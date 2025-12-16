--https://wago.tools/db2/Movie

--[[
BlizzardInterfaceCode/Interface/AddOns/Blizzard_GlueXMLBase/Mists/Constants.lua
CinematicsMenu.lua
Constants.lua
C_CinematicList.GetUICinematicList()
MOVIE_LIST
]]
local function Save()
    return WoWToolsSave['Plus_Gossip']
end
local List={}
local MovieList={}










local function Init()
List={
1061,
1057,
1052,
1051,
1050,
1049,
1048,
1047,
1045,
1043,
1041,
1040,
1038,
1035,
1034,
1033,
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

MovieList= {
{
    expansion = LE_EXPANSION_WAR_WITHIN,
    movieIDs = { 1023 },
    upAtlas = "StreamCinematic-WarWithin2-Large-Up",
    downAtlas = "StreamCinematic-WarWithin2-Large-Down",
    text= WoWTools_DataMixin.onlyChinese and '地心之战' or EXPANSION_NAME10,
    disableAutoPlay = true,
},
{
    expansion = LE_EXPANSION_WAR_WITHIN,
    movieIDs = { 1014 },
    upAtlas = "StreamCinematic-WarWithin-Large-Up",
    downAtlas = "StreamCinematic-WarWithin-Large-Down",
    text= WoWTools_DataMixin.onlyChinese and '地心之战' or EXPANSION_NAME10,
},
{ expansion=LE_EXPANSION_DRAGONFLIGHT,
    movieIDs = { 973 },
    upAtlas="StreamCinematic-Dragonflight2-Up",
    disableAutoPlay=true,
    text= WoWTools_DataMixin.onlyChinese and '巨龙时代' or EXPANSION_NAME9,
},
{ expansion=LE_EXPANSION_DRAGONFLIGHT,
    movieIDs = { 960 },
    upAtlas="StreamCinematic-Dragonflight-Up",
    text= WoWTools_DataMixin.onlyChinese and '巨龙时代' or EXPANSION_NAME9,
},
{ expansion=LE_EXPANSION_SHADOWLANDS,
    movieIDs = { 936 },
    upAtlas="StreamCinematic-Shadowlands-Up",
    text= WoWTools_DataMixin.onlyChinese and '暗影国度' or EXPANSION_NAME8,
},
{ expansion=LE_EXPANSION_BATTLE_FOR_AZEROTH,
    movieIDs = { 852 },
    upAtlas="StreamCinematic-BFA-Up",
    text= WoWTools_DataMixin.onlyChinese and '争霸艾泽拉斯' or EXPANSION_NAME7,
},
{ expansion=LE_EXPANSION_LEGION,
    movieIDs = { 470 },
    upAtlas="StreamCinematic-Legion-Up",
    text= WoWTools_DataMixin.onlyChinese and '军团再临' or EXPANSION_NAME6,
},

{ expansion=LE_EXPANSION_WARLORDS_OF_DRAENOR,
    movieIDs = { 195 },
    upAtlas="StreamCinematic-WOD-Up",
    text= WoWTools_DataMixin.onlyChinese and '德拉诺之王' or EXPANSION_NAME5,
},
{ expansion=LE_EXPANSION_MISTS_OF_PANDARIA,
    movieIDs = { 115 },
    upAtlas="StreamCinematic-MOP-Up",
    text= WoWTools_DataMixin.onlyChinese and '熊猫人之谜' or EXPANSION_NAME4,
},
{ expansion=LE_EXPANSION_CATACLYSM,
    movieIDs = { 23 },
    upAtlas="StreamCinematic-CC-Up",
    text= WoWTools_DataMixin.onlyChinese and '大地的裂变' or EXPANSION_NAME3,
},
{ expansion=LE_EXPANSION_WRATH_OF_THE_LICH_KING,
    movieIDs = { 18 },
    upAtlas="StreamCinematic-LK-Up",
    text= WoWTools_DataMixin.onlyChinese and '巫妖王之怒' or EXPANSION_NAME2,
},
{ expansion=LE_EXPANSION_BURNING_CRUSADE,
    movieIDs = { 27 },
    upAtlas="StreamCinematic-BC-Up",
    text= WoWTools_DataMixin.onlyChinese and '燃烧的远征' or EXPANSION_NAME1,
},
{ expansion=LE_EXPANSION_CLASSIC,
    movieIDs = { 1, 2 },
    upAtlas="StreamCinematic-Classic-Up",
    text= WoWTools_DataMixin.onlyChinese and '经典旧世' or EXPANSION_NAME0,
},
}

    Init= function()end
end









local Movie_ID
local Cinematics_ID
local function Set_StopMove()
    if Save().stopMovie then
        if not Movie_ID then
            Movie_ID= EventRegistry:RegisterFrameEventAndCallback("PLAY_MOVIE", function(_, movieID)
                if not movieID then
                    return
                end

                if Save().movie[movieID] then
                    MovieFrame:StopMovie()
                    print(
                        WoWTools_GossipMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_DataMixin.onlyChinese and '对话' or ENABLE_DIALOG,
                        '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '跳过' or RENOWN_LEVEL_UP_SKIP_BUTTON)..'|r',
                        'movieID|cnGREEN_FONT_COLOR:',
                        movieID
                    )
                else
                    Save().movie[movieID]= date("%d/%m/%y %H:%M:%S")
                    print(
                        WoWTools_GossipMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        '|cnGREEN_FONT_COLOR:movieID',
                        movieID
                    )
                end
            end)
        end

    elseif Movie_ID then
        EventRegistry:UnregisterCallback('PLAY_MOVIE', Movie_ID)
    end

    if Save().stopCinematics then
        if not Cinematics_ID then
            Cinematics_ID= EventRegistry:RegisterFrameEventAndCallback("CINEMATIC_START", function()--_, canBeCancelled, forcedAspectRatio) 
                if IsInInstance() and Save().stopCinematicsInInstance then
                    return
                end
                CinematicFrame_CancelCinematic()
                print(
                    WoWTools_GossipMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '跳过' or RENOWN_LEVEL_UP_SKIP_BUTTON)..'|r',
                    WoWTools_DataMixin.onlyChinese and '过场动画' or CINEMATICS
                )
            end)
        end

    elseif Cinematics_ID then
        EventRegistry:UnregisterCallback('CINEMATIC_START', Cinematics_ID)
    end

end







--下载
local function Movie_SubMenu(root, movieID)
    if IsMovieLocal(movieID) then
        return
    end

    local sub=root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '下载' or 'Download',
    function(data)
        PreloadMovie(data.movieID)
        return MenuResponse.Open
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
--视频
    local num=0
    for _ in pairs(Save().movie) do
        num=num+1
    end

    root= root:CreateButton(
        '|T0:0|t'..(WoWTools_DataMixin.onlyChinese and '视频' or VIDEOOPTIONS_MENU),--..(num==0 and ' |cff626262' or ' ')..num,
    function()
        return MenuResponse.Open
    end, {rightText=num})
    WoWTools_MenuMixin:SetRightText(root)


--跳过，视频，
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '跳过播放影片' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, RENOWN_LEVEL_UP_SKIP_BUTTON, PLAY_MOVIE_PREPEND:match('%(.+)%)') or PLAY_MOVIE_PREPEND),
    function()
        return Save().stopMovie
    end, function()
        Save().stopMovie= not Save().stopMovie and true or false
        Set_StopMove()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('PLAY_MOVIE')
        GameTooltip_AddHighlightLine(tooltip,
            WoWTools_DataMixin.onlyChinese and '已经播放' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ANIMA_DIVERSION_NODE_SELECTED, EVENTTRACE_BUTTON_PLAY)
        )
    end)

--动画字幕
    sub2=sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '动画字幕' or CINEMATIC_SUBTITLES,
    function()
        return C_CVar.GetCVarBool("movieSubtitle")
    end, function()
        if not InCombatLockdown() then
            C_CVar.SetCVar('movieSubtitle', C_CVar.GetCVarBool("movieSubtitle") and '0' or '1')
        end
        if SubtitlesFrame and SubtitlesFrame:IsShown() then
            SubtitlesFrame:Hide()
        end
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine("CVar: movieSubtitle")
    end)
    sub2:SetEnabled(not InCombatLockdown())

--跳过，过场动画
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '跳过过场动画' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, RENOWN_LEVEL_UP_SKIP_BUTTON, CINEMATICS),
    function()
        return Save().stopCinematics
    end, function()
        Save().stopCinematics= not Save().stopCinematics and true or false
        Set_StopMove()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('CINEMATIC_START')
    end)
--仅限在副本里
    sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '仅限在副本里' or  format(LFG_LIST_CROSS_FACTION, AGGRO_WARNING_IN_INSTANCE),
    function()
        return Save().stopCinematicsInInstance
    end, function()
        Save().stopCinematicsInInstance= not Save().stopCinematicsInInstance and true or false
    end)


    local _tab={}
--WoW
    sub=root:CreateButton('WoW |cff626262#'..#MovieList, function()
        return MenuResponse.Open
    end)

    for _, movieEntry in pairs(MovieList) do--MOVIE_LIST or 
        for _, movieID in pairs(movieEntry.movieIDs) do
            _tab[movieID]= movieEntry
            sub2=sub:CreateButton(
                '|A:'..(movieEntry.upAtlas or '')..':0:0|a'
                ..(WoWTools_TextMixin:CN(movieEntry.text
                    or _G["EXPANSION_NAME"..movieEntry.expansion])
                    or ''
                )
                ..' |cff626262'..movieID,
            function(data)
                MovieFrame_PlayMovie(MovieFrame, data.movieID)
                return MenuResponse.Open
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
    sub=root:CreateButton('WoW2 |cff626262#'..#List, function()
        return MenuResponse.Open
    end)
    for _, movieID in pairs(List) do
        local text, atlas
        if _tab[movieID] then
            text= _tab[movieID].text
                or WoWTools_TextMixin:CN(_G["EXPANSION_NAME".._tab[movieID].expansion])
                or '|cnWARNING_FONT_COLOR:'
            text= text..' '
            atlas= _tab[movieID].upAtlas
        end
        sub2=sub:CreateButton(
            (atlas and '|A:'..atlas..':0:0|a' or '')
            ..(text and text..' |cff626262' or '')
            ..movieID,
        function(data)
            MovieFrame_PlayMovie(MovieFrame, data.movieID)
            return MenuResponse.Open
        end, {movieID=movieID, atlas=atlas})
        sub2:SetTooltip(function(tooltip, desc)
            if desc.data.atlas then
                tooltip:AddLine('|A:'..(desc.data.atlas or '')..':134:246|a')
            end
        end)
        Movie_SubMenu(sub2, movieID)--下载
    end
    WoWTools_MenuMixin:SetScrollMode(sub)

--列表，电影
    root:CreateDivider()
    local _num= 0
    for movieID, dateTime in pairs(Save().movie) do
        _num= _num+1
        sub=root:CreateButton(
            '|cff626262'.._num..')|r '..movieID,
        function(data)
            MovieFrame_PlayMovie(MovieFrame, data.movieID)
        end, {movieID=movieID, dateTime=dateTime})
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '播放' or EVENTTRACE_BUTTON_PLAY)
        end)
        Movie_SubMenu(sub, movieID, dateTime)
    end

--全部清除
    root:CreateButton(
        (_num==0 and '|cff626262' or '')
        ..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)..' #'.._num,
    function()
        StaticPopup_Show('WoWTools_OK',
        (WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
        nil,
        {SetValue=function()
            Save().movie={}
        end})
    end)

    WoWTools_MenuMixin:SetScrollMode(root)
    _tab= nil
end



function WoWTools_GossipMixin:Init_MoveListMenu(...)
    Init_Menu(...)
end








function WoWTools_GossipMixin:Init_WoW_MoveList()
    Init()
    Set_StopMove()
end