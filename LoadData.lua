local e = select(2, ...)

local itemLoadTab={--加载法术,或物品数据
        134020,--玩具,大厨的帽子
        6948,--炉石
        140192,--达拉然炉石
        110560,--要塞炉石
        5512,--治疗石
        8529,--诺格弗格药剂
        38682,--附魔纸
        179244,--[召唤司机]
        179245,
    }
local spellLoadTab={
    818,--火
}

for _, itemID in pairs(itemLoadTab) do
    e.LoadDate({id=itemID, type='item'})
end
for _, spellID in pairs(spellLoadTab) do
    e.LoadDate({id=spellID, type='spell'})
end