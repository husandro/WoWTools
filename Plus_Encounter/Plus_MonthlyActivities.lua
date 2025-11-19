--贸易站

--[[
    if self.tracked then
        C_PerksActivities.RemoveTrackedPerksActivity(self.id)
    elseif not self.completed then
        C_PerksActivities.AddTrackedPerksActivity(self.id)
    end
    
MonthlySupersedeActivitiesButtonMixin
MonthlyActivitiesButtonMixin
]]


local function Init()






    Init=function()end
end



function WoWTools_EncounterMixin:Init_MonthlyActivities()--贸易站
    Init()
end