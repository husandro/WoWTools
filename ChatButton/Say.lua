local id, e = ...
local Save= {}

local panel=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)
panel:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
WoWToolsChatButtonFrame.last=panel

local function setType(text)--使用,提示
    if not panel.typeText then
        panel.typeText=e.Cstr(panel, 10, nil, nil, true)
        panel.typeText:SetPoint('BOTTOM',0,2)
    end

    if text=='大喊' then
        text='喊'
    elseif panel.type and text:find('%w') then--处理英文
        text=panel.type:gsub('/','')
    else
        text=e.WA_Utf8Sub(text, 1)
    end

    panel.typeText:SetText(text)
    panel.typeText:SetShown(IsInGroup())
end


--#######
--密语列表
--#######
local WhisperTab={}--{name=name, wow=wow, guid=guid, msg={text=text, type=type,time=time}}
local function findWhisper(name)
    for index, tab in pairs(WhisperTab) do
        if tab.name==name then
            return index
        end
    end
end
local function getWhisper(event, text, name, _, _, _, _, _, _, _, _, _, guid)
    if e.Player.name_server~=name and name then
        local type= event:find('INFORM') and true or nil--_INFORM 发送
        local index=findWhisper(name)
        local tab={text=text, type=type, time=date('%X')}
        if index then
            table.insert(WhisperTab[index].msg, {text=text, type=type, time=date('%X')})
        else
            local wow= event:find('MSG_BN') and true or nil
            table.insert(WhisperTab, {name=name, wow=wow, guid=guid, msg={{text=text, type=type, time=date('%X')}}})
        end
    end
end

local function set_CVar_chatBubbles()--聊天泡泡
    if Save.chatBubbles~=nil then
        local value= Save.chatBubbles and '1' or '0'
        if C_CVar.GetCVar("chatBubbles")~=value then
            C_CVar.SetCVar("chatBubbles", value)
        end
    end
end
--#####
--主菜单
--#####
local chatType={
    {text= SAY, type= SLASH_SAY1},--/s
    {text= YELL, type= 	SLASH_YELL1},--/p
    {text= SLASH_TEXTTOSPEECH_WHISPER, type= SLASH_SMART_WHISPER1}--/w
}

local function InitMenu(self, level, type)--主菜单    
    local info
    if type then
        if type=='WOW' then--战网
            local map=e.GetUnitMapName('player');--玩家区域名称
            for i=1 ,BNGetNumFriends() do
                local wow=C_BattleNet.GetFriendAccountInfo(i);
                if wow and wow.accountName then
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
                            text=text..e.GetPlayerInfo(nil, gameAccountInfo.playerGuid, true)--角色信息
                            if gameAccountInfo.areaName then --位置
                                if gameAccountInfo.areaName==map then
                                    text=text..e.Icon.map2
                                else
                                    text=text..' '..gameAccountInfo.areaName
                                end
                            end
                        end
                        if gameAccountInfo.characterLevel and gameAccountInfo.characterLevel~=MAX_PLAYER_LEVEL then--等级
                            text=text ..' |cff00ff00'..gameAccountInfo.characterLevel..'|r'
                        end              
                    end
                    info={
                        text=text,
                        notCheckable=true, 
                        icon=icon,
                        tooltipOnButton=true,
                        tooltipTitle=wow.note,
                        func=function()
                            e.Say(nil, wow.accountName, true)
                            panel.type=nil
                            panel.name=wow.accountName
                            panel.wow=true
                            setType(COMMUNITY_COMMAND_BATTLENET)--使用,提示
                        end
                    }
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        elseif type=='GAME' then--好友列表
            local map=e.GetUnitMapName('player');--玩家区域名称
            for i=1 , C_FriendList.GetNumFriends() do
                local game=C_FriendList.GetFriendInfoByIndex(i)
                if game and game.connected and (game.guid or game.name) and not game.mobile then--and not game.afk and not game.dnd then 
                    local text=game.guid and e.GetPlayerInfo(nil, game.guid, true) or game.name--角色信息
                    text= (game.level and game.level~=MAX_PLAYER_LEVEL) and text .. ' |cff00ff00'..game.level..'|r' or text--等级
                    if game.area then
                        if game.area == map then--地区
                            text= text..e.Icon.map2
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
                        func=function()
                            e.Say('/w', game.name)
                            panel.type='/w'
                            panel.name=game.name
                            panel.wow=nil
                            setType(SLASH_TEXTTOSPEECH_WHISPER)--使用,提示
                        end
                    }
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        elseif type=='WHISPER' then--密语列表 --{name=name, wow=wow, guid=guid, msg={text=text, type=type,time=time}}
            for _, tab in pairs(WhisperTab) do
                local text

                for _, msg in pairs(tab.msg) do
                    text= text and text..'\n' or ''
                    if msg.type then--发送
                        text= text..msg.time..' '..e.Icon.toLeft2..e.Player.col..msg.text..'|r'
                    else--接收
                        text= text..msg.time..' '..e.Icon.toRight2..'|cnGREEN_FONT_COLOR:'..msg.text..'|r'
                    end
                end

                info={
                    text=(tab.wow and e.Icon.wow2 or '')..(tab.guid and e.GetPlayerInfo(nil, tab.guid, true) or tab.name),
                    notCheckable=true,
                    tooltipOnButton=true,
                    tooltipTitle=PVP_RECORD..SLASH_TEXTTOSPEECH_WHISPER,
                    tooltipText=text,
                    func=function()
                        e.Say(nil, tab.name, tab.wow)
                        panel.type='/w'
                        panel.name=tab.name
                        panel.wow=tab.wow
                        setType(SLASH_TEXTTOSPEECH_WHISPER)--使用,提示
                    end
                }
                UIDropDownMenu_AddButton(info, level)
            end
        elseif type=='FLOOR' then
            local n2=C_FriendList.GetNumWhoResults();--区域
            if n2 then --and n>0 then
                local map=e.GetUnitMapName('player');--玩家区域名称
                for i=1, n2 do
                    local zone= C_FriendList.GetWhoInfo(i)
                    if zone and zone.fullName and zone.fullName~= e.Player.name_server then
                        info={
                            text=zone.fullName, 
                            notCheckable=true, 
                            tooltipOnButton=true,
                            func=function(s, d) 
                                e.Say(nil, zone.fullName)
                                panel.type='/w'
                                panel.name=zone.fullGuildName
                                panel.wow=nil
                            end
                        }
                        if zone.filename then
                            info.text= e.Class(nil, zone.filename)..'|c'..RAID_CLASS_COLORS[zone.filename].colorStr..info.text..'|r'--职业,图标,颜色
                            if (C_FriendList.GetFriendInfo(zone.filename) or C_FriendList.GetFriendInfo(zone.filename:gsub('%-.+',''))) then --好友
                                info.text=inf.text..'|A:socialqueuing-icon-group:0:0|a'
                            end
                        end
                        local t2='';                    
                        if zone.level then 
                            if zone.level~=MAX_PLAYER_LEVEL then
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
                            if t2~='' then t2=t2..'\n' end
                            if zone.fullGuildName==guild then --同公会
                                info.text=info.text..'|A:communities-guildbanner-background:0:0|a';
                                t2=t2..'|A:communities-guildbanner-background:0:0|a'; 
                            end
                            t2=t2..GUILD..': '..zone.fullGuildName;
                        end                    
                        if zone.area then --区域
                            if t2~='' then t2=t2..'\n' end 
                            if zone.area==map then
                                info.text=info.text..e.Icon.map2
                                t2=t2..e.Icon.map2;
                            else
                                info.text=info.text.. ' '..zone.area;
                            end
                            t2=t2..FLOOR..': '..zone.area;
                            
                        end
                        info.tooltipText=t2
                        UIDropDownMenu_AddButton(info, level)
                    end
                end
            end
        end
    else
        for _, tab in pairs(chatType) do
            info={
                text=tab.text,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle=tab.type,
                func=function()
                    e.Say(tab.type)
                    panel.type=tab.type
                    panel.name=nil
                    panel.wow=nil
                    setType(tab.text)--使用,提示
                end
            }
            if tab.text==SLASH_TEXTTOSPEECH_WHISPER then
                local text= UnitIsPlayer('target') and GetUnitName('target', true)
                if text then--目标密语
                    info.text= info.text..' '..text
                    info.func=function()
                        e.Say('/w', text)
                        panel.type='/w'
                        panel.name=text
                        panel.wow=nil
                        setType(tab.text)--使用,提示
                    end
                elseif panel.name then--最后密语
                    info.text= info.text..' '.. panel.name
                    info.func=function()
                        e.Say('/w', panel.name, panel.wow)
                        panel.type='/w'
                        setType(tab.text)--使用,提示
                    end
                end
                info.menuList='WHISPER'
                info.hasArrow=true
            end
            UIDropDownMenu_AddButton(info, level)
        end

        UIDropDownMenu_AddSeparator(level)
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
            text=numOline..COMMUNITY_COMMAND_BATTLENET,
            notCheckable=true,
            menuList='WOW',
            hasArrow=true
        }
        UIDropDownMenu_AddButton(info, level)

        numOline= C_FriendList.GetNumOnlineFriends()--好友列表
        numOline= (numOline and numOline>0) and '|cnGREEN_FONT_COLOR:'..numOline..'|r' or ''
        info={
            text=numOline..FRIENDS,
            notCheckable=true,
            menuList='GAME',
            hasArrow=true
        }
        UIDropDownMenu_AddButton(info, level)

        UIDropDownMenu_AddSeparator(level)
        numOline = C_FriendList.GetNumWhoResults()
        numOline = (numOline and numOline>0)  and '|cnGREEN_FONT_COLOR:'..numOline..'|r' or ''
        info={--区域列表
            text=numOline..(e.onlyChinse and '区域' or FLOOR),
            notCheckable=true,
            menuList='FLOOR',
            hasArrow=true,
            func=function()
                ToggleFriendsFrame(2)
            end
        }
        UIDropDownMenu_AddButton(info, level)
        UIDropDownMenu_AddSeparator(level)

        info={
            text= e.onlyChinse and '聊天泡泡' or CHAT_BUBBLES_TEXT,
            tooltipOnButton=true,
            --tooltipTitle= e.onlyChinse and '战斗中：禁用' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT..': '..DISABLE,
            --tooltipText= (e.onlyChinse and '仅限副本' or LFG_LIST_CROSS_FACTION:format(INSTANCE))..'\n\n
            tooltipTitle= 'CVar chatBubbles',
            checked= C_CVar.GetCVarBool("chatBubbles"),
            disabled= UnitAffectingCombat('player'),
            func= function ()
                Save.chatBubbles= not C_CVar.GetCVarBool("chatBubbles") and true or false
                set_CVar_chatBubbles()
            end
        }
        UIDropDownMenu_AddButton(info, level)
    end
end
--####
--初始
--####
local function Init()
    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    panel.type=SLASH_SAY1
    setType(SAY)--使用,提示

    panel.texture:SetAtlas('transmog-icon-chat')
    panel:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' and (panel.type or panel.name) then
            if panel.type=='/w' then
                local name= UnitIsPlayer('target') and GetUnitName('target', true) or panel.name
                e.Say(panel.type, name , panel.wow)
            else
                e.Say(panel.type, panel.name, panel.wow)
            end
        else
            ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
        end
    end)

    set_CVar_chatBubbles()--聊天泡泡
end


--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
panel:RegisterEvent("CHAT_MSG_WHISPER")
panel:RegisterEvent("CHAT_MSG_BN_WHISPER")
panel:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM")

panel:SetScript("OnEvent", function(self, event, arg1, arg2, ...)
    if event == "ADDON_LOADED" and arg1==id then
        if WoWToolsChatButtonFrame.disabled then--禁用Chat Button
            panel:UnregisterAllEvents()
        else
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            Init()
        end

    elseif event=='CHAT_MSG_WHISPER_INFORM' or event=='CHAT_MSG_WHISPER' or event=='CHAT_MSG_BN_WHISPER' or event=='CHAT_MSG_BN_WHISPER_INFORM' then
        getWhisper(event, arg1, arg2, ...)

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)