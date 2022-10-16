local id, e = ...
e.L=e.L or {}--多语言
e.tips=GameTooltip

e.GroupGuid={}--团队GUID,{GUID==unit}

local function GetWeek()--周数
    local d = date("*t")
    local cd
    if GetLocale() == "zhCN" then 
        cd=4
    else
        cd=3
    end
    for d3=1,15 do
        if date('*t', time({year=d.year, month=1, day=d3})).wday == cd then 
            cd=d3
            break
        end
    end
    local week=ceil(floor((time() - time({year = d.year, month = 1, day = cd})) / (24*60*60)) /7)
    if week==0 then
        week=52
    end
    return week
end

e.Race=function(unit, race, sex, reAtlas)--玩家种族图标
    race =race or select(2,UnitRace(unit))
    sex=sex or UnitSex(unit)
    sex= sex==2 and 'male' or 'female'
    if race=='Scourge' then
        race='Undead'
    elseif race=='HighmountainTauren' then
        race='highmountain'
    elseif race=='ZandalariTroll' then
        race='zandalari'
    elseif race=='LightforgedDraenei' then
        race='lightforged'
    end
    if reAtlas then
        return 'raceicon128-'..race..'-'..sex
    else
        return '|A:raceicon128-'..race..'-'..sex..':0:0|a'
    end
end

e.Class=function(unit, class, reAltlas)--职业图标
    class=class or select(2, UnitClass(unit))
    class=class and 'groupfinder-icon-class-'..class or 'groupfinder-icon-emptyslot'
    if reAltlas then
        return class
    else
        return '|A:'..class ..':0:0|a'
    end
end

e.GetPlayerInfo=function (unit, guid, reName)
    if unit then
        if reName then
            return e.Race(unit)..e.Class(unit)..'|c'..select(4,GetClassColor(UnitClassBase(unit)))..GetUnitName(unit, true)..'|r'
        else
            return e.Race(unit)..e.Class(unit)
        end
    elseif guid then
        local _, englishClass, _, englishRace, sex, name, realm = GetPlayerInfoByGUID(guid)
        if reName then
            return e.Race(nil, englishRace, sex)..e.Class(nil, englishClass)
        else
            realm = (realm and realm~=e.Player.server) and '|cnGREEN_FONT_COLOR:*|r' or ''
            return e.Race(nil, englishRace, sex)..e.Class(nil, englishClass)..'|c'..select(4,GetClassColor(englishClass))..name..realm..'|r'
        end
    end
    return ''
end

e.Player={
    server=GetRealmName(),
    name_server=UnitName('player')..'-'..GetRealmName(),
    col='|c'..select(4,GetClassColor(UnitClassBase('player'))),
    zh= GetLocale()== "zhCN",
    Lo=GetLocale(),
    class=UnitClassBase('player'),
    --MAX_PLAYER_LEVEL = GetMaxLevelForPlayerExpansion()
    week=GetWeek(),--周数
}
e.Player.servers={}--多服务器
for k, v in pairs(GetAutoCompleteRealms()) do
    e.Player.servers[v]=k
end

e.UnitItemLevel={--玩家装等
    [UnitGUID('player')] ={
        itemLeve= C_PaperDollInfo.GetInspectItemLevel('player'),
        specID=GetInspectSpecialization('player'),
        name=UnitName('player'),
        realm=e.Player.server,
        col=e.Player.col,
    }
}

e.Icon={
    icon='orderhalltalents-done-glow',

    disabled='talents-button-reset',
    select='GarrMission_EncounterBar-CheckMark',--绿色√
    select2='|A:GarrMission_EncounterBar-CheckMark:0:0|a',--绿色√
    selectYellow='Adventures-Checkmark',--黄色√
    X2='|A:xmarksthespot:0:0|a',

    right='|A:newplayertutorial-icon-mouse-rightbutton:0:0|a',
    left='|A:newplayertutorial-icon-mouse-leftbutton:0:0|a',
    mid='|A:newplayertutorial-icon-mouse-middlebutton:0:0|a',

    pushed='Forge-ColorSwatchHighlight',--移过时
    highlight='Forge-ColorSwatchSelection',--点击时

    transmogHide='transmog-icon-hidden',--不可幻化
    transmogHide2='|A:transmog-icon-hidden:0:0|a',--不可幻化
    okTransmog2='|T132288:0|t',--可幻化

    map='poi-islands-table',
    map2='|A:poi-islands-table:0:0|a',
    wow2='|A:Icon-WoW:0:0|a',

    horde='charcreatetest-logo-horde',
    alliance='charcreatetest-logo-alliance',
    horde2='|A:charcreatetest-logo-horde:0:0|a',
    alliance2='|A:charcreatetest-logo-alliance:0:0|a',

    number='services-number-',
    number2='|A:services-number-%d:0:0|a',
    clock='socialqueuing-icon-clock',
    clock2='|A:socialqueuing-icon-clock:0:0|a',

    player=e.Race('player'),

    bank2='|A:Banker:0:0|a',
    bag='bag-main',
    bag2='|A:bag-main:0:0|a',
    up2='|A:bags-greenarrow:0:0|a',--绿色向上
    down2='|A:UI-HUD-MicroMenu-StreamDLRed-Up:0:0|a',--红色向下
    toLeft2='|A:common-icon-rotateleft:0:0|a',--向左
    toRight2='|A:common-icon-rotateright:0:0|a',--向右

    unlocked='Levelup-Icon-Lock',--没锁
    quest='AutoQuest-Badge-Campaign',--任务
    guild2='|A:communities-guildbanner-background:0:0|a',
    --mask="Interface\\ChatFrame\\UI-ChatIcon-HotS",--菱形
    --mask='Interface\\CHARACTERFRAME\\TempPortraitAlphaMask',--圆形 :SetMask()
    
    TANK='|A:groupfinder-icon-role-large-tank:0:0|a',
    HEALER='|A:groupfinder-icon-role-large-heal:0:0|a',
    DAMAGER='|A:groupfinder-icon-role-large-dps:0:0|a',
    NONE='|A:groupfinder-icon-emptyslot:0:0|a',
    leader='|A:UI-HUD-UnitFrame-Player-Group-GuideIcon:0:0|a',--队长
}
--Interface\Common\WhiteIconFrame 提示方形外框
e.GetNpcID = function(unit)--NPC ID
    if UnitExists(unit) then
        local guid=UnitGUID(unit)
        if guid then
        return select(6,  strsplit("-", guid));
        end
    end
end

e.MK=function(number,bit)
    bit = bit or 1
    if number>=1e6 then
        if bit==0 then
        return math.modf(number/1e6)..'m'
        else
        return ('%.'..bit..'fm'):format(number/1e6)
        end
    elseif number>= 1e4 and e.Player.zh then
        if bit==0 then
        return math.modf(number/1e4)..'w'
        else
        return ('%.'..bit..'fw'):format(number/1e4)
        end
    elseif number>=1e3 then
        if bit==0 then
            return math.modf(number/1e3)..'k'
        else
        return ('%.'..bit..'fk'):format(number/1e3)
        end
    else
        return ('%i'):format(number)
    end
end

e.GetShowHide = function(sh)
	if sh then
		return '|cnGREEN_FONT_COLOR:'..SHOW..'|r'
	else
		return '|cnRED_FONT_COLOR:'..HIDE..'|r'
	end
end
e.GetEnabeleDisable = function (ed)--启用或禁用字符
    if ed then
        return '|cnGREEN_FONT_COLOR:'..ENABLE..'|r'
    else
        return '|cnRED_FONT_COLOR:'..DISABLE..'|r'
    end
end
e.GetYesNo = function (yesno)
    if yesno then
        return '|cnGREEN_FONT_COLOR:'..YES..'|r'
    else
        return '|cnRED_FONT_COLOR:'..NO..'|r'
    end
end

e.GetDifficultyColor = function(string, difficultyID)--DifficultyUtil.lua
    if difficultyID==17 or difficultyID==7 then--随机
        return '|cFFE7E71F'..string..'|r'
    elseif difficultyID==1 or difficultyID==3 or difficultyID==4 or difficultyID==9 or difficultyID==14 then--普通
        return '|cFF01FF8C'..string..'|r'
    elseif difficultyID==2 or difficultyID==5 or difficultyID==6 or difficultyID==16 then--英雄
        return '|cFFFF9B01'..string..'|r'
    elseif difficultyID==16 or difficultyID==23 then--史诗
        return '|cFFB900FF'..string..'|r'
    elseif difficultyID==8 then--挑战        
        return '|cFFFF8000'..string..'|r'
    elseif difficultyID==24 or difficultyID==33 then--时光
        return '|cFF00B2FF'..string..'|r'
    else
        return string
    end
end

e.Cstr=function(self, size, fontType, ChangeFont, color)
    local b=ChangeFont or self:CreateFontString(nil, 'OVERLAY')
    if fontType then
        if size then
        local fontName, _, fontFlags = fontType:GetFont()
            b:SetFont(fontName, size, fontFlags)
        else
            b:SetFont(fontType:GetFont())
        end
        b:SetTextColor(fontType:GetTextColor())
        b:SetFontObject(fontType:GetFontObject())
        b:SetShadowColor(fontType:GetShadowColor())
        b:SetShadowOffset(fontType:GetShadowOffset())
    else
        b:SetFont('Fonts\\ARHei.ttf', size or 12, 'OUTLINE')
        b:SetShadowOffset(2, -2)
        --b:SetShadowColor(0, 0, 0)
        b:SetJustifyH('LEFT')
        if color then
            b:SetTextColor(color.r, color.g, color.b)
        else
            b:SetTextColor(1, 0.45, 0.04)
        end
    end
    return b
end

e.CeditBox= function(self, width, height)
    width = width or 400
    height= height or 400

    local editBox = CreateFrame("EditBox", nil, self)
    editBox:SetSize(width, height)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject("ChatFontNormal")
    editBox:SetMultiLine(true)

    local tex=editBox:CreateTexture(nil, "BACKGROUND")
    tex:SetAtlas('_Adventures-Mission-Highlight-Mid')
    tex:SetAllPoints(editBox)
    return editBox
end

e.Cbtn= function(self, Template, value, SecureAction, name)
    local b
    if Template then
        b=CreateFrame('Button', name, self, 'UIPanelButtonTemplate')
    elseif SecureAction then
        b=CreateFrame("Button", name, self, "SecureActionButtonTemplate");
        b:SetHighlightAtlas(e.Icon.highlight)
        b:SetPushedAtlas(e.Icon.pushed)
    else
        b=CreateFrame('Button', name, self)
        b:SetHighlightAtlas(e.Icon.highlight)
        b:SetPushedAtlas(e.Icon.pushed)
        if value then
            b:SetNormalAtlas(e.Icon.icon)
        else
            b:SetNormalAtlas(e.Icon.disabled)
        end
    end
    b:RegisterForClicks("LeftButtonDown","RightButtonDown")
    return b
end

e.Ccool=function(self, start, duration, modRate, HideCountdownNumbers, Reverse)--冷却条
    if not self.cool then
        self.cool= CreateFrame("Cooldown", nil, self, 'CooldownFrameTemplate')
        self.cool:SetDrawEdge(true)
        if HideCountdownNumbers then
            self.cool:SetHideCountdownNumbers(true)
        end
        if Reverse then--控制冷却动画的方向
        self.cool:SetReverse(true)
        end
    end
    self.cool:SetCooldown(start, duration, modRate)
end

e.SetButtonKey = function(self, set, key, click)--设置清除快捷键
    if set then
        SetOverrideBindingClick(self, true, key, self:GetName(), click or 'LeftButton')
    else
        ClearOverrideBindings(self)
    end
end

e.itemSlotTable={
    ['INVTYPE_HEAD']=1,
    ['INVTYPE_NECK']=2,
    ['INVTYPE_SHOULDER']=3,
    ['INVTYPE_BODY']=4,
    ['INVTYPE_CHEST']=5,
    ['INVTYPE_WAIST']=6,
    ['INVTYPE_LEGS']=7,
    ['INVTYPE_FEET']=8,
    ['INVTYPE_WRIST']=9,
    ['INVTYPE_HAND']=10,
    ['INVTYPE_FINGER']=11,
    ['INVTYPE_TRINKET']=13,
    ['INVTYPE_WEAPON']=16,
    ['INVTYPE_SHIELD']=17,
    ['INVTYPE_RANGED']=16,
    ['INVTYPE_CLOAK']=15,
    ['INVTYPE_2HWEAPON']=16,
    ['INVTYPE_TABARD']=19,
    ['INVTYPE_ROBE']=5,
    ['INVTYPE_WEAPONMAINHAND']=16,
    ['INVTYPE_WEAPONOFFHAND']=16,
    ['INVTYPE_HOLDABLE']=17,
    ['INVTYPE_THROWN']=16,
    ['INVTYPE_RANGEDRIGHT']=16,
};


e.WA_GetUnitAura = function(unit, spell, filter)--AuraEnvironment.lua
  for i = 1, 255 do
    local name, _, _, _, _, _, _, _, _, spellId = UnitAura(unit, i, filter)
    if not name then
        return
    elseif spell == spellId or spell == name then
      return UnitAura(unit, i, filter)
    end
  end
end
e.WA_GetUnitBuff = function(unit, spell, filter)
    for i = 1, 40 do
        local name, _, _, _, _, _, _, _, _, spellId = UnitBuff(unit, i, filter)
        if not name then
            return
        elseif spell == spellId or spell == name then
          return UnitBuff(unit, i, filter)
        end
      end
end

e.WA_GetUnitDebuff = function(unit, spell, filter)
    for i = 1, 40 do
        local name, _, _, _, _, _, _, _, _, spellId = UnitDebuff(unit, i, filter)
        if not name then
            return
        elseif spell == spellId or spell == name then
          return UnitDebuff(unit, i, filter)
        end
      end
end
e.WA_Utf8Sub = function(input, size)
    local output = ""
    if type(input) ~= "string" then
      return output
    end
    local i = 1
    while (size > 0) do
      local byte = input:byte(i)
      if not byte then
        return output
      end
      if byte < 128 then
        -- ASCII byte
        output = output .. input:sub(i, i)
        size = size - 1
      elseif byte < 192 then
        -- Continuation bytes
        output = output .. input:sub(i, i)
      elseif byte < 244 then
        -- Start bytes
        output = output .. input:sub(i, i)
        size = size - 1
      end
      i = i + 1
    end
    while (true) do
      local byte = input:byte(i)
      if byte and byte >= 128 and byte < 192 then
        output = output .. input:sub(i, i)
      else
        break
      end
      i = i + 1
    end
    return output
end