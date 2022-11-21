local id, e = ...
e.L=e.L or {}--多语言
e.tips=GameTooltip

local ActionButtonUseKeyDown=C_CVar.GetCVarBool("ActionButtonUseKeyDown")
e.LeftButtonDown = ActionButtonUseKeyDown and 'LeftButtonDown' or 'LeftButtonUp'
e.RightButtonDown= ActionButtonUseKeyDown and 'RightButtonDown' or 'RightButtonUp'

local itemLoadTab={--加载法术,或物品数据
        134020,
    }
local spellLoadTab={
        818,
    }
for _, itemID in pairs(itemLoadTab) do
    if not C_Item.IsItemDataCachedByID(itemID) then C_Item.RequestLoadItemDataByID(itemID) end
end
for _, spellID in pairs(spellLoadTab) do
    if not C_Spell.IsSpellDataCached(spellID) then C_Spell.RequestLoadSpellData(spellID) end
end

e.itemPetID={--宠物对换, wow9.0
    [11406]=true,
    [11944]=true,
    [25402]=true,
    [3300]=true,
    [3670]=true,
    [6150]=true,
    [36812]=true,
    [62072]=true,
    [67410]=true,
}

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
    race =race or unit and select(2,UnitRace(unit))
    sex=sex or unit and UnitSex(unit)
    sex= sex==2 and 'male' or 'female'
    if race=='Scourge' then
        race='Undead'
    elseif race=='HighmountainTauren' then
        race='highmountain'
    elseif race=='ZandalariTroll' then
        race='zandalari'
    elseif race=='LightforgedDraenei' then
        race='lightforged'
    elseif race=='Dracthyr' then
        race='dracthyrvisage'
    end
    if race and sex then
        if reAtlas then
            return 'raceicon128-'..race..'-'..sex
        else
            return '|A:raceicon128-'..race..'-'..sex..':0:0|a'
        end
    else
        return ''
    end
end

e.Class=function(unit, class, reAltlas)--职业图标
    class=class or select(2, UnitClass(unit))
    if class=='EVOKER' then
        class='classicon-evoker'
    else
        class=class and 'groupfinder-icon-class-'..class or 'groupfinder-icon-emptyslot'
    end
    if reAltlas then
        return class
    else
        return '|A:'..class ..':0:0|a'
    end
end

e.GetPlayerInfo=function (unit, guid, showName)--, hideClassTexture)
    if unit then
        if showName then
            return e.Race(unit)..(not showName and e.Class(unit) or '')..'|c'..select(4,GetClassColor(UnitClassBase(unit)))..GetUnitName(unit, true)..'|r'
        else
            return e.Race(unit)..(not showName and e.Class(unit) or '')
        end
    elseif guid then
        local _, englishClass, _, englishRace, sex, name, realm = GetPlayerInfoByGUID(guid)
        
        if showName then
            realm = (realm and realm~=e.Player.server) and '|cnGREEN_FONT_COLOR:*|r' or ''
            return (e.Race(nil, englishRace, sex) or '')..(not showName and  e.Class(nil, englishClass) or '')..'|c'..select(4,GetClassColor(englishClass))..name..realm..'|r'
        else
            return (e.Race(nil, englishRace, sex) or '')..(not showName and  e.Class(nil, englishClass) or '')
        end
    end
    return ''
end

e.PlayerLink=function(name, guid) --玩家超链接
    local class, race,sex
    if guid then
        local _, class2, _, englishRace, sex2, name2 = GetPlayerInfoByGUID(guid)
        name = name or name2
        race= englishRace
        sex= sex2
        class= class2
    end
    if name then
        return ((race and sex) and e.Race(nil, race, sex) or '')..'|Hplayer:'..name..'|h['..(class and '|c'..select(4,GetClassColor(class))..name ..'|r' or name)..']|h'
    end
end

e.GetNpcID = function(unit)--NPC ID
    if UnitExists(unit) then
        local guid=UnitGUID(unit)
        if guid then
            return select(6,  strsplit("-", guid));
        end
    end
end

e.GetUnitMapName=function(unit)--单位, 地图名称
    local uiMapID= C_Map.GetBestMapForUnit(unit)
    if uiMapID then
        local info = C_Map.GetMapInfo(uiMapID)
        if info and info.name then 
            return info.name
        end
    end
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
    select='AlliedRace-UnlockingFrame-Checkmark',--'GarrMission_EncounterBar-CheckMark',--绿色√
    select2='|A:AlliedRace-UnlockingFrame-Checkmark:0:0|a',--绿色√
    selectYellow='Adventures-Checkmark',--黄色√
    X2='|A:xmarksthespot:0:0|a',
    O2='|TInterface\\AddOns\\WeakAuras\\Media\\Textures\\cancel-mark.tga:0|t',--￠

    right='|A:newplayertutorial-icon-mouse-rightbutton:0:0|a',
    left='|A:newplayertutorial-icon-mouse-leftbutton:0:0|a',
    mid='|A:newplayertutorial-icon-mouse-middlebutton:0:0|a',

    pushed='UI-HUD-MicroMenu-Highlightalert',--'bag-border-highlight',--Forge-ColorSwatchHighlight',--移过时
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
    clock2='|A:socialqueuing-icon-clock:0:0|a',--auctionhouse-icon-clock

    player=e.Race('player'),

    bank2='|A:Banker:0:0|a',
    bag='bag-main',
    bag2='|A:bag-main:0:0|a',
    bagEmpty='bag-reagent-border-empty',

    up2='|A:bags-greenarrow:0:0|a',--绿色向上
    down2='|A:UI-HUD-MicroMenu-StreamDLRed-Up:0:0|a',--红色向下
    toLeft='common-icon-rotateleft',--向左
    toLeft2='|A:common-icon-rotateleft:0:0|a',
    toRight='common-icon-rotateright',--向右
    toRight2='|A:common-icon-rotateright:0:0|a',

    unlocked='tradeskills-icon-locked',--'Levelup-Icon-Lock',--没锁
    quest='AutoQuest-Badge-Campaign',--任务
    guild2='|A:UI-HUD-MicroMenu-GuildCommunities-Mouseover:0:0|a',--guild2='|A:communities-guildbanner-background:0:0|a',
    --mask="Interface\\ChatFrame\\UI-ChatIcon-HotS",--菱形
    --mask='Interface\\CHARACTERFRAME\\TempPortraitAlphaMask',--圆形 :SetMask()
    --mask='CircleMaskScalable',


    TANK='|A:groupfinder-icon-role-large-tank:0:0|a',
    HEALER='|A:groupfinder-icon-role-large-heal:0:0|a',
    DAMAGER='|A:groupfinder-icon-role-large-dps:0:0|a',
    NONE='|A:groupfinder-icon-emptyslot:0:0|a',
    leader='|A:UI-HUD-UnitFrame-Player-Group-GuideIcon:0:0|a',--队长

    info2='|A:questlegendary:0:0|a',--黄色!
}
--[[
    Interface\Common\WhiteIconFrame 提示方形外框
    FRIENDS_TEXTURE_DND 忙碌texture FRIENDS_LIST_BUSY
    FRIENDS_TEXTURE_AFK 离开 AFK FRIENDS_LIST_AWAY 
    FRIENDS_TEXTURE_ONLINE 	有空 FRIENDS_LIST_AVAILABLE
]]
e.GetFriend = function(name, guid)--检测, 是否好友 
    if guid then 
        if C_FriendList.IsFriend(guid) then 
            return '|A:groupfinder-icon-friend:0:0|a', nil--好友
        elseif IsGuildMember(guid) then 
            return '|A:UI-HUD-MicroMenu-GuildCommunities-Mouseover:0:0|a'--公会
        elseif C_BattleNet.GetAccountInfoByGUID(guid) or C_BattleNet.GetGameAccountInfoByGUID(guid) then 
            return e.Icon.wow2, true; 
        end
    else 
        if C_FriendList.GetFriendInfo(name) or C_FriendList.GetFriendInfo(name:gsub('%-.+','')) then 
            return '|A:groupfinder-icon-friend:0:0|a', nil--好友
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

e.Cstr=function(self, size, fontType, ChangeFont, color, layer, justifyH)
    local b=ChangeFont or self:CreateFontString(nil, (layer or 'OVERLAY'))
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
        b:SetFont('Fonts\\ARHei.ttf', (size or 12), 'OUTLINE')
        b:SetShadowOffset(2, -2)
        --b:SetShadowColor(0, 0, 0)
        b:SetJustifyH(justifyH or 'LEFT')
        if color and type(color)=='table' then
            b:SetTextColor(color[1], color[2], color[3])
        elseif color then
            b:SetTextColor(0.8, 0.8, 0.8)
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
    --editBox:SetAltArrowKeyMode(false)
    local tex=editBox:CreateTexture(nil, "BACKGROUND")
    tex:SetAtlas('_Adventures-Mission-Highlight-Mid')
    tex:SetAllPoints(editBox)
    return editBox
end

e.Cbtn= function(self, Template, value, SecureAction, name, notTexture, size)
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
        if not notTexture then
            if value then
                b:SetNormalAtlas(e.Icon.icon)
            else
                b:SetNormalAtlas(e.Icon.disabled)
            end
        end
    end
    b:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
    b:EnableMouseWheel(true)
    if size then
        b:SetSize(size[1], size[2])
    end
    return b
end

e.Ccool=function(self, start, duration, modRate, HideCountdownNumbers, Reverse, SwipeTexture)--冷却条
    if not self then
        return
    end
    if not self.cooldown then
        self.cooldown= CreateFrame("Cooldown", nil, self, 'CooldownFrameTemplate')
        self.cooldown:SetUseCircularEdge(true)--设置边缘纹理是否应该遵循圆形图案而不是方形编辑框
        self.cooldown:SetDrawBling(true)--闪光
        self.cooldown:SetDrawEdge(true)--冷却动画的移动边缘绘制亮线
        self.cooldown:SetHideCountdownNumbers(HideCountdownNumbers)--隐藏数字
        self.cooldown:SetReverse(Reverse)--控制冷却动画的方向
        if SwipeTexture then
            self.cooldown:SetSwipeTexture('Interface\\CHARACTERFRAME\\TempPortraitAlphaMask')
        end
    end
    start=start or GetTime()
    self.cooldown:SetCooldown(start, duration, modRate)
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


--[[
e.WA_GetUnitAura = function(unit, spell, filter)--AuraEnvironment.lua
  for i = 1, 255 do
    --local name, _, _, _, _, _, _, _, _, spellId = UnitAura(unit, i, filter)
    local spellID = select(10, UnitAura(unit, i, filter))
    if not spellID then
        return
    elseif spell == spellID then
      return UnitAura(unit, i, filter)
    end
  end
end

]]

e.WA_GetUnitBuff = function(unit, spell, filter)
    for i = 1, 40 do
        local spellID = select(10, UnitBuff(unit, i, filter))
        if not spellID then
            return
        elseif spell == spellID then
          return UnitBuff(unit, i, filter)
        end
    end
end
--[[

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

]]

e.WA_Utf8Sub = function(input, size, letterSize)
    local output = ""
    if type(input) ~= "string" then
      return output
    end
    local i = 1

    if letterSize and input:find('%w')  then--英文
        size=letterSize
    end

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

e.HEX=function(r, g, b, a)
    a=a or 1
    r = r <= 1 and r >= 0 and r or 0
    g = g <= 1 and g >= 0 and g or 0
    b = b <= 1 and b >= 0 and b or 0
    a = a <= 1 and a >= 0 and a or 0
    return string.format("%02x%02x%02x%02x",a*255, r*255, g*255, b*255)
end


--取得对战宠物, 强弱 SharedPetBattleTemplates.lua
e.GetPetStrongWeakHints= function(petType)
    local strongTexture,weakHintsTexture, stringIndex, weakHintsIndex
    for i=1, C_PetJournal.GetNumPetTypes() do
        local modifier = C_PetBattles.GetAttackModifier(petType, i);
        if ( modifier > 1 ) then
            strongTexture='Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[i]--"Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[i]
            weakHintsIndex=i
        elseif ( modifier < 1 ) then
            weakHintsTexture='Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[i]
            weakHintsIndex=i
        end
    end
    return strongTexture,weakHintsTexture, stringIndex, weakHintsIndex ----_G["BATTLE_PET_NAME_"..petType]
end

--[[
local R,G,B=4,GetClassColor(UnitClassBase('player'))
e.CStatusBar = function(self,value, size, VERTICAL, color, min, max,ReverseFill)
    if not self.Bar then
        self.Bar = CreateFrame('StatusBar', nil, self);
        if size then
            self.Bar:SetSize(size[1], size[2])
        else
            self.Bar:SetAllPoints(slef)
        end
        if VERTICAL then--"HORIZONTAL","VERTICAL"垂直
            self.Bar:SetOrientation('VERTICAL');
        else
            self.Bar:SetOrientation('HORIZONTAL');
        end
        self.Bar:SetMinMaxValues(min,max);
        self.Bar:SetReverseFill(ReverseFill)
    end
    if color then
        self.Bar:SetStatusBarColor(color[1], color[2], color[3]);
    else
        self.Bar:SetStatusBarColor(R, G, B);
    end
    self.Bar:SetValue(value);
end

]]

e.GetItemCooldown= function(itemID)--物品冷却
    local startTime, duration, enable = GetItemCooldown(itemID)
    if duration>0 and enable==1 then
        local t=GetTime()
        if startTime>t then t=t+86400 end
        t=t-startTime
        t=duration-t
        return '|cnRED_FONT_COLOR:'..SecondsToTime(t)..'|r'
    elseif enable==0 then
        return '|cnRED_FONT_COLOR:'..SPELL_RECAST_TIME_INSTANT..'|r'
    end
    return ''
end

e.GetSpellCooldown = function(spellID)--法术冷却
    local startTime, duration, enable = GetSpellCooldown(spellID)
    if duration>0 and enable==1 then
        local t=GetTime()
        if startTime>t then t=t+86400 end
        t=t-startTime
        t=duration-t
        return '|cnRED_FONT_COLOR:'..SecondsToTime(t)..'|r'
    elseif enable==0 then
        return '|cnRED_FONT_COLOR:'..SPELL_RECAST_TIME_INSTANT..'|r'
    end
    return ''
end

e.Cbtn2= function(name, parent, showTexture, rightClick)
    local button= CreateFrame("Button", name, (parent or UIParent), "SecureActionButtonTemplate")

    local size=e.toolsFrame.size or 30
    button:SetSize(size,size)
    if rightClick then
        button:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
    elseif rightClick~=false then
        button:RegisterForClicks(e.LeftButtonDown)
    end
    button:EnableMouseWheel(true)

    button:SetHighlightAtlas('bag-border')
    button:SetPushedAtlas('bag-border-highlight')

    button.mask= button:CreateMaskTexture()
    button.mask:SetTexture('Interface\\CHARACTERFRAME\\TempPortraitAlphaMask')
    button.mask:SetPoint("TOPLEFT", button, "TOPLEFT", 4, -4);
    button.mask:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -6, 6);

    button.background=button:CreateTexture(nil,'BACKGROUND')
    button.background:SetAllPoints(button)
    button.background:SetAtlas(e.Icon.bagEmpty)
    button.background:AddMaskTexture(button.mask)

    button.texture=button:CreateTexture(nil, 'BORDER')
    button.texture:SetPoint("TOPLEFT", button, "TOPLEFT", 4, -4);
	button.texture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -6, 6);
    button.texture:AddMaskTexture(button.mask)
    button.texture:SetShown(showTexture)

    button.border=button:CreateTexture(nil, 'ARTWORK')
    button.border:SetAllPoints(button)
    button.border:SetAtlas('bag-reagent-border')

    return button
end

e.toolsFrame=CreateFrame('Frame')--TOOLS 框架
e.toolsFrame:SetSize(1,1)
e.toolsFrame:SetShown(false)
e.toolsFrame.last=e.toolsFrame
e.toolsFrame.line=1
e.toolsFrame.index=0
e.ToolsSetButtonPoint=function(self, line, unoLine)--设置位置
    if e.toolsFrame.size and e.toolsFrame.size~=30 then--设置大小
        self:SetSize(e.toolsFrame.size, e.toolsFrame.size)
    end
    if (not unoLine and e.toolsFrame.index>0 and select(2, math.modf(e.toolsFrame.index / 10))==0) or line then
        local x= - (e.toolsFrame.line * (e.toolsFrame.size or 30))
        self:SetPoint('BOTTOMRIGHT', e.toolsFrame , 'TOPRIGHT', x, 0)
        e.toolsFrame.line=e.toolsFrame.line + 1
        if line then
            e.toolsFrame.index=0
        end
    else
        self:SetPoint('BOTTOMRIGHT', e.toolsFrame.last , 'TOPRIGHT')
    end
    e.toolsFrame.last=self
    e.toolsFrame.index=e.toolsFrame.index+1
end

e.GroupGuid={}--团队GUID,{GUID==unit}
local panel=CreateFrame("Frame")
panel:RegisterEvent('GROUP_ROSTER_UPDATE')
panel:RegisterEvent('GROUP_LEFT')
panel:RegisterEvent('ADDON_LOADED')
panel:SetScript('OnEvent', function(self, event, arg1)
    if event=='GROUP_LEFT' then
        e.GroupGuid={}
    elseif event=='GROUP_ROSTER_UPDATE' or (event=='ADDON_LOADED' and arg1==id) then
        e.GroupGuid={}
        if IsInRaid() then
            for index= 1, GetNumGroupMembers() do
                local unit='raid'..index
                local guid=UnitGUID(unit)
                local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(index)

                if guid then
                    local tab={unit=unit, subgroup=subgroup, combatRole=combatRole or role}
                    e.GroupGuid[guid]=tab
                    e.GroupGuid[GetUnitName(unit, true)]=tab
                end
            end
        else
            local tab
            for index= 1, GetNumGroupMembers()-1 do
                local unit='party'..index
                local guid=UnitGUID(unit)
                if guid then
                    tab={unit=unit, combatRole=UnitGroupRolesAssigned(unit)}
                    e.GroupGuid[guid]=tab
                    e.GroupGuid[GetUnitName(unit, true)]=tab
                end
            end
            tab={unit='player', combatRole=UnitGroupRolesAssigned('player')}
            e.GroupGuid[UnitGUID('player')]=tab
            e.GroupGuid[UnitName('player')]=tab
        end
    end
end)

e.Chat=function(text, name, setPrint)--v9.25设置
    if text then
        if name then
            SendChatMessage(text, 'WHISPER',nil, name);

        elseif UnitAffectingCombat('player') and IsInInstance() then
            SendChatMessage(text, 'SAY');

        elseif IsInRaid() then
            SendChatMessage(text, 'RAID')

        elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
            SendChatMessage(text,'PARTY');

        elseif IsInInstance() and IsInGroup() then
            SendChatMessage(text, 'INSTANCE_CHAT');

        elseif not UnitIsDeadOrGhost('player') and not IsResting() then
            SendChatMessage(text, 'SAY');

        elseif setPrint then
            print(text)
        end 
    end 
end

e.Say=function(type, name, wow)
    local chat=SELECTED_DOCK_FRAME;
    local text = chat.editBox:GetText() or '';
    if text:find('/') then text='' end 
    text=' '..text;    
    if name then     
        if wow then 
            ChatFrame_SendBNetTell(name..text)
        else
            ChatFrame_OpenChat("/w " ..name..text, chat);        
        end
    else
        ChatFrame_OpenChat(type..  text, chat)
    end
end

e.GetKeystoneScorsoColor= function(score, texture)--地下城史诗, 分数,颜色
    if not score or score==0 then
        return ''
    else
        local color= C_ChallengeMode.GetDungeonScoreRarityColor(score)
        local score= color:WrapTextInColorCode(score)
        if score~='' and texture then
            score= '|T4352494:0|t'..score
        end
        return score
    end
end
--[[
BACKGROUND
BORDER
ARTWORK
OVERLAY
DRAG_MODEL拖曳
]]