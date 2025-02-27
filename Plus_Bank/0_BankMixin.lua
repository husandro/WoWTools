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
    return index or BankFrame.activeTabIndex
end

--local isBank, isReagent, isAccount= WoWTools_BankMixin:GetActive(index)
function WoWTools_BankMixin:GetActive(index)
    index= self:GetIndex(index)

    local isBank= index==1
    local isReagent= index==2 and IsReagentBankUnlocked()
    local isAccount= index==3 and not AccountBankPanel.PurchaseTab:IsPurchaseTab()--not C_Bank.CanPurchaseBankTab(Enum.BankType.Account)
    return isBank, isReagent, isAccount
end

--银行，空位
function WoWTools_BankMixin:GetFree(index)
    index= self:GetIndex(index)
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








--取出，物品
function WoWTools_BankMixin:Take_Item(isOutItem, classID, subClassID, index, onlyTab)
    index= self:GetIndex(index)

    local isBank, isReagent, isAccount= WoWTools_BankMixin:GetActive(index)

    local bankAutoDepositReagents= C_CVar.GetCVarBool('bankAutoDepositReagents')

    local reagentBankOpen= isReagent or isOutItem--材料银行
                        or (
                            (classID==7 and subClassID~=11)--仅限商业技能
                            --or (isBank and not isOutItem)--银行
                            or (isAccount and bankAutoDepositReagents)
                        )

    local bankType= isAccount and Enum.BankType.Account or Enum.BankType.Character

    local free= isOutItem
                and WoWTools_BagMixin:GetFree(reagentBankOpen)--背包，空位
                or WoWTools_BankMixin:GetFree(index)--银行，空位

    local Tabs= isOutItem
                and WoWTools_BankMixin:GetItems(index)--取出银行
                or WoWTools_BagMixin:GetItems(reagentBankOpen)--放入物品

    local NewTab= {}

    for _, data in pairs(Tabs) do
        if not data.info.isLocked then
            local classID2, subClassID2 = select(6, C_Item.GetItemInfoInstant(data.info.itemID))
            if select(17, C_Item.GetItemInfo(data.info.itemID)) then--商业技能
                if reagentBankOpen and (classID==classID2 or not classID) and (subClassID==subClassID2 or not subClassID) then
                    data.classID= classID2
                    data.subClassID= subClassID2
                    table.insert(NewTab, data)
                    --table.insert(NewTab, {info=data.info, bag=data.bag, slot=data.slot, classID= classID2, subClassID=subClassID2})
                end
            elseif not isReagent then
                if (classID==classID2 or not classID) and (subClassID==subClassID2 or not subClassID) then
                    data.classID= classID2
                    data.subClassID= subClassID2
                    table.insert(NewTab, data)
                    --table.insert(NewTab, {info=data.info, bag=data.bag, slot=data.slot, classID= classID2, subClassID=subClassID2})
                end
            end
        end
    end

    if onlyTab then
        return NewTab
    end


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