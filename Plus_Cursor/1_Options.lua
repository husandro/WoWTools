local e= select(2, ...)
local function Save()
    return WoWTools_CursorMixin.Save
end








local function Init(Frame)

    if (Save().disabled and Save().disabledGCD) or Frame.Texture then
        return
    end
    --设置, 大图片
    Frame.Texture= Frame:CreateTexture()--大图片
    Frame.Texture:SetPoint('TOPRIGHT', Frame, 'TOP', -20, 10)
    Frame.Texture:SetSize(80,80)

    local useClassColorCheck= CreateFrame("CheckButton", nil, Frame, "InterfaceOptionsCheckButtonTemplate")--职业颜色
    local colorText= WoWTools_LabelMixin:Create(Frame, {color={r=Save().color.r, g=Save().color.g, b=Save().color.b, a=Save().color.a}})--nil, nil, nil, {Save().color.r, Save().color.g, Save().color.b, Save().color.a})--自定义,颜色
    local notUseColorCheck= CreateFrame("CheckButton", nil, Frame, "InterfaceOptionsCheckButtonTemplate")--不使用，颜色

    --职业颜色
    useClassColorCheck:SetPoint("BOTTOMLEFT")
    useClassColorCheck.text:SetText(e.onlyChinese and '职业颜色' or CLASS_COLORS)
    useClassColorCheck.text:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
    useClassColorCheck:SetChecked(Save().usrClassColor)
    useClassColorCheck:SetScript('OnMouseDown', function()
        Save().usrClassColor= not Save().usrClassColor and true or nil
        Save().notUseColor=nil
        notUseColorCheck:SetChecked(false)
        WoWTools_CursorMixin:Set_Color()
        if WoWTools_CursorMixin.CursorFrame then
            WoWTools_CursorMixin:Cursor_Settings()--初始，设置
        end
    end)

    --自定义,颜色
    colorText:SetPoint('LEFT', useClassColorCheck.text, 'RIGHT', 4,0)
    colorText:SetText('|A:colorblind-colorwheel:0:0|a'..(e.onlyChinese and '自定义 ' or CUSTOM))
    colorText:EnableMouse(true)
    colorText.r, colorText.g, colorText.b, colorText.a= Save().color.r, Save().color.g, Save().color.b, Save().color.a
    colorText:SetScript('OnMouseDown', function(self)
        local usrClassColor= Save().usrClassColor
        local notUseColor= Save().notUseColor
        Save().usrClassColor=nil
        Save().notUseColor=nil
        useClassColorCheck:SetChecked(false)
        notUseColorCheck:SetChecked(false)

        local valueR, valueG, valueB, valueA= self.r, self.g, self.b, self.a
        local setA, setR, setG, setB
        local function func()
            Save().color= {r=setR, g=setG, b=setB, a=setA}
            self:SetTextColor(setR, setG, setB, setA)
            WoWTools_CursorMixin:Set_Color()
            if WoWTools_CursorMixin.CursorFrame then
                WoWTools_CursorMixin:Cursor_Settings()--初始，设置
            end
        end
        WoWTools_ColorMixin:ShowColorFrame(self.r, self.g, self.b,self.a, function()
                setR, setG, setB, setA= WoWTools_ColorMixin:Get_ColorFrameRGBA()
                func()
            end, function()
                setR, setG, setB, setA= valueR, valueG, valueB, valueA
                if usrClassColor then
                    Save().usrClassColor=true
                    useClassColorCheck:SetChecked(true)
                elseif notUseColor then
                    Save().notUseColor=true
                    notUseColorCheck:SetChecked(true)
                end
                func()
            end
        )
    end)
    colorText:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '设置' or SETTINGS, (e.onlyChinese and '颜色' or COLOR)..e.Icon.left)
        e.tips:Show()
    end)
    colorText:SetScript('OnLeave', GameTooltip_Hide)

    --不使用，颜色
    notUseColorCheck:SetPoint("LEFT", colorText, 'RIGHT')
    notUseColorCheck.text:SetText(e.onlyChinese and '无' or NONE)
    notUseColorCheck:SetChecked(Save().notUseColor)
    notUseColorCheck:SetScript('OnMouseDown', function()
        Save().notUseColor= not Save().notUseColor and true or nil
        Save().useClassColorCheck=nil
        useClassColorCheck:SetChecked(false)
        print(e.addName, WoWTools_CursorMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

    --随机, 图片
    Frame.randomTextureCheck= CreateFrame("CheckButton", nil, Frame, "InterfaceOptionsCheckButtonTemplate")
    Frame.randomTextureCheck:SetPoint("LEFT", notUseColorCheck.text, 'RIGHT', 10,0)
    Frame.randomTextureCheck.text:SetText('|TInterface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47:0|t'..(e.onlyChinese and '随机图标' or 'Random '..EMBLEM_SYMBOL))
    Frame.randomTextureCheck:SetChecked(Save().randomTexture)
    Frame.randomTextureCheck:SetScript('OnMouseDown', function()
        Save().randomTexture= not Save().randomTexture and true or nil
        if WoWTools_CursorMixin.CursorFrame then
            WoWTools_CursorMixin:Cursor_Settings()--初始，设置
            WoWTools_CursorMixin:Cursor_SetEvent()--随机, 事件
        end
    end)
    Frame.randomTextureCheck:SetScript('OnLeave', GameTooltip_Hide)
    Frame.randomTextureCheck:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddLine(e.onlyChinese and '事件' or EVENTS_LABEL)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine('Cursor', (e.onlyChinese and '战斗中: 移动' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT..': '..NPE_MOVE))
        e.tips:AddDoubleLine(' ', (e.onlyChinese and '其它' or OTHER)..e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine('GCD', e.GetEnabeleDisable(true))
        e.tips:Show()
    end)
end










function WoWTools_CursorMixin:Init_Options()
    Init(self.OptionsFrame)
end