--ItemLocation.lua
WoWTools_ItemLocationMixin={
    itemLocation={}
}

function WoWTools_ItemLocationMixin:Clear()
    self.itemLocation={}
end
function WoWTools_ItemLocationMixin:SetBagAndSlot(bagID, slotIndex)
	self:Clear();
	self.itemLocation.bagID = bagID;
	self.itemLocation.slotIndex = slotIndex;
end
function WoWTools_ItemLocationMixin:GetBagAndSlot()
	return self.itemLocation.bagID, self.itemLocation.slotIndex
end


function WoWTools_ItemLocationMixin:SetEquipmentSlot(equipmentSlotIndex)
	self:Clear();
	self.itemLocation.equipmentSlotIndex = equipmentSlotIndex;
end
function WoWTools_ItemLocationMixin:GetEquipmentSlot()
	return self.itemLocation.equipmentSlotIndex;
end
function WoWTools_ItemLocationMixin:IsEquipmentSlot()
	return self.itemLocation.equipmentSlotIndex ~= nil;
end
function WoWTools_ItemLocationMixin:IsBagAndSlot()
	return self.itemLocation.bagID ~= nil and self.itemLocation.slotIndex ~= nil;
end
function WoWTools_ItemLocationMixin:HasAnyLocation()
	return self.itemLocation:IsEquipmentSlot() or self.itemLocation:IsBagAndSlot();
end
function WoWTools_ItemLocationMixin:IsValid()
	return C_Item.DoesItemExist(self.itemLocation)
end
function WoWTools_ItemLocationMixin:IsEqualToBagAndSlot(otherBagID, otherSlotIndex)
	local bagID, slotIndex = self.itemLocation:GetBagAndSlot();
	if bagID and slotIndex then
		return bagID == otherBagID and slotIndex == otherSlotIndex;
	end
	return false;
end
function WoWTools_ItemLocationMixin:IsEqualToEquipmentSlot(otherEquipmentSlotIndex)
	local equipmentSlotIndex = self.itemLocation:GetEquipmentSlot();
	if equipmentSlotIndex then
		return equipmentSlotIndex == otherEquipmentSlotIndex;
	end
	return false;
end
function WoWTools_ItemLocationMixin:IsEqualTo(otherItemLocation)
	if otherItemLocation then
		local bagID, slotIndex = self.itemLocation:GetBagAndSlot();
		if bagID and slotIndex then
			local otherBagID, otherSlotIndex = otherItemLocation:GetBagAndSlot();
			return bagID == otherBagID and slotIndex == otherSlotIndex;
		end
		local equipmentSlotIndex = self.itemLocation:GetEquipmentSlot();
		if equipmentSlotIndex then
			local otherEquipmentSlotIndex = otherItemLocation:GetEquipmentSlot();
			return equipmentSlotIndex == otherEquipmentSlotIndex;
		end
		return not otherItemLocation:HasAnyLocation();
	end
	return false;
end

--[[
ItemLocation = {};
ItemLocationMixin = {};
function ItemLocation:CreateEmpty()
	local itemLocation = CreateFromMixins(ItemLocationMixin);
	return itemLocation;
end
function ItemLocation:CreateFromBagAndSlot(bagID, slotIndex)
	local itemLocation = ItemLocation:CreateEmpty();
	itemLocation:SetBagAndSlot(bagID, slotIndex);
	return itemLocation;
end
function ItemLocation:CreateFromEquipmentSlot(equipmentSlotIndex)
	local itemLocation = ItemLocation:CreateEmpty();
	itemLocation:SetEquipmentSlot(equipmentSlotIndex);
	return itemLocation;
end
function ItemLocation:ApplyLocationToTooltip(itemLocation, tooltip)
	if itemLocation:IsEquipmentSlot() then
		tooltip:SetInventoryItem("player", itemLocation:GetEquipmentSlot());
	elseif itemLocation:IsBagAndSlot() then
		tooltip:SetBagItem(itemLocation:GetBagAndSlot());
	end
end


function ItemLocationMixin:Clear()
	self.bagID = nil;
	self.slotIndex = nil;
	self.equipmentSlotIndex = nil;
end
function ItemLocationMixin:SetBagAndSlot(bagID, slotIndex)
	self:Clear();
	self.bagID = bagID;
	self.slotIndex = slotIndex;
end
function ItemLocationMixin:GetBagAndSlot()
	return self.bagID, self.slotIndex;
end
function ItemLocationMixin:SetEquipmentSlot(equipmentSlotIndex)
	self:Clear();
	self.equipmentSlotIndex = equipmentSlotIndex;
end
function ItemLocationMixin:GetEquipmentSlot()
	return self.equipmentSlotIndex;
end
function ItemLocationMixin:IsEquipmentSlot()
	return self.equipmentSlotIndex ~= nil;
end
function ItemLocationMixin:IsBagAndSlot()
	return self.bagID ~= nil and self.slotIndex ~= nil;
end
function ItemLocationMixin:HasAnyLocation()
	return self:IsEquipmentSlot() or self:IsBagAndSlot();
end
function ItemLocationMixin:IsValid()
	return C_Item.DoesItemExist(self);
end
function ItemLocationMixin:IsEqualToBagAndSlot(otherBagID, otherSlotIndex)
	local bagID, slotIndex = self:GetBagAndSlot();
	if bagID and slotIndex then
		return bagID == otherBagID and slotIndex == otherSlotIndex;
	end
	return false;
end
function ItemLocationMixin:IsEqualToEquipmentSlot(otherEquipmentSlotIndex)
	local equipmentSlotIndex = self:GetEquipmentSlot();
	if equipmentSlotIndex then
		return equipmentSlotIndex == otherEquipmentSlotIndex;
	end
	return false;
end
function ItemLocationMixin:IsEqualTo(otherItemLocation)
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
]]