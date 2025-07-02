

local function Init_Search(self)
	local numList= self:IsVisible() and C_Reputation.GetNumFactions() or 0
	if numList<=0 then
		return
	end

	local factionID, name, factionIndex
	local findTab={}

	factionID =math.max(self:GetNumber() or 0)
	factionID= factionID>0 and factionID or nil

	name= self:GetText() or ''
	name= name:gsub(' ', '')~='' and name or nil

	if name or factionID then
		for index= numList, 1, -1 do
			local data= C_Reputation.GetFactionDataByIndex(index)
			if data and data.factionID and data.name then
	--查找 ID
				if factionID and data.factionID==factionID then
					findTab[data.factionID]=true
					factionIndex= index
					break
	--查找 名称
				elseif name then
					local cn= WoWTools_TextMixin:CN(data.name)
					cn= cn~=data.name and cn or nil
					if cn and cn==name or data.name== name then
						findTab[data.factionID]=true
						factionIndex= index
						break

					elseif cn and cn:find(name) or data.name:find(name) then
						findTab[data.factionID]=true
						factionIndex= index
					end
				end
			end
		end
	end

	if factionIndex then
		ReputationFrame.ScrollBox:ScrollToElementDataIndex(factionIndex)
	end

	for _, btn in pairs(ReputationFrame.ScrollBox:GetFrames()) do
		if btn.Content and btn.elementData then
			if findTab[btn.elementData.factionID] then
				btn.Content.BackgroundHighlight:SetAlpha(0.3)
			else
				btn.Content.BackgroundHighlight:SetAlpha(0)
			end
		end
	end

	findTab=nil
end







local function Expand_All()
	local num= C_Reputation.GetNumFactions() or 0
	if num<=0 then
		return
	end

	for index= num, 1,-1 do
		local data= C_Reputation.GetFactionDataByIndex(index)
		if data and data.isHeader and data.isCollapsed then
			C_Reputation.ExpandFactionHeader(index)
		end
	end

	for _, frame in pairs(ReputationFrame.ScrollBox:GetFrames()) do
		if frame.elementData.isHeader and frame:IsCollapsed() then
			frame:ToggleCollapsed()
		end
	end
end













local function Init()
	local down= WoWTools_ButtonMixin:Cbtn(WoWTools_FactionMixin.Button, {size=22, atlas='NPE_ArrowDown'})--texture='Interface\\Buttons\\UI-MinusButton-Up'})--展开所有
    WoWTools_FactionMixin.down= down
	down:SetPoint("RIGHT", ReputationFrame.filterDropdown, 'LEFT',-2,0)
	down:SetScript("OnClick", function()
		Expand_All()
	end)
	down:SetScript("OnLeave", function() GameTooltip_Hide() end)
	down:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(' ', WoWTools_DataMixin.onlyChinese and '展开选项|A:editmode-down-arrow:16:11:0:-7|a' or HUD_EDIT_MODE_EXPAND_OPTIONS)
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_FactionMixin.addName)
		GameTooltip:Show()
	end)

	local up= WoWTools_ButtonMixin:Cbtn(down, {size=22, atlas='NPE_ArrowUp'})--texture='Interface\\Buttons\\UI-PlusButton-Up'})--收起所有
	up:SetPoint("RIGHT", down, 'LEFT', -2, 0)
	up:SetScript("OnClick", function()
		C_Reputation.CollapseAllFactionHeaders()
	end)
	up:SetScript("OnLeave", function() GameTooltip_Hide() end)
	up:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(' ', WoWTools_DataMixin.onlyChinese and '收起选项|A:editmode-up-arrow:16:11:0:3|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS)
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_FactionMixin.addName)
		GameTooltip:Show()
	end)

	local edit= WoWTools_EditBoxMixin:Create(up, {
		name='WoWTools_PlusFactionSearchBox',
		Template='SearchBoxTemplate'
	})
	edit:SetPoint('RIGHT', up, 'LEFT', -6, 0)
	edit:SetPoint('BOTTOMLEFT', CharacterFramePortrait, 'BOTTOMRIGHT')
	edit:SetAlpha(0.3)

	edit:HookScript('OnTextChanged', function(self)
		Init_Search(self)
	end)
	edit:SetScript('OnEnterPressed', function(self)
		Init_Search(self)
	end)
	edit:HookScript('OnEditFocusLost', function(self)
		self:SetAlpha(0.3)
	end)
	edit:HookScript('OnEditFocusGained', function(self)
		self:SetAlpha(1)
		Expand_All()
		if self:GetText()~='' then
			Init_Search(self)
		end
	end)

end






function WoWTools_FactionMixin:Init_Other_Button()
    Init()
end