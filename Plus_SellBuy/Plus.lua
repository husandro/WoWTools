--商人 Plus
function WoWTools_SellBuyMixin:Init_Plus()
    if self.Save.notPlus then
        return
    end

    self:Init_StackSplitFrame()-- 堆叠,数量,框架

    C_Timer.After(2, self.Init_WidthX2)--加宽，框架x2

    hooksecurefunc('MerchantFrame_UpdateCurrencies', function()
        MerchantExtraCurrencyInset:SetShown(false)
        MerchantExtraCurrencyBg:SetShown(false)
        MerchantMoneyInset:SetShown(false)
    end)
end