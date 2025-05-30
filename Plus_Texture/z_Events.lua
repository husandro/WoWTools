
function WoWTools_TextureMixin.Events:Blizzard_ActionBar()
    self:HideTexture(SpellFlyout.Background.Start)
    self:HideTexture(SpellFlyout.Background.End)
    self:HideTexture(SpellFlyout.Background.HorizontalMiddle)
    self:HideTexture(SpellFlyout.Background.VerticalMiddle)
end


function WoWTools_TextureMixin.Events:Blizzard_TrainerUI()
    self:SetFrame(ClassTrainerFrame, {alpha=0.3})
    self:SetScrollBar(ClassTrainerFrame)
    self:SetNineSlice(ClassTrainerFrame, true)

    self:HideTexture(ClassTrainerFrameInset.Bg)
    self:SetNineSlice(ClassTrainerFrameInset, true)

    self:HideTexture(ClassTrainerFrameBottomInset.Bg)
    self:SetNineSlice(ClassTrainerFrameBottomInset, true)
end





--小时图，时间
function WoWTools_TextureMixin.Events:Blizzard_TimeManager()
    self:SetNineSlice(TimeManagerFrame, true)
    self:SetAlphaColor(TimeManagerFrameBg)
    self:HideTexture(TimeManagerFrameInset.Bg)
    self:SetEditBox(TimeManagerAlarmMessageEditBox)
    WoWTools_ColorMixin:Setup(TimeManagerClockTicker, {type='FontString', alpha=1})--设置颜色

    --秒表 Blizzard_TimeManager.lua
    self:HideTexture(StopwatchFrameBackgroundLeft)
    if StopwatchFrame then
        self:HideTexture(select(2, StopwatchFrame:GetRegions()))
        self:HideTexture(StopwatchTabFrameMiddle)
        self:HideTexture(StopwatchTabFrameRight)
        self:HideTexture(StopwatchTabFrameLeft)
    end
end

















function WoWTools_TextureMixin.Events:Blizzard_AchievementUI()--成就
    self:HideFrame(AchievementFrame)

    hooksecurefunc(AchievementStatTemplateMixin, 'OnLoad', function(f)
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
--成就，显示，按钮
    hooksecurefunc(AchievementTemplateMixin, 'OnLoad', function(f)
        --self:SetAlphaColor(f.Glow, nil, true, 0.85)
        --self:SetAlphaColor(f.Background, nil, true, 0.85)
        self:SetNineSlice(f, nil, true)
     end)



--左下边水印
    self:SetAlphaColor(AchievementFrameWaterMark, nil, true, 0)

--标题
    self:HideTexture(AchievementFrame.Header.Left)
    self:HideTexture(AchievementFrame.Header.Right)
    self:HideTexture(AchievementFrame.Header.RightDDLInset)
    self:HideTexture(AchievementFrame.Header.LeftDDLInset)
    self:HideTexture(AchievementFrame.Header.PointBorder)

    self:SetButton(AchievementFrameCloseButton, {all=true})

--总列表
    self:SetNineSlice(AchievementFrameCategories, nil, true)
    self:SetScrollBar(AchievementFrameCategories)
    hooksecurefunc(AchievementCategoryTemplateMixin, 'OnLoad', function(f)
        self:SetAlphaColor(f.Button.Background, nil, nil, 0.85)
    end)

--成就，列表
    self:SetScrollBar(AchievementFrameAchievements)
    self:HideFrame(AchievementFrameAchievements)
    self:SetNineSlice(AchievementFrameAchievements, nil, true, nil, nil, true)

--总览
    self:SetNineSlice(AchievementFrameSummary, nil, true)
    self:HideFrame(AchievementFrameSummary)
    self:SetNineSlice(AchievementFrameSummary, nil, true, nil, nil, true)
--近期成就
    self:SetAlphaColor(AchievementFrameSummaryAchievementsHeaderHeader, nil, nil, 0.5)
    hooksecurefunc('AchievementFrameSummaryAchievement_OnLoad', function(f)
        --self:SetAlphaColor(f.TitleBar, nil, nil, 0.5)
        --self:SetAlphaColor(f.Glow, nil, nil, 0.3)
        --self:SetAlphaColor(f.Background, nil, nil, 0.3)
        self:SetNineSlice(f, nil, true)
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
    self:SetNineSlice(AchievementFrameComparison, nil, true, nil, nil, true)

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
    self:SetNineSlice(AchievementFrameStats, nil, true, nil, nil, true)
    self:SetAlphaColor(AchievementFrameStatsBG, nil, nil, 0.3)
    self:SetScrollBar(AchievementFrameStats)
    self:SetScrollBar(AchievementFrameComparison.StatContainer)

    --WoWTools_ButtonMixin:AddMask(AchievementFrame, nil, AchievementFrame.Background)
    AchievementFrame.bgMenuButton= WoWTools_ButtonMixin:Cbtn(AchievementFrame.Header, {
        size=23,
        name='AchievementFrameBGMenuButton',
        texture='Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools',
        alpha=0.75
    })
    AchievementFrame.bgMenuButton:SetPoint('RIGHT', AchievementFrame.Header.Points, 'LEFT', -4, 0)
    
    self:Init_BGMenu_Frame(
        AchievementFrame,
        'AchievementFrame',
        AchievementFrame.Background,
    {
        menuButton=AchievementFrame.bgMenuButton
    })

end
















--冒险指南
function WoWTools_TextureMixin.Events:Blizzard_EncounterJournal()
    self:SetButton(EncounterJournalCloseButton, {all=true})
    self:SetNineSlice(EncounterJournal, true)

    self:HideTexture(EncounterJournalBg)
    self:SetAlphaColor(EncounterJournalInset.Bg, nil, nil, 0.3)
    self:SetNineSlice(EncounterJournalInset, nil, true)
    self:SetScrollBar(EncounterJournalInstanceSelect)
    self:SetEditBox(EncounterJournalSearchBox)
    self:SetScrollBar(EncounterJournal.LootJournalItems.ItemSetsFrame)
    self:SetScrollBar(EncounterJournalEncounterFrameInfo.LootContainer)
    self:SetScrollBar(EncounterJournalEncounterFrameInfoDetailsScrollFrame)
    self:HideTexture(EncounterJournalNavBar.overlay)
    self:HideTexture(EncounterJournalNavBarInsetBottomBorder)
    self:HideTexture(EncounterJournalNavBarInsetRightBorder)
    self:HideTexture(EncounterJournalNavBarInsetLeftBorder)
    self:HideTexture(EncounterJournalNavBarInsetBotRightCorner)
    self:HideTexture(EncounterJournalNavBarInsetBotLeftCorner)

    self:SetAlphaColor(EncounterJournalInstanceSelectBG)
    self:SetAlphaColor(EncounterJournalEncounterFrameInfoModelFrameDungeonBG)
    EncounterJournalNavBar:DisableDrawLayer('BACKGROUND')

    self:SetScrollBar(EncounterJournalEncounterFrameInfoOverviewScrollFrame)

    self:SetFrame(EncounterJournalSuggestTab, {notAlpha=true})
    self:SetFrame(EncounterJournalMonthlyActivitiesTab, {notAlpha=true})
    self:SetFrame(EncounterJournalDungeonTab, {notAlpha=true})
    self:SetFrame(EncounterJournalRaidTab, {notAlpha=true})
    self:SetFrame(EncounterJournalLootJournalTab, {notAlpha=true})



    self:SetScrollBar(EncounterJournalEncounterFrameInfo.BossesScrollBar)
    self:SetScrollBar(EncounterJournalEncounterFrameInstanceFrame.LoreScrollBar)
    self:SetScrollBar(EncounterJournal.LootJournal)

    EncounterJournal.LootJournalItems.ItemSetsFrame.ClassDropdown:ClearAllPoints()
    EncounterJournal.LootJournalItems.ItemSetsFrame.ClassDropdown:SetPoint('BOTTOM', EncounterJournal.LootJournalItems.ItemSetsFrame.ClassDropdown:GetParent(), 'TOP', 0, 25)

    self:HideTexture(EncounterJournalMonthlyActivitiesFrame.Bg)
    self:HideTexture(EncounterJournalMonthlyActivitiesFrame.ShadowRight)
    self:SetScrollBar(EncounterJournalMonthlyActivitiesFrame)
    self:SetScrollBar(EncounterJournalMonthlyActivitiesFrame.FilterList)
    self:SetFrame(EncounterJournalMonthlyActivitiesFrame.HelpButton, {alpha=0.3})
end










--[[公会银行
function WoWTools_TextureMixin.Events:Blizzard_GuildBankUI()
    if WoWToolsSave['Plus_GuildBank'].disabled then
        WoWTools_GuildBankself:Init_Guild_Texture()
    end
end]]

function WoWTools_TextureMixin.Events:Blizzard_GuildRename()--11.1.5
    self:SetNineSlice(GuildRenameFrame)
    self:SetAlphaColor(GuildRenameFrameBg, nil, nil, true)
    self:HideTexture(GuildRenameFrameInset.Bg)
    --self:SetInset(GuildRenameFrameInset)
    self:SetNineSlice(GuildRenameFrameInset)

    GuildRegistrarFrameNpcNameText:SetParent(GuildRegistrarFrame.TitleContainer)

    self:SetEditBox(GuildRegistrarFrameEditBox)

end



--拍卖行
function WoWTools_TextureMixin.Events:Blizzard_AuctionHouseUI()
    self:SetAlphaColor(AuctionHouseFrameBg)
    self:SetNineSlice(AuctionHouseFrame, true)
    self:SetAlphaColor(AuctionHouseFrameMiddle, nil, nil, 0.3)
    self:SetAlphaColor(AuctionHouseFrameLeft, nil, nil, 0.3)
    self:SetAlphaColor(AuctionHouseFrameRight, nil, nil, 0.3)

    self:SetFrame(AuctionHouseFrameBuyTab, {notAlpha=true})--{alpha= 0.3})
    self:SetFrame(AuctionHouseFrameSellTab, {notAlpha=true})--{alpha= 0.3})
    self:SetFrame(AuctionHouseFrameAuctionsTab, {notAlpha=true})--{alpha= 0.3})
    self:SetFrame(AuctionHouseFrame.SearchBar.FilterButton, {alpha= 0.3})

    self:SetNineSlice(AuctionHouseFrame.CategoriesList, nil, true)
    self:SetScrollBar(AuctionHouseFrame.CategoriesList)
    self:HideTexture(AuctionHouseFrame.CategoriesList.Background)

    self:SetScrollBar(AuctionHouseFrameAuctionsFrame.BidsList)
    self:SetNineSlice(AuctionHouseFrameAuctionsFrame.BidsList, nil, true)
    self:SetNineSlice(AuctionHouseFrameAuctionsFrame.AllAuctionsList, nil, true)
    self:SetScrollBar(AuctionHouseFrameAuctionsFrame.AllAuctionsList)
    self:SetScrollBar(AuctionHouseFrameAuctionsFrame.SummaryList)
    self:SetNineSlice(AuctionHouseFrameAuctionsFrame.SummaryList, nil, true)


    self:SetNineSlice(AuctionHouseFrame.BrowseResultsFrame.ItemList, nil, true)
    self:SetScrollBar(AuctionHouseFrame.BrowseResultsFrame.ItemList)

    self:SetNineSlice(AuctionHouseFrame.MoneyFrameInset, nil, true)
    self:HideTexture(AuctionHouseFrame.MoneyFrameInset.Bg)
    self:HideFrame(AuctionHouseFrame.MoneyFrameBorder)

    self:SetEditBox(AuctionHouseFrame.SearchBar.SearchBox)


    self:SetNineSlice(AuctionHouseFrame.CommoditiesSellList, nil, true)
    self:SetScrollBar(AuctionHouseFrame.CommoditiesSellList)
    self:SetNineSlice(AuctionHouseFrame.CommoditiesSellFrame, nil, true)
    self:SetFrame(AuctionHouseFrame.CommoditiesSellFrame.ItemDisplay, {alpha=0})
    self:SetEditBox(AuctionHouseFrame.CommoditiesSellFrame.QuantityInput.InputBox)
    self:SetEditBox(AuctionHouseFrame.CommoditiesSellFrame.PriceInput.MoneyInputFrame.GoldBox)
    self:SetEditBox(AuctionHouseFrame.CommoditiesSellFrame.PriceInput.MoneyInputFrame.SilverBox)

    self:SetAlphaColor(AuctionHouseFrame.CommoditiesSellFrame.CreateAuctionTabMiddle, nil, nil, 0.3)
    self:SetAlphaColor(AuctionHouseFrame.CommoditiesSellFrame.CreateAuctionTabLeft, nil, nil, 0.3)
    self:SetAlphaColor(AuctionHouseFrame.CommoditiesSellFrame.CreateAuctionTabRight, nil, nil, 0.3)

    self:SetNineSlice(AuctionHouseFrame.ItemSellList, nil, true)
    self:SetScrollBar(AuctionHouseFrame.ItemSellList)
    self:SetNineSlice(AuctionHouseFrame.ItemSellFrame, nil, true)
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
    self:SetNineSlice(AuctionHouseFrameAuctionsFrame.ItemDisplay, nil, true)
    self:SetNineSlice(AuctionHouseFrameAuctionsFrame.CommoditiesList, nil, true)

    --时光
    self:SetScrollBar(AuctionHouseFrame.WoWTokenResults.DummyScrollBar)
    self:SetNineSlice(AuctionHouseFrame.WoWTokenResults, nil, true)
    --购买
    self:SetNineSlice(AuctionHouseFrame.ItemBuyFrame.ItemDisplay, nil, true)
    self:SetScrollBar(AuctionHouseFrame.ItemBuyFrame.ItemList)
    self:SetNineSlice(AuctionHouseFrame.ItemBuyFrame.ItemList, nil, true)
end














--专业定制
function WoWTools_TextureMixin.Events:Blizzard_ProfessionsCustomerOrders()
    self:SetNineSlice(ProfessionsCustomerOrdersFrame, true)

    self:SetEditBox(ProfessionsCustomerOrdersFrame.BrowseOrders.SearchBar.SearchBox)

    self:SetAlphaColor(ProfessionsCustomerOrdersFrameMiddleMiddle)
    self:SetAlphaColor(ProfessionsCustomerOrdersFrameMiddleLeft)
    self:SetAlphaColor(ProfessionsCustomerOrdersFrameMiddleRight)
    self:SetAlphaColor(ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList.Background)

    --self:SetAlphaColor(ProfessionsCustomerOrdersFrame.Form.LeftPanelBackground.Background)
    --self:SetAlphaColor(ProfessionsCustomerOrdersFrame.Form.RightPanelBackground.Background)

    self:HideTexture(ProfessionsCustomerOrdersFrame.MoneyFrameInset.Bg)
    self:SetAlphaColor(ProfessionsCustomerOrdersFrameLeft)
    self:SetAlphaColor(ProfessionsCustomerOrdersFrameMiddle)
    self:SetAlphaColor(ProfessionsCustomerOrdersFrameRight)

    self:SetNineSlice(ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList, nil, true)
    self:SetNineSlice(ProfessionsCustomerOrdersFrame.BrowseOrders.RecipeList, nil, true)
    self:SetScrollBar(ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList)
    self:SetScrollBar(ProfessionsCustomerOrdersFrame.BrowseOrders.RecipeList)
    self:SetFrame(ProfessionsCustomerOrdersFrameBrowseTab, {alpha=1})
    self:SetFrame(ProfessionsCustomerOrdersFrameOrdersTab, {alpha=1})

    self:SetFrame(ProfessionsCustomerOrdersFrame.MoneyFrameBorder)
    self:SetNineSlice(ProfessionsCustomerOrdersFrame.MoneyFrameInset)
    self:SetAlphaColor(ProfessionsCustomerOrdersFrameLeft)
    self:SetAlphaColor(ProfessionsCustomerOrdersFrameRight)
    self:SetAlphaColor(ProfessionsCustomerOrdersFrameMiddle)

    self:SetNineSlice(ProfessionsCustomerOrdersFrame.MyOrdersPage.OrderList, nil, true)
    self:SetScrollBar(ProfessionsCustomerOrdersFrame.MyOrdersPage.OrderList)

    self:SetNineSlice(ProfessionsCustomerOrdersFrame.Form.CurrentListings, true)
    self:SetScrollBar(ProfessionsCustomerOrdersFrame.Form.CurrentListings.OrderList)
    self:HideTexture(ProfessionsCustomerOrdersFrameBg)

    self:SetNineSlice(ProfessionsCustomerOrdersFrame.Form.LeftPanelBackground, true)
    self:SetNineSlice(ProfessionsCustomerOrdersFrame.Form.RightPanelBackground, true)
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
    self:SetNineSlice(CalendarCreateEventDescriptionContainer, nil, nil, true)
    self:SetNineSlice(CalendarCreateEventInviteList, nil, nil, true)
    self:SetAlphaColor(CalendarCreateEventDivider, true)
    self:SetEditBox(CalendarCreateEventInviteEdit)
    self:SetAlphaColor(CalendarCreateEventFrameButtonBackground, true)
    self:SetAlphaColor(CalendarCreateEventCreateButtonBorder, true)
    self:SetFrame(CalendarCreateEventFrame.Header, {notAlpha=true})

    self:SetFrame(CalendarViewHolidayFrame.Header, {notAlpha=true})
    self:SetFrame(CalendarViewHolidayFrame.Border, {notAlpha=true})

    self:SetAlphaColor(CalendarMonthBackground)
    self:SetAlphaColor(CalendarYearBackground)
end







--飞行地图
function WoWTools_TextureMixin.Events:Blizzard_FlightMap()
    self:SetNineSlice(FlightMapFrame.BorderFrame, true)
    self:HideTexture(FlightMapFrame.ScrollContainer.Child.TiledBackground)
    self:HideTexture(FlightMapFrameBg)
end







--镶嵌宝石，界面
function WoWTools_TextureMixin.Events:Blizzard_ItemSocketingUI()
    self:SetNineSlice(ItemSocketingFrame, true)
    self:SetNineSlice(ItemSocketingFrameInset, nil, true)
    self:SetAlphaColor(ItemSocketingFrameBg)

    ItemSocketingFrameInset.Bg:ClearAllPoints()
    ItemSocketingFrameInset.Bg:SetAllPoints(ItemSocketingScrollFrame)
    self:HideTexture(ItemSocketingFrame['SocketFrame-Right'])
    self:HideTexture(ItemSocketingFrame['SocketFrame-Left'])
    self:HideTexture(ItemSocketingFrame['ParchmentFrame-Top'])
    self:HideTexture(ItemSocketingFrame['ParchmentFrame-Bottom'])
    self:HideTexture(ItemSocketingFrame['ParchmentFrame-Right'])
    self:HideTexture(ItemSocketingFrame['ParchmentFrame-Left'])
    self:SetAlphaColor(ItemSocketingFrame['GoldBorder-Top'])
    self:SetAlphaColor(ItemSocketingFrame['GoldBorder-Bottom'])
    self:SetAlphaColor(ItemSocketingFrame['GoldBorder-Right'])
    self:SetAlphaColor(ItemSocketingFrame['GoldBorder-Left'])
    self:SetAlphaColor(ItemSocketingFrame['GoldBorder-BottomLeft'])
    self:SetAlphaColor(ItemSocketingFrame['GoldBorder-TopLeft'])
    self:SetAlphaColor(ItemSocketingFrame['GoldBorder-BottomRight'])
    self:SetAlphaColor(ItemSocketingFrame['GoldBorder-TopRight'])
    self:SetAlphaColor(_G['ItemSocketingScrollFrameMiddle'])
    self:SetAlphaColor(_G['ItemSocketingScrollFrameTop'])
    self:SetAlphaColor(_G['ItemSocketingScrollFrameBottom'])
    self:SetScrollBar(ItemSocketingScrollFrame)

    self:HideTexture(ItemSocketingFrame.TopLeftNub)
    self:HideTexture(ItemSocketingFrame.TopRightNub)
    self:HideTexture(ItemSocketingFrame.MiddleLeftNub)
    self:HideTexture(ItemSocketingFrame.MiddleRightNub)
    self:HideTexture(ItemSocketingFrame.BottomLeftNub)
    self:HideTexture(ItemSocketingFrame.BottomRightNub)
end














function WoWTools_TextureMixin.Events:Blizzard_WeeklyRewards()--周奖励提示
    self:SetAlphaColor(WeeklyRewardsFrame.BackgroundTile)
    self:SetEditBox(WeeklyRewardsFrame.HeaderFrame)
    self:SetAlphaColor(WeeklyRewardsFrame.RaidFrame.Background)
    self:SetAlphaColor(WeeklyRewardsFrame.MythicFrame.Background)
    self:SetAlphaColor(WeeklyRewardsFrame.PVPFrame.Background)
    hooksecurefunc(WeeklyRewardsFrame,'UpdateSelection', function(frame)
        for _, frame in ipairs(frame.Activities) do
            self:SetAlphaColor(frame.Background)
        end
    end)
end






function WoWTools_TextureMixin.Events:Blizzard_ItemInteractionUI()--套装, 转换
    self:SetNineSlice(ItemInteractionFrame, true)
    self:SetAlphaColor(ItemInteractionFrameBg)
    self:SetAlphaColor(ItemInteractionFrame.Inset.Bg)
    self:SetAlphaColor(ItemInteractionFrameMiddle)

    self:SetAlphaColor(ItemInteractionFrameRight)
    self:SetAlphaColor(ItemInteractionFrameLeft)

    self:HideTexture(ItemInteractionFrame.ButtonFrame.BlackBorder)
end










--装备升级,界面 
function WoWTools_TextureMixin.Events:Blizzard_ItemUpgradeUI()
    self:SetNineSlice(ItemUpgradeFrame, true)
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
function WoWTools_TextureMixin.Events:Blizzard_GarrisonUI()
    self:SetNineSlice(GarrisonCapacitiveDisplayFrame, true)
    if GarrisonCapacitiveDisplayFrame then--要塞订单
        self:SetAlphaColor(GarrisonCapacitiveDisplayFrameBg)
        self:HideTexture(GarrisonCapacitiveDisplayFrame.TopTileStreaks)
        self:HideTexture(GarrisonCapacitiveDisplayFrameInset.Bg)
    end

    self:SetFrame(GarrisonLandingPage, {alpha= 0.3})
    self:SetFrame(GarrisonLandingPage.Report, {alpha= 0.3})
    if GarrisonLandingPageFollowerList then
        self:HideTexture(GarrisonLandingPageFollowerList.FollowerScrollFrame)
        self:SetScrollBar(GarrisonLandingPageReportList)
    end
end






--欲龙术
function WoWTools_TextureMixin.Events:Blizzard_GenericTraitUI()
    self:SetAlphaColor(GenericTraitFrame.Background)
    self:SetNineSlice(GenericTraitFrame, true)
end







--任务选择
function WoWTools_TextureMixin.Events:Blizzard_PlayerChoice()
    hooksecurefunc(PlayerChoiceFrame, 'SetupFrame', function(frame)
        if frame.Background then
            self:SetAlphaColor(frame.Background.BackgroundTile, nil, nil, 0)
            self:SetAlphaColor(frame.Background, nil, nil, 0)
        end

        self:SetNineSlice(frame)
        self:SetAlphaColor(frame.Header)
        self:SetEditBox(frame.Title)
    end)
end















--专业, 初始化, 透明
function WoWTools_TextureMixin.Events:Blizzard_Professions()
    self:SetNineSlice(ProfessionsFrame, true)
    self:SetAlphaColor(ProfessionsFrameBg)
    self:SetAlphaColor(ProfessionsFrame.CraftingPage.SchematicForm.Background, nil, nil, 0.3)
    self:SetAlphaColor(ProfessionsFrame.CraftingPage.RankBar.Background, nil, nil, 0.3)

    self:SetAlphaColor(ProfessionsFrame.CraftingPage.SchematicForm.Details.BackgroundTop)
    self:SetAlphaColor(ProfessionsFrame.CraftingPage.SchematicForm.Details.BackgroundMiddle)
    self:SetAlphaColor(ProfessionsFrame.CraftingPage.SchematicForm.Details.BackgroundBottom)

    self:HideTexture(ProfessionsFrame.SpecPage.TreeView.Background)
    self:HideTexture(ProfessionsFrame.SpecPage.DetailedView.Background)
    self:SetAlphaColor(ProfessionsFrame.SpecPage.DetailedView.Path.DialBG)
    self:SetAlphaColor(ProfessionsFrame.SpecPage.DetailedView.UnspentPoints.CurrencyBackground)

    self:SetNineSlice(InspectRecipeFrame, true)
    self:SetAlphaColor(InspectRecipeFrameBg)
    self:SetAlphaColor(InspectRecipeFrame.SchematicForm.MinimalBackground)
    self:SetTabSystem(ProfessionsFrame)

    if ProfessionsFrame.SpecPage then
        hooksecurefunc(ProfessionsFrame.SpecPage, 'UpdateTabs', function(frame)
            for tab, bool in frame.tabsPool:EnumerateActive() do
                if bool then
                    self:SetFrame(tab, {alpha=0.3})
                end
            end
        end)
        self:SetAlphaColor(ProfessionsFrame.SpecPage.PanelFooter)

        self:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList.Background, nil, nil, 0.3)
        self:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.OrderList.Background, nil,nil, 0.3)
    end

    self:SetAlphaColor(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.Background, nil, nil, 0.3)
    self:SetAlphaColor(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.Background, nil, nil, 0.3)
    self:SetNineSlice(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.NineSlice, true)
    self:SetNineSlice(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.NineSlice, true)

    self:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.PublicOrdersButton.Middle, nil, nil, 0.3)
    self:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.PublicOrdersButton.Right, nil, nil, 0.3)
    self:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.PublicOrdersButton.Left, nil, nil, 0.3)
    self:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.PersonalOrdersButton.Middle, nil, nil, 0.3)
    self:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.PersonalOrdersButton.Right, nil, nil, 0.3)
    self:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.PersonalOrdersButton.Left, nil, nil, 0.3)

    self:SetNineSlice(ProfessionsFrame.CraftingPage.CraftingOutputLog, true)
    self:SetScrollBar(ProfessionsFrame.CraftingPage.CraftingOutputLog)
    self:SetScrollBar(ProfessionsFrame.CraftingPage.RecipeList)

    self:SetNineSlice(ProfessionsFrame.CraftingPage.SchematicForm, true)
    self:SetAlphaColor(ProfessionsFrame.CraftingPage.SchematicForm.MinimalBackground, nil, nil, 0)

    self:SetScrollBar(ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList)
    self:SetScrollBar(ProfessionsFrame.OrdersPage.BrowseFrame.OrderList)
end








--点击，施法
function WoWTools_TextureMixin.Events:Blizzard_ClickBindingUI()
    self:SetNineSlice(ClickBindingFrame, true)
    self:SetScrollBar(ClickBindingFrame)
    self:SetAlphaColor(ClickBindingFrameBg)
    ClickBindingFrame.ScrollBoxBackground:Hide()
    --self:SetNineSlice(ClickBindingFrame.ScrollBoxBackground, nil, true)

    self:SetNineSlice(ClickBindingFrame.TutorialFrame, true)
end









function WoWTools_TextureMixin.Events:Blizzard_ArchaeologyUI()
    self:SetNineSlice(ArchaeologyFrame, true)
    self:SetNineSlice(ArchaeologyFrameInset, nil, true)
    self:HideTexture(ArchaeologyFrameBg)
    self:HideTexture(ArchaeologyFrameInset.Bg)
    self:HideTexture(ArchaeologyFrameRankBarBackground)
    self:SetAlphaColor(ArchaeologyFrameRaceFilterMiddle, nil, nil, 0.3)
    self:SetAlphaColor(ArchaeologyFrameRaceFilterLeft, nil, nil, 0.3)
    self:SetAlphaColor(ArchaeologyFrameRaceFilterRight, nil, nil, 0.3)
end








--分解 ScrappingMachineFrame
function WoWTools_TextureMixin.Events:Blizzard_ScrappingMachineUI()
    self:SetNineSlice(ScrappingMachineFrame, true)
    self:SetAlphaColor(ScrappingMachineFrameBg, nil, nil, 0.3)
    self:HideTexture(ScrappingMachineFrame.Background)
    self:HideTexture(ScrappingMachineFrameInset.Bg)
    self:SetNineSlice(ScrappingMachineFrameInset, true)
end












function WoWTools_TextureMixin.Events:Blizzard_DelvesCompanionConfiguration()
    self:SetButton(DelvesCompanionConfigurationFrame.CloseButton, {all=true})
    self:SetNineSlice(DelvesCompanionAbilityListFrame, true)
    self:SetAlphaColor(DelvesCompanionAbilityListFrameBg)
    self:HideTexture(DelvesCompanionAbilityListFrame.CompanionAbilityListBackground)

    self:SetAlphaColor(DelvesCompanionConfigurationFrame.Background, nil, nil, 0.3)
    self:HideTexture(DelvesCompanionConfigurationFrame.Bg)
    self:SetFrame(DelvesCompanionConfigurationFrame.Border)
    self:SetMenu(DelvesCompanionAbilityListFrame.DelvesCompanionRoleDropdown)
end






function WoWTools_TextureMixin.Events:Blizzard_CovenantRenown()
    self:HideTexture(CovenantRenownFrame.Background)
end





function WoWTools_TextureMixin.Events:Blizzard_Settings()
    self:SetButton(SettingsPanel.ClosePanelButton, {all=true})
    self:SetFrame(SettingsPanel.NineSlice, {alpha=0.5})
    self:SetAlphaColor(SettingsPanel.Bg, nil, nil, 0.5)
    self:SetScrollBar(SettingsPanel.Container.SettingsList)
    self:SetScrollBar(SettingsPanel.CategoryList)

    self:SetNineSlice(PingSystemTutorial, true)
    self:SetNineSlice(PingSystemTutorialInset, nil, true)

    self:HideTexture(PingSystemTutorialBg)

    self:SetFrame(SettingsPanel.GameTab, {notAlpha=true})
    self:SetFrame(SettingsPanel.AddOnsTab, {notAlpha=true})
    self:SetEditBox(SettingsPanel.SearchBox)
    self:SetFrame(SettingsPanel, {index=1})
end





function WoWTools_TextureMixin.Events:Blizzard_CooldownViewer()
    hooksecurefunc(CooldownViewerBuffBarItemMixin, 'SetBarContent', function(frame)
        if not frame.Bar.isSetTexture then
            self:SetFrame(frame.Bar, {alpha=0.2, index=1})--frame:GetBarFrame()
            frame.Bar.isSetTexture=true
        end
    end)
end


function WoWTools_TextureMixin.Events:Blizzard_ExpansionLandingPage()
    local function SetOverlayFrame(frame)
        self:SetScrollBar(frame.MajorFactionList)
        self:SetAlphaColor(frame.Background, nil, nil,true)
        self:HideTexture(frame.ScrollFadeOverlay)
    end

    hooksecurefunc(ExpansionLandingPage, 'RefreshExpansionOverlay', function(frame)
        frame= frame.overlayFrame
        if not frame or not frame:IsShown() then
            return
        end
        SetOverlayFrame(frame)
    end)

    hooksecurefunc(DragonflightLandingOverlayMixin, 'RefreshOverlay', function(frame)
        SetOverlayFrame(frame)
    end)

    hooksecurefunc(WarWithinLandingOverlayMixin, 'RefreshOverlay', function(frame)
        SetOverlayFrame(frame)
    end)

end



--派系声望
function WoWTools_TextureMixin.Events:Blizzard_MajorFactions()
    self:SetAlphaColor(MajorFactionRenownFrame.Background)
    self:SetAlphaColor(MajorFactionRenownFrame.NineSlice, nil, nil, true)

--解锁
    hooksecurefunc(MajorFactionButtonUnlockedStateMixin, 'Refresh', function(frame)--Blizzard_MajorFactionsLandingTemplates.lua
        self:SetAlphaColor(frame.Background, nil, nil, 0.75)
    end)
--没解锁
    hooksecurefunc(MajorFactionButtonLockedStateMixin, 'Refresh', function(frame)
        self:SetAlphaColor(frame.Background, nil, nil, 0.75)
    end)
end



function WoWTools_TextureMixin.Events:Blizzard_PerksProgram()
    self:SetScrollBar(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer)
    self:SetScrollBar(PerksProgramFrame.ProductsFrame.PerksProgramShoppingCartFrame.ItemList)
end

function WoWTools_TextureMixin.Events:Blizzard_Menu()
    hooksecurefunc(MenuProxyMixin, 'OnLoad', function(menu)
        self:SetScrollBar(menu)
    end)
    hooksecurefunc(MenuStyle1Mixin, 'Generate', function(frame)
        local icon= frame:GetRegions()
        if icon:GetObjectType()=="Texture" then
           icon:SetVertexColor(0, 0, 0, 0.925)
        end
    end)
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
end








--世界地图
function WoWTools_TextureMixin.Events:Blizzard_WorldMap()
    self:SetButton(WorldMapFrameCloseButton, {all=true})
    self:SetButton(WorldMapFrame.BorderFrame.MaximizeMinimizeFrame.MaximizeButton, {all=true})
    self:SetButton(WorldMapFrame.BorderFrame.MaximizeMinimizeFrame.MinimizeButton, {all=true})
    self:SetFrame(WorldMapFrame.BorderFrame.Tutorial, {alpha=0.3})

    self:SetNineSlice(WorldMapFrame.BorderFrame, true)
    self:SetAlphaColor(WorldMapFrameBg)
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

    self:SetFrame(QuestMapFrame.MapLegend.BorderFrame, {alpha=0})
    self:SetFrame(QuestMapFrame.QuestsFrame.DetailsFrame.BorderFrame, {alpha=0})
    self:HideTexture(QuestMapFrame.MapLegendTab.Background)
    self:HideTexture(QuestMapFrame.QuestsTab.Background)
    self:HideTexture(QuestMapFrame.QuestsTab.SelectedTexture)

    self:SetFrame(QuestScrollFrame.BorderFrame, {alpha=0})
    self:SetScrollBar(QuestScrollFrame)
    self:SetAlphaColor(QuestScrollFrame.Background, nil, nil, 0.5)

    self:SetAlphaColor(QuestScrollFrame.SettingsDropdown.Icon, nil, nil, 0.9)
    self:SetEditBox(QuestScrollFrame.SearchBox)

    self:SetScrollBar(MapLegendScrollFrame)
    self:SetAlphaColor(MapLegendScrollFrame.Background, nil, nil, 0.3)

--任务，列表 QuestLogHeaderCodeTemplate
    hooksecurefunc(QuestLogHeaderCodeMixin, 'OnLoad', function(btn)
        self:SetFrame(btn, {index=2, isMinAlpha=true})
    end)

    for _, frame in ipairs(WorldMapFrame.overlayFrames or {}) do
        self:SetFrame(frame, {alpha=0.5})
    end
    self:SetButton(WorldMapFrame.SidePanelToggle.CloseButton, {all=true, alpha=0.5})
    self:SetButton(WorldMapFrame.SidePanelToggle.OpenButton, {all=true, alpha=0.5})



    self:SetFrame(WorldMapFrame.NavBar.overlay, {alpha=0})
    self:Init_BGMenu_Frame(
        WorldMapFrame,
        'WorldMapFrame',
        nil,
        {
        PortraitContainer=WorldMapFrame.BorderFrame.PortraitContainer
    }
    )
end






function WoWTools_TextureMixin.Events:Blizzard_GameMenu()
    self:HideTexture(GameMenuFrame.Header.RightBG)
    self:HideTexture(GameMenuFrame.Header.CenterBG)
    self:HideTexture(GameMenuFrame.Header.LeftBG)
    GameMenuFrame.Header.Text:ClearAllPoints()
    GameMenuFrame.Header.Text:SetPoint('TOP', 0 ,-24)
    self:SetFrame(GameMenuFrame.Border, {alpha= 0.3})
end







--好友列表
function WoWTools_TextureMixin.Events:Blizzard_FriendsFrame()

    self:SetNineSlice(FriendsFrame, true)
    self:SetAlphaColor(FriendsFrameBg)
    self:SetNineSlice(FriendsFrameInset, true)
    self:SetAlphaColor(FriendsFrameInset.Bg, nil, nil, 0.3)
    self:SetScrollBar(FriendsListFrame)
    self:SetScrollBar(IgnoreListFrame)

    self:SetFrame(FriendsFrameBattlenetFrame.BroadcastButton, {notAlpha=true})
    self:SetButton(FriendsFrameCloseButton, {all=true})

    --好友列表，召募
    self:SetScrollBar(RecruitAFriendFrame.RecruitList)
    self:SetAlphaColor(RecruitAFriendFrame.RecruitList.ScrollFrameInset.Bg)
    self:SetNineSlice(RecruitAFriendFrame.RewardClaiming.Inset)
    self:SetNineSlice(RecruitAFriendFrame.RecruitList.ScrollFrameInset)
    self:HideTexture(RecruitAFriendFrame.RecruitList.Header.Background)
    self:SetAlphaColor(RecruitAFriendFrame.RewardClaiming.Inset.Bg)

    --团队信息
    self:HideTexture(RaidInfoDetailHeader)
    self:SetAlphaColor(RaidInfoFrame.Header.LeftBG)
    self:SetAlphaColor(RaidInfoFrame.Header.CenterBG)
    self:SetAlphaColor(RaidInfoFrame.Header.RightBG)
    self:SetAlphaColor(RaidInfoDetailFooter)
    self:SetAlphaColor(RaidInfoFrame.Border.LeftEdge, nil, nil, 0.3)
    self:SetAlphaColor(RaidInfoFrame.Border.RightEdge, nil, nil, 0.3)
    self:SetAlphaColor(RaidInfoFrame.Border.TopEdge, nil, nil, 0.3)
    self:SetAlphaColor(RaidInfoFrame.Border.BottomEdge, nil, nil, 0.3)
    self:SetAlphaColor(RaidInfoFrame.Border.TopLeftCorner, nil, nil, 0.3)
    self:SetAlphaColor(RaidInfoFrame.Border.BottomLeftCorner, nil, nil, 0.3)
    self:SetAlphaColor(RaidInfoFrame.Border.BottomRightCorner, nil, nil, 0.3)
    self:SetAlphaColor(RaidInfoFrame.Border.TopRightCorner, nil, nil, 0.3)
    self:SetScrollBar(RaidInfoFrame)
    self:SetAlphaColor(RaidInfoFrame.Border.Bg, nil, nil, 0.3)

    self:SetNineSlice(WhoFrameListInset, true)
    self:SetNineSlice(WhoFrameEditBoxInset, true)
    self:HideTexture(WhoFrameListInset.Bg)
    self:SetScrollBar(WhoFrame)
    self:SetMenu(WhoFrameDropdown)
    self:SetMenu(FriendsFrameStatusDropdown, {alpha=1})

    self:HideTexture(WhoFrameEditBoxInset.Bg)
    self:SetScrollBar(QuickJoinFrame)

    for i=1, 4 do
        self:SetFrame(_G['FriendsFrameTab'..i], {notAlpha=true})
        self:SetFrame(_G['FriendsTabHeaderTab'..i], {notAlpha=true})
        self:SetFrame(_G['WhoFrameColumnHeader'..i], {notAlpha=true})
    end

    self:SetFrame(BattleTagInviteFrame.Border, {notAlpha=true})
end








--聊天设置
function WoWTools_TextureMixin.Events:Blizzard_Channels()
    self:SetAlphaColor(ChannelFrameBg)

    self:HideTexture(ChannelFrameInset.Bg)
    self:HideTexture(ChannelFrame.RightInset.Bg)
    self:HideTexture(ChannelFrame.LeftInset.Bg)

    self:SetScrollBar(ChannelFrame.ChannelRoster)
    self:SetScrollBar(ChannelFrame.ChannelList)

    self:SetNineSlice(ChannelFrame)
    self:SetNineSlice(ChannelFrameInset)
    self:SetNineSlice(ChannelFrame.RightInset)
    self:SetNineSlice(ChannelFrame.LeftInset)
end







--插件，管理
function WoWTools_TextureMixin.Events:Blizzard_AddOnList()
    self:SetNineSlice(AddonList,true)
    self:SetScrollBar(AddonList)
    self:SetAlphaColor(AddonListBg)
    self:SetNineSlice(AddonListInset, true)
    self:SetAlphaColor(AddonListInset.Bg, nil, nil, 0.3)
    self:SetMenu(AddonList.Dropdown)
    self:SetEditBox(AddonList.SearchBox)
    self:SetButton(AddonListCloseButton, {all=true})

     if MainStatusTrackingBarContainer then--货币，XP，追踪，最下面BAR
         self:HideTexture(MainStatusTrackingBarContainer.BarFrameTexture)
     end
end

















--编辑模式
function WoWTools_TextureMixin.Events:Blizzard_EditMode()
        self:SetButton(EditModeManagerFrame.CloseButton, {all=true})
    self:SetScrollBar(EditModeManagerFrame.AccountSettings.SettingsContainer)
    self:SetFrame(EditModeManagerFrame.Border, {alpha=0.3})
    self:SetFrame(EditModeManagerFrame.AccountSettings.SettingsContainer.BorderArt, {alpha=0.3})
    self:SetSlider(EditModeManagerFrame.GridSpacingSlider)
end








--隐藏, 团队, 材质 Blizzard_CompactRaidFrameManager.lua
function WoWTools_TextureMixin.Events:Blizzard_CompactRaidFrames()
    self:SetAlphaColor(_G['CompactRaidFrameManagerBG-regulars'], nil, nil, 0)
    self:SetAlphaColor(_G['CompactRaidFrameManagerBG-party-leads'], nil, nil, 0)
    self:SetAlphaColor(_G['CompactRaidFrameManagerBG-leads'], nil, nil, 0)
    self:SetAlphaColor(_G['CompactRaidFrameManagerBG-party-regulars'], nil,nil,0)

    CompactRaidFrameManagerToggleButtonForward:SetAlpha(0.3)
    CompactRaidFrameManagerToggleButtonBack:SetAlpha(0.3)
    self:SetMenu(CompactRaidFrameManagerDisplayFrameRestrictPingsDropdown)
    self:SetMenu(CompactRaidFrameManagerDisplayFrameModeControlDropdown, {alpha=1})
    self:HideTexture(_G['CompactRaidFrameManagerBG-assists'])
end








function WoWTools_TextureMixin.Events:Blizzard_ReportFrame()
    self:SetFrame(ReportFrame)
    self:SetFrame(ReportFrame.Border)
    self:HideTexture(ReportFrame.BottomInset)
    self:HideTexture(ReportFrame.TopInset)
    self:SetFrame(ReportFrame.CloseButton, {notAlpha=true})

    self:SetScrollBar(ReportFrame.Comment)
end


function WoWTools_TextureMixin.Events:Blizzard_BNet()
    self:SetFrame(BNToastFrame, {alpha=0.3})
end



function WoWTools_TextureMixin.Events:Blizzard_UnitFrame()
    for i=1, MAX_BOSS_FRAMES do
        local frame= _G['Boss'..i..'TargetFrame']
        if frame then
            self:HideTexture(frame.TargetFrameContainer.FrameTexture)
        end
    end


    hooksecurefunc('PlayerFrame_UpdateArt', function()--隐藏材质, 载具
        if OverrideActionBarEndCapL then
            self:HideTexture(OverrideActionBarEndCapL)
            self:HideTexture(OverrideActionBarEndCapR)
            self:HideTexture(OverrideActionBarBorder)
            self:HideTexture(OverrideActionBarBG)
            self:HideTexture(OverrideActionBarButtonBGMid)
            self:HideTexture(OverrideActionBarButtonBGR)
            self:HideTexture(OverrideActionBarButtonBGL)
        end
        if OverrideActionBarMicroBGMid then
            self:HideTexture(OverrideActionBarMicroBGMid)
            self:HideTexture(OverrideActionBarMicroBGR)
            self:HideTexture(OverrideActionBarMicroBGL)
            self:HideTexture(OverrideActionBarLeaveFrameExitBG)

            self:HideTexture(OverrideActionBarDivider2)
            self:HideTexture(OverrideActionBarLeaveFrameDivider3)
        end
        if OverrideActionBarExpBar then
            self:HideTexture(OverrideActionBarExpBarXpMid)
            self:HideTexture(OverrideActionBarExpBarXpR)
            self:HideTexture(OverrideActionBarExpBarXpL)
            for i=1, 19 do
                self:SetAlphaColor(_G['OverrideActionBarXpDiv'..i], nil, nil, 0.3)
            end
        end
    end)

    self:HideTexture(MultiBarBottomLeftButton10.SlotBackground)

    self:HideTexture(PlayerFrameAlternateManaBarBorder)
    self:HideTexture(PlayerFrameAlternateManaBarLeftBorder)
    self:HideTexture(PlayerFrameAlternateManaBarRightBorder)

    if ExtraActionButton1 then self:HideTexture(ExtraActionButton1.style) end--额外技能
    if ZoneAbilityFrame then self:HideTexture(ZoneAbilityFrame.Style) end--区域技能

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
end




--小地图
function WoWTools_TextureMixin.Events:Blizzard_Minimap()
    self:SetAlphaColor(MinimapCompassTexture)
    self:SetButton(GameTimeFrame)

    if MinimapCluster and MinimapCluster.TrackingFrame then
       self:SetButton(MinimapCluster.TrackingFrame.Button, {alpha= 0.3, all=false})
       self:SetFrame(MinimapCluster.BorderTop)
    end

    if WoWToolsSave['Minimap_Plus'] and WoWToolsSave['Minimap_Plus'].Icons.disabled then
        WoWTools_MinimapMixin:Init_SetMinamp_Texture()
    end

--插件，菜单
    self:HideFrame(AddonCompartmentFrame, {alpha= 0.3})
    self:SetAlphaColor(AddonCompartmentFrame.Text, nil, nil, 0.3)
end


--任务，追踪柆
function WoWTools_TextureMixin.Events:Blizzard_ObjectiveTracker()
    self:SetAlphaColor(ScenarioObjectiveTracker.StageBlock.NormalBG, nil, nil, 0.3)

end

--对话框
function WoWTools_TextureMixin.Events:Blizzard_StaticPopup_Frame()
    self:SetFrame(StaticPopup1.Border, {notAlpha=true})
    self:SetAlphaColor(StaticPopup1.Border.Bg, true)
end























--PVEFrame
function WoWTools_TextureMixin.Events:Blizzard_GroupFinder()
    self:SetTabButton(PVEFrameTab1)
    self:SetTabButton(PVEFrameTab2)
    self:SetTabButton(PVEFrameTab3)
    self:SetTabButton(PVEFrameTab4)

    --地下城和团队副本
    self:SetButton(PVEFrameCloseButton, {all=true})
    self:HideTexture(PVEFrame.TopTileStreaks)--最上面
    self:SetNineSlice(PVEFrame, true)
    self:SetEditBox(LFGListFrame.SearchPanel.SearchBox)
    self:SetScrollBar(LFGListFrame.SearchPanel)
    self:SetNineSlice(LFGListFrame.SearchPanel.ResultsInset, nil, true)

    self:SetFrame(LFGListFrame.CategorySelection.Inset, {alpha= 0.3})
    self:SetNineSlice(LFGListFrame.CategorySelection.Inset, nil, true)
    self:HideTexture(LFGListFrame.CategorySelection.Inset.Bg)
    self:HideTexture(LFGListFrame.CategorySelection.Inset.CustomBG)

    self:SetFrame(LFGDungeonReadyDialog.Border, {alpha= 0.3})
    self:SetFrame(LFDRoleCheckPopup.Border, {alpha= 0.3})
    self:SetFrame(LFGDungeonReadyStatus.Border, {alpha= 0.3})

    self:SetScrollBar(LFDQueueFrameSpecific)


    self:SetNineSlice(LFGListFrame.EntryCreation.Inset, nil, true)
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
    self:HideTexture(PVEFrameLLVert)
    self:HideTexture(PVEFrameRLVert)
    self:HideTexture(PVEFrameBLCorner)
    self:HideTexture(PVEFrameBottomLine)
    self:HideTexture(PVEFrameBRCorner)
    self:HideTexture(PVEFrameTLCorner)
    self:HideTexture(PVEFrameTopLine)
    self:HideTexture(PVEFrameTRCorner)


    self:SetAlphaColor(PVEFrameBg)--左边


    self:HideTexture(PVEFrameBlueBg)
    self:HideTexture(PVEFrameLeftInset.Bg)
    self:SetNineSlice(PVEFrameLeftInset, nil, true)
    self:HideFrame(PVEFrame.shadows)

    self:SetAlphaColor(LFDQueueFrameBackground)
    self:SetMenu(LFDQueueFrameTypeDropdown)
    self:SetMenu(LFGListFrame.SearchPanel.FilterButton)

    self:SetNineSlice(LFDParentFrameInset, nil, true)
    self:HideTexture(LFDParentFrameInset.Bg)
    self:SetNineSlice(RaidFinderFrameBottomInset, nil, true)
    self:SetAlphaColor(RaidFinderFrameBottomInset.Bg)

    self:SetAlphaColor(LFDParentFrameRoleBackground)

    self:HideTexture(LFDParentFrameRoleBackground)
    self:SetNineSlice(RaidFinderFrameRoleInset, nil, true)
    self:HideTexture(RaidFinderFrameRoleInset.Bg)
end





--地下城和团队副本, PVP
function WoWTools_TextureMixin.Events:Blizzard_PVPUI()
    self:HideTexture(HonorFrame.Inset.Bg)

    self:SetNineSlice(HonorFrame.Inset, nil, true)
    HonorFrame.BonusFrame.WorldBattlesTexture:SetAlpha(0)
    HonorFrame.BonusFrame.ShadowOverlay:SetAlpha(0)

    self:HideTexture(HonorFrame.ConquestBar.Background)
    self:SetNineSlice(PVPQueueFrame.HonorInset, nil, true)--最右边

    self:SetNineSlice(ConquestFrame.Inset, nil, true)--中间
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

end



--挑战, 钥匙插入， 界面
function WoWTools_TextureMixin.Events:Blizzard_ChallengesUI()
    self:SetButton(ChallengesKeystoneFrame.CloseButton, {all=true})
    self:SetAlphaColor(ChallengesFrameInset.Bg)

    self:SetNineSlice(ChallengesFrameInset)
    self:SetFrame(ChallengesKeystoneFrame, {index=1})
    self:HideTexture(ChallengesKeystoneFrame.InstructionBackground)

    hooksecurefunc(ChallengesKeystoneFrame, 'Reset', function(frame)--钥匙插入， 界面
        self:SetFrame(frame, {index=1})
        self:HideTexture(frame.InstructionBackground)
    end)
end






--地下堡
function WoWTools_TextureMixin.Events:Blizzard_DelvesDashboardUI()
    self:SetAlphaColor(DelvesDashboardFrame.DashboardBackground, nil, nil, 0.3)
end
