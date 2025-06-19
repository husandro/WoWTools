


function WoWTools_TooltipMixin:Set_Achievement(tooltip, achievementID)--成就
    if not achievementID or WoWTools_FrameMixin:IsLocked(tooltip) then
        return
    end

    tooltip:AddLine(' ')
    local _, name, points, completed, _, _, _, _, flags, icon, _, isGuild = GetAchievementInfo(achievementID)

    tooltip:AddDoubleLine(
        'achievementID'..WoWTools_DataMixin.Icon.icon2..(flags==0x20000 and '|cffff00ff'..WoWTools_DataMixin.Icon.wow2..achievementID or achievementID),
        icon and '|T'..icon..':'..self.iconSize..'|t'..icon
    )


--点数
    tooltip.textLeft:SetText(
        points..(WoWTools_DataMixin.onlyChinese and '点' or RESAMPLE_QUALITY_POINT)
    )
    tooltip.text2Left:SetText(--否是完成
        completed
        and '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '已完成' or CRITERIA_COMPLETED)
        or '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '未完成' or ACHIEVEMENTFRAME_FILTER_INCOMPLETE)
    )

    if isGuild or flags==0x4000 then
        tooltip.textRight:SetText(
            '|cnGREEN_FONT_COLOR:'
            ..(WoWTools_DataMixin.onlyChinese and '公会' or GUILD)
        )
    else
        tooltip.textRight:SetText('')
    end

    if flags==0x20000 then
        tooltip.text2Right:SetText(
            WoWTools_DataMixin.Icon.net2
            ..'|cffff00ff'
            ..(WoWTools_DataMixin.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET)
        )
    else
        tooltip.text2Right:SetText('')
    end

    WoWTools_TooltipMixin:Set_Web_Link(tooltip, {type='achievement', id=achievementID, name=name, col=nil, isPetUI=false})--取得网页，数据链接

    WoWTools_Mixin:Call(GameTooltip_CalculatePadding, tooltip)
end

