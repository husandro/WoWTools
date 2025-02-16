local id, e = ...

WoWTools_WorldMapMixin={
Save={
    ShowMapID= true,--地图ID
    --MapIDScale=1,

    HideTitle=e.Player.husandro,--隐藏，标题

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
},
--WoWTools_WorldMapMixin.addName= e.onlyChinese and '地图' or WORLD_MAP
}



--AreaLabelDataProvider.xml
function WoWTools_WorldMapMixin:Create_Wolor_Font(frame, size)
    local font= WoWTools_LabelMixin:Create(frame, {
        size=size,
        justifyH='CENTER',
        color=false,
        fontName='WorldMapTextFont'}
    )--WorldMapTextFont SubZoneTextFont
    return font
end




--玩家当前位置
function WoWTools_WorldMapMixin:GetPlayerXY()
    local uiMapID= C_Map.GetBestMapForUnit("player")--当前地图        
    if uiMapID then
        local position = C_Map.GetPlayerMapPosition(uiMapID, "player")
        if position then
            local x, y
            x,y=position:GetXY()
            if x and y then
                x= format('%.2f', x*100)
                y= format('%.2f', y*100)
                return x, y
            end
        end
    end
end




function WoWTools_WorldMapMixin:SendPlayerPoint()--发送玩家位置
    local mapID = C_Map.GetBestMapForUnit("player")
    if mapID then
        if  C_Map.CanSetUserWaypointOnMap(mapID) then
            local point= C_Map.GetUserWaypoint()
            local pos= C_Map.GetPlayerMapPosition(mapID, "player")
            local mapPoint = UiMapPoint.CreateFromVector2D(mapID, pos)
            C_Map.SetUserWaypoint(mapPoint)
            WoWTools_ChatMixin:Chat(C_Map.GetUserWaypointHyperlink(), nil, true)
            --ChatFrame_OpenChat(SELECTED_DOCK_FRAME.editBox:GetText()..C_Map.GetUserWaypointHyperlink())
            if point then
                C_Map.SetUserWaypoint(point)
            else
                C_Map.ClearUserWaypoint()
            end
            return
        else
            local x, y= self:GetPlayerXY()--玩家当前位置
            if x and y then
                local pointText=x..' '..y
                local info=C_Map.GetMapInfo(mapID)
                if info and info.name then
                    pointText=pointText..' '..info.name
                end
                WoWTools_ChatMixin:Chat(pointText, nil, true)
                --ChatFrame_OpenChat(SELECTED_DOCK_FRAME.editBox:GetText()..pointText)
                return
            end
        end
    end
    local name= GetMinimapZoneText()
    local name2
    if mapID then
        local info=C_Map.GetMapInfo(mapID)
        name2=info and info.name
    end
    if name  or name2 then
        if name2 and name~=name2 then
            name=name2..'('..name..')'
        end
        name =name or name2
        WoWTools_ChatMixin:Chat(name, nil, true)
    else
        print(e.onlyChinese and '当前地图不能标记' or "Cannot set waypoints on this map")
    end
end






local function Init()
    WoWTools_WorldMapMixin:Init_Menu()--设置菜单
    WoWTools_WorldMapMixin:Init_MpaID()--地图ID，信息
    WoWTools_WorldMapMixin:Init_XY_Map()--地图坐标
    WoWTools_WorldMapMixin:Init_XY_Player()--实时玩家当前坐标

    WoWTools_WorldMapMixin:Init_AreaPOI_Name()--地图POI提示，加名称
    WoWTools_WorldMapMixin:Init_Dungeon_Name()--地下城，加名称
    WoWTools_WorldMapMixin:Init_WorldQuest_Name()--世界地图任务，加名称

    WoWTools_WorldMapMixin:Init_Plus_Menu()--设置菜单
    WoWTools_WorldMapMixin:Init_Plus_SearchBox()
end






EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(_, arg1)
	if arg1==id then
        WoWTools_WorldMapMixin.Save= WoWToolsSave['Plus_WorldMap'] or WoWTools_WorldMapMixin.Save
        WoWToolsSave[WORLD_MAP]= nil

        WoWTools_WorldMapMixin.addName= '|A:poi-islands-table:0:0|a'..(e.onlyChinese and '世界地图' or WORLDMAP_BUTTON)
        --WoWTools_WorldMapMixin.addName2= e.onlyChinese and '时实坐标' or RESET_POSITION:gsub(RESET, PLAYER)

        --添加控制面板
        e.AddPanel_Check({
            name= WoWTools_WorldMapMixin.addName,
            tooltip=  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD,
            GetValue= function() return not WoWTools_WorldMapMixin.Save.disabled end,
            func= function()
                WoWTools_WorldMapMixin.Save.disabled= not WoWTools_WorldMapMixin.Save.disabled and true or nil
                print(
                    WoWTools_Mixin.addName,
                    WoWTools_WorldMapMixin.addName,
                    e.GetEnabeleDisable(not WoWTools_WorldMapMixin.Save.disabled),
                    e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                )
            end
        })

        if not WoWTools_WorldMapMixin.Save.disabled then
            Init()
        end

    elseif arg1=='Blizzard_FlightMap' then--飞行点，加名称
        if not WoWTools_WorldMapMixin.Save.disabled then
            WoWTools_WorldMapMixin:Init_FlightMap_Name()--飞行点，加名称
        end
    end
end)



EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGOUT", function()
	if not e.ClearAllSave then
		WoWToolsSave['Plus_WorldMap']= WoWTools_WorldMapMixin.Save
	end
end)


--[[
local panel=CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            WoWTools_WorldMapMixin.Save= WoWToolsSave['Plus_WorldMap'] or WoWTools_WorldMapMixin.Save
            WoWToolsSave[WORLD_MAP]= nil

            WoWTools_WorldMapMixin.addName= '|A:poi-islands-table:0:0|a'..(e.onlyChinese and '世界地图' or WORLDMAP_BUTTON)
            --WoWTools_WorldMapMixin.addName2= e.onlyChinese and '时实坐标' or RESET_POSITION:gsub(RESET, PLAYER)

            --添加控制面板
            e.AddPanel_Check({
                name= WoWTools_WorldMapMixin.addName,
                tooltip=  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD,
                GetValue= function() return not WoWTools_WorldMapMixin.Save.disabled end,
                func= function()
                    WoWTools_WorldMapMixin.Save.disabled= not WoWTools_WorldMapMixin.Save.disabled and true or nil
                    print(
                        WoWTools_Mixin.addName,
                        WoWTools_WorldMapMixin.addName,
                        e.GetEnabeleDisable(not WoWTools_WorldMapMixin.Save.disabled),
                        e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                    )
                end
            })

            if WoWTools_WorldMapMixin.Save.disabled then
                self:UnregisterAllEvents()
            else
                Init()
            end
            self:RegisterEvent("PLAYER_LOGOUT")



        elseif arg1=='Blizzard_FlightMap' then--飞行点，加名称
            WoWTools_WorldMapMixin:Init_FlightMap_Name()--飞行点，加名称
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_WorldMap']= WoWTools_WorldMapMixin.Save
        end
    end
end)
]]