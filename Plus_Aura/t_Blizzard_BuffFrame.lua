--AuraButtonArtTemplate

local function Aura_Add(self)
    for _, auraFrame in ipairs(self.auraFrames) do
        auraFrame.IconMask= auraFrame:CreateMaskTexture()
        auraFrame.IconMask:SetAtlas('UI-HUD-CoolDownManager-Mask')
        auraFrame.IconMask:SetPoint('TOPLEFT', auraFrame.Icon, 0.5, -0.5)
        auraFrame.IconMask:SetPoint('BOTTOMRIGHT', auraFrame.Icon, -0.5, 0.5)
        auraFrame.Icon:AddMaskTexture(auraFrame.IconMask)
    end
end





function WoWTools_TextureMixin.Events:Blizzard_BuffFrame()
    Aura_Add(BuffFrame)
    --Aura_Add(DebuffFrame)
end