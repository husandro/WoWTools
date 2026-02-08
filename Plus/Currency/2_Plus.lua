
local function Save()
    return WoWToolsSave['Currency2']
end













local function Create(frame)
	
	frame.check= CreateFrame('CheckButton', nil, frame, "MinimalCheckboxArtTemplate")
	--frame.check:SetCheckedTexture('AlliedRace-UnlockingFrame-Checkmark')
	frame.check:SetSize(23,23)
	function frame.check:GetCurrencyID()
		local data= self:GetParent().elementData
		if data then
			return data.currencyID
		end
	end

	frame.check:SetPoint('RIGHT', frame.Content.AccountWideIcon, 'LEFT', -2, 0)
	frame.check:SetAlpha(0.5)
	frame.check:SetScript('OnLeave', function(self)
		GameTooltip_Hide()
		self:SetAlpha(0.5)
	end)
	frame.check:SetScript('OnEnter', function(self)
		self:SetAlpha(1)
		local currencyID= self:GetCurrencyID()
		if not currencyID then
			return
		end
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:SetCurrencyByID(currencyID)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(
			WoWTools_DataMixin.Icon.icon2
			..(WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING)
			..': '..(Save().indicato and '|cnGREEN_FONT_COLOR:' or '|cff626262')
			..(WoWTools_DataMixin.onlyChinese and '指定' or COMBAT_ALLY_START_MISSION)
		)
		GameTooltip:Show()
	end)
	frame.check:SetScript('OnClick', function(self)
		local id= self:GetCurrencyID()
		if id then
			Save().tokens[id]= not Save().tokens[id] and true or nil
			WoWTools_CurrencyMixin:Init_TrackButton()
		end
	end)
	WoWTools_TextureMixin:SetCheckBox(frame.check)

--已获取，百分比
	frame.percentText= frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')-- WoWTools_LabelMixin:Create(frame, {color={r=1,g=1,b=1}})
	frame.percentText:SetTextColor(ACCOUNT_WIDE_FONT_COLOR:GetRGB())
	frame.percentText:SetPoint('RIGHT', frame.Content.Count, 'LEFT')

--战团总数量
	frame.accountWideText= frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')-- WoWTools_LabelMixin:Create(frame, {color={r=0, g=0.8, b=1}})
	frame.accountWideText:SetPoint('RIGHT', frame.percentText, 'LEFT', -2, 0)


--替换，原生，都显示图标
	frame.Content.AccountWideIcon:SetAlpha(0.7)
	frame.Content.AccountWideIcon:SetScale(0.7)
	frame.Content.AccountWideIcon:SetScript('OnLeave', function(self)
		GameTooltip_Hide()
		self:SetAlpha(0.7)
	end)
	frame.Content.AccountWideIcon:HookScript('OnEnter', function(self)
		self:SetAlpha(1)
	end)
	
	function frame:RefreshAccountCurrencyIcon()
		local atlas
		if self.elementData.isAccountWide then
			atlas= "warbands-icon"
		elseif self.elementData.isAccountTransferable then
			atlas= 'warbands-transferable-icon'
		end
		if atlas then
			self.Content.AccountWideIcon.Icon:SetAtlas(atlas, TextureKitConstants.UseAtlasSize)
		end
		self.Content.AccountWideIcon:SetShown(atlas)
	end
end
















local function set_Tokens_Button(self)--设置, 列表, 内容
	if not self.check then
		Create(self)
	end

	local info, _, _, percent, isMax, canWeek, canEarned, canQuantity= WoWTools_CurrencyMixin:GetInfo(self.elementData.currencyID, self.elementData.currencyIndex)

	if not info then
		--self.check:SetShown(false)
		self.Content.Count:SetTextColor(1,1,1)
		local lable= self.Content.Name2 or self.Content.Name--汉化，新建
		lable:SetTextColor(1,1,1)
		self.percentText:SetText('')
		self.accountWideText:SetText('')
		return
	end

	info= self.elementData or info

	self.check:SetChecked(Save().tokens[info.currencyID])
	--self.check:SetShown(info.currencyID and not Save().Hide and Save().indicato)


	local accountWide
	local label= self.Content.Name2 or self.Content.Name--汉化，新建
--可转移
	if info.isAccountTransferable then
		label:SetTextColor(0, 0.8, 1)
		accountWide= WoWTools_DataMixin:MK(WoWTools_CurrencyMixin:GetAccountInfo(info.currencyID, true), 3)
		accountWide= ACCOUNT_WIDE_FONT_COLOR:WrapTextInColorCode(accountWide..'|A:warbands-transferable-icon:0:0|a')
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







































local function Init_Search(self)
	local numList= self:IsVisible() and C_CurrencyInfo.GetCurrencyListSize() or 0
	if numList<=0 then
		return
	end

	local currencyID, name, currencyIndex
	local findTab={}

	currencyID =math.max(self:GetNumber() or 0)
	currencyID= currencyID>0 and currencyID or nil

	name= self:GetText() or ''
	name= name:gsub(' ', '')~='' and name or nil

	if name or currencyID then
		for index= numList, 1, -1 do
			local data= C_CurrencyInfo.GetCurrencyListInfo(index)
			if data and not data.isHeader and data.currencyID and data.name then
	--查找 ID
				if currencyID and data.currencyID==currencyID then
					findTab[data.currencyID]=true
					currencyIndex= index
					break
	--查找 名称
				elseif name then
					local cn= WoWTools_TextMixin:CN(data.name)
					cn= cn~=data.name and cn or nil
					if cn and cn==name or data.name== name then
						findTab[data.currencyID]=true
						currencyIndex= index
						break

					elseif cn and cn:find(name) or data.name:find(name) then
						findTab[data.currencyID]=true
						currencyIndex= index
					end
				end
			end
		end
	end

	if currencyIndex then
		TokenFrame.ScrollBox:ScrollToElementDataIndex(currencyIndex)
	end

	for _, btn in pairs(TokenFrame.ScrollBox:GetFrames()) do
		if btn.Content and btn.elementData then
			if findTab[btn.elementData.currencyID] then
				btn.Content.BackgroundHighlight:SetAlpha(0.3)
			else
				btn.Content.BackgroundHighlight:SetAlpha(0)
			end
		end
	end

	findTab=nil
end









local function Expand_All()
	local num= C_CurrencyInfo.GetCurrencyListSize() or 0
	if num<=0 then
		return
	end


	for i=num, 1, -1 do--展开所有
		local info = C_CurrencyInfo.GetCurrencyListInfo(i)
		if info and info.isHeader and not info.isHeaderExpanded then
			C_CurrencyInfo.ExpandCurrencyList(i, true)
		end
	end

	for _, frame in pairs(TokenFrame.ScrollBox:GetFrames() or {}) do
		if frame.elementData.isHeader and frame:IsCollapsed() then
			frame:ToggleCollapsed()
		end
	end

	WoWTools_CurrencyMixin:UpdateTokenFrame()
end













local function Init_PlusButton()
	if  Save().notPlus then
		return
	end

--展开,合起	
	local down= CreateFrame('Button', 'WoWToolsCurrencyExpandeListButton', TokenFrame.filterDropdown, 'WoWToolsButtonTemplate') 
	down:SetNormalAtlas('NPE_ArrowDown')
	--[[WoWTools_ButtonMixin:Cbtn(_G['WoWToolsPlusCurrencyMenuButton'], {
		size=22,
		atlas='NPE_ArrowDown',
		name='WoWToolsCurrencyExpandeListButton',
	})]]
	down:SetPoint('RIGHT', TokenFrame.filterDropdown, 'LEFT', -2, 0)

	down:SetScript("OnClick", function()
		Expand_All()
	end)
	down:SetScript("OnLeave", GameTooltip_Hide)
	down:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(' ', WoWTools_DataMixin.onlyChinese and '展开选项|A:editmode-down-arrow:16:11:0:-7|a' or HUD_EDIT_MODE_EXPAND_OPTIONS)
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_CurrencyMixin.addName)
		GameTooltip:Show()
	end)


--展开所有
	local up=  CreateFrame('Button', nil, down, 'WoWToolsButtonTemplate') -- WoWTools_ButtonMixin:Cbtn(down, {size=22, atlas='NPE_ArrowUp'})--texture='Interface\\Buttons\\UI-PlusButton-Up'})--收起所有
	up:SetNormalAtlas('NPE_ArrowUp')
	up:SetPoint('RIGHT', down, 'LEFT', -2, 0)
	up:SetScript("OnClick", function()
		for i=1, C_CurrencyInfo.GetCurrencyListSize() do
			local info = C_CurrencyInfo.GetCurrencyListInfo(i)
			if info and info.isHeader then
				do
					C_CurrencyInfo.ExpandCurrencyList(i, false)
				end
			end
		end
		WoWTools_CurrencyMixin:UpdateTokenFrame()
	end)
	up:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	up:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(' ',WoWTools_DataMixin.onlyChinese and '收起选项|A:editmode-up-arrow:16:11:0:3|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS)
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_CurrencyMixin.addName)
		GameTooltip:Show()
	end)


	local edit= WoWTools_EditBoxMixin:Create(up, {
		name='WoWTools_PlusTokensSearchBox',
		Template='SearchBoxTemplate'
	})
	edit:SetPoint('RIGHT', up, 'LEFT', -6, 0)
	edit:SetPoint('BOTTOMLEFT', CharacterFramePortrait, 'BOTTOMRIGHT')

	edit:HookScript('OnTextChanged', function(self)
		Init_Search(self)
	end)
	edit:SetScript('OnEnterPressed', function(self)
		Init_Search(self)
	end)
	edit:HookScript('OnEditFocusGained', function(self)
		Expand_All()
		if self:GetText()~='' then
			Init_Search(self)
		end
	end)

	Init_PlusButton=function()
		_G['WoWToolsCurrencyExpandeListButton']:SetShown(not Save().notPlus)
	end
end








--[[
    if WoWTools_DataMixin.Player.husandro then
        for slot= 1, 19 do
            local item= ItemLocation:CreateFromEquipmentSlot(slot)
            if item:IsValid() then
                local data= C_ItemInteraction.GetItemConversionCurrencyCost(item)
                if data then
                    info=data
                    for k, v in pairs(info or {}) do if v and type(v)=='table' then print('|cff00ff00---',k, '---STAR|r') for k2,v2 in pairs(v) do print('|cffffff00',k2,v2, '|r') end print('|cffff0000---',k, '---END|r') else print(k,v) end end print('|cffff00ff——————————|r')
                end
            end
        end
    end]]

	

function WoWTools_CurrencyMixin:Init_Plus()
  	Init()
	Init_PlusButton()
end