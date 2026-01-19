
local function Save()
    return WoWToolsSave['Currency2']
end












--物品，菜单
local function MenuList_Item(_, root)
	local sub, sub2, num
	sub=root:CreateCheckbox(
		(Save().Hide and '|cff626262' or'')..(WoWTools_DataMixin.onlyChinese and '物品' or ITEMS),
	function ()
		return not Save().disabledItemTrack
	end, function()
		Save().disabledItemTrack = not Save().disabledItemTrack and true or nil
		WoWTools_CurrencyMixin:Init_TrackButton()
	end)


	num=0
	for itemID in pairs(Save().item) do
		num=num+1
		sub2=sub:CreateCheckbox(
			WoWTools_ItemMixin:GetName(itemID),
		function(data)
			return Save().item[data.itemID]
		end, function(data)
			Save().item[data.itemID]= not Save().item[data.itemID] and true or nil
			WoWTools_CurrencyMixin:Init_TrackButton()
		end, {itemID=itemID})
		WoWTools_SetTooltipMixin:Set_Menu(sub2)
	end

--全部清除
	sub:CreateDivider()
	WoWTools_MenuMixin:ClearAll(sub, function()
		Save().item={}
		WoWTools_CurrencyMixin:Init_TrackButton()
	end)

	WoWTools_MenuMixin:SetScrollMode(sub)


--使用物品
	sub2=sub:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '使用物品' or USE_ITEM,
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

--重新加载UI
	WoWTools_MenuMixin:Reload(sub2)
end
























--指定货币
local function Init_CurrencyMenu(_, root)
	local  sub, sub2

	local num=0
	local new={}
	for currencyID, _ in pairs(Save().tokens) do
		num=num+1
		table.insert(new, currencyID)
	end
	table.sort(new)
	sub=root:CreateCheckbox(
		(Save().Hide and '|cff626262' or '')
		..(WoWTools_DataMixin.onlyChinese and '指定货币' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMBAT_ALLY_START_MISSION, TOKENS))
		..(num==0 and '|cff626262 ' or ' ')..num,
	function()
		return Save().indicato
	end, function()
		Save().indicato= not Save().indicato and true or nil
		WoWTools_CurrencyMixin:Init_TrackButton()
	end)




	for _, currencyID in pairs(new) do
		sub2=sub:CreateCheckbox(
			WoWTools_CurrencyMixin:GetName(currencyID, nil, nil) or currencyID,
		function(data)
			return Save().tokens[data.currencyID]
		end, function(data)
			Save().tokens[data.currencyID]= not Save().tokens[data.currencyID] and true or nil
			TokenFrame:Update()
			WoWTools_CurrencyMixin:Init_TrackButton()
		end, {currencyID=currencyID})
		sub2:SetTooltip(function(tooltip, description)
			tooltip:SetCurrencyByID(description.data.currencyID)
			WoWTools_CurrencyMixin:Find(description.data.currencyID, nil)--选中提示
		end)
		sub2:SetOnLeave(function()
			WoWTools_CurrencyMixin:Find(nil, nil)--选中提示
			GameTooltip:Hide()
		end)
		--WoWTools_SetTooltipMixin:Set_Menu(sub2)
	end

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
			WoWTools_CurrencyMixin:Init_TrackButton()
		end})
	end)


--全部清除
	sub:CreateDivider()
	WoWTools_MenuMixin:ClearAll(sub, function()
		Save().tokens={}
		WoWTools_CurrencyMixin:Init_TrackButton()
		TokenFrame:Update()
	end)

	WoWTools_MenuMixin:SetScrollMode(sub)
end













local function Init_Menu(self, root)
	if Save().itemButtonUse and WoWTools_MenuMixin:CheckInCombat(root) then
        return
    end

	local sub


--追踪
	sub=root:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING,
	function()
		return not Save().Hide
	end, function()
		Save().Hide= not Save().Hide and true or nil
		WoWTools_CurrencyMixin:Init_TrackButton()
		_G['WoWToolsPlusCurrencyMenuButton']:set_texture()
	end)

	Init_CurrencyMenu(self, sub)
--物品
	MenuList_Item(self, sub)

--重置位置
	root:CreateDivider()
	WoWTools_MenuMixin:RestPoint(self, sub, Save().point, function()
		Save().point=nil
		WoWTools_CurrencyMixin:Init_TrackButton()
	end)


--达到上限
	root:CreateDivider()
	sub=root:CreateCheckbox(
		'|A:communities-icon-chat:0:0|a'..(WoWTools_DataMixin.onlyChinese and '达到上限' or CAPPED),
	function ()
		return not Save().hideCurrencyMax
	end, function ()
		Save().hideCurrencyMax= not Save().hideCurrencyMax and true or nil
		WoWTools_CurrencyMixin:Init_MaxTooltip()
	end)
	sub:SetTooltip(function (tooltip)
		tooltip:AddLine('CURRENCY_DISPLAY_UPDATE')
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '已达到资源上限' or SPELL_FAILED_CUSTOM_ERROR_248)
	end)


--Plus
	sub=root:CreateCheckbox(
		'UI Plus',
	function()
		return not Save().notPlus
	end, function()
		Save().notPlus= not Save().notPlus and true or nil
		WoWTools_CurrencyMixin:Init_Plus()
	end)
	sub:SetTooltip(function (tooltip)
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
	end)

--重新加载UI
	root:CreateDivider()

    sub= WoWTools_MenuMixin:OpenOptions(root, {name= WoWTools_CurrencyMixin.addName})
	WoWTools_MenuMixin:Reload(sub)
end





function WoWTools_CurrencyMixin:Init_Menu(frame)
    MenuUtil.CreateContextMenu(frame, Init_Menu)
end












