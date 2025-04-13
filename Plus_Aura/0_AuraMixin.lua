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
    filter= filter or AuraUtil.AuraFilters.Helpful
    local data

    if UnitIsUnit(unit, 'player') then
        for spellID in pairs(spellTab) do
            data= C_UnitAuras.GetPlayerAuraBySpellID(spellID)
            if data then
                return data
            end
        end
    else
        for index = 1, 255 do
            data= C_UnitAuras.GetAuraDataByIndex(unit, index ,filter)
            if not data then
                return
            elseif spellTab[data.spellId] then
                return data, index
            end
        end
    end
end




--[[

ocal function foo(name, icon, _, _, _, _, _, _, _, spellId, ...)
	if spellId == 21562 then -- Power Word: Fortitude
		-- do stuff
		return true
	end
end
AuraUtil.ForEachAura("player", "HELPFUL", nil, function(...) print(...)end)

https://warcraft.wiki.gg/wiki/API_UnitAura
AuraUtil.ForEachAura("player", "CANCELABLE", nil, function(name, icon, ...)
    print(name, icon, ...)
end)

"HELPFUL"	Buffs
"HARMFUL"	Debuffs
"PLAYER"	Buffs/debuffs 由玩家应用, 如果使用以下过滤器，则需要“HELPFUL”或“HARMFUL” UnitAura / .GetAuraDataByIndex
"RAID"	HELPFUL: 根据玩家职业过滤的增益效果，例如对于牧师来说，它只会返回[真言术：韧]或[恢复]。
HARMFUL: 某些减益效果仅出现在团队框架上，例如与团队环境相关的大多数减益效果。

如果使用，则需要“HELPFUL”或“HARMFUL”过滤器 使用UnitAura / .GetAuraDataByIndex

这不需要你参加突袭
"CANCELABLE"	可以取消的增益效果 /cancelaura or CancelUnitBuff()
"NOT_CANCELABLE"	无法取消的增益效果
"INCLUDE_NAME_PLATE_ONLY"	应该在铭牌上显示的气场
"MAW"	托加斯特心能之力

WeakAuras AuraEnvironment.lua
]]