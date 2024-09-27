local id, e = ...
local Save={
	btn=e.Player.husandro,--启用，TrackButton
	factions={},--指定,显示,声望
	btnstr=true,--文本
	--scaleTrackButton=1,缩放
	--notAutoHideTrack=true,--自动隐藏
	toRightTrackText=true,--向右平移
	--toTopTrack=true,--向上

	factionUpdateTips=true,--更新, 提示
	--indicato=true,--指定
	onlyIcon=e.Player.husandro,--隐藏名称， 仅显示有图标
}
local addName=REPUTATION

local Button
local TrackButton
local Initializer

local onlyIcon
local FACTION_STANDING_INCREASED= FACTION_STANDING_INCREASED--"你在%s中的声望值提高了%d点。";
local FACTION_STANDING_INCREASED_ACCOUNT_WIDE = FACTION_STANDING_INCREASED_ACCOUNT_WIDE--"你的战团在%s中的声望值提高了%d点。";









local function get_Faction_Info(index, factionID)
	local data= WoWTools_FactionMixin:GetInfo(factionID, index, Save.toRightTrackText)
	factionID= data.factionID
	local name
	name= data.name

	if not factionID or not name or name==HIDE or (not data.isHeaderWithRep and data.isHeader) then
		return
	end


	local value= data.valueText
	local texture= data.texture
	local atlas= data.atlas
	local barColor= data.barColor
	local isCapped= data.isCapped
	local isParagon= data.isParagon


	if (isCapped and not isParagon and index)--声望已满，没有奖励
		or (onlyIcon and not atlas and not texture)
	then
		return
	end

	local factionStandingtext
	if not data.isCapped then
		factionStandingtext= data.factionStandingtext
	end

	local text
	if onlyIcon then--仅显示有图标
		name=nil
	else
		name= e.cn(name)
		name= name:match('%- (.+)') or name
	end

	if barColor then
		if value and not factionStandingtext then--值
			value= barColor:WrapTextInColorCode(value)
		end
		if factionStandingtext  then--等级
			factionStandingtext= barColor:WrapTextInColorCode(factionStandingtext)
		end
	end

	if Save.toRightTrackText then--向右平移 
		text= (name or '')
			..(data.hasRep and '|cnGREEN_FONT_COLOR:+|r' or '')--额外，声望
			..(name and ' ' or '')
			..(factionStandingtext or '')
			..(value and ' '..value or '')
			..(data.hasRewardPending or '')--有奖励

	else
		text=(data.hasRewardPending or '')--有奖励
			..(value or '')
			..(factionStandingtext and ' '..factionStandingtext or '')
			..(name and ' ' or '')
			..(data.hasRep and '|cnGREEN_FONT_COLOR:+|r' or '')--额外，声望
			..(name or '')
	end
	return text, texture, atlas, data
end



--TrackButton，提示
local function Set_TrackButton_Pushed(show, text)
	if TrackButton then
		TrackButton:SetButtonState(show and 'PUSHED' or "NORMAL")
	end
	if text then
		text:SetAlpha(show and 0.5 or 1)
	end
end

--设置，提示，位置
local function Set_SetOwner(self, tooltip)
	if Save.toRightTrackText then
		tooltip:SetOwner(self.text, "ANCHOR_RIGHT");
	else
		tooltip:SetOwner(self.text, "ANCHOR_LEFT");
	end
end


local function ShowParagonRewardsTooltip(self)
	Set_SetOwner(self, EmbeddedItemTooltip);
	ReputationParagonFrame_SetupParagonTooltip(self);
	EmbeddedItemTooltip:Show()
end
local function TryAppendAccountReputationLineToTooltip(tooltip, factionID)
	if not tooltip or not factionID or not C_Reputation.IsAccountWideReputation(factionID) then
		return;
	end
	GameTooltip_AddColoredLine(tooltip, e.onlyChinese and '战团声望' or REPUTATION_TOOLTIP_ACCOUNT_WIDE_LABEL, ACCOUNT_WIDE_FONT_COLOR, false);
end

local function ShowFriendshipReputationTooltip(self)
	local friendshipData = C_GossipInfo.GetFriendshipReputation(self.factionID);
	if not friendshipData or friendshipData.friendshipFactionID < 0 then
		return;
	end
	Set_SetOwner(self, GameTooltip)
	local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(friendshipData.friendshipFactionID);
	if rankInfo.maxLevel > 0 then
		GameTooltip_SetTitle(GameTooltip, friendshipData.name.." ("..rankInfo.currentLevel.." / "..rankInfo.maxLevel..")", HIGHLIGHT_FONT_COLOR);
	else
		GameTooltip_SetTitle(GameTooltip, friendshipData.name, HIGHLIGHT_FONT_COLOR);
	end
	TryAppendAccountReputationLineToTooltip(GameTooltip, self.factionID);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip:AddLine(friendshipData.text, nil, nil, nil, true);
	if friendshipData.nextThreshold then
		local current = friendshipData.standing - friendshipData.reactionThreshold;
		local max = friendshipData.nextThreshold - friendshipData.reactionThreshold;
		local wrapText = true;
		GameTooltip_AddHighlightLine(GameTooltip, friendshipData.reaction.." ("..current.." / "..max..")", wrapText);
	else
		local wrapText = true;
		GameTooltip_AddHighlightLine(GameTooltip, friendshipData.reaction, wrapText);
	end
	GameTooltip:Show();
end

local function AddRenownRewardsToTooltip(self, renownRewards)
	GameTooltip_AddHighlightLine(GameTooltip, '接下来的奖励：');

	for i, rewardInfo in ipairs(renownRewards) do
		local renownRewardString;
		local icon, name = RenownRewardUtil.GetRenownRewardInfo(rewardInfo, GenerateClosure(self.ShowMajorFactionRenownTooltip, self));
		if icon then
			local file, width, height = icon, 16, 16;
			local rewardTexture = CreateSimpleTextureMarkup(file, width, height);
			renownRewardString = rewardTexture .. " " .. e.cn(name)
		end
		local wrapText = false;
		GameTooltip_AddNormalLine(GameTooltip, renownRewardString, wrapText);
	end
end
local function ShowMajorFactionRenownTooltip(self)
	Set_SetOwner(self, GameTooltip)
	local majorFactionData = C_MajorFactions.GetMajorFactionData(self.factionID) or {}
	GameTooltip_SetTitle(GameTooltip, e.cn(majorFactionData.name), HIGHLIGHT_FONT_COLOR);
	TryAppendAccountReputationLineToTooltip(GameTooltip, self.factionID);
	GameTooltip_AddHighlightLine(GameTooltip, (e.onlyChinese and '名望' or RENOWN_LEVEL_LABEL).. majorFactionData.renownLevel);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddNormalLine(GameTooltip, format(e.onlyChinese and '继续获取%s的声望以提升名望并解锁奖励。' or MAJOR_FACTION_RENOWN_TOOLTIP_PROGRESS, e.cn(majorFactionData.name)))
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	local nextRenownRewards = C_MajorFactions.GetRenownRewardsForLevel(self.factionID, C_MajorFactions.GetCurrentRenownLevel(self.factionID) + 1);
	if #nextRenownRewards > 0 then
		AddRenownRewardsToTooltip(nextRenownRewards);
	end
	GameTooltip:Show();
end

local function ShowStandardTooltip(self)
	Set_SetOwner(self, GameTooltip)
	GameTooltip_SetTitle(GameTooltip, e.cn(self.name))
	TryAppendAccountReputationLineToTooltip(GameTooltip, self.factionID);
	GameTooltip:Show();
end



















--设置 Text
local function Set_TrackButton_Text()
	if not TrackButton or not TrackButton:IsShown() then
		return
	end

	local faction={}
	if Save.indicato then
		for factionID, _ in pairs(Save.factions) do
			local text, texture, atlas, data= get_Faction_Info(nil, factionID)
			if text then
				table.insert(faction, {text= text, texture=texture, atlas=atlas, data=data})
			end
		end
		table.sort(faction, function(a, b) return a.data.factionID > b.data.factionID end)
	else
		for index=1, C_Reputation.GetNumFactions() do
			local text, texture, atlas, data=get_Faction_Info(index, nil)
			if text then
				table.insert(faction, {text= text, texture=texture, atlas=atlas, data=data})
			end
		end
	end

	local last
	for index, tab in pairs(faction) do
		local btn= TrackButton.btn[index]
		if not btn then
			btn= WoWTools_ButtonMixin:Cbtn(TrackButton.Frame, {size={14,14}, icon='hide'})
			if Save.toTopTrack then
				btn:SetPoint('BOTTOM', last or TrackButton, 'TOP')
			else
				btn:SetPoint('TOP', last or TrackButton, 'BOTTOM')
			end
			btn:SetScript('OnLeave', function(self)
				e.tips:Hide()
				if EmbeddedItemTooltip then EmbeddedItemTooltip:Hide() end
				Set_TrackButton_Pushed(false, self.text)--TrackButton，提示
			end)
			btn:SetScript('OnEnter', function(self)
				if self.isParagon then
					ShowParagonRewardsTooltip(self);
				elseif self.isFriend then
					ShowFriendshipReputationTooltip(self)
				elseif self.isMajorFaction then
					ShowMajorFactionRenownTooltip(self);
				else
					ShowStandardTooltip(self);
				end
				Set_TrackButton_Pushed(true, self.text)--TrackButton，提示
			end)

			btn.text= WoWTools_LabelMixin:CreateLabel(btn, {color=true})
			function btn:set_text_point()
				if Save.toRightTrackText then
					self.text:SetPoint('LEFT', self, 'RIGHT', -3, 0)
				else
					self.text:SetPoint('RIGHT', self, 'LEFT',3, 0)
				end
				self.text:SetJustifyH(Save.toRightTrackText and 'LEFT' or 'RIGHT')
			end

			btn:set_text_point()
			TrackButton.btn[index]=btn
		else
			btn:SetShown(true)
		end
		last=btn

		btn.text:SetText(tab.text)
		btn.factionID= tab.data.factionID
		btn.isFriend= tab.data.friendshipID
		btn.isMajor= tab.data.isMajor
		btn.isParagon= tab.data.isParagon
		btn.name= tab.data.name

		if tab.texture then
			btn:SetNormalTexture(tab.texture)
		elseif tab.atlas then
			btn:SetNormalAtlas(tab.atlas)
		else
			btn:SetNormalTexture(0)
		end
	end

	for index= #faction+1, #TrackButton.btn do
		local btn=TrackButton.btn[index]
		btn.text:SetText('')
		btn:SetShown(false)
		btn:SetNormalTexture(0)
		btn.factionID= nil
		btn.isFriend= nil
		btn.isMajor= nil
		btn.isParagon= nil
		btn.name= nil
	end
end











--初始，监视, 文本
local function Init_TrackButton()
	if not Save.btn or TrackButton then
		return
	end
	TrackButton= WoWTools_ButtonMixin:Cbtn(nil, {icon='hide', size={18,18}, isType2=true})
	--TrackButton.text= WoWTools_LabelMixin:CreateLabel(TrackButton, {color=true})

	TrackButton.texture= TrackButton:CreateTexture()
	TrackButton.texture:SetAllPoints(TrackButton)
	TrackButton.texture:SetAlpha(0.5)

	TrackButton.btn= {}
	TrackButton.Frame= CreateFrame('Frame', nil, TrackButton)
	TrackButton.Frame:SetPoint('BOTTOM')
	TrackButton.Frame:SetSize(1,1)

	function TrackButton:set_Shown()
		local hide= not Save.btn
		or (
		   not Save.notAutoHideTrack and (
				IsInInstance()
				or C_PetBattles.IsInBattle()
				or UnitInVehicle('player')
				or UnitAffectingCombat('player')
			)
	   )
	   	self:SetShown(not hide)
		self.Frame:SetShown(not hide and Save.btnstr)
		Set_TrackButton_Text()
		self:set_Texture()
	end


	function TrackButton:set_Event()
		if not Save.btn then
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
			Set_TrackButton_Text()
		else
			self:set_Shown()
		end
	end)


	function TrackButton:set_Tooltips()
		e.tips:SetOwner(self, "ANCHOR_RIGHT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(e.addName, Initializer:GetName())
		e.tips:AddLine(' ')
		e.tips:AddDoubleLine(e.onlyChinese and '打开/关闭声望界面' or BINDING_NAME_TOGGLECHARACTER2, e.Icon.left)
		e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
		e.tips:AddLine(' ')
		e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' '..(Save.scaleTrackButton or 1), 'Alt+'..e.Icon.mid)
		e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
		e.tips:Show()
	end

	function TrackButton:set_Scale()
		self.Frame:SetScale(Save.scaleTrackButton or 1)
	end

	function TrackButton:set_Texture()
		if Save.btnstr then
			self.texture:SetTexture(0)
		else
			self.texture:SetAtlas(e.Icon.icon)
		end
	end

	function TrackButton:set_Point()
		if Save.point then
			self:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
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
		Save.point={self:GetPoint(1)}
		Save.point[2]=nil
	end)
	TrackButton:SetScript("OnMouseUp", ResetCursor)

	TrackButton:SetScript("OnMouseDown", function(self, d)
		if d=='RightButton' and IsAltKeyDown() then
			SetCursor('UI_MOVE_CURSOR')

		elseif d=='LeftButton' and not IsModifierKeyDown() then--右击, 移动
			ToggleCharacter("ReputationFrame")


		elseif d=='RightButton' and not IsModifierKeyDown() then
			if not self.Menu then
				self.Menu= CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
				e.LibDD:UIDropDownMenu_Initialize(self.Menu, function(_, level)
					local info={
						text= e.onlyChinese and '显示' or SHOW,
						tooltipOnButton=true,
						tooltipTitle=e.onlyChinese and '显示/隐藏' or (SHOW..'/'..HIDE),
						checked= Save.btnstr,
						keepShownOnClick=true,
						func= function()
							Save.btnstr= not Save.btnstr and true or false
							TrackButton:set_Shown()
							ReputationFrame:Update()
						end
					}
					e.LibDD:UIDropDownMenu_AddButton(info, level)


					info={
						text= e.onlyChinese and '向右平移' or BINDING_NAME_STRAFERIGHT,
						checked= Save.toRightTrackText,
						func= function()
							Save.toRightTrackText= not Save.toRightTrackText and true or false
							for _, btn in pairs(TrackButton.btn) do
								btn.text:ClearAllPoints()
								btn:set_text_point()
							end
							ReputationFrame:Update()
						end
					}
					e.LibDD:UIDropDownMenu_AddButton(info, level)

					info={
						text=e.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP,
						icon='bags-greenarrow',
						checked= Save.toTopTrack,
						func= function()
							Save.toTopTrack = not Save.toTopTrack and true or nil
							local last
							for index= 1, #TrackButton.btn do
								local btn=TrackButton.btn[index]
								btn:ClearAllPoints()
								if Save.toTopTrack then
									btn:SetPoint('BOTTOM', last or TrackButton, 'TOP')
								else
									btn:SetPoint('TOP', last or TrackButton, 'BOTTOM')
								end
								last=btn
							end
							ReputationFrame:Update()
						end
					}
					e.LibDD:UIDropDownMenu_AddButton(info, level)

					e.LibDD:UIDropDownMenu_AddSeparator(level)
					info={
						text= e.onlyChinese and '隐藏名称' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, NAME),
						disabled= e.Is_Timerunning and true,
						tooltipOnButton=true,
						tooltipTitle= e.onlyChinese and '仅显示有图标声望' or format(LFG_LIST_CROSS_FACTION, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, FACTION, EMBLEM_SYMBOL)),
						checked= Save.onlyIcon,
						func= function()
							Save.onlyIcon= not Save.onlyIcon and true or nil
							onlyIcon= Save.onlyIcon
							ReputationFrame:Update()
						end
					}
					e.LibDD:UIDropDownMenu_AddButton(info, level)
				end, 'MENU')
			end
			e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)
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
		Set_TrackButton_Text()
	end)

	TrackButton:SetScript("OnMouseWheel", function(self, d)--打开,关闭, 声望
		if IsAltKeyDown() then--缩放
			local num
			num= Save.scaleTrackButton or 1
			if d==1 then
				num= num + 0.05
			elseif d==-1 then
				num= num - 0.05
			end
			num= num<0.4 and 0.4 or num
			num= num>4 and 4 or num
			Save.scaleTrackButton= num
			self:set_Scale()
			self:set_Tooltips()
		end
	end)

	

	hooksecurefunc(ReputationFrame, 'Update', Set_TrackButton_Text)	--更新, 监视, 文本


	TrackButton:set_Scale()
	TrackButton:set_Point()
	TrackButton:set_Event()
	TrackButton:set_Shown()
	TrackButton:set_Texture()
	Set_TrackButton_Text()






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

end

























--#########
--界面, 增强
--#########
local function set_ReputationFrame_InitReputationRow(btn)--factionRow, elementData)--ReputationFrame.lua
	local data= btn.elementData or {}
	local factionID = data.factionID --or btn.factionIndex
	local frame = btn.Content
	if not frame or factionID==0 then
		return
	end

	local bar = frame.ReputationBar;
	--[[elementData
    --factionID, description, name, reaction
    --hasBonusRepCain, isHeaderWithRep, isHeader, canSetInactive, atWarWith, isWatched, isCollapsed, canToggleAtWar, isAccountWide, isChild
    --currentReactionThresholod, nextReactionThreshold, currentStanding
	]]

	if Save.notPlus then
		frame.Name:SetTextColor(1,1,1)
		if frame.watchedIcon then--显示为经验条
			frame.watchedIcon:SetShown(false)
		end
		if frame.completed then--完成次数
			frame.completed:SetText('')
		end
		if frame.levelText then--等级
			frame.levelText:SetText('')
		end
		if frame.texture then--图标
			frame.texture:SetTexture(0)
		end
		if frame.check then
			frame.check:SetShown(false)
		end
		return
	end


	local barColor, levelText, texture, atlas,isCapped
	local isMajorFaction = C_Reputation.IsMajorFaction(factionID);
	local repInfo = C_GossipInfo.GetFriendshipReputation(factionID);

	if repInfo and repInfo.friendshipFactionID and repInfo.friendshipFactionID > 0 then--好友声望
		local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID)
		texture= repInfo and repInfo.texture
		if rankInfo and rankInfo.maxLevel>0 then
			if repInfo.nextThreshold then
				levelText= rankInfo.currentLevel..'/'..rankInfo.maxLevel
			else
				barColor= FACTION_ORANGE_COLOR
				isCapped= true
			end
		end

	elseif isMajorFaction then-- 名望
		local info = C_MajorFactions.GetMajorFactionData(factionID)
			if info then
				atlas= info.textureKit and 'MajorFactions_Icons_'..info.textureKit..'512'
			if C_MajorFactions.HasMaximumRenown(factionID) then
				barColor=FACTION_ORANGE_COLOR
				isCapped=true
			else
				barColor = GREEN_FONT_COLOR
				if info.renownLevel then
					local levels = C_MajorFactions.GetRenownLevels(factionID)
					if levels then
						levelText= info.renownLevel..'/'..#levels
					end
				end
			end
		end

	elseif data.reaction then
		if data.reaction == MAX_REPUTATION_REACTION then--已满
			barColor=FACTION_ORANGE_COLOR
			isCapped=true
		else
			barColor = FACTION_BAR_COLORS[data.reaction]
			levelText= data.reaction..'/'..MAX_REPUTATION_REACTION
		end
	end

	if barColor then--标题, 颜色
		if isCapped and C_Reputation.IsAccountWideReputation(factionID) then
			frame.Name:SetTextColor(0, 0.8, 1)
		else
			frame.Name:SetTextColor(barColor.r, barColor.g, barColor.b)
		end
	end

	--[[if data.isWatched and not bar.watchedIcon then--显示为经验条
		frame.watchedIcon=bar:CreateTexture(nil, 'OVERLAY')
		frame.watchedIcon:SetPoint('LEFT')
		frame.watchedIcon:SetAtlas('common-icon-checkmark-yellow')
		frame.watchedIcon:SetSize(16, 16)
	end
	if frame.watchedIcon then
		frame.watchedIcon:SetShown(data.isWatched)
	end]]

	local completedParagon--完成次数
	if isCapped and C_Reputation.IsFactionParagon(factionID) then--奖励
		local currentValue, threshold, _, _, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID)
		local completed=0
		if currentValue and threshold then
			if not tooLowLevelForParagon then
				completed= math.modf(currentValue/threshold)--完成次数
				completedParagon= completed>0 and completed
			end
		end
	end
	if completedParagon and not frame.completed then
		frame.completed= WoWTools_LabelMixin:CreateLabel(bar)
		frame.completed:SetPoint('RIGHT', frame.ParagonIcon, 'LEFT', 4,0)
	end
	if frame.completed then
		frame.completed:SetText(completedParagon or '')
	end

	if barColor and isCapped then
		bar:SetStatusBarColor(barColor.r, barColor.g, barColor.b)
	end

	if levelText and not frame.levelText then--等级
		frame.levelText= WoWTools_LabelMixin:CreateLabel(bar, {size=10})--10, nil, nil, nil, nil, 'RIGHT')
		frame.levelText:SetPoint('RIGHT')
	end
	if frame.levelText then
		frame.levelText:SetText(levelText or '')
	end

	if (texture or atlas) and not frame.texture then--图标
		local h=frame:GetHeight() or 20
		frame.texture= frame:CreateTexture(nil, 'OVERLAY')
		frame.texture:SetPoint('RIGHT', frame.Name, 'RIGHT',6,0)
		frame.texture:SetSize(h, h)
	end

	if frame.texture then
		if texture then
			frame.texture:SetTexture(texture)
		elseif atlas then
			frame.texture:SetAtlas(atlas)
		else
			frame.texture:SetTexture(0)
		end
	end

	if not frame.check then
		frame.check= CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
		frame.check:SetPoint('LEFT',-12,0)
		function frame.check:get_info()
			return self:GetParent():GetParent().elementData or {}
		end
		frame.check:SetScript('OnClick', function(self)
			local info= self:get_info()
			if info.factionID then
				Save.factions[info.factionID]= not Save.factions[info.factionID] and (info.factionIndex or 1) or nil
				ReputationFrame:Update()
			end
		end)
		frame.check:SetScript('OnEnter', function(self)
			local info= self:get_info()
			if not info.factionID then
				return
			end
			e.tips:SetOwner(self, "ANCHOR_LEFT")
			e.tips:ClearLines()
			e.tips:AddDoubleLine(e.addName, Initializer:GetName())
			e.tips:AddDoubleLine(e.onlyChinese and '追踪' or TRACKING, e.onlyChinese and '指定' or COMBAT_ALLY_START_MISSION)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(e.cn(info.name), info.factionID, 0,1,0,0,1,0)
			e.tips:Show()
			self:SetAlpha(1)
		end)
		frame.check:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.3) end)
		frame.check:SetSize(18,22)
		frame.check:SetCheckedTexture(e.Icon.icon)
	end
	frame.check:SetShown(true)
	frame.check:SetChecked(Save.factions[factionID])
	frame.check:SetAlpha(0.3)

	frame.AccountWideIcon:SetShown(data.isAccountWide)--战团
end
















--#############
--声望更新, 提示
--#############
local function WoWTools_Faction_Updata_Filter(_, _, text, ...)
	local name
	if text then
		name= text:match(FACTION_STANDING_INCREASED) or text:match(FACTION_STANDING_INCREASED_ACCOUNT_WIDE)
	end

	if not name then
		return
	end

	for i=1, C_Reputation.GetNumFactions() do
		local data= C_Reputation.GetFactionDataByIndex(i) or {}
		local name2= data.name
		local factionID= data.factionID
		if name2==name and factionID then
			local cnName= e.cn(name)
			if cnName then
				local num= text:match('%d+')
				if num then
					text= format("你在%s中的声望值提高了%s点。", cnName, num)
				else
					text= text:gsub(name, cnName)
				end
			end

			local info= WoWTools_FactionMixin:GetInfo(factionID, nil, true)
			text= text..(info.atla and '|A:'..info.atlas..':0:0|a' or (info.texture and '|T'..info.texture..':0|t') or '')
				..(info.factionStandingtext or '')
				..(info.hasRewardPending or '')..(info.valueText and ' '..info.valueText or '')

			return false, text, ...
		end
	end
end





























--#####
--主菜单
--#####
local function InitMenu(_, level, type)
	local info
	if type=='INDICATOLIST' then
		local find
		for factionID, index in pairs(Save.factions) do
			local name2= (C_Reputation.GetFactionDataByID(factionID) or {}).name
			if name2 then
				local name= e.cn(name2)..' '..factionID
				info={
					text= name..' |cnGREEN_FONT_COLOR:'..index..'|r',
					tooltipOnButton=true,
					colorCode= not Save.indicato and '|cff9e9e9e' or nil,
					tooltipTitle= e.onlyChinese and '移除' or REMOVE,
					notCheckable= true,
					arg1= name2,
					arg2= factionID,
					func= function(_,arg1, arg2)
						Save.factions[arg2]=nil
						ReputationFrame:Update()
						print(e.addName, Initializer:GetName(), e.onlyChinese and '移除' or REMOVE, arg1, arg2)
					end
				}
				find=true
				e.LibDD:UIDropDownMenu_AddButton(info, level)
			end
		end
		if find then
			e.LibDD:UIDropDownMenu_AddSeparator(level)
			info={
				text= e.onlyChinese and '全部清除' or CLEAR_ALL,
				notCheckable=true,
				func= function()
					Save.factions={}
					ReputationFrame:Update()
				end
			}
			e.LibDD:UIDropDownMenu_AddButton(info, level)
		else
			info={
				text= e.onlyChinese and '无' or NONE,
				notCheckable=true,
				isTitle=true,
			}
			e.LibDD:UIDropDownMenu_AddButton(info, level)
		end

	elseif type=='RestPoint' then
		info={
			text= e.onlyChinese and '自动隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE),
			checked= not Save.notAutoHideTrack,
			tooltipOnButton=true,
			tooltipTitle= (e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)..'|n'
				..(e.onlyChinese and '宠物对战' or SHOW_PET_BATTLES_ON_MAP_TEXT)..'|n'
				..(e.onlyChinese and '在副本中' or AGGRO_WARNING_IN_INSTANCE),
			func= function()
				Save.notAutoHideTrack= not Save.notAutoHideTrack and true or nil
				if TrackButton then
					TrackButton:set_Shown()
				end
			end
		}
		e.LibDD:UIDropDownMenu_AddButton(info, level)
		e.LibDD:UIDropDownMenu_AddSeparator(level)
		info={
			text=e.onlyChinese and '重置位置' or RESET_POSITION,
			colorCode= (not Save.point or not TrackButton) and '|cff9e9e9e' or nil,
			notCheckable=true,
			keepShownOnClick=true,
			func= function()
				Save.point=nil
				if TrackButton then
					TrackButton:ClearAllPoints()
					TrackButton:set_Point()
				end
				print(e.addName, Initializer:GetName(), e.onlyChinese and '重置位置' or RESET_POSITION)
			end
		}
		e.LibDD:UIDropDownMenu_AddButton(info, level)
	end

	if type then
		return
	end

	info={
		text= e.onlyChinese and '追踪' or TRACKING,
		checked= Save.btn,
		hasArrow=true,
		menuList='RestPoint',
		func= function()
			Save.btn= not Save.btn and true or nil
			if TrackButton then
				TrackButton:set_Shown()
			else
				Init_TrackButton()--监视, 文本
			end
			print(e.addName, Initializer:GetName(),e.onlyChinese and '追踪' or TRACKING, e.GetShowHide(Save.btn))
		end
	}
	e.LibDD:UIDropDownMenu_AddButton(info, level)

	info={
		text= (e.onlyChinese and '指定' or COMBAT_ALLY_START_MISSION),
		checked= Save.indicato,
		menuList='INDICATOLIST',
		colorCode= not Save.btn and '|cff9e9e9e' or nil,
		hasArrow=true,
		keepShownOnClick=true,
		func= function()
			Save.indicato= not Save.indicato and true or nil
			ReputationFrame:Update()
		end
	}
	e.LibDD:UIDropDownMenu_AddButton(info, level)

	e.LibDD:UIDropDownMenu_AddSeparator(level)
	info={
		text= (e.onlyChinese and '声望变化' or COMBAT_TEXT_SHOW_REPUTATION_TEXT)..'|A:voicechat-icon-textchat-silenced:0:0|a',
		tooltipOnButton=true,
		tooltipTitle= e.onlyChinese and '展开选项 |A:editmode-down-arrow:16:11:0:-7|a 声望' or HUD_EDIT_MODE_EXPAND_OPTIONS..REPUTATION,
		tooltipText= '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需求' or NEED),
		checked= Save.factionUpdateTips,
		func= function()
			Save.factionUpdateTips= not Save.factionUpdateTips and true or nil
			--set_RegisterEvent_CHAT_MSG_COMBAT_FACTION_CHANGE()--更新, 提示, 事件
			print(e.addName, Initializer:GetName(), e.onlyChinese and '声望变化' or COMBAT_TEXT_SHOW_REPUTATION_TEXT,'|A:voicechat-icon-textchat-silenced:0:0|a', e.GetEnabeleDisable(Save.factionUpdateTips), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
		end
	}
	e.LibDD:UIDropDownMenu_AddButton(info, level)

	info={
		text= 'UI Plus',
		checked= not Save.notPlus,
		func= function()
			Save.notPlus= not Save.notPlus and true or nil
			Button:set_Shown()

			ReputationFrame:Update()
			--print(e.addName, Initializer:GetName(), 'UI Plus', e.GetEnabeleDisable(not Save.notPlus), e.onlyChinese and '需要刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH))
		end
	}
	e.LibDD:UIDropDownMenu_AddButton(info, level)
end

























--######
--初始化
--######
local function Init()
	Button= WoWTools_ButtonMixin:Cbtn(ReputationFrame, {atlas='auctionhouse-icon-favorite',size={22, 22}})
	Button:SetPoint("RIGHT", ReputationFrame.filterDropdown, 'LEFT',-5,0)
	Button:SetScript("OnMouseDown", function(self)
		if not self.Menu then
			self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
    		e.LibDD:UIDropDownMenu_Initialize(self.Menu, InitMenu, 'MENU')
		end
        e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)
    end)
	Button:SetScript('OnEnter', function(self)
		e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.left)
        e.tips:AddDoubleLine(e.addName, Initializer:GetName())
        e.tips:Show()
		Set_TrackButton_Pushed(true)--TrackButton，提示
	end)
	Button:SetScript('OnLeave', function()
		e.tips:Hide()
		Set_TrackButton_Pushed(false)--TrackButton，提示
	end)

	function Button:set_expand_collapse(show)
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

	Button.up= WoWTools_ButtonMixin:Cbtn(Button, {size={22,22}, atlas='NPE_ArrowUp'})--texture='Interface\\Buttons\\UI-PlusButton-Up'})--收起所有
	Button.up:SetPoint("RIGHT", Button, 'LEFT',-2,0)
	Button.up:SetScript("OnClick", function(self)
		self:GetParent():set_expand_collapse(false)
	end)
	Button.up:SetScript("OnLeave", GameTooltip_Hide)
	Button.up:SetScript('OnEnter', function(self)
		e.tips:SetOwner(self, "ANCHOR_LEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(' ', e.onlyChinese and '收起选项|A:editmode-up-arrow:16:11:0:3|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS)
		e.tips:AddDoubleLine(e.addName, Initializer:GetName())
		e.tips:Show()
	end)

	Button.down= WoWTools_ButtonMixin:Cbtn(Button, {size={22,22}, atlas='NPE_ArrowDown'})--texture='Interface\\Buttons\\UI-MinusButton-Up'})--展开所有
	Button.down:SetPoint("RIGHT", Button.up, 'LEFT',-2,0)
	Button.down:SetScript("OnClick", function(self)
		self:GetParent():set_expand_collapse(true)
	end)
	Button.down:SetScript("OnLeave", GameTooltip_Hide)
	Button.down:SetScript('OnEnter', function(self)
		e.tips:SetOwner(self, "ANCHOR_LEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(' ', e.onlyChinese and '展开选项|A:editmode-down-arrow:16:11:0:-7|a' or HUD_EDIT_MODE_EXPAND_OPTIONS)
		e.tips:AddDoubleLine(e.addName, Initializer:GetName())
		e.tips:Show()
	end)

	function Button:set_Shown()
		self.up:SetShown(not Save.notPlus)
	end

	hooksecurefunc(ReputationFrame.ScrollBox, 'Update', function(self)
		if not self:GetView() then
            return
        end
		for _, btn in pairs(self:GetFrames()or {}) do
			set_ReputationFrame_InitReputationRow(btn)
		end
	end)

	Button:set_Shown()

	if Save.factionUpdateTips then--声望更新, 提示
		ChatFrame_AddMessageEventFilter('CHAT_MSG_COMBAT_FACTION_CHANGE', WoWTools_Faction_Updata_Filter)

		C_Timer.After(2, function()
			local text
			for i=1, C_Reputation.GetNumFactions() do--声望更新, 提示
				local data= C_Reputation.GetFactionDataByIndex(i) or {}
				local name= data.name
				local factionID= data.factionID
				if name and factionID and C_Reputation.IsFactionParagon(factionID) and select(4, C_Reputation.GetFactionParagonInfo(factionID)) then--奖励
					text= text and text..' ' or ''

					local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)
					if repInfo and repInfo.texture and repInfo.texture>0 then
						text= text..'|T'..repInfo.texture..':0|t'
					elseif C_Reputation.IsMajorFaction(factionID) then
						local info = C_MajorFactions.GetMajorFactionData(factionID)
						if info and info.textureKit then
							text= text..'|A:MajorFactions_Icons_'..info.textureKit..'512:0:0|a'
						end
					end
					text= text..e.cn(name)
				end
			end
			if text then
				print(e.addName, Initializer:GetName(), '|cffff00ff'..text..'|r', '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '你有未领取的奖励' or WEEKLY_REWARDS_UNCLAIMED_TITLE))
			end
		end)
	end

	C_Timer.After(4, Init_TrackButton)--监视, 文本
end



















--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
		if arg1==id then
            Save= WoWToolsSave[addName] or Save
			Save.factions= Save.factions or {}

			if e.Is_Timerunning then--隐藏名称
				onlyIcon=nil
			else
				onlyIcon= Save.onlyIcon
			end

			--添加控制面板
            Initializer= e.AddPanel_Check({
                name= format('|A:%s:0:0|a%s', e.Icon[e.Player.faction] or '', e.onlyChinese and '声望' or addName),
                tooltip= e.cn(addName),
                GetValue= function() return not Save.disabled end,
                SetValue= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(e.addName, Initializer:GetName(), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })



            if not Save.disabled then
				FACTION_STANDING_INCREASED= LOCALE_zhCN and '你在(.+)中的声望值提高了.+点。' or e.Magic(FACTION_STANDING_INCREASED)
				FACTION_STANDING_INCREASED_ACCOUNT_WIDE= LOCALE_zhCN and '你的战团在(.+)中的声望值提高了.+点。' or e.Magic(FACTION_STANDING_INCREASED_ACCOUNT_WIDE)

                Init()
            end
            self:UnregisterEvent('ADDON_LOADED')
		end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)
