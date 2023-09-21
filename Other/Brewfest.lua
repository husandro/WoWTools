local id, e= ...
local addName= 'Brewfest'
local Save={
    disabled=true,
    --Point
    --scale
}
local panel= CreateFrame("Frame")
local button

--####
--初始
--####
function Init()
    button= e.Cbtn(UIParent, {size={48, 48}, texture=132248})

    button.topText= e.Cstr(button, {size=22})
    button.centerText= e.Cstr(button, {size=22})
    button.speedText= e.Cstr(button, {size=16})
    button.bottomText= e.Cstr(button, {size=16})
    button.bottomText2= e.Cstr(button, {size=16})

    button.topText:SetPoint('BOTTOM', button, 'TOP')
    button.centerText:SetPoint('CENTER')

    button.speedText:SetPoint('TOPLEFT', button, 'BOTTOMLEFT')
    button.bottomText:SetPoint('TOPLEFT', button.speedText, 'BOTTOMLEFT')
    button.bottomText2:SetPoint('TOPLEFT', button.bottomText, 'BOTTOMLEFT')

    button.rightTexture= button:CreateTexture()
    button.rightTexture:SetPoint('RIGHT', button, 'LEFT')
    button.rightTexture:SetSize(48,48)
    button.rightTexture:SetTexture(132622)

    button:RegisterForDrag("RightButton", 'LeftButton')
    button:SetMovable(true)
    button:SetClampedToScreen(true)

    button:SetScript("OnDragStart", button.StartMoving)
    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save.Point={self:GetPoint(1)}
        Save.Point[2]=nil
    end)
    button:SetScript("OnMouseUp", ResetCursor)
    button:SetScript('OnMouseDown', function() SetCursor('UI_MOVE_CURSOR') end)

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
        print(id, addName, (e.onlyChinese and '缩放' or UI_SCALE), '|cnGREEN_FONT_COLOR:'..sacle)
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
        self.bottomText2:SetText('|T133784:0|t'..GetItemCount(37829, true))
        self.rightTexture:SetShown(GetItemCount(33797)>0 and true or false)
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
    button:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_ENTERING_WORLD' then
            self:set_Event()
        elseif event=='UNIT_AURA' then
            self:set_Shown()
        elseif event=='BAG_UPDATE_DELAYED' then
            self:set_ItmeNum()
        end
    end)

    button.elapsed = 0
    button:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= self.elapsed + elapsed
        if self.elapsed > 0.3 then
            local info=C_UnitAuras.GetPlayerAuraBySpellID(43880)
            if info and info.expirationTime then
                self.bottomText:SetText('|T'..info.icon..':0|t'..e.GetTimeInfo(nil, true, nil, info.expirationTime))
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

    button:set_Scale()
    button:set_Point()
    button:set_Event()
end



--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            if not Save.disabled then
                Init()
            end
            panel:UnregisterEvent('ADDON_LOADED')

            --添加控制面板
            e.AddPanel_Header(nil, e.onlyChinese and '其它' or OTHER)
            e.AddPanel_Check_Button({
                checkName= '|T132248:0|t'..addName,
                checkValue= not Save.disabled,
                checkFunc= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end,
                buttonText= e.onlyChinese and '重置位置' or RESET_POSITION,
                buttonFunc= function()
                    Save.Point=nil
                    if button then
                        button:ClearAllPoints()
                        button:set_Point()
                    end
                    print(id, addName, e.onlyChinese and '重置位置' or RESET_POSITION)
                end,
                tooltip= e.onlyChinese and '节日: 美酒节（赛羊）' or CALENDAR_FILTER_HOLIDAYS,
                layout= nil,
                category= nil,
            })
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    end
end)