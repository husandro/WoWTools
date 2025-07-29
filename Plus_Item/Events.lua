

--添加一个按钮, 打开，角色界面
local function Add_OpenOptionButton(frame)
    if not frame then
        return
    end

    local btn= WoWTools_ButtonMixin:Cbtn(frame, {
        atlas='charactercreate-icon-customize-body-selected',
        size=40,
        name='WoWTools'..frame:GetParent():GetName()..'ItemInfoOptionsButton'
    })

    btn:SetPoint('TOPRIGHT',-5,-25)
    btn:SetScript('OnClick', function()
        ToggleCharacter("PaperDollFrame")
    end)

    btn:SetScript('OnLeave', function() GameTooltip_Hide() end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '打开/关闭角色界面' or BINDING_NAME_TOGGLECHARACTER0, WoWTools_DataMixin.Icon.left)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_ItemMixin.addName)
        GameTooltip:Show()
    end)


    if frame==ItemUpgradeFrameCloseButton then--装备升级, 界面
        --物品，货币提示
        WoWTools_LabelMixin:ItemCurrencyTips({frame=ItemUpgradeFrame, point={'TOPLEFT', nil, 'TOPLEFT', 2, -55}})

        btn:SetScript("OnEvent", function()
            WoWTools_LabelMixin:ItemCurrencyTips({frame=ItemUpgradeFrame, point={'TOPLEFT', nil, 'TOPLEFT', 2, -55}})
        end)

        btn:SetScript('OnShow', function(self)
            WoWTools_LabelMixin:ItemCurrencyTips({frame=ItemUpgradeFrame, point={'TOPLEFT', nil, 'TOPLEFT', 2, -55}})
            self:RegisterEvent('BAG_UPDATE_DELAYED')
            self:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
        end)

        btn:SetScript('OnHide', function(self)
            self:UnregisterAllEvents()
        end)
    end
end















--商站
function WoWTools_ItemMixin.Events:Blizzard_PerksProgram()
    local function set_uptate(frame)
        if not frame:GetView() then
            return
        end
        for _, btn in pairs(frame:GetFrames()) do
            if btn.itemID then
                local itemLink= WoWTools_ItemMixin:GetLink(btn.itemID)
                WoWTools_ItemMixin:SetupInfo(btn.ContentsContainer, {itemLink=itemLink, point=btn.ContentsContainer.Icon, size=12})
            elseif btn.GetItemInfo then--10.2
                local itemInfo=btn:GetItemInfo()
                if itemInfo then
                    local itemLink= WoWTools_ItemMixin:GetLink(itemInfo.itemID)
                    WoWTools_ItemMixin:SetupInfo(btn.ContentsContainer, {itemLink=itemLink, point=btn.ContentsContainer.Icon, size=12})
                end
            end
--双击， 移队/加入购物车
            if btn:GetObjectType()=='Button' and not btn:GetScript('OnDoubleClick') then
                btn:SetScript('OnDoubleClick', function(b)
                    b.ContentsContainer.CartToggleButton:Click()
                end)
            end
        end

        if PerksProgramFrame.GetFrozenItemFrame then
            local f= PerksProgramFrame:GetFrozenItemFrame()
            if f then
                WoWTools_ItemMixin:SetupInfo(f.FrozenButton, {
                    itemLink=f.FrozenButton.itemID and WoWTools_ItemMixin:GetLink(f.FrozenButton.itemID),
                    size=12
                })
            end
        end
    end


    hooksecurefunc(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.ScrollBox, 'Update', function(frame)
        set_uptate(frame)
    end)

    C_Timer.After(0.3, function()
        set_uptate(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.ScrollBox)
    end)
end








--周奖励, 物品提示，信息
function WoWTools_ItemMixin.Events:Blizzard_WeeklyRewards()
    hooksecurefunc(WeeklyRewardsFrame, 'Refresh', function(f)--Blizzard_WeeklyRewards.lua WeeklyRewardsMixin:Refresh(playSheenAnims)
        for _, activityInfo in ipairs(C_WeeklyRewards.GetActivities() or {}) do
            local frame = f:GetActivityFrame(activityInfo.type, activityInfo.index)
            local itemFrame= frame and frame.ItemFrame
            if itemFrame then
                WoWTools_ItemMixin:SetItemStats(itemFrame, itemFrame.displayedItemDBID and C_WeeklyRewards.GetItemHyperlink(itemFrame.displayedItemDBID), {point=itemFrame.Icon})
            end
        end
    end)
    hooksecurefunc(WeeklyRewardsFrame, 'UpdateSelection', function(f)
        for _, activityInfo in ipairs(C_WeeklyRewards.GetActivities() or {}) do
            local frame = f:GetActivityFrame(activityInfo.type, activityInfo.index)
            local itemFrame= frame and frame.ItemFrame
            if itemFrame then
                WoWTools_ItemMixin:SetItemStats(itemFrame, itemFrame.displayedItemDBID and C_WeeklyRewards.GetItemHyperlink(itemFrame.displayedItemDBID), {point=itemFrame.Icon})
            end
        end
    end)
end








--拍卖行
function WoWTools_ItemMixin.Events:Blizzard_AuctionHouseUI()
    --出售页面，买卖，物品信息 Blizzard_AuctionHouseSellFrame.lua
    hooksecurefunc(AuctionHouseSellFrameMixin, 'SetItem', function(self, itemLocation)
        WoWTools_ItemMixin:SetupInfo(self.ItemDisplay.ItemButton, {itemLocation= itemLocation, size=12})
    end)

    hooksecurefunc(AuctionHouseFrame, 'SelectBrowseResult', function(self, browseResult)
        local itemKey = browseResult.itemKey
        local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey) or {}
        if itemKeyInfo.isCommodity then
            WoWTools_ItemMixin:SetupInfo(self.CommoditiesBuyFrame.BuyDisplay.ItemDisplay.ItemButton, {itemKey= itemKey, size=12})
        else
            WoWTools_ItemMixin:SetupInfo(self.ItemBuyFrame.ItemDisplay.ItemButton, {itemKey= itemKey, size=12})
        end

        if not self.countLable then
            self.countLable= WoWTools_LabelMixin:Create(self.CommoditiesBuyFrame.BuyDisplay.ItemDisplay)
            self.countLable:SetPoint('BOTTOM', self.CommoditiesBuyFrame.BuyDisplay.ItemDisplay, 'TOP', 0,1)
        end
        local count= WoWTools_ItemMixin:GetCount(itemKey.itemID)
        self.countLable:SetText(count or '')
    end)
end








--套装转换, 界面
function WoWTools_ItemMixin.Events:Blizzard_ItemInteractionUI()
    Add_OpenOptionButton(ItemInteractionFrameCloseButton)--添加一个按钮, 打开选项

    ItemInteractionFrame.Tip= CreateFrame('GameTooltip', nil, ItemInteractionFrame, 'GameTooltipTemplate')
    ItemInteractionFrame.Tip:SetScript('OnHide', ItemInteractionFrame.Tip.ClearLines)
    hooksecurefunc(ItemInteractionFrame.ItemConversionFrame.ItemConversionOutputSlot, 'RefreshIcon', function(self)
        local itemInteractionFrame = self:GetParent():GetParent()
        local itemLocation = itemInteractionFrame:GetItemLocation()
        local itemLink
        local show= (itemLocation and itemInteractionFrame:GetInteractionType() == Enum.UIItemInteractionType.ItemConversion)
        if show then
            itemInteractionFrame.Tip:SetItemInteractionItem()
            itemLink= select(2, itemInteractionFrame.Tip:GetItem())
        end
        WoWTools_ItemMixin:SetItemStats(self, itemLink, {}) --设置，物品，次属性，表
    end)
    hooksecurefunc(ItemInteractionFrame.ItemConversionFrame.ItemConversionInputSlot, 'RefreshIcon', function(self)
        local itemInteractionFrame = self:GetParent():GetParent()
        local itemLocation = itemInteractionFrame:GetItemLocation()
        local itemLink
        local show= (itemLocation and itemInteractionFrame:GetInteractionType() == Enum.UIItemInteractionType.ItemConversion)
        if show then
            itemLink= C_Item.GetItemLink(itemLocation)
        end
        WoWTools_ItemMixin:SetItemStats(self, itemLink, {}) --设置，物品，次属性，表
    end)
end














--装备升级, 界面
function WoWTools_ItemMixin.Events:Blizzard_ItemUpgradeUI()
    Add_OpenOptionButton(ItemUpgradeFrameCloseButton)--添加一个按钮, 打开选项                       
end














function WoWTools_ItemMixin.Events:Blizzard_FrameXML()
    --boss掉落，物品, 可能，会留下 StaticPopup1 框架
    --AlertFrames.xml
    hooksecurefunc('BossBanner_ConfigureLootFrame', function(lootFrame, data)--LevelUpDisplay.lua data= { itemID = itemID, quantity = quantity, playerName = playerName, className = className, itemLink = itemLink }
        WoWTools_ItemMixin:SetItemStats(lootFrame, data.itemLink, {point=lootFrame.Icon})
    end)

        --拾取时, 弹出, 物品提示，信息, 战利品
    --AlertFrameSystems.lua
    hooksecurefunc('DungeonCompletionAlertFrameReward_SetRewardItem', function(frame, itemLink)--,texture
        WoWTools_ItemMixin:SetItemStats(frame, frame.itemLink or itemLink , {point=frame.texture})
    end)
    hooksecurefunc('LootWonAlertFrame_SetUp', function(frame)
        WoWTools_ItemMixin:SetItemStats(frame, frame.hyperlink, {point= frame.lootItem.Icon})
    end)
    hooksecurefunc('LootUpgradeFrame_SetUp', function(frame)
        WoWTools_ItemMixin:SetItemStats(frame, frame.hyperlink, {point=frame.Icon})
    end)

    hooksecurefunc('LegendaryItemAlertFrame_SetUp', function(frame)
        WoWTools_ItemMixin:SetItemStats(frame, frame.hyperlink, {point= frame.Icon})
    end)


    hooksecurefunc(LootItemExtendedMixin, 'Init', function(frame, itemLink2, originalQuantity, _, isCurrency)--ItemDisplay.lua
        local _, _, _, _, itemLink = ItemUtil.GetItemDetails(itemLink2, originalQuantity, isCurrency)
        WoWTools_ItemMixin:SetItemStats(frame, itemLink, {point= frame.Icon})
    end)
end