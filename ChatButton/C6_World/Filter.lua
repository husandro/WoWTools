--屏蔽内容
local function Save()
    return WoWToolsSave['ChatButtonWorldChannel']
end

local FilterTextTab={}--记录, 屏蔽内容
--[[
[text]={
    num=1,
    guid={
        [guid]=name
    }
},
]]







--全部屏蔽, 现有列表
local function Set_Add_All_Player_Filter()
    local index= 0
    for _, tab in pairs(FilterTextTab) do
        for guid, name in pairs(tab.guid or {}) do
            if not Save().myChatFilterPlayers[guid] then
                Save().myChatFilterPlayers[guid]= 1
                index= index+1
                print(
                    WoWTools_WorldMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    WoWTools_DataMixin.onlyChinese and '屏蔽' or IGNORE,
                    '|cff626262'..index..'|r',
                    WoWTools_UnitMixin:GetPlayerInfo(nil, guid, name, {reLink=true, reName=true, reRealm=true})
                )
            end
        end
    end
    FilterTextTab={}
end








--屏蔽刷屏, 菜单
local function Init_Filter_Menu(self, root)
    local sub, sub2, sub3

    local filterNum= CountTable(FilterTextTab or {})

    local filterPlayer= CountTable(Save().myChatFilterPlayers or {})



--屏蔽刷屏
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '屏蔽刷屏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, IGNORE, CLUB_FINDER_REPORT_SPAM),

    function()
        return Save().myChatFilter

    end, function()
        Save().myChatFilter= not Save().myChatFilter and true or false
        WoWTools_WorldMixin:Set_Filters()
        return MenuResponse.Close
    end, {rightText=Save().myChatFilterAutoAdd and filterPlayer or filterNum})

    WoWTools_MenuMixin:SetRightText(sub)

    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('CHAT_MSG_CHANNEL')
        tooltip:AddLine(self:Get_myChatFilter_Text())
        tooltip:AddLine(' ')
        local all=0
        for _, num in pairs(Save().myChatFilterPlayers) do
            all= all+ num
        end
        tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '总计' or TOTAL, WoWTools_DataMixin:MK(all, 3).. ' '..(WoWTools_DataMixin.onlyChinese and "次" or VOICEMACRO_LABEL_CHARGE1))
    end)



--设置, 屏蔽刷屏, 数量
    sub2=sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS,
        --..' |cnGREEN_FONT_COLOR:'
        --..Save().myChatFilterNum,
    function()
        StaticPopup_Show('WoWToolsChatButtonWorldMyChatFilterNum')
    end, {rightText='|cnGREEN_FONT_COLOR:'..Save().myChatFilterNum})

    WoWTools_MenuMixin:SetRightText(sub2)

    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(self:Get_myChatFilter_Text())
    end)







--已经 屏蔽玩家 列表
    sub2=sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '屏蔽玩家' or IGNORE_PLAYER,--..' #'..filterPlayer,
    function()
        return MenuResponse.Refresh
    end, {rightText=filterPlayer})
    WoWTools_MenuMixin:SetRightText(sub2)

--全部清除
    sub3=sub2:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
        --..' #'..filterPlayer,
    function()
        StaticPopup_Show('WoWTools_OK',
            (WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)
            ..'|n|n|cffffffff#'..filterPlayer,
        nil,
        {SetValue=function()
            Save().myChatFilterPlayers={}
        end})
    end, {rightText=filterPlayer})
    WoWTools_MenuMixin:SetRightText(sub3)

        sub2:CreateDivider()

--玩家，列表
        local index=0
        for guid, num in pairs(Save().myChatFilterPlayers) do
            index= index+1
            local name= WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil,{reName=true, reRealm=true})
            name= name=='' and guid or name

            sub3=sub2:CreateButton(
                '|cff626262'..index..')|r '..name,--..' |cff626262#'.. WoWTools_DataMixin:MK(num, 3)..'|r',
            function(data)
                local player= WoWTools_UnitMixin:GetPlayerInfo(nil, data.guid, nil, {reName=true, reRealm=true, reLink=true})
                if Save().myChatFilterPlayers[data.guid] then
                    print(
                        WoWTools_WorldMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '移除' or REMOVE)..'|r',
                        player
                    )
                else
                    print(
                        WoWTools_WorldMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        '|cff626262'..(WoWTools_DataMixin.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE)..'|r',
                        player
                    )
                end
                Save().myChatFilterPlayers[data.guid]=nil
                return MenuResponse.Open
            end, {guid=guid, num=num, rightText= '|cff626262'..WoWTools_DataMixin:MK(num, 3)..'|r'})

            WoWTools_MenuMixin:SetRightText(sub3)

            sub3:SetTooltip(function(tooltip, description)
                tooltip:AddLine((WoWTools_DataMixin.onlyChinese and '刷屏' or REPORTING_MINOR_CATEGORY_SPAM)..' #'..description.data.num)
                tooltip:AddLine(' ')
                if Save().myChatFilterPlayers[description.data.guid] then
                    tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '移除' or REMOVE)
                else
                    tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE)
                end
            end)

            local name2, realmName = select(6, GetPlayerInfoByGUID(guid))
            if name2 and realmName then
                realmName= realmName =='' and WoWTools_DataMixin.Player.Realm or realmName
                sub3:CreateButton(WoWTools_DataMixin.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER, function(data)
                    WoWTools_ChatMixin:Say(nil, data)
                    return MenuResponse.Open
                end, name2..'-'..realmName)
            end
        end

        WoWTools_MenuMixin:SetScrollMode(sub2)







--自动添加
    sub:CreateCheckbox((WoWTools_DataMixin.onlyChinese and '自动添加' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, ADD)), function()
        return Save().myChatFilterAutoAdd
    end, function()
        Save().myChatFilterAutoAdd= not Save().myChatFilterAutoAdd and true or nil
        if Save().myChatFilterAutoAdd then
            Set_Add_All_Player_Filter()--全部屏蔽, 现有列表
        end
        return MenuResponse.CloseAll
    end)



    sub:CreateDivider()

--全部加入, 临时屏蔽
    sub2=sub:CreateButton(
        '|A:GreenCross:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '全部添加' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ALL, ADD)),
        --..' #'..filterNum,
    function()
        Set_Add_All_Player_Filter()
    end, {rightText=filterNum})
    WoWTools_MenuMixin:SetRightText(sub2)


--全部清除, 临时屏蔽
    sub2=sub:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
        --..' #'..filterNum,
    function()
        FilterTextTab={}
    end, {rightText=filterNum})
     WoWTools_MenuMixin:SetRightText(sub2)






--临时屏蔽，列表
    index=0
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

        sub2=sub:CreateButton('|cff626262'..index..')|r '..(playerName or text).. ' |cff626262'..strlenutf8(text)..'|r', function(data)
            WoWTools_ChatMixin:Say(nil, data.name)
            return MenuResponse.Refresh
        end, {data=tab, text=text, name=playerName2})
        sub2:SetTooltip(function(tooltip, description)
            for guid in pairs(description.data.data.guid or {}) do
                tooltip:AddDoubleLine(WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {reName=true, reRealm=true}), ' ')
            end
            --tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '屏蔽玩家' or IGNORE_PLAYER, WoWTools_DataMixin.Icon.left)                
            tooltip:AddDoubleLine(
                '|cnGREEN_FONT_COLOR:'..strlenutf8(description.data.text)..(WoWTools_DataMixin.onlyChinese and '字符' or 'Word count'),
                '|cnGREEN_FONT_COLOR:#'..(description.data.data.num or 0)..(WoWTools_DataMixin.onlyChinese and "次" or VOICEMACRO_LABEL_CHARGE1)
            )
            tooltip:AddLine(' ')
            tooltip:AddLine(description.data.text, nil, nil,nil, true)
        end)



--显示, 内容
        sub2:CreateButton(
            WoWTools_DataMixin.onlyChinese and '显示' or SHOW,
        function(data)
            local _list={}
            for guid, name in pairs(data.guid or {}) do
                local player= WoWTools_UnitMixin:GetPlayerInfo(nil, guid, name, {reName=true, reRealm=true})
                if player then
                    table.insert(_list, player)
                end
            end
            table.insert(_list, data.text)
            WoWTools_TextMixin:ShowText(_list, data.text)
            return MenuResponse.Open
        end, {text=text, guid=tab.guid, playerName=playerName})

        if type(playerName2)=='string' then
            sub2:CreateButton((WoWTools_DataMixin.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER)..WoWTools_DataMixin.Icon.left, function(data)
                WoWTools_ChatMixin:Say(nil, data)
                return MenuResponse.Open
            end, playerName2)
        end

--屏蔽
        sub2:CreateDivider()
        sub2:CreateButton(WoWTools_DataMixin.onlyChinese and '屏蔽' or IGNORE, function(data)
            for guid, name in pairs(data.guid or {}) do
                local player= WoWTools_UnitMixin:GetPlayerInfo(nil, guid, name, {reLink=true, reName=true, reRealm=true})
                if Save().myChatFilterPlayers[guid] then
                    print(
                        WoWTools_WorldMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        player
                    )
                else
                    Save().myChatFilterPlayers[guid]= 1
                    print(
                        WoWTools_WorldMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '屏蔽' or IGNORE)..'|r',
                        player
                    )
                end
            end
            FilterTextTab[data.text]= nil
            return MenuResponse.Close
        end, {text=text, guid=tab.guid})
    end


    WoWTools_MenuMixin:SetScrollMode(sub)
end



















--屏蔽刷屏, 自定义，菜单
local function Init_User_Filter_Menu(_, root)
    local sub, sub2

    local useNum, all= 0, 0
    for _, info in pairs(Save().userChatFilterTab) do
        useNum= useNum+1
        all= all+ (info.num or 0)
    end

    sub= root:CreateCheckbox(
        (WoWTools_DataMixin.onlyChinese and '自定义屏蔽' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CUSTOM, IGNORE)),
        --.. ' '.. useNum,
    function()
        return Save().userChatFilter
    end, function()
        Save().userChatFilter= not Save().userChatFilter and true or false
        WoWTools_WorldMixin:Set_Filters()
    end, {all=all, rightText=useNum})

    WoWTools_MenuMixin:SetRightText(sub)

    sub:SetTooltip(function(tooltip, desc)
        tooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '总计' or TOTAL,
            WoWTools_DataMixin:MK(desc.data.all, 3)
            .. ' '..(WoWTools_DataMixin.onlyChinese and "次" or VOICEMACRO_LABEL_CHARGE1)
        )
    end)



    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '添加' or ADD,
    function()
        StaticPopup_Show('WoWToolsChatWolrdAddPlayerNameChatFilter')
    end)



    if useNum>0 then

    --全部清除, 自定义屏蔽
        sub2=sub:CreateButton(
            '|A:bags-button-autosort-up:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
            --..' #'..useNum,
        function()
            StaticPopup_Show('WoWTools_OK',
            WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
            nil,
            {SetValue=function()
                Save().userChatFilterTab={}
            end})
        end, {rightText=useNum})
        WoWTools_MenuMixin:SetRightText(sub2)

        sub:CreateDivider()
        local player
        for name, tab in pairs(Save().userChatFilterTab) do
            player= WoWTools_UnitMixin:GetPlayerInfo(nil, tab.guid, name, {reName=true, reRealm=true})
            player= (not player or player=='') and name or player

            sub2=sub:CreateCheckbox(
                player..' '..(WoWTools_DataMixin:MK(tab.num, 3) or ''),
            function(data)
                return Save().userChatFilterTab[data.name]
            end, function(data)
                Save().userChatFilterTab[data.name]= not Save().userChatFilterTab[data.name] and data.tab or nil
            end, {name=name, tab=tab})

            sub2:SetTooltip(function(tooltip)
                tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '移除' or REMOVE)
            end)
        end
        WoWTools_MenuMixin:SetScrollMode(sub)
    end
end




















local function WoWTools_Word_Filters(_, _, msg, name, _, _, _, _, _, _, _, _, _, guid)
    if Save().userChatFilter and Save().userChatFilterTab[name] then
        Save().userChatFilterTab[name]= {
                num= Save().userChatFilterTab[name].num +1,
                guid= guid,
        }
        return true

    elseif Save().myChatFilter and guid then
        if Save().myChatFilterPlayers[guid] then--屏蔽，玩家
            Save().myChatFilterPlayers[guid]= Save().myChatFilterPlayers[guid]+1
            return true

        elseif FilterTextTab[msg] then
            FilterTextTab[msg].guid[guid]= name
            FilterTextTab[msg].num= FilterTextTab[msg].num +1
            return true

        elseif not guid
            or guid== WoWTools_DataMixin.Player.GUID
            or WoWTools_UnitMixin:GetIsFriendIcon(nil, guid, name)
            or WoWTools_DataMixin.GroupGuid[name]
        then--自已, 好友
            return false

        elseif strlenutf8(msg)>Save().myChatFilterNum or msg:find('WTS') then-- msg:find('<.->') or  then
            if Save().myChatFilterAutoAdd then
                Save().myChatFilterPlayers[guid]= 1
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












local function Init()
    EventRegistry:RegisterFrameEventAndCallback('PLAYER_ENTERING_WORLD', function(owner, arg1)
        FilterTextTab={}--记录, 屏蔽内容
    end)

    Init=function()end
end




function WoWTools_WorldMixin:Set_Filters()
    if Save().myChatFilter or Save().userChatFilter then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", WoWTools_Word_Filters)
    else
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_CHANNEL", WoWTools_Word_Filters)
    end

    Init()
end



function WoWTools_WorldMixin:Init_Filter_Menu(root)
    Init_Filter_Menu(WoWTools_ChatMixin:GetButtonForName('World'), root)--屏蔽刷屏, 菜单
    Init_User_Filter_Menu(nil, root)--屏蔽刷屏, 自定义，菜单
end


function WoWTools_WorldMixin:Get_FilterTextTab()
    return FilterTextTab
end