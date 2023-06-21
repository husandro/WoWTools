local id, e= ...
local addName= STAT_CATEGORY_ATTRIBUTES--PaperDollFrame.lua
local panel= CreateFrame('Frame')
local button, Role, PrimaryStat, Tabs
local Save={
    redColor= '|cffff0000',
    greenColor='|cff00ff00',
    font={r=0, g=0, b=0, a=1, x=1, y=-1},--阴影
    tab={
        ['STATUS']={bit=2},
        ['CRITCHANCE']= {r=0.99, g=0.35, b=0.31},
        ['HASTE']= {r=0, g=1, b=0.77},
        ['MASTERY']= {r=0.82, g=0.28, b=0.82},
        ['VERSATILITY']= {r=0, g=0.77, b=1},--双属性, damageAndDefense=true, onlyDefense=true,仅防卫
        ['LIFESTEAL']= {r=1, g=0.33, b=0.5},
        ['AVOIDANCE']= {r=0.90, g=0.80, b=0.60},--'闪避'

        ['ARMOR']={r=0.71, g=0.55, b=0.22, a=1},--护甲
        ["DODGE"]= {r=1, g=0.51, b=1},--躲闪
        ["PARRY"]= {r=0.59, g=0.85, b=1},
        ["BLOCK"]= {r=0.75, g=0.53, b=0.78},
        ["STAGGER"]= {r=0.38, g=1, b=0.62},

        ["SPEED"]= {r=1, g=0.82, b=0, current=true},--移动
    },
    --toLeft=true--数值,
    bar= true,--进度条
    barTexture2=true,--样式2
    barWidth= -60,--bar, 宽度
    barX=22,--bar,移位
    --barToLeft=e.Player.husandro,--bar,放左边
    scale= 1.1,--缩放
    vertical=3,--上下，间隔
    horizontal=9,--左右， 间隔
    setMaxMinValue= true,--增加,减少值
    bitPrecet=0,--百分比，位数
    onlyDPS=true,--四属性, 仅限DPS
    --useNumber= e.Player.husandro,--使用数字
    --notText=false,--禁用，数值
    textColor= {r=1,g=1,b=1,a=1},--数值，颜色
    bit=0,--数值，位数
}
    --hideInPetBattle=true,--宠物战斗中, 隐藏
    --buttonAlpha=0.3,--专精，图标，透明度
    --hide=false,--显示，隐藏
    --gsubText
    --strlower
    --strupper


local function get_PrimaryStat()--取得主属
    local spec= GetSpecialization()
    Role= GetSpecializationRole(spec)--DAMAGER, TANK, HEALER
    local icon, _
    icon, _, PrimaryStat= select(4, GetSpecializationInfo(spec, nil, nil, nil, e.Player.sex))
    SetPortraitToTexture(button.texture, icon or 0)
end

local function set_Tabs()
    get_PrimaryStat()--取得主属
    Tabs={
        {name='STATUS', r=e.Player.r, g=e.Player.g, b=e.Player.b, a=1, useNumber=true, textValue=true},

        {name= 'CRITCHANCE', text= e.onlyChinese and '爆击' or STAT_CRITICAL_STRIKE, bar=true, dps=true, textValue=true},
        {name= 'HASTE', text= e.onlyChinese and '急速' or STAT_HASTE, bar=true, dps=true, textValue=true},
        {name= 'MASTERY', text= e.onlyChinese and '精通' or STAT_MASTERY, bar=true, dps=true, textValue=true},
        {name= 'VERSATILITY', text= e.onlyChinese and '全能' or STAT_VERSATILITY, bar=true, dps=true, textValue=true},--5

        {name= 'LIFESTEAL', text= e.onlyChinese and '吸血' or STAT_LIFESTEAL, bar=true, textValue=true},--6
        {name= 'AVOIDANCE', text= e.onlyChinese and '闪避' or STAT_AVOIDANCE, bar=true, textValue=true},--7

        {name= 'ARMOR', text= e.onlyChinese and '护甲' or STAT_ARMOR, bar=true, tank=true, textValue=true},
        {name= 'DODGE', text= e.onlyChinese and '躲闪' or STAT_DODGE, bar=true, tank=true, textValue=true},--9
        {name= 'PARRY', text= e.onlyChinese and '招架' or STAT_PARRY, bar=true, tank=true, textValue=true},--10
        {name= 'BLOCK', text= e.onlyChinese and '格挡' or STAT_BLOCK, bar=true, tank=true, textValue=true},--11
        {name= 'STAGGER', text= e.onlyChinese and '醉拳' or STAT_STAGGER, bar=true, tank=true, usePercent=true, textValue=true},--12

        {name= 'SPEED', text= e.onlyChinese and '移动' or NPE_MOVE},--13
    }

    if PrimaryStat==LE_UNIT_STAT_STRENGTH then
        Tabs[1].text= e.onlyChinese and '力量' or SPEC_FRAME_PRIMARY_STAT_STRENGTH
    elseif PrimaryStat==LE_UNIT_STAT_AGILITY then
        Tabs[1].text= e.onlyChinese and '敏捷' or SPEC_FRAME_PRIMARY_STAT_AGILITY
    else
        Tabs[1].text= e.onlyChinese and '智力' or SPEC_FRAME_PRIMARY_STAT_INTELLECT
    end

    for index, info in pairs(Tabs) do
        if not Save.tab[info.name]then
            Save.tab[info.name]={name= info.name}
        end
        Tabs[index].r= index==1 and e.Player.r or Save.tab[info.name].r or 1
        Tabs[index].g= index==1 and e.Player.g or Save.tab[info.name].g or 0.82
        Tabs[index].b= index==1 and e.Player.b or Save.tab[info.name].b or 0
        Tabs[index].a= index==1 and 1 or Save.tab[info.name].a or 1
        Tabs[index].useNumber=info.name=='STATUS' and true
                            or Tabs[index].usePercent and nil
                            or (Save.useNumber and not Tabs[index].usePercent ) and true
                            or Tabs[index].useNumber
        Tabs[index].bit= Save.tab[info.name].bit or Save.bit or 0
        Tabs[index].current= Save.tab[info.name].current
        Tabs[index].damageAndDefense= Save.tab[info.name].damageAndDefense
        Tabs[index].onlyDefense= Save.tab[info.name].onlyDefense
        Tabs[index].bar= Save.tab[info.name].bar and true or Save.bar and Tabs[index].bar
        Tabs[index].textValue= Save.setMaxMinValue and Tabs[index].textValue or false

        Tabs[index].hide= Save.tab[info.name].hide
        if not Tabs[index].hide then
            if info.name=='STAGGER' and (e.Player.class~='MONK' or Role~='TANK') then--武僧, 醉拳
                Tabs[index].hide= true
            elseif info.dps then--四属性, DPS
                if Role~='DAMAGER' and Role~='HEALER' and Save.onlyDPS then
                    Tabs[index].hide= true
                end
            elseif info.tank then--坦克
                if Role~='TANK' then
                    Tabs[index].hide= true
                end
            end
        end
    end
end

--###########
--设置，当前值
--###########
local function set_Text_Value(frame, value, value2)
    value= value or 0
    value= value>=1 and value or 0
    if not frame.value or frame.value==0 or value==0 then
        frame.value= value
    end

    if not Save.notText then
        local text
        if value==0 then
            text= ''
        else
            if frame.useNumber then
                text= e.MK(value, frame.bit)..( value2 and '/'..e.MK(value2, frame.bit) or '')
            else
                if value2 then
                    text= format('%.'..frame.bit..'f/%.'..frame.bit..'f%%', value, value2)
                else
                    text= format('%.'..frame.bit..'f%%', value)
                end
            end
            if frame.value< value then
                text= Save.greenColor..text
            elseif frame.value> value then
                text= Save.redColor..text
            end
        end
        frame.text:SetText(text)
    end

    if frame.bar and frame.bar:IsShown() then
        if frame.value== value or value==0 then
            frame.bar:SetStatusBarColor(frame.r, frame.g, frame.b, frame.a)
            frame.bar:SetValue(value)
            frame.barTexture:SetShown(false)
            frame.barTextureSpark:SetShown(false)
        else
            if frame.value< value then
                frame.bar:SetStatusBarColor(panel.barGreenColor.r, panel.barGreenColor.g, panel.barGreenColor.b, panel.barGreenColor.a)
            else
                frame.bar:SetStatusBarColor(panel.barRedColor.r, panel.barRedColor.g, panel.barRedColor.b, panel.barRedColor.a)
            end
            frame.bar:SetValue(value)
            if frame.useNumber then
                frame.barTexture:SetWidth(frame.bar:GetWidth()*(frame.value/frame.bar.maxValue))
            else
                frame.barTexture:SetWidth(frame.bar:GetWidth()*(frame.value/100))
            end
            frame.barTexture:SetShown(true)

            frame.barTextureSpark:ClearAllPoints()
            if Save.barToLeft then
                frame.barTextureSpark:SetPoint('LEFT', frame.barTexture,-3,0)
            else
                frame.barTextureSpark:SetPoint('RIGHT', frame.barTexture, 3,0)
            end
            frame.barTextureSpark:SetShown(true)
        end
    end

    if frame.textValue and frame.textValue:IsShown() then
        if frame.value== value or value==0 then
            frame.textValue:SetText('')
        else
            local text, icon
            if frame.value< value then--加
                if frame.useNumber then
                    icon, text= '|A:UI-HUD-Minimap-Zoom-In:8:8|a', e.MK(value-frame.value, frame.bit)
                else
                    icon, text= '|A:UI-HUD-Minimap-Zoom-In:8:8|a', format('%.'..frame.bit..'f', value-frame.value)
                end
            else--减
                if frame.useNumber then
                    icon, text= '|A:UI-HUD-Minimap-Zoom-Out:6:6|a', e.MK(frame.value-value, frame.bit)
                else
                    icon, text= '|A:UI-HUD-Minimap-Zoom-Out:8:8|a', format('%.'..frame.bit..'f', frame.value-value)
                end
            end
            if frame.bar and frame.bar:IsShown() then
                if Save.barToLeft then
                    text= text..icon
                else
                    text= icon..text
                end
            else
                if Save.toLeft then
                    text= text..icon
                else
                    text= icon..text
                end
            end
            frame.textValue:SetText(text)

            if frame.bar and frame.bar:IsShown() then--barToLeft
                local value3= frame.value>value and  frame.value or value
                local barX
                if frame.useNumber then
                    barX= frame.bar:GetWidth()*(value3/frame.bar.maxValue)
                else
                    barX= frame.bar:GetWidth()*(value3/100)
                end
                frame.textValue:ClearAllPoints()
                if Save.barToLeft then
                    frame.textValue:SetPoint('RIGHT', frame.bar, -(barX)-3, 0)
                else
                    frame.textValue:SetPoint('LEFT', frame.bar, barX+3, 0)
                end
            end
        end
    end
end

--#####
--主属性
--#####
local function set_STATUS_Text(frame)
    if not PrimaryStat then
        get_PrimaryStat()--取得主属
    end
    if not PrimaryStat then
        return
    end
    local value= select(2, UnitStat('player', PrimaryStat))
    if not frame then
        return value
    end
    set_Text_Value(frame, value)
end
local function set_STATUS_Tooltip(self)
    if not PrimaryStat then
        get_PrimaryStat()--取得主属
    end
    local frame= self:GetParent()
    e.tips:SetOwner(self, "ANCHOR_RIGHT")
    e.tips:ClearLines()
    local stat, effectiveStat, posBuff, negBuff = UnitStat('player', PrimaryStat);
    local effectiveStatDisplay = BreakUpLargeNumbers(effectiveStat or 0);
    local tooltipText = effectiveStatDisplay

    if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		e.tips:AddLine(tooltipText..effectiveStatDisplay..FONT_COLOR_CODE_CLOSE, nil,nil,nil,true)
	else
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText.." ("..BreakUpLargeNumbers(stat - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 ) then
			tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..BreakUpLargeNumbers(posBuff or 0)..FONT_COLOR_CODE_CLOSE;
		end
		if ( negBuff < 0 ) then
			tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..BreakUpLargeNumbers(negBuff or 0)..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
		end

        e.tips:AddDoubleLine(frame.nameText, tooltipText)
	end

    local role = GetSpecializationRole(GetSpecialization())
    if PrimaryStat==LE_UNIT_STAT_STRENGTH then-- Strength
        local text= ''
        local attackPower = GetAttackPowerForStat(PrimaryStat, effectiveStat or 0);
        if (HasAPEffectsSpellPower()) then
            text= (e.onlyChinese and '提高你的攻击和技能强度' or STAT_TOOLTIP_BONUS_AP_SP)..' '..BreakUpLargeNumbers(attackPower)
        end
        if role == "TANK" then
            local increasedParryChance = GetParryChanceFromAttribute();
            if ( increasedParryChance > 0 ) then
                text = text~='' and text..'|n' or text
                text= text..format(e.onlyChinese and '"招架几率提高%.2f%%|n|cff888888（在效果递减之前）|r"' or CR_PARRY_BASE_STAT_TOOLTIP, increasedParryChance);
            end
        end
        e.tips:AddDoubleLine(text,nil,nil,nil,true)

    elseif PrimaryStat==LE_UNIT_STAT_AGILITY then-- Agility
        local text=''
        if HasAPEffectsSpellPower() then
            text= e.onlyChinese and '提高你的攻击和技能强度' or  STAT_TOOLTIP_BONUS_AP_SP
        else
            text= e.onlyChinese and '提高你的攻击和技能强度' or STAT_TOOLTIP_BONUS_AP
        end

        if role == "TANK" then
            local increasedDodgeChance = GetDodgeChanceFromAttribute();
            if increasedDodgeChance > 0 then
                text= text .."|n"..format(e.onlyChinese and '躲闪几率提高%.2f%%|n|cff888888（在效果递减之前）|r' or CR_DODGE_BASE_STAT_TOOLTIP, increasedDodgeChance);
            end
        end
        e.tips:AddDoubleLine(text,nil,nil,nil,true)

    elseif PrimaryStat==LE_UNIT_STAT_INTELLECT then
        local text
        if HasAPEffectsSpellPower() then
            text= e.onlyChinese and "|cff808080该属性不能使你获益|r" or STAT_NO_BENEFIT_TOOLTIP
        elseif HasSPEffectsAttackPower() then
            text= e.onlyChinese and '提高你的攻击和技能强度' or  STAT_TOOLTIP_BONUS_AP_SP
        else
            text= (e.onlyChinese and '提高你的法术强度' or DEFAULT_STAT4_TOOLTIP).. effectiveStat
        end
        e.tips:AddDoubleLine(text,nil,nil,nil,true)
    end
    if frame.value and frame.value~=stat then
        e.tips:AddLine(' ')
        local text
        if frame.value< stat then
            text= Save.greenColor..'+ '..format('%s', e.MK(stat- frame.value,3))
        else
            text= Save.redColor..'- '..format('%s', e.MK(3, frame.value- stat))
        end
        e.tips:AddDoubleLine(format('%i', frame.value), text)
    end
    e.tips:Show()
end

--####
--爆击
--####
local function get_minCrit()
    local holySchool = 2;
    local minCrit = GetSpellCritChance(holySchool) or 0;
    local spellCrit;
    for i=(holySchool+1), MAX_SPELL_SCHOOLS do
        spellCrit = GetSpellCritChance(i);
        minCrit = min(minCrit, spellCrit);
    end
    return minCrit or 0
end
local function set_CRITCHANCE_Text(frame)
    local critChance
    if Save.useNumber then
        local rating
        local spellCrit = get_minCrit()
        local rangedCrit = GetRangedCritChance();
        local meleeCrit = GetCritChance();

        if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
            rating = CR_CRIT_SPELL;
        elseif (rangedCrit >= meleeCrit) then
            rating = CR_CRIT_RANGED;
        else
            rating = CR_CRIT_MELEE;
        end
        critChance = GetCombatRating(rating)
    else
        local spellCrit = get_minCrit()
        local rangedCrit = GetRangedCritChance();
        local meleeCrit = GetCritChance();
        if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
            critChance = spellCrit
        elseif (rangedCrit >= meleeCrit) then
            critChance = rangedCrit
        else
            critChance = meleeCrit
        end
    end
    if not frame then
        return critChance or 0
    else
        set_Text_Value(frame, critChance)--设置，当前值
    end
end
local function set_CRITCHANCE_Tooltip(self)
    local frame= self:GetParent()
    e.tips:SetOwner(self, "ANCHOR_RIGHT")
    e.tips:ClearLines()
    local spellCrit = get_minCrit() or 0
	local rangedCrit = GetRangedCritChance();
	local meleeCrit = GetCritChance();
    local critChance, rating
	if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
		critChance = spellCrit;
		rating = CR_CRIT_SPELL;
	elseif (rangedCrit >= meleeCrit) then
		critChance = rangedCrit;
		rating = CR_CRIT_RANGED;
	else
		critChance = meleeCrit;
		rating = CR_CRIT_MELEE;
	end
    e.tips:AddDoubleLine(frame.nameText, format('%.2f%%', critChance + 0.5))

	local extraCritChance = GetCombatRatingBonus(rating);
	local extraCritRating = GetCombatRating(rating);
	if (GetCritChanceProvidesParryEffect()) then
        if e.onlyChinese then
            e.tips:AddLine(format("攻击和法术造成额外效果的几率。|n爆击：%s [+%.2f%%]|n招架几率提高%.2f%%。", BreakUpLargeNumbers(extraCritRating), extraCritChance, GetCombatRatingBonusForCombatRatingValue(CR_PARRY, extraCritRating)), nil,nil,nil,true)
        else
            e.tips:AddLine(format(CR_CRIT_PARRY_RATING_TOOLTIP, BreakUpLargeNumbers(extraCritRating), extraCritChance, GetCombatRatingBonusForCombatRatingValue(CR_PARRY, extraCritRating)), nil,nil,nil,true)
        end
	else
        if e.onlyChinese then
		    e.tips:AddLine(format( "攻击和法术造成额外效果的几率。|n爆击：%s [+%.2f%%]", BreakUpLargeNumbers(extraCritRating), extraCritChance), nil,nil,nil,true)
        else
            e.tips:AddLine(format(CR_CRIT_TOOLTIP, BreakUpLargeNumbers(extraCritRating), extraCritChance), nil,nil,nil,true)
        end
	end
    e.tips:Show()
end

--####
--急速
--####
local function set_HASTE_Text(frame)
    local haste
    if Save.useNumber then
        haste= GetCombatRating(CR_HASTE_MELEE)
    else
        haste = GetHaste()
    end
    if not frame then
        return haste or 0
    else
        set_Text_Value(frame, haste)--设置，当前值
    end
end
local function set_HASTE_Tooltip(self)
    local frame= self:GetParent()
    e.tips:SetOwner(self, "ANCHOR_RIGHT")
    e.tips:ClearLines()

    local haste = GetHaste();
	local rating = CR_HASTE_MELEE;

	local hasteFormatString;
	if (haste < 0 and not GetPVPGearStatRules()) then
		hasteFormatString = RED_FONT_COLOR_CODE.."%s"..FONT_COLOR_CODE_CLOSE;
	else
		hasteFormatString = "%s";
	end
	e.tips:AddDoubleLine(frame.nameText, format(hasteFormatString, format("%0.2f%%", haste + 0.5)))
	e.tips:AddLine(_G["STAT_HASTE_"..e.Player.class.."_TOOLTIP"] or (e.onlyChinese and '提高攻击速度和施法速度。' or STAT_HASTE_TOOLTIP), nil, nil,nil,true)
	e.tips:AddDoubleLine(format(e.onlyChinese and '急速：%s [+%.2f%%]' or STAT_HASTE_BASE_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(rating)), GetCombatRatingBonus(rating)))
    e.tips:Show()
end

--####
--精通
--####
local function set_MASTERY_Text(frame)
    local mastery
    if Save.useNumber then
        mastery= GetCombatRating(CR_MASTERY)
    else
        mastery = GetMasteryEffect()
    end
    if not frame then
        return mastery or 0
    else
        set_Text_Value(frame, mastery)--设置，当前值
    end
end

--####
--全能, 5
--####
local function set_VERSATILITY_Text(frame)
    local value, value2
    if Save.useNumber then
        value = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE);
    else
        if frame.onlyDefense then
            value= GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN)
        else
            if frame.damageAndDefense then
                value= GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
                value2= GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN);
            else
                value= GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
            end
        end
    end
    if not frame then
        return value or 0, value2 or 0
    else
        set_Text_Value(frame, value, value2)--设置，当前值
    end
end
local function set_VERSATILITY_Tooltip(self)
    local frame= self:GetParent()
    e.tips:SetOwner(self, "ANCHOR_RIGHT")
    e.tips:ClearLines()
    local versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE);
	local versatilityDamageBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE);
	local versatilityDamageTakenReduction = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN);
    e.tips:AddDoubleLine(frame.nameText, format('%.2f%%',  versatilityDamageBonus))
	e.tips:AddLine(format(e.onlyChinese and "造成的伤害值和治疗量提高%.2f%%，|n受到的伤害降低%.2f%%。|n全能：%s [%.2f%%/%.2f%%]" or CR_VERSATILITY_TOOLTIP, versatilityDamageBonus, versatilityDamageTakenReduction, BreakUpLargeNumbers(versatility), versatilityDamageBonus, versatilityDamageTakenReduction), nil,nil,nil,true)
    e.tips:Show()
end

--####
--吸血, 6
--####
local function set_LIFESTEAL_Text(frame)
    local lifesteal
    if Save.useNumber then
        lifesteal= GetCombatRating(CR_LIFESTEAL)
    else
        lifesteal= GetLifesteal();
    end
    if not frame then
        return lifesteal or 0
    else
        set_Text_Value(frame, lifesteal)--设置，当前值
    end
end
local function set_LIFESTEAL_Tooltip(self)
    local frame= self:GetParent()
    e.tips:SetOwner(self, "ANCHOR_RIGHT")
    e.tips:ClearLines()

    local lifesteal = GetLifesteal();
	e.tips:AddDoubleLine(frame.nameText,  format("%0.2f%%", lifesteal))
    e.tips:AddLine(format(e.onlyChinese and '你所造成伤害和治疗的一部分将转而治疗你。|n|n吸血：%s [+%.2f%%]' or CR_LIFESTEAL_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_LIFESTEAL)), GetCombatRatingBonus(CR_LIFESTEAL)), nil,nil,nil,true)
    e.tips:Show()
end

--####
--闪避, 7
--####
local function set_AVOIDANCE_Text(frame)
    local avoidance
    if Save.useNumber then
        avoidance= GetCombatRating(CR_AVOIDANCE)
    else
        avoidance= GetAvoidance();
    end
    if not frame then
        return avoidance or 0
    else
        set_Text_Value(frame, avoidance)--设置，当前值
    end
end
local function set_AVOIDANCE_Tooltip(self)
    local frame= self:GetParent()
    e.tips:SetOwner(self, "ANCHOR_RIGHT")
    e.tips:ClearLines()

    local Avoidance = GetAvoidance();
	e.tips:AddDoubleLine(frame.nameText,  format("%0.2f%%", Avoidance))
    e.tips:AddLine(format(e.onlyChinese and '范围效果法术的伤害降低。|n|n闪避：%s [+%.2f%%' or CR_AVOIDANCE_TOOLTIP , BreakUpLargeNumbers(GetCombatRating(CR_AVOIDANCE)), GetCombatRatingBonus(CR_AVOIDANCE)), nil,nil,nil,true)
    e.tips:Show()
end

--####
--躲闪, 8
--####
local function set_DODGE_Text(frame)
    local chance
    if Save.useNumber then
        chance= GetCombatRating(CR_DODGE)
    else
        chance= GetDodgeChance();
    end
    if not frame then
        return chance or 0
    else
        set_Text_Value(frame, chance)--设置，当前值
    end
end
local function set_DODGE_Tooltip(self)
    local frame= self:GetParent()
    e.tips:SetOwner(self, "ANCHOR_RIGHT")
    e.tips:ClearLines()

    local chance = GetDodgeChance();
	e.tips:AddDoubleLine(frame.nameText,  format("%0.2f%%", chance))
    e.tips:AddLine( format(e.onlyChinese and '%d点躲闪可使躲闪几率提高%.2f%%|n|cff888888（在效果递减之前）|r' or CR_DODGE_TOOLTIP, GetCombatRating(CR_DODGE), GetCombatRatingBonus(CR_DODGE)), nil,nil,nil,true)
    e.tips:Show()
end

--####
--护甲
--####
local function set_ARMOR_Text(frame)
    local value, value2
    local baselineArmor, effectiveArmor, armor, bonusArmor = UnitArmor('player')
    if Save.useNumber then
        value= effectiveArmor
    else
        value = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitEffectiveLevel('player'));
        value2 = PaperDollFrame_GetArmorReductionAgainstTarget(effectiveArmor);
        if value== value2 then
            value2= nil
        end
    end
    if not frame then
        return value or 0, value2 or 0
    else
        set_Text_Value(frame, value, value2)--设置，当前值
    end
end
local function set_ARMOR_Tooltip(self)
    local frame= self:GetParent()
    e.tips:SetOwner(self, "ANCHOR_RIGHT")
    e.tips:ClearLines()

    local baselineArmor, effectiveArmor, armor, bonusArmor = UnitArmor('player');
    e.tips:AddDoubleLine(frame.nameText, BreakUpLargeNumbers(effectiveArmor))

    local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitEffectiveLevel('player'));
	local armorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(effectiveArmor);

    e.tips:AddLine(format(e.onlyChinese and '物理伤害减免：%0.2f%%|n|cff888888（对抗与你实力相当的敌人时）|r' or STAT_ARMOR_TOOLTIP, armorReduction), nil,nil,nil,true)

	if (armorReductionAgainstTarget) then
		e.tips:AddLine(format(e.onlyChinese and '（对当前目标：%0.2f%%）' or STAT_ARMOR_TARGET_TOOLTIP, armorReductionAgainstTarget), nil,nil,nil,true)
	end
    e.tips:Show()
end

--####
--招架
--####
local function set_PARRY_Text(frame)
    local chance
    if Save.useNumber then
        chance= GetCombatRating(CR_PARRY)
    else
        chance= GetParryChance();
    end
    if not frame then
        return chance or 0
    else
        set_Text_Value(frame, chance)--设置，当前值
    end
end
local function set_PARRY_Tooltip(self)
    local frame= self:GetParent()
    e.tips:SetOwner(self, "ANCHOR_RIGHT")
    e.tips:ClearLines()

    local chance = GetParryChance();
	e.tips:AddDoubleLine(frame.nameText,  format("%0.2f%%", chance))
    e.tips:AddLine(format(e.onlyChinese and '%d点招架可使招架几率提高%.2f%%|n|cff888888（在效果递减之前）|r' or CR_PARRY_TOOLTIP, GetCombatRating(CR_PARRY), GetCombatRatingBonus(CR_PARRY)), nil,nil,nil,true)
    e.tips:Show()
end

--####
--格挡
--####
local function set_BLOCK_Text(frame)
    local chance
    if Save.useNumber then
        chance= GetCombatRating(CR_BLOCK)
    else
        chance= GetBlockChance();
    end
    if not frame then
        return chance or 0
    else
        set_Text_Value(frame, chance)--设置，当前值
    end
end
local function set_BLOCK_Tooltip(self)
    local frame= self:GetParent()
    e.tips:SetOwner(self, "ANCHOR_RIGHT")
    e.tips:ClearLines()

    local chance = GetBlockChance();
    e.tips:AddDoubleLine(frame.nameText,  format("%0.2f%%", chance))

	local shieldBlockArmor = GetShieldBlock();
	local blockArmorReduction = PaperDollFrame_GetArmorReduction(shieldBlockArmor, UnitEffectiveLevel('player'));
	local blockArmorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(shieldBlockArmor);

	e.tips:AddLine(format(e.onlyChinese and '格挡可使一次攻击的伤害降低%0.2f%%.|n|cff888888（对抗与你实力相当的敌人时）|r' or CR_BLOCK_TOOLTIP, blockArmorReduction), nil,nil,nil,true)
	if (blockArmorReductionAgainstTarget) then
		e.tips:AddLine(format(e.onlyChinese and '（对当前目标：%0.2f%%）' or STAT_BLOCK_TARGET_TOOLTIP, blockArmorReductionAgainstTarget), nil,nil,nil,true)
	end
    e.tips:Show()
end

--####
--醉拳
--####
local function set_STAGGER_Text(frame)
    local stagger, staggerAgainstTarget = C_PaperDollInfo.GetStaggerPercentage('player')
    set_Text_Value(frame, stagger, staggerAgainstTarget)--设置，当前值
end
local function set_STAGGER_Tooltip(self)
    local stagger, staggerAgainstTarget = C_PaperDollInfo.GetStaggerPercentage('player');
    if not stagger then
        return
    end
    local frame= self:GetParent()
    e.tips:SetOwner(self, "ANCHOR_RIGHT")
    e.tips:ClearLines()
    e.tips:AddDoubleLine(frame.nameText,  format("%0.2f%%", stagger))
	e.tips:AddLine(format(e.onlyChinese and '你的醉拳可化解%0.2f%%的伤害' or STAT_STAGGER_TOOLTIP, stagger), nil,nil,nil,true)
	if (staggerAgainstTarget) then
		e.tips:AddLine(format(e.onlyChinese and '（对当前目标比例%0.2f%%）' or STAT_STAGGER_TARGET_TOOLTIP, staggerAgainstTarget), nil,nil,nil,true)
	end
    e.tips:Show()
end

--####
--移动
--####
local timeElapsed = 0
local function set_SPEED_Text(frame, elapsed)
    timeElapsed = timeElapsed + elapsed
    if timeElapsed > 0.3 then
        local unit= UnitExists('vehicle') and 'vehicle' or (frame.current or UnitOnTaxi('player')) and 'player'
        if unit then
            local currentSpeed = GetUnitSpeed(unit)
            if currentSpeed~=0 then
                frame.text:SetFormattedText('%.0f%%', currentSpeed*100/BASE_MOVEMENT_SPEED)
            else
                frame.text:SetText('')
            end
        else
            local _, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed('player')
            local value
            value= IsFlying() and flightSpeed or IsSwimming() and swimSpeed or runSpeed
            if value~=0 then
                frame.text:SetFormattedText('%.0f%%', value*100/BASE_MOVEMENT_SPEED)
            else
                frame.text:SetText('')
            end
        end
        timeElapsed = 0
    end
end
local function set_SPEED_Tooltip(self)
    local frame= self:GetParent()
    e.tips:SetOwner(self, "ANCHOR_RIGHT")
    e.tips:ClearLines()
    local currentSpeed, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed('player')
    e.tips:AddDoubleLine(frame.nameText, 'player')
    e.tips:AddLine(format(e.onlyChinese and '提升移动速度。|n|n速度：%s [+%.2f%%]' or CR_SPEED_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_SPEED)), GetCombatRatingBonus(CR_SPEED)), nil,nil,nil, true)
    e.tips:AddLine(' ')
    e.tips:AddDoubleLine((e.onlyChinese and '当前' or REFORGE_CURRENT)..format(' %.0f%%', currentSpeed*100/BASE_MOVEMENT_SPEED), format('%.2f', currentSpeed))
    e.tips:AddDoubleLine((e.onlyChinese and '地面' or MOUNT_JOURNAL_FILTER_GROUND)..format(' %.0f%%', runSpeed*100/BASE_MOVEMENT_SPEED), format('%.2f', runSpeed))
    e.tips:AddDoubleLine((e.onlyChinese and '水栖' or MOUNT_JOURNAL_FILTER_AQUATIC )..format(' %.0f%%', swimSpeed*100/BASE_MOVEMENT_SPEED), format('%.2f', swimSpeed))
    e.tips:AddDoubleLine((e.onlyChinese and '飞行' or MOUNT_JOURNAL_FILTER_FLYING )..format(' %.0f%%', flightSpeed*100/BASE_MOVEMENT_SPEED), format('%.2f', flightSpeed))
    if UnitExists('vehicle') then
        currentSpeed = GetUnitSpeed('vehicle')
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '载具' or 'Vehicle')..format(' %.0f%%', currentSpeed*100/BASE_MOVEMENT_SPEED), format('%.2f', currentSpeed))
    end
    e.tips:Show()
end



local function set_Shadow(self)--设置，字体阴影
    if self then
        self:SetShadowColor(Save.font.r, Save.font.g, Save.font.b, Save.font.a)
        self:SetShadowOffset(Save.font.x, Save.font.y)
    end
end
local function set_Frame(frame, rest)--设置, frame
    if rest then
        --frame, 数值
        frame:SetSize(Save.horizontal, 12+ (Save.vertical or 3))--设置，大小

        --名称
        frame.label:ClearAllPoints()
        if Save.toLeft then
            frame.label:SetPoint('LEFT', frame, 'RIGHT',-5,0)
        else
            frame.label:SetPoint('RIGHT', frame, 'LEFT', 5,0)
        end

        local text= frame.nameText
        if Save.strupper then--大写
            text= strupper(text)
        elseif Save.strlower then--小写
            text= strlower(text)
        end
        if Save.gsubText then--文本，截取
            text= e.WA_Utf8Sub(text, Save.gsubText)
        end
        frame.label:SetText(text or '')

        --数值,text
        frame.text:ClearAllPoints()
        if Save.toLeft then
            frame.text:SetPoint('RIGHT', frame, 'LEFT', 5,0)
        else
            frame.text:SetPoint('LEFT', frame, 'RIGHT',-5,0)
        end

        if Save.toLeft then
            frame.label:SetJustifyH('LEFT')
            frame.text:SetJustifyH('RIGHT')
        else
            frame.label:SetJustifyH('RIGHT')
            frame.text:SetJustifyH('LEFT')
        end

        set_Shadow(frame.label)--设置，字体阴影
        set_Shadow(frame.text)--设置，字体阴影
        
        if frame.bar and frame:IsShown() then
            local value
            if frame.useNumber then
                if frame.name=='STATUS' then
                    value= set_STATUS_Text() or 1000
                else
                    value= max(--取得Bar，最高值
                        set_CRITCHANCE_Text(),
                        set_HASTE_Text(),
                        set_MASTERY_Text(),
                        set_VERSATILITY_Text(),
                        set_LIFESTEAL_Text(),
                        set_AVOIDANCE_Text(),
                        set_ARMOR_Text(),
                        set_DODGE_Text(),
                        set_PARRY_Text()
                    )
                end
                value= (value and value~=0) and value or 1000
                value= format('%i', value)
                value= tonumber('1'..string.rep('0', #value))
            else
                frame.bar:SetMinMaxValues(0,100)
                value=100
            end
            frame.bar:SetMinMaxValues(0, value)
            frame.bar.maxValue=value
            frame.bar:SetSize(120+Save.barWidth, 10)
            frame.bar:ClearAllPoints()
            if Save.barToLeft then
                frame.bar:SetPoint('RIGHT', frame, 'LEFT', -(Save.barX), 0)
                frame.bar:SetReverseFill(true)
            else
                frame.bar:SetPoint('LEFT', frame, 'RIGHT', Save.barX, 0)
                frame.bar:SetReverseFill(false)
            end

            if Save.barTexture2 then
                frame.bar:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')
            else
                frame.bar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')
            end

            frame.barTexture:ClearAllPoints()
            if Save.barToLeft then
                frame.barTexture:SetPoint('RIGHT')
            else
                frame.barTexture:SetPoint('LEFT')
            end
            frame.barTexture:SetSize(frame.bar:GetWidth(), 10)
        end

        if frame.textValue then--数值 + -
            frame.textValue:ClearAllPoints()
            frame.textValue:SetTextColor(frame.r,frame.g,frame.b,frame.a)
            if not Save.notText then
                if Save.toLeft then
                    frame.textValue:SetPoint('RIGHT', frame.text, 'LEFT')--, -30-(frame.bit*6), 0)
                else
                    frame.textValue:SetPoint('LEFT', frame.text, 'RIGHT')--, 30+(frame.bit*6), 0)
                end
            else--不显示，数值
                if Save.toLeft then
                    frame.text:SetPoint('RIGHT', frame, 'LEFT')
                else
                    frame.text:SetPoint('LEFT', frame, 'RIGHT')
                end
            end
            frame.textValue:SetShown(Save.setMaxMinValue)
        end
    end

    if frame.name=='STATUS' then--主属性1
        if not PrimaryStat or not Role then
            get_PrimaryStat()--取得主属
        end
        set_STATUS_Text(frame)
    elseif frame.name=='CRITCHANCE' then--爆击2
        set_CRITCHANCE_Text(frame)
    elseif frame.name=='HASTE' then--急速3
        set_HASTE_Text(frame)
    elseif frame.name=='MASTERY' then--精通4
        set_MASTERY_Text(frame)
    elseif frame.name=='VERSATILITY' then--全能5
        set_VERSATILITY_Text(frame)
    elseif frame.name=='LIFESTEAL' then--吸血6
        set_LIFESTEAL_Text(frame)
    elseif frame.name=='ARMOR' then--护甲
        set_ARMOR_Text(frame)
    elseif frame.name=='AVOIDANCE' then--闪避
        set_AVOIDANCE_Text(frame)
    elseif frame.name=='DODGE' then--躲闪
        set_DODGE_Text(frame)
    elseif frame.name=='PARRY' then--招架
        set_PARRY_Text(frame)
    elseif frame.name=='BLOCK' then--格挡
        set_BLOCK_Text(frame)
    elseif frame.name=='STAGGER' then--醉拳
        set_STAGGER_Text(frame)
    end
end

local function frame_Init(rest)--初始， 或设置
    if rest then
        set_Tabs()
    end

    local last= button.frame
    for _, info in pairs(Tabs) do
        local frame, find= button[info.name], nil
        if not info.hide then
            if not frame then
                frame= CreateFrame('Frame', nil, button.frame)

                frame.label= e.Cstr(frame, {color={r=info.r, g=info.g,b=info.b, a=info.a}})--nil, nil, nil, {info.r,info.g,info.b,info.a}, nil)
                frame.label:EnableMouse(true)
                frame.label:SetScript('OnLeave', function() e.tips:Hide() end)

                frame.text= e.Cstr(frame, {color={r=1,g=1,b=1}, justifyH= Save.toLeft and 'RIGHT'})--nil, nil, nil, {1,1,1}, nil, Save.toLeft and 'RIGHT' or 'LEFT')
                frame.text:EnableMouse(true)
                frame.text:SetScript('OnLeave', function() e.tips:Hide() end)

                if info.name=='STATUS' then--主属性1
                    frame:RegisterUnitEvent('UNIT_STATS', 'player')
                    frame:SetScript('OnEvent', set_STATUS_Text)
                    frame.label:SetScript('OnEnter', set_STATUS_Tooltip)
                    frame.text:SetScript('OnEnter', set_STATUS_Tooltip)

                elseif info.name=='CRITCHANCE' then--爆击2
                    --frame:RegisterUnitEvent('UNIT_DAMAGE', 'player')
                    --frame:RegisterUnitEvent('UNIT_AURA', 'player')
                    --frame:SetScript('OnEvent', set_CRITCHANCE_Text)
                    frame.label:SetScript('OnEnter', set_CRITCHANCE_Tooltip)
                    frame.text:SetScript('OnEnter', set_CRITCHANCE_Tooltip)

                elseif info.name=='HASTE' then--急速3
                    frame:RegisterUnitEvent('UNIT_SPELL_HASTE', 'player')
                    frame:SetScript('OnEvent', set_HASTE_Text)
                    frame.label:SetScript('OnEnter', set_HASTE_Tooltip)
                    frame.text:SetScript('OnEnter', set_HASTE_Tooltip)

                elseif info.name=='MASTERY' then--精通4
                    frame:RegisterEvent('MASTERY_UPDATE')
                    frame.onEnterFunc = Mastery_OnEnter;
                    frame.label:SetScript('OnEnter', frame.onEnterFunc)--PaperDollFrame.lua
                    frame.text:SetScript('OnEnter', frame.onEnterFunc)

                elseif info.name=='VERSATILITY' then--全能5
                    --frame:RegisterUnitEvent('UNIT_DEFENSE', "player")
                    --frame:RegisterUnitEvent('UNIT_DAMAGE', 'player')
                    --frame:RegisterUnitEvent('UNIT_AURA', 'player')
                    --frame:SetScript('OnEvent', set_VERSATILITY_Text)
                    frame.label:SetScript('OnEnter', set_VERSATILITY_Tooltip)
                    frame.text:SetScript('OnEnter', set_VERSATILITY_Tooltip)

                elseif info.name=='LIFESTEAL' then--吸血6
                    --frame:RegisterEvent('LIFESTEAL_UPDATE')
                    button.frame:RegisterEvent('LIFESTEAL_UPDATE')
                    --frame:SetScript('OnEvent', set_LIFESTEAL_Text)
                    frame.label:SetScript('OnEnter', set_LIFESTEAL_Tooltip)
                    frame.text:SetScript('OnEnter', set_LIFESTEAL_Tooltip)

                elseif info.name=='ARMOR' then--护甲
                    --frame:RegisterUnitEvent('UNIT_DEFENSE', "player")
                    --frame:RegisterUnitEvent('UNIT_AURA', 'player')
                    frame:RegisterEvent('PLAYER_TARGET_CHANGED')
                    frame:SetScript('OnEvent', set_ARMOR_Text)
                    frame.label:SetScript('OnEnter', set_ARMOR_Tooltip)
                    frame.text:SetScript('OnEnter', set_ARMOR_Tooltip)

                elseif info.name=='AVOIDANCE' then--闪避7
                    --frame:RegisterEvent('AVOIDANCE_UPDATE')
                    button.frame:RegisterEvent('AVOIDANCE_UPDATE')
                    --frame:SetScript('OnEvent', set_AVOIDANCE_Text)
                    frame.label:SetScript('OnEnter', set_AVOIDANCE_Tooltip)
                    frame.text:SetScript('OnEnter', set_AVOIDANCE_Tooltip)

                elseif info.name=='DODGE' then--躲闪8
                    --frame:RegisterUnitEvent('UNIT_DEFENSE', "player")
                    --frame:RegisterUnitEvent('UNIT_AURA', 'player')
                    --frame:SetScript('OnEvent', set_DODGE_Text)
                    frame.label:SetScript('OnEnter', set_DODGE_Tooltip)
                    frame.text:SetScript('OnEnter', set_DODGE_Tooltip)

                elseif info.name=='PARRY' then--招架9
                    --frame:RegisterUnitEvent('UNIT_DEFENSE', "player")
                    --frame:RegisterUnitEvent('UNIT_AURA', 'player')
                    --frame:SetScript('OnEvent', set_PARRY_Text)
                    frame.label:SetScript('OnEnter', set_PARRY_Tooltip)
                    frame.text:SetScript('OnEnter', set_PARRY_Tooltip)

                elseif info.name=='BLOCK' then--格挡10
                    --frame:RegisterUnitEvent('UNIT_DEFENSE', "player")
                    --frame:RegisterUnitEvent('UNIT_AURA', 'player')
                    --frame:SetScript('OnEvent', set_BLOCK_Text)
                    frame.label:SetScript('OnEnter', set_BLOCK_Tooltip)
                    frame.text:SetScript('OnEnter', set_BLOCK_Tooltip)

                elseif info.name=='STAGGER' then--醉拳11
                    --frame:RegisterUnitEvent('UNIT_AURA', 'player')
                    --frame:RegisterUnitEvent('UNIT_DAMAGE', 'player')
                    frame:RegisterEvent('PLAYER_TARGET_CHANGED')
                    frame:SetScript('OnEvent', set_STAGGER_Text)
                    frame.label:SetScript('OnEnter', set_STAGGER_Tooltip)
                    frame.text:SetScript('OnEnter', set_STAGGER_Tooltip)

                elseif info.name=='SPEED' then--移动12
                    frame:HookScript('OnUpdate', set_SPEED_Text)
                    frame.label:SetScript('OnEnter', set_SPEED_Tooltip)
                    frame.text:SetScript('OnEnter', set_SPEED_Tooltip)
                    hooksecurefunc(UIWidgetPowerBarContainerFrame, 'CreateWidget', function(self, widgetID)
                        if widgetID==4460 then
                            frame:SetShown(false)
                        end
                    end)
                    hooksecurefunc(UIWidgetPowerBarContainerFrame, 'RemoveWidget', function(self, widgetID)
                        if widgetID==4460 then
                            frame:SetShown(true)
                        end
                    end)
                end
                button[info.name]= frame
            end

            --重置, 数值
            if rest then
                if info.bar and not frame.bar then--bar
                    frame.bar= CreateFrame('StatusBar', nil, frame)
                    frame.bar:SetFrameLevel(frame:GetFrameLevel()-1)
                    frame.barTexture= frame.bar:CreateTexture(nil, 'BORDER')
                    frame.barTexture:SetAtlas('UI-HUD-UnitFrame-Player-GroupIndicator')
                    frame.barTextureSpark= frame.bar:CreateTexture(nil, 'OVERLAY')
                    frame.barTextureSpark:SetAtlas('objectivewidget-bar-spark-neutral')
                    frame.barTextureSpark:SetSize(6,12)
                end
                if frame.bar then
                    frame.bar:SetShown(info.bar)
                    frame.barTextureSpark:SetShown(false)
                end

                if info.textValue and not frame.textValue then--数值 + -
                    frame.textValue=e.Cstr(frame)
                end
                if frame.textValue then
                    frame.textValue:SetText('')
                    frame.textValue:SetShown(info.textValue)
                end
                if Save.notText then
                    frame.text:SetText('')
                else
                    frame.text:SetTextColor(Save.textColor.r, Save.textColor.g, Save.textColor.b, Save.textColor.a)
                end

                frame.r, frame.g, frame.b, frame.a= info.r,info.g,info.b,info.a
                frame.damageAndDefense= info.damageAndDefense--全能5
                frame.onlyDefense= info.onlyDefense--全能5
                frame.current= info.current--SPEED 速度12
                frame.bit= info.bit or 0
                frame.useNumber= info.useNumber
                frame.name= info.name
                frame.nameText= info.text

                frame.value=nil
            end

            set_Frame(frame, rest)

            find= (frame.value and frame.value>0) or info.name=='SPEED'
            if find then
                frame:ClearAllPoints()
                frame:SetPoint('TOP', last,'BOTTOM')
                last= frame
                frame:SetShown(true)
            end
        end
        if not find and frame then
            frame:SetShown(false)
        end
    end
end


--##########
--显示， 隐藏
--##########
local function set_Show_Hide()
    button.frame:SetShown(not Save.hide)
    button.texture:SetAlpha(Save.hide and 1 or Save.buttonAlpha or 0.3)
    button.classPortrait:SetAlpha(Save.hide and 1 or Save.buttonAlpha or 0.3)
end

--################
--显示，隐藏，事件
--################
local function set_ShowHide_Event()
    if Save.hideInPetBattle then
        panel:RegisterEvent('PET_BATTLE_OPENING_DONE')
        panel:RegisterEvent('PET_BATTLE_CLOSE')
        panel:RegisterEvent('PLAYER_ENTERING_WORLD')
    else
        panel:UnregisterEvent('PET_BATTLE_OPENING_DONE')
        panel:UnregisterEvent('PET_BATTLE_CLOSE')
        panel:UnregisterEvent('PLAYER_ENTERING_WORLD')
    end
end

--#########
--设置, 位置
--#########
local function set_Point()
    if Save.point then
        button:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
    else
        button:SetPoint('LEFT', 23, 180)
    end
end

--##########
--设置 panel
--##########
local function set_Panle_Setting()--设置 panel
    local last, check, findTank, findDps
    --[[last=CreateFrame('Button', nil, panel, 'UIPanelButtonTemplate')--重新加载UI
    last:SetPoint('TOPLEFT')
    last:SetText(e.onlyChinese and '重新加载UI' or RELOADUI)
    last:SetSize(120, 28)
    last:SetScript('OnMouseUp', e.Reload)]]


    for index, info in pairs(Tabs) do
        if info.dps and not findDps then
            check=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--四属性, 仅限DPS
            check:SetChecked(Save.onlyDPS)
            check:SetPoint('TOPLEFT', last, 'BOTTOMLEFT',0, -16)
            if e.onlyChinese then
                check.text:SetText("仅限"..INLINE_DAMAGER_ICON..INLINE_HEALER_ICON)
            else
                check.text:SetFormattedText(LFG_LIST_CROSS_FACTION , INLINE_DAMAGER_ICON..INLINE_HEALER_ICON)
            end
            check:SetScript('OnMouseUp',function(self)
                Save.onlyDPS = not Save.onlyDPS and true or false
                frame_Init(true)--初始，设置
            end)
            findDps=true
            last=check

        elseif info.tank and not findTank then
            local text= e.Cstr(panel)
            text:SetPoint('TOPLEFT', last, 'BOTTOMLEFT',0, -16)
            if e.onlyChinese then
                text:SetText("仅限"..INLINE_TANK_ICON)
            else
                text:SetFormattedText(LFG_LIST_CROSS_FACTION , INLINE_TANK_ICON)
            end
            findTank=true
            last= text
        end
        local r= info.r or 1
        local g= info.g or 0.82
        local b= info.b or 0
        local a= info.a or 1

        check= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--禁用, 启用
        check:SetChecked(not Save.tab[info.name].hide)
        if info.name=='STATUS' or info.name=='SPEED' or info.name=='LIFESTEAL' then
            if last then
                check:SetPoint('TOPLEFT', last, 'BOTTOMLEFT',0, -16)
            else
                check:SetPoint('TOPLEFT', 0, -32)
            end
        else
            check:SetPoint('TOPLEFT', last, 'BOTTOMLEFT',0, 6)
        end
        check.name= info.name
        check.text2= info.text
        check:SetScript('OnMouseUp',function(self)
            Save.tab[self.name].hide= not Save.tab[self.name].hide and true or nil
            frame_Init(true)--初始，设置
        end)
        check:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            local value= button[self.name] and button[self.name].value
            e.tips:AddDoubleLine(self.text2, format('%.2f%%', value or 0))
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.GetShowHide(Save.tab[self.name].hide), '|cnGREEN_FONT_COLOR:0 = '..(e.onlyChinese and '隐藏' or HIDE))
            e.tips:Show()
        end)
        check:SetScript('OnLeave', function(self) e.tips:Hide() end)

        local text= e.Cstr(panel, {color={r=r,g=g,b=b,a=a}})--nil, nil, nil, {r,g,b,a})--Text
        text:SetPoint('LEFT', check, 'RIGHT')
        text:SetText(info.text)
        if index>1 then
            text:EnableMouse(true)
            text.r, text.g, text.b, text.a= r, g, b, a
            text.name= info.name
            text.text= info.text
            text:SetScript('OnMouseDown', function(self)
                local R,G,B,A= self.r, self.g, self.b, self.a
                local setA, setR, setG, setB
                local function func()
                    Save.tab[self.name].r= setR
                    Save.tab[self.name].g= setG
                    Save.tab[self.name].b= setB
                    Save.tab[self.name].a= setA
                    self:SetTextColor(setR, setG, setB, setA)
                    if button[self.name] then
                        if button[self.name].label then
                            button[self.name].label:SetTextColor(setR, setG, setB, setA)
                        end
                        if button[self.name].bar then
                            button[self.name].bar:SetStatusBarColor(setR,setG,setB,setA)
                        end
                    end
                end
                e.ShowColorPicker(self.r, self.g, self.b,self.a, function()
                        setR, setG, setB, setA = e.Get_ColorFrame_RGBA()
                        func()
                    end,function()
                         setR, setG, setB, setA= R,G,B,A
                        func()
                    end
                )
            end)
            text:SetScript('OnEnter', function(self)
                local r2= Save.tab[self.name].r or 1
                local g2= Save.tab[self.name].g or 0.82
                local b2= Save.tab[self.name].b or 0
                local a2= Save.tab[self.name].a or 1
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(self.text, self.name, r2, g2, b2)
                e.tips:AddDoubleLine(e.onlyChinese and '设置' or SETTINGS, (e.onlyChinese and '颜色' or COLOR)..e.Icon.left)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(format('r%.2f', r2)..format('  g%.2f', g2)..format('  b%.2f', b2), format('a%.2f', a2))
                e.tips:Show()
            end)
            text:SetScript('OnLeave', function() e.tips:Hide() end)
        end

        if info.name=='STATUS' then--主属性, 使用bar
            local current= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
            current:SetChecked(Save.tab[info.name].bar)
            current:SetPoint('LEFT', text, 'RIGHT',2,0)
            current.text:SetText('Bar')
            current:SetScript('OnMouseUp',function(self)
                Save.tab['STATUS'].bar= not Save.tab['STATUS'].bar and true or false
                frame_Init(true)--初始， 或设置
            end)
            current:SetScript('OnEnter', set_SPEED_Tooltip)
            current:SetScript('OnLeave', function() e.tips:Hide() end)

            local sliderBit= CreateFrame("Slider", nil, panel, 'OptionsSliderTemplate')--位数，bit
            sliderBit:SetPoint("LEFT", current.text, 'RIGHT', 6,0)
            sliderBit:SetSize(100,20)
            sliderBit:SetMinMaxValues(0, 6)
            sliderBit:SetValue(Save.tab['STATUS'].bit or 3)
            sliderBit.Low:SetText('0')
            sliderBit.High:SetText('0.003')
            sliderBit.Text:SetText(Save.tab['STATUS'].bit or 3)
            sliderBit:SetValueStep(1)
            sliderBit:SetScript('OnValueChanged', function(self, value, userInput)
                value= math.floor(value)
                self:SetValue(value)
                self.Text:SetText(value)
                Save.tab['STATUS'].bit= value==0 and 0 or value
                frame_Init(true)--初始，设置
            end)

        elseif info.name=='SPEED' then--速度, 当前速度, 选项
            local current= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
            current:SetChecked(Save.tab[info.name].current)
            current:SetPoint('LEFT', text, 'RIGHT',2,0)
            current.text:SetText(e.onlyChinese and '当前' or 'REFORGE_CURRENT')
            current:SetScript('OnMouseUp',function(self)
                Save.tab['SPEED'].current= not Save.tab['SPEED'].current and true or false
                frame_Init(true)--初始， 或设置
            end)
            current:SetScript('OnEnter', set_SPEED_Tooltip)
            current:SetScript('OnLeave', function() e.tips:Hide() end)

        elseif info.name=='VERSATILITY' then--全能5
            local check2=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--仅防卫
            check2:SetChecked(Save.tab['VERSATILITY'].onlyDefense)
            check2:SetPoint('LEFT', text, 'RIGHT',2,0)
            check2.text:SetText((e.onlyChinese and '仅防御' or format(LFG_LIST_CROSS_FACTION, DEFENSE)))
            check2:SetScript('OnMouseDown', function(self)
                Save.tab['VERSATILITY'].onlyDefense= not Save.tab['VERSATILITY'].onlyDefense and true or nil
                if Save.tab['VERSATILITY'].onlyDefense then
                    check2.A.text:SetTextColor(0.62, 0.62, 0.62)
                else
                    check2.A.text:SetTextColor(1, 0.82, 0)
                end
                frame_Init(true)--初始，设置
            end)
            check2:SetScript('OnEnter', set_VERSATILITY_Tooltip)
            check2:SetScript('OnLeave', function() e.tips:Hide() end)

            check2.A=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--双属性 22/18%
            check2.A:SetChecked(Save.tab['VERSATILITY'].damageAndDefense)
            check2.A:SetPoint('LEFT', check2.text, 'RIGHT',2,0)
            check2.A.text:SetText('22/18%')
            check2.A:SetScript('OnMouseDown', function(self)
                Save.tab['VERSATILITY'].damageAndDefense= not Save.tab['VERSATILITY'].damageAndDefense and true or nil
                frame_Init(true)--初始，设置
            end)
            check2.A:SetScript('OnEnter', set_VERSATILITY_Tooltip)
            check2.A:SetScript('OnLeave', function() e.tips:Hide() end)

            if Save.tab['VERSATILITY'].onlyDefense then
                check2.A.text:SetTextColor(0.62, 0.62, 0.62)
            end
        end
        last= check
    end



    local text= e.Cstr(panel, {size=26})--26)--Text
    text:SetPoint('TOPLEFT', last, 'BOTTOMLEFT',0, -16)
    text:SetText(e.onlyChinese and '阴影' or SHADOW_QUALITY:gsub(QUALITY , ''))
    text:EnableMouse(true)
    text.r, text.g, text.b, text.a= Save.font.r, Save.font.g, Save.font.b, Save.font.a
    set_Shadow(text)--设置，字体阴影
    text:SetScript('OnMouseDown', function(self)
        local R,G,B,A= self.r, self.g, self.b, self.a
        local setA, setR, setG, setB
        local function func()
            Save.font.r= setR
            Save.font.g= setG
            Save.font.b= setB
            Save.font.a= setA
            set_Shadow(self)--设置，字体阴影
            frame_Init(true)--初始，设置
        end
        e.ShowColorPicker(self.r, self.g, self.b, self.a, function()
                setR, setG, setB, setA = e.Get_ColorFrame_RGBA()
                func()
            end, function()
                setR, setG, setB, setA= R,G,B,A
                func()
            end
        )
    end)

    local sliderX= CreateFrame("Slider", nil, panel, 'OptionsSliderTemplate')--bar, 宽度
    sliderX:SetPoint("TOPLEFT", text, 'BOTTOMLEFT',0,-12)
    sliderX:SetSize(120,20)
    sliderX:SetMinMaxValues(-5,5)
    sliderX:SetValue(Save.font.x)
    sliderX.Low:SetText('')
    sliderX.High:SetText('')
    sliderX.Text:SetText('x'..Save.font.x)
    sliderX:SetValueStep(0.1)
    sliderX:SetScript('OnValueChanged', function(self, value, userInput)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText('x'..value)
        Save.font.x= value==0 and 0 or value
        set_Shadow(self.text)--设置，字体阴影
        frame_Init(true)--初始，设置
    end)
    sliderX.text= text

    local sliderY= CreateFrame("Slider", nil, panel, 'OptionsSliderTemplate')--bar, 宽度
    sliderY:SetPoint("LEFT", sliderX, 'RIGHT', 2, 0)
    sliderY:SetSize(120,20)
    sliderY:SetMinMaxValues(-5,5)
    sliderY:SetValue(Save.font.y)
    sliderY.Low:SetText('')
    sliderY.High:SetText('')
    sliderY.Text:SetText('y'..Save.font.y)
    sliderY:SetValueStep(0.1)
    sliderY:SetScript('OnValueChanged', function(self, value, userInput)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText('y'..value)
        Save.font.y= value==0 and 0 or value
        set_Shadow(self.text)--设置，字体阴影
        frame_Init(true)--初始，设置
    end)
    sliderY.text= text



    local notTextCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    notTextCheck:SetPoint("TOPLEFT", panel, 'TOP', 0, -32)
    notTextCheck.text:SetText(e.onlyChinese and '隐藏数值' or HIDE..STATUS_TEXT_VALUE)
    notTextCheck:SetChecked(Save.notText)
    notTextCheck:SetScript('OnMouseDown', function()
        Save.notText= not Save.notText and true or nil
        frame_Init(true)--初始， 或设置
    end)

    local textColor= e.Cstr(panel, {size=20})--20)--数值text, 颜色
    textColor:SetPoint('LEFT', notTextCheck.text,'RIGHT', 5, 0)
    textColor:EnableMouse(true)
    textColor:SetScript('OnLeave', function(self) e.tips:Hide() end)
    textColor:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '设置' or SETTINGS, self.hex..(e.onlyChinese and '颜色' or COLOR))
        e.tips:Show()
    end)
    textColor:SetText('23%')
    e.RGB_to_HEX(Save.textColor.r, Save.textColor.g, Save.textColor.b, Save.textColor.a, textColor)
    textColor:SetScript('OnMouseDown', function(self)
        local setR, setG, setB, setA
        local R,G,B,A= self.r, self.g, self.b, self.a
        local function func()
            Save.textColor= {r=setR, g=setG, b=setB, a=setA}
            self:SetTextColor(setR, setG, setB, setA)
            frame_Init(true)--初始，设置
        end
        e.ShowColorPicker(self.r, self.g, self.b,self.a, function()
                setR, setG, setB, setA= e.Get_ColorFrame_RGBA()
                func()
            end,function()
                setR, setG, setB, setA= R,G,B,A
                func()
            end
        )
    end)


    check= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    check:SetPoint("TOPLEFT", notTextCheck, 'BOTTOMLEFT')
    check.text:SetText((e.onlyChinese and '向左' or BINDING_NAME_STRAFELEFT)..' 23%'..Tabs[2].text)
    check:SetChecked(Save.toLeft)
    check:SetScript('OnMouseDown', function()
        Save.toLeft= not Save.toLeft and true or nil
        frame_Init(true)--初始， 或设置
    end)


    local check5= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--使用，数值
    check5:SetPoint("TOPLEFT", check, 'BOTTOMLEFT')
    check5.text:SetText((e.onlyChinese and '数值' or STATUS_TEXT_VALUE)..' 2K')
    check5:SetChecked(Save.useNumber)
    check5:SetScript('OnMouseDown', function()
        Save.useNumber= not Save.useNumber and true or nil
        frame_Init(true)--初始， 或设置
    end)

    local sliderBit= CreateFrame("Slider", nil, panel, 'OptionsSliderTemplate')--位数，bit
    sliderBit:SetPoint("LEFT", check5.text, 'RIGHT', 6,0)
    sliderBit:SetSize(150,20)
    sliderBit:SetMinMaxValues(0, 3)
    sliderBit:SetValue(Save.bit)
    sliderBit.Low:SetText('0')
    sliderBit.High:SetText('0.003')
    sliderBit.Text:SetText(Save.bit)
    sliderBit:SetValueStep(1)
    sliderBit:SetScript('OnValueChanged', function(self, value, userInput)
        value= math.ceil(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.bit= value==0 and 0 or value
        frame_Init(true)--初始，设置
    end)

    local barValueText= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--增加,减少,值
    barValueText:SetPoint("TOPLEFT", check5, 'BOTTOMLEFT')
    barValueText.text:SetText(e.onlyChinese and '增益' or BENEFICIAL)
    barValueText:SetChecked(Save.setMaxMinValue)
    barValueText:SetScript('OnMouseDown', function()
        Save.setMaxMinValue= not Save.setMaxMinValue and true or nil
        frame_Init(true)--初始， 或设置
        if Save.setMaxMinValue then
            C_Timer.After(0.3, function()
                for _, info in pairs(Tabs) do
                    local frame= button[info.name]
                    if frame and frame.textValue then
                        frame.textValue:SetText('+12')
                    end
                end
            end)
        end
    end)
    panel.barGreenColor= e.Cstr(panel, {size=20})--20)
    panel.barGreenColor:SetPoint('LEFT', barValueText.text,'RIGHT', 2, 0)
    panel.barGreenColor:EnableMouse(true)
    panel.barGreenColor:SetScript('OnLeave', function(self) e.tips:Hide() end)
    panel.barGreenColor:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '设置' or SETTINGS, self.hex..(e.onlyChinese and '颜色' or COLOR))
        e.tips:Show()
    end)
    panel.barGreenColor:SetText('+12')
    e.HEX_to_RGB(Save.greenColor, panel.barGreenColor)--设置, panel.barGreenColor. r g b hex
    panel.barGreenColor:SetScript('OnMouseDown', function(self)
        local setR, setG, setB, setA
        local R,G,B,A= self.r, self.g, self.b, self.a
        local function func()
            local hex= e.RGB_to_HEX(setR, setG, setB,setA, self)--RGB转HEX
            hex= hex and '|c'..hex or '|cffff8200'
            Save.greenColor= hex
        end
        e.ShowColorPicker(self.r, self.g, self.b,self.a, function()
                setR, setG, setB, setA= e.Get_ColorFrame_RGBA()
                func()
            end, function()
                setR, setG, setB, setA= R,G,B,A
                func()
            end
        )
    end)

    panel.barRedColor= e.Cstr(panel, {size=20})--20)
    panel.barRedColor:SetPoint('LEFT', panel.barGreenColor,'RIGHT', 2, 0)
    panel.barRedColor:EnableMouse(true)
    panel.barRedColor:SetScript('OnLeave', function(self) e.tips:Hide() end)
    panel.barRedColor:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '设置' or SETTINGS, self.hex..(e.onlyChinese and '颜色' or COLOR))
        e.tips:Show()
    end)
    panel.barRedColor:SetText('-12')
    e.HEX_to_RGB(Save.redColor, panel.barRedColor)--设置, panel.barRedColor. r g b hex
    panel.barRedColor:SetScript('OnMouseDown', function(self)
        local setR, setG, setB, setA
        local R,G,B,A= self.r, self.g, self.b, self.a
        local function func()
            local hex= e.RGB_to_HEX(setR, setG, setB,setA, self)--RGB转HEX
            hex= hex and '|c'..hex or '|cffff0000'
            Save.redColor= hex
        end
        e.ShowColorPicker(self.r, self.g, self.b,self.a, function()
                setR, setG, setB, setA= e.Get_ColorFrame_RGBA()
                func()
            end, function()
                setR, setG, setB, setA= R,G,B,A
                func()
            end
        )
    end)

    local check2= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--bar
    check2:SetPoint("TOPLEFT", barValueText, 'BOTTOMLEFT',0,-62)
    check2.text:SetText('Bar')
    check2:SetChecked(Save.bar)
    check2:SetScript('OnMouseDown', function()
        Save.bar= not Save.bar and true or nil
        frame_Init(true)--初始，设置
    end)

    local check3= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--bar，图片，样式2
    check3:SetPoint("LEFT", check2.text, 'RIGHT', 6, 0)
    check3.text:SetText((e.onlyChinese and '格式' or FORMATTING).. ' 2')
    check3:SetChecked(Save.barTexture2)
    check3:SetScript('OnMouseDown', function()
        Save.barTexture2= not Save.barTexture2 and true or nil
        frame_Init(true)--初始，设置
    end)
    local barWidth= CreateFrame("Slider", nil, panel, 'OptionsSliderTemplate')--bar, 宽度
    barWidth:SetPoint("LEFT", check3.text, 'RIGHT', 10, 0)
    barWidth:SetSize(150,20)
    barWidth:SetMinMaxValues(-120,120)
    barWidth:SetValue(Save.barWidth)
    barWidth.Low:SetText((e.onlyChinese and '宽' or WIDE)..' -60')
    barWidth.High:SetText('120')
    barWidth.Text:SetText(Save.barWidth)
    barWidth:SetValueStep(0.1)
    barWidth:SetScript('OnValueChanged', function(self, value, userInput)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.barWidth= value==0 and 0 or value
        frame_Init(true)--初始，设置
    end)

    local barX= CreateFrame("Slider", nil, panel, 'OptionsSliderTemplate')--bar, 宽度
    barX:SetPoint("TOPLEFT", barWidth.Low, 'BOTTOMLEFT', 0, -10)
    barX:SetSize(150,20)
    barX:SetMinMaxValues(-200,200)
    barX:SetValue(Save.barX)
    barX.Low:SetText('x -200')
    barX.High:SetText('+200')
    barX.Text:SetText(Save.barX)
    barX:SetValueStep(1)
    barX:SetScript('OnValueChanged', function(self, value, userInput)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.barX= value==0 and 0 or value
        frame_Init(true)--初始，设置
    end)

    local barToLeft= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--bar 向左
    barToLeft:SetPoint("TOPLEFT", check2, 'BOTTOMLEFT')
    barToLeft.text:SetText(e.onlyChinese and '向左' or BINDING_NAME_STRAFELEFT)
    barToLeft:SetChecked(Save.barToLeft)
    barToLeft:SetScript('OnMouseDown', function()
        Save.barToLeft= not Save.barToLeft and true or nil
        frame_Init(true)--初始， 或设置
    end)

    local slider= CreateFrame("Slider", nil, panel, 'OptionsSliderTemplate')--间隔，上下
    slider:SetPoint("TOPLEFT", barToLeft, 'BOTTOMLEFT', 0,-80)
    --slider:SetOrientation('VERTICAL')--HORIZONTAL --slider.tooltipText=e.onlyChinese and '距离远近' or TRACKER_SORT_PROXIMITY
    slider:SetSize(200,20)
    slider:SetMinMaxValues(-5,10)
    slider:SetValue(Save.vertical)
    slider.Low:SetText('|T450907:0|t-5')
    slider.High:SetText('|T450905:0|t10')
    slider.Text:SetText(Save.vertical)
    slider:SetValueStep(0.1)
    slider:SetScript('OnValueChanged', function(self, value, userInput)
        value= tonumber(format('%.1f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        Save.vertical= value==0 and 0 or value
        frame_Init(true)--初始，设置
    end)

    local slider2= CreateFrame("Slider", nil, panel, 'OptionsSliderTemplate')--间隔，左右
    slider2:SetPoint("TOPLEFT", slider, 'BOTTOMLEFT', 0,-24)
    slider2:SetSize(200,20)
    slider2:SetMinMaxValues(0.1, 20)
    slider2:SetValue(Save.horizontal)
    slider2.Low:SetText('|T450908:0|t 0.1')
    slider2.High:SetText('|T450906:0|t 10')
    slider2.Text:SetText(Save.horizontal)
    slider2:SetValueStep(0.1)
    slider2:SetScript('OnValueChanged', function(self, value, userInput)
        value= tonumber(format('%.1f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        Save.horizontal=value
        frame_Init(true)--初始，设置
    end)

    local slider3= CreateFrame("Slider", nil, panel, 'OptionsSliderTemplate')--文本，截取
    slider3:SetPoint("TOPLEFT", slider2, 'BOTTOMLEFT', 0,-24)
    slider3:SetSize(200,20)
    slider3:SetMinMaxValues(0, 20)
    slider3:SetValue(Save.gsubText or 0)
    slider3.Low:SetText(e.onlyChinese and '文本 0=否' or (LOCALE_TEXT_LABEL..' 0='..NO) )
    slider3.High:SetText((e.onlyChinese and '截取' or BINDING_NAME_SCREENSHOT).. ' 20')
    slider3.Text:SetText(Save.gsubText or '0')
    slider3:SetValueStep(1)
    slider3:SetScript('OnValueChanged', function(self, value, userInput)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.gsubText= value>0 and value or nil
        frame_Init(true)--初始，设置
    end)

    local checkStrupper= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--bar，图片，样式2
    local checkStrlower= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--bar，图片，样式2
    checkStrupper:SetPoint("LEFT", slider3, 'RIGHT')
    checkStrupper.text:SetText('ABC')--大写
    checkStrupper:SetChecked(Save.strupper)
    checkStrupper:SetScript('OnMouseDown', function()
        Save.strupper= not Save.strupper and true or nil
        if Save.strupper then
            Save.strlower=nil
            checkStrlower:SetChecked(false)
        end
        frame_Init(true)--初始，设置
    end)
    checkStrlower:SetPoint("LEFT", checkStrupper.text, 'RIGHT')
    checkStrlower.text:SetText('abc')--小写
    checkStrlower:SetChecked(Save.strlower)
    checkStrlower:SetScript('OnMouseDown', function()
        Save.strlower= not Save.strlower and true or nil
        if Save.strlower then
            Save.strupper=nil
            checkStrupper:SetChecked(false)
        end
        frame_Init(true)--初始，设置
    end)


    local slider4= CreateFrame("Slider", nil, panel, 'OptionsSliderTemplate')--缩放
    slider4:SetPoint("TOPLEFT", slider3, 'BOTTOMLEFT', 0,-24)
    slider4:SetSize(200,20)
    slider4:SetMinMaxValues(0.3, 4)
    slider4:SetValue(Save.scale or 1)
    slider4.Low:SetText((e.onlyChinese and '缩放' or UI_SCALE)..' 0.4')
    slider4.High:SetText('4')
    slider4.Text:SetText(Save.scale or 1)
    slider4:SetValueStep(0.1)
    slider4:SetScript('OnValueChanged', function(self, value, userInput)
        value= tonumber(format('%.1f', value)) or 1
        self:SetValue(value)
        self.Text:SetText(value)
        Save.scale=value
        button.frame:SetScale(value)
    end)

    local sliderButtonAlpha = e.Create_Slider(panel, {min=0, max=1, value=Save.buttonAlpha or 0.3, setp=0.1, color=true,
    text=e.onlyChinese and '专精透明度' or SPECIALIZATION..'('..CHANGE_OPACITY..')',
    func=function(self, value)
        value= tonumber(format('%.1f', value))
        value= value==0 and 0 or value
        self:SetValue(value)
        self.Text:SetText(value)
        Save.buttonAlpha=  value
        set_Show_Hide()--显示， 隐藏
    end})
    sliderButtonAlpha:SetPoint("TOPLEFT", slider4, 'BOTTOMLEFT', 0,-24)

    --[[local restButton= e.Cbtn(panel, {type=false, size={20,20}})--重置
    restButton:SetNormalAtlas('bags-button-autosort-up')
    restButton:SetPoint("TOPRIGHT")
    restButton:SetScript('OnMouseUp', function()
        StaticPopupDialogs[id..addName..'restAllSetup']={
            text =id..'  '..addName..'|n|n|cnRED_FONT_COLOR:'..(e.onlyChinese and '清除全部' or CLEAR_ALL)..'|r '..(e.onlyChinese and '保存' or SAVE)..'|n|n'..(e.onlyChinese and '重新加载UI' or RELOADUI)..' /reload',
            button1 = '|cnRED_FONT_COLOR:'..(e.onlyChinese and '重置' or RESET),
            button2 = e.onlyChinese and '取消' or CANCEL,
            whileDead=true,timeout=30,hideOnEscape = 1,
            OnAccept=function(self)
                Save=nil
                e.Reload()
            end,
        }
        StaticPopup_Show(id..addName..'restAllSetup')
    end)]]

    local hideText= e.Cstr(panel)--隐藏
    hideText:SetPoint('BOTTOMLEFT')
    hideText:SetText(e.onlyChinese and '隐藏' or HIDE)
    local checkHidePet= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--bar，图片，样式2
    checkHidePet:SetPoint("LEFT", hideText, 'RIGHT')
    checkHidePet.text:SetText(e.onlyChinese and '宠物对战' or PET_BATTLE_COMBAT_LOG)
    checkHidePet:SetChecked(Save.hideInPetBattle)
    checkHidePet:SetScript('OnMouseDown', function()
        Save.hideInPetBattle= not Save.hideInPetBattle and true or nil
        set_ShowHide_Event()--显示，隐藏，事件
        button:SetShown(not Save.hideInPetBattle or not C_PetBattles.IsInBattle())
    end)
end


--#######
--发送信息
--#######
local function send_Att_Chat()
    local text=''
    local specIndex= GetSpecialization()
    if specIndex then
        local specID= GetSpecializationInfo(specIndex)
        if specID then
            local specTab= C_SpecializationInfo.GetSpellsDisplay(specID) or {}
            for _, spellID in pairs (specTab) do
                local link= GetSpellLink(spellID)
                if link then
                    text= link
                    break
                end
            end
        end
    end
    text= text.. 'HP'..e.MK(UnitHealthMax('player'), 0)
    for _, info in pairs(Tabs) do
        local frame=button[info.name]
        if not info.hide and info.name~='SPEED' and frame and frame:IsShown() and frame.value and frame.value>0 then
            local value= frame.text:GetText()
            if value then
                text= text..', '..info.text..value
            end
        end
    end
    if ChatEdit_GetActiveWindow() then
        ChatEdit_InsertLink(text)
    else
        local name
        if UnitExists('target') and UnitIsPlayer('target') and not UnitIsUnit('player', 'target') then
            name= GetUnitName('target', true)
        end
        e.Chat(text, name, true)
    end
end


--####
--初始
--####
local function Init()
    button= e.Cbtn(nil, {icon='hide', size={18,18}})

    button:SetFrameLevel(button:GetFrameLevel()+5)
    button.texture= button:CreateTexture(nil, 'BORDER')
    button.texture:SetSize(12,12)
    button.texture:SetPoint('CENTER')
    button.classPortrait= button:CreateTexture(nil, 'OVERLAY', nil)--加个外框
    button.classPortrait:SetAtlas('DK-Base-Rune-CDFill')
    button.classPortrait:SetPoint('CENTER')
    button.classPortrait:SetSize(20,20)
    button.classPortrait:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)

    set_Point()--设置, 位置

    button:RegisterForDrag("RightButton")
    button:SetMovable(true)
    button:SetClampedToScreen(true)

    button:SetScript("OnDragStart", function(self,d)
        if d=='RightButton' and not IsModifierKeyDown() then
            self:StartMoving()
        end
    end)
    button:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save.point={self:GetPoint(1)}
        Save.point[2]=nil
    end)
    button:SetScript("OnMouseDown", function(self,d)
        if d=='LeftButton' then--提示移动
            if not IsAltKeyDown() then
                frame_Init(true)--初始， 或设置
                print(id, addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '重置' or RESET)..'|r', e.onlyChinese and '数值' or STATUS_TEXT_VALUE)
            else
                send_Att_Chat()--发送信息
            end
        elseif d=='RightButton' then
            if not IsModifierKeyDown() then--移动光标
                SetCursor('UI_MOVE_CURSOR')
                print(id, addName, e.onlyChinese and '还原位置' or RESET_POSITION, 'Alt+'..e.Icon.right)

            elseif IsAltKeyDown then
                Save.point=nil
                self:ClearAllPoints()
                set_Point()--设置, 位置
            end
        end
    end)
    button:SetScript('OnMouseWheel', function(self, d)
        if d==1 then
            Save.hide= true
        elseif d==-1 then
            Save.hide= nil
        end
        set_Show_Hide()--显示， 隐藏
    end)
    button:SetScript('OnEnter', function(self)
        local text
        if ChatEdit_GetActiveWindow() then
            text= e.onlyChinese and '编辑' or EDIT
        elseif UnitExists('target') and UnitIsPlayer('target') and not UnitIsUnit('player', 'target') then
            text= (e.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER)..': '.. GetUnitName('target', true)
        elseif not UnitIsDeadOrGhost('player') and IsInInstance() then
            text= (e.onlyChinese and '说' or SAY)
        elseif IsInRaid() then
            text= e.onlyChinese and '说: 团队' or SAY..': '..CHAT_MSG_RAID
        elseif IsInGroup() then
            text= e.onlyChinese and '说: 队伍' or SAY..': '..CHAT_MSG_PARTY
        else
            text= (e.onlyChinese and '说' or SAY)
        end
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '重置' or RESET, e.Icon.left)
        e.tips:AddDoubleLine(text, 'Alt+'..e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
        e.tips:AddDoubleLine(e.GetShowHide(not Save.hide), e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
    end)
    button:SetScript("OnMouseUp", function() ResetCursor() end)
    button:SetScript("OnLeave",function() ResetCursor() e.tips:Hide() end)

    C_Timer.After(4, function()
        button.frame= CreateFrame("Frame",nil,button)
        button.frame:SetPoint('BOTTOM')
        button.frame:SetSize(1,1)
        if Save.scale and Save.scale~=1 then--缩放
            button.frame:SetScale(Save.scale)
        end

        button.frame:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')

        button.frame:RegisterEvent('PLAYER_AVG_ITEM_LEVEL_UPDATE')
        button.frame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
        button.frame:RegisterEvent('PLAYER_TALENT_UPDATE')
        button.frame:RegisterEvent('CHALLENGE_MODE_START')
        button.frame:RegisterEvent('SOCKET_INFO_SUCCESS')
        button.frame:RegisterEvent('SOCKET_INFO_UPDATE')
       -- button.frame:RegisterEvent('PLAYER_LEVEL_CHANGED')

        button.frame:RegisterUnitEvent('UNIT_DEFENSE', "player")
        button.frame:RegisterUnitEvent('UNIT_DAMAGE', 'player')
        button.frame:RegisterUnitEvent('UNIT_RANGEDDAMAGE', 'player')

        button.frame:RegisterUnitEvent('UNIT_AURA', 'player')

        button.frame:SetScript("OnEvent", function(self, event)
            if event=='PLAYER_SPECIALIZATION_CHANGED' then
                set_Tabs()--设置, 内容
                frame_Init(true)--初始， 或设置
            elseif event=='AVOIDANCE_UPDATE'
                or event=='LIFESTEAL_UPDATE'
                or event=='UNIT_DAMAGE'
                or event=='UNIT_DEFENSE'
                or event=='UNIT_RANGEDDAMAGE'
                or event=='UNIT_AURA' then
                frame_Init()--初始， 或设置
            else
                frame_Init(true)--初始， 或设置
            end
        end)
        set_Show_Hide()--显示， 隐藏
        frame_Init(true)--初始， 或设置
        set_Panle_Setting()--设置 panel
    end)
end



panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            Save.vertical= Save.vertical or 3
            Save.horizontal= Save.horizontal or 8
            Save.barWidth= Save.barWidth or 0
            Save.barX= Save.barX or 0
            Save.bit= Save.bit or 0
            Save.bit= Save.bit== 0 and 0
            Save.textColor= Save.textColor or {r=1,g=1,b=1,a=1}
            Save.font= Save.font or {r=0, g=0, b=0, a=1, x=1, y=-1}--阴影
            Save.tab['STAUTS']= Save.tab['STAUTS'] or {}
            Save.tab['STAUTS'].bit= Save.tab['STAUTS'].bit or 3

            --添加控制面板
            panel.name = '|A:charactercreate-icon-customize-body-selected:0:0|a'..(e.onlyChinese and '属性' or STAT_CATEGORY_ATTRIBUTES)--添加新控制面板
            panel.parent =id
            InterfaceOptions_AddCategory(panel)

            e.ReloadPanel({panel=panel, addName= addName, restTips=nil, checked=not Save.disabled, clearTips=nil,--重新加载UI, 重置, 按钮
            disabledfunc=function()
                Save.disabled = not Save.disabled and true or nil
                if not Save.disabled and not button then
                    Init()
                else
                    print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                    frame_Init(true)--初始， 或设置
                end
            end,
            clearfunc= function() Save=nil e.Reload() end}
        )
            --[[panel.check=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
            panel.check:SetChecked(not Save.disabled)
            panel.check:SetPoint('TOPLEFT', panel, 'TOP')
            panel.check.text:SetText(e.onlyChinese and '启用/禁用' or (ENABLE..'/'..DISABLE))
            panel.check:SetScript('OnMouseDown', function()
                Save.disabled = not Save.disabled and true or nil
                if not Save.disabled and not button then
                    Init()
                else
                    print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                    frame_Init(true)--初始， 或设置
                end
            end)
            panel.check:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddLine(e.onlyChinese and '启用/禁用' or ENABLE..'/'..DISABLE)
                e.tips:Show()
            end)
            panel.check:SetScript('OnLeave', function() e.tips:Hide() end)]]

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
                set_ShowHide_Event()--显示，隐藏，事件
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='PET_BATTLE_OPENING_DONE' then
        button:SetShown(false)

    elseif event=='PET_BATTLE_CLOSE' then
        button:SetShown(true)

    elseif event=='PLAYER_ENTERING_WORLD' then
        button:SetShown(not C_PetBattles.IsInBattle())
    end
end)