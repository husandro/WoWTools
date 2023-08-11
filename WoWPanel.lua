local id, e = ...
local addName= 'panel Settings'
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
            whileDead=true,timeout=30,hideOnEscape = 1,
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

local Category, Layout = Settings.RegisterVerticalLayoutCategory('|TInterface\\AddOns\\WoWTools\\Sesource\\Texture\\WoWtools.tga:0|t|cffff00ffWoW|r|cff00ff00Tools|r')
Settings.RegisterAddOnCategory(Category)

--添加，子目录
function e.AddPanelSubCategory(tab)
    if tab.frame then
        return Settings.RegisterCanvasLayoutSubcategory(Category, tab.frame, tab.name)
    else
        return Settings.RegisterVerticalLayoutSubcategory(Category, tab.name)--Blizzard_SettingsInbound.lua
    end
end

--打开，选项
function e.OpenPanelOpting(frameName)
    Settings.OpenToCategory(Category, frameName)
end

--添加，标题
function e.AddPanelHeader(layout, title)
    layout= layout or Layout
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(title))
end

--添加，Check
function e.AddPanelCheck(tab)
    local name = tab.name
    local tooltip = tab.tooltip
    local category= tab.category or Category
    local defaultValue= tab.value and true or false
    local func= tab.func

    local variable = id..name
    local setting= Settings.RegisterAddOnSetting(category, name, variable, type(defaultValue), defaultValue)

    local initializer= Settings.CreateCheckBox(category, setting, tooltip)
    Settings.SetOnValueChangedCallback(variable, func, initializer)
    return initializer
end
--[[
local initializer2= e.AddPanelCheck({
    name= ,
    tooltip= addName,
    category= Category,
    value= not Save.disabled,
    func= function()
    end
})
local initializer= e.AddPanelCheck({
})
initializer:SetParentInitializer(initializer2, function() return not Save.disabled end)
]]

--添加，按钮
function e.AddPanelButton(tab)
    local name= tab.name or ''
    local buttonText= tab.text
    local buttonClick= tab.func
    local tooltip= tab.tooltip
    local layout= tab.layout or Layout

    local initializer= CreateSettingsButtonInitializer(name, buttonText, buttonClick, tooltip)--Blizzard_SettingControls.lua
	layout:AddInitializer(initializer)
    return initializer
end
--[[
 e.AddPanelButton({
    name= nil,
    text= addName,
    layout= Layout,
    tooltip= nil,
    func= function()
    end
})
]]

--添加，Check 和 按钮
function e.AddPanelCheckButton(tab)
    local checkName = tab.checkName
    local defaultValue= tab.checkValue and true or false
    local checkFunc= tab.checkFunc

    local buttonText= tab.buttonText
    local buttonFunc= tab.buttonFunc

    local tooltip = tab.tooltip
    local layout= tab.layout or Layout
    local category= tab.category or Category

    local variable = id..checkName
    local setting= Settings.RegisterAddOnSetting(category, checkName, variable, type(defaultValue), defaultValue)
    --local initializer= CreateSettingsCheckBoxWithButtonInitializer(setting, buttonText, buttonFunc, false, tooltip)
    local initializer= CreateSettingsCheckBoxWithButtonInitializer(setting, buttonText, buttonFunc, checkFunc, tooltip)
    layout:AddInitializer(initializer)
    --Settings.SetOnValueChangedCallback(variable, checkFunc, initializer)
    return initializer
end

--[[
unction CreateSettingsCheckBoxWithButtonInitializer(setting, buttonText, buttonClick, clickRequiresSet, tooltip)
	local data = Settings.CreateSettingInitializerData(setting, nil, tooltip);
	data.buttonText = buttonText;
	data.OnButtonClick = buttonClick;
	data.clickRequiresSet = clickRequiresSet;
	return Settings.CreateSettingInitializer("SettingsCheckBoxWithButtonControlTemplate", data);
end
]]

--[[
local initializer2= e.AddPanelCheckButton({
    checkName= addName,
    checkValue= not Save.disabled,
    checkFunc= function()
    end,
    buttonText= '',
    buttonFunc= function()
    end,
    tooltip= addName,
    layout= Layout,
    category= Category
})
]]

function e.AddPanelDropDown(tab)
    local SetValue= tab.SetValueFunc
    local GetOptions= tab.GetOptionsFunc
    local defaultValue= tab.value
    local name= tab.name
    local tootip= tab.tooltip
    local category= tab.category or Category

    local variable= id..name
    local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaultValue), defaultValue)
    local initializer= Settings.CreateDropDown(category, setting, GetOptions, tootip)
    Settings.SetOnValueChangedCallback(variable, SetValue)
    return initializer
end
--[[
e.AddPanelDropDown({
    SetValueFunc= function(_, _, value)
    end,
    GetOptionsFunc= function()
        local container = Settings.CreateControlTextContainer()
        container:Add(1, e.onlyChinese and '职业' or CLASS)
        return container:GetData();
    end,
    value=,
    name=,
    tootip= addName,
    category=Category
})
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
    e.AddPanelHeader(nil, e.onlyChinese and '设置' or SETTINGS)

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

    e.AddPanelDropDown({
        SetValueFunc= function(_, _, value)
            if value==2 then
                local valueR, valueG, valueB, valueA= Save.useCustomColorTab.r, Save.useCustomColorTab.g, Save.useCustomColorTab.b, Save.useCustomColorTab.a
                local setA, setR, setG, setB
                local function func()
                    local hex=e.RGB_to_HEX(setR, setG, setB, setA)--RGB转HEX
                    Save.useCustomColorTab={r=setR, g=setG, b=setB, a=setA, hex= '|c'..hex }
                    set_Color()
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
                set_Color()
            end
            Save.useColor= value
            print(id, e.Player.useColor and e.Player.useColor.hex or '', (e.onlyChinese and '颜色' or COLOR)..'|r',   e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
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
        tootip= addName,
        category=Category
    })

    e.AddPanelCheck({
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
        e.AddPanelCheck({
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

    e.AddPanelButton({
        name= '|A:talents-button-undo:0:0|a'..(e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT),
        text= '|A:QuestArtifact:0:0|a'..(e.onlyChinese and '默认设置' or SETTINGS_DEFAULTS),
        func= function()
            StaticPopupDialogs[id..'RestAllSetup']={
                text = '|TInterface\\AddOns\\WoWTools\\Sesource\\Texture\\WoWtools.tga:0|t|cffff00ffWoW|r|cff00ff00Tools|r|n|n'..(e.onlyChinese and "你想要将所有选项重置为默认状态吗？|n将会立即对所有设置生效。" or CONFIRM_RESET_SETTINGS)
                    ..'|n|n|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '重新加载UI' or RELOADUI)..'|n|n'
                ,
                button1= '|cnRED_FONT_COLOR:'..(e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT),
                button2= e.onlyChinese and '取消' or CANCEL,
                whileDead=true,hideOnEscape = 1,
                OnAccept=function ()
                    e.ClearAllSave=true
                    e.Reload()
                end,
            }
            StaticPopup_Show(id..'RestAllSetup')
        end
    })

    e.AddPanelButton({
        name= e.Icon.wow2..(e.onlyChinese and '清除WoW数据' or 'Clear WoW data'),
        text= '|A:QuestArtifact:0:0|a'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2),
        func= function()
            StaticPopupDialogs[id..'RestWoWSetup']={
                text = '|TInterface\\AddOns\\WoWTools\\Sesource\\Texture\\WoWtools.tga:0|t|cffff00ffWoW|r|cff00ff00Tools|r'
                    ..'|n|n'..(e.Icon.wow2..(e.onlyChinese and '清除WoW数据' or 'Clear WoW data'))
                    ..'|n|n|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '重新加载UI' or RELOADUI)..'|n|n'
                ,
                button1= '|cnRED_FONT_COLOR:'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2),
                button2= e.onlyChinese and '取消' or CANCEL,
                whileDead=true,hideOnEscape = 1,
                OnAccept=function ()
                    e.ClearAllSave=true
                    e.Reload()
                end,
            }
            StaticPopup_Show(id..'RestWoWSetup')
        end
    })


    local btn= e.Cbtn(SettingsPanel, {type=false, size={140, 25}})
    btn:SetPoint('RIGHT', SettingsPanel.CloseButton, 'LEFT', -15,0)
    btn:SetText(e.onlyChinese and '重新加载UI' or RELOADUI)
    btn:SetScript("OnClick", e.Reload)
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

            e.onlyChinese= Save.onlyChinese

            Init()

            if e.onlyChinese or LOCALE_zhCN or LOCALE_zhTW then
                e.Player.LayerText= '位面'
            elseif LOCALE_koKR then
                e.Player.LayerText= '층'
            elseif LOCALE_frFR then
                e.Player.LayerText= 'Couche'
            elseif LOCALE_deDE then
                e.Player.LayerText= 'Schicht'
            elseif LOCALE_esES or LOCALE_esMX then
                e.Player.LayerText= 'Capa'
            elseif LOCALE_ruRU then
                e.Player.LayerText= 'слой'
            elseif LOCALE_ptBR then
                e.Player.LayerText= 'Camada'
            elseif LOCALE_itIT then
                e.Player.LayerText= 'Strato'
            end

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