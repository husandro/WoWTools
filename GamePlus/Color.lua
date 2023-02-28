local id, e= ...
local Save= {}
local addName= COLOR_PICKER..' Plus'--"颜色选择器";
local panel= CreateFrame("Frame")--ColorPickerFrame.xml

local RGB_to_HEX=function(r, g, b, a)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	a = a <= 1 and a >= 0 and a or 0
	return format("%02x%02x%02x%02x", a*255, r*255, g*255, b*255)
end

local function set_Text()
	local a, r, g, b = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB()
	if ColorPickerFrame.rgb then
		ColorPickerFrame.rgb:SetText(format('%.2f, %.2f, %.2f, %.2f', r,g,b,a))
		ColorPickerFrame.rgb2:SetText(format('r=%.2f, g=%.2f, b=%.2f, a=%.2f', r,g,b,a))
		ColorPickerFrame.hex:SetText(RGB_to_HEX(r,g,b,a))
		ColorPickerFrame.cn:SetText('')
		ColorPickerFrame.cn2:SetText('')
	end
	ColorPickerFrame.Header.Text:SetTextColor(r,g,b)
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
			ColorPickerFrame:SetColorRGB(self2.r, self2.g, self2.b)
			ColorPickerFrame.opacity = self2.a;
			ColorPickerFrame.cn:SetText(self2.textCode and self2.textCode..'_CODE' or '')
			ColorPickerFrame.cn2:SetText(self2.textCode and '|cn'..self2.textCode or '')
		end)
		if atlas then
			texture:SetAtlas(atlas)
		else
			texture:SetColorTexture(r, g, b, 1)
		end
		return texture
	end


	size, x, y, n= 28, 0, 0, 1
	local classes = {"HUNTER", "WARLOCK", "PRIEST", "PALADIN", "MAGE", "ROGUE", "DRUID", "SHAMAN", "WARRIOR", "DEATHKNIGHT", "MONK", "DEMONHUNTER", "EVOKER"}
	for _, className in pairs(classes) do--ColorUtil.lua
		local col= C_ClassColor.GetClassColor(className)
		local texture= create_Texture(col.r, col.g, col.b, col.a, e.Class(nil, className, true))
		texture:SetPoint('TOPLEFT', self, 'TOPRIGHT', x, y)
		if n==7 then
			n=0
			x= x+ size+2
			y= 0
		else
			y= y- size-2
		end
		n=n+1
	end

	size, x, y, n= 22, -50, 8, 1
	local DBColors = C_UIColor.GetColors();--Color.lua
	for _, dbColor in ipairs(DBColors) do
		local texture= create_Texture(dbColor.color.r, dbColor.color.g, dbColor.color.b, dbColor.color.a)
		texture.textCode= dbColor.baseTag
		texture:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', x, y)
		if n==20 then
			n=0
			y=y +size +2
			x=-50
		else
			x=x+size+2
		end
		n=n+1
	end

	local w=350
	self.rgb= CreateFrame("EditBox", nil, self, 'InputBoxTemplate')
	self.rgb:SetPoint("TOPLEFT", self, 'BOTTOMLEFT',10,0)
	self.rgb:SetSize(w,20)
	self.rgb:SetAutoFocus(false)

	self.rgb2= CreateFrame("EditBox", nil, self, 'InputBoxTemplate')
	self.rgb2:SetPoint("TOPLEFT", self.rgb, 'BOTTOMLEFT',0,-2)
	self.rgb2:SetSize(w,20)
	self.rgb2:SetAutoFocus(false)

	self.hex= CreateFrame("EditBox", nil, self, 'InputBoxTemplate')
	self.hex:SetPoint("TOPLEFT", self.rgb2, 'BOTTOMLEFT',0,-2)
	self.hex:SetSize(w,20)
	self.hex:SetAutoFocus(false)
	self.hexText=e.Cstr(self)
	self.hexText:SetPoint('RIGHT', self.hex, 'LEFT',-2,0)
	self.hexText:SetText('|c')

	self.cn= CreateFrame("EditBox", nil, self, 'InputBoxTemplate')
	self.cn:SetPoint("TOPLEFT", self.hex, 'BOTTOMLEFT',0,-2)
	self.cn:SetSize(w,20)
	self.cn:SetAutoFocus(false)

	self.cn2= CreateFrame("EditBox", nil, self, 'InputBoxTemplate')
	self.cn2:SetPoint("TOPLEFT", self.cn, 'BOTTOMLEFT',0,-2)
	self.cn2:SetSize(w,20)
	self.cn2:SetAutoFocus(false)
	self.cnText2=e.Cstr(self)
	self.cnText2:SetPoint('LEFT', self.cn2, 'RIGHT', 2,0)
	self.cnText2:SetText(':')
end

panel:RegisterEvent('ADDON_LOADED')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板        
            panel.check=e.CPanel((e.onlyChinse and '颜色选择器增强' or addName)..'|A:colorblind-colorwheel:0:0|a', not Save.disabled, true)
            panel.check:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end)
			panel.check.text:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
			panel.check.text:EnableMouse(true)
			panel.check.text:SetScript('OnMouseDown', function()
                e.ShowColorPicker(e.Player.r, e.Player.g, e.Player.b, 1, set_Text)
			end)

            if not Save.disabled then
                Init(ColorPickerFrame)
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