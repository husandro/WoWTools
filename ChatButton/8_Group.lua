
local addName
local P_Save={
    mouseUP=  (WoWTools_DataMixin.Player.Region==1 or WoWTools_DataMixin.Player.Region==3) and 'sum me, pls'
                or WoWTools_DataMixin.Player.Region==5  and '求拉, 谢谢'
                or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC,SUMMON, COMBATLOG_FILTER_STRING_ME),
    mouseDown= WoWTools_DataMixin.Player.Region~=5 and 'inv, thx' or '1' ,
    --type='/raid'
    --text=团队
}

--1US (includes Brazil and Oceania) 2Korea 3Europe (includes Russia) 4Taiwan 5China

local function Save()
    return WoWToolsSave['ChatButtonGroup'] or {}
end

local GroupButton
local roleAtlas={
    TANK='groupfinder-icon-role-large-tank',
    HEALER='groupfinder-icon-role-large-heal',
    DAMAGER='groupfinder-icon-role-large-dps',
    NONE='socialqueuing-icon-group',
}
local SLASH_PARTY1= SLASH_PARTY1
local SLASH_RAID1= SLASH_RAID1
local SLASH_INSTANCE_CHAT1= SLASH_INSTANCE_CHAT1
local SLASH_RAID_WARNING1= SLASH_RAID_WARNING1























local function Set_Type(type, text)--使用,提示
    GroupButton.type= type
    GroupButton.text= text

    if type and text:find('%w') then--处理英文
        text=type:gsub('/','')
    else
        text= text==RAID_WARNING and COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL or text--团队通知->通知
        text= WoWTools_TextMixin:sub(text, 1, 3)
    end

    GroupButton.typeText:SetText(text or '')
end






local function Settings()--队伍信息提示
    local isInGroup= IsInGroup()
    local isInRaid= IsInRaid()
    local isInInstance= IsInInstance()
    local num=GetNumGroupMembers()

    if Save().type and Save().text then
        Set_Type(Save().type, Save().text)

    elseif IsInRaid() then
        Set_Type(SLASH_RAID2, RAID)--使用,提示
    else
        Set_Type(SLASH_PARTY1, HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS)--使用,提示
    end

    local combatRole
    local tab=WoWTools_DataMixin.GroupGuid[WoWTools_DataMixin.Player.GUID]
    if tab then
        combatRole=tab.combatRole
    end

    --队员，数量，提示
    GroupButton.membersText:SetText(isInRaid and num or '')

    if isInGroup then--职责提示
        GroupButton.texture:SetAtlas(roleAtlas[combatRole] or roleAtlas['NONE'])
    else
        GroupButton.texture:SetAtlas('socialqueuing-icon-group')
    end

    --副本外，在团中提示
    GroupButton.textureNotInstance:SetShown(isInRaid and not isInInstance)

    --提示，聊天泡泡，开启/禁用
    GroupButton.tipBubbles:SetShown(not C_CVar.GetCVarBool("chatBubblesParty"))
end

















local function set_Text(text)--处理%s
    local groupTab= WoWTools_DataMixin.GroupGuid[WoWTools_DataMixin.Player.GUID]
    if text:find('%%s') and groupTab and groupTab.subgroup then
        text= text:format(groupTab.subgroup..' '..GROUP..' ')
    else
        text= text:gsub('%%s','')
    end
    return text
end






















--主菜单
local function Init_Menu(self, root)
    if not self:IsVisible() then
        return
    end

    local sub, sub2, col, playerName
    local isInGroup= IsInGroup()
    local isInRaid= IsInRaid()
    local isInInstance= IsInInstance()
    local num=GetNumGroupMembers()
    local le=UnitIsGroupAssistant('player') or  UnitIsGroupLeader('player')
    local isInBat= UnitAffectingCombat('player')

    local chatType={
        {text= WoWTools_DataMixin.onlyChinese and '队伍' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS, type=SLASH_PARTY1, type2='SLASH_PARTY'},--/p
        {text= WoWTools_DataMixin.onlyChinese and '团队' or RAID, type=SLASH_RAID1, type2='SLASH_RAID'},--/raid
        {text= WoWTools_DataMixin.onlyChinese and '副本' or INSTANCE, type=SLASH_INSTANCE_CHAT1, type2='SLASH_INSTANCE_CHAT'},--/i
        {text= WoWTools_DataMixin.onlyChinese and '团队通知' or RAID_WARNING, type= SLASH_RAID_WARNING1, type2='SLASH_RAID_WARNING'},--/rw
    }

    for index, tab in pairs(chatType) do
        col=''
        if index==1 and not isInGroup
            or (index==2 and not isInRaid)--设置颜色
            or (index==3 and (not isInInstance or num<2 ))
            or (index==4 and (not isInRaid or not le))
        then
            col='|cff9e9e9e'
        end

        sub=root:CreateCheckbox(col..tab.text..' '..tab.type, function(data)
            return GroupButton.type==data.type

        end, function(data)
            WoWTools_ChatMixin:Say(data.type)
            Save().type=data.type
            Save().text=data.text
            Settings()

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


        if isInGroup then
            local unit
            if index==1 then
--队伍，子目录
                for i=1, GetNumGroupMembers()-1, 1 do
                    unit='party'..i
                    if UnitExists(unit) and UnitIsPlayer(unit) then
                        playerName=GetUnitName(unit, true)
                        sub2= sub:CreateButton(WoWTools_UnitMixin:GetPlayerInfo({unit=unit, reName=true, reRealm=true}), function(data)
                            if data and data~=WoWTools_DataMixin.Player.Name then
                                WoWTools_ChatMixin:Say(nil, data, nil)
                            end
                            return MenuResponse.Open
                        end, playerName)
                        sub2:SetTooltip(function(tooltip)
                            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER)
                        end)
                    end
                end

            elseif index==2 and isInRaid then
                for i=1, MAX_RAID_MEMBERS,  1 do
                    unit='raid'..i
                   if UnitExists(unit) and not UnitIsUnit(unit, 'player') and UnitIsPlayer(unit) then
                        sub2=sub:CreateButton(
                            WoWTools_UnitMixin:GetPlayerInfo({unit=unit, reName=true, reRealm=true}),
                        function(data)
                            if data and data~=WoWTools_DataMixin.Player.Name then
                                WoWTools_ChatMixin:Say(nil, data, nil)
                            end
                            return MenuResponse.Open
                        end, playerName)
                        sub2:SetTooltip(function(tooltip, description)
                            if description.data and description.data~=WoWTools_DataMixin.Player.Name then
                                tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER)
                            end
                        end)
                    end
                end
                sub:SetGridMode(MenuConstants.VerticalGridDirection, 4)
            end
        end
    end


--跨阵营
    root:CreateDivider()

    local crossNum=0
    local isCrossFactionParty = C_PartyInfo.IsCrossFactionParty()
    if isCrossFactionParty then
        for _, unit in pairs(WoWTools_UnitMixin:GetGroupMembers(false)) do--取得，队员, unit
            if UnitRealmRelationship(unit)==LE_REALM_RELATION_COALESCED then
                crossNum= crossNum+1
            end
        end
    end

    sub=root:CreateTitle(
        (WoWTools_DataMixin.onlyChinese and '跨阵营' or COMMUNITIES_EDIT_DIALOG_CROSS_FACTION)
        ..': '
        ..(
            isInGroup and WoWTools_TextMixin:GetYesNo(C_PartyInfo.IsCrossFactionParty())
            or (C_PartyInfo.CanFormCrossFactionParties() and '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '可创建' or BATTLETAG_CREATE)..'|r')
            or ('|cff9e9e9e'..(WoWTools_DataMixin.onlyChinese and '无' or NONE)..'|r')
        ).. ' #'..crossNum)

    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '跨阵营' or COMMUNITIES_EDIT_DIALOG_CROSS_FACTION)
        tooltip:AddLine(' ')
        tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '创建跨阵营队伍' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMMUNITIES_EDIT_DIALOG_CROSS_FACTION, START_A_GROUP),  WoWTools_TextMixin:GetEnabeleDisable(C_PartyInfo.CanFormCrossFactionParties()))
        local col2= IsInGroup() and '' or '|cff9e9e9e'
        tooltip:AddDoubleLine(
            col2..(WoWTools_DataMixin.onlyChinese and '跨阵营队伍' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMMUNITIES_EDIT_DIALOG_CROSS_FACTION, HUD_EDIT_MODE_SETTING_UNIT_FRAME_SORT_BY_SETTING_GROUP)),
            col2..WoWTools_TextMixin:GetYesNo(isCrossFactionParty)..' #'..crossNum..' '..(WoWTools_DataMixin.onlyChinese and '队员' or PLAYERS_IN_GROUP)
        )
    end)




--组队聊天泡泡
    root:CreateDivider()
    sub=root:CreateCheckbox((isInBat and '|cff9e9e9e' or '')..(WoWTools_DataMixin.onlyChinese and '组队聊天泡泡' or PARTY_CHAT_BUBBLES_TEXT), function()
        return C_CVar.GetCVarBool("chatBubblesParty")
    end, function()
        if not InCombatLockdown() then
            C_CVar.SetCVar("chatBubblesParty", C_CVar.GetCVarBool("chatBubblesParty") and '0' or '1')
            print(WoWTools_DataMixin.Icon.icon2.. addName, WoWTools_DataMixin.onlyChinese and '组队聊天泡泡' or PARTY_CHAT_BUBBLES_TEXT, WoWTools_TextMixin:GetEnabeleDisable(C_CVar.GetCVarBool("chatBubblesParty")))
        else
            print(WoWTools_DataMixin.Icon.icon2.. addName, WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        end
    end)

    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('C_CVar.SetCVar(\"chatBubblesParty\")')
    end)


    sub=root:CreateButton(
        (Save().mouseUP and '|A:bags-greenarrow:0:0|a' or '')
        ..(Save().mouseDown and '|A:UI-HUD-MicroMenu-StreamDLRed-Up:0:0|a' or '')
        ..(not Save().mouseUP and not Save().mouseDown and '|cff9e9e9e' or '')
        ..(WoWTools_DataMixin.onlyChinese and '自定义' or CUSTOM)..'|A:voicechat-icon-textchat-silenced:0:0|a',
    function()
        return MenuResponse.Refresh
    end)


    local tab2={
        {type= 'mouseUP', text= WoWTools_DataMixin.onlyChinese and '鼠标滚轮向上滚动' or KEY_MOUSEWHEELUP, icon= 'bags-greenarrow'},
        {type= 'mouseDown', text= WoWTools_DataMixin.onlyChinese and '鼠标滚轮向下滚动' or KEY_MOUSEWHEELDOWN, icon= 'UI-HUD-MicroMenu-StreamDLRed-Up'},
    }
    for _, tab in pairs(tab2) do
        local text=Save()[tab.type]
        if text then
            text= set_Text(text)--处理%s
        else
            text= tab.text
        end
        text= format('|A:%s:0:0|a%s', tab.icon, text)

        sub:CreateCheckbox(
            text,
        function(data)
            return Save()[data.type]

        end, function(data)
            StaticPopupDialogs['WoWTools_ChatButton_Group_CUSTOM']={--区域,设置对话框
                text=addName
                    ..'|n|n'..(WoWTools_DataMixin.onlyChinese and '自定义发送信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CUSTOM, SEND_MESSAGE))
                    ..'|n|n|cnGREEN_FONT_COLOR:'..format('|A:%s:0:0|a', data.icon)..data.text..'|r|n|n'
                    ..(WoWTools_DataMixin.onlyChinese and '队伍' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS),
                whileDead=true, hideOnEscape=true, exclusive=true,
                hasEditBox=true,
                button1= WoWTools_DataMixin.onlyChinese and '修改' or EDIT,
                button2= WoWTools_DataMixin.onlyChinese and '取消' or CANCEL,
                button3= WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE,
                OnShow = function(f)
                    local edit= f.editBox or f:GetEditBox()
                    if Save()[data.type] then
                        edit:SetText(Save()[data.type])
                    else
                        if data.type=='mouseUP' then
                            edit:SetText(WoWTools_DataMixin.Player.Region==5 and '求拉, 谢谢' or 'sum me, pls')
                        else
                            edit:SetText(WoWTools_DataMixin.Player.Region==5 and '1' or 'inv, thx')
                        end
                        local b3= f.button3 or f:GetButton3()
                        b3:SetEnabled(false)
                    end
                    edit:SetWidth(f:GetWidth())
                end,
                OnHide=function(f)
                    local edit= f.editBox or f:GetEditBox()
                    edit:ClearFocus()
                end,
                OnAccept = function(f)
                    local edit= f.editBox or f:GetEditBox()
                    local text2= edit:GetText()
                    if text2:gsub(' ','')=='' then
                        Save()[data.type]=nil
                    else
                        Save()[data.type]=text2
                    end
                end,
                OnAlt = function()
                    Save()[data.type]=nil
                end,
                EditBoxOnTextChanged=function(f)
                    local text2= f:GetText()
                    local p=f:GetParent()
                    local b1= p.button1 or p:GetButton1()
                    if text2:gsub(' ','')=='' then
                        b1:SetText(WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE)
                    else
                        b1:SetText(WoWTools_DataMixin.onlyChinese and '修改' or EDIT)
                    end
                end,
                EditBoxOnEscapePressed = function(s)
                    s:GetParent():Hide()
                end,
            }
            StaticPopup_Show('WoWTools_ChatButton_Group_CUSTOM')
        end, tab)
    end
end




















local function show_Group_Info_Toolstip()--玩家,信息, 提示
    local raid= IsInRaid()
    local co= raid and MAX_RAID_MEMBERS or GetNumGroupMembers()
    if not IsInGroup() or co<2 then
        return
    end
    local playerNum=0

    local UnitTab={}--取得装等

    local u= raid and 'raid' or 'party'
    local tabT, tabN, tabDPS, totaleHP = {}, {}, {}, 0
    local uiMapID= select(2, WoWTools_MapMixin:GetUnit('player'))

    local unit, info
    for i=1, co do
        unit=u..i

        info={}

        if not raid and i==co then
            unit='player'
        end

        local guid= UnitGUID(unit)
        if guid and UnitExists(unit) then
            playerNum= playerNum+1

            if (not WoWTools_DataMixin.UnitItemLevel[guid] or not WoWTools_DataMixin.UnitItemLevel[guid].itemLeve) then
                table.insert(UnitTab, unit)
            end

            local maxHP= UnitHealthMax(unit)
            local role
            if raid then
                local role2,_, combatRole= select(10, GetRaidRosterInfo(i))
                role= role2 or combatRole
                role= role== 'MAINTANK' and 'TANK' or role
            else
                role= UnitGroupRolesAssigned(unit)
            end

            if maxHP and role then
                if UnitIsPlayer(unit) then
                    info.name= (WoWTools_UnitMixin:GetOnlineInfo(unit) or '')
                        ..WoWTools_UnitMixin:GetPlayerInfo({unit=unit, guid=guid, reName=true, reRealm=true})
                        ..(WoWTools_DataMixin.UnitItemLevel[guid] and WoWTools_DataMixin.UnitItemLevel[guid].itemLeve or '')
                else
                    info.name= UnitName(unit)
                    local classFilename= UnitClassBase(unit)
                    local hex= classFilename and select(4, GetClassColor(classFilename))
                    if hex then
                        info.name= '|c'..hex..info.name..'|r'
                    end
                end

                info.maxHP= maxHP

                info.col= select(5, WoWTools_UnitMixin:GetColor(unit, nil))
                if uiMapID then--不在同地图
                    local text, mapID=WoWTools_MapMixin:GetUnit(unit)
                    if text and mapID and mapID~=uiMapID then
                        info.name= info.name..'|A:poi-islands-table:0:0|a|cnRED_FONT_COLOR:'..text..'|r'
                    end
                end

                if role=='TANK' then
                    table.insert(tabT, info)
                elseif role=='HEALER' then
                    table.insert(tabN, info)
                elseif role=='DAMAGER' then
                    table.insert(tabDPS, info)
                end

                totaleHP= totaleHP+ maxHP
            end
        end
    end

    if totaleHP==0 then
        return
    end

    table.sort(tabT, function(a, b) if a and b then  return a.maxHP> b.maxHP end return false end)
    table.sort(tabN, function(a, b) if a and b then  return a.maxHP> b.maxHP end return false end)
    table.sort(tabDPS, function(a, b) if a and b then  return a.maxHP> b.maxHP end return false end)

    --[[GameTooltip:SetOwner(GroupButton, "ANCHOR_LEFT")
    GameTooltip:ClearLines()]]
    GameTooltip:AddDoubleLine(format(WoWTools_DataMixin.onlyChinese and '%s玩家' or COMMUNITIES_CROSS_FACTION_BUTTON_TOOLTIP_TITLE, playerNum), WoWTools_Mixin:MK(totaleHP,3))
    if playerNum>0 then
        GameTooltip:AddLine(' ')
    end
    local find
    for _, info in pairs(tabT) do
        GameTooltip:AddDoubleLine(info.name, info.col..WoWTools_Mixin:MK(info.maxHP, 3)..INLINE_TANK_ICON)
        find=true
    end
    if find then
        GameTooltip:AddLine(' ')
        find=nil
    end
    for _, info in pairs(tabN) do
        GameTooltip:AddDoubleLine(info.name, info.col..WoWTools_Mixin:MK(info.maxHP, 3)..INLINE_HEALER_ICON)
        find=true
    end
    if find then
        GameTooltip:AddLine(' ')
        find=nil
    end
    for _, info in pairs(tabDPS) do
        GameTooltip:AddDoubleLine(info.name, info.col..WoWTools_Mixin:MK(info.maxHP, 3)..INLINE_DAMAGER_ICON)
        find= true
    end
    if find then
        GameTooltip:AddLine(' ')
    end

    --GameTooltip:Show()

    WoWTools_UnitMixin:GetNotifyInspect(UnitTab)--取得装等
    return find
end




















--####
--初始
--####
local function Init()
    --使用,提示
    GroupButton.typeText=WoWTools_LabelMixin:Create(GroupButton,{color=true})
    GroupButton.typeText:SetPoint('BOTTOM',0,2)

    --队员，数量，提示
    GroupButton.membersText=WoWTools_LabelMixin:Create(GroupButton, {color=true})--10, nil, nil, true)
    GroupButton.membersText:SetPoint('TOPRIGHT', -3, 0)

    GroupButton.tipBubbles= GroupButton:CreateTexture(nil, 'OVERLAY')
    GroupButton.tipBubbles:SetSize(8, 8)
    GroupButton.tipBubbles:SetPoint('TOPLEFT', 3, 0)
    GroupButton.tipBubbles:SetAtlas('talents-button-reset')

    --副本外，在团中提示
    GroupButton.textureNotInstance=GroupButton:CreateTexture(nil,'BACKGROUND')
    GroupButton.textureNotInstance:SetAllPoints(GroupButton)
    GroupButton.textureNotInstance:SetAtlas('socket-punchcard-red-background')

    function GroupButton:set_tooltip()
        self:set_owner()

        local find= show_Group_Info_Toolstip()--玩家,信息, 提示

        if find then
            GameTooltip:AddLine(' ')
        end

        GameTooltip:AddDoubleLine(
            self.text,
            self.type and self.type..WoWTools_DataMixin.Icon.left
        )

        local down, up= Save().mouseDown, Save().mouseUP
        if down or up then
            GameTooltip:AddLine(' ')
        end
        if up then
            GameTooltip:AddLine(
                WoWTools_DataMixin.Icon.mid
                ..'|A:bags-greenarrow:0:0|a'
                ..up
                ..'|A:voicechat-icon-textchat-silenced:0:0|a',
                nil,nil,nil, true
            )
        end
        if down then
            GameTooltip:AddLine(
                WoWTools_DataMixin.Icon.mid
                ..'|A:UI-HUD-MicroMenu-StreamDLRed-Up:0:0|a'
                ..down
                ..'|A:voicechat-icon-textchat-silenced:0:0|a',
                nil,nil,nil, true
            )
        end
        GameTooltip:Show()
    end


    GroupButton:SetupMenu(Init_Menu)

    function GroupButton:set_OnMouseDown()
        if self.type then
            WoWTools_ChatMixin:Say(self.type)
        else
            return true
        end
    end
    --[[GroupButton:SetScript('OnMouseDown',function(self, d)
        if d=='LeftButton' and self.type then
            WoWTools_ChatMixin:Say(self.type)
            self:CloseMenu()
            self:set_tooltip()
        end
    end)

    GroupButton:SetScript('OnClick', function(self, d)
        if d=='LeftButton' and self.type then
            WoWTools_ChatMixin:Say(self.type)
        else
            MenuUtil.CreateContextMenu(self, function(...)
            Init_Menu(...)
        end)
            GameTooltip:Hide()
        end
    end)]]

    GroupButton:SetScript('OnMouseWheel', function(_, d)--发送自定义信息
        local text
        if d==1 then
            text= Save().mouseUP
        elseif d==-1 then
            text= Save().mouseDown
        end
        if text then
            text=set_Text(text)--处理%s
            if IsInRaid() then
                SendChatMessage(text, 'RAID')
            elseif IsInGroup() then
                SendChatMessage(text, 'PARTY')
            else
                WoWTools_ChatMixin:Chat(text, nil, nil)
            end
        end
    end)


    --[[GroupButton:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:state_leave()
    end)
    GroupButton:SetScript('OnEnter', function(self)
        self:set_tooltip()
        self:state_enter()--Init_Menu)
    end)]]

    C_Timer.After(0.3, Settings)--队伍信息提示
end





















--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('GROUP_LEFT')
panel:RegisterEvent('GROUP_ROSTER_UPDATE')
panel:RegisterEvent('CVAR_UPDATE')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['ChatButtonGroup']= WoWToolsSave['ChatButtonGroup'] or P_Save
            addName= '|A:socialqueuing-icon-group:0:0:|a'..(WoWTools_DataMixin.onlyChinese and '队伍' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_SORT_BY_SETTING_GROUP)
            GroupButton= WoWTools_ChatMixin:CreateButton('Group', addName)

            if GroupButton then--禁用 ChatButton
                Init()
                self:UnregisterEvent(event)
            else
                self:UnregisterAllEvents()
            end
        end

    elseif event=='GROUP_ROSTER_UPDATE' or event=='GROUP_LEFT' then
        C_Timer.After(0.3, Settings)--队伍信息提示

    elseif event=='CVAR_UPDATE' then
        if arg1=='chatBubblesParty' then
            Settings()--提示，聊天泡泡，开启/禁用
        end
    end
end)