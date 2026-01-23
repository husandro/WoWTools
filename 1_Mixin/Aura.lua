WoWTools_AuraMixin={}
--[[
AuraUtil.lua
AuraUtil.ShouldDisplayBuff(unitCaster, spellId, canApplyAura)
AuraUtil.ShouldDisplayDebuff(unitCaster, spellId)
 
C_UnitAuras.GetAuraDataBySpellName(unit, auraName, filter))

AuraUtil.FindAura(predicate, unit, filter, predicateArg1, predicateArg2, predicateArg3)

AuraUtil.AuraFilters = {
	Helpful = "HELPFUL",
	Harmful = "HARMFUL",
	Raid = "RAID",
	IncludeNameplateOnly = "INCLUDE_NAME_PLATE_ONLY",
	Player = "PLAYER",
	Cancelable = "CANCELABLE",
	NotCancelable = "NOT_CANCELABLE",
	Maw = "MAW",
}

AuraUtil.AuraFilters.Harmful
]]
function WoWTools_AuraMixin:Get(unit, spellTab, filter)--HELPFUL HARMFUL
    if not canaccessvalue(unit)
        or not WoWTools_UnitMixin:UnitGUID(unit)
        or not UnitExists(unit) then
        return
    end

    filter= filter or AuraUtil.AuraFilters.Helpful
    local data

    if WoWTools_UnitMixin:UnitIsUnit(unit, 'player') then
        for spellID in pairs(spellTab) do
            data= C_UnitAuras.GetPlayerAuraBySpellID(spellID)
            if data then
                return data
            end
        end
    else
        for index = 1, 255 do
            data= C_UnitAuras.GetAuraDataByIndex(unit, index ,filter)

            if not canaccessvalue(data) or  not data then
                return
            elseif spellTab[data.spellId] then
                return data, index
            end
        end
    end
end