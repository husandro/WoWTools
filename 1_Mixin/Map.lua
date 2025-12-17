--[[
GetPosition()
IsInDelve()
Get_Minimap_Tracking
]]

WoWTools_MapMixin={}

--local _x, _y, _z, mapID = UnitPosition("player");
function WoWTools_MapMixin:GetPosition()
    return UnitPosition("player")
end


--InstanceDifficulty.lua
function WoWTools_MapMixin:IsInDelve()
    local mapID= select(4, self:GetPosition())
    return mapID and C_DelvesUI.HasActiveDelve(mapID)
end





function WoWTools_MapMixin:Get_Minimap_Tracking(checkName, isSettings)
    for trackingID=1, C_Minimap.GetNumTrackingTypes() do
        local info= C_Minimap.GetTrackingInfo(trackingID)
        if info and info.name== checkName then
            local active= info.active
            if isSettings then
                active= not info.active and true or false
                C_Minimap.SetTracking(trackingID, active)
            end
            return active
        end
    end
end





function WoWTools_MapMixin:GetUnit(unit)--单位, 地图名称
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


function WoWTools_MapMixin:IsInPvPArea()--是否在，PVP区域中
    return C_PvP.IsArena()
        or C_PvP.IsBattleground()--战场
        or C_PvP.IsSoloShuffle()--闪电战
        or C_PvP.IsInBrawl()--乱斗
end
--PVPMatchUtil.lua
--[[
        C_PvP.IsSoloRBG() or
			C_PvP.IsRatedBattleground() or
			(C_PvP.IsRatedArena() and not IsArenaSkirmish());
         --or C_PvP.IsSoloRBG()
        --or C_PvP.IsRatedBattleground()
        --or C_PvP.IsRatedSoloShuffle()
        --or C_PvP.IsRatedArena()
]]






--[[local DIFFICULTY_NAMES = {
	[DifficultyUtil.ID.DungeonNormal] = PLAYER_DIFFICULTY1,
	[DifficultyUtil.ID.DungeonHeroic] = PLAYER_DIFFICULTY2,
	[DifficultyUtil.ID.Raid10Normal] = PLAYER_DIFFICULTY1,
	[DifficultyUtil.ID.Raid25Normal] = PLAYER_DIFFICULTY1,
	[DifficultyUtil.ID.Raid10Heroic] = PLAYER_DIFFICULTY2,
	[DifficultyUtil.ID.Raid25Heroic] = PLAYER_DIFFICULTY2,
	[DifficultyUtil.ID.RaidLFR] = PLAYER_DIFFICULTY3,
	[DifficultyUtil.ID.DungeonChallenge] = PLAYER_DIFFICULTY_MYTHIC_PLUS,
	[DifficultyUtil.ID.Raid40] = LEGACY_RAID_DIFFICULTY,
	[DifficultyUtil.ID.PrimaryRaidNormal] = PLAYER_DIFFICULTY1,
	[DifficultyUtil.ID.PrimaryRaidHeroic] = PLAYER_DIFFICULTY2,
	[DifficultyUtil.ID.PrimaryRaidMythic] = PLAYER_DIFFICULTY6,
	[DifficultyUtil.ID.PrimaryRaidLFR] = PLAYER_DIFFICULTY3,
	[DifficultyUtil.ID.DungeonMythic] = PLAYER_DIFFICULTY6,
	[DifficultyUtil.ID.DungeonTimewalker] = PLAYER_DIFFICULTY_TIMEWALKER,
	[DifficultyUtil.ID.RaidTimewalker] = PLAYER_DIFFICULTY_TIMEWALKER,
	[DifficultyUtil.ID.Raid40] = PLAYER_DIFFICULTY1,
}]]
local DifficultyType={
    [1]='普通',--DifficultyUtil.ID.DungeonNormal
    [2]='英雄',--DifficultyUtil.ID.DungeonHeroic
    [3]='普通',--DifficultyUtil.ID.Raid10Normal
    [4]='普通',--DifficultyUtil.ID.Raid25Normal
    [5]='英雄',--DifficultyUtil.ID.Raid10Heroic
    [6]='英雄',--DifficultyUtil.ID.Raid25Heroic
    [7]='随机',--DifficultyUtil.ID.RaidLFR
    [8]='挑战',--DifficultyUtil.ID.DungeonChallenge Mythic Keystone
    [9]='经典',--DifficultyUtil.ID.Raid40 40 Player

    [11]='英雄',--场景 Heroic Scenario
    [12]='普通',--场景 Normal Scenario

    [14]='普通',--DifficultyUtil.ID.PrimaryRaidNormal 突袭
    [15]='英雄',--DifficultyUtil.ID.PrimaryRaidHeroic 突袭
    [16]='史诗',--DifficultyUtil.ID.PrimaryRaidMythic 突袭
    [17]='随机',--DifficultyUtil.ID.PrimaryRaidLFR 突袭

    [19]='普通',--场景 Event party
    [20]='普通',--场景 Event Scenario scenario
    [23]='史诗',--DifficultyUtil.ID.DungeonMythic
    [24]='漫游',--DifficultyUtil.ID.DungeonTimewalker
    [25]='PvP',--World PvP Scenario	scenario
    [29]='pvp',--PvEvP Scenario	pvp	
    [30]='普通',--Event	scenario	
    [32]='PvP',--World PvP Scenario	scenario	
    [33]='漫游',--DifficultyUtil.ID.RaidTimewalker	Timewalking	raid	
    [34]='PvP',--PvP pvp	
    [38]='普通',--Normal	scenario	
    [39]='英雄',--Heroic	scenario	displayHeroic
    [40]='史诗',--Mythic	scenario	displayMythic
    [45]='PvP',--PvP	scenario	displayHeroic
    [147]='普通',--Normal	scenario	Warfronts
    [149]='英雄',--Heroic	scenario	displayHeroic Warfronts
    [150]='普通',--Normal	party	
    [151]='漫游',--Looking For Raid	raid	Timewalking
    [152]='普通',--Visions of N'Zoth	scenario	
    [153]='英雄',--Teeming Island	scenario	displayHeroic
    [167]='普通',--Torghast	scenario	
    [168]='普通',--Path of Ascension: Courage	scenario	
    [169]='普通',--Path of Ascension: Loyalty	scenario	
    [170]='普通',--Path of Ascension: Wisdom	scenario	
    [171]='普通',--Path of Ascension: Humility	scenario
    [205]='追随',--Seguace (5) LFG_TYPE_FOLLOWER_DUNGEON = "追随者地下城"
    [208]='地下堡',
    [220]='剧情团队',--DifficultyUtil.ID.RaidStory
    [230]='英雄',
}

local DifficultyColor= {}
EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(owner)
    DifficultyColor= {
        ['经典']= {name= WoWTools_DataMixin.onlyChinese and '经典' or LAYOUT_STYLE_CLASSIC, hex='|cff9d9d9d', r=0.62, g=0.62, b=0.62},
        ['场景']= {name= WoWTools_DataMixin.onlyChinese and '场景' or SCENARIOS , hex='|cffc6ffc9', r=0.78, g=1, b=0.79},
        ['随机']= {name= WoWTools_DataMixin.onlyChinese and '随机' or LFG_TYPE_RANDOM_DUNGEON, hex='|cff1eff00', r=0.12, g=1, b=0},
        ['普通']= {name= WoWTools_DataMixin.onlyChinese and '普通' or PLAYER_DIFFICULTY1, hex='|cffffffff', r=1, g=1, b=1},
        ['英雄']= {name= WoWTools_DataMixin.onlyChinese and '英雄' or PLAYER_DIFFICULTY2, hex='|cff0070dd', r=0, g=0.44, b=0.87},
        ['史诗']= {name= WoWTools_DataMixin.onlyChinese and '史诗' or PLAYER_DIFFICULTY6, hex='|cffff00ff', r=1, g=0, b=1},
        ['挑战']= {name= WoWTools_DataMixin.onlyChinese and '挑战' or PLAYER_DIFFICULTY5,  hex='|cffff8200', r=1, g=0.51, b=0},
        ['漫游']= {name= WoWTools_DataMixin.onlyChinese and '漫游' or PLAYER_DIFFICULTY_TIMEWALKER, hex='|cff00ffff', r=0, g=1, b=1},
        ['PvP']= {name= 'PvP', hex='|cffff4800', r=1, g=0, b=0},
        ['追随']= {name= WoWTools_DataMixin.onlyChinese and '追随' or LFG_TYPE_FOLLOWER_DUNGEON, hex='|cffb1ff00', r=0.69, g=1, b=0, a=1},
        ['地下堡']= {name= WoWTools_DataMixin.onlyChinese and '地下堡' or DELVES_LABEL, hex='|cffedd100', r=0.93, g=0.82, b=0, a=1},
        ['剧情团队']={name= WoWTools_DataMixin.onlyChinese and '剧情团队' or PLAYER_DIFFICULTY_STORY_RAID, hex='|cffaaffaa', r=0.67, g=1.00, b=0.67}

    }
    EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
end)

--副本，难道，颜色
function WoWTools_MapMixin:GetDifficultyColor(difficultyName, difficultyID)--DifficultyUtil.lua
    difficultyName= difficultyID and GetDifficultyInfo(difficultyID) or difficultyName
    difficultyName= WoWTools_TextMixin:CN(difficultyName)

    local colorRe, name
    if difficultyID and difficultyID>0 then
        name= DifficultyType[difficultyID]
        if name then
            local tab= DifficultyColor[name]
            if tab then
                difficultyName= tab.hex..name..'|r'
                colorRe= tab
            end
        end
    end
    if not colorRe then
        local color= PlayerUtil.GetClassColor()
        colorRe={
            r=color.r,
            g=color.g,
            b=color.b,
            hex= color:GenerateHexColorMarkup(),
        }
    end
    return difficultyName, colorRe
end


