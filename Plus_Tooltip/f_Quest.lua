local e= select(2, ...)


--任务
function WoWTools_TooltipMixin:Set_Quest(tooltip, questID, info)
    questID= questID or (info and info.questID or nil)
    if not questID then
        return
    end
    tooltip:AddDoubleLine(WoWTools_Mixin:GetExpansionText(nil, questID))--任务版本

    local lv=C_QuestLog.GetQuestDifficultyLevel(questID)--等级
    local levelText
    if lv then
        if lv<e.Player.level then
            levelText= '|cnGREEN_FONT_COLOR:['..lv..']|r'
        elseif lv>e.Player.level then
            levelText= '|cnRED_FONT_COLOR:['..lv..']|r'
        else
            levelText='|cffffffff['..lv..']|r'
        end
    end
    tooltip:AddDoubleLine((e.onlyChinese and '任务' or QUESTS_LABEL)..(levelText or ''), questID)

    if not info then
        local questLogIndex= C_QuestLog.GetLogIndexForQuestID(questID)
        info = questLogIndex and C_QuestLog.GetInfo(questLogIndex)
    end

    local tagInfo = C_QuestLog.GetQuestTagInfo(questID)
    local name
    if tagInfo and tagInfo.tagID then
        local atlas, color = WoWTools_QuestMixin:GetAtlasColor(questID, info, tagInfo, nil)
        local col= color and color.hex or ''
        tooltip:AddDoubleLine(col..(atlas or '')..'tagID', col..tagInfo.tagID)
        name= tagInfo.name
    else
        local tagID= C_QuestLog.GetQuestType(questID)
        if tagID and tagID>0 then
            tooltip:AddDoubleLine('tagID', tagID)
        end
    end
    WoWTools_TooltipMixin:Set_Web_Link(tooltip, {type='quest', id=questID, name=name or C_QuestLog.GetTitleForQuestID(questID), col=nil, isPetUI=false})--取得网页，数据链接
end