local e= select(2, ...)

WoWToolsChatButtonMixin= {}


function WoWToolsChatButtonMixin:Init(disableTab)
    self.ChatButton= e.Cbtn(nil, {name='WoWToolsChatButtonFrame', icon='hide', size={10, 30}})
    self.LastButton= self.ChatButton
    self.DisabledAdd= disableTab or {}
    return self.ChatButton
end

function WoWToolsChatButtonMixin:CreateButton(name)
    if not self.ChatButton or self.DisabledAdd[name] then
        return
    end

    local btn= CreateFrame("Button", 'WoWToolsChatButton_'..name, self.ChatButton)
    btn:SetPoint('LEFT', self.LastButton, 'RIGHT')

    btn:SetSize(30, 30)
    btn:RegisterForClicks('AnyDown')
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

    --[[btn.border=btn:CreateTexture(nil, 'ARTWORK')
    btn.border:SetAllPoints(btn)
    btn.border:SetAtlas('bag-reagent-border')

    e.Set_Label_Texture_Color(btn.border, {type='Texture', alpha= 0.5})]]

    function btn:state_enter()
        self:GetParent():SetButtonState('PUSHED')
    end
    function btn:state_leave()
        self:GetParent():SetButtonState('NORMAL')
    end

    self.LastButton= btn

    return btn
end