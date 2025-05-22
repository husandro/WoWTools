

--法术书
function WoWTools_MoveMixin.Events:Blizzard_PlayerSpells()
    HeroTalentsSelectionDialog.p_point={PlayerSpellsFrame:GetPoint(1)}
    HeroTalentsSelectionDialog.p_point[2]= nil
    HeroTalentsSelectionDialog:HookScript('OnShow', function(frame)
        PlayerSpellsFrame:ClearAllPoints()
        PlayerSpellsFrame:SetPoint(frame.p_point[1], UIParent, frame.p_point[3], frame.p_point[4], frame.p_point[5])
    end)
    HeroTalentsSelectionDialog:HookScript('OnHide', function()
        self:SetPoint(PlayerSpellsFrame)
    end)

    self:Setup(PlayerSpellsFrame)
    --self:Setup(HeroTalentsSelectionDialog)
    for specContentFrame in PlayerSpellsFrame.SpecFrame.SpecContentFramePool:EnumerateActive() do
        self:Setup(specContentFrame, {frame=PlayerSpellsFrame})
    end

    self:Setup(PlayerSpellsFrame.TalentsFrame, {frame=PlayerSpellsFrame})
    self:Setup(PlayerSpellsFrame.TalentsFrame.ButtonsParent, {frame=PlayerSpellsFrame})
    self:Setup(PlayerSpellsFrame.SpellBookFrame, {frame=PlayerSpellsFrame})
end

    --[[hooksecurefunc(PlayerSpellsFrame.TalentsFrame, 'AcquireTalentButton', function(frame, nodeInfo, talentType, offsetX, offsetY, initFunction)
        print(nodeInfo, talentType, offsetX, offsetY, initFunction)
    end)]]





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
    self:SetEditBox(PlayerSpellsFrame.TalentsFrame.SearchBox)
    self:SetMenu(PlayerSpellsFrame.TalentsFrame.LoadSystem.Dropdown)


    self:SetAlphaColor(PlayerSpellsFrame.SpellBookFrame.TopBar)--法术书
    self:SetEditBox(PlayerSpellsFrame.SpellBookFrame.SearchBox)
    self:SetTabSystem(PlayerSpellsFrame.SpellBookFrame)



    --英雄专精
    self:SetNineSlice(HeroTalentsSelectionDialog, nil, nil, true, false)

    if PlayerSpellsFrame.SpellBookFrame.SettingsDropdown then--11.1.7
        self:SetAlphaColor(PlayerSpellsFrame.SpellBookFrame.SettingsDropdown.Icon, true, nil, nil)
        self:SetAlphaColor(PlayerSpellsFrame.SpellBookFrame.AssistedCombatRotationSpellFrame.Button.Border, nil, nil,  true)
    end

    Set_UI=function()end
end

--天赋和法术书
function WoWTools_TextureMixin.Events:Blizzard_PlayerSpells()
    Set_UI(self)
end


function WoWTools_SpellMixin:Set_UI()
    Set_UI(WoWTools_TextureMixin)
end