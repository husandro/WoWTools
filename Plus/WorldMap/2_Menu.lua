local function Save()
    return  WoWToolsSave['Plus_WorldMap']
end




--隐藏，标题
local function ShowHideTitle()
    local text= ''
    if not Save().HideTitle then
        if WorldMapFrame:IsMaximized() then--WorldMapMixin:SetupTitle()
            text= WoWTools_DataMixin.onlyChinese and '地图' or WORLD_MAP
        else
            text= WoWTools_DataMixin.onlyChinese and '地图和任务日志' or MAP_AND_QUEST_LOG
        end
    end
    WorldMapFrame.BorderFrame:SetTitle(text)
end









local function Init_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip_SetTitle(GameTooltip, WoWTools_WorldMapMixin.addName..WoWTools_DataMixin.Icon.icon2)
    GameTooltip:AddLine(' ')

--位面
    if WoWTools_DataMixin.Player.Layer then
        GameTooltip:AddLine(WoWTools_DataMixin.Language.layer..'|cffffffff'..WoWTools_DataMixin.Player.Layer)
    end

    local uiMapID = WorldMapFrame.mapID or WorldMapFrame:GetMapID("current")--地图信息
    if uiMapID then
        local info = C_Map.GetMapInfo(uiMapID)
        if info then
            GameTooltip:AddDoubleLine(info.name, 'uiMapID|A:poi-islands-table:0:0|a|cffffffff'..(info.mapID or uiMapID))--地图ID
            local uiMapGroupID = C_Map.GetMapGroupID(uiMapID)
            if uiMapGroupID then
                GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '区域' or FLOOR, 'uiMapGroupID g |cffffffff'..uiMapGroupID)
            end
        end
        local areaPoiIDs=C_AreaPoiInfo.GetAreaPOIForMap(uiMapID)
        if areaPoiIDs then
            for _,areaPoiID in pairs(areaPoiIDs) do
                local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID)
                if poiInfo and (poiInfo.areaPoiID or poiInfo.tooltipWidgetSet) then
                    GameTooltip:AddDoubleLine(
                        (poiInfo.atlasName and '|A:'..poiInfo.atlasName..':0:0|a' or '')
                        .. poiInfo.name
                        ..(poiInfo.tooltipWidgetSet and ' widgetSetID |cffffffff'..poiInfo.tooltipWidgetSet or ''),

                        poiInfo.areaPoiID and 'areaPoiID |cffffffff'..poiInfo.areaPoiID
                    )
                end
            end
        end
        if IsInInstance() then--副本数据
            local instanceID, _, LfgDungeonID =select(8, GetInstanceInfo())
            if instanceID then
                GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '副本' or INSTANCE, '|cffffffff'..instanceID)
                if LfgDungeonID then
                    GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '随机副本' or LFG_TYPE_RANDOM_DUNGEON, '|cffffffff'..LfgDungeonID)
                end
            end
        end

        local quests= C_QuestLog.GetQuestsOnMap(uiMapID)
        local num= quests and #quests or 0
        if num>0 then
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine(
                '|A:worldquest-tracker-questmarker:0:0|a'
                ..(WoWTools_DataMixin.onlyChinese and '任务' or QUESTS_LABEL)
                ..' #|cffffffff'..num
            )
            for index, tab in pairs(quests) do
                local questID= tab.questID
                if questID then
                    GameTooltip:AddDoubleLine(
                        index..')',
                        (C_QuestLog.IsComplete(questID) and '|cnGREEN_FONT_COLOR:' or '|cffffffff')
                        ..(WoWTools_QuestMixin:GetName(questID) or questID)
                    )
                end
            end
        end

        local x,y = WoWTools_WorldMapMixin:GetPlayerXY()--玩家当前位置
        if x and y then
            local playerCursorMapName
            local uiMapIDPlayer= C_Map.GetBestMapForUnit("player")
            if uiMapIDPlayer and uiMapIDPlayer~=uiMapID then
                local info2 = C_Map.GetMapInfo(uiMapIDPlayer)
                playerCursorMapName=info2 and info2.name
            end
            GameTooltip:AddLine(' ')
            if playerCursorMapName then
                GameTooltip:AddDoubleLine(WoWTools_DataMixin.Icon.Player..playerCursorMapName, 'XY: |cffffffff'..x..' '..y)
            else
                GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '位置' or (RESET_POSITION:gsub(RESET, WoWTools_DataMixin.Icon.Player)), 'XY: |cffffffff'..x..' '..y)
            end
        end
    end
    GameTooltip:Show()

    if _G['WoWToolsPlayerXYButton'] then
        _G['WoWToolsPlayerXYButton']:SetButtonState('PUSHED')
    end
end
































local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub

--地图和任务日志
    sub= root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '地图和任务日志' or MAP_AND_QUEST_LOG,
    function()
        return not Save().HideTitle
    end, function()
        Save().HideTitle= not Save().HideTitle and true or nil
        ShowHideTitle()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '标题' or NAME)
        tooltip:AddLine(WoWTools_TextMixin:GetShowHide(nil, true))
    end)
    root:CreateDivider()


--显示地图ID
    sub= root:CreateCheckbox(
        (WoWTools_DataMixin.onlyChinese and '地图' or WORLD_MAP)..' ID',
    function()
        return Save().ShowMapID
    end, function()
        Save().ShowMapID= not Save().ShowMapID and true or false
        WoWTools_WorldMapMixin:Init_MpaID()
    end)

    WoWTools_MenuMixin:ScaleRoot(self, sub, function()
        return Save().MapIDScale or 1
    end, function(value)
        Save().MapIDScale= value
        WoWTools_WorldMapMixin:Init_MpaID()
    end, function()
        Save().MapIDScale=nil
        WoWTools_WorldMapMixin:Init_MpaID()
    end)



--地图坐标
    sub= root:CreateCheckbox(
        (WoWTools_DataMixin.onlyChinese and '地图' or WORLD_MAP)..' XY',
    function()
        return Save().ShowMapXY
    end, function()
        Save().ShowMapXY= not Save().ShowMapXY and true or false
        WoWTools_WorldMapMixin:Init_XY_Map()
    end)

    sub:CreateSpacer()--宽度
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().MapXY_W or 90
        end, setValue=function(value)
            Save().MapXY_W= value
            WoWTools_WorldMapMixin:Init_XY_Map()
        end,
        name=WoWTools_DataMixin.onlyChinese and '宽度' or HUD_EDIT_MODE_SETTING_CHAT_FRAME_WIDTH,
        minValue=50,
        maxValue=300,
        step=1,
        bit=nil,
    })
    sub:CreateSpacer()

    sub:CreateSpacer()--X
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().MapXY_X or 35
        end, setValue=function(value)
            Save().MapXY_X= value
            WoWTools_WorldMapMixin:Init_XY_Map()
        end,
        name='X',
        minValue=-1028,
        maxValue=1028,
        step=1,
        bit=nil,
    })
    sub:CreateSpacer()

--MapXY_Y
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().MapXY_Y or -2
        end, setValue=function(value)
            Save().MapXY_Y= value
            WoWTools_WorldMapMixin:Init_XY_Map()
        end,
        name='Y',
        minValue=-1028,
        maxValue=1028,
        step=1,
        bit=nil,
    })
    sub:CreateSpacer()

--缩放
    WoWTools_MenuMixin:ScaleRoot(self, sub, function()
        return Save().MapXYScale or 1
    end, function(value)
        Save().MapXYScale= value
        WoWTools_WorldMapMixin:Init_XY_Map()
    end, function()--重置
        Save().MapXYScale= nil
        Save().MapXY_W= nil
        Save().MapXY_X= nil
        Save().MapXY_Y= nil
        WoWTools_WorldMapMixin:Init_XY_Map()
    end)

--玩家当前位置
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.Icon.Player..' XY',
    function()
        return not Save().PlayerXY.disabled
    end, function()
        Save().PlayerXY.disabled= not Save().PlayerXY.disabled and true or nil
        WoWTools_WorldMapMixin:Init_XY_Player()
    end)

    WoWTools_MenuMixin:RestPoint(self, sub,
        Save().PlayerXY.point,
    function()
        Save().PlayerXY.point= nil
        WoWTools_WorldMapMixin:Init_XY_Player()
    end)

    root:CreateDivider()

--AreaPOI名称
    sub=root:CreateCheckbox(
        '|A:minimap-genericevent-hornicon:0:0|aAreaPOI',
    function()
        return Save().ShowAreaPOI_Name
    end, function()
        Save().ShowAreaPOI_Name= not Save().ShowAreaPOI_Name and true or false
        WoWTools_WorldMapMixin:Init_AreaPOI_Name()
        WoWTools_WorldMapMixin:Refresh()
    end,sub)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '显示名称' or PROFESSIONS_FLYOUT_SHOW_NAME)
        --tooltip:AddLine('|cnWARNING_FONT_COLOR:BUG')
    end)

--字体大小
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        name= WoWTools_DataMixin.onlyChinese and '字体大小' or FONT_SIZE,
        getValue=function()
            return Save().areaPoinFontSize or 10
        end, setValue=function(value)
            Save().areaPoinFontSize=value
            WoWTools_WorldMapMixin:Refresh()
        end,
        minValue=4,
        maxValue=24,
        step=1,
        --tooltip=WoWTools_DataMixin.onlyChinese and '需要刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH)
    })

--地下城，加名称
    sub=root:CreateCheckbox(
        '|A:Dungeon:0:0|a'..(WoWTools_DataMixin.onlyChinese and '地下城' or DUNGEONS),
    function()
        return Save().ShowDungeon_Name
    end, function()
        Save().ShowDungeon_Name= not Save().ShowDungeon_Name and true or false
        WoWTools_WorldMapMixin:Init_Dungeon_Name()--地下城，加名称
        WoWTools_WorldMapMixin:Refresh()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '显示名称' or PROFESSIONS_FLYOUT_SHOW_NAME)
        --tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需要刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH))
    end)

--字体大小
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        name= WoWTools_DataMixin.onlyChinese and '字体大小' or FONT_SIZE,
        getValue=function()
            return Save().dungeonFontSize or 10
        end, setValue=function(value)
            Save().dungeonFontSize=value
            WoWTools_WorldMapMixin:Refresh()
        end,
        minValue=4,
        maxValue=24,
        step=1,
        --tooltip=WoWTools_DataMixin.onlyChinese and '需要刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH)
    })

--世界地图任务，加名称
    sub=root:CreateCheckbox(
        '|A:Quest-Campaign-Available:0:0|a'..(WoWTools_DataMixin.onlyChinese and '世界任务' or WORLD_MAP_FILTER_LABEL_WORLD_QUESTS_SUBMENU),
    function()
        return Save().ShowWorldQues_Name
    end, function()
        Save().ShowWorldQues_Name= not Save().ShowWorldQues_Name and true or false
        WoWTools_WorldMapMixin:Init_WorldQuest_Name()--世界地图任务，加名称
        WoWTools_WorldMapMixin:Refresh()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '显示图标' or SELF_HIGHLIGHT_ICON)
    end)

--Plus
    root:CreateDivider()
    sub=root:CreateCheckbox(
        'Plus',
    function()
        return not Save().notPlus
    end, function()
        Save().notPlus= not Save().notPlus and true or nil
        WoWTools_WorldMapMixin:Init_Plus()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '其它' or OTHER)
        tooltip:AddLine(
            (Save().notPlus and '|cff626262' or '')
            ..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        )
    end)

--重新加载UI
    root:CreateDivider()
    sub= WoWTools_MenuMixin:Reload(root)
--打开选项
    WoWTools_MenuMixin:OpenOptions(sub, {name= WoWTools_WorldMapMixin.addName})
end



















local function Init()--显示地图ID
    local MenuButton= CreateFrame('DropdownButton', 'WoWTools_PlusWorldMap_MenuButton', WorldMapFrame.BorderFrame.TitleContainer, 'WoWToolsMenuTemplate')
    --[[WoWTools_ButtonMixin:Menu(WorldMapFrame.BorderFrame.TitleContainer, {
        name='WoWTools_PlusWorldMap_MenuButton'
    })]]

    if C_AddOns.IsAddOnLoaded('Mapster') then
        C_Timer.After(2, function()
            if _G['MapsterOptionsButton'] then
                _G['MapsterOptionsButton']:SetSize(23, 23)
                _G['MapsterOptionsButton']:SetText('M')
                _G['MapsterOptionsButton']:ClearAllPoints()
                _G['MapsterOptionsButton']:SetPoint('RIGHT', WorldMapFrame.BorderFrame.MaximizeMinimizeFrame.MaximizeButton, 'LEFT')
                MenuButton:SetPoint('RIGHT', _G['MapsterOptionsButton'], 'LEFT')
            else
                MenuButton:SetPoint('RIGHT', WorldMapFrame.BorderFrame.MaximizeMinimizeFrame.MaximizeButton, 'LEFT')
            end
        end)
    else
        MenuButton:SetPoint('RIGHT', WorldMapFrame.BorderFrame.MaximizeMinimizeFrame.MaximizeButton, 'LEFT')
    end


    MenuButton:SetScript('OnLeave', function()
        GameTooltip:Hide()
        if _G['WoWToolsPlayerXYButton'] then
            _G['WoWToolsPlayerXYButton']:SetButtonState('NORMAL')
        end
    end)
    MenuButton:SetScript('OnEnter', Init_OnEnter)

    MenuButton:SetupMenu(Init_Menu)

    Init=function()end
end








--Blizzard_WorldMap.lua
local function Init_Set_Title()
    WoWTools_DataMixin:Hook(WorldMapFrame, 'SynchronizeDisplayState', function()
        if Save().HideTitle then
            ShowHideTitle()
        end
    end)
    WoWTools_DataMixin:Hook(WorldMapFrame, 'SetupTitle', function()
        if Save().HideTitle then
            ShowHideTitle()
        end
    end)

    if Save().HideTitle then--隐藏，标题
        ShowHideTitle()
    end
end




function WoWTools_WorldMapMixin:Init_Menu()
    Init()
    Init_Set_Title()
end