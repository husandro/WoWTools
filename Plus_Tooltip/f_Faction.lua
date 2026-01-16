




--声望
function WoWTools_TooltipMixin:Set_Faction(tooltip, factionID)--, frame)
    local info= not self:IsInCombatDisabled(tooltip)
            and canaccessvalue(factionID)
            and factionID
            and WoWTools_FactionMixin:GetInfo(factionID)

    if not info or not info.factionID then
        return
    end

    

    local size= self.iconSize

    local icon= info.texture and ('|T'..info.texture..':'..size..'|t')
                or (info.atlas and '|A:'..info.atlas..':'..size..':'..size..'|a')
                or info.textureKit and ('|A:majorfactions_icons_'..info.textureKit..'512:'..size..':'..size..'|a')--..info.textureKit)
                or ''

    local account= C_Reputation.IsAccountWideReputation(factionID) and '|A:questlog-questtypeicon-account:0:0|a' or WoWTools_DataMixin.Icon.icon2



    if info.friendshipID then
        tooltip:AddDoubleLine(
            (factionID~=info.friendshipID and 'friendshipID'..account..'|cffffffff'..info.factionID..' ' or '')
            ..icon
            ..(info.texture and '|cffffffff'..info.texture or ' '),

            'friendshipID'..account..'|cffffffff'..info.friendshipID
        )
    elseif info.isMajor then
        tooltip:AddLine(
            icon
            ..(WoWTools_DataMixin.onlyChinese and '名望' or JOURNEYS_RENOWN_LABEL)
            ..account
            ..'|cffffffff'
            ..info.factionID
        )
    else
        tooltip:AddDoubleLine(
            icon..(info.texture or ' '),

            'factionID'
            ..account
            ..'|cffffffff'
            ..info.factionID
        )
    end
    if info.isUnlocked then
        if info.factionStandingtext or info.valueText then
            tooltip:AddDoubleLine(
                info.factionStandingtext or ' ',

                (info.hasRewardPending or '')
                ..(info.valueText or '')
                ..(info.valueText and info.isParagon and '|A:Banker:0:0|a' or '')
            )
        end
        if info.hasRewardPending then
            tooltip:AddLine(
                '|cnWARNING_FONT_COLOR:'
                ..(WoWTools_DataMixin.onlyChinese and '你有未领取的奖励' or WEEKLY_REWARDS_UNCLAIMED_TITLE)
            )
        end
    else
        tooltip:AddLine(
            '|cnWARNING_FONT_COLOR:'
            ..format(
                WoWTools_DataMixin.onlyChinese and  '%s尚未解锁' or ERR_AZERITE_ESSENCE_SELECTION_FAILED_ESSENCE_NOT_UNLOCKED,
                '|A:Professions_Specialization_Lock_Glow:0:0|a'
            )
        )
    end
    WoWTools_TooltipMixin:Set_Web_Link(tooltip, {type='faction', id=info.friendshipID or info.factionID, name=info.name, col=nil, isPetUI=false})--取得网页，数据链接
    tooltip:Show()
end
--[[
    if tooltip==EmbeddedItemTooltip then
        GameTooltip_AddBlankLineToTooltip(tooltip)
    end

    WoWTools_DataMixin:Call('GameTooltip_CalculatePadding', tooltip)
]]

