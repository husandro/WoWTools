if BankFrameTab2 then
    return
end

function WoWTools_ItemMixin.Frames:BankFrame()
    hooksecurefunc(BankPanelItemButtonMixin, 'Refresh', function(btn)
        WoWTools_ItemMixin:SetupInfo(btn, {bag={bag=btn:GetBankTabID(), slot= btn:GetContainerSlotID()}})
    end)
end