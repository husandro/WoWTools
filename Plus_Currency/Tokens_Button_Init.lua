
local function Save()
	return WoWToolsSave['Currency2']
end
local Button








local function click(self)
	local infoType, itemID, itemLink = GetCursorInfo()
	if infoType == "item" and itemID then
		Save().item[itemID]= not Save().item[itemID] and true or nil
		print(WoWTools_DataMixin.Icon.icon2..WoWTools_CurrencyMixin.addName, WoWTools_Mixin.onlyChinese and '追踪' or TRACKING,
				Save().item[itemID] and
				('|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', 'common-icon-checkmark'))
				or ('|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a'),
				itemLink or itemID)
		ClearCursor()
		WoWTools_CurrencyMixin:Set_TrackButton_Text()
	else
		WoWTools_CurrencyMixin:Init_Menu(self)
	end
end

local function enter(self)
	local infoType, itemID, itemLink = GetCursorInfo()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:ClearLines()
	if infoType== "item"  and itemID then
		GameTooltip:SetItemByID(itemID)
		GameTooltip:AddLine(' ')
		GameTooltip:AddDoubleLine(itemLink or ('itemID'..itemID),
				Save().item[itemID] and
					('|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a')
				or ('|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', 'common-icon-checkmark'))
		)
		Button:set_texture(C_Item.GetItemIconByID(itemID))
	else
		GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.left)
		GameTooltip:AddDoubleLine((WoWTools_Mixin.onlyChinese and '拖曳' or DRAG_MODEL)..WoWTools_DataMixin.Icon.left..(WoWTools_Mixin.onlyChinese and '物品' or ITEMS), WoWTools_Mixin.onlyChinese and '追踪' or TRACKING)
	end
	GameTooltip:AddLine(' ')

	GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_CurrencyMixin.addName)
	GameTooltip:Show()
	WoWTools_CurrencyMixin:Set_TrackButton_Pushed(true)--提示
end

local function leave()
	GameTooltip:Hide()
	Button:set_texture()
	WoWTools_CurrencyMixin:Set_TrackButton_Pushed(false)--提示
end















local function Init()
    Button= WoWTools_ButtonMixin:Cbtn(TokenFrame, {name='WoWTools_PlusCurrencyButton', size=23})
	WoWTools_CurrencyMixin.Button= Button

	Button:SetPoint('RIGHT', CharacterFrameCloseButton, 'LEFT', -2, 0)
	Button:SetFrameStrata(CharacterFrameCloseButton:GetFrameStrata())
	Button:SetFrameLevel(CharacterFrameCloseButton:GetFrameLevel()+1)
	Button.texture= Button:CreateTexture()
	Button.texture:SetAllPoints()
	WoWTools_ColorMixin:Setup(Button.texture, {type='Texture'})--设置颜色





	function Button:set_texture(icon)--设置,按钮, 图标
		if icon then
			self.texture:SetTexture(icon)
			self.bagButton.texture:SetTexture(icon)
		elseif Save().Hide then
			self.texture:SetAtlas(WoWTools_DataMixin.Icon.icon)
			self.texture:SetAlpha(0.5)
			self.bagButton.texture:SetAtlas(WoWTools_DataMixin.Icon.icon)
		else
			self.texture:SetAlpha(1)
			self.texture:SetAtlas('ui-questtrackerbutton-filter')
			self.bagButton.texture:SetAtlas('FXAM-SmallSpikeyGlow')
		end
	end


	Button:SetScript('OnMouseDown', click)
	Button:SetScript('OnEnter', enter)
	Button:SetScript('OnLeave', leave)

	Button.bagButton= WoWTools_ButtonMixin:Cbtn(ContainerFrameCombinedBags, {size=18, name='WoWToolsTokensTrackItemBagButton'})--背包中, 增加一个图标, 用来添加或移除
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




	--[[Button.bag=WoWTools_ButtonMixin:Cbtn(Button, {size={18,18}})
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
		WoWTools_CurrencyMixin:UpdateTokenFrame()
	end)
	Button.bag:SetScript('OnEnter', function(self2)
		GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '在行囊上显示' or SHOW_ON_BACKPACK, GetNumWatchedTokens())
		for index=1, BackpackTokenFrame:GetMaxTokensWatched() do--Blizzard_TokenUI.lua
			local info = C_CurrencyInfo.GetBackpackCurrencyInfo(index)
			if info and info.name and info.iconFileID then
				GameTooltip:AddDoubleLine(info.name, '|T'..info.iconFileID..':0|t')
			end
		end
		GameTooltip:Show()
	end)
	Button.bag:SetScript('OnLeave', GameTooltip_Hide)]]

	function Button:settings()
		if self.down then
			self.down:SetShown(not Save().notPlus)
		end

	end
end










function WoWTools_CurrencyMixin:Init_Button()
    Init()
end