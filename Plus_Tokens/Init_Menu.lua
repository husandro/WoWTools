local e= select(2, ...)
local function Save()
    return WoWTools_TokensMixin.Save
end












--物品，菜单
function WoWTools_TokensMixin:MenuList_Item(_, root)
	local sub, sub2, num

	root:CreateDivider()
	sub=root:CreateCheckbox(
		(Save().Hide and '|cff9e9e9e' or'')..(e.onlyChinese and '物品' or ITEMS),
	function ()
		return not Save().disabledItemTrack
	end, function()
		Save().disabledItemTrack = not Save().disabledItemTrack and true or nil
		WoWTools_TokensMixin:Set_TrackButton_Text()
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
			self:Set_TrackButton_Text()
		end, {itemID=itemID})
		WoWTools_SetTooltipMixin:Set_Menu(sub2)
	end

	sub:CreateDivider()

	if num>1 then
--全部清除
		WoWTools_MenuMixin:ClearAll(sub, function() Save().item={} self:Set_TrackButton_Text() end)
--GridMode
		WoWTools_MenuMixin:SetGridMode(sub, num)
	end
--使用物品
	sub2=sub:CreateCheckbox(
		e.onlyChinese and '使用物品' or USE_ITEM,
	function()
		return Save().itemButtonUse
	end, function()
		Save().itemButtonUse= not Save().itemButtonUse and true or nil
	end)
	sub2:SetTooltip(function(tooltip)
		tooltip:AddLine(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
		tooltip:AddLine(e.onlyChinese and '提示: 可能会出现错误' or (LABEL_NOTE..': '..ENABLE_ERROR_SPEECH))
	end)
--重新加载UI
	WoWTools_MenuMixin:Reload(sub2)
end













local function Init_Menu(self, root)
	if Save().itemButtonUse and WoWTools_MenuMixin:CheckInCombat(root) then
        return
    end

	local sub, sub2, num
	

--追踪
	sub=root:CreateCheckbox(
		e.onlyChinese and '追踪' or TRACKING,
	function()
		return not Save().Hide
	end, function()
		Save().Hide= not Save().Hide and true or nil
		WoWTools_TokensMixin:Init_TrackButton()
	end)

--自动隐藏
	sub2=sub:CreateCheckbox(
		e.onlyChinese and '自动隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE),
	function()
		return not Save().notAutoHideTrack
	end, function()
		Save().notAutoHideTrack= not Save().notAutoHideTrack and true or nil
		if WoWTools_TokensMixin.TrackButton then
			WoWTools_TokensMixin.TrackButton:set_shown()
		end
	end)
	sub2:SetTooltip(function(tooltip)
		tooltip:AddLine(e.onlyChinese and '隐藏' or HIDE)
		tooltip:AddLine(' ')
		tooltip:AddLine(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
		tooltip:AddLine(e.onlyChinese and '宠物对战' or SHOW_PET_BATTLES_ON_MAP_TEXT)
		tooltip:AddLine(e.onlyChinese and '在副本中' or AGGRO_WARNING_IN_INSTANCE)
		tooltip:AddLine(e.onlyChinese and '载具控制' or BINDING_HEADER_VEHICLE)
	end)



--重置位置
	sub:CreateDivider()
	WoWTools_MenuMixin:RestPoint(sub, Save().point, function()
		Save().point=nil
		if WoWTools_TokensMixin.TrackButton then
			WoWTools_TokensMixin.TrackButton:set_point()
		end
	end)


--指定货币
	num=0
	local new={}
	for currencyID, _ in pairs(Save().tokens) do
		num=num+1
		table.insert(new, currencyID)
	end
	table.sort(new)
	sub=root:CreateCheckbox(
		(Save().Hide and '|cff9e9e9e' or '')
		..(e.onlyChinese and '指定货币' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMBAT_ALLY_START_MISSION, TOKENS))..(num==0 and '|cff9e9e9e ' or ' ')..num,
	function()
		return Save().indicato
	end, function()
		Save().indicato= not Save().indicato and true or nil
		WoWTools_TokensMixin:Set_TrackButton_Text()
	end)




	for _, currencyID in pairs(new) do
		sub2=sub:CreateCheckbox(
			WoWTools_CurrencyMixin:GetName(currencyID, nil, nil),
		function(data)
			return Save().tokens[data.currencyID]
		end, function(data)
			Save().tokens[data.currencyID]= not Save().tokens[data.currencyID] and true or nil
			TokenFrame:Update()
			WoWTools_TokensMixin:Set_TrackButton_Text()
		end, {currencyID=currencyID})
		WoWTools_SetTooltipMixin:Set_Menu(sub2)
	end

--添加
	sub:CreateDivider()
	sub:CreateButton(
		e.onlyChinese and '添加' or ADD,
	function()
		StaticPopup_Show('WoWTools_Currency', nil, nil, {
		GetValue=function()
		end, CheckValue=function(button1, currencyID)
			button1:SetText(
				Save().tokens[currencyID] and (e.onlyChinese and '更新' or UPDATE)
				or (e.onlyChinese and '添加' or ADD)
			)
		end, SetValue=function(currencyID)
			Save().tokens[currencyID]=true
			WoWTools_TokensMixin:Set_TrackButton_Text()
		end})
	end)

	if num>1 then
--全部清除
		sub:CreateDivider()
		WoWTools_MenuMixin:ClearAll(sub, function()
			Save().tokens={}
			WoWTools_TokensMixin:Set_TrackButton_Text()
			TokenFrame:Update()
		end)
--SetGridMode
		WoWTools_MenuMixin:SetGridMode(sub, num)
	end


--物品
	WoWTools_TokensMixin:MenuList_Item(self, root)

--达到上限
	root:CreateDivider()
	root:CreateCheckbox(
		'|A:communities-icon-chat:0:0|a'..(e.onlyChinese and '达到上限' or CAPPED),
	function ()
		return not Save().hideCurrencyMax
	end, function ()
		Save().hideCurrencyMax= not Save().hideCurrencyMax and true or nil
		self:set_Event()--已达到资源上限
		if not Save().hideCurrencyMax then
			self.currencyMax={}--已达到资源上限
			self:currency_Max()
			print(e.addName, WoWTools_TokensMixin.addName, 'Test', '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已达到资源上限' or SPELL_FAILED_CUSTOM_ERROR_248))
		end
	end)
	sub:SetTooltip(function (tooltip)
		tooltip:AddLine(e.onlyChinese and '已达到资源上限' or SPELL_FAILED_CUSTOM_ERROR_248)
	end)
end





function WoWTools_TokensMixin:Init_Menu(frame)
    MenuUtil.CreateContextMenu(frame, Init_Menu)
end












