local id, e = ...
local Save={noSell={}, Sell={}}
local BossLoot={}
local addName=MERCHANT
local panel=CreateFrame("Frame")

--#########
--设置耐久度
--#########
local function getDurabiliy()--耐久度值
    local c = 0;
    local m = 0;
    for i = 1, 18 do
        local cur,max = GetInventoryItemDurability(i);
        if cur and max and max>0 then
            c = c + cur;
            m =m + max;
        end
    end
    local du='';
    if m>0 then
        du = floor((c/m) * 100)
        if du<30 then
            du='|cnRED_FONT_COLOR:'..du..'%|r';
        elseif du<=60 then
            du='|cnYELLOW_FONT_COLOR:'..du..'%|r';
        elseif du<=90 then
            du='|cnGREEN_FONT_COLOR:'..du..'%|r';
        else
            du=du..'%'
        end
        --du=du..'|T132281:8|t';
    end
    return du
end
local function setDurabiliy()--设置耐久度
    local button=MerchantRepairAllButton
    if not Save.notAutoRepairAll and button then
        if not button.text then
            button.text=e.Cstr(button)
            button.text:SetPoint('TOPLEFT')
        end
        button.text:SetText(getDurabiliy())
    elseif button and button.text then
        button.text:SetText('')
    end
end

--#######
--自动修理
--#######
local function setAutoRepairAll()
    if Save.notAutoRepairAll or not CanMerchantRepair() or IsModifierKeyDown() then
        return
    end
    local Co, Can   = GetRepairAllCost();
    if Can and Co>0 then
        if CanGuildBankRepair() and GetGuildBankMoney()>=Co  then
            RepairAllItems(true);
            print(id, addName, GUILDCONTROL_OPTION15_TOOLTIP, GetCoinTextureString(Co))
        else
            if GetMoney()>=Co then
                print(id, addName, '|cnGREEN_FONT_COLOR:'..REPAIR_COST..'|r', GetCoinTextureString(Co));
            else
                print(id, addName, '|cnRED_FONT_COLOR:'..FAILED..'|r', REPAIR_COST, GetCoinTextureString(Co));
            end
        end
        RepairAllItems();
    end
end

--#######
--出售物品
--#######
local avgItemLevel--装等
local function bossLoot(itemID, itemLink)--BOSS掉落
    avgItemLevel=avgItemLevel or GetAverageItemLevel()
    
    if not itemID or not itemLink or not avgItemLevel then
        return
    end
    local _, _, itemQuality, itemLevel, _, _, _, _, itemEquipLoc, _, _, classID, _, bindType = GetItemInfo(itemLink);
    if itemEquipLoc--绑定
    and itemQuality and itemQuality==4--最高史诗
    and (classID==2 or classID==3 or classID==4)--2武器 3宝石 4盔甲
    and bindType == LE_ITEM_BIND_ON_ACQUIRE--1     LE_ITEM_BIND_ON_ACQUIRE    拾取绑定
    and itemLevel and itemLevel>1 and avgItemLevel-itemLevel>=15 then
        BossLoot[itemLink]=true
    end
end
local itemPetID={--宠物对换, wow9.0
    [11406]=true,
    [11944]=true,
    [25402]=true,
    [3300]=true,
    [3670]=true,
    [6150]=true,
    [36812]=true,
    [62072]=true,
    [67410]=true,
}
local function CheckItemSell(itemID, itemLink, quality)--检测是否是出售物品
    if itemPetID[itemID] then--宠物对换
        return
    end
    if itemID then
        if Save.noSell[itemID] then
            return
        end
        if Save.Sell[itemID] and not Save.notSellCustom then
            return CUSTOM
        end
        if BossLoot[itemLink] and not Save.notSellBoss then
            return BOSS
        end
    end
    if quality==0 and not Save.notSellJunk then--垃圾
        return BAG_FILTER_JUNK
    end
end
local function setSellItems()--出售物品
    if IsModifierKeyDown() then
        return
    end
    local num, gruop, preceTotale= 0, 0, 0
    for bag=0, NUM_BAG_SLOTS do--背包        
        for slot=0, GetContainerNumSlots(bag) do--背包数量
            local _, itemCount, locked, quality, _, _, itemLink, _, noValue, itemID = GetContainerItemInfo(bag,slot);--物品信息
            local checkText=CheckItemSell(itemID, itemLink, quality)--检察 ,boss掉落, 指定 或 出售灰色,宠物
            if itemID and itemLink and itemLink and not locked and checkText then
                UseContainerItem(bag, slot);--买出
                local prece =0
                if not noValue then--卖出钱
                    prece = (select(11, GetItemInfo(itemLink)) or 0)*itemCount;--价格
                    preceTotale = preceTotale + prece
                end
                num=num+itemCount--数量
                gruop=gruop+1--组
                print(checkText or '', itemLink, GetCoinTextureString(prece))
                if gruop>= 12 then
                    break
                end
            end
            if gruop>= 12 then
                break
            end
        end
    end
    if num > 0 then
        print(id, addName, '|cnGREEN_FONT_COLOR:'..gruop..'|r'..AUCTION_PRICE_PER_STACK, '|cnGREEN_FONT_COLOR:'..num..'|r'..AUCTION_HOUSE_QUANTITY_LABEL, GetCoinTextureString(preceTotale))
    end
end

--#######
--设置菜单
--#######
local function setCustomItemMenu(level)--二级菜单, 自定义出售
    local info = UIDropDownMenu_CreateInfo()
    info.text=CLEAR_ALL
    info.notCheckable=true
    info.func=function ()
        Save.Sell={}
    end
    UIDropDownMenu_AddButton(info, level)
    for itemID, boolean in pairs(Save.Sell) do
        if itemID then
            local itemLink= select(2, GetItemInfo(itemID))
            itemLink= itemLink or C_Item.GetItemNameByID(itemID) or ('itemID: ' .. itemID)
            info = UIDropDownMenu_CreateInfo()
            info.text= itemLink
            info.icon= C_Item.GetItemIconByID(itemID)
            info.checked=boolean
            info.func=function()
                if Save.Sell[itemID] then
                    Save.Sell[itemID]=nil
                else
                    Save.Sell[itemID]=true
                end
                print(id, addName, '|cnGREEN_FONT_COLOR:'..REMOVE..'|r'..AUCTION_HOUSE_SELL_TAB, itemLink)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end
end
local function setBossItemMenu(level)
    local info = UIDropDownMenu_CreateInfo()
    info.text=CLEAR_ALL
    info.notCheckable=true
    info.func=function ()
        BossLoot={}
    end
    UIDropDownMenu_AddButton(info, level)
    for itemLink, boolean in pairs(BossLoot) do
        if itemLink then
            info = UIDropDownMenu_CreateInfo()
            info.text=itemLink
            info.checked=boolean
            info.icon= C_Item.GetItemIconByID(itemLink)
            info.func=function()
                if Save.Sell[itemLink] then
                    Save.Sell[itemLink]=nil
                else
                    Save.Sell[itemLink]=true
                end
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end
end
local function InitList(self, level, menuLit)
    if menuLit=='CUSTOM' then
        setCustomItemMenu(level)
        return
    elseif menuLit=='BOSS' then
        setBossItemMenu(level)
        return
    end
    local info = UIDropDownMenu_CreateInfo()--出售垃圾
    info.text=	AUCTION_HOUSE_SELL_TAB..BAG_FILTER_JUNK
    info.checked= not Save.notSellJunk
    info.func=function ()
        if Save.notSellJunk then
            Save.notSellJunk=nil
        else
            Save.notSellJunk=true
        end
    end
    info.tooltipOnButton=true
    info.tooltipTitle=id..' '.. addName
    info.tooltipText='\n'..PROFESSIONS_CRAFTING_QUALITY:format('|cff606060'..ITEM_QUALITY0_DESC..'|r')
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()--自定义出售
    info.text=	AUCTION_HOUSE_SELL_TAB..CUSTOM
    info.checked= not Save.notSellCustom
    info.func=function ()
        if Save.notSellCustom then
            Save.notSellCustom=nil
        else
            Save.notSellCustom=true
        end
    end
    info.menuList='CUSTOM'
    info.hasArrow=true
    info.tooltipOnButton=true
    info.tooltipTitle=DRAG_MODEL..ITEMS
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()--出售BOSS掉落
    info.text=	AUCTION_HOUSE_SELL_TAB..TRANSMOG_SOURCE_1
    info.checked= not Save.notSellCustom
    info.func=function ()
        if Save.notSellBoss then
            Save.notSellBoss=nil
        else
            Save.notSellBoss=true
        end
    end
    info.menuList='BOSS'
    info.hasArrow=true
    info.tooltipOnButton=true
    info.tooltipTitle=STAT_AVERAGE_ITEM_LEVEL..' < ' ..(avgItemLevel and math.ceil(avgItemLevel)-15 or 15)
    UIDropDownMenu_AddButton(info)

    UIDropDownMenu_AddSeparator()
    info=UIDropDownMenu_CreateInfo()
    info.text=REPAIR_ALL_ITEMS
    info.checked=not Save.notAutoRepairAll
    info.func=function ()
        if Save.notAutoRepairAll then
            Save.notAutoRepairAll=nil
        else
            Save.notAutoRepairAll=true
        end
    end
    if CanGuildBankRepair() then
        local money=GetGuildBankMoney()
        if money and money>0 then
            info.tooltipOnButton=true
            info.tooltipTitle=GUILDCONTROL_OPTION15_TOOLTIP
            info.tooltipText=GUILDBANK_REPAIR..'\n'..GetCoinTextureString(money)
        end
    end
    UIDropDownMenu_AddButton(info)

    UIDropDownMenu_AddSeparator()
    info=UIDropDownMenu_CreateInfo()
    info.text=RUNECARVER_SCRAPPING_CONFIRMATION_TEXT..': '..DELETE_ITEM_CONFIRM_STRING
    info.checked= not Save.notDELETE
    info.func=function ()
        if Save.notDELETE then
            Save.notDELETE=nil
        else
            Save.notDELETE=true
        end
    end
    info.tooltipOnButton=true
    info.tooltipTitle=	DELETE_GOOD_ITEM
    UIDropDownMenu_AddButton(info)
end

local menuList= CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")--菜单列表
UIDropDownMenu_Initialize(menuList, InitList, "MENU")

local function setMenu()
    local frame=MerchantFrame
    if not frame or panel.set then
        return
    end
    panel.set=e.Cbtn(frame.TitleContainer)
    panel.set:SetNormalTexture(236994)
    panel.set:SetPoint('RIGHT', frame.TitleContainer ,'RIGHT', -25, 0)
    panel.set:SetSize(20, 20)
    panel.set:SetScript('OnClick', function(self2)
        ToggleDropDownMenu(1, nil, menuList, self2, 5,0)
    end)
    panel.set:SetScript('OnEnter', function()
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType=='item' and itemID then
            if Save.Sell[itemID] then
                Save.Sell[itemID]=nil
                print(id, addName, '|cnRED_FONT_COLOR:'..REMOVE..'|r',AUCTION_HOUSE_SELL_TAB, itemLink)
            else
                Save.Sell[itemID]=true
                print(id,addName, '|cnGREEN_FONT_COLOR:'..ADD..'|r'..AUCTION_HOUSE_SELL_TAB, itemLink )
                C_Timer.After(0.2, function()
                    if MerchantFrame and MerchantFrame:IsShown() then --and MerchantFrame.selectedTab == 1 then
                        setSellItems()
                    end
                end)
            end
            ClearCursor();
        end
    end)
end


hooksecurefunc('MerchantItemButton_OnModifiedClick', function(self, button)
    if ( MerchantFrame.selectedTab == 1 ) then
		if ( HandleModifiedItemClick(GetMerchantItemLink(self:GetID())) ) then
			return;
		end
		if ( IsModifiedClick("SPLITSTACK")) then
			local maxStack = GetMerchantItemMaxStack(self:GetID());
			local _, _, price, stackCount, _, _, _, extendedCost = GetMerchantItemInfo(self:GetID());

			local canAfford;
			if (price and price > 0) then
				canAfford = floor(GetMoney() / (price / stackCount));
			else
				canAfford = maxStack;
			end

			if (extendedCost) then
				local itemCount = GetMerchantItemCostInfo(self:GetID());
				for i = 1, MAX_ITEM_COST do
					local itemTexture, itemValue, itemLink, currencyName = GetMerchantItemCostItem(self:GetID(), i);
					if (itemLink and not currencyName) then
						local myCount = GetItemCount(itemLink, false, false, true);
						canAfford = min(canAfford, floor(myCount / (itemValue / stackCount)));
					end
				end
			end

			if ( maxStack > 1 ) then
				local maxPurchasable = min(maxStack, canAfford);
				--StackSplitFrame:OpenStackSplitFrame(maxPurchasable, self, "BOTTOMLEFT", "TOPLEFT", stackCount);
              --  print(maxPurchasable, stackCount)
			end
			return;
		end
    end
end)

--StackSplitFrame.lua
hooksecurefunc(StackSplitFrame,'OpenStackSplitFrame',function(self, maxStack, parent, anchor, anchorTo, stackCount)
    if not self:IsShown() then
        return
    end
    if not self.MaxButton then
        self.MaxButton=e.Cbtn(self.RightButton, true)
        self.MaxButton:SetPoint('LEFT', self.RightButton, 'RIGHT')
        self.MaxButton:SetText('>>')
        self.MaxButton:SetScript('OnClick', function()
            if self.isMultiStack then
                if self.split<5 then
                    sel.split=5
                elseif self.split<10 then
                    self.split=10
                else
                    self.split=self.split+10
                end
            else
                if self.split >= maxStack then
                    self.split = self.split + maxStack
                else
                    self.split = self.maxStack
                end
            end
            StackSplitFrame:UpdateStackText()
        end)

        self.MinButton=e.Cbtn(self.LeftButton, true)
        self.MinButton:SetPoint('RIGHT', self.LeftButton, 'LEFT')
        self.MinButton:SetText('<<')
        self.MinButton:SetScript('OnClick', function()
            if self.isMultiStack then
                if self.split>20 then
                    self.split=self.split-10
                elseif self.split>10 then
                    self.split=10
                elseif self.split>5 then
                    self.split=5
                else
                    self.split=1
                end
            else
                if self.split >= maxStack then
                    self.split = self.split - maxStack
                else
                    self.split = self.split- maxStack/2
                end
            end
            if self.split<1 then
                self.split=1
            end
            StackSplitFrame:UpdateStackText()
        end)
   end
end)
--######
--DELETE
--######
hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"],"OnShow",function(self)
    if not Save.notDELETE then
        self.editBox:SetText(DELETE_ITEM_CONFIRM_STRING);
    end
end)
hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_QUEST_ITEM"],"OnShow",function(self)
    if not Save.notDELETE and self.editBox then
        self.editBox:SetText(DELETE_CONFIRM_STRING);
    end
end)
hooksecurefunc(StaticPopupDialogs["CONFIRM_DESTROY_COMMUNITY"],"OnShow",function(self)
    if not Save.notDELETE and self.editBox then
        self.editBox:SetText(COMMUNITIES_DELETE_CONFIRM_STRING);
    end
end)
--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:RegisterEvent('MERCHANT_SHOW')
panel:RegisterEvent('UPDATE_INVENTORY_DURABILITY')

panel:RegisterEvent('ENCOUNTER_LOOT_RECEIVED')
panel:RegisterEvent('PLAYER_AVG_ITEM_LEVEL_UPDATE')

panel:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
    if event == "ADDON_LOADED" and arg1==id then
            Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save
            avgItemLevel= GetAverageItemLevel()--装等

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    elseif event=='MERCHANT_SHOW' then
        if not Save.disabled then
            setDurabiliy()--显示耐久度
            setAutoRepairAll()--自动修理
            setSellItems()--出售物品
        end
        setMenu()--设置菜单
    elseif event=='UPDATE_INVENTORY_DURABILITY' then
        setDurabiliy()

    elseif event=='ENCOUNTER_LOOT_RECEIVED' then
        bossLoot(arg2, arg3)
    elseif event=='PLAYER_AVG_ITEM_LEVEL_UPDATE' then
        avgItemLevel= GetAverageItemLevel()--装等
    end
end)