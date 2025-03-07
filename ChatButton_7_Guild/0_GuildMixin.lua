WoWTools_GuildMixin = {}

--会长或官员
function WoWTools_GuildMixin:IsLeaderOrOfficer()
    return C_GuildInfo.IsGuildOfficer() or IsGuildLeader()
end


--是否是公会领袖或官员
function WoWTools_GuildMixin:CanInit_Invite()
    return CanGuildInvite()
        and C_ClubFinder.IsEnabled()
        and (self:IsLeaderOrOfficer())
end