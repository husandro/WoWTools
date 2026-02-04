

local function Save()
    return WoWToolsSave['Plus_Attributes'] or {}
end


local Role, PrimaryStat, Tabs
local RedColor--变小值
local GreenColor--变大值
local BASE_MOVEMENT_SPEED= BASE_MOVEMENT_SPEED or 7



local function Set_Color()
    local r,g,b,a= WoWTools_ColorMixin:HEXtoRGB(Save().redColor)
    RedColor= {r=r or 1, g=g or 0, b=b or 0, a=a or 1}

    r,g,b,a= WoWTools_ColorMixin:HEXtoRGB(Save().greenColor)
    GreenColor= {r=r or 0, g=g or 1, b=b or 0, a=a or 1}
end


local function get_PrimaryStat()--取得主属
    local spec= GetSpecialization() or 0
    Role= GetSpecializationRole(spec)--DAMAGER, TANK, HEALER
    local icon, _
    icon, _, PrimaryStat= select(4, GetSpecializationInfo(spec, nil, nil, nil, WoWTools_DataMixin.Player.Sex))
    --SetPortraitToTexture(_G['WoWToolsAttributesButton'].texture, icon or 0)
    _G['WoWToolsAttributesButton'].texture:SetTexture(icon or 0)
end


local function set_Tabs()
    get_PrimaryStat()--取得主属

    local r,g,b= PlayerUtil.GetClassColor():GetRGB()
    Tabs={
        {name='STATUS', r=r, g=g, b=b, a=1, useNumber=true, textValue=true},

        {name= 'CRITCHANCE', text= WoWTools_DataMixin.onlyChinese and '爆击' or STAT_CRITICAL_STRIKE, bar=true, dps=true, textValue=true, zeroShow=true},
        {name= 'HASTE', text= WoWTools_DataMixin.onlyChinese and '急速' or STAT_HASTE, bar=true, dps=true, textValue=true, zeroShow=true},
        {name= 'MASTERY', text= WoWTools_DataMixin.onlyChinese and '精通' or STAT_MASTERY, bar=true, dps=true, textValue=true, zeroShow=true},
        {name= 'VERSATILITY', text= WoWTools_DataMixin.onlyChinese and '全能' or STAT_VERSATILITY, bar=true, dps=true, textValue=true, zeroShow=true},--5

        {name= 'LIFESTEAL', text= WoWTools_DataMixin.onlyChinese and '吸血' or STAT_LIFESTEAL, bar=true, textValue=true},--6
        {name= 'AVOIDANCE', text= WoWTools_DataMixin.onlyChinese and '闪避' or STAT_AVOIDANCE, bar=true, textValue=true},--7

        {name= 'ARMOR', text= WoWTools_DataMixin.onlyChinese and '护甲' or STAT_ARMOR, bar=true, tank=true, textValue=true},
        {name= 'DODGE', text= WoWTools_DataMixin.onlyChinese and '躲闪' or STAT_DODGE, bar=true, tank=true, textValue=true},--9
        {name= 'PARRY', text= WoWTools_DataMixin.onlyChinese and '招架' or STAT_PARRY, bar=true, tank=true, textValue=true},--10
        {name= 'BLOCK', text= WoWTools_DataMixin.onlyChinese and '格挡' or STAT_BLOCK, bar=true, tank=true, textValue=true},--11
        {name= 'STAGGER', text= WoWTools_DataMixin.onlyChinese and '醉拳' or STAT_STAGGER, bar=true, tank=true, usePercent=true, textValue=true},--12

        {name= 'SPEED', text= WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE},--13
    }

    if PrimaryStat==LE_UNIT_STAT_STRENGTH then
        Tabs[1].text= WoWTools_DataMixin.onlyChinese and '力量' or SPEC_FRAME_PRIMARY_STAT_STRENGTH
    elseif PrimaryStat==LE_UNIT_STAT_AGILITY then
        Tabs[1].text= WoWTools_DataMixin.onlyChinese and '敏捷' or SPEC_FRAME_PRIMARY_STAT_AGILITY
    else
        Tabs[1].text= WoWTools_DataMixin.onlyChinese and '智力' or SPEC_FRAME_PRIMARY_STAT_INTELLECT
    end

    for index, info in pairs(Tabs) do
        if not Save().tab[info.name]then
            Save().tab[info.name]={name= info.name}
        end
        Tabs[index].r= index==1 and r or Save().tab[info.name].r or 1
        Tabs[index].g= index==1 and g or Save().tab[info.name].g or 0.82
        Tabs[index].b= index==1 and b or Save().tab[info.name].b or 0
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
            if info.name=='STAGGER' and (WoWTools_DataMixin.Player.Class~='MONK' or Role~='TANK') then--武僧, 醉拳
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
                    text= WoWTools_DataMixin:MK(value, frame.bit)..( value2 and '/'..WoWTools_DataMixin:MK(value2, frame.bit) or '')
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


    if frame.isBar and frame.bar:IsShown() then
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
                    icon, text= '|A:UI-HUD-Minimap-Zoom-In:8:8|a', WoWTools_DataMixin:MK(value-frame.value, frame.bit)
                else
                    icon, text= '|A:UI-HUD-Minimap-Zoom-In:8:8|a', format('%.'..frame.bit..'f', value-frame.value)
                end
            else--减
                if frame.useNumber then
                    icon, text= '|A:UI-HUD-Minimap-Zoom-Out:6:6|a', WoWTools_DataMixin:MK(frame.value-value, frame.bit)
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














--主属性
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










--爆击
local function get_minCrit()
    local holySchool = 2
    local minCrit = GetSpellCritChance(holySchool) or 0
    local spellCrit
    for i=(holySchool+1), MAX_SPELL_SCHOOLS do
        spellCrit = GetSpellCritChance(i)
        minCrit = min(minCrit, spellCrit)
    end
    return minCrit or 0
end

local function set_CRITCHANCE_Text(frame)
    local critChance
    if Save().useNumber then
        local rating
        local spellCrit = get_minCrit()
        local rangedCrit = GetRangedCritChance()
        local meleeCrit = GetCritChance()

        if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
            rating = CR_CRIT_SPELL
        elseif (rangedCrit >= meleeCrit) then
            rating = CR_CRIT_RANGED
        else
            rating = CR_CRIT_MELEE
        end
        critChance = GetCombatRating(rating)
    else
        local spellCrit = get_minCrit()
        local rangedCrit = GetRangedCritChance()
        local meleeCrit = GetCritChance()
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









--急速
local function set_HASTE_Text(frame)
    local haste
    if Save().useNumber then
        haste= GetCombatRating(CR_HASTE_MELEE)--CR_HASTE_RANGED CR_HASTE_SPELL
    else
        haste = GetHaste()
    end
    if not frame then
        return haste or 0
    else
        set_Text_Value(frame, haste)--设置，当前值
    end
end








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








--全能, 5
local function set_VERSATILITY_Text(frame)
    local value, value2
    if Save().useNumber then
        value = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE)
    else
        if frame.onlyDefense then
            value= GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN)
        else
            if frame.damageAndDefense then
                value= GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
                value2= GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN)
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









--吸血, 6
local function set_LIFESTEAL_Text(frame)
    local lifesteal
    if Save().useNumber then
        lifesteal= GetCombatRating(CR_LIFESTEAL)
    else
        lifesteal= GetLifesteal()
    end
    if not frame then
        return lifesteal or 0
    else
        set_Text_Value(frame, lifesteal)--设置，当前值
    end
end









--闪避, 7
local function set_AVOIDANCE_Text(frame)
    local avoidance
    if Save().useNumber then
        avoidance= GetCombatRating(CR_AVOIDANCE)
    else
        avoidance= GetAvoidance()
    end
    if not frame then
        return avoidance or 0
    else
        set_Text_Value(frame, avoidance)--设置，当前值
    end
end







--躲闪, 8
local function set_DODGE_Text(frame)
    local chance
    if Save().useNumber then
        chance= GetCombatRating(CR_DODGE)
    else
        chance= GetDodgeChance()
    end
    if not frame then
        return chance or 0
    else
        set_Text_Value(frame, chance)--设置，当前值
    end
end












--护甲
local function set_ARMOR_Text(frame)
    local value, value2
    local baselineArmor, effectiveArmor, armor, bonusArmor = UnitArmor('player')
    if Save().useNumber then
        value= effectiveArmor
    else
        value = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitEffectiveLevel('player'))
        value2 = PaperDollFrame_GetArmorReductionAgainstTarget(effectiveArmor)
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












--招架
local function set_PARRY_Text(frame)
    local chance
    if Save().useNumber then
        chance= GetCombatRating(CR_PARRY)
    else
        chance= GetParryChance()
    end
    if not frame then
        return chance or 0
    else
        set_Text_Value(frame, chance)--设置，当前值
    end
end















--格挡10
local function set_BLOCK_Text(frame)
    local chance
    if Save().useNumber then
        chance= GetCombatRating(CR_BLOCK)
    else
        chance= GetBlockChance()
    end
    if not frame then
        return chance or 0
    else
        set_Text_Value(frame, chance)--设置，当前值
    end
end












--醉拳11
local function set_STAGGER_Text(frame)
    local stagger, staggerAgainstTarget = C_PaperDollInfo.GetStaggerPercentage('player')
    set_Text_Value(frame, stagger, staggerAgainstTarget)--设置，当前值
end














--移动12
local function set_SPEED_Text(frame, elapsed)
    frame.elapsed= frame.elapsed + elapsed
    if frame.elapsed < 0.3 then
        return
    end

    frame.elapsed= 0
    local value
    local isGliding, _, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
    if isGliding and forwardSpeed then
        value= forwardSpeed
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
        WoWTools_AttributesMixin:Set_Shadow(frame.label)--设置，字体阴影
        WoWTools_AttributesMixin:Set_Shadow(frame.text)--设置，字体阴影

--背景
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
        frame.bg:SetAlpha(Save().bgAlpha or 0.5)

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













local EventsTable={}
--主属性1
EventsTable.STATUS= function(frame)
    frame:RegisterUnitEvent('UNIT_STATS', 'player')
    frame:SetScript('OnEvent', set_STATUS_Text)
end

--EventsTable.HASTE= function(frame)--爆击2

--急速3
EventsTable.HASTE= function(frame)
    frame:RegisterUnitEvent('UNIT_SPELL_HASTE', 'player')
    frame:SetScript('OnEvent', set_HASTE_Text)
end

--精通4
EventsTable.MASTERY= function(frame)
    frame:RegisterEvent('MASTERY_UPDATE')
    frame.onEnterFunc = Mastery_OnEnter
end

--吸血6
EventsTable.LIFESTEAL= function(frame)
    _G['WoWToolsAttributesButton'].frame:RegisterEvent('LIFESTEAL_UPDATE')
end

--护甲
EventsTable.ARMOR= function(frame)
    frame:RegisterEvent('PLAYER_TARGET_CHANGED')
    frame:SetScript('OnEvent', set_ARMOR_Text)
end

--闪避7
EventsTable.AVOIDANCE= function(frame)
    _G['WoWToolsAttributesButton'].frame:RegisterEvent('AVOIDANCE_UPDATE')
end

--[[
EventsTable.DODGE= function(frame)--躲闪8
EventsTable.PARRY= function(frame)--招架9
EventsTable.BLOCK= function(frame)-格挡10
]]
--醉拳11
EventsTable.STAGGER= function(frame)
    frame:RegisterEvent('PLAYER_TARGET_CHANGED')
    frame:SetScript('OnEvent', set_STAGGER_Text)
end

--移动12
EventsTable.SPEED= function(frame)
    frame.frame=CreateFrame('Frame', nil, frame)
    frame.frame.elapsed= 0.3
    frame.frame:SetScript('OnHide', function(self)
        self.elapsed= nil
        self.text:SetText('')
    end)
    frame.frame:SetScript('OnShow', function(self)
        self.elapsed= 0.3
    end)
    frame.frame:SetScript('OnUpdate', set_SPEED_Text)

    frame.frame.text= frame.text
    frame.frame:SetAllPoints()
    frame:RegisterEvent("PLAYER_STARTED_MOVING")
    frame:RegisterEvent("PLAYER_STOPPED_MOVING")
    frame:SetScript('OnEvent', function(self, event)
        self.frame:SetShown(event=='PLAYER_STARTED_MOVING')
    end)
end
















--初始， 或设置
local function Frame_Init(rest)
    if rest or not Tabs then
        set_Tabs()
    end

    local last= _G['WoWToolsAttributesButton'].frame
    for _, info in pairs(Tabs) do
        local frame, find= _G['WoWToolsAttributesButton'][info.name], nil
        if not info.hide then
            if not frame then
                _G['WoWToolsAttributesButton'][info.name]= CreateFrame('Frame', nil, _G['WoWToolsAttributesButton'].frame)
                frame= _G['WoWToolsAttributesButton'][info.name]

                frame.label= WoWTools_LabelMixin:Create(frame, {mouse=true, color={r=info.r, g=info.g,b=info.b, a=info.a}})--nil, nil, nil, {info.r,info.g,info.b,info.a}, nil)


                frame.text= WoWTools_LabelMixin:Create(frame, {color={r=1,g=1,b=1}, justifyH= Save().toLeft and 'RIGHT'})--nil, nil, nil, {1,1,1}, nil, Save().toLeft and 'RIGHT' or 'LEFT')


                frame.bg= frame:CreateTexture(nil, 'BACKGROUND')
                frame.bg:SetColorTexture(0,0,0)

                frame.bar= CreateFrame('StatusBar', nil, frame)
                frame.bar:SetFrameLevel(frame:GetFrameLevel()-1)
                frame.barTexture= frame.bar:CreateTexture(nil, 'BORDER')
                frame.barTexture:SetAtlas('UI-HUD-UnitFrame-Player-GroupIndicator')
                frame.barTextureSpark= frame.bar:CreateTexture(nil, 'OVERLAY')
                frame.barTextureSpark:SetAtlas('objectivewidget-bar-spark-neutral')
                frame.barTextureSpark:SetSize(6,12)

                if EventsTable[info.name] then
                    EventsTable[info.name](frame)
                end

                frame.label:SetScript('OnLeave', function(self)
                    local prent= self:GetParent()
                    GameTooltip:Hide()
                    prent:SetAlpha(1)
                end)
                if frame.onEnterFunc then
                    frame.label:SetScript('OnEnter', frame.onEnterFunc)--PaperDollFrame.lua
                else
                    frame.label:SetScript('OnEnter', function(self)
                        local prent= self:GetParent()
                        WoWTools_AttributesMixin:Set_Tooltips(prent, self)
                        prent:SetAlpha(0.3)
                    end)
                end
            end

            --重置, 数值
            if rest then
                frame.isBar= info.bar
                frame.bar:SetShown(info.bar)
                frame.barTextureSpark:SetShown(false)

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
































function WoWTools_AttributesMixin:Set_Shadow(label)--设置，字体阴影
    if label then
        label:SetShadowColor(Save().font.r, Save().font.g, Save().font.b, Save().font.a)
        label:SetShadowOffset(Save().font.x, Save().font.y)
    end
end

function WoWTools_AttributesMixin:Frame_Init(rest)
    if rest then
        Set_Color()
    end
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
