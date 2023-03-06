local id, e= ...
local addName= MOUSE_LABEL-- = "鼠标";
local Save={}
local panel= CreateFrame("Frame")



--#####
--初始化
--#####
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
            if not Save.disabled then
                Init()
            end
            panel:UnregisterEvent('ADDON_LOADED')
            panel:RegisterEvent("PLAYER_LOGOUT")
        end
    end
end)