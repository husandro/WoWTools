WoWTools_DataMixin= {
    isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE,
    --isEra = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC,
    --isCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC,

    LeftButtonDown = C_CVar.GetCVarBool("ActionButtonUseKeyDown") and 'LeftButtonDown' or 'LeftButtonUp',
    RightButtonDown= C_CVar.GetCVarBool("ActionButtonUseKeyDown") and 'RightButtonDown' or 'RightButtonUp',
    ExpansionLevel= GetExpansionLevel(),--版本数据
    Is_Timerunning= PlayerGetTimerunningSeasonID(),--1=幻境新生：潘达利亚
    StausText={},--属性，截取表 API_Panel.lua
}



--WoWTools_DataMixin.IsSetPlayerSound= enabled--播放, 事件声音
--WoWTools_DataMixin.ClearAllSave= true 全部重置，插件设置

local battleTag= select(2, BNGetInfo())
local baseClass= UnitClassBase('player')
local playerRealm= GetRealmName():gsub(' ', '')
local currentRegion= GetCurrentRegion()
local r, g, b, hex= GetClassColor(baseClass)
hex= '|c'..hex

local function GetWeek()--周数
    local region= currentRegion
    local d = date("*t")
    local cd= region==1 and 2 or (region==3 and 3) or 4--1US(includes Brazil and Oceania) 2Korea 3Europe (includes Russia) 4Taiwan 5China
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


WoWTools_DataMixin.Player={
    realm= playerRealm,
    Realms= {},--多服务器

    name_realm= UnitName('player')..'-'..playerRealm,
    Name= UnitName('player'),
    Sex= UnitSex("player"),--1	Neutrum / Unknown 2	Male 3	Female
    Class= baseClass,

    Region= currentRegion,--1US (includes Brazil and Oceania) 2Korea 3Europe (includes Russia) 4Taiwan 5China
    cn= currentRegion==5 or currentRegion==4,

    r= r,
    g= g,
    b= b,
    col= hex,
    useColor= {r=r, g=g, b=b, a=1, hex= hex},--使用颜色

    --Lo= GetLocale(),
    Week= GetWeek(),--周数 date('%W')
    GUID= UnitGUID('player'),
    IsMaxLevel= UnitLevel('player')==GetMaxLevelForLatestExpansion(), --GetMaxLevelForPlayerExpansion(),--玩家是否最高等级 MAX_PLAYER_LEVEL
    Level= UnitLevel('player') or 1,--UnitEffectiveLevel('player')
    husandro= battleTag== '古月剑龙#5972' or battleTag=='SandroChina#2690' or battleTag=='Sandro126#2297' or battleTag=='Sandro163EU#2603',
    BattleTag= battleTag,
    Faction= UnitFactionGroup('player'),--玩家, 派系  "Alliance", "Horde", "Neutral"
    Layer= nil, --位面数字
    Language={},--多语言，文本
}
for k, v in pairs(GetAutoCompleteRealms()) do
    WoWTools_DataMixin.Player.Realms[v]=k
end

--zh= LOCALE_zhCN or LOCALE_zhTW,--GetLocale()== ("zhCN" or 'zhTW'),
--ver= select(4,GetBuildInfo())>=100100,--版本 100100
--disabledLUA={},--禁用插件 {save='', text} e.DisabledLua=true



WoWTools_DataMixin.Icon={
    --player= WoWTools_UnitMixin:GetRaceIcon({unit='player', guid=WoWTools_DataMixin.Player.GUID , race=nil , sex=WoWTools_DataMixin.Player.Sex , reAtlas=false}),
    icon= 'orderhalltalents-done-glow',
    icon2='|TInterface\\AddOns\\WoWTools\\Sesource\\Texture\\WoWtools:0|t',
    
    
    right='|A:NPE_RightClick:0:0|a',
    left='|A:NPE_LeftClick:0:0|a',
    mid='|A:newplayertutorial-icon-mouse-middlebutton:0:0|a',
    wow2='|A:glues-characterSelect-iconShop-hover:0:0|a',--'|A:tokens-WoW-generic-regular:0:0|a',
    net2= '|A:gmchat-icon-blizz:0:0|a',--'|A:Battlenet-ClientIcon-App:0:0|a',--'|A:questlog-questtypeicon-account:0:0|a',-- '|A:gmchat-icon-blizz:0:0|a',-- BNet_GetClientEmbeddedTexture(-2, 32, 32)
    toLeft='common-icon-rotateleft',--向左
    toRight='common-icon-rotateright',--向右

    TANK='|A:UI-LFG-RoleIcon-Tank:0:0|a',--INLINE_TANK_ICON
    HEALER='|A:UI-LFG-RoleIcon-Healer:0:0|a',--INLINE_HEALER_ICON
    DAMAGER='|A:UI-LFG-RoleIcon-DPS:0:0|a',--INLINE_DAMAGER_ICON
    NONE='|A:UI-LFG-RoleIcon-Pending:0:0|a',

    Alliance='charcreatetest-logo-alliance',
    Horde='charcreatetest-logo-horde',
    Neutral='nameplates-icon-flag-neutral',
    
--ColorConstants.lua
    [Enum.ItemQuality.Poor] = "dressingroom-itemborder-gray",--0  C_Item.GetItemQualityByID(ID) 方块
	[Enum.ItemQuality.Common] = "dressingroom-itemborder-white",
	[Enum.ItemQuality.Uncommon] = "dressingroom-itemborder-green",
	[Enum.ItemQuality.Rare] = "dressingroom-itemborder-blue",
	[Enum.ItemQuality.Epic] = "dressingroom-itemborder-purple",
	[Enum.ItemQuality.Legendary] = "dressingroom-itemborder-orange",
	[Enum.ItemQuality.Artifact] = "dressingroom-itemborder-artifact",
	[Enum.ItemQuality.Heirloom] = "dressingroom-itemborder-account",
	[Enum.ItemQuality.WoWToken] = "dressingroom-itemborder-account",--8

    [STABLE_PET_SPEC_CUNNING] = "cunning-icon-small",
    [STABLE_PET_SPEC_FEROCITY] = "ferocity-icon-small",
    [STABLE_PET_SPEC_TENACITY] = "tenacity-icon-small",
}

--disabled='talents-button-reset',
--select='common-icon-checkmark',--'GarrMission_EncounterBar-CheckMark',--绿色√   
--common-dropdown-icon-checkmark-yellow 黄色










if LOCALE_zhCN then
    WoWTools_DataMixin.Player.Language= {
        layer='位面',
        key='关键词',
    }
elseif LOCALE_zhTW then
    WoWTools_DataMixin.Player.Language={
        layer='位面',
        key='關鍵詞',
    }
elseif LOCALE_koKR then
    WoWTools_DataMixin.Player.Language={
        layer='층',
        key='키워드',
    }
elseif LOCALE_frFR then
    WoWTools_DataMixin.Player.Language={
        layer='Couche',
        key='Mots clés',
    }
elseif LOCALE_deDE then
    WoWTools_DataMixin.Player.Language={
        layer='Schicht',
        key='Schlüsselwörter',
    }
elseif LOCALE_esES or LOCALE_esMX then--西班牙语
    WoWTools_DataMixin.Player.Language={
        layer='Capa',
        key='Palabras clave',
    }
elseif LOCALE_ruRU then
    WoWTools_DataMixin.Player.Language={
        layer='слой',
        key='Ключевые слова',
    }
elseif LOCALE_ptBR then--葡萄牙语
    WoWTools_DataMixin.Player.Language={
        layer='Camada',
        key='Palavras-chave',
    }
elseif LOCALE_itIT then
    WoWTools_DataMixin.Player.Language={
        layer='Strato',
        key='Parole chiave',
    }
else
    WoWTools_DataMixin.Player.Language={
        layer= 'Layer',
        key='Key words',
    }
end