
local function Save()
    return WoWToolsSave['Plus_GuildBank']
end
local MAX_GUILDBANK_SLOTS_PER_TAB= 98
local StopRun










--提取
local function Check_Bank_Item(tabID, slotID, classID, subClassID, onlyItem)
    local itemLink= GetGuildBankItemLink(tabID, slotID)
    local locked, isFiltered = select(3, GetGuildBankItemInfo(tabID, slotID))

    if locked or isFiltered or not itemLink then
        return
    end

    local itemClassID, itemSubclassID, _, _, _, isCraftingReagent = select(12, C_Item.GetItemInfo(itemLink))
    if
        (classID==itemClassID or not classID)
        and (subClassID==itemSubclassID or not subClassID)
        and ((isCraftingReagent and onlyItem==false) or (onlyItem and not isCraftingReagent))

    then
        return itemLink, itemClassID, itemSubclassID
    end
end






--提取
--numOut 可提取：数字，true无限，false禁用
local function Out_Bank(self, tabID, classID, subClassID, onlyItem, numOut)
    if WoWTools_GuildBankMixin.isInRun then--禁用，按钮移动事件
        StopRun=true--停止，已运行
        return
    end

    WoWTools_GuildBankMixin.isInRun= true
    local itemIndex= 0

    local freeSlots =  WoWTools_BagMixin:GetFree(false)

    if type(numOut)=='number' and numOut>=0 then
        freeSlots= math.min(freeSlots, numOut)
    end

    local saveItemSeconds= Save().saveItemSeconds or 0.8

    local function withdrawItems()
        if
            not self:IsVisible()
            or StopRun
            or GetCurrentGuildBankTab()~= tabID
        then
            StopRun= nil
            WoWTools_GuildBankMixin.isInRun= nil
            print(WoWTools_GuildBankMixin.addName, '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '提取' or WITHDRAW)..'|r', WoWTools_DataMixin.onlyChinese and '中断' or INTERRUPT  )
            return
        end

        local find

        for slotID= MAX_GUILDBANK_SLOTS_PER_TAB, 1, -1 do
            local itemLink= Check_Bank_Item(tabID, slotID, classID, subClassID, onlyItem)
            if itemLink then

                AutoStoreGuildBankItem(tabID, slotID)

                freeSlots = freeSlots - 1
                itemIndex= itemIndex+ 1
                --print(itemIndex, WoWTools_DataMixin.onlyChinese and '提取' or WITHDRAW, itemLink)

                find=true
                break
            end
        end

        if not find or freeSlots <= 0 then
            if freeSlots <= 0  then
                print(WoWTools_GuildBankMixin.addName, '|cffff00ff'..(WoWTools_DataMixin.onlyChinese and '提取' or WITHDRAW)..'|r',  WoWTools_DataMixin.onlyChinese and '中断' or INTERRUPT)
            else
                print(WoWTools_GuildBankMixin.addName, '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '提取' or WITHDRAW)..'|r', WoWTools_DataMixin.onlyChinese and '完成' or COMPLETE )
            end
            StopRun= nil
            WoWTools_GuildBankMixin.isInRun= nil
            return
        end

        C_Timer.After(saveItemSeconds, function()
            withdrawItems()
        end)
    end

    withdrawItems()
end








local function Get_Bank_Num(tabID, classID, subClassID, onlyItem)
    local index=0
    local items={}

    for slotID=1, MAX_GUILDBANK_SLOTS_PER_TAB do
        local itemLink=Check_Bank_Item(tabID, slotID, classID, subClassID, onlyItem)
        if itemLink then
            index= index+ 1
            table.insert(items, {
                tabID= tabID,
                slotID= slotID,
            })
        end
    end

    return index, items
end







































--存放
local function Check_Bag_Item(itemInfo, classID, subClassID, onlyItem)
    if not itemInfo or not itemInfo.itemID then
        return
    end
    local itemClassID, itemSubclassID, _, _, _, isCraftingReagent = select(12, C_Item.GetItemInfo(itemInfo.itemID))

    if itemClassID
        and itemClassID ~= Enum.ItemClass.Questitem
        and not itemInfo.isFiltered
        and not itemInfo.isLocked
        and not itemInfo.isBound
        and (classID==itemClassID or not classID)
        and (subClassID== itemSubclassID or not subClassID)
        and ((isCraftingReagent and onlyItem==false) or (onlyItem and not isCraftingReagent))
    then
        return itemClassID, itemSubclassID
    end
end







--存放
local function Out_Bags(self, tabID, classID, subClassID, onlyItem)
    if WoWTools_GuildBankMixin.isInRun then--禁用，按钮移动事件
        StopRun=true--停止，已运行
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

            itemClassID, itemSubclassID= Check_Bag_Item(itemInfo, classID, subClassID, onlyItem)

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

    local saveItemSeconds= Save().saveItemSeconds or 0.8
    local function depositItems()
        if
           not self:IsVisible()
            or StopRun
            or GetCurrentGuildBankTab()~= tabID
            or InCombatLockdown()
        then
            print(
                itemIndex,
                '|cnWARNING_FONT_COLOR:'
                ..(WoWTools_DataMixin.onlyChinese and '存放' or DEPOSIT)
                ..'|r', WoWTools_DataMixin.onlyChinese and '中断' or INTERRUPT
            )
            StopRun=nil
            WoWTools_GuildBankMixin.isInRun= nil
            return
        end

        local find
        for index, info in pairs(items) do
            C_Container.UseContainerItem(info.bag, info.slot, nil, Enum.BankType.Guild)

            freeSlots = freeSlots- 1
            itemIndex= itemIndex+ 1
            table.remove(items, index)
            --print(itemIndex, WoWTools_DataMixin.onlyChinese and '存放' or DEPOSIT, info.info.hyperlink)

            find=true
            break
        end

        if not find or freeSlots <= 0 then
            if freeSlots <= 0  then
                print(itemIndex, '|cffff00ff'..(WoWTools_DataMixin.onlyChinese and '存放' or DEPOSIT)..'|r',  WoWTools_DataMixin.onlyChinese and '中断' or INTERRUPT )
            else
                print(itemIndex, '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '存放' or DEPOSIT)..'|r', WoWTools_DataMixin.onlyChinese and '完成' or COMPLETE )
            end
            StopRun= nil
            WoWTools_GuildBankMixin.isInRun= nil

            return
        end

        C_Timer.After(saveItemSeconds, function()
            depositItems()
        end)
    end

    depositItems()
end










local function Get_Bag_Num(classID, subClassID, onlyItem)
    local index= 0
    local items= {}
    for bag =0, NUM_BAG_FRAMES+ (onlyItem and 0 or NUM_REAGENTBAG_FRAMES) do
        for slot = C_Container.GetContainerNumSlots(bag), 1, -1 do
            local itemLink= Check_Bag_Item(C_Container.GetContainerItemInfo(bag, slot), classID, subClassID, onlyItem)
            if itemLink then
                index= index+1
                table.insert(items, {
                    slotID= slot,
                    bagID= bag
                })
            end
        end
    end

    return index, items
end










local function Set_ItemList_Tooltip(sub)
    sub:SetTooltip(function(tooltip, desc)
        if not desc.data.items then
            return
        end
        local num= #desc.data.items
        local index=0
        for i, data in pairs(desc.data.items) do
            if data.bagID then
                if C_Container.HasContainerItem(data.bagID, data.slotID) then
                    index= index+1
                    local itemInfo= C_Container.GetContainerItemInfo(data.bagID, data.slotID)
                    if itemInfo then
                        tooltip:AddDoubleLine(
                            '|T'..(itemInfo.iconFileID or 0)..':0|t'
                            ..(
                                WoWTools_HyperLink:CN_Link(itemInfo.hyperlink, {itemID=itemInfo.itemID, isName=true})
                                or itemInfo.itemID
                            )
                            ..' x'..(itemInfo.stackCount==1000 and '1k' or itemInfo.stackCount or 1),

                            index..')'
                        )
                    end
                end
            elseif data.tabID then
                local itemLink= GetGuildBankItemLink(data.tabID, data.slotID)
                local texture, itemCount= GetGuildBankItemInfo(data.tabID, data.slotID)
                if itemLink or texture then
                    index= index+1
                    tooltip:AddDoubleLine(
                        '|T'..(texture or 0)..':0|t'
                        ..(WoWTools_HyperLink:CN_Link(itemLink, {isName=true}) or '')
                        ..' x'..(itemCount==1000 and '1k' or itemCount or 1),

                        index..')'
                    )
                end
            end
            if index>= 20 and num>i and not IsModifierKeyDown() then
                tooltip:AddDoubleLine('|cnGREEN_FONT_COLOR:<Shift>', '|cnGREEN_FONT_COLOR:'..(num-i))
                break
            end
        end
    end)
end












--生成,物品列表
local function Init_SubMenu(self, root, tabID, isOut, numOutorIn, onlyItem, title)
    local sub
--物品
    if onlyItem  then
        for _, classID in pairs({0, 1, 2, 3, 4, 5, 7, 8, 9, 12, 13, 15, 16, 17, 19}) do
            local num, items
            if isOut then
                num, items= Get_Bank_Num(tabID, classID, nil, onlyItem)
            else
                num, items= Get_Bag_Num(classID, nil, onlyItem)
            end

            sub=root:CreateButton(
                (num==0 and '|cff828282' or '')
                ..(classID<10 and ' ' or '')
                ..classID..' '
                ..WoWTools_TextMixin:CN(C_Item.GetItemClassInfo(classID))
                ..' #'..num,
            function(data)
                if isOut then--提取
                    Out_Bank(self, tabID, data.classID, nil, onlyItem, numOutorIn)
                else--存放
                    Out_Bags(self, tabID, data.classID, nil, onlyItem)
                end
                return MenuResponse.Open
            end, {classID=classID, items=items})
            Set_ItemList_Tooltip(sub)
        end
    else
--材料
        for subClassID= 1, 19 do
            local num, items
            if isOut then
                num, items= Get_Bank_Num(tabID, 7, subClassID, onlyItem)
            else
                num, items= Get_Bag_Num(7, subClassID, onlyItem)
            end
            sub=root:CreateButton(
                (num==0 and '|cff828282' or '')
                ..(subClassID<10 and ' ' or '')
                ..subClassID..' '
                ..WoWTools_TextMixin:CN(C_Item.GetItemSubClassInfo(7, subClassID))
                ..' #'..num,
            function(data)
                if isOut then--提取
                    Out_Bank(self, tabID, 7, data.subClassID, onlyItem, numOutorIn)
                else--存放
                    Out_Bags(self, tabID, 7, data.subClassID, onlyItem)
                end
                return MenuResponse.Open
            end, {subClassID=subClassID, items=items})
            Set_ItemList_Tooltip(sub)
        end
    end

    root:CreateDivider()
    root:CreateTitle(title)
end







--提取
--numOut 可提取：数字，true无限，false禁用
local function Init_Out_Bank_Menu(self, root)
    if not self:IsMouseOver() then
        return
    elseif WoWTools_GuildBankMixin.isInRun then--禁用，按钮移动事件
        StopRun=true--停止，已运行
    end

    local tabID= GetCurrentGuildBankTab()
    local numOut= WoWTools_GuildBankMixin:GetNumWithdrawals(tabID)


    local sub, name, num, items
    local disabled= numOut==false

--提取物品
    num, items= Get_Bank_Num(tabID, nil, nil, true)
    name= ((disabled or num==0) and '|cff828282' or '')
        ..'|A:Cursor_OpenHand_32:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '提取物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WITHDRAW, ITEMS))
        ..' #'..num
    sub= root:CreateButton(
       name,
    function(data)
        Out_Bank(self, data.tabID, nil, nil, true, data.numOut)
        return MenuResponse.Open
    end, {tabID=tabID, numOut=numOut, items=items})
    Set_ItemList_Tooltip(sub)

    if not disabled and num>0 then
        Init_SubMenu(self, sub, tabID, true, numOut, true, name)
    end

--提取材料
    num, items= Get_Bank_Num(tabID, nil, nil, false)
    name= ((disabled or num==0) and '|cff828282' or '')
        ..'|A:Cursor_OpenHand_32:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '提取材料' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WITHDRAW, BAG_FILTER_REAGENTS))
        ..' #'..num
    sub= root:CreateButton(
        name,
    function(data)
        Out_Bank(self, data.tabID, nil, nil, false, numOut)
        return MenuResponse.Open
    end, {tabID=tabID, numOut=numOut, items=items})
    Set_ItemList_Tooltip(sub)

    if not disabled and num>0 then
        Init_SubMenu(self, sub, tabID, true, numOut, false, name)
    end
end







--存放
--numIn 是否放入：true, false
local function Init_Out_Bag_Menu(self, root)
    if not self:IsMouseOver() then
        return
    elseif WoWTools_GuildBankMixin.isInRun then--禁用，按钮移动事件
        StopRun=true--停止，已运行
    end

    local tabID= GetCurrentGuildBankTab()
    local _, numIn= WoWTools_GuildBankMixin:GetNumWithdrawals(tabID)


    local sub, name, num, items
    local disabled= numIn==false

--存放物品
    num, items= Get_Bag_Num(nil, nil, true)
    name= ((disabled or num==0) and '|cff828282' or '')
        ..'|A:bag-main:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '存放物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DEPOSIT, ITEMS))
        ..' #'..num
    sub= root:CreateButton(
        name,
    function(data)
        Out_Bags(self, data.tabID, nil, nil, true)
        return MenuResponse.Open
    end, {tabID= tabID, items=items})
    Set_ItemList_Tooltip(sub)
    --sub:SetEnabled(numIn and true or nil)

    if not disabled and num>0 then
        Init_SubMenu(self, sub, tabID, false, numIn, true, name)
    end

--存放材料
    num, items= Get_Bag_Num(nil, nil, false)
    name= ((disabled or num==0) and '|cff828282' or '')
        ..'|A:bag-main:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '存放材料' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DEPOSIT, BAG_FILTER_REAGENTS))
        ..' #'..num
    sub= root:CreateButton(
        name,
    function(data)
        Out_Bags(self, data.tabID, nil, nil, false)
        return MenuResponse.Open
    end, {tabID= tabID, items=items})
    Set_ItemList_Tooltip(sub)
    --sub:SetEnabled(numIn and true or nil)

    if not disabled and num>0 then
        Init_SubMenu(self, sub, tabID, false, numIn, false, name)
    end
end


















--[[numOut 可提取：数字，true无限，false禁用
--numIn 是否放入：true, false

local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    elseif WoWTools_GuildBankMixin.isInRun then--禁用，按钮移动事件
        StopRun=true--停止，已运行
    end

    local tabID= GetCurrentGuildBankTab()
    local numOut, numIn= WoWTools_GuildBankMixin:GetNumWithdrawals(tabID)

--物品
    Init_Out_Bank_Menu(self, root, tabID, numOut)

--材料
    root:CreateDivider()
    Init_Out_Bag_Menu(self, root, tabID, numIn)

--打开选项
    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name= WoWTools_GuildBankMixin.addName})
end]]





local function Init()
    local btn= WoWTools_ButtonMixin:Menu(GuildBankFrame, {atlas='bag-main'})
    btn:SetPoint('RIGHT', GuildItemSearchBox, 'LEFT', -8, 0)

    btn:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')

        GameTooltip:SetText(
            WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_DataMixin.onlyChinese and '存放' or BANK_DEPOSIT_MONEY_BUTTON_LABEL)
            ..'|A:dressingroom-button-appearancelist-up:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)
            ..WoWTools_DataMixin.Icon.left
            ..'|cnGREEN_FONT_COLOR:'
            ..(Save().saveItemSeconds or 0.8)
        )
        GameTooltip:Show()
    end)
    btn:SetupMenu(Init_Out_Bag_Menu)


    local btn2= WoWTools_ButtonMixin:Menu(GuildBankFrame, {
        atlas='Cursor_OpenHand_32',
        name='WoWToolsGuildBankOutMenuButton',
    })
    btn2:SetPoint('RIGHT', btn, 'LEFT', -2, 0)

    btn2:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)
    btn2:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')

        GameTooltip:SetText(
            WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_DataMixin.onlyChinese and '提取' or WITHDRAW)
            ..'|A:dressingroom-button-appearancelist-up:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)
            ..WoWTools_DataMixin.Icon.left
            ..'|cnGREEN_FONT_COLOR:'
            ..(Save().saveItemSeconds or 0.8)
        )
        GameTooltip:Show()
    end)
    btn2:SetupMenu(Init_Out_Bank_Menu)

    Init=function()end
end








function WoWTools_GuildBankMixin:Init_InOut_Item()
    Init()
end