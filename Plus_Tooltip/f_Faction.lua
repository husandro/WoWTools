local e= select(2, ...)




--声望
function WoWTools_TooltipMixin:Set_Faction(tooltip, factionID)--, frame)
    local info= factionID and WoWTools_FactionMixin:GetInfo(factionID, nil, true)
    if not info.factionID then
        return
    end
    local icon= info.texture and ('|T'..info.texture..':0|t'..info.texture)
                or (info.atlas and '|A:'..info.atlas..':0:0|a')--..info.atlas)
    if info.friendshipID then
        tooltip:AddDoubleLine((e.onlyChinese and '个人' or format(QUEST_REPUTATION_REWARD_TITLE, 'NPC'))..' '..info.friendshipID, icon)
    elseif info.isMajor then
        tooltip:AddDoubleLine((e.onlyChinese and '阵营' or MAJOR_FACTION_LIST_TITLE)..' '..info.factionID, icon)
    else
        tooltip:AddDoubleLine((e.onlyChinese and '声望' or REPUTATION)..' '..info.factionID, icon)
    end
    if info.factionStandingtext or info.valueText then
        tooltip:AddDoubleLine(info.factionStandingtext or ' ', (info.hasRewardPending or '')..(info.valueText or '')..(info.valueText and info.isParagon and '|A:Banker:0:0|a' or ''))
    end
    if info.hasRewardPending then
        tooltip:AddLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '你有未领取的奖励' or WEEKLY_REWARDS_UNCLAIMED_TITLE))
    end
    WoWTools_TooltipMixin:Set_Web_Link(tooltip, {type='faction', id=info.friendshipID or info.factionID, name=info.name, col=nil, isPetUI=false})--取得网页，数据链接
    if tooltip==EmbeddedItemTooltip then
        GameTooltip_AddBlankLineToTooltip(tooltip)
    end
    tooltip:Show()
end

