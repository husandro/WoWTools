local id, e = ...
local addName=BAGSLOT
local Save={}


--加载保存数据
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save    
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)
--ContainerFrame.lua

--[[
function ContainerFrameSettingsManager:SetupBagsCombined()
	local container = ContainerFrameCombinedBags;
	self:SetupBagsGeneric(container);
	self:SetTokenTrackerOwner(container);
	self:SetMoneyFrameOwner(container);
end
]]