local id, e = ...
local addName=BAGSLOT
local Save={}
hooksecurefunc(ContainerFrameMixin,'Update',function ()
    print('ContainerFrameMixin.Update')
end)
hooksecurefunc(ContainerFrameMixin,'UpdateItems',function ()
    print('ContainerFrameMixin.UpdateItems')
end)
hooksecurefunc('ContainerFrame_UpdateAll',function ()
    print('ContainerFrame_UpdateAll()')
end)
hooksecurefunc('ContainerFrame_UpdateLocked',function ()
    print('ContainerFrame_UpdateLocked')
end)

hooksecurefunc(ContainerFrameMixin,'UpdateItemContextMatching',function ()
    print('ContainerFrameMixin:UpdateItemContextMatching()')
end)
hooksecurefunc('ContainerFrame_GenerateFrame',function ()
    print('ContainerFrame_GenerateFrame')
end)
hooksecurefunc('ContainerFrame_GetExtendedPriceString',function ()
    print('ContainerFrame_GetExtendedPriceString')
end)
hooksecurefunc(ContainerFrameItemButtonMixin,'OnUpdate', function ()
    print('ContainerFrameItemButtonMixin.OnUpdate')
end)
hooksecurefunc( 'UpdateNewItemList', function(containerFrame)
    print(' UpdateNewItemList(containerFrame)')
end)
hooksecurefunc('ContainerFrame_UpdateLockedItem',function(frame, slot)
print('ContainerFrame_UpdateLockedItem(frame, slot)')
end)

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

function ContainerFrameMixin:UpdateItemContextMatching()
	EventRegistry:TriggerEvent("ItemButton.UpdateItemContextMatching", self:GetBagID());
end
]]