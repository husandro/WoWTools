
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

	WoWTools_DataMixin:Hook(TokenFrame, 'Update', function(frame)
		WoWTools_CurrencyMixin:Set_ItemInteractionFrame(frame)--套装,转换,货币

		if WoWTools_CurrencyMixin.TrackButton then
			WoWTools_CurrencyMixin:Set_TrackButton_Text()
		else
			WoWTools_CurrencyMixin:Init_TrackButton()
		end
	end)

	Init=function()end
end





local function Init_ItemInteractionUI()
	WoWTools_DataMixin:Hook(ItemInteractionFrame, 'SetupChargeCurrency', function(frame)
		WoWTools_CurrencyMixin:Set_ItemInteractionFrame(frame)
	end)
	Init_ItemInteractionUI=function()end
end





--记录，套装，转换，货币
local function Init_Disabled()
	WoWTools_DataMixin:Hook(ItemInteractionFrame, 'SetupChargeCurrency', function()--C_ItemInteraction.GetChargeInfo()
		local itemInfo= C_ItemInteraction.GetItemInteractionInfo() or {}
		Save().ItemInteractionID= itemInfo.currencyTypeId
		WoWTools_DataMixin.CurrencyUpdateItemLevelID= itemInfo.currencyTypeId
	end)
	Init_Disabled=function()end
end





local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_ENTERING_WORLD')

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
				if C_AddOns.IsAddOnLoaded('Blizzard_ItemInteractionUI') then
					Init_Disabled()
					self:UnregisterAllEvents()
				else
					self:UnregisterEvent('PLAYER_ENTERING_WORLD')
				end

			else
				for itemID, _ in pairs(Save().item) do
					WoWTools_DataMixin:Load({id=itemID, type='item'})--加载 item quest spell
				end


				local a= C_AddOns.IsAddOnLoaded('Blizzard_ItemInteractionUI')
				if a then
					Init_ItemInteractionUI()
				end

				local b= C_AddOns.IsAddOnLoaded('Blizzard_TokenUI')
				if b then
					WoWTools_CurrencyMixin:Init_Currency_Transfer()--货币，转移
				end
				if a and b then
					self:UnregisterEvent(event)
				end
			end

		elseif arg1=='Blizzard_ItemInteractionUI' and WoWToolsSave then
			if Save().disabled then
				Init_Disabled()
			else
				Init_ItemInteractionUI()
			end

			if C_AddOns.IsAddOnLoaded('Blizzard_TokenUI') then
				self:UnregisterEvent(event)
			end

		elseif arg1=='Blizzard_TokenUI' then
			WoWTools_CurrencyMixin:Init_Currency_Transfer()--货币，转移

			if C_AddOns.IsAddOnLoaded('Blizzard_ItemInteractionUI') then
				self:UnregisterEvent(event)
			end
		end

	elseif event=='PLAYER_ENTERING_WORLD' and WoWToolsSave then
		Init()
		self:UnregisterEvent(event)
    end
end)