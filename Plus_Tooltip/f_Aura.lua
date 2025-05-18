



function WoWTools_TooltipMixin:Set_All_Aura(tooltip, data)
    local spellID= data.id

    local name= C_Spell.GetSpellName(spellID)
    local icon= C_Spell.GetSpellTexture(spellID)

    tooltip:AddLine(' ')

    tooltip:AddDoubleLine('auraID '..spellID, icon and '|T'..icon..':'..self.iconSize..'|t'..icon)

    local mountID = C_MountJournal.GetMountFromSpell(spellID)
    if mountID then
        WoWTools_TooltipMixin:Set_Mount(tooltip, mountID, 'aura')
    else
        WoWTools_TooltipMixin:Set_Web_Link(tooltip, {type='spell', id=spellID, name=name, col=nil, isPetUI=false})--取得网页，数据链接
    end
end




--来源
function WoWTools_TooltipMixin:Set_Buff(_, tooltip, ...)
    local data=C_UnitAuras.GetAuraDataByIndex(...)
    local source= data and data.sourceUnit
    if not source then
        return
    end

    local r, g ,b , col= select(2, WoWTools_UnitMixin:GetColor(source, nil))
    if r and g and b and tooltip.backgroundColor then
        tooltip:Set_BG_Color(r,g,b, 0.3)
    end
    if source~='player' and tooltip.Portrait then
        SetPortraitTexture(tooltip.Portrait, source)
        tooltip.Portrait:SetShown(true)
    end
    local text= source=='player' and (WoWTools_DataMixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)
            or source=='pet' and (WoWTools_DataMixin.onlyChinese and '宠物' or PET)
            or UnitIsPlayer(source) and WoWTools_UnitMixin:GetPlayerInfo({unit=source, reName=true})
            or UnitName(source) or _G[source] or source

    tooltip:AddLine((col or '|cffffffff') ..format(WoWTools_DataMixin.onlyChinese and '来源：%s' or RUNEFORGE_LEGENDARY_POWER_SOURCE_FORMAT, text)..'|r')

    GameTooltip_CalculatePadding(tooltip)
end