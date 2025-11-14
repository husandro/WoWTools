local function Save()
	return WoWToolsSave['Plus_Faction']
end








local function Create_Frame(btn)
	btn.Content.AccountWideIcon:SetScale(0.6)
--完成次数
	btn.completed= WoWTools_LabelMixin:Create(btn.ParagonIcon, {size=10})
	btn.completed:SetPoint('BOTTOMRIGHT', btn.ParagonIcon)
--等级
	btn.levelText= WoWTools_LabelMixin:Create(btn.ReputationBar, {size=10})
	btn.levelText:SetPoint('TOPRIGHT', 8, 3)
--图标
	local h=btn:GetHeight() or 20
	btn.texture= btn:CreateTexture(nil, 'OVERLAY')
	btn.texture:SetPoint('RIGHT', btn.Name, 'RIGHT',6,0)
	btn.texture:SetSize(h, h)

--check
	btn.check= CreateFrame('CheckButton', nil, btn, "InterfaceOptionsCheckButtonTemplate")
	btn.check:SetPoint('LEFT',-12,0)
	function btn.check:get_info()
		return self:GetParent().elementData or {}
	end
	btn.check:SetScript('OnClick', function(self)
		local info= self:get_info()
		if info.factionID then
			Save().factions[info.factionID]= not Save().factions[info.factionID] and true or nil
			WoWTools_FactionMixin:UpdatList()
		end
	end)
	btn.check:SetScript('OnEnter', function(self)
		local info= self:get_info()
		if not info.factionID then
			return
		end
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_FactionMixin.addName)
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING, WoWTools_DataMixin.onlyChinese and '指定' or COMBAT_ALLY_START_MISSION)
		GameTooltip:AddLine(' ')
		GameTooltip:AddDoubleLine(WoWTools_TextMixin:CN(info.name), info.factionID, 0,1,0,0,1,0)
		GameTooltip:Show()
		self:SetAlpha(1)
	end)
	btn.check:SetScript('OnLeave', function(self)
		GameTooltip:Hide()
		self:SetAlpha(0.3)
	end)
	btn.check:SetSize(18,22)
	btn.check:SetCheckedTexture('orderhalltalents-done-glow')
	WoWTools_TextureMixin:SetCheckBox(btn.check)

	function btn:clear_all()
		self.Content.Name:SetTextColor(1,1,1)
		--self.Content.watchedIcon:SetShown(false)
		self.completed:SetText('')
		self.levelText:SetText('')
		self.texture:SetTexture(0)
		self.check:SetShown(false)
	end
end















local function Init()
	if Save().notPlus then
		return
	end

	WoWTools_DataMixin:Hook(ReputationEntryMixin, 'OnLoad', function(btn)
		Create_Frame(btn)
	end)



	WoWTools_DataMixin:Hook(ReputationEntryMixin, 'Initialize', function(btn, data)--factionRow, elementData)--ReputationFrame.lua
		data= data or btn.elementData
		local factionID = data.factionID --or btn.factionIndex

		if factionID==0 then
			if btn.clear_all then
				btn:clear_all()
			end
			return
		end

		if not btn.clear_all then
			Create_Frame(btn)
		end

		local barColor, levelText, texture, atlas,isCapped
		local isMajorFaction = C_Reputation.IsMajorFaction(factionID)
		local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)

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
							levelText= #levels
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

		if isCapped then
			btn.Content.Name:SetTextColor(1, 0.62, 0)
		elseif barColor then
			btn.Content.Name:SetTextColor(barColor.r, barColor.g, barColor.b)
		else
			btn.Content.Name:SetTextColor(1, 1, 1)
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
			end
		end

		btn.completed:SetText(completedParagon or '')

		if barColor and isCapped then
			btn.Content.ReputationBar:SetStatusBarColor(barColor.r, barColor.g, barColor.b)
		end

		btn.levelText:SetText(levelText or '')

		if texture then
			btn.texture:SetTexture(texture)
		elseif atlas then
			btn.texture:SetAtlas(atlas)
		else
			btn.texture:SetTexture(0)
		end

		btn.check:SetShown(Save().btn and Save().indicato)
		btn.check:SetChecked(Save().factions[factionID])
		btn.check:SetAlpha(0.3)
	end)









	WoWTools_DataMixin:Hook(ReputationEntryMixin, 'RefreshAccountWideIcon', function(self)
		local showAccountWideIcon = C_Reputation.IsAccountWideReputation(self.factionID)
		self.Content.AccountWideIcon:SetShown(showAccountWideIcon)
	end)



	WoWTools_DataMixin:Hook(ReputationSubHeaderMixin, 'RefreshAccountWideIcon', function(self)
		local showAccountWideIcon = C_Reputation.IsAccountWideReputation(self.factionID)
		self.Content.AccountWideIcon:SetShown(showAccountWideIcon)
	end)
	WoWTools_DataMixin:Hook(ReputationSubHeaderMixin, 'OnLoad', function(self)
		self.Content.AccountWideIcon:SetScale(0.6)
	end)

--去掉 名望等级
	local c_RENOWN_LEVEL_LABEL= WoWTools_TextMixin:Magic(RENOWN_LEVEL_LABEL)-- = "名望等级 %d";
	WoWTools_DataMixin:Hook(ReputationBarMixin, 'TryShowReputationStandingText', function(self)
		local t= self.reputationStandingText and self.reputationStandingText:match(c_RENOWN_LEVEL_LABEL)
		if t then
			self.BarText:SetText(t)
		end
	end)











	local down= WoWTools_ButtonMixin:Cbtn(_G['WoWToolsFactionMenuButton'], {
		size=22,
		atlas='NPE_ArrowDown',
		name='WoWToolsFactionListExpandButton'
	})

	down:SetPoint("RIGHT", ReputationFrame.filterDropdown, 'LEFT',-2,0)
	down:SetScript("OnClick", function()
		for index=C_Reputation.GetNumFactions(), 1, -1 do
			local data= C_Reputation.GetFactionDataByIndex(index)
			if data and data.isHeader and data.isCollapsed then
				C_Reputation.ExpandFactionHeader(index)
			end
		end
		for index=C_Reputation.GetNumFactions(), 1, -1 do
			local data= C_Reputation.GetFactionDataByIndex(index)
			if data and data.isHeader and data.isCollapsed then
				C_Reputation.ExpandFactionHeader(index)
			end
		end
	end)
	down:SetScript("OnLeave", function() GameTooltip_Hide() end)
	down:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(' ', WoWTools_DataMixin.onlyChinese and '展开选项|A:editmode-down-arrow:16:11:0:-7|a' or HUD_EDIT_MODE_EXPAND_OPTIONS)
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_FactionMixin.addName)
		GameTooltip:Show()
	end)















	local up= WoWTools_ButtonMixin:Cbtn(down, {
		size=22,
		atlas='NPE_ArrowUp',
		name='WoWToolsFactionListCollapsedButton',
	})--texture='Interface\\Buttons\\UI-PlusButton-Up'})--收起所有
	up:SetPoint("RIGHT", down, 'LEFT', -2, 0)
	up:SetScript("OnClick", function()
		for index=C_Reputation.GetNumFactions(), 1, -1 do
			local data= C_Reputation.GetFactionDataByIndex(index)
			if data and data.isHeader and not data.isCollapsed then
				C_Reputation.CollapseFactionHeader(index)
			end
		end
	end)
	up:SetScript("OnLeave", function() GameTooltip_Hide() end)
	up:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(' ', WoWTools_DataMixin.onlyChinese and '收起选项|A:editmode-up-arrow:16:11:0:3|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS)
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_FactionMixin.addName)
		GameTooltip:Show()
	end)











	local editBox
	local function Init_Search(self)
		local numList= C_Reputation.GetNumFactions() or 0
		if numList==0 then
			return
		end

		local factionID, name, data
		local factionList={}

		factionID =math.max(editBox:GetNumber() or 0)
		factionID= factionID>0 and factionID or nil

		name= editBox:GetText() or ''
		name= name~='' and name or nil

		if name or factionID then
			for index= 1, numList do
				data= C_Reputation.GetFactionDataByIndex(index)
				if data then
	--查找 ID
					if factionID and data.factionID==factionID then
						data.factionIndex = index
						tinsert(factionList, data)
						break
	--查找 名称
					elseif data.name and name then
						local cn= WoWTools_TextMixin:CN(data.name)
						cn= cn~=data.name and cn:upper() or nil

						local p_name= data.name:upper()
						name= name:upper()

						if cn and cn==name or p_name== name then
							data.factionIndex = index
							tinsert(factionList, data)
							break

						elseif cn and cn:find(name) or p_name:find(name) then
							data.factionIndex = index
							tinsert(factionList, data)
						end
					end
				end
			end
		end

		self.ScrollBox:SetDataProvider(CreateDataProvider(factionList), ScrollBoxConstants.RetainScrollPosition);
		self.ReputationDetailFrame:Refresh()
	end

	editBox= WoWTools_EditBoxMixin:Create(up, {
		name='WoWTools_PlusFactionSearchBox',
		Template='SearchBoxTemplate'
	})

	editBox:SetPoint('RIGHT', up, 'LEFT', -6, 0)
	editBox:SetPoint('BOTTOMLEFT', CharacterFramePortrait, 'BOTTOMRIGHT')

	editBox:SetScript('OnTextChanged', function(self)
		local show= self:GetText() ~= ""
		self.Instructions:SetShown(not show)
		local hasfocus= self:HasFocus()
		self:SetAlpha((show or hasfocus) and 1 or 0.3)

		if hasfocus then
			Init_Search(ReputationFrame)
		end

	end)

	editBox:SetScript('OnEnterPressed', function()
		Init_Search(ReputationFrame)
	end)

	editBox:SetScript('OnEditFocusGained', function(self)
		ReputationFrame.Update= Init_Search
		self:SetAlpha(1)
		if self:GetText()~='' then
			Init_Search(ReputationFrame)
		end
		self.clearButton:SetShown(true)
	end)

	editBox:SetScript('OnEditFocusLost', function(self)
		if self.clearButton:IsShown() and self:GetText()=='' then
			self.clearButton:Click()
		end
	end)

	editBox.clearButton:SetScript('OnClick', function(self)
		ReputationFrame.Update= ReputationFrameMixin.Update
		ReputationFrame:Update()
		local p= self:GetParent()
		p:SetText('')
		p:ClearFocus()
		p:SetAlpha(0.3)
		self:Hide()
	end)

	editBox:SetScript('OnEscapePressed', function(self)
		self:ClearFocus()
	end)


	Init=function()
		WoWTools_FactionMixin:UpdatList()
	end
end













function WoWTools_FactionMixin:Init_Plus()
   Init()
end