local id, e = ...
local addName= BUTTON_LAG_AUCTIONHOUSE--拍卖行
local Save={
    --出售
    --hideSellItemList=true,--隐藏，物品列表
    numButton=15,--行数
    scaleSellButton=0.95,--综合
    
    intShowSellItem= e.Player.husandro,--显示，转到出售物品
    isMaxSellItem= true,--出售物品时，使用，最大数量
    hideSellItem={},--跳过，拍卖行物品
    SellItemDefaultPrice={},--默认价格
    
    --拍卖，列表


}















--拍卖行
local AuctionHouseButton
local function Init_Sell()
    local levelFrame= AuctionHouseFrame.CommoditiesSellFrame.QuantityInput.MaxButton:GetFrameLevel()

    AuctionHouseButton= e.Cbtn(AuctionHouseFrame, {size={34, 34}, icon='hide'})
    AuctionHouseButton:SetPoint('TOPLEFT', AuctionHouseFrame, 'TOPRIGHT',0,10)
    AuctionHouseButton.frame= CreateFrame('Frame', nil, AuctionHouseButton)
    AuctionHouseButton.frame:SetAllPoints(AuctionHouseButton)
    AuctionHouseButton.Text= e.Cstr(AuctionHouseButton)
    AuctionHouseButton.Text:SetPoint('CENTER')
    AuctionHouseButton.buttons={}




    --按钮
    function AuctionHouseButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.GetShowHide(nil, true), e.GetShowHide(not Save.hideSellItemList)..e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.scaleSellButton or 1), 'Alt+'..e.Icon.mid)
        e.tips:AddDoubleLine((e.onlyChinese and '行数' or HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ROWS)..' |cnGREEN_FONT_COLOR:'..(Save.numButton or 15), 'Shift+'..e.Icon.mid)
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

    function AuctionHouseButton:set_scale()
        self.frame:SetScale(Save.scaleSellButton or 1)
    end
    AuctionHouseButton:SetScript('OnMouseWheel', function(self, d)
        if IsShiftKeyDown() then
            local n=Save.numButton
            n= d==1 and n+1 or n-1
            n= n>40 and 40 or n
            n= n<1 and 1 or n
            Save.numButton= n
            self:init_items()

        elseif IsAltKeyDown() then
            local n= Save.scaleSellButton or 1
            n= d==1 and n-0.05 or n+0.05
            n= n>2 and 2 or n
            n= n<0.4 and 0.4 or n
            Save.scaleSellButton=n
            self:set_scale()
        end
        self:set_tooltips()
    end)
    AuctionHouseButton:set_scale()









    function AuctionHouseButton:get_displayMode()
        local displayMode= AuctionHouseFrame:GetDisplayMode() or {}
        return displayMode[1]=='CommoditiesSellFrame', displayMode[1]=='ItemSellFrame'
    end


    function AuctionHouseButton:get_itemLocation(bag, slot)
        local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot);
        if itemLocation and itemLocation:IsValid() and C_AuctionHouse.IsSellItemValid(itemLocation, false) then--ContainerFrame.lua
            return itemLocation, C_AuctionHouse.GetItemCommodityStatus(itemLocation) or 0
        end
    end


    function AuctionHouseButton:set_next_item()--放入，第一个，物品
        local isCommoditiesSellFrame, isItemSellFrame= self:get_displayMode()
        if not C_AuctionHouse.IsThrottledMessageSystemReady()
            or (isCommoditiesSellFrame and AuctionHouseFrame.CommoditiesSellFrame:GetItem())
            or (isItemSellFrame and AuctionHouseFrame.ItemSellFrame:GetItem())
        then
            return
        end
        for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES do--Constants.InventoryConstants.NumBagSlots
            for slot=1, C_Container.GetContainerNumSlots(bag) do
                local info = C_Container.GetContainerItemInfo(bag, slot)
                local itemLocation, itemCommodityStatus= self:get_itemLocation(bag, slot)
                if info
                    and itemLocation
                    and itemCommodityStatus>0
                    and info.itemID
                    and not Save.hideSellItem[info.itemID]
                    and (
                        (itemCommodityStatus==Enum.ItemCommodityStatus.Commodity and isCommoditiesSellFrame)
                        or (itemCommodityStatus==Enum.ItemCommodityStatus.Item and isItemSellFrame)
                    )
                then
                    AuctionHouseFrame:SetPostItem(itemLocation)--ContainerFrame.lua
                    return
                end
            end
        end
    end



    function AuctionHouseButton:init_items()
        local index=1
        if not Save.hideSellItemList then
            local isCommoditiesSellFrame, isItemSellFrame= self:get_displayMode()
            for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES do--Constants.InventoryConstants.NumBagSlots
                for slot=1, C_Container.GetContainerNumSlots(bag) do
                    local info = C_Container.GetContainerItemInfo(bag, slot)
                    local itemLocation, itemCommodityStatus= self:get_itemLocation(bag, slot)
                    if info and info.hyperlink and itemLocation and itemCommodityStatus>0 then
                        local btn= self.buttons[index]
                        if not btn then
                            btn= e.Cbtn(self.frame, {button='ItemButton', icon='hide'})
                            btn.selectTexture= btn:CreateTexture(nil, 'OVERLAY')
                            btn.selectTexture:SetAtlas('Forge-ColorSwatchSelection')
                            btn.selectTexture:SetPoint('CENTER')
                            btn.selectTexture:SetSize(42, 42)
                            btn.selectTexture:Hide()

                            btn.isCommoditiesTexture= btn:CreateTexture(nil, 'OVERLAY')
                            btn.isCommoditiesTexture:SetAtlas('AnimaChannel-Bar-Necrolord-Gem')--common-icon-checkmark')
                            btn.isCommoditiesTexture:SetPoint('TOPRIGHT')
                            btn.isCommoditiesTexture:SetSize(16, 16)
                            btn.isCommoditiesTexture:Hide()


                            
                            btn:UpdateItemContextOverlayTextures(1)
                            btn:SetScript('OnLeave', GameTooltip_Hide)

                            btn:SetScript('OnEnter', function(frame)
                                e.tips:SetOwner(frame:GetParent(), "ANCHOR_LEFT")
                                e.tips:ClearLines()
                                local itemLink= C_Item.GetItemLink(frame.itemLocation)
                                if itemLink then
                                    if frame.isPet then
                                        BattlePetToolTip_Show(BattlePetToolTip_UnpackBattlePetLink(itemLink))
                                    else
                                        e.tips:SetHyperlink(itemLink)
                                        e.tips:AddLine(' ')
                                        e.tips:AddDoubleLine(e.onlyChinese and '开始拍卖' or CREATE_AUCTION, e.Icon.left)
                                    end
                                end
                                local itemID= C_Item.GetItemID(frame.itemLocation)
                                if itemID then
                                    e.tips:AddDoubleLine(e.GetShowHide(nil, true), e.GetShowHide(Save.hideSellItem[itemID])..e.Icon.right)
                                end
                                e.tips:Show()
                            end)
                            btn:SetScript('OnClick', function(frame, d)
                                if d=='LeftButton' then--放入，物品
                                    if AuctionHouseMultisellProgressFrame:IsShown() then
                                        C_AuctionHouse.CancelSell()
                                    end
                                    AuctionHouseFrame:SetPostItem(frame.itemLocation)--ContainerFrame.lua

                                elseif d=='RightButton' then--隐藏，物品
                                    local itemID= C_Item.GetItemID(frame.itemLocation)
                                    if itemID then
                                        Save.hideSellItem[itemID]= not Save.hideSellItem[itemID] and true or nil
                                        frame:GetParent():GetParent():init_items()
                                    end
                                end
                            end)
                            self.buttons[index]= btn
                        end
                        btn:ClearAllPoints()
                        btn:SetPoint("TOP", index==1 and self or self.buttons[index-1], 'BOTTOM', 0, -2)

                        btn.isPet= info.hyperlink:find('Hbattlepet:(%d+)')
                        btn:SetItemLocation(itemLocation)
                        btn:SetItemButtonCount(info.stackCount)
                        btn:SetAlpha(Save.hideSellItem[info.itemID] and 0.3 or 1)
                        btn.isCommoditiesTexture:SetShown(
                                (itemCommodityStatus==Enum.ItemCommodityStatus.Item and isItemSellFrame)
                            or (itemCommodityStatus==Enum.ItemCommodityStatus.Commodity and isCommoditiesSellFrame)
                        )

                        btn:SetShown(true)
                        index= index +1
                    end
                end
            end
            for i= Save.numButton+1, index-1, Save.numButton  do
                local btn= self.buttons[i]
                btn:ClearAllPoints()
                btn:SetPoint('LEFT', self.buttons[i-Save.numButton], 'RIGHT', 2, 0)
            end
        end
        for i= index, #self.buttons do
            local btn= self.buttons[i]
            if btn then
                btn.isCommodities=nil
                btn.isPet=nil
                --btn.itemCommodityStatus= nil
                btn:Reset()
                btn:SetShown(false)
            end
        end

        self.Text:SetText(Save.hideSellItemList and '|cff606060'..(e.onlyChinese and '隐藏' or HIDE) or index-1)
    end


    --提示，已放入物品
    function AuctionHouseButton:set_select_tips(frame)
        local itemLocation= frame:GetItem()
        local itemID= itemLocation and C_Item.GetItemID(itemLocation)
        for _, btn in pairs(self.buttons) do
            if not itemID then
                btn.selectTexture:SetShown(false)
            elseif btn.itemLocation and btn.itemLocation:IsValid() then
                btn.selectTexture:SetShown(C_Item.GetItemID(btn.itemLocation)==itemID)
            end
        end
    end
    hooksecurefunc(AuctionHouseFrame.CommoditiesSellFrame, 'SetItem', function(self) AuctionHouseButton:set_select_tips(self) end)
    hooksecurefunc(AuctionHouseFrame.ItemSellFrame, 'SetItem', function(self) AuctionHouseButton:set_select_tips(self) end)




































    
    function AuctionHouseButton:show_CommoditiesSellFrame()
        local isCommoditiesSellFrame= self:get_displayMode()
        if not isCommoditiesSellFrame then
           AuctionHouseFrame:SetDisplayMode(AuctionHouseFrameDisplayMode.CommoditiesSell)
        end
    end

    function AuctionHouseButton:set_shown()
        local isCommoditiesSellFrame, isItemSellFrame= self:get_displayMode()
        self:SetShown(AuctionHouseFrame:IsShown() and (isCommoditiesSellFrame or isItemSellFrame))
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
        if displayMode[1]== "ItemSellFrame" or displayMode[1]=='CommoditiesSellFrame' then
            AuctionHouseButton:init_items()
		end
        AuctionHouseButton:set_shown()
        AuctionHouseButton:set_event()
    end)
    AuctionHouseFrame:HookScript('OnHide', function()
        AuctionHouseButton:set_event()
    end)

























    --Blizzard_AuctionHouseSellFrame.lua
    --出售物品时，使用，最大数量
    AuctionHouseFrame.maxSellItemCheck= CreateFrame('CheckButton', nil, AuctionHouseFrame.CommoditiesSellFrame.QuantityInput.MaxButton, 'InterfaceOptionsCheckButtonTemplate')
    AuctionHouseFrame.maxSellItemCheck:SetPoint('LEFT', AuctionHouseFrame.CommoditiesSellFrame.QuantityInput.MaxButton, 'RIGHT')
    AuctionHouseFrame.maxSellItemCheck:SetSize(24,24)
    AuctionHouseFrame.maxSellItemCheck:SetChecked(Save.isMaxSellItem)
    AuctionHouseFrame.maxSellItemCheck:SetFrameLevel(levelFrame)
    AuctionHouseFrame.maxSellItemCheck:SetScript('OnLeave', GameTooltip_Hide)
    AuctionHouseFrame.maxSellItemCheck:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(' ', e.onlyChinese and '最大数量' or AUCTION_HOUSE_MAX_QUANTITY_BUTTON)
        e.tips:Show()
    end)
    AuctionHouseFrame.maxSellItemCheck:SetScript('OnClick', function()
        Save.isMaxSellItem= not Save.isMaxSellItem and true or nil
        AuctionHouseFrame.maxSellItemCheck2:SetChecked(Save.isMaxSellItem)
    end)


    AuctionHouseFrame.maxSellItemCheck2= CreateFrame('CheckButton', nil, AuctionHouseFrame.ItemSellFrame.QuantityInput.MaxButton, 'InterfaceOptionsCheckButtonTemplate')
    AuctionHouseFrame.maxSellItemCheck2:SetPoint('LEFT', AuctionHouseFrame.ItemSellFrame.QuantityInput.MaxButton, 'RIGHT')
    AuctionHouseFrame.maxSellItemCheck2:SetSize(24,24)
    AuctionHouseFrame.maxSellItemCheck2:SetChecked(Save.isMaxSellItem)
    AuctionHouseFrame.maxSellItemCheck2:SetFrameLevel(levelFrame)
    AuctionHouseFrame.maxSellItemCheck2:SetScript('OnLeave', GameTooltip_Hide)
    AuctionHouseFrame.maxSellItemCheck2:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(' ', e.onlyChinese and '最大数量' or AUCTION_HOUSE_MAX_QUANTITY_BUTTON)
        e.tips:Show()
    end)
    AuctionHouseFrame.maxSellItemCheck2:SetScript('OnClick', function(self)
        Save.isMaxSellItem= not Save.isMaxSellItem and true or nil
        AuctionHouseFrame.maxSellItemCheck:SetChecked(Save.isMaxSellItem)
    end)

    hooksecurefunc(AuctionHouseFrame.ItemSellFrame, 'SetItem', function(self)
        if Save.isMaxSellItem and self.QuantityInput.MaxButton:IsEnabled() then
            self:SetToMaxQuantity()
        end
    end)


























    --显示，转到出售物品
    local showSellItemCheck= CreateFrame('CheckButton', nil, AuctionHouseFrame.CommoditiesSellFrame, 'InterfaceOptionsCheckButtonTemplate')
    showSellItemCheck:SetPoint('BOTTOMLEFT', AuctionHouseFrame.CommoditiesSellFrame, 8, 8)
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
            C_Timer.After(0.5, function() AuctionHouseButton:set_next_item() end)--放入，第一个，物品
        end
    end)






























    --默认价格，替换，原生func
    --Blizzard_AuctionHouseSellFrame.lua
    function AuctionHouseButton:GetDefaultPrice(itemLocation)
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

























    --单价，倍数
    AuctionHouseFrame.CommoditiesSellFrame.percentLabel= e.Cstr(AuctionHouseFrame.CommoditiesSellFrame, {size=16})--单价，提示
    AuctionHouseFrame.CommoditiesSellFrame.percentLabel:SetPoint('BOTTOM', AuctionHouseFrame.CommoditiesSellFrame.PostButton, 'TOP')
    AuctionHouseFrame.CommoditiesSellFrame.vendorPriceLabel= e.Cstr(AuctionHouseFrame.CommoditiesSellFrame, {size=12})--单价，提示
    AuctionHouseFrame.CommoditiesSellFrame.vendorPriceLabel:SetPoint('TOPRIGHT', AuctionHouseFrame.CommoditiesSellFrame.PriceInput.MoneyInputFrame.GoldBox, 'BOTTOMRIGHT',0,4)

    AuctionHouseFrame.ItemSellFrame.percentLabel= e.Cstr(AuctionHouseFrame.ItemSellFrame, {size=16})--单价，提示
    AuctionHouseFrame.ItemSellFrame.percentLabel:SetPoint('BOTTOM', AuctionHouseFrame.ItemSellFrame.PostButton, 'TOP')
    AuctionHouseFrame.ItemSellFrame.vendorPriceLabel= e.Cstr(AuctionHouseFrame.ItemSellFrame, {size=12})--单价，提示
    AuctionHouseFrame.ItemSellFrame.vendorPriceLabel:SetPoint('TOPRIGHT', AuctionHouseFrame.ItemSellFrame.PriceInput.MoneyInputFrame.GoldBox, 'BOTTOMRIGHT',0,4)

    function AuctionHouseButton:Update_Total_Price(frame)
        local itemLocation= frame:GetItem()
        local text=''
        local text2=''
        if itemLocation and itemLocation:IsValid() then
            local itemLink = C_Item.GetItemLink(itemLocation);
            local vendorPrice = select(11, GetItemInfo(itemLink));
            local unitPrice= frame.GetUnitPrice and frame:GetUnitPrice() or frame.PriceInput:GetAmount();-- frame:GetUnitPrice()
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
                text2= col..GetMoneyString(vendorPrice)--GetCoinTextureString(vendorPrice)
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



























    --下一个，拍卖，物品
    --AuctionHouseFrame.CommoditiesSellFrame.PostButton:HookScript('OnClick', function(self)
    hooksecurefunc(AuctionHouseFrame.CommoditiesSellFrame, 'PostItem', function(self)
        self.isNextItem=true
    end)
    hooksecurefunc(AuctionHouseFrame.CommoditiesSellFrame, 'UpdatePostButtonState', function(self)

        if self:GetItem()
            or not C_AuctionHouse.IsThrottledMessageSystemReady()
            or not self.isNextItem
            or AuctionHouseMultisellProgressFrame:IsShown()
        then
            return
        end
        C_Timer.After(0.3, function() AuctionHouseButton:set_next_item() end)--放入，第一个，物品
        self.isNextItem=nil
    end)
    hooksecurefunc(AuctionHouseFrame.ItemSellFrame, 'PostItem', function(self)
        self.isNextItem=true
    end)
    hooksecurefunc(AuctionHouseFrame.ItemSellFrame, 'UpdatePostButtonState', function(self)

        if self:GetItem()
            or not C_AuctionHouse.IsThrottledMessageSystemReady()
            or not self.isNextItem
            or AuctionHouseMultisellProgressFrame:IsShown()
        then
            return
        end
        C_Timer.After(0.3, function() AuctionHouseButton:set_next_item() end)--放入，第一个，物品
        self.isNextItem=nil
    end)

















    --转到，商品，模式，按钮
    local showCommoditiesButton=e.Cbtn(AuctionHouseFrame.ItemSellFrame, {type=false, size={100,22}, text=e.onlyChinese and '物品' or ITEMS})
    showCommoditiesButton:SetPoint('BOTTOMRIGHT', -15,15)
    showCommoditiesButton:SetFrameLevel(levelFrame)
    showCommoditiesButton:SetScript('OnLeave', GameTooltip_Hide)
    showCommoditiesButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT");
        e.tips:ClearLines();
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '显示模式' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, MODE), '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '转到' or CONVERT)..'|r '..(e.onlyChinese and '材料' or PROFESSIONS_COLUMN_HEADER_REAGENTS))
        e.tips:Show();
    end)
    showCommoditiesButton:SetScript('OnClick', function()
        AuctionHouseFrame.ItemSellFrame:ClearPost()
        if AuctionHouseFrame.ItemSellFrame.multisellInProgress then
            C_AuctionHouse.CancelSell()
        end
        AuctionHouseFrame:SetDisplayMode(AuctionHouseFrameDisplayMode.CommoditiesSell)
        C_Timer.After(0.3, function() AuctionHouseButton:set_next_item() end)--放入，第一个，物品
    end)


    --转到，出售商品，按钮
    local showSellButton=e.Cbtn(AuctionHouseFrame.CommoditiesSellFrame, {type=false, size={100,22}, text=e.onlyChinese and '材料' or PROFESSIONS_COLUMN_HEADER_REAGENTS})
    showSellButton:SetPoint('BOTTOMRIGHT',  -15,15)
    showSellButton:SetFrameLevel(levelFrame)
    showSellButton:SetScript('OnLeave', GameTooltip_Hide)
    showSellButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT");
        e.tips:ClearLines();
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '显示' or SHOW, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '转到' or CONVERT)..'|r '..(e.onlyChinese and '物品' or ITEMS))
        
        e.tips:Show();
    end)
    showSellButton:SetScript('OnClick', function()
        AuctionHouseFrame.CommoditiesSellFrame:ClearPost()
        AuctionHouseFrame:SetDisplayMode(AuctionHouseFrameDisplayMode.ItemSell)
        C_Timer.After(0.3, function() AuctionHouseButton:set_next_item() end)--放入，第一个，物品
    end)


--[[
    <Button parentKey="CancelButton">
    <Size x="32" y="32"/>
    <Anchors>
        <Anchor point="LEFT" relativeKey="$parent.ProgressBar" relativePoint="RIGHT" x="2" y="-7"/>
    </Anchors>
    <HitRectInsets left="9" right="7" top="-7" bottom="10"/>
    <Scripts>
        <OnClick>
            C_AuctionHouse.CancelSell();
        </OnClick>
    </Scripts>
    <NormalTexture file="Interface\Buttons\CancelButton-Up"/>
    <PushedTexture file="Interface\Buttons\CancelButton-Down"/>
    <HighlightTexture file="Interface\Buttons\CancelButton-Highlight" alphaMode="ADD"/>
</Button>
]]










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
    AuctionHouseFrame.CommoditiesSellList.RefreshFrame.RefreshButton:SetPoint('LEFT', AuctionHouseFrame.CommoditiesSellFrame.PostButton, 'RIGHT', 4, 0)




    AuctionHouseFrame.ItemSellList:ClearAllPoints()
    AuctionHouseFrame.ItemSellList:SetSize(427, 442)
    AuctionHouseFrame.ItemSellList:SetPoint('BOTTOMLEFT', AuctionHouseFrame.MoneyFrameBorder, 'TOPLEFT')
    AuctionHouseFrame.ItemSellFrame:ClearAllPoints()
    AuctionHouseFrame.ItemSellFrame:SetSize(363, 442)
    AuctionHouseFrame.ItemSellFrame:SetPoint('TOPLEFT', AuctionHouseFrame.ItemSellList, 'TOPRIGHT')
    --刷新，列表
    AuctionHouseFrame.ItemSellList.RefreshFrame.RefreshButton:ClearAllPoints()
    AuctionHouseFrame.ItemSellList.RefreshFrame.RefreshButton:SetParent(AuctionHouseFrame.ItemSellFrame.PostButton)
    AuctionHouseFrame.ItemSellList.RefreshFrame.RefreshButton:SetPoint('LEFT', AuctionHouseFrame.ItemSellFrame.PostButton, 'RIGHT', 4, 0)

    AuctionHouseMultisellProgressFrame:HookScript('OnShow', function(self)
        local isCommoditiesSellFrame, isItemSellFrame= AuctionHouseButton:get_displayMode()
        print(isCommoditiesSellFrame, isItemSellFrame)
        if isCommoditiesSellFrame then
            self:ClearAllPoints()
            self:SetPoint('BOTTOM', AuctionHouseFrame.CommoditiesSellFrame.PostButton, 'TOP')
        elseif isItemSellFrame then
            self:ClearAllPoints()
            self:SetPoint('BOTTOM', AuctionHouseFrame.ItemSellFrame.PostButton, 'TOP')
        end
    end)
    AuctionHouseMultisellProgressFrame:ClearAllPoints()
    AuctionHouseMultisellProgressFrame:SetPoint('BOTTOMRIGHT', AuctionHouseFrame, 'BOTTOMRIGHT', -8,0)
end



































































--所有，出售物品, 表表
local function Init_AllAuctions()
    --移动，刷新，按钮
    AuctionHouseFrameAuctionsFrame.AllAuctionsList.RefreshFrame.RefreshButton:ClearAllPoints()
    AuctionHouseFrameAuctionsFrame.AllAuctionsList.RefreshFrame.RefreshButton:SetPoint('RIGHT', AuctionHouseFrameAuctionsFrame.CancelAuctionButton, 'LEFT', -4, 0)

    --取消
    local cancelButton= e.Cbtn(AuctionHouseFrameAuctionsFrame.CancelAuctionButton, {type=false, size={100,22}, text= e.onlyChinese and '取消' or CANCEL})
    cancelButton:SetPoint('RIGHT', AuctionHouseFrameAuctionsFrame.AllAuctionsList.RefreshFrame.RefreshButton, 'LEFT', -4, 0)
    function cancelButton:get_auctionID()
        local tab={}
        for _, info in pairs(AuctionHouseFrameAuctionsFrame.AllAuctionsList.ScrollBox:GetFrames() or {}) do
            if info.rowData and info.rowData.auctionID and info.rowData.timeLeftSeconds and C_AuctionHouse.CanCancelAuction(info.rowData.auctionID) then
                table.insert(tab, info.rowData)
            end
        end
        table.sort(tab, function(a, b)
            return a.timeLeftSeconds< b.timeLeftSeconds
        end)
        if tab[1] and tab[1].auctionID then
            local auctionID= tab[1].auctionID
            local itemLink= tab[1].itemLink
            if not itemLink then
                local priceInfo = C_AuctionHouse.GetAuctionInfoByID(auctionID) or {}
                itemLink= priceInfo.itemLink
            end
            return auctionID, itemLink
        end
    end
    function cancelButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        e.tips:ClearLines()
        local itemLink= select(2, self:get_auctionID())
        if itemLink then
            e.tips:SetHyperlink(itemLink)
            e.tips:AddLine(' ')
        end
        e.tips:AddDoubleLine(' ', '|cnRED_FONT_COLOR:'..(e.onlyChinese and '取消拍卖将使你失去保证金。' or CANCEL_AUCTION_CONFIRMATION))
        e.tips:AddDoubleLine(e.onlyChinese and '备注' or 'Note', '|cnRED_FONT_COLOR:'..(e.onlyChinese and '请不要太快' or ERR_GENERIC_THROTTLE))
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
    end
    cancelButton:SetScript('OnLeave', GameTooltip_Hide)
    cancelButton:SetScript('OnEnter', cancelButton.set_tooltips)
    cancelButton:SetScript('OnClick', function(self)
        local auctionID, itemLink= self:get_auctionID()
        if auctionID  then
            if C_AuctionHouse.CanCancelAuction(auctionID) then
                local cost= C_AuctionHouse.GetCancelCost(auctionID)
                C_AuctionHouse.CancelAuction(auctionID)
                print(id,addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '取消' or CANCEL)..'|r', itemLink or '', cost and cost>0 and '|cnRED_FONT_COLOR:'..GetMoneyString(cost) or '')
            else
                print(id,addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '出错' or ERRORS)..'|r', itemLink or '')
            end

            --AuctionHouseFrame.AuctionsFrame:SetDataProviderIndexRange(C_AuctionHouse.GetNumOwnedAuctionTypes(), ScrollBoxConstants.RetainScrollPosition);
            AuctionHouseFrameAuctionsFrame.AllAuctionsList.RefreshFrame.RefreshButton:OnClick()
        end
        self:set_tooltips()
    end)


    --[[取消
    local cancelAllButton= e.Cbtn(cancelButton, {type=false, size={100,22}, text= e.onlyChinese and '全部' or ALL})
    cancelAllButton:SetPoint('RIGHT', cancelButton, 'LEFT', -4, 0)
    cancelAllButton:SetScript('OnLeave', GameTooltip_Hide)
    cancelAllButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(' ', '|cnRED_FONT_COLOR:'..(e.onlyChinese and '取消拍卖将使你失去保证金。' or CANCEL_AUCTION_CONFIRMATION))
        e.tips:Show()
    end)
    function cancelAllButton:set_text()
        if self.time and not self.time:IsCancelled() then
            self:SetText(e.onlyChinese and '中断' or INTERRUPT)
        else
            self:SetText(e.onlyChinese and '全部' or ALL)
        end
    end
    cancelAllButton:SetScript('OnClick', function(self)
        if self.time and not self.time:IsCancelled() then
            self.time:Cancel()
            self:set_text()
            return
        end



        local tab={}
        local num=0
        for _, info in pairs(AuctionHouseFrameAuctionsFrame.AllAuctionsList.ScrollBox:GetFrames() or {}) do
            if info.rowData and info.rowData.auctionID and info.rowData.timeLeftSeconds and C_AuctionHouse.CanCancelAuction(info.rowData.auctionID) then
                table.insert(tab, info.rowData)
                num= num+1
            end
        end
        if num==0 then
            return
        end

        table.sort(tab, function(a, b)
            return a.timeLeftSeconds< b.timeLeftSeconds
        end)

        local function AllAuctionsRefreshResults()
            AuctionHouseFrameAuctionsFrame:GetAuctionHouseFrame():QueryAll(AuctionHouseSearchContext.AllAuctions);
            AuctionHouseFrameAuctionsFrame.AllAuctionsList:DirtyScrollFrame();
        end

        if C_AuctionHouse.CanCancelAuction(tab[1].auctionID) then
            local cost= C_AuctionHouse.GetCancelCost(tab[1].auctionID)
            C_AuctionHouse.CancelAuction(tab[1].auctionID)
            print(id,addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '取消' or CANCEL)..'|r', '1/'..num, tab[1].itemLink, cost and cost>0 and '|cnRED_FONT_COLOR:'..GetMoneyString(cost) or '')
            AuctionHouseFrameAuctionsFrame.AllAuctionsList:SetRefreshFrameFunctions(nil, AllAuctionsRefreshResults)--Blizzard_AuctionHouseAuctionsFrame.lua
        end
        
  
        
        if num>1 then
            local index=1
            self.time= C_Timer.NewTicker(3, function()
                index= index+1
                local auctionID= tab[index].auctionID
                local itemLink= tab[index].itemLink
                if C_AuctionHouse.CanCancelAuction(auctionID) then
                    local cost= C_AuctionHouse.GetCancelCost(auctionID)
                    C_AuctionHouse.CancelAuction(auctionID)
                    print(id,addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '取消' or CANCEL)..'|r', index..'/'..num , itemLink, cost and cost>0 and '|cnRED_FONT_COLOR:'..GetMoneyString(cost) or '')
                end
                AuctionHouseFrameAuctionsFrame.AllAuctionsList:SetRefreshFrameFunctions(nil, AllAuctionsRefreshResults)--Blizzard_AuctionHouseAuctionsFrame.lua

                if num==index then
                    self.time:Cancel()
                end
            end, num)
        end
        
        self:set_text()
    end)]]


--[[
    if not self.OnDoubleClick then
        self:SetScript('OnDoubleClick', function(self2)--LFGListApplicationDialogSignUpButton_OnClick(button) LFG队长分数, 双击加入 LFGListSearchPanel_UpdateResults
            if not Save.LFGPlus then
                return
            end
            if LFGListFrame.SearchPanel.SignUpButton:IsEnabled() then
                LFGListFrame.SearchPanel.SignUpButton:Click()
            end
            local frame=LFGListApplicationDialog
            if not frame.TankButton.CheckButton:GetChecked() and not frame.HealerButton.CheckButton:GetChecked() and not frame.DamagerButton.CheckButton:GetChecked() then
                local specID=GetSpecialization()--当前专精
                if specID then
                    local role = select(5, GetSpecializationInfo(specID))
                    if role=='DAMAGER' and frame.DamagerButton:IsShown() then
                        frame.DamagerButton.CheckButton:SetChecked(true)

                    elseif role=='TANK' and frame.TankButton:IsShown() then
                        frame.TankButton.CheckButton:SetChecked(true)

                    elseif role=='HEALER' and frame.HealerButton:IsShown() then
                        frame.HealerButton.CheckButton:SetChecked(true)
                    end
                    LFGListApplicationDialog_UpdateValidState(frame)
                end
            end
            if frame:IsShown() and frame.SignUpButton:IsEnabled() then
                frame.SignUpButton:Click()
            end
        end)
    end]]
end





































--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板
            e.AddPanel_Check({
                name= '|A:Auctioneer:0:0|a'..(e.onlyChinese and '拍卖行' or addName),
                tooltip= addName,
                value= not Save.disabled,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                end
            })

            if Save.disabled then
                panel:UnregisterEvent('ADDON_LOADED')
            end

        elseif arg1=='Blizzard_AuctionHouseUI' then
            Init_Sell()
            Init_AllAuctions()
            panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)