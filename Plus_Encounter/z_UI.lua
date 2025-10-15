

--[[冒险指南
EncounterJournal.encounter.info == EncounterJournalEncounterFrameInfo
EncounterJournal.encounter.info.BossesScrollBox == EncounterJournalEncounterFrameInfo.BossesScrollBox

EncounterJournal.encounter.info.detailsScroll == EncounterJournalEncounterFrameInfoDetailsScrollFrame
EncounterJournal.encounter.infoFrame ==          EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollChild

EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollChild

EncounterJournal.encounter.overviewFrame == EncounterJournal.encounter.info.overviewScroll.child
EncounterJournal.encounter.overviewFrame == EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChild

]]

function WoWTools_MoveMixin.Events:Blizzard_EncounterJournal()
    local s
--旅行者日志
    EncounterJournalMonthlyActivitiesFrame.ThemeContainer.Top:SetPoint('LEFT')
    EncounterJournalMonthlyActivitiesFrame.ThemeContainer.Top:SetPoint('RIGHT')
    EncounterJournalMonthlyActivitiesFrame.ThemeContainer.Bottom:SetPoint('LEFT')
    EncounterJournalMonthlyActivitiesFrame.ThemeContainer.Bottom:SetPoint('RIGHT')
--旅行者日志,右边，列表
    WoWTools_DataMixin:Hook(MonthlyActivitiesButtonMixin, 'Init', function(btn)
        btn.TextContainer:SetPoint('RIGHT', -36, 0)
        btn.TextContainer.ConditionsText:SetPoint('RIGHT')
        btn.TextContainer.NameText:SetPoint('RIGHT')
    end)
--旅行，点数
    --EncounterJournalMonthlyActivitiesFrame.ThresholdContainer:SetPoint('RIGHT', -46-50 ,0)

    C_Timer.After(0.3, function()
        EncounterJournalMonthlyActivitiesFrame.FilterList:SetPoint('BOTTOMLEFT', 225, 5)--<Anchor point="TOPLEFT" x="5" y="-137"/>
    end)

    EncounterJournalMonthlyActivitiesFrame.ScrollBox:SetPoint('BOTTOMLEFT', EncounterJournalMonthlyActivitiesFrame.FilterList, 'BOTTOMRIGHT', 25, 0)
    EncounterJournalMonthlyActivitiesFrame.DividerVertical:SetPoint('BOTTOM')
    EncounterJournalMonthlyActivitiesFrame.Divider:SetPoint('RIGHT')
    EncounterJournalMonthlyActivitiesFrame.Divider:SetPoint('LEFT')

--instanceSelect
    EncounterJournalInstanceSelectBG:SetPoint('BOTTOMRIGHT', 0,2)
    EncounterJournalInstanceSelect.ScrollBox:SetPoint('BOTTOMRIGHT', 0, 15)
    EncounterJournalInstanceSelect.ScrollBar:ClearAllPoints()
    EncounterJournalInstanceSelect.ScrollBar:SetPoint('TOPRIGHT', EncounterJournalInstanceSelect.ScrollBox, 0 ,-6)
    EncounterJournalInstanceSelect.ScrollBar:SetPoint('BOTTOMRIGHT', EncounterJournalInstanceSelect.ScrollBox, 0 , 6)
    EncounterJournalInstanceSelect.ScrollBox:HookScript('OnSizeChanged', function(frame) --EncounterInstanceButtonTemplate Size x="174" y="96"
        local spacing= frame.view:GetHorizontalSpacing()--15
        local value= frame:GetWidth() / (174+ spacing)
        value= math.max(1, math.modf(value))
        if frame.view:GetStride()~= value then
            frame.view:SetStride(value)
            if frame:IsVisible() then
                WoWTools_DataMixin:Call(EncounterJournal_ListInstances)
            end
        end
    end)

--推荐玩法 suggestFrame.Suggestion1
    EncounterJournal.suggestFrame.Suggestion1:SetPoint('BOTTOMRIGHT', EncounterJournal.suggestFrame, 'BOTTOM', -14, 28)
    EncounterJournalSuggestFrame.Suggestion2:SetPoint('TOPLEFT', EncounterJournalSuggestFrame.Suggestion1, 'TOPRIGHT', 14, 0)
    EncounterJournalSuggestFrame.Suggestion2:SetPoint('BOTTOMRIGHT', EncounterJournal.suggestFrame, 'RIGHT', -28, 0)
    EncounterJournalSuggestFrame.Suggestion3:SetPoint('BOTTOMRIGHT', EncounterJournalSuggestFrame, -28, 28)

    s= EncounterJournal.suggestFrame.Suggestion1.centerDisplay
    s:ClearAllPoints()
    s:SetPoint('TOPLEFT', 24, -24)
    s:SetPoint('BOTTOMRIGHT', -24, 24)
    s.title:ClearAllPoints()
    s.title:SetPoint('BOTTOMLEFT', s, 'LEFT')
    s.title:SetPoint('BOTTOMRIGHT', s, 'RIGHT')
    s.title.text:SetAllPoints(s.title)
    s.description:ClearAllPoints()
    s.description:SetPoint('TOPLEFT', s.title, 'BOTTOMLEFT', 10, -2)
    s.description:SetPoint('TOPRIGHT', s.title, 'BOTTOMRIGHT', -10, -2)
    s.description:SetPoint('BOTTOM', EncounterJournal.suggestFrame.Suggestion1.reward.text, 'TOP', 0, 2)
    s.description.text:ClearAllPoints()
    s.description.text:SetAllPoints(s.description)

    for i=2, 3 do
        s= EncounterJournalSuggestFrame['Suggestion'..i].centerDisplay
        s:SetPoint('RIGHT', -70, 0)
        s.title:SetPoint('RIGHT')
        s.title.text:SetAllPoints(s.title)
        s.description:SetPoint('RIGHT')
        s.description.text:ClearAllPoints()
        s.description.text:SetAllPoints(s.description)
        s.button:ClearAllPoints()
        s.button:SetPoint('TOP', s.description, 'BOTTOM', 0, -2)
    end


--物品
    s= EncounterJournal.LootJournalItems:GetRegions()
    if s:GetObjectType()=='Texture' then
        s:SetAllPoints()
    end
    EncounterJournal.LootJournalItems.ItemSetsFrame:SetPoint('TOPRIGHT', -22, -10)
    for _, region in pairs({EncounterJournal.LootJournalItems:GetRegions()}) do
        if region:GetObjectType()=='Texture' then
            region:SetPoint('BOTTOM')
            break
        end
    end
    EncounterJournal.LootJournal.ScrollBox:SetPoint('TOPLEFT', 20, -51)
    for _, region in pairs({EncounterJournal.LootJournal:GetRegions()}) do
        if region:GetObjectType()=='Texture' then
            region:SetPoint('BOTTOM')
            break
        end
    end

--副本，信息
    EncounterJournal.encounter.info:ClearAllPoints()
    EncounterJournal.encounter.info:SetPoint('TOPLEFT', 2, 2)
    EncounterJournal.encounter.info:SetPoint('BOTTOMRIGHT', 2, -2)
    EncounterJournalEncounterFrameInfoBG:SetPoint('TOPLEFT')
--BOSS 列表
    EncounterJournal.encounter.info.BossesScrollBox:SetPoint('TOP', 0, -35)
    EncounterJournal.encounter.info.BossesScrollBox:SetPoint('BOTTOMRIGHT', EncounterJournal.encounter.info, 'BOTTOM', -35, 35)
    WoWTools_DataMixin:Hook(EncounterBossButtonMixin, 'Init', function(btn)
        btn.text:SetPoint('RIGHT', -3, 0)
    end)
--副本，概述
    s= EncounterJournalEncounterFrameInstanceFrame--EncounterJournal.encounter.instance
    s:SetPoint('TOPLEFT', EncounterJournal.encounter.info.BossesScrollBox, 'TOPRIGHT')
    s:SetPoint('BOTTOMRIGHT')
--副本，图片
    EncounterJournalEncounterFrameInstanceFrameBG:SetPoint('LEFT', 55, 0)
    EncounterJournalEncounterFrameInstanceFrameBG:SetPoint('BOTTOMRIGHT', s, 'RIGHT', -15, -35)
--名称
    s.title:ClearAllPoints()
    s.title:SetPoint('TOP',EncounterJournalEncounterFrameInstanceFrameBG, 0, -15)
    s.titleBG:ClearAllPoints()
    s.titleBG:SetPoint('CENTER', s.title, 0, -15)
--副本，按钮
    EncounterJournalEncounterFrameInstanceFrameMapButton:ClearAllPoints()
    EncounterJournalEncounterFrameInstanceFrameMapButton:SetPoint('BOTTOMLEFT', EncounterJournalEncounterFrameInstanceFrameBG, 20, 20)
--副本，概述，文本
    s.LoreScrollingFont:ClearAllPoints()
    s.LoreScrollingFont:SetPoint('TOPLEFT', EncounterJournalEncounterFrameInstanceFrameBG, 'BOTTOMLEFT', 23, 5)
    s.LoreScrollingFont:SetPoint('BOTTOMRIGHT', -23, 5)

--BOSS, 掉落
    EncounterJournal.encounter.info.LootContainer:SetPoint('TOPLEFT', EncounterJournal.encounter.info, 'TOP', 30, -43)
    WoWTools_DataMixin:Hook(EncounterJournalItemMixin,'Init', function(btn)
        if btn:IsVisible() and not btn.set_texture then--btn.set_texture z_Events.lua Plus_Texture
            btn.name:SetPoint('RIGHT')
            btn.armorType:ClearAllPoints()
            btn.armorType:SetPoint('RIGHT', -2, -8)
        end
    end)

--BOSS, 概述
    EncounterJournalEncounterFrameInfoOverviewScrollFrame:SetPoint('TOPLEFT', EncounterJournal.encounter.info, 'TOP', 30, -43)
    EncounterJournal.encounter.overviewFrame:SetPoint('LEFT', 23, 0)
    EncounterJournal.encounter.overviewFrame:HookScript('OnSizeChanged', function(f)
        f:SetPoint('RIGHT', -23, 0)
    end)

--综述
    --[[
    <Frame parentKey="overviewDescription" inherits="EncounterDescriptionTemplate">
        <Size x="95" y="10"/>
        <Anchors>
            <Anchor point="TOP" relativeKey="$parent.header" relativePoint="BOTTOM" x="0" y="-6"/>
        </Anchors>
    </Frame>
    ]]



    EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChild.overviewDescription:SetPoint('RIGHT', 10, 0)
    EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildLoreDescription:SetPoint('RIGHT', 10, 0)
    EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildHeader:SetPoint('LEFT')
    EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildHeader:SetPoint('RIGHT', -23, 0)

--技能
    EncounterJournal.encounter.info.detailsScroll:SetPoint('TOPLEFT', EncounterJournal.encounter.info, 'TOP', 30, -43)
    EncounterJournal.encounter.info.detailsScroll.child:SetPoint('RIGHT', -23, 0)
    EncounterJournal.encounter.info.detailsScroll.child:HookScript('OnSizeChanged', function(f)
        f:SetPoint('RIGHT', -23, 0)
    end)

--模型
    EncounterJournalEncounterFrameInfoModelFrame:SetPoint('TOPLEFT', EncounterJournal.encounter.info, 'TOP')
    EncounterJournalEncounterFrameInfoModelFrameDungeonBG:SetPoint('TOPRIGHT', 0, -2)
    EncounterJournalEncounterFrameInfoModelFrameShadow:SetPoint('TOPLEFT', 0, -2)

    self:Setup(EncounterJournal, {
    minW=400,--800,
    minH=248,--496,
    sizeRestFunc=function()
        EncounterJournal:SetSize(800, 496)
    end})

    self:Setup(EncounterJournalInstanceSelect.ScrollBox, {frame=EncounterJournal})
end




























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
    self:HideTexture(EncounterJournalInset.Bg)
    self:SetNineSlice(EncounterJournalInset)
    self:SetScrollBar(EncounterJournalInstanceSelect)
    self:SetEditBox(EncounterJournalSearchBox)

--团队副本
    --self:SetMenu(EncounterJournalInstanceSelect.ExpansionDropdown)

--首领，信息
    --self:HideFrame(EncounterJournalEncounterFrameInfo)
    self:SetTabButton(EncounterJournalEncounterFrameInfoOverviewTab, 0.8)
    self:SetTabButton(EncounterJournalEncounterFrameInfoLootTab, 0.8)
    self:SetTabButton(EncounterJournalEncounterFrameInfoBossTab, 0.8)
    self:SetTabButton(EncounterJournalEncounterFrameInfoModelTab, 0.8)
--Model
    self:HideTexture(EncounterJournalEncounterFrameInfoModelFrameShadow)
    self:SetAlphaColor(EncounterJournalEncounterFrameInfoModelFrameDungeonBG)
--BOSS, 掉落
    EncounterJournalEncounterFrameInfoClassFilterClearFrame:GetRegions():SetAlpha(0.5)--职业过滤，标题

    if EncounterJournalEncounterFrameInfo.LootContainer then--11.2.5
        --self:SetMenu(EncounterJournalEncounterFrameInfoDifficulty)
        EncounterJournalEncounterFrameInfo.LootContainer.slotFilter:ClearAllPoints()
        EncounterJournalEncounterFrameInfo.LootContainer.slotFilter:SetPoint('RIGHT', EncounterJournalEncounterFrameInfoDifficulty, 'LEFT', -4, 0)
        EncounterJournalEncounterFrameInfo.LootContainer.filter:ClearAllPoints()
        EncounterJournalEncounterFrameInfo.LootContainer.filter:SetPoint('RIGHT', EncounterJournalEncounterFrameInfo.LootContainer.slotFilter, 'LEFT', -4, 0)
        --self:SetMenu(EncounterJournalEncounterFrameInfo.LootContainer.slotFilter)
        --self:SetMenu(EncounterJournalEncounterFrameInfo.LootContainer.filter)
    end

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
    end)
--副本信息
    self:SetScrollBar(EncounterJournalEncounterFrameInstanceFrame.LoreScrollBar)
--副本列表
    EncounterJournalInstanceSelectBG:SetAlpha(0)
--套装
    self:SetScrollBar(EncounterJournal.LootJournal)
    self:SetScrollBar(EncounterJournal.LootJournalItems.ItemSetsFrame)
    self:HideFrame(EncounterJournal.LootJournalItems)
--重新设置专精，位置
    --self:SetMenu(EncounterJournal.LootJournalItems.ItemSetsFrame.ClassDropdown)
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
        btn.Background:SetAlpha(0.5)
        btn.Background:SetAtlas('timerunning-TopHUD-button-glow')
    end)

    self:HideFrame(EncounterJournalMonthlyActivitiesFrame)
    self:SetScrollBar(EncounterJournalMonthlyActivitiesFrame)
    self:SetScrollBar(EncounterJournalMonthlyActivitiesFrame.FilterList)


--旅行者日志
    EncounterJournalMonthlyActivitiesFrame.FilterList.Bg:SetColorTexture(0,0,0,0.3)
--任务，右边列表，按钮
    WoWTools_DataMixin:Hook(MonthlyActivitiesButtonMixin, 'UpdateDesaturatedShared', function(btn)
        local data = btn:GetData()
        local alpha = data and data.completed and 0.1 or 0.5
        btn.NormalTexture:SetAlpha(alpha)
        btn.HighlightTexture:SetAlpha(alpha)
    end)
    self:HideTexture(EncounterJournalMonthlyActivitiesFrame.ThresholdContainer.BarBackground)
    self:SetAlphaColor(EncounterJournalMonthlyActivitiesFrame.ThresholdContainer.BarBorder, nil, nil, 0.3)

    self:SetButton(EncounterJournalMonthlyActivitiesFrame.HelpButton)
    self:Init_BGMenu_Frame(EncounterJournal)
end

