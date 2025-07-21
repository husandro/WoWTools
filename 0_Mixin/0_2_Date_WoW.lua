WoWTools_DataMixin.WoWGUID={}--战网，好友GUID--WoWTools_DataMixin.WoWGUID[名称-服务器]=guid
WoWTools_DataMixin.UnitItemLevel={}--玩家装等
WoWTools_DataMixin.GroupGuid={}--队伍数据收集



--[[
WoWTools_BagMixin:GetItem_WoW_Num(itemID)--取得WOW物品数量  return all, numPlayer

WoWTools_DataMixin.WoWGUID={}--WoWTools_DataMixin.WoWGUID[名称-服务器]=guid

WoWTools_WoWDate[guid]= {--默认数据
    Item={},--{itemID={bag=包, bank=银行}},
    Currency={},--{[currencyID] = 数量}

    Keystone={week=WoWTools_DataMixin.Player.Week},--{score=总分数, link=超连接, weekLevel=本周最高, weekNum=本周次数, all=总次数,week=周数},

    Instance={ins={}, week=WoWTools_DataMixin.Player.Week, day=day},--ins={[名字]={[难度]=已击杀数}}
    Worldboss={boss={}, week=WoWTools_DataMixin.Player.Week, day=day},--{week=周数, boss={[name]=worldBossID}}}
    Rare={day=day, boss={[name]=guid}},--稀有 
    Time={},--{totalTime=总游戏时间, levelTime=当前等级时间, upData=更新时间}总游戏时间
    Guild={
        guid= club.clubFinderGUID,
        link= WoWTools_GuildMixin:GetClubLink(clubID, club.clubFinderGUID),
        clubID= clubID,
        data={guildName, guildRankName, guildRankIndex, realm or WoWTools_DataMixin.Player.Realm},
        text= WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Guild.text
    },
    --Money=钱
    Bank={},--{[itemID]={num=数量,quality=品质}}银行，数据
    region= WoWTools_DataMixin.Player.Region
    --specID 专精
    --itemLevel 装等
    --faction
    --level
    --battleTag
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














--战网，好友GUID
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

EventRegistry:RegisterFrameEventAndCallback("BN_FRIEND_INFO_CHANGED", function(_, friendIndex)
    Get_WoW_GUID_Info(_, friendIndex)
end)














--########
--玩家装等
--########
WoWTools_DataMixin.UnitItemLevel={}
EventRegistry:RegisterFrameEventAndCallback("INSPECT_READY", function(_, guid)--取得玩家信息
    local unit= guid and UnitTokenFromGUID(guid)
    if not unit then
        return
    end

    local r, g, b, hex= select(2, WoWTools_UnitMixin:GetColor(unit, nil))
    local itemLevel= C_PaperDollInfo.GetInspectItemLevel(unit) or (WoWTools_DataMixin.UnitItemLevel[guid] and WoWTools_DataMixin.UnitItemLevel[guid].itemLevel)
    local specID= GetInspectSpecialization(unit) or (WoWTools_DataMixin.UnitItemLevel[guid] and WoWTools_DataMixin.UnitItemLevel[guid].specID)
    WoWTools_DataMixin.UnitItemLevel[guid] = {--玩家装等
        itemLevel= itemLevel,
        specID=specID,
        faction= UnitFactionGroup(unit),
        col= hex,
        r=r,
        g=g,
        b=b,
        level=UnitLevel(unit),
    }
    if UnitInParty(unit) and not IsInRaid() then
        for memberFrame in PartyFrame.PartyMemberFramePool:EnumerateActive() do--先使用一次，用以Shift+点击，设置焦点功能, Invite.lua
            if memberFrame.classFrame and UnitIsUnit(memberFrame.unit, unit) then
                memberFrame.classFrame:set_settings(guid)
                break
            end
        end
    end
    if UnitIsUnit(unit, 'target') and TargetFrame.classFrame then
        TargetFrame.classFrame:set_settings(guid)
    end

--设置 GameTooltip
    if  GameTooltip.textLeft and GameTooltip:IsShown() then
        local name2, unit2, guid2= TooltipUtil.GetDisplayedUnit(GameTooltip)
        if guid2==guid then
            WoWTools_TooltipMixin:Set_Unit_Player(GameTooltip, name2, unit2, guid2)
        end
    end

--保存，自已，装等
    if guid==WoWTools_DataMixin.Player.GUID then
        WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].itemLevel= itemLevel
        WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].specID= specID
    end
    --if UnitIsUnit(unit, 'mouseover') and GameTooltip.textLeft and GameTooltip:IsShown() then
end)















--队伍数据收集
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


EventRegistry:RegisterFrameEventAndCallback("GROUP_ROSTER_UPDATE", function()
    GetGroupGuidDate()
end)
EventRegistry:RegisterFrameEventAndCallback("GROUP_LEFT", function()
    GetGroupGuidDate()
end)















--地下城挑战
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

        weekPvE= WoWTools_ChallengeMixin:GetRewardText(Enum.WeeklyRewardChestThresholdType.Raid),--Raid
        weekMythicPlus= WoWTools_ChallengeMixin:GetRewardText(Enum.WeeklyRewardChestThresholdType.Activities),--MythicPlus
        weekPvP= WoWTools_ChallengeMixin:GetRewardText(Enum.WeeklyRewardChestThresholdType.RankedPvP),--RankedPvP
        weekWorld=WoWTools_ChallengeMixin:GetRewardText(Enum.WeeklyRewardChestThresholdType.World),--world
        link= WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Keystone.link,
        --itemLevel= C_MythicPlus.GetOwnedKeystoneLevel(),
    }
end

--地下城挑战
EventRegistry:RegisterFrameEventAndCallback("CHALLENGE_MODE_MAPS_UPDATE", function()
    C_MythicPlus.RequestRewards()
    C_Timer.After(4, Update_Challenge_Mode)
end)
EventRegistry:RegisterFrameEventAndCallback("WEEKLY_REWARDS_UPDATE", function()
    C_MythicPlus.RequestRewards()
    C_Timer.After(4, Update_Challenge_Mode)
end)







--挑战
local function Get_Info_Challenge()--挑战
    C_MythicPlus.RequestCurrentAffixes()
    C_MythicPlus.RequestMapInfo()
    C_MythicPlus.RequestRewards()
    for _, mapChallengeModeID in pairs(C_ChallengeMode.GetMapTable() or {}) do
        WoWTools_Mixin:Load({type='mapChallengeModeID',mapChallengeModeID })
    end
end

EventRegistry:RegisterFrameEventAndCallback("CHALLENGE_MODE_COMPLETED", function()
    Get_Info_Challenge()
end)

--[[
    C_MythicPlus.GetRunHistory(false, true)--本周记录      
    RequestRatedInfo()--从服务器请求有关玩家 PvP 评分的信息。
    RequestRandomBattlegroundInstanceInfo()--请求随机战场实例信息
    RequestBattlefieldScoreData()--请求战地得分数据
]]













--更新物品
EventRegistry:RegisterFrameEventAndCallback("BAG_UPDATE_DELAYED", function()
    local guid= WoWTools_DataMixin.Player.GUID
    WoWTools_WoWDate[guid].Keystone.link=nil
    WoWTools_WoWDate[guid].Item={}--{itemID={bag=包, bank=银行}}
    for bagID= Enum.BagIndex.Backpack,  NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES do
        for slotID=1, C_Container.GetContainerNumSlots(bagID) do
            local itemID = C_Container.GetContainerItemID(bagID, slotID)
            if itemID then

                if C_Item.IsItemKeystoneByID(itemID) then--挑战
                    WoWTools_WoWDate[guid].Keystone.link= C_Container.GetContainerItemLink(bagID, slotID)
                else
                    local bag=C_Item.GetItemCount(itemID)--物品ID
                    WoWTools_WoWDate[guid].Item[itemID]={
                        bag=bag,
                        bank=C_Item.GetItemCount(itemID, true, false, true)-bag,
                    }
                end
            end
        end
    end
end)

































--更新货币 {currencyID = 数量}
EventRegistry:RegisterFrameEventAndCallback("CURRENCY_DISPLAY_UPDATE", function(_, arg1)
    if arg1 and arg1~=2032 then
        if not C_CurrencyInfo.IsAccountWideCurrency(arg1) then
            local info = C_CurrencyInfo.GetCurrencyInfo(arg1)
            if info and info.quantity then
                WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Currency[arg1]= info.quantity~=0 and info.quantity or nil
            end
        end
    else
        for i=1, C_CurrencyInfo.GetCurrencyListSize() do
            local link =C_CurrencyInfo.GetCurrencyListLink(i)
            local currencyID = link and C_CurrencyInfo.GetCurrencyIDFromLink(link)

            local info = C_CurrencyInfo.GetCurrencyListInfo(i)
            if currencyID and info and info.quantity and currencyID~=2032 and not C_CurrencyInfo.IsAccountWideCurrency(currencyID) then
                WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Currency[currencyID]= info.quantity~=0 and info.quantity or nil
            end
        end
    end
end)




















--副本, 世界BOSS
EventRegistry:RegisterFrameEventAndCallback("UPDATE_INSTANCE_INFO", function()--encounterID, encounterName)
    local tab={}--已杀世界BOSS
    for i=1, GetNumSavedWorldBosses() do--{week=周数, boss={[name]=worldBossID}}}
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
end)





















--稀有怪数 BOSS_KILL
--[[EventRegistry:RegisterFrameEventAndCallback("UNIT_FLAGS", function(_, unit)
    if IsInInstance() or not unit or not UnitIsDead(unit) or UnitIsPlayer(unit) then
        return
    end
    local classification = UnitClassification(unit)
    if classification == "rare" or classification == "rareelite" then
        local threat = UnitThreatSituation('player',unit)
        if threat and threat>0 then
            local name=UnitName(unit)
            if name then
                WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Rare.boss[name]= UnitGUID('target')--以前用true,注意旧数据
                print(name, UnitGUID('target'))
                --RequestRaidInfo()
            end
        end
    end
end)]]


EventRegistry:RegisterFrameEventAndCallback("LOOT_OPENED", function()
    if IsInInstance() or not UnitExists('target') then
        return
    end
    local classification = UnitClassification('target')
    if classification == "rare" or classification == "rareelite" then
        local name=UnitName('target')
        if name then
            WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Rare.boss[name]= UnitGUID('target')
            print(name, UnitGUID('target'))
            --RequestRaidInfo()
        end
    end
end)
















--##
--钱
--##
local function Set_Money()--钱
    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Money= GetMoney() or 0
end

EventRegistry:RegisterFrameEventAndCallback("PLAYER_MONEY", Set_Money)








































--总游戏时间：%s
EventRegistry:RegisterFrameEventAndCallback("TIME_PLAYED_MSG", function(_, arg1, arg2)
    if arg1 and arg2 then
        WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Time={
            totalTime= arg1,
            levelTime= arg2,
            upData= date('%Y-%m-%d %H:%M:%S'),
        }
    end
end)






--位面, 清除
EventRegistry:RegisterFrameEventAndCallback("ZONE_CHANGED_NEW_AREA", function()
    WoWTools_DataMixin.Player.Layer=nil
end)
EventRegistry:RegisterFrameEventAndCallback('PLAYER_ENTERING_WORLD', function()
    WoWTools_DataMixin.Player.Layer=nil
end)

EventRegistry:RegisterFrameEventAndCallback("BOSS_KILL", function()
    RequestRaidInfo()
end)






--玩家是否最高等级
EventRegistry:RegisterFrameEventAndCallback("PLAYER_LEVEL_UP", function(_, level)
    level= level or UnitLevel('player')
    WoWTools_DataMixin.Player.IsMaxLevel= level==GetMaxLevelForLatestExpansion()--玩家是否最高等级
    WoWTools_DataMixin.Player.Level= level
    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].level= level
end)

--玩家, 派系
EventRegistry:RegisterFrameEventAndCallback("NEUTRAL_FACTION_SELECT_RESULT", function(_, success)
    if success then
        WoWTools_DataMixin.Player.Faction= UnitFactionGroup('player')--玩家, 派系  "Alliance", "Horde", "Neutral"
    end
end)

--取得装等, 更新自已
EventRegistry:RegisterFrameEventAndCallback("PLAYER_EQUIPMENT_CHANGED", function()
    WoWTools_UnitMixin:GetNotifyInspect(nil, 'player')--取得装等
end)
EventRegistry:RegisterFrameEventAndCallback("PLAYER_SPECIALIZATION_CHANGED", function()
    WoWTools_UnitMixin:GetNotifyInspect(nil, 'player')--取得装等
end)
EventRegistry:RegisterFrameEventAndCallback("PLAYER_AVG_ITEM_LEVEL_UPDATE", function()
    WoWTools_UnitMixin:GetNotifyInspect(nil, 'player')--取得装等
end)

--[[给 e.Reload用
EventRegistry:RegisterFrameEventAndCallback("ENCOUNTER_START", function(_, encounterID)
    e.IsEncouter_Start= encounterID
end)
EventRegistry:RegisterFrameEventAndCallback("ENCOUNTER_END", function(_, arg1)
    e.IsEncouter_Start= nil
end)]]


EventRegistry:RegisterFrameEventAndCallback("BARBER_SHOP_RESULT", function(_, success)
    if success then
        WoWTools_DataMixin.Player.Sex= UnitSex("player")
        WoWTools_DataMixin.Icon.Player= WoWTools_UnitMixin:GetRaceIcon('player') or ''
    end
end)

















EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
    if arg1~='WoWTools' then
        return
    end

    WoWToolsSave= WoWToolsSave or {}

    WoWTools_WoWDate= WoWTools_WoWDate or {}

    WoWToolsPlayerDate= WoWToolsPlayerDate or {}

    WoWTools_DataMixin.Icon.Player= WoWTools_UnitMixin:GetRaceIcon('player')

    local day= date('%x')--日期
    local guid= WoWTools_DataMixin.Player.GUID
    if not WoWTools_WoWDate[guid] then
        WoWTools_WoWDate[guid]= {--默认数据
            Item={},--{itemID={bag=包, bank=银行}},
            Currency={},--{[currencyID]=数量}

            Keystone={week=WoWTools_DataMixin.Player.Week},--{score=总分数, link=超连接, weekLevel=本周最高, weekNum=本周次数, all=总次数,week=周数},

            Instance={ins={}, week=WoWTools_DataMixin.Player.Week, day=day},--ins={[名字]={[难度]=已击杀数}}
            Worldboss={boss={}, week=WoWTools_DataMixin.Player.Week, day=day},--{week=周数, boss={[name]=worldBossID}}}
            Rare={day=day, boss={}},--稀有 [name]=guid
            Time={},--{totalTime=总游戏时间, levelTime=当前等级时间, upData=更新时间}总游戏时间
            Guild={
                --text= text, GuildInfo() 公会信息,
                --guid= guid, 公会 clubFinderGUID 
                data={},-- {guildName, guildRankName, guildRankIndex, realm} = GetGuildInfo('player')
            },
            --Money=钱
            Bank={},--{[itemID]={num=数量,quality=品质}}银行，数据
            region= WoWTools_DataMixin.Player.Region
            --specID 专精
            --itemLevel 装等
            --faction
            --level
            --battleTag
        }
    end

    WoWTools_WoWDate[guid].Bank= WoWTools_WoWDate[guid].Bank or {}--银行

    WoWTools_WoWDate[guid].Guild= WoWTools_WoWDate[guid].Guild or {data={}}--公会信息

    WoWTools_WoWDate[guid].region= WoWTools_DataMixin.Player.Region
    WoWTools_WoWDate[guid].faction= WoWTools_DataMixin.Player.Faction--派系
    WoWTools_WoWDate[guid].level= WoWTools_DataMixin.Player.Level
    WoWTools_WoWDate[guid].battleTag= WoWTools_DataMixin.Player.BattleTag or WoWTools_WoWDate[guid].battleTag


    for guid2, tab in pairs(WoWTools_WoWDate) do--清除不是本周数据
        if tab.Keystone.week ~=WoWTools_DataMixin.Player.Week then
            WoWTools_WoWDate[guid2].Keystone={week=WoWTools_DataMixin.Player.Week}
        end
        if tab.Instance.week~=WoWTools_DataMixin.Player.Week or (PlayerGetTimerunningSeasonID() and tab.Keystone.day and tab.Keystone.day~=day) then
            WoWTools_WoWDate[guid2].Instance={ins={}, day=day}
        end
        if (tab.Worldboss.week~=WoWTools_DataMixin.Player.Week) or (PlayerGetTimerunningSeasonID() and tab.Keystone.day and tab.Keystone.day~=day) then
            WoWTools_WoWDate[guid2].Worldboss={boss={}, day=day}
        end

        if tab.Rare.day~=day then
            WoWTools_WoWDate[guid2].Rare={day=day,boss={}}
        end
    end



    EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
end)













--保存公会数据，到WOW
local function Save_WoWGuild()
    if IsInGuild() then
        local clubID= C_Club.GetGuildClubId()

        if clubID then
            WoWTools_GuildMixin:Load_Club(clubID)
        end

        local club= clubID and C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID) or {}
        local guildName, guildRankName, guildRankIndex, realm= GetGuildInfo('player')

        realm= (realm=='' or not realm) and WoWTools_DataMixin.Player.Realm or realm
        local old= WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Guild
        if guildName and guildName~=old.data[1] then
            old={}
        end

        WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Guild= {
            guid= club.clubFinderGUID or old.guid,
            link= WoWTools_GuildMixin:GetClubLink(clubID, club.clubFinderGUID) or old.link,
            --clubID= clubID or old.clubID,
            data={guildName, guildRankName, guildRankIndex, realm},
            text= old.text,--公会创立于 ， 名成员， 个帐号
            --tabardData=C_GuildInfo.GetGuildTabardInfo('player'),-- or old.tabardData,
            --emblemFilename = select(10, GetGuildLogoInfo()) or old.emblemFilename
        }
    else
        WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Guild= {data={}}
    end
end

EventRegistry:RegisterFrameEventAndCallback('PLAYER_GUILD_UPDATE', function()
    C_Timer.After(2, Save_WoWGuild)
end)
EventRegistry:RegisterFrameEventAndCallback('GUILD_RENAME_REQUIRED', function()
    C_Timer.After(2, Save_WoWGuild)
end)
EventRegistry:RegisterFrameEventAndCallback('LOADING_SCREEN_DISABLED', function(owner)
    C_Timer.After(2, Save_WoWGuild)
    EventRegistry:UnregisterCallback('LOADING_SCREEN_DISABLED', owner)
end)






EventRegistry:RegisterFrameEventAndCallback('PLAYER_ENTERING_WORLD', function(owner)

    if  WoWTools_DataMixin.Player.IsMaxLevel and not PlayerGetTimerunningSeasonID() then
        Get_Info_Challenge()--挑战
    end

    --C_MajorFactions.RequestCatchUpState()
    C_FriendList.ShowFriends()

    --C_PerksProgram.RequestPendingChestRewards()
    if not C_CurrencyInfo.IsAccountCharacterCurrencyDataReady() then
        C_CurrencyInfo.RequestCurrencyDataForAccountCharacters()
    end

    RequestRaidInfo()

    --C_Calendar.OpenCalendar()
    WoWTools_UnitMixin:GetNotifyInspect(nil, 'player')--取得,自已, 装等
    GetGroupGuidDate()--队伍数据收集

    --Update_Currency()--{currencyID = 数量}
    --Update_Bag_Items()
    Set_Money()--钱
    Update_Challenge_Mode()

    --################
    --开启, 新手編輯模式
    --################ LFDFrame.lua
    if C_PlayerInfo.IsPlayerNPERestricted() then
        EditModeManagerFrame.CanEnterEditMode = function(frame)--EditModeManager.lua
            return TableIsEmpty(frame.FramesBlockingEditMode)
        end
        if Minimap then
            Minimap:SetShown(true)
            MinimapCluster:SetShown(true)
        end
    end

    Get_WoW_GUID_Info()--战网，好友GUID

    EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
end)

