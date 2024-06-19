local id, e = ...
local panel=CreateFrame("Frame")



--[[
e.GetItemWoWNum(itemID)--取得WOW物品数量  return all, numPlayer

e.WoWGUID={}--e.WoWGUID[名称-服务器]=guid

e.WoWDate[e.Player.guid].Keystone={
    score= score,
    all= all,
    week= e.Player.week,
    weekNum= weekNum,
    weekLevel= weekLevel,
    weekPvE= e.Get_Week_Rewards_Text(3),--Raid
    weekMythicPlus= e.Get_Week_Rewards_Text(1),--MythicPlus
    weekPvP= e.Get_Week_Rewards_Text(2),--RankedPvP
    link= e.WoWDate[e.Player.guid].Keystone.link,
}
e.WoWDate[e.Player.guid].Item[itemID]={
    bag=bag,
    bank=C_Item.GetItemCount(itemID, true, false, true)-bag,
}
e.WoWDate[e.Player.guid].Money= GetMoney() or 0

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
        }
e.GetGroupGuidDate()--队伍数据收集
]]










local itemLoadTab={--加载法术,或物品数据
        134020,--玩具,大厨的帽子
        6948,--炉石
        140192,--达拉然炉石
        110560,--要塞炉石
        5512,--治疗石
        8529,--诺格弗格药剂
        38682,--附魔纸
    }
local spellLoadTab={
    818,--火    
    179244,--[召唤司机]
    179245,--[召唤司机]
    33388,--初级骑术
    33391,--中级骑术
    34090,--高级骑术
    34091,--专家级骑术
    90265,--大师级骑术
    783,--旅行形态
}

for _, itemID in pairs(itemLoadTab) do
    e.LoadDate({id=itemID, type='item'})
end
for _, spellID in pairs(spellLoadTab) do
    e.LoadDate({id=spellID, type='spell'})
end








--##############
--战网，好友GUID
--##############
e.WoWGUID={}--e.WoWGUID[名称-服务器]=guid
local function setwowguidTab(info)
    if info and info.characterName then
        local name= e.GetUnitName(info.characterName)
        if name then
            if info.isOnline and info.wowProjectID==1 then
                e.WoWGUID[name]={guid=info.playerGuid, faction=info.factionName}
            else
                e.WoWGUID[name]=nil
            end
        end
    end
end
local function Get_WoW_GUID_Info(friendIndex)
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
local function Get_Player_Info(guid)--取得玩家信息
    local unit= guid and UnitTokenFromGUID(guid)
    if not unit then
        return
    end
    local r, g, b, hex= e.GetUnitColor(unit)
    e.UnitItemLevel[guid] = {--玩家装等
        itemLevel= C_PaperDollInfo.GetInspectItemLevel(unit) or (e.UnitItemLevel[guid] and e.UnitItemLevel[guid].itemLevel),
        specID= GetInspectSpecialization(unit),
        faction= UnitFactionGroup(unit),
        col= hex,
        r=r,
        g=g,
        b=b,
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
        all=#C_MythicPlus.GetRunHistory(true, true)--总次数
        local info = C_MythicPlus.GetRunHistory(false, true)
        if info and #info>0 then
            weekNum=#info--本周次数
            local activities=C_WeeklyRewards.GetActivities(1)
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
        weekPvE= e.Get_Week_Rewards_Text(3),--Raid
        weekMythicPlus= e.Get_Week_Rewards_Text(1),--MythicPlus
        weekPvP= e.Get_Week_Rewards_Text(2),--RankedPvP
        link= e.WoWDate[e.Player.guid].Keystone.link,
    }
end




--[[#######
local function Set_Bag(bagID)
    for slotID=1, C_Container.GetContainerNumSlots(bagID) do
        local itemID = C_Container.GetContainerItemID(bagID, slotID)
        if itemID then
            if C_Item.IsItemKeystoneByID(itemID) then--挑战
                local itemLink=C_Container.GetContainerItemLink(bagID, slotID)
                if itemLink then
                    e.WoWDate[e.Player.guid].Keystone.itemLink[itemLink]=true
                end
            else
                local bag=C_Item.GetItemCount(itemID)--物品ID
                e.WoWDate[e.Player.guid].Item[itemID]={
                    bag=bag,
                    bank=C_Item.GetItemCount(itemID,true)-bag,
                }
            end
        end
    end
end]]

--更新物品
--#######
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
        if guid and info then --and guid~=e.Player.guid then
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
local function Update_Currency(arg1)--{currencyID = 数量}
    if arg1 and arg1~=2032 then
        local info = C_CurrencyInfo.GetCurrencyInfo(arg1)
        if info and info.quantity then
            e.WoWDate[e.Player.guid].Currency[arg1]=info.quantity==0 and nil or info.quantity
        end
    else
        for i=1, C_CurrencyInfo.GetCurrencyListSize() do
            local link =C_CurrencyInfo.GetCurrencyListLink(i)
            local currencyID = link and C_CurrencyInfo.GetCurrencyIDFromLink(link)
            local info = C_CurrencyInfo.GetCurrencyListInfo(i)
            if currencyID and info and info.quantity and currencyID~=2032 then
                e.WoWDate[e.Player.guid].Currency[currencyID]= info.quantity<=0 and nil or info.quantity
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
        day=date('%x'),
        boss=tab
    }

    tab={}
    for i=1, GetNumSavedInstances() do--副本
        local name, _, reset, difficulty, _, _, _, _, _, difficultyName, numEncounters, encounterProgress, extendDisabled = GetSavedInstanceInfo(i)
        if reset and reset>0 and numEncounters and encounterProgress and numEncounters>0 and encounterProgress>0 and difficultyName then
            local killed = encounterProgress ..'/'..numEncounters;
            killed = encounterProgress ==numEncounters and '|cnGREEN_FONT_COLOR:'..killed..'|r' or killed
            difficultyName=e.GetDifficultyColor(difficultyName, difficulty)
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
    C_MythicPlus.RequestCurrentAffixes()
    C_MythicPlus.RequestMapInfo()
    C_MythicPlus.RequestRewards()
    for _, mapChallengeModeID in pairs(C_ChallengeMode.GetMapTable() or {}) do
        e.LoadDate({type='mapChallengeModeID',mapChallengeModeID })
    end
--[[
    C_MythicPlus.GetRunHistory(false, true)--本周记录      
    RequestRatedInfo()--从服务器请求有关玩家 PvP 评分的信息。
    RequestRandomBattlegroundInstanceInfo()--请求随机战场实例信息
    RequestBattlefieldScoreData()--请求战地得分数据
]]
end












panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_LOGOUT')
--panel:RegisterEvent('PLAYER_QUITING')
--panel:RegisterEvent('PLAYER_CAMPING')

panel:RegisterEvent('PLAYER_ENTERING_WORLD')

panel:RegisterEvent('GROUP_ROSTER_UPDATE')--队伍数据收集 e.GroupGuid
panel:RegisterEvent('GROUP_LEFT')
panel:RegisterEvent('TIME_PLAYED_MSG')--总游戏时间：%s
panel:RegisterEvent('INSPECT_READY')--取得装等
panel:RegisterEvent('CHALLENGE_MODE_MAPS_UPDATE')--地下城挑战
panel:RegisterEvent('CHALLENGE_MODE_COMPLETED')--地下城挑战
panel:RegisterEvent('WEEKLY_REWARDS_UPDATE')--地下城挑战
panel:RegisterEvent('PLAYER_MONEY')--钱
panel:RegisterEvent('ZONE_CHANGED_NEW_AREA')--位面, 清除
panel:RegisterEvent('BOSS_KILL')--显示世界BOSS击杀数据
panel:RegisterEvent('CURRENCY_DISPLAY_UPDATE')--货币
panel:RegisterEvent('BAG_UPDATE_DELAYED')--物品
panel:RegisterEvent('UPDATE_INSTANCE_INFO')--副本
panel:RegisterEvent('PLAYER_LEVEL_UP')--更新等级
panel:RegisterEvent('NEUTRAL_FACTION_SELECT_RESULT')--更新阵营

panel:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')--取得,自已, 装等
panel:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')--取得,自已, 装等
panel:RegisterEvent('PLAYER_AVG_ITEM_LEVEL_UPDATE')--取得,自已, 装等

panel:RegisterEvent('ENCOUNTER_START')-- 给 e.REload用
panel:RegisterEvent('ENCOUNTER_END')

panel:RegisterEvent('BN_FRIEND_INFO_CHANGED')--战网，好友GUID

panel:SetScript('OnEvent', function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" then
        if arg1==id then
            WoWToolsSave= WoWToolsSave or {}
            e.WoWDate= WoWDate or {}


            local day= date('%x')--日期
            e.WoWDate[e.Player.guid] = e.WoWDate[e.Player.guid] or
                {--默认数据
                    Item={},--{itemID={bag=包, bank=银行}},
                    Currency={},--{currencyID = 数量}

                    Keystone={week=e.Player.week},--{score=总分数, link=超连接, weekLevel=本周最高, weekNum=本周次数, all=总次数,week=周数},
                    --KeystoneLink=挑战，Link

                    Instance={ins={}, week=e.Player.week, day=day},--ins={[名字]={[难度]=已击杀数}}
                    Worldboss={boss={}, week=e.Player.week, day=day},--{week=周数, boss=table}
                    Rare={day=day, boss={}},--稀有
                    Time={},--{totalTime=总游戏时间, levelTime=当前等级时间}总游戏时间
                    --Money=钱
                    --GuildInfo=公会信息,
                    Bank={},--{[itemID]={num=数量,quality=品质}}银行，数据                    
                }
            e.WoWDate[e.Player.guid].faction= e.Player.faction--派系
            e.WoWDate[e.Player.guid].Bank= e.WoWDate[e.Player.guid].Bank or {}--派系
            e.WoWDate[e.Player.guid].Keystone.itemLink=nil--清除，不用的数据


            for guid, tab in pairs(e.WoWDate) do--清除不是本周数据
                if tab.Keystone.week ~=e.Player.week then
                    e.WoWDate[guid].Keystone={week=e.Player.week}
                end
                if tab.Instance.week~=e.Player.week or (e.Is_Timerunning and tab.Keystone.day and tab.Keystone.day~=day) then
                    e.WoWDate[guid].Instance={ins={}, day=day}
                end
                if (tab.Worldboss.week~=e.Player.week) or (e.Is_Timerunning and tab.Keystone.day and tab.Keystone.day~=day) then
                    e.WoWDate[guid].Worldboss={boss={}, day=day}
                end

                if tab.Rare.day~=day then
                    e.WoWDate[guid].Rare={day=day,boss={}}
                end
            end

            if e.Player.levelMax then
                Get_Info_Challenge()--挑战
            end

            RequestRaidInfo()
            --C_MajorFactions.RequestCatchUpState()
            C_FriendList.ShowFriends()
            if IsInGuild() then--请求，公会名单
                C_GuildInfo.GuildRoster()
            end
            --C_PerksProgram.RequestPendingChestRewards()

            C_Timer.After(2, function()
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
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event=='GROUP_ROSTER_UPDATE' or event=='GROUP_LEFT' then--队伍数据
        e.GetGroupGuidDate()

    elseif event=='TIME_PLAYED_MSG' then--总游戏时间：%s
        if arg1 and arg2 then
            e.WoWDate[e.Player.guid].Time={
                totalTime= arg1,
                levelTime= arg2,
            }
        end

    elseif event=='INSPECT_READY' then--装等
            Get_Player_Info(arg1)

    elseif event=='CHALLENGE_MODE_MAPS_UPDATE' or event=='WEEKLY_REWARDS_UPDATE' then--地下城挑战
        C_MythicPlus.RequestRewards()
        C_Timer.After(4, Update_Challenge_Mode)

    elseif event=='CHALLENGE_MODE_COMPLETED' then
        Get_Info_Challenge()--挑战

    elseif event=='ZONE_CHANGED_NEW_AREA' then--位面, 清除
        e.Player.Layer=nil

    elseif event=='PLAYER_ENTERING_WORLD' then--记录稀有怪
        e.Player.Layer=nil
        if IsInInstance() then--稀有怪
            self:UnregisterEvent('UNIT_FLAGS')
            self:UnregisterEvent('LOOT_OPENED')
        else
            self:RegisterEvent('UNIT_FLAGS')
            self:RegisterEvent('LOOT_OPENED')
        end

    elseif event=='BOSS_KILL' then
        RequestRaidInfo()

    elseif event=='CURRENCY_DISPLAY_UPDATE' then--货币
        Update_Currency(arg1)

    elseif event=='BAG_UPDATE_DELAYED' then
            Update_Bag_Items()

    elseif event=='UPDATE_INSTANCE_INFO' then--副本
        Update_Instance()

    elseif event=='UNIT_FLAGS' then--稀有怪
        Set_Rare_Elite_Killed(arg1)

    elseif event=='LOOT_OPENED' then
        Set_Rare_Elite_Killed('loot')

    elseif event=='PLAYER_MONEY' then--钱
        Set_Money()--钱

    elseif event=='PLAYER_LEVEL_UP' then--玩家是否最高等级
        local level= arg1 or UnitLevel('player')
        e.Player.levelMax= level==MAX_PLAYER_LEVEL--玩家是否最高等级
        e.Player.level= level

    elseif event=='NEUTRAL_FACTION_SELECT_RESULT' then--玩家, 派系
        if arg1 then
            e.Player.faction= UnitFactionGroup('player')--玩家, 派系  "Alliance", "Horde", "Neutral"
        end

    elseif event=='PLAYER_EQUIPMENT_CHANGED' or event=='PLAYER_SPECIALIZATION_CHANGED' or event=='PLAYER_AVG_ITEM_LEVEL_UPDATE' then--更新自已
        e.GetNotifyInspect(nil, arg1 or 'player')--取得装等

    elseif event=='ENCOUNTER_START' then-- 给 e.Reload用
        e.IsEncouter_Start= true
    elseif event=='ENCOUNTER_START' then
        e.IsEncouter_Start= nil

    elseif event=='BN_FRIEND_INFO_CHANGED' then
        if arg1 then
            Get_WoW_GUID_Info(arg1)--战网，好友GUID
        end














    --[[elseif event=='PLAYER_CAMPING' or event=='PLAYER_QUITING' then
        --更新物品
        --e.WoWDate[e.Player.guid].Keystone.itemLink={}
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
                            bank=C_Item.GetItemCount(itemID,true)-bag,
                        }
                    end
                end
            end
        end

        --钱
        e.WoWDate[e.Player.guid].Money= GetMoney()]]

    elseif event == "PLAYER_LOGOUT" then
        if e.ClearAllSave then
            WoWToolsSave=nil
            if not e.Player.husandro then
                WoWDate=nil
            end
        else



            WoWDate= e.WoWDate or {}
        end
    end
end)