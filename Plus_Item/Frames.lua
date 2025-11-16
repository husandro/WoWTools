
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
function WoWTools_ItemMixin.Frames:ContainerFrame1()

    local function Set_BagInfo(frame)
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
    WoWTools_DataMixin:Hook(ContainerFrameCombinedBags, 'UpdateItems', Set_BagInfo)

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
--[[
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
end]]
