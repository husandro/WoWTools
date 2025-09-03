--插件名称
local Category, Layout = Settings.RegisterVerticalLayoutCategory('|TInterface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools.tga:0|t|cffff00ffWoW|r|cff00ff00Tools|r')
Settings.RegisterAddOnCategory(Category)

WoWTools_PanelMixin={}
--[[
WoWTools_PanelMixin:ReloadButton(tab)
WoWTools_PanelMixin:Slider(frame, {w=, h=, min=, max=, value=, setp=, color=, text=, func=clickfunc, tips=func})
WoWTools_PanelMixin:Open(category, name)
WoWTools_PanelMixin:AddSubCategory(tab)
WoWTools_PanelMixin:Header(layout, title)
WoWTools_PanelMixin:OnlyCheck(tab, root)
WoWTools_PanelMixin:OnlyButton(tab)
WoWTools_PanelMixin:OnlyMenu(tab)
WoWTools_PanelMixin:CheckMenu(tab, root)
WoWTools_PanelMixin:Check_Button(tab)
WoWTools_DataMixin:Check_Slider(tab)
WoWTools_DataMixin:OnlySlider(tab)


sub:AddSearchTags(bindingName)

local action = "INTERACTTARGET";
local bindingIndex = C_KeyBindings.GetBindingIndex(action);
local sub = CreateKeybindingEntryInitializer(bindingIndex, true);
sub:AddSearchTags(GetBindingName(action));
layout:AddInitializer(sub);


Settings.RegisterProxySetting(categoryTbl, variable, variableType, name, defaultValue, getValue, setValue)
Settings.RegisterProxySetting(category, "PROXY_MINIMUM_CHARACTER_NAME_SIZE", Settings.VarType.Number, MINIMUM_CHARACTER_NAME_SIZE_TEXT, 0, GetValue, SetValue)

]]










--#####################
--重新加载UI, 重置, 按钮
--#####################
function WoWTools_PanelMixin:ReloadButton(tab)
    local rest= WoWTools_ButtonMixin:Cbtn(tab.panel, {isUI=true, size=25})
    rest:SetNormalAtlas('bags-button-autosort-up')
    rest:SetPushedAtlas('bags-button-autosort-down')
    rest:SetPoint('TOPRIGHT',0,8)
    rest.addName=tab.addName
    rest.func=tab.clearfunc
    rest.clearTips=tab.clearTips
    rest:SetScript('OnClick', function(frame)
        StaticPopup_Show('WoWTools_RestData',
        (frame.addName or '')..'|n|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)..'|r',
        nil, frame.func)
    end)
    rest:SetScript('OnLeave', GameTooltip_Hide)
    rest:SetScript('OnEnter', function(frame)
        GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(frame.clearTips or (WoWTools_DataMixin.onlyChinese and '当前保存' or (ITEM_UPGRADE_CURRENT..SAVE)))
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, frame.addName)
        GameTooltip:Show()
    end)

    local reload
    if tab.reload then
        reload= WoWTools_ButtonMixin:Cbtn(tab.panel, {isUI=true, size=25})
        reload:SetNormalTexture('Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up')
        reload:SetPushedTexture('Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down')
        reload:SetPoint('TOPLEFT',-12, 8)
        reload:SetScript('OnClick', function() WoWTools_DataMixin:Reload() end)
        reload.addName=tab.addName
        reload:SetScript('OnLeave', GameTooltip_Hide)
        reload:SetScript('OnEnter', function(frame)
            GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, frame.addName)
            GameTooltip:Show()
        end)
    end
    if tab.disabledfunc then
        
        local check=WoWTools_ButtonMixin:Cbtn(tab.panel, {
            isCheck=true,
            text=WoWTools_TextMixin:GetEnabeleDisable(true),
            isRightText=true,
        })
        --check.Text:SetText(WoWTools_TextMixin:GetEnabeleDisable(true))
        check:SetChecked(tab.checked)
        if reload then
            check:SetPoint('LEFT', reload, 'RIGHT')
        else
            check:SetPoint('TOPLEFT',-12, 8)
        end
        check:SetScript('OnClick', tab.disabledfunc)
        check:SetScript('OnLeave', GameTooltip_Hide)
        check.addName= tab.addName
        check:SetScript('OnEnter', function(frame)
            GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '启用/禁用' or (ENABLE..'/'..DISABLE))
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, frame.addName)
            GameTooltip:Show()
        end)
    end
    if tab.restTips then
        local needReload= WoWTools_LabelMixin:Create(tab.panel)
        needReload:SetText(format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toRight)..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)..format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toLeft))
        needReload:SetPoint('BOTTOMRIGHT')
        needReload:SetTextColor(0,1,0)
    end
end





function WoWTools_PanelMixin:Slider(frame, tab)--WoWTools_PanelMixin:Slider(frame, {w=, h=, min=, max=, value=, setp=, color=, text=, func=clickfunc, tips=func})
    local slider= CreateFrame("Slider", nil, frame, 'OptionsSliderTemplate')
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
    slider:SetScript('OnMouseWheel', function(f, d)
        local setp= f:GetValueStep() or 1
        local value= f:GetValue()
        if d== 1 then
            value= value- setp
        elseif d==-1 then
            value= value+ setp
        end
        value= value> f.max and f.max or value
        value= value< f.min and f.min or value
        f:SetValue(value)
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
        slider:SetScript('OnEnter', function(f)
            GameTooltip:SetOwner(f, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(tab.text)
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine('|A:UI-HUD-MicroMenu-StreamDLRed-Up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '最小' or MINIMUM)..': '..tab.min)
            GameTooltip:AddLine('|A:bags-greenarrow:0:0|a'..(WoWTools_DataMixin.onlyChinese and '最大' or MAXIMUM)..': '..tab.max)
            GameTooltip:AddLine('Setp: '..tab.setp)
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine(format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toRight)..(WoWTools_DataMixin.onlyChinese and '当前: ' or ITEM_UPGRADE_CURRENT)..f:GetValue())
            GameTooltip:Show()
        end)
    end
    return slider
end


























C_CVar.GetCVar('WoWToolsPanelVariable1') 







--##############
--创建, 添加控制面板


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
function WoWTools_PanelMixin:Open(category, name)
    if WoWTools_FrameMixin:IsLocked(SettingsPanel) then
        return
    end
    category= (category and category.GetID) and category or Category
    Category.expanded=true
    name= name or (category and category.GetName and category:GetName())
    Settings.OpenToCategory(category:GetID(), name)
end


--添加，子目录
function WoWTools_PanelMixin:AddSubCategory(tab)
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
function WoWTools_PanelMixin:Header(layout, title)
    layout= layout or Layout
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(title))
end

--Settings.RegisterProxySetting(categoryTbl, variable, variableType, name, defaultValue, getValue, setValue)


--添加，Check
function WoWTools_PanelMixin:OnlyCheck(tab, root)
    local setting=Settings.RegisterProxySetting(
        tab.category or Category,
        Set_VariableIndex(),
        Settings.VarType.Boolean,
        tab.name,
        tab.GetValue() or tab.value,
        tab.GetValue,
        tab.SetValue or tab.func
    )
    local sub= Settings.CreateCheckbox(tab.category or Category, setting, tab.tooltip)

    if root then
        sub:SetParentInitializer(root)
    end
    return sub
end


--添加，按钮
--CreateSettingsButtonInitializer(name, buttonText, buttonClick, tooltip, addSearchTags)
function WoWTools_PanelMixin:OnlyButton(tab, root)
    local layout= tab.layout or Layout
    local sub= CreateSettingsButtonInitializer(--Blizzard_SettingControls.lua
        tab.title or '',
        tab.buttonText or '',
        tab.SetValue,
        tab.tooltip or tab.buttonText or tab.title or nil,
        Set_SearchTags_Text(tab.addSearchTags or tab.title or tab.buttonText)
    )
    layout:AddInitializer(sub)

    if root then
        sub:SetParentInitializer(root)
    end

    return sub
end
--[[
WoWTools_PanelMixin:OnlyButton({
    title= WoWTools_DataMixin.onlyChinese and '' or '',
    buttonText=WoWTools_DataMixin.onlyChinese and '' or '',
    SetValue=function()
    end,
    tooltip=nil,
    addSearchTags=nil,
}, sub)
]]


--添加，下拉菜单
function WoWTools_PanelMixin:OnlyMenu(tab, root)
    local setting= Settings.RegisterProxySetting(--categoryTbl, variable, variableType, name, defaultValue, getValue, setValue
        tab.category or Category,
        Set_VariableIndex(),
        Settings.VarType.Number,
        tab.name,
        tab.GetValue(),
        tab.GetValue,
        tab.SetValue or tab.func
    )

    local sub= Settings.CreateDropdown(--setting, options, tooltip
        tab.category or Category,
        setting,
        tab.GetOptions,
        tab.tooltip
    )

    if root then
        sub:SetParentInitializer(root)
    end

    return sub
end

--Blizzard_SettingControls.lua
--CreateSettingsCheckboxDropdownInitializer(cbSetting, cbLabel, cbTooltip, dropdownSetting, dropdownOptions, dropDownLabel, dropDownTooltip)
function WoWTools_PanelMixin:CheckMenu(tab, root)
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
	local sub= Settings.CreateSettingInitializer("SettingsCheckboxDropdownControlTemplate", data)
    layout:AddInitializer(sub)

    if root then
        sub:SetParentInitializer(root)
    end

    return sub
end
--[[
WoWTools_PanelMixin:CheckMenu({
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
    container:Add(1, WoWTools_DataMixin.onlyChinese and '位于上方' or QUESTLINE_LOCATED_ABOVE)
    container:Add(2, WoWTools_DataMixin.onlyChinese and '位于下方' or QUESTLINE_LOCATED_BELOW)
    return container:GetData()
end
})
]]






--添加，Check 和 按钮
function WoWTools_PanelMixin:Check_Button(tab, root)
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
    local sub= CreateSettingsCheckboxWithButtonInitializer(
        checkSetting,
        tab.buttonText,
        tab.buttonFunc,
        true,
        tab.tooltip
    )
    layout:AddInitializer(sub)

    if root then
        sub:SetParentInitializer(root)
    end
    return sub
end









function WoWTools_DataMixin:Check_Slider(tab, root)
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
       return WoWTools_DataMixin:GetFormatter1to10(value or 1, 0, 1)
    end)

    local sub = CreateSettingsCheckboxSliderInitializer(
        checkSetting,
        tab.checkName,
        tab.checkTooltip or tab.tooltip,

        sliderSetting,
        options,
        tab.sliderName or tab.checkName,
        tab.siderTooltip or tab.checkTooltip or tab.tooltip
    )

    Settings.SetOnValueChangedCallback(sliderSetting:GetVariable(), tab.sliderSetValue)
    layout:AddInitializer(sub)

    if root then
        sub:SetParentInitializer(root)
    end
    return sub
end



--添加，划动条
function WoWTools_DataMixin:OnlySlider(tab, root)
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
        return WoWTools_DataMixin:GetFormatter1to10(value or 1, 0, 1)
    end)

    local sub=Settings.CreateSlider(tab.category or Category, setting, options, tab.tooltip);
    Settings.SetOnValueChangedCallback(setting:GetVariable(), tab.SetValue)

    if root then
        sub:SetParentInitializer(root)
    end

    return sub
end


















--[[
function  e.Add_Panel_RestData_Button(root, SetValue)
    if not StaticPopupDialogs['WoWTools_Rest_DaTa'] then
        StaticPopupDialogs['WoWTools_Rest_DaTa']={--重置所有,清除全部玩具
            text=id..' '..addName..'|n'..(WoWTools_DataMixin.onlyChinese and '清除全部' or CLEAR_ALL)..'|n|n'..(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI),
            whileDead=true, hideOnEscape=true, exclusive=true,
            button1='|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '重置' or RESET)..'|r',
            button2= WoWTools_DataMixin.onlyChinese and '取消' or CANCEL,
            OnAccept = function(_, setValue)
                setValue()
                WoWTools_DataMixin:Reload()
            end,
        }
    end
end

]]






























