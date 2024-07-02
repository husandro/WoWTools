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
C_Spell.IsSpellPassive= IsPassiveSpell

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
		name=name,
		description=description,
		reaction=standingID,
		currentReactionThreshold=barMin,
		nextReactionThreshold=barMax,
		currentStanding=barValue,
		atWarWith=atWarWith,
		canToggleAtWar=canToggleAtWar,
		isHeader=isHeader,
		isCollapsed=isCollapsed,
		hasRep=hasRep,
		isWatched=isWatched,
		isChild=isChild,
		factionID=factionID,
		hasBonusRepGain=hasBonusRepGain,
		canBeLFGBonus=canBeLFGBonus
	}
end
C_Reputation.GetFactionDataByID= function(faction)
	local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = GetFactionInfoByID(faction)
	return {
		name=name,
		description=description,
		reaction=standingID,
		currentReactionThreshold=barMin,
		nextReactionThreshold=barMax,
		currentStanding=barValue,
		atWarWith=atWarWith,
		canToggleAtWar=canToggleAtWar,
		isHeader=isHeader,
		isCollapsed=isCollapsed,
		hasRep=hasRep,
		isWatched=isWatched,
		isChild=isChild,
		factionID=factionID,
		hasBonusRepGain=hasBonusRepGain,
		canBeLFGBonus=canBeLFGBonus
	}
end

C_SpellBook.GetSpellBookItemLink= GetSpellLink




C_Spell.GetSpellTradeSkillLink= GetSpellTradeSkillLink
C_SpellBook.GetSpellBookItemTradeSkillLink= GetSpellTradeSkillLink

C_Spell.IsSpellPassive= IsPassiveSpell
C_SpellBook.IsSpellBookItemPassive=IsPassiveSpell

C_Spell.IsSpellHelpful= IsHelpfulSpell
C_SpellBook.IsSpellBookItemHelpful= IsHelpfulSpell
C_Spell.IsSpellHarmful= IsHarmfulSpell
C_SpellBook.IsSpellBookItemHarmful= IsHarmfulSpell

C_Spell.IsSpellUsable= IsUsableSpell
C_SpellBook.IsSpellBookItemUsable=IsUsableSpell
C_Spell.SpellHasRange= SpellHasRange
C_SpellBook.SpellBookItemHasRange=SpellHasRange
C_Spell.IsSpellInRange=IsSpellInRange
C_SpellBook.IsSpellBookItemInRange=IsSpellInRange

C_Spell.GetSpellLevelLearned=GetSpellLevelLearned
C_SpellBook.GetSpellBookItemLevelLearned=GetSpellLevelLearned

-- Both return new SpellCooldownInfo table (see SpellSharedDocumentation.lua)
C_Spell.GetSpellCooldown=GetSpellCooldown
C_SpellBook.GetSpellBookItemCooldown=GetSpellCooldown

C_Spell.GetSpellLossOfControlCooldown=GetSpellLossOfControlCooldown
C_SpellBook.GetSpellBookItemLossOfControlCooldown=GetSpellLossOfControlCooldown

-- Both return new SpellChargeInfo table (see SpellSharedDocumentation.lua)
C_Spell.GetSpellCharges=GetSpellCharges
C_SpellBook.GetSpellBookItemCharges=GetSpellCharges

C_Spell.GetSpellCastCount=GetSpellCount
C_SpellBook.GetSpellBookItemCastCount=GetSpellCount

-- Both return array of new SpellPowerCostInfo tables (see SpellSharedDocumentation.lua) which matches old return table structure
C_Spell.GetSpellPowerCost=GetSpellPowerCost
C_SpellBook.GetSpellBookItemPowerCost=GetSpellPowerCost

-- GetSpellAvailableLevel and GetSpellLevelLearned have been unified
C_Spell.GetSpellLevelLearned=GetSpellLevelLearned
C_SpellBook.GetSpellBookItemLevelLearned= GetSpellLevelLearned
C_Spell.GetSpellAutoCast= GetSpellAutocast
C_SpellBook.GetSpellBookItemAutoCast=GetSpellAutocast

C_Spell.ToggleSpellAutoCast=ToggleSpellAutocast
C_SpellBook.ToggleSpellBookItemAutoCast=ToggleSpellAutocast

-- Enable/Disable auto cast functions have been merged into single Set Enabled functions

C_Spell.PickupSpell=PickupSpell
C_SpellBook.PickupSpellBookIte=PickupSpellBookItem

C_SpellBook.GetNumSpellBookSkillLines=GetNumSpellTabs

-- Returns new SpellBookSkillLineInfo table
 C_SpellBook.GetSpellBookSkillLineInfo=GetSpellTabInfo

-- New C_SpellBook.GetSpellBookItemInfo contains far more info than old GetSpellBookItemInfo
-- C_SpellBook.GetSpellBookItemType is the direct replacement for just the type info that the old GetSpellBookItemInfo returned (+spellID as a new bonus 3rd return value)
C_SpellBook.GetSpellBookItemType=GetSpellBookItemInfo

C_SpellBook.GetSpellBookItemTexture= GetSpellBookItemTexture
C_SpellBook.GetSpellBookItemName=GetSpellBookItemName

C_Spell.DoesSpellExist=DoesSpellExist

C_SpellBook.HasPetSpells=HasPetSpells

C_Spell.GetSpellDescription=GetSpellDescription
C_Spell.GetSpellSubtext=GetSpellSubtext
C_Spell.GetSpellTexture=GetSpellTexture
C_Spell.GetSpellSkillLineAbilityRank=GetSpellRank

C_Spell.IsAutoAttackSpell=IsAttackSpell
C_SpellBook.IsAutoAttackSpellBookItem=IsAttackSpell
-- Ranged Auto Attack functions have also been added

C_Spell.IsAutoRepeatSpell=IsAutoRepeatSpell
C_Spell.IsCurrentSpell=IsCurrentSpell
C_Spell.IsPressHoldReleaseSpell=IsPressHoldReleaseSpell

C_Spell.IsClassTalentSpell=IsTalentSpell
C_Spell.IsClassTalentSpellBookItem=IsTalentSpell
C_Spell.IsPvPTalentSpell=IsPvpTalentSpell
C_Spell.IsPvPTalentSpellBookItem=IsPvpTalentSpell

GameTooltip.SetSpellBookItem=GameTooltip.SetSpellBookItem