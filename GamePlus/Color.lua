local id, e= ...
local Save= {
		color={},--保存，历史记录
}
local addName= COLOR_PICKER..' Plus'--"颜色选择器";
local panel= CreateFrame("Frame")--ColorPickerFrame.xml
local logNum= 30--记录数量

local Frame

local timeElapsed=0
local function set_Text(_, elapsed)
	if not Frame or not Frame:IsShown() then
		return
	end
	timeElapsed = timeElapsed + elapsed
	if timeElapsed > 0.3 then
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
				Frame.hex:SetText(e.RGB_to_HEX(r,g,b,a))
			end
		end
		ColorPickerFrame.Header.Text:SetTextColor(r,g,b)

		Frame.alphaText:SetFormattedText('%.2f', a)
		Frame.alphaText:SetTextColor(r,g,b)
	end
end

local function set_Edit_Text(r, g, b, a, textCode)
	ColorPickerFrame:SetColorRGB(r, g, b)
	OpacitySliderFrame:SetValue(a and 1-a or 0);
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
		texture:SetScript('OnMouseDown', function(self2)
			set_Edit_Text(self2.r, self2.g, self2.b, self2.a, self2.textCode)
		end)
		texture:SetScript('OnEnter', function(self2)
			if self2.tooltip then
				e.tips:SetOwner(ColorPickerFrame, "ANCHOR_RIGHT")
				e.tips:ClearLines()
				e.tips:AddLine(self2.tooltip)
				e.tips:Show()
			end
		end)
		texture:SetScript('OnLeave', function() e.tips:Hide() end)
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
			local texture= create_Texture(col.r, col.g, col.b, col.a, e.Class(nil, className, true))
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
			texture.tooltip= col.hex.._G["ITEM_QUALITY" .. index.. "_DESC"]..'\nITEM_QUALITY' ..index.. '_DESC'
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
	local function get_rgb_Text(text)
		text= text:gsub(',',' ')
		text= text:gsub('，',' ')
		text= text:gsub('  ',' ')
		local r, g, b, a

		if text:find('#') or text:find('|c') then
			text= text:gsub(' ',' ')
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
		a= a or '1'
		if r and g and b then
			r, g, b, a= tonumber(r), tonumber(g), tonumber(b), tonumber(a)
			if r and g and b then
				local maxValue= max(r, g, b)
				if maxValue<=1 then
					return r,g,b,a
				elseif maxValue<=255 then
					a= (not a or a==1) and 255 or a
					return r/255, g/255, b/255, a/255
				end
			end
		end
	end
	local w=290
	Frame.rgb= CreateFrame("EditBox", nil, Frame, 'InputBoxTemplate')-- 1 1 1 1
	Frame.rgb:SetPoint("TOPLEFT", ColorPickerFrame, 'BOTTOMLEFT',10,0)
	Frame.rgb:SetSize(w,20)
	Frame.rgb:SetAutoFocus(false)
	Frame.rgb:ClearFocus()
	Frame.rgb:SetScript('OnEnterPressed', function(self2)
		local r, g, b, a=get_rgb_Text(self2:GetText())
		if r and g and b then
			set_Edit_Text(r, g, b, (a or 1), nil)
			self2:ClearFocus()
		end
	end)
	Frame.rgb.lable=e.Cstr(Frame.rgb, {size=10})--10)--提示，修改，颜色
	Frame.rgb.lable:SetPoint('RIGHT', Frame.rgb,-2,0)
	Frame.rgb:SetScript('OnTextChanged', function(self2, userInput)
		if userInput then
			local r, g, b, a= get_rgb_Text(self2:GetText())
			if r and g and b and a then
				self2.lable:SetFormattedText('r%.2f g%.2f b%.2f a%.2f', r,g,b,a)
				self2.lable:SetTextColor(r,g,b)
			else
				self2.lable:SetText('')
			end
		else
			self2.lable:SetText('')
		end
	end)


	Frame.rgb2= CreateFrame("EditBox", nil, Frame, 'InputBoxTemplate')--r=1, b=1, g=1, a=1
	Frame.rgb2:SetPoint("TOPLEFT", Frame.rgb, 'BOTTOMLEFT',0,-2)
	Frame.rgb2:SetSize(w,20)
	Frame.rgb2:SetAutoFocus(false)
	Frame.rgb2:ClearFocus()
	Frame.rgb2:SetScript('OnEnterPressed', function(self2)
		local text= self2:GetText()
		text= text:gsub(' ','')
		text= text:gsub('，', ',')
		text= strlower(text)
		local r, g, b, a= text:match('r=(.-),g=(.-),b=(.-),a=(.+)')
		a= a or '1'
		if r and g and b then
			r, g, b, a= tonumber(r), tonumber(g), tonumber(b), tonumber(a)
			if r and g and b then
				local maxValue= max(r, g, b, a)
				if maxValue<=1 then
					set_Edit_Text(r, g, b, a, nil)
				elseif maxValue<=255 then
					a= a==1 and 255 or a
					set_Edit_Text(r/255, g/255, b/255, a/255, nil)
				end
				self2:ClearFocus()
			end
		end
	end)

	Frame.hex= CreateFrame("EditBox", nil, Frame, 'InputBoxTemplate')--|cff808080
	Frame.hex:SetPoint("TOPLEFT", Frame.rgb2, 'BOTTOMLEFT',0,-2)
	Frame.hex:SetSize(w,20)
	Frame.hex:SetAutoFocus(false)
	Frame.hex:ClearFocus()
	Frame.hex:SetScript('OnEnterPressed', function(self2)
		local text= self2:GetText()
		text= text:gsub(' ','')
		local r, g, b, a= e.HEX_to_RGB(text)
		a= a or '1'
		if r and g and b then
			set_Edit_Text(r, g, b, a, nil)
			self2:ClearFocus()
		end
	end)
	local hexText=e.Cstr(Frame)--提示
	hexText:SetPoint('RIGHT', Frame.hex, 'LEFT',-2,0)
	hexText:SetText('|c')

	Frame.hex.hexText=e.Cstr(Frame.hex, {size=10})--10)--提示，修改，颜色
	Frame.hex.hexText:SetPoint('RIGHT', Frame.hex,-2,0)
	Frame.hex:SetScript('OnTextChanged', function(self2, userInput)
		if userInput then
			local text= self2:GetText()
			text= text:gsub(' ','')
			local r, g, b, a= e.HEX_to_RGB(text)
			a= a or '1'
			if r and g and b then
				self2.hexText:SetFormattedText('r%.2f g%.2f b%.2f a%.2f', r,g,b,a)
				self2.hexText:SetTextColor(r,g,b)
			else
				self2.hexText:SetText('')
			end
		else
			self2.hexText:SetText('')
		end
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
	local cnText2=e.Cstr(Frame)--提示
	cnText2:SetPoint('LEFT', Frame.cn2, 'RIGHT', 2,0)
	cnText2:SetText(':')

	Frame.alphaText=e.Cstr(OpacitySliderFrame, {size=14})--14)--透明值，提示
	Frame.alphaText:SetPoint('LEFT', OpacitySliderFrame, 'RIGHT', 5,0)

	size= 18
	local restColor= create_Texture(e.Player.r, e.Player.g, e.Player.b, 1)--记录，打开时的颜色， 和历史
	restColor:SetPoint('TOP', ColorSwatch, 'BOTTOM', 0, -60)
	restColor:SetScript('OnShow', function(self2)
		local r, g, b, a= e.Get_ColorFrame_RGBA()
		self2:SetColorTexture(r, g, b, a)
		self2.r, self2.g, self2.b, self2.a= r, g, b, a

		size, x, y, n= 16, 0, -15, 0
		for i=1, #Save.color do
			local texture= self2[i]
			local col= Save.color[i]
			if not self2[i] then
				texture= create_Texture(col.r, col.g, col.b, 1)--记录，打开时的颜色， 和历史
				self2[i]= texture
				texture:SetPoint('TOPRIGHT', ColorPickerFrame, 'TOPLEFT', x, y)
			end
			texture.r, texture.g, texture.b, texture.a= col.r, col.g, col.b, col.a
			texture:SetColorTexture(col.r, col.g, col.b , col.a)

			if n==10 then
				n=0
				x= x- size
				y= -15
			else
				y= y- size
			end
			n=n+1
		end
	end)



	ColorPickerFrame:SetScript('OnUpdate', set_Text)
	Frame:SetShown(not Save.hide)
end

panel:RegisterEvent('ADDON_LOADED')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
			Save.color= Save.color or {}

            --添加控制面板        
            panel.check=e.CPanel('|A:colorblind-colorwheel:0:0|a'..(e.onlyChinese and '颜色选择器增强' or addName), not Save.disabled, true)
            panel.check:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)

			panel.check.text:EnableMouse(true)
			panel.check.text:SetScript('OnLeave', function() e.tips:Hide() end)
			panel.check.text:SetScript('OnEnter', function(self2)
				e.tips:SetOwner(self2, "ANCHOR_LEFT")
				e.tips:ClearLines()
				e.tips:AddDoubleLine(e.onlyChinese and '颜色选择器' or COLOR_PICKER, (e.onlyChinese and '打开' or UNWRAP)..e.Icon.left)
				e.tips:Show()
			end)
			panel.check.text:SetScript('OnMouseDown', function()
                e.ShowColorPicker(e.Player.r, e.Player.g, e.Player.b, 1, function()
					set_Text(nil, 3)
				end)
			end)

            if not Save.disabled then
				local check2= CreateFrame("CheckButton", nil, ColorPickerFrame, "InterfaceOptionsCheckButtonTemplate")--显示/隐藏
				check2:SetPoint("TOPLEFT", ColorPickerFrame, 7, -7)
				check2:SetChecked(not Save.hide)
				check2:SetScript('OnMouseDown', function()
					Save.hide= not Save.hide and true or nil
					if not Save.hide and not Frame then
						Init()
					end
					if Frame then
						Frame:SetShown(not Save.hide)
						print(id, addName, e.GetShowHide(not Save.hide))
					end
				end)
				check2:SetScript('OnEnter', function()
					e.tips:SetOwner(ColorPickerFrame, "ANCHOR_RIGHT");
					e.tips:ClearLines();
					e.tips:AddDoubleLine(e.GetShowHide(true), e.GetShowHide(false))
					e.tips:AddDoubleLine(id, addName)
					e.tips:Show();
				end)
				check2:SetScript('OnLeave', function() e.tips:Hide() end)

				local colorTypeCheck= CreateFrame("CheckButton", nil, ColorPickerFrame, "InterfaceOptionsCheckButtonTemplate")--显示/隐藏
				colorTypeCheck:SetPoint("LEFT", check2, 'RIGHT',-4,0)
				colorTypeCheck:SetChecked(Save.colorType)
				colorTypeCheck:SetScript('OnMouseDown', function()
					Save.colorType= not Save.colorType and true or nil
					print(id, addName, e.GetEnabeleDisable(Save.colorType), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
				end)
				colorTypeCheck:SetScript('OnEnter', function()
					e.tips:SetOwner(ColorPickerFrame, "ANCHOR_RIGHT");
					e.tips:ClearLines();
					e.tips:AddDoubleLine(COLOR, 2)
					e.tips:AddDoubleLine(id, addName)
					e.tips:Show();
				end)
				colorTypeCheck:SetScript('OnLeave', function() e.tips:Hide() end)

				if not Save.hide then
					Init()
				end

				ColorPickerOkayButton:SetScript('OnMouseDown', function()--记录，历史
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