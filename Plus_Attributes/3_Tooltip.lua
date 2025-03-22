---@diagnostic disable: param-type-mismatch
local e= select(2, ...)

local function Save()
    return WoWTools_AttributesMixin.Save
end


local Show_Tooltip={}









--set_STATUS_Tooltip
--主属性
Show_Tooltip.STATUS= function(frame, owner)
    local currentSpec= GetSpecialization() or 0
    local PrimaryStat= select(6, GetSpecializationInfo(currentSpec, nil, nil, nil, WoWTools_DataMixin.Player.Sex))

    local stat, effectiveStat, posBuff, negBuff = UnitStat('player', PrimaryStat)
    local effectiveStatDisplay = BreakUpLargeNumbers(effectiveStat or 0)
    local tooltipText = effectiveStatDisplay

    if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		GameTooltip:AddLine(tooltipText..effectiveStatDisplay..FONT_COLOR_CODE_CLOSE, frame.r, frame.g, frame.b,true)
	else
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText.." ("..BreakUpLargeNumbers(stat - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE
		end
		if ( posBuff > 0 ) then
			tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..BreakUpLargeNumbers(posBuff or 0)..FONT_COLOR_CODE_CLOSE
		end
		if ( negBuff < 0 ) then
			tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..BreakUpLargeNumbers(negBuff or 0)..FONT_COLOR_CODE_CLOSE
		end
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE
		end

        GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ', tooltipText, frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)
	end

    local role = GetSpecializationRole(currentSpec)
    if PrimaryStat==LE_UNIT_STAT_STRENGTH then-- Strength
        local text= ''
        local attackPower = GetAttackPowerForStat(PrimaryStat, effectiveStat or 0)
        if (HasAPEffectsSpellPower()) then
            text= (WoWTools_Mixin.onlyChinese and '提高你的攻击和技能强度' or STAT_TOOLTIP_BONUS_AP_SP)..' '..BreakUpLargeNumbers(attackPower)
        end
        if role == "TANK" then
            local increasedParryChance = GetParryChanceFromAttribute()
            if ( increasedParryChance > 0 ) then
                text = text~='' and text..'|n' or text
                text= text..format(WoWTools_Mixin.onlyChinese and '"招架几率提高%.2f%%|n|cff888888（在效果递减之前）|r"' or CR_PARRY_BASE_STAT_TOOLTIP, increasedParryChance)
            end
        end
        GameTooltip:AddLine(text, frame.r, frame.g, frame.b,true)

    elseif PrimaryStat==LE_UNIT_STAT_AGILITY then-- Agility
        local text=''
        if HasAPEffectsSpellPower() then
            text= WoWTools_Mixin.onlyChinese and '提高你的攻击和技能强度' or  STAT_TOOLTIP_BONUS_AP_SP
        else
            text= WoWTools_Mixin.onlyChinese and '提高你的攻击和技能强度' or STAT_TOOLTIP_BONUS_AP
        end

        if role == "TANK" then
            local increasedDodgeChance = GetDodgeChanceFromAttribute()
            if increasedDodgeChance > 0 then
                text= text .."|n"..format(WoWTools_Mixin.onlyChinese and '躲闪几率提高%.2f%%|n|cff888888（在效果递减之前）|r' or CR_DODGE_BASE_STAT_TOOLTIP, increasedDodgeChance)
            end
        end
        GameTooltip:AddLine(text, nil, nil, nil,true)

    elseif PrimaryStat==LE_UNIT_STAT_INTELLECT then
        local text
        if HasAPEffectsSpellPower() then
            text= WoWTools_Mixin.onlyChinese and "|cff808080该属性不能使你获益|r" or STAT_NO_BENEFIT_TOOLTIP
        elseif HasSPEffectsAttackPower() then
            text= WoWTools_Mixin.onlyChinese and '提高你的攻击和技能强度' or  STAT_TOOLTIP_BONUS_AP_SP
        else
            text= (WoWTools_Mixin.onlyChinese and '提高你的法术强度' or DEFAULT_STAT4_TOOLTIP).. effectiveStat
        end
        GameTooltip:AddLine(text, nil, nil, nil,true)
    end
    if frame.value and frame.value~=stat then
        GameTooltip:AddLine(' ')
        local text
        if frame.value< stat then
            text= Save().greenColor..'+ '..format('%s', WoWTools_Mixin:MK(stat- frame.value,3))
        else
            text= Save().redColor..'- '..format('%s', WoWTools_Mixin:MK(3, frame.value- stat))
        end
        GameTooltip:AddDoubleLine(format('%i', frame.value), text)
    end
end






--set_CRITCHANCE_Tooltip
--爆击2
Show_Tooltip.CRITCHANCE= function(frame)
    local spellCrit = WoWTools_AttributesMixin:Get_MinCrit()
	local rangedCrit = GetRangedCritChance()
	local meleeCrit = GetCritChance()
    local critChance, rating
	if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
		critChance = spellCrit
		rating = CR_CRIT_SPELL
	elseif (rangedCrit >= meleeCrit) then
		critChance = rangedCrit
		rating = CR_CRIT_RANGED
	else
		critChance = meleeCrit
		rating = CR_CRIT_MELEE
	end
    GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ', format('%.2f%%', critChance + 0.5), frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)

	local extraCritChance = GetCombatRatingBonus(rating)
	local extraCritRating = GetCombatRating(rating)
	if GetCritChanceProvidesParryEffect() then
        GameTooltip:AddLine(
            format(
                WoWTools_Mixin.onlyChinese and "攻击和法术造成额外效果的几率。|n|n爆击：%s [+%.2f%%]|n招架几率提高%.2f%%。" or CR_CRIT_PARRY_RATING_TOOLTIP,
                BreakUpLargeNumbers(extraCritRating),
                extraCritChance,
                GetCombatRatingBonusForCombatRatingValue(CR_PARRY, extraCritRating)
            ), nil, nil, nil ,true
        )
	else
        GameTooltip:AddLine(
            format(
                WoWTools_Mixin.onlyChinese and "攻击和法术造成额外效果的几率。|n|n爆击：%s [+%.2f%%]" or CR_CRIT_TOOLTIP,
                BreakUpLargeNumbers(extraCritRating),
                extraCritChance
            ), nil, nil, nil,true
        )
	end
end












--set_HASTE_Tooltip
--急速3
Show_Tooltip.HASTE= function(frame)
    local haste = GetHaste()
	local rating = CR_HASTE_MELEE

	local hasteFormatString
	if (haste < 0 and not GetPVPGearStatRules()) then
		hasteFormatString = RED_FONT_COLOR_CODE.."%s"..FONT_COLOR_CODE_CLOSE
	else
		hasteFormatString = "%s"
	end
	GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ', format(hasteFormatString, format("%0.2f%%", haste + 0.5)), frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)
	GameTooltip:AddLine(
        WoWTools_TextMixin:CN(_G["STAT_HASTE_"..WoWTools_DataMixin.Player.Class.."_TOOLTIP"])
        or (WoWTools_Mixin.onlyChinese and '提高攻击速度和施法速度。' or STAT_HASTE_TOOLTIP),
        nil, nil, nil, true
    )
    GameTooltip:AddLine(' ')
	GameTooltip:AddDoubleLine(
        format(
            WoWTools_Mixin.onlyChinese and '急速：%s [+%.2f%%]' or STAT_HASTE_BASE_TOOLTIP,
            BreakUpLargeNumbers(GetCombatRating(rating)),
            GetCombatRatingBonus(rating))
        )
end





--set_VERSATILITY_Tooltip
--全能5
Show_Tooltip.VERSATILITY= function(frame)
    local versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE)
	local versatilityDamageBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
	local versatilityDamageTakenReduction = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN)
    GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ', format('%.2f%%',  versatilityDamageBonus), frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)
    GameTooltip:AddLine(' ')
	GameTooltip:AddLine(
        format(
            WoWTools_Mixin.onlyChinese and "造成的"..INLINE_DAMAGER_ICON.."伤害值和"..INLINE_HEALER_ICON.."治疗量提高%.2f%%，|n"..INLINE_TANK_ICON.."受到的伤害降低%.2f%%。|n|n全能：%s [%.2f%%/%.2f%%]"
            or CR_VERSATILITY_TOOLTIP,
            versatilityDamageBonus,
            versatilityDamageTakenReduction,
            BreakUpLargeNumbers(versatility),
            versatilityDamageBonus,
            versatilityDamageTakenReduction,
            nil, nil, nil, true
        )
    )
end







--set_LIFESTEAL_Tooltip
--吸血6
Show_Tooltip.LIFESTEAL= function(frame)
    local lifesteal = GetLifesteal()
	GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ', format("%0.2f%%", lifesteal), frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)
    GameTooltip:AddLine(
        format(
            WoWTools_Mixin.onlyChinese and '你所造成伤害和治疗的一部分将转而治疗你。|n|n吸血：%s [+%.2f%%]'
            or CR_LIFESTEAL_TOOLTIP,
            BreakUpLargeNumbers(GetCombatRating(CR_LIFESTEAL)),
            GetCombatRatingBonus(CR_LIFESTEAL)),
            nil, nil, nil, true
        )
end






--护甲
--set_ARMOR_Tooltip
Show_Tooltip.ARMOR= function(frame)
    local _, effectiveArmor = UnitArmor('player')
    GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ', BreakUpLargeNumbers(effectiveArmor), frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)

    local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitEffectiveLevel('player'))
	local armorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(effectiveArmor)

    GameTooltip:AddLine(
        format(
            WoWTools_Mixin.onlyChinese and '物理伤害减免：%0.2f%%|n|cff888888（对抗与你实力相当的敌人时）|r'
            or STAT_ARMOR_TOOLTIP,
            armorReduction
        ), nil, nil, nil, true
    )

	if (armorReductionAgainstTarget) then
		GameTooltip:AddLine(
            format(
                WoWTools_Mixin.onlyChinese and '（对当前目标：%0.2f%%）'
                or STAT_ARMOR_TARGET_TOOLTIP, armorReductionAgainstTarget
            ),
            nil, nil, nil, true
        )
	end
end






--set_AVOIDANCE_Tooltip
--闪避7
Show_Tooltip.AVOIDANCE= function(frame)
    local Avoidance = GetAvoidance()
	GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ',  format("%0.2f%%", Avoidance), frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)
    GameTooltip:AddLine(
        format(
            WoWTools_Mixin.onlyChinese and '范围效果法术的伤害降低。|n|n闪避：%s [+%.2f%%'
            or CR_AVOIDANCE_TOOLTIP,
            BreakUpLargeNumbers(GetCombatRating(CR_AVOIDANCE)),
            GetCombatRatingBonus(CR_AVOIDANCE)
        ),
        nil, nil, nil, true
    )
end








--set_DODGE_Tooltip
--躲闪8
Show_Tooltip.DODGE= function(frame)
    local chance = GetDodgeChance()
	GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ',  format("%0.2f%%", chance), frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)
    GameTooltip:AddLine(
        format(
            WoWTools_Mixin.onlyChinese and '%d点躲闪可使躲闪几率提高%.2f%%|n|cff888888（在效果递减之前）|r' or CR_DODGE_TOOLTIP, GetCombatRating(CR_DODGE), GetCombatRatingBonus(CR_DODGE)
        ),
        nil, nil, nil, true
    )
end










--set_PARRY_Tooltip
--招架9
Show_Tooltip.PARRY= function(frame)
    local chance = GetParryChance()
	GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ',  format("%0.2f%%", chance), frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)
    GameTooltip:AddLine(
        format(
            WoWTools_Mixin.onlyChinese and '%d点招架可使招架几率提高%.2f%%|n|cff888888（在效果递减之前）|r'
            or CR_PARRY_TOOLTIP,
            GetCombatRating(CR_PARRY),
            GetCombatRatingBonus(CR_PARRY)
        ),
        nil, nil, nil, true
    )
end










--set_BLOCK_Tooltip
--格挡10
Show_Tooltip.BLOCK= function(frame)
    local chance = GetBlockChance()
    GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ', format("%0.2f%%", chance), frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)

	local shieldBlockArmor = GetShieldBlock()
	local blockArmorReduction = PaperDollFrame_GetArmorReduction(shieldBlockArmor, UnitEffectiveLevel('player'))
	local blockArmorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(shieldBlockArmor)

	GameTooltip:AddLine(format(WoWTools_Mixin.onlyChinese and '格挡可使一次攻击的伤害降低%0.2f%%.|n|cff888888（对抗与你实力相当的敌人时）|r' or CR_BLOCK_TOOLTIP, blockArmorReduction), frame.r, frame.g, frame.b,true)
	if (blockArmorReductionAgainstTarget) then
		GameTooltip:AddLine(
            format(
                WoWTools_Mixin.onlyChinese and '（对当前目标：%0.2f%%）'
                or STAT_BLOCK_TARGET_TOOLTIP,
                blockArmorReductionAgainstTarget
            ),
            nil, nil, nil,true
        )
	end
end











--set_STAGGER_Tooltip
--醉拳11
Show_Tooltip.STAGGER= function(frame)
    local stagger, staggerAgainstTarget = C_PaperDollInfo.GetStaggerPercentage('player')
    if not stagger then
        return
    end
    GameTooltip:ClearLines()
    GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ', format("%0.2f%%", stagger), frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)
	GameTooltip:AddLine(format(WoWTools_Mixin.onlyChinese and '你的醉拳可化解%0.2f%%的伤害' or STAT_STAGGER_TOOLTIP, stagger), frame.r, frame.g, frame.b,true)
	if (staggerAgainstTarget) then
		GameTooltip:AddLine(
            format(
                WoWTools_Mixin.onlyChinese and '（对当前目标比例%0.2f%%）'
                or STAT_STAGGER_TARGET_TOOLTIP, staggerAgainstTarget
            ),
            nil, nil, nil, true
        )
	end
end








--set_SPEED_Tooltip
--移动12
Show_Tooltip.SPEED= function(frame)
    local currentSpeed, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed('player')
    GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ', 'player', frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)
    GameTooltip:AddLine(
        format(
            WoWTools_Mixin.onlyChinese and '提升移动速度。|n|n速度：%s [+%.2f%%]'
            or CR_SPEED_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_SPEED)),
            GetCombatRatingBonus(CR_SPEED)
        ),
        nil, nil, nil, true
    )
    GameTooltip:AddLine(' ')
    GameTooltip:AddDoubleLine(
    (WoWTools_Mixin.onlyChinese and '地面' or MOUNT_JOURNAL_FILTER_GROUND)..format(' %.0f%%', runSpeed*100/BASE_MOVEMENT_SPEED), format('%.2f', runSpeed))
    GameTooltip:AddDoubleLine((WoWTools_Mixin.onlyChinese and '水栖' or MOUNT_JOURNAL_FILTER_AQUATIC )..format(' %.0f%%', swimSpeed*100/BASE_MOVEMENT_SPEED), format('%.2f', swimSpeed))
    GameTooltip:AddDoubleLine((WoWTools_Mixin.onlyChinese and '飞行' or MOUNT_JOURNAL_FILTER_FLYING )..format(' %.0f%%', flightSpeed*100/BASE_MOVEMENT_SPEED), format('%.2f', flightSpeed))
    GameTooltip:AddDoubleLine((WoWTools_Mixin.onlyChinese and '驭空术' or LANDING_DRAGONRIDING_PANEL_TITLE)..format(' %.0f%%', 100*100/BASE_MOVEMENT_SPEED), '100')
    if UnitExists('vehicle') then
        currentSpeed = GetUnitSpeed('vehicle')
        GameTooltip:AddDoubleLine((WoWTools_Mixin.onlyChinese and '载具' or 'Vehicle')..format(' %.0f%%', currentSpeed*100/BASE_MOVEMENT_SPEED), format('%.2f', currentSpeed))
    end
end














function WoWTools_AttributesMixin:Set_Tooltips(frame, owner)
    if Show_Tooltip[frame.name] then
        GameTooltip:SetOwner(owner or frame, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        Show_Tooltip[frame.name](frame)
        GameTooltip:Show()
    end
end