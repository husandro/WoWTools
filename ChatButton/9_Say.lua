local id, e = ...
local Save= {
    --inInstanceBubblesDisabled= e.Player.husandro,
    saveWhisper=true,--保存, 密语
    WhisperTab={},--保存, 密语, 内容 {name=name, wow=wow, guid=guid, msg={text=text, type=type,time=time}}


    --保存上次，内容
    --type='/s',
    --text= e.onlyChinese and '说' or SAY
    --name=玩家名称,
    --isWoW=bool,
    numWhisper=0,--最后密语,数量
}

local addName
local SayButton
local panel= CreateFrame("Frame")

local SLASH_SAY1= SLASH_SAY1
local SLASH_YELL1= SLASH_YELL1
local SLASH_WHISPER1= SLASH_WHISPER1














 --提示，聊天泡泡，开启/禁用
 local function set_chatBubbles_Tips()
    SayButton.tipBubbles:SetShown(not C_CVar.GetCVarBool("chatBubbles"))
end
















--#######
--密语列表
--#######
local function set_numWhisper_Tips()--最后密语,数量, 提示
    SayButton.numWhisper:SetText(Save.numWhisper>0 and Save.numWhisper or '')
end

local function rest_numWhisper_Tips()--重置密语，数量
    Save.numWhisper=0--最后密语,数量, 清空
    set_numWhisper_Tips()--最后密语,数量, 提示
end

local function findWhisper(name)
    for index, tab in pairs(Save.WhisperTab) do
        if tab.name==name then
            return index
        end
    end
end

local function getWhisper(event, text, name, _, _, _, _, _, _, _, _, _, guid)
    if e.Player.name_realm~=name and name then
        local type= event:find('INFORM') and true or nil--_INFORM 发送
        local index=findWhisper(name)
        local tab= {text=text, type=type, player=e.Player.name_realm, time=date('%X')}
        if index then
            Save.WhisperTab[index].guid=guid
            table.insert(Save.WhisperTab[index].msg, tab)
        else
            local wow= event:find('MSG_BN') and true or nil
            table.insert(Save.WhisperTab, 1, {name=name, wow=wow, guid=guid, msg={tab}})
        end
        if not type then
            Save.numWhisper= Save.numWhisper + 1--最后密语,数量
            set_numWhisper_Tips()--最后密语,数量, 提示
        end
    end
end





local function set_InInstance_Disabled_Bubbles()--副本禁用，其它开启
    if Save.inInstanceBubblesDisabled and not UnitAffectingCombat('player') then
        if IsInInstance() then
            C_CVar.SetCVar("chatBubbles", '0')
        else
            C_CVar.SetCVar("chatBubbles", '1')
        end
    end
end




















--#####
--主菜单
--[[#####
local function Init_Menu(self, level, type)--主菜单    
    local chatType={
        {text= e.onlyChinese and '说' or SAY, type= SLASH_SAY1},--/s
        {text= e.onlyChinese and '喊' or YELL, type= SLASH_YELL1},--/p
        {text= e.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER, type= SLASH_WHISPER1}--/w
    }
    local info
    if type then
        if type=='WOW' then--战网
            local map=e.GetUnitMapName('player');--玩家区域名称
            for i=1 ,BNGetNumFriends() do
                local wow=C_BattleNet.GetFriendAccountInfo(i);
                if wow and wow.accountName and wow.gameAccountInfo and wow.gameAccountInfo.isOnline then
                    local color, icon=select(2, FriendsFrame_GetBNetAccountNameAndStatus(wow,true))
                    local text=wow.accountName
                    text= color and color:WrapTextInColorCode(wow.accountName) or text
                    local gameAccountInfo= wow.gameAccountInfo
                    if gameAccountInfo then
                        if gameAccountInfo.clientProgram then
                            local atlas=BNet_GetBattlenetClientAtlas(gameAccountInfo.clientProgram)--在线图标
                            if atlas then
                                text='|A:'..atlas..':0:0|a'.. text
                            end
                        end
                        if gameAccountInfo.playerGuid then
                            text= text..e.GetPlayerInfo({guid=gameAccountInfo.playerGuid, faction=gameAccountInfo.factionName, reName=true, reRealm=true,})
                            if gameAccountInfo.areaName then --位置
                                if gameAccountInfo.areaName==map then
                                    text=text..'|A:poi-islands-table:0:0|a'
                                else
                                    text=text..' '..gameAccountInfo.areaName
                                end
                            end
                        end
                        if gameAccountInfo.characterLevel and gameAccountInfo.characterLevel~=GetMaxLevelForPlayerExpansion() then--等级
                            text=text ..' |cff00ff00'..gameAccountInfo.characterLevel..'|r'
                        end
                    end
                    info={
                        text=text,
                        notCheckable=true,
                        icon=icon,
                        tooltipOnButton=true,
                        tooltipTitle=wow.note,
                        arg1= wow.accountName,
                        keepShownOnClick= true,
                        func=function(_, arg1)
                            e.Say(nil, arg1, true)
                            SayButton.type=nil
                            SayButton.name=arg1
                            SayButton.wow=true

                            setType(e.onlyChinese and '战' or COMMUNITY_COMMAND_BATTLENET)--使用,提示
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                end
            end
        elseif type=='GAME' then--好友列表
            local map=e.GetUnitMapName('player');--玩家区域名称
            for i=1 , C_FriendList.GetNumFriends() do
                local game=C_FriendList.GetFriendInfoByIndex(i)
                if game and game.connected and game.guid and not game.mobile then--and not game.afk and not game.dnd then 
                    local text=e.GetPlayerInfo({guid=game.guid, reName=true, reRealm=true})--角色信息
                    text= (game.level and game.level~=GetMaxLevelForPlayerExpansion()) and text .. ' |cff00ff00'..game.level..'|r' or text--等级
                    if game.area then
                        if game.area == map then--地区
                            text= text..'|A:poi-islands-table:0:0|a'
                        else
                            text= text..' '..game.area
                        end
                    end
                    info={
                        text=text,
                        notCheckable=true,
                        tooltipOnButton=true,
                        tooltipTitle=game.notes,
                        icon= game.afk and FRIENDS_TEXTURE_AFK or game.dnd and FRIENDS_TEXTURE_DND,
                        arg1= game.name,
                        keepShownOnClick= true,
                        func=function(_, arg1)
                            e.Say('/w', arg1)
                            SayButton.type='/w'
                            SayButton.name=arg1
                            SayButton.wow=nil
                            setType(e.onlyChinese and '密' or SLASH_TEXTTOSPEECH_WHISPER)--使用,提示
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                end
            end
        elseif type=='WHISPER' then--密语列表 --{name=name, wow=wow, guid=guid, msg={text=text, type=type,time=time}}
            local find
            for _, tab in pairs(Save.WhisperTab) do
                local text

                for _, msg in pairs(tab.msg) do
                    text= text and text..'|n' or ''
                    if msg.type then--发送
                        text= text..msg.time..' '..format('|A:%s:0:0|a', e.Icon.toLeft)..e.Player.col..msg.text..'|r'
                    else--接收
                        text= text..msg.time..' '..format('|A:%s:0:0|a', e.Icon.toRight)..'|cnGREEN_FONT_COLOR:'..msg.text..'|r'
                    end
                end

                info={
                    text=(tab.wow and format('|T%d:0|t', e.Icon.wow) or '')..e.GetPlayerInfo({unit=tab.unit, guid=tab.guid, name=tab.name, faction=tab.faction, reName=true, reRealm=true}),
                    notCheckable=true,
                    tooltipOnButton=true,
                    tooltipTitle= e.onlyChinese and '记录: 密语' or (PVP_RECORD..SLASH_TEXTTOSPEECH_WHISPER),
                    tooltipText=text,
                    arg1= tab.name,
                    arg2= tab.wow,
                    keepShownOnClick= true,
                    func=function(_, arg1, arg2)
                        e.Say(nil, arg1, arg2)
                        SayButton.type='/w'
                        SayButton.name=arg1
                        SayButton.wow=arg2
                        setType(e.onlyChinese and '密' or SLASH_TEXTTOSPEECH_WHISPER)--使用,提示
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
                find=true
            end
            if find then
                info={
                    text= e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2 ,--清除, 密语
                    icon= 'bags-button-autosort-up',
                    notCheckable=true,
                    keepShownOnClick= true,
                    func= function()
                        Save.WhisperTab={}
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)

                e.LibDD:UIDropDownMenu_AddSeparator(level)
            end
            info={
                text= e.onlyChinese and '保存' or SAVE,--保存, 密语
                checked= Save.saveWhisper,
                keepShownOnClick= true,
                func= function()
                    Save.saveWhisper= not Save.saveWhisper and true or nil
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)

            Save.numWhisper=0--最后密语,数量, 清空
            set_numWhisper_Tips()--最后密语,数量, 提示

        elseif type=='FLOOR' then
            local n2=C_FriendList.GetNumWhoResults();--区域
            if n2 then --and n>0 then
                local playerGuildName = GetGuildInfo('player')
                local map=e.GetUnitMapName('player');--玩家区域名称
                for i=1, n2 do
                    local zone= C_FriendList.GetWhoInfo(i)
                    if zone and zone.fullName and zone.fullName~= e.Player.name_realm then
                        info={
                            text=zone.fullName,
                            notCheckable=true,
                            tooltipOnButton=true,
                            arg1= zone.fullName,
                            arg2= zone.fullGuildName,
                            keepShownOnClick= true,
                            func=function(_, arg1, arg2)
                                e.Say(nil, arg1)
                                SayButton.type='/w'
                                SayButton.name=arg2
                                SayButton.wow=nil
                            end
                        }
                        if zone.filename then
                            info.text= e.Class(nil, zone.filename)..'|c'..RAID_CLASS_COLORS[zone.filename].colorStr..info.text..'|r'--职业,图标,颜色
                            if (C_FriendList.GetFriendInfo(zone.filename) or C_FriendList.GetFriendInfo(zone.filename:gsub('%-.+',''))) then --好友
                                info.text=info.text..'|A:socialqueuing-icon-group:0:0|a'
                            end
                        end
                        local t2='';
                        if zone.level then
                            if zone.level~=GetMaxLevelForPlayerExpansion() then
                                info.text=info.text..' |cffff0000'..zone.level..'|r'
                                t2=t2..LEVEL..': |cffff0000'..zone.level..'|r';
                            else
                                t2=t2..LEVEL..': '..zone.level;
                            end
                            if zone.raceStr then--种族                      
                                t2=t2..' '..zone.raceStr;
                            end
                        end--等级

                        if zone.fullGuildName then--公会
                            if t2~='' then t2=t2..'|n' end
                            if zone.fullGuildName==playerGuildName then --同公会
                                info.text=info.text..'|A:communities-guildbanner-background:0:0|a';
                                t2=t2..'|A:communities-guildbanner-background:0:0|a';
                            end
                            t2=t2..GUILD..': '..zone.fullGuildName;
                        end
                        if zone.area then --区域
                            if t2~='' then t2=t2..'|n' end
                            if zone.area==map then
                                info.text=info.text..'|A:poi-islands-table:0:0|a'
                                t2=t2..'|A:poi-islands-table:0:0|a'
                            else
                                info.text=info.text.. ' '..zone.area;
                            end
                            t2=t2..FLOOR..': '..zone.area;

                        end
                        info.tooltipTitle=t2
                        e.LibDD:UIDropDownMenu_AddButton(info, level)
                    end
                end
            end

        elseif type=='BUBBLES' then
            info={
                text= (e.onlyChinese and '副本' or INSTANCE)..': '..e.GetEnabeleDisable(false),
                checked= Save.inInstanceBubblesDisabled,
                tooltipOnButton= true,
                tooltipTitle= (e.onlyChinese and '其它' or OTHER)..': '..e.GetEnabeleDisable(true),
                tooltipText= e.onlyChinese and '自动' or CLUB_FINDER_LOOKING_FOR_CLASS_SPEC,
                keepShownOnClick= true,
                func= function()
                    Save.inInstanceBubblesDisabled= not Save.inInstanceBubblesDisabled and true or nil
                    set_InInstance_Disabled_Bubbles()--副本禁用，其它开启
                    e.LibDD:CloseDropDownMenus();
                end

            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
    else

    












    
        for index, tab in pairs(chatType) do
            info={
                text=tab.text..(SayButton.type==tab.type and e.Icon.left or ''),
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle=tab.type,
                arg1= tab.type,
                arg2= tab.text,
                func=function(_, arg1, arg2)
                    e.Say(arg1)
                    SayButton.type=arg1
                    SayButton.name=nil
                    SayButton.wow=nil
                    setType(arg2)--使用,提示
                end
            }
            if index==3 then --tab.text=='密语' or tab.text==SLASH_TEXTTOSPEECH_WHISPER then
                local text= UnitIsPlayer('target') and GetUnitName('target', true)
                if text then--目标密语
                    info.text= info.text..' '..text
                    info.arg1= text
                    info.arg2= tab.text
                    info.func=function(_, arg1, arg2)
                        e.Say('/w', arg1)
                        SayButton.type='/w'
                        SayButton.name=arg1
                        SayButton.wow=nil
                        setType(arg2)--使用,提示
                    end
                elseif SayButton.name then--最后密语
                    info.text= info.text..' '.. SayButton.name
                    info.arg1= {name=SayButton.name, wow=SayButton.wow, text=tab.text}
                    info.func=function(_, arg1)
                        e.Say('/w', arg1.name, arg1.wow)
                        SayButton.type='/w'
                        setType(arg1.text)--使用,提示
                    end
                end
                info.menuList='WHISPER'
                info.hasArrow=true
                local num= #Save.WhisperTab
                if num>0 then
                    info.text= '|cnGREEN_FONT_COLOR:'..num..'|r'..info.text
                end
            end
            info.keepShownOnClick= true
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end







        e.LibDD:UIDropDownMenu_AddSeparator(level)
        local numOline
        numOline= 0;--战网在线数量
        for i=1 ,BNGetNumFriends() do
            local wow=C_BattleNet.GetFriendAccountInfo(i)
            if wow and wow.gameAccountInfo and wow.gameAccountInfo.isOnline  then
                numOline=numOline+1
            end
        end
        numOline=numOline>0 and '|cnGREEN_FONT_COLOR:'..numOline..'|r' or ''

        info={--战网
            text=e.Icon.net2..(e.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET)..numOline,
            notCheckable=true,
            menuList='WOW',
            hasArrow=true
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        numOline= C_FriendList.GetNumOnlineFriends()--好友列表
        numOline= (numOline and numOline>0) and '|cnGREEN_FONT_COLOR:'..numOline..'|r' or ''
        info={
            text='|A:groupfinder-icon-friend:0:0|a'..(e.onlyChinese and '好友' or FRIENDS)..numOline,
            notCheckable=true,
            menuList='GAME',
            hasArrow=true
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        numOline = C_FriendList.GetNumWhoResults()
        numOline = (numOline and numOline>0)  and '|cnGREEN_FONT_COLOR:'..numOline..'|r' or ''
        info={--区域列表
            text=format('|A:poi-islands-table:0:0|a%s%s', e.onlyChinese and '区域' or FLOOR, numOline),
            notCheckable=true,
            menuList='FLOOR',
            hasArrow=true,
            keepShownOnClick= true,
            func=function()
                ToggleFriendsFrame(2)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        e.LibDD:UIDropDownMenu_AddSeparator(level)

        info={
            text= e.onlyChinese and '聊天泡泡' or CHAT_BUBBLES_TEXT,
            tooltipOnButton=true,
            --tooltipTitle= e.onlyChinese and '战斗中：禁用' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT..': '..DISABLE,
            --tooltipText= (e.onlyChinese and '仅限副本' or LFG_LIST_CROSS_FACTION:format(INSTANCE))..'|n|n
            tooltipTitle= 'CVar chatBubbles',
            tooltipText= (e.onlyChinese and '当前' or REFORGE_CURRENT)..': '..e.GetEnabeleDisable(C_CVar.GetCVarBool("chatBubbles")),
            menuList= 'BUBBLES',
            hasArrow=true,
            checked= C_CVar.GetCVarBool("chatBubbles"),
            disabled= UnitAffectingCombat('player'),
            keepShownOnClick= true,
            func= function ()
                C_CVar.SetCVar("chatBubbles", not C_CVar.GetCVarBool("chatBubbles") and '1' or '0')
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    end
end
]]


















local function Init_Menu(self, root)
    local sub, sub2, sub3, col, icon
    --local isInCombat= UnitAffectingCombat('player')

    local chatType={
        {text= e.onlyChinese and '说' or SAY, type= SLASH_SAY1, type2='SLASH_SAY'},--/s
        {text= e.onlyChinese and '喊' or YELL, type= SLASH_YELL1, type2='SLASH_YELL'},--/p
        {text= e.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER, type=SLASH_WHISPER1, type2='SLASH_WHISPER', isWhisper=true,}
    }
    for _, tab in pairs(chatType) do
        sub=root:CreateCheckbox(
                tab.text
                ..' '
                ..tab.type
                ..(tab.isWhisper and ' '..e.GetPlayerInfo({unit='target', reName=true}) or ''),
            function(data)
                    return Save.type==data.type

            end, function(data)
                local name
                if data.isWhisper then
                    if UnitIsPlayer('target') and UnitIsFriend('target', 'player') then
                        name= GetUnitName("target", true)
                    end
                end
                e.Say(data.type, name, nil)
                self:settings(data.type, data.text, name, nil)
            end, tab)

        sub:SetTooltip(function(tooltip, description)
            tooltip:AddLine(description.data.text)
            for i=2, 12 do
                local str=_G[description.data.type2..i]
                if str then
                    if str~=description.data.type then
                        tooltip:AddLine(str..' ')
                    end
                else
                    break
                end
            end
        end)

        sub:AddInitializer(function(button)
            if button.leftTexture1 then
                button.leftTexture1:SetShown(false)
            end
            if button.leftTexture2 then
                button.leftTexture2:SetAtlas('newplayertutorial-icon-mouse-leftbutton')
            end
        end)
    end









--密语列表 --{name=name, wow=wow, guid=guid, msg={text=text, type=type,time=time}}
    --[[sub:CreateCheckbox(e.onlyChinese and '保存' or SAVE, function()
        return Save.saveWhisper
    end, function()
        Save.saveWhisper= not Save.saveWhisper and true or nil
    end)]]

--全部清除
    local num= #Save.WhisperTab
    if num>0 then
        sub2=sub:CreateButton((e.onlyChinese and '全部清除' or CLEAR_ALL)..' #'..num, function()
            Save.WhisperTab={}
            rest_numWhisper_Tips()--重置密语，数量
            return MenuResponse.CloseAll
        end)
        sub2:SetTooltip(function(tooltip)
            tooltip:AddLine(e.onlyChinese and '最多保存120条' or 'Save up to 120 recordsf')
        end)

        sub:CreateDivider()


        for index, tab in pairs(Save.WhisperTab) do
            local playerName= e.GetPlayerInfo({unit=tab.unit, guid=tab.guid, name=tab.name, faction=tab.faction, reName=true, reRealm=true})
            playerName= playerName=='' and tab.name or playerName
            sub2=sub:CreateButton('|cff9e9e9e'..index..')|r '..(tab.wow and format('|T%d:0|t', e.Icon.wow) or '')..(playerName or ' '), function(data)
                e.Say(nil, data.name, data.wow)
                self:settings(SLASH_WHISPER1, e.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER, data.name, data.wow)
                return MenuResponse.Open
            end, tab)

            sub2:SetTooltip(function(tooltip, description)
                col= select(4, e.GetUnitColor(nil, description.data.guid))
                local find
                for _, msg in pairs(description.data.msg) do
                    local player= msg.player and msg.player~=e.Player.name_realm and msg.player

                    if msg.type then--发送
                        tooltip:AddLine((player and '|cnGREEN_FONT_COLOR:' or '|cff9e9e9e')..msg.time..' |A:voicechat-icon-textchat-silenced:0:0|a'..msg.text..'|r')
                    else--接收
                        tooltip:AddDoubleLine(
                            col..msg.time,

                            col..(e.GetFriend(description.data.name, description.data.guid, nil) or format('|A:%s:0:0|a', e.Icon.toRight))
                            ..(e.GetUnitRaceInfo({guid=description.data.guid}) or '')
                            ..msg.text.. (player and ' |cnGREEN_FONT_COLOR:*|r' or '')
                        )
                    end
                    find=true
                end
                if find then
                    tooltip:AddLine(' ')
                end
                tooltip:AddLine((e.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER)..e.Icon.left)
                rest_numWhisper_Tips()--重置密语，数量
            end)

            sub2:CreateButton(e.onlyChinese and '显示' or SHOW, function(data)
                col= select(4, e.GetUnitColor(nil, data.guid)) or '|cffffffff'
                local text= '|cff9e9e9e'..e.Player.name_realm..'|r'..e.Icon.player..' <-> '..(e.GetUnitRaceInfo({guid=data.guid}) or '')..col..data.name..'|r|n|n'
                local playerList={}
                for _, msg in pairs(data.msg) do
                    text= text and text..'|n' or ''
                    if msg.type then--发送
                        text= text..'|cff9e9e9e'..msg.time..' '..(msg.player or e.Player.name_realm)..': '..msg.text..'|r'
                        if msg.player and msg.player~=e.Player.name_realm then
                            playerList[msg.player]= true
                            text=text..' |cnGREEN_FONT_COLOR:*|r'
                        end
                    else--接收
                        text= text..col..msg.time..' '..data.name..': '..msg.text..'|r'
                        if msg.player and msg.player~=e.Player.name_realm then
                            playerList[msg.player]= true
                            text=text..' ->|cnGREEN_FONT_COLOR:'..msg.player'|r'
                        end
                    end
                end

                for player in pairs(playerList) do
                    text=text..'|n|cff9e9e9e'..player..'|r <-> '..(e.GetUnitRaceInfo({guid=data.guid}) or '')..col..data.name..'|r|n'
                end
                e.ShowTextFrame(text, e.GetPlayerInfo({name=data.name, guid=data.guid, reName=true, reRealm=true}))
                return MenuResponse.Open
            end, tab)


            sub2:CreateDivider()
            sub2:CreateButton(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, function(data)
                local findIndex= findWhisper(data)
                if findIndex then
                    Save.WhisperTab[findIndex]=nil
                    print(id, addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|r', e.PlayerLink(data))
                else
                    print(id, addName, '|cff9e9e9e'..(e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE)..'|r', e.PlayerLink(data))
                end
                return MenuResponse.Open
            end, tab.name)


        end
        if num>30 then
            sub:SetGridMode(MenuConstants.VerticalGridDirection, math.ceil(num/30))
        end
    end




    root:CreateDivider()

--战网在线数量
    local numOline, onlineList= 0, {}
    local playerMapNamp=e.GetUnitMapName('player')
    for i=1 ,BNGetNumFriends() do
        local wow=C_BattleNet.GetFriendAccountInfo(i)
        if wow and wow.gameAccountInfo and wow.gameAccountInfo.isOnline and wow.accountName then
            numOline=numOline+1
            table.insert(onlineList, wow)
        end
    end
    sub=root:CreateButton(e.Icon.net2..(e.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET)..' '..numOline, function()
        ToggleFriendsFrame(1)
    end)

    for _, wow in pairs(onlineList) do
        col, icon=select(2, FriendsFrame_GetBNetAccountNameAndStatus(wow,true))
        local text=wow.accountName
        text= col and col:WrapTextInColorCode(wow.accountName) or text
        local gameAccountInfo= wow.gameAccountInfo
        local zone
        if gameAccountInfo then
            if gameAccountInfo.clientProgram then
                local atlas=BNet_GetBattlenetClientAtlas(gameAccountInfo.clientProgram)--在线图标
                if atlas then
                    text='|A:'..atlas..':0:0|a'.. text
                end
            end
            if gameAccountInfo.playerGuid then
                text= text..e.GetPlayerInfo({guid=gameAccountInfo.playerGuid, faction=gameAccountInfo.factionName, reName=true, reRealm=true,})
                if gameAccountInfo.areaName then --位置
                    if gameAccountInfo.areaName==playerMapNamp then
                        text=text..'|A:poi-islands-table:0:0|a'
                    end
                    zone= gameAccountInfo.areaName
                end
            end
            if gameAccountInfo.characterLevel and gameAccountInfo.characterLevel~=GetMaxLevelForPlayerExpansion() then--等级
                text=text ..' |cff00ff00'..gameAccountInfo.characterLevel..'|r'
            end
        end
        icon= icon and format('|T%d:0|t', icon) or ''

        sub2=sub:CreateButton(icon..text, function(data)
            e.Say(nil, data.name, true)
            self:settings(nil, e.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET, data.name, true)
            return MenuResponse.Open
        end, {name=wow.accountName, note=wow.note, zone=zone})

        sub2:SetTooltip(function(tooltip, description)
            tooltip:AddLine(description.data.note)
            tooltip:AddLine(e.cn(description.data.zone))
        end)
    end

    if numOline>30 then
        sub:SetGridMode(MenuConstants.VerticalGridDirection, math.ceil(numOline/30))
    end




--聊天泡泡
    root:CreateDivider()
    sub2=root:CreateCheckbox(e.onlyChinese and '聊天泡泡' or CHAT_BUBBLES_TEXT, function()
        return C_CVar.GetCVarBool("chatBubbles")
    end, function()
        if not UnitAffectingCombat('player') then
            C_CVar.SetCVar("chatBubbles", not C_CVar.GetCVarBool("chatBubbles") and '1' or '0')
        else
            print(id, addName, e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        end
    end)

    sub3=sub2:CreateCheckbox(e.onlyChinese and '自动' or SELF_CAST_AUTO, function()
        return Save.inInstanceBubblesDisabled
    end, function()
        Save.inInstanceBubblesDisabled= not Save.inInstanceBubblesDisabled and true or nil
        set_InInstance_Disabled_Bubbles()--副本禁用，其它开启
    end)

    sub3:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '聊天泡泡' or CHAT_BUBBLES_TEXT)
        tooltip:AddLine(' ')
        tooltip:AddDoubleLine((e.onlyChinese and '在副本中' or AGGRO_WARNING_IN_INSTANCE)..':', e.GetEnabeleDisable(false))
        tooltip:AddDoubleLine((e.onlyChinese and '其它' or OTHER)..':', e.GetEnabeleDisable(true))
    end)
end





























--####
--初始
--####
local function Init()
    SayButton.typeText=e.Cstr(SayButton, {color=true})--10, nil, nil, true)
    SayButton.typeText:SetPoint('BOTTOM',0,2)

    SayButton.tipBubbles= SayButton:CreateTexture(nil, 'OVERLAY')
    SayButton.tipBubbles:SetSize(8, 8)
    SayButton.tipBubbles:SetPoint('TOPLEFT', 3, -0)
    SayButton.tipBubbles:SetAtlas(e.Icon.disabled)

    SayButton.numWhisper=e.Cstr(SayButton, {color={r=0,g=1,b=0}})--最后密语,数量, 提示
    SayButton.numWhisper:SetPoint('TOPRIGHT',-3, 0)

    SayButton.texture:SetAtlas('transmog-icon-chat')

    function SayButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        if Save.type or Save.text or Save.name then
            local name
            if Save.type==SLASH_WHISPER1 then
                name= GetUnitName('target', true)
            elseif Save.name then
                name= Save.isWoW and e.Icon.net2..'|cff28a3ff'..Save.name or Save.name
            end
            e.tips:AddDoubleLine((Save.text or '')..(Save.type and ' '..Save.type or ''),(name or '')..e.Icon.left)
        end
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '密语数量' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_TEXTTOSPEECH_WHISPER, AUCTION_HOUSE_QUANTITY_LABEL), Save.numWhisper)
        e.tips:Show()
    end

    SayButton:SetScript('OnLeave', function(self)
        self:state_leave()
        e.tips:Hide()
    end)
    SayButton:SetScript('OnEnter', function(self)
        self:state_enter()
        self:set_tooltip()
    end)

    SayButton:SetScript('OnClick', function(self, d)

        if d=='LeftButton' and (Save.type or Save.name) then
            
            local name, wow= Save.name, Save.isWoW
            if Save.type==SLASH_WHISPER1 and UnitIsPlayer('target') then
                name=GetUnitName('target', true)
                wow= false
            end
         
            e.Say(Save.type, name, wow)

        else
            MenuUtil.CreateContextMenu(self, Init_Menu)
            e.tips:Hide()
        end
    end)

    function SayButton:settings(type, text, name, isWoW)
        Save.type= type
        Save.text= text
        Save.name= name
        Save.isWoW= isWoW

        if text=='大喊' then
            text='喊'
        elseif type and text:find('%w') then--处理英文
            text=type:gsub('/','')
        else
            text=e.WA_Utf8Sub(text, 1, 3)
        end

        self.typeText:SetText(text)
    end


    SayButton:settings(Save.type, Save.text, Save.name, Save.isWoW)
    set_chatBubbles_Tips() --提示，聊天泡泡，开启/禁用
    set_numWhisper_Tips()--最后密语,数量, 提示
end











--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1, arg2, ...)
    if event == "ADDON_LOADED" then
        if arg1==id then
            --处理，上版本数据
            if WoWToolsSave[SAY] then
                Save= WoWToolsSave[SAY]
                Save.WhisperTab=Save.WhisperTab or {}
                WoWToolsSave[SAY]=nil
                Save.type= SLASH_SAY1
                Save.text= (e.onlyChinese and '说' or SAY)
            else
                Save= WoWToolsSave['ChatButton_Say'] or Save
            end

            Save.numWhisper= Save.numWhisper or 0
            SayButton= WoWToolsChatButtonMixin:CreateButton('Say')


            if SayButton then--禁用Chat Button
                addName= '|A:transmog-icon-chat:0:0|a'..(e.onlyChinese and '说' or SAY)
                if #Save.WhisperTab>120 then
                    for i=121, #Save.WhisperTab do
                        Save.WhisperTab[i]=nil
                    end
                end


                Init()
                self:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
                self:RegisterEvent("CHAT_MSG_WHISPER")
                self:RegisterEvent("CHAT_MSG_BN_WHISPER")
                self:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM")
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
                self:RegisterEvent('CVAR_UPDATE')
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event=='CHAT_MSG_WHISPER_INFORM' or event=='CHAT_MSG_WHISPER' or event=='CHAT_MSG_BN_WHISPER' or event=='CHAT_MSG_BN_WHISPER_INFORM' then
        getWhisper(event, arg1, arg2, ...)

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButton_Say']=Save
        end
    elseif event== 'PLAYER_ENTERING_WORLD' then
        set_InInstance_Disabled_Bubbles()--副本禁用，其它开启

    elseif event=='CVAR_UPDATE' then
        if arg1=='chatBubbles' then
            set_chatBubbles_Tips() --提示，聊天泡泡，开启/禁用
        end
    end
end)