local e = select(2, ...)


--[[
e.Is_PTR= IsPublicBuild() or IsTestBuild()
local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local isEra = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local isCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
]]

e.WoWDate={}--战网，数据
e.StausText={}--属性，截取表 API_Panel.lua
e.ChallengesSpellTabs={}--Challenges.lua
e.tips=GameTooltip

--local securecallfunction= securecallfunction
function e.call(func, ...)
    if func then
        securecallfunction(func, ...)
    end
end



e.LeftButtonDown = C_CVar.GetCVarBool("ActionButtonUseKeyDown") and 'LeftButtonDown' or 'LeftButtonUp'
e.RightButtonDown= C_CVar.GetCVarBool("ActionButtonUseKeyDown") and 'RightButtonDown' or 'RightButtonUp'
e.onlyChinese= LOCALE_zhCN and true or false
e.ExpansionLevel= GetExpansionLevel()--版本数据
e.Is_Timerunning= PlayerGetTimerunningSeasonID()-- 1=幻境新生：潘达利亚




local battleTag= select(2, BNGetInfo())
local baseClass= UnitClassBase('player')
local playerRealm= GetRealmName():gsub(' ', '')
local currentRegion= GetCurrentRegion()

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




e.Player={
    realm= playerRealm,
    Realms= {},--多服务器
    name_realm= UnitName('player')..'-'..playerRealm,
    name= UnitName('player'),
    sex= UnitSex("player"),--1	Neutrum / Unknown 2	Male 3	Female
    class= baseClass,
    r= GetClassColor(baseClass),
    g= select(2,GetClassColor(baseClass)),
    b= select(3, GetClassColor(baseClass)),
    col= '|c'..select(4, GetClassColor(baseClass)),
    cn= currentRegion==5 or currentRegion==4,
    region= currentRegion,--1US (includes Brazil and Oceania) 2Korea 3Europe (includes Russia) 4Taiwan 5China
    --Lo= GetLocale(),
    week= GetWeek(),--周数
    guid= UnitGUID('player'),
    IsMaxLevel= UnitLevel('player')==GetMaxLevelForLatestExpansion(), --GetMaxLevelForPlayerExpansion(),--玩家是否最高等级 MAX_PLAYER_LEVEL
    level= UnitLevel('player') or 1,--UnitEffectiveLevel('player')
    husandro= battleTag== '古月剑龙#5972' or battleTag=='SandroChina#2690' or battleTag=='Sandro126#2297' or battleTag=='Sandro163EU#2603',
    battleTag= battleTag,
    faction= UnitFactionGroup('player'),--玩家, 派系  "Alliance", "Horde", "Neutral"
    Layer= nil, --位面数字
    --useColor= nil,--使用颜色
    L={},--多语言，文本
}
e.Player.useColor= {r=e.Player.r, g=e.Player.g, b=e.Player.b, a=1, hex= e.Player.col}--使用颜色

 --zh= LOCALE_zhCN or LOCALE_zhTW,--GetLocale()== ("zhCN" or 'zhTW'),
 --ver= select(4,GetBuildInfo())>=100100,--版本 100100
 --disabledLUA={},--禁用插件 {save='', text} e.DisabledLua=true
for k, v in pairs(GetAutoCompleteRealms()) do
    e.Player.Realms[v]=k
end



e.Icon={
    --player= WoWTools_UnitMixin:GetRaceIcon({unit='player', guid=e.Player.guid , race=nil , sex=e.Player.sex , reAtlas=false}),
    icon= 'orderhalltalents-done-glow',
    icon2='|TInterface\\AddOns\\WoWTools\\0_Sesource\\Texture\\WoWtools.tga:0|t',
    disabled='talents-button-reset',
    select='common-icon-checkmark',--'GarrMission_EncounterBar-CheckMark',--绿色√   
    right='|A:newplayertutorial-icon-mouse-rightbutton:0:0|a',
    left='|A:newplayertutorial-icon-mouse-leftbutton:0:0|a',
    mid='|A:newplayertutorial-icon-mouse-middlebutton:0:0|a',
    wow2='|A:glues-characterSelect-iconShop-hover:0:0|a',--'|A:tokens-WoW-generic-regular:0:0|a',
    net2= '|A:Battlenet-ClientIcon-App:0:0|a',--'|A:questlog-questtypeicon-account:0:0|a',-- '|A:gmchat-icon-blizz:0:0|a',-- BNet_GetClientEmbeddedTexture(-2, 32, 32), questlog-questtypeicon-account
    toLeft='common-icon-rotateleft',--向左
    toRight='common-icon-rotateright',--向右
    TANK='|A:UI-LFG-RoleIcon-Tank:0:0|a',--INLINE_TANK_ICON
    HEALER='|A:UI-LFG-RoleIcon-Healer:0:0|a',--INLINE_HEALER_ICON
    DAMAGER='|A:UI-LFG-RoleIcon-DPS:0:0|a',--INLINE_DAMAGER_ICON
    NONE='|A:UI-LFG-RoleIcon-Pending:0:0|a',
    Alliance='charcreatetest-logo-alliance',
    Horde='charcreatetest-logo-horde',
    Neutral='nameplates-icon-flag-neutral',
    [Enum.ItemQuality.Poor] = "dressingroom-itemborder-gray",--0  C_Item.GetItemQualityByID(ID)
	[Enum.ItemQuality.Common] = "dressingroom-itemborder-white",
	[Enum.ItemQuality.Uncommon] = "dressingroom-itemborder-green",
	[Enum.ItemQuality.Rare] = "dressingroom-itemborder-blue",
	[Enum.ItemQuality.Epic] = "dressingroom-itemborder-purple",
	[Enum.ItemQuality.Legendary] = "dressingroom-itemborder-orange",
	[Enum.ItemQuality.Artifact] = "dressingroom-itemborder-artifact",
	[Enum.ItemQuality.Heirloom] = "dressingroom-itemborder-account",
	[Enum.ItemQuality.WoWToken] = "dressingroom-itemborder-account",--8

}


--[[
C_Texture.GetTitleIconTexture(BNET_CLIENT_WOW, Enum.TitleIconVersion.Medium, function(success, texture)--FriendsFrame.lua BnetShared.lua    
    if success and texture then
        e.Icon.wow=texture
    end
end)
C_Texture.GetTitleIconTexture('BSAp', Enum.TitleIconVersion.Small, function(success, texture)
    if success and texture then
        e.Icon.net2= '|T'..texture..':0|t'
    end
end)]]




if LOCALE_zhCN then
    e.Player.L= {
        layer='位面',
        key='关键词',
    }
elseif LOCALE_zhTW then
    e.Player.L={
        layer='位面',
        key='關鍵詞',
    }
elseif LOCALE_koKR then
    e.Player.L={
        layer='층',
        key='키워드',
    }
elseif LOCALE_frFR then
    e.Player.L={
        layer='Couche',
        key='Mots clés',
    }
elseif LOCALE_deDE then
    e.Player.L={
        layer='Schicht',
        key='Schlüsselwörter',
    }
elseif LOCALE_esES or LOCALE_esMX then--西班牙语
    e.Player.L={
        layer='Capa',
        key='Palabras clave',
    }
elseif LOCALE_ruRU then
    e.Player.L={
        layer='слой',
        key='Ключевые слова',
    }
elseif LOCALE_ptBR then--葡萄牙语
    e.Player.L={
        layer='Camada',
        key='Palavras-chave',
    }
elseif LOCALE_itIT then
    e.Player.L={
        layer='Strato',
        key='Parole chiave',
    }
else
    e.Player.L={
        layer= 'Layer',
        key='Key words',
    }
end





