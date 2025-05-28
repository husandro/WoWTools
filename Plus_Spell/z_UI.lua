--天赋，法术书
function WoWTools_MoveMixin.Events:Blizzard_PlayerSpells()
--英雄专精
    HeroTalentsSelectionDialog.p_point={PlayerSpellsFrame:GetPoint(1)}
    HeroTalentsSelectionDialog.p_point[2]= nil
    HeroTalentsSelectionDialog:HookScript('OnShow', function(frame)
        PlayerSpellsFrame:ClearAllPoints()
        PlayerSpellsFrame:SetPoint(frame.p_point[1], UIParent, frame.p_point[3], frame.p_point[4], frame.p_point[5])
    end)
    HeroTalentsSelectionDialog:HookScript('OnHide', function()
        self:SetPoint(PlayerSpellsFrame)
    end)
    self:Setup(HeroTalentsSelectionDialog)

--天赋，法术书
    self:Setup(PlayerSpellsFrame)

--专精
    for specContentFrame in PlayerSpellsFrame.SpecFrame.SpecContentFramePool:EnumerateActive() do
        self:Setup(specContentFrame, {frame=PlayerSpellsFrame})
    end

--天赋
    self:Setup(PlayerSpellsFrame.TalentsFrame, {frame=PlayerSpellsFrame})
    self:Setup(PlayerSpellsFrame.TalentsFrame.ButtonsParent, {frame=PlayerSpellsFrame})

--法术书
    self:Setup(PlayerSpellsFrame.SpellBookFrame, {frame=PlayerSpellsFrame})
end










function WoWTools_TextureMixin.Events:Blizzard_PlayerSpells()
    self:SetButton(PlayerSpellsFrameCloseButton, {all=true})
    self:SetButton(PlayerSpellsFrame.MaximizeMinimizeButton.MaximizeButton, {all=true})
    self:SetButton(PlayerSpellsFrame.MaximizeMinimizeButton.MinimizeButton, {all=true})
    

    --self:SetAlphaColor(PlayerSpellsFrameBg)
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
    self:SetFrame(PlayerSpellsFrame.SpellBookFrame.SearchPreviewContainer, {isMinAlpha=true})

    self:SetTabSystem(PlayerSpellsFrame.SpellBookFrame)



    --英雄专精
    self:SetNineSlice(HeroTalentsSelectionDialog, nil, nil, true, false)

    if PlayerSpellsFrame.SpellBookFrame.SettingsDropdown then--11.1.7
        self:SetAlphaColor(PlayerSpellsFrame.SpellBookFrame.SettingsDropdown.Icon, true, nil, nil)
        self:SetAlphaColor(PlayerSpellsFrame.SpellBookFrame.AssistedCombatRotationSpellFrame.Button.Border, nil, nil,  true)
    end




--背景
    PlayerSpellsFrameBg:ClearAllPoints()
    PlayerSpellsFrameBg:SetPoint('TOPLEFT', PlayerSpellsFrame, 3, -3)
    PlayerSpellsFrameBg:SetPoint('BOTTOMRIGHT', PlayerSpellsFrame, -3, 3)

--专精 ClassSpecFrameTemplate
    PlayerSpellsFrame.SpecFrame.Background:ClearAllPoints()
    PlayerSpellsFrame.SpecFrame.Background:SetPoint('TOPLEFT', PlayerSpellsFrame, 3, -3)
    PlayerSpellsFrame.SpecFrame.Background:SetPoint('BOTTOMRIGHT', PlayerSpellsFrame, -3, 3)

--天赋 ClassTalentsFrameTemplate
    PlayerSpellsFrame.TalentsFrame.Background:ClearAllPoints()
    PlayerSpellsFrame.TalentsFrame.Background:SetPoint('TOPLEFT', PlayerSpellsFrame, 3, -3)
    PlayerSpellsFrame.TalentsFrame.Background:SetPoint('BOTTOMRIGHT', PlayerSpellsFrame, -3, 3)

    PlayerSpellsFrame.TalentsFrame.BottomBar:SetAlpha(0)
    PlayerSpellsFrame.TalentsFrame.HeroTalentsContainer.ExpandedContainer.Background:SetAlpha(0.2)
    PlayerSpellsFrame.TalentsFrame.HeroTalentsContainer.PreviewContainer.Background:SetAlpha(0.2)

--法术书 SpellBookFrameTemplate
    self:SetFrame(PlayerSpellsFrame.SpellBookFrame.HelpPlateButton, {alpha=0.3})
    --PlayerSpellsFrame.SpellBookFrame.BookBGHalved

    --[[PlayerSpellsFrame.TalentsFrame.Background:ClearAllPoints()
    PlayerSpellsFrame.TalentsFrame.Background:SetPoint('TOPLEFT')
    PlayerSpellsFrame.TalentsFrame.Background:SetPoint('BOTTOMRIGHT', PlayerSpellsFrame.TalentsFrame, 'BOTTOMRIGHT')]]



    hooksecurefunc(PlayerSpellsFrame.TalentsFrame, "UpdateSpecBackground", function(frame)
        if PlayerSpellsFrameBg.Set_BGTexture then
            --[[local currentSpecID = frame:GetSpecID()
            local specVisuals = ClassTalentUtil.GetVisualsForSpecID(currentSpecID);
            if specVisuals and specVisuals.background and C_Texture.GetAtlasInfo(specVisuals.background) then
                PlayerSpellsFrameBg.set_BGData.p_texture= specVisuals.background
            end]]

            PlayerSpellsFrameBg:Set_BGTexture()
        end
    end)

    WoWTools_TextureMixin:Init_BGMenu_Frame(
        PlayerSpellsFrame,
        'PlayerSpellsFrame',
        PlayerSpellsFrameBg,
    {
        notAnims=true,
        isHook=true,
        setValueFunc=function() WoWTools_Mixin:Call(PlayerSpellsFrame.TalentsFrame.UpdateSpecBackground, PlayerSpellsFrame.TalentsFrame) end,
        icons={
            PlayerSpellsFrame.SpecFrame.Background,
            PlayerSpellsFrame.TalentsFrame.Background,
        }
    })
end