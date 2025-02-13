local e= select(2, ...)



--[[

local function Set_Edit_Text(r, g, b, a, textCode)
	if ColorPickerFrame.Content then
		ColorPickerFrame.Content.ColorPicker:SetColorRGB(r, g, b)
		ColorPickerFrame.Content.ColorPicker:SetColorAlpha(a or 1)
	else
		OpacitySliderFrame:SetValue(a and 1-a or 0)
		ColorPickerFrame:SetColorRGB(r, g, b)
	end
	WoWTools_ColorMixin.Frame.cn:SetText(textCode and textCode..'_CODE' or '')
	WoWTools_ColorMixin.Frame.cn2:SetText(textCode and '|cn'..textCode or '')
end










local function Init_1()
    local Frame= _G['WoWToolsColorPickerFrameButton'].frame

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

    Frame.rgb= CreateFrame("EditBox", nil, Frame, 'SearchBoxTemplate')-- 1 1 1 1
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
                return r/255, g/255, b/255, a/255
            end
        end
    end
    Frame.rgb:SetScript('OnEnterPressed', function(self)
        local r, g, b, a= self:get_RGB()
        if r and g and b then
            Set_Edit_Text(r, g, b, (a or 1), nil)
            self:ClearFocus()
        end
    end)
    Frame.rgb:SetScript('OnHide', function(self)
        self:SetText('')
        self:ClearFocus()
    end)

    Frame.rgb.lable=WoWTools_LabelMixin:Create(Frame.rgb, {size=10})--10)--提示，修改，颜色
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
        e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_ColorMixin.addName)
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
                    Set_Edit_Text(r, g, b, a, nil)
                elseif maxValue<=255 then
                    a= a==1 and 255 or a
                    Set_Edit_Text(r/255, g/255, b/255, a/255, nil)
                end
                self:ClearFocus()
        end
    end)
    Frame.rgb2.lable=WoWTools_LabelMixin:Create(Frame.rgb2, {size=10})--10)--提示，修改，颜色
    Frame.rgb2.lable:SetPoint('RIGHT', Frame.rgb2,-2,0)
    Frame.rgb2:SetScript('OnHide', function(self)
        self:SetText('')
        self:ClearFocus()
    end)
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
        e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_ColorMixin.addName)
        e.tips:Show()
        self:SetAlpha(0.3)
    end)


    Frame.hex= CreateFrame("EditBox", nil, Frame, 'InputBoxTemplate')--|cff808080
    Frame.hex:SetPoint("TOPLEFT", Frame.rgb2, 'BOTTOMLEFT',0,-2)
    Frame.hex:SetSize(w,20)
    Frame.hex:SetAutoFocus(false)
    Frame.hex:ClearFocus()
    function Frame.hex:get_RGB()
        return WoWTools_ColorMixin:HEXtoRGB(self:GetText())
    end
    Frame.hex:SetScript('OnEnterPressed', function(self)
        local r, g, b, a= self:get_RGB()
        if r and g and b then
            Set_Edit_Text(r, g, b, a, nil)
            self:ClearFocus()
        end
    end)
    Frame.hex:SetScript('OnHide', function(self)
        self:SetText('')
        self:ClearFocus()
    end)

    local hexText=WoWTools_LabelMixin:Create(Frame)--提示
    hexText:SetPoint('RIGHT', Frame.hex, 'LEFT',-2,0)
    hexText:SetText('|c')

    Frame.hex.lable=WoWTools_LabelMixin:Create(Frame.hex, {size=10})--10)--提示，修改，颜色
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
        e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_ColorMixin.addName)
        e.tips:Show()
        self:SetAlpha(0.3)
    end)

    Frame.cn= CreateFrame("EditBox", nil, Frame, 'InputBoxTemplate')--格式 RED_FONT_COLOR
    Frame.cn:SetPoint("TOPLEFT", Frame.hex, 'BOTTOMLEFT',0,-2)
    Frame.cn:SetSize(w,20)
    Frame.cn:SetAutoFocus(false)
    Frame.cn:ClearFocus()
    Frame.cn:SetScript('OnHide', function(self)
        self:SetText('')
        self:ClearFocus()
    end)

    Frame.cn2= CreateFrame("EditBox", nil, Frame, 'InputBoxTemplate')--格式 '|cnGREEN_FONT_COLOR:'
    Frame.cn2:SetPoint("TOPLEFT", Frame.cn, 'BOTTOMLEFT',0,-2)
    Frame.cn2:SetSize(w,20)
    Frame.cn2:SetAutoFocus(false)
    Frame.cn2:ClearFocus()
    Frame.cn2:SetScript('OnHide', function(self)
        self:SetText('')
        self:ClearFocus()
    end)

    local cnText2=WoWTools_LabelMixin:Create(Frame)--提示
    cnText2:SetPoint('LEFT', Frame.cn2, 'RIGHT', 2,0)
    cnText2:SetText(':')
end]]




local EditBoxs={}
local function OnColorSelect(_, r, g, b)
    if WoWTools_ColorMixin.Save.hide or not (r and g and b) then
        return
    end

    local a= ColorPickerFrame.hasOpacity and ColorPickerFrame.Content.ColorPicker:GetColorAlpha() or 1
    for _, frame in pairs(EditBoxs) do

        if not frame:HasFocus() then
            local text= frame.set_text(r, g, b, a)
            if text then
                frame:SetText(text)
            end
        end
        frame.Instructions:SetTextColor(r,g,b)
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





local function Get_RGB255toText(text)
    local r,g,b= text:match('(%d+).-(%d+).-(%d+)')
    if r and g and b then
        local r2,g2,b2= tonumber(r), tonumber(g), tonumber(b)
        r2,g2,b2= math.min(r, 255), math.min(g, 255), math.min(b, 255)
        Set_Color(r2/255, g2/255, b2/255)
    end
end















local function Create_EditBox(index, tab)
    local frame= CreateFrame("EditBox", nil, _G['WoWToolsColorPickerFrameButton'].frame, 'SearchBoxTemplate', index)--格式 RED_FONT_COLOR

    frame:SetPoint('TOPLEFT', ColorPickerFrame.Content, 'BOTTOMLEFT', 12, -(index-1)*22)
    frame:SetPoint('RIGHT', ColorPickerFrame.Content, -26, 0)
    frame:SetHeight(20)
    frame:SetAutoFocus(false)
    frame:ClearFocus()

    frame.set_value= tab.set_value
    frame.set_text= tab.set_text
    frame.set_tooltip= tab.set_tooltip
    frame.name=tab.name

    frame.Instructions:SetText(tab.name or '')
    frame.Instructions:ClearAllPoints()
    frame.Instructions:SetPoint('RIGHT', frame.clearButton, 'LEFT')
    WoWTools_PlusTextureMixin:SetSearchBox(frame)
    --frame.searchIcon:SetAtlas('NPE_Icon')

    frame:HookScript('OnEnterPressed', function(self)
        self:ClearFocus()
        ColorPickerFrame.Content.ColorPicker:SetColorRGB(ColorPickerFrame:GetColorRGB())
    end)

    frame:SetScript('OnTextChanged', function(self, userInput)
        if userInput and self:HasFocus() then
            self.set_value(self:GetText())
        end
        --[[
        self.Instructions:SetShown(hasText)
        self.Instructions2:SetShown(not hasText)]]
        local hasText= self:HasText()
        self.clearButton:SetShown(hasText)
        --self.Instructions:SetShown(hasText)
    end)

    frame:HookScript('OnEscapePressed', frame.ClearFocus)
    frame:HookScript('OnTabPressed', function(self)
        local value= self:GetID()+1
        if value>#EditBoxs then
            value=1
        end
        EditBoxs[value]:SetFocus()
    end)

    frame:HookScript('OnEditFocusGained', function(self)
    end)

    frame:HookScript('OnHide', function(self)
        self:SetText('')
        self:ClearFocus()
    end)

    frame:HookScript('OnLeave', function()
        e.tips:Hide()
    end)
    frame:HookScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(self.name)
        e.tips:Show()
    end)

   --[[rame.icon= frame:CreateTexture()
    frame.icon:SetPoint('LEFT', frame, 'RIGHT')
    frame.icon:SetAtlas('NPE_Icon')
    frame.icon:SetSize(20,20)]]

    table.insert(EditBoxs, frame)
end






















local function Init()
    local Tab={
        {
            name='R G B A',
            set_value= function(text)
                Set_Color(Get_RGBAtoText(text))
            end,
            set_text= function(r,g,b,a)
                r= tonumber(format('%.2f', r))
                g= tonumber(format('%.2f', g))
                b= tonumber(format('%.2f', b))
                a= a and tonumber(format('%.2f', a)) or 1
                return r..' '..g..' '..b.. (a~=1 and ' '..a or '')
            end,
        },
        {
            name='HEX',
            set_value= function(text)
                Set_Color(WoWTools_ColorMixin:HEXtoRGB(text))
            end,
            set_text= function(r,g,b,a)
                return WoWTools_ColorMixin:RGBtoHEX(r,g,b,a)
            end,
        },
        {
            name='R G B',
            set_value= Get_RGB255toText,
            set_text= function(r,g,b)
                return format(
                    '%i %i %i',
                    r*255,
                    g*255,
                    b*255
                )
            end,
        },
    }

    for index, tab in pairs(Tab) do
        Create_EditBox(index, tab)
    end

    ColorPickerFrame.Content.ColorPicker:HookScript("OnColorSelect", OnColorSelect)
    OnColorSelect(nil, ColorPickerFrame:GetColorRGB())
end



function WoWTools_ColorMixin:Init_EditBox()
    Init()
end



--[[function WoWTools_ColorMixin:Set_Edit_Text(...)
	Set_Edit_Text(...)
end]]