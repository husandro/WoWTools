
--住房 查找器 11.2.7
function WoWTools_TextureMixin.Events:Blizzard_HousingBulletinBoard()
    self:SetButton(HousingBulletinBoardFrame.CloseButton)
    self:SetAlphaColor(HousingBulletinBoardFrame.GearDropdown.Icon, true)
    self:SetScrollBar(HousingBulletinBoardFrame.ResidentsTab)
    self:HideTexture(HousingBulletinBoardFrame.Background)
    self:SetAlphaColor(HousingBulletinBoardFrame.Footer)
end
--住宅信息板
function WoWTools_TextureMixin.Events:Blizzard_HousingCornerstone()
    self:SetButton(HousingCornerstoneVisitorFrameCloseButton)
    self:SetAlphaColor(HousingCornerstoneVisitorFrame.Background)
    self:SetButton(HousingCornerstoneVisitorFrame.GearDropdown, 1)

    self:SetButton(HousingCornerstonePurchaseFrameCloseButton)
    self:SetNineSlice(HousingCornerstonePurchaseFrame.MoneyFrameBackdrop)

    self:SetButton(HousingCornerstoneHouseInfoFrameCloseButton)
    self:SetAlphaColor(HousingCornerstoneHouseInfoFrame.GearDropdown.Icon, true)
end
--住宅信息板
function WoWTools_TextureMixin.Events:Blizzard_HousingDashboard()
--11.2.7中显示图标，会出错
    WoWTools_DataMixin:Hook(HousingDashboardFrame.CatalogContent, 'UpdateCategoryText', function(frame)
        local categoryString = frame.Categories:GetFocusedCategoryString()
        if categoryString then
            local t= WoWTools_TextMixin:CN(categoryString:match('(.+) ||TInterfaceIcons.+|t'))
            if t then
                frame.OptionsContainer.CategoryText:SetText(WoWTools_TextMixin:CN(t))
            end
        end
    end)

    self:SetButton(HousingDashboardFrameCloseButton)
    self:SetNineSlice(HousingDashboardFrame)
    self:SetFrame(HousingDashboardFrame, {alpha=0})

    self:SetAlphaColor(HousingDashboardFrame.HouseInfoTabButton.Icon, true)
    self:SetAlphaColor(HousingDashboardFrame.CatalogTabButton.Icon, true)
    self:SetScrollBar(HousingDashboardFrame.CatalogContent.OptionsContainer)
    --HousingDashboardFrame.CatalogContent.TempDisclaimer.DisclaimerText:SetAlpha(0.3)

    self:SetUIButton(HousingDashboardFrame.HouseInfoContent.DashboardNoHousesFrame.NoHouseButton)

    self:SetAlphaColor(HousingDashboardFrame.HouseInfoContent.ContentFrame.HouseUpgradeFrame.TrackFrame.Background, nil, nil, 0.3)
    self:SetButton(HousingDashboardFrame.HouseInfoContent.ContentFrame.HouseUpgradeFrame.TrackFrame.JumpLeftButton, 1)
    self:SetButton(HousingDashboardFrame.HouseInfoContent.ContentFrame.HouseUpgradeFrame.TrackFrame.LeftButton, 1)
    self:SetButton(HousingDashboardFrame.HouseInfoContent.ContentFrame.HouseUpgradeFrame.TrackFrame.RightButton, 1)
    self:SetButton(HousingDashboardFrame.HouseInfoContent.ContentFrame.HouseUpgradeFrame.TrackFrame.JumpRightButton, 1)
    self:SetCheckBox(HousingDashboardFrame.HouseInfoContent.ContentFrame.HouseUpgradeFrame.WatchFavorButton)

    self:SetButton(HousingDashboardFrame.HouseInfoContent.ContentFrame.HouseUpgradeFrame.TeleportToHouseButton, 1)
    HousingDashboardFrame.HouseInfoContent.ContentFrame.HouseUpgradeFrame.TeleportToHouseButton:HookScript('OnEnter', function()
        WoWTools_TooltipMixin:Set_Spell(GameTooltip, 1233637)--https://www.wowhead.com/cn/spell=1233637/传送回家
    end)
    HousingDashboardFrame.HouseInfoContent.ContentFrame.HouseUpgradeFrame.TrackFrame.ClipFrame:EnableMouseWheel(true)
    HousingDashboardFrame.HouseInfoContent.ContentFrame.HouseUpgradeFrame.TrackFrame.ClipFrame:SetScript('OnMouseWheel', function(frame, d)
        local parent= frame:GetParent()
        local b= d==1 and parent.LeftButton or parent.RightButton
        b:OnMouseDown()
    end)


    WoWTools_TextureMixin:Init_BGMenu_Frame(HousingDashboardFrame, {
        alpha=0.5,
        nineSliceAlpha=0,
        portraitAlpha=0.5,
        settings=function(_, textureName, alphaValue)--设置内容时，调用
            local alpha= textureName and 0 or alphaValue or 1
            self:SetAlphaColor(HousingDashboardFrame.CatalogContent.PreviewFrame.PreviewBackground, nil, true, alpha)
            self:SetAlphaColor(HousingDashboardFrame.CatalogContent.Background, nil, true, alpha)
            self:SetAlphaColor(HousingDashboardFrame.CatalogContent.Categories.Background, nil, true, alpha)
            self:SetAlphaColor(HousingDashboardFrame.CatalogContent.Categories.TopBorder, nil, true, alpha)
            self:SetAlphaColor(HousingDashboardFrame.CatalogContent.Divider, nil, nil, alpha)
            self:SetAlphaColor(HousingDashboardFrame.HouseInfoContent.ContentFrame.HouseUpgradeFrame.Background, nil, nil, alpha)

            alpha= math.max(alphaValue, 0.5)
            self:SetAlphaColor(HousingDashboardFrame.HouseInfoContent.DashboardNoHousesFrame.Background, nil, true, alpha)
        end
    })
end

function WoWTools_TextureMixin.Events:Blizzard_HousingCharter()
    self:SetAlphaColor(HousingCharterFrame.Background)
end

--住宅区登记表 11.2.7
function WoWTools_TextureMixin.Events:Blizzard_HousingCreateNeighborhood()
    self:SetEditBox(HousingCreateNeighborhoodCharterFrame.NeighborhoodNameEditBox)
    self:SetAlphaColor(HousingCreateNeighborhoodCharterFrame.Background)
end
--住宅搜索器
function WoWTools_TextureMixin.Events:Blizzard_HousingHouseFinder()
    self:SetButton(HouseFinderFrameCloseButton)
    self:SetNineSlice(HouseFinderFrame)

    self:SetEditBox(HouseFinderFrame.NeighborhoodListFrame.BNetFriendSearchBox)
    self:SetButton(HouseFinderFrame.NeighborhoodListFrame.RefreshButton, {alpa=1})
    self:SetAlphaColor(HouseFinderFrame.NeighborhoodListFrame.NeighborhoodTitleBG, true)
    self:HideTexture(HouseFinderFrame.NeighborhoodListFrame.NeighborhoodListBG)
    self:HideFrame(HouseFinderFrame.NeighborhoodListFrame.ListBottomGradient)
    self:SetScrollBar(HouseFinderFrame.NeighborhoodListFrame.ScrollFrame)

    self:HideTexture(HouseFinderFrame.TopTileStreaks)
    self:HideTexture(HouseFinderFrame.WoodBorderFrame.Border)

    self:SetUIButton(HouseFinderFrame.PlotInfoFrame.VisitHouseButton)
    self:SetAlphaColor(HouseFinderFrame.PlotInfoFrame.BackButton.Icon, true)
    self:SetAlphaColor(HouseFinderFrame.PlotInfoFrame.PlotTitleBG, true)
    self:HideTexture(HouseFinderFrameBg)
end

function WoWTools_TextureMixin.Events:Blizzard_HousingHouseSettings()
    self:SetAlphaColor(HousingHouseSettingsFrame.Background)
    self:SetButton(HousingHouseSettingsFrame.CloseButton)
    for _, option in pairs(HousingHouseSettingsFrame.PlotAccess.accessOptions or {}) do
        self:SetCheckBox(option.Checkbox)
    end
        for _, option in pairs(HousingHouseSettingsFrame.HouseAccess.accessOptions or {}) do
        self:SetCheckBox(option.Checkbox)
    end
end


function WoWTools_TextureMixin.Events:Blizzard_HouseEditor()
    HouseEditorFrame.StoragePanel.InputBlocker:DisableDrawLayer('BACKGROUND')--按钮，背景 HouseEditorStorageFrameTemplate

    self:SetScrollBar(HouseEditorFrame.StoragePanel.OptionsContainer)
    self:SetAlphaColor(HouseEditorFrame.StoragePanel.CollapseButton.Icon, nil, nil, 0.5)
    self:SetAlphaColor(HouseEditorFrame.StorageButton.Icon, nil, nil, 0.5)
    self:SetAlphaColor(HouseEditorFrame.StoragePanel.HeaderBackground)

    HouseEditorFrame.StoragePanel.ResizeButton:SetHighlightTexture('Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight')
    HouseEditorFrame.StoragePanel.ResizeButton:SetPushedTexture('Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down')

    self:SetButton(HouseEditorFrame.StoragePanel.ResizeButton, {alpha=1})
    HouseEditorFrame.StoragePanel.ResizeButton:SetAlpha(0.5)
    HouseEditorFrame.StoragePanel.ResizeButton:HookScript('OnLeave', function(b) b:SetAlpha(0.5) end)
    HouseEditorFrame.StoragePanel.ResizeButton:HookScript('OnEnter', function(b) b:SetAlpha(1) end)

    self:Init_BGMenu_Frame(HouseEditorFrame.StoragePanel, {
        name='HouseEditorStoragePanel',
        enabled=true,
        isNewButton=true,
        newButtonPoint=function(btn)
            btn:SetPoint('TOPLEFT')
        end,
        settings=function(_, texture, alpha)
            alpha= texture and 0 or alpha or 0.5
            self:SetAlphaColor(HouseEditorFrame.StoragePanel.Background, nil, nil, alpha)
            self:SetAlphaColor(HouseEditorFrame.StoragePanel.Categories.Background, nil, nil, alpha)
            self:SetAlphaColor(HouseEditorFrame.StoragePanel.Categories.TopBorder, nil, nil, alpha)
            HouseEditorFrame.StoragePanel.ResizeButton:SetNormalTexture(texture and 0 or 'Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up')
        end,
    })

    self:HideTexture(HouseEditorFrame.ModeBar.BookendRight)
    self:HideTexture(HouseEditorFrame.ModeBar.BookendLeft)
    self:HideTexture(HouseEditorFrame.ModeBar.Background)
    self:HideTexture(HouseEditorFrame.ModeBar.GradientBackground)

    self:SetButton(HouseEditorFrame.ExteriorCustomizationModeFrame.FixtureOptionList.CloseButton)
    self:SetScrollBar(HouseEditorFrame.ExteriorCustomizationModeFrame.FixtureOptionList)
    --self:SetAlphaColor(HouseEditorFrame.ExteriorCustomizationModeFrame.FixtureOptionList.Background)
    self:SetAlphaColor(HouseEditorFrame.ExteriorCustomizationModeFrame.FixtureOptionList.Header)

end



function WoWTools_TextureMixin.Events:Blizzard_HousingModelPreview()
    self:SetButton(HousingModelPreviewFrameCloseButton)
    --self:SetModelZoom(HousingModelPreviewFrame.ModelPreview.ModelSceneControls)
    self:HideTexture(HousingModelPreviewFrameBg)
    self:HideTexture(HousingModelPreviewFrameInset.Bg)
    self:SetNineSlice(HousingModelPreviewFrameInset)

     self:Init_BGMenu_Frame(HousingModelPreviewFrame, {
        enabled=true,
        alpha=1,
        isNewButton=true,
        newButtonPoint=function(btn)
            btn:SetPoint('RIGHT', HousingModelPreviewFrameCloseButton, 'LEFT')
        end,
        settings=function(_, texture, alpha)
            alpha= texture and 0 or alpha or 1
            self:SetAlphaColor(HousingModelPreviewFrame.ModelPreview.PreviewBackground, nil, true, alpha)
        end,
    })
    
end
