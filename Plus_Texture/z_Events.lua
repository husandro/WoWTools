


function WoWTools_TextureMixin.Events:Blizzard_TrainerUI()
    self:HideFrame(ClassTrainerFrame, {show={[ClassTrainerFramePortrait]=1}})
    self:SetScrollBar(ClassTrainerFrame)
    --self:SetNineSlice(ClassTrainerFrame)
    self:SetButton(ClassTrainerFrameCloseButton)

    self:HideTexture(ClassTrainerFrameInset.Bg)
    self:SetNineSlice(ClassTrainerFrameInset)

    self:HideTexture(ClassTrainerFrameBottomInset.Bg)
    self:SetNineSlice(ClassTrainerFrameBottomInset)

    self:HideTexture(ClassTrainerStatusBarBackground)
    self:SetAlphaColor(ClassTrainerStatusBarRight, nil, nil, 0.3)
    self:SetAlphaColor(ClassTrainerStatusBarLeft, nil, nil, 0.3)
    self:SetAlphaColor(ClassTrainerStatusBarMiddle, nil, nil, 0.3)

    ClassTrainerFrameSkillStepButton:SetNormalTexture(0)
    WoWTools_DataMixin:Hook('ClassTrainerFrame_InitServiceButton', function(btn)
        btn:SetNormalTexture(0)
    end)


    self:Init_BGMenu_Frame(ClassTrainerFrame)
end





--小时图，时间
function WoWTools_TextureMixin.Events:Blizzard_TimeManager()
    self:SetButton(TimeManagerFrameCloseButton)

    self:SetNineSlice(TimeManagerFrame, self.min, true)
    self:SetAlphaColor(TimeManagerFrameBg)

    self:HideTexture(TimeManagerFrameInset.Bg)
    self:SetNineSlice(TimeManagerFrameInset, 0)

    self:SetEditBox(TimeManagerAlarmMessageEditBox)
    self:SetMenu(TimeManagerAlarmTimeFrame.HourDropdown)
    self:SetMenu(TimeManagerAlarmTimeFrame.MinuteDropdown)



    --秒表 Blizzard_TimeManager.lua
    self:HideTexture(StopwatchFrameBackgroundLeft)
    self:SetButton(StopwatchCloseButton)
    if StopwatchFrame then
        self:HideTexture(select(2, StopwatchFrame:GetRegions()))
        self:HideTexture(StopwatchTabFrameMiddle)
        self:HideTexture(StopwatchTabFrameRight)
        self:HideTexture(StopwatchTabFrameLeft)
    end
end

















function WoWTools_TextureMixin.Events:Blizzard_AchievementUI()--成就

    self:HideFrame(AchievementFrame, {show={[AchievementFrame.Background]=true}})

    WoWTools_DataMixin:Hook(AchievementStatTemplateMixin, 'OnLoad', function(f)
        if f.Middle then
            self:SetAlphaColor(f.Middle, nil, nil, 0.5)
            self:SetAlphaColor(f.Left, nil, nil, 0.5)
            self:SetAlphaColor(f.Right, nil, nil, 0.5)
        end
    end)

--Search
    self:SetEditBox(AchievementFrame.SearchBox)
    AchievementFrame.SearchBox:ClearAllPoints()
    AchievementFrame.SearchBox:SetPoint('LEFT', AchievementFrame.Header.PointBorder, 'RIGHT')
    AchievementFrame.SearchBox:SetPoint('RIGHT', AchievementFrameCloseButton, 'LEFT', -23, 0)
    AchievementFrame.SearchPreviewContainer:SetPoint('RIGHT', AchievementFrame.SearchBox)
    for i=1, 5 do
        AchievementFrame.SearchPreviewContainer['SearchPreview'..i]:SetPoint('RIGHT')
    end
    self:SetScrollBar(AchievementFrame.SearchResults)


--Tab
    self:SetTabButton(AchievementFrameTab1, 0.3)
    self:SetTabButton(AchievementFrameTab2, 0.3)
    self:SetTabButton(AchievementFrameTab3, 0.3)

--左下边水印
    self:SetAlphaColor(AchievementFrameWaterMark, nil, true, 0)

--标题
    self:HideTexture(AchievementFrame.Header.Left)
    self:HideTexture(AchievementFrame.Header.Right)
    self:HideTexture(AchievementFrame.Header.RightDDLInset)
    self:HideTexture(AchievementFrame.Header.LeftDDLInset)
    self:HideTexture(AchievementFrame.Header.PointBorder)

    self:SetButton(AchievementFrameCloseButton)

--总列表
    self:SetNineSlice(AchievementFrameCategories)
    self:SetScrollBar(AchievementFrameCategories)
    WoWTools_DataMixin:Hook(AchievementCategoryTemplateMixin, 'OnLoad', function(f)
        self:SetAlphaColor(f.Button.Background, nil, nil, 0.5)
    end)

--成就，列表, 显示，按钮
    self:SetScrollBar(AchievementFrameAchievements)
    self:HideFrame(AchievementFrameAchievements)
    self:SetNineSlice(AchievementFrameAchievements)
    WoWTools_DataMixin:Hook(AchievementTemplateMixin, 'OnLoad', function(f)
        self:SetNineSlice(f)
    end)

    local function Set_AchievementTemplate(f, show)
        local alpha= (f.completed and not f:IsSelected() and not show) and 0 or 1
        self:SetFrame(f, {alpha=alpha, notColor=true})
--点数，外框
        f.Shield.Icon:SetAlpha(alpha)
    end
    WoWTools_DataMixin:Hook(AchievementTemplateMixin, 'Init', function(f)
        Set_AchievementTemplate(f, nil)
    end)
    WoWTools_DataMixin:Hook(AchievementTemplateMixin, 'OnEnter', function(f)
        Set_AchievementTemplate(f, true)
    end)
    WoWTools_DataMixin:Hook(AchievementTemplateMixin, 'OnLeave', function(f)
        Set_AchievementTemplate(f, nil)
    end)

--总览
    self:SetNineSlice(AchievementFrameSummary)
    self:HideFrame(AchievementFrameSummary)

--近期成就
    self:SetAlphaColor(AchievementFrameSummaryAchievementsHeaderHeader, nil, nil, 0.5)
    WoWTools_DataMixin:Hook('AchievementFrameSummaryAchievement_OnLoad', function(f)
        self:SetAlphaColor(f.Background, nil, true, 0)

        f:HookScript('OnLeave', function(f2)
            self:SetAlphaColor(f2.Background, nil, true, 0)
        end)

        self:SetNineSlice(f)
    end)
    WoWTools_DataMixin:Hook('AchievementFrameSummaryAchievement_OnEnter', function(f)
         self:SetAlphaColor(f.Background, nil, true, 1)
    end)


    self:SetAlphaColor(AchievementFrameSummaryCategoriesHeaderTexture, nil, nil, 0.5)
    self:HideTexture(AchievementFrameSummaryCategoriesStatusBarRight)
    self:HideTexture(AchievementFrameSummaryCategoriesStatusBarMiddle)
    self:HideTexture(AchievementFrameSummaryCategoriesStatusBarLeft)
    self:SetAlphaColor(AchievementFrameSummaryCategoriesStatusBarFillBar, nil, nil, 0.5)
    for i=1, 12 do
        self:HideTexture(_G['AchievementFrameCategoriesCategory'..i..'Bar'])
        self:HideTexture(_G['AchievementFrameSummaryCategoriesCategory'..i..'Right'])
        self:HideTexture(_G['AchievementFrameSummaryCategoriesCategory'..i..'Middle'])
        self:HideTexture(_G['AchievementFrameSummaryCategoriesCategory'..i..'Left'])
        self:SetAlphaColor(_G['AchievementFrameSummaryCategoriesCategory'..i..'FillBar'], nil, nil, 0.5)
    end

--比较
    AchievementFrameComparisonHeader:ClearAllPoints()
    AchievementFrameComparisonHeader:SetPoint('BOTTOMLEFT', AchievementFrameComparison, 'TOPRIGHT', -125, 15)
    self:SetFrame(AchievementFrameComparison, {alpha=0})
    self:HideTexture(AchievementFrameComparisonHeaderBG)

    --self:SetFrame(AchievementFrameComparisonHeader, {alpha=0})
    self:SetScrollBar(AchievementFrameComparison.AchievementContainer)
    self:SetNineSlice(AchievementFrameComparison)

--目标名称
    AchievementFrameComparisonHeaderName:SetWidth(0)
    AchievementFrameComparisonHeaderName:ClearAllPoints()
    AchievementFrameComparisonHeaderName:SetPoint('BOTTOMRIGHT', AchievementFrameCloseButton, 'TOPLEFT', 0, 25)

    --AchievementFrameComparisonHeaderName:SetPoint('CENTER', 0)
    AchievementFrameComparisonHeaderName:SetTextScale(1.5)
    AchievementFrameComparisonHeaderName:SetShadowOffset(1, -1)
--目标成就点数
    AchievementFrameComparisonHeader.Points:ClearAllPoints()
    AchievementFrameComparisonHeader.Points:SetPoint('BOTTOM', AchievementFrameComparisonHeaderName, 'TOP',0,2)
--创建 BG
    self:CreateBG(AchievementFrameComparisonHeader, {
        point=function(icon)
            icon:SetPoint('TOP', AchievementFrameComparisonHeader.Points, 0, 2)
            icon:SetPoint('BOTTOM', AchievementFrameComparisonHeaderName, 0, -5)
            icon:SetPoint('LEFT', AchievementFrameComparisonHeaderName, -2, 0)
            icon:SetPoint('RIGHT', AchievementFrameComparisonHeaderName, 2, 0)
        end
    })
--头像
    AchievementFrameComparisonHeaderPortrait:ClearAllPoints()
    AchievementFrameComparisonHeaderPortrait:SetPoint('BOTTOM', AchievementFrameComparisonHeader.Background, 'TOP')
    self:SetAlphaColor(AchievementFrameComparisonHeaderPortraitBg, nil, nil, 0.5)


--统计
    self:SetNineSlice(AchievementFrameStats)
    self:SetAlphaColor(AchievementFrameStatsBG, nil, nil, 0.3)
    self:SetScrollBar(AchievementFrameStats)
    self:SetScrollBar(AchievementFrameComparison.StatContainer)

    self:Init_BGMenu_Frame(AchievementFrame, {
        isNewButton=AchievementFrame.Header,
        newButtonPoint=function(btn)
            btn:SetPoint('RIGHT', AchievementFrame.Header.Points, 'LEFT', -4, 0)
        end,
        bgPoint=function(icon)
            icon:SetPoint('TOPLEFT', -3, 33)
            icon:SetPoint('BOTTOMRIGHT', 0, 2)
        end
    })
end




























--拍卖行
function WoWTools_TextureMixin.Events:Blizzard_AuctionHouseUI()
    self:HideFrame(AuctionHouseFrame)
    self:SetButton(AuctionHouseFrameCloseButton)

    self:SetTabButton(AuctionHouseFrameBuyTab)
    self:SetTabButton(AuctionHouseFrameSellTab)
    self:SetTabButton(AuctionHouseFrameAuctionsTab)
    self:SetFrame(AuctionHouseFrame.SearchBar.FilterButton, {alpha= 0.3})

    self:SetNineSlice(AuctionHouseFrame.CategoriesList)
    self:SetScrollBar(AuctionHouseFrame.CategoriesList)
    self:HideTexture(AuctionHouseFrame.CategoriesList.Background)

    self:SetScrollBar(AuctionHouseFrameAuctionsFrame.BidsList)
    self:SetNineSlice(AuctionHouseFrameAuctionsFrame.BidsList)
    self:SetNineSlice(AuctionHouseFrameAuctionsFrame.AllAuctionsList)
    self:SetScrollBar(AuctionHouseFrameAuctionsFrame.AllAuctionsList)
    self:SetScrollBar(AuctionHouseFrameAuctionsFrame.SummaryList)
    self:SetNineSlice(AuctionHouseFrameAuctionsFrame.SummaryList)

--购买
    self:SetNineSlice(AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay)
    self:SetNineSlice(AuctionHouseFrame.CommoditiesBuyFrame.ItemList)
    self:SetScrollBar(AuctionHouseFrame.CommoditiesBuyFrame.ItemList)


    self:SetNineSlice(AuctionHouseFrame.BrowseResultsFrame.ItemList)
    self:SetScrollBar(AuctionHouseFrame.BrowseResultsFrame.ItemList)

    self:SetNineSlice(AuctionHouseFrame.MoneyFrameInset)
    self:HideTexture(AuctionHouseFrame.MoneyFrameInset.Bg)
    self:HideFrame(AuctionHouseFrame.MoneyFrameBorder)

    self:SetEditBox(AuctionHouseFrame.SearchBar.SearchBox)


    self:SetNineSlice(AuctionHouseFrame.CommoditiesSellList)
    self:SetScrollBar(AuctionHouseFrame.CommoditiesSellList)
    self:SetNineSlice(AuctionHouseFrame.CommoditiesSellFrame)
    self:SetFrame(AuctionHouseFrame.CommoditiesSellFrame.ItemDisplay, {alpha=0})
    self:SetEditBox(AuctionHouseFrame.CommoditiesSellFrame.QuantityInput.InputBox)
    self:SetEditBox(AuctionHouseFrame.CommoditiesSellFrame.PriceInput.MoneyInputFrame.GoldBox)
    self:SetEditBox(AuctionHouseFrame.CommoditiesSellFrame.PriceInput.MoneyInputFrame.SilverBox)

    self:SetAlphaColor(AuctionHouseFrame.CommoditiesSellFrame.CreateAuctionTabMiddle, nil, nil, 0.3)
    self:SetAlphaColor(AuctionHouseFrame.CommoditiesSellFrame.CreateAuctionTabLeft, nil, nil, 0.3)
    self:SetAlphaColor(AuctionHouseFrame.CommoditiesSellFrame.CreateAuctionTabRight, nil, nil, 0.3)
    self:SetEditBox(AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.QuantityInput.InputBox)

    self:SetNineSlice(AuctionHouseFrame.ItemSellList)
    self:SetScrollBar(AuctionHouseFrame.ItemSellList)

    self:SetNineSlice(AuctionHouseFrame.ItemSellFrame)
    self:SetAlphaColor(AuctionHouseFrame.ItemSellFrame.ItemDisplay.ItemButton.EmptyBackground, nil, nil, 0.3)
    self:SetFrame(AuctionHouseFrame.ItemSellFrame.ItemDisplay, {alpha=0})
    self:SetEditBox(AuctionHouseFrame.ItemSellFrame.QuantityInput.InputBox)
    self:SetEditBox(AuctionHouseFrame.ItemSellFrame.PriceInput.MoneyInputFrame.GoldBox)
    self:SetEditBox(AuctionHouseFrame.ItemSellFrame.PriceInput.MoneyInputFrame.SilverBox)

    self:SetAlphaColor(AuctionHouseFrame.ItemSellFrame.CreateAuctionTabMiddle, nil, nil, 0.3)
    self:SetAlphaColor(AuctionHouseFrame.ItemSellFrame.CreateAuctionTabLeft, nil, nil, 0.3)
    self:SetAlphaColor(AuctionHouseFrame.ItemSellFrame.CreateAuctionTabRight, nil, nil, 0.3)

    --拍卖，所在物品，页面
    self:SetEditBox(AuctionHouseFrameAuctionsFrameBidsTab)
    self:SetEditBox(AuctionHouseFrameAuctionsFrameAuctionsTab)
    self:SetFrame(AuctionHouseFrameAuctionsFrameGold, {alpha=0.3})
    self:SetFrame(AuctionHouseFrameAuctionsFrameSilver, {alpha=0.3})
    self:SetNineSlice(AuctionHouseFrameAuctionsFrame.ItemDisplay)
    self:SetNineSlice(AuctionHouseFrameAuctionsFrame.CommoditiesList)

    --时光
    self:SetScrollBar(AuctionHouseFrame.WoWTokenResults.DummyScrollBar)
    self:SetNineSlice(AuctionHouseFrame.WoWTokenResults)
    --购买
    self:SetNineSlice(AuctionHouseFrame.ItemBuyFrame.ItemDisplay)
    self:SetScrollBar(AuctionHouseFrame.ItemBuyFrame.ItemList)
    self:SetNineSlice(AuctionHouseFrame.ItemBuyFrame.ItemList)


    --目录，列表
    local Alpha
    WoWTools_DataMixin:Hook('AuctionHouseFilterButton_SetUp', function(btn)
        if btn.NormalTexture then
            btn.NormalTexture:SetAlpha(Alpha or 1)
        end
    end)

    local function settings(alpha)
        AuctionHouseFrame.BrowseResultsFrame.ItemList.Background:SetAlpha(alpha)
        AuctionHouseFrame.ItemSellList.Background:SetAlpha(alpha)
        AuctionHouseFrame.ItemSellFrame.Background:SetAlpha(alpha)
        AuctionHouseFrame.CommoditiesSellList.Background:SetAlpha(alpha)
        AuctionHouseFrame.CommoditiesSellFrame.Background:SetAlpha(alpha)
        AuctionHouseFrameAuctionsFrame.SummaryList.Background:SetAlpha(alpha)
        AuctionHouseFrameAuctionsFrame.AllAuctionsList.Background:SetAlpha(alpha)
        AuctionHouseFrameAuctionsFrame.BidsList.Background:SetAlpha(alpha)
        AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.Background:SetAlpha(alpha)
        AuctionHouseFrame.CommoditiesBuyFrame.ItemList.Background:SetAlpha(alpha)

        Alpha= alpha
    end

    self:Init_BGMenu_Frame(AuctionHouseFrame, {
        enabled=true,
        alpha=1,
        settings=function(_, texture, alpha)
            settings(texture and 0 or alpha or 1)
        end
    })
end














--专业定制
function WoWTools_TextureMixin.Events:Blizzard_ProfessionsCustomerOrders()
    self:HideFrame(ProfessionsCustomerOrdersFrame)
    self:HideTexture(ProfessionsCustomerOrdersFrameBg)
    --self:SetNineSlice(ProfessionsCustomerOrdersFrame, true)
    self:SetButton(ProfessionsCustomerOrdersFrameCloseButton)

    self:SetEditBox(ProfessionsCustomerOrdersFrame.BrowseOrders.SearchBar.SearchBox)

    self:HideTexture(ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList.Background)

    self:SetNineSlice(ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList)
    self:SetNineSlice(ProfessionsCustomerOrdersFrame.BrowseOrders.RecipeList)
    self:SetScrollBar(ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList)
    self:SetScrollBar(ProfessionsCustomerOrdersFrame.BrowseOrders.RecipeList)
    self:SetTabButton(ProfessionsCustomerOrdersFrameBrowseTab)
    self:SetTabButton(ProfessionsCustomerOrdersFrameOrdersTab)

    self:HideFrame(ProfessionsCustomerOrdersFrame.MoneyFrameBorder)
    self:SetNineSlice(ProfessionsCustomerOrdersFrame.MoneyFrameInset)
    self:HideFrame(ProfessionsCustomerOrdersFrame.MoneyFrameInset)

    self:SetNineSlice(ProfessionsCustomerOrdersFrame.MyOrdersPage.OrderList)
    self:SetScrollBar(ProfessionsCustomerOrdersFrame.MyOrdersPage.OrderList)

    self:SetNineSlice(ProfessionsCustomerOrdersFrame.Form.CurrentListings)
    self:SetScrollBar(ProfessionsCustomerOrdersFrame.Form.CurrentListings.OrderList)


    self:SetNineSlice(ProfessionsCustomerOrdersFrame.Form.LeftPanelBackground)
    self:SetNineSlice(ProfessionsCustomerOrdersFrame.Form.RightPanelBackground)

    self:Init_BGMenu_Frame(ProfessionsCustomerOrdersFrame)
end








--黑市
function WoWTools_TextureMixin.Events:Blizzard_BlackMarketUI()
    self:SetAlphaColor(BlackMarketFrameTitleBg)
    self:SetAlphaColor(BlackMarketFrameBg)
    self:SetAlphaColor(BlackMarketFrame.LeftBorder)
    self:SetAlphaColor(BlackMarketFrame.RightBorder)
    self:SetAlphaColor(BlackMarketFrame.BottomBorder)
    self:SetScrollBar(BlackMarketFrame)
end














--日历
function WoWTools_TextureMixin.Events:Blizzard_Calendar()
    self:SetButton(CalendarCloseButton)

    self:SetAlphaColor(CalendarFrameTopMiddleTexture)
    self:SetAlphaColor(CalendarFrameTopLeftTexture)
    self:SetAlphaColor(CalendarFrameTopRightTexture)

    self:SetAlphaColor(CalendarFrameLeftTopTexture)
    self:SetAlphaColor(CalendarFrameLeftMiddleTexture)
    self:SetAlphaColor(CalendarFrameLeftBottomTexture)
    self:SetAlphaColor(CalendarFrameRightTopTexture)
    self:SetAlphaColor(CalendarFrameRightMiddleTexture)
    self:SetAlphaColor(CalendarFrameRightBottomTexture)

    self:SetAlphaColor(CalendarFrameBottomRightTexture)
    self:SetAlphaColor(CalendarFrameBottomMiddleTexture)
    self:SetAlphaColor(CalendarFrameBottomLeftTexture)

    self:SetAlphaColor(CalendarCreateEventFrame.Border.Bg)
    self:SetFrame(CalendarCreateEventFrame.Border, {notAlpha=true})
    self:SetEditBox(CalendarCreateEventTitleEdit)
    self:SetNineSlice(CalendarCreateEventDescriptionContainer)
    self:SetNineSlice(CalendarCreateEventInviteList)
    self:SetAlphaColor(CalendarCreateEventDivider, true)
    self:SetEditBox(CalendarCreateEventInviteEdit)
    self:SetAlphaColor(CalendarCreateEventFrameButtonBackground, true)
    self:SetAlphaColor(CalendarCreateEventCreateButtonBorder, true)
    self:SetFrame(CalendarCreateEventFrame.Header, {notAlpha=true})

    self:SetButton(CalendarViewHolidayCloseButton)
    self:SetFrame(CalendarViewHolidayFrame.Header, {notAlpha=true})
    self:SetFrame(CalendarViewHolidayFrame.Border, {notAlpha=true})

    self:SetAlphaColor(CalendarMonthBackground)
    self:SetAlphaColor(CalendarYearBackground)

    self:SetFrame(CalendarEventPickerFrame.Header, {notAlpha=true})
    self:SetFrame(CalendarEventPickerFrame.Border, {notAlpha=true})
    self:SetAlphaColor(CalendarEventPickerFrameButtonBackground, true)
    self:SetAlphaColor(CalendarEventPickerCloseButtonBorder, true)
    self:SetScrollBar(CalendarEventPickerFrame)
end







--飞行地图
function WoWTools_TextureMixin.Events:Blizzard_FlightMap()
    self:SetNineSlice(FlightMapFrame.BorderFrame, self.min)
    self:HideTexture(FlightMapFrame.ScrollContainer.Child.TiledBackground)
    self:HideTexture(FlightMapFrameBg)
end







--镶嵌宝石，界面
function WoWTools_TextureMixin.Events:Blizzard_ItemSocketingUI()
    self:HideFrame(ItemSocketingFrame)
    self:SetNineSlice(ItemSocketingFrameInset)
    self:SetButton(ItemSocketingFrameCloseButton)
    self:HideTexture(ItemSocketingFrameInset.Bg)
    self:SetScrollBar(ItemSocketingScrollFrame)
    self:HideFrame(ItemSocketingFrame)
    self:Init_BGMenu_Frame(ItemSocketingFrame)
end




















function WoWTools_TextureMixin.Events:Blizzard_ItemInteractionUI()--套装, 转换
    self:SetNineSlice(ItemInteractionFrame, self.min)
    self:SetAlphaColor(ItemInteractionFrameBg)
    self:SetAlphaColor(ItemInteractionFrame.Inset.Bg)
    self:SetAlphaColor(ItemInteractionFrameMiddle)

    self:SetAlphaColor(ItemInteractionFrameRight)
    self:SetAlphaColor(ItemInteractionFrameLeft)

    self:HideTexture(ItemInteractionFrame.ButtonFrame.BlackBorder)
end










--装备升级,界面 
function WoWTools_TextureMixin.Events:Blizzard_ItemUpgradeUI()
    --self:SetNineSlice(ItemUpgradeFrame, true)
    self:SetAlphaColor(ItemUpgradeFrameBg)
    self:HideTexture(ItemUpgradeFrame.TopBG)
    self:HideTexture(ItemUpgradeFrame.BottomBG)
    self:SetAlphaColor(ItemUpgradeFramePlayerCurrenciesBorderMiddle)
    self:SetAlphaColor(ItemUpgradeFramePlayerCurrenciesBorderLeft)
    self:SetAlphaColor(ItemUpgradeFramePlayerCurrenciesBorderRight)

    self:SetAlphaColor(ItemUpgradeFrameMiddle)
    self:SetAlphaColor(ItemUpgradeFrameRight)
    self:SetAlphaColor(ItemUpgradeFrameLeft)
end











--要塞
--GarrisonShipyardFrame--海军行动
--GarrisonMissionFrame--要塞任务
function WoWTools_TextureMixin.Events:Blizzard_GarrisonUI()
--侦查地图
    self:SetButton(OrderHallMissionFrame.CloseButton)
    self:SetFrame(OrderHallMissionFrame, {alpha=0})
    self:SetButton(AdventureMapQuestChoiceDialog.CloseButton)
    --self:SetFrame(AdventureMapQuestChoiceDialog, {alpha=1, show={[AdventureMapQuestChoiceDialog.Background]=1}})

--要塞订单
    self:SetNineSlice(GarrisonCapacitiveDisplayFrame)
    self:SetAlphaColor(GarrisonCapacitiveDisplayFrameBg)
    self:HideTexture(GarrisonCapacitiveDisplayFrame.TopTileStreaks)
    self:HideTexture(GarrisonCapacitiveDisplayFrameInset.Bg)

--要塞报告
    self:SetButton(GarrisonLandingPage.CloseButton)
    self:HideFrame(GarrisonLandingPage)
    self:HideFrame(GarrisonLandingPage.Report)

    self:SetScrollBar(GarrisonLandingPageFollowerList)
    self:HideTexture(GarrisonLandingPageFollowerList.FollowerScrollFrame)
    self:SetEditBox(GarrisonLandingPageFollowerList.SearchBox)
    self:HideTexture(GarrisonLandingPageFollowerList.FollowerHeaderBar)

    self:SetScrollBar(GarrisonLandingPageReportList)
    self:HideFrame(GarrisonLandingPageReportList)
    self:HideTexture(GarrisonLandingPageReport.Background)

    self:SetScrollBar(GarrisonLandingPageShipFollowerList)
    self:HideTexture(GarrisonLandingPageShipFollowerList.FollowerScrollFrame)
    self:SetEditBox(GarrisonLandingPageShipFollowerList.SearchBox)
    self:HideTexture(GarrisonLandingPageShipFollowerList.FollowerHeaderBar)

    self:SetTabButton(GarrisonLandingPageTab1)
    self:SetTabButton(GarrisonLandingPageTab2)
    self:SetTabButton(GarrisonLandingPageTab3)

    self:Init_BGMenu_Frame(GarrisonLandingPage, {isNewButton=true})
end




--欲龙术
function WoWTools_TextureMixin.Events:Blizzard_GenericTraitUI()
    self:HideFrame(GenericTraitFrame)
    self:SetButton(GenericTraitFrame.CloseButton, {all=true, alpha=1})
    self:SetNineSlice(GenericTraitFrame)

    self:Init_BGMenu_Frame(GenericTraitFrame, {isNewButton=true,
        newButtonAlpha=1,
        newButtonPoint=function(btn)
            btn:SetPoint('TOPLEFT', 10, -10)
        end,
        bgPoint=function(icon)
            icon:SetPoint('TOPLEFT', 10, -10)
            icon:SetPoint('BOTTOMRIGHT', -10, 10)
        end
    })
end







--任务选择
function WoWTools_TextureMixin.Events:Blizzard_PlayerChoice()
    WoWTools_DataMixin:Hook(PlayerChoiceFrame, 'SetupFrame', function(frame)
        if frame.Background then
            self:SetAlphaColor(frame.Background.BackgroundTile, nil, nil, 0)
            self:SetAlphaColor(frame.Background, nil, nil, 0)
        end

        self:SetNineSlice(frame)
        self:SetAlphaColor(frame.Header)
        self:SetEditBox(frame.Title)
    end)

    self:SetButton(PlayerChoiceFrame.CloseButton, {all=true,})
    self:SetAlphaColor(PlayerChoiceFrame.CloseButton.Border)

    PlayerChoiceFrame.Title.Middle:ClearAllPoints()
    PlayerChoiceFrame.Title.Middle:SetPoint('LEFT', PlayerChoiceFrame.Title.Left, 'RIGHT', -10,0)
    PlayerChoiceFrame.Title.Middle:SetPoint('RIGHT', PlayerChoiceFrame.Title.Right, 'LEFT', 10, 0)

    self:Init_BGMenu_Frame(PlayerChoiceFrame, {isNewButton=true})
end
















--专业, 初始化, 透明
function WoWTools_TextureMixin.Events:Blizzard_Professions()
    --self:SetNineSlice(ProfessionsFrame)
    self:HideFrame(ProfessionsFrame)
    self:SetButton(ProfessionsFrame.CloseButton)
    self:SetButton(ProfessionsFrame.MaximizeMinimize.MaximizeButton)
    self:SetButton(ProfessionsFrame.MaximizeMinimize.MinimizeButton)

    self:SetFrame(ProfessionsFrame.CraftingPage.LinkButton, {notAlpha=true})
    self:SetButton(ProfessionsFrame.CraftingPage.TutorialButton)
    self:SetAlphaColor(ProfessionsFrame.CraftingPage.RankBar.Background, nil, nil, 0.5)
    self:SetFrame(ProfessionsFrame.CraftingPage.RankBar.ExpansionDropdownButton, {notAlpha=true})
    self:HideTexture(ProfessionsFrame.CraftingPage.RankBar.Border)
    self:SetAlphaColor(ProfessionsFrame.CraftingPage.SchematicForm.Background, nil, nil, 0.5)
    self:SetNineSlice(ProfessionsFrame.CraftingPage.SchematicForm)
    self:SetAlphaColor(ProfessionsFrame.CraftingPage.SchematicForm.MinimalBackground, nil, nil, 0.5)
    self:SetAlphaColor(ProfessionsFrame.CraftingPage.SchematicForm.Details.BackgroundTop)
    self:SetAlphaColor(ProfessionsFrame.CraftingPage.SchematicForm.Details.BackgroundMiddle)
    self:SetAlphaColor(ProfessionsFrame.CraftingPage.SchematicForm.Details.BackgroundBottom)
    self:SetFrame(ProfessionsFrame.CraftingPage.GearSlotDivider)

    self:SetFrame(ProfessionsFrame.CraftingPage.Prof1Gear0Slot, {show={[ProfessionsFrame.CraftingPage.Prof1Gear0Slot.icon]=true}})
    self:SetFrame(ProfessionsFrame.CraftingPage.Prof1Gear1Slot, {show={[ProfessionsFrame.CraftingPage.Prof1Gear1Slot.icon]=true}})
    self:SetFrame(ProfessionsFrame.CraftingPage.Prof1ToolSlot, {show={[ProfessionsFrame.CraftingPage.Prof1ToolSlot.icon]=true}})

    self:SetAlphaColor(ProfessionsFrame.SpecPage.TreeView.Background, nil, nil, 0)
    self:HideTexture(ProfessionsFrame.SpecPage.DetailedView.Background)
    self:SetAlphaColor(ProfessionsFrame.SpecPage.DetailedView.Path.DialBG)
    self:SetAlphaColor(ProfessionsFrame.SpecPage.DetailedView.UnspentPoints.CurrencyBackground)
    self:SetAlphaColor(ProfessionsFrame.SpecPage.TopDivider, nil, nil, 0)

    self:SetNineSlice(InspectRecipeFrame)
    self:SetAlphaColor(InspectRecipeFrameBg)
    self:SetAlphaColor(InspectRecipeFrame.SchematicForm.MinimalBackground)
    --self:SetTabSystem(ProfessionsFrame)

    WoWTools_DataMixin:Hook(ProfessionsFrame.SpecPage, 'UpdateTabs', function(frame)
        for tab, bool in frame.tabsPool:EnumerateActive() do
            if bool then
                self:SetFrame(tab, {alpha=0.3})
            end
        end
    end)
    self:SetAlphaColor(ProfessionsFrame.SpecPage.PanelFooter)

    --self:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList.Background, nil, nil, 0.3)

    self:SetAlphaColor(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.Background, nil, nil, 0.3)
    self:SetAlphaColor(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.Background, nil, nil, 0.3)
    self:SetNineSlice(ProfessionsFrame.OrdersPage.OrderView.OrderInfo)
    self:SetNineSlice(ProfessionsFrame.OrdersPage.OrderView.OrderDetails)


    self:SetScrollBar(ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList)
    self:SetEditBox(ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList.SearchBox)
    self:SetNineSlice(ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList.BackgroundNineSlice)
    self:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.PublicOrdersButton.Middle, nil, nil, 0.3)
    self:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.PublicOrdersButton.Right, nil, nil, 0.3)
    self:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.PublicOrdersButton.Left, nil, nil, 0.3)
    self:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.PersonalOrdersButton.Middle, nil, nil, 0.3)
    self:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.PersonalOrdersButton.Right, nil, nil, 0.3)
    self:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.PersonalOrdersButton.Left, nil, nil, 0.3)
    self:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.OrderList.Background, nil,nil, 0.3)
    self:SetNineSlice(ProfessionsFrame.OrdersPage.BrowseFrame.OrderList)
    self:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.OrdersRemainingDisplay.Background, nil, nil, 0.3)

    for _, typeTab in ipairs(ProfessionsFrame.OrdersPage.BrowseFrame.orderTypeTabs) do
        self:SetTabButton(typeTab)
	end

    self:SetNineSlice(ProfessionsFrame.CraftingPage.CraftingOutputLog)
    self:SetScrollBar(ProfessionsFrame.CraftingPage.CraftingOutputLog)

    self:SetScrollBar(ProfessionsFrame.CraftingPage.RecipeList)
    self:HideFrame(ProfessionsFrame.CraftingPage.RecipeList.BackgroundNineSlice)
    self:SetEditBox(ProfessionsFrame.CraftingPage.RecipeList.SearchBox)

    self:SetScrollBar(ProfessionsFrame.OrdersPage.BrowseFrame.OrderList)

    self:SetButton(ProfessionsFrame.CraftingPage.CraftingOutputLog.ClosePanelButton)

    self:Init_BGMenu_Frame(ProfessionsFrame)
end








--点击，施法
function WoWTools_TextureMixin.Events:Blizzard_ClickBindingUI()
    self:SetNineSlice(ClickBindingFrame, 1, true)
    self:SetScrollBar(ClickBindingFrame)
    self:SetAlphaColor(ClickBindingFrameBg)
    ClickBindingFrame.ScrollBoxBackground:Hide()
    self:SetNineSlice(ClickBindingFrame.TutorialFrame)
end









function WoWTools_TextureMixin.Events:Blizzard_ArchaeologyUI()
    self:SetButton(ArchaeologyFrameCloseButton)
    self:SetNineSlice(ArchaeologyFrameInset)
    self:HideTexture(ArchaeologyFrameBg)
    self:HideTexture(ArchaeologyFrameInset.Bg)
    self:HideTexture(ArchaeologyFrameRankBarBackground)
    self:SetAlphaColor(ArchaeologyFrameRaceFilterMiddle, nil, nil, 0.3)
    self:SetAlphaColor(ArchaeologyFrameRaceFilterLeft, nil, nil, 0.3)
    self:SetAlphaColor(ArchaeologyFrameRaceFilterRight, nil, nil, 0.3)

    self:SetAlphaColor(ArchaeologyFrameRankBarBorder)

    self:Init_BGMenu_Frame(ArchaeologyFrame, {
        enabled=true,
        alpha=1,
        settings= function(_, texture, alpha)
            alpha= texture and 0 or alpha or 1
            ArchaeologyFrameBgLeft:SetAlpha(alpha)
            ArchaeologyFrameBgRight:SetAlpha(alpha)
        end
    })
end








--分解 ScrappingMachineFrame
function WoWTools_TextureMixin.Events:Blizzard_ScrappingMachineUI()
    self:SetNineSlice(ScrappingMachineFrame, 0.3)
    self:SetAlphaColor(ScrappingMachineFrameBg)
    self:HideTexture(ScrappingMachineFrame.Background)
    self:HideTexture(ScrappingMachineFrameInset.Bg)
    self:SetNineSlice(ScrappingMachineFrameInset)
    self:HideTexture(ScrappingMachineFrame.TopTileStreaks)
    self:SetButton(ScrappingMachineFrameCloseButton)
end












function WoWTools_TextureMixin.Events:Blizzard_DelvesCompanionConfiguration()
    self:SetButton(DelvesCompanionConfigurationFrame.CloseButton)
    self:SetNineSlice(DelvesCompanionConfigurationFrame)
    self:HideFrame(DelvesCompanionConfigurationFrame.Border)
    self:HideTexture(DelvesCompanionConfigurationFrame.Bg)
--添加Bg
    for _, btn in pairs({
        DelvesCompanionConfigurationFrame.CompanionCombatRoleSlot,
        DelvesCompanionConfigurationFrame.CompanionCombatTrinketSlot,
        DelvesCompanionConfigurationFrame.CompanionUtilityTrinketSlot
    }) do
        btn.Bg= btn:CreateTexture(nil, 'BACKGROUND')
        btn.Bg:SetColorTexture(0,0,0,0.3)
        btn.Bg:SetPoint('TOPLEFT', btn.Label, -2, 2)
        btn.Bg:SetPoint('BOTTOMRIGHT', btn.Value, 2, -2)
    end

    self:SetNineSlice(DelvesCompanionAbilityListFrame)
    self:HideTexture(DelvesCompanionAbilityListFrameBg)
    self:HideTexture(DelvesCompanionAbilityListFrame.CompanionAbilityListBackground)
    self:SetButton(DelvesCompanionAbilityListFrame.CloseButton)
    self:SetMenu(DelvesCompanionAbilityListFrame.DelvesCompanionRoleDropdown)
    self:HideTexture(DelvesCompanionAbilityListFrame.TopTileStreaks)
--添加Bg
    WoWTools_DataMixin:Hook(DelvesCompanionAbilityMixin, 'InitAdditionalElements', function(btn)
        if not btn.Bg then
            btn.Bg= btn:CreateTexture(nil, 'BACKGROUND')
            btn.Bg:SetColorTexture(0,0,0,0.3)
            btn.Bg:SetAllPoints()
        end
    end)

    self:Init_BGMenu_Frame(DelvesCompanionConfigurationFrame, {
        PortraitContainer=DelvesCompanionConfigurationFrame.CompanionPortraitFrame,
    })
    --{isNewButton=true})
    self:Init_BGMenu_Frame(DelvesCompanionAbilityListFrame)
end






function WoWTools_TextureMixin.Events:Blizzard_CovenantRenown()
    self:HideTexture(CovenantRenownFrame.Background)
end





function WoWTools_TextureMixin.Events:Blizzard_Settings()
    self:SetButton(SettingsPanel.ClosePanelButton)
    --self:SetNineSlice(SettingsPanel)
    self:HideFrame(SettingsPanel.Bg)
    self:HideFrame(SettingsPanel)
    self:SetScrollBar(SettingsPanel.Container.SettingsList)
    self:SetScrollBar(SettingsPanel.CategoryList)

    self:SetNineSlice(PingSystemTutorial, 1, true)
    self:SetNineSlice(PingSystemTutorialInset, nil, true)

    self:HideTexture(PingSystemTutorialBg)

    self:SetTabButton(SettingsPanel.GameTab)
    self:SetTabButton(SettingsPanel.AddOnsTab)
    self:SetEditBox(SettingsPanel.SearchBox)

    self:CreateBG(SettingsPanel.CategoryList, {isAllPoint=true, alpha=0.5, isColor=true})
    self:CreateBG(SettingsPanel.Container, {isAllPoint=true, alpha=0.5, isColor=true})


    self:Init_BGMenu_Frame(SettingsPanel, {isNewButton=true})
end




--冷却设置
function WoWTools_TextureMixin.Events:Blizzard_CooldownViewer()

    WoWTools_DataMixin:Hook(CooldownViewerBuffBarItemMixin, 'OnLoad', function(frame)
        self:SetFrame(frame.Bar, {alpha=0.2, index=1})
    end)
    for frame in BuffBarCooldownViewer.itemFramePool:EnumerateActive() do
		self:SetFrame(frame.Bar, {alpha=0.2, index=1})
	end

    if not CooldownViewerSettings then--冷却设置 11.2.5
        return
    end

    self:SetButton(CooldownViewerSettingsCloseButton)
    self:SetButton(CooldownViewerSettings.SettingsDropdown, {alpha=1})
    self:SetEditBox(CooldownViewerSettings.SearchBox)
    self:SetNineSlice(CooldownViewerSettings)

    self:HideTexture(CooldownViewerSettings.TopTileStreaks)
    self:HideTexture(CooldownViewerSettingsBg)
    self:SetScrollBar(CooldownViewerSettings.CooldownScroll)

    self:HideTexture(CooldownViewerSettingsInset.Bg)
    self:SetNineSlice(CooldownViewerSettingsInset)

    for _, tabButton in ipairs(CooldownViewerSettings.TabButtons) do
        self:HideTexture(tabButton.Background)
	end

    --CooldownViewerSettingsCategoryMixin 标题
    --CooldownViewerSettingsItemMixin 追踪的状态栏
    --CooldownViewerSettingsBarItemMixin 追踪的状态栏 bar


    local function set_button(pool)
        if not pool then
            return
        end
        for f in pool:EnumerateActive() do
            self:SetAlphaColor(f.Header.Left)
            self:SetAlphaColor(f.Header.Middle)
            self:SetAlphaColor(f.Header.Right)

            for btn in f.itemPool:EnumerateActive() do
                if not btn.IconMask then
                    WoWTools_ButtonMixin:AddMask(btn, false, btn.Icon)
                end
                if btn.Bar then
                    self:SetFrame(btn.Bar, {alpha=0.3})
                end
            end
        end
    end

    local function on_show(frame)
        set_button(frame.categoryPool:GetPool('CooldownViewerSettingsCategoryTemplate'))
        set_button(frame.categoryPool:GetPool('CooldownViewerSettingsBarCategoryTemplate'))
    end

    on_show(CooldownViewerSettings)
    WoWTools_DataMixin:Hook(CooldownViewerSettings, 'RefreshLayout', function(frame)
       on_show(frame)
    end)

    self:Init_BGMenu_Frame(CooldownViewerSettings)



--增加 Esc 闭关窗口
end












function WoWTools_TextureMixin.Events:Blizzard_ExpansionLandingPage()
    local function SetOverlayFrame(frame)
        if not frame then
            return
        end
        self:HideFrame(frame, {show={[frame.Background]=1}})
        self:SetScrollBar(frame.MajorFactionList)
        self:SetButton(frame.CloseButton)
        self:HideFrame(frame.ScrollFadeOverlay)
    end


    SetOverlayFrame(ExpansionLandingPage.overlayFrame)

    WoWTools_DataMixin:Hook(ExpansionLandingPage, 'RefreshExpansionOverlay', function(frame)
        SetOverlayFrame(frame.overlayFrame)
    end)

    self:Init_BGMenu_Frame(ExpansionLandingPage, {
        isNewButton=true,
        newButtonAlpha=1,
        newButtonPoint=function(btn)
            if ExpansionLandingPage.overlayFrame then
	            btn:SetPoint('TOPLEFT', ExpansionLandingPage.overlayFrame, 7, -8)
            else
                btn:SetPoint('TOPLEFT')
            end
            btn:SetFrameStrata('HIGH')
        end,
        bgPoint=function(icon)
            if ExpansionLandingPage.overlayFrame then
                icon:SetPoint('TOPLEFT', ExpansionLandingPage.overlayFrame, 10, -10)
                icon:SetPoint('BOTTOMRIGHT', ExpansionLandingPage.overlayFrame, -10, 10)
            else
                icon:SetPoint('CENTER')
                icon:SetSize(785, 550)
            end
        end,
        settings=function(_, texture, alpha)
            local bg= ExpansionLandingPage.overlayFrame and ExpansionLandingPage.overlayFrame.Background
            if bg then
                bg:SetAlpha(texture and 0 or alpha or 1)
            end
        end
    })

end



--派系声望
function WoWTools_TextureMixin.Events:Blizzard_MajorFactions()
    --self:SetAlphaColor(MajorFactionRenownFrame.Background)
    self:SetNineSlice(MajorFactionRenownFrame)
    self:SetButton(MajorFactionRenownFrame.CloseButton)

--解锁
    WoWTools_DataMixin:Hook(MajorFactionButtonUnlockedStateMixin, 'Refresh', function(frame)--Blizzard_MajorFactionsLandingTemplates.lua
        self:SetAlphaColor(frame.Background, nil, nil, 0.75)
    end)
--没解锁
    WoWTools_DataMixin:Hook(MajorFactionButtonLockedStateMixin, 'Refresh', function(frame)
        self:SetAlphaColor(frame.Background, nil, nil, 0.75)
    end)

    self:Init_BGMenu_Frame(MajorFactionRenownFrame, {isNewButton=true,
        newButtonAlpha=1,
        newButtonPoint=function(btn)
            btn:SetPoint('TOPLEFT', 10, -10)
        end,
        settings=function(_, texture, alpha)
            MajorFactionRenownFrame.Background:SetAlpha(texture and 0 or alpha or 1)
        end
    })

end



function WoWTools_TextureMixin.Events:Blizzard_PerksProgram()
    self:SetScrollBar(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer)
    self:SetScrollBar(PerksProgramFrame.ProductsFrame.PerksProgramShoppingCartFrame.ItemList)
    self:SetScrollBar(PerksProgramFrame.ProductsFrame.PerksProgramProductDetailsContainerFrame.SetDetailsScrollBoxContainer)
    self:SetFrame(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.Border, {alpha=1})
    self:SetNineSlice(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.PerksProgramHoldFrame, self.min)
    self:SetAlphaColor(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.PerksDividerTop, nil, nil, 1)
    self:SetFrame(PerksProgramFrame.ProductsFrame.PerksProgramProductDetailsContainerFrame.Border, {alpha=1})
    self:SetFrame(PerksProgramFrame.ProductsFrame.PerksProgramShoppingCartFrame.Background, {alpha=1})
    self:SetAlphaColor(PerksProgramFrame.ProductsFrame.PerksProgramShoppingCartFrame.BottomDivider, nil, nil, 1)
--列表
    PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer:ClearAllPoints()
    PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer:SetPoint('TOPLEFT', 3, -5)
    PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer:SetPoint('BOTTOM', 0, 2)
--过滤
    PerksProgramFrame.ProductsFrame.PerksProgramFilter:ClearAllPoints()
    --PerksProgramFrame.ProductsFrame.PerksProgramFilter:SetPoint('TOPLEFT', PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer, 'TOPRIGHT', 3, -52)
    PerksProgramFrame.ProductsFrame.PerksProgramFilter:SetPoint('TOP', PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer, 0, -18)
--货币
    PerksProgramFrame.ProductsFrame.PerksProgramCurrencyFrame.Icon:ClearAllPoints()
    PerksProgramFrame.ProductsFrame.PerksProgramCurrencyFrame.Icon:SetPoint('LEFT')
    PerksProgramFrame.ProductsFrame.PerksProgramCurrencyFrame.Text:ClearAllPoints()
    PerksProgramFrame.ProductsFrame.PerksProgramCurrencyFrame.Text:SetPoint('LEFT', PerksProgramFrame.ProductsFrame.PerksProgramCurrencyFrame.Icon, 'RIGHT')
    PerksProgramFrame.ProductsFrame.PerksProgramCurrencyFrame.Text:SetJustifyH('RIGHT')
    EventRegistry:RegisterCallback("PerksProgram.UpdateCartShown", function(frame, cartShown)
        if not cartShown  then
            frame:ClearAllPoints()
            frame:SetPoint('TOPLEFT', frame:GetParent().ProductsScrollBoxContainer, 'TOPRIGHT', 3, 2)
        end
    end, PerksProgramFrame.ProductsFrame.PerksProgramCurrencyFrame)
--离开
    PerksProgramFrame.FooterFrame.LeaveButton:ClearAllPoints()
    PerksProgramFrame.FooterFrame.LeaveButton:SetPoint('BOTTOMLEFT', PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer, 'BOTTOMRIGHT', 0, 30)
end







--AuraButtonArtTemplate DebuffFrame
function WoWTools_TextureMixin.Events:Blizzard_BuffFrame()
    for _, auraFrame in ipairs(BuffFrame.auraFrames or {}) do
        auraFrame.IconMask= auraFrame:CreateMaskTexture()
        auraFrame.IconMask:SetAtlas('UI-HUD-CoolDownManager-Mask')
        auraFrame.IconMask:SetPoint('TOPLEFT', auraFrame.Icon, 0.5, -0.5)
        auraFrame.IconMask:SetPoint('BOTTOMRIGHT', auraFrame.Icon, -0.5, 0.5)
        auraFrame.Icon:AddMaskTexture(auraFrame.IconMask)
    end


    BuffFrame.CollapseAndExpandButton:HookScript('OnMouseDown', function(btn, d)
        if d~='RightButton' or InCombatLockdown() then
            return
        end

        MenuUtil.CreateContextMenu(btn, function(_, root)
            local sub= root:CreateCheckbox(
                WoWTools_DataMixin.Icon.icon2
                ..(WoWTools_DataMixin.onlyChinese and '显示冷却时间' or COUNTDOWN_FOR_COOLDOWNS_TEXT),
            function()
                return C_CVar.GetCVarBool('buffDurations')
            end, function()
                if not InCombatLockdown() then
                    C_CVar.SetCVar('buffDurations', C_CVar.GetCVarBool('buffDurations') and 0 or 1)
                end
            end)
            sub:SetTooltip(function(tooltip)
                tooltip:AddLine('CVar |cffffffffbuffDurations')
            end)
        end)
    end)

    BuffFrame.CollapseAndExpandButton:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)

    BuffFrame.CollapseAndExpandButton:SetScript('OnEnter', function(btn)
        if InCombatLockdown() then
            return
        end
        GameTooltip:SetOwner(btn, 'ANCHOR_BOTTOMRIGHT')
        GameTooltip:SetText(
            WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_DataMixin.onlyChinese and '显示冷却时间' or COUNTDOWN_FOR_COOLDOWNS_TEXT)
            ..WoWTools_DataMixin.Icon.right
            ..WoWTools_TextMixin:GetShowHide(C_CVar.GetCVarBool('buffDurations'), nil)
        )
        GameTooltip:Show()
    end)
end












--主菜单
function WoWTools_TextureMixin.Events:Blizzard_GameMenu()
    self:HideFrame(GameMenuFrame.Header)
    GameMenuFrame.Header.Text:ClearAllPoints()
    GameMenuFrame.Header.Text:SetPoint('TOP', 0 ,-24)
    self:HideFrame(GameMenuFrame.Border)

    self:Init_BGMenu_Frame(GameMenuFrame, {
        isNewButton=true,
        newButtonPoint=function(btn)
            btn:SetPoint('TOPLEFT', GameMenuFrame.Border)
        end
    })
end


    --[[local dataButton={--layoutIndex
        [GAMEMENU_OPTIONS]= {'mechagon-projects', false},--选项
        [HUD_EDIT_MODE_MENU]= {'UI-HUD-Minimap-CraftingOrder-Up', false},--编辑模式
        [MACROS]= {'NPE_Icon', false},--宏命令设置

        [ADDONS]= {'dressingroom-button-appearancelist-up', false},--插件
        [LOG_OUT]= {'perks-warning-large', false, {0,0.8,1}},--登出
        [EXIT_GAME]= {'Ping_Chat_Warning', false, {0,0.8,1}},--退出游戏
        [RETURN_TO_GAME]= {'poi-traveldirections-arrow', true, {0,1,0}},--返回游戏
    }
    WoWTools_DataMixin:Hook(GameMenuFrame, 'InitButtons', function(frame)
        for btn in frame.buttonPool:EnumerateActive() do
            local data= dataButton[btn:GetText()]
            if data then
                if  not btn.Texture then
                    btn.Texture= btn:CreateTexture(nil, 'BORDER')
                    btn.Texture:SetSize(26, 26)--200, 36
                    btn.Texture:SetPoint('RIGHT', btn, 'LEFT', 6,0)
                end
                if btn.Texture then
                    if data and data[1] then
                        btn.Texture:SetAtlas(data[1])
                    else
                        btn.Texture:SetTexture(nil)
                    end
                    if data and data[2] then
                        btn.Texture:SetTexCoord(1,0,1,0)
                    end
                end

                local font= btn:GetFontString()
                local r, g, b
                if data[3] then
                    r, g, b= data[3][1], data[3][2], data[3][3]
                elseif data then
                    r, g, b= 1, 1, 1
                end
                font:SetTextColor(r or 1, g or 0.82, b or 0)
            end
        end
    end)]]














--聊天设置
function WoWTools_TextureMixin.Events:Blizzard_Channels()
    self:SetButton(ChannelFrameCloseButton)
    self:HideFrame(ChannelFrame)

    self:HideFrame(ChannelFrameInset)
    self:SetAlphaColor(ChannelFrame.RightInset.Bg, nil, nil, 0.3)
    self:SetAlphaColor(ChannelFrame.LeftInset, nil, nil, 0.3)

    self:SetScrollBar(ChannelFrame.ChannelRoster)
    self:SetScrollBar(ChannelFrame.ChannelList)

    self:SetNineSlice(ChannelFrame)
    self:SetNineSlice(ChannelFrameInset)
    self:SetNineSlice(ChannelFrame.RightInset)
    self:SetNineSlice(ChannelFrame.LeftInset)

    self:Init_BGMenu_Frame(ChannelFrame)
end























--编辑模式
function WoWTools_TextureMixin.Events:Blizzard_EditMode()
    self:SetButton(EditModeManagerFrame.CloseButton)
    self:SetScrollBar(EditModeManagerFrame.AccountSettings.SettingsContainer)
    self:SetFrame(EditModeManagerFrame.Border, {alpha=0.3})
    self:SetFrame(EditModeManagerFrame.AccountSettings.SettingsContainer.BorderArt, {alpha=0.3})
    self:SetSlider(EditModeManagerFrame.GridSpacingSlider)
    self:SetMenu(EditModeManagerFrame.LayoutDropdown)

    self:SetFrame(EditModeSystemSettingsDialog.Border)
    self:SetButton(EditModeSystemSettingsDialog.CloseButton)
end








--隐藏, 团队, 材质 Blizzard_CompactRaidFrameManager.lua
function WoWTools_TextureMixin.Events:Blizzard_CompactRaidFrames()

    self:HideFrame(CompactRaidFrameManager, {show={[CompactRaidFrameManager.Background]=true}})

--打开
    CompactRaidFrameManagerToggleButtonBack.hoverTex= 'common-icon-rotateleft'
    CompactRaidFrameManagerToggleButtonBack.normalTex= 'common-icon-backarrow'
    CompactRaidFrameManagerToggleButtonBack:GetNormalTexture():SetAlpha(0.3)
    CompactRaidFrameManagerToggleButtonBack:SetNormalAtlas('common-icon-backarrow')
    local icon= CompactRaidFrameManagerToggleButtonBack:GetPushedTexture()
    icon:SetAtlas('common-icon-backarrow')
    icon= CompactRaidFrameManagerToggleButtonBack:GetDisabledTexture()
    icon:SetAtlas('common-icon-backarrow')
    icon:SetDesaturated(true)
--合
    CompactRaidFrameManagerToggleButtonForward:GetNormalTexture():SetAlpha(0.3)
    CompactRaidFrameManagerToggleButtonForward.hoverTex= 'common-icon-rotateright'
    CompactRaidFrameManagerToggleButtonForward.normalTex= 'common-icon-forwardarrow'
    CompactRaidFrameManagerToggleButtonForward:SetNormalAtlas('common-icon-forwardarrow')
    icon= CompactRaidFrameManagerToggleButtonForward:GetPushedTexture()
    icon:SetAtlas('common-icon-forwardarrow')
    icon= CompactRaidFrameManagerToggleButtonForward:GetDisabledTexture()
    icon:SetAtlas('common-icon-forwardarrow')
    icon:SetDesaturated(true)
--Background
    self:SetAlphaColor(CompactRaidFrameManager.Background, true)
    CompactRaidFrameManager.Background:SetShown(CompactRaidFrameManagerToggleButtonBack:IsShown())
        CompactRaidFrameManagerToggleButtonBack:HookScript('OnShow', function(b)
        b:GetParent().Background:SetShown(true)
    end)
    CompactRaidFrameManagerToggleButtonForward:HookScript('OnShow', function(b)
        b:GetParent().Background:SetShown(false)
    end)
--BG
    self:Init_BGMenu_Frame(CompactRaidFrameManagerDisplayFrame, {
        isNewButton=true,
        newButtonPoint=function(btn)
            if _G['CompactRaidFrameManagerScaleMenuButton'] then
                btn:SetPoint('RIGHT', _G['CompactRaidFrameManagerScaleMenuButton'], 'LEFT')
            else
                btn:SetPoint('LEFT', CompactRaidFrameManagerDisplayFrameModeControlDropdown, 'RIGHT')
            end
        end,
        settings=function(_, texture, alpha)
            CompactRaidFrameManager.Background:SetAlpha(texture and 0 or alpha or 1)
        end
    })

    CompactRaidFrameManagerDisplayFrameRaidMembersLabel:SetText('')--队员
    CompactRaidFrameManagerDisplayFrameRaidMembersLabel:ClearAllPoints()

    self:SetMenu(CompactRaidFrameManagerDisplayFrameRestrictPingsDropdown)
    self:SetMenu(CompactRaidFrameManagerDisplayFrameModeControlDropdown)
end








function WoWTools_TextureMixin.Events:Blizzard_ReportFrame()
    self:SetFrame(ReportFrame)
    self:SetFrame(ReportFrame.Border)
    self:HideTexture(ReportFrame.BottomInset)
    self:HideTexture(ReportFrame.TopInset)
    self:SetFrame(ReportFrame.CloseButton, {notAlpha=true})

    self:SetScrollBar(ReportFrame.Comment)
end






function WoWTools_TextureMixin.Events:Blizzard_UnitFrame()
    for i=1, MAX_BOSS_FRAMES do
        local frame= _G['Boss'..i..'TargetFrame']
        if frame then
            self:HideTexture(frame.TargetFrameContainer.FrameTexture)
        end
    end


    --WoWTools_DataMixin:Hook('PlayerFrame_UpdateArt', function()--隐藏材质, 载具
    self:SetAlphaColor(OverrideActionBarEndCapL, nil, nil, 0)
    self:SetAlphaColor(OverrideActionBarEndCapR, nil, nil, 0)
    self:SetAlphaColor(OverrideActionBarBorder, nil, nil, 0)
    self:SetAlphaColor(OverrideActionBarBG, nil, nil, 0.3)
    self:SetAlphaColor(OverrideActionBarButtonBGMid, nil, nil, 0)
    self:SetAlphaColor(OverrideActionBarButtonBGR, nil, nil, 0)
    self:SetAlphaColor(OverrideActionBarButtonBGL, nil, nil, 0)

    self:SetAlphaColor(OverrideActionBarMicroBGMid, nil, nil, 0)
    self:SetAlphaColor(OverrideActionBarMicroBGR, nil, nil, 0)
    self:SetAlphaColor(OverrideActionBarMicroBGL, nil, nil, 0)
    self:SetAlphaColor(OverrideActionBarLeaveFrameExitBG, nil, nil, 0)

    self:SetAlphaColor(OverrideActionBarDivider2, nil, nil, 0)
    self:SetAlphaColor(OverrideActionBarLeaveFrameDivider3, nil, nil, 0)

    self:SetAlphaColor(OverrideActionBarExpBarXpMid, nil, nil, 0)
    self:SetAlphaColor(OverrideActionBarExpBarXpR, nil, nil, 0)
    self:SetAlphaColor(OverrideActionBarExpBarXpL, nil, nil, 0)

    for i=1, 19 do
        self:SetAlphaColor(_G['OverrideActionBarXpDiv'..i], nil, nil, 0)
    end


--货币，XP，追踪，最下面BAR
    --self:SetAlphaColor(MainStatusTrackingBarContainer.BarFrameTexture, nil, nil, 0.1)
    --self:SetAlphaColor(SecondaryStatusTrackingBarContainer.BarFrameTexture, nil, nil, 0.1)

    for _, barContainer in ipairs(StatusTrackingBarManager.barContainers or {}) do
        self:HideTexture(barContainer.BarFrameTexture)
    end

    self:SetAlphaColor(MultiBarBottomLeftButton10.SlotBackground, nil, nil, 0)

    self:HideTexture(PlayerFrameAlternateManaBarBorder)
    self:HideTexture(PlayerFrameAlternateManaBarLeftBorder)
    self:HideTexture(PlayerFrameAlternateManaBarRightBorder)
--额外技能
    self:SetAlphaColor(ExtraActionButton1.style, nil, true, 0.3)

--小队，背景
    self:SetFrame(PartyFrame.Background, {alpha= 0.3})

--施法条 CastingBarFrameTemplate
    for _, frame in pairs({
        PlayerCastingBarFrame,
        PetCastingBarFrame,
        OverlayPlayerCastingBarFrame,
    }) do
        if frame then
            self:SetAlphaColor(frame.Border)
            self:SetAlphaColor(frame.Background)
            self:SetAlphaColor(frame.TextBorder)
            self:SetAlphaColor(frame.Shine)
        end
    end

--团队 RolePoll.lua
    self:SetFrame(RolePollPopup.Border, {notAlpha=true})
    self:SetButton(RolePollPopupCloseButton)
end








--对话框 11.2没了
function WoWTools_TextureMixin.Events:Blizzard_StaticPopup_Frame()
    self:SetFrame(StaticPopup1.Border, {notAlpha=true})
    self:SetAlphaColor(StaticPopup1.Border.Bg, true)
end

--11.2才有
function WoWTools_TextureMixin.Events:Blizzard_StaticPopup_Game()
    for i=1, 4 do
        local p= _G['StaticPopup'..i]
        if p then
            self:SetFrame(p.BG, {notAlpha=true})
        end
        local edit= _G['StaticPopup'..i..'EditBox']
        if edit then
            self:SetEditBox(edit)
            self:SetNineSlice(edit, 1)
        end
    end
end




















--PVEFrame
function WoWTools_TextureMixin.Events:Blizzard_GroupFinder()
    self:SetTabButton(PVEFrameTab1)
    self:SetTabButton(PVEFrameTab2)
    self:SetTabButton(PVEFrameTab3)
    self:SetTabButton(PVEFrameTab4)

    --地下城和团队副本
    self:SetButton(PVEFrameCloseButton)
    self:HideTexture(PVEFrame.TopTileStreaks)--最上面
    --self:SetNineSlice(PVEFrame)
    self:SetEditBox(LFGListFrame.SearchPanel.SearchBox)
    self:SetScrollBar(LFGListFrame.SearchPanel)
    self:SetNineSlice(LFGListFrame.SearchPanel.ResultsInset)

    self:SetFrame(LFGListFrame.CategorySelection.Inset, {alpha= 0.3})
    self:SetNineSlice(LFGListFrame.CategorySelection.Inset)
    self:HideTexture(LFGListFrame.CategorySelection.Inset.Bg)
    self:HideTexture(LFGListFrame.CategorySelection.Inset.CustomBG)

    self:SetFrame(LFGDungeonReadyDialog.Border, {alpha= 0.3})
    self:SetButton(LFGDungeonReadyDialogCloseButton)

    self:SetFrame(LFDRoleCheckPopup.Border, {alpha= 0.3})
    self:SetFrame(LFGDungeonReadyStatus.Border, {alpha= 0.3})
    self:SetButton(LFGDungeonReadyStatusCloseButton)

    self:SetScrollBar(LFDQueueFrameSpecific)


    self:SetNineSlice(LFGListFrame.EntryCreation.Inset)
    self:HideTexture(LFGListFrame.EntryCreation.Inset.CustomBG)
    self:HideTexture(LFGListFrame.EntryCreation.Inset.Bg)

    self:SetMenu(LFGListEntryCreationGroupDropdown)
    self:SetMenu(LFGListEntryCreationActivityDropdown)
    self:SetMenu(LFGListEntryCreationPlayStyleDropdown)
    self:SetEditBox(LFGListFrame.EntryCreation.Name)
    self:SetEditBox(LFGListCreationDescription.EditBox)
    self:SetEditBox(LFGListFrame.EntryCreation.ItemLevel.EditBox)
    self:SetEditBox(LFGListFrame.EntryCreation.VoiceChat.EditBox)

    self:SetAlphaColor(LFGListFrameMiddleMiddle)
    self:SetAlphaColor(LFGListFrameMiddleLeft)
    self:SetAlphaColor(LFGListFrameMiddleRight)
    self:SetAlphaColor(LFGListFrameBottomMiddle)
    self:SetAlphaColor(LFGListFrameTopMiddle)
    self:SetAlphaColor(LFGListFrameTopLeft)
    self:SetAlphaColor(LFGListFrameBottomLeft)
    self:SetAlphaColor(LFGListFrameTopRight)
    self:SetAlphaColor(LFGListFrameBottomRight)

    self:SetScrollBar(LFGListFrame.ApplicationViewer)
    self:SetNineSlice(LFGListFrame.ApplicationViewer.Inset)

    self:SetAlphaColor(RaidFinderQueueFrameBackground)

    self:HideTexture(RaidFinderFrameRoleBackground)


    --右边
    self:HideFrame(PVEFrame)
    --[[self:HideTexture(PVEFrameLLVert)
    self:HideTexture(PVEFrameRLVert)
    self:HideTexture(PVEFrameBLCorner)
    self:HideTexture(PVEFrameBottomLine)
    self:HideTexture(PVEFrameBRCorner)
    self:HideTexture(PVEFrameTLCorner)
    self:HideTexture(PVEFrameTopLine)
    self:HideTexture(PVEFrameTRCorner)
    ]]

    --self:HideTexture(PVEFrameBg)--左边


    self:HideTexture(PVEFrameBlueBg)
    self:HideTexture(PVEFrameLeftInset.Bg)
    self:SetNineSlice(PVEFrameLeftInset)
    self:HideFrame(PVEFrame.shadows)

    self:SetAlphaColor(LFDQueueFrameBackground, nil, nil, 0.3)

    self:SetMenu(LFDQueueFrameTypeDropdown)
    LFDQueueFrameTypeDropdownName:ClearAllPoints()
    LFDQueueFrameTypeDropdownName:SetPoint('BOTTOMLEFT', LFDQueueFrameRandomScrollFrame, 'TOPLEFT', 0, 15)
    LFDQueueFrameTypeDropdownName:SetWidth(LFDQueueFrameTypeDropdownName:GetStringWidth()+4)
    --LFDQueueFrameTypeDropdownName:SetJustifyH('LEFT')


    self:SetMenu(LFGListFrame.SearchPanel.FilterButton)

    self:SetNineSlice(LFDParentFrameInset)
    self:HideTexture(LFDParentFrameInset.Bg)
    self:SetNineSlice(RaidFinderFrameBottomInset)
    self:SetAlphaColor(RaidFinderFrameBottomInset.Bg)

    self:SetAlphaColor(LFDParentFrameRoleBackground)

    self:HideTexture(LFDParentFrameRoleBackground)
    self:SetNineSlice(RaidFinderFrameRoleInset)
    self:HideTexture(RaidFinderFrameRoleInset.Bg)

    for i=1, 5 do
        local b= _G['GroupFinderFrameGroupButton'..i]
        if b then
            self:SetAlphaColor(b.bg, nil, nil, 0.5)
        end
    end

    WoWTools_DataMixin:Hook('LFGListCategorySelection_AddButton', function(frame, btnIndex)
        local btn = frame.CategoryButtons[btnIndex];
        if btn then
            self:SetAlphaColor(btn.Icon, nil, nil, 0.5)
            self:HideTexture(btn.Cover)
        end
    end)

    self:Init_BGMenu_Frame(PVEFrame)
end










--地下城和团队副本, PVP
function WoWTools_TextureMixin.Events:Blizzard_PVPUI()
    self:HideTexture(HonorFrame.Inset.Bg)

    self:SetNineSlice(HonorFrame.Inset)
    HonorFrame.BonusFrame.WorldBattlesTexture:SetAlpha(0)
    HonorFrame.BonusFrame.ShadowOverlay:SetAlpha(0)

    self:HideTexture(HonorFrame.ConquestBar.Background)
    self:SetNineSlice(PVPQueueFrame.HonorInset)--最右边

    self:SetNineSlice(ConquestFrame.Inset)--中间
    self:HideTexture(ConquestFrame.Inset.Bg)
    self:HideTexture(ConquestFrameLeft)
    self:HideTexture(ConquestFrameRight)
    self:HideTexture(ConquestFrameTopRight)
    self:HideTexture(ConquestFrameTop)
    self:HideTexture(ConquestFrameTopLeft)
    self:HideTexture(ConquestFrameBottomLeft)
    self:HideTexture(ConquestFrameBottom)
    self:HideTexture(ConquestFrameBottomRight)

    self:SetAlphaColor(ConquestFrame.RatedBGTexture)
    PVPQueueFrame.HonorInset:DisableDrawLayer('BACKGROUND')
    self:SetAlphaColor(PVPQueueFrame.HonorInset.CasualPanel.HonorLevelDisplay.Background)
    self:HideTexture(ConquestFrame.RatedBGTexture)

    for i=1, 4 do
        local b= _G['PVPQueueFrameCategoryButton'..i]
        if b then
            self:SetAlphaColor(b.Background, nil, nil, 0.5)
        end
    end
end



--挑战, 钥匙插入，界面
function WoWTools_TextureMixin.Events:Blizzard_ChallengesUI()
    self:HideFrame(ChallengesFrame)
    self:HideTexture(ChallengesFrame.Background)
    ChallengesFrame.Background:ClearAllPoints()
    self:HideTexture(ChallengesFrameInset.Bg)
    self:SetNineSlice(ChallengesFrameInset)
    self:HideTexture(ChallengesFrame.WeeklyInfo.Child.RuneBG)

--钥匙插入，界面
    self:SetButton(ChallengesKeystoneFrame.CloseButton)
    self:HideFrame(ChallengesKeystoneFrame, {index=1})
    self:HideTexture(ChallengesKeystoneFrame.InstructionBackground)
    WoWTools_DataMixin:Hook(ChallengesKeystoneFrame, 'Reset', function(frame)
        self:HideTexture(frame, {index=1})
        self:HideTexture(frame.InstructionBackground)
    end)


    self:Init_BGMenu_Frame(ChallengesKeystoneFrame, {
        isNewButton=ChallengesKeystoneFrame.CloseButton,
        newButtonPoint=function(btn)
            btn:SetPoint('RIGHT', ChallengesKeystoneFrame.CloseButton, 'LEFT', -23, 0)
        end
    })
end




function WoWTools_TextureMixin.Events:Blizzard_WeeklyRewards()--周奖励提示
    self:HideFrame(WeeklyRewardsFrame)
    self:SetButton(WeeklyRewardsFrame.CloseButton)

    WoWTools_DataMixin:Hook(WeeklyRewardsFrame, 'UpdateOverlay', function(f)
        f= f.Overlay
        if not f or not f:IsShown() then
            return
        end
        self:SetNineSlice(f)
        self:SetFrame(f)
    end)

    WoWTools_DataMixin:Hook(WeeklyRewardsFrame,'UpdateSelection', function(frame)
        for _, f in ipairs(frame.Activities) do
            self:SetAlphaColor(f.Background)
        end
    end)

    self:Init_BGMenu_Frame(WeeklyRewardsFrame, {
        isNewButton=true,
        newButtonAlpha=1,
        newButtonPoint=function(btn)
            btn:SetPoint('TOPLEFT', 10, -10)
        end,
        bgPoint=function(icon)
            icon:SetPoint('TOPLEFT', 10, -10)
            icon:SetPoint('BOTTOMRIGHT', -10, 10)
        end
    })
end





--地下堡
function WoWTools_TextureMixin.Events:Blizzard_DelvesDashboardUI()
    self:HideTexture(DelvesDashboardFrame.DashboardBackground)
    self:HideTexture(DelvesDashboardFrame.ThresholdBar.BarBackground)
    self:SetAlphaColor(DelvesDashboardFrame.ThresholdBar.BarBorder, nil, nil, 0.3)

    WoWTools_DataMixin:Hook(DelvesDashboardFrame, 'UpdateGreatVaultVisibility', function(f)
        local bg= f.ButtonPanelLayoutFrame.CompanionConfigButtonPanel.ButtonPanelBackground
        bg:SetAlpha(bg:IsDesaturated() and 0.5 or 0)

        bg = f.ButtonPanelLayoutFrame.GreatVaultButtonPanel.ButtonPanelBackground
        bg:SetAlpha(bg:IsDesaturated() and 0.5 or 0)
    end)

end

function WoWTools_TextureMixin.Events:Blizzard_DelvesDifficultyPicker()
    self:SetNineSlice(DelvesDifficultyPickerFrame)
    self:HideFrame(DelvesDifficultyPickerFrame.Border)
    self:SetButton(DelvesDifficultyPickerFrame.CloseButton)
end















--货币
function WoWTools_TextureMixin.Events:Blizzard_TokenUI()
    self:SetFrame(TokenFramePopup.Border, {alpha=0.3})
    self:SetButton(CurrencyTransferMenuCloseButton)
    self:SetFrame(TokenFrame)
    self:SetMenu(TokenFrame.filterDropdown)

    self:SetScrollBar(TokenFrame)--bug，货币转移，出错
    --[[self:SetAlphaColor(TokenFrame.ScrollBar.Track.Thumb.Begin, true)
    self:SetAlphaColor(TokenFrame.ScrollBar.Track.Thumb.Middle, true)
    self:SetAlphaColor(TokenFrame.ScrollBar.Track.Thumb.End, true)]]





    WoWTools_DataMixin:Hook(TokenFrame.ScrollBox, 'Update', function(f)
        if not f:GetView() then
            return
        end
        for _, frame in pairs(f:GetFrames() or {}) do
            if frame.Middle then
                self:SetAlphaColor(frame.Middle, nil, nil, true)
                self:SetAlphaColor(frame.Right, nil, nil, true)
                self:SetAlphaColor(frame.Left, nil, nil, true)
            end
        end
    end)

    self:CreateBG(TokenFrame.ScrollBox, {--添加Bg
        atlas= "UI-Character-Info-"..WoWTools_DataMixin.Player.Class.."-BG",
        alpha=0.3,
        isAllPoint=true,
    })


--货币转移
    self:SetButton(CurrencyTransferLogCloseButton)
    self:SetNineSlice(CurrencyTransferLog)
    self:SetAlphaColor(CurrencyTransferLogBg, nil, nil, 0.3)
    self:SetNineSlice(CurrencyTransferLogInset, nil, true)
    self:SetScrollBar(CurrencyTransferLog)

    self:SetNineSlice(CurrencyTransferMenu)
    self:SetAlphaColor(CurrencyTransferMenu.TransactionDivider)
    self:HideTexture(CurrencyTransferMenuBg)
    self:SetNineSlice(CurrencyTransferMenuInset)


    if CurrencyTransferMenu.AmountSelector then--11.2 没有了
        self:SetEditBox(CurrencyTransferMenu.AmountSelector.InputBox)
        self:SetMenu(CurrencyTransferMenu.SourceSelector.Dropdown)
    else
        self:SetEditBox(CurrencyTransferMenu.Content.AmountSelector.InputBox)
        self:SetMenu(CurrencyTransferMenu.Content.SourceSelector.Dropdown)
    end
end




--玩家, 观察角色, 界面
function WoWTools_TextureMixin.Events:Blizzard_InspectUI()
    self:HideFrame(InspectFrame)
    self:HideFrame(InspectModelFrame)
    self:HideFrame(InspectModelFrameControlFrame)
    self:SetButton(InspectFrameCloseButton)
    self:HideTexture(InspectFrameInset.Bg)
    self:HideTexture(InspectPVPFrame.BG)

    self:HideTexture(InspectGuildFrameBG)
    self:SetTabButton(InspectFrameTab1)
    self:SetTabButton(InspectFrameTab2)
    self:SetTabButton(InspectFrameTab3)
    --self:SetNineSlice(InspectFrame)
    self:SetNineSlice(InspectFrameInset)

    self:SetAlphaColor(InspectModelFrameBackgroundOverlay, nil, nil, 0)
    self:SetAlphaColor(InspectModelFrameBackgroundBotLeft, nil, nil, 0)
    self:SetAlphaColor(InspectModelFrameBackgroundBotRight, nil, nil, 0)
    self:SetAlphaColor(InspectModelFrameBackgroundTopLeft, nil, nil, 0)
    self:SetAlphaColor(InspectModelFrameBackgroundTopRight, nil, nil, 0)

    self:HideTexture(InspectHeadSlotFrame)
	self:HideTexture(InspectNeckSlotFrame)
	self:HideTexture(InspectShoulderSlotFrame)
	self:HideTexture(InspectBackSlotFrame)
	self:HideTexture(InspectChestSlotFrame)
	self:HideTexture(InspectShirtSlotFrame)
	self:HideTexture(InspectTabardSlotFrame)
	self:HideTexture(InspectWristSlotFrame)
	self:HideTexture(InspectHandsSlotFrame)
	self:HideTexture(InspectWaistSlotFrame)
	self:HideTexture(InspectLegsSlotFrame)
	self:HideTexture(InspectFeetSlotFrame)
	self:HideTexture(InspectFinger0SlotFrame)
	self:HideTexture(InspectFinger1SlotFrame)
	self:HideTexture(InspectTrinket0SlotFrame)
	self:HideTexture(InspectTrinket1SlotFrame)
	self:HideTexture(InspectMainHandSlotFrame)
	self:HideTexture(InspectSecondaryHandSlotFrame)

    self:HideFrame(InspectMainHandSlot)

    self:Init_BGMenu_Frame(InspectFrame)
end










function WoWTools_TextureMixin.Events:Blizzard_EventTrace()
    local function set_button(btn)
        if btn then
            self:SetAlphaColor(btn.NormalTexture, nil, nil, true)
            if btn.MouseoverOverlay then
                btn.MouseoverOverlay:SetTexCoord(0,1,0.8,0)
            end
        end
    end
    self:SetButton(EventTraceCloseButton)
    self:SetNineSlice(EventTrace, self.min, true)
    self:SetAlphaColor(EventTraceBg, nil, nil, true)
    self:SetAlphaColor(EventTraceInset.Bg, nil, nil, true)
    self:SetNineSlice(EventTraceInset)
    self:SetButton(EventTrace.ResizeButton)
    self:SetScrollBar(EventTrace.Log.Events)
    self:SetEditBox(EventTrace.Log.Bar.SearchBox)

    set_button(EventTrace.SubtitleBar.ViewLog)
    set_button(EventTrace.SubtitleBar.ViewFilter)

    set_button(EventTrace.Log.Bar.DiscardAllButton)
    set_button(EventTrace.Log.Bar.PlaybackButton)
    set_button(EventTrace.Log.Bar.MarkButton)

    set_button(EventTrace.Filter.Bar.DiscardAllButton)
    set_button(EventTrace.Filter.Bar.UncheckAllButton)
    set_button(EventTrace.Filter.Bar.CheckAllButton)

    self:SetFrame(EventTrace.Log.Events.ScrollBox, {index=1, isMinAlpha=true})
    self:SetFrame(EventTrace.Filter.ScrollBox, {index=1, isMinAlpha=true})

    WoWTools_DataMixin:Hook(EventTraceLogEventButtonMixin, 'OnLoad', function(frame)
        self:SetButton(frame.HideButton)
        local icon= frame:GetRegions()
        if icon:GetObjectType()=='Texture' then
            icon:SetTexture(0)
        end
        --frame.Alternate:SetAlpha(0.75)
    end)
    WoWTools_DataMixin:Hook(EventTraceFilterButtonMixin, 'Init', function(frame, elementData, hideCb)
        local icon= frame:GetRegions()
        if icon:GetObjectType()=='Texture' then
            icon:SetTexture(0)
        end
    end)
end
























--天赋，法术书
function WoWTools_TextureMixin.Events:Blizzard_PlayerSpells()
    self:SetButton(PlayerSpellsFrameCloseButton)
    self:SetButton(PlayerSpellsFrame.MaximizeMinimizeButton.MaximizeButton)
    self:SetButton(PlayerSpellsFrame.MaximizeMinimizeButton.MinimizeButton)
    self:HideTexture(PlayerSpellsFrame.TopTileStreaks)


    --self:SetAlphaColor(PlayerSpellsFrameBg)
    self:SetNineSlice(PlayerSpellsFrame)
    --self:SetTabSystem(PlayerSpellsFrame)

    self:SetAlphaColor(PlayerSpellsFrame.SpecFrame.Background, 0.3)--专精
    self:HideTexture(PlayerSpellsFrame.SpecFrame.BlackBG)

    self:SetAlphaColor(PlayerSpellsFrame.TalentsFrame.BottomBar, 0.3)--天赋
    self:HideTexture(PlayerSpellsFrame.TalentsFrame.BlackBG)
    self:SetEditBox(PlayerSpellsFrame.TalentsFrame.SearchBox)
    self:SetMenu(PlayerSpellsFrame.TalentsFrame.LoadSystem.Dropdown)


    self:HideTexture(PlayerSpellsFrame.SpellBookFrame.TopBar)--法术书

    self:SetEditBox(PlayerSpellsFrame.SpellBookFrame.SearchBox)
    self:SetFrame(PlayerSpellsFrame.SpellBookFrame.SearchPreviewContainer)

    --英雄专精
    self:SetNineSlice(HeroTalentsSelectionDialog, self.min, true)
    self:SetButton(HeroTalentsSelectionDialog.CloseButton)

    if PlayerSpellsFrame.SpellBookFrame.SettingsDropdown then--11.1.7
        self:SetAlphaColor(PlayerSpellsFrame.SpellBookFrame.SettingsDropdown.Icon, true, nil, nil)
        self:SetAlphaColor(PlayerSpellsFrame.SpellBookFrame.AssistedCombatRotationSpellFrame.Button.Border, nil, nil,  true)
    end




--背景
    self:HideTexture(PlayerSpellsFrameBg)

--专精 ClassSpecFrameTemplate
    --PlayerSpellsFrame.SpecFrame.Background:ClearAllPoints()
    --PlayerSpellsFrame.SpecFrame.Background:SetPoint('TOPLEFT', PlayerSpellsFrame, 3, -3)
    --PlayerSpellsFrame.SpecFrame.Background:SetPoint('BOTTOMRIGHT', PlayerSpellsFrame, -3, 3)

--天赋 ClassTalentsFrameTemplate
    --PlayerSpellsFrame.TalentsFrame.Background:ClearAllPoints()
    --PlayerSpellsFrame.TalentsFrame.Background:SetPoint('TOPLEFT', PlayerSpellsFrame, 3, -3)
    --PlayerSpellsFrame.TalentsFrame.Background:SetPoint('BOTTOMRIGHT', PlayerSpellsFrame, -3, 3)

    PlayerSpellsFrame.TalentsFrame.BottomBar:SetAlpha(0)
    PlayerSpellsFrame.TalentsFrame.HeroTalentsContainer.ExpandedContainer.Background:SetAlpha(0.2)
    PlayerSpellsFrame.TalentsFrame.HeroTalentsContainer.PreviewContainer.Background:SetAlpha(0.2)

--法术书 SpellBookFrameTemplate
    self:SetFrame(PlayerSpellsFrame.SpellBookFrame.HelpPlateButton, {alpha=0.3})

    self:Init_BGMenu_Frame(PlayerSpellsFrame, {
        settings=function(_, texture, alpha)
            PlayerSpellsFrame.SpecFrame.Background:SetAlpha(texture and 0 or alpha or 1)
            PlayerSpellsFrame.TalentsFrame.Background:SetAlpha(texture and 0 or alpha or 1)
        end
    })
end















































--商店
function WoWTools_TextureMixin.Events:Blizzard_AccountStore()
    self:HideFrame(AccountStoreFrame)
    self:SetNineSlice(AccountStoreFrame)

    self:SetButton(AccountStoreFrameCloseButton)

    self:HideFrame(AccountStoreFrame.LeftInset)
    self:HideFrame(AccountStoreFrame.RightInset)
    self:HideFrame(AccountStoreFrame.LeftDisplay)
    AccountStoreFrame.RightDisplay.ShadowOverlay:SetAlpha(0)

    self:SetScrollBar(AccountStoreFrame.CategoryList)

    self:Init_BGMenu_Frame(AccountStoreFrame)
end














--专业书
function WoWTools_TextureMixin.Events:Blizzard_ProfessionsBook()
    ProfessionsBookPage1:SetPoint('TOPLEFT', ProfessionsBookFrame, 'TOPLEFT', 0, -23)
    ProfessionsBookPage1:SetPoint('BOTTOM',0, -15)
    ProfessionsBookPage2:SetPoint('BOTTOMRIGHT', 15, -15)
    self:SetNineSlice(ProfessionsBookFrame)
    self:SetNineSlice(ProfessionsBookFrameInset)
    self:HideTexture(ProfessionsBookFrameBg)
    self:HideTexture(ProfessionsBookFrameInset.Bg)
    self:SetButton(ProfessionsBookFrameCloseButton)

    ProfessionsBookFrameTutorialButton:SetFrameLevel(ProfessionsBookFrameCloseButton:GetFrameLevel()+1)
    self:SetButton(ProfessionsBookFrameTutorialButton)

    self:Init_BGMenu_Frame(ProfessionsBookFrame, {
        settings=function(_, texture, alpha)--设置内容时，调用
            ProfessionsBookPage1:SetAlpha(texture and 0 or alpha or 1)
            ProfessionsBookPage2:SetAlpha(texture and 0 or alpha or 1)
        end,
        alpha=1,
        enabled=true,
    })

    PrimaryProfession1.bg= PrimaryProfession1:CreateTexture(nil, 'BACKGROUND')
    PrimaryProfession1.bg:SetAtlas('delves-affix-mask')
    PrimaryProfession1.bg:SetAllPoints(PrimaryProfession1Icon)

    PrimaryProfession2.bg= PrimaryProfession2:CreateTexture(nil, 'BACKGROUND')
    PrimaryProfession2.bg:SetAtlas('delves-affix-mask')
    PrimaryProfession2.bg:SetAllPoints(PrimaryProfession2Icon)

    self:HideTexture(PrimaryProfession1SpellButtonBottomNameFrame)
    self:HideTexture(PrimaryProfession2SpellButtonBottomNameFrame)

    self:HideTexture(SecondaryProfession1SpellButtonLeftNameFrame)
    self:HideTexture(SecondaryProfession1SpellButtonRightNameFrame)

    self:HideTexture(SecondaryProfession2SpellButtonLeftNameFrame)
    self:HideTexture(SecondaryProfession2SpellButtonRightNameFrame)

    self:HideTexture(SecondaryProfession3SpellButtonLeftNameFrame)
    self:HideTexture(SecondaryProfession3SpellButtonRightNameFrame)
end


function WoWTools_TextureMixin.Events:Blizzard_ArtifactUI()
    self:HideFrame(ArtifactFrame)
    self:SetButton(ArtifactFrame.CloseButton)
    self:SetFrame(ArtifactFrame.BorderFrame)
    self:SetAlphaColor(ArtifactFrame.ForgeBadgeFrame.ItemIconBorder, true)



    if ArtifactFrame.PerksTab then
        self:SetFrame(ArtifactFrame.PerksTab, {alpha=0})
        self:SetAlphaColor(ArtifactFrame.PerksTab.BackgroundBack, nil, nil, 0)

        self:HideFrame(ArtifactFrame.PerksTab.Model)
    end

    self:Init_BGMenu_Frame(ArtifactFrame, {
        isNewButton=true
    })
end

function WoWTools_TextureMixin.Events:Blizzard_RemixArtifactUI()
    self:SetButton(RemixArtifactFrame.CloseButton)
    WoWTools_TextureMixin:Init_BGMenu_Frame(RemixArtifactFrame, {
        --enabled=true,
        isNewButton=true,
        alpha=0,
        nineSliceAlpha=0,
        portraitAlpha=0.5,
        settings=function(icon, textureName, alphaValue, _, portraitAlpha)--设置内容时，调用
            RemixArtifactFrame.PortraitAlpha= portraitAlpha or 1
            local alpha= textureName and 0 or alphaValue or 1

            self:SetAlphaColor(RemixArtifactFrame.Model.BackgroundFront, nil, true, math.min(alpha, 0.15))
            self:SetAlphaColor(RemixArtifactFrame.Model.BackgroundFrontSides, nil, true, math.min(alpha, 0.2))
            self:SetAlphaColor(RemixArtifactFrame.Model.BackgroundVignette, nil, true, math.min(alpha, 0.8))

            self:SetAlphaColor(RemixArtifactFrame.Background, nil, true, alpha)

            self:SetAlphaColor(RemixArtifactFrame.ButtonsParent.Overlay, nil, true, alpha)

            RemixArtifactFrame.Model:SetModelAlpha(portraitAlpha)
            RemixArtifactFrame.AltModel:SetModelAlpha(portraitAlpha)
        end
    })
    RemixArtifactFrame:HookScript('OnShow', function(f)
        C_Timer.After(0.3, function()
            f.Model:SetModelAlpha(f.PortraitAlpha or 1)
            f.AltModel:SetModelAlpha(f.PortraitAlpha or 1)
        end)
    end)



end




