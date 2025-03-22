if GameLimitedMode_IsActive() or PlayerGetTimerunningSeasonID() then
    return
end
--拍卖行
local e= select(2, ...)
local function Save()
    return WoWTools_AuctionHouseMixin.Save
end





local AuctionHouseButton



local function Create_Button()
    local btn= WoWTools_ButtonMixin:Cbtn(AuctionHouseButton.frame, {frameType='ItemButton', size=36})
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
                (WoWTools_Mixin.onlyChinese and '开始拍卖' or CREATE_AUCTION).. WoWTools_DataMixin.Icon.left..' '..WoWTools_DataMixin.Icon.right..(WoWTools_Mixin.onlyChinese and '隐藏' or HIDE)
                or
                function(tooltip)
                    tooltip:AddLine(' ')
                    tooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '开始拍卖' or CREATE_AUCTION..WoWTools_DataMixin.Icon.left, WoWTools_DataMixin.Icon.right..(WoWTools_Mixin.onlyChinese and '隐藏' or HIDE))
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
                    WoWTools_AuctionHouseMixin:Init_Sell_Item_Button()
                else
                    self:set_alpha()
                end

                if self.selectTexture:IsShown() then
                    AuctionHouseFrame:ClearPostItem()
                    WoWTools_AuctionHouseMixin:SetPostNextSellItem()
                end
            end
        end
    end)
    table.insert(AuctionHouseButton.buttons, btn)
    return btn
end










local function Init_Sell_Item_Button()
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




















local function Init()
    AuctionHouseButton= WoWTools_ButtonMixin:Menu(AuctionHouseFrame, {name='WoWToolsAuctionHouseSellListButton', icon='hide'})

    AuctionHouseButton:SetPoint('TOPLEFT', AuctionHouseFrame, 'TOPRIGHT',4,0)
    AuctionHouseButton.frame= CreateFrame('Frame', nil, AuctionHouseButton)
    AuctionHouseButton.frame:SetSize(1,1)
    AuctionHouseButton.frame:SetPoint('BOTTOMLEFT')
    AuctionHouseButton.Text= WoWTools_LabelMixin:Create(AuctionHouseButton)
    AuctionHouseButton.Text:SetPoint('CENTER')
    AuctionHouseButton.buttons={}




--按钮
    function AuctionHouseButton:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_AuctionHouseMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.left)
    end

    function AuctionHouseButton:Settings()
        self.frame:SetScale(Save().scaleSellButton or 1)
        local hide= Save().hideSellItemList
        self.frame:SetShown(not hide)
        if hide then
            self.Text:SetText('|cff828282'..(WoWTools_Mixin.onlyChinese and '隐藏' or HIDE))
        end
        self:SetAlpha(hide and 0.3 or 1)
    end

    function AuctionHouseButton:Init_Sell_Item_Button()
        Init_Sell_Item_Button()
    end


    AuctionHouseButton:SetScript('OnLeave', GameTooltip_Hide)
    AuctionHouseButton:SetScript('OnEnter', AuctionHouseButton.set_tooltips)
    AuctionHouseButton:SetScript('OnEvent', function()
        C_Timer.After(0.3, Init_Sell_Item_Button)
    end)

--菜单
    WoWTools_AuctionHouseMixin:Sell_Setup_Menu(AuctionHouseButton)

    AuctionHouseButton:Settings()

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
            Init_Sell_Item_Button()
		end
        AuctionHouseButton:set_shown()
        AuctionHouseButton:set_event()
    end)
    AuctionHouseFrame:HookScript('OnHide', function()
        AuctionHouseButton:set_event()
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











function WoWTools_AuctionHouseMixin:Init_Sell()
    if not self.Save.disabledSellPlus then
        Init()
    end
end

function WoWTools_AuctionHouseMixin:Init_Sell_Item_Button()
    Init_Sell_Item_Button()
end
