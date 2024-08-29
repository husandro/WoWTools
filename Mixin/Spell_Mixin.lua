local e= select(2, ...)
WoWTools_SpellMixin={}

function WoWTools_SpellMixin:GetLink(spellID, isCN)
    if spellID then
        local link= C_Spell.GetSpellLink(spellID)
        if not link then
            e.LoadDate({id=spellID, type='spell'})
--|Hspell:818:0|h[烹饪用火]|h
            link=format('|cff28a3ff|Hspell:%d:0|h[%d]|h|r', spellID, spellID)
        end
        if isCN then
            local name= e.cn(nil, {spellID=spellID, isName=true})
            if name then
                link= link:gsub('%[.-]', '['..name..']')
            end
        end
        return link
    end
end
