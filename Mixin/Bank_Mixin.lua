WoWTools_BankMixin={}

--银行，空位
function WoWTools_BankMixin:GetFree()
    local free= 0
    for i=1, NUM_BANKGENERIC_SLOTS do--28        
        if not self:GetItemInfo(BankSlotsFrame["Item"..i]) then
            free= free+1
        end
    end
    for bag=(NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS), NUM_TOTAL_EQUIPPED_BAG_SLOTS+1, -1 do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if not info or not info.itemID then
                free= free+ 1
            end
        end
    end
    return free
end


function WoWTools_BankMixin:GetItemInfo(button)
    if button then
        local info = C_Container.GetContainerItemInfo(self:GetBagAndSlot(button))
        if info and info.itemID then
            return info
        end
    end
end
--[[
Field	Type	
iconFileID	number	
stackCount	number	
isLocked	boolean	
quality	Enum.ItemQuality?	
isReadable	boolean	
hasLoot	boolean	
hyperlink	string	
isFiltered	boolean	
hasNoValue	boolean	
itemID	number	
isBound	boolean	
]]

function WoWTools_BankMixin:GetBagAndSlot(button)
    return button.isBag and Enum.BagIndex.Bankbag
        or button:GetParent():GetID(),

        button:GetID()
end