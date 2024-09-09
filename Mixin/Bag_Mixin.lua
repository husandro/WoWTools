
WoWTools_BagMixin={
    --Find
}

--查询，背包里物品，itemName，itemLink，itemID，itemLocation，merchantIndex，BuybackIndex，itemKey，bag，guidBank，lootIndex
function WoWTools_BagMixin:Find(find, tab)
    if not IsBagOpen(Enum.BagIndex.Backpack) and not IsBagOpen(NUM_TOTAL_EQUIPPED_BAG_SLOTS) then
        return
    end

    if find~=true or not tab then
        C_Container.SetItemSearch('')
        return
    end

    local itemName, itemLink
    if tab.itemName then--名称
        itemName= tab.itemName

    elseif tab.itemLink then--itemLink
        itemLink= tab.itemLink

    elseif tab.itemID then--itemID
        itemName= C_Item.GetItemNameByID(tab.itemLink or tab.itemID)

    elseif tab.itemLocation and tab.itemLocation:IsValid() then--itemLocation
        itemName= C_Item.GetItemName(tab.itemLocation)

    elseif tab.merchantIndex then--商人
        itemName=  GetMerchantItemInfo(tab.merchantIndex)

    elseif tab.BuybackIndex then--商人，回购
        itemName= GetBuybackItemInfo(tab.BuybackIndex)

    elseif tab.itemKey then--itemKey
        local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(tab.itemKey) or {}
        itemName= itemKeyInfo.itemName

    elseif tab.bag then--背包 {}
        itemLink= C_Container.GetContainerItemLink(tab.bag.bag, tab.bag.slot)

    elseif tab.guidBank then--公会银行 {}
        itemLink= GetGuildBankItemLink(tab.guidBank.tab, tab.guidBank.slot)
    elseif tab.lootIndex then
        local _, lootName, _, currencyID= GetLootSlotInfo(tab.lootIndex)
        itemName= not currencyID and lootName
    end

    if itemLink then
        itemName= C_Item.GetItemNameByID(itemLink) or itemLink:match('|H.-%[(.-)]|h')
    end
    if itemName then
        C_Container.SetItemSearch(itemName)
    end
end








--背包，空位
function WoWTools_BagMixin:GetFree(all)
    local free= 0--CalculateTotalNumberOfFreeBagSlots() MainMenuBarBagButtons.lua
    local num= NUM_BAG_FRAMES+(all and NUM_REAGENTBAG_FRAMES or 0)
    for i = BACKPACK_CONTAINER, num do
        free= free+ (C_Container.GetContainerNumFreeSlots(i) or 0)
    end
    return free
end



