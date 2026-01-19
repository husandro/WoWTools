

local function Save()
    return WoWToolsSave['Currency2']
end
local TrackButton, Frame







--物品，菜单
local function MenuList_Item(self, root)
	local sub, sub2
	sub=root:CreateCheckbox(
		(Save().Hide and '|cff626262' or'')..(WoWTools_DataMixin.onlyChinese and '物品' or ITEMS),
	function ()
		return not Save().disabledItemTrack
	end, function()
		Save().disabledItemTrack = not Save().disabledItemTrack and true or nil
		self:settings()
	end)


	local itemTab={}
	for itemID in pairs(Save().item  or {}) do
		table.insert(itemTab, {
			itemID= itemID,
			itemQuality=C_Item.GetItemQualityByID(itemID) or 0
		})
	end
	table.sort(itemTab, function(a, b)
		if a.itemQuality== b.itemQuality then
			return a.itemID> b.itemID
		else
			return a.itemQuality> b.itemQuality
		end
	end)

	for _, info in pairs(itemTab) do
		sub2=sub:CreateCheckbox(
			WoWTools_ItemMixin:GetName(info.itemID),
		function(data)
			return Save().item[data.itemID]
		end, function(data)
			Save().item[data.itemID]= not Save().item[data.itemID] and true or nil
			self:settings()
		end, {itemID=info.itemID})
		WoWTools_SetTooltipMixin:Set_Menu(sub2)
	end

	sub:SetData({rightText=#itemTab})
	WoWTools_MenuMixin:SetRightText(sub)



--全部清除
	sub:CreateDivider()
	WoWTools_MenuMixin:ClearAll(sub, function()
		Save().item={}
		self:settings()
	end)




--使用物品
	sub2=sub:CreateCheckbox(
		WARNING_FONT_COLOR:WrapTextInColorCode(WoWTools_DataMixin.onlyChinese and '使用物品' or USE_ITEM),
	function()
		return Save().itemButtonUse
	end, function()
		Save().itemButtonUse= not Save().itemButtonUse and true or nil
	end)
	sub2:SetTooltip(function(tooltip)
		tooltip:AddLine('SecureActionButton')
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '提示: 可能会出现错误' or (LABEL_NOTE..': '..ENABLE_ERROR_SPEECH))
	end)

	WoWTools_MenuMixin:SetScrollMode(sub)
end
























--指定货币
local function Init_CurrencyMenu(self, root)
	local  sub, sub2

	sub=root:CreateCheckbox(
		(WoWTools_DataMixin.onlyChinese and '指定货币' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMBAT_ALLY_START_MISSION, TOKENS)),
	function()
		return Save().indicato
	end, function()
		Save().indicato= not Save().indicato and true or nil
		self:settings()
		TokenFrame:Update()
	end)


	local tab={}
	for currencyID in pairs(Save().tokens) do
		table.insert(tab, currencyID)
	end
	table.sort(tab, function(a, b) return a.currencyID> b.currencyID end)

	for _, currencyID in pairs(tab) do
		sub2=sub:CreateCheckbox(
			WoWTools_CurrencyMixin:GetName(currencyID, nil, nil) or currencyID,
		function(data)
			return Save().tokens[data.currencyID]

		end, function(data)
			Save().tokens[data.currencyID]= not Save().tokens[data.currencyID] and true or nil
			TokenFrame:Update()
			self:settings()
		end, {currencyID=currencyID})

		sub2:SetTooltip(function(tooltip, description)
			tooltip:SetCurrencyByID(description.data.currencyID)
			WoWTools_CurrencyMixin:Find(description.data.currencyID, nil)--选中提示
		end)
		sub2:SetOnLeave(function()
			WoWTools_CurrencyMixin:Find(nil, nil)--选中提示
			GameTooltip:Hide()
		end)
	end

	sub:SetData({rightText=#tab})
	WoWTools_MenuMixin:SetRightText(sub)

--添加
	sub:CreateDivider()
	sub:CreateButton(
		WoWTools_DataMixin.onlyChinese and '添加' or ADD,
	function()
		StaticPopup_Show('WoWTools_Currency', nil, nil, {
		GetValue=function()
		end, CheckValue=function(button1, currencyID)
			button1:SetText(
				Save().tokens[currencyID] and (WoWTools_DataMixin.onlyChinese and '更新' or UPDATE)
				or (WoWTools_DataMixin.onlyChinese and '添加' or ADD)
			)
		end, SetValue=function(currencyID)
			Save().tokens[currencyID]=true
			self:settings()
		end})
	end)


--全部清除
	sub:CreateDivider()
	WoWTools_MenuMixin:ClearAll(sub, function()
		Save().tokens={}
		self:settings()
		TokenFrame:Update()
	end)

	WoWTools_MenuMixin:SetScrollMode(sub)
end















--追踪
local function Init_Menu(self, root)

    local sub

--显示
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '显示' or SHOW,
    function()
        return Save().str
    end, function ()
		Save().str= not Save().str and true or false
		self:settings()
    end)
	--自动隐藏
	sub=sub:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '自动隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE),
	function()
		return not Save().notAutoHideTrack
	end, function()
		Save().notAutoHideTrack= not Save().notAutoHideTrack and true or nil
		self:settings()
	end)
	sub:SetTooltip(function(tooltip)
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE)
		tooltip:AddLine(' ')
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '宠物对战' or SHOW_PET_BATTLES_ON_MAP_TEXT)
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '在副本中' or AGGRO_WARNING_IN_INSTANCE)
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '载具控制' or BINDING_HEADER_VEHICLE)
	end)

	Init_CurrencyMenu(self, root)

--物品
	MenuList_Item(self, root)


--重置位置
	root:CreateDivider()
	sub = WoWTools_MenuMixin:RestPoint(self, root, Save().point, function()
		Save().point=nil
		self:settings()
	end)











	
--显示名称
    sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '显示名称' or PROFESSIONS_FLYOUT_SHOW_NAME,
    function ()
        return Save().nameShow
    end, function ()
        Save().nameShow= not Save().nameShow and true or nil
        self:settings()
    end)

--向右平移
    sub:CreateCheckbox(
        (WoWTools_DataMixin.onlyChinese and '向右平移' or BINDING_NAME_STRAFERIGHT),
    function ()
        return Save().toRightTrackText
    end, function ()
        Save().toRightTrackText = not Save().toRightTrackText and true or false
        self:settings()
    end)


--上
    sub:CreateCheckbox(
        (WoWTools_DataMixin.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP)..'|A:bags-greenarrow:0:0|a',
    function ()
        return Save().toTopTrack
    end, function ()
        Save().toTopTrack = not Save().toTopTrack and true or nil
		self:settings()
    end)

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().scaleTrackButton
    end, function(value)
        Save().scaleTrackButton= value
        self:settings()
    end)

--FrameStrata
    WoWTools_MenuMixin:FrameStrata(self, sub, function(data)
		if _G['WoWToolsCurrencyTrackMainButton'] then
			return _G['WoWToolsCurrencyTrackMainButton']:GetFrameStrata()==data
		else
			return Save().strata== data
		end
    end, function(data)
        Save().strata= data
        self:settings()
    end)

--背景, 透明度
	WoWTools_MenuMixin:BgAplha(sub,
	function()--GetValue
		return Save().trackBgAlpha or 0.5
	end, function(value)--SetValue
		Save().trackBgAlpha= value
		self:settings()
	end, function()--RestFunc
		Save().bgAlpha= nil
		self:settings()
	end)--onlyRoot





--重新加载UI
	sub:CreateDivider()
	WoWTools_MenuMixin:Reload(sub)
end

























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
	WoWTools_DataMixin:Load(itemID, 'item')

	local text
	local icon= select(5, C_Item.GetItemInfoInstant(itemID))
	local numText= WoWTools_ItemMixin:GetCount(itemID, {notZero=true})
	--local num= C_Item.GetItemCount(itemID , true, true, true, true)
	--local bag= C_Item.GetItemCount(itemID)
	local name= C_Item.GetItemNameByID(itemID)
	local itemQuality
	--if num>0 then

		itemQuality = C_Item.GetItemQualityByID(itemID)

		--[[local numText
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
		end]]


		if Save().nameShow then
			text= WoWTools_TextMixin:CN(name, {itemID=itemID, isName=true})
		end

		if text or numText then
			if Save().toRightTrackText then--向右平移
				text=(text or '')..(text and numText and ' ' or '')..(numText or '')
			else
				text=(numText or '')..(text and numText and ' ' or '')..(text or '')
			end
	--设置颜色
			text= WoWTools_ItemMixin:GetColor(itemQuality, {text= text})
		end
	--

	return text, icon, itemQuality, name
end



local function Set_ItemTexture(btn, icon)
	if icon then
		btn.texture:SetTexture(icon or 0)
	else
		ItemEventListener:AddCancelableCallback(btn.itemID, function()
			if btn.itemID then
				Set_ItemTexture(btn, select(5, C_Item.GetItemInfoInstant(btn.itemID)))
			end
		end)
	end
end

local function Set_ItemAttribute(btn)
	ItemEventListener:AddCancelableCallback(btn.itemID, function()
		if btn.itemID then
			if btn:CanChangeAttribute() then
				btn:SetAttribute('item',  C_Item.GetItemNameByID(btn.itemID))
			else
				EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner)
					if btn.itemID then
						btn:SetAttribute('item',  C_Item.GetItemNameByID(btn.itemID))
					end
					EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
				end)
			end
		end
	end)
end









--货币
local function Get_Currency(currencyID, index)
	local info, num2, _, percent, isMax, canWeek, canEarned, canQuantity= WoWTools_CurrencyMixin:GetInfo(currencyID, index)

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
































local function Set_ScripButton(btn)

    btn.text= btn:CreateFontString(nil, 'BORDER', 'GameFontHighlight') -- WoWTools_LabelMixin:Create(btn, {color={r=1,g=1,b=1}})


    btn:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
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

			local notFind= C_Item.GetItemCount(self.itemID, false, false, true, false)==0
            local col= notFind and '|cff626262' or '|cnGREEN_FONT_COLOR:'

            if self.itemButtonUse then
                GameTooltip:AddDoubleLine(col..(WoWTools_DataMixin.onlyChinese and '使用物品' or USE_ITEM), WoWTools_DataMixin.Icon.left)
            end

			col= C_Item.IsEquippedItem(self.itemID) and '|cff626262' or col

            GameTooltip:AddDoubleLine(col..(WoWTools_DataMixin.onlyChinese and '拿取' or 'Pickup'), col..('Alt+'..WoWTools_DataMixin.Icon.left))
            WoWTools_BagMixin:Find(true, {itemID=self.itemID})--查询，背包里物品

        elseif self.currencyID then
            GameTooltip:SetCurrencyByID(self.currencyID)
            local link= C_CurrencyInfo.GetCurrencyLink(self.currencyID) or (WoWTools_DataMixin.onlyChinese and '超链接' or COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK)
            GameTooltip:AddDoubleLine(link..'|A:transmog-icon-chat:0:0|a', WoWTools_DataMixin.Icon.left)
			WoWTools_CurrencyMixin:Find(self.currencyID, nil)--选中提示
        end
        GameTooltip:Show()

    end)

    btn:SetScript("OnMouseDown", function(self)
        if self.currencyID then
            WoWTools_ChatMixin:Chat(C_CurrencyInfo.GetCurrencyLink(self.currencyID), nil, true)
            return
        end

        if not self.itemID or not IsAltKeyDown() or C_Item.GetItemCount(self.itemID)==0 then
			return
		end

		
		local bag, slot= select(2, WoWTools_BagMixin:Ceca(self.itemID, {findAll=true}))
		if bag and slot then
			C_Container.PickupContainerItem(bag, slot)
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
	btn:SetScript('OnEvent', btn.set_item_cool)

	btn:SetScript('OnShow', function(self)
		self:set_item_cool()
		self:set_btn_Event()
	end)
	btn:SetScript('OnHide', function(self)
		self:UnregisterEvent('BAG_UPDATE_COOLDOWN')
	end)

	if btn.itemID then
		if btn.border then
			btn.border:SetAlpha(1)
		elseif not btn.border then
			btn.texture= btn:CreateTexture(nil, 'BORDER')
			btn.texture:SetAllPoints()
			btn.border= btn:CreateTexture(nil, 'ARTWORK')
			btn.border:SetAllPoints()
		end
	end
end





















local function Init_Button()
	if not Frame:IsShown() or WoWTools_FrameMixin:IsLocked(Frame) then
        return
	end

	TrackButton.pool:ReleaseAll()
	TrackButton.itemPool:ReleaseAll()
	TrackButton.itemPool2:ReleaseAll()

	local tab={}
	local bat= InCombatLockdown()

	if Save().indicato then
		for currencyID in pairs(Save().tokens) do
			local text, icon= Get_Currency(currencyID, nil)--货币
			if text then
				table.insert(tab, {text= text, icon=icon, currencyID=currencyID})
			end
		end
		table.sort(tab, function(a, b)
			return a.currencyID> b.currencyID
		end)
	else
		for index=1, C_CurrencyInfo.GetCurrencyListSize() do
			local text, icon, currencyID = Get_Currency(nil, index)--货币
			if text then
				table.insert(tab, {text= text, icon=icon, index=index, currencyID= currencyID})
			end
		end
	end


	if not Save().disabledItemTrack then
		if (Save().itemButtonUse and not bat or not Save().itemButtonUse) then
			local itemTab={}
			for itemID in pairs(Save().item) do
				local text, icon, itemQuality, name= Get_Item(itemID)
				if text then
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

	local bgWidth= 0
	local toTopTrack= Save().toTopTrack
	local toRightTrackText= Save().toRightTrackText
	local last= TrackButton



	for index, tables in pairs(tab) do
		local itemID= tables.itemID
        local itemButtonUse=(Save().itemButtonUse and itemID) and true or nil--使用物品

		local btn
		if itemButtonUse then
			btn= TrackButton.itemPool2:Acquire()
			btn:SetAttribute('type', 'item')
			if tables.name then
				btn:SetAttribute('item',  tables.name)
			else
				Set_ItemAttribute(btn)
			end

		elseif itemID then
			btn= TrackButton.itemPool:Acquire()
		else
			btn= TrackButton.pool:Acquire()
		end


		btn.itemButtonUse= itemButtonUse
		btn.itemID= itemID
		btn.index= index
		btn.name= tables.name
		btn.currencyID= tables.currencyID


		if not btn.text then
			Set_ScripButton(btn)
		end

		if btn.border then
			btn:set_item_cool()
			btn.border:SetAtlas(itemButtonUse and qualityToIconBorderAtlas[tables.itemQuality] or WoWTools_DataMixin.Icon[tables.itemQuality] or WoWTools_DataMixin.Icon[1])
			Set_ItemTexture(btn, tables.icon)
		else
			btn:SetNormalTexture(tables.icon or 0)
		end

		btn.text:SetText(tables.text)--设置，文本


		local y= (not last.itemID and btn.itemID) and 10 or 0
		if toTopTrack then
			btn:SetPoint("BOTTOM", last, 'TOP', 0,  y)
		else
			btn:SetPoint("TOP", last, 'BOTTOM', 0,  -y)
		end

		btn.text:ClearAllPoints()
 		if toRightTrackText then
            btn.text:SetPoint('LEFT', btn, 'RIGHT')
        else
            btn.text:SetPoint('RIGHT', btn, 'LEFT')
        end

		bgWidth= math.max(btn.text:GetStringWidth() + 23, bgWidth)
		btn:Show()
		last= btn
	end

	--TrackButton.numButton= #tab
	--TrackButton.bgWidth= bgWidth
	--TrackButton:set_bg()
end




































local function Init()
	if Save().Hide then
		return
	end

	TrackButton= CreateFrame('Button', 'WoWToolsCurrencyTrackMainButton', UIParent, 'WoWToolsButtonTemplate')

	Frame= CreateFrame('Frame', 'WoWToolsCurrencyTrackMainFrame', TrackButton)

	TrackButton.pool= CreateFramePool('Button', Frame, 'WoWToolsButtonTemplate')
	TrackButton.itemPool= CreateFramePool('Button', Frame, 'WoWToolsButtonTemplate')
    TrackButton.itemPool2= CreateFramePool('Button', Frame, 'WoWToolsButton2Template SecureActionButtonTemplate')


	Frame:SetSize(1, 1)
	Frame:SetPoint('CENTER')
	Frame:Hide()

	Frame:SetScript('OnShow', function(self)
		self:RegisterEvent('BAG_UPDATE_DELAYED')
		self:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
		Init_Button()
	end)



	Frame:SetScript('OnEvent', function(self, event)
		if event=='PLAYER_REGEN_ENABLED' then
			self:UnregisterEvent('PLAYER_REGEN_ENABLED')
		end
		if self:IsShown() then
			Init_Button()
		end
	end)

	TrackButton.Bg= Frame:CreateTexture(nil, "BACKGROUND")

	TrackButton.bgWidth=0
	function TrackButton:set_bgalpha()
		self.Bg:SetColorTexture(0, 0, 0, Save().trackBgAlpha or 0.5)
	end
	function TrackButton:set_bg()
		--[[if self.numButton==0 then
			self.Bg:SetShown(false)
			return
		end
		self.Bg:ClearAllPoints()
		if Save().toTopTrack then
			if Save().toRightTrackText then
				self.Bg:SetPoint("TOPLEFT", _G[Name..self.numButton], -1, 1)
				self.Bg:SetPoint('BOTTOMLEFT', _G[Name..1], -1, -1)
			else
				self.Bg:SetPoint("TOPRIGHT", _G[Name..self.numButton], 1, 1)
				self.Bg:SetPoint('BOTTOMRIGHT', _G[Name..1], 1, -1)
			end
		else
			if Save().toRightTrackText then
				self.Bg:SetPoint('TOPLEFT', _G[Name..1], -1, 1)
				self.Bg:SetPoint('BOTTOMLEFT', _G[Name..self.numButton], -1, -1)
			else
				self.Bg:SetPoint('TOPRIGHT', _G[Name..1], 1, 1)
				self.Bg:SetPoint('BOTTOMRIGHT', _G[Name..self.numButton], 1, -1)
			end
		end
		self.Bg:SetWidth(self.bgWidth+1)
		self.Bg:SetShown(true)]]
	end

	TrackButton.texture= TrackButton:CreateTexture(nil, 'BORDER')
    TrackButton.texture:SetPoint('CENTER')

	function TrackButton:set_texture(icon)
		if icon and icon>0 then
			self.texture:SetTexture(icon)
			self.texture:SetPoint('TOPLEFT',0,0)
			self.texture:SetPoint('BOTTOMRIGHT',0,0)
		else
			self.texture:SetAtlas('Adventure-MissionEnd-Line')
			self.texture:SetPoint('TOPLEFT', 1.5,-6)
			self.texture:SetPoint('BOTTOMRIGHT',-1.5,6)
			self.texture:SetAlpha(Save().str and 0.3 or 1)
		end
	end

	function TrackButton:set_point()
		if WoWTools_FrameMixin:IsLocked(self) then
			return
		end
		self:ClearAllPoints()
		if Save().point then
			self:SetPoint(Save().point[1], UIParent, Save().point[3], Save().point[4], Save().point[5])
		else
			self:SetPoint('TOPLEFT', 200, WoWTools_DataMixin.Player.husandro and 0 or -100)
		end
	end

	function TrackButton:set_scale()
		if Frame:CanChangeAttribute() then
			Frame:SetScale(Save().scaleTrackButton or 1)
		end
	end

	function TrackButton:set_shown()--显示,隐藏
		if WoWTools_FrameMixin:IsLocked(self) then
			return
		end
		local hide= Save().Hide
			or (
				not Save().notAutoHideTrack and (
					IsInInstance()
					or C_PetBattles.IsInBattle()
					or UnitHasVehicleUI('player')
					or PlayerIsInCombat()
				)
			)
		self:set_texture()
		self:SetShown(not hide)
		Frame:SetShown(Save().str and not hide)
	end

	function TrackButton:set_strata()
        self:SetFrameStrata(Save().strata or 'MEDIUM')
    end

	function TrackButton:set_event()
		self:UnregisterAllEvents()
		if not Save().notAutoHideTrack and not Save().Hide then

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

	function TrackButton:set_Tooltip()
		if Save().toRightTrackText then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		else
			GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		end
		GameTooltip:ClearLines()

		if WoWTools_FrameMixin:IsLocked(self) then
			GameTooltip_AddErrorLine(GameTooltip, WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
			GameTooltip:Show()
			return
		end

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
			GameTooltip:AddLine(WoWTools_CurrencyMixin.addName..WoWTools_DataMixin.Icon.icon2)
			GameTooltip:AddLine(' ')
			GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '打开/关闭货币页面' or BINDING_NAME_TOGGLECURRENCY, WoWTools_DataMixin.Icon.left)
			GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU), WoWTools_DataMixin.Icon.right)
			GameTooltip:AddLine(' ')
			GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, 'Atl+'..WoWTools_DataMixin.Icon.right)
			local num= self.pool:GetNumActive()+ self.itemPool:GetNumActive()+ self.itemPool2:GetNumActive()
			GameTooltip:AddDoubleLine(WoWTools_TextMixin:GetShowHide(Frame:IsShown(), true), '|cffffffff#'..num..WoWTools_DataMixin.Icon.mid)
			GameTooltip:AddLine(' ')
			GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '拖曳' or DRAG_MODEL)..WoWTools_DataMixin.Icon.left..(WoWTools_DataMixin.onlyChinese and '物品' or ITEMS), WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING)
		end
		GameTooltip:Show()
	end


	TrackButton:SetScript('OnEvent', function(self)
		self:set_shown()
	end)

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
			Init_Button()

		elseif d=='LeftButton' and not IsModifierKeyDown() then
			ToggleCharacter("TokenFrame")--打开货币

		elseif d=='RightButton' and not IsModifierKeyDown() then
			MenuUtil.CreateContextMenu(self, Init_Menu)
		end
	end)


	TrackButton:SetScript("OnEnter", function(self)
		if not WoWTools_FrameMixin:IsLocked(self) then
			Init_Button()
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
		if not WoWTools_FrameMixin:IsLocked(self) then
			Save().str= d==-1
			self:set_texture()
			self:set_shown()
			self:set_Tooltip()
		end
	end)

	function TrackButton:settings()
		self:set_shown()
		self:set_strata()
		self:set_point()
		self:set_scale()
		self:set_event()
		self:set_bgalpha()
		Init_Button()
	end
	TrackButton:settings()


	WoWTools_DataMixin:Hook(TokenFrame, 'Update', function()
		Init_Button()
	end)


	Init=function()
		TrackButton:settings()
	end
end





function WoWTools_CurrencyMixin:Init_TrackButton()
    Init()
end

