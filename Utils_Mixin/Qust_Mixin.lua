--[[
--QuestUtils.lua
QuestUtils_GetQuestName(questID
]]
local e= select(2, ...)
WoWTools_QuestMixin={}

--function WoWTools_QuestMixin:GetID()

function WoWTools_QuestMixin:GetName(questID)
    return C_TaskQuest.GetQuestInfoByQuestID(questID) or C_QuestLog.GetTitleForQuestID(questID)
end

function WoWTools_QuestMixin:GetLink(questID)
    local link= GetQuestLink(questID)
    if not link then
        local index= C_QuestLog.GetLogIndexForQuestID(questID)
        local info= index and C_QuestLog.GetInfo(index) or {}
        
        local leavel= info.level
        local name= e.cn(info.title or self:GetName(questID) or questID, {questID=questID, isName=true})

        link= '|Hquest:'..questID
            ..(leavel and ':'..info.level or '')
            ..'|h['..name..']|h'
    end
    return link
end
