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
		Button:set_texture(C_Item.GetItemIconByID(itemID))
	else
		e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.left)
		e.tips:AddDoubleLine((e.onlyChinese and '拖曳' or DRAG_MODEL)..e.Icon.left..(e.onlyChinese and '物品' or ITEMS), e.onlyChinese and '追踪' or TRACKING)
	end
	e.tips:AddLine(' ')

	e.tips:AddDoubleLine(e.addName, WoWTools_TokensMixin.addName)
	e.tips:Show()
	WoWTools_TokensMixin:Set_TrackButton_Pushed(true)--提示
end

local function leave()
	e.tips:Hide()
	Button:set_texture()
	WoWTools_TokensMixin:Set_TrackButton_Pushed(false)--提示
end















local function Init()
    Button= WoWTools_ButtonMixin:Cbtn(TokenFrame, {name='WoWTools_PlusCurrencyButton', icon='hide', size=23})
	WoWTools_TokensMixin.Button= Button
	
	Button:SetPoint('RIGHT', CharacterFrameCloseButton, 'LEFT', -2, 0)
	Button:SetFrameStrata(CharacterFrameCloseButton:GetFrameStrata())
	Button:SetFrameLevel(CharacterFrameCloseButton:GetFrameLevel()+1)
	Button.texture= Button:CreateTexture()
	Button.texture:SetAllPoints()
	--Button:SetPushedAtlas('ui-questtrackerbutton-filter-pressed')
	--Button:SetHighlightAtlas('ui-questtrackerbutton-red-highlight')





	function Button:set_texture(icon)--设置,按钮, 图标
		if icon then
			self.texture:SetTexture(icon)
			self.bagButton.texture:SetTexture(icon)
		elseif Save().Hide then
			self.texture:SetAtlas(e.Icon.icon)
			self.texture:SetAlpha(0.5)
			self.bagButton.texture:SetAtlas(e.Icon.icon)
		else
			self.texture:SetAlpha(1)
			self.texture:SetAtlas('ui-questtrackerbutton-filter')
			self.bagButton.texture:SetAtlas('FXAM-SmallSpikeyGlow')
		end
	end


	Button:SetScript('OnMouseDown', click)
	Button:SetScript('OnEnter', enter)
	Button:SetScript('OnLeave', leave)

	Button.bagButton= WoWTools_ButtonMixin:Cbtn(ContainerFrameCombinedBags, {icon='hide', size={18,18, name='WoWToolsTokensTrackItemBagButton'}})--背包中, 增加一个图标, 用来添加或移除
	Button.bagButton:SetPoint('RIGHT', ContainerFrameCombinedBags.CloseButton, 'LEFT',-2,0)
	Button.bagButton:SetFrameStrata(ContainerFrameCombinedBags.CloseButton:GetFrameStrata())
	Button.bagButton:SetFrameLevel(ContainerFrameCombinedBags.CloseButton:GetFrameLevel()+1)
	Button.bagButton.texture= Button.bagButton:CreateTexture()
	Button.bagButton.texture:SetAllPoints()
	Button.bagButton.texture:SetAlpha(0.5)
	Button.bagButton:SetScript('OnMouseDown', click)
	Button.bagButton:SetScript('OnEnter', enter)
	Button.bagButton:SetScript('OnLeave',leave)

	Button:set_texture()--设置,按钮, 图标


	

	--[[Button.bag=WoWTools_ButtonMixin:Cbtn(Button, {icon='hide', size={18,18}})
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
		WoWTools_TokensMixin:UpdateTokenFrame()
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
	Button.bag:SetScript('OnLeave', GameTooltip_Hide)]]

	function Button:settings()
		if self.down then
			self.down:SetShown(not Save().notPlus)
		end
		
	end
end










function WoWTools_TokensMixin:Init_Button()
    Init()
end