WoWTools_WorldMapMixin={}

function WoWTools_WorldMapMixin:Refresh()
    if not WoWTools_FrameMixin:IsLocked(WorldMapFrame) and WorldMapFrame:IsShown() then
        WorldMapFrame:RefreshOverlayFrames()
    end
end

function WoWTools_WorldMapMixin:GetMapID()
    return WorldMapFrame.mapID or C_Map.GetBestMapForUnit("player")
end


--AreaLabelDataProvider.xml
function WoWTools_WorldMapMixin:Create_Wolor_Font(frame, size)
  return WoWTools_LabelMixin:Create(frame, {
        size=size,
        justifyH='CENTER',
        color=false,
        notShadow=true,
        fontName='WorldMapTextFont'}
    )--WorldMapTextFont SubZoneTextFont
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
        print(WoWTools_DataMixin.onlyChinese and '当前地图不能标记' or "Cannot set waypoints on this map")
    end
end
