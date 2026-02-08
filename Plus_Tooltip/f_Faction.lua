




--声望
function WoWTools_TooltipMixin:Set_Faction(tooltip, factionID)--, frame)
    local info= not self:IsInCombatDisabled(tooltip)
            and canaccessvalue(factionID)
            and factionID
            and WoWTools_FactionMixin:GetInfo(factionID)
            or {}

    if not info.factionID then
        return
    end



    local size= self.iconSize

    local icon= info.texture and ('|T'..info.texture..':'..size..'|t')
                or (info.atlas and '|A:'..info.atlas..':'..size..':'..size..'|a')
                or info.textureKit and ('|A:majorfactions_icons_'..info.textureKit..'512:'..size..':'..size..'|a')--..info.textureKit)
                or WoWTools_DataMixin.Icon.icon2


    tooltip:AddDoubleLine(
--战团声望
        (C_Reputation.IsAccountWideReputation(factionID) and '|A:questlog-questtypeicon-account:0:0|a' or '')
--名称
        ..(   info.friendshipID and 'friendshipID'
            or (info.isMajor and (WoWTools_DataMixin.onlyChinese and '名望' or JOURNEYS_RENOWN_LABEL))
            or (WoWTools_DataMixin.onlyChinese and '声望' or REPUTATION)
        )
--图标
        ..icon
        ..'|cffffffff'..info.factionID,

        (info.factionStandingtext and (WoWTools_DataMixin.onlyChinese and '等级' or LEVEL)..' |cffffffff'..info.factionStandingtext)
        ..' '
        ..(info.valueText or '')
    )


    if info.hasRewardPending then
        GameTooltip_AddInstructionLine(tooltip,
            info.hasRewardPending
            ..'|cnWARNING_FONT_COLOR:'
            ..(WoWTools_DataMixin.onlyChinese and '你有未领取的奖励' or WEEKLY_REWARDS_UNCLAIMED_TITLE)
        )
    end

    if not info.isUnlocked then
        tooltip:AddLine(
            '|cnWARNING_FONT_COLOR:'
            ..format(
                WoWTools_DataMixin.onlyChinese and  '%s尚未解锁' or ERR_AZERITE_ESSENCE_SELECTION_FAILED_ESSENCE_NOT_UNLOCKED,
                '|A:Professions_Specialization_Lock_Glow:0:0|a'
            )
        )
    end

    if info.expansionID then
         tooltip:AddLine(WoWTools_DataMixin:GetExpansionText(info.expansionID))
    end
    

    WoWTools_TooltipMixin:Set_Web_Link(tooltip, {type='faction', id=info.friendshipID or info.factionID, name=info.name, col=nil, isPetUI=false})--取得网页，数据链接
    tooltip:Show()
end
--[[
    if tooltip==EmbeddedItemTooltip then
        GameTooltip_AddBlankLineToTooltip(tooltip)
    end

    WoWTools_TooltipMixin:CalculatePadding(tooltip)
]]

