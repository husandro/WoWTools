
--收藏
function WoWTools_TextureMixin.Events:Blizzard_Collections()
    self:SetButton(WardrobeCollectionFrame.InfoButton)
    WardrobeCollectionFrame.InfoButton:SetFrameLevel(CollectionsJournal.TitleContainer:GetFrameLevel()+1)

    self:HideTexture(CollectionsJournal.TopTileStreaks)
    self:SetButton(CollectionsJournalCloseButton)
    --self:SetNineSlice(CollectionsJournal)
    self:HideTexture(CollectionsJournalBg)
    self:SetButton(PetJournalTutorialButton)
    PetJournalTutorialButton:SetFrameLevel(CollectionsJournal.TitleContainer:GetFrameLevel()+1)


--坐骑
    self:SetFrame(MountJournal.MountCount, {alpha=0.3})
    self:HideTexture(MountJournal.LeftInset.Bg)
    self:HideTexture(MountJournal.MountDisplay.YesMountsTex)
    self:SetAlphaColor(MountJournal.MountDisplay.ShadowOverlay, nil, nil, 0)

    self:SetAlphaColor(MountJournal.RightInset.Bg, nil, nil, 0.3)
    MountJournal.RightInset.Bg:ClearAllPoints()
    MountJournal.RightInset.Bg:SetPoint('TOPLEFT', MountJournalIcon, -2, 2)
    MountJournal.RightInset.Bg:SetPoint('BOTTOMRIGHT', MountJournalLore, 2, -2)


    self:HideFrame(MountJournal.BottomLeftInset)
    self:SetNineSlice(MountJournal.BottomLeftInset)


    self:SetScrollBar(MountJournal)
    self:SetEditBox(MountJournalSearchBox)

    self:SetNineSlice(MountJournal.RightInset)
    self:SetNineSlice(MountJournal.LeftInset)
    if MountJournal.ToggleDynamicFlightFlyoutButton then--11.1.7
        self:SetAlphaColor(MountJournal.ToggleDynamicFlightFlyoutButton.Border, true)
    end
    if MountJournal.SummonRandomFavoriteSpellFrame then
        self:SetAlphaColor(MountJournal.SummonRandomFavoriteSpellFrame.Button.Border, true)
    end
--宠物
    self:HideFrame(PetJournalLoadoutBorder)

    self:HideTexture(PetJournalPetCardInset.Bg)
    self:SetAlphaColor(PetJournalPetCardBG, nil, nil, 0.3)

    self:HideTexture(PetJournalRightInset.Bg)
    self:SetAlphaColor(PetJournalLoadoutPet1BG)
    self:SetAlphaColor(PetJournalLoadoutPet2BG)
    self:SetAlphaColor(PetJournalLoadoutPet3BG)
    self:HideTexture(PetJournalLeftInset.Bg)

    self:SetScrollBar(PetJournal)
    self:SetEditBox(PetJournalSearchBox)

    self:SetFrame(PetJournal.PetCount, {alpha=0.3})

    if PetJournal.SummonRandomPetSpellFrame then --11.1.7才有
        self:SetAlphaColor(PetJournal.SummonRandomPetSpellFrame.Button.Border, true, nil, nil)
        self:SetAlphaColor(PetJournal.HealPetSpellFrame.Button.Border, true, nil, nil)
    else
        self:SetAlphaColor(PetJournalSummonRandomFavoritePetButtonBorder, true, nil, nil)
        self:SetAlphaColor(PetJournalHealPetButtonBorder, true, nil, nil)
    end

    self:SetFrame(PetJournalFilterButton, {alpha=0.3})
    self:SetNineSlice(PetJournalLeftInset)
    self:SetNineSlice(PetJournalPetCardInset)
    self:SetNineSlice(PetJournalRightInset)


--玩具
    self:SetEditBox(ToyBox.searchBox)
    self:HideFrame(ToyBox.iconsFrame)
    self:SetNineSlice(ToyBox.iconsFrame)
    ToyBox.progressBar:DisableDrawLayer('BACKGROUND')
    self:SetAlphaColor(ToyBox.progressBar.border, nil, nil, 0.3)

--传家宝
    self:SetEditBox(HeirloomsJournalSearchBox)
    self:HideFrame(HeirloomsJournal.iconsFrame)
    self:SetNineSlice(HeirloomsJournal.iconsFrame)
    HeirloomsJournal.progressBar:DisableDrawLayer('BACKGROUND')
    self:SetAlphaColor(HeirloomsJournal.progressBar.border, nil, nil, 0.3)

--物品
    self:SetNineSlice(WardrobeCollectionFrame.ItemsCollectionFrame)
    self:HideFrame(WardrobeCollectionFrame.ItemsCollectionFrame)
    WardrobeCollectionFrame.progressBar:DisableDrawLayer('BACKGROUND')
    self:SetAlphaColor(WardrobeCollectionFrame.progressBar.border, nil, nil, 0.3)
    self:SetEditBox(WardrobeCollectionFrameSearchBox)


--套装
    self:SetScrollBar(WardrobeCollectionFrame.SetsCollectionFrame.ListContainer)
    self:SetNineSlice(WardrobeCollectionFrame.SetsCollectionFrame.LeftInset)
    self:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.LeftInset.Bg)
    self:HideFrame(WardrobeCollectionFrame.SetsCollectionFrame.RightInset)
    self:SetNineSlice(WardrobeCollectionFrame.SetsCollectionFrame.RightInset)
    self:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.ModelFadeTexture)

--试衣间WardrobeFrame
    --self:SetNineSlice(WardrobeFrame)
    self:HideFrame(WardrobeFrame)
    self:HideFrame(WardrobeTransmogFrame)
    self:SetNineSlice(WardrobeTransmogFrame.Inset)
    self:HideTexture(WardrobeTransmogFrame.Inset.Bg)
    self:HideTexture(WardrobeTransmogFrame.Inset.BG)
    self:SetButton(WardrobeFrameCloseButton)

--试衣间, 套装
    self:HideFrame(WardrobeCollectionFrame.SetsTransmogFrame)
    self:SetNineSlice(WardrobeCollectionFrame.SetsTransmogFrame)


--试衣间，物品 WardrobeItemsModelTemplate
    for _, btn in pairs(WardrobeCollectionFrame.ItemsCollectionFrame.Models or {}) do
        btn:DisableDrawLayer('BACKGROUND')
        btn.Border:SetAlpha(0)
    end
    hooksecurefunc(WardrobeItemsModelMixin, 'OnLoad', function(btn)
        btn:DisableDrawLayer('BACKGROUND')
        btn.Border:SetAlpha(0)
    end)

--试衣间，套装
    for _, btn in pairs(WardrobeCollectionFrame.SetsTransmogFrame.Models or {}) do
        btn:DisableDrawLayer('BACKGROUND')
        self:HideTexture(btn.Border)
    end
    hooksecurefunc(WardrobeSetsTransmogModelMixin, 'OnLoad', function(btn)
        btn:DisableDrawLayer('BACKGROUND')
        self:HideTexture(btn.Border)
    end)

    self:HideFrame(WarbandSceneJournal.IconsFrame)
    self:SetNineSlice(WarbandSceneJournal.IconsFrame)

--玩具, 传家宝，建立按钮，Bg, CollectionsSpellButton_OnLoad
    hooksecurefunc('CollectionsSpellButton_OnShow', function(btn)--CollectionsSpellButton_OnLoad
        if btn.Bg or not btn.name then
            return
        end
        btn.Bg= btn:CreateTexture(nil, 'BACKGROUND')
        btn.Bg:SetColorTexture(0,0,0,0.3)
        btn.Bg:SetPoint('TOPLEFT', btn.name, -2, 2)
        btn.Bg:SetPoint('RIGHT', btn.name, 2, 0)
        btn.Bg:SetPoint('BOTTOM', btn.special or btn.name, 0,-2)
    end)

--收集
    self:Init_BGMenu_Frame(CollectionsJournal)
--试衣间
    self:Init_BGMenu_Frame(WardrobeFrame, {
        newButtonPoint=function(btn)
            btn:SetPoint('RIGHT', WardrobeFrameCloseButton, -23, 0)
        end
    })




    
    

    if _G['RematchJournal'] then
        self:SetNineSlice(_G['RematchJournal'])
        self:SetAlphaColor(_G['RematchJournalBg'])
        self:SetAlphaColor(RematchLoadoutPanel.Target.InsetBack)
        self:HideTexture(RematchPetPanel.Top.InsetBack)
        self:SetAlphaColor(RematchQueuePanel.List.Background.InsetBack)
        self:SetAlphaColor(RematchQueuePanel.Top.InsetBack)
        self:NineSlice(RematchPetPanel.Top.TypeBar)
        self:SetAlphaColor(RematchTeamPanel.List.Background.InsetBack)
        self:SetAlphaColor(RematchOptionPanel.List.Background.InsetBack)
        self:SetAlphaColor(RematchLoadoutPanel.TopLoadout.InsetBack)
    end

    if _G['RematchFrame'] then
        
        self:HideTexture(_G['RematchFrame'].Bg)
        self:HideTexture(_G['RematchFrame'].OptionsPanel.List.Back)
        self:HideTexture(_G['RematchFrame'].QueuePanel.List.Back)
        self:HideTexture(_G['RematchFrame'].TargetsPanel.List.Back)
        self:HideTexture(_G['RematchFrame'].TeamsPanel.List.Back)
        self:HideTexture(_G['RematchFrame'].ToolBar.Bg)
    end
end



