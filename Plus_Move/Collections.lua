--收藏
function WoWTools_MoveMixin.Events:Blizzard_Collections()
--坐骑
    MountJournal.RightInset:ClearAllPoints()
    MountJournal.RightInset:SetWidth(400)
    MountJournal.RightInset:SetPoint('TOPRIGHT', -6, -60)
    MountJournal.RightInset:SetPoint('BOTTOM', MountJournal, 0, 26)

    MountJournal.LeftInset:ClearAllPoints()
    MountJournal.LeftInset:SetPoint('TOPRIGHT', MountJournal.RightInset, 'TOPLEFT', -24, 0)
    MountJournal.LeftInset:SetPoint('LEFT', 6, 0)
    MountJournal.LeftInset:SetPoint('BOTTOM', MountJournalMountButton, 'TOP', 0, 2)

    MountJournal.BottomLeftInset:ClearAllPoints()
    MountJournal.BottomLeftInset:SetPoint('BOTTOM', MountJournal.RightInset)
    MountJournal.BottomLeftInset:SetSize(279, 75)
    MountJournal.BottomLeftInset:SetFrameStrata('DIALOG')

    MountJournal.MountDisplay.ModelScene.TogglePlayer:SetScript('OnLeave', GameTooltip_Hide)
    MountJournal.MountDisplay.ModelScene.TogglePlayer:SetScript('OnEnter', function(frame)
        GameTooltip:SetOwner(frame, 'ANCHOR_LEFT')
        GameTooltip:SetText(WoWTools_DataMixin.onlyChinese and '显示角色' or MOUNT_JOURNAL_PLAYER)
        GameTooltip:Show()
    end)
    MountJournal.MountDisplay.ModelScene.TogglePlayer.TogglePlayerText:SetText('')
    MountJournal.MountDisplay.ModelScene.TogglePlayer.TogglePlayerText:SetAlpha(0)


    MountJournal.MountDisplay.ModelScene.ControlFrame:ClearAllPoints()
    MountJournal.MountDisplay.ModelScene.ControlFrame:SetPoint('TOP', MountJournalLore, 'BOTTOM', 0, -12)
    WoWTools_DataMixin:Hook('MountJournal_InitMountButton', function(btn)
        if btn.is_setting then
            return
        end
        btn.is_setting= true
        btn.name:SetPoint('RIGHT', -4, 0)
        btn.background:SetTexture(0)
        btn.background:SetColorTexture(0, 0, 0, 0.5)
    end)


--宠物
    PetJournalRightInset:ClearAllPoints()
    PetJournalRightInset:SetPoint('TOPRIGHT', PetJournalPetCardInset, 'BOTTOMRIGHT', 0, -22)
    PetJournalRightInset:SetSize(411,171)
    PetJournalLeftInset:SetPoint('RIGHT', PetJournalRightInset, 'LEFT', -24, 0)
    PetJournalLoadoutBorder:ClearAllPoints()
    PetJournalLoadoutBorder:SetPoint('TOP', PetJournalRightInset)



--外观，物品 WardrobeFrame 没有了
    WardrobeCollectionFrame:HookScript('OnSizeChanged', function(frame)
        local itemFrame= frame.ItemsCollectionFrame

        itemFrame.PagingFrame:SetPoint('BOTTOM', 0, 2)
        itemFrame.ModelR1C1:ClearAllPoints()
        itemFrame.PagingFrame:ClearAllPoints()

        local cols, rows
        local w, h= itemFrame.ModelR1C1:GetSize()--78, 104

        if self:Save().size['CollectionsJournal'] then
            itemFrame.ModelR1C1:SetPoint("TOPLEFT", itemFrame, 6, -60)
            itemFrame.PagingFrame:SetPoint('BOTTOM', 0, 2)
            cols= math.modf((itemFrame:GetWidth()-46)/(w+10))--行，数量
            rows= math.modf((itemFrame:GetHeight()-86)/(h+10))--列，数量
        else
            cols= itemFrame.NUM_COLS or 6
            rows= itemFrame.NUM_ROWS or 3
            itemFrame.ModelR1C1:SetPoint("TOPLEFT", itemFrame, 71, -110)
            itemFrame.PagingFrame:SetPoint('BOTTOM', 0, 35)
        end

        cols= max(cols, 6)--行，数量
        rows= max(rows, 3)--列，数量

        local num= cols * rows--总数
        local numModel= #itemFrame.Models--已存，数量

        for _ = numModel+1, num, 1 do--创建，MODEL
            local model= CreateFrame('DressUpModel', nil, itemFrame, 'WardrobeItemsModelTemplate')
            table.insert(itemFrame.Models, model)
        end

        for i=2, num do--设置位置
            local model= itemFrame.Models[i]
            model:ClearAllPoints()
            model:SetPoint('LEFT', itemFrame.Models[i-1], 'RIGHT', 16, 0)
            model:SetShown(true)
        end
        for i= cols+1, num, cols do
            local model= itemFrame.Models[i]
            model:ClearAllPoints()
            model:SetPoint('TOP', itemFrame.Models[i-cols], 'BOTTOM', 0, -10)
        end

        itemFrame.PAGE_SIZE= num--设置，总数

        for i= num+1, #itemFrame.Models, 1 do
            itemFrame.Models[i]:SetShown(false)
        end
--更新
        if itemFrame:IsVisible() then
            itemFrame:RefreshVisualsList()
            itemFrame:UpdateItems()
            itemFrame:ResetPage()
            frame:RefreshCameras()
        end
    end)


--外观，套装
    WardrobeCollectionFrame.SetsCollectionFrame.RightInset:ClearAllPoints()
    WardrobeCollectionFrame.SetsCollectionFrame.RightInset:SetWidth(410)
    WardrobeCollectionFrame.SetsCollectionFrame.RightInset:SetPoint('TOPRIGHT', 2, 0)
    WardrobeCollectionFrame.SetsCollectionFrame.RightInset:SetPoint('BOTTOM')
    WardrobeCollectionFrame.SetsCollectionFrame.ListContainer:SetPoint('RIGHT', WardrobeCollectionFrame.SetsCollectionFrame.RightInset, 'LEFT', -24, 0)
    WardrobeCollectionFrame.SetsCollectionFrame.ListContainer:SetPoint('BOTTOM')
    WardrobeCollectionFrame.SetsCollectionFrame.LeftInset:SetPoint('RIGHT', WardrobeCollectionFrame.SetsCollectionFrame.ListContainer)





    self:Setup(CollectionsJournal, {
        minW=703,
        minH=606,
        sizeUpdateFunc=function()
            if WarbandSceneJournal:IsVisible() then
                WarbandSceneJournal:SetupJournalEntries()
            end
        end,
        sizeStopFunc=function(frame)
            self:Save().size[frame:GetName()]= {frame:GetSize()}
        end,
        sizeRestFunc=function(frame)
            frame:SetSize(703, 606)
            self:Save().size['CollectionsJournal']=nil
        end,
    })






    self:Setup(MountJournal.BottomLeftInset, {frame=CollectionsJournal})
    self:Setup(PetJournalPetCard, {frame=CollectionsJournal})
    self:Setup(PetJournalLoadoutPet1, {frame=CollectionsJournal})
    self:Setup(PetJournalLoadoutPet2, {frame=CollectionsJournal})
    self:Setup(PetJournalLoadoutPet3, {frame=CollectionsJournal})
    self:Setup(PetJournalLoadoutPet1.modelScene.cardButton, {frame=CollectionsJournal})
    self:Setup(PetJournalLoadoutPet2.modelScene.cardButton, {frame=CollectionsJournal})
    self:Setup(PetJournalLoadoutPet3.modelScene.cardButton, {frame=CollectionsJournal})



    if _G['RematchFrame'] then
        RematchFrame:HookScript('OnSizeChanged', function(f)
            f:ClearAllPoints()
            f:SetAllPoints(CollectionsJournal)

            f.Canvas:ClearAllPoints()
            f.Canvas:SetPoint('TOPLEFT', 2, -60)
            f.Canvas:SetPoint('BOTTOMRIGHT', -2, 34)

            f.LoadedTargetPanel:ClearAllPoints()
            f.LoadedTargetPanel:SetPoint('TOP', f.ToolBar, 'BOTTOM')
            f.LoadedTargetPanel:SetSize(277, 75)
            f.LoadoutPanel:ClearAllPoints()
            f.LoadoutPanel:SetPoint('TOP', f.LoadedTeamPanel, 'BOTTOM')
            f.LoadoutPanel:SetWidth(277)
            f.LoadoutPanel:SetPoint('BOTTOM')

            f.PetsPanel:ClearAllPoints()
            f.PetsPanel:SetPoint('TOPLEFT', f.ToolBar, 'BOTTOMLEFT')
            f.PetsPanel:SetPoint('BOTTOMRIGHT', f.LoadoutPanel, 'BOTTOMLEFT',0,38)

            f.OptionsPanel:ClearAllPoints()
            f.OptionsPanel:SetPoint('TOPLEFT', f.LoadedTargetPanel, 'TOPRIGHT')
            f.OptionsPanel:SetPoint('BOTTOMRIGHT', -4, 38)

            f.TeamsPanel:ClearAllPoints()
            f.TeamsPanel:SetPoint('TOPLEFT', f.LoadedTargetPanel, 'TOPRIGHT')
            f.TeamsPanel:SetPoint('BOTTOMRIGHT', -4, 38)

            f.TargetsPanel:ClearAllPoints()
            f.TargetsPanel:SetPoint('TOPLEFT', f.LoadedTargetPanel, 'TOPRIGHT')
            f.TargetsPanel:SetPoint('BOTTOMRIGHT', -4, 38)

            f.QueuePanel:ClearAllPoints()
            f.QueuePanel:SetPoint('TOPLEFT', f.LoadedTargetPanel, 'TOPRIGHT')
            f.QueuePanel:SetPoint('BOTTOMRIGHT', -4, 38)
            f.QueuePanel.List.Help:ClearAllPoints()
            f.QueuePanel.List.Help:SetPoint('TOPLEFT', 8, 22)
            f.QueuePanel.List.Help:SetPoint('BOTTOMRIGHT', -22, 22)
        end)

        self:Setup(RematchFrame, {frame=CollectionsJournal})
        self:Setup(RematchFrame.TeamsPanel.List.ScrollBox, {frame=CollectionsJournal})
        self:Setup(RematchFrame.QueuePanel.List.ScrollBox, {frame=CollectionsJournal})
    end


    C_Timer.After(0.3, function()
        if _G['ManuscriptsJournal'] then
            self:Setup(_G['ManuscriptsJournal'], {frame=CollectionsJournal})
        end
    end)


--这个有人出错
    MountJournal.FilterDropdown:ClearAllPoints()
    MountJournal.FilterDropdown:SetPoint('TOPRIGHT', MountJournal.LeftInset, -5, -10)
    MountJournalSearchBox:ClearAllPoints()
    MountJournalSearchBox:SetPoint('TOPLEFT', MountJournal.LeftInset, 15, -9)
    MountJournalSearchBox:SetPoint('RIGHT', MountJournal.FilterDropdown, 'LEFT', -2, 0)
end