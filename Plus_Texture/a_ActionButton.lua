local e= select(2, ...)
--动作条
local KEY_BUTTON = KEY_BUTTON10:gsub(10, '')--"鼠标按键10"

function e.GetHotKeyText(text, action)
    if text and text:find(KEY_BUTTON) then
       return text:gsub(KEY_BUTTON, 'm')
    elseif action then
        text= GetBindingKeyForAction(action, false, false)
        if text and text:find(KEY_BUTTON) then
            text= text:gsub(KEY_BUTTON, 'm')
        end
        return text
    end
end







local function Set_Texture(btn)
    WoWTools_PlusTextureMixin:HideTexture(btn.SlotArt)
    WoWTools_PlusTextureMixin:HideTexture(btn.NormalTexture)--外框，方块
    WoWTools_PlusTextureMixin:HideTexture(btn.SlotBackground, true)--背景
end


local function Init_HooKey(btn)
    if not btn then
        return
    end
    if btn.UpdateHotkeys then
        hooksecurefunc(btn, 'UpdateHotkeys', function(self)
            if self.HotKey then--快捷键
                local text=self.HotKey:GetText()
                if text and text:find(KEY_BUTTON) then
                    self.HotKey:SetText(e.GetHotKeyText(text, nil))
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
        }) do
            Init_HooKey(_G[name..i])
        end
    end

    hooksecurefunc(MainMenuBar, 'UpdateDividers', function(self)--主动作条
        for i=1, MAIN_MENU_BAR_NUM_BUTTONS do
            Set_Texture(_G['ActionButton'..i])
        end
        if self.hideBarArt or self.numRows > 1 or self.buttonPadding > self.minButtonPadding then
            return
        end

        local dividersPool = self.isHorizontal and self.HorizontalDividersPool or self.VerticalDividersPool
        if dividersPool then
            for i, actionButton in pairs(self.actionButtons) do
                for pool in dividersPool:EnumerateActive() do
                    WoWTools_PlusTextureMixin:SetFrame(pool)
                end
            end
        end
    end)

    --[[local dividersPool = MainMenuBar.isHorizontal and MainMenuBar.HorizontalDividersPool or MainMenuBar.VerticalDividersPool
    if dividersPool then
        for i, actionButton in pairs(MainMenuBar.actionButtons) do
            for pool in dividersPool:EnumerateActive() do
                WoWTools_PlusTextureMixin:SetFrame(pool)
            end
        end
    end]]

    WoWTools_PlusTextureMixin:SetFrame(MainMenuBar.ActionBarPageNumber.UpButton, {alpha=0.5})
    WoWTools_PlusTextureMixin:SetFrame(MainMenuBar.ActionBarPageNumber.DownButton, {alpha=0.5})
    WoWTools_ColorMixin:SetLabelTexture(MainMenuBar.ActionBarPageNumber.Text, {type='FontString'})

    if MainMenuBar.EndCaps then
        WoWTools_PlusTextureMixin:SetAlphaColor(MainMenuBar.EndCaps.LeftEndCap, true, nil, nil)
        WoWTools_PlusTextureMixin:SetAlphaColor(MainMenuBar.EndCaps.RightEndCap, true, nil, nil)
    end
    WoWTools_PlusTextureMixin:SetAlphaColor(MainMenuBar.BorderArt, nil, nil, 0.3)



end














function WoWTools_PlusTextureMixin:Init_Action_Button()
    Init()
end
