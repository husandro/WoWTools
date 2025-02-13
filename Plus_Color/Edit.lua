local e= select(2, ...)





local function Set_Edit_Text(r, g, b, a, textCode)
	if ColorPickerFrame.Content then
		ColorPickerFrame.Content.ColorPicker:SetColorRGB(r, g, b)
		ColorPickerFrame.Content.ColorPicker:SetColorAlpha(a or 1)
	else
		OpacitySliderFrame:SetValue(a and 1-a or 0)
		ColorPickerFrame:SetColorRGB(r, g, b)
	end
	Frame.cn:SetText(textCode and textCode..'_CODE' or '')
	Frame.cn2:SetText(textCode and '|cn'..textCode or '')
end










local function Init()

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
end




function WoWTools_ColorMixin:Init_EditBox()
    Init()
end



function WoWTools_ColorMixin:Set_Edit_Text(...)
	Set_Edit_Text(...)
end