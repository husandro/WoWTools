local id, e = ...
e.L=e.L or {}--多语言
e.tips=GameTooltip


local function GetWeek()--周数
    local d = date("*t")
    local cd=3
    if GetCurrentRegion()==5 then
        cd=4
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

local LeftButtonDown = C_CVar.GetCVarBool("ActionButtonUseKeyDown") and 'LeftButtonDown' or 'LeftButtonUp'
local RightButtonDown= C_CVar.GetCVarBool("ActionButtonUseKeyDown") and 'RightButtonDown' or 'RightButtonUp'


e.LoadDate= function(tab)--e.LoadDate({id=, type=''})--加载 item quest spell
    if not tab.id then
        return
    end
    if tab.type=='quest' then
        C_QuestLog.RequestLoadQuestByID(tab.id)
    elseif tab.type=='spell' then
        local spellID= tab.id
        if type(tab.id)=='string' then
            spellID= select(7, GetSpellInfo(tab.id))
        end
        if spellID and not C_Spell.IsSpellDataCached(spellID) then C_Spell.RequestLoadSpellData(spellID) end
    elseif tab.type=='item' then
        if not C_Item.IsItemDataCachedByID(tab.id) then C_Item.RequestLoadItemDataByID(tab.id) end
    end
end

local itemLoadTab={--加载法术,或物品数据
        134020,--玩具,大厨的帽子
        6948,--炉石
        140192,--达拉然炉石
        110560,--要塞炉石
        5512,--治疗石
        8529,--诺格弗格药剂
        38682,--附魔纸
        179244,--[召唤司机]
        179245,
    }
local spellLoadTab={
        818,--火
    }
for _, itemID in pairs(itemLoadTab) do
    e.LoadDate({id=itemID, type='item'})
end
for _, spellID in pairs(spellLoadTab) do
    e.LoadDate({id=spellID, type='spell'})
end
for bag=0, NUM_BAG_SLOTS do
    for slot=1, C_Container.GetContainerNumSlots(bag) do
        local info = C_Container.GetContainerItemInfo(bag, slot)
        if info and info.itemID then
            e.LoadDate({id=info.itemID, type='item'})
        end
    end
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
    realm = realm=='' and nil or realm
    if name then
        realm= realm or name:match('%-(.+)')
        if realm then
            name= name:match('(.+)%-') or name
            if realm==e.Player.server then
                return name
            elseif e.Player.servers[realm] then
                return name..'|cnGREEN_FONT_COLOR:*|r'
            else
                return name..'*'
            end
        end
        return name
    end
end

e.GetUnitRaceInfo=function(tab)--e.GetUnitRaceInfo({unit=nil, guid=nil, race=nil, sex=nil, reAtlas=false})--玩家种族图标
    local race =tab.race or tab.unit and select(2,UnitRace(tab.unit))
    local sex= tab.sex
    if not (race or sex) and tab.guid then
        race, sex = select(4, GetPlayerInfoByGUID(tab.guid))
    end
    sex=sex or tab.unit and UnitSex(tab.unit)
    sex= sex==2 and 'male' or sex==3 and 'female'
    if sex and race then
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
        if tab.reAtlas then
            return 'raceicon128-'..race..'-'..sex
        else
            return '|A:raceicon128-'..race..'-'..sex..':0:0|a'
        end
    end
end

e.Class=function(unit, class, reAltlas)--职业图标
    class=class or unit and select(2, UnitClass(unit))
    if class then
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
end

local function getGUID(unit, name)--从名字,名unit, 获取GUID
    if unit then
        return UnitGUID(unit)
    elseif name then
        if e.GroupGuid[name] and e.GroupGuid[name].guid then--队友
            return e.GroupGuid[name].guid
        elseif e.WoWGUID[name] then--战网
            return e.WoWGUID[name]
        elseif UnitIsPlayer('target') and GetUnitName('target',true)==name then--目标
            return UnitGUID('target')
        elseif C_FriendList.GetFriendInfo(name) then--好友
            local info=C_FriendList.GetFriendInfo(name)
            return info and info.guid
        elseif name==e.Player.name or name==e.Player.name_server then
            return e.Player.guid
        end
    end
end

e.GetFriend= function(name, guid, unit)--检测, 是否好友
    guid= guid or getGUID(unit, name)
    if guid==e.Player.guid or name==e.Player.name or (unit and UnitIsUnit('player', unit)) then
        return
    end
    if guid then
        if C_BattleNet.GetAccountInfoByGUID(guid) or C_BattleNet.GetGameAccountInfoByGUID(guid) then
            return e.Icon.wow2

        elseif C_FriendList.IsFriend(guid) then
            return '|A:groupfinder-icon-friend:0:0|a'--好友
        elseif IsGuildMember(guid) then
            return '|A:UI-HUD-MicroMenu-GuildCommunities-Mouseover:0:0|a'--公会
        end
    elseif name then
        local name2=name:match('(.-)%-')
        local info=C_FriendList.GetFriendInfo(name) or name2 and C_FriendList.GetFriendInfo(name2)
        if info then
            return '|A:groupfinder-icon-friend:0:0|a'--好友
        end
    end
end

e.GetUnitFaction= function(unit, text, allShow)--检查, 是否同一阵营
    local faction= unit and UnitFactionGroup(unit) or text
    if faction and (not allShow and faction~= e.Player.faction or allShow) and faction~='Neutral' then
        return faction=='Horde' and e.Icon.horde2 or e.Icon.alliance2
    end
end


e.PlayerLink=function(name, guid, slotLink) --玩家超链接
    guid= guid or name and e.GroupGuid[name] and e.GroupGuid[name].guid or e.WoWGUID[name]
    if name == COMBATLOG_FILTER_STRING_ME or name==e.Player.name or name==e.Player.name_server or guid==e.Player.guid then--自已
        return (not slotLink and e.Icon.player)..'|Hplayer:'..e.Player.name_server..'|h['..e.Player.col..COMBATLOG_FILTER_STRING_ME..'|r'..']|h'
    end
    if guid then
        local _, class, _, race, sex, name2, realm = GetPlayerInfoByGUID(guid)
        if name2 then
            local showName= GetPlayerNameRemoveRealm(name2, realm)
            if class then
                showName= '|c'..select(4,GetClassColor(class))..showName..'|r'
            end
            return (not slotLink and e.GetUnitRaceInfo({unit=nil, guid=guid , race=race , sex=sex , reAtlas=false}) or '')..'|Hplayer:'..name2..(realm and '-'..realm or '')..'|h['..showName..']|h'
        end
    elseif name then
        return '|Hplayer:'..name..'|h['..GetPlayerNameRemoveRealm(name)..']|h'
    end
end

--IsPlayerInGuildFromGUID(playerGUID)--玩家信息图标
e.GetPlayerInfo= function(tab)--e.GetPlayerInfo({unit=nil, guid=nil, name=nil, reName=true, reLink=false})
    local guid= tab.guid or getGUID(tab.unit, tab.name)
    local unit= tab.unit
                or guid and e.GroupGuid[guid] and e.GroupGuid[guid].unit
                or tab.name and e.GroupGuid[tab.name] and e.GroupGuid[tab.name].unit
    local name= tab.name or guid and e.GroupGuid[guid] and e.GroupGuid[guid].name

    if guid==e.Player.guid or name==e.Player.name or name==e.Player.name_server or unit=='player' then
        return e.Icon.player..((tab.reName or tab.reLink) and e.Player.col..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)..'|r' or '')..e.Icon.star2

    elseif guid and C_PlayerInfo.GUIDIsPlayer(guid) then
        local _, englishClass, _, englishRace, sex, name2, realm = GetPlayerInfoByGUID(guid)
        name= name2
        --if name and englishClass and englishRace and sex then

            local friend= e.GetFriend(name, guid, unit)--检测, 是否好友
            local faction= unit and e.GetUnitFaction(unit)--检查, 是否同一阵营
            local groupInfo= e.GroupGuid[guid] or e.GroupGuid[name] or {}--队伍成员

            local text= (friend or '')
                        ..(faction or '')
                        ..(e.GetUnitRaceInfo({unit=unit, guid=guid , race=englishRace, sex=sex, reAtlas=false}) or '')
                        ..(e.Class(unit, englishClass) or '')

            if groupInfo.combatRole=='HEALER' or groupInfo.combatRole=='TANK' then--职业图标
                text= text..e.Icon[groupInfo.combatRole]..(groupInfo.subgroup or '')
            end

            if tab.reLink then
                return text..e.PlayerLink(name, guid, true) --玩家超链接
            elseif tab.reName and name then
                if tab.reRealm then
                    text= text..(name..(realm and realm~='' and '-'..realm or ''))
                else
                    text= text..GetPlayerNameRemoveRealm(name, realm)
                end
                text= '|c'..select(4,GetClassColor(englishClass))..text..'|r'                
            end
            
            return text
       -- end
    end
    return ''
end


local rPerc, gPerc, bPerc, argbHex = GetClassColor(UnitClassBase('player'))
e.Player={
    server= GetRealmName(),
    servers= {},--多服务器
    name_server= UnitName('player')..'-'..GetRealmName(),
    name= UnitName('player'),
    sex= UnitSex("player"),
    class= UnitClassBase('player'),
    r= rPerc,
    g= gPerc,
    b= bPerc,
    col= '|c'..argbHex,
    --zh= LOCALE_zhCN or LOCALE_zhTW,--GetLocale()== ("zhCN" or 'zhTW'),
    cn= GetCurrentRegion()==5,
    region=GetCurrentRegion(),--1US (includes Brazil and Oceania) 2Korea 3Europe (includes Russia) 4Taiwan 5China
    Lo= GetLocale(),
    week= GetWeek(),--周数
    guid= UnitGUID('player'),
    levelMax= UnitLevel('player')==MAX_PLAYER_LEVEL,--玩家是否最高等级
    level= UnitLevel('player'),--UnitEffectiveLevel('player')
    husandro= select(2, BNGetInfo()) == '古月剑龙#5972' or select(2, BNGetInfo())=='SandroChina#2690' or UnitName('player')=='Fuocco' or UnitName('player')=='活就好',
    faction= UnitFactionGroup('player'),--玩家, 派系  "Alliance", "Horde", "Neutral"
    disabledLUA={},--禁用插件 {save='', text} e.DisabledLua=true
    --useColor= {r=1, g=0.82, b=0, a=1, hex='|cffffd100'},--使用颜色
    LayerText= 'Layer',--位面文本
    --Layer= nil, 位面数字
    --ver= select(4,GetBuildInfo())>=100100,--版本 100100
}
 --MAX_PLAYER_LEVEL = GetMaxLevelForPlayerExpansion()

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
    wow2='|A:Icon-WoW:0:0|a',--136235
    --wow2= '|A:128-Store-Main:0:0|a',

    horde='charcreatetest-logo-horde',
    alliance='charcreatetest-logo-alliance',
    horde2='|A:charcreatetest-logo-horde:0:0|a',
    alliance2='|A:charcreatetest-logo-alliance:0:0|a',

    number='services-number-',
    number2='|A:services-number-%d:0:0|a',
    clock='socialqueuing-icon-clock',
    clock2='|A:socialqueuing-icon-clock:0:0|a',--auctionhouse-icon-clock

    player= e.GetUnitRaceInfo({unit='player', guid=nil , race=nil , sex=nil , reAtlas=false}),

    bank2='|A:Banker:0:0|a',
    bag='bag-main',
    bag2='|A:bag-main:0:0|a',
    bagEmpty='bag-reagent-border-empty',

    up2='|A:bags-greenarrow:0:0|a',--绿色向上, 红色向上 UI-HUD-Minimap-Arrow-Corpse， 金色 UI-HUD-Minimap-Arrow-Guard
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
    format("\124T%s.tga:0\124t", FRIENDS_TEXTURE_AFK)
    Interface\\FriendsFrame\\Battlenet-Portrait
]]



e.PlayerOnlineInfo=function(unit)--单位，状态信息
    if unit and UnitExists(unit) then
        if not UnitIsConnected(unit) then
            return format("\124T%s.tga:0\124t", FRIENDS_TEXTURE_DND), e.onlyChinese and '离线' or PLAYER_OFFLINE
        elseif UnitIsAFK(unit) then
            return format("\124T%s.tga:0\124t", FRIENDS_TEXTURE_AFK), e.onlyChinese and '离开' or AFK
        elseif UnitIsGhost(unit) then
            return '|A:poi-soulspiritghost:0:0|a', e.onlyChinese and '幽灵' or DEAD
        elseif UnitIsDead(unit) then
            return '|A:deathrecap-icon-tombstone:0:0|a', e.onlyChinese and '死亡' or DEAD
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



e.MK=function(number,bit)
    bit = bit or 1
    if number>=1e6 then
        if bit==0 then
            return ('%im'):format(number/1e6)
            --return math.modf(number/1e6)..'m'
        else
            return ('%.'..bit..'fm'):format(number/1e6)
        end
    elseif number>= 1e4 and (LOCALE_zhCN or e.onlyChinese) then
        if bit==0 then
            return ('%iw'):format(number/1e4)
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
		return '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '显示' or SHOW)..'|r'
	else
		return '|cnRED_FONT_COLOR:'..(e.onlyChinese and '隐藏' or HIDE)..'|r'
	end
end
e.GetEnabeleDisable = function (ed)--启用或禁用字符
    if ed then
        return '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '启用' or ENABLE)..'|r'
    else
        return '|cnRED_FONT_COLOR:'..(e.onlyChinese and '禁用' or DISABLE)..'|r'
    end
end
e.GetYesNo = function (yesno)
    if yesno then
        return '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '是' or YES)..'|r'
    else
        return '|cnRED_FONT_COLOR:'..(e.onlyChinese and '否' or NO)..'|r'
    end
end

e.GetDifficultyColor = function(string, difficultyID)--DifficultyUtil.lua
    if string and difficultyID then
        if difficultyID==17 or difficultyID==7 then--随机, 蓝色
            return '|cff0000ff'..string..'|r' --rgb= 0,0,1
        elseif difficultyID==1 or difficultyID==3 or difficultyID==4 or difficultyID==9 or difficultyID==14 then--普通, 白色
            return '|cffffffff'..string..'|r'--rgb= 1,1,1
        elseif difficultyID==2 or difficultyID==5 or difficultyID==6 or difficultyID==16 then--英雄, 绿色
            return '|cffffff00'..string..'|r'--rgb= 0,1,0
        elseif difficultyID==16 or difficultyID==23 then--史诗, 紫色
            return '|cffff00ff'..string..'|r'--rgb= 1,0,1
        elseif difficultyID==8 then--挑战, 金色
            return '|cFFFF8000'..string..'|r'--rgb= 1,0.82,0
        elseif difficultyID==24 or difficultyID==33 then--时光, 天蓝色
            return '|cFF00B2FF'..string..'|r'-- rgb= 0,0.7,1
        else
            return string
        end
    end
end

e.Cstr=function(self, tab)--self, {size, copyFont, changeFont, color={r=,g=,b=,a=}, layer=, justifyH}
    tab= tab or {}--Fonts.xml FontStyles.xml
    self= self or UIParent
    local font= tab.changeFont or self:CreateFontString(nil, (tab.layer or 'OVERLAY'), 'GameFontNormal', 5)
    if tab.copyFont then
        --[[font:CopyFontObject(tab.copyFont)
        if tab.size then
            font:SetHeight(tab.szie)
        end]]
        local fontName, size, fontFlags = tab.copyFont:GetFont()
        font:SetFont(fontName, tab.size or size, fontFlags)
        font:SetTextColor(tab.copyFont:GetTextColor())
        font:SetFontObject(tab.copyFont:GetFontObject())
        font:SetShadowColor(tab.copyFont:GetShadowColor())
        font:SetShadowOffset(tab.copyFont:GetShadowOffset())
    else
        if (e.onlyChinese or LOCALE_zhCN) then
            font:SetFont('Fonts\\ARHei.ttf', (tab.size or 12), 'OUTLINE')
        else
            local fontName= font:GetFont()
            font:SetFont(fontName, (tab.size or 12), 'OUTLINE')--THICKOUTLINE
        end
        font:SetShadowOffset(1, -1)
        --font:SetShadowColor(0, 0, 0)
        font:SetJustifyH(tab.justifyH or 'LEFT')
        if not tab.color then
            font:SetTextColor(1, 0.82, 0)
        elseif type(tab.color)=='table' then
            font:SetTextColor(tab.color.r, tab.color.g, tab.color.b, tab.color.a or 1)
        else
            if e.Player.useColor then
                font:SetTextColor(e.Player.useColor.r, e.Player.useColor.g, e.Player.useColor.b, e.Player.useColor.a)
            else
                font:SetTextColor(0.82, 0.82, 0.82)
            end
        end
    end
    return font
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

e.Cbtn= function(self, tab)--type, icon, name, size
    tab=tab or {}
    self= self or UIParent
    local button
    if tab.type==false then
        button=CreateFrame('Button', tab.name, self, 'UIPanelButtonTemplate')--MagicButtonTemplate
    elseif tab.type==true then
        button=CreateFrame("Button", tab.name, self, "SecureActionButtonTemplate");
        button:SetHighlightAtlas(e.Icon.highlight)
        button:SetPushedAtlas(e.Icon.pushed)
    else
        button=CreateFrame('Button', tab.name, self)
        button:SetHighlightAtlas(e.Icon.highlight)
        button:SetPushedAtlas(e.Icon.pushed)
        if tab.icon~='hide' then
            if tab.texture then
                button:SetNormalTexture(tab.texture)
            elseif tab.atlas then
                button:SetNormalAtlas(tab.atlas)
            elseif tab.icon==true then
                button:SetNormalAtlas(e.Icon.icon)
            else
                button:SetNormalAtlas(e.Icon.disabled)
            end
        end
    end
    button:RegisterForClicks(LeftButtonDown, RightButtonDown)
    button:EnableMouseWheel(true)
    if tab.size then
        button:SetSize(tab.size[1], tab.size[2])
    end
    return button
end

e.Ccool=function(self, start, duration, modRate, HideCountdownNumbers, Reverse, SwipeTexture, hideDrawBling)--冷却条
    if not (self or duration) then
        return
    end
    if not self.cooldown then
        self.cooldown= CreateFrame("Cooldown", nil, self, 'CooldownFrameTemplate')
        self.cooldown:SetUseCircularEdge(true)--设置边缘纹理是否应该遵循圆形图案而不是方形编辑框
        self.cooldown:SetDrawBling(not hideDrawBling)--闪光
        self.cooldown:SetDrawEdge(true)--冷却动画的移动边缘绘制亮线
        self.cooldown:SetHideCountdownNumbers(HideCountdownNumbers)--隐藏数字
        self.cooldown:SetReverse(Reverse)--控制冷却动画的方向
        self.cooldown:SetFrameStrata("TOOLTIP")
        self.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge");
        if SwipeTexture then
            self.cooldown:SetSwipeTexture('Interface\\CHARACTERFRAME\\TempPortraitAlphaMask')--圆框架
        end
    end
    start=start or GetTime()
    self.cooldown:SetCooldown(start, duration, modRate)
end
e.SetItemSpellCool= function(self, item, spell)
    if item then
        local startTime, duration = GetItemCooldown(item)
        e.Ccool(self, startTime, duration, nil, true, nil, true)
    elseif spell then
        local start, duration, _, modRate = GetSpellCooldown(spell)
        e.Ccool(self, start, duration, modRate, true, nil, true)--冷却条
    elseif self.cooldown then
        self.cooldown:Clear()
    end
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
--[[
e.HEX=function(r, g, b, a)
    a=a or 1
    r = r <= 1 and r >= 0 and r or 0
    g = g <= 1 and g >= 0 and g or 0
    b = b <= 1 and b >= 0 and b or 0
    a = a <= 1 and a >= 0 and a or 0
    return string.format("%02x%02x%02x%02x",a*255, r*255, g*255, b*255)
end]]


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
]]

e.Cbtn2= function(name, parent, showTexture, rightClick)
    local button= CreateFrame("Button", name, parent or UIParent, "SecureActionButtonTemplate")
    local size= e.toolsFrame.size
    button:SetSize(size,size)
    if rightClick then
        button:RegisterForClicks(LeftButtonDown, RightButtonDown)
    elseif rightClick~=false then
        button:RegisterForClicks(LeftButtonDown)
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
    button.background:SetAlpha(0.5)
    button.background:AddMaskTexture(button.mask)

    button.texture=button:CreateTexture(nil, 'BORDER')

    button.texture:SetPoint("TOPLEFT", button, "TOPLEFT", 4, -4);
	button.texture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -6, 6);
    button.texture:AddMaskTexture(button.mask)
    button.texture:SetShown(showTexture)

    button.border=button:CreateTexture(nil, 'ARTWORK')
    button.border:SetAllPoints(button)
    button.border:SetAtlas('bag-reagent-border')
    if e.Player.useColor then--使用职业颜色
        button.border:SetVertexColor(e.Player.useColor.r, e.Player.useColor.g, e.Player.useColor.b, e.Player.useColor.a)
        button.border:SetAlpha(0.5)
    end

    return button
end

e.toolsFrame=CreateFrame('Frame')--TOOLS 框架
e.toolsFrame:SetSize(1,1)
e.toolsFrame:SetShown(false)
e.toolsFrame.last=e.toolsFrame
e.toolsFrame.line=1
e.toolsFrame.index=0
e.toolsFrame.size= 30
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

e.Chat=function(text, name, setPrint)
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

e.Say=function(type, name, wow, text)
    local chat= SELECTED_DOCK_FRAME
    local msg = chat.editBox:GetText() or ''
    if text and text==msg then
        text=''
    else
        text= text or ''
    end
    if msg:find('/') then msg='' end
    msg=' '..msg
    if name then
        if wow then
            ChatFrame_SendBNetTell(name..msg..(text or ''))
        else
            ChatFrame_OpenChat("/w " ..name..msg..(text or ''), chat);
        end
    elseif type then
        ChatFrame_OpenChat(type..msg..(text or ''), chat)
    end
end

e.GetKeystoneScorsoColor= function(score, texture, overall)--地下城史诗, 分数, 颜色 C_ChallengeMode.GetOverallDungeonScore()
    if not score or score==0 then
        return ''
    else
        local color= not overall and C_ChallengeMode.GetDungeonScoreRarityColor(score) or C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(score)
        if color  then
            score= color:WrapTextInColorCode(score)
        end
        if texture then
            score= '|T4352494:0|t'..score
        end
        return score, color
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
            return '|A:transmog-icon-checkmark:0:0|a', numCollected, numAll, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已收集' or COLLECTED)..'|r'
        elseif numAll <=9 then
            if numCollected==0 then
                return e.Icon.number2:format(numAll-numCollected), numCollected, numAll, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
            else
                return e.Icon.number2:format(numAll-numCollected), numCollected, numAll, '|cnYELLOW_FONT_COLOR:'..numCollected..'/'..numAll..' '..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
            end
        else
            if numCollected==0 then
                return '|cnRED_FONT_COLOR:'..numAll-numCollected..'|r ', numCollected, numAll, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
            else
                return ' |cnYELLOW_FONT_COLOR:'..numAll-numCollected..'|r ', numCollected, numAll, '|cnYELLOW_FONT_COLOR:'..numCollected..'/'..numAll..' '..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
            end
        end
    end
end

e.GetItemCollected= function(link, sourceID, icon)--物品是否收集
    sourceID= sourceID or link and select(2, C_TransmogCollection.GetItemInfo(link))
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
                return '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已收集' or COLLECTED)..'|r', sourceInfo.isCollected, isSelf
            end
        else
            if icon then
                if isSelf then
                    return e.Icon.okTransmog2, sourceInfo.isCollected, isSelf
                else
                    return e.Icon.star2, sourceInfo.isCollected, isSelf
                end
            else
                return '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r', sourceInfo.isCollected, isSelf
            end
        end
    end
end

e.GetPetCollectedNum= function(speciesID, itemID)--总收集数量， 25 25 25， 3/3
    speciesID = speciesID or itemID and select(13, C_PetJournal.GetPetInfoByItemID(itemID))--宠物物品
    if not speciesID then
        return
    end
    local AllCollected, CollectedNum, CollectedText
    local numPets, numOwned = C_PetJournal.GetNumPets()
    if numPets and numOwned and numPets>0 then
        if numPets<numOwned or numPets<3 then
            AllCollected= e.MK(numOwned, 3)
        else
            AllCollected= e.MK(numOwned,3)..'/'..e.MK(numPets,3).. (' %i%%'):format(numOwned/numPets*100)
        end
    end

    local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)
    if numCollected and limit and limit>0 then
        if numCollected>0 then
            local text2
            for index= 1 ,numOwned do
                local petID, speciesID2, _, _, level = C_PetJournal.GetPetInfoByIndex(index)
                if speciesID2==speciesID and petID and level then
                    local rarity = select(5, C_PetJournal.GetPetStats(petID))
                    local col= rarity and select(4, GetItemQualityColor(rarity-1))
                    if col then
                        text2= text2 and text2..' ' or ''
                        text2= text2..'|c'..col..level..'|r'
                    end
                end
            end
            CollectedNum= text2
        end

        if numCollected==0 then
            CollectedText='|cnRED_FONT_COLOR:'..numCollected..'|r/'..limit
        elseif limit and numCollected==limit and limit>0 then
            CollectedText= '|cnGREEN_FONT_COLOR:'..numCollected..'/'..limit..'|r'
        else
            CollectedText= numCollected..'/'..limit
        end
    end
    return AllCollected, CollectedNum, CollectedText
end

e.GetMountCollected= function(mountID)--坐骑, 收集数量
    if select(11, C_MountJournal.GetMountInfoByID(mountID)) then
        return '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已收集' or COLLECTED)..'|r'
    else
        return '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
    end
end



e.ExpansionLevel= GetExpansionLevel()
e.GetExpansionText= function(expacID, questID)--版本数据
    expacID= expacID or questID and GetQuestExpansion(questID)
    if expacID then
        if e.ExpansionLevel==expacID then
            return _G['EXPANSION_NAME'..expacID], (e.onlyChinese and '版本' or GAME_VERSION_LABEL)..' '..(expacID+1)
        else
            return '|cff606060'.._G['EXPANSION_NAME'..expacID]..'|r', '|cff606060'..(e.onlyChinese and '版本' or GAME_VERSION_LABEL)..' '..(expacID+1)..'|r'
        end
    end
end

--e.GetTooltipData({bag={bag=nil, slot=nil}, guidBank={tab=nil, slot=nil}, merchant={slot, buyBack=true}, inventory=nil, hyperLink=nil, itemID=nil, text={}, onlyText=nil, wow=nil, onlyWoW=nil, red=nil, onlyRed=nil})--物品提示，信息
e.GetTooltipData= function(tab)
    local tooltipData
    if tab.itemID and C_Heirloom.IsItemHeirloom(tab.itemID) then
        tooltipData= C_TooltipInfo.GetHeirloomByItemID(tab.itemID)
    elseif tab.bag then
        tooltipData= C_TooltipInfo.GetBagItem(tab.bag.bag, tab.bag.slot)
    elseif tab.guidBank then-- guidBank then
        tooltipData= C_TooltipInfo.GetGuildBankItem(tab.guidBank.tab, tab.guidBank.slot)
    elseif tab.merchant then
        if tab.merchant.buyBack then
            tooltipData= C_TooltipInfo.GetBuybackItem(tab.merchant.slot)
        else
            tooltipData= C_TooltipInfo.GetMerchantItem(tab.merchant.slot)--slot
        end
    elseif tab.inventory then
        tooltipData= C_TooltipInfo.GetInventoryItem('player', tab.inventory)
    end
    tooltipData= tooltipData or tab.hyperLink and C_TooltipInfo.GetHyperlink(tab.hyperLink)
    local date={
        red=false,
        wow=false,
        text={},
    }
    if tooltipData and tooltipData.lines then
        local numText= tab.text and #tab.text or 0
        local find= numText>0 or tab.wow
        local numFind=0
        for _, line in ipairs(tooltipData.lines) do--是否
            TooltipUtil.SurfaceArgs(line)
            if tab.red and not date.red then
                local leftHex=line.leftColor and line.leftColor:GenerateHexColor()
                local rightHex=line.rightColor and line.rightColor:GenerateHexColor()
                if leftHex == 'ffff2020' or leftHex=='fefe1f1f' or rightHex== 'ffff2020' or rightHex=='fefe1f1f' then-- or hex=='fefe7f3f' then
                    date.red=true
                    if tab.onlyRed then
                        break
                    end
                end
            end
            if line.leftText and find then
                if tab.text then
                    for _, text in pairs(tab.text) do
                        if line.leftText:find(text) or line.leftText==text then
                            date.text[text]= line.leftText:match(text) or line.leftText
                            numFind= numFind +1
                            if tab.onlyText and numFind==numText then
                                break
                            end
                        end
                    end
                end
                if tab.wow and not date.wow and (line.leftText==ITEM_BNETACCOUNTBOUND or line.leftText==ITEM_ACCOUNTBOUND) then--暴雪游戏通行证绑定, 账号绑定
                    date.wow=true
                    if tab.onlyWoW then
                        break
                    end
                end
            end
        end
    end
    return date
end

e.PlaySound= function(soundKitID, setPlayerSound)--播放, 声音 SoundKitConstants.lua e.PlaySound()--播放, 声音
    if not C_CVar.GetCVarBool('Sound_EnableAllSound') or C_CVar.GetCVar('Sound_MasterVolume')=='0' or (not setPlayerSound and not e.setPlayerSound) then
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
    PlaySound(soundKitID or SOUNDKIT.GS_CHARACTER_SELECTION_ENTER_WORLD, channel)--SOUNDKIT.READY_CHECK SOUNDKIT.LFG_ROLE_CHECK SOUNDKIT.LFG_ROLE_CHECK SOUNDKIT.IG_PLAYER_INVITE
end

e.set_CVar= function(name, value)-- e.set_CVar()--设置 Cvar
    if value~= nil then
        C_CVar.SetCVar(name, value and '1' or '0')
    end
end


--###############
--显示, 物品, 属性
--###############
e.Get_Item_Stats= function(link)--物品，次属性，表
    if not link then
        return {}
    end
    local num, tab= 0, {}
    local info= GetItemStats(link) or {}
    if info['ITEM_MOD_CRIT_RATING_SHORT'] then
        table.insert(tab, {text=e.onlyChinese and '爆' or strlower(e.WA_Utf8Sub(STAT_CRITICAL_STRIKE, 1, 2)), value=info['ITEM_MOD_CRIT_RATING_SHORT'] or 1, index=1})
        num= num +1
    end
    if info['ITEM_MOD_HASTE_RATING_SHORT'] then
        table.insert(tab, {text=e.onlyChinese and '急' or strlower(e.WA_Utf8Sub(STAT_HASTE, 1,2)), value=info['ITEM_MOD_HASTE_RATING_SHORT'] or 1, index=1})
        num= num +1
    end
    if info['ITEM_MOD_MASTERY_RATING_SHORT'] then
        table.insert(tab, {text=e.onlyChinese and '精' or strlower(e.WA_Utf8Sub(STAT_MASTERY, 1,2)), value=info['ITEM_MOD_MASTERY_RATING_SHORT'] or 1, index=1})
        num= num +1
    end
    if info['ITEM_MOD_VERSATILITY'] then
        table.insert(tab, {text=e.onlyChinese and '全' or strlower(e.WA_Utf8Sub(STAT_VERSATILITY, 1,2)), value=info['ITEM_MOD_VERSATILITY'] or 1, index=1})
        num= num +1
    end
    if num<4 and info['ITEM_MOD_CR_AVOIDANCE_SHORT'] then
        table.insert(tab, {text=e.onlyChinese and '闪' or strlower(e.WA_Utf8Sub(ITEM_MOD_CR_AVOIDANCE_SHORT, 1,2)), value=info['ITEM_MOD_CR_AVOIDANCE_SHORT'], index=2})
        num= num +1
    end
    if num<4 and info['ITEM_MOD_CR_LIFESTEAL_SHORT'] then
        table.insert(tab, {text=e.onlyChinese and '吸' or strlower(e.WA_Utf8Sub(ITEM_MOD_CR_LIFESTEAL_SHORT, 1,2)), value=info['ITEM_MOD_CR_LIFESTEAL_SHORT'] or 1, index=2})
        num= num +1
    end
    --[[if num<4 and info['ITEM_MOD_CR_AVOIDANCE_SHORT'] then
        table.insert(tab, {text=e.onlyChinese and '溅' or strlower(e.WA_Utf8Sub(ITEM_MOD_CR_MULTISTRIKE_SHORT, 1,2)), value=info['ITEM_MOD_CR_MULTISTRIKE_SHORT'] or 1, index=2})
        num= num +1
    end]]
    if num<4 and info['ITEM_MOD_CR_SPEED_SHORT'] then
        table.insert(tab, {text=e.onlyChinese and '速' or strlower(e.WA_Utf8Sub(ITEM_MOD_CR_SPEED_SHORT, 1,2)), value=info['ITEM_MOD_CR_SPEED_SHORT'] or 1, index=2})
        num= num +1
    end
    return tab
end

--e.Set_Item_Stats(self, itemLink, {point=self.icon, itemID=nil, hideSet=false, hideLevel=false, hideStats=false})--设置，物品，4个次属性，套装，装等，
e.Set_Item_Stats = function(self, link, setting)
    if not self then
        return
    end
    local setID, itemLevel
    --setting= setting or {}

    if link then
        if not setting.hideSet then
            setID= select(16 , GetItemInfo(link))--套装
            if setID and not self.itemSet then
                self.itemSet= self:CreateTexture()
                self.itemSet:SetAtlas(e.Icon.pushed)
                self.itemSet:SetAllPoints(setting.point or self)
            end
        end

        if not setting.hideLevel then--物品, 装等
            local quality = C_Item.GetItemQualityByID(link)--颜色
            if quality==7 then
                local itemLevelStr=ITEM_LEVEL:gsub('%%d', '%(%%d%+%)')--"物品等级：%d"
                local dateInfo= e.GetTooltipData({hyperLink=link, itemID= setting.itemID or GetItemInfoInstant(link), text={itemLevelStr}, onlyText=true})--物品提示，信息
                itemLevel= tonumber(dateInfo.text[itemLevelStr])
            end
            itemLevel= itemLevel or GetDetailedItemLevelInfo(link)
            if itemLevel and itemLevel<3 then
                itemLevel=nil
            end
            local avgItemLevel= itemLevel and select(2, GetAverageItemLevel())--已装备, 装等
            if itemLevel and avgItemLevel then
                local lv = itemLevel- avgItemLevel
                --if lv>=7 then
                  --  itemLevel= GREEN_FONT_COLOR_CODE..itemLevel..'|r'
                --elseif quality and quality<= 6 then
                    if lv <= -6  then
                        itemLevel =RED_FONT_COLOR_CODE..itemLevel..'|r'
                    elseif lv>=7 then
                        itemLevel= GREEN_FONT_COLOR_CODE..itemLevel..'|r'
                    else
                        local hexColor= quality and select(4, GetItemQualityColor(quality))
                        if hexColor then
                            itemLevel='|c'..hexColor..itemLevel..'|r'
                        end
                    end
                --end
            end
            if not self.itemLevel and itemLevel then
                self.itemLevel= e.Cstr(self, {justifyH='CENTER'})--nil, nil, nil,nil,nil, 'CENTER')
                self.itemLevel:SetShadowOffset(2,-2)
                self.itemLevel:SetPoint('CENTER', setting.point)
            end
        end
    end
    if self.itemSet then self.itemSet:SetShown(setID) end--套装
    if self.itemLevel then self.itemLevel:SetText(itemLevel or '') end--装等

    local tab= not setting.hideStats and e.Get_Item_Stats(link) or {}--物品，次属性，表
    table.sort(tab, function(a,b) return a.value>b.value and a.index== b.index end)
    for index=1 ,4 do
        local text=self['statText'..index]
        if tab[index] then
            if not text then
                text= e.Cstr(self,{justifyH= (index==2 or index==4) and 'RIGHT'})
                if index==1 then
                    text:SetPoint('BOTTOMLEFT', setting.point or self, 'BOTTOMLEFT')
                elseif index==2 then
                    text:SetPoint('BOTTOMRIGHT', setting.point or self, 'BOTTOMRIGHT', 4,0)
                elseif index==3 then
                    text:SetPoint('TOPLEFT', setting.point or self, 'TOPLEFT')
                else
                    text:SetPoint('TOPRIGHT', setting.point or self, 'TOPRIGHT',4,0)
                end
                self['statText'..index]=text
            end
            text:SetText(tab[index].text)
        elseif text then
            text:SetText('')
        end
    end
end

local function set_Frame_Color(self, setR, setG, setB, setA, setHex)
    if self then
        local type= self:GetObjectType()
        if type=='FontString' then
            self:SetTextColor(setR, setG, setB,setA)
        elseif type=='Texture' then
            self:SetColorTexture(setR, setG, setB,setA)
        end
        self.r, self.g, self.b, self.a, self.hex= setR, setG, setB, setA, '|c'..setHex
    end
end
e.RGB_to_HEX=function(setR, setG, setB, setA, self)--RGB转HEX
    setA= setA or 1
	setR = setR <= 1 and setR >= 0 and setR or 0
	setG = setG <= 1 and setG >= 0 and setG or 0
	setB = setA <= 1 and setB >= 0 and setB or 0
	setA = setA <= 1 and setA >= 0 and setA or 0
    local hex=format("%02x%02x%02x%02x", setA*255, setR*255, setG*255, setB*255)
    set_Frame_Color(self, setR, setG, setB, setA, hex)
	return hex
end

e.HEX_to_RGB=function(hexColor, self)--HEX转RGB -- ColorUtil.lua
	if hexColor then
		hexColor= hexColor:gsub('|c', '')
        hexColor= hexColor:gsub('#', '')
		hexColor= hexColor:gsub(' ','')
        local len= #hexColor
		if len == 8 then
            local colorA= tonumber(hexColor:sub(1, 2), 16)
            local colorR= tonumber(hexColor:sub(3, 4), 16)
            local colorG= tonumber(hexColor:sub(5, 6), 16)
            local colorB= tonumber(hexColor:sub(7, 8), 16)
            if colorA and colorR and colorG and colorB then
                colorA, colorR, colorG, colorB= colorA/255, colorR/255, colorG/255, colorB/255
                set_Frame_Color(self, colorR, colorG, colorB, colorA, hexColor)
                return colorR, colorG, colorB, colorA
            end
        elseif len==6 then
            local colorR= tonumber(hexColor:sub(1, 2), 16)
            local colorG= tonumber(hexColor:sub(3, 4), 16)
            local colorB= tonumber(hexColor:sub(5, 6), 16)
            if colorR and colorG and colorB then
                colorR, colorG, colorB= colorR/255, colorG/255, colorB/255
                hexColor= 'ff'..hexColor
                set_Frame_Color(self, colorR, colorG, colorB, 1, hexColor)
                return colorR, colorG, colorB, 1
            end
		end
	end
end

e.Get_ColorFrame_RGBA= function()--取得, ColorFrame, 颜色
	local a= OpacitySliderFrame:IsShown() and OpacitySliderFrame:GetValue() or 0
	local r, g, b = ColorPickerFrame:GetColorRGB()
	return r, g, b, 1-a
end

e.ShowColorPicker= function(valueR, valueG, valueB, valueA, func, cancelFunc)
    ColorPickerFrame:SetShown(false); -- Need to run the OnShow handler.
    valueR= valueR or 1
    valueG= valueG or 0.8
    valueB= valueB or 0
    valueA= valueA or 1
    --valueA= 1- valueA
    ColorPickerFrame.hasOpacity= true
    --ColorPickerFrame.previousValues = {valueR, valueG , valueB , valueA}
    ColorPickerFrame.func= func
    ColorPickerFrame.opacityFunc= func
    ColorPickerFrame.cancelFunc = cancelFunc or func
    ColorPickerFrame:SetColorRGB(valueR, valueG, valueB)
    ColorPickerFrame.opacity = 1- valueA;
    ColorPickerFrame:SetShown(true)
end

e.Reload= function()
    local bat= UnitAffectingCombat('player') and e.IsEncouter_Start
    if not bat or not IsInInstance() then
        C_UI.Reload()
    else
        print(id, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
    end
end

e.Create_Slider= function(self, tab)--e.Create_Slider(self, {w= ,h=, min=, max=, value=, setp=, color=, text=, func=})
    local slider= CreateFrame("Slider", nil, self, 'OptionsSliderTemplate')
    slider:SetSize(tab.w or 200, tab.h or 18)
    slider:SetMinMaxValues(tab.min, tab.max)
    slider:SetValue(tab.value)
    slider.Low:SetText(tab.text..' '..tab.min)
    slider.High:SetText(tab.max)
    slider.Text:SetText(tab.value)
    slider:SetValueStep(tab.setp)
    slider:SetScript('OnValueChanged', tab.func)
    if tab.color then
        slider.Low:SetTextColor(1,0,1)
        slider.High:SetTextColor(1,0,1)
        slider.Text:SetTextColor(1,0,1)
        slider.NineSlice.BottomEdge:SetVertexColor(1,0,1)
        slider.NineSlice.TopEdge:SetVertexColor(1,0,1)
        slider.NineSlice.RightEdge:SetVertexColor(1,0,1)
        slider.NineSlice.LeftEdge:SetVertexColor(1,0,1)
        slider.NineSlice.TopRightCorner:SetVertexColor(1,0,1)
        slider.NineSlice.TopLeftCorner:SetVertexColor(1,0,1)
        slider.NineSlice.BottomRightCorner:SetVertexColor(1,0,1)
        slider.NineSlice.BottomLeftCorner:SetVertexColor(1,0,1)
    end
    return slider
end

e.Magic= function(text)
    local tab= {'%.', '%(','%)','%+', '%-', '%*', '%?', '%[', '%^'}
    for _,v in pairs(tab) do
        text= text:gsub(v,'%%'..v)
    end
    tab={
        ['%%%d%$s']= '%(%.%-%)',
        ['%%s']= '%(%.%-%)',
        ['%%%d%$d']= '%(%%d%+%)',
        ['%%d']= '%(%%d%+%)',
    }
    local find
    for k,v in pairs(tab) do
        text= text:gsub(k,v)
        find=true
    end
    if find then
        tab={'%$'}
    else
        tab={'%%','%$'}
    end
    for _, v in pairs(tab) do
        text= text:gsub(v,'%%'..v)
    end
    return text
end


local LibRangeCheck = LibStub("LibRangeCheck-2.0")
e.GetRange= function(unit, checkVisible)--WA Prototypes.lua
    return LibRangeCheck:GetRange(unit, checkVisible);
end

e.CheckRange= function(unit, range, operator)
    local min, max= LibRangeCheck:GetRange(unit, true);
    if (operator == "<=") then
        return (max or 999) <= range;
    else
        return (min or 0) >= range;
    end
end

e.Set_HelpTips= function(tab)--e.Set_HelpTips({frame=, topoint=, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, onlyOne=nil, show=})--设置，提示
    if tab.show and not tab.frame.HelpTips then
        tab.frame.HelpTips= e.Cbtn(tab.frame, {layer='OVERLAY',size=tab.size and {tab.size[1], tab.size[2]} or {40,40}})-- button:CreateTexture(nil, 'OVERLAY')
        if tab.point=='right' then
            tab.frame.HelpTips:SetPoint('BOTTOMLEFT', tab.topoint or tab.frame, 'BOTTOMRIGHT',0,-10)
            tab.frame.HelpTips:SetNormalAtlas(tab.atlas or e.Icon.toLeft)
        else--left
            tab.frame.HelpTips:SetPoint('BOTTOMRIGHT', tab.topoint or tab.frame, 'BOTTOMLEFT',0,-10)
            tab.frame.HelpTips:SetNormalAtlas(tab.atlas or e.Icon.toRight)
        end
        if tab.color then
            SetItemButtonNormalTextureVertexColor(tab.frame.HelpTips, tab.color.r, tab.color.g, tab.color.b, tab.color.a or 1);
        end
        tab.frame.HelpTips.elapsed=0
        tab.frame.HelpTips:SetScript('OnUpdate', function(self, elapsed)
            self.elapsed= self.elapsed + elapsed
            if self.elapsed>0.5 then
                self.elapsed=0
                self:SetScale(self:GetScale()==1 and 0.5 or 1)
            end
        end)
        tab.frame.HelpTips:SetScript('OnEnter', function(self) self:SetShown(false) end)
        if tab.onlyOne then
            tab.frame.HelpTips.onlyOne=true
        end
    end
    if tab.frame.HelpTips and not tab.frame.HelpTips.onlyOne then
        tab.frame.HelpTips:SetShown(tab.show)
    end
end

local Realms={}
if e.Player.region==3 then--EU 
    Realms = {--3 EU
        ["Aegwynn"]="deDE", ["Alexstrasza"]="deDE", ["Alleria"]="deDE", ["Aman’Thul"]="deDE", ["Aman'Thul"]="deDE", ["Ambossar"]="deDE",
        ["Anetheron"]="deDE", ["Antonidas"]="deDE", ["Anub'arak"]="deDE", ["Area52"]="deDE", ["Arthas"]="deDE",
        ["Arygos"]="deDE", ["Azshara"]="deDE", ["Baelgun"]="deDE", ["Blackhand"]="deDE", ["Blackmoore"]="deDE",
        ["Blackrock"]="deDE", ["Blutkessel"]="deDE", ["Dalvengyr"]="deDE", ["DasKonsortium"]="deDE",
        ["DasSyndikat"]="deDE", ["DerMithrilorden"]="deDE", ["DerRatvonDalaran"]="deDE",
        ["DerAbyssischeRat"]="deDE", ["Destromath"]="deDE", ["Dethecus"]="deDE", ["DieAldor"]="deDE",
        ["DieArguswacht"]="deDE", ["DieNachtwache"]="deDE", ["DieSilberneHand"]="deDE", ["DieTodeskrallen"]="deDE",
        ["DieewigeWacht"]="deDE", ["DunMorogh"]="deDE", ["Durotan"]="deDE", ["Echsenkessel"]="deDE", ["Eredar"]="deDE",
        ["FestungderStürme"]="deDE", ["Forscherliga"]="deDE", ["Frostmourne"]="deDE", ["Frostwolf"]="deDE",
        ["Garrosh"]="deDE", ["Gilneas"]="deDE", ["Gorgonnash"]="deDE", ["Gul'dan"]="deDE", ["Kargath"]="deDE", ["Kel'Thuzad"]="deDE",
        ["Khaz'goroth"]="deDE", ["Kil'jaeden"]="deDE", ["Krag'jin"]="deDE", ["KultderVerdammten"]="deDE", ["Lordaeron"]="deDE",
        ["Lothar"]="deDE", ["Madmortem"]="deDE", ["Mal'Ganis"]="deDE", ["Malfurion"]="deDE", ["Malorne"]="deDE", ["Malygos"]="deDE", ["Mannoroth"]="deDE",
        ["Mug'thol"]="deDE", ["Nathrezim"]="deDE", ["Nazjatar"]="deDE", ["Nefarian"]="deDE", ["Nera'thor"]="deDE", ["Nethersturm"]="deDE",
        ["Norgannon"]="deDE", ["Nozdormu"]="deDE", ["Onyxia"]="deDE", ["Perenolde"]="deDE", ["Proudmoore"]="deDE", ["Rajaxx"]="deDE", ["Rexxar"]="deDE",
        ["Sen'jin"]="deDE", ["Shattrath"]="deDE", ["Taerar"]="deDE", ["Teldrassil"]="deDE", ["Terrordar"]="deDE", ["Theradras"]="deDE", ["Thrall"]="deDE",
        ["Tichondrius"]="deDE", ["Tirion"]="deDE", ["Todeswache"]="deDE", ["Ulduar"]="deDE", ["Un'Goro"]="deDE", ["Vek'lor"]="deDE", ["Wrathbringer"]="deDE",
        ["Ysera"]="deDE", ["ZirkeldesCenarius"]="deDE", ["Zuluhed"]="deDE",

        ["Arakarahm"]="frFR", ["Arathi"]="frFR", ["Archimonde"]="frFR", ["Chantséternels"]="frFR", ["Cho’gall"]="frFR", ["Cho'gall"]="frFR",
        ["ConfrérieduThorium"]="frFR", ["ConseildesOmbres"]="frFR", ["Dalaran"]="frFR", ["Drek’Thar"]="frFR", ["Drek'Thar"]="frFR",
        ["Eitrigg"]="frFR", ["Eldre’Thalas"]="frFR", ["Eldre'Thalas"]="frFR", ["Elune"]="frFR", ["Garona"]="frFR", ["Hyjal"]="frFR", ["Illidan"]="frFR",
        ["Kael’thas"]="frFR", ["Kael'thas"]="frFR", ["KhazModan"]="frFR", ["KirinTor"]="frFR", ["Krasus"]="frFR", ["LaCroisadeécarlate"]="frFR",
        ["LesClairvoyants"]="frFR", ["LesSentinelles"]="frFR", ["MarécagedeZangar"]="frFR", ["Medivh"]="frFR", ["Naxxramas"]="frFR",
        ["Ner’zhul"]="frFR", ["Ner'zhul"]="frFR", ["Rashgarroth"]="frFR", ["Sargeras"]="frFR", ["Sinstralis"]="frFR", ["Suramar"]="frFR",
        ["Templenoir"]="frFR", ["Throk’Feroth"]="frFR", ["Throk'Feroth"]="frFR", ["Uldaman"]="frFR", ["Varimathras"]="frFR", ["Vol’jin"]="frFR",
        ["Vol'jin"]="frFR", ["Ysondre"]="frFR",

        ["AeriePeak"]="enGB", ["Agamaggan"]="enGB", ["Aggramar"]="enGB", ["Ahn'Qiraj"]="enGB", ["Al'Akir"]="enGB", ["Alonsus"]="enGB", ["Anachronos"]="enGB",
        ["Arathor"]="enGB", ["ArenaPass"]="enGB", ["ArenaPass1"]="enGB", ["ArgentDawn"]="enGB", ["Aszune"]="enGB", ["Auchindoun"]="enGB", ["AzjolNerub"]="enGB",
        ["Azuremyst"]="enGB", ["Balnazzar"]="enGB", ["Blade'sEdge"]="enGB", ["Bladefist"]="enGB", ["Bloodfeather"]="enGB", ["Bloodhoof"]="enGB", ["Bloodscalp"]="enGB",
        ["Boulderfist"]="enGB", ["BronzeDragonflight"]="enGB", ["Bronzebeard"]="enGB", ["BurningBlade"]="enGB", ["BurningLegion"]="enGB", ["BurningSteppes"]="enGB",
        ["C'Thun"]="enGB", ["ChamberofAspects"]="enGB", ["Chromaggus"]="enGB", ["ColinasPardas"]="enGB", ["Crushridge"]="enGB", ["CultedelaRivenoire"]="enGB",
        ["Daggerspine"]="enGB", ["DarkmoonFaire"]="enGB", ["Darksorrow"]="enGB", ["Darkspear"]="enGB", ["Deathwing"]="enGB", ["DefiasBrotherhood"]="enGB",
        ["Dentarg"]="enGB", ["Doomhammer"]="enGB", ["Draenor"]="enGB", ["Dragonblight"]="enGB", ["Dragonmaw"]="enGB", ["Drak'thul"]="enGB", ["Dunemaul"]="enGB",
        ["EarthenRing"]="enGB", ["EmeraldDream"]="enGB", ["Emeriss"]="enGB", ["Eonar"]="enGB", ["Executus"]="enGB", ["Frostmane"]="enGB", ["Frostwhisper"]="enGB",
        ["Genjuros"]="enGB", ["Ghostlands"]="enGB", ["GrimBatol"]="enGB", ["Hakkar"]="enGB", ["Haomarush"]="enGB", ["Hellfire"]="enGB", ["Hellscream"]="enGB",
        ["Jaedenar"]="enGB", ["Karazhan"]="enGB", ["Kazzak"]="enGB", ["Khadgar"]="enGB", ["Kilrogg"]="enGB", ["Kor'gall"]="enGB", ["KulTiras"]="enGB", ["LaughingSkull"]="enGB",
        ["Lightbringer"]="enGB", ["Lightning'sBlade"]="enGB", ["Magtheridon"]="enGB", ["Mazrigos"]="enGB", ["Moonglade"]="enGB", ["Nagrand"]="enGB",
        ["Neptulon"]="enGB", ["Nordrassil"]="enGB", ["Outland"]="enGB", ["Quel'Thalas"]="enGB", ["Ragnaros"]="enGB", ["Ravencrest"]="enGB", ["Ravenholdt"]="enGB",
        ["Runetotem"]="enGB", ["Saurfang"]="enGB", ["ScarshieldLegion"]="enGB", ["Shadowsong"]="enGB", ["ShatteredHalls"]="enGB", ["ShatteredHand"]="enGB",
        ["Silvermoon"]="enGB", ["Skullcrusher"]="enGB", ["Spinebreaker"]="enGB", ["Sporeggar"]="enGB", ["SteamwheedleCartel"]="enGB", ["Stormrage"]="enGB",
        ["Stormreaver"]="enGB", ["Stormscale"]="enGB", ["Sunstrider"]="enGB", ["Sylvanas"]="enGB", ["Talnivarr"]="enGB", ["TarrenMill"]="enGB", ["Terenas"]="enGB",
        ["Terokkar"]="enGB", ["TheMaelstrom"]="enGB", ["TheSha'tar"]="enGB", ["TheVentureCo"]="enGB", ["Thunderhorn"]="enGB", ["Trollbane"]="enGB", ["Turalyon"]="enGB",
        ["Twilight'sHammer"]="enGB", ["TwistingNether"]="enGB", ["Vashj"]="enGB", ["Vek'nilash"]="enGB", ["Wildhammer"]="enGB", ["Xavius"]="enGB", ["Zenedar"]="enGB",

        ["Nemesis"]="itIT", ["Pozzodell'Eternità"]="itIT",

        ["DunModr"]="esES", ["EuskalEncounter"]="esES", ["Exodar"]="esES", ["LosErrantes"]="esES",
        ["Minahonda"]="esES", ["Sanguino"]="esES", ["Shen'dralar"]="esES",
        ["Tyrande"]="esES", ["Uldum"]="esES", ["Zul'jin"]="esES",

        ["Азурегос"]="ruRU", ["Борейскаятундра"]="ruRU", ["ВечнаяПесня"]="ruRU", ["Галакронд"]="ruRU", ["Голдринн"]="ruRU",
        ["Гордунни"]="ruRU", ["Гром"]="ruRU", ["Дракономор"]="ruRU", ["Корольлич"]="ruRU", ["Пиратскаябухта"]="ruRU", ["Подземье"]="ruRU", ["ПропускнаАрену1"]="ruRU",
        ["Разувий"]="ruRU", ["Ревущийфьорд"]="ruRU", ["СвежевательДуш"]="ruRU", ["Седогрив"]="ruRU", ["СтражСмерти"]="ruRU", ["Термоштепсель"]="ruRU",
        ["ТкачСмерти"]="ruRU", ["ЧерныйШрам"]="ruRU", ["Ясеневыйлес"]="ruRU",

        ["Aggra(Português)"]="ptBR",
    }

elseif e.Player.region==1 then
    Realms = {--1 US
        ["Aman'Thul"]="oce", ["Barthilas"]="oce", ["Caelestrasz"]="oce", ["Dath'Remar"]="oce", ["Dreadmaul"]="oce",
        ["Frostmourne"]="oce", ["Gundrak"]="oce", ["Jubei'Thos"]="oce", ["Khaz'goroth"]="oce", ["Nagrand"]="oce",
        ["Saurfang"]="oce", ["Thaurissan"]="oce",

        ["Aerie Peak"]="usp", ["Anvilmar"]="usp", ["Arathor"]="usp", ["Antonidas"]="usp", ["Azuremyst"]="usp",
        ["Baelgun"]="usp", ["Blade's Edge"]="usp", ["Bladefist"]="usp", ["Bronzebeard"]="usp", ["Cenarius"]="usp",
        ["Darrowmere"]="usp", ["Draenor"]="usp", ["Dragonblight"]="usp", ["Echo Isles"]="usp", ["Galakrond"]="usp",
        ["Gnomeregan"]="usp", ["Hyjal"]="usp", ["Kilrogg"]="usp", ["Korialstrasz"]="usp", ["Lightbringer"]="usp",
        ["Misha"]="usp", ["Moonrunner"]="usp", ["Nordrassil"]="usp", ["Proudmoore"]="usp", ["Shadowsong"]="usp",
        ["Shu'Halo"]="usp", ["Silvermoon"]="usp", ["Skywall"]="usp", ["Suramar"]="usp", ["Uldum"]="usp", ["Uther"]="usp",
        ["Velen"]="usp", ["Windrunner"]="usp", ["Blackrock"]="usp", ["Blackwing Lair"]="usp", ["Bonechewer"]="usp",
        ["Boulderfist"]="usp", ["Coilfang"]="usp", ["Crushridge"]="usp", ["Daggerspine"]="usp", ["Dark Iron"]="usp",
        ["Destromath"]="usp", ["Dethecus"]="usp", ["Dragonmaw"]="usp", ["Dunemaul"]="usp", ["Frostwolf"]="usp",
        ["Gorgonnash"]="usp", ["Gurubashi"]="usp", ["Kalecgos"]="usp", ["Kil'Jaeden"]="usp", ["Lethon"]="usp", ["Maiev"]="usp",
        ["Nazjatar"]="usp", ["Ner'zhul"]="usp", ["Onyxia"]="usp", ["Rivendare"]="usp", ["Shattered Halls"]="usp",
        ["Spinebreaker"]="usp", ["Spirestone"]="usp", ["Stonemaul"]="usp", ["Stormscale"]="usp", ["Tichondrius"]="usp",
        ["Ursin"]="usp", ["Vashj"]="usp", ["Blackwater Raiders"]="usp", ["Cenarion Circle"]="usp",
        ["Feathermoon"]="usp", ["Sentinels"]="usp", ["Silver Hand"]="usp", ["The Scryers"]="usp",
        ["Wyrmrest Accord"]="usp", ["The Venture Co"]="usp",

        ["Azjol-Nerub"]="usm", ["AzjolNerub"]="usm", ["Doomhammer"]="usm", ["Icecrown"]="usm", ["Perenolde"]="usm",
        ["Terenas"]="usm", ["Zangarmarsh"]="usm", ["Kel'Thuzad"]="usm", ["Darkspear"]="usm", ["Deathwing"]="usm",
        ["Bloodscalp"]="usm", ["Nathrezim"]="usm", ["Shadow Council"]="usm",

        ["Aegwynn"]="usc", ["Agamaggan"]="usc", ["Aggramar"]="usc", ["Akama"]="usc", ["Alexstrasza"]="usc", ["Alleria"]="usc",
        ["Archimonde"]="usc", ["Azgalor"]="usc", ["Azshara"]="usc", ["Balnazzar"]="usc", ["Blackhand"]="usc",
        ["Blood Furnace"]="usc", ["Borean Tundra"]="usc", ["Burning Legion"]="usc", ["Cairne"]="usc",
        ["Cho'gall"]="usc", ["Chromaggus"]="usc", ["Dawnbringer"]="usc", ["Dentarg"]="usc", ["Detheroc"]="usc",
        ["Drak'tharon"]="usc", ["Drak'thul"]="usc", ["Draka"]="usc", ["Eitrigg"]="usc", ["Emerald Dream"]="usc",
        ["Farstriders"]="usc", ["Fizzcrank"]="usc", ["Frostmane"]="usc", ["Garithos"]="usc", ["Garona"]="usc",
        ["Ghostlands"]="usc", ["Greymane"]="usc", ["Gul'dan"]="usc", ["Hakkar"]="usc",
        ["Hellscream"]="usc", ["Hydraxis"]="usc", ["Illidan"]="usc", ["Kael'thas"]="usc", ["Khaz Modan"]="usc",
        ["Kirin Tor"]="usc", ["Korgath"]="usc", ["Kul Tiras"]="usc", ["Laughing Skull"]="usc", ["Lightninghoof"]="usc",
        ["Madoran"]="usc", ["Maelstrom"]="usc", ["Mal'Ganis"]="usc", ["Malfurion"]="usc", ["Malorne"]="usc", ["Malygos"]="usc",
        ["Mok'Nathal"]="usc", ["Moon Guard"]="usc", ["Mug'thol"]="usc", ["Muradin"]="usc", ["Nesingwary"]="usc",
        ["Quel'Dorei"]="usc", ["Ravencrest"]="usc", ["Rexxar"]="usc", ["Runetotem"]="usc", ["Sargeras"]="usc",
        ["Scarlet Crusade"]="usc", ["Sen'Jin"]="usc", ["Sisters of Elune"]="usc", ["Staghelm"]="usc",
        ["Stormreaver"]="usc", ["Terokkar"]="usc", ["The Underbog"]="usc", ["Thorium Brotherhood"]="usc",
        ["Thunderhorn"]="usc", ["Thunderlord"]="usc", ["Twisting Nether"]="usc", ["Vek'nilash"]="usc",
        ["Whisperwind"]="usc", ["Wildhammer"]="usc", ["Winterhoof"]="usc",

        ["Altar of Storms"]="use", ["Alterac Mountains"]="use", ["Andorhal"]="use", ["Anetheron"]="use",
        ["Anub'arak"]="use", ["Area 52"]="use", ["Argent Dawn"]="use", ["Arthas"]="use", ["Arygos"]="use", ["Auchindoun"]="use",
        ["Black Dragonflight"]="use", ["Bleeding Hollow"]="use", ["Bloodhoof"]="use", ["Burning Blade"]="use",
        ["Dalaran"]="use", ["Dalvengyr"]="use", ["Demon Soul"]="use", ["Drenden"]="use", ["Durotan"]="use", ["Duskwood"]="use",
        ["Earthen Ring"]="use", ["Eldre'Thalas"]="use", ["Elune"]="use", ["Eonar"]="use", ["Eredar"]="use", ["Executus"]="use",
        ["Exodar"]="use", ["Fenris"]="use", ["Firetree"]="use", ["Garrosh"]="use", ["Gilneas"]="use", ["Gorefiend"]="use",
        ["Grizzly Hills"]="use", ["Haomarush"]="use", ["Jaedenar"]="use", ["Kargath"]="use", ["Khadgar"]="use",
        ["Lightning's Blade"]="use", ["Llane"]="use", ["Lothar"]="use", ["Magtheridon"]="use", ["Mannoroth"]="use",
        ["Medivh"]="use", ["Nazgrel"]="use", ["Norgannon"]="use", ["Ravenholdt"]="use", ["Scilla"]="use", ["Shadowmoon"]="use",
        ["Shandris"]="use", ["Shattered Hand"]="use", ["Skullcrusher"]="use", ["Smolderthorn"]="use",
        ["Steamwheedle Cartel"]="use", ["Stormrage"]="use", ["Tanaris"]="use", ["The Forgotten Coast"]="use",
        ["Thrall"]="use", ["Tortheldrin"]="use", ["Trollbane"]="use", ["Turalyon"]="use", ["Uldaman"]="use",
        ["Undermine"]="use", ["Warsong"]="use", ["Ysera"]="use", ["Ysondre"]="use", ["Zul'jin"]="use", ["Zuluhed"]="use",

        ["Drakkari"]="mex", ["Quel'Thalas"]="mex", ["Ragnaros"]="mex",

        ["Azralon"]="bzl", ["Gallywix"]="bzl", ["Goldrinn"]="bzl", ["Nemesis"]="bzl", ["Tol Barad"]="bzl",
    }
end
local regionColor = {--https://wago.io/6-GG3RMcC
    ["deDE"] = {col="|cFF00FF00DE|r", text='DE', realm="Germany"},
    ["frFR"] = {col="|cFF00FFFFFR|r", text='FR', realm="France"},
    ["enGB"] = {col="|cFFFF00FFGB|r", text='GB', realm="Great Britain"},
    ["itIT"] = {col="|cFFFFFF00IT|r", text='IT', realm="Italy"},
    ["esES"] = {col="|cFFFFBF00ES|r", text='ES', realm="Spain"},
    ["ruRU"] = {col="|cFFCCCCFFRU|r" ,text='RU', realm="Russia"},
    ["ptBR"] = {col="|cFF8fce00PT|r", text='PT', realm="Portuguese"},
    ["oce"] = {col="|cFF00FF00OCE|r", text='CE', realm="Oceanic"},
    ["usp"] = {col="|cFF00FFFFUSP|r", text='USP', realm="US Pacific"},
    ["usm"] = {col="|cFFFF00FFUSM|r", text='USM', realm="US Mountain"},
    ["usc"] = {col="|cFFFFFF00USC|r", text='USC', realm="US Central"},
    ["use"] = {col="|cFFFFBF00USE|r", text='USE', realm="US East"},
    ["mex"] = {col="|cFFCCCCFFMEX|r", text='MEX', realm="Mexico"},
    ["bzl"] = {col="|cFF8fce00BZL|r", text='BZL', realm="Brazil"},
}
e.Get_Region= function(server, guid, unit)--e.Get_Region(server, guid, unit)--服务器，EU， US {col=, text=, realm=}
    server= server
            or unit and ((select(2, UnitName(unit)) or e.Player.server))
            or guid and select(7, GetPlayerInfoByGUID(guid))
    return server and Realms[server] and regionColor[Realms[server]]
end