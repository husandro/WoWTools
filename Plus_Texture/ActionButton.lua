--动作条
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


local function Init_HooKey(btn)
    if not btn then
        return
    end
    if btn.UpdateHotkeys then
        hooksecurefunc(btn, 'UpdateHotkeys', function(self)
            if self.HotKey then--快捷键
                local text= WoWTools_KeyMixin:GetHotKeyText(self.HotKey:GetText(), nil)
                if text then
                    self.HotKey:SetText(text)
                end
                self.HotKey:SetTextColor(1,1,1,1)
            end
        end)
    end
    if btn.cooldown then--缩小，冷却，字体
        btn.cooldown:SetCountdownFont('NumberFontNormal')
    end


    Set_Texture(btn)
end

















local function Init()
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


    hooksecurefunc(MainMenuBar, 'UpdateDividers', function(self)--主动作条
        for i=1, MAIN_MENU_BAR_NUM_BUTTONS do
            Set_Texture(_G['ActionButton'..i])
        end
        if self.hideBarArt or self.numRows > 1 or self.buttonPadding > self.minButtonPadding then
            return
        end

        local dividersPool = self.isHorizontal and self.HorizontalDividersPool or self.VerticalDividersPool
        if dividersPool then
            for pool in dividersPool:EnumerateActive() do
                WoWTools_TextureMixin:SetFrame(pool)
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

    WoWTools_TextureMixin:SetFrame(MainMenuBar.ActionBarPageNumber.UpButton, {alpha=0.5})
    WoWTools_TextureMixin:SetFrame(MainMenuBar.ActionBarPageNumber.DownButton, {alpha=0.5})
    WoWTools_ColorMixin:Setup(MainMenuBar.ActionBarPageNumber.Text, {type='FontString'})

    if MainMenuBar.EndCaps then
        WoWTools_TextureMixin:SetAlphaColor(MainMenuBar.EndCaps.LeftEndCap, true, nil, nil)
        WoWTools_TextureMixin:SetAlphaColor(MainMenuBar.EndCaps.RightEndCap, true, nil, nil)
    end
    WoWTools_TextureMixin:SetAlphaColor(MainMenuBar.BorderArt, nil, nil, 0.3)
end











--区域技能
function WoWTools_TextureMixin.Events:Blizzard_ZoneAbility()
    --self:SetAlphaColor(ZoneAbilityFrame.Style, nil, true, 0.3)
    hooksecurefunc(ZoneAbilityFrame, 'UpdateDisplayedZoneAbilities', function(frame)
        for btn in frame.SpellButtonContainer:EnumerateActive() do
            if not btn.IconMask then
                Set_Texture(btn)
            end
        end
    end)
end


function WoWTools_TextureMixin:Init_Action_Button()
    Init()
end
