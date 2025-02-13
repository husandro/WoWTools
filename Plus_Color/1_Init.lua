local id, e= ...



local function Init()
--透明值，提示
	ColorPickerFrame.Content.ColorPicker.alphaText=WoWTools_LabelMixin:Create(ColorPickerFrame.Content.ColorPicker)
	ColorPickerFrame.Content.ColorPicker.alphaText:SetPoint('BOTTOM', ColorPickerFrame.Content.ColorPicker.Alpha, 'TOP',0,1)

	ColorPickerFrame.Content.ColorPicker.alphaWheelTexture= ColorPickerFrame.Content.ColorPicker:CreateTexture(nil, 'OVERLAY', nil, 7)
	ColorPickerFrame.Content.ColorPicker.alphaWheelTexture:SetPoint('TOPLEFT', ColorPickerFrame.Content.ColorPicker.Alph)
	ColorPickerFrame.Content.ColorPicker.alphaWheelTexture:SetPoint('BOTTOMRIGHT', ColorPickerFrame.Content.ColorPicker.Alph)
	ColorPickerFrame.Content.ColorPicker.alphaWheelTexture:EnableMouseWheel(true)

--修行，透明度值，MouseWheel
	ColorPickerFrame.Content.ColorPicker:EnableMouseWheel(true)
	ColorPickerFrame.Content.ColorPicker:HookScript('OnMouseWheel', function(self, d)
		local value
		value= (not WoWTools_ColorMixin.Save.hide and self.Alpha:IsShown()) and self:GetColorAlpha()
		if not value then
			return
		end
		if d== 1 then
			value= value+ 0.01
		elseif d==-1 then
			value= value- 0.01
		end
		value= math.min(1, value)
		value= math.max(0, value)
		self:SetColorAlpha(value)
		self.alphaWheelTexture:SetShown(value)
	end)

--显示，透明度值
	ColorPickerFrame.Content.ColorPicker:HookScript("OnColorSelect", function(self, r, g, b)
		local text, a
		a=(not WoWTools_ColorMixin.Save.hide and self.Alpha:IsShown()) and self:GetColorAlpha()
		if a then
			text= format('%.2f', a)
		else
			r,g,b,a=1,1,1,1
		end

		self.alphaText:SetText(text or '')
		self.alphaWheelTexture:SetShown(text)

		for _, icon in pairs({ColorPickerFrame.Border:GetRegions()}) do
			if icon:GetObjectType()=="Texture" then
				icon:SetVertexColor(r,g,b,a)
			end
		end
		for _, icon in pairs({ColorPickerFrame.Header:GetRegions()}) do
			if icon:GetObjectType()=="Texture" then
				icon:SetVertexColor(r,g,b,a)
			end
		end
	end)


	--WoWTools_ColorMixin:Init_Log()
	do
		WoWTools_ColorMixin:Init_Options()
	end
	WoWTools_ColorMixin:Init_EditBox()
	WoWTools_ColorMixin:Init_SelectColor()

	return true
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
					WoWTools_ColorMixin:ShowColorFrame(e.Player.r, e.Player.g, e.Player.b, 1, nil, nil)
                end,
			})

            if not WoWTools_ColorMixin.Save.disabled then
				ColorPickerFrame:HookScript('OnShow', function()
					if Init() then Init=function()end end
				end)

				if e.Player.husandro then
					C_Timer.After(2, function()
						WoWTools_ColorMixin:ShowColorFrame(e.Player.r, e.Player.g, e.Player.b, 1, nil, nil)
					end)
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