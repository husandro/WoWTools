local id, e = ...
local addName= FRIENDS_LIST
local Save={
        Friends={},
        --disabledBNFriendInfo=true,--禁用战网，好友信息，提示
        --allFriendInfo= true,--所有，提示，WoW，好友，提示
        --showInCombatFriendInfo,--仅限，不在战斗中，好友，提示
    }
local panel=CreateFrame("Frame")










--#############
--快速加入, 模块
--#############
local function set_SOCIAL_QUEUE_UPDATE()--更新, 快速加入
    if QuickJoinToastButton then
        if not QuickJoinToastButton.quickJoinText then
            QuickJoinToastButton.quickJoinText= e.Cstr(QuickJoinToastButton, {color=true})--:CreateFontString()
            --QuickJoinToastButton.quickJoinText:SetFontObject('NumberFontNormal')
            QuickJoinToastButton.quickJoinText:SetPoint('TOPRIGHT', -6, -3)
            if e.Player.useColor then
                QuickJoinToastButton.FriendCount:SetTextColor(e.Player.useColor.r, e.Player.useColor.g, e.Player.useColor.b)
            end
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
                local raceTexture=e.GetUnitRaceInfo({unit=nil, guid=guid, race=race, sex=sex , reAtlas=false})
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
                        e.tips:SetOwner(self2, "ANCHOR_LEFT")
                        e.tips:ClearLines()
                        e.tips:AddDoubleLine(e.onlyChinese and '/密语' or SLASH_SMART_WHISPER2, self2.col..self2.name)
                        e.tips:AddLine(' ')
                        e.tips:AddDoubleLine(id, e.cn(addName))
                        e.tips:Show()
                    end)
                    nameObj:SetScript('OnMouseDown',function(self2)
                        e.Say(nil, self2.name, self2.guid2 and C_BattleNet.GetGameAccountInfoByGUID(self2.guid))
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
            frame.roleTips= e.Cstr(frame)
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
        local link= leaderGUID and e.GetPlayerInfo({guid=leaderGUID, reName=true, reRealm=true, reLink=true,})
        if link and not self.nameInfo then
            self.nameInfo= e.Cstr(self)
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
            print(id, e.cn(addName),
                    tank2 and INLINE_TANK_ICON, healer2 and INLINE_HEALER_ICON, dps2 and INLINE_DAMAGER_ICON,
                    e.GetEnabeleDisable(false)..'Alt',
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


















--#############
--好友列表, 模块
--#############
local function set_FriendsList_Init()--好友列表, 初始化
    Save.Friends[e.Player.name_realm]=Save.Friends[e.Player.name_realm] or {}

    local regionNames = {
        [1] = e.onlyChinese and '北美' or NORTH_AMERICA,
        [2] = e.onlyChinese and '韩国' or KOREA,
        [3] = e.onlyChinese and '欧洲' or EUROPE,
        [4] = e.onlyChinese and '台湾' or TAIWAN,
        [5] = e.onlyChinese and '中国' or CHINA,
    };

    panel.btn= e.Cbtn(FriendsFrameStatusDropDownButton, {size={20,20}})
    panel.btn:RegisterEvent('BN_FRIEND_INFO_CHANGED')
    panel.btn.playerRealmID = GetRealmID()
    panel.btn:SetScript('OnEvent', function(self, _, friendIndex)
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
                not Save.allFriendInfo
                and accountInfo.gameAccountInfo.isOnline
                and (
                        accountInfo.gameAccountInfo.clientProgram ~= BNET_CLIENT_WOW
                        or accountInfo.gameAccountInfo.wowProjectID ~= WOW_PROJECT_ID
                        or not accountInfo.gameAccountInfo.isInCurrentRegion
                    )
                )
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

        if accountInfo.gameAccountInfo.characterLevel and accountInfo.gameAccountInfo.characterLevel>0 and accountInfo.gameAccountInfo.characterLevel~= MAX_PLAYER_LEVEL then--角色等级
            text= text..'|cnGREEN_FONT_COLOR:'..accountInfo.gameAccountInfo.characterLevel..'|r '
        end

        if accountInfo.gameAccountInfo.isOnline and accountInfo.gameAccountInfo.clientProgram == BNET_CLIENT_WOW then
            if accountInfo.gameAccountInfo.wowProjectID == WOW_PROJECT_ID  and accountInfo.gameAccountInfo.isInCurrentRegion then
                text= text..e.GetPlayerInfo({
                            guid=accountInfo.gameAccountInfo.playerGuid,
                            reLink= accountInfo.gameAccountInfo.factionName==e.Player.faction,
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
            if accountInfo.gameAccountInfo.regionID and regionNames[accountInfo.gameAccountInfo.regionID] then
                text= text..' |cnRED_FONT_COLOR:'..regionNames[accountInfo.gameAccountInfo.regionID]..'|r'
            end
        elseif accountInfo.gameAccountInfo.clientProgram == BNET_CLIENT_WOW and accountInfo.gameAccountInfo.wowProjectID ~= WOW_PROJECT_ID then
            text= text..' |cnRED_FONT_COLOR:CLASSIC'..accountInfo.gameAccountInfo.wowProjectID..'|r'
        end

        local infoText
        local function ShowRichPresenceOnly(client, wowProjectID, faction, realmID)
            if (client ~= BNET_CLIENT_WOW) or (wowProjectID ~= WOW_PROJECT_ID) then
                return true;
            elseif (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) and ((faction ~= e.Player.faction) or (realmID ~= self.playerRealmID)) then
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
                        return format(e.onlyChinese and '|A:recruitafriend_V2_tab_icon:0:0|a|cffffd200招募的战友：|r %s' or RAF_RECRUIT_FRIEND, locationText);
                    else
                        return format(e.onlyChinese and '|A:recruitafriend_V2_tab_icon:0:0|acffffd200招募者：|r %s' or RAF_RECRUITER_FRIEND, locationText);
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

    --#######
    --好友列表
    --#######
    local optionText= (e.onlyChinese and '设置' or SETTINGS).."|T%s:0:|t %s"
    local function set_Status()
        if not BNConnected() then
            return
        end
        local bnetAFK, bnetDND= select(5, BNGetInfo())
        if Save.Friends[e.Player.name_realm].Availabel then
            if bnetAFK or bnetDND then
                BNSetAFK(false)
                BNSetDND(false)
                print(id, e.cn(addName), format(optionText, FRIENDS_TEXTURE_ONLINE, e.onlyChinese and '有空' or FRIENDS_LIST_AVAILABLE))
            end
            panel.btn:SetNormalTexture(FRIENDS_TEXTURE_ONLINE)

        elseif Save.Friends[e.Player.name_realm].Away then
            if not bnetAFK then
                BNSetAFK(true)
                print(id, e.cn(addName), format(optionText, FRIENDS_TEXTURE_AFK, e.onlyChinese and '离开' or FRIENDS_LIST_AWAY))
            end
            panel.btn:SetNormalTexture(FRIENDS_TEXTURE_AFK)

        elseif Save.Friends[e.Player.name_realm].DND then
            if not bnetDND then
                BNSetDND(true)
                print(id, e.cn(addName), format(optionText, FRIENDS_TEXTURE_DND, e.onlyChinese and '忙碌' or FRIENDS_LIST_BUSY))
                panel.btn:SetNormalTexture(FRIENDS_TEXTURE_DND)
            end

        else
            panel.btn:SetNormalAtlas(e.Icon.icon)
        end
    end
    set_Status()
    panel.btn:SetPoint('LEFT', FriendsFrameStatusDropDownButton, 'RIGHT',0,-2)
    panel.btn:SetScript('OnMouseDown', function(self)
        if not BNConnected() then
            print(id, e.cn(addName), e.Icon.net2, e.onlyChinese and '断开战网' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SOCIAL_TWITTER_DISCONNECT, COMMUNITY_COMMAND_BATTLENET))
            return
        end
        if not self.menu then
            self.menu= CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
            local function Init_Status_Menu(_, level, menuList)
                local info
                if menuList=='OnlyWOWFriendInfo' then
                    info={
                        text= format(e.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, 'WoW'..format('|T%d:0|t', e.Icon.wow)..(e.onlyChinese and '好友' or FRIEND)),
                        disabled= Save.disabledBNFriendInfo,
                        checked= not Save.allFriendInfo,
                        keepShownOnClick=true,
                        func= function()
                            Save.allFriendInfo= not Save.allFriendInfo and true or nil
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)

                    info={
                        text= format(e.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, (e.onlyChinese and '不在战斗中' or LEAVE..'('..COMBAT..')')),
                        disabled= Save.disabledBNFriendInfo,
                        checked= not Save.showInCombatFriendInfo,
                        keepShownOnClick=true,
                        func= function()
                            Save.showInCombatFriendInfo= not Save.showInCombatFriendInfo and true or nil
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                    return

                elseif menuList=='PlayerList' then--玩家，列表
                    local find
                    for name, tab in pairs(Save.Friends) do
                        if name~=e.Player.name_realm and (tab.Availabel or tab.Away or tab.DND) then
                            info={
                                text= name..' '
                                    ..(tab.Availabel and  optionText:format(FRIENDS_TEXTURE_ONLINE, e.onlyChinese and '有空' or FRIENDS_LIST_AVAILABLE) or '')
                                    ..(tab.Away and  optionText:format(FRIENDS_TEXTURE_AFK, e.onlyChinese and '离开' or FRIENDS_LIST_AWAY) or '' )
                                    ..(tab.DND and optionText:format(FRIENDS_TEXTURE_DND, e.onlyChinese and '忙碌' or FRIENDS_LIST_BUSY) or ''),
                                notCheckable= true,
                                tooltipOnButton=true,
                                tooltipTitle= e.onlyChinese and '移除' or REMOVE,
                                arg1= name,
                                func= function(_, arg1)
                                    Save.Friends[arg1]= {}
                                end,
                            }
                            e.LibDD:UIDropDownMenu_AddButton(info, level)
                            find=true
                        end
                    end
                    if not find then
                        e.LibDD:UIDropDownMenu_AddButton({text= e.onlyChinese and '无' or NONE, isTitle=true, notCheckable=true}, level)
                    end
                    return
                end

                info= {
                    text = optionText:format(FRIENDS_TEXTURE_ONLINE, e.onlyChinese and '有空' or FRIENDS_LIST_AVAILABLE),
                    checked= Save.Friends[e.Player.name_realm].Availabel,
                    tooltipOnButton=true,
                    tooltipTitle= e.onlyChinese and '登入(游戏)' or (LOG_IN..' ('..GAME..')'),
                    tooltipText=id..' '..e.cn(addName),
                    func=function()
                        Save.Friends[e.Player.name_realm].Availabel = not Save.Friends[e.Player.name_realm].Availabel and true or nil
                        Save.Friends[e.Player.name_realm].Away= nil
                        Save.Friends[e.Player.name_realm].DND= nil
                        set_Status()
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)

                info= {
                    text = optionText:format(FRIENDS_TEXTURE_AFK, e.onlyChinese and '离开' or FRIENDS_LIST_AWAY),
                    checked= Save.Friends[e.Player.name_realm].Away,
                    tooltipOnButton=true,
                    tooltipTitle= e.onlyChinese and '登入(游戏)' or (LOG_IN..' ('..GAME..')'),
                    tooltipText=id..' '..e.cn(addName),
                    func=function()
                        Save.Friends[e.Player.name_realm].Availabel = nil
                        Save.Friends[e.Player.name_realm].Away= not Save.Friends[e.Player.name_realm].Away and true or nil
                        Save.Friends[e.Player.name_realm].DND=nil
                        set_Status()
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)

                info= {
                    text = optionText:format(FRIENDS_TEXTURE_DND, e.onlyChinese and '忙碌' or FRIENDS_LIST_BUSY),
                    checked= Save.Friends[e.Player.name_realm].DND,
                    tooltipOnButton=true,
                    tooltipTitle= e.onlyChinese and '登入(游戏)' or (LOG_IN..' ('..GAME..')'),
                    tooltipText=id..' '..e.cn(addName),
                    func=function()
                        Save.Friends[e.Player.name_realm].Availabel = nil
                        Save.Friends[e.Player.name_realm].Away=nil
                        Save.Friends[e.Player.name_realm].DND= not Save.Friends[e.Player.name_realm].DND and true or nil
                        set_Status()
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)

                info={
                    text= e.onlyChinese and '无' or NONE,
                    func= function()
                        Save.Friends[e.Player.name_realm].Availabel = nil
                        Save.Friends[e.Player.name_realm].Away= nil
                        Save.Friends[e.Player.name_realm].DND= nil
                        set_Status()
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)

                --e.LibDD:UIDropDownMenu_AddSeparator(level)
                info={
                    text=e.onlyChinese and '其他玩家' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTINGS_CATEGORY_TITLE_MISC, PLAYER) ,
                    notCheckable=true,
                    hasArrow=true,
                    menuList='PlayerList',
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)

                e.LibDD:UIDropDownMenu_AddSeparator(level)
                info={
                    text=  e.Icon.net2..(e.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET)..' ('..(e.onlyChinese and '好友' or FRIEND)..') '..( e.onlyChinese and '信息' or INFO)..'|A:communities-icon-chat:0:0|a',
                    checked= not Save.disabledBNFriendInfo,
                    hasArrow=true,
                    menuList= 'OnlyWOWFriendInfo',
                    --keepShownOnClick=true,
                    func= function()
                        Save.disabledBNFriendInfo= not Save.disabledBNFriendInfo and true or nil
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)

                info={
                    text= '|A:Battlenet-ClientIcon-App:0:0|a'..(e.onlyChinese and '好友' or FRIEND)..' Plus',
                    checked= not Save.disabledFriendPlus,
                    keepShownOnClick=true,
                    func= function()
                        Save.disabledFriendPlus= not Save.disabledFriendPlus and true or nil
                        print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabledFriendPlus), e.onlyChinese and '需求刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH))
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
            e.LibDD:UIDropDownMenu_Initialize(self.menu, Init_Status_Menu, 'MENU')
        end
        e.LibDD:ToggleDropDownMenu(1, nil, self.menu, self, 15,0)
    end)


    hooksecurefunc('FriendsFrame_UpdateFriendButton', function(self)--FriendsFrame.lua
        if Save.disabledFriendPlus then
            return
        end

        if self.buttonType == FRIENDS_BUTTON_TYPE_WOW then
            local info = C_FriendList.GetFriendInfoByIndex(self.id)
            if not info or not info.guid then
                return
            end
            local text=e.GetPlayerInfo({guid=info.guid})
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
                if accountInfo.gameAccountInfo.regionID and regionNames[accountInfo.gameAccountInfo.regionID] then
                    self.info:SetText('|cnRED_FONT_COLOR:'..regionNames[accountInfo.gameAccountInfo.regionID])
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

            if accountInfo.gameAccountInfo.characterLevel and accountInfo.gameAccountInfo.characterLevel>0 and accountInfo.gameAccountInfo.characterLevel~= MAX_PLAYER_LEVEL then--角色等级
                text= text..'|cnGREEN_FONT_COLOR:'..accountInfo.gameAccountInfo.characterLevel..'|r '
            end
            text= text.. e.GetPlayerInfo({guid=accountInfo.gameAccountInfo.playerGuid, reName=true, reRealm=true, faction=accountInfo.gameAccountInfo.factionName })

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
                    if name==e.Player.name then--自己
                        text= e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME
                    end
                    if not text then--距离
                        local distance, checkedDistance = UnitDistanceSquared(unit)
                        if checkedDistance then
                            if distance and distance > DISTANCE_THRESHOLD_SQUARED then
                                text= e.GetUnitMapName(unit)--单位, 地图名称
                                if text then
                                    text= '|A:poi-islands-table:0:0|a|cnGREEN_FONT_COLOR:'..text..'|r'
                                end
                            end
                        end
                    end

                    text= text or e.PlayerOnlineInfo(unit)--状态

                    if not text and not setSize then--处理名字
                        text= name:gsub('(%-.+)','')--名称
                        text= e.WA_Utf8Sub(text, 3, 7)
                    end
                    if text then
                        subframes.name:SetText(text)
                    end
                end

                if subframes.class and fileName then
                    local text
                    if e.UnitItemLevel[guid] and e.UnitItemLevel[guid].specID then
                        local texture= select(4, GetSpecializationInfoForSpecID(e.UnitItemLevel[guid].specID))
                        if texture then
                            text= "|T"..texture..':0|t'
                        end
                    end
                    text= text or e.Class(nil, fileName)--职业图标

                    if text then
                        if guid and e.UnitItemLevel[guid] and e.UnitItemLevel[guid].itemLevel then
                            text= e.UnitItemLevel[guid].itemLevel..text
                            itemLevel= itemLevel+ e.UnitItemLevel[guid].itemLevel
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

                if subframes.level and level==MAX_PLAYER_LEVEL then
                    subframes.level:SetText(e.GetUnitRaceInfo({unit=unit, guid=guid, race=nil, sex=nil, reAtlas=false}) or '')
                end
            end
        end
    end
    if not RaidFrame.groupInfoLable then
        RaidFrame.groupInfoLable= e.Cstr(RaidFrame, {copyFont=FriendsFrameTitleText, justifyH='CENTER'})
        RaidFrame.groupInfoLable:SetPoint('BOTTOM',FriendsFrame.TitleContainer, 'TOP')
    end
    local text= '|A:charactercreate-gendericon-male-selected:0:0|a'..(itemNum==0 and 0 or format('%i',itemLevel/itemNum))
    text= text..'  |cnGREEN_FONT_COLOR:'..itemNum..'|r/'..GetNumGroupMembers()..'|cnRED_FONT_COLOR:'--人数
    text= text..'  '..format("\124T%s.tga:0\124t", FRIENDS_TEXTURE_DND)..notOnlineNum--不在线, 人数
    text= text..'  '..format("\124T%s.tga:0\124t", FRIENDS_TEXTURE_AFK)..afkNum--AFK
    text= text..'  |A:deathrecap-icon-tombstone:0:0|a'..deadNum--死亡
    RaidFrame.groupInfoLable:SetText(text)
    e.GetNotifyInspect(getItemLevelTab)--取得装等
end























local function set_WhoList_Update()--查询, 名单列表
    if not WhoFrame.ScrollBox:GetView() then
        return
    end
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
                    C_Timer.After(1, function() e.call('WhoList_Update') end)
                end
            end)
            btn:HookScript('OnEnter', function(self)--FriendsFrame.lua
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                local index= self.index
                local info = index and C_FriendList.GetWhoInfo(index)
                if info and info.fullName then
                    e.tips:AddLine((info.gender==2 and '|A:charactercreate-gendericon-male-selected:0:0|a' or info.gender==3 and '|A:charactercreate-gendericon-female-selected:0:0|a' or format('|A:%s:0:0|a', e.Icon.toRight))
                                ..(e.Class(nil, info.filename) or '')
                                ..self.col
                                ..info.fullName
                                ..(e.GetFriend(info.fullName) or '')
                                ..(info.level and ' '..(info.level~=MAX_PLAYER_LEVEL and '|cnGREEN_FONT_COLOR:' or '')..info.level or '')
                            )
                    e.tips:AddLine('|A:UI-HUD-MicroMenu-GuildCommunities-GuildColor-Mouseover:0:0|a'..self.col..(info.fullGuildName or ''))
                    e.tips:AddLine('|A:groupfinder-waitdot:0:0|a'..self.col..(info.raceStr or ''))
                    e.tips:AddLine('|A:poi-islands-table:0:0|a'..self.col..(info.area or ''))
                end

                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(self.col..'index', self.index)
                e.tips:AddDoubleLine(self.col..(e.onlyChinese and '组队邀请' or GROUP_INVITE), (e.onlyChinese and '双击' or BUFFER_DOUBLE)..e.Icon.left)
                e.tips:AddDoubleLine(self.col..(e.onlyChinese and '添加好友' or ADD_FRIEND), 'Alt+'..e.Icon.left)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(id, e.cn(addName))
                e.tips:Show()
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
                local class=  e.Class(nil, info.filename)
                if class and btn.Class then
                    btn.Class:SetText(class)
                end
            end
           level= info.level
        end
        btn.col= hex and '|c'..hex or ''
        if r and g and b then
            if btn.Name and info.fullName then
                if info.fullName== e.Player.name then
                    btn.Name:SetText(format('|A:%s:0:0|a', e.Icon.toRight)..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)..format('|A:%s:0:0|a', e.Icon.toLeft))
                else
                    local nameText= e.GetFriend(info.fullName)--检测, 是否好友
                    if nameText then
                        nameText= nameText..info.fullName
                        if info.fullName== e.Player.name then
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
                if level==0 or level== MAX_PLAYER_LEVEL then
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
    set_QuinkJoin_Init()--快速加入, 模块
    set_FriendsList_Init()--好友列表, 模块
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
                    text= '|cff606060'..num..'/'..numEncounters..'|r'
                elseif num==0 then
                    text= '|cnRED_FONT_COLOR:'..num..'/'..numEncounters..'|r'
                else
                    text= '|cnGREEN_FONT_COLOR:'..num..'|r/'..numEncounters
                end
                if extended or locked then
                    local t=''
                    for j=1,numEncounters do
                        local isKilled = select(3, GetSavedInstanceEncounterInfo(index,j))
                        t= t..(isKilled and '|A:common-icon-redx:0:0|a' or format('|A:%s:0:0|a', e.Icon.select))
                    end
                    text= t..' '..text
                end
            end
        end
        if text and not btn.tipsLabel then
            btn.tipsLabel= e.Cstr(btn, {justifyH='RIGHT'})
            btn.tipsLabel:SetPoint('BOTTOMRIGHT', -52,1)
        end
        if btn.tipsLabel then
            btn.tipsLabel:SetText(text or '')
        end
    end)
end












--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('SOCIAL_QUEUE_UPDATE')--快速加入

panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板
            e.AddPanel_Check({
                name= '|A:socialqueuing-icon-group:0:0|a'..(e.onlyChinese and '好友列表' or addName),
                tooltip= e.cn(addName),
                value= not Save.disabled,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            --[[添加控制面板        
            local sel=e.AddPanel_Check('|A:socialqueuing-icon-group:0:0|a'..(e.onlyChinese and '好友列表' or addName), not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                if Save.disabled then
                    Save.disabled=nil
                else
                    Save.disabled=true
                end
                print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)]]

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_RaidUI' then
            hooksecurefunc('RaidGroupFrame_Update', Init_RaidGroupFrame_Update)--团队, 模块
            RaidFrame:HookScript('OnUpdate', function(frame, elapsed)
                frame.elapsed= (frame.elapsed or 1) + elapsed
                if frame.elapsed>1 then
                    frame.elapsed=0
                    if not UnitAffectingCombat('player') then
                        e.call('RaidGroupFrame_Update')
                    end
                end
            end)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='SOCIAL_QUEUE_UPDATE' then--更新, 快速加入
        set_SOCIAL_QUEUE_UPDATE()


    end

end)
