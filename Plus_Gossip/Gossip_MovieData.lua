


local MovieList= {--CinematicsMenu.lua
    { expansion=LE_EXPANSION_CLASSIC,
        movieIDs = { 1, 2 },
        upAtlas="StreamCinematic-Classic-Up",
        text= WoWTools_Mixin.onlyChinese and '经典旧世' or nil,
    },
    { expansion=LE_EXPANSION_BURNING_CRUSADE,
        movieIDs = { 27 },
        upAtlas="StreamCinematic-BC-Up",
        text= WoWTools_Mixin.onlyChinese and '燃烧的远征' or nil,
    },
    { expansion=LE_EXPANSION_WRATH_OF_THE_LICH_KING,
        movieIDs = { 18 },
        upAtlas="StreamCinematic-LK-Up",
        text= WoWTools_Mixin.onlyChinese and '巫妖王之怒' or nil,
    },
    { expansion=LE_EXPANSION_CATACLYSM,
        movieIDs = { 23 },
        upAtlas="StreamCinematic-CC-Up",
        text= WoWTools_Mixin.onlyChinese and '大地的裂变' or nil,
    },
    { expansion=LE_EXPANSION_MISTS_OF_PANDARIA,
        movieIDs = { 115 },
        upAtlas="StreamCinematic-MOP-Up",
        text= WoWTools_Mixin.onlyChinese and '熊猫人之谜' or nil,
    },
    { expansion=LE_EXPANSION_WARLORDS_OF_DRAENOR,
        movieIDs = { 195 },
        upAtlas="StreamCinematic-WOD-Up",
        text= WoWTools_Mixin.onlyChinese and '德拉诺之王' or nil,
    },
    { expansion=LE_EXPANSION_LEGION,
        movieIDs = { 470 },
        upAtlas="StreamCinematic-Legion-Up",
        text= WoWTools_Mixin.onlyChinese and '军团再临' or nil,
    },
    { expansion=LE_EXPANSION_BATTLE_FOR_AZEROTH,
        movieIDs = { 852 },
        upAtlas="StreamCinematic-BFA-Up",
        text= WoWTools_Mixin.onlyChinese and '争霸艾泽拉斯' or nil,
    },
    { expansion=LE_EXPANSION_SHADOWLANDS,
        movieIDs = { 936 },
        upAtlas="StreamCinematic-Shadowlands-Up",
        text= WoWTools_Mixin.onlyChinese and '暗影国度' or nil,
    },
    { expansion=LE_EXPANSION_DRAGONFLIGHT,
        movieIDs = { 960 },
        upAtlas="StreamCinematic-Dragonflight-Up",
        text= WoWTools_Mixin.onlyChinese and '巨龙时代' or nil,
    },
    { expansion=LE_EXPANSION_DRAGONFLIGHT,
        movieIDs = { 973 },
        upAtlas="StreamCinematic-Dragonflight2-Up",
        title=_G['DRAGONFLIGHT_TOTHESKIES'],
        disableAutoPlay=true,
        text= WoWTools_Mixin.onlyChinese and '巨龙时代' or nil,
    },
    {
		expansion = LE_EXPANSION_WAR_WITHIN,
		movieIDs = { 1014 },
		upAtlas = "StreamCinematic-WarWithin-Large-Up",
		downAtlas = "StreamCinematic-WarWithin-Large-Down",
	},
    {
		expansion = LE_EXPANSION_WAR_WITHIN,
		movieIDs = { 1023 },
		upAtlas = "StreamCinematic-WarWithin2-Large-Up",
		downAtlas = "StreamCinematic-WarWithin2-Large-Down",
		title = WARWITHIN_TITLE2,
		disableAutoPlay = true,
	},
	-- Movie sequence 12 = WarWithin

}


function WoWTools_GossipMixin:Get_MoveData()
    return MovieList
end