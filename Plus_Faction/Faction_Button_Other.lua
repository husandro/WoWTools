local EditBox

















local function Init_Search(self)
	local numList= C_Reputation.GetNumFactions() or 0
	if numList<=0 then
		return
	end

	local factionID, name, data
	local factionList={}

	factionID =math.max(EditBox:GetNumber() or 0)
	factionID= factionID>0 and factionID or nil

	name= EditBox:GetText() or ''
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





















local function Init()
	--local P_Update= ReputationFrame.Update

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












	EditBox= WoWTools_EditBoxMixin:Create(up, {
		name='WoWTools_PlusFactionSearchBox',
		Template='SearchBoxTemplate'
	})

	EditBox:SetPoint('RIGHT', up, 'LEFT', -6, 0)
	EditBox:SetPoint('BOTTOMLEFT', CharacterFramePortrait, 'BOTTOMRIGHT')

	EditBox:SetScript('OnTextChanged', function(self)
		local show= self:GetText() ~= ""
		self.Instructions:SetShown(not show)
		local hasfocus= self:HasFocus()
		self:SetAlpha((show or hasfocus) and 1 or 0.3)

		if hasfocus then
			Init_Search(ReputationFrame)
		end

	end)

	EditBox:SetScript('OnEnterPressed', function()
		Init_Search(ReputationFrame)
	end)

	EditBox:SetScript('OnEditFocusGained', function(self)
		ReputationFrame.Update= Init_Search
		self:SetAlpha(1)
		if self:GetText()~='' then
			Init_Search(ReputationFrame)
		end
		self.clearButton:SetShown(true)
	end)

	EditBox:SetScript('OnEditFocusLost', function(self)
		if self.clearButton:IsShown() and self:GetText()=='' then
			self.clearButton:Click()
		end
	end)

	EditBox.clearButton:SetScript('OnClick', function(self)
		ReputationFrame.Update= ReputationFrameMixin.Update
		ReputationFrame:Update()
		EditBox:SetText('')
		EditBox:ClearFocus()
		self:Hide()
		EditBox:SetAlpha(0.3)
	end)

	EditBox:SetScript('OnEscapePressed', function(self)
		self:ClearFocus()
	end)



	Init=function()end
end






function WoWTools_FactionMixin:Init_Other_Button()
    Init()
end