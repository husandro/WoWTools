--[[
if ( strsub(link, 1, 13) == "perksactivity" ) then
		local _, perksActivityID = strsplit(":", link);
		if ( not EncounterJournal ) then
			EncounterJournal_LoadUI();
		end
		MonthlyActivitiesFrame_OpenFrameToActivity(tonumber(perksActivityID));
if ( not EncounterJournal ) then
    EncounterJournal_LoadUI();
end
MonthlyActivitiesFrame_OpenFrameToActivity(tonumber(perksActivityID))
]]

local function Clear_MonthlyActivities()
    local tab, num= {}, 0
    for _, perksActivityIDs in pairs(C_PerksActivities.GetTrackedPerksActivities() or {}) do
        for _, perksActivityID in pairs(perksActivityIDs) do
            C_PerksActivities.RemoveTrackedPerksActivity(perksActivityID)
            num= num+1
            table.insert(tab, perksActivityID)
        end
    end
    return tab, num
end




local function Init()
    WoWTools_ObjectiveMixin:Add_ClearAll_Button(MonthlyActivitiesObjectiveTracker, WoWTools_DataMixin.onlyChinese and '旅行者日志' or TRACKER_HEADER_MONTHLY_ACTIVITIES, function(self)
        local tab, num= Clear_MonthlyActivities()
        if num > 0 then
            for index, perksActivityID in pairs(tab) do
                print(index..') ',
                    C_PerksActivities.GetPerksActivityChatLink(perksActivityID) or perksActivityID
                )
            end
            self:print_text(num)
        end
    end)
end








--旅行者日志 MonthlyActivitiesObjectiveTracker
function WoWTools_ObjectiveMixin:Init_MonthlyActivities()
    Init()
end

function WoWTools_ObjectiveMixin:Clear_MonthlyActivities()
    return Clear_MonthlyActivities()
end