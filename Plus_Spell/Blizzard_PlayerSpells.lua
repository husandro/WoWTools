

--法术书
function WoWTools_MoveMixin.Events:Blizzard_PlayerSpells()
    self:Setup(PlayerSpellsFrame, {onShowFunc=true})
    for specContentFrame in PlayerSpellsFrame.SpecFrame.SpecContentFramePool:EnumerateActive() do
        self:Setup(specContentFrame, {frame=PlayerSpellsFrame})
    end

    self:Setup(PlayerSpellsFrame.TalentsFrame, {frame=PlayerSpellsFrame})
    self:Setup(PlayerSpellsFrame.TalentsFrame.ButtonsParent, {frame=PlayerSpellsFrame})
    self:Setup(PlayerSpellsFrame.SpellBookFrame, {frame=PlayerSpellsFrame})
end




local function Set_UI(self)
    self:SetButton(PlayerSpellsFrameCloseButton, {all=true})
    self:SetButton(PlayerSpellsFrame.MaximizeMinimizeButton.MaximizeButton, {all=true})
    self:SetButton(PlayerSpellsFrame.MaximizeMinimizeButton.MinimizeButton, {all=true})
    self:SetButton(PlayerSpellsFrame.SpellBookFrame.HelpPlateButton)

    self:SetAlphaColor(PlayerSpellsFrameBg)
    self:SetNineSlice(PlayerSpellsFrame, 0.3)
    self:SetTabSystem(PlayerSpellsFrame)

    self:SetAlphaColor(PlayerSpellsFrame.SpecFrame.Background, 0.3)--专精
    self:HideTexture(PlayerSpellsFrame.SpecFrame.BlackBG)

    self:SetAlphaColor(PlayerSpellsFrame.TalentsFrame.BottomBar, 0.3)--天赋
    self:HideTexture(PlayerSpellsFrame.TalentsFrame.BlackBG)
    self:SetSearchBox(PlayerSpellsFrame.TalentsFrame.SearchBox)
    self:SetMenu(PlayerSpellsFrame.TalentsFrame.LoadSystem.Dropdown)


    self:SetAlphaColor(PlayerSpellsFrame.SpellBookFrame.TopBar)--法术书
    self:SetSearchBox(PlayerSpellsFrame.SpellBookFrame.SearchBox)
    self:SetTabSystem(PlayerSpellsFrame.SpellBookFrame)



    --英雄专精
    self:SetNineSlice(HeroTalentsSelectionDialog, nil, nil, true, false)

    if PlayerSpellsFrame.SpellBookFrame.SettingsDropdown then--11.1.7
        self:SetAlphaColor(PlayerSpellsFrame.SpellBookFrame.SettingsDropdown.Icon, true, nil, nil)
        self:SetAlphaColor(PlayerSpellsFrame.SpellBookFrame.AssistedCombatRotationSpellFrame.Button.Border, nil, nil,  true)
    end
end

--天赋和法术书
function WoWTools_TextureMixin.Events:Blizzard_PlayerSpells()
    Set_UI(self)
end


function WoWTools_SpellMixin:Set_UI()
    Set_UI(WoWTools_TextureMixin)
end