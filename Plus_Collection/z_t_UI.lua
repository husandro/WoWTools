
--收藏
function WoWTools_TextureMixin.Events:Blizzard_Collections()
    self:HideTexture(CollectionsJournal.TopTileStreaks)
    self:SetButton(CollectionsJournalCloseButton)
    self:HideTexture(CollectionsJournalBg)
    self:SetButton(PetJournalTutorialButton)
    PetJournalTutorialButton:SetFrameLevel(CollectionsJournal.TitleContainer:GetFrameLevel()+1)

    for i=1, 10 do
        self:SetTabButton(_G['CollectionsJournalTab'..i])
    end


--坐骑
    --self:SetMenu(MountJournal.FilterDropdown)
    self:SetUIButton(MountJournalMountButton)
    self:SetFrame(MountJournal.MountCount, {alpha=0.3})
    self:HideTexture(MountJournal.LeftInset.Bg)
    self:HideTexture(MountJournal.MountDisplay.YesMountsTex)
    self:SetCheckBox(MountJournal.MountDisplay.ModelScene.TogglePlayer)
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
    --WoWTools_DataMixin:Hook('MountJournal_InitMountButton', function(btn)

--宠物
    self:SetUIButton(PetJournalSummonButton)
    self:SetUIButton(PetJournalFindBattle)
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
    self:SetStatusBar(ToyBox.progressBar)
    self:SetButton(ToyBox.PagingFrame.PrevPageButton, 1)
    self:SetButton(ToyBox.PagingFrame.NextPageButton, 1)

--传家宝
    self:SetButton(HeirloomsJournal.PagingFrame.NextPageButton, 1)
    self:SetButton(HeirloomsJournal.PagingFrame.PrevPageButton, 1)
    self:SetEditBox(HeirloomsJournalSearchBox)
    self:HideFrame(HeirloomsJournal.iconsFrame)
    self:SetNineSlice(HeirloomsJournal.iconsFrame)
    HeirloomsJournal.progressBar:DisableDrawLayer('BACKGROUND')
    self:SetStatusBar(HeirloomsJournal.progressBar)
    self:SetAlphaColor(HeirloomsJournal.progressBar.border, nil, nil, 0.3)


--物品
    self:SetButton(WardrobeCollectionFrame.InfoButton)
    WardrobeCollectionFrame.InfoButton:SetFrameLevel(CollectionsJournal.TitleContainer:GetFrameLevel()+1)
    self:SetMenu(WardrobeCollectionFrame.ClassDropdown)
    self:SetNineSlice(WardrobeCollectionFrame.ItemsCollectionFrame)
    self:HideFrame(WardrobeCollectionFrame.ItemsCollectionFrame)
    WardrobeCollectionFrame.progressBar:DisableDrawLayer('BACKGROUND')

    self:SetStatusBar(WardrobeCollectionFrame.progressBar)
    self:SetEditBox(WardrobeCollectionFrameSearchBox)
    --[[for _, region in pairs({WardrobeCollectionFrame.ItemsCollectionFrame.SlotsFrame:GetChildren()}) do
        if region:IsObjectType('Button') then
            local icon= region:GetNormalTexture()
            if icon then
                self:SetAlphaColor(icon, true, nil, 1)
            end
        end
    end]]
    self:SetButton(WardrobeCollectionFrame.ItemsCollectionFrame.PagingFrame.PrevPageButton, 1)
    self:SetButton(WardrobeCollectionFrame.ItemsCollectionFrame.PagingFrame.NextPageButton, 1)

--套装
    self:SetScrollBar(WardrobeCollectionFrame.SetsCollectionFrame.ListContainer)
    self:SetNineSlice(WardrobeCollectionFrame.SetsCollectionFrame.LeftInset)
    self:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.LeftInset.Bg)
    self:HideFrame(WardrobeCollectionFrame.SetsCollectionFrame.RightInset)
    self:SetNineSlice(WardrobeCollectionFrame.SetsCollectionFrame.RightInset)
    self:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.ModelFadeTexture)

--营区
    self:SetButton(WarbandSceneJournal.IconsFrame.Icons.Controls.PagingControls.PrevPageButton, 1)
    self:SetButton(WarbandSceneJournal.IconsFrame.Icons.Controls.PagingControls.NextPageButton, 1)
    self:SetCheckBox(WarbandSceneJournal.IconsFrame.Icons.Controls.ShowOwned.Checkbox)


--试衣间WardrobeFrame
    for _, name in pairs({
    'HeadButton',
    'ShoulderButton',
    'SecondaryShoulderButton',
    'BackButton',
    'ChestButton',
    'ShirtButton',
    'TabardButton',
    'WristButton',

    'HandsButton',
    'WaistButton',
    'LegsButton',
    'FeetButton',

    'MainHandButton',
    'MainHandEnchantButton',
    'SecondaryHandButton',
    'SecondaryHandEnchantButton',
    }) do
        local btn= WardrobeTransmogFrame[name]
        if btn then
            self:HideTexture(btn.Border)
            WoWTools_ButtonMixin:AddMask(btn, false, btn.Icon)
        end
    end


    WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox.Label:SetText('')
    WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox:SetScript('OnLeave', GameTooltip_Hide)
    WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText(WoWTools_DataMixin.onlyChinese and '两侧肩膀使用不同的幻化外观' or TRANSMOGRIFY_RIGHT_SHOULDER)
        GameTooltip:Show()
    end)

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
    WoWTools_DataMixin:Hook(WardrobeItemsModelMixin, 'OnLoad', function(btn)
        btn:DisableDrawLayer('BACKGROUND')
        btn.Border:SetAlpha(0)
    end)

--试衣间，套装
    --self:SetModelZoom(WardrobeTransmogFrame.ModelScene.ControlFrame)
    self:SetButton(WardrobeTransmogFrame.ModelScene.ClearAllPendingButton)
    self:SetButton(WardrobeCollectionFrame.SetsTransmogFrame.PagingFrame.NextPageButton, 1)
    self:SetButton(WardrobeCollectionFrame.SetsTransmogFrame.PagingFrame.PrevPageButton, 1)
    self:SetCheckBox(WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox)
    for _, btn in pairs(WardrobeCollectionFrame.SetsTransmogFrame.Models or {}) do
        btn:DisableDrawLayer('BACKGROUND')
        self:HideTexture(btn.Border)
    end
    WoWTools_DataMixin:Hook(WardrobeSetsTransmogModelMixin, 'OnLoad', function(btn)
        btn:DisableDrawLayer('BACKGROUND')
        self:HideTexture(btn.Border)
    end)

    self:HideFrame(WarbandSceneJournal.IconsFrame)
    self:SetNineSlice(WarbandSceneJournal.IconsFrame)

--玩具, 传家宝，建立按钮，Bg, CollectionsSpellButton_OnLoad
    WoWTools_DataMixin:Hook('CollectionsSpellButton_OnShow', function(btn)--CollectionsSpellButton_OnLoad
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
         for _, btn in pairs({RematchFrame.PanelTabs:GetChildren()}) do
                if btn:IsObjectType('Button') then
                    self:SetTabButton(btn)
                end
            end
        self:SetFrame(RematchFrame, {alpha=1})
        self:HideTexture(RematchFrame.Bg)
        self:SetButton(RematchFrame.TitleBar.CloseButton)
        self:SetFrame(RematchFrame.TitleBar.Portrait, {notAlpha=true})

        if RematchFrame.ToolBar then
            self:HideFrame(RematchFrame.ToolBar)
            self:HideFrame(RematchFrame.ToolBar.TotalsButton)
            self:SetNineSlice(RematchFrame.ToolBar)

            for _, btn in pairs({RematchFrame.ToolBar:GetChildren()}) do
                if btn:IsObjectType('Button') then
                    self:HideTexture(btn.Border)
                end
            end
        end

        if RematchFrame.PetsPanel then
            self:HideTexture(RematchFrame.PetsPanel.Top.TypeBar.TabbedBorder)
            self:HideFrame(RematchFrame.PetsPanel.ResultsBar)
            self:HideFrame(RematchFrame.PetsPanel.Top.TypeBar.Level25Button)
        end

        if RematchFrame.LoadedTargetPanel then
            self:HideFrame(RematchFrame.LoadedTargetPanel)
            self:SetAlphaColor(RematchFrame.LoadedTargetPanel.BigLoadSaveButton.Back, true)
            self:HideTexture(RematchFrame.LoadedTargetPanel.SmallTeamsButton.Back)
            self:HideTexture(RematchFrame.LoadedTargetPanel.SmallRandomButton.Back)

            self:HideFrame(RematchFrame.LoadedTeamPanel.TeamButton)
        end

        if RematchFrame.LoadoutPanel  then
            self:SetFrame(RematchFrame.LoadoutPanel, {isSub=true})
        end

        local frame
        for _, panel in pairs({
            'QueuePanel',
            'TeamsPanel',
            'TargetsPanel',
            'OptionsPanel',
            'PetsPanel',
        }) do
            frame= RematchFrame[panel] or frame
            if frame then
                if frame.Top then
                    if frame.Top.AllButton then
                        self:SetAlphaColor(frame.Top.AllButton.Back)

                    elseif frame.Top.TeamsButton then
                        self:SetAlphaColor(frame.Top.TeamsButton.Back)

                    elseif frame.Top.ToggleButton then
                        self:SetAlphaColor(frame.Top.ToggleButton.Back)
                        self:SetAlphaColor(frame.Top.FilterButton.Back)

                    elseif frame.Top.QueueButton then
                        self:SetAlphaColor(frame.Top.QueueButton.Back)

                    end

                    self:HideFrame(frame.Top)
                    self:SetEditBox(frame.Top.SearchBox)
                end

                if frame.PreferencesFrame then
                    self:HideFrame(frame.PreferencesFrame)
                    if frame.PreferencesFrame.PreferencesButton then
                        self:SetAlphaColor(frame.PreferencesFrame.PreferencesButton.Back)
                    end
                end

                if frame.List then
                    self:HideFrame(frame.List)
                    self:SetScrollBar(frame.List)
                    self:SetAlphaColor(frame.List.ScrollToTopButton.Texture, true)
                    self:SetAlphaColor(frame.List.ScrollToBottomButton.Texture, true)

                    WoWTools_DataMixin:Hook(frame.List.ScrollBox, 'Update', function(frame)
                        if not frame:HasView() then
                            return
                        end
                        for _, btn in pairs(frame:GetFrames() or {}) do
                            self:SetAlphaColor(btn.Back)
                            if btn.widget and btn.widget.DropDown then
                                self:SetFrame(btn.widget.DropDown, {notAlpha=true})
                            end
                        end
                    end)
                end
            end
        end

        frame= _G['RematchPetCard']
        if frame then
            self:SetFrame(frame, {notAlpha=true})
            self:SetButton(frame.MinimizeButton)
            self:SetButton(frame.CloseButton)
            if frame.Content then
                self:SetNineSlice(frame.Content, 1)
                self:SetFrame(frame.Content.Front, {notAlpha=true})
                self:SetFrame(frame.Content.Abilities, {notAlpha=true})
            end
        end

        frame= _G['RematchDialog']
        if frame then
            self:SetFrame(frame, {notAlpha=true})
            self:SetButton(frame.CloseButton)

            self:HideTexture(frame.InsetBorderBottomLeft)
            self:HideTexture(frame.InsetBorderBottomRight)
            self:HideTexture(frame.InsetBorderTopRight)
            self:HideTexture(frame.InsetBorderTopLeft)
            self:HideTexture(frame.InsetBorderRight)
            self:HideTexture(frame.InsetBorderTop)
            self:HideTexture(frame.InsetBorderLeft)
            self:HideTexture(frame.InsetBorderBottom)
        end

        frame= _G['RematchDialogCanvas']
        if frame then
            self:HideFrame(frame.TeamPicker.Lister.List)
            self:HideFrame(frame.TeamPicker.Lister.Top)

            self:HideFrame(frame.TeamPicker.Picker.Top)
            self:HideFrame(frame.TeamPicker.Picker.List)
            self:SetScrollBar(frame.TeamPicker.Picker.List)
            self:SetAlphaColor(frame.TeamPicker.Picker.List.ScrollToTopButton.Texture, true)
            self:SetAlphaColor(frame.TeamPicker.Picker.List.ScrollToBottomButton.Texture, true)

            self:SetEditBox(frame.MultiLineEditBox)
            self:SetFrame(RematchDialogCanvasScrollBarScrollUpButton, {notAlpha=true})
            self:SetAlphaColor(RematchDialogCanvasScrollBarThumbTexture, true)
            self:SetFrame(RematchDialogCanvasScrollBarScrollDownButton, {notAlpha=true})

            self:HideFrame(frame.GroupPicker.Top)
            self:HideFrame(frame.GroupPicker.List)
        end
    end













     C_Timer.After(0.3, function()
        if not _G['ManuscriptsJournal'] then
            return
        end
        self:HideTexture(ManuscriptsJournalProgressBar.border)
        ManuscriptsJournalProgressBar:DisableDrawLayer('BACKGROUND')

        self:HideTexture(SoulshapesJournalProgressBar.border)
        SoulshapesJournalProgressBar:DisableDrawLayer('BACKGROUND')

        for i=1, 7 do
            local bar= _G['ManuscriptsJournalMount'..i..'Bar']
            if bar then
                self:HideTexture(bar.border)
                bar:DisableDrawLayer('BACKGROUND')
            end
        end
        for _, name in pairs({
            'Manuscripts',
            'Soulshapes',
            'TameTomes',
            'Dirigible',
        }) do
            local frame= _G[name..'Journal']
            if frame then
                self:HideFrame(frame.iconsFrame, {show={[frame.iconsFrame.BackgroundTile]=true}})
                self:HideFrame(frame.iconsFrame.BackgroundTile)
                self:SetNineSlice(frame.iconsFrame)
                local edit= _G[name..'JournalSearchBox']
                if edit then
                    self:SetFrame(frame.FilterButton, {alpha=0.5})
                    self:SetEditBox(edit)
                end
            end
            local tab= _G['ManuscriptsSkillLine'..name..'Tab']
            if tab then
                self:HideFrame(tab, {index=1})
                WoWTools_ButtonMixin:AddMask(tab, {isType=true})
            end
        end

        for _, name in pairs({
            'Warrior',
            'Paladin',
            'Hunter',
            'Rogue',
            'Priest',
            'Death',
            'Shaman',
            'Mage',
            'Warlock',
            'Monk',
            'Druid',
            'Demon',
            'Evoker',
        }) do
            local tab= _G['ManuscriptsSkillLine'..name..'Tab']
            if tab then
                self:HideFrame(tab, {index=1})
                WoWTools_ButtonMixin:AddMask(tab, {isType=true})
            end
        end
    end)

end



