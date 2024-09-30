local e= select(2, ...)
local function Save()
    return WoWTools_TokensMixin.Save
end













local function set_Tokens_Button(frame)--设置, 列表, 内容

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
				WoWTools_TokensMixin:Set_TrackButton_Text()
			end
		end)
		frame.check:SetScript('OnEnter', function(self)
			e.tips:SetOwner(self, "ANCHOR_LEFT")
			e.tips:ClearLines()
			if self.currencyID then
				e.tips:SetCurrencyByID(self.currencyID)
				e.tips:AddLine(" ")
			end
			e.tips:AddDoubleLine(e.onlyChinese and '追踪' or TRACKING, e.onlyChinese and '指定' or COMBAT_ALLY_START_MISSION)
			e.tips:AddDoubleLine(e.addName, WoWTools_TokensMixin.addName)
			e.tips:Show()
		end)
		frame.check:SetScript('OnLeave', GameTooltip_Hide)
		frame.check:SetSize(18,18)

		frame:HookScript('OnEnter', function(self)
			for _, btn in pairs(WoWTools_TokensMixin.TrackButton and WoWTools_TokensMixin.TrackButton.btn or {}) do
				local show= self.check.currencyID and self.check.currencyID== btn.currencyID
				if btn:CanChangeAttribute() then
					btn:SetScale(show and 2 or 1)
				else
					btn:SetAlpha(show and 0.3 or 1)
				end
			end
		end)
		frame:HookScript('OnLeave', function()
			for _, btn in pairs(WoWTools_TokensMixin.TrackButton and WoWTools_TokensMixin.TrackButton.btn or {}) do
				if btn:CanChangeAttribute() then
					btn:SetScale(1)
				end
				btn:SetAlpha(1)
			end
		end)
	end

	if frame.check then
		frame.check:SetCheckedTexture(info and info.iconFileID or e.Icon.icon)
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
		frame.percentText= WoWTools_LabelMixin:CreateLabel(frame, {color={r=1,g=1,b=1}})
		frame.percentText:SetPoint('RIGHT', frame.Content.Count, 'LEFT')
	end

	if frame.percentText then
		frame.percentText:SetText(percent and format('%d%%', percent) or '')
	end

	if frame.Content.Name then
		if info.isAccountTransferable then
			frame.Content.Name:SetTextColor(0, 0.8, 1)		
		else
			local r, g, b= C_Item.GetItemQualityColor(info and info.quality or 1)
			frame.Content.Name:SetTextColor(r or 1, g or 1, b or 1)
		end
	end

	--[[if frame.Name then
		local r, g, b= C_Item.GetItemQualityColor(info and info.quality or 1)
		frame.Content.Name:SetTextColor(r or 1, g or 1, b or 1)
	end]]


	--frame.Content.AccountWideIcon:SetShown(info.isAccountTransferable)
end













function WoWTools_TokensMixin:Init_ScrollBox_Plus()
    hooksecurefunc(TokenFrame.ScrollBox, 'Update', function(f)
        if not f:GetView() then
            return
        end
        for _, frame in pairs(f:GetFrames() or {}) do
            set_Tokens_Button(frame)--设置, 列表, 内容
        end
    end)
end