local e = select(2, ...)
--[[
e.WoWDate={}
e.strText={}
e.tips=GameTooltip
e.call=securecall
e.LeftButtonDown
e.RightButtonDown
e.onlyChinese
e.itemSlotTable
e.ExpansionLevel
e.Player={}
e.Icon={}
]]


--Blizzard_Deprecated/Deprecated_10_2_0.lua
e.WoWDate={}
e.strText={}
e.tips=GameTooltip
e.call=securecall
--securecallfunction
e.LeftButtonDown = C_CVar.GetCVarBool("ActionButtonUseKeyDown") and 'LeftButtonDown' or 'LeftButtonUp'
e.RightButtonDown= C_CVar.GetCVarBool("ActionButtonUseKeyDown") and 'RightButtonDown' or 'RightButtonUp'
e.onlyChinese= LOCALE_zhCN and true or false
e.ExpansionLevel= GetExpansionLevel()--版本数据
e.LibDD=LibStub:GetLibrary("LibUIDropDownMenu-4.0", true)--菜单

local function GetWeek()--周数
    local region= GetCurrentRegion()
    local d = date("*t")
    local cd= region==1 and 2 or region==3 and 3 or 4--1US(includes Brazil and Oceania) 2Korea 3Europe (includes Russia) 4Taiwan 5China
    for d3=1,15 do
        if date('*t', time({year=d.year, month=1, day=d3})).wday == cd then
            cd=d3
            break
        end
    end
    local week=ceil(floor((time() - time({year= d.year, month= 1, day= cd})) / (24*60*60)) /7)
    if week==0 then
        week=52
    end
    return week
end



local battleTag= select(2, BNGetInfo())
local baseClass= UnitClassBase('player')
e.Player={
    realm= GetRealmName(),
    Realms= {},--多服务器
    name_realm= UnitName('player')..'-'..GetRealmName(),
    name= UnitName('player'),
    sex= UnitSex("player"),
    class= UnitClassBase('player'),
    r= GetClassColor(baseClass),
    g= select(2,GetClassColor(baseClass)),
    b= select(3, GetClassColor(baseClass)),
    col= '|c'..select(4, GetClassColor(baseClass)),
    cn= GetCurrentRegion()==5,
    region= GetCurrentRegion(),--1US (includes Brazil and Oceania) 2Korea 3Europe (includes Russia) 4Taiwan 5China
    --Lo= GetLocale(),
    week= GetWeek(),--周数
    guid= UnitGUID('player'),
    levelMax= UnitLevel('player')==MAX_PLAYER_LEVEL,--玩家是否最高等级
    level= UnitLevel('player'),--UnitEffectiveLevel('player')
    husandro= battleTag== '古月剑龙#5972' or battleTag=='SandroChina#2690' or battleTag=='Sandro126#2297' or battleTag=='Sandro163EU#2603',
    faction= UnitFactionGroup('player'),--玩家, 派系  "Alliance", "Horde", "Neutral"
    Layer= nil, --位面数字
    --useColor= nil,--使用颜色
    L={},--多语言，文本
}
--e.Player.r, e.Player.g, e.Player.b, e.Player.col= e.GetUnitColor('player')--职业颜色
e.Player.useColor= {r=e.Player.r, g=e.Player.g, b=e.Player.b, a=1, hex= e.Player.col}--使用颜色

 --MAX_PLAYER_LEVEL = GetMaxLevelForPlayerExpansion()
 --zh= LOCALE_zhCN or LOCALE_zhTW,--GetLocale()== ("zhCN" or 'zhTW'),
 --ver= select(4,GetBuildInfo())>=100100,--版本 100100
 --disabledLUA={},--禁用插件 {save='', text} e.DisabledLua=true
for k, v in pairs(GetAutoCompleteRealms()) do
    e.Player.Realms[v]=k
end



e.Icon={
    icon= 'orderhalltalents-done-glow',
    disabled='talents-button-reset',
    select='common-icon-checkmark',--'GarrMission_EncounterBar-CheckMark',--绿色√
    select2='|A:common-icon-checkmark:0:0|a',--绿色√
    --selectYellow='common-icon-checkmark-yellow',--黄色√
    X2='|A:common-icon-redx:0:0|a',
    O2='|A:talents-button-reset:0:0|a',--￠
    right='|A:newplayertutorial-icon-mouse-rightbutton:0:0|a',
    left='|A:newplayertutorial-icon-mouse-leftbutton:0:0|a',
    mid='|A:newplayertutorial-icon-mouse-middlebutton:0:0|a',
    map='poi-islands-table',
    map2='|A:poi-islands-table:0:0|a',
    wow=136235,
    wow2= '|T136235:0|t',--'|A:Icon-WoW:0:0|a',--136235  BNet_GetClientEmbeddedTexture(-2, 32, 32)
    net2= '|A:questlog-questtypeicon-account:0:0|a',-- '|A:gmchat-icon-blizz:0:0|a',-- BNet_GetClientEmbeddedTexture(-2, 32, 32), questlog-questtypeicon-account
    horde= 'charcreatetest-logo-horde',
    alliance='charcreatetest-logo-alliance',
    horde2='|A:charcreatetest-logo-horde:0:0|a',
    alliance2='|A:charcreatetest-logo-alliance:0:0|a',

    number='services-number-',
    number2='|A:services-number-%d:0:0|a',
    clock='socialqueuing-icon-clock',
    clock2='|A:socialqueuing-icon-clock:0:0|a',

    --player= e.GetUnitRaceInfo({unit='player', guid=nil , race=nil , sex=nil , reAtlas=false}),

    bank2='|A:Banker:0:0|a',
    bag='bag-main',
    bag2='|A:bag-main:0:0|a',
    --bagEmpty='bag-reagent-border-empty',

    up2='|A:bags-greenarrow:0:0|a',--绿色向上, 红色向上 UI-HUD-Minimap-Arrow-Corpse， 金色 UI-HUD-Minimap-Arrow-Guard
    down2='|A:UI-HUD-MicroMenu-StreamDLRed-Up:0:0|a',--红色向下
    toLeft='common-icon-rotateleft',--向左
    toLeft2='|A:common-icon-rotateleft:0:0|a',
    toRight='common-icon-rotateright',--向右
    toRight2='|A:common-icon-rotateright:0:0|a',

    unlocked='tradeskills-icon-locked',--'Levelup-Icon-Lock',--没锁
    quest='AutoQuest-Badge-Campaign',--任务
    guild2='|A:UI-HUD-MicroMenu-GuildCommunities-Mouseover:0:0|a',--guild2='|A:communities-guildbanner-background:0:0|a',

    TANK='|A:UI-LFG-RoleIcon-Tank:0:0|a',--INLINE_TANK_ICON
    HEALER='|A:UI-LFG-RoleIcon-Healer:0:0|a',--INLINE_HEALER_ICON
    DAMAGER='|A:UI-LFG-RoleIcon-DPS:0:0|a',--INLINE_DAMAGER_ICON
    NONE='|A:UI-LFG-RoleIcon-Pending:0:0|a',
    leader='|A:UI-HUD-UnitFrame-Player-Group-GuideIcon:0:0|a',--队长

    info2='|A:questlegendary:0:0|a',--黄色!
    star2='|A:auctionhouse-icon-favorite:0:0|a',--星星
}


C_Texture.GetTitleIconTexture(BNET_CLIENT_WOW, Enum.TitleIconVersion.Medium, function(success, texture)--FriendsFrame.lua BnetShared.lua    
    if success and texture then
        e.Icon.wow=texture
        e.Icon.wow2= '|T'..texture..':0|t'
    end
end)
C_Texture.GetTitleIconTexture('BSAp', Enum.TitleIconVersion.Small, function(success, texture)
    if success and texture then
        e.Icon.net2= '|T'..texture..':0|t'
    end
end)




if LOCALE_zhCN then
    e.Player.L= {
        layer='位面',
        size='大小',
        key='关键词',
    }
elseif LOCALE_zhTW then
    e.Player.L={
        layer='位面',
        size='大小',
        key='關鍵詞',
    }
elseif LOCALE_koKR then
    e.Player.L={
        layer='층',
        size='크기',
        key='키워드',
    }
elseif LOCALE_frFR then
    e.Player.L={
        layer='Couche',
        size='Taille',
        key='Mots clés',
    }
elseif LOCALE_deDE then
    e.Player.L={
        layer='Schicht',
        size='Größe',
        key='Schlüsselwörter',
    }
elseif LOCALE_esES or LOCALE_esMX then--西班牙语
    e.Player.L={
        layer='Capa',
        size='Tamaño',
        key='Palabras clave',
    }
elseif LOCALE_ruRU then
    e.Player.L={
        layer='слой',
        size='Размер',
        key='Ключевые слова',
    }
elseif LOCALE_ptBR then--葡萄牙语
    e.Player.L={
        layer='Camada',
        size='Tamanho',
        key='Palavras-chave',
    }
elseif LOCALE_itIT then
    e.Player.L={
        layer='Strato',
        size='Misurare',
        key='Parole chiave',
    }
else
    e.Player.L={
        layer= 'Layer',
        size= 'Size',
        key='Key words',
    }
end
