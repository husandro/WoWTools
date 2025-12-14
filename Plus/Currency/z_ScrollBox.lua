
local function Save()
    return WoWToolsSave['Currency2']
end













local function Create(frame)
	frame.Content.AccountWideIcon:SetScript('OnLeave', nil)
	frame.Content.AccountWideIcon.Icon:SetAlpha(0.5)

	frame.check= CreateFrame('CheckButton', nil, frame, "MinimalCheckboxArtTemplate")
	frame.check:SetCheckedTexture('AlliedRace-UnlockingFrame-Checkmark')
	frame.check:SetSize(18,18)
	function frame.check:GetCurrencyID()
		local currencyIndex= self:GetParent().currencyIndex
		if currencyIndex then
			local data= C_CurrencyInfo.GetCurrencyListInfo(currencyIndex)
			if data then
				return data.currencyID
			end
		end
	end

	frame.check:SetPoint('LEFT', frame.Content.WatchedCurrencyCheck, 'RIGHT', -2, 0)
	frame.check:SetAlpha(0.5)
	frame.check:SetScript('OnClick', function(self)
		local id= self:GetCurrencyID()
		if id then
			Save().tokens[id]= not Save().tokens[id] and true or nil
			WoWTools_CurrencyMixin:Set_TrackButton_Text()
		end
	end)
	frame.check:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 12, -12)
		GameTooltip:ClearLines()
		local currencyIndex= self:GetParent().currencyIndex
		if currencyIndex then
			GameTooltip:SetCurrencyToken(currencyIndex)
			GameTooltip:AddLine(" ")
		end
		GameTooltip:AddLine(
			WoWTools_DataMixin.Icon.icon2
			..(WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING)
			..': '..(Save().indicato and '|cnGREEN_FONT_COLOR:' or '|cff626262')
			..(WoWTools_DataMixin.onlyChinese and '指定' or COMBAT_ALLY_START_MISSION)
		)

		GameTooltip:Show()
	end)
	frame.check:SetScript('OnLeave', function() GameTooltip_Hide() end)
	frame.check:SetSize(18,18)
	WoWTools_TextureMixin:SetCheckBox(frame.check)

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
	if not self.check then
		Create(self)
	end

	local info, _, _, percent, isMax, canWeek, canEarned, canQuantity= WoWTools_CurrencyMixin:GetInfo(self.elementData.currencyID, self.elementData.currencyIndex)
	
	if not info then
		self.check:SetShown(false)
		self.Content.Count:SetTextColor(1,1,1)
		local lable= self.Content.Name2 or self.Content.Name--汉化，新建
		lable:SetTextColor(1,1,1)
		self.percentText:SetText('')
		self.accountWideText:SetText('')
		return
	end

	info= self.elementData or info

	self.check:SetChecked(Save().tokens[info.currencyID])
	self.check:SetShown(info.currencyID and not Save().Hide and Save().indicato)


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
		local r, g, b= WoWTools_ItemMixin:GetColor(info and info.quality)
		label:SetTextColor(r, g, b)
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
	if Save().notPlus then
		return
	end

	WoWTools_DataMixin:Hook(TokenEntryMixin, 'OnLoad', function(frame)
		Create(frame)--设置, 列表, 内容
	end)

	WoWTools_DataMixin:Hook(TokenEntryMixin, 'Initialize', function(frame)
		set_Tokens_Button(frame)--设置, 列表, 内容
	end)


	if TokenFrame.ScrollBox:HasView() then
		for _, frame in pairs(TokenFrame.ScrollBox:GetFrames() or {}) do
			if frame.elementData and not frame.elementData.isHeader  then
            	set_Tokens_Button(frame)--设置, 列表, 内容
			end
        end
	end


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
	WoWTools_DataMixin:Hook(TokenFrame, 'UpdatePopup', function(_, btn)
		TokenFramePopup.Name.currencyID= btn.elementData.currencyID
		TokenFramePopup.Name:SetText(WoWTools_CurrencyMixin:GetName(btn.elementData.currencyID) or '')
	end)


	Init=function()end
end


function WoWTools_CurrencyMixin:Init_Plus()
  	Init()
end