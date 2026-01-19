
local function Save()
	return WoWToolsSave['Currency2']
end


local function IsLocked()
	return WoWTools_FrameMixin:IsLocked(CurrencyTransferMenu)
end

--货币，转移
local function Init()
	if not Save().notPlus  then
		return
	end

--有时会有BUG, 加个 重新加载UI 按钮
	local reload= CreateFrame('Button', nil, CurrencyTransferMenuCloseButton, 'WoWToolsButtonTemplate')
    reload:SetNormalTexture('Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up')
    reload:SetPoint('RIGHT', CurrencyTransferMenuCloseButton, 'LEFT', -2, 0)
    reload.tooltip=WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)
    reload:SetScript('OnClick', function() WoWTools_DataMixin:Reload() end)

	WoWTools_DataMixin:Hook(CurrencyTransferLogEntryMixin, 'Initialize', function(self, elementData)
		local name= WoWTools_UnitMixin:GetPlayerInfo(nil, elementData.sourceCharacterGUID, nil, {reName=true, reRealm=true})
		if name~='' then
			self.SourceName:SetText(name)
		end
		name= WoWTools_UnitMixin:GetPlayerInfo(nil, elementData.destinationCharacterGUID, nil, {reName=true, reRealm=true})
		if name~='' then
			self.DestinationName:SetText(name)
		end
	end)

	WoWTools_DataMixin:Hook(CurrencyTransferLog.ScrollBox, 'Update', function(self)
		if not self:HasView() then
            return
        end

		for _, btn in pairs(self:GetFrames() or {}) do
			local data= btn.transactionData or {}
			local name= WoWTools_UnitMixin:GetPlayerInfo(nil, data.sourceCharacterGUID, nil, {reName=true, reRealm=true})
			if name~='' then
				btn.SourceName:SetText(name)
			end

			name= WoWTools_UnitMixin:GetPlayerInfo(nil, data.destinationCharacterGUID, nil, {reName=true, reRealm=true})
			if name~='' then
				btn.DestinationName:SetText(name)
			end

		end
	end)

	local content= CurrencyTransferMenu.Content
	
	WoWTools_DataMixin:Hook(content.SourceSelector.Dropdown.Text, 'SetText', function(self)
		local data= CurrencyTransferMenu.sourceCharacterData
		if data then
			local name= WoWTools_UnitMixin:GetPlayerInfo(nil, data.characterGUID, nil, {reName=true, reRealm=true})
			if name ~='' and self:GetText()~=name then
				self:SetText(name)
			end
		end
	end)

	WoWTools_DataMixin:Hook(content.SourceSelector, 'RefreshPlayerName', function(self)--收取人，我 提示
		local name= WoWTools_UnitMixin:GetPlayerInfo(nil, WoWTools_DataMixin.Player.GUID, nil, {reName=true})
		if name~='' then
			self.PlayerName:SetFormattedText(WoWTools_DataMixin.onlyChinese and '收取人 %s' or CURRENCY_TRANSFER_DESTINATION, name)
		end
	end)

	WoWTools_DataMixin:Hook(content.SourceBalancePreview, 'SetCharacterName', function(self)
		local data= self:GetParent().sourceCharacterData or {}
		local name= WoWTools_UnitMixin:GetPlayerInfo(nil, data.characterGUID, nil, {reName=true, reRealm=true})
		if name~='' then
			self.Label:SetFormattedText(WoWTools_DataMixin.onlyChinese and '%s |cnWARNING_FONT_COLOR:的新余额|r' or CURRENCY_TRANSFER_NEW_BALANCE_PREVIEW, name)
		end
    end)

    WoWTools_DataMixin:Hook(content.PlayerBalancePreview, 'SetCharacterName', function(self)
		local name= WoWTools_UnitMixin:GetPlayerInfo(nil, WoWTools_DataMixin.Player.GUID, nil, {reName=true, reRealm=true})
		if name~='' then
			self.Label:SetFormattedText(WoWTools_DataMixin.onlyChinese and '%s |cnGREEN_FONT_COLOR:的新余额|r' or CURRENCY_TRANSFER_NEW_BALANCE_PREVIEW, name)
		end
    end)

	content.SourceBalancePreview.BalanceInfo.Amount:SetTextColor(1, 0, 0)
	content.PlayerBalancePreview.BalanceInfo.Amount:SetTextColor(0, 1, 0)

--总数
	CurrencyTransferMenu.wowNumLabel= CurrencyTransferMenu:CreateFontString(nil, 'BORDER', 'GameFontNormal') -- WoWTools_LabelMixin:Create(content, {color={r=0,g=0.8,b=1}, size=16, mouse=true})
	CurrencyTransferMenu.wowNumLabel:SetPoint('BOTTOM', content.SourceSelector.Dropdown, 'TOP', 0, 2)
	CurrencyTransferMenu.wowNumLabel:SetScript('OnLeave', function(self)
		GameTooltip_Hide()
		self:SetAlpha(1)
	end)
	CurrencyTransferMenu.wowNumLabel:SetScript('OnEnter', function(self)
		WoWTools_SetTooltipMixin:Frame(self)
		self:SetAlpha(0.5)
	end)

	WoWTools_DataMixin:Hook(CurrencyTransferMenu, 'FullRefresh', function(self)

		local text, currencyID
		if self.currencyInfo then
			text= '|T'..(self.currencyInfo.iconFileID or 0)..':0|t'

			currencyID= self.currencyInfo.currencyID-- self:GetCurrencyID()
			if currencyID and currencyID>0 then
				local num, tab= WoWTools_CurrencyMixin:GetAccountInfo(currencyID)
				if num>0 then
					text= text..#tab..WoWTools_DataMixin.Icon.wow2..WoWTools_DataMixin:MK(num, 3)
				end
			end
		end
		self.wowNumLabel:SetText(text)
		self.wowNumLabel.currencyID= currencyID
	end)

	Init=function()end
end









function WoWTools_CurrencyMixin:Init_Currency_Transfer()
    Init()
end
--conversionCost = C_ItemInteraction.GetItemConversionCurrencyCost(item)