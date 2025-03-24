
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









local function Init()
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










function WoWTools_ColorMixin:Init_Other()
    Init()
end