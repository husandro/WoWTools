function WoWToolsButton_OnLoad(self)
    self:EnableMouseWheel(true)
    self:RegisterForClicks(WoWTools_DataMixin.LeftButtonDown, WoWTools_DataMixin.RightButtonDown)
end

function WoWToolsMenu_OnLoad(self)
    self:EnableMouseWheel(true)
    self:RegisterForMouse("RightButtonDown", 'LeftButtonDown', "LeftButtonUp", 'RightButtonUp')
    WoWTools_TextureMixin:SetButton(self, {alpha=0.5})
end

function WoWToolsButton_OnLeave(self)
    GameTooltip_Hide()
    if self.set_alpha then
        self:set_alpha()
    end
end

function WoWToolsButton_OnEnter(self)
    if self.tooltip then
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:ClearLines()
        if type(self.tooltip)=='function' then
            self:tooltip(GameTooltip)
        else
            GameTooltip:AddLine(self.tooltip)
        end
        GameTooltip:Show()
    end
    if self.set_alpha then
        self:set_alpha()
    end
end