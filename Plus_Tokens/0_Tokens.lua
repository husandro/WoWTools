local id, e = ...
local addName

WoWTools_TokensMixin={
Save={
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
},

TrackButton=nil,
}
local function Save()
	return WoWTools_TokensMixin.Save
end
local Button












--######
--初始化
--######
local function Init()
	Button= WoWTools_ButtonMixin:Cbtn(TokenFrame, {icon='hide', size={22,22}})
	Button:SetPoint("RIGHT", TokenFrame.CurrencyTransferLogToggleButton, 'LEFT',-2,0)
	Button.texture= Button:CreateTexture()
	Button.texture:SetAllPoints()
	Button.texture:SetAlpha(0.5)

	Button.bagButton= WoWTools_ButtonMixin:Cbtn(ContainerFrameCombinedBags, {icon='hide', size={18,18, name='WoWToolsTokensTrackItemBagButton'}})--背包中, 增加一个图标, 用来添加或移除
	Button.bagButton:SetPoint('RIGHT', ContainerFrameCombinedBags.CloseButton, 'LEFT',-4,0)
    
	Button.bagButton:SetFrameStrata('HIGH')
	Button.bagButton.texture= Button.bagButton:CreateTexture()
	Button.bagButton.texture:SetAllPoints()
	Button.bagButton.texture:SetAlpha(0.5)

	function Button:set_bagButtonTexture(icon)--设置,按钮, 图标
		if icon then
			self.texture:SetTexture(icon)
			self.bagButton.texture:SetTexture(icon)
		elseif Save().Hide then
			self.texture:SetAtlas(e.Icon.icon)
			self.bagButton.texture:SetAtlas(e.Icon.icon)
		else
			self.texture:SetAtlas('FXAM-SmallSpikeyGlow')
			self.bagButton.texture:SetAtlas('FXAM-SmallSpikeyGlow')
		end
	end
	Button:set_bagButtonTexture()--设置,按钮, 图标

	local function click(self)
		local infoType, itemID, itemLink = GetCursorInfo()
        if infoType == "item" and itemID then
			Save().item[itemID]= not Save().item[itemID] and true or nil
			print(e.addName, addName, e.onlyChinese and '追踪' or TRACKING,
					Save().item[itemID] and
					('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', e.Icon.select))
					or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a'),
					itemLink or itemID)
			ClearCursor()
			WoWTools_TokensMixin:Set_TrackButton_Text()
		else
			WoWTools_TokensMixin:Init_Menu(self)
		end
	end

	local function enter(self)
		local infoType, itemID, itemLink = GetCursorInfo()
		e.tips:SetOwner(self, "ANCHOR_LEFT")
		e.tips:ClearLines()
		if infoType== "item"  and itemID then
			e.tips:SetItemByID(itemID)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(itemLink or ('itemID'..itemID),
					Save().item[itemID] and
						('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a')
					or ('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', e.Icon.select))
			)
			Button:set_bagButtonTexture(C_Item.GetItemIconByID(itemID))
		else
			e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.left)
			e.tips:AddDoubleLine((e.onlyChinese and '拖曳' or DRAG_MODEL)..e.Icon.left..(e.onlyChinese and '物品' or ITEMS), e.onlyChinese and '追踪' or TRACKING)
		end
		e.tips:AddLine(' ')

		e.tips:AddDoubleLine(e.addName, addName)
		e.tips:Show()
		self.texture:SetAlpha(1)
		WoWTools_TokensMixin:Set_TrackButton_Pushed(true)--提示
	end

	local function leave(self)
		e.tips:Hide()
		Button:set_bagButtonTexture()
		self.texture:SetAlpha(0.5)
		WoWTools_TokensMixin:Set_TrackButton_Pushed(false)--提示
	end


	Button:SetScript('OnMouseDown', click)
	Button:SetScript('OnEnter', enter)
	Button:SetScript('OnLeave', leave)

	Button.bagButton:SetScript('OnMouseDown', click)
	Button.bagButton:SetScript('OnEnter', enter)
	Button.bagButton:SetScript('OnLeave',leave)
	Button.bagButton:HookScript('OnEnter', function(self2) self2:SetAlpha(1) end)
	Button.bagButton:HookScript('OnLeave', function(self2) self2:SetAlpha(0.5) end)



	--展开,合起
	Button.down= WoWTools_ButtonMixin:Cbtn(Button, {size={22,22}, atlas='NPE_ArrowDown'})--texture='Interface\\Buttons\\UI-MinusButton-Up'})--展开所有
	Button.down:SetPoint('RIGHT', Button, 'LEFT', -2, 0)
	Button.down:SetScript("OnClick", function()
		for i=1, C_CurrencyInfo.GetCurrencyListSize() do--展开所有
			local info = C_CurrencyInfo.GetCurrencyListInfo(i)
			if info  and info.isHeader and not info.isHeaderExpanded then
				C_CurrencyInfo.ExpandCurrencyList(i,true)
			end
		end
		TokenFrame:Update()
	end)
	Button.down:SetScript("OnLeave", GameTooltip_Hide)
	Button.down:SetScript('OnEnter', function(self)
		e.tips:SetOwner(self, "ANCHOR_LEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(' ', e.onlyChinese and '展开选项|A:editmode-down-arrow:16:11:0:-7|a' or HUD_EDIT_MODE_EXPAND_OPTIONS)
		e.tips:AddDoubleLine(e.addName, addName)
		e.tips:Show()
	end)

	Button.up= WoWTools_ButtonMixin:Cbtn(Button, {size={22,22}, atlas='NPE_ArrowUp'})--texture='Interface\\Buttons\\UI-PlusButton-Up'})--收起所有
	Button.up:SetPoint('RIGHT', Button.down, 'LEFT', -2, 0)
	Button.up:SetScript("OnClick", function()
		for i=1, C_CurrencyInfo.GetCurrencyListSize() do--展开所有
			local info = C_CurrencyInfo.GetCurrencyListInfo(i)
			if info  and info.isHeader and info.isHeaderExpanded then
				C_CurrencyInfo.ExpandCurrencyList(i, false)
			end
		end
		TokenFrame:Update()
	end)
	Button.up:SetScript("OnLeave", GameTooltip_Hide)
	Button.up:SetScript('OnEnter', function(self)
		e.tips:SetOwner(self, "ANCHOR_LEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(' ',e.onlyChinese and '收起选项|A:editmode-up-arrow:16:11:0:3|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS)
		e.tips:AddDoubleLine(e.addName, addName)
		e.tips:Show()
	end)

	Button.bag=WoWTools_ButtonMixin:Cbtn(Button, {icon='hide', size={18,18}})
	Button.bag:SetPoint('RIGHT', Button.up, 'LEFT',-4,0)
	Button.bag:SetNormalAtlas('bag-main')
	Button.bag:SetScript("OnClick", function(self)
		for index=1, BackpackTokenFrame:GetMaxTokensWatched() do--Blizzard_TokenUI.lua
			local info = C_CurrencyInfo.GetBackpackCurrencyInfo(index)
			if info then
				print(C_CurrencyInfo.GetCurrencyLink(info.currencyTypesID) or info.name)
			end
		end
		ToggleAllBags()
		TokenFrame:Update()
	end)
	Button.bag:SetScript('OnEnter', function(self2)
		e.tips:SetOwner(self2, "ANCHOR_LEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(e.onlyChinese and '在行囊上显示' or SHOW_ON_BACKPACK, GetNumWatchedTokens())
		for index=1, BackpackTokenFrame:GetMaxTokensWatched() do--Blizzard_TokenUI.lua
			local info = C_CurrencyInfo.GetBackpackCurrencyInfo(index)
			if info and info.name and info.iconFileID then
				e.tips:AddDoubleLine(info.name, '|T'..info.iconFileID..':0|t')
			end
		end
		e.tips:Show()
	end)
	Button.bag:SetScript('OnLeave', GameTooltip_Hide)

	Button.currencyMax={}
	function Button:currency_Max(curID)--已达到资源上限
		local tab={}
		if curID then
			if self.currencyMax[curID] then
				return
			end
			local info, num, total, percent, isMax, canWeek, canEarned, canQuantity= WoWTools_CurrencyMixin:GetInfo(curID, nil)
			if info and isMax then
				tab[info.currencyID]= info.link
			end
		else
			for currencyID, _ in pairs(Save().tokens) do
				if not self.currencyMax[currencyID] then
					local info, _, total, percent, isMax, canWeek, canEarned, canQuantity= WoWTools_CurrencyMixin:GetInfo(currencyID, nil)
					if info and isMax then
						tab[currencyID]= info.link
					end
				end
			end
			for i=1, C_CurrencyInfo.GetCurrencyListSize() do
				local info, num, total, percent, isMax, canWeek, canEarned, canQuantity= WoWTools_CurrencyMixin:GetInfo(nil, i)
				if info
					and not self.currencyMax[info.currencyID]
					and isMax
				then
					tab[info.currencyID]= info.link
				end
			end
		end
		local text
		for currencyID, link in pairs(tab) do
			text= (text or '')..link
			self.currencyMax[currencyID]=true
		end
		if text then
			print(e.addName, addName, text, '|r|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已达到资源上限' or SPELL_FAILED_CUSTOM_ERROR_248))
		end
	end

	function Button:set_Event()
		if Save().hideCurrencyMax then
			self:UnregisterAllEvents()
		else
			self:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
		end
	end
	Button:SetScript('OnEvent', function(self, _, arg1)
		if arg1 then
			self:currency_Max(nil, arg1)
		end
	end)







	WoWTools_TokensMixin:Init_Currency_Transfer()--货币，转移
	C_Timer.After(4, function()
		WoWTools_TokensMixin:Init_TrackButton()
		WoWTools_TokensMixin:Init_ScrollBox_Plus()
		hooksecurefunc(TokenFrame, 'Update', function(self)
			WoWTools_TokensMixin:Set_ItemInteractionFrame(self)--套装,转换,货币
			WoWTools_TokensMixin:Init_TrackButton()
		end)
		if not Save().hideCurrencyMax then
			Button:currency_Max()--已达到资源上限
			Button:set_Event()--已达到资源上限
		end
	end)
end


















--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
		if arg1==id then
			WoWTools_TokensMixin.Save= WoWToolsSave['Currency2'] or WoWTools_TokensMixin.Save

			for itemID, _ in pairs(Save().item) do
				e.LoadData({id=itemID, type='item'})--加载 item quest spell
			end

			addName = '|A:bags-junkcoin:0:0|a'..(e.onlyChinese and '货币' or TOKENS)

			--添加控制面板
			e.AddPanel_Check({
				name= addName,
				GetValue= function() return not Save().disabled end,
				SetValue= function()
					Save().disabled= not Save().disabled and true or nil
					print(e.addName, addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
				end
			})

            if Save().disabled then
				self:UnregisterEvent('ADDON_LOADED')
			else
				Init()
            end


		elseif arg1=='Blizzard_ItemInteractionUI' then
            hooksecurefunc(ItemInteractionFrame, 'SetupChargeCurrency', function(frame)
				WoWTools_TokensMixin:Set_ItemInteractionFrame(frame)
			end)
		end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Currency2']= WoWTools_TokensMixin.Save
        end
	end
end)