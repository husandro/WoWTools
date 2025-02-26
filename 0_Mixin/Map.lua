--[[
GetPosition()
IsInDelve()
Get_Minimap_Tracking
]]
local e= select(2, ...)
WoWTools_MapMixin={}

function WoWTools_MapMixin:GetPosition()
   --local _x, _y, _z, mapID = UnitPosition("player");
    return UnitPosition("player")
end


--InstanceDifficulty.lua
function WoWTools_MapMixin:IsInDelve()
    local mapID= select(4, self:GetPosition())
    return C_DelvesUI.HasActiveDelve(mapID)
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
    return C_PvP.IsArena() or C_PvP.IsBattleground()
end








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

--副本，难道，颜色
function WoWTools_MapMixin:GetDifficultyColor(string, difficultyID)--DifficultyUtil.lua
    local colorRe, name
    if difficultyID and difficultyID>0 then
        local color= {
            ['经典']= {name= e.onlyChinese and '经典' or LAYOUT_STYLE_CLASSIC, hex='|cff9d9d9d', r=0.62, g=0.62, b=0.62},
            ['场景']= {name= e.onlyChinese and '场景' or SCENARIOS , hex='|cffc6ffc9', r=0.78, g=1, b=0.79},
            ['随机']= {name= e.onlyChinese and '随机' or LFG_TYPE_RANDOM_DUNGEON, hex='|cff1eff00', r=0.12, g=1, b=0},
            ['普通']= {name= e.onlyChinese and '普通' or PLAYER_DIFFICULTY1, hex='|cffffffff', r=1, g=1, b=1},
            ['英雄']= {name= e.onlyChinese and '英雄' or PLAYER_DIFFICULTY2, hex='|cff0070dd', r=0, g=0.44, b=0.87},
            ['史诗']= {name= e.onlyChinese and '史诗' or PLAYER_DIFFICULTY6, hex='|cffff00ff', r=1, g=0, b=1},
            ['挑战']= {name= e.onlyChinese and '挑战' or PLAYER_DIFFICULTY5,  hex='|cffff8200', r=1, g=0.51, b=0},
            ['漫游']= {name= e.onlyChinese and '漫游' or PLAYER_DIFFICULTY_TIMEWALKER, hex='|cff00ffff', r=0, g=1, b=1},
            ['pvp']= {name= 'PvP', hex='|cffff0000', r=1, g=0, b=0},
            ['追随']= {name= e.onlyChinese and '追随' or LFG_TYPE_FOLLOWER_DUNGEON, hex='|cffb1ff00', r=0.69, g=1, b=0, a=1},
            ['地下堡']= {name= e.onlyChinese and '地下堡' or DELVES_LABEL, hex='|cffedd100', r=0.93, g=0.82, b=0, a=1},
            ['团本剧情']={name= e.onlyChinese and '团本剧情' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, RAID, QUEST_CLASSIFICATION_QUESTLINE), hex='|cffaaffaa', r=0.67, g=1.00, b=0.67}

        } or {}
        local type={
            [1]= '普通',--DifficultyUtil.ID.DungeonNormal
            [2]='英雄',--DifficultyUtil.ID.DungeonHeroic
            [3]='普通',--DifficultyUtil.ID.Raid10Normal
            [4]='普通',--DifficultyUtil.ID.Raid25Normal
            [5]='英雄',--DifficultyUtil.ID.Raid10Heroic
            [6]='英雄',--DifficultyUtil.ID.Raid25Heroic
            [7]='随机',--DifficultyUtil.ID.RaidLFR
            [8]='挑战',--DifficultyUtil.ID.DungeonChallenge Mythic Keystone
            [9]='经典',--DifficultyUtil.ID.Raid40 40 Player

            [11]= '英雄',--场景 Heroic Scenario
            [12]= '普通',--场景 Normal Scenario

            [14]='普通',--DifficultyUtil.ID.PrimaryRaidNormal 突袭
            [15]='英雄',--DifficultyUtil.ID.PrimaryRaidHeroic 突袭
            [16]='史诗',--DifficultyUtil.ID.PrimaryRaidMythic 突袭
            [17]='随机',--DifficultyUtil.ID.PrimaryRaidLFR 突袭

            [19]='普通',--场景 Event party
            [20]='普通',--场景 Event Scenario scenario
            [23]='史诗',--DifficultyUtil.ID.DungeonMythic
            [24]='漫游',--DifficultyUtil.ID.DungeonTimewalker
            [25]='pvp',--World PvP Scenario	scenario
            [29]='pvp',--PvEvP Scenario	pvp	
            [30]='普通',--Event	scenario	
            [32]='pvp',--World PvP Scenario	scenario	
            [33]='漫游',--DifficultyUtil.ID.RaidTimewalker	Timewalking	raid	
            [34]='pvp',--PvP pvp	
            [38]='普通',--Normal	scenario	
            [39]='英雄',--Heroic	scenario	displayHeroic
            [40]='史诗',--Mythic	scenario	displayMythic
            [45]='pvp',--PvP	scenario	displayHeroic
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
            [220]='团本剧情',--DifficultyUtil.ID.RaidStory
        }
        name= type[difficultyID]
        if name then
            local tab= color[name]
            if tab then
                string= tab.hex..tab.name..'|r'
                colorRe= tab
            end
        end
    end
    return  string,
            colorRe or (
                e.Player.useColor or {r=e.Player.r, g=e.Player.g, b=e.Player.b, hex=e.Player.col}
            ),
            e.onlyChinese and name or (difficultyID and GetDifficultyInfo(difficultyID))
end


