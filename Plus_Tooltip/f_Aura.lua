



function WoWTools_TooltipMixin:Set_All_Aura(tooltip, data)
    if self:IsInCombatDisabled(tooltip)
        or not canaccesstable(data)
        or not data
        or not canaccessvalue(data.id)
        or not data.id
    then
        return
    end

    local spellID= data.id

    local name= C_Spell.GetSpellName(spellID)
    local icon= C_Spell.GetSpellTexture(spellID)

    tooltip:AddLine(' ')

    tooltip:AddDoubleLine(
        icon and '|T'..icon..':'..self.iconSize..'|t|cffffffff'..icon or ' ',
        'auraID'..WoWTools_DataMixin.Icon.icon2..'|cffffffff'..spellID
    )

    local mountID = C_MountJournal.GetMountFromSpell(spellID)
    if mountID then
        WoWTools_TooltipMixin:Set_Mount(tooltip, mountID, 'aura')
    else
        WoWTools_TooltipMixin:Set_Web_Link(tooltip, {type='spell', id=spellID, name=name, col=nil, isPetUI=false})--取得网页，数据链接
    end

    tooltip.Portrait:settings(icon)
end




--来源
function WoWTools_TooltipMixin:Set_Buff(_, tooltip, ...)
    if self:IsInCombatDisabled(tooltip) then
        return
    end

    local data= C_UnitAuras.GetAuraDataByIndex(...)
    if not canaccessvalue(data)
        or not data
        or not canaccessvalue(data.sourceUnit)
        or not data.sourceUnit
    then
        return
    end

    local source= data.sourceUnit

    local r, g ,b , col= select(2, WoWTools_UnitMixin:GetColor(source, nil))
    if r and g and b and tooltip.Set_BG_Color then
        tooltip:Set_BG_Color(r,g,b, 0.3)
    end
    if source~='player' and tooltip.Portrait then
        SetPortraitTexture(tooltip.Portrait, source)
    end
    local text= source=='player' and (WoWTools_DataMixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)
            or source=='pet' and (WoWTools_DataMixin.onlyChinese and '宠物' or PET)
            or UnitIsPlayer(source) and WoWTools_UnitMixin:GetPlayerInfo(source, nil, nil, {reName=true})
            or UnitName(source) or _G[source] or source

    tooltip:AddLine(
        (col or '|cffffffff')
        ..format(WoWTools_DataMixin.onlyChinese and '来源：%s' or RUNEFORGE_LEGENDARY_POWER_SOURCE_FORMAT, text)
    )

    WoWTools_TooltipMixin:Show(tooltip)
end