
local id, e = ...
local addName= '|A:newplayertutorial-drag-cursor:0:0|aTooltips'
local Initializer, Layout= e.AddPanel_Sub_Category({name=addName})

WoWTools_TooltipMixin={
    Save={
        setDefaultAnchor=true,--指定点
        --AnchorPoint={},--指定点，位置
        --cursorRight=nil,--'ANCHOR_CURSOR_RIGHT',

        setCVar=e.Player.husandro,
        ShowOptionsCVarTips=e.Player.husandro,--显示选项中的CVar
        inCombatDefaultAnchor=true,
        ctrl= e.Player.husandro,--取得网页，数据链接

        --模型
        modelSize=100,--大小
        --modelLeft=true,--左边
        modelX= 0,
        modelY= -15,
        modelFacing= -0.3,--方向
        showModelFileID=e.Player.husandro,--显示，文件ID
        --WidgetSetID=848,--自定义，监视 WidgetSetID
        --disabledNPCcolor=true,--禁用NPC颜色
        --hideHealth=true,----生命条提示
    },
    addName=addName,
    Initializer=Initializer,
    Layout=Layout,
    WoWHead= 'https://www.wowhead.com/',
    AddOn={},
}









local function Save()
    return WoWTools_TooltipMixin.Save
end

local function Load_Addon(name, isLoaddedName)
    if isLoaddedName then
        if C_AddOns.IsAddOnLoaded(isLoaddedName) then
            name= isLoaddedName
        end
    end
    if name and WoWTools_TooltipMixin.AddOn[name] and not Save().disabled then
        WoWTools_TooltipMixin.AddOn[name]()
    end
end
















--设置，宽度
function WoWTools_TooltipMixin:Set_Width(tooltip)
    local w= tooltip:GetWidth()
    local w2= tooltip.textLeft:GetStringWidth()+ tooltip.text2Left:GetStringWidth()+ tooltip.textRight:GetStringWidth()
    if w<w2 then
        tooltip:SetMinimumWidth(w2)
    end
end


--设置单位
function WoWTools_TooltipMixin:Set_Unit(tooltip)--设置单位提示信息
    local name, unit, guid= TooltipUtil.GetDisplayedUnit(tooltip)
    if not name or not UnitExists(unit) or not guid then
        return
    end
    if UnitIsPlayer(unit) then
        WoWTools_TooltipMixin:Set_Unit_Player(tooltip, name, unit, guid)

    elseif (UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then--宠物TargetFrame.lua
        WoWTools_TooltipMixin:Set_Pet(tooltip, UnitBattlePetSpeciesID(unit), true)

    else
        WoWTools_TooltipMixin:Set_Unit_NPC(tooltip, name, unit, guid)
    end
end












--初始
local function Init()
    WoWTools_TooltipMixin:Init_StatusBar()--生命条提示
    WoWTools_TooltipMixin:Init_Hook()
    WoWTools_TooltipMixin:Init_BattlePet()
    WoWTools_TooltipMixin:Init_Settings()
    WoWTools_TooltipMixin:Init_SetPoint()
    WoWTools_TooltipMixin:Init_CVar()
end














--加载保存数据
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if WoWToolsSave['Tootips'] then
                WoWTools_TooltipMixin.Save= WoWToolsSave['Tootips']
                WoWToolsSave['Tootips']=nil
            else
                WoWTools_TooltipMixin.Save= WoWToolsSave['Plus_Tootips'] or WoWTools_TooltipMixin.Save
            end

            --Save().WidgetSetID = Save().WidgetSetID or 0



            e.AddPanel_Check({
                name= addName,
                tooltip= addName,
                GetValue= function() return not Save().disabled end,
                category= Initializer,
                func= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(e.addName, addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            WoWTools_TooltipMixin:Init_WoWHeadText()

            if not Save().disabled then
                self:RegisterEvent('PLAYER_LEAVING_WORLD')
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
                Init()--初始

                for _, name in pairs(
                    {
                     'Blizzard_AchievementUI',
                     'Blizzard_Collections',
                     'Blizzard_ChallengesUI',
                     'Blizzard_OrderHallUI',
                     'Blizzard_FlightMap',
                     'Blizzard_Professions',
                     'Blizzard_ClassTalentUI',
                     'Blizzard_PlayerChoice',
                     'Blizzard_GenericTraitUI',
                     'Blizzard_Settings',
                    }
                )do
                    Load_Addon(nil, name)
                end
            else
                self:UnregisterEvent('ADDON_LOADED')
            end

        else
            Load_Addon(arg1)
        end


    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_Tootips']= WoWTools_TooltipMixin.Save
        end

    elseif event=='PLAYER_LEAVING_WORLD' then
        if Save().setCVar then
            if not UnitAffectingCombat('player') then
                Save().graphicsViewDistance= C_CVar.GetCVar('graphicsViewDistance')
                SetCVar("graphicsViewDistance", 0)
            else
                Save().graphicsViewDistance=nil
            end
        end

    elseif event=='PLAYER_ENTERING_WORLD' then--https://wago.io/ZtSxpza28
        if Save().setCVar and Save().graphicsViewDistance and not UnitAffectingCombat('player') then
            C_CVar.SetCVar('graphicsViewDistance', Save().graphicsViewDistance)
            Save().graphicsViewDistance=nil
        end
    end
end)


    --[[TooltipDataRules.lua 
    Enum.TooltipDataType = {
		Item = 0,
		Spell = 1,
		Unit = 2,
		Corpse = 3,
		Object = 4,
		Currency = 5,
		BattlePet = 6,
		UnitAura = 7,
		AzeriteEssence = 8,
		CompanionPet = 9,
		Mount = 10,
		PetAction = 11,
		Achievement = 12,
		EnhancedConduit = 13,
		EquipmentSet = 14,
		InstanceLock = 15,
		PvPBrawl = 16,
		RecipeRankInfo = 17,
		Totem = 18,
		Toy = 19,
		CorruptionCleanser = 20,
		MinimapMouseover = 21,
		Flyout = 22,
		Quest = 23,
		QuestPartyProgress = 24,
		Macro = 25,
		Debug = 26,
	},
    TooltipDataProcessor.AllTypes
    Blizzard_SharedXMLGame/Tooltip/TooltipDataRules.lua
追踪栏
    hooksecurefunc('BonusObjectiveTracker_OnBlockEnter', function(block)
        if block.id and not block.module.tooltipBlock and block.TrackedQuest then
            e.tips:SetOwner(block, "ANCHOR_LEFT")
            e.tips:ClearLines()
            GameTooltip_AddQuest(block.TrackedQuest or block, block.id)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.addName, addName)
            e.tips:Show()
        end
    end)]]

    --显示选项中的CVar 11版本
    --[[Blizzard_SettingControls.lua
    if Save().ShowOptionsCVarTips then
        local function InitTooltip(name, tooltip, variable)
            GameTooltip_AddHighlightLine(SettingsTooltip, e.strText[name] or name)
            if tooltip then
                if type(tooltip) == "function" then
                    GameTooltip_AddNormalLine(SettingsTooltip, tooltip())
                else
                    GameTooltip_AddNormalLine(SettingsTooltip, e.strText[tooltip] or tooltip)
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
                    GameTooltip_AddNormalLine(SettingsTooltip, '|cnRED_FONT_COLOR:isSecure: true|r', true)
                end
                GameTooltip_AddNormalLine(SettingsTooltip, id..addName)
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
                            local optionLabel= e.strText[option.label] or option.label
                            if option.disabled then
                                optionLabel = DISABLED_FONT_COLOR:WrapTextInColorCode(optionLabel)
                            else
                                optionLabel = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(optionLabel)
                            end
                            local optionTooltip= option.tooltip
                            if optionTooltip then
                                optionTooltip= e.strText[optionTooltip] or optionTooltip
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
                    local label= e.strText[defaultOption.label] or defaultOption.label
                    GameTooltip_AddHighlightLine(SettingsTooltip, string.format("%s: %s", e.onlyChinese and '推荐' or VIDEO_OPTIONS_RECOMMENDED, GREEN_FONT_COLOR:WrapTextInColorCode(label)))
                end

                if warningOption and warningOption.value == setting:GetValue() and warningOption.warning then
                    GameTooltip_AddBlankLineToTooltip(SettingsTooltip)
                    local warning= e.strText[warningOption.warning] or warningOption.warning
                    GameTooltip_AddNormalLine(SettingsTooltip, WARNING_FONT_COLOR:WrapTextInColorCode(warning))
                end

                if setting:HasCommitFlag(Settings.CommitFlag.ClientRestart) then
                    GameTooltip_AddBlankLineToTooltip(SettingsTooltip)
                    GameTooltip_AddErrorLine(SettingsTooltip, e.onlyChinese and '更改此选项需要重新启动客户端' or VIDEO_OPTIONS_NEED_CLIENTRESTART)
                end
            end
            return initTooltip
        end


        hooksecurefunc(SettingsCheckBoxControlMixin, 'Init', function(self, initializer)
            local setting = initializer.data.setting
            local initTooltip= GenerateClosure(InitTooltip, addName, initializer:GetTooltip(), setting.variable)
            self:SetTooltipFunc(initTooltip)
            self.CheckBox:SetTooltipFunc(initTooltip)
        end)
        hooksecurefunc(SettingsSliderControlMixin, 'Init', function(self, initializer)
            local setting = initializer.data.setting
            local initTooltip= GenerateClosure(InitTooltip, addName, initializer:GetTooltip(), setting.variable)
            self:SetTooltipFunc(initTooltip)
            self.SliderWithSteppers.Slider:SetTooltipFunc(initTooltip)
        end)
        hooksecurefunc(SettingsDropDownControlMixin, 'Init', function(self, initializer)
            local setting = self:GetSetting()
            local options = initializer:GetOptions()
            local initTooltip= GenerateClosure(InitTooltip, addName, initializer:GetTooltip(), setting.variable)
            self:SetTooltipFunc(initTooltip)

            initTooltip = GenerateClosure(CreateOptionsInitTooltip(setting, addName, initializer:GetTooltip(), options, setting.variable))
            self.DropDown.Button:SetTooltipFunc(initTooltip)
        end)
        hooksecurefunc(SettingsCheckBoxWithButtonControlMixin, 'Init', function(self, initializer)
            local setting = initializer:GetSetting()
            local initTooltip= GenerateClosure(InitTooltip, addName, initializer:GetTooltip(), setting.variable)
	        self:SetTooltipFunc(initTooltip)
            self.CheckBox:SetTooltipFunc(initTooltip)
        end)
        hooksecurefunc(SettingsCheckBoxSliderControlMixin, 'Init', function(self, initializer)--Blizzard_SettingControls.lua
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
        hooksecurefunc(SettingsCheckBoxDropDownControlMixin, 'Init', function(self, initializer)--Blizzard_SettingControls.lua
            local cbSetting = initializer.data.cbSetting
            local cbLabel = initializer.data.cbLabel
            local cbTooltip = initializer.data.cbTooltip
            local initTooltip= GenerateClosure(InitTooltip, cbLabel, cbTooltip, cbSetting.variable)
	        self:SetTooltipFunc(initTooltip)
            self.CheckBox:SetTooltipFunc(initTooltip)

            local setting = initializer.data.dropDownSetting
            local options = initializer.data.dropDownOptions
            initTooltip = GenerateClosure(CreateOptionsInitTooltip(setting, addName, initializer:GetTooltip(), options, setting.variable))
            self.DropDown.Button:SetTooltipFunc(initTooltip)
        end)

        hooksecurefunc(KeyBindingFrameBindingTemplateMixin, 'Init', function(self, initializer)--Blizzard_Keybindings.lua
            local bindingIndex = initializer.data.bindingIndex
            local action, category = GetBinding(bindingIndex)
            local bindingName = GetBindingName(action)
            bindingName= e.strText[bindingName] or bindingName
            local function InitializeKeyBindingButtonTooltip(index)
                local key = select(index, GetBindingKey(action))
                if key then
                    Settings.InitTooltip(format(KEY_BINDING_NAME_AND_KEY, bindingName, GetBindingText(key)), e.onlyChinese and '<右键解除键位>' or KEY_BINDING_TOOLTIP)
                end
                GameTooltip_AddNormalLine(SettingsTooltip, 'bindingIndex |cnGREEN_FONT_COLOR:'..bindingIndex..'|r', true)
                GameTooltip_AddNormalLine(SettingsTooltip, 'action |cnGREEN_FONT_COLOR:'..action..'|r', true)
                if category then
                    GameTooltip_AddNormalLine(SettingsTooltip, category, true)
                end
                GameTooltip_AddNormalLine(SettingsTooltip, id..' '..addName, true)
            end

            for index, button in ipairs(self.Buttons) do
                button:SetTooltipFunc(GenerateClosure(InitializeKeyBindingButtonTooltip, index))
            end
        end)
    end





    
    --监视， WidgetSetID
    local widgetLabel= WoWTools_LabelMixin:Create(panel)
    widgetLabel:SetPoint('TOPLEFT', ctrlCopy, 'BOTTOMLEFT',0, -8)
    widgetLabel:SetText('WidgetSetID')
    widgetLabel:EnableMouse(true)
    widgetLabel:SetScript('OnLeave', function(self2) self2:SetAlpha(1) e.tips:Hide() end)
    widgetLabel:SetScript('OnEnter', function(self2)
        set_Cursor_Tips(self2)
        self2:SetAlpha(0.3)
    end)
    local widgetEdit= CreateFrame("EditBox", nil, panel, 'InputBoxTemplate')
	widgetEdit:SetPoint('LEFT', widgetLabel, 'RIGHT',6,0)
	widgetEdit:SetSize(100,20)
    widgetEdit:SetAutoFocus(false)
    widgetEdit:SetNumeric(true)
    widgetEdit:SetNumber(Save().WidgetSetID)
    widgetEdit:SetCursorPosition(0)
    widgetEdit:ClearFocus()
    widgetEdit:SetJustifyH('CENTER')
    widgetEdit:SetScript('OnEscapePressed', function(self2) self2:ClearFocus() end)
    widgetEdit:SetScript('OnLeave', GameTooltip_Hide)
	widgetEdit:SetScript('OnEnterPressed', function(self2)
        local num= math.modf(self2:GetNumber())
        if num>=0 then
            Save().WidgetSetID= num
            self2:ClearFocus()
            set_Cursor_Tips(self2)
            print(e.addName, Category:GetName(), 'PlayerFrame WidgetSetID',
                num==0 and e.GetEnabeleDisable(false) or num,
                '|n|cnRED_FONT_COLOR:',
                e.onlyChinese and '备注：如果出现错误，请关闭此功能（0）' or 'note: If you get error, please disable this (0)'
            )
        end
	end)
    widgetLabel= WoWTools_LabelMixin:Create(panel)
    widgetLabel:SetPoint('LEFT', widgetEdit, 'RIGHT',4, 0)
    widgetLabel:SetText('0 '..(e.onlyChinese and '取消' or CANCEL))
end

]]
