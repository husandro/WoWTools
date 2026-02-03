--玩具界面, 按钮

local function Save()
    return WoWToolsSave['Tools_Hearthstone']
end
local function SaveItems()
    return WoWToolsPlayerDate['HearthstoneItems']
end

--设置，物品，提示
local function Set_Menu_Tooltip(tooltip, desc)
    if desc.data then
        WoWTools_SetTooltipMixin:Setup(tooltip, {itemID=desc.data.itemID})--设置，物品，提示
    end
    WoWTools_ToolsMixin:Get_ButtonForName('Hearthstone'):set_tooltip_location(tooltip)
end







function WoWTools_HearthstoneMixin:Init_Menu_Toy(frame, root)

    local sub, sub2, name, toyName, icon
    local index=0
    for itemID in pairs(SaveItems()) do
        WoWTools_DataMixin:Load(itemID, 'item')

        toyName, icon = select(2, C_ToyBox.GetToyInfo(itemID))
        index= index+ 1

        icon= '|T'..(icon or 0)..':0|t'
        name=WoWTools_TextMixin:CN(toyName, {itemID=itemID, isName=true})
        if name then
            name=name:match('|c........(.-)|r') or name
        else
            name='itemID '.. itemID
        end

--名称
        local has= PlayerHasToy(itemID)
        local isLoked= Save().lockedToy==itemID
        sub=root:CreateCheckbox(
            (isLoked and '|cnGREEN_FONT_COLOR:' or (has and '' or '|cff626262'))
            ..icon
            ..name
            ..(isLoked and '|A:AdventureMapIcon-Lock:0:0|a' or '')--锁定
            ..(has and WoWTools_CooldownMixin:GetText(nil, itemID) or ''),--CD
            function(data)
                return frame.itemID==data.itemID
            end, function(data)
                if data.has then
                    local toy= frame.Selected_Value~=data.itemID and data.itemID or nil
                    frame:Set_SelectValue_Random(toy)
                end
            end,
            {itemID=itemID, name=toyName, has=has, rightText=index}
        )
        sub:SetTooltip(Set_Menu_Tooltip)
        WoWTools_MenuMixin:SetRightText(sub)

        sub2=sub:CreateCheckbox(
            (has and '' or '|cff626262')
            ..icon
            ..(WoWTools_DataMixin.onlyChinese and '锁定' or LOCK)..'|A:AdventureMapIcon-Lock:0:0|a',
        function(data)
            return Save().lockedToy==data.itemID
        end, function(data)
            if data.has then
                local toy= Save().lockedToy~=data.itemID and itemID or nil
                Save().lockedToy= toy
                frame:Set_LockedValue_Random(toy)
            end
        end, {itemID=itemID, name=toyName, has=has})
        sub2:SetTooltip(Set_Menu_Tooltip)


        sub2=sub:CreateButton(
            '|A:common-icon-zoomin:0:0|a'..(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS),
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
            tooltip:AddLine(MicroButtonTooltipText(WoWTools_DataMixin.onlyChinese and '战团藏品' or COLLECTIONS, "TOGGLECOLLECTIONS"))
        end)

        sub:CreateDivider()
        sub2=sub:CreateButton(
            '|A:common-icon-redx:0:0|a'..(WoWTools_DataMixin.onlyChinese and '移除' or REMOVE),
            function(data)
                WoWTools_HearthstoneMixin:Remove_Toy(data.itemID)--移除
                return MenuResponse.Open
            end,
            {itemID=itemID, name=toyName}
        )
        sub2:SetTooltip(Set_Menu_Tooltip)
    end
    WoWTools_MenuMixin:SetScrollMode(root)
end










