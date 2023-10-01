local id, e = ...
local addName= TOKENS
local Save={
	tokens={},--{[currencyID]=true}指定显示，表
	item={},--[202196]= true
	--indicato=nil,--指定显示

	Hide=true,
	str=true,
	--scaleTrackButton=1,
	--toRightTrackText=true,--向右平移

	--hideCurrencyMax=true,--隐藏，已达到资源上限,提示
	--showID=true,--显示ID
}
local Button
local TrackButton
---@class Button
---@class TrackButton









local Get_Currency= function(tab)--货币
	--Get_Currency({index=index, showName=Save.nameShow, showID=Save.showID, toRight=Save.toRightTrackText, bit=nil})--货币
    local info
	if tab.index then
		info= C_CurrencyInfo.GetCurrencyListInfo(tab.index)
	elseif tab.id then
		info= C_CurrencyInfo.GetCurrencyInfo(tab.id)
	elseif tab.link then
		info= C_CurrencyInfo.GetCurrencyInfoFromLink(tab.link)
	end

	local text
    if not info or not info.iconFileID or not info.quantity or info.quantity<=0 then
		if info and info.isHeader and Save.showName and info.name then
			if tab.toRight then
				text= '|cffffffff'..info.name..'|r'..e.Icon.icon
			else
				text= e.Icon.icon..'|cffffffff'..info.name..'|r'
			end
		end
		return text
    end

	local currencyID
	if tab.showID then
		if tab.id then
			currencyID= tab.id
		elseif tab.link then
			currencyID= C_CurrencyInfo.GetCurrencyIDFromLink(tab.link)
		elseif tab.index then
			local link= C_CurrencyInfo.GetCurrencyListLink(tab.index)
			currencyID= link and C_CurrencyInfo.GetCurrencyIDFromLink(link)
		end
	end

	local icon= '|T'..info.iconFileID..':0|t'
    local name=  tab.showName and info.name or nil
	local num= e.MK(info.quantity, tab.bit or 3)

	local weekMax= info.canEarnPerWeek and info.maxWeeklyQuantity==info.quantityEarnedThisWeek--本周
	local earnedMax= info.useTotalEarnedForMaxQty and info.totalEarned==info.maxQuantity--赛季

    local max
	if info.quantity==info.maxQuantity--最大数
		or weekMax
		or earnedMax
	then
		max= tab.toRight and e.Icon.toRight2 or e.Icon.toLeft2
		num= '|cnRED_FONT_COLOR:'..num..'|r'
	end

	local need
	if not weekMax--本周,收入
		and info.canEarnPerWeek
		and info.quantityEarnedThisWeek and info.maxWeeklyQuantity and info.maxWeeklyQuantity>0
		and info.quantityEarnedThisWeek<info.maxWeeklyQuantity
	then
		need= '|cnGREEN_FONT_COLOR:(+'..e.MK(info.maxWeeklyQuantity- info.quantityEarnedThisWeek, tab.bit)..'|r'

	elseif not earnedMax--赛季,收入
		and info.useTotalEarnedForMaxQty
		and info.totalEarned and info.maxQuantity and info.maxQuantity>0
		and info.totalEarned<info.maxQuantity
	then
		need= '|cnGREEN_FONT_COLOR:(+'..e.MK(info.maxQuantity- info.totalEarned, tab.bit)..'|r'
	end

	if tab.toRight then
		text= (max or '')
			..num
			..(name and ' '..name or '')
			..icon
			..(currencyID and ' '..currencyID or '')
	else
		text=(currencyID and currencyID..' ' or '')
			..icon
			..(name and ' '..name..' ' or '')
			..num
			..(max or '')
	end


    return text
end
























--#############
--套装,转换,货币
--Blizzard_ItemInteractionUI.lua
local function set_ItemInteractionFrame_Currency(self)
	if not self then
		return
	end
    local itemInfo= C_ItemInteraction.GetItemInteractionInfo()
    local currencyID= itemInfo and itemInfo.currencyTypeId or self.chargeCurrencyTypeId or 2533--2167

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
					e.tips:AddDoubleLine(id, addName)
					e.tips:Show()
				end
			end)
			self.ItemInteractionFrameCurrencyText:SetScript('OnLeave', function() e.tips:Hide() end)
        end
		self.ItemInteractionFrameCurrencyText.chargeCurrencyTypeId= currencyID

        local chargeInfo = C_ItemInteraction.GetChargeInfo()
        local timeToNextCharge = chargeInfo.timeToNextCharge
        if (self.interactionType == Enum.UIItemInteractionType.ItemConversion) then
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





--###########
--监视声望按钮
--###########
local function Init_TrackButton()
	if Save.Hide or TrackButton then
		return
	end

	for itemID, _ in pairs(Save.item) do
		e.LoadDate({id=itemID, type='item'})--加载 item quest spell
	end

	TrackButton= e.Cbtn(nil, {atlas='hide', size={24,24}})

	TrackButton.text=e.Cstr(TrackButton, {color=true})--内容显示文本
	TrackButton.text2=e.Cstr(TrackButton, {color=true})--物品, 内容显示文本

	function TrackButton:set_Point()
		if Save.point then
			self:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
		else
			self:SetPoint('TOPLEFT', TokenFrame, 'TOPRIGHT',0, -35)
		end
	end

	function TrackButton:set_Item_Text()
		local text
		if Save.str and self:IsShown() then
			for itemID in pairs(Save.item) do
				local num= GetItemCount(itemID , nil, true, true)
				local icon= C_Item.GetItemIconByID(itemID)
				if icon and num>0 then
					text= text and text..'|n' or ''

					local idText= Save.showID and itemID

					icon= '|T'..icon..':0|t'
					local name
					if Save.nameShow then
						name= C_Item.GetItemNameByID(itemID) or GetItemInfo(itemID)
						if name then
							local itemQuality = C_Item.GetItemQualityByID(itemID)
							if itemQuality then
								local hex = select(4, GetItemQualityColor(itemQuality))
								name = hex and '|c'..hex..name..'|r' or name
							end
						end
					end

					if Save.toRightTrackText then--向右平移
						text= text
							.. e.MK(num, 3)
							..(name and ' '..name or '')
							..icon
							..(idText and ' '..idText or '')
					else
						text= text
							..(idText and idText..' ' or '')
							..icon
							..(name and name..' ' or '')
							..e.MK(num, 3)
					end

				elseif not icon then
					e.LoadDate({id=itemID, type='item'})--加载 item quest spell
				end
			end
		end
		self.text2:SetText(text and text..' ' or '')
	end

	function TrackButton:set_Currency_Text()
		local text
		if Save.str and self:IsShown() then
			if Save.indicato then
				local tab={}
				for currentID, index in pairs(Save.tokens) do
					table.insert(tab, {currentID= currentID, index=index==true and 1 or index})
				end
				table.sort(tab, function(a,b) return a.index< b.index end)
				for _, info in pairs(tab) do
					local msg= Get_Currency({id=info.currentID, showName=Save.nameShow, showID=Save.showID, toRight=Save.toRightTrackText})--货币
					if msg then
						text= text and text..'|n'..msg or msg
					end
				end
			else
				for index=1, C_CurrencyInfo.GetCurrencyListSize() do
					local msg= Get_Currency({index=index, showName=Save.nameShow, showID=Save.showID, toRight=Save.toRightTrackText})--货币
					if msg then
						text= text and text..'|n'..msg or msg
					end
				end
			end
		end
		self.text:SetText(text and text..' ' or '')
	end

	function TrackButton:set_Shown()--显示,隐藏
		local hide= Save.Hide or IsInInstance() or C_PetBattles.IsInBattle() or UnitAffectingCombat('player')
		self:SetShown(not hide)
		self:set_Currency_Text()
		self:set_Item_Text()
		if Save.str then
			self:SetNormalTexture(0)
			self:SetAlpha(1)
		else
			self:SetNormalAtlas(e.Icon.icon)
			self:SetAlpha(0.5)
		end
	end

	function TrackButton:set_Scale()
		self.text:SetScale(Save.scaleTrackButton or 1)
		self.text2:SetScale(Save.scaleTrackButton or 1)
	end

	function TrackButton:set_Text_Point()
		if Save.toRightTrackText then--向右平移
			self.text:SetPoint('TOPRIGHT', -3,-3)
			self.text2:SetPoint('TOPRIGHT', self.text, 'BOTTOMRIGHT', 0, -6)
		else
			self.text:SetPoint('TOPLEFT',3,-3)
			self.text2:SetPoint('TOPLEFT', self.text, 'BOTTOMLEFT', 0, -6)
		end

		self.text:SetJustifyH(Save.toRightTrackText and 'RIGHT' or 'LEFT')
		self.text2:SetJustifyH(Save.toRightTrackText and 'RIGHT' or 'LEFT')
	end

	TrackButton:RegisterForDrag("RightButton")
	TrackButton:SetClampedToScreen(true);
	TrackButton:SetMovable(true);
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
			self:Raise()
	end)
	TrackButton:SetScript("OnMouseUp", ResetCursor)
	TrackButton:SetScript("OnMouseDown", function(_, d)
		if d=='RightButton' and IsAltKeyDown() then--右击,移动
			SetCursor('UI_MOVE_CURSOR')
		end
	end)
	TrackButton:SetScript("OnMouseWheel", function(self, d)
		if IsAltKeyDown() then
			local n= Save.scaleTrackButton or 1
			if d==1 then
				n= n+ 0.05
			elseif d==-1 then
				n= n- 0.05
			end
			n= n<0.4 and 0.4 or n
			n= n>3 and 3 or n
			Save.scaleTrackButton=n
			self:set_Scale()
			self:set_Tooltips()
			print(id, addName, e.onlyChinese and '追踪' or TRACKING, e.onlyChinese and '字体大小' or FONT_SIZE, n)
		end
	end)

	TrackButton:SetScript("OnClick", function(self, d)
		if d=='LeftButton' and not IsModifierKeyDown() then--点击,显示隐藏
			Save.str= not Save.str and true or nil
			self:set_Shown()
			self:set_Tooltips()
			print(id, addName, e.GetShowHide(Save.str))

		elseif d=='LeftButton' and IsShiftKeyDown() then--向右平移
			Save.toRightTrackText = not Save.toRightTrackText and true or nil
			self.text:ClearAllPoints()
			self.text2:ClearAllPoints()
			self:set_Text_Point()
			self:set_Shown()

		elseif d=='LeftButton' and IsAltKeyDown() then--显示名称
			Save.nameShow= not Save.nameShow and true or nil
			self:set_Shown()
			self:set_Tooltips()
			print(id, addName, SHOW, NAME, e.GetShowHide(Save.nameShow))

		elseif d=='LeftButton' and IsControlKeyDown() then --显示ID
			Save.showID= not Save.showID and true or nil
			self:set_Shown()
			self:set_Tooltips()
			print(id, addName, SHOW, 'ID', e.GetShowHide(Save.showID))

		elseif d=='RightButton' and not IsModifierKeyDown() then
			ToggleCharacter("TokenFrame")--打开货币
		end
	end)

	function TrackButton:set_Tooltips()
		e.tips:SetOwner(self, "ANCHOR_LEFT");
		e.tips:ClearLines();
		e.tips:AddDoubleLine((e.onlyChinese and '追踪' or TRACKING)..': '..e.GetShowHide(Save.str),e.Icon.left)
		e.tips:AddDoubleLine(e.onlyChinese and '打开/关闭货币页面' or BINDING_NAME_TOGGLECURRENCY, e.Icon.right)
		e.tips:AddLine(' ')
		e.tips:AddDoubleLine((e.onlyChinese and '名称' or NAME)..': '..e.GetShowHide(Save.nameShow), 'Alt+'..e.Icon.left)
		e.tips:AddDoubleLine('ID: '..e.GetShowHide(Save.showID), 'Ctrl+'..e.Icon.left)
		e.tips:AddDoubleLine(e.onlyChinese and '向右平移' or BINDING_NAME_STRAFERIGHT, 'Shift+'..e.Icon.left)
		e.tips:AddLine(' ')
		e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Atl+'..e.Icon.right)
		e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' '..(Save.scaleTrackButton or 1), 'Alt+'..e.Icon.mid)
		e.tips:AddLine(' ')
		e.tips:AddDoubleLine(id, addName)
		e.tips:Show()
		self:SetAlpha(1)
	end
	TrackButton:SetScript("OnEnter", TrackButton.set_Tooltips)
	TrackButton:SetScript('OnMouseUp', ResetCursor)
	TrackButton:SetScript("OnLeave", function(self)
		self:set_Shown()
		self:SetButtonState("NORMAL")
		e.tips:Hide()
	end)

	function TrackButton:set_Event()
		if Save.Hide then
			self:UnregisterAllEvents()
		else
			self:RegisterEvent('PLAYER_ENTERING_WORLD')
			self:RegisterEvent('PET_BATTLE_OPENING_DONE')
			self:RegisterEvent('PET_BATTLE_CLOSE')
			self:RegisterEvent('PLAYER_REGEN_DISABLED')
			self:RegisterEvent('PLAYER_REGEN_ENABLED')
			self:RegisterEvent('BAG_UPDATE_DELAYED')
			self:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
		end
	end
	TrackButton:SetScript('OnEvent', function(self, event)
		if event=='BAG_UPDATE_DELAYED' then
			self:set_Item_Text()
		elseif event=='CURRENCY_DISPLAY_UPDATE' then
			self:set_Currency_Text()
		else
			self:set_Shown()--显示,隐藏
		end
	end)

	TrackButton:set_Point()
	TrackButton:set_Scale()
	TrackButton:set_Event()
	TrackButton:set_Shown()
	TrackButton:set_Text_Point()
end






















local function set_Tokens_Button(frame)--设置, 列表, 内容
	if not frame or not frame.index then
		return
	end
	local info = C_CurrencyInfo.GetCurrencyListInfo(frame.index)
	local link= C_CurrencyInfo.GetCurrencyListLink(frame.index)
	local currencyID= link and C_CurrencyInfo.GetCurrencyIDFromLink(link)
	if not frame.isHeader and info and currencyID  and not frame.check then
		frame.check= CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
		frame.check:SetPoint('LEFT', -3,0)
		frame.check:SetScript('OnClick', function(self)
			if self.currencyID then
				Save.tokens[self.currencyID]= not Save.tokens[self.currencyID] and self.index or nil
				frame.check:SetAlpha(Save.tokens[self.currencyID] and 1 or 0.5)
				if TrackButton then
					TrackButton:set_Currency_Text()--设置, 文本
				end
			end
		end)
		frame.check:SetScript('OnEnter', function(self)
			e.tips:SetOwner(self, "ANCHOR_LEFT")
			e.tips:ClearLines()
			if self.currencyID then
				local info2=C_CurrencyInfo.GetCurrencyInfo(self.currencyID)
				if info2 and info2.name then
					e.tips:AddDoubleLine(info2.name, self.currencyID, 0,1,0, 0,1,0)
					e.tips:AddLine(' ')
				end
			end
			e.tips:AddDoubleLine(e.onlyChinese and '追踪' or TRACKING, e.onlyChinese and '指定' or COMBAT_ALLY_START_MISSION)
			e.tips:AddDoubleLine(id, addName)
			e.tips:Show()
		end)
		frame.check:SetScript('OnLeave', function() e.tips:Hide() end)
		frame.check:SetSize(15,15)
		frame.check:SetCheckedTexture(e.Icon.icon)
	end

	if frame.check then
		frame.check.currencyID= currencyID
		frame.check.index= frame.index
		frame.check:SetShown(not frame.isHeader)
		frame.check:SetChecked(Save.tokens[currencyID])
		frame.check:SetAlpha(Save.tokens[currencyID] and 1 or 0.5)
	end

	if info and frame.Count then--最大数
		local max= info.quantity and info.quantity>0 and (
						info.quantity==info.maxQuantity
					or (info.canEarnPerWeek and info.maxWeeklyQuantity==info.quantityEarnedThisWeek)--本周
					or (info.useTotalEarnedForMaxQty and info.totalEarned==info.maxQuantity)--赛季
				)
		if max then
			frame.Count:SetTextColor(1,0,0)
		elseif info.useTotalEarnedForMaxQty or info.canEarnPerWeek then
			frame.Count:SetTextColor(1,0,1)
		elseif info.maxQuantity and info.maxQuantity>0 then
			frame.Count:SetTextColor(0,1,0)
		else
			frame.Count:SetTextColor(1,1,1)
		end
	end
end


























--#####
--主菜单
--#####
local function InitMenu(_, level, menuList)--主菜单
	local info
	if menuList=='ITEMS' then
		for itemID, _ in pairs(Save.item) do
			e.LoadDate({id=itemID, type='item'})--加载 item quest spell
			info={
				text= select(2, GetItemInfo(itemID)) or ('itemID '..itemID),
				icon= C_Item.GetItemIconByID(itemID),
				notCheckable=true,
				tooltipOnButton=true,
				tooltipTitle=e.onlyChinese and '移除' or REMOVE,
				arg1= itemID,
				func= function(_, arg1)
					Save.item[arg1]= nil
					if TrackButton then
						TrackButton:set_Shown()
					end
					print(id, addName, e.onlyChinese and '移除' or REMOVE, select(2, GetItemInfo(itemID)) or ('itemID '..itemID))
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
					if TrackButton then
						TrackButton:set_Shown()
					end
					print(id, addName, e.onlyChinese and '全部清除' or CLEAR_ALL)
				end
			end
		}
		e.LibDD:UIDropDownMenu_AddButton(info, level)

	elseif menuList=='TOKENS' then
		for currencyID, _ in pairs(Save.tokens) do
			local currencyInfo= C_CurrencyInfo.GetCurrencyInfo(currencyID) or {}
			info={
				text= currencyInfo.name or currencyID,
				icon=currencyInfo.iconFileID,
				notCheckable=true,
				tooltipOnButton=true,
				tooltipTitle=e.onlyChinese and '移除' or REMOVE,
				tooltipText=currencyID,
				colorCode= not Save.indicato and '|cff606060' or nil,
				arg1= currencyID,
				func= function(_, arg1)
					Save.tokens[arg1]=nil
					e.call('TokenFrame_Update')
					print(id, addName, e.onlyChinese and '移除' or REMOVE, C_CurrencyInfo.GetCurrencyLink(arg1) or arg1)
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
					Save.tokens= {}
					e.call('TokenFrame_Update')
					print(id, addName, e.onlyChinese and '全部清除' or CLEAR_ALL)
				end
			end
		}
		e.LibDD:UIDropDownMenu_AddButton(info, level)

	elseif menuList=='RestPoint' then
		info={
			text=e.onlyChinese and '重置位置' or RESET_POSITION,
			colorCode= (not Save.point or not TrackButton) and '|cff606060' or nil,
			notCheckable=true,
			keepShownOnClick=true,
			func= function()
				Save.point=nil
				if TrackButton then
					TrackButton:ClearAllPoints()
					TrackButton:set_Point()
				end
				print(id, addName, e.onlyChinese and '重置位置' or RESET_POSITION)
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
			if TrackButton then
				TrackButton:set_Shown()
			else
				Init_TrackButton()
			end
			Button:set_bagButtonTexture()
			print(id, addName, e.onlyChinese and '追踪' or TRACKING, e.GetEnabeleDisable(not Save.Hide))
		end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

	info={
		text=e.onlyChinese and '货币' or TOKENS,
		checked= Save.indicato,
		tooltipOnButton=true,
		tooltipTitle=e.onlyChinese and '指定' or COMBAT_ALLY_START_MISSION,
		menuList='TOKENS',
		hasArrow=true,
		keepShownOnClick=true,
		func= function()
			Save.indicato= not Save.indicato and true or nil
			if TrackButton then
				TrackButton:set_Shown()
			end
		end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
		text=e.onlyChinese and '物品' or ITEMS,
		notCheckable=true,
		menuList='ITEMS',
		hasArrow=true,
		keepShownOnClick=true,
		colorCoed=Save.Hide and '|cff606060' or nil,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
	

	e.LibDD:UIDropDownMenu_AddSeparator(level)
	info={
		text=e.onlyChinese and '达到上限' or CAPPED,
		checked= not Save.hideCurrencyMax,
		tooltipOnButton=true,
		tooltipTitle=e.onlyChinese and '已达到资源上限' or SPELL_FAILED_CUSTOM_ERROR_248,
		keepShownOnClick=true,
		func= function()
			Save.hideCurrencyMax= not Save.hideCurrencyMax and true or nil
			Button:set_Event()--已达到资源上限
			if not Save.hideCurrencyMax then
				Button:currency_Max(true)--已达到资源上限
				print(id, addName, 'Test', '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已达到资源上限' or SPELL_FAILED_CUSTOM_ERROR_248))
			end
		end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end


























--######
--初始化
--######
local function Init()
	Button= e.Cbtn(TokenFrame, {icon='hide', size={18,18}})
	Button:SetPoint("TOPRIGHT", TokenFrame, 'TOPRIGHT',-6,-35)
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
			print(id, addName, e.onlyChinese and '追踪' or TRACKING,
					Save.item[itemID] and
					('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..e.Icon.select2)
					or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..e.Icon.X2),
					itemLink or itemID)
			ClearCursor()
			if TrackButton then
				TrackButton:set_Item_Text()
			end
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
        if infoType ~= "item" then
			itemID=nil
		end
		e.tips:SetOwner(self, "ANCHOR_LEFT")
		e.tips:ClearLines()
		if itemID then
			e.tips:SetItemByID(itemID)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(itemLink or ('itemID'..itemID),
					Save.item[itemID] and
						('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..e.Icon.X2)
					or ('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..e.Icon.select2)
			)
			Button:set_bagButtonTexture(C_Item.GetItemIconByID(itemID))
		else
			e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.left)
			e.tips:AddDoubleLine((e.onlyChinese and '拖曳' or DRAG_MODEL)..e.Icon.left..(e.onlyChinese and '物品' or ITEMS), e.onlyChinese and '追踪' or TRACKING)
		end
		e.tips:AddLine(' ')

		e.tips:AddDoubleLine(id, addName)
		e.tips:Show()
		self.texture:SetAlpha(1)
		if TrackButton and TrackButton:IsShown() then
			TrackButton:SetButtonState('PUSHED')
		end
	end

	local function leave(self)
		e.tips:Hide()
		Button:set_bagButtonTexture()
		self.texture:SetAlpha(0.5)
		if TrackButton then
			TrackButton:SetButtonState("NORMAL")
		end
	end


	Button:SetScript('OnClick', click)
	Button:SetScript('OnEnter', enter)
	Button:SetScript('OnLeave', leave)

	Button.bagButton:SetScript('OnClick', click)
	Button.bagButton:SetScript('OnEnter', enter)
	Button.bagButton:SetScript('OnLeave',leave)
	Button.bagButton:HookScript('OnEnter', function(self2) self2:SetAlpha(1) end)
	Button.bagButton:HookScript('OnLeave', function(self2) self2:SetAlpha(0.5) end)



	--展开,合起
	Button.down= e.Cbtn(Button, {size={22,22}, texture='Interface\\Buttons\\UI-MinusButton-Up'})--展开所有
	Button.down:SetPoint('RIGHT', Button, 'LEFT', -2, 0)
	Button.down:SetScript("OnClick", function()
		for i=1, C_CurrencyInfo.GetCurrencyListSize() do--展开所有
			local info = C_CurrencyInfo.GetCurrencyListInfo(i)
			if info  and info.isHeader and not info.isHeaderExpanded then
				C_CurrencyInfo.ExpandCurrencyList(i,true);
			end
		end
		e.call('TokenFrame_Update')
	end)
	Button.down:SetScript("OnLeave", function() e.tips:Hide() end)
	Button.down:SetScript('OnEnter', function(self)
		e.tips:SetOwner(self, "ANCHOR_LEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(' ', e.onlyChinese and '展开选项|A:editmode-down-arrow:16:11:0:-7|a' or HUD_EDIT_MODE_EXPAND_OPTIONS)
		e.tips:AddDoubleLine(id, addName)
		e.tips:Show()
	end)

	Button.up= e.Cbtn(Button, {size={22,22}, texture='Interface\\Buttons\\UI-PlusButton-Up'})--收起所有
	Button.up:SetPoint('RIGHT', Button.down, 'LEFT', -2, 0)
	Button.up:SetScript("OnClick", function()
		for i=1, C_CurrencyInfo.GetCurrencyListSize() do--展开所有
			local info = C_CurrencyInfo.GetCurrencyListInfo(i);
			if info  and info.isHeader and info.isHeaderExpanded then
				C_CurrencyInfo.ExpandCurrencyList(i, false);
			end
		end
		e.call('TokenFrame_Update')
	end)
	Button.up:SetScript("OnLeave", function() e.tips:Hide() end)
	Button.up:SetScript('OnEnter', function(self)
		e.tips:SetOwner(self, "ANCHOR_LEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(' ',e.onlyChinese and '收起选项|A:editmode-up-arrow:16:11:0:3|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS)
		e.tips:AddDoubleLine(id, addName)
		e.tips:Show()
	end)

	Button.bag=e.Cbtn(Button, {icon='hide', size={18,18}})
	Button.bag:SetPoint('RIGHT', Button.up, 'LEFT',-4,0)
	Button.bag:SetNormalAtlas(e.Icon.bag)
	Button.bag:SetScript("OnClick", function(self)
		for index=1, BackpackTokenFrame:GetMaxTokensWatched() do--Blizzard_TokenUI.lua
			local info = C_CurrencyInfo.GetBackpackCurrencyInfo(index)
			if info then
				print(C_CurrencyInfo.GetCurrencyLink(info.currencyTypesID) or info.name)
			end
		end
		ToggleAllBags()
		e.call('TokenFrame_Update')
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
	Button.bag:SetScript('OnLeave', function() e.tips:Hide() end)


	function Button:currency_Max(init, curID)--已达到资源上限
		self.currencyMax= (init or not self.currencyMax) and {} or self.currencyMax
		local text
		if curID then
			local info = C_CurrencyInfo.GetCurrencyInfo(curID)
			if info then
				if info and info.quantity and info.quantity>0
					and (
						(info.maxQuantity and info.maxQuantity>0 and info.quantity==info.maxQuantity)--最大数
						or (info.canEarnPerWeek and info.canEarnPerWeek>0 and info.maxWeeklyQuantity==info.quantityEarnedThisWeek)--本周
						or (info.useTotalEarnedForMaxQty and info.maxQuantity and info.maxQuantity>0 and info.totalEarned==info.maxQuantity)--赛季
					)
				then
					text= C_CurrencyInfo.GetCurrencyLink(curID) or curID
				end
			end
		else
			local tab={}
			for currencyID, _ in pairs(Save.tokens) do
				if not self.currencyMax[currencyID] then
					local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
					if info and info.quantity and info.quantity>0
						and (
							(info.maxQuantity and info.maxQuantity>0 and info.quantity==info.maxQuantity)--最大数
							or (info.canEarnPerWeek and info.canEarnPerWeek>0 and info.maxWeeklyQuantity==info.quantityEarnedThisWeek)--本周
							or (info.useTotalEarnedForMaxQty and info.useTotalEarnedForMaxQty>0 and info.totalEarned==info.maxQuantity)--赛季
						)
					then
						tab[currencyID]=C_CurrencyInfo.GetCurrencyLink(currencyID) or info.name or currencyID
					end
				end
			end
			for i=1, C_CurrencyInfo.GetCurrencyListSize() do
				local info = C_CurrencyInfo.GetCurrencyListInfo(i)
				if info and info.quantity and info.quantity>0
					and (
						(info.maxQuantity and info.maxQuantity>0 and info.quantity==info.maxQuantity)--最大数
						or (info.canEarnPerWeek and info.canEarnPerWeek>0 and info.maxWeeklyQuantity==info.quantityEarnedThisWeek)--本周
						or (info.useTotalEarnedForMaxQty and info.useTotalEarnedForMaxQty>0 and info.totalEarned==info.maxQuantity)--赛季
					)
				then
					local link =C_CurrencyInfo.GetCurrencyListLink(i)
					local currencyID = link and C_CurrencyInfo.GetCurrencyIDFromLink(link)
					if currencyID and not self.currencyMax[currencyID] then
						tab[currencyID]=link
					end
				end
			end
			for currencyID, _ in pairs(tab) do
				local link= C_CurrencyInfo.GetCurrencyLink(currencyID)
				text= (text and text..' ' or '|cnGREEN_FONT_COLOR:')..(link or currencyID)
				self.currencyMax[currencyID]=true
			end
		end
		if text then
			print(id, addName, text, '|r|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已达到资源上限' or SPELL_FAILED_CUSTOM_ERROR_248))
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
		if arg1 and not self.currencyMax[arg1] then
			self:currency_Max(nil, arg1)
		end
	end)


	C_Timer.After(2, function()
		hooksecurefunc('TokenFrame_InitTokenButton',function(_, frame)--Blizzard_TokenUI.lua
			set_Tokens_Button(frame)--设置, 列表, 内容
		end)
		hooksecurefunc('TokenFrame_Update', function()
			for _, frame in pairs(TokenFrame.ScrollBox:GetFrames()) do
				set_Tokens_Button(frame)--设置, 列表, 内容
			end
			set_ItemInteractionFrame_Currency(TokenFrame)--套装,转换,货币
			if TrackButton then
				TrackButton:set_Currency_Text()--设置, 文本
			end
		end)

		if not Save.hideCurrencyMax then
			Button:currency_Max(true)--已达到资源上限
			Button:set_Event()--已达到资源上限
		end

		Init_TrackButton()
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
			e.AddPanel_Check({
				name= '|A:bags-junkcoin:0:0|a'..(e.onlyChinese and '货币' or addName),
				tooltip= addName,
				value= not Save.disabled,
				func= function()
					Save.disabled= not Save.disabled and true or nil
					print(addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
				end
			})


            --[[添加控制面板        
            local sel=e.AddPanel_Check('|A:bags-junkcoin:0:0|a'..(e.onlyChinese and '货币' or addName), not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)]]

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
				Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

		elseif arg1=='Blizzard_ItemInteractionUI' then
            hooksecurefunc(ItemInteractionFrame, 'SetupChargeCurrency', set_ItemInteractionFrame_Currency)
		end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
	end
end)