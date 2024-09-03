local e= select(2, ...)
WoWTools_SpellItemMixin={
    --set_tooltip
    --SetTooltip
    --GetName
}













function WoWTools_SpellItemMixin:GetName(spellID, itemID)--取得，法术，物品，名称
    local col, name, desc, cool
    if spellID then
        e.LoadDate({id=spellID, type='spell'})

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

    elseif itemID then
        e.LoadDate({id=itemID, type='item'})

        if C_ToyBox.GetToyInfo(itemID) then
            if not PlayerHasToy(itemID) then
                col='|cnRED_FONT_COLOR:'
                desc= '|A:Islands-QuestBangDisable:0:0|a'..(e.onlyChinese and '未收集' or NOT_COLLECTED)
            else
                cool= e.GetSpellItemCooldown(nil, itemID)
            end
        else
            local num= C_Item.GetItemCount(itemID, true, false, true, true) or 0
            if num==0 then
                col='|cff9e9e9e'
            else
                cool= e.GetSpellItemCooldown(nil, itemID)
            end
            desc= ' x'..num..' '
        end
        name= (e.cn(C_Item.GetItemNameByID(itemID), {itemID=itemID, isName=true}) or ('itemID '..itemID))
        if name then
            name= '|T'..(C_Item.GetItemIconByID(itemID) or 0)..':0|t'..(name:match('|c........(.+)|r') or name)
        end

    end

    if name then
        if desc and col then
            desc= col..desc..'|r'
        end

        return name..(desc or '')..(cool or ''), col

    end
end
