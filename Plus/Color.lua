local id, e= ...
local Save= {
		color={},--保存，历史记录
}
local addName= COLOR_PICKER--"颜色选择器";
local panel= CreateFrame("Frame")--ColorPickerFrame.xml
local logNum= 30--记录数量

local Frame


local function set_Text(self, elapsed)
	if not Frame or not Frame:IsShown() then
		return
	end
	self.elapsed = (self.elapsed or 0.3) + elapsed
	if self.elapsed > 0.3 then
		local r, g, b, a= e.Get_ColorFrame_RGBA()
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

local function set_Edit_Text(r, g, b, a, textCode)
	if ColorPickerFrame.Content then
		ColorPickerFrame.Content.ColorPicker:SetColorRGB(r, g, b)
		ColorPickerFrame.Content.ColorPicker:SetColorAlpha(a or 1);
	else
		OpacitySliderFrame:SetValue(a and 1-a or 0);
		ColorPickerFrame:SetColorRGB(r, g, b)
	end
	Frame.cn:SetText(textCode and textCode..'_CODE' or '')
	Frame.cn2:SetText(textCode and '|cn'..textCode or '')
end


















--####
--初始
--####
local function Init()
	Frame= CreateFrame("Frame", nil, ColorPickerFrame)

	local size, x, y, n

	local function create_Texture(r,g,b,a, atlas)
		local texture= Frame:CreateTexture()
		texture:SetSize(size, size)
		texture:EnableMouse(true)
		a=a or 1
		texture.r, texture.g, texture.b, texture.a= r, g, b, a
		texture:SetScript('OnMouseDown', function(self)
			set_Edit_Text(self.r, self.g, self.b, self.a, self.textCode)
			self:SetAlpha(0.1)
		end)
		texture:SetScript('OnMouseUp', function(self) self:SetAlpha(0.7) end)
		texture:SetScript('OnEnter', function(self)
			local col= '|c'..WoWTools_ColorMixin:RGBtoHEX(self.r, self.g, self.b, self.a)
			e.tips:SetOwner(ColorPickerFrame, "ANCHOR_RIGHT")
			e.tips:ClearLines()
			e.tips:AddDoubleLine(col..id, col..addName)
			if self.tooltip then
				e.tips:AddLine(' ')
				e.tips:AddLine(self.tooltip)
			end
			e.tips:AddDoubleLine(col..'r'..format('%.2f',self.r)..' g'..format('%.2f',self.g)..' b'..format('%.2f',self.b), col..'a'..(self.a and format('%.2f',self.a) or 1))
			e.tips:Show()
			self:SetAlpha(0.7)
		end)
		texture:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
		if atlas then
			texture:SetAtlas(atlas)
		else
			texture:SetColorTexture(r, g, b)
		end
		return texture
	end

	local colorTab={}
	size, x, y, n= 22, 0, -15, 1
	for className, col in pairs(RAID_CLASS_COLORS) do--职业 ColorUtil.lua
		local text= col.r..col.g..col.b.. (col.a or 1)
		if not colorTab[text] then
			colorTab[text]= true
			local texture= create_Texture(col.r, col.g, col.b, col.a, WoWTools_UnitMixin:GetClassIcon(nil, className, true))
			texture:SetPoint('TOPLEFT', ColorPickerFrame, 'TOPRIGHT', x, y)
			local hex= col:GenerateHexColor()
			texture.tooltip= '|c'..hex..'RAID_CLASS_COLORS["'..className..'"]'
			if n==7 then
				n=0
				x= x+ size
				y= -15
			else
				y= y- size
			end
			n=n+1
		end
	end

	size, x, y, n= 16, x+size, -15, 0
	for index, col in pairs(ITEM_QUALITY_COLORS) do--物品 UIParent.lua
		local text= col.r..col.g..col.b.. (col.a or 1)
		if not colorTab[text] then
			colorTab[text]= true
			local texture= create_Texture(col.r, col.g, col.b, col.a)
			texture:SetPoint('TOPLEFT', ColorPickerFrame, 'TOPRIGHT', x, y)
			texture.tooltip= col.hex.._G["ITEM_QUALITY" .. index.. "_DESC"]..'|nITEM_QUALITY' ..index.. '_DESC'
			if n==10 then
				n=0
				x= x+ size
				y= -15
			else
				y= y- size
			end
			n=n+1
		end
	end
	n=n+1
	for name, col in pairs(MATERIAL_TEXT_COLOR_TABLE) do--SharedColorConstants.lua
		local text= col.r..col.g..col.b.. (col.a or 1)
		if not colorTab[text] then
			colorTab[text]= true
			local texture= create_Texture(col.r, col.g, col.b, col.a)
			texture:SetPoint('TOPLEFT', ColorPickerFrame, 'TOPRIGHT', x, y)
			texture.tooltip= 'MATERIAL_TEXT_COLOR_TABLE'..'["'..name..'"]'
			if n==9 then
				n=0
				x= x+ size
				y= -15
			else
				y= y- size
			end
			n=n+1
		end
	end
	for name, col in pairs(MATERIAL_TITLETEXT_COLOR_TABLE) do--SharedColorConstants.lua
		local text= col.r..col.g..col.b.. (col.a or 1)
		if not colorTab[text] then
			colorTab[text]= true
			local texture= create_Texture(col.r, col.g, col.b, col.a)
			texture:SetPoint('TOPLEFT', ColorPickerFrame, 'TOPRIGHT', x, y)
			texture.tooltip= 'MATERIAL_TITLETEXT_COLOR_TABLE'..'["'..name..'"]'
			if n==10 then
				n=0
				x= x+ size
				y= -15
			else
				y= y- size
			end
			n=n+1
		end
	end
	for name, col in pairs(COVENANT_COLORS) do--SharedColorConstants.lua
		if type(name)~='number' then
			local text= col.r..col.g..col.b.. (col.a or 1)
			if not colorTab[text] then
			colorTab[text]= true
				local texture= create_Texture(col.r, col.g, col.b, col.a)
				texture:SetPoint('TOPLEFT', ColorPickerFrame, 'TOPRIGHT', x, y)
				texture.tooltip= 'COVENANT_COLORS'..'["'..name..'"]'
				if n==10 then
					n=0
					x= x+ size
					y= -15
				else
					y= y- size
				end
				n=n+1
			end
		end
	end
	for name, col in pairs(PLAYER_FACTION_COLORS) do--SharedColorConstants.lua
		local text= col.r..col.g..col.b.. (col.a or 1)
		if not colorTab[text] then
			colorTab[text]= true
			local texture= create_Texture(col.r, col.g, col.b, col.a)
			texture:SetPoint('TOPLEFT', ColorPickerFrame, 'TOPRIGHT', x, y)
			texture.tooltip= 'PLAYER_FACTION_COLORS'..'['..name..']'
			if n==10 then
				n=0
				x= x+ size
				y= -15
			else
				y= y- size
			end
			n=n+1
		end
	end

	size, x, y, n= 16, -70, -3, 1
	local Y=0
	local DBColors = C_UIColor.GetColors() or {};--Color.lua
	table.sort(DBColors, function(a,b)
		return a.color.r> b.color.r
	end)
	for _, dbColor in ipairs(DBColors) do
		local text= dbColor.color.r.. dbColor.color.g.. dbColor.color.b.. (dbColor.color.a or 1)
		if not colorTab[text] then
			colorTab[text]= true
			local texture= create_Texture(dbColor.color.r, dbColor.color.g, dbColor.color.b, dbColor.color.a)
			texture.textCode= dbColor.baseTag
			texture:SetPoint('BOTTOMLEFT', ColorPickerFrame.Header, 'TOPLEFT', x, y)
			if n==20 then
				n=0
				y=y +size
				x=-70
				Y=Y+1
			else
				x=x +size
			end
			n=n+1
			if Y>5 then
				break
			end
		end
	end
	if Save.colorType then--颜色 选择器2
		x, y, n= -102, y+3, 1
		for r=0, 1, 0.2 do
			for g=0, 1, 0.2 do
				for b=0, 1, 0.2 do
					local texture= create_Texture(r, g, b)
					texture:SetPoint('BOTTOMLEFT', ColorPickerFrame.Header, 'TOPLEFT', x, y)
					if n==24 then
						n=0
						y=y +size
						x=-102
					else
						x=x +size
					end
					n=n+1
				end
			end
		end
	end





















	--RGB
	local w=290
	local function set_EnterTips(frame, func)--建立一个图标，提示Enter键
		local enter
		enter= frame:CreateTexture()
		enter:EnableMouse(true)
		enter:SetPoint('LEFT', frame, 'RIGHT')
		enter:SetSize(20,20)
		enter:SetAtlas('NPE_Icon')
		enter:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
		enter:SetScript("OnEnter", func)
	end

	Frame.rgb= CreateFrame("EditBox", nil, Frame, 'InputBoxTemplate')-- 1 1 1 1
	Frame.rgb:SetPoint("TOPLEFT", ColorPickerFrame, 'BOTTOMLEFT',10,0)
	Frame.rgb:SetSize(w,20)
	Frame.rgb:SetAutoFocus(false)
	Frame.rgb:ClearFocus()
	function Frame.rgb:get_RGB()
		local text= self:GetText() or ''
		text= text:gsub(',',' ')
		text= text:gsub('，',' ')
		text= text:gsub('  ',' ')
		local r, g, b, a

		if text:find('#') or text:find('|c') then
			r, g, b, a= e.HEX_to_RGB(text)
		else
			r, g, b, a= text:match('(.-) (.-) (.-) (.+)')
			if not r or not g or not b then
				r, g, b= text:match('(.-) (.-) (.+)')
			end

			if not r or not g or not b then
				r, g, b= text:match('(%d+) (%d+) (%d+)')
			end
		end

		if r and g and b then
			r= r and tonumber(r) or 1
			g= g and tonumber(g) or 1
			b= b and tonumber(b) or 1
			a= a and tonumber(a) or 1

			r= r>1 and 1 or b<0 and 0 or r
			g= g>1 and 1 or g<0 and 0 or g
			b= b>1 and 1 or b<0 and 0 or b
			a= a>1 and 1 or a<0 and 0 or a

			local maxValue= max(r, g, b)
			if maxValue<=1 then
				return r,g,b,a
			elseif maxValue<=255 then
				a= (not a or a==1) and 255 or a
				return r/255, g/255, b/255, a/255
			end
		end
	end
	Frame.rgb:SetScript('OnEnterPressed', function(self)
		local r, g, b, a= self:get_RGB()
		if r and g and b then
			set_Edit_Text(r, g, b, (a or 1), nil)
			self:ClearFocus()
		end
	end)
	Frame.rgb.lable=WoWTools_LabelMixin:CreateLabel(Frame.rgb, {size=10})--10)--提示，修改，颜色
	Frame.rgb.lable:SetPoint('RIGHT', Frame.rgb,-2,0)
	Frame.rgb:SetScript('OnTextChanged', function(self, userInput)
		if userInput then
			local r, g, b, a= self:get_RGB()
			if r and g and b and a then
				self.lable:SetFormattedText('r%.2f g%.2f b%.2f a%.2f', r,g,b,a)
				self.lable:SetTextColor(r,g,b)
			else
				self.lable:SetText('')
			end
		else
			self.lable:SetText('')
		end
	end)
	set_EnterTips(Frame.rgb, function(self)--建立一个图标，提示Enter键
		e.tips:SetOwner(self, "ANCHOR_RIGHT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(e.onlyChinese and '回车按键' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, KEY_ENTER, SELF_CAST_KEY_PRESS))
		e.tips:AddLine('1.00, 0.00, 1.00, 1.00')
		e.tips:AddLine('1.00, 0.00, 1.00')
		e.tips:AddLine(' ')
		e.tips:AddDoubleLine(e.addName, e.cn(addName))
		e.tips:Show()
		self:SetAlpha(0.3)
	end)


	Frame.rgb2= CreateFrame("EditBox", nil, Frame, 'InputBoxTemplate')--r=1, b=1, g=1, a=1
	Frame.rgb2:SetPoint("TOPLEFT", Frame.rgb, 'BOTTOMLEFT',0,-2)
	Frame.rgb2:SetSize(w,20)
	Frame.rgb2:SetAutoFocus(false)
	Frame.rgb2:ClearFocus()
	function Frame.rgb2:get_RGB()
		local text= self:GetText() or ''
		text= text:gsub(',',' ')
		text= text:gsub('，',' ')
		text= text:gsub('  ',' ')
		text= strlower(text)
		local r, g, b, a= text:match('r=(.-) g=(.-) b=(.-) a=(.+)')
		if not (r or g or b) then
			r, g, b= text:match('r=(.-) g=(.-) b=(.+)')
		end
		r, g, b, a= r and tonumber(r), g and tonumber(g), b and tonumber(b), a and tonumber(a) or 1
		if r and g and b then
			r= r>1 and 1 or b<0 and 0 or r
			g= g>1 and 1 or g<0 and 0 or g
			b= b>1 and 1 or b<0 and 0 or b
			a= a>1 and 1 or a<0 and 0 or a
			return r, g, b, a
		end
	end
	Frame.rgb2:SetScript('OnEnterPressed', function(self)
		local r, g, b, a= self:get_RGB()
			if r and g and b then
				local maxValue= max(r, g, b, a)
				if maxValue<=1 then
					set_Edit_Text(r, g, b, a, nil)
				elseif maxValue<=255 then
					a= a==1 and 255 or a
					set_Edit_Text(r/255, g/255, b/255, a/255, nil)
				end
				self:ClearFocus()
		end
	end)
	Frame.rgb2.lable=WoWTools_LabelMixin:CreateLabel(Frame.rgb2, {size=10})--10)--提示，修改，颜色
	Frame.rgb2.lable:SetPoint('RIGHT', Frame.rgb2,-2,0)
	Frame.rgb2:SetScript('OnTextChanged', function(self, userInput)
		if userInput then
			local r, g, b, a= self:get_RGB()
			if r and g and b then
				self.lable:SetFormattedText('r%.2f g%.2f b%.2f a%.2f', r,g,b,a)
				self.lable:SetTextColor(r,g,b)
			else
				self.lable:SetText('')
			end
		else
			self.lable:SetText('')
		end
	end)
	set_EnterTips(Frame.rgb2, function(self)--建立一个图标，提示Enter键
		e.tips:SetOwner(self, "ANCHOR_RIGHT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(e.onlyChinese and '回车按键' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, KEY_ENTER, SELF_CAST_KEY_PRESS))
		e.tips:AddLine('r=1.00, g=0.00, b=1.00, a=1.00')
		e.tips:AddLine('r=1.00, g=0.00, b=1.00')
		e.tips:AddLine(' ')
		e.tips:AddDoubleLine(e.addName, e.cn(addName))
		e.tips:Show()
		self:SetAlpha(0.3)
	end)


	Frame.hex= CreateFrame("EditBox", nil, Frame, 'InputBoxTemplate')--|cff808080
	Frame.hex:SetPoint("TOPLEFT", Frame.rgb2, 'BOTTOMLEFT',0,-2)
	Frame.hex:SetSize(w,20)
	Frame.hex:SetAutoFocus(false)
	Frame.hex:ClearFocus()
	function Frame.hex:get_RGB()
		return e.HEX_to_RGB(self:GetText())
	end
	Frame.hex:SetScript('OnEnterPressed', function(self)
		local r, g, b, a= self:get_RGB()
		if r and g and b then
			set_Edit_Text(r, g, b, a, nil)
			self:ClearFocus()
		end
	end)
	local hexText=WoWTools_LabelMixin:CreateLabel(Frame)--提示
	hexText:SetPoint('RIGHT', Frame.hex, 'LEFT',-2,0)
	hexText:SetText('|c')

	Frame.hex.lable=WoWTools_LabelMixin:CreateLabel(Frame.hex, {size=10})--10)--提示，修改，颜色
	Frame.hex.lable:SetPoint('RIGHT', Frame.hex,-2,0)
	Frame.hex:SetScript('OnTextChanged', function(self, userInput)
		if userInput then
			local r, g, b, a= self:get_RGB()
			if r and g and b then
				self.lable:SetFormattedText('r%.2f g%.2f b%.2f a%.2f', r,g,b,a or 1)
				self.lable:SetTextColor(r,g,b)
			else
				self.lable:SetText('')
			end
		else
			self.lable:SetText('')
		end
	end)

	set_EnterTips(Frame.hex, function(self)--建立一个图标，提示Enter键
		e.tips:SetOwner(self, "ANCHOR_RIGHT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(e.onlyChinese and '回车按键' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, KEY_ENTER, SELF_CAST_KEY_PRESS))
		e.tips:AddLine('|c........')
		e.tips:AddLine('ff00ff00')
		e.tips:AddLine('Hex #......')

		e.tips:AddLine(' ')
		e.tips:AddDoubleLine(e.addName, e.cn(addName))
		e.tips:Show()
		self:SetAlpha(0.3)
	end)

	Frame.cn= CreateFrame("EditBox", nil, Frame, 'InputBoxTemplate')--格式 RED_FONT_COLOR
	Frame.cn:SetPoint("TOPLEFT", Frame.hex, 'BOTTOMLEFT',0,-2)
	Frame.cn:SetSize(w,20)
	Frame.cn:SetAutoFocus(false)
	Frame.cn:ClearFocus()

	Frame.cn2= CreateFrame("EditBox", nil, Frame, 'InputBoxTemplate')--格式 '|cnGREEN_FONT_COLOR:'
	Frame.cn2:SetPoint("TOPLEFT", Frame.cn, 'BOTTOMLEFT',0,-2)
	Frame.cn2:SetSize(w,20)
	Frame.cn2:SetAutoFocus(false)
	Frame.cn2:ClearFocus()
	local cnText2=WoWTools_LabelMixin:CreateLabel(Frame)--提示
	cnText2:SetPoint('LEFT', Frame.cn2, 'RIGHT', 2,0)
	cnText2:SetText(':')











	local restColor= create_Texture(e.Player.r, e.Player.g, e.Player.b, 1)--记录，打开时的颜色， 和历史
	if ColorSwatch then
		restColor:SetPoint('TOP', ColorSwatch, 'BOTTOM', 0, -60)
	else
		restColor:SetPoint('TOPLEFT', ColorPickerFrame.Content.ColorSwatchCurrent, 'TOPRIGHT', 2,0)
	end
	restColor:SetScript('OnShow', function(self)
		local r, g, b, a= e.Get_ColorFrame_RGBA()
		self:SetColorTexture(r, g, b, a)
		self.r, self.g, self.b, self.a= r, g, b, a

		for i=1, #Save.color do
			local texture= self[i]
			local col= Save.color[i]
			if not self[i] then
				texture= create_Texture(col.r, col.g, col.b, 1)--记录，打开时的颜色， 和历史
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
		for i= 11, #Save.color, 10 do
			self[i]:ClearAllPoints()
			self[i]:SetPoint('TOPRIGHT', self[i-10], 'TOPLEFT')
		end
	end)










	if OpacitySliderFrame then
		Frame.alphaText=WoWTools_LabelMixin:CreateLabel(OpacitySliderFrame, {mouse=true, size=14})--14)--透明值，提示
		Frame.alphaText:SetPoint('LEFT', OpacitySliderFrame, 'RIGHT', 5,0)

		OpacitySliderFrame:EnableMouseWheel(true)
		OpacitySliderFrame:SetScript('OnMouseWheel', function(self, d)
			local value= self:GetValue()
			if d== 1 then
				value= value- 0.01
			elseif d==-1 then
				value= value+ 0.01
			end
			value= value> 1 and 1 or value
			value= value< 0 and 0 or value
			self:SetValue(value)
		end)
	else
		Frame.alphaText=WoWTools_LabelMixin:CreateLabel(ColorPickerFrame, {mouse=true, size=14})--透明值，提示
		Frame.alphaText:SetPoint('TOP', ColorPickerFrame.Content.ColorSwatchOriginal, 'BOTTOM')
	end
	Frame.alphaText:SetScript('OnLeave', function(self) self:SetAlpha(1) e.tips:Hide() end)
	Frame.alphaText:SetScript('OnEnter', function(self)
		e.tips:SetOwner(self, "ANCHOR_LEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(e.addName, e.cn(addName))
		e.tips:AddDoubleLine(e.onlyChinese and '透明度' or CHANGE_OPACITY, 'Alpha')
		e.tips:Show()
	end)








	if ColorPickerOkayButton then
		ColorPickerOkayButton:HookScript('OnMouseDown', function()--记录，历史
			local r, g, b, a= e.Get_ColorFrame_RGBA()
			for _, col in pairs(Save.color) do
				if col.r==r and col.g==g and col.b==b and col.a== a then
					return
				end
			end
			if #Save.color >=logNum then
				table.remove(Save.color, 1)
			end
			table.insert(Save.color,{r=r, g=g, b=b, a=a})
		end)
		ColorPickerFrame:HookScript('OnUpdate', set_Text)
	else
		ColorPickerFrame.Footer.OkayButton:HookScript('OnClick', function()
			local r, g, b, a= e.Get_ColorFrame_RGBA()
			for _, col in pairs(Save.color) do
				if col.r==r and col.g==g and col.b==b and col.a== a then
					return
				end
			end
			if #Save.color >=logNum then
				table.remove(Save.color, 1)
			end
			table.insert(Save.color,{r=r, g=g, b=b, a=a})
		end)
		ColorPickerFrame.Content.ColorPicker:HookScript("OnColorSelect", set_Text)
	end

	Frame:SetShown(not Save.hide)
end





















panel:RegisterEvent('ADDON_LOADED')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
			Save.color= Save.color or {}

			--添加控制面板
			e.AddPanel_Check_Button({
				checkName=  '|A:colorblind-colorwheel:0:0|a'..(e.onlyChinese and '颜色选择器' or addName),
				GetValue= function() return not Save.disabled end,
				SetValue= function()
					Save.disabled= not Save.disabled and true or nil
                	print(e.addName, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
				end,
				buttonText='|A:QuestArtifact:0:0|a'..(e.onlyChinese and '测试' or 'Test'),
				buttonFunc= function()
					e.ShowColorPicker(e.Player.r, e.Player.g, e.Player.b, 1, function()end)
                end,
				tooltip= e.cn(addName),
				layout= nil,
				category= nil,
			})


            if not Save.disabled then
				local check2= CreateFrame("CheckButton", nil, ColorPickerFrame, "InterfaceOptionsCheckButtonTemplate")--显示/隐藏
				check2:SetCheckedTexture('MonsterFriend')
				check2.type2= CreateFrame("CheckButton", nil, ColorPickerFrame, "InterfaceOptionsCheckButtonTemplate")--显示/隐藏
				check2.type2:SetCheckedTexture('MonsterFriend')
				check2:SetPoint("TOPLEFT", ColorPickerFrame, 7, -7)
				check2:SetChecked(not Save.hide)
				check2:SetScript('OnMouseDown', function()
					Save.hide= not Save.hide and true or nil
					if not Save.hide and not Frame then
						Init()
					end
					if Frame then
						Frame:SetShown(not Save.hide)
						print(e.addName, e.cn(addName), e.GetShowHide(not Save.hide))
					end
				end)
				check2:SetScript('OnEnter', function()
					e.tips:SetOwner(ColorPickerFrame, "ANCHOR_RIGHT");
					e.tips:ClearLines();
					e.tips:AddDoubleLine(e.GetShowHide(not Save.color)..e.Icon.left)
					e.tips:AddDoubleLine(e.addName, e.cn(addName))
					e.tips:Show();
				end)
				check2:SetScript('OnLeave', GameTooltip_Hide)


				check2.type2:SetPoint("LEFT", check2, 'RIGHT',-4,0)
				check2.type2:SetChecked(Save.colorType)
				check2.type2:SetScript('OnMouseDown', function()
					Save.colorType= not Save.colorType and true or nil
					print(e.addName, e.cn(addName), e.GetEnabeleDisable(Save.colorType), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
				end)
				check2.type2:SetScript('OnEnter', function()
					e.tips:SetOwner(ColorPickerFrame, "ANCHOR_RIGHT");
					e.tips:ClearLines();
					e.tips:AddDoubleLine(e.onlyChinese and '颜色' or COLOR, 2)
					e.tips:AddDoubleLine(e.addName, e.cn(addName))
					e.tips:Show();
				end)
				check2.type2:SetScript('OnLeave', GameTooltip_Hide)

				if not Save.hide then
					Init()
				end


            end
            panel:UnregisterEvent('ADDON_LOADED')
            panel:RegisterEvent('PLAYER_LOGOUT')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)

--[[


local function RGB_to_HSV(r, g, b)--ColorPickerPlus
	local mincolor, maxcolor = math.min(r, g, b), math.max(r, g, b)
	local ch, cs, cv = 0, 0, maxcolor
	if maxcolor > 0 then -- technically ch is undefined if cs is zero
		local delta = maxcolor - mincolor
		cs = delta / maxcolor
		if delta > 0 then -- don't allow divide by zero
			if r == maxcolor then
				ch = (g - b) / delta -- between yellow and magenta
			elseif g == maxcolor then
				ch = 2 + ((b - r) / delta) -- between cyan and yellow
			else
				ch = 4 + ((r - g) / delta) -- between magenta and cyan
			end
		end
		if ch < 0 then ch = ch + 6 end -- correct for negative values
		ch = ch / 6 -- and finally adjust range 0 to 1.0
	end
	return ch, cs, cv
end

-- Convert h, s, l input values into r, g, b return values
-- All values are in the range 0 to 1.0
local function HSV_to_RGB(ch, cs, cv)
	if not ch or not cs or not cv then return 1, 0, 0 end
	if ch == 1 then ch = 0 end
	local r, g, b = cv, cv, cv
	if cs > 0 then -- if cs is zero then grey is returned
		local h = ch * 6; local sextant = math.floor(h) -- figure out which sextant of the color wheel
		local fract = h - sextant -- fractional offset into the sextant
		local p, q, t = cv * (1 - cs), cv * (1 - (cs * fract)), cv * (1 - (cs * (1 - fract)))
		if sextant == 0 then
			r, g, b = cv, t, p
		elseif sextant == 1 then
			r, g, b = q, cv, p
		elseif sextant == 2 then
			r, g, b = p, cv, t
		elseif sextant == 3 then
			r, g, b = p, q, cv
		elseif sextant == 4 then
			r, g, b = t, p, cv
		else
			r, g, b = cv, p, q
		end
	end
	return r, g, b
end
]]