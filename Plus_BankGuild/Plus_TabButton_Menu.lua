local e= select(2, ...)
local MAX_GUILDBANK_SLOTS_PER_TAB= 96








local function Set_Tooltip(tooltip, desc)
    --for _, info in pairs(desc.data.items or {}) do

    --end
end










--提取
local function Check_Bank(tabID, slotID, classID, subClassID, onlyItem)
    local itemClassID, itemSubclassID, _, isCraftingReagent
    local itemLink= GetGuildBankItemLink(tabID, slotID)
    local locked, isFiltered = select(3, GetGuildBankItemInfo(tabID, slotID))
    if locked or isFiltered or not itemLink then
        return
    end

    itemClassID, itemSubclassID, _, _, _, isCraftingReagent = select(12, C_Item.GetItemInfo(itemLink))

    if
        (classID==itemClassID or not classID)
        and (subClassID==subClassID or not subClassID)
        and (onlyItem and not isCraftingReagent or not onlyItem)
        
    then
        return itemLink, itemClassID, itemSubclassID
    end
end







--提取
local function Out_Bank(self, tabID, classID, subClassID, onlyItem)
    if WoWTools_GuildBankMixin.isInRun then--禁用，按钮移动事件
        self.isInRun=true--停止，已运行
        return
    end
    
    WoWTools_GuildBankMixin.isInRun= true
    local freeSlots =  WoWTools_BagMixin:GetFree(false)
    local itemIndex= 0

    local function withdrawItems()
        if 
            not self:IsVisible()
            or self.isInRun
            or GetCurrentGuildBankTab()~= tabID
        then
            self.isInRun= nil
            WoWTools_GuildBankMixin.isInRun= nil
            print(itemIndex..')', '|cnRED_FONT_COLOR:'..(e.onlyChinese and '提取' or WITHDRAW)..'|r', e.onlyChinese and '中断' or INTERRUPT  )
            return
        end

        local find

        for slotID= MAX_GUILDBANK_SLOTS_PER_TAB, 1, -1 do
            local itemLink= Check_Bank(tabID, slotID, classID, subClassID, onlyItem)
            if itemLink then

                AutoStoreGuildBankItem(tabID, slotID)

                print(e.onlyChinese and '提取' or WITHDRAW, itemLink)

                freeSlots = freeSlots - 1
                itemIndex= itemIndex+ 1

                find=true
                break
            end
        end
     
        if not find or freeSlots <= 0 then
            if freeSlots <= 0  then
                print(itemIndex..')', '|cffff00ff'..(e.onlyChinese and '提取' or WITHDRAW)..'|r', e.onlyChinese and '背包已满' or SPELL_FAILED_CUSTOM_ERROR_1059 )
            else
                print(itemIndex..')', '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '提取' or WITHDRAW)..'|r', e.onlyChinese and '完成' or COMPLETE )
            end
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
        --return MenuResponse.Open
    end, {tabID= tabID})
    sub:SetTooltip(Set_Tooltip)

    sub= root:CreateButton(
        (e.onlyChinese and '提取材料' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WITHDRAW, BAG_FILTER_REAGENTS))
        ..' #'..numReagent,
    function(data)
        Out_Bank(self, data.tabID, nil, false)
        --return MenuResponse.Open
    end, {tabID= tabID})
    sub:SetTooltip(Set_Tooltip)
end




















--存放
local function Check_Bag(itemInfo, classID, subClassID, onlyItem)
    if not itemInfo or not itemInfo.itemID then
        return
    end
    local itemClassID, itemSubClass= select(12, C_Item.GetItemInfo(itemInfo.itemID))

    if itemClassID
        and itemClassID ~= Enum.ItemClass.Questitem
        and not itemInfo.isFiltered
        and not itemInfo.isLocked
        and not itemInfo.isBound
        and (classID==itemClassID or not classID)
        and (subClassID== itemSubClass or not subClassID)
        and (onlyItem and not select(17, C_Item.GetItemInfo(itemInfo.itemID)) or not onlyItem)
    then
        return itemClassID, itemSubClass
    end
end



--存放
local function In_Bags(self, tabID, classID, subClassID, onlyItem)
    if WoWTools_GuildBankMixin.isInRun then--禁用，按钮移动事件
        self.isInRun=true--停止，已运行
        return
    end

    WoWTools_GuildBankMixin.isInRun= true

    local freeSlots = WoWTools_GuildBankMixin:GetFree(tabID)
    local itemInfo, itemClassID, itemSubclassID
    local items={}
    local itemIndex=0

    for bag =0, NUM_BAG_FRAMES+ (onlyItem and 0 or NUM_REAGENTBAG_FRAMES) do
        for slot = C_Container.GetContainerNumSlots(bag), 1, -1 do

            itemInfo= C_Container.GetContainerItemInfo(bag, slot)

            itemClassID, itemSubclassID= Check_Bag(itemInfo, classID, subClassID, onlyItem)

            if itemClassID then
                table.insert(items, {
                    info= itemInfo,
                    bag= bag,
                    slot= slot,
                    classID= itemClassID,
                    subClassID= itemSubclassID
                })
            end
        end
    end

    table.sort(items, function(a, b)
        if a.classID== b.classID then
            if a.subClassID== b.subClassID then
                if a.info.quality== b.info.quality then
                    return a.info.iconFileID> b.info.iconFileID
                else
                    return a.info.quality<b.info.quality
                end
            else
                return a.subClassID < b.subClassID
            end
        else
            return a.classID<b.classID
        end
    end)


    local function depositItems()
        if
           not self:IsVisible()
            or self.isInRun
            or GetCurrentGuildBankTab()~= tabID
        then
            print(itemIndex..')', '|cnRED_FONT_COLOR:'..(e.onlyChinese and '存放' or DEPOSIT)..'|r', e.onlyChinese and '中断' or INTERRUPT  )
            self.isInRun=nil
            WoWTools_GuildBankMixin.isInRun= nil
            return
        end

        local find
        for index, info in pairs(items) do
            C_Container.UseContainerItem(info.bag, info.slot, nil, Enum.BankType.Guild)

            print(itemIndex, e.onlyChinese and '存放' or DEPOSIT, info.info.hyperlink)

            freeSlots = freeSlots- 1
            itemIndex= itemIndex+ 1
            table.remove(items, index)

            find=true
            break
        end

        if not find or freeSlots <= 0 then
            if freeSlots <= 0  then
                print(itemIndex..')', '|cffff00ff'..(e.onlyChinese and '存放' or DEPOSIT)..'|r', e.onlyChinese and '你的银行已满' or ERR_BANK_FULL )
            else
                print(itemIndex..')', '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '存放' or DEPOSIT)..'|r', e.onlyChinese and '完成' or COMPLETE )
            end
            self.isInRun= nil
            WoWTools_GuildBankMixin.isInRun= nil

            return
        end

        C_Timer.After(0.8, function()
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
        return Check_Bag(itemInfo, nil )
    end)
    local regents= WoWTools_BagMixin:GetItems(true, false, true, function(_, _, itemInfo)
        return Check_Bag(itemInfo)
    end)


    sub= root:CreateButton(
        (e.onlyChinese and '存放物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DEPOSIT, ITEMS))
        ..' #'..#items,
    function(data)
        In_Bags(self, data.tabID, nil, true)
        --return MenuResponse.Open
    end, {tabID= tabID, items=items})
    sub:SetTooltip(Set_Tooltip)


    sub= root:CreateButton(
        (e.onlyChinese and '存放材料' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DEPOSIT, BAG_FILTER_REAGENTS))
        ..' #'..#regents,
    function(data)
        In_Bags(self, data.tabID, nil, false)
        --return MenuResponse.Open

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