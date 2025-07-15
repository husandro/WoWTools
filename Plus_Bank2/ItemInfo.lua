if not BankFrameTab2 then
    return
end

function WoWTools_ItemMixin.Frames:BankPanelItemButtonMixin()
--银行
    hooksecurefunc('BankFrameItemButton_Update', function(btn)
        if btn.isBag then
            WoWTools_BagMixin:SetFreeNum(btn)
        else
            if btn.hasItem then
                local bag, slot= WoWTools_BankMixin:GetBagAndSlot(btn)
                WoWTools_ItemMixin:SetupInfo(btn, {bag={bag=bag, slot=slot}})
            else
                WoWTools_ItemMixin:SetupInfo(btn)
            end
        end
    end)
--7到13
    for bagID= NUM_TOTAL_BAG_FRAMES+NUM_REAGENTBAG_FRAMES+1, NUM_CONTAINER_FRAMES do
        local frame= _G['ContainerFrame'..bagID]
        if frame then
            hooksecurefunc(frame, 'UpdateItems', function(f)
                WoWTools_BagMixin:SetFreeNum(BankSlotsFrame['Bag'..(f:GetBagID()-NUM_TOTAL_BAG_FRAMES)])
            end)
        end
    end

--战团银行
    hooksecurefunc(BankPanelItemButtonMixin, 'Refresh', function(btn)
        WoWTools_ItemMixin:SetupInfo(btn, btn.itemInfo)
    end)
end