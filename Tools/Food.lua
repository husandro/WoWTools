local id, e = ...
local addName= POWER_TYPE_FOOD
local Save={}
--e.Cbtn= function(self, Template, value, SecureAction, name, notTexture, size)
local panel=e.Cbtn(WoWToolsMountButton, nil,nil,nil,nil,true)

--####
--初始
--####
local function Init()
    local size=e.toolsFrame.size or 30
    panel:SetSize(size,size)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        Save= WoWToolsSave and WoWToolsSave[addName..'Tools'] or Save
        if not e.toolsFrame.disabled then
            Init()--初始
        else
            panel:UnregisterAllEvents()
        end
        panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='BAG_UPDATE_DELAYED' then
    end
end)