
WoWTools_DataMixin.WoWGUID={}--战网，好友GUID--WoWTools_DataMixin.WoWGUID[名称-服务器]=guid
WoWTools_DataMixin.UnitItemLevel={}--玩家装等
WoWTools_DataMixin.GroupGuid={}--队伍数据收集



--[[
WoWTools_BagMixin:GetItem_WoW_Num(itemID)--取得WOW物品数量  return all, numPlayer

WoWTools_DataMixin.WoWGUID={}--WoWTools_DataMixin.WoWGUID[名称-服务器]=guid

WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID]={
    Keystone={
        score= score,
        all= all,
        week= WoWTools_DataMixin.Player.Week,
        weekNum= weekNum,
        weekLevel= weekLevel,
        weekPvE= WoWTools_WeekMixin:GetRewardText(3),--Raid
        weekMythicPlus= WoWTools_WeekMixin:GetRewardText(1),--MythicPlus
        weekPvP= WoWTools_WeekMixin:GetRewardText(2),--RankedPvP
        weekWorld= WoWTools_WeekMixin:GetRewardText(6),--世界
        link= WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Keystone.link,
    },
    Item={
        [itemID]={
            bag=bag,
            bank=C_Item.GetItemCount(itemID, true, false, true)-bag,
        },
    },
    Money= GetMoney() or 0
    level=
    faction=
    region=
}

WoWTools_DataMixin.UnitItemLevel=[guid] = {--玩家装等
        itemLevel= C_PaperDollInfo.GetInspectItemLevel(unit) or (WoWTools_DataMixin.UnitItemLevel[guid] and WoWTools_DataMixin.UnitItemLevel[guid].itemLevel),
        specID= GetInspectSpecialization(unit),
        faction= UnitFactionGroup(unit),
        col= hex,
        r=r,
        g=g,
        b=b,
    }
WoWTools_UnitMixin:GetNotifyInspect(tab, unit)--取得装等
WoWTools_DataMixin.GroupGuid[GetUnitName(unit, true) or guid]={--队伍数据
            unit= unit,
            combatRole= UnitGroupRolesAssigned(unit),
            guid=guid,
            faction= UnitFactionGroup(unit),
            level=
        }
GetGroupGuidDate()--队伍数据收集
]]














--##############
--战网，好友GUID
--##############

local function setwowguidTab(info)
    if info and info.characterName then
        local name= WoWTools_UnitMixin:GetFullName(info.characterName)
        if name then
            if info.isOnline and info.wowProjectID==1 then
                WoWTools_DataMixin.WoWGUID[name]={guid=info.playerGuid, faction=info.factionName, level= info.characterLevel}
            else
                WoWTools_DataMixin.WoWGUID[name]=nil
            end
        end
    end
end
local function Get_WoW_GUID_Info(_, friendIndex)
    if friendIndex then
        local accountInfo =C_BattleNet.GetFriendAccountInfo(friendIndex)
        setwowguidTab(accountInfo and accountInfo.gameAccountInfo)
    else
        WoWTools_DataMixin.WoWGUID={}
        for i=1 ,BNGetNumFriends() do
            local accountInfo =C_BattleNet.GetFriendAccountInfo(i);
            setwowguidTab(accountInfo and accountInfo.gameAccountInfo)
        end
    end
end
















--########
--玩家装等
--########
WoWTools_DataMixin.UnitItemLevel={}
local function Get_Player_Info(_, guid)--取得玩家信息
    local unit= guid and UnitTokenFromGUID(guid)
    if not unit then
        return
    end

    local r, g, b, hex= select(2, WoWTools_UnitMixin:Get_Unit_Color(unit, nil))
    WoWTools_DataMixin.UnitItemLevel[guid] = {--玩家装等
        itemLevel= C_PaperDollInfo.GetInspectItemLevel(unit) or (WoWTools_DataMixin.UnitItemLevel[guid] and WoWTools_DataMixin.UnitItemLevel[guid].itemLevel),
        specID= GetInspectSpecialization(unit),
        faction= UnitFactionGroup(unit),
        col= hex,
        r=r,
        g=g,
        b=b,
        level=UnitLevel(unit),
    }
    if UnitInParty(unit) and not IsInRaid() and PartyFrame.MemberFrame1.classFrame then
        for memberFrame in PartyFrame.PartyMemberFramePool:EnumerateActive() do--先使用一次，用以Shift+点击，设置焦点功能, Invite.lua
            if UnitIsUnit(memberFrame.unit, unit) then
                memberFrame.classFrame:set_settings(guid)
                break
            end
        end
    end
    if UnitIsUnit(unit, 'target') and TargetFrame.classFrame then
        TargetFrame.classFrame:set_settings(guid)
    end

    --if UnitIsUnit(unit, 'mouseover') and GameTooltip.textLeft and GameTooltip:IsShown() then
end















--###########
--队伍数据收集
--###########

local function GetGroupGuidDate()--队伍数据收集
    WoWTools_DataMixin.GroupGuid={}
    local UnitTab={}
    if IsInRaid() then
        for index= 1, MAX_RAID_MEMBERS do --GetNumGroupMembers() do
            local unit= 'raid'..index
            if UnitExists(unit) then
                local guid= UnitGUID(unit)
                local _, _, subgroup, _, _, _, _, _, _, role, _, combatRole = GetRaidRosterInfo(index)
                if guid then
                    local tab={
                        unit=unit,
                        subgroup= subgroup,
                        combatRole= role or combatRole,
                        faction= UnitFactionGroup(unit),
                    }
                    WoWTools_DataMixin.GroupGuid[guid]= tab
                    tab.guid= guid
                    WoWTools_DataMixin.GroupGuid[GetUnitName(unit, true)]= tab
                    if not WoWTools_DataMixin.UnitItemLevel[guid] or not WoWTools_DataMixin.UnitItemLevel[guid].itemLevel then
                        table.insert(UnitTab, unit)
                    end
                end
            end
        end
    elseif IsInGroup() then
        for index= 1, 4 do
            local unit= 'party'..index
            local guid= UnitExists(unit) and UnitGUID(unit)
            if guid then
                WoWTools_DataMixin.GroupGuid[guid]= {
                    unit= unit,
                    combatRole= UnitGroupRolesAssigned(unit),
                    faction= UnitFactionGroup(unit),
                }
                WoWTools_DataMixin.GroupGuid[GetUnitName(unit, true)]= {
                    unit= unit,
                    combatRole= UnitGroupRolesAssigned(unit),
                    guid=guid,
                    faction= UnitFactionGroup(unit),
                }
                if not WoWTools_DataMixin.UnitItemLevel[guid] or not WoWTools_DataMixin.UnitItemLevel[guid].itemLevel then
                    table.insert(UnitTab, unit)
                end
            end
        end
    end
    WoWTools_UnitMixin:GetNotifyInspect(UnitTab)--取得装等
end









--#########
--地下城挑战
--#########
local function Update_Challenge_Mode()--{score=总分数,itemLink={超连接}, weekLevel=本周最高, weekNum=本周次数, all=总次数,week=周数}
    local all, weekNum, weekLevel
    local score=C_ChallengeMode.GetOverallDungeonScore()
    if score and score>0 then
        all= #C_MythicPlus.GetRunHistory(true, true)--总次数
        local info = C_MythicPlus.GetRunHistory(false, true)
        if info and #info>0 then
            weekNum=#info--本周次数
            local activities= C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.Activities)
            if activities then
                local lv=0
                for _,v in pairs(activities) do
                    if v and v.level then
                        if v.level and v.level >lv then
                            lv=v.level;
                        end
                    end
                end
                if lv > 0 then
                    weekLevel=lv--本周最高
                end
            end
        end
    end

    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Keystone={
        score= score,
        all= all,
        week= WoWTools_DataMixin.Player.Week,
        weekNum= weekNum,
        weekLevel= weekLevel,

        weekPvE= WoWTools_WeekMixin:GetRewardText(Enum.WeeklyRewardChestThresholdType.Raid),--Raid
        weekMythicPlus= WoWTools_WeekMixin:GetRewardText(Enum.WeeklyRewardChestThresholdType.Activities),--MythicPlus
        weekPvP= WoWTools_WeekMixin:GetRewardText(Enum.WeeklyRewardChestThresholdType.RankedPvP),--RankedPvP
        weekWorld=WoWTools_WeekMixin:GetRewardText(Enum.WeeklyRewardChestThresholdType.World),--world
        link= WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Keystone.link,
    }
end











--更新物品
local function Update_Bag_Items()
    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Keystone.link=nil
    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Item={}--{itemID={bag=包, bank=银行}}
    for bagID= Enum.BagIndex.Backpack,  NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES do
        for slotID=1, C_Container.GetContainerNumSlots(bagID) do
            local itemID = C_Container.GetContainerItemID(bagID, slotID)
            if itemID then
                if C_Item.IsItemKeystoneByID(itemID) then--挑战
                    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Keystone.link= C_Container.GetContainerItemLink(bagID, slotID)

                else
                    local bag=C_Item.GetItemCount(itemID)--物品ID
                    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Item[itemID]={
                        bag=bag,
                        bank=C_Item.GetItemCount(itemID, true, false, true)-bag,
                    }
                end
            end
        end
    end
end


































--#######
--更新货币
--#######
local function Update_Currency(_, arg1)--{currencyID = 数量}
    if arg1 and arg1~=2032 then
        local info = C_CurrencyInfo.GetCurrencyInfo(arg1)
        if info and info.quantity then
            if C_CurrencyInfo.IsAccountWideCurrency(arg1) then
                WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Currency[arg1]=nil
            else
                WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Currency[arg1]=info.quantity==0 and nil or info.quantity
            end
        end
    else
        for i=1, C_CurrencyInfo.GetCurrencyListSize() do
            local link =C_CurrencyInfo.GetCurrencyListLink(i)
            local currencyID = link and C_CurrencyInfo.GetCurrencyIDFromLink(link)
            local info = C_CurrencyInfo.GetCurrencyListInfo(i)
            if currencyID and info and info.quantity and currencyID~=2032 then
                if C_CurrencyInfo.IsAccountWideCurrency(currencyID) then
                    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Currency[currencyID]=nil
                else
                    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Currency[currencyID]= info.quantity<=0 and nil or info.quantity
                end
            end
        end
    end
end





















--#############
--副本, 世界BOSS
--#############
local function Update_Instance()--encounterID, encounterName)
    local tab={}--已杀世界BOSS
    for i=1, GetNumSavedWorldBosses() do--{week=周数, boss={name=true}}}
        local bossName, worldBossID, reset=GetSavedWorldBossInfo(i)
        if bossName and (not reset or reset>0) then
            tab[bossName] = worldBossID
            if WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Rare.boss[bossName] then--清除稀有怪
                WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Rare.boss[bossName]=nil
            end
        end
    end

    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Worldboss={
        week=WoWTools_DataMixin.Player.Week,
        day= date('%x'),
        boss=tab
    }

    tab={}
    for i=1, GetNumSavedInstances() do--副本
        local name, _, reset, difficulty, _, _, _, _, _, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
        if reset and reset>0 and numEncounters and encounterProgress and numEncounters>0 and encounterProgress>0 and difficultyName then
            local killed = encounterProgress ..'/'..numEncounters;
            killed = encounterProgress ==numEncounters and '|cnGREEN_FONT_COLOR:'..killed..'|r' or killed
            difficultyName=WoWTools_MapMixin:GetDifficultyColor(difficultyName, difficulty)
            tab[name] = tab[name] or {}
            tab[name][difficultyName]=killed
        end
    end
    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Instance = {
        week=WoWTools_DataMixin.Player.Week,
        day=date('%x'),
        ins=tab
    }
end






















--#########
--稀有怪数据
--#########
local function Set_Rare_Elite_Killed(unit)--稀有怪数据
    if unit=='loot' then
        unit='target'
        local classification = UnitExists(unit) and UnitClassification(unit)
        if classification == "rare" or classification == "rareelite" then
            local name=UnitName(unit)
            if name then
                WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Rare.boss[name]=true
                RequestRaidInfo()
            end
        end
    elseif UnitIsDead(unit) then
        local classification = UnitClassification(unit)
        if classification == "rare" or classification == "rareelite" then
            local threat = UnitThreatSituation('player',unit)
            if threat and threat>0 then
                local name=UnitName(unit)
                if name then
                    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Rare.boss[name]=true
                    RequestRaidInfo()
                end
            end
        end
    end
end




















--##
--钱
--##
local function Set_Money()--钱
    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Money= GetMoney() or 0
end












--挑战
local function Get_Info_Challenge()--挑战
    if not WoWTools_DataMixin.Player.IsMaxLevel then
        return
    end
    C_MythicPlus.RequestCurrentAffixes()
    C_MythicPlus.RequestMapInfo()
    C_MythicPlus.RequestRewards()
    for _, mapChallengeModeID in pairs(C_ChallengeMode.GetMapTable() or {}) do
        WoWTools_Mixin:Load({type='mapChallengeModeID',mapChallengeModeID })
    end
end
--[[
    C_MythicPlus.GetRunHistory(false, true)--本周记录      
    RequestRatedInfo()--从服务器请求有关玩家 PvP 评分的信息。
    RequestRandomBattlegroundInstanceInfo()--请求随机战场实例信息
    RequestBattlefieldScoreData()--请求战地得分数据
]]

































--队伍数据
EventRegistry:RegisterFrameEventAndCallback("GROUP_ROSTER_UPDATE", GetGroupGuidDate)
EventRegistry:RegisterFrameEventAndCallback("GROUP_LEFT", GetGroupGuidDate)

--总游戏时间：%s
EventRegistry:RegisterFrameEventAndCallback("TIME_PLAYED_MSG", function(_, arg1, arg2)
    if arg1 and arg2 then
        WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Time={
            totalTime= arg1,
            levelTime= arg2,
        }
    end
end)

--取得玩家信息
EventRegistry:RegisterFrameEventAndCallback("INSPECT_READY", Get_Player_Info)

--地下城挑战
EventRegistry:RegisterFrameEventAndCallback("CHALLENGE_MODE_MAPS_UPDATE", function(_, arg1)
    C_MythicPlus.RequestRewards()
    C_Timer.After(4, Update_Challenge_Mode)
end)
EventRegistry:RegisterFrameEventAndCallback("WEEKLY_REWARDS_UPDATE", function(_, arg1)
    C_MythicPlus.RequestRewards()
    C_Timer.After(4, Update_Challenge_Mode)
end)

--挑战
EventRegistry:RegisterFrameEventAndCallback("CHALLENGE_MODE_COMPLETED", Get_Info_Challenge)

--位面, 清除
EventRegistry:RegisterFrameEventAndCallback("ZONE_CHANGED_NEW_AREA", function(_, arg1)
    WoWTools_DataMixin.Player.Layer=nil
end)
EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(_, arg1)
    WoWTools_DataMixin.Player.Layer=nil
end)

--记录稀有怪
EventRegistry:RegisterFrameEventAndCallback("UNIT_FLAGS", function(_, arg1)
    if not IsInInstance() and arg1 then
        return
    end
    Set_Rare_Elite_Killed(arg1)
end)
EventRegistry:RegisterFrameEventAndCallback("LOOT_OPENED", function(_, arg1)
    if not IsInInstance() then
        return
    end
    Set_Rare_Elite_Killed('loot')
end)
EventRegistry:RegisterFrameEventAndCallback("BOSS_KILL", RequestRaidInfo)

--货币
EventRegistry:RegisterFrameEventAndCallback("CURRENCY_DISPLAY_UPDATE", Update_Currency)

--更新物品
EventRegistry:RegisterFrameEventAndCallback("BAG_UPDATE_DELAYED", Update_Bag_Items)

--副本
EventRegistry:RegisterFrameEventAndCallback("UPDATE_INSTANCE_INFO", Update_Instance)

--钱
EventRegistry:RegisterFrameEventAndCallback("PLAYER_MONEY", Set_Money)

--玩家是否最高等级
EventRegistry:RegisterFrameEventAndCallback("PLAYER_LEVEL_UP", function(_, arg1)
    local level= arg1 or UnitLevel('player')
    WoWTools_DataMixin.Player.IsMaxLevel= level==GetMaxLevelForLatestExpansion()--玩家是否最高等级
    WoWTools_DataMixin.Player.Level= level
    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].level= level
end)

--玩家, 派系
EventRegistry:RegisterFrameEventAndCallback("NEUTRAL_FACTION_SELECT_RESULT", function(_, arg1)
    if arg1 then
        WoWTools_DataMixin.Player.Faction= UnitFactionGroup('player')--玩家, 派系  "Alliance", "Horde", "Neutral"
    end
end)

--取得装等, 更新自已
EventRegistry:RegisterFrameEventAndCallback("PLAYER_EQUIPMENT_CHANGED", function(_, arg1)
    WoWTools_UnitMixin:GetNotifyInspect(nil, 'player')--取得装等
end)
EventRegistry:RegisterFrameEventAndCallback("PLAYER_SPECIALIZATION_CHANGED", function(_, arg1)
    WoWTools_UnitMixin:GetNotifyInspect(nil, 'player')--取得装等
end)
EventRegistry:RegisterFrameEventAndCallback("PLAYER_AVG_ITEM_LEVEL_UPDATE", function(_, arg1)
    WoWTools_UnitMixin:GetNotifyInspect(nil, 'player')--取得装等
end)

--[[给 e.Reload用
EventRegistry:RegisterFrameEventAndCallback("ENCOUNTER_START", function(_, encounterID)
    e.IsEncouter_Start= encounterID
end)
EventRegistry:RegisterFrameEventAndCallback("ENCOUNTER_END", function(_, arg1)
    e.IsEncouter_Start= nil
end)]]

--战网，好友GUID
EventRegistry:RegisterFrameEventAndCallback("BN_FRIEND_INFO_CHANGED", Get_WoW_GUID_Info)

EventRegistry:RegisterFrameEventAndCallback("BARBER_SHOP_RESULT", function(_, arg1)
    if arg1 then
        WoWTools_DataMixin.Player.Sex= UnitSex("player")
        WoWTools_DataMixin.Icon.Player= WoWTools_UnitMixin:GetRaceIcon({unit='player', guid=nil , race=nil , sex=nil , reAtlas=false})
    end
end)


















EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
    if arg1~='WoWTools' then
        return
    end

    WoWToolsSave= WoWToolsSave or {}
    WoWTools_WoWDate= WoWTools_WoWDate or {}


    local day= date('%x')--日期
    if not WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID] then
        WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID]= {--默认数据
            Item={},--{itemID={bag=包, bank=银行}},
            Currency={},--{currencyID = 数量}

            Keystone={week=WoWTools_DataMixin.Player.Week},--{score=总分数, link=超连接, weekLevel=本周最高, weekNum=本周次数, all=总次数,week=周数},

            Instance={ins={}, week=WoWTools_DataMixin.Player.Week, day=day},--ins={[名字]={[难度]=已击杀数}}
            Worldboss={boss={}, week=WoWTools_DataMixin.Player.Week, day=day},--{week=周数, boss=table}
            Rare={day=day, boss={}},--稀有
            Time={},--{totalTime=总游戏时间, levelTime=当前等级时间}总游戏时间
            Guild={
                --text= text, GuildInfo() 公会信息,
                --guid= guid, 公会 clubFinderGUID 
                data={},-- {guildName, guildRankName, guildRankIndex, realm} = GetGuildInfo('player')
            },
            --Money=钱
            Bank={},--{[itemID]={num=数量,quality=品质}}银行，数据
            region= WoWTools_DataMixin.Player.Region
        }
    end

    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Bank= WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Bank or {}--派系

    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Guild= WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Guild or {data={}}--公会信息
    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].GuildInfo=nil--清除，旧版本数据
    

    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].region= WoWTools_DataMixin.Player.Region
    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].faction= WoWTools_DataMixin.Player.Faction--派系
    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].level= WoWTools_DataMixin.Player.Level
    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].battleTag= WoWTools_DataMixin.Player.BattleTag or WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].battleTag


    for guid, tab in pairs(WoWTools_WoWDate) do--清除不是本周数据
        if tab.Keystone.week ~=WoWTools_DataMixin.Player.Week then
            WoWTools_WoWDate[guid].Keystone={week=WoWTools_DataMixin.Player.Week}
        end
        if tab.Instance.week~=WoWTools_DataMixin.Player.Week or (PlayerGetTimerunningSeasonID() and tab.Keystone.day and tab.Keystone.day~=day) then
            WoWTools_WoWDate[guid].Instance={ins={}, day=day}
        end
        if (tab.Worldboss.week~=WoWTools_DataMixin.Player.Week) or (PlayerGetTimerunningSeasonID() and tab.Keystone.day and tab.Keystone.day~=day) then
            WoWTools_WoWDate[guid].Worldboss={boss={}, day=day}
        end

        if tab.Rare.day~=day then
            WoWTools_WoWDate[guid].Rare={day=day,boss={}}
        end
    end

    Get_Info_Challenge()--挑战

    --C_MajorFactions.RequestCatchUpState()
    C_FriendList.ShowFriends()


    --C_PerksProgram.RequestPendingChestRewards()

    C_Timer.After(4, function()


        C_CurrencyInfo.RequestCurrencyDataForAccountCharacters()
        RequestRaidInfo()

        C_Calendar.OpenCalendar()
        WoWTools_UnitMixin:GetNotifyInspect(nil, 'player')--取得,自已, 装等
        GetGroupGuidDate()--队伍数据收集

        Update_Currency()--{currencyID = 数量}
        Update_Bag_Items()
        Set_Money()--钱
        Update_Challenge_Mode()
        --################
        --开启, 新手編輯模式
        --################ LFDFrame.lua
        if C_PlayerInfo.IsPlayerNPERestricted() then
            --C_PlayerInfo.IsPlayerNPERestricted= function() return false end
            EditModeManagerFrame.CanEnterEditMode = function(self2)--EditModeManager.lua
                return TableIsEmpty(self2.FramesBlockingEditMode)
            end
            if Minimap then
                Minimap:SetShown(true)
                MinimapCluster:SetShown(true)
            end
        end

        Get_WoW_GUID_Info()--战网，好友GUID                

    end)

    EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
end)






