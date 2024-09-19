local e= select(2, ...)
local function Save()
    return WoWTools_TokensMixin.Save
end












--物品，菜单
function WoWTools_TokensMixin:MenuList_Item(_, root)
	local sub, num
	num=0
	for itemID in pairs(Save().item) do
		num=num+1
		sub=root:CreateCheckbox(
			WoWTools_ItemMixin:GetName(itemID),
		function(data)
			return Save().item[data.itemID]
		end, function(data)
			Save().item[data.itemID]= not Save().item[data.itemID] and true or nil
			self:Set_TrackButton_Text()
		end, {itemID=itemID})
		WoWTools_SetTooltipMixin:Set_Menu(sub)
	end

	root:CreateDivider()
	if num>1 then
--全部清除
		WoWTools_MenuMixin:ClearAll(root, function() Save().item={} self:Set_TrackButton_Text() end)
--GridMode
		WoWTools_MenuMixin:SetGridMode(root, num)
	end
--使用物品
	sub=root:CreateCheckbox(
		e.onlyChinese and '使用物品' or USE_ITEM,
	function()
		return Save().itemButtonUse
	end, function()
		Save().itemButtonUse= not Save().itemButtonUse and true or nil
	end)
	sub:SetTooltip(function(tooltip)
		tooltip:AddLine(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
		tooltip:AddLine(e.onlyChinese and '提示: 可能会出现错误' or (LABEL_NOTE..': '..ENABLE_ERROR_SPEECH))
	end)
--重新加载UI
	WoWTools_MenuMixin:Reload(sub)

end













local function Init_Menu(_, root)
	local sub, sub2, num
	local enabled= not (Save().itemButtonUse and UnitAffectingCombat('player'))

--追踪
	sub=root:CreateCheckbox(
		e.onlyChinese and '追踪' or TRACKING,
	function()
		return not Save().Hide
	end, function()
		Save().Hide= not Save().Hide and true or nil
		WoWTools_TokensMixin:Init_TrackButton()
	end)
	sub:SetEnabled(enabled)

--自动隐藏
	sub2=sub:CreateCheckbox(
		e.onlyChinese and '自动隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE),
	function()
		return not Save().notAutoHideTrack
	end, function()
		Save().notAutoHideTrack= not Save().notAutoHideTrack and true or nil
		if WoWTools_TokensMixin.TrackButton then
			WoWTools_TokensMixin.TrackButton:set_Shown()
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
	sub2:SetEnabled(enabled)


--重置位置
	sub:CreateDivider()
	WoWTools_MenuMixin:RestPoint(sub, Save().point, function()
		Save().point=nil
		WoWTools_TokensMixin.TrackButton:set_point()
	end)


--指定货币
	sub=root:CreateCheckbox(
		e.onlyChinese and '指定货币' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMBAT_ALLY_START_MISSION, TOKENS),
	function()
		return Save().indicato
	end, function()
		Save().indicato= not Save().indicato and true or nil
		WoWTools_TokensMixin:Init_TrackButton()
	end)

	num=0
	for currencyID in pairs(Save().tokens) do
		num=num+1
		sub2=sub:CreateCheckbox(
			WoWTools_CurrencyMixin:GetName(currencyID, nil, nil),
		function(data)
			return Save().tokens[data.currencyID]
		end, function(data)
			Save().tokens[data.currencyID]= not Save().tokens[data.currencyID] and true or nil
			TokenFrame:Update()
		end, {currencyID=currencyID})
		WoWTools_SetTooltipMixin:Set_Menu(sub2)
	end

	if num>1 then
--SetGridMode
		WoWTools_MenuMixin:SetGridMode(sub, num)
		
	end
end








--#####
--主菜单
--#####
local function InitMenu(self, level, menuList)--主菜单

	local info
	if menuList=='ITEMS' then
		MenuList_Item(level)

	elseif menuList=='TOKENS' then
		for currencyID, _ in pairs(Save().tokens) do
			local currencyInfo= C_CurrencyInfo.GetCurrencyInfo(currencyID) or {}
			info={
				text= currencyInfo.name or currencyID,
				icon=currencyInfo.iconFileID,
				notCheckable=true,
				tooltipOnButton=true,
				tooltipTitle=e.onlyChinese and '移除' or REMOVE,
				tooltipText='ID '..currencyID,
				colorCode= not Save().indicato and '|cff9e9e9e' or (currencyInfo and ITEM_QUALITY_COLORS[currencyInfo.quality]).hex or nil,
				arg1= currencyID,
				func= function(_, arg1)
					Save().tokens[arg1]=nil
					TokenFrame:Update()
					print(e.addName, WoWTools_TokensMixin.addName, e.onlyChinese and '移除' or REMOVE, C_CurrencyInfo.GetCurrencyLink(arg1) or arg1)
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
						e.call(ChatEdit_FocusActiveWindow)
					end,
					OnAccept = function(s)
						local n= s.editBox:GetNumber()
						if n then
							Save().tokens[n]=0
							print(e.addName, WoWTools_TokensMixin.addName, e.onlyChinese and '添加' or ADD,  C_CurrencyInfo.GetCurrencyLink(n))
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

							if Save().tokens[n] then
								text= text..'|n'..(e.onlyChinese and '更新' or UPDATE)
							end
						end
						local p= s:GetParent()
						p.text:SetText(text)
						p.button1:SetEnabled(curInfo and not Save().tokens[n])
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
					Save().tokens= {}
					TokenFrame:Update()
					print(e.addName, WoWTools_TokensMixin.addName, e.onlyChinese and '全部清除' or CLEAR_ALL)
				end
			end
		}
		e.LibDD:UIDropDownMenu_AddButton(info, level)

	end

	if menuList then
		return
	end

    info={
		text= (e.onlyChinese and '追踪' or TRACKING),
		checked= not Save().Hide,
		keepShownOnClick=true,
		hasArrow=true,
		menuList='RestPoint',
		func= function()
			Save().Hide= not Save().Hide and true or nil
			WoWTools_TokensMixin:Init_TrackButton()
			print(e.addName, WoWTools_TokensMixin.addName, e.onlyChinese and '追踪' or TRACKING, e.GetEnabeleDisable(not Save().Hide))
		end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

	info={
		text=e.onlyChinese and '指定货币' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMBAT_ALLY_START_MISSION, TOKENS),
		checked= Save().indicato,
		tooltipOnButton=true,
		menuList='TOKENS',
		hasArrow=true,
		keepShownOnClick=true,
		func= function()
			Save().indicato= not Save().indicato and true or nil
			WoWTools_TokensMixin:Init_TrackButton()
		end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

	info={
		text=e.onlyChinese and '物品' or ITEMS,
		checked= not Save().disabledItemTrack,
		menuList='ITEMS',
		hasArrow=true,
		keepShownOnClick=true,
		disabled= UnitAffectingCombat('player'),
		colorCode=Save().Hide and '|cff9e9e9e' or nil,
		func= function()
			Save().disabledItemTrack = not Save().disabledItemTrack and true or nil
			WoWTools_TokensMixin:Set_TrackButton_Text()
		end
	}
    e.LibDD:UIDropDownMenu_AddButton(info, level)

	e.LibDD:UIDropDownMenu_AddSeparator(level)
	info={
		text=e.onlyChinese and '达到上限' or CAPPED,
		checked= not Save().hideCurrencyMax,
		icon='communities-icon-chat',
		tooltipOnButton=true,
		tooltipTitle=e.onlyChinese and '已达到资源上限' or SPELL_FAILED_CUSTOM_ERROR_248,
		keepShownOnClick=true,
		func= function()
			Save().hideCurrencyMax= not Save().hideCurrencyMax and true or nil
			Button:set_Event()--已达到资源上限
			if not Save().hideCurrencyMax then
				Button.currencyMax={}--已达到资源上限
				Button:currency_Max()
				print(e.addName, WoWTools_TokensMixin.addName, 'Test', '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已达到资源上限' or SPELL_FAILED_CUSTOM_ERROR_248))
			end
		end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end















function WoWTools_TokensMixin:Init_Menu(frame)
    MenuUtil.CreateContextMenu(frame, Init_Menu)
end