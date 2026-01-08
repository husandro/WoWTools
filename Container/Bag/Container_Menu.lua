--背包，菜单，增强 ContainerFrame.lua
local function Save()
    return WoWToolsSave['Plus_Container'] or {}
end


--NUM_TOTAL_BAG_FRAMES 5
--local function AddButtons_BagFilters(description, bagID)



local function Get_Columns(self)
    local value= Save()[self:GetName()..'Columns']
    if value then
        return value
    elseif self:IsCombinedBagContainer() then
        return 10
    else
        return 4
    end
end

local function Set_GetColumns(self)
    if not self
        or not self.GetColumns
        or not Save().enabledCombinedColumns
    then
        return
    end
    local name= self:GetName()

    local value= Save()[name..'Columns']
    if value then
--替换，原生
        function self:GetColumns()
            return Get_Columns(self)
        end
        if not self~=ContainerFrameCombinedBags then
            function self:GetPaddingWidth()
                return 15
            end
            function self:CalculateWidth()
                local columns = self:GetColumns()
                local templateInfo = C_XMLUtil.GetTemplateInfo(self.itemButtonPool:GetTemplate())
                local ITEM_SPACING_X = 5
                local itemsWidth = (columns * templateInfo.width) + ((columns-1) * ITEM_SPACING_X)
                return itemsWidth + self:GetPaddingWidth()
            end
        end
    end
end

local function Update_Frame(self)
    if not self
        or not self.GetColumns
        or not self:IsVisible()
        or not Save().enabledCombinedColumns
    then
        return
    end

    local size, id= self.size, self:GetID()
    if size and id then
        ContainerFrame_GenerateFrame(self, size, id)
    end
end





local function Get_BagName(frame)--frame:GetBagID()
    local name= frame:GetName()
    local bagID= tonumber(name:match('%d') or 1)
    bagID= bagID-1

    local bagName
    if frame==ContainerFrameCombinedBags then
        bagName= '|A:bag-main:0:0|a'..(WoWTools_DataMixin.onlyChinese and '组合背包' or COMBINED_BAG_TITLE)

    elseif ContainerFrame_IsReagentBag(bagID) then
        bagName= '|A:Professions_Tracking_Fish:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '材料包' or EQUIP_CONTAINER_REAGENT:gsub(EQUIPSET_EQUIP, ''))
            ..' '..(name:match('%d') or '')

    else
        bagName= (
                WoWTools_TextMixin:CN(C_Container.GetBagName(bagID))
                or (WoWTools_DataMixin.onlyChinese and '行囊' or BAG_NAME_BACKPACK)
            )
            ..' '..(name:match('%d') or '')

        if bagID==0 then
            bagName= '|A:hud-backpack:0:0|a'..bagName
        else
            local inventoryID = C_Container.ContainerIDToInventoryID(bagID)
            local texture = inventoryID and GetInventoryItemTexture('player', inventoryID)
            if texture then
                bagName= '|T'..texture..':0|t'..bagName
            end
        end
    end
    return bagName
end









local function Init_Columns_Menu(self, root)
    local sub= root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '行数' or HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ROWS,
    function()
        return Save().enabledCombinedColumns
    end, function()
        Save().enabledCombinedColumns= not Save().enabledCombinedColumns and true or false
    end, {rightText= Get_Columns(self)})

    WoWTools_MenuMixin:SetRightText(sub)
    sub:SetTooltip(function(tooltip)
        GameTooltip_AddInstructionLine(tooltip, WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        GameTooltip_AddErrorLine(tooltip, WoWTools_DataMixin.onlyChinese and '可能会出现错误' or 'Errors may occur')
    end)

    sub:CreateSpacer()

    local frames= {
        ContainerFrameCombinedBags,
    }
    for bag= 1, NUM_CONTAINER_FRAMES do
        local frame=_G['ContainerFrame'..bag]
        if frame and frame.GetColumns then
            if self==frame then
                table.insert(frames, 1, frame)
            else
                table.insert(frames, frame)
            end
        end
    end

    local disabled= not Save().enabledCombinedColumns-- or InCombatLockdown()

    for _, frame in pairs(frames) do
        sub:CreateSpacer()
        local hex= disabled and '|cff626262' or (frame==self and '|cnGREEN_FONT_COLOR:') or (frame:IsShown() and '|cnNORMAL_FONT_COLOR:') or ''

        local sub2= WoWTools_MenuMixin:CreateSlider(sub, {
            name=hex
                ..Get_BagName(frame),
            getValue=function(_, desc)
                return Get_Columns(desc.data.frame)
            end, setValue=function(value, _, desc)
                Save()[desc.data.name..'Columns']= value
                Set_GetColumns(desc.data.frame)
                Update_Frame(desc.data.frame)
            end,
            minValue=1,
            maxValue=50,
            step=1,
        })

        sub2:SetData({frame=frame, name=frame:GetName()})
        sub2:SetTooltip(function(tooltip,desc)
            tooltip:AddLine(desc.data.name)
        end)

        sub:CreateSpacer()
        if frame==self then sub:CreateSpacer() end
    end



    sub:CreateSpacer()
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT,
    function()
        for _, frame in pairs(frames) do
            Save()[frame:GetName()..'Columns']= nil
            Update_Frame(frame)
        end
        return MenuResponse.Refresh
    end)


    root:CreateDivider()

--打开选项界面
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_BagMixin.addName})
--重载
    WoWTools_MenuMixin:Reload(sub)
--重置数据
    WoWTools_MenuMixin:RestData(sub, WoWTools_BagMixin.addName, function()
        WoWToolsSave['Plus_Container']= nil
        WoWTools_DataMixin:Reload()
    end)
end

















local function Init()






    Menu.ModifyMenu("MENU_CONTAINER_FRAME", function(self, root)
        if not self:IsMouseOver() then
            return
        end

        local frame= self:GetParent()
        local bagID = frame:GetBagID()
--全部启用
        if ContainerFrame_CanContainerUseFilterMenu(bagID) then
            local sub
            root:CreateDivider()

            sub=root:CreateCheckbox(
                WoWTools_DataMixin.onlyChinese and '全部启用' or ENABLE_ALL_ADDONS,
            function(data)
                for _, flag in ContainerFrameUtil_EnumerateBagGearFilters() do
                    if C_Container.GetBagSlotFlag(data.bagID, flag)==false then
                        return false
                    end
                end
                return true
            end, function(data)
                for _, flag in ContainerFrameUtil_EnumerateBagGearFilters() do
                    C_Container.SetBagSlotFlag(data.bagID, flag, true)
                    ContainerFrameSettingsManager:SetFilterFlag(data.bagID, flag, true);
                end
            end, {bagID=bagID})
            sub:SetTooltip(function(tooltip)
                tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '指定背包' or BAG_FILTER_ASSIGN_TO:gsub(HEADER_COLON, ''))
                tooltip:AddDoubleLine(WoWTools_BagMixin.addName, WoWTools_DataMixin.addName)
            end)
--全部禁用
            sub=root:CreateCheckbox(
                WoWTools_DataMixin.onlyChinese and '全部禁用' or DISABLE_ALL_ADDONS,
            function(data)
                for _, flag in ContainerFrameUtil_EnumerateBagGearFilters() do
                    if C_Container.GetBagSlotFlag(data.bagID, flag) then
                        return false
                    end
                end
                return true
            end, function(data)
                for _, flag in ContainerFrameUtil_EnumerateBagGearFilters() do
                    C_Container.SetBagSlotFlag(data.bagID, flag, true)
                    ContainerFrameSettingsManager:SetFilterFlag(data.bagID, flag, false);
                end
                return MenuResponse.Close
            end, {bagID=bagID})
            sub:SetTooltip(function(tooltip)
                tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '指定背包' or BAG_FILTER_ASSIGN_TO:gsub(HEADER_COLON, ''))
                tooltip:AddDoubleLine(WoWTools_BagMixin.addName, WoWTools_DataMixin.addName)
            end)
        else
            root:CreateDivider()
        end

        Init_Columns_Menu(frame, root)
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
            tooltip:AddLine('C_Container'..WoWTools_DataMixin.Icon.icon2..'|cffffffffSetSortBagsRightToLeft')
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
            tooltip:AddLine('C_Container'..WoWTools_DataMixin.Icon.icon2..'|cffffffffSetInsertItemsLeftToRight')
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
            tooltip:AddLine('C_Container'..WoWTools_DataMixin.Icon.icon2..'|cffffffffSetBackpackAutosortDisabled')
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
            tooltip:AddLine('C_Container'..WoWTools_DataMixin.Icon.icon2..'|cffffffffSetBackpackSellJunkDisabled')
        end)

        Init_Columns_Menu(self:GetParent(), root)
    end)







    if Save().enabledCombinedColumns then
--ContainerFrame1 到 13 11.2版本是 6
        for bagID= 1, NUM_CONTAINER_FRAMES do
            local frame= _G['ContainerFrame'..bagID]
            if frame then
                Set_GetColumns(frame)
            end
        end
--ContainerFrameCombinedBags
        Set_GetColumns(ContainerFrameCombinedBags)
--设置 SearchBox
        WoWTools_DataMixin:Hook(ContainerFrame1, 'SetSearchBoxPoint', function(_, searchBox)
            searchBox:SetPoint('RIGHT', -28-23, 0)
        end)
        WoWTools_DataMixin:Hook(ContainerFrameCombinedBags, 'SetSearchBoxPoint', function(_, searchBox)
            searchBox:SetPoint('RIGHT', -28-46, 0)
        end)
    end

    Init=function()end
end











function WoWTools_BagMixin:Init_Container_Menu()
    Init()
end
