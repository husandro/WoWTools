
local function Set_Texture(btn)
    WoWTools_TextureMixin:HideTexture(btn.SlotArt)
    WoWTools_TextureMixin:HideTexture(btn.NormalTexture)--外框，方块
    WoWTools_TextureMixin:HideTexture(btn.SlotBackground, true)--背景
    if not btn.IconMask then
        WoWTools_ButtonMixin:AddMask(btn, false, btn.Icon)
    else
        btn.IconMask:ClearAllPoints()
        btn.IconMask:SetAtlas('UI-HUD-CoolDownManager-Mask')
        btn.IconMask:SetPoint('TOPLEFT', btn.Icon or btn, 0.5, -0.5)
        btn.IconMask:SetPoint('BOTTOMRIGHT', btn.Icon or btn, -0.5, 0.5)
    end
end

local function Set_Assisted(self)
    self:SetFrameStrata('BACKGROUND')
end




local function Init_HooKey(btn)
    if not btn then
        return
    end

    if btn.UpdateHotkeys then
        hooksecurefunc(btn, 'UpdateHotkeys', function(b)
            if b.HotKey then--快捷键
                local text= WoWTools_KeyMixin:GetHotKeyText(b.HotKey:GetText(), nil)
                if text then
                    b.HotKey:SetText(text)
                end
                b.HotKey:SetTextColor(1,1,1,1)
            end
        end)
    end
    if btn.cooldown then--缩小，冷却，字体
        btn.cooldown:SetCountdownFont('NumberFontNormal')
    end

    if btn.AssistedCombatRotationFrame then
        Set_Assisted(btn.AssistedCombatRotationFrame)
        btn.AssistedCombatRotationFrame:HookScript('OnShow', function(frame)
            Set_Assisted(frame)
        end)
    end

    Set_Texture(btn)
end







--动作条
function WoWTools_TextureMixin.Events:Blizzard_ActionBar()
    for i=1, MAIN_MENU_BAR_NUM_BUTTONS do
        for _, name in pairs({
            "ActionButton",
            "MultiBarBottomLeftButton",
            "MultiBarBottomRightButton",
            "MultiBarLeftButton",
            "MultiBarRightButton",
            "MultiBar5Button",
            "MultiBar6Button",
            "MultiBar7Button",
            "PetActionButton",
            "OverrideActionBarButton",
        }) do
            Init_HooKey(_G[name..i])
        end
    end

    Init_HooKey(_G['ExtraActionButton1'])

    hooksecurefunc(ActionBarButtonAssistedCombatRotationFrameMixin, 'OnShow', function(frame)
        Set_Assisted(frame)
    end)



    --hooksecurefunc(MainMenuBar, 'UpdateDividers', function(bar)--主动作条 
    EditModeManagerFrame:HookScript('OnHide', function()
        for i=1, MAIN_MENU_BAR_NUM_BUTTONS do
            Set_Texture(_G['ActionButton'..i])
        end

        local bar= MainMenuBar
        --[[if bar.hideBarArt or bar.numRows > 1 or bar.buttonPadding > bar.minButtonPadding then
            return
        end]]

        local dividersPool = bar.isHorizontal and bar.HorizontalDividersPool or bar.VerticalDividersPool
        if dividersPool then
            for pool in dividersPool:EnumerateActive() do
                self:SetFrame(pool)
            end
        end
    end)

    OverrideActionBarExpBarOverlayFrameText:SetAlpha(0.3)
    OverrideActionBarExpBar:HookScript('OnLeave', function()
        OverrideActionBarExpBarOverlayFrameText:SetAlpha(0.3)
    end)
    OverrideActionBarExpBar:HookScript('OnEnter', function()
        OverrideActionBarExpBarOverlayFrameText:SetAlpha(1)
    end)

    self:SetFrame(MainMenuBar.ActionBarPageNumber.UpButton, {alpha=0.5})
    self:SetFrame(MainMenuBar.ActionBarPageNumber.DownButton, {alpha=0.5})
    WoWTools_ColorMixin:Setup(MainMenuBar.ActionBarPageNumber.Text, {type='FontString'})

    if MainMenuBar.EndCaps then
        self:SetAlphaColor(MainMenuBar.EndCaps.LeftEndCap, true, nil, nil)
        self:SetAlphaColor(MainMenuBar.EndCaps.RightEndCap, true, nil, nil)
    end
    self:SetAlphaColor(MainMenuBar.BorderArt, nil, nil, 0.3)


    self:HideTexture(SpellFlyout.Background.Start)
    self:HideTexture(SpellFlyout.Background.End)
    self:HideTexture(SpellFlyout.Background.HorizontalMiddle)
    self:HideTexture(SpellFlyout.Background.VerticalMiddle)
end


























--区域技能
function WoWTools_TextureMixin.Events:Blizzard_ZoneAbility()
    --hooksecurefunc(ZoneAbilityFrame, 'UpdateDisplayedZoneAbilities', function(frame)
    for btn in ZoneAbilityFrame.SpellButtonContainer:EnumerateActive() do
        Set_Texture(btn)
    end

    ZoneAbilityFrame:HookScript('OnShow', function(frame)
        for btn in frame.SpellButtonContainer:EnumerateActive() do
            if not btn.IconMask then
                Set_Texture(btn)
            end
        end
    end)
end


