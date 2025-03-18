local e= select(2, ...)
local function Save()
    return WoWTools_LFDMixin.Save
end







local function Set_PvERoles()

    if not Save().autoSetPvPRole then
        return
    end
    local _, isTank, isHealer, isDPS = GetLFGRoles()--检测是否选定角色pve
    if isTank or isHealer or isDPS then
        return
    end


    local role = select(5, GetSpecializationInfo(GetSpecialization() or 0))
    if role=='TANK' then
        isTank, isHealer, isDPS=true, false, false
    elseif role=='HEALER' then
        isTank, isHealer, isDPS=false, true, false
    elseif role=='DAMAGER' then
        isTank, isHealer, isDPS=false, false ,true
    else
        isTank, isHealer, isDPS=true, true, true
    end

    SetLFGRoles(true, isTank, isHealer, isDPS)
end








local function Set_PvPRoles()--检测是否选定角色pvp
    if not Save().autoSetPvPRole then
        return
    end

    local tank, healer, dps = GetPVPRoles()
    if  not tank and not  healer and not dps then
        tank, healer, dps=true,true,true
        local sid=GetSpecialization()
        if sid then
            local role = select(5, GetSpecializationInfo(sid))
            if role then
                if role=='TANK' then
                    tank, healer, dps = true, false, false
                elseif role=='HEALER' then
                    tank, healer, dps= false, true, false
                elseif role=='DAMAGER' then
                    tank, healer, dps= false, false,true
                end
            end
        end
        SetPVPRoles(tank, healer, dps)
    end
end




local function Init_LFD()
    function LFDRoleCheckPopup:CancellORSetTime(seconds)
        if self.acceptTime then
            self.acceptTime:Cancel()
        end
        if not seconds then
            e.Ccool(self)
        else
            e.Ccool(self, nil, seconds, nil, true, true)--设置冷却
        end
    end



    LFDRoleCheckPopup:HookScript("OnUpdate",function(self)--副本职责
        if IsModifierKeyDown() then
            self:CancellORSetTime(nil)
        end
    end)


    LFDRoleCheckPopup:HookScript("OnShow",function(self)--副本职责
        e.PlaySound()--播放, 声音
        if not Save().autoSetPvPRole or IsModifierKeyDown() then
            return
        end

        Set_PvPRoles()--检测是否选定角色pvp
        if not LFDRoleCheckPopupAcceptButton:IsEnabled() then
            LFDRoleCheckPopup_UpdateAcceptButton()
        end
        print(e.Icon.icon2..WoWTools_LFDMixin.addName,
                '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '职责确认' or ROLE_POLL)..': |cfff00fff'.. SecondsToTime(WoWTools_LFDMixin.Save.sec).. '|r '..(e.onlyChinese and '接受' or ACCEPT)..'|r',
                '|cnRED_FONT_COLOR:'..'Alt '..(e.onlyChinese and '取消' or CANCEL)
            )
        self:CancellORSetTime(WoWTools_LFDMixin.Save.sec)
        self.acceptTime= C_Timer.NewTimer(WoWTools_LFDMixin.Save.sec, function()
            if LFDRoleCheckPopupAcceptButton:IsEnabled() and not IsModifierKeyDown() then
                local t=LFDRoleCheckPopupDescriptionText:GetText()
                print(e.Icon.icon2..WoWTools_LFDMixin.addName, '|cffff00ff', t)
                LFDRoleCheckPopupAcceptButton:Click()--LFDRoleCheckPopupAccept_OnClick
            end
        end)
    end)
end








local function Init_PvP()
    C_Timer.After(2, Set_PvPRoles)
    PVPReadyDialog:HookScript('OnShow', function(self2)
        e.PlaySound()--播放, 声音
        e.Ccool(self2, nil, BATTLEFIELD_TIMER_THRESHOLDS[3] or 60, nil, true)--冷却条
    end)
end













--职责确认 RolePoll.lua
local function Init_RolePollPopup()
     RolePollPopup:HookScript('OnShow', function(self)
        e.PlaySound()--播放, 声音
        if not Save().autoSetPvPRole or IsModifierKeyDown() then
            return
        end

        local icon
        local btn2

        local canBeTank, canBeHealer, canBeDamager = UnitGetAvailableRoles("player")
        local role = select(5, GetSpecializationInfo(GetSpecialization() or 0))
        if role=='DAMAGER' and canBeDamager then
            btn2= RolePollPopupRoleButtonDPS
            icon= e.Icon['DAMAGER']
        elseif role=='TANK' and canBeTank then
            btn2= RolePollPopupRoleButtonTank
            icon= e.Icon['TANK']
        elseif role=='HEALER' and canBeHealer then
            btn2= RolePollPopupRoleButtonHealer
            icon= e.Icon['HEALER']
        end


        if btn2 then
            btn2.checkButton:SetChecked(true)
            e.call(RolePollPopupRoleButtonCheckButton_OnClick, btn2.checkButton, btn2)
            e.Ccool(self, nil, WoWTools_LFDMixin.Save.sec, nil, true)--冷却条
            self.aceTime=C_Timer.NewTimer(WoWTools_LFDMixin.Save.sec, function()
                if self.acceptButton:IsEnabled() then
                    self.acceptButton:Click()
                    print(e.Icon.icon2..WoWTools_LFDMixin.addName, e.onlyChinese and '职责确认' or ROLE_POLL, icon or '')
                end
            end)
        end
    end)


    RolePollPopup:HookScript('OnUpdate', function(self)
        if IsModifierKeyDown() then
            if self.aceTime then
                self.aceTime:Cancel()
            end
            e.Ccool(self)--冷却条
        end
    end)

    RolePollPopup:HookScript('OnHide', function(self)
        if self.aceTime then
            self.aceTime:Cancel()
        end
        e.Ccool(self)--冷却条
    end)
end


















function WoWTools_LFDMixin:Init_RolePollPopup()
    C_Timer.After(2, Set_PvERoles)
    Init_LFD()
    Init_PvP()
    Init_RolePollPopup()
end