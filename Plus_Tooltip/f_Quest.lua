


--任务
function WoWTools_TooltipMixin:Set_Quest(tooltip, questID, info)
    questID= questID or (info and info.questID or nil)

    if not questID or WoWTools_FrameMixin:IsLocked(tooltip) then
        return
    end

    tooltip:AddLine(WoWTools_DataMixin:GetExpansionText(nil, questID))--任务版本

    local lv=C_QuestLog.GetQuestDifficultyLevel(questID)--等级
    local levelText
    if lv then
        if lv<WoWTools_DataMixin.Player.Level then
            levelText= '|cnGREEN_FONT_COLOR:'..lv..'|r '
        elseif lv>WoWTools_DataMixin.Player.Level then
            levelText= '|cnRED_FONT_COLOR:'..lv..']|r '
        else
            levelText='|cffffffff'..lv..'|r '
        end
        levelText= levelText..(WoWTools_DataMixin.onlyChinese and '等级' or LEVEL)
    end

    tooltip:AddDoubleLine(
        'questID|cffffffff'
        ..WoWTools_DataMixin.Icon.icon2
        ..questID,

        levelText
    )

    if not info then
        local questLogIndex= C_QuestLog.GetLogIndexForQuestID(questID)
        info = questLogIndex and C_QuestLog.GetInfo(questLogIndex)
    end

    local tagInfo = C_QuestLog.GetQuestTagInfo(questID)
    local name
    if tagInfo and tagInfo.tagID then
        local atlas, color = WoWTools_QuestMixin:GetAtlasColor(questID, info, tagInfo, nil)
        local col= color and color.hex or ''
        tooltip:AddDoubleLine(
            col..(atlas or '')..'tagID',
            col..tagInfo.tagID
        )
        name= tagInfo.name
    else
        local tagID= C_QuestLog.GetQuestType(questID)
        if tagID and tagID>0 then
            tooltip:AddDoubleLine('tagID|cffffffff'..WoWTools_DataMixin.Icon.icon2..tagID)
        end
    end

--货币
    local data= WoWTools_QuestMixin:GetRewardInfo(questID)
    local currencyID= data and data.currencyID
    if  data and data.currencyID then
        local info2, num, totale, percent, isMax, canWeek, canEarned, canQuantity= WoWTools_CurrencyMixin:GetInfo(currencyID, nil, nil)
        if info2 and num then
            local icon, isWide, isTrans, col, atlas= WoWTools_CurrencyMixin:GetAccountIcon(currencyID, nil, nil)
            local wowNum= isWide and WoWTools_CurrencyMixin:GetAccountInfo(currencyID)
            tooltip:AddLine(' ')

            tooltip:AddDoubleLine(
                '|T'..(info2.iconFileID or 0)..':'..self.iconSize..'|t'

                ..(isMax and '|cnRED_FONT_COLOR:' or (canWeek or canEarned or canQuantity and '|cnGREEN_FONT_COLOR:') or col or '')
                ..WoWTools_DataMixin:MK(num,3)
                ..'|r '
                ..(percent and (isMax and '|cnRED_FONT_COLOR:' or '')..percent..'%|r' or ''),

                (icon or '')..(wowNum and WoWTools_DataMixin:MK(wowNum) or '')
            )
        end

    end

    self:Set_Web_Link(tooltip, {type='quest', id=questID, name=name or C_QuestLog.GetTitleForQuestID(questID), col=nil, isPetUI=false})--取得网页，数据链接

    WoWTools_DataMixin:Call(GameTooltip_CalculatePadding, tooltip)
end