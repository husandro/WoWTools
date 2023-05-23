local id, e = ...
local addName= 'ChatButtonGroup'
local Save={
    mouseUP= not LOCALE_zhCN and SUMMON ..' '..COMBATLOG_FILTER_STRING_ME or '求拉, 谢谢',
    mouseDown= not LOCALE_zhCN and 'inv, thx' or '1' ,
}
local button

local roleAtlas={
    TANK='groupfinder-icon-role-large-tank',
    HEALER='groupfinder-icon-role-large-heal',
    DAMAGER='groupfinder-icon-role-large-dps',
    NONE='socialqueuing-icon-group',
}

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

    local subgroup, combatRole
    local tab=e.GroupGuid[e.Player.guid]
    if tab then
        subgroup= tab and tab.subgroup
        combatRole=tab.combatRole
    end

    if subgroup and not button.subgroupTexture then--小队号
        button.subgroupTexture=e.Cstr(button, {size=10, colro=true, justifyH='RIGHT'})--10, nil, nil, true, nil, 'RIGHT')
        button.subgroupTexture:SetPoint('TOPRIGHT',-6,-3)
        button.subgroupTexture:SetTextColor(0,1,0)
    end
    if button.subgroupTexture then
        button.subgroupTexture:SetText(subgroup or '')
    end

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

local function setText(text)--处理%s
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
local function InitMenu(self, level, type)--主菜单
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
                text=setText(text)--处理%s
            end
            info={
                text= text,
                icon= tab.icon,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle=tab.text,
                arg1=tab.text,
                arg2=tab.type,
                func=function(_, arg1, arg2)
                    StaticPopupDialogs[id..addName..'CUSTOM']={--区域,设置对话框
                        text=id..'    '..addName
                            ..'|n|n'..(e.onlyChinese and '自定义发送信息' or (CUSTOM..SEND_MESSAGE))
                            ..'|n|n|cnGREEN_FONT_COLOR:%s|r|n|n'
                            ..(e.onlyChinese and '队伍' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS),
                        whileDead=1,
                        hideOnEscape=1,
                        exclusive=1,
                        timeout = 60,
                        hasEditBox=1,
                        button1= e.onlyChinese and '修改' or SLASH_CHAT_MODERATE2:gsub('/',''),
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
                                self2:GetParent().button1:SetText(e.onlyChinese and '修改' or SLASH_CHAT_MODERATE2:gsub('/',''))
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
            func= function()
                C_CVar.SetCVar("chatBubblesParty", not C_CVar.GetCVarBool("chatBubblesParty") and '1' or '0')
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    end
end

local function show_Group_Info_Toolstip()--玩家,信息, 提示
    local co=GetNumGroupMembers()
    if not IsInGroup() or co<2 then
        return
    end

    local UnitTab={}
    local raid=IsInRaid()
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
        if (not e.UnitItemLevel[guid] or not e.UnitItemLevel[guid].itemLeve) then
            table.insert(UnitTab, unit)
            NotifyInspect(unit)--取得装等
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

        if guid and maxHP and role then
            info.name= (e.PlayerOnlineInfo(unit) or '')..e.GetPlayerInfo({unit=unit, guid=guid, name=nil,  reName=true, reRealm=true}).. (e.UnitItemLevel[guid] and e.UnitItemLevel[guid].itemLeve or '')
            info.maxHP= maxHP

            if uiMapID then--不在同地图
                local text, mapID=e.GetUnitMapName(unit)
                if text and mapID and mapID~=uiMapID then
                    info.name= info.name..e.Icon.map2..'|cnRED_FONT_COLOR:'..text..'|r'
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
        e.tips:AddDoubleLine(info.name, e.MK(info.maxHP, 3)..INLINE_TANK_ICON)
        find=true
    end
    if find then
        e.tips:AddLine(' ')
        find=nil
    end
    for _, info in pairs(tabN) do
        e.tips:AddDoubleLine(info.name, e.MK(info.maxHP, 3)..INLINE_HEALER_ICON)
        find=true
    end
    if find then
        e.tips:AddLine(' ')
        find=nil
    end
    for _, info in pairs(tabDPS) do
        e.tips:AddDoubleLine(info.name, e.MK(info.maxHP, 3)..INLINE_DAMAGER_ICON)
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
                self.Menu=CreateFrame("Frame", id..addName..'Menu', self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, InitMenu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
        end
    end)

    button:SetScript('OnMouseWheel', function(self, d)--发送自定义信息
        local text= d==1 and Save.mouseUP or d==-1 and Save.mouseDown
        if text then
            text=setText(text)--处理%s
            e.Chat(text, nil, true)
        end
    end)

    --button:SetScript('OnLeave', function() e.tips:Hide() end)

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
                button=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)

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