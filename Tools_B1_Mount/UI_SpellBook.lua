--法术书，选项
local e= select(2, ...)
local function Save()
    return WoWTools_MountMixin.Save
end






local function set_Use_Spell_Button(btn, spellID)
    if not btn.mountSpell then
        btn.mountSpell= WoWTools_ButtonMixin:Cbtn(btn, {size=16, atlas='hud-microbutton-Mounts-Down'})
        btn.mountSpell:SetPoint('TOP', btn, 'BOTTOM', -8, 0)
        function btn.mountSpell:set_alpha()
            if self.spellID then
                self:SetAlpha(Save().Mounts[SPELLS][self.spellID] and 1 or 0.2)
            end
        end
        function btn.mountSpell:set_tooltips()
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(WoWTools_ToolsMixin.addName, WoWTools_MountMixin.addName)
            e.tips:AddLine(' ')
            if self.spellID then
                e.tips:AddDoubleLine(
                    '|T'..(C_Spell.GetSpellTexture(self.spellID) or 0)..':0|t'
                    ..(C_Spell.GetSpellLink(self.spellID) or self.spellID)
                    ..' '..e.GetEnabeleDisable(Save().Mounts[SPELLS][self.spellID]),

                    e.Icon.left
                )
            end
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
            e.tips:Show()
            self:SetAlpha(1)
        end
        btn.mountSpell:SetScript('OnLeave', function(self) e.tips:Hide() self:set_alpha()  end)
        btn.mountSpell:SetScript('OnEnter', btn.mountSpell.set_tooltips)
        btn.mountSpell:SetScript('OnMouseDown', function(self, d)
            if d=='LeftButton' then
                if self.spellID then
                    Save().Mounts[SPELLS][self.spellID]= not Save().Mounts[SPELLS][self.spellID] and true or nil
                    self:set_tooltips()
                    self:set_alpha()
                    WoWTools_MountMixin.MountButton:settings()
                    print(WoWTools_Mixin.addName, WoWTools_MountMixin.addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD, C_Spell.GetSpellLink(self.spellID))
                end
            else
                WoWTools_MountMixin:Init_Menu_Spell(self)
            end
        end)
    end

    btn.mountSpell.spellID= spellID
    btn.mountSpell:set_alpha()
    btn.mountSpell:SetShown(spellID and true or false)
end









local function Init()
    if not SpellFlyoutButton_UpdateGlyphState then
        return
    end
    hooksecurefunc('SpellFlyoutButton_UpdateGlyphState', function(self)--法术书，界面, Flyout, 菜单
        local frame= self:GetParent():GetParent()
        if not frame or not frame.mountSpell or not self.spellID or C_Spell.IsSpellPassive(self.spellID) then
            if self.mountSpell then
                self.mountSpell:SetShown(false)
            end
        else
            set_Use_Spell_Button(self, self.spellID)
        end
    end)
end














function WoWTools_MountMixin:Init_SpellFlyoutButton()
    Init()
end

function WoWTools_MountMixin:Init_UI_SpellBook_Menu()--法术书，选项
    hooksecurefunc(SpellBookItemMixin, 'UpdateVisuals', function(frame)
        set_Use_Spell_Button(frame.Button, frame.spellBookItemInfo.spellID)
    end)
end