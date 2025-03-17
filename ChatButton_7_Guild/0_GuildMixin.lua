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

--加载，Club,数据 CommunitiesFrameMixin:RequestSubscribedClubFinderPostingInfo()
function WoWTools_GuildMixin:Load_Club(clubID)--加载，Club,数据
    if not C_ClubFinder.IsEnabled() then
		return
	end
    clubID= clubID or C_Club.GetGuildClubId()
    if clubID and not C_ClubFinder.RequestPostingInformationFromClubId(clubID) then
        C_ClubFinder.RequestSubscribedClubPostingIDs()
    end
end
--C_ClubFinder.RequestPostingInformationFromClubId(clubID) then--加载，Club，信息
--C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID)--Club，信息


--Club, 超链接
function WoWTools_GuildMixin:GetClubLink(clubID, clubGUID)
    if not clubID or not C_ClubFinder.IsEnabled() then
        return
    end
    do
        WoWTools_GuildMixin:Load_Club(clubID)--加载，Club,数据
    end

    local club= clubID and C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID)
            or (clubGUID and C_ClubFinder.GetRecruitingClubInfoFromFinderGUID(clubGUID))
    if club and club.clubFinderGUID then
        return GetClubFinderLink(club.clubFinderGUID, club.name)
    end
end

--Club,列出查找，过期时间
function WoWTools_GuildMixin:GetClubFindDay(clubID)
    if C_ClubFinder.IsEnabled() then
        clubID= clubID or C_Club.GetGuildClubId()
        local expirationTime = clubID and ClubFinderGetClubPostingExpirationTime(clubID)--CommunitiesFrameMixin:SetClubFinderPostingExpirationText(
        if expirationTime and expirationTime>0 then
            return expirationTime
        end
    end
end
--WoWTools_ChatMixin:Chat(WoWTools_GuildMixin:GetClubLink(data.clubID), nil, nil)

