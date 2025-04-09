
local function Save()
	return WoWToolsSave['Plus_Color'] or {}
end









local Textures={}
local function Set_SaveLogList()
	local logColor= Save().logColor
	local n= math.min(#logColor, Save().logMaxColor or 10)

	for i=1, n, 1 do
		local icon= Textures[i]
		local col= logColor[i]
		if not Textures[i] then
			icon= WoWTools_ColorMixin:Create_Texture(col.r, col.g, col.b, col.a)--记录，打开时的颜色， 和历史
			if i==1 then
				icon:SetPoint('TOPRIGHT', ColorPickerFrame, "TOPLEFT", 0, -20)
			else
				icon:SetPoint('TOP', Textures[i-1], 'BOTTOM')
			end
			icon.tooltip= (WoWTools_DataMixin.onlyChinese and '记录' or EVENTTRACE_LOG_HEADER)..' '..i
			table.insert(Textures, icon)
		end
		icon.r, icon.g, icon.b, icon.a= col.r, col.g, col.b, col.a
		icon:SetColorTexture(col.r, col.g, col.b , 1)
		icon:SetShown(true)
	end

	for i= 11, n, 10 do
		Textures[i]:ClearAllPoints()
		Textures[i]:SetPoint('TOPRIGHT', Textures[i-10], 'TOPLEFT')
	end

	for i=n+1, #Textures, 1 do
		Textures[i]:SetShown(false)
	end
end















local function Init_Menu(self, root)
	local sub
--颜色


	local function set_tooltip(tooltip, desc)
		tooltip:AddDoubleLine(
			'r'..tonumber(format('%.2f',desc.data.r))
			..'  g'..tonumber(format('%.2f',desc.data.g))
			..'  b'..tonumber(format('%.2f',desc.data.b)),

            'a'..(desc.data.a and tonumber(format('%.2f',desc.data.a) or 1))
        )
	end

	local function add_icon(button, desc)
		local icon = button:AttachTexture()
		icon:SetSize(20, 20);
		icon:SetPoint("RIGHT")
		icon:SetColorTexture(desc.data.r, desc.data.g, desc.data.b, 1)
		return 20 + button.fontString:GetUnboundedStringWidth(), 20
	end

--当前
	sub= root:CreateButton('|cffffd100'..(WoWTools_DataMixin.onlyChinese and '当前' or REFORGE_CURRENT),
		function ()
			return MenuResponse
		end,
		{r=self.r, g=self.g, b=self.b, a=self.a or 1}
	)
	sub:AddInitializer(add_icon)
	sub:SetTooltip(set_tooltip)
	root:CreateDivider()

--替换
	local col=select(5, WoWTools_ColorMixin:Get_ColorFrameRGBA())
	sub= root:CreateButton(
		(self.r==col.r and self.g==col.g and self.b==col.b and self.a==self.a and '|cff828282' or '|cnGREEN_FONT_COLOR:')
		..(WoWTools_DataMixin.onlyChinese and '替换' or REPLACE),
	function(data)
		Save().saveColor[self.index]= {data.r, data.g, data.b, data.a}
		self.r, self.g, self.b, self.a= data.r, data.g, data.b, data.a
		self:SetColorTexture(data.r, data.g, data.b)
		print(WoWTools_ColorMixin.addName, WoWTools_DataMixin.onlyChinese and '替换成功' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REPLACE, COMPLETE))
		return MenuResponse
	end, col)
	sub:AddInitializer(add_icon)
	sub:SetTooltip(set_tooltip)
end




local function Init()
	Save().logColor= Save().logColor or {}
	Save().saveColor= Save().saveColor or {}

	ColorPickerFrame.Content.ColorSwatchCurrent:HookScript("OnMouseDown", function(self) self:SetAlpha(0.3) end)
	ColorPickerFrame.Content.ColorSwatchCurrent:HookScript("OnMouseUp", function(self) self:SetAlpha(0.5) end)
	ColorPickerFrame.Content.ColorSwatchCurrent:HookScript('OnLeave', function(self)
		GameTooltip:Hide()
		self:SetAlpha(1)
	end)
	ColorPickerFrame.Content.ColorSwatchCurrent:HookScript('OnEnter', function(self)
		GameTooltip:SetOwner(ColorPickerFrame, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
		GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and "当前颜色" or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REFORGE_CURRENT, COLOR))
		GameTooltip:Show()
		self:SetAlpha(0.5)
	end)

	ColorPickerFrame.Content.ColorSwatchOriginal:HookScript("OnMouseDown", function(self) self:SetAlpha(0.3) end)
	ColorPickerFrame.Content.ColorSwatchOriginal:HookScript("OnMouseUp", function(self) self:SetAlpha(0.5) end)
	ColorPickerFrame.Content.ColorSwatchOriginal:HookScript('OnLeave', function(self)
		GameTooltip:Hide()
		self:SetAlpha(1)
	end)
	ColorPickerFrame.Content.ColorSwatchOriginal:HookScript('OnEnter', function(self)
		local r,g,b,a= ColorPickerFrame:GetPreviousValues()
		GameTooltip:SetOwner(ColorPickerFrame, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and "初始|n匹配值" or BATTLEGROUND_MATCHMAKING_VALUE, WoWTools_DataMixin.Icon.left)
		if r and g and b then
			GameTooltip:AddLine(' ')
			GameTooltip:AddDoubleLine(
				format(
					'r='..tonumber(format('%.2f', r))
					..'  g='..tonumber(format('%.2f', g))
					..'  b='..tonumber(format('%.2f', b))
				),
            	a and tonumber(format('%.2f', a)) or 1
			)
		end
		GameTooltip:Show()
		self:SetAlpha(0.5)
	end)
	ColorPickerFrame.Content.ColorSwatchOriginal:HookScript('OnMouseDown', function()
		local r,g,b,a= ColorPickerFrame:GetPreviousValues()
		if r and g and b then
			ColorPickerFrame.Content.ColorPicker:SetColorRGB(r, g, b)
			if ColorPickerFrame.hasOpacity then
				ColorPickerFrame.Content.ColorPicker:SetColorAlpha(a or 1)
			end
		end
	end)
	hooksecurefunc(ColorPickerFrame, 'SetupColorPickerAndShow', Set_SaveLogList)
	Set_SaveLogList()


--保存，记录数量
	ColorPickerFrame.Footer.OkayButton:HookScript('OnClick', function()
		local logNum= Save().logMaxColor or 10
		if logNum==0 then
			Save().logColor={}
			return
		end
--检测，已存在
		local r, g, b, a= WoWTools_ColorMixin:Get_ColorFrameRGBA()
		for _, col in pairs(Save().logColor) do
			if col.r==r and col.g==g and col.b==b and col.a== a then
				return
			end
		end
--移除，最后，记录数量
		local num= #Save().logColor
		do
			for i= num, logNum, -1 do
				table.remove(Save().logColor, i)
			end
		end

		table.insert(Save().logColor, 1, {r=r, g=g, b=b, a=a})
	end)

	--RestColor= WoWTools_ColorMixin:Create_Texture(WoWTools_DataMixin.Player.r, WoWTools_DataMixin.Player.g, WoWTools_DataMixin.Player.b, 1)--记录，打开时的颜色， 和历史
	--RestColor:SetPoint('TOPRIGHT', ColorPickerFrame.Content.ColorSwatchCurrent, 'TOPRIGHT', 10,0)

--保存，颜色
	for index, color in pairs(
		{
			{1, 0.82, 0, 1},
			{1, 0, 1, 1},
			{1, 1, 0, 1},
			{0, 1, 0, 1}
		}
	) do
		local col= Save().saveColor[index] or color
		local r,g,b,a= col[1],col[2],col[3], col[4] or 1
		local icon= WoWTools_ColorMixin:Create_Texture(r,g,b,a)--记录，打开时的颜色， 和历史
		local s= icon:GetWidth()
		if index==1 then
			icon:SetPoint('TOPLEFT', ColorPickerFrame.Content.ColorSwatchOriginal, 'BOTTOMLEFT', 0, 0)
		elseif index==2 then
			icon:SetPoint('TOPLEFT', ColorPickerFrame.Content.ColorSwatchOriginal, 'BOTTOMLEFT', 0, -s)
		elseif index==3 then
			icon:SetPoint('TOPLEFT', ColorPickerFrame.Content.ColorSwatchOriginal, 'BOTTOMLEFT', s, 0)
		else
			icon:SetPoint('TOPLEFT', ColorPickerFrame.Content.ColorSwatchOriginal, 'BOTTOMLEFT', s, -s)
		end
		icon.index= index
		icon.tooltip= function(self)
			GameTooltip:AddLine(' ')
			GameTooltip:AddDoubleLine(
				(WoWTools_DataMixin.onlyChinese and '常用颜色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SAVE, COLOR))..' '..self.index,
				(WoWTools_DataMixin.onlyChinese and '替换' or REPLACE)..WoWTools_DataMixin.Icon.right
			)
		end
		icon.notClick='RightButton'
		icon:HookScript('OnMouseDown', function(self, d)
			if d=='RightButton' then
				MenuUtil.CreateContextMenu(self, function(...)
					Init_Menu(...)
				end)
			end
		end)
	end
end













function WoWTools_ColorMixin:Init_Log()
	Init()
end


--设置，记录
function WoWTools_ColorMixin:Set_SaveLogList()
	Set_SaveLogList()
end