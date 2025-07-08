
local P_Save= {
    --inInstanceBubblesDisabled= WoWTools_DataMixin.Player.husandro,
    saveWhisper=true,--保存, 密语
    WhisperTab={},--保存, 密语, 内容 {name=name, wow=wow, guid=guid, msg={text=text, type=type,time=time}}


    --保存上次，内容
    --type='/s',
    --text= WoWTools_DataMixin.onlyChinese and '说' or SAY
    --name=玩家名称,
    --isWoW=bool,
    numWhisper=0,--最后密语,数量
}

local function Save()
    return WoWToolsSave['ChatButton_Say'] or {}
end

local addName
local SayButton












 --提示，聊天泡泡，开启/禁用
 local function set_chatBubbles_Tips()
    SayButton.tipBubbles:SetShown(not C_CVar.GetCVarBool("chatBubbles"))
end
















--#######
--密语列表
--#######
local function set_numWhisper_Tips()--最后密语,数量, 提示
    SayButton.numWhisper:SetText(Save().numWhisper>0 and Save().numWhisper or '')
end

local function rest_numWhisper_Tips()--重置密语，数量
    Save().numWhisper=0--最后密语,数量, 清空
    set_numWhisper_Tips()--最后密语,数量, 提示
end

local function findWhisper(name)
    for index, tab in pairs(Save().WhisperTab) do
        if tab.name==name then
            return index
        end
    end
end

local function getWhisper(event, text, name, _, _, _, _, _, _, _, _, _, guid)
    if WoWTools_DataMixin.Player.name_realm~=name and name then
        local type= event:find('INFORM') and true or nil--_INFORM 发送
        local index=findWhisper(name)
        local tab= {text=text, type=type, player=WoWTools_DataMixin.Player.name_realm, time=date('%X')}
        if index then
            Save().WhisperTab[index].guid=guid
            table.insert(Save().WhisperTab[index].msg, tab)
        else
            local wow= event:find('MSG_BN') and true or nil
            table.insert(Save().WhisperTab, 1, {name=name, wow=wow, guid=guid, msg={tab}})
        end
        if not type then
            Save().numWhisper= Save().numWhisper + 1--最后密语,数量
            set_numWhisper_Tips()--最后密语,数量, 提示
        end
    end
end





local function set_InInstance_Disabled_Bubbles()--副本禁用，其它开启
    if Save().inInstanceBubblesDisabled and not InCombatLockdown() then
        if IsInInstance() then
            C_CVar.SetCVar("chatBubbles", '0')
        else
            C_CVar.SetCVar("chatBubbles", '1')
        end
    end
end

































local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    
    local sub, sub2, sub3, col, icon, name, num
    --local isInCombat= UnitAffectingCombat('player')

    local chatType={
        {text= WoWTools_DataMixin.onlyChinese and '说' or SAY, type= SLASH_SAY1, type2='SLASH_SAY'},--/s
        {text= WoWTools_DataMixin.onlyChinese and '喊' or YELL, type= SLASH_YELL1, type2='SLASH_YELL'},--/p
        {text= WoWTools_DataMixin.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER, type=SLASH_WHISPER1, type2='SLASH_WHISPER', isWhisper=true,}
    }
    for _, tab in pairs(chatType) do
        sub=root:CreateCheckbox(
                tab.text
                ..' '
                ..tab.type
                ..(tab.isWhisper and ' '..WoWTools_UnitMixin:GetPlayerInfo('target', nil, nil, {reName=true}) or ''),
            function(data)
                    return Save().type==data.type

            end, function(data)
                local name
                if data.isWhisper then
                    if UnitIsPlayer('target') and UnitIsFriend('target', 'player') then
                        name= GetUnitName("target", true)
                    end
                end
                WoWTools_ChatMixin:Say(data.type, name, nil)
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
    --[[sub:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '保存' or SAVE, function()
        return Save().saveWhisper
    end, function()
        Save().saveWhisper= not Save().saveWhisper and true or nil
    end)]]

--全部清除
    num= #Save().WhisperTab
    if num>0 then
        name= (WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)..' #'..num
        sub2=sub:CreateButton(
            name,
        function(data)
            StaticPopup_Show('WoWTools_OK',
            data.name,
            nil,
            {SetValue=function()
                Save().WhisperTab={}
                rest_numWhisper_Tips()--重置密语，数量
            end})
            return MenuResponse.Open
        end, {name=name})
        sub2:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '最多保存120条' or 'Save up to 120 recordsf')
        end)

        sub:CreateDivider()


        for index, tab in pairs(Save().WhisperTab) do
            local playerName= WoWTools_UnitMixin:GetPlayerInfo(tab.unit, tab.guid, tab.name, {faction=tab.faction, reName=true, reRealm=true})
            playerName= playerName=='' and tab.name or playerName
            sub2=sub:CreateButton('|cff9e9e9e'..index..')|r '..(tab.wow and WoWTools_DataMixin.Icon.wow2 or '')..(playerName or ' '), function(data)
                WoWTools_ChatMixin:Say(nil, data.name, data.wow)
                self:settings(SLASH_WHISPER1, WoWTools_DataMixin.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER, data.name, data.wow)
                return MenuResponse.Open
            end, tab)

            sub2:SetTooltip(function(tooltip, desc)
                col= select(5, WoWTools_UnitMixin:GetColor(nil, desc.data.guid))
                local find
                for _, msg in pairs(desc.data.msg) do
                    local player= msg.player and msg.player~=WoWTools_DataMixin.Player.name_realm and msg.player

                    if msg.type then--发送
                        tooltip:AddLine((player and '|cnGREEN_FONT_COLOR:' or '|cff9e9e9e')..msg.time..' |A:voicechat-icon-textchat-silenced:0:0|a'..msg.text..'|r')
                    else--接收
                        tooltip:AddDoubleLine(
                            col..msg.time,

                            col
                            ..(
                                WoWTools_UnitMixin:GetIsFriendIcon(nil, desc.data.guid, desc.data.name)
                                or format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toRight)
                            )
                            ..(WoWTools_UnitMixin:GetRaceIcon(nil, desc.data.guid, nil) or '')
                            ..msg.text.. (player and ' |cnGREEN_FONT_COLOR:*|r' or '')
                        )
                    end
                    find=true
                end
                if find then
                    tooltip:AddLine(' ')
                end
                tooltip:AddLine((WoWTools_DataMixin.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER)..WoWTools_DataMixin.Icon.left)
                rest_numWhisper_Tips()--重置密语，数量
            end)

            sub2:CreateButton(WoWTools_DataMixin.onlyChinese and '显示' or SHOW, function(data)
                col= select(5, WoWTools_UnitMixin:GetColor(nil, data.guid)) or '|cffffffff'
                local text= '|cff9e9e9e'
                            ..WoWTools_DataMixin.Player.name_realm
                            ..'|r'..WoWTools_DataMixin.Icon.Player
                            ..' <-> '
                            ..(WoWTools_UnitMixin:GetRaceIcon(nil, data.guid, nil) or '')
                            ..col
                            ..data.name
                            ..'|r|n|n'
                local playerList={}
                for _, msg in pairs(data.msg) do
                    text= text and text..'|n' or ''
                    if msg.type then--发送
                        text= text..'|cff9e9e9e'..msg.time..' '..(msg.player or WoWTools_DataMixin.Player.name_realm)..': '..msg.text..'|r'
                        if msg.player and msg.player~=WoWTools_DataMixin.Player.name_realm then
                            playerList[msg.player]= true
                            text=text..' |cnGREEN_FONT_COLOR:*|r'
                        end
                    else--接收
                        text= text..col..msg.time..' '..data.name..': '..msg.text..'|r'
                        if msg.player and msg.player~=WoWTools_DataMixin.Player.name_realm then
                            playerList[msg.player]= true
                            text=text..' ->|cnGREEN_FONT_COLOR:'..msg.player'|r'
                        end
                    end
                end

                for player in pairs(playerList) do
                    text=text
                        ..'|n|cff9e9e9e'
                        ..player..'|r <-> '
                        ..(WoWTools_UnitMixin:GetRaceIcon(nil, data.guid, nil) or '')
                        ..col
                        ..data.name
                        ..'|r|n'
                end
                WoWTools_TextMixin:ShowText(text, WoWTools_UnitMixin:GetPlayerInfo(nil, data.guid, data.name, {reName=true, reRealm=true}))
                return MenuResponse.Open
            end, tab)


            sub2:CreateDivider()
            sub2:CreateButton(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
            function(data)
                local findIndex= findWhisper(data.name)
                if findIndex then
                    Save().WhisperTab[findIndex]=nil
                    print(
                        WoWTools_DataMixin.Icon.icon2..addName,
                        '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '移除' or REMOVE)..'|r',
                        WoWTools_UnitMixin:GetLink(data.unit, data.guid, data.name, false)
                    )
                else
                    print(
                        WoWTools_DataMixin.Icon.icon2..addName,
                        '|cff9e9e9e'..(WoWTools_DataMixin.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE)..'|r',
                        WoWTools_UnitMixin:GetLink(data.unit, data.guid, data.name, false)
                    )
                end
                return MenuResponse.Open
            end, tab)
        end
--SetScrollMod
        WoWTools_MenuMixin:SetScrollMode(sub)
    end




    root:CreateDivider()

--战网在线数量
    local numOline, onlineList= 0, {}
    local playerMapNamp=WoWTools_MapMixin:GetUnit('player')
    for i=1 ,BNGetNumFriends() do
        local wow=C_BattleNet.GetFriendAccountInfo(i)
        if wow and wow.gameAccountInfo and wow.gameAccountInfo.isOnline and wow.accountName then
            numOline=numOline+1
            table.insert(onlineList, wow)
        end
    end
    sub=root:CreateButton(WoWTools_DataMixin.Icon.net2..(WoWTools_DataMixin.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET)..' '..numOline, function()
        ToggleFriendsFrame(1)
    end)

    local maxLevel= GetMaxLevelForLatestExpansion()
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
                text= text..WoWTools_UnitMixin:GetPlayerInfo(nil, gameAccountInfo.playerGuid, nil, {faction=gameAccountInfo.factionName, reName=true, reRealm=true,})
                if gameAccountInfo.areaName then --位置
                    if gameAccountInfo.areaName==playerMapNamp then
                        text=text..'|A:poi-islands-table:0:0|a'
                    end
                    zone= gameAccountInfo.areaName
                end
            end
            if gameAccountInfo.characterLevel and gameAccountInfo.characterLevel~=maxLevel then--等级
                text=text ..' |cff00ff00'..gameAccountInfo.characterLevel..'|r'
            end
        end
        icon= icon and format('|T%d:0|t', icon) or ''

        sub2=sub:CreateButton(icon..text, function(data)
            WoWTools_ChatMixin:Say(nil, data.name, true)
            self:settings(nil, WoWTools_DataMixin.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET, data.name, true)
            return MenuResponse.Open
        end, {name=wow.accountName, note=wow.note, zone=zone})

        sub2:SetTooltip(function(tooltip, description)
            tooltip:AddLine(description.data.note)
            tooltip:AddLine(WoWTools_TextMixin:CN(description.data.zone))
        end)
    end
    WoWTools_MenuMixin:SetScrollMode(sub)




--聊天泡泡
    root:CreateDivider()
    sub2=root:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '聊天泡泡' or CHAT_BUBBLES_TEXT, function()
        return C_CVar.GetCVarBool("chatBubbles")
    end, function()
        if not UnitAffectingCombat('player') then
            C_CVar.SetCVar("chatBubbles", not C_CVar.GetCVarBool("chatBubbles") and '1' or '0')
        else
            print(WoWTools_DataMixin.Icon.icon2..addName, WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        end
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('C_CVar.SetCVar(\"chatBubbles\")')
    end)

    sub3=sub2:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '自动' or SELF_CAST_AUTO, function()
        return Save().inInstanceBubblesDisabled
    end, function()
        Save().inInstanceBubblesDisabled= not Save().inInstanceBubblesDisabled and true or nil
        set_InInstance_Disabled_Bubbles()--副本禁用，其它开启
    end)

    sub3:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '聊天泡泡' or CHAT_BUBBLES_TEXT)
        tooltip:AddLine(' ')
        tooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '在副本中' or AGGRO_WARNING_IN_INSTANCE)..':', WoWTools_TextMixin:GetEnabeleDisable(false))
        tooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '其它' or OTHER)..':', WoWTools_TextMixin:GetEnabeleDisable(true))
    end)
end





























--####
--初始
--####
local function Init()
    SayButton.typeText=WoWTools_LabelMixin:Create(SayButton, {color=true})--10, nil, nil, true)
    SayButton.typeText:SetPoint('BOTTOM',0,2)

    SayButton.tipBubbles= SayButton:CreateTexture(nil, 'OVERLAY')
    SayButton.tipBubbles:SetSize(8, 8)
    SayButton.tipBubbles:SetPoint('TOPLEFT', 3, -0)
    SayButton.tipBubbles:SetAtlas('talents-button-reset')

    SayButton.numWhisper=WoWTools_LabelMixin:Create(SayButton, {color={r=0,g=1,b=0}})--最后密语,数量, 提示
    SayButton.numWhisper:SetPoint('TOPRIGHT',-3, 0)

    SayButton.texture:SetAtlas('transmog-icon-chat')

    function SayButton:set_tooltip()
        self:set_owner()
        if Save().type or Save().text or Save().name then
            local name
            if Save().type==SLASH_WHISPER1 then
                name= GetUnitName('target', true)
            elseif Save().name then
                name= Save().isWoW and WoWTools_DataMixin.Icon.net2..'|cff28a3ff'..Save().name or Save().name
            end
            GameTooltip:AddDoubleLine((Save().text or '')..(Save().type and ' '..Save().type or ''),(name or '')..WoWTools_DataMixin.Icon.left)
        end
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '密语数量' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_TEXTTOSPEECH_WHISPER, AUCTION_HOUSE_QUANTITY_LABEL), Save().numWhisper)
        GameTooltip:Show()
    end

    SayButton:SetupMenu(Init_Menu)

    function SayButton:set_OnMouseDown()
        if Save().type or Save().name then
            local name, wow= Save().name, Save().isWoW
            if Save().type==SLASH_WHISPER1 and UnitIsPlayer('target') then
                name=GetUnitName('target', true)
                wow= false
            end
            WoWTools_ChatMixin:Say(Save().type, name, wow)
        else
            return true
        end
    end

    function SayButton:settings(type, text, name, isWoW)
        Save().type= type
        Save().text= text
        Save().name= name
        Save().isWoW= isWoW

        if text=='大喊' then
            text='喊'
        elseif type and text:find('%w') then--处理英文
            text=type:gsub('/','')
        else
            text=WoWTools_TextMixin:sub(text, 1, 3)
        end

        self.typeText:SetText(text)
    end


    SayButton:settings(Save().type, Save().text, Save().name, Save().isWoW)
    set_chatBubbles_Tips() --提示，聊天泡泡，开启/禁用
    set_numWhisper_Tips()--最后密语,数量, 提示
end











--###########
--加载保存数据
--###########
local panel= CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
panel:RegisterEvent("CHAT_MSG_WHISPER")
panel:RegisterEvent("CHAT_MSG_BN_WHISPER")
panel:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM")
panel:RegisterEvent('PLAYER_ENTERING_WORLD')
panel:RegisterEvent('CVAR_UPDATE')

panel:SetScript("OnEvent", function(self, event, arg1, arg2, ...)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['ChatButton_Say']= WoWToolsSave['ChatButton_Say'] or P_Save
            Save().text= Save().text or (WoWTools_DataMixin.onlyChinese and '说' or SAY)

            addName= '|A:transmog-icon-chat:0:0|a'..(WoWTools_DataMixin.onlyChinese and '说' or SAY)
            SayButton= WoWTools_ChatMixin:CreateButton('Say', addName)

            if SayButton then--禁用Chat Button
                if #Save().WhisperTab>120 then
                    for i=121, #Save().WhisperTab do
                        Save().WhisperTab[i]=nil
                    end
                end

                Init()
                self:UnregisterEvent('ADDON_LOADED')
            else
                self:UnregisterAllEvents()
            end
        end

    elseif event=='CHAT_MSG_WHISPER_INFORM' or event=='CHAT_MSG_WHISPER' or event=='CHAT_MSG_BN_WHISPER' or event=='CHAT_MSG_BN_WHISPER_INFORM' then
        getWhisper(event, arg1, arg2, ...)

    elseif event== 'PLAYER_ENTERING_WORLD' and WoWToolsSave then
        set_InInstance_Disabled_Bubbles()--副本禁用，其它开启

    elseif event=='CVAR_UPDATE' and arg1=='chatBubbles' and WoWToolsSave then
        set_chatBubbles_Tips() --提示，聊天泡泡，开启/禁用
    end
end)