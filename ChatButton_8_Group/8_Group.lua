
local addName
local P_Save={
    --type='/raid'
    --text=团队
}
    --[[mouseUP=  (WoWTools_DataMixin.Player.Region==1 or WoWTools_DataMixin.Player.Region==3) and 'sum me, pls'
                or WoWTools_DataMixin.Player.Region==5  and '求拉, 谢谢'
                or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC,SUMMON, COMBATLOG_FILTER_STRING_ME),
    mouseDown= WoWTools_DataMixin.Player.Region~=5 and 'inv, thx' or '1' ,
 
}]]

--1US (includes Brazil and Oceania) 2Korea 3Europe (includes Russia) 4Taiwan 5China

local function Save()
    return WoWToolsSave['ChatButtonGroup']
end

local GroupButton
local roleAtlas={
    TANK='groupfinder-icon-role-large-tank',
    HEALER='groupfinder-icon-role-large-heal',
    DAMAGER='groupfinder-icon-role-large-dps',
    NONE='socialqueuing-icon-group',
}


local ClickType= 'p'-- p r rw i
local ChatTypeTabs={}





















local function Settings()--队伍信息提示
    local isInRaid= IsInRaid()
    local isInInstance= IsInInstance()

    if not ClickType then
        if isInRaid then
            if UnitIsGroupLeader('player') then
               ClickType= 'w'
            else
                ClickType= 'r'
            end
        else
            ClickType= 'p'
        end
    end

--使用,提示
    GroupButton.typeText:SetText(
        WoWTools_DataMixin.onlyChinese and ChatTypeTabs[ClickType].cn
        or ClickType
        or ''
    )

    local combatRole
    local tab=WoWTools_DataMixin.GroupGuid[WoWTools_DataMixin.Player.GUID]
    if tab then
        combatRole=tab.combatRole
    end

--队员，数量，提示
    GroupButton.membersText:SetText(isInRaid and GetNumGroupMembers() or '')

--职责提示
    if IsInGroup() then
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












local function Set_OnMouseWheel(d)
    local text
    if d==1 then
        text= WoWToolsPlayerDate['GroupMouseUpText']
    elseif d==-1 then
        text= WoWToolsPlayerDate['GroupMouseDownText']
    end

    if not text then
        return
    end

    text= set_Text(text)--处理%s

    if IsInRaid() then
        C_ChatInfo.SendChatMessage(text, 'RAID')
    elseif IsInGroup() then
        C_ChatInfo.SendChatMessage(text, 'PARTY')
    else
        WoWTools_ChatMixin:Chat(text, nil, nil)
    end
end
















--主菜单
local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub, col
    local isInGroup= IsInGroup()
    local isInRaid= IsInRaid()
    local isInInstance= IsInInstance()
    local num=GetNumGroupMembers()
    local le=UnitIsGroupAssistant('player') or  UnitIsGroupLeader('player')
    local isInBat= UnitAffectingCombat('player')

    for index, text in pairs({
        'p',--/p
        'r',--/raid
        'i',--/i
        'w',
    }) do
        col=''
        if index==1 and not isInGroup
            or (index==2 and not isInRaid)--设置颜色
            or (index==3 and (not isInInstance or num<2 ))
            or (index==4 and (not isInRaid or not le))
        then
            col='|cff9e9e9e'
        end
        local chatType= _G[ChatTypeTabs[text].type2..'1']
        sub=root:CreateCheckbox(
            col
            ..ChatTypeTabs[text].text
            ..' '..chatType,
        function(data)
            return ClickType==data.type
        end, function(data)
            ClickType= data.type
            WoWTools_ChatMixin:Say(data.text)
            Settings()

        end, {type=text, text=chatType})

        sub:SetTooltip(function(tooltip, desc)
            local newTab={
                [desc.data.text]=1
            }
            
            tooltip:AddLine(desc.data.text)
            for i=2, 12 do
                local str=_G[ChatTypeTabs[desc.data.text].type2..i]
                if str then
                    if str~=desc.data.type then
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

        --[[if isInGroup then
            local unit
            if index==1 then
--队伍，子目录
                for i=1, GetNumGroupMembers()-1, 1 do
                    unit='party'..i
                    if UnitExists(unit) and UnitIsPlayer(unit) then
                        playerName=GetUnitName(unit, true)
                        sub2= sub:CreateButton(WoWTools_UnitMixin:GetPlayerInfo(unit, nil, nil, {reName=true, reRealm=true}), function(data)
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
                            WoWTools_UnitMixin:GetPlayerInfo(unit, nil, nil, {reName=true, reRealm=true}),
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
        end]]


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
    sub=root:CreateCheckbox((isInBat and '|cff9e9e9e' or '')..(WoWTools_DataMixin.onlyChinese and '组队聊天泡泡' or PARTY_CHAT_BUBBLES_TEXT), function()
        return C_CVar.GetCVarBool("chatBubblesParty")
    end, function()
        if not InCombatLockdown() then
            C_CVar.SetCVar("chatBubblesParty", C_CVar.GetCVarBool("chatBubblesParty") and '0' or '1')
            print(WoWTools_DataMixin.Icon.icon2..addName, WoWTools_DataMixin.onlyChinese and '组队聊天泡泡' or PARTY_CHAT_BUBBLES_TEXT, WoWTools_TextMixin:GetEnabeleDisable(C_CVar.GetCVarBool("chatBubblesParty")))
        else
            print(WoWTools_DataMixin.Icon.icon2..addName, WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        end
    end)

    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('C_CVar.SetCVar(\"chatBubblesParty\")')
    end)





    root:CreateDivider()
    for _, tab in pairs({
        {type= 'GroupMouseUpText', text= WoWTools_DataMixin.onlyChinese and '鼠标滚轮向上滚动' or KEY_MOUSEWHEELUP, icon= 'bags-greenarrow'},
        {type= 'GroupMouseDownText', text= WoWTools_DataMixin.onlyChinese and '鼠标滚轮向下滚动' or KEY_MOUSEWHEELDOWN, icon= 'UI-HUD-MicroMenu-StreamDLRed-Up'},
    }) do
        sub= root:CreateButton(
            '|A:'..tab.icon..':0:0|a'
            ..WoWTools_TextMixin:sub(WoWToolsPlayerDate[tab.type], 8, 16),
        function(data)
            Set_OnMouseWheel(data.type=='GroupMouseUpText' and 1 or -1)
        end, tab)
        sub:SetTooltip(function(tooltip, desc)
            tooltip:AddLine('|A:voicechat-icon-textchat-silenced:0:0|a|A:'..desc.data.icon..':0:0|a'..desc.data.text, nil, nil, nil, true)
            tooltip:AddLine(WoWToolsPlayerDate[desc.data.type], nil,nil,nil, true)
        end)

        sub:CreateButton(
            '|A:'..tab.icon..':0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '修改' or HUD_EDIT_MODE_RENAME_LAYOUT),
        function(data)
            StaticPopup_Show('WoWTools_EditText',
                addName
                ..'|n|n'..(WoWTools_DataMixin.onlyChinese and '自定义发送信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CUSTOM, SEND_MESSAGE))
                ..'|n|n|cnGREEN_FONT_COLOR:'..format('|A:%s:0:0|a', data.icon)..data.text..'|r|n|n'
                ..(WoWTools_DataMixin.onlyChinese and '队伍' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS),
            nil,
            {
                text= WoWToolsPlayerDate[data.type],
                SetValue= function(f)
                    local edit= f.editBox or f:GetEditBox()
                    WoWToolsPlayerDate[data.type]= edit:GetText()
                end
            })
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
                        ..WoWTools_UnitMixin:GetPlayerInfo(unit, guid, nil, {reName=true, reRealm=true})
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


    GameTooltip:AddDoubleLine(format(WoWTools_DataMixin.onlyChinese and '%s玩家' or COMMUNITIES_CROSS_FACTION_BUTTON_TOOLTIP_TITLE, playerNum), WoWTools_Mixin:MK(totaleHP,3))
    if playerNum>0 then
        GameTooltip:AddLine(' ')
    end
    local find
    for _, data in pairs(tabT) do
        GameTooltip:AddDoubleLine(data.name, data.col..WoWTools_Mixin:MK(data.maxHP, 3)..INLINE_TANK_ICON)
        find=true
    end
    if find then
        GameTooltip:AddLine(' ')
        find=nil
    end
    for _, data in pairs(tabN) do
        GameTooltip:AddDoubleLine(data.name, data.col..WoWTools_Mixin:MK(data.maxHP, 3)..INLINE_HEALER_ICON)
        find=true
    end
    if find then
        GameTooltip:AddLine(' ')
        find=nil
    end
    for _, data in pairs(tabDPS) do
        GameTooltip:AddDoubleLine(data.name, data.col..WoWTools_Mixin:MK(data.maxHP, 3)..INLINE_DAMAGER_ICON)
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

    ChatTypeTabs={
        ['p']= {--/p
            text=WoWTools_DataMixin.onlyChinese and '队伍' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS,
            type2='SLASH_PARTY',
            cn='队'
        },
        ['r']= {--/raid
            text= WoWTools_DataMixin.onlyChinese and '团队' or RAID,
            type2='SLASH_RAID',
            cn='团'
        },
        ['i']= {--i
            WoWTools_DataMixin.onlyChinese and '副本' or INSTANCE,--/i
            type2='SLASH_INSTANCE_CHAT',
            cn='副'
        },
        ['w']= {--rw
            text= WoWTools_DataMixin.onlyChinese and '团队通知' or RAID_WARNING,--/rw
            type2='SLASH_RAID_WARNING',
            cn='领'
        }
    }

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
            ChatTypeTabs[ClickType].text,
            ClickType..WoWTools_DataMixin.Icon.left
        )

        GameTooltip:AddLine(' ')

        GameTooltip:AddLine(
            '|A:voicechat-icon-textchat-silenced:0:0|a'
            ..WoWTools_DataMixin.Icon.mid
            ..'|A:bags-greenarrow:0:0|a'
            ..WoWToolsPlayerDate['GroupMouseUpText'],
            nil,nil,nil, true
        )

        GameTooltip:AddLine(
            '|A:voicechat-icon-textchat-silenced:0:0|a'
            ..WoWTools_DataMixin.Icon.mid
            ..'|A:UI-HUD-MicroMenu-StreamDLRed-Up:0:0|a'
            ..WoWToolsPlayerDate['GroupMouseDownText'],
            nil,nil,nil, true
        )

        GameTooltip:Show()
    end

    function GroupButton:set_OnMouseDown()
        
    end
    

    GroupButton:SetScript('OnMouseWheel', function(_, d)--发送自定义信息
       Set_OnMouseWheel(d)
    end)

    GroupButton:SetupMenu(Init_Menu)

    C_Timer.After(0.3, function() Settings() end)--队伍信息提示
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

            if Save().mouseUP then
                WoWToolsPlayerDate['GroupMouseUpText']= Save().mouseUP
                Save().mouseUP= nil

                WoWToolsPlayerDate['GroupMouseDownText']= Save().mouseDown
                Save().mouseDown= nil
            end

            WoWToolsPlayerDate['GroupMouseUpText']= WoWToolsPlayerDate['GroupMouseUpText']
                or (WoWTools_DataMixin.Player.Region==1 or WoWTools_DataMixin.Player.Region==3) and 'sum me, pls'
                or (WoWTools_DataMixin.Player.Region==5  and '求拉, 谢谢')
                or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC,SUMMON, COMBATLOG_FILTER_STRING_ME)

            WoWToolsPlayerDate['GroupMouseDownText']= WoWToolsPlayerDate['GroupMouseDownText']
                or (WoWTools_DataMixin.Player.Region~=5 and 'inv, thx') or '1'

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