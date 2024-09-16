


function WoWTools_TooltipMixin:Init_SetPoint()
    hooksecurefunc("GameTooltip_SetDefaultAnchor", function(frame, parent)--位置
        if WoWTools_TooltipMixin.Save.setDefaultAnchor and not (WoWTools_TooltipMixin.Save.inCombatDefaultAnchor and UnitAffectingCombat('player')) then
            frame:ClearAllPoints()
            frame:SetOwner(
                parent,
                WoWTools_TooltipMixin.Save.cursorRight and 'ANCHOR_CURSOR_RIGHT' or 'ANCHOR_CURSOR_LEFT',
                WoWTools_TooltipMixin.Save.cursorX or 0,
                WoWTools_TooltipMixin.Save.cursorY or 0
            )
        end
    end)
end