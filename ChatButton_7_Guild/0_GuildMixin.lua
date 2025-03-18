local e= select(2, ...)
--CommunitiesUtil.lua
WoWTools_GuildMixin = {}

--图标会长或官员
function WoWTools_GuildMixin:Get_Rank_Texture(rankIndex, reColor)
    local icon
    if rankIndex ==0 then
        icon= '|TInterface\\GroupFrame\\UI-Group-LeaderIcon:0|t'
    elseif rankIndex == 1 then
        icon= '|TInterface\\GroupFrame\\UI-Group-AssistantIcon:0|t'
    end
    if reColor and icon then
        icon= icon..'|cffff00ff'
    end
    return icon or ''
end

--会长或官员
function WoWTools_GuildMixin:IsLeaderOrOfficer()
    return C_GuildInfo.IsGuildOfficer() or IsGuildLeader()
end




--加载，Club,数据 CommunitiesFrameMixin:RequestSubscribedClubFinderPostingInfo()
function WoWTools_GuildMixin:Load_Club(clubID)--加载，Club,数据
    clubID= clubID or C_Club.GetGuildClubId()
    if clubID and not C_ClubFinder.RequestPostingInformationFromClubId(clubID) then
        C_ClubFinder.RequestSubscribedClubPostingIDs()
    end
end

--Club, 超链接
function WoWTools_GuildMixin:GetClubLink(clubID, clubGUID)
    clubID= clubID or C_Club.GetGuildClubId()
    local club= clubID and C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID)
                or (clubGUID and C_ClubFinder.GetRecruitingClubInfoFromFinderGUID(clubGUID))

    clubGUID= club and club.clubFinderGUID or clubGUID


    if clubGUID then
        return GetClubFinderLink(clubGUID, club and club.name or COMMUNITIES_INVITE_MEMBERS)--不查用中文
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

--在线成员
--CommunitiesUtil.GetOnlineMembers
function WoWTools_GuildMixin:GetNumOnline(clubID)
    local online, all, onlineTab= 0, 0, {}
    local memberInfo
    clubID= clubID or C_Club.GetGuildClubId()

    local members= clubID and C_Club.GetClubMembers(clubID) or {}
    for _, memberID in ipairs(members) do
        memberInfo = C_Club.GetMemberInfo(clubID, memberID)
        if memberInfo and memberInfo.name and not memberInfo.isSelf then

            if
                memberInfo.presence == Enum.ClubMemberPresence.Online--在线
                or memberInfo.presence == Enum.ClubMemberPresence.Away--离开
                or memberInfo.presence == Enum.ClubMemberPresence.Busy--忙碌
            then
                online= online+1
                table.insert(onlineTab, memberInfo)
            end
            all= all+1
        end
    end
    return online, all, onlineTab
end



--公会，社区，信息
function WoWTools_GuildMixin:OnEnter_GuildInfo()

    if IsInGuild() then
        local all, online, app = GetNumGuildMembers()
        local guildName, guildRankName, guildRankIndex, realm = GetGuildInfo('player')
--在线成员：
        GameTooltip:AddLine(
            guildName
            ..(realm and realm~=e.Player.realm and '-'..realm or ' ')
            ..' ('..all..')',
            nil, nil, nil, true
        )
--会长或官员
        GameTooltip:AddLine(
            self:Get_Rank_Texture(guildRankIndex, false)
            ..guildRankName
            ..(guildRankIndex>1 and ' '..guildRankIndex or '')
            , nil, nil, nil, true
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


    local icon, name, col, applicantList, num, info, members, online, all
    local guildClubId= C_Club.GetGuildClubId()
    local numApplicant= 0

    for _, tab in pairs(clubs) do

        online, all= self:GetNumOnline(tab.clubId)--在线成员

        icon=(tab.clubId==guildClubId) and '|A:auctionhouse-icon-favorite:0:0|a'

            or (tab.avatarId==1
                and '|A:plunderstorm-glues-queueselector-trio-selected:0:0|a'
                or ('|T'..(tab.avatarId or 0)..':0|t')
            )


        col= online>0 and '|cnGREEN_FONT_COLOR:' or '|cff9e9e9e'

        name= col..tab.name..'|r'

--未读信息
        if CommunitiesUtil.DoesCommunityHaveUnreadMessages(tab.clubId) then
            name= name..'|A:communities-icon-notification:0:0|a'
        end

--申请者
        applicantList= self:GetApplicantList(tab.clubId)
        num = applicantList and #applicantList
        if num then
            name= name..'|A:communities-icon-invitemail:0:0|a|cnGREEN_FONT_COLOR:'..num..'|r'
            numApplicant= numApplicant + num
        end

        GameTooltip:AddDoubleLine(icon..name, col..online..'/'..all..icon)
    end


    local hasMsg= CommunitiesUtil.DoesAnyCommunityHaveUnreadMessages()--未读信息
    local hasPlayer= numApplicant>0
    if hasMsg or hasPlayer then
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            hasPlayer and
                '|cnGREEN_FONT_COLOR:'
                ..(e.onlyChinese and '申请人' or CLUB_FINDER_APPLICANTS)
                ..'|r|A:communities-icon-invitemail:0:0|a|cnGREEN_FONT_COLOR:'..numApplicant
            or ' ',

            hasMsg and
                '|cnGREEN_FONT_COLOR:'
                ..(e.onlyChinese and '未读信息' or COMMUNITIES_CHAT_FRAME_UNREAD_MESSAGES_NOTIFICATION)
                ..'|A:communities-icon-notification:0:0|a'
        )
    end
end








function WoWTools_GuildMixin:GetApplicantList(clubID)
    if C_ClubFinder.IsEnabled() then
        clubID= clubID or C_Club.GetGuildClubId()
        if clubID then
            local data = C_Club.GetClubPrivileges(clubID)
            if data and data.canGetInvitation then
                data= C_ClubFinder.ReturnClubApplicantList(clubID)
                if not data or #data==0 then
                    return
                end
                return data
            end
        end
    end
end
