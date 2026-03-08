local function Save()
    return WoWToolsSave['Plus_WorldMap'].PlayerPin
end

local function SaveWoW()
    return WoWToolsPlayerDate.WorldMapPin
end

local WorldMapPin={
    [2393]={--12.0银月城
        [WoWTools_DataMixin.onlyChinese and BUTTON_LAG_AUCTIONHOUSE or '拍卖行']={
            --icon= 'Warfronts-FieldMapIcons-Horde-Banner-Minimap',
            x= 50.02,
            y= 74.76,
            color={r=0.87, g=0.8, b=0.61},
            --note='b拍卖行a',
        }
    }
}

local Pool
local addName


local function Is_CurPoint(waypoint)
    local point= C_Map.GetUserWaypoint()
    return point and point.uiMapID==waypoint.uiMapID and point.x==waypoint.x and point.y==waypoint.y
end

















local function Init_Button(pin)
    pin:SetFrameStrata('HIGH')
    pin.text = pin:CreateFontString(nil, "BORDER", "WorldMapTextFont")
    pin.text:SetPoint('CENTER')

    function pin:tooltip(tooltip)
        if self.data.note then
            tooltip:AddLine(self.data.note, nil, nil, nil, true)
        end
        GameTooltip_AddColoredLine(tooltip,
            '<'
            ..(WoWTools_DataMixin.onlyChinese and '|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a 地图标记位置' or MAP_PIN_HYPERLINK)
            ..'>',
            C_Map.CanSetUserWaypointOnMap(self.data.mapID) and GREEN_FONT_COLOR or DISABLED_FONT_COLOR
        )
    end

    pin:SetScript("OnMouseDown", function(self, d)
        if d ~= "LeftButton"
            or not C_Map.CanSetUserWaypointOnMap(self.data.mapID)
        then
            return
        end

        local x,y= self.data.x/100, self.data.y/100

        local waypoint = UiMapPoint.CreateFromCoordinates(self.data.mapID, x, y)
        if waypoint then
            if Is_CurPoint(waypoint) then
                C_Map.ClearUserWaypoint()
            else
                C_Map.SetUserWaypoint(waypoint)
                C_SuperTrack.SetSuperTrackedUserWaypoint(true)
            end
        end
    end)


    function pin:Init(canvas, width, height)
        local data= self.data

        self.text:SetText(
            (select(3, WoWTools_TextureMixin:IsAtlas(data.icon)) or '')
            ..data.name
        )

        local color
        if data.color then
            color= CreateColor(data.color.r or 1, data.color.g or 1, data.color.b or 1)
        else
            color= CreateColor(1.0, 0.9294, 0.7607)
        end
        self.text:SetTextColor(color:GetRGB())

        local h= Save().size or 32
        self.text:SetFontHeight(h)
        self:SetSize(h-2, h-2)

        local x= data.x * width / 100
        local y= data.y * height / 100
        self:SetPoint("CENTER", canvas, 'TOPLEFT', x, -y)

        pin:Show()
    end
end









local function RefreshMapMarkers()
    if not Pool then
        return
    end

    Pool:ReleaseAll()

    local mapID= WoWTools_WorldMapMixin:GetMapID()
    local pins = SaveWoW()[mapID]
    local canvas = WorldMapFrame:GetCanvas()

    if not pins
        or TableIsEmpty(pins)
        or not canvas
        or Save().disabled
    then
        return
    end

    local width, height = canvas:GetSize()

    for name, data in pairs(pins) do

        local pin = Pool:Acquire()
        pin.data= {
            name= name,
            mapID= mapID,
            icon= data.icon,
            x= data.x,
            y= data.y,
            note= data.note,
        }

        pin:Init(canvas, width, height)
    end
end









local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local sub
    local x, y, mapID= WoWTools_WorldMapMixin:GetPlayerXY()

    sub= root:CreateCheckbox(
        addName,
    function()
        return not Save().disabled
    end, function()
        Save().disabled= not Save().disabled and true or nil
        WoWTools_WorldMapMixin:Init_PlayerPin()
    end)

    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        name= WoWTools_DataMixin.onlyChinese and '字体大小' or FONT_SIZE,
        getValue=function()
            return Save().size or 46
        end, setValue=function(value)
            Save().size= value
            RefreshMapMarkers()
        end,
        minValue=4,
        maxValue=200,
        step=2,
    })
    sub:CreateSpacer()
--新建
    root:CreateDivider()
    sub= root:CreateButton(
        WoWTools_DataMixin.Icon.Player
        ..(WoWTools_DataMixin.onlyChinese and '新建' or NEW),
    function()
        WoWTools_WorldMapMixin:Init_PlayerPin_EditUI({
            isNew=true,
        })
        return MenuResponse.Open
    end)
    sub:SetTooltip(function (tooltip)
        if x and y then
            tooltip:AddDoubleLine('mpaID ', mapID)
            tooltip:AddDoubleLine('XY', x..'  '..y)
        end
    end)



--自定义
    local num= 0
    for _, data in pairs(SaveWoW()) do
        num= num+ CountTable(data)
    end
    sub=root:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '自定义' or CUSTOM),
    function()
        WoWTools_WorldMapMixin:Init_PlayerPin_EditUI({})
        return MenuResponse.Open
    end, {rightText=num})
    WoWTools_MenuMixin:SetRightText(sub)



end






local function Init()
    if not _G['WoWToolsWorldFramePlayerPinButton'] then

        WoWToolsPlayerDate.WorldMapPin= WoWToolsPlayerDate.WorldMapPin or WorldMapPin

        local btn= CreateFrame('DropdownButton', 'WoWToolsWorldFramePlayerPinButton', WorldMapFrameCloseButton, 'WoWToolsMenu3Template')
        btn:SetNormalAtlas('Ping_Wheel_Icon_Assist')
        btn:SetPoint('RIGHT', WorldMapFrameCloseButton, 'LEFT', -23*2, 0)
        btn:SetupMenu(Init_Menu)
        addName= '|A:Ping_Wheel_Icon_Assist:0:0|a'..(WoWTools_DataMixin.onlyChinese and '地图标记' or MAP_PIN)
        btn.tooltip= addName
    end


    if Save().disabled then
        return
    end

    Pool= CreateFramePool('DropdownButton', WorldMapFrame:GetCanvas(), 'WoWToolsMenu2Template', nil, nil, Init_Button)
    --[[WorldMapFrame:HookScript("OnHide", function()
        Pool:ReleaseAll()
    end)]]
    --WorldMapFrame:HookScript("OnShow", RefreshMapMarkers)
    hooksecurefunc(WorldMapFrame, "OnMapChanged", RefreshMapMarkers)
    --hooksecurefunc(WorldMapFrame.ScrollContainer, "ZoomIn", RefreshMapMarkers)
    --hooksecurefunc(WorldMapFrame.ScrollContainer, "ZoomOut", RefreshMapMarkers)


    if WoWTools_DataMixin.Player.husandro then
        C_Timer.After(2, function()
            WoWTools_WorldMapMixin:Init_PlayerPin_EditUI()
        end)
    end
    
    Init=function()
        RefreshMapMarkers()
    end
end





function WoWTools_WorldMapMixin:Init_PlayerPin()
    Init()
    
end