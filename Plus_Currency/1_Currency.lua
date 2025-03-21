local id, e = ...
WoWTools_CurrencyMixin.Save={
	--notPlus=true,
	tokens={},--{[currencyID]=true}指定显示，表
	item={},--[202196]= true
	--indicato=nil,--指定显示

	Hide=not e.Player.husandro,
	str=true,
	--scaleTrackButton=1,
	toRightTrackText=true,--向右平移
	--toTopTrack=true,--向上
	--notAutoHideTrack=true,--自动隐藏
	itemButtonUse=e.Player.husandro,
	--disabledItemTrack=true,禁用，追踪物品

	--hideCurrencyMax=true,--隐藏，已达到资源上限,提示
	--showID=true,--显示ID
}

local function Save()
	return WoWTools_CurrencyMixin.Save
end

function WoWTools_CurrencyMixin:UpdateTokenFrame()
	if not WoWTools_Mixin:IsLockFrame(TokenFrame) then
		WoWTools_Mixin:Call(TokenFrame.Update, TokenFrame)
		WoWTools_Mixin:Call(TokenFramePopup.CloseIfHidden, TokenFramePopup)
	end
end






local function Init()
	WoWTools_CurrencyMixin:Init_Button()
	WoWTools_CurrencyMixin:Init_Other_Button()
	WoWTools_CurrencyMixin:Init_Currency_Transfer()--货币，转移
	WoWTools_CurrencyMixin:Init_TrackButton()
	WoWTools_CurrencyMixin:Init_ScrollBox_Plus()
	WoWTools_CurrencyMixin:Init_MaxTooltip()

	hooksecurefunc(TokenFrame, 'Update', function(frame)
		WoWTools_CurrencyMixin:Set_ItemInteractionFrame(frame)--套装,转换,货币

		if WoWTools_CurrencyMixin.TrackButton then
			WoWTools_CurrencyMixin:Set_TrackButton_Text()
		else
			WoWTools_CurrencyMixin:Init_TrackButton()
		end
	end)
end










local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
			WoWTools_CurrencyMixin.Save= WoWToolsSave['Currency2'] or Save()

			local addName= '|A:bags-junkcoin:0:0|a'..(e.onlyChinese and '货币' or TOKENS)
			WoWTools_CurrencyMixin.addName= addName

			--添加控制面板
			e.AddPanel_Check({
				name= addName,
				GetValue= function() return not Save().disabled end,
				SetValue= function()
					Save().disabled= not Save().disabled and true or nil
					print(e.Icon.icon2.. addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
				end
			})

			e.SetItemCurrencyID= Save().ItemInteractionID--套装，转换，货币

			if Save().disabled then
				self:UnregisterEvent(event)
			else
				for itemID, _ in pairs(Save().item) do
					WoWTools_Mixin:Load({id=itemID, type='item'})--加载 item quest spell
				end
				Init()
			end

		elseif arg1=='Blizzard_ItemInteractionUI' then
			if not Save().disabled then
				hooksecurefunc(ItemInteractionFrame, 'SetupChargeCurrency', function(frame)
					WoWTools_CurrencyMixin:Set_ItemInteractionFrame(frame)
				end)
			else--记录，套装，转换，货币
				hooksecurefunc(ItemInteractionFrame, 'SetupChargeCurrency', function(frame)
					local itemInfo= C_ItemInteraction.GetItemInteractionInfo() or {}
					Save().ItemInteractionID= itemInfo.currencyTypeId
					e.SetItemCurrencyID= itemInfo.currencyTypeId
				end)
				C_ItemInteraction.GetChargeInfo()
			end
		end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Currency2']= Save()
        end
    end
end)