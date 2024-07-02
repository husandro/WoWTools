
if not C_Reputation.GetNumFactions then--11版本
	C_Reputation.GetNumFactions= GetNumFactions
	C_Reputation.GetFactionDataByIndex= GetFactionInfo
    C_Spell.GetSpellInfo= GetSpellInfo
	C_Spell.IsSpellUsable= IsUsableSpell
	C_Spell.GetSpellName= GetSpellInfo
	C_Spell.GetSpellTexture= GetSpellTexture
	C_Spell.GetSpellLink= GetSpellLink
	C_Spell.GetSpellCooldown= function(spell)
		local start, duration, enabled, modRate=  GetSpellCooldown(spell)
		return{
			start=start,
			duration=duration,
			enabled=enabled,
			modRate=modRate
		}
	end
	
end

