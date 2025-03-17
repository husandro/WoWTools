local e= select(2, ...)
local function Save()
    return WoWTools_GuildMixin.Save
end



local function Get_Rank_Texture(rankIndex, reColor)
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






--帐号，公会，数据  e.WoWDate[e.Player.guid].Guild.data[4]= e.Player.realm
local function WoW_List(_, root)
    local sub, sub2

    sub= root:CreateButton('WoW', function() return MenuResponse.Open end)

    local name, realm, rankIndex, rankName, text
    for guid, info in pairs(e.WoWDate) do
        if info.Guild and info.Guild.link and info.Guild.clubID and guid~=e.Player.husandro then

            C_ClubFinder.RequestPostingInformationFromClubId(info.Guild.clubID)

            name= info.Guild.data[1]
            rankName= info.Guild.data[2]
            rankIndex= info.Guild.data[3]
            realm= info.Guild.data[4]

            sub2= sub:CreateButton(
                WoWTools_UnitMixin:GetPlayerInfo({guid=guid, reName=true, reRealm=false})
                ..' '
                ..Get_Rank_Texture(rankIndex, true)
                ..name
                ..(realm and realm~=e.Player.realm
                    and (e.Player.Realms[realm] and '|cnGREEN_FONT_COLOR:-|r' or '|cnRED_FONT_COLOR:-|r')..realm
                    or ''
                ),
            function(data)
                WoWTools_ChatMixin:Chat(data.link, nil, ChatEdit_GetActiveWindow() and true or false)
                return MenuResponse.Open
            end, {
                link= info.Guild.link,
                name= name,
                rankName= rankName,
                rankIndex= rankIndex,
                realm= realm,
                text= info.Guild.text,
                playerGuid= guid,
            })

            sub2:SetTooltip(function(tooltip, desc)
                tooltip:AddLine(desc.data.name)
                if desc.data.realm then
                    tooltip:AddLine(
                        (e.Player.Realms[desc.data.realm] and '|cnGREEN_FONT_COLOR:' or '|cffff00ff')
                        ..desc.data.realm
                    )
                end
                tooltip:AddLine(desc.data.text)
                tooltip:AddLine(' ')
                tooltip:AddLine( WoWTools_UnitMixin:GetPlayerInfo({guid=desc.data.playerGuid, reName=true, reRealm=true}))
                tooltip:AddLine(
                    Get_Rank_Texture(desc.data.rankIndex, true)
                    ..desc.data.rankName
                )

                tooltip:AddLine(' ')
                tooltip:AddDoubleLine('|cff00ccff'..(e.onlyChinese and '分享链接至聊天栏' or CLUB_FINDER_LINK_POST_IN_CHAT), e.Icon.left)
            end)
        end
    end

    WoWTools_MenuMixin:SetScrollMode(sub)
end
















--公会在线列表
local function Guild_Player_List(_, root)
    local total, online = GetNumGuildMembers()
    local showNotOnLine= Save().showNotOnLine

    if total<1 and (online<1 and not showNotOnLine) then
        return
    end

    local sub, text

    C_GuildInfo.GuildRoster()
    root:CreateDivider()

    local map=WoWTools_MapMixin:GetUnit('player')
    local maxLevel= GetMaxLevelForLatestExpansion()
    local name, rankName, rankIndex, level, zone, publicNote, officerNote, isOnline, status, guid

    for index=1, total, 1 do
        name, rankName, rankIndex, level, _, zone, publicNote, officerNote, isOnline, status, _, _, _, _, _, _, guid = GetGuildRosterInfo(index)
        if name and guid and (isOnline or showNotOnLine) and guid~=e.Player.guid then
            publicNote= publicNote~='' and publicNote or nil
            officerNote= officerNote~='' and officerNote or nil
            sub=root:CreateButton(
                (--状态
                    status==1 and format('|T%s:0|t', FRIENDS_TEXTURE_AFK)
                    or (status==2 and format('|T%s:0|t', FRIENDS_TEXTURE_DND))
                    or (not isOnline and format('|T%s:0|t', FRIENDS_TEXTURE_OFFLINE))
                    or (isOnline and showNotOnLine and format('|T%s:0|t', FRIENDS_TEXTURE_ONLINE))
                    or '  '
                )
                ..Get_Rank_Texture(rankIndex)--官员
                ..WoWTools_UnitMixin:GetPlayerInfo({guid=guid, name=name, reName=true, reRealm=true})--名称
                ..(level and level~=maxLevel and ' |cnGREEN_FONT_COLOR:'..level..'|r' or '')--等级
                ..(isOnline and zone and (zone==map and '|A:poi-islands-table:0:0|a' or e.cn(zone)) or '')--地区
                ..((publicNote or officerNote) and '|A:QuestLegendary:0:0|a' or ''),--提示有备注
                

            function(data)
                WoWTools_ChatMixin:Say(nil, data.name)
                return MenuResponse.Open
            end, {
                publicNote=publicNote,
                officerNote=officerNote,
                name=name,
                rankName=rankName,
                rankIndex=rankIndex,
                zone=zone,

            })
            sub:SetTooltip(function(tooltip, desc)
                tooltip:AddLine((e.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER)..' '..SLASH_WHISPER1..' '..desc.data.name)
                tooltip:AddLine(' ')
                tooltip:AddDoubleLine(
                    desc.data.zone,
                    Get_Rank_Texture(desc.data.rankIndex)..(desc.data.rankName or '').. (desc.data.rankIndex and ' '..desc.data.rankIndex)
                )

                if desc.data.publicNote then
                    tooltip:AddLine(' ')
                    tooltip:AddLine(desc.data.publicNote, nil,nil,nil, true)
                end
                
                if desc.data.officerNote then
                    tooltip:AddLine(' ')
                    tooltip:AddLine(desc.data.officerNote, nil,nil,nil,true)
                end
            end)
        end
    end
    WoWTools_MenuMixin:SetScrollMode(root)
end











--主菜单
local function Init_Menu(self, root)
    local sub, sub2
--无公会
    if not IsInGuild() then
        WoW_List(self, root)

        root:CreateButton(
            MicroButtonTooltipText('公会与社区', "TOGGLEGUILDTAB"),
        ToggleGuildFrame)
        return
    end

    local clubID= C_Club.GetGuildClubId()
    local clubInfo = clubID and C_Club.GetClubInfo(clubID) or {}--C_Club.GetClubInfo(clubID) C_ClubFinder.GetRecruitingClubInfoFromClubID() ClubFinderGetCurrentClubListingInfo(guildClubId)

--分享链接至聊天栏 ToggleGuildFrame()
    local guildName, guildRankName, guildRankIndex, realm= GetGuildInfo('player')

    sub= root:CreateButton(
        (CanGuildInvite() and '|cff00ccff' or '|cff828282')
        ..Get_Rank_Texture(guildRankIndex, false)
        ..(guildName or clubInfo.name or (e.onlyChinese and '公会成员' or LFG_LIST_GUILD_MEMBER))
        ..(guildRankName and guildRankIndex and guildRankIndex>1 and ' '.. guildRankName or ''),
    function(data)
        WoWTools_ChatMixin:Chat(
            data.clubID and WoWTools_GuildMixin:GetClubLink(data.clubID),
            nil,
            ChatEdit_GetActiveWindow() and true or false
        )

    end, {
        clubID= clubID,
        realm= realm,
        description=clubInfo.description,
    })
    sub:SetTooltip(function(tooltip, desc)
        tooltip:AddLine(desc.data.description, nil, nil, nil,true)
        tooltip:AddLine('|cff00ccff'..(e.onlyChinese and '分享链接至聊天栏' or CLUB_FINDER_LINK_POST_IN_CHAT))
        tooltip:AddLine('clubID |cffffffff'..(desc.data.clubID or ''))
        if not CanGuildInvite() then
            tooltip:AddLine(
                '|cff828282'
                ..(e.onlyChinese and '无法邀请成员' or format(ERROR_CLUB_ACTION_INVITE_MEMBER, ''))..'|r'
            )
        end
    end)

--公会信息
    sub2=sub:CreateCheckbox(e.onlyChinese and '公会信息' or GUILD_INFORMATION, function()
        return Save().guildInfo
    end, function()
        Save().guildInfo= not Save().guildInfo and true or nil
        if Save().guildInfo then
            e.WoWDate[e.Player.guid].Guild.text= nil
        end
        self:set_guild_info()--事件, 公会新成员, 队伍新成员
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine()
        tooltip:AddLine(e.WoWDate[e.Player.guid].Guild.text)
    end)

    sub2= sub:CreateCheckbox(
        e.onlyChinese and '显示离线成员' or COMMUNITIES_MEMBER_LIST_SHOW_OFFLINE,
    function()
        return Save().showNotOnLine
    end, function()
        Save().showNotOnLine= not Save().showNotOnLine and true or nil
        return MenuResponse.CloseAll
    end)

    WoW_List(self, root)

--弹劾
    if CanReplaceGuildMaster() then
        root:CreateDivider()
        sub=root:CreateButton(e.onlyChinese and '弹劾' or GUILD_IMPEACH_POPUP_CONFIRM, ToggleGuildFrame)
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(e.onlyChinese and '你所在公会的领袖已被标记为非活动状态。你现在可以争取公会领导权。是否要移除公会领袖？' or GUILD_IMPEACH_POPUP_TEXT, nil,nil,nil, true)
        end)
    end

--公会在线列表
    Guild_Player_List(_, root)
end




function WoWTools_GuildMixin:Init_Menu(btn)
    btn:SetupMenu(Init_Menu)
end