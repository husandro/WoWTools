


function WoWTools_TooltipMixin:Set_Achievement(tooltip, achievementID)--成就
    if self:IsInCombatDisabled(tooltip)
        or not canaccessvalue(achievementID)
        or not achievementID
    then
        return
    end

    local _, name, points, completed, _, _, _, _, flags, icon, rewardText, isGuild = GetAchievementInfo(achievementID)
--奖励
    if rewardText and rewardText~='' then
        tooltip:AddLine(' ')
        local itemID= C_AchievementInfo.GetRewardItemID(achievementID)
        local itemIcon
        if itemID then
            WoWTools_DataMixin:Load(itemID, 'item')
            itemIcon= select(5, C_Item.GetItemInfoInstant(itemID))
        end
        tooltip:AddLine(
            (itemIcon and '|T'..itemIcon..':0|t' or '')
            ..WoWTools_TextMixin:CN(rewardText),
            0, 0.8, 1, true
        )
    end

    tooltip:AddLine(' ')
--id icon    
    tooltip:AddDoubleLine(
        icon and '|T'..icon..':'..self.iconSize..'|t|cffffffff'..icon or ' ',

        'achievementID'
        ..WoWTools_DataMixin.Icon.icon2
        ..(flags==0x20000 and '|cff00ccff'..WoWTools_DataMixin.Icon.wow2 or '|cffffffff')
        ..achievementID
    )
--点数
    local textLeft= (points or 0)..(WoWTools_DataMixin.onlyChinese and '点' or RESAMPLE_QUALITY_POINT)
--否是完成
    local text2Left= completed
                    and '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '已完成' or CRITERIA_COMPLETED)
                    or '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '未完成' or ACHIEVEMENTFRAME_FILTER_INCOMPLETE)
--公会成就
    local textRight= (isGuild or flags==0x4000) and (WoWTools_DataMixin.onlyChinese and '公会成就' or GUILD_ACHIEVEMENTS_TITLE) or nil
--是，战团通用
    local text2Right= flags==0x20000 and (WoWTools_DataMixin.Icon.net2..'|cff00ccff'..(WoWTools_DataMixin.onlyChinese and '战团通用' or ITEM_UPGRADE_DISCOUNT_TOOLTIP_ACCOUNT_WIDE)) or nil

    if tooltip.IsEmbedded then--嵌入式
        tooltip:AddLine(textLeft)
        tooltip:AddLine(text2Left)
        tooltip:AddLine(textRight)
        tooltip:AddLine(text2Right)
    else
        tooltip.textLeft:SetText(textLeft or '')
        tooltip.text2Left:SetText(text2Left or '')
        tooltip.textRight:SetText(textRight or '')
        tooltip.text2Right:SetText(text2Right or '')
    end

    tooltip.Portrait:settings(icon)

    WoWTools_TooltipMixin:Set_Web_Link(tooltip, {type='achievement', id=achievementID, name=name, col=nil, isPetUI=false})--取得网页，数据链接

    WoWTools_DataMixin:Call('GameTooltip_CalculatePadding', tooltip)
end

