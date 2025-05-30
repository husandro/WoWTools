local function Save()
    return WoWToolsSave['Plus_Move']
end









--专业训练师
function WoWTools_MoveMixin.Events:Blizzard_TrainerUI()
    self:Setup(ClassTrainerFrame, {minW=328, minH=197, setSize=true, initFunc=function(btn)
        ClassTrainerFrameSkillStepButton:SetPoint('RIGHT', -12, 0)
        ClassTrainerFrameBottomInset:SetPoint('BOTTOMRIGHT', -4, 28)
        hooksecurefunc('ClassTrainerFrame_Update', function()--Blizzard_TrainerUI.lua
            ClassTrainerFrame.ScrollBox:SetPoint('BOTTOMRIGHT', -26, 34)
        end)
        btn.targetFrame.ScrollBox:ClearAllPoints()
    end, sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(338, 424)
    end})
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
    self:Setup(PlayerChoiceFrame, {notZoom=true})
end

--公会银行
function WoWTools_MoveMixin.Events:Blizzard_GuildBankUI()
    if WoWToolsSave['Plus_GuildBank'].disabled then
        self:Setup(GuildBankFrame)
    end
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

--镶嵌宝石，界面
function WoWTools_MoveMixin.Events:Blizzard_ItemSocketingUI()
    C_Timer.After(2, function()
        self:Setup(ItemSocketingFrame)
        self:Setup(ItemSocketingScrollChild, {frame=ItemSocketingFrame})
    end)
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

























--冒险指南
function WoWTools_MoveMixin.Events:Blizzard_EncounterJournal()
    EncounterJournalMonthlyActivitiesFrame.ScrollBox:SetPoint('BOTTOM')

    EncounterJournalInstanceSelectBG:SetPoint('BOTTOMRIGHT', 0,2)
    EncounterJournalInstanceSelect.ScrollBox:SetPoint('BOTTOMLEFT', -3, 15)
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
    EncounterJournalEncounterFrameInfo:SetPoint('TOP')
    EncounterJournalEncounterFrameInfo.BossesScrollBox:SetPoint('TOP', 0, -43)
    EncounterJournalEncounterFrameInstanceFrame:SetPoint('TOP')
    EncounterJournalEncounterFrameInfoBG:SetPoint('TOP')
    EncounterJournalEncounterFrameInstanceFrameMapButton:ClearAllPoints()
    EncounterJournalEncounterFrameInstanceFrameMapButton:SetPoint('TOPLEFT', 33, -275)
    EncounterJournalEncounterFrameInstanceFrame.LoreScrollingFont:SetPoint('TOPRIGHT', -35, -330)
    EncounterJournalEncounterFrameInfoOverviewScrollFrame:SetPoint('TOP',0,-43)
    EncounterJournalEncounterFrameInfo.LootContainer:SetPoint('TOP', 0, -43)
    EncounterJournalEncounterFrameInfoDetailsScrollFrame:SetPoint('TOP', 0, -43)
    EncounterJournalEncounterFrameInfoModelFrame:ClearAllPoints()
    EncounterJournalEncounterFrameInfoModelFrame:SetPoint('RIGHT', 0, 0)

    self:Setup(EncounterJournal, {
        minW=800,
        minH=496,
        maxW=800,
        setSize=true,
        sizeRestFunc=function(self)
            self.targetFrame:SetSize(800, 496)
        end
    })
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
        sizeUpdateFunc=function(btn)
            btn.targetFrame:UpdateLines()--RefreshAllData()
        end,
        sizeRestFunc=function(btn)
            btn.targetFrame:SetSize(500, 400)
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
        sizeRestFunc=function(btn)
            btn.targetFrame:SetSize(800, 538)
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
--Search
    AchievementFrame.SearchResults:ClearAllPoints()
    AchievementFrame.SearchResults:SetPoint('BOTTOMLEFT', 100, 8)
    AchievementFrame.SearchResults:SetPoint('BOTTOMRIGHT', -100, 8)
    AchievementFrame.SearchResults:SetPoint('TOP', 0, -250)

    hooksecurefunc(AchievementFrame, 'SetWidth', function(f)
        self:Set_SizeScale(f)
    end)

    self:Setup(AchievementFrame, {
        minW=768,
        --maxW=768,
        minH=500,
        setSize=true,
        sizeRestFunc= function(btn)
            btn.targetFrame:SetSize(768, 500)
        end,
    })


    self:Setup(AchievementFrame.Header, {frame=AchievementFrame})

    --比较
    self:Setup(AchievementFrameComparisonHeader, {frame=AchievementFrame})
    self:Setup(AchievementFrameComparison, {frame=AchievementFrame})
    self:Setup(AchievementFrameComparison.AchievementContainer, {frame=AchievementFrame})

    AchievementFrame.SearchResults:SetPoint('TOP', 0, -15)
    
    --self:Setup(AchievementFrame.SearchResults)--:SetPoint('TOP', 0, -15)
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
        end, sizeStopFunc=function(btn)
            if PVEFrame.activeTabIndex==1 then
                Save().size['PVEFrame_PVE']= {btn.targetFrame:GetSize()}
            elseif PVEFrame.activeTabIndex==2 then
                if PVPQueueFrame.selection==LFGListPVPStub then
                    Save().size['PVEFrame_PVP']= {btn.targetFrame:GetSize()}
                end
            elseif PVEFrame.activeTabIndex==3 then
                Save().size['PVEFrame_KEY']= {btn.targetFrame:GetSize()}
            end
        end, sizeRestFunc=function(btn)
            if PVEFrame.activeTabIndex==1 then
                Save().size['PVEFrame_PVE']=nil
                btn.targetFrame:SetSize(PVE_FRAME_BASE_WIDTH, 428)
            elseif PVEFrame.activeTabIndex==2 then--Blizzard_PVPUI.lua
                Save().size['PVEFrame_PVP']=nil
                local width = PVE_FRAME_BASE_WIDTH;
                width = width + PVPQueueFrame.HonorInset:Update();
                btn.targetFrame:SetSize(width, 428)
            elseif PVEFrame.activeTabIndex==3 then
                Save().size['PVEFrame_KEY']=nil
                btn.targetFrame:SetSize(PVE_FRAME_BASE_WIDTH, 428)
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

--聊天设置
function WoWTools_MoveMixin.Events:Blizzard_Channels()
    self:Setup(ChannelFrame, {minW=402, minH=200, maxW=402, setSize=true,  sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(402, 423)
    end})
end

--选项
function WoWTools_MoveMixin.Events:Blizzard_Settings_Shared()
    self:Setup(SettingsPanel, {setSize=true, minW=800, minH=200, initFunc=function(btn)
        for _, region in pairs({btn.targetFrame:GetRegions()}) do
            if region:GetObjectType()=='Texture' then
                region:SetPoint('BOTTOMRIGHT', -12, 38)
            end
        end
    end, sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(920, 724)
    end})
end


function WoWTools_MoveMixin.Events:Blizzard_ChatFrame()
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


function WoWTools_MoveMixin.Events:Blizzard_StableUI()
    if WoWTools_DataMixin.Player.Class=='HUNTER' and WoWToolsSave['Plus_StableFrame'] and WoWToolsSave['Plus_StableFrame'].disabled then--StableFrame
        self:Setup(StableFrame)
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
    self:Setup(OverrideActionBarExpBar, {notZoom=true})
    self:Setup(ReportFrame)
end