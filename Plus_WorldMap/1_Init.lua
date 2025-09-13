local P_Save={
    ShowMapID= true,--地图ID
    --MapIDScale=1,

    HideTitle=WoWTools_DataMixin.Player.husandro,--隐藏，标题

    ShowMapXY= true,--地图坐标
    --MapXYScale=1,
    --MapXY_W
    --MapXY_X=72,
    --MapXY_Y=-2,

    --ShowPlayerXY=false,--实时玩家当前坐标
    --PlayerXYPoint={},
    --PlayerXY_Scale=1,
    --PlayerXY_Strata
    --PlayerXY_Text_toLeft=true,
    --PlayerXY_Size=12

    ShowAreaPOI_Name=true,
    ShowDungeon_Name=true,
    ShowWorldQues_Name=true,
    --ShowFlightMap_Name=true,
    --[[Abandon={
        filter={
            Complete=true,
            Campaign=true,
            Important=true,
            Legendary=true,
            Calling=true,
        }
    },]]
}







local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWToolsSave['Plus_WorldMap']= WoWToolsSave['Plus_WorldMap'] or P_Save
            P_Save= nil

            WoWTools_WorldMapMixin.addName= '|A:poi-islands-table:0:0|a'..(WoWTools_DataMixin.onlyChinese and '世界地图' or WORLDMAP_BUTTON)
            --WoWTools_WorldMapMixin.addName2= WoWTools_DataMixin.onlyChinese and '时实坐标' or RESET_POSITION:gsub(RESET, PLAYER)

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_WorldMapMixin.addName,
                tooltip=  WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD,
                GetValue= function() return not  WoWToolsSave['Plus_WorldMap'].disabled end,
                func= function()
                     WoWToolsSave['Plus_WorldMap'].disabled= not  WoWToolsSave['Plus_WorldMap'].disabled and true or nil
                    print(
                        WoWTools_DataMixin.addName,
                        WoWTools_WorldMapMixin.addName,
                        WoWTools_TextMixin:GetEnabeleDisable(not  WoWToolsSave['Plus_WorldMap'].disabled),
                        WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                    )
                end
            })

            if  WoWToolsSave['Plus_WorldMap'].disabled then
                self:UnregisterEvent(event)
            else
                WoWTools_WorldMapMixin:Init_Menu()--设置菜单
                WoWTools_WorldMapMixin:Init_MpaID()--地图ID，信息
                WoWTools_WorldMapMixin:Init_XY_Map()--地图坐标
                WoWTools_WorldMapMixin:Init_XY_Player()--实时玩家当前坐标

                WoWTools_WorldMapMixin:Init_AreaPOI_Name()--地图POI提示，加名称
                WoWTools_WorldMapMixin:Init_Dungeon_Name()--地下城，加名称
                WoWTools_WorldMapMixin:Init_WorldQuest_Name()--世界地图任务，加名称

                WoWTools_WorldMapMixin:Init_Plus_Menu()--设置菜单
                WoWTools_WorldMapMixin:Init_Plus_SearchBox()

                if C_AddOns.IsAddOnLoaded('Blizzard_FlightMap') then
                    self:UnregisterEvent(event)
                end
            end

        elseif arg1=='Blizzard_FlightMap' then--飞行点，加名称
            WoWTools_WorldMapMixin:Init_FlightMap_Name()--飞行点，加名称
            self:UnregisterEvent(event)
        end
    end
end)