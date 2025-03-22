local e= select(2, ...)
local function Save()
    return WoWTools_CurrencyMixin.Save
end













local function set_Tokens_Button(frame)--设置, 列表, 内容
	if Save().notPlus then
		if frame.check then
			frame.check:SetShown(false)
			if frame.Content then
				frame.Content.Count:SetTextColor(1,1,1)
				local lable= frame.Content.Name2 or frame.Content.Name--汉化，新建
				lable:SetTextColor(1,1,1)
			end
			if frame.percentText then
				frame.percentText:SetText('')
			end
		end
		return
	end

	local data= frame.elementData or {}
	if not data.currencyID then
		return
	end


	local info, _, _, percent, isMax, canWeek, canEarned, canQuantity= WoWTools_CurrencyMixin:GetInfo(data.currencyID, data.currencyIndex)
	if not info or info.isHealer then
		if frame.check then
			frame.check:SetShown(false)
		end
		return
	end



	local currencyID= info.currencyID
	if not frame.check then
		frame.check= CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
		frame.check:SetPoint('RIGHT', frame, 'LEFT',4,0)
		frame.check:SetScript('OnClick', function(self)
			if self.currencyID then
				Save().tokens[self.currencyID]= not Save().tokens[self.currencyID] and true or nil
				frame.check:SetAlpha(Save().tokens[self.currencyID] and 1 or 0.5)
				WoWTools_CurrencyMixin:Set_TrackButton_Text()
			end
		end)
		frame.check:SetScript('OnEnter', function(self)
			GameTooltip:SetOwner(self, "ANCHOR_LEFT")
			GameTooltip:ClearLines()
			if self.currencyID then
				GameTooltip:SetCurrencyByID(self.currencyID)
				GameTooltip:AddLine(" ")
			end
			GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '追踪' or TRACKING, WoWTools_Mixin.onlyChinese and '指定' or COMBAT_ALLY_START_MISSION)
			GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_CurrencyMixin.addName)
			GameTooltip:Show()
		end)
		frame.check:SetScript('OnLeave', GameTooltip_Hide)
		frame.check:SetSize(18,18)

		frame:HookScript('OnEnter', function(self)
			if WoWTools_CurrencyMixin.TrackButton then
				for _, btn in pairs(WoWTools_CurrencyMixin.TrackButton.btn or {}) do
					local show= self.check.currencyID and self.check.currencyID== btn.currencyID
					btn:SetButtonState(self.check.currencyID== btn.currencyID and 'PUSHED' or 'NORMAL')
				end
			end
		end)
		frame:HookScript('OnLeave', function()
			if WoWTools_CurrencyMixin.TrackButton then
				for _, btn in pairs(WoWTools_CurrencyMixin.TrackButton.btn or {}) do
					btn:SetButtonState('NORMAL')
				end
			end
		end)
	end

	if frame.check then
		frame.check:SetCheckedTexture(info and info.iconFileID or WoWTools_DataMixin.Icon.icon)
		frame.check.currencyID= currencyID
		frame.check:SetShown(true)
		frame.check:SetChecked(Save().tokens[currencyID])
		frame.check:SetAlpha(Save().tokens[currencyID] and 1 or 0.5)
	end


	if isMax then
		frame.Content.Count:SetTextColor(1,0,0)
	elseif canWeek or canEarned or canQuantity then
		frame.Content.Count:SetTextColor(0,1,0)
	else
		frame.Content.Count:SetTextColor(1,1,1)
	end

	if percent and not frame.percentText then
		frame.percentText= WoWTools_LabelMixin:Create(frame, {color={r=1,g=1,b=1}})
		frame.percentText:SetPoint('RIGHT', frame.Content.Count, 'LEFT')
	end

	if frame.percentText then
		frame.percentText:SetText(percent and format('%d%%', percent) or '')
	end

	if frame.Content.Name then
		local lable= frame.Content.Name2 or frame.Content.Name--汉化，新建
		if info.isAccountTransferable then
			lable:SetTextColor(0, 0.8, 1)
		else
			local r, g, b= C_Item.GetItemQualityColor(info and info.quality or 1)
			lable:SetTextColor(r or 1, g or 1, b or 1)
		end
	end

	--[[if frame.Name then
		local r, g, b= C_Item.GetItemQualityColor(info and info.quality or 1)
		frame.Content.Name:SetTextColor(r or 1, g or 1, b or 1)
	end]]


	--frame.Content.AccountWideIcon:SetShown(info.isAccountTransferable)
end













function WoWTools_CurrencyMixin:Init_ScrollBox_Plus()
    hooksecurefunc(TokenFrame.ScrollBox, 'Update', function(f)
        if not f:GetView() then
            return
        end
        for _, frame in pairs(f:GetFrames() or {}) do
            set_Tokens_Button(frame)--设置, 列表, 内容
        end
    end)
end