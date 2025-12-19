local function Set_Move(frame, name, isFuoriScreen)
    if not frame then
        return
    end

    frame.saveName= name

    if isFuoriScreen then
        frame:SetClampedToScreen(false)
    end

    local p= WoWTools_MoveMixin:Save().point[name]
    if p and p[1] then
        frame:ClearAllPoints()
        frame:SetPoint(p[1], frame:GetParent(), p[3], p[4], p[5])
    end

    frame:SetMovable(true)
    frame:RegisterForDrag('LeftButton', 'RightButton')
    frame:SetScript('OnMouseUp', function()
        ResetCursor()
    end)
    frame:SetScript('OnMouseDown', function()
        SetCursor('UI_MOVE_CURSOR')
    end)
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            WoWTools_MoveMixin:Save().point[self.saveName]= {self:GetPoint(1)}
            WoWTools_MoveMixin:Save().point[self.saveName][2]= nil
        end
    end)
end











function WoWTools_MoveMixin.Events:Blizzard_HouseEditor()

    --WoWTools_TextureMixin:CreateBG(HouseEditorFrame.StoragePanel, {isColor=true, isAllpoint=true, alpha=0.5})
    HouseEditorFrame.StoragePanel.SearchBox:SetPoint('TOPLEFT', 43, -20)--<Anchor point="TOPLEFT" x="20" y="-20"/>]]
--编辑住宅器
    Set_Move(HouseEditorFrame.StoragePanel, 'HouseStorage', true)

--编辑住宅外观
    Set_Move(HouseEditorFrame.ExteriorCustomizationModeFrame.FixtureOptionList, 'HouseExterior', true)

    Set_Move(HouseEditorFrame.StorageButton, 'HouseStorageButton', false)

    Set_Move(HouseEditorFrame.ModeBar, 'HouseBar', false)

--菜单
    local menu= CreateFrame('DropdownButton', 'WoWToolsHouseEditorFrameMenuButton', HouseEditorFrame.StoragePanel, 'WoWToolsMenuTemplate')
    menu:SetPoint('TOPLEFT', 23, 0)
    function menu:set_scale()
        local s= WoWTools_MoveMixin:Save().scale['HouseStorage'] or 1
        HouseEditorFrame.StoragePanel:SetScale(s)
    end
    menu:set_scale()

--菜单
    menu:SetupMenu(function(frame, root)
 --缩放
        WoWTools_MenuMixin:ScaleRoot(frame, root, function()
            return self:Save().scale['HouseStorage'] or 1
        end, function(value)
            self:Save().scale['HouseStorage']= value
            frame:set_scale()
        end, function()
--重置缩放
            self:Save().scale['HouseStorage']= nil
            frame:set_scale()
--重置位置
            if self:Save().point['HouseStorage'] then
                self:Save().point['HouseStorage']= nil
                HouseEditorFrame.StoragePanel:ClearAllPoints()
                HouseEditorFrame.StoragePanel:SetPoint('LEFT', 0, 150)--<Anchor point="LEFT" x="0" y="150"/> Blizzard_HouseEditor.xml
            end
            if self:Save().point['HouseExterior'] then
                self:Save().point['HouseExterior']= nil
                HouseEditorFrame.ExteriorCustomizationModeFrame.FixtureOptionList:ClearAllPoints()
                HouseEditorFrame.ExteriorCustomizationModeFrame.FixtureOptionList:SetPoint('TOPLEFT', HouseEditorFrame.ExteriorCustomizationModeFrame , 'LEFT', 80, -200)--<Anchor point="TOPLEFT" relativePoint="LEFT" x="80" y="200"/>
            end

            if self:Save().point['HouseBar'] then
                self:Save().point['HouseBar']= nil
                HouseEditorFrame.ModeBar:ClearAllPoints()
                HouseEditorFrame.ModeBar:SetPoint('BOTTOM', 0, 0)--<Anchor point="BOTTOM" x="0" y="0"/>
            end
        end)
    end)

    C_Timer.After(0.1, function()
        HouseEditorFrame.StoragePanel.ResizeButton:SetMinHeight(525)
        HouseEditorFrame.StoragePanel.ResizeButton:SetMinWidth(220)--需要延迟
        HouseEditorFrame.StoragePanel.ResizeButton.maxWidth = nil
        HouseEditorFrame.StoragePanel.ResizeButton.maxHeight = nil
        local size= self:Save().size['HouseStorage']
        if size and size[1] then
            HouseEditorFrame.StoragePanel:SetSize(size[1], size[2])
        end
        HouseEditorFrame.StoragePanel:HookScript('OnSizeChanged', function(_, w, h)
            self:Save().size['HouseStorage']= {w, h}
        end)
    end)
end














 --11.2.7
function WoWTools_MoveMixin.Events:Blizzard_HousingDashboard()
    HousingDashboardFrame.HouseInfoContent.DashboardNoHousesFrame.Background:ClearAllPoints()
    HousingDashboardFrame.HouseInfoContent.DashboardNoHousesFrame.Background:SetAllPoints(HousingDashboardFrame.HouseInfoContent.DashboardNoHousesFrame)

--WoWTools_DataMixin:Hook(HousingDashboardFrame, 'UpdateSizeToContent', function(contentFrame)
    local size= self:Save().size[HousingDashboardFrame:GetName()]
    if size and size[1] and size[2] then
        HousingDashboardFrame.baseWidth, HousingDashboardFrame.baseHeight= size[1], size[2]
    end

    self:Setup(HousingDashboardFrame, {
        minW=405, minH=455,
    sizeRestFunc=function(f)
        f:SetSize(814, 544)
--这个是修改参数，可能会有BUG
        f.baseWidth, f.baseHeight= 814, 544
    end})
    self:Setup(HousingDashboardFrame.HouseInfoContent.DashboardNoHousesFrame, {frame=HousingDashboardFrame})
end







--住房
function WoWTools_MoveMixin.Events:Blizzard_HousingBulletinBoard()
    HousingBulletinBoardFrame.ResidentsTab:SetPoint('BOTTOMRIGHT')
    self:Setup(HousingBulletinBoardFrame, {
    sizeRestFunc=function(f)
        f:SetSize(600, 400)
    end
    })
end





function WoWTools_MoveMixin.Events:Blizzard_HousingCharter()
    self:Setup(HousingCharterFrame)
end










--住宅区登记表
function WoWTools_MoveMixin.Events:Blizzard_HousingCreateNeighborhood()
    self:Setup(HousingCreateNeighborhoodCharterFrame)
end










--住宅信息板
function WoWTools_MoveMixin.Events:Blizzard_HousingCornerstone()
    self:Setup(HousingCornerstoneVisitorFrame)
    self:Setup(HousingCornerstonePurchaseFrame)
    self:Setup(HousingCornerstoneHouseInfoFrame)
end











--住宅搜索器
function WoWTools_MoveMixin.Events:Blizzard_HousingHouseFinder()
    HouseFinderFrame.HouseFinderMapCanvasFrame:SetPoint('BOTTOMRIGHT')
    HouseFinderFrame.NeighborhoodListFrame:SetPoint('BOTTOM')
    self:Setup(HouseFinderFrame,  {
    sizeRestFunc=function(f)
        f:SetSize(954, 489)
    end})
    self:Setup(HouseFinderFrame.PlotInfoFrame, {frame=HouseFinderFrame})
end








function WoWTools_MoveMixin.Events:Blizzard_HousingHouseSettings()
    self:Setup(HousingHouseSettingsFrame)
end

function WoWTools_MoveMixin.Events:Blizzard_HousingControls()
    self:Setup(HousingControlsFrame, {notZoom=true})
    HousingControlsFrame:SetClampedToScreen(true)
end

function WoWTools_MoveMixin.Events:Blizzard_HousingModelPreview()
    self:Setup(HousingModelPreviewFrame, {
    sizeRestFunc=function(f)
        f:SetSize(450, 545)
    end})
end
