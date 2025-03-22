
local id, e = ...

WoWTools_MinimapMixin={
Save={
    scale=WoWTools_DataMixin.Player.husandro and 1 or 0.85,
    ZoomOut=true,--更新地区时,缩小化地图
    ZoomOutInfo=true,--小地图, 缩放, 信息

    vigentteButton=WoWTools_DataMixin.Player.husandro,
    vigentteButtonShowText=true,
    vigentteSound= WoWTools_DataMixin.Player.husandro,--播放声音
    vigentteButtonTextScale=1,
    hideVigentteCurrentOnMinimap=nil,--当前，小地图，标记
    hideVigentteCurrentOnWorldMap=nil,--当前，世界地图，标记
    questIDs={},--世界任务, 监视, ID {[任务ID]=true}
    areaPoiIDs={[7943]= 2248},--{[areaPoiID]= 地图ID}
    uiMapIDs= {},--地图ID 监视, areaPoiIDs，
    currentMapAreaPoiIDs=true,--当前地图，监视, areaPoiIDs，
    textToDown= WoWTools_DataMixin.Player.husandro,--文本，向下

    miniMapPoint={},--保存小图地, 按钮位置

    --disabledInstanceDifficulty=true,--副本，难图，指示
    --hideMPortalRoomLabels=true,--'10.2 副本，挑战专送门'


    --时钟
    useServerTimer=true,--小时图，使用服务器, 时间

    --秒表
    StopwatchOnClickPause=WoWTools_DataMixin.Player.husandro,--移过暂停

    hideExpansionLandingPageMinimapButton= true,--隐藏，图标
    --moveExpansionLandingPageMinimapButton=true,--移动动图标

    moving_over_Icon_show_menu=WoWTools_DataMixin.Player.husandro,--移过图标时，显示菜单
    --hide_MajorFactionRenownFrame_Button=true,--隐藏，派系声望，列表，图标
    --MajorFactionRenownFrame_Button_Scale=1,--缩放
},
--addName= '|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..HUD_EDIT_MODE_MINIMAP_LABEL,
--addName2= '|A:VignetteKillElite:0:0|a'..TRACKING,
}


local addName
local function Save()
    return  WoWTools_MinimapMixin.Save
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

--选项
    sub=WoWTools_MenuMixin:OpenOptions(root, {
        name=self.addName,
        --GetCategory=function()
    })

--要塞，图标，移动/隐藏，选项
    WoWTools_MinimapMixin:ExpansionLanding_Menu(self, sub)

    sub:CreateDivider()

--追踪 AreaPoiID
    sub2= sub:CreateCheckbox(
        '|A:VignetteKillElite:0:0|a'..(WoWTools_Mixin.onlyChinese and '追踪' or TRACKING)..' AreaPoi',
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
        --tooltip:AddLine('|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '内存会不断增加' or 'Memory will continue to increase')..' (Bug)')
    end)

--追踪 AreaPoiID 菜单
    --WoWTools_MinimapMixin:Init_TrackButton_Menu(self, sub2)
    sub2:SetEnabled(not IsInInstance() and not WoWTools_MapMixin:IsInDelve())

--镜头视野范围
    sub2=sub:CreateCheckbox(
        '|A:common-icon-zoomin:0:0|a'..(WoWTools_Mixin.onlyChinese and '镜头视野范围' or CAMERA_FOV),
    function()
        return Save().ZoomOutInfo
    end, function()
        Save().ZoomOutInfo= not Save().ZoomOutInfo and true or nil
        WoWTools_MinimapMixin:Init_Minimap_Zoom()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(
            (WoWTools_Mixin.onlyChinese and '镜头视野范围' or CAMERA_FOV),
            format(WoWTools_Mixin.onlyChinese and '%s码' or IN_GAME_NAVIGATION_RANGE, format('%i', C_Minimap.GetViewRadius() or 100))
        )
    end)


--缩小地图
    sub2=sub:CreateCheckbox(
        '|A:UI-HUD-Minimap-Zoom-Out:0:0|a'..(WoWTools_Mixin.onlyChinese and '缩小地图' or BINDING_NAME_MINIMAPZOOMOUT),
    function()
        return Save().ZoomOut
    end, function()
        Save().ZoomOut= not Save().ZoomOut and 'min' or nil
        WoWTools_MinimapMixin:Init_Minimap_Zoom()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '更新地区时' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UPDATE, ZONE))
    end)
    WoWTools_MinimapMixin:Zoom_Menu(self, sub2)

--地下城难度
    sub2=sub:CreateCheckbox(
        '|A:DungeonSkull:0:0|a'..(WoWTools_Mixin.onlyChinese and '地下城难度' or DUNGEON_DIFFICULTY),
    function()
        return not Save().disabledInstanceDifficulty
    end, function()
        Save().disabledInstanceDifficulty= not Save().disabledInstanceDifficulty and true or nil
            print(WoWTools_DataMixin.Icon.icon2.. addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabledInstanceDifficulty), WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    )
    sub2:SetTooltip(function(tooltip)
        WoWTools_MinimapMixin:InstanceDifficulty_Tooltip(nil, tooltip)
    end)

--CVar 镇民
    sub:CreateDivider()
    sub2=sub:CreateCheckbox(
        '|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..(WoWTools_Mixin.onlyChinese and '镇民' or TOWNSFOLK_TRACKING_TEXT),
    function()
        return C_CVar.GetCVarBool("minimapTrackingShowAll")
    end, function()
        C_CVar.SetCVar('minimapTrackingShowAll', not C_CVar.GetCVarBool("minimapTrackingShowAll") and '1' or '0' )
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '追踪' or TRACKING)
        tooltip:AddLine(
        [[SetCVar("minimapTrackingShowAll", "1")]])
    end)
end



















function WoWTools_MinimapMixin:Open_Menu(frame)
    MenuUtil.CreateContextMenu(frame, Init_Menu)
end

--打开选项界面
function WoWTools_MinimapMixin:OpenPanel(root)
    return WoWTools_MenuMixin:OpenOptions(root, {name=addName})
end

















local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWTools_MinimapMixin.Save= WoWToolsSave['Minimap_Plus'] or WoWTools_MinimapMixin.Save

            addName='|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..(WoWTools_Mixin.onlyChinese and '小地图' or HUD_EDIT_MODE_MINIMAP_LABEL)
            WoWTools_MinimapMixin.addName= addName
            WoWTools_MinimapMixin.addName2= '|A:VignetteKillElite:0:0|a'..(WoWTools_Mixin.onlyChinese and '追踪' or TRACKING)

           WoWTools_PanelMixin:Check_Button({
                checkName= addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(WoWTools_DataMixin.Icon.icon2.. addName, WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end,
                buttonText= WoWTools_Mixin.onlyChinese and '重置位置' or RESET_POSITION,
                buttonFunc= function()
                    if StopwatchFrame.rest_point then
                        StopwatchFrame:rest_point()
                    end
                    WoWTools_MinimapMixin:Rest_TimeManager_Point()--重置，TimeManager位置
                    WoWTools_MinimapMixin:Rest_TrackButton_Point()--重置，TrackButton位置
                    print(WoWTools_DataMixin.Icon.icon2.. addName, WoWTools_Mixin.onlyChinese and '重置位置' or RESET_POSITION)
                end
            })

            if Save().disabled then
                self:UnregisterEvent(event)
            else
                for questID in pairs(Save().questIDs or {}) do
                    WoWTools_Mixin:Load({id= questID, type=='quest'})
                end

                WoWTools_MinimapMixin:Init_InstanceDifficulty()--副本，难度，指示
                WoWTools_MinimapMixin:Init_TrackButton()--小地图, 标记, 文本
                WoWTools_MinimapMixin:Init_Icon()--添加，图标
                WoWTools_MinimapMixin:Init_ExpansionLanding()
                WoWTools_MinimapMixin:Init_Minimap_Zoom()--缩放数值, 缩小化地图
            end

        elseif arg1=='Blizzard_TimeManager' then
            WoWTools_MinimapMixin:Init_TimeManager()--秒表
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Minimap_Plus']=Save()
        end
    end
end)