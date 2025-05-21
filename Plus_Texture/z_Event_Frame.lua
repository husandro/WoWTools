local function Save()
    return WoWToolsSave['Plus_Texture'] or {}
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
    self:SetButton(AchievementFrameCloseButton, {all=true})
    self:HideFrame(AchievementFrame.Header)
    self:HideFrame(AchievementFrameSummary)
    self:SetNineSlice(AchievementFrameCategories, true)
    self:SetScrollBar(AchievementFrameCategories)

    self:SetScrollBar(AchievementFrameAchievements)
    self:HideFrame(AchievementFrameAchievements)

    self:SetScrollBar(AchievementFrameStats)
    self:SetEditBox(AchievementFrame.SearchBox)
    self:SetAlphaColor(AchievementFrameStatsBG, nil, nil, 0.3)
    self:SetFrame(AchievementFrameTab1, {alpha=0.3})
    self:SetFrame(AchievementFrameTab2, {alpha=0.3})
    self:SetFrame(AchievementFrameTab3, {alpha=0.3})
    self:HideTexture(AchievementFrameSummaryCategoriesStatusBarFillBar)

    self:HideTexture(AchievementFrameComparisonHeaderBG)

    for i=1, 10 do
        self:HideTexture(_G['AchievementFrameCategoriesCategory'..i..'Bar'])
        self:SetAlphaColor(_G['AchievementFrameSummaryCategoriesCategory'..i..'Right'])
        self:SetAlphaColor(_G['AchievementFrameSummaryCategoriesCategory'..i..'Middle'])
        self:SetAlphaColor(_G['AchievementFrameSummaryCategoriesCategory'..i..'Left'])
    end
    --比较
    AchievementFrameComparisonHeader:ClearAllPoints()
    AchievementFrameComparisonHeader:SetPoint('BOTTOMLEFT', AchievementFrameComparison, 'TOPRIGHT', -125, 0)
end










--地下城和团队副本, PVP
function WoWTools_TextureMixin.Events:Blizzard_PVPUI()
    self:HideTexture(HonorFrame.Inset.Bg)
    self:HideTexture(HonorFrame.BonusFrame.ShadowOverlay)
    self:HideTexture(HonorFrame.BonusFrame.WorldBattlesTexture)
    self:SetNineSlice(HonorFrame.Inset, nil, true)
    self:SetAlphaColor(HonorFrame.BonusFrame.WorldBattlesTexture)
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
    self:SetScrollBar(LFDQueueFrameSpecific)
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


    C_Timer.After(0.3, function()
        if EncounterJournalMonthlyActivitiesFrame then
            self:HideTexture(EncounterJournalMonthlyActivitiesFrame.Bg)
            self:HideTexture(EncounterJournalMonthlyActivitiesFrame.ShadowRight)
            self:SetScrollBar(EncounterJournalMonthlyActivitiesFrame)
            self:SetScrollBar(EncounterJournalMonthlyActivitiesFrame.FilterList)
        end
    end)
end










--[[公会银行
function WoWTools_TextureMixin.Events:Blizzard_GuildBankUI()
    if WoWToolsSave['Plus_GuildBank'].disabled then
        WoWTools_GuildBankMixin:Init_Guild_Texture()
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









--专业书
function WoWTools_TextureMixin.Events:Blizzard_ProfessionsBook()
    self:SetNineSlice(ProfessionsBookFrame, nil, nil, 0.3)
    self:SetNineSlice(ProfessionsBookFrameInset, nil, nil, 0.3)
    self:HideTexture(ProfessionsBookFrameBg)
    self:HideTexture(ProfessionsBookFrameInset.Bg)
    self:SetButton(ProfessionsBookFrameCloseButton, {all=true})
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





--玩家, 观察角色, 界面
function WoWTools_TextureMixin.Events:Blizzard_InspectUI()
    self:SetNineSlice(InspectFrame, true)
    self:SetAlphaColor(InspectFrameBg)
    self:HideTexture(InspectFrameInset.Bg)
    self:HideTexture(InspectPVPFrame.BG)
    self:HideTexture(InspectGuildFrameBG)
    self:SetFrame(InspectFrameTab1, {notAlpha=true})
    self:SetFrame(InspectFrameTab2, {notAlpha=true})
    self:SetFrame(InspectFrameTab3, {notAlpha=true})
    self:SetNineSlice(InspectFrame, true)
    self:SetNineSlice(InspectFrameInset, nil, true)
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









--地下堡
function WoWTools_TextureMixin.Events:Blizzard_DelvesDashboardUI()
    self:SetAlphaColor(DelvesDashboardFrame.DashboardBackground, nil, nil, 0.3)
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

