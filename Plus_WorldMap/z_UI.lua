--世界地图
function WoWTools_TextureMixin.Events:Blizzard_WorldMap()
    self:SetButton(WorldMapFrameCloseButton)
    self:SetButton(WorldMapFrame.BorderFrame.MaximizeMinimizeFrame.MaximizeButton)
    self:SetButton(WorldMapFrame.BorderFrame.MaximizeMinimizeFrame.MinimizeButton)
    self:SetButton(WorldMapFrame.BorderFrame.Tutorial)

    self:SetNineSlice(WorldMapFrame.BorderFrame)
    self:HideTexture(WorldMapFrameBg)
    self:SetAlphaColor(QuestMapFrame.Background)
    self:SetNavBar(WorldMapFrame)

    self:HideTexture(WorldMapFrame.BorderFrame.InsetBorderTop)
--最大化时，隐藏背景
    WoWTools_DataMixin:Hook(WorldMapFrame, 'SynchronizeDisplayState', function(frame)
        if frame:IsMaximized() then
            frame.BlackoutFrame:Hide()
        end
    end)



    self:SetScrollBar(QuestMapDetailsScrollFrame)

    self:SetFrame(QuestMapFrame.QuestsFrame.DetailsFrame.BorderFrame, {alpha=0})
    self:SetUIButton(QuestMapFrame.QuestsFrame.DetailsFrame.AbandonButton)
    self:SetUIButton(QuestMapFrame.QuestsFrame.DetailsFrame.ShareButton)
    self:SetUIButton(QuestMapFrame.QuestsFrame.DetailsFrame.TrackButton)
--共享，两边, 材质
    for _, icon in pairs({QuestMapFrame.QuestsFrame.DetailsFrame.ShareButton:GetRegions()}) do
        if icon:IsObjectType("Texture") then
            local atlas= icon:GetAtlas()
            if atlas=='UI-Frame-BtnDivMiddle' or atlas=='UI-Frame-BtnDivMiddle' then
                icon:SetTexture(0)
            end
        end
    end
--战役
    self:SetScrollBar(QuestMapFrame.QuestsFrame.CampaignOverview.ScrollFrame)
    self:SetAlphaColor(QuestMapFrame.QuestsFrame.CampaignOverview.BorderFrame.Border, true)


    self:HideTexture(QuestMapFrame.QuestsTab.Background)
    self:HideTexture(QuestMapFrame.QuestsTab.SelectedTexture)

    self:HideTexture(QuestMapFrame.EventsTab.Background)--11.2才有

    self:SetFrame(QuestMapFrame.MapLegend.BorderFrame, {alpha=0})
    self:HideTexture(QuestMapFrame.MapLegendTab.Background)



    self:SetFrame(QuestScrollFrame.BorderFrame, {alpha=0})
    self:SetScrollBar(QuestScrollFrame)
    self:SetAlphaColor(QuestScrollFrame.Background, nil, nil, 0.5)

    self:SetAlphaColor(QuestScrollFrame.SettingsDropdown.Icon, nil, nil, 0.9)
    self:SetEditBox(QuestScrollFrame.SearchBox)

    self:SetScrollBar(MapLegendScrollFrame)
    self:SetAlphaColor(MapLegendScrollFrame.Background, nil, nil, 0.3)

--任务，列表 QuestLogHeaderCodeTemplate
    WoWTools_DataMixin:Hook(QuestLogHeaderCodeMixin, 'OnLoad', function(btn)
        self:SetFrame(btn, {alpha=0.7})
    end)
--战役, 列表
    WoWTools_DataMixin:Hook(CampaignHeaderDisplayMixin, 'SetCampaign', function(btn)
        self:SetAlphaColor(btn.Background, nil, true)
    end)

    for _, frame in ipairs(WorldMapFrame.overlayFrames or {}) do
        self:SetFrame(frame, {alpha=0.5})
        self:SetButton(frame.BountyDropdown)
    end

    self:SetButton(WorldMapFrame.SidePanelToggle.CloseButton, 0.5)
    self:SetButton(WorldMapFrame.SidePanelToggle.OpenButton, 0.5)

    self:SetFrame(WorldMapFrame.NavBar.overlay, {alpha=0})

    WorldMapFrame.BorderFrame.PortraitContainer:SetSize(48,48)

    WoWTools_DataMixin:Hook(WorldMapFrame, 'Minimize', function(frame)
       frame.BorderFrame.PortraitContainer:SetSize(48,48)
    end)
    WoWTools_DataMixin:Hook(WorldMapFrame, 'Maximize', function(frame)
        frame.BorderFrame.PortraitContainer:SetSize(23,23)
    end)

    self:SetNineSlice(QuestScrollFrame.CampaignTooltip, 0.5, true)

--事件
    if QuestMapFrame.EventsFrame then--11.2.7才有
        self:SetFrame(QuestMapFrame.EventsFrame, {alpha=0})
        self:SetScrollBar(QuestMapFrame.EventsFrame)
        self:HideTexture(QuestMapFrame.EventsFrame.BorderFrame.Border)
        self:SetAlphaColor(QuestMapFrame.EventsFrame.ScrollBox.Background, nil, true)
        WoWTools_DataMixin:Hook(EventSchedulerOngoingEntryMixin, 'Init', function(frame)
            self:SetAlphaColor(frame.Background, true)
        end)
        WoWTools_DataMixin:Hook(EventSchedulerBaseLabelMixin, 'Init', function(frame)
            self:SetAlphaColor(frame.Background, true)
        end)
    end

    self:Init_BGMenu_Frame(WorldMapFrame, {
        PortraitContainer=WorldMapFrame.BorderFrame.PortraitContainer,
        NineSlice= WorldMapFrame.BorderFrame.NineSlice,
        settings=function(_, _, _, nineSliceAlpha, portraitAlpha)
            self:SetNineSlice(WorldMapFrame.BorderFrame, nineSliceAlpha)
            WorldMapFramePortrait:SetAlpha(portraitAlpha or 1)
        end
    })
end


















function WoWTools_MoveMixin.Events:Blizzard_WorldMap()
    local minimizedWidth= WorldMapFrame.minimizedWidth or 702
    local minimizedHeight= WorldMapFrame.minimizedHeight or 534
    local questLogWidth= WorldMapFrame.questLogWidth or 333


    local function set_min_max_value(size)
        if WoWTools_FrameMixin:IsLocked(WorldMapFrame) then
            return
        end
        local isMax= WorldMapFrame:IsMaximized()
        if isMax then
            WorldMapFrame.minimizedWidth= minimizedWidth
            WorldMapFrame.minimizedHeight= minimizedHeight
            WorldMapFrame.BorderFrame.MaximizeMinimizeFrame:Maximize()
            if self:Save().size[WorldMapFrame:GetName()] then
                WorldMapFrame:UpdateMaximizedSize()
            end

        elseif size and size[1] then
            local w= size[1] -questLogWidth-- +2
            WorldMapFrame.minimizedWidth= w
            WorldMapFrame.minimizedHeight= size[2] or minimizedHeight
            WorldMapFrame.BorderFrame.MaximizeMinimizeFrame:Minimize()
        end
    end

    WoWTools_DataMixin:Hook(WorldMapFrame.SidePanelToggle, 'Refresh', function()
        local name= WorldMapFrame:GetName()
        if self:Save().size[name] and not WorldMapFrame:IsMaximized() then
            self:Save().size[name]= {WorldMapFrame:GetSize()}
        end
    end)


    WoWTools_DataMixin:Hook(WorldMapFrame, 'Minimize', function(frame)
        if not frame.ResizeButton then
            return
        end
        local name= frame:GetName()
        local size= self:Save().size[name]
        if size then
            frame:SetSize(size[1], size[2])
            set_min_max_value(size)
        end
        local scale= self:Save().scale[name]
        if scale then
            frame:SetScale(scale)
        end
        frame.ResizeButton:SetShown(true)
    end)
    WoWTools_DataMixin:Hook(WorldMapFrame, 'Maximize', function(frame)
        if not frame.ResizeButton then
            return
        end
        set_min_max_value()
        if self:Save().scale[frame:GetName()] then
            frame:SetScale(1)
        end
        frame.ResizeButton:SetShown(false)
    end)

    self:Setup(WorldMapFrame, {
        minW=questLogWidth*2+37,
        minH=questLogWidth,
        sizeUpdateFunc= function()--WorldMapMixin:UpdateMaximizedSize()
            set_min_max_value({WorldMapFrame:GetSize()})
        end,
        sizeRestFunc= function()
            WorldMapFrame.minimizedWidth= minimizedWidth
            WorldMapFrame.minimizedHeight= minimizedHeight
            WorldMapFrame:SetSize(minimizedWidth+ questLogWidth, minimizedHeight)
            WorldMapFrame.BorderFrame.MaximizeMinimizeFrame:Minimize()
        end, sizeTooltip='|cnWARNING_FONT_COLOR:BUG|r'
    })


    QuestMapDetailsScrollFrame:SetPoint('BOTTOM', 0, 72)

    QuestMapFrame.DetailsFrame:SetPoint('BOTTOM')
    QuestMapDetailsScrollFrame.Contents:SetPoint('BOTTOMLEFT')

    QuestMapFrame.DetailsFrame.Bg:SetPoint('BOTTOM', 0, 23)
    QuestMapFrame.DetailsFrame.SealMaterialBG:SetPoint('BOTTOM', 0, 23)

    WorldMapFrame.ScrollContainer.Child.TiledBackground:ClearAllPoints()
    WorldMapFrame.ScrollContainer.Child.TiledBackground:SetAllPoints()

    QuestMapFrame.QuestsFrame.DetailsFrame:GetFrameLevel(501)
    QuestMapFrame.QuestsFrame.DetailsFrame:GetFrameStrata('HIGH')


    QuestScrollFrame.Background:SetPoint('BOTTOM', 0, 123)
    QuestScrollFrame.Background:SetAllPoints()

    self:Setup(QuestScrollFrame, {frame=WorldMapFrame})
    self:Setup(MapQuestInfoRewardsFrame, {frame=WorldMapFrame})
    self:Setup(QuestMapFrame, {frame=WorldMapFrame})
    self:Setup(QuestMapFrame.DetailsFrame, {frame=WorldMapFrame})
    self:Setup(QuestMapDetailsScrollFrame, {frame=WorldMapFrame})

--战役
    QuestMapFrame.QuestsFrame.CampaignOverview.Header:SetFrameLevel(QuestMapFrame.QuestsFrame.CampaignOverview.BorderFrame:GetFrameLevel()+1)
    self:Setup(QuestMapFrame.QuestsFrame.CampaignOverview.BorderFrame, {frame=WorldMapFrame})
    


end