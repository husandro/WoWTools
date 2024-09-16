local e= select(2, ...)

function WoWTools_TooltipMixin:Set_Spell(tooltip, spellID)--法术    
    spellID = spellID or select(2, tooltip:GetSpell())
    local name, icon, originalIcon
    local spellInfo= spellID and C_Spell.GetSpellInfo(spellID)
    if spellInfo then
        name= spellInfo.name
        icon= spellInfo.iconID
        originalIcon= spellInfo.originalIconID
    end
    if not name then
        return
    end

    local spellTexture=  originalIcon or icon
    tooltip:AddLine(' ')
    tooltip:AddDoubleLine((e.onlyChinese and '法术' or SPELLS)..' '..spellID, spellTexture and '|T'..spellTexture..':0|t'..spellTexture, 1,1,1, 1,1,1)
    local mountID = spellID~=150544 and C_MountJournal.GetMountFromSpell(spellID)--坐骑
    if mountID then
        WoWTools_TooltipMixin:Set_Mount(tooltip, mountID)
    else
        WoWTools_TooltipMixin:Set_Web_Link(tooltip, {type='spell', id=spellID, name=name, col=nil, isPetUI=false})--取得网页，数据链接
    end
end

--[[local overrideSpellID = FindSpellOverrideByID(spellID)
if overrideSpellID and overrideSpellID~=spellID then
    e.LoadData({id=overrideSpellID, type='spell'})--加载 item quest spell
    local link= C_Spell.GetSpellLink(overrideSpellID)
    if link then

    local name2, _, icon2, _, _, _, _, originalIcon2= C_Spell.GetSpellInfo(overrideSpellID)
    link= link or name2
    link= link and link..overrideSpellID or ('overrideSpellID '..overrideSpellID)
    if link then
        spellTexture=  originalIcon2 or icon2 or C_Spell.GetSpellTexture(overrideSpellID)
        e.tips:AddDoubleLine(format(e.onlyChinese and '代替%s' or REPLACES_SPELL, link), spellTexture and '|T'..spellTexture..':0|t'..spellTexture)
    end
end]]



