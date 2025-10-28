--艾泽拉斯之心
function WoWTools_TooltipMixin:Set_Azerite(tooltip, powerID)
    if not powerID or WoWTools_FrameMixin:IsLocked(tooltip) then
        return
    end

    tooltip:AddLine(
        'powerID'
        ..WoWTools_DataMixin.Icon.icon2
        ..'|cffffffff'
        ..powerID)

--法术
    local info = C_AzeriteEmpoweredItem.GetPowerInfo(powerID)
    if info and info.spellID then
        WoWTools_TooltipMixin:Set_Spell(tooltip, info.spellID)
    else
        WoWTools_DataMixin:Call('GameTooltip_CalculatePadding', tooltip)
    end
end