--购买物品
local function Save()
    return WoWToolsSave['Plus_SellBuy']
end

local function Get_Buy_Num(itemID)
    if itemID then
        return WoWToolsSave['Plus_SellBuy'].buyItems[WoWTools_DataMixin.Player.GUID][itemID]
    end
end

local function SaveBuyItem(itemID, num)--当num=nil时，会清除
    WoWToolsSave['Plus_SellBuy'].buyItems[WoWTools_DataMixin.Player.GUID][itemID]=num
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

            if (price and price > 0) then
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
            print(WoWTools_MerchantMixin.addName, WoWTools_DataMixin.onlyChinese and '正在购买' or TUTORIAL_TITLE20, '|cnGREEN_FONT_COLOR:'..num2..'|r', itemLink2)
        end
    end)
end




















local function Add_BuyItem(itemID, itemLink)

    if not itemID then
        return
    end


        local icon
        icon= C_Item.GetItemIconByID(itemLink)
        icon= icon and '|T'..icon..':0|t' or ''

        StaticPopupDialogs['WoWTools_AutoBuy']= {
            text =WoWTools_DataMixin.addName..' '..WoWTools_MerchantMixin.addName
            ..'|n|n'.. (WoWTools_DataMixin.onlyChinese and '自动购买' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, PURCHASE))..': '..icon ..itemLink
            ..'|n|n'..WoWTools_DataMixin.Icon.Player..WoWTools_DataMixin.Player.name_realm..': ' ..(WoWTools_DataMixin.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL)
            ..'|n|n0: '..(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)
            ..(Save().notAutoBuy and '|n|n'..(WoWTools_DataMixin.onlyChinese and '自动购买' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, PURCHASE))..': '..WoWTools_TextMixin:GetEnabeleDisable(false) or ''),
            button1 = WoWTools_DataMixin.onlyChinese and '购买' or PURCHASE,
            button2 = WoWTools_DataMixin.onlyChinese and '取消' or CANCEL,
            whileDead=true, hideOnEscape=true, exclusive=true, hasEditBox=true,
            OnAccept=function(self)
                local edit= self.editBox or self:GetEditBox()
                local num= edit:GetNumber()
                if num==0 then
                    SaveBuyItem(itemID, nil)
                    print(WoWTools_DataMixin.Icon.icon2..WoWTools_MerchantMixin.addName, '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)..'|r', itemLink)
                else
                    SaveBuyItem(itemID, num)
                    Save().Sell[itemID]=nil
                    print(WoWTools_DataMixin.Icon.icon2..WoWTools_MerchantMixin.addName, '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '购买' or PURCHASE)..'|rx|cffff00ff'..num..'|r', itemLink)
                    set_buy_item()--购买物品
                end
                BuyItemButton:set_text()--回购，数量，提示
                WoWTools_MerchantMixin:Update_MerchantFrame()
            end,
            OnShow=function(self)
                local edit= self.editBox or self:GetEditBox()
                edit:SetNumeric(true)
                local num= Get_Buy_Num(itemID) or 1
                if num then
                    edit:SetText(num)
                end
            end,
            OnHide= function(self)
                local edit= self.editBox or self:GetEditBox()
                edit:SetText("")
                edit:ClearFocus()
            end,
            EditBoxOnEscapePressed =function(s)
                s:ClearFocus()
                s:GetParent():Hide()
            end,
        }
        StaticPopup_Show('WoWTools_AutoBuy')

end


























local function Check_All(quality)
     return WoWTools_BagMixin:GetItems(true, nil, nil, function(_, _, info)
        local data= WoWTools_ItemMixin:GetTooltip({
            hyperLink= info.hyperlink,
            onlyText=true,
            text={ITEM_UNSELLABLE}--无法出售
        })
        return not info.isLocked
            and info.quality<Enum.ItemQuality.Legendary
            and not Save().noSell[info.itemID]
            and not data.text[ITEM_UNSELLABLE]
            and (info.quality==quality or not quality)
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
        print('|cnRED_FONT_COLOR:'..gruop..')|r',  data.hyperlink, C_CurrencyInfo.GetCoinTextureString(prece))
    end

    if num > 0 then
        print(
            WoWTools_DataMixin.Icon.icon2..WoWTools_MerchantMixin.addName,
            (WoWTools_DataMixin.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB)..' |cnGREEN_FONT_COLOR:'..gruop..'|r'..(WoWTools_DataMixin.onlyChinese and '组' or AUCTION_PRICE_PER_STACK),
            '|cnGREEN_FONT_COLOR:'..num..'|r'..(WoWTools_DataMixin.onlyChinese and '件' or AUCTION_HOUSE_QUANTITY_LABEL),
            C_CurrencyInfo.GetCoinTextureString(preceTotale)
        )
    end
end







local function Init_Menu_Sell(self, root)
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
    local sub, sub2, name, num, items

--出售全部
    items= Check_All()
    num= #items

    name= (WoWTools_DataMixin.onlyChinese and '出售全部' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, AUCTION_HOUSE_SELL_TAB, ALL))
        ..' #|cnGREEN_FONT_COLOR:'..num

    sub= root:CreateButton(
        name,
    function(data)
        StaticPopup_Show('WoWTools_OK',
            '|A:Perks-ShoppingCart:0:0|a'..data.name..att,
            nil,
            {SetValue=function()
                Sell_Items(Check_All())
            end})
        return MenuResponse.Open
    end, {name=name})

    sub:SetTooltip(function(tooltip)
        for index, info in pairs(Check_All()) do
            tooltip:AddDoubleLine(WoWTools_ItemMixin:GetName(info.info.itemID, info.info.hyperlink), index)
        end
    end)

    local tabCN= {
        [0]= WoWTools_DataMixin.onlyChinese and '粗糙' or ITEM_QUALITY0_DESC,
        [1]= WoWTools_DataMixin.onlyChinese and '普通' or ITEM_QUALITY1_DESC,
        [2]= WoWTools_DataMixin.onlyChinese and '优秀' or ITEM_QUALITY2_DESC,
        [3]= WoWTools_DataMixin.onlyChinese and '精良' or ITEM_QUALITY3_DESC,
        [4]= WoWTools_DataMixin.onlyChinese and '史诗' or ITEM_QUALITY4_DESC,

    }
    for quality= 0 , 4 do
        name= select(4, WoWTools_ItemMixin:GetColor(quality))
            ..(WoWTools_DataMixin.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB)
            ..tabCN[quality]
            ..' #|cffffffff'..#Check_All(quality)

        sub2= sub:CreateButton(
            name,
        function(data)
            StaticPopup_Show('WoWTools_OK',
                '|A:Perks-ShoppingCart:0:0|a'..data.name..att,
                nil,
                {SetValue=function()
                    Sell_Items(Check_All(data.quality))
                end})
            return MenuResponse.Open
        end, {name=name, quality=quality})

        sub2:SetTooltip(function(tooltip, desc)
            for index, info in pairs(Check_All(desc.data.quality)) do
                tooltip:AddDoubleLine(WoWTools_ItemMixin:GetName(info.info.itemID, info.info.hyperlink), index)
            end
        end)
    end
end






















local function Init()
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
            local icon= C_Item.GetItemIconByID(itemLink)
            local name= '|T'..(icon or 0)..':0|t'..itemLink
            if Save().Sell[itemIDorIndex] then
                GameTooltip:AddDoubleLine(name, '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '移除出售' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REMOVE, AUCTION_HOUSE_SELL_TAB)))
                self.texture:SetAtlas('bags-button-autosort-up')
            else
                GameTooltip:AddDoubleLine(name, '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '添加出售' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, AUCTION_HOUSE_SELL_TAB)))
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
            GameTooltip:AddDoubleLine('|A:Perks-ShoppingCart:0:0|a|cffff00ff'..(WoWTools_DataMixin.onlyChinese and '自动购买' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, PURCHASE)), '|cnGREEN_FONT_COLOR: #'..num..'|r')
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
            if Save().Sell[itemID] then
                Save().Sell[itemID]=nil
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_MerchantMixin.addName, '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '移除' or REMOVE)..'|r', WoWTools_DataMixin.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB, itemLink)
            else
                Save().Sell[itemID]=true
                Save().noSell[itemID]=nil
                SaveBuyItem(itemID, nil)
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_MerchantMixin.addName, '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '添加' or ADD)..'|r'..(WoWTools_DataMixin.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB), itemLink )
                if _G['WoWTools_AutoSellJunkCheck'] then
                    _G['WoWTools_AutoSellJunkCheck']:set_sell_junk()--出售物品
                end
            end
            ClearCursor()
            self:set_text()--回购，数量，提示

        elseif infoType=='merchant' and itemID then--购买物品, itemID 为 index
            Add_BuyItem(GetMerchantItemID(itemID), GetMerchantItemLink(itemID))
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
        for _ in pairs(Save().buyItems[WoWTools_DataMixin.Player.GUID]) do
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