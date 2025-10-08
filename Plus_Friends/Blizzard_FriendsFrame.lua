--好友列表, 模块
local function Save()
    return WoWToolsSave['Plus_FriendsList']
end
local OptionTexture={
    ['Availabel'] = FRIENDS_TEXTURE_ONLINE,
    ['DND']= FRIENDS_TEXTURE_DND,
    ['Away'] =FRIENDS_TEXTURE_AFK,
}
local OptionText--= (WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS).."|T%s:0:|t %s"
local RegionNames
local FriendsButton





















local function Init_Friends_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub, name
    if not BNConnected() then
        root:CreateTitle('|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '断开战网' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SOCIAL_TWITTER_DISCONNECT, COMMUNITY_COMMAND_BATTLENET))..'|r')
        root:CreateDivider()
    end

    root:CreateTitle(WoWTools_DataMixin.onlyChinese and '登入游戏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LOG_IN, GAME))
    root:CreateCheckbox(OptionText:format(FRIENDS_TEXTURE_ONLINE, WoWTools_DataMixin.onlyChinese and '有空' or FRIENDS_LIST_AVAILABLE), function()
        return Save().Friends[WoWTools_DataMixin.Player.GUID]== 'Availabel'
    end, function()
        if Save().Friends[WoWTools_DataMixin.Player.GUID]== 'Availabel' then
            Save().Friends[WoWTools_DataMixin.Player.GUID]= nil
        else
            Save().Friends[WoWTools_DataMixin.Player.GUID]= 'Availabel'
        end
        self:set_status()
    end)

    root:CreateCheckbox(OptionText:format(FRIENDS_TEXTURE_AFK, WoWTools_DataMixin.onlyChinese and '离开' or FRIENDS_LIST_AWAY), function()
        return Save().Friends[WoWTools_DataMixin.Player.GUID]== 'Away'
    end, function()
        if Save().Friends[WoWTools_DataMixin.Player.GUID]== 'Away' then
            Save().Friends[WoWTools_DataMixin.Player.GUID]= nil
        else
            Save().Friends[WoWTools_DataMixin.Player.GUID]= 'Away'
        end
        self:set_status()
    end)

    root:CreateCheckbox(OptionText:format(FRIENDS_TEXTURE_DND, WoWTools_DataMixin.onlyChinese and '忙碌' or FRIENDS_LIST_BUSY), function()
        return Save().Friends[WoWTools_DataMixin.Player.GUID]== 'DND'
    end, function()
        if Save().Friends[WoWTools_DataMixin.Player.GUID]== 'DND' then
            Save().Friends[WoWTools_DataMixin.Player.GUID]= nil
        else
            Save().Friends[WoWTools_DataMixin.Player.GUID]= 'DND'
        end
        self:set_status()
    end)

    root:CreateDivider()
    sub= root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '其他玩家' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTINGS_CATEGORY_TITLE_MISC, PLAYER),
    function()
        return MenuResponse.Open
    end)

    sub:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
    function(data)
        StaticPopup_Show('WoWTools_OK',
        data.name,
        nil,
        {SetValue=function()
            Save().Friends= {}
            print(
                WoWTools_FriendsMixin.addName..WoWTools_DataMixin.Icon.icon2,
                data.name
            )
        end})
        return MenuResponse.Open
    end, {name=name})
    sub:CreateDivider()

    for guid, stat in pairs(Save().Friends) do
        if guid~=WoWTools_DataMixin.Player.GUID then
            local btn= sub:CreateCheckbox(
                format('|A:%s:0:0|a', OptionTexture[stat] or '')
                ..WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {reName=true, reRealm=true}),
            function(data)
                return Save().Friends[data.guid]
            end, function(data)
                Save().Friends[data.guid]= not Save().Friends[data.guid] and data.stat or nil
            end, {guid=guid, stat=stat})
            btn:SetData(guid)
            btn:SetTooltip(function(tooltip, desc)
                GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(desc))
                GameTooltip_AddNormalLine(tooltip, WoWTools_DataMixin.onlyChinese and '移除' or REMOVE)
            end)
        end
    end

    root:CreateDivider()
    sub= root:CreateCheckbox(WoWTools_DataMixin.Icon.net2..(WoWTools_DataMixin.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET)..' ('..(WoWTools_DataMixin.onlyChinese and '好友' or FRIEND)..') '..( WoWTools_DataMixin.onlyChinese and '信息' or INFO)..'|A:communities-icon-chat:0:0|a', function()
        return not Save().disabledBNFriendInfo
    end, function()
        Save().disabledBNFriendInfo= not Save().disabledBNFriendInfo and true or nil
        self:set_events()
    end)

    sub:CreateCheckbox(format(WoWTools_DataMixin.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, 'WoW'..WoWTools_DataMixin.Icon.wow2..(WoWTools_DataMixin.onlyChinese and '好友' or FRIEND)), function()
        return not Save().allFriendInfo
    end, function()
        Save().allFriendInfo= not Save().allFriendInfo and true or nil
    end)

    sub:CreateCheckbox((WoWTools_DataMixin.onlyChinese and '仅限偏好好友' or format(LFG_LIST_CROSS_FACTION, BATTLE_PET_FAVORITE))..'|A:friendslist-favorite:0:0|a', function()
        return Save().showFriendInfoOnlyFavorite
    end, function()
        Save().showFriendInfoOnlyFavorite= not Save().showFriendInfoOnlyFavorite and true or nil
    end)

    sub:CreateCheckbox((WoWTools_DataMixin.onlyChinese and '仅限脱离战斗' or format(LFG_LIST_CROSS_FACTION, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_OUT_OF_COMBAT))..'|A:Warfronts-BaseMapIcons-Horde-Barracks-Minimap:0:0|a', function()
        return not Save().showInCombatFriendInfo
    end, function()
        Save().showInCombatFriendInfo= not Save().showInCombatFriendInfo and true or nil
    end)

    root:CreateCheckbox('|A:Battlenet-ClientIcon-App:0:0|a'..(WoWTools_DataMixin.onlyChinese and '好友' or FRIEND)..' Plus', function()
        return not Save().disabledFriendPlus
    end, function()
        Save().disabledFriendPlus= not Save().disabledFriendPlus and true or nil
        WoWTools_DataMixin:Call(FriendsList_Update, true)
    end)

    root:CreateDivider()
    root:CreateButton(WoWTools_FriendsMixin.addName, function()
        WoWTools_PanelMixin:Open(nil, WoWTools_FriendsMixin.addName)
    end)
end










--处理，好友，在线信息
local function Set_Friend_Event(self, _, friendIndex)
--战斗中，不显示，好友，提示
    if (not Save().showInCombatFriendInfo and UnitAffectingCombat('player') and IsInInstance()) then
        self.tips=nil
        return
    end

    local accountInfo= friendIndex and C_BattleNet.GetFriendAccountInfo(friendIndex) --FriendsFrame_UpdateFriendButton FriendsFrame.lua

    if not accountInfo
        or (
            not Save().allFriendInfo--仅限，WoW，好友
            and accountInfo.gameAccountInfo.isOnline
            and (
                    accountInfo.gameAccountInfo.clientProgram ~= BNET_CLIENT_WOW
                    or accountInfo.gameAccountInfo.wowProjectID ~= WOW_PROJECT_ID
                    or not accountInfo.gameAccountInfo.isInCurrentRegion
                )
            )
        or (not accountInfo.isFavorite and Save().showFriendInfoOnlyFavorite)--仅限收藏好友
    then
        return
    end

    local text= ((accountInfo.note and accountInfo.note:gsub(' ', '')~='') and accountInfo.note or accountInfo.accountName or accountInfo.battleTag or '')--备注 或名称 战网名称
    text= '|cff00ccff['..GetBNPlayerLink(accountInfo.accountName, text, accountInfo.bnetAccountID, 0, 0, 0)..'] '
    if accountInfo.gameAccountInfo.isOnline then--是不在线
        if accountInfo.isAFK or accountInfo.gameAccountInfo.isGameAFK then
            text= text..'|T'..FRIENDS_TEXTURE_AFK..':0|t'
        elseif accountInfo.isDND or accountInfo.gameAccountInfo.isGameBusy then
            text= text..'|T'..FRIENDS_TEXTURE_DND..':0|t'
        else
            text= text..'|T'..FRIENDS_TEXTURE_ONLINE..':0|t'
        end
    else
        text= text..'|T'..FRIENDS_TEXTURE_OFFLINE..':0|t'
    end

    if accountInfo.gameAccountInfo.characterLevel and accountInfo.gameAccountInfo.characterLevel>0 and accountInfo.gameAccountInfo.characterLevel~= GetMaxLevelForLatestExpansion() then--角色等级
        text= text..'|cnGREEN_FONT_COLOR:'..accountInfo.gameAccountInfo.characterLevel..'|r '
    end

    if accountInfo.gameAccountInfo.isOnline and accountInfo.gameAccountInfo.clientProgram == BNET_CLIENT_WOW then
        if accountInfo.gameAccountInfo.wowProjectID == WOW_PROJECT_ID  and accountInfo.gameAccountInfo.isInCurrentRegion then
            text= text..WoWTools_UnitMixin:GetPlayerInfo(nil, accountInfo.gameAccountInfo.playerGuid, nil, {
                        reLink= accountInfo.gameAccountInfo.factionName==WoWTools_DataMixin.Player.Faction,
                        reName=true,
                        faction=accountInfo.gameAccountInfo.factionName,
                    })..' '
        else
            text= text..(accountInfo.gameAccountInfo.characterName or '')
                    ..(accountInfo.gameAccountInfo.realmName and accountInfo.gameAccountInfo.realmName~='' and '-'..accountInfo.gameAccountInfo.realmName or '')
                    ..(accountInfo.gameAccountInfo.className and '('..accountInfo.gameAccountInfo.className..')' or '')
        end
    end

    if accountInfo.gameAccountInfo.clientProgram then
        C_Texture.GetTitleIconTexture(accountInfo.gameAccountInfo.clientProgram, Enum.TitleIconVersion.Small, function(success, texture)--FriendsFrame.lua BnetShared.lua
            if success and texture then
                text= text..'|T'..texture..':0|t'
            end
        end)
    end

    if not accountInfo.gameAccountInfo.isInCurrentRegion then
        if accountInfo.gameAccountInfo.regionID and RegionNames[accountInfo.gameAccountInfo.regionID] then
            text= text..' |cnWARNING_FONT_COLOR:'..RegionNames[accountInfo.gameAccountInfo.regionID]..'|r'
        end
    elseif accountInfo.gameAccountInfo.clientProgram == BNET_CLIENT_WOW and accountInfo.gameAccountInfo.wowProjectID ~= WOW_PROJECT_ID then
        text= text..' |cnWARNING_FONT_COLOR:CLASSIC'..accountInfo.gameAccountInfo.wowProjectID..'|r'
    end

    local infoText
    local function ShowRichPresenceOnly(client, wowProjectID, faction, realmID)
        if (client ~= BNET_CLIENT_WOW) or (wowProjectID ~= WOW_PROJECT_ID) then
            return true;
        elseif (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) and ((faction ~= WoWTools_DataMixin.Player.Faction) or (realmID ~= self.playerRealmID)) then
            return true
        end
    end
    local function GetOnlineInfoText(client, isMobile, rafLinkType, locationText)
        if locationText then
            if isMobile then
                return '|A:UI-ChatIcon-App:0:0|a'..locationText
            end
            if (client == BNET_CLIENT_WOW) and (rafLinkType ~= Enum.RafLinkType.None) and not isMobile then
                if rafLinkType == Enum.RafLinkType.Recruit then
                    return format(WoWTools_DataMixin.onlyChinese and '|A:recruitafriend_V2_tab_icon:0:0|a|cffffd200招募的战友：|r %s' or RAF_RECRUIT_FRIEND, locationText);
                else
                    return format(WoWTools_DataMixin.onlyChinese and '|A:recruitafriend_V2_tab_icon:0:0|acffffd200招募者：|r %s' or RAF_RECRUITER_FRIEND, locationText);
                end
            end
        end
        return locationText;
    end
    if ShowRichPresenceOnly(accountInfo.gameAccountInfo.clientProgram, accountInfo.gameAccountInfo.wowProjectID, accountInfo.gameAccountInfo.factionName, accountInfo.gameAccountInfo.realmID) then
        infoText = GetOnlineInfoText(accountInfo.gameAccountInfo.clientProgram, accountInfo.gameAccountInfo.isWowMobile, accountInfo.rafLinkType, accountInfo.gameAccountInfo.richPresence);
    else
        infoText = GetOnlineInfoText(accountInfo.gameAccountInfo.clientProgram, accountInfo.gameAccountInfo.isWowMobile, accountInfo.rafLinkType, accountInfo.gameAccountInfo.areaName);
    end
    text= text..(infoText or '')

    if accountInfo.gameAccountInfo.canSummon then
        text= text..'|A:socialqueuing-friendlist-summonbutton-up:0:0|a'
    end

    if self.tips~= text then
        self.tips= text
        print(
            WoWTools_DataMixin.Icon.icon2..text
        )
    end
end


















local function Init()--好友列表, 初始化
    OptionText= (WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS).."|T%s:0:|t %s"
    RegionNames = {
        [1] = WoWTools_DataMixin.onlyChinese and '北美' or NORTH_AMERICA,
        [2] = WoWTools_DataMixin.onlyChinese and '韩国' or KOREA,
        [3] = WoWTools_DataMixin.onlyChinese and '欧洲' or EUROPE,
        [4] = WoWTools_DataMixin.onlyChinese and '台湾' or TAIWAN,
        [5] = WoWTools_DataMixin.onlyChinese and '中国' or CHINA,
    }
    FriendsFrameStatusDropdown:SetSize(58, 25)--原生，有点问题

    FriendsButton= WoWTools_ButtonMixin:Menu(FriendsListFrame, {
        name= 'WoWToolsFriendsMenuButton',
        icon='hide',
    })

    FriendsButton:SetPoint('RIGHT', FriendsFrameCloseButton, 'LEFT')
    FriendsButton:GetFrameStrata(FriendsFrameCloseButton:GetFrameStrata())
    FriendsButton:SetFrameLevel(FriendsFrameCloseButton:GetFrameLevel()+1)
    FriendsButton:SetupMenu(Init_Friends_Menu)

    FriendsButton.playerRealmID = GetRealmID()

--处理，好友，在线信息
    FriendsButton:SetScript('OnEvent', Set_Friend_Event)


    function FriendsButton:set_events()
        if Save().disabledBNFriendInfo then
            self.tips= nil
            self:UnregisterEvent('BN_FRIEND_INFO_CHANGED')
        else
            self:RegisterEvent('BN_FRIEND_INFO_CHANGED')
        end
    end
    FriendsButton:set_events()











    --#######
    --好友列表
    --#######

    function FriendsButton:set_status(showPrint)
        if not BNConnected() then
            self:SetNormalTexture(WoWTools_DataMixin.Icon.icon)
            self:GetNormalTexture():SetAlpha(0.3)
            return
        end

        local bnetAFK, bnetDND= select(5, BNGetInfo())
        local text

        local alpha= 1
        if Save().Friends[WoWTools_DataMixin.Player.GUID]=='Availabel' then
            if bnetAFK or bnetDND then
                BNSetAFK(false)
                BNSetDND(false)
                text= format(OptionText, FRIENDS_TEXTURE_ONLINE, WoWTools_DataMixin.onlyChinese and '有空' or FRIENDS_LIST_AVAILABLE)

            end
            self:SetNormalTexture(FRIENDS_TEXTURE_ONLINE)

        elseif Save().Friends[WoWTools_DataMixin.Player.GUID]=='Away' then
            if not bnetAFK then
                BNSetAFK(true)
                text= format(OptionText, FRIENDS_TEXTURE_AFK, WoWTools_DataMixin.onlyChinese and '离开' or FRIENDS_LIST_AWAY)
            end
            self:SetNormalTexture(FRIENDS_TEXTURE_AFK)

        elseif Save().Friends[WoWTools_DataMixin.Player.GUID]=='DND' then
            if not bnetDND then
                BNSetDND(true)
                text= format(OptionText, FRIENDS_TEXTURE_DND, WoWTools_DataMixin.onlyChinese and '忙碌' or FRIENDS_LIST_BUSY)
            end
            self:SetNormalTexture(FRIENDS_TEXTURE_DND)

        else
            self:SetNormalTexture(WoWTools_DataMixin.Icon.icon)
            alpha= 0.3
        end

        self:GetNormalTexture():SetAlpha(alpha)

        if text then
            if showPrint then
                print(
                    WoWTools_FriendsMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    text
                )
            else
                WoWTools_DataMixin:Call(FriendsFrame_CheckBattlenetStatus)
            end


            bnetAFK, bnetDND = select(5, BNGetInfo());
            if bnetAFK then
                FriendsTabHeader.bnStatus = FRIENDS_TEXTURE_AFK;
            elseif bnetDND then
                FriendsTabHeader.bnStatus = FRIENDS_TEXTURE_DND;
            else
                FriendsTabHeader.bnStatus = FRIENDS_TEXTURE_ONLINE;
            end
            FriendsFrameStatusDropdown.Text:SetFormattedText("\124T%s.tga:16:16:0:0\124t", FriendsTabHeader.bnStatus)
        end
    end

    FriendsButton:set_status(true)









--好友PLUS FriendsFrame.lua
     WoWTools_DataMixin:Hook('FriendsFrame_UpdateFriendButton', function(self)
        if Save().disabledFriendPlus then
            return
        end

        if self.buttonType == FRIENDS_BUTTON_TYPE_WOW then
            local info = C_FriendList.GetFriendInfoByIndex(self.id)
            if not info or not info.guid then
                return
            end
            local text=WoWTools_UnitMixin:GetPlayerInfo(nil, info.guid, nil)
            if text~='' then
                text= text..(info.area and info.connected and ' '..info.area or '')
                self.info:SetText(text)
            end

        elseif self.buttonType == FRIENDS_BUTTON_TYPE_BNET then--2战网                
            local accountInfo = C_BattleNet.GetFriendAccountInfo(self.id)
            if not accountInfo then
                return
            end
            if accountInfo.note and accountInfo.note:gsub(' ','')~='' then--备注，提示
                self.name:SetText(accountInfo.accountName..' ('..accountInfo.note..')')
            end
            if not accountInfo.gameAccountInfo.isInCurrentRegion then--不在，当前地区
                if accountInfo.gameAccountInfo.regionID and RegionNames[accountInfo.gameAccountInfo.regionID] then
                    self.info:SetText('|cnWARNING_FONT_COLOR:'..RegionNames[accountInfo.gameAccountInfo.regionID])
                end
                return
            elseif not accountInfo.gameAccountInfo.isOnline then--or accountInfo.gameAccountInfo.wowProjectID~=WOW_PROJECT_ID then
                return

            elseif accountInfo.gameAccountInfo.clientProgram ~= BNET_CLIENT_WOW or accountInfo.gameAccountInfo.wowProjectID~= WOW_PROJECT_ID then
                if accountInfo.gameAccountInfo.wowProjectID and accountInfo.gameAccountInfo.clientProgram then
                    self.info:SetText('|cnWARNING_FONT_COLOR:'..accountInfo.gameAccountInfo.clientProgram.. accountInfo.gameAccountInfo.wowProjectID)
                end
                return
            end

            local text=''

            if accountInfo.gameAccountInfo.characterLevel and accountInfo.gameAccountInfo.characterLevel>0 and accountInfo.gameAccountInfo.characterLevel~= GetMaxLevelForLatestExpansion() then--角色等级
                text= text..'|cnGREEN_FONT_COLOR:'..accountInfo.gameAccountInfo.characterLevel..'|r '
            end
            text= text.. WoWTools_UnitMixin:GetPlayerInfo(nil, accountInfo.gameAccountInfo.playerGuid, nil, {reName=true, reRealm=true, faction=accountInfo.gameAccountInfo.factionName })

            if accountInfo.gameAccountInfo.isOnline and accountInfo.gameAccountInfo.areaName then--区域
                text= text..' '..accountInfo.gameAccountInfo.areaName
            end
            if accountInfo.gameAccountInfo.playerGuid then
                local class= select(2, GetPlayerInfoByGUID(accountInfo.gameAccountInfo.playerGuid))
                if class then
                    text= '|c'..select(4, GetClassColor(class))..text..'|r'
                end
            end
            self.info:SetText(text)
        end
     end)

















    --查询, 名单列表
    local function set_WhoList_Update(scrollBox)
        scrollBox= scrollBox or WhoFrame.ScrollBox
        if not scrollBox:GetView() then
            return
        end

        local maxLevel= GetMaxLevelForLatestExpansion()

        local class= WhoFrameColumnHeader4:GetFontString():GetStringWidth()+15
        WhoFrameColumnHeader1:SetWidth(class)

        local level= WhoFrameColumnHeader3:GetFontString():GetStringWidth()+15
        WhoFrameColumnHeader3:SetWidth(level)

        local width= ((scrollBox:GetWidth() -level - class)/ 2)- 18.5

        WhoFrameColumnHeader1:SetWidth(width-7)
        WhoFrameColumnHeader2:SetWidth(width+7)

        for _, btn in pairs(scrollBox:GetFrames()) do
            btn.Name:SetWidth(width-7)
            btn.Variable:SetWidth(width+7)

            if not btn.setOnDoubleClick then
                btn.Level:SetWidth(level)
                btn.Class:SetWidth(class)
                for _, t in pairs({btn:GetRegions()}) do
                    if t:GetObjectType()=='Texture' then
                        t:SetPoint('LEFT')
                        t:SetPoint('RIGHT')
                        break
                    end
                end

                btn:SetScript('OnDoubleClick', function()
                    if WhoFrameGroupInviteButton:IsEnabled() then
                        WhoFrameGroupInviteButton:Click()
                    end
                end)
                btn:HookScript('OnClick', function()
                    if WhoFrameAddFriendButton:IsEnabled() and IsAltKeyDown() then
                        WhoFrameAddFriendButton:Click()
                        C_Timer.After(1, function() WoWTools_DataMixin:Call(WhoList_Update) end)
                    end
                end)
                btn:HookScript('OnEnter', function(self)--FriendsFrame.lua
                    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                    GameTooltip:ClearLines()
                    local index= self.index
                    local info = index and C_FriendList.GetWhoInfo(index)
                    if info and info.fullName then
                        GameTooltip:AddLine((info.gender==2 and '|A:charactercreate-gendericon-male-selected:0:0|a' or info.gender==3 and '|A:charactercreate-gendericon-female-selected:0:0|a' or format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toRight))
                                    ..(WoWTools_UnitMixin:GetClassIcon(nil, nil, info.filename) or '')
                                    ..self.col
                                    ..info.fullName
                                    ..(WoWTools_UnitMixin:GetIsFriendIcon(nil, nil, info.fullName) or '')
                                    ..(info.level and ' '..(info.level~=GetMaxLevelForLatestExpansion() and '|cnGREEN_FONT_COLOR:' or '')..info.level or '')
                                )
                        GameTooltip:AddLine('|A:UI-HUD-MicroMenu-GuildCommunities-GuildColor-Mouseover:0:0|a'..self.col..(info.fullGuildName or ''))
                        GameTooltip:AddLine('|A:groupfinder-waitdot:0:0|a'..self.col..(info.raceStr or ''))
                        GameTooltip:AddLine('|A:poi-islands-table:0:0|a'..self.col..(info.area or ''))
                    end

                    GameTooltip:AddLine(' ')
                    GameTooltip:AddDoubleLine(self.col..'index', self.index)
                    GameTooltip:AddDoubleLine(self.col..(WoWTools_DataMixin.onlyChinese and '组队邀请' or GROUP_INVITE), (WoWTools_DataMixin.onlyChinese and '双击' or BUFFER_DOUBLE)..WoWTools_DataMixin.Icon.left)
                    GameTooltip:AddDoubleLine(self.col..(WoWTools_DataMixin.onlyChinese and '添加好友' or ADD_FRIEND), 'Alt+'..WoWTools_DataMixin.Icon.left)
                    GameTooltip:AddLine(' ')
                    GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_FriendsMixin.addName)
                    GameTooltip:Show()
                end)
                btn.setOnDoubleClick= true
            end
            btn.tooltip1=nil
            btn.tooltip2=nil

            local info= btn.index and C_FriendList.GetWhoInfo(btn.index)
            local r,g,b,lv, hex

            if info then
                if RAID_CLASS_COLORS[info.filename] then
                    r,g,b= RAID_CLASS_COLORS[info.filename]:GetRGB()
                    hex= RAID_CLASS_COLORS[info.filename]:GenerateHexColor()
                    btn.Class:SetText(
                        (info.gender==2
                            and '|A:charactercreate-gendericon-male-selected:0:0|a'
                            or (info.gender==3 and '|A:charactercreate-gendericon-female-selected:0:0|a')
                            or ''
                        )
                        ..(WoWTools_UnitMixin:GetClassIcon(nil, nil, info.filename) or info.filename)
                    )
                end
            lv= info.level

                if info.fullName then
                    if info.fullName== WoWTools_DataMixin.Player.Name then
                        btn.Name:SetText(format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toRight)..(WoWTools_DataMixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)..format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toLeft))
                    else
                        local nameText= WoWTools_UnitMixin:GetIsFriendIcon(nil, nil, info.fullName)--检测, 是否好友
                        if nameText then
                            nameText= nameText..info.fullName
                            if info.fullName== WoWTools_DataMixin.Player.Name then
                                nameText= nameText..'|A:auctionhouse-icon-favorite:0:0|a'
                            end
                            btn.Name:SetText(nameText)
                        end
                    end
                end
            end

            btn.col= hex and '|c'..hex or ''

            r,g,b= r or 1, g or 1, b or 1
            btn.Name:SetTextColor(r,g,b)
            btn.Variable:SetTextColor(r,g,b)

            if lv==0 or lv== maxLevel then
                btn.Level:SetText('|cff626262'..lv..'|r')
            else
                btn.Level:SetTextColor(0,1,0)
            end
        end
    end

    WoWTools_DataMixin:Hook('WhoList_Update', function()
        set_WhoList_Update()
    end)

    WoWTools_DataMixin:Hook(WhoFrame.ScrollBox, 'SetScrollTargetOffset', function(self)
        set_WhoList_Update(self)
    end)


    FriendsFrame:HookScript('OnShow', function(self)
        local isConnected= BNConnected()
        if not isConnected and not self.ConnectedLabel then
            self.ConnectedLabel= WoWTools_LabelMixin:Create(self.TitleContainer, {
                name= 'WoWToolsFriendsConnectedLabel',
                text= WoWTools_DataMixin.onlyChinese and '战网断开' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SOCIAL_TWITTER_DISCONNECT, COMMUNITY_COMMAND_BATTLENET),
                --color= {r=1,g=0,b=0},
            })
            self.ConnectedLabel:SetPoint('LEFT', FriendsFrameTitleText, 0, 0)
        end
        if self.ConnectedLabel then
            self.ConnectedLabel:SetShown(not isConnected)
        end
    end)

    Init=function()end
end

















function WoWTools_FriendsMixin:Blizzard_FriendsFrame()
    Init()
end