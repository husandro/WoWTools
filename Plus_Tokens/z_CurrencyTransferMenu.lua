local e= select(2, ...)








--货币，转移
local function Init()
	hooksecurefunc(CurrencyTransferLog.ScrollBox, 'Update', function(self)
		if not self:GetView() or Save().notPlus then
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
	CurrencyTransferMenuCloseButton:SetFrameLevel(CurrencyTransferMenuCloseButton:GetFrameLevel()+1)--原始，不好点击
	CurrencyTransferMenuCloseButton:SetFrameStrata('HIGH')

	hooksecurefunc(CurrencyTransferMenu.SourceSelector, 'RefreshPlayerName', function(self)--收取人，我 提示		
		if not Save().notPlus then
			local name= WoWTools_UnitMixin:GetPlayerInfo({guid=e.Player.guid, reName=true})
			if name~='' then
				self.PlayerName:SetFormattedText(e.onlyChinese and '收取人 %s' or CURRENCY_TRANSFER_DESTINATION, name)
			end
		end
	end)

	hooksecurefunc(CurrencyTransferMenu.SourceBalancePreview, 'SetCharacterName', function(self)
		if not Save().notPlus then
			local data= self:GetParent().sourceCharacterData or {}
			local name= WoWTools_UnitMixin:GetPlayerInfo({guid=data.characterGUID, reName=true, reRealm=true})
			if name~='' then
				self.Label:SetFormattedText(e.onlyChinese and '%s |cnRED_FONT_COLOR:的新余额|r' or CURRENCY_TRANSFER_NEW_BALANCE_PREVIEW, name)
			end
		end
    end)
    hooksecurefunc(CurrencyTransferMenu.PlayerBalancePreview, 'SetCharacterName', function(self)
		if not Save().notPlus then
			local name= WoWTools_UnitMixin:GetPlayerInfo({guid=e.Player.guid, reName=true, reRealm=true})
			if name~='' then
				self.Label:SetFormattedText(e.onlyChinese and '%s |cnGREEN_FONT_COLOR:的新余额|r' or CURRENCY_TRANSFER_NEW_BALANCE_PREVIEW, name)
			end
		end
    end)

	--可能会出现错误
		CurrencyTransferMenu.AmountSelector.InputBox:HookScript('OnTextChanged', function(self, userInput)
			if not Save().notPlus then
				if userInput then
					e.call(self.ValidateAndSetValue, self)
				end
			end
		end)

	CurrencyTransferMenu.SourceBalancePreview.BalanceInfo.Amount:SetTextColor(1,0,0)
	CurrencyTransferMenu.PlayerBalancePreview.BalanceInfo.Amount:SetTextColor(0,1,0)
end









function WoWTools_TokensMixin:Init_Currency_Transfer()
    Init()
end