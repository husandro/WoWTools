
local P_Save={
	--notPlus=true,
	tokens={},--{[currencyID]=true}指定显示，表
	item={},--[202196]= true
	--indicato=nil,--指定显示

	Hide=not WoWTools_DataMixin.Player.husandro,
	str=true,
	--scaleTrackButton=1,
	toRightTrackText=true,--向右平移
	--toTopTrack=true,--向上
	--notAutoHideTrack=true,--自动隐藏
	itemButtonUse=WoWTools_DataMixin.Player.husandro,
	--disabledItemTrack=true,禁用，追踪物品

	--hideCurrencyMax=true,--隐藏，已达到资源上限,提示
	--showID=true,--显示ID
}

local function Save()
	return WoWToolsSave['Currency2']
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





local function Blizzard_ItemInteractionUI()
	if not C_AddOns.IsAddOnLoaded('Blizzard_ItemInteractionUI') then
		return
	end

	hooksecurefunc(ItemInteractionFrame, 'SetupChargeCurrency', function(frame)
		WoWTools_CurrencyMixin:Set_ItemInteractionFrame(frame)
	end)
	Blizzard_ItemInteractionUI=function()end
	return true
end




local panel= CreateFrame("Frame")
--panel:RegisterEvent("ADDON_LOADED")
--panel:RegisterEvent('PLAYER_LOGIN')
panel:RegisterAllEvents()
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
			WoWToolsSave['Currency2']= WoWToolsSave['Currency2'] or P_Save

			WoWTools_CurrencyMixin.addName= '|A:bags-junkcoin:0:0|a'..(WoWTools_DataMixin.onlyChinese and '货币' or TOKENS)

			--添加控制面板
			WoWTools_PanelMixin:OnlyCheck({
				name= WoWTools_CurrencyMixin.addName,
				GetValue= function() return not Save().disabled end,
				SetValue= function()
					Save().disabled= not Save().disabled and true or nil
					print(
						WoWTools_DataMixin.Icon.icon2..WoWTools_CurrencyMixin.addName,
						WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
						WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
					)
				end
			})

			WoWTools_DataMixin.CurrencyUpdateItemLevelID= Save().ItemInteractionID--套装，转换，货币

			if Save().disabled then
--记录，套装，转换，货币
				hooksecurefunc(ItemInteractionFrame, 'SetupChargeCurrency', function()--C_ItemInteraction.GetChargeInfo()
					local itemInfo= C_ItemInteraction.GetItemInteractionInfo() or {}
					Save().ItemInteractionID= itemInfo.currencyTypeId
					WoWTools_DataMixin.CurrencyUpdateItemLevelID= itemInfo.currencyTypeId
				end)
				self:UnregisterEvent(event)

			else

				for itemID, _ in pairs(Save().item) do
					WoWTools_Mixin:Load({id=itemID, type='item'})--加载 item quest spell
				end

				if Blizzard_ItemInteractionUI() then
					self:UnregisterEvent(event)
				end
			end

		elseif arg1=='Blizzard_ItemInteractionUI' and WoWToolsSave then
			if Blizzard_ItemInteractionUI() then
				self:UnregisterEvent(event)
			end
		end

	elseif event=='PLAYER_LOGIN' then
		Init()
		self:UnregisterEvent(event)
    end
end)