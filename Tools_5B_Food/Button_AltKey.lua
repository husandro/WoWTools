
local function Save()
    return WoWToolsSave['Tools_Foods']
end










local function Init(btn)
    if not btn or not btn:CanChangeAttribute() then
        return
    end

    local item, alt, ctrl, shift
    local tab= Save().spells[WoWTools_DataMixin.Player.Class]
    if tab then
        item, alt, ctrl, shift= tab.item, tab.alt, tab.ctrl, tab.shift
    end

    btn.itemID= item or 5512--治疗石

    btn:SetAttribute('alt-spell1', (alt and C_Spell.GetSpellName(alt) or alt or nil))
    btn.alt= alt


    btn:SetAttribute('ctrl-spell1', (ctrl and C_Spell.GetSpellName(ctrl) or ctrl) or nil)
    btn.ctrl= ctrl

    btn:SetAttribute('shift-type1', 'spell')
    btn:SetAttribute('shift-spell1', (shift and C_Spell.GetSpellName(shift) or shift) or nil)
    btn.shift= shift
end



function WoWTools_FoodMixin:Set_AltSpell()
    Init(self.Button)
end