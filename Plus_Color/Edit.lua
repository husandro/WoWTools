
local EditBoxs={}
--SimpleColorSelectAPIDocumentation.lua








local function OnColorSelect(_, r, g, b)
    if WoWToolsSave['Plus_Color'].hide or not (r and g and b) then
        return
    end

    local a= ColorPickerFrame.hasOpacity and ColorPickerFrame.Content.ColorPicker:GetColorAlpha() or 1
    for _, frame in pairs(EditBoxs) do
        if frame:IsShown() then
            if not frame:HasFocus() then
                local text= frame.get_text(r, g, b, a)
                if text then
                    frame:SetText(text)
                end
            end
            frame.Instructions:SetTextColor(r,g,b)
        end
    end
end

local function Set_Color(r,g,b,a)
    if r and g and b then
        ColorPickerFrame.Content.ColorPicker:SetColorRGB(r, g, b)
        ColorPickerFrame.Content.ColorPicker:SetColorAlpha(a or 1)
    end
end

local function Get_RGBAtoText(text)
    text= text:gsub(',',' ')
    text= text:gsub('，',' ')
    text= text:gsub('  ',' ')
    if text=='' then
        return
    end

    local r, g, b, a

    if text:find('#') or text:find('|c') then
        r, g, b, a= WoWTools_ColorMixin:HEXtoRGB(text)
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
           r,g,b,a= r/255, g/255, b/255, a/255
           return r,g,b,a
        end
    end
end












local Tab={
    {
        name='RGBA',
        get_value= function(text)
            return Get_RGBAtoText(text)
        end,
        get_text= function(r,g,b,a)
            r= tonumber(format('%.2f', r))
            g= tonumber(format('%.2f', g))
            b= tonumber(format('%.2f', b))
            a= a and tonumber(format('%.2f', a)) or 1
            return r..' '..g..' '..b.. (a~=1 and ' '..a or '')
        end,
    },
    {
        name='HEX',--..(WoWTools_DataMixin.onlyChinese and '颜色码' or COLOR_PICKER_HEX),--..' AARRGGBB',
        get_value= function(text)
            return WoWTools_ColorMixin:HEXtoRGB(text)
        end,
        get_text= function(r,g,b,a)
            return WoWTools_ColorMixin:RGBtoHEX(r,g,b,a)
        end,
    },
    {
        name='RGB',
        get_value= function(text)
            local r,g,b= text:match('(%d+).-(%d+).-(%d+)')
            if r and g and b then
                local r2,g2,b2= tonumber(r), tonumber(g), tonumber(b)
                r2,g2,b2= math.min(r, 255), math.min(g, 255), math.min(b, 255)
                return r2/255, g2/255, b2/255
            end
        end,
        get_text= function(r,g,b)
            return format(
                '%i %i %i',
                r*255,
                g*255,
                b*255
            )
        end,
    },
    {
        name= 'HSV',
        get_value= function(text)
        local h, s, v = text:match('(%d+).-(%d+).-(%d+)')
            h= h and tonumber(h)
            s= s and tonumber(s)
            v= v and tonumber(v)
            if h and s and v then
                local frame= ColorPickerFrame.Content.ColorPicker
                frame:SetColorHSV(h, s/100, v/100)
                frame:SetColorAlpha(1)
                return frame:GetColorRGB()
            end
        end,
        get_text= function()
            local h,s,v= ColorPickerFrame.Content.ColorPicker:GetColorHSV()
            if h and s and v then
                return string.format("%i %i %i", h, s*100, v*100)
            end
        end,
    },
    {
        name= 'CODE',
        get_value= function(text)
            if text=='' then
                return
            end
            text=text:gsub(' ', '')
            text= text:match('|cn(.+)') or text
            text= text:gsub(HEADER_COLON, '')
            text= string.upper(text)
            local color= _G[text:gsub("_CODE", '')] or _G[text]

            local t= type(color)
            if t=='string' then
                return WoWTools_ColorMixin:HEXtoRGB(color)
            elseif t=='table' then
                return color.r, color.g, color.b, color.a
            end
        end,
        get_text= function(r,g,b,a)
            local r2,g2,b2,a2= format('%.2f',r), format('%.2f',g), format('%.2f',b), format('%.2f',a or 1)
            local r3,g3,b3,a3, r4,g4,b4,a4
            for _, info in pairs(C_UIColor.GetColors() or {}) do
                r4,g4,b4,a4= info.color.r, info.color.g, info.color.b, info.color.a or 1
                r3,g3,b3,a3= format('%.2f',r4), format('%.2f', g4), format('%.2f',b4), format('%.2f',a4)
                if
                    (r2==r3 or r4==r)
                    and (g2==g3 or g4==g)
                    and (b2==b3 or b4==b)
                    and (a2==a3 or a4==a4)
                then
                    return info.baseTag
                end
            end
            return ''
        end,
    }
}


-- |cnGREEN_FONT_COLOR:



--[[
if not r or not g or not b then
                return ''
            end

            local r2,g2,b2,a2= format('%.2f',r), format('%.2f',g), format('%.2f',b), format('%.2f',a or 1)
            local r3,g3,b3,a3, r4,g4,b4,a4
            for _, info in pairs(C_UIColor.GetColors() or {}) do
                r4,g4,b4,a4= info.color.r, info.color.g, info.color.b, info.color.a or 1
                r3,g3,b3,a3= format('%.2f',r4), format('%.2f', g4), format('%.2f',b4), format('%.2f',a4)
                if
                    (r2==r3 or r4==r)
                    and (g2==g3 or g4==g)
                    and (b2==b3 or b4==b)
                    and (a2==a3 or a4==a4)
                then
                    return info.baseTag
                end
            end
            return ''
]]







local function Create_EditBox(index, tab)
    local frame= CreateFrame("EditBox", nil, _G['WoWToolsColorPickerFrameButton'].frame, 'SearchBoxTemplate', index)--格式 RED_FONT_COLOR

    frame:SetPoint('TOPLEFT', ColorPickerFrame.Content, 'BOTTOMLEFT', 12, -(index-1)*22)
    frame:SetPoint('RIGHT', ColorPickerFrame.Content, -12, 0)
    frame:SetHeight(20)
    frame:SetAutoFocus(false)
    frame:ClearFocus()

    if tab.name=='CODE' then
        WoWTools_ColorMixin:Init_CODE(frame)
    end

    frame.get_value= tab.get_value
    frame.get_text= tab.get_text
    frame.name=tab.name

    frame.Instructions:SetText(tab.name or '')
    frame.Instructions:ClearAllPoints()
    frame.Instructions:SetPoint('RIGHT', frame.clearButton, 'LEFT')
    WoWTools_TextureMixin:SetSearchBox(frame, {alpha=0.6})
    frame.Instructions:SetAlpha(0.6)

    --[[frame.clearButton:SetAlpha(0.6)
    --frame.searchIcon:SetAlpha(0.6)
    --frame.searchIcon:SetAtlas('NPE_Icon')
    function frame:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        local r,g,b,a= self.get_value(self:GetText())
        GameTooltip:AddLine(self.name, r,g,b)

        if r and g and b then
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine(Tab[1].get_text(r, g, b, a))
            GameTooltip:AddLine(Tab[2].get_text(r, g, b, a))
            GameTooltip:AddLine(Tab[3].get_text(r, g, b, a))
        end
        GameTooltip:Show()
    end]]

    function frame:set_bg_alpha(alpha)
        frame.Middle:SetAlpha(alpha)
        frame.Left:SetAlpha(alpha)
        frame.Right:SetAlpha(alpha)
    end


--OnEnterPressed
    frame:SetScript('OnEnterPressed', function(self)
        self:ClearFocus()
        ColorPickerFrame.Content.ColorPicker:SetColorRGB(ColorPickerFrame:GetColorRGB())
    end)

--OnTextChanged
    frame:SetScript('OnTextChanged', function(self, userInput)
        if userInput and self:HasFocus() then
            Set_Color(self.get_value(self:GetText()))
        end
        self.clearButton:SetShown(self:HasText())
        --[[if GameTooltip:IsOwned(self) then
            self:set_tooltip()
        end]]
    end)
    function frame:Setup()
        Set_Color(self.get_value(self:GetText()))
        self.clearButton:SetShown(self:HasText())
    end


--OnEscapePressed
    frame:SetScript('OnEscapePressed', frame.ClearFocus)
    frame:SetScript('OnTabPressed', function(self)
        local value= self:GetID()+1
        if value>#EditBoxs then
            value=1
        end
        EditBoxs[value]:SetFocus()
    end)

--OnEditFocusGained
    frame:SetScript('OnEditFocusGained', function(self)
        self:HighlightText()
	    self:set_bg_alpha(1)
        self.Instructions:SetShown(false)
    end)

--OnEditFocusLost
    frame:SetScript('OnEditFocusLost', function(self)
        self:ClearHighlightText()
        self:set_bg_alpha(0.6)
        self.Instructions:SetShown(true)
    end)

--OnHide
    frame:SetScript('OnHide', function(self)
        self:SetText('')
        self:ClearFocus()
    end)

    --[[frame:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
    end)
    frame:SetScript('OnEnter', function(self)
        self:set_tooltip()
    end)]]

   --[[rame.icon= frame:CreateTexture()
    frame.icon:SetPoint('LEFT', frame, 'RIGHT')
    frame.icon:SetAtlas('NPE_Icon')
    frame.icon:SetSize(20,20)]]
    
    --[[if tab.name=='HSV' then
        function frame:set_tooltip()
        end
    end]]

    table.insert(EditBoxs, frame)
end






















local function Init()
    for index, tab in pairs(Tab) do
        Create_EditBox(index, tab)
    end

    ColorPickerFrame.Content.ColorPicker:HookScript("OnColorSelect", OnColorSelect)
    OnColorSelect(nil, ColorPickerFrame:GetColorRGB())
end



function WoWTools_ColorMixin:Init_EditBox()
    Init()
end
