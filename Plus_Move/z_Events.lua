local function Save()
    return WoWToolsSave['Plus_Move']
end
--[[
/dump WoWTools_MoveMixin.Events.Blizzard_EncounterJournal(WoWTools_MoveMixin)
]]








--专业训练师
function WoWTools_MoveMixin.Events:Blizzard_TrainerUI()
    ClassTrainerFrame.ScrollBox:ClearAllPoints()
    ClassTrainerFrame.ScrollBox:SetPoint('BOTTOMRIGHT', -26, 34)
    ClassTrainerFrameSkillStepButton:SetPoint('RIGHT', -12, 0)
    ClassTrainerFrameBottomInset:SetPoint('BOTTOMRIGHT', -4, 28)
    hooksecurefunc('ClassTrainerFrame_Update', function()--Blizzard_TrainerUI.lua
        ClassTrainerFrame.ScrollBox:SetPoint('BOTTOMRIGHT', -26, 34)
    end)
    self:Setup(ClassTrainerFrame, {
        minW=200,--328,
        minH=197,
        setSize=true,
        sizeRestFunc=function(btn)
            ClassTrainerFrame:SetSize(338, 424)
        end}
    )
end

--小时图，时间
function WoWTools_MoveMixin.Events:Blizzard_TimeManager()
    self:Setup(TimeManagerFrame, {save=true})
end

--黑市
function WoWTools_MoveMixin.Events:Blizzard_BlackMarketUI()
    self:Setup(BlackMarketFrame)
end

--日历
function WoWTools_MoveMixin.Events:Blizzard_Calendar()
    self:Setup(CalendarFrame)
    self:Setup(CalendarEventPickerFrame, {frame=CalendarFrame})
    self:Setup(CalendarTexturePickerFrame, {frame=CalendarFrame})
    self:Setup(CalendarMassInviteFrame, {frame=CalendarFrame})
    self:Setup(CalendarCreateEventFrame, {frame=CalendarFrame})
    self:Setup(CalendarViewEventFrame, {frame=CalendarFrame})
    self:Setup(CalendarViewHolidayFrame, {frame=CalendarFrame})
    self:Setup(CalendarViewRaidFrame, {frame=CalendarFrame})
end

--要塞
function WoWTools_MoveMixin.Events:Blizzard_GarrisonUI()
    self:Setup(GarrisonShipyardFrame)--海军行动
    self:Setup(GarrisonMissionFrame)--要塞任务
    self:Setup(GarrisonCapacitiveDisplayFrame)--要塞订单
    self:Setup(GarrisonLandingPage)--要塞报告
    self:Setup(OrderHallMissionFrame)
end

--任务选择
function WoWTools_MoveMixin.Events:Blizzard_PlayerChoice()
    self:Setup(PlayerChoiceFrame)

    hooksecurefunc(PlayerChoiceFrame, 'SetupOptions', function(frame)
        for optionFrame in frame.optionPools:EnumerateActiveByTemplate(frame.optionFrameTemplate) do
            if not optionFrame.moveFrameData then
                self:Setup(optionFrame, {frame=frame})
            end
        end
    end)
end



--飞行地图
function WoWTools_MoveMixin.Events:Blizzard_FlightMap()
    self:Setup(FlightMapFrame)
end


function WoWTools_MoveMixin.Events:Blizzard_OrderHallUI()
    self:Setup(OrderHallTalentFrame)
end


function WoWTools_MoveMixin.Events:Blizzard_GenericTraitUI()
    self:Setup(GenericTraitFrame)
    self:Setup(GenericTraitFrame.ButtonsParent, {frame=GenericTraitFrame})
end

--周奖励面板
function WoWTools_MoveMixin.Events:Blizzard_WeeklyRewards()
    self:Setup(WeeklyRewardsFrame)
    self:Setup(WeeklyRewardsFrame.Blackout, {frame=WeeklyRewardsFrame})
end


--装备升级,界面
function WoWTools_MoveMixin.Events:Blizzard_ItemUpgradeUI()
    self:Setup(ItemUpgradeFrame)
end

--玩家, 观察角色, 界面
function WoWTools_MoveMixin.Events:Blizzard_InspectUI()
    if InspectFrame then
        self:Setup(InspectFrame)
    end
end

--套装, 转换
function WoWTools_MoveMixin.Events:Blizzard_ItemInteractionUI()
    C_Timer.After(2, function()
        self:Setup(ItemInteractionFrame)
    end)
end



--虚空，仓库
function WoWTools_MoveMixin.Events:Blizzard_VoidStorageUI()
    self:Setup(VoidStorageFrame)
end

--时光漫游
function WoWTools_MoveMixin.Events:Blizzard_ChromieTimeUI()
    self:Setup(ChromieTimeFrame)
end

--侦查地图
function WoWTools_MoveMixin.Events:Blizzard_BFAMissionUI()
    self:Setup(BFAMissionFrame)
end


--派系声望
function WoWTools_MoveMixin.Events:Blizzard_MajorFactions()
    self:Setup(MajorFactionRenownFrame)
end


--死亡
function WoWTools_MoveMixin.Events:Blizzard_DeathRecap()
    self:Setup(DeathRecapFrame, {save=true})
end

--点击，施法
function WoWTools_MoveMixin.Events:Blizzard_ClickBindingUI()
    self:Setup(ClickBindingFrame)
    self:Setup(ClickBindingFrame.ScrollBox, {frame=ClickBindingFrame})
end


function WoWTools_MoveMixin.Events:Blizzard_ArchaeologyUI()
    self:Setup(ArchaeologyFrame)
end


function WoWTools_MoveMixin.Events:Blizzard_CovenantRenown()
    self:Setup(CovenantRenownFrame)
end


function WoWTools_MoveMixin.Events:Blizzard_ScrappingMachineUI()
    self:Setup(ScrappingMachineFrame)
end


function WoWTools_MoveMixin.Events:Blizzard_ArtifactUI()
    self:Setup(ArtifactFrame)
end

function WoWTools_MoveMixin.Events:Blizzard_DelvesCompanionConfiguration()
    self:Setup(DelvesCompanionConfigurationFrame)
    self:Setup(DelvesCompanionAbilityListFrame)
end


function WoWTools_MoveMixin.Events:Blizzard_HelpFrame()
    self:Setup(HelpFrame)
    --self:Setup(HelpFrame.TitleContainer, {frame=HelpFrame})
end



function WoWTools_MoveMixin.Events:Blizzard_GuildRename()--11.1.5
    self:Setup(GuildRenameFrame)
end























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
                WoWTools_Mixin:Call(EncounterJournal_ListInstances)
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
    hooksecurefunc(EncounterBossButtonMixin, 'Init', function(btn)
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
    hooksecurefunc(EncounterJournalItemMixin,'Init', function(btn)
        if btn:IsVisible() and not btn.set_texture then--btn.set_texture z_Events.lua Plus_Texture
            btn.name:SetPoint('RIGHT')
            btn.armorType:ClearAllPoints()
            btn.armorType:SetPoint('RIGHT', -2, -8)
        end
    end)

--BOSS, 概述
    EncounterJournalEncounterFrameInfoOverviewScrollFrame:SetPoint('TOPLEFT', EncounterJournal.encounter.info, 'TOP', 30, -43)
    EncounterJournal.encounter.overviewFrame:SetPoint('RIGHT', -23, 0)--.encounter.info.overviewScroll.child
    EncounterJournal.encounter.overviewFrame:HookScript('OnSizeChanged', function(f)
        f:SetPoint('RIGHT', -23, 0)
    end)
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
        --maxW=800,
        setSize=true,
        sizeRestFunc=function()
            EncounterJournal:SetSize(800, 496)
        end
    })

    self:Setup(EncounterJournalInstanceSelect.ScrollBox, {frame=EncounterJournal})
    --self:Setup(EncounterJournalEncounterFrameInfo.LootContainer.ScrollBox, {frame=EncounterJournal})
    --self:Setup(EncounterJournalEncounterFrameInfo.BossesScrollBox, {frame=EncounterJournal})
end











--FSTACK
function WoWTools_MoveMixin.Events:Blizzard_DebugTools()
    TableAttributeDisplay.LinesScrollFrame:ClearAllPoints()
    TableAttributeDisplay.LinesScrollFrame:SetPoint('TOPLEFT', 6, -62)
    TableAttributeDisplay.LinesScrollFrame:SetPoint('BOTTOMRIGHT', -36, 22)
    TableAttributeDisplay.FilterBox:SetPoint('RIGHT', -26,0)
    TableAttributeDisplay.TitleButton.Text:SetPoint('RIGHT')

    hooksecurefunc(TableAttributeLineReferenceMixin, 'Initialize', function(f)
        local frame= f:GetParent():GetParent():GetParent()
        local btn= frame.ResizeButton
        if btn and btn.setSize then
            local w= frame:GetWidth()-200
            f.ValueButton:SetWidth(w)
            f.ValueButton.Text:SetWidth(w)
        end
    end)
    hooksecurefunc(TableAttributeDisplay, 'UpdateLines', function(f)
        if f.dataProviders then
            for _, line in ipairs(f.lines) do
                if line.ValueButton then
                    local w= f:GetWidth()-200
                    line.ValueButton:SetWidth(w)
                    line.ValueButton.Text:SetWidth(w)
                end
            end
        end
    end)

    self:Setup(TableAttributeDisplay, {
        minW=476,
        minH=150,
        setSize=true,
        sizeUpdateFunc=function()
            TableAttributeDisplay:UpdateLines()--RefreshAllData()
        end,
        sizeRestFunc=function()
            TableAttributeDisplay:SetSize(500, 400)
        end,
    })
end
















--拍卖行
function WoWTools_MoveMixin.Events:Blizzard_AuctionHouseUI()
    AuctionHouseFrame.CategoriesList:SetPoint('BOTTOM', AuctionHouseFrame.MoneyFrameBorder.MoneyFrame, 'TOP',0,2)
    AuctionHouseFrame.BrowseResultsFrame.ItemList.Background:SetPoint('BOTTOMRIGHT')
    AuctionHouseFrameAuctionsFrame.SummaryList.Background:SetPoint('BOTTOM')
    AuctionHouseFrameAuctionsFrame.AllAuctionsList.Background:SetPoint('BOTTOMRIGHT')
    AuctionHouseFrameAuctionsFrame.BidsList.Background:SetPoint('BOTTOMRIGHT')
    AuctionHouseFrame.WoWTokenResults.BuyoutLabel:ClearAllPoints()
    AuctionHouseFrame.WoWTokenResults.BuyoutLabel:SetPoint('BOTTOM', AuctionHouseFrame.WoWTokenResults.Buyout, 'TOP', 0, 32)
    AuctionHouseFrame.WoWTokenResults.Background:SetPoint('BOTTOMRIGHT')
    AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.Background:SetPoint('BOTTOM')
    AuctionHouseFrame.CommoditiesBuyFrame.ItemList.Background:SetPoint('BOTTOMRIGHT')
    AuctionHouseFrame.ItemBuyFrame.ItemList.Background:SetPoint('BOTTOMRIGHT')
    AuctionHouseFrame.ItemBuyFrame.ItemDisplay:SetPoint('RIGHT',-3, 0)
    AuctionHouseFrame.ItemBuyFrame.ItemDisplay.Background:SetPoint('RIGHT')

    hooksecurefunc(AuctionHouseFrame, 'SetDisplayMode', function(frame, mode)
        local size= Save().size[frame:GetName()]
        local btn= frame.ResizeButton
        if not size or not btn then
            return
        end

        if mode==AuctionHouseFrameDisplayMode.ItemSell or mode==AuctionHouseFrameDisplayMode.CommoditiesSell then
            frame:SetSize(800, 538)
            btn.minWidth = 800
            btn.minHeight = 538
            btn.maxWidth = 800
            btn.maxHeight = 538
        else
            frame:SetSize(size[1], size[2])
            btn.minWidth = 600
            btn.minHeight = 320
            btn.maxWidth = nil
            btn.maxHeight = nil
        end
    end)

    self:Setup(AuctionHouseFrame, {
        setSize=true,
        sizeRestFunc=function()
            AuctionHouseFrame:SetSize(800, 538)
        end
    })

    self:Setup(AuctionHouseFrame.ItemSellFrame, {frame=AuctionHouseFrame})
    self:Setup(AuctionHouseFrame.ItemSellFrame.Overlay, {frame=AuctionHouseFrame})
    self:Setup(AuctionHouseFrame.ItemSellFrame.ItemDisplay, {frame=AuctionHouseFrame})

    self:Setup(AuctionHouseFrame.CommoditiesSellFrame, {frame=AuctionHouseFrame})
    self:Setup(AuctionHouseFrame.CommoditiesSellFrame.Overlay, {frame=AuctionHouseFrame})
    self:Setup(AuctionHouseFrame.CommoditiesSellFrame.ItemDisplay, {frame=AuctionHouseFrame})

    self:Setup(AuctionHouseFrame.ItemBuyFrame.ItemDisplay, {frame=AuctionHouseFrame, save=true})
    self:Setup(AuctionHouseFrameAuctionsFrame.ItemDisplay, {frame=AuctionHouseFrame, save=true})
end














--成就
function WoWTools_MoveMixin.Events:Blizzard_AchievementUI()
    AchievementFrameCategories:ClearAllPoints()
    AchievementFrameCategories:SetPoint('TOPLEFT', 21, -19)
    AchievementFrameCategories:SetPoint('BOTTOMLEFT', 175, 19)

    AchievementFrameMetalBorderRight:SetPoint('TOP', AchievementFrameMetalBorderTopRight, 'BOTTOM')
    AchievementFrameMetalBorderLeft:SetPoint('TOP', AchievementFrameMetalBorderTopLeft, 'BOTTOM')
    AchievementFrameMetalBorderRight:SetPoint('BOTTOM', AchievementFrameMetalBorderBottomRight, 'TOP')
    AchievementFrameMetalBorderLeft:SetPoint('BOTTOM', AchievementFrameMetalBorderBottomLeft, 'TOP')

    --hooksecurefunc(AchievementTemplateMixin, 'OnLoad', function(f)
--成就，显示，按钮
    hooksecurefunc(AchievementTemplateMixin, 'OnLoad', function(f)
        f.Label:SetPoint('RIGHT', f.Shield.Icon, 'LEFT')
        f.Label:SetPoint('LEFT', f.PlusMinus, 'RIGHT')

        f.Description:SetPoint('RIGHT', f.Shield.Icon, 'LEFT')
        f.Description:SetPoint('LEFT', f.Icon, 'RIGHT')

        f.Reward:SetPoint('RIGHT', f.Shield.Icon, 'LEFT')
        f.Reward:SetPoint('LEFT', f.Icon, 'RIGHT')
    end)
    --hooksecurefunc('AchievementObjectives_DisplayProgressiveAchievement', function(objectivesFrame, id)



    local left= -38
    AchievementFrameAchievements:SetPoint('RIGHT', left, 0)
    AchievementFrameStats:SetPoint('RIGHT', left, 0)
--总览
    AchievementFrameSummary:SetPoint('RIGHT', left, 0)

--统计
    AchievementFrameStatsBG:SetPoint('RIGHT')

--比较
    AchievementFrameComparison:SetPoint('RIGHT')

    AchievementFrameComparison.AchievementContainer:SetPoint('RIGHT', left, 0)

    AchievementFrameComparison.Summary:SetPoint('RIGHT', left, 0)
    AchievementFrameComparison.Summary.Player:SetPoint('RIGHT', -120, 0)
    AchievementFrameComparison.AchievementContainer.ScrollBar:SetPoint('TOPLEFT', AchievementFrameComparison.Summary, 'TOPRIGHT', 5, -5)
    hooksecurefunc(AchievementComparisonTemplateMixin, 'OnLoad', function(f)
        f.Player:SetPoint('RIGHT', -120, 0)
    end)
    AchievementFrameComparison.StatContainer:SetPoint('RIGHT', left, 0)


    AchievementFrame.Header:ClearAllPoints()
    AchievementFrame.Header:SetPoint('BOTTOM', AchievementFrame, 'TOP', 0, -38)

    AchievementFrameFilterDropdown:ClearAllPoints()
    AchievementFrameFilterDropdown:SetPoint('CENTER', AchievementFrame.Header.LeftDDLInset, -2, 3)
--Search
    --[[AchievementFrame.SearchResults:ClearAllPoints()
    AchievementFrame.SearchResults:SetPoint('BOTTOMLEFT', 100, 8)
    AchievementFrame.SearchResults:SetPoint('BOTTOMRIGHT', -100, 8)
    AchievementFrame.SearchResults:SetPoint('TOP', 0, -15)]]

    self:Setup(AchievementFrame, {
        minW=768,
        --maxW=768,
        minH=500,
        setSize=true,
        sizeRestFunc= function()
            AchievementFrame:SetSize(768, 500)
        end,
    })
    self:Setup(AchievementFrame.Header, {frame=AchievementFrame})
--比较
    self:Setup(AchievementFrameComparisonHeader, {frame=AchievementFrame})
    self:Setup(AchievementFrameComparison, {frame=AchievementFrame})
    self:Setup(AchievementFrameComparison.AchievementContainer, {frame=AchievementFrame})

    hooksecurefunc(AchievementFrame, 'SetWidth', function(f)
        if f.ResizeButton and not f.ResizeButton.isActiveButton then
            self:Set_SizeScale(f)
        end
    end)
end














--地下城和团队副本 GroupFinderFrame
function WoWTools_MoveMixin.Events:Blizzard_GroupFinder()
   LFGListPVEStub:SetPoint('BOTTOMRIGHT')
    LFGListFrame.CategorySelection.Inset.CustomBG:SetPoint('BOTTOMRIGHT')

    hooksecurefunc('GroupFinderFrame_SelectGroupButton', function(index)
        local btn= PVEFrame.ResizeButton
        if not btn or btn.disabledSize or not PVEFrame:IsProtected() then
            return
        end
        if index==3 then
            btn.setSize= true
            local size= Save().size['PVEFrame_PVE']
            if size then
                PVEFrame:SetSize(size[1], size[2])
                return
            end
        else
            btn.setSize= false
        end
        PVEFrame:SetSize(PVE_FRAME_BASE_WIDTH, 428)
        LFGListFrame.ApplicationViewer.InfoBackground:SetPoint('RIGHT', -20, 0)
    end)


    self:Setup(PVEFrame, {
        setSize=true,
        minW=563,
        minH=428,
        sizeUpdateFunc=function()
            if PVEFrame.activeTabIndex==3 then
                WoWTools_Mixin:Call(ChallengesFrame.Update, ChallengesFrame)
            end
        end, sizeStopFunc=function()
            if PVEFrame.activeTabIndex==1 then
                Save().size['PVEFrame_PVE']= {PVEFrame:GetSize()}
            elseif PVEFrame.activeTabIndex==2 then
                if PVPQueueFrame.selection==LFGListPVPStub then
                    Save().size['PVEFrame_PVP']= {PVEFrame:GetSize()}
                end
            elseif PVEFrame.activeTabIndex==3 then
                Save().size['PVEFrame_KEY']= {PVEFrame:GetSize()}
            end
        end, sizeRestFunc=function()
            if PVEFrame.activeTabIndex==1 then
                Save().size['PVEFrame_PVE']=nil
                PVEFrame:SetSize(PVE_FRAME_BASE_WIDTH, 428)
            elseif PVEFrame.activeTabIndex==2 then--Blizzard_PVPUI.lua
                Save().size['PVEFrame_PVP']=nil
                local width = PVE_FRAME_BASE_WIDTH;
                width = width + PVPQueueFrame.HonorInset:Update();
                PVEFrame:SetSize(width, 428)
            elseif PVEFrame.activeTabIndex==3 then
                Save().size['PVEFrame_KEY']=nil
                PVEFrame:SetSize(PVE_FRAME_BASE_WIDTH, 428)
                WoWTools_Mixin:Call(ChallengesFrame.Update, ChallengesFrame)
            end
        end
    })

    --自定义，副本，创建，更多...
    LFGListFrame.EntryCreation.ActivityFinder.Dialog:ClearAllPoints()
    LFGListFrame.EntryCreation.ActivityFinder.Dialog:SetPoint('TOPLEFT',0, -30)
    LFGListFrame.EntryCreation.ActivityFinder.Dialog:SetPoint('BOTTOMRIGHT')
end









--地下城和团队副本, PVP
function WoWTools_MoveMixin.Events:Blizzard_PVPUI()
    PVPUIFrame:SetPoint('BOTTOMRIGHT')
    LFGListPVPStub:SetPoint('BOTTOMRIGHT')
    LFGListFrame.ApplicationViewer.InfoBackground:SetPoint('RIGHT', -2,0)

    hooksecurefunc('PVPQueueFrame_ShowFrame', function()
        local btn= PVEFrame.ResizeButton
        if not btn or btn.disabledSize or WoWTools_FrameMixin:IsLocked(PVEFrame) then
            return
        end
        if PVPQueueFrame.selection==LFGListPVPStub then
            btn.setSize= true
            local size= Save().size['PVEFrame_PVP']
            if size then
                PVEFrame:SetSize(size[1], size[2])
                return
            end
        else
            btn.setSize= false
        end
        PVEFrame:SetHeight(428)
    end)
end














--挑战, 钥匙插件, 界面
function WoWTools_MoveMixin.Events:Blizzard_ChallengesUI()
    self:Setup(ChallengesKeystoneFrame)

    ChallengesFrame.WeeklyInfo:SetPoint('BOTTOMRIGHT')
    ChallengesFrame.WeeklyInfo.Child:SetPoint('BOTTOMRIGHT')
    ChallengesFrame.WeeklyInfo.Child.RuneBG:SetPoint('BOTTOMRIGHT')
    for _, region in pairs({ChallengesFrame:GetRegions()}) do
        if region:GetObjectType()=='Texture' then
            region:SetPoint('BOTTOMRIGHT')
        end
    end
    ChallengesFrame:HookScript('OnShow', function()
        local frame= PVEFrame
        if not frame.ResizeButton or frame.ResizeButton.disabledSize or not frame:CanChangeAttribute() then
            return
        end
        local size= WoWToolsSave['Plus_Move'].size['PVEFrame_KEY']
        frame.ResizeButton.setSize= true
        if size then
            frame:SetSize(size[1], size[2])
        else
            frame:SetSize(PVE_FRAME_BASE_WIDTH, 428)
        end
    end)
end










--地下堡
function WoWTools_MoveMixin.Events:Blizzard_DelvesDashboardUI()
    self:Setup(DelvesDashboardFrame, {frame=PVEFrame})
    self:Setup(DelvesDashboardFrame.ButtonPanelLayoutFrame, {frame=PVEFrame})
    self:Setup(DelvesDashboardFrame.ButtonPanelLayoutFrame.CompanionConfigButtonPanel, {frame=PVEFrame})
end

function WoWTools_MoveMixin.Events:Blizzard_DelvesDifficultyPicker()
    self:Setup(DelvesDifficultyPickerFrame)
end



--聊天设置
function WoWTools_MoveMixin.Events:Blizzard_Channels()
    self:Setup(ChannelFrame, {minW=402, minH=200, maxW=402, setSize=true,  sizeRestFunc=function(btn)
        ChannelFrame:SetSize(402, 423)
    end})
end

--选项
function WoWTools_MoveMixin.Events:Blizzard_Settings_Shared()
    for _, region in pairs({SettingsPanel:GetRegions()}) do
        if region:GetObjectType()=='Texture' then
            region:SetPoint('BOTTOMRIGHT', -12, 38)
        end
    end
    self:Setup(SettingsPanel, {setSize=true, minW=800, minH=200, sizeRestFunc=function(btn)
        SettingsPanel:SetSize(920, 724)
    end})
end


function WoWTools_MoveMixin.Events:Blizzard_ChatFrame()
    CombatConfigFormattingExampleString1:SetPoint('RIGHT')
    CombatConfigFormattingExampleString2:SetPoint('RIGHT')

    self:Setup(ChatConfigFrame)
    self:Setup(ChatConfigFrame.Header, {frame=ChatConfigFrame})
    self:Setup(ChatConfigFrame.Border, {frame=ChatConfigFrame})
end

--插件
function WoWTools_MoveMixin.Events:Blizzard_AddOnList()
    if WoWToolsSave['Plus_AddOns'] and WoWToolsSave['Plus_AddOns'].disabled then
        self:Setup(AddonList)
    end
end




--菜单
function WoWTools_MoveMixin.Events:Blizzard_GameMenu()
    self:Setup(GameMenuFrame)
end


function WoWTools_MoveMixin.Events:Blizzard_ActionBar()
    self:Setup(ExtraActionButton1, {click='RightButton', notSave=true, notMoveAlpha=true, notFuori=true})--额外技能
end

function WoWTools_MoveMixin.Events:Blizzard_UnitFrame()
    self:Setup(PartyFrame.Background, {frame=PartyFrame, notZoom=true, notSave=true})

--其它
    self:Setup(OpacityFrame)
    self:Setup(ArcheologyDigsiteProgressBar, {notZoom=true})
    self:Setup(VehicleSeatIndicator, {notZoom=true, notSave=true})
    self:Setup(ExpansionLandingPage)
    self:Setup(PlayerPowerBarAlt, {notMoveAlpha=true})
    self:Setup(CreateChannelPopup)
    self:Setup(BattleTagInviteFrame)

    for _, barContainer in ipairs(StatusTrackingBarManager.barContainers or {}) do
        self:Setup(barContainer, {alpha=0})
    end

    self:Setup(OverrideActionBar, {notMoveAlpha=true})
    self:Setup(OverrideActionBarExpBar, {frame=OverrideActionBar})

    self:Setup(ReportFrame)
end








--角色
function WoWTools_MoveMixin.Frames:CharacterFrame()--:Init_CharacterFrame()--角色
    PaperDollFrame.TitleManagerPane:ClearAllPoints()
    PaperDollFrame.TitleManagerPane:SetPoint('TOPLEFT', CharacterFrameInsetRight, 4, -4)
    PaperDollFrame.TitleManagerPane:SetPoint('BOTTOMRIGHT', CharacterFrameInsetRight, -4, 4)

    PaperDollFrame.TitleManagerPane.ScrollBox:ClearAllPoints()
    PaperDollFrame.TitleManagerPane.ScrollBox:SetPoint('TOPLEFT',CharacterFrameInsetRight,4,-4)
    PaperDollFrame.TitleManagerPane.ScrollBox:SetPoint('BOTTOMRIGHT', CharacterFrameInsetRight, -22,4)

    PaperDollFrame.EquipmentManagerPane:ClearAllPoints()
    PaperDollFrame.EquipmentManagerPane:SetPoint('TOPLEFT', CharacterFrameInsetRight, 4, -4)
    PaperDollFrame.EquipmentManagerPane:SetPoint('BOTTOMRIGHT', CharacterFrameInsetRight, -4, 4)
    PaperDollFrame.EquipmentManagerPane.ScrollBox:ClearAllPoints()
    PaperDollFrame.EquipmentManagerPane.ScrollBox:SetPoint('TOPLEFT', CharacterFrameInsetRight, 4, -28)
    PaperDollFrame.EquipmentManagerPane.ScrollBox:SetPoint('BOTTOMRIGHT', CharacterFrameInsetRight, -22, 4)

    CharacterModelScene:ClearAllPoints()
    CharacterModelScene:SetPoint('TOPLEFT', 52, -66)
    CharacterModelScene:SetPoint('BOTTOMRIGHT', CharacterFrameInset, -50, 34)

    CharacterModelFrameBackgroundOverlay:ClearAllPoints()
    CharacterModelFrameBackgroundOverlay:SetAllPoints(CharacterModelScene)

    CharacterModelFrameBackgroundTopLeft:ClearAllPoints()
    CharacterModelFrameBackgroundTopLeft:SetPoint('TOPLEFT')
    CharacterModelFrameBackgroundTopLeft:SetPoint('BOTTOMRIGHT',-19, 128)

    CharacterModelFrameBackgroundTopRight:ClearAllPoints()
    CharacterModelFrameBackgroundTopRight:SetPoint('TOPLEFT', CharacterModelFrameBackgroundTopLeft, 'TOPRIGHT')
    CharacterModelFrameBackgroundTopRight:SetPoint('BOTTOMRIGHT', 0, 128)

    CharacterModelFrameBackgroundBotLeft:ClearAllPoints()
    CharacterModelFrameBackgroundBotLeft:SetPoint('TOPLEFT', CharacterModelFrameBackgroundTopLeft, 'BOTTOMLEFT')
    CharacterModelFrameBackgroundBotLeft:SetPoint('BOTTOMRIGHT', -19, 0)

    CharacterModelFrameBackgroundBotRight:ClearAllPoints()
    CharacterModelFrameBackgroundBotRight:SetPoint('TOPLEFT', CharacterModelFrameBackgroundBotLeft, 'TOPRIGHT')
    CharacterModelFrameBackgroundBotRight:SetPoint('BOTTOMRIGHT')

    CharacterStatsPane.ClassBackground:ClearAllPoints()
    CharacterStatsPane.ClassBackground:SetAllPoints(CharacterStatsPane)


    CharacterFrame.InsetRight:ClearAllPoints()
    CharacterFrame.InsetRight:SetPoint('TOPRIGHT', 0, -58)
    CharacterFrame.InsetRight:SetPoint('BOTTOMRIGHT')
    CharacterFrame.InsetRight:SetWidth(203)

    CharacterFrame.Inset:ClearAllPoints()
    CharacterFrame.Inset:SetPoint('TOPRIGHT', CharacterFrame.InsetRight, 'TOPLEFT')
    CharacterFrame.Inset:SetPoint('BOTTOMLEFT')
    CharacterFrame.Inset.NineSlice:Hide()



    ReputationFrame.ScrollBox:ClearAllPoints()
    ReputationFrame.ScrollBox:SetPoint('TOPLEFT', 4, -58)
    ReputationFrame.ScrollBox:SetPoint('BOTTOMRIGHT', -22, 2)

    TokenFrame.ScrollBox:ClearAllPoints()
    TokenFrame.ScrollBox:SetPoint('TOPLEFT', TokenFrame, 4, -58)
    TokenFrame.ScrollBox:SetPoint('BOTTOMRIGHT', TokenFrame , -22, 2)

    

    local function Set_Slot_Point()
        if not WoWTools_FrameMixin:IsLocked(CharacterFrame) then
            return
        end
        local w, h= CharacterFrame:GetSize()--366 * 337   (40+4)*8
        local line= math.max(4, (h-16-42- 40*7- 58)/7)

        CharacterHeadSlot:SetPoint('TOPLEFT', CharacterFrame, 8, -60)
        CharacterNeckSlot:SetPoint('TOPLEFT', CharacterHeadSlot, 'BOTTOMLEFT', 0, -line)
        CharacterShoulderSlot:SetPoint('TOPLEFT', CharacterNeckSlot, 'BOTTOMLEFT', 0, -line)
        CharacterBackSlot:SetPoint('TOPLEFT', CharacterShoulderSlot, 'BOTTOMLEFT', 0, -line)
        CharacterChestSlot:SetPoint('TOPLEFT', CharacterBackSlot, 'BOTTOMLEFT', 0, -line)
        CharacterShirtSlot:SetPoint('TOPLEFT', CharacterChestSlot, 'BOTTOMLEFT', 0, -line)
        CharacterTabardSlot:SetPoint('TOPLEFT', CharacterShirtSlot, 'BOTTOMLEFT', 0, -line)
        CharacterWristSlot:SetPoint('TOPLEFT', CharacterTabardSlot, 'BOTTOMLEFT', 0, -line)

        --CharacterHandsSlot
        CharacterWaistSlot:SetPoint('TOPLEFT', CharacterHandsSlot, 'BOTTOMLEFT', 0, -line)
        CharacterLegsSlot:SetPoint('TOPLEFT', CharacterWaistSlot, 'BOTTOMLEFT', 0, -line)
        CharacterFeetSlot:SetPoint('TOPLEFT', CharacterLegsSlot, 'BOTTOMLEFT', 0, -line)
        CharacterFinger0Slot:SetPoint('TOPLEFT', CharacterFeetSlot, 'BOTTOMLEFT', 0, -line)
        CharacterFinger1Slot:SetPoint('TOPLEFT', CharacterFinger0Slot, 'BOTTOMLEFT', 0, -line)
        CharacterTrinket0Slot:SetPoint('TOPLEFT', CharacterFinger1Slot, 'BOTTOMLEFT', 0, -line)
        CharacterTrinket1Slot:SetPoint('TOPLEFT', CharacterTrinket0Slot, 'BOTTOMLEFT', 0, -line)

        line= (w-40*2-200-203)/3
        CharacterMainHandSlot:SetPoint('BOTTOMLEFT', 100+line, 16)
        CharacterSecondaryHandSlot:SetPoint('TOPLEFT', CharacterMainHandSlot,'TOPRIGHT', math.max(5, line), 0)
    end

    hooksecurefunc(CharacterFrame, 'UpdateSize', function(f)
        if not f.ResizeButton then
            return
        end
        local size
        if f.Expanded then
            f.ResizeButton.minWidth=450
            size= Save().size['CharacterFrameExpanded']
        else
            size= Save().size['CharacterFrameCollapse']
            f.ResizeButton.minWidth=320
        end
        if size then
            f:SetSize(size[1], size[2])
        end
        Set_Slot_Point()
    end)

    self:Setup(CharacterFrame, {
        minW=450,
        minH=424,
        setSize=true,
        sizeUpdateFunc=function()
            if PaperDollFrame.EquipmentManagerPane:IsVisible() then
                WoWTools_Mixin:Call(PaperDollEquipmentManagerPane_Update)
            end
            if PaperDollFrame.TitleManagerPane:IsVisible() then
                WoWTools_Mixin:Call(PaperDollTitlesPane_Update)
            end
            if CharacterHeadSlot:IsVisible() then
                Set_Slot_Point()
            end
        end,
        sizeStopFunc=function(btn)
              if CharacterFrame.Expanded then
                Save().size['CharacterFrameExpanded']={CharacterFrame:GetSize()}
            else
                Save().size['CharacterFrameCollapse']={CharacterFrame:GetSize()}
            end
            Set_Slot_Point()
        end,
        sizeRestFunc=function()
            if not WoWTools_FrameMixin:IsLocked(CharacterFrame) then
                if (Save().size['CharacterFrameExpanded'] or Save().size['CharacterFrameCollapse']) then
                    CharacterFrame:SetHeight(424)
                end
                Save().size['CharacterFrameExpanded']=nil
                Save().size['CharacterFrameCollapse']=nil
                WoWTools_Mixin:Call(CharacterFrame.UpdateSize, CharacterFrame)
            end
        end,
        sizeRestTooltipColorFunc=function(f)
            return ((f.target.Expanded and Save().size['CharacterFrameExpanded']) or (not f.target.Expanded and Save().size['CharacterFrameCollapse'])) and '' or '|cff9e9e9e'
        end
    })

    self:Setup(TokenFrame, {frame=CharacterFrame})
    self:Setup(TokenFramePopup, {frame=CharacterFrame})
    self:Setup(ReputationFrame, {frame=CharacterFrame})
    self:Setup(ReputationFrame.ReputationDetailFrame, {frame=CharacterFrame})

    self:Setup(CurrencyTransferMenu)
    self:Setup(CurrencyTransferLog, {
        setSize=true,
        sizeRestFunc=function()
            CurrencyTransferLog:ClearAllPoints()
            CurrencyTransferLog:SetPoint('TOPLEFT', CharacterFrame, 'TOPRIGHT', 5,0)
            CurrencyTransferLog:SetSize(340, 370)
        end, scaleRestFunc= function()
            CurrencyTransferLog:ClearAllPoints()
            CurrencyTransferLog:SetPoint('TOPLEFT', CharacterFrame, 'TOPRIGHT', 5,0)
        end,
    })

end













--移动 ETRACE
function WoWTools_MoveMixin.Events:Blizzard_EventTrace()
    EventTrace.Log.Bar.SearchBox:SetPoint('LEFT', EventTrace.Log.Bar.Label, 'RIGHT')
    EventTrace.Log.Bar.SearchBox:SetScript('OnEditFocusGained', function(frame)
        frame:HighlightText()
    end)
    self:Setup(EventTrace)
end









--天赋，法术书
function WoWTools_MoveMixin.Events:Blizzard_PlayerSpells()
--英雄专精
    HeroTalentsSelectionDialog.p_point={PlayerSpellsFrame:GetPoint(1)}
    HeroTalentsSelectionDialog.p_point[2]= nil
    HeroTalentsSelectionDialog:HookScript('OnShow', function(frame)
        PlayerSpellsFrame:ClearAllPoints()
        PlayerSpellsFrame:SetPoint(frame.p_point[1], UIParent, frame.p_point[3], frame.p_point[4], frame.p_point[5])
    end)
    HeroTalentsSelectionDialog:HookScript('OnHide', function()
        self:SetPoint(PlayerSpellsFrame)
    end)
    self:Setup(HeroTalentsSelectionDialog)

--天赋，法术书
    self:Setup(PlayerSpellsFrame)

--专精
    for specContentFrame in PlayerSpellsFrame.SpecFrame.SpecContentFramePool:EnumerateActive() do
        self:Setup(specContentFrame, {frame=PlayerSpellsFrame})
    end

--天赋
    self:Setup(PlayerSpellsFrame.TalentsFrame, {frame=PlayerSpellsFrame})
    self:Setup(PlayerSpellsFrame.TalentsFrame.ButtonsParent, {frame=PlayerSpellsFrame})

--法术书
    self:Setup(PlayerSpellsFrame.SpellBookFrame, {frame=PlayerSpellsFrame})
end














--商店
function WoWTools_MoveMixin.Events:Blizzard_AccountStore()
    self:Setup(AccountStoreFrame, {
        setSize=true, minH=537, minW=800,
    sizeRestFunc=function()
        AccountStoreFrame:SetSize(800, 537)
    end})
end





--专业书
function WoWTools_MoveMixin.Events:Blizzard_ProfessionsBook()
    self:Setup(ProfessionsBookFrame)
end

--追踪栏
function WoWTools_MoveMixin.Events:Blizzard_ObjectiveTracker()
    EventRegistry:RegisterCallback("EditMode.Exit", function()
        ObjectiveTrackerFrame:SetMovable(true)
    end)

    self:Setup(ObjectiveTrackerFrame.Header, {
        notSave=true,
        notZoom=true,
        frame=ObjectiveTrackerFrame,
    })
end



--StaticPopup 11.2才有
function WoWTools_MoveMixin.Events:Blizzard_StaticPopup_Game()
    for i=1, 4 do
        local dialog= _G['StaticPopup'..i]
        if dialog then

            self:Setup(_G['StaticPopup'..i], {
                notSave=true,
            })

            if dialog.SetupAnchor then
                hooksecurefunc(dialog, 'SetupAnchor', function(f)
                    self:SetPoint(f)
                end)
            end
        end
    end
end
