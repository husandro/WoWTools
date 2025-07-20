
if BankFrameTab2 then
    return
end


local function Get_Bank_Free()
    local free= 0
    for _, tabData in ipairs(BankPanel.purchasedBankTabData or {}) do
        if tabData.ID and tabData.ID~=-1 then
            free= free + (C_Container.GetContainerNumFreeSlots(tabData.ID) or 0)
        end
    end
    return free
end


local function Use_Container_Item(free, data)
    if not data then
        return 0
    end

    free= free or Get_Bank_Free()

    for _, itemInfo in pairs(data) do
        if free==0 or IsModifierKeyDown() or not BankFrame:IsShown() or InCombatLockdown() then
            free=0
            break

        elseif C_Container.HasContainerItem(itemInfo.bagID, itemInfo.slotID) then
            C_Container.UseContainerItem(itemInfo.bagID, itemInfo.slotID, 'player', BankFrame:GetActiveBankType(), true)
            free= free-1
        end

    end
    return free
end


local function Set_Tooltip_ItemList(tooltip, data)
    for _, itemInfo in pairs(data or {}) do
        if C_Container.HasContainerItem(itemInfo.bagID, itemInfo.slotID) then
            tooltip:AddLine(
                '|T'..(itemInfo.iconFileID or 0)..':0|t'
                ..(
                    WoWTools_HyperLink:CN_Link(itemInfo.hyperlink, {itemID=itemInfo.itemID, isName=true})
                    or itemInfo.itemID
                )
                ..' x'..(itemInfo.stackCount==1000 and '1k' or itemInfo.stackCount or 1)
            )
        end
    end
end


local function Get_BagItems()

    local items= WoWTools_BagMixin:GetItems(true, nil, nil, function(_, _, info)
        return not info.isFiltered and not info.isLocked
    end)
    local num= #items
    if num==0 then
        return {}, 0
    end

    local itemTab={}
    for _, data in pairs(items) do
        local info= data.info
        info.bagID= data.bag
        info.slotID= data.slot
        info.isRegent= data.isRegent

        local classID, subClassID = select(6, C_Item.GetItemInfoInstant(data.info.itemID))
        info.classID= classID
        info.subClassID= subClassID

         if not itemTab[classID] then
            itemTab[classID]= {
                item={info},
                sub={
                    [subClassID]={info}
                },
                num=1
            }
        else
            table.insert(itemTab[classID].item, info)

            if not itemTab[classID].sub[subClassID] then
                itemTab[classID].sub[subClassID]= {info}
            else
                table.insert(itemTab[classID].sub[subClassID], info)
            end

            itemTab[classID].num= itemTab[classID].num+1
        end
    end
    return itemTab, num
end


local function Init_RightTab_Menu(self, root)
    if not self:IsMouseOver() then
        return
    elseif BankPanelSystemMixin:IsActiveBankTypeLocked() then
        root:CreateTitle(WoWTools_DataMixin and '你无法和另一名角色一起同时使用战团银行。' or ACCOUNT_BANK_ERROR_NO_LOCK )
        return
    end

    local itemTab, itemNum= Get_BagItems()
    root:CreateTitle(
        (BankPanel:GetActiveBankType()== Enum.BankType.Account and '|cff00ccff' or '|cffff8000')
        ..(WoWTools_DataMixin.onlyChinese and '存放' or BANK_DEPOSIT_MONEY_BUTTON_LABEL)..' #'..itemNum
    )
    if itemNum==0 then
        return
    else
        root:CreateDivider()
    end


    local sub, sub2

    for classID, info in pairs(itemTab) do
        sub=root:CreateButton(
            '|cnGREEN_FONT_COLOR:#'..info.num..'|r '
            ..(WoWTools_TextMixin:CN(C_Item.GetItemClassInfo(classID)) or classID)
            ..' '..classID,
        function(data)
            Use_Container_Item(nil, itemTab[data.classID].item)
            return MenuResponse.Refresh
        end, {classID=classID})

        sub:SetTooltip(function(tooltip, desc)
            Set_Tooltip_ItemList(tooltip, itemTab[desc.data.classID].item)
        end)

--subClasses
        for subClassID, subData in pairs(info.sub) do
            sub2= sub:CreateButton(
               '|cnGREEN_FONT_COLOR:#'..#subData..'|r '
               ..WoWTools_TextMixin:CN(C_Item.GetItemSubClassInfo(classID, subClassID))
               ..' '..subClassID,
            function(data)
                Use_Container_Item(nil, itemTab[data.classID].sub[data.subClassID])
                return MenuResponse.Refresh
            end, {classID=classID, subClassID=subClassID})

            sub2:SetTooltip(function(tooltip, desc)
                Set_Tooltip_ItemList(tooltip, itemTab[desc.data.classID].sub[desc.data.subClassID])
            end)
        end

    end

    root:CreateDivider()
    root:CreateButton(
        '|cnGREEN_FONT_COLOR:#'..itemNum..'|r '
        ..(WoWTools_DataMixin.onlyChinese and '全部' or ALL),
    function()
        local free= WoWTools_BagMixin:GetFree(true) or 0
        for _, item in pairs(itemTab) do
            free= Use_Container_Item(free, item.item)
            if free==0 then
                break
            end
        end
        return MenuResponse.Refresh
    end)
end

local function Init()
    local btn= WoWTools_ButtonMixin:Menu(BankPanel, {
        size=23,
        atlas='Levelup-Icon-Bag',
    })

    btn:SetPoint('RIGHT', BankItemSearchBox, 'LEFT', -16, 0)
    btn:SetScript('OnLeave', function() GameTooltip:Hide() end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(
            (BankPanel:GetActiveBankType()== Enum.BankType.Account and '|cff00ccff' or '|cffff8000')
            ..WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_DataMixin.onlyChinese and '存放' or BANK_DEPOSIT_MONEY_BUTTON_LABEL)
            ..'|A:dressingroom-button-appearancelist-up:0:0|a'
        )
        GameTooltip:Show()
    end)

    btn:SetupMenu(Init_RightTab_Menu)

    --[[BankPanel.AutoDepositFrame.DepositButton:SetScript('OnEnter', function(self)
        if not self:IsEnabled() then
            return
        end
    end)]]
    Init=function()end
end

function WoWTools_BankMixin:Init_In_Plus()
    Init()
end
