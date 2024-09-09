local e= select(2, ...)

function e.LoadData(tab)--e.LoadData({id=, type=''})--加载 item quest spell, uiMapID
    if not tab or not tab.id then
        return
    end
    if tab.type=='quest' then --e.LoadData({id=, type='quest'})
        C_QuestLog.RequestLoadQuestByID(tab.id)
        if not HaveQuestRewardData(tab.id) then
            C_TaskQuest.RequestPreloadRewardData(tab.id)
        end

    elseif tab.type=='spell' then--e.LoadData({id=, type='spell'})
        local spellID= tab.id
        if type(tab.id)=='string' then
            spellID= (C_Spell.GetSpellInfo(tab.id) or {}).spellID
        end
        if spellID and not C_Spell.IsSpellDataCached(spellID) then
            C_Spell.RequestLoadSpellData(spellID)
        end

    elseif tab.type=='item' then--e.LoadData({id=, type='item'})
        local item= tab.itemLink or tab.id-- tab.id or (tab.itemLink and tab.itemLink:match('|Hitem:(%d+):'))
        if item and not C_Item.IsItemDataCachedByID(item) then
            C_Item.RequestLoadItemDataByID(item)
        end
    elseif tab.type=='itemLocation' then
        if not C_Item.IsItemDataCached(tab.id) then
            C_Item.RequestLoadItemData(tab.id)
        end

    elseif tab.type=='mapChallengeModeID' then--e.LoadData({id=, type='mapChallengeModeID'})
        C_ChallengeMode.RequestLeaders(tab.id)

    elseif tab.typ=='club' then--e.LoadData({id=, type='club'})
        C_Club.RequestTickets(tab.id)
    end
end



local itemLoadTab={--加载法术,或物品数据
        134020,--玩具,大厨的帽子
        6948,--炉石
        140192,--达拉然炉石
        110560,--要塞炉石
        5512,--治疗石
        8529,--诺格弗格药剂
        38682,--附魔纸
        5512--治疗石
    }
local spellLoadTab={
    113509,--魔法汉堡
    818,--火    
    179244,--[召唤司机]
    179245,--[召唤司机]
    33388,--初级骑术
    33391,--中级骑术
    34090,--高级骑术
    34091,--专家级骑术
    90265,--大师级骑术
    783,--旅行形态
    436854,--切换飞行模式 C_MountJournal.GetDynamicFlightModeSpellID()
    404468,--/飞行模式：稳定
}


for _, itemID in pairs(itemLoadTab) do
    e.LoadData({id=itemID, type='item'})
end
for _, spellID in pairs(spellLoadTab) do
    e.LoadData({id=spellID, type='spell'})
end


