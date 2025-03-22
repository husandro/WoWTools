local e= select(2, ...)

local function Save()
    return WoWTools_CurrencyMixin.Save
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
	local num= C_Item.GetItemCount(itemID , true, true, true, true)
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
			max= WoWTools_CurrencyMixin:GetAccountIcon(currencyID or info.currencyID, index) or '|A:quest-important-available:0:0|a'
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























function WoWTools_CurrencyMixin:Set_TrackButton_Pushed(show, label)--提示
    if self.TrackButton then
		self.TrackButton:SetButtonState(show and 'PUSHED' or "NORMAL")
	end
	if label then
		label:SetAlpha(show and 0.5 or 1)
	end
end















local function Create_Button(last, index, endTokenIndex, itemButtonUse, tables)
    local btn= WoWTools_ButtonMixin:Cbtn(WoWTools_CurrencyMixin.TrackButton.Frame, {
		size=14,
		isSecure=itemButtonUse,
		isType2=itemButtonUse
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
        btn:SetPoint("BOTTOM", last or WoWTools_CurrencyMixin.TrackButton, 'TOP', 0,  (endTokenIndex>1 and index==endTokenIndex) and 10 or 0) --货物，物品，分开
    else
        btn:SetPoint("TOP", last or WoWTools_CurrencyMixin.TrackButton, 'BOTTOM', 0,  (endTokenIndex>1 and index==endTokenIndex) and -10 or 0) --货物，物品，分开
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
            local col= C_Item.GetItemCount(self.itemID)==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:'
            if self.itemButtonUse then
                GameTooltip:AddDoubleLine(col..(e.onlyChinese and '使用物品' or USE_ITEM), e.Icon.left)
            end
            GameTooltip:AddDoubleLine(col..(e.onlyChinese and '拿取' or 'Pickup'), col..('Alt+'..e.Icon.left))
            WoWTools_BagMixin:Find(true, {itemID=self.itemID})--查询，背包里物品
        elseif self.currencyID then
            GameTooltip:SetCurrencyByID(self.currencyID)
            local link= C_CurrencyInfo.GetCurrencyLink(self.currencyID) or (e.onlyChinese and '超链接' or COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK)
            GameTooltip:AddDoubleLine(link..'|A:transmog-icon-chat:0:0|a', e.Icon.left)
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
        WoWTools_CooldownMixin:SetFrame(self, {item=self.itemID, type= self.itemButtonUs })
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
		WoWTools_CooldownMixin:Setup(self)
        self:UnregisterEvent('BAG_UPDATE_COOLDOWN')
    end)
    btn:set_btn_Event()

    if itemButtonUse then--使用物品
        btn:SetAttribute('type', 'item')
    end
    btn.itemButtonUse= itemButtonUse--使用物品

    WoWTools_CurrencyMixin.TrackButton.btn[index]= btn
    return btn
end
















function WoWTools_CurrencyMixin:Set_TrackButton_Text()
	if not self.TrackButton then
        return
    elseif not self.TrackButton:IsShown() or not Save().str then
		self.TrackButton.Frame:set_shown()
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
			self.TrackButton.Frame:RegisterEvent('PLAYER_REGEN_ENABLED')
		end
	end

	local last,size

	for index, tables in pairs(tab) do
        local itemButtonUse=(Save().itemButtonUse and tables.itemID) and true or nil--使用物品
		local btn= self.TrackButton.btn[index] or Create_Button(last, index, endTokenIndex, itemButtonUse, tables)
		
		size= itemButtonUse and 22 or 14
		btn:SetSize(size, size)


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

	if self.TrackButton.endTokenIndex and self.TrackButton.endTokenIndex~= endTokenIndex then--货物，物品，分开
		last=nil
		for i= 1, #self.TrackButton.btn do
			local btn= self.TrackButton.btn[i]
			if btn and btn:CanChangeAttribute() then
				btn:ClearAllPoints()
				if endTokenIndex>1 and i==endTokenIndex then--货物，物品，分开
					btn:SetPoint("TOP", last or self.TrackButton, 'BOTTOM',0, -10)
				else
					btn:SetPoint("TOP", last or self.TrackButton, 'BOTTOM',0, -1)
				end
				last=btn
			end
		end
	end
	self.TrackButton.endTokenIndex= endTokenIndex


	for i= #tab+1, #self.TrackButton.btn do--隐藏，多余
		local btn= self.TrackButton.btn[i]
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















