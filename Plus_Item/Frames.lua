
--boss掉落，物品, 可能，会留下 StaticPopup1 框架
function WoWTools_ItemMixin.Frames:BossBanner_ConfigureLootFrame()
    hooksecurefunc('BossBanner_ConfigureLootFrame', function(lootFrame, data)--LevelUpDisplay.lua
        WoWTools_ItemMixin:SetItemStats(lootFrame, data.itemLink, {point=lootFrame.Icon})
    end)
end










function WoWTools_ItemMixin.Frames:DungeonCompletionAlertFrameReward_SetRewardItem()
    --boss掉落，物品, 可能，会留下 StaticPopup1 框架
    hooksecurefunc('BossBanner_ConfigureLootFrame', function(lootFrame, data)--LevelUpDisplay.lua
        WoWTools_ItemMixin:SetItemStats(lootFrame, data.itemLink, {point=lootFrame.Icon})
    end)

        --拾取时, 弹出, 物品提示，信息, 战利品
    --AlertFrameSystems.lua
    hooksecurefunc('DungeonCompletionAlertFrameReward_SetRewardItem', function(frame, itemLink)
        WoWTools_ItemMixin:SetItemStats(frame, frame.itemLink or itemLink , {point=frame.texture})
    end)
    hooksecurefunc('LootWonAlertFrame_SetUp', function(frame)
        WoWTools_ItemMixin:SetItemStats(frame, frame.hyperlink, {point= frame.lootItem.Icon})
    end)
    hooksecurefunc('LootUpgradeFrame_SetUp', function(frame)
        WoWTools_ItemMixin:SetItemStats(frame, frame.hyperlink, {point=frame.Icon})
    end)

    hooksecurefunc('LegendaryItemAlertFrame_SetUp', function(frame)
        WoWTools_ItemMixin:SetItemStats(frame, frame.hyperlink, {point= frame.Icon})
    end)


    hooksecurefunc(LootItemExtendedMixin, 'Init', function(frame, itemLink2, originalQuantity, _, isCurrency)--ItemDisplay.lua
        local _, _, _, _, itemLink = ItemUtil.GetItemDetails(itemLink2, originalQuantity, isCurrency)
        WoWTools_ItemMixin:SetItemStats(frame, itemLink, {point= frame.Icon})
    end)
end
















--拾取
function WoWTools_ItemMixin.Frames:LootFrame()

    hooksecurefunc(LootFrame, 'Open', function(frame)--LootFrame.lua
        if not frame.ScrollBox:GetView() then
            return
        end
        for index, btn in pairs(frame.ScrollBox:GetFrames() or {}) do
            WoWTools_ItemMixin:SetupInfo(btn.Item, {lootIndex=btn.GetOrderIndex() or btn:GetSlotIndex() or index})
        end
    end)
    hooksecurefunc(LootFrame.ScrollBox, 'SetScrollTargetOffset', function(frame)
        if not frame:GetView() then
            return
        end
        for index, btn in pairs(frame:GetFrames() or {}) do
            WoWTools_ItemMixin:SetupInfo(btn.Item, {lootIndex=btn.GetOrderIndex() or btn:GetSlotIndex() or index})
        end
    end)
end


--银行
function WoWTools_ItemMixin.Frames:BankPanelItemButtonMixin()
    hooksecurefunc( BankPanelItemButtonMixin, 'Refresh', function (frame)
        WoWTools_ItemMixin:SetupInfo(frame, {itemLink=frame.itemInfo and frame.itemInfo.hyperlink})
    end)

--银行, BankFrame.lua
    hooksecurefunc('BankFrameItemButton_Update', function(frame)
        if not frame.isBag then
            local bag, slot= WoWTools_BankMixin:GetBagAndSlot(frame)
            WoWTools_ItemMixin:SetupInfo(frame, {bag={bag=bag, slot=slot}})
            --WoWTools_ItemMixin:SetupInfo(frame, {bag={bag=frame:GetParent():GetID(), slot=frame:GetID()}})
        end
    end)

--战团银行
    hooksecurefunc(BankPanelItemButtonMixin, 'Refresh', function(frame)
        local info= frame.itemInfo or {}
        info.isShow=true
        WoWTools_ItemMixin:SetupInfo(frame, info)
    end)
end













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

        hooksecurefunc('ContainerFrame_GenerateFrame',function()
            for _, frame in ipairs(ContainerFrameSettingsManager:GetBagsShown()) do
                if not frame.SetBagInfo then
                    setBags(frame)

                    hooksecurefunc(frame, 'UpdateItems', function(f)

                        setBags(f)
                    end)
                    frame.SetBagInfo=true
                end
            end
        end)
    end
end
