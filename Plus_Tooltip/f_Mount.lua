local e= select(2, ...)








function WoWTools_TooltipMixin:Set_Mount(tooltip, mountID, type)--坐骑
    if mountID==268435455 then
        self:Set_Spell(tooltip, 150544)--法术
        return
    end

    tooltip:AddLine(' ')
    --local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, isFiltered, isCollected, mountID, isForDragonriding = C_MountJournal.GetDisplayedMountInfo(elementData.index)
    local creatureName, spellID, _,isActive, isUsable, _, _, isFactionSpecific, faction, _, isCollected, _, isForDragonriding =C_MountJournal.GetMountInfoByID(mountID)

    WoWTools_Mixin:Load({id=spellID, type='spell'})
    tooltip:AddDoubleLine('mountID '..mountID, spellID and '|T'..(C_Spell.GetSpellTexture(spellID) or 0)..':0|t'..'spellID '..spellID or nil)

    local textRight
    if isFactionSpecific then
        if faction==0 then
            textRight= format(
                WoWTools_Mixin.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION,
                format('|A:%s:0:0|a', e.Icon.Horde, WoWTools_Mixin.onlyChinese and '部落' or THE_HORDE)
            )
        elseif faction==1 then
            textRight= format(
                WoWTools_Mixin.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION,
                format('|A:%s:0:0|a', e.Icon.Alliance, WoWTools_Mixin.onlyChinese and '联盟' or THE_ALLIANCE)
            )
        end
    elseif isForDragonriding then
        textRight= format(WoWTools_Mixin.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, WoWTools_Mixin.onlyChinese and '驭空术' or MOUNT_JOURNAL_FILTER_DRAGONRIDING)
    end
    tooltip.textRight:SetText(textRight or '')

    local creatureDisplayInfoID, _, source, isSelfMount, _, _, animID = C_MountJournal.GetMountInfoExtraByID(mountID)
    if creatureDisplayInfoID then
        tooltip:AddDoubleLine(format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WoWTools_Mixin.onlyChinese and '模型' or MODEL, creatureDisplayInfoID), isSelfMount and '|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '变形' or TUTORIAL_TITLE61_DRUID) or nil)
    end

    if source then--显示来源
        tooltip:AddLine(' ')
        tooltip:AddLine(e.cn(source), nil,nil,nil,true)
    end

    self:Set_Item_Model(tooltip, {creatureDisplayID=creatureDisplayInfoID, animID=animID})--设置, 3D模型

    tooltip.text2Left:SetText(isCollected and '|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '已收集' or COLLECTED)..'|r' or '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '未收集' or NOT_COLLECTED)..'|r')
    
    local can= isCollected and isUsable and not isActive and not UnitCastingInfo('player')
    if can and IsAltKeyDown() then
        C_MountJournal.SummonByID(mountID)
        print(WoWTools_Mixin.addName, self.addName, spellID and C_Spell.GetSpellLink(spellID), '|cnGREEN_FONT_COLOR:Alt+'..(WoWTools_Mixin.onlyChinese and '召唤坐骑' or MOUNT))
    end
    local col= can and '|cnGREEN_FONT_COLOR:' or '|cff9e9e9e'
    tooltip:AddDoubleLine(col..(WoWTools_Mixin.onlyChinese and '召唤坐骑' or MOUNT), col..'Alt+|A:NPE_Icon:0:0|a')

    if type and MountJournal and MountJournal:IsVisible() and creatureName then
        MountJournalSearchBox:SetText(creatureName)
    end
    self:Set_Web_Link(tooltip, {type='spell', id=spellID, name=creatureName, col=nil, isPetUI=false})--取得网页，数据链接    
end

