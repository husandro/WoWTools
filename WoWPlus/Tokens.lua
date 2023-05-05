local id, e = ...
local addName=TOKENS
local Save={
	Hide=true,
	str=true,
	tokens={},--{[currencyID]=true}指定显示，表
	item={
		[202196]= true
	},
	--indicato=nil,--指定显示
}
local button

local Get_Currency= function(tab)--e.Get_Currency({id=nil, index=nil, link=nil, soloValue=nil, showIcon=true, showName=true, showID=true, bit=3, showMax=nil})--货币
    local info = tab.index and C_CurrencyInfo.GetCurrencyListInfo(tab.index) or tab.id and C_CurrencyInfo.GetCurrencyInfo(tab.id) or C_CurrencyInfo.GetCurrencyInfoFromLink(tab.link)
    if not info then--or (not info.discovered and info.quality==0 and not info.isHeader) then
        return
    end
    if tab.soloValue then--仅，返回值
        return info
    end

    if info.isHeader then
        return tab.showName and (tab.showIcon and '|A:'..e.Icon.icon..':0:0|a|cffffffff' or '')..info.name..'|r'
    end
    if not info.quantity or info.quality==0 then
        return
    end
    local t=''
    t= tab.showName and '   ' or t
    if tab.showID then--显示ID
        local ID= tab.id or tab.link and C_CurrencyInfo.GetCurrencyIDFromLink(tab.link)
        if tab.index then
            local link=tab.link or C_CurrencyInfo.GetCurrencyListLink(tab.index)
            ID= link and C_CurrencyInfo.GetCurrencyIDFromLink(link)
        end
        if ID then
            t= ID and t..ID..' ' or t
        end
    end
    if tab.showIcon and info.iconFileID then--图标
        t= t..'|T'..info.iconFileID..':0|t'
    end
    if tab.showName and info.name then--名称
        t= t..info.name..' '
    end

    local max= info.quantity and info.quantity>0 and (
            info.quantity==info.maxQuantity--最大数
        or (info.canEarnPerWeek and info.maxWeeklyQuantity==info.quantityEarnedThisWeek)--本周
        or (info.useTotalEarnedForMaxQty and info.totalEarned==info.maxQuantity)--赛季
    )
    if max then--最大数量
        t=t..'|cnRED_FONT_COLOR:'..e.MK(info.quantity, tab.bit)..'|r'..e.Icon.O2
    else
        t=t..e.MK(info.quantity, tab.bit)..(tab.showMax and info.maxQuantity and info.maxQuantity>0 and ' /'..e.MK(info.maxQuantity, tab.bit) or '')
    end

    if info.canEarnPerWeek and info.quantityEarnedThisWeek< info.maxWeeklyQuantity then--本周,收入
        t= t..' |cnGREEN_FONT_COLOR:(+'..e.MK(info.maxWeeklyQuantity - info.quantityEarnedThisWeek, tab.bit)..'|r'
    elseif info.useTotalEarnedForMaxQty and info.totalEarned< info.maxQuantity  and info.totalEarned< info.maxQuantity then--赛季,收入
        t= t..' |cnGREEN_FONT_COLOR:(+'..e.MK(info.maxQuantity- info.totalEarned, tab.bit)..'|r'
    end

    return t
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
        if (self.interactionType == Enum.UIItemInteractionType.ItemConversion) and timeToNextCharge>0 then
            text= text ..' |cnGREEN_FONT_COLOR:'..SecondsToClock(timeToNextCharge, true)..'|r'
        end

		if info.canEarnPerWeek and info.maxWeeklyQuantity and info.maxWeeklyQuantity>0 then
			text= text..' ('..info.quantityEarnedThisWeek..'/'..info.maxWeeklyQuantity..')'
		end
    end

	if self.ItemInteractionFrameCurrencyText then
		self.ItemInteractionFrameCurrencyText:SetText(text or '')
	end
end

local function get_Item_Num(tab)--物品数量
	local num= 0
	for _ in pairs(tab) do
		num= num +1
	end
	return num
end


local function set_Text_Item()
	if button.btn then
		local text=''
		if Save.str then
			for itemID in pairs(Save.item) do
				local num= GetItemCount(itemID , nil, true, true)
				local icon= C_Item.GetItemIconByID(itemID) or select(10, GetItemInfo(itemID))
				if icon and num>0 then
					text= text~='' and text..'\n' or text
					text= text..'|T'..icon..':0|t'..num
				elseif not icon then
					e.LoadDate({id=itemID, type='item'})--加载 item quest spell
				end
			end
		end
		button.btn.text2:SetText(text)
	end
end

local function set_Text()
	if button.btn then
		local m=''
		if Save.str then
			if Save.indicato then
				local tab={}
				for currentID, index in pairs(Save.tokens) do
					table.insert(tab, {currentID= currentID, index=index==true and 1 or index})
				end
				table.sort(tab, function(a,b) return a.index< b.index end)
				for _, info in pairs(tab) do
					local text= Get_Currency({id=info.currentID, index=nil, link=nil, soloValue=nil, showIcon=true, showName=Save.nameShow, showID=Save.showID, bit=3, showMax=nil})--货币
					if text then
						m= m..text..'\n' or m
					end
				end
			else
				for index=1, C_CurrencyInfo.GetCurrencyListSize() do
					local text= Get_Currency({id=nil, index=index, link=nil, soloValue=nil, showIcon=true, showName=Save.nameShow, showID=Save.showID, bit=3, showMax=nil})--货币
					if text then
						m= m..text..'\n' or m
					end
				end
			end
		end
		button.btn.text:SetText(m)
	end
end


local function Set_btn()
	if not Save.Hide and not button.btn then--监视声望按钮
		button.btn=e.Cbtn(nil, {icon=Save.str, size={18,18}})
		if Save.point then
			button.btn:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
		else
			button.btn:SetPoint('TOPLEFT', TokenFrame, 'TOPRIGHT',0, -35)
		end
		button.btn:RegisterForDrag("RightButton")
		button.btn:SetClampedToScreen(true);
		button.btn:SetMovable(true);
		button.btn:SetScript("OnDragStart", function(self2, d) if d=='RightButton' and not IsModifierKeyDown() then self2:StartMoving() end end)
		button.btn:SetScript("OnDragStop", function(self2)
				ResetCursor()
				self2:StopMovingOrSizing()
				Save.point={self2:GetPoint(1)}
				Save.point[2]=nil
		end)
		button.btn:SetScript("OnMouseUp", function() ResetCursor() end)
		button.btn:SetScript("OnClick", function(self2, d)
			local key=IsModifierKeyDown()
			if d=='RightButton' and not key then--右击,移动
				SetCursor('UI_MOVE_CURSOR')

			elseif d=='LeftButton' and not key then--点击,显示隐藏
				Save.str= not Save.str and true or nil
				button.btn:SetNormalAtlas(Save.str and e.Icon.icon or e.Icon.disabled)
				print(id, addName, e.GetShowHide(Save.str))
				set_Text()

			elseif d=='LeftButton' and IsAltKeyDown() then--显示名称
				Save.nameShow= not Save.nameShow and true or nil
				set_Text()
				print(id, addName, SHOW, NAME, e.GetShowHide(Save.nameShow))

			elseif d=='LeftButton' and IsControlKeyDown() then --显示ID
				Save.showID= not Save.showID and true or nil
				print(id, addName, SHOW, 'ID', e.GetShowHide(Save.showID))
				set_Text()
			end
		end)
		button.btn:SetScript("OnEnter",function(self2)
			e.tips:SetOwner(self2, "ANCHOR_LEFT");
			e.tips:ClearLines();
			e.tips:AddDoubleLine((e.onlyChinese and '追踪' or TRACKING)..': '..e.GetShowHide(Save.str),e.Icon.left)
			e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(e.onlyChinese and '打开/关闭货币页面' or BINDING_NAME_TOGGLECURRENCY, e.Icon.mid)
			e.tips:AddDoubleLine((e.onlyChinese and '字体大小' or FONT_SIZE)..(Save.size or 12), 'Alt+'..e.Icon.mid)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine((e.onlyChinese and '名称' or NAME)..': '..e.GetShowHide(Save.nameShow), 'Alt+'..e.Icon.left)
			e.tips:AddDoubleLine('ID: '..e.GetShowHide(Save.showID), 'Ctrl+'..e.Icon.left)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(id, addName)
			e.tips:Show();
		end)
		button.btn:SetScript("OnLeave", function(self2)
			self2:SetButtonState("NORMAL")
			ResetCursor()
			e.tips:Hide()
		end);
		button.btn:EnableMouseWheel(true)
		button.btn:SetScript("OnMouseWheel", function (self2, d)
			if IsAltKeyDown() then
				local n= Save.size or 12
				if d==1 then
					n= n+ 1
				elseif d==-1 then
					n= n- 1
				end
				n= n<6 and 6 or n
				n= n>32 and 32 or n
				Save.size=n
				e.Cstr(nil, {size=n, changeFont=button.btn.text, color=true})--n, nil, button.btn.text, true)
				print(id, addName, e.onlyChinese and '追踪' or TRACKING, e.onlyChinese and '字体大小' or FONT_SIZE, n)
			else
				if d==1 and not TokenFrame:IsVisible() or d==-1 and TokenFrame:IsVisible() then
					ToggleCharacter("TokenFrame")--打开货币
				end
			end
		end)

		button.btn:SetScript('OnEvent', function(self, event)
			self:SetShown(not Save.Hide and not IsInInstance() and not C_PetBattles.IsInBattle())
			if event=='BAG_UPDATE_DELAYED' then
				set_Text_Item()
			else
				set_Text()
			end
		end)

		button.btn.text=e.Cstr(button.btn, {size=Save.size, color=true})--内容显示文本
		button.btn.text:SetPoint('TOPLEFT',3,-3)

		button.btn.text2=e.Cstr(button.btn, {size=Save.size, color=true})----物品, 内容显示文本
		button.btn.text2:SetPoint('TOPLEFT', button.btn.text, 'BOTTOMLEFT', 0, -8)
	end
	if button.btn then
		button.btn:SetShown(not Save.Hide and not IsInInstance() and not C_PetBattles.IsInBattle())
		button.btn:SetNormalAtlas(Save.str and e.Icon.icon or e.Icon.disabled)
		
		local events={
			'CURRENCY_DISPLAY_UPDATE',
			'PLAYER_ENTERING_WORLD',
			'PET_BATTLE_OPENING_DONE',
			'PET_BATTLE_CLOSE',
		}
		if Save.Hide or get_Item_Num(Save.tokens)==0 then
			FrameUtil.UnregisterFrameForEvents(button.btn, events)
			button.btn.text:SetText('')
		else
			FrameUtil.RegisterFrameForEvents(button.btn, events)
			set_Text()
		end

		--物品数量
		if Save.Hide or get_Item_Num(Save.item)==0 then
			button.btn:UnregisterEvent('BAG_UPDATE_DELAYED')
			button.btn.text2:SetText('')
		else
			button.btn:RegisterEvent('BAG_UPDATE_DELAYED')
			set_Text_Item()
		end
	end
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
				set_Text()--设置, 文本
			end
		end)
		frame.check:SetScript('OnEnter', function(self)
			e.tips:SetOwner(self, "ANCHOR_RIGHT")
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


--##############
--设置,按钮, 图标
--##############
local function set_bagButtonTexture(icon)
	if icon then
		button:SetNormalTexture(icon)
		button.bagButton:SetNormalTexture(icon)
	elseif Save.Hide then
		button:SetNormalAtlas(e.Icon.disabled)
		button.bagButton:SetNormalAtlas(e.Icon.disabled)
	else
		button:SetNormalAtlas('auctionhouse-icon-favorite')
		button.bagButton:SetNormalAtlas('auctionhouse-icon-favorite')
	end
end

--#####
--主菜单
--#####
local function InitMenu(self, level, menuList)--主菜单
	local info
	if menuList=='ITEMS' then
		local find
		for itemID in pairs(Save.item) do
			info={
				text= select(2, GetItemInfo(itemID)) or ('itemID '..itemID),
				icon= C_Item.GetItemIconByID(itemID),
				notCheckable=true,
				tooltipOnButton=true,
				tooltipTitle=e.onlyChinese and '移除' or REMOVE,
				arg1= itemID,
				func= function(_, arg1)
					Save.item[arg1]= nil
					Set_btn()
					print(id, addName, e.onlyChinese and '移除' or REMOVE, select(2, GetItemInfo(itemID)) or ('itemID '..itemID))
				end
			}
			find=true
			e.LibDD:UIDropDownMenu_AddButton(info, level)
		end
		if find then
			e.LibDD:UIDropDownMenu_AddSeparator(level)
			info={
				text= e.onlyChinese and '全部清除' or CLEAR_ALL,
				icon='bags-button-autosort-up',
				notCheckable=true,
				func= function()
					Save.item= {}
					Set_btn()
					print(id, addName, e.onlyChinese and '全部清除' or CLEAR_ALL)
				end
			}
			find=true
			e.LibDD:UIDropDownMenu_AddButton(info, level)
		end
		return
	end

    info={
		text= (e.onlyChinese and '追踪' or TRACKING),
		checked= not Save.Hide,
		func= function()
			Save.Hide= not Save.Hide and true or nil
			Set_btn()
			set_bagButtonTexture()
			print(id, addName, e.onlyChinese and '追踪' or TRACKING, e.GetEnabeleDisable(not Save.Hide))
			if Save.Hide then
				button.indcatoCheck.text:SetTextColor(0.82, 0.82, 0.82, 0.5)
			else
				button.indcatoCheck.text:SetTextColor(1, 1, 1, 1)
			end
		end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
		text=e.onlyChinese and '物品' or ITEMS,
		notCheckable=true,
		menuList='ITEMS',
		hasArrow=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end


--######
--初始化
--######
local function Init()
	for itemID in pairs(Save.item) do
		e.LoadDate({id=itemID, type='item'})--加载 item quest spell
	end

	local function click(self)
		local infoType, itemID, itemLink = GetCursorInfo()
        if infoType == "item" and itemID then
			Save.item[itemID]= not Save.item[itemID] and true or nil
			Set_btn()
			print(id, addName, e.onlyChinese and '追踪' or TRACKING,
					Save.item[itemID] and
							('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..e.Icon.select2)
							or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..e.Icon.X2),
					itemLink or ('itemID'..itemID))
			ClearCursor()
		else
			e.LibDD:ToggleDropDownMenu(1, nil, button.Menu, self, 15, 0)
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
			set_bagButtonTexture(C_Item.GetItemIconByID(itemID))
		else
			e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.left)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine((e.onlyChinese and '拖曳' or DRAG_MODEL)..e.Icon.left..(e.onlyChinese and '物品' or ITEMS), e.onlyChinese and '追踪' or TRACKING)
			e.tips:AddDoubleLine(e.onlyChinese and '副本/宠物对战' or (INSTANCE..'/'..SHOW_PET_BATTLES_ON_MAP_TEXT), e.GetEnabeleDisable(false))
		end
		e.tips:AddLine(' ')
		e.tips:AddDoubleLine(id, addName)
		e.tips:Show()
		if button.btn and button.btn:IsShown() then
			button.btn:SetButtonState('PUSHED')
		end
	end

	local function leave()
		if button.btn then
			button.btn:SetButtonState("NORMAL")
		end
		e.tips:Hide()
		set_bagButtonTexture()
	end

	button= e.Cbtn(TokenFrame, {icon=false, size={18,18}})
	button:SetPoint("TOPRIGHT", TokenFrame, 'TOPRIGHT',-6,-35)

	button.Menu=CreateFrame("Frame", id..addName..'Menu', button, "UIDropDownMenuTemplate")
	e.LibDD:UIDropDownMenu_Initialize(button.Menu, InitMenu, 'MENU')

	button.bagButton= e.Cbtn(ContainerFrameCombinedBags, {size={18,18}})--背包中, 增加一个图标, 用来添加或移除
	button.bagButton:SetPoint('RIGHT', ContainerFrameCombinedBags.CloseButton, 'LEFT',-4,0)

	button:SetScript('OnClick', click)
	button:SetScript('OnEnter', enter)
	button:SetScript('OnLeave', leave)

	button.bagButton:SetScript('OnClick', click)
	button.bagButton:SetScript('OnEnter', enter)
	button.bagButton:SetScript('OnLeave',leave)

	set_bagButtonTexture()

	--展开,合起
	button.down=e.Cbtn(button, {icon=false, size={18,18}});
	button.down:SetPoint('RIGHT', button, 'LEFT', -2,0)
	button.down:SetNormalTexture('Interface\\Buttons\\UI-MinusButton-Up')
	button.down:SetScript("OnClick", function(self)
			for i=1, C_CurrencyInfo.GetCurrencyListSize() do--展开所有
				local info = C_CurrencyInfo.GetCurrencyListInfo(i)
				if info  and info.isHeader and not info.isHeaderExpanded then
					C_CurrencyInfo.ExpandCurrencyList(i,true);
				end
			end
			TokenFrame_Update()
	end)
	button.up=e.Cbtn(button, {icon=false, size={18,18}})
	button.up:SetPoint('RIGHT', button.down, 'LEFT',-2,0)
	button.up:SetSize(18,18);
	button.up:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
	button.up:SetScript("OnClick", function(self)
			for i=1, C_CurrencyInfo.GetCurrencyListSize() do--展开所有
				local info = C_CurrencyInfo.GetCurrencyListInfo(i);
				if info  and info.isHeader and info.isHeaderExpanded then
					C_CurrencyInfo.ExpandCurrencyList(i, false);
				end
			end
			TokenFrame_Update();
	end)
	button.bag=e.Cbtn(button, {icon='hide', size={18,18}})
	button.bag:SetPoint('RIGHT', button.up, 'LEFT',-2,0)
	button.bag:SetNormalAtlas(e.Icon.bag)
	button.bag:SetScript("OnClick", function(self)
		for index=1, BackpackTokenFrame:GetMaxTokensWatched() do--Blizzard_TokenUI.lua
			local info = C_CurrencyInfo.GetBackpackCurrencyInfo(index)
			if info then
				print(C_CurrencyInfo.GetCurrencyLink(info.currencyTypesID) or info.name)
			end
		end
		ToggleAllBags()
		TokenFrame_Update();
	end)
	button.bag:SetScript('OnEnter', function(self2)
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
	button.bag:SetScript('OnLeave', function() e.tips:Hide() end)


	button.indcatoCheck= CreateFrame("CheckButton", nil, TokenFrame, "InterfaceOptionsCheckButtonTemplate")--指定显示, 选项
	button.indcatoCheck:SetPoint('TOP', 0, -32)
	button.indcatoCheck:SetScript('OnMouseDown', function(self, d)
		if d=='LeftButton' then
			Save.indicato= not Save.indicato and true or nil
			print(id, addName, e.onlyChinese and '追踪' or TRACKING, e.GetShowHide(not Save.Hide))
		elseif d=='RightButton' then
			Save.tokens={}
			print(id, addName, e.onlyChinese and '全部清除' or CLEAR_ALL, e.onlyChinese and '类型' or TYPE, e.onlyChinese and '指定' or COMBAT_ALLY_START_MISSION)
			TokenFrame_Update()
		end
		set_Text()--设置, 文本
	end)
	button.indcatoCheck:SetScript('OnEnter', function(self)
		local num= 0
		for _, _ in pairs(Save.tokens) do
			num= num+1
		end
		e.tips:SetOwner(self, "ANCHOR_LEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(e.onlyChinese and '追踪 (类型): 指定' or  TRACKING..' ('..TYPE..'): '..COMBAT_ALLY_START_MISSION, e.Icon.left)
		e.tips:AddDoubleLine( e.onlyChinese and '全部清除' or CLEAR_ALL, '|cnGREEN_FONT_COLOR:#'..num..'|r'.. e.Icon.right)
		e.tips:AddLine(' ')
		e.tips:AddDoubleLine((e.onlyChinese and '追踪' or TRACKING), e.GetShowHide(not Save.Hide))
		e.tips:AddDoubleLine(id, addName)
		e.tips:Show()
	end)
	button.indcatoCheck:SetScript('OnLeave', function() e.tips:Hide() end)
	button.indcatoCheck.text:SetText(e.onlyChinese and '指定' or COMBAT_ALLY_START_MISSION)
	button.indcatoCheck:SetChecked(Save.indicato)
	if Save.Hide then
		button.indcatoCheck.text:SetTextColor(0.82, 0.82, 0.82, 0.5)
	end

	hooksecurefunc('TokenFrame_InitTokenButton',function(self, frame, elementData)--Blizzard_TokenUI.lua
		set_Tokens_Button(frame)--设置, 列表, 内容
	end)
	hooksecurefunc('TokenFrame_Update', function()
		for _, frame in pairs(TokenFrame.ScrollBox:GetFrames()) do
			set_Tokens_Button(frame)--设置, 列表, 内容
		end
		set_ItemInteractionFrame_Currency(TokenFrame)--套装,转换,货币
		set_Text()--设置, 文本
	end)

	C_Timer.After(2, Set_btn)
end


--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
		if arg1==id then
            Save= WoWToolsSave[addName] or Save
			Save.tokens= Save.tokens or {}
			Save.item= Save.item or {}
            --添加控制面板        
            local sel=e.CPanel('|A:bags-junkcoin:0:0|a'..(e.onlyChinese and '货币' or addName), not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)

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