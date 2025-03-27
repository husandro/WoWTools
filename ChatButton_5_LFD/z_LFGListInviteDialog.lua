--队伍查找器, 邀请信息









local function Settings(self)

    WoWTools_Mixin:PlaySound(SOUNDKIT.IG_PLAYER_INVITE)--播放, 声音

    WoWTools_CooldownMixin:Setup(self, nil, STATICPOPUP_TIMEOUT, nil, true, true, nil)--冷却条

    if WoWToolsSave['ChatButton_LFD'].disabedLFDInviteInfo or not self.resultID then
        return
    end

    local status, _, _, role= select(2,C_LFGList.GetApplicationInfo(self.resultID))
    local info= C_LFGList.GetSearchResultInfo(self.resultID)

    if status~="invited" or not info then
        return
    end

    print(
        WoWTools_DataMixin.Icon.icon2..WoWTools_LFDMixin.addName,

        info.leaderOverallDungeonScore and info.leaderOverallDungeonScore>0 and
            '|T4352494:0|t'..WoWTools_WeekMixin:KeystoneScorsoColor(info.leaderOverallDungeonScore)
        or '',--地下城史诗,分数

        info.leaderPvpRatingInfo and info.leaderPvpRatingInfo.rating and info.leaderPvpRatingInfo.rating>0 and
            '|A:pvptalents-warmode-swords:0:0|a|cnRED_FONT_COLOR:'..info.leaderPvpRatingInfo.rating..'|r'
        or '',--PVP 分数

        info.leaderName and
            (WoWTools_DataMixin.onlyChinese and '%s邀请你加入' or COMMUNITY_INVITATION_FRAME_INVITATION_TEXT):format(WoWTools_UnitMixin:GetLink(info.leaderName)..' ')
        or '',--%s邀请你加入

        info.name,--名称

        WoWTools_DataMixin.Icon[role] or '',

        info.numMembers and
            (WoWTools_DataMixin.onlyChinese and '队员' or PLAYERS_IN_GROUP)..'|cff00ff00 '..info.numMembers..'|r'
        or '',--队伍成员数量

        info.autoAccept and
            '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '自动邀请' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, INVITE))..'|r'
        or '',--对方是否开启, 自动邀请

        info.activityID and
            '|cffff00ff'..WoWTools_TextMixin:CN(C_LFGList.GetActivityFullName(info.activityID))..'|r'
        or '',--查找器,类型

        info.isWarMode and-- info.isWarMode ~= C_PvP.IsWarModeDesired() and
            '|A:pvptalents-warmode-swords:0:0|a|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '战争模式' or TALENT_FRAME_LABEL_WARMODE)..'|r'
        or ''
    )
end







--队伍查找器, 邀请信息
function WoWTools_LFDMixin:Init_LFGListInviteDialog_Info()--队伍查找器, 邀请信息
    LFGListInviteDialog:SetScript("OnShow", Settings)
end
