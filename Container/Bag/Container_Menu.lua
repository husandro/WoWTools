--背包，菜单，增强 ContainerFrame.lua


--NUM_TOTAL_BAG_FRAMES 5
--local function AddButtons_BagFilters(description, bagID)


local function Init()
    Menu.ModifyMenu("MENU_CONTAINER_FRAME", function(self, root)
        if not self:IsMouseOver() then
            return
        end
        local frame= self:GetParent()
        local bagID = frame:GetBagID()

        if not ContainerFrame_CanContainerUseFilterMenu(bagID) or not ContainerFrameUtil_EnumerateBagGearFilters then
            return
        end
        local sub
        root:CreateDivider()

        sub=root:CreateCheckbox(
            WoWTools_DataMixin.onlyChinese and '全部启用' or ENABLE_ALL_ADDONS,
        function(data)
            if ContainerFrameUtil_EnumerateBagGearFilters then
                for _, flag in ContainerFrameUtil_EnumerateBagGearFilters() do
                    if C_Container.GetBagSlotFlag(data.bagID, flag)==false then
                        return false
                    end
                end
                return true
            end
            return false
        end, function(data)
            if ContainerFrameUtil_EnumerateBagGearFilters then
                for i, flag in ContainerFrameUtil_EnumerateBagGearFilters() do
                    C_Container.SetBagSlotFlag(data.bagID, flag, true)
                    ContainerFrameSettingsManager:SetFilterFlag(data.bagID, flag, true);
                end
            end
            return MenuResponse.Close
        end, {bagID=bagID})
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '指定背包' or BAG_FILTER_ASSIGN_TO:gsub(HEADER_COLON, ''))
            tooltip:AddDoubleLine(WoWTools_BagMixin.addName, WoWTools_DataMixin.addName)
        end)

        sub=root:CreateCheckbox(
            WoWTools_DataMixin.onlyChinese and '全部禁用' or DISABLE_ALL_ADDONS,
        function(data)
            if ContainerFrameUtil_EnumerateBagGearFilters then
                for _, flag in ContainerFrameUtil_EnumerateBagGearFilters() do
                    if C_Container.GetBagSlotFlag(data.bagID, flag) then
                        return false
                    end
                end
                return true
            end
            return false
        end, function(data)
            if ContainerFrameUtil_EnumerateBagGearFilters then
                for i, flag in ContainerFrameUtil_EnumerateBagGearFilters() do
                    C_Container.SetBagSlotFlag(data.bagID, flag, true)
                    ContainerFrameSettingsManager:SetFilterFlag(data.bagID, flag, false);
                end
            end
            return MenuResponse.Close
        end, {bagID=bagID})
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '指定背包' or BAG_FILTER_ASSIGN_TO:gsub(HEADER_COLON, ''))
            tooltip:AddDoubleLine(WoWTools_BagMixin.addName, WoWTools_DataMixin.addName)
        end)
    end)













    Menu.ModifyMenu("MENU_CONTAINER_FRAME_COMBINED", function(self, root)
        if not self:IsMouseOver() then
            return
        end

        local sub
        root:CreateDivider()

        sub= root:CreateCheckbox(
            WoWTools_DataMixin.onlyChinese and '反向整理背包' or REVERSE_CLEAN_UP_BAGS_TEXT,
        function()
            return not C_Container.GetSortBagsRightToLeft()
        end, function()
            C_Container.SetSortBagsRightToLeft(not C_Container.GetSortBagsRightToLeft())
            return MenuResponse.Close
        end)
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine('C_Container'..WoWTools_DataMixin.Icon.icon2..'SetSortBagsRightToLeft')
        end)

        sub= root:CreateCheckbox(
            WoWTools_DataMixin.onlyChinese and '将战利品放入最左边的背包' or REVERSE_NEW_LOOT_TEXT,
        function()
            return C_Container.GetInsertItemsLeftToRight()
        end, function()
            C_Container.SetInsertItemsLeftToRight(not C_Container.GetInsertItemsLeftToRight())
            return MenuResponse.Close
        end)
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine('C_Container'..WoWTools_DataMixin.Icon.icon2..'SetInsertItemsLeftToRight')
        end)

        sub= root:CreateCheckbox(
            WoWTools_DataMixin.onlyChinese and '禁用排序' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DISABLE, STABLE_FILTER_BUTTON_LABEL),
        function()
            return C_Container.GetBackpackAutosortDisabled()
        end, function()
            C_Container.SetBackpackAutosortDisabled(not C_Container.GetBackpackAutosortDisabled() and true or false)
            return MenuResponse.Close
        end)
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine('C_Container'..WoWTools_DataMixin.Icon.icon2..'SetBackpackAutosortDisabled')
        end)

        sub= root:CreateCheckbox(
            WoWTools_DataMixin.onlyChinese and '禁用出售垃圾' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DISABLE, SELL_ALL_JUNK_ITEMS_EXCLUDE_HEADER),
        function()
            return C_Container.GetBackpackSellJunkDisabled()
        end, function()
            C_Container.SetBackpackSellJunkDisabled(not C_Container.GetBackpackSellJunkDisabled() and true or false)
            return MenuResponse.Close
        end)
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine('C_Container'..WoWTools_DataMixin.Icon.icon2..'SetBackpackSellJunkDisabled')
        end)

    end)





    Init=function()end
end











function WoWTools_BagMixin:Init_Container_Menu()
    Init()
end
