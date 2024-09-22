local e= select(2, ...)
local addName
local function Save()
    return WoWTools_TokensMixin.Save
end











local qualityToIconBorderAtlas ={
	[Enum.ItemQuality.Poor] = "auctionhouse-itemicon-border-gray",
	[Enum.ItemQuality.Common] = "auctionhouse-itemicon-border-white",
	[Enum.ItemQuality.Uncommon] = "auctionhouse-itemicon-border-green",
	[Enum.ItemQuality.Rare] = "auctionhouse-itemicon-border-blue",
	[Enum.ItemQuality.Epic] = "auctionhouse-itemicon-border-purple",
	[Enum.ItemQuality.Legendary] = "auctionhouse-itemicon-border-orange",
	[Enum.ItemQuality.Artifact] = "auctionhouse-itemicon-border-artifact",
	[Enum.ItemQuality.Heirloom] = "auctionhouse-itemicon-border-account",
	[Enum.ItemQuality.WoWToken] = "auctionhouse-itemicon-border-account",
}








--###########
--监视声望按钮
--###########
--物品
local function Get_Item(itemID)
	local text, name
	local icon= C_Item.GetItemIconByID(itemID)
	local num= C_Item.GetItemCount(itemID , true, false, true)
	local bag= C_Item.GetItemCount(itemID)
	local itemQuality
	if icon and num>0 then

		itemQuality = C_Item.GetItemQualityByID(itemID)

		local numText
		if bag==num then
			numText= WoWTools_Mixin:MK(num, 3)
		else
			local bank= num-bag
			if bank==0 then
				numText= num
			else
				if Save().toRightTrackText then
					numText= (bag>0 and bag..'|A:bag-main:0:0|a' or '')..(bank>0 and bank..'|A:Levelup-Icon-Bag:0:0|a' or '')
				else
					numText= (bank>0 and bank..'|A:Levelup-Icon-Bag:0:0|a' or '')..(bag>0 and bag..'|A:bag-main:0:0|a' or '')
				end
			end
		end

		name= e.cn(C_Item.GetItemNameByID(itemID)) or ''

		local nameText
		local hex= itemQuality and select(4, C_Item.GetItemQualityColor(itemQuality)) or 'ffffffff'
		if Save().nameShow then
			nameText= '|c'..hex..name..'|r'
		else
			numText= '|c'..hex..numText..'|r'
		end

		if Save().toRightTrackText then--向右平移
			text=(nameText and nameText..' ' or '')..numText
		else
			text=numText..(nameText and ' '..nameText or '')
		end
	end
	return text, icon, itemQuality, name
end
















--货币
local function Get_Currency(currencyID, index)

	local info, num2, total, percent, isMax, canWeek, canEarned, canQuantity= WoWTools_CurrencyMixin:GetInfo(currencyID, index)

	local text
    if not info
		or info.isHeader
		or not info.iconFileID

		or (info.quantity==0 and not (canWeek or canEarned or canQuantity))
	then
		return
    end

    local name

	if Save().nameShow then
		local hex= currencyID and C_CurrencyInfo.IsAccountTransferableCurrency(currencyID) and 'ff00d1ff' or select(4, C_Item.GetItemQualityColor(info and info.quality or 1))
		name = format('|c%s%s|r', hex, e.cn(info.name))
	end


	local need
	if percent then
		need= format('(%d%%)', percent)
	end

	local num= WoWTools_Mixin:MK(num2, 3)

	local max
	if isMax then
		max= '|A:quest-important-available:0:0|a'--format('|A:%s:0:0|a', e.Icon.select)
		num= '|cnRED_FONT_COLOR:'..num..'|r'
	elseif canWeek or canEarned or canQuantity then
		num= '|cnGREEN_FONT_COLOR:'..num..'|r'
	end



	if Save().toRightTrackText then
		text= format('%s%s%s%s', name and name..' ' or '',  num or '', need and ' '..need or '', max or '')
	else
		text= format('%s%s%s%s', max or '', need and need..' ' or '', num or '', name and ' '..name or '')
	end


    return text, info.iconFileID, info.currencyID
end






















local function Set_TrackButton_Pushed(show, text)--提示
	if TrackButton then
		TrackButton:SetButtonState(show and 'PUSHED' or "NORMAL")
	end
	if text then
		text:SetAlpha(show and 0.5 or 1)
	end
end


















local function Set_TrackButton_Text()
	if not TrackButton or not TrackButton:IsShown() or not Save().str then
		if TrackButton then
			TrackButton.Frame:set_shown()
		end
		return
	end

	local tab={}
	local endTokenIndex=1--货物，物品，分开
	local bat= UnitAffectingCombat('player')

	if Save().indicato then
		for currencyID, _ in pairs(Save().tokens) do
			local text, icon= Get_Currency(currencyID, nil)--货币
			if text and icon then
				table.insert(tab, {text= text, icon=icon, currencyID=currencyID})
				endTokenIndex= endTokenIndex+1--货物，物品，分开
			end
		end
		table.sort(tab, function(a, b)
			return a.currencyID> b.currencyID
		end)
	else
		for index=1, C_CurrencyInfo.GetCurrencyListSize() do
			local text, icon, currencyID = Get_Currency(nil, index)--货币
			if text and icon then
				table.insert(tab, {text= text, icon=icon, index=index, currencyID= currencyID})
				endTokenIndex= endTokenIndex+1--货物，物品，分开
			end
		end
	end


	if not Save().disabledItemTrack then
		if (Save().itemButtonUse and not bat or not Save().itemButtonUse) then
			local itemTab={}
			for itemID in pairs(Save().item) do
				local text, icon, itemQuality, name= Get_Item(itemID)
				if text and icon then
					table.insert(itemTab, {text= text, icon=icon, itemID= itemID, itemQuality=itemQuality or 0, name=name})
				end
			end
			table.sort(itemTab, function(a, b)
				if a.itemQuality== b.itemQuality then
					return a.itemID> b.itemID
				else
					return a.itemQuality> b.itemQuality
				end
			end)
			for _, tables in pairs(itemTab) do
				table.insert(tab, tables)
			end
		end
		if Save().itemButtonUse then
			TrackButton.Frame:RegisterEvent('PLAYER_REGEN_ENABLED')
		end
	end

	local last

	for index, tables in pairs(tab) do
		local btn= TrackButton.btn[index]
		local itemButtonUse=(Save().itemButtonUse and tables.itemID) and true or nil--使用物品
		if not btn then
			btn= WoWTools_ButtonMixin:Cbtn(TrackButton.Frame, {size={14,14}, icon='hide', type=itemButtonUse, pushe=itemButtonUse})
			btn.itemButtonUse= itemButtonUse
			if itemButtonUse then
				btn.texture= btn:CreateTexture(nil,'BORDER')
				btn.texture:SetSize(14,14)
				btn.texture:SetPoint('CENTER',-0.5,0.5)
				btn.border=btn:CreateTexture(nil, 'ARTWORK')
				btn.border:SetSize(18,18)
				btn.border:SetPoint('CENTER',-0.5,0.3)

			elseif tables.itemID then
				btn.border=btn:CreateTexture(nil, 'ARTWORK')
				btn.border:SetAllPoints(btn)
			end

			btn.text= WoWTools_LabelMixin:CreateLabel(btn, {color={r=1,g=1,b=1}})


			if Save().toTopTrack then
				btn:SetPoint("BOTTOM", last or TrackButton, 'TOP', 0,  (endTokenIndex>1 and index==endTokenIndex) and 10 or 0) --货物，物品，分开
			else
				btn:SetPoint("TOP", last or TrackButton, 'BOTTOM', 0,  (endTokenIndex>1 and index==endTokenIndex) and -10 or 0) --货物，物品，分开
			end


			function btn:set_Text_Point()
				if Save().toRightTrackText then
					self.text:SetPoint('LEFT', self, 'RIGHT')
				else
					self.text:SetPoint('RIGHT', self, 'LEFT')
				end
			end
			btn:set_Text_Point()

			btn:SetScript('OnLeave', function(self)
				e.tips:Hide()
				Set_TrackButton_Pushed(false, self.text)--提示
				if self.itemID then
					WoWTools_BagMixin:Find(false)--查询，背包里物品
				end
			end)
			btn:SetScript('OnEnter', function(self)
				if Save().toRightTrackText then
					e.tips:SetOwner(self.text, "ANCHOR_RIGHT")
				else
					e.tips:SetOwner(self.text, "ANCHOR_LEFT")
				end
				e.tips:ClearLines()
				if self.itemID then
					e.tips:SetItemByID(self.itemID)
					e.tips:AddLine(' ')
					local col= C_Item.GetItemCount(self.itemID)==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:'
					if self.itemButtonUse then
						e.tips:AddDoubleLine(col..(e.onlyChinese and '使用物品' or USE_ITEM), e.Icon.left)
					end
					e.tips:AddDoubleLine(col..(e.onlyChinese and '拿取' or 'Pickup'), col..('Alt+'..e.Icon.left))
					WoWTools_BagMixin:Find(true, {itemID=self.itemID})--查询，背包里物品
				elseif self.currencyID then
					e.tips:SetCurrencyByID(self.currencyID)
					local link= C_CurrencyInfo.GetCurrencyLink(self.currencyID) or (e.onlyChinese and '超链接' or COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK)
					e.tips:AddDoubleLine(link..'|A:transmog-icon-chat:0:0|a', e.Icon.left)
				elseif self.index then
					e.tips:SetCurrencyToken(self.index)
				end
				--e.tips:AddDoubleLine(e.addName, addName)
				e.tips:Show()
				Set_TrackButton_Pushed(true, self.text)--提示
			end)
			btn:SetScript("OnMouseDown", function(self)
				if self.currencyID then
					WoWTools_ChatMixin:Chat(C_CurrencyInfo.GetCurrencyLink(self.currencyID), nil, true)
					return
				end
				if not self.itemID or not IsAltKeyDown() or C_Item.GetItemCount(self.itemID)==0 then return end

				for bag= Enum.BagIndex.Backpack, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
					for slot=1, C_Container.GetContainerNumSlots(bag) do
						if C_Container.GetContainerItemID(bag, slot)== self.itemID then
							C_Container.PickupContainerItem(bag, slot)
							return
						end
					end
				end
			end)

			function btn:set_item_cool()
				e.SetItemSpellCool(self, {item=self.itemID, type= self.itemButtonUs })
			end
			function btn:set_btn_Event()
				if self.itemID then
					self:RegisterEvent('BAG_UPDATE_COOLDOWN')
				end
			end
			btn:SetScript('OnEvent', function(self, event)
				self:set_item_cool()
			end)

			btn:SetScript('OnShow', function(self)
				self:set_item_cool()
				self:set_btn_Event()
			end)
			btn:SetScript('OnHide', function(self)
				self:UnregisterEvent('BAG_UPDATE_COOLDOWN')
			end)

			btn:set_btn_Event()

			if itemButtonUse then--使用物品
				btn:SetAttribute('type', 'item')
			end
			btn.itemButtonUse= itemButtonUse--使用物品

			TrackButton.btn[index]= btn
		end

		btn.itemID= tables.itemID
		btn.index= tables.index
		btn.name= tables.name
		btn.currencyID= tables.currencyID

		local can= btn:CanChangeAttribute()

		if btn.texture then
			SetPortraitToTexture(btn.texture, tables.icon)
		else
			btn:SetNormalTexture(tables.icon)--设置，图片
		end
		if btn.border then
			local atlas= btn.itemButtonUse and qualityToIconBorderAtlas[tables.itemQuality] or e.Icon[tables.itemQuality]--qualityToIconBorderAtlas4[tables.itemQuality]
			if atlas then
				btn.border:SetAtlas(atlas)
			end
			if can then
				btn:SetShown(atlas and true or false)
			end
		end

		btn.text:SetText(tables.text)--设置，文本

		btn:set_item_cool()

		if itemButtonUse and can then--使用物品
			btn:SetAttribute('item',  tables.itemID and tables.name or nil )
		end

		if btn.itemButtonUse and can or not btn.itemButtonUse then
			btn:SetShown(true)
		end

		last= btn
	end

	if TrackButton.endTokenIndex and TrackButton.endTokenIndex~= endTokenIndex then--货物，物品，分开
		last=nil
		for i= 1, #TrackButton.btn do
			local btn= TrackButton.btn[i]
			if btn and btn:CanChangeAttribute() then
				btn:ClearAllPoints()
				if endTokenIndex>1 and i==endTokenIndex then--货物，物品，分开
					btn:SetPoint("TOP", last or TrackButton, 'BOTTOM',0, -10)
				else
					btn:SetPoint("TOP", last or TrackButton, 'BOTTOM',0, -1)
				end
				last=btn
			end
		end
	end
	TrackButton.endTokenIndex= endTokenIndex


	for i= #tab+1, #TrackButton.btn do--隐藏，多余
		local btn= TrackButton.btn[i]
		if btn then
			btn.text:SetText('')
			btn:SetNormalTexture(0)
			if btn:CanChangeAttribute() then
				btn:SetShown(false)
			end
			btn.itemID= nil
			btn.index= nil
			btn.name= nil
			btn.currencyID= nil
		end
	end
end




















local function Init_TrackButton()
	if Save().Hide or TrackButton then
		if TrackButton then
			TrackButton:set_event()
			TrackButton:set_shown()
		end
		return
	end


	TrackButton= WoWTools_ButtonMixin:Cbtn(nil, {atlas='hide', size={18,18}, isType2=true})
	WoWTools_TokensMixin.TrackButton= TrackButton

	TrackButton.texture= TrackButton:CreateTexture()
	TrackButton.texture:SetAllPoints(TrackButton)
	TrackButton.texture:SetAlpha(0.5)

	function TrackButton:set_point()
		self:ClearAllPoints()
		if Save().point then
			self:SetPoint(Save().point[1], UIParent, Save().point[3], Save().point[4], Save().point[5])
		elseif e.Player.husandro then
			self:SetPoint('TOPLEFT')
		else
			self:SetPoint('TOPLEFT', TokenFrame, 'TOPRIGHT',0, -35)
		end
	end

	function TrackButton:set_texture(icon)
		if icon and icon>0 then
			self.texture:SetTexture(icon)
		elseif Save().str then
			self.texture:SetTexture(0)
		else
			self.texture:SetAtlas(e.Icon.icon)
		end
	end

	function TrackButton:set_shown()--显示,隐藏
		local hide= Save().Hide
		 	or (
				not Save().notAutoHideTrack and (
					IsInInstance()
					or C_PetBattles.IsInBattle()					
					or UnitHasVehicleUI('player')
					or UnitAffectingCombat('player')
				)
			)
		if self:CanChangeAttribute() then
			self:SetShown(not hide)
		end
	end

	function TrackButton:set_event()
		if Save().Hide then
			self:UnregisterAllEvents()
		else
			self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
			self:RegisterEvent('PLAYER_ENTERING_WORLD')
			self:RegisterEvent('PET_BATTLE_OPENING_DONE')
			self:RegisterEvent('PET_BATTLE_CLOSE')
			self:RegisterUnitEvent('UNIT_EXITED_VEHICLE', 'player')
			self:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', 'player')
			self:RegisterEvent('PLAYER_REGEN_DISABLED')
			self:RegisterEvent('PLAYER_REGEN_ENABLED')
		end
	end

	TrackButton:SetScript('OnEvent', TrackButton.set_shown)


	function TrackButton:set_scale()
		if self.Frame:CanChangeAttribute() then
			self.Frame:SetScale(Save().scaleTrackButton or 1)
		end
	end



	function TrackButton:set_Tooltips()
		if Save().toRightTrackText then
			e.tips:SetOwner(self, "ANCHOR_RIGHT")
		else
			e.tips:SetOwner(self, "ANCHOR_LEFT")
		end
		e.tips:ClearLines()

		local infoType, itemID, itemLink = GetCursorInfo()
		if infoType=='item' and itemID then
			e.tips:SetItemByID(itemID)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(itemLink or ('itemID'..itemID),
					Save().item[itemID] and
						('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a')
					or ('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', e.Icon.select))
			)
			self:set_texture(C_Item.GetItemIconByID(itemID))
		else
			local canFrame= self.Frame:CanChangeAttribute() and '|cnGREEN_FONT_COLOR:' or ''
			e.tips:AddDoubleLine(e.addName, addName)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(e.onlyChinese and '打开/关闭货币页面' or BINDING_NAME_TOGGLECURRENCY, e.Icon.left)
			e.tips:AddDoubleLine((e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU)..' '..e.GetShowHide(Save().str), e.Icon.right)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(canFrame..(e.onlyChinese and '移动' or NPE_MOVE), 'Atl+'..e.Icon.right)
			--e.tips:AddDoubleLine(canFrame..(e.onlyChinese and '缩放' or UI_SCALE)..' '..(Save().scaleTrackButton or 1), 'Alt+'..e.Icon.mid)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(canFrame..(e.onlyChinese and '拖曳' or DRAG_MODEL)..e.Icon.left..(e.onlyChinese and '物品' or ITEMS), e.onlyChinese and '追踪' or TRACKING)
		end
		e.tips:Show()
	end

	

	TrackButton:RegisterForDrag("RightButton")
	TrackButton:SetClampedToScreen(true)
	TrackButton:SetMovable(true)
	TrackButton:SetScript("OnDragStart", function(self)
		if IsAltKeyDown() then
			self:StartMoving()
		end
	end)
	TrackButton:SetScript("OnDragStop", function(self)
		ResetCursor()
		self:StopMovingOrSizing()
		Save().point={self:GetPoint(1)}
		Save().point[2]=nil
	end)
	TrackButton:SetScript("OnMouseUp", ResetCursor)
	--[[TrackButton:SetScript("OnMouseWheel", function(self, d)
		if IsAltKeyDown() then
			local n= Save().scaleTrackButton or 1
			if d==1 then
				n= n+ 0.05
			elseif d==-1 then
				n= n- 0.05
			end
			n= n<0.4 and 0.4 or n
			n= n>4 and 4 or n
			Save().scaleTrackButton=n
			self:set_Scale()
			self:set_Tooltips()
			print(e.addName, addName, e.onlyChinese and '缩放' or UI_SCALE, n)
		end
	end)]]
	TrackButton:SetScript("OnMouseDown", function(self, d)
		if d=='RightButton' and IsAltKeyDown() then--右击,移动
			SetCursor('UI_MOVE_CURSOR')
			return
		end

		local infoType, itemID, itemLink = GetCursorInfo()
        if infoType == "item" and itemID then
			Save().item[itemID]= not Save().item[itemID] and true or nil
			print(e.addName, addName, e.onlyChinese and '追踪' or TRACKING,
					Save().item[itemID] and
					('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', e.Icon.select))
					or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a'),
					itemLink or itemID)
			ClearCursor()
			Set_TrackButton_Text()

		elseif d=='LeftButton' and not IsModifierKeyDown() then
			ToggleCharacter("TokenFrame")--打开货币

		elseif d=='RightButton' and not IsModifierKeyDown() then
			WoWTools_TokensMixin:Init_TrackButton_Menu(self)
		end
	end)


	TrackButton:SetScript("OnEnter", function(self)
		if (Save().itemButtonUse and not UnitAffectingCombat('player')) or not Save().itemButtonUse then
			Set_TrackButton_Text()
			self:set_shown()
		end
		self:set_Tooltips()
		self.texture:SetAlpha(1)
	end)
	TrackButton:SetScript('OnMouseUp', ResetCursor)
	TrackButton:SetScript("OnLeave", function(self)
		e.tips:Hide()
		self:set_texture()
		self.texture:SetAlpha(0.5)
	end)









	TrackButton.btn={}
	TrackButton.Frame= CreateFrame('Frame', nil, TrackButton)
	TrackButton.Frame:SetSize(1,1)
	TrackButton.Frame:SetPoint('BOTTOM')



	TrackButton.Frame:SetScript('OnShow', Set_TrackButton_Text)

	TrackButton.Frame:RegisterEvent('BAG_UPDATE_DELAYED')
	TrackButton.Frame:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
	TrackButton.Frame:SetScript('OnEvent', function(self, event)
		if event=='PLAYER_REGEN_ENABLED' then
			self:UnregisterEvent('PLAYER_REGEN_ENABLED')
		end
		Set_TrackButton_Text()
	end)
	function TrackButton.Frame:set_shown()
		if Save().itemButtonUse and not UnitAffectingCombat('player') or not Save().itemButtonUse then
			self:SetShown(Save().str)
		end
	end
	TrackButton.Frame:set_shown()

	function TrackButton:set_strata()
        self:SetFrameStrata(Save().strata or 'MEDIUM')
    end
	TrackButton:set_strata()
	TrackButton:set_point()
	TrackButton:set_scale()
	TrackButton:set_event()
	TrackButton:set_shown()
	TrackButton:set_texture()

	Set_TrackButton_Text()
end


















function WoWTools_TokensMixin:Init_TrackButton()
	addName= self.addName
    Init_TrackButton()
end

function WoWTools_TokensMixin:Set_TrackButton_Pushed(status)--提示
    Set_TrackButton_Pushed(status)
end

function WoWTools_TokensMixin:Set_TrackButton_Text()
    Set_TrackButton_Text()
end
