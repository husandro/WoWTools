WoWTools_GuildMixin = {}

--是否是公会领袖或官员
function WoWTools_GuildMixin:CanInit_Invite()
    return CanGuildInvite()
        and (C_GuildInfo.IsGuildOfficer() or IsGuildLeader())
        and C_ClubFinder.IsEnabled()
end