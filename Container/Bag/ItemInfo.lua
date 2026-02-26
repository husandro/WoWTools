
--容器，背包
function WoWTools_ItemMixin.Frames:ContainerFrame1()

    --[[local function Set_BagInfo(frame)
        for _, itemButton in frame:EnumerateValidItems() do
            if itemButton.hasItem then
                local slotID, bagID= itemButton:GetSlotAndBagID()--:GetID() GetBagID()
                WoWTools_ItemMixin:SetupInfo(itemButton, {bag={bag=bagID, slot=slotID}})
            else
                WoWTools_ItemMixin:SetupInfo(itemButton)
            end
        end
    end
--ContainerFrame1 到 13 11.2版本是 6
    for bagID= 1, NUM_CONTAINER_FRAMES do--NUM_TOTAL_BAG_FRAMES+NUM_REAGENTBAG_FRAMES do--6
        WoWTools_DataMixin:Hook(_G['ContainerFrame'..bagID], 'UpdateItems', Set_BagInfo)
    end
--ContainerFrameCombinedBags
    WoWTools_DataMixin:Hook(ContainerFrameCombinedBags, 'UpdateItems', Set_BagInfo)]]

    Menu.ModifyMenu("MENU_CONTAINER_FRAME_COMBINED", function(_, root)
        local sub=root:CreateCheckbox(
            WoWTools_DataMixin.onlyChinese and '物品信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEMS, INFO),
        function()
            return not self:Save().no.ContainerFrame1
        end, function()
            self:Save().no.ContainerFrame1= not self:Save().no.ContainerFrame1 and true or nil
        end)

    --属性，字体，缩放
        sub:CreateSpacer()
        WoWTools_MenuMixin:CreateSlider(sub, {
        name= WoWTools_DataMixin.onlyChinese and '字体大小' or FONT_SIZE,
        getValue=function()
            return self:Save().size.ContainerFrame1 or 10
        end, setValue=function(value)
            self:Save().size.ContainerFrame1= value
            --更新物品
        end,
        minValue=6,
        maxValue=18,
        step=1,
        --bit--='%.1f'
        --tooltip--function, string, table
        })
        sub:CreateSpacer()
    end)

    WoWTools_DataMixin:Hook(ContainerFrameItemButtonMixin, 'UpdateCooldown', function(btn)
        WoWTools_ItemMixin:SetupInfo(btn, not self:Save().no.ContainerFrame1 and {bag={bag=btn:GetBagID(), slot=btn:GetID()}, size=self:Save().size.ContainerFrame1} or nil)
    end)

--其它插件
    if C_AddOns.IsAddOnLoaded("Bagnon") then
        local itemButton = Bagnon.ItemSlot or Bagnon.Item
        if itemButton and itemButton.Update then
            hooksecurefunc(itemButton, 'Update', function(frame)
                local slot, bag= frame:GetSlotAndBagID()
                if slot and bag then
                    local slotID, bagID= frame:GetSlotAndBagID()
                    WoWTools_ItemMixin:SetupInfo(frame, frame.hasItem and {bag={bag=bagID, slot=slotID}} or nil)
                end
            end)
        end

    elseif C_AddOns.IsAddOnLoaded("Baggins") then
        WoWTools_DataMixin:Hook(_G['Baggins'], 'UpdateItemButton', function(_, _, button, bagID, slotID)
            if button and bagID and slotID then
                WoWTools_ItemMixin:SetupInfo(button, {bag={bag=bagID, slot=slotID}})
            end
        end)

    elseif C_AddOns.IsAddOnLoaded('Inventorian') then
        local lib = LibStub("AceAddon-3.0", true)
        if lib then
            ADDON= lib:GetAddon("Inventorian")
            local InvLevel = ADDON:NewModule('InventorianWoWToolsItemInfo')
            function InvLevel:Update()
                WoWTools_ItemMixin:SetupInfo(self, {bag={bag=self.bag, slot=self.slot}})
            end
            function InvLevel:WrapItemButton(item)
                WoWTools_DataMixin:Hook(item, "Update", InvLevel.Update)
            end
            WoWTools_DataMixin:Hook(ADDON.Item, "WrapItemButton", InvLevel.WrapItemButton)
        end
    end
end
