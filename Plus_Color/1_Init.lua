local id, e= ...
local function Save()
	return WoWTools_ColorMixin.Save
end






local function OnColorSelect(self, r, g, b)
	local alphaText, a
		a=(not Save().hide and self.Alpha:IsShown()) and self:GetColorAlpha()

		if a then
			alphaText= format('%.2f', a)
		else
			r,g,b,a=1,1,1,1
		end
--透明度值
		self.alphaText:SetText(alphaText or '')
--修改材质颜色
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
		local texture= _G['WoWToolsColorPickerFrameButton']:GetNormalTexture()
		texture:SetVertexColor(r,g,b)
end

local function Init_Other()
--修改，透明度值，MouseWheel
	ColorPickerFrame.Content.ColorPicker:EnableMouseWheel(true)
	ColorPickerFrame.Content.ColorPicker:HookScript('OnMouseWheel', function(self, d)
		local value
		value= (not Save().hide and self.Alpha:IsShown()) and self:GetColorAlpha()
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
	end)

--透明度值
	ColorPickerFrame.Content.ColorPicker.alphaText=WoWTools_LabelMixin:Create(ColorPickerFrame.Content.ColorPicker)
	ColorPickerFrame.Content.ColorPicker.alphaText:SetPoint('BOTTOM', ColorPickerFrame.Content.ColorPicker.Alpha, 'TOP',0,1)

--修改材质颜色
	ColorPickerFrame.Content.ColorPicker:HookScript("OnColorSelect", OnColorSelect)
	OnColorSelect(ColorPickerFrame.Content.ColorPicker, ColorPickerFrame:GetColorRGB())
end










local function Init()
	do
		WoWTools_ColorMixin:Init_Options()
	end
	WoWTools_ColorMixin:Init_EditBox()
	WoWTools_ColorMixin:Init_SelectColor()
	WoWTools_ColorMixin:Init_Log()
	Init_Other()
	return true
end








EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(_, arg1)
	if arg1~=id then
		return
	end

	WoWToolsSave[COLOR_PICKER]= nil
	WoWTools_ColorMixin.Save= WoWToolsSave['Plus_Color'] or Save()
	WoWTools_ColorMixin.addName= '|A:colorblind-colorwheel:0:0|a'..(e.onlyChinese and '颜色选择器' or COLOR_PICKER)

	--添加控制面板
	e.AddPanel_Check_Button({
		checkName= WoWTools_ColorMixin.addName,
		GetValue= function() return not Save().disabled end,
		SetValue= function()
			Save().disabled= not Save().disabled and true or nil
			print(
				WoWTools_Mixin.addName,
				WoWTools_ColorMixin.addName,
				e.GetEnabeleDisable(not Save().disabled),
				e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
			)
		end,
		buttonText='|A:colorblind-colorwheel:0:0|a'..(e.onlyChinese and '显示' or SHOW),
		buttonFunc= function()
			WoWTools_ColorMixin:ShowColorFrame(e.Player.r, e.Player.g, e.Player.b, 1, nil, nil)
		end,
	})

	if Save().disabled then
		return
	end

	ColorPickerFrame:HookScript('OnShow', function()
		if Init() then Init=function()end end
	end)

	if Save().autoShow then
		C_Timer.After(2, function()
			WoWTools_ColorMixin:ShowColorFrame(e.Player.r, e.Player.g, e.Player.b, 1, nil, nil)
			print(
				WoWTools_Mixin.addName,
				WoWTools_ColorMixin.addName,
				'|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '自动显示' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SHOW))..'|A:colorblind-colorwheel:0:0|a'
			)
		end)
	end
end)

EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGOUT", function()
	if not e.ClearAllSave then
		WoWToolsSave['Plus_Color']=WoWTools_ColorMixin.Save
	end
end)
--[[
local panel= CreateFrame('Frame')
panel:RegisterEvent('PLAYER_LOGOUT')
panel:RegisterEvent('ADDON_LOADED')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then

			WoWToolsSave[COLOR_PICKER]= nil
			WoWTools_ColorMixin.Save= WoWToolsSave['Plus_Color'] or Save()

			WoWTools_ColorMixin.addName= '|A:colorblind-colorwheel:0:0|a'..(e.onlyChinese and '颜色选择器' or COLOR_PICKER)

			--添加控制面板
			e.AddPanel_Check_Button({
				checkName= WoWTools_ColorMixin.addName,
				GetValue= function() return not Save().disabled end,
				SetValue= function()
					Save().disabled= not Save().disabled and true or nil
                	print(
						WoWTools_Mixin.addName,
						WoWTools_ColorMixin.addName,
						e.GetEnabeleDisable(not Save().disabled),
						e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
					)
				end,
				buttonText='|A:colorblind-colorwheel:0:0|a'..(e.onlyChinese and '显示' or SHOW),
				buttonFunc= function()
					WoWTools_ColorMixin:ShowColorFrame(e.Player.r, e.Player.g, e.Player.b, 1, nil, nil)
                end,
			})

            if not Save().disabled then
				ColorPickerFrame:HookScript('OnShow', function()
					if Init() then Init=function()end end
				end)

				if Save().autoShow then
					C_Timer.After(2, function()
						WoWTools_ColorMixin:ShowColorFrame(e.Player.r, e.Player.g, e.Player.b, 1, nil, nil)
						print(
							WoWTools_Mixin.addName,
							WoWTools_ColorMixin.addName,
							'|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '自动显示' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SHOW))..'|A:colorblind-colorwheel:0:0|a'
						)
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
]]