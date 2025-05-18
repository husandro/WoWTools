



--猎人兽栏，宠物
local CALL_PET_SPELL_IDS = {
	[0883]=1,
	[83242]=2,
	[83243]=3,
	[83244]=4,
	[83245]=5,
}


local function Set_HunterPet(tooltip, spellID, size)

    local index= CALL_PET_SPELL_IDS[spellID]
    local info= index and C_StableInfo.GetStablePetInfo(index)
    if not info then
        return
    end

    local atlas= WoWTools_DataMixin.Icon[info.specialization]
    tooltip:AddDoubleLine(
        (WoWTools_TextMixin:CN(info.familyName) or '')
        ..(info.name and info.name~=info.familyName and '<'..info.name..'>' or ''),

        (atlas and '|A:'..atlas..':'..size..':'..size..'|a' or '')..(WoWTools_TextMixin:CN(info.specialization) or '')
    )

    local icon, icon2='', ''
    local texture
    for _, abilitie in pairs(info.abilities or info.petAbilities or {}) do
        texture= C_Spell.GetSpellTexture(abilitie)
        if texture and texture>0 then
            icon= icon..'|T'..texture..':'..size..'|t'
        end
    end
    for _, abilitie in pairs(info.specAbilities or {}) do
        texture= C_Spell.GetSpellTexture(abilitie)
        if texture and texture>0 then
            icon2= icon2..'|T'..texture..':'..size..'|t'
        end
    end
    if icon2~='' then
        tooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '专精技能' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SPECIALIZATION, ABILITIES),
            icon2
        )
    end
    if icon~='' then
        tooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '基础技能' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, BASE_SETTINGS_TAB, ABILITIES),
            icon
        )
    end
   
end



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

    local size= self.iconSize

    local spellTexture=  originalIcon or icon
    tooltip:AddLine(' ')
    tooltip:AddDoubleLine('spellID '..spellID, spellTexture and '|T'..spellTexture..':'..size..'|t'..spellTexture)

    Set_HunterPet(tooltip, spellID, size)--猎人兽栏，宠物

    local mountID = spellID~=150544 and C_MountJournal.GetMountFromSpell(spellID)--坐骑
    if mountID then
        WoWTools_TooltipMixin:Set_Mount(tooltip, mountID)
    else
        WoWTools_TooltipMixin:Set_Web_Link(tooltip, {type='spell', id=spellID, name=name, col=nil, isPetUI=false})--取得网页，数据链接
    end

    GameTooltip_CalculatePadding(tooltip)
end

--[[local overrideSpellID = FindSpellOverrideByID(spellID)
if overrideSpellID and overrideSpellID~=spellID then
    WoWTools_Mixin:Load({id=overrideSpellID, type='spell'})--加载 item quest spell
    local link= C_Spell.GetSpellLink(overrideSpellID)
    if link then

    local name2, _, icon2, _, _, _, _, originalIcon2= C_Spell.GetSpellInfo(overrideSpellID)
    link= link or name2
    link= link and link..overrideSpellID or ('overrideSpellID '..overrideSpellID)
    if link then
        spellTexture=  originalIcon2 or icon2 or C_Spell.GetSpellTexture(overrideSpellID)
        GameTooltip:AddDoubleLine(format(WoWTools_DataMixin.onlyChinese and '代替%s' or REPLACES_SPELL, link), spellTexture and '|T'..spellTexture..':'..self.iconSize..'|t'..spellTexture)
    end
end]]



