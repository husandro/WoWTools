








function WoWTools_TooltipMixin:Set_Mount(tooltip, mountID, type)--坐骑
    if WoWTools_FrameMixin:IsLocked(tooltip) or not mountID then
        return
    elseif mountID==268435455 then
        self:Set_Spell(tooltip, 150544)--法术
        return
    end

    tooltip:AddLine(' ')
    --local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, isFiltered, isCollected, mountID, isForDragonriding = C_MountJournal.GetDisplayedMountInfo(elementData.index)
    local creatureName, spellID, _,isActive, isUsable, _, _, isFactionSpecific, faction, _, isCollected, _, isForDragonriding =C_MountJournal.GetMountInfoByID(mountID)

    WoWTools_Mixin:Load({id=spellID, type='spell'})

    tooltip:AddDoubleLine(
        spellID and '|T'..(C_Spell.GetSpellTexture(spellID) or 0)..':0|t'
        ..'spellID'
        ..WoWTools_DataMixin.Icon.icon2
        ..'|cffffffff'..spellID,

        'mountID'
        ..WoWTools_DataMixin.Icon.icon2
        ..'|cffffffff'
        ..mountID
    )

    local textRight
    if isFactionSpecific then
        if faction==0 then
            textRight= format(
                WoWTools_DataMixin.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION,
                format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.Horde, WoWTools_DataMixin.onlyChinese and '部落' or THE_HORDE)
            )
        elseif faction==1 then
            textRight= format(
                WoWTools_DataMixin.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION,
                format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.NONE, WoWTools_DataMixin.onlyChinese and '联盟' or THE_ALLIANCE)
            )
        end
    elseif isForDragonriding then
        textRight= format(WoWTools_DataMixin.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, WoWTools_DataMixin.onlyChinese and '驭空术' or MOUNT_JOURNAL_FILTER_DRAGONRIDING)
    end
    tooltip.textRight:SetText(textRight or '')

    local creatureDisplayInfoID, _, source, isSelfMount, _, _, animID, spellVisualKitID = C_MountJournal.GetMountInfoExtraByID(mountID)
    if creatureDisplayInfoID then
        tooltip:AddDoubleLine(
            'creatureDisplayInfoID'
            ..WoWTools_DataMixin.Icon.icon2
            ..'|cffffffff'
            ..creatureDisplayInfoID,

            isSelfMount and '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '变形' or TUTORIAL_TITLE61_DRUID)
        )
    end

    if source then--显示来源
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_TextMixin:CN(source), nil,nil,nil,true)
    end

--设置, 3D模型
    self:Set_Item_Model(tooltip, {
        creatureDisplayID=creatureDisplayInfoID,
        animID=animID,
        spellVisualKitID=spellVisualKitID,
    })
    tooltip.text2Left:SetText(
        isCollected
        and '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '已收集' or COLLECTED)..'|r'
        or ('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '未收集' or NOT_COLLECTED)..'|r')
    )

--召唤坐骑 
    local can= isCollected and isUsable and not isActive and not UnitCastingInfo('player')
    if can and IsAltKeyDown() then
        C_MountJournal.SummonByID(mountID)
        print(WoWTools_DataMixin.addName, self.addName, spellID and C_Spell.GetSpellLink(spellID), '|cnGREEN_FONT_COLOR:Alt+'..(WoWTools_DataMixin.onlyChinese and '召唤坐骑' or MOUNT))
    end
    local col= can and '|cnGREEN_FONT_COLOR:' or '|cff9e9e9e'
    tooltip:AddDoubleLine(
        col..(WoWTools_DataMixin.onlyChinese and '召唤坐骑' or MOUNT),
        col..'Alt+|A:NPE_Icon:0:0|a'
    )

    if type and MountJournal and MountJournal:IsVisible() and creatureName then
        MountJournalSearchBox:SetText(creatureName)
    end
    self:Set_Web_Link(tooltip, {type='spell', id=spellID, name=creatureName, col=nil, isPetUI=false})--取得网页，数据链接    

    WoWTools_Mixin:Call(GameTooltip_CalculatePadding, tooltip)
end

