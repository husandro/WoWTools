

local P_Save={
    disabled= not WoWTools_DataMixin.Player.husandro,
    scale= WoWTools_DataMixin.Player.husandro and 0.85 or 1,
    autoHide= WoWTools_DataMixin.Player.husandro and true or nil
}


local function Save()
    return WoWToolsSave['ObjectiveTracker']
end












local function Init()
    WoWTools_ObjectiveMixin:Init_Quest()
    WoWTools_ObjectiveMixin:Init_Campaign_Quest()
    WoWTools_ObjectiveMixin:Init_World_Quest()
    WoWTools_ObjectiveMixin:Init_Achievement()
    WoWTools_ObjectiveMixin:Init_Professions()
    WoWTools_ObjectiveMixin:Init_MonthlyActivities()
    WoWTools_ObjectiveMixin:Init_ScenarioObjective()
    WoWTools_ObjectiveMixin:Init_ObjectiveTrackerFrame()
    WoWTools_ObjectiveMixin:Init_ObjectiveTrackerShared()

    Init=function()end
end





local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWToolsSave['ObjectiveTracker']= WoWToolsSave['ObjectiveTracker'] or P_Save

           WoWTools_ObjectiveMixin.addName= '|A:Objective-Nub:0:0|a|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '目标追踪栏' or HUD_EDIT_MODE_OBJECTIVE_TRACKER_LABEL)..'|r'

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name=WoWTools_ObjectiveMixin.addName,
                tooltip='|cnRED_FONT_COLOR:Bug',
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    Init()
                    print(
                        WoWTools_DataMixin.Icon.icon2..WoWTools_ObjectiveMixin.addName,
                        WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                        WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                    )
                end
            })

            if not Save().disabled then
                Init()
            end

            self:UnregisterEvent(event)
        end
    end
end)


--[[
local Frames={
    'QuestObjectiveTracker',
    'CampaignQuestObjectiveTracker',
    'WorldQuestObjectiveTracker',
    'AchievementObjectiveTracker',
    'ProfessionsRecipeTracker',
    'MonthlyActivitiesObjectiveTracker',
    'BonusObjectiveTracker', --.Header
}]]

