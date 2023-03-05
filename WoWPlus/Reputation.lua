local id, e = ...
local Save={btnStrHideCap=true, btnStrHideHeader=true, factionUpdateTips=true, btnstr=true}
local addName=REPUTATION
local panel= e.Cbtn(ReputationFrame, nil, true, nil, nil, nil,{20, 20})

--#########
--设置, 文本
--#########
local function Reputation_Text_setText()--设置, 文本
	if not Save.btn or not Save.btnstr or (panel.btn and not panel.btn:IsShown())  then
		if panel.btn and panel.btn.text then
			panel.btn.text:SetText('')
			panel.btn:SetNormalAtlas(e.Icon.disabled)
		end
		return
	end
	panel.btn:SetNormalTexture(0)

	local m=''

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
			local hasRewardPending
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
					t= t.. (icon or '    ')--('|A:'..e.Icon.icon..':0:0|a'))
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

	if m=='' then
		m='..'
	end
	panel.btn.text:SetText(m)
end


local function Set_Reputation_Text()--监视, 文本
	if Save.btn and not panel.btn then
		panel.btn= e.Cbtn(nil, nil, Save.btn, nil,nil,nil,{18,18})
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
				Save.btnstr= not Save.btnstr and true or false
				print(id, addName, e.GetShowHide(Save.btnstr))
				Reputation_Text_setText()--设置, 文本

			elseif d=='LeftButton' and IsAltKeyDown() then
				Save.btnStrHideHeader= not Save.btnStrHideHeader and true or false
				Reputation_Text_setText()--设置, 文本
				print(id,addName, e.onlyChinese and '版本' or GAME_VERSION_LABEL,'('..NO..e.Icon.bank2..(e.onlyChinese and '奖励' or QUEST_REWARDS)..')', e.GetShowHide(not Save.btnStrHideHeader))

			elseif d=='LeftButton' and IsShiftKeyDown() then--Shift+点击, 隐藏最高级, 且没有奖励声望
				Save.btnStrHideCap= not Save.btnStrHideCap and true or false
				Reputation_Text_setText()--设置, 文本
				print(id, addName, e.onlyChinese and '没有声望奖励时' or VIDEO_OPTIONS_ULTRA_HIGH..'('..NO..e.Icon.bank2..QUEST_REWARDS..')', e.GetShowHide(not Save.btnStrHideCap))
			end
		end)
		panel.btn:SetScript("OnEnter",function(self2)
			e.tips:SetOwner(self2, "ANCHOR_LEFT");
			e.tips:ClearLines();
			e.tips:AddDoubleLine(id, addName)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(e.GetShowHide(Save.btnstr), e.Icon.left)
			e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(e.onlyChinese and '打开/关闭声望界面' or BINDING_NAME_TOGGLECHARACTER2, e.Icon.mid)
			e.tips:AddDoubleLine((e.onlyChinese and '字体大小' or FONT_SIZE)..': '..(Save.size or 12), 'Alt+'..e.Icon.mid)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine((e.onlyChinese and '版本' or GAME_VERSION_LABEL)..': '..e.GetShowHide(not Save.btnStrHideHeader), 'Alt + '..e.Icon.left)
			e.tips:AddDoubleLine((e.onlyChinese and '隐藏最高声望' or (VIDEO_OPTIONS_ULTRA_HIGH..addName))..': '..e.GetShowHide(not Save.btnStrHideCap), 'Shift + '..e.Icon.left)
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
				print(id, addName, e.onlyChinese and '文本' or LOCALE_TEXT_LABEL, e.onlyChinese and '字体大小' or FONT_SIZE, num)

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
		panel.btn:RegisterEvent('PLAYER_ENTERING_WORLD')
		panel.btn:RegisterEvent('PET_BATTLE_OPENING_DONE')
		panel.btn:RegisterEvent('PET_BATTLE_CLOSE')
		panel.btn:RegisterEvent('UPDATE_FACTION')
		panel.btn:SetScript('OnEvent', function(self)
			local show= Save.btn and not IsInInstance() and not C_PetBattles.IsInBattle()
			self:SetShown(show)
			if show then
				Reputation_Text_setText()--设置, 文本
			end
		end)

		panel.btn.text=e.Cstr(panel.btn, Save.size, nil, nil, true)
		panel.btn.text:SetPoint('TOPLEFT',3,-3)
	end
	if panel.btn then
		panel.btn:SetShown(Save.btn and not IsInInstance() and not C_PetBattles.IsInBattle())
		Reputation_Text_setText()--设置, 文本
	end
end

--#########
--界面, 增强
--#########
local function set_ReputationFrame_InitReputationRow(factionRow, elementData)--ReputationFrame.lua
    local factionIndex = elementData.index;
	local factionContainer = factionRow.Container
	local factionBar = factionContainer.ReputationBar;

	local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canSetInactive = GetFactionInfo(factionIndex);
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
		factionContainer.watchedIcon:SetAtlas(e.Icon.selectYellow)
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
		factionContainer.completed= e.Cstr(factionBar, nil, nil, nil, nil, nil, 'RIGHT')
		factionContainer.completed:SetPoint('RIGHT',- 5,0)
	end
	if factionContainer.completed then
		factionContainer.completed:SetText(completedParagon or '')
	end

	if barColor and isCapped then
		factionBar:SetStatusBarColor(barColor.r, barColor.g, barColor.b)
	end

	if levelText and not factionContainer.levelText then--等级
		factionContainer.levelText= e.Cstr(factionContainer, 10, nil, nil, nil, nil, 'RIGHT')
		factionContainer.levelText:SetPoint('RIGHT', factionContainer, 'LEFT',2,0)
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
end


--#############
--声望更新, 提示
--#############
--[[local function set_RegisterEvent_CHAT_MSG_COMBAT_FACTION_CHANGE()--更新, 提示, 事件
	if Save.factionUpdateTips or Save.btn then
		panel:RegisterEvent('CHAT_MSG_COMBAT_FACTION_CHANGE')
	else
		panel:UnregisterEvent('CHAT_MSG_COMBAT_FACTION_CHANGE')
	end
end]]

local factionStr=FACTION_STANDING_INCREASED:gsub("%%s", "(.-)")--你在%s中的声望值提高了%d点。
factionStr = factionStr:gsub("%%d", ".-")
local function FactionUpdate(self, event, text, ...)
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
			local m=factionStandingtext and factionStandingtext or ''
			if barColor then
				m=barColor:WrapTextInColorCode(m)
			end
			if value then
				m=m..' |cffffffff'..value..'|r'
			end
			m=(icon or ('|A:'..e.Icon.icon..':0:0|a'))..m
			if hasRewardPending then
				m=m..e.Icon.bank2
			end

			return false, text..m, ...
		end
	end
end


--#####
--主菜单
--#####
local function InitMenu(self, level, type)
	local info
	info={
		text= e.onlyChinese and '文本' or LOCALE_TEXT_LABEL,
		colorCode= (IsInInstance() or C_PetBattles.IsInBattle()) and '|cff808080',
		checked= Save.btn,
		func= function()
			Save.btn= not Save.btn and true or nil
			Set_Reputation_Text()--监视, 文本
			print(id, addName, e.onlyChinese and '文本' or LOCALE_TEXT_LABEL, e.GetShowHide(Save.btn))
		end
	}
	UIDropDownMenu_AddButton(info, level)

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
	UIDropDownMenu_AddButton(info, level)

	info={
		text= 'UI Plus',
		checked= not Save.notPlus,
		func= function()
			Save.notPlus= not Save.notPlus and true or nil
			panel.down:SetShown(not Save.notPlus)
			panel.up:SetShown(not Save.notPlus)
			print(id, addName, 'UI Plus', e.GetEnabeleDisable(not Save.notPlus), e.onlyChinese and '需要刷新' or NEED..REFRESH)
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

	--set_RegisterEvent_CHAT_MSG_COMBAT_FACTION_CHANGE()--更新, 提示, 事件

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

	if Save.factionUpdateTips then--声望更新, 提示
		ChatFrame_AddMessageEventFilter('CHAT_MSG_COMBAT_FACTION_CHANGE', FactionUpdate)
	end

end


--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
		if arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel(e.onlyChinese and '声望' or addName, not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)

            if Save.disabled then
                panel:UnregisterAllEvents()
				panel:SetShown(false)
            else
                Init()
				panel:UnregisterEvent('ADDON_LOADED')
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
		end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)
