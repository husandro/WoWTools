local id, e= ...
local addName= BUTTON_LAG_MAIL
local Save={
    --hide=true,--隐藏

    lastSendPlayerList= {},--历史记录, {'名字-服务器',},
    --hideSendPlayerList=true,--隐藏，历史记录
    lastMaxSendPlayerList=20,--记录, 最大数
    --lastSendPlayer='Fuocco-server',--记录 SendMailNameEditBox，内容

    show={--显示离线成员
        ['FRIEND']=true,--好友
        --['GUILD']=true,--公会
    },

    fast={},--快速，加载，物品，指定玩家
    fastShow=true,--显示/隐藏，快速，加载，按钮
    --CtrlFast= e.Player.husandro,--Ctrl+RightButton,快速，加载，物品
    --scaleSendPlayerFrame=1.2,--清除历史数据，缩放

    scaleFastButton=1.25,

    --INBOXITEMS_TO_DISPLAY=7,
}







local size=23--图标大小
local panel= CreateFrame("Frame")
local button
local Initializer

















local function set_Text_SendMailNameEditBox(_, name)--设置，发送名称，文
    if name then
        name= name:gsub('%-'..e.Player.realm, '')
        SendMailNameEditBox:SetText(name)
        SendMailNameEditBox:SetCursorPosition(0)
        SendMailNameEditBox:ClearFocus()
        C_Timer.After(0.5, function()
            if SendMailSubjectEditBox:GetText()=='' then
                SendMailSubjectEditBox:SetText(e.Player.region==5 and '你好' or EMOTE56_CMD1:gsub('/',''))
                SendMailSubjectEditBox:SetCursorPosition(0)
                SendMailSubjectEditBox:ClearFocus()
            end
        end)
    end
end

local function get_Name_Info(name)--取得名称，信息
    if name then
        local reName
        name = e.GetUnitName(name)
        for guid, tab in pairs(e.WoWDate or {}) do
            if name== e.GetUnitName(nil, nil, guid) then
                reName= '|A:auctionhouse-icon-favorite:0:0|a'..e.GetPlayerInfo({guid=guid, faction=tab.faction, reName=true, realm=true})
                break
            end
        end
        reName= reName or e.GetPlayerInfo({name=name, reName=true, reRealm=true})
        return reName and reName:gsub('%-'..e.Player.realm, '') or name
    end
end

























--#######
--设置菜单
--#######
local function Init_Menu(_, level, menuList)
    local info
    if menuList=='SELF' then
        local find
        for guid, _ in pairs(e.WoWDate) do
            if guid and guid~= e.Player.guid then
                info={
                    text= e.GetPlayerInfo({guid=guid, reName=true, reRealm=true}),
                    icon= 'auctionhouse-icon-favorite',
                    keepShownOnClick= true,
                    notCheckable= true,
                    arg1= e.GetUnitName(nil, nil, guid),
                    func= set_Text_SendMailNameEditBox,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
                find=true
            end
        end
        if not find then
            e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
        end

    elseif menuList=='FRIEND'  then
        local find
        for i=1 , C_FriendList.GetNumFriends() do
            local game=C_FriendList.GetFriendInfoByIndex(i)
            if game and game.guid and (game.connected or Save.show['FRIEND']) and not e.WoWDate[game.guid] then

                local text= e.GetPlayerInfo({guid=game.guid, reName=true, reRealm=true})--角色信息
                text= (game.level and game.level~=MAX_PLAYER_LEVEL and game.level>0) and text .. ' |cff00ff00'..game.level..'|r' or text--等级
                if game.area and game.connected then
                    text= text..' '..game.area
                elseif not game.connected then
                    text= text..' '..(e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)
                end

                info={
                    text=text,
                    icon= e.WoWDate[game.guid] and 'auctionhouse-icon-favorite',
                    notCheckable= true,
                    tooltipOnButton=true,
                    keepShownOnClick= true,
                    tooltipTitle=game.notes,
                    arg1= e.GetUnitName(nil, nil, game.guid),
                    func= set_Text_SendMailNameEditBox,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
                find=true
            end
        end
        if not find then
            e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE,
            icon= 'mechagon-projects',
            checked= Save.show['FRIEND'],
            tooltipOnButton= true,
            tooltipTitle= e.onlyChinese and '显示离线成员' or COMMUNITIES_MEMBER_LIST_SHOW_OFFLINE,
            tooltipText= e.GetEnabeleDisable(Save.show['FRIEND']),
            func= function()
                Save.show['FRIEND']= not Save.show['FRIEND'] and true or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif menuList=='WOW' then
        local find
        for i=1 ,BNGetNumFriends() do
            local wow= C_BattleNet.GetFriendAccountInfo(i);
            local wowInfo= wow and wow.gameAccountInfo
            if wowInfo
                and wowInfo.playerGuid
                and wowInfo.wowProjectID==1
                and wowInfo.isOnline
            then
                local name= e.GetUnitName(wowInfo.characterName, nil, wowInfo.playerGuid)

                local text= e.GetPlayerInfo({guid=wowInfo.playerGuid, reName=true, reRealm=true, factionName=wowInfo.factionName})--角色信息

                if wowInfo.characterLevel and wowInfo.characterLevel~=MAX_PLAYER_LEVEL and wowInfo.characterLevel>0 then--等级
                    text=text ..' |cff00ff00'..wowInfo.characterLevel..'|r'
                end
                if not wowInfo.isOnline then
                    text= text..' '..(e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)
                end

                info={
                    text= text,
                    icon= e.WoWDate[wowInfo.playerGuid] and 'auctionhouse-icon-favorite',
                    keepShownOnClick= true,
                    notCheckable=true,
                    tooltipOnButton=true,
                    tooltipTitle= wow and wow.note or '',
                    tooltipText= name,
                    arg1= name,
                    func= set_Text_SendMailNameEditBox,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
                find=true
            end
        end
        if not find then
            e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
        end

    elseif menuList=='GUILD' then
        local num=0
        for index=1, GetNumGuildMembers() do
            local name, rankName, rankIndex, lv, _, zone, publicNote, officerNote, isOnline, status, _, _, _, _, _, _, guid = GetGuildRosterInfo(index)
            if name and guid and (isOnline or rankIndex<2 or (Save.show['GUILD'] and num<60)) and not e.WoWDate[guid] then

                local text= e.GetPlayerInfo({guid=guid, reName=true, reRealm=true,})--角色信息

                text= (lv and lv~=MAX_PLAYER_LEVEL and lv>0) and text .. ' |cff00ff00'..lv..'|r' or text--等级
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
                info={
                    text=text,
                    icon=icon,
                    keepShownOnClick= true,
                    notCheckable=true,
                    tooltipOnButton=true,
                    tooltipTitle=publicNote or '',
                    tooltipText=officerNote or '',
                    arg1= name,
                    func= set_Text_SendMailNameEditBox,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
                num= num+1
            end
        end
        if num==0 then
            e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE,
            icon= 'mechagon-projects',
            checked= Save.show['GUILD'],
            tooltipOnButton= true,
            tooltipTitle= e.onlyChinese and '显示离线成员' or COMMUNITIES_MEMBER_LIST_SHOW_OFFLINE,
            tooltipText= e.GetEnabeleDisable(Save.show['GUILD']),
            func= function()
                Save.show['GUILD']= not Save.show['GUILD'] and true or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif menuList=='GROUP' then
        local find
        local u=  IsInRaid() and 'raid' or 'party'
        for i=1, GetNumGroupMembers() do
            local unit= u..i
            if UnitExists(unit) and not UnitIsUnit('player', unit) then
                local name= GetUnitName(unit, true)
                local text=  i..')'.. (i<10 and '  ' or ' ')..e.GetPlayerInfo({unit= unit, reName=true, reRealm=true})

                local lv= UnitLevel(unit)
                text= (lv and lv~=MAX_PLAYER_LEVEL and lv>0) and text .. ' |cff00ff00'..lv..'|r' or text--等级
                if not UnitIsConnected(unit) then
                    text= text..' '..(e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)
                end

                info={
                    text= text,
                    keepShownOnClick= true,
                    notCheckable=true,
                    tooltipOnButton=true,
                    tooltipTitle= name,
                    arg1= name,
                    func= set_Text_SendMailNameEditBox,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
                find= true
            end
        end
        if not find then
            e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
        end

    elseif menuList and type(menuList)=='number' then--社区
        local num=0
        local members= C_Club.GetClubMembers(menuList) or {}
        for index, memberID in pairs(members) do
            local tab = C_Club.GetMemberInfo(menuList, memberID) or {}
            if tab.guid and tab.name and (tab.zone or tab.role<4 or (Save.show[menuList] and num<60)) and not e.WoWDate[tab.guid] then
                local faction= tab.faction==Enum.PvPFaction.Alliance and 'Alliance' or tab.faction==Enum.PvPFaction.Horde and 'Horde'
                local  text= e.GetPlayerInfo({guid=tab.guid,  reName=true, reRealm=true, factionName=faction})--角色信息

                text= (tab.level and tab.level~=MAX_PLAYER_LEVEL and tab.level>0) and text .. ' |cff00ff00'..tab.level..'|r' or text--等级
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

                info={
                    text= index..(index<10 and ')  ' or ') ')..text.. (tab.zone and format('|A:%s:0:0|a', e.Icon.select) or ''),
                    icon= icon,
                    keepShownOnClick= true,
                    notCheckable=true,
                    tooltipOnButton=true,
                    tooltipTitle=tab.memberNote or '',
                    tooltipText=tab.officerNote,
                    arg1= tab.name,
                    func= set_Text_SendMailNameEditBox,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
                num= num+1
            end
        end
        if num==0 then
            e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE,
            icon= 'mechagon-projects',
            checked= Save.show[menuList],
            tooltipOnButton= true,
            tooltipTitle= e.onlyChinese and '显示离线成员' or COMMUNITIES_MEMBER_LIST_SHOW_OFFLINE,
            tooltipText= e.GetEnabeleDisable(Save.show[menuList]),
            func= function()
                Save.show[menuList]= not Save.show[menuList] and true or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    --[[elseif menuList=='SETTINGS' then
        info={
            text= 'Ctrl + '..e.Icon.right..' '..(e.onlyChinese and '多物品' or MAIL_MULTIPLE_ITEMS),
            checked= not Save.disableCtrlFast,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '备注：如果出现错误' or ('note: '..ERRORS..' ('..SHOW..')'),
            tooltipText= e.onlyChinese and '请禁用此功能' or DISABLE,
            func= function()
                Save.disableCtrlFast= not Save.disableCtrlFast and true or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)]]
    end

    if menuList then
        return
    end

    info={
        text= '|A:auctionhouse-icon-favorite:0:0|a'..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME),
        hasArrow= true,
        notCheckable=true,
        menuList= 'SELF',
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= e.Icon.net2..(e.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET),
        hasArrow= true,
        notCheckable=true,
        menuList= 'WOW',
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= '|A:groupfinder-icon-friend:0:0|a'..(e.onlyChinese and '好友' or FRIEND),
        hasArrow= true,
        notCheckable=true,
        menuList= 'FRIEND',
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)


    info={
        text= '|A:communities-guildbanner-background:0:0|a'..(e.onlyChinese and '公会' or GUILD),
        disabled= not IsInGuild(),
        hasArrow= true,
        notCheckable=true,
        menuList= 'GUILD',
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= '|A:UI-HUD-UnitFrame-Player-Group-GuideIcon-2x:0:0|a'..(e.onlyChinese and '队员' or PLAYERS_IN_GROUP),
        disabled= GetNumGroupMembers()<2,
        hasArrow= true,
        notCheckable=true,
        menuList= 'GROUP',
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
                menuList= tab.clubId,
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
    end

    --[[e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= e.onlyChinese and '设置' or SETTINGS,
        hasArrow=true,
        menuList='SETTINGS',
        notCheckable=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)]]

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= id..' '..Initializer:GetName(),
        icon= 'UI-HUD-Minimap-Mail-Mouseover',
        notCheckable= true,
        isTitle=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end





























local function Init_Button()
    if button then
        return
    end

    --下拉，菜单
    button= e.Cbtn(SendMailFrame, {size={size, size}, atlas='common-icon-rotateleft'})
    button:SetPoint('LEFT', SendMailNameEditBox, 'RIGHT')
    --[[if _G['SendMailNameEditBoxMiddle'] then
        button:SetPoint('LEFT', _G['SendMailNameEditBoxMiddle'] or SendMailNameEditBox, 'RIGHT', 6, 0)
    else
        button:SetPoint('LEFT', _G['Postal_BlackBookButton'] or SendMailNameEditBox, 'RIGHT', 2, 0)--C_AddOns.IsAddOnLoaded('Postal')
    end]]
    button:SetFrameStrata('HIGH')
    button:SetScript('OnMouseDown', function(self)
        if not self.Menu then
            self.Menu= CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
            e.LibDD:UIDropDownMenu_Initialize(self.Menu, Init_Menu, 'MENU')
        end
        e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
    end)
    button:RegisterEvent('MAIL_SEND_SUCCESS')--SendName，设置，发送成功，名字
    button:RegisterEvent('MAIL_FAILED')
    button:SetScript('OnEvent', function(self, event)
        if event=='MAIL_SEND_SUCCESS' then
            if self.SendName then--SendName，设置，发送成功，名字
                local find
                for index, name in pairs(Save.lastSendPlayerList) do
                    if name==self.SendName then
                        find= index
                        break
                    end
                end

                if find~=1 then
                    if find then
                        table.remove(Save.lastSendPlayerList, find)

                    elseif #Save.lastSendPlayerList>= Save.lastMaxSendPlayerList then
                        table.remove(Save.lastSendPlayerList )
                    end
                    table.insert(Save.lastSendPlayerList, 1, self.SendName)
                end

                self.ClearPlayerButton.set_showHidetips_Texture(self.ClearPlayerButton)--隐藏，历史记录, 提示, 设置图片
                self.ClearPlayerButton.Init_Player_List()--设置，历史记录，内容
                if not Save.hide and not Save.hideSendPlayerList then
                    set_Text_SendMailNameEditBox(nil, self.SendName)
                end

                self.SendName=nil
            end
            self.FastButton.get_Send_Max_Item()--能发送，数量
            self.FastButton.set_Fast_Event()--清除，注册，事件，显示/隐藏，设置数量

        elseif event=='MAIL_FAILED' then
            self.SendName=nil
        end
    end)


    --#########
    --目标，名称
    --#########
    button.GetTargetNameButton= e.Cbtn(button, {size={size,size}, icon='hide'})
    button.GetTargetNameButton:SetPoint('LEFT', button, 'RIGHT',2,2)
    button.GetTargetNameButton:SetScript('OnClick', function(self)
        if self.name then
            set_Text_SendMailNameEditBox(nil, self.name)
        end
    end)
    button.GetTargetNameButton:SetScript('OnLeave', GameTooltip_Hide)
    button.GetTargetNameButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(e.onlyChinese and '目标' or TARGET)
        e.tips:AddDoubleLine(GetUnitName('target', true), e.GetPlayerInfo({unit='target', reName=true, reRealm=true}))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:Show()
    end)
    button.GetTargetNameButton.set_GetTargetNameButton_Texture= function(self)
        if self then
            if UnitExists('target') and UnitIsPlayer('target') and not UnitIsUnit('player', 'target') then
                local name= GetUnitName('target', true)
                if name then
                    local atlas, texture
                    local index= GetRaidTargetIndex('target') or 0
                    if index>0 and index<9 then
                        texture= 'Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index
                    else
                        atlas= e.GetUnitRaceInfo({unit= 'target', reAtlas=true})
                    end
                    if texture then
                        self:SetNormalTexture(texture)
                    else
                        self:SetNormalAtlas(atlas or 'Adventures-Target-Indicator')
                    end
                    self:SetShown(true)
                    self.name=name
                    return
                end
            end
            self.name=nil
            self:SetShown(false)
        end
    end
    button.GetTargetNameButton:SetScript('OnEvent',  button.GetTargetNameButton.set_GetTargetNameButton_Texture)
    button.GetTargetNameButton.set_GetTargetNameButton_Texture(button.GetTargetNameButton)--目标，名称，按钮，显示/隐藏


    --#######
    --历史记录
    --#######
    button.ClearPlayerButton= e.Cbtn(button, {size={size,size}, atlas='bags-button-autosort-up'})
    button.ClearPlayerButton:SetPoint('RIGHT', SendMailNameEditBox, 'LEFT', -2, 0)
    button.ClearPlayerButton:SetText(not e.onlyChinese and SLASH_STOPWATCH_PARAM_STOP2 or "清除")
    button.ClearPlayerButton:SetScript('OnClick', function(self, d)
        if d=='LeftButton' and not IsModifierKeyDown() then
            SendMailNameEditBox:SetText('')
            e.call('SendMailFrame_Update')

        elseif IsAltKeyDown() and d=='LeftButton' then
            Save.lastSendPlayerList={}
            Save.lastSendPlayer=nil
            self.Init_Player_List()--设置，历史记录，内容
            self.set_showHidetips_Texture(self)--隐藏，历史记录, 提示, 设置图片
            print(id, Initializer:GetName(), e.onlyChinese and '记录' or EVENTTRACE_LOG_HEADER, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '全部清除' or CLEAR_ALL))
        end
    end)
    button.ClearPlayerButton:SetScript('OnMouseWheel', function(self, d)
        if IsAltKeyDown() then
            local num= Save.scaleSendPlayerFrame or 1
            if d==1 then
                num= num- 0.05
            elseif d==-1 then
                num= num+ 0.05
            end
            num= num<0.5 and 0.5 or num>2 and 2 or num
            print(id, Initializer:GetName(),e.onlyChinese and '缩放' or UI_SCALE, '|cnGREEN_FONT_COLOR:'..(Save.scaleSendPlayerFrame or 1) )
            Save.scaleSendPlayerFrame= num
            button.SendPlayerFrame:SetScale(num)

        elseif not IsModifierKeyDown() then--隐藏/显示
            Save.hideSendPlayerList= d==1 and true or nil
            button.SendPlayerFrame:SetShown(not Save.hideSendPlayerList and true or false)
            print(id, Initializer:GetName(), e.GetShowHide(not Save.hideSendPlayerList), '|cnGREEN_FONT_COLOR:'..#Save.lastSendPlayerList..' '..(e.onlyChinese and '记录' or EVENTTRACE_LOG_HEADER))
            self.set_showHidetips_Texture(self)--隐藏，历史记录, 提示, 设置图片
        end
    end)
    button.ClearPlayerButton:SetScript('OnLeave', function(self)
        e.tips:Hide()
        self.setAlpha(self)
        self:GetParent().SendPlayerFrame:SetAlpha(1)
    end)
    button.ClearPlayerButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, (e.onlyChinese and '收件人' or MAIL_TO_LABEL)..e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '全部清除' or CLEAR_ALL)..' |cnGREEN_FONT_COLOR:#'..#Save.lastSendPlayerList..'|r/'..Save.lastMaxSendPlayerList, '|cnGREEN_FONT_COLOR:Alt+'.. e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '记录' or EVENTTRACE_LOG_HEADER)..' '..(Save.hideSendPlayerList and '|A:AnimaChannel-Bar-Venthyr-Gem:0:0|a' or '|A:AnimaChannel-Bar-Necrolord-Gem:0:0|a')..e.GetShowHide(not Save.hideSendPlayerList), e.Icon.mid)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.scaleSendPlayerFrame or 1), 'Alt+'..e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:Show()
        self:SetAlpha(1)
        self:GetParent().SendPlayerFrame:SetAlpha(0.5)
    end)
    button.ClearPlayerButton.setAlpha= function(self)--设置，历史记录，清除按钮透明度
        self:SetAlpha(SendMailNameEditBox:GetText()=='' and 0.3 or 1)
    end
    button.ClearPlayerButton.setAlpha(button.ClearPlayerButton)--设置，历史记录，清除按钮透明度

    --隐藏/显示，历史记录, 提示
    button.ClearPlayerButton.showHidetips= button.ClearPlayerButton:CreateTexture(nil,'OVERLAY')
    button.ClearPlayerButton.showHidetips:SetSize(size/2,size/2)
    button.ClearPlayerButton.showHidetips:SetPoint('TOPLEFT')
    button.ClearPlayerButton.set_showHidetips_Texture= function(self)--隐藏，历史记录, 提示, 设置图片
        self.showHidetips:SetAtlas((Save.hideSendPlayerList or #Save.lastSendPlayerList==0) and 'AnimaChannel-Bar-Venthyr-Gem' or 'AnimaChannel-Bar-Necrolord-Gem')
    end
    button.ClearPlayerButton.set_showHidetips_Texture(button.ClearPlayerButton)--隐藏，历史记录, 提示, 设置图片

    --设置，历史记录，内容
    button.ClearPlayerButton.Init_Player_List= function()
        for index, name in pairs(Save.lastSendPlayerList) do
            local label= button.SendPlayerFrame.createdButton(index)
            label.name= name
            label:SetText(get_Name_Info(name)..' '..(index<10 and ' ' or '')..'|cnGREEN_FONT_COLOR:'..index..' ')
            label:SetShown(name~=e.Player.name_realm)
        end

        for index= #Save.lastSendPlayerList+1, #button.SendPlayerFrame.tab do
            button.SendPlayerFrame.tab[index]:SetShown(false)
            button.SendPlayerFrame.tab[index]:SetText('')
        end
    end

    --移动 收件人：字符
    local labelSend={SendMailNameEditBox:GetRegions()}
    labelSend=labelSend[3]
    if labelSend and labelSend:GetObjectType()=='FontString' then
        labelSend:ClearAllPoints()
        labelSend:SetPoint('RIGHT', button.ClearPlayerButton, 'LEFT')
    end

    --历史记录
    button.SendPlayerFrame= CreateFrame('Frame', nil, button)
    button.SendPlayerFrame:SetPoint('TOPRIGHT', SendMailFrame, 'TOPLEFT', 4, -40)
    button.SendPlayerFrame:SetSize(1,1)
    button.SendPlayerFrame:SetShown(not Save.hideSendPlayerList)
    button.SendPlayerFrame.tab={}
    button.SendPlayerFrame.createdButton= function(index)
        local label= button.SendPlayerFrame.tab[index]
        if not label then
            label= e.Cstr(button.SendPlayerFrame, {justifyH='RIGHT', mouse=true, size=16})
            label:SetPoint('TOPRIGHT', index==1 and button.SendPlayerFrame or button.SendPlayerFrame.tab[index-1], 'BOTTOMRIGHT')
            label:SetScript('OnMouseUp',function(self) self:SetAlpha(0.5) end)
            label:SetScript('OnMouseDown', function(self, d)
                if d=='LeftButton' then
                    set_Text_SendMailNameEditBox(nil, self.name)--设置，收件人，名字

                elseif d=='RightButton' then--移除，单个，名字
                    for i, name in pairs(Save.lastSendPlayerList) do
                        if name==self.name then
                            print(id, Initializer:GetName(), '|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|r', get_Name_Info(name))
                            table.remove(Save.lastSendPlayerList, i)
                            button.ClearPlayerButton.Init_Player_List()--设置，历史记录，内容
                            break
                        end
                    end
                end
                self:SetAlpha(0)
            end)
            label:SetScript('OnLeave', function(self)
                e.tips:Hide()
                self:SetAlpha(1)
                self:GetParent():GetParent().ClearPlayerButton:SetButtonState('NORMAL')
            end)
            label:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddLine(e.onlyChinese and '记录' or EVENTTRACE_LOG_HEADER)
                e.tips:AddLine(self:GetText()..e.Icon.left)
                e.tips:AddLine(' ')
                e.tips:AddLine((e.onlyChinese and '移除' or REMOVE)..e.Icon.right)
                e.tips:Show()
                self:SetAlpha(0.5)
                self:GetParent():GetParent().ClearPlayerButton:SetButtonState('PUSHED')
            end)
            table.insert(button.SendPlayerFrame.tab, label)
        end
        return label
    end

    button.ClearPlayerButton.Init_Player_List()--设置，历史记录，内容

    if Save.scaleSendPlayerFrame and Save.scaleSendPlayerFrame~=1 then
        button.SendPlayerFrame:SetScale(Save.scaleSendPlayerFrame)
    end

    --#########
    --提示，内容
    --MailFrameTitleText:SetText(e.onlyChinese and '发件箱' or SENDMAIL)
    SendMailNameEditBox.playerTipsLable= e.Cstr(button, {justifyH='CENTER', size=10})
    SendMailNameEditBox.playerTipsLable:SetPoint('BOTTOM', SendMailNameEditBox, 'TOP',0,-3)
    SendMailNameEditBox:HookScript('OnTextChanged', function(self)
        local name= e.GetUnitName(self:GetText())
        Save.lastSendPlayer= name or Save.lastSendPlayer--记录 SendMailNameEditBox，内容

        if Save.hide or Save.hideSendPlayerList then--隐藏
            self.playerTipsLable:SetText('')
            return
        end

        local text=''
        if self:GetText():find(' ') then
            text=' (|cnRED_FONT_COLOR:'..(e.onlyChinese and '空格键' or KEY_SPACE)..'|r)'
        end

        self.playerTipsLable:SetText((get_Name_Info(name) or '')..text)
        button.ClearPlayerButton:SetAlpha(self:GetText()=='' and 0.3 or 1)
    end)

    --#################
    --隐藏， 邮资：，文本
    --#################
    if SendMailCostMoneyFrameCopperButton then
        SendMailCostMoneyFrameCopperButton:SetScript('OnLeave', GameTooltip_Hide)
        SendMailCostMoneyFrameCopperButton:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddLine(e.onlyChinese and '邮资：' or SEND_MAIL_COST)
            e.tips:Show()
        end)
        if SendMailCostMoneyFrame then
            local frames= {SendMailCostMoneyFrame:GetRegions()}
            for _, text in pairs(frames) do
                if text:GetObjectType()=="FontString" and text:GetText()==SEND_MAIL_COST then
                    text:SetText('')
                    text:Hide()
                    break
                end
            end
        end
        --[[C_Timer.After(2, function()
            SendMailCostMoneyFrameCopperButtonText:ClearAllPoints()
            SendMailCostMoneyFrameCopperButtonText:SetPoint('LEFT', button, 'RIGHT',2,0)
            --SendMailCostMoneyFrameCopperButton:Clea
        end)]]
    end
end























--##################
--设置，快速选取，按钮
--##################
local function check_Enabled_Item(classID, subClassID, findString, bag, slot)
    local info = C_Container.GetContainerItemInfo(bag, slot)
    if info
        and info.itemID
        and info.hyperlink
        and not info.isLocked
        and not info.isBound
    then
        local class, sub = select(6, C_Item.GetItemInfoInstant(info.hyperlink))
        if (findString and info.hyperlink:find(findString))
            or (
                class==classID
                and (not subClassID or sub==subClassID)
            )
        then
            if class==2 or class==4 then--幻化
                local text, isCollected =e.GetItemCollected(info.hyperlink)
                if text and not isCollected then
                    return info
                end
            else
                return info
            end
        end
    end
end
























--####################
--快速，加载，物品，菜单
--####################
local function Init_Fast_Menu(_, level, menuList)
    local info
    if menuList then
        local newTab={}
        for subClass, tab in pairs(menuList.subClass) do
            table.insert(newTab, {subClass= subClass, num= tab.num, item= tab.item})
        end
        table.sort(newTab, function(a,b) return a.subClass< b.subClass end)

        for _, tab in pairs(newTab) do
            local tooltip
            for link, num in pairs(tab.item) do
                local icon= C_Item.GetItemIconByID(link)
                tooltip= (tooltip and tooltip..'|n' or '|n')..(icon and '|T'..icon..':0|t' or '')..link..'|cnGREEN_FONT_COLOR:#'..num..'|r'
            end
            local className= e.cn(C_Item.GetItemSubClassInfo(menuList.class, tab.subClass)) or ''
            local text =(tab.subClass<10 and ' ' or '')..tab.subClass..') '.. className
            info={
                text= text..' |cnGREEN_FONT_COLOR:#'..tab.num,
                keepShownOnClick= true,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle= text,
                tooltipText= tooltip,
                arg1=menuList.class,
                arg2= tab.subClass,
                func= function(_, arg1, arg2)
                    button.FastButton.set_PickupContainerItem(arg1, arg2)
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        local className= C_Item.GetItemClassInfo(menuList.class)
        className= e.strText[className] or className
        info= {
            text= menuList.class..') '..className..' #'..menuList.num,
            notCheckable= true,
            isTitle= true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        if menuList.class==2 or menuList.class==4 then
            info= {
                text= '|T132288:0|t'..format(e.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, e.onlyChinese and '你还没有收藏过此外观' or TRANSMOGRIFY_STYLE_UNCOLLECTED),
                notCheckable= true,
                isTitle= true,
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)

        end
        return
    end

    local tab={}
    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES+ NUM_REAGENTBAG_FRAMES do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info2 = C_Container.GetContainerItemInfo(bag, slot)
            if info2
                and info2.hyperlink
                and not info2.isLocked
                and not info2.isBound
            then
                local class, sub = select(6, C_Item.GetItemInfoInstant(info2.hyperlink))
                if class and sub then
                    local find=true
                    if class==2 or class==4 then--幻化
                        local text, isCollected= e.GetItemCollected(info2.hyperlink)
                        if not text or isCollected then
                            find= false
                        end
                    end
                    if find then
                        tab[class]= tab[class] or {
                                            num= 0,
                                            subClass= {
                                                        [sub]={num=0, item={}}
                                                    }
                                        }
                        tab[class].num= tab[class].num+ info2.stackCount


                        tab[class]['subClass'][sub]= tab[class]['subClass'][sub] or {num=0, item={}}

                        tab[class]['subClass'][sub]['num']= tab[class]['subClass'][sub]['num'] + info2.stackCount

                        tab[class]['subClass'][sub]['item'][info2.hyperlink]= (tab[class]['subClass'][sub]['item'][info2.hyperlink] or 0)+ info2.stackCount
                    end
                end
            end
        end
    end

    local newTab={}
    for class, tab2 in pairs(tab) do
        table.insert(newTab, {class=class, num=tab2.num, subClass= tab2.subClass})
    end
    table.sort(newTab, function(a,b) return a.class< b.class end)

    local find
    for _, tab2 in pairs(newTab) do
        local className=  C_Item.GetItemClassInfo(tab2.class) or ''
        className= e.strText[className] or className
        info={
            text= (tab2.class<10 and ' ' or '')..tab2.class..') '..className..((tab2.class==2 or tab2==4) and '|T132288:0|t' or ' ')..'|cnGREEN_FONT_COLOR:#'..tab2.num,
            keepShownOnClick= true,
            notCheckable=true,
            menuList= {class=tab2.class, subClass=tab2.subClass, num=tab2.num},
            hasArrow=true,
            tooltipOnButton= true,
            arg1=tab2.class,
            func= function(_, arg1)
                button.FastButton.set_PickupContainerItem(arg1)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        find=true
    end
    if not find then
        info={
            text= e.onlyChinese and '无' or NONE,
            notCheckable= true,
            isTitle= true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    end
end

































--####################
--快速，加载，物品，按钮
--####################
local function Init_Fast_Button()
    if button.FastButton then
        return
    end

    button.FastButtonS={}
    panel.ItemMaxNum= ATTACHMENTS_MAX_SEND

    button.FastButton= e.Cbtn(button, {size={size+4, size+4}, atlas= 'NPE_ArrowRight'})
    if _G['Postal_QuickAttachButton1'] then--C_AddOns.IsAddOnLoaded('Postal')
        button.FastButton:SetPoint('BOTTOMLEFT', _G['Postal_QuickAttachButton1'], 'TOPRIGHT', 2, 0)
    else
        button.FastButton:SetPoint('BOTTOMLEFT', MailFrameCloseButton, 'BOTTOMRIGHT',0, -2)
    end
    button.FastButton:SetScript('OnMouseDown', function(self, d)
        if IsAltKeyDown() and d=='LeftButton' then--展开/缩起
            Save.fastShow= not Save.fastShow and true or nil
            self.frame:SetShown(Save.fastShow)

        else--菜单
            if not self.Menu then
                self.Menu= CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, Init_Fast_Menu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
        end
    end)
    button.FastButton:SetScript('OnMouseWheel', function(self, d)
        if IsAltKeyDown() then
            local num= Save.scaleFastButton or 1
            if d==1 then
                num= num- 0.05
            elseif d==-1 then
                num= num+ 0.05
            end
            num= num<0.5 and 0.5 or num>2 and 2 or num
            print(id, Initializer:GetName(),e.onlyChinese and '缩放' or UI_SCALE, '|cnGREEN_FONT_COLOR:'..(Save.scaleFastButton or 1) )
            Save.scaleFastButton= num
            self.frame:SetScale(num)
        end
    end)

    button.FastButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '收起选项 |A:editmode-up-arrow:16:11:0:3|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS)..' '..e.GetYesNo(not Save.fastShow), 'Alt+'..e.Icon.left)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.scaleFastButton or 1), 'Alt+'..e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:Show()
        self.get_Send_Max_Item()--能发送，数量
        self.set_Fast_Event(nil, true)--清除，注册，事件，显示/隐藏，设置数量
        for _, btn in pairs(button.FastButtonS) do
            btn:SetAlpha(1)
        end
        button.clearAllItmeButton:SetShown(true)
    end)
    button.FastButton:SetScript('OnLeave', function(self)
        e.tips:Hide()
        self.get_Send_Max_Item()--能发送，数量
        self.set_Fast_Event()--清除，注册，事件，显示/隐藏，设置数量
        button.clearAllItmeButton:SetShown(panel.ItemMaxNum<ATTACHMENTS_MAX_SEND)
    end)

    --[[button.FastButton:RegisterEvent('MAIL_SEND_INFO_UPDATE')
    button.FastButton:RegisterEvent('MAIL_SEND_SUCCESS')
    button.FastButton:SetScript('OnEvent', function(self, arg1)
        self.get_Send_Max_Item()--能发送，数量
    end)]]

    button.FastButton.get_Send_Max_Item= function()--能发送，数量
        local tab={}
        for i= 1, ATTACHMENTS_MAX_SEND do
            if not HasSendMailItem(i) then
                table.insert(tab, i)
            end
        end
        panel.ItemMaxNum= #tab
        return tab
    end

    button.FastButton.set_Fast_Event= function(frame, unregisterAllEvents)--清除，注册，事件，显示/隐藏，设置数量
        if frame then
            if unregisterAllEvents then
                frame:UnregisterAllEvents()
            elseif frame:IsShown() then
                button.FastButton.get_Send_Max_Item()--能发送，数量
                button.FastButton.set_Label_Text(frame)
                frame:RegisterEvent('BAG_UPDATE_DELAYED')
                frame:RegisterEvent('MAIL_SEND_INFO_UPDATE')
                frame:RegisterEvent('MAIL_SEND_SUCCESS')
            end
        else
            if not unregisterAllEvents then
                button.FastButton.get_Send_Max_Item()--能发送，数量
            end
            for _, btn in pairs(button.FastButtonS) do
                if unregisterAllEvents then
                    btn:UnregisterAllEvents()
                elseif btn:IsShown() then
                    button.FastButton.set_Label_Text(btn)
                    btn:RegisterEvent('BAG_UPDATE_DELAYED')
                    btn:RegisterEvent('MAIL_SEND_INFO_UPDATE')
                    btn:RegisterEvent('MAIL_SEND_SUCCESS')
                end
            end
        end
    end

    button.FastButton.set_PickupContainerItem= function(classID, subClassID, findString, onlyBag)--自动放物品
        local slotTab= button.FastButton.get_Send_Max_Item()--能发送，数量
        if #slotTab==0 then
            return
        end

        button.FastButton.set_Fast_Event(nil, true)--清除，注册，事件，显示/隐藏，设置数量

        if onlyBag then
            local info= check_Enabled_Item(classID, subClassID, findString, onlyBag.bag, onlyBag.slot)
            if info then

                C_Container.PickupContainerItem(onlyBag.bag, onlyBag.slot)
                ClickSendMailItemButton(slotTab[1])
                table.remove(slotTab, 1)

                if #slotTab==0 then
                    slotTab= button.FastButton.get_Send_Max_Item()--能发送，数量
                    button.FastButton.set_Fast_Event()--清除，注册，事件，显示/隐藏，设置数量
                    return
                end
            else
                return
            end
        end

        for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES+ NUM_REAGENTBAG_FRAMES do
            for slot=1, C_Container.GetContainerNumSlots(bag) do
                local info= check_Enabled_Item(classID, subClassID, findString, bag, slot)

                if info then
                    C_Container.PickupContainerItem(bag, slot)
                    ClickSendMailItemButton(slotTab[1])
                    table.remove(slotTab, 1)
                    if #slotTab==0 then
                        slotTab= button.FastButton.get_Send_Max_Item()--能发送，数量
                        button.FastButton.set_Fast_Event()--清除，注册，事件，显示/隐藏，设置数量
                        return
                    end
                end
            end
        end

        button.FastButton.get_Send_Max_Item()--能发送，数量
        button.FastButton.set_Fast_Event()--清除，注册，事件，显示/隐藏，设置数量
    end

    button.FastButton.set_Label_Text= function(self)--设置提示，数量，堆叠
        if not self or not self:IsShown() then
            return
        end
        local num, stack= 0, 0 --C_Item.GetItemMaxStackSizeByID(info.itemID)
        for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES+ NUM_REAGENTBAG_FRAMES do
            for slot=1, C_Container.GetContainerNumSlots(bag) do
                local info= check_Enabled_Item(self.classID, self.subClassID, self.findString, bag, slot)
                if info then
                    num= num+ info.stackCount
                    stack= stack+1
                end
            end
        end
        self.numLable:SetText(num==stack and '' or num)
        self.stackLable:SetText(stack>0 and stack or '' )
        local alpha= 1
        if panel.ItemMaxNum==0 and stack>0 then
            alpha= 0.5
        elseif panel.ItemMaxNum==0 or stack==0 then
            alpha=0.1
        end
        self:SetAlpha(alpha)
        self.num=num
        self.stack=stack
    end

    button.FastButton.frame= CreateFrame('Frame', nil, button)
    button.FastButton.frame:SetSize(size, 2)
    button.FastButton.frame:SetPoint('TOPLEFT', button.FastButton, 'BOTTOMLEFT')
    if Save.scaleFastButton and Save.scaleFastButton~=1 then
        button.FastButton.frame:SetScale(Save.scaleFastButton)
    end
    button.FastButton.frame:SetShown(Save.fastShow)

    local fast={
        {GetSpellTexture(3908) or 4620681, 7, 5, e.onlyChinese and '布'},--1
        {GetSpellTexture(2108) or 4620678, 7, 6, e.onlyChinese and '皮革'},--2
        {GetSpellTexture(2656) or 4625105, 7, 7, e.onlyChinese and '金属 矿石'},--3
        {GetSpellTexture(2550) or 4620671, 7, 8, e.onlyChinese and '烹饪'},--4
        {GetSpellTexture(2383) or 133939, 7, 9, e.onlyChinese and '草药'},--5
        {GetSpellTexture(7411) or 4620672, 7, 12, e.onlyChinese and '附魔'},--6
        {GetSpellTexture(45357) or 4620676, 7, 16, e.onlyChinese and '铭文'},--7
        {GetSpellTexture(25229) or 4620677, 7, 4, e.onlyChinese and '珠宝加工'},--8

        {"Interface/Icons/INV_Gizmo_FelIronCasing", 7, 1, e.onlyChinese and '零部'},--9
        {"Interface/Icons/INV_Elemental_Primal_Air", 7, 10, e.onlyChinese and '元素'},--10
        {"Interface/Icons/INV_Bijou_Green", 7, 18, e.onlyChinese and '可选材料'},--11
        {"Interface/Icons/INV_Misc_Rune_09", 7, 11, e.onlyChinese and '其它'},--12
        {"Interface/Icons/Ability_Ensnare", 7, 0, e.onlyChinese and '贸易品'},--13
        '-',
        {132690, 4, 1, e.onlyChinese and '布甲'},--1
        {132722, 4, 2, e.onlyChinese and '皮甲'},--2
        {132629, 4, 3, e.onlyChinese and '锁甲'},--3
        {132738, 4, 4, e.onlyChinese and '板甲'},--4
        {134966, 4, 6, e.onlyChinese and '盾牌'},--5
        {135317, 2, nil, e.onlyChinese and '武器'},--6
        {644389, 15, 2, e.onlyChinese and '宠物' or PET, 'Hbattlepet'},--7

        --{133035, 0, 0, e.onlyChinese and '装置'},
        {463931, 0, 1, e.onlyChinese and '药水'},
        {609902, 0, 3, e.onlyChinese and '合计'},
        --{609902, 0, 7, e.onlyChinese and '绷带'},
        {133974, 0, 5, e.onlyChinese and '食物'},
        {1528795, 0, 9, e.onlyChinese and '符文'},

        {466645, 3, nil, e.onlyChinese and '宝石'},
        {463531, 8, nil, e.onlyChinese and '附魔'},
    }

    local x, y=0, 0
    for index, tab in pairs(fast) do
        if tab~='-' then
            local btn= e.Cbtn(button.FastButton.frame, {size={size,size}, texture=tab[1]})
            btn:SetPoint('TOPLEFT', button.FastButton.frame,'BOTTOMLEFT', x, y)

            btn.classID= tab[2]
            btn.subClassID= tab[3]
            btn.name= tab[4] or not tab[3] and C_Item.GetItemClassInfo(tab[2]) or C_Item.GetItemSubClassInfo(tab[2], tab[3])
            btn.findString= tab[5]

            btn.numLable= e.Cstr(btn, {size=10})
            btn.numLable:SetPoint('TOPLEFT')
            btn.stackLable= e.Cstr(btn, {size=10})
            btn.stackLable:SetPoint('BOTTOMRIGHT')
            btn.playerTexture= btn:CreateTexture(nil, 'OVERLAY')
            btn.playerTexture:SetAtlas('AnimaChannel-Bar-Necrolord-Gem')
            btn.playerTexture:SetSize(size/2, size/2)
            btn.playerTexture:SetPoint('BOTTOMLEFT')
            function btn:set_Player_Lable()--设置指定发送，玩家, 提示
                self.playerTexture:SetShown(Save.fast[self.name] and true or false)
            end
            btn:set_Player_Lable()

            btn:SetScript('OnClick', function(self, d)
                if d=='LeftButton' then
                    local name= Save.fast[self.name]
                    if name and name~=e.Player.name_realm then
                        set_Text_SendMailNameEditBox(nil, name)--设置，发送名称，文
                    end
                    button.FastButton.set_PickupContainerItem(self.classID, self.subClassID, self.findString)--自动放物品
                elseif d=='RightButton' then
                    if not self.Menu then
                        self.Menu= CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                        e.LibDD:UIDropDownMenu_Initialize(self.Menu, function(_, level, menuList)
                            local icon= self:GetNormalTexture():GetTexture()
                            if menuList=='SELF' then
                                local find
                                local name= Save.fast[self.name]
                                for guid, _ in pairs(e.WoWDate) do
                                    if guid then
                                        local playerName= e.GetUnitName(nil, nil, guid)
                                        e.LibDD:UIDropDownMenu_AddButton({
                                            text= e.GetPlayerInfo({guid=guid, reName=true, reRealm=true}),
                                            checked= name and name==playerName,
                                            icon=icon,
                                            tooltipOnButton=true,
                                            tooltipTitle=self.name,
                                            tooltipText=playerName,
                                            arg1= self.name,
                                            arg2= playerName,
                                            func= function(_, arg1, arg2)
                                                if arg2 then
                                                    Save.fast[arg1]= arg2
                                                    print(id, Initializer:GetName(), arg1, arg2)
                                                    self:set_Player_Lable()
                                                end
                                            end,
                                        }, level)
                                        find=true
                                    end
                                end
                                if not find then
                                    e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
                                end
                                return
                            end

                            local playerName= Save.fast[self.name]
                            local newName= e.GetUnitName(SendMailNameEditBox:GetText())
                            e.LibDD:UIDropDownMenu_AddButton({
                                text='|T'..icon..':0|t'..self.name..': '..(playerName and e.GetPlayerInfo({name=playerName, reName=true}) or format('|cff606060%s|r', e.onlyChinese and '无' or NONE)),
                                notCheckable=true,
                                colorCode= not playerName and '|cff606060',
                                isTitle=true,
                            }, level)

                            e.LibDD:UIDropDownMenu_AddButton({
                                text= e.onlyChinese and '更新' or UPDATE,
                                notCheckable=true,
                                colorCode= (not newName or playerName==newName) and '|cff606060',
                                tooltipOnButton=true,
                                tooltipTitle= newName or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, e.onlyChinese and '需求' or NEED, e.onlyChinese and '收件人：' or MAIL_TO_LABEL),
                                arg1=self.name,
                                arg2=newName,
                                func= function(_, arg1, arg2)
                                    if arg2 then
                                        Save.fast[arg1]= arg2
                                        print(id, Initializer:GetName(), arg1, arg2)
                                        self:set_Player_Lable()
                                    end
                                end
                            }, level)

                            e.LibDD:UIDropDownMenu_AddButton({
                                text= e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
                                notCheckable=true,
                                colorCode= not playerName and '|cff606060',
                                arg1=self.name,
                                func=function(_, arg1)
                                    Save.fast[arg1]=nil
                                    print(id, Initializer:GetName(), arg1, e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)
                                    self:set_Player_Lable()
                                end
                            }, level)

                            e.LibDD:UIDropDownMenu_AddSeparator(level)
                            e.LibDD:UIDropDownMenu_AddButton({
                                text= '|A:auctionhouse-icon-favorite:0:0|a'..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME),
                                hasArrow= true,
                                notCheckable=true,
                                menuList= 'SELF',
                                keepShownOnClick=true,
                            }, level)

                        end, 'MENU')
                    end
                    e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)

                    --[[Save.fast[self.name]= e.GetUnitName(SendMailNameEditBox:GetText())--取得， SendMailNameEditBox， 名称
                    self:set_Player_Lable()--设置指定发送，玩家, 提示
                    print(id, Initializer:GetName(), self.name, Save.fast[self.name] or (e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2))]]
                end
            end)

            btn:SetScript('OnLeave', function(self)
                button.FastButton.set_Label_Text(self)--设置提示，数量，堆叠
                e.tips:Hide()
            end)
            btn:SetScript('OnEnter', function(self)
                self.set_Player_Lable(self)--设置指定发送，玩家, 提示
                local playerName= Save.fast[self.name]
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddLine('|T'..(self:GetNormalTexture():GetTexture() or 0)..':0|t'..self.name)
                e.tips:AddDoubleLine((e.onlyChinese and '添加' or ADD)..e.Icon.left, e.GetPlayerInfo({name=playerName, reName=true}))
                e.tips:AddLine(' ')
                if self.classID==2 or self.classID==4 then
                    e.tips:AddDoubleLine(format(e.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, e.onlyChinese and '你还没有收藏过此外观' or TRANSMOGRIFY_STYLE_UNCOLLECTED))
                end
                e.tips:AddDoubleLine(self.classID and 'ClassID '..self.classID or '', self.subClassID and 'SubClassID '..self.subClassID or '')
                e.tips:AddDoubleLine(e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL, self.num)
                e.tips:AddDoubleLine(e.onlyChinese and '组数' or AUCTION_NUM_STACKS, self.stack)
                e.tips:AddLine(' ')
                e.tips:AddLine((e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU)..e.Icon.right)
                e.tips:Show()
                self:SetAlpha(1)
            end)

            btn:SetScript('OnShow', function(self)
                button.FastButton.set_Fast_Event(self)--清除，注册，事件，显示/隐藏，设置数量
                self.set_Player_Lable(self)--设置指定发送，玩家, 提示
            end)
            btn:SetScript('OnHide', function(self)
                button.FastButton.set_Fast_Event(self, true)--清除，注册，事件，显示/隐藏，设置数量
            end)
            btn:SetScript('OnEvent', function(self, arg1)
                button.FastButton.set_Label_Text()
            end)
            button.FastButtonS[index]= btn

            y= y- size
        else
            x= x+ size
            y=0
        end
    end

    button.clearAllItmeButton=e.Cbtn(button, {size={size,size}, atlas='bags-button-autosort-up'})
    button.clearAllItmeButton:SetPoint('BOTTOMRIGHT', SendMailAttachment7, 'TOPRIGHT')--,0, -4)
    button.clearAllItmeButton:SetScript('OnClick', function()
        button.FastButton.set_Fast_Event(nil, true)--清除，注册，事件，显示/隐藏，设置数量
        for i= 1, ATTACHMENTS_MAX_SEND do
            if HasSendMailItem(i) then
                ClickSendMailItemButton(i, true)
            end
        end
        button.FastButton.get_Send_Max_Item()--能发送，数量
        button.FastButton.set_Fast_Event()--清除，注册，事件，显示/隐藏，设置数量
    end)
    button.clearAllItmeButton:SetScript('OnLeave', GameTooltip_Hide)
    button.clearAllItmeButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()

        e.tips:AddDoubleLine(' ', e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)
        e.tips:AddDoubleLine((self.numItem or 0)..' '..(e.onlyChinese and '个' or AUCTION_HOUSE_QUANTITY_LABEL),
                            (panel.ItemMaxNum and ATTACHMENTS_MAX_SEND-panel.ItemMaxNum or 0)..'/'..ATTACHMENTS_MAX_SEND..' '..(e.onlyChinese and '组' or AUCTION_NUM_STACKS))
        e.tips:Show()
    end)
    button.clearAllItmeButton:SetShown(false)
    button.clearAllItmeButton:RegisterEvent('MAIL_SEND_INFO_UPDATE')
    button.clearAllItmeButton:RegisterEvent('MAIL_SEND_SUCCESS')
    button.clearAllItmeButton:SetScript('OnEvent', function(self)
        button.FastButton.get_Send_Max_Item()--能发送，数量
        self:SetShown(panel.ItemMaxNum<ATTACHMENTS_MAX_SEND)
        local num= 0
        if self:IsShown() then
            for index= 1, ATTACHMENTS_MAX_SEND do
                if HasSendMailItem(index) then
                   num= num+ (select(4, GetSendMailItem(index)) or 0)
                end
            end
            self.itemNumLabel:SetText(num)
        else
            self.itemNumLabel:SetText('')
        end
        self.numItem= num
    end)
    button.clearAllItmeButton.itemNumLabel= e.Cstr(button.clearAllItmeButton)
    button.clearAllItmeButton.itemNumLabel:SetPoint('BOTTOMRIGHT', button.clearAllItmeButton, 'BOTTOMLEFT',0,4)

    local btn= _G['SendMailAttachment'..ATTACHMENTS_MAX_SEND]--最大数，提示
    if btn then
        btn.max= btn:CreateTexture(nil, 'OVERLAY')
        btn.max:SetSize(20, 30)
        btn.max:SetAtlas('poi-traveldirections-arrow2')
        btn.max:SetAlpha(0.5)
        btn.max:SetPoint('LEFT', btn, 'RIGHT', -2, 0)
    end
    for i=1, ATTACHMENTS_MAX_SEND do--索引，提示
        btn= _G['SendMailAttachment'..i]
        if btn then
            btn.indexLable= e.Cstr(btn, {layer='BORDER'})
            btn.indexLable:SetPoint('CENTER')
            btn.indexLable:SetAlpha(0.3)
            btn.indexLable:SetText(i)

            for _, region in pairs({btn:GetRegions()}) do--背景，透明度
                if region:GetObjectType()=="Texture" then
                    region:SetAlpha(0.5)
                    break
                end
            end
        end
    end
end






























--################
--收信箱，物品，提示
--MailFrame.lua
--_G["MailItem"..i.."Button"]:Hide();
--_G["MailItem"..i.."Sender"]:SetText("");
--_G["MailItem"..i.."Subject"]:SetText("");
--_G["MailItem"..i.."ExpireTime"]:Hide();
--local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, itemCount, wasRead, x, y, z, isGM, firstItemQuantity, firstItemLink = GetInboxHeaderInfo(btn.index)
--local bodyText, stationeryID1, stationeryID2, isTakeable, isInvoice, isConsortium = GetInboxText(InboxFrame.openMailID);
local initInBox
local function Init_InBox()
    if initInBox then
        return
    end
    initInBox=true

    local function get_Money(num)
        if num and num>0 then
            if num>=1e4 then
                return e.MK(num/1e4, 2)..'|TInterface/moneyframe/ui-goldicon:0|t'
            else
                return GetMoneyString(num)
            end
        end
        return ''
    end
    --查找，信件里的第一个物品，超链接
    local function find_itemLink(itemCount, openMailID, itemLink)
        itemLink= (itemCount and itemCount>0) and itemLink
        if itemCount and itemCount>0 and not itemLink then
            for i= 1, itemCount do
                itemLink= GetInboxItemLink(openMailID, i)
                if itemLink then
                    break
                end
            end
        end
        return itemLink
    end



    --删除，或退信
    local function return_delete_InBox(openMailID)--删除，或退信
        local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, itemCount, wasRead, x, y, z, isGM, firstItemQuantity, firstItemLink = GetInboxHeaderInfo(openMailID)

        local itemName= find_itemLink(itemCount, openMailID, firstItemLink)
        local icon=packageIcon or stationeryIcon

        local text= GetInboxText(openMailID) or ''
        text= text:gsub(' ','') and nil or text

        local delOrRe
        local canDelete= InboxItemCanDelete(openMailID)
        if InboxItemCanDelete(openMailID) then
            delOrRe= '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '删除' or DELETE)..'|r'
        else
            delOrRe= '|cFFFF00FF'..(e.onlyChinese and '退信' or MAIL_RETURN)..'|r'
        end

        if canDelete and (not money or money==0) and (not CODAmount or CODAmount==0) and (not itemCount or itemCount) then
            DeleteInboxItem(openMailID)
        else
            InboxFrame.openMailID= openMailID
            OpenMailFrame.itemName= (itemCount and itemCount>0) and itemName or nil
            OpenMailFrame.money= money
            e.call('OpenMail_Delete')--删除，或退信 MailFrame.lua
        end

        print('|cFFFF00FF'..openMailID..')|r',
            ((icon and not itemName) and '|T'..icon..':0|t' or '')..delOrRe,
            e.PlayerLink(sender, nil, true),
            subject,
            itemName or '',
            (money and money>0) and GetMoneyString(money, true) or '',
            (CODAmount and CODAmount>0) and GetMoneyString(CODAmount, true) or '',
            text and '|n' or '',
            text or '')
    end


    --隐藏，所有，选中提示
    local function set_btn_enterTipTexture_Hide_All()
        for i=1, INBOXITEMS_TO_DISPLAY do
            local btn=_G["MailItem"..i.."Button"]
            if btn and btn.enterTipTexture then
                btn.enterTipTexture:SetShown(false)
            end
        end
    end




    local function set_Tooltips_DeleteAll(self, del)--所有，删除，退信，提示
        set_btn_enterTipTexture_Hide_All()--隐藏，所有，选中提示

        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine('|cffff00ff'..id, '|cffff00ff'..addName)
        local num=0
        local findReTips--显示第一个，退回信里，的物品
        for i=1, select(2, GetInboxNumItems()) do
            local canDelete=InboxItemCanDelete(i)
            local packageIcon, stationeryIcon, sender, subject, money, CODAmount, _, itemCount, wasRead, _, _, _, _, _, firstItemLink = GetInboxHeaderInfo(i)
            local moneyPaga= (CODAmount and CODAmount>0) and CODAmount or nil
            local moneyGet= (money and money>0) and money or nil
            local itemLink= find_itemLink(itemCount, i, firstItemLink)--查找，信件里的第一个物品，超链接
            if (canDelete and del and not moneyPaga and not moneyGet and not itemLink) or (not del and not canDelete) then
                e.tips:AddDoubleLine((i<10 and ' ' or '')
                                        ..i..') |T'..(packageIcon or stationeryIcon)..':0|t'
                                        ..get_Name_Info(sender)
                                        ..(not wasRead and ' |cnRED_FONT_COLOR:'..(e.onlyChinese and '未读' or COMMUNITIES_FRAME_JUMP_TO_UNREAD) or '')
                                    , subject)

                if not canDelete and (itemCount and itemCount>0) and not findReTips then--物品，提示
                    local allCount=0
                    for itemIndex= 1, itemCount do
                        local itemIndexLink= GetInboxItemLink(i, itemIndex)
                        if itemIndexLink then
                            local texture, count = select(3, GetInboxItem(i, itemIndex))
                            allCount= allCount+ (count or 1)
                            e.tips:AddDoubleLine(' ','|cnGREEN_FONT_COLOR:'..(count or 1)..'x|r '..(texture and '|T'..texture..':0|t' or '')..itemIndexLink..' ('..itemIndex)
                        end
                    end
                    if allCount>1 then
                        e.tips:AddDoubleLine(' ', '#'..e.MK(allCount, 3))
                    end
                    e.tips:AddLine(' ')
                end

                if not findReTips and not Save.hide then--显示，所有，选中提示
                    for i2=1, INBOXITEMS_TO_DISPLAY do
                        local btn=_G["MailItem"..i2.."Button"]
                        if btn and btn.enterTipTexture and btn.index==i then
                            btn.enterTipTexture:SetShown(true)
                            break
                        end
                    end
                end

                findReTips=true
                num=num+1
            end
        end
        e.tips:AddDoubleLine(' ',
                            del and '|cnRED_FONT_COLOR:'..(e.onlyChinese and '删除' or DELETE)..'|r |cnGREEN_FONT_COLOR:#'..num
                            or ('|cFFFF00FF'..(e.onlyChinese and '退信' or MAIL_RETURN)..'|r |cnGREEN_FONT_COLOR:#'..num)
                        )
        e.tips:Show()
    end



    local function eventEnter(self, get)--enter 提示，删除，或退信，按钮
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(' ')
        local packageIcon, stationeryIcon, _, _, _, _, _, itemCount = GetInboxHeaderInfo(self.openMailID)
        local allCount=0
        if itemCount then
            for itemIndex= 1, itemCount do
                local itemIndexLink= GetInboxItemLink(self.openMailID, itemIndex)
                if itemIndexLink then
                    local texture, count = select(3, GetInboxItem(self.openMailID, itemIndex))
                    texture = texture or C_Item.GetItemIconByID(itemIndexLink)
                    allCount= allCount+ (count or 1)
                    e.tips:AddLine((itemIndex<10 and ' ' or '')..itemIndex..') '..(texture and '|T'..texture..':0|t' or '')..itemIndexLink..'|cnGREEN_FONT_COLOR: x'..(count or 1)..'|r')
                end
            end
            e.tips:AddLine(' ')
        end
        local text= GetInboxText(self.openMailID)
        if text and text:gsub(' ', '')~='' then
            e.tips:AddLine(text, nil,nil,nil, true)
            e.tips:AddLine(' ')
        end

        local text2
        if get then
            text2= e.onlyChinese and '提取' or WITHDRAW
        elseif self.canDelete then
            text2= e.onlyChinese and '删除' or DELETE
        else
            text2= e.onlyChinese and '退信' or MAIL_RETURN
        end
        local icon= packageIcon or stationeryIcon
        e.tips:AddLine('|cffff00ff'..self.openMailID..' |r'..(icon and '|T'..icon..':0|t')..text2..(allCount>1 and ' |cnGREEN_FONT_COLOR:'..e.MK(allCount,3)..'|r'..(e.onlyChinese and '物品' or ITEMS) or ''))
        e.tips:Show()
    end



    hooksecurefunc('InboxFrame_Update',function()
        local totalItems= select(2, GetInboxNumItems())  --信件，总数量   

        for i=1, INBOXITEMS_TO_DISPLAY do
            local btn=_G["MailItem"..i.."Button"]
            if btn and btn:IsShown() then

                --local _, _, sender, subject, money2, CODAmount2, _, itemCount2, wasRead, wasReturned, textCreated, canReply, isGM = GetInboxHeaderInfo(btn.index)
                local packageIcon, stationeryIcon, sender, subject, money2, CODAmount2, daysLeft, itemCount2, wasRead, wasReturned, textCreated, canReply, isGM = GetInboxHeaderInfo(btn.index)
                local invoiceType, itemName, playerName, bid, buyout, deposit, consignment = GetInboxInvoiceInfo(btn.index)
                local CODAmount= (CODAmount2 and CODAmount2>0) and CODAmount2 or nil
                local money= (money2 and money2>0) and money2 or nil
                local itemCount= (itemCount2 and itemCount2>0) and itemCount2 or nil
                --local isPlayer= sender and canReply and sender ~= UnitName("player") and not isGM

                --发信人，提示, 点击回复
                if sender then
                    local frame=_G["MailItem"..i.."Sender"]
                    if frame then
                        if not frame:IsMouseEnabled()  then--回复
                            frame:EnableMouse(true)
                            frame:SetScript('OnMouseDown', function(self)
                                if not Save.hide and not self.isGM and (self.playerName or self.sender) and self.canReply  then
                                    OpenMailSender.Name:SetText(self.playerName or self.sender)
                                    OpenMailSubject:SetText(self.subject)
                                    InboxFrame.openMailID= self.openMailID
                                    e.call('OpenMail_Reply')--回复
                                end
                                self:SetAlpha(1)
                            end)
                            frame:SetScript('OnEnter', function(self)
                                if not Save.hide and not self.isGM and (self.playerName or self.sender) and self.canReply  then
                                    e.tips:SetOwner(self, "ANCHOR_LEFT")
                                    e.tips:ClearLines()
                                    e.tips:AddDoubleLine(e.onlyChinese and '回复' or REPLY_MESSAGE, self.playerName or self.sender)
                                    e.tips:Show()
                                end
                                self:SetAlpha(0.3)
                            end)
                            frame:SetScript('OnLeave', function(self)
                                e.tips:Hide()
                                self:SetAlpha(1)
                            end)
                        end
                        frame.canReply= canReply
                        frame.sender= sender
                        frame.subject= subject
                        frame.openMailID= btn.index

                        frame.playerName= (invoiceType=='buyer' or invoiceType=='seller') and playerName or nil
                        frame.isGM= isGM

                        if not Save.hide and sender  then
                            frame:SetText(playerName and sender..'  '..get_Name_Info(playerName) or get_Name_Info(sender))--发信人，提示 
                        end
                    end
                end

                --信件，索引，提示
                if not _G['PostalSelectReturnButton'] then
                    if not btn.indexText and not Save.hide then
                        btn.indexText= e.Cstr(btn, {alpha= 0.5})
                        btn.indexText:SetPoint('RIGHT', btn, 'LEFT',-2,0)
                    end
                    if btn.indexText then
                        btn.indexText:SetText((Save.hide or not btn.index) and '' or btn.index)
                    end
                end

                --提示，需要付钱, 可收取钱
                if (money or CODAmount) and not btn.CODAmountTips and not Save.hide then
                    btn.CODAmountTips= btn:CreateTexture(nil, 'OVERLAY')--图片
                    btn.CODAmountTips:SetSize(150, 20)
                    btn.CODAmountTips:SetPoint('BOTTOM', _G['MailItem'..i], 0,-4)
                    btn.CODAmountTips:SetAtlas('jailerstower-wayfinder-rewardbackground-selected')
                    btn.CODAmountTips:EnableMouse(true)
                    btn.moneyPagaTip= e.Cstr(btn)--文本
                    btn.moneyPagaTip:SetPoint('CENTER', btn.CODAmountTips)
                    btn.moneyPagaTip:EnableMouse(true)
                end
                if btn.CODAmountTips then
                    btn.CODAmountTips:SetShown((money or CODAmount) and not Save.hide)

                    if CODAmount then
                        btn.CODAmountTips:SetVertexColor(1,0,0)
                        btn.moneyPagaTip:SetTextColor(1,0,0)
                    else
                        btn.CODAmountTips:SetVertexColor(0,1,0)
                        btn.moneyPagaTip:SetTextColor(0,1,0)
                    end

                    local text
                    if not Save.hide and (money or CODAmount) then
                        if CODAmount then
                            text= (e.onlyChinese and '付款' or COD)
                        elseif money or invoiceType=='seller' then
                            text= (e.onlyChinese and '可取' or WITHDRAW)
                            text= invoiceType=='seller' and '|A:Levelup-Icon-Bag:0:0|a'..text or text
                        end
                        if text then
                            if bid and deposit and consignment then
                                text= text..' '..get_Money(bid + deposit - consignment)
                            else
                                text= text..' '..get_Money(money)
                            end
                        end
                    end
                    btn.moneyPagaTip:SetText(text or '')
                end

                --删除，或退信，按钮
                if not btn.DeleteButton and not Save.hide then
                    btn.DeleteButton= e.Cbtn(btn, {size={22,22}})
                    if _G['MailItem'..i..'ExpireTime'] and _G['MailItem'..i..'ExpireTime'].returnicon then
                        btn.DeleteButton:SetPoint('RIGHT', _G['MailItem'..i..'ExpireTime'].returnicon, 'LEFT')
                    else
                        btn.DeleteButton:SetPoint('BOTTOMRIGHT', _G['MailItem'..i])
                    end
                    btn.DeleteButton:SetScript('OnClick', function(self)--OpenMail_Delete()
                        return_delete_InBox(self.openMailID)--删除，或退信
                    end)
                    btn.DeleteButton:SetScript('OnEnter', function(self)
                        eventEnter(self)
                        local frame= self:GetParent()
                        frame.enterTipTexture:SetShown(true)
                    end)
                    btn.DeleteButton:SetScript('OnLeave', function(self)
                        local frame= self:GetParent()
                        frame.enterTipTexture:SetShown(false)
                        e.tips:Hide()
                    end)

                    --移过时，提示，选中，信件
                    btn.DeleteButton.numItemLabel= e.Cstr(btn.DeleteButton)
                    btn.DeleteButton.numItemLabel:SetPoint('BOTTOMRIGHT')
                    btn.enterTipTexture= btn:CreateTexture(nil, 'OVERLAY', nil, 7)
                    btn.enterTipTexture:SetAtlas('jailerstower-wayfinder-rewardbackground-selected')
                    btn.enterTipTexture:SetAllPoints(_G['MailItem'..i])
                    btn.enterTipTexture:SetVertexColor(0,1,0)
                    btn.enterTipTexture:Hide()

                    --提取，物品，和钱
                    btn.outItemOrMoney= e.Cbtn(btn, {size={22, 20}, atlas='talents-search-notonactionbarhidden'})
                    btn.outItemOrMoney:SetPoint('RIGHT', btn.DeleteButton, 'LEFT', -22, 0)
                    btn.outItemOrMoney:SetScript('OnClick', function(self)
                        e.call('InboxFrame_OnModifiedClick', self:GetParent(), self.openMailID)
                    end)
                    btn.outItemOrMoney:SetScript('OnLeave' ,function(self)
                        local frame=self:GetParent()
                        frame.enterTipTexture:SetShown(false)
                        e.tips:Hide()
                    end)
                    btn.outItemOrMoney:SetScript('OnEnter', function(self)
                        eventEnter(self, true)
                        local frame= self:GetParent()
                        frame.enterTipTexture:SetShown(true)
                    end)
                end

                if btn.DeleteButton then--删除，或退信，按钮，设置参数
                    btn.DeleteButton:SetNormalTexture(InboxItemCanDelete(btn.index) and 'xmarksthespot' or 'common-icon-undo')
                    btn.DeleteButton.openMailID= btn.index

                    local show= true
                    if Save.hide or invoiceType or (sender and strlower(sender) == strlower(BUTTON_LAG_AUCTIONHOUSE)) then
                        show=false
                    end

                    btn.DeleteButton:SetShown(show)
                    if btn.DeleteButton.numItemLabel then
                        btn.DeleteButton.numItemLabel:SetText((itemCount and itemCount>1) and itemCount or '')
                    end

                    btn.outItemOrMoney.openMailID= btn.index
                    btn.outItemOrMoney:SetShown((money or itemCount) and not CODAmount and not Save.hide)
                end
            end
        end

        --####################
        --所有，删除，退信，按钮
        --####################
        local allMoney= 0--总，可收取钱
        local allCODAmount= 0--总，要付款钱
        local allItemCount= 0--总，物品数
        local allSender= 0--总，发信人数
        local allSenderTab= {}--总，发信人数,表

        local numCanDelete= 0--可以删除，数量
        local numCanRe=0--可以退回，数量

        if not Save.hide then
            for i= 1, totalItems do
                local _, _, sender, _, money, CODAmount, _, itemCount, _, _, _, _, isGM= GetInboxHeaderInfo(i)
                local invoiceType= GetInboxInvoiceInfo(i)
                if sender then
                    if InboxItemCanDelete(i) then
                        if (not CODAmount or CODAmount==0) and (not money or money==0) and (not itemCount or itemCount==0) then
                            numCanDelete= numCanDelete +1
                        end
                    else
                        numCanRe= numCanRe+1
                    end
                    allMoney= allMoney+ (money or 0)
                    allCODAmount= allCODAmount+ (CODAmount or 0)
                    allItemCount= allItemCount+ (itemCount or 0)
                    if not allSenderTab[sender] and not isGM and not invoiceType then
                        allSenderTab[sender]=true
                        allSender= allSender +1
                    end
                end
            end
        end

        --删除所有信，按钮
        if numCanDelete>0 and not InboxFrame.DeleteAllButton then
            InboxFrame.DeleteAllButton= e.Cbtn(InboxFrame, {size={25,25}, atlas='xmarksthespot'})
            if _G['PostalSelectReturnButton'] then
                InboxFrame.DeleteAllButton:SetPoint('LEFT', _G['PostalSelectReturnButton'], 'RIGHT')
            else
                InboxFrame.DeleteAllButton:SetPoint('BOTTOMRIGHT', _G['MailItem1'], 'TOPRIGHT', 15, 15)
            end

            InboxFrame.DeleteAllButton:SetScript('OnEnter', function(self)--提示，要删除信，内容
                set_Tooltips_DeleteAll(self, true)
            end)
            InboxFrame.DeleteAllButton:SetScript('OnLeave', function(self)
                set_btn_enterTipTexture_Hide_All()--隐藏，所有，选中提示
                e.tips:Hide()
            end)

            --删除信
            InboxFrame.DeleteAllButton:SetScript('OnClick', function(self)

                for i=1, select(2, GetInboxNumItems())do
                    if InboxItemCanDelete(i) then
                        local money, CODAmount, _, itemCount= select(5, GetInboxHeaderInfo(i))
                        if (not money or money==0) and (not CODAmount or CODAmount==0) and (not itemCount or itemCount==0) then
                            return_delete_InBox(i)--删除，或退信
                            --DeleteInboxItem(i);
                            break
                        end
                    end
                end
                C_Timer.After(0.5, function()
                    set_Tooltips_DeleteAll(self, true)
                end)
            end)

            InboxFrame.DeleteAllButton.Text= e.Cstr(InboxFrame.DeleteAllButton)
            InboxFrame.DeleteAllButton.Text:SetPoint('BOTTOMRIGHT')
        end
        if InboxFrame.DeleteAllButton then
            InboxFrame.DeleteAllButton.Text:SetText(numCanDelete)
            InboxFrame.DeleteAllButton:SetShown(numCanDelete>0)
        end


        --退回，所有信，按钮
        if numCanRe>1 and not InboxFrame.ReAllButton then
            InboxFrame.ReAllButton= e.Cbtn(InboxFrame, {size={25,25}, atlas='common-icon-undo'})
            if _G['PostalSelectReturnButton'] then
                InboxFrame.ReAllButton:SetPoint('RIGHT', _G['PostalSelectOpenButton'], 'LEFT')
            else
                InboxFrame.ReAllButton:SetPoint('RIGHT', InboxFrame.DeleteAllButton,'LEFT')
            end

            InboxFrame.ReAllButton:SetScript('OnEnter', function(self)--提示，要删除信，内容
                set_Tooltips_DeleteAll(self, false)
            end)
            InboxFrame.ReAllButton:SetScript('OnLeave', function(self)
                set_btn_enterTipTexture_Hide_All()--隐藏，所有，选中提示
                e.tips:Hide()
            end)

            --删除信
            InboxFrame.ReAllButton:SetScript('OnClick', function(self)
                for i=1, select(2, GetInboxNumItems()) do
                    if not InboxItemCanDelete(i) then
                        return_delete_InBox(i)--删除，或退信
                        break
                    end
                end
                C_Timer.After(0.5, function()
                    set_Tooltips_DeleteAll(self, false)
                end)
            end)

            InboxFrame.ReAllButton.Text= e.Cstr(InboxFrame.ReAllButton)
            InboxFrame.ReAllButton.Text:SetPoint('BOTTOMRIGHT')
        end
        if InboxFrame.ReAllButton then
            InboxFrame.ReAllButton.Text:SetText(numCanRe)
            InboxFrame.ReAllButton:SetShown(numCanRe>1)
        end


        --总，内容，提示
        local text=''
        if not Save.hide then
            local allSenderText--总，发信人数
            if allSender>0 then
                if e.onlyChinese then
                    allSenderText= '发信人'
                else
                    allSenderText= ITEM_TEXT_FROM:gsub(',','')
                    allSenderText= allSenderText:gsub('，','')
                end
                allSenderText= '|cnGREEN_FONT_COLOR:'..allSender..'|r'..allSenderText..' '
            end
            if totalItems>0 then
                text= '|cnGREEN_FONT_COLOR:'..totalItems..'|r'..(e.onlyChinese and '信件' or MAIL_LABEL)..' '--总，信件
                    ..(allSenderText or '')--总，发信人数
                    ..(allItemCount>0 and '|cnGREEN_FONT_COLOR:'..allItemCount..'|r'..(e.onlyChinese and '物品' or ITEMS)..' ' or '')--总，物品数
                    ..(allMoney>0 and '|cnGREEN_FONT_COLOR:'..get_Money(allMoney)..'|r'..(e.onlyChinese and '可取' or WITHDRAW)..' ' or '')--总，可收取钱
                    ..(allCODAmount>0 and '|cnRED_FONT_COLOR:'.. get_Money(allCODAmount)..'|r'..(e.onlyChinese and '付款' or COD)..' ' or '')--总，要付款钱
            end
            if not InboxFrame.AllTipsLable then
                InboxFrame.AllTipsLable= e.Cstr(InboxFrame)
                InboxFrame.AllTipsLable:SetPoint('TOP', 20, -48)

                MailFrameTrialError:ClearAllPoints()--你需要升级你的账号才能开启这项功能。
                MailFrameTrialError:SetPoint('BOTTOM', InboxFrame.AllTipsLable, 'TOP', 0, 2)
                MailFrameTrialError:SetPoint('LEFT', InboxFrame, 55, 0)
                MailFrameTrialError:SetPoint('RIGHT', InboxFrame)
                MailFrameTrialError:SetWordWrap(false)

                InboxTooMuchMail:SetPoint('BOTTOM', InboxFrame.AllTipsLable, 'TOP', 0, 2)
            end
        end
        if InboxFrame.AllTipsLable then
            InboxFrame.AllTipsLable:SetText(text)
        end
    end)

    --提示，需要付钱, 可收取钱
    hooksecurefunc('OpenMail_Update', function()--多物品，打开时
        if not OpenMailFrame_IsValidMailID() then
            return
        end

        local sender, _, money, CODAmount
        if not Save.hide then
            sender, _, money, CODAmount= select(3, GetInboxHeaderInfo(InboxFrame.openMailID))
        end

        if sender then
            local newName= get_Name_Info(sender)
            if newName~=sender and not OpenMailFrame.sendTips and not Save.hide then
                OpenMailFrame.sendTips= e.Cstr(OpenMailFrame)
                OpenMailFrame.sendTips:SetPoint('BOTTOMLEFT', OpenMailSender.Name, 'TOPLEFT')
            end
            if OpenMailFrame.sendTips then
                OpenMailFrame.sendTips:SetText(newName==sender and '' or newName)
            end
        elseif OpenMailFrame.sendTips then
            OpenMailFrame.sendTips:SetText('')
        end

        local moneyPaga= CODAmount and CODAmount>0 and CODAmount
        local moneyGet= money and money>0 and money

        --提示，需要付钱
        if (moneyPaga or moneyGet) and not OpenMailFrame.CODAmountTips then
            OpenMailFrame.CODAmountTips= OpenMailFrame:CreateTexture(nil, 'OVERLAY')
            OpenMailFrame.CODAmountTips:SetSize(150, 25)
            OpenMailFrame.CODAmountTips:SetPoint('BOTTOM',0, 68)
            OpenMailFrame.CODAmountTips:SetAtlas('jailerstower-wayfinder-rewardbackground-selected')
            OpenMailFrame.moneyPagaTip= e.Cstr(OpenMailFrame)
            OpenMailFrame.moneyPagaTip:SetPoint('CENTER', OpenMailFrame.CODAmountTips)

        end
        if OpenMailFrame.CODAmountTips then
            if moneyPaga then
                OpenMailFrame.CODAmountTips:SetVertexColor(1,0,0)
                OpenMailFrame.moneyPagaTip:SetTextColor(1,0,0)
            elseif moneyGet then
                OpenMailFrame.CODAmountTips:SetVertexColor(0,1,0)
                OpenMailFrame.moneyPagaTip:SetTextColor(0,1,0)
            end
            OpenMailFrame.CODAmountTips:SetShown((moneyPaga or moneyGet) and not Save.hide)

            if (moneyPaga or moneyGet) then
                local text
                if moneyPaga then
                    text= (e.onlyChinese and '付款' or COD)
                elseif moneyGet then
                    text= (e.onlyChinese and '可取' or WITHDRAW)
                end
                text= text..' '..get_Money(moneyPaga or moneyGet)
                OpenMailFrame.moneyPagaTip:SetText(text)
            else
                OpenMailFrame.moneyPagaTip:SetText('')
            end
        end
    end)
end





































local P_INBOXITEMS_TO_DISPLAY= INBOXITEMS_TO_DISPLAY--7

local function Set_Inbox_btn_Point(frame, index)--设置，模板，内容，位置
    if frame then
        frame:SetPoint('RIGHT', -17, 0)
        _G['MailItem'..index..'Sender']:SetPoint('RIGHT', -40, 0)
        _G['MailItem'..index..'Subject']:SetPoint('RIGHT', -2, 0)
        local region= select(2, frame:GetRegions())
        if region and region:GetObjectType()=='Texture' then
            region:SetPoint('LEFT', MailItem6ButtonSlot, 'RIGHT', -16, 0)
        end
    end
end

local function Set_Inbox_Button()--显示，隐藏，建立，收件，物品
    for i=P_INBOXITEMS_TO_DISPLAY +1, INBOXITEMS_TO_DISPLAY, 1 do
        local frame= _G['MailItem'..i]
        if not frame then
            frame= CreateFrame('Frame', 'MailItem'..i, InboxFrame, 'MailItemTemplate')
            frame:SetPoint('TOPLEFT', _G['MailItem'..(i-1)], 'BOTTOMLEFT')
            Set_Inbox_btn_Point(frame, i)--设置，模板，内容，位置
        end
        frame:SetShown(true)
    end
    local index= INBOXITEMS_TO_DISPLAY+1--隐藏    
    while _G['MailItem'..index] do
        _G['MailItem'..index]:SetShown(false)
        index= index+1
    end
    --InboxFrameBg:SetShown(Save.INBOXITEMS_TO_DISPLAY)--因为图片，大小不一样，所有这样处理
end

local function Init_UI()
    --收件箱
    InboxFrame:SetPoint('RIGHT')
    for i= 1, INBOXITEMS_TO_DISPLAY do--7
        Set_Inbox_btn_Point(_G['MailItem'..i], i)--设置，模板，内容，位置
    end

    InboxFrame:SetPoint('BOTTOMRIGHT')
    InboxPrevPageButton:ClearAllPoints()
    InboxPrevPageButton:SetPoint('BOTTOMLEFT', 10, 10)
    InboxNextPageButton:SetPoint('BOTTOMRIGHT', -10, 10)
    OpenAllMail:ClearAllPoints()--全部打开
    OpenAllMail:SetPoint('BOTTOM', 0, 10)

    --InboxFrameBg:SetAtlas('QuestBG-Parchment')
    InboxFrameBg:SetAlpha(0.3)
    InboxFrameBg:SetTexture(0)
    InboxFrameBg:SetPoint('BOTTOMRIGHT', -4,4)

    --发件箱
    SendMailFrame:SetPoint('BOTTOMRIGHT', 384-338, 424-512)
    SendMailHorizontalBarLeft:ClearAllPoints()
    SendMailHorizontalBarLeft:SetPoint('BOTTOMLEFT', SendMailMoneyButton, 'TOPLEFT', -14, -4)
    SendMailHorizontalBarLeft:SetPoint('RIGHT', MailFrame, -80, 0)
    SendMailHorizontalBarLeft2:SetPoint('RIGHT', MailFrame, -80, 0)

    SendMailScrollFrame:SetPoint('RIGHT', MailFrame, -34, 0)
    SendMailScrollFrame:SetPoint('BOTTOM', SendMailHorizontalBarLeft2, 'TOP')
    SendMailScrollChildFrame:SetPoint('BOTTOMRIGHT')
    SendStationeryBackgroundLeft:SetPoint('BOTTOMRIGHT', -42, 0)
    SendStationeryBackgroundRight:SetPoint('BOTTOM')

    SendMailBodyEditBox:SetPoint('BOTTOMRIGHT', SendMailScrollFrame)


    SendMailSubjectEditBox:SetPoint('RIGHT', MailFrame, -28, 0)--主题
    SendMailSubjectEditBoxMiddle:SetPoint('RIGHT', -8, 0)
    SendMailNameEditBox:SetPoint('RIGHT', SendMailCostMoneyFrame, 'LEFT', -32, 0)--收件人
    SendMailNameEditBoxMiddle:SetPoint('RIGHT', -8, 0)





    if Save.INBOXITEMS_TO_DISPLAY then
        INBOXITEMS_TO_DISPLAY= Save.INBOXITEMS_TO_DISPLAY
        Set_Inbox_Button()--显示，隐藏，建立，收件，物品    
    end
    e.Set_Move_Frame(MailFrame, {setSize=true, needSize=true, needMove=true, minW=338, minH=424, sizeUpdateFunc=function(btn)
        local h= btn.target:GetHeight()-424
        local num= P_INBOXITEMS_TO_DISPLAY
        if h>45 then
            num= num+ math.modf(h/45)
        end
        INBOXITEMS_TO_DISPLAY=num
        Set_Inbox_Button()--显示，隐藏，建立，收件，物品
        Save.INBOXITEMS_TO_DISPLAY= num>P_INBOXITEMS_TO_DISPLAY and num or nil
        if InboxFrame:IsVisible() then
            e.call('InboxFrame_Update')
        else
            e.call('SendMailFrame_Update')
        end
    end, sizeRestFunc=function(btn)
        btn.target:SetSize(338, 424)
        Save.INBOXITEMS_TO_DISPLAY=nil
        INBOXITEMS_TO_DISPLAY= P_INBOXITEMS_TO_DISPLAY
        Set_Inbox_Button()--显示，隐藏，建立，收件，物品
    end

    })
    e.Set_Move_Frame(SendMailFrame, {frame=MailFrame})

end

















local function set_SendStationeryBackground_Alpha(alpha)--收件箱，内容，背景，透明度
    SendStationeryBackgroundLeft:SetAlpha(alpha)
    SendStationeryBackgroundRight:SetAlpha(alpha)
end

local function Init_Edit_Letter_Num()--字数
    for _, frame in pairs({SendMailNameEditBox, SendMailSubjectEditBox, SendMailBodyEditBox}) do
        if frame:GetMaxLetters()>0 then
            frame.numLetters= e.Cstr(frame)
            if frame:IsMultiLine() then
                frame.numLetters:SetPoint('BOTTOMRIGHT')
            else
                frame.numLetters:SetPoint('RIGHT')
            end
            frame.numLetters:SetAlpha(0)
            frame:HookScript('OnTextChanged', function(self)
                self.numLetters:SetFormattedText('%d/%d', self:GetNumLetters() or 0, self:GetMaxLetters())
            end)

            if frame==SendMailBodyEditBox then
                set_SendStationeryBackground_Alpha(0.5)--收件箱，内容，背景，透明度
                frame:HookScript('OnEditFocusGained', function(self)
                    self.numLetters:SetAlpha(1)
                    set_SendStationeryBackground_Alpha(1)--收件箱，内容，背景，透明度
                end)
                frame:HookScript('OnEditFocusLost', function(self)
                    self.numLetters:SetAlpha(0)
                    set_SendStationeryBackground_Alpha(0.5)--收件箱，内容，背景，透明度
                end)
            else
                frame:HookScript('OnEditFocusGained', function(self)
                    self.numLetters:SetAlpha(1)
                end)
                frame:HookScript('OnEditFocusLost', function(self)
                    self.numLetters:SetAlpha(0)
                end)
            end
        end
    end
end
































local function set_button_Show_Hide()
    if not Save.hide then
        Init_Button()
        Init_Fast_Button()
        if button then
            button.GetTargetNameButton:RegisterEvent('PLAYER_TARGET_CHANGED')
            button.GetTargetNameButton:RegisterEvent('RAID_TARGET_UPDATE')
        end
        Init_InBox()--收信箱，物品，提示

    else
        if button then
            button.GetTargetNameButton:UnregisterAllEvents()
        end
    end
    if button then
        button:SetShown(not Save.hide)
    end
end


--####
--初始
--####
local function Init()--SendMailNameEditBox
    Init_UI()
    Init_Edit_Letter_Num()--字数

    panel.showButton= e.Cbtn(MailFrame.TitleContainer, {size={size,size}, icon='hide'})
    if _G['MoveZoomInButtonPerMailFrame'] then
        panel.showButton:SetPoint('RIGHT', _G['MoveZoomInButtonPerMailFrame'], 'LEFT')
    else
        panel.showButton:SetPoint('LEFT', MailFrame.TitleContainer, -5, 0)
        panel.showButton:SetFrameLevel(MailFrame.TitleContainer:GetFrameLevel()+1)
    end

    panel.showButton:SetAlpha(0.3)
    panel.showButton:SetScript('OnClick', function(_, d)
        if d=='LeftButton' then
            Save.hide= not Save.hide and true or nil
            set_button_Show_Hide()
            panel.showButton:SetNormalAtlas(Save.hide and e.Icon.disabled or e.Icon.icon)

            if OpenMailFrame:IsShown() then
                e.call('OpenMail_Update')
            end
            if InboxFrame:IsShown() then
                e.call('InboxFrame_Update')
            end
        elseif d=='RightButton' then
            e.OpenPanelOpting(Initializer)
        end
    end)

    panel.showButton:SetScript('OnLeave', function(self)
        self:SetAlpha(0.3)
        e.tips:Hide()
    end)
    panel.showButton:SetScript('OnEnter', function(self)
        self:SetAlpha(1)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.GetShowHide(nil, true), e.Icon.left)--not e.onlyChinese and SHOW..'/'..HIDE or '显示/隐藏')
        e.tips:AddDoubleLine(e.onlyChinese and '选项' or OPTIONS, e.Icon.right)
        e.tips:Show()
    end)
    panel.showButton:SetNormalAtlas(Save.hide and e.Icon.disabled or e.Icon.icon)

    local function set_Show_MailFrame_Init()
        if Save.lastSendPlayer and not Save.hideSendPlayerList and not Save.hide and Save.lastSendPlayer~=e.Player.name_realm then--记录 SendMailNameEditBox，内容
            set_Text_SendMailNameEditBox(nil, Save.lastSendPlayer)--设置，发送名称，文

        end
        if button then
            button.GetTargetNameButton.set_GetTargetNameButton_Texture(button.GetTargetNameButton)--目标，名称，按钮，显示/隐藏--目标，名称
            button.ClearPlayerButton.setAlpha(button.ClearPlayerButton)--设置，历史记录，清除按钮透明度
        end
    end
    MailFrame:HookScript('OnShow', function()
        set_button_Show_Hide()
        local canCheck, timeUntilAvailable = C_Mail.CanCheckInbox()
        if canCheck then
            set_Show_MailFrame_Init()
        else
            C_Timer.After(timeUntilAvailable, set_Show_MailFrame_Init)
        end
        C_Timer.After(1, function()
            if GetInboxNumItems()==0 then--如果没有信，转到，发信
                MailFrameTab_OnClick(nil, 2)
            end
        end)
    end)

    MailFrame:HookScript('OnHide', function()
        if button then
            button.GetTargetNameButton:UnregisterAllEvents()
        end
    end)

    SendMailNameEditBox:HookScript('OnEditFocusLost', function(self)
        Save.lastSendPlayer= e.GetUnitName(self:GetText()) or Save.lastSendPlayer----记录 SendMailNameEditBox，内容
    end)

    SendMailMailButton:HookScript('OnClick', function()--SendName，设置，发送成功，名字
        if button then
            button.SendName= e.GetUnitName(SendMailNameEditBox:GetText())--取得，收件人，名称

            if not Save.hide and Save.fastShow then
                C_Timer.After(1.5, function()
                    button.FastButton.get_Send_Max_Item()--能发送，数量
                    button.FastButton.set_Fast_Event()--清除，注册，事件，显示/隐藏，设置数量
                end)
            end
        end
    end)
    SendMailFrame:HookScript('OnShow', function ()
        SendMailNameEditBox:ClearFocus()
    end)

end






























panel:RegisterEvent('ADDON_LOADED')
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            Save.lastSendPlayerList= Save.lastSendPlayerList or {}
            Save.lastMaxSendPlayerList= Save.lastMaxSendPlayerList or 20

            if e.Player.husandro and #Save.lastSendPlayerList==0 then
                --1US(includes Brazil and Oceania) 2Korea 3Europe (includes Russia) 4Taiwan 5China
                if e.Player.region==3 then
                    Save.lastSendPlayerList= {
                        'Zans-Nemesis',
                        'Qisi-Nemesis',
                        'Sandroxx-Nemesis',
                        'Fuocco-Nemesis',
                        'Sm-Nemesis',
                        'Xiaod-Nemesis',
                        'Dz-Nemesis',
                        'Ws-Nemesis',
                        'Sosi-Nemesis',
                        'Maggoo-Nemesis',
                        'Dhb-Nemesis',
                        'Ms-Nemesis',--最大存20个
                    }
                    Save.fast={
                        [e.onlyChinese and '布甲' or C_Item.GetItemSubClassInfo(4, 1)]= 'Ms-Nemesis',--布甲
                        [e.onlyChinese and '皮甲' or C_Item.GetItemSubClassInfo(4, 2)]= 'Xiaod-Nemesis',--皮甲
                        [e.onlyChinese and '锁甲' or C_Item.GetItemSubClassInfo(4, 3)]= 'Fuocco-Nemesis',--锁甲
                        [e.onlyChinese and '板甲' or C_Item.GetItemSubClassInfo(4, 4)]= 'Zans-Nemesis',--板甲
                        [e.onlyChinese and '盾牌' or C_Item.GetItemSubClassInfo(4, 6)]= 'Zans-Nemesis',--盾牌
                        [e.onlyChinese and '武器' or C_Item.GetItemClassInfo(2)]= 'Zans-Nemesis',--武器

                    }
                end
            end

            --添加控制面板
            Initializer= e.AddPanel_Check({
                name= '|A:UI-HUD-Minimap-Mail-Mouseover:0:0|a'..(e.onlyChinese and '邮件' or addName),
                tooltip= e.cn(addName),
                value= not Save.disabled,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(Initializer:GetName(), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
                panel:UnregisterEvent('ADDON_LOADED')
            end
            panel:RegisterEvent('PLAYER_LOGOUT')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end

end)