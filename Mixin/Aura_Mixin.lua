WoWTools_AuraMixin={}




local function UnitAura(unit, i, filter)
    local data= C_UnitAuras.GetAuraDataByIndex(unit, i ,filter)
    if data then
        return AuraUtil.UnpackAuraData(data)
    end
end


--WeakAuras AuraEnvironment.lua
function WoWTools_AuraMixin:Get(unit, spell, filter, spellTab)--HELPFUL HARMFUL
    spellTab= spellTab or {}
    filter = filter and filter.."|HELPFUL" or "HELPFUL"
    for i = 1, 255 do
        local spellID= select(10, UnitAura(unit, i, filter))
        if not spellID then
            return
        elseif spellTab[spellID] or spell== spellID then
            return UnitAura(unit, i, filter)
        end
    end
end


function WoWTools_AuraMixin:Debuff(unit, spell, filter, spellTab)
    filter = filter and filter.."|HARMFUL" or "HARMFUL"
    spellTab= spellTab or {}
    for i = 1, 255 do
        local spellID= select(10, UnitAura(unit, i, filter))
        if not spellID then
            return
        elseif spellTab[spellID] or spell== spellID then
            return UnitAura(unit, i, filter)
        end
    end
end