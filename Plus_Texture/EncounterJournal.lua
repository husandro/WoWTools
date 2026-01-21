--冒险指南
function WoWTools_TextureMixin.Events:Blizzard_EncounterJournal()
    self:SetTabButton(EncounterJournalMonthlyActivitiesTab)
    self:SetNavBar(EncounterJournal)


    self:SetTabButton(EncounterJournalDungeonTab)
    self:SetTabButton(EncounterJournalRaidTab)
    self:SetTabButton(EncounterJournalLootJournalTab)

    self:HideTexture(EncounterJournal.TopTileStreaks)
    self:SetButton(EncounterJournalCloseButton)

    self:HideTexture(EncounterJournalBg)

    self:SetNineSlice(EncounterJournalInset)
    self:SetScrollBar(EncounterJournalInstanceSelect)
    self:SetEditBox(EncounterJournalSearchBox)
--推荐玩法
    self:SetButton(EncounterJournalSuggestFramePrevButton, {alpha=1})
    self:SetButton(EncounterJournalSuggestFrameNextButton, {alpha=1})

--团队副本
    --self:SetMenu(EncounterJournalInstanceSelect.ExpansionDropdown)

--首领，信息
    --self:HideFrame(EncounterJournalEncounterFrameInfo)

    --self:SetTabButton(EncounterJournalEncounterFrameInfoOverviewTab, 0.8)
    --self:SetTabButton(EncounterJournalEncounterFrameInfoLootTab, 0.8)
    --self:SetTabButton(EncounterJournalEncounterFrameInfoBossTab, 0.8)
    --self:SetTabButton(EncounterJournalEncounterFrameInfoModelTab, 0.8)
--Model
    self:HideTexture(EncounterJournalEncounterFrameInfoModelFrameShadow)
    self:SetAlphaColor(EncounterJournalEncounterFrameInfoModelFrameDungeonBG)
--BOSS, 掉落
    EncounterJournalEncounterFrameInfoClassFilterClearFrame:GetRegions():SetAlpha(0.5)--职业过滤，标题

    EncounterJournalEncounterFrameInfo.LootContainer.slotFilter:ClearAllPoints()
    EncounterJournalEncounterFrameInfo.LootContainer.slotFilter:SetPoint('RIGHT', EncounterJournalEncounterFrameInfoDifficulty, 'LEFT', -4, 0)
    EncounterJournalEncounterFrameInfo.LootContainer.filter:ClearAllPoints()
    EncounterJournalEncounterFrameInfo.LootContainer.filter:SetPoint('RIGHT', EncounterJournalEncounterFrameInfo.LootContainer.slotFilter, 'LEFT', -4, 0)


    self:SetScrollBar(EncounterJournalEncounterFrameInfo.LootContainer)
    WoWTools_DataMixin:Hook(EncounterJournalItemMixin,'Init', function(btn)
        if btn:IsVisible() and not btn.set_texture then
            btn.bosslessTexture:SetTexture(0)
            btn.bosslessTexture:SetPoint('RIGHT')
            btn.bossTexture:SetTexture(0)
            btn.armorType:SetPoint('RIGHT', -2, -8)
            btn.name:SetPoint('RIGHT')
            btn.name:SetTextColor(0,0,0)
            btn.set_texture= true
        end
    end)
--BOSS, 概述
    self:SetScrollBar(EncounterJournalEncounterFrameInfoOverviewScrollFrame)
--BOSS, 技能
    self:SetScrollBar(EncounterJournalEncounterFrameInfoDetailsScrollFrame)

--BOSS, 列表
    self:HideTexture(EncounterJournalEncounterFrameInfoLeftHeaderShadow)
    self:HideTexture(EncounterJournalEncounterFrameInfoRightHeaderShadow)
    self:SetScrollBar(EncounterJournalEncounterFrameInfo.BossesScrollBar)
    WoWTools_DataMixin:Hook(EncounterBossButtonMixin, 'Init', function(btn)
        btn:GetRegions():SetAlpha(0.5)
        btn.text:SetTextColor(1, 0.88, 0.68)
    end)
--副本信息
    self:SetScrollBar(EncounterJournalEncounterFrameInstanceFrame.LoreScrollBar)

--套装
    self:SetScrollBar(EncounterJournal.LootJournal)
    self:SetScrollBar(EncounterJournal.LootJournalItems.ItemSetsFrame)
    self:HideFrame(EncounterJournal.LootJournalItems)
--重新设置专精，位置
    self:SetMenu(EncounterJournal.LootJournalItems.ItemSetsFrame.ClassDropdown)
    EncounterJournal.LootJournalItems.ItemSetsFrame.ClassDropdown:ClearAllPoints()
    EncounterJournal.LootJournalItems.ItemSetsFrame.ClassDropdown:SetPoint(
        'TOPRIGHT',
        EncounterJournalInstanceSelect.ExpansionDropdown,
        'BOTTOMRIGHT',
        0, 2
    )
    self:HideFrame(EncounterJournal.LootJournalItems.ItemSetsFrame)

--套装,按钮
    WoWTools_DataMixin:Hook(LootJournalItemSetButtonMixin, 'Init', function(btn)
        btn.Background:SetAtlas('timerunning-TopHUD-button-glow')
        btn.Background:SetAlpha(0.5)
    end)

--暗影国度 暗影之力
    self:HideFrame(EncounterJournal.LootJournal, {index=1})

--旅行者日志
    self:HideFrame(EncounterJournalMonthlyActivitiesFrame)
    self:SetScrollBar(EncounterJournalMonthlyActivitiesFrame)
    --EncounterJournalMonthlyActivitiesFrame.FilterList.Bg:SetColorTexture(0,0,0,0.3)
    self:SetScrollBar(EncounterJournalMonthlyActivitiesFrame.FilterList)
    self:HideTexture(EncounterJournalMonthlyActivitiesFrame.ThresholdContainer.BarBackground)
    self:SetAlphaColor(EncounterJournalMonthlyActivitiesFrame.ThresholdContainer.BarBorder, nil, nil, 0.3)
    self:SetButton(EncounterJournalMonthlyActivitiesFrame.HelpButton)
--任务，右边列表，按钮
    WoWTools_DataMixin:Hook(MonthlyActivitiesButtonMixin, 'UpdateDesaturatedShared', function(btn)
        local data = btn:GetData()
        local alpha = data and data.completed and 0.1 or 0.5
        btn.NormalTexture:SetAlpha(alpha)
        btn.HighlightTexture:SetAlpha(alpha)
    end)

    self:SetButton(EncounterJournalInstanceSelect.GreatVaultButton, {alpha=1})

--旅程 12.0才有

    self:SetButton(EncounterJournalJourneysFrame.JourneyProgress.OverviewBtn, {alpha=1})
    self:SetScrollBar(EncounterJournalJourneysFrame)
    self:SetAlphaColor(EncounterJournalJourneysFrame.JourneyOverview.DividerTexture, nil, nil, true)
    --self:SetAlphaColor(EncounterJournalJourneysFrame.JourneyProgress.ProgressDetailsFrame.JourneyLevelBar, nil, nil, 0.3)
    self:SetAlphaColor(EncounterJournalJourneysFrame.JourneyProgress.ProgressDetailsFrame.JourneyLevelBg, true)










    self:Init_BGMenu_Frame(EncounterJournal, {
    settings= function(_, textureName, alphaValue)
        local alpha= textureName and 0 or alphaValue or 1
        EncounterJournalInstanceSelectBG:SetAlpha(alpha)
        EncounterJournalInset.Bg:SetAlpha(alpha)

--副本列表 12.0才有
        EncounterJournalJourneysFrame.BorderFrame.Border:SetAlpha(alpha)
        EncounterJournalJourneysFrame.BorderFrame.TopDetail:SetAlpha(alpha)
        EncounterJournalInstanceSelect.evergreenBg:SetAlpha(alpha)
    end})
end