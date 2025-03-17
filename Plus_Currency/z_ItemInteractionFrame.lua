local e= select(2, ...)
local function Save()
	return WoWTools_CurrencyMixin.Save
end






C_AddOns.LoadAddOn('Blizzard_ItemInteractionUI')

--#############
--套装,转换,货币
--Blizzard_ItemInteractionUI.lua
local function Init(self)
	if not self then
		return
	end

    local itemInfo= C_ItemInteraction.GetItemInteractionInfo() or {}

	local currencyID= itemInfo.currencyTypeId
	if currencyID then
		Save().ItemInteractionID= currencyID
		e.SetItemCurrencyID= currencyID
	else
		currencyID= self.chargeCurrencyTypeId or e.SetItemCurrencyID--套装，转换，货币
	end


	if not currencyID then
		return
	end

	if self==ItemInteractionFrame then
		TokenFrame.chargeCurrencyTypeId= currencyID
	end

    local info= (not Save().notPlus) and C_CurrencyInfo.GetCurrencyInfo(currencyID)
	local text
    if info and info.quantity and (info.discovered or info.quantity>0) then
        text= info.iconFileID and '|T'..info.iconFileID..':0|t' or ''
        text= text.. info.quantity
        text= info.maxQuantity and text..'/'..info.maxQuantity or text
        if not self.ItemInteractionFrameCurrencyText then
            self.ItemInteractionFrameCurrencyText= WoWTools_LabelMixin:Create(self)
            self.ItemInteractionFrameCurrencyText:SetPoint('TOPLEFT', 55, -38)
			self.ItemInteractionFrameCurrencyText:EnableMouse(true)
			self.ItemInteractionFrameCurrencyText:SetScript('OnEnter', function(self2)
				if self2.chargeCurrencyTypeId then
					GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
					GameTooltip:ClearLines()
					GameTooltip:SetCurrencyByID(self2.chargeCurrencyTypeId)
					GameTooltip:AddLine(' ')
					GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_CurrencyMixin.addName)
					GameTooltip:Show()
				end
			end)
			self.ItemInteractionFrameCurrencyText:SetScript('OnLeave', GameTooltip_Hide)
        end
		self.ItemInteractionFrameCurrencyText.chargeCurrencyTypeId= currencyID

        local chargeInfo = C_ItemInteraction.GetChargeInfo()
        local timeToNextCharge = chargeInfo.timeToNextCharge

        if timeToNextCharge and (self.interactionType == Enum.UIItemInteractionType.ItemConversion) then
            text= text ..' |cnGREEN_FONT_COLOR:'..(WoWTools_TimeMixin:SecondsToClock(timeToNextCharge, true) or '')..'|r'
        end

		if info.canEarnPerWeek and info.maxWeeklyQuantity and info.maxWeeklyQuantity>0 then
			text= text..' ('..info.quantityEarnedThisWeek..'/'..info.maxWeeklyQuantity..')'
		end
    end

	if self.ItemInteractionFrameCurrencyText then
		self.ItemInteractionFrameCurrencyText:SetText(text or '')
	end
end











function WoWTools_CurrencyMixin:Set_ItemInteractionFrame(frame)
    Init(frame)
end