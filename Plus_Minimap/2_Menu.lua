local function Save()
    return  WoWToolsSave['Minimap_Plus']
end



--主菜单
local function Init_Menu(self, root)
--战斗中，不显示
    if WoWTools_MenuMixin:CheckInCombat(root) then
        return
    end

    local sub, sub2

--要塞，菜单
    WoWTools_MinimapMixin:Garrison_Menu(self, root)

--派系，菜单
    WoWTools_MinimapMixin:Faction_Menu(self, root)

    root:CreateDivider()

    sub= root:CreateButton('Plus', function() return MenuResponse.Open end)

--要塞，图标，移动/隐藏，选项
    WoWTools_MinimapMixin:ExpansionLanding_Menu(self, sub)

    sub:CreateDivider()

--追踪 AreaPoiID
    sub2= sub:CreateCheckbox(
        '|A:VignetteKillElite:0:0|a'..(WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING)..' AreaPoi',
    function()
        return Save().vigentteButton
    end, function()
        Save().vigentteButton= not Save().vigentteButton and true or nil
        WoWTools_MinimapMixin:Init_TrackButton()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('AreaPoiID')
        tooltip:AddLine('WorldQuest')
        tooltip:AddLine('Vignette')
        --tooltip:AddLine(' ')
        --tooltip:AddLine('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '内存会不断增加' or 'Memory will continue to increase')..' (Bug)')
    end)

--追踪 AreaPoiID 菜单
    --WoWTools_MinimapMixin:Init_TrackButton_Menu(self, sub2)
    sub2:SetEnabled(not IsInInstance() and not WoWTools_MapMixin:IsInDelve())

--镜头视野范围
    sub2=sub:CreateCheckbox(
        '|A:common-icon-zoomin:0:0|a'..(WoWTools_DataMixin.onlyChinese and '镜头视野范围' or CAMERA_FOV),
    function()
        return Save().ZoomOutInfo
    end, function()
        Save().ZoomOutInfo= not Save().ZoomOutInfo and true or nil
        WoWTools_MinimapMixin:Init_Minimap_Zoom()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(
            (WoWTools_DataMixin.onlyChinese and '镜头视野范围' or CAMERA_FOV),
            format(WoWTools_DataMixin.onlyChinese and '%s码' or IN_GAME_NAVIGATION_RANGE, format('%i', C_Minimap.GetViewRadius() or 100))
        )
    end)


--缩小地图
    sub2=sub:CreateCheckbox(
        '|A:UI-HUD-Minimap-Zoom-Out:0:0|a'..(WoWTools_DataMixin.onlyChinese and '缩小地图' or BINDING_NAME_MINIMAPZOOMOUT),
    function()
        return Save().ZoomOut
    end, function()
        Save().ZoomOut= not Save().ZoomOut and 'min' or nil
        WoWTools_MinimapMixin:Init_Minimap_Zoom()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '更新地区时' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UPDATE, ZONE))
    end)
    WoWTools_MinimapMixin:Zoom_Menu(self, sub2)

--地下城难度
    sub2=sub:CreateCheckbox(
        '|A:DungeonSkull:0:0|a'..(WoWTools_DataMixin.onlyChinese and '地下城难度' or DUNGEON_DIFFICULTY),
    function()
        return not Save().disabledInstanceDifficulty
    end, function()
        Save().disabledInstanceDifficulty= not Save().disabledInstanceDifficulty and true or nil
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_MinimapMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabledInstanceDifficulty), WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    )
    sub2:SetTooltip(function(tooltip)
        WoWTools_MinimapMixin:InstanceDifficulty_Tooltip(nil, tooltip)
    end)

--CVar 镇民
    sub:CreateDivider()
    sub2=sub:CreateCheckbox(
        '|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..(WoWTools_DataMixin.onlyChinese and '镇民' or TOWNSFOLK_TRACKING_TEXT),
    function()
        return C_CVar.GetCVarBool("minimapTrackingShowAll")
    end, function()
        C_CVar.SetCVar('minimapTrackingShowAll', not C_CVar.GetCVarBool("minimapTrackingShowAll") and '1' or '0' )
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING)
        tooltip:AddLine(
        [[SetCVar("minimapTrackingShowAll", "1")]])
    end)

    sub2= sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '收集图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC,  WEEKLY_REWARDS_GET_CONCESSION, EMBLEM_SYMBOL),
    function()
        Save().collectionIcon= not Save().collectionIcon and true or nil
        WoWTools_MinimapMixin:Init_Collection_Icon()
    end)
    sub:CreateDivider()
--选项
    WoWTools_MenuMixin:OpenOptions(sub, {
        name= WoWTools_MinimapMixin.addName,
        --GetCategory=function()
    })
end











function WoWTools_MinimapMixin:Open_Menu(frame)
    MenuUtil.CreateContextMenu(frame, Init_Menu)
end