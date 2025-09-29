 --显示选项中的CVar
--Blizzard_SettingControls.lua

        --[[local function set_onenter(self)
            if self.onEnter or not self.variable then
                return
            end
            self:HookScript('OnEnter', function(frame)
                if not frame.variable then
                    return
                end
                local value, defaultValue, _, _, _, isSecure = C_CVar.GetCVarInfo(frame.variable)
                GameTooltip_AddBlankLineToTooltip(SettingsTooltip)
                GameTooltip_AddNormalLine(SettingsTooltip,
                    HIGHLIGHT_FONT_COLOR:WrapTextInColorCode('CVar|cff00ff00'..WoWTools_DataMixin.Icon.right..frame.variable..'|r')
                    ..(value and ' ('..(value or '')..'/'..(defaultValue or '')..')' or ''),
                    true)
                if isSecure then
                    GameTooltip_AddNormalLine(SettingsTooltip, '|cnWARNING_FONT_COLOR:isSecure: true|r', true)
                end
                GameTooltip_AddNormalLine(SettingsTooltip, id.. ' '..addName)
                SettingsTooltip:Show()
            end)
            self:HookScript('OnMouseDown', function(frame, d)
                if d=='RightButton' and frame.variable then
                    e.Chat(frame.variable, nil, true)
                end
            end)
            self.onEnter=true
        end]]


local function Init()
    if not WoWToolsSave['Plus_Tootips'].ShowOptionsCVarTips then
        return
    end

    local function InitTooltip(name, tooltip, variable)
        GameTooltip_AddHighlightLine(SettingsTooltip, WoWTools_TextMixin:CN(name) or name)
        if tooltip then
            if type(tooltip) == "function" then
                GameTooltip_AddNormalLine(SettingsTooltip, tooltip())
            else
                GameTooltip_AddNormalLine(SettingsTooltip, WoWTools_TextMixin:CN(tooltip) or tooltip)
            end
        end
        if variable then
            local value, defaultValue, _, _, _, isSecure = C_CVar.GetCVarInfo(variable)
            GameTooltip_AddBlankLineToTooltip(SettingsTooltip)
            GameTooltip_AddNormalLine(SettingsTooltip,
                HIGHLIGHT_FONT_COLOR:WrapTextInColorCode('CVar |cff00ff00'..variable..'|r')
                ..(value and ' ('..(value or '')..'/'..(defaultValue or '')..')' or ''),
                true)
            if isSecure then
                GameTooltip_AddNormalLine(SettingsTooltip, '|cnWARNING_FONT_COLOR:isSecure: true|r', true)
            end
            GameTooltip_AddNormalLine(SettingsTooltip, WoWTools_DataMixin.Icon.icon2..WoWTools_TooltipMixin.addName)
        end
    end
    local function CreateOptionsInitTooltip(setting, name, tooltip, options, variable)--Blizzard_SettingControls.lua
        local initTooltip= function()
            InitTooltip(name, tooltip, variable)
            local optionData = type(options) == 'function' and options() or options
            local default2 = setting:GetDefaultValue()
            local warningOption = nil
            local defaultOption = nil
            for _, option in ipairs(optionData or {}) do
                local default = option.value == default2
                if default then
                    defaultOption = option
                end
                if option.warning then
                    warningOption = option
                end
                if option.tooltip or option.disabled then
                    GameTooltip_AddBlankLineToTooltip(SettingsTooltip)
                    if option.label then
                        local optionLabel= WoWTools_TextMixin:CN(option.label) or option.label
                        if option.disabled then
                            optionLabel = DISABLED_FONT_COLOR:WrapTextInColorCode(optionLabel)
                        else
                            optionLabel = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(optionLabel)
                        end
                        local optionTooltip= option.tooltip
                        if optionTooltip then
                            optionTooltip= WoWTools_TextMixin:CN(optionTooltip) or optionTooltip
                            if option.disabled then
                                optionTooltip = DISABLED_FONT_COLOR:WrapTextInColorCode(optionTooltip)
                            elseif default and option.recommend then
                                optionTooltip = GREEN_FONT_COLOR:WrapTextInColorCode(optionTooltip)
                            else
                                optionTooltip = NORMAL_FONT_COLOR:WrapTextInColorCode(optionTooltip)
                            end
                            GameTooltip_AddDisabledLine(SettingsTooltip, string.format("%s: %s", optionLabel, optionTooltip))
                        else
                            GameTooltip_AddDisabledLine(SettingsTooltip, string.format("%s:", optionLabel))
                        end
                    end
                    if option.disabled then
                        GameTooltip_AddErrorLine(SettingsTooltip, option.disabled)
                    end
                end
            end
            if defaultOption and defaultOption.recommend and defaultOption.label then
                GameTooltip_AddBlankLineToTooltip(SettingsTooltip)
                local label= WoWTools_TextMixin:CN(defaultOption.label) or defaultOption.label
                GameTooltip_AddHighlightLine(SettingsTooltip, string.format("%s: %s", WoWTools_DataMixin.onlyChinese and '推荐' or VIDEO_OPTIONS_RECOMMENDED, GREEN_FONT_COLOR:WrapTextInColorCode(label)))
            end

            if warningOption and warningOption.value == setting:GetValue() and warningOption.warning then
                GameTooltip_AddBlankLineToTooltip(SettingsTooltip)
                local warning= WoWTools_TextMixin:CN(warningOption.warning) or warningOption.warning
                GameTooltip_AddNormalLine(SettingsTooltip, WARNING_FONT_COLOR:WrapTextInColorCode(warning))
            end

            if setting:HasCommitFlag(Settings.CommitFlag.ClientRestart) then
                GameTooltip_AddBlankLineToTooltip(SettingsTooltip)
                GameTooltip_AddErrorLine(SettingsTooltip, WoWTools_DataMixin.onlyChinese and '更改此选项需要重新启动客户端' or VIDEO_OPTIONS_NEED_CLIENTRESTART)
            end
        end
        return initTooltip
    end


    --[[WoWTools_DataMixin:Hook(SettingsCheckBoxControlMixin, 'Init', function(self, initializer)
        if self:IsProtected() and InCombatLockdown() or issecure() then
            return
        end

        local setting = initializer.data.setting
        local initTooltip= GenerateClosure(InitTooltip, initializer:GetName(), initializer:GetTooltip(), setting.variable)
        self:SetTooltipFunc(initTooltip)
        self.CheckBox:SetTooltipFunc(initTooltip)
    end)]]
    WoWTools_DataMixin:Hook(SettingsSliderControlMixin, 'Init', function(self, initializer)
        if self:IsProtected() and InCombatLockdown() or issecure() then
            return
        end
        --[[self.SliderWithSteppers.Slider.variable= initializer.data.setting.variable
        set_onenter(self.SliderWithSteppers.Slider)]]
        local setting = initializer.data.setting
        local initTooltip= GenerateClosure(InitTooltip, initializer:GetName(), initializer:GetTooltip(), setting.variable)
        self:SetTooltipFunc(initTooltip)
        self.SliderWithSteppers.Slider:SetTooltipFunc(initTooltip)
    end)
    WoWTools_DataMixin:Hook(SettingsDropDownControlMixin, 'Init', function(self, initializer)
        if self:IsProtected() and InCombatLockdown() or issecure() then
            return
        end
        --[[self.DropDown.Button.variable= initializer.data.setting.variable
        set_onenter(self.DropDown.Button)]]
        local setting = self:GetSetting()
        local options = initializer:GetOptions()
        local initTooltip= GenerateClosure(InitTooltip, initializer:GetName(), initializer:GetTooltip(), setting.variable)
        self:SetTooltipFunc(initTooltip)

        initTooltip = GenerateClosure(CreateOptionsInitTooltip(setting, initializer:GetName(), initializer:GetTooltip(), options, setting.variable))
        self.DropDown.Button:SetTooltipFunc(initTooltip)
    end)
    WoWTools_DataMixin:Hook(SettingsCheckBoxWithButtonControlMixin, 'Init', function(self, initializer)
        if self:IsProtected() and InCombatLockdown() or issecure() then
            return
        end
        --[[self.CheckBox.variable= initializer.data.setting.variable
        set_onenter(self.CheckBox)]]
        local setting = initializer:GetSetting()
        local initTooltip= GenerateClosure(InitTooltip, initializer:GetName(), initializer:GetTooltip(), setting.variable)
        self:SetTooltipFunc(initTooltip)
        self.CheckBox:SetTooltipFunc(initTooltip)
    end)
    WoWTools_DataMixin:Hook(SettingsCheckBoxSliderControlMixin, 'Init', function(self, initializer)--Blizzard_SettingControls.lua
        if self:IsProtected() and InCombatLockdown() or issecure() then
            return
        end
    --[[self.CheckBox.variable= initializer.data.cbSetting.variable
        set_onenter(self.CheckBox)
        self.SliderWithSteppers.Slider.variable= initializer.data.sliderSetting.variable
        set_onenter(self.SliderWithSteppers.Slider)]]
        local cbSetting = initializer.data.cbSetting
        local cbLabel = initializer.data.cbLabel
        local cbTooltip = initializer.data.cbTooltip
        local sliderLabel = initializer.data.sliderLabel
        local sliderTooltip = initializer.data.sliderTooltip
        local cbInitTooltip = GenerateClosure(InitTooltip, cbLabel, cbTooltip, cbSetting.variable)
        self:SetTooltipFunc(cbInitTooltip)
        self.CheckBox:SetTooltipFunc(cbInitTooltip)
        self.SliderWithSteppers.Slider:SetTooltipFunc(GenerateClosure(InitTooltip, sliderLabel, sliderTooltip, cbSetting.variable))
    end)
    WoWTools_DataMixin:Hook(SettingsCheckBoxDropDownControlMixin, 'Init', function(self, initializer)--Blizzard_SettingControls.lua
        if self:IsProtected() and InCombatLockdown() or issecure() then
            return
        end
        --[[self.CheckBox.variable= initializer.data.cbSetting.variable
        set_onenter(self.CheckBox)
        self.DropDown.Button.variable= initializer.data.dropDownSetting.variable
        set_onenter(self.DropDown.Button)]]
        local cbSetting = initializer.data.cbSetting
        local cbLabel = initializer.data.cbLabel
        local cbTooltip = initializer.data.cbTooltip
        local initTooltip= GenerateClosure(InitTooltip, cbLabel, cbTooltip, cbSetting.variable)
        self:SetTooltipFunc(initTooltip)
        self.CheckBox:SetTooltipFunc(initTooltip)

        local setting = initializer.data.dropDownSetting
        local options = initializer.data.dropDownOptions
        initTooltip = GenerateClosure(CreateOptionsInitTooltip(setting, initializer:GetName(), initializer:GetTooltip(), options, setting.variable))
        self.DropDown.Button:SetTooltipFunc(initTooltip)
    end)

    WoWTools_DataMixin:Hook(KeyBindingFrameBindingTemplateMixin, 'Init', function(self, initializer)--Blizzard_Keybindings.lua
        if self:IsProtected() and InCombatLockdown() or issecure() then
            return
        end
        local bindingIndex = initializer.data.bindingIndex
        local action, category = GetBinding(bindingIndex)
        local bindingName = GetBindingName(action)
        bindingName= WoWTools_TextMixin:CN(bindingName) or bindingName
        local function InitializeKeyBindingButtonTooltip(index)
            local key = select(index, GetBindingKey(action))
            if key then
                Settings.InitTooltip(format(KEY_BINDING_NAME_AND_KEY, bindingName, GetBindingText(key)), WoWTools_DataMixin.onlyChinese and '<右键解除键位>' or KEY_BINDING_TOOLTIP)
            end
            GameTooltip_AddNormalLine(SettingsTooltip, 'bindingIndex |cnGREEN_FONT_COLOR:'..bindingIndex..'|r', true)
            GameTooltip_AddNormalLine(SettingsTooltip, 'action |cnGREEN_FONT_COLOR:'..action..'|r', true)
            if category then
                GameTooltip_AddNormalLine(SettingsTooltip, category, true)
            end
            GameTooltip_AddNormalLine(SettingsTooltip, WoWTools_DataMixin.Icon.icon2..WoWTools_TooltipMixin.addName, true)
        end

        for index, button in ipairs(self.Buttons) do
            button:SetTooltipFunc(GenerateClosure(InitializeKeyBindingButtonTooltip, index))
        end
    end)
    return true
end














function WoWTools_TooltipMixin:Init_CVar_Value()
    if Init() then
        Init=function()end
        return true
    end
end