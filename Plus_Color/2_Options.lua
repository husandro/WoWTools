local e= select(2, ...)
local function Save()
	return WoWTools_ColorMixin.Save
end

local btn

--[[local function Init2()
	local Frame= WoWTools_ColorMixin.Frame
	if OpacitySliderFrame then
		Frame.alphaText=WoWTools_LabelMixin:Create(OpacitySliderFrame, {mouse=true, size=14})--14)--透明值，提示
		Frame.alphaText:SetPoint('LEFT', OpacitySliderFrame, 'RIGHT', 5,0)

		OpacitySliderFrame:EnableMouseWheel(true)
		OpacitySliderFrame:SetScript('OnMouseWheel', function(self, d)
			local value= self:GetValue()
			if d== 1 then
				value= value- 0.01
			elseif d==-1 then
				value= value+ 0.01
			end
			value= value> 1 and 1 or value
			value= value< 0 and 0 or value
			self:SetValue(value)
		end)
	else
		Frame.alphaText=WoWTools_LabelMixin:Create(ColorPickerFrame, {mouse=true, size=14})--透明值，提示
		Frame.alphaText:SetPoint('TOP', ColorPickerFrame.Content.ColorSwatchOriginal, 'BOTTOM')
	end
	Frame.alphaText:SetScript('OnLeave', function(self) self:SetAlpha(1) e.tips:Hide() end)
	Frame.alphaText:SetScript('OnEnter', function(self)
		e.tips:SetOwner(self, "ANCHOR_LEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_ColorMixin.addName)
		e.tips:AddDoubleLine(e.onlyChinese and '透明度' or CHANGE_OPACITY, 'Alpha')
		e.tips:Show()
	end)




	local check2= CreateFrame("CheckButton", nil, ColorPickerFrame, "InterfaceOptionsCheckButtonTemplate")--显示/隐藏
	check2:SetCheckedTexture('MonsterFriend')
	check2.type2= CreateFrame("CheckButton", nil, ColorPickerFrame, "InterfaceOptionsCheckButtonTemplate")--显示/隐藏
	check2.type2:SetCheckedTexture('MonsterFriend')
	check2:SetPoint("TOPLEFT", ColorPickerFrame, 7, -7)
	check2:SetChecked(not Save().hide)
	check2:SetScript('OnMouseDown', function()
		Save().hide= not Save().hide and true or nil
		if not Save().hide and not Frame then
			Init()
		end
		if Frame then
			Frame:SetShown(not Save().hide)
			print(WoWTools_Mixin.addName, WoWTools_ColorMixin.addName, e.GetShowHide(not Save().hide))
		end
	end)
	check2:SetScript('OnEnter', function()
		e.tips:SetOwner(ColorPickerFrame, "ANCHOR_RIGHT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(e.GetShowHide(not Save().color)..e.Icon.left)
		e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_ColorMixin.addName)
		e.tips:Show()
	end)
	check2:SetScript('OnLeave', GameTooltip_Hide)


	check2.type2:SetPoint("LEFT", check2, 'RIGHT',-4,0)
	check2.type2:SetChecked(Save().selectType2)
	check2.type2:SetScript('OnMouseDown', function()
		Save().selectType2= not Save().selectType2 and true or nil
		print(WoWTools_Mixin.addName, WoWTools_ColorMixin.addName, e.GetEnabeleDisable(Save().selectType2), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
	end)
	check2.type2:SetScript('OnEnter', function()
		e.tips:SetOwner(ColorPickerFrame, "ANCHOR_RIGHT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(e.onlyChinese and '颜色' or COLOR, 2)
		e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_ColorMixin.addName)
		e.tips:Show()
	end)
	check2.type2:SetScript('OnLeave', GameTooltip_Hide)
end]]


local function Init_Menu(self, root)
	local sub
	root:CreateCheckbox(
		e.onlyChinese and '显示' or SHOW,
	function()
		return self.frame:IsShown()
	end, function()
		Save().hide= not Save().hide and true or nil
		self:Settings()
	end)

	root:CreateDivider()
--缩放
	WoWTools_MenuMixin:Scale(root, function()
		return Save().scale or 1
	end, function(value)
		Save().scale= value
		self:Settings()
	end)

	local num= #Save().logColor
	sub=root:CreateButton(
		'|A:bags-button-autosort-up:0:0|a'
		..(num==0 and '|cff828282' or '')
		..'#'..num
		..(e.onlyChinese and '清除记录' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_STOPWATCH_PARAM_STOP2, EVENTTRACE_LOG_HEADER)),
	function()
		WoWTools_ColorMixin:Clear_Log()
	end)
	sub:SetTooltip(function(tooltip)
		tooltip:AddLine(e.onlyChinese and '最多保存30个颜色' or 'Save up to 30 colors')
	end)
end

--[[
local function Init_OpacityFrame()
	OpacityFrameSlider:HookScript('OnValueChanged', function(self, ...)
		print(...)
	end)
end]]



local function Init()
	btn=WoWTools_ButtonMixin:CreateMenu(ColorPickerFrame, {name='WoWToolsColorPickerFrameButton'})
	btn:SetPoint("TOPLEFT", ColorPickerFrame.Border, 7, -7)
	
	function btn:set_alpha()
		self:GetNormalTexture():SetAlpha(GameTooltip:IsOwned(self) and 1 or 0.2)
	end

	function btn:set_tooltip()
		e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_ColorMixin.addName)
		e.tips:AddLine(' ')
		e.tips:AddDoubleLine(
			e.GetShowHide(self.frame:IsShown()),
			(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)..e.Icon.left
		)
        e.tips:Show()
	end

	btn:SetScript('OnLeave', function(self)
		e.tips:Hide()
		self:set_alpha()
	end)
	btn:SetScript('OnEnter', function(self)
		self:set_tooltip()
		self:set_alpha()
	end)

	btn.frame=CreateFrame("Frame", nil, btn)
	btn.frame:SetPoint('BOTTOMRIGHT')
	btn.frame:SetSize(1,1)

	function btn:Settings()
		self:SetNormalAtlas(Save().hide and e.Icon.icon or 'ui-questtrackerbutton-filter')
		self.frame:SetShown(not Save().hide)
		self.frame:SetScale(Save().scale or 1)
		ColorPickerFrame.Content.ColorPicker:SetColorRGB(ColorPickerFrame:GetColorRGB())
	end

	btn:SetupMenu(Init_Menu)
	btn:Settings()
	btn:set_alpha()
end








function WoWTools_ColorMixin:Init_Options()
	Init()
end