local e= select(2, ...)









local function set_Use_Spell_Button(btn, spellID)
    if not btn.useSpell then
        btn.useSpell= WoWTools_ButtonMixin:Cbtn(btn, {size={16,16}, atlas='soulbinds_tree_conduit_icon_utility'})
        btn.useSpell:SetPoint('TOP', btn, 'BOTTOM', 8,0)
        function btn.useSpell:set_alpha()
            if self.spellID then
                self:SetAlpha(WoWTools_UseItemsMixin:Find_Type('spell', self.spellID) and 1 or 0.2)
            end
        end
        function btn.useSpell:set_tooltips()
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(WoWTools_ToolsButtonMixin:GetName(), WoWTools_UseItemsMixin.addName)
            e.tips:AddLine(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            e.tips:AddLine(' ')
            if self.spellID then
                e.tips:AddDoubleLine(
                    '|T'..(C_Spell.GetSpellTexture(self.spellID) or 0)..':0|t'
                    ..(C_Spell.GetSpellLink(self.spellID) or self.spellID)
                    ..' '..e.GetEnabeleDisable(WoWTools_UseItemsMixin:Find_Type('spell', self.spellID)),

                    e.Icon.left
                )
            end
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
            e.tips:Show()
            self:SetAlpha(1)
        end
        btn.useSpell:SetScript('OnLeave', function(self) e.tips:Hide() self:set_alpha()  end)
        btn.useSpell:SetScript('OnEnter', btn.useSpell.set_tooltips)
        btn.useSpell:SetScript('OnMouseDown', function(self, d)
            if d=='LeftButton' then
                if self.spellID then
                    local findIndex= WoWTools_UseItemsMixin:Find_Type('spell', self.spellID)
                    if findIndex then
                        table.remove(WoWTools_UseItemsMixin.Save.spell, findIndex)
                    else
                        table.insert(WoWTools_UseItemsMixin.Save.spell, self.spellID)
                    end
                    self:set_tooltips()
                    self:set_alpha()
                    print(e.addName, WoWTools_UseItemsMixin.addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD, C_Spell.GetSpellLink(self.spellID))
                end
            else
                --e.LibDD:ToggleDropDownMenu(1, nil, button.Menu, self, 15, 0)
                --MenuUtil.CreateContextMenu(self, Init_Menu)
                WoWTools_UseItemsMixin:Init_Menu(self)
            end
        end)
    end

    btn.useSpell.spellID= spellID
    btn.useSpell:set_alpha()
    btn.useSpell:SetShown(spellID and true or false)
end














local function Init_SpellFlyoutButton_UpdateGlyphState(self)
    local frame= self:GetParent():GetParent()
    if not frame or not frame.useSpell or not self.spellID or C_Spell.IsSpellPassive(self.spellID) then
        if self.useSpell then
            self.useSpell:SetShown(false)
        end
    else
        set_Use_Spell_Button(self, self.spellID)
    end
end
















function WoWTools_ToolsButtonMixin:Init_SpellFlyoutButton()--法术书，界面, Flyout, 菜单
    hooksecurefunc('SpellFlyoutButton_UpdateGlyphState', Init_SpellFlyoutButton_UpdateGlyphState)--法术书，界面, Flyout, 菜单
end




function WoWTools_ToolsButtonMixin:Init_PlayerSpells()
    hooksecurefunc(SpellBookItemMixin, 'UpdateVisuals', function(frame)
        set_Use_Spell_Button(frame.Button, frame.spellBookItemInfo.spellID)
    end)
end