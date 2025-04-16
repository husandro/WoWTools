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
    self:SetSearchBox(TimeManagerAlarmMessageEditBox)
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









local function Set_TalentsFrameBg()
    local show= not Save().HideTalentsBG
    PlayerSpellsFrame.TalentsFrame.Background:SetShown(show)
    PlayerSpellsFrame.TalentsFrame.HeroTalentsContainer.PreviewContainer.Background:SetShown(show)
    PlayerSpellsFrame.TalentsFrame.BottomBar:SetShown(show)
end

--天赋和法术书
function WoWTools_TextureMixin.Events:Blizzard_PlayerSpells()
    self:SetAlphaColor(PlayerSpellsFrameBg)
    self:SetNineSlice(PlayerSpellsFrame, 0.3)
    self:SetTabSystem(PlayerSpellsFrame)

    self:SetAlphaColor(PlayerSpellsFrame.SpecFrame.Background)--专精
    self:HideTexture(PlayerSpellsFrame.SpecFrame.BlackBG)

    self:SetAlphaColor(PlayerSpellsFrame.TalentsFrame.BottomBar, 0.3)--天赋
    self:HideTexture(PlayerSpellsFrame.TalentsFrame.BlackBG)
    self:SetSearchBox(PlayerSpellsFrame.TalentsFrame.SearchBox)
    Menu.ModifyMenu("MENU_CLASS_TALENT_PROFILE", function(_, root)--隐藏，天赋，背景
        root:CreateDivider()
        local sub=WoWTools_MenuMixin:ShowBackground(root, function()
            return not Save().HideTalentsBG
        end, function()
            Save().HideTalentsBG= not Save().HideTalentsBG and true or nil
            Set_TalentsFrameBg()
        end)
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_TextureMixin.addName)
        end)
    end)
    Set_TalentsFrameBg()


    self:SetAlphaColor(PlayerSpellsFrame.SpellBookFrame.TopBar)--法术书
    self:SetSearchBox(PlayerSpellsFrame.SpellBookFrame.SearchBox)
    self:SetTabSystem(PlayerSpellsFrame.SpellBookFrame)



    --英雄专精
    self:SetNineSlice(HeroTalentsSelectionDialog, nil, nil, true, false)
end







function WoWTools_TextureMixin.Events:Blizzard_AchievementUI()--成就
    self:HideFrame(AchievementFrame)
    self:HideFrame(AchievementFrame.Header)
    self:HideFrame(AchievementFrameSummary)
    self:SetNineSlice(AchievementFrameCategories, true)
    self:SetScrollBar(AchievementFrameCategories)

    self:SetScrollBar(AchievementFrameAchievements)
    self:HideFrame(AchievementFrameAchievements)

    self:SetScrollBar(AchievementFrameStats)
    self:SetSearchBox(AchievementFrame.SearchBox)
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
    self:SetNineSlice(EncounterJournal, true)

    self:HideTexture(EncounterJournalBg)
    self:SetAlphaColor(EncounterJournalInset.Bg, nil, nil, 0.3)
    self:SetNineSlice(EncounterJournalInset, nil, true)
    self:SetScrollBar(EncounterJournalInstanceSelect)
    self:SetSearchBox(EncounterJournalSearchBox)
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

    self:SetSearchBox(AuctionHouseFrame.SearchBar.SearchBox)


    self:SetNineSlice(AuctionHouseFrame.CommoditiesSellList, nil, true)
    self:SetScrollBar(AuctionHouseFrame.CommoditiesSellList)
    self:SetNineSlice(AuctionHouseFrame.CommoditiesSellFrame, nil, true)
    self:SetFrame(AuctionHouseFrame.CommoditiesSellFrame.ItemDisplay, {alpha=0})
    self:SetSearchBox(AuctionHouseFrame.CommoditiesSellFrame.QuantityInput.InputBox)
    self:SetSearchBox(AuctionHouseFrame.CommoditiesSellFrame.PriceInput.MoneyInputFrame.GoldBox)
    self:SetSearchBox(AuctionHouseFrame.CommoditiesSellFrame.PriceInput.MoneyInputFrame.SilverBox)

    self:SetAlphaColor(AuctionHouseFrame.CommoditiesSellFrame.CreateAuctionTabMiddle, nil, nil, 0.3)
    self:SetAlphaColor(AuctionHouseFrame.CommoditiesSellFrame.CreateAuctionTabLeft, nil, nil, 0.3)
    self:SetAlphaColor(AuctionHouseFrame.CommoditiesSellFrame.CreateAuctionTabRight, nil, nil, 0.3)

    self:SetNineSlice(AuctionHouseFrame.ItemSellList, nil, true)
    self:SetScrollBar(AuctionHouseFrame.ItemSellList)
    self:SetNineSlice(AuctionHouseFrame.ItemSellFrame, nil, true)
    self:SetFrame(AuctionHouseFrame.ItemSellFrame.ItemDisplay, {alpha=0})
    self:SetSearchBox(AuctionHouseFrame.ItemSellFrame.QuantityInput.InputBox)
    self:SetSearchBox(AuctionHouseFrame.ItemSellFrame.PriceInput.MoneyInputFrame.GoldBox)
    self:SetSearchBox(AuctionHouseFrame.ItemSellFrame.PriceInput.MoneyInputFrame.SilverBox)

    self:SetAlphaColor(AuctionHouseFrame.ItemSellFrame.CreateAuctionTabMiddle, nil, nil, 0.3)
    self:SetAlphaColor(AuctionHouseFrame.ItemSellFrame.CreateAuctionTabLeft, nil, nil, 0.3)
    self:SetAlphaColor(AuctionHouseFrame.ItemSellFrame.CreateAuctionTabRight, nil, nil, 0.3)

    --拍卖，所在物品，页面
    self:SetSearchBox(AuctionHouseFrameAuctionsFrameBidsTab)
    self:SetSearchBox(AuctionHouseFrameAuctionsFrameAuctionsTab)
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
end






--专业定制
function WoWTools_TextureMixin.Events:Blizzard_ProfessionsCustomerOrders()
    self:SetNineSlice(ProfessionsCustomerOrdersFrame, true)

    self:SetSearchBox(ProfessionsCustomerOrdersFrame.BrowseOrders.SearchBar.SearchBox)

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





--收藏
function WoWTools_TextureMixin.Events:Blizzard_Collections()
    self:SetNineSlice(CollectionsJournal, true)
    self:SetAlphaColor(CollectionsJournalBg)

    self:SetFrame(MountJournal.MountCount, {alpha=0.3})
    self:HideTexture(MountJournal.LeftInset.Bg)
    self:SetAlphaColor(MountJournal.MountDisplay.YesMountsTex)
    self:HideTexture(MountJournal.RightInset.Bg)
    self:SetAlphaColor(MountJournal.BottomLeftInset.Background)
    self:HideTexture(MountJournal.BottomLeftInset.Bg)
    self:SetScrollBar(MountJournal)
    self:SetSearchBox(MountJournalSearchBox)
    self:SetNineSlice(MountJournal.BottomLeftInset, nil, true)
    self:SetNineSlice(MountJournal.RightInset, nil, true)
    self:SetNineSlice(MountJournal.LeftInset, nil, true)

    self:SetAlphaColor(PetJournalPetCardBG, nil, nil, 0.3)
    self:SetAlphaColor(PetJournalPetCardInset.Bg)
    self:SetAlphaColor(PetJournalRightInset.Bg)
    self:SetAlphaColor(PetJournalLoadoutPet1BG, nil, nil, 0.3)
    self:SetAlphaColor(PetJournalLoadoutPet2BG, nil, nil, 0.3)
    self:SetAlphaColor(PetJournalLoadoutPet3BG, nil, nil, 0.3)
    self:SetAlphaColor(PetJournalLoadoutBorderSlotHeaderBG)
    self:HideTexture(PetJournalLeftInset.Bg)
    self:HideTexture(PetJournalLoadoutBorder)

    self:SetScrollBar(PetJournal)
    self:SetSearchBox(PetJournalSearchBox)

    self:SetAlphaColor(PetJournal.PetCount.BorderTopMiddle, nil, nil, 0.3)
    self:SetAlphaColor(PetJournal.PetCount.Bg, nil, nil, 0.3)
    self:SetAlphaColor(PetJournal.PetCount.BorderBottomMiddle, nil, nil, 0.3)
    self:SetAlphaColor(PetJournal.PetCount.BorderTopRightMiddle, nil, nil, 0.3)
    self:SetAlphaColor(PetJournal.PetCount.BorderTopLeftMiddle, nil, nil, 0.3)
    self:SetAlphaColor(PetJournal.PetCount.BorderBottomLeft, nil, nil, 0.3)
    self:SetAlphaColor(PetJournal.PetCount.BorderTopLeft, nil, nil, 0.3)
    self:SetAlphaColor(PetJournal.PetCount.BorderBottomRight, nil, nil, 0.3)
    self:SetAlphaColor(PetJournal.PetCount.BorderTopRight, nil, nil, 0.3)
    self:SetAlphaColor(PetJournal.PetCount.BorderLeftMiddle, nil, nil, 0.3)
    self:SetAlphaColor(PetJournal.PetCount.BorderRightMiddle, nil, nil, 0.3)
    self:SetFrame(PetJournalFilterButton, {alpha=0.3})
    self:SetNineSlice(PetJournalLeftInset, nil, true)
    self:SetNineSlice(PetJournalPetCardInset, nil, true)
    self:SetNineSlice(PetJournalRightInset, nil, true)

    if _G['RematchFrame'] then
        self:HideTexture(_G['RematchFrame'].Bg)
        self:HideTexture(_G['RematchFrame'].OptionsPanel.List.Back)
        self:HideTexture(_G['RematchFrame'].QueuePanel.List.Back)
        self:HideTexture(_G['RematchFrame'].TargetsPanel.List.Back)
        self:HideTexture(_G['RematchFrame'].TeamsPanel.List.Back)
        self:HideTexture(_G['RematchFrame'].ToolBar.Bg)
    end


    self:HideTexture(ToyBox.iconsFrame.BackgroundTile)
    self:HideTexture(ToyBox.iconsFrame.Bg)
    self:SetSearchBox(ToyBox.searchBo)
    self:SetSearchBox(ToyBox.searchBox)
    self:SetFrame(ToyBoxFilterButton, {alpha=0.3})
    self:HideTexture(ToyBox.iconsFrame.ShadowLineTop)
    self:HideTexture(ToyBox.iconsFrame.ShadowLineBottom)

    self:SetNineSlice(ToyBox.iconsFrame, nil, true)
    ToyBox.progressBar:DisableDrawLayer('BACKGROUND')

    self:HideTexture(HeirloomsJournal.iconsFrame.BackgroundTile)
    self:HideTexture(HeirloomsJournal.iconsFrame.Bg)
    self:SetSearchBox(HeirloomsJournalSearchBox)
    self:SetAlphaColor(HeirloomsJournalMiddleMiddle)
    self:SetAlphaColor(HeirloomsJournalMiddleLeft)
    self:SetAlphaColor(HeirloomsJournalMiddleRight)
    self:SetAlphaColor(HeirloomsJournalBottomMiddle)
    self:SetAlphaColor(HeirloomsJournalTopMiddle)
    self:SetAlphaColor(HeirloomsJournalBottomLeft)
    self:SetAlphaColor(HeirloomsJournalBottomRight)
    self:SetAlphaColor(HeirloomsJournalTopLeft)
    self:SetAlphaColor(HeirloomsJournalTopRight)
    self:HideTexture(HeirloomsJournal.iconsFrame.ShadowLineBottom)
    self:HideTexture(HeirloomsJournal.iconsFrame.ShadowLineTop)
    self:SetNineSlice(HeirloomsJournal.iconsFrame, nil, true)
    HeirloomsJournal.progressBar:DisableDrawLayer('BACKGROUND')
    self:SetFrame(HeirloomsJournal.FilterButton, {alpha=0.3})

    self:HideTexture(WardrobeCollectionFrame.ItemsCollectionFrame.ShadowLineBottom)
    self:HideTexture(WardrobeCollectionFrame.ItemsCollectionFrame.ShadowLineTop)
    self:SetNineSlice(WardrobeCollectionFrame.ItemsCollectionFrame, nil, true)
    self:HideTexture(WardrobeCollectionFrame.ItemsCollectionFrame.BackgroundTile)
    self:HideTexture(WardrobeCollectionFrame.ItemsCollectionFrame.Bg)
    self:HideTexture(WardrobeCollectionFrame.ItemsCollectionFrame.ShadowLineTop)

    self:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.BackgroundTile)
    self:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.Bg)
    self:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.LeftInset.Bg)
    self:SetScrollBar(WardrobeCollectionFrame.SetsCollectionFrame.ListContainer)
    self:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.ShadowLineTop)
    self:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.BGCornerBottomRight)
    self:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.BGCornerBottomLeft)
    self:SetNineSlice(WardrobeCollectionFrame.SetsCollectionFrame.RightInset, nil, true)
    self:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.ShadowLineBottom)
    self:SetNineSlice(WardrobeCollectionFrame.SetsCollectionFrame.LeftInset, nil, true)

    self:SetSearchBox(WardrobeCollectionFrameSearchBox)
    self:SetAlphaColor(WardrobeCollectionFrameMiddleMiddle)
    self:SetAlphaColor(WardrobeCollectionFrameTopMiddle)
    self:SetAlphaColor(WardrobeCollectionFrameBottomMiddle)
    self:SetAlphaColor(WardrobeCollectionFrameTopMiddle)
    self:SetAlphaColor(WardrobeCollectionFrameMiddleLeft)
    self:SetAlphaColor(WardrobeCollectionFrameMiddleRight)
    self:SetAlphaColor(WardrobeCollectionFrameTopLeft)
    self:SetAlphaColor(WardrobeCollectionFrameBottomLeft)
    self:SetAlphaColor(WardrobeCollectionFrameBottomRight)
    self:SetAlphaColor(WardrobeCollectionFrameTopLeft)

    self:SetFrame(WardrobeCollectionFrame.FilterButton, {alpha=0.3})
    self:SetFrame(WardrobeSetsCollectionVariantSetsButton, {alpha=0.3})

    self:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.ModelFadeTexture)

    self:SetFrame(WardrobeCollectionFrameTab1, {notAlpha=true})
    self:SetFrame(WardrobeCollectionFrameTab2, {notAlpha=true})

    --试衣间
    self:SetNineSlice(WardrobeFrame, true)
    self:HideTexture(WardrobeFrameBg)
    self:HideTexture(WardrobeTransmogFrame.Inset.Bg)
    self:SetAlphaColor(WardrobeTransmogFrame.Inset.BG)
    self:HideTexture(WardrobeCollectionFrame.SetsTransmogFrame.BackgroundTile)
    self:SetNineSlice(WardrobeCollectionFrame.SetsTransmogFrame, nil, true)
    self:SetAlphaColor(WardrobeCollectionFrame.SetsTransmogFrame.Bg)


    self:SetAlphaColor(WardrobeTransmogFrame.MoneyMiddle)
    self:SetAlphaColor(WardrobeTransmogFrame.MoneyLeft)
    self:SetAlphaColor(WardrobeTransmogFrame.MoneyRight)

    hooksecurefunc(WardrobeCollectionFrame, 'SetTab', function(frame)
        local f= frame.activeFrame
        if f and f==frame.SetsTransmogFrame then
            for i=1, f.PAGE_SIZE or 8 do
                local btn= f.Models[i]
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
        self:SetFrame(_G['CollectionsJournalTab'..i], {notAlpha=true})
    end

    if _G['RematchJournal'] then
        self:SetNineSlice(_G['RematchJournal'], true)
        self:SetAlphaColor(_G['RematchJournalBg'])
        self:SetAlphaColor(RematchLoadoutPanel.Target.InsetBack)
        self:HideTexture(RematchPetPanel.Top.InsetBack)
        self:SetAlphaColor(RematchQueuePanel.List.Background.InsetBack)
        self:SetAlphaColor(RematchQueuePanel.Top.InsetBack)
        self:HideTexture(RematchPetPanel.Top.TypeBar.NineSlice)
        self:SetAlphaColor(RematchTeamPanel.List.Background.InsetBack)
        self:SetAlphaColor(RematchOptionPanel.List.Background.InsetBack)
        self:SetAlphaColor(RematchLoadoutPanel.TopLoadout.InsetBack)
    end


    if WarbandSceneJournal then--11.1
        self:HideTexture(WarbandSceneJournal.IconsFrame.BackgroundTile)
        self:HideTexture(WarbandSceneJournal.IconsFrame.Bg)
    end
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
    self:SetSearchBox(CalendarCreateEventTitleEdit)
    self:SetNineSlice(CalendarCreateEventDescriptionContainer, nil, nil, true)
    self:SetNineSlice(CalendarCreateEventInviteList, nil, nil, true)
    self:SetAlphaColor(CalendarCreateEventDivider, true)
    self:SetSearchBox(CalendarCreateEventInviteEdit)
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
    self:SetSearchBox(WeeklyRewardsFrame.HeaderFrame)
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






--宏
function WoWTools_TextureMixin.Events:Blizzard_MacroUI()
    self:SetFrame(MacroFrame, {notAlpha=true})
    self:SetNineSlice(MacroFrameInset, true)
    self:SetNineSlice(MacroFrame, true)
    self:SetNineSlice(MacroFrameTextBackground, true, nil, nil, true)
    self:HideTexture(MacroFrameBg)
    self:SetAlphaColor(MacroFrameInset.Bg)
    self:SetAlphaColor(MacroHorizontalBarLeft, true)
    self:HideTexture(MacroFrameSelectedMacroBackground)
    self:SetScrollBar(MacroFrame.MacroSelector)
    self:SetScrollBar(MacroFrame.NoteEditBox)
    self:SetScrollBar(MacroFrameScrollFrame)
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
        self:SetSearchBox(frame.Title)
    end)
end







--派系声望
function WoWTools_TextureMixin.Events:Blizzard_MajorFactions()
    self:SetAlphaColor(MajorFactionRenownFrame.Background)
    self:SetAlphaColor(MajorFactionRenownFrame.NineSlice, nil, nil, true)
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
    self:SetFrame(SettingsPanel.NineSlice, {alpha=0.5})
    self:SetAlphaColor(SettingsPanel.Bg, nil, nil, 0.5)
    self:SetScrollBar(SettingsPanel.Container.SettingsList)
    self:SetScrollBar(SettingsPanel.CategoryList)

    self:SetNineSlice(PingSystemTutorial, true)
    self:SetNineSlice(PingSystemTutorialInset, nil, true)

    self:HideTexture(PingSystemTutorialBg)

    self:SetFrame(SettingsPanel.GameTab, {notAlpha=true})
    self:SetFrame(SettingsPanel.AddOnsTab, {notAlpha=true})
    self:SetSearchBox(SettingsPanel.SearchBox)
    self:SetFrame(SettingsPanel, {index=1})
end





function WoWTools_TextureMixin.Events:Blizzard_CooldownViewer()
     hooksecurefunc(CooldownViewerBuffBarItemMixin, 'SetBarContent', function(frame)
        if not frame.Bar.isSetTexture then
            self:SetFrame(frame.Bar, {alpha=0.2, index=1})
            --[[for index, icon in pairs({frame.Bar:GetRegions()}) do
                if index==1 and icon:GetObjectType()=="Texture" then
                    icon:SetAtlas('UI-HUD-CoolDownManager-Bar')
                    icon:SetVertexColor(0.2, 0.2, 0.2, 0.5)
                    frame.Bar.isSetTexture =true
                    return
                end
            end]]
            frame.Bar.isSetTexture=true
        end
    end)
end
