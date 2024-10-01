local e= select(2, ...)





local function Init(Button)
	--展开,合起
	
	local down= WoWTools_ButtonMixin:Cbtn(WoWTools_TokensMixin.Button, {size={22,22}, atlas='NPE_ArrowDown'})--texture='Interface\\Buttons\\UI-MinusButton-Up'})--展开所有
	WoWTools_TokensMixin.Button.down= down

	down:SetPoint('RIGHT', TokenFrame.CurrencyTransferLogToggleButton, 'LEFT', -2, 0)
	down:SetScript("OnClick", function()
		for i=1, C_CurrencyInfo.GetCurrencyListSize() do--展开所有
			local info = C_CurrencyInfo.GetCurrencyListInfo(i)
			if info and info.isHeader and not info.isHeaderExpanded then
				C_CurrencyInfo.ExpandCurrencyList(i, true)
			end
		end
		e.call(TokenFrame.Update, TokenFrame)
	end)
	down:SetScript("OnLeave", GameTooltip_Hide)
	down:SetScript('OnEnter', function(self)
		e.tips:SetOwner(self, "ANCHOR_LEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(' ', e.onlyChinese and '展开选项|A:editmode-down-arrow:16:11:0:-7|a' or HUD_EDIT_MODE_EXPAND_OPTIONS)
		e.tips:AddDoubleLine(e.addName, WoWTools_TokensMixin.addName)
		e.tips:Show()
	end)


--展开所有
	local up= WoWTools_ButtonMixin:Cbtn(down, {size={22,22}, atlas='NPE_ArrowUp'})--texture='Interface\\Buttons\\UI-PlusButton-Up'})--收起所有
	up:SetPoint('RIGHT', down, 'LEFT', -2, 0)
	up:SetScript("OnClick", function()
		for i=1, C_CurrencyInfo.GetCurrencyListSize() do
			local info = C_CurrencyInfo.GetCurrencyListInfo(i)
			if info  and info.isHeader and info.isHeaderExpanded then
				C_CurrencyInfo.ExpandCurrencyList(i, false)
			end
		end
		e.call(TokenFrame.Update, TokenFrame)
	end)
	up:SetScript("OnLeave", GameTooltip_Hide)
	up:SetScript('OnEnter', function(self)
		e.tips:SetOwner(self, "ANCHOR_LEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(' ',e.onlyChinese and '收起选项|A:editmode-up-arrow:16:11:0:3|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS)
		e.tips:AddDoubleLine(e.addName, WoWTools_TokensMixin.addName)
		e.tips:Show()
	end)
if e.Player.husandro then
	
	local edit= WoWTools_EditBoxMixn:Create(up, {name='WoWTools_PlusTokensSearchBox', instructions= 'text', Template='SearchBoxTemplate'})
	edit:SetPoint('RIGHT', up, 'LEFT', -6, 0)
	edit.Instructions:SetText(e.onlyChinese and '名称, ID' or (NAME..', ID'))
	edit:SetScript('OnEscapePressed', EditBox_ClearFocus)
    edit:SetScript('OnHide', function(s) s:SetText('') s:ClearFocus() end)
	edit:SetSize(180, 23)
end
	WoWTools_TokensMixin.Button:settings()
end






function WoWTools_TokensMixin:Init_Other_Button()
    Init()
end