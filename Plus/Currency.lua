local id, e = ...
local addName= TOKENS
local Save={
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
}
local Button
local TrackButton
local Initializer

for itemID, _ in pairs(Save.item) do
	e.LoadDate({id=itemID, type='item'})--加载 item quest spell
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

--[[local qualityToIconBorderAtlas4 ={
	[Enum.ItemQuality.Poor] = "dressingroom-itemborder-gray",
	[Enum.ItemQuality.Common] = "dressingroom-itemborder-white",
	[Enum.ItemQuality.Uncommon] = "dressingroom-itemborder-green",
	[Enum.ItemQuality.Rare] = "dressingroom-itemborder-blue",
	[Enum.ItemQuality.Epic] = "dressingroom-itemborder-purple",
	[Enum.ItemQuality.Legendary] = "auctionhouse-itemicon-border-orange",
	[Enum.ItemQuality.Artifact] = "dressingroom-itemborder-orange",
	[Enum.ItemQuality.Heirloom] = "dressingroom-itemborder-account",
	[Enum.ItemQuality.WoWToken] = "dressingroom-itemborder-account",
}
]]





--从currencyID, index中取得 info, currencyID
--[[从index直接取得info, 会出现，赛季内容错误，10.2中出现
local function Get_For_index_To_currencyID(currencyID, index)--从currencyID, index中取得 info, currencyID
	local link
	if index then
		link= C_CurrencyInfo.GetCurrencyListLink(index)
		if link then
			currencyID= C_CurrencyInfo.GetCurrencyIDFromLink(link)
		end
	end
	if currencyID then
		return C_CurrencyInfo.GetCurrencyInfo(currencyID), currencyID, link
	end
end
]]










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
			numText= e.MK(num, 3)
		else
			local bank= num-bag
			if bank==0 then
				numText= num
			else
				if Save.toRightTrackText then
					numText= (bag>0 and bag..'|A:bag-main:0:0|a' or '')..(bank>0 and bank..'|A:Levelup-Icon-Bag:0:0|a' or '')
				else
					numText= (bank>0 and bank..'|A:Levelup-Icon-Bag:0:0|a' or '')..(bag>0 and bag..'|A:bag-main:0:0|a' or '')
				end
			end
		end

		name= e.cn(C_Item.GetItemNameByID(itemID)) or ''

		local nameText
		local hex= itemQuality and select(4, C_Item.GetItemQualityColor(itemQuality)) or 'ffffffff'
		if Save.nameShow then
			nameText= '|c'..hex..name..'|r'
		else
			numText= '|c'..hex..numText..'|r'
		end

		if Save.toRightTrackText then--向右平移
			text=(nameText and nameText..' ' or '')..numText
		else
			text=numText..(nameText and ' '..nameText or '')
		end
	end
	return text, icon, itemQuality, name
end




--货币
local function Get_Currency(currencyID, index)
	local info, num, total, percent, isMax, canWeek, canEarned, canQuantity= e.GetCurrencyMaxInfo(currencyID, index)

	local text
    if not info
		or info.isHeader
		or not info.iconFileID

		or (info.quantity==0 and not (canWeek or canEarned or canQuantity))
	then
		return
    end

    local name
	if Save.nameShow then
		local hex= select(4, C_Item.GetItemQualityColor(info and info.quality or 1))
		--local col= (ITEM_QUALITY_COLORS[info.quality] or {}).hex
		name = format('|c%s%s|r', hex, e.cn(info.name))
	end


	local need
	if percent then
		need= format('(%d%%)', percent)
	end

	num= e.MK(num, 3)

	local max
	if isMax then
		max= '|A:quest-important-available:0:0|a'--format('|A:%s:0:0|a', e.Icon.select)
		num= '|cnRED_FONT_COLOR:'..num..'|r'
	elseif canWeek or canEarned or canQuantity then
		num= '|cnGREEN_FONT_COLOR:'..num..'|r'
	end



	if Save.toRightTrackText then
		text= format('%s%s%s%s', name and name..' ' or '',  num, need and ' '..need or '', max or '')
	else
		text= format('%s%s%s%s', max or '', need and need..' ' or '', num, name and ' '..name or '')
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
	if not TrackButton or not TrackButton:IsShown() or not Save.str then
		if TrackButton then
			TrackButton.Frame:set_shown()
		end
		return
	end

	local tab={}
	local endTokenIndex=1--货物，物品，分开
	local bat= UnitAffectingCombat('player')

	if Save.indicato then
		for currencyID, _ in pairs(Save.tokens) do
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
	if not Save.disabledItemTrack then
		if (Save.itemButtonUse and not bat or not Save.itemButtonUse) then
			local itemTab={}
			for itemID in pairs(Save.item) do
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
		if Save.itemButtonUse then
			TrackButton.Frame:RegisterEvent('PLAYER_REGEN_ENABLED')
		end
	end

	local last

	for index, tables in pairs(tab) do
		local btn= TrackButton.btn[index]
		local itemButtonUse=(Save.itemButtonUse and tables.itemID) and true or nil--使用物品
		if not btn then
			btn= e.Cbtn(TrackButton.Frame, {size={14,14}, icon='hide', type=itemButtonUse, pushe=itemButtonUse})
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
				--btn.border:SetSize(18,18)
				--btn.border:SetPoint('CENTER',-0.5,0.5)
			end

			btn.text= e.Cstr(btn, {color={r=1,g=1,b=1}})


			if Save.toTopTrack then
				btn:SetPoint("BOTTOM", last or TrackButton, 'TOP', 0,  (endTokenIndex>1 and index==endTokenIndex) and 10 or 0) --货物，物品，分开
			else
				btn:SetPoint("TOP", last or TrackButton, 'BOTTOM', 0,  (endTokenIndex>1 and index==endTokenIndex) and -10 or 0) --货物，物品，分开
			end


			function btn:set_Text_Point()
				if Save.toRightTrackText then
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
					e.FindBagItem(false)--查询，背包里物品
				end
			end)
			btn:SetScript('OnEnter', function(self)
				if Save.toRightTrackText then
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
					e.FindBagItem(true, {itemID=self.itemID})--查询，背包里物品
				elseif self.currencyID then
					e.tips:SetCurrencyByID(self.currencyID)
					local link= C_CurrencyInfo.GetCurrencyLink(self.currencyID) or (e.onlyChinese and '超链接' or COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK)
					e.tips:AddDoubleLine(link..'|A:transmog-icon-chat:0:0|a', e.Icon.left)
				elseif self.index then
					e.tips:SetCurrencyToken(self.index)
				end
				--e.tips:AddDoubleLine(id, Initializer:GetName())
				e.tips:Show()
				Set_TrackButton_Pushed(true, self.text)--提示
			end)
			btn:SetScript("OnMouseDown", function(self)
				if self.currencyID then					
					e.Chat(C_CurrencyInfo.GetCurrencyLink(self.currencyID), nil, true)
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








--物品，菜单
local function MenuList_Item(level)
	local info
	for itemID, _ in pairs(Save.item) do
		info={
			text= select(2, C_Item.GetItemInfo(itemID)) or ('itemID '..itemID),
			icon= C_Item.GetItemIconByID(itemID),
			notCheckable=true,
			tooltipOnButton=true,
			tooltipTitle=e.onlyChinese and '移除' or REMOVE,
			arg1= itemID,
			func= function(_, arg1)
				Save.item[arg1]= nil
				Set_TrackButton_Text()
				print(id, Initializer:GetName(), e.onlyChinese and '移除' or REMOVE, select(2, C_Item.GetItemInfo(itemID)) or ('itemID '..itemID))
			end
		}
		e.LibDD:UIDropDownMenu_AddButton(info, level)
	end
	e.LibDD:UIDropDownMenu_AddSeparator(level)
	info={
		text= e.onlyChinese and '全部清除' or CLEAR_ALL,
		icon='bags-button-autosort-up',
		notCheckable=true,
		tooltipOnButton=true,
		tooltipTitle='Shift+'..e.Icon.left,
		func= function()
			if IsShiftKeyDown() then
				Save.item= {}
				Set_TrackButton_Text()
				print(id, Initializer:GetName(), e.onlyChinese and '全部清除' or CLEAR_ALL)
			end
		end
	}
	e.LibDD:UIDropDownMenu_AddButton(info, level)

	e.LibDD:UIDropDownMenu_AddSeparator(level)
	info={
		text= e.onlyChinese and '使用物品' or USE_ITEM,
		checked= Save.itemButtonUse,
		keepShownOnClick= true,
		tooltipOnButton= true,
		disabled=UnitAffectingCombat('player'),
		tooltipTitle= '|cnRED_FONT_COLOR:'..(e.onlyChinese and '友情提示: 可能会出现错误' or ('note: '..ENABLE_ERROR_SPEECH)..'|r'),
		tooltipText= (e.onlyChinese and '重新加载UI' or RELOADUI)..'|n'..SLASH_RELOAD1,
		func= function()
			Save.itemButtonUse= not Save.itemButtonUse and true or nil
			e.Reload()
		end
	}
	e.LibDD:UIDropDownMenu_AddButton(info, level)
end







local function Init_TrackButton()
	if Save.Hide or TrackButton then
		if TrackButton then
			TrackButton:set_Event()
			TrackButton:set_Shown()
		end
		return
	end


	TrackButton= e.Cbtn(nil, {atlas='hide', size={18,18}, pushe=true})

	TrackButton.texture= TrackButton:CreateTexture()
	TrackButton.texture:SetAllPoints(TrackButton)
	TrackButton.texture:SetAlpha(0.5)

	function TrackButton:set_Point()
		if Save.point then
			self:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
		elseif e.Player.husandro then
			self:SetPoint('TOPLEFT')
		else
			self:SetPoint('TOPLEFT', TokenFrame, 'TOPRIGHT',0, -35)
		end
	end

	function TrackButton:set_Texture(icon)
		if icon and icon>0 then
			self.texture:SetTexture(icon)
		elseif Save.str then
			self.texture:SetTexture(0)
		else
			self.texture:SetAtlas(e.Icon.icon)
		end
	end

	function TrackButton:set_Shown()--显示,隐藏
		local hide= Save.Hide
		 	or (
				not Save.notAutoHideTrack and (IsInInstance() or C_PetBattles.IsInBattle() or UnitAffectingCombat('player'))
			)
		if self:CanChangeAttribute() then
			self:SetShown(not hide)
		end
	end

	function TrackButton:set_Scale()
		if self.Frame:CanChangeAttribute() then
			self.Frame:SetScale(Save.scaleTrackButton or 1)
		end
	end



	function TrackButton:set_Tooltips()
		if Save.toRightTrackText then
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
					Save.item[itemID] and
						('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a')
					or ('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', e.Icon.select))
			)
			self:set_Texture(C_Item.GetItemIconByID(itemID))
		else
			local canFrame= self.Frame:CanChangeAttribute() and '|cnGREEN_FONT_COLOR:' or ''
			e.tips:AddDoubleLine(id, Initializer:GetName())
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(e.onlyChinese and '打开/关闭货币页面' or BINDING_NAME_TOGGLECURRENCY, e.Icon.left)
			e.tips:AddDoubleLine((e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU)..' '..e.GetShowHide(Save.str), e.Icon.right)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(canFrame..(e.onlyChinese and '移动' or NPE_MOVE), 'Atl+'..e.Icon.right)
			e.tips:AddDoubleLine(canFrame..(e.onlyChinese and '缩放' or UI_SCALE)..' '..(Save.scaleTrackButton or 1), 'Alt+'..e.Icon.mid)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(canFrame..(e.onlyChinese and '拖曳' or DRAG_MODEL)..e.Icon.left..(e.onlyChinese and '物品' or ITEMS), e.onlyChinese and '追踪' or TRACKING)
		end
		e.tips:Show()
	end

	function TrackButton:set_Event()
		if Save.Hide then
			self:UnregisterAllEvents()
		else
			self:RegisterEvent('PLAYER_ENTERING_WORLD')
			self:RegisterEvent('PET_BATTLE_OPENING_DONE')
			self:RegisterEvent('PET_BATTLE_CLOSE')
			self:RegisterEvent('PLAYER_REGEN_DISABLED')
			self:RegisterEvent('PLAYER_REGEN_ENABLED')
		end
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
		Save.point={self:GetPoint(1)}
		Save.point[2]=nil
	end)
	TrackButton:SetScript("OnMouseUp", ResetCursor)
	TrackButton:SetScript("OnMouseWheel", function(self, d)
		if IsAltKeyDown() then
			local n= Save.scaleTrackButton or 1
			if d==1 then
				n= n+ 0.05
			elseif d==-1 then
				n= n- 0.05
			end
			n= n<0.4 and 0.4 or n
			n= n>4 and 4 or n
			Save.scaleTrackButton=n
			self:set_Scale()
			self:set_Tooltips()
			print(id, Initializer:GetName(), e.onlyChinese and '缩放' or UI_SCALE, n)
		end
	end)
	TrackButton:SetScript("OnMouseDown", function(self, d)
		if d=='RightButton' and IsAltKeyDown() then--右击,移动
			SetCursor('UI_MOVE_CURSOR')
			return
		end

		local infoType, itemID, itemLink = GetCursorInfo()
        if infoType == "item" and itemID then
			Save.item[itemID]= not Save.item[itemID] and true or nil
			print(id, Initializer:GetName(), e.onlyChinese and '追踪' or TRACKING,
					Save.item[itemID] and
					('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', e.Icon.select))
					or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a'),
					itemLink or itemID)
			ClearCursor()
			Set_TrackButton_Text()

		elseif d=='LeftButton' and not IsModifierKeyDown() then
			ToggleCharacter("TokenFrame")--打开货币

		elseif d=='RightButton' and not IsModifierKeyDown() then
			if not self.Menu then
				self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
				e.LibDD:UIDropDownMenu_Initialize(self.Menu, function(_, level, menuList)
					if menuList=='ITEMS' then
						MenuList_Item(level)
						return
					end
					local info={
						text= e.onlyChinese and '显示' or SHOW,
						tooltipOnButton=true,
						tooltipTitle=e.onlyChinese and '显示/隐藏' or (SHOW..'/'..HIDE),
						checked= Save.str,
						keepShownOnClick=true,
						disabled= Save.itemButtonUse and UnitAffectingCombat('player'),
						func= function()
							Save.str= not Save.str and true or nil
							TrackButton:set_Texture()
							TrackButton.Frame:set_shown()
							print(id, Initializer:GetName(), e.GetShowHide(Save.str))
						end
					}
					e.LibDD:UIDropDownMenu_AddButton(info, level)
					e.LibDD:UIDropDownMenu_AddSeparator(level)
					info={
						text=e.onlyChinese and '显示名称' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, NAME),
						checked= Save.nameShow,
						keepShownOnClick=true,
						func= function()
							Save.nameShow= not Save.nameShow and true or nil
							Set_TrackButton_Text()
						end
					}
					e.LibDD:UIDropDownMenu_AddButton(info, level)

					info={
						text= e.onlyChinese and '向右平移' or BINDING_NAME_STRAFERIGHT,
						checked= Save.toRightTrackText,
						keepShownOnClick=true,
						icon= 'NPE_ArrowRight',
						func= function()
							Save.toRightTrackText = not Save.toRightTrackText and true or nil
							for _, btn in pairs(TrackButton.btn) do
								btn.text:ClearAllPoints()
								btn:set_Text_Point()
							end
							Set_TrackButton_Text()
						end
					}

					e.LibDD:UIDropDownMenu_AddButton(info, level)
					info={
						text=e.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP,
						icon='bags-greenarrow',
						checked= Save.toTopTrack,
						tooltipOnButton=true,
						tooltipTitle= (e.onlyChinese and '重新加载UI' or RELOADUI)..'|n'..SLASH_RELOAD1,
						disabled= UnitAffectingCombat('player'),
						func= function()
							Save.toTopTrack = not Save.toTopTrack and true or nil
							e.Reload()
						end
					}
					e.LibDD:UIDropDownMenu_AddButton(info, level)

					info={
						text=e.onlyChinese and '物品' or ITEMS,
						checked= not Save.disabledItemTrack,
						menuList='ITEMS',
						hasArrow=true,
						keepShownOnClick=true,
						disabled= UnitAffectingCombat('player'),
						func= function()
							Save.disabledItemTrack = not Save.disabledItemTrack and true or nil
							Set_TrackButton_Text()
						end
					}
					e.LibDD:UIDropDownMenu_AddButton(info, level)

					e.LibDD:UIDropDownMenu_AddSeparator(level)
					e.LibDD:UIDropDownMenu_AddButton({
						text= e.onlyChinese and '选项' or OPTIONS,
						notCheckable=true,
						icon= 'mechagon-projects',
						func= function()
							e.OpenPanelOpting(Initializer:GetName())
						end
					}, level)
				end, 'MENU')
			end
			e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)
		end
	end)


	TrackButton:SetScript("OnEnter", function(self)
		if (Save.itemButtonUse and not UnitAffectingCombat('player')) or not Save.itemButtonUse then
			Set_TrackButton_Text()
			self:set_Shown()
		end
		self:set_Tooltips()
		self.texture:SetAlpha(1)
	end)
	TrackButton:SetScript('OnMouseUp', ResetCursor)
	TrackButton:SetScript("OnLeave", function(self)
		e.tips:Hide()
		self:set_Texture()
		self.texture:SetAlpha(0.5)
	end)
	TrackButton:SetScript('OnEvent', TrackButton.set_Shown)








	TrackButton.btn={}
	TrackButton.Frame= CreateFrame('Frame', nil, TrackButton)
	TrackButton.Frame:SetSize(1,1)
	TrackButton.Frame:SetPoint('BOTTOM')



	TrackButton.Frame:SetScript('OnShow', Set_TrackButton_Text)

	TrackButton.Frame:RegisterEvent('BAG_UPDATE_DELAYED')
	--TrackButton.Frame:RegisterEvent('BAG_UPDATE')
	TrackButton.Frame:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
	TrackButton.Frame:SetScript('OnEvent', function(self, event)
		if event=='PLAYER_REGEN_ENABLED' then
			self:UnregisterEvent('PLAYER_REGEN_ENABLED')
		end
		Set_TrackButton_Text()
	end)
	function TrackButton.Frame:set_shown()
		if Save.itemButtonUse and not UnitAffectingCombat('player') or not Save.itemButtonUse then
			self:SetShown(Save.str)
		end
	end
	TrackButton.Frame:set_shown()

	TrackButton:set_Point()
	TrackButton:set_Scale()
	TrackButton:set_Event()
	TrackButton:set_Shown()
	TrackButton:set_Texture()

	Set_TrackButton_Text()



end








































--#############
--套装,转换,货币
--Blizzard_ItemInteractionUI.lua
local function set_ItemInteractionFrame_Currency(self)
	if not self then
		return
	end
    local itemInfo= C_ItemInteraction.GetItemInteractionInfo() or {}
	local currencyID= itemInfo.currencyTypeId or self.chargeCurrencyTypeId
	currencyID= currencyID or e.SetItemCurrencyID--套装，转换，货币

	if not currencyID then
		return
	end

	if self==ItemInteractionFrame then
		TokenFrame.chargeCurrencyTypeId= currencyID
	end

    local info= C_CurrencyInfo.GetCurrencyInfo(currencyID)
	local text
    if info and info.quantity and (info.discovered or info.quantity>0) then
        text= info.iconFileID and '|T'..info.iconFileID..':0|t' or ''
        text= text.. info.quantity
        text= info.maxQuantity and text..'/'..info.maxQuantity or text
        if not self.ItemInteractionFrameCurrencyText then
            self.ItemInteractionFrameCurrencyText= e.Cstr(self)
            self.ItemInteractionFrameCurrencyText:SetPoint('TOPLEFT', 55, -38)
			self.ItemInteractionFrameCurrencyText:EnableMouse(true)
			self.ItemInteractionFrameCurrencyText:SetScript('OnEnter', function(self2)
				if self2.chargeCurrencyTypeId then
					e.tips:SetOwner(self2, "ANCHOR_LEFT")
					e.tips:ClearLines()
					e.tips:SetCurrencyByID(self2.chargeCurrencyTypeId)
					e.tips:AddLine(' ')
					e.tips:AddDoubleLine(id, Initializer:GetName())
					e.tips:Show()
				end
			end)
			self.ItemInteractionFrameCurrencyText:SetScript('OnLeave', GameTooltip_Hide)
        end
		self.ItemInteractionFrameCurrencyText.chargeCurrencyTypeId= currencyID

        local chargeInfo = C_ItemInteraction.GetChargeInfo()
        local timeToNextCharge = chargeInfo.timeToNextCharge

        if timeToNextCharge and (self.interactionType == Enum.UIItemInteractionType.ItemConversion) then
            text= text ..' |cnGREEN_FONT_COLOR:'..(e.SecondsToClock(timeToNextCharge, true) or '')..'|r'
        end

		if info.canEarnPerWeek and info.maxWeeklyQuantity and info.maxWeeklyQuantity>0 then
			text= text..' ('..info.quantityEarnedThisWeek..'/'..info.maxWeeklyQuantity..')'
		end
    end

	if self.ItemInteractionFrameCurrencyText then
		self.ItemInteractionFrameCurrencyText:SetText(text or '')
	end
end



















local function set_Tokens_Button(frame)--设置, 列表, 内容
	local data= frame.elementData or {}
	if not data.currencyIndex then
		return
	end

	local info, _, _, percent, isMax, canWeek, canEarned, canQuantity= e.GetCurrencyMaxInfo(nil, data.currencyIndex)
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
				Save.tokens[self.currencyID]= not Save.tokens[self.currencyID] and self.index or nil
				frame.check:SetAlpha(Save.tokens[self.currencyID] and 1 or 0.5)
				Set_TrackButton_Text()
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
			e.tips:AddDoubleLine(id, Initializer:GetName())
			e.tips:Show()
		end)
		frame.check:SetScript('OnLeave', GameTooltip_Hide)
		frame.check:SetSize(15,15)

		frame:HookScript('OnEnter', function(self)
			for _, btn in pairs(TrackButton and TrackButton.btn or {}) do
				local show= self.check.currencyID and self.check.currencyID== btn.currencyID
				if btn:CanChangeAttribute() then
					btn:SetScale(show and 2 or 1)
				else
					btn:SetAlpha(show and 0.3 or 1)
				end
			end
		end)
		frame:HookScript('OnLeave', function()
			for _, btn in pairs(TrackButton and TrackButton.btn or {}) do
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
		frame.check.index= frame.index
		frame.check:SetShown(true)
		frame.check:SetChecked(Save.tokens[currencyID])
		frame.check:SetAlpha(Save.tokens[currencyID] and 1 or 0.5)
	end

	
	if isMax then
		frame.Content.Count:SetTextColor(1,0,0)
	elseif canWeek or canEarned or canQuantity then
		frame.Content.Count:SetTextColor(0,1,0)
	else
		frame.Content.Count:SetTextColor(1,1,1)
	end

	if percent and not frame.percentText then
		frame.percentText= e.Cstr(frame, {color={r=1,g=1,b=1}})
		frame.percentText:SetPoint('RIGHT', frame.Content.Count, 'LEFT')
	end

	if frame.percentText then
		frame.percentText:SetText(percent and format('%d%%', percent) or '')
	end

	if frame.Name then
		local r, g, b= C_Item.GetItemQualityColor(info and info.quality or 1)
		frame.Content.Name:SetTextColor(r or 1, g or 1, b or 1)
	end

	frame.Content.AccountWideIcon:SetShown(info.isAccountTransferable)
end


























--#####
--主菜单
--#####
local function InitMenu(_, level, menuList)--主菜单

	local info
	if menuList=='ITEMS' then
		MenuList_Item(level)

	elseif menuList=='TOKENS' then
		for currencyID, _ in pairs(Save.tokens) do
			local currencyInfo= C_CurrencyInfo.GetCurrencyInfo(currencyID) or {}
			info={
				text= currencyInfo.name or currencyID,
				icon=currencyInfo.iconFileID,
				notCheckable=true,
				tooltipOnButton=true,
				tooltipTitle=e.onlyChinese and '移除' or REMOVE,
				tooltipText='ID '..currencyID,
				colorCode= not Save.indicato and '|cff9e9e9e' or (currencyInfo and ITEM_QUALITY_COLORS[currencyInfo.quality]).hex or nil,
				arg1= currencyID,
				func= function(_, arg1)
					Save.tokens[arg1]=nil
					TokenFrame:Update()
					print(id, Initializer:GetName(), e.onlyChinese and '移除' or REMOVE, C_CurrencyInfo.GetCurrencyLink(arg1) or arg1)
				end
			}
			e.LibDD:UIDropDownMenu_AddButton(info, level)
		end
		e.LibDD:UIDropDownMenu_AddSeparator(level)

		info={
			text= e.onlyChinese and '添加' or ADD,
			notCheckable=true,
			tooltipOnButton=true,
			tooltipTitle= e.onlyChinese and '自定义' or CUSTOM,
			icon='communities-icon-addchannelplus',
			func= function()
				StaticPopupDialogs[id..addName..'AddTokensUse']= StaticPopupDialogs[id..addName..'AddTokensUse'] or {--快捷键,设置对话框
					text=' |n ',-- e.onlyChinese and '货币' or TOKENS,
					whileDead=true, hideOnEscape=true, exclusive=true, showAlert=true,
					hasEditBox=true,
					button1= e.onlyChinese and '添加' or ADD,
					button2= e.onlyChinese and '取消' or CANCEL,
					OnShow=function(s)
                        s.editBox:SetNumeric(true)
						s.editBox:SetFocus()
                    end,
					OnHide= function()
						e.call('ChatEdit_FocusActiveWindow')
					end,
					OnAccept = function(s)
						local n= s.editBox:GetNumber()
						if n then
							Save.tokens[n]=0
							print(id, Initializer:GetName(), e.onlyChinese and '添加' or ADD,  C_CurrencyInfo.GetCurrencyLink(n))
							TokenFrame:Update()
						end
					end,
					EditBoxOnTextChanged=function(s)
						local n= s:GetNumber()
						local curInfo= n and C_CurrencyInfo.GetCurrencyInfo(n)
						local text= e.onlyChinese and '货币' or TOKENS
						local icon
						if curInfo then
							icon= curInfo.iconFileID
							text= C_CurrencyInfo.GetCurrencyLink(n) or curInfo.name or text
							print(Save.tokens[n])
							if Save.tokens[n] then
								text= text..'|n'..(e.onlyChinese and '已存在|r' or ' Existed')
							end
						end
						local p= s:GetParent()
						p.text:SetText(text)
						p.button1:SetEnabled(curInfo and not Save.tokens[n])
						p.AlertIcon:SetTexture(icon or 0)
					end,
					EditBoxOnEscapePressed = function(s)
						s:ClearFocus()
						s:GetParent():Hide()
					end,
				}
				StaticPopup_Show(id..addName..'AddTokensUse')
			end
		}
		e.LibDD:UIDropDownMenu_AddButton(info, level)

		info={
			text= e.onlyChinese and '全部清除' or CLEAR_ALL,
			icon='bags-button-autosort-up',
			notCheckable=true,
			tooltipOnButton=true,
			tooltipTitle='Shift+'..e.Icon.left,
			func= function()
				if IsShiftKeyDown() then
					Save.tokens= {}
					TokenFrame:Update()
					print(id, Initializer:GetName(), e.onlyChinese and '全部清除' or CLEAR_ALL)
				end
			end
		}
		e.LibDD:UIDropDownMenu_AddButton(info, level)

	elseif menuList=='RestPoint' then
		info={
			text= e.onlyChinese and '自动隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE),
			checked= not Save.notAutoHideTrack,
			disabled= Save.itemButtonUse and UnitAffectingCombat('player'),
			tooltipOnButton=true,
			tooltipTitle= (e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)..'|n'
				..(e.onlyChinese and '宠物对战' or SHOW_PET_BATTLES_ON_MAP_TEXT)..'|n'
				..(e.onlyChinese and '在副本中' or AGGRO_WARNING_IN_INSTANCE),
			func= function()
				Save.notAutoHideTrack= not Save.notAutoHideTrack and true or nil
				if TrackButton then
					TrackButton:set_Shown()
				end
			end
		}
		e.LibDD:UIDropDownMenu_AddButton(info, level)
		e.LibDD:UIDropDownMenu_AddSeparator(level)
		info={
			text=e.onlyChinese and '重置位置' or RESET_POSITION,
			colorCode= (not Save.point or not TrackButton) and '|cff9e9e9e' or nil,
			notCheckable=true,
			keepShownOnClick=true,
			func= function()
				Save.point=nil
				if TrackButton then
					TrackButton:ClearAllPoints()
					TrackButton:set_Point()
				end
				print(id, Initializer:GetName(), e.onlyChinese and '重置位置' or RESET_POSITION)
			end
		}
		e.LibDD:UIDropDownMenu_AddButton(info, level)
	end

	if menuList then
		return
	end

    info={
		text= (e.onlyChinese and '追踪' or TRACKING),
		checked= not Save.Hide,
		keepShownOnClick=true,
		hasArrow=true,
		menuList='RestPoint',
		func= function()
			Save.Hide= not Save.Hide and true or nil
			Init_TrackButton()
			print(id, Initializer:GetName(), e.onlyChinese and '追踪' or TRACKING, e.GetEnabeleDisable(not Save.Hide))
		end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

	info={
		text=e.onlyChinese and '指定货币' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMBAT_ALLY_START_MISSION, TOKENS),
		checked= Save.indicato,
		tooltipOnButton=true,
		menuList='TOKENS',
		hasArrow=true,
		keepShownOnClick=true,
		func= function()
			Save.indicato= not Save.indicato and true or nil
			Set_TrackButton_Text()
		end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

	info={
		text=e.onlyChinese and '物品' or ITEMS,
		checked= not Save.disabledItemTrack,
		menuList='ITEMS',
		hasArrow=true,
		keepShownOnClick=true,
		disabled= UnitAffectingCombat('player'),
		colorCode=Save.Hide and '|cff9e9e9e' or nil,
		func= function()
			Save.disabledItemTrack = not Save.disabledItemTrack and true or nil
			Set_TrackButton_Text()
		end
	}
    e.LibDD:UIDropDownMenu_AddButton(info, level)

	e.LibDD:UIDropDownMenu_AddSeparator(level)
	info={
		text=e.onlyChinese and '达到上限' or CAPPED,
		checked= not Save.hideCurrencyMax,
		icon='communities-icon-chat',
		tooltipOnButton=true,
		tooltipTitle=e.onlyChinese and '已达到资源上限' or SPELL_FAILED_CUSTOM_ERROR_248,
		keepShownOnClick=true,
		func= function()
			Save.hideCurrencyMax= not Save.hideCurrencyMax and true or nil
			Button:set_Event()--已达到资源上限
			if not Save.hideCurrencyMax then
				Button.currencyMax={}--已达到资源上限
				Button:currency_Max()
				print(id, Initializer:GetName(), 'Test', '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已达到资源上限' or SPELL_FAILED_CUSTOM_ERROR_248))
			end
		end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end











--货币，转移
local function Init_Currency_Transfer()
	hooksecurefunc(CurrencyTransferLog.ScrollBox, 'Update', function(self)
		if not self:GetView() then
            return
        end
		for _, btn in pairs(self:GetFrames() or {}) do
			local data= btn.transactionData or {}
			local name= e.GetPlayerInfo({guid=data.sourceCharacterGUID, reName=true, reRealm=true})
			if name~='' then
				btn.SourceName:SetText(name)
			end

			name= e.GetPlayerInfo({guid=data.destinationCharacterGUID, reName=true, reRealm=true})
			if name~='' then
				btn.DestinationName:SetText(name)
			end

		end
	end)
	CurrencyTransferMenuCloseButton:SetFrameLevel(CurrencyTransferMenuCloseButton:GetFrameLevel()+1)--原始，不好点击
	CurrencyTransferMenuCloseButton:SetFrameStrata('HIGH')

	hooksecurefunc(CurrencyTransferMenu.SourceSelector, 'RefreshPlayerName', function(self)--收取人，我 提示		
		local name= e.GetPlayerInfo({guid=e.Player.guid, reName=true})
		if name~='' then
			self.PlayerName:SetFormattedText(e.onlyChinese and '收取人 %s' or CURRENCY_TRANSFER_DESTINATION, name)
		end
	end)

	hooksecurefunc(CurrencyTransferMenu.SourceBalancePreview, 'SetCharacterName', function(self)
		local data= self:GetParent().sourceCharacterData or {}
		local name= e.GetPlayerInfo({guid=data.characterGUID, reName=true, reRealm=true})
		if name~='' then
			self.Label:SetFormattedText(e.onlyChinese and '%s |cnRED_FONT_COLOR:的新余额|r' or CURRENCY_TRANSFER_NEW_BALANCE_PREVIEW, name)
		end
    end)
    hooksecurefunc(CurrencyTransferMenu.PlayerBalancePreview, 'SetCharacterName', function(self)
		local name= e.GetPlayerInfo({guid=e.Player.guid, reName=true, reRealm=true})
		if name~='' then
			self.Label:SetFormattedText(e.onlyChinese and '%s |cnGREEN_FONT_COLOR:的新余额|r' or CURRENCY_TRANSFER_NEW_BALANCE_PREVIEW, name)
		end
    end)

	--可能会出现错误
		CurrencyTransferMenu.AmountSelector.InputBox:HookScript('OnTextChanged', function(self, userInput)
			if userInput then
				e.call(self.ValidateAndSetValue, self)
			end
		end)

	CurrencyTransferMenu.SourceBalancePreview.BalanceInfo.Amount:SetTextColor(1,0,0)
	CurrencyTransferMenu.PlayerBalancePreview.BalanceInfo.Amount:SetTextColor(0,1,0)
end













--######
--初始化
--######
local function Init()
	Button= e.Cbtn(TokenFrame, {icon='hide', size={22,22}})
	Button:SetPoint("RIGHT", TokenFrame.CurrencyTransferLogToggleButton, 'LEFT',-2,0)
	Button.texture= Button:CreateTexture()
	Button.texture:SetAllPoints()
	Button.texture:SetAlpha(0.5)

	Button.bagButton= e.Cbtn(ContainerFrameCombinedBags, {icon='hide', size={18,18, name='WoWToolsTokensTrackItemBagButton'}})--背包中, 增加一个图标, 用来添加或移除
	if _G['MoveZoomInButtonPerContainerFrameCombinedBags'] then
        Button.bagButton:SetPoint('LEFT', _G['MoveZoomInButtonPerContainerFrameCombinedBags'], 'RIGHT')
    else
        Button.bagButton:SetPoint('RIGHT', ContainerFrameCombinedBags.CloseButton, 'LEFT',-4,0)
    end
	Button.bagButton:SetFrameStrata('HIGH')
	Button.bagButton.texture= Button.bagButton:CreateTexture()
	Button.bagButton.texture:SetAllPoints()
	Button.bagButton.texture:SetAlpha(0.5)

	function Button:set_bagButtonTexture(icon)--设置,按钮, 图标
		if icon then
			self.texture:SetTexture(icon)
			self.bagButton.texture:SetTexture(icon)
		elseif Save.Hide then
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
			Save.item[itemID]= not Save.item[itemID] and true or nil
			print(id, Initializer:GetName(), e.onlyChinese and '追踪' or TRACKING,
					Save.item[itemID] and
					('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', e.Icon.select))
					or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a'),
					itemLink or itemID)
			ClearCursor()
			Set_TrackButton_Text()
		else
			if not Button.Menu then
				Button.Menu=CreateFrame("Frame", nil, Button, "UIDropDownMenuTemplate")
				e.LibDD:UIDropDownMenu_Initialize(Button.Menu, InitMenu, 'MENU')
			end
			e.LibDD:ToggleDropDownMenu(1, nil, Button.Menu, self, 15, 0)
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
					Save.item[itemID] and
						('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a')
					or ('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', e.Icon.select))
			)
			Button:set_bagButtonTexture(C_Item.GetItemIconByID(itemID))
		else
			e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.left)
			e.tips:AddDoubleLine((e.onlyChinese and '拖曳' or DRAG_MODEL)..e.Icon.left..(e.onlyChinese and '物品' or ITEMS), e.onlyChinese and '追踪' or TRACKING)
		end
		e.tips:AddLine(' ')

		e.tips:AddDoubleLine(id, Initializer:GetName())
		e.tips:Show()
		self.texture:SetAlpha(1)
		Set_TrackButton_Pushed(true)--提示
	end

	local function leave(self)
		e.tips:Hide()
		Button:set_bagButtonTexture()
		self.texture:SetAlpha(0.5)
		Set_TrackButton_Pushed(false)--提示
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
	Button.down= e.Cbtn(Button, {size={22,22}, atlas='NPE_ArrowDown'})--texture='Interface\\Buttons\\UI-MinusButton-Up'})--展开所有
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
		e.tips:AddDoubleLine(id, Initializer:GetName())
		e.tips:Show()
	end)

	Button.up= e.Cbtn(Button, {size={22,22}, atlas='NPE_ArrowUp'})--texture='Interface\\Buttons\\UI-PlusButton-Up'})--收起所有
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
		e.tips:AddDoubleLine(id, Initializer:GetName())
		e.tips:Show()
	end)

	Button.bag=e.Cbtn(Button, {icon='hide', size={18,18}})
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
			local info, num, total, percent, isMax, canWeek, canEarned, canQuantity= e.GetCurrencyMaxInfo(curID, nil)
			if info and isMax then
				tab[info.currencyID]= info.link
			end
		else
			for currencyID, _ in pairs(Save.tokens) do
				if not self.currencyMax[currencyID] then
					local info, _, total, percent, isMax, canWeek, canEarned, canQuantity= e.GetCurrencyMaxInfo(currencyID, nil)
					if info and isMax then
						tab[currencyID]= info.link
					end
				end
			end
			for i=1, C_CurrencyInfo.GetCurrencyListSize() do
				local info, num, total, percent, isMax, canWeek, canEarned, canQuantity= e.GetCurrencyMaxInfo(nil, i)
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
			print(id, Initializer:GetName(), text, '|r|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已达到资源上限' or SPELL_FAILED_CUSTOM_ERROR_248))
		end
	end

	function Button:set_Event()
		if Save.hideCurrencyMax then
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



	Init_Currency_Transfer()--货币，转移

	
	C_Timer.After(4, function()
		Init_TrackButton()
		
			hooksecurefunc(TokenFrame, 'Update', function(self)
				set_ItemInteractionFrame_Currency(self)--套装,转换,货币
				Set_TrackButton_Text()
			end)
			hooksecurefunc(TokenFrame.ScrollBox, 'Update', function(f)
				if f:GetView() then
					return
				end
				for _, frame in pairs(f:GetFrames() or {}) do
					set_Tokens_Button(frame)--设置, 列表, 内容
				end
			end)

		

		if not Save.hideCurrencyMax then
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
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
		if arg1==id then
            Save= WoWToolsSave[addName] or Save
			Save.tokens= Save.tokens or {}
			Save.item= Save.item or {}

			--添加控制面板
			Initializer= e.AddPanel_Check({
				name= '|A:bags-junkcoin:0:0|a'..(e.onlyChinese and '货币' or addName),
				tooltip= addName,
				value= not Save.disabled,
				func= function()
					Save.disabled= not Save.disabled and true or nil
					print(id, Initializer:GetName(), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
				end
			})


            if Save.disabled then
                panel:UnregisterAllEvents()
            else
				Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

		elseif arg1=='Blizzard_ItemInteractionUI' then
            hooksecurefunc(ItemInteractionFrame, 'SetupChargeCurrency', set_ItemInteractionFrame_Currency)

		--[[elseif arg1=='Blizzard_TokenUI' then
			hooksecurefunc(TokenEntryMixin, 'OnEnter', function(frame)--角色栏,声望
				for _, btn in pairs(TrackButton and TrackButton.btn or {}) do
					if frame.check and frame.check.currencyID and frame.check.currencyID== btn.currencyID then
						btn:SetScale(2)
					else
						btn:SetScale(1)
					end
				end
			end)
			hooksecurefunc(TokenEntryMixin, 'OnLeave', function(frame)--角色栏,声望
				for _, btn in pairs(TrackButton and TrackButton.btn or {}) do
					btn:SetScale(1)
				end
			end)]]
		end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
	end
end)