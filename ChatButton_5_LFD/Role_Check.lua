
local function Save()
    return WoWToolsSave['ChatButton_LFD'] or {}
end





print(GetLFGRoles())

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


    SetLFGRoles(true , isTank, isHealer, isDPS)
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

--StaticPopupTimeoutSec = 60





























local function Init()
    PVPReadyDialog:HookScript('OnShow', function(self2)
        WoWTools_Mixin:PlaySound()--播放, 声音
        WoWTools_CooldownMixin:Setup(self2, nil, BATTLEFIELD_TIMER_THRESHOLDS[3] or 60, nil, true)--冷却条
    end)

    PVPTimerFrame:HookScript('OnShow', function(self2)
        WoWTools_Mixin:PlaySound()--播放, 声音
        WoWTools_CooldownMixin:Setup(self2, nil, BATTLEFIELD_TIMER_THRESHOLDS[3] or 60, nil, true)--冷却条
    end)



















    function LFDRoleCheckPopup:CancellORSetTime(seconds)
        if self.acceptTime then
            self.acceptTime:Cancel()
            self.acceptTime=nil
        end
        if not seconds then
            if self:IsShown() then
                WoWTools_CooldownMixin:Setup(self, self.onShowTime, StaticPopupTimeoutSec *2, nil, true, true)
            else
                WoWTools_CooldownMixin:Setup(self)
            end
        else
            WoWTools_CooldownMixin:Setup(self, nil, seconds, nil, true, true)--设置冷却
        end
    end



    LFDRoleCheckPopup:HookScript("OnUpdate",function(self)--副本职责
        if IsModifierKeyDown() then
            self:CancellORSetTime(nil)
        end
    end)

    LFDRoleCheckPopup:HookScript("OnHide",function(self)
        self:CancellORSetTime(nil)
        self.onShowTime=nil
    end)

    LFDRoleCheckPopup:HookScript("OnShow",function(self)--副本职责
        self.onShowTime= GetTime()

        WoWTools_Mixin:PlaySound()--播放, 声音
        if not Save().autoSetPvPRole or IsModifierKeyDown() then
            return
        end

        local _, _, _, _, _, isBGRoleCheck = GetLFGRoleUpdate();
        if isBGRoleCheck  then
            Set_PvPRoles()--检测是否选定角色pvp
        else
            Set_PvERoles()
        end

        if not LFDRoleCheckPopupAcceptButton:IsEnabled() then
            LFDRoleCheckPopup_UpdateAcceptButton()
        end

        print(WoWTools_LFDMixin.addName..WoWTools_DataMixin.Icon.icon2,
                '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '职责确认' or ROLE_POLL)..': |cfff00fff'.. SecondsToTime(Save().sec).. '|r '..(WoWTools_DataMixin.onlyChinese and '接受' or ACCEPT)..'|r',
                '|cnRED_FONT_COLOR:'..'Alt '..(WoWTools_DataMixin.onlyChinese and '取消' or CANCEL)
            )

        self:CancellORSetTime(Save().sec)

        self.acceptTime= C_Timer.NewTimer(Save().sec, function()
            if LFDRoleCheckPopupAcceptButton:IsEnabled() and not IsModifierKeyDown() then
                local t=LFDRoleCheckPopupDescriptionText:GetText()
                if t~='' then
                    print(
                        WoWTools_DataMixin.Icon.icon2..WoWTools_LFDMixin.addName,
                        '|cffff00ff',
                        WoWTools_TextMixin:CN(t)
                    )
                end
                LFDRoleCheckPopupAcceptButton:Click()--LFDRoleCheckPopupAccept_OnClick
            end
        end)
    end)




















--职责确认 RolePoll.lua
    hooksecurefunc('RolePollPopup_Show', function(self)
        WoWTools_Mixin:PlaySound()--播放, 声音
        if not Save().autoSetPvPRole or IsModifierKeyDown() then
            return
        end

        local icon
        local btn2

        local canBeTank, canBeHealer, canBeDamager = UnitGetAvailableRoles("player")
        local role = select(5, GetSpecializationInfo(GetSpecialization() or 0))
        if role=='DAMAGER' and canBeDamager then
            btn2= RolePollPopupRoleButtonDPS
            icon= WoWTools_DataMixin.Icon['DAMAGER']
        elseif role=='TANK' and canBeTank then
            btn2= RolePollPopupRoleButtonTank
            icon= WoWTools_DataMixin.Icon['TANK']
        elseif role=='HEALER' and canBeHealer then
            btn2= RolePollPopupRoleButtonHealer
            icon= WoWTools_DataMixin.Icon['HEALER']
        end


        if btn2 then
            btn2.checkButton:SetChecked(true)
            WoWTools_Mixin:Call(RolePollPopupRoleButtonCheckButton_OnClick, btn2.checkButton, btn2)
            WoWTools_CooldownMixin:Setup(self, nil, WoWToolsSave['ChatButton_LFD'].sec, nil, true)--冷却条
            self.aceTime=C_Timer.NewTimer(Save().sec, function()
                if self.acceptButton:IsEnabled() and self:IsShown() and not IsMetaKeyDown() then
                    self.acceptButton:Click()
                    print(
                        WoWTools_DataMixin.Icon.icon2..WoWTools_LFDMixin.addName,
                        WoWTools_DataMixin.onlyChinese and '职责确认' or ROLE_POLL,
                        icon or ''
                    )
                end
            end)
        end
    end)

    --RolePollPopup:HookScript('OnShow', function(self)


    RolePollPopup:HookScript('OnUpdate', function(self)
        if IsModifierKeyDown() or not self.acceptButton:IsEnabled() then
            if self.aceTime then
                self.aceTime:Cancel()
                self.aceTime= nil
            end
            WoWTools_CooldownMixin:Setup(self)--冷却条
        end
    end)

    RolePollPopup:HookScript('OnHide', function(self)
        if self.aceTime then
            self.aceTime:Cancel()
            self.aceTime= nil
        end
        WoWTools_CooldownMixin:Setup(self)--冷却条
    end)

















    C_Timer.After(2, function()
        Set_PvERoles()
        Set_PvPRoles()
    end)







    Init=function()end
end


















function WoWTools_LFDMixin:Init_RolePollPopup()
    Init()
end