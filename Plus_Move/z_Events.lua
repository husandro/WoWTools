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

    hooksecurefunc(ZoneAbilityFrame, 'UpdateDisplayedZoneAbilities', function(frame)
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

    WoWTools_DataMixin:Hook(AchievementFrame, 'SetWidth', function(f)
        if f.ResizeButton and not f.ResizeButton.isActiveButton then
            self:Set_SizeScale(f)
        end
    end)
end














--地下城和团队副本 GroupFinderFrame
function WoWTools_MoveMixin.Events:Blizzard_GroupFinder()

    LFGListPVEStub:SetPoint('BOTTOMRIGHT')
    LFGListFrame.CategorySelection.Inset.CustomBG:SetPoint('BOTTOMRIGHT')
    --LFDQueueFrameBackground:SetPoint('RIGHT')
    LFDQueueFrame:SetPoint('BOTTOMRIGHT')

    WoWTools_DataMixin:Hook('GroupFinderFrame_SelectGroupButton', function(index)
        local btn= PVEFrame.ResizeButton
        if not btn or btn.disabledSize or not PVEFrame:IsProtected() then
            return
        end
        if index==3 then
            btn.setSize= true
            local size= self:Save().size['PVEFrame_PVE']
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
                WoWTools_DataMixin:Call(ChallengesFrame.Update, ChallengesFrame)
            end
        end, sizeStopFunc=function()
            if PVEFrame.activeTabIndex==1 then
                self:Save().size['PVEFrame_PVE']= {PVEFrame:GetSize()}
            elseif PVEFrame.activeTabIndex==2 then
                if PVPQueueFrame.selection==LFGListPVPStub then
                    self:Save().size['PVEFrame_PVP']= {PVEFrame:GetSize()}
                end
            elseif PVEFrame.activeTabIndex==3 then
                self:Save().size['PVEFrame_KEY']= {PVEFrame:GetSize()}
            end
        end, sizeRestFunc=function()
            if PVEFrame.activeTabIndex==1 then
                self:Save().size['PVEFrame_PVE']=nil
                PVEFrame:SetSize(PVE_FRAME_BASE_WIDTH, 428)
            elseif PVEFrame.activeTabIndex==2 then--Blizzard_PVPUI.lua
                self:Save().size['PVEFrame_PVP']=nil
                local width = PVE_FRAME_BASE_WIDTH;
                width = width + PVPQueueFrame.HonorInset:Update();
                PVEFrame:SetSize(width, 428)
            elseif PVEFrame.activeTabIndex==3 then
                self:Save().size['PVEFrame_KEY']=nil
                PVEFrame:SetSize(PVE_FRAME_BASE_WIDTH, 428)
                WoWTools_DataMixin:Call(ChallengesFrame.Update, ChallengesFrame)
            end
        end
    })

--自定义，副本，创建，更多...
    LFGListFrame.EntryCreation.ActivityFinder.Dialog:ClearAllPoints()
    LFGListFrame.EntryCreation.ActivityFinder.Dialog:SetPoint('TOPLEFT',0, -30)
    LFGListFrame.EntryCreation.ActivityFinder.Dialog:SetPoint('BOTTOMRIGHT')

--确定，进入副本
    WoWTools_MoveMixin:Setup(LFGDungeonReadyPopup, {
        notFuori=true,
        setResizeButtonPoint={'BOTTOMRIGHT', LFGDungeonReadyPopup, 6, -6},
    restPointFunc=function()
        LFGDungeonReadyPopup:ClearAllPoints()
        LFGDungeonReadyPopup:SetPoint('TOP', UIParent, 'TOP', 0, -135)
    end})
    WoWTools_MoveMixin:Setup(LFGDungeonReadyDialog, {notSize=true, frame=LFGDungeonReadyPopup})
    WoWTools_MoveMixin:Setup(LFGDungeonReadyStatus, {notSize=true, frame=LFGDungeonReadyPopup})
end









--地下城和团队副本, PVP
function WoWTools_MoveMixin.Events:Blizzard_PVPUI()
    PVPUIFrame:SetPoint('BOTTOMRIGHT')
    LFGListPVPStub:SetPoint('BOTTOMRIGHT')
    LFGListFrame.ApplicationViewer.InfoBackground:SetPoint('RIGHT', -2,0)

    WoWTools_DataMixin:Hook('PVPQueueFrame_ShowFrame', function()
        local btn= PVEFrame.ResizeButton
        if not btn or btn.disabledSize or WoWTools_FrameMixin:IsLocked(PVEFrame) then
            return
        end
        if PVPQueueFrame.selection==LFGListPVPStub then
            btn.setSize= true
            local size= self:Save().size['PVEFrame_PVP']
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
        local size= self:Save().size['PVEFrame_KEY']
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
        if WoWTools_FrameMixin:IsLocked(CharacterFrame) then
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

    WoWTools_DataMixin:Hook(CharacterFrame, 'UpdateSize', function(f)
        if not f.ResizeButton then
            return
        end
        local size
        if f.Expanded then
            f.ResizeButton.minWidth=450
            size= self:Save().size['CharacterFrameExpanded']
        else
            size= self:Save().size['CharacterFrameCollapse']
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
                WoWTools_DataMixin:Call(PaperDollEquipmentManagerPane_Update)
            end
            if PaperDollFrame.TitleManagerPane:IsVisible() then
                WoWTools_DataMixin:Call(PaperDollTitlesPane_Update)
            end
            if CharacterHeadSlot:IsVisible() then
                Set_Slot_Point()
            end
        end,
        sizeStopFunc=function()
            if CharacterFrame.Expanded then
                self:Save().size['CharacterFrameExpanded']={CharacterFrame:GetSize()}
            else
                self:Save().size['CharacterFrameCollapse']={CharacterFrame:GetSize()}
            end
            Set_Slot_Point()
        end,
        sizeRestFunc=function()
            if not WoWTools_FrameMixin:IsLocked(CharacterFrame) then
                if (self:Save().size['CharacterFrameExpanded'] or self:Save().size['CharacterFrameCollapse']) then
                    CharacterFrame:SetHeight(424)
                end
                self:Save().size['CharacterFrameExpanded']=nil
                self:Save().size['CharacterFrameCollapse']=nil
                WoWTools_DataMixin:Call(CharacterFrame.UpdateSize, CharacterFrame)
            end
        end,
        sizeRestTooltipColorFunc=function(f)
            return ((f.target.Expanded and self:Save().size['CharacterFrameExpanded']) or (not f.target.Expanded and self:Save().size['CharacterFrameCollapse'])) and '' or '|cff9e9e9e'
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
        setSize=true, minH=537, minW=800,
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
            self:Setup(dialog, {notSize=true, notFuori=true,})
        else
            self:SetPoint(dialog)--设置, 移动,
        end
    end)

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

    self:Setup(CooldownViewerSettings, {needSize=true, setSize=true, minW=196, minH=183,--maxW=399,
        sizeRestFunc=function()
            CooldownViewerSettings:SetSize(399, 609)
        end
    })
end

