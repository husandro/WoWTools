local e= select(2, ...)
local function Save()
	return WoWTools_ColorMixin.Save
end

local Textures={}
local RestColor









local function Set_SaveList()
	local n= #Save().logColor
	local logColor= Save().logColor
	for i=1, n do
		local texture= Textures[i]
		local col= logColor[i]
		if not Textures[i] then
			texture= WoWTools_ColorMixin:Create_Texture(col.r, col.g, col.b, 1)--记录，打开时的颜色， 和历史
			if i==1 then
				texture:SetPoint('TOPRIGHT', ColorPickerFrame, "TOPLEFT", 0, -20)
			else
				texture:SetPoint('TOP', Textures[i-1], 'BOTTOM')
			end
			table.insert(Textures, texture)
		end
		texture.r, texture.g, texture.b, texture.a= col.r, col.g, col.b, col.a
		texture:SetColorTexture(col.r, col.g, col.b , col.a)
		texture:SetShown(true)
	end

	for i= 11, n, 10 do
		Textures[i]:ClearAllPoints()
		Textures[i]:SetPoint('TOPRIGHT', Textures[i-10], 'TOPLEFT')
	end

	for i=n+1, #Textures, 1 do
		Textures[i]:SetShown(false)
	end
end


















local function Init()
	RestColor= WoWTools_ColorMixin:Create_Texture(e.Player.r, e.Player.g, e.Player.b, 1)--记录，打开时的颜色， 和历史
	RestColor:SetPoint('TOPLEFT', ColorPickerFrame.Content.ColorSwatchCurrent, 'TOPRIGHT', 10,0)

	hooksecurefunc(ColorPickerFrame, 'SetupColorPickerAndShow', function(_, info)
		local r = info.r
		local g = info.g
		local b = info.b
		local a = info.opacity
		RestColor:SetColorTexture(r, g, b, a)
		RestColor.r, RestColor.g, RestColor.b, RestColor.a= r, g, b, a
		Set_SaveList()
	end)

	Set_SaveList()



	ColorPickerFrame.Footer.OkayButton:HookScript('OnClick', function()
		local r, g, b, a= WoWTools_ColorMixin:Get_ColorFrameRGBA()
		for _, col in pairs(Save().logColor) do
			if col.r==r and col.g==g and col.b==b and col.a== a then
				return
			end
		end

		if #Save().logColor >=30 then--记录数量
			table.remove(Save().logColor, 1)
		end
		table.insert(Save().logColor,{r=r, g=g, b=b, a=a})
	end)
end













function WoWTools_ColorMixin:Init_Log()
	Init()
end


--清除记录
function WoWTools_ColorMixin:Clear_Log()
	self.Save.logColor={}
	Set_SaveList()
end