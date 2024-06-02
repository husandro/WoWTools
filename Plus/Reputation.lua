---@diagnostic disable: redundant-parameter
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


local onlyIcon














local function get_Faction_Info(index, factionID)
	local name, standingID, barMin, barMax, barValue, isHeader,  hasRep,  _
	if index then
		name, _, standingID, barMin, barMax, barValue, _, _, isHeader, _, hasRep, _, _, factionID= GetFactionInfo(index)
	else
		name, _, standingID, barMin, barMax, barValue, _, _, isHeader, _, hasRep, _, _, factionID= GetFactionInfoByID(factionID)
	end

	if not factionID or not name or name==HIDE or (not hasRep and isHeader) then
		return
	end
	local factionStandingtext, value, texture, atlas, barColor

	local isCapped= standingID == MAX_REPUTATION_REACTION--8
	local isMajorFaction = C_Reputation.IsMajorFaction(factionID)
	local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)
	local friendshipID--个人声望

	if repInfo and repInfo.friendshipFactionID> 0 then--个人声望
		if repInfo.nextThreshold then
			factionStandingtext = e.cn(repInfo.reaction)
			local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID)
			if rankInfo and rankInfo.maxLevel>0  and rankInfo.currentLevel~=rankInfo.maxLevel then
				if Save.toRightTrackText then--向右平移 
					factionStandingtext= (factionStandingtext and factionStandingtext..' ' or '')..rankInfo.currentLevel..'/'..rankInfo.maxLevel
				else
					factionStandingtext= rankInfo.currentLevel..'/'..rankInfo.maxLevel..(factionStandingtext and ' '..factionStandingtext or '')

				end
				barColor= FACTION_BAR_COLORS[standingID]
			end
			value= format('%i%%', repInfo.standing/repInfo.nextThreshold*100)
			isCapped= false
			friendshipID= repInfo.friendshipFactionID
		else
			if factionID then-- 隐藏最高级, 且没有奖励声望
				value= '|cff606060'..(e.onlyChinese and '已满' or VIDEO_OPTIONS_ULTRA_HIGH)..'|r'
			end
			isCapped=true
		end
		texture=repInfo.texture--图标

	elseif isMajorFaction then--名望
		isCapped=C_MajorFactions.HasMaximumRenown(factionID)
		local info = C_MajorFactions.GetMajorFactionData(factionID)
		if not isCapped then
			if info then
				if info.renownLevel then
					factionStandingtext= info.renownLevel
					local levels = C_MajorFactions.GetRenownLevels(factionID)
					if levels then
						factionStandingtext= factionStandingtext..'/'..#levels
					end
				end
				--if Save.toRightTrackText then--向右平移 
					value= format('%i%%', info.renownReputationEarned/info.renownLevelThreshold*100)
				--else
					--value= format('%i%%', info.renownReputationEarned/info.renownLevelThreshold*100)
				--end
				barColor= GREEN_FONT_COLOR
			end
		else
			if factionID then-- 隐藏最高级, 且没有奖励声望
				value= '|cff606060'..(e.onlyChinese and '最高' or VIDEO_OPTIONS_ULTRA_HIGH)..'|r'
			end
		end

		atlas=(info and info.textureKit) and 'MajorFactions_Icons_'..info.textureKit..'512'

	else
		if (isHeader and hasRep) or not isHeader then
			if not isCapped then
				factionStandingtext = e.cn(GetText("FACTION_STANDING_LABEL"..standingID, e.Player.sex))
				if barValue and barMax then
					if barMax==0 then
						value= format('%i%%', (barMin-barValue)/barMin*100)
					else
						value= format('%i%%', barValue/barMax*100)
					end
					if Save.toRightTrackText then--向右平移 
						factionStandingtext= factionStandingtext..' '..standingID..'/'..MAX_REPUTATION_REACTION
					else
						factionStandingtext= standingID..'/'..MAX_REPUTATION_REACTION..' '..factionStandingtext
					end
					barColor= FACTION_BAR_COLORS[standingID]
				end
			else
				if factionID then-- 隐藏最高级, 且没有奖励声望
					value= '|cff606060'..(e.onlyChinese and '最高' or VIDEO_OPTIONS_ULTRA_HIGH)..'|r'
				end
			end
		end
	end

	local isParagon = C_Reputation.IsFactionParagon(factionID)--奖励
	local hasRewardPending
	if isParagon then--奖励
		local currentValue, threshold, rewardQuestID, hasRewardPending2, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID);
		hasRewardPending= hasRewardPending2 and '|A:Banker:0:0|a' or nil
		if not tooLowLevelForParagon and currentValue and threshold then
			local completed= math.modf(currentValue/threshold)--完成次数
			currentValue= completed>0 and currentValue - threshold * completed or currentValue
			if Save.toRightTrackText then--向右平移 
				value= '('..completed..') '..format('%i%%', currentValue/threshold*100)
			else
				value= format('%i%%', currentValue/threshold*100)..' ('..completed..')'
			end
		end
	end

	if (isCapped and not isParagon and index)--声望已满，没有奖励
		or (onlyIcon and not atlas and not texture)
	then
		return
	end

	local text
	if onlyIcon then--仅显示有图标
		name=nil
	else
		name= e.cn(name)
		name= name:match('%- (.+)') or name
	end
	
	if Save.toRightTrackText then--向右平移 
		text= name and e.cn(name)..' ' or ''
		if factionStandingtext then--等级
			factionStandingtext= barColor and barColor:WrapTextInColorCode(factionStandingtext) or factionStandingtext
			text= text..factionStandingtext..' '
		end
		if value then--值
			value= (not factionStandingtext and barColor) and barColor:WrapTextInColorCode(value) or value
			text= text..value
		end
		text= hasRewardPending and text..hasRewardPending or text--有奖励
	else

		text= hasRewardPending or ''--有奖励
		if value then--值
			value= (not factionStandingtext and barColor) and barColor:WrapTextInColorCode(value) or value
			text= text..value
		end

		if factionStandingtext then--等级
			factionStandingtext= barColor and barColor:WrapTextInColorCode(factionStandingtext) or factionStandingtext
			text= text..' '..factionStandingtext
		end
		text= name and text..' '..name or text
	end
	return text, texture, atlas, factionID, friendshipID
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
local function Set_SetOwner(self)
	if Save.toRightTrackText then
		GameTooltip:SetOwner(self.text, "ANCHOR_RIGHT");
	else
		GameTooltip:SetOwner(self.text, "ANCHOR_LEFT");
	end
end








--个人，声望，提示
local function ShowFriendshipReputationTooltip(self)--ReputationFrame.lua
	local repInfo = C_GossipInfo.GetFriendshipReputation(self.friendshipID);--ReputationFrame.lua
	if ( repInfo and repInfo.friendshipFactionID and repInfo.friendshipFactionID > 0) then
		Set_SetOwner(self)
		local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(repInfo.friendshipFactionID);
		if ( rankInfo.maxLevel > 0 ) then
			GameTooltip:SetText(e.cn(repInfo.name).." ("..rankInfo.currentLevel.." / "..rankInfo.maxLevel..")", 1, 1, 1);
		else
			GameTooltip:SetText(e.cn(repInfo.name), 1, 1, 1);
		end
		GameTooltip:AddLine(e.cn(repInfo.text), nil, nil, nil, true);
		if ( repInfo.nextThreshold ) then
			local current = repInfo.standing - repInfo.reactionThreshold;
			local max = repInfo.nextThreshold - repInfo.reactionThreshold;
			GameTooltip:AddLine(e.cn(repInfo.reaction).." ("..current.." / "..max..")" , 1, 1, 1, true);
		else
			GameTooltip:AddLine(e.cn(repInfo.reaction), 1, 1, 1, true);
		end
		GameTooltip:AddLine(' ')
		GameTooltip:AddDoubleLine('friendshipID', self.factionID)
		GameTooltip:Show();
	end
end

--名望，提示
local function ShowMajorFactionRenownTooltip(self)--ReputationFrame.lua
	local function AddRenownRewardsToTooltip(renownRewards)
		GameTooltip_AddHighlightLine(GameTooltip, e.onlyChinese and '接下来的奖励：' or MAJOR_FACTION_BUTTON_TOOLTIP_NEXT_REWARDS);
		for i, rewardInfo in ipairs(renownRewards) do
			local renownRewardString;
			local icon, name = RenownRewardUtil.GetRenownRewardInfo(rewardInfo, GenerateClosure(self.ShowMajorFactionRenownTooltip, self));
			if icon then
				local file, width, height = icon, 16, 16;
				local rewardTexture = CreateSimpleTextureMarkup(file, width, height);
				renownRewardString = rewardTexture .. " " ..e.cn(name);
			end
			local wrapText = false;
			GameTooltip_AddNormalLine(GameTooltip, renownRewardString, wrapText);
		end
	end
	Set_SetOwner(self)
	local majorFactionData = C_MajorFactions.GetMajorFactionData(self.factionID) or {};
	local tooltipTitle = e.cn(majorFactionData.name)
	GameTooltip_SetTitle(GameTooltip, tooltipTitle, NORMAL_FONT_COLOR);
	GameTooltip_AddColoredLine(GameTooltip, (e.onlyChinese and '名望' or RENOWN_LEVEL_LABEL)..majorFactionData.renownLevel, BLUE_FONT_COLOR);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddHighlightLine(GameTooltip, format(e.onlyChinese and '继续获取%s的声望以提升名望并解锁奖励。' or MAJOR_FACTION_RENOWN_TOOLTIP_PROGRESS, majorFactionData.name));
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	local nextRenownRewards = C_MajorFactions.GetRenownRewardsForLevel(self.factionID, C_MajorFactions.GetCurrentRenownLevel(self.factionID) + 1);
	if #nextRenownRewards > 0 then
		AddRenownRewardsToTooltip(nextRenownRewards);
	end
	GameTooltip:Show();
end

--阵营声望，提示
local function ShowFactionTooltip(self)--Tooltips.lua
	local isParagon = C_Reputation.IsFactionParagon(self.factionID)--奖励			
	local completedParagon--完成次数
	if ( isParagon ) then--奖励
		local currentValue, threshold, _, _, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(self.factionID)
		if not tooLowLevelForParagon then
			local completed= math.modf(currentValue/threshold)--完成次数
			if completed>0 then
				completedParagon=(e.onlyChinese and '奖励 '..completed..' 次' or (QUEST_REWARDS.. ' '..completed..' '..VOICEMACRO_LABEL_CHARGE1))
			end
		end
	end
	local name, description, standingID, barMin, barMax, barValue, _, _, isHeader, _, hasRep, _, _, factionID, _, _ = GetFactionInfoByID(self.factionID)
	if factionID then
		Set_SetOwner(self)
		e.tips:AddLine(e.cn(name)..' '..standingID..'/'..MAX_REPUTATION_REACTION, 1,1,1)
		e.tips:AddLine(e.cn(description), nil,nil,nil, true)
		e.tips:AddLine(' ')
		local gender = e.Player.sex
		local factionStandingtext = e.cn(GetText("FACTION_STANDING_LABEL"..standingID, gender))
		local barColor = FACTION_BAR_COLORS[standingID]
		factionStandingtext=barColor:WrapTextInColorCode(factionStandingtext)--颜色
		if barValue and barMax then
			if barMax==0 then
				e.tips:AddLine(factionStandingtext..' '..('%i%%'):format( (barMin-barValue)/barMin*100), 1,1,1)
			else
				e.tips:AddLine(factionStandingtext..' '..e.MK(barValue, 3)..'/'..e.MK(barMax, 3)..' '..('%i%%'):format(barValue/barMax*100), 1,1,1)
			end
			e.tips:AddLine(' ')
		end
		e.tips:AddDoubleLine((e.onlyChinese and '声望' or REPUTATION)..' '..self.factionID, completedParagon)
		e.tips:Show();
	end
end











--设置 Text
local function Set_TrackButton_Text()
	if not TrackButton or not TrackButton:IsShown() then
		return
	end
	local faction={}
	if Save.indicato then
		for factionID, _ in pairs(Save.factions) do
			local text, texture, atlas, _, friendshipID= get_Faction_Info(nil, factionID)
			if text then
				table.insert(faction, {text= text, texture=texture, atlas=atlas, factionID= factionID, friendshipID=friendshipID})
			end
		end
		table.sort(faction, function(a, b) return a.factionID > b.factionID end)
	else
		for index=1, GetNumFactions() do
			local text, texture, atlas, factionID, friendshipID=get_Faction_Info(index, nil)
			if text and factionID then
				table.insert(faction, {text= text, texture=texture, atlas=atlas, factionID= factionID, friendshipID=friendshipID})
			end
		end
	end

	local last
	for index, tab in pairs(faction) do
		local btn= TrackButton.btn[index]
		if not btn then
			btn= e.Cbtn(TrackButton.Frame, {size={14,14}, icon='hide'})
			if Save.toTopTrack then
				btn:SetPoint('BOTTOM', last or TrackButton, 'TOP')
			else
				btn:SetPoint('TOP', last or TrackButton, 'BOTTOM')
			end
			btn:SetScript('OnLeave', function(self)
				e.tips:Hide()
				self.UpdateTooltip= nil
				Set_TrackButton_Pushed(false, self.text)--TrackButton，提示
			end)
			btn:SetScript('OnEnter', function(self)
				if C_Reputation.IsFactionParagon(self.factionID) then--ReputationFrame.lua
					self.UpdateTooltip = ReputationParagonFrame_SetupParagonTooltip;
					Set_SetOwner(self)--设置，提示，位置
					ReputationParagonFrame_SetupParagonTooltip(self)
				else
					if ( self.friendshipID ) then
						ShowFriendshipReputationTooltip(self);--个人，声望，提示

					elseif self.factionID and C_Reputation.IsMajorFaction(self.factionID) and not C_MajorFactions.HasMaximumRenown(self.factionID) then

						ShowMajorFactionRenownTooltip(self);--名望，提示
					else

						ShowFactionTooltip(self)--阵营声望，提示
					end
				end
				Set_TrackButton_Pushed(true, self.text)--TrackButton，提示
			end)

			btn.text= e.Cstr(btn, {color=true})
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
		btn.factionID= tab.factionID
		btn.friendshipID= tab.friendshipID
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
	end
end











--初始，监视, 文本
local function Init_TrackButton()
	if not Save.btn or TrackButton then
		return
	end
	TrackButton= e.Cbtn(nil, {icon='hide', size={18,18}, pushe=true})
	--TrackButton.text= e.Cstr(TrackButton, {color=true})

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
		   not Save.notAutoHideTrack and (IsInInstance() or C_PetBattles.IsInBattle() or UnitAffectingCombat('player'))
	   )
	   	self:SetShown(not hide)
		self.Frame:SetShown(not hide and Save.btnstr)
		Set_TrackButton_Text()
		self:set_Texture()
	end

	function TrackButton:set_Tooltips()
		e.tips:SetOwner(self, "ANCHOR_RIGHT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(id, e.cn(addName))
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
				self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
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
							e.call('ReputationFrame_Update')
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
							e.call('ReputationFrame_Update')
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
							e.call('ReputationFrame_Update')
						end
					}
					e.LibDD:UIDropDownMenu_AddButton(info, level)

					e.LibDD:UIDropDownMenu_AddSeparator(level)
					info={
						text= e.onlyChinese and '隐藏名称' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, NAME),
						disabled= PlayerGetTimerunningSeasonID() and true,
						tooltipOnButton=true,
						tooltipTitle= e.onlyChinese and '仅显示有图标声望' or format(LFG_LIST_CROSS_FACTION, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, FACTION, EMBLEM_SYMBOL)),
						checked= Save.onlyIcon,
						func= function()
							Save.onlyIcon= not Save.onlyIcon and true or nil
							e.call('ReputationFrame_Update')
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
			print(id, e.cn(addName), e.onlyChinese and '追踪' or TRACKING, e.onlyChinese and '字体大小' or FONT_SIZE, num)
		end
	end)

	function TrackButton:set_Event()
		if not Save.btn then
			self:UnregisterAllEvents()
		else
			self:RegisterEvent('PLAYER_ENTERING_WORLD')
			self:RegisterEvent('PET_BATTLE_OPENING_DONE')
			self:RegisterEvent('PET_BATTLE_CLOSE')
			self:RegisterEvent('UPDATE_FACTION')
			self:RegisterEvent('PLAYER_REGEN_DISABLED')
			self:RegisterEvent('PLAYER_REGEN_ENABLED')
		end
	end

	TrackButton:SetScript('OnEvent', function(self, event)
		if event=='UPDATE_FACTION' then
			Set_TrackButton_Text()
		else
			self:set_Shown()
		end
	end)

	hooksecurefunc('ReputationFrame_Update',Set_TrackButton_Text)--更新, 监视, 文本

	TrackButton:set_Scale()
	TrackButton:set_Point()
	TrackButton:set_Event()
	TrackButton:set_Shown()
	TrackButton:set_Texture()
	Set_TrackButton_Text()
end

























--#########
--界面, 增强
--#########
local function set_ReputationFrame_InitReputationRow(factionRow, elementData)--ReputationFrame.lua
    local factionIndex = elementData.index;
	local frame = factionRow.Container
	local factionBar = frame.ReputationBar;
	--local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canSetInactive
	local _, _, standingID, _, _, _, _, _, isHeader, _, hasRep, isWatched, _, factionID= GetFactionInfo(factionIndex)
	if (isHeader and not hasRep) or not factionID or Save.notPlus then
		if isHeader and not hasRep and frame.Name then
			frame.Name:SetTextColor(1,1,1)
		end
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
	local factionTitle = frame.Name
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

	elseif (isHeader and hasRep) or not isHeader then
		if (standingID == MAX_REPUTATION_REACTION) then--已满
			barColor=FACTION_ORANGE_COLOR
			isCapped=true
		else
			barColor = FACTION_BAR_COLORS[standingID]
			levelText= standingID..'/'..MAX_REPUTATION_REACTION
		end
	end

	if barColor then--标题, 颜色
		factionTitle:SetTextColor(barColor.r, barColor.g, barColor.b)
	end

	if isWatched and not factionBar.watchedIcon then--显示为经验条
		frame.watchedIcon=factionBar:CreateTexture(nil, 'OVERLAY')
		frame.watchedIcon:SetPoint('LEFT')
		frame.watchedIcon:SetAtlas('common-icon-checkmark-yellow')
		frame.watchedIcon:SetSize(16, 16)
	end
	if frame.watchedIcon then
		frame.watchedIcon:SetShown(isWatched)
	end

	local completedParagon--完成次数
	if isCapped and C_Reputation.IsFactionParagon(factionID) then--奖励
		local currentValue, threshold, _, _, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID)
		local completed=0
		if currentValue and threshold then
			if not tooLowLevelForParagon then
				completed= math.modf(currentValue/threshold)--完成次数
				completedParagon= completed>0 and completed
			end
			factionBar:SetMinMaxValues(0, threshold)
			factionBar:SetValue(currentValue-(threshold*completed))
		end
	end
	if completedParagon and not frame.completed then
		frame.completed= e.Cstr(factionBar, {justifyH='RIGHT'})
		frame.completed:SetPoint('RIGHT',- 5,0)
	end
	if frame.completed then
		frame.completed:SetText(completedParagon or '')
	end

	if barColor and isCapped then
		factionBar:SetStatusBarColor(barColor.r, barColor.g, barColor.b)
	end

	if levelText and not frame.levelText then--等级
		frame.levelText= e.Cstr(frame, {size=10, justifyH='RIGHT'})--10, nil, nil, nil, nil, 'RIGHT')
		frame.levelText:SetPoint('RIGHT', frame, 'LEFT',-2,0)
	end
	if frame.levelText then
		frame.levelText:SetText(levelText or '')
	end

	if (texture or atlas) and not frame.texture then--图标
		local h=frame:GetHeight() or 20
		frame.texture= frame:CreateTexture(nil, 'OVERLAY')
		frame.texture:SetPoint('RIGHT', factionTitle, 'RIGHT',6,0)
		frame.texture:SetSize(h,h)
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
		frame.check:SetPoint('LEFT',-4,0)
		frame.check:SetScript('OnClick', function(self)
			if self.factionID then
				Save.factions[self.factionID ]= not Save.factions[self.factionID ] and self.factionIndex or nil
				e.call('ReputationFrame_Update')
			end
		end)
		frame.check:SetScript('OnEnter', function(self)
			e.tips:SetOwner(self, "ANCHOR_LEFT")
			e.tips:ClearLines()
			if self.factionID then
				local name2=GetFactionInfoByID(self.factionID)
				e.tips:AddDoubleLine(name2, self.factionID, 0,1,0,0,1,0)
				e.tips:AddLine(' ')
			end
			e.tips:AddDoubleLine(e.onlyChinese and '追踪' or TRACKING, e.onlyChinese and '指定' or COMBAT_ALLY_START_MISSION)
			e.tips:AddDoubleLine(id, e.cn(addName))
			e.tips:Show()
			self:SetAlpha(1)
		end)
		frame.check:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.3) end)
		frame.check:SetSize(18,22)
		frame.check:SetCheckedTexture(e.Icon.icon)
	end
	frame.check:SetShown(true)
	frame.check.factionID= factionID
	frame.check.factionIndex= factionIndex
	frame.check:SetChecked(Save.factions[factionID])
	frame.check:SetAlpha(0.3)
end
















--#############
--声望更新, 提示
--#############
local factionStr= FACTION_STANDING_INCREASED:gsub("%%s", "(.-)")--你在%s中的声望值提高了%d点。
factionStr = factionStr:gsub("%%d", ".-")
local function Set_Faction_Update(_, _, text, ...)
	local name=text and text:match(factionStr)
	if not name then
		return
	end

	for i=1, GetNumFactions() do
		local name2, _, standingID, barMin, barMax, barValue, _, _, _, _, _, _, _, factionID = GetFactionInfo(i)
		if name2==name and factionID then
			local isCapped= standingID == MAX_REPUTATION_REACTION
			local factionStandingtext, value, icon
			local barColor = FACTION_BAR_COLORS[standingID]
			local isMajorFaction = C_Reputation.IsMajorFaction(factionID)
			local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)
			if (repInfo and repInfo.friendshipFactionID > 0) then--个人声望
				factionStandingtext = repInfo.reaction
				if ( repInfo.nextThreshold ) then
					value=('%i%%'):format(repInfo.standing/repInfo.nextThreshold*100);
					barColor = FACTION_BAR_COLORS[standingID]
				else
					barColor = FACTION_ORANGE_COLOR
					isCapped=true
				end
				if repInfo.texture then--图标
					icon='|T'..repInfo.texture..':0|t'
				end
			elseif ( isMajorFaction ) then--名望
				isCapped=C_MajorFactions.HasMaximumRenown(factionID)
				local info = C_MajorFactions.GetMajorFactionData(factionID);
				if isCapped then
					barColor = FACTION_ORANGE_COLOR
					value= e.onlyChinese and '已满' or VIDEO_OPTIONS_ULTRA_HIGH
				else
					barColor = GREEN_FONT_COLOR
					if info then
						if info.name and info.name~=name then
							factionStandingtext=name
						end
						value= (e.onlyChinese and '名望' or RENOWN_LEVEL_LABEL)..' '..info.renownLevel.. (' %i%%'):format(info.renownReputationEarned/info.renownLevelThreshold*100)--名望 RENOWN_LEVEL_LABEL
					end
				end
				if info and info.textureKit then
					icon='|A:MajorFactions_Icons_'..info.textureKit..'512:0:0|a'
				end
			else
				factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID, e.Player.sex)
				if isCapped then
					barColor = FACTION_ORANGE_COLOR
				elseif barValue and barMax then
					if barMax==0 then
						value=format('%i%%', (barMin-barValue)/barMin*100)
					else
						value=format('%i%%', barValue/barMax*100)
					end
				end
			end

			local hasRewardPending, rewardQuestID
			if C_Reputation.IsFactionParagon(factionID) then--奖励
				local currentValue, threshold, rewardQuestID2, hasRewardPending2, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID);
				hasRewardPending=hasRewardPending2
				rewardQuestID= rewardQuestID2
				if not tooLowLevelForParagon then
					local completed= math.modf(currentValue/threshold)
					currentValue= completed>0 and currentValue - threshold*completed or currentValue
					value= '|cnGREEN_FONT_COLOR:'..format('%i%%',currentValue/threshold*100)..'|r'..(completed>0 and ' '..(e.onlyChinese and '奖励' or QUEST_REWARDS)..'|cnGREEN_FONT_COLOR: '..completed..' |r'..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1) or '')
				end
			end
			local m= e.cn(factionStandingtext) or ''
			if barColor then
				m= barColor:WrapTextInColorCode(m)
			end
			if value then
				m=m..' |cffff00ff'..value..'|r'
			end
			m=(icon or ('|A:'..e.Icon.icon..':0:0|a'))..m
			if hasRewardPending then
				m=m..'|A:Banker:0:0|a'..(rewardQuestID and GetQuestLink(rewardQuestID) or '')
			end
			local cnName= e.cn(name)
			if cnName then
				local num= text:match('%d+')
				if num then
					text= format("你在%s中的声望值提高了%s点。", cnName, num)
				else
					text= text:gsub(name, cnName)
				end
			end
			return false, text..m, ...
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
			local name=GetFactionInfoByID(factionID)
			name= name and name..' '..factionID or ('factionID '..factionID)
			info={
				text= name..' |cnGREEN_FONT_COLOR:'..index..'|r',
				tooltipOnButton=true,
				colorCode= not Save.indicato and '|cff606060' or nil,
				tooltipTitle= e.onlyChinese and '移除' or REMOVE,
				notCheckable= true,
				arg1= name,
				arg2= factionID,
				func= function(_,arg1, arg2)
					Save.factions[arg2]=nil
					e.call('ReputationFrame_Update')
					print(id, e.cn(addName), e.onlyChinese and '移除' or REMOVE, arg1, arg2)
				end
			}
			find=true
			e.LibDD:UIDropDownMenu_AddButton(info, level)
		end
		if find then
			e.LibDD:UIDropDownMenu_AddSeparator(level)
			info={
				text= e.onlyChinese and '全部清除' or CLEAR_ALL,
				notCheckable=true,
				func= function()
					Save.factions={}
					e.call('ReputationFrame_Update')
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
			colorCode= (not Save.point or not TrackButton) and '|cff606060' or nil,
			notCheckable=true,
			keepShownOnClick=true,
			func= function()
				Save.point=nil
				if TrackButton then
					TrackButton:ClearAllPoints()
					TrackButton:set_Point()
				end
				print(id, e.cn(addName), e.onlyChinese and '重置位置' or RESET_POSITION)
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
			print(id, e.cn(addName),e.onlyChinese and '追踪' or TRACKING, e.GetShowHide(Save.btn))
		end
	}
	e.LibDD:UIDropDownMenu_AddButton(info, level)

	info={
		text= (e.onlyChinese and '指定' or COMBAT_ALLY_START_MISSION),
		checked= Save.indicato,
		menuList='INDICATOLIST',
		colorCode= not Save.btn and '|cff606060' or nil,
		hasArrow=true,
		keepShownOnClick=true,
		func= function()
			Save.indicato= not Save.indicato and true or nil
			e.call('ReputationFrame_Update')
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
			print(id, e.cn(addName), e.onlyChinese and '声望变化' or COMBAT_TEXT_SHOW_REPUTATION_TEXT,'|A:voicechat-icon-textchat-silenced:0:0|a', e.GetEnabeleDisable(Save.factionUpdateTips), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
		end
	}
	e.LibDD:UIDropDownMenu_AddButton(info, level)

	info={
		text= 'UI Plus',
		checked= not Save.notPlus,
		func= function()
			Save.notPlus= not Save.notPlus and true or nil
			Button:set_Shown()

			e.call('ReputationFrame_Update')
			--print(id, e.cn(addName), 'UI Plus', e.GetEnabeleDisable(not Save.notPlus), e.onlyChinese and '需要刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH))
		end
	}
	e.LibDD:UIDropDownMenu_AddButton(info, level)
end

























--######
--初始化
--######
local function Init()
	Button= e.Cbtn(ReputationFrame, {atlas='auctionhouse-icon-favorite',size={18, 18}})
	Button:SetPoint("LEFT", ReputationFrameStandingLabel, 'RIGHT',5,0)
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
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:Show()
		Set_TrackButton_Pushed(true)--TrackButton，提示
	end)
	Button:SetScript('OnLeave', function()
		e.tips:Hide()
		Set_TrackButton_Pushed(false)--TrackButton，提示
	end)

	Button.up= e.Cbtn(Button, {size={22,22}, atlas='NPE_ArrowUp'})--texture='Interface\\Buttons\\UI-PlusButton-Up'})--收起所有
	Button.up:SetPoint("LEFT", ReputationFrameFactionLabel, 'RIGHT',5,0)
	Button.up:SetScript("OnClick", function()
		for i=GetNumFactions(), 1, -1 do
			CollapseFactionHeader(i)
		end
	end)
	Button.up:SetScript("OnLeave", GameTooltip_Hide)
	Button.up:SetScript('OnEnter', function(self)
		e.tips:SetOwner(self, "ANCHOR_LEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(' ', e.onlyChinese and '收起选项|A:editmode-up-arrow:16:11:0:3|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS)
		e.tips:AddDoubleLine(id, e.cn(addName))
		e.tips:Show()
	end)

	Button.down= e.Cbtn(Button.up, {size={22,22}, atlas='NPE_ArrowDown'})--texture='Interface\\Buttons\\UI-MinusButton-Up'})--展开所有
	Button.down:SetPoint('LEFT', Button.up, 'RIGHT')
	Button.down:SetScript("OnClick", ExpandAllFactionHeaders)
	Button.down:SetScript("OnLeave", GameTooltip_Hide)
	Button.down:SetScript('OnEnter', function(self)
		e.tips:SetOwner(self, "ANCHOR_LEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(' ', e.onlyChinese and '展开选项|A:editmode-down-arrow:16:11:0:-7|a' or HUD_EDIT_MODE_EXPAND_OPTIONS)
		e.tips:AddDoubleLine(id, e.cn(addName))
		e.tips:Show()
	end)

	function Button:set_Shown()
		self.up:SetShown(not Save.notPlus)
	end

	C_Timer.After(2, Init_TrackButton)--监视, 文本
	hooksecurefunc('ReputationFrame_InitReputationRow', set_ReputationFrame_InitReputationRow)-- 声望, 界面, 增强
	Button:set_Shown()

	if Save.factionUpdateTips then--声望更新, 提示
		ChatFrame_AddMessageEventFilter('CHAT_MSG_COMBAT_FACTION_CHANGE', Set_Faction_Update)

		local text
		for i=1, GetNumFactions() do--声望更新, 提示
			local name, _, _, _, _, _, _, _, _, _, _, _, _, factionID = GetFactionInfo(i)
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
				text= text..name
			end
		end
		if text then
			print(id, e.cn(addName), '|cffff00ff'..text..'|r', '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '你有未领取的奖励' or WEEKLY_REWARDS_UNCLAIMED_TITLE))
		end
	end
end



















--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
		if arg1==id then
            Save= WoWToolsSave[addName] or Save
			Save.factions= Save.factions or {}

			if PlayerGetTimerunningSeasonID() then--隐藏名称
				onlyIcon=nil
			else
				onlyIcon= Save.onlyIcon
			end

			--添加控制面板
            e.AddPanel_Check({
                name= format('|A:%s:0:0|a%s', e.Icon[e.Player.faction] or '', e.onlyChinese and '声望' or addName),
                tooltip= e.cn(addName),
                value= not Save.disabled,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })


            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
				panel:UnregisterEvent('ADDON_LOADED')
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
		end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)
