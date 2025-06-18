



local function Init_Search(self)
	local numList= C_CurrencyInfo.GetCurrencyListSize()

	local currencyID, name

	local currID=math.max(self:GetNumber() or 0)
	currID= math.min(currID, 2147483647)

	local text= self:GetText()
	local info = currID>0 and C_CurrencyInfo.GetCurrencyInfo(currID)
	if info then
		if info.discovered then
			currencyID= info.currencyID
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

	local find, find2
	local cur1, cur2


	for index=1, numList, 1 do
		local data= C_CurrencyInfo.GetCurrencyListInfo(index) or {}

		if currencyID== data.currencyID or data.name==name then
			find= index
			cur1= data.currencyID

		elseif name and data.name:find(name) then
			find2= index
			cur2= data.currencyID
		end

		if data.isHeader and not data.isHeaderExpanded then
			C_CurrencyInfo.ExpandCurrencyList(index, true)
		end
	end

	WoWTools_CurrencyMixin:UpdateTokenFrame()


	find= find or find2
	cur1= cur1 or cur2


	if find and cur1 then

		TokenFrame.ScrollBox:ScrollToElementDataIndex(find)

		for _, frame in pairs(TokenFrame.ScrollBox:GetFrames() or {}) do
			if frame.Content and frame.elementData then
				if frame.elementData.currencyID==cur1 then
					frame.Content.BackgroundHighlight:SetAlpha(0.2)
				else
					frame.Content.BackgroundHighlight:SetAlpha(0)
				end
			end
		end

	end


end









local function Init()
--展开,合起	
	local down= WoWTools_ButtonMixin:Cbtn(_G['WoWToolsPlusCurrencyMenuButton'], {
		size=22,
		atlas='NPE_ArrowDown',
		name='WoWToolsCurrencyExpandeListButton',
	})--texture='Interface\\Buttons\\UI-MinusButton-Up'})--展开所有
	--_G['WoWToolsPlusCurrencyMenuButton'].down= down

	down:SetPoint('RIGHT', TokenFrame.filterDropdown, 'LEFT', -2, 0)

	down:SetScript("OnClick", function()
		for i=1, C_CurrencyInfo.GetCurrencyListSize() do--展开所有
			local info = C_CurrencyInfo.GetCurrencyListInfo(i)
			if info and info.isHeader and not info.isHeaderExpanded then
				C_CurrencyInfo.ExpandCurrencyList(i, true)
				WoWTools_CurrencyMixin:UpdateTokenFrame()
			end
		end
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
			if info  and info.isHeader and info.isHeaderExpanded then
				C_CurrencyInfo.ExpandCurrencyList(i, false)
			end
		end
		WoWTools_CurrencyMixin:UpdateTokenFrame()
	end)
	up:SetScript("OnLeave", GameTooltip_Hide)
	up:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(' ',WoWTools_DataMixin.onlyChinese and '收起选项|A:editmode-up-arrow:16:11:0:3|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS)
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_CurrencyMixin.addName)
		GameTooltip:Show()
	end)


	local edit= WoWTools_EditBoxMixin:Create(up, {name='WoWTools_PlusTokensSearchBox', Template='SearchBoxTemplate'})
	edit:SetPoint('RIGHT', up, 'LEFT', -6, 0)
	edit:SetPoint('BOTTOMLEFT', CharacterFramePortrait, 'BOTTOMRIGHT')
	edit:SetAlpha(0.3)
	edit.Instructions:SetText(WoWTools_DataMixin.onlyChinese and '需求：展开选项' or (NEED..': '..HUD_EDIT_MODE_EXPAND_OPTIONS:gsub(' |A:.+|a', '')))
	edit:SetScript('OnTextChanged', Init_Search)
	edit:SetScript('OnEnterPressed', Init_Search)
	edit:HookScript('OnEditFocusLost', function(self) self:SetAlpha(0.3) end)
	edit:HookScript('OnEditFocusGained', function(self) self:SetAlpha(1) end)
	edit:HookScript('OnTextChanged', function(s)
        s.Instructions:SetShown(s:GetText() == "")
    end)
	edit:SetSize(180, 23)

	_G['WoWToolsPlusCurrencyMenuButton']:settings()
end






function WoWTools_CurrencyMixin:Init_Other_Button()
    Init()
end