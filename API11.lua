if C_Reputation.GetNumFactions then--11版本
	return
end



C_Reputation.GetNumFactions= GetNumFactions

C_Spell.GetSpellInfo= GetSpellInfo
C_Spell.IsSpellUsable= IsUsableSpell
C_Spell.GetSpellName= GetSpellInfo
C_Spell.GetSpellTexture= GetSpellTexture
C_Spell.GetSpellLink= GetSpellLink
C_Spell.GetSpellDescription= GetSpellDescription
C_Spell.GetSpellCooldown= function(spell)
	local start, duration, enabled, modRate=  GetSpellCooldown(spell)
	return{
		start=start,
		duration=duration,
		enabled=enabled,
		modRate=modRate
	}
end
C_Spell.GetSpellCharges= function(spell)
	local urrentCharges, maxCharges, cooldownStart, cooldownDuration, chargeModRate= GetSpellCharges(spell)
	return {
		urrentCharges= urrentCharges,
		maxCharges= maxCharges,
		cooldownStart= cooldownStart,
		cooldownDuration= cooldownDuration,
		chargeModRate= chargeModRate,
	}
end


C_Reputation.GetFactionDataByIndex= function(index)
	local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = GetFactionInfo(index)
	return {
		name=name, description=description, standingID=standingID, barMin=barMin, barMax=barMax, barValue=barValue, atWarWith=atWarWith, canToggleAtWar=canToggleAtWar, isHeader=isHeader, isCollapsed=isCollapsed, hasRep=hasRep, isWatched=isWatched, isChild=isChild, factionID=factionID, hasBonusRepGain=hasBonusRepGain, canBeLFGBonus=canBeLFGBonus
	}
end
C_Reputation.GetFactionDataByID= function(faction)
	local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = GetFactionInfoByID(faction)
	return {
		name=name, description=description, standingID=standingID, barMin=barMin, barMax=barMax, barValue=barValue, atWarWith=atWarWith, canToggleAtWar=canToggleAtWar, isHeader=isHeader, isCollapsed=isCollapsed, hasRep=hasRep, isWatched=isWatched, isChild=isChild, factionID=factionID, hasBonusRepGain=hasBonusRepGain, canBeLFGBonus=canBeLFGBonus
	}
end