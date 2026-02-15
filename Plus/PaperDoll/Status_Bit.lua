local function Save()
    return WoWToolsSave['Plus_PaperDoll']
end








 --自定，数据
local function status_set_rating(frame, rating)
    local num= GetCombatRating(rating) or 0
    if num == 0 then
        frame.numLabel:SetText('')
    else
        local extraChance = GetCombatRatingBonus(rating) or 0
        local extra=''
        if extraChance>0 then
            extra= format('|cnGREEN_FONT_COLOR:+%i%%|r', extraChance)
        elseif extraChance<0 then
            extra= format('|cnWARNING_FONT_COLOR:%i%%|r', extraChance)
        end
        frame.numLabel:SetFormattedText('%s%s', BreakUpLargeNumbers(num), extra)
    end
end

local function create_status_label(frame, rating)
    local bit= Save().itemLevelBit or -1

    if bit>=0 and frame:IsShown() then
        if not frame.numLabel then
            frame.numLabel=WoWTools_LabelMixin:Create(frame, {color={r=1,g=1,b=1}})
            frame.numLabel:SetPoint('LEFT', frame.Label, 'RIGHT',2,0)
        end
        if rating then
            status_set_rating(frame, rating)
        end
        return true

    elseif frame.numLabel then
        frame.numLabel:SetText("")
    end
end


















-- General
local function Init_General()
    WoWTools_DataMixin:Hook('PaperDollFrame_SetHealth', function(frame)--生命
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetPower', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetAlternateMana', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)
    function MovementSpeed_OnUpdate(statFrame)--原生，替换，增强 PaperDollFrame_SetMovementSpeed
        local unit = statFrame.unit
        local _, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed(unit)
        local isGliding, _, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
        if isGliding and forwardSpeed then
            flightSpeed= forwardSpeed/BASE_MOVEMENT_SPEED*100
        else
            flightSpeed = flightSpeed/BASE_MOVEMENT_SPEED*100
        end
        runSpeed = runSpeed/BASE_MOVEMENT_SPEED*100
        swimSpeed = swimSpeed/BASE_MOVEMENT_SPEED*100
        if (unit == "pet") then
            swimSpeed = runSpeed
        end
        local speed = runSpeed
        local swimming = IsSwimming(unit)
        if (swimming) then
            speed = swimSpeed
        elseif (IsFlying(unit)) then
            speed = flightSpeed
        end
        if (IsFalling(unit)) then
            if (statFrame.wasSwimming) then
                speed = swimSpeed
            end
        else
            statFrame.wasSwimming = swimming
        end
        local valueText = format("%i%%", speed)
        PaperDollFrame_SetLabelAndText(statFrame, WoWTools_DataMixin.onlyChinese and '移动' or (NPE_MOVE), valueText, false, speed)
        statFrame.speed = speed
        statFrame.runSpeed = runSpeed
        statFrame.flightSpeed = flightSpeed
        statFrame.swimSpeed = swimSpeed
        create_status_label(statFrame, CR_SPEED or 14)
    end
    function MovementSpeed_OnEnter(statFrame)
        GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT")
        GameTooltip_SetTitle(GameTooltip,
            format(PAPERDOLLFRAME_TOOLTIP_FORMAT, WoWTools_DataMixin.onlyChinese and '移动速度' or STAT_MOVEMENT_SPEED).." "..format("%d%%", statFrame.speed+0.5)
        )
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(format(WoWTools_DataMixin.onlyChinese and '奔跑速度：%d%%' or STAT_MOVEMENT_GROUND_TOOLTIP, statFrame.runSpeed+0.5))
        GameTooltip:AddLine(format(WoWTools_DataMixin.onlyChinese and '游泳速度：%d%%' or STAT_MOVEMENT_SWIM_TOOLTIP, statFrame.swimSpeed+0.5))
        if (statFrame.unit ~= "pet") then
            GameTooltip:AddLine(format(WoWTools_DataMixin.onlyChinese and '飞行速度：%d%%' or STAT_MOVEMENT_FLIGHT_TOOLTIP, statFrame.flightSpeed+0.5))
            GameTooltip:AddLine(format('%s: %i%%', WoWTools_DataMixin.onlyChinese and '驭空术' or LANDING_DRAGONRIDING_PANEL_TITLE, 100*100/BASE_MOVEMENT_SPEED))
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(format(WoWTools_DataMixin.onlyChinese and '提升移动速度。|n|n速度：%s [+%.2f%%]' or CR_SPEED_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_SPEED or 14)), GetCombatRatingBonus(CR_SPEED or 14)))
        GameTooltip:Show()
        statFrame.UpdateTooltip = MovementSpeed_OnEnter
    end

end















--Base stats
local function Init_Base_Stats(frame, unit, statIndex)--主属性
    if create_status_label(frame) then
        local tooltipText
        local _, _, posBuff, negBuff = UnitStat(unit, statIndex)
        if posBuff ~= 0 or negBuff ~= 0 then
            if ( posBuff > 0 ) then
                tooltipText = GREEN_FONT_COLOR_CODE.."+"..BreakUpLargeNumbers(posBuff)..FONT_COLOR_CODE_CLOSE
            end
            if ( negBuff < 0 ) then
                tooltipText = (tooltipText or '')..WARNING_FONT_COLOR_CODE.." -"..BreakUpLargeNumbers(negBuff)..FONT_COLOR_CODE_CLOSE
            end
        end
        frame.numLabel:SetText(tooltipText or '')
    end
end







--Enhancement
local function Init_Enhancements()
    WoWTools_DataMixin:Hook('PaperDollFrame_SetCritChance', function(frame)--爆击
        if create_status_label(frame) then
            local rating, spellCrit, rangedCrit, meleeCrit
            local holySchool = 2
            local minCrit = GetSpellCritChance(holySchool)
            for i=(holySchool+1), MAX_SPELL_SCHOOLS do
                spellCrit = GetSpellCritChance(i)
                minCrit = min(minCrit, spellCrit)
            end
            spellCrit = minCrit
            rangedCrit = GetRangedCritChance()
            meleeCrit = GetCritChance()
            if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
                rating = CR_CRIT_SPELL
            elseif (rangedCrit >= meleeCrit) then
                rating = CR_CRIT_RANGED
            else
                rating = CR_CRIT_MELEE
            end
            status_set_rating(frame, rating)
        end
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetHaste', function(frame)--急速
        create_status_label(frame, CR_HASTE_MELEE)
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetMastery', function(frame)--精通
        create_status_label(frame, CR_MASTERY)
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetVersatility', function(frame)--全能
        if create_status_label(frame) then
            local text
            local versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE) or 0
            if versatility>1 then
                text= BreakUpLargeNumbers(versatility)
                local versatilityDamageTakenReduction= GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN)
                if versatilityDamageTakenReduction>1 then
                    text= format('%s/|cffc69b6d%i%%|r', text, versatilityDamageTakenReduction)
                end
            end
            frame.numLabel:SetText(text or '')
        end
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetLifesteal', function(frame)--吸
        create_status_label(frame, CR_LIFESTEAL)
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetAvoidance', function(frame)--闪避
        create_status_label(frame, CR_AVOIDANCE)
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetSpeed', function(frame)--速度
        create_status_label(frame, CR_SPEED)
    end)
end















local function Init_Attack()
    WoWTools_DataMixin:Hook('PaperDollFrame_SetDamage', function(frame)--伤害
        if create_status_label(frame) then
            frame.numLabel:SetText(frame.damage and frame.damage:match('(|c.-|r)') or '')
        end
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetAttackPower', function(frame)--功击强度
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)

    WoWTools_DataMixin:Hook('PaperDollFrame_SetEnergyRegen', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetRuneRegen', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetFocusRegen', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)
end










-- Spell
local function Init_Spell()
    WoWTools_DataMixin:Hook('PaperDollFrame_SetSpellPower', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetManaRegen', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)
end










local function Init_Defense()
    WoWTools_DataMixin:Hook('PaperDollFrame_SetArmor', function(frame, unit)--护甲
        if create_status_label(frame) then
            local effectiveArmor = select(2, UnitArmor(unit))
            local text
            local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitEffectiveLevel(unit)) or 0
            if armorReduction>1 then
                text = format('%i%%', armorReduction)
                local armorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(effectiveArmor)
                if armorReductionAgainstTarget and armorReduction~=armorReductionAgainstTarget and armorReductionAgainstTarget>1 then
                    text = format('%s/%i%%', text, armorReductionAgainstTarget)
                end
            end
            frame.numLabel:SetText(text or '')
        end
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetDodge', function(frame)--躲闪
        create_status_label(frame, CR_DODGE)
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetParry', function(frame)--招架
        create_status_label(frame, CR_PARRY)
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetBlock', function(frame, unit)--格挡
        if create_status_label(frame) then--, CR_BLOCK)
            local text
            local shieldBlockArmor = GetShieldBlock()
            local blockArmorReduction = PaperDollFrame_GetArmorReduction(shieldBlockArmor, UnitEffectiveLevel(unit)) or 0
            if blockArmorReduction>1 then
                local blockArmorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(shieldBlockArmor)
                text= format('%i%%', blockArmorReduction)
                if blockArmorReductionAgainstTarget and blockArmorReduction~= blockArmorReductionAgainstTarget and blockArmorReductionAgainstTarget>1 then
                    text=format('%s/%i%%', text, blockArmorReductionAgainstTarget)
                end
            end
            frame.numLabel:SetText(text or '')
        end
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetResilience', function(frame)--韧性
        create_status_label(frame, COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN)
    end)

    WoWTools_DataMixin:Hook('PaperDollFrame_SetLabelAndText', function(statFrame, _, text, isPercentage, numericValue)
        local bit= Save().itemLevelBit or -1
        if bit>=0 and (isPercentage or (type(text)=='string' and text:find('%%'))) then
            statFrame.Value:SetFormattedText('%.0'..bit..'f%%', numericValue)
        end
    end)
end


















    --[[功击速度，放在前前，原生出错
    function PaperDollFrame_SetAttackSpeed(statFrame, unit)
        local meleeHaste = GetMeleeHaste()
        local speed, offhandSpeed = UnitAttackSpeed(unit)
        local displaySpeed
        speed= speed or 0
        if offhandSpeed  then
            displaySpeed = format("%.2f/%.2f", speed, offhandSpeed)
        else
            displaySpeed = format("%.2f", speed)
        end
        PaperDollFrame_SetLabelAndText(statFrame, WoWTools_DataMixin.onlyChinese and '攻击速度' or WEAPON_SPEED, displaySpeed, false, speed)
        statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, WoWTools_DataMixin.onlyChinese and '攻击速度' or ATTACK_SPEED).." "..displaySpeed..FONT_COLOR_CODE_CLOSE
        statFrame.tooltip2 = format(WoWTools_DataMixin.onlyChinese and '攻击速度+%s%%' or STAT_ATTACK_SPEED_BASE_TOOLTIP, BreakUpLargeNumbers(meleeHaste))
        statFrame:Show()
        if statFrame.numLabel then
            statFrame.numLabel:SetText('')
        end
    end]]


local function Init()
    if Save().notStatusPlusFunc then
        return
    end

    WoWTools_DataMixin:Hook('PaperDollFrame_SetItemLevel', function(statFrame)--物品等级，小数点
        local bit= Save().itemLevelBit or -1
        if statFrame:IsShown() and bit>=0 then
            local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvP = GetAverageItemLevel()
	        local minItemLevel = C_PaperDollInfo.GetMinItemLevel()
	        local displayItemLevel = math.max(minItemLevel or 0, avgItemLevelEquipped)
            local pvp=''
            if ( avgItemLevel ~= avgItemLevelPvP ) then
                pvp= format('/|cffff7f00%i|r', avgItemLevelPvP)
            end
            if statFrame.numericValue ~= displayItemLevel then
                statFrame.Value:SetFormattedText('%.0'..bit..'f%s', displayItemLevel, pvp)
            end
        end
    end)
    CharacterStatsPane.ItemLevelFrame.Value:EnableMouse(true)
    function CharacterStatsPane.ItemLevelFrame.Value:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        local bit= Save().itemLevelBit or -1
        GameTooltip_SetTitle(GameTooltip,
            WoWTools_PaperDollMixin.addName..WoWTools_DataMixin.Icon.icon2
        )
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            (WoWTools_DataMixin.onlyChinese and '小数 ' or 'Decimals ')
            ..(
                bit==-1 and '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE)..'|r'
                or ('|cnGREEN_FONT_COLOR:'..bit)
            ),

            '-1'..WoWTools_DataMixin.Icon.left
            ..WoWTools_DataMixin.Icon.right..'+1'
        )
        GameTooltip:Show()
    end
    CharacterStatsPane.ItemLevelFrame.Value:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        GameTooltip_Hide()
    end)
    CharacterStatsPane.ItemLevelFrame.Value:SetScript('OnEnter', function(self)
        self:set_tooltips()
        self:SetAlpha(0.7)
    end)
    CharacterStatsPane.ItemLevelFrame.Value:SetScript('OnMouseUp', function(self)
        self:SetAlpha(0.7)
    end)
    CharacterStatsPane.ItemLevelFrame.Value:SetScript('OnMouseDown', function(self, d)
        local n= (Save().itemLevelBit or -1)+ (d=='LeftButton' and -1 or 1)
        n= math.max(-1, n)
        n= math.min(4, n)
        Save().itemLevelBit=n
        WoWTools_DataMixin:Call('PaperDollFrame_UpdateStats')
        self:set_tooltips()
        self:SetAlpha(0.3)
    end)



    Init_General()


--Base stats
    WoWTools_DataMixin:Hook('PaperDollFrame_SetStat', Init_Base_Stats)

--Enhancements
    Init_Enhancements()


-- Attack
    Init_Attack()


-- Spell
    Init_Spell()

-- Defense
    Init_Defense()

    Init=function()end
end















function WoWTools_PaperDollMixin:Init_Status_Bit()
    Init()
end