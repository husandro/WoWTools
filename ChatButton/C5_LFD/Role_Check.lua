
local function Save()
    return WoWToolsSave['ChatButton_LFD']
end







local function Set_PvERoles()
    local isTank, isHealer, isDPS = select(2, GetLFGRoles())--检测是否选定角色pve

    if Save().autoSetRole or not (isTank or isHealer or isDPS) then
        local role = select(5, C_SpecializationInfo.GetSpecializationInfo(GetSpecialization() or 0))
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
end





local function Set_PvPRoles()--检测是否选定角色pvp
    local tank, healer, dps = GetPVPRoles()

    if Save().autoSetRole or not (tank or healer or dps) then
        tank, healer, dps= true,true,true
        local sid=GetSpecialization()
        if sid then
            local role = select(5, C_SpecializationInfo.GetSpecializationInfo(sid))
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
    if not Save().autoSetPvPRole then
        return
    end


    PVPReadyDialog:HookScript('OnShow', function(self)
        WoWTools_DataMixin:PlaySound()--播放, 声音
        WoWTools_CooldownMixin:Setup(self, nil, BATTLEFIELD_TIMER_THRESHOLDS[3] or 60, nil, true)--冷却条
    end)

    PVPTimerFrame:HookScript('OnShow', function(self)
        WoWTools_DataMixin:PlaySound()--播放, 声音
        WoWTools_CooldownMixin:Setup(self, nil, BATTLEFIELD_TIMER_THRESHOLDS[3] or 60, nil, true)--冷却条
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

        WoWTools_DataMixin:PlaySound()--播放, 声音
        if IsModifierKeyDown() then
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

        print(
            WoWTools_LFDMixin.addName..WoWTools_DataMixin.Icon.icon2,

            '|cnGREEN_FONT_COLOR:'
            ..(WoWTools_DataMixin.onlyChinese and '职责确认' or ROLE_POLL)
            ..': |cfff00fff'.. SecondsToTime(Save().sec or 5)..'|r '
            ..(WoWTools_DataMixin.onlyChinese and '接受' or ACCEPT)..'|r',

            '|cnWARNING_FONT_COLOR:'..'Alt '
            ..(WoWTools_DataMixin.onlyChinese and '取消' or CANCEL)
        )

        self:CancellORSetTime(Save().sec or 5)

        self.acceptTime= C_Timer.NewTimer(Save().sec or 5, function()
            if LFDRoleCheckPopupAcceptButton:IsEnabled() and not IsModifierKeyDown() then
                local t=LFDRoleCheckPopupDescriptionText:GetText()
                if t~='' then
                    print(
                        WoWTools_LFDMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        '|cffff00ff',
                        WoWTools_TextMixin:CN(t)
                    )
                end
                LFDRoleCheckPopupAcceptButton:Click()--LFDRoleCheckPopupAccept_OnClick
            end
        end)
    end)




















--职责确认 RolePoll.lua
    WoWTools_DataMixin:Hook('RolePollPopup_Show', function(self)
        WoWTools_DataMixin:PlaySound()--播放, 声音
        if IsModifierKeyDown() or InCombatLockdown() then
            return
        end

        local icon
        local btn2

        local canBeTank, canBeHealer, canBeDamager = UnitGetAvailableRoles("player")
        local role = select(5, C_SpecializationInfo.GetSpecializationInfo(GetSpecialization() or 0))
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
            WoWTools_DataMixin:Call('RolePollPopupRoleButtonCheckButton_OnClick', btn2.checkButton, btn2)
            WoWTools_CooldownMixin:Setup(self, nil, Save().sec or 5, nil, true)--冷却条
            self.aceTime=C_Timer.NewTimer(Save().sec or 5, function()
                if self.acceptButton:IsEnabled()
                    and self:IsShown()
                    and not IsMetaKeyDown()
                    and not InCombatLockdown()
                then
                    self.acceptButton:Click()
                    print(
                        WoWTools_LFDMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_DataMixin.onlyChinese and '职责确认' or ROLE_POLL,
                        icon or ''
                    )
                end
            end)
        end
    end)

    --RolePollPopup:HookScript('OnShow', function(self)


    RolePollPopup:HookScript('OnUpdate', function(self)
        if IsModifierKeyDown() or not self.acceptButton:IsEnabled() or InCombatLockdown() then
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
        --WoWTools_CooldownMixin:Setup(self)--冷却条
    end)




































--队伍查找器, 邀请信息
    LFGListInviteDialog:HookScript("OnShow", function(self)
        WoWTools_DataMixin:PlaySound(SOUNDKIT.IG_PLAYER_INVITE)--播放, 声音

        WoWTools_CooldownMixin:Setup(self, nil, StaticPopupTimeoutSec, nil, true, true, nil)--冷却条

        if not self.resultID then
            return
        end

        local status, _, _, role= select(2,C_LFGList.GetApplicationInfo(self.resultID))
        local info= C_LFGList.GetSearchResultInfo(self.resultID)

        if status~="invited" or not info then
            return
        end

        local leaderGuid = info.partyGUID and select(8, C_SocialQueue.GetGroupInfo(info.partyGUID))

        print(
            WoWTools_LFDMixin.addName..WoWTools_DataMixin.Icon.icon2,

            info.leaderOverallDungeonScore and info.leaderOverallDungeonScore>0 and
                '|T4352494:0|t'..WoWTools_ChallengeMixin:KeystoneScorsoColor(info.leaderOverallDungeonScore)
            or '',--地下城史诗,分数

            info.leaderPvpRatingInfo and info.leaderPvpRatingInfo.rating and info.leaderPvpRatingInfo.rating>0 and
                '|A:pvptalents-warmode-swords:0:0|a|cnWARNING_FONT_COLOR:'..info.leaderPvpRatingInfo.rating..'|r'
            or '',--PVP 分数

            (info.leaderName or leaderGuid) and format(
                WoWTools_DataMixin.onlyChinese and '%s邀请你加入' or COMMUNITY_INVITATION_FRAME_INVITATION_TEXT,
                WoWTools_UnitMixin:GetLink(nil, leaderGuid, info.leaderName, false)..' '
            )
            or '',--%s邀请你加入

            info.name,--名称

            WoWTools_DataMixin.Icon[role] or '',

            info.numMembers and info.numMembers>0 and
                (WoWTools_DataMixin.onlyChinese and '队员' or PLAYERS_IN_GROUP)..'|cff00ff00 '..info.numMembers..'|r'
            or '',--队伍成员数量

            info.numBNetFriends and info.numBNetFriends>0 and
            '|cff00ccff'..WoWTools_DataMixin.Icon.wow2..(WoWTools_DataMixin.onlyChinese and '战网好友' or PLAYERS_IN_GROUP)..' '..info.numMembers..'|r'
            or '',

            info.numCharFriends and info.numCharFriends>0 and
            '|cffedd100'..WoWTools_DataMixin.Icon.wow2..(WoWTools_DataMixin.onlyChinese and '好友' or FRIEND)..' '..info.numCharFriends..'|r'
            or '',

            info.autoAccept and
                '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '自动邀请' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, INVITE))..'|r'
            or '',--对方是否开启, 自动邀请

            info.activityID and
                '|cffff00ff'..WoWTools_TextMixin:CN(C_LFGList.GetActivityFullName(info.activityID))..'|r'
            or '',--查找器,类型

            info.isWarMode and-- info.isWarMode ~= C_PvP.IsWarModeDesired() and
                '|A:pvptalents-warmode-swords:0:0|a|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '战争模式' or TALENT_FRAME_LABEL_WARMODE)..'|r'
            or ''
        )
    end)




























--确定，进入副本，信息
    LFGInvitePopup:HookScript("OnShow", function(self)--自动进入FB
        WoWTools_DataMixin:PlaySound()--播放, 声音
        WoWTools_CooldownMixin:Setup(self, nil, self.timeOut and StaticPopupTimeoutSec, nil, true, true)
    end)
    --[[LFGInvitePopup:HookScript('OnHide', function(self)
        WoWTools_CooldownMixin:Setup(self)
    end)]]

    LFGDungeonReadyDialog:HookScript("OnShow", function(self)--自动进入FB
        WoWTools_DataMixin:PlaySound()--播放, 声音
        WoWTools_CooldownMixin:Setup(self, nil, self.timeOut or 38, nil, true, true)
    end)
    WoWTools_DataMixin:Hook('LFGDungeonReadyPopup_OnFail', function()
        if LFGDungeonReadyPopup:IsShown() then
            WoWTools_CooldownMixin:Setup(LFGDungeonReadyPopup, nil, LFGDungeonReadyPopup.closeIn or 5, nil, true, true)
        end
    end)



--确定，进入副本
    LFGDungeonReadyDialog.bossTipsLabel= WoWTools_LabelMixin:Create(LFGDungeonReadyDialog)
    LFGDungeonReadyDialog.bossTipsLabel:SetPoint('LEFT', LFGDungeonReadyDialog, 'RIGHT', 4, 0)

    LFGDungeonReadyDialog:HookScript('OnHide', function(self)
        self.bossTipsLabel:SetText('')
    end)

    LFGDungeonReadyDialog:HookScript('OnShow', function(self)
        local totalEncounters= select(9, GetLFGProposal())
        local text
        local dead=0
        for i=1, totalEncounters or 0 do
            local bossName, _, isKilled = GetLFGProposalEncounter(i)
            if bossName then
                text= (text and text..'|n' or '')..i..') '

                if isKilled then
                    text= text
                        ..'|A:common-icon-checkmark:0:0|a|cnWARNING_FONT_COLOR:'..WoWTools_TextMixin:CN(bossName)
                        ..'|r |cffffffff'..(WoWTools_DataMixin.onlyChinese and '已消灭' or BOSS_DEAD)..'|r'
                    dead= dead+1
                else
                    text= text
                        ..'|A:QuestLegendary:0:0|a|cnGREEN_FONT_COLOR:'..WoWTools_TextMixin:CN(bossName)
                        ..'|r |cffffffff'..(WoWTools_DataMixin.onlyChinese and '可消灭' or BOSS_ALIVE)..'|r'
                end
            end
        end

        if text then
            text= (totalEncounters==dead and '|cff626262' or '|cffffffff')
                ..(WoWTools_DataMixin.onlyChinese and '首领：' or BOSSES)
                ..format(WoWTools_DataMixin.onlyChinese and '已消灭%d/%d个首领' or BOSSES_KILLED, dead, totalEncounters)
                ..'|r|n|n'
                ..text
                ..'|n|n'..WoWTools_ChatMixin.addName..' '..WoWTools_LFDMixin.addName
        end
        self.bossTipsLabel:SetText(text or '')
    end)


    LFGDungeonReadyDialogCloseButton:HookScript('OnLeave', GameTooltip_Hide)
    LFGDungeonReadyDialogCloseButton:HookScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE)
        GameTooltip:Show()
    end)

    Menu.ModifyMenu("MENU_QUEUE_STATUS_FRAME", function(self, root)
        if self:IsMouseOver() then
            WoWTools_LFDMixin:ShowMenu_LFGDungeonReadyDialog(root)--显示 LFGDungeonReadyDialog
        end
    end)


















    EventRegistry:RegisterFrameEventAndCallback("PLAYER_SPECIALIZATION_CHANGED", function(owner, arg1)
        if arg1=='player' and Save().autoSetRole then
            Set_PvERoles()
            Set_PvPRoles()
        end
    end)



    EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(owner)
        Set_PvERoles()
        Set_PvPRoles()

--确定，进入副本
            if GetLFGProposal() and not LFGDungeonReadyPopup:IsShown() then
                StaticPopupSpecial_Show(LFGDungeonReadyPopup)
                WoWTools_DataMixin:Call('LFGDungeonReadyPopup_Update')
            end
        EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
    end)

    Init=function()
        Set_PvERoles()
        Set_PvPRoles()
    end
end


















function WoWTools_LFDMixin:Init_RolePollPopup()
    Init()
end