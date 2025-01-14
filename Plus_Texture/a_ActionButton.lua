
--动作条
local KEY_BUTTON = KEY_BUTTON10:gsub(10, '')--"鼠标按键10"



local function Set_HooKey(btn)
    if not btn then
        return
    end
    if btn.UpdateHotkeys then
        hooksecurefunc(btn, 'UpdateHotkeys', function(self)
            if self.HotKey then--快捷键
                local text=self.HotKey:GetText()
                if text and text:find(KEY_BUTTON) then
                    self.HotKey:SetText(text:gsub(KEY_BUTTON, 'm'))
                end
                self.HotKey:SetTextColor(1,1,1,1)
            end
        end)
    end
    if btn.cooldown then--缩小，冷却，字体
        btn.cooldown:SetCountdownFont('NumberFontNormal')
    end
    WoWTools_PlusTextureMixin:HideTexture(btn.NormalTexture)--外框，方块
    WoWTools_PlusTextureMixin:HideTexture(btn.SlotBackground, true)--背景
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
            Set_HooKey(_G[name..i])
        end
    end

    hooksecurefunc(MainMenuBar, 'UpdateDividers', function(self)--主动作条
        for i=1, MAIN_MENU_BAR_NUM_BUTTONS do
            local btn=_G['ActionButton'..i]
            if btn then
                WoWTools_PlusTextureMixin:HideTexture(btn.NormalTexture)--外框，方块
                WoWTools_PlusTextureMixin:HideTexture(btn.SlotBackground, true)--背景
            end
        end
    end)

    WoWTools_PlusTextureMixin:SetFrame(MainMenuBar.ActionBarPageNumber.UpButton, {alpha=0.3})
    WoWTools_PlusTextureMixin:SetFrame(MainMenuBar.ActionBarPageNumber.DownButton, {alpha=0.3})
    WoWTools_ColorMixin:SetLabelTexture(MainMenuBar.ActionBarPageNumber.Text, {type='FontString'})

    if MainMenuBar.EndCaps then
        WoWTools_PlusTextureMixin:SetAlphaColor(MainMenuBar.EndCaps.LeftEndCap, true, nil, 0.3)
        WoWTools_PlusTextureMixin:SetAlphaColor(MainMenuBar.EndCaps.RightEndCap, true, nil, 0.3)
    end
    WoWTools_PlusTextureMixin:SetAlphaColor(MainMenuBar.BorderArt, nil, nil, 0.3)
end














function WoWTools_PlusTextureMixin:Init_Action_Button()
    Init()
end
