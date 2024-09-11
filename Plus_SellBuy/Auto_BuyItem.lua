--购买物品
local e= select(2, ...)

local function Save()
    return WoWTools_SellBuyMixin.Save
end





local function GetBuyNum(itemID)
    return WoWTools_SellBuyMixin.Save.buyItems[e.Player.guid][itemID]
end







local function SaveBuyItem(itemID, num)--当num=nil时，会清除
    WoWTools_SellBuyMixin.Save.buyItems[e.Player.guid][itemID]=num
end














local function Init()
    local BuyItemButton=WoWTools_ButtonMixin:Cbtn(MerchantBuyBackItem, {size={22,22}, icon='hide', name='WoWTools_BuyItemButton'})
    BuyItemButton:SetPoint('BOTTOMRIGHT', MerchantBuyBackItem, 6,-4)
    function BuyItemButton:set_texture()
        self:SetNormalTexture(236994)
    end
    BuyItemButton:set_texture()
    function BuyItemButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()

        local infoType, itemIDorIndex, itemLink = GetCursorInfo()
        if infoType=='item' and itemIDorIndex and itemLink then
            local icon= C_Item.GetItemIconByID(itemLink)
            local name= '|T'..(icon or 0)..':0|t'..itemLink
            if Save().Sell[itemIDorIndex] then
                e.tips:AddDoubleLine(name, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除出售' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REMOVE, AUCTION_HOUSE_SELL_TAB)))
                self:SetNormalAtlas('bags-button-autosort-up')
            else
                e.tips:AddDoubleLine(name, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加出售' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, AUCTION_HOUSE_SELL_TAB)))
                if icon then
                    self:SetNormalTexture(icon)
                end
            end
        elseif infoType=='merchant' and itemIDorIndex then--购买物品
            local itemID= GetMerchantItemID(itemIDorIndex)
            local icon= select(2, GetMerchantItemInfo(itemIDorIndex))
            itemLink= GetMerchantItemLink(itemIDorIndex)
            
            if itemID and itemLink then
                local name = '|T'..(icon or 0)..':0|t'..itemLink
                local num= GetBuyNum(itemID)
                if num then
                    e.tips:AddDoubleLine(name..' x|cnGREEN_FONT_COLOR:'..num, '|cffff00ff'..(e.onlyChinese and '修改' or EDIT)..e.Icon.left)
                else
                    e.tips:AddDoubleLine(name, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '购买' or PURCHASE)..e.Icon.left)
                end
                if icon then
                    self:SetNormalTexture(icon)
                end
            end
        else

            e.tips:AddDoubleLine(e.addName, WoWTools_SellBuyMixin.addName)
            local num= self:set_text()--回购，数量，提示
            e.tips:AddDoubleLine('|T236994:0|t|cffff00ff'..(e.onlyChinese and '自动购买物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, PURCHASE)), '|cnGREEN_FONT_COLOR: #'..num..'|r')
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine((e.onlyChinese and '拖曳' or DRAG_MODEL)..e.Icon.left..(e.onlyChinese and '物品' or ITEMS), e.onlyChinese and '出售/购买' or (AUCTION_HOUSE_SELL_TAB..'/'..PURCHASE))
            --e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.left)
        end
        e.tips:Show()
    end

    BuyItemButton:SetScript('OnLeave', function(self) GameTooltip_Hide() self:set_texture() end)
    BuyItemButton:SetScript('OnEnter', BuyItemButton.set_tooltip)
    BuyItemButton:SetScript('OnMouseUp', BuyItemButton.set_texture)







--购买
    BuyItemButton:SetScript('OnMouseDown', function(self, d)
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType=='item' and itemID then
            if Save().Sell[itemID] then
                Save().Sell[itemID]=nil
                print(e.addName, WoWTools_SellBuyMixin.addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|r', e.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB, itemLink)
            else
                Save().Sell[itemID]=true
                Save().noSell[itemID]=nil                
                SaveBuyItem(itemID, nil)
                print(e.addName, WoWTools_SellBuyMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..'|r'..(e.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB), itemLink )
                if _G['WoWTools_AutoSellJunkCheck'] then
                    _G['WoWTools_AutoSellJunkCheck']:set_sell_junk()--出售物品
                end
            end
            ClearCursor()
            self:set_text()--回购，数量，提示

        elseif infoType=='merchant' and itemID then--购买物品
            local index=itemID
            itemID= GetMerchantItemID(index)
            itemLink=GetMerchantItemLink(index)
            if itemID and itemLink then
                local icon
                icon= C_Item.GetItemIconByID(itemLink)
                icon= icon and '|T'..icon..':0|t' or ''
                StaticPopupDialogs['WoWTools_AutoBuy']= {
                    text =e.addName..' '..WoWTools_SellBuyMixin.addName
                    ..'|n|n'.. (e.onlyChinese and '自动购买' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, PURCHASE))..': '..icon ..itemLink
                    ..'|n|n'..e.Icon.player..e.Player.name_realm..': ' ..(e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL)
                    ..'|n|n0: '..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)
                    ..(Save().notAutoBuy and '|n|n'..(e.onlyChinese and '自动购买' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, PURCHASE))..': '..e.GetEnabeleDisable(false) or ''),
                    button1 = e.onlyChinese and '购买' or PURCHASE,
                    button2 = e.onlyChinese and '取消' or CANCEL,
                    whileDead=true, hideOnEscape=true, exclusive=true, hasEditBox=true,
                    OnAccept=function(s)
                        local num= s.editBox:GetNumber()
                        if num==0 then                            
                            SaveBuyItem(itemID, nil)
                            print(e.addName, WoWTools_SellBuyMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)..'|r', itemLink)
                        else                            
                            SaveBuyItem(itemID, num)
                            Save().Sell[itemID]=nil
                            print(e.addName, WoWTools_SellBuyMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '购买' or PURCHASE)..'|rx|cffff00ff'..num..'|r', itemLink)
                            BuyItemButton:set_buy_item()--购买物品
                        end
                        BuyItemButton:set_text()--回购，数量，提示
                        WoWTools_SellBuyMixin:Set_Merchant_Info()--设置, 提示, 信息
                    end,
                    OnShow=function(s)
                        s.editBox:SetNumeric(true)
                        local num= GetBuyNum(itemID) or 1
                        if num then
                            s.editBox:SetText(num)
                        end
                    end,
                    OnHide= function(self3)
                        self3.editBox:SetText("")
                        self3.editBox:ClearFocus()
                    end,
                    EditBoxOnEscapePressed = function(s)
                        s:SetAutoFocus(false)
                        s:ClearFocus()
                        s:GetParent():Hide()
                    end,
                }
                StaticPopup_Show('WoWTools_AutoBuy')
                ClearCursor()
            end
        else
            --WoWTools_SellBuyMixin:Init_Menu(self)
            MenuUtil.CreateContextMenu(self,  function(f, root)
                root:CreateTitle(e.onlyChinese and '拖曳物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DRAG_MODEL, ITEMS))
                root:CreateDivider()
                WoWTools_SellBuyMixin:BuyItem_Menu(f, root)
            end)

        end
    end)







    function BuyItemButton:set_buy_item()--购买物品
        local numAllItems= GetMerchantNumItems() or 0
        if IsModifierKeyDown() or Save().notAutoBuy or numAllItems==0 then
            return
        end
        local Tab={}
        for index=1, numAllItems do
            local itemID=GetMerchantItemID(index)
            local num= GetBuyNum(itemID)
            if num then
                local buyNum=num-C_Item.GetItemCount(itemID, true, false, true)
                if buyNum>0 then
                    local maxStack = GetMerchantItemMaxStack(index)
                    local _, _, price, stackCount, _, _, _, extendedCost = GetMerchantItemInfo(index)
                    local canAfford
                    if (price and price > 0) then
                        canAfford = floor(GetMoney() / (price / stackCount))
                    end
                    if (extendedCost) then
                        for i = 1, MAX_ITEM_COST do
                            local _, itemValue, itemLink, currencyName = GetMerchantItemCostItem(index, i)
                            if itemLink and itemValue and itemValue>0 then
                                if not currencyName then
                                    local myCount = C_Item.GetItemCount(itemLink, false, false, true)
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
                print(WoWTools_SellBuyMixin.addName, e.onlyChinese and '正在购买' or TUTORIAL_TITLE20, '|cnGREEN_FONT_COLOR:'..num2..'|r', itemLink2)
            end
        end)
    end
    BuyItemButton:RegisterEvent('MERCHANT_SHOW')
    BuyItemButton:SetScript('OnEvent', BuyItemButton.set_buy_item)--购买物品

    BuyItemButton.Text= e.Cstr(BuyItemButton, {justifyH='CENTER'})
    BuyItemButton.Text:SetPoint('CENTER', 2, 0)
    function BuyItemButton:set_text()--回购，数量，提示
        local num= 0
        for _ in pairs(Save().buyItems[e.Player.guid]) do
            num= num +1
        end
        self.Text:SetText(not Save().notAutoBuy and num or '')
        return num
    end
    BuyItemButton:set_text()--回购，数量，提示
end








function WoWTools_SellBuyMixin:Init_Buy_Items_Button()--购买物品
    Init()
end