
function WoWTools_TooltipMixin:Set_Azerite(tooltip, powerID)--艾泽拉斯之心
    if powerID then
        tooltip:AddLine(' ')
        tooltip:AddDoubleLine('powerID', powerID)
        local info = C_AzeriteEmpoweredItem.GetPowerInfo(powerID)
        if info and info.spellID then
            WoWTools_TooltipMixin:Set_Spell(tooltip, info.spellID)--法术
        else
            GameTooltip_CalculatePadding(tooltip)
        end
    end
end