local id, e = ...
local Save={}
local addName=MOUNTS..FAVORITES

local function setMountJournal_UpdateMountDisplay()
    if not MountJournal.selectedMountID then
        return
    end
    local creatureName, spellID, icon, active, isUsable, sourceType = C_MountJournal.GetMountInfoByID(MountJournal.selectedMountID);
    if sourceType==6 then--成就
       
    end
end

local function setMenuMontJournal(self, level)
    print(self.spellID,'a')
end
--###########
--加载保存数据
--###########
panel=CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save
--[[            local check=e.CPanel(addName, not Save.disabled, true)
            check:SetScript('OnClick', function()
            if Save.disabled then
                Save.disabled=nil
            else
                Save.disabled=true
            end
            print(id, addName, e.GetEnabeleDisable(not Save.disabled))
        end)]]
    elseif event=='ADDON_LOADED' and arg1=='Blizzard_Collections' then
        hooksecurefunc('MountJournal_UpdateMountDisplay', setMountJournal_UpdateMountDisplay)--Blizzard_MountCollection.lua
        hooksecurefunc('MountOptionsMenu_Init', setMenuMontJournal)

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)