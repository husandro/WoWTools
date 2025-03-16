--背包，菜单，增强 ContainerFrame.lua
local e= select(2, ...)

--NUM_TOTAL_BAG_FRAMES 5
--local function AddButtons_BagFilters(description, bagID)

local function MENU_CONTAINER_FRAME(self, root)
    local frame= self:GetParent()
    local bagID = frame:GetBagID()

    if not ContainerFrame_CanContainerUseFilterMenu(bagID) or not ContainerFrameUtil_EnumerateBagGearFilters then
        return
    end
    local sub
    root:CreateDivider()

    sub=root:CreateCheckbox(
        e.onlyChinese and '全部启用' or ENABLE_ALL_ADDONS,
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
        tooltip:AddLine(e.onlyChinese and '指定背包' or BAG_FILTER_ASSIGN_TO:gsub(HEADER_COLON, ''))
        tooltip:AddDoubleLine(WoWTools_BagMixin.addName, WoWTools_Mixin.addName)
    end)

    sub=root:CreateCheckbox(
        e.onlyChinese and '全部禁用' or DISABLE_ALL_ADDONS,
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
        tooltip:AddLine(e.onlyChinese and '指定背包' or BAG_FILTER_ASSIGN_TO:gsub(HEADER_COLON, ''))
        tooltip:AddDoubleLine(WoWTools_BagMixin.addName, WoWTools_Mixin.addName)
    end)
end












--主背包
local function MENU_CONTAINER_FRAME_COMBINED(_, root)
    local sub
    root:CreateDivider()

    sub= root:CreateCheckbox(
        e.onlyChinese and '反向整理背包' or REVERSE_CLEAN_UP_BAGS_TEXT,
    function()
        return C_Container.GetSortBagsRightToLeft()
    end, function()
        C_Container.SetSortBagsRightToLeft(not C_Container.GetSortBagsRightToLeft())
        return MenuResponse.Close
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('C_Container.SetSortBagsRightToLeft')
        tooltip:AddDoubleLine(WoWTools_BagMixin.addName, WoWTools_Mixin.addName)
    end)

    sub= root:CreateCheckbox(
        e.onlyChinese and '禁用排序' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DISABLE, STABLE_FILTER_BUTTON_LABEL),
    C_Container.GetBackpackAutosortDisabled, function()
        C_Container.SetBackpackAutosortDisabled(not C_Container.GetBackpackAutosortDisabled() and true or false)
        return MenuResponse.Close
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('C_Container.SetBackpackAutosortDisabled')
        tooltip:AddDoubleLine(WoWTools_BagMixin.addName, WoWTools_Mixin.addName)
    end)

end











function WoWTools_BagMixin:Init_Container_Menu()
    Menu.ModifyMenu("MENU_CONTAINER_FRAME", MENU_CONTAINER_FRAME)
    Menu.ModifyMenu("MENU_CONTAINER_FRAME_COMBINED", MENU_CONTAINER_FRAME_COMBINED)
end
