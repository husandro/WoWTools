
--任务 QuestObjectiveTracker QuestObjectiveTrackerMixin







local function Init()
    WoWTools_ObjectiveMixin:Add_ClearAll_Button(QuestObjectiveTracker, WoWTools_Mixin.onlyChinese and '任务' or TRACKER_HEADER_QUESTS, function(self)
        local questIDS, num= {}, 0
        for i= 1, C_QuestLog.GetNumQuestWatches() or 0, 1 do
            local questID= C_QuestLog.GetQuestIDForQuestWatchIndex(i)
            if questID and questID>0 and not C_CampaignInfo.IsCampaignQuest(questID) then
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

    hooksecurefunc(QuestObjectiveTracker, 'AddBlock', function(_, block)
        local questID= block.id and tonumber(block.id)
        if questID then
            local color = select(2, WoWTools_QuestMixin:GetAtlasColor(questID))
            if color and block.HeaderText then
                block.HeaderText:SetTextColor(color.r, color.g, color.b)
            end
        end
    end)
end






function WoWTools_ObjectiveMixin:Init_Quest()
    Init()
end