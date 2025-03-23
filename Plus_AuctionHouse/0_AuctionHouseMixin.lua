
WoWTools_AuctionHouseMixin= {}
--物品Link
function WoWTools_AuctionHouseMixin:GetItemLink(rowData)
    if not rowData then
        return
    end
    local itemLink= rowData.itemLink
    local itemID, isPet
    itemID= rowData.itemID or (rowData and rowData.itemKey and rowData.itemKey.itemID)
    if not itemLink and rowData.auctionID then
        local priceInfo = C_AuctionHouse.GetAuctionInfoByID(rowData.auctionID) or {}
        itemLink= priceInfo.itemLink or priceInfo.battlePetLink
    end
    if not itemLink and itemID then
        itemLink= WoWTools_ItemMixin:GetLink(itemID)
    end
    isPet= rowData and rowData.itemKey and rowData.itemKey.battlePetSpeciesID and rowData.itemKey.battlePetSpeciesID>0
    return itemLink, itemID, isPet
end

--显示模式
function WoWTools_AuctionHouseMixin:GetDisplayMode()
    local displayMode= AuctionHouseFrame:GetDisplayMode()
    return
        displayMode==AuctionHouseFrameDisplayMode.CommoditiesSell,--商品
        displayMode==AuctionHouseFrameDisplayMode.ItemSell--物品
end

--物品列表，检测有效物品
function WoWTools_AuctionHouseMixin:GetItemSellStatus(bag, slot, isCheckHideItem)
    local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot);
    if itemLocation and itemLocation:IsValid() and C_AuctionHouse.IsSellItemValid(itemLocation, false) then--ContainerFrame.lua
        local itemCommodityStatus= C_AuctionHouse.GetItemCommodityStatus(itemLocation) or 0
        if itemCommodityStatus>0 then
            local info = C_Container.GetContainerItemInfo(bag, slot) or {}
            if
                info.itemID
                and info.hyperlink
                and info.quality>= WoWToolsSave['Plus_AuctionHouse'].sellItemQualiy
                and (isCheckHideItem
                    and (
                        (info.itemID==82800 and not WoWToolsSave['Plus_AuctionHouse'].hideSellPet[info.hyperlink:match('Hbattlepet:(%d+)')])
                        or (info.itemID~=82800 and not WoWToolsSave['Plus_AuctionHouse'].hideSellItem[info.itemID])
                    )
                    or not isCheckHideItem
                )
            then
                return itemLocation, itemCommodityStatus, info
            end
        end
    end
end

--放入，第一个，物品
function WoWTools_AuctionHouseMixin:SetPostNextSellItem()
    local isCommoditiesSellFrame, isItemSellFrame= self:GetDisplayMode()
    if not C_AuctionHouse.IsThrottledMessageSystemReady()
        or (isCommoditiesSellFrame and AuctionHouseFrame.CommoditiesSellFrame:GetItem())
        or (isItemSellFrame and AuctionHouseFrame.ItemSellFrame:GetItem())
        or not AuctionHouseFrame:IsShown()
    then
        return
    end
    
    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES do--Constants.InventoryConstants.NumBagSlots
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local itemLocation, itemCommodityStatus= self:GetItemSellStatus(bag, slot, true)
            if itemLocation
                and (
                    (itemCommodityStatus==Enum.ItemCommodityStatus.Commodity and isCommoditiesSellFrame)
                    or (itemCommodityStatus==Enum.ItemCommodityStatus.Item and isItemSellFrame)
                )
            then
                AuctionHouseFrame:SetPostItem(itemLocation)--ContainerFrame.lua
                return
            end
        end
    end
end

