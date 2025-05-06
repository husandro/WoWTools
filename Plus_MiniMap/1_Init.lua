WoWTools_MinimapMixin={}



local P_Save={
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

    Icons={},--收集图标
}



local function Save()
    return  WoWToolsSave['Minimap_Plus']
end













local function Init()
    for questID in pairs(Save().questIDs or {}) do
        WoWTools_Mixin:Load({id= questID, type=='quest'})
    end
    do
        WoWTools_MinimapMixin:Init_Icon()--添加，图标
    end

    WoWTools_MinimapMixin:Init_InstanceDifficulty()--副本，难度，指示
    WoWTools_MinimapMixin:Init_TrackButton()--小地图, 标记, 文本
    WoWTools_MinimapMixin:Init_ExpansionLanding()
    WoWTools_MinimapMixin:Init_Minimap_Zoom()--缩放数值, 缩小化地图

    Init=function()end
end









local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("LOADING_SCREEN_DISABLED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Minimap_Plus']= WoWToolsSave['Minimap_Plus'] or P_Save

            Save().MajorFactionRenownFrame_Button_Scale=nil
			Save().hide_MajorFactionRenownFrame_Button=nil
            Save().Icons= Save().Icons or {}

            WoWTools_MinimapMixin.addName= '|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..(WoWTools_DataMixin.onlyChinese and '小地图' or HUD_EDIT_MODE_MINIMAP_LABEL)
            WoWTools_MinimapMixin.addName2= '|A:VignetteKillElite:0:0|a'..(WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING)

           WoWTools_PanelMixin:Check_Button({
                checkName= WoWTools_MinimapMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    if Save().disabled then
                        print(
                            WoWTools_DataMixin.Icon.icon2..WoWTools_MinimapMixin.addName,
                            WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                        )
                    else
                        Init()
                        WoWTools_MinimapMixin:Init_TimeManager()--秒表
                        WoWTools_MinimapMixin:Init_Collection_Icon()--收集插件图标
                    end

                end,
                buttonText= WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION,
                buttonFunc= function()
                    if StopwatchFrame.rest_point then
                        StopwatchFrame:rest_point()
                    end
                    WoWTools_MinimapMixin:Rest_TimeManager_Point()--重置，TimeManager位置
                    WoWTools_MinimapMixin:Rest_TrackButton_Point()--重置，TrackButton位置
                    print(
                        WoWTools_DataMixin.Icon.icon2..WoWTools_MinimapMixin.addName,
                        WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION
                    )
                end
            })

            if Save().disabled then
                self:UnregisterAllEvents()

            else
                Init()
                
                if C_AddOns.IsAddOnLoaded('Blizzard_TimeManager') then
                    WoWTools_MinimapMixin:Init_TimeManager()--秒表
                    self:UnregisterEvent(event)
                end
            end

        elseif arg1=='Blizzard_TimeManager' and WoWToolsSave then
            WoWTools_MinimapMixin:Init_TimeManager()--秒表
            self:UnregisterEvent(event)
        end

    elseif event=='LOADING_SCREEN_DISABLED' then
        WoWTools_MinimapMixin:Init_Collection_Icon()--收集插件图标
        self:UnregisterEvent(event)
    end
end)