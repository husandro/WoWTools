local function Save()
    return WoWToolsSave['Plus_WorldMap'].PlayerPin
end

local function SaveWoW()
    return WoWToolsPlayerDate.PlayerMapPin
end


local Button


local function Is_CurPoint(waypoint)
    local point= C_Map.GetUserWaypoint()
    return point and point.uiMapID==waypoint.uiMapID and point.x==waypoint.x and point.y==waypoint.y
end






local function Init_PinMenu(self, root)
    if not self:IsMouseOver() then
        return
    end
    root:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '编辑' or EDIT),
    function()
        WoWTools_WorldMapMixin:Init_PlayerPin_EditUI({mapID=WoWTools_WorldMapMixin:GetMapID(), xy=self.data.xy})
        return MenuResponse.Open
    end)
    
end



local function Init_Pool(pin)
    --pin:SetFrameStrata('HIGH')
    pin.text = pin:CreateFontString(nil, "BORDER", "WorldMapTextFont")
    pin.text:SetPoint('CENTER')
    pin:SetupMenu(Init_PinMenu)

    function pin:tooltip(tooltip)
        if self.data.note then
            tooltip:AddLine(self.data.note, nil, nil, nil, true)
        end
    end

    pin:SetScript('OnEnter', function(self)
        if self.data.note then
            GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
            GameTooltip_SetTitle(GameTooltip, self.data.note)
        end
        WoWTools_WorldMapMixin:PlayerPin_ScrollToXY(self.data.xy)
    end)

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
end









local function RefreshMapMarkers()
    if not Button then
        return
    end

    Button.pool:ReleaseAll()

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

    --[[local profession= {}
    for _, i in pairs({GetProfessions()}) do
        local skillLineID= select(7, GetProfessionInfo(i))
        if skillLineID and skillLineID>0 then
            profession[skillLineID]= 1
        end
    end]]

    local width, height = canvas:GetSize()
    local classID= PlayerUtil.GetClassID()
    local h= Save().size or 32

    for xy, pin in pairs(pins) do
        local x, y= WoWTools_WorldMapMixin:GetXYForText(xy)

        if x and y--坐标
            and (not pin.skillLineID or C_SpellBook.GetSkillLineIndexByID(pin.skillLineID))--仅限专业
            and (not pin.classID or pin.classID==classID)--仅限职业
        then

            local btn = Button.pool:Acquire()
            btn.data= {
                mapID= mapID,
                x= x,--数字
                y= y,--数字
                xy= xy,--50.00 50.00 这个是字符
                --pin=pin
                note=pin.note,
            }

            local icon=''
            if pin.icon then
                if C_Texture.GetAtlasID(icon)>0 then
                    icon= '|A:'..pin.icon..':0:0|a'
                else
                    icon= '|T'..pin.icon..':0|t'
                end
            end

            btn.text:SetText(icon..(pin.name or ''))

            if pin.name then
                local color
                if pin.color then
                    color= CreateColor(pin.color.r or 1, pin.color.g or 1, pin.color.b or 1)
                else
                    color= CreateColor(1.0, 0.9294, 0.7607)
                end
                btn.text:SetTextColor(color:GetRGB())
            end

            btn.text:SetFontHeight(h)
            

            btn:SetSize(h-2, h-2)

            btn:SetPoint("CENTER", canvas, 'TOPLEFT', x *width/100, -(y* height/100))

            btn:Show()
        end
    end
end









local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local sub
    --local x, y, mapID= WoWTools_WorldMapMixin:GetPlayerXY()


    local num= 0
    for _, pin in pairs(SaveWoW()) do
        num= num+ CountTable(pin)
    end

--自定义
    sub=root:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '编辑' or EDIT),
    function()
        WoWTools_WorldMapMixin:Init_PlayerPin_EditUI()
        return MenuResponse.Open
    end, {rightText=num})
    WoWTools_MenuMixin:SetRightText(sub)

--重置位置
    local frameName= 'WoWToolsPlayerPinEditUIFrame'
    sub:CreateButton(
        (WoWTools_MoveMixin:GetPoint(nil, frameName) and '' or '|cff626262')
        ..(WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION),
    function()
        WoWTools_MoveMixin:ClearPoint(nil, frameName)--重置位置
        if _G[frameName] then
            _G[frameName]:ClearAllPoints()
            _G[frameName]:SetPoint('CENTER')
        end
        return MenuResponse.Refresh
    end)

--[[新建
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
            tooltip:AddDoubleLine('mpaID ', mapID, nil,nil,nil, 1,1,1)
            tooltip:AddDoubleLine('XY', x..'  '..y, nil,nil,nil, 1,1,1)
        end
    end)]]







--打开选项
    root:CreateDivider()
    sub= WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_WorldMapMixin.addName, name2=WoWTools_WorldMapMixin.addName2})

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

--parent
    sub=sub:CreateCheckbox(
        'WorldFrame',
    function()
        return Save().parentWorldFrame
    end, function()
        Save().parentWorldFrame= not Save().parentWorldFrame and true or nil
        if Button then
            Button:set_point()
        end
    end)
    sub:SetTooltip(function(tooltip)
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







    Button= CreateFrame('DropdownButton', 'WoWToolsWorldFramePlayerPinButton', MinimapCluster.Tracking.Button, 'WoWToolsMenu3Template')
    Button:SetNormalAtlas('Gear')
    Button:SetupMenu(Init_Menu)
    Button.tooltip= NORMAL_FONT_COLOR:WrapTextInColorCode(WoWTools_WorldMapMixin.addName2)
        ..'|n'..WoWTools_DataMixin.Icon.left..(WoWTools_DataMixin.onlyChinese and '新建' or NEW)
        ..'|n'..WoWTools_DataMixin.Icon.right..(WoWTools_DataMixin.onlyChinese and '菜单' or CONTACTS_MENU_NAME)
        ..'|n'..WoWTools_DataMixin.Icon.mid..WoWTools_TextMixin:GetShowHide(nil, true)
    function Button:set_alpha()
        self:GetNormalTexture():SetAlpha(self:IsMouseOver() and 1 or 0.5)
    end
    Button:set_alpha()

    function Button:set_point()
        self:ClearAllPoints()
        if Save().parentWorldFrame then
            self:SetPoint('RIGHT', WorldMapFrameCloseButton, 'LEFT', -23*2, 0)
            self:SetParent(WorldMapFrameCloseButton)
            self:SetFrameStrata(WorldMapFrameCloseButton:GetFrameStrata())
        else
            self:SetPoint('RIGHT', MinimapCluster.Tracking.Button, 'LEFT')
            self:SetParent(MinimapCluster.Tracking.Button)
            self:SetFrameStrata(MinimapCluster.Tracking.Button:GetFrameStrata())
        end
    end



    Button:RegisterEvent('PLAYER_ENTERING_WORLD')
    Button:SetScript('OnEvent', function(self)
        self:GetNormalTexture():SetDesaturated(not WoWTools_WorldMapMixin:GetMapID())
    end)

    Button:SetScript('OnMouseWheel', function(_, d)
        local frame= _G['WoWToolsPlayerPinEditUIFrame']
        if d==-1 then
            if frame and frame:IsShown() then
                WoWTools_WorldMapMixin:Init_PlayerPin_EditUI()
            end
        else
            if not frame or not frame:IsShown() then
                WoWTools_WorldMapMixin:Init_PlayerPin_EditUI()
            end
        end
    end)
    Button:set_point()


    Button.pool= CreateFramePool('DropdownButton', WorldMapFrame:GetCanvas(), 'WoWToolsMenu2Template', nil, nil, Init_Pool)
    --[[WorldMapFrame:HookScript("OnHide", function()
        Button.pool:ReleaseAll()
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
        Button:SetShown(not Save().disabled)
    end
end





function WoWTools_WorldMapMixin:Init_PlayerPin()
    Init()

end


function WoWTools_WorldMapMixin:Init_PlayerPin_RefreshMapMarkers()
    if _G['WoWToolsWorldMapMenuButton'] and _G['WoWToolsWorldMapMenuButton']:IsVisible() then
        RefreshMapMarkers()
    end
end

function WoWTools_WorldMapMixin:PlayerPin_ScrollToPin(mapID, xy)
    if not Button or WorldMapFrame.mapID~=mapID then
        return
    end
    for b in Button.pool:EnumerateActive() do
        b:SetButtonState(xy and b.data and b.data.xy==xy and 'PUSHED' or 'NORMAL')
    end
end
