
local id, e= ...
local Save={
    redColor= '|cnRED_FONT_COLOR:',
    greenColor='|cnGREEN_FONT_COLOR:',
}
local addName= STAT_CATEGORY_ATTRIBUTES
local panel= CreateFrame('Frame')
local button


--#####
--主属性
--#####
local function set_Stat_Text(frame)
    local value= UnitStat('player', frame.primaryStat)
    local text
    if not frame.value or frame.value== value then
        text= e.MK(value, 3)
    elseif frame.value< value then
        text= Save.greenColor..e.MK(value, 3)..'|r'
    else
        text= Save.redColor..e.MK(value, 3)..'|r'
    end
    frame.text:SetText(text)
    return value
end
local function set_Stat_Tooltip(self)
    local frame= self:GetParent()
    e.tips:SetOwner(self, "ANCHOR_LEFT")
    e.tips:ClearLines()
    local stat, effectiveStat, posBuff, negBuff = UnitStat('player', frame.primaryStat);
    local effectiveStatDisplay = BreakUpLargeNumbers(effectiveStat);
    local tooltipText = effectiveStatDisplay
    if posBuff~=0 and negBuff~=0 then
        tooltipText = effectiveStatDisplay;
        if ( posBuff > 0 or negBuff < 0 ) then
            tooltipText = tooltipText.." ("..BreakUpLargeNumbers(stat - posBuff - negBuff)
        end
        if ( posBuff > 0 ) then
            tooltipText = tooltipText..GREEN_FONT_COLOR_CODE.."+"..BreakUpLargeNumbers(posBuff)..FONT_COLOR_CODE_CLOSE;
        end
        if ( negBuff < 0 ) then
            tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..BreakUpLargeNumbers(negBuff)..FONT_COLOR_CODE_CLOSE;
        end
        if ( posBuff > 0 or negBuff < 0 ) then
            tooltipText = tooltipText..")"
        end
    end
    e.tips:AddDoubleLine(frame.name, tooltipText)

    local _, unitClass = UnitClass("player");
    unitClass = strupper(unitClass);
    local primaryStat, spec, role;
    spec = GetSpecialization();
    if (spec) then
        role = GetSpecializationRole(spec);
        primaryStat = select(6, GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player")));
    end
    if frame.primaryStat==1 then-- Strength
        local text= ''
        local attackPower = GetAttackPowerForStat(frame.index, effectiveStat);
        if (HasAPEffectsSpellPower()) then
            text= e.onlyChinse and '提高你的攻击和技能强度' or STAT_TOOLTIP_BONUS_AP_SP
        end
        if (not primaryStat or primaryStat == LE_UNIT_STAT_STRENGTH) then
            text= text..' '.. BreakUpLargeNumbers(attackPower)
            if ( role == "TANK" ) then
                local increasedParryChance = GetParryChanceFromAttribute();
                if ( increasedParryChance > 0 ) then
                    CR_PARRY_BASE_STAT_TOOLTIP = "招架几率提高%.2f%%|n|cff888888（在效果递减之前）|r"

                    text= text..'\n'..format(e.onlyChinse and '"招架几率提高%.2f%%|n|cff888888（在效果递减之前）|r"' or CR_PARRY_BASE_STAT_TOOLTIP, increasedParryChance);
                end
            end
        else
            text= e.onlyChinse and "|cff808080该属性不能使你获益|r" or STAT_NO_BENEFIT_TOOLTIP
        end
        e.tips:AddDoubleLine(text,nil,nil,nil,true)
    elseif frame.primaryStat==2 then-- Agility
        local text=''
        if (not primaryStat or primaryStat == LE_UNIT_STAT_AGILITY) then
            if HasAPEffectsSpellPower() then
                text= e.onlyChinse and '提高你的攻击和技能强度' or  STAT_TOOLTIP_BONUS_AP_SP
            else
                text= e.onlyChinse and '提高你的攻击和技能强度' or STAT_TOOLTIP_BONUS_AP
            end
            if ( role == "TANK" ) then
                local increasedDodgeChance = GetDodgeChanceFromAttribute();
                if ( increasedDodgeChance > 0 ) then
                    text= text .."|n"..format(e.onlyChinse and '躲闪几率提高%.2f%%|n|cff888888（在效果递减之前）|r' or CR_DODGE_BASE_STAT_TOOLTIP, increasedDodgeChance);
                end
            end
        else
            text= e.onlyChinse and "|cff808080该属性不能使你获益|r" or STAT_NO_BENEFIT_TOOLTIP
        end
        e.tips:AddDoubleLine(text,nil,nil,nil,true)

    elseif frame.primaryStat==3 then
        local text
        if ( HasAPEffectsSpellPower() ) then
            text= e.onlyChinse and "|cff808080该属性不能使你获益|r" or STAT_NO_BENEFIT_TOOLTIP
        elseif ( HasSPEffectsAttackPower() ) then
            text= e.onlyChinse and '提高你的攻击和技能强度' or  STAT_TOOLTIP_BONUS_AP_SP
        elseif ( not primaryStat or primaryStat == LE_UNIT_STAT_INTELLECT ) then
            text= (e.onlyChinse and '提高你的法术强度' or DEFAULT_STAT4_TOOLTIP).. effectiveStat
        else
            text= e.onlyChinse and "|cff808080该属性不能使你获益|r" or STAT_NO_BENEFIT_TOOLTIP
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
local function set_Crit_Text(frame)
    local critChance
	local spellCrit = frame.minCrit
	local rangedCrit = GetRangedCritChance();
	local meleeCrit = GetCritChance();
	if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
		critChance = spellCrit
	elseif (rangedCrit >= meleeCrit) then
		critChance = rangedCrit
	else
		critChance = meleeCrit
	end
    if not frame.value or frame.value== critChance then
        frame.text:SetFormattedText('%d%%', critChance + 0.5)
    elseif frame.value< critChance then
        frame.text:SetFormattedText(Save.greenColor..'%d%%', critChance + 0.5)
    else
        frame.text:SetFormattedText(Save.redColor..'%d%%', critChance + 0.5)
    end
    return critChance
end
local function set_Crit_Tooltip(self)
    local frame= self:GetParent()
    e.tips:SetOwner(self, "ANCHOR_LEFT")
    e.tips:ClearLines()
    local spellCrit = frame.minCrit
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
    e.tips:AddDoubleLine(frame.name, format('%d%%', critChance + 0.5))

	local extraCritChance = GetCombatRatingBonus(rating);
	local extraCritRating = GetCombatRating(rating);
	if (GetCritChanceProvidesParryEffect()) then
        if e.onlyChinse then
            e.tips:AddLine(format("攻击和法术造成额外效果的几率。\n爆击：%s [+%.2f%%]\n招架几率提高%.2f%%。", BreakUpLargeNumbers(extraCritRating), extraCritChance, GetCombatRatingBonusForCombatRatingValue(CR_PARRY, extraCritRating)), nil,nil,nil,true)
        else
            e.tips:AddLine(format(CR_CRIT_PARRY_RATING_TOOLTIP, BreakUpLargeNumbers(extraCritRating), extraCritChance, GetCombatRatingBonusForCombatRatingValue(CR_PARRY, extraCritRating)), nil,nil,nil,true)
        end
	else
        if e.onlyChinse then
		    e.tips:AddLine(format( "攻击和法术造成额外效果的几率。\n爆击：%s [+%.2f%%]", BreakUpLargeNumbers(extraCritRating), extraCritChance), nil,nil,nil,true)
        else
            e.tips:AddLine(format(CR_CRIT_TOOLTIP, BreakUpLargeNumbers(extraCritRating), extraCritChance), nil,nil,nil,true)
        end
	end
    if frame.value and frame.value~=critChance then
        e.tips:AddLine(' ')
        local text
        if frame.value< critChance then
            text= Save.greenColor..'+ '..format('%.2f%%', critChance- frame.value)
        else
            text= Save.redColor..'- '..format('%.2f%%', frame.value- critChance)
        end
        e.tips:AddDoubleLine(format('%.2f%%', frame.value + 0.5), text)
    end
    e.tips:Show()
end

--####
--急速
--####
local function set_Haste_Text(frame)
	local haste = GetHaste()
    if not frame.value or frame.value== haste then
        frame.text:SetFormattedText('%d%%', haste + 0.5)
    elseif frame.value< haste then
        frame.text:SetFormattedText(Save.greenColor..'%d%%', haste + 0.5)
    else
        frame.text:SetFormattedText(Save.redColor..'%d%%', haste + 0.5)
    end
    return haste
end
local function set_Haste_Tooltip(self)
    local frame= self:GetParent()
    e.tips:SetOwner(self, "ANCHOR_LEFT")
    e.tips:ClearLines()

    local haste = GetHaste();
	local rating = CR_HASTE_MELEE;

	local hasteFormatString;
	if (haste < 0 and not GetPVPGearStatRules()) then
		hasteFormatString = RED_FONT_COLOR_CODE.."%s"..FONT_COLOR_CODE_CLOSE;
	else
		hasteFormatString = "%s";
	end
	e.tips:AddDoubleLine(frame.name, format(hasteFormatString, format("%d%%", haste + 0.5)))
	e.tips:AddLine(_G["STAT_HASTE_"..e.Player.class.."_TOOLTIP"] or (e.onlyChinse and '提高攻击速度和施法速度。' or STAT_HASTE_TOOLTIP), nil, nil,nil,true)
	e.tips:AddDoubleLine(format(e.onlyChinse and '急速：%s [+%.2f%%]' or STAT_HASTE_BASE_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(rating)), GetCombatRatingBonus(rating)))
    if frame.value and frame.value~=haste then
        e.tips:AddLine(' ')
        local text
        if frame.value< haste then
            text= Save.greenColor..'+ '..format('%.2f%%', haste- frame.value)
        else
            text= Save.redColor..'- '..format('%.2f%%', frame.value- haste)
        end
        e.tips:AddDoubleLine(format('%.2f%%', frame.value + 0.5), text)
    end
    e.tips:Show()
end

--####
--精通
--####
local function set_Mastery_Text(frame)
	local mastery = GetMasteryEffect();
    if not frame.value or frame.value== mastery then
        frame.text:SetFormattedText('%d%%', mastery + 0.5)
    elseif frame.value< mastery then
        frame.text:SetFormattedText(Save.greenColor..'%d%%', mastery + 0.5)
    else
        frame.text:SetFormattedText(Save.redColor..'%d%%', mastery + 0.5)
    end
    return mastery
end

--####
--全能
--####
local function set_Versatility_Text(frame)
    local versatilityDamageBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
    if not frame.value or frame.value== versatilityDamageBonus then
        frame.text:SetFormattedText('%d%%', versatilityDamageBonus + 0.5)
    elseif frame.value< versatilityDamageBonus then
        frame.text:SetFormattedText(Save.greenColor..'%d%%', versatilityDamageBonus + 0.5)
    else
        frame.text:SetFormattedText(Save.redColor..'%d%%', versatilityDamageBonus + 0.5)
    end
    return versatilityDamageBonus
end
local function set_Versatility_Tooltip(self)
    local frame= self:GetParent()
    e.tips:SetOwner(self, "ANCHOR_LEFT")
    e.tips:ClearLines()
    local versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE);
	local versatilityDamageBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE);
	local versatilityDamageTakenReduction = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN);
    e.tips:AddLine(frame.name)
	e.tips:AddLine(format(e.onlyChinse and "造成的伤害值和治疗量提高%.2f%%，\n受到的伤害降低%.2f%%。\n全能：%s [%.2f%%/%.2f%%]" or CR_VERSATILITY_TOOLTIP, versatilityDamageBonus, versatilityDamageTakenReduction, BreakUpLargeNumbers(versatility), versatilityDamageBonus, versatilityDamageTakenReduction), nil,nil,nil,true)
    if frame.value and frame.value~=versatilityDamageBonus then
        e.tips:AddLine(' ')
        local text
        if frame.value< versatilityDamageBonus then
            text= Save.greenColor..'+ '..format('%.2f%%', versatilityDamageBonus- frame.value)
        else
            text= Save.redColor..'- '..format('%.2f%%', frame.value- versatilityDamageBonus)
        end
        e.tips:AddDoubleLine(format('%.2f%%', frame.value + 0.5), text)
    end
    e.tips:Show()
end



local Tabs
local function set_Tabs()
    Tabs={
        {name='STATUS', r=e.Player.r, g=e.Player.g, b=e.Player.b, a=1, text= {
                [1]= e.onlyChinse and '力量' or SPEC_FRAME_PRIMARY_STAT_STRENGTH,
                [2]= e.onlyChinse and '敏捷' or SPEC_FRAME_PRIMARY_STAT_AGILITY,
                [3]= e.onlyChinse and '智力' or SPEC_FRAME_PRIMARY_STAT_INTELLECT,
            }
        },
        {name= 'CRITCHANCE', r=0.82, g=0.2, b=0, text= e.onlyChinse and '爆击' or STAT_CRITICAL_STRIKE},
        {name= 'HASTE', r=0.2, g=0.82, b=0.2, text= e.onlyChinse and '急速' or STAT_HASTE},
        {name= 'MASTERY', r=0.82, g=0, b=0.82, text= e.onlyChinse and '精通' or STAT_MASTERY},
        {name= 'VERSATILITY', r=0, g=1, b=0.82, text= e.onlyChinse and '全能' or STAT_VERSATILITY},
    }
end

local function set_OnEvent(frame)
    frame.value=nil
    local name
    if frame.index==1 then
        frame.primaryStat= select(6, GetSpecializationInfo(GetSpecialization(), nil, nil, nil, UnitSex("player")))
        name= Tabs[frame.index]['text'][frame.primaryStat]
        frame.value= set_Stat_Text(frame)
        frame:SetScript('OnEvent', set_Stat_Text)
        frame.label:SetScript('OnEnter', set_Stat_Tooltip)
        frame.text:SetScript('OnEnter', set_Stat_Tooltip)

    else
        name= Tabs[frame.index].text
        if frame.index==2 then--爆击
            local holySchool = 2;
            local minCrit = GetSpellCritChance(holySchool);
            local spellCrit;
            for i=(holySchool+1), MAX_SPELL_SCHOOLS do
                spellCrit = GetSpellCritChance(i);
                minCrit = min(minCrit, spellCrit);
            end
            frame.minCrit = minCrit
            frame.value= set_Crit_Text(frame)
            frame:SetScript('OnEvent', set_Crit_Text)
            frame.label:SetScript('OnEnter', set_Crit_Tooltip)
            frame.text:SetScript('OnEnter', set_Crit_Tooltip)

        elseif frame.index==3 then--急速
            frame.value= set_Haste_Text(frame)
            frame:SetScript('OnEvent', set_Haste_Text)
            frame.label:SetScript('OnEnter', set_Haste_Tooltip)
            frame.text:SetScript('OnEnter', set_Haste_Tooltip)

        elseif frame.index==4 then--精通
            frame.value= set_Mastery_Text(frame)
            frame.onEnterFunc = Mastery_OnEnter;
            frame.label:SetScript('OnEnter', frame.onEnterFunc)--PaperDollFrame.lua
            frame.text:SetScript('OnEnter', frame.onEnterFunc)

        elseif frame.index==5 then--全能
            frame.value= set_Versatility_Text(frame)
            frame:SetScript('OnEvent', set_Versatility_Text)
            frame.label:SetScript('OnEnter', set_Versatility_Tooltip)
            frame.text:SetScript('OnEnter', set_Versatility_Tooltip)

        end
    end

    frame.name= name
    frame.label:SetText(name)
end

local function create_Rest_Lable()
    local last
    for index, info in pairs(Tabs) do
        local frame= button[info.name]
        if not frame then
            frame= CreateFrame('Frame', nil, button)
            frame:SetPoint('TOPRIGHT', last or button, 'BOTTOMRIGHT')
            frame:SetSize(1,12)
            frame:RegisterUnitEvent('UNIT_DAMAGE', 'player')

            frame.label= e.Cstr(frame, nil, nil, nil, {info.r,info.g,info.b,info.a}, nil, 'RIGHT')
            frame.label:SetPoint('TOPRIGHT')
            frame.label:EnableMouse(true)
            frame.label:SetScript('OnLeave', function() e.tips:Hide() end)

            frame.text= e.Cstr(frame, nil, nil, nil, {1,1,1}, nil, 'LEFT')
            frame.text:SetPoint('TOPLEFT', frame, 'TOPRIGHT')
            frame.text:EnableMouse(true)
            frame.text:SetScript('OnLeave', function() e.tips:Hide() end)

            frame.index= index
            last= frame
            button[info.name]= frame
            
        end
        set_OnEvent(frame)
    end
end

--####
--初始
--####
local function Init()
    --##########
    --设置 panel
    --##########
    panel.name = (e.onlyChinse and '属性' or STAT_CATEGORY_ATTRIBUTES)..'|A:charactercreate-icon-customize-body-selected:0:0|a'--添加新控制面板
    panel.parent =id
    InterfaceOptions_AddCategory(panel)

    --e.Cbtn= function(self, Template, value, SecureAction, name, notTexture, size)
    button= e.Cbtn(nil, nil, nil, nil, nil, true, {18,18})
    if Save.point then
        button:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
    else
        button:SetPoint('LEFT', 80, 180)
    end
    button:RegisterForDrag("RightButton")
    button:SetMovable(true)
    button:SetClampedToScreen(true)

    button:SetScript("OnDragStart", function(self,d )
        if d=='RightButton' then
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
            create_Rest_Lable()
            print(id, addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinse and '重置' or RESET)..'|r', e.onlyChinse and '数值' or STATUS_TEXT_VALUE)

        elseif d=='RightButton' then--移动光标
            SetCursor('UI_MOVE_CURSOR')

        end
    end)
    button:SetScript("OnMouseUp", function() ResetCursor() end)
    button:SetScript("OnLeave",function() ResetCursor() e.tips:Hide() end)
    button:SetScript('OnMouseWheel', function(self, d)--缩放
        local sacle=Save.scale or 1
        if d==1 then
            sacle=sacle+0.1
        elseif d==-1 then
            sacle=sacle-0.1
        end
        if sacle>3 then
            sacle=3
        elseif sacle<0.6 then
            sacle=0.6
        end
        
        self:SetScale(sacle)
        Save.scale=sacle
    end)
    button:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinse and '重置' or RESET, e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinse and '移动' or NPE_MOVE, e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinse and '缩放' or UI_SCALE)..': '..(Save.scale or 1), e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
    end)


    

    if Save.scale and Save.scale~=1 then--缩放
        button:SetScale(Save.scale)
    end

    set_Tabs()--设置, 内容

    C_Timer.After(2, create_Rest_Lable)
end


panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板        
            local check= e.CPanel((e.onlyChinse and '属性' or STAT_CATEGORY_ATTRIBUTES)..'|A:charactercreate-icon-customize-body-selected:0:0|a', not Save.disabled)
            check:SetScript('OnMouseDown', function()
                Save.disabled = not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需求重新加载' or REQUIRES_RELOAD)
            end)
            --[[check:SetScript('OnEnter', function(self2)
                local name, description, filedataid= C_ChallengeMode.GetAffixInfo(13)
                if name and description then
                    e.tips:SetOwner(self2, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:AddDoubleLine(name, filedataid and '|T'..filedataid ..':0|t' or ' ')
                    e.tips:AddLine(description, nil,nil,nil,true)
                    e.tips:Show()
                end
            end)
            check:SetScript('OnLeave', function() e.tips:Hide() end)]]
            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)