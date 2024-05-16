if GameLimitedMode_IsActive() then--受限模式
    return
end

local id, e= ...
local addName= BUTTON_LAG_MAIL
local Save={
    --hide=true,--隐藏


    lastSendPlayerList= {},--历史记录, {'名字-服务器',},
    --hideSendPlayerList=true,--隐藏，历史记录
    lastMaxSendPlayerList=20,--记录, 最大数

    show={--显示离线成员
        ['FRIEND']=true,--好友
        --['GUILD']=true,--公会
    },

    fast={},--快速，加载，物品，指定玩家
    fastShow=true,--显示/隐藏，快速，加载，按钮
    --CtrlFast= e.Player.husandro,--Ctrl+RightButton,快速，加载，物品
    --scaleSendPlayerFrame=1.2,--清除历史数据，缩放

    scaleFastButton=1.3,

    --INBOXITEMS_TO_DISPLAY=7,

    logSendInfo= e.Player.husandro,--隐藏时不,清除，内容
    --lastSendPlayer='Fuocco-server',--收件人
    --lastSendSub=主题
    --lastSendBody=内容
}







local fastButton
local Initializer














local NiHao= (e.Player.region==5 or e.Player.region==4) and '你好' or EMOTE56_CMD1:gsub('/','')


local function set_Text_SendMailNameEditBox(_, name)--设置，发送名称，文
    if name then
        name= name:gsub('%-'..e.Player.realm, '')
        SendMailNameEditBox:SetText(name)
        SendMailNameEditBox:SetCursorPosition(0)
        SendMailNameEditBox:ClearFocus()
        C_Timer.After(0.5, function()
            if SendMailSubjectEditBox:GetText()=='' then
                SendMailSubjectEditBox:SetText(NiHao)
                SendMailSubjectEditBox:SetCursorPosition(0)
                SendMailSubjectEditBox:ClearFocus()
            end
        end)
    end
end

local function get_Name_Info(name)--取得名称，信息
    if name then
        local reName
        name = e.GetUnitName(name)--取得全名
        for guid, tab in pairs(e.WoWDate) do
            if name== e.GetUnitName(nil, nil, guid) then
                reName= '|A:auctionhouse-icon-favorite:0:0|a'..e.GetPlayerInfo({guid=guid, faction=tab.faction, reName=true, realm=true})
                break
            end
        end
        reName= reName or e.GetPlayerInfo({name=name, reName=true, reRealm=true})
        return reName and reName:gsub('%-'..e.Player.realm, '') or name
    end
end

local function Get_Realm_Info(name)
    local realm= name and name:match('%-(.+)')
    if realm and not (e.Player.Realms[realm] or realm==e.Player.realm) then
        return format('|cnRED_FONT_COLOR:%s|r', e.onlyChinese and '该玩家与你不在同一个服务器' or ERR_PETITION_NOT_SAME_SERVER)
    end
end



local function Refresh_All()
    if InboxFrame:IsShown() then
        e.call('InboxFrame_Update')
    elseif SendMailFrame:IsShown() then
        e.call('SendMailFrame_Update')
    end
    if OpenMailFrame:IsShown() then
        e.call('OpenMail_Update')
    end
end



--设置，快速选取，按钮
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

















--#######
--设置菜单
--#######
local function Init_Menu(_, level, menuList)
    local info
    if menuList=='SELF' then
        local find
        for guid, _ in pairs(e.WoWDate) do
            if guid and guid~= e.Player.guid then
                local name= e.GetUnitName(nil, nil, guid)
                if not Get_Realm_Info(name) then
                    e.LibDD:UIDropDownMenu_AddButton({
                        text= e.GetPlayerInfo({guid=guid, reName=true, reRealm=true}),
                        icon= 'auctionhouse-icon-favorite',
                        tooltipOnButton=true,
                        tooltipTitle=name,
                        keepShownOnClick= true,
                        notCheckable= true,
                        arg1= name,
                        func= set_Text_SendMailNameEditBox,
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
        for i=1 , C_FriendList.GetNumFriends() do
            local game=C_FriendList.GetFriendInfoByIndex(i)
            if game and game.guid and (game.connected or Save.show['FRIEND']) and not e.WoWDate[game.guid] then
                local name= e.GetUnitName(nil, nil, game.guid)
                if not Get_Realm_Info(name) then
                    local text= e.GetPlayerInfo({guid=game.guid, reName=true, reRealm=true})--角色信息
                    text= (game.level and game.level~=MAX_PLAYER_LEVEL and game.level>0) and text .. ' |cff00ff00'..game.level..'|r' or text--等级
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
                        func= set_Text_SendMailNameEditBox,
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
            checked= Save.show['FRIEND'],
            tooltipOnButton= true,
            tooltipTitle= e.onlyChinese and '显示离线成员' or COMMUNITIES_MEMBER_LIST_SHOW_OFFLINE,
            tooltipText= e.GetEnabeleDisable(Save.show['FRIEND']),
            func= function()
                Save.show['FRIEND']= not Save.show['FRIEND'] and true or nil
            end
        }, level)

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
                if not Get_Realm_Info(name) then
                    local text= e.GetPlayerInfo({guid=wowInfo.playerGuid, reName=true, reRealm=true, factionName=wowInfo.factionName})--角色信息

                    if wowInfo.characterLevel and wowInfo.characterLevel~=MAX_PLAYER_LEVEL and wowInfo.characterLevel>0 then--等级
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
                        func= set_Text_SendMailNameEditBox,
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
                e.LibDD:UIDropDownMenu_AddButton({
                    text=text,
                    icon=icon,
                    keepShownOnClick= true,
                    notCheckable=true,
                    tooltipOnButton=true,
                    tooltipTitle=publicNote or '',
                    tooltipText=officerNote or '',
                    arg1= name,
                    func= set_Text_SendMailNameEditBox,
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
            checked= Save.show['GUILD'],
            tooltipOnButton= true,
            tooltipTitle= e.onlyChinese and '显示离线成员' or COMMUNITIES_MEMBER_LIST_SHOW_OFFLINE,
            tooltipText= e.GetEnabeleDisable(Save.show['GUILD']),
            func= function()
                Save.show['GUILD']= not Save.show['GUILD'] and true or nil
            end
        }, level)

    --[[elseif menuList=='GROUP' then
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
        end]]

    elseif menuList and type(menuList)=='number' then--社区
        local num=0
        local members= C_Club.GetClubMembers(menuList) or {}
        for index, memberID in pairs(members) do
            local tab = C_Club.GetMemberInfo(menuList, memberID) or {}
            if tab.guid and tab.name and (tab.zone or tab.role<4 or (Save.show[menuList] and num<60)) and not e.WoWDate[tab.guid] then
                if not Get_Realm_Info(tab.name) then
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

                    e.LibDD:UIDropDownMenu_AddButton({
                        text= index..(index<10 and ')  ' or ') ')..text.. (tab.zone and format('|A:%s:0:0|a', e.Icon.select) or ''),
                        icon= icon,
                        keepShownOnClick= true,
                        notCheckable=true,
                        tooltipOnButton=true,
                        tooltipTitle=tab.memberNote or '',
                        tooltipText=tab.officerNote,
                        arg1= tab.name,
                        func= set_Text_SendMailNameEditBox,
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

    --[[e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= '|A:UI-HUD-UnitFrame-Player-Group-GuideIcon-2x:0:0|a'..(e.onlyChinese and '队员' or PLAYERS_IN_GROUP),
        disabled= GetNumGroupMembers()<2,
        hasArrow= true,
        notCheckable=true,
        menuList= 'GROUP',
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)]]


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

    --[[e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= e.onlyChinese and '设置' or SETTINGS,
        hasArrow=true,
        menuList='SETTINGS',
        notCheckable=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)]]
    e.LibDD:UIDropDownMenu_AddSeparator(level)
    e.LibDD:UIDropDownMenu_AddButton({
        text= e.onlyChinese and '保存内容' or format(GUILDBANK_LOG_TITLE_FORMAT, INFO),--"%s 记录",
        keepShownOnClick=true,
        checked= Save.logSendInfo,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '收件人：' or MAIL_TO_LABEL,
        tooltipText= e.onlyChinese and '主题：' or MAIL_SUBJECT_LABEL,
        func=function()
            Save.logSendInfo= not Save.logSendInfo and true or nil
            SendMailNameEditBox:save_log()
            SendMailSubjectEditBox:save_log()
            SendMailBodyEditBox:save_log()
        end
    }, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= id..' '..Initializer:GetName(),
        notCheckable= true,
        isTitle=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end









































































--快速，加载，物品，菜单
local function Init_Fast_Menu(frame, level, menuList)
    local self= frame:GetParent()
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
                    self:set_PickupContainerItem(arg1, arg2, nil)
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
                self:set_PickupContainerItem(arg1, nil, nil)
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
    
    e.LibDD:UIDropDownMenu_AddSeparator(level)
    e.LibDD:UIDropDownMenu_AddButton({
        text= e.onlyChinese and '显示' or SHOW,
        checked= Save.fastShow,
        keepShownOnClick=true,
        func= function()
            Save.fastShow= not Save.fastShow and true or nil
            self:set_shown()
        end
    }, level)
end









local function Init_Fast_Button_Menu(frame, level, menuList)
    local self= frame:GetParent()
    local icon= '|T'..(self:GetNormalTexture():GetTexture() or 0)..':0|t'
    if menuList=='SELF' then
        local find
        local name= Save.fast[self.name]
        local tab= {}
        for guid, _ in pairs(e.WoWDate) do
            local playerName= e.GetUnitName(nil, nil, guid)
            if playerName then
                local realm= Get_Realm_Info(playerName)
                local info= {
                    text= e.GetPlayerInfo({guid=guid, reName=true, reRealm=true}),
                    checked= name and name==playerName,
                    icon= realm and 'quest-legendary-available',
                    tooltipOnButton=true,
                   tooltipTitle=icon..self.name,
                    tooltipText=playerName..(realm and '|n'..realm or ''),
                    arg1= self.name,
                    arg2= playerName,
                    func= function(_, arg1, arg2)
                        if arg2 then
                            Save.fast[arg1]= arg2
                            print(id, Initializer:GetName(), arg1, arg2)
                            self:set_Player_Lable()
                        end
                    end,
                }
                if realm then
                    table.insert(tab, info)
                else
                    table.insert(tab, 1, info)
                end
            end
        end
        for _, info in pairs(tab) do
            e.LibDD:UIDropDownMenu_AddButton(info, level)
            find=true
        end
        if not find then
            e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
        end
        return
    end

    local playerName= Save.fast[self.name]
    local newName= e.GetUnitName(SendMailNameEditBox:GetText())
    e.LibDD:UIDropDownMenu_AddButton({
        text=icon..self.name..': '..(playerName and e.GetPlayerInfo({name=playerName, reName=true}) or format('|cff606060%s|r', e.onlyChinese and '无' or NONE)),
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

end






--####################
--快速，加载，物品，按钮
--####################
local function Init_Fast_Button()
    fastButton= e.Cbtn(SendMailFrame, {size={22, 22}, icon='hide'})
    fastButton:SetPoint('BOTTOMLEFT', MailFrameCloseButton, 'BOTTOMRIGHT',0, -2)
    fastButton.buttons={}
    fastButton.frame= CreateFrame('Frame', nil, fastButton)
    fastButton.frame:SetSize(1, 1)
    fastButton.frame:SetPoint('TOPLEFT', fastButton, 'BOTTOMLEFT')


    function fastButton:set_scale()
        self.frame:SetScale(Save.scaleFastButton or 1)
    end
    function fastButton:set_shown()
        self.frame:SetShown(Save.fastShow)
        self:SetAlpha(Save.fastShow and 1 or 0.3)
        self:SetNormalAtlas(Save.fastShow and 'NPE_ArrowDown' or 'NPE_ArrowRight')
    end
    function fastButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.left)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.scaleFastButton or 1), e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:Show()
    end
    fastButton:SetScript('OnLeave', function(self)
        e.tips:Hide()
        for _, btn in pairs(self.buttons) do
            btn:set_alpha()
        end
    end)
    fastButton:SetScript('OnEnter', function(self)
        self:set_tooltips()
        for _, btn in pairs(self.buttons) do
            btn:SetAlpha(1)
        end
    end)
    fastButton:SetScript('OnMouseDown', function(self)
        if not self.Menu then
            self.Menu= CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
            e.LibDD:UIDropDownMenu_Initialize(self.Menu, Init_Fast_Menu, 'MENU')
        end
        e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
    end)
    fastButton:SetScript('OnMouseWheel', function(self, d)
        local num= Save.scaleFastButton or 1
        num= d==1 and num-0.05 or num
        num= d==-1 and num+0.05 or num
        num= num<0.4 and 0.4 or num
        num= num>4 and 4 or num
        Save.scaleFastButton= num
        self:set_scale()
        self:set_tooltips()
    end)
     
    fastButton:set_scale()
    fastButton:set_shown()





    function fastButton:get_send_max_item()--能发送，数量
        local tab={}
        for i= 1, ATTACHMENTS_MAX_SEND do
            if not HasSendMailItem(i) then
                table.insert(tab, i)
            end
        end
        self.canSendTab= tab
    end
    hooksecurefunc('SendMailFrame_Update', function() fastButton:get_send_max_item() end)

    function fastButton:set_PickupContainerItem(classID, subClassID, findString)--自动放物品
        if #self.canSendTab>0 then
            for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES+ NUM_REAGENTBAG_FRAMES do
                for slot=1, C_Container.GetContainerNumSlots(bag) do
                    local info= check_Enabled_Item(classID, subClassID, findString, bag, slot)
                    if info then
                        C_Container.PickupContainerItem(bag, slot)
                        ClickSendMailItemButton(self.canSendTab[1])
                        if #self.canSendTab==0 or not self:IsShown() then
                            return
                        end
                    end
                end
            end
        end
    end






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
    for _, tab in pairs(fast) do
        if tab~='-' then
            local btn= e.Cbtn(fastButton.frame, {size=22, texture=tab[1]})
            btn:SetPoint('TOPLEFT', fastButton.frame,'BOTTOMLEFT', x, y)

            btn.classID= tab[2]
            btn.subClassID= tab[3]
            btn.name= tab[4] or not tab[3] and C_Item.GetItemClassInfo(tab[2]) or C_Item.GetItemSubClassInfo(tab[2], tab[3])
            btn.findString= tab[5]

            btn.Text= e.Cstr(btn, {size=10})
            btn.Text:SetPoint('TOPLEFT')
            btn.Text2= e.Cstr(btn, {size=10})
            btn.Text2:SetPoint('BOTTOMRIGHT')
            btn.playerTexture= btn:CreateTexture(nil, 'OVERLAY')
            btn.playerTexture:SetAtlas('AnimaChannel-Bar-Necrolord-Gem')
            btn.playerTexture:SetSize(22/2, 22/2)
            btn.playerTexture:SetPoint('BOTTOMLEFT')
            function btn:set_Player_Lable()--设置指定发送，玩家, 提示
                self.playerTexture:SetShown(Save.fast[self.name] and true or false)
            end
            btn:set_Player_Lable()
            function btn:set_alpha()
                self:SetAlpha(self.stack and self.stack>0 and 1 or 0.1)
            end
            function btn:settings()
                if self.checking then
                    return
                end
                self.checking=true
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
                self.Text:SetText(num==stack and '' or num)
                self.Text2:SetText(stack>0 and stack or '' )
                self.num=num
                self.stack=stack
                self:set_alpha()
                self.checking=nil
            end
            function btn:set_event()
                if self:IsShown() then
                    self:settings()
                    self:RegisterEvent('BAG_UPDATE_DELAYED')
                    self:RegisterEvent('MAIL_SEND_INFO_UPDATE')
                else
                    self:UnregisterAllEvents()
                end
            end
            btn:SetScript('OnEvent', btn.settings)
            btn:SetScript('OnShow', btn.set_event)
            btn:SetScript('OnHide', btn.set_event)

            btn:SetScript('OnClick', function(self, d)
                if d=='LeftButton' then
                    local name= Save.fast[self.name]
                    if name and name~=e.Player.name_realm then
                        set_Text_SendMailNameEditBox(nil, name)--设置，发送名称，文
                    end
                    self:GetParent():GetParent():set_PickupContainerItem(self.classID, self.subClassID, self.findString)--自动放物品
                elseif d=='RightButton' then
                    if not self.Menu then
                        self.Menu= CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                        e.LibDD:UIDropDownMenu_Initialize(self.Menu, Init_Fast_Button_Menu, 'MENU')
                    end
                    e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
                end
            end)

            btn:SetScript('OnLeave', function(self) self:set_alpha() e.tips:Hide() self:settings() end)
            btn:SetScript('OnEnter', function(self)
                self:settings()
                local playerName= Save.fast[self.name]
                local playerNameInfo= get_Name_Info(playerName)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine('|T'..(self:GetNormalTexture():GetTexture() or 0)..':0|t'..self.name, get_Name_Info(playerName))
                e.tips:AddDoubleLine((e.onlyChinese and '添加' or ADD)..e.Icon.left, playerName and playerName~=playerNameInfo and playerName)
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
            table.insert(fastButton.buttons, btn)
            y= y- 22
        else
            x= x+ 22
            y=0
        end
    end

    local texture= fastButton.frame:CreateTexture(nil, 'BACKGROUND')--添加，背景
    texture:SetAtlas('footer-bg')
    texture:SetPoint("TOPLEFT", fastButton.buttons[1],-2, 2)
    texture:SetPoint('BOTTOMRIGHT', fastButton.buttons[#fastButton.buttons], 2, -2)
end






























local function get_Money(num)
    local text
    if num and num>0 then
        if num>=1e4 then
            text= e.MK(num/1e4, 2)..'|TInterface/moneyframe/ui-goldicon:0|t'
        else
            text= GetMoneyString(num)
        end
    end
    return text or ''
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





--收信箱，物品，提示
local function Init_InBox()
    local showButton= e.Cbtn(InboxFrame, {size=22, icon='hide'})
    showButton:SetFrameStrata(MailFrame.TitleContainer:GetFrameStrata())
    showButton:SetFrameLevel(MailFrame.TitleContainer:GetFrameLevel()+1)
    showButton:SetPoint('LEFT', MailFrame.TitleContainer, -5, 0)
    showButton:SetAlpha(0.3)
    function showButton:set_texture()
        self:SetNormalAtlas(Save.hide and e.Icon.disabled or e.Icon.icon)
    end
    showButton:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            Save.hide= not Save.hide and true or nil
            self:set_texture()
            Refresh_All()
        elseif d=='RightButton' then
            e.OpenPanelOpting(Initializer)
        end
    end)

    showButton:SetScript('OnLeave', function(self)
        self:SetAlpha(0.3)
        e.tips:Hide()
    end)
    showButton:SetScript('OnEnter', function(self)
        self:SetAlpha(1)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.GetShowHide(nil, true), e.Icon.left)--not e.onlyChinese and SHOW..'/'..HIDE or '显示/隐藏')
        e.tips:AddDoubleLine(e.onlyChinese and '选项' or OPTIONS, e.Icon.right)
        e.tips:Show()
    end)
    showButton:set_texture()



    hooksecurefunc('InboxFrame_Update',function()
        local totalItems= select(2, GetInboxNumItems())  --信件，总数量
        for i=1, INBOXITEMS_TO_DISPLAY do
            local btn=_G["MailItem"..i.."Button"]
            if btn and btn:IsShown() then
                local packageIcon, stationeryIcon, sender, subject, money2, CODAmount2, daysLeft, itemCount2, wasRead, wasReturned, textCreated, canReply, isGM, firstItemQuantity, firstItemLink = GetInboxHeaderInfo(btn.index)
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
                                    e.tips:SetOwner(self:GetParent(), "ANCHOR_LEFT")
                                    e.tips:ClearLines()
                                    e.tips:AddDoubleLine(id, Initializer:GetName())
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
                    btn.DeleteButton= e.Cbtn(btn, {size=18})
                    if _G['MailItem'..i..'ExpireTime'] and _G['MailItem'..i..'ExpireTime'].returnicon then
                        btn.DeleteButton:SetPoint('RIGHT', _G['MailItem'..i..'ExpireTime'].returnicon, 'LEFT')
                    else
                        btn.DeleteButton:SetPoint('BOTTOMRIGHT', _G['MailItem'..i])
                    end
                    btn.DeleteButton:SetScript('OnClick', function(self)--OpenMail_Delete()
                        return_delete_InBox(self.openMailID)--删除，或退信
                        C_Timer.After(0.3, function()
                            if GameTooltip:IsOwned(self) then
                                eventEnter(self)
                                local frame= self:GetParent()
                                frame.enterTipTexture:SetShown(true)
                            end
                        end)
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

                e.Set_Item_Info(btn, {itemLink= not Save.hide and firstItemLink})
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

        local moneyPaga= CODAmount and CODAmount>0 and CODAmount or nil
        local moneyGet= money and money>0 and money or nil

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

        for i=1, ATTACHMENTS_MAX_RECEIVE do--物品，信息
            local attachmentButton = OpenMailFrame.OpenMailAttachments[i]
            if attachmentButton and attachmentButton:IsShown() then
                e.Set_Item_Info(attachmentButton, {itemLink= (not Save.hide and HasInboxItem(InboxFrame.openMailID, i)) and GetInboxItemLink(InboxFrame.openMailID, i)})
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
    --InboxFrameBg:SetAlpha(0.3)
    InboxFrameBg:SetTexture(0)
    --InboxFrameBg:SetPoint('BOTTOMRIGHT', -4,4)

    --发件箱
    SendMailFrame:SetPoint('BOTTOMRIGHT', 384-338, 424-512)
    SendMailHorizontalBarLeft:ClearAllPoints()
    SendMailHorizontalBarLeft:SetPoint('BOTTOMLEFT', SendMailMoneyButton, 'TOPLEFT', -14, -4)
    SendMailHorizontalBarLeft:SetPoint('RIGHT', MailFrame, -80, 0)
    SendMailHorizontalBarLeft2:SetPoint('RIGHT', MailFrame, -80, 0)

    SendMailScrollFrame:SetPoint('RIGHT', MailFrame, -34, 0)
    SendMailScrollFrame:SetPoint('BOTTOM', SendMailHorizontalBarLeft2, 'TOP')
    SendMailScrollChildFrame:SetPoint('BOTTOMRIGHT')
    SendStationeryBackgroundLeft:SetPoint('BOTTOMRIGHT', -42, -4)
    SendStationeryBackgroundRight:SetPoint('BOTTOM',0,-4)

    SendMailBodyEditBox:SetPoint('BOTTOMRIGHT', SendMailScrollFrame)


    SendMailSubjectEditBox:SetPoint('RIGHT', MailFrame, -28, 0)--主题
    SendMailSubjectEditBoxMiddle:SetPoint('RIGHT', -8, 0)
    --SendMailNameEditBox:SetPoint('TOPLEFT', 122, -30 )--x="90" y="-30
    SendMailNameEditBox:SetPoint('RIGHT', SendMailCostMoneyFrame, 'LEFT', -54, 0)--收件人
    SendMailNameEditBoxMiddle:SetPoint('RIGHT', -8, 0)



    SendMailCostMoneyFrameCopperButton:SetScript('OnLeave', GameTooltip_Hide)--隐藏， 邮资：，文本
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


    e.Set_Move_Frame(MailFrame, {setSize=true, needSize=true, needMove=true, minW=338, minH=424, initFunc=function(btn)
        if Save.INBOXITEMS_TO_DISPLAY then
            INBOXITEMS_TO_DISPLAY= Save.INBOXITEMS_TO_DISPLAY
            Set_Inbox_Button()--显示，隐藏，建立，收件，物品    
        end
    end, sizeUpdateFunc=function(btn)
        local h= btn.target:GetHeight()-424
        local num= P_INBOXITEMS_TO_DISPLAY
        if h>45 then
            num= num+ math.modf(h/45)
        end
        INBOXITEMS_TO_DISPLAY=num
        Set_Inbox_Button()--显示，隐藏，建立，收件，物品
        Save.INBOXITEMS_TO_DISPLAY= num>P_INBOXITEMS_TO_DISPLAY and num or nil
        Refresh_All()
    end, sizeRestFunc=function(btn)
        btn.target:SetSize(338, 424)
        Save.INBOXITEMS_TO_DISPLAY=nil
        INBOXITEMS_TO_DISPLAY= P_INBOXITEMS_TO_DISPLAY
        Set_Inbox_Button()--显示，隐藏，建立，收件，物品
        Refresh_All()
    end})
    e.Set_Move_Frame(SendMailFrame, {frame=MailFrame})
end

























local function Init_Edit_Letter_Num()--字数
    --收件人
    SendMailNameEditBox.playerTipsLable= e.Cstr(SendMailNameEditBox, {justifyH='CENTER', size=10})
    SendMailNameEditBox.playerTipsLable:SetPoint('BOTTOM', SendMailNameEditBox, 'TOP',0,-3)
    function SendMailNameEditBox:save_log()--保存内容
        Save.lastSendPlayer= Save.logSendInfo and e.GetUnitName(self:GetText()) or nil--收件人
    end
    SendMailNameEditBox:HookScript('OnTextChanged', function(self)
        local name= e.GetUnitName(self:GetText())
        local text= Get_Realm_Info(name) or ''
        if text=='' then
            text= get_Name_Info(name) or text
            if (LOCALE_koKR or LOCALE_zhCN or LOCALE_zhTW or LOCALE_ruRU) and self:GetText():find(' ') then
                text= text..' (|cffffffff'..(e.onlyChinese and '空格键' or KEY_SPACE)..'|r)'
            end
        end
        self.playerTipsLable:SetText(text)
        self:save_log()
    end)

    --主题
    SendMailSubjectEditBox.numLetters= e.Cstr(SendMailSubjectEditBox)
    SendMailSubjectEditBox.numLetters:SetPoint('RIGHT')
    SendMailSubjectEditBox.numLetters:SetAlpha(0)
    function SendMailSubjectEditBox:save_log()--保存内容
        local text
        if Save.logSendInfo then
            text= self:GetText() or ''
            if text==NiHao or text:gsub(' ', '')== '' then text= nil end
        end
        Save.lastSendSub=text
    end
    SendMailSubjectEditBox:HookScript('OnTextChanged', function(self)
        self.numLetters:SetFormattedText('%d/%d', self:GetNumLetters() or 0, self:GetMaxLetters() or 0)
        self:save_log()
    end)
    SendMailSubjectEditBox:HookScript('OnEditFocusGained', function(self)
        self.numLetters:SetAlpha(1)
    end)
    SendMailSubjectEditBox:HookScript('OnEditFocusLost', function(self)
        self.numLetters:SetAlpha(0)
    end)

    --内容
    SendMailBodyEditBox.numLetters= e.Cstr(SendMailBodyEditBox)
    SendMailBodyEditBox.numLetters:SetPoint('BOTTOMRIGHT')
    SendMailBodyEditBox.numLetters:SetAlpha(0)
    function SendMailBodyEditBox:wowtools_settings()
        local has= self:HasFocus()
        local alpha= has and 1 or 0.5
        SendStationeryBackgroundLeft:SetAlpha(alpha)--背景，透明度
        SendStationeryBackgroundRight:SetAlpha(alpha)
        self.numLetters:SetAlpha(has and 1 or 0)
    end
    function SendMailBodyEditBox:save_log()--保存内容
        local text
        if Save.logSendInfo then
            text= self:GetText() or ''
            if text:gsub(' ', '')== '' then text= nil end
        end
        Save.lastSendBody=text
    end
    SendMailBodyEditBox:HookScript('OnTextChanged', function(self)
        self.numLetters:SetFormattedText('%d/%d', self:GetNumLetters() or 0, self:GetMaxLetters() or 0)
        self.numLetters:SetFormattedText('%d/%d', self:GetNumLetters() or 0, self:GetMaxLetters() or 0)
        self:save_log()
    end)
    SendMailBodyEditBox:HookScript('OnEditFocusGained', SendMailBodyEditBox.wowtools_settings)
    SendMailBodyEditBox:HookScript('OnEditFocusLost', SendMailBodyEditBox.wowtools_settings)
end















--收件人，列表
function Init_Send_Name_List()
    --下拉，菜单
    local listButton= e.Cbtn(SendMailNameEditBox, {size=22, atlas='common-icon-rotateleft'})
    listButton:SetPoint('LEFT', SendMailNameEditBox, 'RIGHT')
    listButton:SetScript('OnMouseDown', function(self)
        if not self.Menu then
            self.Menu= CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
            e.LibDD:UIDropDownMenu_Initialize(self.Menu, Init_Menu, 'MENU')
        end
        e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
    end)



    --目标，名称
    listButton.btn= e.Cbtn(SendMailNameEditBox, {size=22, icon='hide'})
    listButton.btn:SetPoint('LEFT', listButton, 'RIGHT', 2, 0)
    listButton.btn:SetScript('OnClick', function(self)
        set_Text_SendMailNameEditBox(nil, self.name)
    end)
    listButton.btn:SetScript('OnLeave', GameTooltip_Hide)
    listButton.btn:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(' ')
        e.tips:AddLine(e.onlyChinese and '目标' or TARGET)
        e.tips:AddDoubleLine(e.onlyChinese and '收件人：' or MAIL_TO_LABEL, e.GetPlayerInfo({unit='target', reName=true, reRealm=true}))
        if self.tooltip then
            e.tips:AddLine(self.tooltip)
        end
        e.tips:Show()
    end)

    function listButton:settings()
        local name
        if UnitExists('target') and UnitIsPlayer('target') and not UnitIsUnit('player', 'target') then
            name= e.GetUnitName(nil, 'target', nil)--取得全名
            if name then
                local atlas, texture
                local index= GetRaidTargetIndex('target') or 0
                if index>0 and index<9 then
                    texture= 'Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index
                else
                    atlas= e.GetUnitRaceInfo({unit= 'target', reAtlas=true})
                end
                if texture then
                    self.btn:SetNormalTexture(texture)
                else
                    self.btn:SetNormalAtlas(atlas or 'Adventures-Target-Indicator')
                end
            end
        end

        self.btn.name=name
        self.btn.tooltip= Get_Realm_Info(name)
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
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(' ')
        e.tips:AddLine(e.onlyChinese and '显示好友列表' or SHOW_FRIENDS_LIST)
        e.tips:Show()
    end)

    --清除，收件人
    local clearButton= e.Cbtn(SendMailNameEditBox, {size=22, atlas='bags-button-autosort-up'})
    clearButton:SetPoint('RIGHT', SendMailNameEditBox, 'LEFT', -4, 0)
    clearButton:SetScript('OnLeave', GameTooltip_Hide)
    clearButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, e.onlyChinese and '收件人' or MAIL_TO_LABEL)
        e.tips:Show()
    end)
    clearButton:SetScript('OnClick', function(self)
        self:GetParent():SetText('')
        Refresh_All()
    end)

    --移动 收件人：字符
    local labelSend=select(3, SendMailNameEditBox:GetRegions())
    if labelSend and labelSend:GetObjectType()=='FontString' then
        labelSend:ClearAllPoints()
        labelSend:SetPoint('RIGHT', clearButton, 'LEFT')
    end
end


















local function Init_Send_History_Name()--收件人，历史记录
    local historyButton= e.Cbtn(SendMailFrame, {size=22, icon='hide'})
    SendMailMailButton.historyButton= historyButton

    historyButton:SetPoint('TOPRIGHT', SendMailFrame, 'TOPLEFT', 0, -22)
    historyButton.frame= CreateFrame('Frame', nil, historyButton)
    historyButton.frame:SetPoint('BOTTOMRIGHT')
    historyButton.frame:SetSize(1,1)
    historyButton.Text= e.Cstr(historyButton, {justifyH='RIGHT', color={r=1,g=1,b=1}})--列表，数量
    historyButton.Text:SetPoint('BOTTOMRIGHT', 2, -2)

    historyButton.buttons={}
    function historyButton:created_button(index)
        local btn= e.Cbtn(self.frame, {size={22, 14}, icon='hide'})
        btn:SetPoint('TOPRIGHT', self.frame, 'BOTTOMRIGHT', 0, -(index-1)*14)
        btn.Text= e.Cstr(btn, {justifyH='RIGHT'})
        btn.Text:SetPoint('RIGHT', -2, 0)

        btn:SetScript('OnLeave', function(frame) e.tips:Hide() frame:set_alpha() end)
        btn:SetScript('OnEnter', function(frame)
            e.tips:SetOwner(frame, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, Initializer:GetName())
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(Get_Realm_Info(frame.name) or ' ', frame.name)
            e.tips:Show()
            frame:SetAlpha(1)
        end)
        btn:SetScript('OnClick', function(frame)
            set_Text_SendMailNameEditBox(nil, frame.name)--设置，收件人，名字
        end)
        function btn:set_alpha()
            self:SetAlpha(self.alpha or 1)
        end
        function btn:settings()
            self.Text:SetText(get_Name_Info(self.name))
            self:SetWidth(self.Text:GetWidth()+4)
            self.alpha= (self.name==e.Player.name_realm or Get_Realm_Info(self.name)) and 0.3 or 1
            self:set_alpha()
            self:SetShown(true)
        end
        function btn:clear()
            self:SetShown(false)
            self.Text:SetText('')
            self.name=nil
        end
        self.buttons[index]= btn
        return btn
    end

    function historyButton:set_list()
        self.Text:SetText(#Save.lastSendPlayerList)--列表，数量
        if Save.hideSendPlayerList then
            return
        end
        local index=1
        for _, name in pairs(Save.lastSendPlayerList) do
            if not Get_Realm_Info(name) and name~=e.Player.name_realm then
                local btn= self.buttons[index] or self:created_button(index)
                btn.name=name
                btn:settings()
                index= index+1
            end
        end
        for i= index, #self.buttons, 1 do
            local btn= self.buttons[i]
            if btn then
                btn:clear()
            end
        end
    end

    historyButton:SetScript('OnEvent', function(self, event)
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
                self:set_list()--设置，历史记录，内容
                set_Text_SendMailNameEditBox(nil, self.SendName)
                self.SendName=nil
            end

        elseif event=='MAIL_FAILED' then
            self.SendName=nil
        end
    end)
    SendMailMailButton:HookScript('OnClick', function(self)
        self.historyButton.SendName= e.GetUnitName(SendMailNameEditBox:GetText())
    end)



    function historyButton:settings()
        self:SetNormalAtlas(Save.hideSendPlayerList and e.Icon.disabled or 'NPE_ArrowDown')
        self:SetAlpha(Save.hideSendPlayerList and 0.5 or 1)
        self.frame:SetScale(Save.scaleSendPlayerFrame or 1)
        self.frame:SetShown(not Save.hideSendPlayerList)
    end



    function historyButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.left)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.scaleSendPlayerFrame or 1), e.Icon.mid)
        e.tips:Show()
    end
    historyButton:SetScript('OnLeave', GameTooltip_Hide)
    historyButton:SetScript('OnEnter', historyButton.set_tooltip)

    historyButton:SetScript('OnClick', function(self)
        if not self.Menu then
            self.Menu= CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
            e.LibDD:UIDropDownMenu_Initialize(self.Menu, function(_, level, menuList)
                if menuList then
                    for index, name in pairs(Save.lastSendPlayerList) do
                        local realm= Get_Realm_Info(name)
                        e.LibDD:UIDropDownMenu_AddButton({
                            text=get_Name_Info(name),
                            icon= realm and 'quest-legendary-available',
                            notCheckable=true,
                            tooltipOnButton=true,
                            tooltipTitle=name,
                            tooltipText=(e.onlyChinese and '移除' or REMOVE)..(realm and '|n'.. realm or ''),
                            arg1=index,
                            func=function(_, arg1)
                                local name2= Save.lastSendPlayerList[arg1]
                                table.remove(Save.lastSendPlayerList, arg1)
                                self:set_list()
                                print(id, Initializer:GetName(), format('|cnGREEN_FONT_COLOR:%s|r', e.onlyChinese and '移除' or REMOVE), name2)
                            end
                        }, level)
                    end

                    e.LibDD:UIDropDownMenu_AddSeparator(level)
                    e.LibDD:UIDropDownMenu_AddButton({
                        text= e.onlyChinese and '全部清除' or CLEAR_ALL,
                        notCheckable=true,
                        func= function()
                            Save.lastSendPlayerList={}
                            self:set_list()
                            print(id, Initializer:GetName(), format('|cnGREEN_FONT_COLOR:%s|r',e.onlyChinese and '全部清除' or CLEAR_ALL))
                        end
                    }, level)
                    return
                end
                e.LibDD:UIDropDownMenu_AddButton({
                    text= e.GetShowHide(nil, true),
                    checked= not Save.hideSendPlayerList,
                    func= function()
                        Save.hideSendPlayerList= not Save.hideSendPlayerList and true or nil
                        self:settings()
                        self:set_list()
                    end
                }, level)

                local num= #Save.lastSendPlayerList
                e.LibDD:UIDropDownMenu_AddButton({
                    text= format('%s |cnGREEN_FONT_COLOR:#%d|r', e.onlyChinese and '记录' or EVENTTRACE_LOG_HEADER, num),
                    notCheckable=true,
                    disabled= num==0,
                    menuList='LIST',
                    hasArrow=true,
                }, level)
            end, 'MENU')
        end
        e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
    end)
    historyButton:SetScript('OnMouseWheel', function(self, d)
        local num= Save.scaleSendPlayerFrame or 1
        num= d==1 and num-0.05 or num
        num= d==-1 and num+0.05 or num
        num= num<0.4 and 0.4 or num
        num= num>4 and 4 or num
        Save.scaleSendPlayerFrame= num
        self:settings()
        self:set_tooltip()
    end)

    historyButton:SetScript('OnHide', historyButton.UnregisterAllEvents)
    historyButton:SetScript('OnShow', function(self)
        self:RegisterEvent('MAIL_SEND_SUCCESS')--SendName，设置，发送成功，名字
        self:RegisterEvent('MAIL_FAILED')
        self:set_list()
    end)

    historyButton:settings()
end
















function Init_Clear_All_Send_Items()--清除所有，要发送物品
    local clearSendItem=e.Cbtn(SendMailAttachment7, {size=22, atlas='bags-button-autosort-up'})
    clearSendItem:SetPoint('BOTTOMRIGHT', SendMailAttachment7, 'TOPRIGHT')--,0, -4)
    clearSendItem.Text= e.Cstr(clearSendItem)
    clearSendItem.Text:SetPoint('BOTTOMRIGHT', clearSendItem, 'BOTTOMLEFT',0, 4)
    clearSendItem:SetScript('OnClick', function()
        for i= 1, ATTACHMENTS_MAX_SEND do
            if HasSendMailItem(i) then
                ClickSendMailItemButton(i, true)
            end
        end
    end)
    clearSendItem:SetScript('OnLeave', GameTooltip_Hide)
    clearSendItem:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)
        e.tips:Show()
    end)

    SendMailFrame.clearSendItem= clearSendItem
    hooksecurefunc('SendMailFrame_Update', function()--发信箱，物品，信息
        local self= SendMailFrame
        local num= 0
        for i=1, ATTACHMENTS_MAX_SEND do
            local sendMailAttachmentButton = self.SendMailAttachments[i]
            local has= HasSendMailItem(i)
            if has then
                num= num+ (select(4, GetSendMailItem(i)) or 1)
            end
            if sendMailAttachmentButton and sendMailAttachmentButton:IsShown() then
                e.Set_Item_Info(sendMailAttachmentButton, {itemLink=has and GetSendMailItemLink(i)})
            end
        end
        self.clearSendItem.Text:SetText(num>0 and num or '')
        self.clearSendItem:SetShown(num>0)
    end)

    for _, btn in pairs(SendMailFrame.SendMailAttachments or {}) do
        btn:HookScript('OnLeave', function(self) e.FindBagItem(false, nil) end)
        btn:HookScript('OnEnter', function(self) 
            
            e.FindBagItem(true, {itemLink=GetSendMailItemLink(self:GetID())})
        end)
    end

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














--####
--初始
--####
local function Init()--SendMailNameEditBox
    Init_InBox()--收信箱，物品，提示
    Init_UI()
    Init_Edit_Letter_Num()--字数
    Init_Send_Name_List()--收件人，列表
    Init_Send_History_Name()--收件人，历史记录
    Init_Clear_All_Send_Items()--清除所有，要发送物品


    Init_Fast_Button()


    function MailFrame:set_to_send()
        if Save.lastSendPlayer then--收件人
            set_Text_SendMailNameEditBox(nil, Save.lastSendPlayer)--设置，发送名称，文
        end
        if Save.lastSendSub then--主题
            SendMailSubjectEditBox:SetText(Save.lastSendSub)
        end
        if Save.lastSendBody then--内容
            SendMailBodyEditBox:SetText(Save.lastSendBody)
        end
        SendMailNameEditBox:ClearFocus()
        --local canCheck, timeUntilAvailable = C_Mail.CanCheckInbox()
        C_Timer.After(1, function()
            if GetInboxNumItems()==0 then--如果没有信，转到，发信
                MailFrameTab_OnClick(nil, 2)
            end
        end)
    end
    MailFrame:HookScript('OnShow', MailFrame.set_to_send)
    MailFrame:set_to_send()












end





























local panel= CreateFrame("Frame")
panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_LOGOUT')
panel:SetScript("OnEvent", function(self, event, arg1)
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
                    print(id, Initializer:GetName(), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if not Save.disabled then
                self:RegisterEvent('MAIL_SHOW')
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='MAIL_SHOW' then
        Init()
        self:UnregisterEvent('MAIL_SHOW')
    end
end)