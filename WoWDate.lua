local id, e = ...
local panel=CreateFrame("Frame")
--local addName= 'WoWDate'
WoWDate={}
e.GroupFrame={}--UnitFrame.lua 设置装等， 专精

--##############
--战网，好友GUID
--##############
e.WoWGUID={}--e.WoWGUID[名称-服务器]=guid
local function setwowguidTab(info)
    if info and info.characterName then
        local name= e.GetUnitName(info.characterName)
        if info.isOnline and info.wowProjectID==1 then
            e.WoWGUID[name]={guid=info.playerGuid, faction=info.factionName}
        else
            e.WoWGUID[name]=nil
        end
    end
end
local function get_WoW_GUID_Info(friendIndex)
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
local function get_Player_Info(guid)--取得玩家信息
    local unit
    if e.GroupGuid[guid] then
        unit= e.GroupGuid[guid].unit
    elseif guid== e.Player.guid then
        unit= 'player'
    elseif UnitGUID("mouseover")== guid then
        unit= 'mouseover'
    elseif guid== UnitGUID('target') then
        unit='target'
    end

    local itemLevel= unit and C_PaperDollInfo.GetInspectItemLevel(unit)
    if unit then

        local r, g, b, hex
        local class= UnitClassBase(unit)
        if class then
            r, g, b, hex= GetClassColor(class)
            if hex then
                hex= '|c'..hex
            end
        end

        itemLevel= itemLevel or e.UnitItemLevel[guid] and e.UnitItemLevel[guid].itemLevel
        local specID= GetInspectSpecialization(unit)
        e.UnitItemLevel[guid] = {--玩家装等
            itemLevel= itemLevel,
            specID= specID,
            faction= UnitFactionGroup(unit),
            col= hex,
            r=r,
            g=g,
            b=b,
        }

        --UnitFrame.lua set_UnitFrame_Update()--职业, 图标， 颜色
        local frame= e.GroupFrame[unit]
        if frame and frame.unit~='vehicle' then
            if frame.itemLevel and itemLevel then--装等
                frame.itemLevel:SetText(hex and (hex..itemLevel) or itemLevel)
            end

            if frame.classTexture and specID then--专精
                local texture= select(4, GetSpecializationInfoByID(specID))
                if texture then
                    SetPortraitToTexture(frame.classTexture, texture)
                end
            end
            if frame.classPortrait and r and g and b then--外框
                frame.classPortrait:SetVertexColor(r, g, b, 1)
            end
        end
    end
end

--#######
--取得装等
--#######
e.GetNotifyInspect= function(tab)
    local num, index= #tab, 1
    if num>0 then
        if panel.NotifyInspectTicker then panel.NotifyInspectTicker:Cancel() end
        panel.NotifyInspectTicker=C_Timer.NewTicker(4, function()
            local unit=tab[index]
            if UnitExists(unit) and CheckInteractDistance(unit, 1) and CanInspect(unit) then
                NotifyInspect(tab[index])
            end
            index= index+ 1
        end, num-1)
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
        local tab
        for index= 1, 4 do
            local unit= 'party'..index
            if UnitExists(unit) then
                local guid=UnitGUID(unit)
                if guid then
                    tab={
                        unit= unit,
                        combatRole= UnitGroupRolesAssigned(unit),
                        guid=guid,
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
    end
    e.GetNotifyInspect(UnitTab)--取得装等
end


--#########
--地下城挑战
--#########
local function updateChallengeMode()--{score=总分数,itemLink={超连接}, weekLevel=本周最高, weekNum=本周次数, all=总次数,week=周数}
    local tab={
        itemLink=WoWDate[e.Player.guid].Keystone.itemLink
    }
    local score=C_ChallengeMode.GetOverallDungeonScore();
    if score and score>0 then
        tab.score=score--总分数
        tab.all=#C_MythicPlus.GetRunHistory(true, true)--总次数
        tab.week=e.Player.week
        local info = C_MythicPlus.GetRunHistory(false, true)
        if info and #info>0 then
            tab.weekNum=#info--本周次数
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
                    tab.weekLevel=lv--本周最高
                end
            end
        end
    end
    WoWDate[e.Player.guid].Keystone=tab
end

--#######
--更新物品
--#######
local function updateItems()
    WoWDate[e.Player.guid].Keystone.itemLink={}
    WoWDate[e.Player.guid].Item={}--{itemID={bag=包, bank=银行}}
    for bagID= Enum.BagIndex.Backpack, Constants.InventoryConstants.NumBagSlots+1 do
        for slotID=1, C_Container.GetContainerNumSlots(bagID) do
            local itemID = C_Container.GetContainerItemID(bagID, slotID)
            if itemID then
                if C_Item.IsItemKeystoneByID(itemID) then--挑战
                    local itemLink=C_Container.GetContainerItemLink(bagID, slotID)
                    if itemLink then
                        WoWDate[e.Player.guid].Keystone.itemLink[itemLink]=true
                    end
                else
                    local bag=GetItemCount(itemID)--物品ID
                    WoWDate[e.Player.guid].Item[itemID]={
                        bag=bag,
                        bank=GetItemCount(itemID,true)-bag,
                    }
                end
            end
        end
    end
end

e.GetItemWoWNum= function(itemID)--e.GetItemWoWNum()--取得WOW物品数量
    local all,numPlayer=0,0
    for guid, info in pairs(WoWDate) do
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
local function updateCurrency(arg1)--{currencyID = 数量}
    if arg1 and arg1~=2032 then
        local info = C_CurrencyInfo.GetCurrencyInfo(arg1)
        if info and info.quantity then
            WoWDate[e.Player.guid].Currency[arg1]=info.quantity==0 and nil or info.quantity
        end
    else
        for i=1, C_CurrencyInfo.GetCurrencyListSize() do
            local link =C_CurrencyInfo.GetCurrencyListLink(i)
            local currencyID = link and C_CurrencyInfo.GetCurrencyIDFromLink(link)
            local info = C_CurrencyInfo.GetCurrencyListInfo(i)
            if currencyID and info and info.quantity and currencyID~=2032 then
                WoWDate[e.Player.guid].Currency[currencyID]= info.quantity<=0 and nil or info.quantity
            end
        end
    end
end

--#############
--副本, 世界BOSS
--#############
local function undateInstance(encounterID, encounterName)
    local tab={}--已杀世界BOSS
    for i=1, GetNumSavedWorldBosses() do--{week=周数, boss={name=true}}}
        local bossName,_,reset=GetSavedWorldBossInfo(i)
        if bossName and (not reset or reset>0) then
            tab[bossName] = true
            if WoWDate[e.Player.guid].Rare.boss[bossName] then--清除稀有怪
                WoWDate[e.Player.guid].Rare.boss[bossName]=nil
            end
        end
    end

    WoWDate[e.Player.guid].Worldboss={
        week=e.Player.week,
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
    WoWDate[e.Player.guid].Instance = {
        week=e.Player.week,
        ins=tab
    }
end

--#########
--稀有怪数据
--#########
local function setRareEliteKilled(unit)--稀有怪数据
    if unit=='loot' then
        unit='target'
        local classification = UnitExists(unit) and UnitClassification(unit)
        if classification == "rare" or classification == "rareelite" then
            local name=UnitName(unit)
            if name then
                WoWDate[e.Player.guid].Rare.boss[name]=true
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
                    WoWDate[e.Player.guid].Rare.boss[name]=true
                    RequestRaidInfo()
                end
            end
        end
    end
end

--##
--钱
--##
local function set_Money()--钱
    local money=GetMoney()
    WoWDate[e.Player.guid].Money= money==0 and nil or money
end


local function get_Info_Challenge()--挑战
    C_MythicPlus.RequestCurrentAffixes()
    C_MythicPlus.RequestMapInfo()
    C_MythicPlus.RequestRewards()
    for _, mapID in pairs(C_ChallengeMode.GetMapTable() or {}) do
        C_ChallengeMode.RequestLeaders(mapID)
    end
    --C_MythicPlus.GetRunHistory(false, true)--本周记录
end

panel:RegisterEvent("ADDON_LOADED")
--panel:RegisterEvent('PLAYER_LOGOUT')
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
            local day= date('%x')--日期
            WoWDate=WoWDate or {}
            WoWDate[e.Player.guid] = WoWDate[e.Player.guid] or
                {--默认数据
                    Item={},--{itemID={bag=包, bank=银行}},
                    Currency={},--{currencyID = 数量}

                    Keystone={itemLink={}, week=e.Player.week},--{score=总分数,itemLink={超连接}, weekLevel=本周最高, weekNum=本周次数, all=总次数,week=周数},
                    Instance={ins={}, week=e.Player.week},--ins={[名字]={[难度]=已击杀数}}
                    Worldboss={boss={}, week=e.Player.week},--{week=周数, boss=table}
                    Rare={day=day, boss={}},--稀有
                    Time={},--{totalTime=总游戏时间, levelTime=当前等级时间}总游戏时间
                    --Money=钱
                    --GuildInfo=公会信息,
                }
            WoWDate[e.Player.guid].faction= e.Player.faction--派系

            for guid, tab in pairs(WoWDate) do--清除不是本周数据
                if tab.Keystone.week ~=e.Player.week then
                    WoWDate[guid].Keystone={itemLink={}}
                end
                if tab.Instance.week~=e.Player.week then
                    WoWDate[guid].Instance={ins={}}
                end
                if tab.Worldboss.week~=e.Player.week then
                    WoWDate[guid].Worldboss={boss={}}
                end

                if tab.Rare.day~=day then
                    WoWDate[guid].Rare={day=day,boss={}}
                end
            end

            if e.Player.levelMax then
                get_Info_Challenge()--挑战
            end

            RequestRaidInfo()
            C_MajorFactions.RequestCatchUpState()
            C_FriendList.ShowFriends()
            if IsInGuild() then--请求，公会名单
                C_GuildInfo.GuildRoster()
            end
            --[[
                RequestRatedInfo()--从服务器请求有关玩家 PvP 评分的信息。
                RequestRandomBattlegroundInstanceInfo()--请求随机战场实例信息
                RequestBattlefieldScoreData()--请求战地得分数据
            ]]
            C_Timer.After(2, function()
                NotifyInspect('player')--取得,自已, 装等
                e.GetGroupGuidDate()--队伍数据收集    
                set_Money()--钱
                updateCurrency(nil)--{currencyID = 数量}

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

                get_WoW_GUID_Info()--战网，好友GUID
            end)
            panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event=='GROUP_ROSTER_UPDATE' or event=='GROUP_LEFT' then--队伍数据
        e.GetGroupGuidDate()

    elseif event=='TIME_PLAYED_MSG' then--总游戏时间：%s
        if arg1 and arg2 then
            WoWDate[e.Player.guid].Time={
                totalTime= arg1,
                levelTime= arg2,
            }
        end

    elseif event=='INSPECT_READY' then--装等
            get_Player_Info(arg1)

    elseif event=='CHALLENGE_MODE_MAPS_UPDATE' or event=='WEEKLY_REWARDS_UPDATE' then--地下城挑战
        C_MythicPlus.RequestRewards()
        C_Timer.After(2, updateChallengeMode)

    elseif event=='CHALLENGE_MODE_COMPLETED' then
        get_Info_Challenge()--挑战

    elseif event=='ZONE_CHANGED_NEW_AREA' then--位面, 清除
        e.Player.Layer=nil

    elseif event=='PLAYER_ENTERING_WORLD' then--记录稀有怪
        e.Player.Layer=nil
        if IsInInstance() then--稀有怪
            panel:UnregisterEvent('UNIT_FLAGS')
            panel:UnregisterEvent('LOOT_OPENED')
        else
            panel:RegisterEvent('UNIT_FLAGS')
            panel:RegisterEvent('LOOT_OPENED')
        end

    elseif event=='BOSS_KILL' then
        RequestRaidInfo()

    elseif event=='CURRENCY_DISPLAY_UPDATE' then--货币
        updateCurrency(arg1)

    elseif event=='BAG_UPDATE_DELAYED' then
        updateItems()

    elseif event=='UPDATE_INSTANCE_INFO' then--副本
        undateInstance()

    elseif event=='UNIT_FLAGS' then--稀有怪
        setRareEliteKilled(arg1)
    elseif event=='LOOT_OPENED' then
        setRareEliteKilled('loot')

    elseif event=='PLAYER_MONEY' then--钱
        set_Money()--钱

    elseif event=='PLAYER_LEVEL_UP' then--玩家是否最高等级
        local level= arg1 or UnitLevel('player')
        e.Player.levelMax= level==MAX_PLAYER_LEVEL--玩家是否最高等级
        e.Player.level= level

    elseif event=='NEUTRAL_FACTION_SELECT_RESULT' then--玩家, 派系
        if arg1 then
            e.Player.faction= UnitFactionGroup('player')--玩家, 派系  "Alliance", "Horde", "Neutral"
        end

    elseif event=='PLAYER_EQUIPMENT_CHANGED' or event=='PLAYER_SPECIALIZATION_CHANGED' or event=='PLAYER_AVG_ITEM_LEVEL_UPDATE' then--更新自已
        if event=='PLAYER_SPECIALIZATION_CHANGED' and UnitInParty(arg1) then
            NotifyInspect(arg1)--队伍数据收集
        else
            NotifyInspect('player')--取得,自已, 装等
        end

    elseif event=='ENCOUNTER_START' then-- 给 e.Reload用
        e.IsEncouter_Start= true
    elseif event=='ENCOUNTER_START' then
        e.IsEncouter_Start= nil

    elseif event=='BN_FRIEND_INFO_CHANGED' then
        if arg1 then
            get_WoW_GUID_Info(arg1)--战网，好友GUID
        end
    end
end)