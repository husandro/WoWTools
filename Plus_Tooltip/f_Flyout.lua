local e= select(2, ...)


--法术, 弹出框
function WoWTools_TooltipMixin:Set_Flyout(tooltip, flyoutID)
    local name, _, numSlots, isKnown= GetFlyoutInfo(flyoutID)
    if not name then
        return
    end

    tooltip:AddLine(' ')
    for slot= 1, numSlots do
        local flyoutSpellID, overrideSpellID, isKnown2, spellName = GetFlyoutSlotInfo(flyoutID, slot)
        local spellID= overrideSpellID or flyoutSpellID
        if spellID then
            e.LoadData({id=spellID, type='spell'})
            local name2= e.cn(C_Spell.GetSpellName(spellID), {spellID=spellID, isName=true})
            local icon= C_Spell.GetSpellTexture(spellID)
            if name2 and icon then
                tooltip:AddDoubleLine('|T'..icon..':0|t'..(not isKnown2 and ' |cnRED_FONT_COLOR:' or '')..e.cn(name2)..'|r', (not isKnown2 and '|cnRED_FONT_COLOR:' or '').. spellID..' '..(e.onlyChinese and '法术' or SPELLS)..'('..slot)
            else
                tooltip:AddDoubleLine((not isKnown2 and ' |cnRED_FONT_COLOR:' or '')..spellName..'|r',(not isKnown2 and '|cnRED_FONT_COLOR:' or '')..spellID..' '..(e.onlyChinese and '法术' or SPELLS)..'('..slot)
            end
        end
    end

    local icon
    local btn= tooltip:GetOwner()
    if btn and (btn.IconTexture or btn.icon) then
        icon= (btn.IconTexture or btn.icon):GetTextureFileID()
    end
    tooltip:AddLine(' ')
    tooltip:AddDoubleLine((not isKnown and '|cnRED_FONT_COLOR:' or '')..'flyoutID|r '..flyoutID, icon and icon>0 and format('|T%d:0|t%d', icon, icon), 1,1,1, 1,1,1)
end


