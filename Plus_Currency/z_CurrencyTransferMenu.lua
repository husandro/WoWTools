
local function Save()
	return WoWToolsSave['Currency2']
end




local function IsLocked()
	return WoWTools_FrameMixin:IsLocked(CurrencyTransferMenu) or issecure()
end

--货币，转移
local function Init()
	--不能点击，关闭按钮

	CurrencyTransferLogCloseButton:SetFrameLevel(CurrencyTransferLog.TitleContainer:GetFrameLevel()+2)
	CurrencyTransferMenuCloseButton:SetFrameLevel(CurrencyTransferMenu.TitleContainer:GetFrameLevel()+2)


	hooksecurefunc(CurrencyTransferLog.ScrollBox, 'Update', function(self)
		if not self:GetView() or Save().notPlus or WoWTools_FrameMixin:IsLocked(self:GetParent()) then
            return
        end

		for _, btn in pairs(self:GetFrames() or {}) do
			local data= btn.transactionData or {}
			local name= WoWTools_UnitMixin:GetPlayerInfo({guid=data.sourceCharacterGUID, reName=true, reRealm=true})
			if name~='' then
				btn.SourceName:SetText(name)
			end

			name= WoWTools_UnitMixin:GetPlayerInfo({guid=data.destinationCharacterGUID, reName=true, reRealm=true})
			if name~='' then
				btn.DestinationName:SetText(name)
			end

		end
	end)

local content= CurrencyTransferMenu.Content--11.2
	or CurrencyTransferMenu

	hooksecurefunc(content.SourceSelector, 'RefreshPlayerName', function(self)--收取人，我 提示		
		if not Save().notPlus and not IsLocked() then
			local name= WoWTools_UnitMixin:GetPlayerInfo({guid=WoWTools_DataMixin.Player.GUID, reName=true})
			if name~='' then
				self.PlayerName:SetFormattedText(WoWTools_DataMixin.onlyChinese and '收取人 %s' or CURRENCY_TRANSFER_DESTINATION, name)
			end
		end
	end)

	hooksecurefunc(content.SourceBalancePreview, 'SetCharacterName', function(self)
		if not Save().notPlus and not IsLocked() then
			local data= self:GetParent().sourceCharacterData or {}
			local name= WoWTools_UnitMixin:GetPlayerInfo({guid=data.characterGUID, reName=true, reRealm=true})
			if name~='' then
				self.Label:SetFormattedText(WoWTools_DataMixin.onlyChinese and '%s |cnRED_FONT_COLOR:的新余额|r' or CURRENCY_TRANSFER_NEW_BALANCE_PREVIEW, name)
			end
		end
    end)

    hooksecurefunc(content.PlayerBalancePreview, 'SetCharacterName', function(self)
		if not Save().notPlus and not IsLocked() then
			local name= WoWTools_UnitMixin:GetPlayerInfo({guid=WoWTools_DataMixin.Player.GUID, reName=true, reRealm=true})
			if name~='' then
				self.Label:SetFormattedText(WoWTools_DataMixin.onlyChinese and '%s |cnGREEN_FONT_COLOR:的新余额|r' or CURRENCY_TRANSFER_NEW_BALANCE_PREVIEW, name)
			end
		end
    end)

	content.SourceBalancePreview.BalanceInfo.Amount:SetTextColor(1, 0, 0)
	content.PlayerBalancePreview.BalanceInfo.Amount:SetTextColor(0, 1, 0)

--总数
	CurrencyTransferMenu.wowNumLabel= WoWTools_LabelMixin:Create(content, {color={r=0,g=0.8,b=1}, size=16, mouse=true})
	CurrencyTransferMenu.wowNumLabel:SetPoint('BOTTOM', content.SourceSelector.Dropdown, 'TOP', 0, 2)
	CurrencyTransferMenu.wowNumLabel:SetScript('OnLeave', GameTooltip_Hide)
	CurrencyTransferMenu.wowNumLabel:SetScript('OnEnter', function(self)
		if not Save().notPlus then
			WoWTools_SetTooltipMixin:Frame(self)
		end
	end)

	hooksecurefunc(CurrencyTransferMenu, 'FullRefresh', function(self)
		if IsLocked() then
			return
		end

		local text
		local currencyID= self:GetCurrencyID()
		if not Save().notPlus then
			if currencyID and currencyID>0 then
				local num, tab= WoWTools_CurrencyMixin:GetAccountInfo(currencyID)
				if num>0 then
					text= #tab..WoWTools_DataMixin.Icon.wow2..WoWTools_Mixin:MK(num, 3)
				end
			end
		end
		self.wowNumLabel:SetText(text or '')
		self.wowNumLabel.currencyID= currencyID
	end)

	Init=function()end
end









function WoWTools_CurrencyMixin:Init_Currency_Transfer()
	if WoWTools_DataMixin.Player.husandro then
    	Init()
	else
		Init=function()end
	end
end