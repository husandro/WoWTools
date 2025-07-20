if BankFrameTab2 then
    return
end






local function Get_Container_Tab(containerID)
    local itemTab={}
    local itemNum=0

    containerID= containerID or BankPanel:GetSelectedTabID()
    if not containerID or containerID==-1 then
        return itemTab, itemNum
    end

    for slotID = C_Container.GetContainerNumSlots(containerID) or 0, 1, -1 do
        local info = C_Container.GetContainerItemInfo(containerID, slotID)
        local classID, subClassID

        if info and not info.isFiltered and info.hyperlink then
            classID, subClassID = select(6, C_Item.GetItemInfoInstant(info.hyperlink))
        end

        if classID then
            info.slotID= slotID
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

            itemNum=itemNum+1
        end
    end

    return itemTab, itemNum
end














local function Use_Container_Item(free, containerID, data)
    if not data then
        return 0
    end

    free= free or WoWTools_BagMixin:GetFree(true) or 0

    for _, itemInfo in pairs(data) do
        if C_Container.HasContainerItem(containerID, itemInfo.slotID) then
            if free==0 or IsModifierKeyDown() then
                free=0
                break

            elseif C_Container.HasContainerItem(containerID, itemInfo.slotID) then
                C_Container.UseContainerItem(containerID, itemInfo.slotID)
                free= free-1
            end
        end
    end
    return free
end

local function Set_Tooltip_ItemList(tooltip, containerID, data)
    for _, itemInfo in pairs(data) do
        if C_Container.HasContainerItem(containerID, itemInfo.slotID) then
            tooltip:AddLine(
                '|T'..(itemInfo.iconFileID or 0)..':0|t'
                ..WoWTools_HyperLink:CN_Link(itemInfo.hyperlink, {itemID=itemInfo.itemID, isName=true})
                ..' x'..(itemInfo.stackCount==1000 and '1k' or itemInfo.stackCount or 1)
            )
        end
    end
end






local function Init_RightTab_Menu(self, root)
    local containerID= (not self:IsPurchaseTab() and not self:IsActiveBankTypeLocked())
                        and self.tabData and self.tabData.ID
    if not containerID or containerID==-1 then
        return
    end

    local itemTab, itemNum=Get_Container_Tab(containerID)

    root:CreateTitle(
        ('|T'..(self.tabData.icon or '')..':0|t')
        ..(self:GetActiveBankType()== Enum.BankType.Account and '|cff00ccff' or '|cffff8000')
        ..(WoWTools_DataMixin.onlyChinese and '提取' or WITHDRAW)..' #'..itemNum
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
            Use_Container_Item(nil, containerID, itemTab[data.classID].item)
            return MenuResponse.Refresh
        end, {classID=classID})

        sub:SetTooltip(function(tooltip, desc)
            Set_Tooltip_ItemList(tooltip, containerID, itemTab[desc.data.classID].item)
        end)

--subClasses
        for subClassID, subData in pairs(info.sub) do
            sub2= sub:CreateButton(
               '|cnGREEN_FONT_COLOR:#'..#subData..'|r '
               ..WoWTools_TextMixin:CN(C_Item.GetItemSubClassInfo(classID, subClassID))
               ..' '..subClassID,
            function(data)
                Use_Container_Item(nil, containerID, itemTab[data.classID].sub[data.subClassID])
                return MenuResponse.Refresh
            end, {classID=classID, subClassID=subClassID})

            sub2:SetTooltip(function(tooltip, desc)
                Set_Tooltip_ItemList(tooltip, containerID, itemTab[desc.data.classID].sub[desc.data.subClassID])
            end)
        end

    end

    root:CreateDivider()
    root:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '全部' or ALL)
        ..' |cnGREEN_FONT_COLOR:#'..itemNum,
    function()
        local free= WoWTools_BagMixin:GetFree(true) or 0
        for _, item in pairs(itemTab) do
            free= Use_Container_Item(free, containerID, item.item)
            if free==0 then
                break
            end
        end
        return MenuResponse.Refresh
    end)
end















local function Init()
    BankPanel.AutoDepositFrame.DepositButton:HookScript('OnEnter', function(self)
        if not self:IsEnabled() then
            return
        end
    end)
    BankPanel.AutoDepositFrame.DepositButton:HookScript('OnMouseDown', function(self, d)
        if d~='RightButton' or not self:IsEnabled() then
            return
        end

    end)

--右边Tab
    hooksecurefunc(BankPanelTabMixin, 'OnLoad', function(btn)
        btn:SetScript('OnMouseWheel', function(self)
            MenuUtil.CreateContextMenu(self, Init_RightTab_Menu)
        end)

        btn:HookScript('OnEnter', function(self)
            if not self:IsPurchaseTab() and not self:IsActiveBankTypeLocked() and self.tabData then
                GameTooltip:AddLine(
                    WoWTools_DataMixin.Icon.mid
                    ..'|cnGREEN_FONT_COLOR:<'
                    ..(WoWTools_DataMixin.onlyChinese and '提取' or WITHDRAW)--..(WoWTools_DataMixin.onlyChinese and '提取菜单' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WITHDRAW, HUD_EDIT_MODE_MICRO_MENU_LABEL))
                    ..'>'
                )
                GameTooltip:Show()
            end
        end)
    end)

    Init=function()end
end








function WoWTools_BankMixin:Out_In_Plus()
    Init()
end
