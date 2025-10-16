
local function Set_Texture(self)
    if self then
        WoWTools_TextureMixin:HideTexture(self.SlotArt)--, nil, true, 0)
        WoWTools_TextureMixin:HideTexture(self.NormalTexture)--, nil, true, 0)--外框，方块
        WoWTools_TextureMixin:HideTexture(self.SlotBackground)--, nil, true, 0)--背景

        if not self.IconMask then
            WoWTools_ButtonMixin:AddMask(self, false, self.Icon)
        else
            self.IconMask:ClearAllPoints()
            self.IconMask:SetAtlas('UI-HUD-CoolDownManager-Mask')
            self.IconMask:SetPoint('TOPLEFT', self.Icon or self, 0.5, -0.5)
            self.IconMask:SetPoint('BOTTOMRIGHT', self.Icon or self, -0.5, 0.5)
        end
    end
end

local function Set_Assisted(self)
    if not InCombatLockdown() then
        self:SetFrameStrata('BACKGROUND')
    else
        EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner)
            self:SetFrameStrata('BACKGROUND')
            EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
        end)
    end
end

local function Set_KeyText(self)
    local text= WoWTools_KeyMixin:GetHotKeyText(self.HotKey:GetText(), nil)
    if text then
        self.HotKey:SetText(text)
    end
    self.HotKey:SetTextColor(1,1,1,1)
end

local function Set_MainMenuBarPool()
    local dividersPool = MainMenuBar.isHorizontal and MainMenuBar.HorizontalDividersPool or MainMenuBar.VerticalDividersPool
    if dividersPool then
        for pool in dividersPool:EnumerateActive() do
            WoWTools_TextureMixin:HideFrame(pool)
        end
    end
end


local function Init_HooKey(btn)
    if not btn then
        return
    end
    Set_Texture(btn)

    if btn.UpdateHotkeys then
        Set_KeyText(btn)
        WoWTools_DataMixin:Hook(btn, 'UpdateHotkeys', function(b)
            Set_KeyText(b)
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
end



--动作条
function WoWTools_TextureMixin.Events:Blizzard_ActionBar()


    for i=1, MAIN_MENU_BAR_NUM_BUTTONS do
        for _, name in pairs({
            "ActionButton",
            "MultiBarBottomLeftButton",
            "MultiBarBottomRightButton",
            "MultiBarLeftButton",
            "MultiBarRightButton",--这个有Bug SetShown
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


    for i=1, 10 do
        Set_Texture(_G['StanceButton'..i])--..'NormalTexture'])
    end

    WoWTools_DataMixin:Hook(ActionBarButtonAssistedCombatRotationFrameMixin, 'OnShow', function(frame)
        Set_Assisted(frame)
    end)



    --WoWTools_DataMixin:Hook(MainMenuBar, 'UpdateDividers', function(bar)--主动作条 

    Set_MainMenuBarPool()


    EditModeManagerFrame:HookScript('OnHide', function()
        for i=1, MAIN_MENU_BAR_NUM_BUTTONS do
            Set_Texture(_G['ActionButton'..i])
        end
       Set_MainMenuBarPool()
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
    self:SetAlphaColor(MainMenuBar.BorderArt, nil, nil, 0)


    self:HideTexture(SpellFlyout.Background.Start)
    self:HideTexture(SpellFlyout.Background.End)
    self:HideTexture(SpellFlyout.Background.HorizontalMiddle)
    self:HideTexture(SpellFlyout.Background.VerticalMiddle)



--Flyout
    --WoWTools_DataMixin:Hook(SpellFlyoutPopupButtonMixin, 'OnLoad', function(btn)
end


























--区域技能
function WoWTools_TextureMixin.Events:Blizzard_ZoneAbility()
    for btn in ZoneAbilityFrame.SpellButtonContainer:EnumerateActive() do
        Set_Texture(btn)
    end

    self:SetAlphaColor(ZoneAbilityFrame.Style, nil, nil, 0.3)

    hooksecurefunc(ZoneAbilityFrame, 'UpdateDisplayedZoneAbilities', function(frame)
        for btn in frame.SpellButtonContainer:EnumerateActive() do
            if not btn.IconMask then
                Set_Texture(btn)
            end
        end
    end)
end















--[[
战斗宠物

技能, 提示
	PetBattlePrimaryUnitTooltip
    PetBattleUnitTooltipTemplate
    TooltipBackdropTemplate

	PetBattlePrimaryAbilityTooltip
    SharedPetBattleAbilityTooltipTemplate
]]
function WoWTools_TextureMixin.Events:Blizzard_PetBattleUI()
    self:HideTexture(PetBattleFrame.TopArtLeft)
    self:HideTexture(PetBattleFrame.TopArtRight)
    self:HideTexture(PetBattleFrame.TopVersus)
    PetBattleFrame.TopVersusText:SetText('')
    PetBattleFrame.TopVersusText:SetShown(false)
    self:HideTexture(PetBattleFrame.WeatherFrame.BackgroundArt)

    self:HideTexture(PetBattleFrameXPBarLeft)
    self:HideTexture(PetBattleFrameXPBarRight)
    self:HideTexture(PetBattleFrameXPBarMiddle)

    self:HideTexture(PetBattleFrame.BottomFrame.LeftEndCap)
    self:HideTexture(PetBattleFrame.BottomFrame.RightEndCap)
    self:HideTexture(PetBattleFrame.BottomFrame.Background)
    self:HideTexture(PetBattleFrame.BottomFrame.TurnTimer.ArtFrame2)

    PetBattleFrame.BottomFrame.FlowFrame:SetShown(false)
    PetBattleFrame.BottomFrame.Delimiter:SetShown(false)

    for i=1,NUM_BATTLE_PETS_IN_BATTLE do
        if PetBattleFrame.BottomFrame.PetSelectionFrame['Pet'..i] then
            WoWTools_ColorMixin:Setup(PetBattleFrame.BottomFrame.PetSelectionFrame['Pet'..i].SelectedTexture, {type='Texture', color={r=0,g=1,b=1}})
        end
    end

    --宠物， 主面板,主技能, 提示
    --for _, btn in pairs(PetBattleFrame.BottomFrame.abilityButtons) do
    WoWTools_DataMixin:Hook('PetBattleAbilityButton_UpdateHotKey', function(frame)
        if not frame.HotKey:IsShown() then
            return
        end
        local key= WoWTools_KeyMixin:GetHotKeyText(GetBindingKey("ACTIONBUTTON"..frame:GetID()), nil)
        if key then
            frame.HotKey:SetText(key)
        end
        frame.HotKey:SetTextColor(1,1,1)
    end)

    self:HideFrame(PetBattleFrame.BottomFrame.MicroButtonFrame)

    WoWTools_DataMixin:Hook('PetBattleFrame_UpdatePassButtonAndTimer', function(frame)--Blizzard_PetBattleUI.lua
        self:HideTexture(frame.BottomFrame.TurnTimer.TimerBG)
        self:HideTexture(frame.BottomFrame.TurnTimer.ArtFrame)
        self:HideTexture(frame.BottomFrame.TurnTimer.ArtFrame2)
    end)

    PetBattlePrimaryUnitTooltip:SetBackdropBorderColor(0,0,0, 0.1)
    PetBattlePrimaryAbilityTooltip:SetBackdropBorderColor(0,0,0, 0.1)
end