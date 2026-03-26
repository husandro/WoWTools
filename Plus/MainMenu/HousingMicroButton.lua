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




InitiativesTabMixin:RefreshInitiativeTab()
]]
local function Init()
    --if not C_NeighborhoodInitiative.GetActiveNeighborhood()  then


    local frame= CreateFrame('Frame', nil, HousingMicroButton)
    frame.label= frame:CreateFontString('WoWToolsHousingMicroButtonInitiativesLastPointLabel', 'ARTWORK', 'WoWToolsFonts')
    frame.label:SetPoint('TOP', HousingMicroButton, 0, -3)
    frame.label:SetJustifyH('CENTER')
    frame.label:SetFontHeight(WoWToolsSave['Plus_MainMenu'].size or 12)

    frame.label2= frame:CreateFontString('WoWToolsHousingMicroButtonInitiativesLastPointLabel', 'ARTWORK', 'WoWToolsFonts')
    frame.label2:SetPoint('BOTTOM', HousingMicroButton, 0, 3)
    frame.label2:SetJustifyH('CENTER')
    frame.label2:SetFontHeight(WoWToolsSave['Plus_MainMenu'].size or 12)

    WoWTools_ColorMixin:SetLabelColor(frame.label)
    WoWTools_ColorMixin:SetLabelColor(frame.label2)

    table.insert(WoWTools_MainMenuMixin.Labels, frame.label)
    table.insert(WoWTools_MainMenuMixin.Labels, frame.label2)

    frame.currencyID= 3363--https://www.wowhead.com/cn/currency=3363/社区礼券

    function frame:set_currency()
        local _, num, _, _, isMax= WoWTools_CurrencyMixin:GetInfo(self.currencyID)
        if num then
            self.label2:SetText((isMax and '|cnWARNING_FONT_COLOR:' or '')..num)
        else
            self.label2:SetText('')
        end
    end

    function frame:Set_InitiativesLastPoints()
        local value
        if C_NeighborhoodInitiative.IsInitiativeEnabled() then
            value= GetCVarNumberOrDefault("endeavorInitiativesLastPoints")
        end

        if value and value>=0 then
            value= format('%i', value/10)
            frame.label:SetText(value)
            return value
        else
            frame.label:SetText('')
        end
    end

    if C_NeighborhoodInitiative.IsInitiativeEnabled() then
        frame:RegisterEvent('CVAR_UPDATE')
    end

    frame:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
    frame:SetScript('OnEvent', function(self, event, arg1)
        if event == "CURRENCY_DISPLAY_UPDATE" then
            if arg1==self.currencyID then
                self:set_currency()
            end

        elseif arg1 == "endeavorInitiativesLastPoints" then
           self:Set_InitiativesLastPoints()
        end
    end)


    if C_NeighborhoodInitiative.IsInitiativeEnabled() then
        C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo()
        C_NeighborhoodInitiative.RequestInitiativeActivityLog()
    end

    HousingMicroButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() or Kiosk.IsEnabled() then
            return
        end

        if not InCombatLockdown() then
            if C_NeighborhoodInitiative.IsInitiativeEnabled() then
                C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo()
                C_NeighborhoodInitiative.RequestInitiativeActivityLog()
            end
        end

        local text
        text= frame:Set_InitiativesLastPoints()
        if text then
            text= text..'%'
        end


        local name = WoWTools_CurrencyMixin:GetName(frame.currencyID)
        if not (text or name) then
            return
        end

        GameTooltip:AddLine(' ')

        if text then
            GameTooltip:AddLine(
                (WoWTools_DataMixin.onlyChinese and '文化节进度' or ENDEAVOR_FAVOR)
                ..': '..text
            )

            local currentInitiative=  C_NeighborhoodInitiative.GetNeighborhoodInitiativeInfo()
            if currentInitiative and currentInitiative.duration and currentInitiative.duration > 0 then
                GameTooltip:AddDoubleLine(' ',
                    format(WoWTools_DataMixin.onlyChinese and '剩余时间：%s' or HOUSING_DASHBOARD_TIME_REMAINING,
                        SecondsToTime(currentInitiative.duration, false, true, 1)
                    )
                )
            end
        end

        if name then
            GameTooltip:AddLine(name)
        end

        GameTooltip:Show()
    end)





    C_Timer.After(2, function()
        frame:Set_InitiativesLastPoints()
        frame:set_currency()
    end)

    Init=function() end
end
function WoWTools_MainMenuMixin:HousingMicroButton()--住宅信息板
    Init()
end