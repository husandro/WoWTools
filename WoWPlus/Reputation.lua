---@diagnostic disable: redundant-parameter
local id, e = ...
local Save={
	--btn=true,--启用，TrackButton
	factions={},--指定,显示,声望
	btnstr=true,--文本
	--scaleTrackButton=1,缩放
	btnStrHideCap=true,-- 隐藏最高级, 且没有奖励声望
	btnStrHideHeader=true, --隐藏, 版本标题

	factionUpdateTips=true,--更新, 提示
	--indicato=true,--指定
	--showID=true,--显示ID
	--hideName=true,--隐藏名称
}
local addName=REPUTATION

local Button
local TrackButton
---@class Button
---@class TrackButton


















local function get_Faction_Info(tab)
	local name, standingID, barMin, barMax, barValue, isHeader, isCollapsed, hasRep, isChild, factionID, _
	--local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus
	if tab.index then
		name, _, standingID, barMin, barMax, barValue, _, _, isHeader, isCollapsed, hasRep, _, isChild, factionID= GetFactionInfo(tab.index)
	else
		name, _, standingID, barMin, barMax, barValue, _, _, isHeader, isCollapsed, hasRep, _, isChild, factionID, _, _= GetFactionInfoByID(tab.factionID)
	end

	if tab.hide and name==HIDE then --隐藏 '隐藏声望'
		return
	end

	if (hasRep or ((isHeader or isChild)  and not isCollapsed ) or (not isHeader and not isChild)) and factionID and name then
		local isCapped= standingID == MAX_REPUTATION_REACTION
		local factionStandingtext, value, icon
		--local barColor = FACTION_BAR_COLORS[standingID]

		local isMajorFaction = C_Reputation.IsMajorFaction(factionID)
		local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)

		if (repInfo and repInfo.friendshipFactionID > 0) then--个人声望
			if ( repInfo.nextThreshold ) then
				factionStandingtext = repInfo.reaction
				local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID)
				if rankInfo and rankInfo.maxLevel>0  and rankInfo.currentLevel~=rankInfo.maxLevel then
					factionStandingtext= factionStandingtext..' '..rankInfo.currentLevel..'/'..rankInfo.maxLevel
				end
				value=('%i%%'):format(repInfo.standing/repInfo.nextThreshold*100);
				--barColor = FACTION_BAR_COLORS[standingID]					
			else
				--barColor = FACTION_ORANGE_COLOR
				isCapped=true
			end
			if repInfo.texture and repInfo.texture~=0 then--图标
				icon='|T'..repInfo.texture..':0|t'
			end
		elseif ( isMajorFaction ) then--名望
			isCapped=C_MajorFactions.HasMaximumRenown(factionID)
			local info = C_MajorFactions.GetMajorFactionData(factionID);
			if not isCapped then
				if info then
					if info.name and info.name~=name then
						factionStandingtext=name
					end
					value= info.renownLevel..' '..('%i%%'):format(info.renownReputationEarned/info.renownLevelThreshold*100)--名望RENOWN_LEVEL_LABEL
				end
			else
				value= VIDEO_OPTIONS_ULTRA_HIGH
			end

			if info and info.textureKit then
				icon='|A:MajorFactions_Icons_'..info.textureKit..'512:0:0|a'
			end
		else
			if (isHeader and hasRep) or not isHeader then
				local gender = e.Player.sex
				factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID, gender)
				if barValue and barMax then
					if barMax==0 then
						value=('%i%%'):format( (barMin-barValue)/barMin*100)
					else
						value=('%i%%'):format(barValue/barMax*100)
					end
				end
			end
		end

		local isParagon = C_Reputation.IsFactionParagon(factionID)--奖励			
		local hasRewardPending
		if ( isParagon ) then--奖励
			local currentValue, threshold, rewardQuestID, hasRewardPending2, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID);
			hasRewardPending=hasRewardPending2
			if not tooLowLevelForParagon and  currentValue and threshold then
				local completed= math.modf(currentValue/threshold)--完成次数
				currentValue= completed>0 and currentValue - threshold * completed or currentValue
				value=('%i%%'):format(currentValue/threshold*100)
				--value = completed>0 and value.. ' '..completed or value
			end
		end

		local verHeader= isHeader and not isParagon and not hasRep and not isChild--版本声望
		if not ((Save.btnStrHideCap and isCapped and not isParagon and not isHeader) or (Save.btnStrHideHeader and verHeader))then
			local t=''

			if verHeader then
				t= t.. e.Icon.star2
			end

			if isChild and not isHeader then
				t= t..e.Icon.toRight2..(icon or '')
			elseif not verHeader then
				t= t.. (icon or '    ')
			end
			if tab.name then--名称
				t=t..(name:match('%- (.+)') or name)
			end
			t=t..(factionStandingtext and ' '..factionStandingtext or '')..(value and ' '..value or '')

			if hasRewardPending then--有奖励
				t=t..' '..e.Icon.bank2
			end

			if verHeader then
				t='|cnGREEN_FONT_COLOR:'..t..'|r'
			end
			return t
		end
	end
end












local function Init_TrackButton()--监视, 文本
	if not Save.btn or TrackButton then
		return
	end
	TrackButton= e.Cbtn(nil, {icon='hide', size={20,20}})
	TrackButton.text= e.Cstr(TrackButton, {color=true})
	TrackButton.texture= TrackButton:CreateTexture()
	TrackButton.texture:SetAllPoints(TrackButton)

	function TrackButton:set_Scale()
		if Save.ttoRightTrackText then
			self.text:SetPoint('TOPRIGHT', -3 , -3)
		else
			self.text:SetPoint('TOPLEFT', 3 , -3)
		end
		self.text:SetScale(Save.scaleTrackButton or 1)
	end

	function TrackButton:set_Texture()
		if Save.btnstr then
			self.texture:SetTexture(0)
		else
			self.texture:SetAtlas(e.Icon.icon)
		end
		self.texture:SetAlpha(Save.btnstr and 1 or 0.5)
	end

	function TrackButton:set_Point()
		if Save.point then
			self:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
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
	TrackButton:SetScript("OnMouseDown", function(_, d)
		if d=='RightButton' and IsAltKeyDown() then
			SetCursor('UI_MOVE_CURSOR')
		end
	end)

	TrackButton:SetScript("OnClick", function(self, d)
		if d=='LeftButton' and not IsModifierKeyDown() then--右击, 移动
			ToggleCharacter("ReputationFrame")
		elseif d=='RightButton' and not IsModifierKeyDown() then
			if not self.Menu then
				self.Menu=CreateFrame("Frame", id..addName..'Menu', self, "UIDropDownMenuTemplate")
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
						text= e.onlyChinese and '显示版本' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, GAME_VERSION_LABEL),
						tooltipOnButton=true,
						tooltipTitle=e.onlyChinese and '无声望' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NONE, REPUTATION),
						checked= not Save.btnStrHideHeader,
						colorCode= Save.indicato and '|cff606060' or nil,
						keepShownOnClick=true,
						func= function()
							Save.btnStrHideHeader= not Save.btnStrHideHeader and true or false--隐藏最高声望
							e.call('ReputationFrame_Update')
						end
					}
					e.LibDD:UIDropDownMenu_AddButton(info, level)

					info={
						text= e.onlyChinese and '显示最高声望' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, VIDEO_OPTIONS_ULTRA_HIGH , REPUTATION)),
						tooltipOnButton=true,
						tooltipTitle=e.onlyChinese and '继续获取阵营的声望以赢取奖励。' or format(PARAGON_REPUTATION_TOOLTIP_TEXT, FACTION),
						checked= not Save.btnStrHideCap,
						keepShownOnClick=true,
						func= function()
							Save.btnStrHideCap= not Save.btnStrHideCap and true or false--隐藏最高级, 且没有奖励声望
							e.call('ReputationFrame_Update')
						end
					}
					e.LibDD:UIDropDownMenu_AddButton(info, level)

					info={
						text= e.onlyChinese and '显示名称' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, NAME),
						checked= not Save.hideName,
						func= function()
							Save.hideName= not Save.hideName and true or nil
							e.call('ReputationFrame_Update')
						end
					}
					e.LibDD:UIDropDownMenu_AddButton(info, level)

					info={
						text= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, e.onlyChinese and '显示' or SHOW, 'ID'),
						checked= Save.showID,
						keepShownOnClick=true,
						func= function()
							Save.showID= not Save.showID and true or false
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

	function TrackButton:set_Tooltips()
		e.tips:SetOwner(self, "ANCHOR_LEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(e.onlyChinese and '打开/关闭声望界面' or BINDING_NAME_TOGGLECHARACTER2, e.Icon.left)
		e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
		e.tips:AddLine(' ')
		e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' '..(Save.scaleTrackButton or 1), 'Alt+'..e.Icon.mid)
		e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
		e.tips:AddLine(' ')
		e.tips:AddDoubleLine(id, addName)
		e.tips:Show()
		self.texture:SetAlpha(1)
	end
	TrackButton:SetScript("OnLeave", function(self)
		ResetCursor()
		e.tips:Hide()
		self:set_Texture()
	end)
	TrackButton:SetScript("OnEnter",TrackButton.set_Tooltips)

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
			print(id, addName, e.onlyChinese and '追踪' or TRACKING, e.onlyChinese and '字体大小' or FONT_SIZE, num)
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

	function TrackButton:set_Shown()
		self:SetShown(
			Save.btn
			and not IsInInstance()
			and not C_PetBattles.IsInBattle()
			and not UnitAffectingCombat('player')
		)
		self:set_Text()
		self:set_Texture()
	end

	TrackButton:SetScript('OnEvent', function(self, event)
		if event=='UPDATE_FACTION' then
			self:set_Text()
		else
			self:set_Shown()
		end
	end)


	function TrackButton:set_Text()
		local text
		if Save.btnstr and self:IsShown() then
			if Save.indicato then
				local tab={}
				for factionID, value in pairs(Save.factions) do
					table.insert(tab, {factionID= factionID, index= value==true and 1 or value})
				end
				table.sort(tab, function(a, b) return a.index < b.index end)
				for _, info in pairs(tab) do
					local t=get_Faction_Info({factionID= info.factionID, name=not Save.hideName,})
					if t then
						text= text and text..'|n'..t or t
					end
				end
			else
				for i=1, GetNumFactions() do
					local t=get_Faction_Info({index= i, hide=true, name=not Save.hideName,})
					if t then
						text= text and text..'|n'..t or t
					end
				end
			end
			text= text and text..' ' or '..'
		end
		self.text:SetText(text or '')
	end

	hooksecurefunc('ReputationFrame_Update', function() TrackButton:set_Text() end)--更新, 监视, 文本

	TrackButton:set_Scale()
	TrackButton:set_Point()
	TrackButton:set_Event()
	TrackButton:set_Shown()
	TrackButton:set_Texture()
end

























--#########
--界面, 增强
--#########
local function set_ReputationFrame_InitReputationRow(factionRow, elementData)--ReputationFrame.lua
    local factionIndex = elementData.index;
	local factionContainer = factionRow.Container
	local factionBar = factionContainer.ReputationBar;
	--local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canSetInactive
	local _, _, standingID, _, _, _, _, _, isHeader, _, hasRep, isWatched, _, factionID= GetFactionInfo(factionIndex)
	if (isHeader and not hasRep) or not factionID or Save.notPlus then
		if factionContainer.watchedIcon then--显示为经验条
			factionContainer.watchedIcon:SetShown(false)
		end
		if factionContainer.completed then--完成次数
			factionContainer.completed:SetText('')
		end
		if factionContainer.levelText then--等级
			factionContainer.levelText:SetText('')
		end
		if factionContainer.texture then--图标
			factionContainer.texture:SetTexture(0)
		end
		if factionContainer.check then
			factionContainer.check:SetShown(false)
		end
		return
	end

	local barColor, levelText, texture, atlas,isCapped
	local factionTitle = factionContainer.Name
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
				barColor = BLUE_FONT_COLOR
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
		factionContainer.watchedIcon=factionBar:CreateTexture(nil, 'OVERLAY')
		factionContainer.watchedIcon:SetPoint('LEFT')
		factionContainer.watchedIcon:SetAtlas('common-icon-checkmark-yellow')
		factionContainer.watchedIcon:SetSize(16, 16)
	end
	if factionContainer.watchedIcon then
		factionContainer.watchedIcon:SetShown(isWatched)
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
	if completedParagon and not factionContainer.completed then
		factionContainer.completed= e.Cstr(factionBar, {justifyH='RIGHT'})
		factionContainer.completed:SetPoint('RIGHT',- 5,0)
	end
	if factionContainer.completed then
		factionContainer.completed:SetText(completedParagon or '')
	end

	if barColor and isCapped then
		factionBar:SetStatusBarColor(barColor.r, barColor.g, barColor.b)
	end

	if levelText and not factionContainer.levelText then--等级
		factionContainer.levelText= e.Cstr(factionContainer, {size=10, justifyH='RIGHT'})--10, nil, nil, nil, nil, 'RIGHT')
		factionContainer.levelText:SetPoint('RIGHT', factionContainer, 'LEFT',-2,0)
	end
	if factionContainer.levelText then
		factionContainer.levelText:SetText(levelText or '')
	end

	if (texture or atlas) and not factionContainer.texture then--图标
		local h=factionContainer:GetHeight() or 20
		factionContainer.texture= factionContainer:CreateTexture(nil, 'OVERLAY')
		factionContainer.texture:SetPoint('RIGHT', factionTitle, 'RIGHT',6,0)
		factionContainer.texture:SetSize(h,h)
	end
	if factionContainer.texture then
		if texture then
			factionContainer.texture:SetTexture(texture)
		elseif atlas then
			factionContainer.texture:SetAtlas(atlas)
		else
			factionContainer.texture:SetTexture(0)
		end
	end

	if not factionContainer.check then
		factionContainer.check= CreateFrame("CheckButton", nil, factionContainer, "InterfaceOptionsCheckButtonTemplate")
		factionContainer.check:SetPoint('LEFT',-4,0)
		factionContainer.check:Raise()
		factionContainer.check:SetScript('OnClick', function(self)
			if self.factionID then
				Save.factions[self.factionID ]= not Save.factions[self.factionID ] and self.factionIndex or nil
				self:SetAlpha(1)
				e.call('ReputationFrame_Update')
			end
		end)
		factionContainer.check:SetScript('OnEnter', function(self)
			e.tips:SetOwner(self, "ANCHOR_LEFT")
			e.tips:ClearLines()
			if self.factionID then
				local name2=GetFactionInfoByID(self.factionID)
				e.tips:AddDoubleLine(name2, self.factionID, 0,1,0,0,1,0)
				e.tips:AddLine(' ')
			end
			if Save.btnStrHideCap then
				e.tips:AddLine('|cffff00ff'..(e.onlyChinese and '隐藏最高' or (VIDEO_OPTIONS_ULTRA_HIGH..': '..HIDE)))
			end
			e.tips:AddDoubleLine(e.onlyChinese and '追踪' or TRACKING, e.onlyChinese and '指定' or COMBAT_ALLY_START_MISSION)
			e.tips:AddDoubleLine(id, addName)
			e.tips:Show()
		end)
		factionContainer.check:SetScript('OnLeave', function() e.tips:Hide() end)
		factionContainer.check:SetSize(18,22)
		factionContainer.check:SetCheckedTexture(e.Icon.icon)
	end
	factionContainer.check:SetShown(true)
	factionContainer.check.factionID= factionID
	factionContainer.check.factionIndex= factionIndex
	factionContainer.check:SetChecked(Save.factions[factionID])
	factionContainer.check:SetAlpha(0.5)
end
















--#############
--声望更新, 提示
--#############
local factionStr=FACTION_STANDING_INCREASED:gsub("%%s", "(.-)")--你在%s中的声望值提高了%d点。
factionStr = factionStr:gsub("%%d", ".-")
local function FactionUpdate(_, _, text, ...)
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
			if (repInfo and repInfo.friendshipFactionID > 0) then
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
			elseif ( isMajorFaction ) then
				isCapped=C_MajorFactions.HasMaximumRenown(factionID)
				local info = C_MajorFactions.GetMajorFactionData(factionID);
				if isCapped then
					barColor = FACTION_ORANGE_COLOR
					value= VIDEO_OPTIONS_ULTRA_HIGH
				else
					barColor = BLUE_FONT_COLOR
					if info then
						if info.name and info.name~=name then
							factionStandingtext=name
						end
						value= RENOWN_LEVEL_LABEL..' '..info.renownLevel.. (' %i%%'):format(info.renownReputationEarned/info.renownLevelThreshold*100)--名望 RENOWN_LEVEL_LABEL
					end
				end
				if info and info.textureKit then
					icon='|A:MajorFactions_Icons_'..info.textureKit..'512:0:0|a'
				end
			else
				local gender = e.Player.sex
				factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID, gender)
				if isCapped then
					barColor = FACTION_ORANGE_COLOR
				elseif barValue and barMax then
					if barMax==0 then
						value=('%i%%'):format( (barMin-barValue)/barMin*100)
					else
						value=('%i%%'):format(barValue/barMax*100)
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
			local m= factionStandingtext and factionStandingtext or ''
			if barColor then
				m= barColor:WrapTextInColorCode(m)
			end
			if value then
				m=m..' |cffff00ff'..value..'|r'
			end
			m=(icon or ('|A:'..e.Icon.icon..':0:0|a'))..m
			if hasRewardPending then
				m=m..e.Icon.bank2..(rewardQuestID and GetQuestLink(rewardQuestID) or '')
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
					print(id, addName, e.onlyChinese and '移除' or REMOVE, arg1, arg2)
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
		return
	end

	if type then
		return
	end

	info={
		text= e.onlyChinese and '追踪' or TRACKING,
		checked= Save.btn,
		tooltipOnButton=true,
		tooltipTitle= e.onlyChinese and '副本/宠物对战' or INSTANCE..'/'..SHOW_PET_BATTLES_ON_MAP_TEXT,
		tooltipText= e.GetEnabeleDisable(false),
		colorCode= (IsInInstance() or C_PetBattles.IsInBattle()) and '|cffff0000',
		func= function()
			Save.btn= not Save.btn and true or nil
			if TrackButton then
				TrackButton:set_Shown()
				e.call('ReputationFrame_Update')
			else
				Init_TrackButton()--监视, 文本
			end
			print(id, addName,e.onlyChinese and '追踪' or TRACKING, e.GetShowHide(Save.btn))
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
			print(id, addName, e.onlyChinese and '声望变化' or COMBAT_TEXT_SHOW_REPUTATION_TEXT,'|A:voicechat-icon-textchat-silenced:0:0|a', e.GetEnabeleDisable(Save.factionUpdateTips), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
		end
	}
	e.LibDD:UIDropDownMenu_AddButton(info, level)

	info={
		text= 'UI Plus',
		checked= not Save.notPlus,
		func= function()
			Save.notPlus= not Save.notPlus and true or nil
			Button.down:SetShown(not Save.notPlus)
			Button.up:SetShown(not Save.notPlus)
			e.call('ReputationFrame_Update')
			--print(id, addName, 'UI Plus', e.GetEnabeleDisable(not Save.notPlus), e.onlyChinese and '需要刷新' or NEED..REFRESH)
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
	Button:SetScript("OnClick", function(self)
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
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
		if TrackButton then
			TrackButton:SetButtonState('PUSHED')
		end
	end)
	Button:SetScript('OnLeave', function()
		e.tips:Hide()
		if TrackButton then
			TrackButton:SetButtonState("NORMAL")
		end
	end)

	Init_TrackButton()--监视, 文本

	hooksecurefunc('ReputationFrame_InitReputationRow', set_ReputationFrame_InitReputationRow)-- 声望, 界面, 增强

	Button.up=CreateFrame("Button",nil, Button, 'UIPanelButtonTemplate')--收起所有
	Button.up:SetShown(not Save.notPlus)
	Button.up:SetNormalTexture('Interface\\Buttons\\UI-PlusButton-Up')
	Button.up:SetSize(16, 16)
	Button.up:SetPoint("LEFT", ReputationFrameFactionLabel, 'RIGHT',5,0)
	Button.up:SetScript("OnMouseDown", function()
		for i=GetNumFactions(), 1, -1 do
			CollapseFactionHeader(i)
		end
	end)
	Button.down=CreateFrame("Button",nil, Button, 'UIPanelButtonTemplate')--展开所有
	Button.down:SetShown(not Save.notPlus)
	Button.down:SetNormalTexture('Interface\\Buttons\\UI-MinusButton-Up')
	Button.down:SetPoint('LEFT', Button.up, 'RIGHT')
	Button.down:SetSize(18, 18)
	Button.down:SetScript("OnMouseDown", function(self)
		ExpandAllFactionHeaders()
	end)

	if Save.factionUpdateTips then--声望更新, 提示
		ChatFrame_AddMessageEventFilter('CHAT_MSG_COMBAT_FACTION_CHANGE', FactionUpdate)

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
			print(id, addName, '|cffff00ff'..text..'|r', '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '你有未领取的奖励' or WEEKLY_REWARDS_UNCLAIMED_TITLE))
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

			--添加控制面板
            e.AddPanel_Check({
                name= (e.Player.faction=='Alliance' and e.Icon.alliance2 or e.Icon.horde2 )..(e.onlyChinese and '声望' or addName),
                tooltip= addName,
                value= not Save.disabled,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            --[[添加控制面板        
            local sel=e.AddPanel_Check((e.Player.faction=='Alliance' and e.Icon.alliance2 or e.Icon.horde2 )..(e.onlyChinese and '声望' or addName), not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)]]

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
