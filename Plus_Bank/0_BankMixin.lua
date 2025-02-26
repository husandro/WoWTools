--[[
    local index= BankFrame.activeTabIndex
	Enum.BankType = {
		Character = 0,
		Guild = 1,
		Account = 2,
	},
]]
WoWTools_BankMixin={}

--local isBank, isReagent, isAccount= WoWTools_BankMixin:GetActive(index)
function WoWTools_BankMixin:GetActive(index)
    index= index or BankFrame.activeTabIndex

    local isBank= index==1
    local isReagent= index==2 and IsReagentBankUnlocked()
    local isAccount= index==3 and not AccountBankPanel.PurchaseTab:IsPurchaseTab()--not C_Bank.CanPurchaseBankTab(Enum.BankType.Account)
    return isBank, isReagent, isAccount
end

--银行，空位
function WoWTools_BankMixin:GetFree(index)
    local free= 0
    local isBank, isReagent, isAccount= self:GetActive(index)

    if isBank then
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
    elseif isReagent then
        for _, btn in ReagentBankFrame:EnumerateValidItems() do
            if not self:GetItemInfo(btn) then
                free=free+1
            end
        end

--战团银行   
    elseif isAccount then
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
    local isBank, isReagent, isAccount= WoWTools_BankMixin:GetActive(index)

    if isBank then
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
    elseif isReagent then
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
    elseif isAccount then
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



--取出，物品
function WoWTools_BankMixin:Take_Item(isOutItem, classID, subClassID, activeTabIndex)
    if self.isRun then
        return
    end
    self.isRun= true

    activeTabIndex= activeTabIndex or BankFrame.activeTabIndex

    local isBank= activeTabIndex==1
    local isReagent= activeTabIndex==2
    local isAccount= activeTabIndex==3
    local bankAutoDepositReagents= C_CVar.GetCVarBool('bankAutoDepositReagents')

    local reagentBankOpen= classID==7
                        or isReagent
                        or (bankAutoDepositReagents and isAccount)
                        or (isBank and isOutItem)

    local bankType= isAccount and Enum.BankType.Account or Enum.BankType.Character

    local free= isOutItem
            and WoWTools_BagMixin:GetFree(reagentBankOpen)--背包，空位
            or WoWTools_BankMixin:GetFree(activeTabIndex)--银行，空位

    local Tabs= isOutItem
        and WoWTools_BankMixin:GetItems(activeTabIndex)--取出银行
        or WoWTools_BagMixin:GetItems(reagentBankOpen)--放入物品

    if free==0 or not Tabs then
        self.isRun=nil
        return
    end


    for _, data in pairs(Tabs) do
        if IsModifierKeyDown() or free<=0 then
            self.isRun=nil
            return
        end
        do
            if not data.info.isLocked then
                local bag, slot
                --local classID2, subClassID2 = select(6, C_Item.GetItemInfoInstant(data.info.itemID))
                local classID2, subClassID2, _, _, _, isCraftingReagent2 = select(12, C_Item.GetItemInfo(data.info.hyperlink or data.info.itemID))
                if isCraftingReagent2 then
                    if reagentBankOpen then
                        bag, slot= data.bag, data.slot
                    end
                elseif not isReagent then
                    if (classID==classID2 or not classID) and (subClassID==subClassID2 or not subClassID) then
                        bag, slot= data.bag, data.slot
                    end
                end
                if bag and slot then
                    C_Container.UseContainerItem(bag, slot, nil, bankType, reagentBankOpen)
                    free= free-1
                end
            end
        end
    end
    self.isRun=nil
end

