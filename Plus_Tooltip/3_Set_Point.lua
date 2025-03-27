
local function Settings(frame, parent)
    if WoWToolsSave['Plus_Tootips'].setDefaultAnchor and not (WoWToolsSave['Plus_Tootips'].inCombatDefaultAnchor and UnitAffectingCombat('player')) then
        frame:ClearAllPoints()
        frame:SetOwner(
            parent,
            WoWToolsSave['Plus_Tootips'].cursorRight and 'ANCHOR_CURSOR_RIGHT' or 'ANCHOR_CURSOR_LEFT',
            WoWToolsSave['Plus_Tootips'].cursorX or 0,
            WoWToolsSave['Plus_Tootips'].cursorY or 0
        )
    end
end


function WoWTools_TooltipMixin:Init_SetPoint()
    hooksecurefunc("GameTooltip_SetDefaultAnchor", Settings)
end