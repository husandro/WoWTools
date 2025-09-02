
local function Save()
    return WoWToolsSave['Currency2']
end













local function Create(frame)
	if frame.check then
		return
	end

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
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING, WoWTools_DataMixin.onlyChinese and '指定' or COMBAT_ALLY_START_MISSION)
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_CurrencyMixin.addName)
		GameTooltip:Show()
	end)
	frame.check:SetScript('OnLeave', function() GameTooltip_Hide() end)
	frame.check:SetSize(18,18)
	frame.check:Hide()

	frame:HookScript('OnEnter', function(self)
		if WoWTools_CurrencyMixin.TrackButton then
			for _, btn in pairs(WoWTools_CurrencyMixin.TrackButton.btn or {}) do
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

--已获取，百分比
	frame.percentText= WoWTools_LabelMixin:Create(frame, {color={r=1,g=1,b=1}})
	frame.percentText:SetPoint('RIGHT', frame.Content.Count, 'LEFT')

--战团总数量
	frame.accountWideText= WoWTools_LabelMixin:Create(frame, {color={r=0, g=0.8, b=1}})
	frame.accountWideText:SetPoint('RIGHT', frame.percentText, 'LEFT', -2, 0)


--替换，原生，都显示图标
	function frame:RefreshAccountCurrencyIcon()
		local show=true
		if self.elementData.isAccountWide then
			self.Content.AccountWideIcon.Icon:SetAtlas("warbands-icon", TextureKitConstants.UseAtlasSize)
			self.Content.AccountWideIcon.Icon:SetScale(0.9)

		elseif self.elementData.isAccountTransferable then
			self.Content.AccountWideIcon.Icon:SetAtlas("warbands-transferable-icon", TextureKitConstants.UseAtlasSize)
			self.Content.AccountWideIcon.Icon:SetScale(0.9)

		else
			self.Content.AccountWideIcon.Icon:SetAtlas(nil)
			show=false
		end
		self.Content.AccountWideIcon:SetShown(show)
	end
end
















local function set_Tokens_Button(self)--设置, 列表, 内容
	Create(self)

	local info, _, _, percent, isMax, canWeek, canEarned, canQuantity
	if not Save().notPlus then
		info, _, _, percent, isMax, canWeek, canEarned, canQuantity= WoWTools_CurrencyMixin:GetInfo(self.elementData.currencyID, self.elementData.currencyIndex)

	end

	if not info then
		self.check:SetShown(false)
		self.Content.Count:SetTextColor(1,1,1)
		local lable= self.Content.Name2 or self.Content.Name--汉化，新建
		lable:SetTextColor(1,1,1)
		self.percentText:SetText('')
		self.accountWideText:SetText('')
		return
	end


	self.check:SetCheckedTexture(info and info.iconFileID or 'orderhalltalents-done-glow')
	self.check.currencyID= info.currencyID
	self.check:SetChecked(Save().tokens[info.currencyID])
	self.check:SetAlpha(Save().tokens[info.currencyID] and 1 or 0.5)
	self.check:SetShown(true)



	local accountWide
	local label= self.Content.Name2 or self.Content.Name--汉化，新建
--可转移
	if info.isAccountTransferable then
		label:SetTextColor(0, 0.8, 1)
		accountWide= WoWTools_DataMixin:MK(WoWTools_CurrencyMixin:GetAccountInfo(info.currencyID, true), 3)

--战团共享
	elseif info.isAccountWide then
		label:SetTextColor(1, 0.49, 0.04)

--其它
	else
		local r, g, b= C_Item.GetItemQualityColor(info and info.quality or 1)
		label:SetTextColor(r or 1, g or 1, b or 1)
	end

--战团总数量，不包含自已
	self.accountWideText:SetText(accountWide or '')

	if isMax then
		self.Content.Count:SetTextColor(1,0,0)
	elseif canWeek or canEarned or canQuantity then
		self.Content.Count:SetTextColor(0,1,0)
	else
		self.Content.Count:SetTextColor(1,1,1)
	end

--已获取，百分比
	self.percentText:SetText(percent and format('%d%%', percent) or '')
end



















local function Init()
	hooksecurefunc(TokenFrame.ScrollBox, 'Update', function(f)
        if not f:GetView() then
            return
        end
        for _, frame in pairs(f:GetFrames() or {}) do
			if not frame.elementData.isHeader then
            	set_Tokens_Button(frame)--设置, 列表, 内容
			end
        end
    end)








--弹出框，增加，货币信息
	TokenFramePopup.Name= WoWTools_LabelMixin:Create(TokenFramePopup, {size=14, mouse=true, name='WoWToolsTokenFramePopupName'})
	TokenFramePopup.Name:SetPoint('TOPLEFT', TokenFramePopup, 'BOTTOMLEFT', 6, 6)
	TokenFramePopup.Name:SetScript('OnLeave', function(self)
		GameTooltip_Hide()
		self:SetAlpha(1)
	end)
	TokenFramePopup.Name:SetScript('OnEnter', function(self)
		WoWTools_SetTooltipMixin:Frame(self)
		self:SetAlpha(0.5)
	end)
	hooksecurefunc(TokenFrame, 'UpdatePopup', function(_, btn)
		TokenFramePopup.Name.currencyID= btn.elementData.currencyID
		TokenFramePopup.Name:SetText(not Save().notPlus and WoWTools_CurrencyMixin:GetName(btn.elementData.currencyID) or '')
	end)


	Init=function()end
end


function WoWTools_CurrencyMixin:Init_ScrollBox_Plus()
  	Init()
end