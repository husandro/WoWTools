function WoWToolsButton_OnLoad(self)
    self:EnableMouseWheel(true)
    self:RegisterForClicks(WoWTools_DataMixin.LeftButtonDown, WoWTools_DataMixin.RightButtonDown)
end

function WoWToolsButton_OnLeave(self)
    GameTooltip_Hide()
    if self.set_alpha then
        self:set_alpha()
    elseif self.alpha then
        self:SetAlpha(self:IsMouseOver() and 1 or self.alpha)
    end
end

function WoWToolsButton_OnEnter(self)
    if self.tooltip then
        GameTooltip:SetOwner(self, self.owner or 'ANCHOR_LEFT')
        GameTooltip:ClearLines()
        if type(self.tooltip)=='function' then
            self:tooltip(GameTooltip)
        else
            GameTooltip:AddLine(self.tooltip, nil, nil, nil, true)
        end
        GameTooltip:Show()
    end
    if self.set_alpha then
        self:set_alpha()
    elseif self.alpha then
        self:SetAlpha(self:IsMouseOver() and 1 or self.alpha)
    end
end