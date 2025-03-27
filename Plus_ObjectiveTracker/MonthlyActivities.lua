





local function Init()
    WoWTools_ObjectiveMixin:Add_ClearAll_Button(MonthlyActivitiesObjectiveTracker, WoWTools_Mixin.onlyChinese and '旅行者日志' or TRACKER_HEADER_MONTHLY_ACTIVITIES, function(self)
        local num=0
        for _, perksActivityIDs in pairs(C_PerksActivities.GetTrackedPerksActivities() or {}) do
            for _, perksActivityID in pairs(perksActivityIDs) do
                C_PerksActivities.RemoveTrackedPerksActivity(perksActivityID)
                num= num+1
            end
        end
        self:print_text(num)
    end)
end








--旅行者日志 MonthlyActivitiesObjectiveTracker
function WoWTools_ObjectiveMixin:Init_MonthlyActivities()
    Init()
end