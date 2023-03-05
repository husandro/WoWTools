local id, e= ...
local Save= {
		color={},--保存，历史记录
}
local addName= COLOR_PICKER..' Plus'--"颜色选择器";
local panel= CreateFrame("Frame")--ColorPickerFrame.xml
local logNum= 30--记录数量



local timeElapsed=0
local function set_Text(self, elapsed)
	timeElapsed = timeElapsed + elapsed
	if timeElapsed > 0.3 then
		local r, g, b, a= e.Get_ColorFrame_RGBA()
		if ColorPickerFrame.rgb then
			if not ColorPickerFrame.rgb:HasFocus() then
				ColorPickerFrame.rgb:SetText(format('%.2f %.2f %.2f %.2f', r,g,b,a))
			end
			if not ColorPickerFrame.rgb2:HasFocus() then
				ColorPickerFrame.rgb2:SetText(format('r=%.2f, g=%.2f, b=%.2f, a=%.2f', r,g,b,a))
			end
			if not ColorPickerFrame.hex:HasFocus() then
				ColorPickerFrame.hex:SetText(e.RGB_to_HEX(r,g,b,a))
			end
		end
		ColorPickerFrame.Header.Text:SetTextColor(r,g,b)
		ColorPickerFrame.alphaText:SetFormattedText('%.2f', a)
		ColorPickerFrame.alphaText:SetTextColor(r,g,b)
	end
end

local function set_Edit_Text(r, g, b, a, textCode)
	ColorPickerFrame:SetColorRGB(r, g, b)
	OpacitySliderFrame:SetValue(a or 1);
	ColorPickerFrame.cn:SetText(textCode and textCode..'_CODE' or '')
	ColorPickerFrame.cn2:SetText(textCode and '|cn'..textCode or '')
end
--####
--初始
--####
local function Init(self)
	local size, x, y, n
	local function create_Texture(r,g,b,a, atlas)
		local texture= self:CreateTexture()
		texture:SetSize(size, size)
		texture:EnableMouse(true)
		texture.r, texture.g, texture.b, texture.a= r, g, b, a
		texture:SetScript('OnMouseDown', function(self2)
			set_Edit_Text(self2.r, self2.g, self2.b, self2.a, self2.textCode)
		end)
		texture:SetScript('OnEnter', function(self2)
			if self2.tooltip then
				e.tips:SetOwner(self, "ANCHOR_RIGHT")
				e.tips:ClearLines()
				e.tips:AddLine(self2.tooltip)
				e.tips:Show()
			end
		end)
		texture:SetScript('OnLeave', function() e.tips:Hide() end)
		if atlas then
			texture:SetAtlas(atlas)
		else
			texture:SetColorTexture(r, g, b, 1)
		end
		return texture
	end


	size, x, y, n= 22, 0, -15, 1
	for className, col in pairs(RAID_CLASS_COLORS) do--职业 ColorUtil.lua
		local texture= create_Texture(col.r, col.g, col.b, col.a, e.Class(nil, className, true))
		texture:SetPoint('TOPLEFT', self, 'TOPRIGHT', x, y)
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

	size, x, y, n= 16, x+size, -15, 0
	for index, col in pairs(ITEM_QUALITY_COLORS) do--物品 UIParent.lua
		local texture= create_Texture(col.r, col.g, col.b, col.a)
		texture:SetPoint('TOPLEFT', self, 'TOPRIGHT', x, y)
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
	n=n+1
	for name, col in pairs(MATERIAL_TEXT_COLOR_TABLE) do--SharedColorConstants.lua
		local texture= create_Texture(col.r, col.g, col.b, col.a)
		texture:SetPoint('TOPLEFT', self, 'TOPRIGHT', x, y)
		texture.tooltip= 'MATERIAL_TEXT_COLOR_TABLE'..'["'..name..'"]'
		if n==10 then
			n=0
			x= x+ size
			y= -15
		else
			y= y- size
		end
		n=n+1
	end
	for name, col in pairs(MATERIAL_TITLETEXT_COLOR_TABLE) do--SharedColorConstants.lua
		local texture= create_Texture(col.r, col.g, col.b, col.a)
		texture:SetPoint('TOPLEFT', self, 'TOPRIGHT', x, y)
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
	for name, col in pairs(COVENANT_COLORS) do--SharedColorConstants.lua
		if type(name)~='number' then
			local texture= create_Texture(col.r, col.g, col.b, col.a)
			texture:SetPoint('TOPLEFT', self, 'TOPRIGHT', x, y)
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
	for name, col in pairs(PLAYER_FACTION_COLORS) do--SharedColorConstants.lua
		local texture= create_Texture(col.r, col.g, col.b, col.a)
		texture:SetPoint('TOPLEFT', self, 'TOPRIGHT', x, y)
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

	size, x, y, n= 16, 2, 8, 1
	local DBColors = C_UIColor.GetColors();--Color.lua
	for _, dbColor in ipairs(DBColors) do
		local texture= create_Texture(dbColor.color.r, dbColor.color.g, dbColor.color.b, dbColor.color.a)
		texture.textCode= dbColor.baseTag
		texture:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', x, y)
		if n==22 then
			n=0
			y=y +size
			x=2
		else
			x=x +size
		end
		n=n+1
	end

	local w=290
	self.rgb= CreateFrame("EditBox", nil, self, 'InputBoxTemplate')-- 1 1 1 1
	self.rgb:SetPoint("TOPLEFT", self, 'BOTTOMLEFT',10,0)
	self.rgb:SetSize(w,20)
	self.rgb:SetAutoFocus(false)
	self.rgb:SetScript('OnEnterPressed', function(self2)
		local text= self2:GetText()
		text= text:gsub('  ',' ')
		local r, g, b, a= text:match('(.-) (.-) (.-) (.+)')
		a= a or '1'
		if r and g and b then
			r, g, b, a= tonumber(r), tonumber(g), tonumber(b), tonumber(a)
			if r and g and b then
				set_Edit_Text(r, g, b, a, nil)
				self2:ClearFocus()
			end
		end
	end)

	self.rgb2= CreateFrame("EditBox", nil, self, 'InputBoxTemplate')--r=1, b=1, g=1, a=1
	self.rgb2:SetPoint("TOPLEFT", self.rgb, 'BOTTOMLEFT',0,-2)
	self.rgb2:SetSize(w,20)
	self.rgb2:SetAutoFocus(false)
	self.rgb2:SetScript('OnEnterPressed', function(self2)
		local text= self2:GetText()
		text= text:gsub(' ','')
		text= text:gsub('，', ',')
		text= strlower(text)
		local r, g, b, a= text:match('r=(.-),g=(.-),b=(.-),a=(.+)')
		a= a or '1'
		if r and g and b then
			r, g, b, a= tonumber(r), tonumber(g), tonumber(b), tonumber(a)
			if r and g and b then
				set_Edit_Text(r, g, b, a, nil)
				self2:ClearFocus()
			end
		end
	end)

	self.hex= CreateFrame("EditBox", nil, self, 'InputBoxTemplate')--|cff808080
	self.hex:SetPoint("TOPLEFT", self.rgb2, 'BOTTOMLEFT',0,-2)
	self.hex:SetSize(w,20)
	self.hex:SetAutoFocus(false)
	self.hex:SetScript('OnEnterPressed', function(self2)
		local text= self2:GetText()
		text= text:gsub(' ','')
		local r, g, b, a= e.HEX_to_RGB(text)
		a= a or '1'
		if r and g and b then
			set_Edit_Text(r, g, b, a, nil)
			self2:ClearFocus()
		end
	end)
	local hexText=e.Cstr(self)--提示
	hexText:SetPoint('RIGHT', self.hex, 'LEFT',-2,0)
	hexText:SetText('|c')

	self.hex.hexText=e.Cstr(self.hex, 18)--提示，修改，颜色
	self.hex.hexText:SetPoint('RIGHT', self.hex,-2,0)
	self.hex:SetScript('OnTextChanged', function(self2, userInput)
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

	self.cn= CreateFrame("EditBox", nil, self, 'InputBoxTemplate')--格式 RED_FONT_COLOR
	self.cn:SetPoint("TOPLEFT", self.hex, 'BOTTOMLEFT',0,-2)
	self.cn:SetSize(w,20)
	self.cn:SetAutoFocus(false)

	self.cn2= CreateFrame("EditBox", nil, self, 'InputBoxTemplate')--格式 '|cnGREEN_FONT_COLOR:'
	self.cn2:SetPoint("TOPLEFT", self.cn, 'BOTTOMLEFT',0,-2)
	self.cn2:SetSize(w,20)
	self.cn2:SetAutoFocus(false)
	local cnText2=e.Cstr(self)--提示
	cnText2:SetPoint('LEFT', self.cn2, 'RIGHT', 2,0)
	cnText2:SetText(':')

	self.alphaText=e.Cstr(OpacitySliderFrame, 16)--透明值，提示
	self.alphaText:SetPoint('LEFT', OpacitySliderFrame, 'RIGHT', 5,0)

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
				texture:SetPoint('TOPRIGHT', self, 'TOPLEFT', x, y)
			end
			texture.r, texture.g, texture.b, texture.a= col.r, col.g, col.b, col.a
			texture:SetColorTexture(col.r, col.g, col.b ,1)

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

	ColorPickerOkayButton:SetScript('OnMouseDown', function()--记录，历史
		if #Save.color >=logNum then
			table.remove(Save.color, 1)
		end
		local r, g, b, a= e.Get_ColorFrame_RGBA()
		table.insert(Save.color,{r=r, g=g, b=b, a=a})
	end)
end

panel:RegisterEvent('ADDON_LOADED')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
			Save.color= Save.color or {}

            --添加控制面板        
            panel.check=e.CPanel((e.onlyChinese and '颜色选择器增强' or addName)..'|A:colorblind-colorwheel:0:0|a', not Save.disabled, true)
            panel.check:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)
			--panel.check.text:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
			panel.check.text:EnableMouse(true)
			panel.check.text:SetScript('OnMouseDown', function()
                e.ShowColorPicker(e.Player.r, e.Player.g, e.Player.b, 1, function()
					set_Text(nil, 3)
				end)
			end)

            if not Save.disabled then
                Init(ColorPickerFrame)
				ColorPickerFrame:SetScript('OnUpdate', set_Text)
            end
            panel:UnregisterEvent('ADDON_LOADED')
            panel:RegisterEvent('PLAYER_LOGOUT')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
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