local id, e =...
local Save={btnStrHideCap=true, btnStrHideHeader=true, factionUpdateTips=true}
local addName=REPUTATION
local Frame=ReputationFrame

local Icon={
    isCapped='|A:'..e.Icon.icon..':0:0|a',
	up="Interface\\Buttons\\UI-PlusButton-Up",
	down="Interface\\Buttons\\UI-MinusButton-Up",
	reward='ParagonReputation_Bag',--奖励
	reward2='|A:ParagonReputation_Bag:0:0|a'
}

local function btnstrSetText()--监视声望内容
	local btn=Frame.sel2 and Frame.sel2.btn--监视声望按钮
	if not btn or not btn.str then
		return
	end
	if not Save.btnstr then
		btn:SetNormalAtlas(e.Icon.disabled)
		btn.str:SetText('')
		return
	end

	local m=''
	local hasRewardPending
	for i=1, GetNumFactions() do
		local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus =GetFactionInfo(i)
		if name==HIDE then break end--隐藏 '隐藏声望'
		if (hasRep or ((isHeader or isChild)  and not isCollapsed ) or (not isHeader and not isChild)) and factionID then
			local isCapped= standingID == MAX_REPUTATION_REACTION
			local factionStandingtext, value, icon
			local barColor = FACTION_BAR_COLORS[standingID]

			local isMajorFaction = C_Reputation.IsMajorFaction(factionID)
			local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)

			if (repInfo and repInfo.friendshipFactionID > 0) then--个人声望
				if ( repInfo.nextThreshold ) then
					factionStandingtext = repInfo.reaction;
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
				local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID);
				if isCapped then
					barColor = FACTION_ORANGE_COLOR
				else
					--factionStandingtext = majorFactionData.renownLevel..'/'..majorFactionData.renownLevelThreshold--名望RENOWN_LEVEL_LABEL				
					barColor = BLUE_FONT_COLOR
					if majorFactionData then
						if majorFactionData.name and majorFactionData.name~=name then 
							factionStandingtext=name
						end
						value= majorFactionData.renownLevel..'/'..majorFactionData.renownLevelThreshold--名望RENOWN_LEVEL_LABEL
					end
					--value=('%i%%'):format(majorFactionData.renownReputationEarned/majorFactionData.renownLevelThreshold*100)
				end
				if majorFactionData and majorFactionData.textureKit then
					icon='|T'..majorFactionData.textureKit..':0|t'
				end
			else
				if isCapped then
					barColor = FACTION_ORANGE_COLOR
				elseif (isHeader and hasRep) or not isHeader then
					local gender = UnitSex("player");
					factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID, gender)
					value=('%i%%'):format(barValue/barMax*100)
				elseif isHeader and not hasRep then
					barColor=PROGENITOR_MATERIAL_TITLETEXT_COLOR
				end
			end

			local isParagon = C_Reputation.IsFactionParagon(factionID)--奖励			
			if ( isParagon ) then--奖励
				local currentValue, threshold, rewardQuestID, hasRewardPending2, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID);
				hasRewardPending=hasRewardPending2
				if not tooLowLevelForParagon then
					value=('%i%%'):format(currentValue/threshold*100)
				end
			end
			if not ((Save.btnStrHideCap and isCapped and not isParagon and not isHeader) or (Save.btnStrHideHeader and isHeader and not isParagon and not hasRep))then
				local t
				if isHeader then
					t=Icon.isCapped
				else
					t='    '
				end
				if isChild then
					t='  '..t
				end
				if Save.btnStrShowID and not(isHeader and not hasRep ) then--显示ID
				t=t..factionID..' '
				end
				t=t..(icon or '')..name..(factionStandingtext and ' '..factionStandingtext or '')..(value and ' |cffffffff'..value..'|r' or '')
				t=barColor:WrapTextInColorCode(t)
				if hasRewardPending then--有奖励
					t=t..' '..Icon.reward2
				end
				if m~='' then m=m..'|n' end
				m=m..t
			end
		end
	end

	if hasRewardPending then
		btn:SetNormalAtlas(Icon.reward)--有奖励
	else
		btn:SetNormalAtlas(e.Icon.icon)
	end
	btn.str:SetText(m)
end

--ReputationFrame.lua
hooksecurefunc('ReputationFrame_InitReputationRow', function (factionRow, elementData)
	if Save.disabled then
		return
	end
    local factionIndex = elementData.index;
	local factionContainer = factionRow.Container
	local factionBar = factionContainer.ReputationBar;
	local watchedIcon=factionBar.watchedIcon--显示为经验条
	local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canSetInactive = GetFactionInfo(factionIndex);
	if (isHeader and not hasRep) or not factionID then
		if watchedIcon then
			watchedIcon:SetShown(false)
		end
		return
	end

	local factionTitle = factionContainer.Name
	local text
	local barColor
	local isMajorFaction = C_Reputation.IsMajorFaction(factionID);
	local repInfo = C_GossipInfo.GetFriendshipReputation(factionID);

	if repInfo and repInfo.friendshipFactionID > 0 then--好友声望
		local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID)
		if rankInfo and rankInfo.maxLevel>0 then
			local icon=repInfo.texture and '|T'..repInfo.texture..':0|t' or nil
			if repInfo.nextThreshold then
				text=name..(icon or '')..rankInfo.currentLevel..'/'..rankInfo.maxLevel
			else
				text=(icon or Icon.isCapped).. name
				barColor=FACTION_ORANGE_COLOR				
			end
		end
	elseif isMajorFaction then-- 名望
		local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)
		local icon
		if majorFactionData and majorFactionData.textureKit then
			icon='|T'..majorFactionData.textureKit..':0|t'
		end
		if C_MajorFactions.HasMaximumRenown(factionID) then
			text=(icon or Icon.isCapped)..name
			barColor=FACTION_ORANGE_COLOR
		else
			if majorFactionData then
				text=(icon or '')..majorFactionData.renownLevel..'/'..majorFactionData.renownLevelThreshold
			end
			barColor = BLUE_FONT_COLOR
		end
	elseif (isHeader and hasRep) or not isHeader then
		if (standingID == MAX_REPUTATION_REACTION) then--已满
			text=Icon.isCapped..name
			barColor=FACTION_ORANGE_COLOR
		else
			text=name..''..standingID..'/'..MAX_REPUTATION_REACTION
			barColor = FACTION_BAR_COLORS[standingID]
		end
	end
	if text then
		if barColor then
			text=barColor:WrapTextInColorCode(text)--颜色	
		end
		factionTitle:SetText(text)
	end
	if isWatched then
		if not watchedIcon then
			watchedIcon=factionBar:CreateTexture(nil, 'OVERLAY')
			watchedIcon:SetPoint('RIGHT', factionBar, 'LEFT',8, 0)
			watchedIcon:SetAtlas(e.Icon.selectYellow)
			watchedIcon:SetSize(16, 16)
			factionBar.watchedIcon=watchedIcon
		end
		watchedIcon:SetShown(true)
	elseif watchedIcon then
		watchedIcon:SetShown(false)
	end
end)

Frame.sel=CreateFrame("Button",nil, Frame, 'UIPanelButtonTemplate')--禁用,开启
Frame.sel:RegisterForClicks("LeftButtonDown","RightButtonDown")
Frame.sel:SetSize(18, 18)
Frame.sel:SetPoint("LEFT", ReputationFrameStandingLabel, 'RIGHT',5,0)
Frame.sel:SetScript('OnLeave', function ()
	e.tips:Hide()
end)

Frame.sel2=CreateFrame("Button",nil, Frame, 'UIPanelButtonTemplate')--监视声望按钮 禁用,开启
Frame.sel2:SetSize(18, 18)
Frame.sel2:SetPoint("LEFT", Frame.sel, 'RIGHT',2,0)
Frame.sel2:SetScript("OnEnter", function(self)
	e.tips:SetOwner(self, "ANCHOR_LEFT")
    e.tips:ClearLines()
	e.tips:AddDoubleLine(id, addName)
	e.tips:AddLine(' ')
	e.tips:AddDoubleLine(COMBAT_TEXT_SHOW_REPUTATION_TEXT, e.GetEnabeleDisable(Save.btn)..e.Icon.left)
--	e.tips:AddDoubleLine(addName..UPDATE, e.GetEnabeleDisable(Save.factionUpdateTips))
    e.tips:Show()
end)
Frame.sel2:SetScript('OnLeave', function ()
	e.tips:Hide()
end)

hooksecurefunc('ReputationFrame_Update', btnstrSetText)--更新监视

local function SetRe()--监视声望	
	Frame.sel2:SetNormalAtlas(Save.btn and e.Icon.icon or e.Icon.disabled)
	local btn=Frame.sel2.btn--监视声望按钮
	if Save.btn and not btn then
			btn=CreateFrame("Button",nil, UIParent)--禁用,开启
			btn:SetNormalAtlas(e.Icon.icon)
			btn:SetHighlightAtlas(e.Icon.highlight)
			btn:SetPushedAtlas(e.Icon.pushed)
			btn:SetSize(18, 18)
			if Save.point then
				btn:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
			else
				btn:SetPoint('TOPLEFT', Frame, 'TOPRIGHT',0, -40)
			end
			btn:RegisterForDrag("RightButton")
			btn:SetClampedToScreen(true);
			btn:SetMovable(true);
			btn:SetScript("OnDragStart", function(self2, d) if d=='RightButton' and not IsModifierKeyDown() then self2:StartMoving() end end)
			btn:SetScript("OnDragStop", function(self2)
					ResetCursor()
					self2:StopMovingOrSizing()
					Save.point={self2:GetPoint(1)}
					print(COMBAT_TEXT_SHOW_REPUTATION_TEXT..': |cnGREEN_FONT_COLOR:Alt+'..e.Icon.right..KEY_BUTTON2..'|r: '.. TRANSMOGRIFY_TOOLTIP_REVERT);
			end)
			btn:SetScript("OnMouseUp", function() ResetCursor() end)
			btn:SetScript("OnMouseDown", function(self2, d)
				local key=IsModifierKeyDown()
				if d=='RightButton' and IsAltKeyDown() then--alt+右击, 还原位置
					Save.point=nil
					self2:ClearAllPoints()
					self2:SetPoint('TOPLEFT', Frame, 'TOPRIGHT',0, -40)

				elseif d=='RightButton' and not key then--右击,移动
					SetCursor('UI_MOVE_CURSOR')

				elseif d=='LeftButton' and not key then--点击,显示隐藏
					if Save.btnstr then
						Save.btnstr=nil
					else
						Save.btnstr=true
					end
					print(addName..': '..e.GetShowHide(Save.btnstr))
					btnstrSetText()

				elseif d=='LeftButton' and IsAltKeyDown() then
					if Save.btnStrHideHeader then
						Save.btnStrHideHeader=nil
					else
						Save.btnStrHideHeader=true
					end
					btnstrSetText()
					print(GAME_VERSION_LABEL..'('..NO..Icon.reward2..QUEST_REWARDS..')'..addName..": "..e.GetShowHide(not Save.btnStrHideHeader))

				elseif d=='LeftButton' and IsControlKeyDown() then--Ctrl+点击, 显示ID
					if Save.btnStrShowID then
						Save.btnStrShowID=nil
					else
						Save.btnStrShowID=true
					end
					btnstrSetText()
					print(addName..' ID: '..e.GetShowHide(Save.btnStrShowID))

				elseif d=='LeftButton' and IsShiftKeyDown() then--Shift+点击, 隐藏最高级, 且没有奖励声望
					if Save.btnStrHideCap then
						Save.btnStrHideCap=nil
					else
						Save.btnStrHideCap=true
					end
					btnstrSetText()
					print(VIDEO_OPTIONS_ULTRA_HIGH..'('..NO..Icon.reward2..QUEST_REWARDS..')'..addName..": "..e.GetShowHide(not Save.btnStrHideCap))

				--[[elseif d=='RightButton' and IsShiftKeyDown() then--更新提示声望
					if Save.factionUpdateTips then
						Save.factionUpdateTips=nil
					else
						Save.factionUpdateTips=true
					end
					print(addName..UPDATE..": "..e.GetEnabeleDisable(Save.factionUpdateTips))]]
				end
			end)
			btn:SetScript("OnEnter",function(self2)
				if UnitAffectingCombat('player') then
					return
				end
				e.tips:SetOwner(self2, "ANCHOR_LEFT");
				e.tips:ClearLines();
				e.tips:AddDoubleLine(id, addName)
				e.tips:AddLine(' ')
				e.tips:AddDoubleLine(COMBAT_TEXT_SHOW_REPUTATION_TEXT..': '..e.GetShowHide(Save.btnstr), e.Icon.left)
				e.tips:AddDoubleLine(BINDING_NAME_TOGGLECHARACTER2, e.Icon.mid)
				e.tips:AddDoubleLine(NPE_MOVE, e.Icon.right)
				e.tips:AddLine(' ')
				e.tips:AddDoubleLine(GAME_VERSION_LABEL..addName..': '..e.GetShowHide(not Save.btnStrHideHeader), 'Alt + '..e.Icon.left)
				e.tips:AddDoubleLine(addName..' ID: '..e.GetShowHide(Save.btnStrShowID), 'Ctrl + '..e.Icon.left)
				e.tips:AddDoubleLine(VIDEO_OPTIONS_ULTRA_HIGH..addName..': '..e.GetShowHide(not Save.btnStrHideCap), 'Shift + '..e.Icon.left)
				--e.tips:AddLine(' ')
				--e.tips:AddDoubleLine(addName..UPDATE..': '..e.GetEnabeleDisable(Save.factionUpdateTips), 'Shift + '..e.Icon.right)
				e.tips:Show();
			end)
			btn:SetScript("OnLeave", function() ResetCursor()  e.tips:Hide() end);
			btn:EnableMouseWheel(true)
			btn:SetScript("OnMouseWheel", function (self2, d)
				ToggleCharacter("ReputationFrame")--打开声望
			end)

			btn.str=e.Cstr(btn)
			btn.str:SetPoint('TOPLEFT',3,-3)
			Frame.sel2.btn=btn
	end
	if btn then
		btn:SetShown(Save.btn)
		btnstrSetText()
	end
end

Frame.sel2:SetScript('OnClick', function(self, d)
	if Save.btn then
		Save.btn=nil
	else
		Save.btn=true
		Save.btnstr=true
	end
	print(SHOW..addName..': '..e.GetEnabeleDisable(Save.btn))
	SetRe();
end)

local factionStr=FACTION_STANDING_INCREASED:gsub("%%s", "(.-)")--你在%s中的声望值提高了%d点。
factionStr = factionStr:gsub("%%d", ".-")

local function FactionUpdate(self, env, text)--监视声望更新提示
	local name=text and text:match(factionStr)
	if not Save.factionUpdateTips or not name then
		return
	end
	for i=1, GetNumFactions() do
		local name2, _, standingID, _, barMax, barValue, _, _, _, _, _, _, _, factionID = GetFactionInfo(i)		
		if not factionID then break end--隐藏声望
		if name2==name then
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
				local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID);
				if isCapped then
					barColor = FACTION_ORANGE_COLOR
				else
					barColor = BLUE_FONT_COLOR
					if majorFactionData then
						if majorFactionData.name and majorFactionData.name~=name then
							factionStandingtext=name
						end
						value= majorFactionData.renownLevel..'/'..majorFactionData.renownLevelThreshold--名望RENOWN_LEVEL_LABEL
					end
				end
				if majorFactionData and majorFactionData.textureKit then
					icon='|T'..majorFactionData.textureKit..':0|t'
				end
			else
				local gender = UnitSex("player");
				factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID, gender)
				if isCapped then
					barColor = FACTION_ORANGE_COLOR
				else
					value=('%i%%'):format(barValue/barMax*100)
				end
			end
			local isParagon = C_Reputation.IsFactionParagon(factionID)--奖励
			local hasRewardPending
			if ( isParagon ) then--奖励
				local currentValue, threshold, rewardQuestID, hasRewardPending2, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID);
				hasRewardPending=hasRewardPending2
				if not tooLowLevelForParagon then
					value=('%i%%'):format(currentValue/threshold*100)
				end
			end
			local m=name..(factionStandingtext and ' '..factionStandingtext or '')
			if barColor then
				m=barColor:WrapTextInColorCode(m)
			end
			if value then
				m=m..' |cffffffff'..value..'|r'
			end
			m=addName..(icon or Icon.isCapped)..m
			if hasRewardPending then
				m=m..' '..Icon.reward2
			end
			C_Timer.After(0.3, function() print(m) end)
			return
		end
	end
end
Frame.sel2:RegisterEvent('CHAT_MSG_COMBAT_FACTION_CHANGE')
Frame.sel2:SetScript('OnEvent', FactionUpdate)

local function SetAll()--收起,展开
	Frame.sel:SetNormalAtlas(Save.disabled and e.Icon.disabled or e.Icon.icon)
	if Save.disabled then
		return
	end
	if not Frame.up then
		Frame.up=CreateFrame("Button",nil, Frame, 'UIPanelButtonTemplate')--收起所有
		Frame.up:SetNormalTexture(Icon.up)
		Frame.up:SetSize(16, 16)
		Frame.up:SetPoint("LEFT", ReputationFrameFactionLabel, 'RIGHT',5,0)
		Frame.up:SetScript("OnClick", function()
			for i=GetNumFactions(), 1, -1 do
				CollapseFactionHeader(i)
			end
		end)
	end
	if not Frame.down then
		Frame.down=CreateFrame("Button",nil, Frame, 'UIPanelButtonTemplate')--展开所有
		Frame.down:SetNormalTexture(Icon.down)
		Frame.down:SetPoint('LEFT', Frame.up, 'RIGHT')
		Frame.down:SetSize(18, 18)
		Frame.down:SetScript("OnMouseDown", function(self)
			ExpandAllFactionHeaders()
		end)
	end
end

Frame.sel:SetScript("OnClick", function(self, d)
	if d=='LeftButton' then
		local m=addName..':'..e.GetEnabeleDisable(Save.disabled)
		if Save.disabled then
			Save.disabled=nil
		else
			Save.disabled=true
			m=m..' '..NEED..'|cnGREEN_FONT_COLOR:/reload'..'|r'
		end
		print(m)
		SetAll()--收起,展开
		ReputationFrame_Update()
	elseif d=='RightButton' then
		if Save.factionUpdateTips then
			Save.factionUpdateTips=nil
		else
			Save.factionUpdateTips=true
		end
		print(addName, UPDATE..': '..e.GetEnabeleDisable(Save.factionUpdateTips))
	end
end)

Frame.sel:SetScript("OnEnter", function(self2)
	e.tips:SetOwner(self2, "ANCHOR_LEFT")
    e.tips:ClearLines()
	e.tips:AddLine(id, addName)
	e.tips:AddLine(' ')
	e.tips:AddDoubleLine(addName..': '..e.GetEnabeleDisable(not Save.disabled), e.Icon.left)
	e.tips:AddLine(' ')
	e.tips:AddDoubleLine(UPDATE..': '..e.GetEnabeleDisable(Save.factionUpdateTips), e.Icon.right)
    e.tips:Show()
end)

Frame.sel:RegisterEvent("ADDON_LOADED")
Frame.sel:RegisterEvent("PLAYER_LOGOUT")
Frame.sel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == id then
		Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save
		SetAll()--收起,展开		
		SetRe()--监视声望
    elseif event == "PLAYER_LOGOUT" then
		if not e.ClearAllSave then
			if not WoWToolsSave then WoWToolsSave={} end
			WoWToolsSave[addName]=Save
		end
	end
end)