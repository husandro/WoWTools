local e= select(2, ...)
--插件名称
local Category, Layout = Settings.RegisterVerticalLayoutCategory('|TInterface\\AddOns\\WoWTools\\Sesource\\Texture\\WoWtools.tga:0|t|cffff00ffWoW|r|cff00ff00Tools|r')
Settings.RegisterAddOnCategory(Category)


--[[
e.ReloadPanel(tab)
e.CSlider(self, {w=, h=, min=, max=, value=, setp=, color=, text=, func=clickfunc, tips=func})
e.OpenPanelOpting(category, name)
e.AddPanel_Sub_Category(tab)
e.AddPanel_Header(layout, title)
e.AddPanel_Check(tab)
e.AddPanel_Button(tab)
e.AddPanel_DropDown(tab)
e.AddPanel_Check_Button(tab)
e.GetFormatter1to10(value, minValue, maxValue)
e.AddPanel_Check_Sider(tab)
e.AddPanelSider(tab)
e.StausText={}--属性，截取表 API_Panel.lua

initializer:AddSearchTags(bindingName)

local action = "INTERACTTARGET";
local bindingIndex = C_KeyBindings.GetBindingIndex(action);
local initializer = CreateKeybindingEntryInitializer(bindingIndex, true);
initializer:AddSearchTags(GetBindingName(action));
layout:AddInitializer(initializer);
]]










--#####################
--重新加载UI, 重置, 按钮
--#####################
function e.ReloadPanel(tab)
    local rest= WoWTools_ButtonMixin:Cbtn(tab.panel, {type=false, size={25,25}})
    rest:SetNormalAtlas('bags-button-autosort-up')
    rest:SetPushedAtlas('bags-button-autosort-down')
    rest:SetPoint('TOPRIGHT',0,8)
    rest.addName=tab.addName
    rest.func=tab.clearfunc
    rest.clearTips=tab.clearTips
    rest:SetScript('OnClick', function(self)
        StaticPopup_Show('WoWTools_RestData',
        (self.addName or '')..'|n|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '重新加载UI' or RELOADUI)..'|r',
        nil, self.func)
    end)
    rest:SetScript('OnLeave', GameTooltip_Hide)
    rest:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(self.clearTips or (e.onlyChinese and '当前保存' or (ITEM_UPGRADE_CURRENT..SAVE)))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(WoWTools_Mixin.addName, self.addName)
        e.tips:Show()
    end)

    local reload
    if reload then
        reload= WoWTools_ButtonMixin:Cbtn(tab.panel, {type=false, size={25,25}})
        reload:SetNormalTexture('Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up')
        reload:SetPushedTexture('Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down')
        reload:SetPoint('TOPLEFT',-12, 8)
        reload:SetScript('OnClick', function() WoWTools_Mixin:Reload() end)
        reload.addName=tab.addName
        reload:SetScript('OnLeave', GameTooltip_Hide)
        reload:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddLine(e.onlyChinese and '重新加载UI' or RELOADUI)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(WoWTools_Mixin.addName, self.addName)
            e.tips:Show()
        end)
    end
    if tab.disabledfunc then
        local check=CreateFrame("CheckButton", nil, tab.panel, "InterfaceOptionsCheckButtonTemplate")
        check.text:SetText(e.GetEnabeleDisable(true))
        check:SetChecked(tab.checked)
        if reload then
            check:SetPoint('LEFT', reload, 'RIGHT')
        else
            check:SetPoint('TOPLEFT',-12, 8)
        end
        check:SetScript('OnClick', tab.disabledfunc)
        check:SetScript('OnLeave', GameTooltip_Hide)
        check.addName= tab.addName
        check:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddLine(e.onlyChinese and '启用/禁用' or (ENABLE..'/'..DISABLE))
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(WoWTools_Mixin.addName, self.addName)
            e.tips:Show()
        end)
    end
    if tab.restTips then
        local needReload= WoWTools_LabelMixin:Create(tab.panel)
        needReload:SetText(format('|A:%s:0:0|a', e.Icon.toRight)..(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)..format('|A:%s:0:0|a', e.Icon.toLeft))
        needReload:SetPoint('BOTTOMRIGHT')
        needReload:SetTextColor(0,1,0)
    end
end





function e.CSlider(self, tab)--e.CSlider(self, {w=, h=, min=, max=, value=, setp=, color=, text=, func=clickfunc, tips=func})
    local slider= CreateFrame("Slider", nil, self, 'OptionsSliderTemplate')
    slider:SetSize(tab.w or 200, tab.h or 18)
    slider:SetMinMaxValues(tab.min, tab.max)
    slider:SetValue(tab.value)
    slider.Low:SetText(tab.text or tab.min)
    slider.High:SetText('')
    slider.Text:SetText(tab.value)

    slider.Low:ClearAllPoints()
    slider.Low:SetPoint('LEFT')
    slider.Text:ClearAllPoints()
    slider.Text:SetPoint('RIGHT')

    slider:SetValueStep(tab.setp)
    slider:SetScript('OnValueChanged', tab.func)
    slider:EnableMouseWheel(true)
    slider.max= tab.max
    slider.min= tab.min
    slider:SetScript('OnMouseWheel', function(self2, d)
        local setp= self2:GetValueStep() or 1
        local value= self2:GetValue()
        if d== 1 then
            value= value- setp
        elseif d==-1 then
            value= value+ setp
        end
        value= value> self2.max and self2.max or value
        value= value< self2.min and self2.min or value
        self2:SetValue(value)
    end)
    if tab.color then
        slider.Low:SetTextColor(1,0,1)
        slider.High:SetTextColor(1,0,1)
        slider.Text:SetTextColor(1,0,1)
        slider.NineSlice.BottomEdge:SetVertexColor(1,0,1)
        slider.NineSlice.TopEdge:SetVertexColor(1,0,1)
        slider.NineSlice.RightEdge:SetVertexColor(1,0,1)
        slider.NineSlice.LeftEdge:SetVertexColor(1,0,1)
        slider.NineSlice.TopRightCorner:SetVertexColor(1,0,1)
        slider.NineSlice.TopLeftCorner:SetVertexColor(1,0,1)
        slider.NineSlice.BottomRightCorner:SetVertexColor(1,0,1)
        slider.NineSlice.BottomLeftCorner:SetVertexColor(1,0,1)
    end
    slider:SetScript('OnLeave', GameTooltip_Hide)
    if tab.tip then
        slider:SetScript('OnEnter', tab.tips)
    else
        slider:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddLine(tab.text)
            e.tips:AddLine(' ')
            e.tips:AddLine('|A:UI-HUD-MicroMenu-StreamDLRed-Up:0:0|a'..(e.onlyChinese and '最小' or MINIMUM)..': '..tab.min)
            e.tips:AddLine('|A:bags-greenarrow:0:0|a'..(e.onlyChinese and '最大' or MAXIMUM)..': '..tab.max)
            e.tips:AddLine('Setp: '..tab.setp)
            e.tips:AddLine(' ')
            e.tips:AddLine(format('|A:%s:0:0|a', e.Icon.toRight)..(e.onlyChinese and '当前: ' or ITEM_UPGRADE_CURRENT)..self2:GetValue())
            e.tips:Show()
        end)
    end
    return slider
end


































--##############
--创建, 添加控制面板
--##############
local variableIndex=0
local function Set_VariableIndex()
    variableIndex= variableIndex+1
    return 'WoWToolsPanelVariable'..variableIndex
end
local function Set_SearchTags_Text(tags)
    if tags then
        tags= tags:gsub('|A.-|a', '')
        tags= tags:gsub('|T.-|t', '')
        tags= tags:gsub('|c........', '')
        tags= tags:gsub('|r', '')
    else
         tags=''
    end
    return tags
end



--打开，选项
--Settings.OpenToCategory(categoryID, scrollToElementName)
function e.OpenPanelOpting(category, name)
    category= (category and category.GetID) and category or Category
    Category.expanded=true
    name= name or (category and category.GetName and category:GetName())
    Settings.OpenToCategory(category:GetID(), name)
end


--添加，子目录
function e.AddPanel_Sub_Category(tab)
    local disabled
    if type(tab.disabled)=='function' then
        disabled= tab.disabled()
    else
        disabled= tab.disabled
    end

    local name= (disabled and '|cff828282' or '')..tab.name

    if tab.frame then
        return Settings.RegisterCanvasLayoutSubcategory(tab.category or Category, tab.frame, name)
    else
        return Settings.RegisterVerticalLayoutSubcategory(tab.category or Category, name)--Blizzard_SettingsInbound.lua
    end
end


--添加，标题
function e.AddPanel_Header(layout, title)
    layout= layout or Layout
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(title))
end






--Settings.RegisterProxySetting(categoryTbl, variable, variableType, name, defaultValue, getValue, setValue)



--添加，Check
function e.AddPanel_Check(tab, parentInitializer)
    local setting=Settings.RegisterProxySetting(
        tab.category or Category,
        Set_VariableIndex(),
        Settings.VarType.Boolean,
        tab.name,
        tab.GetValue() or tab.value,
        tab.GetValue,
        tab.SetValue or tab.func
    )
    local initializer= Settings.CreateCheckbox(tab.category or Category, setting, tab.tooltip)
    if parentInitializer then
        initializer:SetParentInitializer(parentInitializer)
    end
    return initializer
end


--添加，按钮
--CreateSettingsButtonInitializer(name, buttonText, buttonClick, tooltip, addSearchTags)
function e.AddPanel_Button(tab, parentInitializer)
    local layout= tab.layout or Layout
    local initializer= CreateSettingsButtonInitializer(--Blizzard_SettingControls.lua
        tab.title or '',
        tab.buttonText or '',
        tab.SetValue,
        tab.tooltip or tab.buttonText or tab.title or nil,
        Set_SearchTags_Text(tab.addSearchTags or tab.title or tab.buttonText)
    )
    layout:AddInitializer(initializer)
    if parentInitializer then
        initializer:SetParentInitializer(parentInitializer)
    end
    return initializer
end
--[[
e.AddPanel_Button({
    title= e.onlyChinese and '' or '',
    buttonText=e.onlyChinese and '' or '',
    SetValue=function()
    end,
    tooltip=nil,
    addSearchTags=nil,
}, sub)
]]


--添加，下拉菜单
function e.AddPanel_DropDown(tab)
    local setting= Settings.RegisterProxySetting(--categoryTbl, variable, variableType, name, defaultValue, getValue, setValue
        tab.category or Category,
        Set_VariableIndex(),
        Settings.VarType.Number,
        tab.name,
        tab.GetValue(),
        tab.GetValue,
        tab.SetValue or tab.func
    )
    return Settings.CreateDropdown(--setting, options, tooltip
            tab.category or Category,
            setting,
            tab.GetOptions,
            tab.tooltip
        )
end

--Blizzard_SettingControls.lua
--CreateSettingsCheckboxDropdownInitializer(cbSetting, cbLabel, cbTooltip, dropdownSetting, dropdownOptions, dropDownLabel, dropDownTooltip)
function e.AddPanel_Check_DropDown(tab, parentInitializer)
    local layout= tab.layout or Layout
    local cbSetting=Settings.RegisterProxySetting(
        tab.category or Category,--categoryTbl
        Set_VariableIndex(),--variable
        Settings.VarType.Boolean,--variableType
        tab.name,--name
        tab.GetValue(),--defaultValue
        tab.GetValue,--getValue
        tab.SetValue or tab.func--setValue
    )

    local dropdownSetting= Settings.RegisterProxySetting(--categoryTbl, variable, variableType, name, defaultValue, getValue, setValue
        tab.category or Category,
        Set_VariableIndex(),
        Settings.VarType.Number,
        tab.name,
        tab.DropDownGetValue(),
        tab.DropDownGetValue,
        tab.DropDownSetValue
    )

	local data =
	{
		name = tab.name,
		tooltip = tab.tooltip,
		cbSetting = cbSetting,
		cbLabel = tab.CheckBoxName or tab.name,
		cbTooltip = tab.CheckBoxTooltip or tab.tooltip,
		dropdownSetting = dropdownSetting,
		dropdownOptions = tab.GetOptions,
		dropDownLabel = tab.DropDownName or tab.name,
		dropDownTooltip = tab.DropDownTooltip or tab.tooltip,
	};
	local initializer= Settings.CreateSettingInitializer("SettingsCheckboxDropdownControlTemplate", data)
    layout:AddInitializer(initializer)
    if parentInitializer then
        initializer:SetParentInitializer(parentInitializer)
    end

    return initializer
end
--[[
e.AddPanel_Check_DropDown({
category=,
name=,
tooltip=,
GetValue=function()
end,
SetValue=function(value)
end,

DropDownGetValue=function()
end,
DropDownSetValue=function(value)
end,
GetOptions=function()
    local container = Settings.CreateControlTextContainer()
    container:Add(1, e.onlyChinese and '位于上方' or QUESTLINE_LOCATED_ABOVE)
    container:Add(2, e.onlyChinese and '位于下方' or QUESTLINE_LOCATED_BELOW)
    return container:GetData()
end
})
]]






--添加，Check 和 按钮
function e.AddPanel_Check_Button(tab, parentInitializer)
    local layout= tab.layout or Layout
    local checkSetting=Settings.RegisterProxySetting(
        tab.category or Category,
        Set_VariableIndex(),
        Settings.VarType.Boolean,
        tab.checkName,
        tab.GetValue(),
        tab.GetValue,
        tab.SetValue
    )
    local initializer= CreateSettingsCheckboxWithButtonInitializer(
        checkSetting,
        tab.buttonText,
        tab.buttonFunc,
        true,
        tab.tooltip
    )
    layout:AddInitializer(initializer)
    if parentInitializer then
        initializer:SetParentInitializer(parentInitializer)
    end
    return initializer
end



--添加，Check 和 划条
function e.GetFormatter1to10(value, minValue, maxValue)
    if value and minValue and maxValue then
        return RoundToSignificantDigits(((value-minValue)/(maxValue-minValue) * (maxValue- minValue)) + minValue, maxValue)
    end
    return value
end
--[[local function GetFormatter1to10(minValue, maxValue)
    return function(value)
        return e.GetFormatter1to10(value, minValue, maxValue)
    end
end]]






function e.AddPanel_Check_Sider(tab)
    local layout= tab.layout or Layout
    local checkSetting=Settings.RegisterProxySetting(
        tab.category or Category,
        Set_VariableIndex(),
        Settings.VarType.Boolean,
        tab.checkName,
        tab.checkGetValue(),
        tab.checkGetValue,
        tab.checkSetValue
    )

    local sliderSetting = Settings.RegisterProxySetting(
        tab.category or Category,
        Set_VariableIndex(),
        Settings.VarType.Number,
        tab.sliderName or tab.checkName,
        tab.sliderGetValue(),
        tab.sliderGetValue,
        tab.sliderSetValue
    )

    local options = Settings.CreateSliderOptions(tab.minValue, tab.maxValue, tab.step);
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
       return e.GetFormatter1to10(value or 1, 0, 1)
    end)

    local initializer = CreateSettingsCheckboxSliderInitializer(
        checkSetting,
        tab.checkName,
        tab.checkTooltip,

        sliderSetting,
        options,
        tab.sliderName or tab.checkName,
        tab.siderTooltip or tab.checkTooltip
    )

    Settings.SetOnValueChangedCallback(sliderSetting:GetVariable(), tab.sliderSetValue)
    layout:AddInitializer(initializer)
    return initializer
end



--添加，划动条
function e.AddPanelSider(tab)
    local setting = Settings.RegisterProxySetting(
        tab.category or Category,
        Set_VariableIndex(),
        Settings.VarType.Number,
        tab.name,
        tab.GetValue(),
        tab.GetValue,
        tab.SetValue
    )

    local options = Settings.CreateSliderOptions(tab.minValue, tab.maxValue, tab.setp);
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
        return e.GetFormatter1to10(value or 1, 0, 1)
    end)

    local initializer=Settings.CreateSlider(tab.category or Category, setting, options, tab.tooltip);
    Settings.SetOnValueChangedCallback(setting:GetVariable(), tab.SetValue)
    return initializer
end


















--[[
function  e.Add_Panel_RestData_Button(root, SetValue)
    if not StaticPopupDialogs['WoWTools_Rest_DaTa'] then
        StaticPopupDialogs['WoWTools_Rest_DaTa']={--重置所有,清除全部玩具
            text=id..' '..addName..'|n'..(e.onlyChinese and '清除全部' or CLEAR_ALL)..'|n|n'..(e.onlyChinese and '重新加载UI' or RELOADUI),
            whileDead=true, hideOnEscape=true, exclusive=true,
            button1='|cnRED_FONT_COLOR:'..(e.onlyChinese and '重置' or RESET)..'|r',
            button2= e.onlyChinese and '取消' or CANCEL,
            OnAccept = function(_, setValue)
                setValue()
                WoWTools_Mixin:Reload()
            end,
        }
    end
end

]]






























