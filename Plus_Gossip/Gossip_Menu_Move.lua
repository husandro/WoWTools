--https://wago.tools/db2/Movie

local list={
1035,
1030,
1029,
1028,
1025,
1024,
1023,
1021,
1020,
1019,
1014,
1013,
1012,
1010,
1009,
1004,
1003,
1002,
1001,
998,
997,
996,
995,
993,
992,
991,
981,
980,
979,
974,
973,
972,
971,
970,
969,
968,
967,
966,
965,
964,
963,
962,
961,
960,
958,
957,
956,
955,
954,
953,
952,
951,
950,
949,
948,
947,
946,
945,
944,
943,
942,
941,
938,
937,
936,
935,
934,
933,
932,
931,
930,
928,
927,
926,
925,
924,
923,
922,
921,
920,
919,
918,
917,
916,
915,
914,
913,
912,
911,
910,
909,
908,
907,
905,
904,
903,
901,
900,
899,
898,
897,
896,
895,
894,
889,
888,
886,
885,
884,
883,
882,
879,
876,
875,
874,
873,
871,
866,
865,
864,
863,
862,
861,
860,
859,
858,
857,
856,
855,
854,
853,
852,
721,
720,
718,
717,
716,
708,
689,
688,
687,
686,
682,
681,
680,
679,
678,
677,
667,
663,
662,
661,
656,
641,
637,
636,
635,
625,
549,
542,
535,
534,
533,
532,
531,
497,
496,
495,
494,
490,
489,
488,
487,
486,
485,
484,
483,
478,
477,
476,
475,
474,
473,
472,
471,
470,
469,
315,
308,
304,
295,
294,
293,
292,
270,
269,
199,
198,
195,
194,
193,
192,
191,
190,
189,
188,
187,
185,
178,
177,
168,
167,
152,
151,
128,
127,
123,
121,
120,
119,
118,
117,
116,
115,
76,
75,
74,
73,
33,
32,
27,
23,
22,
21,
18,
16,
14,
2,
1,
}

--[[
BlizzardInterfaceCode/Interface/AddOns/Blizzard_GlueXMLBase/Mists/Constants.lua
CinematicsMenu.lua
Constants.lua
]]
local MovieList= {
    { expansion=LE_EXPANSION_CLASSIC,
        movieIDs = { 1, 2 },
        upAtlas="StreamCinematic-Classic-Up",
        text= WoWTools_DataMixin.onlyChinese and '经典旧世' or nil,
    },
    { expansion=LE_EXPANSION_BURNING_CRUSADE,
        movieIDs = { 27 },
        upAtlas="StreamCinematic-BC-Up",
        text= WoWTools_DataMixin.onlyChinese and '燃烧的远征' or nil,
    },
    { expansion=LE_EXPANSION_WRATH_OF_THE_LICH_KING,
        movieIDs = { 18 },
        upAtlas="StreamCinematic-LK-Up",
        text= WoWTools_DataMixin.onlyChinese and '巫妖王之怒' or nil,
    },
    { expansion=LE_EXPANSION_CATACLYSM,
        movieIDs = { 23 },
        upAtlas="StreamCinematic-CC-Up",
        text= WoWTools_DataMixin.onlyChinese and '大地的裂变' or nil,
    },
    { expansion=LE_EXPANSION_MISTS_OF_PANDARIA,
        movieIDs = { 115 },
        upAtlas="StreamCinematic-MOP-Up",
        text= WoWTools_DataMixin.onlyChinese and '熊猫人之谜' or nil,
    },
    { expansion=LE_EXPANSION_WARLORDS_OF_DRAENOR,
        movieIDs = { 195 },
        upAtlas="StreamCinematic-WOD-Up",
        text= WoWTools_DataMixin.onlyChinese and '德拉诺之王' or nil,
    },
    { expansion=LE_EXPANSION_LEGION,
        movieIDs = { 470 },
        upAtlas="StreamCinematic-Legion-Up",
        text= WoWTools_DataMixin.onlyChinese and '军团再临' or nil,
    },
    { expansion=LE_EXPANSION_BATTLE_FOR_AZEROTH,
        movieIDs = { 852 },
        upAtlas="StreamCinematic-BFA-Up",
        text= WoWTools_DataMixin.onlyChinese and '争霸艾泽拉斯' or nil,
    },
    { expansion=LE_EXPANSION_SHADOWLANDS,
        movieIDs = { 936 },
        upAtlas="StreamCinematic-Shadowlands-Up",
        text= WoWTools_DataMixin.onlyChinese and '暗影国度' or nil,
    },
    { expansion=LE_EXPANSION_DRAGONFLIGHT,
        movieIDs = { 960 },
        upAtlas="StreamCinematic-Dragonflight-Up",
        text= WoWTools_DataMixin.onlyChinese and '巨龙时代' or nil,
    },
    { expansion=LE_EXPANSION_DRAGONFLIGHT,
        movieIDs = { 973 },
        upAtlas="StreamCinematic-Dragonflight2-Up",
        title=_G['DRAGONFLIGHT_TOTHESKIES'],
        disableAutoPlay=true,
        text= WoWTools_DataMixin.onlyChinese and '巨龙时代' or nil,
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









--下载
local function Movie_SubMenu(root, movieID)
    if IsMovieLocal(movieID) then
        return
    end

    local sub=root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '下载' or 'Download',
    function(data)
        PreloadMovie(data.movieID)
    end, {movieID=movieID})

--进度        
    sub:SetTooltip(function(tooltip, description)
        local inProgress, downloaded, total = GetMovieDownloadProgress(description.data.movieID)
        if inProgress and downloaded and total and total>0 then
            tooltip:AddDoubleLine(
                WoWTools_DataMixin.onlyChinese and '进度' or PVP_PROGRESS_REWARDS_HEADER,
                format('|n%i%%', downloaded/total*100)
            )
        end
    end)
end






local function Init_Menu(_, root)
    local sub, sub2
--WoW
    sub=root:CreateButton('WoW', function()
        return MenuResponse.Open
    end)

    for _, movieEntry in pairs(MovieList) do--MOVIE_LIST or 
        for _, movieID in pairs(movieEntry.movieIDs) do
            sub2=sub:CreateButton(
                movieID
                ..('|A:'..(movieEntry.upAtlas or '')..':0:0|a')
                ..WoWTools_TextMixin:CN(movieEntry.title or movieEntry.text or _G["EXPANSION_NAME"..movieEntry.expansion]) or movieID,
            function(data)
                MovieFrame_PlayMovie(MovieFrame, data.movieID)
            end, {movieID=movieID, atlas=movieEntry.upAtlas})

            sub2:SetTooltip(function(tooltip, desc)
                if desc.data.atlas then
                    tooltip:AddLine('|A:'..(desc.data.atlas or '')..':134:246|a')
                end
            end)
--下载
            Movie_SubMenu(sub2, movieID)
        end
    end

    WoWTools_MenuMixin:SetScrollMode(sub)

--WoW2
    sub=root:CreateButton('WoW2', function()
        return MenuResponse.Open
    end)
    
    table.sort(list, function(a,b) return a>b end)

    for _, movieID in pairs(list) do
        sub2=sub:CreateButton(
            movieID,
        function(data)
            MovieFrame_PlayMovie(MovieFrame, data.movieID)
        end, {movieID=movieID})
--下载
        Movie_SubMenu(sub2, movieID)
    end
    WoWTools_MenuMixin:SetScrollMode(sub)
end



function WoWTools_GossipMixin:Init_WoW_MoveList(...)
    Init_Menu(...)
end