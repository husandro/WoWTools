local e= select(2, ...)

local function Save()
    return WoWTools_HyperLink.Save
end


--队伍查找器, 接受邀请
local function Set_LFGListInviteDialog_OnShow(self)
    if Save().setPlayerSound then
        e.PlaySound(SOUNDKIT.IG_PLAYER_INVITE)--播放, 声音
    end
    e.Ccool(self, nil, STATICPOPUP_TIMEOUT, nil, true, true, nil)--冷却条
    local status, _, _, role= select(2,C_LFGList.GetApplicationInfo(self.resultID))
    if status=="invited" then
        local info= C_LFGList.GetSearchResultInfo(self.resultID)
        if self.AcceptButton and self.AcceptButton:IsEnabled() and info then
            print(e.Icon.icon2..WoWTools_HyperLink.addName,
                info.leaderOverallDungeonScore and info.leaderOverallDungeonScore>0 and '|T4352494:0|t'..WoWTools_WeekMixin:KeystoneScorsoColor(info.leaderOverallDungeonScore) or '',--地下城史诗,分数
                info.leaderPvpRatingInfo and info.leaderPvpRatingInfo.rating and info.leaderPvpRatingInfo.rating>0 and '|A:pvptalents-warmode-swords:0:0|a|cnRED_FONT_COLOR:'..info.leaderPvpRatingInfo.rating..'|r' or '',--PVP 分数
                info.leaderName and (e.onlyChinese and '%s邀请你加入' or COMMUNITY_INVITATION_FRAME_INVITATION_TEXT):format(WoWTools_UnitMixin:GetLink(info.leaderName)..' ') or '',--	%s邀请你加入
                info.name,--名称
                e.Icon[role] or '',
                info.numMembers and (e.onlyChinese and '队员' or PLAYERS_IN_GROUP)..'|cff00ff00 '..info.numMembers..'|r' or '',--队伍成员数量
                info.autoAccept and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '自动邀请' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, INVITE))..'|r' or '',--对方是否开启, 自动邀请
                info.activityID and '|cffff00ff'..C_LFGList.GetActivityFullName(info.activityID)..'|r' or '',--查找器,类型
                info.isWarMode~=nil and info.isWarMode ~= C_PvP.IsWarModeDesired() and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '战争模式' or TALENT_FRAME_LABEL_WARMODE)..'|r' or ''
            )
        end
    end
end



