--[[
RGBtoHEX(setR, setG, setB, setA, frame)--RGB转HEX

local classInfo = selection.data;
local classColor = GetClassColorObj(classInfo.classFile) or HIGHLIGHT_FONT_COLOR;
return classColor:WrapTextInColorCode(classInfo.className);
]]
local e= select(2, ...)
WoWTools_ColorMixin={}


local function set_Frame_Color(frame, setR, setG, setB, setA, setHex)
    if frame then
        local type= frame:GetObjectType()
        if type=='FontString' then
            frame:SetTextColor(setR, setG, setB,setA)
        elseif type=='Texture' then
            frame:SetColorTexture(setR, setG, setB,setA)
        end
        frame.r, frame.g, frame.b, frame.a, frame.hex= setR, setG, setB, setA, '|c'..setHex
    end
end


function WoWTools_ColorMixin:RGBtoHEX(setR, setG, setB, setA, frame)--RGB转HEX
    setA= setA or 1
	setR = setR <= 1 and setR >= 0 and setR or 0
	setG = setG <= 1 and setG >= 0 and setG or 0
	setB = setA <= 1 and setB >= 0 and setB or 0
	setA = setA <= 1 and setA >= 0 and setA or 0
    local hex=format("%02x%02x%02x%02x", setA*255, setR*255, setG*255, setB*255)
    set_Frame_Color(frame, setR, setG, setB, setA, hex)
	return hex
end


function WoWTools_ColorMixin:HEXtoRGB(hexColor, frame)--HEX转RGB -- ColorUtil.lua
	if hexColor then
		hexColor= hexColor:match('|c(.+)') or hexColor
        hexColor= hexColor:gsub('#', '')
		hexColor= hexColor:gsub(' ','')
        local len= #hexColor
		if len == 8 then
            local colorA= tonumber(hexColor:sub(1, 2), 16)
            local colorR= tonumber(hexColor:sub(3, 4), 16)
            local colorG= tonumber(hexColor:sub(5, 6), 16)
            local colorB= tonumber(hexColor:sub(7, 8), 16)
            if colorA and colorR and colorG and colorB then
                colorA, colorR, colorG, colorB= colorA/255, colorR/255, colorG/255, colorB/255
                set_Frame_Color(frame, colorR, colorG, colorB, colorA, hexColor)
                return colorR, colorG, colorB, colorA
            end
        elseif len==6 then
            local colorR= tonumber(hexColor:sub(1, 2), 16)
            local colorG= tonumber(hexColor:sub(3, 4), 16)
            local colorB= tonumber(hexColor:sub(5, 6), 16)
            if colorR and colorG and colorB then
                colorR, colorG, colorB= colorR/255, colorG/255, colorB/255
                hexColor= 'ff'..hexColor
                set_Frame_Color(frame, colorR, colorG, colorB, 1, hexColor)
                return colorR, colorG, colorB, 1
            end
		end
	end
end


function WoWTools_ColorMixin:Get_ColorFrameRGBA()--取得, ColorFrame, 颜色
    local r,g,b= ColorPickerFrame:GetColorRGB()
    local a= ColorPickerFrame.hasOpacity and ColorPickerFrame:GetColorAlpha()
    r= r and tonumber(format('%.2f', r)) or 1
    g= g and tonumber(format('%.2f', g)) or 1
    b= b and tonumber(format('%.2f', b)) or 1
    a= a and tonumber(format('%.2f', a)) or 1
	return r, g, b, a, {r=r, g=g, b=b, a=a}
end

function WoWTools_ColorMixin:ShowColorFrame(valueR, valueG, valueB, valueA, swatchFunc, cancelFunc)
    ColorPickerFrame:SetupColorPickerAndShow({--ColorPickerFrame.lua
        r=valueR or 1,
        g=valueG or 1,
        b=valueB or 1,
        hasOpacity=valueA and true or false,
        swatchFunc= swatchFunc or function()end,
        cancelFunc= cancelFunc or function()end,
        opacity=valueA or 1,
    })
end
--[[frame.swatchFunc = info.swatchFunc
frame.hasOpacity = info.hasOpacity
frame.opacityFunc = info.opacityFunc
frame.opacity = info.opacity
frame.previousValues = {r = info.r, g = info.g, b = info.b, a = info.opacity}
frame.cancelFunc = info.cancelFunc
frame.extraInfo = info.extraInfo]]
--[[else
    ColorPickerFrame:SetShown(false) -- Need to run the OnShow handler.
    valueR= valueR or 1
    valueG= valueG or 0.8
    valueB= valueB or 0
    valueA= valueA or 1
    --valueA= 1- valueA

    --ColorPickerFrame.previousValues = {valueR, valueG , valueB , valueA}
    ColorPickerFrame.func= func
    ColorPickerFrame.opacityFunc= func
    ColorPickerFrame.cancelFunc = cancelFunc or func
    if ColorPickerFrame.SetColorRGB then
        ColorPickerFrame:SetColorRGB(valueR, valueG, valueB)
    else
        ColorPickerFrame.Content.ColorPicker:SetColorRGB(valueR, valueG, valueB)
    end
    ColorPickerFrame.hasOpacity= true

    ColorPickerFrame.opacity = 1- valueA
    ColorPickerFrame:SetShown(true)
end]]















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