



--战役，任务 CampaignQuestObjectiveTracker
local function Init()
    WoWTools_ObjectiveMixin:Add_ClearAll_Button(CampaignQuestObjectiveTracker, WoWTools_DataMixin.onlyChinese and '战役' or TRACKER_HEADER_CAMPAIGN_QUESTS, function(self)
        local questIDS, num= {}, 0
        for i= 1, C_QuestLog.GetNumQuestWatches() or 0, 1 do
            local questID= C_QuestLog.GetQuestIDForQuestWatchIndex(i)
            if questID and questID>0 and C_CampaignInfo.IsCampaignQuest(questID) then
                table.insert(questIDS, questID)
            end
        end
        for index, questID in pairs(questIDS) do
           local wasRemoved= C_QuestLog.RemoveQuestWatch(questID)
           if wasRemoved then
                print(index..')', GetQuestLink(questID) or questID)
                num=num+1
            end
        end
        self:print_text(num)
    end)
end




function WoWTools_ObjectiveMixin:Init_Campaign_Quest()
    Init()
end