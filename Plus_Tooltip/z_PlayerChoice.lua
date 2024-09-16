local function Blizzard_PlayerChoice()
    hooksecurefunc(PlayerChoicePowerChoiceTemplateMixin, 'OnEnter', function(self)
        if self.optionInfo and self.optionInfo.spellID then
            GameTooltip:ClearLines()
            GameTooltip:SetSpellByID(self.optionInfo.spellID)
            GameTooltip:Show()
        end
    end)

    WoWTools_TooltipMixin.AddOn.Blizzard_PlayerChoice=nil
end


function WoWTools_TooltipMixin.AddOn.Blizzard_PlayerChoice()
    Blizzard_PlayerChoice()
end
