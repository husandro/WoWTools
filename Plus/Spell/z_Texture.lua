
--天赋，法术书
function WoWTools_TextureMixin.Events:Blizzard_PlayerSpells()
    self:SetButton(PlayerSpellsFrameCloseButton)
    self:SetButton(PlayerSpellsFrame.MaximizeMinimizeButton.MaximizeButton)
    self:SetButton(PlayerSpellsFrame.MaximizeMinimizeButton.MinimizeButton)
    self:HideTexture(PlayerSpellsFrame.TopTileStreaks)


    self:SetNineSlice(PlayerSpellsFrame)
    self:SetTabButton(PlayerSpellsFrame)

    self:SetAlphaColor(PlayerSpellsFrame.SpecFrame.Background, 0.3)--专精
    self:HideTexture(PlayerSpellsFrame.SpecFrame.BlackBG)

    self:SetAlphaColor(PlayerSpellsFrame.TalentsFrame.BottomBar, 0.3)--天赋
    self:HideTexture(PlayerSpellsFrame.TalentsFrame.BlackBG)
    self:SetEditBox(PlayerSpellsFrame.TalentsFrame.SearchBox)
    self:SetMenu(PlayerSpellsFrame.TalentsFrame.LoadSystem.Dropdown)
    self:SetUIButton(PlayerSpellsFrame.TalentsFrame.ApplyButton)


    self:HideTexture(PlayerSpellsFrame.SpellBookFrame.TopBar)--法术书

    self:SetEditBox(PlayerSpellsFrame.SpellBookFrame.SearchBox)
    self:SetFrame(PlayerSpellsFrame.SpellBookFrame.SearchPreviewContainer)

    --英雄专精
    self:SetNineSlice(HeroTalentsSelectionDialog, self.min, true)
    self:SetButton(HeroTalentsSelectionDialog.CloseButton)

    self:SetAlphaColor(PlayerSpellsFrame.SpellBookFrame.SettingsDropdown.Icon, true, nil, nil)
    self:SetAlphaColor(PlayerSpellsFrame.SpellBookFrame.AssistedCombatRotationSpellFrame.Button.Border, nil, nil,  true)





--背景
    self:HideTexture(PlayerSpellsFrameBg)

--专精 ClassSpecFrameTemplate
    --PlayerSpellsFrame.SpecFrame.Background:ClearAllPoints()
    --PlayerSpellsFrame.SpecFrame.Background:SetPoint('TOPLEFT', PlayerSpellsFrame, 3, -3)
    --PlayerSpellsFrame.SpecFrame.Background:SetPoint('BOTTOMRIGHT', PlayerSpellsFrame, -3, 3)

--天赋 ClassTalentsFrameTemplate
    --PlayerSpellsFrame.TalentsFrame.Background:ClearAllPoints()
    --PlayerSpellsFrame.TalentsFrame.Background:SetPoint('TOPLEFT', PlayerSpellsFrame, 3, -3)
    --PlayerSpellsFrame.TalentsFrame.Background:SetPoint('BOTTOMRIGHT', PlayerSpellsFrame, -3, 3)



--新建 天赋，配置
    self:SetFrame(ClassTalentLoadoutCreateDialog.Border, {alpha=1})
    self:SetEditBox(ClassTalentLoadoutCreateDialog.NameControl.EditBox)
--导入，天赋，配置
    self:SetFrame(ClassTalentLoadoutImportDialog.Border, {alpha=1})
    self:SetEditBox(ClassTalentLoadoutImportDialog.ImportControl.InputContainer.EditBox)
    self:SetEditBox(ClassTalentLoadoutImportDialog.NameControl.EditBox)
    self:SetFrame(ClassTalentLoadoutImportDialog.ImportControl.InputContainer, {alpha=1})

    PlayerSpellsFrame.TalentsFrame.BottomBar:SetAlpha(0)
    PlayerSpellsFrame.TalentsFrame.HeroTalentsContainer.ExpandedContainer.Background:SetAlpha(0.2)
    PlayerSpellsFrame.TalentsFrame.HeroTalentsContainer.PreviewContainer.Background:SetAlpha(0.2)

--法术书 SpellBookFrameTemplate
    self:SetFrame(PlayerSpellsFrame.SpellBookFrame.HelpPlateButton, {alpha=0.3})

    self:Init_BGMenu_Frame(PlayerSpellsFrame, {
        settings=function(_, texture, alpha)
            PlayerSpellsFrame.SpecFrame.Background:SetAlpha(texture and 0 or alpha or 1)
            PlayerSpellsFrame.TalentsFrame.Background:SetAlpha(texture and 0 or alpha or 1)
        end
    })
end