local e= select(2, ...)
local function Save()
	return WoWTools_ColorMixin.Save
end










local function set_Text(self, elapsed)
	if not Frame or not Frame:IsShown() then
		return
	end
	self.elapsed = (self.elapsed or 0.3) + elapsed
	if self.elapsed > 0.3 then
		local r, g, b, a= WoWTools_ColorMixin:Get_ColorFrameRGBA()
		r= r==0 and 0 or r
		g= g==0 and 0 or g
		b= b==0 and 0 or b
		a= a==0 and 0 or a
		if Frame.rgb then
			if not Frame.rgb:HasFocus() then
				Frame.rgb:SetText(format('%.2f %.2f %.2f %.2f', r,g,b,a))
			end
			if not Frame.rgb2:HasFocus() then
				Frame.rgb2:SetText(format('r=%.2f, g=%.2f, b=%.2f, a=%.2f', r,g,b,a))
			end
			if not Frame.hex:HasFocus() then
				Frame.hex:SetText(WoWTools_ColorMixin:RGBtoHEX(r,g,b,a))
			end
		end
		ColorPickerFrame.Header.Text:SetTextColor(r,g,b)
		Frame.alphaText:SetText(a)
		Frame.alphaText:SetTextColor(r,g,b)
	end
end









local function Init()

	local restColor= WoWTools_ColorMixin:Create_Texture(e.Player.r, e.Player.g, e.Player.b, 1)--记录，打开时的颜色， 和历史
	if ColorSwatch then
		restColor:SetPoint('TOP', ColorSwatch, 'BOTTOM', 0, -60)
	else
		restColor:SetPoint('TOPLEFT', ColorPickerFrame.Content.ColorSwatchCurrent, 'TOPRIGHT', 2,0)
	end
	restColor:SetScript('OnShow', function(self)
		local r, g, b, a= WoWTools_ColorMixin:Get_ColorFrameRGBA()
		self:SetColorTexture(r, g, b, a)
		self.r, self.g, self.b, self.a= r, g, b, a

		for i=1, #Save().color do
			local texture= self[i]
			local col= Save().color[i]
			if not self[i] then
				texture= WoWTools_ColorMixin:Create_Texture(col.r, col.g, col.b, 1)--记录，打开时的颜色， 和历史
				self[i]= texture
				if i==1 then
					texture:SetPoint('TOPRIGHT', ColorPickerFrame, "TOPLEFT", 0, -20)
				else
					texture:SetPoint('TOP', self[i-1], 'BOTTOM')
				end
			end
			texture.r, texture.g, texture.b, texture.a= col.r, col.g, col.b, col.a
			texture:SetColorTexture(col.r, col.g, col.b , col.a)
		end
		for i= 11, #Save().color, 10 do
			self[i]:ClearAllPoints()
			self[i]:SetPoint('TOPRIGHT', self[i-10], 'TOPLEFT')
		end
	end)


    if ColorPickerOkayButton then
        ColorPickerOkayButton:HookScript('OnMouseDown', function()--记录，历史
            local r, g, b, a= WoWTools_ColorMixin:Get_ColorFrameRGBA()
            for _, col in pairs(Save().color) do
                if col.r==r and col.g==g and col.b==b and col.a== a then
                    return
                end
            end
            if #Save().color >=30 then--记录数量
                table.remove(Save().color, 1)
            end
            table.insert(Save().color,{r=r, g=g, b=b, a=a})
        end)
        ColorPickerFrame:HookScript('OnUpdate', set_Text)
    else
        ColorPickerFrame.Footer.OkayButton:HookScript('OnClick', function()
            local r, g, b, a= WoWTools_ColorMixin:Get_ColorFrameRGBA()
            for _, col in pairs(Save().color) do
                if col.r==r and col.g==g and col.b==b and col.a== a then
                    return
                end
            end
            if #Save().color >=30 then--记录数量
                table.remove(Save().color, 1)
            end
            table.insert(Save().color,{r=r, g=g, b=b, a=a})
        end)
        ColorPickerFrame.Content.ColorPicker:HookScript("OnColorSelect", set_Text)
    end

    Frame:SetShown(not Save().hide)
end













function WoWTools_ColorMixin:Init_Log()
	Init()
end