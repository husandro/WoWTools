local id, e = ...
local addName =WORLD_MAP
local addName2=RESET_POSITION:gsub(RESET, PLAYER)
local Save={}

local function getPlayerXY()--当前世界地图位置
    local uiMapID= C_Map.GetBestMapForUnit("player")--当前地图        
    if uiMapID then
        local position = C_Map.GetPlayerMapPosition(uiMapID, "player")
        if position then
            local x,y=position:GetXY()
            if x and y then
                x=('%.1f'):format(x*100)
                y=('%.1f'):format(y*100)
                return x, y
            end
        end
    end
end
local function sendPlayerPoint()--发送玩家位置
    local mapID = C_Map.GetBestMapForUnit("player")
    if mapID and C_Map.CanSetUserWaypointOnMap(mapID) then
        local point=C_Map.GetUserWaypoint()
        local pos = C_Map.GetPlayerMapPosition(mapID, "player")
        local mapPoint = UiMapPoint.CreateFromVector2D(mapID, pos)
        C_Map.SetUserWaypoint(mapPoint)
        ChatFrame_OpenChat(SELECTED_DOCK_FRAME.editBox:GetText()..C_Map.GetUserWaypointHyperlink())
        if point then
            C_Map.SetUserWaypoint(point)
        else
            C_Map.ClearUserWaypoint()
        end
    else
        local name=GetMinimapZoneText()
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
            ChatFrame_OpenChat(SELECTED_DOCK_FRAME.editBox:GetText()..name)
        else
            print("Cannot set waypoints on this map")
        end
    end
end

local function CursorPositionInt()
    local frame=WorldMapFrame
    if not Save.PlayerXY or frame.playerPostionBtn then
        if frame.playerPostionBtn then
            frame.playerPostionBtn:SetShown(Save.PlayerXY)
        end
        return
    end
    frame.playerPostionBtn=CreateFrame('Button', nil, UIParent)--实时玩家当前坐标
    frame.playerPostionBtn:SetHighlightAtlas(e.Icon.highlight)
    frame.playerPostionBtn:SetPushedAtlas(e.Icon.pushed)
    if not Save.PlayerXYPoint then
        frame.playerPostionBtn:SetPoint('BOTTOMRIGHT', frame, 'TOPRIGHT',-50, 5)
    else
        frame.playerPostionBtn:SetPoint(Save.PlayerXYPoint[1], UIParent, Save.PlayerXYPoint[3], Save.PlayerXYPoint[4], Save.PlayerXYPoint[5])
    end
    frame.playerPostionBtn:SetSize(12,12)
    frame.playerPostionBtn:RegisterForClicks("LeftButtonDown","RightButtonDown")
    frame.playerPostionBtn:EnableMouseWheel(true)
    frame.playerPostionBtn:SetMovable(true)
    frame.playerPostionBtn:RegisterForDrag("RightButton");
    frame.playerPostionBtn:SetClampedToScreen(true);
    frame.playerPostionBtn:SetScript("OnDragStart", function(self2, d)
        if d=='RightButton' and not IsModifierKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
            self2:StartMoving()
        end
    end)
    frame.playerPostionBtn:SetScript("OnDragStop", function(self2, d)
        self2:StopMovingOrSizing()
        Save.PlayerXYPoint={self2:GetPoint(1)}
        print(id, addName, addName2, '|cFF00FF00Alt+'..e.Icon.right..KEY_BUTTON2..'|r: '.. TRANSMOGRIFY_TOOLTIP_REVERT)
        ResetCursor()
    end)
    frame.playerPostionBtn:SetScript("OnMouseUp", function(self2,d)
        if d=='RightButton' and IsAltKeyDown() then
            self2:ClearAllPoints();
            self2:SetPoint('BOTTOMRIGHT', frame, 'TOPRIGHT',-50, 5)
        elseif d=='LeftButton' and not IsModifierKeyDown() then
            sendPlayerPoint()--发送玩家位置
        end
        ResetCursor();
    end);
    frame.playerPostionBtn:SetScript("OnEnter",function(self2)
        if UnitAffectingCombat('player') then
            return
        end
        e.tips:ClearLines()
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:AddDoubleLine(id, addName2)
        e.tips:AddLine(' ')
        local can = C_Map.GetBestMapForUnit("player")
        can= can and C_Map.CanSetUserWaypointOnMap(can)
        e.tips:AddDoubleLine('|A:Waypoint-MapPin-ChatIcon:0:0|a'..RESET_POSITION:gsub(RESET, SEND_LABEL), (not can and GetMinimapZoneText() or not can and '|cnRED_FONT_COLOR:'..NONE..'|r' or '') ..e.Icon.left)
        e.tips:AddDoubleLine(FONT_SIZE..': '..(Save.PlayerXYSize or 12), e.Icon.mid)
        e.tips:AddDoubleLine(NPE_MOVE, e.Icon.right)
        e.tips:Show()
    end)
    frame.playerPostionBtn:SetScript("OnLeave", function()
        e.tips:Hide()
        ResetCursor()
    end)

    frame.playerPostionBtn:SetScript('OnMouseWheel',function(self, d)
        if IsModifierKeyDown() then
            return
        end
        local size=Save.PlayerXYSize or 12
        if d==1 then
            size=size+1
            size = size>72 and 72 or size
        elseif d==-1 then
            size=size-1
            size= size<8 and 8 or size
        end
        Save.PlayerXYSize=size
        e.Cstr(nil, size, nil, self.Text)
        print(id,FONT_SIZE..': '..size)
    end)

    frame.playerPostionBtn.Text=e.Cstr(frame.playerPostionBtn, Save.PlayerXYSize)
    frame.playerPostionBtn.Text:SetPoint('RIGHT')

    local timeElapsed = 0
    frame.playerPostionBtn:HookScript("OnUpdate", function (self, elapsed)
        timeElapsed = timeElapsed + elapsed
        if timeElapsed > 0.3 then
            timeElapsed = 0
            local x, y =getPlayerXY()
            if x and y then
                self.Text:SetText(x.. ' '..y)
            else
                self.Text:SetText('..')
            end
        end
    end)
end

local function setOnEnter(self)--地图ID提示
    local frame=WorldMapFrame
    e.tips:SetOwner(self, "ANCHOR_LEFT")
    e.tips:ClearLines()
    e.tips:AddDoubleLine(id, addName)
    local uiMapID = frame.mapID or frame:GetMapID("current")
    if uiMapID then
        e.tips:AddLine(' ')
        local info = C_Map.GetMapInfo(uiMapID)
        if info then
            e.tips:AddDoubleLine(info.name, 'mapID: '..info.mapID or uiMapID)--地图ID
            local uiMapGroupID = C_Map.GetMapGroupID(uiMapID)
            if uiMapGroupID then
                e.tips:AddDoubleLine(FLOOR, 'uiMapGroupID: '..uiMapGroupID)
            end
        end
        local areaPoiIDs=C_AreaPoiInfo.GetAreaPOIForMap(uiMapID)
        if areaPoiIDs then
            for _,areaPoiID in pairs(areaPoiIDs) do
                local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID)
                if poiInfo and (poiInfo.areaPoiID or poiInfo.widgetSetID) then
                    e.tips:AddDoubleLine((poiInfo.atlasName and '|A:'..poiInfo.atlasName..':0:0|a' or '')
                    .. poiInfo.name
                    ..(poiInfo.widgetSetID and 'widgetSetID: '..poiInfo.widgetSetID or ''),
                    'areaPoiID: '..(poiInfo.areaPoiID or NONE))
                end
            end
        end
        local x,y =getPlayerXY()
        if x and y then
            local playerCursorMapName
            local uiMapIDPlayer= C_Map.GetBestMapForUnit("player")
            if uiMapIDPlayer and uiMapIDPlayer~=uiMapID then
                local info = C_Map.GetMapInfo(uiMapIDPlayer)
                playerCursorMapName=info and info.name
            end
            e.tips:AddLine(' ')
            if playerCursorMapName then
                e.tips:AddDoubleLine(e.Icon.player..playerCursorMapName, 'XY: '..x..' '..y)
            else
                e.tips:AddDoubleLine(RESET_POSITION:gsub(RESET, e.Icon.player), 'XY: '..x..' '..y)
            end
        end
    end
    e.tips:AddLine(' ')
    e.tips:AddDoubleLine(addName..": "..e.GetEnabeleDisable(not Save.disabled), e.Icon.left)
    e.tips:AddDoubleLine(addName2..': '..e.GetEnabeleDisable(Save.PlayerXY), e.Icon.right)
    e.tips:Show()
end

local function setMapIDText(self)
    local m=''
    if not Save.disabled then
        local uiMapID = self.mapID or self:GetMapID("current")
        m= uiMapID or m
        if uiMapID then
            local uiMapGroupID=C_Map.GetMapGroupID(uiMapID)
            if uiMapGroupID then
                m='g'..uiMapGroupID..'  '..m
            end
            local areaPoiIDs=C_AreaPoiInfo.GetAreaPOIForMap(uiMapID)
            if areaPoiIDs then
                for _,areaPoiID in pairs(areaPoiIDs) do
                    local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID)
                    if poiInfo and (poiInfo.areaPoiID or poiInfo.widgetSetID) and poiInfo.atlasName then
                        m='|A:'..poiInfo.atlasName..':0:0|a'..m
                    end
                end
            end
            if not self.mapInfoBtn.mapID then--字符
                self.mapInfoBtn.mapID=e.Cstr(self.BorderFrame.TitleContainer, nil, WorldMapFrameTitleText)
                self.mapInfoBtn.mapID:SetPoint('RIGHT', self.mapInfoBtn, 'LEFT')
            end
        end

        local uiMapIDPlayer= C_Map.GetBestMapForUnit("player")--玩家当前坐标
        local x, y= getPlayerXY(self, uiMapID)
        local playerPositionText
        if uiMapIDPlayer and uiMapIDPlayer==uiMapID and x and y then
            if not self.playerPosition.Text then
                self.playerPosition.Text=e.Cstr(self.playerPosition, nil ,WorldMapFrameTitleText)
                self.playerPosition.Text:SetPoint('LEFT',self.playerPosition, 'RIGHT', 2, 0)
            end
            playerPositionText=x..' '..y..'  '
        end
        if self.playerPosition.Text then
            self.playerPosition.Text:SetText(playerPositionText or '')
        end
    end
    if self.mapInfoBtn.mapID then
        self.mapInfoBtn.mapID:SetText(m)
    end
    self.playerPosition:SetShown(not Save.disabled)
end
local function setMapID(self)--显示地图ID
    if not self.mapInfoBtn then
        self.mapInfoBtn=e.Cbtn(self.BorderFrame.TitleContainer)
        self.mapInfoBtn:SetPoint('RIGHT', self.BorderFrame.TitleContainer, 'RIGHT', -50,0)
        self.mapInfoBtn:SetSize(22,22)
        self.mapInfoBtn:SetNormalAtlas(e.Icon.map)
        self.mapInfoBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        self.mapInfoBtn:SetScript('OnEnter', setOnEnter)
        self.mapInfoBtn:SetScript('OnLeave', function() e.tips:Hide() end)
        self.mapInfoBtn:SetScript('OnClick', function(self2, d)
            if d=="LeftButton" then
                if Save.disabled then
                    Save.disabled=nil
                else
                    Save.disabled=true
                end
                setMapIDText(self)
                print(id, addName, e.GetShowHide(not Save.disabled))
            elseif d=='RightButton' then--实时玩家当前坐标
                if Save.PlayerXY then
                    Save.PlayerXY=nil
                    print(id, addName, addName2..":", e.GetEnabeleDisable(Save.PlayerXY), '|cnGREEN_FONT_COLOR:'..NEED..'/reload|r')
                else
                    Save.PlayerXY=true
                    print(id, addName, addName2..":", e.GetEnabeleDisable(Save.PlayerXY))                   
                end
                CursorPositionInt()
            end
        end)
    end
    if not self.playerPosition then--玩家坐标
        self.playerPosition=e.Cbtn(self.BorderFrame.TitleContainer)
        self.playerPosition:SetPoint('LEFT', self.BorderFrame.TitleContainer, 'LEFT', 95, -2)
        self.playerPosition:SetSize(22, 22)
        self.playerPosition:SetNormalAtlas(e.Icon.player:match('|A:(.-):'))
        self.playerPosition:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        self.playerPosition:SetScript('OnLeave', function() e.tips:Hide() end)
        self.playerPosition:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, addName)
            e.tips:AddLine(' ')
            local can = C_Map.GetBestMapForUnit("player")
            can= can and C_Map.CanSetUserWaypointOnMap(can)
            e.tips:AddDoubleLine('|A:Waypoint-MapPin-ChatIcon:0:0|a'..RESET_POSITION:gsub(RESET, SEND_LABEL), (not can and GetMinimapZoneText() or not can and '|cnRED_FONT_COLOR:'..NONE..'|r' or '')..e.Icon.left)
            e.tips:AddDoubleLine(PREVIOUS..REFORGE_CURRENT..WORLD_MAP, e.Icon.right)
            e.tips:Show()
        end)
        self.playerPosition:SetScript('OnClick', function(self2, d)
            if d=='RightButton' then--返回当前地图                
	            self:SetMapID(MapUtil.GetDisplayableMapForPlayer())
            elseif d=='LeftButton' then
                sendPlayerPoint()--发送玩家位置
            end
        end)
    end
    setMapIDText(self)
end
hooksecurefunc(WorldMapFrame, 'OnMapChanged', setMapID)--Blizzard_WorldMap.lua


--加载保存数据
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save
            CursorPositionInt()

    elseif event == "PLAYER_LOGOUT" then
        if not WoWToolsSave then WoWToolsSave={} end
		WoWToolsSave[addName]=Save
    end
end)