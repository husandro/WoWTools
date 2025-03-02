WoWTools_BagMixin={}

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
        local info = C_MerchantFrame.GetItemInfo(tab.merchantIndex)
        if info then
            itemName= info.name
        end

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








--背包，空位, all 包含材料 C_Container.GetContainerNumSlots(i)
function WoWTools_BagMixin:GetFree(isRegentBag)

    local free, all, regentsFree= 0, 0, 0--CalculateTotalNumberOfFreeBagSlots() MainMenuBarBagButtons.lua

    local num= NUM_BAG_FRAMES+ (isRegentBag and NUM_REAGENTBAG_FRAMES or 0)

    for i = BACKPACK_CONTAINER, num do
        local freeBag= C_Container.GetContainerNumFreeSlots(i) or 0
        free= free+ freeBag
        all= all+ (C_Container.GetContainerNumSlots(i) or 0)
        if isRegentBag and i==num then
            regentsFree= freeBag
        end
    end
    return free, all, regentsFree
end


function WoWTools_BagMixin:GetItems(checkAllBag, onlyItem, onlyRegents, checkBagFunc)
    local Tabs={}

    local context= ItemButtonUtil.GetItemContext()
    local num= NUM_BAG_FRAMES+ ((checkAllBag or onlyRegents) and NUM_REAGENTBAG_FRAMES or 0)
    local isCraftingReagent

    for bag= BACKPACK_CONTAINER, num do--0-5
        for slot=1, C_Container.GetContainerNumSlots(bag) do

            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemID and
                (context
                    and ItemButtonUtil.ItemContextMatchResult.Match == ItemButtonUtil.GetItemContextMatchResultForItem(ItemLocation:CreateFromBagAndSlot(bag, slot))
                    or (checkBagFunc and checkBagFunc(bag, slot, info))
                    or not checkBagFunc
                )
            then

                WoWTools_Mixin:Load({id=info.itemID, type='item'})
--仅物品，仅材料    
                if onlyItem or onlyRegents then

                    isCraftingReagent= select(17, C_Item.GetItemInfo(info.itemID))

                    if onlyRegents and isCraftingReagent or (onlyItem and isCraftingReagent==false) then
                        table.insert(Tabs, 1, {
                            info=info,
                            bag=bag,
                            slot=slot,
                        })
                    end
                else
                    table.insert(Tabs, 1, {
                        info=info,
                        bag=bag,
                        slot=slot,
                    })
                end
            end
        end
    end
    return Tabs
end
--[[
ItemButtonUtil.ItemContextEnum = {
	Scrapping = 1,
	CleanseCorruption = 2,
	PickRuneforgeBaseItem = 3,
	ReplaceBonusTree = 4,
	SelectRuneforgeItem = 5,
	SelectRuneforgeUpgradeItem = 6,
	Soulbinds = 7,
	MythicKeystone = 8,
	UpgradableItem = 9,
	RunecarverScrapping = 10,
	ItemConversion = 11,
	ItemRecrafting = 12,
	JumpUpgradeTrack = 13,
	AccountBankDepositing = 14,
	Enchanting = 15,
}

ItemButtonUtil.ItemContextMatchResult = {
	Match = 1,
	Mismatch = 2,
	DoesNotApply = 3,
}
]]