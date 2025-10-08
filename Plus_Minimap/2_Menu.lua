local function Save()
    return  WoWToolsSave['Minimap_Plus']
end











local function Init_Plus_Menu(self, root)
    local sub

--要塞，图标，移动/隐藏，选项
    WoWTools_MinimapMixin:ExpansionLanding_Menu(self, root)

    root:CreateDivider()

--追踪 AreaPoiID
    sub= root:CreateCheckbox(
        '|A:VignetteKillElite:0:0|a'..(WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING)..' AreaPoi',
    function()
        return Save().vigentteButton
    end, function()
        Save().vigentteButton= not Save().vigentteButton and true or nil
        WoWTools_MinimapMixin:Init_TrackButton()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('AreaPoiID')
        tooltip:AddLine('WorldQuest')
        tooltip:AddLine('Vignette')
        --tooltip:AddLine(' ')
        --tooltip:AddLine('|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '内存会不断增加' or 'Memory will continue to increase')..' (Bug)')
    end)

--追踪 AreaPoiID 菜单
    --WoWTools_MinimapMixin:Init_TrackButton_Menu(self, sub)
    sub:SetEnabled(not IsInInstance() and not WoWTools_MapMixin:IsInDelve())

--镜头视野范围
    sub=root:CreateCheckbox(
        '|A:common-icon-zoomin:0:0|a'..(WoWTools_DataMixin.onlyChinese and '镜头视野范围' or CAMERA_FOV),
    function()
        return Save().ZoomOutInfo
    end, function()
        Save().ZoomOutInfo= not Save().ZoomOutInfo and true or false
        WoWTools_MinimapMixin:Init_Minimap_Zoom()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(
            (WoWTools_DataMixin.onlyChinese and '镜头视野范围' or CAMERA_FOV),
            format(WoWTools_DataMixin.onlyChinese and '%s码' or IN_GAME_NAVIGATION_RANGE, format('%i', C_Minimap.GetViewRadius() or 100))
        )
    end)

--缩小地图
    sub=root:CreateCheckbox(
        '|A:UI-HUD-Minimap-Zoom-Out:0:0|a'..(WoWTools_DataMixin.onlyChinese and '缩小地图' or BINDING_NAME_MINIMAPZOOMOUT),
    function()
        return Save().ZoomOut
    end, function()
---@diagnostic disable-next-line: assign-type-mismatch
        Save().ZoomOut= not Save().ZoomOut and 'min' or nil
        WoWTools_MinimapMixin:Init_Minimap_Zoom()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '更新地区时' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UPDATE, ZONE))
    end)
    WoWTools_MinimapMixin:Zoom_Menu(self, sub)

--地下城难度
    sub=root:CreateCheckbox(
        '|A:DungeonSkull:0:0|a'..(WoWTools_DataMixin.onlyChinese and '地下城难度' or DUNGEON_DIFFICULTY),
    function()
        return not Save().disabledInstanceDifficulty
    end, function()
        Save().disabledInstanceDifficulty= not Save().disabledInstanceDifficulty and true or nil
        print(
            WoWTools_MinimapMixin.addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_TextMixin:GetEnabeleDisable(not Save().disabledInstanceDifficulty),
            WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
        )
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MinimapMixin:InstanceDifficulty_Tooltip(nil, tooltip)
    end)

--CVar 镇民
    root:CreateDivider()
    sub=root:CreateCheckbox(
        '|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..(WoWTools_DataMixin.onlyChinese and '镇民' or TOWNSFOLK_TRACKING_TEXT),
    function()
        return C_CVar.GetCVarBool("minimapTrackingShowAll")
    end, function()
        if not InCombatLockdown() then
            C_CVar.SetCVar('minimapTrackingShowAll', not C_CVar.GetCVarBool("minimapTrackingShowAll") and '1' or '0' )
        end
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING)
        tooltip:AddLine(
        [[SetCVar("minimapTrackingShowAll", "1")]])
    end)

--收集图标
    sub= root:CreateCheckbox(
        WoWTools_DataMixin.Icon.icon2
        ..'|cnWARNING_FONT_COLOR:'
        ..(WoWTools_DataMixin.onlyChinese and '收集图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WEEKLY_REWARDS_GET_CONCESSION, EMBLEM_SYMBOL)),
    function ()
        return not Save().Icons.disabled
    end, function()
        Save().Icons.disabled= not Save().Icons.disabled and true or nil
        WoWTools_MinimapMixin:Init_Collection_Icon()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_TextMixin:GetEnabeleDisable(nil, true))
    end)

if Save().Icons.disabled then
--过滤 Border 透明度
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().Icons.borderAlpha2 or 0
        end, setValue=function(value)
            Save().Icons.borderAlpha2=value
            WoWTools_MinimapMixin:Init_SetMinamp_Texture()
        end,
        name=WoWTools_DataMixin.onlyChinese and '外框透明度' or 'Border alpha',
        minValue=0,
        maxValue=1,
        step=0.05,
        bit='%0.2f',
    })
    sub:CreateSpacer()

--过滤 Bg Alpha
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().Icons.bgAlpha2 or 0.5
        end, setValue=function(value)
            Save().Icons.bgAlpha2=value
            WoWTools_MinimapMixin:Init_SetMinamp_Texture()
        end,
        name=WoWTools_DataMixin.onlyChinese and '背景透明度' or 'Background alpha',
        minValue=0,
        maxValue=1,
        step=0.05,
        bit='%0.2f',
    })
    sub:CreateSpacer()
end

end


















--主菜单
local function Init_Menu(self, root)
--战斗中，不显示
    if WoWTools_MenuMixin:CheckInCombat(root) then
        return
    end

    local sub
--要塞，菜单
    WoWTools_MinimapMixin:Garrison_Menu(self, root)

--派系，菜单
    WoWTools_MinimapMixin:Faction_Menu(self, root)


    root:CreateDivider()

--Plus
    --[[local sub= root:CreateButton(
        string.match(WoWTools_MinimapMixin.addName, '(|A:.-|a)')
        ..'Plus',
    function()
        return MenuResponse.Open
    end)]]

--打开，选项
    sub= WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_MinimapMixin.addName})

--Plus
    Init_Plus_Menu(self, sub)
end











function WoWTools_MinimapMixin:Open_Menu(frame)
    MenuUtil.CreateContextMenu(frame, Init_Menu)
end

