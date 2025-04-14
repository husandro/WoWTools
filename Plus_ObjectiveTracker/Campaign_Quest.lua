--战役，任务 CampaignQuestObjectiveTracker

local function Clear_CampaignQuest()
    local tab, num= {}, 0
    for i= 1, C_QuestLog.GetNumQuestWatches() or 0, 1 do
        local questID= C_QuestLog.GetQuestIDForQuestWatchIndex(i)
        if questID
            and questID>0
            and C_CampaignInfo.IsCampaignQuest(questID)
            and C_QuestLog.RemoveQuestWatch(questID)--移除
        then
            num= num+1
            table.insert(tab, questID)
        end
    end
    return tab, num
end




local function Init()
    WoWTools_ObjectiveMixin:Add_ClearAll_Button(CampaignQuestObjectiveTracker, WoWTools_DataMixin.onlyChinese and '战役' or TRACKER_HEADER_CAMPAIGN_QUESTS, function(self)
        local tab, num= Clear_CampaignQuest()
        for index, questID in pairs(tab) do
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

function WoWTools_ObjectiveMixin:Clear_CampaignQuest()
    return Clear_CampaignQuest()
end