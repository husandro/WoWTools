---@diagnostic disable: undefined-global, redefined-local, assign-type-mismatch, undefined-field, inject-field, missing-parameter, redundant-parameter, unused-local, trailing-space, param-type-mismatch, duplicate-set-field

--[[
.fontString
.leftTexture1
.leftTexture2
WoWTools_Mixin:Call(menu.ReinitializeAll, menu)

function MenuTemplates.CreateRadio(text, isSelected, onSelect, data)
	local function Initializer(button, description, menu)
		MenuVariants.CreateRadio(text, button, isSelected, data);
	end
	
	local elementDescription = CreateButtonDescription(data);
	elementDescription:SetSoundKit(GetButtonSoundKit);
	elementDescription:AddInitializer(Initializer);
	elementDescription:SetRadio(true);
	elementDescription:SetIsSelected(isSelected);
	elementDescription:SetResponder(onSelect);
	return elementDescription;
end
SetResponse(MenuResponse.Refresh)

Blizzard_Menu implementation guide

Blizzard_Menu 是一个用于创建上下文菜单和下拉菜单的新框架，是 UIDropDownMenu 的完全替代品。

所有 UIDropDownMenu 的使用都已转换为使用 Blizzard_Menu，并且 UIDropDownMenu 现已弃用。由于
这两个系统之间存在巨大的根本差异，因此尚未提供垫片，并且 UIDropDownMenu 的任何公共用途
也需要根据 Blizzard_Menu 重写其实现以利用这些变化。

*** 菜单 ***
菜单是包含一组常用控件（如按钮、单选按钮和复选框）的框架，但也可以包含专用框架。
这些菜单可以在光标处打开（上下文菜单），也可以与下拉按钮相连。
这些菜单的内容由生成器函数定义。
其参数是菜单所有者和保存菜单内容的根描述。

示例:
]]
local function GeneratorFunction(owner, rootDescription)
	rootDescription:CreateTitle("My Title");
	rootDescription:CreateButton("My Button", function(data)
    	-- Button handling here.
	end);
end

--[[*** 子菜单 ***
添加到根描述的元素称为元素描述，它们共享根描述中可用的大部分功能。
例如，元素描述可以以与添加到根描述相同的方式添加控件。
当元素描述中添加元素时，它将变成并显示为子菜单。

示例:]]
local submenu = rootDescription:CreateButton("My Submenu");
submenu:CreateButton("Enable", SetEnabledFunction, true);
submenu:CreateButton("Disable", SetEnabledFunction, false);

--[[*** 根描述和元素描述 ***
这两种描述类型都可以使用这些函数：
SetTag
ClearQueuedDescription
AddQueuedDescription
Insert

这些功能仅适用于元素描述：
SetRadio
IsSelected 
SetIsSelected
SetSelectionIgnored
SetSoundKit
SetOnEnter
SetOnLeave
SetEnabled
IsEnabled
SetData
SetResponder
SetResponse
SetTooltip
Pick

*** 添加元素 Adding Elements ***
要将元素描述添加到另一个元素描述，建议使用最能代表您的控件类型的创建函数之一。
请注意，出于实用性原因，这些函数不适用于分隔符和间隔符：

CreateFrame(frameType)
CreateTemplate(frameTemplate)
CreateButton
CreateTitle
CreateCheckbox
CreateRadio
CreateDivider
CreateSpacer
CreateColorSwatch

您可能想要插入标题、分隔符或间隔符，但前提是要添加其他元素：

QueueTitle
QueueDivider
QueueSpacer

*** 上下文菜单 ***
虽然上下文菜单在技术上可以在空白处打开（只要有一个区域可以检测鼠标向上/单击），但它们通常是在按钮或列表元素等区域上方打开的。
此区域称为所有者区域（或简称所有者）。
如果所有者在其菜单打开时被隐藏，则菜单将自动关闭。

示例:
（参见上面的 GeneratorFunction
MenuUtil.CreateContextMenu(owner, GeneratorFunction);

*** 下拉按钮 ***
鼠标按下时，下拉按钮会创建与其自身相连的菜单。
与上下文菜单类似，此处隐含的所有者是下拉按钮。
与上下文菜单一样，如果下拉按钮在其菜单打开时被隐藏，它将自动关闭。

示例:
（参见上面的 GeneratorFunction）
dropdownButton:SetupMenu(GeneratorFunction);

在 XML 中，这些下拉按钮应始终使用 DropdownButton 内部函数创建。
使用此内部函数可免除与菜单行为相关的实现步骤。
例如，菜单将在按下时打开，播放适当的打开/关闭声音，并自动显示所选的文本选项（如果适用）。

示例:
<DropdownButton parentKey="FilterDropdown" inherits="WowStyle1FilterDropdownTemplate">
	<Anchors>
		<Anchor point="TOPRIGHT" x="-26" y="-64"/>
	</Anchors>
</DropdownButton>

在 Lua 中，可以像创建任何其他框架一样创建下拉按钮。例如，使用 CreateFrame：

示例:]]
local dropdown = CreateFrame("DropdownButton", nil, MyParentFrame, "WowStyle1DropdownTemplate");
dropdown:SetDefaultText("My Dropdown");
dropdown:SetPoint("CENTER", 0, -250);
dropdown:SetupMenu(GeneratorFunction);

--[[*** 模板 ***
MenuTemplates.xml 中提供了我们整个 UI 中使用的最常见下拉样式的模板。您会发现 WowStyle1DropdownTemplate
和 WowStyle1FilterDropdownTemplate 在代码中使用最频繁。WowStyle1DropdownTemplate 用于至少有一个
可选元素的下拉列表，而 WowStyle1FilterDropdownTemplate 用于可能有许多可选元素的分类过滤器。

WowStyle2DropdownTemplate
WowStyle2IconButtonTemplate
WowMenuAutoHideButtonTemplate

上下文菜单不依赖于任何模板。

*** 选择状态 ***
默认情况下，可选下拉按钮（例如 WowStyle1DropdownTemplate）上显示的文本由菜单内元素描述的选中状态决定。
例如，给定以下菜单描述，下拉按钮内显示的文本应为“Radio1”。


示例:]]
local g_selectedIndex = 1;

local function IsSelected(index) return index == g_selectedIndex; end
local function SetSelected(index) g_selectedIndex = index; end

local function GeneratorFunction(dropdown, rootDescription)
	for index = 1, 3 do
	    rootDescription:CreateRadio("My Radio "..index, IsSelected, SetSelected, index);
	end
end

dropdown:SetupMenu(GeneratorFunction);

--[[当下拉按钮显示时，将调用生成器函数（如果存在）来填充描述。
完成后，下拉按钮将遍历根描述可访问的所有元素描述，以查找所有选定元素，并将结果组合起来形成选择文本。
如果有多个选定元素，文本将变为逗号分隔的列表。


** 操作选择文本 ***

选择文本通常需要特殊行为。
很多时候，不希望将元素描述附带的相同文本用作选择文本。
在某些情况下，您可能需要将特定的可选元素描述完全排除在考虑范围之外。

以下是一些支持的更改结果的方法：


SetSelectionTranslator(func)：这是在每个元素描述上调用的函数，允许自定义返回。示例中，selection.data
是一个代表排名的数字（1、2、3 等），但译者将其改为“排名 1”、“排名 2”、“排名 3”等。


示例:]]
self:SetSelectionTranslator(function(selection)
	return TRADESKILL_RECIPE_LEVEL_DROPDOWN_BUTTON_FORMAT:format(selection.data);
end);

--[[SetSelectionText(func)：使用所有已知选定元素描述调用一次的函数，返回所需文本。
在示例中，选择被完全忽略，而是使用一些内部状态来显示所需字符串，这些字符串可以是“任意”、“多个”或结合类和规范的格式化字符串。
如果有用，实现可以考虑选择的内容。

示例:]]
self:SetSelectionText(function(selections)
	if self.checkedCount > 1 then
		return CLUB_FINDER_MULTIPLE_ROLES;
	end

	if self.checkedCount == 1 then
		local specID, specInfo = next(self.checkedList);
		return TALENT_SPEC_AND_CLASS:format(specInfo.specName, specInfo.className);
	end

	return CLUB_FINDER_ANY_FLAG;
end);

--[[OverrideText(text): 设置文本并忽略所有选择状态。 Sets the text and ignores all selection state.
示例:
self.Dropdown:OverrideText("My Text");

SetDefaultText(text): 设置未找到选择时显示的文本。 Sets the text displayed when no selections are found.
示例:
self.TitleDropdown:SetDefaultText(PAPERDOLL_SELECT_TITLE);

SetSelectionIgnored(): 将要忽略的元素描述标记为选择候选项。 Marks an element description to be ignored as a selection candidate.
示例:]]
local checkbox = rootDescription:CreateCheckbox(REPUTATION_CHECKBOX_SHOW_LEGACY_REPUTATIONS, IsLegacyRepSelected, SetLegacyRepSelected);
checkbox:SetSelectionIgnored();

--[[*** 更新下拉按钮 ***
如前所述，选择文本由所选元素描述告知，因此如果下拉列表外部的代码导致逻辑状态发生变化，则需要通知下拉列表进行更新。
最容易做到这一点的方法是调用下拉列表上的 GenerateMenu() 以创建新的根描述，然后重新评估所选文本。这通常也是最可靠的。
请注意，如果更改的来源源自选择菜单元素，则不需要发生这种情况，因为这将自动触发选择文本。


*** 配置元素描述框架 ***
*** 更改属性 ***
元素描述会通知菜单系统要创建什么，但一旦创建了框架，大多数自定义都会通过初始化程序进行。
初始化程序的第一个参数是框架。下面是一个初始化程序的示例，它只是更改 Radio 模板附带的字体字符串上的字体对象。
示例:]]
local radio = rootDescription:CreateRadio(durationText, IsSelected, SetSelected, index);
radio:AddInitializer(function(button, description, menu)
	button.fontString:SetFontObject("Number12Font");
end);

--[[*** 初始化模板 *** 

如果您有一个需要使用其他地方的数据初始化的模板（在本例中为下拉按钮），您可能需要一个稍微复杂一些的初始化程序，但方法类似：

示例:]]
local levelRangeFrame = rootDescription:CreateTemplate("LevelRangeFrameTemplate");
levelRangeFrame:AddInitializer(function(frame, elementDescription, menu)
	frame:Reset();

	local minLevel = filterDropdown.minLevel;
	if minLevel > 0 then
		frame:SetMinLevel(minLevel);
	end

	local maxLevel = filterDropdown.maxLevel;
	if maxLevel > 0 then
		frame:SetMaxLevel(maxLevel);
	end

	frame:SetLevelRangeChangedCallback(function(minLevel, maxLevel)
		filterDropdown.minLevel, filterDropdown.maxLevel = minLevel, maxLevel;
		filterDropdown:ValidateResetState();
	end);
end);

--[[*** 自定义按钮和处理 ***
如果您想在菜单中使用自己的按钮模板，则需要在菜单被选中时（单击、鼠标按下或其他方式）通知菜单描述对象。这可以通过在描述对象上调用 Pick() 来完成：
]]
local data = {...};
local buttonDescription = rootDescription:CreateTemplate("YourButtonTemplate", data);
buttonDescription:AddInitializer(function(button, description, menu)
	button:SetScript("OnClick", function(button, buttonName)
		local inputContext = MenuInputContext.MouseButton;
		description:Pick(inputContext, buttonName);
	end);
end);

--您还可以提供响应函数，以根据您的用例利用自定义响应类型。
buttonDescription:SetResponder(function(data, menuInputData, menu)
	-- Your handler here...

	return MenuResponse.Close;
end)

--当前的响应类型为：
MenuResponse = 
{
	Open = 1, -- 菜单保持开放且不变
	Refresh = 2, -- 菜单中的所有框架都已重新初始化
	Close = 3, --父菜单保持打开，但此菜单关闭
	CloseAll = 4, -- 所有菜单关闭
};

--[[*** 合成器 ***
合成器有助于将区域恢复到其默认状态，并能够组成可根据需要处置的临时区域层次结构。在菜单的情况下，这对于专门化常见控件类型非常有用，而无需创建其他模板。

如果您想使用单选模板，但还需要框架上的其他各种区域，您可以按照货币转移中的此示例进行操作。
这会附加并初始化纹理、字体字符串，然后根据需要重新锚定所有内容。请注意每个 AttachTexture 和 AttachFontString 调用，这些函数是通过合成器添加到按钮的。

示例:]]
local radio = rootDescription:CreateRadio(currencyData.characterName, IsSelected, SetSelected, currencyData);
radio:AddInitializer(function(button, description, menu)
	local rightTexture = button:AttachTexture();
	rightTexture:SetSize(18, 18);
	rightTexture:SetPoint("RIGHT");
	rightTexture:SetTexture(currencyInfo.icon);

	local fontString = button.fontString;
	fontString:SetPoint("RIGHT", rightTexture, "LEFT");
	fontString:SetTextColor(NORMAL_FONT_COLOR:GetRGB());

	local fontString2 = button:AttachFontString();
	fontString2:SetHeight(20);
	fontString2:SetPoint("RIGHT", rightTexture, "LEFT", -5, 0);
	fontString2:SetJustifyH("RIGHT");
	fontString2:SetText(BreakUpLargeNumbers(currencyData.quantity));

	-- Manual calculation required to accomodate aligned text.
	local pad = 20;
	local width = pad + fontString:GetUnboundedStringWidth() + fontString2:GetUnboundedStringWidth() + rightTexture:GetWidth();

	local height = 20;
	return width, height;
end);

--[[关闭此菜单后，所有区域都将从收音机上剥离，脚本将被清除，关键更改将恢复。它只在控件显示的生命周期内存在。

*** 元素范围 ***

大多数情况下，您不需要提供框架的范围。有些场景（如上例）可能需要特定的
填充，尤其是在内容左锚和右锚的框架上，宽度难以推断。

菜单容器将调整大小以包含所有菜单元素。每个菜单元素都分配有一个框架，并且每个框架的范围
根据以下规则按优先级顺序获取：

1) 派生初始化程序返回的第一个大小。此返回是可选的，在 99% 的情况下，如果提供了初始化程序，则会省略。

2) 菜单元素框架上每个区域的边界框的大小。这仅在为框架分配了合成器（默认）时才会发生。

3) 框架的大小。这是最后一种情况，因为所有框架都有大小，即使它是合成器中默认的 1x1 大小。

*** 工具提示 ***

虽然您可以手动设置脚本以在元素初始化程序内的框架上显示工具提示，但更简单的方法是调用 SetTooltip 将该设置委托给菜单系统。如果您将数据传递给元素描述，则可以使用 GetData() 访问它。

示例:]]
local button = rootDescription:CreateButton("Button", OnClick);
button:SetTooltip(function(tooltip, elementDescription)
	GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
	GameTooltip_AddInstructionLine(tooltip, "Test Tooltip Instruction");--绿色
	GameTooltip_AddNormalLine(tooltip, "Test Tooltip Normal Line");--黄色
	GameTooltip_AddErrorLine(tooltip, "Test Tooltip Colored Line");--红色
	GameTooltip_AddColoredLine(tooltip, text, HIGHLIGHT_FONT_COLOR)--白色
end);

GameTooltip_SetTitle(tooltip, text, overrideColor, wrap)
GameTooltip_AddBlankLineToTooltip(tooltip)

--[[*** 显示模式 ***
默认情况下，菜单垂直布局元素。要启用网格布局，请使用 SetGridMode。如果没有提供列，则列数将自动从 AutoCalculateColumns（下面提供）中选择：

示例:]]
local columns = 2;
rootDescription:SetGridMode(MenuConstants.VerticalGridDirection, columns);

local function AutoCalculateColumns(count)
	if count > 36 then
		return 4;
	elseif count > 24 then
		return 3;
	elseif count > 10 then
		return 2;
	end
	return 1;
end

--[[*** 滚动菜单 ***
在菜单集可能很大的情况下，极少数情况下可能需要滚动菜单。要启用此功能，请使用 SetScrollMode。

示例:]]
local extent = 20;
local maxCharacters = 8;
local maxScrollExtent = extent * maxCharacters;
rootDescription:SetScrollMode(maxScrollExtent);

--[[*** 定位 ***
根菜单的定位适用不同的规则：

根上下文菜单将始终夹紧在屏幕上。
下拉根菜单永远不会沿垂直轴夹紧在屏幕上。如果菜单无法容纳，它将在垂直轴上反射，然后在水平轴上夹紧在屏幕上。这可以防止菜单与其所连接的下拉菜单重叠。

子菜单永远不会夹紧在屏幕上。
与根菜单类似，如果子菜单无法容纳，它将在所连接的元素的水平轴上反射。此规则适用于任何深度的子菜单，但菜单元素将始终尝试在可能的情况下从左到右方向创建子菜单。

*** 样式 ***
菜单背景纹理、内部范围填充和子范围填充的选择由分配给上下文菜单或下拉按钮的菜单样式决定。当打开上下文菜单时，除非所有者区域提供覆盖，
否则菜单样式混合的选择由 MenuVariants.GetDefaultContextMenuMixin() 决定。
同样，除非下拉按钮提供覆盖，否则菜单样式混合的选择由 MenuVariants.GetDefaultMenuMixin() 决定。

*** 帮助程序 ***

如果您正在创建常见控件类型的下拉按钮菜单，并且不需要对任何元素进行调整，请考虑使用以下可变参数实用程序之一来简化您的定义：

MenuUtil.CreateButtonMenu
MenuUtil.CreateCheckboxMenu
MenuUtil.CreateRadioMenu
MenuUtil.CreateEnumRadioMenu
MenuUtil.CreateButtonContextMenu
MenuUtil.CreateCheckboxContextMenu
MenuUtil.CreateRadioContextMenu
MenuUtil.CreateEnumRadioContextMenu

示例 1:]]
MenuUtil.CreateButtonMenu(dropdown,
	{"My Button 1", OnClick, 1},
	{"My Button 2", OnClick, 2},
	{"My Button 3", OnClick, 3}
);

--示例 2:
MenuUtil.CreateCheckboxContextMenu(ownerButton,
	CheckboxAPI.IsSelected, 
	CheckboxAPI.ToggleSelected,
	{"My Checkbox 1", 1},
	{"My Checkbox 2", 2},
	{"My Checkbox 3", 3},
	{"My Checkbox 4", 4},
	{"My Checkbox 5", 5}
);

--[[*** 插件菜单自定义 ***
根菜单描述标有字符串标识符，插件作者可以使用它来注册将元素附加到菜单的函数。

UnitPopup 菜单标签的格式为 MENU_UNIT_<UNIT_TYPE>，其中 UNIT_TYPE 是单元类型之一（SELF、RAID、PARTY1 等），
并附带 contextData 表，插件可以使用它来获取有关菜单的更多信息。

要修改菜单：

示例：]]
Menu.ModifyMenu("MENU_MINIMAP_TRACKING", function(owner, rootDescription, contextData)
	rootDescription:CreateDivider();
	rootDescription:CreateTitle("My Addon");
	rootDescription:CreateButton("Button", function() print("Text here!") end);
end);

--[[*** 污点 ***
菜单系统的设计考虑了更好地支持插件自定义，而不会产生污点后果。插件应始终能够
在菜单的任何位置插入元素，而不会将污点传递给任何周围的元素处理程序。

*** 事件跟踪菜单发现 ***
当打开带标签的菜单时，EventTrace 将显示带有标签的“Menu.OpenMenuTag”事件，以便轻松识别菜单。或者，可以调用
Menu.PrintOpenMenuTags() 来打印所有打开的带标签的菜单。]]





local function GeneratorFunction(owner, rootDescription)
	rootDescription:CreateTitle("My Title");
	rootDescription:CreateButton("My Button", function(data)
    	-- Button handling here.
	end);
    
    local submenu = rootDescription:CreateButton("My Submenu");
    submenu:CreateButton("Enable", SetEnabledFunction, true);
    submenu:CreateButton("Disable", SetEnabledFunction, false);
end

local btn= CreateFrame('DropdownButton', nil, nil, 'UIPanelButtonTemplate')
btn:SetPoint('CENTER')

btn:SetScript('OnMouseDown', function(self)
    MenuUtil.CreateContextMenu(self, GeneratorFunction)
end)










Menu.ModifyMenu("MENU_MINIMAP_TRACKING", function(owner, rootDescription, contextData)
	rootDescription:CreateDivider();
	rootDescription:CreateTitle("My Addon");
	rootDescription:CreateButton("Button", function() print("Text here!") end);
end);

MenuTemplates.SetHierarchyEnabled(button, enabled);