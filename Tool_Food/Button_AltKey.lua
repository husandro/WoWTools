local e= select(2, ...)


local function Init(UseButton)
    if not UseButton:CanChangeAttribute() then
        return
    end

    local item, alt, ctrl, shift
    local tab= WoWTools_FoodMixin.Save.spells[e.Player.class]
    if tab then
        item, alt, ctrl, shift= tab.item, tab.alt, tab.ctrl, tab.shift
    end

    UseButton.itemID= item or 5512--治疗石

    UseButton:SetAttribute('alt-spell1', (alt and C_Spell.GetSpellName(alt) or alt or nil))
    UseButton.alt= alt


    UseButton:SetAttribute('ctrl-spell1', (ctrl and C_Spell.GetSpellName(ctrl) or ctrl) or nil)
    UseButton.ctrl= ctrl

    UseButton:SetAttribute('shift-type1', 'spell')
    UseButton:SetAttribute('shift-spell1', (shift and C_Spell.GetSpellName(shift) or shift) or nil)
    UseButton.shift= shift

end



function WoWTools_FoodMixin:Set_AltSpell()
    Init(self.UseButton)
end