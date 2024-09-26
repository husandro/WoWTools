


function WoWTools_TooltipMixin:Init_SetPoint()
    hooksecurefunc("GameTooltip_SetDefaultAnchor", function(frame, parent)--位置
        if self.Save.setDefaultAnchor and not (self.Save.inCombatDefaultAnchor and UnitAffectingCombat('player')) then
            frame:ClearAllPoints()
            frame:SetOwner(
                parent,
                self.Save.cursorRight and 'ANCHOR_CURSOR_RIGHT' or 'ANCHOR_CURSOR_LEFT',
                self.Save.cursorX or 0,
                self.Save.cursorY or 0
            )
        end
    end)
end