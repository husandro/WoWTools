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
        if info and not info.hyperlink then
            for k, v in pairs(info or {}) do if v and type(v)=='table' then print('|cff00ff00---',k, '---STAR') for k2,v2 in pairs(v) do print(k2,v2) end print('|cffff0000---',k, '---END') else print(k,v) end end print('|cffff00ff——————————')
        end
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
        if free==0 or IsModifierKeyDown() or not BankFrame:IsShown() or InCombatLockdown() then
            free=0
            break

        elseif C_Container.HasContainerItem(containerID, itemInfo.slotID) then
            C_Container.UseContainerItem(containerID, itemInfo.slotID)
            free= free-1
        end
        
    end
    return free
end

local function Set_Tooltip_ItemList(tooltip, containerID, data)
    for _, itemInfo in pairs(data or {}) do
        if C_Container.HasContainerItem(containerID, itemInfo.slotID) then
            tooltip:AddLine(
                '|T'..(itemInfo.iconFileID or 0)..':0|t'
                ..WoWTools_HyperLink:CN_Link(itemInfo.hyperlink, {itemID=itemInfo.itemID, isName=true})
                ..' x'..(itemInfo.stackCount==1000 and '1k' or itemInfo.stackCount or 1)
            )
        end
    end
end














local function Init_RightTab_Menu(root, tabData)
    if BankPanelSystemMixin:IsActiveBankTypeLocked() then
        root:CreateTitle(WoWTools_DataMixin and '你无法和另一名角色一起同时使用战团银行。' or ACCOUNT_BANK_ERROR_NO_LOCK )
        return
    end

    local containerID= tabData.ID

    local itemTab, itemNum= Get_Container_Tab(containerID)

    root:CreateTitle(
        ('|T'..(tabData.icon or 0)..':0|t')
        ..(BankPanel:GetActiveBankType()== Enum.BankType.Account and '|cff00ccff' or '|cffff8000')
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
        '|cnGREEN_FONT_COLOR:#'..itemNum..'|r '
        ..(WoWTools_DataMixin.onlyChinese and '全部' or ALL),
    function()
        local free= WoWTools_BagMixin:GetFree(true) or 0
        for _, item in pairs(itemTab) do
            free= Use_Container_Item(free, containerID, item.item)
            if free==0 or not BankFrame:IsShown() then
                break
            end
        end
        return MenuResponse.Refresh
    end)
end







local function Init()
    --[[BankPanel.AutoDepositFrame.DepositButton:HookScript('OnEnter', function(self)
        if not self:IsEnabled() then
            return
        end
    end)
    BankPanel.AutoDepositFrame.DepositButton:HookScript('OnMouseDown', function(self, d)
        if d~='RightButton' or not self:IsEnabled() then
            return
        end

    end)]]

--右边Tab
    hooksecurefunc(BankPanelTabMixin, 'OnLoad', function(btn)
        btn:SetScript('OnMouseWheel', function(self)
            MenuUtil.CreateContextMenu(self, function(_, root)
                if self.tabData and not self:IsPurchaseTab() and not self:IsActiveBankTypeLocked() then
                    Init_RightTab_Menu(root, self.tabData)
                end
            end)
        end)

        btn:HookScript('OnEnter', function(self)
            if not self:IsPurchaseTab() and not self:IsActiveBankTypeLocked() and self.tabData then
                GameTooltip:AddLine(
                    WoWTools_DataMixin.Icon.mid
                    ..'|cnGREEN_FONT_COLOR:<'
                    ..(WoWTools_DataMixin.onlyChinese and '提取' or WITHDRAW)--..(WoWTools_DataMixin.onlyChinese and '提取菜单' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WITHDRAW, HUD_EDIT_MODE_MICRO_MENU_LABEL))
                    ..'>|A:dressingroom-button-appearancelist-up:0:0|a'
                )
                GameTooltip:Show()
            end
        end)
    end)

    Init=function()end
end





function WoWTools_BankMixin:Init_Out_Menu(root, tabData)
    Init_RightTab_Menu(root, tabData)
end


function WoWTools_BankMixin:Init_Out_Plus()
    Init()
end














