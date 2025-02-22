local id, e = ...




--[[
e.GetItemWoWNum(itemID)--取得WOW物品数量  return all, numPlayer

e.WoWGUID={}--e.WoWGUID[名称-服务器]=guid

e.WoWDate[e.Player.guid]={
    Keystone={
        score= score,
        all= all,
        week= e.Player.week,
        weekNum= weekNum,
        weekLevel= weekLevel,
        weekPvE= WoWTools_WeekMixin:GetRewardText(3),--Raid
        weekMythicPlus= WoWTools_WeekMixin:GetRewardText(1),--MythicPlus
        weekPvP= WoWTools_WeekMixin:GetRewardText(2),--RankedPvP
        weekWorld= WoWTools_WeekMixin:GetRewardText(6),--世界
        link= e.WoWDate[e.Player.guid].Keystone.link,
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

e.UnitItemLevel=[guid] = {--玩家装等
        itemLevel= C_PaperDollInfo.GetInspectItemLevel(unit) or (e.UnitItemLevel[guid] and e.UnitItemLevel[guid].itemLevel),
        specID= GetInspectSpecialization(unit),
        faction= UnitFactionGroup(unit),
        col= hex,
        r=r,
        g=g,
        b=b,
    }
e.GetNotifyInspect(tab, unit)--取得装等
e.GroupGuid[GetUnitName(unit, true) or guid]={--队伍数据
            unit= unit,
            combatRole= UnitGroupRolesAssigned(unit),
            guid=guid,
            faction= UnitFactionGroup(unit),
            level=
        }
e.GetGroupGuidDate()--队伍数据收集
]]














--##############
--战网，好友GUID
--##############
e.WoWGUID={}--e.WoWGUID[名称-服务器]=guid


local function setwowguidTab(info)
    if info and info.characterName then
        local name= WoWTools_UnitMixin:GetFullName(info.characterName)
        if name then
            if info.isOnline and info.wowProjectID==1 then
                e.WoWGUID[name]={guid=info.playerGuid, faction=info.factionName, level= info.characterLevel}
            else
                e.WoWGUID[name]=nil
            end
        end
    end
end
local function Get_WoW_GUID_Info(_, friendIndex)
    if friendIndex then
        local accountInfo =C_BattleNet.GetFriendAccountInfo(friendIndex)
        setwowguidTab(accountInfo and accountInfo.gameAccountInfo)
    else
        e.WoWGUID={}
        for i=1 ,BNGetNumFriends() do
            local accountInfo =C_BattleNet.GetFriendAccountInfo(i);
            setwowguidTab(accountInfo and accountInfo.gameAccountInfo)
        end
    end
end
















--########
--玩家装等
--########
e.UnitItemLevel={}
local function Get_Player_Info(_, guid)--取得玩家信息
    local unit= guid and UnitTokenFromGUID(guid)
    if not unit then
        return
    end

    local r, g, b, hex= select(2, WoWTools_UnitMixin:Get_Unit_Color(unit, nil))
    e.UnitItemLevel[guid] = {--玩家装等
        itemLevel= C_PaperDollInfo.GetInspectItemLevel(unit) or (e.UnitItemLevel[guid] and e.UnitItemLevel[guid].itemLevel),
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














--#######
--取得装等
--#######
local NotifyInspectTicker
function e.GetNotifyInspect(tab, unit)
    if unit then
        if UnitExists(unit) and CanInspect(unit) and (not InspectFrame or not InspectFrame:IsShown()) then--and CheckInteractDistance(unit, 1)
            NotifyInspect(unit)
        end
    else
        tab=tab or {}
        local num, index= #tab, 1
        if num>0 then
            if NotifyInspectTicker and not NotifyInspectTicker:IsCancelled() then
                NotifyInspectTicker:Cancel()
            end
            NotifyInspectTicker=C_Timer.NewTimer(4, function()--InspectFrame,如果显示，查看玩家，天赋，出错
                local unit2=tab[index]
                if UnitExists(unit2) and CanInspect(unit2) and (not InspectFrame or not InspectFrame:IsShown()) then--and CheckInteractDistance(unit2, 1)
                    NotifyInspect(tab[index])
                    index= index+ 1
                end
            end, num)
        end
    end
end

--###########
--队伍数据收集
--###########
e.GroupGuid={}
function e.GetGroupGuidDate()--队伍数据收集
    e.GroupGuid={}
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
                    e.GroupGuid[guid]= tab
                    tab.guid= guid
                    e.GroupGuid[GetUnitName(unit, true)]= tab
                    if not e.UnitItemLevel[guid] or not e.UnitItemLevel[guid].itemLevel then
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
                e.GroupGuid[guid]= {
                    unit= unit,
                    combatRole= UnitGroupRolesAssigned(unit),
                    faction= UnitFactionGroup(unit),
                }
                e.GroupGuid[GetUnitName(unit, true)]= {
                    unit= unit,
                    combatRole= UnitGroupRolesAssigned(unit),
                    guid=guid,
                    faction= UnitFactionGroup(unit),
                }
                if not e.UnitItemLevel[guid] or not e.UnitItemLevel[guid].itemLevel then
                    table.insert(UnitTab, unit)
                end
            end
        end
    end
    e.GetNotifyInspect(UnitTab)--取得装等
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

    e.WoWDate[e.Player.guid].Keystone={
        score= score,
        all= all,
        week= e.Player.week,
        weekNum= weekNum,
        weekLevel= weekLevel,

        weekPvE= WoWTools_WeekMixin:GetRewardText(Enum.WeeklyRewardChestThresholdType.Raid),--Raid
        weekMythicPlus= WoWTools_WeekMixin:GetRewardText(Enum.WeeklyRewardChestThresholdType.Activities),--MythicPlus
        weekPvP= WoWTools_WeekMixin:GetRewardText(Enum.WeeklyRewardChestThresholdType.RankedPvP),--RankedPvP
        weekWorld=WoWTools_WeekMixin:GetRewardText(Enum.WeeklyRewardChestThresholdType.World),--world
        link= e.WoWDate[e.Player.guid].Keystone.link,
    }
end











--更新物品
local function Update_Bag_Items()
    e.WoWDate[e.Player.guid].Keystone.link=nil
    e.WoWDate[e.Player.guid].Item={}--{itemID={bag=包, bank=银行}}
    for bagID= Enum.BagIndex.Backpack,  NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES do
        for slotID=1, C_Container.GetContainerNumSlots(bagID) do
            local itemID = C_Container.GetContainerItemID(bagID, slotID)
            if itemID then
                if C_Item.IsItemKeystoneByID(itemID) then--挑战
                    e.WoWDate[e.Player.guid].Keystone.link= C_Container.GetContainerItemLink(bagID, slotID)

                else
                    local bag=C_Item.GetItemCount(itemID)--物品ID
                    e.WoWDate[e.Player.guid].Item[itemID]={
                        bag=bag,
                        bank=C_Item.GetItemCount(itemID, true, false, true)-bag,
                    }
                end
            end
        end
    end
end


















function e.GetItemWoWNum(itemID)--e.GetItemWoWNum()--取得WOW物品数量
    local all,numPlayer=0,0
    for guid, info in pairs(e.WoWDate) do
        if guid and info and info.region==e.Player.region then --and guid~=e.Player.guid then
            local tab=info.Item[itemID]
            if tab and tab.bag and tab.bank then
                all=all +tab.bag
                all=all +tab.bank
                numPlayer=numPlayer +1
            end
        end
    end
    return all, numPlayer
end



















--#######
--更新货币
--#######
local function Update_Currency(_, arg1)--{currencyID = 数量}
    if arg1 and arg1~=2032 then
        local info = C_CurrencyInfo.GetCurrencyInfo(arg1)
        if info and info.quantity then
            if C_CurrencyInfo.IsAccountWideCurrency(arg1) then
                e.WoWDate[e.Player.guid].Currency[arg1]=nil
            else
                e.WoWDate[e.Player.guid].Currency[arg1]=info.quantity==0 and nil or info.quantity
            end
        end
    else
        for i=1, C_CurrencyInfo.GetCurrencyListSize() do
            local link =C_CurrencyInfo.GetCurrencyListLink(i)
            local currencyID = link and C_CurrencyInfo.GetCurrencyIDFromLink(link)
            local info = C_CurrencyInfo.GetCurrencyListInfo(i)
            if currencyID and info and info.quantity and currencyID~=2032 then
                if C_CurrencyInfo.IsAccountWideCurrency(currencyID) then
                    e.WoWDate[e.Player.guid].Currency[currencyID]=nil
                else
                    e.WoWDate[e.Player.guid].Currency[currencyID]= info.quantity<=0 and nil or info.quantity
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
            if e.WoWDate[e.Player.guid].Rare.boss[bossName] then--清除稀有怪
                e.WoWDate[e.Player.guid].Rare.boss[bossName]=nil
            end
        end
    end

    e.WoWDate[e.Player.guid].Worldboss={
        week=e.Player.week,
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
    e.WoWDate[e.Player.guid].Instance = {
        week=e.Player.week,
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
                e.WoWDate[e.Player.guid].Rare.boss[name]=true
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
                    e.WoWDate[e.Player.guid].Rare.boss[name]=true
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
    e.WoWDate[e.Player.guid].Money= GetMoney() or 0
end












--挑战
local function Get_Info_Challenge()--挑战
    if not e.Player.IsMaxLevel then
        return
    end
    C_MythicPlus.RequestCurrentAffixes()
    C_MythicPlus.RequestMapInfo()
    C_MythicPlus.RequestRewards()
    for _, mapChallengeModeID in pairs(C_ChallengeMode.GetMapTable() or {}) do
        e.LoadData({type='mapChallengeModeID',mapChallengeModeID })
    end
end
--[[
    C_MythicPlus.GetRunHistory(false, true)--本周记录      
    RequestRatedInfo()--从服务器请求有关玩家 PvP 评分的信息。
    RequestRandomBattlegroundInstanceInfo()--请求随机战场实例信息
    RequestBattlefieldScoreData()--请求战地得分数据
]]

































--队伍数据
EventRegistry:RegisterFrameEventAndCallback("GROUP_ROSTER_UPDATE", e.GetGroupGuidDate)
EventRegistry:RegisterFrameEventAndCallback("GROUP_LEFT", e.GetGroupGuidDate)

--总游戏时间：%s
EventRegistry:RegisterFrameEventAndCallback("TIME_PLAYED_MSG", function(_, arg1, arg2)
    if arg1 and arg2 then
        e.WoWDate[e.Player.guid].Time={
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
    e.Player.Layer=nil
end)
EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(_, arg1)
    e.Player.Layer=nil
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
    e.Player.IsMaxLevel= level==GetMaxLevelForLatestExpansion()--玩家是否最高等级
    e.Player.level= level
    e.WoWDate[e.Player.guid].level= level
end)

--玩家, 派系
EventRegistry:RegisterFrameEventAndCallback("NEUTRAL_FACTION_SELECT_RESULT", function(_, arg1)
    if arg1 then
        e.Player.faction= UnitFactionGroup('player')--玩家, 派系  "Alliance", "Horde", "Neutral"
    end
end)

--取得装等, 更新自已
EventRegistry:RegisterFrameEventAndCallback("PLAYER_EQUIPMENT_CHANGED", function(_, arg1)
    e.GetNotifyInspect(nil, 'player')--取得装等
end)
EventRegistry:RegisterFrameEventAndCallback("PLAYER_SPECIALIZATION_CHANGED", function(_, arg1)
    e.GetNotifyInspect(nil, 'player')--取得装等
end)
EventRegistry:RegisterFrameEventAndCallback("PLAYER_AVG_ITEM_LEVEL_UPDATE", function(_, arg1)
    e.GetNotifyInspect(nil, 'player')--取得装等
end)

--给 e.Reload用
EventRegistry:RegisterFrameEventAndCallback("ENCOUNTER_START", function(_, encounterID)
    e.IsEncouter_Start= encounterID
end)
EventRegistry:RegisterFrameEventAndCallback("ENCOUNTER_END", function(_, arg1)
    e.IsEncouter_Start= nil
end)

--战网，好友GUID
EventRegistry:RegisterFrameEventAndCallback("BN_FRIEND_INFO_CHANGED", Get_WoW_GUID_Info)

EventRegistry:RegisterFrameEventAndCallback("BARBER_SHOP_RESULT", function(_, arg1)
    if arg1 then
        e.Player.sex= UnitSex("player")
        e.Icon.player= WoWTools_UnitMixin:GetRaceIcon({unit='player', guid=nil , race=nil , sex=nil , reAtlas=false})
    end
end)


















EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
    if arg1~=id then
        return
    end

    WoWToolsSave= WoWToolsSave or {}
    WoWTools_WoWDate= WoWTools_WoWDate or {}
    e.WoWDate= WoWTools_WoWDate or {}


    local day= date('%x')--日期
    if not e.WoWDate[e.Player.guid] then
        e.WoWDate[e.Player.guid]= {--默认数据
            Item={},--{itemID={bag=包, bank=银行}},
            Currency={},--{currencyID = 数量}

            Keystone={week=e.Player.week},--{score=总分数, link=超连接, weekLevel=本周最高, weekNum=本周次数, all=总次数,week=周数},

            Instance={ins={}, week=e.Player.week, day=day},--ins={[名字]={[难度]=已击杀数}}
            Worldboss={boss={}, week=e.Player.week, day=day},--{week=周数, boss=table}
            Rare={day=day, boss={}},--稀有
            Time={},--{totalTime=总游戏时间, levelTime=当前等级时间}总游戏时间
            --Money=钱
            --GuildInfo=公会信息,
            Bank={},--{[itemID]={num=数量,quality=品质}}银行，数据
            region= e.Player.region
        }
    else
        e.WoWDate[e.Player.guid].Bank= e.WoWDate[e.Player.guid].Bank or {}--派系
    end

    e.WoWDate[e.Player.guid].region= e.Player.region
    e.WoWDate[e.Player.guid].faction= e.Player.faction--派系
    e.WoWDate[e.Player.guid].level= e.Player.level
    e.WoWDate[e.Player.guid].battleTag= e.Player.battleTag or e.WoWDate[e.Player.guid].battleTag


    for guid, tab in pairs(e.WoWDate) do--清除不是本周数据
        if tab.Keystone.week ~=e.Player.week then
            e.WoWDate[guid].Keystone={week=e.Player.week}
        end
        if tab.Instance.week~=e.Player.week or (PlayerGetTimerunningSeasonID() and tab.Keystone.day and tab.Keystone.day~=day) then
            e.WoWDate[guid].Instance={ins={}, day=day}
        end
        if (tab.Worldboss.week~=e.Player.week) or (PlayerGetTimerunningSeasonID() and tab.Keystone.day and tab.Keystone.day~=day) then
            e.WoWDate[guid].Worldboss={boss={}, day=day}
        end

        if tab.Rare.day~=day then
            e.WoWDate[guid].Rare={day=day,boss={}}
        end
    end

    Get_Info_Challenge()--挑战

    --C_MajorFactions.RequestCatchUpState()
    C_FriendList.ShowFriends()
    if IsInGuild() then--请求，公会名单
        C_GuildInfo.GuildRoster()
    end
    --C_PerksProgram.RequestPendingChestRewards()

    C_Timer.After(4, function()
        C_CurrencyInfo.RequestCurrencyDataForAccountCharacters()
        RequestRaidInfo()

        C_Calendar.OpenCalendar()
        e.GetNotifyInspect(nil, 'player')--取得,自已, 装等
        e.GetGroupGuidDate()--队伍数据收集

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








EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGOUT", function()
    if e.ClearAllSave then
        WoWToolsSave={}
        if not e.Player.husandro then
            WoWTools_WoWDate={}
        end
    else
        WoWTools_WoWDate= e.WoWDate or {}
    end
end)