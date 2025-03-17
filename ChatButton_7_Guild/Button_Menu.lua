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
local function WoW_List(self, root)
    if not e.Player.husandro then
        return 
    end
    local sub, sub2


    sub= root:CreateButton('WoW', function()return MenuResponse.Open end)

    for guid, info in pairs(e.WoWDate) do
        if info.Guild and info.Guild.link and info.Guild.clubID and guid~=e.Player.husandro then
            C_ClubFinder.RequestPostingInformationFromClubId(info.Guild.clubID)
            sub2= sub:CreateButton(
                WoWTools_UnitMixin:GetPlayerInfo({guid=guid, reName=true, reRealm=false}),
            function(data)
                WoWTools_ChatMixin:Chat(data.link, nil, nil)
                return MenuResponse.Open
            end, {
                link= info.Guild.link,
                name= info.Guild.data[1],
                rankName= info.Guild.data[2],
                rankIndex= info.Guild.data[3],
                realm= info.Guild.data[4],
                text= info.Guild.text,
                playerGuid= guid,
            })
        -- local guildName, guildRankName, guildRankIndex, realm= GetGuildInfo('player')
            sub2:AddInitializer(function(btn, desc)
                local name= desc.data.name
                if not name then
                    return
                end
                local fontString2 = btn:AttachFontString()
                fontString2:SetHeight(20);
                fontString2:SetPoint("RIGHT")--, btn.fontString, 'RIGHT', 5, 0)
                --fontString2:SetPoint("RIGHT")
                fontString2:SetJustifyH("RIGHT")

                local realm= desc.data.realm
                if realm and realm~=desc.data.playerRealm then
                    realm= (e.Player.Realms[realm] and '|cnGREEN_FONT_COLOR:-|r' or '|cnRED_FONT_COLOR:-|r')..realm
                else
                    realm= ''
                end

                fontString2:SetText(
                    --(desc.data.link and e.Icon.left or '')
                    Get_Rank_Texture(desc.data.rankIndex, true)
                    ..name
                    ..realm
                )

                local width = 20 + btn.fontString:GetUnboundedStringWidth() + fontString2:GetUnboundedStringWidth()
                return width,  20
            end)
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























--主菜单
local function Init_Menu(self, root)
    local sub, sub2, text
--无公会
    if not IsInGuild() then
        WoW_List(self, root)

        root:CreateButton(
            MicroButtonTooltipText('公会与社区', "TOGGLEGUILDTAB"),
        ToggleGuildFrame)
        return
    end

    local clubID= C_Club.GetGuildClubId()
    local clubInfo = clubID and C_Club.GetClubInfo(clubID)--C_Club.GetClubInfo(clubID) C_ClubFinder.GetRecruitingClubInfoFromClubID() ClubFinderGetCurrentClubListingInfo(guildClubId)

--分享链接至聊天栏
    sub= root:CreateButton(
        (CanGuildInvite() and '|cff00ccff' or '|cff828282')
        ..(clubInfo.name
            or (e.onlyChinese and '公会成员' or LFG_LIST_GUILD_MEMBER)),
    function(data)
        if not data.clubID then
            return
        end
        WoWTools_ChatMixin:Chat(WoWTools_GuildMixin:GetClubLink(data.clubID), nil, nil)
         --ToggleGuildFrame()

    end, {clubID= clubID})
    sub:SetTooltip(function(tooltip, desc)
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
    local total, online = GetNumGuildMembers()
    local showNotOnLine= Save().showNotOnLine

    if total>1 and (online>1 or showNotOnLine) then
        root:CreateDivider()

        local map=WoWTools_MapMixin:GetUnit('paleyr')
        local maxLevel= GetMaxLevelForLatestExpansion()
        

        for index=1, total, 1 do
            local name, _, rankIndex, lv, _, zone, publicNote, officerNote, isOnline, status, _, _, _, _, _, _, guid = GetGuildRosterInfo(index)
            if name and guid and (isOnline or showNotOnLine) and guid~=e.Player.guid then

                text= status==1 and format('|T%s:0|t', FRIENDS_TEXTURE_AFK)
                    or (status==2 and format('|T%s:0|t', FRIENDS_TEXTURE_DND))
                    or (not isOnline and format('|T%s:0|t', FRIENDS_TEXTURE_OFFLINE))
                    or (isOnline and showNotOnLine and format('|T%s:0|t', FRIENDS_TEXTURE_ONLINE))
                    or '  '


                text=text
                    ..Get_Rank_Texture(rankIndex)
                    ..WoWTools_UnitMixin:GetPlayerInfo({guid=guid, name=name, reName=true, reRealm=true})
                text=(lv and lv~=maxLevel) and text..' |cnGREEN_FONT_COLOR:'..lv..'|r' or text--等级
                if zone and zone==map then--地区
                    text= text..'|A:poi-islands-table:0:0|a'
                end
               -- text= rankName and text..' '..rankName..(rankIndex or '') or text


                sub=root:CreateButton(text, function(data)
                    WoWTools_ChatMixin:Say(nil, data.name)
                    return MenuResponse.Open
                end, {publicNote=publicNote, officerNote=officerNote, name=name, zone=zone})
                sub:SetTooltip(function(tooltip, description)
                    tooltip:AddLine((e.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER)..' '..SLASH_WHISPER1..' '..description.data.name)
                    tooltip:AddLine(' ')
                    tooltip:AddLine(description.data.zone)
                    tooltip:AddLine(description.data.publicNote)
                    tooltip:AddLine(description.data.officerNote)
                end)
            end
        end
        WoWTools_MenuMixin:SetScrollMode(root)
    end
end




function WoWTools_GuildMixin:Init_Menu(btn)
    btn:SetupMenu(Init_Menu)
end