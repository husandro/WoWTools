if GameLimitedMode_IsActive() then
    return
end


--收件人，列表
local e= select(2, ...)
local function Save()
    return WoWTools_MailMixin.Save
end


local listButton











--我
local function Init_IsSelf(root)
    local new={}
    for guid, data in pairs(e.WoWDate) do
        if guid and guid~= e.Player.guid and data.region==e.Player.region then
            new[guid]=data
        end
    end

    local num=0
    for guid, info in pairs(new) do
        root:CreateButton(
            WoWTools_UnitMixin:GetPlayerInfo({guid=guid, reName=true, reRealm=true, faction=info.faction}),
        function(data)
            WoWTools_MailMixin:SetSendName(nil, data.guid)
            return MenuResponse.Open
        end, {guid=guid})
        num=num+1
    end

    local num2, new2= WoWTools_CurrencyMixin:GetAccountInfo(615)
    if num2==0 then
        num2, new2= WoWTools_CurrencyMixin:GetAccountInfo(515)
    end

    if num2>0 then
        if num>0 then
            root:CreateDivider()
        end
        for _, info in pairs(new2 or {}) do
            local guid=info.characterGUID
            if guid and not new[guid] then
                root:CreateButton(
                    WoWTools_UnitMixin:GetPlayerInfo({guid=guid, reName=true, reRealm=true, faction=info.faction}),
                function(data)
                    WoWTools_MailMixin:SetSendName(nil, data.guid)
                    return MenuResponse.Open
                end, {guid=guid})
                num=num+1
            end
        end
    end

    WoWTools_MenuMixin:SetGridMode(root, num)
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
                    WoWTools_UnitMixin:GetPlayerInfo({guid=wowInfo.playerGuid, reName=true, reRealm=true, level=wowInfo.characterLevel, faction=wowInfo.factionName})
                    ..(wowInfo.isOnline and '' or ('|cff9e9e9e'..(e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)))
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
        e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE,
    function()
        return Save().show['WoW']
    end, function()
        Save().show['WoW']= not Save().show['WoW'] and true or nil
        return MenuResponse.CloseAll
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '显示离线成员' or COMMUNITIES_MEMBER_LIST_SHOW_OFFLINE)
    end)

    WoWTools_MenuMixin:SetGridMode(root, num)
end







local function Init_Friend(root)
    local sub
    local num=0
    for i=1 , C_FriendList.GetNumFriends() do
        local game= C_FriendList.GetFriendInfoByIndex(i) or {}
        local guid= game.guid
        if guid and not e.WoWDate[guid] and (game.connected or Save().show['FRIEND']) then
            local name= WoWTools_UnitMixin:GetFullName(nil, nil, guid)
            if not WoWTools_MailMixin:GetRealmInfo(name) then
                root:CreateButton(
                    WoWTools_UnitMixin:GetPlayerInfo({guid=guid, reName=true, reRealm=true, level=game.level, faction=game.faction})
                    ..(game.connected and '' or ('|cff9e9e9e'..(e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE))),
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
        e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE,
    function()
        return Save().show['FRIEND']
    end, function()
        Save().show['FRIEND']= not Save().show['FRIEND'] and true or nil
        return MenuResponse.CloseAll
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '显示离线成员' or COMMUNITIES_MEMBER_LIST_SHOW_OFFLINE)
    end)

    WoWTools_MenuMixin:SetGridMode(root, num)
end









local function Init_Guild(root)
    local sub
    local num=0
    for index=1, GetNumGuildMembers() do
        local name, rankName, rankIndex, lv, _, zone, publicNote, officerNote, isOnline, status, _, _, _, _, _, _, guid = GetGuildRosterInfo(index)
        --if name and guid and (isOnline or rankIndex<2 or (Save().show['GUILD'] and num<60)) and not e.WoWDate[guid] then
        if name and guid and (isOnline or rankIndex<2 or Save().show['GUILD']) and not e.WoWDate[guid] and not WoWTools_MailMixin:GetRealmInfo(name) then
            local text= WoWTools_UnitMixin:GetPlayerInfo({guid=guid, reName=true, reRealm=true, level=lv})--角色信息

            if not isOnline then
                text= text..'|cff9e9e9e'..(e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)..'|r'
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
        e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE,
    function()
        return Save().show['GUILD']
    end, function()
        Save().show['GUILD']= not Save().show['GUILD'] and true or nil
        return MenuResponse.CloseAll
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '显示离线成员' or COMMUNITIES_MEMBER_LIST_SHOW_OFFLINE)
    end)

    WoWTools_MenuMixin:SetGridMode(root, num)
end











local function Init_Club(root, clubID)
    local sub
    local num=0
    for _, memberID in pairs(C_Club.GetClubMembers(clubID) or {}) do
        local tab = C_Club.GetMemberInfo(clubID, memberID)
        if tab and tab.guid and tab.name and (tab.zone or tab.role<4 or (Save().show['CLUB'])) and not e.WoWDate[tab.guid] then
            if not WoWTools_MailMixin:GetRealmInfo(tab.name) then
                local faction= tab.faction==Enum.PvPFaction.Alliance and 'Alliance' or tab.faction==Enum.PvPFaction.Horde and 'Horde'
                local  text= WoWTools_UnitMixin:GetPlayerInfo({guid=tab.guid, reName=true, reRealm=true, faction=faction, level=tab.level})--角色信息
                if not tab.zone then
                    text= text..'|cff9e9e9e'..(e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)..'|r'
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
        e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE,
    function()
        return Save().show['CLUB']
    end, function()
        Save().show['CLUB']= not Save().show['CLUB'] and true or nil
        return MenuResponse.CloseAll
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '显示离线成员' or COMMUNITIES_MEMBER_LIST_SHOW_OFFLINE)
    end)

    WoWTools_MenuMixin:SetGridMode(root, num)
end















local function Init_Menu(_, root)
    local sub
--我
    sub=root:CreateButton(
        '|A:auctionhouse-icon-favorite:0:0|a'..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME),
    function()
        return MenuResponse
    end)
    Init_IsSelf(sub)

--战网
    sub=root:CreateButton(
        e.Icon.net2..(e.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET),
    function()
        return MenuResponse
    end)
    Init_WoW(sub)

--好友
    sub=root:CreateButton(
        '|A:groupfinder-icon-friend:0:0|a'..(e.onlyChinese and '好友' or FRIEND),
    function()
        return MenuResponse
    end)
    Init_Friend(sub)

--公会
    sub=root:CreateButton(
        '|A:communities-guildbanner-background:0:0|a'..(e.onlyChinese and '公会' or GUILD),
    function()
        return MenuResponse
    end)
    Init_Guild(sub)

--社区
    for _, tab in pairs(C_Club.GetSubscribedClubs() or {}) do
        if tab.clubId and tab.clubType ~= Enum.ClubType.Guild then
            sub=root:CreateButton(
                '|T'..(tab.avatarId or 0)..':0|t'..(tab.shortName or tab.name),
            function()
                return MenuResponse.Open
            end)
            Init_Club(sub, tab.clubId)
        end
    end

--保存内容
    root:CreateDivider()
    sub=root:CreateCheckbox(
        e.onlyChinese and '保存内容' or format(GUILDBANK_LOG_TITLE_FORMAT, INFO),--"%s 记录"
    function()
        return Save().logSendInfo
    end, function()
        Save().logSendInfo= not Save().logSendInfo and true or nil
        SendMailNameEditBox:save_log()
        SendMailSubjectEditBox:save_log()
        SendMailBodyEditBox:save_log()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '收件人：' or MAIL_TO_LABEL)
        tooltip:AddLine(e.onlyChinese and '主题：' or MAIL_SUBJECT_LABEL)
    end)

--打开选项
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_MailMixin.addName})
--SetScrollMode
    WoWTools_MenuMixin:SetScrollMode(root)
end

















--收件人，列表
function Init()
    --下拉，菜单
    listButton= WoWTools_ButtonMixin:Cbtn(SendMailNameEditBox, {size=22, atlas='common-icon-rotateleft'})

    listButton:SetPoint('LEFT', SendMailNameEditBox, 'RIGHT')
    listButton:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, Init_Menu)
    end)



    --目标，名称
    listButton.btn= WoWTools_ButtonMixin:Cbtn(listButton, {size=22, icon='hide'})
    listButton.btn:SetPoint('TOP', listButton, 'BOTTOM')
    listButton.btn:SetScript('OnClick', function(self)
          WoWTools_MailMixin:SetSendName(self.name)
    end)
    listButton.btn:SetScript('OnLeave', GameTooltip_Hide)
    listButton.btn:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_MailMixin.addName, e.onlyChinese and '名单列表' or WHO_LIST)
        e.tips:AddLine(' ')
        e.tips:AddLine(e.onlyChinese and '目标' or TARGET)
        e.tips:AddDoubleLine(e.onlyChinese and '收件人：' or MAIL_TO_LABEL, WoWTools_UnitMixin:GetPlayerInfo({unit='target', reName=true, reRealm=true}))
        if self.tooltip then
            e.tips:AddLine(self.tooltip)
        end
        e.tips:Show()
    end)

    function listButton:Settings()
        local name
        if UnitExists('target') and UnitIsPlayer('target') and not UnitIsUnit('player', 'target') then
            name= WoWTools_UnitMixin:GetFullName(nil, 'target', nil)--取得全名
            if name then
                local atlas, texture
                local index= GetRaidTargetIndex('target') or 0
                if index>0 and index<9 then
                    texture= 'Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index
                else
                    atlas= WoWTools_UnitMixin:GetRaceIcon({unit= 'target', reAtlas=true})
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
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_MailMixin.addName, e.onlyChinese and '名单列表' or WHO_LIST)
        e.tips:AddLine(' ')
        e.tips:AddLine(e.onlyChinese and '显示好友列表' or SHOW_FRIENDS_LIST)
        e.tips:Show()
    end)


end















function WoWTools_MailMixin:Init_Send_Name_List()--收件人，列表
    if self.Save.hideSendNameList or listButton then
        if listButton then
            listButton:Settings()
        end
    else
        Init()
    end
end
