local e= select(2, ...)
WoWTools_SpellItemMixin={}




local function set_tooltip(tooltip, data)
    if type(data)~='table' then
        return
    end
    if data.link or data.itemLink or data.spellLink then
        tooltip:SetHyperlink(data.link or data.itemLink or data.spellLink)

    elseif data.itemID then
        if C_ToyBox.GetToyInfo(data.itemID) then
            tooltip:SetToyByItemID(data.itemID)
        else
            tooltip:SetItemByID(data.itemID)
        end

    elseif data.spellID then
        tooltip:SetSpellByID(data.spellID)

    elseif data.currencyID then
        tooltip:SetCurrencyByID(data.currencyID)

    elseif data.widgetSetID then
        GameTooltip_AddWidgetSet(tooltip, data.widgetSetID);
    end 
    if data.tooltip then
        GameTooltip_AddNormalLine(tooltip, type(data.tooltip)=='function' and data.tooltip() or data.tooltip, true)
    end
end







function WoWTools_SpellItemMixin:SetTooltip(tooltip, data, root, frame)    
    if root then
        root:SetTooltip(function(tip, description)
            set_tooltip(tip, description.data)
        end)
    elseif frame then
        tooltip= tooltip or GameTooltip
        tooltip:SetOwner(frame, "ANCHOR_LEFT");
        set_tooltip(tooltip, data)
        tooltip:Show();
    else
        set_tooltip(tooltip, data)
    end
end












function WoWTools_SpellItemMixin:GetName(spellID, itemID)--取得，法术，物品，名称
    local cool= e.GetSpellItemCooldown(spellID, itemID) or ''
    local col
    if spellID then
        e.LoadDate({id=spellID, type='spell'})
        local desc=''
        local mountID =C_MountJournal.GetMountFromSpell(spellID)
        if mountID then--坐骑
            if not select(11, C_MountJournal.GetMountInfoByID(mountID)) then
                desc='|A:Islands-QuestBangDisable:0:0|a|cff9e9e9e'..(e.onlyChinese and '未收集' or NOT_COLLECTED )..'|r'
                col='|cff9e9e9e'
            end
        else
            local isPet= not IsPlayerSpell(spellID)
            desc= isPet and '|A:WildBattlePet:0:0|a' or ''
            if C_Spell.DoesSpellExist(spellID) then
                if not IsSpellKnownOrOverridesKnown(spellID, isPet) then
                    col='|cff9e9e9e'
                    desc=desc..('|A:Islands-QuestBangDisable:0:0|a|cff9e9e9e'..(e.onlyChinese and '未学习' or TRADE_SKILLS_UNLEARNED_TAB)..'|r')
                end
            else
                desc=desc..'|A:Islands-QuestBangDisable:0:0|a'
                col='|cff9e9e9e'
            end
        end



        return '|T'..(C_Spell.GetSpellTexture(spellID) or 0)..':0|t'
            ..'|cff00ccff['..(e.cn(C_Spell.GetSpellName(spellID), {spellID=spellID, isName=true}) or ('spellID '..spellID))..']|r'
            ..desc,

            col

    elseif itemID then
        e.LoadDate({id=itemID, type='item'})
        local desc=''
        if C_ToyBox.GetToyInfo(itemID) then
            if not PlayerHasToy(itemID) then
                desc= '|A:Islands-QuestBangDisable:0:0|a|cff9e9e9e'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
                col='|cff9e9e9e'
            end
        else
            local num= C_Item.GetItemCount(itemID, true, false, true, true) or ''
            if num==0 then
                col='|cff9e9e9e'
            end
            desc= ' x'..num..' '
        end

        return
            '|T'..(C_Item.GetItemIconByID(itemID) or 0)..':0|t'
            ..(col or '')
            ..'['..(e.cn(C_Item.GetItemNameByID(itemID), {itemID=itemID, isName=true}) or ('itemID '..itemID))..']'
            ..desc
            ..cool,

            col
    end
end

