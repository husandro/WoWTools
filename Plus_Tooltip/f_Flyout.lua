


--法术, 弹出框
function WoWTools_TooltipMixin:Set_Flyout(tooltip, flyoutID)
    if self:IsInCombatDisabled(tooltip)
        or not canaccessvalue(flyoutID)
        or not flyoutID
    then
        return
    end

    local name, _, numSlots, isKnown= GetFlyoutInfo(flyoutID)

    if not name then
        return
    end

    tooltip:AddLine(' ')
    for slot= 1, numSlots do
        local flyoutSpellID, overrideSpellID, isKnown2, spellName = GetFlyoutSlotInfo(flyoutID, slot)
        local spellID= overrideSpellID or flyoutSpellID
        local col= not isKnown2 and '|cnWARNING_FONT_COLOR:' or (select(2, math.modf(slot/2))==0 and '|cffffffff') or ''
        if spellID then
           WoWTools_DataMixin:Load(spellID, 'spell')
            local name2= WoWTools_TextMixin:CN(C_Spell.GetSpellName(spellID), {spellID=spellID, isName=true})
            local icon= C_Spell.GetSpellTexture(spellID)

            tooltip:AddDoubleLine(
                col..'|T'..(icon or 0)..':'..self.iconSize..'|t'..(name2 or spellName or ''),
                col..spellID..' ('..slot
            )
        end
    end

    local icon
    local btn= tooltip:GetOwner()
    if btn and (btn.IconTexture or btn.icon) then
        icon= (btn.IconTexture or btn.icon):GetTextureFileID()
    end
    tooltip:AddLine(' ')
    tooltip:AddDoubleLine(
        icon and '|T'..icon..':'..self.iconSize..'|t|cffffffff'..icon,

        (not isKnown and '|cnWARNING_FONT_COLOR:' or '')
        ..'flyoutID|r'
        ..WoWTools_DataMixin.Icon.icon2
        ..'|cffffffff'
        ..flyoutID
    )
    WoWTools_TooltipMixin:Show(tooltip)
end


