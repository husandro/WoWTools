



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
        (atlas and '|A:'..atlas..':'..size..':'..size..'|a' or ' ')..(WoWTools_TextMixin:CN(info.specialization) or ' '),

        (WoWTools_TextMixin:CN(info.familyName) or '')
        ..(info.name and info.name~=info.familyName and '<'..info.name..'>' or '')
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
            icon2,
            WoWTools_DataMixin.onlyChinese and '专精技能' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SPECIALIZATION, ABILITIES)
        )
    end
    if icon~='' then
        tooltip:AddDoubleLine(
            icon,
            WoWTools_DataMixin.onlyChinese and '基础技能' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, BASE_SETTINGS_TAB, ABILITIES)
        )
    end

end



function WoWTools_TooltipMixin:Set_Spell(tooltip, spellID)--, actionID)
    if self:IsInCombatDisabled(tooltip)
        or not canaccessvalue(spellID)
    then
        return
    end

    spellID = spellID or select(2, tooltip:GetSpell())-- or (actionID and C_ActionBar.GetSpell(actionID))

    if issecretvalue(spellID) or not spellID then
        return
    end

    local name, icon, originalIcon
    local spellInfo= C_Spell.GetSpellInfo(spellID)

    if canaccesstable(spellInfo) and spellInfo then
        name= spellInfo.name
        icon= spellInfo.iconID
        originalIcon= spellInfo.originalIconID
    end

    if issecretvalue(name) or not name then
        return
    end



    local spellTexture=  originalIcon or icon
    tooltip:AddLine(' ')
    tooltip:AddDoubleLine(
        spellTexture and '|T'..spellTexture..':'..self.iconSize..'|t|cffffffff'..spellTexture or ' ',

        --'spellID|cffffffff'
        (WoWTools_DataMixin.onlyChinese and '法术' or SPELLS)
        ..WoWTools_DataMixin.Icon.icon2
        ..spellID
    )

    Set_HunterPet(tooltip, spellID, self.iconSize)--猎人兽栏，宠物

    local mountID = spellID~=150544 and C_MountJournal.GetMountFromSpell(spellID)--坐骑
    if mountID then
        self:Set_Mount(tooltip, mountID)
    else
        self:Set_Web_Link(tooltip, {type='spell', id=spellID, name=name, col=nil, isPetUI=false})--取得网页，数据链接
    end

    tooltip.Portrait:settings(spellTexture)

    WoWTools_TooltipMixin:Show(tooltip)
    --tooltip:Show()
end

--[[local overrideSpellID = FindSpellOverrideByID(spellID)
if overrideSpellID and overrideSpellID~=spellID then
   WoWTools_DataMixin:Load(overrideSpellID, 'spell')--加载 item quest spell
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



