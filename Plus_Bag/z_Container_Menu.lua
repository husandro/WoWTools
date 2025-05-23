--背包，菜单，增强 ContainerFrame.lua


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
end












--主背包
local function MENU_CONTAINER_FRAME_COMBINED(_, root)
    local sub
    root:CreateDivider()

    sub= root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '反向整理背包' or REVERSE_CLEAN_UP_BAGS_TEXT,
    function()
        return C_Container.GetSortBagsRightToLeft()
    end, function()
        C_Container.SetSortBagsRightToLeft(not C_Container.GetSortBagsRightToLeft())
        return MenuResponse.Close
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('C_Container.SetSortBagsRightToLeft')
        tooltip:AddDoubleLine(WoWTools_BagMixin.addName, WoWTools_DataMixin.addName)
    end)

    sub= root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '禁用排序' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DISABLE, STABLE_FILTER_BUTTON_LABEL),
    C_Container.GetBackpackAutosortDisabled, function()
        C_Container.SetBackpackAutosortDisabled(not C_Container.GetBackpackAutosortDisabled() and true or false)
        return MenuResponse.Close
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('C_Container.SetBackpackAutosortDisabled')
        tooltip:AddDoubleLine(WoWTools_BagMixin.addName, WoWTools_DataMixin.addName)
    end)

    --[[CONTAINER_OFFSET_Y 
    root:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(root, {
        getValue=function()
            return CONTAINER_OFFSET_Y or 85
        end, setValue=function(value)
            CONTAINER_OFFSET_Y= value
            WoWTools_Mixin:Call(UpdateContainerFrameAnchors)
        end,
        name= 'y',
        minValue=20,
        maxValue=200,
        step=1,
        
        tooltip=function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '间隔' or 'Interval')
        end
    
    })
    sub:CreateSpacer()

    root:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(root, {
        getValue=function()
            return CONTAINER_OFFSET_X  or -4
        end, setValue=function(value)
            CONTAINER_OFFSET_X = value
            WoWTools_Mixin:Call(UpdateContainerFrameAnchors)
        end,
        name= 'x',
        minValue=-20,
        maxValue=200,
        step=1,
        
        tooltip=function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '间隔' or 'Interval')
        end
    
    })
    sub:CreateSpacer()]]
end











function WoWTools_BagMixin:Init_Container_Menu()
    Menu.ModifyMenu("MENU_CONTAINER_FRAME", MENU_CONTAINER_FRAME)
    Menu.ModifyMenu("MENU_CONTAINER_FRAME_COMBINED", MENU_CONTAINER_FRAME_COMBINED)
end
