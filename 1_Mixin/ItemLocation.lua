--ItemLocation.lua

WoWTools_ItemLocationMixin={
    itemLocation={},
}




--清除
function WoWTools_ItemLocationMixin:Clear()
    self.itemLocation={}
end
--是否，有数扰
function WoWTools_ItemLocationMixin:HasAnyLocation()
	return self:IsEquipmentSlot() or self:IsBagAndSlot();
end
--是否，存在，物品
function WoWTools_ItemLocationMixin:IsValid()
	if self:HasAnyLocation() then
		return C_Item.DoesItemExist(self.itemLocation)
	end
end

--设置，背包，bagID, slotIndex
function WoWTools_ItemLocationMixin:SetBagAndSlot(bagID, slotIndex)
	self:Clear();
	self.itemLocation.bagID = bagID;
	self.itemLocation.slotIndex = slotIndex;
end
--得到，背包，bagID, slotIndex
function WoWTools_ItemLocationMixin:GetBagAndSlot()
	return self.itemLocation.bagID, self.itemLocation.slotIndex
end
--是否，背包
function WoWTools_ItemLocationMixin:IsBagAndSlot()
	return self.itemLocation.bagID ~= nil and self.itemLocation.slotIndex ~= nil;
end
--是否是，当前背包，位置
function WoWTools_ItemLocationMixin:IsEqualToBagAndSlot(otherBagID, otherSlotIndex)
	local bagID, slotIndex = self:GetBagAndSlot();
	if bagID and slotIndex then
		return bagID == otherBagID and slotIndex == otherSlotIndex;
	end
	return false;
end



--设置，装备槽
function WoWTools_ItemLocationMixin:SetEquipmentSlot(equipmentSlotIndex)
	self:Clear();
	self.itemLocation.equipmentSlotIndex = equipmentSlotIndex;
end
--得到，装备槽
function WoWTools_ItemLocationMixin:GetEquipmentSlot()
	return self.itemLocation.equipmentSlotIndex;
end
--是否，装备槽
function WoWTools_ItemLocationMixin:IsEquipmentSlot()
	return self.itemLocation.equipmentSlotIndex ~= nil;
end
--是否，装备到批定槽
function WoWTools_ItemLocationMixin:IsEqualToEquipmentSlot(otherEquipmentSlotIndex)
	local equipmentSlotIndex = self:GetEquipmentSlot();
	if equipmentSlotIndex then
		return equipmentSlotIndex == otherEquipmentSlotIndex;
	end
	return false;
end





--是装备到其它 槽
function WoWTools_ItemLocationMixin:IsEqualTo(otherItemLocation)
	if otherItemLocation then
		local bagID, slotIndex = self:GetBagAndSlot();
		if bagID and slotIndex then
			local otherBagID, otherSlotIndex = otherItemLocation:GetBagAndSlot();
			return bagID == otherBagID and slotIndex == otherSlotIndex;
		end
		local equipmentSlotIndex = self:GetEquipmentSlot();
		if equipmentSlotIndex then
			local otherEquipmentSlotIndex = otherItemLocation:GetEquipmentSlot();
			return equipmentSlotIndex == otherEquipmentSlotIndex;
		end
		return not otherItemLocation:HasAnyLocation();
	end
	return false;
end








--背包，信息
function WoWTools_ItemLocationMixin:GetContainerInfo()
	if self:IsBagAndSlot() then
		return C_Container.GetContainerItemInfo(self:GetBagAndSlot())
	end
end

--取得，背包或装备 ID
function WoWTools_ItemLocationMixin:GetItemID()
	if self:IsValid() then
		if self:IsBagAndSlot() then
			return C_Container.GetContainerItemID(self:GetBagAndSlot())
		elseif self:IsEquipmentSlot() then
			return GetInventoryItemID('player', self.itemLocation.equipmentSlotIndex)
		end
	end
end

--背包或装备 ItemLink
function WoWTools_ItemLocationMixin:GetItemLink()
	if self:IsValid() then
		if self:IsBagAndSlot() then
			return C_Container.GetContainerItemLink(self:GetBagAndSlot())
		elseif self:IsEquipmentSlot() then
			return GetInventoryItemLink('player', self.itemLocation.equipmentSlotIndex)
		end
	end
end

--背包或装备 数量
function WoWTools_ItemLocationMixin:GetItemCount()
	local count
	if self:IsValid() then
		if self:IsBagAndSlot() then
			local itemID= self:GetItemID()
			if itemID then
				count= C_Item.GetItemCount(itemID, true, false, true, true)
			end
		elseif self:IsEquipmentSlot() then
			count= GetInventoryItemCount('player', self.itemLocation.equipmentSlotIndex) or 0
		end
	end
	count= count or 0

	local text= count>0 and ' x'..count or ' |cff9e9e9ex0|r'
	return count or 0, text
end

--物品冷却 start, duration, enable
function WoWTools_ItemLocationMixin:GetItemCooldown()
	if self:IsValid() then
		if self:IsBagAndSlot() then
			return C_Container.GetContainerItemCooldown(self:GetBagAndSlot())
		elseif self:IsEquipmentSlot() then

			return GetInventoryItemCooldown('player', self.itemLocation.equipmentSlotIndex)
		end
	end
end

--物品冷却 start, duration, enable
function WoWTools_ItemLocationMixin:GetItemQuality()
	if self:IsValid() then
		if self:IsBagAndSlot() then
			local containerInfo=C_Container.GetContainerItemInfo(self:GetBagAndSlot())
			if containerInfo then
				return containerInfo.quality
			end
		elseif self:IsEquipmentSlot() then
			return GetInventoryItemQuality('player', self.itemLocation.equipmentSlotIndex)
		end
	end
end

--物品名称, name, WoWTools_TextMixin:CN(name)
function WoWTools_ItemLocationMixin:GetItemTexture()
	local texture
	if self:IsValid() then
		local itemID= self:itemID()
		if itemID then
			texture= C_Item.GetItemIconByID(itemID)
		end
	end
	texture= texture or 0
	return texture, format('|T%d:0|t', texture)
end

--物品名称, name, WoWTools_TextMixin:CN(name)
function WoWTools_ItemLocationMixin:GetItemName(isText)
	if self:IsValid() then
		local itemID= self:GetItemID()
		local itemName= itemID and C_Item.GetItemNameByID(itemID)
		if itemName then
			return itemName, isText and WoWTools_ItemMixin:GetName(itemID)
		end
	end
end


--[[
C_Container.GetContainerItemInfo
iconFileID	number	
stackCount	number	
isLocked	boolean	
quality	Enum.ItemQuality?🔗
isReadable	boolean	
hasLoot	boolean	
hyperlink	string	
isFiltered	boolean	
hasNoValue	boolean	
itemID	number	
isBound	boolean


CancelPendingEquip(index) - Cancels a pending equip confirmation.
EquipPendingItem(invSlot) - Equips the currently pending Bind-on-Equip or Bind-on-Pickup item from the specified inventory slot.
GetAverageItemLevel() - Returns the character's average item level.
GetInventoryAlertStatus(index) - Returns the durability status of an equipped item.
GetInventoryItemBroken(unit, invSlot) - Returns true if an inventory item has zero durability.
GetInventoryItemCooldown(unit, invSlot) - Get cooldown information for an inventory item.
GetInventoryItemCount(unit, invSlot) - Determine the quantity of an item in an inventory slot.
GetInventoryItemDurability(invSlot) - Returns the durability of an equipped item.
GetInventoryItemID(unit, invSlot) - Returns the item ID for an equipped item.
GetInventoryItemLink(unit, invSlot) - Returns the item link for an equipped item.
GetInventoryItemQuality(unit, invSlot) - Returns the quality of an equipped item.
GetInventoryItemTexture(unit, invSlot) - Returns the texture for an equipped item.
GetInventorySlotInfo(invSlotName) - Returns info for an equipment slot.
HasWandEquipped() - Returns true if a wand is equipped.
IsInventoryItemLocked(id) - Returns whether an inventory item is locked, usually as it awaits pending action.
UpdateInventoryAlertStatus()
UseInventoryItem(invSlot) #pro


C_Container.ContainerIDToInventoryID(containerID) : inventoryID
C_Container.ContainerRefundItemPurchase(containerIndex, slotIndex [, isEquipped])
C_Container.GetBackpackAutosortDisabled() : isDisabled
C_Container.GetBagName(bagIndex) : name
C_Container.GetBagSlotFlag(bagIndex, flag) : isSet
C_Container.GetBankAutosortDisabled() : isDisabled
C_Container.GetContainerFreeSlots(containerIndex) : freeSlots
C_Container.GetContainerItemCooldown(containerIndex, slotIndex) : startTime, duration, enable
C_Container.GetContainerItemDurability(containerIndex, slotIndex) : durability, maxDurability
C_Container.GetContainerItemEquipmentSetInfo(containerIndex, slotIndex) : inSet, setList
C_Container.GetContainerItemID(containerIndex, slotIndex) : containerID
C_Container.GetContainerItemInfo(containerIndex, slotIndex) : containerInfo
C_Container.GetContainerItemLink(containerIndex, slotIndex) : itemLink
C_Container.GetContainerItemPurchaseCurrency(containerIndex, slotIndex, itemIndex, isEquipped) : currencyInfo
C_Container.GetContainerItemPurchaseInfo(containerIndex, slotIndex, isEquipped) : info
C_Container.GetContainerItemPurchaseItem(containerIndex, slotIndex, itemIndex, isEquipped) : itemInfo
C_Container.GetContainerItemQuestInfo(containerIndex, slotIndex) : questInfo
C_Container.GetContainerNumFreeSlots(bagIndex) : numFreeSlots, bagFamily
C_Container.GetContainerNumSlots(containerIndex) : numSlots
C_Container.GetInsertItemsLeftToRight() : isEnabled
C_Container.GetItemCooldown(itemID) : startTime, duration, enable
C_Container.GetMaxArenaCurrency() : maxCurrency
C_Container.GetSortBagsRightToLeft() : isEnabled
C_Container.IsBattlePayItem(containerIndex, slotIndex) : isBattlePayItem
C_Container.IsContainerFiltered(containerIndex) : isFiltered
C_Container.PickupContainerItem(containerIndex, slotIndex)
C_Container.PlayerHasHearthstone() : itemID
C_Container.SetBackpackAutosortDisabled(disable)
C_Container.SetBagPortraitTexture(texture, bagIndex)
C_Container.SetBagSlotFlag(bagIndex, flag, isSet)
C_Container.SetBankAutosortDisabled(disable)
C_Container.SetInsertItemsLeftToRight(enable)
C_Container.SetItemSearch(searchString)
C_Container.SetSortBagsRightToLeft(enable)
C_Container.ShowContainerSellCursor(containerIndex, slotIndex)
C_Container.SocketContainerItem(containerIndex, slotIndex) : success
C_Container.SortBags()
C_Container.SortBankBags()
C_Container.SortReagentBankBags()
C_Container.SplitContainerItem(containerIndex, slotIndex, amount)
C_Container.UseContainerItem(containerIndex, slotIndex, [unitToken], [reagentBankOpen])
C_Container.UseHearthstone() : used
]]