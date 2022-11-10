local id, e = ...

local panel=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)
panel:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
WoWToolsChatButtonFrame.last=panel

local roleAtlas={
    TANK='groupfinder-icon-role-large-tank',
    HEALER='groupfinder-icon-role-large-heal',
    DAMAGER='groupfinder-icon-role-large-dps',
    NONE='socialqueuing-icon-group',
}

local function setGroupTips()--队伍信息提示
    local isInGroup= IsInGroup()
    local isInRaid= IsInRaid()
    local isInInstance= IsInInstance()
    local num=GetNumGroupMembers()
    if isInGroup and not panel.membersText then--人数
        panel.membersText=e.Cstr(panel, 10, nil, nil, true)
        panel.membersText:SetPoint('TOPLEFT', 3, -3)
    end
    if panel.membersText then
        panel.membersText:SetText(isInGroup and num or '')
    end

    local subgroup, combatRole--小队号
    local tab=e.GroupGuid[UnitGUID('player')]
    if tab then
        subgroup= tab and tab.subgroup
        combatRole=tab.combatRole
    end
    if subgroup and not panel.subgroupTexture then
        panel.subgroupTexture=e.Cstr(panel, 10, nil, nil, true, nil, 'RIGHT')
        panel.subgroupTexture:SetPoint('TOPRIGHT',-6,-3)
        panel.subgroupTexture:SetTextColor(0,1,0)
    end
    if panel.subgroupTexture then
        panel.subgroupTexture:SetText(subgroup or '')
    end

    if isInRaid and not isInInstance and not panel.textureNotInstance then
       panel.textureNotInstance=panel:CreateTexture(nil,'BACKGROUND')
       panel.textureNotInstance:SetAllPoints(panel)
       panel.textureNotInstance:SetAtlas('WhiteCircle-RaidBlips')
       panel.textureNotInstance:SetColorTexture(1,0,0)
    end
    if panel.textureNotInstance then
        panel.textureNotInstance:SetShown(isInRaid and not isInInstance)
    end

    if isInGroup then
        panel.texture:SetAtlas(roleAtlas[combatRole] or roleAtlas['NONE'])
    end
    panel.texture:SetShown(isInGroup)

    if panel.typeText then
        panel.typeText:SetShown(isInGroup)
    end
end

local function setType(text)--使用,提示
    if not panel.typeText then
        panel.typeText=e.Cstr(panel, 10, nil, nil, true)
        panel.typeText:SetPoint('BOTTOM',0,7)
    end
    if panel.type and text:find('%w') then--处理英文
        text=panel.type:gsub('/','')
    else
        text= text==RAID_WARNING and COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_SETTINGS_LABEL or text--团队通知->通知
        text=e.WA_Utf8Sub(text, 1)
    end
    
    panel.typeText:SetText(text)
    panel.typeText:SetShown(IsInGroup())
end
--#####
--主菜单
--#####
local chatType={
    {text= RAID, type= SLASH_RAID2},--/raid
    {text= HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS, type= SLASH_PARTY1},--/p
    {text= RAID_WARNING, type= 	SLASH_RAID_WARNING1},--/rw
    {text= INSTANCE, type= SLASH_INSTANCE_CHAT1},--/i
}
local function InitMenu(self, level, type)--主菜单
    local isInGroup= IsInGroup()
    local isInRaid= IsInRaid()
    local isInInstance= IsInInstance()
    local num=GetNumGroupMembers()
    local le=UnitIsGroupAssistant('player') or  UnitIsGroupLeader('player')
    local info
    for _, tab in pairs(chatType) do
        info={
            text=tab.text,
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle=tab.type,
            func=function()
                e.Say(tab.type)
                panel.type=tab.type
                setType(tab.text)--使用,提示
            end
        }
        if (tab.text==RAID and not isInRaid)--设置颜色
            or (tab.text==HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS and not isInGroup)
            or (tab.text== INSTANCE and (not isInInstance or num<2))
            or (tab.text==RAID_WARNING and (not isInRaid or not le))
        then
            info.colorCode='|cff606060'
        end
        UIDropDownMenu_AddButton(info, level)
    end
end
--####
--初始
--####
local function Init()
    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    if IsInRaid() then
        panel.type=SLASH_RAID2
        setType(RAID)--使用,提示
    elseif IsInGroup() then
        panel.type=SLASH_PARTY1
        setType(HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS)--使用,提示
    end

    panel.texture:SetAtlas('socialqueuing-icon-group')
    panel:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' and panel.type then
            e.Say(panel.type)
        else
            ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
        end
    end)

    C_Timer.After(0.3, function() setGroupTips() end)--队伍信息提示
end




--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('GROUP_LEFT')
panel:RegisterEvent('GROUP_ROSTER_UPDATE')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
        if WoWToolsChatButtonFrame.disabled then--禁用Chat Button
            panel:SetShown(false)
            panel:UnregisterAllEvents()
        else
            Init()
        end
    elseif event=='GROUP_ROSTER_UPDATE' or event=='GROUP_LEFT' then
         C_Timer.After(0.3, function() setGroupTips() end)--队伍信息提示
         
    end
end)