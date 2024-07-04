local id, e = ...
local Save= {
    --inInstanceBubblesDisabled= e.Player.husandro,
    saveWhisper=true,--保存, 密语
    --WhisperTab={}--保存, 密语, 内容
}
local addName= SAY
local button
local panel= CreateFrame("Frame")


local function setType(text)--使用,提示
    if not button.typeText then
        button.typeText=e.Cstr(button, {size=10, color=true})--10, nil, nil, true)
        button.typeText:SetPoint('BOTTOM',0,2)
    end

    if text=='大喊' then
        text='喊'
    elseif button.type and text:find('%w') then--处理英文
        text=button.type:gsub('/','')
    else
        text=e.WA_Utf8Sub(text, 1)
    end

    button.typeText:SetText(text)
end


--#######
--密语列表
--#######
local WhisperTab={}--{name=name, wow=wow, guid=guid, msg={text=text, type=type,time=time}}
local numWhisper=0--最后密语,数量

local function set_numWhisper_Tips()--最后密语,数量, 提示
    if numWhisper>0 and not button.numWhisper then
        button.numWhisper=e.Cstr(button, {color={r=0,g=1,b=0}})
        button.numWhisper:SetPoint('TOPRIGHT',-5,-5)
    end
    if button.numWhisper then
        button.numWhisper:SetText(numWhisper>0 and numWhisper or '')
    end
end

local function findWhisper(name)
    for index, tab in pairs(WhisperTab) do
        if tab.name==name then
            return index
        end
    end
end

local function getWhisper(event, text, name, _, _, _, _, _, _, _, _, _, guid)
    if e.Player.name_realm~=name and name then
        local type= event:find('INFORM') and true or nil--_INFORM 发送
        local index=findWhisper(name)
        local tab= {text=text, type=type, time=date('%X')}
        if index then
            table.insert(WhisperTab[index].msg, tab)
        else
            local wow= event:find('MSG_BN') and true or nil
            table.insert(WhisperTab, {name=name, wow=wow, guid=guid, msg={tab}})
        end
        if not type then
            numWhisper= numWhisper + 1--最后密语,数量
            set_numWhisper_Tips()--最后密语,数量, 提示
        end
    end
end


local function set_chatBubbles_Tips()--提示，聊天泡泡，开启/禁用
    local bool= C_CVar.GetCVarBool("chatBubbles")
    if not bool and not button.tipBubbles then
        button.tipBubbles= button:CreateTexture(nil, 'OVERLAY')
        local size=15
        button.tipBubbles:SetSize(size, size)
        button.tipBubbles:SetPoint('TOPLEFT', 3, -3)
        button.tipBubbles:SetAtlas(e.Icon.disabled)
    end
    if button.tipBubbles then
        button.tipBubbles:SetShown(not bool)
    end
end

local function set_InInstance_Disabled_Bubbles()--副本禁用，其它开启
    if Save.inInstanceBubblesDisabled then
        if IsInInstance() then
            C_CVar.SetCVar("chatBubbles", '0')
        else
            C_CVar.SetCVar("chatBubbles", '1')
        end
    end
end

--#####
--主菜单
--#####
local function Init_Menu(self, level, type)--主菜单    
    local chatType={
        {text= e.onlyChinese and '说' or SAY, type= SLASH_SAY1},--/s
        {text= e.onlyChinese and '喊' or YELL, type= SLASH_YELL1},--/p
        {text= e.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER, type= SLASH_SMART_WHISPER1}--/w
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
                            button.type=nil
                            button.name=arg1
                            button.wow=true
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
                            button.type='/w'
                            button.name=arg1
                            button.wow=nil
                            setType(e.onlyChinese and '密' or SLASH_TEXTTOSPEECH_WHISPER)--使用,提示
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                end
            end
        elseif type=='WHISPER' then--密语列表 --{name=name, wow=wow, guid=guid, msg={text=text, type=type,time=time}}
            local find
            for _, tab in pairs(WhisperTab) do
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
                        button.type='/w'
                        button.name=arg1
                        button.wow=arg2
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
                        WhisperTab={}
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

            numWhisper=0--最后密语,数量, 清空
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
                                button.type='/w'
                                button.name=arg2
                                button.wow=nil
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
                text=tab.text..(button.type==tab.type and e.Icon.left or ''),
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle=tab.type,
                arg1= tab.type,
                arg2= tab.text,
                func=function(_, arg1, arg2)
                    e.Say(arg1)
                    button.type=arg1
                    button.name=nil
                    button.wow=nil
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
                        button.type='/w'
                        button.name=arg1
                        button.wow=nil
                        setType(arg2)--使用,提示
                    end
                elseif button.name then--最后密语
                    info.text= info.text..' '.. button.name
                    info.arg1= {name=button.name, wow=button.wow, text=tab.text}
                    info.func=function(_, arg1)
                        e.Say('/w', arg1.name, arg1.wow)
                        button.type='/w'
                        setType(arg1.text)--使用,提示
                    end
                end
                info.menuList='WHISPER'
                info.hasArrow=true
                local num= #WhisperTab
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

--####
--初始
--####
local function Init()
    button:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
    WoWToolsChatButtonFrame.last=button

    

    button.type=SLASH_SAY1
    setType(e.onlyChinese and '说' or SAY)--使用,提示

    button.texture:SetAtlas('transmog-icon-chat')
    button:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' and (button.type or button.name) then
            if button.type=='/w' then
                local name= UnitIsPlayer('target') and GetUnitName('target', true) or button.name
                e.Say(button.type, name , button.wow)
            else
                e.Say(button.type, button.name, button.wow)
            end
        else
            if not self.Menu then
                self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, Init_Menu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)
        end
    end)

    set_chatBubbles_Tips()--提示，聊天泡泡，开启/禁用

end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1, arg2, ...)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if not WoWToolsChatButtonFrame.disabled then--禁用Chat Button
                Save= WoWToolsSave[addName] or Save

                WhisperTab= Save.WhisperTab or {}--保存, 密语

                button= e.Cbtn2({
                    name=nil,
                    parent=WoWToolsChatButtonFrame,
                    click=true,-- right left
                    notSecureActionButton=true,
                    notTexture=nil,
                    showTexture=true,
                    sizi=nil,
                })

                Init()
                panel:RegisterEvent("PLAYER_LOGOUT")
                panel:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
                panel:RegisterEvent("CHAT_MSG_WHISPER")
                panel:RegisterEvent("CHAT_MSG_BN_WHISPER")
                panel:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM")
                panel:RegisterEvent('PLAYER_ENTERING_WORLD')
                panel:RegisterEvent('CVAR_UPDATE')
            end
            panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event=='CHAT_MSG_WHISPER_INFORM' or event=='CHAT_MSG_WHISPER' or event=='CHAT_MSG_BN_WHISPER' or event=='CHAT_MSG_BN_WHISPER_INFORM' then
        getWhisper(event, arg1, arg2, ...)

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if Save.saveWhisper then--保存, 密语
                Save.WhisperTab= WhisperTab
            else
                Save.WhisperTab=nil
            end
            WoWToolsSave[addName]=Save
        end
    elseif event== 'PLAYER_ENTERING_WORLD' then
        set_InInstance_Disabled_Bubbles()--副本禁用，其它开启

    elseif event=='CVAR_UPDATE' then
        if arg1=='chatBubbles' then
            set_chatBubbles_Tips()--提示，聊天泡泡，开启/禁用
        end
    end
end)