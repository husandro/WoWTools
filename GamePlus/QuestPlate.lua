local id, e= ...
local Save= {}
local addName= QUESTS_LABEL..NAMEPLATES_LABEL
local panel= CreateFrame("Frame")


--####
--初始
--####
local function Init()
    
end


--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板
            local check=e.CPanel(e.onlyChinse and '宠物对战' or addName, not Save.disabled, true)
            check:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '重新加载UI' or RELOADUI)
            end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)