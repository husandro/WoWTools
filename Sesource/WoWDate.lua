local id, e = ...
local panel=CreateFrame("Frame")
e.WoWSave={}

--########
--玩家装等
--########
e.UnitItemLevel={}
local function getPlayerInfo(unit, guid)--取得玩家信息
    if not unit and guid then
        unit= e.GroupGuid[guid] and e.GroupGuid[guid].unit 
                or guid== e.Player.guid and 'player'
                or guid== UnitGUID("mouseover") and "mouseover"
                or guid== UnitGUID('target') and 'target'
    end
    if unit and UnitExists(unit) and guid then
        local itemLevel=C_PaperDollInfo.GetInspectItemLevel(unit)
        if itemLevel and itemLevel>1 then
            local name, realm= UnitFullName(unit)
            local r, g, b, hex = GetClassColor(UnitClassBase(unit))
            
            e.UnitItemLevel[guid] = {--玩家装等
                itemLevel=itemLevel,
                specID=GetInspectSpecialization(unit),
                name=name,
                realm=realm,
                col='|c'..hex,
                r=r,
                g=g,
                b=b,
            }
        end
    end
end


--###########
--队伍数据收集
--###########
e.GroupGuid={}
local function set_GroupGuid()--队伍数据收集
    e.GroupGuid={}
    if IsInRaid() then
        for index= 1, GetNumGroupMembers() do
            local unit='raid'..index
            local guid=UnitGUID(unit)
            local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(index)
            if guid then
                local tab={unit=unit, subgroup=subgroup, combatRole=combatRole or role}
                e.GroupGuid[guid]=tab
                e.GroupGuid[GetUnitName(unit, true)]=tab

                if (not e.UnitItemLevel[guid] or not e.UnitItemLevel[guid].itemLeve ) and CheckInteractDistance(unit, 1) then
                    NotifyInspect(unit)--取得装等
                end
            end
        end
    else
        local tab
        for index= 1, GetNumGroupMembers()-1 do
            local unit='party'..index
            local guid=UnitGUID(unit)
            if guid then
                tab={unit=unit, combatRole=UnitGroupRolesAssigned(unit)}
                e.GroupGuid[guid]=tab
                e.GroupGuid[GetUnitName(unit, true)]=tab

                if (not e.UnitItemLevel[guid] or not e.UnitItemLevel[guid].itemLeve ) and CheckInteractDistance(unit, 1) then
                    NotifyInspect(unit)--取得装等
                end
            end
        end
        tab={unit='player', combatRole=UnitGroupRolesAssigned('player')}
        e.GroupGuid[e.Player.guid]=tab
        e.GroupGuid[UnitName('player')]=tab        
    end
end


--#########
--地下城挑战
--#########
local function updateChallengeMode()--{score=总分数,itemLink={超连接}, weekLevel=本周最高, weekNum=本周次数, all=总次数,week=周数}
    local tab={
        itemLink=e.WoWSave[e.Player.guid].Keystone.itemLink
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
    e.WoWSave[e.Player.guid].Keystone=tab
end

--#######
--更新物品
--#######
local function updateItems()
    e.WoWSave[e.Player.guid].Keystone.itemLink={}
    e.WoWSave[e.Player.guid].Item={}--{itemID={bag=包, bank=银行}}
    for bagID=0, NUM_BAG_SLOTS do
        for slotID=1, C_Container.GetContainerNumSlots(bagID) do
            local itemID = C_Container.GetContainerItemID(bagID, slotID)
            if itemID then
                if C_Item.IsItemKeystoneByID(itemID) then--挑战
                    local itemLink=C_Container.GetContainerItemLink(bagID, slotID)
                    if itemLink then
                        e.WoWSave[e.Player.guid].Keystone.itemLink[itemLink]=true
                    end
                else
                    local bag=GetItemCount(itemID)--物品ID
                    e.WoWSave[e.Player.guid].Item[itemID]={
                        bag=bag,
                        bank=GetItemCount(itemID,true)-bag,
                    }
                end
            end
        end
    end
end

--#######
--更新货币
--#######
local function updateCurrency(arg1)--{currencyID = 数量}
    if arg1 then
        local info = C_CurrencyInfo.GetCurrencyInfo(arg1)
        if info and info.quantity then
            e.WoWSave[e.Player.guid].Currency[arg1]=info.quantity==0 and nil or info.quantity
        end
    else
        for i=1, C_CurrencyInfo.GetCurrencyListSize() do
            local link =C_CurrencyInfo.GetCurrencyListLink(i)
            local currencyID = link and C_CurrencyInfo.GetCurrencyIDFromLink(link)
            local info = C_CurrencyInfo.GetCurrencyListInfo(i)
            if currencyID and info and info.quantity then
                e.WoWSave[e.Player.guid].Currency[currencyID]=info.quantity==0 and nil or info.quantity
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
            if e.WoWSave[e.Player.guid].Rare.boss[bossName] then--清除稀有怪
                e.WoWSave[e.Player.guid].Rare.boss[bossName]=nil
            end
        end
    end

    e.WoWSave[e.Player.guid].Worldboss={
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
    e.WoWSave[e.Player.guid].Instance = {
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
                e.WoWSave[e.Player.guid].Rare.boss[name]=true
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
                    e.WoWSave[e.Player.guid].Rare.boss[name]=true
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
    e.WoWSave[e.Player.guid].Money= money==0 and nil or money
end

panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_LOGOUT')

panel:RegisterEvent('GROUP_ROSTER_UPDATE')--队伍数据收集 e.GroupGuid
panel:RegisterEvent('GROUP_LEFT')
panel:RegisterEvent('ADDON_LOADED')

panel:RegisterEvent('TIME_PLAYED_MSG')--总游戏时间：%s

panel:RegisterEvent('INSPECT_READY')

panel:RegisterEvent('CHALLENGE_MODE_MAPS_UPDATE')--地下城挑战
panel:RegisterEvent('CHALLENGE_MODE_COMPLETED')
panel:RegisterEvent('WEEKLY_REWARDS_UPDATE')

panel:RegisterEvent('PLAYER_MONEY')--钱

panel:RegisterEvent('ZONE_CHANGED_NEW_AREA')--位面, 清除
panel:RegisterEvent('PLAYER_ENTERING_WORLD')

panel:RegisterEvent('BOSS_KILL')--显示世界BOSS击杀数据

panel:RegisterEvent('CURRENCY_DISPLAY_UPDATE')--货币

panel:RegisterEvent('BAG_UPDATE_DELAYED')--物品

panel:RegisterEvent('UPDATE_INSTANCE_INFO')--副本

panel:RegisterEvent('PLAYER_LEVEL_UP')--更新玩家等级

panel:SetScript('OnEvent', function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1==id then
        local day= date('%x')--日期
        e.WoWSave=WoWDate or {}
        e.WoWSave[e.Player.guid] = e.WoWSave[e.Player.guid] or
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

        for guid, tab in pairs(e.WoWSave) do--清除不是本周数据
            if tab.Keystone.week ~=e.Player.week then
                e.WoWSave[guid].Keystone={itemLink={}}
            end
            if tab.Instance.week~=e.Player.week then
                e.WoWSave[guid].Instance={ins={}}
            end
            if tab.Worldboss.week~=e.Player.week then
                e.WoWSave[guid].Worldboss={boss={}}
            end

            if tab.Rare.day~=day then
                e.WoWSave[guid].Rare={day=day,boss={}}
            end
        end

        C_Timer.After(2, function()
            set_GroupGuid()--队伍数据收集
            NotifyInspect('player')--取得,自已, 装等
            C_MythicPlus.RequestMapInfo()
            C_MythicPlus.RequestRewards()
            C_MythicPlus.RequestCurrentAffixes()
            RequestRaidInfo()
            set_Money()--钱
            updateCurrency()--{currencyID = 数量}
        end)
    elseif event=='PLAYER_LOGOUT' then
        if not e.ClearAllSave then
            WoWDate=e.WoWSave
        end

    elseif event=='GROUP_ROSTER_UPDATE' or event=='GROUP_LEFT' then--队伍数据
        set_GroupGuid()
    elseif event=='GROUP_LEFT' then
        e.GroupGuid={}

    elseif event=='TIME_PLAYED_MSG' then--总游戏时间：%s
        if arg1 and arg2 then
            e.WoWSave[e.Player.guid].Time={
                totalTime= arg1,
                levelTime= arg2,
            }
        end

    elseif event=='INSPECT_READY' then--装等
        local unit= UnitGUID("mouseover")==arg1 and 'mouseover'
                    or e.GroupGuid[arg1] and e.GroupGuid[arg1].unit 
                    or arg1==e.Player.guid and 'player'
                    or arg1==UnitGUID('target') and 'target'
        if unit then
            getPlayerInfo(unit, arg1)
        end

    elseif event=='CHALLENGE_MODE_MAPS_UPDATE' or event=='WEEKLY_REWARDS_UPDATE' then--地下城挑战
        updateChallengeMode()

    elseif event=='CHALLENGE_MODE_COMPLETED' then
        C_MythicPlus.RequestMapInfo()

    elseif event=='ZONE_CHANGED_NEW_AREA' then--位面, 清除
        e.Layer=nil 

    elseif event=='PLAYER_ENTERING_WORLD' then--记录稀有怪
        e.Layer=nil
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
        local level=UnitLevel('player')
        e.Player.levelMax= level==MAX_PLAYER_LEVEL--玩家是否最高等级
        e.Player.level=level
    end
end)