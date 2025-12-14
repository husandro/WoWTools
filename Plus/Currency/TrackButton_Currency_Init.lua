

local function Save()
    return WoWToolsSave['Currency2']
end
local TrackButton, Frame
local Name='WoWToolsCurrencyTrackButton'
local NumButton=0




























--圆形 11.1.5
local qualityToIconBorderAtlas = AUCTION_HOUSE_ITEM_QUALITY_ICON_BORDER_ATLASES  or {
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
	local icon= select(5, C_Item.GetItemInfoInstant(itemID))
	local num= C_Item.GetItemCount(itemID , true, true, true, true)
	local bag= C_Item.GetItemCount(itemID)
	local itemQuality
	if icon and num>0 then

		itemQuality = C_Item.GetItemQualityByID(itemID)

		local numText
		if bag==num then
			numText= WoWTools_DataMixin:MK(num, 3)
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

		name= WoWTools_TextMixin:CN(C_Item.GetItemNameByID(itemID)) or ''

		local nameText= WoWTools_ItemMixin:GetColor(itemQuality, {text= Save().nameShow and name or numText})

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

	currencyID= currencyID or (info and info.currencyID)

    if not info
		or not currencyID
		or info.isHeader
		or not info.iconFileID
		or (info.quantity==0 and not (canWeek or canEarned or canQuantity))
	then
		return
    end

    local name

	if Save().nameShow and info.name then
		name= WoWTools_TextMixin:CN(info.name)
		if C_CurrencyInfo.IsAccountTransferableCurrency(currencyID) then
			name= '|cff00d1ff'..name..'|r'
		else
			name= WoWTools_ItemMixin:GetColor(info.quality, {text=name})
		end
	end


	local need
	if percent then
		need= format('(%d%%)', percent)
	end

	local num= WoWTools_DataMixin:MK(num2, 3)

	local max
	if isMax then
			max= WoWTools_CurrencyMixin:GetAccountIcon(currencyID or info.currencyID, index) or '|A:quest-important-available:0:0|a'
		num= '|cnWARNING_FONT_COLOR:'..num..'|r'
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























function WoWTools_CurrencyMixin:Set_TrackButton_Pushed(show, label)--提示
    if TrackButton then
		TrackButton:SetButtonState(show and 'PUSHED' or "NORMAL")
	end
	if label then
		label:SetAlpha(show and 0.5 or 1)
	end
end















local function Create_Button(index, endTokenIndex, itemButtonUse, tables)
    local btn= WoWTools_ButtonMixin:Cbtn(Frame, {
		size=14,
		isSecure=itemButtonUse,
		isType2=itemButtonUse,

		name=Name..index
	})
    btn.itemButtonUse= itemButtonUse

    if itemButtonUse then
		if not btn.texture then
			btn.texture= btn:CreateTexture(nil,'BORDER')
			btn.texture:SetSize(14,14)
			btn.texture:SetPoint('CENTER',-0.5,0.5)
			btn.border=btn:CreateTexture(nil, 'ARTWORK')
			btn.border:SetSize(18,18)
			btn.border:SetPoint('CENTER',-0.5,0.3)
		end

    elseif tables.itemID then
		if not btn.border then
			btn.border=btn:CreateTexture(nil, 'ARTWORK')
			btn.border:SetAllPoints()
		end
    end



    btn.text= WoWTools_LabelMixin:Create(btn, {color={r=1,g=1,b=1}})


    if Save().toTopTrack then
        btn:SetPoint("BOTTOM", _G[Name..(index-1)] or TrackButton, 'TOP', 0,  (endTokenIndex>1 and index==endTokenIndex) and 10 or 0) --货物，物品，分开
    else
        btn:SetPoint("TOP", _G[Name..(index-1)] or TrackButton, 'BOTTOM', 0,  (endTokenIndex>1 and index==endTokenIndex) and -10 or 0) --货物，物品，分开
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
        GameTooltip:Hide()
        WoWTools_CurrencyMixin:Set_TrackButton_Pushed(false, self.text)--提示
        if self.itemID then
            WoWTools_BagMixin:Find(false)--查询，背包里物品
		elseif self.currencyID then
			WoWTools_CurrencyMixin:Find(nil, nil)--选中提示
		end
    end)

    btn:SetScript('OnEnter', function(self)
        if Save().toRightTrackText then
            GameTooltip:SetOwner(self.text, "ANCHOR_RIGHT")
        else
            GameTooltip:SetOwner(self.text, "ANCHOR_LEFT")
        end
        GameTooltip:ClearLines()
        if self.itemID then
            GameTooltip:SetItemByID(self.itemID)
            GameTooltip:AddLine(' ')
            local col= C_Item.GetItemCount(self.itemID)==0 and '|cff626262' or '|cnGREEN_FONT_COLOR:'
            if self.itemButtonUse then
                GameTooltip:AddDoubleLine(col..(WoWTools_DataMixin.onlyChinese and '使用物品' or USE_ITEM), WoWTools_DataMixin.Icon.left)
            end
            GameTooltip:AddDoubleLine(col..(WoWTools_DataMixin.onlyChinese and '拿取' or 'Pickup'), col..('Alt+'..WoWTools_DataMixin.Icon.left))
            WoWTools_BagMixin:Find(true, {itemID=self.itemID})--查询，背包里物品
        elseif self.currencyID then
            GameTooltip:SetCurrencyByID(self.currencyID)
            local link= C_CurrencyInfo.GetCurrencyLink(self.currencyID) or (WoWTools_DataMixin.onlyChinese and '超链接' or COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK)
            GameTooltip:AddDoubleLine(link..'|A:transmog-icon-chat:0:0|a', WoWTools_DataMixin.Icon.left)
			WoWTools_CurrencyMixin:Find(self.currencyID, nil)--选中提示

        elseif self.index then
            GameTooltip:SetCurrencyToken(self.index)
        end
        GameTooltip:Show()
		self:set_item_cool()
        WoWTools_CurrencyMixin:Set_TrackButton_Pushed(true, self.text)--提示
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
        WoWTools_CooldownMixin:SetFrame(self, {itemID=self.itemID, type= self.itemButtonUs })
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
		--WoWTools_CooldownMixin:Setup(self)
        self:UnregisterEvent('BAG_UPDATE_COOLDOWN')
    end)
    btn:set_btn_Event()

    if itemButtonUse then--使用物品
        btn:SetAttribute('type', 'item')
    end
    btn.itemButtonUse= itemButtonUse--使用物品

    NumButton= index

	TrackButton.NumButton= NumButton

    return btn
end
















function WoWTools_CurrencyMixin:Set_TrackButton_Text()
	if not TrackButton then
        return
    elseif not TrackButton:IsShown() or not Save().str then
		Frame:set_shown()
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
			Frame:RegisterEvent('PLAYER_REGEN_ENABLED')
		end
	end

	local size

	for index, tables in pairs(tab) do
        local itemButtonUse=(Save().itemButtonUse and tables.itemID) and true or nil--使用物品
		local btn= _G[Name..index] or Create_Button(index, endTokenIndex, itemButtonUse, tables)

		size= itemButtonUse and 22 or 14
		btn:SetSize(size, size)


		btn.itemID= tables.itemID
		btn.index= tables.index
		btn.name= tables.name
		btn.currencyID= tables.currencyID

		local can= btn:CanChangeAttribute()

		if btn.texture then
			--SetPortraitToTexture(btn.texture, tables.icon)
			btn.texture:SetTexture(tables.icon or 0)
		else
			btn:SetNormalTexture(tables.icon or 0)--设置，图片
		end
		if btn.border then
			local atlas= btn.itemButtonUse and qualityToIconBorderAtlas[tables.itemQuality] or WoWTools_DataMixin.Icon[tables.itemQuality]--qualityToIconBorderAtlas4[tables.itemQuality]
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
	end

	if TrackButton.endTokenIndex and TrackButton.endTokenIndex~= endTokenIndex then--货物，物品，分开
		for i= 1, NumButton do
			local btn= _G[Name..i]
			if btn and btn:CanChangeAttribute() then
				btn:ClearAllPoints()
				if endTokenIndex>1 and i==endTokenIndex then--货物，物品，分开
					btn:SetPoint("TOP", _G[Name..(i-1)] or TrackButton, 'BOTTOM',0, -10)
				else
					btn:SetPoint("TOP", _G[Name..(i-1)] or TrackButton, 'BOTTOM',0, -1)
				end
			end
		end
	end
	TrackButton.endTokenIndex= endTokenIndex


	for i= #tab+1, NumButton do--隐藏，多余
		local btn= _G[Name..i]
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
	if Save().Hide then
		return
	end


	TrackButton= WoWTools_ButtonMixin:Cbtn(nil, {name='WoWToolsCurrencyTrackMainButton', size=23})



	TrackButton.texture= TrackButton:CreateTexture(nil, 'BORDER')

    TrackButton.texture:SetPoint('CENTER')
    TrackButton.texture:SetSize(12,10)

	function TrackButton:set_point()
		self:ClearAllPoints()
		if Save().point then
			self:SetPoint(Save().point[1], UIParent, Save().point[3], Save().point[4], Save().point[5])
		else
			self:SetPoint('TOPLEFT', 200, WoWTools_DataMixin.Player.husandro and 0 or -100)
		end
	end

	function TrackButton:set_texture(icon)
		if icon and icon>0 then
			self.texture:SetTexture(icon)
			self.texture:SetPoint('TOPLEFT',0,0)
			self.texture:SetPoint('BOTTOMRIGHT',0,0)
		else
			self.texture:SetAtlas('Adventure-MissionEnd-Line')
			self.texture:SetPoint('TOPLEFT', 6,-6)
			self.texture:SetPoint('BOTTOMRIGHT',-6,6)
			self.texture:SetAlpha(Save().str and 0.3 or 0.7)
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
		if Frame:CanChangeAttribute() then
			Frame:SetScale(Save().scaleTrackButton or 1)
		end
	end



	function TrackButton:set_Tooltip()
		if Save().toRightTrackText then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		else
			GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		end
		GameTooltip:ClearLines()

		local infoType, itemID, itemLink = GetCursorInfo()
		if infoType=='item' and itemID then
			GameTooltip:SetItemByID(itemID)
			GameTooltip:AddLine(' ')
			GameTooltip:AddDoubleLine(itemLink or ('itemID'..itemID),
					Save().item[itemID] and
						('|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a')
					or ('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', 'common-icon-checkmark'))
			)
			self:set_texture(select(5, C_Item.GetItemInfoInstant(itemID)))
		else
			local canFrame= Frame:CanChangeAttribute() and '|cnGREEN_FONT_COLOR:' or ''
			GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_CurrencyMixin.addName)
			GameTooltip:AddLine(' ')
			GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '打开/关闭货币页面' or BINDING_NAME_TOGGLECURRENCY, WoWTools_DataMixin.Icon.left)
			GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU), WoWTools_DataMixin.Icon.right)
			GameTooltip:AddDoubleLine(canFrame..(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE), 'Atl+'..WoWTools_DataMixin.Icon.right)
			GameTooltip:AddDoubleLine(WoWTools_TextMixin:GetShowHide(Save().str, true), WoWTools_DataMixin.Icon.mid)
			GameTooltip:AddLine(' ')
			GameTooltip:AddDoubleLine(canFrame..(WoWTools_DataMixin.onlyChinese and '拖曳' or DRAG_MODEL)..WoWTools_DataMixin.Icon.left..(WoWTools_DataMixin.onlyChinese and '物品' or ITEMS), WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING)
		end
		GameTooltip:Show()
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
        if WoWTools_FrameMixin:IsInSchermo(self) then
			Save().point={self:GetPoint(1)}
			Save().point[2]=nil
        end
	end)
	TrackButton:SetScript("OnMouseUp", ResetCursor)

	TrackButton:SetScript("OnMouseDown", function(self, d)
		if d=='RightButton' and IsAltKeyDown() then--右击,移动
			SetCursor('UI_MOVE_CURSOR')
			return
		end

		local infoType, itemID, itemLink = GetCursorInfo()
        if infoType == "item" and itemID then
			Save().item[itemID]= not Save().item[itemID] and true or nil
			print(
				WoWTools_CurrencyMixin.addName..WoWTools_DataMixin.Icon.icon2,
				WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING,

				Save().item[itemID] and
				('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', 'common-icon-checkmark'))
				or ('|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a'),

				itemLink or itemID
			)
			ClearCursor()
			WoWTools_CurrencyMixin:Set_TrackButton_Text()

		elseif d=='LeftButton' and not IsModifierKeyDown() then
			ToggleCharacter("TokenFrame")--打开货币

		elseif d=='RightButton' and not IsModifierKeyDown() then
			WoWTools_CurrencyMixin:Init_Menu(self)
			--WoWTools_CurrencyMixin:Init_TrackButton_Menu(self)
		end
	end)


	TrackButton:SetScript("OnEnter", function(self)
		if (Save().itemButtonUse and not UnitAffectingCombat('player')) or not Save().itemButtonUse then
			WoWTools_CurrencyMixin:Set_TrackButton_Text()
			self:set_shown()
		end
		self:set_Tooltip()
		self.texture:SetAlpha(1)
	end)
	TrackButton:SetScript('OnMouseUp', ResetCursor)
	TrackButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
		self:set_texture()
	end)
	TrackButton:SetScript('OnMouseWheel', function(self, d)
		if Save().itemButtonUse and not UnitAffectingCombat('player') or not Save().itemButtonUse then
			Save().str= d==-1
			self:set_texture()
			Frame:set_shown()
			self:set_Tooltip()
		end
	end)









	Frame= CreateFrame('Frame', 'WoWToolsCurrencyTrackMainFrame', TrackButton)
	Frame:SetSize(1,1)
	Frame:SetPoint('BOTTOM')



	Frame:SetScript('OnShow', function()
		WoWTools_CurrencyMixin:Set_TrackButton_Text()
	end)

	Frame:RegisterEvent('BAG_UPDATE_DELAYED')
	Frame:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
	Frame:SetScript('OnEvent', function(self, event)
		if event=='PLAYER_REGEN_ENABLED' then
			self:UnregisterEvent('PLAYER_REGEN_ENABLED')
		end
		WoWTools_CurrencyMixin:Set_TrackButton_Text()
	end)
	function Frame:set_shown()
		if Save().itemButtonUse and not UnitAffectingCombat('player') or not Save().itemButtonUse then
			self:SetShown(Save().str)
		end
	end
	Frame:set_shown()

	function TrackButton:set_strata()
        self:SetFrameStrata(Save().strata or 'MEDIUM')
    end
	TrackButton:set_strata()
	TrackButton:set_point()
	TrackButton:set_scale()
	TrackButton:set_event()
	TrackButton:set_shown()
	TrackButton:set_texture()


	WoWTools_CurrencyMixin:Set_TrackButton_Text()

	WoWTools_DataMixin:Hook(TokenFrame, 'Update', function()
		if TrackButton then
			WoWTools_CurrencyMixin:Set_TrackButton_Text()
		else
			WoWTools_CurrencyMixin:Init_TrackButton()
		end
	end)



	Init_TrackButton=function()
		TrackButton:set_event()
		TrackButton:set_shown()
	end
end







































function WoWTools_CurrencyMixin:Init_TrackButton()
    Init_TrackButton()
end

