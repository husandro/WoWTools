---@diagnostic disable: duplicate-set-field

WoWTools_RealmMixin={}


if WoWTools_DataMixin.Player.Region~=1 and WoWTools_DataMixin.Player.Region~=3 then
    WoWTools_RealmMixin.Get_Region=function()end
    return
end
--[[
WoWTools_RealmMixin:Get_Region(realm, guid, unit, disabled)
WoWTools_DataMixin.Player.Language={layer=, size=, key=}
]]




local Realms={}
if WoWTools_DataMixin.Player.Region==3 then--EU 
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

elseif WoWTools_DataMixin.Player.Region==1 then
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
    ["deDE"]= {col="|cFF00FF00DE|r", text='DE', realm="Germany"},
    ["frFR"]= {col="|cFF00FFFFFR|r", text='FR', realm="France"},
    ["enGB"]= {col="|cFFFF00FFGB|r", text='GB', realm="Great Britain"},
    ["itIT"]= {col="|cFFFFFF00IT|r", text='IT', realm="Italy"},
    ["esES"]= {col="|cFFFFBF00ES|r", text='ES', realm="Spain"},
    ["ruRU"]= {col="|cFFCCCCFFRU|r" ,text='RU', realm="Russia"},
    ["ptBR"]= {col="|cFF8fce00PT|r", text='PT', realm="Portuguese"},

    ["oce"]= {col="|cFF00FF00OCE|r", text='CE', realm="Oceanic"},
    ["usp"]= {col="|cFF00FFFFUSP|r", text='USP', realm="US Pacific"},
    ["usm"]= {col="|cFFFF00FFUSM|r", text='USM', realm="US Mountain"},
    ["usc"]= {col="|cFFFFFF00USC|r", text='USC', realm="US Central"},
    ["use"]= {col="|cFFFFBF00USE|r", text='USE', realm="US East"},
    ["mex"]= {col="|cFFCCCCFFMEX|r", text='MEX', realm="Mexico"},
    ["bzl"]= {col="|cFF8fce00BZL|r", text='BZL', realm="Brazil"},
}

function WoWTools_RealmMixin:Get_Region(realm, guid, unit, disabled)--WoWTools_RealmMixin:Get_Region(server, guid, unit)--服务器，EU， US {col=, text=, realm=}
    if disabled then
        regionColor={}
        Realms={}
    else
        realm= realm=='' and WoWTools_DataMixin.Player.realm
                or realm
                or unit and ((select(2, UnitName(unit)) or WoWTools_DataMixin.Player.realm))
                or guid and select(7, GetPlayerInfoByGUID(guid))
        return realm and Realms[realm] and regionColor[Realms[realm]]
    end
end
