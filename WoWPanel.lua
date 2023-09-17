local id, e = ...
local addName= 'Panel Settings'
local Save={
    onlyChinese= e.Player.husandro or LOCALE_zhCN,
    --useClassColor= e.Player.husandro,--使用,职业, 颜色
    --useCustomColor= nil,--使用, 自定义, 颜色
    useColor=1,
    useCustomColorTab= {r=1, g=0.82, b=0, a=1, hex='|cffffd100'},--自定义, 颜色, 表
}
local panel = CreateFrame("Frame", 'WoWTools')--Panel







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
                WoWDate=nil
                e.Reload()
                print(id, addName, (e.onlyChinese and '缩放' or UI_SCALE)..': 1', '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD))
            end
        end
        StaticPopup_Show(id..'restAllSetup')
    end)
    rest:SetScript('OnLeave', function() e.tips:Hide() end)
    rest:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(self.clearTips or (e.onlyChinese and '当前保存' or (ITEM_UPGRADE_CURRENT..SAVE)))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, self.addName)
        e.tips:Show()
    end)
    local reload= e.Cbtn(tab.panel, {type=false, size={25,25}})
    reload:SetNormalTexture('Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up')
    reload:SetPushedTexture('Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down')
    reload:SetPoint('TOPLEFT',-12, 8)
    reload:SetScript('OnClick', e.Reload)
    reload.addName=tab.addName
    reload:SetScript('OnLeave', function() e.tips:Hide() end)
    reload:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(e.onlyChinese and '重新加载UI' or RELOADUI)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, self.addName)
        e.tips:Show()
    end)
    if tab.restTips then
        local needReload= e.Cstr(tab.panel)
        needReload:SetText(e.Icon.toRight2..(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)..e.Icon.toLeft2)
        needReload:SetPoint('BOTTOMRIGHT')
        needReload:SetTextColor(0,1,0)
    end
    if tab.disabledfunc then
        local check=CreateFrame("CheckButton", nil, tab.panel, "InterfaceOptionsCheckButtonTemplate")
        check.text:SetText(e.GetEnabeleDisable(true))
        check:SetChecked(tab.checked)
        check:SetPoint('LEFT', reload, 'RIGHT')
        check:SetScript('OnClick', tab.disabledfunc)
        check:SetScript('OnLeave', function() e.tips:Hide() end)
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
Settings.RegisterAddOnCategory(Category)
Settings.SetKeybindingsCategory(Category)

--打开，选项
function e.OpenPanelOpting(category, name)
    category= category or Category
    local find= Settings.OpenToCategory(category:GetID(), name)
    if not find then
        Settings.OpenToCategory(Category:GetID())
        if e.Player.husandro then
            print(id, addName, '没有找到 panel')
        end
    end
end

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
    tooltip= addName,
    category= Category,
    value= not Save.disabled,
    func= function()
        print(id, addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
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
    local tooltip= tab.title and tab.tooltip or nil
    local layout= tab.layout or Layout

    local initializer= CreateSettingsButtonInitializer(title, buttonText, buttonClick, tooltip)--Blizzard_SettingControls.lua
	layout:AddInitializer(initializer)
    return initializer
end
--[[
 e.AddPanel_Button({
    title= nil,
    buttonText= addName,
    tooltip= nil,--需要 title
    layout= Layout,
    func= function()
        print(id, addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end
})
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
        print(id, addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end,
    GetOptionsFunc= function()
        local container = Settings.CreateControlTextContainer()
        container:Add(1, e.onlyChinese and '职业' or CLASS)
        return container:GetData();
    end,
    value=,
    name=,
    tooltip= addName,
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
    checkName= addName,
    checkValue= not Save.disabled,
    checkFunc= function()
        print(id, addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end,
    buttonText= '',
    buttonFunc= function()
        print(id, addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end,
    tooltip= addName,
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
    checkName= addName,
    checkValue= not Save.disabled,
    checkTooltip= addName,
    checkFunc= function()
        print(id, addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end,
    sliderValue= 0.5,
    sliderMinValue= 0,
    sliderMaxValue= 1,
    sliderStep= 0.1,
    siderName= nil,
    siderTooltip= nil,
    siderFunc= function(_, _, value2)
        local value3= e.GetFormatter1to10(value2, MinValue, MaxValue)
        print(id, addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
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
    name= addName,
    value= 0,
    minValue= 0,
    maxValue= 1,
    setp= 1,
    tooltip= addName,
    category= Category,
    func= function(_, _, value2)
        local value3= e.GetFormatter1to10(value2, minValue, maxValue)
        print(id, addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
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





--####
--开始
--####

local function Init()
    e.AddPanel_Header(nil, e.onlyChinese and '设置' or SETTINGS)

    e.AddPanel_Button({
        title= '|A:talents-button-undo:0:0|a'..(e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT),
        buttonText= '|A:QuestArtifact:0:0|a'..(e.onlyChinese and '默认设置' or SETTINGS_DEFAULTS),
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
                    WoWDate={}
                    e.Reload()
                end,
            }
            StaticPopup_Show(id..'RestWoWSetup')
        end
    })



    local function set_Color()
        if Save.useColor==1 then
            e.Player.useColor= {r=e.Player.r, g=e.Player.g, b=e.Player.b, a=1, hex= e.Player.col}
        elseif Save.useColor==2 then
            e.Player.useColor= Save.useCustomColorTab
        else
            e.Player.useColor=nil
        end
    end
    set_Color()
    e.AddPanel_DropDown({
        SetValueFunc= function(_, _, value)
            if value==2 then
                local valueR, valueG, valueB, valueA= Save.useCustomColorTab.r, Save.useCustomColorTab.g, Save.useCustomColorTab.b, Save.useCustomColorTab.a
                local setA, setR, setG, setB
                local function func()
                    local hex=e.RGB_to_HEX(setR, setG, setB, setA)--RGB转HEX
                    Save.useCustomColorTab={r=setR, g=setG, b=setB, a=setA, hex= '|c'..hex }
                    set_Color()
                    print(e.Player.useColor and e.Player.useColor.hex or '', id, addName,   e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
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
                set_Color()
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
        tooltip= addName,
        category=Category
    })

    if not LOCALE_zhCN then
        e.AddPanel_Check({
            name= 'Chinese',
            tooltip=e.onlyChinese and '语言: 简体中文'
                    or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LANGUAGE..': ', LFG_LIST_LANGUAGE_ZHCN),
            category=Category,
            value= not Save.disabled,
            func= function()
                e.onlyChinese= not e.onlyChinese and true or nil
                Save.onlyChinese = e.onlyChinese
                print(id,  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        })
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


    local btn= e.Cbtn(SettingsPanel, {type=false, size={140, 25}})
    btn:SetPoint('RIGHT', SettingsPanel.ApplyButton, 'LEFT', -15,0)
    btn:SetText(e.onlyChinese and '重新加载UI' or RELOADUI)
    btn:SetScript("OnClick", e.Reload)
    btn:SetScript('OnLeave', function() e.tips:Hide() end)
    btn:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(' ', '|cnGREEN_FONT_COLOR:'..SLASH_RELOAD1)
        e.tips:AddLine(" ")
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
    end)
end


local tabzhCN={
    layer='位面',
    size='大小',
    key='关键词',
}
local function set_Local_Text()
    if e.onlyChinese then
        e.Player.L=tabzhCN
    end
end
if LOCALE_zhCN then
    e.Player.L= tabzhCN
elseif LOCALE_zhTW then
    e.Player.L={
        layer='位面',
        size='大小',
        key='關鍵詞',
    } 
elseif LOCALE_koKR then
    e.Player.L={
        layer='층',
        size='크기',
        key='키워드',
    }
elseif LOCALE_frFR then
    e.Player.L={
        layer='Couche',
        size='Taille',
        key='Mots clés',
    }
elseif LOCALE_deDE then
    e.Player.L={
        layer='Schicht',
        size='Größe',
        key='Schlüsselwörter',
    }
elseif LOCALE_esES or LOCALE_esMX then--西班牙语
    e.Player.L={
        layer='Capa',
        size='Tamaño',
        key='Palabras clave',
    }
elseif LOCALE_ruRU then
    e.Player.L={
        layer='слой',
        size='Размер',
        key='Ключевые слова',
    }
elseif LOCALE_ptBR then--葡萄牙语
    e.Player.L={
        layer='Camada',
        size='Tamanho',
        key='Palavras-chave',
    }
elseif LOCALE_itIT then
    e.Player.L={
        layer='Strato',
        size='Misurare',
        key='Parole chiave',
    }
else
    e.Player.L={
        layer= 'Layer',
        size= 'Size',
        key='Key words',
    }
end





panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(_, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1==id then
            WoWToolsSave= WoWToolsSave or {}
            WoWDate= WoWDate or {}

            Save= WoWToolsSave[addName] or Save
            Save.useColor= Save.useColor or 1
            Save.useCustomColorTab= Save.useCustomColorTab or {r=1, g=0.82, b=0, a=1, hex='|cffffd100'}

            e.onlyChinese= Save.onlyChinese or LOCALE_zhCN

            set_Local_Text()
            Init()
            panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if e.ClearAllSave then
            WoWToolsSave=nil
            WoWDate=nil
        else
            WoWToolsSave[addName]=Save
        end
    end
end)