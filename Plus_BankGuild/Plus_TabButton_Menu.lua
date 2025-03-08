local e= select(2, ...)
local MAX_GUILDBANK_SLOTS_PER_TAB= 96




--生成,物品列表
local function Init_Button_List(isReagent)
    if not isReagent  then
        for index, classID in pairs({0, 1, 2, 3, 4, 5, 7, 8, 9, 12, 13, 15, 16, 17, 19}) do
            
        end
    else
        for index= 1, 19 do
        end
    end
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
--numOut 可提取：数字，true无限，false禁用
local function Out_Bank(self, tabID, classID, subClassID, onlyItem, numOut)
    if WoWTools_GuildBankMixin.isInRun then--禁用，按钮移动事件
        self.isInRun=true--停止，已运行
        return
    end

    WoWTools_GuildBankMixin.isInRun= true
    local itemIndex= 0

    local freeSlots =  WoWTools_BagMixin:GetFree(false)

    if type(numOut)=='number' then
        freeSlots= math.min(freeSlots, numOut)
    end

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

                freeSlots = freeSlots - 1
                itemIndex= itemIndex+ 1
                print(itemIndex, e.onlyChinese and '提取' or WITHDRAW, itemLink)

                find=true
                break
            end
        end

        if not find or freeSlots <= 0 then
            if freeSlots <= 0  then
                print(itemIndex..')', '|cffff00ff'..(e.onlyChinese and '提取' or WITHDRAW)..'|r', e.onlyChinese and '背包已满' or SPELL_FAILED_CUSTOM_ERROR_1059)
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








local function Get_Bank(tabID, classID, subClassID, onlyItem)
    local index=0

    for slotID= MAX_GUILDBANK_SLOTS_PER_TAB, 1, -1 do
        if Check_Bank(tabID, slotID, classID, subClassID, onlyItem) then
            index= index+ 1
        end
    end

    return index
end







--提取
--numOut 可提取：数字，true无限，false禁用
local function Init_Out_Menu(self, root, tabID, numOut)
    local sub

    sub= root:CreateButton(
        (e.onlyChinese and '提取物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WITHDRAW, ITEMS))
        ..' #'..Get_Bank(tabID, nil, nil, true),
    function(data)
        Out_Bank(self, data.tabID, nil, true, data.numOut)
    end, {tabID= tabID, numOut=numOut})
    sub:SetEnabled(numOut)


    sub= root:CreateButton(
        (e.onlyChinese and '提取材料' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WITHDRAW, BAG_FILTER_REAGENTS))
        ..' #'..Get_Bank(tabID, nil, nil, false),
    function(data)
        Out_Bank(self, data.tabID, nil, false, numOut)
    end, {tabID=tabID, numOut=numOut})
    sub:SetEnabled(numOut)
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
    local itemIndex=0
    local items= {}

    local itemInfo, itemClassID, itemSubclassID
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

            freeSlots = freeSlots- 1
            itemIndex= itemIndex+ 1
            table.remove(items, index)
            print(itemIndex, e.onlyChinese and '存放' or DEPOSIT, info.info.hyperlink)

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








local function Get_Bag(classID, subClassID, onlyItem)
    local index= 0

    for bag =0, NUM_BAG_FRAMES+ (onlyItem and 0 or NUM_REAGENTBAG_FRAMES) do
        for slot = C_Container.GetContainerNumSlots(bag), 1, -1 do
            if Check_Bag(C_Container.GetContainerItemInfo(bag, slot),
                    classID, subClassID, onlyItem
                )
            then
                index= index+1
            end
        end
    end

    return index
end








--存放
--numIn 是否放入：true, false
local function Init_In_Menu(self, root, tabID, numIn)
    local sub

    sub= root:CreateButton(
        (e.onlyChinese and '存放物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DEPOSIT, ITEMS))
        ..' #'..Get_Bag(nil, nil, true),
    function(data)
        In_Bags(self, data.tabID, nil, true)
    end, {tabID= tabID})
    sub:SetEnabled(numIn)

    sub= root:CreateButton(
        (e.onlyChinese and '存放材料' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DEPOSIT, BAG_FILTER_REAGENTS))
        ..' #'..Get_Bag(nil, nil, false),
    function(data)
        In_Bags(self, data.tabID, nil, false)
    end, {tabID= tabID})
    sub:SetEnabled(numIn)

end
























function WoWTools_GuildBankMixin:Set_TabButton_Menu(btn)
    btn:SetupMenu(function(frame, root)
        if WoWTools_GuildBankMixin.isInRun then--禁用，按钮移动事件
            frame.isInRun=true--停止，已运行
        end



        local tabID= GetCurrentGuildBankTab()
        
        local numOut, numIn= WoWTools_GuildBankMixin:GetNumWithdrawals(tabID)

        Init_Out_Menu(frame, root, tabID, numOut)
        root:CreateDivider()
        Init_In_Menu(frame, root, tabID, numIn)
    end)
end