
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
