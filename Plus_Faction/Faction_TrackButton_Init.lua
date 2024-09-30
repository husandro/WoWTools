
local e= select(2, ...)
local function Save()
    return WoWTools_ReputationMixin.Save
end
local TrackButton















local function Init_Menu(self, root)
	local sub
--显示
	sub=root:CreateCheckbox(
		e.onlyChinese and '显示' or SHOW,
	function()
		return Save().btnstr
	end, function()
		Save().btnstr= not Save().btnstr and true or nil
		self:set_Shown()
		e.call(ReputationFrame.Update, ReputationFrame)
	end)
	sub:SetTooltip(function(tooltip)
		tooltip:AddLine(e.onlyChinese and '显示/隐藏' or (SHOW..'/'..HIDE))
	end)

--向右平移
	root:CreateDivider()
	root:CreateCheckbox(
		e.onlyChinese and '向右平移' or BINDING_NAME_STRAFERIGHT,
	function()
		return Save().toRightTrackText
	end, function()
		Save().toRightTrackText= not Save().toRightTrackText and true or false
		for _, btn in pairs(self.btn) do
			btn.text:ClearAllPoints()
			btn:set_text_point()
		end
		e.call(ReputationFrame.Update, ReputationFrame)
	end)

--上
	root:CreateCheckbox(
		'|A:bags-greenarrow:0:0|a'
		..(e.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP),
	function()
		return Save().toTopTrack
	end, function()
		Save().toTopTrack= not Save().toTopTrack and true or nil
		local last
		for index= 1, #TrackButton.btn do
			local btn=TrackButton.btn[index]
			btn:ClearAllPoints()
			if Save().toTopTrack then
				btn:SetPoint('BOTTOM', last or TrackButton, 'TOP')
			else
				btn:SetPoint('TOP', last or TrackButton, 'BOTTOM')
			end
			last=btn
		end
		e.call(ReputationFrame.Update, ReputationFrame)
	end)

--隐藏名称
	sub=root:CreateCheckbox(
		e.onlyChinese and '隐藏名称' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, NAME),
	function()
		return Save().onlyIcon
	end, function()
		Save().onlyIcon= not Save().onlyIcon and true or nil
		WoWTools_ReputationMixin.onlyIcon= Save().onlyIcon
		e.call(ReputationFrame.Update, ReputationFrame)
	end)
	sub:SetTooltip(function(tooltip)
		tooltip:AddLine(
			e.onlyChinese and '仅显示有图标声望'
			or format(LFG_LIST_CROSS_FACTION, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, FACTION, EMBLEM_SYMBOL))
		)
		e.call(ReputationFrame.Update, ReputationFrame)
	end)
	sub:SetEnabled(not PlayerGetTimerunningSeasonID())

--缩放
	WoWTools_MenuMixin:Scale(root, function()
		return Save().scaleTrackButton or 1
	end, function(value)
		Save().scaleTrackButton= value
		self:set_Scale()
	end)



--自动隐藏
	sub=root:CreateCheckbox(
		e.onlyChinese and '自动隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE),
	function()
		return not Save().notAutoHideTrack
	end, function()
		Save().notAutoHideTrack= not Save().notAutoHideTrack and true or nil
		self:set_Shown()
	end)
	sub:SetTooltip(function(tooltip)
		tooltip:AddLine(e.onlyChinese and '隐藏' or HIDE)
		tooltip:AddLine(' ')
		tooltip:AddLine(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
		tooltip:AddLine(e.onlyChinese and '宠物对战' or SHOW_PET_BATTLES_ON_MAP_TEXT)
		tooltip:AddLine(e.onlyChinese and '在副本中' or AGGRO_WARNING_IN_INSTANCE)
	end)

	--重置位置
	root:CreateDivider()
	WoWTools_MenuMixin:RestPoint(root, Save().point, function()
		Save().point=nil
		self:ClearAllPoints()
		self:set_Point()
		print(e.addName, WoWTools_ReputationMixin.addName, e.onlyChinese and '重置位置' or RESET_POSITION)
	end)
end

















--初始，监视, 文本
local function Init()
	if not Save().btn or TrackButton then
		return
	end
	TrackButton= WoWTools_ButtonMixin:Cbtn(nil, {icon='hide', size={22,22}, isType2=true})
	WoWTools_ReputationMixin.TrackButton= TrackButton

	--TrackButton.text= WoWTools_LabelMixin:CreateLabel(TrackButton, {color=true})

	TrackButton.texture= TrackButton:CreateTexture()
	TrackButton.texture:SetAllPoints()
	TrackButton.texture:SetAlpha(0.5)

	TrackButton.btn= {}
	TrackButton.Frame= CreateFrame('Frame', nil, TrackButton)
	TrackButton.Frame:SetPoint('BOTTOM')
	TrackButton.Frame:SetSize(1,1)

	function TrackButton:set_Shown()
		local hide= not Save().btn
		or (
		   not Save().notAutoHideTrack and (
				IsInInstance()
				or C_PetBattles.IsInBattle()
				or UnitInVehicle('player')
				or UnitAffectingCombat('player')
			)
	   )
	   	self:SetShown(not hide)
		self.Frame:SetShown(not hide and Save().btnstr)
		WoWTools_ReputationMixin:TrackButton_Settings()
		self:set_Texture()
	end


	function TrackButton:set_Event()
		if not Save().btn then
			self:UnregisterAllEvents()
		else
			self:RegisterEvent('UPDATE_FACTION')
			self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
			self:RegisterEvent('PLAYER_ENTERING_WORLD')
			self:RegisterEvent('PET_BATTLE_OPENING_DONE')
			self:RegisterEvent('PET_BATTLE_CLOSE')
			self:RegisterEvent('PLAYER_REGEN_DISABLED')
			self:RegisterEvent('PLAYER_REGEN_ENABLED')
			self:RegisterUnitEvent('UNIT_EXITED_VEHICLE', 'player')
			self:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', 'player')
		end
	end

	TrackButton:SetScript('OnEvent', function(self, event)
		if event=='UPDATE_FACTION' then
			WoWTools_ReputationMixin:TrackButton_Settings()
		else
			self:set_Shown()
		end
	end)


	function TrackButton:set_Tooltips()
		e.tips:SetOwner(self, "ANCHOR_LEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(e.addName, WoWTools_ReputationMixin.addName)
		e.tips:AddLine(' ')
		e.tips:AddDoubleLine(e.onlyChinese and '打开/关闭声望界面' or BINDING_NAME_TOGGLECHARACTER2, e.Icon.left)
		e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
		e.tips:AddLine(' ')
		--e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' '..(Save().scaleTrackButton or 1), 'Alt+'..e.Icon.mid)
		e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
		e.tips:Show()
	end

	function TrackButton:set_Scale()
		self.Frame:SetScale(Save().scaleTrackButton or 1)
	end

	function TrackButton:set_Texture()
		if Save().btnstr then
			self.texture:SetTexture(0)
		else
			self.texture:SetAtlas(e.Icon.icon)
		end
	end

	function TrackButton:set_Point()
		if Save().point then
			self:SetPoint(Save().point[1], UIParent, Save().point[3], Save().point[4], Save().point[5])
		elseif e.Player.husandro then
			self:SetPoint('TOPLEFT',70,0)
		else
			self:SetPoint('TOPLEFT', ReputationFrame, 'TOPRIGHT',0, -40)
		end
	end

	TrackButton:RegisterForDrag("RightButton")
	TrackButton:SetClampedToScreen(true);
	TrackButton:SetMovable(true);
	TrackButton:SetScript("OnDragStart", function(self)
		if IsAltKeyDown() then
			self:StartMoving()
		end
	end)
	TrackButton:SetScript("OnDragStop", function(self)
		ResetCursor()
		self:StopMovingOrSizing()
		Save().point={self:GetPoint(1)}
		Save().point[2]=nil
	end)
	TrackButton:SetScript("OnMouseUp", ResetCursor)

	TrackButton:SetScript("OnMouseDown", function(self, d)
		if d=='RightButton' and IsAltKeyDown() then
			SetCursor('UI_MOVE_CURSOR')

		elseif d=='LeftButton' and not IsModifierKeyDown() then--右击, 移动
			ToggleCharacter("ReputationFrame")


		elseif d=='RightButton' and not IsModifierKeyDown() then
			MenuUtil.CreateContextMenu(self, Init_Menu)
		end
		self:set_Tooltips()
	end)

	TrackButton:SetScript("OnLeave", function(self)
		ResetCursor()
		e.tips:Hide()
		self.texture:SetAlpha(0.5)
	end)
	TrackButton:SetScript("OnEnter", function(self)
		self:set_Tooltips()
		self.texture:SetAlpha(1)
		WoWTools_ReputationMixin:TrackButton_Settings()
	end)


	TrackButton:set_Scale()
	TrackButton:set_Point()
	TrackButton:set_Event()
	TrackButton:set_Shown()
	TrackButton:set_Texture()
	WoWTools_ReputationMixin:TrackButton_Settings()



	hooksecurefunc(ReputationEntryMixin, 'OnEnter', function(self)--角色栏,声望
		for _, btn in pairs(TrackButton.btn) do
			if self.elementData.factionID== btn.factionID then
				btn:SetScale(2)
			else
				btn:SetScale(1)
			end
		end
    end)
	hooksecurefunc(ReputationEntryMixin, 'OnLeave', function()--角色栏,声望
		for _, btn in pairs(TrackButton.btn) do
			btn:SetScale(1)
		end
    end)

	hooksecurefunc(ReputationFrame, 'Update', function()
		WoWTools_ReputationMixin:TrackButton_Settings()--更新, 监视, 文本
	end)
end











function WoWTools_ReputationMixin:Init_TrackButton()
	if PlayerGetTimerunningSeasonID() then--隐藏名称
		self.onlyIcon=nil
	else
		self.onlyIcon= Save().onlyIcon
	end

    Init()

	
end