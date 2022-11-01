local id, e = ...
local Save={}
local addName=RAID_FRAMES_LABEL

for index, tab in pairs(EditModeSettingDisplayInfoManager.systemSettingDisplayInfo[Enum.EditModeSystem.UnitFrame]) do
    if tab.name==HUD_EDIT_MODE_SETTING_UNIT_FRAME_WIDTH  then-- Frame Width
        EditModeSettingDisplayInfoManager.systemSettingDisplayInfo[Enum.EditModeSystem.UnitFrame][index].minValue=36
    elseif tab.name==HUD_EDIT_MODE_SETTING_UNIT_FRAME_HEIGHT then
        EditModeSettingDisplayInfoManager.systemSettingDisplayInfo[Enum.EditModeSystem.UnitFrame][index].minValue=18
        print(tab.maxValue )
    end
end



--###########
--加载保存数据
--###########
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)