local id, e = ...

local Save={
    world= e.Player.region==5 and '大脚世界频道' or 'World',
    myChatFilter= true,--过滤，多次，内容
    myChatFilterNum=70,

    myChatFilterAutoAdd= e.Player.husandro,
    myChatFilterPlayers={},--{[guid]=num,}

    userChatFilter=false,
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
        e.onlyChinese and '内容限'..Save.myChatFilterNum..'个字符以内'
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











local function Set_LeftClick_Tooltip(name, channelNumber, texture)--设置点击提示,频道字符
    WorldButton.channelNumber=channelNumber
    WorldButton.channelName=name

    local text
    if name then
        text= name=='大脚世界频道' and '世' or e.WA_Utf8Sub(name, 1, 3)
    else
        text= e.onlyChinese and '无' or NONE
    end

    if name == Save.world then
        WorldButton.texture:SetAtlas('WildBattlePet')
    elseif texture then
        WorldButton.texture:SetTexture(texture)
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
                e.Say('/'..channelNumber2)
                Set_LeftClick_Tooltip(name, channelNumber2)--设置点击提示,频道字符
            else
                e.Say(SLASH_JOIN4..' '..name)
            end
        end)
    else
        if check==2 and SELECTED_CHAT_FRAME:GetID()~=2 then
            Set_Join(name, true)
        end
        if channelNumber then
            Set_LeftClick_Tooltip(name, channelNumber)--设置点击提示,频道字符
            e.Say('/'..channelNumber);
        else
            e.Say(SLASH_JOIN4..' '..name)
        end
    end
end






































--#######
--屏蔽内容
--#######
local function Set_myChat_Filter(_, _, msg, name, _, _, _, _, _, _, _, _, _, guid)
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

        elseif not guid or guid== e.Player.guid or e.GetFriend(name, guid) or e.GroupGuid[guid] then--自已, 好友
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
        ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", Set_myChat_Filter)
    else
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_CHANNEL", Set_myChat_Filter)
    end
end













--玩家，添加，列表
local function Init_User_Chat_Filter()
    Menu.ModifyMenu("MENU_UNIT_FRIEND", function(_, root, data)
        if
            --not Save.myChatFilter
             not data.chatTarget
            or data.which~='FRIEND'
            or data.chatTarget==e.Player.name_realm
            or e.GetFriend(data.chatTarget)
            or e.GroupGuid[data.chatTarget]
        then
            return
        end--data.playerLocation


        local sub=root:CreateCheckbox(e.onlyChinese and '屏蔽刷屏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, IGNORE, CLUB_FINDER_REPORT_SPAM),
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
            tooltip:AddDoubleLine(id, addName)
            tooltip:AddDoubleLine()
            tooltip:AddDoubleLine(e.onlyChinese and '自定义屏蔽' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CUSTOM, IGNORE), e.GetEnabeleDisable(Save.userChatFilter))
            tooltip:AddLine(' ')
            tooltip:AddDoubleLine(
                (e.onlyChinese and '屏蔽刷屏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, IGNORE, CLUB_FINDER_REPORT_SPAM)
                ..' '
                .. (Save.userChatFilterTab[description.name] and Save.userChatFilterTab[description.name].num) or ''),
                e.onlyChinese and '添加/移除' or ADD..'/'..REMOVE
            )

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
                print(id, addName, e.onlyChinese and '屏蔽' or IGNORE, '|cff9e9e9e'..index..'|r', e.GetPlayerInfo({guid=guid, name=name, reLink=true, reName=true, reRealm=true}))
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
        (e.onlyChinese and '屏蔽刷屏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, IGNORE, CLUB_FINDER_REPORT_SPAM))
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
        tooltip:AddDoubleLine(e.onlyChinese and '总计' or TOTAL, e.MK(all, 3).. ' '..(e.onlyChinese and "次" or VOICEMACRO_LABEL_CHARGE1))
    end)


if not Save.myChatFilter then
    return
end

--设置, 屏蔽刷屏, 数量
    sub2=sub:CreateButton('     '..(e.onlyChinese and '设置' or SETTINGS)..' |cnGREEN_FONT_COLOR:'..Save.myChatFilterNum, function()
        StaticPopupDialogs[id..addName..'myChatFilterNum']= {
            text=id..' '..addName..'|n|n'..get_myChatFilter_Text(),
            whileDead=true, hideOnEscape=true, exclusive=true,
            hasEditBox=true,
            button1= e.onlyChinese and '修改' or EDIT,
            button2= e.onlyChinese and '取消' or CANCEL,
            OnShow = function(self)
                self.editBox:SetNumeric(true)
                self.editBox:SetNumber(Save.myChatFilterNum)
            end,
            OnAccept = function(self)
                local num= self.editBox:GetNumber()
                Save.myChatFilterNum= num
                print(id, e.cn(addName), get_myChatFilter_Text())
            end,
            EditBoxOnTextChanged=function(self)
                local num= self:GetNumber() or 0
                self:GetParent().button1:SetEnabled(num>=10)
            end,
            EditBoxOnEscapePressed = function(self2)
                self2:SetAutoFocus(false)
                self2:ClearFocus()
                self2:GetParent():Hide()
            end,
        }
        StaticPopup_Show(id..addName..'myChatFilterNum')
    end)

    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(get_myChatFilter_Text())
    end)







--屏蔽玩家
    sub2=sub:CreateButton('     '..(e.onlyChinese and '屏蔽玩家' or IGNORE_PLAYER)..' #'..filterPlayer, function()
        return MenuResponse.Refresh
    end, filterPlayer)



    if filterPlayer>0 then
--全部清除
        sub2:CreateButton('|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '全部清除' or CLEAR_ALL)..' #'..filterPlayer, function()
            Save.myChatFilterPlayers={}
        end)
        sub2:CreateDivider()

--玩家，列表
        local index=0
        for guid, num in pairs(Save.myChatFilterPlayers) do
            index= index+1
            local name= e.GetPlayerInfo({guid=guid, reName=true, reRealm=true})
            name= name=='' and guid or name
            
            sub3=sub2:CreateButton('|cff9e9e9e'..index..')|r '..name..' |cff9e9e9e#'.. e.MK(num, 3)..'|r', function(data)
                local player= e.GetPlayerInfo({guid=data.guid, reName=true, reRealm=true, reLink=true})                
                if Save.myChatFilterPlayers[data.guid] then
                    print(id, addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|r', player)
                else
                    print(id, addName, '|cff9e9e9e'..(e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE)..'|r', player)
                end
                Save.myChatFilterPlayers[data.guid]=nil
                return MenuResponse.Open
            end, {guid=guid, num=num})

            sub3:SetTooltip(function(tooltip, description)
                tooltip:AddLine((e.onlyChinese and '刷屏' or REPORTING_MINOR_CATEGORY_SPAM)..' #'..description.data.num)
                tooltip:AddLine(' ')
                if Save.myChatFilterPlayers[description.data.guid] then
                    tooltip:AddLine(e.onlyChinese and '移除' or REMOVE)
                else
                    tooltip:AddLine(e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE)
                end
            end)

            local name, realmName = select(6, GetPlayerInfoByGUID(guid))
            if name and realmName then
                realmName= realmName =='' and e.Player.realm or realmName
                sub3:CreateButton(e.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER, function(data)
                    e.Say(nil, data)
                    return MenuResponse.Open
                end, name..'-'..realmName)
            end
        end


        if filterPlayer>35 then
            sub2:SetGridMode(MenuConstants.VerticalGridDirection, math.ceil(filterPlayer/35))
        end
    end







--自动添加
    sub:CreateCheckbox((e.onlyChinese and '自动添加' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, ADD)), function()
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
    sub:CreateButton('|A:GreenCross:0:0|a'..(e.onlyChinese and '全部添加' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ALL, ADD))..' #'..filterNum, Set_Add_All_Player_Filter)


--全部清除, 屏蔽刷屏
    sub:CreateButton('|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '全部清除' or CLEAR_ALL)..' #'..filterNum, function()
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
            playerName=e.GetPlayerInfo({guid=guid, name=name, reName=true, reRealm=true})
            playerName2= name
            if playerName~='' then
                break
            end
        end

        sub2=sub:CreateButton('|cff9e9e9e'..index..')|r '..(playerName or text).. ' |cff9e9e9e'..strlenutf8(text)..'|r', function(data)
            e.Say(nil, data.name)
            return MenuResponse.Refresh
        end, {data=tab, text=text, name=playerName2})
        sub2:SetTooltip(function(tooltip, description)
            for guid in pairs(description.data.data.guid or {}) do
                tooltip:AddDoubleLine(e.GetPlayerInfo({guid=guid, reName=true, reRealm=true}), ' ')
            end
            --tooltip:AddDoubleLine(e.onlyChinese and '屏蔽玩家' or IGNORE_PLAYER, e.Icon.left)                
            tooltip:AddDoubleLine(
                '|cnGREEN_FONT_COLOR:'..strlenutf8(description.data.text)..(e.onlyChinese and '字符' or 'Word count'),
                '|cnGREEN_FONT_COLOR:#'..(description.data.data.num or 0)..(e.onlyChinese and "次" or VOICEMACRO_LABEL_CHARGE1)
            )
            tooltip:AddLine(' ')
            tooltip:AddLine(description.data.text, nil, nil,nil, true)
        end)

        --[[sub2:AddInitializer(function(button)
            button:SetHyperlinksEnabled(true)
            button:SetScript('OnHyperlinkLeave', GameTooltip_Hide)
            button:SetScript('OnHyperlinkEnter', function(self, link)
                if link then
                    e.tips:SetOwner(self, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:SetHyperlink(link)
                    e.tips:Show()
                end
            end)
            button:SetScript('OnHyperlinkClick', function(_, link, text2, region)
                SetItemRef(link, text2, region, nil)
            end)
            button:SetScript('OnHide', function(self)
                self:SetScript('OnHyperlinkLeave', nil)
                self:SetScript('OnHyperlinkEnter', nil)
                self:SetScript('OnHyperlinkClick', nil)
            end)
        end)]]



--显示, 内容
        sub2:CreateButton(e.onlyChinese and '显示' or SHOW, function(data)
            local str=''
            local player2
            for guid, name in pairs(data.guid or {}) do
                local player= e.GetPlayerInfo({guid=guid, name=name, reName=true, reRealm=true})
                str= str..player..'|n'
                player2= player2 or player
            end
            str=str..'|n'..data.text

            e.ShowTextFrame(str, player2 or data.playerName)
            return MenuResponse.Open
        end, {text=text, guid=tab.guid, playerName=playerName})

        if type(playerName2)=='string' then
            sub2:CreateButton((e.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER)..e.Icon.left, function(data)
                e.Say(nil, data)
                return MenuResponse.Open
            end, playerName2)
        end

--屏蔽
        sub2:CreateDivider()
        sub2:CreateButton(e.onlyChinese and '屏蔽' or IGNORE, function(data)
            for guid, name in pairs(data.guid or {}) do
                local player= e.GetPlayerInfo({guid=guid, name=name, reLink=true, reName=true, reRealm=true})
                if Save.myChatFilterPlayers[guid] then
                    print(id, addName, '|cff9e9e9e'..(e.onlyChinese and '已存在|r' or 'Existed|r'), player)
                else
                    Save.myChatFilterPlayers[guid]= 1
                    print(id, addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '屏蔽' or IGNORE)..'|r', player)
                end
            end
            FilterTextTab[data.text]= nil
            return MenuResponse.Close
        end, {text=text, guid=tab.guid})
    end

    if filterNum>35 then
        sub:SetGridMode(MenuConstants.VerticalGridDirection, math.ceil(filterNum/35))
    end
end

end















--屏蔽刷屏, 自定义，菜单
local function Init_User_Filter_Menu(root)
    local sub, sub2

    local useNum= 0
    for _ in pairs(Save.userChatFilterTab) do
        useNum= useNum+1
    end
    sub= root:CreateCheckbox((e.onlyChinese and '自定义屏蔽' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CUSTOM, IGNORE)).. ' '.. useNum, function()
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
        tooltip:AddDoubleLine(e.onlyChinese and '总计' or TOTAL, e.MK(all, 3).. ' '..(e.onlyChinese and "次" or VOICEMACRO_LABEL_CHARGE1))
    end)

if not Save.userChatFilter then
    return
end

    sub:CreateButton(e.onlyChinese and '添加' or ADD, function()
        StaticPopupDialogs['WoWTools_ChatButton_Wolrd_userChatFilterADD']= {
            text=(e.onlyChinese and '自定义屏蔽' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CUSTOM, IGNORE))
                ..'|n|n'..e.Player.name_realm..'|n',
            whileDead=true, hideOnEscape=true, exclusive=true,
            hasEditBox=true,
            button1= e.onlyChinese and '添加' or ADD,
            button2= e.onlyChinese and '取消' or CANCEL,
            OnShow = function(self)
                self.button1:SetEnabled(false)
            end,
            OnHide= function(self)
                self.editBox:ClearFocus()
            end,
            OnAccept = function(self)
                local text= self.editBox:GetText()
                if not text:find('%-') then
                    text= text..'-'..e.Player.realm
                end
                Save.userChatFilterTab[text]={num=0, guid=nil}
                print(id, addName, e.onlyChinese and '添加' or ADD, text, e.GetPlayerInfo({name=text, reName=true, reRealm=true, reLink=true}))
            end,
            EditBoxOnTextChanged=function(self)
                local text= self:GetText() or ''
                local enabled=true
                if text==''
                    or text== e.Player.name_realm
                    or text== e.Player.name

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
        sub:CreateButton('|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '全部清除' or CLEAR_ALL)..' #'..useNum, function()
            Save.userChatFilterTab={}
        end)
        sub:CreateDivider()

        for name, tab in pairs(Save.userChatFilterTab) do
            local player= e.GetPlayerInfo({name=name, guid=tab.guid, reName=true, reRealm=true})
            player= (not player or player=='') and name or player

            sub2=sub:CreateButton(player..' '..tab.num, function(data)
                if Save.userChatFilterTab[data.name] then
                    print(id, addName, e.onlyChinese and '移除' or REMOVE, e.GetPlayerInfo({name=data.name, guid=data.tab.guid, reName=true, reRealm=true, reLink=true}))
                    Save.userChatFilterTab[data.name]=nil
                end
                return MenuResponse.Refresh
            end, {name=name, tab=tab})

            sub2:SetTooltip(function(tooltip)
                tooltip:AddLine(e.onlyChinese and '移除' or REMOVE)
            end)
        end

        if useNum>35 then
            sub:SetGridMode(MenuConstants.VerticalGridDirection, math.ceil(useNum/35))
        end
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
    sub:CreateButton(e.onlyChinese and '修改名称' or EQUIPMENT_SET_EDIT:gsub('/.+',''), function()
        StaticPopupDialogs[id..addName..'changeNamme']={
            text=(e.onlyChinese and '修改名称' or EQUIPMENT_SET_EDIT:gsub('/.+',''))..'|n|n'..(e.onlyChinese and '重新加载UI' or RELOADUI ),
            whileDead=true, hideOnEscape=true, exclusive=true,
            hasEditBox=1,
            button1= e.onlyChinese and '确定' or OKAY,
            button2= e.onlyChinese and '取消' or CANCEL,
            OnShow= function(s)
                s.editBox:SetText(e.Player.region==5 and '大脚世界频道' and Save.world or 'World')
                s.button1:SetEnabled(false)
            end,
            OnHide= function(s)
                s.editBox:SetText("")
                e.call('ChatEdit_FocusActiveWindow')
            end,
            OnAccept= function(s)
                Save.world= s.editBox:GetText()
                e.Reload()
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
        StaticPopup_Show(id..addName..'changeNamme')
    end)
    sub:CreateDivider()
end

    local value= Check_Channel(name)
    local col= value==1 and '' or '|cff9e9e9e'
    sub:CreateButton(col..(e.onlyChinese and '屏蔽' or IGNORE), function(data)
        Set_Join(data, nil, nil, true)--加入,移除,屏蔽
        return MenuResponse.Close
    end, name)

    col= value==1 and '|cff9e9e9e' or ''
    sub:CreateButton(col..(e.onlyChinese and '加入' or CHAT_JOIN), function(data)
        Set_Join(data, true)
        return MenuResponse.Close
    end, name)
end












--添加菜单
local function Add_Menu(root, name, channelNumber)
    local text=name
    local clubId=name:match('Community:(%d+)');
    if clubId then
        e.LoadDate({id=clubId, type='club'})
    end
    local communityName, communityTexture
    local clubInfo= clubId and C_Club.GetClubInfo(clubId)--社区名称
    if clubInfo and (clubInfo.shortName or clubInfo.name) then
        text='|cnGREEN_FONT_COLOR:'..(clubInfo.shortName or clubInfo.name)..' |r'
        communityName=clubInfo.shortName or clubInfo.name
        communityTexture=clubInfo.avatarId
    end
    text=((channelNumber and channelNumber>0) and channelNumber..' ' or '')..text--频道数字

    local sub=root:CreateCheckbox(text, function(data)
        return WorldButton.channelNumber == GetChannelName(data.communityName or data.name)

    end, function(data)
        Send_Say(data.name, data.channelNumber)
        Set_LeftClick_Tooltip(--设置点击提示,频道字符
            data.communityName or data.name,
            data.channelNumber,
            data.texture
        )

    end, {
        texture=communityTexture,
        name=name,
        communityName=communityName,
        channelNumber= channelNumber,
    })


    sub:SetTooltip(function(tooltip, description)
        --tooltip:AddDoubleLine('Alt+'..e.Icon.left, e.onlyChinese and '屏蔽' or IGNORE)
        --tooltip:AddLine(' ')
        local value= Check_Channel(description.data.name)
        if value==0 then--不存在
            tooltip:AddLine(Get_Channel_Color(nil, 0)..(e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE))
        elseif value==1 then
            tooltip:AddLine(e.onlyChinese and '已加入' or CLUB_FINDER_JOINED)
        elseif value==2 then--屏蔽
            tooltip:AddLine(Get_Channel_Color(name, 2)..(e.onlyChinese and '已屏蔽' or IGNORED))
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

    WorldButton.leftClickTips=e.Cstr(WorldButton, {size=12, color=true, justifyH='CENTER'})--10, nil, nil, true, nil, 'CENTER')
    WorldButton.leftClickTips:SetPoint('BOTTOM',0,2)

    function WorldButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()

        local find
        find=0
        for _ in pairs(FilterTextTab) do
            find= find+1
        end

        e.tips:AddDoubleLine((e.onlyChinese and '屏蔽刷屏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, IGNORE, CLUB_FINDER_REPORT_SPAM))..' #'..find, e.GetEnabeleDisable(Save.myChatFilter))
        e.tips:AddLine(' ')
        local channels = {GetChannelList()}
        for i = 1, #channels, 3 do
            local channelNumber, name, disabled = channels[i], channels[i+1], channels[i+2]
            if not disabled and channelNumber and name then
                find= (channelNumber and WorldButton.channelNumber==channelNumber) and e.Icon.left or '   '
                local value= Check_Channel(name)
                local col= Get_Channel_Color(name, value)
                e.tips:AddDoubleLine(col..channelNumber..')', col..name..find)
            end
        end
        e.tips:Show()
    end

    WorldButton:SetScript("OnClick",function(self, d)
        if d=='LeftButton' and self.channelNumber and self.channelNumber>0 then
            Send_Say(self.channelName, self.channelNumber)
            --e.Say('/'..self.channelNumber)
            self:set_tooltip()
        else
            MenuUtil.CreateContextMenu(self, Init_Menu)
            e.tips:Hide()
        end
    end)

    WorldButton:SetScript('OnLeave', function(self)
        self:state_leave()
        e.tips:Hide()
    end)
    WorldButton:SetScript('OnEnter', function(self)
        self:state_enter(Init_Menu)
        self:set_tooltip()
    end)

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
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave['ChatButtonWorldChannel'] or Save
            addName= '|A:tokens-WoW-generic-regular:0:0|a'..(e.onlyChinese and '频道' or CHANNEL)
            WorldButton= WoWToolsChatButtonMixin:CreateButton('World', addName)

            if WorldButton then--禁用Chat Button

                Init()
                self:RegisterEvent('PLAYER_ENTERING_WORLD')

            end
            self:UnregisterEvent('ADDON_LOADED')

        end
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButtonWorldChannel']=Save
        end

    elseif event== 'PLAYER_ENTERING_WORLD' then
        FilterTextTab={}--记录, 屏蔽内容

    end
end)
