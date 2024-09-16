

local function Blizzard_GenericTraitUI(self)
    local currencyInfo = self:GetParent().treeCurrencyInfo and self:GetParent().treeCurrencyInfo[1] or {}
    if not currencyInfo.traitCurrencyID or currencyInfo.traitCurrencyID<=0 then
        return
    end
    local overrideIcon = select(4, C_Traits.GetTraitCurrencyInfo(currencyInfo.traitCurrencyID))
    GameTooltip:AddDoubleLine(format('traitCurrencyID: %d', currencyInfo.traitCurrencyID), format('|T%d:0|t%d', overrideIcon or 0, overrideIcon or 0))
    GameTooltip:Show()
end







function WoWTools_TooltipMixin.AddOn.Blizzard_GenericTraitUI()
    GenericTraitFrame.Currency:HookScript('OnEnter', Blizzard_GenericTraitUI)
end
