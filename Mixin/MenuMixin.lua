local e= select(2, ...)

WoWTools_MenuMixin={}

function WoWTools_MenuMixin:CreateSlider(root, tab)
    local sub=root:CreateTemplate("OptionsSliderTemplate")
    sub:SetTooltip(tab.tooltip)
    sub:SetData(tab)

    sub:AddInitializer(function(f, desc)--, description, menu)
        f.getValue=desc.data.getValue
        f.setValue=desc.data.setValue
        f.minValue=desc.data.minValue or 0
        f.maxValue=desc.data.maxValue or 100
        f.step=desc.data.step or 1
        f.bit=desc.data.bit

        local va= desc.data.getValue() or 1
        f:SetValueStep(f.step or 1)
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
            local value= s.getValue()
            if d== 1 then
                value= value- s.step
            elseif d==-1 then
                value= value+ s.step
            end
            value= value> s.maxValue and s.maxValue or value
            value= value< s.minValue and s.minValue or value
            s:SetValue(value)
        end)
        f:SetScript('OnHide', function(s)
            s.SetValue=nil
            s.minValue=nil
            s.maxValue=nil
            s.step=nil
            s.bit=nil
            f:SetScript('OnMouseWheel', nil)
            f:SetScript('OnValueChanged', nil)
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
        name=nil,
        minValue=0.4,
        maxValue=4,
        step=0.05,
        bit='%0.2f',
        tooltip=function(tooltip)
            tooltip:AddDoubleLine(e.onlyChinese and '缩放' or UI_SCALE)
        end
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


--重置数据
function WoWTools_MenuMixin:RestDataMenu(root, name, SetValue)
    return root:CreateButton('|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT), function(data)
        StaticPopup_Show('WoWTools_RestData',data.name, nil, data.SetValue)
        return MenuResponse.Open
    end, {name=name, SetValue=SetValue})
end

--重新加载UI
function WoWTools_MenuMixin:ReloadMenu(root, isControlKeyDown)
    local sub=root:CreateButton('|TInterface\\Vehicles\\UI-Vehicles-Button-Exit-Up:0|t'..(e.onlyChinese and '重新加载UI' or RELOADUI),
    function(data)
        if data and IsControlKeyDown() or not data then
            e.Reload()
        end
    end, isControlKeyDown)
    sub:SetTooltip(function(tooltip, desc)
        tooltip:AddDoubleLine(SLASH_RELOAD1, desc.data and '|cnGREEN_FONT_COLOR:Ctrl+|r'..e.Icon.left)
    end)
    return sub
end