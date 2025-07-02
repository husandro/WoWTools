
local function Save()
    return WoWToolsSave['Plus_GuildBank']
end
local MAX_GUILDBANK_SLOTS_PER_TAB= 98











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
        self.isInRun=true--停止，已运行
        return
    end

    WoWTools_GuildBankMixin.isInRun= true
    local itemIndex= 0

    local freeSlots =  WoWTools_BagMixin:GetFree(false)

    if type(numOut)=='number' then
        freeSlots= math.min(freeSlots, numOut)
    end

    local saveItemSeconds= Save().saveItemSeconds or 0.8

    local function withdrawItems()
        if
            not self:IsVisible()
            or self.isInRun
            or GetCurrentGuildBankTab()~= tabID
        then
            self.isInRun= nil
            WoWTools_GuildBankMixin.isInRun= nil
            print(WoWTools_GuildBankMixin.addName, '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '提取' or WITHDRAW)..'|r', WoWTools_DataMixin.onlyChinese and '中断' or INTERRUPT  )
            return
        end

        local find

        for slotID= MAX_GUILDBANK_SLOTS_PER_TAB, 1, -1 do
            local itemLink= Check_Bank_Item(tabID, slotID, classID, subClassID, onlyItem)
            if itemLink then

                AutoStoreGuildBankItem(tabID, slotID)

                freeSlots = freeSlots - 1
                itemIndex= itemIndex+ 1
                print(itemIndex, WoWTools_DataMixin.onlyChinese and '提取' or WITHDRAW, itemLink)

                find=true
                break
            end
        end

        if not find or freeSlots <= 0 then
            if freeSlots <= 0  then
                print(WoWTools_GuildBankMixin.addName, '|cffff00ff'..(WoWTools_DataMixin.onlyChinese and '提取' or WITHDRAW)..'|r', WoWTools_DataMixin.onlyChinese and '背包已满' or SPELL_FAILED_CUSTOM_ERROR_1059)
            else
                print(WoWTools_GuildBankMixin.addName, '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '提取' or WITHDRAW)..'|r', WoWTools_DataMixin.onlyChinese and '完成' or COMPLETE )
            end
            self.isInRun= nil
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

    for slotID=1, MAX_GUILDBANK_SLOTS_PER_TAB do
        if Check_Bank_Item(tabID, slotID, classID, subClassID, onlyItem) then
            index= index+ 1
        end
    end

    return index
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
            or self.isInRun
            or GetCurrentGuildBankTab()~= tabID
            or InCombatLockdown()
        then
            print(
                itemIndex,
                '|cnRED_FONT_COLOR:'
                ..(WoWTools_DataMixin.onlyChinese and '存放' or DEPOSIT)
                ..'|r', WoWTools_DataMixin.onlyChinese and '中断' or INTERRUPT
            )
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
            print(itemIndex, WoWTools_DataMixin.onlyChinese and '存放' or DEPOSIT, info.info.hyperlink)

            find=true
            break
        end

        if not find or freeSlots <= 0 then
            if freeSlots <= 0  then
                print(itemIndex, '|cffff00ff'..(WoWTools_DataMixin.onlyChinese and '存放' or DEPOSIT)..'|r', WoWTools_DataMixin.onlyChinese and '你的银行已满' or ERR_BANK_FULL )
            else
                print(itemIndex, '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '存放' or DEPOSIT)..'|r', WoWTools_DataMixin.onlyChinese and '完成' or COMPLETE )
            end
            self.isInRun= nil
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

    for bag =0, NUM_BAG_FRAMES+ (onlyItem and 0 or NUM_REAGENTBAG_FRAMES) do
        for slot = C_Container.GetContainerNumSlots(bag), 1, -1 do
            if Check_Bag_Item(C_Container.GetContainerItemInfo(bag, slot), classID, subClassID, onlyItem) then
                index= index+1
            end
        end
    end

    return index
end























--生成,物品列表
local function Init_SubMenu(self, root, tabID, isOut, numOutorIn, onlyItem, title)
    local num
--物品
    if onlyItem  then
        for _, classID in pairs({0, 1, 2, 3, 4, 5, 7, 8, 9, 12, 13, 15, 16, 17, 19}) do
            num= isOut and Get_Bank_Num(tabID, classID, nil, onlyItem)
                        or Get_Bag_Num(classID, nil, onlyItem)
            root:CreateButton(
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
            end, {classID=classID})
        end
    else
--材料
        for subClassID= 1, 19 do
            num= isOut and Get_Bank_Num(tabID, 7, subClassID, onlyItem)
                        or Get_Bag_Num(7, subClassID, onlyItem)
            root:CreateButton(
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
            end, {subClassID=subClassID})
        end
    end

    root:CreateDivider()
    root:CreateTitle(title)
end







--提取
--numOut 可提取：数字，true无限，false禁用
local function Init_Out_Bank_Menu(self, root, tabID, numOut)
    local sub, name, num
    local disabled= numOut==false

--提取物品
    num= Get_Bank_Num(tabID, nil, nil, true)
    name= ((disabled or num==0) and '|cff828282' or '')
        ..'|A:Cursor_OpenHand_32:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '提取物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WITHDRAW, ITEMS))
        ..' #'..num
    sub= root:CreateButton(
       name,
    function(data)
        Out_Bank(self, data.tabID, nil, nil, true, data.numOut)
        return MenuResponse.Close
    end, {tabID= tabID, numOut=numOut})
    sub:SetEnabled(numOut)

    if not disabled and num>0 then
        Init_SubMenu(self, sub, tabID, true, numOut, true, name)
    end
        
--提取材料
    num= Get_Bank_Num(tabID, nil, nil, false)
    name= ((disabled or num==0) and '|cff828282' or '')
        ..'|A:Cursor_OpenHand_32:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '提取材料' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WITHDRAW, BAG_FILTER_REAGENTS))
        ..' #'..num
    sub= root:CreateButton(
        name,
    function(data)
        Out_Bank(self, data.tabID, nil, nil, false, numOut)
        return MenuResponse.Close
    end, {tabID=tabID, numOut=numOut})
    sub:SetEnabled(numOut)

    if not disabled and num>0 then
        Init_SubMenu(self, sub, tabID, true, numOut, false, name)
    end
end







--存放
--numIn 是否放入：true, false
local function Init_Out_Bag_Menu(self, root, tabID, numIn)
    local sub, name, num
    local disabled= numIn==false

--存放物品
    num= Get_Bag_Num(nil, nil, true)
    name= ((disabled or num==0) and '|cff828282' or '')
        ..'|A:Banker:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '存放物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DEPOSIT, ITEMS))
        ..' #'..num
    sub= root:CreateButton(
        name,
    function(data)
        Out_Bags(self, data.tabID, nil, nil, true)
        return MenuResponse.Close
    end, {tabID= tabID})
    sub:SetEnabled(numIn)

    if not disabled and num>0 then
        Init_SubMenu(self, sub, tabID, false, numIn, true, name)
    end

--存放材料
    num= Get_Bag_Num(nil, nil, false)
    name= ((disabled or num==0) and '|cff828282' or '')
        ..'|A:Banker:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '存放材料' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DEPOSIT, BAG_FILTER_REAGENTS))
        ..' #'..num
    sub= root:CreateButton(
        name,
    function(data)
        Out_Bags(self, data.tabID, nil, nil, false)
        return MenuResponse.Close
    end, {tabID= tabID})
    sub:SetEnabled(numIn)

    if not disabled and num>0 then
        Init_SubMenu(self, sub, tabID, false, numIn, false, name)
    end
end


















--numOut 可提取：数字，true无限，false禁用
--numIn 是否放入：true, false

local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    elseif WoWTools_GuildBankMixin.isInRun then--禁用，按钮移动事件
        self.isInRun=true--停止，已运行
    end

    local tabID= GetCurrentGuildBankTab()
    local numOut, numIn= WoWTools_GuildBankMixin:GetNumWithdrawals(tabID)
    local sub, sub2, name, icon
    local rightToleft= Save().sortRightToLeft

--排序
    sub=root:CreateButton(
        ((numOut==0 or not WoWTools_GuildMixin:IsLeaderOrOfficer()) and '|cff828282' or '')
        ..'|A:bags-button-autosort-up:0:0|a'
        ..(rightToleft and '' or '|A:common-icon-rotateright:0:0|a')
        ..(WoWTools_DataMixin.onlyChinese and '整理' or STABLE_FILTER_BUTTON_LABEL)
        ..(rightToleft and '|A:common-icon-rotateleft:0:0|a' or ''),
    function()
        WoWTools_GuildBankMixin:Init_Plus_Sort(self)
        return MenuResponse.Close
    end)
    root:CreateDivider()

    sub2= sub:CreateCheckbox(
        (rightToleft and '' or '|A:common-icon-rotateright:0:0|a')
        ..(WoWTools_DataMixin.onlyChinese and '反向整理公会仓库' or REVERSE_CLEAN_UP_BAGS_TEXT:gsub(HUD_EDIT_MODE_BAGS_LABEL, GUILD_BANK))
        ..(rightToleft and '|A:common-icon-rotateleft:0:0|a' or ''),
    function()
        return Save().sortRightToLeft
    end, function()
        Save().sortRightToLeft= not Save().sortRightToLeft and true or nil
        return MenuResponse.CloseAll
    end)
     
--物品
    Init_Out_Bank_Menu(self, root, tabID, numOut)

--材料
    root:CreateDivider()
    Init_Out_Bag_Menu(self, root, tabID, numIn)

--打开选项
    name, icon= GetGuildBankTabInfo(tabID)
    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {
        name= WoWTools_GuildBankMixin.addName,
        name2= '|T'..(icon or 0)..':0|t'..(name  or format(WoWTools_DataMixin.onlyChinese and '标签%d' or GUILDBANK_TAB_NUMBER, tabID)),
    })

    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().saveItemSeconds or 0.8
        end, setValue=function(value)
            Save().saveItemSeconds=value

            if WoWTools_GuildBankMixin.isInRun then--禁用，按钮移动事件
                self.isInRun=true--停止，已运行
            end

        end,
        name=WoWTools_DataMixin.onlyChinese and '延迟' or LAG_TOLERANCE,
        minValue=0.5,
        maxValue=1.5,
        step=0.1,
        bit='%.1f',
        tooltip=function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '延迟' or LAG_TOLERANCE)
        end
    })
    sub:CreateSpacer()
end





function WoWTools_GuildBankMixin:Init_Button_Menu(...)
    Init_Menu(...)
end