if GameLimitedMode_IsActive() or PlayerGetTimerunningSeasonID() then
    return
end
--拍卖行
local e= select(2, ...)
local function Save()
    return WoWTools_AuctionHouseMixin.Save
end
















--下一个，拍卖，物品  
local function Init_NextItem()
    AuctionHouseFrame.CommoditiesSellFrame.PostButton:SetHeight(32)--<Size x="194" y="22"/>
    AuctionHouseFrame.ItemSellFrame.PostButton:SetHeight(32)

    hooksecurefunc(AuctionHouseFrame.CommoditiesSellFrame, 'PostItem', function(self)
        self.isNextItem=true
    end)
    hooksecurefunc(AuctionHouseFrame.CommoditiesSellFrame, 'UpdatePostButtonState', function(self)
        self.PostButton:ClearAllPoints()
        self.PostButton:SetPoint('BOTTOM', 45, 75)
        if self:GetItem()
            or not C_AuctionHouse.IsThrottledMessageSystemReady()
            or not self.isNextItem
            or AuctionHouseMultisellProgressFrame:IsShown()
        then
            return
        end
        C_Timer.After(0.3, function() WoWTools_AuctionHouseMixin:SetPostNextSellItem() end)--放入，第一个，物品
        self.isNextItem=nil
    end)
    hooksecurefunc(AuctionHouseFrame.ItemSellFrame, 'PostItem', function(self)
        self.isNextItem=true
    end)
    hooksecurefunc(AuctionHouseFrame.ItemSellFrame, 'UpdatePostButtonState', function(self)
        self.PostButton:ClearAllPoints()
        self.PostButton:SetPoint('BOTTOM', 45, 75)
        if self:GetItem()
            or not C_AuctionHouse.IsThrottledMessageSystemReady()
            or not self.isNextItem
            or AuctionHouseMultisellProgressFrame:IsShown()
        then
            return
        end
        C_Timer.After(0.3, function() WoWTools_AuctionHouseMixin:SetPostNextSellItem() end)--放入，第一个，物品
        self.isNextItem=nil
    end)
end















--转到，商品，模式，按钮
local function Init_ShowCommoditiesButton()
    local levelFrame= AuctionHouseFrame.CommoditiesSellFrame.QuantityInput.MaxButton:GetFrameLevel()

    local showCommoditiesButton=WoWTools_ButtonMixin:Cbtn(AuctionHouseFrame.ItemSellFrame, {
        isUI=true,
        size={100,22},
        text=e.onlyChinese and '物品' or ITEMS
    })
    showCommoditiesButton:SetPoint('BOTTOMRIGHT', -15,15)
    showCommoditiesButton:SetFrameLevel(levelFrame)
    showCommoditiesButton:SetScript('OnLeave', GameTooltip_Hide)
    showCommoditiesButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT");
        e.tips:ClearLines();
        e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_AuctionHouseMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '显示模式' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, MODE), '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '转到' or CONVERT)..'|r '..(e.onlyChinese and '材料' or PROFESSIONS_COLUMN_HEADER_REAGENTS))
        e.tips:Show();
    end)
    showCommoditiesButton:SetScript('OnClick', function()
        AuctionHouseFrame:ClearPostItem()
        if AuctionHouseMultisellProgressFrame:IsShown() then
            C_AuctionHouse.CancelSell()
        end
        AuctionHouseFrame:SetDisplayMode(AuctionHouseFrameDisplayMode.CommoditiesSell)
        C_Timer.After(0.5, function() WoWTools_AuctionHouseMixin:SetPostNextSellItem() end)--放入，第一个，物品
    end)


--转到，出售商品，按钮
    local showSellButton=WoWTools_ButtonMixin:Cbtn(AuctionHouseFrame.CommoditiesSellFrame, {
        isUI=true,
        size={100,22},
        text=e.onlyChinese and '材料' or PROFESSIONS_COLUMN_HEADER_REAGENTS
    })
    showSellButton:SetPoint('BOTTOMRIGHT',  -15,15)
    showSellButton:SetFrameLevel(levelFrame)
    showSellButton:SetScript('OnLeave', GameTooltip_Hide)
    showSellButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT");
        e.tips:ClearLines();
        e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_AuctionHouseMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '显示' or SHOW, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '转到' or CONVERT)..'|r '..(e.onlyChinese and '物品' or ITEMS))
        e.tips:Show();
    end)
    showSellButton:SetScript('OnClick', function()
        AuctionHouseFrame:ClearPostItem()
        AuctionHouseFrame:SetDisplayMode(AuctionHouseFrameDisplayMode.ItemSell)
        C_Timer.After(0.5, function() WoWTools_AuctionHouseMixin:SetPostNextSellItem() end)--放入，第一个，物品
    end)

--取消拍卖
    local cancelButton2= WoWTools_ButtonMixin:Cbtn(AuctionHouseFrame.ItemSellFrame.PostButton, {size=32, texture='Interface\\Buttons\\CancelButton-Up'})
    cancelButton2:SetHighlightTexture('Interface\\Buttons\\CancelButton-Highlight')
    cancelButton2:SetPushedTexture('Interface\\Buttons\\CancelButton-Down')
    cancelButton2:SetFrameLevel(1501)
    cancelButton2:SetPoint('RIGHT', AuctionHouseFrame.ItemSellFrame.PostButton, 'LEFT', 0,-2)
    cancelButton2:SetScript('OnLeave', GameTooltip_Hide)
    cancelButton2:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT");
        e.tips:ClearLines();
        e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_AuctionHouseMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(' ', e.onlyChinese and '取消拍卖' or AUCTION_HOUSE_CANCEL_AUCTION_BUTTON)
        e.tips:Show();
    end)
    cancelButton2:SetScript('OnClick', C_AuctionHouse.CancelSell)





--Blizzard_AuctionHouseSearchBar.lua
--出售，物品，双击列表，转到购买界面
    hooksecurefunc(AuctionHouseFrame.CommoditiesSellList.ScrollBox, 'Update', function(frame)
        if not frame:GetView() then
            return
        end
        for _, btn in pairs(frame:GetFrames() or {}) do
            if not btn.setOnDoubleClick then
                btn:SetScript('OnDoubleClick', function()
                    local itemLink= AuctionHouseFrame.CommoditiesSellFrame.ItemDisplay:GetItemLink()
                    local itemName= itemLink and C_Item.GetItemInfo(itemLink)
                    if itemName then
                        AuctionHouseFrame:SetDisplayMode(AuctionHouseFrameDisplayMode.Buy)
                        AuctionHouseFrame.SearchBar.SearchBox:SetText(itemName)
                        AuctionHouseFrame.SearchBar:StartSearch()
                    end
                end)
                btn.setOnDoubleClick=true
            end
        end
    end)
    hooksecurefunc(AuctionHouseFrame.ItemSellList.ScrollBox, 'Update', function(frame)
        if not frame:GetView() then
            return
        end
        for _, btn in pairs(frame:GetFrames() or {}) do
            if not btn.setOnDoubleClick then
                btn:SetScript('OnDoubleClick', function()
                    local itemLink= AuctionHouseFrame.ItemSellFrame.ItemDisplay:GetItemLink()
                    local itemName= itemLink and C_Item.GetItemInfo(itemLink)
                    if itemName then
                        AuctionHouseFrame:SetDisplayMode(AuctionHouseFrameDisplayMode.Buy)
                        AuctionHouseFrame.SearchBar.SearchBox:SetText(itemName)
                        AuctionHouseFrame.SearchBar:StartSearch()
                    end
                end)
                btn.setOnDoubleClick=true
            end
        end
    end)

end


















--显示拍卖行时，转到出售物品
local function OnShowToSellFrame()
    if not Save().intShowSellItem then
        return
    end
    if not AuctionHouseFrame:IsShown() then
        return
    end
    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES do--Constants.InventoryConstants.NumBagSlots
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            if select(2, WoWTools_AuctionHouseMixin:GetItemSellStatus(bag, slot, true)) then
                AuctionHouseFrame:SetDisplayMode(AuctionHouseFrameDisplayMode.CommoditiesSell)
                C_Timer.After(0.5, function() WoWTools_AuctionHouseMixin:SetPostNextSellItem() end)--放入，第一个，物品
                return
            end
        end
    end
end














--默认价格，替换，原生func
local function GetDefaultPrice(itemLocation)
    local price= 100000
    if itemLocation and itemLocation:IsValid() then
        local itemLink = C_Item.GetItemLink(itemLocation);
        local itemID= C_Item.GetItemID(itemLocation)

        if itemID and Save().SellItemDefaultPrice[itemID] then--上次保存的，物价
            price= Save().SellItemDefaultPrice[itemID]

        elseif itemID and C_MountJournal.GetMountFromItem(itemID) or C_ToyBox.GetToyInfo(itemID) then--坐骑
            price= 999999900--9.9万

        elseif itemID and C_PetJournal.GetPetInfoByItemID(itemID)--宠物
            or (itemLink and (itemLink:find('Hbattlepet:(%d+)')))
        then
            price= 99999900--0.9万

        elseif itemLink and LinkUtil.IsLinkType(itemLink, "item") then
            local vendorPrice = select(11, C_Item.GetItemInfo(itemLink));
            if vendorPrice then

                local defaultPrice = vendorPrice * 500--倍数，原1.5倍
                price = defaultPrice + (COPPER_PER_SILVER - (defaultPrice % COPPER_PER_SILVER)); -- AH prices must be in silver increments.
            end
        end
    end
    return price
end


















--单价，倍数
local function Update_Total_Price(frame)
    local itemLocation= frame:GetItem()
    local text=''
    local text2=''
    if itemLocation and itemLocation:IsValid() then
        local itemLink = C_Item.GetItemLink(itemLocation);
        local vendorPrice =itemLink and select(11, C_Item.GetItemInfo(itemLink)) or 10000;
        local unitPrice= frame.GetUnitPrice and frame:GetUnitPrice() or frame.PriceInput:GetAmount();-- frame:GetUnitPrice()
        unitPrice= (unitPrice==0 or not unitPrice) and 1 or unitPrice
        local col=''
        if vendorPrice and unitPrice and vendorPrice>0 and unitPrice>0 then
            if unitPrice> vendorPrice then
                local x= unitPrice/vendorPrice
                if x<5 then
                    col= '|cff9e9e9e'
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
                text= col..(e.onlyChinese and '危险' or VOICEMACRO_1_Sc_0)
                local itemID=  C_Item.GetItemID(itemLocation)
                if itemID and not Save().hideSellItem[itemID] then--加入，隐藏，物品列表
                    Save().hideSellItem[itemID]=true

                    WoWTools_AuctionHouseMixin:Init_Sell_Item_Button()

                    AuctionHouseFrame:ClearPostItem()
                    C_Timer.After(0.3, function() WoWTools_AuctionHouseMixin:SetPostNextSellItem() end)--放入，第一个，物品
                end
            end
        end
        if vendorPrice then
            text2= col..GetMoneyString(vendorPrice)--C_CurrencyInfo.GetCoinTextureString(vendorPrice)
        end
    end
    frame.vendorPriceLabel:SetText(text2)
    frame.percentLabel:SetText(text)
end

--记录，用户，输入，价格
local function Save_SellItem_Price(frame)
    local itemLocation= frame:GetItem()
    if itemLocation and itemLocation:IsValid() then
        local itemID= C_Item.GetItemID(itemLocation)
        if itemID  then
            local unitPrice= frame.PriceInput:GetAmount()
            if unitPrice and unitPrice>100000 then--10金
                Save().SellItemDefaultPrice[itemID]= unitPrice
            else
                Save().SellItemDefaultPrice[itemID]=nil
            end
        end
    end
end







--单价，倍数
local function Init_PercentLabel()
    AuctionHouseFrame.CommoditiesSellFrame.percentLabel= WoWTools_LabelMixin:Create(AuctionHouseFrame.CommoditiesSellFrame, {size=22, justifyH='RIGHT'})--单价，提示
    AuctionHouseFrame.CommoditiesSellFrame.percentLabel:SetPoint('BOTTOMRIGHT', AuctionHouseFrame.CommoditiesSellList, 'TOP', -50,0)

    AuctionHouseFrame.CommoditiesSellFrame.vendorPriceLabel= WoWTools_LabelMixin:Create(AuctionHouseFrame.CommoditiesSellFrame, {size=12})--单价，提示
    AuctionHouseFrame.CommoditiesSellFrame.vendorPriceLabel:SetPoint('TOPRIGHT', AuctionHouseFrame.CommoditiesSellFrame.PriceInput.MoneyInputFrame.GoldBox, 'BOTTOMRIGHT',0,4)

    AuctionHouseFrame.ItemSellFrame.percentLabel= WoWTools_LabelMixin:Create(AuctionHouseFrame.ItemSellFrame, {size=22, justifyH='RIGHT'})--单价，提示
    AuctionHouseFrame.ItemSellFrame.percentLabel:SetPoint('BOTTOMRIGHT', AuctionHouseFrame.ItemSellList, 'TOP', -50,0)

    AuctionHouseFrame.ItemSellFrame.vendorPriceLabel= WoWTools_LabelMixin:Create(AuctionHouseFrame.ItemSellFrame, {size=12})--单价，提示
    AuctionHouseFrame.ItemSellFrame.vendorPriceLabel:SetPoint('TOPRIGHT', AuctionHouseFrame.ItemSellFrame.PriceInput.MoneyInputFrame.GoldBox, 'BOTTOMRIGHT',0,4)

    hooksecurefunc(AuctionHouseFrame.CommoditiesSellFrame, 'UpdateTotalPrice', function(self)
        Update_Total_Price(self)
    end)
    hooksecurefunc(AuctionHouseFrame.ItemSellFrame, 'UpdateTotalPrice', function(self)
        Update_Total_Price(self)
    end)


    AuctionHouseFrame.CommoditiesSellFrame.PriceInput.MoneyInputFrame.GoldBox:HookScript('OnTextChanged', function(_, userInput)
        if userInput then
            Save_SellItem_Price(AuctionHouseFrame.CommoditiesSellFrame)
        end
    end)
    AuctionHouseFrame.ItemSellFrame.PriceInput.MoneyInputFrame.GoldBox:HookScript('OnTextChanged', function(_, userInput)
        if userInput then
            Save_SellItem_Price(AuctionHouseFrame.ItemSellFrame)
        end
    end)

    AuctionHouseFrame.CommoditiesSellFrame.PriceInput.MoneyInputFrame.SilverBox:HookScript('OnTextChanged', function(_, userInput)
        if userInput then
            Save_SellItem_Price(AuctionHouseFrame.CommoditiesSellFrame)
        end
    end)
    AuctionHouseFrame.ItemSellFrame.PriceInput.MoneyInputFrame.SilverBox:HookScript('OnTextChanged', function(_, userInput)
        if userInput then
            Save_SellItem_Price(AuctionHouseFrame.ItemSellFrame)
        end
    end)

end














--出售物品时，使用，最大数量 Blizzard_AuctionHouseSellFrame.lua
local function Init_MaxSellItemCheck()
    local MaxSellItemCheck, MaxSellItemCheck2
    MaxSellItemCheck= CreateFrame('CheckButton', nil, AuctionHouseFrame.CommoditiesSellFrame.QuantityInput.MaxButton, 'InterfaceOptionsCheckButtonTemplate')
    MaxSellItemCheck:SetPoint('LEFT', AuctionHouseFrame.CommoditiesSellFrame.QuantityInput.MaxButton, 'RIGHT')
    MaxSellItemCheck:SetSize(24,24)
    MaxSellItemCheck:SetChecked(Save().isMaxSellItem)

    MaxSellItemCheck:SetScript('OnLeave', GameTooltip_Hide)
    MaxSellItemCheck:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_AuctionHouseMixin.addName)
        e.tips:AddDoubleLine(' ', e.onlyChinese and '最大数量' or AUCTION_HOUSE_MAX_QUANTITY_BUTTON)
        e.tips:Show()
    end)
    MaxSellItemCheck:SetScript('OnClick', function()
        Save().isMaxSellItem= not Save().isMaxSellItem and true or nil
        MaxSellItemCheck2:SetChecked(Save().isMaxSellItem)
    end)

    MaxSellItemCheck2= CreateFrame('CheckButton', nil, AuctionHouseFrame.ItemSellFrame.QuantityInput.MaxButton, 'InterfaceOptionsCheckButtonTemplate')
    MaxSellItemCheck2:SetPoint('LEFT', AuctionHouseFrame.ItemSellFrame.QuantityInput.MaxButton, 'RIGHT')
    MaxSellItemCheck2:SetSize(24,24)
    MaxSellItemCheck2:SetChecked(Save().isMaxSellItem)

    MaxSellItemCheck2:SetScript('OnLeave', GameTooltip_Hide)
    MaxSellItemCheck2:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_AuctionHouseMixin.addName)
        e.tips:AddDoubleLine(' ', e.onlyChinese and '最大数量' or AUCTION_HOUSE_MAX_QUANTITY_BUTTON)
        e.tips:Show()
    end)
    MaxSellItemCheck2:SetScript('OnClick', function()
        Save().isMaxSellItem= not Save().isMaxSellItem and true or nil
        MaxSellItemCheck:SetChecked(Save().isMaxSellItem)
    end)
end















local function Init()
    Init_ShowCommoditiesButton()--转到，商品，模式，按钮
    Init_NextItem()--下一个，拍卖，物品
    Init_PercentLabel()--单价，倍数
    Init_MaxSellItemCheck()--出售物品时，使用，最大数量

--默认价格，替换，原生func
    function AuctionHouseFrame.CommoditiesSellFrame:GetDefaultPrice()
        return GetDefaultPrice(self:GetItem())
    end
    function AuctionHouseFrame.ItemSellFrame:GetDefaultPrice()
        return GetDefaultPrice(self:GetItem())
    end

--显示拍卖行时，转到出售物品
    C_Timer.After(0.3, function()
        AuctionHouseFrame:HookScript('OnShow', OnShowToSellFrame)
        OnShowToSellFrame()
    end)


--移动, Frame
--Blizzard_AuctionHouseFrame.xml
    AuctionHouseFrame.CommoditiesSellList:ClearAllPoints()
    AuctionHouseFrame.CommoditiesSellList:SetSize(427, 442)
    AuctionHouseFrame.CommoditiesSellList:SetPoint('BOTTOMLEFT', AuctionHouseFrame.MoneyFrameBorder, 'TOPLEFT')
    AuctionHouseFrame.CommoditiesSellFrame:ClearAllPoints()
    AuctionHouseFrame.CommoditiesSellFrame:SetSize(363, 442)
    AuctionHouseFrame.CommoditiesSellFrame:SetPoint('TOPLEFT', AuctionHouseFrame.CommoditiesSellList, 'TOPRIGHT')
--刷新，列表
    AuctionHouseFrame.CommoditiesSellList.RefreshFrame.RefreshButton:ClearAllPoints()
    AuctionHouseFrame.CommoditiesSellList.RefreshFrame.RefreshButton:SetParent(AuctionHouseFrame.CommoditiesSellFrame.PostButton)
    AuctionHouseFrame.CommoditiesSellList.RefreshFrame.RefreshButton:SetPoint('LEFT', AuctionHouseFrame.CommoditiesSellFrame.PostButton, 'RIGHT')

    AuctionHouseFrame.ItemSellList:ClearAllPoints()
    AuctionHouseFrame.ItemSellList:SetSize(427, 442)
    AuctionHouseFrame.ItemSellList:SetPoint('BOTTOMLEFT', AuctionHouseFrame.MoneyFrameBorder, 'TOPLEFT')
    AuctionHouseFrame.ItemSellFrame:ClearAllPoints()
    AuctionHouseFrame.ItemSellFrame:SetSize(363, 442)
    AuctionHouseFrame.ItemSellFrame:SetPoint('TOPLEFT', AuctionHouseFrame.ItemSellList, 'TOPRIGHT')
--刷新，列表
    AuctionHouseFrame.ItemSellList.RefreshFrame.RefreshButton:ClearAllPoints()
    AuctionHouseFrame.ItemSellList.RefreshFrame.RefreshButton:SetParent(AuctionHouseFrame.ItemSellFrame.PostButton)
    AuctionHouseFrame.ItemSellList.RefreshFrame.RefreshButton:SetPoint('LEFT', AuctionHouseFrame.ItemSellFrame.PostButton, 'RIGHT')

--可购买数量：
    AuctionHouseFrame.CommoditiesSellList.RefreshFrame.TotalQuantity:ClearAllPoints()
    AuctionHouseFrame.CommoditiesSellList.RefreshFrame.TotalQuantity:SetPoint('BOTTOMRIGHT', AuctionHouseFrame.CommoditiesSellList, 'TOPRIGHT', -25, 0)

    AuctionHouseFrame.ItemSellList.RefreshFrame.TotalQuantity:ClearAllPoints()
    AuctionHouseFrame.ItemSellList.RefreshFrame.TotalQuantity:SetPoint('BOTTOMRIGHT', AuctionHouseFrame.ItemSellList, 'TOPRIGHT', -25, 0)
end











function WoWTools_AuctionHouseMixin:Sell_Other()
    if not self.Save.disabledSellPlus then
        Init()
    end
end