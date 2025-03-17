local e= select(2, ...)
--CommunitiesUtil.lua
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

function WoWTools_GuildMixin:GetGuildClubID(clubID)
    if C_ClubFinder.IsEnabled() then
        clubID= clubID or C_Club.GetGuildClubId()
        WoWTools_Mixin:Load({id=clubID, type='club'})
        return clubID
    end
end


--加载，Club,数据 CommunitiesFrameMixin:RequestSubscribedClubFinderPostingInfo()
function WoWTools_GuildMixin:Load_Club(clubID)--加载，Club,数据
    clubID= self:GetGuildClubID(clubID)
    if clubID and not C_ClubFinder.RequestPostingInformationFromClubId(clubID) then
        C_ClubFinder.RequestSubscribedClubPostingIDs()
    end
end
--C_ClubFinder.RequestPostingInformationFromClubId(clubID) then--加载，Club，信息
--C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID)--Club，信息


--Club, 超链接
function WoWTools_GuildMixin:GetClubLink(clubID, clubGUID)
    clubID= self:GetGuildClubID(clubID)
    local club= clubID and C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID)
            or (clubGUID and C_ClubFinder.GetRecruitingClubInfoFromFinderGUID(clubGUID))
    if club and club.clubFinderGUID then
        return GetClubFinderLink(club.clubFinderGUID, club.name)
    end
end

--Club,列出查找，过期时间
function WoWTools_GuildMixin:GetClubFindDay(clubID)
    clubID= self:GetGuildClubID(clubID)
    local expirationTime = clubID and ClubFinderGetClubPostingExpirationTime(clubID)--CommunitiesFrameMixin:SetClubFinderPostingExpirationText(
    if expirationTime and expirationTime>0 then
        return expirationTime
    end
end
--WoWTools_ChatMixin:Chat(WoWTools_GuildMixin:GetClubLink(data.clubID), nil, nil)







--公会，社区，信息
function WoWTools_GuildMixin:OnEnter_GuildInfo()

    if IsInGuild() then
        local all, online, app = GetNumGuildMembers()
        local guildName, guildRankName, _, realm = GetGuildInfo('player')
--在线成员：
        GameTooltip:AddDoubleLine(
            guildName
            ..(realm and realm~=e.Player.realm and '-'..realm or ' ')
            ..' ('..all..')',
            guildRankName
        )

--今天信息
        local day= GetGuildRosterMOTD()
        if day and day~='' then
            GameTooltip:AddLine('|cffff00ff'..day..'|r', nil,nil, nil, true)
        end

        local col= online>1 and '|cnGREEN_FONT_COLOR:' or '|cff9e9e9e'

        GameTooltip:AddDoubleLine(
            col..(e.onlyChinese and '在线成员：' or GUILD_MEMBERS_ONLINE_COLON),
            col..'|A:UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon:0:0|a'..(online-1)..'|r'
            ..(app and app>1 and '/|A:UI-ChatIcon-App:0:0|a'..(app-1) or '')
        )
    end

    local clubs= C_Club.GetSubscribedClubs()
    if not clubs then
        return
    end
    GameTooltip:AddLine(' ')

    local all=0
    local icon, name, col, applicantList, num
    local guildClubId= C_Club.GetGuildClubId()
    local numApplicant= 0

    for _, tab in pairs(clubs) do
        local members= C_Club.GetClubMembers(tab.clubId) or {}
        local online= 0
        for _, memberID in pairs(members) do--CommunitiesUtil.GetOnlineMembers
            local info = C_Club.GetMemberInfo(tab.clubId, memberID) or {}
            if not info.isSelf and info.presence~=Enum.ClubMemberPresence.Offline and info.presence~=Enum.ClubMemberPresence.Unknown then--CommunitiesUtil.GetOnlineMembers()
                online= online+1
                all= all+1
            end
        end

        icon=(tab.clubId==guildClubId) and '|A:auctionhouse-icon-favorite:0:0|a'

            or (tab.avatarId==1
                and '|A:plunderstorm-glues-queueselector-trio-selected:0:0|a'
                or ('|T'..(tab.avatarId or 0)..':0|t')
            )


        col= online>0 and '|cnGREEN_FONT_COLOR:' or '|cff9e9e9e'

        name= col..tab.name..'|r'

--未读信息
        if CommunitiesUtil.DoesCommunityHaveUnreadMessages(tab.clubId) then
            name= name..'|A:communities-icon-invitemail:0:0|a'
        end

--申请者
        applicantList=  self:GetApplicantList(tab.clubId)
        num = applicantList and #applicantList
        if num then
            name= name..'|A:communities-icon-notification:0:0|a|cnGREEN_FONT_COLOR:'..num..'|r'
            numApplicant= numApplicant + num
        end

        GameTooltip:AddDoubleLine(icon..name, col..online..icon)
    end


    local hasMsg= CommunitiesUtil.DoesAnyCommunityHaveUnreadMessages()--未读信息
    local hasPlayer= numApplicant>0
    if hasMsg or hasPlayer then
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            hasPlayer and
                '|cnGREEN_FONT_COLOR:'
                ..(e.onlyChinese and '申请人' or CLUB_FINDER_APPLICANTS)
                ..'|r|A:communities-icon-notification:0:0|a|cnGREEN_FONT_COLOR:'..numApplicant
            or ' ',

            hasMsg and
                '|cnGREEN_FONT_COLOR:'
                ..(e.onlyChinese and '未读信息' or COMMUNITIES_CHAT_FRAME_UNREAD_MESSAGES_NOTIFICATION)
                ..'|A:communities-icon-invitemail:0:0|a'
        )
    end
end

--CreateCommunitiesIconNotificationMarkup(name)











function WoWTools_GuildMixin:GetApplicantList(clubID)
    clubID= self:GetGuildClubID(clubID)
    local data= clubID and C_ClubFinder.ReturnClubApplicantList(clubID)
    if not data or #data==0 then
        return
    end
    return data
end
