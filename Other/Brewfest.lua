local id, e= ...
local addName= 'Brewfest'
local Save={
    disabled=not e.Player.husandro,
    --Point
    --scale
}

local button

--####
--初始
--####
local function Init()
    button= WoWTools_ButtonMixin:Cbtn(UIParent, {size={48, 48}, texture=132248})
    button:SetShown(false)

    button.topText= WoWTools_LabelMixin:Create(button, {size=22})--debuff
    button.centerText= WoWTools_LabelMixin:Create(button, {size=22})--持续，时间
    button.speedText= WoWTools_LabelMixin:Create(button, {size=16})--移动，速度
    button.itemText= WoWTools_LabelMixin:Create(button, {size=16})--物品，数量
    button.timeText= WoWTools_LabelMixin:Create(button, {size=16})--坐骑，剩余，时间
    button.rightText= WoWTools_LabelMixin:Create(button, {size=16})--本次，物品，收入

    button.topText:SetPoint('BOTTOM', button, 'TOP')
    button.centerText:SetPoint('CENTER')

    button.speedText:SetPoint('TOPLEFT', button, 'BOTTOMLEFT')
    button.itemText:SetPoint('TOPLEFT', button.speedText, 'BOTTOMLEFT')
    button.timeText:SetPoint('TOPLEFT', button.itemText, 'BOTTOMLEFT')
    button.rightText:SetPoint('LEFT', button, 'RIGHT')

    button.leftTexture= button:CreateTexture()
    button.leftTexture:SetPoint('RIGHT', button, 'LEFT')
    button.leftTexture:SetSize(48,48)
    button.leftTexture:SetTexture(132622)
    button.leftTexture:SetShown(false)

    button:SetScript('OnShow', function(self)
        self.item= C_Item.GetItemCount(37829, true, false, true)
    end)
    button:SetScript('OnHide', function(self)
        local num= C_Item.GetItemCount(37829, true, false, true)
        if self.item and self.item<num then
            print(WoWTools_Mixin.addName, e.cn(addName), WoWTools_ItemMixin:GetLink(37829), self.item)
        end
        self.item=nil
    end)

    function button.leftTexture:set_tipSound()
        if self:GetParent():IsVisible() then
            e.PlaySound()
        end
    end
    button.leftTexture:SetScript('OnShow', button.leftTexture.set_tipSound)
    button.leftTexture:SetScript('OnHide', button.leftTexture.set_tipSound)

    button:RegisterForDrag("RightButton")
    button:SetMovable(true)
    button:SetClampedToScreen(true)

    button:SetScript("OnDragStart", button.StartMoving)
    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save.Point={self:GetPoint(1)}
        Save.Point[2]=nil
    end)
    button:SetScript("OnMouseUp", ResetCursor)
    button:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' and not IsModifierKeyDown() then
            self:set_Shown()
        elseif d=='RightButton' then
            SetCursor('UI_MOVE_CURSOR')
        end
    end)

    function button:set_Scale()
        self:SetScale(Save.scale or 1)
    end
    button:SetScript('OnMouseWheel', function(self, d)--缩放
        local sacle= Save.scale or 1
        if d==1 then
            sacle= sacle+0.05
        elseif d==-1 then
            sacle= sacle-0.05
        end
        sacle= sacle>4 and 4 or sacle
        sacle= sacle<0.4 and 0.4 or sacle

        Save.scale=sacle
        self:set_Scale()
        print(WoWTools_Mixin.addName, e.cn(addName), (e.onlyChinese and '缩放' or UI_SCALE), '|cnGREEN_FONT_COLOR:'..sacle)
    end)

    function button:set_Point()
        if Save.Point then
            self:SetPoint(Save.Point[1], UIParent, Save.Point[3], Save.Point[4], Save.Point[5])
        else
            self:SetPoint('CENTER',-350, 150)
        end
    end

    function button:set_Shown()
        local info= C_UnitAuras.GetPlayerAuraBySpellID(42992)
                or C_UnitAuras.GetPlayerAuraBySpellID(42993)
                or C_UnitAuras.GetPlayerAuraBySpellID(42994)
                or C_UnitAuras.GetPlayerAuraBySpellID(43332)


                or C_UnitAuras.GetPlayerAuraBySpellID(43880)
                or C_UnitAuras.GetPlayerAuraBySpellID(43883)

        self:SetNormalTexture(info and info.icon or 132248)
        self:SetShown(info and true or false)

        local duration= (info and info.duration and info.duration>0) and info.duration or nil
        e.Ccool(self, nil, duration, nil, true, true)

        local spellId= info and info.spellId or nil
        if duration then
            self.Time=nil
            self.spellId=nil
        elseif spellId and spellId~=self.spellId then
            self.Time= (not duration and spellId and self.spellId~= spellId) and GetTime() or nil
            self.spellId= spellId
        end

        self:set_ItmeNum()
    end

    function button:set_ItmeNum()
        local num = C_Item.GetItemCount(37829, true, false, true)
        self.itemText:SetText(num>0 and '|T133784:0|t'..num or '')
        self.leftTexture:SetShown(C_Item.GetItemCount(33797)>0 and true or false)
        num= num- (self.item or num)
        self.rightText:SetText(num>0 and '|T133784:0|t'..num or '')
    end

    function button:set_Event()
        if IsInInstance() then
            self:UnregisterEvent('UNIT_AURA')
            self:UnregisterEvent('BAG_UPDATE_DELAYED')
        else
            self:RegisterUnitEvent('UNIT_AURA', 'player')
            self:RegisterEvent('BAG_UPDATE_DELAYED')
            self.elapsed = 0
        end
        self:set_Shown()
    end

    button:RegisterEvent('PLAYER_ENTERING_WORLD')
    button:SetScript('OnEvent', function(self, event, _, arg2)
        if event=='PLAYER_ENTERING_WORLD' then
            self:set_Event()
        elseif event=='UNIT_AURA' then
            if arg2 and arg2.addedAuras then
                for _, info in pairs(arg2.addedAuras) do
                    if info.spellId==43052 then
                        self.Timer= nil
                        self.spellId=nil
                        e.PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN)
                        break
                    end
                end
            end
            self:set_Shown()
        elseif event=='BAG_UPDATE_DELAYED' then
            self:set_ItmeNum()
        end
    end)

    button:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 0.3) + elapsed
        if self.elapsed > 0.3 then
            local info= C_UnitAuras.GetPlayerAuraBySpellID(43880) or C_UnitAuras.GetPlayerAuraBySpellID(43883)
            if info and info.expirationTime and info.expirationTime>0 then
                self.timeText:SetText('|T'..info.icon..':0|t'..WoWTools_TimeMixin:Info(nil, true, nil, info.expirationTime))
            end

            local text
            info= C_UnitAuras.GetPlayerAuraBySpellID(43052)
            if info and info.applications then
                text= (info.applications<=60 and '|cnGREEN_FONT_COLOR:' or info.applications<=80 and '|cnYELLOW_FONT_COLOR:' or '|cnRED_FONT_COLOR:')
                    ..'|T'..info.icon..':0|t'
                    ..info.applications
            end
            self.topText:SetText(text or '')

            text=nil
            if self.Time then
                local time= GetTime()
                time= time<self.Time and time+86400 or time
                text= format('%i', time- self.Time)
            end
            self.centerText:SetText(text or '')

            self.speedText:SetFormattedText('|T132307:0|t%i',GetUnitSpeed("player")*100/7)
            self.elapsed=0
        end
    end)

    button:SetScript('OnClick', function(_, d)
        if d=='LeftButton' and IsShiftKeyDown() then
            local macroId = CreateMacro('Ram', 236912, '/click ExtraActionButton1')
            print(WoWTools_Mixin.addName, e.cn(addName), e.onlyChinese and '创建宏' or CREATE_MACROS, 'Ram',
                macroId and '/click ExtraActionButton1' or (e.onlyChinese and '无法创建' or NONE)
            )
        end
    end)
    button:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:SetSpellByID(self.spellId or 43883)
        e.tips:AddLine(' ')
        local macro= select(3, GetMacroInfo('Ram'))
        local col= (macro and macro:find('ExtraActionButton1')) and '|cff9e9e9e' or ''
        e.tips:AddDoubleLine(col..(e.onlyChinese and '创建宏"' or CREATE_MACROS), col..'Shift+'..e.Icon.left)
        e.tips:AddLine(col..'/click ExtraActionButton1')
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' '..(Save.scale or 1), e.Icon.mid)
        e.tips:Show()
    end)
    button:SetScript('OnLeave', GameTooltip_Hide)

    button:set_Scale()
    button:set_Point()
    button:set_Event()
end









EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
    if arg1~=id then
        return
    end
    Save= WoWToolsSave[addName] or Save

    --添加控制面板
    e.AddPanel_Header(nil, e.onlyChinese and '其它' or OTHER)
    e.AddPanel_Check_Button({
        checkName= '|T132248:0|t'..e.cn(addName),
        GetValue= function() return not Save.disabled end,
        SetValue= function()
            Save.disabled= not Save.disabled and true or nil
            if not Save.disabled then
                if not button then
                    Init()
                end
                button:SetShown(true)
            else
                print(WoWTools_Mixin.addName, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        end,
        buttonText= e.onlyChinese and '重置位置' or RESET_POSITION,
        buttonFunc= function()
            Save.Point=nil
            if button then
                button:ClearAllPoints()
                button:set_Point()
            end
            print(WoWTools_Mixin.addName, e.cn(addName), e.onlyChinese and '重置位置' or RESET_POSITION)
        end,
        tooltip= e.onlyChinese and '节日: 美酒节（赛羊）' or CALENDAR_FILTER_HOLIDAYS,
        layout= nil,
        category= nil,
    })

    if not Save.disabled then
        Init()
    end
    EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
end)

EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGOUT", function()
    if not e.ClearAllSave then
        WoWToolsSave[addName]=Save
    end
end)