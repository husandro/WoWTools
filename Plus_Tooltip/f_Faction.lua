




--声望
function WoWTools_TooltipMixin:Set_Faction(tooltip, factionID)--, frame)
    local info= factionID and WoWTools_FactionMixin:GetInfo(factionID, nil, true)
    if not info.factionID then
        return
    end
    local icon= info.texture and ('|T'..info.texture..':0|t')
                or (info.atlas and '|A:'..info.atlas..':0:0|a')--..info.atlas)
                or info.textureKit and ('|A:MajorFactions_Icons_'..info.textureKit..'512:0:0|a')--..info.textureKit)
                or ''
    if info.friendshipID then
        tooltip:AddDoubleLine(
            'friendshipID '..info.friendshipID,
            (factionID~=info.friendshipID and 'factionID '..info.factionID..' ' or '')
            ..icon..(info.texture or '')
        )
    elseif info.isMajor then
        tooltip:AddLine(
            icon 
            ..(WoWTools_DataMixin.onlyChinese and '阵营' or MAJOR_FACTION_LIST_TITLE)
            ..' '
            ..info.factionID
        )
    else
        tooltip:AddDoubleLine('factionID '..info.factionID, icon..(info.texture or ''))
    end
    if info.isUnlocked then
        if info.factionStandingtext or info.valueText then
            tooltip:AddDoubleLine(info.factionStandingtext or ' ', (info.hasRewardPending or '')..(info.valueText or '')..(info.valueText and info.isParagon and '|A:Banker:0:0|a' or ''))
        end
        if info.hasRewardPending then
            tooltip:AddLine('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '你有未领取的奖励' or WEEKLY_REWARDS_UNCLAIMED_TITLE))
        end
    else
        tooltip:AddLine(
            '|cnRED_FONT_COLOR:'
            ..format(
                WoWTools_DataMixin.onlyChinese and  '%s尚未解锁' or ERR_AZERITE_ESSENCE_SELECTION_FAILED_ESSENCE_NOT_UNLOCKED,
                '|A:greatVault-lock:0:0|a'
            )
        )
    end
    WoWTools_TooltipMixin:Set_Web_Link(tooltip, {type='faction', id=info.friendshipID or info.factionID, name=info.name, col=nil, isPetUI=false})--取得网页，数据链接
    if tooltip==EmbeddedItemTooltip then
        GameTooltip_AddBlankLineToTooltip(tooltip)
    end
    tooltip:Show()
end

