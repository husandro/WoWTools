---@diagnostic disable: undefined-global
--[[
https://github.com/tomrus88/BlizzardInterfaceCode/blob/5321290b97b74177bd44a65054d34fd61ce83424/Interface/AddOns/Blizzard_Settings_Shared/Blizzard_ImplementationReadme.lua#L88
Blizzard_Settings 实施指南

Blizzard_Settings 最初在 10.0 中实施，但在 11.0 中进行了更新，以解决
可用性问题。

插件可以使用画布或垂直列表框架描述设置。]]

--[[*** 类别和子类别 ***
类别是您的设置的容器，可以用画布或垂直列表表示：]]
local category, layout = Settings.RegisterCanvasLayoutCategory(myFrame, "My Addon");
--or
local category, layout = Settings.RegisterVerticalLayoutCategory("My Addon");


--子类别附加到类别。请注意，如果您想要
--技术组合，父类别类型是可以互换的。
local subcategory, subcategoryLayout = Settings.RegisterCanvasLayoutSubcategory(category, myFrame, "My Addon Subcategory");
--or
local subcategory, subcategoryLayout = Settings.RegisterVerticalLayoutSubcategory(category, "My Addon Subcategory");
--这些函数返回的布局对象具有与所选演示类型相关的不同 API。对于垂直列表，一般来说，您根本不需要与布局对象交互，除非您需要创建自定义控件和/或框架来表示设置。

--[[*** Canvas ***
Canvas 是指完全在插件中设计的框架。此技术是从
旧版设置系统中保留下来的。选择类别后，设置系统将显示您的框架。除了
一些可选功能外，框架的实现细节由您决定。

Canvas 布局对象允许您自定义锚定。如果没有提供锚点，
框架将锚定到面板空间中的 TOPLEFT (0,0) 和 BOTTOMRIGHT (0,0)。]]
layout:AddAnchorPoint("TOPLEFT", 50, -50);
la​​yout:AddAnchorPoint("BOTTOMRIGHT", -50, 50);

--[[您可以在框架中定义 3 个可选函数：
1) OnCommit：在设置面板中选择“应用”选项时调用。如果任何
带有“应用”提交标志的设置已更改，则将调用此函数。
如果您的设置对象已设置“应用”提交标志，则将调用此函数。
2) OnDefault：应用默认值时调用。
3) OnRefresh：显示设置面板时调用。

为框架注册类别后，最后一步应该是注册类别：]]
Settings.RegisterAddOnCategory(category);

--[[*** 垂直列表 ***
垂直列表允许您放弃创建控件和处理其布局的设计工作。
这些列表使用设置对象和设置控件的组合进行填充。这是用于显示大多数 WoW 游戏设置的技术。

此示例使用代理设置创建一个带有复选框的类别，并使用插件设置创建一个带有复选框的子类别。]]


--MyAddon.toc:
--## SavedVariables: MyAddonSettings

--MyAddon.lua:
EventRegistry:RegisterFrameEventAndCallback("VARIABLES_LOADED", function()
	local category, layout = Settings.RegisterVerticalLayoutCategory("My Addon");
-- 代理设置允许获取和设置访问器，但您有责任默认初始化
-- 保存的变量值，并在其发生变化时将该值写入您保存的变量表。
	if MyAddonSettings.canLog == nil then
		MyAddonSettings.canLog = Settings.Default.True;
	end

	local function GetValue()
		return MyAddonSettings.canLog;
	end

	local function SetValue(value)
		MyAddonSettings.canLog = value;
		-- 您应用“canLog”值的实现。
	end

	-- “MY_ADDON_CAN_LOG” 和 “MY_ADDON_CAN_LOG_ATTACKS” 是变量名称，并且是
-- 设置查找所必需的。
	local canLogSetting = Settings.RegisterProxySetting(category, "MY_ADDON_CAN_LOG", 
		Settings.VarType.Boolean, "Can Log", Settings.Default.True, GetValue, SetValue)
	Settings.CreateCheckbox(category, canLogSetting);

	-- 插件设置会将任何值更改直接写入您保存的变量表。分配回调
-- 将值更改应用于您的代码。请注意，与代理设置不同，如果值当前为零，则您不需要默认
-- 初始化变量表，因为它会在
-- RegisterAddOnSetting 返回之前为您完成。
	local logCategory, logLayout = Settings.RegisterVerticalLayoutSubcategory(category, "Log Details");
	local logAttacksSetting = Settings.RegisterAddOnSetting(logCategory, "MY_ADDON_CAN_LOG_ATTACKS", "logAttacks", 
		MyAddonSettings, Settings.VarType.Boolean, "Log Attacks", Settings.Default.True);
	
	logAttacksSetting:SetValueChangedCallback(function(setting, value)
		-- 您应用“logAttacks”值的实现。
	end);

	Settings.CreateCheckbox(logCategory, logAttacksSetting);

	Settings.RegisterAddOnCategory(category);
end);

--*** 设置控件 ***
--使用以下实用函数可以轻松将设置与控件配对。摘录自 WoW 代码中的示例：

--Settings.CreateCheckbox():

local function GetValue()
	return tonumber(GetCVar("softTargetEnemy")) == Enum.SoftTargetEnableFlags.Any;
end

local function SetValue(value)
	SetCVar("softTargetEnemy", value and Enum.SoftTargetEnableFlags.Any or Enum.SoftTargetEnableFlags.Gamepad);
end

local defaultValue = false;
local setting = Settings.RegisterProxySetting(category, "PROXY_ACTION_TARGETING",
	Settings.VarType.Boolean, ACTION_TARGETING_OPTION, defaultValue, GetValue, SetValue);
Settings.CreateCheckbox(category, setting, OPTION_TOOLTIP_ACTION_TARGETING);





--Settings.CreateSlider():

local max = 1.0;
local function GetValue()
	return max - C_VoiceChat.GetMasterVolumeScale();
end

local function SetValue(value)
	C_VoiceChat.SetMasterVolumeScale(max - value);
end

local defaultValue = tonumber(GetCVarDefault("VoiceChatMasterVolumeScale"));
local setting = Settings.RegisterProxySetting(category, "PROXY_VOICE_DUCKING",
	Settings.VarType.Number, VOICE_CHAT_DUCKING_SCALE, defaultValue, GetValue, SetValue);

local minValue, maxValue, step = 0, max, .01;
local options = Settings.CreateSliderOptions(minValue, maxValue, step);
options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatPercentage);

local initializer = Settings.CreateSlider(category, setting, options, VOICE_CHAT_AUDIO_DUCKING);
initializer:SetParentInitializer(outputInitializer);





--Settings.CreateDropdown():

local function GetValue()
	local chatBubbles = C_CVar.GetCVarBool("chatBubbles");
	local chatBubblesParty = C_CVar.GetCVarBool("chatBubblesParty");
	if chatBubbles and chatBubblesParty then
		return 1;
	elseif not chatBubbles then
		return 2;
	elseif chatBubbles and not chatBubblesParty then
		return 3;
	end
end

local function SetValue(value)
	if value == 1 then
		SetCVar("chatBubbles", "1");
		SetCVar("chatBubblesParty", "1");
	elseif value == 2 then
		SetCVar("chatBubbles", "0");
		SetCVar("chatBubblesParty", "0");
	elseif value == 3 then
		SetCVar("chatBubbles", "1");
		SetCVar("chatBubblesParty", "0");
	end
end

local function GetOptions()
	local container = Settings.CreateControlTextContainer();
	container:Add(1, ALL);
	container:Add(2, NONE);
	container:Add(3, CHAT_BUBBLES_EXCLUDE_PARTY_CHAT);
	return container:GetData();
end

local defaultValue = 1;
local setting = Settings.RegisterProxySetting(category, "PROXY_CHAT_BUBBLES",
	Settings.VarType.Number, CHAT_BUBBLES_TEXT, defaultValue, GetValue, SetValue);
Settings.CreateDropdown(category, setting, GetOptions, OPTION_TOOLTIP_CHAT_BUBBLES);

--[[*** 访问设置值 ***
注册设置后，您可以使用 Settings.GetSetting(variable) 检索对象。

要访问或更改设置的值，请​​分别使用 setting:SetValue(value) 和 setting:GetValue()。

您还可以通过分别使用 Settings.GetValue(variable) 和 Settings.SetValue(variable, value) 单独设置变量来访问或更改设置的值。

*** 打开类别设置 ***
您可以使用以下方法打开类别设置 UI：
Settings.OpenToCategory(categoryID, scrollToElementName);

对于垂直列表，可选的“scrollToElementName”是指分配给设置的显示名称。

如果省略此项，类别将打开到列表顶部。需要使用 GetID() 从类别或子类别中检索 ID：

例如：]]

Settings.OpenToCategory(category:GetID());
--or
local settingName = "Can Log";
Settings.OpenToCategory(category:GetID(), settingName);
--[[*** 插件子类别排序 ***
插件类别按字母顺序排序，但子类别不按字母顺序排序。
您可以使用以下方法启用子类别排序：]]
