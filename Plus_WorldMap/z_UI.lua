

--世界地图
function WoWTools_TextureMixin.Events:Blizzard_WorldMap()
    self:SetButton(WorldMapFrameCloseButton)
    self:SetButton(WorldMapFrame.BorderFrame.MaximizeMinimizeFrame.MaximizeButton)
    self:SetButton(WorldMapFrame.BorderFrame.MaximizeMinimizeFrame.MinimizeButton)
    self:SetButton(WorldMapFrame.BorderFrame.Tutorial)

    self:SetNineSlice(WorldMapFrame.BorderFrame, self.min)
    self:HideTexture(WorldMapFrameBg)
    self:SetAlphaColor(QuestMapFrame.Background)
    self:HideTexture(WorldMapFrame.NavBar.overlay)
    self:HideTexture(WorldMapFrame.NavBar.InsetBorderBottom)
    self:HideTexture(WorldMapFrame.NavBar.InsetBorderRight)
    self:HideTexture(WorldMapFrame.NavBar.InsetBorderLeft)
    self:HideTexture(WorldMapFrame.NavBar.InsetBorderBottomRight)
    self:HideTexture(WorldMapFrame.NavBar.InsetBorderBottomLeft)
    self:HideTexture(WorldMapFrame.BorderFrame.InsetBorderTop)
    WorldMapFrame.NavBar:DisableDrawLayer('BACKGROUND')

    hooksecurefunc(WorldMapFrame, 'SynchronizeDisplayState', function(frame)--最大化时，隐藏背景
        if frame:IsMaximized() then
            frame.BlackoutFrame:Hide()
        end
    end)



    self:SetScrollBar(QuestMapDetailsScrollFrame)

    self:SetFrame(QuestMapFrame.QuestsFrame.DetailsFrame.BorderFrame, {alpha=0})
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
    hooksecurefunc(QuestLogHeaderCodeMixin, 'OnLoad', function(btn)
        self:SetFrame(btn, {alpha=0.7})
    end)

    for _, frame in ipairs(WorldMapFrame.overlayFrames or {}) do
        self:SetFrame(frame, {alpha=0.5})
    end
    self:SetButton(WorldMapFrame.SidePanelToggle.CloseButton, {alpha=0.5})
    self:SetButton(WorldMapFrame.SidePanelToggle.OpenButton, {alpha=0.5})



    self:SetFrame(WorldMapFrame.NavBar.overlay, {alpha=0})

    WorldMapFrame.BorderFrame.PortraitContainer:SetSize(48,48)
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
    --frame.questLogWidth = 333;


    local function set_min_max_value(size)
        local frame= WorldMapFrame
        local isMax= frame:IsMaximized()

        if isMax then
            frame.minimizedWidth= minimizedWidth
            frame.minimizedHeight= minimizedHeight
            frame.BorderFrame.MaximizeMinimizeFrame:Maximize()
            if self:Save().size[frame:GetName()] then
                frame:UpdateMaximizedSize()
            end

        elseif size then
            local w= size[1]-(frame.questLogWidth or 333)+2
            frame.minimizedWidth= w
            frame.minimizedHeight= size[2]
            frame.BorderFrame.MaximizeMinimizeFrame:Minimize()
        end
    end

    hooksecurefunc(WorldMapFrame, 'Minimize', function(frame)
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
    hooksecurefunc(WorldMapFrame, 'Maximize', function(frame)
        set_min_max_value()
        if self:Save().scale[frame:GetName()] then
            frame:SetScale(1)
        end
        frame.ResizeButton:SetShown(false)
    end)

    self:Setup(WorldMapFrame, {
        minW=(WorldMapFrame.questLogWidth or 333)*2+37,
        minH=WorldMapFrame.questLogWidth,
        setSize=true,
        --onShowFunc=true,
        --notMoveAlpha=true,
        sizeUpdateFunc= function()--WorldMapMixin:UpdateMaximizedSize()
            set_min_max_value({WorldMapFrame:GetSize()})
        end,
        sizeRestFunc= function()
            WorldMapFrame.minimizedWidth= minimizedWidth
            WorldMapFrame.minimizedHeight= minimizedHeight
            WorldMapFrame:SetSize(minimizedWidth+ (WorldMapFrame.questLogWidth or 290), minimizedHeight)
            WorldMapFrame.BorderFrame.MaximizeMinimizeFrame:Minimize()
        end, sizeTooltip='|cnRED_FONT_COLOR:BUG|r'
    })


    QuestMapDetailsScrollFrame:SetPoint('BOTTOM', 0, 72)

    QuestMapFrame.DetailsFrame:SetPoint('BOTTOM')
    QuestMapDetailsScrollFrame.Contents:SetPoint('BOTTOMLEFT')

    QuestMapFrame.DetailsFrame.Bg:SetPoint('BOTTOM', 0, 23)
    QuestMapFrame.DetailsFrame.SealMaterialBG:SetPoint('BOTTOM', 0, 23)

    WorldMapFrame.ScrollContainer.Child.TiledBackground:ClearAllPoints()
    WorldMapFrame.ScrollContainer.Child.TiledBackground:SetAllPoints()

   -- QuestMapFrame.QuestsFrame.DetailsFrame:SetFrameLevel(WorldMapFrame.BorderFrame:GetFrameLevel()+1)
    --QuestMapFrame.QuestsFrame.DetailsFrame:GetFrameStrata()
    QuestMapFrame.QuestsFrame.DetailsFrame:GetFrameLevel(501)
    QuestMapFrame.QuestsFrame.DetailsFrame:GetFrameStrata('HIGH')
    

    QuestScrollFrame.Background:SetPoint('BOTTOM', 0, 123)
    QuestScrollFrame.Background:SetAllPoints()

    self:Setup(QuestScrollFrame, {frame=WorldMapFrame})
    self:Setup(MapQuestInfoRewardsFrame, {frame=WorldMapFrame})
    self:Setup(QuestMapFrame, {frame=WorldMapFrame})
    self:Setup(QuestMapFrame.DetailsFrame, {frame=WorldMapFrame})
    self:Setup(QuestMapDetailsScrollFrame, {frame=WorldMapFrame})


end