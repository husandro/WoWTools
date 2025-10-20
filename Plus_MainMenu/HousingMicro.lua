--[[
function HousingFramesUtil.ToggleHousingDashboard()
	if (PlayerIsTimerunning() or not C_Housing.IsHousingServiceEnabled()) then
		return;
	end

	if not HousingDashboardFrame then
		C_AddOns.LoadAddOn("Blizzard_HousingDashboard");
	end

	if (C_PlayerInfo.IsPlayerNPERestricted()) then
		return;
	end

	ToggleFrame(HousingDashboardFrame);
end
]]
local function Init()
    if HousingMicroButton then
        HousingMicroButton:HookScript('OnClick', function(_, d)
            if d=='RightButton' and not KeybindFrames_InQuickKeybindMode() and not Kiosk.IsEnabled() then
                HousingFramesUtil.ToggleHousingDashboard()
                if HousingDashboardFrame:IsShown() then
                    HousingDashboardFrame.activeTab = HousingDashboardFrame.catalogTab
                    HousingDashboardFrame:SetTab(HousingDashboardFrame.activeTab)
                end
            end
        end)

    end
    Init=function() end
end
function WoWTools_MainMenuMixin:HousingMicro()--住宅信息板
    Init()
end