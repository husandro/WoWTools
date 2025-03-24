
local function Save()
	return WoWToolsSave['Plus_Color'] or {}
end




local function Init_Menu(self, root)
	local sub
	root:CreateCheckbox(
		WoWTools_Mixin.onlyChinese and '显示' or SHOW,
	function()
		return self.frame:IsShown()
	end, function()
		Save().hide= not Save().hide and true or nil
		self:Settings()
	end)

	root:CreateDivider()
--缩放
	WoWTools_MenuMixin:Scale(self, root, function()
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
		..(WoWTools_Mixin.onlyChinese and '清除记录' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_STOPWATCH_PARAM_STOP2, EVENTTRACE_LOG_HEADER)),
	function()
		Save().logColor={}
		WoWTools_ColorMixin:Set_SaveLogList()
		return MenuResponse.Close
	end)
	sub:SetTooltip(function(tooltip)
		tooltip:AddLine(
			format((WoWTools_Mixin.onlyChinese and '最多保存%d个颜色' or 'Save up to %d colors'), Save().logMaxColor or 10)
		)
	end)

--设置，最多保存30个颜色
	sub:CreateSpacer()
	WoWTools_MenuMixin:CreateSlider(sub, {
		getValue=function()
			return Save().logMaxColor or 10
		end, setValue=function(value)
			Save().logMaxColor=value
			WoWTools_ColorMixin:Set_SaveLogList()--设置，记录
		end,
		name=WoWTools_Mixin.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL,
		minValue=0,
		maxValue=200,
		step=1,
		--bit='%.2f',
		tooltip=function(tooltip)
			tooltip:AddLine(WoWTools_Mixin.onlyChinese and '保存' or SAVE)
		end
	})
	sub:CreateSpacer()

--更多颜色
	sub=root:CreateCheckbox(
		WoWTools_Mixin.onlyChinese and '更多颜色' or (COLORS..' 2'),
	function()
		return Save().selectType2
	end, function()
		Save().selectType2 = not Save().selectType2 and true or nil
	end)
	sub:SetTooltip(function(tooltip)
		tooltip:AddLine( WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
	end)

--重新加载UI
	WoWTools_MenuMixin:Reload(sub)


--禁止自动隐藏
	sub=root:CreateCheckbox(
		'|A:newplayertutorial-drag-cursor:0:0|a'
		..(WoWTools_Mixin.onlyChinese and '自动隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE)),
	function()
		return not Save().notHideFuori
	end, function()
		Save().notHideFuori= not Save().notHideFuori and true or nil
		self:Settings()
	end)
	sub:SetTooltip(function(tooltip)
		tooltip:AddLine(WoWTools_Mixin.onlyChinese and '框架外点击：自动隐藏' or 'Click outside the ColorFrame: Auto-hide')
	end)


--自动显示
	root:CreateDivider()
	sub=root:CreateCheckbox(
		WoWTools_Mixin.onlyChinese and '自动显示' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SHOW),
	function()
		return Save().autoShow
	end, function()
		Save().autoShow= not Save().autoShow and true or nil
	end)
	sub:SetTooltip(function(tooltip)
		tooltip:AddLine(WoWTools_Mixin.onlyChinese and '显示' or SHOW)
		tooltip:AddLine(WoWTools_Mixin.onlyChinese and '登入游戏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LOG_IN, GAME))
	end)


--打开选项界面
	root:CreateDivider()
	WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_ColorMixin.addName})
end












local function Init()
	local btn=WoWTools_ButtonMixin:Menu(ColorPickerFrame, {name='WoWToolsColorPickerFrameButton'})
	btn:SetPoint("TOPLEFT", ColorPickerFrame.Border, 7, -7)

	function btn:set_alpha()
		self:GetNormalTexture():SetAlpha(GameTooltip:IsOwned(self) and 1 or 0.3)
	end

	function btn:set_tooltip()
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_ColorMixin.addName)
		GameTooltip:AddLine(' ')
		GameTooltip:AddDoubleLine(
			WoWTools_TextMixin:GetShowHide(self.frame:IsShown()),
			(WoWTools_Mixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)..WoWTools_DataMixin.Icon.left
		)
        GameTooltip:Show()
	end

	btn:SetScript('OnLeave', function(self)
		GameTooltip:Hide()
		self:set_alpha()
	end)
	btn:SetScript('OnEnter', function(self)
		self:set_tooltip()
		self:set_alpha()
	end)

	btn.frame=CreateFrame("Frame", nil, btn)
	btn.frame:SetPoint('BOTTOMRIGHT')
	btn.frame:SetSize(1,1)

--原生，去掉，在框架外，会自动关闭, 提示
	btn.autoHideTexture= btn:CreateTexture(nil, 'BORDER')
	btn.autoHideTexture:SetSize(23,23)
	btn.autoHideTexture:SetPoint('LEFT', ColorPickerFrame.Footer.CancelButton, 'RIGHT', 0, -1)
	btn.autoHideTexture:SetAtlas('newplayertutorial-drag-cursor')
	btn.autoHideTexture:EnableMouse(true)
	btn.autoHideTexture:SetScript('OnLeave', function(self) self:SetAlpha(1) GameTooltip:Hide() end)	
	btn.autoHideTexture:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
		GameTooltip:SetText(WoWTools_Mixin.onlyChinese and '自动隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE))
		GameTooltip:AddLine(WoWTools_Mixin.onlyChinese and '框架外点击：自动隐藏' or 'Click outside the ColorFrame: Auto-hide')
		GameTooltip:Show()
		self:SetAlpha(0.3)
	end)
	btn.autoHideTexture:SetScript('OnMouseDown', function(self)
		local p= self:GetParent()
		if not p:IsMenuOpen() then
			p:OpenMenu()
		end
	end)

	function btn:Settings()
		self:SetNormalAtlas(Save().hide and WoWTools_DataMixin.Icon.icon or 'ui-questtrackerbutton-filter')
		self.frame:SetShown(not Save().hide)
		self.frame:SetScale(Save().scale or 1)
		ColorPickerFrame.Content.ColorPicker:SetColorRGB(ColorPickerFrame:GetColorRGB())
		self.autoHideTexture:SetShown(not Save().notHideFuori)
	end

	btn:SetupMenu(Init_Menu)
	btn:Settings()
	btn:set_alpha()
end








function WoWTools_ColorMixin:Init_Menu()
	Init()
end