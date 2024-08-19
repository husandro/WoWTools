local e= select(2, ...)

WoWTools_MenuMixin={}

function WoWTools_MenuMixin:CreateSlider(root, tab)
    local sub=root:CreateTemplate("OptionsSliderTemplate")    
    sub:SetTooltip(tab.tooltip)
    tab.tooltip=nil
    sub:SetData(tab)

    sub:AddInitializer(function(f, desc)--, description, menu)
        f.setValue=desc.data.setValue or 1
        f.minValue=desc.data.minValue or 0
        f.maxValue=desc.data.maxValue or 100
        f.step=desc.data.step or 1
        f.bit=desc.data.bit

        local va= desc.data.getValue() or 1
        f:SetValueStep(f.step)
        f:SetMinMaxValues(f.minValue, f.maxValue)
        f:SetValue(va)

        f.Text:ClearAllPoints()
        f.Text:SetPoint('TOPRIGHT', 0,6)
        f.Text:SetText(va or 1)

        f.High:SetText(desc.data.name or '')
        f.Low:SetText('')

        f:SetScript('OnValueChanged', function(s, value)
            if s.bit then
                value= tonumber(format(s.bit, value))
            else
                value= math.ceil(value)
            end
            s.setValue(value)
            s.Text:SetText(value)
        end)

        f:EnableMouseWheel(true)
        f:SetScript('OnMouseWheel', function(s, d)
            local value= s:GetValue()
            if d== 1 then
                value= value- s.step
            elseif d==-1 then
                value= value+ s.step
            end
            value= value> s.maxValue and s.maxValue or value
            value= value< s.minValue and s.minValue or value
            s:setValue(value)
        end)
        f:SetScript('OnHide', function(s)
            s.SetValue=nil
            s.minValue=nil
            s.maxValue=nil
            s.step=nil
            s.bit=nil
            f:SetScript('OnMouseWheel', nil)
            f:SetScript('OnValueChanged', nil)
            --f:SetScript('OnHide', nil)
        end)

    end)

    return sub
end


--缩放，Frame
function WoWTools_MenuMixin:ScaleFrame(frame, delta, value, func)
    local n= value
    if frame:CanChangeAttribute() and not UnitAffectingCombat('player') and IsAltKeyDown() then
        n= n or 1
        n= delta==1 and n-0.05 or n
        n= delta==-1 and n+0.05 or n
        n= n>4 and 4 or n
        n= n<0.4 and 0.4 or n
        frame:SetScale(n)
        if func then
            func()
        end
        if frame.set_scale then
            frame:set_scale()
        end
        if frame.set_tooltip then
            frame:set_tooltip()
        end
    end
    return n
end


--缩放
function WoWTools_MenuMixin:ScaleMenu(root, GetValue, SetValue, checkGetValue, checkSetValue)
    local sub
    if checkGetValue and checkSetValue then
        sub= root:CreateCheckbox(e.onlyChinese and '缩放' or UI_SCALE, checkGetValue, checkSetValue)
    else
        sub= root:CreateButton(e.onlyChinese and '缩放' or UI_SCALE, function()
            return MenuResponse.Open
        end)
    end

    local sub2=self:CreateSlider(sub, {
        getValue=GetValue,
        setValue=SetValue,
        name=e.onlyChinese and '缩放' or UI_SCALE,
        minValue=0.4,
        maxValue=4,
        step=0.01,
        bit='%0.2f',
        tooltip=nil
    })

    return sub2, sub
end
    --[[sub2 = sub:CreateTemplate("OptionsSliderTemplate");

    sub2:AddInitializer(function(f)--, description, menu)
        f.func= SetValue

        local va= GetValue()
        f:SetValueStep(0.01)
        f:SetMinMaxValues(0.4, 4)
        f:SetValue(va or 1)

        f.Text:ClearAllPoints()
        f.Text:SetPoint('TOPRIGHT',0,6)
        f.Text:SetText(va or 1)

        f.High:SetText(e.onlyChinese and '缩放' or UI_SCALE)
        f.Low:SetText('')

        f:SetScript('OnValueChanged', function(frame, value)
            value= tonumber(format('%0.2f', value))
            frame.func(value)
            frame.Text:SetText(value)
        end)

        f:EnableMouseWheel(true)
        f:SetScript('OnMouseWheel', function(s, d)
            local value= s:GetValue()
            if d== 1 then
                value= value- 0.01
            elseif d==-1 then
                value= value+ 0.01
            end
            value= value> 4 and 4 or value
            value= value< 0.4 and 0.4 or value
            s:SetValue(value)
        end)
    end)]]


--FrameStrata
function WoWTools_MenuMixin:StrataMenu(root, GetValue, SetValue)
    local sub=root:CreateButton('FrameStrata', function() return MenuResponse.Open end)

    for _, strata in pairs({'BACKGROUND','LOW','MEDIUM','HIGH','DIALOG','FULLSCREEN','FULLSCREEN_DIALOG'}) do
        sub:CreateCheckbox((strata=='HIGH' and '|cnGREEN_FONT_COLOR:' or '')..strata, GetValue, SetValue, strata)
    end
    return sub
end

--重置位置
function WoWTools_MenuMixin:RestPointMenu(root, point, SetValue)
    return root:CreateButton((point and '' or '|cff9e9e9e')..(e.onlyChinese and '重置位置' or RESET_POSITION), SetValue)
end


