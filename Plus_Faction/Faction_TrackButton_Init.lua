
local function Save()
    return WoWToolsSave['Plus_Faction']
end
local TrackButton















local function Init_Menu(self, root)
	local sub, sub2
--显示
	sub=root:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '显示' or SHOW,
	function()
		return Save().btnstr
	end, function()
		Save().btnstr= not Save().btnstr and true or nil
		self:set_Shown()
		WoWTools_Mixin:Call(ReputationFrame.Update, ReputationFrame)
	end)
	sub:SetTooltip(function(tooltip)
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '显示/隐藏' or (SHOW..'/'..HIDE))
	end)

--向右平移
	sub:CreateDivider()
	sub:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '向右平移' or BINDING_NAME_STRAFERIGHT,
	function()
		return Save().toRightTrackText
	end, function()
		Save().toRightTrackText= not Save().toRightTrackText and true or false
		for _, btn in pairs(self.btn) do
			btn.text:ClearAllPoints()
			btn:set_text_point()
		end
		WoWTools_Mixin:Call(ReputationFrame.Update, ReputationFrame)
	end)

--上
	sub:CreateCheckbox(
		'|A:bags-greenarrow:0:0|a'
		..(WoWTools_DataMixin.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP),
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
		WoWTools_Mixin:Call(ReputationFrame.Update, ReputationFrame)
	end)

--隐藏名称
	sub2=sub:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '隐藏名称' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, NAME),
	function()
		return Save().onlyIcon
	end, function()
		Save().onlyIcon= not Save().onlyIcon and true or nil
		WoWTools_FactionMixin.onlyIcon= Save().onlyIcon
		WoWTools_Mixin:Call(ReputationFrame.Update, ReputationFrame)
	end)
	sub2:SetTooltip(function(tooltip)
		tooltip:AddLine(
			WoWTools_DataMixin.onlyChinese and '仅显示有图标声望'
			or format(LFG_LIST_CROSS_FACTION, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, FACTION, EMBLEM_SYMBOL))
		)
		WoWTools_Mixin:Call(ReputationFrame.Update, ReputationFrame)
	end)
	sub2:SetEnabled(not PlayerGetTimerunningSeasonID())

--缩放
	WoWTools_MenuMixin:Scale(self, sub, function()
		return Save().scaleTrackButton or 1
	end, function(value)
		Save().scaleTrackButton= value
		self:set_Scale()
	end)

--FrameStrata    
	WoWTools_MenuMixin:FrameStrata(sub, function(data)
		return self:GetFrameStrata()==data
	end, function(data)
		Save().strata= data
		self:set_strata()
	end)


--自动隐藏
	sub2=sub:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '自动隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE),
	function()
		return not Save().notAutoHideTrack
	end, function()
		Save().notAutoHideTrack= not Save().notAutoHideTrack and true or nil
		self:set_Shown()
	end)
	sub2:SetTooltip(function(tooltip)
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE)
		tooltip:AddLine(' ')
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '宠物对战' or SHOW_PET_BATTLES_ON_MAP_TEXT)
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '在副本中' or AGGRO_WARNING_IN_INSTANCE)
	end)

--重置位置
	sub:CreateDivider()
	WoWTools_MenuMixin:RestPoint(self, sub, Save().point, function()
		Save().point=nil
		self:ClearAllPoints()
		self:set_Point()
		print(WoWTools_DataMixin.Icon.icon2..WoWTools_FactionMixin.addName, WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION)
	end)

	--打开选项界面
	root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_FactionMixin.addName})
end

















--初始，监视, 文本
local function Init()
	if not Save().btn or TrackButton then
		return
	end
	TrackButton= WoWTools_ButtonMixin:Cbtn(nil, {
		size=23,
		name='WoWToolsFactionTrackListMainButton',
	})
	WoWTools_FactionMixin.TrackButton= TrackButton

	TrackButton.texture= TrackButton:CreateTexture(nil, 'BORDER')
    TrackButton.texture:SetAtlas('Adventure-MissionEnd-Line')
    TrackButton.texture:SetPoint('CENTER')
    TrackButton.texture:SetSize(12,10)

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
		WoWTools_FactionMixin:TrackButton_Settings()
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
			WoWTools_FactionMixin:TrackButton_Settings()
		else
			self:set_Shown()
		end
	end)


	function TrackButton:set_Tooltips()
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_FactionMixin.addName)
		GameTooltip:AddLine(' ')
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '打开/关闭声望界面' or BINDING_NAME_TOGGLECHARACTER2, WoWTools_DataMixin.Icon.left)
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.right)
		GameTooltip:AddLine(' ')
		--GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE)..' '..(Save().scaleTrackButton or 1), 'Alt+'..WoWTools_DataMixin.Icon.mid)
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
		GameTooltip:Show()
	end

	function TrackButton:set_Scale()
		self.Frame:SetScale(Save().scaleTrackButton or 1)
	end

	function TrackButton:set_Texture()
		self.texture:SetAlpha(Save().btnstr and 0.3 or 0.7)
	end

	function TrackButton:set_Point()
		if Save().point then
			self:SetPoint(Save().point[1], UIParent, Save().point[3], Save().point[4], Save().point[5])
		else
			self:SetPoint('TOPLEFT', 0, WoWTools_DataMixin.Player.husandro and 0 or -100)
		end
	end

	function TrackButton:set_strata()
        self:SetFrameStrata(Save().strata or 'MEDIUM')
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
        if WoWTools_FrameMixin:IsInSchermo(self) then
			Save().point={self:GetPoint(1)}
			Save().point[2]=nil
		end
	end)
	TrackButton:SetScript("OnMouseUp", ResetCursor)

	TrackButton:SetScript("OnMouseDown", function(self, d)
		if d=='RightButton' and IsAltKeyDown() then
			SetCursor('UI_MOVE_CURSOR')

		elseif d=='LeftButton' and not IsModifierKeyDown() then--右击, 移动
			ToggleCharacter("ReputationFrame")


		elseif d=='RightButton' and not IsModifierKeyDown() then
			MenuUtil.CreateContextMenu(self, function(...)
                Init_Menu(...)
            end)
		end
		self:set_Tooltips()
	end)

	TrackButton:SetScript("OnLeave", function(self)
		ResetCursor()
		GameTooltip:Hide()
		self:set_Texture()
	end)
	TrackButton:SetScript("OnEnter", function(self)
		self:set_Tooltips()
		self.texture:SetAlpha(1)
		WoWTools_FactionMixin:TrackButton_Settings()
	end)


	TrackButton:set_Scale()
	TrackButton:set_Point()
	TrackButton:set_Event()
	TrackButton:set_Shown()
	TrackButton:set_Texture()
	TrackButton:set_strata()
	WoWTools_FactionMixin:TrackButton_Settings()



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
		WoWTools_FactionMixin:TrackButton_Settings()--更新, 监视, 文本
	end)
end











function WoWTools_FactionMixin:Init_TrackButton()
	if PlayerGetTimerunningSeasonID() then--隐藏名称
		self.onlyIcon=nil
	else
		self.onlyIcon= Save().onlyIcon
	end

    Init()

	
end