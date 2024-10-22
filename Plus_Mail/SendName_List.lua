--收件人，列表
local e= select(2, ...)
--[[local function Save()
    return WoWTools_MailMixin.Save
end]]












--#######
--设置菜单
--[[#######
local function Init_Menu(_, level, menuList)
    local info
    if menuList=='SELF' then
        local find
        for guid, _ in pairs(e.WoWDate) do
            if guid and guid~= e.Player.guid then
                local name= WoWTools_UnitMixin:GetFullName(nil, nil, guid)
                if not WoWTools_MailMixin:GetRealmInfo(name) then
                    e.LibDD:UIDropDownMenu_AddButton({
                        text= WoWTools_UnitMixin:GetPlayerInfo({guid=guid, reName=true, reRealm=true}),
                        icon= 'auctionhouse-icon-favorite',
                        tooltipOnButton=true,
                        tooltipTitle=name,
                        keepShownOnClick= true,
                        notCheckable= true,
                        arg1= name,
                        func=   WoWTools_MailMixin.SetSendName,
                    }, level)
                    find=true
                end
            end
        end
        if not find then
            e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
        end

    elseif menuList=='FRIEND'  then
        local find
        local maxLevel= GetMaxLevelForLatestExpansion()
        for i=1 , C_FriendList.GetNumFriends() do
            local game=C_FriendList.GetFriendInfoByIndex(i)
            if game and game.guid and (game.connected or Save().show['FRIEND']) and not e.WoWDate[game.guid] then
                local name= WoWTools_UnitMixin:GetFullName(nil, nil, game.guid)
                if not WoWTools_MailMixin:GetRealmInfo(name) then
                    local text= WoWTools_UnitMixin:GetPlayerInfo({guid=game.guid, reName=true, reRealm=true})--角色信息
                    text= (game.level and game.level~=maxLevel and game.level>0) and text .. ' |cff00ff00'..game.level..'|r' or text--等级
                    if game.area and game.connected then
                        text= text..' '..game.area
                    elseif not game.connected then
                        text= text..' '..(e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)
                    end

                    e.LibDD:UIDropDownMenu_AddButton({
                        text=text,
                        notCheckable= true,
                        keepShownOnClick= true,
                        tooltipOnButton=true,
                        tooltipTitle=name,
                        tooltipText=game.notes,
                        arg1= name,
                        func=   WoWTools_MailMixin.SetSendName,
                    }, level)
                    find=true
                end
            end
        end
        if not find then
            e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        e.LibDD:UIDropDownMenu_AddButton({
            text= e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE,
            icon= 'mechagon-projects',
            checked= Save().show['FRIEND'],
            tooltipOnButton= true,
            tooltipTitle= e.onlyChinese and '显示离线成员' or COMMUNITIES_MEMBER_LIST_SHOW_OFFLINE,
            tooltipText= e.GetEnabeleDisable(Save().show['FRIEND']),
            func= function()
                Save().show['FRIEND']= not Save().show['FRIEND'] and true or nil
            end
        }, level)

    elseif menuList=='WOW' then
        local find
        local maxLevel= GetMaxLevelForLatestExpansion()
        for i=1 ,BNGetNumFriends() do
            local wow= C_BattleNet.GetFriendAccountInfo(i);
            local wowInfo= wow and wow.gameAccountInfo
            if wowInfo
                and wowInfo.playerGuid
                and wowInfo.wowProjectID==1
                and wowInfo.isOnline
            then
                local name= WoWTools_UnitMixin:GetFullName(wowInfo.characterName, nil, wowInfo.playerGuid)
                if not WoWTools_MailMixin:GetRealmInfo(name) then
                    local text= WoWTools_UnitMixin:GetPlayerInfo({guid=wowInfo.playerGuid, reName=true, reRealm=true, factionName=wowInfo.factionName})--角色信息

                    if wowInfo.characterLevel and wowInfo.characterLevel~=maxLevel and wowInfo.characterLevel>0 then--等级
                        text=text ..' |cff00ff00'..wowInfo.characterLevel..'|r'
                    end
                    if not wowInfo.isOnline then
                        text= text..' '..(e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)
                    end

                    e.LibDD:UIDropDownMenu_AddButton({
                        text= text,
                        icon= e.WoWDate[wowInfo.playerGuid] and 'auctionhouse-icon-favorite',
                        keepShownOnClick= true,
                        notCheckable=true,
                        tooltipOnButton=true,
                        tooltipText= name,
                        tooltipTitle= wow and wow.note,
                        arg1= name,
                        func=   WoWTools_MailMixin.SetSendName,
                    }, level)
                end
                find=true
            end
        end
        if not find then
            e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
        end

    elseif menuList=='GUILD' then
        local num=0
        local maxLevel= GetMaxLevelForLatestExpansion()
        for index=1, GetNumGuildMembers() do
            local name, rankName, rankIndex, lv, _, zone, publicNote, officerNote, isOnline, status, _, _, _, _, _, _, guid = GetGuildRosterInfo(index)
            if name and guid and (isOnline or rankIndex<2 or (Save().show['GUILD'] and num<60)) and not e.WoWDate[guid] then

                local text= WoWTools_UnitMixin:GetPlayerInfo({guid=guid, reName=true, reRealm=true,})--角色信息

                text= (lv and lv~=maxLevel and lv>0) and text .. ' |cff00ff00'..lv..'|r' or text--等级
                if zone and isOnline then
                    text= text..' '..zone
                elseif not isOnline then
                    text= text..' '..(e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)
                end

                local icon
                if rankIndex == 0 then
                    icon= "Interface\\GroupFrame\\UI-Group-LeaderIcon"
                elseif rankIndex == 1 then
                    icon= "Interface\\GroupFrame\\UI-Group-AssistantIcon"
                end

                text= rankName and text..' '..rankName..(rankIndex and ' '..rankIndex or '') or text
                e.LibDD:UIDropDownMenu_AddButton({
                    text=text,
                    icon=icon,
                    keepShownOnClick= true,
                    notCheckable=true,
                    tooltipOnButton=true,
                    tooltipTitle=publicNote or '',
                    tooltipText=officerNote or '',
                    arg1= name,
                    func=   WoWTools_MailMixin.SetSendName,
                }, level)
                num= num+1
            end
        end
        if num==0 then
            e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        e.LibDD:UIDropDownMenu_AddButton({
            text= e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE,
            icon= 'mechagon-projects',
            checked= Save().show['GUILD'],
            tooltipOnButton= true,
            tooltipTitle= e.onlyChinese and '显示离线成员' or COMMUNITIES_MEMBER_LIST_SHOW_OFFLINE,
            tooltipText= e.GetEnabeleDisable(Save().show['GUILD']),
            func= function()
                Save().show['GUILD']= not Save().show['GUILD'] and true or nil
            end
        }, level)


    elseif menuList and type(menuList)=='number' then--社区
        local num=0
        local maxLevel= GetMaxLevelForLatestExpansion()
        local members= C_Club.GetClubMembers(menuList) or {}
        for index, memberID in pairs(members) do
            local tab = C_Club.GetMemberInfo(menuList, memberID) or {}
            if tab.guid and tab.name and (tab.zone or tab.role<4 or (Save().show[menuList] and num<60)) and not e.WoWDate[tab.guid] then
                if not WoWTools_MailMixin:GetRealmInfo(tab.name) then
                    local faction= tab.faction==Enum.PvPFaction.Alliance and 'Alliance' or tab.faction==Enum.PvPFaction.Horde and 'Horde'
                    local  text= WoWTools_UnitMixin:GetPlayerInfo({guid=tab.guid,  reName=true, reRealm=true, factionName=faction})--角色信息

                    text= (tab.level and tab.level~=maxLevel and tab.level>0) and text .. ' |cff00ff00'..tab.level..'|r' or text--等级
                    if tab.zone then
                        text= text..' '..tab.zone
                    else
                        text= text..' '..(e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)
                    end

                    local icon
                    if tab.role == Enum.ClubRoleIdentifier.Owner or tab.role == Enum.ClubRoleIdentifier.Leader then
                        icon= "Interface\\GroupFrame\\UI-Group-LeaderIcon"
                    elseif tab.role == Enum.ClubRoleIdentifier.Moderator then
                        icon= "Interface\\GroupFrame\\UI-Group-AssistantIcon"
                    end

                    e.LibDD:UIDropDownMenu_AddButton({
                        text= index..(index<10 and ')  ' or ') ')..text.. (tab.zone and format('|A:%s:0:0|a', e.Icon.select) or ''),
                        icon= icon,
                        keepShownOnClick= true,
                        notCheckable=true,
                        tooltipOnButton=true,
                        tooltipTitle=tab.memberNote or '',
                        tooltipText=tab.officerNote,
                        arg1= tab.name,
                        func=   WoWTools_MailMixin.SetSendName,
                    }, level)
                    num= num+1
                end
            end
        end
        if num==0 then
            e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE,
            icon= 'mechagon-projects',
            checked= Save().show[menuList],
            tooltipOnButton= true,
            tooltipTitle= e.onlyChinese and '显示离线成员' or COMMUNITIES_MEMBER_LIST_SHOW_OFFLINE,
            tooltipText= e.GetEnabeleDisable(Save().show[menuList]),
            func= function()
                Save().show[menuList]= not Save().show[menuList] and true or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    end

    if menuList then
        return
    end

    info={
        text= '|A:auctionhouse-icon-favorite:0:0|a'..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME),
        hasArrow= true,
        notCheckable=true,
        keepShownOnClick= true,
        menuList= 'SELF',
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= e.Icon.net2..(e.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET),
        hasArrow= true,
        notCheckable=true,
        keepShownOnClick= true,
        menuList= 'WOW',
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= '|A:groupfinder-icon-friend:0:0|a'..(e.onlyChinese and '好友' or FRIEND),
        hasArrow= true,
        notCheckable=true,
        keepShownOnClick= true,
        menuList= 'FRIEND',
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)


    info={
        text= '|A:communities-guildbanner-background:0:0|a'..(e.onlyChinese and '公会' or GUILD),
        disabled= not IsInGuild(),
        hasArrow= true,
        notCheckable=true,
        keepShownOnClick= true,
        menuList= 'GUILD',
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)




    local clubs= C_Club.GetSubscribedClubs() or {}--社区
    if #clubs>0 then
        e.LibDD:UIDropDownMenu_AddSeparator(level)
    end
    for _, tab in pairs(clubs) do
        if tab.clubType ~= Enum.ClubType.Guild then
            info={
                text= (tab.avatarId and '|T'..tab.avatarId..':0|t' or '')..(tab.shortName or tab.name),
                hasArrow= true,
                notCheckable=true,
                keepShownOnClick= true,
                menuList= tab.clubId,
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
    end


    e.LibDD:UIDropDownMenu_AddSeparator(level)
    e.LibDD:UIDropDownMenu_AddButton({
        text= e.onlyChinese and '保存内容' or format(GUILDBANK_LOG_TITLE_FORMAT, INFO),--"%s 记录",
        keepShownOnClick=true,
        checked= Save().logSendInfo,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '收件人：' or MAIL_TO_LABEL,
        tooltipText= e.onlyChinese and '主题：' or MAIL_SUBJECT_LABEL,
        func=function()
            Save().logSendInfo= not Save().logSendInfo and true or nil
            SendMailNameEditBox:save_log()
            SendMailSubjectEditBox:save_log()
            SendMailBodyEditBox:save_log()
        end
    }, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= WoWTools_MailMixin.addName,
        notCheckable= true,
        isTitle=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end]]




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
        root:CreateDivider()
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
    local num=0
    for i=1 ,BNGetNumFriends() do
        local wow= C_BattleNet.GetFriendAccountInfo(i) or {}
        local wowInfo= wow.gameAccountInfo
        if wowInfo
            and wowInfo.playerGuid
            and wowInfo.wowProjectID==WOW_PROJECT_MAINLINE
            --and wowInfo.isOnline
        then
            local name= WoWTools_UnitMixin:GetFullName(wowInfo.characterName, nil, wowInfo.playerGuid)
            if not WoWTools_MailMixin:GetRealmInfo(name) then
                root:CreateButton(
                    WoWTools_UnitMixin:GetPlayerInfo({guid=wowInfo.playerGuid, reName=true, reRealm=true, level=wowInfo.characterLevel, faction=wowInfo.factionName})
                    ..(wowInfo.isOnline and '' or ('|cff9e9e9e'..((e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE))))
                    ..(wow.isFavorite and '|A:auctionhouse-icon-favorite:0:0|a' or ''),
                function(data)
                    WoWTools_MailMixin:SetSendName(nil, data.guid)
                    return MenuResponse.Open
                end, {guid=wowInfo.playerGuid})
                num=num+1
            end
        end
    end
    WoWTools_MenuMixin:SetGridMode(root, num)
end







local function Init_Friend(root)
    local num=0
    for i=1 , C_FriendList.GetNumFriends() do
        local game= C_FriendList.GetFriendInfoByIndex(i) or {}
        local guid= game.guid
        if guid and not e.WoWDate[guid] then
            local name= WoWTools_UnitMixin:GetFullName(nil, nil, guid)
            if not WoWTools_MailMixin:GetRealmInfo(name) then
                root:CreateButton(
                    WoWTools_UnitMixin:GetPlayerInfo({guid=guid, reName=true, reRealm=true, level=game.level, faction=game.faction})
                    ..(game.connected and '' or ('|cff9e9e9e'..((e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)))),
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









local function Init_Guild(root)
    local num=0

        for index=1, GetNumGuildMembers() do
            local name, rankName, rankIndex, lv, _, zone, publicNote, officerNote, isOnline, status, _, _, _, _, _, _, guid = GetGuildRosterInfo(index)
            --if name and guid and (isOnline or rankIndex<2 or (Save().show['GUILD'] and num<60)) and not e.WoWDate[guid] then
            if name and guid and isOnline and not e.WoWDate[guid] and not WoWTools_MailMixin:GetRealmInfo(name) then
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
                num= num+1
            end
        end
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

end

















--收件人，列表
function Init()
    --下拉，菜单
    local listButton= WoWTools_ButtonMixin:Cbtn(SendMailNameEditBox, {size=22, atlas='common-icon-rotateleft'})

    listButton:SetPoint('LEFT', SendMailNameEditBox, 'RIGHT')
    listButton:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, Init_Menu)
    end)



    --目标，名称
    listButton.btn= WoWTools_ButtonMixin:Cbtn(SendMailNameEditBox, {size=22, icon='hide'})
    listButton.btn:SetPoint('LEFT', listButton, 'RIGHT', 2, 0)
    listButton.btn:SetScript('OnClick', function(self)
          WoWTools_MailMixin:SetSendName(self.name)
    end)
    listButton.btn:SetScript('OnLeave', GameTooltip_Hide)
    listButton.btn:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_MailMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddLine(e.onlyChinese and '目标' or TARGET)
        e.tips:AddDoubleLine(e.onlyChinese and '收件人：' or MAIL_TO_LABEL, WoWTools_UnitMixin:GetPlayerInfo({unit='target', reName=true, reRealm=true}))
        if self.tooltip then
            e.tips:AddLine(self.tooltip)
        end
        e.tips:Show()
    end)

    function listButton:settings()
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
    end

    listButton:SetScript('OnEvent',  listButton.settings)
    listButton:SetScript('OnHide', listButton.UnregisterAllEvents)
    listButton:SetScript('OnShow', function(self)
        self:RegisterEvent('PLAYER_TARGET_CHANGED')--SendName，设置，发送成功，名字
        self:RegisterEvent('RAID_TARGET_UPDATE')
        self:settings()
    end)
    listButton:SetScript('OnLeave', GameTooltip_Hide)
    listButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_MailMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddLine(e.onlyChinese and '显示好友列表' or SHOW_FRIENDS_LIST)
        e.tips:Show()
    end)

--清除，收件人
    local clearButton= WoWTools_ButtonMixin:Cbtn(SendMailNameEditBox, {size=22, atlas='bags-button-autosort-up'})
    clearButton:SetPoint('RIGHT', SendMailNameEditBox, 'LEFT', -4, 0)
    clearButton:SetScript('OnLeave', GameTooltip_Hide)
    clearButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_MailMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, e.onlyChinese and '收件人' or MAIL_TO_LABEL)
        e.tips:Show()
    end)
    clearButton:SetScript('OnClick', function(self)
        self:GetParent():SetText('')
        WoWTools_MailMixin:RefreshAll()
    end)
end















function WoWTools_MailMixin:Init_Send_Name_List()--收件人，列表
    Init()
end
