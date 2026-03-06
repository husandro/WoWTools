local function Save()
    return WoWToolsSave['Plus_WorldMap'].PlayerPin
end
local function SaveWoW()
    return WoWToolsPlayerDate.WorldMapPlayerPin
end
local Button
local function RefreshMapMarkers()
    
end

local function UpdateQuickCoordInputVisibility()
end

local function ClearAllMarkerFrames()
end


local function CreateMarkerFrame(parent, marker)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(2200)

    frame.fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    local size = self:GetDB().settings.markerSize or 15
    local fontPath = GameFontNormal:GetFont()
    frame.fontString:SetFont(fontPath, size, "OUTLINE")
    frame.fontString:SetShadowOffset(0, 0)
    frame.fontString:SetText(marker.title or L.CUSTOM_POINT)

    local c = cloneColor(marker.customColor)
    frame.fontString:SetTextColor(c.r, c.g, c.b, 1)

    local w = frame.fontString:GetStringWidth()
    local h = frame.fontString:GetStringHeight()
    frame:SetSize(w, h)
    frame.fontString:SetPoint("CENTER", frame, "CENTER")

    frame:EnableMouse(true)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(marker.title or L.CUSTOM_POINT, 1, 0.82, 0)
        if marker.note and marker.note ~= "" then
            GameTooltip:AddLine(marker.note, 1, 1, 1, true)
        end
        GameTooltip:Show()
    end)

    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    frame:SetScript("OnMouseUp", function(_, button)
        if button ~= "LeftButton" then return end
        local mapID = WorldMapFrame and WorldMapFrame:GetMapID()
        if not mapID then return end

        local x, y = decodeCoord(marker.coord)
        local waypoint = UiMapPoint.CreateFromCoordinates(mapID, x, y)
        if not waypoint then return end

        C_Map.SetUserWaypoint(waypoint)
        if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
            C_SuperTrack.SetSuperTrackedUserWaypoint(true)
        end
    end)

    return frame
end



local function Init()
    Button= CreateFrame('DropdownButton', 'WoWToolsWorldFramePlayerPinButton', WorldMapFrameCloseButton, 'WoWToolsMenu3Template')
    Button:SetNormalAtlas('Ping_Wheel_Icon_Assist')
    Button:SetPoint('RIGHT', WorldMapFrameCloseButton, 'LEFT', -23*2, 0)

    Button.pool= CreateFramePool('DropdownButton', Button, 'WoWToolsMenu3Template')

    WorldMapFrame:HookScript("OnShow", function()
        RefreshMapMarkers(true)
        UpdateQuickCoordInputVisibility()
    end)

    WorldMapFrame:HookScript("OnHide", function()
        ClearAllMarkerFrames()
        UpdateQuickCoordInputVisibility()
    end)

    hooksecurefunc(WorldMapFrame, "OnMapChanged", function()
        RefreshMapMarkers(true)
    end)

    if WorldMapFrame.ScrollContainer then
        hooksecurefunc(WorldMapFrame.ScrollContainer, "ZoomIn", function()
            RefreshMapMarkers(true)
        end)
        hooksecurefunc(WorldMapFrame.ScrollContainer, "ZoomOut", function()
            RefreshMapMarkers(true)
        end)
    end

    Init=function()

    end
end




function WoWTools_WorldMapMixin:Init_PlayerPin()
    Init()
end