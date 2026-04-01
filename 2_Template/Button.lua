function WoWToolsButton_OnLoad(self)
    self:EnableMouseWheel(true)
    self:RegisterForClicks(WoWTools_DataMixin.LeftButtonDown, WoWTools_DataMixin.RightButtonDown)
end

function WoWToolsMenu_OnLoad(self)
    self:EnableMouseWheel(true)
    self:RegisterForMouse("RightButtonDown", 'LeftButtonDown', "LeftButtonUp", 'RightButtonUp')
end

function WoWToolsButton_OnLeave(self)
    ResetCursor()
    GameTooltip_Hide()
    WoWToolsButton_SetAlpha(self)
end

--.owner= 'ANCHOR_RIGHT'
function WoWToolsButton_OnEnter(self)
    if self.tooltip then
        GameTooltip:SetOwner(self, self.owner or 'ANCHOR_LEFT')
        if type(self.tooltip)=='function' then
            GameTooltip:ClearLines()
            self:tooltip(GameTooltip)
        else
            GameTooltip_SetTitle(GameTooltip, self.tooltip, HIGHLIGHT_FONT_COLOR)
        end
        GameTooltip:Show()
    end
    WoWToolsButton_SetAlpha(self)
end

function WoWToolsButton_SetAlpha(self)
    if self.set_alpha then
        self:set_alpha()
    elseif self.alpha then
        self:SetAlpha(self:IsMouseOver() and 1 or self.alpha)
    end
end
