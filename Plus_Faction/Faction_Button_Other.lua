

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






local function set_expand_collapse(show)
	local num= C_Reputation.GetNumFactions() or 0
	if num<=0 then
		return
	end
--[[do
	if show then
		C_Reputation.ExpandAllFactionHeaders()

	else
		C_Reputation.CollapseAllFactionHeaders()
	end
end]]
	for index= num, 1,-1 do
		local data= C_Reputation.GetFactionDataByIndex(index)
		if data and data.isHeader then
			if show then
				do
					C_Reputation.ExpandFactionHeader(index)
				end
			else
				do
					C_Reputation.CollapseFactionHeader(index)
				end
			end
		end
	end

	do
		for _, frame in pairs(ReputationFrame.ScrollBox:GetFrames() or {}) do
			if frame.elementData.isHeader and frame:IsCollapsed() then
				frame:ToggleCollapsed()
			end
		end
	end
end
	--[[for _, frame in pairs(ReputationFrame.ScrollBox:GetFrames()) do
		if frame.elementData and frame.elementData.isHeader then
			if show then
				if frame:IsCollapsed() then
					frame:ToggleCollapsed()
				end
			else
				if not frame:IsCollapsed() then
					frame:ToggleCollapsed()
				end
			end
		end
	end]]




--[[
local function Init_Search(self)
	local numList= self:IsVisible() and C_Reputation.GetNumFactions() or 0
	if numList<=0 then
		return
	end

	local factionID, name

	local currID=math.max(self:GetNumber() or 0)
	currID= math.min(currID, 2147483647)

	local text= self:GetText()
	local info = currID>0 and C_Reputation.GetFactionDataByID(currID)
	if info then
		if info.factionID then
			factionID= info.factionID
		else
			return
		end
	else
		text= text:gsub(' ', '')
		if text~='' then
			name=text
		else
			return
		end
	end

	--local findHeader=true
	local find, find2
	local cur1, cur2


	for index=1, numList, 1 do
		local data= C_Reputation.GetFactionDataByIndex(index) or {}

		if factionID== data.factionID or data.name==name then
			find= index
			cur1= data.factionID
			--break

		elseif name and data.name:find(name) then
			find2= index
			cur2= data.factionID
		end

		if data.isHeader and data.isCollapsed then
			C_Reputation.ExpandFactionHeader(index)
		end
	end


	find= find or find2
	cur1= cur1 or cur2


	if find and cur1 then

		ReputationFrame.ScrollBox:ScrollToElementDataIndex(find)

		for _, frame in pairs(ReputationFrame.ScrollBox:GetFrames() or {}) do
			if frame.Content and frame.elementData then
				if frame.elementData.factionID==cur1 then
					frame.Content.BackgroundHighlight:SetAlpha(0.2)
				else
					frame.Content.BackgroundHighlight:SetAlpha(0)
				end
			end
		end
	end
end]]









local function Init()


	local down= WoWTools_ButtonMixin:Cbtn(WoWTools_FactionMixin.Button, {size=22, atlas='NPE_ArrowDown'})--texture='Interface\\Buttons\\UI-MinusButton-Up'})--展开所有
    WoWTools_FactionMixin.down= down
	down:SetPoint("RIGHT", ReputationFrame.filterDropdown, 'LEFT',-2,0)
	down:SetScript("OnClick", function()
		set_expand_collapse(true)
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
		set_expand_collapse(false)
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
		set_expand_collapse(true)
		if self:GetText()~='' then
			Init_Search(self)
		end
	end)

end






function WoWTools_FactionMixin:Init_Other_Button()
    Init()
end