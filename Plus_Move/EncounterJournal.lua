--[[
EncounterJournalEncounterFrameInfo
EncounterJournal.encounter.info

EncounterJournalEncounterFrameInstanceFrame
EncounterJournal.encounter.instance

EncounterJournalSuggestFrame.Suggestion1
EncounterJournal.suggestFrame.Suggestion1
]]

function WoWTools_MoveMixin.Events:Blizzard_EncounterJournal()
    local icon

    EncounterJournalMonthlyActivitiesFrame.RestrictedText:ClearAllPoints()
    EncounterJournalMonthlyActivitiesFrame.RestrictedText:SetPoint('CENTER', EncounterJournalMonthlyActivitiesFrame.ThresholdContainer)
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
    EncounterJournalMonthlyActivitiesFrame.ThresholdContainer:SetPoint('RIGHT', -46-50 ,0)

    EncounterJournalMonthlyActivitiesFrame.ThresholdContainer.BarBackground:ClearAllPoints()
    EncounterJournalMonthlyActivitiesFrame.ThresholdContainer.BarBackground:SetAllPoints()
    EncounterJournalMonthlyActivitiesFrame.ThresholdContainer.BarBackgroundGlow:ClearAllPoints()
    EncounterJournalMonthlyActivitiesFrame.ThresholdContainer.BarBackgroundGlow:SetAllPoints()
    EncounterJournalMonthlyActivitiesFrame.ThresholdContainer.BarBorder:ClearAllPoints()
    EncounterJournalMonthlyActivitiesFrame.ThresholdContainer.BarBorder:SetAllPoints()
    EncounterJournalMonthlyActivitiesFrame.ThresholdContainer.BarBorderGlow:ClearAllPoints()
    EncounterJournalMonthlyActivitiesFrame.ThresholdContainer.BarBorderGlow:SetAllPoints()


    C_Timer.After(0.3, function()
        EncounterJournalMonthlyActivitiesFrame.FilterList:SetPoint('BOTTOMLEFT', 225, 5)--<Anchor point="TOPLEFT" x="5" y="-137"/>
    end)

    EncounterJournalMonthlyActivitiesFrame.ScrollBox:SetPoint('BOTTOMLEFT', EncounterJournalMonthlyActivitiesFrame.FilterList, 'BOTTOMRIGHT', 25, 0)
    EncounterJournalMonthlyActivitiesFrame.DividerVertical:SetPoint('BOTTOM')
    EncounterJournalMonthlyActivitiesFrame.Divider:SetPoint('RIGHT')
    EncounterJournalMonthlyActivitiesFrame.Divider:SetPoint('LEFT')



--推荐玩法 suggestFrame.Suggestion1
    EncounterJournalSuggestFrame.Suggestion1:SetPoint('BOTTOMRIGHT', EncounterJournalSuggestFrame, 'BOTTOM', -14, 28)
    EncounterJournalSuggestFrame.Suggestion2:SetPoint('TOPLEFT', EncounterJournalSuggestFrame.Suggestion1, 'TOPRIGHT', 14, 0)
    EncounterJournalSuggestFrame.Suggestion2:SetPoint('BOTTOMRIGHT', EncounterJournalSuggestFrame, 'RIGHT', -28, 0)
    EncounterJournalSuggestFrame.Suggestion3:SetPoint('BOTTOMRIGHT', EncounterJournalSuggestFrame, -28, 28)


    EncounterJournalSuggestFrame.Suggestion1.centerDisplay:ClearAllPoints()
    EncounterJournalSuggestFrame.Suggestion1.centerDisplay:SetPoint('TOPLEFT', 24, -24)
    EncounterJournalSuggestFrame.Suggestion1.centerDisplay:SetPoint('BOTTOMRIGHT', -24, 24)
    EncounterJournalSuggestFrame.Suggestion1.centerDisplay.title:ClearAllPoints()
    EncounterJournalSuggestFrame.Suggestion1.centerDisplay.title:SetPoint('BOTTOMLEFT', EncounterJournalSuggestFrame.Suggestion1.centerDisplay, 'LEFT')
    EncounterJournalSuggestFrame.Suggestion1.centerDisplay.title:SetPoint('BOTTOMRIGHT', EncounterJournalSuggestFrame.Suggestion1.centerDisplay, 'RIGHT')
    EncounterJournalSuggestFrame.Suggestion1.centerDisplay.title.text:SetAllPoints(EncounterJournalSuggestFrame.Suggestion1.centerDisplay.title)
    EncounterJournalSuggestFrame.Suggestion1.centerDisplay.description:ClearAllPoints()
    EncounterJournalSuggestFrame.Suggestion1.centerDisplay.description:SetPoint('TOPLEFT', EncounterJournalSuggestFrame.Suggestion1.centerDisplay.title, 'BOTTOMLEFT', 10, -2)
    EncounterJournalSuggestFrame.Suggestion1.centerDisplay.description:SetPoint('TOPRIGHT', EncounterJournalSuggestFrame.Suggestion1.centerDisplay.title, 'BOTTOMRIGHT', -10, -2)
    EncounterJournalSuggestFrame.Suggestion1.centerDisplay.description:SetPoint('BOTTOM', EncounterJournalSuggestFrame.Suggestion1.reward.text, 'TOP', 0, 2)
    EncounterJournalSuggestFrame.Suggestion1.centerDisplay.description.text:ClearAllPoints()
    EncounterJournalSuggestFrame.Suggestion1.centerDisplay.description.text:SetAllPoints(EncounterJournalSuggestFrame.Suggestion1.centerDisplay.description)

    for i=2, 3 do
        local s= EncounterJournalSuggestFrame['Suggestion'..i].centerDisplay
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

    icon= EncounterJournal.LootJournalItems:GetRegions()
    if icon and icon:IsObjectType('Texture') then
        icon:SetAllPoints()
    end
    EncounterJournal.LootJournalItems.ItemSetsFrame:SetPoint('TOPRIGHT', -22, -10)
    for _, region in pairs({EncounterJournal.LootJournalItems:GetRegions()}) do
        if region:IsObjectType('Texture') then
            region:SetPoint('BOTTOM')
            break
        end
    end
    
    EncounterJournal.LootJournal.ScrollBox:SetPoint('TOPLEFT', 20, -51)
    EncounterJournal.LootJournal.ScrollBox:SetPoint('RIGHT', -20, 0)

    for _, region in pairs({EncounterJournal.LootJournal:GetRegions()}) do
        if region:IsObjectType('Texture') then
            region:SetPoint('BOTTOM')
            break
        end
    end

--暗影国度 暗影之力
    icon= EncounterJournal.LootJournal:GetRegions()
    if icon and icon:IsObjectType('Texture') then
        icon:SetAllPoints()
    end

--副本，信息 EncounterJournalEncounterFrameInfo
    EncounterJournalEncounterFrameInfo:ClearAllPoints()
    EncounterJournalEncounterFrameInfo:SetPoint('TOPLEFT', 2, 2)
    EncounterJournalEncounterFrameInfo:SetPoint('BOTTOMRIGHT', 2, -2)
    EncounterJournalEncounterFrameInfoBG:SetPoint('TOPLEFT')
--BOSS 列表
    EncounterJournalEncounterFrameInfo.BossesScrollBox:SetPoint('TOP', 0, -35)
    EncounterJournalEncounterFrameInfo.BossesScrollBox:SetPoint('BOTTOMRIGHT', EncounterJournalEncounterFrameInfo, 'BOTTOM', -35, 35)
    WoWTools_DataMixin:Hook(EncounterBossButtonMixin, 'Init', function(btn)
        btn.text:SetPoint('RIGHT', -3, 0)
    end)
--副本，概述
    EncounterJournalEncounterFrameInstanceFrame:SetPoint('TOPLEFT', EncounterJournalEncounterFrameInfo.BossesScrollBox, 'TOPRIGHT')
    EncounterJournalEncounterFrameInstanceFrame.LoreScrollingFont:SetPoint('BOTTOMRIGHT')
--副本，图片
    EncounterJournalEncounterFrameInstanceFrameBG:SetPoint('LEFT', 55, 0)
    EncounterJournalEncounterFrameInstanceFrameBG:SetPoint('BOTTOMRIGHT', EncounterJournalEncounterFrameInstanceFrame, 'RIGHT', -15, -35)
--名称
    EncounterJournalEncounterFrameInstanceFrame.title:ClearAllPoints()
    EncounterJournalEncounterFrameInstanceFrame.title:SetPoint('TOP', EncounterJournalEncounterFrameInstanceFrameBG, 0, -15)
    EncounterJournalEncounterFrameInstanceFrame.titleBG:ClearAllPoints()
    EncounterJournalEncounterFrameInstanceFrame.titleBG:SetPoint('CENTER', EncounterJournalEncounterFrameInstanceFrame.title, 0, -15)
--副本，按钮
    EncounterJournalEncounterFrameInstanceFrameMapButton:ClearAllPoints()
    EncounterJournalEncounterFrameInstanceFrameMapButton:SetPoint('BOTTOMLEFT', EncounterJournalEncounterFrameInstanceFrameBG, 20, 20)
--副本，概述，文本
    EncounterJournalEncounterFrameInstanceFrame.LoreScrollingFont:ClearAllPoints()
    EncounterJournalEncounterFrameInstanceFrame.LoreScrollingFont:SetPoint('TOPLEFT', EncounterJournalEncounterFrameInstanceFrameBG, 'BOTTOMLEFT', 23, 5)
    EncounterJournalEncounterFrameInstanceFrame.LoreScrollingFont:SetPoint('BOTTOMRIGHT', -23, 5)

 --Boss, 战利品, 物品信息, 职业过滤
    EncounterJournalEncounterFrameInfoClassFilterClearFrame:SetPoint('RIGHT')
    EncounterJournalEncounterFrameInfoClassFilterClearFrame:SetPoint('LEFT')
    icon= EncounterJournalEncounterFrameInfoClassFilterClearFrame:GetRegions()
    if icon and icon:IsObjectType('Texture') then
        icon:SetPoint('RIGHT')
        icon:SetPoint('LEFT')
    end

--BOSS, 掉落
    EncounterJournalEncounterFrameInfo.LootContainer:SetPoint('TOPLEFT', EncounterJournalEncounterFrameInfo, 'TOP', 40, -43)
    WoWTools_DataMixin:Hook(EncounterJournalItemMixin,'Init', function(btn)
        if btn:IsVisible() and not btn.set_texture then--btn.set_texture z_Events.lua Plus_Texture
            btn.name:SetPoint('RIGHT')
            btn.armorType:ClearAllPoints()
            btn.armorType:SetPoint('RIGHT', -2, -8)
        end
    end)



--BOSS, 概述
    EncounterJournalEncounterFrameInfoOverviewScrollFrame:SetPoint('TOPLEFT', EncounterJournalEncounterFrameInfo, 'TOP', 30, -43)
    EncounterJournal.encounter.overviewFrame:SetPoint('LEFT', 23, 0)
    EncounterJournal.encounter.overviewFrame:HookScript('OnSizeChanged', function(f)
        f:SetPoint('RIGHT', -23, 0)
    end)


--综述,Boss信息
    EncounterJournalEncounterFrameInfo.encounterTitle:ClearAllPoints()
    EncounterJournalEncounterFrameInfo.encounterTitle:SetPoint('BOTTOMLEFT', EncounterJournalEncounterFrameInfoOverviewScrollFrame, 'TOPLEFT', 10, 10)
    EncounterJournalEncounterFrameInfo.encounterTitle:SetPoint('RIGHT', EncounterJournalEncounterFrameInfoDifficulty, 'LEFT')
    EncounterJournalEncounterFrameInfo.encounterTitle:SetJustifyH('CENTER')


--综述
    EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChild.overviewDescription:SetPoint('RIGHT', 10, 0)
    EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildLoreDescription:SetPoint('RIGHT', 10, 0)
    EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildHeader:SetPoint('LEFT')
    EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildHeader:SetPoint('RIGHT', -23, 0)

--技能
    EncounterJournalEncounterFrameInfo.detailsScroll:SetPoint('TOPLEFT', EncounterJournalEncounterFrameInfo, 'TOP', 30, -43)
    EncounterJournalEncounterFrameInfo.detailsScroll.child:SetPoint('RIGHT', -23, 0)
    EncounterJournalEncounterFrameInfo.detailsScroll.child:HookScript('OnSizeChanged', function(f)
        f:SetPoint('RIGHT', -23, 0)
    end)

--模型
    EncounterJournalEncounterFrameInfoModelFrame:SetPoint('TOPLEFT', EncounterJournalEncounterFrameInfo, 'TOP')
    EncounterJournalEncounterFrameInfoModelFrameDungeonBG:SetPoint('TOPRIGHT', 0, -2)
    EncounterJournalEncounterFrameInfoModelFrameShadow:SetPoint('TOPLEFT', 0, -2)

--instanceSelect
    EncounterJournalInstanceSelectBG:SetPoint('BOTTOMRIGHT', 0,2)
    if EncounterJournalInstanceSelect.evergreenBg then
        EncounterJournalInstanceSelect.evergreenBg:SetPoint('BOTTOMRIGHT')
    end
    EncounterJournalInstanceSelect.ScrollBox:SetPoint('BOTTOMRIGHT', 0, 15)
    EncounterJournalInstanceSelect.ScrollBar:ClearAllPoints()
    EncounterJournalInstanceSelect.ScrollBar:SetPoint('TOPRIGHT', EncounterJournalInstanceSelect.ScrollBox, 0 ,-6)
    EncounterJournalInstanceSelect.ScrollBar:SetPoint('BOTTOMRIGHT', EncounterJournalInstanceSelect.ScrollBox, 0 , 6)

    local function Set_InstanceSelect_Stride()
        local frame= EncounterJournalInstanceSelect.ScrollBox
        local spacing= frame.view:GetHorizontalSpacing() or 15
        local value= frame:GetWidth() / (174+ spacing)
        value= math.max(1, math.modf(value))
        if frame.view:GetStride()~= value then
            frame.view:SetStride(value)
            --if frame:IsVisible() then
                --WoWTools_DataMixin:Call('EncounterJournal_ListInstances')
            --end
        end

        frame= EncounterJournal.LootJournal.ScrollBox
        spacing= frame.view:GetHorizontalSpacing() or 15
        value= frame:GetWidth() / (325+ spacing)
        value= math.max(2, math.modf(value))
        if frame.view:GetStride()~= value then
            frame.view:SetStride(value)
            --if frame:IsVisible() then
                --WoWTools_DataMixin:Call('EncounterJournal_ListInstances')
            --end
        end
    end
    --EncounterJournalInstanceSelect.ScrollBox:HookScript('OnSizeChanged', Set_InstanceSelect_Stride) --EncounterInstanceButtonTemplate Size x="174" y="96"


    self:Setup(EncounterJournal, {
        minW=400,--800,
        minH=248,--496,
    sizeStopFunc= function(frame)
        Set_InstanceSelect_Stride()
        self:Save().size[frame:GetName()]= {frame:GetSize()}
    end,
    sizeRestFunc=function(f)
        f:SetSize(800, 496)
    end})

    --self:Setup(EncounterJournalInstanceSelect.ScrollBox, {frame=EncounterJournal})


    if EncounterJournal.TutorialsFrame then--11.2.7才有
        icon= EncounterJournal.TutorialsFrame.Contents:GetRegions()
        if icon and icon:IsObjectType('Texture') then
            icon:SetPoint('BOTTOMRIGHT', -27, 27)
        end
    end


    Set_InstanceSelect_Stride()

    icon= nil
end