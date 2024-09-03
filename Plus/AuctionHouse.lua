local id, e = ...
local addName= BUTTON_LAG_AUCTIONHOUSE--拍卖行
local Save={
    --出售
    --hideSellItemList=true,--隐藏，物品列表
    numButton=15,--行数
    scaleSellButton=0.95,--综合

    intShowSellItem= e.Player.husandro,--显示，转到出售物品
    isMaxSellItem= true,--出售物品时，使用，最大数量
    hideSellItem={
        [201469]=true,--翡翠青苹果
        [202071]=true,--元素微粒
        [192658]=true,--高纤维树叶
        [192615]=true,--幽光液体
    },--跳过，拍卖行物品
    SellItemDefaultPrice={},--默认价格

    --拍卖，列表


}





local function Get_ItemLink_For_rowData(rowData)
    if not rowData then
        return
    end
    local itemLink= rowData.itemLink
    local itemID, isPet
    itemID= rowData.itemID or (rowData and rowData.itemKey and rowData.itemKey.itemID)
    if not itemLink and rowData.auctionID then
        local priceInfo = C_AuctionHouse.GetAuctionInfoByID(rowData.auctionID) or {}
        itemLink= priceInfo.itemLink or priceInfo.battlePetLink
    end
    if not itemLink and itemID then
        itemLink= WoWTools_ItemMixin:GetLink(itemID)
    end
    isPet= rowData and rowData.itemKey and rowData.itemKey.battlePetSpeciesID and rowData.itemKey.battlePetSpeciesID>0
    return itemLink, itemID, isPet
end









--拍卖行
local AuctionHouseButton
local function Init_Sell()
    local levelFrame= AuctionHouseFrame.CommoditiesSellFrame.QuantityInput.MaxButton:GetFrameLevel()

    AuctionHouseButton= WoWTools_ButtonMixin:Cbtn(AuctionHouseFrame, {size={34, 34}, icon='hide'})
    AuctionHouseButton:SetPoint('TOPLEFT', AuctionHouseFrame, 'TOPRIGHT',4,10)
    AuctionHouseButton.frame= CreateFrame('Frame', nil, AuctionHouseButton)
    AuctionHouseButton.frame:SetAllPoints(AuctionHouseButton)
    AuctionHouseButton.Text= e.Cstr(AuctionHouseButton)
    AuctionHouseButton.Text:SetPoint('CENTER')
    AuctionHouseButton.buttons={}




    --按钮
    function AuctionHouseButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, e.cn(addName))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.GetShowHide(nil, true), e.GetShowHide(not Save.hideSellItemList)..e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.scaleSellButton or 1), 'Alt+'..e.Icon.mid)
        e.tips:AddDoubleLine((e.onlyChinese and '行数' or HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ROWS)..' |cnGREEN_FONT_COLOR:'..(Save.numButton or 15), 'Shift+'..e.Icon.mid)
        e.tips:AddLine(' ')
        local num= 0
        for _ in pairs(Save.hideSellItem) do
            num= num+1
        end
        e.tips:AddDoubleLine((e.onlyChinese and '清除隐藏物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_STOPWATCH_PARAM_STOP2, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, ITEMS)))..' |cnGREEN_FONT_COLOR:'..num, 'Ctrl+'..e.Icon.right)
        e.tips:Show()
    end
    AuctionHouseButton:SetScript('OnLeave', GameTooltip_Hide)
    AuctionHouseButton:SetScript('OnEnter', AuctionHouseButton.set_tooltips)
    AuctionHouseButton:SetScript('OnEvent', function(self)
        C_Timer.After(0.3, function() self:init_items() end)
    end)
    AuctionHouseButton:SetScript('OnClick', function(self, d)
        if IsControlKeyDown() and d=='RightButton' then
            Save.hideSellItem={}
            self:init_items()
            print(e.addName, e.cn(addName), e.onlyChinese and '清除隐藏物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_STOPWATCH_PARAM_STOP2, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, ITEMS)))

        elseif not IsModifierKeyDown() then
            Save.hideSellItemList= not Save.hideSellItemList and true or nil
            self:init_items()
        end
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
            n= n>4 and 4 or n
            n= n<0.4 and 0.4 or n
            Save.scaleSellButton=n
            self:set_scale()
        end
        self:set_tooltips()
    end)
    AuctionHouseButton:set_scale()









    function AuctionHouseButton:get_displayMode()
        local displayMode= AuctionHouseFrame:GetDisplayMode()
        return displayMode==AuctionHouseFrameDisplayMode.CommoditiesSell, displayMode==AuctionHouseFrameDisplayMode.ItemSell
        --return displayMode[1]=='CommoditiesSellFrame', displayMode[1]=='ItemSellFrame'
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
                    if info and info.hyperlink and info.itemID and itemLocation and itemCommodityStatus>0 then
                        local btn= self.buttons[index]
                        if not btn then
                            btn= WoWTools_ButtonMixin:Cbtn(self.frame, {button='ItemButton', icon='hide'})
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



                            btn:UpdateItemContextOverlayTextures(1)
                            btn:SetScript('OnLeave', function()
                                C_Container.SetItemSearch('')
                                GameTooltip_Hide()
                            end)

                            btn:SetScript('OnEnter', function(frame)
                                e.tips:SetOwner(frame:GetParent(), "ANCHOR_LEFT")
                                e.tips:ClearLines()
                                if frame.itemLocation and frame.itemLocation:IsValid() and C_Item.DoesItemExist(frame.itemLocation) then
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
                                    local itemName=C_Item.GetItemNameByID(itemLink)
                                    if itemID then
                                        e.tips:AddDoubleLine(e.GetShowHide(nil, true), e.GetShowHide(Save.hideSellItem[itemID])..e.Icon.right)
                                    end
                                    C_Container.SetItemSearch(itemName or '')
                                else
                                    e.tips:AddLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '未发现物品' or BROWSE_ORDERS))
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
                                        if frame.selectTexture:IsShown() then
                                            AuctionHouseFrame:ClearPostItem()
                                            AuctionHouseButton:set_next_item()
                                        end
                                    end
                                end
                            end)
                            self.buttons[index]= btn
                        end
                        btn:ClearAllPoints()
                        btn:SetPoint("TOPLEFT", index==1 and self or self.buttons[index-1], 'BOTTOMLEFT', 0, -2)

                        btn.isPet= info.hyperlink:find('Hbattlepet:(%d+)')
                        btn:SetItemLocation(itemLocation)
                        btn:SetItemButtonCount(info.stackCount)
                        btn:SetAlpha(Save.hideSellItem[info.itemID] and 0.3 or 1)
                        btn.isCommoditiesTexture:SetShown(not Save.hideSellItem[info.itemID] and (
                            (itemCommodityStatus==Enum.ItemCommodityStatus.Item and isItemSellFrame)
                            or (itemCommodityStatus==Enum.ItemCommodityStatus.Commodity and isCommoditiesSellFrame)
                        ))

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

        self.Text:SetText(Save.hideSellItemList and '|cff9e9e9e'..(e.onlyChinese and '隐藏' or HIDE) or index-1)
    end




































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
        e.tips:AddDoubleLine(e.addName, e.cn(addName))
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
        e.tips:AddDoubleLine(e.addName, e.cn(addName))
        e.tips:AddDoubleLine(' ', e.onlyChinese and '最大数量' or AUCTION_HOUSE_MAX_QUANTITY_BUTTON)
        e.tips:Show()
    end)
    AuctionHouseFrame.maxSellItemCheck2:SetScript('OnClick', function()
        Save.isMaxSellItem= not Save.isMaxSellItem and true or nil
        AuctionHouseFrame.maxSellItemCheck:SetChecked(Save.isMaxSellItem)
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
            if Save.isMaxSellItem and self.QuantityInput.MaxButton:IsEnabled() then
                self:SetToMaxQuantity()--出售物品时，使用，最大数量
            end
        end)

    end)
    hooksecurefunc(AuctionHouseFrame.ItemSellFrame, 'SetItem', function(self)
        C_Timer.After(0.3, function()
            AuctionHouseButton:set_select_tips()--提示，已放入物品
            if Save.isMaxSellItem and self.QuantityInput.MaxButton:IsEnabled() then
                self:SetToMaxQuantity()--出售物品时，使用，最大数量
            end
        end)

    end)




































    --转到出售
    function AuctionHouseButton:show_CommoditiesSellFrame()
        local isCommoditiesSellFrame= self:get_displayMode()
        if not isCommoditiesSellFrame then
           AuctionHouseFrame:SetDisplayMode(AuctionHouseFrameDisplayMode.CommoditiesSell)
        end
    end
    --当页面是 出售 时，显示按钮
    function AuctionHouseButton:set_shown()
        local isCommoditiesSellFrame, isItemSellFrame= self:get_displayMode()
        self:SetShown(AuctionHouseFrame:IsShown() and (isCommoditiesSellFrame or isItemSellFrame))
    end
    --设置事件
    function AuctionHouseButton:set_event()
        self:UnregisterAllEvents()
        if self:IsShown() then
            self:RegisterEvent('BAG_UPDATE_DELAYED')
        end
    end
    --事件
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




















































    --显示拍卖行时，转到出售物品
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
        e.tips:AddDoubleLine(e.addName, e.cn(addName))
        e.tips:AddDoubleLine(e.onlyChinese and '显示拍卖行时' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, BUTTON_LAG_AUCTIONHOUSE),
            e.onlyChinese and '转到出售' or ('=> '..AUCTION_HOUSE_SELL_TAB))
        e.tips:Show()
    end)
    showSellItemCheck:SetScript('OnClick', function()
        Save.intShowSellItem= not Save.intShowSellItem and true or nil
    end)
    AuctionHouseFrame:HookScript('OnShow', function(self)
        if not Save.intShowSellItem then
            return
        end
        local find
        for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES do--Constants.InventoryConstants.NumBagSlots
            for slot=1, C_Container.GetContainerNumSlots(bag) do
                local info = C_Container.GetContainerItemInfo(bag, slot)
                local itemCommodityStatus= info and info.itemID and not Save.hideSellItem[info.itemID] and select(2, AuctionHouseButton:get_itemLocation(bag, slot)) or 0
                if itemCommodityStatus>0 then
                    find=true
                    break
                end
            end
            if find then
                break
            end
        end
        if find then
            self:SetDisplayMode(AuctionHouseFrameDisplayMode.CommoditiesSell)
            C_Timer.After(0.5, function() AuctionHouseButton:set_next_item() end)--放入，第一个，物品
        end
    end)














    --记录，用户，输入，价格
    function AuctionHouseButton:save_item_price(frame)
        local itemLocation= frame:GetItem()
        if itemLocation and itemLocation:IsValid() then
            local itemID= C_Item.GetItemID(itemLocation)
            if itemID  then
                local unitPrice= frame.PriceInput:GetAmount()
                if unitPrice and unitPrice>100000 then--10金
                    Save.SellItemDefaultPrice[itemID]= unitPrice
                else
                    Save.SellItemDefaultPrice[itemID]=nil
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

























    --单价，倍数
    AuctionHouseFrame.CommoditiesSellFrame.percentLabel= e.Cstr(AuctionHouseFrame.CommoditiesSellFrame, {size=22, justifyH='RIGHT'})--单价，提示
    AuctionHouseFrame.CommoditiesSellFrame.percentLabel:SetPoint('BOTTOMRIGHT', AuctionHouseFrame.CommoditiesSellList, 'TOP', -50,0)
    --AuctionHouseFrame.CommoditiesSellFrame.percentLabel:SetPoint('BOTTOM', AuctionHouseFrame.CommoditiesSellFrame.PostButton, 'TOP') 
    AuctionHouseFrame.CommoditiesSellFrame.vendorPriceLabel= e.Cstr(AuctionHouseFrame.CommoditiesSellFrame, {size=12})--单价，提示
    AuctionHouseFrame.CommoditiesSellFrame.vendorPriceLabel:SetPoint('TOPRIGHT', AuctionHouseFrame.CommoditiesSellFrame.PriceInput.MoneyInputFrame.GoldBox, 'BOTTOMRIGHT',0,4)

    AuctionHouseFrame.ItemSellFrame.percentLabel= e.Cstr(AuctionHouseFrame.ItemSellFrame, {size=22, justifyH='RIGHT'})--单价，提示
    AuctionHouseFrame.ItemSellFrame.percentLabel:SetPoint('BOTTOMRIGHT', AuctionHouseFrame.ItemSellList, 'TOP', -50,0)
    --AuctionHouseFrame.ItemSellFrame.percentLabel:SetPoint('BOTTOM', AuctionHouseFrame.ItemSellFrame.PostButton, 'TOP')
    AuctionHouseFrame.ItemSellFrame.vendorPriceLabel= e.Cstr(AuctionHouseFrame.ItemSellFrame, {size=12})--单价，提示
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
                    if itemID and not Save.hideSellItem[itemID] then--加入，隐藏，物品列表
                        Save.hideSellItem[itemID]=true
                        self:init_items()
                        AuctionHouseFrame:ClearPostItem()
                        C_Timer.After(0.3, function() self:set_next_item() end)--放入，第一个，物品
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























    AuctionHouseFrame.CommoditiesSellFrame.PostButton:SetHeight(32)--<Size x="194" y="22"/>
    AuctionHouseFrame.ItemSellFrame.PostButton:SetHeight(32)


    --下一个，拍卖，物品        
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
        C_Timer.After(0.3, function() AuctionHouseButton:set_next_item() end)--放入，第一个，物品
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
        C_Timer.After(0.3, function() AuctionHouseButton:set_next_item() end)--放入，第一个，物品
        self.isNextItem=nil
    end)

















    --转到，商品，模式，按钮
    local showCommoditiesButton=WoWTools_ButtonMixin:Cbtn(AuctionHouseFrame.ItemSellFrame, {type=false, size={100,22}, text=e.onlyChinese and '物品' or ITEMS})
    showCommoditiesButton:SetPoint('BOTTOMRIGHT', -15,15)
    showCommoditiesButton:SetFrameLevel(levelFrame)
    showCommoditiesButton:SetScript('OnLeave', GameTooltip_Hide)
    showCommoditiesButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT");
        e.tips:ClearLines();
        e.tips:AddDoubleLine(e.addName, e.cn(addName))
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
        C_Timer.After(0.5, function() AuctionHouseButton:set_next_item() end)--放入，第一个，物品
    end)


    --转到，出售商品，按钮
    local showSellButton=WoWTools_ButtonMixin:Cbtn(AuctionHouseFrame.CommoditiesSellFrame, {type=false, size={100,22}, text=e.onlyChinese and '材料' or PROFESSIONS_COLUMN_HEADER_REAGENTS})
    showSellButton:SetPoint('BOTTOMRIGHT',  -15,15)
    showSellButton:SetFrameLevel(levelFrame)
    showSellButton:SetScript('OnLeave', GameTooltip_Hide)
    showSellButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT");
        e.tips:ClearLines();
        e.tips:AddDoubleLine(e.addName, e.cn(addName))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '显示' or SHOW, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '转到' or CONVERT)..'|r '..(e.onlyChinese and '物品' or ITEMS))
        e.tips:Show();
    end)
    showSellButton:SetScript('OnClick', function()
        AuctionHouseFrame:ClearPostItem()
        AuctionHouseFrame:SetDisplayMode(AuctionHouseFrameDisplayMode.ItemSell)
        C_Timer.After(0.5, function() AuctionHouseButton:set_next_item() end)--放入，第一个，物品
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
        e.tips:AddDoubleLine(e.addName, e.cn(addName))
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











































--所有，出售物品, 表表
local function Init_AllAuctions()
    --移动，刷新，按钮
    AuctionHouseFrameAuctionsFrame.AllAuctionsList.RefreshFrame.RefreshButton:ClearAllPoints()
    AuctionHouseFrameAuctionsFrame.AllAuctionsList.RefreshFrame.RefreshButton:SetPoint('RIGHT', AuctionHouseFrameAuctionsFrame.CancelAuctionButton, 'LEFT', -4, 0)

    --取消
    local cancelButton= WoWTools_ButtonMixin:Cbtn(AuctionHouseFrameAuctionsFrame.CancelAuctionButton, {type=false, size={100,22}, text= e.onlyChinese and '取消' or CANCEL})
    cancelButton:SetPoint('RIGHT', AuctionHouseFrameAuctionsFrame.AllAuctionsList.RefreshFrame.RefreshButton, 'LEFT', -4, 0)
    function cancelButton:get_auctionID()
        local tab={}
        if AuctionHouseFrameAuctionsFrame.AllAuctionsList.ScrollBox:GetView() then           
            for _, info in pairs(AuctionHouseFrameAuctionsFrame.AllAuctionsList.ScrollBox:GetFrames() or {}) do
                if info.rowData and info.rowData.auctionID and info.rowData.timeLeftSeconds and C_AuctionHouse.CanCancelAuction(info.rowData.auctionID) then
                    table.insert(tab, info.rowData)
                end
            end
        end
        table.sort(tab, function(a, b)
            return a.timeLeftSeconds< b.timeLeftSeconds
        end)
        if tab[1] and tab[1].auctionID then
            local auctionID= tab[1].auctionID
            local itemLink, itemID, isPet = Get_ItemLink_For_rowData(tab[1])
            return auctionID, itemLink, itemID, isPet
        end
    end
    function cancelButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        e.tips:ClearLines()
        local itemLink, itemID, isPet= select(2, self:get_auctionID())
        if itemLink then
            if isPet then
                BattlePetToolTip_Show(BattlePetToolTip_UnpackBattlePetLink(itemLink))
            else
                e.tips:SetHyperlink(itemLink)
            end
            e.tips:AddLine(' ')
        elseif itemID then
            e.tips:SetItemByID(itemID)
            e.tips:AddDoubleLine(' ')
        end
        e.tips:AddDoubleLine(' ', '|cnRED_FONT_COLOR:'..(e.onlyChinese and '取消拍卖将使你失去保证金。' or CANCEL_AUCTION_CONFIRMATION))
        e.tips:AddDoubleLine(e.onlyChinese and '备注' or 'Note', '|cnRED_FONT_COLOR:'..(e.onlyChinese and '请不要太快' or ERR_GENERIC_THROTTLE))
        e.tips:AddDoubleLine(e.addName, e.cn(addName))
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
                print(e.addName,e.cn(addName), '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '取消拍卖' or AUCTION_HOUSE_CANCEL_AUCTION_BUTTON)..'|r', itemLink or '', cost and cost>0 and '|cnRED_FONT_COLOR:'..GetMoneyString(cost) or '')
            else
                print(e.addName,e.cn(addName), '|cnRED_FONT_COLOR:'..(e.onlyChinese and '出错' or ERRORS)..'|r', itemLink or '')
            end
            AuctionHouseFrameAuctionsFrame.AllAuctionsList.RefreshFrame.RefreshButton:OnClick()
            self:set_tooltips()
        end
    end)


    --双击，取消拍卖
    local function OnDoubleClick_AllAuctionsList(frame)
        if not frame:GetView() then
            return
        end
        for _, btn in pairs(frame:GetFrames() or {}) do
            if not btn.setOnDoubleClick then
                btn:SetScript('OnDoubleClick', function(self)
                    if self.rowData and self.rowData.auctionID and C_AuctionHouse.CanCancelAuction(self.rowData.auctionID) then
                        local cost= C_AuctionHouse.GetCancelCost(self.rowData.auctionID)
                        local itemLink= Get_ItemLink_For_rowData(self.rowData)
                        C_AuctionHouse.CancelAuction(self.rowData.auctionID)
                        print(e.addName, e.cn(addName), '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '取消拍卖' or AUCTION_HOUSE_CANCEL_AUCTION_BUTTON)..'|r', itemLink, cost and cost>0 and '|cnRED_FONT_COLOR:'..GetMoneyString(cost) or '')
                    end
                end)
                btn.setOnDoubleClick=true
            end
        end
    end
    hooksecurefunc(AuctionHouseFrameAuctionsFrame.AllAuctionsList.ScrollBox, 'Update', OnDoubleClick_AllAuctionsList)
    hooksecurefunc(AuctionHouseFrameAuctionsFrame.ItemList.ScrollBox, 'Update', OnDoubleClick_AllAuctionsList)
    hooksecurefunc(AuctionHouseFrameAuctionsFrame.CommoditiesList.ScrollBox, 'Update', OnDoubleClick_AllAuctionsList)
end










local function Set_BrowseResultsFrame(frame)
    if not frame:GetView() then
        return
    end
    for _, btn in pairs(frame:GetFrames() or {}) do
        local text
        local itemKey= btn.rowData and btn.rowData.itemKey
        local itemKeyInfo = itemKey and C_AuctionHouse.GetItemKeyInfo(itemKey)--itemID battlePetSpeciesID itemName battlePetLink appearanceLink quality iconFileID isPet isCommodity isEquipment
        if itemKeyInfo then
            local isCollectedAll--宠物
            text, isCollectedAll= select(3, e.GetPetCollectedNum(itemKeyInfo.battlePetSpeciesID, itemKeyInfo.itemID, true))
            if isCollectedAll then
                text= '|A:common-icon-checkmark-yellow:0:0|a'
            end

            text= text or e.GetItemCollected(itemKeyInfo.itemID, nil, true)--物品是否收集

            if not text then--坐骑
                local isMountCollected= select(2, e.GetMountCollected(nil, itemKeyInfo.itemID))
                if isMountCollected then
                    text= '|A:common-icon-checkmark-yellow:0:0|a'
                end
            end
            if not text then
                local t1, t2= e.Get_Gem_Stats(nil, Get_ItemLink_For_rowData(btn.rowData))--显示, 宝石, 属性
                if t1 then
                    text= t1..(t2 and ' '..t2 or '')
                end
            end
            --[[if not text then
                --local itmeLink= Get_ItemLink_For_rowData(btn.rowData)
                local itemLink= Get_ItemLink_For_rowData(btn.rowData)
                local classID= select(6, C_Item.GetItemInfoInstant(itemKeyInfo.itemID))
                
                if classID==9 then--配方
                    local dataTooltipsInfo = C_TooltipInfo.GetItemKey(btn.rowData.itemKey.itemID, btn.rowData.itemKey.itemLevel, btn.rowData.itemKey.itemSuffix, btn.rowData.itemKey.itemLevel)

                    local dateInfo= WoWTools_ItemMixin:GetTooltip({itemID=itemKeyInfo.itemID, text={ITEM_SPELL_KNOWN}, onlyText=true})--物品提示，信息
                    local isLearned= dateInfo.text[ITEM_SPELL_KNOWN]
                    
                    if dataTooltipsInfo then
                        print(dataTooltipsInfo. hyperlink)
                    end
                    if isLearned then
                        text= '|A:common-icon-checkmark-yellow:0:0|a'
                    else
                        text= '|A:AdventureMapIcon-Quest:0:0|a'
                    end
                end
            end]]
        end
        if text and not btn.lable then
            btn.lable= e.Cstr(btn)
        end
        if btn.lable then
            btn.lable:SetPoint('RIGHT', btn.cells[2].Icon, 'LEFT')
            btn.lable:SetText(text or '')
        end
    end
end

--浏览拍卖行
--Blizzard_AuctionHouseUI.lua
--local ITEM_SPELL_KNOWN = ITEM_SPELL_KNOWN--"已学习
local function Init_BrowseResultsFrame()
    --hooksecurefunc(AuctionHouseFrame.BrowseResultsFrame.ItemList.ScrollBox, 'SetScrollTargetOffset', Set_BrowseResultsFrame)
    hooksecurefunc(AuctionHouseFrame.BrowseResultsFrame.ItemList.ScrollBox, 'Update', Set_BrowseResultsFrame)

    --双击，一口价
    hooksecurefunc(AuctionHouseFrame.ItemBuyFrame.ItemList.ScrollBox, 'Update', function(frame)
        if not frame:GetView() then
            return
        end
        for _, btn in pairs(frame:GetFrames() or {}) do
            if not btn.setOnDoubleClick then
                btn:SetScript('OnDoubleClick', function()
                    if AuctionHouseFrame.ItemBuyFrame.BuyoutFrame.BuyoutButton and AuctionHouseFrame.ItemBuyFrame.BuyoutFrame.BuyoutButton:IsEnabled() then
                        if StaticPopup1:IsShown() then
                            StaticPopup1:Hide()
                        else
                            AuctionHouseFrame.ItemBuyFrame.BuyoutFrame.BuyoutButton:Click()
                        end
                    end
                end)
                btn.setOnDoubleClick=true
            end
        end
    end)
end
































--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if e.Is_Timerunning then
                self:UnregisterAllEvents()
                return
            end

            Save= WoWToolsSave[addName] or Save
           
            --添加控制面板
            e.AddPanel_Check({
                name= '|A:Auctioneer:0:0|a'..(e.onlyChinese and '拍卖行' or addName),
                
                tooltip= e.cn(addName),
                Value= not Save.disabled,
                GetValue= function() return not Save.disabled end,
                SetValue= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(e.addName, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                end
            })

            if Save.disabled then
                self:UnregisterEvent('ADDON_LOADED')               
            end
            


        elseif arg1=='Blizzard_AuctionHouseUI' then
            Init_BrowseResultsFrame()
            Init_AllAuctions()
            Init_Sell()
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)