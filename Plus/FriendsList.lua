local id, e = ...
local addName
local Save={
        Friends={},
        disabledBNFriendInfo=not WoWTools_DataMixin.Player.husandro and true or nil,--禁用战网，好友信息，提示
        --allFriendInfo= true,--仅限，WoW，好友
        --showInCombatFriendInfo=true,--仅限，不在战斗中，好友，提示
        --showFriendInfoOnlyFavorite=true,--仅限收藏好友
    }

local FriendsButton
local OptionText--= (WoWTools_Mixin.onlyChinese and '设置' or SETTINGS).."|T%s:0:|t %s"


local OptionTexture={
    ['Availabel'] = FRIENDS_TEXTURE_ONLINE,
    ['DND']= FRIENDS_TEXTURE_DND,
    ['Away'] =FRIENDS_TEXTURE_AFK,
}
local RegionNames




--#############
--快速加入, 模块
--#############
local function set_SOCIAL_QUEUE_UPDATE()--更新, 快速加入
    if QuickJoinToastButton then
        if not QuickJoinToastButton.quickJoinText then
            QuickJoinToastButton.quickJoinText= WoWTools_LabelMixin:Create(QuickJoinToastButton, {color=true})--:CreateFontString()
            --QuickJoinToastButton.quickJoinText:SetFontObject('NumberFontNormal')
            QuickJoinToastButton.quickJoinText:SetPoint('TOPRIGHT', -6, -3)
            --if WoWTools_DataMixin.Player.useColor then
              --  QuickJoinToastButton.FriendCount:SetTextColor(WoWTools_DataMixin.Player.useColor.r, WoWTools_DataMixin.Player.useColor.g, WoWTools_DataMixin.Player.useColor.b)
            --end
        end

        local n=#C_SocialQueue.GetAllGroups()
        QuickJoinToastButton.quickJoinText:SetText(n~=0 and n or '')
    end
end





local function set_QuinkJoin_Init()--快速加入, 初始化 QuickJoin.lua
    set_SOCIAL_QUEUE_UPDATE()

    hooksecurefunc(QuickJoinEntryMixin, 'ApplyToFrame', function(self, frame)
        if not frame then
            return
        end
        for i=1, #self.displayedMembers do
            local guid=self.displayedMembers[i].guid
            local nameObj = frame.Members[i]
            local name = nameObj and nameObj.name
            if guid and name then
                local _, class, _, race, sex = GetPlayerInfoByGUID(guid)
                local raceTexture=WoWTools_UnitMixin:GetRaceIcon({unit=nil, guid=guid, race=race, sex=sex , reAtlas=false})
                local hex= select(4, GetClassColor(class))
                hex= '|c'..hex
                name= (raceTexture or '').. name
                name=hex..name..'|r'
                nameObj:SetText(name)

                nameObj.guid=guid
                nameObj.col= hex
                if not nameObj:IsMouseEnabled() then
                    nameObj:EnableMouse(true)
                    nameObj:SetScript('OnLeave', GameTooltip_Hide)
                    nameObj:SetScript('OnEnter', function(self2)
                        GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
                        GameTooltip:ClearLines()
                        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '/密语' or SLASH_SMART_WHISPER2, self2.col..self2.name)
                        GameTooltip:AddLine(' ')
                        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, addName)
                        GameTooltip:Show()
                    end)
                    nameObj:SetScript('OnMouseDown',function(self2)
                        WoWTools_ChatMixin:Say(nil, self2.name, self2.guid2 and C_BattleNet.GetGameAccountInfoByGUID(self2.guid))
                    end)
                end
            end
        end

        if not frame.OnDoubleClick then--设置, 双击, 加入
            frame:HookScript("OnDoubleClick", function()--QuickJoin.lua
                QuickJoinFrame:JoinQueue()
                local frame2=LFGListApplicationDialog
                if frame2:IsShown() then
                    if not frame2.TankButton.CheckButton:GetChecked() and not frame2.HealerButton.CheckButton:GetChecked() and not frame2.DamagerButton.CheckButton:GetChecked() then
                        local specID=GetSpecialization()--当前专精
                        if specID then
                            local role = select(5, GetSpecializationInfo(specID))
                            if role=='DAMAGER' and frame2.DamagerButton:IsShown() then
                                frame2.DamagerButton.CheckButton:SetChecked(true)

                            elseif role=='TANK' and frame2.TankButton:IsShown() then
                                frame2.TankButton.CheckButton:SetChecked(true)

                            elseif role=='HEALER' and frame2.HealerButton:IsShown() then
                                frame2.HealerButton.CheckButton:SetChecked(true)
                            end
                            LFGListApplicationDialog_UpdateValidState(frame2)
                        end
                    end
                    --[[if frame2.SignUpButton:IsEnabled() then
                        --frame2.SignUpButton:Click()
                    end]]
                end
            end)
        end

        local text--需求职责, 提示
        if self.guid then
            local canJoin, numQueues, needTank, needHealer, needDamage, isSoloQueuePart, questSessionActive, leaderGUID = C_SocialQueue.GetGroupInfo(self.guid)
            if canJoin then
                if numQueues and numQueues>0 then
                    text= '|cnGREEN_FONT_COLOR:'..numQueues..'|r'
                end
                if needTank or needHealer or needDamage then
                    text= (text or '')..(needTank and INLINE_TANK_ICON or '')..(needHealer and INLINE_HEALER_ICON or '')..(needDamage and INLINE_DAMAGER_ICON or '')
                end
                if questSessionActive then
                    text= (text or '')..'|A:QuestPortraitIcon-SandboxQuest:0:0|a'
                end
            end
        end
        if text and not frame.roleTips then
            frame.roleTips= WoWTools_LabelMixin:Create(frame)
            frame.roleTips:SetPoint('BOTTOMRIGHT')
        end
        if frame.roleTips then
            frame.roleTips:SetText(text or '')
        end
    end)

    hooksecurefunc(QuickJoinRoleSelectionFrame, 'ShowForGroup', function(self, guid)--职责选择框
        local t, h ,dps=self.RoleButtonTank.CheckButton, self.RoleButtonHealer.CheckButton, self.RoleButtonDPS.CheckButton--选择职责
        local t3, h3, dps3 =t:GetChecked(), h:GetChecked(), dps:GetChecked()
        if not t3 and not h3 and not dps3 then
            local sid=GetSpecialization()
            if sid and sid>0 then
                local role = select(5, GetSpecializationInfo(sid))
                if role=='TANK' then
                    t:Click()
                elseif role=='HEALER' then
                    h:Click()
                elseif role=='DAMAGER' then
                    dps:Click()
                end
            end
        end

        local leaderGUID = select(8, C_SocialQueue.GetGroupInfo(guid))--玩家名称
        local link= leaderGUID and WoWTools_UnitMixin:GetPlayerInfo({guid=leaderGUID, reName=true, reRealm=true, reLink=true,})
        if link and not self.nameInfo then
            self.nameInfo= WoWTools_LabelMixin:Create(self)
            self.nameInfo:SetPoint('BOTTOM', self.CancelButton, 'TOPLEFT', 2, 0)
            self:HookScript('OnHide', function(self2)
                if self2.nameInfo then
                    self2.nameInfo:SetText('')
                end
            end)
        end
        if self.nameInfo then
            self.nameInfo:SetText(link or '')
        end

        if self.AcceptButton:IsEnabled() and not IsModifierKeyDown() then
            local tank2, healer2, dps2= self:GetSelectedRoles()
            self.AcceptButton:Click()
            print(WoWTools_DataMixin.Icon.icon2.. addName,
                    tank2 and INLINE_TANK_ICON, healer2 and INLINE_HEALER_ICON, dps2 and INLINE_DAMAGER_ICON,
                    WoWTools_TextMixin:GetEnabeleDisable(false)..'Alt',
                    link
                )
        end
    end)

    if QuickJoinToastButton.Toast then
        QuickJoinToastButton.Toast:ClearAllPoints()
        QuickJoinToastButton.Toast:SetPoint('BOTTOMLEFT', QuickJoinToastButton, 'TOPLEFT', 29, 2)
    end
    if QuickJoinToastButton.Toast2 then
        QuickJoinToastButton.Toast2:ClearAllPoints()
        QuickJoinToastButton.Toast2:SetPoint('BOTTOMLEFT', QuickJoinToastButton.Toast or QuickJoinToastButton, 'TOPLEFT', 29 ,2)
    end
end





























local function Init_Friends_Menu(self, root)
    if not BNConnected() then
        root:CreateTitle('|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '断开战网' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SOCIAL_TWITTER_DISCONNECT, COMMUNITY_COMMAND_BATTLENET))..'|r')
        root:CreateDivider()
    end

    root:CreateTitle(WoWTools_Mixin.onlyChinese and '登入游戏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LOG_IN, GAME))
    root:CreateCheckbox(OptionText:format(FRIENDS_TEXTURE_ONLINE, WoWTools_Mixin.onlyChinese and '有空' or FRIENDS_LIST_AVAILABLE), function()
        return Save.Friends[WoWTools_DataMixin.Player.GUID]== 'Availabel'
    end, function()
        if Save.Friends[WoWTools_DataMixin.Player.GUID]== 'Availabel' then
            Save.Friends[WoWTools_DataMixin.Player.GUID]= nil
        else
            Save.Friends[WoWTools_DataMixin.Player.GUID]= 'Availabel'
        end
        self:set_status()
    end)

    root:CreateCheckbox(OptionText:format(FRIENDS_TEXTURE_AFK, WoWTools_Mixin.onlyChinese and '离开' or FRIENDS_LIST_AWAY), function()
        return Save.Friends[WoWTools_DataMixin.Player.GUID]== 'Away'
    end, function()
        if Save.Friends[WoWTools_DataMixin.Player.GUID]== 'Away' then
            Save.Friends[WoWTools_DataMixin.Player.GUID]= nil
        else
            Save.Friends[WoWTools_DataMixin.Player.GUID]= 'Away'
        end
        self:set_status()
    end)

    root:CreateCheckbox(OptionText:format(FRIENDS_TEXTURE_DND, WoWTools_Mixin.onlyChinese and '忙碌' or FRIENDS_LIST_BUSY), function()
        return Save.Friends[WoWTools_DataMixin.Player.GUID]== 'DND'
    end, function()
        if Save.Friends[WoWTools_DataMixin.Player.GUID]== 'DND' then
            Save.Friends[WoWTools_DataMixin.Player.GUID]= nil
        else
            Save.Friends[WoWTools_DataMixin.Player.GUID]= 'DND'
        end
        self:set_status()
    end)

    root:CreateDivider()
    local sub= root:CreateButton(WoWTools_Mixin.onlyChinese and '其他玩家' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTINGS_CATEGORY_TITLE_MISC, PLAYER))
    sub:CreateButton('|A:bags-button-autosort-up:0:0|a'..(WoWTools_Mixin.onlyChinese and '全部清除' or CLEAR_ALL), function()
        Save.Friends= {}
        print(WoWTools_DataMixin.Icon.icon2.. addName, WoWTools_Mixin.onlyChinese and '全部清除' or CLEAR_ALL)
    end)
    sub:CreateDivider()

    for guid, stat in pairs(Save.Friends) do
        if guid~=WoWTools_DataMixin.Player.GUID then
            local btn= sub:CreateButton(format('|A:%s:0:0|a', OptionTexture[stat] or '').. WoWTools_UnitMixin:GetPlayerInfo({guid=guid, reName=true, reRealm=true}), function(data)
                if data then
                    Save.Friends[data]= nil
                end
            end)
            btn:SetData(guid)
            btn:SetTooltip(function(tooltip, elementDescription)
                GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription))
                GameTooltip_AddNormalLine(tooltip, WoWTools_Mixin.onlyChinese and '移除' or REMOVE)
            end)
        end
    end

    root:CreateDivider()
    sub= root:CreateCheckbox(WoWTools_DataMixin.Icon.net2..(WoWTools_Mixin.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET)..' ('..(WoWTools_Mixin.onlyChinese and '好友' or FRIEND)..') '..( WoWTools_Mixin.onlyChinese and '信息' or INFO)..'|A:communities-icon-chat:0:0|a', function()
        return not Save.disabledBNFriendInfo
    end, function()
        Save.disabledBNFriendInfo= not Save.disabledBNFriendInfo and true or nil
    end)

    sub:CreateCheckbox(format(WoWTools_Mixin.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, 'WoW'..WoWTools_DataMixin.Icon.wow2..(WoWTools_Mixin.onlyChinese and '好友' or FRIEND)), function()
        return not Save.allFriendInfo
    end, function()
        Save.allFriendInfo= not Save.allFriendInfo and true or nil
    end)

    sub:CreateCheckbox((WoWTools_Mixin.onlyChinese and '仅限偏好好友' or format(LFG_LIST_CROSS_FACTION, BATTLE_PET_FAVORITE))..'|A:friendslist-favorite:0:0|a', function()
        return Save.showFriendInfoOnlyFavorite
    end, function()
        Save.showFriendInfoOnlyFavorite= not Save.showFriendInfoOnlyFavorite and true or nil
    end)

    sub:CreateCheckbox((WoWTools_Mixin.onlyChinese and '仅限脱离战斗' or format(LFG_LIST_CROSS_FACTION, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_OUT_OF_COMBAT))..'|A:Warfronts-BaseMapIcons-Horde-Barracks-Minimap:0:0|a', function()
        return not Save.showInCombatFriendInfo
    end, function()
        Save.showInCombatFriendInfo= not Save.showInCombatFriendInfo and true or nil
    end)

    root:CreateCheckbox('|A:Battlenet-ClientIcon-App:0:0|a'..(WoWTools_Mixin.onlyChinese and '好友' or FRIEND)..' Plus', function()
        return not Save.disabledFriendPlus
    end, function()
        Save.disabledFriendPlus= not Save.disabledFriendPlus and true or nil
        WoWTools_Mixin:Call(FriendsList_Update, true)
    end)

    root:CreateDivider()
    root:CreateButton(id..' '..addName, function()
        WoWTools_PanelMixin:Open(nil, addName)
    end)
end




















--#############
--好友列表, 模块
--#############
local function Init_FriendsList()--好友列表, 初始化

    FriendsButton= WoWTools_ButtonMixin:Cbtn(FriendsListFrame, {size=20})
    FriendsButton:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, Init_Friends_Menu)
    end)
    FriendsButton:SetPoint('LEFT', FriendsFrameStatusDropdown, 'RIGHT')


    FriendsButton.playerRealmID = GetRealmID()
    FriendsButton:SetScript('OnEvent', function(self, _, friendIndex)
        if Save.disabledBNFriendInfo then
            return
        end
        if not Save.showInCombatFriendInfo and UnitAffectingCombat('player') and IsInInstance() then--战斗中，不显示，好友，提示
            self.tips=nil
            return
        end
        local accountInfo= friendIndex and C_BattleNet.GetFriendAccountInfo(friendIndex) --FriendsFrame_UpdateFriendButton FriendsFrame.lua
        if not accountInfo
            or (
                not Save.allFriendInfo--仅限，WoW，好友
                and accountInfo.gameAccountInfo.isOnline
                and (
                        accountInfo.gameAccountInfo.clientProgram ~= BNET_CLIENT_WOW
                        or accountInfo.gameAccountInfo.wowProjectID ~= WOW_PROJECT_ID
                        or not accountInfo.gameAccountInfo.isInCurrentRegion
                    )
                )
            or (not accountInfo.isFavorite and Save.showFriendInfoOnlyFavorite)--仅限收藏好友
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
                text= text..WoWTools_UnitMixin:GetPlayerInfo({
                            guid=accountInfo.gameAccountInfo.playerGuid,
                            reLink= accountInfo.gameAccountInfo.factionName==WoWTools_DataMixin.Player.Faction,
                            reName=true,
                            --reRealm=true,
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
                text= text..' |cnRED_FONT_COLOR:'..RegionNames[accountInfo.gameAccountInfo.regionID]..'|r'
            end
        elseif accountInfo.gameAccountInfo.clientProgram == BNET_CLIENT_WOW and accountInfo.gameAccountInfo.wowProjectID ~= WOW_PROJECT_ID then
            text= text..' |cnRED_FONT_COLOR:CLASSIC'..accountInfo.gameAccountInfo.wowProjectID..'|r'
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
                        return format(WoWTools_Mixin.onlyChinese and '|A:recruitafriend_V2_tab_icon:0:0|a|cffffd200招募的战友：|r %s' or RAF_RECRUIT_FRIEND, locationText);
                    else
                        return format(WoWTools_Mixin.onlyChinese and '|A:recruitafriend_V2_tab_icon:0:0|acffffd200招募者：|r %s' or RAF_RECRUITER_FRIEND, locationText);
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
            print(text)
        end
    end)

    if Save.showFriendInfoOnlyFavorite then
        FriendsButton:RegisterEvent('BN_FRIEND_INFO_CHANGED')
    else
        C_Timer.After(2, function()
            FriendsButton:RegisterEvent('BN_FRIEND_INFO_CHANGED')
        end)
    end












    --#######
    --好友列表
    --#######

    function FriendsButton:set_status(showPrint)
        if not BNConnected() then
            self:SetNormalAtlas(WoWTools_DataMixin.Icon.icon)
            return
        end
        local bnetAFK, bnetDND= select(5, BNGetInfo())
        local text


        if Save.Friends[WoWTools_DataMixin.Player.GUID]=='Availabel' then
            if bnetAFK or bnetDND then
                BNSetAFK(false)
                BNSetDND(false)
                text= format(OptionText, FRIENDS_TEXTURE_ONLINE, WoWTools_Mixin.onlyChinese and '有空' or FRIENDS_LIST_AVAILABLE)

            end
            self:SetNormalTexture(FRIENDS_TEXTURE_ONLINE)

        elseif Save.Friends[WoWTools_DataMixin.Player.GUID]=='Away' then
            if not bnetAFK then
                BNSetAFK(true)
                text= format(OptionText, FRIENDS_TEXTURE_AFK, WoWTools_Mixin.onlyChinese and '离开' or FRIENDS_LIST_AWAY)
            end
            self:SetNormalTexture(FRIENDS_TEXTURE_AFK)

        elseif Save.Friends[WoWTools_DataMixin.Player.GUID]=='DND' then
            if not bnetDND then
                BNSetDND(true)
                text= format(OptionText, FRIENDS_TEXTURE_DND, WoWTools_Mixin.onlyChinese and '忙碌' or FRIENDS_LIST_BUSY)
            end
            self:SetNormalTexture(FRIENDS_TEXTURE_DND)

        else
            self:SetNormalAtlas(WoWTools_DataMixin.Icon.icon)
        end
        if text then
            if showPrint then
                print(WoWTools_DataMixin.Icon.icon2.. addName, text)
            else
                WoWTools_Mixin:Call(FriendsFrame_CheckBattlenetStatus)
            end

C_Timer.After(1.3, function()
            bnetAFK, bnetDND = select(5, BNGetInfo());
            if bnetAFK then
                FriendsTabHeader.bnStatus = FRIENDS_TEXTURE_AFK;
            elseif bnetDND then
                FriendsTabHeader.bnStatus = FRIENDS_TEXTURE_DND;
            else
                FriendsTabHeader.bnStatus = FRIENDS_TEXTURE_ONLINE;
            end
            FriendsFrameStatusDropdown.Text:SetFormattedText("\124T%s.tga:16:16:0:0\124t", FriendsTabHeader.bnStatus)
end)
        end
    end
    FriendsButton:set_status(true)
end











--好友PLUS
--FriendsFrame.lua
local function Set_FriendsFrame_UpdateFriendButton(self)
    if Save.disabledFriendPlus then
        return
    end

    if self.buttonType == FRIENDS_BUTTON_TYPE_WOW then
        local info = C_FriendList.GetFriendInfoByIndex(self.id)
        if not info or not info.guid then
            return
        end
        local text=WoWTools_UnitMixin:GetPlayerInfo({guid=info.guid})
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
                self.info:SetText('|cnRED_FONT_COLOR:'..RegionNames[accountInfo.gameAccountInfo.regionID])
            end
            return
        elseif not accountInfo.gameAccountInfo.isOnline then--or accountInfo.gameAccountInfo.wowProjectID~=WOW_PROJECT_ID then
            return

        elseif accountInfo.gameAccountInfo.clientProgram ~= BNET_CLIENT_WOW or accountInfo.gameAccountInfo.wowProjectID~= WOW_PROJECT_ID then
            if accountInfo.gameAccountInfo.wowProjectID and accountInfo.gameAccountInfo.clientProgram then
                self.info:SetText('|cnRED_FONT_COLOR:'..accountInfo.gameAccountInfo.clientProgram.. accountInfo.gameAccountInfo.wowProjectID)
            end
            return
        end

        local text=''

        if accountInfo.gameAccountInfo.characterLevel and accountInfo.gameAccountInfo.characterLevel>0 and accountInfo.gameAccountInfo.characterLevel~= GetMaxLevelForLatestExpansion() then--角色等级
            text= text..'|cnGREEN_FONT_COLOR:'..accountInfo.gameAccountInfo.characterLevel..'|r '
        end
        text= text.. WoWTools_UnitMixin:GetPlayerInfo({guid=accountInfo.gameAccountInfo.playerGuid, reName=true, reRealm=true, faction=accountInfo.gameAccountInfo.factionName })

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
end
























--#########
--团队, 模块
--Blizzard_RaidUI.lua
--[[subframes = {};
subframes.name = _G["RaidGroupButton"..i.."Name"];
subframes.class = _G["RaidGroupButton"..i.."Class"];
subframes.level = _G["RaidGroupButton"..i.."Level"];
subframes.rank = _G["RaidGroupButton"..i.."Rank"];
subframes.role = _G["RaidGroupButton"..i.."Role"];
subframes.rankTexture = _G["RaidGroupButton"..i.."RankTexture"];
subframes.roleTexture = _G["RaidGroupButton"..i.."RoleTexture"];
subframes.readyCheck = _G["RaidGroupButton"..i.."ReadyCheck"];
button.subframes = subframes;
]]
--local setRaidGroupFrameLabel
local function Init_RaidGroupFrame_Update()--团队, 模块
    if not IsInRaid() then
        if RaidFrame.groupInfoLable then
            RaidFrame.groupInfoLable:SetText('')
        end
        return
    end
    local itemLevel, itemNum, afkNum, deadNum, notOnlineNum= 0,0,0,0,0
    local getItemLevelTab={}--取得装等
    local setSize= WhoFrame:GetWidth()> 350
    local maxLevel= GetMaxLevelForLatestExpansion()
    for i=1, MAX_RAID_MEMBERS do
        local button = _G["RaidGroupButton"..i]
        if button and button.subframes then
            local subframes = button.subframes
            local unit = "raid"..i
            if subframes and UnitExists(unit) then
                local name, _, _, level, _, fileName, _, online, isDead, role, _, combatRole = GetRaidRosterInfo(i)
                local guid= UnitGUID(unit)

                afkNum= UnitIsAFK(unit) and (afkNum+1) or afkNum
                deadNum= isDead and (deadNum+1) or deadNum
                notOnlineNum= not online and (notOnlineNum+1) or notOnlineNum

                if subframes.name and name then
                    local text
                    if name==WoWTools_DataMixin.Player.Name then--自己
                        text= WoWTools_Mixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME
                    end
                    if not text then--距离
                        local distance, checkedDistance = UnitDistanceSquared(unit)
                        if checkedDistance then
                            if distance and distance > DISTANCE_THRESHOLD_SQUARED then
                                text= WoWTools_MapMixin:GetUnit(unit)--单位, 地图名称
                                if text then
                                    text= '|A:poi-islands-table:0:0|a|cnGREEN_FONT_COLOR:'..text..'|r'
                                end
                            end
                        end
                    end

                    text= text or WoWTools_UnitMixin:GetOnlineInfo(unit)--状态

                    if not text and not setSize then--处理名字
                        text= name:gsub('(%-.+)','')--名称
                        text= WoWTools_TextMixin:sub(text, 3, 7)
                    end
                    if text then
                        subframes.name:SetText(text)
                    end
                end

                if subframes.class and fileName then
                    local text
                    if WoWTools_DataMixin.UnitItemLevel[guid] and WoWTools_DataMixin.UnitItemLevel[guid].specID then
                        local texture= select(4, GetSpecializationInfoForSpecID(WoWTools_DataMixin.UnitItemLevel[guid].specID))
                        if texture then
                            text= "|T"..texture..':0|t'
                        end
                    end
                    text= text or WoWTools_UnitMixin:GetClassIcon(nil, fileName)--职业图标

                    if text then
                        if guid and WoWTools_DataMixin.UnitItemLevel[guid] and WoWTools_DataMixin.UnitItemLevel[guid].itemLevel then
                            text= WoWTools_DataMixin.UnitItemLevel[guid].itemLevel..text
                            itemLevel= itemLevel+ WoWTools_DataMixin.UnitItemLevel[guid].itemLevel
                            itemNum= itemNum+1
                        else
                            table.insert(getItemLevelTab, unit)--取得装等
                        end
                        local role2= role or combatRole
                        if role2=='TANK'then
                            text= INLINE_TANK_ICON..text
                        elseif role2=='HEALER' then
                            text= INLINE_HEALER_ICON..text
                        end
                        subframes.class:SetText(text)
                        subframes.class:SetJustifyH('RIGHT')
                    end
                end

                if subframes.level and level==maxLevel then
                    subframes.level:SetText(WoWTools_UnitMixin:GetRaceIcon({unit=unit, guid=guid, race=nil, sex=nil, reAtlas=false}) or '')
                end
            end
        end
    end
    if not RaidFrame.groupInfoLable then
        RaidFrame.groupInfoLable= WoWTools_LabelMixin:Create(RaidFrame, {copyFont=FriendsFrameTitleText, justifyH='CENTER'})
        RaidFrame.groupInfoLable:SetPoint('BOTTOM',FriendsFrame.TitleContainer, 'TOP')
    end
    local text= '|A:charactercreate-gendericon-male-selected:0:0|a'..(itemNum==0 and 0 or format('%i',itemLevel/itemNum))
    text= text..'  |cnGREEN_FONT_COLOR:'..itemNum..'|r/'..GetNumGroupMembers()..'|cnRED_FONT_COLOR:'--人数
    text= text..'  '..format("\124T%s.tga:0\124t", FRIENDS_TEXTURE_DND)..notOnlineNum--不在线, 人数
    text= text..'  '..format("\124T%s.tga:0\124t", FRIENDS_TEXTURE_AFK)..afkNum--AFK
    text= text..'  |A:deathrecap-icon-tombstone:0:0|a'..deadNum--死亡
    RaidFrame.groupInfoLable:SetText(text)
    WoWTools_UnitMixin:GetNotifyInspect(getItemLevelTab)--取得装等
end























local function set_WhoList_Update()--查询, 名单列表
    if not WhoFrame.ScrollBox:GetView() then
        return
    end
    local maxLevel= GetMaxLevelForLatestExpansion()
    for _, btn in pairs(WhoFrame.ScrollBox:GetFrames()) do
        if not btn.setOnDoubleClick then
            btn:SetScript('OnDoubleClick', function()
                if WhoFrameGroupInviteButton:IsEnabled() then
                    WhoFrameGroupInviteButton:Click()
                end
            end)
            btn:HookScript('OnClick', function()
                if WhoFrameAddFriendButton:IsEnabled() and IsAltKeyDown() then
                    WhoFrameAddFriendButton:Click()
                    C_Timer.After(1, function() WoWTools_Mixin:Call(WhoList_Update) end)
                end
            end)
            btn:HookScript('OnEnter', function(self)--FriendsFrame.lua
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                local index= self.index
                local info = index and C_FriendList.GetWhoInfo(index)
                if info and info.fullName then
                    GameTooltip:AddLine((info.gender==2 and '|A:charactercreate-gendericon-male-selected:0:0|a' or info.gender==3 and '|A:charactercreate-gendericon-female-selected:0:0|a' or format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toRight))
                                ..(WoWTools_UnitMixin:GetClassIcon(nil, info.filename) or '')
                                ..self.col
                                ..info.fullName
                                ..(WoWTools_UnitMixin:GetIsFriendIcon(info.fullName) or '')
                                ..(info.level and ' '..(info.level~=GetMaxLevelForLatestExpansion() and '|cnGREEN_FONT_COLOR:' or '')..info.level or '')
                            )
                    GameTooltip:AddLine('|A:UI-HUD-MicroMenu-GuildCommunities-GuildColor-Mouseover:0:0|a'..self.col..(info.fullGuildName or ''))
                    GameTooltip:AddLine('|A:groupfinder-waitdot:0:0|a'..self.col..(info.raceStr or ''))
                    GameTooltip:AddLine('|A:poi-islands-table:0:0|a'..self.col..(info.area or ''))
                end

                GameTooltip:AddLine(' ')
                GameTooltip:AddDoubleLine(self.col..'index', self.index)
                GameTooltip:AddDoubleLine(self.col..(WoWTools_Mixin.onlyChinese and '组队邀请' or GROUP_INVITE), (WoWTools_Mixin.onlyChinese and '双击' or BUFFER_DOUBLE)..WoWTools_DataMixin.Icon.left)
                GameTooltip:AddDoubleLine(self.col..(WoWTools_Mixin.onlyChinese and '添加好友' or ADD_FRIEND), 'Alt+'..WoWTools_DataMixin.Icon.left)
                GameTooltip:AddLine(' ')
                GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, addName)
                GameTooltip:Show()
            end)
            btn.setOnDoubleClick= true
        end
        btn.tooltip1=nil
        btn.tooltip2=nil

        local info= btn.index and C_FriendList.GetWhoInfo(btn.index)
        local r,g,b,level, hex
        if info then
            if RAID_CLASS_COLORS[info.filename] then
                r,g,b= RAID_CLASS_COLORS[info.filename]:GetRGB()
                hex= RAID_CLASS_COLORS[info.filename]:GenerateHexColor()
                local class=  WoWTools_UnitMixin:GetClassIcon(nil, info.filename)
                if class and btn.Class then
                    btn.Class:SetText(class)
                end
            end
           level= info.level
        end
        btn.col= hex and '|c'..hex or ''
        if r and g and b then
            if btn.Name and info.fullName then
                if info.fullName== WoWTools_DataMixin.Player.Name then
                    btn.Name:SetText(format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toRight)..(WoWTools_Mixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)..format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toLeft))
                else
                    local nameText= WoWTools_UnitMixin:GetIsFriendIcon(info.fullName)--检测, 是否好友
                    if nameText then
                        nameText= nameText..info.fullName
                        if info.fullName== WoWTools_DataMixin.Player.Name then
                            nameText= nameText..'|A:auctionhouse-icon-favorite:0:0|a'
                        end
                        btn.Name:SetText(nameText)
                    end
                end
                btn.Name:SetTextColor(r,g,b)
            end
            if btn.Variable then
                btn.Variable:SetTextColor(r,g,b)
            end
            if btn.Level then
                if level==0 or level== maxLevel then
                    btn.Level:SetTextColor(r,g,b)
                    btn.Level:SetText('')
                else
                    btn.Level:SetTextColor(0,1,0)
                end
            end
        end
    end
end



















--######
--初始化
--######
local function Init()--FriendsFrame.lua
    BNToastFrame:ClearAllPoints()
    BNToastFrame:SetPoint('BOTTOMLEFT', QuickJoinToastButton, 'TOPLEFT')

    Init_FriendsList()--好友列表, 模块
    hooksecurefunc('FriendsFrame_UpdateFriendButton', Set_FriendsFrame_UpdateFriendButton)--好友PLUS

    set_QuinkJoin_Init()--快速加入, 模块


    hooksecurefunc('WhoList_Update', set_WhoList_Update)
    hooksecurefunc(WhoFrame.ScrollBox, 'SetScrollTargetOffset', set_WhoList_Update)

    --团队，团队信息 RaidFrame.xml
    hooksecurefunc('RaidInfoFrame_InitButton', function(btn, elementData)
        if not btn:IsVisible() then
            return
        end
        local index = elementData.index;
        local text
        if elementData.isInstance then
            local _, _, _, _, locked, extended, _, _, _, _, numEncounters, encounterProgress = GetSavedInstanceInfo(index)
            if numEncounters and encounterProgress then
                local num
                num= numEncounters- encounterProgress
                num= num<0 and 0 or num
                if not (extended or locked) then
                    text= '|cff9e9e9e'..num..'/'..numEncounters..'|r'
                elseif num==0 then
                    text= '|cnRED_FONT_COLOR:'..num..'/'..numEncounters..'|r'
                else
                    text= '|cnGREEN_FONT_COLOR:'..num..'|r/'..numEncounters
                end
                if extended or locked then
                    local t=''
                    for j=1,numEncounters do
                        local isKilled = select(3, GetSavedInstanceEncounterInfo(index,j))
                        t= t..(isKilled and '|A:common-icon-redx:0:0|a' or format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.select))
                    end
                    text= t..' '..text
                end
            end
        end
        if text and not btn.tipsLabel then
            btn.tipsLabel= WoWTools_LabelMixin:Create(btn, {justifyH='RIGHT'})
            btn.tipsLabel:SetPoint('BOTTOMRIGHT', -52,1)
        end
        if btn.tipsLabel then
            btn.tipsLabel:SetText(text or '')
        end
    end)

    FriendsFrameStatusDropdown:SetSize(58, 25)--原生，有点问题
end









local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            if WoWToolsSave['FriendsList_lua'] then
                Save= WoWToolsSave['FriendsList_lua']
                WoWToolsSave['FriendsList_lua']= nil
            else
                Save= WoWToolsSave['Plus_FriendsList'] or Save
            end
            addName= '|A:socialqueuing-icon-group:0:0|a'..(WoWTools_Mixin.onlyChinese and '好友列表' or FRIENDS_LIST)

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= addName,
                GetValue= function() return not Save.disabled end,
                SetValue= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(WoWTools_DataMixin.Icon.icon2.. addName, WoWTools_TextMixin:GetEnabeleDisable(not Save.disabled), WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if Save.disabled then
                self:UnregisterEvent(event)
            else
                OptionText= (WoWTools_Mixin.onlyChinese and '设置' or SETTINGS).."|T%s:0:|t %s"
                RegionNames = {
                    [1] = WoWTools_Mixin.onlyChinese and '北美' or NORTH_AMERICA,
                    [2] = WoWTools_Mixin.onlyChinese and '韩国' or KOREA,
                    [3] = WoWTools_Mixin.onlyChinese and '欧洲' or EUROPE,
                    [4] = WoWTools_Mixin.onlyChinese and '台湾' or TAIWAN,
                    [5] = WoWTools_Mixin.onlyChinese and '中国' or CHINA,
                }
                Init()

                self:RegisterEvent('SOCIAL_QUEUE_UPDATE')
            end

        elseif arg1=='Blizzard_RaidUI' then

            hooksecurefunc('RaidGroupFrame_Update', Init_RaidGroupFrame_Update)--团队, 模块

            RaidFrame:HookScript('OnUpdate', function(frame, elapsed)
                frame.elapsed= (frame.elapsed or 1) + elapsed
                if frame.elapsed>1 then
                    frame.elapsed=0
                    if not UnitAffectingCombat('player') then
                        WoWTools_Mixin:Call(RaidGroupFrame_Update)
                    end
                end
            end)

        end

    elseif event=='SOCIAL_QUEUE_UPDATE' then
        set_SOCIAL_QUEUE_UPDATE()

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_FriendsList']=Save
        end
    end
end)