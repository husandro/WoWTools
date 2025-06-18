
local function Save()
	return WoWToolsSave['Currency2']
end
local Button








local function click(self)
	local infoType, itemID, itemLink = GetCursorInfo()
	if infoType == "item" and itemID then
		Save().item[itemID]= not Save().item[itemID] and true or nil
		print(WoWTools_DataMixin.Icon.icon2..WoWTools_CurrencyMixin.addName, WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING,
				Save().item[itemID] and
				('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', 'common-icon-checkmark'))
				or ('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a'),
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
					('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a')
				or ('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', 'common-icon-checkmark'))
		)
		Button:set_texture(C_Item.GetItemIconByID(itemID))
	else
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.left)
		GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '拖曳' or DRAG_MODEL)..WoWTools_DataMixin.Icon.left..(WoWTools_DataMixin.onlyChinese and '物品' or ITEMS), WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING)
	end
	GameTooltip:AddLine(' ')

	GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_CurrencyMixin.addName)
	GameTooltip:Show()
	WoWTools_CurrencyMixin:Set_TrackButton_Pushed(true)--提示
end

local function leave()
	GameTooltip:Hide()
	Button:set_texture()
	WoWTools_CurrencyMixin:Set_TrackButton_Pushed(false)--提示
end















local function Init()
    Button= WoWTools_ButtonMixin:Cbtn(TokenFrame, {name='WoWToolsPlusCurrencyMenuButton', size=23})
	--WoWTools_CurrencyMixin.Button= Button

	Button:SetPoint('RIGHT', CharacterFrameCloseButton, 'LEFT', -2, 0)
	Button:SetFrameStrata(CharacterFrameCloseButton:GetFrameStrata())
	Button:SetFrameLevel(CharacterFrameCloseButton:GetFrameLevel()+1)

	Button.texture= Button:CreateTexture()
	Button.texture:SetAllPoints()

	WoWTools_TextureMixin:SetButton(Button, {all=true})

	function Button:set_texture(icon)--设置,按钮, 图标
		if icon then
			self.texture:SetTexture(icon)
			self.bagButton.texture:SetTexture(icon)
		elseif Save().Hide then
			self.texture:SetTexture('Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools')
			--self.texture:SetAlpha(0.5)
			self.bagButton.texture:SetTexture('Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools')
		else
			--self.texture:SetAlpha(1)
			self.texture:SetAtlas('ui-questtrackerbutton-filter')
			self.bagButton.texture:SetAtlas('FXAM-SmallSpikeyGlow')
		end
	end

	Button:SetScript('OnMouseDown', function(b)
		click(b)
	end)
	Button:SetScript('OnEnter', function(b)
		enter(b)
	end)
	Button:SetScript('OnLeave', function(b)
		leave(b)
	end)

	Button.bagButton= WoWTools_ButtonMixin:Cbtn(ContainerFrameCombinedBags, {size=18, name='WoWToolsTokensTrackItemBagButton'})--背包中, 增加一个图标, 用来添加或移除
	Button.bagButton:SetPoint('RIGHT', ContainerFrameCombinedBags.CloseButton, 'LEFT',-2,0)
	Button.bagButton:SetFrameStrata(ContainerFrameCombinedBags.CloseButton:GetFrameStrata())
	Button.bagButton:SetFrameLevel(ContainerFrameCombinedBags.CloseButton:GetFrameLevel()+1)
	WoWTools_TextureMixin:SetButton(Button.bagButton, {all=true})

	Button.bagButton.texture= Button.bagButton:CreateTexture()
	Button.bagButton.texture:SetAllPoints()
	
	Button.bagButton.texture:SetAlpha(0.3)

	Button.bagButton:SetScript('OnMouseDown', function(...)
		click()
	end)
	Button.bagButton:SetScript('OnEnter', function(...)
		enter(...)
	end)
	Button.bagButton:SetScript('OnLeave', function(...)
		leave(...)
	end)

	Button:set_texture()--设置,按钮, 图标

	function Button:settings()
		if _G['WoWToolsCurrencyExpandeListButton'] then
			_G['WoWToolsCurrencyExpandeListButton']:SetShown(not Save().notPlus)
		end
	end
end










function WoWTools_CurrencyMixin:Init_Button()
    Init()
end