local e= select(2, ...)
local function Save()
    return WoWTools_ReputationMixin.Save
end











local function Init_Menu(self, root)
	local sub, sub2, num
--追踪
	sub=root:CreateCheckbox(
		e.onlyChinese and '追踪' or TRACKING,
	function()
		return Save().btn
	end, function()
		Save().btn= not Save().btn and true or nil
		if WoWTools_ReputationMixin.TrackButton then
			WoWTools_ReputationMixin.TrackButton:set_Shown()
		else
			WoWTools_ReputationMixin:Init_TrackButton()--监视, 文本
		end
		print(e.addName, WoWTools_ReputationMixin.addName, e.onlyChinese and '追踪' or TRACKING, e.GetShowHide(Save().btn))
	end)

--自动隐藏
	sub2=sub:CreateCheckbox(
		e.onlyChinese and '自动隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE),
	function()
		return not Save().notAutoHideTrack
	end, function()
		Save().notAutoHideTrack= not Save().notAutoHideTrack and true or nil
		if WoWTools_ReputationMixin.TrackButton then
			WoWTools_ReputationMixin.TrackButton:set_Shown()
		end
	end)
	sub2:SetTooltip(function(tooltip)
		tooltip:AddLine(e.onlyChinese and '隐藏' or HIDE)
		tooltip:AddLine(' ')
		tooltip:AddLine(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
		tooltip:AddLine(e.onlyChinese and '宠物对战' or SHOW_PET_BATTLES_ON_MAP_TEXT)
		tooltip:AddLine(e.onlyChinese and '在副本中' or AGGRO_WARNING_IN_INSTANCE)
	end)

--重置位置
	sub:CreateDivider()
	WoWTools_MenuMixin:RestPoint(sub, Save().point, function()
		Save().point=nil
		if WoWTools_ReputationMixin.TrackButton then
			WoWTools_ReputationMixin.TrackButton:ClearAllPoints()
			WoWTools_ReputationMixin.TrackButton:set_Point()
		end
		print(e.addName, WoWTools_ReputationMixin.addName, e.onlyChinese and '重置位置' or RESET_POSITION)
	end)

--指定
	sub=root:CreateCheckbox(
		(Save().btn and '' or '|cff9e9e9e')
		..(e.onlyChinese and '指定' or COMBAT_ALLY_START_MISSION),
	function()
		return Save().indicato
	end, function()
		Save().indicato= not Save().indicato and true or nil
		e.call(ReputationFrame.Update, ReputationFrame)
	end)

--指定，列表
	num=0
	local new={}
	for factionID in pairs(Save().factions) do
		table.insert(new, factionID)
	end
	table.sort(new)--, function(a, b) return a.data.factionID > b.data.factionID end)

	for _, factionID in pairs(new) do
		sub:CreateCheckbox(
			WoWTools_FactionMixin:GetName(factionID),
		function(data)
			return Save().factions[data.factionID]
		end, function(data)
			Save().factions[data.factionID]= not Save().factions[data.factionID] and true or nil
			e.call(ReputationFrame.Update, ReputationFrame)

		end, {factionID=factionID})
		num= num+1
	end

	if num>1 then
		WoWTools_MenuMixin:SetGridMode(sub, num)
--全部清除
		WoWTools_MenuMixin:ClearAll(sub, function()
			Save().factions={}
			e.call(ReputationFrame.Update, ReputationFrame)
		end)
	end

--声望变化
	root:CreateDivider()
	sub=root:CreateCheckbox(
		'|A:voicechat-icon-textchat-silenced:0:0|a'
		..(e.onlyChinese and '声望变化' or COMBAT_TEXT_SHOW_REPUTATION_TEXT),
	function()
		return Save().factionUpdateTips
	end, function()
		Save().factionUpdateTips= not Save().factionUpdateTips and true or nil
		if Save().factionUpdateTips then
			WoWTools_ReputationMixin:Check_Chat_MSG()
			print(FACTION_STANDING_INCREASED)
			print(FACTION_STANDING_INCREASED_ACCOUNT_WIDE)
		end
	end)
	sub:SetTooltip(function(tooltip)
		tooltip:AddLine('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需求' or NEED))
		tooltip:AddLine(
			e.onlyChinese and '展开选项 |A:editmode-down-arrow:16:11:0:-7|a 声望'
			or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_EXPAND_OPTIONS, REPUTATION)
		)
	end)

--Plus
	root:CreateCheckbox(
		'UI Plus',
	function()
	return not Save().notPlus
	end, function()
		Save().notPlus= not Save().notPlus and true or nil
		e.call(ReputationFrame.Update, ReputationFrame)
		self:settings()
	end)
end



















local function Init()
    local btn= WoWTools_ButtonMixin:CreateMenu(ReputationFrame, {name='WoWTools_PlusReputationButton'})
    btn:SetupMenu(Init_Menu)

	btn:SetPoint("RIGHT", CharacterFrameCloseButton, 'LEFT', -2, 0)
    btn:SetFrameStrata(CharacterFrameCloseButton:GetFrameStrata())
    btn:SetFrameLevel(CharacterFrameCloseButton:GetFrameLevel())

	btn:SetScript('OnEnter', function(self)
		e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_ReputationMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.left)
        e.tips:Show()
		WoWTools_ReputationMixin:Set_TrackButton_Pushed(true)--TrackButton，提示
	end)

	btn:SetScript('OnLeave', function()
		e.tips:Hide()
		WoWTools_ReputationMixin:Set_TrackButton_Pushed(false)--TrackButton，提示
	end)

	function btn:set_expand_collapse(show)
		if self.isGo then
			return
		end
		self.isGo=true
		for index=1, C_Reputation.GetNumFactions() do
			local data= C_Reputation.GetFactionDataByIndex(index) or {}
			if data.isHeader then
				if show then
					if data.isCollapsed then
						C_Reputation.ExpandFactionHeader(index);
					end
				else
					if not data.isCollapsed then
						C_Reputation.CollapseFactionHeader(index);
					end
				end
			end
		end
		self.isGo=nil
	end

	btn.up= WoWTools_ButtonMixin:Cbtn(btn, {size={22,22}, atlas='NPE_ArrowUp'})--texture='Interface\\Buttons\\UI-PlusButton-Up'})--收起所有
	btn.up:SetPoint("RIGHT", btn, 'LEFT',-2,0)
	btn.up:SetScript("OnClick", function(self)
		self:GetParent():set_expand_collapse(false)
	end)
	btn.up:SetScript("OnLeave", GameTooltip_Hide)
	btn.up:SetScript('OnEnter', function(self)
		e.tips:SetOwner(self, "ANCHOR_LEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(' ', e.onlyChinese and '收起选项|A:editmode-up-arrow:16:11:0:3|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS)
		e.tips:AddDoubleLine(e.addName, WoWTools_ReputationMixin.addName)
		e.tips:Show()
	end)

	btn.down= WoWTools_ButtonMixin:Cbtn(btn, {size={22,22}, atlas='NPE_ArrowDown'})--texture='Interface\\Buttons\\UI-MinusButton-Up'})--展开所有
	btn.down:SetPoint("RIGHT", btn.up, 'LEFT',-2,0)
	btn.down:SetScript("OnClick", function(self)
		self:GetParent():set_expand_collapse(true)
	end)
	btn.down:SetScript("OnLeave", GameTooltip_Hide)
	btn.down:SetScript('OnEnter', function(self)
		e.tips:SetOwner(self, "ANCHOR_LEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(' ', e.onlyChinese and '展开选项|A:editmode-down-arrow:16:11:0:-7|a' or HUD_EDIT_MODE_EXPAND_OPTIONS)
		e.tips:AddDoubleLine(e.addName, WoWTools_ReputationMixin.addName)
		e.tips:Show()
	end)

	function btn:settings()
		local show= not WoWTools_ReputationMixin.Save.notPlus
		self.up:SetShown(show)
	end
    btn:settings()
end











function WoWTools_ReputationMixin:Init_Button()
    Init()
end
