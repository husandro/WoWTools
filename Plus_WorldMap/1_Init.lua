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
    --PlayerXY_Size=23,
    --PlayerXY_Elapsed=0.3,--LAG_TOLERANCE = "延迟容限";
    --PlayerXY_BGAlpha=0.5
    --PlayerXY_TextY=0

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

    --notPlus=true--其它增强 z_Plus.lua
}



local function Save()
    return  WoWToolsSave['Plus_WorldMap']
end




local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWToolsSave['Plus_WorldMap']= WoWToolsSave['Plus_WorldMap'] or P_Save
            P_Save= nil

            WoWTools_WorldMapMixin.addName= '|A:poi-islands-table:0:0|a'..(WoWTools_DataMixin.onlyChinese and '世界地图' or WORLDMAP_BUTTON)

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_WorldMapMixin.addName,
                tooltip=  WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD,
                GetValue= function() return not  Save().disabled end,
                func= function()
                     Save().disabled= not  Save().disabled and true or nil
                    print(
                        WoWTools_DataMixin.addName,
                        WoWTools_WorldMapMixin.addName,
                        WoWTools_TextMixin:GetEnabeleDisable(not  Save().disabled),
                        WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                    )
                end
            })

            if Save().disabled then
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
                WoWTools_WorldMapMixin:Init_Plus()

                if C_AddOns.IsAddOnLoaded('Blizzard_FlightMap') then
                    WoWTools_WorldMapMixin:Init_FlightMap_Name()--飞行点，加名称
                    self:UnregisterEvent(event)
                end
            end

        elseif arg1=='Blizzard_FlightMap' then--飞行点，加名称
            WoWTools_WorldMapMixin:Init_FlightMap_Name()--飞行点，加名称
            self:UnregisterEvent(event)
        end
    end
end)