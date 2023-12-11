local id, e = ...
local Save={
    noSell={
        [144341]=true,--[可充电的里弗斯电池]
        [49040]=true,--[基维斯]
        [114943]=true,--[终极版侏儒军刀]
        [103678]=true,--迷时神器
        [142469]=true,--魔导大师的紫罗兰印戒
        [139590]=true,--[传送卷轴：拉文霍德]
        [144391]=true,--拳手的重击指环
        [144392]=true,--拳手的重击指环
        [37863]=true,--[烈酒的遥控器]
    },
    Sell={
        [34498]=true,--[纸飞艇工具包]
    },
    altDisabledAutoLoot= e.Player.husandro,--打开拾取窗口时，下次禁用，自动拾取
    --sellJunkMago=true,--出售，可幻化，垃圾物品
    --notPlus=true,--商人 Pluse,加宽

    --拍卖行
    --hideSellItemList=true,--隐藏，物品列表
    intShowSellItem= e.Player.husandro,--显示，转到出售物品
    isMaxSellItem=e.Player.husandro,--出售物品时，使用，最大数量
    hideSellItem={},--跳过，拍卖行物品
    SellItemDefaultPrice={},--默认价格
}

local addName= MERCHANT
local panel= CreateFrame("Frame")
local RepairSave={date=date('%x'), player=0, guild=0, num=0}


--MerchantFrame.lua
local bossSave={}
local buySave={}--购买物品




--MerchantFrame.lua










--#########
--设置耐久度
--#########
local function set_Durabiliy_Value_Text()--设置耐久度
    local text
    if not Save.notAutoRepairAll then
        if not MerchantRepairAllButton.durabiliyText then
            MerchantRepairAllButton.durabiliyText=e.Cstr(MerchantRepairAllButton)
            MerchantRepairAllButton.durabiliyText:SetPoint('TOPLEFT')
        end
        text= e.GetDurabiliy()
    end
    if MerchantRepairAllButton.durabiliyText then
        MerchantRepairAllButton.durabiliyText:SetText(text or '')
    end
end























--#######
--自动修理
--#######
local function setAutoRepairAll()
    if Save.notAutoRepairAll or not CanMerchantRepair() or IsModifierKeyDown() then
        return
    end
    local Co, Can= GetRepairAllCost();
    if Can and Co and Co>0 then
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
    and itemLevel and itemLevel>1 and avgItemLevel-itemLevel>=15
    and not Save.noSell[itemID]
    then
        bossSave[itemID]=true
        if not Save.notSellBoss then
            print(addName, '|cnGREEN_FONT_COLOR:'.. (e.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB) ,itemLink, itemID)
        end
    end
end






















--####################
--检测是否是出售物品
--为 ItemInfo.lua, 用
e.CheckItemSell= function(itemID, quality)
    if itemID then
        if Save.noSell[itemID] then
            return

        elseif Save.Sell[itemID] and not Save.notSellCustom then
            return e.onlyChinese and '自定义' or CUSTOM

        elseif quality==0 and e.GetPet9Item(itemID, true) then--宠物兑换, wow9.0
            return e.onlyChinese and '宠物' or PET

        elseif bossSave[itemID] and not Save.notSellBoss then
            return e.onlyChinese and '首领' or BOSS

        elseif quality==0 and not Save.notSellJunk then--垃圾
            if Save.sellJunkMago then
                return e.onlyChinese and '垃圾' or BAG_FILTER_JUNK

            else
                local classID, subclassID = select(6, GetItemInfoInstant(itemID))
                if (classID==2 or classID==4) and subclassID~=0 then
                    local isCollected = select(2, e.GetItemCollected(itemID, nil, nil))--物品是否收集
                    if isCollected==false then
                        return
                    end
                end
                return e.onlyChinese and '垃圾' or BAG_FILTER_JUNK
            end
        end
    end
end





























--#######
--出售物品
--#######
local function setSellItems()
    if IsModifierKeyDown() then
        return
    end
    local num, gruop, preceTotale= 0, 0, 0
    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES do
        for slot=1, C_Container.GetContainerNumSlots(bag) do--背包数量
            local info = C_Container.GetContainerItemInfo(bag,slot)
            if info
                and info.hyperlink
                and info.itemID
                and info.quality
                and (info.quality<5 or Save.Sell[info.itemID]and not Save.notSellCustom)
            then
                local checkText= e.CheckItemSell(info.itemID, info.quality)--检察 ,boss掉落, 指定 或 出售灰色,宠物
                if not info.isLocked and checkText then
                    C_Container.UseContainerItem(bag, slot)--买出

                    local prece =0
                    if not info.hasNoValue then--卖出钱
                        prece = (select(11, GetItemInfo(info.hyperlink)) or 0) * (C_Container.stackCount or 1);--价格
                        preceTotale = preceTotale + prece
                    end
                    gruop= gruop+ 1
                    num= num+ (C_Container.stackCount or 1)--数量

                    print('|cnRED_FONT_COLOR:'..gruop..')|r', checkText or '', info.hyperlink, GetCoinTextureString(prece))

                    if gruop>= 11 then
                        break
                    end
                end
                if gruop>= 11 then
                    break
                end
            end
        end
    end
    if num > 0 then
        print(
            id, addName,
            (e.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB)..' |cnGREEN_FONT_COLOR:'..gruop..'|r'..(e.onlyChinese and '组' or AUCTION_PRICE_PER_STACK),
            '|cnGREEN_FONT_COLOR:'..num..'|r'..(e.onlyChinese and '件' or AUCTION_HOUSE_QUANTITY_LABEL),
            GetCoinTextureString(preceTotale)
        )
    end
end

















--#######
--购买物品
--#######
local function set_Buy_Items()--购买物品
    if IsModifierKeyDown() or Save.notAutoBuy then
        return
    end
    local Tab={}
    local merchantNum=GetMerchantNumItems()
    for index=1, merchantNum do
        local itemID=GetMerchantItemID(index)
        local num= itemID and buySave[itemID]
        if itemID and num then
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
            print(addName, e.onlyChinese and '正在购买' or TUTORIAL_TITLE20, '|cnGREEN_FONT_COLOR:'..num2..'|r', itemLink2)
        end
    end)
end


































--###################
--购回物品,禁止买出物品
--###################
local function set_BuyBack_Items()
    if IsModifierKeyDown() then
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
























--商人Pluse. 设置, 提示, 信息
--#########################
local function Set_Merchant_Info()--设置, 提示, 信息
    local selectedTab= MerchantFrame.selectedTab
    local isMerce= selectedTab == 1
    local page= isMerce and MERCHANT_ITEMS_PER_PAGE or BUYBACK_ITEMS_PER_PAGE
    local numItem= isMerce and  GetMerchantNumItems() or GetNumBuybackItems();
    --for i=1, page do
    for index=1, page do
		--local index = selectedTab==1 and (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i) or i
        local btn= _G["MerchantItem"..index]
        --local itemButton= _G["MerchantItem"..index.."ItemButton"]

        local text, spellID
        local num, itemID
        if btn and index<= numItem then
            local itemLink
            if isMerce then
                itemID= GetMerchantItemID(index)
                itemLink=  GetMerchantItemLink(index)
            else
                itemID= C_MerchantFrame.GetBuybackItemID(index)
                itemLink= GetBuybackItemLink(index)
            end


            num=(not Save.notAutoBuy and itemID) and buySave[itemID]--自动购买， 数量
            num= num and num..'|T236994:0|t'
            --if not Save.notShowBagNum then--包里，银行，总数
                --包里，银行，总数
                local bag=itemID and GetItemCount(itemID,true)
                if bag and bag>0 then
                    num=(num and num..'|n' or '')..bag..e.Icon.bank2
                end
            --end
            if num and not btn.buyItemNum then
                btn.buyItemNum=e.Cstr(btn)
                btn.buyItemNum:SetPoint('RIGHT')
                btn.buyItemNum:EnableMouse(true)
                btn.buyItemNum:SetScript('OnLeave', GameTooltip_Hide)
                btn.buyItemNum:SetScript('OnEnter', function(self2)
                    if not self2.itemID then return end
                    e.tips:SetOwner(self2, "ANCHOR_LEFT");
					e.tips:ClearLines();
                    e.tips:AddDoubleLine(id, addName)
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine('|T236994:0|t'..(e.onlyChinese and '自动购买物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, PURCHASE)), not Save.notAutoBuy and buySave[self2.itemID] or (e.onlyChinese and '无' or NONE))
                    local all= GetItemCount(self2.itemID, true)
                    local bag2= GetItemCount(self2.itemID)
                    e.tips:AddDoubleLine(e.Icon.bank2..(e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL), all..'= '.. e.Icon.bag2.. bag2..'+ '..e.Icon.bank2..(all-bag))
					e.tips:Show();
                end)
            end



            --物品，属性
            local classID= itemLink and select(6, GetItemInfoInstant(itemLink))
            if classID==2 or classID==4 then--装备
                local stat= e.Get_Item_Stats(itemLink)--物品，属性，表
                table.sort(stat, function(a,b) return a.value>b.value and a.index== b.index end)
                for _, tab in pairs(stat) do
                    text= text and text..' ' or ''
                    text= (text and text..' ' or '')..tab.text
                end
                spellID= select(2, GetItemSpell(itemLink))
                if spellID then
                    text= (text or '').. '|A:soulbinds_tree_conduit_icon_utility:10:10|a'
                end
                if text and not btn.stats then
                    btn.stats=e.Cstr(btn, {size=10, mouse=true})
                    btn.stats:SetPoint('TOPLEFT', btn, 'BOTTOMLEFT',0,6)
                    --btn.stats:EnableMouse(true)
                    btn.stats:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
                    btn.stats:SetScript('OnEnter', function(self2)
                        if self2.spellID then
                            e.tips:SetOwner(self2, "ANCHOR_LEFT");
                            e.tips:ClearLines();
                            e.tips:SetSpellByID(self2.spellID)
                            e.tips:AddLine(' ')
                            e.tips:AddDoubleLine(id, addName)
                            e.tips:Show();
                        end
                        self2:SetAlpha(0.5)
                    end)
                end
            end
        end
        if btn then
            if btn.buyItemNum then
                btn.buyItemNum:SetText(num or '')
                btn.buyItemNum.itemID= itemID
            end
            if btn and btn.stats then
                btn.stats:SetText(text or '')
                btn.stats.spellID= spellID
            end
        end
    end
end















--商人 Pluse, 加宽，物品，信息
--##########################
local function Init_Frame_Plus()
    if Save.notPlus then
        return

    elseif C_AddOns.IsAddOnLoaded("CompactVendor") then
        print(id, addName, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, e.onlyChinese and '框体宽度' or COMPACT_UNIT_FRAME_PROFILE_FRAMEWIDTH, 'x2'),
            e.GetEnabeleDisable(false), 'CompactVendor',
            e.onlyChinese and '插件' or ADDONS
        )
    end

    MerchantFrame.width= MerchantFrame:GetWidth()--宽度
    MERCHANT_ITEMS_PER_PAGE= 22

    for i= 3, 6 do
        if not _G['MerchantFrameTab'..i] then
            --上一页
            MerchantPrevPageButton:ClearAllPoints()
            MerchantPrevPageButton:SetPoint('LEFT', _G['MerchantFrameTab'..(i-1)], 'RIGHT', 2,0)
            local label, texture= MerchantPrevPageButton:GetRegions()
            if texture and texture:GetObjectType()=='Texture' then texture:Hide() texture:SetTexture(0) end
            if label and label:GetObjectType()=='FontString' then label:Hide() label:SetText('') end

            --页数
            MerchantPageText:ClearAllPoints()
            MerchantPageText:SetPoint('LEFT', MerchantPrevPageButton, 'RIGHT')

            --下一页
            MerchantNextPageButton:ClearAllPoints()
            MerchantNextPageButton:SetPoint('LEFT', MerchantPageText, 'RIGHT')
            label, texture= MerchantNextPageButton:GetRegions()
            if texture and texture:GetObjectType()=='Texture' then texture:Hide() texture:SetTexture(0) end
            if label and label:GetObjectType()=='FontString' then label:Hide() label:SetText('') end
            break
        end
    end

    --[[
        MERCHANT_ITEMS_PER_PAGE = 10;
        BUYBACK_ITEMS_PER_PAGE = 12;
        MAX_MERCHANT_CURRENCIES = 6;
    ]]
    MerchantItem11:ClearAllPoints()
    MerchantItem11:SetPoint("TOPLEFT", MerchantItem2, "TOPRIGHT", 8, 0)
    MerchantItem12:ClearAllPoints()
	MerchantItem12:SetPoint("TOPLEFT", MerchantItem11, "TOPRIGHT", 8, 0)


    MerchantItem11:SetShown(true)
    MerchantItem12:SetShown(true)

    MerchantSellAllJunkButton:ClearAllPoints()
    MerchantSellAllJunkButton:SetPoint('RIGHT', MerchantBuyBackItemItemButtonNormalTexture, 'LEFT',2,0)

    --新建，按钮
    for i = 13, 22 do
        local btn= _G['MerchantItem'..i] or CreateFrame('Frame', 'MerchantItem'.. i, MerchantFrame, 'MerchantItemTemplate')
        btn:SetPoint('TOPLEFT', _G['MerchantItem'..(i-2)], 'BOTTOMLEFT', 0, -8)
    end


    --建立，索引，文本
    for i=1, MERCHANT_ITEMS_PER_PAGE do
        local btn= _G['MerchantItem'..i]
        btn.IndexLable= e.Cstr(btn)
        btn.IndexLable:SetPoint('TOPRIGHT', _G['MerchantItem'..i], -1, 4)
        btn.IndexLable:SetAlpha(0.3)
        btn.IndexLable.index=i
        function btn:set_index_text(hide)
            local itemButton= _G["MerchantItem"..self.IndexLable.index.."ItemButton"]
            self.IndexLable:SetText(not hide and itemButton and itemButton.hasItem and itemButton:GetID() or '')
        end

        --建立，物品，背景
        btn.itemBG= btn:CreateTexture(nil, 'BACKGROUND')
        btn.itemBG:SetAtlas('ChallengeMode-guild-background')
        btn.itemBG:SetSize(100,43)
        btn.itemBG:SetPoint('TOPRIGHT',-7,-2)
    end




    --回购，数量，提示
    MerchantFrameTab2.numLable= e.Cstr(MerchantFrameTab2)
    MerchantFrameTab2.numLable:SetPoint('TOPRIGHT')
    function MerchantFrameTab2:set_buyback_num()
        local num
        num= GetNumBuybackItems() or 0
        if num>0 then
            num= num==BUYBACK_ITEMS_PER_PAGE and '|cnRED_FONT_COLOR:'..num or num
        else
            num= ''
        end
        self.numLable:SetText(num)
    end





    --卖
    hooksecurefunc('MerchantFrame_UpdateMerchantInfo', function()
        MerchantItem11:SetShown(true)
        MerchantItem12:SetShown(true)
        for i = 1, MERCHANT_ITEMS_PER_PAGE do
            local btn= _G['MerchantItem'..i]
            btn:SetShown(true)
            btn:set_index_text()
            if btn.itemBG and _G["MerchantItem"..i.."ItemButton"] then--Texture.lua
                btn.itemBG:SetShown(_G["MerchantItem"..i.."ItemButton"].hasItem)
            end
        end
        MerchantFrame:SetWidth(MerchantFrame.width*2)--宽度
        MerchantItem11:SetPoint("TOPLEFT", MerchantItem2, "TOPRIGHT", 8, 0)
        MerchantItem12:SetPoint("TOPLEFT", MerchantItem11, "TOPRIGHT", 8, 0)
        Set_Merchant_Info()--设置, 提示, 信息
        MerchantFrameTab2:set_buyback_num()--回购，数量，提示
    end)





    --回购
    hooksecurefunc('MerchantFrame_UpdateBuybackInfo', function()
        local numBuybackItems = GetNumBuybackItems() or 0
        for i = 1, MERCHANT_ITEMS_PER_PAGE do
            local btn= _G['MerchantItem'..i]
            if i> BUYBACK_ITEMS_PER_PAGE then
                btn:SetShown(false)
                btn.itemBG:SetShown(numBuybackItems<=i)
            end
            btn:set_index_text(i> numBuybackItems)
            btn.itemBG:SetShown(numBuybackItems>=i)--建立，物品，背景
        end
        MerchantFrame:SetWidth(MerchantFrame.width)--宽度
        MerchantItem11:SetPoint("TOPLEFT", MerchantItem9, "BOTTOMLEFT", 0, -8)
        MerchantItem12:SetPoint("TOPLEFT", MerchantItem10, "BOTTOMLEFT", 0, -8)
        Set_Merchant_Info()--设置, 提示, 信息
        MerchantFrameTab2:set_buyback_num()--回购，数量，提示
    end)
    hooksecurefunc('MerchantFrame_UpdateCurrencies', function()
        MerchantExtraCurrencyInset:SetShown(false)
        MerchantExtraCurrencyBg:SetShown(false)
    end)
    MerchantMoneyInset:SetShown(false)

    --移动，回购买，图标
    if MerchantBuyBackItemItemButton and MerchantBuyBackItemItemButton.UndoFrame and MerchantBuyBackItemItemButton.UndoFrame.Arrow then
        MerchantBuyBackItemItemButton.UndoFrame.Arrow:ClearAllPoints()
        MerchantBuyBackItemItemButton.UndoFrame.Arrow:SetPoint('BOTTOMRIGHT', MerchantBuyBackItem, 6,-4)
    end
end


























--#######
--设置菜单
--#######
local function Init_Menu(_, level, type)
    local info
    if type=='SELLJUNK' then--出售垃圾
        info= {
            text= e.onlyChinese and '幻化' or TRANSMOGRIFICATION,
            checked= Save.sellJunkMago,
            tooltipOnButton=true,
            tooltipTitle= '|cff9d9d9d'..(e.onlyChinese and '粗糙' or ITEM_QUALITY0_DESC),
            func=function ()
                Save.sellJunkMago= not Save.sellJunkMago and true or nil
                setSellItems()--出售物品
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif type=='CUSTOM' then--二级菜单, 自定义出售
        for itemID, boolean in pairs(Save.Sell) do
            if itemID  then
                e.LoadDate({id=itemID, type='item'})
                local itemLink= select(2, GetItemInfo(itemID))
                itemLink= itemLink or C_Item.GetItemNameByID(itemID) or ('itemID: ' .. itemID)
                info= {}
                info.text= itemLink
                info.icon= C_Item.GetItemIconByID(itemID)
                info.checked=boolean
                info.func=function()
                    Save.Sell[itemID]=nil
                    print(id, addName, '|cnGREEN_FONT_COLOR:'..REMOVE..'|r'..AUCTION_HOUSE_SELL_TAB, itemLink)
                end
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info= {
            text=e.onlyChinese and '清除全部' or CLEAR_ALL,
            notCheckable=true,
            func=function ()
                Save.Sell={}
                e.LibDD:CloseDropDownMenus();
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif type=='BOSS' then--二级菜单, BOSS
        for itemID, _ in pairs(bossSave) do
            if itemID then
                e.LoadDate({id=itemID, type='item'})
                info= {
                    text= select(2,GetItemInfo(itemID)) or itemID,
                    notCheckable=true,
                    icon= C_Item.GetItemIconByID(itemID),
                    func=function()
                        Save.bossSave[itemID]=nil
                    end,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info= {
            text=e.onlyChinese and '清除全部' or CLEAR_ALL,
            notCheckable=true,
            func=function ()
                bossSave={}
                e.LibDD:CloseDropDownMenus();
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif type=='BUY' then--二级菜单, 购买物品
        for itemID, num in pairs(buySave) do
            if itemID and num then
                select(2, GetItemInfo(itemID))
                local bag=GetItemCount(itemID)
                local bank=GetItemCount(itemID, true)-bag
                local itemLink= select(2, GetItemInfo(itemID))
                itemLink= itemLink or C_Item.GetItemNameByID(itemID) or ('itemID: ' .. itemID)
                info= {}
                info.text='|cnGREEN_FONT_COLOR:'..num..'|r '..itemLink..' '..'|cnYELLOW_FONT_COLOR:'..bag..e.Icon.bag2..bank..e.Icon.bank2..'|r'
                info.checked= true
                info.icon= C_Item.GetItemIconByID(itemID)
                info.func=function()
                    buySave[itemID]=nil
                    Set_Merchant_Info()--设置, 提示, 信息
                end
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info= {
            text=e.onlyChinese and '清除全部' or CLEAR_ALL,
            notCheckable=true,
            func=function ()
                buySave={}
                Set_Merchant_Info()--设置, 提示, 信息
                e.LibDD:CloseDropDownMenus();
           end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif type=='BUYBACK' then--二级菜单, 购回物品
        for itemID, _ in pairs(Save.noSell) do
            if itemID then
                select(2, GetItemInfo(itemID))
                local bag=GetItemCount(itemID)
                local bank=GetItemCount(itemID, true)-bag
                local itemLink= select(2, GetItemInfo(itemID))
                itemLink= itemLink or C_Item.GetItemNameByID(itemID) or ('itemID: ' .. itemID)
                info= {
                    text=itemLink..' '..'|cnYELLOW_FONT_COLOR:'..bag..e.Icon.bag2..bank..e.Icon.bank2..'|r',
                    checked= true,
                    icon= C_Item.GetItemIconByID(itemID),
                    func=function()
                        Save.noSell[itemID]=nil
                    end,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info ={
            text= e.onlyChinese and '清除全部' or CLEAR_ALL,
            notCheckable=true,
            func=function ()
                Save.noSell={}
                e.LibDD:CloseDropDownMenus();
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return
    end

    local num
    info ={--出售垃圾
        text= e.onlyChinese and '出售垃圾' or AUCTION_HOUSE_SELL_TAB..BAG_FILTER_JUNK,
        checked= not Save.notSellJunk,
        menuList= 'SELLJUNK',
        hasArrow= true,
        func=function ()
            Save.notSellJunk= not Save.notSellJunk and true or nil
        end,
        tooltipOnButton=true,
        tooltipTitle=id..' '.. addName,
        tooltipText=format(e.onlyChinese and '品质：%s' or PROFESSIONS_CRAFTING_QUALITY, '|cff606060'..(e.onlyChinese and '粗糙' or ITEM_QUALITY0_DESC)..'|r'),
    }
    e.LibDD:UIDropDownMenu_AddButton(info)

    num=0
    for _, boolean in pairs(Save.Sell) do
        if boolean then
            num=num+1
        end
    end
    info = {
        text= (e.onlyChinese and '出售自定义' or  AUCTION_HOUSE_SELL_TAB..CUSTOM)..'|cnRED_FONT_COLOR: #'..num..'|r',
        checked= not Save.notSellCustom,
        func=function ()
            Save.notSellCustom= not Save.notSellCustom and true or nil
        end,
        menuList='CUSTOM',
        hasArrow=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info)

    num=0
    for itemID, _ in pairs(bossSave) do
        if itemID then
            num=num+1
        end
    end
    info = {--出售BOSS掉落
        text= (e.onlyChinese and '出售首领掉落' or AUCTION_HOUSE_SELL_TAB..TRANSMOG_SOURCE_1)..'|cnRED_FONT_COLOR: #'..num..'|r',
        checked= not Save.notSellBoss,
        func=function ()
            Save.notSellBoss= not Save.notSellBoss and true or nil
        end,
        menuList='BOSS',
        hasArrow=true,
        tooltipOnButton=true,
        tooltipTitle= (e.onlyChinese and '物品等级' or STAT_AVERAGE_ITEM_LEVEL)..' < ' ..(avgItemLevel and math.ceil(avgItemLevel)-15 or 15)
    }
    e.LibDD:UIDropDownMenu_AddButton(info)

    e.LibDD:UIDropDownMenu_AddSeparator()
    num=0
    for _, boolean in pairs(Save.noSell) do
        if boolean then
            num=num+1
        end
    end
    info ={--购回
        text= (e.onlyChinese and '回购' or BUYBACK)..'|cnRED_FONT_COLOR: #'..num..'|r',
        notCheckable=true,
        menuList='BUYBACK',
        hasArrow=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info)

    num=0
    for _, boolean in pairs(buySave) do
        if boolean then
            num=num+1
        end
    end
    e.LibDD:UIDropDownMenu_AddSeparator()
    info={--购买物品
        text=  (e.onlyChinese and '自动购买物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, PURCHASE))..'|cnGREEN_FONT_COLOR: #'..num..'|r',
        checked=not Save.notAutoBuy,
        func=function ()
            if Save.notAutoBuy then
                Save.notAutoBuy=nil
            else
                Save.notAutoBuy=true
            end
            Set_Merchant_Info()--设置, 提示, 信息
        end,
        menuList='BUY',
        hasArrow=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info)

    e.LibDD:UIDropDownMenu_AddSeparator()
    info={}--自动修理
    info.text= e.onlyChinese and '修理所有物品' or REPAIR_ALL_ITEMS
    info.checked=not Save.notAutoRepairAll
    info.func=function ()
        if Save.notAutoRepairAll then
            Save.notAutoRepairAll=nil
        else
            Save.notAutoRepairAll=true
        end
        set_Durabiliy_Value_Text()
    end
    info.tooltipOnButton=true
    info.tooltipTitle= (e.onlyChinese and '金币记录' or GUILD_BANK_MONEY_LOG).. ' '..RepairSave.date
    local text=	(e.onlyChinese and '修理' or MINIMAP_TRACKING_REPAIR)..': '..RepairSave.num..' '..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
                ..'|n'..(e.onlyChinese and '公会' or GUILD)..': '..GetCoinTextureString(RepairSave.guild)
                ..'|n'..(e.onlyChinese and '玩家' or PLAYER)..': '..GetCoinTextureString(RepairSave.player)
    if RepairSave.guild>0 and RepairSave.player>0 then
        text=text..'|n|n'..(e.onlyChinese and '合计' or TOTAL)..': '..GetCoinTextureString(RepairSave.guild+RepairSave.player)
    end
    if CanGuildBankRepair() then
        text=text..'|n|n'..(e.onlyChinese and '你想要使用公会资金修理吗？' or GUILDBANK_REPAIR)..'|n'..GetCoinTextureString(GetGuildBankMoney() or 0)
    end
    info.tooltipText=text
    e.LibDD:UIDropDownMenu_AddButton(info)

    --[[e.LibDD:UIDropDownMenu_AddSeparator()
    info= {--显示数物品,拥有数量,在商人界面
        text= e.onlyChinese and '显示数量'..e.Icon.bank2 or (SHOW..e.Icon.bank2..AUCTION_HOUSE_QUANTITY_LABEL),
        checked= not Save.notShowBagNum,
        func=function ()
            Save.notShowBagNum= not Save.notShowBagNum and true or nil
            Set_Merchant_Info()--设置, 提示, 信息
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info)]]


    info={--删除字符
        text= e.onlyChinese and '自动输入DELETE' or (RUNECARVER_SCRAPPING_CONFIRMATION_TEXT..': '..DELETE_ITEM_CONFIRM_STRING),
        checked= not Save.notDELETE,
        func=function ()
            Save.notDELETE= not Save.notDELETE and true or nil
        end,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '你真的要摧毁%s吗？|n|n请在输入框中输入 DELETE 以确认。' or DELETE_GOOD_ITEM,
    }
    e.LibDD:UIDropDownMenu_AddButton(info)

    info= {--堆叠数量
        text= (e.onlyChinese and '堆叠数量' or AUCTION_STACK_SIZE).. ' Plus',
        checked= not Save.notStackSplit,
        func=function ()
            Save.notStackSplit = not Save.notStackSplit and true or nil
            print(id, addName , '|cnRED_FONT_COLOR:',e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info)

    info= {--商人 Pluse
        text= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, (e.onlyChinese and '商人' or MERCHANT ), 'Plus'),
        checked= not Save.notPlus,
        func=function ()
            Save.notPlus = not Save.notPlus and true or nil
            print(id, addName , '|cnRED_FONT_COLOR:',e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info)
end




























local function Init_Button(frame)
    local btn=e.Cbtn(frame.TitleContainer, {size={20,20}, texture=236994})
    btn:Raise()
    btn:SetAlpha(0.5)
    btn:SetPoint('RIGHT', frame.TitleContainer ,'RIGHT', -25, 0)
    btn:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT");
        e.tips:ClearLines();
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddLine(' ')
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType=='item' and itemID and itemLink then
            local icon=C_Item.GetItemIconByID(itemLink)
            e.tips:AddDoubleLine(itemLink, icon and '|T'..icon..':0|t' or ' ')
            if Save.Sell[itemID] then
                e.tips:AddDoubleLine(e.onlyChinese and '移除' or REMOVE, e.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB, 1,0,0, 1,0,0)
            else
                e.tips:AddDoubleLine(e.onlyChinese and '添加' or ADD, e.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB, 0,1,0, 0,1,0)
            end
        elseif infoType=='merchant' and itemID then--购买物品
            itemID= GetMerchantItemID(itemID)

            e.tips:AddDoubleLine((e.onlyChinese and '购买' or PURCHASE)..((itemID and buySave[itemID]) and '|cnRED_FONT_COLOR:'..(e.onlyChinese and '修改' or SLASH_CHAT_MODERATE2:gsub('%/',''))..' '..buySave[itemID]..'|r' or '' ), e.onlyChinese and '物品' or ITEMS, 0,1,0, 0,1,0)
        else
            e.tips:AddDoubleLine((e.onlyChinese and '拖曳' or DRAG_MODEL)..e.Icon.left..(e.onlyChinese and '物品' or ITEMS), e.onlyChinese and '出售/购买' or (AUCTION_HOUSE_SELL_TAB..'/'..PURCHASE))
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.left)
        end
        e.tips:Show()
        self2:SetAlpha(1)
    end)
    btn:SetScript('OnMouseUp', function(self2, d)
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType=='item' and itemID then
            if Save.Sell[itemID] then
                Save.Sell[itemID]=nil
                print(id, addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|r', e.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB, itemLink)
            else
                Save.Sell[itemID]=true
                Save.noSell[itemID]=nil
                buySave[itemID]=nil
                print(id,addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..'|r'..(e.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB), itemLink )
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
                local icon
                icon= C_Item.GetItemIconByID(itemLink)
                icon= icon and '|T'..icon..':0|t' or ''
                StaticPopupDialogs[id..addName..'Buy']={
                    text =id..' '..addName
                    ..'|n|n'.. (e.onlyChinese and '自动购买' or AUTO_JOIN:gsub(JOIN,PURCHASE))..': '..icon ..itemLink
                    ..'|n|n'..e.Icon.player..e.Player.name_realm..': ' ..(e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL)
                    ..'|n|n0: '..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)
                    ..(Save.notAutoBuy and '|n|n'..(e.onlyChinese and '自动购买' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, PURCHASE))..': '..e.GetEnabeleDisable(false) or ''),
                    button1 = e.onlyChinese and '购买' or PURCHASE,
                    button2 = e.onlyChinese and '取消' or CANCEL,
                    whileDead=true, hideOnEscape=true, exclusive=true, hasEditBox=true,
                    OnAccept=function(s)
                        local num= s.editBox:GetNumber()
                        if num==0 then
                            buySave[itemID]=nil
                            print('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)..'|r', itemLink)
                        else
                            buySave[itemID]=num
                            Save.Sell[itemID]=nil
                            print(PURCHASE, '|cnGREEN_FONT_COLOR:'..num..'|r', itemLink)
                            set_Buy_Items()
                        end
                        Set_Merchant_Info()--设置, 提示, 信息
                        ClearCursor();
                    end,
                    OnShow=function(s)
                        s.editBox:SetNumeric(true);

                        if buySave[itemID] then
                            s.editBox:SetText(buySave[itemID])
                        end
                    end,
                    OnHide= function(self3)
                        self3.editBox:SetText("")
                        e.call('ChatEdit_FocusActiveWindow')
                    end,
                    EditBoxOnEscapePressed = function(s)
                        s:SetAutoFocus(false)
                        s:ClearFocus()
                        s:GetParent():Hide()
                    end,
                }
                StaticPopup_Show(id..addName..'Buy');
            end
        else
            if not self2.Menu then
                self2.Menu=CreateFrame("Frame", nil, self2, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self2.Menu, Init_Menu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self2.Menu, self2, 15, 0)
        end
    end)
    btn:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.5) end)

    local noSellButton=e.Cbtn(frame.TitleContainer, {size={20,20}, atlas='common-icon-undo'})--nil, false)--购回
    noSellButton:Raise()
    noSellButton:SetAlpha(0.5)
    noSellButton:SetPoint('RIGHT', btn, 'LEFT', -2, 0)
    noSellButton:SetScript('OnMouseUp', function()
        local infoType, itemID, itemLink = GetCursorInfo()

        if infoType=='merchant' and itemID then--购买物品
            itemLink= GetMerchantItemLink(itemID)
            itemID= GetMerchantItemID(itemID)
        end

        if (infoType=='item' or infoType=='merchant') and itemID then
            if Save.noSell[itemID] then
                Save.noSell[itemID]=nil
                print(id, addName,'|cnRED_FONT_COLOR:', e.onlyChinese and '移除' or REMOVE, e.onlyChinese and '回购' or BUYBACK, itemLink)
            else
                Save.noSell[itemID]=true
                Save.Sell[itemID]=nil
                print(id,addName, '|cnGREEN_FONT_COLOR:', e.onlyChinese and '添加' or ADD, e.onlyChinese and '回购' or BUYBACK, itemLink )
                C_Timer.After(0.2, function()
                    if MerchantFrame and MerchantFrame:IsShown() then --and MerchantFrame.selectedTab == 1 then
                        set_BuyBack_Items()--购回物品
                    end
                end)
            end
            ClearCursor();
        end
    end)
    noSellButton:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT");
        e.tips:ClearLines();
        e.tips:AddDoubleLine(id, addName)
        local num=0
        for _, _  in pairs(Save.noSell) do
            num=num+1
        end
        e.tips:AddDoubleLine(e.onlyChinese and '物品' or ITEMS, '|cnGREEN_FONT_COLOR: #'..num..'|r')
        e.tips:AddLine(' ')
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType=='merchant' and itemID then--购买物品
            itemLink= GetMerchantItemLink(itemID)
            itemID= GetMerchantItemID(itemID)
        end
        if (infoType=='item' or infoType=='merchant') and itemID and itemLink then

            local icon=C_Item.GetItemIconByID(itemLink)
            e.tips:AddDoubleLine(itemLink, icon and '|T'..icon..':0|t' or ' ')
            if Save.noSell[itemID] then
                e.tips:AddDoubleLine(e.onlyChinese and '移除' or REMOVE, e.onlyChinese and '回购' or BUYBACK, 1,0,0, 1,0,0)
            else
                e.tips:AddDoubleLine(e.onlyChinese and '添加' or ADD, e.onlyChinese and '回购' or BUYBACK, 0,1,0, 0,1,0)
            end
        else
            e.tips:AddDoubleLine((e.onlyChinese and '拖曳' or DRAG_MODEL)..e.Icon.left..(e.onlyChinese and '物品' or ITEMS), e.onlyChinese and '回购' or BUYBACK)
        end
        e.tips:Show()
        self2:SetAlpha(1)
    end)
    noSellButton:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.5) end)
end


























--StackSplitFrame.lua 堆叠,数量,框架
--#################################
local function set_StackSplitFrame_OpenStackSplitFrame(self)--, maxStack, parent, anchor, anchorTo, stackCount)
    if Save.notStackSplit then
        return
    end
    if not self.restButton then
        local function setButton()
            self.RightButton:SetEnabled(self.split<self.maxStack)
            self.LeftButton:SetEnabled(self.split>self.minSplit)
        end
        self.restButton=e.Cbtn(self, {size={22,22}})--重置
        self.restButton:SetPoint('TOP')
        self.restButton:SetNormalAtlas('characterundelete-RestoreButton')
        self.restButton:SetScript('OnMouseDown', function(self2)
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
            e.tips:AddDoubleLine((e.onlyChinese and '堆叠数量' or AUCTION_STACK_SIZE)..' Plus', e.onlyChinese and '重置' or RESET, nil,nil,nil, 0,1,0)
            e.tips:Show()
        end)
        self.restButton:SetScript('OnLeave', GameTooltip_Hide)

        self.MaxButton=e.Cbtn(self, {icon='hide', size={40,20}})
        self.MaxButton:SetNormalFontObject('NumberFontNormalYellow')
        self.MaxButton:SetPoint('LEFT', self.restButton, 'RIGHT')
        self.MaxButton:SetScript('OnMouseDown', function(self2)
            self.split=self.maxStack
            StackSplitFrame:UpdateStackText()
            setButton()
        end)

        self.MetaButton=e.Cbtn(self, {icon='hide', size={40,20}})
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
        self.editBox:ClearFocus()
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
end





















--拍卖行
local AuctionHouseButton
local function Init_AuctionHouse()
    if not e.Player.husandro then
        return
    end
    local size= 32

    AuctionHouseButton= e.Cbtn(AuctionHouseFrame, {size={size, size}, icon='hide'})
    AuctionHouseButton:SetPoint('TOPLEFT', AuctionHouseFrame, 'TOPRIGHT',0,10)
    --AuctionHouseButton.frame= CreateFrame('Frame', nil, AuctionHouseButton)
    --AuctionHouseButton.frame:SetAllPoints(AuctionHouseButton)
    AuctionHouseButton.Text= e.Cstr(AuctionHouseButton)
    AuctionHouseButton.Text:SetPoint('CENTER')
    AuctionHouseButton.buttons={}


    function AuctionHouseButton:init_items()
        local index=1
        if not Save.hideSellItemList then
            for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES do--Constants.InventoryConstants.NumBagSlots
                for slot=1, C_Container.GetContainerNumSlots(bag) do
                    local info = C_Container.GetContainerItemInfo(bag, slot)
                    local itemLocation= ItemLocation:CreateFromBagAndSlot(bag, slot)
                    if info and info.itemID and itemLocation and C_AuctionHouse.IsSellItemValid(itemLocation, false) then
                        local btn= self.buttons[index]
                        if not btn then
                            btn= e.Cbtn(self, {size={size,size}, button='ItemButton', icon='hide'})
                            btn.selectTexture= btn:CreateTexture(nil, 'OVERLAY')
                            btn.selectTexture:SetAtlas('Forge-ColorSwatchSelection')
                            btn.selectTexture:SetPoint('CENTER')
                            btn.selectTexture:SetSize(size+8, size+8)
                            btn.selectTexture:Hide()
                            --btn.selectTexture:SetVertexColor(0,1,0)
                            
                            btn:SetPoint("TOP", index==1 and self or self.buttons[index-1], 'BOTTOM', 0, -2)
                            btn:UpdateItemContextOverlayTextures(1)
                            btn:SetScript('OnLeave', GameTooltip_Hide)

                            btn:SetScript('OnEnter', function(frame)
                                e.tips:SetOwner(frame:GetParent(), "ANCHOR_LEFT")
                                e.tips:ClearLines()
                                local itemLink= C_Item.GetItemLink(frame.itemLocation)
                                if itemLink then
                                    e.tips:SetHyperlink(itemLink)
                                    e.tips:AddLine(' ')
                                    e.tips:AddDoubleLine(e.onlyChinese and '开始拍卖' or CREATE_AUCTION, e.Icon.left)
                                end
                                local itemID= C_Item.GetItemID(frame.itemLocation)
                                if itemID then
                                    e.tips:AddDoubleLine(e.GetShowHide(nil, true), e.GetShowHide(Save.hideSellItem[itemID])..e.Icon.right)
                                end
                                e.tips:Show()
                            end)
                            btn:SetScript('OnClick', function(frame, d)
                                if d=='LeftButton' then--放入，物品
                                    AuctionHouseButton:show_CommoditiesSellFrame()
                                    local fromItemDisplay = nil
                                    local refreshListWithPreviousItem = true
                                    AuctionHouseFrame.CommoditiesSellFrame:SetItem(frame.itemLocation, fromItemDisplay, refreshListWithPreviousItem)

                                elseif d=='RightButton' then--隐藏，物品
                                    local itemID= C_Item.GetItemID(frame.itemLocation)
                                    if itemID then
                                        Save.hideSellItem[itemID]= not Save.hideSellItem[itemID] and true or nil
                                        frame:GetParent():init_items()
                                    end
                                end
                            end)
                            self.buttons[index]= btn
                        end
                        btn:SetItemLocation(itemLocation)
                        btn:SetItemButtonCount(info.stackCount)
                        btn:SetAlpha(Save.hideSellItem[info.itemID] and 0.3 or 1)
                        btn:SetShown(true)
                        index= index +1
                    end
                end
            end
            for i=16, index-1, 15 do
                local btn= self.buttons[i]
                btn:ClearAllPoints()
                btn:SetPoint('LEFT', self.buttons[i-15], 'RIGHT', 2, 0)
            end
        end
        for i= index, #self.buttons do
            local btn= self.buttons[i]
            if btn then
                btn.bag=nil
                btn:Reset()
                btn:SetShown(false)
            end
        end

        self.Text:SetText(Save.hideSellItemList and '|cff606060'..(e.onlyChinese and '隐藏' or HIDE) or index-1)
    end

    hooksecurefunc(AuctionHouseFrame.CommoditiesSellFrame, 'SetItem', function(self)
        local itemLocation= self:GetItem()
        local itemID= itemLocation and C_Item.GetItemID(itemLocation)
        for _, btn in pairs(AuctionHouseButton.buttons) do
            if btn.itemLocation then
                btn.selectTexture:SetShown(C_Item.GetItemID(btn.itemLocation)==itemID)
            else
                break
            end
        end
    end)


    function AuctionHouseButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.GetShowHide(nil, true), e.GetShowHide(not Save.hideSellItemList)..e.Icon.left)
        e.tips:Show()
    end
    AuctionHouseButton:SetScript('OnLeave', GameTooltip_Hide)
    AuctionHouseButton:SetScript('OnEnter', AuctionHouseButton.set_tooltips)
    AuctionHouseButton:SetScript('OnEvent', AuctionHouseButton.init_items)
    AuctionHouseButton:SetScript('OnClick', function(self)
        Save.hideSellItemList= not Save.hideSellItemList and true or nil
        self:init_items()
        self:set_tooltips()
    end)


    function AuctionHouseButton:get_displayMode()
        local displayMode= AuctionHouseFrame:GetDisplayMode() or {}
        return displayMode[1]
    end
    function AuctionHouseButton:show_CommoditiesSellFrame()
        local displayMode= self:get_displayMode()
        if displayMode ~='CommoditiesSellFrame' then
           AuctionHouseFrame:SetDisplayMode(AuctionHouseFrameDisplayMode.CommoditiesSell)
        end
    end

    function AuctionHouseButton:set_shown()
        local displayMode= self:get_displayMode()
        self:SetShown(AuctionHouseFrame:IsShown() and (displayMode=='CommoditiesSellFrame' or displayMode=='ItemSellFrame'))
    end


    function AuctionHouseButton:set_event()
        self:UnregisterAllEvents()
        if self:IsShown() then
            self:RegisterEvent('BAG_UPDATE_DELAYED')
        end
    end

    hooksecurefunc(AuctionHouseFrame, 'SetDisplayMode', function(self, displayMode)
        if not displayMode or not self:IsShown() then
            return
        end
        if displayMode[1]== "ItemSellFrame" then
            self:SetDisplayMode(AuctionHouseFrameDisplayMode.CommoditiesSell)
        elseif displayMode[1]=='CommoditiesSellFrame' then
            AuctionHouseButton:init_items()
		end
        AuctionHouseButton:set_shown()
        AuctionHouseButton:set_event()
    end)


    AuctionHouseFrame:HookScript('OnHide', function()
        AuctionHouseButton:set_shown()
        AuctionHouseButton:set_event()
    end)

    --Blizzard_AuctionHouseSellFrame.lua
    --出售物品时，使用，最大数量
    local levelFrame= AuctionHouseFrame.CommoditiesSellFrame.QuantityInput.MaxButton:GetFrameLevel()
    local maxSellItemCheck= CreateFrame('CheckButton', nil, AuctionHouseFrame.CommoditiesSellFrame.QuantityInput.MaxButton, 'InterfaceOptionsCheckButtonTemplate')
    maxSellItemCheck:SetPoint('LEFT', AuctionHouseFrame.CommoditiesSellFrame.QuantityInput.MaxButton, 'RIGHT')
    maxSellItemCheck:SetSize(24,24)
    maxSellItemCheck:SetChecked(Save.isMaxSellItem)
    maxSellItemCheck:SetFrameLevel(levelFrame)
    maxSellItemCheck:SetScript('OnLeave', GameTooltip_Hide)
    maxSellItemCheck:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(' ', e.onlyChinese and '最大数量' or AUCTION_HOUSE_MAX_QUANTITY_BUTTON)
        e.tips:Show()
    end)
    maxSellItemCheck:SetScript('OnClick', function()
        Save.isMaxSellItem= not Save.isMaxSellItem and true or nil
    end)
    hooksecurefunc(AuctionHouseFrame.CommoditiesSellFrame, 'SetItem', function(self)
        if Save.isMaxSellItem and self.QuantityInput.MaxButton:IsEnabled() then
            self:SetToMaxQuantity()
        end
    end)

    --显示，转到出售物品
    local showSellItemCheck= CreateFrame('CheckButton', nil, AuctionHouseFrame.CommoditiesSellFrame, 'InterfaceOptionsCheckButtonTemplate')
    showSellItemCheck:SetPoint('BOTTOMLEFT', AuctionHouseFrame.CommoditiesSellFrame)
    showSellItemCheck:SetSize(24,24)
    showSellItemCheck:SetChecked(Save.intShowSellItem)
    showSellItemCheck.Text:SetText(e.onlyChinese and '显示' or SHOW)
    showSellItemCheck:SetFrameLevel(levelFrame)
    showSellItemCheck:SetScript('OnLeave', GameTooltip_Hide)
    showSellItemCheck:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(e.onlyChinese and '显示拍卖行时' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, BUTTON_LAG_AUCTIONHOUSE),
            e.onlyChinese and '转到出售' or ('=> '..AUCTION_HOUSE_SELL_TAB))
        e.tips:Show()
    end)
    showSellItemCheck:SetScript('OnClick', function()
        Save.intShowSellItem= not Save.intShowSellItem and true or nil
    end)
    AuctionHouseFrame:HookScript('OnShow', function(self)
        if Save.intShowSellItem then
            self:SetDisplayMode(AuctionHouseFrameDisplayMode.CommoditiesSell)
        end
    end)

    --默认价格，替换，原生func
    --Blizzard_AuctionHouseSellFrame.lua
    function AuctionHouseFrame.CommoditiesSellFrame:GetDefaultPrice()
        local itemLocation = self:GetItem();
        local price= 100000
        if itemLocation and itemLocation:IsValid() then
            local itemLink = C_Item.GetItemLink(itemLocation);
            local itemID= C_Item.GetItemID(itemLocation)

            if itemID and Save.SellItemDefaultPrice[itemID] then--上次保存的，物价
                price= Save.SellItemDefaultPrice[itemID]

            elseif itemID and C_MountJournal.GetMountFromItem(itemID) or C_ToyBox.GetToyInfo(itemID) then--坐骑
                price= 999999900--9.9万

            elseif itemID and C_PetJournal.GetPetInfoByItemID(itemID)--宠物
                or (itemLink and (itemLink:find('Hbattlepet:(%d+)')))
            then
                price= 99999900--0.9万

            elseif LinkUtil.IsLinkType(itemLink, "item") then
                local vendorPrice = select(11, GetItemInfo(itemLink));
                if vendorPrice then

                    local defaultPrice = vendorPrice * 100--倍数，原1.5倍
                    price = defaultPrice + (COPPER_PER_SILVER - (defaultPrice % COPPER_PER_SILVER)); -- AH prices must be in silver increments.
                end
            end
        end


        return price
    end

    --单价，倍数
    AuctionHouseFrame.CommoditiesSellFrame.percentLabel= e.Cstr(AuctionHouseFrame.CommoditiesSellFrame, {size=16})--单价，提示
    AuctionHouseFrame.CommoditiesSellFrame.percentLabel:SetPoint('BOTTOM', AuctionHouseFrame.CommoditiesSellFrame.PostButton, 'TOP')
    AuctionHouseFrame.CommoditiesSellFrame.vendorPriceLabel= e.Cstr(AuctionHouseFrame.CommoditiesSellFrame, {size=12})--单价，提示
    AuctionHouseFrame.CommoditiesSellFrame.vendorPriceLabel:SetPoint('TOPRIGHT', AuctionHouseFrame.CommoditiesSellFrame.PriceInput.MoneyInputFrame.GoldBox, 'BOTTOMRIGHT',0,4)
    hooksecurefunc(AuctionHouseFrame.CommoditiesSellFrame, 'UpdateTotalPrice', function(self)
        local itemLocation= self:GetItem()
        local text=''
        local text2=''
        if itemLocation and itemLocation:IsValid() then
            local itemLink = C_Item.GetItemLink(itemLocation);
            local vendorPrice = select(11, GetItemInfo(itemLink));
            local unitPrice= self:GetUnitPrice()
            local col=''
            if vendorPrice and unitPrice and vendorPrice>0 and unitPrice>0 then
                if unitPrice> vendorPrice then
                    local x= unitPrice/vendorPrice
                    if x<5 then
                        col= '|cff606060'
                    elseif x<10 then
                        col= '|cffffffff'
                    elseif x<50 then
                        col='|cnGREEN_FONT_COLOR:'
                    else
                        col='|cffff00ff'
                    end
                    x= x<0 and 0 or x
                    if x<10 then
                        text= col..format('x%.2f', x)
                    else
                        text= col..format('x%i', x)
                    end
                else
                    col='|cnRED_FONT_COLOR:'
                end
            end
            if vendorPrice then
                text2= col..GetCoinTextureString(vendorPrice)
            end
        end
        self.vendorPriceLabel:SetText(text2)
        self.percentLabel:SetText(text)
    end)

    --下一个，拍卖，物品
    --AuctionHouseFrame.CommoditiesSellFrame.PostButton:HookScript('OnClick', function(self)
    hooksecurefunc(AuctionHouseFrame.CommoditiesSellFrame, 'PostItem', function(self)
        self.isNextItem=true
    end)
    hooksecurefunc(AuctionHouseFrame.CommoditiesSellFrame, 'UpdatePostButtonState', function(self)
        if self.itemLocation or not C_AuctionHouse.IsThrottledMessageSystemReady() or not self.isNextItem then
            return
        end
        for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES do--Constants.InventoryConstants.NumBagSlots
            for slot=1, C_Container.GetContainerNumSlots(bag) do
                local info = C_Container.GetContainerItemInfo(bag, slot)
                local itemLocation= ItemLocation:CreateFromBagAndSlot(bag, slot)
                if info and info.itemID and not Save.hideSellItem[info.itemID] and itemLocation and C_AuctionHouse.IsSellItemValid(itemLocation, false) then
                    local fromItemDisplay = nil;
                    local refreshListWithPreviousItem = true;
                    self:SetItem(itemLocation, fromItemDisplay, refreshListWithPreviousItem)
                    self.isNextItem=nil
                    return
                end
            end
        end
        self.isNextItem=nil
    end)


    --移动, Frame
    --Blizzard_AuctionHouseFrame.xml
    AuctionHouseFrame.CommoditiesSellList:ClearAllPoints()
    AuctionHouseFrame.CommoditiesSellList:SetPoint('TOPLEFT', AuctionHouseFrame.ItemSellFrame, 'TOPLEFT')
    AuctionHouseFrame.CommoditiesSellList:SetPoint('BOTTOMRIGHT', AuctionHouseFrame.ItemSellFrame, 'BOTTOMRIGHT', 65,0)

    AuctionHouseFrame.CommoditiesSellFrame:ClearAllPoints()
    AuctionHouseFrame.CommoditiesSellFrame:SetPoint('TOPLEFT', AuctionHouseFrame.ItemSellList, 'TOPLEFT', 67,0)
    AuctionHouseFrame.CommoditiesSellFrame:SetPoint('BOTTOMRIGHT', AuctionHouseFrame.ItemSellList, 'BOTTOMRIGHT')

    --[[AuctionHouseFrame.CommoditiesSellFrame.PostButton:ClearAllPoints()
    local btn= AuctionHouseFrame.CommoditiesSellFrame.PostButton
    AuctionHouseFrame.CommoditiesSellFrame.PostButton:SetPoint('RIGHT', AuctionHouseFrame.CommoditiesSellFrame)
    AuctionHouseFrame.CommoditiesSellFrame.PostButton:SetSize(270,22)]]


    --Blizzard_AuctionHouseFrame.lua
    --C_AuctionHouse.CancelAuction(self.data.auctionID)
    --[[
        StaticPopupDialogs["CANCEL_AUCTION"] = {
	text = CANCEL_AUCTION_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		C_AuctionHouse.CancelAuction(self.data.auctionID);
	end,
	OnShow = function(self)
		local cancelCost = C_AuctionHouse.GetCancelCost(self.data.auctionID);
		MoneyFrame_Update(self.moneyFrame, cancelCost);
		if cancelCost > 0 then
			self.text:SetText(CANCEL_AUCTION_CONFIRMATION_MONEY);
		else
			self.text:SetText(CANCEL_AUCTION_CONFIRMATION);
		end
	end,
	hasMoneyFrame = 1,
	showAlert = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
    ]]
end























--####
--初始
--####
local DELETE_ITEM_CONFIRM_STRING= DELETE_ITEM_CONFIRM_STRING
local COMMUNITIES_DELETE_CONFIRM_STRING= COMMUNITIES_DELETE_CONFIRM_STRING
local function Init()
    Init_Button(MerchantFrame)--初始，按钮


    --######
    --DELETE
    --######
    hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"],"OnShow",function(self)
        if not Save.notDELETE then
            self.editBox:SetText(DELETE_ITEM_CONFIRM_STRING);
        end
    end)
    hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_QUEST_ITEM"], "OnShow",function(self)
        if not Save.notDELETE and self.editBox then
            self.editBox:SetText(DELETE_ITEM_CONFIRM_STRING);
        end
    end)
    hooksecurefunc(StaticPopupDialogs["CONFIRM_DESTROY_COMMUNITY"],"OnShow",function(self)
        if not Save.notDELETE and self.editBox then
            self.editBox:SetText(COMMUNITIES_DELETE_CONFIRM_STRING);
        end
    end)





    hooksecurefunc(StackSplitFrame, 'OpenStackSplitFrame',set_StackSplitFrame_OpenStackSplitFrame)--StackSplitFrame.lua 堆叠,数量,框架








    --#################
    --拾取, 设置自动拾取
    --#################
    if LootFrame then
        local check=CreateFrame("CheckButton", nil, LootFrame.TitleContainer, "InterfaceOptionsCheckButtonTemplate")
        check:SetPoint('TOPLEFT',-27,2)

        check:SetScript('OnClick', function()
            if not UnitAffectingCombat('player') then
                C_CVar.SetCVar("autoLootDefault", not C_CVar.GetCVarBool("autoLootDefault") and '1' or '0')
                local value= C_CVar.GetCVarBool("autoLootDefault")
                print(id, addName, not e.onlyChinese and AUTO_LOOT_DEFAULT_TEXT or "自动拾取", e.GetEnabeleDisable(value))
                if value and not IsModifierKeyDown() then
                    for i = GetNumLootItems(), 1, -1 do
                        LootSlot(i);
                    end
                end
            end
        end)
        check:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT");
            e.tips:ClearLines();
            e.tips:AddDoubleLine(e.onlyChinese and '自动拾取' or AUTO_LOOT_DEFAULT_TEXT, (e.onlyChinese and '当前' or REFORGE_CURRENT)..': '..e.GetEnabeleDisable(C_CVar.GetCVarBool("autoLootDefault")))
            e.tips:AddLine(' ')
            local col= UnitAffectingCombat('player') and '|cff606060'
            e.tips:AddDoubleLine((col or '')..(e.onlyChinese and '拾取时' or PROC_EVENT512_DESC:format(ITEM_LOOT)),
                (col or '|cnGREEN_FONT_COLOR:')..'Shift|r '..(e.onlyChinese and '禁用' or DISABLE))
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
        end)
        check:SetScript('OnShow', function(self)
            self:SetEnabled(not UnitAffectingCombat('player'))
            self:SetChecked(C_CVar.GetCVarBool("autoLootDefault"))
        end)
    end





    Init_Frame_Plus()--加宽，框架x2

end































--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:RegisterEvent('MERCHANT_SHOW')
panel:RegisterEvent('UPDATE_INVENTORY_DURABILITY')

panel:RegisterEvent('ENCOUNTER_LOOT_RECEIVED')
panel:RegisterEvent('PLAYER_AVG_ITEM_LEVEL_UPDATE')

panel:RegisterEvent('MERCHANT_UPDATE')--购回

panel:RegisterEvent('LOOT_READY')--自动拾取加强 


panel:SetScript("OnEvent", function(_, event, arg1, arg2, arg3, _, arg5)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            Save.hideSellItem= Save.hideSellItem or {}
            Save.SellItemDefaultPrice= Save.SellItemDefaultPrice or {}

            --添加控制面板
            local initializer2= e.AddPanel_Check({
                name= '|A:SpellIcon-256x256-SellJunk:0:0|a'..(e.onlyChinese and '商人' or addName),
                tooltip= addName,
                value= not Save.disabled,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                end
            })

            local initializer= e.AddPanel_Check({
                name= e.onlyChinese and "自动拾取" or AUTO_LOOT_DEFAULT_TEXT,
                tooltip= (not e.onlyChinese and AUTO_LOOT_DEFAULT_TEXT..', '..REFORGE_CURRENT or '自动拾取, 当前: ')..e.GetEnabeleDisable(C_CVar.GetCVarBool("autoLootDefault"))
                    ..'|n'..(not e.onlyChinese and HUD_EDIT_MODE_LOOT_FRAME_LABEL..'Shift: '..DISABLE or '拾取窗口 Shift: 禁用')..'|n|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '不在战斗中' or 'not in combat'),
                value= Save.altDisabledAutoLoot,
                func= function()
                    Save.altDisabledAutoLoot= not Save.altDisabledAutoLoot and true or nil
                end
            })
            initializer:SetParentInitializer(initializer2, function() return not Save.disabled end)


            if Save.disabled then
                e.CheckItemSell=nil
                panel:UnregisterAllEvents()
            else
                if WoWToolsSave then
                    buySave=WoWToolsSave.BuyItems and WoWToolsSave.BuyItems[e.Player.name_realm] or buySave--购买物品
                    RepairSave=WoWToolsSave.Repair and WoWToolsSave.Repair[e.Player.name_realm] or RepairSave--修理
                end
                avgItemLevel= GetAverageItemLevel()--装等

                Init()
                --panel:UnregisterEvent('ADDON_LOADED')
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_AuctionHouseUI' then
            Init_AuctionHouse()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
            WoWToolsSave.BuyItems=WoWToolsSave.BuyItems or {}--购买物品
            WoWToolsSave.BuyItems[e.Player.name_realm]=buySave
            WoWToolsSave.Repair=WoWToolsSave.Repair or {}--修理
            WoWToolsSave.Repair[e.Player.name_realm] = RepairSave
        end
    elseif event=='MERCHANT_SHOW' then
        set_Durabiliy_Value_Text()--显示耐久度
        setAutoRepairAll()--自动修理
        setSellItems()--出售物品
        set_Buy_Items()--购买物品


    elseif event=='UPDATE_INVENTORY_DURABILITY' then
        set_Durabiliy_Value_Text()

    elseif event=='ENCOUNTER_LOOT_RECEIVED' then--买出BOOS装备
        if IsInInstance() and arg5 and arg5:find(e.Player.name) then
            bossLoot(arg2, arg3)
        end

    elseif event=='PLAYER_AVG_ITEM_LEVEL_UPDATE' then
        avgItemLevel= GetAverageItemLevel()--装等

    elseif event=='MERCHANT_UPDATE' then
        set_BuyBack_Items()--回购

    elseif event=='LOOT_READY' then--拾取, 增强
        if arg1 then
            if IsShiftKeyDown() and Save.altDisabledAutoLoot and not UnitAffectingCombat('player') then
                C_CVar.SetCVar("autoLootDefault", '0')
                print(id, addName,'|cnGREEN_FONT_COLOR:Shift|r', e.onlyChinese and "自动拾取" or AUTO_LOOT_DEFAULT_TEXT, e.GetEnabeleDisable(C_CVar.GetCVarBool("autoLootDefault")))
            else
                for i = GetNumLootItems(), 1, -1 do
                    LootSlot(i);
                end
            end
        end

    end
end)
