local function Save()
    return WoWToolsSave['Plus_WorldMap'].PlayerPin
end

local function SaveWoW()
    return WoWToolsPlayerDate.PlayerMapPin
end


local Button
local PinHeight= 42--默认大小



local function Is_CurPoint(waypoint)
    local point= C_Map.GetUserWaypoint()
    return point and point.uiMapID==waypoint.uiMapID and point.x==waypoint.x and point.y==waypoint.y
end








local function RefreshMapMarkers()
    if not Button then
        return
    end

    Button.pool:ReleaseAll()

    local mapID= WoWTools_WorldMapMixin:GetMapID()
    local pins= SaveWoW()[mapID]
    local canvas= WorldMapFrame:GetCanvas()

    if not pins
        or TableIsEmpty(pins)
        or not canvas
        or Save().disabled
    then
        return
    end

    local width, height = canvas:GetSize()
    local classID= PlayerUtil.GetClassID()
    local fontH= Save().fontHeight or PinHeight
    local iconSize= Save().iconSize or PinHeight
    --local strata= Save().pinStrata or 'MEDIUM'

    for xy, pin in pairs(pins) do
        local x, y= WoWTools_WorldMapMixin:GetXYForText(xy)
        local professionIsKnown= WoWTools_ProfessionMixin:IsKnown(pin.profession)

        if x and y--坐标
            and professionIsKnown~=false
            and (not pin.class or pin.class[classID])--仅限职业
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

            --local icon= select(3, WoWTools_TextureMixin:IsAtlas(pin.icon)) or ''
            local textureID= select(2, WoWTools_TextureMixin:SetTexture(btn.texture, pin.icon))

            btn.text:SetText(pin.name or '')
            if pin.name then
                local color
                if pin.color then
                    color= CreateColor(pin.color.r or 1, pin.color.g or 1, pin.color.b or 1)
                else
                    color= CreateColor(1.0, 0.9294, 0.7607)
                end
                btn.text:SetTextColor(color:GetRGB())
                btn.text:SetFontHeight(fontH)
                btn.text:SetPoint('LEFT', btn, 'RIGHT', textureID and -4 or -iconSize, 0)
            end

            if textureID then
                btn:SetSize(iconSize, iconSize)
            else
                btn:SetSize(fontH, fontH)
            end

            --btn:SetFrameStrata(strata)
            btn:SetPoint("CENTER", canvas, 'TOPLEFT', x *width/100, -(y* height/100))
            btn:Show()
        end
    end
end






















local function Init_Pool(btn)
    btn.text = btn:CreateFontString(nil, "BORDER", 'WoWToolsFont2') --"WorldMapTextFont")
    btn:SetFrameStrata('HIGH')

    btn:SetMovable(true)
    btn:RegisterForDrag("RightButton")

    btn:SetupMenu(function(self, root)
        if not self:IsMouseOver() then
            return
        end
        root:CreateButton(
            (WoWTools_DataMixin.onlyChinese and '编辑' or EDIT)
            ..' '..self.data.xy,
        function()
            WoWTools_WorldMapMixin:PlayerPin_ShowUI({mapID=WoWTools_WorldMapMixin:GetMapID(), xy=self.data.xy})
            return MenuResponse.Open
        end)
        root:CreateDivider()
        root:CreateButton(
            WoWTools_DataMixin.onlyChinese and '删除' or DELETE,
        function()
            SaveWoW()[self.data.mapID][self.data.xy]= nil
            RefreshMapMarkers()
            WoWTools_WorldMapMixin:PlayerPin_RefreshUI()
        end)
        root:CreateDivider()
        root:CreateTitle(
            WoWTools_DataMixin.Icon.left
            ..(WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING)
            ..'|A:Waypoint-MapPin-Untracked:0:0|a')
        root:CreateTitle(
            'Alt+'..WoWTools_DataMixin.Icon.right
            ..(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE)
        )
    end)

    btn:SetScript('OnLeave', function()
        WoWTools_WorldMapMixin:PlayerPin_SetUIButtonState()
        GameTooltip:Hide()
    end)

    btn:SetScript('OnEnter', function(self)
        if self.data.note then
            GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
            GameTooltip_SetTitle(GameTooltip, self.data.note)
            GameTooltip:Show()
        end
        WoWTools_WorldMapMixin:PlayerPin_SetUIButtonState(self.data.xy)
    end)

    btn:HookScript("OnMouseUp", ResetCursor)--还原光标
    btn:SetScript("OnMouseDown", function(self, d)
        if d=="LeftButton" then
            self:CloseMenu()
            if C_Map.CanSetUserWaypointOnMap(self.data.mapID) then
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
            end
        elseif d=='RightButton' and IsAltKeyDown() then
            self:CloseMenu()
            SetCursor('UI_MOVE_CURSOR')
        end
    end)

--开始移动
    btn:SetScript("OnDragStart", function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            self:StartMoving()
        end
    end)
--停止移动
    btn:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local newXY= WoWTools_WorldMapMixin:GetTextForXY(nil, nil, true, false)
        local mapID= self.data.mapID
        local oldXY= self.data.xy

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

            RefreshMapMarkers()
            WoWTools_WorldMapMixin:PlayerPin_RefreshUI({mapID=mapID, xy=newXY})
            --WoWTools_WorldMapMixin:PlayerPin_RefreshUI(data)
            --WoWTools_WorldMapMixin:PlayerPin_ShowUI({mapID=mapID, xy=newXY})
        end
        ResetCursor()
    end)
end













local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local sub, sub2
    local uiFrame, uiName= WoWTools_WorldMapMixin:PlayerPin_GetUIFrame()

    local num= 0
    for _, pin in pairs(SaveWoW()) do
        num= num+ CountTable(pin)
    end


--[[新建
    root:CreateDivider()
    sub= root:CreateButton(
        WoWTools_DataMixin.Icon.Player
        ..(WoWTools_DataMixin.onlyChinese and '新建' or NEW),
    function()
        WoWTools_WorldMapMixin:PlayerPin_ShowUI({
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


    root:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(root, {
        name= WoWTools_DataMixin.onlyChinese and '字体' or FONT_SIZE,
        getValue=function()
            return Save().fontHeight or PinHeight
        end, setValue=function(value)
            Save().fontHeight= value
            RefreshMapMarkers()
        end,
        minValue=2,
        maxValue=200,
        step=1,
    })
    root:CreateSpacer()

    WoWTools_MenuMixin:CreateSlider(root, {
        name= WoWTools_DataMixin.onlyChinese and '图标' or SELF_HIGHLIGHT_ICON,
        getValue=function()
            return Save().iconSize or PinHeight
        end, setValue=function(value)
            Save().iconSize= value
            RefreshMapMarkers()
        end,
        minValue=2,
        maxValue=200,
        step=1,
    })
    root:CreateSpacer()
--FrameStrata
    --[[WoWTools_MenuMixin:FrameStrata(self, root,
    function(strata)
        return (Save().pinStrata or 'MEDIUM') == strata
    end, function(strata)
        Save().pinStrata= strata
        RefreshMapMarkers()
        return MenuResponse.Refresh
    end, {no={BACKGROUND=1, LOW=1}})]]


    root:CreateDivider()
--自定义
    sub=root:CreateButton(
        (WoWTools_DataMixin.onlyChinese and 'UI编辑' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, 'UI', EDIT))..WoWTools_DataMixin.Icon.mid,
    function()
        WoWTools_WorldMapMixin:PlayerPin_ShowUI()
        return MenuResponse.Open
    end, {rightText=num})
    WoWTools_MenuMixin:SetRightText(sub)

--FrameStrata
    WoWTools_MenuMixin:FrameStrata(self, sub,
    function(strata)
        local frame= WoWTools_WorldMapMixin:PlayerPin_GetUIFrame()
        if frame then
            return frame:GetFrameStrata()==strata
        else
            return (Save().UIStrata or 'HIGH') == strata
        end
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
        if Button then
            Button:set_point()
        end
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







    Button= CreateFrame('DropdownButton', 'WoWToolsWorldFramePlayerPinButton', MinimapCluster.Tracking.Button, 'WoWToolsMenu2Template')
    Button:SetNormalAtlas('Gear')
    Button:SetupMenu(Init_Menu)
    Button.tooltip= NORMAL_FONT_COLOR:WrapTextInColorCode(WoWTools_WorldMapMixin.addName2)
        ..'|n'..WoWTools_DataMixin.Icon.left..(WoWTools_DataMixin.onlyChinese and '新建' or NEW)
        ..'|n'..WoWTools_DataMixin.Icon.right..(WoWTools_DataMixin.onlyChinese and '菜单' or CONTACTS_MENU_NAME)
        ..'|n'..WoWTools_DataMixin.Icon.mid..(WoWTools_DataMixin.onlyChinese and 'UI编辑' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, 'UI', EDIT))
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
    Button:set_point()


    Button.pool= CreateFramePool('DropdownButton', WorldMapFrame:GetCanvas(), 'WoWToolsMenu2Template', nil, nil, Init_Pool)
    --[[WorldMapFrame:HookScript("OnHide", function()
        Button.pool:ReleaseAll()
    end)]]
    --WorldMapFrame:HookScript("OnShow", RefreshMapMarkers)
    hooksecurefunc(WorldMapFrame, "OnMapChanged", RefreshMapMarkers)
    --hooksecurefunc(WorldMapFrame.ScrollContainer, "ZoomIn", RefreshMapMarkers)
    --hooksecurefunc(WorldMapFrame.ScrollContainer, "ZoomOut", RefreshMapMarkers)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Object, function(tooltip, data)
        if InCombatLockdown()
            or not data or not data.lines[1]
        then
            return
        end

        local frame = WoWTools_WorldMapMixin:PlayerPin_GetUIFrame()
        if frame and frame:IsShown() and not WoWTools_DataMixin.Player.husandro then
            return
        end

        local text= WoWTools_TextMixin:CN(data.lines[1].leftText)
        if text then
            local xy, mapID= WoWTools_WorldMapMixin:GetTextForXY(nil, nil, nil, true)
            if xy and mapID then
                if IsControlKeyDown() and IsAltKeyDown() then
                    WoWTools_WorldMapMixin:PlayerPin_ShowUI({
                        isNew= true,
                        mapID= mapID,
                        xy= xy,
                        name= text,
                    })
                elseif SaveWoW()[mapID] and SaveWoW()[mapID][xy] then
                    GameTooltip_AddColoredLine(tooltip,
                        WoWTools_DataMixin.Icon.icon2..'Ctr+Alt '
                        ..(WoWTools_DataMixin.onlyChinese and '更新' or UPDATE)
                        ..'|A:Gear:0:0|a',
                        HIGHLIGHT_FONT_COLOR
                    )
                    tooltip:Show()
                else
                    GameTooltip_AddInstructionLine(tooltip,
                        WoWTools_DataMixin.Icon.icon2..'Ctr+Alt '
                        ..(WoWTools_DataMixin.onlyChinese and '新建' or NEW)
                        ..'|A:Gear:0:0|a'..xy
                    )
                    tooltip:Show()
                end
            end
        end
    end)

    if WoWTools_DataMixin.Player.husandro then
        C_Timer.After(2, function()
            WoWTools_WorldMapMixin:PlayerPin_ShowUI()
        end)
    end

    Init=function()
        RefreshMapMarkers()
        Button:SetShown(not Save().disabled)
    end
end





function WoWTools_WorldMapMixin:PlayerPin_InitPins()
    Init()
end


function WoWTools_WorldMapMixin:PlayerPin_RefreshPins()
    if _G['WoWToolsWorldMapMenuButton'] and WorldMapFrame:IsShown() then
        RefreshMapMarkers()
    end
end

function WoWTools_WorldMapMixin:PlayerPin_SetPinState(mapID, xy)
    if not Button or WorldMapFrame.mapID~=mapID then
        return
    end
    for b in Button.pool:EnumerateActive() do
        b:SetButtonState(xy and b.data and b.data.xy==xy and 'PUSHED' or 'NORMAL')
    end
end
