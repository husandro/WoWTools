local function Create_BagFreeLabel(button)
    if not button then
        return

    elseif button.set_free then
        button:set_free()
        return
    end

    button.numFreeSlots=WoWTools_LabelMixin:Create(button, {color=true, justifyH='CENTER'})
    button.numFreeSlots:SetPoint('TOP', 0, 2)
    button.numMaxSlots=WoWTools_LabelMixin:Create(button, {justifyH='CENTER', color={r=0.82,g=0.82,b=0.82, a=0.7}})
    button.numMaxSlots:SetPoint('BOTTOM')

    button.NormalTexture:SetAlpha(0.2)

    function button:set_free()
        local hasItem = GameTooltip:SetInventoryItem("player", self:GetInventorySlot())
        local numFreeSlots, maxSlot

        if hasItem then
            local bagID= self:GetBagID()
            numFreeSlots= C_Container.GetContainerNumFreeSlots(bagID)
            maxSlot= C_Container.GetContainerNumSlots(bagID)
        end

        self.numFreeSlots:SetText(numFreeSlots or '')
        self.numMaxSlots:SetText(maxSlot or '')
        self.icon:SetAlpha(hasItem and 1 or 0.2)
    end
    button:set_free()
end




--银行
function WoWTools_ItemMixin.Frames:BankPanelItemButtonMixin()
    
--银行 1-7 背包 Free, BankFrame.lua
    --[[local numBag= NUM_TOTAL_EQUIPPED_BAG_SLOTS+ NUM_REAGENTBAG_FRAMES--5+1
    for i=NUM_BANKBAGSLOTS, 1, -1 do
        local button= BankSlotsFrame['Bag'..i]

        Create_BagFreeLabel(button)

        local frame= _G['ContainerFrame'..(i+numBag)]
        if frame then
            hooksecurefunc(frame, 'UpdateItems', function(f)
                local bagID= f:GetBagID()-NUM_TOTAL_EQUIPPED_BAG_SLOTS+ NUM_REAGENTBAG_FRAMES-1
                local btn= BankSlotsFrame['Bag'..bagID]
                if btn and btn.set_free then
                    btn:set_free()
                end
            end)
        end
    end]]


    --银行, BankFrame.lua
    hooksecurefunc('BankFrameItemButton_Update', function(frame)
        if frame.isBag then
            Create_BagFreeLabel(frame)
        else
            if frame.hasItem then
                local bag, slot= WoWTools_BankMixin:GetBagAndSlot(frame)
                WoWTools_ItemMixin:SetupInfo(frame, {bag={bag=bag, slot=slot}})
            else
                WoWTools_ItemMixin:SetupInfo(frame)
            end
        end
    end)

--战团银行
    --[[hooksecurefunc(BankPanelItemButtonMixin, 'Init', function(frame)
        WoWTools_ItemMixin:SetupInfo(frame, {itemLocation= frame:GetItemLocation()})
        --WoWTools_ItemMixin:SetupInfo(frame, frame.itemInfo )
    end)]]
    --[[hooksecurefunc(BankPanelItemButtonMixin, 'Refresh', function(frame)
        WoWTools_ItemMixin:SetupInfo(frame, {itemLocation= frame:GetItemLocation()})
        --WoWTools_ItemMixin:SetupInfo(frame, frame.itemInfo)
    end)]]
    
    hooksecurefunc(BankPanelItemButtonMixin, 'Refresh', function(frame)
        WoWTools_ItemMixin:SetupInfo(frame, frame.itemInfo)
        --WoWTools_ItemMixin:SetupInfo(frame, frame.itemInfo)
    end)

end