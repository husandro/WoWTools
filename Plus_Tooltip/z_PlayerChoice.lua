local function Blizzard_PlayerChoice(self)
    if self.optionInfo and self.optionInfo.spellID then
        GameTooltip:ClearLines()
        GameTooltip:SetSpellByID(self.optionInfo.spellID)
        GameTooltip:Show()
    end
end


function WoWTools_TooltipMixin.AddOn.Blizzard_PlayerChoice()
    hooksecurefunc(PlayerChoicePowerChoiceTemplateMixin, 'OnEnter', Blizzard_PlayerChoice)
end
