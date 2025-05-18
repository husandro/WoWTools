
WoWTools_HunterMixin={}



function WoWTools_HunterMixin:GetAbilitieIconForTab(tab, line, size)
    local text=''
    for _, spellID in pairs(tab or {}) do
        WoWTools_Mixin:Load({id=spellID, type='spell'})
        local texture= C_Spell.GetSpellTexture(spellID)
        if texture and texture>0 then
            text= format('%s%s|T%d:%d|t', text, line and text~='' and '|n' or '', texture, size or 0)
        end
    end
    return text
end
