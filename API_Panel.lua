local id, e = ...
local addName= 'Panel Settings'
local Save={
    onlyChinese= LOCALE_zhCN or e.Player.husandro,
    --useClassColor= e.Player.husandro,--使用,职业, 颜色
    --useCustomColor= nil,--使用, 自定义, 颜色
    useColor=1,
    useCustomColorTab= {r=1, g=0.82, b=0, a=1, hex='|cffffd100'},--自定义, 颜色, 表
}
local panel = CreateFrame("Frame", 'WoWTools')--Panel


--[[
e.ReloadPanel(tab)
e.CSlider(self, {w=, h=, min=, max=, value=, setp=, color=, text=, func=clickfunc, tips=func})
e.OpenPanelOpting(name, category)
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
]]














--#####################
--重新加载UI, 重置, 按钮
--#####################
function e.ReloadPanel(tab)
    local rest= e.Cbtn(tab.panel, {type=false, size={25,25}})
    rest:SetNormalAtlas('bags-button-autosort-up')
    rest:SetPushedAtlas('bags-button-autosort-down')
    rest:SetPoint('TOPRIGHT',0,8)
    rest.addName=tab.addName
    rest.func=tab.clearfunc
    rest.clearTips=tab.clearTips
    rest.clearWoWData= tab.clearWoWData
    rest:SetScript('OnClick', function(self)
        StaticPopupDialogs[id..'restAllSetup']={
            text =id..'  '..self.addName..'|n|n|cnRED_FONT_COLOR:'..(self.clearTips or (e.onlyChinese and '当前保存' or (ITEM_UPGRADE_CURRENT..SAVE)))..'|r '..(e.onlyChinese and '保存' or SAVE)..'|n|n'..(e.onlyChinese and '重新加载UI' or RELOADUI)..' /reload',
            button1= '|cnRED_FONT_COLOR:'..(e.onlyChinese and '重置' or RESET),
            button2= e.onlyChinese and '取消' or CANCEL,
            whileDead=true, hideOnEscape=true, exclusive=true,
            OnAccept=self.func,
        }

        if self.clearWoWData then
            StaticPopupDialogs[id..'restAllSetup'].button3= '|cffff00ff'..(e.onlyChinese and '清除WoW数据' or 'Clear WoW data')..'|r'
            StaticPopupDialogs[id..'restAllSetup'].OnAlt= function()
                e.WoWDate=nil
                e.Reload()
                print(id, e.cn(addName), (e.onlyChinese and '缩放' or UI_SCALE)..': 1', '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD))
            end
        end
        StaticPopup_Show(id..'restAllSetup')
    end)
    rest:SetScript('OnLeave', GameTooltip_Hide)
    rest:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(self.clearTips or (e.onlyChinese and '当前保存' or (ITEM_UPGRADE_CURRENT..SAVE)))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, self.addName)
        e.tips:Show()
    end)

    local reload
    if reload then
        reload= e.Cbtn(tab.panel, {type=false, size={25,25}})
        reload:SetNormalTexture('Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up')
        reload:SetPushedTexture('Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down')
        reload:SetPoint('TOPLEFT',-12, 8)
        reload:SetScript('OnClick', e.Reload)
        reload.addName=tab.addName
        reload:SetScript('OnLeave', GameTooltip_Hide)
        reload:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddLine(e.onlyChinese and '重新加载UI' or RELOADUI)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, self.addName)
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
            e.tips:AddDoubleLine(id, self.addName)
            e.tips:Show()
        end)
    end
    if tab.restTips then
        local needReload= e.Cstr(tab.panel)
        needReload:SetText(e.Icon.toRight2..(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)..e.Icon.toLeft2)
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
            e.tips:AddLine(e.Icon.down2..(e.onlyChinese and '最小' or MINIMUM)..': '..tab.min)
            e.tips:AddLine(e.Icon.up2..(e.onlyChinese and '最大' or MAXIMUM)..': '..tab.max)
            e.tips:AddLine('Setp: '..tab.setp)
            e.tips:AddLine(' ')
            e.tips:AddLine(e.Icon.toRight2..(e.onlyChinese and '当前: ' or ITEM_UPGRADE_CURRENT)..self2:GetValue())
            e.tips:Show()
        end)
    end
    return slider
end





































--##############
--创建, 添加控制面板
--##############
local variableIndex=0
local function get_variableIndex()
    variableIndex= variableIndex+1
    return variableIndex
end
local Category, Layout = Settings.RegisterVerticalLayoutCategory('|TInterface\\AddOns\\WoWTools\\Sesource\\Texture\\WoWtools.tga:0|t|cffff00ffWoW|r|cff00ff00Tools|r')
Category.expanded=true
Settings.RegisterAddOnCategory(Category)
Settings.SetKeybindingsCategory(Category)

--打开，选项
function e.OpenPanelOpting(name, category)
    name= type(name)=='table' and name:GetName() or name
    Settings.OpenToCategory(Category:GetID(), name)
    if category then
        Settings.OpenToCategory(category:GetID(), category:GetName())
    end
end
    --[[
    if subCategoryName and Category:HasSubcategories() then
        Settings.OpenToCategory(Category:GetID(), name)
        print(SettingsPanel.CategoryList.ScrollBox.ScrollTarget.SetExpanded)
        --SettingsPanel.CategoryList.ScrollBox
        
       for _, info in pairs(Category:GetSubcategories() or {}) do
            if info.name==subCategoryName then
                for k, v in pairs(info) do if v and type(v)=='table' then print('---------',k..'STAR') for k2,v2 in pairs(v) do print(k2,v2) end print('---------',k..'END') end print(k,v) end
                --Settings.OpenToCategory(info.ID, info.name)
                return
            end
       end
    else
        Settings.OpenToCategory(Category:GetID(), name)
    end]]


--添加，子目录
function e.AddPanel_Sub_Category(tab)
    if tab.frame then
        return Settings.RegisterCanvasLayoutSubcategory(Category, tab.frame, tab.name)
    else
        return Settings.RegisterVerticalLayoutSubcategory(Category, tab.name)--Blizzard_SettingsInbound.lua
    end
end


--添加，标题
function e.AddPanel_Header(layout, title)
    layout= layout or Layout
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(title))
end


--添加，Check
function e.AddPanel_Check(tab)
    local name = tab.name
    local tooltip = tab.tooltip
    local category= tab.category or Category
    local defaultValue= tab.value and true or false
    local func= tab.func

    local variable = id..name..(category.order or '')..get_variableIndex()
    local setting= Settings.RegisterAddOnSetting(category, name, variable, type(defaultValue), defaultValue)

    local initializer= Settings.CreateCheckBox(category, setting, tooltip)
    Settings.SetOnValueChangedCallback(variable, func, initializer)
    return initializer
end
--[[
local initializer2= e.AddPanel_Check({
    name= ,
    tooltip= e.cn(addName),
    category= Category,
    value= not Save.disabled,
    func= function()
        print(id, e.cn(addName), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end
})
local initializer= e.AddPanel_Check({
})
initializer:SetParentInitializer(initializer2, function() return not Save.disabled end)
]]

--添加，按钮
function e.AddPanel_Button(tab)
    local title= tab.title or ''
    local buttonText= tab.buttonText or ''
    local buttonClick= tab.func
    local tooltip= tab.tooltip or tab.buttonText or tab.title or nil
    local layout= tab.layout or Layout
    local addSearchTags= tab.addSearchTags or tab.title or tab.buttonText or ''

    local initializer= CreateSettingsButtonInitializer(title, buttonText, buttonClick, tooltip, addSearchTags)--Blizzard_SettingControls.lua
	layout:AddInitializer(initializer)
    return initializer
end
--[[
 local initializer= e.AddPanel_Button({
    title= nil,
    buttonText= e.cn(addName),
    tooltip= nil,--需要 title
    layout= Layout,
    addSearchTags= e.cn(addName),
    func= function()
        print(id, e.cn(addName), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end
})
initializer:SetParentInitializer(initializer2, function() return not Save.disabled end)
]]

--添加，下拉菜单
function e.AddPanel_DropDown(tab)
    local SetValue= tab.SetValueFunc
    local GetOptions= tab.GetOptionsFunc
    local defaultValue= tab.value
    local name= tab.name
    local tooltip= tab.tooltip
    local category= tab.category or Category

    local variable= id..name..(category.order or '')..get_variableIndex()
    local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaultValue), defaultValue)
    local initializer= Settings.CreateDropDown(category, setting, GetOptions, tooltip)
    Settings.SetOnValueChangedCallback(variable, SetValue, initializer)
    return initializer
end
--[[
e.AddPanel_DropDown({
    SetValueFunc= function(_, _, value)
        print(id, e.cn(addName), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end,
    GetOptionsFunc= function()
        local container = Settings.CreateControlTextContainer()
        container:Add(1, e.onlyChinese and '职业' or CLASS)
        return container:GetData();
    end,
    value=,
    name=,
    tooltip= e.cn(addName),
    category=Category
})
]]



--添加，Check 和 按钮
function e.AddPanel_Check_Button(tab)
    local checkName = tab.checkName
    local defaultValue= tab.checkValue and true or false
    local checkFunc= tab.checkFunc

    local buttonText= tab.buttonText
    local buttonFunc= tab.buttonFunc

    local tooltip = tab.tooltip
    local layout= tab.layout or Layout
    local category= tab.category or Category

    local variable = id..checkName..(category.order or '')..get_variableIndex()
    local setting= Settings.RegisterAddOnSetting(category, checkName, variable, type(defaultValue), defaultValue)
    local initializer= CreateSettingsCheckBoxWithButtonInitializer(setting, buttonText, buttonFunc, false, tooltip)
    layout:AddInitializer(initializer)
    Settings.SetOnValueChangedCallback(variable, checkFunc, initializer)
    return initializer
end
--[[
local initializer2= e.AddPanel_Check_Button({
    checkName= e.cn(addName),
    checkValue= not Save.disabled,
    checkFunc= function()
        print(id, e.cn(addName), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end,
    buttonText= '',
    buttonFunc= function()
        print(id, e.cn(addName), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end,
    tooltip= e.cn(addName),
    layout= Layout,
    category= Category
})
]]



--添加，Check 和 划条
function e.GetFormatter1to10(value, minValue, maxValue)
    return RoundToSignificantDigits(((value-minValue)/(maxValue-minValue) * (maxValue- minValue)) + minValue, maxValue)
end
local function GetFormatter1to10(minValue, maxValue)
    return function(value)
        return e.GetFormatter1to10(value, minValue, maxValue)
    end
end
function e.AddPanel_Check_Sider(tab)
    local checkName= tab.checkName
    local checkValue= tab.checkValue and true or false
    local checkTooltip= tab.checkTooltip
    local checkFunc= tab.checkFunc

    local sliderValue= tab.sliderValue
    local sliderMinValue= tab.sliderMinValue
    local sliderMaxValue= tab.sliderMaxValue
    local sliderStep= tab.sliderStep
    local siderName= tab.siderName or checkName
    local siderTooltip= tab.siderTooltip or checkTooltip
    local siderFunc= tab.siderFunc

    local category= tab.category or Category
    local variable = id..checkName..(category.order or '')..get_variableIndex()
    local layout= tab.layout or Layout
    local checkSetting = Settings.RegisterAddOnSetting(category, checkName..'Check', variable..'Check', type(checkValue), checkValue)
    local siderSetting = Settings.RegisterAddOnSetting(category, checkName..'Sider', variable..'Sider', type(sliderValue), sliderValue)

    local options = Settings.CreateSliderOptions(sliderMinValue, sliderMaxValue, sliderStep)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, GetFormatter1to10(sliderMinValue, sliderMaxValue));

    local initializer = CreateSettingsCheckBoxSliderInitializer(checkSetting, checkName, checkTooltip, siderSetting, options, siderName, siderTooltip);
    Settings.SetOnValueChangedCallback(variable..'Check', checkFunc, initializer)
    Settings.SetOnValueChangedCallback(variable..'Sider', siderFunc, initializer)
    layout:AddInitializer(initializer)
    return initializer
end

--[[
e.AddPanel_Check_Sider({
    checkName= e.cn(addName),
    checkValue= not Save.disabled,
    checkTooltip= e.cn(addName),
    checkFunc= function()
        print(id, e.cn(addName), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end,
    sliderValue= 0.5,
    sliderMinValue= 0,
    sliderMaxValue= 1,
    sliderStep= 0.1,
    siderName= nil,
    siderTooltip= nil,
    siderFunc= function(_, _, value2)
        local value3= e.GetFormatter1to10(value2, MinValue, MaxValue)
        print(id, e.cn(addName), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end,
    layout= Layout,
    category= Category,
})
]]

--添加，划动条
function e.AddPanelSider(tab)
    local name= tab.name
    local defaultValue= tab.value
    local minValue= tab.minValue
    local maxValue= tab.maxValue
    local step= tab.setp
    local tooltip= tab.tooltip
    local category= tab.category or Category
    local func= tab.func

    local variable = id..name..(category.order or '')..get_variableIndex()
    local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaultValue), defaultValue)
    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, GetFormatter1to10(minValue, maxValue))
    local initializer= Settings.CreateSlider(category, setting, options, tooltip)
	Settings.SetOnValueChangedCallback(variable, func, initializer)
    return initializer
end
--[[
e.AddPanelSider({
    name= e.cn(addName),
    value= 0,
    minValue= 0,
    maxValue= 1,
    setp= 1,
    tooltip= e.cn(addName),
    category= Category,
    func= function(_, _, value2)
        local value3= e.GetFormatter1to10(value2, minValue, maxValue)
        print(id, e.cn(addName), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end
})
]]




--[[
function CreateSettingsCheckBoxSliderInitializer(cbSetting, cbLabel, cbTooltip, sliderSetting, sliderOptions, sliderLabel, sliderTooltip)
	local data =
	{
		name = cbLabel,
		tooltip = cbTooltip,
		cbSetting = cbSetting,
		cbLabel = cbLabel,
		cbTooltip = cbTooltip,
		sliderSetting = sliderSetting,
		sliderOptions = sliderOptions,
		sliderLabel = sliderLabel,
		sliderTooltip = sliderTooltip,
	};
	return Settings.CreateSettingInitializer("SettingsCheckBoxSliderControlTemplate", data);
end

]]






--[[Blizzard_SettingControls.lua PingSystem.lua
function CreateSettingsListSectionHeaderInitializer(name)
	local data = {name = name};
	return Settings.CreateElementInitializer("SettingsListSectionHeaderTemplate", data);
end
function CreateSettingsButtonInitializer(name, buttonText, buttonClick, tooltip)
	local data = {name = name, buttonText = buttonText, buttonClick = buttonClick, tooltip = tooltip};
	local initializer = Settings.CreateElementInitializer("SettingButtonControlTemplate", data);
	initializer:AddSearchTags(name);
	initializer:AddSearchTags(buttonText);
	return initializer;
end
function CreateSettingsCheckBoxWithButtonInitializer(setting, buttonText, buttonClick, clickRequiresSet, tooltip)
	local data = Settings.CreateSettingInitializerData(setting, nil, tooltip);
	data.buttonText = buttonText;
	data.OnButtonClick = buttonClick;
	data.clickRequiresSet = clickRequiresSet;
	return Settings.CreateSettingInitializer("SettingsCheckBoxWithButtonControlTemplate", data);
end
function CreateSettingsCheckBoxSliderInitializer(cbSetting, cbLabel, cbTooltip, sliderSetting, sliderOptions, sliderLabel, sliderTooltip)
	local data =
	{
		name = cbLabel,
		tooltip = cbTooltip,
		cbSetting = cbSetting,
		cbLabel = cbLabel,
		cbTooltip = cbTooltip,
		sliderSetting = sliderSetting,
		sliderOptions = sliderOptions,
		sliderLabel = sliderLabel,
		sliderTooltip = sliderTooltip,
	};
	return Settings.CreateSettingInitializer("SettingsCheckBoxSliderControlTemplate", data);
end
function CreateSettingsCheckBoxDropDownInitializer(cbSetting, cbLabel, cbTooltip, dropDownSetting, dropDownOptions, dropDownLabel, dropDownTooltip)
	local data =
	{
		name = cbLabel,
		tooltip = cbTooltip,
		cbSetting = cbSetting,
		cbLabel = cbLabel,
		cbTooltip = cbTooltip,
		dropDownSetting = dropDownSetting,
		dropDownOptions = dropDownOptions,
		dropDownLabel = dropDownLabel,
		dropDownTooltip = dropDownTooltip,
	};
	return Settings.CreateSettingInitializer("SettingsCheckBoxDropDownControlTemplate", data);
end
function CreateSettingsExpandableSectionInitializer(name)
	local initializer = CreateFromMixins(SettingsExpandableSectionInitializer);
	initializer:Init("SettingsExpandableSectionTemplate");
	initializer.data = {name = name};
	return initializer;
end

function CreateSettingsAddOnDisabledLabelInitializer()
	local data = {};
	return Settings.CreateElementInitializer("SettingsAddOnDisabledLabelTemplate", data);
end
function CreateSettingsSelectionCustomSelectedData(data, label)
	data.selectedDataFunc = function()
		return {label = label};
	end;
end
]]




--自定义，颜色
local function Set_Color()
    if Save.useColor==1 then
        e.Player.useColor= {r=e.Player.r, g=e.Player.g, b=e.Player.b, a=1, hex= e.Player.col}
    elseif Save.useColor==2 then
        e.Player.useColor= Save.useCustomColorTab
    else
        e.Player.useColor=nil
    end
end





























--####
--开始
--####
local function Init_Options()
    e.AddPanel_Header(nil, e.onlyChinese and '设置' or SETTINGS)

    e.AddPanel_Button({
        title= '|A:talents-button-undo:0:0|a'..(e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT),
        buttonText= '|A:QuestArtifact:0:0|a'..(e.onlyChinese and '清除全部' or REMOVE_WORLD_MARKERS ),
        addSearchTags= e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT,
        func= function()
            StaticPopupDialogs[id..'RestAllSetup']={
                text = '|TInterface\\AddOns\\WoWTools\\Sesource\\Texture\\WoWtools.tga:0|t|cffff00ffWoW|r|cff00ff00Tools|r|n|n'..(e.onlyChinese and "你想要将所有选项重置为默认状态吗？|n将会立即对所有设置生效。" or CONFIRM_RESET_SETTINGS)
                    ..'|n|n|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '重新加载UI' or RELOADUI)..'|n|n'
                ,
                button1= '|cnRED_FONT_COLOR:'..(e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT),
                button2= e.onlyChinese and '取消' or CANCEL,
                whileDead=true, hideOnEscape=true, exclusive=true,
                OnAccept=function ()
                    e.ClearAllSave=true
                    e.Reload()
                end,
            }
            StaticPopup_Show(id..'RestAllSetup')
        end
    })

    e.AddPanel_Button({
        title= e.Icon.wow2..(e.onlyChinese and '清除WoW数据' or 'Clear WoW data'),
        buttonText= '|A:QuestArtifact:0:0|a'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2),
        addSearchTags= e.onlyChinese and '清除WoW数据' or 'Clear WoW data',
        func= function()
            StaticPopupDialogs[id..'RestWoWSetup']={
                text = '|TInterface\\AddOns\\WoWTools\\Sesource\\Texture\\WoWtools.tga:0|t|cffff00ffWoW|r|cff00ff00Tools|r'
                    ..'|n|n'..(e.Icon.wow2..(e.onlyChinese and '清除WoW数据' or 'Clear WoW data'))
                    ..'|n|n|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '重新加载UI' or RELOADUI)..'|n|n'
                ,
                button1= '|cnRED_FONT_COLOR:'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2),
                button2= e.onlyChinese and '取消' or CANCEL,
                whileDead=true, hideOnEscape=true, exclusive=true,
                OnAccept=function ()
                    e.WoWDate={}
                    e.Reload()
                end,
            }
            StaticPopup_Show(id..'RestWoWSetup')
        end
    })








    e.AddPanel_DropDown({
        SetValueFunc= function(_, a, value)
            if value==2 then
                local valueR, valueG, valueB, valueA= Save.useCustomColorTab.r, Save.useCustomColorTab.g, Save.useCustomColorTab.b, Save.useCustomColorTab.a
                local setA, setR, setG, setB
                local function func()
                    local hex=e.RGB_to_HEX(setR, setG, setB, setA)--RGB转HEX
                    Save.useCustomColorTab={r=setR, g=setG, b=setB, a=setA, hex= '|c'..hex }
                    Set_Color()--自定义，颜色
                    print(e.Player.useColor and e.Player.useColor.hex or '', id, e.cn(addName),   e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
                e.ShowColorPicker(valueR, valueG, valueB, valueA, function()
                        setR, setG, setB, setA= e.Get_ColorFrame_RGBA()
                        func()
                    end, function()
                        setR, setG, setB, setA= valueR, valueG, valueB, valueA
                        func()
                    end
                )
            else
                if ColorPickerFrame:IsShown() then
                    ColorPickerCancelButton:Click()
                end
                Set_Color()--自定义，颜色
                print(id, e.Player.useColor and e.Player.useColor.hex or '', (e.onlyChinese and '颜色' or COLOR)..'|r',   e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
            Save.useColor= value

        end,
        GetOptionsFunc= function()
            local container = Settings.CreateControlTextContainer()
			container:Add(1, e.onlyChinese and '职业' or CLASS)
			container:Add(2, e.onlyChinese and '自定义' or CUSTOM)
			container:Add(3, e.onlyChinese and '无' or NONE)
			return container:GetData();
        end,
        value= Save.useColor,
        name= (e.Player.useColor and e.Player.useColor.hex or '')..(e.onlyChinese and '颜色' or COLOR),
        tooltip= e.cn(addName),
        category=Category
    })

    if not LOCALE_zhCN then
        if e.Player.region==3 then
            e.AddPanel_Check_Button({
                checkName= 'Chinese',
                checkValue= Save.onlyChinese,
                checkFunc= function()
                    e.onlyChinese= not e.onlyChinese and true or nil
                    Save.onlyChinese = e.onlyChinese
                    print(id,  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end,
                buttonText= e.onlyChinese and '语言翻译' or BUG_CATEGORY15,
                buttonFunc= function()
                    e.OpenPanelOpting(e.onlyChinese and '语言翻译' or BUG_CATEGORY15)
                end,
                tooltip=  e.onlyChinese and '语言: 简体中文'
                    or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LANGUAGE..': ', LFG_LIST_LANGUAGE_ZHCN),
                layout= Layout,
                category= Category
            })

        else
            e.AddPanel_Check({
                name= 'Chinese',
                tooltip= e.onlyChinese and '语言: 简体中文'
                        or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LANGUAGE..': ', LFG_LIST_LANGUAGE_ZHCN),
                category=Category,
                value= Save.onlyChinese,
                func= function()
                    e.onlyChinese= not e.onlyChinese and true or nil
                    Save.onlyChinese = e.onlyChinese
                    print(id,  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })
        end
    end

    if e.Player.region==1 or e.Player.region==3 then--US EU realm提示
        local function get_tooltip()
            local tabs= e.Player.region==3 and
                {
                    ["deDE"] = {col="|cFF00FF00DE|r", text='DE', realm="Germany"},
                    ["frFR"] = {col="|cFF00FFFFFR|r", text='FR', realm="France"},
                    ["enGB"] = {col="|cFFFF00FFGB|r", text='GB', realm="Great Britain"},
                    ["itIT"] = {col="|cFFFFFF00IT|r", text='IT', realm="Italy"},
                    ["esES"] = {col="|cFFFFBF00ES|r", text='ES', realm="Spain"},
                    ["ruRU"] = {col="|cFFCCCCFFRU|r" ,text='RU', realm="Russia"},
                    ["ptBR"] = {col="|cFF8fce00PT|r", text='PT', realm="Portuguese"},
                }
            or
                {
                    ["oce"] = {col="|cFF00FF00OCE|r", text='CE', realm="Oceanic"},
                    ["usp"] = {col="|cFF00FFFFUSP|r", text='USP', realm="US Pacific"},
                    ["usm"] = {col="|cFFFF00FFUSM|r", text='USM', realm="US Mountain"},
                    ["usc"] = {col="|cFFFFFF00USC|r", text='USC', realm="US Central"},
                    ["use"] = {col="|cFFFFBF00USE|r", text='USE', realm="US East"},
                    ["mex"] = {col="|cFFCCCCFFMEX|r", text='MEX', realm="Mexico"},
                    ["bzl"] = {col="|cFF8fce00BZL|r", text='BZL', realm="Brazil"},
                }
            local text
            for text2, tab in pairs(tabs) do
                text= (text and text..'|n' or '')..tab.col..'  '..tab.realm.. '  ('..tab.text..')  '.. text2
            end
            return text
        end
        e.AddPanel_Check({
            name= e.onlyChinese and '服务器' or 'Realm',
            tooltip=get_tooltip(),
            category=Category,
            value= not Save.disabledRealm,
            func= function()
                Save.disabledRealm= not Save.disabledRealm and true or nil
                print(id,  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        })
        if Save.disabledRealm then
            e.Get_Region(nil, nil, nil, true)
            e.Get_Region=function() end
        end
    end
end












local function Init()
    e.StausText={
        [ITEM_MOD_HASTE_RATING_SHORT]= e.onlyChinese and '急' or e.WA_Utf8Sub(STAT_HASTE, 1, 2, true),
        [ITEM_MOD_CRIT_RATING_SHORT]= e.onlyChinese and '爆' or e.WA_Utf8Sub(STAT_CRITICAL_STRIKE, 1, 2, true),
        [ITEM_MOD_MASTERY_RATING_SHORT]= e.onlyChinese and '精' or e.WA_Utf8Sub(STAT_MASTERY, 1, 2, true),
        [ITEM_MOD_VERSATILITY]= e.onlyChinese and '全' or e.WA_Utf8Sub(STAT_VERSATILITY, 1, 2, true),
        [ITEM_MOD_CR_AVOIDANCE_SHORT]= e.onlyChinese and '闪' or e.WA_Utf8Sub(STAT_AVOIDANCE, 1, 2, true),
        [ITEM_MOD_CR_LIFESTEAL_SHORT]= e.onlyChinese and '吸' or e.WA_Utf8Sub(STAT_LIFESTEAL, 1, 2, true),
        [ITEM_MOD_CR_SPEED_SHORT]=e.onlyChinese and '速' or e.WA_Utf8Sub(SPEED, 1,2,true),
    }
end
--[[
["ITEM_MOD_HASTE_RATING_SHORT"] = "急速",
["ITEM_MOD_CRIT_RATING_SHORT"] = "爆击",
["ITEM_MOD_MASTERY_RATING_SHORT"] = "精通",
["ITEM_MOD_VERSATILITY"] = "全能",
["ITEM_MOD_CR_LIFESTEAL_SHORT"] = "吸血",
["ITEM_MOD_CR_SPEED_SHORT"] = "加速",

["ITEM_MOD_PVP_POWER_SHORT"] = "PvP强度",
["ITEM_MOD_RESILIENCE_RATING_SHORT"] = "PvP韧性",
["ITEM_MOD_SPELL_POWER_SHORT"] = "法术强度",    
["ITEM_MOD_SPIRIT_SHORT"] = "精神",
["ITEM_MOD_STAMINA_SHORT"] = "耐力",
["ITEM_MOD_SPELL_DAMAGE_DONE_SHORT"] = "伤害加成",
["ITEM_MOD_SPELL_HEALING_DONE_SHORT"] = "治疗加成",
["ITEM_MOD_MULTICRAFT_SHORT"] = "产能",
["ITEM_MOD_DEFTNESS_SHORT"] = "熟练",
["ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT"] = "护甲穿透",
["ITEM_MOD_ATTACK_POWER_SHORT"] = "攻击强度",
["ITEM_MOD_CORRUPTION"] = "腐蚀",
["ITEM_MOD_CRAFTING_SPEED_SHORT"] = "制作速度",  
["ITEM_MOD_CR_STURDINESS_SHORT"] = "永不磨损",
["ITEM_MOD_EXPERTISE_RATING_SHORT"] = "精准",
["ITEM_MOD_EXTRA_ARMOR_SHORT"] = "护甲加成",
["ITEM_MOD_FINESSE_SHORT"] = "精细",
["ITEM_MOD_HIT_RATING_SHORT"] = "命中",
["ITEM_MOD_INSPIRATION_SHORT"] = "灵感",
["ITEM_MOD_RESOURCEFULNESS_SHORT"] = "充裕",
["ITEM_MOD_SPELL_PENETRATION_SHORT"] = "法术穿透",
["ITEM_MOD_PERCEPTION_SHORT"] = "感知",
["ITEM_MOD_DEFENSE_SKILL_RATING_SHORT"] = "防御",

["ITEM_MOD_CR_MULTISTRIKE_SHORT"] = "溅射",
["ITEM_MOD_BLOCK_RATING_SHORT"] = "格挡",
["ITEM_MOD_CR_AVOIDANCE_SHORT"] = "闪避",
["ITEM_MOD_DODGE_RATING_SHORT"] = "躲闪"
["ITEM_MOD_PARRY_RATING_SHORT"] = "招架",

["ITEM_MOD_AGILITY_SHORT"] = "敏捷",
["ITEM_MOD_STRENGTH_SHORT"] = "力量",
["ITEM_MOD_INTELLECT_SHORT"] = "智力",]]






panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(_, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1==id then
            WoWToolsSave= WoWToolsSave or {}
            --e.WoWDate= e.WoWDate or e.WoWDate or {}

            Save= WoWToolsSave[addName] or Save
            Save.useColor= Save.useColor or 1
            Save.useCustomColorTab= Save.useCustomColorTab or {r=1, g=0.82, b=0, a=1, hex='|cffffd100'}
            Set_Color()--自定义，颜色

            e.onlyChinese= LOCALE_zhCN or Save.onlyChinese
            Save.onlyChinese= LOCALE_zhCN or Save.onlyChinese

            if e.onlyChinese then
                e.Player.L= {
                    layer='位面',
                    size='大小',
                    key='关键词',
                }
            end

            Init()
            Init_Options()

            if not StaticPopupDialogs['GAME_SETTINGS_APPLY_DEFAULTS'].OnShow then
                --你想要将所有用户界面和插件设置重置为默认状态，还是只重置这个界面或插件的设置？
                --所有设置
                StaticPopupDialogs['GAME_SETTINGS_APPLY_DEFAULTS'].OnShow= function(frame)
                    frame.button1:SetEnabled(false)
                    C_Timer.After(3, function()
                        frame.button1:SetEnabled(true)
                    end)
                end
            end

            panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)