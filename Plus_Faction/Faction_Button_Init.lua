
local function Save()
    return WoWToolsSave['Plus_Faction']
end











local function Init_Menu(self, root)
	local sub, sub2, num
--追踪
	sub=root:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING,
	function()
		return Save().btn
	end, function()
		Save().btn= not Save().btn and true or nil
		if WoWTools_FactionMixin.TrackButton then
			WoWTools_FactionMixin.TrackButton:set_Shown()
		else
			WoWTools_FactionMixin:Init_TrackButton()--监视, 文本
		end
		print(WoWTools_DataMixin.Icon.icon2..WoWTools_FactionMixin.addName, WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING, WoWTools_TextMixin:GetShowHide(Save().btn))
	end)

--自动隐藏
	sub2=sub:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '自动隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE),
	function()
		return not Save().notAutoHideTrack
	end, function()
		Save().notAutoHideTrack= not Save().notAutoHideTrack and true or nil
		if WoWTools_FactionMixin.TrackButton then
			WoWTools_FactionMixin.TrackButton:set_Shown()
		end
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
		if WoWTools_FactionMixin.TrackButton then
			WoWTools_FactionMixin.TrackButton:ClearAllPoints()
			WoWTools_FactionMixin.TrackButton:set_Point()
		end
		print(WoWTools_DataMixin.Icon.icon2..WoWTools_FactionMixin.addName, WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION)
	end)

--指定
	sub=root:CreateCheckbox(
		(Save().btn and '' or '|cff9e9e9e')
		..(WoWTools_DataMixin.onlyChinese and '指定' or COMBAT_ALLY_START_MISSION),
	function()
		return Save().indicato
	end, function()
		Save().indicato= not Save().indicato and true or nil
		WoWTools_Mixin:Call(ReputationFrame.Update, ReputationFrame)
	end)
	

--指定，列表
	num=0
	local new={}
	for factionID in pairs(Save().factions) do
		table.insert(new, factionID)
	end
	table.sort(new)

	for _, factionID in pairs(new) do
		sub2=sub:CreateCheckbox(
			WoWTools_FactionMixin:GetName(factionID),
		function(data)
			return Save().factions[data.factionID]
		end, function(data)
			Save().factions[data.factionID]= not Save().factions[data.factionID] and true or nil
			WoWTools_Mixin:Call(ReputationFrame.Update, ReputationFrame)
		end, {factionID=factionID})
		WoWTools_SetTooltipMixin:FactionMenu(sub2)
		--[[sub2:SetOnEnter(function(btn, description)
			btn.factionID= description.data.factionID
			WoWTools_SetTooltipMixin:Faction(btn)
		end)
		sub2:SetOnLeave(function(btn)
			btn.factionID=nil
			WoWTools_SetTooltipMixin:Hide()
		end)]]
		num= num+1
	end

	if num>1 then
		WoWTools_MenuMixin:SetScrollMode(sub)
--全部清除
		WoWTools_MenuMixin:ClearAll(sub, function()
			Save().factions={}
			WoWTools_Mixin:Call(ReputationFrame.Update, ReputationFrame)
		end)
	end

--声望变化
	root:CreateDivider()
	sub=root:CreateCheckbox(
		'|A:voicechat-icon-textchat-silenced:0:0|a'
		..(WoWTools_DataMixin.onlyChinese and '声望变化' or COMBAT_TEXT_SHOW_REPUTATION_TEXT),
	function()
		return Save().factionUpdateTips
	end, function()
		Save().factionUpdateTips= not Save().factionUpdateTips and true or nil
		if Save().factionUpdateTips then
			WoWTools_FactionMixin:Check_Chat_MSG()
			print(FACTION_STANDING_INCREASED)
			print(FACTION_STANDING_INCREASED_ACCOUNT_WIDE)
		end
	end)
	sub:SetTooltip(function(tooltip)
		tooltip:AddLine('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '需求' or NEED))
		tooltip:AddLine(
			WoWTools_DataMixin.onlyChinese and '展开选项 |A:editmode-down-arrow:16:11:0:-7|a 声望'
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
		WoWTools_Mixin:Call(ReputationFrame.Update, ReputationFrame)
		self:settings()
	end)
end



















local function Init()
    local btn= WoWTools_ButtonMixin:Menu(ReputationFrame, {name='WoWTools_PlusReputationMenuButton'})
	WoWTools_FactionMixin.Button= btn

    btn:SetupMenu(Init_Menu)

	btn:SetPoint("RIGHT", CharacterFrameCloseButton, 'LEFT', -2, 0)
    btn:SetFrameStrata(CharacterFrameCloseButton:GetFrameStrata())
    btn:SetFrameLevel(CharacterFrameCloseButton:GetFrameLevel()+2)

	btn:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_FactionMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
		WoWTools_FactionMixin:Set_TrackButton_Pushed(true)--TrackButton，提示
	end)

	btn:SetScript('OnLeave', function()
		GameTooltip:Hide()
		WoWTools_FactionMixin:Set_TrackButton_Pushed(false)--TrackButton，提示
	end)

	

	function btn:settings()
		if self.down then
			local show= not WoWToolsSave['Plus_Faction'].notPlus
			self.down:SetShown(show)
		end
	end

    --btn:settings()
end











function WoWTools_FactionMixin:Init_Button()
    Init()
end
