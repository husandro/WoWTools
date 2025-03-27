
local function Settings(frame, parent)
    if WoWToolsSave['Plus_Target'].setDefaultAnchor and not (WoWToolsSave['Plus_Target'].inCombatDefaultAnchor and UnitAffectingCombat('player')) then
        frame:ClearAllPoints()
        frame:SetOwner(
            parent,
            WoWToolsSave['Plus_Target'].cursorRight and 'ANCHOR_CURSOR_RIGHT' or 'ANCHOR_CURSOR_LEFT',
            WoWToolsSave['Plus_Target'].cursorX or 0,
            WoWToolsSave['Plus_Target'].cursorY or 0
        )
    end
end


function WoWTools_TooltipMixin:Init_SetPoint()
    hooksecurefunc("GameTooltip_SetDefaultAnchor", Settings)
end