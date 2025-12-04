--购买物品
local function Save()
    return WoWToolsSave['Plus_SellBuy']
end

local function Get_Buy_Num(itemID)
    if itemID then
        local num=WoWToolsPlayerDate['SellBuyItems'].buy[WoWTools_DataMixin.Player.GUID][itemID]
        return num
    end
end

local function SaveBuyItem(itemID, num)--当num=nil时，会清除    
    WoWToolsPlayerDate['SellBuyItems'].buy[WoWTools_DataMixin.Player.GUID][itemID]=num
end



local BuyItemButton











local function set_buy_item()
    local numAllItems= GetMerchantNumItems() or 0

    if IsModifierKeyDown() or Save().notAutoBuy or numAllItems==0 then
        return
    end

    local Tab={}
    for index=1, numAllItems do
        local itemID= GetMerchantItemID(index)
        local info= itemID and C_MerchantFrame.GetItemInfo(index)
        local num= info and Get_Buy_Num(itemID) or 0
        local buyNum= num>0 and num- C_Item.GetItemCount(itemID, true, false, true) or 0

        if buyNum>0 then

            local maxStack = GetMerchantItemMaxStack(index)
            local price= info.price
            local stackCount= info.stackCount
            local canAfford

            if price==0 or not price then
                canAfford= stackCount or 1
            elseif (price and price > 0) then
                canAfford = floor(GetMoney() / (price / stackCount))
            else
                canAfford= info.stackCount--测试服中
            end

            if info.hasExtendedCost then
                for i = 1, MAX_ITEM_COST do
                    local _, itemValue, itemLink, currencyName = GetMerchantItemCostItem(index, i)
                    if itemLink and itemValue and itemValue>0 then
                        if not currencyName then
                            local myCount = C_Item.GetItemCount(itemLink, false, false, true)
                            local value= floor(myCount / (itemValue / stackCount))
                            canAfford=not canAfford and value or min(canAfford, value)
                        elseif currencyName then
                            local currencyinfo= C_CurrencyInfo.GetCurrencyInfoFromLink(itemLink)
                            if currencyinfo and currencyinfo.quantity then
                                local value=floor(currencyinfo.quantity / (itemValue / stackCount))
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

    C_Timer.After(1.5, function()
        for itemLink2, num2 in pairs(Tab) do
            print(
                WoWTools_MerchantMixin.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_DataMixin.onlyChinese and '正在购买' or TUTORIAL_TITLE20,
                '|cnGREEN_FONT_COLOR:'..num2..'|r',
                itemLink2
            )
        end
    end)
end

























local function Check_All(onlyRegents)
    return WoWTools_BagMixin:GetItems(nil, not onlyRegents, onlyRegents, function(_, _, info)
        return not info.isLocked
            and info.quality<Enum.ItemQuality.Legendary
            and (select(11, C_Item.GetItemInfo(info.hyperlink)) or 0)> 0
            and not WoWToolsPlayerDate['SellBuyItems'].noSell[info.itemID]
    end)
end

local function Sell_Items(tab)
    local num, gruop, preceTotale= 0, 0, 0
    local data
    for _, info in pairs(tab) do
        if IsModifierKeyDown()
            or not MerchantFrame:IsShown()
            or InCombatLockdown()
            --or MerchantFrame.selectedTab~=1
        then
            break
        end

        data= info.info
        do
            C_Container.UseContainerItem(info.bag, info.slot)--买出
        end

        local prece =0
        if not info.hasNoValue then--卖出钱
            prece = (select(11, C_Item.GetItemInfo(data.hyperlink)) or 0) * (data.stackCount or 1)--价格
            preceTotale = preceTotale + prece
        end

        gruop= gruop+ 1
        num= num+ (data.stackCount or 1)--数量
        print(
            WoWTools_DataMixin.Icon.icon2..'|cnWARNING_FONT_COLOR:'..gruop..')|r',
            data.hyperlink,
            C_CurrencyInfo.GetCoinTextureString(prece)
        )
    end

    if num > 0 then
        print(
            WoWTools_MerchantMixin.addName..WoWTools_DataMixin.Icon.icon2,
            (WoWTools_DataMixin.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB)..' |cnGREEN_FONT_COLOR:'..gruop..'|r'..(WoWTools_DataMixin.onlyChinese and '组' or AUCTION_PRICE_PER_STACK),
            '|cnGREEN_FONT_COLOR:'..num..'|r'..(WoWTools_DataMixin.onlyChinese and '件' or AUCTION_HOUSE_QUANTITY_LABEL),
            C_CurrencyInfo.GetCoinTextureString(preceTotale)
        )
    end
end








local function Set_SellMenu_Tooltip(tooltip, desc)
    if not desc.data.tab then
        return
    end
    for index, info in pairs(desc.data.tab) do
        tooltip:AddDoubleLine(
            '|T'..(info.info.iconFileID or 0)..':0|t'
            ..WoWTools_HyperLink:CN_Link(info.info.hyperlink, {isName=true, itemID=info.info.itemID})
            ..' |cffffffffx'
            ..(info.info.stackCount or 1),
            index..')'
        )
    end
    if not desc.data.tab2 then
        return
    end
    tooltip:AddLine(' ')

    for index, info in pairs(desc.data.tab2) do
        tooltip:AddDoubleLine(
            '|T'..(info.info.iconFileID or 0)..':0|t'
            ..WoWTools_HyperLink:CN_Link(info.info.hyperlink, {isName=true, itemID=info.info.itemID})
            ..' |cffffffffx'
            ..(info.info.stackCount or 1),
            index..')'
        )
    end
end



--出售菜单
local function Init_Menu_Sell(_, root)
    if WoWTools_MenuMixin:CheckInCombat(root) then
        return
    elseif not C_MerchantFrame.IsSellAllJunkEnabled() then
        root:CreateTitle(WoWTools_DataMixin.onlyChinese and '商人不收' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, AUCTION_HOUSE_SELL_TAB, DISABLE))
        return
    elseif MerchantFrame.selectedTab~=1 then
        root:CreateTitle(WoWTools_DataMixin.onlyChinese and '切换到商人' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SWITCH, MERCHANT))
        return
    end

    local att= '|n|n|cnYELLOW_FONT_COLOR:'
            ..(WoWTools_DataMixin.onlyChinese and '危险！' or VOICEMACRO_1_Sc_0)
            ..(WoWTools_DataMixin.onlyChinese and '危险！' or VOICEMACRO_1_Sc_0)
            ..(WoWTools_DataMixin.onlyChinese and '危险！' or VOICEMACRO_1_Sc_0)
            ..'|n'
    local sellText=  '|T236994:0|t'..(WoWTools_DataMixin.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB)
    local sub, sub2, name




    local items= Check_All()
    local regents= Check_All(true)
    local tabs={
        [0]={},
        [1]={},
        [2]={},
        [3]={},
        [4]={},
    }
    for _, data in pairs(items) do
        if tabs[data.info.quality] then
            table.insert(tabs[data.info.quality], data)
        end
    end

    local num= #items
    local regionNum= #regents

--出售全部
    sub= root:CreateButton(
        sellText
        ..' #|cnGREEN_FONT_COLOR:'
        ..num+regionNum,
    function()
        return MenuResponse.Open
    end)


    for quality= 0 , 4 do
        name= '|T236994:0|t'
            ..WoWTools_ItemMixin.QalityText[quality]
            ..' #|cffffffff'..#tabs[quality]

        sub2= sub:CreateButton(
            name,
        function(data)
            StaticPopup_Show('WoWTools_OK',
                sellText..data.name..att,
                nil,
                {SetValue=function()
                    Sell_Items(data.tab)
                end})
            return MenuResponse.Open
        end, {tab=tabs[quality], name=name})

        sub2:SetTooltip(Set_SellMenu_Tooltip)
    end

    sub:CreateDivider()
    name= '|T236994:0|t'
        ..(WoWTools_DataMixin.onlyChinese and '材料' or BAG_FILTER_REAGENTS)
        ..' #'..regionNum
    sub2= sub:CreateButton(
        name,
    function(data)
        StaticPopup_Show('WoWTools_OK',
            sellText..data.name..att,
            nil,
            {SetValue=function()
                Sell_Items(regents)
            end})
        return MenuResponse.Open
    end, {name=name, tab=regents})
    sub2:SetTooltip(Set_SellMenu_Tooltip)


    sub:CreateDivider()
    name= '|T236994:0|t'
        ..(WoWTools_DataMixin.onlyChinese and '全部' or  ALL)
        ..' #'..num..'+'..regionNum

    sub2= sub:CreateButton(
        name,
    function(data)
        StaticPopup_Show('WoWTools_OK',
            sellText..data.name..att,
            nil,
            {SetValue=function()
                do
                    Sell_Items(items)
                end
                do
                    Sell_Items(regents)
                end
            end})
        return MenuResponse.Open
    end, {name=name, tab=items, tab2=regents})

    sub2:SetTooltip(Set_SellMenu_Tooltip)
end






















local function Init()
    StaticPopupDialogs['WoWTools_AutoBuy']= {
        text = WoWTools_DataMixin.Icon.icon2
        ..(WoWTools_DataMixin.onlyChinese and '自动购买' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, PURCHASE))
        ..'|n'..WoWTools_DataMixin.Icon.Player..WoWTools_DataMixin.Player.Name_Realm
        ..'|n',
        button1 = WoWTools_DataMixin.onlyChinese and '购买' or PURCHASE,
        button2 = WoWTools_DataMixin.onlyChinese and '取消' or CANCEL,
        button3 = WoWTools_DataMixin.onlyChinese and '移除' or REMOVE,
        whileDead=true, hideOnEscape=true, exclusive=true,
        OnShow=function(self, data)
            local edit= self:GetEditBox()
            edit:SetNumeric(true)
            local num= Get_Buy_Num(data.itemID) or select(8, C_Item.GetItemInfo(data.itemID)) or 1
            edit:SetText(num)
            edit:SetFocus()
            edit:HighlightText()
        end,
        OnHide= function(self)
            local edit= self:GetEditBox()
            edit:SetText("")
            edit:SetNumeric(false)
            edit:ClearFocus()
        end,
        OnAccept=function(self, data)
            local edit= self:GetEditBox()
            local num= edit:GetNumber()
            if num==0 then
                SaveBuyItem(data.itemID, nil)
                print(
                    WoWTools_MerchantMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)
                    ..'|r',
                    select(2, C_Item.GetItemInfo(data.itemID)) or data.name or data.itemID
                )
            else
                SaveBuyItem(data.itemID, num)
                WoWToolsPlayerDate['SellBuyItems'].sell[data.itemID]=nil
                print(
                    WoWTools_MerchantMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '购买' or PURCHASE)..'|rx|cffff00ff'..num..'|r',
                    select(2, C_Item.GetItemInfo(data.itemID)) or data.name or data.itemID
                )
                set_buy_item()--购买物品
            end
            BuyItemButton:set_text()--回购，数量，提示
            WoWTools_MerchantMixin:Update_MerchantFrame()
        end,
        OnAlt=function(_, data)
            SaveBuyItem(data.itemID, nil)
            print(
                WoWTools_MerchantMixin.addName..WoWTools_DataMixin.Icon.icon2,
                '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)..'|r',
                select(2, C_Item.GetItemInfo(data.itemID)) or data.name or data.itemID
            )
        end,

        EditBoxOnEscapePressed =function(s)
            s:GetParent():Hide()
        end,
        hasItemFrame=true,
        hasEditBox=true,
    }



    BuyItemButton=WoWTools_ButtonMixin:Cbtn(MerchantBuyBackItem, {
        name='WoWTools_BuyItemButton',
        addTexture=true,
        size=35,
    })

     if Save().notPlus then
        BuyItemButton:SetPoint('BOTTOMRIGHT', MerchantBuyBackItem, 6,-4)
        BuyItemButton:SetSize(22, 22)
    else
        BuyItemButton:SetPoint('LEFT', MerchantBuyBackItemItemButtonIconTexture, 'RIGHT', 50, 0)
    end

    function BuyItemButton:set_texture()
        --self.texture:SetTexture(236994)
        self.texture:SetAtlas('Perks-ShoppingCart')
    end

    function BuyItemButton:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()

        local infoType, itemIDorIndex, itemLink = GetCursorInfo()
        if infoType=='item' and itemIDorIndex and itemLink then
            local icon= select(5, C_Item.GetItemInfoInstant(itemLink))
            local name= '|T'..(icon or 0)..':0|t'..itemLink
            if WoWToolsPlayerDate['SellBuyItems'].sell[itemIDorIndex] then
                GameTooltip:AddDoubleLine(
                    name,
                    '|A:bags-button-autosort-up:0:0|a|cnWARNING_FONT_COLOR:'
                    ..(WoWTools_DataMixin.onlyChinese and '移除出售' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REMOVE, AUCTION_HOUSE_SELL_TAB))
                )
                self.texture:SetAtlas('bags-button-autosort-up')
            else
                GameTooltip:AddDoubleLine(
                    name,
                    '|T236994:0|t|cnGREEN_FONT_COLOR:'
                    ..(WoWTools_DataMixin.onlyChinese and '添加出售' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, AUCTION_HOUSE_SELL_TAB))
                )
                if icon then
                    self.texture:SetTexture(icon)
                end
            end
        elseif infoType=='merchant' and itemIDorIndex then--购买物品
            local itemID= GetMerchantItemID(itemIDorIndex)
            local info= C_MerchantFrame.GetItemInfo(itemIDorIndex)
            local icon= info and info.texture
            itemLink= GetMerchantItemLink(itemIDorIndex)

            if itemID and itemLink then
                local name = '|T'..(icon or 0)..':0|t'..itemLink
                local num= Get_Buy_Num(itemID)
                if num then
                    GameTooltip:AddDoubleLine(name..' x|cnGREEN_FONT_COLOR:'..num, '|cffff00ff'..(WoWTools_DataMixin.onlyChinese and '修改' or EDIT)..WoWTools_DataMixin.Icon.left)
                else
                    GameTooltip:AddDoubleLine(name, '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '购买' or PURCHASE)..WoWTools_DataMixin.Icon.left)
                end
                if icon then
                    self.texture:SetTexture(icon)
                end
            end
        else

            --GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_MerchantMixin.addName)
            local num= self:set_text()--回购，数量，提示
            GameTooltip:AddDoubleLine(
                '|A:Perks-ShoppingCart:0:0|a|cffff00ff'
                ..(WoWTools_DataMixin.onlyChinese and '自动购买' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, PURCHASE)),
                '|cnGREEN_FONT_COLOR: #'..num..'|r'
            )
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '拖曳' or DRAG_MODEL)..WoWTools_DataMixin.Icon.left..(WoWTools_DataMixin.onlyChinese and '物品' or ITEMS), WoWTools_DataMixin.onlyChinese and '出售/购买' or (AUCTION_HOUSE_SELL_TAB..'/'..PURCHASE))
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.left)
        end
        GameTooltip:Show()
    end

    BuyItemButton:SetScript('OnLeave', function(self)
        self:set_texture()
        GameTooltip_Hide()
    end)
    BuyItemButton:SetScript('OnEnter', function(self)
        self:set_tooltip()
    end)
    BuyItemButton:SetScript('OnMouseUp', function(self)
        self:set_texture()
    end)













--购买
    BuyItemButton:SetScript('OnMouseDown', function(self, d)
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType=='item' and itemID then
            if WoWToolsPlayerDate['SellBuyItems'].sell[itemID] then
                WoWToolsPlayerDate['SellBuyItems'].sell[itemID]=nil
                print(
                    WoWTools_MerchantMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '移除' or REMOVE)..'|r',
                    WoWTools_DataMixin.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB,
                    itemLink
                )
            else
                WoWToolsPlayerDate['SellBuyItems'].sell[itemID]=true
                WoWToolsPlayerDate['SellBuyItems'].noSell[itemID]=nil
                SaveBuyItem(itemID, nil)
                print(
                    WoWTools_MerchantMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '添加' or ADD)..'|r'..(WoWTools_DataMixin.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB),
                    itemLink
                )
                if _G['WoWTools_AutoSellJunkCheck'] then
                    _G['WoWTools_AutoSellJunkCheck']:set_sell_junk()--出售物品
                end
            end
            ClearCursor()
            self:set_text()--回购，数量，提示

        elseif infoType=='merchant' and itemID then--购买物品, itemID 为 index
            itemID= GetMerchantItemID(itemID)

            if not itemID then
                return
            end

            local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(itemID)
            StaticPopup_Show('WoWTools_AutoBuy', nil, nil, {
                link= GetMerchantItemLink(itemID),
                itemID= itemID,
                name= WoWTools_TextMixin:CN(itemName, {itemID=itemID, isName=true}),
                color= {ITEM_QUALITY_COLORS[itemRarity].color:GetRGBA()},
                texture= itemTexture,
                count=C_Item.GetItemCount(itemID, true, true, true, true),
            })
            ClearCursor()

        else
            MenuUtil.CreateContextMenu(self,  function(f, root)
                Init_Menu_Sell(self, root)
                root:CreateDivider()
                root:CreateTitle(WoWTools_DataMixin.onlyChinese and '拖曳物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DRAG_MODEL, ITEMS))
                WoWTools_MerchantMixin:Player_Sell_Menu(f, root)

                WoWTools_MerchantMixin:BuyItem_Menu(f, root)
            end)

        end
    end)








--购买物品

    BuyItemButton:RegisterEvent('MERCHANT_SHOW')
    BuyItemButton:SetScript('OnEvent', function()
        set_buy_item()--购买物品
    end)

    BuyItemButton.Text= WoWTools_LabelMixin:Create(BuyItemButton, {justifyH='RIGHT', color={r=1,g=1,b=1}})
    BuyItemButton.Text:SetPoint('BOTTOMRIGHT')


    function BuyItemButton:set_text()--回购，数量，提示
        local num= 0
        for _ in pairs(WoWToolsPlayerDate['SellBuyItems'].buy[WoWTools_DataMixin.Player.GUID]) do
            num= num +1
        end
        self.Text:SetText(not Save().notAutoBuy and num or '')
        self.texture:SetDesaturated(Save().notAutoBuy or num==0)
        return num
    end

    BuyItemButton:set_text()--回购，数量，提示
    BuyItemButton:set_texture()

    Init=function()end
end















function WoWTools_MerchantMixin:Init_Buy_Items_Button()--购买物品
    Init()
end