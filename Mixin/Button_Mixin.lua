local e= select(2, ...)

Button_Mixin={}
local buttonIndex= 1

function Button_Mixin:CreateSecure(tab)
    tab= tab or {}
    local name= tab.name or ('WoWToolsToolsButton'..buttonIndex)--设置 名称
    local parent= tab.parent or UIParent--设置 名称
    local setID= tab.setID
    local size= tab.size or 30

    local btn= CreateFrame("Button", name, parent, "SecureActionButtonTemplate", setID)

    btn:SetSize(size, size)
    btn:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
    btn:EnableMouseWheel(true)

    btn:SetPushedAtlas('bag-border-highlight')
    btn:SetHighlightAtlas('bag-border')

    btn.mask= btn:CreateMaskTexture()
    btn.mask:SetTexture('Interface\\CHARACTERFRAME\\TempPortraitAlphaMask')
    btn.mask:SetPoint("TOPLEFT", btn, "TOPLEFT", 4, -4)
    btn.mask:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -6, 6)

    btn.background= btn:CreateTexture(nil, 'BACKGROUND')
    btn.background:SetAllPoints(btn)
    btn.background:SetAtlas('bag-reagent-border-empty')
    btn.background:SetAlpha(0.5)
    btn.background:AddMaskTexture(btn.mask)

    btn.texture=btn:CreateTexture(nil, 'BORDER')
    btn.texture:SetPoint("TOPLEFT", btn, "TOPLEFT", 4, -4)
    btn.texture:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -6, 6)
    btn.texture:AddMaskTexture(btn.mask)

    btn.border=btn:CreateTexture(nil, 'ARTWORK')
    btn.border:SetAllPoints(btn)

    btn.border:SetAtlas('bag-reagent-border')

    e.Set_Label_Texture_Color(btn.border, {type='Texture', 0.5})
    buttonIndex= buttonIndex+1

    return btn
end

