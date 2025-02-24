if GameLimitedMode_IsActive() or PlayerGetTimerunningSeasonID() then
    return
end
--拍卖行
local e= select(2, ...)
local function Save()
    return WoWTools_AuctionHouseMixin.Save
end




local levelFrame
local AuctionHouseButton



local function Create_Button()
    local btn= WoWTools_ButtonMixin:Cbtn(AuctionHouseButton.frame, {button='ItemButton', icon='hide'})
    btn.selectTexture= btn:CreateTexture(nil, 'OVERLAY')
    btn.selectTexture:SetAtlas('Forge-ColorSwatchSelection')
    btn.selectTexture:SetPoint('CENTER')
    btn.selectTexture:SetSize(42, 42)
    btn.selectTexture:Hide()

    btn.isCommoditiesTexture= btn:CreateTexture(nil, 'OVERLAY')
    btn.isCommoditiesTexture:SetAtlas('AnimaChannel-Bar-Necrolord-Gem')--common-icon-checkmark')
    btn.isCommoditiesTexture:SetPoint('TOPRIGHT',2,2)
    btn.isCommoditiesTexture:SetSize(16, 16)
    btn.isCommoditiesTexture:Hide()

    function btn:set_alpha()
        btn:SetAlpha(
            (self.isPet and Save().hideSellPet[self.isPet] or  Save().hideSellItem[self:GetItemID()])
            and 0.3 or 1
        )
    end


    btn:SetScript('OnHide', function(self)
        self.isCommodities=nil
        self.isPet=nil
        self:Reset()
    end)

    btn:UpdateItemContextOverlayTextures(1)
    btn:SetScript('OnLeave', function()
        C_Container.SetItemSearch('')
        GameTooltip_Hide()
    end)


    btn:SetScript('OnEnter', function(self)
        local itemLink=self:GetItemLink()
        WoWTools_SetTooltipMixin:Frame(self, nil, {
            itemLink=itemLink,
            tooltip= self.isPet and
                (e.onlyChinese and '开始拍卖' or CREATE_AUCTION).. e.Icon.left..' '..e.Icon.right..(e.onlyChinese and '隐藏' or HIDE)
                or
                function(tooltip)
                    tooltip:AddLine(' ')
                    tooltip:AddDoubleLine(e.onlyChinese and '开始拍卖' or CREATE_AUCTION..e.Icon.left, e.Icon.right..(e.onlyChinese and '隐藏' or HIDE))
                end
        })
        local itemName
        if itemLink then
            local speciesID= itemLink and itemLink:match('Hbattlepet:(%d+)')
            if speciesID then
                itemName= C_PetJournal.GetPetInfoBySpeciesID(speciesID)
            end
            itemName= itemName or C_Item.GetItemNameByID(itemLink)
        end
        C_Container.SetItemSearch(itemName or '')
    end)

    btn:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then--放入，物品
            if AuctionHouseMultisellProgressFrame:IsShown() then
                C_AuctionHouse.CancelSell()
            end
            AuctionHouseFrame:SetPostItem(self.itemLocation)--ContainerFrame.lua

        elseif d=='RightButton' then--隐藏，物品
            local itemID= C_Item.GetItemID(self.itemLocation)
            if itemID then
                if self.isPet then
                    Save().hideSellPet[self.isPet]= not Save().hideSellPet[self.isPet] and self:GetItemLink() or nil
                else
                    Save().hideSellItem[itemID]= not Save().hideSellItem[itemID] and true or nil
                end

                if Save().hideSellItemListButton then--隐藏物品列表，隐藏按钮
                    AuctionHouseButton:Init_Item_Button()
                else
                    self:Settings()
                end

                if self.selectTexture:IsShown() then
                    AuctionHouseFrame:ClearPostItem()
                    WoWTools_AuctionHouseMixin:SetPostNextSellItem()
                end
            end
        end
    end)
    table.insert(AuctionHouseButton.buttons, btn)
    --AuctionHouseButton.buttons[index]= btn
    return btn
end










local function Init_Item_Button()
    if Save().hideSellItemList then
       return
    end

    local isCheckHideItem= Save().hideSellItemListButton--隐藏物品列表，隐藏按钮
    local isCommoditiesSellFrame, isItemSellFrame= WoWTools_AuctionHouseMixin:GetDisplayMode()

    local Tab={}
    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES do--Constants.InventoryConstants.NumBagSlots
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local itemLocation, itemCommodityStatus, info= WoWTools_AuctionHouseMixin:GetItemSellStatus(bag, slot, isCheckHideItem)
            if itemLocation then
                table.insert(Tab, {
                    itemLocation= itemLocation,
                    status= itemCommodityStatus,
                    count= info.stackCount,
                    itemID= info.itemID,
                    isPet= info.hyperlink:match('Hbattlepet:(%d+)')-- 注意，isPet 这个是字符
                })

            end
        end
    end

    table.sort(Tab, function(a, b)
        if a.status==b.status then
            if a.isPet and b.isPet then
                return tonumber(a.isPet)> tonumber(b.isPet)
            else
                return a.itemID> b.itemID
            end
        else
            return a.status>b.status
        end
    end)

    local index=1
    for _, tab in pairs(Tab) do
        local btn= AuctionHouseButton.buttons[index] or Create_Button()
        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", index==1 and AuctionHouseButton or AuctionHouseButton.buttons[index-1], 'BOTTOMLEFT', 0, -2)

        btn.isPet= tab.isPet
        btn:SetItemLocation(tab.itemLocation)
        btn:SetItemButtonCount(tab.count)

        btn.isCommoditiesTexture:SetShown(
            (tab.status==Enum.ItemCommodityStatus.Item and isItemSellFrame)
            or (tab.status==Enum.ItemCommodityStatus.Commodity and isCommoditiesSellFrame)
        )

        btn:SetShown(true)
        btn:set_alpha()
        index= index+1
    end

    for i= Save().numButton+1, index-1, Save().numButton  do
        local btn= AuctionHouseButton.buttons[i]
        btn:ClearAllPoints()
        btn:SetPoint('LEFT', AuctionHouseButton.buttons[i-Save().numButton], 'RIGHT', 2, 0)
    end

    for i= index, #AuctionHouseButton.buttons do
        local btn= AuctionHouseButton.buttons[i]
        if btn then
            btn:SetShown(false)
        end
    end

    AuctionHouseButton.Text:SetText(
        select(4, WoWTools_ItemMixin:GetColor(Save().sellItemQualiy))
        ..(index-1)
        )
end

































local function Init_AuctionHouseButton()

    AuctionHouseButton:SetPoint('TOPLEFT', AuctionHouseFrame, 'TOPRIGHT',4,0)
    AuctionHouseButton.frame= CreateFrame('Frame', nil, AuctionHouseButton)
    AuctionHouseButton.frame:SetSize(1,1)
    AuctionHouseButton.frame:SetPoint('BOTTOMLEFT')
    AuctionHouseButton.Text= WoWTools_LabelMixin:Create(AuctionHouseButton)
    AuctionHouseButton.Text:SetPoint('CENTER')
    AuctionHouseButton.buttons={}




    --按钮
    function AuctionHouseButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_AuctionHouseMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.left)
    end

    function AuctionHouseButton:Settings()
        self.frame:SetScale(Save().scaleSellButton or 1)
        local hide= Save().hideSellItemList
        self.frame:SetShown(not hide)
        if hide then
            self.Text:SetText('|cff828282'..(e.onlyChinese and '隐藏' or HIDE))
        end
    end
    AuctionHouseButton:Settings()


    AuctionHouseButton:SetScript('OnLeave', GameTooltip_Hide)
    AuctionHouseButton:SetScript('OnEnter', AuctionHouseButton.set_tooltips)
    AuctionHouseButton:SetScript('OnEvent', function()
        C_Timer.After(0.3, Init_Item_Button)
    end)

--菜单
    WoWTools_AuctionHouseMixin:Sell_Setup_Menu(AuctionHouseButton)

    function AuctionHouseButton:Init_Item_Button()
        Init_Item_Button()
    end


















--转到出售
    function AuctionHouseButton:show_CommoditiesSellFrame()
        local isCommoditiesSellFrame= WoWTools_AuctionHouseMixin:GetDisplayMode()
        if not isCommoditiesSellFrame then
           AuctionHouseFrame:SetDisplayMode(AuctionHouseFrameDisplayMode.CommoditiesSell)
        end
    end
--当页面是 出售 时，显示按钮
    function AuctionHouseButton:set_shown()
        local isCommoditiesSellFrame, isItemSellFrame= WoWTools_AuctionHouseMixin:GetDisplayMode()
        self:SetShown(AuctionHouseFrame:IsShown() and (isCommoditiesSellFrame or isItemSellFrame))
    end
--设置事件
    function AuctionHouseButton:set_event()
        if self:IsShown() then
            self:RegisterEvent('BAG_UPDATE_DELAYED')
        else
            self:UnregisterEvent('BAG_UPDATE_DELAYED')
        end
    end
--事件
    hooksecurefunc(AuctionHouseFrame, 'SetDisplayMode', function(self, displayMode)
        if not displayMode or not self:IsShown() then
            return
        end
        if displayMode[1]== "ItemSellFrame" or displayMode[1]=='CommoditiesSellFrame' then
            Init_Item_Button()
		end
        AuctionHouseButton:set_shown()
        AuctionHouseButton:set_event()
    end)
    AuctionHouseFrame:HookScript('OnHide', function()
        AuctionHouseButton:set_event()
    end)








--记录，用户，输入，价格
    function AuctionHouseButton:save_item_price(frame)
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
    AuctionHouseFrame.CommoditiesSellFrame.PriceInput.MoneyInputFrame.GoldBox:HookScript('OnTextChanged', function(_, userInput)
        if userInput then
            AuctionHouseButton:save_item_price(AuctionHouseFrame.CommoditiesSellFrame)
        end
    end)
    AuctionHouseFrame.ItemSellFrame.PriceInput.MoneyInputFrame.GoldBox:HookScript('OnTextChanged', function(_, userInput)
        if userInput then
            AuctionHouseButton:save_item_price(AuctionHouseFrame.ItemSellFrame)
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
    MaxSellItemCheck:SetFrameLevel(levelFrame)
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
    MaxSellItemCheck2:SetFrameLevel(levelFrame)
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

--提示，已放入物品
    function AuctionHouseButton:set_select_tips()
        local itemLocation= AuctionHouseFrame.CommoditiesSellFrame:GetItem() or AuctionHouseFrame.ItemSellFrame:GetItem()
        local itemID= itemLocation and C_Item.GetItemID(itemLocation)
        for _, btn in pairs(self.buttons) do
            if not itemID then
                btn.selectTexture:SetShown(false)
            elseif btn.itemLocation and btn.itemLocation:IsValid() then
                btn.selectTexture:SetShown(C_Item.GetItemID(btn.itemLocation)==itemID)
            end
        end
    end

    hooksecurefunc(AuctionHouseFrame.CommoditiesSellFrame, 'SetItem', function(self)
        C_Timer.After(0.3, function()
            AuctionHouseButton:set_select_tips()--提示，已放入物品
            if Save().isMaxSellItem and self.QuantityInput.MaxButton:IsEnabled() then
                self:SetToMaxQuantity()--出售物品时，使用，最大数量
            end
        end)

    end)
    hooksecurefunc(AuctionHouseFrame.ItemSellFrame, 'SetItem', function(self)
        C_Timer.After(0.3, function()
            AuctionHouseButton:set_select_tips()--提示，已放入物品
            if Save().isMaxSellItem and self.QuantityInput.MaxButton:IsEnabled() then
                self:SetToMaxQuantity()--出售物品时，使用，最大数量
            end
        end)

    end)
end



















--显示拍卖行时，转到出售物品
local function OnShowToSellFrame()
    if not Save().intShowSellItem then
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








--默认价格，替换，原生func Blizzard_AuctionHouseSellFrame.lua
local function Init_SetDefaultPrice()
    function AuctionHouseButton:GetDefaultPrice(itemLocation)
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
    function AuctionHouseFrame.CommoditiesSellFrame:GetDefaultPrice()
        return AuctionHouseButton:GetDefaultPrice(self:GetItem())
    end
    function AuctionHouseFrame.ItemSellFrame:GetDefaultPrice()
        return AuctionHouseButton:GetDefaultPrice(self:GetItem())
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

    function AuctionHouseButton:Update_Total_Price(frame)
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
                        Init_Item_Button()
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
    hooksecurefunc(AuctionHouseFrame.CommoditiesSellFrame, 'UpdateTotalPrice', function(self)
        AuctionHouseButton:Update_Total_Price(self)
    end)
    hooksecurefunc(AuctionHouseFrame.ItemSellFrame, 'UpdateTotalPrice', function(self)
        AuctionHouseButton:Update_Total_Price(self)
    end)
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
    local showCommoditiesButton=WoWTools_ButtonMixin:Cbtn(AuctionHouseFrame.ItemSellFrame, {type=false, size={100,22}, text=e.onlyChinese and '物品' or ITEMS})
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
    local showSellButton=WoWTools_ButtonMixin:Cbtn(AuctionHouseFrame.CommoditiesSellFrame, {type=false, size={100,22}, text=e.onlyChinese and '材料' or PROFESSIONS_COLUMN_HEADER_REAGENTS})
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
    local cancelButton2= WoWTools_ButtonMixin:Cbtn(AuctionHouseFrame.ItemSellFrame.PostButton, {size={32,32}, texture='Interface\\Buttons\\CancelButton-Up'})
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




















local function Init()
    levelFrame= AuctionHouseFrame.CommoditiesSellFrame.QuantityInput.MaxButton:GetFrameLevel()

    AuctionHouseButton= WoWTools_ButtonMixin:CreateMenu(AuctionHouseFrame, {
        --button='DropdownButton',
        size=23,
        hideIcon=true,
        name='WoWToolsAuctionHouseSellListButton'
    })

    Init_AuctionHouseButton()


    Init_MaxSellItemCheck()--出售物品时，使用，最大数量
    --Init_ShowSellItemCheck()--显示拍卖行时，转到出售物品
    Init_SetDefaultPrice()--默认价格，替换，原生func
    Init_PercentLabel()--单价，倍数
    Init_NextItem()--下一个，拍卖，物品   
    Init_ShowCommoditiesButton()--转到，商品，模式，按钮

--显示拍卖行时，转到出售物品
    AuctionHouseFrame:HookScript('OnShow', OnShowToSellFrame)
    --OnShowToSellFrame()

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
    --AuctionHouseFrame.CommoditiesSellList.RefreshFrame.TotalQuantity:SetPoint('TOP', AuctionHouseFrame.CommoditiesSellFrame.PostButton, 'BOTTOM', 0, -2)    

    AuctionHouseFrame.ItemSellList.RefreshFrame.TotalQuantity:ClearAllPoints()
    AuctionHouseFrame.ItemSellList.RefreshFrame.TotalQuantity:SetPoint('BOTTOMRIGHT', AuctionHouseFrame.ItemSellList, 'TOPRIGHT', -25, 0)
    --AuctionHouseFrame.ItemSellList.RefreshFrame.TotalQuantity:SetPoint('TOP', AuctionHouseFrame.ItemSellFrame.PostButton, 'BOTTOM', 0, -2)
end











function WoWTools_AuctionHouseMixin:Init_Sell()
    Init()
end
