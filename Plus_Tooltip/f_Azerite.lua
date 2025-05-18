--艾泽拉斯之心
function WoWTools_TooltipMixin:Set_Azerite(tooltip, powerID)
    if not powerID then
        return
    end

    tooltip:AddLine(' ')
    tooltip:AddDoubleLine('powerID', powerID)

--法术
    local info = C_AzeriteEmpoweredItem.GetPowerInfo(powerID)
    if info and info.spellID then
        WoWTools_TooltipMixin:Set_Spell(tooltip, info.spellID)
    else
        GameTooltip_CalculatePadding(tooltip)
    end
end