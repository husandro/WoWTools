
local function Save()
	return WoWToolsSave['Plus_Color'] or {}
end








local function OnColorSelect(self, r, g, b)
	local alphaText, a
	a=(not Save().hide and self.Alpha:IsShown()) and self:GetColorAlpha()

	r,g,b= r or 1, g or 1, b or 1

	if a then
		alphaText= format('%.2f', a)
	end

	a = a or 1

--透明度值

	self.alphaText:SetText(alphaText or '')

--修改材质颜色
	for _, icon in pairs({ColorPickerFrame.Border:GetRegions()}) do
		if icon:IsObjectType('Texture')then
			icon:SetVertexColor(r,g,b)
		end
	end
	for _, icon in pairs({ColorPickerFrame.Header:GetRegions()}) do
		if icon:IsObjectType('Texture')then
			icon:SetVertexColor(r,g,b)
		end
	end
	local texture= _G['WoWToolsColorPickerFrameButton']:GetNormalTexture()
	texture:SetVertexColor(r,g,b)

	ColorPickerFrame.Header.Text:SetTextColor(r,g,b)

	for _, btn in pairs({
		ColorPickerFrame.Footer.OkayButton,
		ColorPickerFrame.Footer.CancelButton,
		ColorPickerFrame.Content.HexBox,
	}) do
		if btn.Left then
			btn.Left:SetVertexColor(r,g,b)
		end
		if btn.Middle then
			btn.Middle:SetVertexColor(r,g,b)
		end
		if btn.Right then
			btn.Right:SetVertexColor(r,g,b)
		end
	end

	
end









local function Init()
--修改，透明度值，MouseWheel
	ColorPickerFrame.Content.ColorPicker:EnableMouseWheel(true)
	ColorPickerFrame.Content.ColorPicker:HookScript('OnMouseWheel', function(self, d)
		if Save().hide then
			return
		end

		local value, h, s

		if IsAltKeyDown() then
			value= self.Alpha:IsShown() and self:GetColorAlpha()
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

		else
			h,s,value= self:GetColorHSV()

			if d== 1 then
				value= value+ 0.01
			elseif d==-1 then
				value= value- 0.01
			end
			value= math.min(1, value)
			value= math.max(0, value)

			self:SetColorHSV(h, s, value)
		end
	end)
	
--[[
	--不能点击，指定值
	ColorPickerFrame.Content.ColorPicker.Value:HookScript('OnLeave', GameTooltip_Hide)
	ColorPickerFrame.Content.ColorPicker.Value:HookScript('OnEnter', function(self)
		if not Save().hide then
			GameTooltip:SetOwner(ColorPickerFrame, 'ANCHOR_RIGHT')
			GameTooltip:SetText('+0.01 '..WoWTools_DataMixin.Icon.mid..' -0.01')
			GameTooltip:Show()
		end
	end)

	ColorPickerFrame.Content.ColorPicker.Alpha:HookScript('OnLeave', GameTooltip_Hide)
	ColorPickerFrame.Content.ColorPicker.Alpha:HookScript('OnEnter', function(self)
		if not Save().hide then
			GameTooltip:SetOwner(ColorPickerFrame, 'ANCHOR_RIGHT')
			GameTooltip:SetText('+0.01 Alt+'..WoWTools_DataMixin.Icon.mid..' -0.01')
			GameTooltip:Show()
		end
	end)]]




--透明度值
	ColorPickerFrame.Content.ColorPicker.alphaText=WoWTools_LabelMixin:Create(ColorPickerFrame.Content.ColorPicker)
	ColorPickerFrame.Content.ColorPicker.alphaText:SetPoint('BOTTOM', ColorPickerFrame.Content.ColorPicker.Alpha, 'TOP',0,1)

--修改材质颜色
	ColorPickerFrame.Content.ColorPicker:HookScript("OnColorSelect", OnColorSelect)
	OnColorSelect(ColorPickerFrame.Content.ColorPicker, ColorPickerFrame:GetColorRGB())


	ColorPickerFrame.Header.Text:SetShadowOffset(1, -1)
	ColorPickerFrame.Header.Text:SetShadowColor(0,0,0)
end



--ColorPickerFrame.Content.ColorPicker:GetColorHSV()






function WoWTools_ColorMixin:Init_Other()
    Init()
end