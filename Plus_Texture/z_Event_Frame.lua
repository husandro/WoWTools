
local Events={}



function Events:Blizzard_TrainerUI(mixin)
    mixin:SetFrame(ClassTrainerFrame, {alpha=0.3})
    mixin:SetScrollBar(ClassTrainerFrame)
    mixin:SetNineSlice(ClassTrainerFrame, true)

    mixin:HideTexture(ClassTrainerFrameInset.Bg)
    mixin:SetNineSlice(ClassTrainerFrameInset, true)

    mixin:HideTexture(ClassTrainerFrameBottomInset.Bg)
    mixin:SetNineSlice(ClassTrainerFrameBottomInset, true)
end





--小时图，时间
function Events:Blizzard_TimeManager(mixin)
    mixin:SetNineSlice(TimeManagerFrame, true)
    mixin:SetAlphaColor(TimeManagerFrameBg)
    mixin:HideTexture(TimeManagerFrameInset.Bg)
    mixin:SetSearchBox(TimeManagerAlarmMessageEditBox)
    WoWTools_ColorMixin:SetLabelTexture(TimeManagerClockTicker, {type='FontString', alpha=1})--设置颜色

    --秒表 Blizzard_TimeManager.lua
    mixin:HideTexture(StopwatchFrameBackgroundLeft)
    if StopwatchFrame then
        mixin:HideTexture(select(2, StopwatchFrame:GetRegions()))
        mixin:HideTexture(StopwatchTabFrameMiddle)
        mixin:HideTexture(StopwatchTabFrameRight)
        mixin:HideTexture(StopwatchTabFrameLeft)
    end
end




--天赋和法术书
function Events:Blizzard_PlayerSpells(mixin)
    mixin:SetAlphaColor(PlayerSpellsFrameBg, 0.3)
    mixin:SetNineSlice(PlayerSpellsFrame, 0.3)
    mixin:SetTabSystem(PlayerSpellsFrame)

    mixin:SetAlphaColor(PlayerSpellsFrame.SpecFrame.Background)--专精
    mixin:HideTexture(PlayerSpellsFrame.SpecFrame.BlackBG)

    mixin:SetAlphaColor(PlayerSpellsFrame.TalentsFrame.BottomBar, 0.3)--天赋
    mixin:HideTexture(PlayerSpellsFrame.TalentsFrame.BlackBG)

    mixin:SetSearchBox(PlayerSpellsFrame.TalentsFrame.SearchBox)

    mixin:SetAlphaColor(PlayerSpellsFrame.SpellBookFrame.TopBar)--法术书
    mixin:SetSearchBox(PlayerSpellsFrame.SpellBookFrame.SearchBox)
    mixin:SetTabSystem(PlayerSpellsFrame.SpellBookFrame)
end







function Events:Blizzard_AchievementUI(mixin)--成就
    mixin:HideFrame(AchievementFrame)
    mixin:HideFrame(AchievementFrame.Header)
    mixin:HideFrame(AchievementFrameSummary)
    mixin:SetNineSlice(AchievementFrameCategories, true)
    mixin:SetScrollBar(AchievementFrameCategories)

    mixin:SetScrollBar(AchievementFrameAchievements)
    mixin:HideFrame(AchievementFrameAchievements)

    mixin:SetScrollBar(AchievementFrameStats)
    mixin:SetSearchBox(AchievementFrame.SearchBox)
    mixin:SetAlphaColor(AchievementFrameStatsBG, nil, nil, 0.3)
    mixin:SetFrame(AchievementFrameTab1, {alpha=0.3})
    mixin:SetFrame(AchievementFrameTab2, {alpha=0.3})
    mixin:SetFrame(AchievementFrameTab3, {alpha=0.3})
    mixin:HideTexture(AchievementFrameSummaryCategoriesStatusBarFillBar)

    mixin:HideTexture(AchievementFrameComparisonHeaderBG)

    for i=1, 10 do
        mixin:HideTexture(_G['AchievementFrameCategoriesCategory'..i..'Bar'])
        mixin:SetAlphaColor(_G['AchievementFrameSummaryCategoriesCategory'..i..'Right'])
        mixin:SetAlphaColor(_G['AchievementFrameSummaryCategoriesCategory'..i..'Middle'])
        mixin:SetAlphaColor(_G['AchievementFrameSummaryCategoriesCategory'..i..'Left'])
    end
    --比较
    AchievementFrameComparisonHeader:ClearAllPoints()
    AchievementFrameComparisonHeader:SetPoint('BOTTOMLEFT', AchievementFrameComparison, 'TOPRIGHT', -125, 0)
end










--地下城和团队副本, PVP
function Events:Blizzard_PVPUI(mixin)
    mixin:HideTexture(HonorFrame.Inset.Bg)
    mixin:HideTexture(HonorFrame.BonusFrame.ShadowOverlay)
    mixin:HideTexture(HonorFrame.BonusFrame.WorldBattlesTexture)
    mixin:SetNineSlice(HonorFrame.Inset, nil, true)
    mixin:SetAlphaColor(HonorFrame.BonusFrame.WorldBattlesTexture)
    mixin:HideTexture(HonorFrame.ConquestBar.Background)

    mixin:SetNineSlice(PVPQueueFrame.HonorInset, nil, true)--最右边

    mixin:SetNineSlice(ConquestFrame.Inset, nil, true)--中间
    mixin:HideTexture(ConquestFrame.Inset.Bg)
    mixin:HideTexture(ConquestFrameLeft)
    mixin:HideTexture(ConquestFrameRight)
    mixin:HideTexture(ConquestFrameTopRight)
    mixin:HideTexture(ConquestFrameTop)
    mixin:HideTexture(ConquestFrameTopLeft)
    mixin:HideTexture(ConquestFrameBottomLeft)
    mixin:HideTexture(ConquestFrameBottom)
    mixin:HideTexture(ConquestFrameBottomRight)

    mixin:SetAlphaColor(ConquestFrame.RatedBGTexture)
    PVPQueueFrame.HonorInset:DisableDrawLayer('BACKGROUND')
    mixin:SetAlphaColor(PVPQueueFrame.HonorInset.CasualPanel.HonorLevelDisplay.Background)

    mixin:HideTexture(ConquestFrame.RatedBGTexture)
    mixin:SetScrollBar(LFDQueueFrameSpecific)
end








--冒险指南
function Events:Blizzard_EncounterJournal(mixin)
    mixin:SetNineSlice(EncounterJournal, true)

    mixin:HideTexture(EncounterJournalBg)
    mixin:SetAlphaColor(EncounterJournalInset.Bg, nil, nil, 0.3)
    mixin:SetNineSlice(EncounterJournalInset, nil, true)
    mixin:SetScrollBar(EncounterJournalInstanceSelect)
    mixin:SetSearchBox(EncounterJournalSearchBox)
    mixin:SetScrollBar(EncounterJournal.LootJournalItems.ItemSetsFrame)
    mixin:SetScrollBar(EncounterJournalEncounterFrameInfo.LootContainer)
    mixin:SetScrollBar(EncounterJournalEncounterFrameInfoDetailsScrollFrame)
    mixin:HideTexture(EncounterJournalNavBar.overlay)
    mixin:HideTexture(EncounterJournalNavBarInsetBottomBorder)
    mixin:HideTexture(EncounterJournalNavBarInsetRightBorder)
    mixin:HideTexture(EncounterJournalNavBarInsetLeftBorder)
    mixin:HideTexture(EncounterJournalNavBarInsetBotRightCorner)
    mixin:HideTexture(EncounterJournalNavBarInsetBotLeftCorner)

    mixin:SetAlphaColor(EncounterJournalInstanceSelectBG)
    mixin:SetAlphaColor(EncounterJournalEncounterFrameInfoModelFrameDungeonBG)
    EncounterJournalNavBar:DisableDrawLayer('BACKGROUND')

    mixin:SetScrollBar(EncounterJournalEncounterFrameInfoOverviewScrollFrame)

    mixin:SetFrame(EncounterJournalSuggestTab, {notAlpha=true})
    mixin:SetFrame(EncounterJournalMonthlyActivitiesTab, {notAlpha=true})
    mixin:SetFrame(EncounterJournalDungeonTab, {notAlpha=true})
    mixin:SetFrame(EncounterJournalRaidTab, {notAlpha=true})
    mixin:SetFrame(EncounterJournalLootJournalTab, {notAlpha=true})



    mixin:SetScrollBar(EncounterJournalEncounterFrameInfo.BossesScrollBar)
    mixin:SetScrollBar(EncounterJournalEncounterFrameInstanceFrame.LoreScrollBar)
    mixin:SetScrollBar(EncounterJournal.LootJournal)

    EncounterJournal.LootJournalItems.ItemSetsFrame.ClassDropdown:ClearAllPoints()
    EncounterJournal.LootJournalItems.ItemSetsFrame.ClassDropdown:SetPoint('BOTTOM', EncounterJournal.LootJournalItems.ItemSetsFrame.ClassDropdown:GetParent(), 'TOP', 0, 25)


    C_Timer.After(0.3, function()
        if EncounterJournalMonthlyActivitiesFrame then
            mixin:HideTexture(EncounterJournalMonthlyActivitiesFrame.Bg)
            mixin:HideTexture(EncounterJournalMonthlyActivitiesFrame.ShadowRight)
            mixin:SetScrollBar(EncounterJournalMonthlyActivitiesFrame)
            mixin:SetScrollBar(EncounterJournalMonthlyActivitiesFrame.FilterList)
        end
    end)
end










--公会银行
function Events:Blizzard_GuildBankUI(mixin)
    mixin:SetAlphaColor(GuildBankFrame.BlackBG)
    mixin:HideTexture(GuildBankFrame.TitleBg)
    mixin:HideTexture(GuildBankFrame.RedMarbleBG)
    mixin:SetAlphaColor(GuildBankFrame.MoneyFrameBG)

    mixin:SetAlphaColor(GuildBankFrame.TabLimitBG)
    mixin:SetAlphaColor(GuildBankFrame.TabLimitBGLeft)
    mixin:SetAlphaColor(GuildBankFrame.TabLimitBGRight)
    mixin:SetSearchBox(GuildItemSearchBox)

    mixin:SetAlphaColor(GuildBankFrame.TabTitleBG)
    mixin:SetAlphaColor(GuildBankFrame.TabTitleBGLeft)
    mixin:SetAlphaColor(GuildBankFrame.TabTitleBGRight)

    for i=1, 7 do
        local frame= GuildBankFrame['Column'..i]
        if frame then
            mixin:HideTexture(frame.Background)
        end
        mixin:SetFrame(_G['GuildBankFrameTab'..i], {notAlpha=true})
    end

    local MAX_GUILDBANK_SLOTS_PER_TAB = 98;
    local NUM_SLOTS_PER_GUILDBANK_GROUP = 14;
    hooksecurefunc(GuildBankFrame,'Update', function(self2)--Blizzard_GuildBankUI.lua
        if ( self2.mode == "bank" ) then
            local tab = GetCurrentGuildBankTab() or 1
            for i=1, MAX_GUILDBANK_SLOTS_PER_TAB do
                local index = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP);
                if ( index == 0 ) then
                    index = NUM_SLOTS_PER_GUILDBANK_GROUP;
                end
                local column = ceil((i-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP);
                local button = self2.Columns[column].Buttons[index];
                if button and button.NormalTexture then
                    local texture= GetGuildBankItemInfo(tab, i)
                    button.NormalTexture:SetAlpha(texture and 1 or 0.1)
                end
            end
        end
    end)

    mixin:SetScrollBar(GuildBankFrame.Log)
    mixin:SetScrollBar(GuildBankInfoScrollFrame)
end






--拍卖行
function Events:Blizzard_AuctionHouseUI(mixin)
    mixin:SetAlphaColor(AuctionHouseFrameBg)
    mixin:SetNineSlice(AuctionHouseFrame, true)
    mixin:SetAlphaColor(AuctionHouseFrameMiddle, nil, nil, 0.3)
    mixin:SetAlphaColor(AuctionHouseFrameLeft, nil, nil, 0.3)
    mixin:SetAlphaColor(AuctionHouseFrameRight, nil, nil, 0.3)

    mixin:SetFrame(AuctionHouseFrameBuyTab, {notAlpha=true})--{alpha= 0.3})
    mixin:SetFrame(AuctionHouseFrameSellTab, {notAlpha=true})--{alpha= 0.3})
    mixin:SetFrame(AuctionHouseFrameAuctionsTab, {notAlpha=true})--{alpha= 0.3})
    mixin:SetFrame(AuctionHouseFrame.SearchBar.FilterButton, {alpha= 0.3})

    mixin:SetNineSlice(AuctionHouseFrame.CategoriesList, nil, true)
    mixin:SetScrollBar(AuctionHouseFrame.CategoriesList)
    mixin:HideTexture(AuctionHouseFrame.CategoriesList.Background)

    mixin:SetScrollBar(AuctionHouseFrameAuctionsFrame.BidsList)
    mixin:SetNineSlice(AuctionHouseFrameAuctionsFrame.BidsList, nil, true)
    mixin:SetNineSlice(AuctionHouseFrameAuctionsFrame.AllAuctionsList, nil, true)
    mixin:SetScrollBar(AuctionHouseFrameAuctionsFrame.AllAuctionsList)
    mixin:SetScrollBar(AuctionHouseFrameAuctionsFrame.SummaryList)
    mixin:SetNineSlice(AuctionHouseFrameAuctionsFrame.SummaryList, nil, true)


    mixin:SetNineSlice(AuctionHouseFrame.BrowseResultsFrame.ItemList, nil, true)
    mixin:SetScrollBar(AuctionHouseFrame.BrowseResultsFrame.ItemList)

    mixin:SetNineSlice(AuctionHouseFrame.MoneyFrameInset, nil, true)
    mixin:HideTexture(AuctionHouseFrame.MoneyFrameInset.Bg)
    mixin:HideFrame(AuctionHouseFrame.MoneyFrameBorder)

    mixin:SetSearchBox(AuctionHouseFrame.SearchBar.SearchBox)


    mixin:SetNineSlice(AuctionHouseFrame.CommoditiesSellList, nil, true)
    mixin:SetScrollBar(AuctionHouseFrame.CommoditiesSellList)
    mixin:SetNineSlice(AuctionHouseFrame.CommoditiesSellFrame, nil, true)
    mixin:SetFrame(AuctionHouseFrame.CommoditiesSellFrame.ItemDisplay, {alpha=0})
    mixin:SetSearchBox(AuctionHouseFrame.CommoditiesSellFrame.QuantityInput.InputBox)
    mixin:SetSearchBox(AuctionHouseFrame.CommoditiesSellFrame.PriceInput.MoneyInputFrame.GoldBox)
    mixin:SetSearchBox(AuctionHouseFrame.CommoditiesSellFrame.PriceInput.MoneyInputFrame.SilverBox)

    mixin:SetAlphaColor(AuctionHouseFrame.CommoditiesSellFrame.CreateAuctionTabMiddle, nil, nil, 0.3)
    mixin:SetAlphaColor(AuctionHouseFrame.CommoditiesSellFrame.CreateAuctionTabLeft, nil, nil, 0.3)
    mixin:SetAlphaColor(AuctionHouseFrame.CommoditiesSellFrame.CreateAuctionTabRight, nil, nil, 0.3)

    mixin:SetNineSlice(AuctionHouseFrame.ItemSellList, nil, true)
    mixin:SetScrollBar(AuctionHouseFrame.ItemSellList)
    mixin:SetNineSlice(AuctionHouseFrame.ItemSellFrame, nil, true)
    mixin:SetFrame(AuctionHouseFrame.ItemSellFrame.ItemDisplay, {alpha=0})
    mixin:SetSearchBox(AuctionHouseFrame.ItemSellFrame.QuantityInput.InputBox)
    mixin:SetSearchBox(AuctionHouseFrame.ItemSellFrame.PriceInput.MoneyInputFrame.GoldBox)
    mixin:SetSearchBox(AuctionHouseFrame.ItemSellFrame.PriceInput.MoneyInputFrame.SilverBox)

    mixin:SetAlphaColor(AuctionHouseFrame.ItemSellFrame.CreateAuctionTabMiddle, nil, nil, 0.3)
    mixin:SetAlphaColor(AuctionHouseFrame.ItemSellFrame.CreateAuctionTabLeft, nil, nil, 0.3)
    mixin:SetAlphaColor(AuctionHouseFrame.ItemSellFrame.CreateAuctionTabRight, nil, nil, 0.3)

    --拍卖，所在物品，页面
    mixin:SetSearchBox(AuctionHouseFrameAuctionsFrameBidsTab)
    mixin:SetSearchBox(AuctionHouseFrameAuctionsFrameAuctionsTab)
    mixin:SetFrame(AuctionHouseFrameAuctionsFrameGold, {alpha=0.3})
    mixin:SetFrame(AuctionHouseFrameAuctionsFrameSilver, {alpha=0.3})
    mixin:SetNineSlice(AuctionHouseFrameAuctionsFrame.ItemDisplay, nil, true)
    mixin:SetNineSlice(AuctionHouseFrameAuctionsFrame.CommoditiesList, nil, true)

    --时光
    mixin:SetScrollBar(AuctionHouseFrame.WoWTokenResults.DummyScrollBar)
    mixin:SetNineSlice(AuctionHouseFrame.WoWTokenResults, nil, true)
    --购买
    mixin:SetNineSlice(AuctionHouseFrame.ItemBuyFrame.ItemDisplay, nil, true)
    mixin:SetScrollBar(AuctionHouseFrame.ItemBuyFrame.ItemList)
    mixin:SetNineSlice(AuctionHouseFrame.ItemBuyFrame.ItemList, nil, true)
end









--专业书
function Events:Blizzard_ProfessionsBook(mixin)
    mixin:SetNineSlice(ProfessionsBookFrame, nil, nil, 0.3)
    mixin:SetNineSlice(ProfessionsBookFrameInset, nil, nil, 0.3)
    mixin:HideTexture(ProfessionsBookFrameBg)
    mixin:HideTexture(ProfessionsBookFrameInset.Bg)
end






--专业定制
function Events:Blizzard_ProfessionsCustomerOrders(mixin)
    mixin:SetNineSlice(ProfessionsCustomerOrdersFrame, true)

    mixin:SetSearchBox(ProfessionsCustomerOrdersFrame.BrowseOrders.SearchBar.SearchBox)

    mixin:SetAlphaColor(ProfessionsCustomerOrdersFrameMiddleMiddle)
    mixin:SetAlphaColor(ProfessionsCustomerOrdersFrameMiddleLeft)
    mixin:SetAlphaColor(ProfessionsCustomerOrdersFrameMiddleRight)
    mixin:SetAlphaColor(ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList.Background)

    --mixin:SetAlphaColor(ProfessionsCustomerOrdersFrame.Form.LeftPanelBackground.Background)
    --mixin:SetAlphaColor(ProfessionsCustomerOrdersFrame.Form.RightPanelBackground.Background)

    mixin:HideTexture(ProfessionsCustomerOrdersFrame.MoneyFrameInset.Bg)
    mixin:SetAlphaColor(ProfessionsCustomerOrdersFrameLeft)
    mixin:SetAlphaColor(ProfessionsCustomerOrdersFrameMiddle)
    mixin:SetAlphaColor(ProfessionsCustomerOrdersFrameRight)

    mixin:SetNineSlice(ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList, nil, true)
    mixin:SetNineSlice(ProfessionsCustomerOrdersFrame.BrowseOrders.RecipeList, nil, true)
    mixin:SetScrollBar(ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList)
    mixin:SetScrollBar(ProfessionsCustomerOrdersFrame.BrowseOrders.RecipeList)
    mixin:SetFrame(ProfessionsCustomerOrdersFrameBrowseTab, {alpha=0.3})
    mixin:SetFrame(ProfessionsCustomerOrdersFrameOrdersTab, {alpha=0.3})

    mixin:SetNineSlice(ProfessionsCustomerOrdersFrame.MyOrdersPage.OrderList, nil, true)
    mixin:SetScrollBar(ProfessionsCustomerOrdersFrame.MyOrdersPage.OrderList)

    mixin:SetNineSlice(ProfessionsCustomerOrdersFrame.Form.CurrentListings, true)
    mixin:SetScrollBar(ProfessionsCustomerOrdersFrame.Form.CurrentListings.OrderList)
    mixin:HideTexture(ProfessionsCustomerOrdersFrameBg)

    mixin:SetNineSlice(ProfessionsCustomerOrdersFrame.Form.LeftPanelBackground, true)
    mixin:SetNineSlice(ProfessionsCustomerOrdersFrame.Form.RightPanelBackground, true)
end








--黑市
function Events:Blizzard_BlackMarketUI(mixin)
    mixin:SetAlphaColor(BlackMarketFrameTitleBg)
    mixin:SetAlphaColor(BlackMarketFrameBg)
    mixin:SetAlphaColor(BlackMarketFrame.LeftBorder)
    mixin:SetAlphaColor(BlackMarketFrame.RightBorder)
    mixin:SetAlphaColor(BlackMarketFrame.BottomBorder)
    mixin:SetScrollBar(BlackMarketFrame)
end





--收藏
function Events:Blizzard_Collections(mixin)
    mixin:SetNineSlice(CollectionsJournal, true)
    mixin:SetAlphaColor(CollectionsJournalBg)

    mixin:SetFrame(MountJournal.MountCount, {alpha=0.3})
    mixin:HideTexture(MountJournal.LeftInset.Bg)
    mixin:SetAlphaColor(MountJournal.MountDisplay.YesMountsTex)
    mixin:HideTexture(MountJournal.RightInset.Bg)
    mixin:SetAlphaColor(MountJournal.BottomLeftInset.Background)
    mixin:HideTexture(MountJournal.BottomLeftInset.Bg)
    mixin:SetScrollBar(MountJournal)
    mixin:SetSearchBox(MountJournalSearchBox)
    mixin:SetNineSlice(MountJournal.BottomLeftInset, nil, true)
    mixin:SetNineSlice(MountJournal.RightInset, nil, true)
    mixin:SetNineSlice(MountJournal.LeftInset, nil, true)

    mixin:SetAlphaColor(PetJournalPetCardBG, nil, nil, 0.3)
    mixin:SetAlphaColor(PetJournalPetCardInset.Bg)
    mixin:SetAlphaColor(PetJournalRightInset.Bg)
    mixin:SetAlphaColor(PetJournalLoadoutPet1BG, nil, nil, 0.3)
    mixin:SetAlphaColor(PetJournalLoadoutPet2BG, nil, nil, 0.3)
    mixin:SetAlphaColor(PetJournalLoadoutPet3BG, nil, nil, 0.3)
    mixin:SetAlphaColor(PetJournalLoadoutBorderSlotHeaderBG)
    mixin:HideTexture(PetJournalLeftInset.Bg)
    mixin:HideTexture(PetJournalLoadoutBorder)

    mixin:SetScrollBar(PetJournal)
    mixin:SetSearchBox(PetJournalSearchBox)

    mixin:SetAlphaColor(PetJournal.PetCount.BorderTopMiddle, nil, nil, 0.3)
    mixin:SetAlphaColor(PetJournal.PetCount.Bg, nil, nil, 0.3)
    mixin:SetAlphaColor(PetJournal.PetCount.BorderBottomMiddle, nil, nil, 0.3)
    mixin:SetAlphaColor(PetJournal.PetCount.BorderTopRightMiddle, nil, nil, 0.3)
    mixin:SetAlphaColor(PetJournal.PetCount.BorderTopLeftMiddle, nil, nil, 0.3)
    mixin:SetAlphaColor(PetJournal.PetCount.BorderBottomLeft, nil, nil, 0.3)
    mixin:SetAlphaColor(PetJournal.PetCount.BorderTopLeft, nil, nil, 0.3)
    mixin:SetAlphaColor(PetJournal.PetCount.BorderBottomRight, nil, nil, 0.3)
    mixin:SetAlphaColor(PetJournal.PetCount.BorderTopRight, nil, nil, 0.3)
    mixin:SetAlphaColor(PetJournal.PetCount.BorderLeftMiddle, nil, nil, 0.3)
    mixin:SetAlphaColor(PetJournal.PetCount.BorderRightMiddle, nil, nil, 0.3)
    mixin:SetFrame(PetJournalFilterButton, {alpha=0.3})
    mixin:SetNineSlice(PetJournalLeftInset, nil, true)
    mixin:SetNineSlice(PetJournalPetCardInset, nil, true)
    mixin:SetNineSlice(PetJournalRightInset, nil, true)
    local frame=_G['RematchFrame']
    if frame then
        mixin:HideTexture(frame.Bg)
        mixin:HideTexture(frame.OptionsPanel.List.Back)
        mixin:HideTexture(frame.QueuePanel.List.Back)
        mixin:HideTexture(frame.TargetsPanel.List.Back)
        mixin:HideTexture(frame.TeamsPanel.List.Back)
        mixin:HideTexture(frame.ToolBar.Bg)
    end


    mixin:HideTexture(ToyBox.iconsFrame.BackgroundTile)
    mixin:HideTexture(ToyBox.iconsFrame.Bg)
    mixin:SetSearchBox(ToyBox.searchBo)
    mixin:SetSearchBox(ToyBox.searchBox)
    mixin:SetFrame(ToyBoxFilterButton, {alpha=0.3})
    mixin:HideTexture(ToyBox.iconsFrame.ShadowLineTop)
    mixin:HideTexture(ToyBox.iconsFrame.ShadowLineBottom)

    mixin:SetNineSlice(ToyBox.iconsFrame, nil, true)
    ToyBox.progressBar:DisableDrawLayer('BACKGROUND')

    mixin:HideTexture(HeirloomsJournal.iconsFrame.BackgroundTile)
    mixin:HideTexture(HeirloomsJournal.iconsFrame.Bg)
    mixin:SetSearchBox(HeirloomsJournalSearchBox)
    mixin:SetAlphaColor(HeirloomsJournalMiddleMiddle)
    mixin:SetAlphaColor(HeirloomsJournalMiddleLeft)
    mixin:SetAlphaColor(HeirloomsJournalMiddleRight)
    mixin:SetAlphaColor(HeirloomsJournalBottomMiddle)
    mixin:SetAlphaColor(HeirloomsJournalTopMiddle)
    mixin:SetAlphaColor(HeirloomsJournalBottomLeft)
    mixin:SetAlphaColor(HeirloomsJournalBottomRight)
    mixin:SetAlphaColor(HeirloomsJournalTopLeft)
    mixin:SetAlphaColor(HeirloomsJournalTopRight)
    mixin:HideTexture(HeirloomsJournal.iconsFrame.ShadowLineBottom)
    mixin:HideTexture(HeirloomsJournal.iconsFrame.ShadowLineTop)
    mixin:SetNineSlice(HeirloomsJournal.iconsFrame, nil, true)
    HeirloomsJournal.progressBar:DisableDrawLayer('BACKGROUND')
    mixin:SetFrame(HeirloomsJournal.FilterButton, {alpha=0.3})

    mixin:HideTexture(WardrobeCollectionFrame.ItemsCollectionFrame.ShadowLineBottom)
    mixin:HideTexture(WardrobeCollectionFrame.ItemsCollectionFrame.ShadowLineTop)
    mixin:SetNineSlice(WardrobeCollectionFrame.ItemsCollectionFrame, nil, true)
    mixin:HideTexture(WardrobeCollectionFrame.ItemsCollectionFrame.BackgroundTile)
    mixin:HideTexture(WardrobeCollectionFrame.ItemsCollectionFrame.Bg)
    mixin:HideTexture(WardrobeCollectionFrame.ItemsCollectionFrame.ShadowLineTop)

    mixin:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.BackgroundTile)
    mixin:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.Bg)
    mixin:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.LeftInset.Bg)
    mixin:SetScrollBar(WardrobeCollectionFrame.SetsCollectionFrame.ListContainer)
    mixin:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.ShadowLineTop)
    mixin:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.BGCornerBottomRight)
    mixin:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.BGCornerBottomLeft)
    mixin:SetNineSlice(WardrobeCollectionFrame.SetsCollectionFrame.RightInset, nil, true)
    mixin:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.ShadowLineBottom)
    mixin:SetNineSlice(WardrobeCollectionFrame.SetsCollectionFrame.LeftInset, nil, true)

    mixin:SetSearchBox(WardrobeCollectionFrameSearchBox)
    mixin:SetAlphaColor(WardrobeCollectionFrameMiddleMiddle)
    mixin:SetAlphaColor(WardrobeCollectionFrameTopMiddle)
    mixin:SetAlphaColor(WardrobeCollectionFrameBottomMiddle)
    mixin:SetAlphaColor(WardrobeCollectionFrameTopMiddle)
    mixin:SetAlphaColor(WardrobeCollectionFrameMiddleLeft)
    mixin:SetAlphaColor(WardrobeCollectionFrameMiddleRight)
    mixin:SetAlphaColor(WardrobeCollectionFrameTopLeft)
    mixin:SetAlphaColor(WardrobeCollectionFrameBottomLeft)
    mixin:SetAlphaColor(WardrobeCollectionFrameBottomRight)
    mixin:SetAlphaColor(WardrobeCollectionFrameTopLeft)

    mixin:SetFrame(WardrobeCollectionFrame.FilterButton, {alpha=0.3})
    mixin:SetFrame(WardrobeSetsCollectionVariantSetsButton, {alpha=0.3})

    mixin:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.ModelFadeTexture)

    mixin:SetFrame(WardrobeCollectionFrameTab1, {notAlpha=true})
    mixin:SetFrame(WardrobeCollectionFrameTab2, {notAlpha=true})

    --试衣间
    mixin:SetNineSlice(WardrobeFrame, true)
    mixin:HideTexture(WardrobeFrameBg)
    mixin:HideTexture(WardrobeTransmogFrame.Inset.Bg)
    mixin:SetAlphaColor(WardrobeTransmogFrame.Inset.BG)
    mixin:HideTexture(WardrobeCollectionFrame.SetsTransmogFrame.BackgroundTile)
    mixin:SetNineSlice(WardrobeCollectionFrame.SetsTransmogFrame, nil, true)
    mixin:SetAlphaColor(WardrobeCollectionFrame.SetsTransmogFrame.Bg)


    mixin:SetAlphaColor(WardrobeTransmogFrame.MoneyMiddle)
    mixin:SetAlphaColor(WardrobeTransmogFrame.MoneyLeft)
    mixin:SetAlphaColor(WardrobeTransmogFrame.MoneyRight)

    hooksecurefunc(WardrobeCollectionFrame, 'SetTab', function(self2)
        local frame2= self2.activeFrame
        if frame2 and frame2==self2.SetsTransmogFrame then
            for i=1, frame2.PAGE_SIZE or 8 do
                local btn= frame2.Models[i]
                if btn then
                    btn:DisableDrawLayer('BACKGROUND')
                end
            end
        end
    end)
    for v=1,4 do
        for h= 1, 2 do
            local button= WardrobeCollectionFrame.SetsTransmogFrame['ModelR'..h..'C'..v]
            if button then
                button:DisableDrawLayer('BACKGROUND')
            end
        end
    end
    WardrobeCollectionFrame.progressBar:DisableDrawLayer('BACKGROUND')


    for i=1, 7 do
        mixin:SetFrame(_G['CollectionsJournalTab'..i], {notAlpha=true})
    end

    if _G['RematchJournal'] then
        mixin:SetNineSlice(_G['RematchJournal'], true)
        mixin:SetAlphaColor(_G['RematchJournalBg'])
        mixin:SetAlphaColor(RematchLoadoutPanel.Target.InsetBack)
        mixin:HideTexture(RematchPetPanel.Top.InsetBack)
        mixin:SetAlphaColor(RematchQueuePanel.List.Background.InsetBack)
        mixin:SetAlphaColor(RematchQueuePanel.Top.InsetBack)
        mixin:HideTexture(RematchPetPanel.Top.TypeBar.NineSlice)
        mixin:SetAlphaColor(RematchTeamPanel.List.Background.InsetBack)
        mixin:SetAlphaColor(RematchOptionPanel.List.Background.InsetBack)
        mixin:SetAlphaColor(RematchLoadoutPanel.TopLoadout.InsetBack)
    end
end












--日历
function Events:Blizzard_Calendar(mixin)
    mixin:SetAlphaColor(CalendarFrameTopMiddleTexture)
    mixin:SetAlphaColor(CalendarFrameTopLeftTexture)
    mixin:SetAlphaColor(CalendarFrameTopRightTexture)

    mixin:SetAlphaColor(CalendarFrameLeftTopTexture)
    mixin:SetAlphaColor(CalendarFrameLeftMiddleTexture)
    mixin:SetAlphaColor(CalendarFrameLeftBottomTexture)
    mixin:SetAlphaColor(CalendarFrameRightTopTexture)
    mixin:SetAlphaColor(CalendarFrameRightMiddleTexture)
    mixin:SetAlphaColor(CalendarFrameRightBottomTexture)

    mixin:SetAlphaColor(CalendarFrameBottomRightTexture)
    mixin:SetAlphaColor(CalendarFrameBottomMiddleTexture)
    mixin:SetAlphaColor(CalendarFrameBottomLeftTexture)

    mixin:SetAlphaColor(CalendarCreateEventFrame.Border.Bg)
    mixin:SetFrame(CalendarCreateEventFrame.Border, {notAlpha=true})
    mixin:SetSearchBox(CalendarCreateEventTitleEdit)
    mixin:SetNineSlice(CalendarCreateEventDescriptionContainer, nil, nil, true)
    mixin:SetNineSlice(CalendarCreateEventInviteList, nil, nil, true)
    mixin:SetAlphaColor(CalendarCreateEventDivider, true)
    mixin:SetSearchBox(CalendarCreateEventInviteEdit)
    mixin:SetAlphaColor(CalendarCreateEventFrameButtonBackground, true)
    mixin:SetAlphaColor(CalendarCreateEventCreateButtonBorder, true)
    mixin:SetFrame(CalendarCreateEventFrame.Header, {notAlpha=true})

    mixin:SetFrame(CalendarViewHolidayFrame.Header, {notAlpha=true})
    mixin:SetFrame(CalendarViewHolidayFrame.Border, {notAlpha=true})

    mixin:SetAlphaColor(CalendarMonthBackground)
    mixin:SetAlphaColor(CalendarYearBackground)
end







--飞行地图
function Events:Blizzard_FlightMap(mixin)
    mixin:SetNineSlice(FlightMapFrame.BorderFrame, true)
    mixin:HideTexture(FlightMapFrame.ScrollContainer.Child.TiledBackground)
    mixin:HideTexture(FlightMapFrameBg)
end







--镶嵌宝石，界面
function Events:Blizzard_ItemSocketingUI(mixin)
    mixin:SetNineSlice(ItemSocketingFrame, true)
    mixin:SetNineSlice(ItemSocketingFrameInset, nil, true)
    mixin:SetAlphaColor(ItemSocketingFrameBg)

    ItemSocketingFrameInset.Bg:ClearAllPoints()
    ItemSocketingFrameInset.Bg:SetAllPoints(ItemSocketingScrollFrame)
    mixin:HideTexture(ItemSocketingFrame['SocketFrame-Right'])
    mixin:HideTexture(ItemSocketingFrame['SocketFrame-Left'])
    mixin:HideTexture(ItemSocketingFrame['ParchmentFrame-Top'])
    mixin:HideTexture(ItemSocketingFrame['ParchmentFrame-Bottom'])
    mixin:HideTexture(ItemSocketingFrame['ParchmentFrame-Right'])
    mixin:HideTexture(ItemSocketingFrame['ParchmentFrame-Left'])
    mixin:SetAlphaColor(ItemSocketingFrame['GoldBorder-Top'])
    mixin:SetAlphaColor(ItemSocketingFrame['GoldBorder-Bottom'])
    mixin:SetAlphaColor(ItemSocketingFrame['GoldBorder-Right'])
    mixin:SetAlphaColor(ItemSocketingFrame['GoldBorder-Left'])
    mixin:SetAlphaColor(ItemSocketingFrame['GoldBorder-BottomLeft'])
    mixin:SetAlphaColor(ItemSocketingFrame['GoldBorder-TopLeft'])
    mixin:SetAlphaColor(ItemSocketingFrame['GoldBorder-BottomRight'])
    mixin:SetAlphaColor(ItemSocketingFrame['GoldBorder-TopRight'])
    mixin:SetAlphaColor(_G['ItemSocketingScrollFrameMiddle'])
    mixin:SetAlphaColor(_G['ItemSocketingScrollFrameTop'])
    mixin:SetAlphaColor(_G['ItemSocketingScrollFrameBottom'])
    mixin:SetScrollBar(ItemSocketingScrollFrame)

    mixin:HideTexture(ItemSocketingFrame.TopLeftNub)
    mixin:HideTexture(ItemSocketingFrame.TopRightNub)
    mixin:HideTexture(ItemSocketingFrame.MiddleLeftNub)
    mixin:HideTexture(ItemSocketingFrame.MiddleRightNub)
    mixin:HideTexture(ItemSocketingFrame.BottomLeftNub)
    mixin:HideTexture(ItemSocketingFrame.BottomRightNub)
end







function Events:Blizzard_ChallengesUI(mixin)--挑战, 钥匙插入， 界面
    mixin:SetAlphaColor(ChallengesFrameInset.Bg)

    hooksecurefunc(ChallengesKeystoneFrame, 'Reset', function(self2)--钥匙插入， 界面
        mixin:SetFrame(self2, {index=1})
        mixin:HideTexture(self2.InstructionBackground)
    end)
end






function Events:Blizzard_WeeklyRewards(mixin)--周奖励提示
    mixin:SetAlphaColor(WeeklyRewardsFrame.BackgroundTile)
    mixin:SetSearchBox(WeeklyRewardsFrame.HeaderFrame)
    mixin:SetAlphaColor(WeeklyRewardsFrame.RaidFrame.Background)
    mixin:SetAlphaColor(WeeklyRewardsFrame.MythicFrame.Background)
    mixin:SetAlphaColor(WeeklyRewardsFrame.PVPFrame.Background)
    hooksecurefunc(WeeklyRewardsFrame,'UpdateSelection', function(self2)
        for _, frame in ipairs(self2.Activities) do
            mixin:SetAlphaColor(frame.Background)
        end
    end)
end






function Events:Blizzard_ItemInteractionUI(mixin)--套装, 转换
    mixin:SetNineSlice(ItemInteractionFrame, true)
    mixin:SetAlphaColor(ItemInteractionFrameBg)
    mixin:SetAlphaColor(ItemInteractionFrame.Inset.Bg)
    mixin:SetAlphaColor(ItemInteractionFrameMiddle)

    mixin:SetAlphaColor(ItemInteractionFrameRight)
    mixin:SetAlphaColor(ItemInteractionFrameLeft)

    mixin:HideTexture(ItemInteractionFrame.ButtonFrame.BlackBorder)
end





--玩家, 观察角色, 界面
function Events:Blizzard_InspectUI(mixin)
    mixin:SetNineSlice(InspectFrame, true)
    mixin:SetAlphaColor(InspectFrameBg)
    mixin:HideTexture(InspectFrameInset.Bg)
    mixin:HideTexture(InspectPVPFrame.BG)
    mixin:HideTexture(InspectGuildFrameBG)
    mixin:SetFrame(InspectFrameTab1, {notAlpha=true})
    mixin:SetFrame(InspectFrameTab2, {notAlpha=true})
    mixin:SetFrame(InspectFrameTab3, {notAlpha=true})
    mixin:SetNineSlice(InspectFrame, true)
    mixin:SetNineSlice(InspectFrameInset, nil, true)
end





--装备升级,界面 
function Events:Blizzard_ItemUpgradeUI(mixin)
    mixin:SetNineSlice(ItemUpgradeFrame, true)
    mixin:SetAlphaColor(ItemUpgradeFrameBg)
    mixin:HideTexture(ItemUpgradeFrame.TopBG)
    mixin:HideTexture(ItemUpgradeFrame.BottomBG)
    mixin:SetAlphaColor(ItemUpgradeFramePlayerCurrenciesBorderMiddle)
    mixin:SetAlphaColor(ItemUpgradeFramePlayerCurrenciesBorderLeft)
    mixin:SetAlphaColor(ItemUpgradeFramePlayerCurrenciesBorderRight)

    mixin:SetAlphaColor(ItemUpgradeFrameMiddle)
    mixin:SetAlphaColor(ItemUpgradeFrameRight)
    mixin:SetAlphaColor(ItemUpgradeFrameLeft)
end






--宏
function Events:Blizzard_MacroUI(mixin)
    mixin:SetFrame(MacroFrame, {notAlpha=true})
    mixin:SetNineSlice(MacroFrameInset, true)
    mixin:SetNineSlice(MacroFrame, true)
    mixin:SetNineSlice(MacroFrameTextBackground, true, nil, nil, true)
    mixin:HideTexture(MacroFrameBg)
    mixin:SetAlphaColor(MacroFrameInset.Bg)
    mixin:SetAlphaColor(MacroHorizontalBarLeft, true)
    mixin:HideTexture(MacroFrameSelectedMacroBackground)
    mixin:SetScrollBar(MacroFrame.MacroSelector)
    mixin:SetScrollBar(MacroFrame.NoteEditBox)
    mixin:SetScrollBar(MacroFrameScrollFrame)
end








--要塞
function Events:Blizzard_GarrisonUI(mixin)
    mixin:SetNineSlice(GarrisonCapacitiveDisplayFrame, true)
    if GarrisonCapacitiveDisplayFrame then--要塞订单
        mixin:SetAlphaColor(GarrisonCapacitiveDisplayFrameBg)
        mixin:HideTexture(GarrisonCapacitiveDisplayFrame.TopTileStreaks)
        mixin:HideTexture(GarrisonCapacitiveDisplayFrameInset.Bg)
    end

    mixin:SetFrame(GarrisonLandingPage, {alpha= 0.3})
    mixin:SetFrame(GarrisonLandingPage.Report, {alpha= 0.3})
    if GarrisonLandingPageFollowerList then
        mixin:HideTexture(GarrisonLandingPageFollowerList.FollowerScrollFrame)
    end
end






--欲龙术
function Events:Blizzard_GenericTraitUI(mixin)
    mixin:SetAlphaColor(GenericTraitFrame.Background)
    mixin:SetNineSlice(GenericTraitFrame, true)
end







--任务选择
function Events:Blizzard_PlayerChoice(mixin)
    hooksecurefunc(PlayerChoiceFrame, 'SetupFrame', function(self2)
        if self2.Background then
            mixin:SetAlphaColor(self2.Background.BackgroundTile, nil, nil, 0)
            mixin:SetAlphaColor(self2.Background, nil, nil, 0)
        end

        mixin:SetNineSlice(self2)
        mixin:SetAlphaColor(self2.Header)
        mixin:SetSearchBox(self2.Title)
    end)
end







--派系声望
function Events:Blizzard_MajorFactions(mixin)
    mixin:SetAlphaColor(MajorFactionRenownFrame.Background)
end








--专业, 初始化, 透明
function Events:Blizzard_Professions(mixin)
    mixin:SetNineSlice(ProfessionsFrame, true)
    mixin:SetAlphaColor(ProfessionsFrameBg)
    mixin:SetAlphaColor(ProfessionsFrame.CraftingPage.SchematicForm.Background, nil, nil, 0.3)
    mixin:SetAlphaColor(ProfessionsFrame.CraftingPage.RankBar.Background, nil, nil, 0.3)

    mixin:SetAlphaColor(ProfessionsFrame.CraftingPage.SchematicForm.Details.BackgroundTop)
    mixin:SetAlphaColor(ProfessionsFrame.CraftingPage.SchematicForm.Details.BackgroundMiddle)
    mixin:SetAlphaColor(ProfessionsFrame.CraftingPage.SchematicForm.Details.BackgroundBottom)

    mixin:HideTexture(ProfessionsFrame.SpecPage.TreeView.Background)
    mixin:HideTexture(ProfessionsFrame.SpecPage.DetailedView.Background)
    mixin:SetAlphaColor(ProfessionsFrame.SpecPage.DetailedView.Path.DialBG)
    mixin:SetAlphaColor(ProfessionsFrame.SpecPage.DetailedView.UnspentPoints.CurrencyBackground)

    mixin:SetNineSlice(InspectRecipeFrame, true)
    mixin:SetAlphaColor(InspectRecipeFrameBg)
    mixin:SetAlphaColor(InspectRecipeFrame.SchematicForm.MinimalBackground)
    mixin:SetTabSystem(ProfessionsFrame)

    if ProfessionsFrame.SpecPage then
        hooksecurefunc(ProfessionsFrame.SpecPage, 'UpdateTabs', function(self2)
            for tab, bool in self2.tabsPool:EnumerateActive() do
                if bool then
                    mixin:SetFrame(tab, {alpha=0.3})
                end
            end
        end)
        mixin:SetAlphaColor(ProfessionsFrame.SpecPage.PanelFooter)

        mixin:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList.Background, nil, nil, 0.3)
        mixin:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.OrderList.Background, nil,nil, 0.3)
    end

    mixin:SetAlphaColor(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.Background, nil, nil, 0.3)
    mixin:SetAlphaColor(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.Background, nil, nil, 0.3)
    mixin:SetNineSlice(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.NineSlice, true)
    mixin:SetNineSlice(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.NineSlice, true)

    mixin:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.PublicOrdersButton.Middle, nil, nil, 0.3)
    mixin:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.PublicOrdersButton.Right, nil, nil, 0.3)
    mixin:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.PublicOrdersButton.Left, nil, nil, 0.3)
    mixin:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.PersonalOrdersButton.Middle, nil, nil, 0.3)
    mixin:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.PersonalOrdersButton.Right, nil, nil, 0.3)
    mixin:SetAlphaColor(ProfessionsFrame.OrdersPage.BrowseFrame.PersonalOrdersButton.Left, nil, nil, 0.3)

    mixin:SetNineSlice(ProfessionsFrame.CraftingPage.CraftingOutputLog, true)
    mixin:SetScrollBar(ProfessionsFrame.CraftingPage.CraftingOutputLog)
    mixin:SetScrollBar(ProfessionsFrame.CraftingPage.RecipeList)

    mixin:SetNineSlice(ProfessionsFrame.CraftingPage.SchematicForm, true)
    mixin:SetAlphaColor(ProfessionsFrame.CraftingPage.SchematicForm.MinimalBackground, nil, nil, 0)

    mixin:SetScrollBar(ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList)
    mixin:SetScrollBar(ProfessionsFrame.OrdersPage.BrowseFrame.OrderList)
end








--点击，施法
function Events:Blizzard_ClickBindingUI(mixin)
    mixin:SetNineSlice(ClickBindingFrame, true)
    mixin:SetScrollBar(ClickBindingFrame)
    mixin:SetAlphaColor(ClickBindingFrameBg)
    ClickBindingFrame.ScrollBoxBackground:Hide()
    --mixin:SetNineSlice(ClickBindingFrame.ScrollBoxBackground, nil, true)

    mixin:SetNineSlice(ClickBindingFrame.TutorialFrame, true)
end









function Events:Blizzard_ArchaeologyUI(mixin)
    mixin:SetNineSlice(ArchaeologyFrame, true)
    mixin:SetNineSlice(ArchaeologyFrameInset, nil, true)
    mixin:HideTexture(ArchaeologyFrameBg)
    mixin:HideTexture(ArchaeologyFrameInset.Bg)
    mixin:HideTexture(ArchaeologyFrameRankBarBackground)
    mixin:SetAlphaColor(ArchaeologyFrameRaceFilterMiddle, nil, nil, 0.3)
    mixin:SetAlphaColor(ArchaeologyFrameRaceFilterLeft, nil, nil, 0.3)
    mixin:SetAlphaColor(ArchaeologyFrameRaceFilterRight, nil, nil, 0.3)
end








--分解 ScrappingMachineFrame
function Events:Blizzard_ScrappingMachineUI(mixin)
    mixin:SetNineSlice(ScrappingMachineFrame, true)
    mixin:SetAlphaColor(ScrappingMachineFrameBg, nil, nil, 0.3)
    mixin:HideTexture(ScrappingMachineFrame.Background)
    mixin:HideTexture(ScrappingMachineFrameInset.Bg)
    mixin:SetNineSlice(ScrappingMachineFrameInset, true)
end









--地下堡
function Events:Blizzard_DelvesDashboardUI(mixin)
    mixin:SetAlphaColor(DelvesDashboardFrame.DashboardBackground, nil, nil, 0.3)
    mixin:SetAlphaColor(DelvesCompanionConfigurationFrame.Background, nil, nil, 0.3)
    mixin:HideTexture(DelvesCompanionConfigurationFrame.Bg)
    mixin:SetFrame(DelvesCompanionConfigurationFrame.Border)

    mixin:SetNineSlice(DelvesCompanionAbilityListFrame, true)
    mixin:SetAlphaColor(DelvesCompanionAbilityListFrameBg)
    mixin:HideTexture(DelvesCompanionAbilityListFrame.CompanionAbilityListBackground)
end








function Events:Blizzard_CovenantRenown(mixin)
    mixin:HideTexture(CovenantRenownFrame.Background)
end
















function WoWTools_PlusTextureMixin:Init_Event()
    for name, func in pairs(Events) do
        if C_AddOns.IsAddOnLoaded(name) then
            do
                func(nil, self)
            end
            Events[name]= nil
        end
    end
end


function WoWTools_PlusTextureMixin:Set_Event(name)
    local func=Events[name]
    if func then
        do
            func(nil, self)
        end
        Events[name]= nil
    end
end