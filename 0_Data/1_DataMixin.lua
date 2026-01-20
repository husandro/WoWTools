--EventRegistry:TriggerEvent("PerksProgram.UpdateCartShown", showCart)
--EventRegistry:RegisterCallback("PerksProgram.UpdateCartShown", self.OnShoppingCartVisibilityUpdated, self);
--TimerunningUtil.TimerunningEnabledForPlayer() PlayerIsTimerunning(),--1=幻境新生：潘达利亚 
--CombatLogGetCurrentEventInfo
if not canaccessvalue then--12.0才有 SecureTypes.lua 
    canaccessvalue= function() return true end
    canaccesstable= function() return true end
    issecretvalue= function() return true end
    issecrettable= function() return true end
    canaccesssecrets= function() return true end
    C_Reputation.IsFactionParagonForCurrentPlayer= function(factionID)
        return C_Reputation.IsFactionParagon(factionID)
    end
end


WoWTools_DataMixin= {
    addName= '|TInterface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools.tga:0|t|cffff00ffWoW|r|cff00ff00Tools|r',
    onlyChinese= LOCALE_zhCN and true or false,

    --isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and not C_AddOns.IsAddOnLoaded('Blizzard_PTRFeedback'),--Blizzard_PTRFeedback

    --isEra = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC,
    --isCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC,
    --IsPublicBuild()

    LeftButtonDown= C_CVar.GetCVarBool("ActionButtonUseKeyDown") and 'LeftButtonDown' or 'LeftButtonUp',
    RightButtonDown= C_CVar.GetCVarBool("ActionButtonUseKeyDown") and 'RightButtonDown' or 'RightButtonUp',
    ExpansionLevel=  math.max(GetAccountExpansionLevel(), GetExpansionLevel()),-- GetClampedCurrentExpansionLevel() math.max(GetAccountExpansionLevel(), GetExpansionLevel()),-- GetExpansionLevel() or 1,--版本数据

    StausText={},--属性，截取表 API_Panel.lua
    UnitItemLevel={},
    Language={}
}


--[[
UnitItemLevel[guid]={--玩家装等
    itemLevel= itemLevel,
    specID=specID,
    faction= UnitFactionGroup(unit),
    col= hex,
    r=r,
    g=g,
    b=b,
    level=UnitLevel(unit),
}
]]

--WoWTools_DataMixin.IsSetPlayerSound= enabled--播放, 事件声音
--WoWTools_DataMixin.ClearAllSave= true 全部重置，插件设置

local battleTag= select(2, BNGetInfo())
local baseClass= UnitClassBase('player')
local playerRealm= GetRealmName():gsub(' ', '')
local currentRegion= GetCurrentRegion()
--local r, g, b, hex= GetClassColor(baseClass)


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

--PlayerUtil.GetClassColor():WrapTextInColorCode(linkText)
WoWTools_DataMixin.Player={
    Realm= playerRealm,
    Realms= {},--多服务器

    Name_Realm= UnitName('player')..'-'..playerRealm,
    --Name= UnitName('player'),
    --Sex= UnitSex("player"),--1	Neutrum / Unknown 2	Male 3	Female
    Class= baseClass,--1WARRIOR 2PALADIN 3HUNTER 4ROGUE 5PRIEST 6DEATHKNIGHT 7SHAMAN 8MAGE 9WARLOCK 10MONK 11DRUID 12DEMONHUNTER 13EVOKER

    Region= currentRegion,--1US (includes Brazil and Oceania) 2Korea 3Europe (includes Russia) 4Taiwan 5China
    IsCN= currentRegion==5 or currentRegion==4,

    --col= '|c'..hex,
    --UseColor= {r=r, g=g, b=b, a=1, hex='|c'..hex},--使用颜色
    --Color= PlayerUtil.GetClassColor(),

    --Lo= GetLocale(),
    Week= GetWeek(),--周数 date('%W')
    GUID= UnitGUID('player'),
    IsMaxLevel= UnitLevel('player')==GetMaxLevelForLatestExpansion(), --GetMaxLevelForPlayerExpansion(),--玩家是否最高等级 MAX_PLAYER_LEVEL
    Level= UnitLevel('player') or 1,--UnitEffectiveLevel('player')
    husandro= battleTag== '古月剑龙#5972' or battleTag=='SandroChina#2690' or battleTag=='Sandro126#2297' or battleTag=='Sandro163EU#2603',
    BattleTag= battleTag,
    Faction= UnitFactionGroup('player'),--玩家, 派系  "Alliance", "Horde", "Neutral"
    Layer= nil, --位面数字
    --Language={},--多语言，文本
}
for realmIndex, realmName in pairs(GetAutoCompleteRealms() or {}) do
    WoWTools_DataMixin.Player.Realms[realmName]=realmIndex
end

--zh= LOCALE_zhCN or LOCALE_zhTW,--GetLocale()== ("zhCN" or 'zhTW'),
--ver= select(4,GetBuildInfo())>=100100,--版本 100100
--disabledLUA={},--禁用插件 {save='', text} e.DisabledLua=true


WoWTools_DataMixin.Icon={
    Player= '',-- WoWTools_UnitMixin:GetRaceIcon('player') 玩家图标icon
    icon= 'Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools',
    icon2='|TInterface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools:0|t',

    right='|A:NPE_RightClick:0:0|a',
    left='|A:NPE_LeftClick:0:0|a',
    mid='|A:newplayertutorial-icon-mouse-middlebutton:0:0|a',
    wow2='|A:glues-characterSelect-iconShop-hover:0:0|a',--'|A:questlog-questtypeicon-account:0:0|a',--,--'|A:tokens-WoW-generic-regular:0:0|a',
    net2= '|A:gmchat-icon-blizz:0:0|a',--'|A:Battlenet-ClientIcon-App:0:0|a',--'|A:questlog-questtypeicon-account:0:0|a',-- '|A:gmchat-icon-blizz:0:0|a',-- BNet_GetClientEmbeddedTexture(-2, 32, 32)
    --toLeft='common-icon-rotateleft',--向左
    --toRight='common-icon-rotateright',--向右

--Blizzard_FrameXMLBase/Constants.lua
    TANK='|A:UI-LFG-RoleIcon-Tank:0:0|a',--INLINE_TANK_ICON CreateAtlasMarkup(GetMicroIconForRole("TANK"), 16, 16) 
    HEALER='|A:UI-LFG-RoleIcon-Healer:0:0|a',--INLINE_HEALER_ICON CreateAtlasMarkup(GetMicroIconForRole("HEALER"), 16, 16)
    DAMAGER='|A:UI-LFG-RoleIcon-DPS:0:0|a',--INLINE_DAMAGER_ICON CreateAtlasMarkup(GetMicroIconForRole("DAMAGER"), 16, 16)
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


--[[
questlog-questtypeicon-account
disabled='talents-button-reset', ChallengeMode-icon-redline
select='common-icon-checkmark',--'GarrMission_EncounterBar-CheckMark',--绿色√   
common-dropdown-icon-checkmark-yellow 黄色
ChallengeMode-RankLineDivider
]]









if LOCALE_zhCN then
    WoWTools_DataMixin.Language= {
        layer='位面',
        key='关键词',
    }
elseif LOCALE_zhTW then
    WoWTools_DataMixin.Language={
        layer='位面',
        key='關鍵詞',
    }
elseif LOCALE_koKR then
    WoWTools_DataMixin.Language={
        layer='층',
        key='키워드',
    }
elseif LOCALE_frFR then
    WoWTools_DataMixin.Language={
        layer='Couche',
        key='Mots clés',
    }
elseif LOCALE_deDE then
    WoWTools_DataMixin.Language={
        layer='Schicht',
        key='Schlüsselwörter',
    }
elseif LOCALE_esES or LOCALE_esMX then--西班牙语
    WoWTools_DataMixin.Language={
        layer='Capa',
        key='Palabras clave',
    }
elseif LOCALE_ruRU then
    WoWTools_DataMixin.Language={
        layer='слой',
        key='Ключевые слова',
    }
elseif LOCALE_ptBR then--葡萄牙语
    WoWTools_DataMixin.Language={
        layer='Camada',
        key='Palavras-chave',
    }
elseif LOCALE_itIT then
    WoWTools_DataMixin.Language={
        layer='Strato',
        key='Parole chiave',
    }
else
    WoWTools_DataMixin.Language={
        layer= 'Layer',
        key='Key words',
    }
end






function WoWTools_DataMixin:Info(data1)
    local data= _G[data1] or data1

    local secret= WoWTools_DataMixin.onlyChinese and '|cnEVENTTRACE_SECRET_COLOR:<机密>|r' or (EVENTTRACE_SECRET_FMT and format(EVENTTRACE_SECRET_FMT, '')) or '|cff88ff88<secret>|r'

    local typeData= type(data)
    
    if issecrettable(data) or (typeData=='table' and issecrettable(data))  then
        print(WoWTools_DataMixin.Icon.icon2, secret)
        return
    end
    local t=''
    if typeData=='table' then
        for k, v in pairs(data) do
            if v and type(v)=='table' then
                if issecrettable(v) then
                    t= t..' |n|cnWARNING_FONT_COLOR:---'..tostring(k)..'---|r'..secret
                else
                    t= t..' |n|cff00ff00---'..tostring(k)..'---STAR|r'

                    for k2, v2 in pairs(v) do
                        if type(v2)=='table' then
                            if issecrettable(v2) then
                                t= t..'|n|cnWARNING_FONT_COLOR:'..tostring(k2)..'---|r'..secret
                            else
                                t= t..'|n|cff00ffff---'..tostring(k2)..'---STAR|r'
                                for k3, v3 in pairs(v2) do
                                    t= t..'|n        '..(type(v3)=='function' and '|cff00ccff' or '|cffffff00')..tostring(k3)..' |r= '..tostring(v3)
                                end
                                t= t..'|n   |cffff5e00---'..tostring(k2)..'---END|r'
                            end
                        else
                            t= t..'|n    '..(type(v2)=='function' and '|cff00ccff' or '|cffffff00')..tostring(k2)..' |r= '..(issecrettable(v2) and secret or tostring(v2))
                        end
                    end
                    t= t..'  |n|cffff0000---'..tostring(k)..'---END|r'
                end
            else
                t= t..'|n'..(type(v)=='function' and '|cff00ccff' or '|cffff00ff')..tostring(k)..'|r = '..(issecretvalue(v) and secret or tostring(v))
            end
        end
        t=t..'|n|cffff00ff——————————|r'

    elseif typeData=='string' then
        t=data
    end
    
    WoWTools_TextMixin:ShowText(t, WoWTools_DataMixin.Icon.icon2..(type(data1)=='string' and data1 or tostring(data)))--, {notClear=true})
end

if not _G[SLASH_INFOSLASH1] then
    SLASH_INFOSLASH1 = "/info"
    SlashCmdList["INFOSLASH"] = function(msg)
	    WoWTools_DataMixin:Info(msg)
    end
end


