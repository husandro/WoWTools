local id, e = ...
local addName= 'ChatButtonGroup'
local Save={
    --mouseUP=  not LOCALE_zhCN and SUMMON ..' '..COMBATLOG_FILTER_STRING_ME or '求拉, 谢谢',
    mouseUP=  (e.Player.region==1 or e.Player.region==3) and 'sum me, pls'
                or e.Player.region==5  and '求拉, 谢谢'
                or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC,SUMMON, COMBATLOG_FILTER_STRING_ME),
    mouseDown= e.Player.region~=5 and 'inv, thx' or '1' ,
}
--1US (includes Brazil and Oceania) 2Korea 3Europe (includes Russia) 4Taiwan 5China
local button

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

local function setType(text)--使用,提示
    if not button.typeText then
        button.typeText=e.Cstr(button,{size=10, color=true})-- 10, nil, nil, true)
        button.typeText:SetPoint('BOTTOM',0,2)
    end
    if button.type and text:find('%w') then--处理英文
        text=button.type:gsub('/','')
    else
        text= text==RAID_WARNING and COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL or text--团队通知->通知
        text=e.WA_Utf8Sub(text, 1)
    end

    button.typeText:SetText(text)
    button.typeText:SetShown(IsInGroup())
end

local function setGroupTips()--队伍信息提示
    local isInGroup= IsInGroup()
    local isInRaid= IsInRaid()
    local isInInstance= IsInInstance()
    local num=GetNumGroupMembers()

    if not button.type then
        if isInRaid then
            button.type=SLASH_RAID2
            setType(RAID)--使用,提示
        elseif isInGroup then
            button.type=SLASH_PARTY1
            setType(HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS)--使用,提示
        end
    end

    if isInGroup and not button.membersText then--人数
        button.membersText=e.Cstr(button, {size=10, color=true})--10, nil, nil, true)
        button.membersText:SetPoint('TOPLEFT', 3, -3)
    end
    if button.membersText then
        button.membersText:SetText(isInGroup and num or '')
    end

    local combatRole--subgroup,
    local tab=e.GroupGuid[e.Player.guid]
    if tab then
      --  subgroup= tab and tab.subgroup
        combatRole=tab.combatRole
    end

    --[[if subgroup and not button.subgroupTexture then--小队号
        button.subgroupTexture=e.Cstr(button, {size=10, colro=true, justifyH='RIGHT'})--10, nil, nil, true, nil, 'RIGHT')
        button.subgroupTexture:SetPoint('TOPRIGHT',-6,-3)
        button.subgroupTexture:SetTextColor(0,1,0)
    end
    if button.subgroupTexture then
        button.subgroupTexture:SetText(subgroup or '')
    end]]

    if isInRaid and not isInInstance and not button.textureNotInstance then--在副本外, 在团时, 提示
        button.textureNotInstance=button:CreateTexture(nil,'BACKGROUND')
        button.textureNotInstance:SetAllPoints(button)
        button.textureNotInstance:SetAtlas('socket-punchcard-red-background')
    end
    if button.textureNotInstance then
        button.textureNotInstance:SetShown(isInRaid and not isInInstance)
    end

    if isInGroup then--职责提示
        button.texture:SetAtlas( roleAtlas[combatRole] or roleAtlas['NONE'])
    else
        button.texture:SetAtlas('socialqueuing-icon-group')
    end
    --button.texture:SetDesaturated(not isInGroup)
    --button.texture:SetShown(isInGroup)

    if button.typeText then
        button.typeText:SetShown(isInGroup)
    end
end

local function set_Text(text)--处理%s
    local groupTab= e.GroupGuid[e.Player.guid]
    if text:find('%%s') and groupTab and groupTab.subgroup then
        text= text:format(groupTab.subgroup..' '..GROUP..' ')
    else
        text= text:gsub('%%s','')
    end
    return text
end
















--#####
--主菜单
--#####
local function InitMenu(_, level, type)--主菜单
    local chatType={
        {text= e.onlyChinese and '队伍' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS, type= SLASH_PARTY1},--/p
        {text= e.onlyChinese and '团队' or RAID, type= SLASH_RAID1},--/raid
        {text= e.onlyChinese and '副本' or INSTANCE, type= SLASH_INSTANCE_CHAT1},--/i
        {text= e.onlyChinese and '团队通知' or RAID_WARNING, type= 	SLASH_RAID_WARNING1},--/rw
    }
    local info
    if type then
        local tab2={
            {type= 'mouseUP', text= e.onlyChinese and '鼠标滚轮向上滚动' or KEY_MOUSEWHEELUP, icon= 'bags-greenarrow'},
            {type= 'mouseDown', text= e.onlyChinese and '鼠标滚轮向下滚动' or KEY_MOUSEWHEELDOWN, icon= 'UI-HUD-MicroMenu-StreamDLYellow-Up'},
        }
        for _, tab in pairs(tab2) do
            local text=(Save[tab.type] or tab.text)
            if Save[tab.type] then
                text=set_Text(text)--处理%s
            end
            info={
                text= text,
                icon= tab.icon,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle=tab.text,
                arg1=tab.text,
                arg2=tab.type,
                keepShownOnClick=true,
                func=function(_, arg1, arg2)
                    StaticPopupDialogs[id..addName..'CUSTOM']={--区域,设置对话框
                        text=id..'    '..addName
                            ..'|n|n'..(e.onlyChinese and '自定义发送信息' or (CUSTOM..SEND_MESSAGE))
                            ..'|n|n|cnGREEN_FONT_COLOR:%s|r|n|n'
                            ..(e.onlyChinese and '队伍' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS),
                        whileDead=true, hideOnEscape=true, exclusive=true,
                        hasEditBox=1,
                        button1= e.onlyChinese and '修改' or EDIT,
                        button2= e.onlyChinese and '取消' or CANCEL,
                        OnShow = function(self2, data)
                            self2.editBox:SetWidth(self2:GetWidth()-30)
                            if Save[data.type] then
                                self2.editBox:SetText(Save[data.type])
                            end
                        end,
                        OnAccept = function(self2, data)
                            local text2= self2.editBox:GetText()
                            if text2:gsub(' ','')=='' then
                                Save[data.type]=nil
                            else
                                Save[data.type]=text2
                            end
                        end,
                        EditBoxOnTextChanged=function(self2, data)
                            local text2= self2:GetText()
                            if text2:gsub(' ','')=='' then
                                self2:GetParent().button1:SetText(e.onlyChinese and '移除' or REMOVE)
                            else
                                self2:GetParent().button1:SetText(e.onlyChinese and '修改' or EDIT)
                            end
                        end,
                        EditBoxOnEscapePressed = function(s)
                            s:SetAutoFocus(false)
                            s:ClearFocus()
                            s:GetParent():Hide()
                        end,
                    }
                    StaticPopup_Show(id..addName..'CUSTOM', arg1, nil , {type=arg2})
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
    else
        local isInGroup= IsInGroup()
        local isInRaid= IsInRaid()
        local isInInstance= IsInInstance()
        local num=GetNumGroupMembers()
        local le=UnitIsGroupAssistant('player') or  UnitIsGroupLeader('player')

        for _, tab in pairs(chatType) do
            info={
                text=tab.text,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle=tab.type,
                keepShownOnClick=true,
                func=function()
                    e.Say(tab.type)
                    button.type=tab.type
                    setType(tab.text)--使用,提示
                end
            }
            if ((tab.text==HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS or tab.text=='队伍') and not isInGroup)
                or ((tab.text==RAID or tab.text=='团队') and not isInRaid)--设置颜色
                or ((tab.text== INSTANCE or tab.text=='副本') and (not isInInstance or num<2))
                or ((tab.text==RAID_WARNING or tab.text=='团队通知') and (not isInRaid or not le))
            then
                info.colorCode='|cff606060'
            elseif (tab.text==RAID or tab.text=='团队') and not isInInstance then--在副本外,团
                info.colorCode='|cffff0000'
            end
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        e.LibDD:UIDropDownMenu_AddSeparator(level)

        info={
            text= (e.onlyChinese and '跨阵营' or COMMUNITIES_EDIT_DIALOG_CROSS_FACTION)
                ..' '..(isInGroup and e.GetYesNo(C_PartyInfo.IsCrossFactionParty)
                        or C_PartyInfo.CanFormCrossFactionParties() and (e.onlyChinese and '创建' or BATTLETAG_CREATE)
                        or (e.onlyChinese and '无' or NONE)),
            notCheckable=true,
            isTitle=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text=((Save.mouseDown or Save.mouseUP) and e.Icon.mid or '').. (e.onlyChinese and '自定义' or CUSTOM),
            notCheckable=true,
            menuList='CUSTOM',
            hasArrow=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinese and '聊天泡泡' or CHAT_BUBBLES_TEXT,
            tooltipOnButton=true,
            tooltipTitle= 'CVar chatBubblesParty',
            checked= C_CVar.GetCVarBool("chatBubblesParty"),
            disabled= UnitAffectingCombat('player'),
            keepShownOnClick=true,
            func= function()
                C_CVar.SetCVar("chatBubblesParty", not C_CVar.GetCVarBool("chatBubblesParty") and '1' or '0')
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    end
end

local function show_Group_Info_Toolstip()--玩家,信息, 提示
    local raid= IsInRaid()
    local co= raid and MAX_RAID_MEMBERS or GetNumGroupMembers()
    if not IsInGroup() or co<2 then
        return
    end

    local UnitTab={}--取得装等

    local u= raid and 'raid' or 'party'
    local tabT, tabN, tabDPS, totaleHP = {}, {}, {}, 0
    local uiMapID= select(2, e.GetUnitMapName('player'))

    for i=1, co do
        local unit=u..i
        local info={}
        if not raid and i==co then
            unit='player'
        end

        local guid= UnitGUID(unit)
        if guid and UnitExists(unit) then
            if (not e.UnitItemLevel[guid] or not e.UnitItemLevel[guid].itemLeve) then
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
                info.name= (e.PlayerOnlineInfo(unit) or '')..e.GetPlayerInfo({unit=unit, guid=guid, reName=true, reRealm=true})..(e.UnitItemLevel[guid] and e.UnitItemLevel[guid].itemLeve or '')
                info.maxHP= maxHP
                info.col= select(4, e.GetUnitColor(unit))
                if uiMapID then--不在同地图
                    local text, mapID=e.GetUnitMapName(unit)
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

    e.tips:SetOwner(button, "ANCHOR_LEFT")
    e.tips:ClearLines()
    e.tips:AddDoubleLine(format(e.onlyChinese and '%s玩家' or COMMUNITIES_CROSS_FACTION_BUTTON_TOOLTIP_TITLE, co), e.MK(totaleHP,3))

    local find
    for _, info in pairs(tabT) do
        e.tips:AddDoubleLine(info.name, info.col..e.MK(info.maxHP, 3)..INLINE_TANK_ICON)
        find=true
    end
    if find then
        e.tips:AddLine(' ')
        find=nil
    end
    for _, info in pairs(tabN) do
        e.tips:AddDoubleLine(info.name, info.col..e.MK(info.maxHP, 3)..INLINE_HEALER_ICON)
        find=true
    end
    if find then
        e.tips:AddLine(' ')
        find=nil
    end
    for _, info in pairs(tabDPS) do
        e.tips:AddDoubleLine(info.name, info.col..e.MK(info.maxHP, 3)..INLINE_DAMAGER_ICON)
    end

    e.tips:Show()

    e.GetNotifyInspect(UnitTab)--取得装等
end

--####
--初始
--####
local function Init()
    button:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
    WoWToolsChatButtonFrame.last=button

    if IsInRaid() then
        button.type=SLASH_RAID2
        setType(RAID)--使用,提示
    elseif IsInGroup() then
        button.type=SLASH_PARTY1
        setType(HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS)--使用,提示
    end

    button.texture:SetAtlas('socialqueuing-icon-group')
    button:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' and button.type then
            e.Say(button.type)
        else
            show_Group_Info_Toolstip()--玩家,信息, 提示
            if not self.Menu then
                self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, InitMenu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
        end
    end)

    button:SetScript('OnMouseWheel', function(self, d)--发送自定义信息
        local text
        if d==1 then
            text= Save.mouseUP
        elseif d==-1 then
            text= Save.mouseDown
        end
        if text then
            text=set_Text(text)--处理%s
            if IsInRaid() then
                SendChatMessage(text, 'RAID')
            elseif IsInGroup() then
                SendChatMessage(text, 'PARTY')
            else
                e.Chat(text, nil, nil)
            end
        end
    end)

    button:SetScript('OnLeave', GameTooltip_Hide)
    button:SetScript('OnEnter', function(self2)
        if (Save.mouseDown or Save.mouseUP) then-- and IsInGroup()
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.onlyChinese and '说' or SAY, IsInRaid() and (e.onlyChinese and '团队' or RAID) or IsInGroup() and (e.onlyChinese and '小队' or GROUP))
            if Save.mouseUP then
                e.tips:AddDoubleLine(Save.mouseUP, (e.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP)..e.Icon.mid)
            end
            if Save.mouseDown then
                e.tips:AddDoubleLine(Save.mouseDown, (e.onlyChinese and '下' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_DOWN)..e.Icon.mid)
            end
            e.tips:Show()
        end
    end)


    C_Timer.After(0.3, function() setGroupTips() end)--队伍信息提示
end

--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if not WoWToolsChatButtonFrame.disabled then--禁用Chat Button
                Save= WoWToolsSave[addName] or Save

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
                panel:RegisterEvent('GROUP_LEFT')
                panel:RegisterEvent('GROUP_ROSTER_UPDATE')
            end
            panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='GROUP_ROSTER_UPDATE' or event=='GROUP_LEFT' then
        C_Timer.After(0.3, function() setGroupTips() end)--队伍信息提示

    end
end)