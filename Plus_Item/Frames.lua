
--boss掉落，物品, 可能，会留下 StaticPopup1 框架
function WoWTools_ItemMixin.Frames:BossBanner_ConfigureLootFrame()
    WoWTools_DataMixin:Hook('BossBanner_ConfigureLootFrame', function(lootFrame, data)--LevelUpDisplay.lua
        WoWTools_ItemMixin:SetItemStats(lootFrame, data.itemLink, {point=lootFrame.Icon})
    end)
end























--拾取
function WoWTools_ItemMixin.Frames:LootFrame()
    WoWTools_DataMixin:Hook(LootFrameItemElementMixin, 'Init', function(btn)
        WoWTools_ItemMixin:SetupInfo(btn.Item, {lootIndex= btn:GetSlotIndex()})
    end)
end
    --[[
    local texture, item, quantity, currencyID, itemQuality, locked, isQuestItem, questID, isActive = GetLootSlotInfo(slotIndex);
    WoWTools_DataMixin:Hook(LootFrame, 'Open', function(frame)--LootFrame.lua
        if not frame.ScrollBox:HasView() then
            return
        end
        for index, btn in pairs(frame.ScrollBox:GetFrames() or {}) do
            WoWTools_ItemMixin:SetupInfo(btn.Item, {lootIndex=btn.GetOrderIndex() or btn:GetSlotIndex() or index})
        end
    end)
    WoWTools_DataMixin:Hook(LootFrame.ScrollBox, 'SetScrollTargetOffset', function(frame)
        if not frame:HasView() then
            return
        end
        for index, btn in pairs(frame:GetFrames() or {}) do
            WoWTools_ItemMixin:SetupInfo(btn.Item, {lootIndex=btn.GetOrderIndex() or btn:GetSlotIndex() or index})
        end
    end)]]














--容器，背包
function WoWTools_ItemMixin.Frames:ContainerFrame_GenerateFrame()
    if C_AddOns.IsAddOnLoaded("Bagnon") then
        local itemButton = Bagnon.ItemSlot or Bagnon.Item
        if (itemButton) and (itemButton.Update)  then
            hooksecurefunc(itemButton, 'Update', function(frame)
                local slot, bag= frame:GetSlotAndBagID()
                if slot and bag then
                    if frame.hasItem then
                        local slotID, bagID= frame:GetSlotAndBagID()--:GetID() GetBagID()
                        WoWTools_ItemMixin:SetupInfo(frame, {bag={bag=bagID, slot=slotID}})
                    else
                        WoWTools_ItemMixin:SetupInfo(frame, {})
                    end
                end
            end)
        end


    elseif C_AddOns.IsAddOnLoaded("Baggins") then
        hooksecurefunc(_G['Baggins'], 'UpdateItemButton', function(_, _, button, bagID, slotID)
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
                hooksecurefunc(item, "Update", InvLevel.Update)
            end
            hooksecurefunc(ADDON.Item, "WrapItemButton", InvLevel.WrapItemButton)
        end

    else


        local function setBags(frame)--背包设置
            for _, itemButton in frame:EnumerateValidItems() do
                if itemButton.hasItem then
                    local slotID, bagID= itemButton:GetSlotAndBagID()--:GetID() GetBagID()
                    WoWTools_ItemMixin:SetupInfo(itemButton, {bag={bag=bagID, slot=slotID}})
                else
                    WoWTools_ItemMixin:SetupInfo(itemButton)
                end
            end
        end

        WoWTools_DataMixin:Hook('ContainerFrame_GenerateFrame',function()
            for _, frame in ipairs(ContainerFrameSettingsManager:GetBagsShown()) do
                if not frame.SetBagInfo then
                    setBags(frame)

                    WoWTools_DataMixin:Hook(frame, 'UpdateItems', function(f)
                        setBags(f)
                    end)
                    frame.SetBagInfo=true
                end
            end
        end)
    end
end
