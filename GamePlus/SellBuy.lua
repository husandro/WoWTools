local id, e = ...
local Save={noSell={}, Sell={}, }
local bossSave={}
local buySave={}--购买物品
local addName=MERCHANT
local panel=CreateFrame("Frame")
local RepairSave={date=date('%x'), player=0, guild=0, num=0}

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
    if not Save.disabled and not Save.notAutoRepairAll and button then
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
    if Save.notAutoRepairAll or not CanMerchantRepair() or IsModifierKeyDown() or Save.disabled then
        return
    end
    local Co, Can   = GetRepairAllCost();
    if Can and Co>0 then
        if CanGuildBankRepair() and GetGuildBankMoney()>=Co  then
            RepairAllItems(true);
            RepairSave.guild=RepairSave.guild+Co
            RepairSave.num=RepairSave.num+1
            print(id, addName, GUILDCONTROL_OPTION15_TOOLTIP, GetCoinTextureString(Co))
        else
            if GetMoney()>=Co then
                RepairAllItems();
                RepairSave.player=RepairSave.player+Co
                RepairSave.num=RepairSave.num+1
                print(id, addName, '|cnGREEN_FONT_COLOR:'..REPAIR_COST..'|r', GetCoinTextureString(Co));
            else
                print(id, addName, '|cnRED_FONT_COLOR:'..FAILED..'|r', REPAIR_COST, GetCoinTextureString(Co));
            end
        end
        
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
        bossSave[itemLink]=true
    end
end

local function CheckItemSell(itemID, itemLink, quality)--检测是否是出售物品
    if itemID then
        if Save.noSell[itemID] then
            return
        end
        if Save.Sell[itemID] and not Save.notSellCustom then
            return CUSTOM
        end
        if bossSave[itemLink] and not Save.notSellBoss then
            return BOSS
        end
    end
    if e.itemPetID[itemID] then--宠物对换
        return
    end
    if quality==0 and not Save.notSellJunk then--垃圾
        return BAG_FILTER_JUNK
    end
end
local function setSellItems()--出售物品
    if IsModifierKeyDown() or Save.disabled then
        return
    end
    local num, gruop, preceTotale= 0, 0, 0
    for bag=0, NUM_BAG_SLOTS do--背包        
        for slot=0, C_Container.GetContainerNumSlots(bag) do--背包数量
            local _, itemCount, locked, quality, _, _, itemLink, _, noValue, itemID = C_Container.GetContainerItemInfo(bag,slot);--物品信息
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
                print(AUCTION_HOUSE_SELL_TAB, checkText or '', itemLink, GetCoinTextureString(prece))
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
        print(id, addName, AUCTION_HOUSE_SELL_TAB, '|cnGREEN_FONT_COLOR:'..gruop..'|r'..AUCTION_PRICE_PER_STACK, '|cnGREEN_FONT_COLOR:'..num..'|r'..AUCTION_HOUSE_QUANTITY_LABEL, GetCoinTextureString(preceTotale))
    end
end

--#######
--购买物品
--#######
local function setBuyItems()--购买物品
    if IsModifierKeyDown() or Save.notAutoBuy or Save.disabled then
        return
    end
    local Tab={}
    local merchantNum=GetMerchantNumItems()
    for index=1, merchantNum do
        local itemID=GetMerchantItemID(index)
        local num= itemID and buySave[itemID]
        if num then
            local buyNum=num-GetItemCount(itemID, true)
            if buyNum>0 then
                local maxStack = GetMerchantItemMaxStack(index);
                local _, _, price, stackCount, _, _, _, extendedCost = GetMerchantItemInfo(index)
                local canAfford;
                if (price and price > 0) then
                    canAfford = floor(GetMoney() / (price / stackCount));
                end
                if (extendedCost) then
                    for i = 1, MAX_ITEM_COST do
                        local _, itemValue, itemLink, currencyName = GetMerchantItemCostItem(index, i);
                        if itemLink and itemValue and itemValue>0 then
                            if not currencyName then
                                local myCount = GetItemCount(itemLink, false, false, true);
                                local value= floor(myCount / (itemValue / stackCount))
                                canAfford=not canAfford and value or min(canAfford, value)
                            elseif currencyName then
                               local info= C_CurrencyInfo.GetCurrencyInfoFromLink(itemLink)
                               if info and info.quantity then
                                    local value=floor(info.quantity / (itemValue / stackCount))
                                    canAfford= not canAfford and value or min(canAfford, value)
                                else
                                    canAfford=0
                               end
                            end
                        end
                    end
                end
                if canAfford and canAfford>=buyNum and floor(buyNum/stackCount)>0 then
                    while buyNum>0 do
                        local stack=floor(buyNum/stackCount)
                        if IsModifierKeyDown() or stack<1 then
                            break
                        end
                        local buy=buyNum
                        if stackCount>1 then
                            if buy>=maxStack then
                                buy=maxStack
                            else
                                buy=stack*stackCount
                            end
                        else
                            buy=buy>maxStack and maxStack or buy
                        end
                        BuyMerchantItem(index, buy)
                        buyNum=buyNum-buy
                    end
                    local itemLink=GetMerchantItemLink(index)
                    if itemLink then
                        Tab[itemLink]=num
                    end
                end
            end
        end
    end
    C_Timer.After(1.5, function()
        for itemLink2, num2 in pairs(Tab) do
            print(id, addName, TUTORIAL_TITLE20, '|cnGREEN_FONT_COLOR:'..num2..'|r', itemLink2)
        end
    end)
end

--###################
--购回物品,禁止买出物品
--###################
local function setBuyBackItems()
    if IsModifierKeyDown() or Save.disabled then
        return
    end
    local tab={}
    for buybackSlotIndex=1, GetNumBuybackItems() do
       local itemID = C_MerchantFrame.GetBuybackItemID(buybackSlotIndex)
        if itemID and Save.noSell[itemID] then
            local itemLink=GetBuybackItemLink(buybackSlotIndex)
            BuybackItem(buybackSlotIndex)
            if itemLink then
                tab[itemLink]=true
            end
        end
    end
    C_Timer.After(0.3, function()
        for itemLink, _ in pairs(tab) do
            print(id, addName, BUYBACK, itemLink)
        end
    end)
end
local function setMerchantInfo()
    local selectedTab= MerchantFrame.selectedTab
    local page= selectedTab == 1 and MERCHANT_ITEMS_PER_PAGE or BUYBACK_ITEMS_PER_PAGE
    for i=1, page do
		local index = selectedTab==1 and (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i) or i
        local itemButton= _G["MerchantItem"..i]
        if itemButton then
            local num
            if itemButton:IsShown() and not Save.disabled then
                local itemID
                if selectedTab==1 then
                    itemID = GetMerchantItemID(index)
                else
                    itemID=C_MerchantFrame.GetBuybackItemID(index)
                end
                num=(not Save.notAutoBuy and itemID) and buySave[itemID]
                num= num and num..'|T236994:0|t'
                if not Save.notShowBagNum then
                    local bag=itemID and GetItemCount(itemID,true)
                    if bag and bag>0 then
                        num=(num and num..'\n' or '')..bag..e.Icon.bank2
                    end
                end
                if num then
                    if not itemButton.buyItemNum then
                        itemButton.buyItemNum=e.Cstr(itemButton)
                        --itemButton.buyItemNum:SetPoint('BOTTOMRIGHT', _G["MerchantItem"..index.."Name"],0,-8)
                        itemButton.buyItemNum:SetPoint('BOTTOMRIGHT')
                    end
                    itemButton.buyItemNum:SetText(num)
                    num=true
                end
            end
            if itemButton.buyItemNum then
                itemButton.buyItemNum:SetShown(num)
            end
        end
    end
end
hooksecurefunc('MerchantFrame_UpdateMerchantInfo',setMerchantInfo)--MerchantFrame.lua
hooksecurefunc('MerchantFrame_UpdateBuybackInfo', setMerchantInfo)

--#######
--设置菜单
--#######
local function setCustomItemMenu(level)--二级菜单, 自定义出售
    local info = UIDropDownMenu_CreateInfo()
    info.text=CLEAR_ALL
    info.notCheckable=true
    info.func=function ()
        Save.Sell={}
        CloseDropDownMenus();
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
                Save.Sell[itemID]=nil
                print(id, addName, '|cnGREEN_FONT_COLOR:'..REMOVE..'|r'..AUCTION_HOUSE_SELL_TAB, itemLink)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end
end
local function setBossItemMenu(level)--二级菜单, BOSS
    local info = UIDropDownMenu_CreateInfo()
    info.text=CLEAR_ALL
    info.notCheckable=true
    info.func=function ()
        bossSave={}
        CloseDropDownMenus();
    end
    UIDropDownMenu_AddButton(info, level)
    for itemLink, boolean in pairs(bossSave) do
        if itemLink then
            info = UIDropDownMenu_CreateInfo()
            info.text=itemLink
            info.checked=boolean
            info.icon= C_Item.GetItemIconByID(itemLink)
            info.func=function()
                Save.Sell[itemLink]=nil
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end
end
local function setBuyItemMenu(level)--二级菜单, 购买物品
    local info = UIDropDownMenu_CreateInfo()
    info.text=CLEAR_ALL
    info.notCheckable=true
    info.func=function ()
        buySave={}
        setMerchantInfo()
        CloseDropDownMenus();
    end
    UIDropDownMenu_AddButton(info, level)
    for itemID, num in pairs(buySave) do
        if itemID and num then
            local bag=GetItemCount(itemID)
            local bank=GetItemCount(itemID, true)-bag
            local itemLink= select(2, GetItemInfo(itemID))
            itemLink= itemLink or C_Item.GetItemNameByID(itemID) or ('itemID: ' .. itemID)
            info = UIDropDownMenu_CreateInfo()
            info.text='|cnGREEN_FONT_COLOR:'..num..'|r '..itemLink..' '..'|cnYELLOW_FONT_COLOR:'..bag..e.Icon.bag2..bank..e.Icon.bank2..'|r'
            info.checked= true
            info.icon= C_Item.GetItemIconByID(itemID)
            info.func=function()
                buySave[itemID]=nil
                setMerchantInfo()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end
end
local function setBuybackItemMenu(level)--二级菜单, 购回物品
    local info = UIDropDownMenu_CreateInfo()
    info.text=CLEAR_ALL
    info.notCheckable=true
    info.func=function ()
        Save.noSell={}
        CloseDropDownMenus();
    end
    UIDropDownMenu_AddButton(info, level)
    for itemID, _ in pairs(Save.noSell) do
        if itemID then
            local bag=GetItemCount(itemID)
            local bank=GetItemCount(itemID, true)-bag
            local itemLink= select(2, GetItemInfo(itemID))
            itemLink= itemLink or C_Item.GetItemNameByID(itemID) or ('itemID: ' .. itemID)
            info = UIDropDownMenu_CreateInfo()
            info.text=itemLink..' '..'|cnYELLOW_FONT_COLOR:'..bag..e.Icon.bag2..bank..e.Icon.bank2..'|r'
            info.checked= true
            info.icon= C_Item.GetItemIconByID(itemID)
            info.func=function()
                Save.noSell[itemID]=nil
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
    elseif menuLit=='BUY' then
        setBuyItemMenu(level)
        return
    elseif menuLit=='BUYBACK' then
        setBuybackItemMenu(level)
        return
    end
    local num
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
    num=0
    for _, boolean in pairs(Save.Sell) do
        if boolean then
            num=num+1
        end
    end
    info.text=	AUCTION_HOUSE_SELL_TAB..CUSTOM..'|cnRED_FONT_COLOR: #'..num..'|r'
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
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()--出售BOSS掉落
    num=0
    for _, boolean in pairs(bossSave) do
        if boolean then
            num=num+1
        end
    end
    info.text=	AUCTION_HOUSE_SELL_TAB..TRANSMOG_SOURCE_1..'|cnRED_FONT_COLOR: #'..num..'|r'
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
    info = UIDropDownMenu_CreateInfo()--购回
    num=0
    for _, boolean in pairs(Save.noSell) do
        if boolean then
            num=num+1
        end
    end
    info.text= BUYBACK..'|cnRED_FONT_COLOR: #'..num..'|r'
    info.notCheckable=true
    info.menuList='BUYBACK'
    info.hasArrow=true
    UIDropDownMenu_AddButton(info)

    UIDropDownMenu_AddSeparator()
    info=UIDropDownMenu_CreateInfo()--购买物品
    num=0
    for _, boolean in pairs(buySave) do
        if boolean then
            num=num+1
        end
    end
    info.text=AUTO_JOIN:gsub(JOIN,'')..PURCHASE..'|cnGREEN_FONT_COLOR: #'..num..'|r'
    info.checked=not Save.notAutoBuy
    info.func=function ()
        if Save.notAutoBuy then
            Save.notAutoBuy=nil
        else
            Save.notAutoBuy=true
        end
        setMerchantInfo()
    end
    info.menuList='BUY'
    info.hasArrow=true
    UIDropDownMenu_AddButton(info)

    UIDropDownMenu_AddSeparator()
    info=UIDropDownMenu_CreateInfo()--自动修理
    info.text=REPAIR_ALL_ITEMS
    info.checked=not Save.notAutoRepairAll
    info.func=function ()
        if Save.notAutoRepairAll then
            Save.notAutoRepairAll=nil
        else
            Save.notAutoRepairAll=true
        end
        setDurabiliy()
    end
    info.tooltipOnButton=true
    info.tooltipTitle=GUILD_BANK_MONEY_LOG.. ' '..RepairSave.date
    local text=	MINIMAP_TRACKING_REPAIR..': '..RepairSave.num..' '..VOICEMACRO_LABEL_CHARGE1
                ..'\n'..GUILD..': '..GetCoinTextureString(RepairSave.guild)
                ..'\n'..PLAYER..': '..GetCoinTextureString(RepairSave.player)
    if RepairSave.guild>0 and RepairSave.player>0 then
        text=text..'\n\n'..TOTAL..': '..GetCoinTextureString(RepairSave.guild+RepairSave.player)
    end
    if CanGuildBankRepair() then
        text=text..'\n\n'..GUILDBANK_REPAIR..'\n'..GetCoinTextureString(GetGuildBankMoney())
    end
    info.tooltipText=text
    UIDropDownMenu_AddButton(info)

    UIDropDownMenu_AddSeparator()
    info=UIDropDownMenu_CreateInfo()--显示数物品,拥有数量,在商人界面
    info.text=SHOW..e.Icon.bank2..AUCTION_HOUSE_QUANTITY_LABEL
    info.checked= not Save.notShowBagNum
    info.func=function ()
        if Save.notShowBagNum then
            Save.notShowBagNum=nil
        else
            Save.notShowBagNum=true
        end
        setMerchantInfo()
    end
    UIDropDownMenu_AddButton(info)


    info=UIDropDownMenu_CreateInfo()--删除字符
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

    info=UIDropDownMenu_CreateInfo()--堆叠数量
    info.text=AUCTION_STACK_SIZE.. ' Plus'
    info.checked= not Save.notStackSplit
    info.func=function ()
        if Save.notStackSplit then
            Save.notStackSplit=nil
        else
            Save.notStackSplit=true
        end
    end
    if not Save.notStackSplit then
        info.tooltipOnButton=true
        info.tooltipTitle=	NEED..' /reload'
    end
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
    if Save.disabled then
        panel.set:SetNormalAtlas(e.Icon.icon)
    else
        panel.set:SetNormalTexture(236994)
    end
    panel.set:SetPoint('RIGHT', frame.TitleContainer ,'RIGHT', -25, 0)
    panel.set:SetSize(20, 20)
    panel.set:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT");
        e.tips:ClearLines();
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(e.GetEnabeleDisable(not Save.disabled), e.Icon.right)
        if not Save.disabled then
            e.tips:AddLine(' ')
            local infoType, itemID, itemLink = GetCursorInfo()
            if infoType=='item' and itemID and itemLink then
                local icon=C_Item.GetItemIconByID(itemLink)
                e.tips:AddDoubleLine(itemLink, icon and '|T'..icon..':0|t' or ' ')
                if Save.Sell[itemID] then
                    e.tips:AddDoubleLine(REMOVE, AUCTION_HOUSE_SELL_TAB, 1,0,0, 1,0,0)
                else
                    e.tips:AddDoubleLine(ADD, AUCTION_HOUSE_SELL_TAB, 0,1,0, 0,1,0)
                end
            elseif infoType=='merchant' and itemID then--购买物品
                itemID= GetMerchantItemID(itemID)

                e.tips:AddDoubleLine(PURCHASE..((itemID and buySave[itemID]) and '|cnRED_FONT_COLOR:'..SLASH_CHAT_MODERATE2..' '..buySave[itemID]..'|r' or '' ), ITEMS, 0,1,0, 0,1,0)
            else
                e.tips:AddDoubleLine(DRAG_MODEL..e.Icon.left..ITEMS, AUCTION_HOUSE_SELL_TAB..'/'..PURCHASE)
                e.tips:AddDoubleLine(MAINMENU or SLASH_TEXTTOSPEECH_MENU, e.Icon.left)
            end
        end
        e.tips:Show()
    end)
    panel.set:SetScript('OnMouseUp', function(self2, d)
        if d=='RightButton' then
            if Save.disabled then
                Save.disabled=nil
                panel.set:SetNormalTexture(236994)
            else
                Save.disabled=true
                panel.set:SetNormalAtlas(e.Icon.icon)
            end
            panel.noSell:SetShown(not Save.disabled)
            return
        end
        if Save.disabled then
            return
        end
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType=='item' and itemID then
            if Save.Sell[itemID] then
                Save.Sell[itemID]=nil
                print(id, addName, '|cnRED_FONT_COLOR:'..REMOVE..'|r',AUCTION_HOUSE_SELL_TAB, itemLink)
            else
                Save.Sell[itemID]=true
                Save.noSell[itemID]=nil
                buySave[itemID]=nil
                print(id,addName, '|cnGREEN_FONT_COLOR:'..ADD..'|r'..AUCTION_HOUSE_SELL_TAB, itemLink )
                C_Timer.After(0.2, function()
                    if MerchantFrame and MerchantFrame:IsShown() then --and MerchantFrame.selectedTab == 1 then
                        setSellItems()
                    end
                end)
            end
            ClearCursor();
        elseif infoType=='merchant' and itemID then--购买物品
            local index=itemID
            itemID= GetMerchantItemID(index)
            itemLink=GetMerchantItemLink(index)
            if itemID and itemLink then
                local icon= C_Item.GetItemIconByID(itemLink)
                icon= icon and '|T'..icon..':0|t' or ''
                StaticPopupDialogs[id..addName..'Buy']={
                    text =id..' '..addName
                    ..'\n\n'..AUTO_JOIN:gsub(JOIN,'')..PURCHASE..': '..icon ..itemLink
                    ..'\n\n'..e.Icon.player..e.Player.name_server..': ' ..AUCTION_HOUSE_QUANTITY_LABEL
                    ..'\n\n0: '..(CLEAR or KEY_NUMLOCK_MAC)
                    ..(Save.notAutoBuy and '\n\n'..AUTO_JOIN:gsub(JOIN,'')..PURCHASE..': '..e.GetEnabeleDisable(flse) or ''),
                    button1 = PURCHASE,
                    button2 = CANCEL,
                    hasEditBox=true,whileDead=true,timeout=60,hideOnEscape = 1,
                    OnAccept=function(s)
                        local num= s.editBox:GetNumber()
                        if num==0 then
                            buySave[itemID]=nil
                            print('|cnGREEN_FONT_COLOR:'..(CLEAR or KEY_NUMLOCK_MAC)..'|r', itemLink)
                        else
                            buySave[itemID]=num
                            Save.Sell[itemID]=nil
                            print(PURCHASE, '|cnGREEN_FONT_COLOR:'..num..'|r', itemLink)
                            setBuyItems()
                        end
                        ClearCursor();
                    end,
                    OnShow=function(s)
                        s.editBox:SetNumeric(true);
                        if buySave[itemID] then
                            s.editBox:SetText(buySave[itemID])
                        end
                    end,
                    EditBoxOnEscapePressed = function(s) s:GetParent():Hide() end,
                }
                StaticPopup_Show(id..addName..'Buy');
            end
        else
            ToggleDropDownMenu(1, nil, menuList, self2, 5,0)
        end
    end)
    panel.set:SetScript('OnLeave', function() e.tips:Hide() end)

    panel.noSell=e.Cbtn(panel.set, nil, false)--购回
    panel.noSell:SetPoint('RIGHT', panel.set, 'LEFT', -2, 0)
    panel.noSell:SetSize(20, 20)
    panel.noSell:SetScript('OnMouseUp', function(self2)
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType=='item' and itemID then
            if Save.noSell[itemID] then
                Save.noSell[itemID]=nil
                print(id, addName,'|cnGREEN_FONT_COLOR:'.. REMOVE..'|r', BUYBACK, itemLink)
            else
                Save.noSell[itemID]=true
                Save.Sell[itemID]=nil
                print(id,addName, '|cnGREEN_FONT_COLOR:'..ADD..'|r', BUYBACK, itemLink )
                C_Timer.After(0.2, function()
                    if MerchantFrame and MerchantFrame:IsShown() then --and MerchantFrame.selectedTab == 1 then
                        setBuyBackItems()--购回物品
                    end
                end)
            end
            ClearCursor();
        end
    end)
    panel.noSell:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT");
        e.tips:ClearLines();
        e.tips:AddDoubleLine(id, addName)
        local num=0
        for _, _  in pairs(Save.noSell) do
            num=num+1
        end
        e.tips:AddDoubleLine(ITEMS, '|cnGREEN_FONT_COLOR: #'..num..'|r')
        e.tips:AddLine(' ')
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType=='item' and itemID and itemLink then

            local icon=C_Item.GetItemIconByID(itemLink)
            e.tips:AddDoubleLine(itemLink, icon and '|T'..icon..':0|t' or ' ')
            if Save.noSell[itemID] then
                e.tips:AddDoubleLine(REMOVE, BUYBACK, 1,0,0, 1,0,0)
            else
                e.tips:AddDoubleLine(ADD, BUYBACK, 0,1,0, 0,1,0)
            end
        else
            e.tips:AddDoubleLine(DRAG_MODEL..e.Icon.left..ITEMS, BUYBACK)
        end
        e.tips:Show()
    end)
    panel.noSell:SetScript('OnLeave', function() e.tips:Hide() end)
    panel.noSell:SetShown(not Save.disabled)
end
--StackSplitFrame.lua 堆叠,数量,框架
hooksecurefunc(StackSplitFrame,'OpenStackSplitFrame',function(self, maxStack, parent, anchor, anchorTo, stackCount)
    if Save.notStackSplit or Save.disabled then
        return
    end
    if not self.restButton then
        local function setButton()
            self.RightButton:SetEnabled(self.split<self.maxStack)
            self.LeftButton:SetEnabled(self.split>self.minSplit)
        end
        self.restButton=e.Cbtn(self)--重置
        self.restButton:SetPoint('TOP')
        self.restButton:SetSize(22, 22)
        self.restButton:SetNormalAtlas('characterundelete-RestoreButton')
        self.restButton:SetScript('OnClick', function(self2)
            self.split=self.minSplit
            self.LeftButton:SetEnabled(false)
            self.RightButton:SetEnabled(true)
            StackSplitFrame:UpdateStackText()
            setButton()
        end)
        self.restButton:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, 'ANCHOR_LEFT')
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, addName)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(AUCTION_STACK_SIZE..' Plus', '|cnGREEN_FONT_COLOR:'..RESET..'|r')
            e.tips:Show()
        end)
        self.restButton:SetScript('OnLeave', function() e.tips:Hide() end)
        
        self.MaxButton=e.Cbtn(self, nil, nil, nil,nil, true)
        self.MaxButton:SetSize(40, 20)
        self.MaxButton:SetNormalFontObject('NumberFontNormalYellow')
        self.MaxButton:SetPoint('LEFT', self.restButton, 'RIGHT')
        self.MaxButton:SetScript('OnMouseDown', function(self2)
            self.split=self.maxStack
            StackSplitFrame:UpdateStackText()
            setButton()
        end)

        self.MetaButton=e.Cbtn(self, nil, nil, nil,nil, true)
        self.MetaButton:SetSize(40, 20)
        self.MetaButton:SetNormalFontObject('NumberFontNormalYellow')
        self.MetaButton:SetPoint('RIGHT', self.restButton, 'LEFT')
        self.MetaButton:SetScript('OnMouseDown', function(self2)
            self.split=floor(self.maxStack/2)
            StackSplitFrame:UpdateStackText()
            setButton()
        end)

        self.editBox=CreateFrame('EditBox', nil, self)--输入框
        self.editBox:SetSize(100, 23)
        self.editBox:SetPoint('RIGHT', self.RightButton, 'LEFT',-12, 0)
        self.editBox:SetAutoFocus(false)
        self.editBox:SetFontObject("ChatFontNormal")
        self.editBox:SetMultiLine(false)
        self.editBox:SetNumeric(true)
        self.editBox:SetScript('OnEditFocusLost', function(self2) self2:SetText('') end)
        self.editBox:SetScript("OnEscapePressed",function(self2) self2:ClearFocus() end)
        self.editBox:SetScript('OnEnterPressed', function(self2) self2:ClearFocus() end)
        self.editBox:SetScript('OnTextChanged',function(self2, userInput)
            if not userInput then
                return
            end
            local num=self2:GetNumber()
            if self.isMultiStack then
                num=floor(num/self.minSplit) * self.minSplit
            end
            num= num<self.minSplit and self.minSplit or num
            num= num>self.maxStack and self.maxStack or num
            self.RightButton:SetEnabled(num<self.maxStack)
            self.LeftButton:SetEnabled(num==self.minSplit)
            self.split=num
            StackSplitFrame:UpdateStackText()
            setButton()
        end)
    end

    self.MaxButton:SetText(self.maxStack)
    self.MetaButton:SetText(floor(self.maxStack/2))
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

panel:RegisterEvent('MERCHANT_UPDATE')--购回

panel:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
    if event == "ADDON_LOADED" and arg1==id then
        if WoWToolsSave then
            Save= WoWToolsSave[addName] or Save
            buySave=WoWToolsSave.BuyItems and WoWToolsSave.BuyItems[e.Player.name_server] or buySave--购买物品
            RepairSave=WoWToolsSave.Repair and WoWToolsSave.Repair[e.Player.name_server] or RepairSave--修理
        end
        avgItemLevel= GetAverageItemLevel()--装等

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
            WoWToolsSave.BuyItems=WoWToolsSave.BuyItems or {}--购买物品
            WoWToolsSave.BuyItems[e.Player.name_server]=buySave
            WoWToolsSave.Repair=WoWToolsSave.Repair or {}--修理
            WoWToolsSave.Repair[e.Player.name_server] = RepairSave
        end
    elseif event=='MERCHANT_SHOW' then
        setDurabiliy()--显示耐久度
        setAutoRepairAll()--自动修理
        setSellItems()--出售物品
        setBuyItems()--购买物品
        setMenu()--设置菜单
    elseif event=='UPDATE_INVENTORY_DURABILITY' then
        setDurabiliy()

    elseif event=='ENCOUNTER_LOOT_RECEIVED' then--买出BOOS装备
        bossLoot(arg2, arg3)

    elseif event=='PLAYER_AVG_ITEM_LEVEL_UPDATE' then
        avgItemLevel= GetAverageItemLevel()--装等

    elseif event=='MERCHANT_UPDATE' then
        setBuyBackItems()--回购
    end
end)

--name, texture, price, stackCount, numAvailable, isPurchasable, isUsable, extendedCost, currencyID, spellID = GetMerchantItemInfo(index);