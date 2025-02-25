--[[
	Enum.BankType = {
		Character = 0,
		Guild = 1,
		Account = 2,
	},
]]
WoWTools_BankMixin={}



--银行，空位
function WoWTools_BankMixin:GetFree(index)
    local free= 0
    index= index or BankFrame.activeTabIndex

    if index==1 then
--银行
        for i=1, NUM_BANKGENERIC_SLOTS do--28
            if not self:GetItemInfo(BankSlotsFrame["Item"..i]) then
                free=free+1
            end
        end

        --银行，背包
        for bag=NUM_TOTAL_EQUIPPED_BAG_SLOTS+1, (NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS) do--6-12
            free= free+ (C_Container.GetContainerNumFreeSlots(bag) or 0)
        end

--材料银行       
    elseif index==2 then
        for _, btn in ReagentBankFrame:EnumerateValidItems() do
            if not self:GetItemInfo(btn) then
                free=free+1
            end
        end

--战团银行   
    elseif index==3 then
        for btn in AccountBankPanel:EnumerateValidItems() do
            if not self:GetItemInfo(btn) then
                free=free+1
            end
        end
    end

    return free
end



function WoWTools_BankMixin:GetBagAndSlot(button)
    return button.isBag and Enum.BagIndex.Bankbag
        or button:GetParent():GetID(),

        button:GetID()
end


function WoWTools_BankMixin:GetItemInfo(button)
    if button then
        local bag, slot= self:GetBagAndSlot(button)
        if bag and slot then
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemID then
                return info, bag, slot
            end
        end
    end
end




function WoWTools_BankMixin:GetItems(index)--从最后，到第一
    local Tabs={}
    index= index or BankFrame.activeTabIndex

    if index==1 then
--银行
        for i=1, NUM_BANKGENERIC_SLOTS do--28
            local info, bag, slot= self:GetItemInfo(BankSlotsFrame["Item"..i])
            if info then
                table.insert(Tabs, 1, {
                    info=info,
                    bag=bag,
                    slot=slot,
                })
            end
        end

        --银行，背包
        for bag=NUM_TOTAL_EQUIPPED_BAG_SLOTS+1, (NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS) do--6-12
            for slot=1, C_Container.GetContainerNumSlots(bag) or 0, 1 do
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if info and info.itemID then
                    table.insert(Tabs, 1, {
                        info=info,
                        bag=bag,
                        slot=slot,
                    })
                end
            end
        end

--材料银行       
    elseif index==2 then
        for _, btn in ReagentBankFrame:EnumerateValidItems() do
            local info, bag, slot= self:GetItemInfo(btn)
            if info then
                table.insert(Tabs, 1, {
                    info=info,
                    bag=bag,
                    slot=slot,
                })
            end
        end

--战团银行   
    elseif index==3 then
        for btn in AccountBankPanel:EnumerateValidItems() do
            local info, bag, slot= self:GetItemInfo(btn)
            if info then
                table.insert(Tabs, 1, {
                    info=info,
                    bag=bag,
                    slot=slot,
                })
            end
        end
    end

    return Tabs
end




function WoWTools_BankMixin:OpenBag(bagID)
    if bagID then
        ToggleBag(bagID)
    else
        for i=1, 7 do
            ToggleBag(i+NUM_TOTAL_EQUIPPED_BAG_SLOTS);
        end
    end
end

function WoWTools_BankMixin:CloseBag(bagID)
    if bagID then
        CloseBag(bagID)
    else
        for i=1, 7 do
            CloseBag(i+NUM_TOTAL_EQUIPPED_BAG_SLOTS);
        end
    end
end


function WoWTools_BankMixin:Set_Background_Texture(texture)
    if texture then
        if self.Save.showBackground then
            texture:SetAtlas('bank-frame-background')
        else
            texture:SetTexture(0)
        end
    end
end