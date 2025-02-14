local e= select(2, ...)

WoWTools_ColorMixin={
    Save= {
        --disabled=true,
        --hide=true,
        --autoShow=true,--自动显示
        --sacle=1,

        logColor={},--保存，历史记录
        --logMaxColor=30,--设置，最多保存30个颜色
        --selectType2=true,--更多颜色

        saveColor={},--保存4个颜色
    }
}





local function set_Frame_Color(frame, r, g, b, setA, hex)
    if frame then
        local type= frame:GetObjectType()
        if type=='FontString' then
            frame:SetTextColor(r, g, b,setA)
        elseif type=='Texture' then
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






--HEX转RGB -- ColorUtil.lua
function WoWTools_ColorMixin:HEXtoRGB(text, frame)
	if not text or text=='' then
        return
    end
    text= text:gsub(' ','')
    text= text:match('|c(.+)') or text
    text= text:gsub('#', '')
    local len= #text
    local r,g,b,a
    if len>8 then
        text=string.sub(text,1,8)
    end
    if len == 8 then
        r,g,b, a= ExtractColorValueFromHex(text, 3), ExtractColorValueFromHex(text, 5), ExtractColorValueFromHex(text, 7), ExtractColorValueFromHex(text, 1)
    elseif len==6 then
        r,g,b,a= ExtractColorValueFromHex(text, 1), ExtractColorValueFromHex(text, 3), ExtractColorValueFromHex(text, 5), 1
    end
    if r and g and b then
        set_Frame_Color(frame, r, g, b, a or 1, 'ff'..text)
        return a,r,g, a or 1
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
function WoWTools_ColorMixin:SetLabelTexture(frame, tab)--设置颜色
    if frame and (e.Player.useColor or tab.color) then
        local type= tab.type or type(frame)-- FontString Texture String
        local alpha= tab.alpha
        local col= tab.color or e.Player.useColor

        local r,g,b,a= col.r, col.g, col.b, alpha or col.a or 1
        if type=='FontString' or type=='EditBox' then
            frame:SetTextColor(r, g, b, a)

        elseif type=='Texture' then
            frame:SetVertexColor(r, g, b, a)
        elseif type=='Button' then
            local texture= frame:GetNormalTexture()
            if texture then
                texture:SetVertexColor(r, g, b, a)
            end
            texture= frame:GetPushedTexture()
            if texture then
                texture:SetVertexColor(r, g, b, a)
            end
            texture= frame:GetHighlightTexture()
            if texture then
                texture:SetVertexColor(r, g, b, a)
            end

        elseif type=='String' then
            local hex= tab.color and tab.color.hex or e.Player.useColor.hex
            return hex..frame
        end
    elseif type=='String' then
        return frame
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
]]







