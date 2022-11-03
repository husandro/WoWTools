local id , e = ...
local addName=UNITNAME_SUMMON_TITLE14:format('Mage')
local Save={

}
local panel=e.Cbtn2(nil, e.toolsFrame)

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
    if event == "ADDON_LOADED" and arg1== id then
        Save= WoWToolsSave and WoWToolsSave[addName..'Tools'] or Save
        if not e.toolsFrame.disabled then
            C_Timer.After(1.7, function()
                if UnitAffectingCombat('player') then
                    panel.combat= true
                else
                    Init()--初始
                end
            end)
        else
            panel:UnregisterAllEvents()
        end
        panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName..'Tools']=Save
        end
    end
end)