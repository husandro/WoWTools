

WoWTools_ColorMixin={}





local function set_Frame_Color(frame, r, g, b, setA, hex)
    if frame then
        local Type= frame:GetObjectType()
        if Type=='FontString' then
            frame:SetTextColor(r, g, b,setA)
        elseif Type=='Texture' then
            --frame:SetVertexColor(r, g, b, setA)
            frame:SetColorTexture(r, g, b,setA)
        end
        frame.r, frame.g, frame.b, frame.a, frame.hex= r, g, b, setA, '|c'..hex
    end
end




--RGB转HEX
function WoWTools_ColorMixin:RGBtoHEX(r, g, b, a, frame)
    if r and g and b then

        r= math.max(math.min(r, 1), 0)
        g= math.max(math.min(g, 1), 0)
        b= math.max(math.min(b, 1), 0)

        a= math.max(math.min(a or 1, 1), 0)

        local hex=format("%02x%02x%02x%02x", a*255, r*255, g*255, b*255)

        set_Frame_Color(frame, r, g, b, a, hex)

        return hex
    end
end





--( ) . % + - * ? [ ^ $ 
--HEX转RGB -- ColorUtil.lua
function WoWTools_ColorMixin:HEXtoRGB(text, frame)
    text= text:gsub(' ','')
	if not text or text=='' then
        return
    end

    text= text:match('|c(.+)') or text
    text= text:gsub('#', '')
    local len= #text

    local r,g,b,a
    if len>8 then
        text=string.sub(text,1,8)
        len=8

    elseif len==7 then
        text=text..'f'
        len=8

    elseif len<6 then
        while len < 6 do
            text = text..'f'
            len = len + 1;
            if len == 6 then
                break
            end
        end
    end

    if len == 8 then
        a, r,g,b= ExtractColorValueFromHex(text, 1), ExtractColorValueFromHex(text, 3), ExtractColorValueFromHex(text, 5), ExtractColorValueFromHex(text, 7)

    elseif len==6 then--#COLOR_FORMAT_RGB
        r,g,b, a= ExtractColorValueFromHex(text, 1), ExtractColorValueFromHex(text, 3), ExtractColorValueFromHex(text, 5), 1
    end
    if r and g and b then
        set_Frame_Color(frame, r, g, b, a or 1, (len~=8 and 'ff' or '')..text)
        return r,g,b, a or 1
    end
end




--取得, ColorFrame, 颜色
function WoWTools_ColorMixin:Get_ColorFrameRGBA()
    local r,g,b= ColorPickerFrame:GetColorRGB()
    local a= ColorPickerFrame.hasOpacity and ColorPickerFrame:GetColorAlpha() or 1
    r= r and tonumber(format('%.2f', r)) or 1
    g= g and tonumber(format('%.2f', g)) or 1
    b= b and tonumber(format('%.2f', b)) or 1
    a= a~=1 and tonumber(format('%.2f', a)) or a
	return r, g, b, a, {r=r, g=g, b=b, a=a}
end






--ColorPickerFrame.lua
function WoWTools_ColorMixin:ShowColorFrame(valueR, valueG, valueB, valueA, swatchFunc, cancelFunc)
    ColorPickerFrame:SetupColorPickerAndShow({
        r=valueR or 1,
        g=valueG or 1,
        b=valueB or 1,
        hasOpacity= valueA and true or false,
        swatchFunc= swatchFunc or function()end,
        cancelFunc= cancelFunc or function()end,
        opacity= valueA or 1,
    })
end





--设置颜色
function WoWTools_ColorMixin:Setup(object, tab)--设置颜色
    tab = tab or {}
    if not object or not (WoWTools_DataMixin.Player.useColor or tab.color) then
        return
    end

    local Type= tab.type or (object.GetObjectType and object:GetObjectType()) or type(object)-- FontString Texture String

    local alpha= tab.alpha
    local col= tab.color or WoWTools_DataMixin.Player.useColor
    local isColorTexture= tab.isColorTexture

    local r,g,b,a= col.r, col.g, col.b, alpha or col.a or 1

    if Type=='FontString' or Type=='EditBox' then
        object:SetTextColor(r, g, b, a)

    elseif Type=='Texture' then
        if isColorTexture then
            object:SetColorTexture(r, g, b, a)
        else
            object:SetVertexColor(r, g, b, a)
        end

    elseif Type=='Button' then
        local icon= object:GetNormalTexture()
        if icon then
            icon:SetVertexColor(r, g, b, a)
        end
        icon= object:GetPushedTexture()
        if icon then
            icon:SetVertexColor(r, g, b, a)
        end
        icon= object:GetHighlightTexture()
        if icon then
            icon:SetVertexColor(r, g, b, a)
        end

    elseif Type=='String' then
        local hex= tab.color and tab.color.hex or WoWTools_DataMixin.Player.useColor.hex
        return hex..object
    end
end











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
		local h = ch * 6 local sextant = math.floor(h) -- figure out which sextant of the color wheel
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
















            RGB to HSV

            r, g, b = r or 1, g or 1, b or 1
            local maxVal = math.max(r, g, b)
            local minVal = math.min(r, g, b)
            local delta = maxVal - minVal

            local h, s, v = 0, 0, maxVal

            if delta > 0 then
                if maxVal == r then
                    h = (g - b) / delta % 6
                elseif maxVal == g then
                    h = (b - r) / delta + 2
                elseif maxVal == b then
                    h = (r - g) / delta + 4
                end
                h = h * 60
                if h < 0 then
                    h = h + 360
                end

                s = maxVal == 0 and 0 or delta / maxVal
            end

            return string.format("%i %i %i", math.floor(h + 0.5), math.floor(s * 100 + 0.5), math.floor(v * 100 + 0.5))
]]







