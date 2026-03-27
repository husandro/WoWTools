local function Save()
    return WoWToolsSave['Plus_WorldMap'].PlayerPin
end
local function SaveWoW()
    return WoWToolsPlayerDate.PlayerMapPin
end

local PinHeight= 12--默认大小
local Button

local function SetUserWaypoint(self)
    local mapID= self.mapID
    local x, y= self.x, self.y--x=0.0555
    if _G['TomTom'] then
        local name= (select(3,  self.texture:GetAtlas() or self.texture:GetTexture()) or '')..(self.text:GetText() or '')
        local tab= {
            title = name,
            persistent = nil,
            minimap = true,
            world = true
        }
        if TomTom:WaypointExists(mapID, x, y, name) then
            TomTom:RemoveWaypoint({mapID, x, y, name = name, from=tab})
        else
            TomTom:AddWaypoint(mapID, x, y, {
            title = name,
            persistent = nil,
            minimap = true,
            world = true
        })
        end

    elseif C_Map.CanSetUserWaypointOnMap(mapID) then
        local waypoint = UiMapPoint.CreateFromCoordinates(mapID, x, y)
        if waypoint then
            local point= C_Map.GetUserWaypoint()
            if point and point.uiMapID==waypoint.uiMapID and point.x==waypoint.x and point.y==waypoint.y then
                C_Map.ClearUserWaypoint()
            else
                C_Map.SetUserWaypoint(waypoint)
                C_SuperTrack.SetSuperTrackedUserWaypoint(true)
            end
        end
    end
end










local function Check_Profession(profession)
    if type(profession)~= "table" then
        return true
    end
    for skillLineID in pairs(profession) do
        if C_SpellBook.GetSkillLineIndexByID(skillLineID) then
            return true
        end
    end
end




WoWToolsWorldMapDataProvider = CreateFromMixins(MapCanvasDataProviderMixin)

function WoWToolsWorldMapDataProvider:RemoveAllData()
	if self:GetMap() then
		self:GetMap():RemoveAllPinsByTemplate("WoWToolsWorldMapPinTemplate")
	end
end

function WoWToolsWorldMapDataProvider:RefreshAllData()
    local count= 0
    if self:GetMap() then

        self:GetMap():RemoveAllPinsByTemplate("WoWToolsWorldMapPinTemplate")

        local mapID= self:GetMap():GetMapID()
        if mapID and not Save().disabled then
            local classID= select(3, UnitClassBase('player'))

            for xy, pin in pairs(SaveWoW()[mapID] or {}) do--xy~='options'
                local x,y= WoWTools_WorldMapMixin:GetXYForText(xy)
                if x and y
                    and (not pin.class or pin.class[classID])
                    and Check_Profession(pin.profession)
                then
                    count= count +1
                    self:GetMap():AcquirePin("WoWToolsWorldMapPinTemplate", xy, x, y, pin, mapID)
                end
            end

        end
    end

    Button.text:SetText(count>0 and count or DISABLED_FONT_COLOR:WrapTextInColorCode('0'))
    Button:SetWidth(math.max(Button.text:GetStringWidth()+4, 23))
end













WoWToolsWorldMapPinMixin= CreateFromMixins(MapCanvasPinMixin)

function WoWToolsWorldMapPinMixin:OnLoad()
	self:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI")
	self:SetMovable(true)
	self:SetScalingLimits(1, 1.0, 1.2)
    self:RegisterForMouse("RightButtonDown", 'LeftButtonDown', "LeftButtonUp", 'RightButtonUp')
    self:SetupMenu(function(btn, root)
        if not btn:IsMouseOver() then
            return
        end
        root:CreateButton(
            (WoWTools_DataMixin.onlyChinese and '编辑' or EDIT)
            ..' '..btn.xy,
        function()
            WoWTools_WorldMapMixin:PlayerPin_ShowUI({mapID=WoWTools_WorldMapMixin:GetMapID(), xy=btn.xy})
            return MenuResponse.Open
        end)
        root:CreateDivider()
        root:CreateButton(
            WoWTools_DataMixin.onlyChinese and '删除' or DELETE,
        function()
            SaveWoW()[btn.mapID][btn.xy]= nil
            WoWToolsWorldMapDataProvider:RemoveAllData()
            WoWTools_WorldMapMixin:PlayerPin_RefreshUI()
        end)
        root:CreateDivider()
        root:CreateTitle(
            WoWTools_DataMixin.Icon.left
            ..(_G['TomTom'] and 'TomTom' or (WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING))
            ..'|A:Waypoint-MapPin-Untracked:0:0|a')
        root:CreateTitle(
            'Alt+'..WoWTools_DataMixin.Icon.right
            ..(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE)
        )
    end)

    self:RegisterForDrag("RightButton")
--开始移动
    self:SetScript("OnDragStart", function(btn, d)
        if d=='RightButton' and IsAltKeyDown() then
            btn:StartMoving()
            btn.isMoving = true
        end
    end)
--停止移动
    self:SetScript("OnDragStop", function(btn, d, ...)
        btn:StopMovingOrSizing()
        if not btn.isMoving then
            return
        else
            btn.isMoving= nil
        end

        local mapID= btn.mapID
        local x, y= WoWTools_WorldMapMixin:GetMapXY()
        local newXY= WoWTools_WorldMapMixin:GetTextForXY(x, y)
        local oldXY= btn.xy

        if newXY and oldXY~=newXY and SaveWoW()[mapID] and SaveWoW()[mapID][oldXY] then
            local delTab= SaveWoW()[mapID][newXY]--如果已存在
            if delTab then
                print(
                    WoWTools_DataMixin.Icon.icon2
                    ..WARNING_FONT_COLOR:WrapTextInColorCode(WoWTools_DataMixin.onlyChinese and '替换' or REPLACE),
                    newXY,
                    select(3, WoWTools_TextureMixin:IsAtlas(delTab.icon)) or '',
                    delTab.name or '',
                    delTab.note
                )
            end
            SaveWoW()[mapID][newXY]= CopyTable(SaveWoW()[mapID][oldXY])
            SaveWoW()[mapID][oldXY]= nil--清除原来的

            WoWToolsWorldMapDataProvider:RefreshAllData()
            WoWTools_WorldMapMixin:PlayerPin_RefreshUI({mapID=mapID, xy=newXY})
        end
        ResetCursor()
    end)
end












function WoWToolsWorldMapPinMixin:OnAcquired(xy, x, y, pin, mapID)
    local options= SaveWoW()[mapID].options or {}
    local iconS, fontH= options.iconS or PinHeight, options.fontH or PinHeight

    x,y= x/100, y/100

    self.mapID= mapID
    self.xy= xy
    self.x= x
    self.y= y
    self.note= pin.note

    if self.SetPassThroughButtons then
		self:SetPassThroughButtons("")
	end
    local textureID= select(2, WoWTools_TextureMixin:SetTexture(self.texture, pin.icon))
    self.text:SetText(pin.name or '')
    local icons2= textureID and iconS or fontH
    if pin.name then
        local color
        if pin.color then
            color= CreateColor(pin.color.r or 1, pin.color.g or 1, pin.color.b or 1)
        else
            color= CreateColor(1.0, 0.9294, 0.7607)
        end
        self.text:SetTextColor(color:GetRGB())
        self.text:SetFontHeight(fontH)
        self.text:SetPoint('LEFT', self, 'RIGHT', textureID and -1 or -icons2, 0)
    end
    self:SetSize(icons2, icons2)
    self:SetPosition(x, y)
end
function WoWToolsWorldMapPinMixin:OnReleased()
	self.xy= nil
    self.x= nil
    self.y= nil
    self.mapID= nil
    self.note= nil
	if self.widgetContainer then
		self.widgetContainer:UnregisterForWidgetSet();
	end
end
function WoWToolsWorldMapPinMixin:OnMouseEnter()
	if self.note then
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip_SetTitle(GameTooltip, self.note)
        GameTooltip:Show()
    end
    WoWTools_WorldMapMixin:PlayerPin_SetUIButtonState(self.xy)
end

function WoWToolsWorldMapPinMixin:OnMouseLeave()
	WoWTools_WorldMapMixin:PlayerPin_SetUIButtonState()
    GameTooltip:Hide()
end

function WoWToolsWorldMapPinMixin:OnMouseDown(d)
	if d=="LeftButton" then
        self:CloseMenu()
        SetUserWaypoint(self)
    elseif d=='RightButton' and IsAltKeyDown() then
        self:CloseMenu()
        SetCursor('UI_MOVE_CURSOR')
    end
end

function WoWToolsWorldMapPinMixin:OnMouseUp()
	ResetCursor()
end
-- hack to avoid error in combat in 10.1.5
WoWToolsWorldMapPinMixin.SetPassThroughButtons = function()end
























local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local sub, sub2
    local uiFrame, uiName= WoWTools_WorldMapMixin:PlayerPin_GetUIFrame()


    local data= WorldMapFrame:IsShown() and SaveWoW()[WorldMapFrame.mapID]
    if data then
        SaveWoW()[WorldMapFrame.mapID].options= SaveWoW()[WorldMapFrame.mapID].options or {}

        root:CreateSpacer()
        WoWTools_MenuMixin:CreateSlider(root, {
            name= WoWTools_DataMixin.onlyChinese and '字体' or FONT_SIZE,
            getValue=function()
                return SaveWoW()[WorldMapFrame.mapID].options.fontH or PinHeight
            end, setValue=function(value)
                SaveWoW()[WorldMapFrame.mapID].options.fontH = value
                WoWToolsWorldMapDataProvider:RefreshAllData()
            end,
            minValue=2,
            maxValue=200,
            step=1,
        })
        root:CreateSpacer()

        WoWTools_MenuMixin:CreateSlider(root, {
            name= WoWTools_DataMixin.onlyChinese and '图标' or SELF_HIGHLIGHT_ICON,
            getValue=function()
                return SaveWoW()[WorldMapFrame.mapID].options.iconS or PinHeight
            end, setValue=function(value)
                SaveWoW()[WorldMapFrame.mapID].options.iconS = value
                WoWToolsWorldMapDataProvider:RefreshAllData()
            end,
            minValue=2,
            maxValue=200,
            step=1,
        })
        root:CreateSpacer()
        root:CreateDivider()
    end

--UI编辑
    sub=root:CreateButton(
        (WoWTools_DataMixin.onlyChinese and 'UI编辑' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, 'UI', EDIT))..WoWTools_DataMixin.Icon.mid,
    function()
        WoWTools_WorldMapMixin:PlayerPin_ShowUI()
        return MenuResponse.Open
    end)
    WoWTools_MenuMixin:SetRightText(sub)

--FrameStrata
    WoWTools_MenuMixin:FrameStrata(self, sub,
    function(strata)
        return (Save().UIStrata or 'HIGH') == strata
    end, function(strata)
        Save().UIStrata= strata
        if uiFrame  then
            uiFrame:settings()
        end
        return MenuResponse.Refresh
    end)

    sub:CreateDivider()
--重置位置
    sub:CreateButton(
        (WoWTools_MoveMixin:GetPoint(nil, uiName) and '' or '|cff626262')
        ..(WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION),
    function()
        WoWTools_MoveMixin:ClearPoint(nil, uiName)--重置位置
        local frame= WoWTools_WorldMapMixin:PlayerPin_GetUIFrame()
        if frame then
            frame:ClearAllPoints()
            frame:SetPoint('CENTER')
        end
        return MenuResponse.Refresh
    end)

--打开选项
    --root:CreateDivider()
    sub= WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_WorldMapMixin.addName, name2=WoWTools_WorldMapMixin.addName2})

--parent
    sub2=sub:CreateCheckbox(
        'WorldFrame',
    function()
        return Save().parentWorldFrame
    end, function()
        Save().parentWorldFrame= not Save().parentWorldFrame and true or nil
        self:set_point()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('SetParent: |cnHIGHLIGHT_FONT_COLOR:WorldFrame / Minimap')
    end)

    sub:CreateDivider()
--重新加载UI
    WoWTools_MenuMixin:Reload(sub)
end









































local function Init()
    if Save().disabled then--or not WorldMapFrame:GetCanvas() then
        return
    end

    WorldMapFrame:AddDataProvider(WoWToolsWorldMapDataProvider)
    if WorldMapFrame:IsShown() then
        WoWToolsWorldMapDataProvider:RemoveAllData()
    end


    Button= CreateFrame('DropdownButton', 'WoWToolsWorldFramePlayerPinButton', MinimapCluster.Tracking.Button, 'WoWToolsMenu3Template')

    Button.text= Button:CreateFontString(nil, 'ARTWORK', 'WoWToolsFonts')
    Button.text:SetPoint('CENTER')
    Button.text:SetJustifyH('CENTER')
    WoWTools_ColorMixin:SetLabelColor(Button.text)
    Button.text:SetFontHeight(10)

    Button:SetupMenu(Init_Menu)

    function Button:tooltip(tooltip)
        tooltip:AddLine(WoWTools_WorldMapMixin.addName2)
        local canvas= WorldMapFrame:GetCanvas()
        if canvas and WorldMapFrame.mapID then
            local w, h= canvas:GetSize()
            tooltip:AddDoubleLine('Canvas: |cffffffff'..math.modf(w)..'|r x |cffffffff'..math.modf(h))
        end
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_DataMixin.Icon.left..(WoWTools_DataMixin.onlyChinese and '新建' or NEW), 1,1,1)
        tooltip:AddLine(WoWTools_DataMixin.Icon.right..(WoWTools_DataMixin.onlyChinese and '菜单' or CONTACTS_MENU_NAME), 1,1,1)
        tooltip:AddLine(WoWTools_DataMixin.Icon.mid..(WoWTools_DataMixin.onlyChinese and 'UI编辑' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, 'UI', EDIT)), 1,1,1)
    end

    function Button:set_point()
        self:ClearAllPoints()
        if Save().parentWorldFrame then
            self:SetPoint('RIGHT', _G['WoWToolsWorldMapMenuButton'], 'LEFT', 0, 0)
            self:SetParent(_G['WoWToolsWorldMapMenuButton'])
            self:SetFrameStrata(_G['WoWToolsWorldMapMenuButton']:GetFrameStrata())
        else
            self:SetPoint('RIGHT', MinimapCluster.Tracking.Button, 'LEFT')
            self:SetParent(MinimapCluster.Tracking.Button)
            self:SetFrameStrata(MinimapCluster.Tracking.Button:GetFrameStrata())

        end
    end

    Button:SetScript('OnMouseUp', function(self, d)
        if d~='LeftButton' then
            return
        end
        self:CloseMenu()
        local isMapXY= WorldMapFrame:IsShown()
        if isMapXY then
            WoWTools_WorldMapMixin:PlayerPin_ShowUI({
                isNew=true,
                mapID=WoWTools_WorldMapMixin:GetMapID(),
            })
        else
            local xy, mapID= WoWTools_WorldMapMixin:GetTextForXY(nil, nil, nil, true)
            WoWTools_WorldMapMixin:PlayerPin_ShowUI({
                isNew=true,
                mapID=mapID,
                xy= xy
            })
        end
        local frame= WoWTools_WorldMapMixin:PlayerPin_GetUIFrame()
        if frame then
            if isMapXY then
                if not frame.getMapXYButton.isSatrt then
                    frame.getMapXYButton:Click()
                end
            else
                if not frame.getNameButton.isSatrt then
                    frame.getNameButton:Click()
                end
            end
        end
    end)

    Button:SetScript('OnMouseWheel', function(_, d)
        local frame= WoWTools_WorldMapMixin:PlayerPin_GetUIFrame()
        if d==-1 then
            if frame and frame:IsShown() then
                WoWTools_WorldMapMixin:PlayerPin_ShowUI()
            end
        else
            if not frame or not frame:IsShown() then
                WoWTools_WorldMapMixin:PlayerPin_ShowUI()
            end
        end
    end)

    function Button:set_text()
        if not self:IsVisible() then
            return
        end
        local mapID= WorldMapFrame:IsShown() and WorldMapFrame.mapID or C_Map.GetBestMapForUnit("player")
        local count= 0
        if mapID and SaveWoW()[mapID] then
            if not SaveWoW()[mapID].options then
                SaveWoW()[mapID].options= {}
            end
            count= CountTable(SaveWoW()[mapID])-1
        end
        self.text:SetText(count>0 and count or DISABLED_FONT_COLOR:WrapTextInColorCode('0'))
        self:SetWidth(math.max(self.text:GetStringWidth()+4, 23))
    end

    Button:RegisterEvent('ZONE_CHANGED')
    Button:RegisterEvent('ZONE_CHANGED_NEW_AREA')
    Button:RegisterEvent('PLAYER_ENTERING_WORLD')

    Button:SetScript('OnEvent', Button.set_text)
    Button:set_point()


    WorldMapFrame:HookScript("OnHide", function()
        Button:set_text()
    end)
    --WorldMapFrame:HookScript("OnShow", RefreshMapMarkers)
    --hooksecurefunc(WorldMapFrame, "OnMapChanged", RefreshMapMarkers)
    --hooksecurefunc(WorldMapFrame.ScrollContainer, "ZoomIn", RefreshMapMarkers)
    --hooksecurefunc(WorldMapFrame.ScrollContainer, "ZoomOut", RefreshMapMarkers)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Object, function(tooltip, data)
        if Save().disabled
            or InCombatLockdown()
            or not data
            or not data.lines
            or not data.lines[1]
            or not data.lines[1].leftText
        then
            return
        end
        local text= WoWTools_TextMixin:CN(data.lines[1].leftText)
        local xy, mapID= WoWTools_WorldMapMixin:GetTextForXY(nil, nil, nil, true)
        if xy and mapID then
            if IsControlKeyDown() and IsAltKeyDown() then
                WoWTools_WorldMapMixin:PlayerPin_ShowUI({
                    isNew= true,
                    mapID= mapID,
                    xy= xy,
                    name= text,
                })
                tooltip:Show()
                return
            end
            tooltip:AddLine(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(WoWTools_DataMixin.Icon.Player..xy))
            if SaveWoW()[mapID] and SaveWoW()[mapID][xy] then
                tooltip:AddLine(NORMAL_FONT_COLOR:WrapTextInColorCode(
                    '|A:Gear:0:0|a'..'Ctr+Alt '
                    ..(WoWTools_DataMixin.onlyChinese and '更新' or UPDATE)
                ))
            else
                tooltip:AddLine(GREEN_FONT_COLOR:WrapTextInColorCode(
                    '|A:Gear:0:0|a'..'Ctr+Alt '
                    ..(WoWTools_DataMixin.onlyChinese and '新建' or NEW)
                ))
            end
            tooltip:Show()
        end
    end)


    --[[if WoWTools_DataMixin.Player.husandro then
        C_Timer.After(2, function()
            WoWTools_WorldMapMixin:PlayerPin_ShowUI()
        end)
    end]]



    Init=function()
        WoWToolsWorldMapDataProvider:RemoveAllData()
        Button:SetShown(not Save().disabled)
    end
end



















function WoWTools_WorldMapMixin:Init_PlayerPin()
    Init()
end
