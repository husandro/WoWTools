--玩具界面, 按钮
local e= select(2, ...)
local function Save()
    return WoWTools_HearthstoneMixin.Save
end

--设置，物品，提示
local function Set_Menu_Tooltip(tooltip, desc)
    if desc.data then
        WoWTools_SetTooltipMixin:Setup(tooltip, {itemID=desc.data.itemID})--设置，物品，提示
    end
    WoWTools_HearthstoneMixin.ToyButton:set_tooltip_location(tooltip)
end

--[[local function set_ToggleCollectionsJournal(data)
    WoWTools_LoadUIMixin:Journal(3)
    if data.name or data.itemID then
        local name= data.name or select(2, C_ToyBox.GetToyInfo(data.itemID)) or C_Item.GetItemNameByID(data.itemID)
        if name then
            C_ToyBoxInfo.SetDefaultFilters()
            if ToyBox.searchBox then
                ToyBox.searchBox:SetText(name)
            end
        end
    end
    return MenuResponse.Open
end]]













local function Init_Menu_Toy(self, root)

    local sub, sub2, name, toyName, icon
    local index=0
    for itemID in pairs(Save().items) do
        WoWTools_Mixin:Load({id=itemID, type='item'})

        toyName, icon = select(2, C_ToyBox.GetToyInfo(itemID))
        index= index+ 1

        icon= '|T'..(icon or 0)..':0|t'
        name=e.cn(toyName, {itemID=itemID, isName=true})
        if name then
            name=name:match('|c........(.-)|r') or name
        else
            name='itemID '.. itemID
        end

--名称
        local has= PlayerHasToy(itemID)
        local isLoked= Save().lockedToy==itemID
        sub=root:CreateCheckbox(
            (isLoked and '|cnGREEN_FONT_COLOR:' or (has and '' or '|cff9e9e9e'))
            ..index..') '..icon
            ..name
            ..(isLoked and '|A:AdventureMapIcon-Lock:0:0|a' or '')--锁定
            ..(has and e.GetSpellItemCooldown(nil, itemID) or ''),--CD
            function(data)
                return self.itemID==data.itemID
            end, function(data)
                if data.has then
                    local toy= self.Selected_Value~=data.itemID and data.itemID or nil
                    self:Set_SelectValue_Random(toy)
                end
            end,
            {itemID=itemID, name=toyName, has=has}
        )
        sub:SetTooltip(Set_Menu_Tooltip)

        sub2=sub:CreateCheckbox(
            (has and '' or '|cff9e9e9e')
            ..icon
            ..(e.onlyChinese and '锁定' or LOCK)..'|A:AdventureMapIcon-Lock:0:0|a',
        function(data)
            return Save().lockedToy==data.itemID
        end, function(data)
            if data.has then
                local toy= Save().lockedToy~=data.itemID and itemID or nil
                Save().lockedToy= toy
                self:Set_LockedValue_Random(toy)
            end
        end, {itemID=itemID, name=toyName, has=has})
        sub2:SetTooltip(Set_Menu_Tooltip)


        sub2=sub:CreateButton(
            '|A:common-icon-zoomin:0:0|a'..(e.onlyChinese and '设置' or SETTINGS),
        function(data)
            WoWTools_LoadUIMixin:Journal(3)
            if data.name or data.itemID then
                local itemName= data.name or select(2, C_ToyBox.GetToyInfo(data.itemID)) or C_Item.GetItemNameByID(data.itemID)
                if itemName then
                    C_ToyBoxInfo.SetDefaultFilters()
                    if ToyBox.searchBox then
                        ToyBox.searchBox:SetText(itemName)
                    end
                end
            end
            return MenuResponse.Open
        end,
            {itemID=itemID, name=toyName}
        )
        sub2:SetTooltip(function(tooltip)
            tooltip:AddLine(MicroButtonTooltipText(e.onlyChinese and '战团藏品' or COLLECTIONS, "TOGGLECOLLECTIONS"))
        end)

        sub:CreateDivider()
        sub2=sub:CreateButton(
            '|A:common-icon-redx:0:0|a'..(e.onlyChinese and '移除' or REMOVE),
            function(data)
                WoWTools_HearthstoneMixin:Remove_Toy(data.itemID)--移除
                return MenuResponse.Open
            end,
            {itemID=itemID, name=toyName}
        )
        sub2:SetTooltip(Set_Menu_Tooltip)
    end
    WoWTools_MenuMixin:SetGridMode(root, index)
end













function WoWTools_HearthstoneMixin:Init_Menu_Toy(...)
    Init_Menu_Toy(...)
end