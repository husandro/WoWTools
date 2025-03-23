local Save={
    world= WoWTools_DataMixin.Player.Region==5 and '大脚世界频道' or 'World',
    myChatFilter= true,--过滤，多次，内容
    myChatFilterNum=70,

    myChatFilterAutoAdd= WoWTools_DataMixin.Player.husandro,
    myChatFilterPlayers={},--{[guid]=num,}

    userChatFilter=true,
    userChatFilterTab={},--{[name-realm]={num=0, guid=guid},}
}


local addName
local WorldButton
local FilterTextTab={--记录, 屏蔽内容
--[[
[text]={
    num=1,
    guid={
        [guid]=name
    }
},
]]
}







local function get_myChatFilter_Text()
    return (
        WoWTools_Mixin.onlyChinese and '内容限'..Save.myChatFilterNum..'个字符以内'
        or ERR_VOICE_CHAT_CHANNEL_NAME_TOO_LONG:gsub(CHANNEL_CHANNEL_NAME,''):gsub('30', Save.myChatFilterNum)
    )
end









local function Check_Channel(name)
    if not name or not select(2,GetChannelName(name)) then
        return 0--不存存在
    else
        local tab={GetChatWindowChannels(SELECTED_CHAT_FRAME:GetID())}
        for i= 1, #tab, 2 do
            if tab[i]==name then
                return 1--存在
            end
        end
        return 2--屏蔽
    end
end






local function Get_Channel_Color(name, value)
    value= value or Check_Channel(name)
    if value==0 then
        return '|cff9e9e9e'
    elseif value==2 then
        return '|cnRED_FONT_COLOR:'
    else
        return ''
    end
end






local function Set_Join(name, join, leave, remove)--加入,移除, 屏蔽
    if leave then
        LeaveChannelByName(name);
    elseif join then
        JoinPermanentChannel(name);
        ChatFrame_AddChannel(SELECTED_CHAT_FRAME, name);
    elseif remove then
        ChatFrame_RemoveChannel(SELECTED_CHAT_FRAME, name);
    end
    C_Timer.After(1, function() Check_Channel(name) end)
end











local function Set_LeftClick_Tooltip(name, channelNumber, texture, clubInfo)--设置点击提示,频道字符
    WorldButton.channelNumber=channelNumber
    WorldButton.channelName=name

    local text
    if name then
        text= name=='大脚世界频道' and '世' or WoWTools_TextMixin:sub(name, 1, 3)
    else
        text= WoWTools_Mixin.onlyChinese and '无' or NONE
    end

    if name == Save.world then
        WorldButton.texture:SetAtlas('WildBattlePet')
    elseif texture then
        if clubInfo and clubInfo.clubId then
            C_Club.SetAvatarTexture(WorldButton.texture, clubInfo.avatarId, clubInfo.clubType)
        else
            WorldButton.texture:SetTexture(texture)
        end
    else
        WorldButton.texture:SetAtlas('128-Store-Main')
    end
    WorldButton.leftClickTips:SetText(text)

end









local function Send_Say(name, channelNumber)--发送
    Save.lastName= name
    local check=Check_Channel(name)
    if check==0 or not channelNumber or channelNumber==0 then
        Set_Join(name, true)
        C_Timer.After(1, function()
            local channelNumber2 = GetChannelName(name)
            if channelNumber2 and channelNumber2>0 then
                WoWTools_ChatMixin:Say('/'..channelNumber2)
                Set_LeftClick_Tooltip(name, channelNumber2)--设置点击提示,频道字符
            else
                WoWTools_ChatMixin:Say(SLASH_JOIN4..' '..name)
            end
        end)
    else
        if check==2 and SELECTED_CHAT_FRAME:GetID()~=2 then
            Set_Join(name, true)
        end
        if channelNumber then
            Set_LeftClick_Tooltip(name, channelNumber)--设置点击提示,频道字符
            WoWTools_ChatMixin:Say('/'..channelNumber);
        else
            WoWTools_ChatMixin:Say(SLASH_JOIN4..' '..name)
        end
    end
end






































--#######
--屏蔽内容
--#######
local function WoWTools_Word_Filter(_, _, msg, name, _, _, _, _, _, _, _, _, _, guid)
    if Save.userChatFilter and Save.userChatFilterTab[name] then
        Save.userChatFilterTab[name]= {
                num= Save.userChatFilterTab[name].num +1,
                guid= guid,
        }
        return true

    elseif Save.myChatFilter and guid then
        if Save.myChatFilterPlayers[guid] then--屏蔽，玩家
            Save.myChatFilterPlayers[guid]= Save.myChatFilterPlayers[guid]+1
            return true

        elseif FilterTextTab[msg] then
            FilterTextTab[msg].guid[guid]= name
            FilterTextTab[msg].num= FilterTextTab[msg].num +1
            return true

        elseif not guid or guid== WoWTools_DataMixin.Player.GUID or WoWTools_UnitMixin:GetIsFriendIcon(name, guid) or WoWTools_DataMixin.GroupGuid[guid] then--自已, 好友
            return false

        elseif strlenutf8(msg)>Save.myChatFilterNum or msg:find('WTS') then-- msg:find('<.->') or  then
            if Save.myChatFilterAutoAdd then
                Save.myChatFilterPlayers[guid]= 1
            else
                FilterTextTab[msg]={
                    num=1,
                    guid={
                            [guid]=name,
                        },
                }
            end
            return true
        end
    end
    return false
end







local function Set_Filter()
    if Save.myChatFilter or Save.userChatFilter then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", WoWTools_Word_Filter)
    else
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_CHANNEL", WoWTools_Word_Filter)
    end
end













--玩家，添加，列表
local function Init_User_Chat_Filter()
    Menu.ModifyMenu("MENU_UNIT_FRIEND", function(_, root, data)
        if
            --not Save.myChatFilter
             not data.chatTarget
            or data.which~='FRIEND'
            or data.chatTarget==WoWTools_DataMixin.Player.name_realm
            or WoWTools_UnitMixin:GetIsFriendIcon(data.chatTarget)
            or WoWTools_DataMixin.GroupGuid[data.chatTarget]
        then
            return
        end--data.playerLocation


        local sub=root:CreateCheckbox(WoWTools_Mixin.onlyChinese and '屏蔽刷屏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, IGNORE, CLUB_FINDER_REPORT_SPAM),
        function(name)
            return Save.userChatFilterTab[name]
        end, function(name)
            if Save.userChatFilterTab[name] then
                Save.userChatFilterTab[name]= nil
            else
                Save.userChatFilterTab[name]={
                    num=0,
                    guid=nil,
                }
            end
        end, data.chatTarget)

        sub:SetTooltip(function(tooltip, description)
            tooltip:AddDoubleLine(WoWTools_Mixin.addName, addName)
            tooltip:AddDoubleLine()
            tooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '自定义屏蔽' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CUSTOM, IGNORE), WoWTools_TextMixin:GetEnabeleDisable(Save.userChatFilter))
            tooltip:AddLine(' ')
            tooltip:AddDoubleLine(
                (WoWTools_Mixin.onlyChinese and '屏蔽刷屏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, IGNORE, CLUB_FINDER_REPORT_SPAM)
                ..' '
                .. (Save.userChatFilterTab[description.name] and Save.userChatFilterTab[description.name].num) or ''),
                WoWTools_Mixin.onlyChinese and '添加/移除' or ADD..'/'..REMOVE
            )

        end)

        sub:CreateCheckbox(WoWTools_Mixin.onlyChinese and '自定义屏蔽' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CUSTOM, IGNORE), function()
            return Save.userChatFilter
        end, function()
            Save.userChatFilter= not Save.userChatFilter and true or false
            Set_Filter()
        end)

    end)
end






















--全部屏蔽, 现有列表
local function Set_Add_All_Player_Filter()
    local index= 0
    for _, tab in pairs(FilterTextTab) do
        for guid, name in pairs(tab.guid or {}) do
            if not Save.myChatFilterPlayers[guid] then
                Save.myChatFilterPlayers[guid]= 1
                index= index+1
                print(WoWTools_DataMixin.Icon.icon2.. addName,
                    WoWTools_Mixin.onlyChinese and '屏蔽' or IGNORE,
                    '|cff9e9e9e'..index..'|r',
                    WoWTools_UnitMixin:GetPlayerInfo(nil, guid, name, {reLink=true, reName=true, reRealm=true})
                )
            end
        end
    end
    FilterTextTab={}
end













--屏蔽刷屏, 菜单
local function Init_Filter_Menu(root)
    local sub, sub2, sub3

    local filterNum=0
    for _ in pairs(FilterTextTab) do
        filterNum= filterNum+1
    end

    local filterPlayer=0
    for _ in pairs(Save.myChatFilterPlayers) do
        filterPlayer= filterPlayer+1
    end



--屏蔽刷屏
    sub=root:CreateCheckbox(
        (WoWTools_Mixin.onlyChinese and '屏蔽刷屏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, IGNORE, CLUB_FINDER_REPORT_SPAM))
        .. ' '..(Save.myChatFilterAutoAdd and filterPlayer or filterNum),

        function()
            return Save.myChatFilter

        end, function()
            Save.myChatFilter= not Save.myChatFilter and true or nil
            Set_Filter()
            return MenuResponse.Close
        end)

    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('CHAT_MSG_CHANNEL')
        tooltip:AddLine(get_myChatFilter_Text())
        tooltip:AddLine(' ')
        local all=0
        for _, num in pairs(Save.myChatFilterPlayers) do
            all= all+ num
        end
        tooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '总计' or TOTAL, WoWTools_Mixin:MK(all, 3).. ' '..(WoWTools_Mixin.onlyChinese and "次" or VOICEMACRO_LABEL_CHARGE1))
    end)


if not Save.myChatFilter then
    return
end

--设置, 屏蔽刷屏, 数量
    sub2=sub:CreateButton('     '..(WoWTools_Mixin.onlyChinese and '设置' or SETTINGS)..' |cnGREEN_FONT_COLOR:'..Save.myChatFilterNum, function()
        StaticPopupDialogs['WoWToolsChatButtonWorldMyChatFilterNum']= {
            text=addName..'|n|n'..get_myChatFilter_Text(),
            whileDead=true, hideOnEscape=true, exclusive=true,
            hasEditBox=true,
            button1= WoWTools_Mixin.onlyChinese and '修改' or EDIT,
            button2= WoWTools_Mixin.onlyChinese and '取消' or CANCEL,
            OnShow = function(self)
                self.editBox:SetNumeric(true)
                self.editBox:SetNumber(Save.myChatFilterNum)
            end,
            OnAccept = function(self)
                local num= self.editBox:GetNumber()
                Save.myChatFilterNum= num
                print(WoWTools_Mixin.addName, WoWTools_TextMixin:CN(addName), get_myChatFilter_Text())
            end,
            EditBoxOnTextChanged=function(self)
                local num= self:GetNumber() or 0
                self:GetParent().button1:SetEnabled(num>=10 and num<2147483647)
            end,
            EditBoxOnEscapePressed = function(self2)
                self2:SetAutoFocus(false)
                self2:ClearFocus()
                self2:GetParent():Hide()
            end,
        }
        StaticPopup_Show('WoWToolsChatButtonWorldMyChatFilterNum')
    end)

    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(get_myChatFilter_Text())
    end)







--屏蔽玩家
    sub2=sub:CreateButton('     '..(WoWTools_Mixin.onlyChinese and '屏蔽玩家' or IGNORE_PLAYER)..' #'..filterPlayer, function()
        return MenuResponse.Refresh
    end, filterPlayer)



    if filterPlayer>0 then
--全部清除
        sub2:CreateButton('|A:bags-button-autosort-up:0:0|a'..(WoWTools_Mixin.onlyChinese and '全部清除' or CLEAR_ALL)..' #'..filterPlayer, function()
            Save.myChatFilterPlayers={}
        end)
        sub2:CreateDivider()

--玩家，列表
        local index=0
        for guid, num in pairs(Save.myChatFilterPlayers) do
            index= index+1
            local name= WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil,{reName=true, reRealm=true})
            name= name=='' and guid or name

            sub3=sub2:CreateButton('|cff9e9e9e'..index..')|r '..name..' |cff9e9e9e#'.. WoWTools_Mixin:MK(num, 3)..'|r', function(data)
                local player= WoWTools_UnitMixin:GetPlayerInfo(nil, data.guid, nil, {reName=true, reRealm=true, reLink=true})
                if Save.myChatFilterPlayers[data.guid] then
                    print(WoWTools_DataMixin.Icon.icon2.. addName, '|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '移除' or REMOVE)..'|r', player)
                else
                    print(WoWTools_DataMixin.Icon.icon2.. addName, '|cff9e9e9e'..(WoWTools_Mixin.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE)..'|r', player)
                end
                Save.myChatFilterPlayers[data.guid]=nil
                return MenuResponse.Open
            end, {guid=guid, num=num})

            sub3:SetTooltip(function(tooltip, description)
                tooltip:AddLine((WoWTools_Mixin.onlyChinese and '刷屏' or REPORTING_MINOR_CATEGORY_SPAM)..' #'..description.data.num)
                tooltip:AddLine(' ')
                if Save.myChatFilterPlayers[description.data.guid] then
                    tooltip:AddLine(WoWTools_Mixin.onlyChinese and '移除' or REMOVE)
                else
                    tooltip:AddLine(WoWTools_Mixin.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE)
                end
            end)

            local name2, realmName = select(6, GetPlayerInfoByGUID(guid))
            if name2 and realmName then
                realmName= realmName =='' and WoWTools_DataMixin.Player.realm or realmName
                sub3:CreateButton(WoWTools_Mixin.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER, function(data)
                    WoWTools_ChatMixin:Say(nil, data)
                    return MenuResponse.Open
                end, name2..'-'..realmName)
            end
        end

        --全部清除
        sub2:CreateDivider()
        sub2:CreateButton('|A:bags-button-autosort-up:0:0|a'..(WoWTools_Mixin.onlyChinese and '全部清除' or CLEAR_ALL)..' #'..filterPlayer, function()
            Save.myChatFilterPlayers={}
        end)
        WoWTools_MenuMixin:SetGridMode(sub2, filterPlayer)
    end







--自动添加
    sub:CreateCheckbox((WoWTools_Mixin.onlyChinese and '自动添加' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, ADD)), function()
        return Save.myChatFilterAutoAdd
    end, function()
        Save.myChatFilterAutoAdd= not Save.myChatFilterAutoAdd and true or nil
        if Save.myChatFilterAutoAdd then
            Set_Add_All_Player_Filter()--全部屏蔽, 现有列表
        end
        return MenuResponse.CloseAll
    end)



--没有自动，添加时，显示其它，菜单
 if not Save.myChatFilterAutoAdd and filterNum>0 then
    sub:CreateDivider()

--全部屏蔽, 现有列表
    sub:CreateButton('|A:GreenCross:0:0|a'..(WoWTools_Mixin.onlyChinese and '全部添加' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ALL, ADD))..' #'..filterNum, Set_Add_All_Player_Filter)


--全部清除, 屏蔽刷屏
    sub:CreateButton('|A:bags-button-autosort-up:0:0|a'..(WoWTools_Mixin.onlyChinese and '全部清除' or CLEAR_ALL)..' #'..filterNum, function()
        FilterTextTab={}
    end)


    sub:CreateDivider()
--屏蔽刷屏，显示内容
    local index=0
    for text, tab in pairs(FilterTextTab) do
        index= index+1

        local playerName
        local playerName2
        for guid, name in pairs(tab.guid) do
            playerName=WoWTools_UnitMixin:GetPlayerInfo(nil, guid, name, {reName=true, reRealm=true})
            playerName2= name
            if playerName~='' then
                break
            end
        end

        sub2=sub:CreateButton('|cff9e9e9e'..index..')|r '..(playerName or text).. ' |cff9e9e9e'..strlenutf8(text)..'|r', function(data)
            WoWTools_ChatMixin:Say(nil, data.name)
            return MenuResponse.Refresh
        end, {data=tab, text=text, name=playerName2})
        sub2:SetTooltip(function(tooltip, description)
            for guid in pairs(description.data.data.guid or {}) do
                tooltip:AddDoubleLine(WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {reName=true, reRealm=true}), ' ')
            end
            --tooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '屏蔽玩家' or IGNORE_PLAYER, WoWTools_DataMixin.Icon.left)                
            tooltip:AddDoubleLine(
                '|cnGREEN_FONT_COLOR:'..strlenutf8(description.data.text)..(WoWTools_Mixin.onlyChinese and '字符' or 'Word count'),
                '|cnGREEN_FONT_COLOR:#'..(description.data.data.num or 0)..(WoWTools_Mixin.onlyChinese and "次" or VOICEMACRO_LABEL_CHARGE1)
            )
            tooltip:AddLine(' ')
            tooltip:AddLine(description.data.text, nil, nil,nil, true)
        end)



--显示, 内容
        sub2:CreateButton(WoWTools_Mixin.onlyChinese and '显示' or SHOW, function(data)
            local str=''
            local player2
            for guid, name in pairs(data.guid or {}) do
                local player= WoWTools_UnitMixin:GetPlayerInfo(nil, guid, name, {reName=true, reRealm=true})
                str= str..player..'|n'
                player2= player2 or player
            end
            str=str..'|n'..data.text

            WoWTools_TextMixin:ShowText(str, player2 or data.playerName)
            return MenuResponse.Open
        end, {text=text, guid=tab.guid, playerName=playerName})

        if type(playerName2)=='string' then
            sub2:CreateButton((WoWTools_Mixin.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER)..WoWTools_DataMixin.Icon.left, function(data)
                WoWTools_ChatMixin:Say(nil, data)
                return MenuResponse.Open
            end, playerName2)
        end

--屏蔽
        sub2:CreateDivider()
        sub2:CreateButton(WoWTools_Mixin.onlyChinese and '屏蔽' or IGNORE, function(data)
            for guid, name in pairs(data.guid or {}) do
                local player= WoWTools_UnitMixin:GetPlayerInfo(nil, guid, name, {reLink=true, reName=true, reRealm=true})
                if Save.myChatFilterPlayers[guid] then
                    print(WoWTools_DataMixin.Icon.icon2.. addName, player)
                else
                    Save.myChatFilterPlayers[guid]= 1
                    print(WoWTools_DataMixin.Icon.icon2.. addName, '|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '屏蔽' or IGNORE)..'|r', player)
                end
            end
            FilterTextTab[data.text]= nil
            return MenuResponse.Close
        end, {text=text, guid=tab.guid})
    end

    WoWTools_MenuMixin:SetGridMode(sub, filterNum)
end

end















--屏蔽刷屏, 自定义，菜单
local function Init_User_Filter_Menu(root)
    local sub, sub2

    local useNum= 0
    for _ in pairs(Save.userChatFilterTab) do
        useNum= useNum+1
    end
    sub= root:CreateCheckbox((WoWTools_Mixin.onlyChinese and '自定义屏蔽' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CUSTOM, IGNORE)).. ' '.. useNum, function()
        return Save.userChatFilter
    end, function()
        Save.userChatFilter= not Save.userChatFilter and true or false
        Set_Filter()
        return MenuResponse.Close
    end)

    sub:SetTooltip(function(tooltip)
        local all=0
        for _, info in pairs(Save.userChatFilterTab) do
            all= all+ info.num
        end
        tooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '总计' or TOTAL, WoWTools_Mixin:MK(all, 3).. ' '..(WoWTools_Mixin.onlyChinese and "次" or VOICEMACRO_LABEL_CHARGE1))
    end)

if not Save.userChatFilter then
    return
end

    sub:CreateButton(WoWTools_Mixin.onlyChinese and '添加' or ADD, function()
        StaticPopupDialogs['WoWTools_ChatButton_Wolrd_userChatFilterADD']= {
            text=(WoWTools_Mixin.onlyChinese and '自定义屏蔽' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CUSTOM, IGNORE))
                ..'|n|n'..WoWTools_DataMixin.Player.name_realm..'|n',
            whileDead=true, hideOnEscape=true, exclusive=true,
            hasEditBox=true,
            button1= WoWTools_Mixin.onlyChinese and '添加' or ADD,
            button2= WoWTools_Mixin.onlyChinese and '取消' or CANCEL,
            OnShow = function(self)
                self.button1:SetEnabled(false)
            end,
            OnHide= function(self)
                self.editBox:ClearFocus()
            end,
            OnAccept = function(self)
                local text= self.editBox:GetText()
                if not text:find('%-') then
                    text= text..'-'..WoWTools_DataMixin.Player.realm
                end
                Save.userChatFilterTab[text]={num=0, guid=nil}
                print(WoWTools_DataMixin.Icon.icon2.. addName, WoWTools_Mixin.onlyChinese and '添加' or ADD, text, WoWTools_UnitMixin:GetPlayerInfo(nil, nil, text, {reName=true, reRealm=true, reLink=true}))
            end,
            EditBoxOnTextChanged=function(self)
                local text= self:GetText() or ''
                local enabled=true
                if text==''
                    or text== WoWTools_DataMixin.Player.name_realm
                    or text== WoWTools_DataMixin.Player.Name

                    or text:find('^ ')
                    or text:find(' $')

                    or text:find('%.')
                    or text:find('%+')
                    or text:find('%*')
                    or text:find('%?')
                    or text:find('%[')
                    or text:find('%^')
                    or text:find('%$')
                then
                    enabled=false
                end
                self:GetParent().button1:SetEnabled(enabled)
            end,
            EditBoxOnEscapePressed = function(self)
                self:GetParent():Hide()
            end,
        }
        StaticPopup_Show('WoWTools_ChatButton_Wolrd_userChatFilterADD')
    end)



    if useNum>0 then

    --全部清除, 自定义屏蔽
        sub:CreateButton('|A:bags-button-autosort-up:0:0|a'..(WoWTools_Mixin.onlyChinese and '全部清除' or CLEAR_ALL)..' #'..useNum, function()
            Save.userChatFilterTab={}
        end)
        sub:CreateDivider()

        for name, tab in pairs(Save.userChatFilterTab) do
            local player= WoWTools_UnitMixin:GetPlayerInfo({name=name, guid=tab.guid, reName=true, reRealm=true})
            player= (not player or player=='') and name or player

            sub2=sub:CreateButton(player..' '..tab.num, function(data)
                if Save.userChatFilterTab[data.name] then
                    print(WoWTools_DataMixin.Icon.icon2.. addName, WoWTools_Mixin.onlyChinese and '移除' or REMOVE, WoWTools_UnitMixin:GetPlayerInfo({name=data.name, guid=data.tab.guid, reName=true, reRealm=true, reLink=true}))
                    Save.userChatFilterTab[data.name]=nil
                end
                return MenuResponse.Refresh
            end, {name=name, tab=tab})

            sub2:SetTooltip(function(tooltip)
                tooltip:AddLine(WoWTools_Mixin.onlyChinese and '移除' or REMOVE)
            end)
        end
        WoWTools_MenuMixin:SetGridMode(sub, useNum)
    end
end























local function Add_Initializer(button, description)
    button:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed= (self.elapsed or 1) +elapsed
        if self.elapsed>1 then
            self.elapsed=0
            local value= Check_Channel(description.data.name)
            if value==0 then--不存在
                self.fontString:SetTextColor(0.62, 0.62, 0.62)
            elseif value==2 then----屏蔽
                self.fontString:SetTextColor(1,0,0)
            else
                self.fontString:SetTextColor(1,1,1)
            end
        end
    end)

    if button.leftTexture1 then
        button.leftTexture1:SetShown(false)
    end
    if button.leftTexture2 then
        button.leftTexture2:SetAtlas('newplayertutorial-icon-mouse-leftbutton')
    end

    button:SetScript('OnHide', function(self)
        self:SetScript('OnUpdate', nil)
        self.elapsed=nil
        if self.fontString then
            self.fontString:SetTextColor(1,1,1)
        end
    end)
end












local function Channel_Opetion_Menu(sub, name)

    --世界，修改
if name== Save.world then
    sub:CreateButton(WoWTools_Mixin.onlyChinese and '修改名称' or EQUIPMENT_SET_EDIT:gsub('/.+',''), function()
        StaticPopupDialogs['WoWToolsChatButtonWorldChangeNamme']={
            text=(WoWTools_Mixin.onlyChinese and '修改名称' or EQUIPMENT_SET_EDIT:gsub('/.+',''))..'|n|n'..(WoWTools_Mixin.onlyChinese and '重新加载UI' or RELOADUI ),
            whileDead=true, hideOnEscape=true, exclusive=true,
            hasEditBox=1,
            button1= WoWTools_Mixin.onlyChinese and '确定' or OKAY,
            button2= WoWTools_Mixin.onlyChinese and '取消' or CANCEL,
            OnShow= function(s)
                s.editBox:SetAutoFocus(false)
                s.editBox:SetText(WoWTools_DataMixin.Player.Region==5 and '大脚世界频道' and Save.world or 'World')
                s.button1:SetEnabled(false)
                s.editBox:SetFoucus()
            end,
            OnHide= function(s)
                s.editBox:SetText("")
                s.editBox:ClearFocus()
            end,
            OnAccept= function(s)
                Save.world= s.editBox:GetText()
                WoWTools_Mixin:Reload()
            end,
            EditBoxOnTextChanged=function(s)
                local t= s:GetText()
                s:GetParent().button1:SetEnabled(t~= Save.world and t:gsub(' ', '')~='')
            end,
            EditBoxOnEscapePressed = function(s)
                s:SetAutoFocus(false)
                s:ClearFocus()
                s:GetParent():Hide()
            end,
        }
        StaticPopup_Show('WoWToolsChatButtonWorldChangeNamme')
    end)
    sub:CreateDivider()
end

    local value= Check_Channel(name)
    local col= value==1 and '' or '|cff9e9e9e'
    sub:CreateButton(col..(WoWTools_Mixin.onlyChinese and '屏蔽' or IGNORE), function(data)
        Set_Join(data, nil, nil, true)--加入,移除,屏蔽
        return MenuResponse.Close
    end, name)

    col= value==1 and '|cff9e9e9e' or ''
    sub:CreateButton(col..(WoWTools_Mixin.onlyChinese and '加入' or CHAT_JOIN), function(data)
        Set_Join(data, true)
        return MenuResponse.Close
    end, name)
end












--添加菜单
local function Add_Menu(root, name, channelNumber)
    local text, sub, communityName, communityTexture, online
    local clubId=name:match('Community:(%d+)')

    if clubId then
        WoWTools_Mixin:Load({id=clubId, type='club'})
    end

    local clubInfo= clubId and C_Club.GetClubInfo(clubId)--社区名称

    if clubInfo and (clubInfo.shortName or clubInfo.name) then
        online= WoWTools_GuildMixin:GetNumOnline(clubInfo.clubId)--在线成员
        text= (clubInfo.avatarId==1
                and '|A:plunderstorm-glues-queueselector-trio-selected:0:0|a'
                or ('|T'..(clubInfo.avatarId or 0)..':0|t')
            )
            ..(clubInfo.clubType == Enum.ClubType.BattleNet and '|cff00ccff' or '|cffff8000')
            ..(clubInfo.shortName or clubInfo.name)
            ..'|r'
            ..(clubInfo.favoriteTimeStamp and '|A:recipetoast-icon-star:0:0|a' or ' ')
            ..((online==0 and '|cff828282' or '|cffffffff')..online)
        communityName=clubInfo.shortName or clubInfo.name
        communityTexture=clubInfo.avatarId
    end



    sub=root:CreateCheckbox(
        ((channelNumber and channelNumber>0) and channelNumber..' ' or '')..(text or name),--频道数字
    function(data)
        return WorldButton.channelNumber == GetChannelName(data.communityName or data.name)

    end, function(data)
        Send_Say(data.name, data.channelNumber)
        Set_LeftClick_Tooltip(--设置点击提示,频道字符
            data.communityName or data.name,
            data.channelNumber,
            data.texture,
            data.clubInfo
        )

    end, {
        texture=communityTexture,
        name=name,
        communityName=communityName,
        channelNumber= channelNumber,
        clubId= clubId,
        clubInfo= clubInfo,
    })
    --self.Description.EditBox.Instructions:SetText(self.clubType == Enum.ClubType.BattleNet and COMMUNITIES_CREATE_DIALOG_DESCRIPTION_INSTRUCTIONS_BATTLE_NET or COMMUNITIES_CREATE_DIALOG_DESCRIPTION_INSTRUCTIONS);

    sub:SetTooltip(function(tooltip, desc)
        local value= Check_Channel(desc.data.name)
        local t
        if value==0 then--不存在
            t= Get_Channel_Color(nil, 0)..(WoWTools_Mixin.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE)
        elseif value==1 then
            t= WoWTools_Mixin.onlyChinese and '已加入' or CLUB_FINDER_JOINED
        elseif value==2 then--屏蔽
            t= Get_Channel_Color(name, 2)..(WoWTools_Mixin.onlyChinese and '已屏蔽' or IGNORED)
        end

        local club= desc.data.clubInfo

        if club and club.clubId then
            local isNet=  club.clubType == Enum.ClubType.BattleNet
            tooltip:AddLine(club.name, club.shortName)
            local col= isNet and '|cff00ccff' or '|cffff8000'
            tooltip:AddDoubleLine(
                t and col..t,
                col
                ..(
                    isNet
                    and (WoWTools_Mixin.onlyChinese and '暴雪群组' or COMMUNITIES_INVITATION_FRAME_TYPE)
                    or (WoWTools_Mixin.onlyChinese and '社区' or CLUB_FINDER_COMMUNITY_TYPE)
                )
            )
            tooltip:AddLine(club.description, nil, nil, nil, true)
            tooltip:AddDoubleLine('clubId', club.clubId)
        elseif t then
            tooltip:AddLine(t)
        end
    end)

    sub:AddInitializer(Add_Initializer)

    Channel_Opetion_Menu(sub, name, channelNumber)
end



















local function Init_Menu(_, root)

--世界频道
    local world = GetChannelName(Save.world)
    Add_Menu(root, Save.world, world)

--频道，列表
    root:CreateDivider()
    local find
    local channels = {GetChannelList()}
    for i = 1, #channels, 3 do
        local channelNumber, name, disabled = channels[i], channels[i+1], channels[i+2]
        if not disabled and channelNumber and name~=Save.world then
            Add_Menu(root, name, channelNumber)
            find=true
        end
    end
    if find then
        root:CreateDivider()
    end



    Init_Filter_Menu(root)--屏蔽刷屏, 菜单

    Init_User_Filter_Menu(root)--屏蔽刷屏, 自定义，菜单
end
















--####
--初始
--####
local function Init()
    WorldButton.texture:SetAtlas('128-Store-Main')

    WorldButton.leftClickTips=WoWTools_LabelMixin:Create(WorldButton, {size=12, color=true, justifyH='CENTER'})--10, nil, nil, true, nil, 'CENTER')
    WorldButton.leftClickTips:SetPoint('BOTTOM',0,2)

    function WorldButton:set_tooltip()
        self:set_owner()

        local find
        find=0
        for _ in pairs(FilterTextTab) do
            find= find+1
        end

        GameTooltip:AddDoubleLine((WoWTools_Mixin.onlyChinese and '屏蔽刷屏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, IGNORE, CLUB_FINDER_REPORT_SPAM))..' #'..find, WoWTools_TextMixin:GetEnabeleDisable(Save.myChatFilter))
        GameTooltip:AddLine(' ')

        local clubID, channelNumber, name, disabled, clubInfo, col
        local channels = {GetChannelList()}
        local value
        for i = 1, #channels, 3 do
            channelNumber, name, disabled = channels[i], channels[i+1], channels[i+2]
            if not disabled and channelNumber and name then
                value= Check_Channel(name)
                col= Get_Channel_Color(name, value)

                find= (channelNumber and WorldButton.channelNumber==channelNumber) and WoWTools_DataMixin.Icon.left or '   '
                
                clubID=name:match('Community:(%d+)');
                if clubID then
                    WoWTools_Mixin:Load({id=clubID, type='club'})

                    clubInfo= C_Club.GetClubInfo(clubID)

                    if clubInfo and clubInfo.name then
                        name= (clubInfo.avatarId==1
                                and '|A:plunderstorm-glues-queueselector-trio-selected:0:0|a'
                                or ('|T'..(clubInfo.avatarId or 0)..':0|t')
                            )
                            ..clubInfo.name
                    end
                end

                GameTooltip:AddDoubleLine(col..channelNumber..')', col..name..find)
            end
        end
        GameTooltip:Show()
    end

    --[[WorldButton:SetScript("OnClick",function(self, d)
        if d=='LeftButton' and self.channelNumber and self.channelNumber>0 then
            Send_Say(self.channelName, self.channelNumber)
            --WoWTools_ChatMixin:Say('/'..self.channelNumber)
            self:set_tooltip()
        else
            MenuUtil.CreateContextMenu(self, Init_Menu)
            GameTooltip:Hide()
        end
    end)]]

    WorldButton:SetupMenu(Init_Menu)

    function WorldButton:set_OnMouseDown()
        if self.channelNumber and self.channelNumber>0 then
            Send_Say(self.channelName, self.channelNumber)
        else
            return true
        end
    end

    --[[WorldButton:SetScript('OnMouseDown',function(self, d)
        if d=='LeftButton' and self.channelNumber and self.channelNumber>0 then
            Send_Say(self.channelName, self.channelNumber)
            self:CloseMenu()
            self:set_tooltip()
        end
    end)]]

    --[[WorldButton:SetScript('OnLeave', function(self)
        self:state_leave()
        GameTooltip:Hide()
    end)
    WorldButton:SetScript('OnEnter', function(self)
        self:state_enter()--Init_Menu)
        self:set_tooltip()
    end)]]

    if Save.lastName then
        local channelNumber = GetChannelName(Save.lastName)
        if channelNumber and channelNumber>0 then
            WorldButton.channelNumber= channelNumber
            Set_LeftClick_Tooltip(Save.lastName, channelNumber)
        end
    end
    if Save.myChatFilter then
        Set_Filter()
    end

    Init_User_Chat_Filter()--玩家，添加，列表
end
























--###########
--加载保存数据
--###########
local panel= CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            Save= WoWToolsSave['ChatButtonWorldChannel'] or Save
            Save.myChatFilterPlayers= Save.myChatFilterPlayers or {}
            Save.userChatFilterTab= Save.userChatFilterTab or {}

            addName= '|A:tokens-WoW-generic-regular:0:0|a'..(WoWTools_Mixin.onlyChinese and '频道' or CHANNEL)
            WorldButton= WoWTools_ChatMixin:CreateButton('World', addName)

            if WorldButton then--禁用Chat Button

                Init()
                self:RegisterEvent('PLAYER_ENTERING_WORLD')

            end
            self:UnregisterEvent('ADDON_LOADED')

        end

    elseif event == "PLAYER_LOGOUT" then
        if not WoWTools_DataMixin.ClearAllSave then
            WoWToolsSave['ChatButtonWorldChannel']=Save
        end

    elseif event== 'PLAYER_ENTERING_WORLD' then
        FilterTextTab={}--记录, 屏蔽内容

    end
end)
