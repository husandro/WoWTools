--收藏
local function Save()
    return WoWToolsSave['Plus_Move']
end












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
















--藏品
local function Init_CollectionsJournal()
--坐骑
    MountJournalSearchBox:SetPoint('RIGHT', MountJournal.FilterDropdown, 'LEFT', -2, 0)

    MountJournal.RightInset:ClearAllPoints()
    MountJournal.RightInset:SetWidth(400)
    MountJournal.RightInset:SetPoint('TOPRIGHT', -6, -60)
    MountJournal.RightInset:SetPoint('BOTTOM', MountJournal, 0, 26)

    MountJournal.LeftInset:ClearAllPoints()
    MountJournal.LeftInset:SetPoint('TOPRIGHT', MountJournal.RightInset, 'TOPLEFT', -24, 0)
    MountJournal.LeftInset:SetPoint('LEFT', 6, 0)
    MountJournal.LeftInset:SetPoint('BOTTOM', MountJournalMountButton, 'TOP', 0, 2)

    --MountJournal.BottomLeftInset:SetPoint('TOPRIGHT', MountJournal.LeftInset, 'BOTTOMRIGHT', 0, -10)
    MountJournal.BottomLeftInset:ClearAllPoints()
    MountJournal.BottomLeftInset:SetPoint('BOTTOM', MountJournal.RightInset)
    MountJournal.BottomLeftInset:SetSize(279, 75)
    MountJournal.BottomLeftInset:SetFrameStrata('DIALOG')

    --MountJournal.MountDisplay.ModelScene.TogglePlayer:ClearAllPoints()
    --MountJournal.MountDisplay.ModelScene.TogglePlayer:SetPoint('BOTTOMLEFT', MountJournal.BottomLeftInset, 'TOPLEFT', 22, -4)
    MountJournal.MountDisplay.ModelScene.TogglePlayer:SetScript('OnLeave', GameTooltip_Hide)
    MountJournal.MountDisplay.ModelScene.TogglePlayer:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText(WoWTools_DataMixin.onlyChinese and '显示角色' or MOUNT_JOURNAL_PLAYER)
        GameTooltip:Show()
    end)
    MountJournal.MountDisplay.ModelScene.TogglePlayer.TogglePlayerText:SetText('')
    MountJournal.MountDisplay.ModelScene.TogglePlayer.TogglePlayerText:SetAlpha(0)


    MountJournal.MountDisplay.ModelScene.ControlFrame:ClearAllPoints()
    MountJournal.MountDisplay.ModelScene.ControlFrame:SetPoint('TOP', MountJournalLore, 'BOTTOM', 0, -12)

    PetJournalRightInset:ClearAllPoints()
    PetJournalRightInset:SetPoint('TOPRIGHT', PetJournalPetCardInset, 'BOTTOMRIGHT', 0, -22)
    PetJournalRightInset:SetSize(411,171)
    PetJournalLeftInset:SetPoint('RIGHT', PetJournalRightInset, 'LEFT', -24, 0)
    PetJournalLoadoutBorder:ClearAllPoints()
    PetJournalLoadoutBorder:SetPoint('TOP', PetJournalRightInset)

    hooksecurefunc('MountJournal_InitMountButton', function(btn)
        if btn.is_setting then
            return
        end
        btn.is_setting= true
        btn.name:SetPoint('RIGHT', -4, 0)
        btn.background:SetTexture(0)
        btn.background:SetColorTexture(0, 0, 0, 0.5)
    end)
    WardrobeCollectionFrame.SetsCollectionFrame.RightInset:ClearAllPoints()
    WardrobeCollectionFrame.SetsCollectionFrame.RightInset:SetWidth(410)
    WardrobeCollectionFrame.SetsCollectionFrame.RightInset:SetPoint('TOPRIGHT', 2, 0)
    WardrobeCollectionFrame.SetsCollectionFrame.RightInset:SetPoint('BOTTOM')
    WardrobeCollectionFrame.SetsCollectionFrame.ListContainer:SetPoint('RIGHT', WardrobeCollectionFrame.SetsCollectionFrame.RightInset, 'LEFT', -24, 0)
    WardrobeCollectionFrame.SetsCollectionFrame.ListContainer:SetPoint('BOTTOM')
    WardrobeCollectionFrame.SetsCollectionFrame.LeftInset:SetPoint('RIGHT', WardrobeCollectionFrame.SetsCollectionFrame.ListContainer)



    WoWTools_MoveMixin:Setup(CollectionsJournal, {
        setSize=true,
        minW=703,
        minH=606,
        sizeUpdateFunc=function(btn)
            init_items_colllection(btn, true)
            if WarbandSceneJournal and WarbandSceneJournal:IsShown() then
                WarbandSceneJournal:SetupJournalEntries()
            end
        end,
        sizeStopFunc=function()
            Save().size['CollectionsJournal']= {CollectionsJournal:GetSize()}
            update_frame()
        end,
        sizeRestFunc=function(btn)
            CollectionsJournal:SetSize(703, 606)
            Save().size['CollectionsJournal']=nil
            init_items_colllection(btn)
            update_frame()
        end,
        scaleRestFunc=function()
            update_frame()
        end
    })


    WoWTools_MoveMixin:Setup(MountJournal.BottomLeftInset, {frame=CollectionsJournal})
    WoWTools_MoveMixin:Setup(PetJournalPetCard, {frame=CollectionsJournal})
    WoWTools_MoveMixin:Setup(PetJournalLoadoutPet1, {frame=CollectionsJournal})
    WoWTools_MoveMixin:Setup(PetJournalLoadoutPet2, {frame=CollectionsJournal})
    WoWTools_MoveMixin:Setup(PetJournalLoadoutPet3, {frame=CollectionsJournal})
    WoWTools_MoveMixin:Setup(PetJournalLoadoutPet1.modelScene.cardButton, {frame=CollectionsJournal})
    WoWTools_MoveMixin:Setup(PetJournalLoadoutPet2.modelScene.cardButton, {frame=CollectionsJournal})
    WoWTools_MoveMixin:Setup(PetJournalLoadoutPet3.modelScene.cardButton, {frame=CollectionsJournal})



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

        WoWTools_MoveMixin:Setup(RematchFrame, {frame=CollectionsJournal})
        WoWTools_MoveMixin:Setup(RematchFrame.TeamsPanel.List.ScrollBox, {frame=CollectionsJournal})
        WoWTools_MoveMixin:Setup(RematchFrame.QueuePanel.List.ScrollBox, {frame=CollectionsJournal})
    end






    
    C_Timer.After(0.3, function()
        if _G['ManuscriptsJournal'] then
            WoWTools_MoveMixin:Setup(_G['ManuscriptsJournal'], {frame=CollectionsJournal})
        end
    end)


    Init_CollectionsJournal=function()end
end




















local function Init_WardrobeFrame()
    WoWTools_MoveMixin:Setup(WardrobeFrame, {setSize=true, minW=965, minH=606, initFunc=function()
        WardrobeTransmogFrame:ClearAllPoints()
        WardrobeTransmogFrame:SetPoint('LEFT', 2, -28)
        WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox:ClearAllPoints()--两侧肩膀使用不同的幻化外观
        WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox:SetPoint('RIGHT', WardrobeTransmogFrame.ShoulderButton, 'LEFT', -6, 0)
        WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox.Label:ClearAllPoints()
        WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox.Label:SetPoint('RIGHT', WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox, 'LEFT')
    end, sizeUpdateFunc=function(btn)
        init_items_colllection(btn, true)
    end, sizeStopFunc=function()
        Save().size['WardrobeFrame']= {WardrobeFrame:GetSize()}
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
        if parent==WardrobeFrame then
            self:SetPoint('BOTTOMLEFT', 300,0)
        end
        init_items_colllection(btn)
    end)


    Init_WardrobeFrame=function()end
end











function WoWTools_MoveMixin.Events:Blizzard_Collections()
    Init_CollectionsJournal()
    Init_WardrobeFrame()
end