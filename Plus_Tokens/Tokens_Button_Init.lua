local e=select(2, ...)
local function Save()
	return WoWTools_TokensMixin.Save
end
local Button








local function click(self)
	local infoType, itemID, itemLink = GetCursorInfo()
	if infoType == "item" and itemID then
		Save().item[itemID]= not Save().item[itemID] and true or nil
		print(e.addName, WoWTools_TokensMixin.addName, e.onlyChinese and '追踪' or TRACKING,
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

	e.tips:AddDoubleLine(e.addName, WoWTools_TokensMixin.addName)
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















local function Init()
    Button= WoWTools_ButtonMixin:Cbtn(TokenFrame, {name='WoWTools_PlusCurrencyButton', icon='hide', size={22,22}})
	WoWTools_TokensMixin.Button= Button
	
	Button:SetPoint('RIGHT', CharacterFrameCloseButton, 'LEFT', -2, 0)
	Button:SetFrameStrata(CharacterFrameCloseButton:GetFrameStrata())
	Button.texture= Button:CreateTexture()
	Button.texture:SetAllPoints()
	Button.texture:SetAlpha(0.5)


	Button.bagButton= WoWTools_ButtonMixin:Cbtn(ContainerFrameCombinedBags, {icon='hide', size={18,18, name='WoWToolsTokensTrackItemBagButton'}})--背包中, 增加一个图标, 用来添加或移除
	Button.bagButton:SetPoint('RIGHT', ContainerFrameCombinedBags.CloseButton, 'LEFT',-4,0)
	Button.bagButton:SetFrameStrata(ContainerFrameCombinedBags.CloseButton:GetFrameStrata())
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

	


	Button:SetScript('OnMouseDown', click)
	Button:SetScript('OnEnter', enter)
	Button:SetScript('OnLeave', leave)

	Button.bagButton:SetScript('OnMouseDown', click)
	Button.bagButton:SetScript('OnEnter', enter)
	Button.bagButton:SetScript('OnLeave',leave)




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
		e.call(TokenFrame.Update, TokenFrame)
	end)
	Button.down:SetScript("OnLeave", GameTooltip_Hide)
	Button.down:SetScript('OnEnter', function(self)
		e.tips:SetOwner(self, "ANCHOR_LEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(' ', e.onlyChinese and '展开选项|A:editmode-down-arrow:16:11:0:-7|a' or HUD_EDIT_MODE_EXPAND_OPTIONS)
		e.tips:AddDoubleLine(e.addName, WoWTools_TokensMixin.addName)
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
		e.call(TokenFrame.Update, TokenFrame)
	end)
	Button.up:SetScript("OnLeave", GameTooltip_Hide)
	Button.up:SetScript('OnEnter', function(self)
		e.tips:SetOwner(self, "ANCHOR_LEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(' ',e.onlyChinese and '收起选项|A:editmode-up-arrow:16:11:0:3|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS)
		e.tips:AddDoubleLine(e.addName, WoWTools_TokensMixin.addName)
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
		e.call(TokenFrame.Update, TokenFrame)
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
		local tab, num= {}, 0
        local isMax, isMaxWeek
		if curID then
			if self.currencyMax[curID] then
				return
			end
            isMax, isMaxWeek= WoWTools_CurrencyMixin:IsMax(curID)
			if isMax or isMaxWeek then
                tab[curID]={isMax=isMax, isMaxWeek=isMaxWeek}
				num=1
            end
		else
			for currencyID, _ in pairs(Save().tokens) do
				if not self.currencyMax[currencyID] then
                    isMax, isMaxWeek= WoWTools_CurrencyMixin:IsMax(curID)
                    if isMax or isMaxWeek then
                        tab[curID]={isMax=isMax, isMaxWeek=isMaxWeek}
						num=num+1
                    end
				end
			end
			for i=1, C_CurrencyInfo.GetCurrencyListSize() do
                isMax, isMaxWeek, curID= WoWTools_CurrencyMixin:IsMax(nil, i)
                if isMax or isMaxWeek then
                    tab[curID]={isMax=isMax, isMaxWeek=isMaxWeek}
					num=num+1
                end
			end
		end
        if num>0 then
            print(e.addName, WoWTools_TokensMixin.addName)
            for currencyID, info in pairs(tab) do
                print(
					(WoWTools_CurrencyMixin:GetLink(currencyID) or currencyID)
					..(info.isMaxWeek and (e.onlyChinese and '本周' or GUILD_CHALLENGES_THIS_WEEK) or '')
				)
                self.currencyMax[currencyID]=true
            end
            print(
                '|cnGREEN_FONT_COLOR:'
                ..(e.onlyChinese and '已达到资源上限' or SPELL_FAILED_CUSTOM_ERROR_248)
                ..'|r'
                ..(num>1 and num or '')
            )
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




    if not Save().hideCurrencyMax then
        C_Timer.After(4, function()
            Button:currency_Max()--已达到资源上限
            Button:set_Event()--已达到资源上限
        end)
    end
end










function WoWTools_TokensMixin:Init_Button()
    Init()
end