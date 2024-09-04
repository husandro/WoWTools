--[[
GetName(spellID)--取得法术，名称
GetLink(spellID, isCN)
]]

local e= select(2, ...)
WoWTools_SpellMixin={}

function WoWTools_SpellMixin:GetLink(spellID, isCN)
    if spellID then
        local link= C_Spell.GetSpellLink(spellID)
        if not link then
            e.LoadData({id=spellID, type='spell'})
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






function WoWTools_SpellMixin:GetName(spellID)--取得法术，名称
    if not spellID then
        return
    end

    local col, name, desc, cool

    e.LoadData({id=spellID, type='spell'})

    local mountID = C_MountJournal.GetMountFromSpell(spellID)
    if mountID then--坐骑
        if not select(11, C_MountJournal.GetMountInfoByID(mountID)) then
            col='|cnRED_FONT_COLOR:'
            desc='|A:Islands-QuestBangDisable:0:0|a'..(e.onlyChinese and '未收集' or NOT_COLLECTED )
        end
    else
        local isPet= not IsPlayerSpell(spellID)
        desc= isPet and '|A:WildBattlePet:0:0|a' or ''
        if C_Spell.DoesSpellExist(spellID) then
            if not IsSpellKnownOrOverridesKnown(spellID, isPet) then
                col='|cnRED_FONT_COLOR:'
                desc=(desc or '')..'|A:Islands-QuestBangDisable:0:0|a'..(e.onlyChinese and '未学习' or TRADE_SKILLS_UNLEARNED_TAB)
            else
                cool=e.GetSpellItemCooldown(spellID, nil)
            end
        else
            desc= (desc or '')..'|A:Islands-QuestBangDisable:0:0|a'
            col='|cff9e9e9e'
        end
    end
    name= e.cn(C_Spell.GetSpellName(spellID), {spellID=spellID, isName=true})
    if name then
        name= name:match('|c........(.+)|r') or name
    end

    name= '|T'..(C_Spell.GetSpellTexture(spellID) or 0)..':0|t'..(name or ('spellID '..spellID))

    if desc and col then
        desc= col..desc..'|r'
    end

    return name..(desc or '')..(cool or ''), col
end
