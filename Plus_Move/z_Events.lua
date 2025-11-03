--专业训练师
function WoWTools_MoveMixin.Events:Blizzard_TrainerUI()
    ClassTrainerFrame.ScrollBox:ClearAllPoints()
    ClassTrainerFrame.ScrollBox:SetPoint('BOTTOMRIGHT', -26, 34)
    ClassTrainerFrameSkillStepButton:SetPoint('RIGHT', -12, 0)
    ClassTrainerFrameBottomInset:SetPoint('BOTTOMRIGHT', -4, 28)
    WoWTools_DataMixin:Hook('ClassTrainerFrame_Update', function()--Blizzard_TrainerUI.lua
        ClassTrainerFrame.ScrollBox:SetPoint('BOTTOMRIGHT', -26, 34)
    end)
    self:Setup(ClassTrainerFrame, {
    minW=200,
    minH=197,
    sizeRestFunc=function()
        ClassTrainerFrame:SetSize(338, 424)
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

    self:Setup(OrderHallMissionFrame)--侦查地图
    self:Setup(AdventureMapQuestChoiceDialog, {frame=OrderHallMissionFrame})
end

--任务选择
function WoWTools_MoveMixin.Events:Blizzard_PlayerChoice()
    self:Setup(PlayerChoiceFrame)

    WoWTools_DataMixin:Hook(PlayerChoiceFrame, 'SetupOptions', function(frame)
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
    ClickBindingFrame.TutorialButton:SetFrameLevel(ClickBindingFrame.TitleContainer:GetFrameLevel()+1)

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

function WoWTools_MoveMixin.Events:Blizzard_RemixArtifactUI()
    self:Setup(RemixArtifactFrame)
    self:Setup(RemixArtifactFrame.ButtonsParent.Overlay, {frame=RemixArtifactFrame})
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















--[[
function WoWTools_MoveMixin.Events:Blizzard_ZoneAbility()
    local function set_button(frame)
        for btn in frame.SpellButtonContainer:EnumerateActive() do
            if not btn.moveFrameData then
                self:Setup(btn, {frame=ZoneAbilityFrame, click='RightButton'})
                btn:HookScript('OnDragStart', function(b, d)
                    if d=='RightButton' then

                    end
                end)
            end
        end
    end

    set_button(ZoneAbilityFrame)

    WoWTools_DataMixin:Hook(ZoneAbilityFrame, 'UpdateDisplayedZoneAbilities', function(frame)
       set_button(frame)
    end)


    --SetupButton(ZoneAbilityFrame)--, {frame=ZoneAbilityFrame.SpellButtonContainer})
end
]]













--FSTACK
function WoWTools_MoveMixin.Events:Blizzard_DebugTools()
    TableAttributeDisplay.LinesScrollFrame:ClearAllPoints()
    TableAttributeDisplay.LinesScrollFrame:SetPoint('TOPLEFT', 6, -62)
    TableAttributeDisplay.LinesScrollFrame:SetPoint('BOTTOMRIGHT', -36, 22)
    TableAttributeDisplay.FilterBox:SetPoint('RIGHT', -26,0)
    TableAttributeDisplay.TitleButton.Text:SetPoint('RIGHT')

    WoWTools_DataMixin:Hook(TableAttributeLineReferenceMixin, 'Initialize', function(f)
        local frame= f:GetParent():GetParent():GetParent()
        local btn= frame.ResizeButton
        if btn and btn.setSize then
            local w= frame:GetWidth()-200
            f.ValueButton:SetWidth(w)
            f.ValueButton.Text:SetWidth(w)
        end
    end)
    WoWTools_DataMixin:Hook(TableAttributeDisplay, 'UpdateLines', function(f)
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
        sizeUpdateFunc=function()
            TableAttributeDisplay:UpdateLines()--RefreshAllData()
        end,
        sizeRestFunc=function()
            TableAttributeDisplay:SetSize(500, 400)
        end,
    })
end
















--拍卖行
--Shared
--Blizzard_AuctionHouseTableBuilder.lua
function WoWTools_MoveMixin.Events:Blizzard_AuctionHouseUI()
    AuctionHouseFrame.CategoriesList:SetPoint('BOTTOM', AuctionHouseFrame.MoneyFrameBorder.MoneyFrame, 'TOP',0,2)
    AuctionHouseFrame.BrowseResultsFrame.ItemList.HeaderContainer:SetPoint('RIGHT')
    AuctionHouseFrame.BrowseResultsFrame.ItemList.Background:SetPoint('BOTTOMRIGHT')

    AuctionHouseFrameAuctionsFrame.SummaryList.Background:SetPoint('BOTTOM')
    AuctionHouseFrameAuctionsFrame.AllAuctionsList.Background:SetPoint('BOTTOMRIGHT')
    AuctionHouseFrameAuctionsFrame.BidsList.Background:SetPoint('BOTTOMRIGHT')
    AuctionHouseFrame.WoWTokenResults.BuyoutLabel:ClearAllPoints()
    AuctionHouseFrame.WoWTokenResults.BuyoutLabel:SetPoint('BOTTOM', AuctionHouseFrame.WoWTokenResults.Buyout, 'TOP', 0, 32)
    AuctionHouseFrame.WoWTokenResults.Background:SetPoint('BOTTOMRIGHT')
    AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.Background:SetPoint('BOTTOM')
    AuctionHouseFrame.CommoditiesBuyFrame.ItemList.Background:SetPoint('BOTTOMRIGHT')

    AuctionHouseFrame.ItemBuyFrame.ItemList.HeaderContainer:SetPoint('RIGHT')
    AuctionHouseFrame.ItemBuyFrame.ItemList.Background:SetPoint('BOTTOMRIGHT')

    AuctionHouseFrame.ItemBuyFrame.ItemDisplay:SetPoint('RIGHT',-3, 0)
    AuctionHouseFrame.ItemBuyFrame.ItemDisplay.Background:SetPoint('RIGHT')

    WoWTools_DataMixin:Hook(AuctionHouseFrame, 'SetDisplayMode', function(frame, mode)
        local size= self:Save().size[frame:GetName()]
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

    --WoWTools_DataMixin:Hook(AchievementTemplateMixin, 'OnLoad', function(f)
--成就，显示，按钮
    WoWTools_DataMixin:Hook(AchievementTemplateMixin, 'OnLoad', function(f)
        f.Label:SetPoint('RIGHT', f.Shield.Icon, 'LEFT')
        f.Label:SetPoint('LEFT', f.PlusMinus, 'RIGHT')

        f.Description:SetPoint('RIGHT', f.Shield.Icon, 'LEFT')
        f.Description:SetPoint('LEFT', f.Icon, 'RIGHT')

        f.Reward:SetPoint('RIGHT', f.Shield.Icon, 'LEFT')
        f.Reward:SetPoint('LEFT', f.Icon, 'RIGHT')
    end)
    --WoWTools_DataMixin:Hook('AchievementObjectives_DisplayProgressiveAchievement', function(objectivesFrame, id)



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
    WoWTools_DataMixin:Hook(AchievementComparisonTemplateMixin, 'OnLoad', function(f)
        f.Player:SetPoint('RIGHT', -120, 0)
    end)
    AchievementFrameComparison.StatContainer:SetPoint('RIGHT', left, 0)


    AchievementFrame.Header:ClearAllPoints()
    AchievementFrame.Header:SetPoint('BOTTOM', AchievementFrame, 'TOP', 0, -38)

    AchievementFrameFilterDropdown:ClearAllPoints()
    AchievementFrameFilterDropdown:SetPoint('CENTER', AchievementFrame.Header.LeftDDLInset, -2, 3)

    --[[hooksecurefunc('AchievementObjectives_DisplayCriteria', function(objectivesFrame, id)
        if not id or not objectivesFrame or objectivesFrame:GetHeight()==0 then
            return
        end
        local numCriteria = GetAchievementNumCriteria(id)
        for i = 1, numCriteria do
            local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, criteriaFlags, assetID, quantityString = GetAchievementCriteriaInfo(id, i);
            if ( criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID ) then
            elseif ( bit.band(criteriaFlags, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR ) then

            else
            end
        end
    end)]]




    self:Setup(AchievementFrame, {
        minW=768,
        minH=500,
        sizeRestFunc= function()
            AchievementFrame:SetSize(768, 500)
        end,
    })
    self:Setup(AchievementFrame.Header, {frame=AchievementFrame})

--比较
    self:Setup(AchievementFrameComparisonHeader, {frame=AchievementFrame})
    self:Setup(AchievementFrameComparison, {frame=AchievementFrame})
    self:Setup(AchievementFrameComparison.AchievementContainer, {frame=AchievementFrame})

    WoWTools_DataMixin:Hook(AchievementFrame, 'SetWidth', function(f)
        if f.ResizeButton and not f.ResizeButton.isActiveButton then
            self:Set_SizeScale(f)
        end
    end)

--Search 结果
    AchievementFrame.SearchResults:SetPoint('TOP', 0, -14)
    self:Setup(AchievementFrame.SearchResults, {frame=AchievementFrame})
end

























--聊天设置
function WoWTools_MoveMixin.Events:Blizzard_Channels()
    self:Setup(ChannelFrame, {
        minW=402, minH=200, maxW=402,
    sizeRestFunc=function()
        ChannelFrame:SetSize(402, 423)
    end})
end

--选项
function WoWTools_MoveMixin.Events:Blizzard_Settings_Shared()
    for _, region in pairs({SettingsPanel:GetRegions()}) do
        if region:IsObjectType('Texture') then
            region:SetPoint('BOTTOMRIGHT', -12, 38)
        end
    end
    self:Setup(SettingsPanel, {minW=800, minH=200, sizeRestFunc=function(btn)
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





--菜单
function WoWTools_MoveMixin.Events:Blizzard_GameMenu()
    self:Setup(GameMenuFrame)
end


function WoWTools_MoveMixin.Events:Blizzard_ActionBar()
    self:Setup(ExtraActionButton1, {click='RightButton', notSave=true, notMoveAlpha=true})--额外技能
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
        if not InCombatLockdown() then
            PlayerSpellsFrame:ClearAllPoints()
            PlayerSpellsFrame:SetPoint(frame.p_point[1], UIParent, frame.p_point[3], frame.p_point[4], frame.p_point[5])
        end

    end)
    HeroTalentsSelectionDialog:HookScript('OnHide', function()
        self:SetPoint(PlayerSpellsFrame)
    end)
    --self:Setup(HeroTalentsSelectionDialog)



--天赋，法术书
    PlayerSpellsFrame:HookScript('OnShow', function(frame)
        self:Set_Frame_Scale(frame)
    end)
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
        minH=537, minW=800,
    sizeRestFunc=function()
        AccountStoreFrame:SetSize(800, 537)
    end})
end





--专业书
function WoWTools_MoveMixin.Events:Blizzard_ProfessionsBook()
    self:Setup(ProfessionsBookFrame)
end




--[[StaticPopup 11.2才有 Blizzard_StaticPopup就行
function WoWTools_MoveMixin.Events:Blizzard_StaticPopup_Game()
    --print('a')
    for i=1, 4 do
        local dialog= _G['StaticPopup'..i]
        if dialog then

            self:Setup(_G['StaticPopup'..i], {
                notSave=true,
            })

            if dialog.SetupAnchor then
                WoWTools_DataMixin:Hook(dialog, 'SetupAnchor', function(f)
                    self:SetPoint(f)
                end)
            end
        end
    end
end
]]


--LFDRoleCheckPopup
function WoWTools_MoveMixin.Events:Blizzard_StaticPopup()
    WoWTools_DataMixin:Hook('StaticPopup_SetUpPosition', function(dialog)
        if not dialog.moveFrameData then
            self:Setup(dialog)
        else
            self:SetPoint(dialog)--设置, 移动,
        end
    end)

end




function WoWTools_MoveMixin.Events:Blizzard_DurabilityFrame()
    self:Setup(DurabilityFrame, {notSave=true, notZoom=true})
end








function WoWTools_MoveMixin.Events:Blizzard_CooldownViewer()
    if not CooldownViewerSettings then--冷却设置 11.2.5
        return
    end
    --[[if WoWTools_DataMixin.Player.husandro then
        CooldownViewerSettings:Show()
    end]]


    local function on_settings(frame)
        local w=frame.CooldownScroll:GetWidth()
        local value= math.max(3, math.modf(w/46))

        local pool= frame.categoryPool:GetPool('CooldownViewerSettingsCategoryTemplate')
        if pool then
            for f in pool:EnumerateActive() do
                if f.Container.stride~=value then
                    f.Container.stride = value
                    f:Layout()
                end
                f:SetPoint('RIGHT', frame.CooldownScroll)
            end
        end

        pool= frame.categoryPool:GetPool('CooldownViewerSettingsBarCategoryTemplate')
        if pool then
            for f in pool:EnumerateActive() do
                f:SetPoint('RIGHT', frame.CooldownScroll)
                f.Container:SetPoint('RIGHT', -17, 0)
            end
        end
    end

    CooldownViewerSettings:HookScript('OnSizeChanged', function(frame)
        on_settings(frame)
    end)

    WoWTools_DataMixin:Hook(CooldownViewerSettings, 'RefreshLayout', function(frame)
       on_settings(frame)
    end)

    WoWTools_DataMixin:Hook(CooldownViewerSettingsBarItemMixin, 'RefreshData', function(frame)
        frame.Bar:SetPoint('RIGHT', CooldownViewerSettings.CooldownScroll, -17, 0)
    end)

    CooldownViewerSettings.SearchBox:SetPoint('RIGHT', -45, 0)

    self:Setup(CooldownViewerSettings, {
        minW=196, minH=183,
    sizeRestFunc=function()
        CooldownViewerSettings:SetSize(399, 609)
    end
    })
end







function WoWTools_MoveMixin.Events:Blizzard_AlliedRacesUI()
    self:Setup(AlliedRacesFrame)
end


 --11.2.7
function WoWTools_MoveMixin.Events:Blizzard_HousingDashboard()
    HousingDashboardFrame.HouseInfoContent.DashboardNoHousesFrame.Background:ClearAllPoints()
    HousingDashboardFrame.HouseInfoContent.DashboardNoHousesFrame.Background:SetAllPoints(HousingDashboardFrame.HouseInfoContent.DashboardNoHousesFrame)

    self:Setup(HousingDashboardFrame, {
        minW=405, minH=455,
    sizeRestFunc=function()
        HousingDashboardFrame:SetSize(814, 544)
    end})
    self:Setup(HousingDashboardFrame.HouseInfoContent.DashboardNoHousesFrame, {frame=HousingDashboardFrame})
end
--住房
function WoWTools_MoveMixin.Events:Blizzard_HousingBulletinBoard()
    HousingBulletinBoardFrame.ResidentsTab:SetPoint('BOTTOMRIGHT')
    self:Setup(HousingBulletinBoardFrame, {
    sizeRestFunc=function()
        HousingBulletinBoardFrame:SetSize(600, 400)
    end
    })
end

function WoWTools_MoveMixin.Events:Blizzard_HousingCharter()
    self:Setup(HousingCharterFrame)
end

--住宅区登记表
function WoWTools_MoveMixin.Events:Blizzard_HousingCreateNeighborhood()
    self:Setup(HousingCreateNeighborhoodCharterFrame)
end

function WoWTools_MoveMixin.Events:Blizzard_HousingCornerstone()
    self:Setup(HousingCornerstoneVisitorFrame)
    self:Setup(HousingCornerstonePurchaseFrame)
    self:Setup(HousingCornerstoneHouseInfoFrame)
end

--住宅搜索器
function WoWTools_MoveMixin.Events:Blizzard_HousingHouseFinder()
    HouseFinderFrame.HouseFinderMapCanvasFrame:SetPoint('BOTTOMRIGHT')
    HouseFinderFrame.NeighborhoodListFrame:SetPoint('BOTTOM')
    self:Setup(HouseFinderFrame,  {
    sizeRestFunc=function()
        HouseFinderFrame:SetSize(954, 489)
    end})
    self:Setup(HouseFinderFrame.PlotInfoFrame, {frame=HouseFinderFrame})
end

function WoWTools_MoveMixin.Events:Blizzard_HousingHouseSettings()
    self:Setup(HousingHouseSettingsFrame)
end

--function WoWTools_MoveMixin.Events:Blizzard_HousingControls()

--编辑住宅
function WoWTools_MoveMixin.Events:Blizzard_HouseEditor()
    HouseEditorFrame.StoragePanel.InputBlocker:ClearAllPoints()--HouseEditorStorageFrameTemplate
    WoWTools_TextureMixin:CreateBG(HouseEditorFrame.StoragePanel, {isColor=true, isAllpoint=true, alpha=0.5})

    local p= self:Save().point['HouseEditorFrame']
    if p and p[1] then
        HouseEditorFrame.StoragePanel:ClearAllPoints()
        HouseEditorFrame.StoragePanel:SetPoint(p[1], HouseEditorFrame, p[3], p[4], p[5])
    end
    HouseEditorFrame.StoragePanel:SetMovable(true)
    HouseEditorFrame.StoragePanel:SetClampedToScreen(false)
    HouseEditorFrame.StoragePanel:RegisterForDrag('LeftButton', 'RightButton')
    HouseEditorFrame.StoragePanel:SetScript('OnMouseUp', function()
        ResetCursor()
    end)
    HouseEditorFrame.StoragePanel:SetScript('OnMouseDown', function(_, d)
        if d=='RightButton' then
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    HouseEditorFrame.StoragePanel:SetScript("OnDragStart", function(frame)
        frame:StartMoving()
    end)
    HouseEditorFrame.StoragePanel:SetScript("OnDragStop", function(frame)
        ResetCursor()
        frame:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(frame) then
            self:Save().point['HouseEditorFrame']= {frame:GetPoint(1)}
            self:Save().point['HouseEditorFrame'][2]= nil
        end
    end)

--菜单
    local menu= CreateFrame('DropdownButton', 'WoWToolsHouseEditorFrameMenuButton', HouseEditorFrame.StoragePanel.SearchBox, 'WoWToolsMenuButtonTemplate')
    menu:SetPoint('RIGHT', HouseEditorFrame.StoragePanel.SearchBox, 'LEFT', -4, 0)
    function menu:set_scale()
        local s= WoWTools_MoveMixin:Save().scale['HouseEditorFrame'] or 1
        HouseEditorFrame.StoragePanel:SetScale(s)
    end
    menu:set_scale()
    menu:SetupMenu(function(frame, root)
 --缩放
        WoWTools_MenuMixin:ScaleRoot(frame, root, function()
            return self:Save().scale['HouseEditorFrame'] or 1
        end, function(value)
            self:Save().scale['HouseEditorFrame']= value
            frame:set_scale()
        end, function()
--重置缩放
            self:Save().scale['HouseEditorFrame']= nil
            frame:set_scale()
--重置位置
            if self:Save().point['HouseEditorFrame'] then
                self:Save().point['HouseEditorFrame']= nil
                HouseEditorFrame.StoragePanel:ClearAllPoints()
                HouseEditorFrame.StoragePanel:SetPoint('LEFT', 0, 150)--<Anchor point="LEFT" x="0" y="150"/> Blizzard_HouseEditor.xml
            end
            if self:Save().point['ExteriorCustomizationModeFrame'] then
                self:Save().point['ExteriorCustomizationModeFrame']= nil
                HouseEditorFrame.ExteriorCustomizationModeFrame.FixtureOptionList:ClearAllPoints()
                HouseEditorFrame.ExteriorCustomizationModeFrame.FixtureOptionList:SetPoint('TOPLEFT', HouseEditorFrame.ExteriorCustomizationModeFrame , 'LEFT', 80, -200)--<Anchor point="TOPLEFT" relativePoint="LEFT" x="80" y="200"/>
            end
        end)
    end)
    HouseEditorFrame.StoragePanel.SearchBox:SetPoint('TOPLEFT', 43, -20)--<Anchor point="TOPLEFT" x="20" y="-20"/>]]


    p= self:Save().point['ExteriorCustomizationModeFrame']
    if p and p[1] then
        HouseEditorFrame.ExteriorCustomizationModeFrame.FixtureOptionList:ClearAllPoints()
        HouseEditorFrame.ExteriorCustomizationModeFrame.FixtureOptionList:SetPoint(p[1], HouseEditorFrame.ExteriorCustomizationModeFrame, p[3], p[4], p[5])
    end
    HouseEditorFrame.ExteriorCustomizationModeFrame.FixtureOptionList:SetMovable(true)
    HouseEditorFrame.ExteriorCustomizationModeFrame.FixtureOptionList:SetClampedToScreen(false)
    HouseEditorFrame.ExteriorCustomizationModeFrame.FixtureOptionList:RegisterForDrag('LeftButton', 'RightButton')
    HouseEditorFrame.ExteriorCustomizationModeFrame.FixtureOptionList:SetScript('OnMouseUp', function()
        ResetCursor()
    end)
    HouseEditorFrame.ExteriorCustomizationModeFrame.FixtureOptionList:SetScript('OnMouseDown', function(_, d)
        if d=='RightButton' then
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    HouseEditorFrame.ExteriorCustomizationModeFrame.FixtureOptionList:SetScript("OnDragStart", function(frame)
        frame:StartMoving()
    end)
    HouseEditorFrame.ExteriorCustomizationModeFrame.FixtureOptionList:SetScript("OnDragStop", function(parent)
        ResetCursor()
        parent:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(parent) then
            self:Save().point['ExteriorCustomizationModeFrame']= {parent:GetPoint(1)}
            self:Save().point['ExteriorCustomizationModeFrame'][2]= nil
        end
    end)
    
    
end

