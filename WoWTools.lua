local id, e = ...
e.L=e.L or {}--多语言
e.tips=GameTooltip

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

local ActionButtonUseKeyDown=C_CVar.GetCVarBool("ActionButtonUseKeyDown")
e.LeftButtonDown = ActionButtonUseKeyDown and 'LeftButtonDown' or 'LeftButtonUp'
e.RightButtonDown= ActionButtonUseKeyDown and 'RightButtonDown' or 'RightButtonUp'

e.LoadSpellItemData= function(ID, spell)--加载法术, 物品数据
    if spell then
        if not C_Spell.IsSpellDataCached(ID) then C_Spell.RequestLoadSpellData(ID) end
    else
        if not C_Item.IsItemDataCachedByID(ID) then C_Item.RequestLoadItemDataByID(ID) end
    end
end

local itemLoadTab={--加载法术,或物品数据
        134020,--玩具,大厨的帽子
        6948,--炉石
        140192,--达拉然炉石
        110560,--要塞炉石
        5512,--治疗石
        8529,--诺格弗格药剂
    }
local spellLoadTab={
        818,--火
    }
for _, itemID in pairs(itemLoadTab) do
    e.LoadSpellItemData(itemID)--加载法术, 物品数据
end
for _, spellID in pairs(spellLoadTab) do
    e.LoadSpellItemData(spellID, true)
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

local GetPlayerNameRemoveRealm= function(name, realm)--玩家名称, 去服务器为*
    if name then
        realm= realm or name:match('%-(.+)')
        if realm then
            if e.Player.servers[realm] then
                return name..'|cnGREEN_FONT_COLOR:*|r'
            else
                return name..'*'
            end
        end
        return name
    end
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
    class=class or (unit and select(2, UnitClass(unit)))
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
    guid= guid or UnitGUID(unit)
    if guid then
        local _, englishClass, _, englishRace, sex, name, realm = GetPlayerInfoByGUID(guid)
        if name and englishClass and englishRace and sex then
            if showName then
                return (e.Race(nil, englishRace, sex) or '')..'|c'..select(4,GetClassColor(englishClass))..GetPlayerNameRemoveRealm(name, realm)..'|r'
            else
                return (e.Race(nil, englishRace, sex) or '')..(e.Class(nil, englishClass) or '')
            end
        end
    elseif unit then
        if showName then
            local name= GetUnitName(unit, true)
            if name then
                local col
                local className=UnitClassBase(unit)
                if className then
                    col= select(4,GetClassColor(className))
                    if col then
                        name= '|c'..col..name..'|r'
                    end
                end
                if not col then
                    name= (e.Class(unit) or '')..name
                end
                return e.Race(unit)..name
            end
        else
            return e.Race(unit)..(e.Class(unit) or '')
        end
    end
    return ''
end

e.Player={
    server=GetRealmName(),
    servers={},--多服务器
    name_server=UnitName('player')..'-'..GetRealmName(),
    name= UnitName('player'),
    col='|c'..select(4,GetClassColor(UnitClassBase('player'))),
    zh= GetLocale()== ("zhCN" or 'zhTW'),
    Lo=GetLocale(),
    class=UnitClassBase('player'),
    --MAX_PLAYER_LEVEL = GetMaxLevelForPlayerExpansion()
    week=GetWeek(),--周数
    guid=UnitGUID('player'),
    levelMax=UnitLevel('player')==MAX_PLAYER_LEVEL,--玩家是否最高等级
    level=UnitLevel('player'),
    husandro= select(2, BNGetInfo()) == '古月剑龙#5972' or select(2, BNGetInfo())=='SandroChina#2690',
}
for k, v in pairs(GetAutoCompleteRealms()) do
    e.Player.servers[v]=k
end

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
    --INLINE_TANK_ICON
    --INLINE_HEALER_ICON
    --INLINE_DAMAGER_ICON

    info2='|A:questlegendary:0:0|a',--黄色!
    star2='|A:auctionhouse-icon-favorite:0:0|a',--星星
}
--[[
    Interface\Common\WhiteIconFrame 提示方形外框
    FRIENDS_TEXTURE_DND 忙碌texture FRIENDS_LIST_BUSY
    FRIENDS_TEXTURE_AFK 离开 AFK FRIENDS_LIST_AWAY 
    FRIENDS_TEXTURE_ONLINE 	有空 FRIENDS_LIST_AVAILABLE
]]


e.PlayerLink=function(name, guid) --玩家超链接
    if not guid and name then
        local unit=e.GroupGuid[name] and e.GroupGuid[name].unit
        if unit then
            guid= UnitGUID(unit)
        end
    end
    if name == COMBATLOG_FILTER_STRING_ME or name==e.Player.name or name==e.Player.name_server or guid==e.Player.guid then--自已
        return e.Icon.player..'|Hplayer:'..e.Player.name_server..'|h['..e.Player.col..COMBATLOG_FILTER_STRING_ME..'|r'..']|h'
    end

    if guid then
        local _, class, _, race, sex, name2, realm = GetPlayerInfoByGUID(guid)
        if name2 then
            local showName= GetPlayerNameRemoveRealm(name2, realm)
            if class then
                showName= '|c'..select(4,GetClassColor(class))..showName..'|r'
            end
            return ((race and sex) and e.Race(nil, race, sex) or '')..'|Hplayer:'..name2..(realm and '-'..realm or '')..'|h['..showName..']|h'
        end
    elseif name then
        return '|Hplayer:'..name..'|h['..GetPlayerNameRemoveRealm(name)..']|h'
    end
end

e.PlayerOnlineInfo=function(unit)--单位，状态信息
    if unit and UnitExists(unit) then
        if not UnitIsConnected(unit) then
            return '|TInterface\\FriendsFrame\\StatusIcon-Offline:0|t'
        elseif UnitIsAFK(unit) then
            return '|TInterface\\FriendsFrame\\StatusIcon-Away:0|t'
        elseif UnitIsDeadOrGhost(unit) then
            return '|A:poi-soulspiritghost:0:0|a'
        end
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
    local text
    local uiMapID= C_Map.GetBestMapForUnit(unit)
    if unit=='player' and IsInInstance() then
        local name, _, _, difficultyName= GetInstanceInfo()
        if name then
            text= name .. ((difficultyName and difficultyName~='') and '('..difficultyName..')' or '')
        else
            text=GetMinimapZoneText()
        end
    elseif uiMapID then
        local info = C_Map.GetMapInfo(uiMapID)
        if info and info.name then
            text=info.name
        end
    end
    return text, uiMapID
end

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
            return ('%im'):format(number/1e6)
            --return math.modf(number/1e6)..'m'
        else
            return ('%.'..bit..'fm'):format(number/1e6)
        end
    elseif number>= 1e4 and (e.Player.zh or e.onlyChinse) then
        if bit==0 then
            return ('%iw'):format(number/1e4)
            --return math.modf(number/1e4)..'w'
        else
            return ('%.'..bit..'fw'):format(number/1e4)
        end
    elseif number>=1e3 then
        if bit==0 then
            return ('%ik'):format(number/1e3)
            --return math.modf(number/1e3)..'k'
        else
            return ('%.'..bit..'fk'):format(number/1e3)
        end
    else
        return ('%i'):format(number)
    end
end

e.GetShowHide = function(sh)
	if sh then
		return '|cnGREEN_FONT_COLOR:'..(e.onlyChinse and '显示' or SHOW)..'|r'
	else
		return '|cnRED_FONT_COLOR:'..(e.onlyChinse and '隐藏' or HIDE)..'|r'
	end
end
e.GetEnabeleDisable = function (ed)--启用或禁用字符
    if ed then
        return '|cnGREEN_FONT_COLOR:'..(e.onlyChinse and '启用' or ENABLE)..'|r'
    else
        return '|cnRED_FONT_COLOR:'..(e.onlyChinse and '禁用' or DISABLE)..'|r'
    end
end
e.GetYesNo = function (yesno)
    if yesno then
        return '|cnGREEN_FONT_COLOR:'..(e.onlyChinse and '是' or YES)..'|r'
    else
        return '|cnRED_FONT_COLOR:'..(e.onlyChinse and '否' or NO)..'|r'
    end
end

e.GetDifficultyColor = function(string, difficultyID)--DifficultyUtil.lua
    if string and difficultyID then
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
end

e.Cstr=function(self, size, fontType, ChangeFont, color, layer, justifyH)
    self= self or UIParent
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
    self= self or UIParent
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

e.Ccool=function(self, start, duration, modRate, HideCountdownNumbers, Reverse, SwipeTexture, hideDrawBling)--冷却条
    if not self then
        return
    end
    if not self.cooldown then
        self.cooldown= CreateFrame("Cooldown", nil, self, 'CooldownFrameTemplate')
        self.cooldown:SetUseCircularEdge(true)--设置边缘纹理是否应该遵循圆形图案而不是方形编辑框
        self.cooldown:SetDrawBling(not hideDrawBling)--闪光
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

e.toolsFrame=CreateFrame('Frame', nil, UIParent)--TOOLS 框架
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

e.Chat=function(text, name, setPrint)--v9.25设置
    if text then
        local ins=IsInInstance()
        if name then
            SendChatMessage(text, 'WHISPER',nil, name);

        elseif not UnitIsDeadOrGhost('player') and ins then
            SendChatMessage(text, 'SAY');

        elseif IsInRaid() then
            SendChatMessage(text, 'RAID')

        elseif IsInGroup() then
            SendChatMessage(text,'PARTY');

        elseif not IsResting() and not UnitAffectingCombat('player') then
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
        if color  then
            score= color:WrapTextInColorCode(score)
        end
        if texture then
            score= '|T4352494:0|t'..score
        end
        return score
    end
end

e.GetTimeInfo= function(value, chat, time)
    if value>0 then
        time= time or GetTime()
        time= time < value and time + 86400 or time
        time= time - value;
        if chat then 
            return SecondsToClock(time):gsub('：',':'), time;
        else
            return SecondsToTime(time), time;
        end
    else
        if chat then 
            return SecondsToClock(0):gsub('：',':'), 0;
        else
            return SecondsToTime(0), 0;
        end
    end
end

e.GetSetsCollectedNum= function(setID)--套装 , 收集数量, 返回: 图标, 数量, 最大数, 文本
    local info= setID and C_TransmogSets.GetSetPrimaryAppearances(setID)
    local numCollected,numAll=0,0
    if info then
        for _,v in pairs(info) do
            numAll=numAll+1
            if v.collected then
                numCollected=numCollected + 1
            end
        end
    end
    if numAll>0 then
        if numCollected==numAll then
            return '|A:transmog-icon-checkmark:6:6|a', numCollected, numAll, '|cnGREEN_FONT_COLOR:'..(e.onlyChinse and '已收集' or COLLECTED)..'|r'
        elseif numAll <=9 then
            if numCollected==0 then
                return e.Icon.number2:format(numAll-numCollected), numCollected, numAll, '|cnRED_FONT_COLOR:'..(e.onlyChinse and '未收集' or NOT_COLLECTED)..'|r'
            else
                return e.Icon.number2:format(numAll-numCollected), numCollected, numAll, '|cnYELLOW_FONT_COLOR:'..numCollected..'/'..numAll..' '..(e.onlyChinse and '未收集' or NOT_COLLECTED)..'|r'
            end
        else
            if numCollected==0 then
                return '|cnRED_FONT_COLOR:'..numAll-numCollected..'|r ', numCollected, numAll, '|cnRED_FONT_COLOR:'..(e.onlyChinse and '未收集' or NOT_COLLECTED)..'|r'
            else
                return ' |cnYELLOW_FONT_COLOR:'..numAll-numCollected..'|r ', numCollected, numAll, '|cnYELLOW_FONT_COLOR:'..numCollected..'/'..numAll..' '..(e.onlyChinse and '未收集' or NOT_COLLECTED)..'|r'
            end
        end
    end
end

e.GetItemCollected= function(link, sourceID, icon)--物品是否收集
    sourceID= sourceID or link and select(2,C_TransmogCollection.GetItemInfo(link))
    local sourceInfo = sourceID and C_TransmogCollection.GetSourceInfo(sourceID)
    if sourceInfo then
        local isSelf= select(2, C_TransmogCollection.PlayerCanCollectSource(sourceID))
        if sourceInfo.isCollected then
            if icon then
                if isSelf then
                    return e.Icon.select2, sourceInfo.isCollected, isSelf
                else
                    return '|A:Adventures-Checkmark:0:0|a', sourceInfo.isCollected, isSelf--黄色√
                end
            else
                return '|cnGREEN_FONT_COLOR:'..(e.onlyChinse and '已收集' or COLLECTED)..'|r', sourceInfo.isCollected, isSelf
            end
        else
            if icon then
                if isSelf then
                    return e.Icon.okTransmog2, sourceInfo.isCollected, isSelf
                else
                    return e.Icon.star2, sourceInfo.isCollected, isSelf
                end
            else
                return '|cnRED_FONT_COLOR:'..(e.onlyChinse and '未收集' or NOT_COLLECTED)..'|r', sourceInfo.isCollected, isSelf
            end
        end
    end
end

e.GetPetCollected= function(speciesID, itemID, numShow)--宠物, 收集数量
    speciesID = speciesID or (itemID and select(13, C_PetJournal.GetPetInfoByItemID(itemID)))--宠物物品
    if speciesID then
        local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)
        if nunumCollected==0 then
            if numShow then
                return '|cnRED_FONT_COLOR:'..numCollected..'/'..limit..'|r', numCollected, limit
            else
                return '|cnRED_FONT_COLOR:'..format(e.onlyChinse and '已收集（%d/%d）' or ITEM_PET_KNOWN, numCollected, limit)..'|r', numCollected, limit
            end
        elseif limit and numCollected==limit and limit>0 then
            if numShow then
                return '|cnGREEN_FONT_COLOR:'..numCollected..'/'..limit..'|r', numCollected, limit
            else
                return '|cnGREEN_FONT_COLOR:'..format(e.onlyChinse and '已收集（%d/%d）' or ITEM_PET_KNOWN, numCollected, limit)..'|r', numCollected, limit
            end
        else
            if numShow then
                return numCollected..'/'..limit, numCollected, limit
            else
                return format(e.onlyChinse and '已收集（%d/%d）' or ITEM_PET_KNOWN, numCollected, limit), numCollected, limit
            end
        end
    end
end

e.GetMountCollected= function(mountID)--坐骑, 收集数量
    if select(11, C_MountJournal.GetMountInfoByID(mountID)) then
        return '|cnGREEN_FONT_COLOR:'..(e.onlyChinse and '已收集' or COLLECTED)..'|r'
    else
        return '|cnRED_FONT_COLOR:'..(e.onlyChinse and '未收集' or NOT_COLLECTED)..'|r'
    end
end

e.ExpansionLevel= GetExpansionLevel()
e.GetExpansionText= function(expacID, questID)--版本数据
    expacID= expacID or questID and GetQuestExpansion(questID)
    if expacID then
        if e.ExpansionLevel==expacID then
            return _G['EXPANSION_NAME'..expacID], (e.onlyChinse and '版本' or GAME_VERSION_LABEL)..' '..(expacID+1)
        else
            return '|cff606060'.._G['EXPANSION_NAME'..expacID]..'|r', '|cff606060'..(e.onlyChinse and '版本' or GAME_VERSION_LABEL)..' '..(expacID+1)..'|r'
        end
    end
end


e.GetTooltipData= function(colorRed, text, hyperLink, bag, guidBank, merchant, buyBack, inventory, text2)--物品提示，信息
    local tooltipData
    if bag then
        tooltipData= C_TooltipInfo.GetBagItem(bag.bag, bag.slot)
    elseif guidBank then
        tooltipData= C_TooltipInfo.GetGuildBankItem(guidBank.tab, guidBank.slot)
    elseif merchant then
        tooltipData= C_TooltipInfo.GetMerchantItem(merchant)--slot
    elseif buyBack then
        tooltipData= C_TooltipInfo.GetBuybackItem(buyBack)
    elseif inventory then
        tooltipData= C_TooltipInfo.GetInventoryItem('player', inventory)
    end
    tooltipData=  tooltipData or (hyperLink and C_TooltipInfo.GetHyperlink(hyperLink))
    if tooltipData and tooltipData.lines then
        local noUse, findText, wow, findText2
        for _, line in ipairs(tooltipData.lines) do--是否
            TooltipUtil.SurfaceArgs(line)
            if colorRed and noUse==nil then
                local leftHex=line.leftColor and line.leftColor:GenerateHexColor()
                local rightHex=line.rightColor and line.rightColor:GenerateHexColor()
                if leftHex == 'ffff2020' or leftHex=='fefe1f1f' or rightHex== 'ffff2020' or rightHex=='fefe1f1f' then-- or hex=='fefe7f3f' then
                    noUse=true
                    if not text then
                        break
                    end
                end
            end
            if line.leftText then
                if text and line.leftText:find(text) then--字符
                    findText= line.leftText:match(text) or line.leftText
                    if not colorRed   then
                        break
                    end
                elseif text2 and line.leftText:find(text2) then--字符2
                    findText2= line.leftText:match(text2) or line.leftText
                    if not colorRed and findText then
                        break
                    end
                elseif line.leftText==ITEM_BNETACCOUNTBOUND or line.leftText==ITEM_ACCOUNTBOUND then--暴雪游戏通行证绑定, 账号绑定
                    wow=true
                end
            end
        end
        return noUse, findText, wow, findText2
    end
end


e.PlaySound= function(soundKitID)--播放, 声音 SoundKitConstants.lua e.PlaySound()--播放, 声音
    if not C_CVar.GetCVarBool('Sound_EnableAllSound') or C_CVar.GetCVar('Sound_MasterVolume')=='0' then
        return
    end
    local channel
    if C_CVar.GetCVarBool('Sound_EnableDialog') and C_CVar.GetCVar("Sound_DialogVolume")~='0' then
        channel= 'Dialog'
    elseif C_CVar.GetCVarBool('Sound_EnableAmbience') and C_CVar.GetCVar("Sound_AmbienceVolume")~='0' then
        channel= 'Ambience'
    elseif C_CVar.GetCVarBool('Sound_EnableSFX') and C_CVar.GetCVar("Sound_SFXVolume")~='0' then
        channel= 'SFX'
    elseif C_CVar.GetCVarBool('Sound_EnableMusic') and C_CVar.GetCVar("Sound_MusicVolume")~='0' then
        channel= 'Music'
    else
        channel= 'Master'
    end
    PlaySound(soundKitID or SOUNDKIT.READY_CHECK, channel)
end
--[[
BACKGROUND
BORDER
ARTWORK
OVERLAY
DRAG_MODEL拖曳

UIPanelWindows[]

FrameUtil.RegisterFrameForEvents(self, table);
SetPortraitTexture(textureObject, unitToken [, disableMasking])
SetPortraitToTexture(textureObject, texturePath)
Region:SetVertexColor(colorR, colorG, colorB [, a])
]]
