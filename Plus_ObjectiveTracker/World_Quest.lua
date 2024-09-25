local e= select(2, ...)






--世界，任务 WorldQuestObjectiveTracker
local function Init()
    WoWTools_ObjectiveTrackerMixin:Add_ClearAll_Button(WorldQuestObjectiveTracker, e.onlyChinese and '世界任务' or TRACKER_HEADER_WORLD_QUESTS, function(self)
        local questIDS={}
        for i= 1, C_QuestLog.GetNumWorldQuestWatches() or 0, 1 do
            local questID= C_QuestLog.GetQuestIDForWorldQuestWatchIndex(i)
            if questID and questID>0 then
                table.insert(questIDS, questID)
            end
        end
        local num=0
        for index, questID in pairs(questIDS) do
            local wasRemoved= C_QuestLog.RemoveWorldQuestWatch(questID)
            if wasRemoved then
                print(index..')', GetQuestLink(questID) or questID)
                num=num+1
            end
        end
        self:print_text(num)
    end)
end






function WoWTools_ObjectiveTrackerMixin:Init_World_Quest()
    Init()
end