local id, e= ...

WoWTools_AttributesMixin={
Save={
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

        ["SPEED"]= {r=1, g=0.82, b=0},--, current=true},--移动
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
    --disabledDragonridingSpeed=true,--禁用，驭空术UI，速度
    --disabledVehicleSpeed=true, --禁用，载具，速度

    hideInPetBattle=true,--宠物战斗中, 隐藏
    buttonAlpha=0.3,--专精，图标，透明度
    --hide=false,--显示，隐藏
    --gsubText
    --strlower
    --strupper
    showBG=e.Player.husandro,

}
}


local function Save()
    return WoWTools_AttributesMixin.Save
end



local addName-- STAT_CATEGORY_ATTRIBUTES--PaperDollFrame.lua
local panel= CreateFrame('Frame')
local button, Role, PrimaryStat, Tabs
local RedColor--变小值
local GreenColor--变大值





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

        {name= 'CRITCHANCE', text= e.onlyChinese and '爆击' or STAT_CRITICAL_STRIKE, bar=true, dps=true, textValue=true, zeroShow=true},
        {name= 'HASTE', text= e.onlyChinese and '急速' or STAT_HASTE, bar=true, dps=true, textValue=true, zeroShow=true},
        {name= 'MASTERY', text= e.onlyChinese and '精通' or STAT_MASTERY, bar=true, dps=true, textValue=true, zeroShow=true},
        {name= 'VERSATILITY', text= e.onlyChinese and '全能' or STAT_VERSATILITY, bar=true, dps=true, textValue=true, zeroShow=true},--5

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
        if not Save().tab[info.name]then
            Save().tab[info.name]={name= info.name}
        end
        Tabs[index].r= index==1 and e.Player.r or Save().tab[info.name].r or 1
        Tabs[index].g= index==1 and e.Player.g or Save().tab[info.name].g or 0.82
        Tabs[index].b= index==1 and e.Player.b or Save().tab[info.name].b or 0
        Tabs[index].a= index==1 and 1 or Save().tab[info.name].a or 1
        Tabs[index].useNumber=info.name=='STATUS' and true
                            or Tabs[index].usePercent and nil
                            or (Save().useNumber and not Tabs[index].usePercent ) and true
                            or Tabs[index].useNumber
        Tabs[index].bit= Save().tab[info.name].bit or Save().bit or 0
        --Tabs[index].current= Save().tab[info.name].current
        Tabs[index].damageAndDefense= Save().tab[info.name].damageAndDefense
        Tabs[index].onlyDefense= Save().tab[info.name].onlyDefense
        Tabs[index].bar= Save().tab[info.name].bar and true or (Save().bar and Tabs[index].bar)
        Tabs[index].textValue= Save().setMaxMinValue and Tabs[index].textValue or false

        Tabs[index].hide= Save().tab[info.name].hide
        Tabs[index].zeroShow= info.zeroShow--等于0， 时也要显示
        if not Tabs[index].hide then
            if info.name=='STAGGER' and (e.Player.class~='MONK' or Role~='TANK') then--武僧, 醉拳
                Tabs[index].hide= true
            elseif info.dps then--四属性, DPS
                if Role~='DAMAGER' and Role~='HEALER' and Save().onlyDPS then
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
    value= value>0 and value or 0
    if not frame.value or ((frame.value==0 or value==0) and not frame.zeroShow)  then
        frame.value= value
    end

    if not Save().notText then
        local text
        if value<1 and not frame.zeroShow then
            text= ''
        else
            if frame.useNumber then
                if frame.bit==0 then
                    text= BreakUpLargeNumbers(value)..(value2 and '/'..BreakUpLargeNumbers(value) or '')
                else
                    text= WoWTools_Mixin:MK(value, frame.bit)..( value2 and '/'..WoWTools_Mixin:MK(value2, frame.bit) or '')
                end

            else
                if value2 then
                    text= format('%.'..frame.bit..'f/%.'..frame.bit..'f%%', value, value2)
                else
                    text= format('%.'..frame.bit..'f%%', value)
                end
            end
            if frame.value< value then
                text= Save().greenColor..text
            elseif frame.value> value then
                text= Save().redColor..text
            end
        end
        frame.text:SetText(text)
    end


    if frame.bar and frame.bar:GetAlpha()>0 then
        if frame.value== value or (value<1 and not frame.zeroShow) then
            frame.bar:SetStatusBarColor(frame.r, frame.g, frame.b, frame.a)
            frame.bar:SetValue(value)
            frame.barTexture:SetShown(false)
            frame.barTextureSpark:SetShown(false)
        else
            if frame.value< value then
                frame.bar:SetStatusBarColor(GreenColor.r, GreenColor.g, GreenColor.b, GreenColor.a)
            else
                frame.bar:SetStatusBarColor(RedColor.r, RedColor.g, RedColor.b, RedColor.a)
            end
            frame.bar:SetValue(value)
            if frame.useNumber then
                frame.barTexture:SetWidth(frame.bar:GetWidth()*(frame.value/frame.bar.maxValue))
            else
                frame.barTexture:SetWidth(frame.bar:GetWidth()*(frame.value/100))
            end
            frame.barTexture:SetShown(true)

            frame.barTextureSpark:ClearAllPoints()
            if Save().barToLeft then
                frame.barTextureSpark:SetPoint('LEFT', frame.barTexture,-3,0)
            else
                frame.barTextureSpark:SetPoint('RIGHT', frame.barTexture, 3,0)
            end
            frame.barTextureSpark:SetShown(true)
        end
    end

    if frame.textValue and frame.textValue:IsShown() then
        if frame.value== value or (value<1 and not frame.zeroShow) then
            frame.textValue:SetText('')
        else
            local text, icon
            if frame.value< value then--加
                if frame.useNumber then
                    icon, text= '|A:UI-HUD-Minimap-Zoom-In:8:8|a', WoWTools_Mixin:MK(value-frame.value, frame.bit)
                else
                    icon, text= '|A:UI-HUD-Minimap-Zoom-In:8:8|a', format('%.'..frame.bit..'f', value-frame.value)
                end
            else--减
                if frame.useNumber then
                    icon, text= '|A:UI-HUD-Minimap-Zoom-Out:6:6|a', WoWTools_Mixin:MK(frame.value-value, frame.bit)
                else
                    icon, text= '|A:UI-HUD-Minimap-Zoom-Out:8:8|a', format('%.'..frame.bit..'f', frame.value-value)
                end
            end
            if frame.bar and frame.bar:IsShown() then
                if Save().barToLeft then
                    text= text..icon
                else
                    text= icon..text
                end
            else
                if Save().toLeft then
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
                if Save().barToLeft then
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
    if Save().useNumber then
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


--####
--急速
--####
local function set_HASTE_Text(frame)
    local haste
    if Save().useNumber then
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


--####
--精通
--PaperDollFrame.lua
local function set_MASTERY_Text(frame)
    local mastery
    if Save().useNumber then
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
    if Save().useNumber then
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


--####
--吸血, 6
--####
local function set_LIFESTEAL_Text(frame)
    local lifesteal
    if Save().useNumber then
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


--####
--闪避, 7
--####
local function set_AVOIDANCE_Text(frame)
    local avoidance
    if Save().useNumber then
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

--####
--躲闪, 8
--####
local function set_DODGE_Text(frame)
    local chance
    if Save().useNumber then
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


--####
--护甲
--####
local function set_ARMOR_Text(frame)
    local value, value2
    local baselineArmor, effectiveArmor, armor, bonusArmor = UnitArmor('player')
    if Save().useNumber then
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


--####
--招架
--####
local function set_PARRY_Text(frame)
    local chance
    if Save().useNumber then
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


--####
--格挡
--####
local function set_BLOCK_Text(frame)
    local chance
    if Save().useNumber then
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


--####
--醉拳
--####
local function set_STAGGER_Text(frame)
    local stagger, staggerAgainstTarget = C_PaperDollInfo.GetStaggerPercentage('player')
    set_Text_Value(frame, stagger, staggerAgainstTarget)--设置，当前值
end




--####
--移动
--####
local function set_SPEED_Text(frame, elapsed)
    frame.elapsed= (frame.elapsed or 0.3) + elapsed
    if frame.elapsed > 0.3 then
        frame.elapsed= 0
        local value
        local isGliding, _, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
        if isGliding and forwardSpeed then
            value= forwardSpeed
            -- local unit= PlayerFrame.displayedUnit or PlayerFrame.unit or 'player'
        elseif UnitInVehicle('player') then
            value= GetUnitSpeed('vehicle')
        else
            value= GetUnitSpeed('player')
        end
        if value==0 then
            frame.text:SetText('')
        else
            frame.text:SetFormattedText('%.0f%%', value*100/BASE_MOVEMENT_SPEED)
        end
    end
end





local function set_Shadow(self)--设置，字体阴影
    if self then
        self:SetShadowColor(Save().font.r, Save().font.g, Save().font.b, Save().font.a)
        self:SetShadowOffset(Save().font.x, Save().font.y)
    end
end


















local function set_Frame(frame, rest)--设置, frame
    if rest then
        --frame, 数值
        frame:SetSize(Save().horizontal, 12+ (Save().vertical or 3))--设置，大小

        --名称
        frame.label:ClearAllPoints()
        if Save().toLeft then
            frame.label:SetPoint('LEFT', frame, 'RIGHT',-5,0)
        else
            frame.label:SetPoint('RIGHT', frame, 'LEFT', 5,0)
        end

        local text= frame.nameText
        if Save().strupper then--大写
            text= strupper(text)
        elseif Save().strlower then--小写
            text= strlower(text)
        end
        if Save().gsubText then--文本，截取
            text= WoWTools_TextMixin:sub(text, Save().gsubText)
        end
        frame.label:SetText(text or '')

        --数值,text
        frame.text:ClearAllPoints()
        if Save().toLeft then
            frame.text:SetPoint('RIGHT', frame, 'LEFT', 5,0)
        else
            frame.text:SetPoint('LEFT', frame, 'RIGHT',-5,0)
        end

        if Save().toLeft then
            frame.label:SetJustifyH('LEFT')
            frame.text:SetJustifyH('RIGHT')
        else
            frame.label:SetJustifyH('RIGHT')
            frame.text:SetJustifyH('LEFT')
        end
        set_Shadow(frame.label)--设置，字体阴影
        set_Shadow(frame.text)--设置，字体阴影

--背景
        if Save().showBG then
            frame.bg:ClearAllPoints()
            if Save().toLeft then
                frame.bg:SetPoint('TOPRIGHT', frame.label, 1, 1)
                frame.bg:SetPoint('BOTTOM', frame.label, 0, -1)
                frame.bg:SetPoint('LEFT', frame.text, -1, 0)
            else
                frame.bg:SetPoint('TOPLEFT', frame.label, -1, 1)
                frame.bg:SetPoint('BOTTOM', frame.label, 0, -1)
                frame.bg:SetPoint('RIGHT', frame.text, 1, 0)
            end
            frame.bg:SetShown(true)
        else
            frame.bg:SetShown(false)
        end


        if frame.isBar then
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
            frame.bar:SetSize(120+Save().barWidth, 10)
            frame.bar:ClearAllPoints()
            if Save().barToLeft then
                frame.bar:SetPoint('RIGHT', frame, 'LEFT', -(Save().barX), 0)
                frame.bar:SetReverseFill(true)
            else
                frame.bar:SetPoint('LEFT', frame, 'RIGHT', Save().barX, 0)
                frame.bar:SetReverseFill(false)
            end

            if Save().barTexture2 then
                frame.bar:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')
            else
                frame.bar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')
            end

            frame.barTexture:ClearAllPoints()
            if Save().barToLeft then
                frame.barTexture:SetPoint('RIGHT')
            else
                frame.barTexture:SetPoint('LEFT')
            end
            frame.barTexture:SetSize(frame.bar:GetWidth(), 10)
        end

        if frame.textValue then--数值 + -
            frame.textValue:ClearAllPoints()
            frame.textValue:SetTextColor(frame.r,frame.g,frame.b,frame.a)
            if not Save().notText then
                if Save().toLeft then
                    frame.textValue:SetPoint('RIGHT', frame.text, 'LEFT')--, -30-(frame.bit*6), 0)
                else
                    frame.textValue:SetPoint('LEFT', frame.text, 'RIGHT')--, 30+(frame.bit*6), 0)
                end
            else--不显示，数值
                if Save().toLeft then
                    frame.text:SetPoint('RIGHT', frame, 'LEFT')
                else
                    frame.text:SetPoint('LEFT', frame, 'RIGHT')
                end
            end
            frame.textValue:SetShown(Save().setMaxMinValue)
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










--初始， 或设置
local function Frame_Init(rest)
    if rest or not Tabs then
        set_Tabs()
    end

    local last= button.frame
    for _, info in pairs(Tabs) do
        local frame, find= button[info.name], nil
        if not info.hide then
            if not frame then
                frame= CreateFrame('Frame', nil, button.frame)

                frame.label= WoWTools_LabelMixin:Create(frame, {mouse=true, color={r=info.r, g=info.g,b=info.b, a=info.a}})--nil, nil, nil, {info.r,info.g,info.b,info.a}, nil)
                frame.label:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)

                frame.text= WoWTools_LabelMixin:Create(frame, {mouse=true, color={r=1,g=1,b=1}, justifyH= Save().toLeft and 'RIGHT'})--nil, nil, nil, {1,1,1}, nil, Save().toLeft and 'RIGHT' or 'LEFT')
                

                frame.bg= frame:CreateTexture(nil, 'BACKGROUND')
                frame.bg:SetAlpha(0.5)
                frame.bg:SetAtlas('UI-Frame-DialogBox-BackgroundTile')

                if info.name=='STATUS' then--主属性1
                    frame:RegisterUnitEvent('UNIT_STATS', 'player')
                    frame:SetScript('OnEvent', set_STATUS_Text)

                --elseif info.name=='CRITCHANCE' then--爆击2
                    --frame.label:SetScript('OnEnter', set_CRITCHANCE_Tooltip)
                    --frame.text:SetScript('OnEnter', set_CRITCHANCE_Tooltip)

                elseif info.name=='HASTE' then--急速3
                    frame:RegisterUnitEvent('UNIT_SPELL_HASTE', 'player')
                    frame:SetScript('OnEvent', set_HASTE_Text)
                    --frame.label:SetScript('OnEnter', set_HASTE_Tooltip)
                    --frame.text:SetScript('OnEnter', set_HASTE_Tooltip)

                elseif info.name=='MASTERY' then--精通4
                    frame:RegisterEvent('MASTERY_UPDATE')
                    frame.onEnterFunc = Mastery_OnEnter;
                    --frame.label:SetScript('OnEnter', frame.onEnterFunc)--PaperDollFrame.lua
                    --frame.text:SetScript('OnEnter', frame.onEnterFunc)

                --[[elseif info.name=='VERSATILITY' then--全能5
                    frame.label:SetScript('OnEnter', set_VERSATILITY_Tooltip)
                    frame.text:SetScript('OnEnter', set_VERSATILITY_Tooltip)]]

                elseif info.name=='LIFESTEAL' then--吸血6
                    button.frame:RegisterEvent('LIFESTEAL_UPDATE')
                    --frame.label:SetScript('OnEnter', set_LIFESTEAL_Tooltip)
                    --frame.text:SetScript('OnEnter', set_LIFESTEAL_Tooltip)

                elseif info.name=='ARMOR' then--护甲
                    frame:RegisterEvent('PLAYER_TARGET_CHANGED')
                    frame:SetScript('OnEvent', set_ARMOR_Text)
                    --frame.label:SetScript('OnEnter', set_ARMOR_Tooltip)
                    --frame.text:SetScript('OnEnter', set_ARMOR_Tooltip)

                elseif info.name=='AVOIDANCE' then--闪避7
                    button.frame:RegisterEvent('AVOIDANCE_UPDATE')
                    --frame.label:SetScript('OnEnter', set_AVOIDANCE_Tooltip)
                    --frame.text:SetScript('OnEnter', set_AVOIDANCE_Tooltip)

                --elseif info.name=='DODGE' then--躲闪8
                    --frame.label:SetScript('OnEnter', set_DODGE_Tooltip)
                    --frame.text:SetScript('OnEnter', set_DODGE_Tooltip)

                --[[elseif info.name=='PARRY' then--招架9
                    frame.label:SetScript('OnEnter', set_PARRY_Tooltip)
                    frame.text:SetScript('OnEnter', set_PARRY_Tooltip)]]

                --[[elseif info.name=='BLOCK' then--格挡10
                    frame.label:SetScript('OnEnter', set_BLOCK_Tooltip)
                    frame.text:SetScript('OnEnter', set_BLOCK_Tooltip)]]

                elseif info.name=='STAGGER' then--醉拳11
                    frame:RegisterEvent('PLAYER_TARGET_CHANGED')
                    frame:SetScript('OnEvent', set_STAGGER_Text)
                    --frame.label:SetScript('OnEnter', set_STAGGER_Tooltip)
                    --frame.text:SetScript('OnEnter', set_STAGGER_Tooltip)

                elseif info.name=='SPEED' then--移动12
                    frame:HookScript('OnUpdate', set_SPEED_Text)
                    --frame.label:SetScript('OnEnter', set_SPEED_Tooltip)
                    --frame.text:SetScript('OnEnter', set_SPEED_Tooltip)
                end
                --frame.label:HookScript('OnEnter', function(self2) self2:SetAlpha(0.3) end)
                --frame.text:HookScript('OnEnter', function(self2) self2:SetAlpha(0.3) end)

                if frame.onEnterFunc then
                    frame.label:SetScript('OnEnter', frame.onEnterFunc)--PaperDollFrame.lua
                    frame.text:SetScript('OnEnter', frame.onEnterFunc)
                else
                    frame.label:SetScript('OnEnter', function(self)
                        WoWTools_AttributesMixin:Set_Tooltips(self:GetParent(), self)
                        self:SetAlpha(0.3)
                    end)
                    frame.text:SetScript('OnEnter', function(self)
                        WoWTools_AttributesMixin:Set_Tooltips(self:GetParent(), self)
                        self:SetAlpha(0.3)
                    end)
                end
                frame.text:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
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
                frame.isBar= info.bar
                if frame.bar then
                    frame.bar:SetAlpha(info.bar and 1 or 0)
                    frame.barTextureSpark:SetShown(false)
                end

                if info.textValue and not frame.textValue then--数值 + -
                    frame.textValue=WoWTools_LabelMixin:Create(frame)
                end
                if frame.textValue then
                    frame.textValue:SetText('')
                    frame.textValue:SetShown(info.textValue)
                end
                if Save().notText then
                    frame.text:SetText('')
                else
                    frame.text:SetTextColor(Save().textColor.r, Save().textColor.g, Save().textColor.b, Save().textColor.a)
                end

                frame.r, frame.g, frame.b, frame.a= info.r,info.g,info.b,info.a
                frame.damageAndDefense= info.damageAndDefense--全能5
                frame.onlyDefense= info.onlyDefense--全能5
                frame.bit= info.bit or 0
                frame.useNumber= info.useNumber
                frame.name= info.name
                frame.nameText= info.text
                frame.zeroShow= info.zeroShow
               
                frame.value=nil

            end

            set_Frame(frame, rest)

            find= (frame.value and ((frame.value<1 and frame.zeroShow) or frame.value>=1)) or info.name=='SPEED'

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




































































--####
--初始
--####
local function Init()
    WoWTools_AttributesMixin:Init_Dragonriding_Speed()--驭空术UI，速度
    WoWTools_AttributesMixin:Init_Vehicle_Speed()--载具，移动，速度

    button= WoWTools_ButtonMixin:Cbtn(nil, {icon='hide', size={22,22}, isType2=true, name='WoWTools_AttributesButton'})
    button.frame= CreateFrame("Frame",nil,button)


    button.texture= button:CreateTexture(nil, 'BORDER')
    button.texture:SetSize(18,18)
    button.texture:SetPoint('CENTER')

    button.classPortrait= button:CreateTexture(nil, 'OVERLAY', nil)--加个外框
    button.classPortrait:SetPoint('CENTER',1,-1)
    button.classPortrait:SetSize(24,24)
    button.classPortrait:SetAtlas('bag-reagent-border')
    button.classPortrait:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)

    function button:get_Att_Text_Chat()--属性，内容
        local text=''
        local specIndex= GetSpecialization()
        if specIndex then
            local specID= GetSpecializationInfo(specIndex)
            if specID then
                local specTab= C_SpecializationInfo.GetSpellsDisplay(specID) or {}
                for _, spellID in pairs (specTab) do
                    local link= C_Spell.GetSpellLink(spellID)
                    if link then
                        text= link
                        break
                    end
                end
            end
        end
        text= text..'HP'..WoWTools_Mixin:MK(UnitHealthMax('player'), 0)

        for _, info in pairs(Tabs) do
            local frame=button[info.name]
            if not info.hide and info.name~='SPEED' and frame and frame:IsShown() and frame.value and frame.value>0 then
                local value= frame.text:GetText()
                if value then
                    text= text..', '..info.text..value
                end
            end
        end
        return text
    end

    function button:get_sendTextTips()
        local text
        if ChatEdit_GetActiveWindow() then
            text= e.onlyChinese and '编辑' or EDIT
        elseif UnitExists('target') and UnitIsPlayer('target') and not UnitIsUnit('player', 'target') then
            text= (e.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER)..': '.. GetUnitName('target', true)
        elseif not UnitIsDeadOrGhost('player') and IsInInstance() then
            text= (e.onlyChinese and '说' or SAY)
        elseif IsInRaid() then
            text= e.onlyChinese and '说: 团队' or (SAY..': '..CHAT_MSG_RAID)
        elseif IsInGroup() then
            text= e.onlyChinese and '说: 队伍' or (SAY..': '..CHAT_MSG_PARTY)
        else
            text= (e.onlyChinese and '说' or SAY)
        end
        return text
    end

    function button:send_Att_Chat()--发送信息
        local text= self:get_Att_Text_Chat()
        if ChatEdit_GetActiveWindow() then
            ChatEdit_InsertLink(text)
        else
            local name
            if UnitExists('target') and UnitIsPlayer('target') and not UnitIsUnit('player', 'target') then
                name= GetUnitName('target', true)
            end
            WoWTools_ChatMixin:Chat(text, name, nil)
        end
    end

    function button:set_Show_Hide()--显示， 隐藏
        self.frame:SetShown(not Save().hide)
        self.texture:SetAlpha(Save().hide and 1 or Save().buttonAlpha or 0.3)
        self.classPortrait:SetAlpha(Save().hide and 1 or Save().buttonAlpha or 0)
        self:SetScale(Save().buttonScale or 1)
    end

    function button:set_Point()--设置, 位置
        self:ClearAllPoints()
        if Save().point then
            button:SetPoint(Save().point[1], UIParent, Save().point[3], Save().point[4], Save().point[5])
        elseif e.Player.husandro then
            button:SetPoint('LEFT', PlayerFrame, 'RIGHT', 25, 35)
        else
            button:SetPoint('LEFT', 23, 180)
        end
    end


    button:RegisterForDrag("RightButton")
    button:SetMovable(true)
    button:SetClampedToScreen(true)
    button:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save().point={self:GetPoint(1)}
        Save().point[2]=nil
    end)
    button:SetScript("OnMouseUp", ResetCursor)
    button:SetScript("OnMouseDown", function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')

        elseif d=='LeftButton' and not IsModifierKeyDown() then
            WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置
            print(e.addName, WoWTools_AttributesMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '重置' or RESET)..'|r', e.onlyChinese and '数值' or STATUS_TEXT_VALUE)

        elseif d=='RightButton' and IsShiftKeyDown() then
            self:send_Att_Chat()--发送信息

        elseif d=='RightButton' and not IsModifierKeyDown() then
            WoWTools_AttributesMixin:Init_Menu(self)

        end
    end)



    button:SetScript('OnMouseWheel', function(self, d)
        if d==1 then
            Save().hide= true
        elseif d==-1 then
            Save().hide= nil
        end
        self:set_Show_Hide()--显示， 隐藏
    end)

    button:SetScript("OnLeave",function(self) ResetCursor() e.tips:Hide() self:set_Show_Hide() end)

    button:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '重置' or RESET, e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '显示/隐藏' or (HIDE..'/'..SHOW), e.Icon.mid)
        e.tips:AddDoubleLine(self:get_sendTextTips(), 'Shift+'..e.Icon.right)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine(e.addName, WoWTools_AttributesMixin.addName)
        e.tips:Show()
        self.texture:SetAlpha(1)
        self.classPortrait:SetAlpha(1)
    end)


    function button:settings()
        if Save().hideInPetBattle then
            self:SetShown(
                not C_PetBattles.IsInBattle()
                and not UnitHasVehicleUI('player')
            )
        else
            self:SetShown(true)
        end
    end
    function button:set_event()
        self:UnregisterAllEvents()
        if Save().hideInPetBattle then
            self:RegisterEvent('PET_BATTLE_OPENING_DONE')
            self:RegisterEvent('PET_BATTLE_CLOSE')
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:RegisterEvent('UNIT_ENTERED_VEHICLE')
            self:RegisterEvent('UNIT_EXITED_VEHICLE')
        end
    end
    button:SetScript('OnEvent', button.settings)








    button:set_event()
    button:settings()
    button:set_Point()--设置, 位置
    button:set_Show_Hide()--显示， 隐藏
















    C_Timer.After(4, function()
        button.frame:SetPoint('BOTTOM')
        button.frame:SetSize(1, 1)
        if Save().scale and Save().scale~=1 then--缩放
            button.frame:SetScale(Save().scale)
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

        button.frame:SetScript("OnEvent", function(_, event)
            if event=='PLAYER_SPECIALIZATION_CHANGED' then
                set_Tabs()--设置, 内容
                WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置
            elseif event=='AVOIDANCE_UPDATE'
                or event=='LIFESTEAL_UPDATE'
                or event=='UNIT_DAMAGE'
                or event=='UNIT_DEFENSE'
                or event=='UNIT_RANGEDDAMAGE'
                or event=='UNIT_AURA' then
                WoWTools_AttributesMixin:Frame_Init()--初始， 或设置
            else
                WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置
            end
        end)

        WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置
    end)
end
















function WoWTools_AttributesMixin:Frame_Init(rest)
    Frame_Init(rest)
end

function WoWTools_AttributesMixin:Get_Tabs()
    do
        if not Tabs then
            set_Tabs()
        end
    end
    return Tabs
end

function WoWTools_AttributesMixin:Get_MinCrit()
    return get_minCrit()
end







panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then

            WoWTools_AttributesMixin.Save= WoWToolsSave['Plus_Attributes'] or WoWTools_AttributesMixin.Save

            WoWTools_AttributesMixin.addName= '|A:charactercreate-icon-customize-body-selected:0:0|a'..(e.onlyChinese and '属性' or STAT_CATEGORY_ATTRIBUTES)

            WoWTools_AttributesMixin.PanelFrame= CreateFrame('Frame')
            WoWTools_AttributesMixin.Category= e.AddPanel_Sub_Category({name=WoWTools_AttributesMixin.addName, frame=WoWTools_AttributesMixin.PanelFrame})--添加控制面板

            e.ReloadPanel({panel=WoWTools_AttributesMixin.PanelFrame, addName=WoWTools_AttributesMixin.addName, restTips=nil, checked=not Save().disabled, clearTips=nil, reload=false,--重新加载UI, 重置, 按钮
                disabledfunc=function()
                    Save().disabled = not Save().disabled and true or nil
                    if not Save().disabled and not button then
                        do
                            Init()
                        end
                        WoWTools_AttributesMixin:Init_Options()
                    else
                        print(e.addName, WoWTools_AttributesMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                        WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置
                    end
                end,
                clearfunc= function()
                    WoWTools_AttributesMixin.Save=nil
                    WoWTools_Mixin:Reload()
                end
            })

            if not Save().disabled then
                local r,g,b,a= WoWTools_ColorMixin:HEXtoRGB(Save().redColor)
                RedColor= {r=r or 1, g=g or 0, b=b or 0, a=a or 1}
                r,g,b,a= WoWTools_ColorMixin:HEXtoRGB(Save().greenColor)
                GreenColor= {r=r or 0, g=g or 1, b=b or 0, a=a or 1}
                Init()
            end

            if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
                WoWTools_AttributesMixin:Init_Options()
                self:UnregisterEvent('Blizzard_Settings')
            end

        elseif arg1=='Blizzard_Settings' then
            WoWTools_AttributesMixin:Init_Options()

        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_Attributes']= WoWTools_AttributesMixin.Save
        end
    end
end)