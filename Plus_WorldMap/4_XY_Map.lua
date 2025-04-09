
--地图坐标

local function Save()
    return  WoWToolsSave['Plus_WorldMap']
end

local MapXYButton










--自定义，地图标记，XY
local function Set_Map_Waypoint(self)
    local mapID = WorldMapFrame.mapID
    if not mapID then
        print(WoWTools_DataMixin.onlyChinese and '没有找到MapID' or "Not found MapID")
        return
    elseif not C_Map.CanSetUserWaypointOnMap(mapID) then
        print(WoWTools_DataMixin.onlyChinese and '当前地图不能标记' or "Cannot set waypoints on this map")
        return
    end

    local text= self:GetText() or ''
    text= text:gsub('%s', function(t) if t~='.' then return ' ' end end)
    text= text:gsub('%p', function(t) if t~='.' then return ' ' end end)
    text= text:gsub('%a', function(t) if t~='.' then return ' ' end end)

    text= text:gsub('，', ' ')
    text= text:gsub('%s%s', ' ')

--100.10 100.10
    local x, y= text:match('(%d+%.%d+) (%d+%.%d+)')

--100.10 100
if not x or not y then
    x, y= text:match('(%d+%.%d+) (%d+)')
end


--100 100.10
if not x or not y then
    x, y= text:match('(%d+) (%d+%.%d+)')
end

--100 100
    if not x or not y then
        x, y= text:match('(%d+) (%d+)')
    end


    x= x and tonumber(x)
    y= y and tonumber(y)
    if x and y then
        x, y= x*0.01, y*0.01

        if x>1 or y>1 then
            print(WoWTools_DataMixin.onlyChinese and '错误XY' or 'Error XY')
            return
        end

        local pos= CreateVector2D(x, y)
        local mapPoint = UiMapPoint.CreateFromVector2D(mapID, pos)
        C_Map.SetUserWaypoint(mapPoint)

        print(C_Map.GetUserWaypointHyperlink(), x*100, y*100)
    else
        print(WoWTools_DataMixin.onlyChinese and '错误XY' or 'Error XY')
    end
end






local function Init_Menu(_, root)

    local mapID= C_Map.GetBestMapForUnit("player")
    local can= mapID and C_Map.CanSetUserWaypointOnMap(mapID)

    root:CreateButton(
        (can and '' or '|cff9e9e9e')
        ..'|A:Waypoint-MapPin-ChatIcon:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '分享' or SOCIAL_SHARE_TEXT),
    function()
        WoWTools_WorldMapMixin:SendPlayerPoint()--发送玩家位置
        return MenuResponse.Open
    end)

    root:CreateDivider()
    root:CreateButton(
        (WorldMapFrame.mapID==MapUtil.GetDisplayableMapForPlayer() and '|cff9e9e9e' or '')
        ..WoWTools_DataMixin.Icon.Player
        ..(WoWTools_DataMixin.onlyChinese and '返回当前地图' or
        format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PREVIOUS, REFORGE_CURRENT), WORLD_MAP)
    ), function()
        WorldMapFrame:SetMapID(MapUtil.GetDisplayableMapForPlayer())
        return MenuResponse.Open
    end)
end







local function Init()
    MapXYButton=WoWTools_ButtonMixin:Cbtn(WorldMapFrame.BorderFrame.TitleContainer, {
        atlas=WoWTools_DataMixin.Icon.Player:match('|A:(.-):'),
        size=22,
    })

    MapXYButton:SetScript('OnLeave', GameTooltip_Hide)
    MapXYButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_WorldMapMixin.addName)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.left)

        --GameTooltip:AddLine(' ')
        --local can
        --can= C_Map.GetBestMapForUnit("player")
        --can= can and C_Map.CanSetUserWaypointOnMap(can)
        --GameTooltip:AddDoubleLine('|A:Waypoint-MapPin-ChatIcon:0:0|a'..(WoWTools_DataMixin.onlyChinese and '发送位置' or RESET_POSITION:gsub(RESET, SEND_LABEL)), (not can and GetMinimapZoneText() or not can and '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '无' or NONE)..'|r' or '')..WoWTools_DataMixin.Icon.left)
        --GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '返回当前地图' or (PREVIOUS..REFORGE_CURRENT..WORLD_MAP), WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
    end)
    MapXYButton:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, function(...)
            Init_Menu(...)
        end)
        --[[if d=='RightButton' then--返回当前地图                
            WorldMapFrame:SetMapID(MapUtil.GetDisplayableMapForPlayer())

        elseif d=='LeftButton' then
            WoWTools_WorldMapMixin:SendPlayerPoint()--发送玩家位置
        end]]
    end)



    MapXYButton.edit= CreateFrame("EditBox", nil, MapXYButton, 'InputBoxTemplate')
    MapXYButton.edit:SetHeight(22)
    WoWTools_ColorMixin:Setup(MapXYButton.edit, {type='EditBox'})
    MapXYButton.edit:SetAutoFocus(false)
    MapXYButton.edit:ClearFocus()
    MapXYButton.edit:SetPoint('LEFT', MapXYButton, 'RIGHT',2,0)
    MapXYButton.edit.Left:SetAlpha(0.3)
    MapXYButton.edit.Middle:SetAlpha(0.3)
    MapXYButton.edit.Right:SetAlpha(0.3)

    MapXYButton.edit:SetScript('OnEditFocusLost', function(self)
        WoWTools_ColorMixin:Setup(self, {type='EditBox'})
    end)

    MapXYButton.edit:SetScript('OnEditFocusGained', function(self)
        self:HighlightText()
        self:SetTextColor(1,1,1)
    end)

    MapXYButton.edit:SetScript("OnKeyUp", function(self, key)
        if not IsControlKeyDown() or key ~= "C" then
            return
        end
        self:ClearFocus()
        print(
            WoWTools_DataMixin.addName,
            WoWTools_WorldMapMixin.addName,
            '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '复制链接' or BROWSER_COPY_LINK)..'|r',
            self:GetText()
        )
    end)

    MapXYButton.edit:SetScript("OnEnterPressed", Set_Map_Waypoint)--自定义，地图标记，XY
    MapXYButton.edit:SetScript('OnLeave', GameTooltip_Hide)
    MapXYButton.edit:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(
            '|A:Waypoint-MapPin-Untracked:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '地图标记' or MAP_PIN)
            ..'|A:NPE_Icon:0:0|aEnter'
        )

        local mapID = WorldMapFrame.mapID
        if not mapID then
            GameTooltip:AddLine('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '没有找到MapID' or "Not found MapID"))
        elseif not C_Map.CanSetUserWaypointOnMap(mapID) then
            GameTooltip:AddLine('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '当前地图不能标记' or "Cannot set waypoints on this map"))
        end

        GameTooltip:Show()
    end)

    MapXYButton.Text=WoWTools_LabelMixin:Create(MapXYButton, {copyFont=WorldMapFrameTitleText})--玩家当前坐标
    MapXYButton.Text:SetPoint('LEFT',MapXYButton.edit, 'RIGHT', 2, 0)


    MapXYButton:HookScript("OnUpdate", function (self, elapsed)
        self.elapsed = (self.elapsed or 1) + elapsed
        if self.elapsed > 0.15 then
            self.elapsed = 0
            local text=''
            local x, y= WoWTools_WorldMapMixin:GetPlayerXY()--玩家当前位置
            if x and y then
                text=x..' '..y
            end
            if not self.edit:HasFocus() then
                self.edit:SetText(text)
            end
            x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()--当前世界地图位置
            if x and y then
                text = ('%.2f'):format(x*100)..' '..('%.2f'):format(y*100)
            else
                text=''
            end
            MapXYButton.Text:SetText(text)
        end
    end)


    function MapXYButton:Settings()
        self.edit:SetWidth(Save().MapXY_W or 90)
        self:SetScale(Save().MapXYScale or 1)
        self:SetShown(Save().ShowMapXY)
        
        self:ClearAllPoints()
        self:SetPoint('BOTTOMLEFT', WorldMapFrame.BorderFrame.TitleContainer,
            Save().MapXY_X or 72,
            Save().MapXY_Y or -2
        )
    end

    MapXYButton:Settings()
end











function WoWTools_WorldMapMixin:Init_XY_Map()
    if MapXYButton then
        MapXYButton:Settings()

    elseif WoWToolsSave['Plus_WorldMap'].ShowMapXY then
        Init()
    end
end