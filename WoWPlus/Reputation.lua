local id, e = ...
local Save={btnStrHideCap=true, btnStrHideHeader=true, factionUpdateTips=true, btnstr=true}
local addName=REPUTATION
local panel= e.Cbtn(ReputationFrame, nil, true, nil, nil, nil,{20, 20})

--#########
--设置, 文本
--#########
local function set_UPDATE_FACTION()--设置, 文本, 事件
	if Save.btn then
		panel:RegisterEvent('UPDATE_FACTION')
	else
		panel:UnregisterEvent('UPDATE_FACTION')
	end
end
local function Reputation_Text_setText()--设置, 文本
	if not Save.btn or not Save.btnstr then
		if panel.btn and panel.btn.text then
			panel.btn.text:SetText('')
		end
		return
	end

	local m=''
	local hasRewardPending
	for i=1, GetNumFactions() do
		local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus =GetFactionInfo(i)
		if name==HIDE then break end--隐藏 '隐藏声望'

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
					local gender = UnitSex("player");
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
			if ( isParagon ) then--奖励
				local currentValue, threshold, rewardQuestID, hasRewardPending2, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID);
				hasRewardPending=hasRewardPending2
				if not tooLowLevelForParagon then
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
					t= t.. (icon or ('|A:'..e.Icon.icon..':0:0|a'))
				end

				t=t..(name:match('%- (.+)') or name)..(factionStandingtext and ' '..factionStandingtext or '')..(value and ' '..value or '')

				if hasRewardPending then--有奖励
					t=t..' '..e.Icon.bank2
				end

				if verHeader then
					t='|cnGREEN_FONT_COLOR:'..t..'|r'
				end
				if m~='' then m=m..'|n' end
				m=m..t
			end
		end
	end

	if hasRewardPending then
		panel.btn:SetNormalAtlas('ParagonReputation_Bag')--有奖励
	else
		panel.btn:SetNormalAtlas(e.Icon.icon)
	end
	panel.btn.text:SetText(m)
end


local function Set_Reputation_Text()--监视, 文本
	if Save.btn and not panel.btn then
		panel.btn=e.Cbtn(nil, nil, Save.btn, nil,nil,nil,{18,18})
		if Save.point then
			panel.btn:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
		else
			panel.btn:SetPoint('TOPLEFT', ReputationFrame, 'TOPRIGHT',0, -40)
		end
		panel.btn:RegisterForDrag("RightButton")
		panel.btn:SetClampedToScreen(true);
		panel.btn:SetMovable(true);
		panel.btn:SetScript("OnDragStart", function(self2, d) if d=='RightButton' and not IsModifierKeyDown() then self2:StartMoving() end end)
		panel.btn:SetScript("OnDragStop", function(self2)
				ResetCursor()
				self2:StopMovingOrSizing()
				Save.point={self2:GetPoint(1)}
				Save.point[2]=nil
		end)
		panel.btn:SetScript("OnMouseUp", function() ResetCursor() end)
		panel.btn:SetScript("OnMouseDown", function(self2, d)
			local key=IsModifierKeyDown()
			if d=='RightButton' and not key then--右击,移动
				SetCursor('UI_MOVE_CURSOR')

			elseif d=='LeftButton' and not key then--点击,显示隐藏
				Save.btnstr= not Save.btnstr and true or nil
				print(id, addName, e.GetShowHide(Save.btnstr))
				Reputation_Text_setText()--设置, 文本

			elseif d=='LeftButton' and IsAltKeyDown() then
				Save.btnStrHideHeader= not Save.btnStrHideHeader and true or nil
				Reputation_Text_setText()--设置, 文本
				print(id,addName, e.onlyChinse and '版本' or GAME_VERSION_LABEL,'('..NO..e.Icon.bank2..(e.onlyChinse and '奖励' or QUEST_REWARDS)..')', e.GetShowHide(not Save.btnStrHideHeader))

			elseif d=='LeftButton' and IsShiftKeyDown() then--Shift+点击, 隐藏最高级, 且没有奖励声望
				Save.btnStrHideCap= not Save.btnStrHideCap and true or nil
				Reputation_Text_setText()--设置, 文本
				print(id, addName, e.onlyChinse and '没有声望奖励时' or VIDEO_OPTIONS_ULTRA_HIGH..'('..NO..e.Icon.bank2..QUEST_REWARDS..')', e.GetShowHide(not Save.btnStrHideCap))
			end
		end)
		panel.btn:SetScript("OnEnter",function(self2)
			e.tips:SetOwner(self2, "ANCHOR_LEFT");
			e.tips:ClearLines();
			e.tips:AddDoubleLine(id, addName)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(e.GetShowHide(Save.btnstr), e.Icon.left)
			e.tips:AddDoubleLine(e.onlyChinse and '移动' or NPE_MOVE, e.Icon.right)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(e.onlyChinse and '打开/关闭声望界面' or BINDING_NAME_TOGGLECHARACTER2, e.Icon.mid)
			e.tips:AddDoubleLine((e.onlyChinse and '字体大小' or FONT_SIZE)..': '..(Save.size or 12), 'Alt+'..e.Icon.mid)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine((e.onlyChinse and '版本' or GAME_VERSION_LABEL)..': '..e.GetShowHide(not Save.btnStrHideHeader), 'Alt + '..e.Icon.left)
			e.tips:AddDoubleLine((e.onlyChinse and '隐藏最高声望' or (VIDEO_OPTIONS_ULTRA_HIGH..addName))..': '..e.GetShowHide(not Save.btnStrHideCap), 'Shift + '..e.Icon.left)
			e.tips:Show();
		end)
		panel.btn:SetScript("OnLeave", function() ResetCursor()  e.tips:Hide() end);
		panel.btn:EnableMouseWheel(true)
		panel.btn:SetScript("OnMouseWheel", function (self2, d)--打开,关闭, 声望
			if IsAltKeyDown() then--缩放
				local num
				num= Save.size or 12
				if d==1 then
					num= num +1
				elseif d==-1 then
					num= num -1
				end
				num= num<6 and 6 or num
				num= num>32 and 32 or num
				Save.size= num
				e.Cstr(nil, num, nil, panel.btn.text, true)
				print(id, addName, e.onlyChinse and '文本' or LOCALE_TEXT_LABEL, e.onlyChinse and '字体大小' or FONT_SIZE, num)

			elseif d==1 then
				if not ReputationFrame:IsVisible() then
					ToggleCharacter("ReputationFrame")
				end
			elseif d==-1 then
				if ReputationFrame:IsVisible() then
					ToggleCharacter("ReputationFrame")
				end
			end
		end)

		panel.btn.text=e.Cstr(panel.btn, Save.size, nil, nil, true)
		panel.btn.text:SetPoint('TOPLEFT',3,-3)
	end
	if panel.btn then
		panel.btn:SetShown(Save.btn)
		Reputation_Text_setText()--设置, 文本
	end
	set_UPDATE_FACTION()--设置, 文本, 事件
end

--#########
--界面, 增强
--#########
local function set_ReputationFrame_InitReputationRow(factionRow, elementData)--ReputationFrame.lua
	if Save.notPlus then
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

	local isCappedIcon='|A:'..e.Icon.icon..':0:0|a'
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
				text=(icon or isCappedIcon).. name
				barColor=FACTION_ORANGE_COLOR
			end
		end
	elseif isMajorFaction then-- 名望
		local info = C_MajorFactions.GetMajorFactionData(factionID)
		local icon
		if info and info.textureKit then
			icon='|A:MajorFactions_Icons_'..info.textureKit..'512:0:0|a'
		end
		if C_MajorFactions.HasMaximumRenown(factionID) then
			text=(icon or isCappedIcon)..name
			barColor=FACTION_ORANGE_COLOR
		else
			if info then
				text=(icon or '')..name--.. ('%i%%'):format(info.renownLevel..'/'..info.renownLevelThreshold*100)
			end
			barColor = BLUE_FONT_COLOR
		end
	elseif (isHeader and hasRep) or not isHeader then

		if (standingID == MAX_REPUTATION_REACTION) then--已满
			text=isCappedIcon..name
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

	local isParagon = C_Reputation.IsFactionParagon(factionID)--奖励			
	local completedParagon--完成次数
	if ( isParagon ) then--奖励
		local currentValue, threshold, _, _, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID)
		if not tooLowLevelForParagon then
			local completed= math.modf(currentValue/threshold)--完成次数
			if completed>0 then
				completedParagon=completed
			end
		end
	end
	if completedParagon and not factionBar.completed then
		factionBar.completed=e.Cstr(factionBar, nil, nil, nil, nil, nil, 'RIGHT')
		factionBar.completed:SetPoint('RIGHT',- 5,0)
	end
	if factionBar.completed then
		factionBar.completed:SetText(completedParagon or '')
	end
end


--#############
--声望更新, 提示
--#############
local function set_RegisterEvent_CHAT_MSG_COMBAT_FACTION_CHANGE()--更新, 提示, 事件
	if Save.factionUpdateTips or Save.btn then
		panel:RegisterEvent('CHAT_MSG_COMBAT_FACTION_CHANGE')
	else
		panel:UnregisterEvent('CHAT_MSG_COMBAT_FACTION_CHANGE')
	end
end

local factionStr=FACTION_STANDING_INCREASED:gsub("%%s", "(.-)")--你在%s中的声望值提高了%d点。
factionStr = factionStr:gsub("%%d", ".-")
local function FactionUpdate(text)
	local name=text and text:match(factionStr)
	if not Save.factionUpdateTips or not name then
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
				local gender = UnitSex("player");
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
			local isParagon = C_Reputation.IsFactionParagon(factionID)--奖励
			local hasRewardPending
			if ( isParagon ) then--奖励
				local currentValue, threshold, rewardQuestID, hasRewardPending2, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID);
				hasRewardPending=hasRewardPending2
				if not tooLowLevelForParagon then
					local completed= math.modf(currentValue/threshold)
					currentValue= completed>0 and currentValue - threshold*completed or currentValue
					value=('%i%%'):format(currentValue/threshold*100).. (completed>0 and ' '..QUEST_REWARDS..'|cnGREEN_FONT_COLOR:'..completed..'|r'..VOICEMACRO_LABEL_CHARGE1 or '')
				end
			end
			local m=name..(factionStandingtext and ' '..factionStandingtext or '')
			if barColor then
				m=barColor:WrapTextInColorCode(m)
			end
			if value then
				m=m..' |cffffffff'..value..'|r'
			end
			m=(icon or isCappedIcon)..m
			if hasRewardPending then
				m=m..' '..e.Icon.bank2
			end

			C_Timer.After(0.3, function()
				print(id, addName, m)
			end)
			return
		end
	end
end


--#####
--主菜单
--#####
local function InitMenu(self, level, type)
	local info
	info={
		text= e.onlyChinse and '文本' or LOCALE_TEXT_LABEL,
		checked= Save.btn,
		func= function()
			Save.btn= not Save.btn and true or nil
			Set_Reputation_Text()--监视, 文本
			print(id, addName, e.onlyChinse and '文本' or LOCALE_TEXT_LABEL, e.GetShowHide(Save.btn))
		end
	}
	UIDropDownMenu_AddButton(info, level)

	info={
		text= (e.onlyChinse and '声望变化' or COMBAT_TEXT_SHOW_REPUTATION_TEXT)..'|A:voicechat-icon-textchat-silenced:0:0|a',
		checked= Save.factionUpdateTips,
		func= function()
			Save.factionUpdateTips= not Save.factionUpdateTips and true or nil
			set_RegisterEvent_CHAT_MSG_COMBAT_FACTION_CHANGE()--更新, 提示, 事件
			print(id, addName, e.onlyChinse and '声望变化' or COMBAT_TEXT_SHOW_REPUTATION_TEXT,'|A:voicechat-icon-textchat-silenced:0:0|a', e.GetEnabeleDisable(Save.factionUpdateTips))
		end
	}
	UIDropDownMenu_AddButton(info, level)

	info={
		text= 'UI Plus',
		checked= not Save.notPlus,
		func= function()
			Save.notPlus= not Save.notPlus and true or nil
			panel.down:SetShown(not Save.notPlus)
			panel.up:SetShown(not Save.notPlus)
			print(id, addName, 'UI Plus', e.GetEnabeleDisable(not Save.notPlus), e.onlyChinse and '需要刷新' or NEED..REFRESH)
		end
	}
	UIDropDownMenu_AddButton(info, level)
	--UIDropDownMenu_AddSeparator(level)
end

--######
--初始化
--######
local function Init()
	Set_Reputation_Text()--监视, 文本
	hooksecurefunc('ReputationFrame_Update', Reputation_Text_setText)--更新, 监视, 文本

	hooksecurefunc('ReputationFrame_InitReputationRow', set_ReputationFrame_InitReputationRow)-- 声望, 界面, 增强

	set_RegisterEvent_CHAT_MSG_COMBAT_FACTION_CHANGE()--更新, 提示, 事件

	panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

	panel:SetPoint("LEFT", ReputationFrameStandingLabel, 'RIGHT',5,0)
	panel:SetScript("OnMouseDown", function(self,d)
        ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
    end)

	panel.up=CreateFrame("Button",nil, panel, 'UIPanelButtonTemplate')--收起所有
	panel.up:SetShown(not Save.notPlus)
	panel.up:SetNormalTexture('Interface\\Buttons\\UI-PlusButton-Up')
	panel.up:SetSize(16, 16)
	panel.up:SetPoint("LEFT", ReputationFrameFactionLabel, 'RIGHT',5,0)
	panel.up:SetScript("OnMouseDown", function()
		for i=GetNumFactions(), 1, -1 do
			CollapseFactionHeader(i)
		end
	end)
	panel.down=CreateFrame("Button",nil, panel, 'UIPanelButtonTemplate')--展开所有
	panel.down:SetShown(not Save.notPlus)
	panel.down:SetNormalTexture('Interface\\Buttons\\UI-MinusButton-Up')
	panel.down:SetPoint('LEFT', panel.up, 'RIGHT')
	panel.down:SetSize(18, 18)
	panel.down:SetScript("OnMouseDown", function(self)
		ExpandAllFactionHeaders()
	end)
end


--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel(e.onlyChinse and '声望' or addName, not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

	elseif event=='UPDATE_FACTION' then
		Reputation_Text_setText()--文本

	elseif event=='CHAT_MSG_COMBAT_FACTION_CHANGE' then--声望更新, 提示
		FactionUpdate(arg1)
    end
end)
