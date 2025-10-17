


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
    GameTooltip:ClearLines()
    GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_WorldMapMixin.addName)
    GameTooltip:AddLine(' ')
    GameTooltip:AddDoubleLine(WoWTools_DataMixin.Player.Language.layer, WoWTools_DataMixin.Player.Layer or (WoWTools_DataMixin.onlyChinese and '无' or NONE))--位面

    local uiMapID = WorldMapFrame.mapID or WorldMapFrame:GetMapID("current")--地图信息
    if uiMapID then
        local info = C_Map.GetMapInfo(uiMapID)
        if info then
            GameTooltip:AddDoubleLine(info.name, 'mapID '..info.mapID or uiMapID)--地图ID
            local uiMapGroupID = C_Map.GetMapGroupID(uiMapID)
            if uiMapGroupID then
                GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '区域' or FLOOR, 'uiMapGroupID g'..uiMapGroupID)
            end
        end
        local areaPoiIDs=C_AreaPoiInfo.GetAreaPOIForMap(uiMapID)
        if areaPoiIDs then
            for _,areaPoiID in pairs(areaPoiIDs) do
                local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID)
                if poiInfo and (poiInfo.areaPoiID or poiInfo.tooltipWidgetSet) then
                    GameTooltip:AddDoubleLine((poiInfo.atlasName and '|A:'..poiInfo.atlasName..':0:0|a' or '')
                    .. poiInfo.name
                    ..(poiInfo.tooltipWidgetSet and ' widgetSetID '..poiInfo.tooltipWidgetSet or ''),
                    'areaPoiID '..(poiInfo.areaPoiID or NONE))
                end
            end
        end
        if IsInInstance() then--副本数据
            local instanceID, _, LfgDungeonID =select(8, GetInstanceInfo())
            if instanceID then
                GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '副本' or INSTANCE, instanceID)
                if LfgDungeonID then
                    GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '随机副本' or LFG_TYPE_RANDOM_DUNGEON, LfgDungeonID)
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
                GameTooltip:AddDoubleLine(WoWTools_DataMixin.Icon.Player..playerCursorMapName, 'XY: '..x..' '..y)
            else
                GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '位置' or (RESET_POSITION:gsub(RESET, WoWTools_DataMixin.Icon.Player)), 'XY: '..x..' '..y)
            end
        end
    end
    GameTooltip:Show()

    if _G['WoWToolsPlayerXYButton'] then
        _G['WoWToolsPlayerXYButton']:SetButtonState('PUSHED')
    end
end



















--实时玩家当前坐标，选项
local function Init_PlayerXY_Option_Menu(self, root2)
    local sub
    local root= root2

    sub= root:CreateButton(
        '|A:Waypoint-MapPin-ChatIcon:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '分享' or SOCIAL_SHARE_TEXT),
    function()
        WoWTools_WorldMapMixin:SendPlayerPoint()--发送玩家位置
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '分享链接至聊天栏' or CLUB_FINDER_LINK_POST_IN_CHAT)

        local mapID= C_Map.GetBestMapForUnit("player")
        local can= mapID and C_Map.CanSetUserWaypointOnMap(mapID)
        if not can then
            tooltip:AddLine('|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '当前地图不能标记' or "Cannot set waypoints on this map"))
        end
    end)

    root:CreateDivider()
    if self==_G['WoWToolsPlayerXYButton'] then
        root= root:CreateButton(
            '|A:mechagon-projects:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '选项' or GAMEMENU_OPTIONS),
        function()
            return MenuResponse.Open
        end)
    end

    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '右边' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT,
    function()
        return not Save().PlayerXY_Text_toLeft
    end, function()
        Save().PlayerXY_Text_toLeft= not Save().PlayerXY_Text_toLeft and true or nil
        WoWTools_WorldMapMixin:Init_XY_Player()
    end)

--Text Y
    root:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(root, {
        getValue=function()
            return Save().PlayerXY_TextY or -3
        end, setValue=function(value)
            Save().PlayerXY_TextY= value
            WoWTools_WorldMapMixin:Init_XY_Player()
        end,
        name= 'Y',
        minValue=-23,
        maxValue=23,
        step=1,
        bit=nil,
    })

--FrameStrata
    root:CreateSpacer()
    WoWTools_MenuMixin:FrameStrata(self, root, function(data)
        if _G['WoWToolsPlayerXYButton'] then
            return _G['WoWToolsPlayerXYButton']:GetFrameStrata()==data
        end
    end, function(data)
        Save().PlayerXY_Strata= data
        WoWTools_WorldMapMixin:Init_XY_Player()
    end)

--延迟容限
    root:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(root, {
        getValue=function()
            return Save().PlayerXY_Elapsed or 0.3
        end, setValue=function(value)
            Save().PlayerXY_Elapsed= value
            WoWTools_WorldMapMixin:Init_XY_Player()
        end,
        name= WoWTools_DataMixin.onlyChinese and '延迟' or LAG_TOLERANCE,
        minValue=0.1,
        maxValue=0.5,
        step=0.01,
        bit='%.2f',
    })

--图像大小
    root:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(root, {
        getValue=function()
            return Save().PlayerXY_Size or 23
        end, setValue=function(value)
            Save().PlayerXY_Size= value
            WoWTools_WorldMapMixin:Init_XY_Player()
        end,
        name= WoWTools_DataMixin.Icon.Player,
        minValue=6,
        maxValue=72,
        step=1,
        bit=nil,
    })

--Background
    root:CreateSpacer()
    WoWTools_MenuMixin:BgAplha(root,
    function()
        return Save().PlayerXY_BGAlpha or 0.5
    end, function(value)
        Save().PlayerXY_BGAlpha= value
        WoWTools_WorldMapMixin:Init_XY_Player()
    end, nil, true)

--缩放
    WoWTools_MenuMixin:ScaleRoot(self, root, function()
        return Save().PlayerXY_Scale or 1
    end, function(value)
        Save().PlayerXY_Scale= value
        WoWTools_WorldMapMixin:Init_XY_Player()
    end, function()--重置
        Save().PlayerXY_Scale= nil
        Save().PlayerXYPoint= nil
        Save().PlayerXY_Size= nil
        Save().PlayerXY_Text_toLeft= nil
        Save().PlayerXY_Elapsed= nil
        Save().PlayerXY_BGAlpha= nil
        Save().PlayerXY_TextY= nil
        WoWTools_WorldMapMixin:Init_XY_Player()
    end)



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
        Save().ShowMapID= not Save().ShowMapID and true or nil
        WoWTools_WorldMapMixin:Init_MpaID()
    end)

    WoWTools_MenuMixin:ScaleRoot(self, sub, function()
        return Save().MapIDScale or 1
    end, function(value)
        Save().MapIDScale= value
        WoWTools_WorldMapMixin:Init_MpaID()
    end, function()
        Save().MapIDScale=1
        WoWTools_WorldMapMixin:Init_MpaID()
    end)



--地图坐标
    sub= root:CreateCheckbox(
        (WoWTools_DataMixin.onlyChinese and '地图' or WORLD_MAP)..' XY',
    function()
        return Save().ShowMapXY
    end, function()
        Save().ShowMapXY= not Save().ShowMapXY and true or nil
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

    sub:CreateSpacer()--Y
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

    WoWTools_MenuMixin:ScaleRoot(self, sub, function()--缩放
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
        return Save().ShowPlayerXY
    end, function()
        Save().ShowPlayerXY= not Save().ShowPlayerXY and true or nil
        WoWTools_WorldMapMixin:Init_XY_Player()
    end)

    if _G['WoWToolsPlayerXYButton'] then--实时玩家当前坐标，选项
        Init_PlayerXY_Option_Menu(self, sub)
    end
    root:CreateDivider()

--AreaPOI名称
    sub=root:CreateCheckbox(
        '|A:minimap-genericevent-hornicon:0:0|aAreaPOI',
    function()
        return Save().ShowAreaPOI_Name
    end, function()
        Save().ShowAreaPOI_Name= not Save().ShowAreaPOI_Name and true or nil
        WoWTools_WorldMapMixin:Init_AreaPOI_Name()
    end,sub)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '显示名称' or PROFESSIONS_FLYOUT_SHOW_NAME)
        tooltip:AddLine(
            (Save().ShowAreaPOI_Name and '' or '|cff626262')
            ..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        )
    end)

--地下城，加名称
    sub=root:CreateCheckbox(
        '|A:Dungeon:0:0|a'..(WoWTools_DataMixin.onlyChinese and '地下城' or DUNGEONS),
    function()
        return Save().ShowDungeon_Name
    end, function()
        Save().ShowDungeon_Name= not Save().ShowDungeon_Name and true or nil
        WoWTools_WorldMapMixin:Init_Dungeon_Name()--地下城，加名称
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '显示名称' or PROFESSIONS_FLYOUT_SHOW_NAME)
        tooltip:AddLine(
            (Save().ShowDungeon_Name and '' or '|cff626262')
            ..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        )
    end)


--世界地图任务，加名称
    sub=root:CreateCheckbox(
        '|A:Quest-Campaign-Available:0:0|a'..(WoWTools_DataMixin.onlyChinese and '世界任务' or WORLD_MAP_FILTER_LABEL_WORLD_QUESTS_SUBMENU),
    function()
        return Save().ShowWorldQues_Name
    end, function()
        Save().ShowWorldQues_Name= not Save().ShowWorldQues_Name and true or nil
        WoWTools_WorldMapMixin:Init_WorldQuest_Name()--世界地图任务，加名称
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '显示图标' or SELF_HIGHLIGHT_ICON)
        tooltip:AddLine(
            (Save().ShowWorldQues_Name and '' or '|cff626262')
            ..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        )
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
    local MenuButton= WoWTools_ButtonMixin:Menu(WorldMapFrame.BorderFrame.TitleContainer, {name='WoWTools_PlusWorldMap_MenuButton'})

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



function WoWTools_WorldMapMixin:Init_PlayerXY_Option_Menu(...)
    Init_PlayerXY_Option_Menu(...)
end


function WoWTools_WorldMapMixin:Init_Menu()
    Init()
    Init_Set_Title()
end