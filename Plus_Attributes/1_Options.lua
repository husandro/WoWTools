local e= select(2, ...)

local function Save()
    return WoWTools_AttributesMixin.Save
end



--##########
--设置 panel
--##########
local function Init()--设置 panel
    if Save().disabled then
        return
    end


    local last, check, findTank, findDps
    local panel= WoWTools_AttributesMixin.PanelFrame
    local button= _G['WoWTools_AttributesButton']
    local Tabs= WoWTools_AttributesMixin:Get_Tabs()

    for index, info in pairs(Tabs) do
        if info.dps and not findDps then
            check=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--四属性, 仅限DPS
            check:SetChecked(Save().onlyDPS)
            check:SetPoint('TOPLEFT', last, 'BOTTOMLEFT',0, -16)
            if e.onlyChinese then
                check.text:SetText("仅限"..INLINE_DAMAGER_ICON..INLINE_HEALER_ICON)
            else
                check.text:SetFormattedText(LFG_LIST_CROSS_FACTION , INLINE_DAMAGER_ICON..INLINE_HEALER_ICON)
            end
            check:SetScript('OnMouseUp',function(self)
                Save().onlyDPS = not Save().onlyDPS and true or false
                WoWTools_AttributesMixin:Frame_Init(true)--初始，设置
            end)
            findDps=true
            last=check

        elseif info.tank and not findTank then
            local text= WoWTools_LabelMixin:Create(panel)
            text:SetPoint('TOPLEFT', last, 'BOTTOMLEFT',0, -16)
            if e.onlyChinese then
                text:SetText("仅限"..INLINE_TANK_ICON)
            else
                text:SetFormattedText(LFG_LIST_CROSS_FACTION , INLINE_TANK_ICON)
            end
            findTank=true
            last= text
        end

        check= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--禁用, 启用
        check:SetChecked(not Save().tab[info.name].hide)
        if info.name=='STATUS' or info.name=='SPEED' or info.name=='LIFESTEAL' then
            if last then
                check:SetPoint('TOPLEFT', last, 'BOTTOMLEFT',0, -16)
            else
                check:SetPoint('TOPLEFT', 0, -32)
            end
        else
            check:SetPoint('TOPLEFT', last, 'BOTTOMLEFT',0, 6)
        end
        check.name= info.name
        check.text2= info.text
        check.zeroShow= info.zeroShow

        check:SetScript('OnMouseUp',function(self)
            Save().tab[self.name].hide= not Save().tab[self.name].hide and true or nil
            WoWTools_AttributesMixin:Frame_Init(true)--初始，设置
        end)
        check:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            local value= button[self.name] and button[self.name].value
            e.tips:AddDoubleLine(self.text2, format('%.2f%%', value or 0))
            if not info.zeroShow then
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(e.GetShowHide(not Save().tab[self.name].hide), (e.onlyChinese and '值' or 'value: ')..' < 1 ='..(e.onlyChinese and '隐藏' or HIDE))
            end
            e.tips:Show()
        end)
        check:SetScript('OnLeave', GameTooltip_Hide)

        local text= WoWTools_LabelMixin:Create(check, {color={r=info.r or 1, g=info.g or 0.82, b=info.b or 0, a=info.a or 1}})--nil, nil, nil, {r,g,b,a})--Text
        text:SetPoint('LEFT', check, 'RIGHT')
        text:SetText(info.text)
        if index>1 then
            text:EnableMouse(true)
            text.name= info.name
            text.text= info.text
            text:SetScript('OnMouseDown', function(self)
                local R,G,B,A= Save().tab[self.name].r, Save().tab[self.name].g, Save().tab[self.name].r, Save().tab[self.name].a or 1-- self.r, self.g, self.b, self.a
                local setA, setR, setG, setB
                local function func()
                    Save().tab[self.name].r= setR
                    Save().tab[self.name].g= setG
                    Save().tab[self.name].b= setB
                    Save().tab[self.name].a= setA
                    self:SetTextColor(setR, setG, setB, setA)
                    if button and button[self.name] then
                        if button[self.name].label then
                            button[self.name].label:SetTextColor(setR, setG, setB, setA)
                        end
                        if button[self.name].bar then
                            button[self.name].bar:SetStatusBarColor(setR,setG,setB,setA)
                        end
                    end
                end
                WoWTools_ColorMixin:ShowColorFrame(R,G,B,A, function()
                        setR, setG, setB, setA = WoWTools_ColorMixin:Get_ColorFrameRGBA()
                        func()
                    end,function()
                         setR, setG, setB, setA= R,G,B,A
                        func()
                    end
                )
            end)
            text:SetScript('OnEnter', function(self)
                local r2= Save().tab[self.name].r or 1
                local g2= Save().tab[self.name].g or 0.82
                local b2= Save().tab[self.name].b or 0
                local a2= Save().tab[self.name].a or 1
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(self.text, self.name, r2, g2, b2)
                e.tips:AddDoubleLine(e.onlyChinese and '设置' or SETTINGS, (e.onlyChinese and '颜色' or COLOR)..e.Icon.left)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(format('r%.2f', r2)..format('  g%.2f', g2)..format('  b%.2f', b2), format('a%.2f', a2))
                e.tips:Show()
                self:SetAlpha(0.3)
            end)
            text:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
        end

        if info.name=='STATUS' then--主属性, 使用bar
            local current= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
            current:SetChecked(Save().tab[info.name].bar)
            current:SetPoint('LEFT', text, 'RIGHT',2,0)
            current.text:SetText(e.Player.col..'Bar')
            current:SetScript('OnMouseUp',function(self)
                Save().tab['STATUS'].bar= not Save().tab['STATUS'].bar and true or false
                WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置
            end)
            current:SetScript('OnEnter', function(self)
                WoWTools_AttributesMixin:Set_Tooltips(self, nil)
                self:SetAlpha(0.3)
            end)
            current:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
            current.name= info.name

            --位数，bit
            local sliderBit=e.CSlider(panel, {w=100,h=20, min=0, max=3, value=Save().tab['STATUS'].bit or 3, setp=1, color=nil,
                text= e.Player.col..(e.onlyChinese and '位数' or 'bit'),
                func=function(self, value)
                    value= math.floor(value)
                    self:SetValue(value)
                    self.Text:SetText(value)
                    Save().tab['STATUS'].bit= value==0 and 0 or value
                    WoWTools_AttributesMixin:Frame_Init(true)--初始，设置
                end,
                tips=nil
            })
            sliderBit:SetPoint("LEFT", current.text, 'RIGHT', 6,0)
            sliderBit:SetSize(100,20)


        elseif info.name=='SPEED' then--速度, 当前速度, 选项
            --驭空术UI，速度
            local dragonriding= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
            dragonriding:SetChecked(not Save().disabledDragonridingSpeed)
            dragonriding:SetPoint('LEFT', text, 'RIGHT',2,0)
            dragonriding.text:SetFormattedText('|A:dragonriding_vigor_decor:0:0|a%s', e.onlyChinese and '驭空术' or GENERIC_TRAIT_FRAME_DRAGONRIDING_TITLE)
            dragonriding:SetScript('OnClick',function()
                Save().disabledDragonridingSpeed= not Save().disabledDragonridingSpeed and true or nil
                print(e.addName, WoWTools_AttributesMixin.addName, e.GetEnabeleDisable(not Save().disabledDragonridingSpeed), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
            end)

            --载具，速度
            local vehicleSpeedCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
            vehicleSpeedCheck:SetChecked(not Save().disabledVehicleSpeed)
            vehicleSpeedCheck:SetPoint('LEFT', dragonriding.text, 'RIGHT',2,0)
            vehicleSpeedCheck.text:SetFormattedText(e.onlyChinese and '%s载具' or UNITNAME_SUMMON_TITLE9, '|TInterface\\Vehicles\\UI-Vehicles-Button-Exit-Up:0|t')
            vehicleSpeedCheck:SetScript('OnClick',function()
                Save().disabledVehicleSpeed= not Save().disabledVehicleSpeed and true or nil
                print(e.addName, WoWTools_AttributesMixin.addName, e.GetEnabeleDisable(not Save().disabledVehicleSpeed), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
            end)


        elseif info.name=='VERSATILITY' then--全能5
            local check2=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--仅防卫
            check2:SetChecked(Save().tab['VERSATILITY'].onlyDefense)
            check2:SetPoint('LEFT', text, 'RIGHT',2,0)
            check2.text:SetText((e.onlyChinese and '仅防御' or format(LFG_LIST_CROSS_FACTION, DEFENSE)))
            check2:SetScript('OnMouseDown', function(self)
                Save().tab['VERSATILITY'].onlyDefense= not Save().tab['VERSATILITY'].onlyDefense and true or nil
                if Save().tab['VERSATILITY'].onlyDefense then
                    check2.A.text:SetTextColor(0.62, 0.62, 0.62)
                else
                    check2.A.text:SetTextColor(1, 0.82, 0)
                end
                WoWTools_AttributesMixin:Frame_Init(true)--初始，设置
            end)
            check2:SetScript('OnEnter', function(self)
                WoWTools_AttributesMixin:Set_Tooltips(self, nil)
                self:SetAlpha(0.3)
            end)
            check2:SetScript('OnLeave', GameTooltip_Hide)
            check2.name= info.name

            check2.A=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--双属性 22/18%
            check2.A:SetChecked(Save().tab['VERSATILITY'].damageAndDefense)
            check2.A:SetPoint('LEFT', check2.text, 'RIGHT',2,0)
            check2.A.text:SetText('22/18%')
            check2.A:SetScript('OnMouseDown', function(self)
                Save().tab['VERSATILITY'].damageAndDefense= not Save().tab['VERSATILITY'].damageAndDefense and true or nil
                WoWTools_AttributesMixin:Frame_Init(true)--初始，设置
            end)
            check2.A:SetScript('OnEnter', function(self)
                WoWTools_AttributesMixin:Set_Tooltips(self, nil)
                self:SetAlpha(0.3)
            end)
            check2.A:SetScript('OnLeave', GameTooltip_Hide)
            check2.A.name= info.name

            if Save().tab['VERSATILITY'].onlyDefense then
                check2.A.text:SetTextColor(0.62, 0.62, 0.62)
            end
        end
        last= check
    end



    local text= WoWTools_LabelMixin:Create(panel, {size=26})--26)--Text
    text:SetPoint('TOPLEFT', last, 'BOTTOMLEFT',0, -16)
    text:SetText(e.onlyChinese and '阴影' or SHADOW_QUALITY:gsub(QUALITY , ''))
    text:EnableMouse(true)
    text.r, text.g, text.b, text.a= Save().font.r, Save().font.g, Save().font.b, Save().font.a
    WoWTools_AttributesMixin:Set_Shadow(text)--设置，字体阴影
    text:SetScript('OnMouseDown', function(self)
        local R,G,B,A= self.r, self.g, self.b, self.a
        local setA, setR, setG, setB
        local function func()
            Save().font.r= setR
            Save().font.g= setG
            Save().font.b= setB
            Save().font.a= setA
            WoWTools_AttributesMixin:Set_Shadow(self)--设置，字体阴影
            WoWTools_AttributesMixin:Frame_Init(true)--初始，设置
        end
        WoWTools_ColorMixin:ShowColorFrame(self.r, self.g, self.b, self.a, function()
                setR, setG, setB, setA = WoWTools_ColorMixin:Get_ColorFrameRGBA()
                func()
            end, function()
                setR, setG, setB, setA= R,G,B,A
                func()
            end
        )
    end)
    text:SetScript('OnLeave', function(self2) self2:SetAlpha(1) e.tips:Hide() end)
    text:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '设置' or SETTINGS, (e.onlyChinese and '阴影' or SHADOW_QUALITY:gsub(QUALITY , ''))..e.Icon.left..(e.onlyChinese and '颜色' or COLOR))
        e.tips:AddDoubleLine('r'..(self2.r or 1)..' g'..(self2.g or 1)..' b'..(self2.b or 1), 'a'..(self2.a or 1))
        e.tips:Show()
        self2:SetAlpha(0.3)
    end)

    --bar, 宽度
    local sliderX=e.CSlider(panel, {w=120 ,h=20, min=-5, max=5, value=Save().font.x, setp=1, color=nil,
        text='X',
        func=function(self, value)
            value= math.floor(value)
            self:SetValue(value)
            self.Text:SetText(value)
            Save().font.x= value==0 and 0 or value
            WoWTools_AttributesMixin:Set_Shadow(self.text)--设置，字体阴影
            WoWTools_AttributesMixin:Frame_Init(true)--初始，设置
        end, tips=nil
    })
    sliderX:SetPoint("TOPLEFT", text, 'BOTTOMLEFT',0,-12)
    sliderX.text= text

    --bar, 宽度
    local sliderY= e.CSlider(panel, {w=120 ,h=20, min=-5, max=5, value=Save().font.y, setp=1, color=true,
        text='Y', func=function(self, value, userInput)
            value= math.floor(value)
            self:SetValue(value)
            self.Text:SetText(value)
            Save().font.y= value==0 and 0 or value
            WoWTools_AttributesMixin:Set_Shadow(self.text)--设置，字体阴影
            WoWTools_AttributesMixin:Frame_Init(true)--初始，设置
        end, tips=nil
    })
    sliderY:SetPoint("LEFT", sliderX, 'RIGHT', 2, 0)
    sliderY.text= text

    local notTextCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    notTextCheck:SetPoint("TOPLEFT", panel, 'TOP', 0, -32)
    notTextCheck.text:SetText(e.onlyChinese and '隐藏数值' or HIDE..STATUS_TEXT_VALUE)
    notTextCheck:SetChecked(Save().notText)
    notTextCheck:SetScript('OnMouseDown', function()
        Save().notText= not Save().notText and true or nil
        WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置
    end)

    local textColor= WoWTools_LabelMixin:Create(panel, {size=20})--20)--数值text, 颜色
    textColor:SetPoint('LEFT', notTextCheck.text,'RIGHT', 5, 0)
    textColor:EnableMouse(true)
    textColor:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
    textColor:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '设置' or SETTINGS, e.Icon.left..self.hex..(e.onlyChinese and '颜色' or COLOR))
        e.tips:Show()
        self:SetAlpha(0.3)
    end)
    textColor:SetText('23%')
    WoWTools_ColorMixin:RGBtoHEX(Save().textColor.r, Save().textColor.g, Save().textColor.b, Save().textColor.a, textColor)
    textColor:SetScript('OnMouseDown', function(self)
        local setR, setG, setB, setA
        local R,G,B,A= self.r, self.g, self.b, self.a
        local function func()
            Save().textColor= {r=setR, g=setG, b=setB, a=setA}
            self:SetTextColor(setR, setG, setB, setA)
            WoWTools_AttributesMixin:Frame_Init(true)--初始，设置
        end
        WoWTools_ColorMixin:ShowColorFrame(self.r, self.g, self.b,self.a, function()
                setR, setG, setB, setA= WoWTools_ColorMixin:Get_ColorFrameRGBA()
                func()
            end,function()
                setR, setG, setB, setA= R,G,B,A
                func()
            end
        )
    end)


    check= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    check:SetPoint("TOPLEFT", notTextCheck, 'BOTTOMLEFT')
    check.text:SetText((e.onlyChinese and '向左' or BINDING_NAME_STRAFELEFT)..' 23%'..Tabs[2].text)
    check:SetChecked(Save().toLeft)
    check:SetScript('OnMouseDown', function()
        Save().toLeft= not Save().toLeft and true or nil
        WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置
    end)


    local check5= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--使用，数值
    check5:SetPoint("TOPLEFT", check, 'BOTTOMLEFT')
    check5.text:SetText((e.onlyChinese and '数值' or STATUS_TEXT_VALUE)..' 2K')
    check5:SetChecked(Save().useNumber)
    check5:SetScript('OnMouseDown', function()
        Save().useNumber= not Save().useNumber and true or nil
        WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置
    end)

    --位数，bit
    local sliderBit= e.CSlider(panel, {w=100 ,h=20, min=0, max=3, value=Save().bit or 0, setp=1, color=nil,
        text=(e.onlyChinese and '位数' or 'bit'),
        func=function(self, value)
            value= math.ceil(value)
            self:SetValue(value)
            self.Text:SetText(value)
            Save().bit= value==0 and 0 or value
            WoWTools_AttributesMixin:Frame_Init(true)--初始，设置
        end,
    tips=nil})
    sliderBit:SetPoint("LEFT", check5.text, 'RIGHT', 6,0)


    local barValueText= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--增加,减少,值
    barValueText:SetPoint("TOPLEFT", check5, 'BOTTOMLEFT')
    barValueText.text:SetText(e.onlyChinese and '增益' or BENEFICIAL)
    barValueText:SetChecked(Save().setMaxMinValue)
    barValueText:SetScript('OnMouseDown', function()
        Save().setMaxMinValue= not Save().setMaxMinValue and true or nil
        WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置
        if Save().setMaxMinValue then
            C_Timer.After(0.3, function()
                for _, info in pairs(WoWTools_AttributesMixin:Get_Tabs()) do
                    local frame= button[info.name]
                    if frame and frame.textValue then
                        frame.textValue:SetText('+12')
                    end
                end
            end)
        end
    end)
    panel.barGreenColor= WoWTools_LabelMixin:Create(panel, {size=20})--20)
    panel.barGreenColor:SetPoint('LEFT', barValueText.text,'RIGHT', 2, 0)
    panel.barGreenColor:EnableMouse(true)
    panel.barGreenColor:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
    panel.barGreenColor:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '设置' or SETTINGS, e.Icon.left..self.hex..(e.onlyChinese and '颜色' or COLOR))
        e.tips:Show()
        self:SetAlpha(0.3)
    end)
    panel.barGreenColor:SetText('+12')
    WoWTools_ColorMixin:HEXtoRGB(Save().greenColor, panel.barGreenColor)--设置, panel.barGreenColor. r g b hex
    panel.barGreenColor:SetScript('OnMouseDown', function(self)
        local setR, setG, setB, setA
        local R,G,B,A= self.r, self.g, self.b, self.a
        local function func()
            local hex= WoWTools_ColorMixin:RGBtoHEX(setR, setG, setB,setA, self)--RGB转HEX
            hex= hex and '|c'..hex or '|cffff8200'
            Save().greenColor= hex
            GreenColor= {r=setR or 1, g=setG or 0, b=setB or 0, a=setA or 1}
        end
        WoWTools_ColorMixin:ShowColorFrame(self.r, self.g, self.b,self.a, function()
                setR, setG, setB, setA= WoWTools_ColorMixin:Get_ColorFrameRGBA()
                func()
            end, function()
                setR, setG, setB, setA= R,G,B,A
                func()
            end
        )
    end)

    panel.barRedColor= WoWTools_LabelMixin:Create(panel, {size=20})--20)
    panel.barRedColor:SetPoint('LEFT', panel.barGreenColor,'RIGHT', 2, 0)
    panel.barRedColor:EnableMouse(true)
    panel.barRedColor:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
    panel.barRedColor:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '设置' or SETTINGS, e.Icon.left..self.hex..(e.onlyChinese and '颜色' or COLOR))
        e.tips:Show()
        self:SetAlpha(0.3)
    end)
    panel.barRedColor:SetText('-12')
    WoWTools_ColorMixin:HEXtoRGB(Save().redColor, panel.barRedColor)--设置, panel.barRedColor. r g b hex
    panel.barRedColor:SetScript('OnMouseDown', function(self)
        local setR, setG, setB, setA
        local R,G,B,A= self.r, self.g, self.b, self.a
        local function func()
            local hex= WoWTools_ColorMixin:RGBtoHEX(setR, setG, setB,setA, self)--RGB转HEX
            hex= hex and '|c'..hex or '|cffff0000'
            Save().redColor= hex
            RedColor= {r=setR or 1, g=setG or 0, b=setB or 0, a=setA or 1}
        end
        WoWTools_ColorMixin:ShowColorFrame(self.r, self.g, self.b,self.a, function()
                setR, setG, setB, setA= WoWTools_ColorMixin:Get_ColorFrameRGBA()
                func()
            end, function()
                setR, setG, setB, setA= R,G,B,A
                func()
            end
        )
    end)

    local check2= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--bar
    check2:SetPoint("TOPLEFT", barValueText, 'BOTTOMLEFT',0,-62)
    check2.text:SetText('Bar')
    check2:SetChecked(Save().bar)
    check2:SetScript('OnMouseDown', function()
        Save().bar= not Save().bar and true or nil
        WoWTools_AttributesMixin:Frame_Init(true)--初始，设置
    end)

    local check3= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--bar，图片，样式2
    check3:SetPoint("LEFT", check2.text, 'RIGHT', 6, 0)
    check3.text:SetText((e.onlyChinese and '格式' or FORMATTING).. ' 2')
    check3:SetChecked(Save().barTexture2)
    check3:SetScript('OnMouseDown', function()
        Save().barTexture2= not Save().barTexture2 and true or nil
        WoWTools_AttributesMixin:Frame_Init(true)--初始，设置
    end)

    --bar, 宽度
    local barWidth= e.CSlider(panel, {w=120, h=20, min=-119, max=250, value=Save().barWidth, setp=1, color=nil,
        text=e.onlyChinese and '宽' or WIDE,
        func=function(self, value)
            value= math.floor(value)
            self:SetValue(value)
            self.Text:SetText(value)
            Save().barWidth= value==0 and 0 or value
            WoWTools_AttributesMixin:Frame_Init(true)--初始，设置
        end, tips=nil
    })
    barWidth:SetPoint("LEFT", check3.text, 'RIGHT', 10, 0)

    --bar, x
    local barX= e.CSlider(panel, {w=120, h=20, min=-250, max=250, value=Save().barX, setp=1, color=true,
        text='X',
        func=function(self, value)
            value= math.floor(value)
            self:SetValue(value)
            self.Text:SetText(value)
            Save().barX= value==0 and 0 or value
            WoWTools_AttributesMixin:Frame_Init(true)--初始，设置
        end, tips=nil
    })
    barX:SetPoint("TOPLEFT", barWidth.Low, 'BOTTOMLEFT', 0, -10)


    local barToLeft= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--bar 向左
    barToLeft:SetPoint("TOPLEFT", check2, 'BOTTOMLEFT')
    barToLeft.text:SetText(e.onlyChinese and '向左' or BINDING_NAME_STRAFELEFT)
    barToLeft:SetChecked(Save().barToLeft)
    barToLeft:SetScript('OnMouseDown', function()
        Save().barToLeft= not Save().barToLeft and true or nil
        WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置
    end)

    --间隔，上下
    local slider= e.CSlider(panel, {w=120, h=20, min=-5, max=10, value=Save().vertical, setp=0.1, color=nil,
        text='|T450907:0|t|T450905:0|t',
        func=function(self, value)
            value= tonumber(format('%.1f', value))
            self:SetValue(value)
            self.Text:SetText(value)
            Save().vertical= value==0 and 0 or value
            WoWTools_AttributesMixin:Frame_Init(true)--初始，设置
        end,
        tips=nil
    })
    slider:SetPoint("TOPLEFT", barToLeft, 'BOTTOMLEFT', 0,-80)

    --间隔，左右
    local slider2= e.CSlider(panel, {w=120, h=20, min=-0.1, max=40, value=Save().horizontal, setp=0.1, color=true,
        text='|T450908:0|t|T450906:0|t',
        func=function(self, value)
            value= tonumber(format('%.1f', value))
            self:SetValue(value)
            self.Text:SetText(value)
            Save().horizontal=value
            WoWTools_AttributesMixin:Frame_Init(true)--初始，设置
        end,
        tips=nil
    })
    slider2:SetPoint("LEFT", slider, 'RIGHT', 10,0)

    --文本，截取
    local slider3= e.CSlider(panel, {w=120, h=20, min=0, max=20, value=Save().gsubText or 0, setp=1, color=nil,
        text=e.onlyChinese and '截取' or BINDING_NAME_SCREENSHOT,
        func=function(self, value, userInput)
            value= math.floor(value)
            self:SetValue(value)
            self.Text:SetText(value)
            Save().gsubText= value>0 and value or nil
            WoWTools_AttributesMixin:Frame_Init(true)--初始，设置
            print(e.addName, WoWTools_AttributesMixin.addName, '|cnGREEN_FONT_COLOR:'..value..'|r', e.onlyChinese and '文本 0=否' or (LOCALE_TEXT_LABEL..' 0='..NO))
        end,
        tips=nil
    })
    slider3:SetPoint("TOPLEFT", slider, 'BOTTOMLEFT', 0,-24)


    local checkStrupper= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--bar，图片，样式2
    local checkStrlower= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--bar，图片，样式2
    checkStrupper:SetPoint("LEFT", slider3, 'RIGHT')
    checkStrupper.text:SetText('ABC')--大写
    checkStrupper:SetChecked(Save().strupper)
    checkStrupper:SetScript('OnMouseDown', function()
        Save().strupper= not Save().strupper and true or nil
        if Save().strupper then
            Save().strlower=nil
            checkStrlower:SetChecked(false)
        end
        WoWTools_AttributesMixin:Frame_Init(true)--初始，设置
    end)
    checkStrlower:SetPoint("LEFT", checkStrupper.text, 'RIGHT')
    checkStrlower.text:SetText('abc')--小写
    checkStrlower:SetChecked(Save().strlower)
    checkStrlower:SetScript('OnMouseDown', function()
        Save().strlower= not Save().strlower and true or nil
        if Save().strlower then
            Save().strupper=nil
            checkStrupper:SetChecked(false)
        end
        WoWTools_AttributesMixin:Frame_Init(true)--初始，设置
    end)

    --缩放
    local slider4= e.CSlider(panel, {w=nil, h=20, min=0.3, max=4, value=Save().scale or 1, setp=0.1, color=nil,
        text=e.onlyChinese and '缩放' or UI_SCALE,
        func=function(self, value)
            value= tonumber(format('%.1f', value)) or 1
            self:SetValue(value)
            self.Text:SetText(value)
            Save().scale=value
            button.frame:SetScale(value)
        end,
        tips=nil
    })
    slider4:SetPoint("TOPLEFT", slider3, 'BOTTOMLEFT', 0,-24)


    local sliderButtonAlpha = e.CSlider(panel, {min=0, max=1, value=Save().buttonAlpha or 0.3, setp=0.1, color=true,
    text=e.onlyChinese and '专精透明度' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SPECIALIZATION, 'Alpha'),
    func=function(self, value)
        value= tonumber(format('%.1f', value))
        value= value==0 and 0 or value
        value= value==1 and 1 or value
        self:SetValue(value)
        self.Text:SetText(value)
        Save().buttonAlpha= value
        button:set_Show_Hide()--显示， 隐藏
    end})
    sliderButtonAlpha:SetPoint("TOPLEFT", slider4, 'BOTTOMLEFT', 0,-24)

    local sliderButtonScale = e.CSlider(panel, {min=0.4, max=4, value=Save().buttonScale or 1, setp=0.1, color=true,
    text=e.onlyChinese and '专精缩放' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SPECIALIZATION, UI_SCALE),
    func=function(self, value)
        value= tonumber(format('%.01f', value))
        value= value<0.4 and 0.4 or value
        value= value>4 and 4 or value
        self:SetValue(value)
        self.Text:SetText(value)
        Save().buttonScale= value
        button:set_Show_Hide()--显示， 隐藏
    end})
    sliderButtonScale:SetPoint("TOPLEFT", sliderButtonAlpha, 'BOTTOMLEFT', 0,-24)


    local restPosti= WoWTools_ButtonMixin:Cbtn(panel, {size={20,20}, atlas='characterundelete-RestoreButton'})--重置
    restPosti:SetPoint('BOTTOMRIGHT')
    restPosti:SetScript('OnClick', function()
        Save().point=nil
        button:set_Point()--设置, 位置
    end)
    restPosti:SetScript('OnLeave', GameTooltip_Hide)
    restPosti:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine((not Save().point and '|cff9e9e9e' or '')..(e.onlyChinese and '重置位置' or RESET_POSITION))
        e.tips:Show()
    end)


    local checkHidePet= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    checkHidePet:SetPoint('BOTTOMLEFT')
    checkHidePet.text:SetText(e.onlyChinese and '自动隐藏' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE))
    checkHidePet:SetChecked(Save().hideInPetBattle)
    checkHidePet:SetScript('OnMouseDown', function()
        Save().hideInPetBattle= not Save().hideInPetBattle and true or nil
        button:set_event()
        button:settings()
    end)

    return true
end











function WoWTools_AttributesMixin:Init_Options()
    if Init() then
        Init=function()end
    end
end