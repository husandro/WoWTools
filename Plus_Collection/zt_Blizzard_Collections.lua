
--收藏
function WoWTools_TextureMixin.Events:Blizzard_Collections()
    self:SetButton(CollectionsJournalCloseButton, {all=true})
    self:SetButton(PetJournalTutorialButton, {all=true})

    self:SetNineSlice(CollectionsJournal, true)
    self:SetAlphaColor(CollectionsJournalBg, nil, nil, true)

--坐骑
    self:SetFrame(MountJournal.MountCount, {alpha=0.3})
    self:HideTexture(MountJournal.LeftInset.Bg)
    self:SetAlphaColor(MountJournal.MountDisplay.YesMountsTex)
    self:HideTexture(MountJournal.RightInset.Bg)
    self:SetAlphaColor(MountJournal.BottomLeftInset.Background)
    self:HideTexture(MountJournal.BottomLeftInset.Bg)
    self:SetScrollBar(MountJournal)
    self:SetEditBox(MountJournalSearchBox)
    self:SetNineSlice(MountJournal.BottomLeftInset, nil, true)
    self:SetNineSlice(MountJournal.RightInset, nil, true)
    self:SetNineSlice(MountJournal.LeftInset, nil, true)
    if MountJournal.ToggleDynamicFlightFlyoutButton then--11.1.7
        self:SetAlphaColor(MountJournal.ToggleDynamicFlightFlyoutButton.Border, true)
    end
    if MountJournal.SummonRandomFavoriteSpellFrame then
        self:SetAlphaColor(MountJournal.SummonRandomFavoriteSpellFrame.Button.Border, true)
    end

    self:SetAlphaColor(PetJournalPetCardBG, nil, nil, 0.3)
    self:SetAlphaColor(PetJournalPetCardInset.Bg)
    self:SetAlphaColor(PetJournalRightInset.Bg)
    self:SetAlphaColor(PetJournalLoadoutPet1BG, nil, nil, 0.3)
    self:SetAlphaColor(PetJournalLoadoutPet2BG, nil, nil, 0.3)
    self:SetAlphaColor(PetJournalLoadoutPet3BG, nil, nil, 0.3)
    self:SetAlphaColor(PetJournalLoadoutBorderSlotHeaderBG)
    self:HideTexture(PetJournalLeftInset.Bg)
    self:HideTexture(PetJournalLoadoutBorder)

    self:SetScrollBar(PetJournal)
    self:SetEditBox(PetJournalSearchBox)

    self:SetAlphaColor(PetJournal.PetCount.BorderTopMiddle, nil, nil, 0.3)
    self:SetAlphaColor(PetJournal.PetCount.Bg, nil, nil, 0.3)
    self:SetAlphaColor(PetJournal.PetCount.BorderBottomMiddle, nil, nil, 0.3)
    self:SetAlphaColor(PetJournal.PetCount.BorderTopRightMiddle, nil, nil, 0.3)
    self:SetAlphaColor(PetJournal.PetCount.BorderTopLeftMiddle, nil, nil, 0.3)
    self:SetAlphaColor(PetJournal.PetCount.BorderBottomLeft, nil, nil, 0.3)
    self:SetAlphaColor(PetJournal.PetCount.BorderTopLeft, nil, nil, 0.3)
    self:SetAlphaColor(PetJournal.PetCount.BorderBottomRight, nil, nil, 0.3)
    self:SetAlphaColor(PetJournal.PetCount.BorderTopRight, nil, nil, 0.3)
    self:SetAlphaColor(PetJournal.PetCount.BorderLeftMiddle, nil, nil, 0.3)
    self:SetAlphaColor(PetJournal.PetCount.BorderRightMiddle, nil, nil, 0.3)

    if PetJournal.SummonRandomPetSpellFrame then --11.1.7才有
        self:SetAlphaColor(PetJournal.SummonRandomPetSpellFrame.Button.Border, true, nil, nil)
        self:SetAlphaColor(PetJournal.HealPetSpellFrame.Button.Border, true, nil, nil)
    else
        self:SetAlphaColor(PetJournalSummonRandomFavoritePetButtonBorder, true, nil, nil)
        self:SetAlphaColor(PetJournalHealPetButtonBorder, true, nil, nil)
    end

    self:SetFrame(PetJournalFilterButton, {alpha=0.3})
    self:SetNineSlice(PetJournalLeftInset, nil, true)
    self:SetNineSlice(PetJournalPetCardInset, nil, true)
    self:SetNineSlice(PetJournalRightInset, nil, true)

    if _G['RematchFrame'] then
        self:HideTexture(_G['RematchFrame'].Bg)
        self:HideTexture(_G['RematchFrame'].OptionsPanel.List.Back)
        self:HideTexture(_G['RematchFrame'].QueuePanel.List.Back)
        self:HideTexture(_G['RematchFrame'].TargetsPanel.List.Back)
        self:HideTexture(_G['RematchFrame'].TeamsPanel.List.Back)
        self:HideTexture(_G['RematchFrame'].ToolBar.Bg)
    end


    self:HideTexture(ToyBox.iconsFrame.BackgroundTile)
    self:HideTexture(ToyBox.iconsFrame.Bg)
    self:SetEditBox(ToyBox.searchBo)
    self:SetEditBox(ToyBox.searchBox)
    self:SetFrame(ToyBoxFilterButton, {alpha=0.3})
    self:HideTexture(ToyBox.iconsFrame.ShadowLineTop)
    self:HideTexture(ToyBox.iconsFrame.ShadowLineBottom)

    self:SetNineSlice(ToyBox.iconsFrame, nil, true)
    ToyBox.progressBar:DisableDrawLayer('BACKGROUND')

    self:HideTexture(HeirloomsJournal.iconsFrame.BackgroundTile)
    self:HideTexture(HeirloomsJournal.iconsFrame.Bg)
    self:SetEditBox(HeirloomsJournalSearchBox)
    self:SetAlphaColor(HeirloomsJournalMiddleMiddle)
    self:SetAlphaColor(HeirloomsJournalMiddleLeft)
    self:SetAlphaColor(HeirloomsJournalMiddleRight)
    self:SetAlphaColor(HeirloomsJournalBottomMiddle)
    self:SetAlphaColor(HeirloomsJournalTopMiddle)
    self:SetAlphaColor(HeirloomsJournalBottomLeft)
    self:SetAlphaColor(HeirloomsJournalBottomRight)
    self:SetAlphaColor(HeirloomsJournalTopLeft)
    self:SetAlphaColor(HeirloomsJournalTopRight)
    self:HideTexture(HeirloomsJournal.iconsFrame.ShadowLineBottom)
    self:HideTexture(HeirloomsJournal.iconsFrame.ShadowLineTop)
    self:SetNineSlice(HeirloomsJournal.iconsFrame, nil, true)
    HeirloomsJournal.progressBar:DisableDrawLayer('BACKGROUND')
    self:SetFrame(HeirloomsJournal.FilterButton, {alpha=0.3})

    self:HideTexture(WardrobeCollectionFrame.ItemsCollectionFrame.ShadowLineBottom)
    self:HideTexture(WardrobeCollectionFrame.ItemsCollectionFrame.ShadowLineTop)
    self:SetNineSlice(WardrobeCollectionFrame.ItemsCollectionFrame, nil, true)
    self:HideTexture(WardrobeCollectionFrame.ItemsCollectionFrame.BackgroundTile)
    self:HideTexture(WardrobeCollectionFrame.ItemsCollectionFrame.Bg)
    self:HideTexture(WardrobeCollectionFrame.ItemsCollectionFrame.ShadowLineTop)

    self:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.BackgroundTile)
    self:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.Bg)
    self:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.LeftInset.Bg)
    self:SetScrollBar(WardrobeCollectionFrame.SetsCollectionFrame.ListContainer)
    self:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.ShadowLineTop)
    self:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.BGCornerBottomRight)
    self:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.BGCornerBottomLeft)
    self:SetNineSlice(WardrobeCollectionFrame.SetsCollectionFrame.RightInset, nil, true)
    self:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.ShadowLineBottom)
    self:SetNineSlice(WardrobeCollectionFrame.SetsCollectionFrame.LeftInset, nil, true)

    self:SetEditBox(WardrobeCollectionFrameSearchBox)
    self:SetAlphaColor(WardrobeCollectionFrameMiddleMiddle)
    self:SetAlphaColor(WardrobeCollectionFrameTopMiddle)
    self:SetAlphaColor(WardrobeCollectionFrameBottomMiddle)
    self:SetAlphaColor(WardrobeCollectionFrameTopMiddle)
    self:SetAlphaColor(WardrobeCollectionFrameMiddleLeft)
    self:SetAlphaColor(WardrobeCollectionFrameMiddleRight)
    self:SetAlphaColor(WardrobeCollectionFrameTopLeft)
    self:SetAlphaColor(WardrobeCollectionFrameBottomLeft)
    self:SetAlphaColor(WardrobeCollectionFrameBottomRight)
    self:SetAlphaColor(WardrobeCollectionFrameTopLeft)

    self:SetFrame(WardrobeCollectionFrame.FilterButton, {alpha=0.3})
    self:SetFrame(WardrobeSetsCollectionVariantSetsButton, {alpha=0.3})

    self:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.ModelFadeTexture)

    self:SetTabButton(WardrobeCollectionFrameTab1)
    self:SetTabButton(WardrobeCollectionFrameTab2)

    --试衣间
    self:SetNineSlice(WardrobeFrame, true)
    self:HideTexture(WardrobeFrameBg)
    self:HideTexture(WardrobeTransmogFrame.Inset.Bg)
    self:SetAlphaColor(WardrobeTransmogFrame.Inset.BG)
    self:HideTexture(WardrobeCollectionFrame.SetsTransmogFrame.BackgroundTile)
    self:SetNineSlice(WardrobeCollectionFrame.SetsTransmogFrame, nil, true)
    self:SetAlphaColor(WardrobeCollectionFrame.SetsTransmogFrame.Bg)


    self:SetAlphaColor(WardrobeTransmogFrame.MoneyMiddle)
    self:SetAlphaColor(WardrobeTransmogFrame.MoneyLeft)
    self:SetAlphaColor(WardrobeTransmogFrame.MoneyRight)

    hooksecurefunc(WardrobeCollectionFrame, 'SetTab', function(frame)
        local f= frame.activeFrame
        if f and f==frame.SetsTransmogFrame then
            for i=1, f.PAGE_SIZE or 8 do
                local btn= f.Models[i]
                if btn then
                    btn:DisableDrawLayer('BACKGROUND')
                end
            end
        end
    end)
    for v=1,4 do
        for h= 1, 2 do
            local button= WardrobeCollectionFrame.SetsTransmogFrame['ModelR'..h..'C'..v]
            if button then
                button:DisableDrawLayer('BACKGROUND')
            end
        end
    end
    WardrobeCollectionFrame.progressBar:DisableDrawLayer('BACKGROUND')


    for i=1, 7 do
        self:SetFrame(_G['CollectionsJournalTab'..i], {notAlpha=true})
    end

    if _G['RematchJournal'] then
        self:SetNineSlice(_G['RematchJournal'], true)
        self:SetAlphaColor(_G['RematchJournalBg'])
        self:SetAlphaColor(RematchLoadoutPanel.Target.InsetBack)
        self:HideTexture(RematchPetPanel.Top.InsetBack)
        self:SetAlphaColor(RematchQueuePanel.List.Background.InsetBack)
        self:SetAlphaColor(RematchQueuePanel.Top.InsetBack)
        self:HideTexture(RematchPetPanel.Top.TypeBar.NineSlice)
        self:SetAlphaColor(RematchTeamPanel.List.Background.InsetBack)
        self:SetAlphaColor(RematchOptionPanel.List.Background.InsetBack)
        self:SetAlphaColor(RematchLoadoutPanel.TopLoadout.InsetBack)
    end


    if WarbandSceneJournal then--11.1
        self:HideTexture(WarbandSceneJournal.IconsFrame.BackgroundTile)
        self:HideTexture(WarbandSceneJournal.IconsFrame.Bg)
    end
end


