local e= select(2, ...)
--[[
WoWToolsScaleMenuMixin:SetupFrame(self, delta, value, func)--设置Frame缩放

WoWToolsScaleMenuMixin:Setup(root, function()
    return Save.markersScale
end, function(value)
    Save.markersScale= value
end)
]]



--[[设置Frame缩放
function WoWToolsScaleMenuMixin:SetupFrame(self, delta, value, func)
    local n= value
    if self:CanChangeAttribute() and not UnitAffectingCombat('player') and IsAltKeyDown() then
        n= n or 1
        n= delta==1 and n-0.05 or n
        n= delta==-1 and n+0.05 or n
        n= n>4 and 4 or n
        n= n<0.4 and 0.4 or n
        self:SetScale(n)
        if func then
            func()
        end
        if self.set_scale then
            self:set_scale()
        end
        if self.set_tooltip then
            self:set_tooltip()
        end
    end
    return n
end]]


WoWToolsScaleMenuMixin={}

function WoWToolsScaleMenuMixin:SetupFrame(frame, delta, value, func)
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

function WoWToolsScaleMenuMixin:Setup(root, GetValue, SetValue, checkGetValue, checkSetValue)
    local sub, sub2
    if checkGetValue and checkSetValue then
        sub= root:CreateCheckbox(e.onlyChinese and '缩放' or UI_SCALE, checkGetValue, checkSetValue)
    else
        sub= root:CreateButton(e.onlyChinese and '缩放' or UI_SCALE, function()
            return MenuResponse.Open
        end)
    end

    sub2 = sub:CreateTemplate("OptionsSliderTemplate");

    sub2:AddInitializer(function(f, description, menu)
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
    end)

    return sub2, sub
end