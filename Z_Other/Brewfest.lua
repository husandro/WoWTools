
local addName

local function Save()
    return WoWToolsSave['Other_Brewfest']
end






--####
--初始
--####
local function Init()
    local btn= CreateFrame('Button', 'WoWToolsBrewfestButton', UIParent, 'WoWToolsButtonTemplate')
    btn:SetSize(48, 48)
    btn:SetNormalTexture('132248')
    --WoWTools_ButtonMixin:Cbtn(UIParent, {size=48, texture=132248})
    btn:SetShown(false)

    btn.topText= WoWTools_LabelMixin:Create(btn, {size=22})--debuff
    btn.centerText= WoWTools_LabelMixin:Create(btn, {size=22})--持续，时间
    btn.speedText= WoWTools_LabelMixin:Create(btn, {size=16})--移动，速度
    btn.itemText= WoWTools_LabelMixin:Create(btn, {size=16})--物品，数量
    btn.timeText= WoWTools_LabelMixin:Create(btn, {size=16})--坐骑，剩余，时间
    btn.rightText= WoWTools_LabelMixin:Create(btn, {size=16})--本次，物品，收入

    btn.topText:SetPoint('BOTTOM', btn, 'TOP')
    btn.centerText:SetPoint('CENTER')

    btn.speedText:SetPoint('TOPLEFT', btn, 'BOTTOMLEFT')
    btn.itemText:SetPoint('TOPLEFT', btn.speedText, 'BOTTOMLEFT')
    btn.timeText:SetPoint('TOPLEFT', btn.itemText, 'BOTTOMLEFT')
    btn.rightText:SetPoint('LEFT', btn, 'RIGHT')

    btn.leftTexture= btn:CreateTexture()
    btn.leftTexture:SetPoint('RIGHT', btn, 'LEFT')
    btn.leftTexture:SetSize(48,48)
    btn.leftTexture:SetTexture(132622)
    btn.leftTexture:SetShown(false)

    btn:SetScript('OnShow', function(self)
        self.item= C_Item.GetItemCount(37829, true, false, true)
    end)
    btn:SetScript('OnHide', function(self)
        local num= C_Item.GetItemCount(37829, true, false, true)
        if self.item and self.item<num then
            print(WoWTools_DataMixin.Icon.icon2..addName, WoWTools_ItemMixin:GetLink(37829), self.item)
        end
        self.item=nil
    end)

    function btn.leftTexture:set_tipSound()
        if self:GetParent():IsVisible() then
            WoWTools_DataMixin:PlaySound()
        end
    end
    btn.leftTexture:SetScript('OnShow', btn.leftTexture.set_tipSound)
    btn.leftTexture:SetScript('OnHide', btn.leftTexture.set_tipSound)

    btn:RegisterForDrag("RightButton")
    btn:SetMovable(true)
    btn:SetClampedToScreen(true)

    btn:SetScript("OnDragStart", btn.StartMoving)
    btn:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().Point={self:GetPoint(1)}
            Save().Point[2]=nil
        end
    end)
    btn:SetScript("OnMouseUp", ResetCursor)
    btn:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' and not IsModifierKeyDown() then
            self:set_Shown()
        elseif d=='RightButton' then
            SetCursor('UI_MOVE_CURSOR')
        end
    end)

    function btn:set_Scale()
        self:SetScale(Save().scale or 1)
    end
    btn:SetScript('OnMouseWheel', function(self, d)--缩放
        local sacle= Save().scale or 1
        if d==1 then
            sacle= sacle+0.05
        elseif d==-1 then
            sacle= sacle-0.05
        end
        sacle= sacle>4 and 4 or sacle
        sacle= sacle<0.4 and 0.4 or sacle

        Save().scale=sacle
        self:set_Scale()
        print(WoWTools_DataMixin.Icon.icon2..addName, (WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE), '|cnGREEN_FONT_COLOR:'..sacle)
    end)

    function btn:set_Point()
        if Save().Point then
            self:SetPoint(Save().Point[1], UIParent, Save().Point[3], Save().Point[4], Save().Point[5])
        else
            self:SetPoint('CENTER',-350, 150)
        end
    end

    function btn:set_Shown()
        local info= C_UnitAuras.GetPlayerAuraBySpellID(42992)
                or C_UnitAuras.GetPlayerAuraBySpellID(42993)
                or C_UnitAuras.GetPlayerAuraBySpellID(42994)
                or C_UnitAuras.GetPlayerAuraBySpellID(43332)


                or C_UnitAuras.GetPlayerAuraBySpellID(43880)
                or C_UnitAuras.GetPlayerAuraBySpellID(43883)

        self:SetNormalTexture(info and info.icon or 132248)
        self:SetShown(info and true or false)

        local duration= (info and info.duration and info.duration>0) and info.duration or nil
        WoWTools_CooldownMixin:Setup(self, nil, duration, nil, true, true)

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

    function btn:set_ItmeNum()
        local num = C_Item.GetItemCount(37829, true, false, true)
        self.itemText:SetText(num>0 and '|T133784:0|t'..num or '')
        self.leftTexture:SetShown(C_Item.GetItemCount(33797)>0 and true or false)
        num= num- (self.item or num)
        self.rightText:SetText(num>0 and '|T133784:0|t'..num or '')
    end

    function btn:set_Event()
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

    btn:RegisterEvent('PLAYER_ENTERING_WORLD')
    btn:SetScript('OnEvent', function(self, event, _, arg2)
        if event=='PLAYER_ENTERING_WORLD' then
            self:set_Event()
        elseif event=='UNIT_AURA' then
            if arg2 and arg2.addedAuras then
                for _, info in pairs(arg2.addedAuras) do
                    if info.spellId==43052 then
                        self.Timer= nil
                        self.spellId=nil
                        WoWTools_DataMixin:PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN)
                        break
                    end
                end
            end
            self:set_Shown()
        elseif event=='BAG_UPDATE_DELAYED' then
            self:set_ItmeNum()
        end
    end)

    btn:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 0.3) + elapsed
        if self.elapsed > 0.3 then
            local info= C_UnitAuras.GetPlayerAuraBySpellID(43880) or C_UnitAuras.GetPlayerAuraBySpellID(43883)
            if info and info.expirationTime and info.expirationTime>0 then
                self.timeText:SetText('|T'..info.icon..':0|t'..WoWTools_TimeMixin:Info(nil, true, nil, info.expirationTime))
            end

            local text
            info= C_UnitAuras.GetPlayerAuraBySpellID(43052)
            if info and info.applications then
                text= (info.applications<=60 and '|cnGREEN_FONT_COLOR:' or info.applications<=80 and '|cnYELLOW_FONT_COLOR:' or '|cnWARNING_FONT_COLOR:')
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

    btn:SetScript('OnClick', function(_, d)
        if d=='LeftButton' and IsShiftKeyDown() then
            local macroId = CreateMacro('Ram', 236912, '/click ExtraActionButton1')
            print(WoWTools_DataMixin.Icon.icon2..addName, WoWTools_DataMixin.onlyChinese and '创建宏' or CREATE_MACROS, 'Ram',
                macroId and '/click ExtraActionButton1' or (WoWTools_DataMixin.onlyChinese and '无法创建' or NONE)
            )
        end
    end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:SetSpellByID(self.spellId or 43883)
        GameTooltip:AddLine(' ')
        local macro= select(3, GetMacroInfo('Ram'))
        local col= (macro and macro:find('ExtraActionButton1')) and '|cff9e9e9e' or ''
        GameTooltip:AddDoubleLine(col..(WoWTools_DataMixin.onlyChinese and '创建宏"' or CREATE_MACROS), col..'Shift+'..WoWTools_DataMixin.Icon.left)
        GameTooltip:AddLine(col..'/click ExtraActionButton1')
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE)..' '..(Save().scale or 1), WoWTools_DataMixin.Icon.mid)
        GameTooltip:Show()
    end)
    btn:SetScript('OnLeave', GameTooltip_Hide)

    btn:set_Scale()
    btn:set_Point()
    btn:set_Event()

    Init=function()
        btn:SetShown( not Save().disabled)
    end
end







local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1== 'WoWTools' then

            WoWToolsSave['Other_Brewfest']= WoWToolsSave['Other_Brewfest'] or {disabled=true}

--添加控制面板
            addName= '|T132248:0|t'..(WoWTools_DataMixin.onlyChinese and '美酒节赛羊' or WoWTools_TextMixin:CN(C_Item.GetItemNameByID(33976), {itemID=33976, isName=true}) or 'Brewfest')

            WoWTools_PanelMixin:Check_Button({
                checkName= addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or false
                    if not Save().disabled then
                        Init()
                    else
                        print(addName..WoWTools_DataMixin.Icon.icon2, WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                    end
                end,
                buttonText= WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION,
                buttonFunc= function()
                    Save().Point=nil
                    if _G['WoWToolsBrewfestButton'] then
                        _G['WoWToolsBrewfestButton']:ClearAllPoints()
                        _G['WoWToolsBrewfestButton']:set_Point()
                    end
                    print(addName..WoWTools_DataMixin.Icon.icon2, WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION)
                end,
                tooltip=function()
                    return WoWTools_DataMixin.onlyChinese and '节日: 美酒节（赛羊）'
                        or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC,
                            CALENDAR_FILTER_HOLIDAYS,
                            WoWTools_TextMixin:CN(C_Item.GetItemNameByID(33976), {itemID=33976, isName=true})
                            or ''
                        )
                end,
                layout= WoWTools_OtherMixin.Layout,
                category= WoWTools_OtherMixin.Category,
            })

            if not Save().disabled then
                WoWTools_DataMixin:Load(33976, 'item')--美酒节赛羊
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
            end
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        Init()
        self:UnregisterEvent(event)
    end
end)