local id, e = ...
WoWTools_MoveMixin={
Save={
    --disabledMove=true,--禁用移动
    point={},--移动
    SavePoint= e.Player.husandro,--保存窗口,位置
    moveToScreenFuori=e.Player.husandro,--可以移到屏幕外

    --disabledZoom=true,--禁用缩放
    scale={--缩放
        ['UIWidgetPowerBarContainerFrame']= e.Player.husandro and 0.85 or 1,
        ['ZoneAbilityFrame']= e.Player and 0.75 or 1,
    },
    size={},
    disabledSize={},--['CharacterFrame']= true

    --notMoveAlpha=true,--是否设置，移动时，设置透明度
    alpha=0.5,
    disabledAlpha={},
}
}

local function Save()
    return WoWTools_MoveMixin.Save
end


--WoWTools_MoveMixin:Setup(self, tab)


















































































































local function setAddLoad(arg1)
    if Save().disabled then
        return
    end

    if arg1=='Blizzard_TrainerUI' then--专业训练师
        WoWTools_MoveMixin:Setup(ClassTrainerFrame, {minW=328, minH=197, setSize=true, initFunc=function(btn)
            ClassTrainerFrameSkillStepButton:SetPoint('RIGHT', -12, 0)
            ClassTrainerFrameBottomInset:SetPoint('BOTTOMRIGHT', -4, 28)
            hooksecurefunc('ClassTrainerFrame_Update', function()--Blizzard_TrainerUI.lua
                ClassTrainerFrame.ScrollBox:SetPoint('BOTTOMRIGHT', -26, 34)
            end)
            btn.target.ScrollBox:ClearAllPoints()
        end, sizeRestFunc=function(self)
            self.target:SetSize(338, 424)
        end})

    elseif arg1=='Blizzard_TimeManager' then--小时图，时间
        WoWTools_MoveMixin:Setup(TimeManagerFrame, {save=true})

    elseif arg1=='Blizzard_AchievementUI' then--成就
        WoWTools_MoveMixin:Setup(AchievementFrame, {minW=768, maxW=768, minH=500, setSize=true, initFunc=function()
            AchievementFrameCategories:ClearAllPoints()
            AchievementFrameCategories:SetPoint('TOPLEFT', 21, -19)
            AchievementFrameCategories:SetPoint('BOTTOMLEFT', 175, 19)
            AchievementFrameMetalBorderRight:ClearAllPoints()

            AchievementFrame.SearchResults:SetPoint('TOP', 0, -15)
        end, sizeRestFunc=function(self)
            self.target:SetSize(768, 500)
        end})
        WoWTools_MoveMixin:Setup(AchievementFrameComparisonHeader, {frame=AchievementFrame})
        WoWTools_MoveMixin:Setup(AchievementFrameComparison, {frame=AchievementFrame})
        WoWTools_MoveMixin:Setup(AchievementFrame.Header, {frame=AchievementFrame})


    elseif arg1=='Blizzard_EncounterJournal' then--冒险指南
        WoWTools_MoveMixin:Setup(EncounterJournal, {minW=800, minH=496, maxW=800, setSize=true, initFunc=function()
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
        end, sizeRestFunc=function(self)
            self.target:SetSize(800, 496)
        end})
       --WoWTools_MoveMixin:Setup(EncounterJournal.NineSlice, {frame=EncounterJournal})



    elseif arg1=='Blizzard_AuctionHouseUI' then--拍卖行
        WoWTools_MoveMixin:Setup(AuctionHouseFrame, {setSize=true, initFunc=function()
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

            hooksecurefunc(AuctionHouseFrame, 'SetDisplayMode', function(self, mode)
                local size= Save().size[self:GetName()]
                if not size then
                    return
                end
                local btn= self.ResizeButton
                if mode==AuctionHouseFrameDisplayMode.ItemSell or mode==AuctionHouseFrameDisplayMode.CommoditiesSell then
                    self:SetSize(800, 538)
                    btn.minWidth = 800
                    btn.minHeight = 538
                    btn.maxWidth = 800
                    btn.maxHeight = 538
                else
                    self:SetSize(size[1], size[2])
                    btn.minWidth = 600
                    btn.minHeight = 320
                    btn.maxWidth = nil
                    btn.maxHeight = nil
                end
            end)
        end, sizeRestFunc=function(btn)
            btn.target:SetSize(800, 538)
        end})

        WoWTools_MoveMixin:Setup(AuctionHouseFrame.ItemSellFrame, {frame=AuctionHouseFrame})
        WoWTools_MoveMixin:Setup(AuctionHouseFrame.ItemSellFrame.Overlay, {frame=AuctionHouseFrame})
        WoWTools_MoveMixin:Setup(AuctionHouseFrame.ItemSellFrame.ItemDisplay, {frame=AuctionHouseFrame})

        WoWTools_MoveMixin:Setup(AuctionHouseFrame.CommoditiesSellFrame, {frame=AuctionHouseFrame})
        WoWTools_MoveMixin:Setup(AuctionHouseFrame.CommoditiesSellFrame.Overlay, {frame=AuctionHouseFrame})
        WoWTools_MoveMixin:Setup(AuctionHouseFrame.CommoditiesSellFrame.ItemDisplay, {frame=AuctionHouseFrame})

        WoWTools_MoveMixin:Setup(AuctionHouseFrame.ItemBuyFrame.ItemDisplay, {frame=AuctionHouseFrame, save=true})
        WoWTools_MoveMixin:Setup(AuctionHouseFrameAuctionsFrame.ItemDisplay, {frame=AuctionHouseFrame, save=true})

    elseif arg1=='Blizzard_BlackMarketUI' then--黑市
        WoWTools_MoveMixin:Setup(BlackMarketFrame)


























    elseif arg1=='Blizzard_Collections' then--收藏
        local function update_frame()
            local self= WardrobeCollectionFrame
            if self:IsShown() then
                if self.SetsTransmogFrame:IsShown() then
                    self.SetsTransmogFrame:ResetPage()--WardrobeSetsTransmogMixin
                    self:RefreshCameras()
                elseif self.ItemsCollectionFrame:IsShown() then
                    self.ItemsCollectionFrame:RefreshVisualsList()
                    self.ItemsCollectionFrame:UpdateItems()
                    self.ItemsCollectionFrame:ResetPage()
                    self:RefreshCameras()
                end

            end
        end



        local function init_sets_collenction(restButton, set)--套装
            local self= WardrobeCollectionFrame
            if self:GetParent()~=WardrobeFrame then
                return
            end

            local cols, rows
            local frame= self.SetsTransmogFrame

            frame.ModelR1C1:ClearAllPoints()
            frame.PagingFrame:ClearAllPoints()
            if Save().size[restButton.name] or set then--129 186
                cols= max(math.modf(frame:GetWidth()/(129+10)), frame.NUM_COLS or 4)--行，数量
                rows= max(math.modf(frame:GetHeight()/(186+10)), frame.NUM_ROWS or 2)--列，数量
                frame.ModelR1C1:SetPoint("TOPLEFT", frame, 6, -6)
                frame.PagingFrame:SetPoint('TOP', WardrobeCollectionFrame.SetsTransmogFrame, 'BOTTOM', 0, -2)
            else
                cols= frame.NUM_COLS or 4
                rows= frame.NUM_ROWS or 2
                frame.ModelR1C1:SetPoint("TOPLEFT", frame, 50, -75)
                frame.PagingFrame:SetPoint('BOTTOM', 0, 30)
            end

            local num= cols * rows--总数
            local numModel= #frame.Models--已存，数量

            for i= numModel+1, num, 1 do--创建，MODEL
                local model= CreateFrame('DressUpModel', nil, frame, 'WardrobeSetsTransmogModelTemplate')
                --model:OnLoad()
                table.insert(frame.Models, model)
            end

            for i=2, num do--设置位置
                local model= frame.Models[i]
                model:ClearAllPoints()
                model:SetPoint('LEFT', frame.Models[i-1], 'RIGHT', 10, 0)
                model:SetShown(true)
            end
            for i= cols+1, num, cols do
                local model= frame.Models[i]
                model:ClearAllPoints()
                model:SetPoint('TOP', frame.Models[i-cols], 'BOTTOM', 0, -10)
            end

            frame.PAGE_SIZE= num--设置，总数
            for i= num+1, #frame.Models, 1 do
                frame.Models[i]:SetShown(false)
            end
        end

        local function init_items_colllection(restButton, set)--物品
            if not restButton or not restButton.setSize then
                return
            end
            local frame= WardrobeCollectionFrame.ItemsCollectionFrame
            frame.PagingFrame:SetPoint('BOTTOM', 0, 2)
            frame.ModelR1C1:ClearAllPoints()
            frame.PagingFrame:ClearAllPoints()
            local cols, rows
            local w, h= frame.ModelR1C1:GetSize()--78, 104
            if Save().size[restButton.name] or set then
                if WardrobeCollectionFrame:GetParent()==WardrobeFrame then
                    frame.ModelR1C1:SetPoint("TOPLEFT", frame, 6, -6)
                    frame.PagingFrame:SetPoint('TOP', frame, 'BOTTOM', 0, -2)
                    cols= math.modf((frame:GetWidth()-36)/(w+10))
                    rows= math.modf((frame:GetHeight())/(h+10))
                else
                    frame.ModelR1C1:SetPoint("TOPLEFT", frame, 6, -60)
                    frame.PagingFrame:SetPoint('BOTTOM', 0, 2)
                    cols= math.modf((frame:GetWidth()-46)/(w+10))--行，数量
                    rows= math.modf((frame:GetHeight()-86)/(h+10))--列，数量
                end
            else
                cols= frame.NUM_COLS or 6
                rows= frame.NUM_ROWS or 3
                if WardrobeCollectionFrame:GetParent()==WardrobeFrame then
                    frame.ModelR1C1:SetPoint("TOPLEFT", frame, 50, -85)
                    frame.PagingFrame:SetPoint('BOTTOM', 0, 50)
                else
                    frame.ModelR1C1:SetPoint("TOPLEFT", frame, 71, -110)
                    frame.PagingFrame:SetPoint('BOTTOM', 0, 35)
                end
            end

            cols= max(cols, 6)--行，数量
            rows= max(rows, 3)--列，数量

            local num= cols * rows--总数
            local numModel= #frame.Models--已存，数量

            for i= numModel+1, num, 1 do--创建，MODEL
                local model= CreateFrame('DressUpModel', nil, frame, 'WardrobeItemsModelTemplate')
                table.insert(frame.Models, model)
            end

            for i=2, num do--设置位置
                local model= frame.Models[i]
                model:ClearAllPoints()
                model:SetPoint('LEFT', frame.Models[i-1], 'RIGHT', 16, 0)
                model:SetShown(true)
            end
            for i= cols+1, num, cols do
                local model= frame.Models[i]
                model:ClearAllPoints()
                model:SetPoint('TOP', frame.Models[i-cols], 'BOTTOM', 0, -10)
            end

            frame.PAGE_SIZE= num--设置，总数
            for i= num+1, #frame.Models, 1 do
                frame.Models[i]:SetShown(false)
            end
            init_sets_collenction(restButton, set)
        end


        WoWTools_MoveMixin:Setup(CollectionsJournal, {setSize=true, minW=703, minH=606, notInCombat=true, initFunc=function()
            MountJournal.RightInset:ClearAllPoints()
            MountJournal.RightInset:SetWidth(400)
            MountJournal.RightInset:SetPoint('TOPRIGHT', -6, -60)
            MountJournal.RightInset:SetPoint('BOTTOM', 0, 26)
            MountJournal.LeftInset:SetPoint('RIGHT', MountJournal.RightInset, 'LEFT', -24, 0)
            MountJournal.BottomLeftInset:SetPoint('TOPRIGHT', MountJournal.LeftInset, 'BOTTOMRIGHT', 0, -10)
            for _, region in pairs({MountJournal.BottomLeftInset:GetRegions()}) do
                region:SetPoint('RIGHT')
            end
            --MountJournalSearchBox:SetPoint('RIGHT', MountJournalFilterButton, 'LEFT', -2, 0)

            PetJournalRightInset:ClearAllPoints()
            PetJournalRightInset:SetPoint('TOPRIGHT', PetJournalPetCardInset, 'BOTTOMRIGHT', 0, -22)
            PetJournalRightInset:SetSize(411,171)
            PetJournalLeftInset:SetPoint('RIGHT', PetJournalRightInset, 'LEFT', -24, 0)
            PetJournalLoadoutBorder:ClearAllPoints()
            PetJournalLoadoutBorder:SetPoint('TOP', PetJournalRightInset)
            --PetJournalSearchBox:SetPoint('LEFT', PetJournalFilterButton, 'RIGHT',-2, 0)


            WardrobeCollectionFrame.SetsCollectionFrame.RightInset:ClearAllPoints()
            WardrobeCollectionFrame.SetsCollectionFrame.RightInset:SetWidth(410)
            WardrobeCollectionFrame.SetsCollectionFrame.RightInset:SetPoint('TOPRIGHT', 2, 0)
            WardrobeCollectionFrame.SetsCollectionFrame.RightInset:SetPoint('BOTTOM')
            WardrobeCollectionFrame.SetsCollectionFrame.ListContainer:SetPoint('RIGHT', WardrobeCollectionFrame.SetsCollectionFrame.RightInset, 'LEFT', -24, 0)
            WardrobeCollectionFrame.SetsCollectionFrame.ListContainer:SetPoint('BOTTOM')
            WardrobeCollectionFrame.SetsCollectionFrame.LeftInset:SetPoint('RIGHT', WardrobeCollectionFrame.SetsCollectionFrame.ListContainer)

            if _G['RematchFrame'] then
                local function rematch()
                    local self= _G['RematchFrame']
                    self:ClearAllPoints()
                    self:SetAllPoints(CollectionsJournal)

                    self.Canvas:ClearAllPoints()
                    self.Canvas:SetPoint('TOPLEFT', 2, -60)
                    self.Canvas:SetPoint('BOTTOMRIGHT', -2, 34)

                    self.LoadedTargetPanel:ClearAllPoints()
                    self.LoadedTargetPanel:SetPoint('TOP', self.ToolBar, 'BOTTOM')
                    self.LoadedTargetPanel:SetSize(277, 75)
                    self.LoadoutPanel:ClearAllPoints()
                    self.LoadoutPanel:SetPoint('TOP', self.LoadedTeamPanel, 'BOTTOM')
                    self.LoadoutPanel:SetWidth(277)
                    self.LoadoutPanel:SetPoint('BOTTOM')

                    self.PetsPanel:ClearAllPoints()
                    self.PetsPanel:SetPoint('TOPLEFT', self.ToolBar, 'BOTTOMLEFT')
                    self.PetsPanel:SetPoint('BOTTOMRIGHT', self.LoadoutPanel, 'BOTTOMLEFT',0,38)

                    self.OptionsPanel:ClearAllPoints()
                    self.OptionsPanel:SetPoint('TOPLEFT', self.LoadedTargetPanel, 'TOPRIGHT')
                    self.OptionsPanel:SetPoint('BOTTOMRIGHT', -4, 38)

                    self.TeamsPanel:ClearAllPoints()
                    self.TeamsPanel:SetPoint('TOPLEFT', self.LoadedTargetPanel, 'TOPRIGHT')
                    self.TeamsPanel:SetPoint('BOTTOMRIGHT', -4, 38)

                    self.TargetsPanel:ClearAllPoints()
                    self.TargetsPanel:SetPoint('TOPLEFT', self.LoadedTargetPanel, 'TOPRIGHT')
                    self.TargetsPanel:SetPoint('BOTTOMRIGHT', -4, 38)

                    self.QueuePanel:ClearAllPoints()
                    self.QueuePanel:SetPoint('TOPLEFT', self.LoadedTargetPanel, 'TOPRIGHT')
                    self.QueuePanel:SetPoint('BOTTOMRIGHT', -4, 38)
                    self.QueuePanel.List.Help:ClearAllPoints()
                    self.QueuePanel.List.Help:SetPoint('TOPLEFT', 8, 22)
                    self.QueuePanel.List.Help:SetPoint('BOTTOMRIGHT', -22, 22)
                end
                _G['RematchFrame']:HookScript('OnShow', rematch)
                hooksecurefunc(_G['RematchFrame'].PanelTabs, 'TabOnClick', rematch)
                WoWTools_MoveMixin:Setup(_G['RematchFrame'].TeamsPanel.List.ScrollBox, {frame=CollectionsJournal})
                WoWTools_MoveMixin:Setup(_G['RematchFrame'].QueuePanel.List.ScrollBox, {frame=CollectionsJournal})
            end
            C_Timer.After(2, function()
                local frame= _G['ManuscriptsJournal']
                if frame then
                    WoWTools_MoveMixin:Setup(frame, {frame=CollectionsJournal})
                end
            end)
        end, sizeUpdateFunc=function(btn)
            init_items_colllection(btn, true)
        end, sizeStopFunc=function(btn)
            Save().size[btn.name]= {btn.target:GetSize()}
            update_frame()
        end, sizeRestFunc=function(btn)
            btn.target:SetSize(703, 606)
            Save().size[btn.name]=nil
            init_items_colllection(btn)
            update_frame()
        end, scaleRestFunc=function()
            update_frame()
        end, scaleUpdateFunc=function()
        end})--藏品


        WoWTools_MoveMixin:Setup(WardrobeFrame, {setSize=true, minW=965, minH=606, initFunc=function(btn)
            WardrobeTransmogFrame:ClearAllPoints()
            WardrobeTransmogFrame:SetPoint('LEFT', 2, -28)
            WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox:ClearAllPoints()--两侧肩膀使用不同的幻化外观
            WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox:SetPoint('RIGHT', WardrobeTransmogFrame.ShoulderButton, 'LEFT', -6, 0)
            WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox.Label:ClearAllPoints()
            WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox.Label:SetPoint('RIGHT', WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox, 'LEFT')
        end, sizeUpdateFunc=function(btn)
            init_items_colllection(btn, true)

        end, sizeStopFunc=function(btn)
            Save().size[btn.name]= {btn.target:GetSize()}
            update_frame()
        end, sizeRestFunc=function(btn)
            WardrobeFrame:SetSize(965, 606)
            Save().size[btn.name]=nil
            init_items_colllection(btn)
        end, scaleStoppedFunc=function()
            update_frame()
        end, scaleRestFunc=function()
            update_frame()
        end})--幻化



        hooksecurefunc(WardrobeCollectionFrame, 'SetContainer', function(self, parent)
            local btn=parent.ResizeButton
            if not btn or not btn.setSize then
                return
            end
            if parent==CollectionsJournal then

            elseif parent==WardrobeFrame then
                self:SetPoint('BOTTOMLEFT', 300,0)
            end
            init_items_colllection(btn)
        end)


























    elseif arg1=='Blizzard_Calendar' then--日历
        WoWTools_MoveMixin:Setup(CalendarFrame)
        WoWTools_MoveMixin:Setup(CalendarEventPickerFrame, {frame=CalendarFrame})
        WoWTools_MoveMixin:Setup(CalendarTexturePickerFrame, {frame=CalendarFrame})
        WoWTools_MoveMixin:Setup(CalendarMassInviteFrame, {frame=CalendarFrame})
        WoWTools_MoveMixin:Setup(CalendarCreateEventFrame, {frame=CalendarFrame})
        WoWTools_MoveMixin:Setup(CalendarViewEventFrame, {frame=CalendarFrame})
        WoWTools_MoveMixin:Setup(CalendarViewHolidayFrame, {frame=CalendarFrame})
        WoWTools_MoveMixin:Setup(CalendarViewRaidFrame, {frame=CalendarFrame})

    elseif arg1=='Blizzard_GarrisonUI' then--要塞
        WoWTools_MoveMixin:Setup(GarrisonShipyardFrame)--海军行动
        WoWTools_MoveMixin:Setup(GarrisonMissionFrame)--要塞任务
        WoWTools_MoveMixin:Setup(GarrisonCapacitiveDisplayFrame)--要塞订单
        WoWTools_MoveMixin:Setup(GarrisonLandingPage)--要塞报告
        WoWTools_MoveMixin:Setup(OrderHallMissionFrame)

    elseif arg1=='Blizzard_PlayerChoice' then
        WoWTools_MoveMixin:Setup(PlayerChoiceFrame, {notZoom=true, notSave=true})--任务选择

    elseif arg1=="Blizzard_GuildBankUI" then--公会银行
        WoWTools_MoveMixin:Setup(GuildBankFrame)

    elseif arg1=='Blizzard_FlightMap' then--飞行地图
        WoWTools_MoveMixin:Setup(FlightMapFrame)

    elseif arg1=='Blizzard_OrderHallUI' then
        WoWTools_MoveMixin:Setup(OrderHallTalentFrame)

    elseif arg1=='Blizzard_GenericTraitUI' then
        WoWTools_MoveMixin:Setup(GenericTraitFrame)
        WoWTools_MoveMixin:Setup(GenericTraitFrame.ButtonsParent, {frame=GenericTraitFrame})

    elseif arg1=='Blizzard_WeeklyRewards' then--'Blizzard_EventTrace' then--周奖励面板
        WoWTools_MoveMixin:Setup(WeeklyRewardsFrame)
        WoWTools_MoveMixin:Setup(WeeklyRewardsFrame.Blackout, {frame=WeeklyRewardsFrame})

    elseif arg1=='Blizzard_ItemSocketingUI' then--镶嵌宝石，界面
        C_Timer.After(2, function()
            WoWTools_MoveMixin:Setup(ItemSocketingFrame)
            WoWTools_MoveMixin:Setup(ItemSocketingScrollChild, {frame=ItemSocketingFrame})
        end)
    elseif arg1=='Blizzard_ItemUpgradeUI' then--装备升级,界面
        WoWTools_MoveMixin:Setup(ItemUpgradeFrame)

    elseif arg1=='Blizzard_InspectUI' then--玩家, 观察角色, 界面
        if InspectFrame then
            WoWTools_MoveMixin:Setup(InspectFrame)
        end

    elseif arg1=='Blizzard_PVPUI' then--地下城和团队副本, PVP
        if not Save().disabledZoom then
            PVPUIFrame:SetPoint('BOTTOMRIGHT')
            LFGListPVPStub:SetPoint('BOTTOMRIGHT')
            LFGListFrame.ApplicationViewer.InfoBackground:SetPoint('RIGHT', -2,0)
            hooksecurefunc('PVPQueueFrame_ShowFrame', function()
                local btn= PVEFrame.ResizeButton
                if btn.disabledSize or UnitAffectingCombat('player') then
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

    elseif arg1=='Blizzard_ChallengesUI' then--挑战, 钥匙插件, 界面
        WoWTools_MoveMixin:Setup(ChallengesKeystoneFrame)

        if not Save().disabledZoom then
            ChallengesFrame.WeeklyInfo:SetPoint('BOTTOMRIGHT')
            ChallengesFrame.WeeklyInfo.Child:SetPoint('BOTTOMRIGHT')
            ChallengesFrame.WeeklyInfo.Child.RuneBG:SetPoint('BOTTOMRIGHT')
            for _, region in pairs({ChallengesFrame:GetRegions()}) do
                if region:GetObjectType()=='Texture' then
                    region:SetPoint('BOTTOMRIGHT')
                end
            end
            ChallengesFrame:HookScript('OnShow', function()
                local self= PVEFrame
                if self.ResizeButton.disabledSize or UnitAffectingCombat('player') then
                    return
                end
                local size= Save().size['PVEFrame_KEY']
                self.ResizeButton.setSize= true
                if size then
                    self:SetSize(size[1], size[2])
                else
                    self:SetSize(PVE_FRAME_BASE_WIDTH, 428)
                end
            end)
        end

    elseif arg1=='Blizzard_ItemInteractionUI' then--套装, 转换
        C_Timer.After(2, function()
            WoWTools_MoveMixin:Setup(ItemInteractionFrame)
        end)

    elseif arg1=='Blizzard_Professions' then--专业
        WoWTools_MoveMixin:Setup(ProfessionsFrame, {setSize=true, initFunc=function()--ProfessionsUtil.SetCraftingMinimized(false)
            ProfessionsFrame.CraftingPage.P_GetDesiredPageWidth= ProfessionsFrame.CraftingPage.GetDesiredPageWidth
            function ProfessionsFrame.CraftingPage:GetDesiredPageWidth()--Blizzard_ProfessionsCrafting.lua
                local size, scale
                local frame= self:GetParent()
                local name= frame:GetName()
                if ProfessionsUtil.IsCraftingMinimized() then
                    scale= Save().scale[name..'Mini']
                    size= Save().size[name..'Mini']

                else
                    scale= Save().scale[name..'Normal']
                    size= Save().size[name..'Normal']
                end
                if scale then
                    frame:SetScale(scale)
                end
                if size then
                    frame:SetSize(size[1], size[2])
                    return size[1]
                else
                    return self:P_GetDesiredPageWidth()--404
                end
            end
            ProfessionsFrame.OrdersPage.P_GetDesiredPageWidth= ProfessionsFrame.OrdersPage.GetDesiredPageWidth
            function ProfessionsFrame.OrdersPage:GetDesiredPageWidth()--Blizzard_ProfessionsCrafterOrderPage.lua
                local frame= self:GetParent()
                local name= frame:GetName()
                local scale= Save().scale[name..'Order']
                local size= Save().size[name..'Order']
                if scale then
                    frame:SetScale(scale)
                end
                if size then
                    frame:SetSize(size[1], size[2])
                    return size[1]
                else
                    return self:P_GetDesiredPageWidth()-- 1105
                end
            end
            ProfessionsFrame.SpecPage.P_GetDesiredPageWidth= ProfessionsFrame.SpecPage.GetDesiredPageWidth
            function ProfessionsFrame.SpecPage:GetDesiredPageWidth()--Blizzard_ProfessionsSpecializations.lua
                local frame= self:GetParent()
                local name= frame:GetName()
                local scale= Save().scale[name..'Spec']
                local size= Save().size[name..'Spec']
                if scale then
                    frame:SetScale(scale)
                end
                if size then
                    frame:SetSize(size[1], size[2])
                    return size[1]
                else
                    return self:P_GetDesiredPageWidth()--1144
                end
            end
            local function set_on_show(self)
                C_Timer.After(0.3, function()
                    local size, scale
                    local name= self:GetName()
                    if ProfessionsUtil.IsCraftingMinimized() then
                        scale= Save().scale[name..'Mini']
                        size= Save().size[name..'Mini']
                        self.ResizeButton.minWidth= 404
                        self.ResizeButton.minHeight= 650
                    elseif self.TabSystem.selectedTabID==1 then
                        scale= Save().scale[name..'Normal']
                        size= Save().size[name..'Normal']
                        self.ResizeButton.minWidth= 830
                        self.ResizeButton.minHeight= 580
                        if size then
                            self:Refresh()
                        end
                    elseif self.TabSystem.selectedTabID==2 then
                        scale= Save().scale[name..'Spec']
                        size= Save().size[name..'Spec']
                        self.ResizeButton.minWidth= 1144
                        self.ResizeButton.minHeight= 658
                    elseif self.TabSystem.selectedTabID==3 then
                        scale= Save().scale[name..'Order']
                        size= Save().size[name..'Order']
                        self.ResizeButton.minWidth= 1050
                        self.ResizeButton.minHeight= 240
                        if size then
                            self:Refresh()
                        end
                    end
                    if scale then
                        self:SetScale(scale)
                    end
                    if size then
                        self:SetSize(size[1], size[2])
                    end
                end)
            end
            ProfessionsFrame:HookScript('OnShow', set_on_show)
            for _, tabID in pairs(ProfessionsFrame:GetTabSet() or {}) do
                local btn= ProfessionsFrame:GetTabButton(tabID)
                btn:HookScript('OnClick', function()
                    set_on_show(ProfessionsFrame)
               end)
            end
            hooksecurefunc(ProfessionsFrame, 'ApplyDesiredWidth', set_on_show)

            --655 553
            local function set_craftingpage_position(self)
                self.SchematicForm:ClearAllPoints()
                self.SchematicForm:SetPoint('TOPRIGHT', -5, -72)
                self.SchematicForm:SetPoint('BOTTOMRIGHT', 670, 5)
                self.RecipeList:ClearAllPoints()
                self.RecipeList:SetPoint('TOPLEFT', 5, -72)
                self.RecipeList:SetPoint('BOTTOMLEFT', 5, 5)
                self.RecipeList:SetPoint('TOPRIGHT', self.SchematicForm, 'TOPLEFT')
            end

            set_craftingpage_position(ProfessionsFrame.CraftingPage)
            function ProfessionsFrame.CraftingPage:SetMaximized()
                set_craftingpage_position(self)
                self:Refresh(self.professionInfo)
            end
            hooksecurefunc(ProfessionsFrame.CraftingPage, 'SetMinimized', function(self)
                self.SchematicForm.Details:ClearAllPoints()
                self.SchematicForm.Details:SetPoint('BOTTOM', 0, 33)
                self.SchematicForm:SetPoint('BOTTOMRIGHT')
            end)
            ProfessionsFrame.CraftingPage.RankBar:ClearAllPoints()
            ProfessionsFrame.CraftingPage.RankBar:SetPoint('RIGHT', ProfessionsFrame.CraftingPage.Prof1Gear1Slot, 'LEFT', -36, 0)

            ProfessionsFrame.CraftingPage.SchematicForm.MinimalBackground:ClearAllPoints()
            ProfessionsFrame.CraftingPage.SchematicForm.MinimalBackground:SetAllPoints(ProfessionsFrame.CraftingPage.SchematicForm)

            ProfessionsFrame.SpecPage.TreeView:ClearAllPoints()
            ProfessionsFrame.SpecPage.TreeView:SetPoint('TOPLEFT', 2, -85)
            ProfessionsFrame.SpecPage.TreeView:SetPoint('BOTTOM', 0, 50)
            ProfessionsFrame.SpecPage.DetailedView:ClearAllPoints()
            ProfessionsFrame.SpecPage.DetailedView:SetPoint('TOPLEFT', ProfessionsFrame.SpecPage.TreeView, 'TOPRIGHT', -40, 0)
            ProfessionsFrame.SpecPage.DetailedView:SetPoint('BOTTOMRIGHT', 0, 50)

            ProfessionsFrame.SpecPage.PanelFooter:ClearAllPoints()
            ProfessionsFrame.SpecPage.PanelFooter:SetPoint('BOTTOMLEFT', 0, 4)
            ProfessionsFrame.SpecPage.PanelFooter:SetPoint('BOTTOMRIGHT')

            ProfessionsFrame.OrdersPage.BrowseFrame.OrderList:ClearAllPoints()
            ProfessionsFrame.OrdersPage.BrowseFrame.OrderList:SetPoint('TOPRIGHT', 0, -92)
            ProfessionsFrame.OrdersPage.BrowseFrame.OrderList:SetWidth(800)
            ProfessionsFrame.OrdersPage.BrowseFrame.OrderList:SetPoint('BOTTOM', 0, 5)
            ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList:ClearAllPoints()
            ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList:SetPoint('TOPLEFT', 5, -92)
            ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList:SetPoint('BOTTOMRIGHT', ProfessionsFrame.OrdersPage.BrowseFrame.OrderList, 'BOTTOMLEFT')
            for _, region in pairs({ProfessionsFrame.SpecPage.PanelFooter:GetRegions()}) do
                if region:GetObjectType()=='Texture' then
                    region:ClearAllPoints()
                    region:SetAllPoints(ProfessionsFrame.SpecPage.PanelFooter)
                    break
                end
            end
            hooksecurefunc(ProfessionsRecipeListRecipeMixin, 'Init', function(self)
                self.Label:SetPoint('RIGHT', -22, 0)
            end)
        end, scaleStoppedFunc=function(btn)
            local self= btn.target
            local sacle= self:GetScale()
            local name= btn.name
            if ProfessionsUtil.IsCraftingMinimized() then
                Save().scale[name..'Mini']= sacle
            elseif self.TabSystem.selectedTabID==2 then
                Save().scale[name..'Spec']= sacle
            elseif self.TabSystem.selectedTabID==3 then
                Save().scale[name..'Order']= sacle
            else
                Save().scale[name..'Normal']= sacle
            end
        end, scaleRestFunc=function(btn)
            local self= btn.target
            local name= btn.name
            if ProfessionsUtil.IsCraftingMinimized() then
                Save().scale[name..'Mini']= nil
            elseif self.TabSystem.selectedTabID==2 then
                Save().scale[name..'Spec']= nil
            elseif self.TabSystem.selectedTabID==3 then
                Save().scale[name..'Order']= nil
            else
                Save().scale[name..'Normal']= nil
            end
        end, sizeRestTooltipColorFunc= function(btn)
            local name= btn.name
            if ProfessionsUtil.IsCraftingMinimized() then
                return Save().size[name..'Mini'] and '' or '|cff9e9e9e'
            elseif btn.target.TabSystem.selectedTabID==2 then
                return Save().size[name..'Spec'] and '' or '|cff9e9e9e'
            elseif btn.target.TabSystem.selectedTabID==3 then
                return Save().size[name..'Order'] and '' or '|cff9e9e9e'
            else
                return Save().size[name..'Normal'] and '' or '|cff9e9e9e'
            end
        end, sizeStopFunc=function(btn)
            local self= btn.target
            local name= btn.name
            local size= {self:GetSize()}
            if ProfessionsUtil.IsCraftingMinimized() then
                Save().size[name..'Mini']= size
            elseif self.TabSystem.selectedTabID==2 then
                Save().size[name..'Spec']= size
            elseif self.TabSystem.selectedTabID==3 then
                Save().size[name..'Order']= size
                self:Refresh()
            else
                Save().size[name..'Normal']= size
                self:Refresh()
            end
        end, sizeRestFunc=function(btn)
            local self= btn.target
            local name= btn.name
            if ProfessionsUtil.IsCraftingMinimized() then
                self:SetSize(404, 658)
                Save().size[name..'Mini']=nil
            elseif self.TabSystem.selectedTabID==2 then
                self:SetSize(1144, 658)
                Save().size[name..'Spec']=nil
            elseif self.TabSystem.selectedTabID==3 then
                self:SetSize(1105, 658)
                Save().size[name..'Order']=nil
            else
                self:SetSize(942, 658)
                Save().size[name..'Normal']=nil
                self:Refresh(self.professionInfo)
            end
        end})

    elseif arg1=='Blizzard_ProfessionsBook' then--专业书
        WoWTools_MoveMixin:Setup(ProfessionsBookFrame)

    elseif arg1=='Blizzard_ProfessionsCustomerOrders' then--专业定制
        WoWTools_MoveMixin:Setup(ProfessionsCustomerOrdersFrame, {setSize=true, minW=825, minH=200, onShowFunc=true, initFunc=function()
            ProfessionsCustomerOrdersFrame.BrowseOrders:ClearAllPoints()
            ProfessionsCustomerOrdersFrame.BrowseOrders:SetPoint('TOPLEFT')
            ProfessionsCustomerOrdersFrame.BrowseOrders:SetPoint('BOTTOMRIGHT')
            ProfessionsCustomerOrdersFrame.BrowseOrders.RecipeList:ClearAllPoints()
            ProfessionsCustomerOrdersFrame.BrowseOrders.RecipeList:SetPoint('TOPRIGHT', 0, -72)
            ProfessionsCustomerOrdersFrame.BrowseOrders.RecipeList:SetWidth(660)
            ProfessionsCustomerOrdersFrame.BrowseOrders.RecipeList:SetPoint('BOTTOM', 0, 29)
            ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList:ClearAllPoints()
            ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList:SetPoint('TOPLEFT', 0, -72)
            ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList:SetPoint('BOTTOMRIGHT', ProfessionsCustomerOrdersFrame.BrowseOrders.RecipeList, 'BOTTOMLEFT', 4, 0)
            ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList.ScrollBox:SetPoint('RIGHT', -12,0)
            ProfessionsCustomerOrdersFrame.MyOrdersPage:ClearAllPoints()
            ProfessionsCustomerOrdersFrame.MyOrdersPage:SetPoint('TOPLEFT')
            ProfessionsCustomerOrdersFrame.MyOrdersPage:SetPoint('BOTTOMRIGHT')
            hooksecurefunc(ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList.ScrollBox, 'Update', function(self)
                if not self:GetView() then
                    return
                end
                for _, btn in pairs(self:GetFrames() or {}) do
                    btn.HighlightTexture:SetPoint('RIGHT')
                    btn.NormalTexture:SetPoint('RIGHT')
                    btn.SelectedTexture:SetPoint('RIGHT')
                end
            end)
            ProfessionsCustomerOrdersFrame.Form:HookScript('OnHide', function(self)
                local frame= self:GetParent()
                if frame.ResizeButton.disabledSize then
                    return
                end
                frame.ResizeButton.setSize=true
                local name= frame:GetName()
                local scale= Save().scale[name]
                if scale then
                    frame:SetScale(scale)
                end
                local size= Save().size[name]
                if size then
                    frame:SetSize(size[1], size[2])
                end
            end)
            ProfessionsCustomerOrdersFrame.Form:HookScript('OnShow', function(self)
                local frame= self:GetParent()
                if frame.ResizeButton.disabledSize then
                    return
                end
                frame.ResizeButton.setSize= false
                local name= frame:GetName()
                local scale= Save().scale[name..'From']
                if scale then
                    frame:SetScale(scale)
                end
                if Save().size[name] then
                    frame:SetSize(825, 568)
                end
            end)
        end, scaleStoppedFunc=function(btn)
            local self= btn.target
            local name= btn.name
            if self.Form:IsShown() then
                Save().scale[name..'From']= self:GetScale()
            else
                Save().scale[name]= self:GetScale()
            end
        end, scaleRestFunc=function(btn)
            local name= btn.name
            if btn.target.Form:IsShown() then
                Save().scale[name..'From']= nil
            else
                Save().scale[name]= nil
            end
        end, sizeRestFunc=function(btn)
            btn.target:SetSize(825, 568)
        end})

        WoWTools_MoveMixin:Setup(ProfessionsCustomerOrdersFrame.Form, {frame=ProfessionsCustomerOrdersFrame})

        WoWTools_MoveMixin:Setup(InspectRecipeFrame)

    elseif arg1=='Blizzard_VoidStorageUI' then--虚空，仓库
         WoWTools_MoveMixin:Setup(VoidStorageFrame)

    elseif arg1=='Blizzard_ChromieTimeUI' then--时光漫游
        WoWTools_MoveMixin:Setup(ChromieTimeFrame)


    elseif arg1=='Blizzard_BFAMissionUI' then--侦查地图
        WoWTools_MoveMixin:Setup(BFAMissionFrame)

    elseif arg1=='Blizzard_MacroUI' then--宏
        C_Timer.After(2, function()--给 Macro.lua 用
            WoWTools_MoveMixin:Setup(MacroFrame)
        end)

    elseif arg1=='Blizzard_MajorFactions' then--派系声望
        WoWTools_MoveMixin:Setup(MajorFactionRenownFrame)

    elseif arg1=='Blizzard_DebugTools' then--FSTACK
        WoWTools_MoveMixin:Setup(TableAttributeDisplay, {minW=476, minH=150, setSize=true, initFunc=function()
            TableAttributeDisplay.LinesScrollFrame:ClearAllPoints()
            TableAttributeDisplay.LinesScrollFrame:SetPoint('TOPLEFT', 6, -62)
            TableAttributeDisplay.LinesScrollFrame:SetPoint('BOTTOMRIGHT', -36, 22)
            TableAttributeDisplay.FilterBox:SetPoint('RIGHT', -26,0)
            TableAttributeDisplay.TitleButton.Text:SetPoint('RIGHT')
            hooksecurefunc(TableAttributeLineReferenceMixin, 'Initialize', function(self, _, _, attributeData)
                local frame= self:GetParent():GetParent():GetParent()
                local btn= frame.ResizeButton
                if btn and btn.setSize then
                    local w= frame:GetWidth()-200
                    self.ValueButton:SetWidth(w)
                    self.ValueButton.Text:SetWidth(w)
                end
            end)
            hooksecurefunc(TableAttributeDisplay, 'UpdateLines', function(self)
                if self.dataProviders then
                    for _, line in ipairs(self.lines) do
                        if line.ValueButton then
                            local w= self:GetWidth()-200
                            line.ValueButton:SetWidth(w)
                            line.ValueButton.Text:SetWidth(w)
                        end
                    end
                end
            end)
        end, sizeUpdateFunc=function(btn)
            btn.target:UpdateLines()--RefreshAllData()
        end, sizeRestFunc=function(btn)
            btn.target:SetSize(500, 400)
        end})

    elseif arg1=='Blizzard_EventTrace' then--ETRACE
        EventTrace.Log.Bar.SearchBox:SetPoint('LEFT', EventTrace.Log.Bar.Label, 'RIGHT')
        EventTrace.Log.Bar.SearchBox:SetScript('OnEditFocusGained', function(self)
            self:HighlightText()
        end)
        WoWTools_MoveMixin:Setup(EventTrace)

    elseif arg1=='Blizzard_DeathRecap' then--死亡
        WoWTools_MoveMixin:Setup(DeathRecapFrame, {save=true})

    elseif arg1=='Blizzard_ClickBindingUI' then--点击，施法
        WoWTools_MoveMixin:Setup(ClickBindingFrame)
        WoWTools_MoveMixin:Setup(ClickBindingFrame.ScrollBox, {frame=ClickBindingFrame})

    elseif arg1=='Blizzard_ArchaeologyUI' then
        WoWTools_MoveMixin:Setup(ArchaeologyFrame)

    elseif arg1=='Blizzard_CovenantRenown' then
        WoWTools_MoveMixin:Setup(CovenantRenownFrame)

    elseif arg1=='Blizzard_ScrappingMachineUI' then
        WoWTools_MoveMixin:Setup(ScrappingMachineFrame)

    elseif arg1=='Blizzard_PlayerSpells' then--法术书
        WoWTools_MoveMixin:Setup(PlayerSpellsFrame)
        for specContentFrame in PlayerSpellsFrame.SpecFrame.SpecContentFramePool:EnumerateActive() do
            WoWTools_MoveMixin:Setup(specContentFrame, {frame=PlayerSpellsFrame})
        end

        WoWTools_MoveMixin:Setup(PlayerSpellsFrame.TalentsFrame, {frame=PlayerSpellsFrame})
        WoWTools_MoveMixin:Setup(PlayerSpellsFrame.TalentsFrame.ButtonsParent, {frame=PlayerSpellsFrame})
        WoWTools_MoveMixin:Setup(PlayerSpellsFrame.SpellBookFrame, {frame=PlayerSpellsFrame})


    elseif arg1=='Blizzard_ArtifactUI' then
        WoWTools_MoveMixin:Setup(ArtifactFrame)

    elseif arg1=='Blizzard_DelvesDashboardUI' then
        WoWTools_MoveMixin:Setup(DelvesCompanionConfigurationFrame)
        WoWTools_MoveMixin:Setup(DelvesCompanionAbilityListFrame)

    elseif arg1=='Blizzard_HelpFrame' then
        WoWTools_MoveMixin:Setup(HelpFrame)
        WoWTools_MoveMixin:Setup(HelpFrame.TitleContainer, {frame=HelpFrame})
    end
end




















































--########
--初始,移动
--########
local function Init_Move()
    WoWTools_MoveMixin:Init_Communities()--公会和社区
    WoWTools_MoveMixin:Init_WorldMapFrame()--世界地图
    WoWTools_MoveMixin:Init_CharacterFrame()--角色
    WoWTools_MoveMixin:Init_FriendsFrame()--好友列表
    WoWTools_MoveMixin:Init_PVEFrame()--地下城和团队副本
    WoWTools_MoveMixin:Init_QuestFrame()--任务
    WoWTools_MoveMixin:Init_AddButton()--添加，移动/缩放，按钮
    WoWTools_MoveMixin:Init_Other()
    WoWTools_MoveMixin:Init_Class_Power()--职业，能量条
end




























--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('MAIL_SHOW')

local eventTab={}
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if WoWToolsSave['Frame'] then
                WoWTools_MoveMixin.Save= WoWToolsSave['Frame']
                Save().scale= Save().scale or {}
                Save().size= Save().size or {}
                Save().disabledSize= Save().disabledSize or {}
                Save().disabledAlpha= Save().disabledAlpha or {}
                Save().alpha= Save().alpha or 0.5
                WoWToolsSave['Frame']=nil
            else
                WoWTools_MoveMixin.Save= WoWToolsSave['Plus_Move'] or WoWTools_MoveMixin.Save
            end

            WoWTools_MoveMixin.addName= '|TInterface\\Cursor\\UI-Cursor-Move:0|t'..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, e.onlyChinese and '移动' or NPE_MOVE, 'Frame')

            WoWTools_MoveMixin:Init_Options()
           

            if Save().disabled then
                self:UnregisterAllEvents()
            else
                Init_Move()--初始, 移动
               
                for _, ent in pairs(eventTab or {}) do
                    setAddLoad(ent)
                end
            end
            eventTab=nil
            self:RegisterEvent("PLAYER_LOGOUT")

        else
            if eventTab then
                table.insert(eventTab, arg1)
            else
                setAddLoad(arg1)
            end
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_Move']=Save()
        end

    elseif event=='MAIL_SHOW' then
         C_Timer.After(2, function()
            WoWTools_MoveMixin:Setup(MailFrame)--邮箱，信件， Mail.lua，有操作
        end)
        self:UnregisterEvent('MAIL_SHOW')
    end

end)