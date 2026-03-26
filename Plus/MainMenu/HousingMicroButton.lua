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
HousingMicroButton:HookScript('OnClick', function(_, d)
        if d=='RightButton' and not KeybindFrames_InQuickKeybindMode() and not Kiosk.IsEnabled() then
            HousingFramesUtil.ToggleHousingDashboard()
            if HousingDashboardFrame:IsShown() then
                HousingDashboardFrame.activeTab = HousingDashboardFrame.catalogTab
                HousingDashboardFrame:SetTab(HousingDashboardFrame.activeTab)
            end
        end
    end)
]]
local function Init()
    if not C_NeighborhoodInitiative.IsInitiativeEnabled() then
        return
    end

    C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo()

    local frame= CreateFrame('Frame', nil, HousingMicroButton)
    frame.label= frame:CreateFontString('WoWToolsHousingMicroButtonInitiativesLastPointLabel', 'BORDER', 'WoWToolsFont')
    frame.label:SetPoint('BOTTOM', HousingMicroButton, 0, 3)
    frame.label:SetFontHeight(WoWToolsSave['Plus_MainMenu'].size or 12)
    WoWTools_ColorMixin:SetLabelColor(frame.label)
    table.insert(WoWTools_MainMenuMixin.Labels, HousingMicroButton.InitiativesLastPoints)

    frame:RegisterEvent('CVAR_UPDATE')
    frame:SetScript('OnEvent', function(self, _, cvar, value)
        if cvar == "endeavorInitiativesLastPoints" then
            value= value and tonumber(value)
            if value and value>=0 then
                self.label:SetFormattedText('%i', value/10)
            else
                self.label:SetText('')
            end
        end
    end)

    C_Timer.After(2, function()
        local value
        value= GetCVarNumberOrDefault("endeavorInitiativesLastPoints")
        if value and value>=0 then
            frame.label:SetFormattedText('%i', value/10)
        end
    end)

    --[[HousingMicroButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() or Kiosk.IsEnabled() then
            return
        end]]

    Init=function() end
end
function WoWTools_MainMenuMixin:HousingMicroButton()--住宅信息板
    Init()
end