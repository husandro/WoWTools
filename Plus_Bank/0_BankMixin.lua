--[[
    local index= BankFrame.activeTabIndex
	Enum.BankType = {
		Character = 0,
		Guild = 1,
		Account = 2,
	},
]]
WoWTools_BankMixin={}

function WoWTools_BankMixin:GetIndex(index)
    return index or BankFrame.activeTabIndex or 1
end

--local isBank, isReagent, isAccount= WoWTools_BankMixin:GetActive(index)
function WoWTools_BankMixin:GetActive(index)
    index= self:GetIndex(index)

    local isBank= index==1
    local isReagent= index==2 and IsReagentBankUnlocked()
    local isAccount= index==3 --and (not AccountBankPanel.PurchaseTab:IsSelected() and C_Bank.CanPurchaseBankTab(Enum.BankType.Account)--AccountBankPanel.PurchaseTab:IsPurchaseTab()--not C_Bank.CanPurchaseBankTab(Enum.BankType.Account)
    return isBank, isReagent, isAccount
end

--银行，空位
function WoWTools_BankMixin:GetFree(index)
    index= self:GetIndex(index)
    local free, all= 0, 0
    
    local isBank, isReagent, isAccount= self:GetActive(index)
    
    if isBank then
--银行
        for i=1, NUM_BANKGENERIC_SLOTS do--28
            if not BankSlotsFrame["Item"..i].hasItem then--not self:GetItemInfo(BankSlotsFrame["Item"..i]) then
                free=free+1
            end
            all=all+1
        end

        --银行，背包
        for bag=NUM_TOTAL_EQUIPPED_BAG_SLOTS+1, (NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS) do--6-12
            free= free+ (C_Container.GetContainerNumFreeSlots(bag) or 0)
            all= all+ C_Container.GetContainerNumSlots(bag)
        end

--材料银行       
    elseif isReagent then
        for _, btn in ReagentBankFrame:EnumerateValidItems() do
            if not btn.hasItem then--not self:GetItemInfo(btn) then
                free=free+1
            end
            all=all+1
        end
--战团银行   
    elseif isAccount then
        if AccountBankPanel.itemButtonPool:GetNumActive() > 0 then
            for btn in AccountBankPanel:EnumerateValidItems() do
                if not btn.itemInfo then-- not self:GetItemInfo(btn) then
                    free=free+1
                end
                all=all+1
            end
        end
    end

    return free, all
end



function WoWTools_BankMixin:GetBagAndSlot(btn)
    if btn then
        if btn.GetBankTabID then
            return btn:GetBankTabID(), btn:GetContainerSlotID()
        else
            return btn.isBag and Enum.BagIndex.Bankbag
                or btn:GetParent():GetID(),

                btn:GetID()
        end
    end
end

--[[if btn.itemLocation then
            if C_Item.DoesItemExist(btn.itemLocation) then
                btn.itemLocation:Get
            end
        end]]

function WoWTools_BankMixin:GetItemInfo(btn)
        local bag, slot= self:GetBagAndSlot(btn)
        local info= bag and slot and C_Container.GetContainerItemInfo(bag, slot)
        if info and info.itemID then
            return info, bag, slot
        end
end




function WoWTools_BankMixin:GetItems(index)--从最后，到第一
    index= self:GetIndex(index)

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
        for _, btn in ReagentBankFrame:EnumerateItems() do
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
        --if not C_PlayerInfo.HasAccountInventoryLock() then
        if AccountBankPanel.itemButtonPool:GetNumActive() > 0 then
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
    end

    return Tabs
end








--取出，物品

function WoWTools_BankMixin:Take_Item(isOutItem, classID, subClassID, index, onlyTab, checkBagFunc)
    index= self:GetIndex(index)

    local _, isReagent, isAccount= WoWTools_BankMixin:GetActive(index)

    local bankAutoDepositReagents =C_CVar.GetCVarBool('bankAutoDepositReagents')

    local checkAllBag= bankAutoDepositReagents and isAccount or isReagent
    local onlyItem= not checkAllBag
    local onlyRegents= isReagent

    local free= isOutItem
                and WoWTools_BagMixin:GetFree(checkAllBag)--背包，空位
                or WoWTools_BankMixin:GetFree(index)--银行，空位

    local Tabs= isOutItem
                and WoWTools_BankMixin:GetItems(index)--取出银行
                or WoWTools_BagMixin:GetItems(checkAllBag, onlyItem, onlyRegents, checkBagFunc)--放入物品

    local NewTab= {}

    local checkReagent= (bankAutoDepositReagents and isAccount or isReagent) and not classID

    for _, data in pairs(Tabs) do
        if not data.info.isLocked then
            local classID2, subClassID2 = select(6, C_Item.GetItemInfoInstant(data.info.itemID))

            if select(17, C_Item.GetItemInfo(data.info.itemID)) then--商业技能
                if checkReagent
                or (classID==classID2 or not classID) and (subClassID==subClassID2 or not subClassID)
                then
                    data.classID= classID2
                    data.subClassID= subClassID2
                    table.insert(NewTab, data)
                end
            elseif not isReagent then
                if (classID==classID2 or not classID) and (subClassID==subClassID2 or not subClassID) then
                    data.classID= classID2
                    data.subClassID= subClassID2
                    table.insert(NewTab, data)
                end
            end
        end
    end

    if onlyTab then
        return NewTab, free
    end

    local bankType= isAccount and Enum.BankType.Account or Enum.BankType.Character
    local reagentBankOpen= isOutItem or isReagent

    for _, data in pairs(NewTab) do
        if free==0 then
            return
        end
        do
            C_Container.UseContainerItem(data.bag, data.slot, nil, bankType, reagentBankOpen)
        end
        free= free-1
    end
end
--[[NewTab={
    info=,
    bag=,
    slot=,
    classID=
    subClassID=
}]]
















function WoWTools_BankMixin:OpenBag(bagID)
    if bagID then
        if not IsBagOpen(bagID) then
            ToggleBag(bagID)
        end
    else
        for i=1, 7 do
            bagID= i+NUM_TOTAL_EQUIPPED_BAG_SLOTS
            if not IsBagOpen(bagID) then
                ToggleBag(bagID)
            end
        end
    end
end

function WoWTools_BankMixin:CloseBag(bagID)
    if bagID then
        if IsBagOpen(bagID) then
            CloseBag(bagID)
        end
    else
        for i=1, 7 do
            bagID= i+NUM_TOTAL_EQUIPPED_BAG_SLOTS
            if IsBagOpen(bagID) then
                CloseBag(bagID)
            end
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