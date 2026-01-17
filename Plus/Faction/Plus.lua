local function Save()
	return WoWToolsSave['Plus_Faction']
end








local function Create_Frame(btn)
	btn.Content.ReputationBar.BarText:SetAlpha(0)
	btn.Content.ReputationBar.BarText:ClearAllPoints()

	btn.Content.AccountWideIcon:SetScale(0.6)
--完成次数
	--[[btn.completed= btn.Content.ReputationBar:CreateFontString(nil, 'BORDER', 'GameFontNormal')-- WoWTools_LabelMixin:Create(btn.Content.ParagonIcon, {size=10})
	--btn.completed:SetFontHeight(10)
	--btn.completed:SetPoint('RIGHT', btn.Content.ParagonIcon, 'LEFT')
	btn.completed:SetPoint('BOTTOMRIGHT')]]
	--btn.Content.ReputationBar.BarText:SetAlpha(0)
	btn.barText2= btn.Content.ReputationBar:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
	btn.barText2:SetPoint('CENTER')
	btn.barText2:SetJustifyH('CENTER')


--图标
	local h=btn:GetHeight() or 20
	btn.texture= btn.Content.ReputationBar:CreateTexture(nil, 'OVERLAY')
	btn.texture:SetPoint('RIGHT', btn.Content.Name, 'RIGHT',6,0)
	btn.texture:SetSize(h, h)
--等级
	btn.levelText= btn.Content.ReputationBar:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')--WoWTools_LabelMixin:Create(btn.Content.ReputationBar, {size=10})
	--btn.levelText:SetFontHeight(10)
	btn.levelText:SetPoint('LEFT')

--check
	btn.check= CreateFrame('CheckButton', nil, btn.Content, "InterfaceOptionsCheckButtonTemplate")
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
		self:SetAlpha(0.4)
	end)
	btn.check:SetSize(18,22)
	btn.check:SetAlpha(0.3)
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



	WoWTools_DataMixin:Hook(ReputationEntryMixin, 'Initialize', function(btn)--factionRow, elementData)--ReputationFrame.lua
		local data= {}
		if not Save().notPlus then
			data= WoWTools_FactionMixin:GetInfo(btn.factionID)
		end

		if not btn.barText2 then
			Create_Frame(btn)
		end

		local text
		if data.isCapped then
			text= data.valueText
		elseif data.factionStandingtext then
			text= data.factionStandingtext..(data.valueText and ' '..data.valueText or '')
		end

		text= text or (WoWTools_TextMixin:CN(btn.Content.ReputationBar.BarText:GetText()))
		btn.barText2:SetText(text or '')
		--btn.Content.ReputationBar.BarText:SetAlpha(text and 0 or 1)
		--[[if text and btn.Content.ReputationBar.reputationStandingText then
			btn.Content.ReputationBar.reputationStandingText= nil
		end]]


		if data.color then
			btn.Content.Name:SetTextColor(data.color:GetRGB())
--这个，替换原生，可能会出现错误 ReputationBarMixin.UpdateBarColor
			--btn.Content.ReputationBar.UpdateBarColor= function()end
			btn.Content.ReputationBar:SetStatusBarColor(data.color:GetRGB());
		else
			--btn.UpdateBarColor= 
		end

		if data.atlas then
			btn.texture:SetAtlas(data.atlas)
		else
			btn.texture:SetTexture(data.texture or 0)
		end

		btn.check:SetShown(Save().btn and Save().indicato)
		btn.check:SetChecked(Save().factions[data.factionID])
	end)
	--[[	
		local factionID = data.factionID --or btn.factionIndex

		if not btn.clear_all then
			Create_Frame(btn)
		end
--[]
		local barColor, levelText, texture, atlas,isCapped
		local isMajorFaction = C_Reputation.IsMajorFaction(factionID)
		local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)

		if repInfo and repInfo.friendshipFactionID and repInfo.friendshipFactionID > 0 then--好友声望
			local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID)

			texture= repInfo and repInfo.texture

			if rankInfo and repInfo.nextThreshold then
				levelText= rankInfo.maxLevel
			else
				isCapped= true
			end

		elseif isMajorFaction then-- 名望
			local info = C_MajorFactions.GetMajorFactionData(factionID)
			if info then
				atlas= info.textureKit and 'MajorFactions_Icons_'..info.textureKit..'512'
				if C_MajorFactions.HasMaximumRenown(factionID) then
					isCapped=true
				else
					local levels = C_MajorFactions.GetRenownLevels(factionID)
					if levels then
						levelText= #levels
					end
				end
			end

		elseif data.reaction then
			if data.reaction == MAX_REPUTATION_REACTION then--已满
				isCapped=true
			else
				barColor = FACTION_BAR_COLORS[data.reaction]
				levelText= data.reaction..'/'..MAX_REPUTATION_REACTION
			end
		end


		local completedParagon--完成次数
		if isCapped and C_Reputation.IsFactionParagon(factionID) then--奖励
			--local currentValue, threshold, rewardQuestID, _, tooLowLevelForParagon, paragonStorageLevel = C_Reputation.GetFactionParagonInfo(factionID)
			local _, _, rewardQuestID, _, _, paragonStorageLevel = C_Reputation.GetFactionParagonInfo(factionID)
			if paragonStorageLevel and paragonStorageLevel>0 then
				completedParagon= paragonStorageLevel
			end
			if rewardQuestID then
				barColor= GREEN_FONT_COLOR
			end
		end

		btn.completed:SetText(completedParagon or '')
		

		if isCapped then
			btn.Content.Name:SetTextColor(FACTION_ORANGE_COLOR:GetRGB())
			btn.Content.ReputationBar:SetStatusBarColor(FACTION_ORANGE_COLOR:GetRGB())
		elseif barColor then
			btn.Content.Name:SetTextColor(barColor:GetRGB())
			btn.Content.ReputationBar:SetStatusBarColor(barColor:GetRGB())
		else
			btn.Content.Name:SetTextColor(1, 1, 1)
		end

		btn.levelText:SetText(levelText or '')
		if atlas then
			btn.texture:SetAtlas(atlas)
		else
			btn.texture:SetTexture(texture or 0)
		end

		btn.check:SetShown(Save().btn and Save().indicato)
		btn.check:SetChecked(Save().factions[factionID])
	end)

]]







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

--[[去掉 名望等级
	local c_RENOWN_LEVEL_LABEL= WoWTools_TextMixin:Magic(RENOWN_LEVEL_LABEL)-- = "名望等级 %d";
	WoWTools_DataMixin:Hook(ReputationBarMixin, 'TryShowReputationStandingText', function(self)
		if not self.reputationStandingText or self.BarText:GetAlpha()==0 then
			return
		end
		local t= self.reputationStandingText:match(c_RENOWN_LEVEL_LABEL)
		if t then
			self.BarText:SetText(t)
		end
	end)]]











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
		--self:SetAlpha((show or hasfocus) and 1 or 0.3)

		if hasfocus then
			Init_Search(ReputationFrame)
		end

	end)

	editBox:SetScript('OnEnterPressed', function()
		Init_Search(ReputationFrame)
	end)

	editBox:SetScript('OnEditFocusGained', function(self)
		ReputationFrame.Update= Init_Search
		--self:SetAlpha(1)
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
		--p:SetAlpha(0.3)
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