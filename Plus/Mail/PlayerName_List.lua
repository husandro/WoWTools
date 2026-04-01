--收件人，列表
local function Save()
    return WoWToolsSave['Plus_Mail']
end


local listButton











--我
local function Init_IsSelf(root)
    local new={}
    for guid, data in pairs(WoWTools_WoWDate) do
        if guid and guid~= WoWTools_DataMixin.Player.GUID and data.region==WoWTools_DataMixin.Player.Region then
            new[guid]=data
        end
    end

    for _, currencyID in pairs({
        3316,--/虚光灰岩
        2003,--巨龙群岛补给
        1767,--冥殇
        1560,--战争物资
        1220,--职业大厅资源
        823,--/埃匹希斯水晶
        777,--永恒铸币
        241,--冠军的徽记
    }) do
        local accountCurrencyData= select(2, WoWTools_CurrencyMixin:GetAccountInfo(currencyID))
        for _, data in pairs(accountCurrencyData or {}) do
            if not new[data.characterGUID] then
                new[data.characterGUID]=data
            end
        end
    end

    local tab= {}
    for guid, data in pairs(new) do
        local server= select(2, UnitNameFromGUID(guid)) or WoWTools_DataMixin.Player.Realm
        tab[server]= tab[server] or {}

        table.insert(tab[server], {
            guid= guid,
            faction= data.faction,
            classID= select(3, UnitClassFromGUID(guid)) or 0,
        })
    end

    new= {}
    for server, data in pairs(tab) do
        local d= {}
        for _, info in pairs(data) do
            table.insert(d, info)
        end
        table.insert(new, {server= server, data=data, count=#data})
    end
    table.sort(new, function(a, b)
        if a.server==WoWTools_DataMixin.Player.Realm then
            return true
        else
            return a.count> b.count
        end
    end)

    for _, acount in pairs(new) do
        root:CreateTitle(
            '|cffffffff'..acount.count..'|r '
            ..(acount.server==WoWTools_DataMixin.Player.Realm and '|A:recipetoast-icon-star:0:0|a' or '')
            ..acount.server,
            WoWTools_DataMixin.Player.Realms[acount.server] and GREEN_FONT_COLOR or NORMAL_FONT_COLOR
        )

        table.sort(acount.data, function(a, b) return a.classID< b.classID end)
        for index, info in pairs(acount.data) do
            local guid= info.guid

            local sub=root:CreateRadio(
                WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {reName=true, faction=info.faction}),--3reRealm=true, 
            function(data)
                local name= WoWTools_UnitMixin:GetFullName(nil, nil, data.guid)
                if name then
                    name= name:gsub('%-'..WoWTools_DataMixin.Player.Realm, '')
                end
                return name and name==SendMailNameEditBox:GetText()
            end, function(data)
                WoWTools_MailMixin:SetSendName(nil, data.guid)
                return MenuResponse.Refresh
            end, {guid=guid, rightText=(acount.server==WoWTools_DataMixin.Player.Realm and '|cnGREEN_FONT_COLOR:' or '|cff626262')..index})

            WoWTools_MenuMixin:SetRightText(sub)
        end
    end

    WoWTools_MenuMixin:SetScrollMode(root)
    tab=nil
    new=nil
end











local function Init_WoW(root)
    local sub
    local num=0
    for i=1 ,BNGetNumFriends() do
        local wow= C_BattleNet.GetFriendAccountInfo(i) or {}
        local wowInfo= wow.gameAccountInfo
        if wowInfo
            and wowInfo.playerGuid
            and wowInfo.wowProjectID==WOW_PROJECT_MAINLINE
            and (wowInfo.isOnline or Save().show['WoW'])
        then
            local name= WoWTools_UnitMixin:GetFullName(wowInfo.characterName, nil, wowInfo.playerGuid)
            if not WoWTools_MailMixin:GetRealmInfo(name) then
                sub=root:CreateButton(
                    WoWTools_UnitMixin:GetPlayerInfo(nil, wowInfo.playerGuid, nil, {reName=true, reRealm=true, level=wowInfo.characterLevel, faction=wowInfo.factionName})
                    ..(wowInfo.isOnline and '' or ('|cff626262'..(WoWTools_DataMixin.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)))
                    ..(wow.isFavorite and '|A:auctionhouse-icon-favorite:0:0|a' or ''),
                function(data)
                    WoWTools_MailMixin:SetSendName(nil, data.guid)
                    return MenuResponse.Open
                end, {guid=wowInfo.playerGuid, battleTag=wow.battleTag, note=wow.note})
                sub:SetTooltip(function(tooltip, description)
                    tooltip:AddLine(description.data.battleTag)
                    tooltip:AddLine(wow.note, nil,nil,nil, true)
                end)
                num=num+1
            end
        end
    end

    if num>0 then
        root:CreateDivider()
    end
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE,
    function()
        return Save().show['WoW']
    end, function()
        Save().show['WoW']= not Save().show['WoW'] and true or nil
        return MenuResponse.CloseAll
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '显示离线成员' or COMMUNITIES_MEMBER_LIST_SHOW_OFFLINE)
    end)

    WoWTools_MenuMixin:SetScrollMode(root)
end







local function Init_Friend(root)
    local sub
    local num=0
    for i=1 , C_FriendList.GetNumFriends() do
        local game= C_FriendList.GetFriendInfoByIndex(i) or {}
        local guid= game.guid
        if guid and not WoWTools_WoWDate[guid] and (game.connected or Save().show['FRIEND']) then
            local name= WoWTools_UnitMixin:GetFullName(nil, nil, guid)
            if not WoWTools_MailMixin:GetRealmInfo(name) then
                root:CreateButton(
                    WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {reName=true, reRealm=true, level=game.level, faction=game.faction})
                    ..(game.connected and '' or ('|cff626262'..(WoWTools_DataMixin.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE))),
                function(data)
                    WoWTools_MailMixin:SetSendName(nil, data.guid)
                    return MenuResponse.Open
                end, {guid=guid})
                num=num+1
            end
        end
    end

    if num>0 then
        root:CreateDivider()
    end
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE,
    function()
        return Save().show['FRIEND']
    end, function()
        Save().show['FRIEND']= not Save().show['FRIEND'] and true or nil
        return MenuResponse.CloseAll
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '显示离线成员' or COMMUNITIES_MEMBER_LIST_SHOW_OFFLINE)
    end)

    WoWTools_MenuMixin:SetScrollMode(root)
end









local function Init_Guild(root)
    local sub
    local num=0
    for index=1, GetNumGuildMembers() do
        local name, rankName, rankIndex, lv, _, _, _, _, isOnline, _, _, _, _, _, _, _, guid = GetGuildRosterInfo(index)
        --if name and guid and (isOnline or rankIndex<2 or (Save().show['GUILD'] and num<60)) and not WoWTools_WoWDate[guid] then
        if name and guid and (isOnline or rankIndex<2 or Save().show['GUILD']) and not WoWTools_WoWDate[guid] and not WoWTools_MailMixin:GetRealmInfo(name) then
            local text= WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {reName=true, reRealm=true, level=lv})--角色信息

            if not isOnline then
                text= text..'|cff626262'..(WoWTools_DataMixin.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)..'|r'
            end

            if rankIndex == 0 then
                text= "|TInterface\\GroupFrame\\UI-Group-LeaderIcon:0|t"..text
            elseif rankIndex == 1 then
                text= "|TInterface\\GroupFrame\\UI-Group-AssistantIcon:0|t"..text
            end

            text= rankName and text..' '..rankName..(rankIndex and ' '..rankIndex or '') or text

            root:CreateButton(
                text,
            function(data)
                WoWTools_MailMixin:SetSendName(nil, data.guid)
                return MenuResponse.Open
            end, {guid=guid})
            num=num+1
        end
    end

    if num>0 then
        root:CreateDivider()
    end
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE,
    function()
        return Save().show['GUILD']
    end, function()
        Save().show['GUILD']= not Save().show['GUILD'] and true or nil
        return MenuResponse.CloseAll
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '显示离线成员' or COMMUNITIES_MEMBER_LIST_SHOW_OFFLINE)
    end)

    WoWTools_MenuMixin:SetScrollMode(root)
end











local function Init_Club(root, clubID)
    local sub
    local num=0
    for _, memberID in pairs(C_Club.GetClubMembers(clubID) or {}) do
        local tab = C_Club.GetMemberInfo(clubID, memberID)
        if tab and tab.guid and tab.name and (tab.zone or tab.role<4 or (Save().show['CLUB'])) and not WoWTools_WoWDate[tab.guid] then
            if not WoWTools_MailMixin:GetRealmInfo(tab.name) then
                local faction= tab.faction==Enum.PvPFaction.Alliance and 'Alliance' or tab.faction==Enum.PvPFaction.Horde and 'Horde'
                local  text= WoWTools_UnitMixin:GetPlayerInfo(nil, tab.guid, nil, {reName=true, reRealm=true, faction=faction, level=tab.level})--角色信息
                if not tab.zone then
                    text= text..'|cff626262'..(WoWTools_DataMixin.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)..'|r'
                end
                if tab.role == Enum.ClubRoleIdentifier.Owner or tab.role == Enum.ClubRoleIdentifier.Leader then
                    text= text.."|TInterface\\GroupFrame\\UI-Group-LeaderIcon:0|t"
                elseif tab.role == Enum.ClubRoleIdentifier.Moderator then
                    text= text.."|TInterface\\GroupFrame\\UI-Group-AssistantIcon:0|t"
                end
                sub=root:CreateButton(
                    text,
                function(data)
                    WoWTools_MailMixin:SetSendName(nil, data.guid)
                    return MenuResponse.Open
                end, {guid=tab.guid, officerNote=tab.officerNote, memberNote=tab.memberNote})
                sub:SetTooltip(function(tooltip, description)
                    tooltip:AddLine(description.data.memberNote)
                    tooltip:AddLine(description.data.officerNote)

                end)
                num= num+1
            end
        end
    end

    if num>0 then
        root:CreateDivider()
    end
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE,
    function()
        return Save().show['CLUB']
    end, function()
        Save().show['CLUB']= not Save().show['CLUB'] and true or nil
        return MenuResponse.CloseAll
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '显示离线成员' or COMMUNITIES_MEMBER_LIST_SHOW_OFFLINE)
    end)

    WoWTools_MenuMixin:SetScrollMode(root)
end















local function Init_Menu(_, root)
    local sub
--我
    sub=root:CreateButton(
        '|A:auctionhouse-icon-favorite:0:0|a'..(WoWTools_DataMixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME),
    function()
        return MenuResponse
    end)
    Init_IsSelf(sub)

--战网
    sub=root:CreateButton(
        WoWTools_DataMixin.Icon.net2..(WoWTools_DataMixin.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET),
    function()
        return MenuResponse
    end)
    Init_WoW(sub)

--好友
    sub=root:CreateButton(
        '|A:groupfinder-icon-friend:0:0|a'..(WoWTools_DataMixin.onlyChinese and '好友' or FRIEND),
    function()
        return MenuResponse
    end)
    Init_Friend(sub)

--公会
    sub=root:CreateButton(
        '|A:communities-guildbanner-background:0:0|a'..(WoWTools_DataMixin.onlyChinese and '公会' or GUILD),
    function()
        return MenuResponse
    end)
    Init_Guild(sub)

--社区
    local clubs= C_Club.GetSubscribedClubs()
    if canaccesstable(clubs) and clubs then
        for _, tab in pairs(clubs) do
            if canaccessvalue(tab.clubId) and tab.clubId and tab.clubType ~= Enum.ClubType.Guild then
                sub=root:CreateButton(
                    (tab.avatarId==1
                        and '|A:plunderstorm-glues-queueselector-trio-selected:0:0|a'
                        or ('|T'..(tab.avatarId or 0)..':0|t')
                    )
                    ..(tab.shortName or tab.name),
                function()
                    return MenuResponse.Open
                end)
                Init_Club(sub, tab.clubId)
            end
        end
    end

--保存内容
    root:CreateDivider()
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '保存内容' or format(GUILDBANK_LOG_TITLE_FORMAT, INFO),--"%s 记录"
    function()
        return Save().logSendInfo
    end, function()
        Save().logSendInfo= not Save().logSendInfo and true or nil
        SendMailNameEditBox:save_log()
        SendMailSubjectEditBox:save_log()
        SendMailBodyEditBox:save_log()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '收件人：' or MAIL_TO_LABEL)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '主题：' or MAIL_SUBJECT_LABEL)
    end)

--打开选项
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_MailMixin.addName})

    WoWTools_MenuMixin:SetScrollMode(root)
end

















--收件人，列表
local function Init()
    if Save().hideSendNameList then
        return
    end




    --下拉，菜单
    listButton= CreateFrame('DropdownButton', 'WoWToolsSendMailPlayerNameListButton', SendMailNameEditBox, 'WoWToolsMenu3Template') --WoWTools_ButtonMixin:Cbtn(SendMailNameEditBox, {size=22, atlas='common-icon-rotateleft'})
    listButton:SetNormalAtlas('common-icon-rotateleft')

    listButton:SetPoint('LEFT', SendMailNameEditBox, 'RIGHT')
    listButton:SetupMenu(Init_Menu)
    --[[listButton:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, function(...)
            Init_Menu(...)
        end)
    end)]]



    --目标，名称
    listButton.btn= WoWTools_ButtonMixin:Cbtn(listButton, {size=22})
    listButton.btn:SetPoint('TOP', listButton, 'BOTTOM')
    listButton.btn:SetScript('OnClick', function(self)
          WoWTools_MailMixin:SetSendName(self.name)
    end)
    listButton.btn:SetScript('OnLeave', GameTooltip_Hide)
    listButton.btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_MailMixin.addName, WoWTools_DataMixin.onlyChinese and '名单列表' or WHO_LIST)
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '目标' or TARGET)
        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '收件人：' or MAIL_TO_LABEL,
            WoWTools_UnitMixin:GetPlayerInfo('target', nil, nil, {reName=true, reRealm=true})
        )
        if self.tooltip then
            GameTooltip:AddLine(self.tooltip)
        end
        GameTooltip:Show()
    end)

    function listButton:Settings()
        local name
        if WoWTools_UnitMixin:UnitGUID('target') and UnitIsPlayer('target') and WoWTools_UnitMixin:UnitIsUnit('player', 'target')==false then
            name= WoWTools_UnitMixin:GetFullName(nil, 'target', nil)--取得全名
            if name then
                local atlas, texture
                local index= GetRaidTargetIndex('target') or 0
                if index>0 and index<9 then
                    texture= 'Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index
                else
                    atlas= WoWTools_UnitMixin:GetRaceIcon('target', nil, nil, {reAtlas=true})
                end
                if texture then
                    self.btn:SetNormalTexture(texture)
                else
                    self.btn:SetNormalAtlas(atlas or 'Adventures-Target-Indicator')
                end
            end
        end

        self.btn.name=name
        self.btn.tooltip= WoWTools_MailMixin:GetRealmInfo(name)
        self.btn:SetShown(name and true or false)
        self.btn:SetAlpha(self.btn.tooltip and 0.5 or 1)
        self:SetShown(not Save().hideSendNameList)
    end

    listButton:SetScript('OnEvent',  listButton.Settings)
    listButton:SetScript('OnHide', listButton.UnregisterAllEvents)
    listButton:SetScript('OnShow', function(self)
        self:RegisterEvent('PLAYER_TARGET_CHANGED')--SendName，设置，发送成功，名字
        self:RegisterEvent('RAID_TARGET_UPDATE')
        self:Settings()
    end)
    listButton:SetScript('OnLeave', GameTooltip_Hide)
    listButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_MailMixin.addName, WoWTools_DataMixin.onlyChinese and '名单列表' or WHO_LIST)
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '显示好友列表' or SHOW_FRIENDS_LIST)
        GameTooltip:Show()
    end)




    Init=function()
        listButton:Settings()
    end
end















function WoWTools_MailMixin:Init_Send_Name_List()--收件人，列表
    Init()
end
