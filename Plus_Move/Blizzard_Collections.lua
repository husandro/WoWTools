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









local function init_rematch()
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








--藏品
local function Init_CollectionsJournal()
--坐骑
    MountJournalSearchBox:SetPoint('RIGHT', MountJournal.FilterDropdown, 'LEFT', -2, 0)
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



    WoWTools_MoveMixin:Setup(CollectionsJournal, {
        setSize=true,
        minW=703,
        minH=606,
        --notInCombat=true,
        sizeUpdateFunc=function(btn)
            init_items_colllection(btn, true)

            if WarbandSceneJournal and WarbandSceneJournal:IsShown() then
                WarbandSceneJournal:SetupJournalEntries()
            end
        end,
        sizeStopFunc=function(btn)
            Save().size[btn.name]= {btn.targetFrame:GetSize()}
            update_frame()
        end,
        sizeRestFunc=function(btn)
            btn.targetFrame:SetSize(703, 606)
            Save().size[btn.name]=nil
            init_items_colllection(btn)
            update_frame()
        end,
        scaleRestFunc=function()
            update_frame()
        end
    })

    WoWTools_MoveMixin:Setup(PetJournalPetCard, {frame=CollectionsJournal})
    WoWTools_MoveMixin:Setup(PetJournalLoadoutPet1, {frame=CollectionsJournal})
    WoWTools_MoveMixin:Setup(PetJournalLoadoutPet2, {frame=CollectionsJournal})
    WoWTools_MoveMixin:Setup(PetJournalLoadoutPet3, {frame=CollectionsJournal})
    WoWTools_MoveMixin:Setup(PetJournalLoadoutPet1.modelScene.cardButton, {frame=CollectionsJournal})
    WoWTools_MoveMixin:Setup(PetJournalLoadoutPet2.modelScene.cardButton, {frame=CollectionsJournal})
    WoWTools_MoveMixin:Setup(PetJournalLoadoutPet3.modelScene.cardButton, {frame=CollectionsJournal})


    C_Timer.After(2, function()
        local frame= _G['ManuscriptsJournal']
        if frame then
            WoWTools_MoveMixin:Setup(frame, {frame=CollectionsJournal})
        end
    end)

    if _G['RematchFrame'] then
        _G['RematchFrame']:HookScript('OnShow', init_rematch)
        hooksecurefunc(_G['RematchFrame'].PanelTabs, 'TabOnClick', init_rematch)
        WoWTools_MoveMixin:Setup(_G['RematchFrame'].TeamsPanel.List.ScrollBox, {frame=CollectionsJournal})
        WoWTools_MoveMixin:Setup(_G['RematchFrame'].QueuePanel.List.ScrollBox, {frame=CollectionsJournal})
    end

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
    end, sizeStopFunc=function(btn)
        Save().size[btn.name]= {btn.targetFrame:GetSize()}
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



    Init_WardrobeFrame=function()end
end











function WoWTools_MoveMixin.Events:Blizzard_Collections()
    Init_CollectionsJournal()
    Init_WardrobeFrame()
end