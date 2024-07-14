if not ObjectiveTrackerContainerMixin then
    return
end


local id, e = ...
local addName= HUD_EDIT_MODE_OBJECTIVE_TRACKER_LABEL
local Save={
    scale= 0.85,
    autoHide=true,
    --inCombatHide=e.Player.husandro,--战斗中隐藏
}
local Initializer














local function Init()
    


end






















--###########
--加载保存数据
--###########
local panel=CreateFrame("Frame")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板
            Initializer= e.AddPanel_Check({
                name= '|A:Objective-Nub:0:0|a'..(e.onlyChinese and '目标追踪栏' or HUD_EDIT_MODE_OBJECTIVE_TRACKER_LABEL),
                tooltip= e.cn(addName),
                value= not Save.disabled,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(id, Initializer:GetName(), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })
            local initializer2= e.AddPanel_Check({
                name= e.onlyChinese and '自动隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE),
                tooltip= (e.onlyChinese and '目标追踪栏' or HUD_EDIT_MODE_OBJECTIVE_TRACKER_LABEL)
                    ..'|n|n'..(e.onlyChinese and '场景战役' or SCENARIOS)..' ...'
                    ..'|nUI WIDGET ...'
                    ..'|n|n'..(e.onlyChinese and '奖励目标' or SCENARIO_BONUS_OBJECTIVES)..' '..e.GetShowHide(false)
                    ..'|n'..(e.onlyChinese and '世界任务' or TRACKER_HEADER_WORLD_QUESTS)..' '..e.GetShowHide(false)
                    ..'|n'..(e.onlyChinese and '战役' or TRACKER_HEADER_CAMPAIGN_QUESTS)..' '..e.GetShowHide(false)
                    ..'|n'..(e.onlyChinese and '追踪任务' or TRACK_QUEST)..' '..e.GetShowHide(false)
                    ..'|n'..(e.onlyChinese and '追踪成就' or TRACKER_HEADER_ACHIEVEMENTS)..' '..e.GetShowHide(false)
                    ..'|n'..(e.onlyChinese and '追踪配方' or PROFESSIONS_TRACK_RECIPE)..' '..e.GetShowHide(false)
                    ..'|n|n'..(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT )..' '..e.GetShowHide(false),
                value= Save.autoHide,
                func= function()
                    Save.autoHide= not Save.autoHide and true or nil
                    print(id, Initializer:GetName(), e.onlyChinese and '自动隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE),
                        e.onlyChinese and '任务追踪栏' or QUEST_OBJECTIVES, e.GetEnabeleDisable(Save.autoHide)
                    )
                    if ObjectiveTrackerFrame.Header.MinimizeButton.set_evnet then
                        ObjectiveTrackerFrame.Header.MinimizeButton:set_evnet()
                    end
                end
            })
            initializer2:SetParentInitializer(Initializer, function() if Save.disabled then return false else return true end end)
            initializer2= e.AddPanel_Check({
                name= e.onlyChinese and '战斗中隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, HIDE),
                value= Save.inCombatHide,
                func= function()
                    Save.inCombatHide= not Save.inCombatHide and true or nil
                    if ObjectiveTrackerFrame.Header.MinimizeButton.set_evnet then
                        ObjectiveTrackerFrame.Header.MinimizeButton:set_evnet()
                    end
                end
            })
            initializer2:SetParentInitializer(Initializer, function() if Save.disabled then return false else return true end end)


            if not Save.disabled then
                Init()
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)