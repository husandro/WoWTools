local e= select(2, ...)
local MAX_GUILDBANK_SLOTS_PER_TAB= 96



local function Check_Bag_Item(itemInfo, classID, onlyItem)
    local itemClassID = itemInfo and itemInfo.itemID and select(12, C_Item.GetItemInfo(itemInfo.itemID))

    return itemClassID
        and itemClassID ~= Enum.ItemClass.Questitem
        and not itemInfo.isFiltered
        and not itemInfo.isLocked
        and not itemInfo.isBound
        and (classID==itemClassID or not classID)
        and (not onlyItem and select(17, C_Item.GetItemInfo(itemInfo.itemID)) or onlyItem)
end



local function Check_Bank_Item(tabID, slotID, classID, onlyItem)
    local itemClassID, _, isCraftingReagent
    local itemLink= GetGuildBankItemLink(tabID, slotID)
    local locked, isFiltered = select(3, GetGuildBankItemInfo(tabID, slotID))
    if locked or isFiltered or not itemLink then
        return
    end

    itemClassID, _, _, _, _, isCraftingReagent = select(12, C_Item.GetItemInfo(itemLink))

    if (classID==itemClassID or not classID) and (not onlyItem and isCraftingReagent or onlyItem) then
        return itemLink
    end
end



local function Set_Tooltip(tooltip, desc)
    --for _, info in pairs(desc.data.items or {}) do

    --end
end















--提取
local function Out_Bank(self, tabID, classID, onlyItem)
    if WoWTools_GuildBankMixin.isInRun then--禁用，按钮移动事件
        self.isInRun=true--停止，已运行
        return
    end

    local freeSlots =  WoWTools_BagMixin:GetFree(false)
    WoWTools_GuildBankMixin.isInRun= true

    local function withdrawItems()
        if
            freeSlots <= 0
            or not self:IsVisible()
            or self.isInRun
            or GetCurrentGuildBankTab()~= tabID
        then
            self.isInRun= nil
            WoWTools_GuildBankMixin.isInRun= nil
            return
        end

        local find

        for slotID= MAX_GUILDBANK_SLOTS_PER_TAB, 1, -1 do
            local itemLink= Check_Bank_Item(tabID, slotID, classID, onlyItem)
            if itemLink then

                AutoStoreGuildBankItem(tabID, slotID)
                print(e.onlyChinese and '提取' or WITHDRAW, itemLink)

                freeSlots = freeSlots - 1
                find=true
                break
            end
        end

        if not find then
            self.isInRun= nil
            WoWTools_GuildBankMixin.isInRun= nil
            return
        end

        C_Timer.After(0.8, function()
            withdrawItems()
        end)
    end

    withdrawItems()
end










--提取
local function Init_Out_Menu(self, root, tabID)
    local sub
   
    local bankItems= select(2, WoWTools_GuildBankMixin:GetFree(tabID))
    local numBankItem= 0
    local numReagent= 0
    for _, info in pairs(bankItems) do
        if select(17, C_Item.GetItemInfo(info.itemLink)) then
            numBankItem= numBankItem+1
        else
            numReagent= numReagent +1
        end
    end

    sub= root:CreateButton(
        (e.onlyChinese and '提取物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WITHDRAW, ITEMS))
        ..' #'..numBankItem,
    function(data)
        Out_Bank(self, data.tabID, nil, true)
        return MenuResponse.Open
    end, {tabID= tabID})
    sub:SetTooltip(Set_Tooltip)

    sub= root:CreateButton(
        (e.onlyChinese and '提取材料' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WITHDRAW, BAG_FILTER_REAGENTS))
        ..' #'..numReagent,
    function(data)
        Out_Bank(self, data.tabID, nil, false)
        return MenuResponse.Open
    end, {tabID= tabID})
    sub:SetTooltip(Set_Tooltip)
end

















--存放
local function In_Bags(self, tabID, classID, onlyItem)
    if WoWTools_GuildBankMixin.isInRun then--禁用，按钮移动事件
        self.isInRun=true--停止，已运行
        return
    end

    local freeSlots = WoWTools_GuildBankMixin:GetFree(tabID)
    local num= NUM_BAG_FRAMES+ (onlyItem and 0 or NUM_REAGENTBAG_FRAMES)
    WoWTools_GuildBankMixin.isInRun= true

    local function depositItems()
        if
            freeSlots <= 0
            or not self:IsVisible()
            or self.isInRun
            or GetCurrentGuildBankTab()~= tabID
        then
            self.isInRun=nil
            WoWTools_GuildBankMixin.isInRun= nil
            return
        end

        local find
        for bag = num, 0, -1 do
            for slot = C_Container.GetContainerNumSlots(bag), 1, -1 do
                local itemInfo= C_Container.GetContainerItemInfo(bag, slot)
                if Check_Bag_Item(itemInfo, classID, onlyItem) then

                    C_Container.UseContainerItem(bag, slot, nil, Enum.BankType.Guild)
                    print(e.onlyChinese and '存放' or DEPOSIT, itemInfo.hyperlink)

                    freeSlots = freeSlots - 1
                    find=true
                    break
                end
            end
            if find then
                break
            end
        end

        if not find then
            self.isInRun= nil
            WoWTools_GuildBankMixin.isInRun= nil
            return
        end

        C_Timer.After(0.6, function()
            depositItems()
        end)
    end

    depositItems()
end










--存放
local function Init_In_Menu(self, root, tabID)
    local tabs={}
    local sub

    for bag= BACKPACK_CONTAINER, NUM_BAG_FRAMES+ NUM_REAGENTBAG_FRAMES do--0-5
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)

        end
    end


    local items= WoWTools_BagMixin:GetItems(false, true, false, function(_, _, itemInfo)
        return Check_Bag_Item(itemInfo, nil )
    end)
    local regents= WoWTools_BagMixin:GetItems(true, false, true, function(_, _, itemInfo)
        return Check_Bag_Item(itemInfo)
    end)


    sub= root:CreateButton(
        (e.onlyChinese and '存放物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DEPOSIT, ITEMS))
        ..' #'..#items,
    function(data)
        In_Bags(self, data.tabID, nil, true)
        return MenuResponse.Open
    end, {tabID= tabID, items=items})
    sub:SetTooltip(Set_Tooltip)


    sub= root:CreateButton(
        (e.onlyChinese and '存放材料' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DEPOSIT, BAG_FILTER_REAGENTS))
        ..' #'..#regents,
    function(data)
        In_Bags(self, data.tabID, nil, false)
        return MenuResponse.Open

    end, {tabID= tabID, items=items})
    sub:SetTooltip(Set_Tooltip)
end







function WoWTools_GuildBankMixin:Set_TabButton_Menu(btn)
    btn:SetupMenu(function(frame, root)
        local tabID= GetCurrentGuildBankTab()
        Init_Out_Menu(frame, root, tabID)
        root:CreateDivider()
        Init_In_Menu(frame, root, tabID)
    end)
end