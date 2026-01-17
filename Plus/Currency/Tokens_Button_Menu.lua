
local function Save()
    return WoWToolsSave['Currency2']
end












--物品，菜单
function WoWTools_CurrencyMixin:MenuList_Item(_, root)
	local sub, sub2, num
	sub=root:CreateCheckbox(
		(Save().Hide and '|cff626262' or'')..(WoWTools_DataMixin.onlyChinese and '物品' or ITEMS),
	function ()
		return not Save().disabledItemTrack
	end, function()
		Save().disabledItemTrack = not Save().disabledItemTrack and true or nil
		WoWTools_CurrencyMixin:Set_TrackButton_Text()
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
			WoWTools_CurrencyMixin:Set_TrackButton_Text()
		end, {itemID=itemID})
		WoWTools_SetTooltipMixin:Set_Menu(sub2)
	end

	sub:CreateDivider()

	if num>1 then
--全部清除
		WoWTools_MenuMixin:ClearAll(sub, function()
			Save().item={}
			WoWTools_CurrencyMixin:Set_TrackButton_Text()
		end)

		WoWTools_MenuMixin:SetScrollMode(sub)
	end

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




















--追踪
local function Init_TrackButton_Menu(self, root)
	local btn= _G['WoWToolsCurrencyTrackMainButton']
    if not btn or Save().itemButtonUse and WoWTools_MenuMixin:CheckInCombat(root) then
        return
    end

    local sub

--显示
    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '显示' or SHOW,
    function()
        return Save().str
    end, function ()
		if Save().itemButtonUse and not UnitAffectingCombat('player') or not Save().itemButtonUse then
			Save().str= not Save().str and true or false
			btn:set_texture()
			_G['WoWToolsCurrencyTrackMainFrame']:set_shown()
		end
    end)

--显示名称
    root:CreateDivider()
    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '显示名称' or PROFESSIONS_FLYOUT_SHOW_NAME,
    function ()
        return Save().nameShow
    end, function ()
        Save().nameShow= not Save().nameShow and true or nil
        WoWTools_CurrencyMixin:Set_TrackButton_Text()
    end)

--向右平移
    root:CreateCheckbox(
        (WoWTools_DataMixin.onlyChinese and '向右平移' or BINDING_NAME_STRAFERIGHT)..'|A:NPE_ArrowRight:0:0|a',
    function ()
        return Save().toRightTrackText
    end, function ()
        Save().toRightTrackText = not Save().toRightTrackText and true or false
        for i=1, btn.NumButton or 0 do
			local b= _G['WoWToolsCurrencyTrackButton'..i]
			if b and b.set_Text_Point then
				b.text:ClearAllPoints()
				b:set_Text_Point()
			end
        end
    end)

--上
    sub=root:CreateCheckbox(
        (WoWTools_DataMixin.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP)..'|A:bags-greenarrow:0:0|a',
    function ()
        return Save().toTopTrack
    end, function ()
        Save().toTopTrack = not Save().toTopTrack and true or nil
    end)
    sub:SetTooltip(function (tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)
    end)
--reload
	WoWTools_MenuMixin:Reload(sub)

    --缩放
    WoWTools_MenuMixin:Scale(self, root, function()
        return Save().scaleTrackButton
    end, function(value)
        Save().scaleTrackButton= value
        btn:set_scale()
    end)

--FrameStrata
    WoWTools_MenuMixin:FrameStrata(self, root, function(data)
        return btn:GetFrameStrata()==data
    end, function(data)
        Save().strata= data
        btn:set_strata()
    end)

--背景, 透明度
	WoWTools_MenuMixin:BgAplha(root,
	function()--GetValue
		return Save().trackBgAlpha or 0.5
	end, function(value)--SetValue
		Save().trackBgAlpha= value
		btn:set_bgalpha()
	end, function()--RestFunc
		Save().bgAlpha= nil
		btn:set_bgalpha()
	end)--onlyRoot

--自动隐藏
	sub=root:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '自动隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE),
	function()
		return not Save().notAutoHideTrack
	end, function()
		Save().notAutoHideTrack= not Save().notAutoHideTrack and true or nil
		btn:set_shown()
	end)
	sub:SetTooltip(function(tooltip)
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE)
		tooltip:AddLine(' ')
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '宠物对战' or SHOW_PET_BATTLES_ON_MAP_TEXT)
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '在副本中' or AGGRO_WARNING_IN_INSTANCE)
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '载具控制' or BINDING_HEADER_VEHICLE)
	end)

--重置位置
	root:CreateDivider()
	WoWTools_MenuMixin:RestPoint(self, root, Save().point, function()
		Save().point=nil
		btn:set_point()
	end)
end





















local function Init_Menu(self, root)
	if Save().itemButtonUse and WoWTools_MenuMixin:CheckInCombat(root) then
        return
    end

	local sub, sub2, num


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

--TrackButton 选项
	Init_TrackButton_Menu(self, sub)

--指定货币
	num=0
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
		WoWTools_CurrencyMixin:Set_TrackButton_Text()
	end)




	for _, currencyID in pairs(new) do
		sub2=sub:CreateCheckbox(
			WoWTools_CurrencyMixin:GetName(currencyID, nil, nil) or currencyID,
		function(data)
			return Save().tokens[data.currencyID]
		end, function(data)
			Save().tokens[data.currencyID]= not Save().tokens[data.currencyID] and true or nil
			TokenFrame:Update()
			WoWTools_CurrencyMixin:Set_TrackButton_Text()
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
			WoWTools_CurrencyMixin:Set_TrackButton_Text()
		end})
	end)

	if num>1 then
--全部清除
		sub:CreateDivider()
		WoWTools_MenuMixin:ClearAll(sub, function()
			Save().tokens={}
			WoWTools_CurrencyMixin:Set_TrackButton_Text()
			TokenFrame:Update()
		end)

		WoWTools_MenuMixin:SetScrollMode(sub)
	end


--物品
	WoWTools_CurrencyMixin:MenuList_Item(self, root)

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
    WoWTools_MenuMixin:Reload(root)
    WoWTools_MenuMixin:OpenOptions(root, {name= WoWTools_CurrencyMixin.addName})
end





function WoWTools_CurrencyMixin:Init_Menu(frame)
    MenuUtil.CreateContextMenu(frame, Init_Menu)
end












