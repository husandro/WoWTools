local id, e = ...
local addName= 'Panel Settings'
local Save={
    onlyChinese= LOCALE_zhCN or e.Player.husandro,
    --useClassColor= e.Player.husandro,--使用,职业, 颜色
    --useCustomColor= nil,--使用, 自定义, 颜色
    useColor=1,
    useCustomColorTab= {r=1, g=0.82, b=0, a=1, hex='|cffffd100'},--自定义, 颜色, 表
}



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
        e.tips:AddDoubleLine(e.addName, self.addName)
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
            e.tips:AddDoubleLine(e.addName, self.addName)
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
            e.tips:AddDoubleLine(e.addName, self.addName)
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

--插件名称
local Category, Layout = Settings.RegisterVerticalLayoutCategory('|TInterface\\AddOns\\WoWTools\\Sesource\\Texture\\WoWtools.tga:0|t|cffff00ffWoW|r|cff00ff00Tools|r')
Settings.RegisterAddOnCategory(Category)


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






--Settings.RegisterProxySetting(categoryTbl, variable, variableType, name, defaultValue, getValue, setValue)



--添加，Check
function e.AddPanel_Check(tab, parentInitializer)
    local setting=Settings.RegisterProxySetting(
        tab.category or Category,
        Set_VariableIndex(),
        Settings.VarType.Boolean,
        tab.name,
        tab.value or tab.GetValue(),
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
        SetValue= function()
            StaticPopup_Show('WoWTools_RestData',
                (e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT)..'|n|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '重新加载UI' or RELOADUI)..'|r',
                nil,
                function()
                    e.ClearAllSave=true
                    WoWTools_Mixin:Reload()
                end
            )
        end
    })

    e.AddPanel_Button({
        title= e.Icon.wow2..(e.onlyChinese and '清除WoW数据' or 'Clear WoW data'),
        buttonText= '|A:QuestArtifact:0:0|a'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2),
        addSearchTags= e.onlyChinese and '清除WoW数据' or 'Clear WoW data',
        SetValue= function()
            StaticPopup_Show('WoWTools_RestData',
                (e.Icon.wow2..(e.onlyChinese and '清除WoW数据' or 'Clear WoW data'))..'|n|n|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '重新加载UI' or RELOADUI)..'|r',
                nil,
                function()
                    e.WoWDate={}
                    WoWTools_Mixin:Reload()
                end
            )
        end
    })








    e.AddPanel_DropDown({
        SetValue= function(value)
            if value==2 then
                local valueR, valueG, valueB, valueA= Save.useCustomColorTab.r, Save.useCustomColorTab.g, Save.useCustomColorTab.b, Save.useCustomColorTab.a
                local setA, setR, setG, setB
                local function func()
                    local hex=WoWTools_ColorMixin:RGBtoHEX(setR, setG, setB, setA)--RGB转HEX
                    Save.useCustomColorTab={r=setR, g=setG, b=setB, a=setA, hex= '|c'..hex }
                    Set_Color()--自定义，颜色
                    print(e.Player.useColor and e.Player.useColor.hex or '', id, e.cn(addName),   e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
                WoWTools_ColorMixin:ShowColorFrame(valueR, valueG, valueB, valueA, function()
                        setR, setG, setB, setA= WoWTools_ColorMixin:Get_ColorFrameRGBA()
                        func()
                    end, function()
                        setR, setG, setB, setA= valueR, valueG, valueB, valueA
                        func()
                    end
                )
            else
                if ColorPickerFrame:IsShown() then
                    ColorPickerFrame.Footer.OkayButton:Click()
                end
                Set_Color()--自定义，颜色
                print(e.addName, e.Player.useColor and e.Player.useColor.hex or '', (e.onlyChinese and '颜色' or COLOR)..'|r',   e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
            Save.useColor= value

        end,
        GetOptions= function()
            local container = Settings.CreateControlTextContainer()
			container:Add(1, e.onlyChinese and '职业' or CLASS)
			container:Add(2, e.onlyChinese and '自定义' or CUSTOM)
			container:Add(3, e.onlyChinese and '无' or NONE)
			return container:GetData();
        end,
        GetValue= function() return Save.useColor end,
        name= (e.Player.useColor and e.Player.useColor.hex or '')..(e.onlyChinese and '颜色' or COLOR),
        tooltip= e.cn(addName),
        category=Category
    })


    if not LOCALE_zhCN then
        e.AddPanel_Check({
            name= 'Chinese ',
            tooltip= e.onlyChinese and '语言: 简体中文'
                    or (LANGUAGE..': '..LFG_LIST_LANGUAGE_ZHCN),
            category=Category,
            Value= Save.onlyChinese,
            GetValue= function() return Save.onlyChinese end,
            SetValue= function()
                e.onlyChinese= not e.onlyChinese and true or nil
                Save.onlyChinese = e.onlyChinese
                print(e.addName,  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        })
    end

    if e.Player.region==1 or e.Player.region==3 then--US EU realm提示
        local function get_tooltip(tooltip)
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
            Value= not Save.disabledRealm,
            GetValue= function() return not Save.disabledRealm end,
            SetValue= function()
                Save.disabledRealm= not Save.disabledRealm and true or nil
                print(e.addName,  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        })

        if Save.disabledRealm then
            e.Get_Region(nil, nil, nil, true)
            e.Get_Region=function() end
        end
    end
    e.AddPanel_Header(nil, 'Plus')
end












local function Init()
    e.StausText={
        [ITEM_MOD_HASTE_RATING_SHORT]= e.onlyChinese and '急' or WoWTools_TextMixin:sub(STAT_HASTE, 1, 2, true),
        [ITEM_MOD_CRIT_RATING_SHORT]= e.onlyChinese and '爆' or WoWTools_TextMixin:sub(STAT_CRITICAL_STRIKE, 1, 2, true),
        [ITEM_MOD_MASTERY_RATING_SHORT]= e.onlyChinese and '精' or WoWTools_TextMixin:sub(STAT_MASTERY, 1, 2, true),
        [ITEM_MOD_VERSATILITY]= e.onlyChinese and '全' or WoWTools_TextMixin:sub(STAT_VERSATILITY, 1, 2, true),
        [ITEM_MOD_CR_AVOIDANCE_SHORT]= e.onlyChinese and '闪' or WoWTools_TextMixin:sub(STAT_AVOIDANCE, 1, 2, true),
        [ITEM_MOD_CR_LIFESTEAL_SHORT]= e.onlyChinese and '吸' or WoWTools_TextMixin:sub(STAT_LIFESTEAL, 1, 2, true),
        [ITEM_MOD_CR_SPEED_SHORT]=e.onlyChinese and '速' or WoWTools_TextMixin:sub(SPEED, 1,2,true),
        --[ITEM_MOD_EXTRA_ARMOR_SHORT]= e.onlyChinese and '护' or WoWTools_TextMixin:sub(ARMOR, 1,2,true)
    }
end









local panel = CreateFrame("Frame")
panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1==id then
            e.Is_Timerunning= PlayerGetTimerunningSeasonID()


            WoWToolsSave= WoWToolsSave or {}
            --e.WoWDate= e.WoWDate or e.WoWDate or {}

            Save= WoWToolsSave[addName] or Save
            Save.useColor= Save.useColor or 1
            Save.useCustomColorTab= Save.useCustomColorTab or {r=1, g=0.82, b=0, a=1, hex='|cffffd100'}
            Set_Color()--自定义，颜色

            e.onlyChinese= LOCALE_zhCN or Save.onlyChinese

            if e.onlyChinese then
                e.Player.L= {
                    layer='位面',
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

            self:UnregisterEvent('ADDON_LOADED')

            C_Timer.After(2, function()
                e.Is_Timerunning= PlayerGetTimerunningSeasonID()
            end)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)