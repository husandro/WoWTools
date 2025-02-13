local id, e= ...



local function Init()
	if _G['WoWToolsColorPickerFramePlus'] then
		return
	end

	local frame= CreateFrame("Frame", 'WoWToolsColorPickerFramePlus', ColorPickerFrame)
	frame:SetPoint('BOTTOMRIGHT')
	frame:SetSize(1,1)
	WoWTools_ColorMixin.Frame= frame
	frame:SetShown(not WoWTools_ColorMixin.hide)

	WoWTools_ColorMixin:Init_Options()
	WoWTools_ColorMixin:Init_SelectColor()
	WoWTools_ColorMixin:Init_EditBox()
	WoWTools_ColorMixin:Init_Log()
end



local panel= CreateFrame("Frame")
panel:RegisterEvent('PLAYER_LOGOUT')
panel:RegisterEvent('ADDON_LOADED')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
			WoWToolsSave[COLOR_PICKER]= nil
            WoWTools_ColorMixin.Save= WoWToolsSave['Plus_Color'] or WoWTools_ColorMixin.Save
			WoWTools_ColorMixin.addName= '|A:colorblind-colorwheel:0:0|a'..(e.onlyChinese and '颜色选择器' or COLOR_PICKER)

			--添加控制面板
			e.AddPanel_Check_Button({
				checkName= WoWTools_ColorMixin.addName,
				GetValue= function() return not WoWTools_ColorMixin.Save.disabled end,
				SetValue= function()
					WoWTools_ColorMixin.Save.disabled= not WoWTools_ColorMixin.Save.disabled and true or nil
                	print(
						WoWTools_Mixin.addName,
						WoWTools_ColorMixin.addName,
						e.GetEnabeleDisable(not WoWTools_ColorMixin.Save.disabled),
						e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
					)
				end,
				buttonText='|A:colorblind-colorwheel:0:0|a'..(e.onlyChinese and '显示' or SHOW),
				buttonFunc= function()
					WoWTools_ColorMixin:ShowColorFrame(e.Player.r, e.Player.g, e.Player.b, nil, nil, nil)
                end,
			})

            if not WoWTools_ColorMixin.Save.disabled then


				if ColorPickerFrame:IsShown() then
					Init()
				else
					ColorPickerFrame:HookScript('OnShow', Init)
				end
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_Color']=WoWTools_ColorMixin.Save
        end
    end
end)