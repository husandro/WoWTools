
local function Init_Search(self)
	local numList= self:IsVisible() and C_CurrencyInfo.GetCurrencyListSize() or 0
	if numList<=0 then
		return
	end

	local currencyID, name, currencyIndex
	local findTab={}

	currencyID =math.max(self:GetNumber() or 0)
	currencyID= currencyID>0 and currencyID or nil

	name= self:GetText() or ''
	name= name:gsub(' ', '')~='' and name or nil

	if name or currencyID then
		for index= numList, 1, -1 do
			local data= C_CurrencyInfo.GetCurrencyListInfo(index)
			if data and not data.isHeader and data.currencyID and data.name then
	--查找 ID
				if currencyID and data.currencyID==currencyID then
					findTab[data.currencyID]=true
					currencyIndex= index
					break
	--查找 名称
				elseif name then
					local cn= WoWTools_TextMixin:CN(data.name)
					cn= cn~=data.name and cn or nil
					if cn and cn==name or data.name== name then
						findTab[data.currencyID]=true
						currencyIndex= index
						break

					elseif cn and cn:find(name) or data.name:find(name) then
						findTab[data.currencyID]=true
						currencyIndex= index
					end
				end
			end
		end
	end

	if currencyIndex then
		TokenFrame.ScrollBox:ScrollToElementDataIndex(currencyIndex)
	end

	for _, btn in pairs(TokenFrame.ScrollBox:GetFrames()) do
		if btn.Content and btn.elementData then
			if findTab[btn.elementData.currencyID] then
				btn.Content.BackgroundHighlight:SetAlpha(0.3)
			else
				btn.Content.BackgroundHighlight:SetAlpha(0)
			end
		end
	end

	findTab=nil
end









local function Expand_All()
	local num= C_CurrencyInfo.GetCurrencyListSize() or 0
	if num<=0 then
		return
	end


	for i=num, 1, -1 do--展开所有
		local info = C_CurrencyInfo.GetCurrencyListInfo(i)
		if info and info.isHeader and not info.isHeaderExpanded then
			C_CurrencyInfo.ExpandCurrencyList(i, true)
		end
	end

	for _, frame in pairs(TokenFrame.ScrollBox:GetFrames() or {}) do
		if frame.elementData.isHeader and frame:IsCollapsed() then
			frame:ToggleCollapsed()
		end
	end

	WoWTools_CurrencyMixin:UpdateTokenFrame()
end









local function Init()
--展开,合起	
	local down= WoWTools_ButtonMixin:Cbtn(_G['WoWToolsPlusCurrencyMenuButton'], {
		size=22,
		atlas='NPE_ArrowDown',
		name='WoWToolsCurrencyExpandeListButton',
	})
	down:SetPoint('RIGHT', TokenFrame.filterDropdown, 'LEFT', -2, 0)

	down:SetScript("OnClick", function()
		Expand_All()
	end)
	down:SetScript("OnLeave", GameTooltip_Hide)
	down:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(' ', WoWTools_DataMixin.onlyChinese and '展开选项|A:editmode-down-arrow:16:11:0:-7|a' or HUD_EDIT_MODE_EXPAND_OPTIONS)
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_CurrencyMixin.addName)
		GameTooltip:Show()
	end)


--展开所有
	local up= WoWTools_ButtonMixin:Cbtn(down, {size=22, atlas='NPE_ArrowUp'})--texture='Interface\\Buttons\\UI-PlusButton-Up'})--收起所有
	up:SetPoint('RIGHT', down, 'LEFT', -2, 0)
	up:SetScript("OnClick", function()
		for i=1, C_CurrencyInfo.GetCurrencyListSize() do
			local info = C_CurrencyInfo.GetCurrencyListInfo(i)
			if info and info.isHeader then
				do
					C_CurrencyInfo.ExpandCurrencyList(i, false)
				end
			end
		end
		WoWTools_CurrencyMixin:UpdateTokenFrame()
	end)
	up:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	up:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(' ',WoWTools_DataMixin.onlyChinese and '收起选项|A:editmode-up-arrow:16:11:0:3|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS)
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_CurrencyMixin.addName)
		GameTooltip:Show()
	end)


	local edit= WoWTools_EditBoxMixin:Create(up, {
		name='WoWTools_PlusTokensSearchBox',
		Template='SearchBoxTemplate'
	})
	edit:SetPoint('RIGHT', up, 'LEFT', -6, 0)
	edit:SetPoint('BOTTOMLEFT', CharacterFramePortrait, 'BOTTOMRIGHT')

	edit:HookScript('OnTextChanged', function(self)
		Init_Search(self)
	end)
	edit:SetScript('OnEnterPressed', function(self)
		Init_Search(self)
	end)
	--[[edit:HookScript('OnEditFocusLost', function(self)
		self:SetAlpha(0.3)
	end)]]
	edit:HookScript('OnEditFocusGained', function(self)
		--self:SetAlpha(1)
		Expand_All()
		if self:GetText()~='' then
			Init_Search(self)
		end
	end)

	_G['WoWToolsPlusCurrencyMenuButton']:settings()
end






function WoWTools_CurrencyMixin:Init_Other_Button()
    Init()
end