local P_Save={
    autoClear=true,--进入战斗时,清除数据
    saveLog=WoWTools_DataMixin.Player.husandro,
    save={},--保存数据,最多30个
}

local function Save()
    return WoWToolsSave['ChatButton_Roll'] or {}
end

local addName
local RollButton
local RollTab={}

local panel= CreateFrame('Frame')



--local MaxPlayer, MinPlayer


local Max, Min
local function findRolled(name)--查找是否ROLL过
    for _, tab in pairs(RollTab) do
        if tab.name==name then
            return true
        end
    end
end

local rollText= WoWTools_TextMixin:Magic(RANDOM_ROLL_RESULT)--"%s掷出%d（%d-%d）";

local function setCHAT_MSG_SYSTEM(text)
    if not text then
        return
    end
    local name, roll, minText, maxText=text:match(rollText)
    roll=  roll and tonumber(roll)
    if not (name and roll and minText=='1' and (maxText=='100' or maxText=='1000')) then
        return
    end
    name=name:find('%-') and name or (name..'-'..WoWTools_DataMixin.Player.Realm)
    if not findRolled(name) then
        if not Max or roll>Max then
            if Max then
                Min= (not Min or Min>Max) and Max or Min
            end
            Max=roll
        elseif not Min or Min>roll then
            Min=roll
        end

        RollButton.rightTopText:SetText(Max)

        if Min then
            RollButton.rightBottomText:SetText(Min)
        end
    end

    local faction,guid
    if name==WoWTools_DataMixin.Player.Name_Realm then
        faction= WoWTools_DataMixin.Player.Faction
        guid= WoWTools_DataMixin.Player.GUID
    elseif WoWTools_DataMixin.GroupGuid[name] then
        faction= WoWTools_DataMixin.GroupGuid[name].faction
        guid= WoWTools_DataMixin.GroupGuid[name].guid
    end

    table.insert(RollTab, {name=name,
                        roll=roll,
                        date=date('%X'),
                        text=text,
                        guid= guid,
                        faction= faction,
                    })

    if GameTooltip:IsOwned(RollButton) then
        RollButton:set_tooltip()
    end
end












local function get_Save_Max()--清除时,保存数据
    if not Save().saveLog then
        return
    end

    local maxTab, max= nil, 0
    for _, tab in pairs(RollTab) do
        if tab.roll and tab.roll>max then
            maxTab= tab
            if tab==100 then
                break
            end
        end
    end
    if maxTab then
        if #Save().save>=40 then
            table.remove(Save().save, 1)
        end
        table.insert(Save().save, maxTab)
    end
end

local function setRest()--重置
    get_Save_Max()--清除时,保存数据
    RollTab={}
    Max, Min= nil, nil
    RollButton.rightBottomText:SetText('')
    RollButton.rightTopText:SetText('')
end



local function setAutoClearRegisterEvent()--注册自动清除事件
    if Save().autoClear then
        panel:RegisterEvent('PLAYER_REGEN_DISABLED')
    else
        panel:UnregisterEvent('PLAYER_REGEN_DISABLED')
    end
    RollButton.autoClearTips:SetShown(Save().autoClear)
end

















--#####
--主菜单
--#####

local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub, sub2

    root:SetScrollMode(20*44)

    sub=root:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
    function()
        setRest()--重置
        return MenuResponse.Close
    end, {rightText=#RollTab})
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)
    end)
    WoWTools_MenuMixin:SetRightText(sub)

--1000点
    sub2=sub:CreateCheckbox(
        '1000',
    function()
        return Save().is1000
    end, function()
        Save().is1000= not Save().is1000 and true or nil
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('1-1000')
        tooltip:AddLine('1-100')
    end)
--
    sub2= sub:CreateCheckbox(
        '|A:bags-button-autosort-up:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '自动清除' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SLASH_STOPWATCH_PARAM_STOP2)),
    function ()
        return Save().autoClear
    end, function ()
        Save().autoClear= not Save().autoClear and true or false
        setAutoClearRegisterEvent()--注册自动清除事件
    end)
    sub2:SetTooltip(function (tooltip)
        GameTooltip_SetTitle(tooltip, WoWTools_DataMixin.onlyChinese and '进入战斗时: 清除' or (ENTERING_COMBAT..': '..SLASH_STOPWATCH_PARAM_STOP2))
    end)
--清除记录
    sub2=sub:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '清除记录' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_STOPWATCH_PARAM_STOP2, EVENTTRACE_LOG_HEADER)),
    function()
        Save().save={}
        return MenuResponse.CloseAll
    end, {rightText= #Save().save})
    WoWTools_MenuMixin:SetRightText(sub2)

--不保存
    sub2:CreateCheckbox(
        (WoWTools_DataMixin.onlyChinese and '保存' or SAVE)
        .. ' 40 '
        ..(WoWTools_DataMixin.onlyChinese and '条' or AUCTION_HOUSE_QUANTITY_LABEL),
    function()
        return Save().saveLog
    end, function()
        Save().saveLog= not Save().saveLog and true or nil
        panel:set_event()
    end)

    sub:CreateDivider()
    for index, tab in pairs(Save().save) do
        sub2= sub:CreateButton(
            '|TInterface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47:0|t'
            ..HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(tab.roll)
            ..(tab.roll<10 and '  ' or (tab.roll<100 and ' ') or '')
            ..WoWTools_UnitMixin:GetPlayerInfo(tab.unit, tab.guid, tab.name, {reName=true, reRealm=true})..' '..tab.date,
        function(data)
            WoWTools_ChatMixin:Chat(data.text, nil, nil)
            return MenuResponse.Refresh
        end, {text=tab.text, rightText=index})

        sub2:SetTooltip(function(tooltip, desc)
            tooltip:AddLine(desc.data.text)
            GameTooltip_AddHighlightLine(tooltip, '|A:voicechat-icon-textchat-silenced:0:0|a'..(WoWTools_DataMixin.onlyChinese and '发送信息' or SEND_MESSAGE))
        end)
        WoWTools_MenuMixin:SetRightText(sub2)
    end
    WoWTools_MenuMixin:SetScrollMode(sub)


    root:CreateDivider()
    local _tabNew={}
    for index, tab in pairs(RollTab) do
        local header='|TInterface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47:0|t'
                ..HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(tab.roll)
                ..(tab.roll<10 and '  ' or (tab.roll<100 and ' ') or '')
                ..WoWTools_UnitMixin:GetPlayerInfo(tab.unit, tab.guid, tab.name, {reName=true, reRealm=true})
                ..' '..tab.date
                ..(tab.roll==Max and '|A:auctionhouse-icon-checkmark:0:0|a' or (tab.roll==Min and '|T450905:0|a') or '')

        if not _tabNew[tab.name] then
            _tabNew[tab.name]={
                text=tab.text,
                header= header,
                index=index,
                list={}
            }
        else
            table.insert(_tabNew[tab.name].list, {
                text=tab.text,
                header=header,
            })
        end
    end

    table.sort(_tabNew, function(a, b)
        return a.index< b.index
    end)

    for _, tab in pairs(_tabNew) do
        sub=root:CreateButton(
            tab.header,
        function(data)
            WoWTools_ChatMixin:Chat(data.text, nil, nil)
            return MenuResponse.Open
        end, {text=tab.text, rightText=#tab.list})
        sub:SetTooltip(function(tooltip, desc)
            tooltip:AddLine(desc.data.text)
            GameTooltip_AddHighlightLine(tooltip, '|A:voicechat-icon-textchat-silenced:0:0|a'..(WoWTools_DataMixin.onlyChinese and '发送信息' or SEND_MESSAGE))
        end)
        WoWTools_MenuMixin:SetRightText(sub)

        for i, list in pairs(tab.list) do
            sub2=sub:CreateButton(
                list.header,
            function(data)
                WoWTools_ChatMixin:Chat(data.text, nil, nil)
                return MenuResponse.Open
            end, {text=list.text, rightText=i})
            sub2:SetTooltip(function(tooltip, desc)
                tooltip:AddLine(desc.data.text)
                GameTooltip_AddHighlightLine(tooltip, '|A:voicechat-icon-textchat-silenced:0:0|a'..(WoWTools_DataMixin.onlyChinese and '发送信息' or SEND_MESSAGE))
            end)
            WoWTools_MenuMixin:SetRightText(sub2)
        end
        WoWTools_MenuMixin:SetScrollMode(sub)
    end

    WoWTools_MenuMixin:SetScrollMode(root)

    _tabNew= nil
end

















--####
--初始
--####
local function Init()


    RollButton.texture:SetTexture('Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47')

    RollButton.autoClearTips= RollButton:CreateTexture(nil,'OVERLAY')
    RollButton.autoClearTips:SetPoint('BOTTOMLEFT',4, 4)
    RollButton.autoClearTips:SetSize(12,12)
    RollButton.autoClearTips:SetAtlas('bags-button-autosort-up')

    RollButton.rightBottomText=WoWTools_LabelMixin:Create(RollButton, {color={r=0,g=1,b=0}})
    RollButton.rightBottomText:SetPoint('BOTTOMRIGHT',-2,3)

    RollButton.rightTopText=WoWTools_LabelMixin:Create(RollButton, {color={r=0,g=1,b=0}})
    RollButton.rightTopText:SetPoint('TOPLEFT',2,-3)


    function RollButton:set_tooltip()
        self:set_owner()
        GameTooltip:AddLine(addName..WoWTools_DataMixin.Icon.left..'/roll')
        if #RollTab>0 then
            local _tabNew={}
            for _, tab in pairs(RollTab) do
                if not _tabNew[tab.name] then
                    local icon=tab.roll==Max and '|A:auctionhouse-icon-checkmark:0:0|a' or (tab.roll==Min and '|T450905:0|a') or ''
                    GameTooltip:AddLine(
                        '|TInterface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47:0|t'
                        ..(tab.roll<10 and '  ' or (tab.roll<100 and ' ') or '')
                        ..HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(tab.roll)
                        ..WoWTools_UnitMixin:GetPlayerInfo(tab.unit, tab.guid, tab.name, {reName=true, reRealm=true})
                        ..' '..tab.date..icon)
                    _tabNew[tab.name]=true
                end
            end
            _tabNew= nil
        end
        GameTooltip:Show()
    end

    function RollButton:set_OnMouseDown()
        if Save().is1000 then
            RandomRoll(1, 1000)
        else
            RandomRoll(1, 100)
        end
    end

    RollButton:SetupMenu(Init_Menu)

    setAutoClearRegisterEvent()--注册自动清除事件
end

















function panel:set_event()
    self:UnregisterEvent('PLAYER_LOGOUT')
    if Save().saveLog then
        self:RegisterEvent('PLAYER_LOGOUT')
    end
end



panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['ChatButton_Roll']= WoWToolsSave['ChatButton_Roll'] or P_Save
            P_Save=nil

            addName= '|TInterface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47:0|t'..(WoWTools_DataMixin.onlyChinese and '掷骰' or ROLL)

            RollButton= WoWTools_ChatMixin:CreateButton('Roll', addName)

            if RollButton then
                self:set_event()
                self:RegisterEvent('CHAT_MSG_SYSTEM')
                Init()
            else
                self:SetScript('OnEvent', nil)
            end
            self:UnregisterEvent(event)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not WoWTools_DataMixin.ClearAllSave then
            get_Save_Max()--清除时,保存数据
        end

    elseif event=='CHAT_MSG_SYSTEM' then
        setCHAT_MSG_SYSTEM(arg1)

    elseif event=='PLAYER_REGEN_DISABLED' then
        setRest()--重置
    end
end)