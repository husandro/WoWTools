


function WoWTools_TooltipMixin:Set_Achievement(tooltip, achievementID)--成就
    if not achievementID then
        return
    end

    tooltip:AddLine(' ')
    local _, name, points, completed, _, _, _, _, flags, icon, _, isGuild = GetAchievementInfo(achievementID)

    tooltip:AddDoubleLine('achievementID '..(flags==0x20000 and '|cffff00ff'..WoWTools_DataMixin.Icon.wow2..achievementID..'|r' or achievementID), icon and '|T'..icon..':0|t'..icon)

    tooltip.textLeft:SetText(points..(WoWTools_DataMixin.onlyChinese and '点' or RESAMPLE_QUALITY_POINT))--点数
    tooltip.text2Left:SetText(completed and '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '已完成' or CRITERIA_COMPLETED)..'|r' or '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '未完成' or ACHIEVEMENTFRAME_FILTER_INCOMPLETE)..'|r')--否是完成
    tooltip.textRight:SetText(isGuild and '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '公会' or GUILD) or flags==0x4000 and ('|cffff00ff'..WoWTools_DataMixin.Icon.net2..(WoWTools_DataMixin.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET))  or '')
    if flags==0x20000 then
        tooltip.textRight:SetText(WoWTools_DataMixin.Icon.net2..'|cffff00ff'..(WoWTools_DataMixin.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET))
    end

    WoWTools_TooltipMixin:Set_Web_Link(tooltip, {type='achievement', id=achievementID, name=name, col=nil, isPetUI=false})--取得网页，数据链接
end

