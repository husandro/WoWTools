local e= select(2, ...)
WoWTools_StableFrameMixin={}

e.dropdownIconForPetSpec = {
    [STABLE_PET_SPEC_CUNNING] = "cunning-icon-small",
    [STABLE_PET_SPEC_FEROCITY] = "ferocity-icon-small",
    [STABLE_PET_SPEC_TENACITY] = "tenacity-icon-small",
}

function WoWTools_StableFrameMixin:GetAbilitieIconForTab(tab, line)
    local text=''
    for _, spellID in pairs(tab or {}) do
        e.LoadData({id=spellID, type='spell'})
        local texture= C_Spell.GetSpellTexture(spellID)
        if texture and texture>0 then
            text= format('%s%s|T%d:14|t', text, line and text~='' and '|n' or '', texture)
        end
    end
    return text
end
