


local addName
local P_Save={}

local function Save()
    return WoWToolsSave['Plus_ItemInfo'] or {}
end





































local function setBags(self)--背包设置
    if not self:IsVisible() then
        return
    end
    for _, itemButton in self:EnumerateValidItems() do
        if itemButton.hasItem then
            local slotID, bagID= itemButton:GetSlotAndBagID()--:GetID() GetBagID()
            WoWTools_ItemMixin:Setup(itemButton, {bag={bag=bagID, slot=slotID}})
        else
            WoWTools_ItemMixin:Setup(itemButton, {})
        end
    end
end


























--[[hooksecurefunc(GuildBankFrame,'Update', function(self)--Blizzard_GuildBankUI.lua
local MAX_GUILDBANK_SLOTS_PER_TAB = 98
local NUM_SLOTS_PER_GUILDBANK_GROUP = 14
local function setGuildBank()--公会银行,设置
    if GuildBankFrame and GuildBankFrame:IsVisible() then
        local tab = GetCurrentGuildBankTab() or 1--Blizzard_GuildBankUI.lua
        for i=1, MAX_GUILDBANK_SLOTS_PER_TAB do
            local index = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP)
            if ( index == 0 ) then
                index = NUM_SLOTS_PER_GUILDBANK_GROUP
            end
            local column = ceil((i-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP)
            local button = (GuildBankFrame.Columns[column] and GuildBankFrame.Columns[column].Buttons) and GuildBankFrame.Columns[column].Buttons[index]
            if button then
                WoWTools_ItemMixin:Setup(button,{guidBank={tab=tab, slot=i}})
            end
        end
    end
end]]






























--###
--BAG
--###
local function Init_Bag()
    if C_AddOns.IsAddOnLoaded("Bagnon") then
        local itemButton = Bagnon.ItemSlot or Bagnon.Item
        if (itemButton) and (itemButton.Update)  then
            hooksecurefunc(itemButton, 'Update', function(self)
                local slot, bag= self:GetSlotAndBagID()
                if slot and bag then
                    if self.hasItem then
                        local slotID, bagID= self:GetSlotAndBagID()--:GetID() GetBagID()
                        WoWTools_ItemMixin:Setup(self, {bag={bag=bagID, slot=slotID}})
                    else
                        WoWTools_ItemMixin:Setup(self, {})
                    end
                end
            end)
        end
        return

    elseif C_AddOns.IsAddOnLoaded("Baggins") then
        hooksecurefunc(_G['Baggins'], 'UpdateItemButton', function(_, _, button, bagID, slotID)
            if button and bagID and slotID then
                WoWTools_ItemMixin:Setup(button, {bag={bag=bagID, slot=slotID}})
            end
        end)
        return

    elseif C_AddOns.IsAddOnLoaded('Inventorian') then
        local lib = LibStub("AceAddon-3.0", true)
        if lib then
            ADDON= lib:GetAddon("Inventorian")
            local InvLevel = ADDON:NewModule('InventorianWoWToolsItemInfo')
            function InvLevel:Update()
                WoWTools_ItemMixin:Setup(self, {bag={bag=self.bag, slot=self.slot}})
            end
            function InvLevel:WrapItemButton(item)
                hooksecurefunc(item, "Update", InvLevel.Update)
            end
            hooksecurefunc(ADDON.Item, "WrapItemButton", InvLevel.WrapItemButton)
            return
        end

    else
        hooksecurefunc('ContainerFrame_GenerateFrame',function (self)
            for _, frame in ipairs(ContainerFrameSettingsManager:GetBagsShown()) do
                if not frame.SetBagInfo then
                    setBags(frame)
                    hooksecurefunc(frame, 'UpdateItems', setBags)
                    frame.SetBagInfo=true
                end
            end
        end)
        --[[
            local numBag= NUM_TOTAL_EQUIPPED_BAG_SLOTS+ NUM_REAGENTBAG_FRAMES--5+1
            for i=NUM_BANKBAGSLOTS, 1, -1 do
                local frame= _G['ContainerFrame'..(i+numBag)]
                if frame then
                    hooksecurefunc(frame,'UpdateItems', function(self)
                        self:GetBagID()
                    end)
                end
            end
        ]]

--打开公会银行时, 打开背包
        --EventRegistry:RegisterFrameEventAndCallback("GUILDBANKBAGSLOTS_CHANGED", setGuildBank)
        --EventRegistry:RegisterFrameEventAndCallback("GUILDBANK_ITEM_LOCK_CHANGED", setGuildBank)
    end

--银行, BankFrame.lua
    hooksecurefunc('BankFrameItemButton_Update', function(self)
        if not self.isBag then
            local bag, slot= WoWTools_BankMixin:GetBagAndSlot(self)
            WoWTools_ItemMixin:Setup(self, {bag={bag=bag, slot=slot}})
            --WoWTools_ItemMixin:Setup(self, {bag={bag=self:GetParent():GetID(), slot=self:GetID()}})
        end
    end)

--战团银行
    hooksecurefunc(BankPanelItemButtonMixin, 'Refresh', function(self)
        local info= self.itemInfo or {}
        info.isShow=true
        WoWTools_ItemMixin:Setup(self, info)
    end)
end


























--####
--初始
--####
local function Init()
    FMTab={--附魔
        ['主属性']= '主',
        ['坐骑速度']= '骑',
        [PRIMARY_STAT1_TOOLTIP_NAME]=  WoWTools_DataMixin.onlyChinese and "力" or WoWTools_TextMixin:sub(PRIMARY_STAT1_TOOLTIP_NAME, 1, 3, true),
        [PRIMARY_STAT2_TOOLTIP_NAME]=  WoWTools_DataMixin.onlyChinese and "敏" or WoWTools_TextMixin:sub(PRIMARY_STAT2_TOOLTIP_NAME, 1, 3, true),
        [PRIMARY_STAT3_TOOLTIP_NAME]=  WoWTools_DataMixin.onlyChinese and "耐" or WoWTools_TextMixin:sub(PRIMARY_STAT3_TOOLTIP_NAME, 1, 3, true),
        [PRIMARY_STAT4_TOOLTIP_NAME]=  WoWTools_DataMixin.onlyChinese and "智" or WoWTools_TextMixin:sub(PRIMARY_STAT4_TOOLTIP_NAME, 1, 3, true),
        [ITEM_MOD_CRIT_RATING_SHORT]= WoWTools_DataMixin.onlyChinese and '爆' or WoWTools_TextMixin:sub(STAT_CRITICAL_STRIKE, 1, 3, true),
        [ITEM_MOD_HASTE_RATING_SHORT]= WoWTools_DataMixin.onlyChinese and '急' or WoWTools_TextMixin:sub(STAT_HASTE, 1, 3, true),
        [ITEM_MOD_MASTERY_RATING_SHORT]= WoWTools_DataMixin.onlyChinese and '精' or WoWTools_TextMixin:sub(STAT_MASTERY, 1, 3, true),
        [ITEM_MOD_VERSATILITY]= WoWTools_DataMixin.onlyChinese and '全' or WoWTools_TextMixin:sub(STAT_VERSATILITY, 1, 3, true),
        [ITEM_MOD_CR_AVOIDANCE_SHORT]= WoWTools_DataMixin.onlyChinese and '闪' or WoWTools_TextMixin:sub(ITEM_MOD_CR_AVOIDANCE_SHORT, 1, 3, true),
        [ITEM_MOD_CR_LIFESTEAL_SHORT]= WoWTools_DataMixin.onlyChinese and '吸' or WoWTools_TextMixin:sub(ITEM_MOD_CR_LIFESTEAL_SHORT, 1, 3, true),
        [ITEM_MOD_CR_SPEED_SHORT]= WoWTools_DataMixin.onlyChinese and '速' or WoWTools_TextMixin:sub(ITEM_MOD_CR_SPEED_SHORT, 1, 3, true),
    }

    --boss掉落，物品, 可能，会留下 StaticPopup1 框架
    hooksecurefunc('BossBanner_ConfigureLootFrame', function(lootFrame, data)--LevelUpDisplay.lua
        WoWTools_ItemMixin:SetItemStats(lootFrame, data.itemLink, {point=lootFrame.Icon})
    end)




    --拾取时, 弹出, 物品提示，信息, 战利品
    --AlertFrameSystems.lua
    hooksecurefunc('DungeonCompletionAlertFrameReward_SetRewardItem', function(frame, itemLink)
        WoWTools_ItemMixin:SetItemStats(frame, frame.itemLink or itemLink , {point=frame.texture})
    end)
    hooksecurefunc('LootWonAlertFrame_SetUp', function(self)
        WoWTools_ItemMixin:SetItemStats(self, self.hyperlink, {point= self.lootItem.Icon})
    end)
    hooksecurefunc('LootUpgradeFrame_SetUp', function(self)
        WoWTools_ItemMixin:SetItemStats(self, self.hyperlink, {point=self.Icon})
    end)

    hooksecurefunc('LegendaryItemAlertFrame_SetUp', function(frame)
        WoWTools_ItemMixin:SetItemStats(frame, frame.hyperlink, {point= frame.Icon})
    end)


    hooksecurefunc(LootItemExtendedMixin, 'Init', function(self, itemLink2, originalQuantity, _, isCurrency)--ItemDisplay.lua
        local _, _, _, _, itemLink = ItemUtil.GetItemDetails(itemLink2, originalQuantity, isCurrency)
        WoWTools_ItemMixin:SetItemStats(self, itemLink, {point= self.Icon})
    end)






    --拾取
    hooksecurefunc(LootFrame, 'Open', function(self)--LootFrame.lua
        if not self.ScrollBox:GetView() then
            return
        end
        for index, btn in pairs(self.ScrollBox:GetFrames() or {}) do
            WoWTools_ItemMixin:Setup(btn.Item, {lootIndex=btn.GetOrderIndex() or btn:GetSlotIndex() or index})
        end
    end)
    hooksecurefunc(LootFrame.ScrollBox, 'SetScrollTargetOffset', function(self)
        if not self:GetView() then
            return
        end
        for index, btn in pairs(self:GetFrames() or {}) do
            WoWTools_ItemMixin:Setup(btn.Item, {lootIndex=btn.GetOrderIndex() or btn:GetSlotIndex() or index})
        end
    end)

    Init_Bag()



    hooksecurefunc( BankPanelItemButtonMixin, 'Refresh', function (self)
        WoWTools_ItemMixin:Setup(self, {itemLink=self.itemInfo and self.itemInfo.hyperlink})
    end)

end


































--添加一个按钮, 打开，角色界面
local function add_Button_OpenOption(frame)
    if not frame then
        return
    end
    local btn= WoWTools_ButtonMixin:Cbtn(frame, {atlas='charactercreate-icon-customize-body-selected', size=40})
    btn:SetPoint('TOPRIGHT',-5,-25)
    btn:SetScript('OnClick', function()
        ToggleCharacter("PaperDollFrame")
    end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '打开/关闭角色界面' or BINDING_NAME_TOGGLECHARACTER0, WoWTools_DataMixin.Icon.left)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, addName)
        GameTooltip:Show()
    end)
    btn:SetScript('OnLeave', GameTooltip_Hide)
    if frame==ItemUpgradeFrameCloseButton then--装备升级, 界面
        --物品，货币提示
        WoWTools_LabelMixin:ItemCurrencyTips({frame=ItemUpgradeFrame, point={'TOPLEFT', nil, 'TOPLEFT', 2, -55}})
        btn:SetScript("OnEvent", function()
            --物品，货币提示
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







--商站 Blizzard_PerksProgram.lua
local function Blizzard_PerksProgram()
    local function set_FrozenButton_Tips()
        if PerksProgramFrame.GetFrozenItemFrame then
            local frame= PerksProgramFrame:GetFrozenItemFrame()
            if frame then
                local itemLink= frame.FrozenButton.itemID and WoWTools_ItemMixin:GetLink(frame.FrozenButton.itemID)
                WoWTools_ItemMixin:Setup(frame.FrozenButton, {itemLink=itemLink, size=12})
            end
        end
    end

    local function set_uptate(frame)
        if not frame:GetView() then
            return
        end
        for _, btn in pairs(frame:GetFrames()) do
            if btn.itemID then
                local itemLink= WoWTools_ItemMixin:GetLink(btn.itemID)
                WoWTools_ItemMixin:Setup(btn.ContentsContainer, {itemLink=itemLink, point=btn.ContentsContainer.Icon, size=12})
            elseif btn.GetItemInfo then--10.2
                local itemInfo=btn:GetItemInfo()
                if itemInfo then
                    local itemLink= WoWTools_ItemMixin:GetLink(itemInfo.itemID)
                    WoWTools_ItemMixin:Setup(btn.ContentsContainer, {itemLink=itemLink, point=btn.ContentsContainer.Icon, size=12})
                end
            end
--双击， 移队/加入购物车
            if btn:GetObjectType()=='Button' and not btn:GetScript('OnDoubleClick') then
                btn:SetScript('OnDoubleClick', function(self)
                    self.ContentsContainer.CartToggleButton:Click()
                end)
            end
        end
        set_FrozenButton_Tips()
    end


    hooksecurefunc(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.ScrollBox, 'Update', function(self)
        set_uptate(self)
    end)

    C_Timer.After(0.3, function()
        set_uptate(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.ScrollBox)
    end)




    Blizzard_PerksProgram=function()end
end








--周奖励, 物品提示，信息
local function Blizzard_WeeklyRewards()
    hooksecurefunc(WeeklyRewardsFrame, 'Refresh', function(self2)--Blizzard_WeeklyRewards.lua WeeklyRewardsMixin:Refresh(playSheenAnims)
        for _, activityInfo in ipairs(C_WeeklyRewards.GetActivities() or {}) do
            local frame = self2:GetActivityFrame(activityInfo.type, activityInfo.index)
            local itemFrame= frame and frame.ItemFrame
            if itemFrame then
                WoWTools_ItemMixin:SetItemStats(itemFrame, itemFrame.displayedItemDBID and C_WeeklyRewards.GetItemHyperlink(itemFrame.displayedItemDBID), {point=itemFrame.Icon})
            end
        end
    end)
    hooksecurefunc(WeeklyRewardsFrame, 'UpdateSelection', function(self2)
        for _, activityInfo in ipairs(C_WeeklyRewards.GetActivities() or {}) do
            local frame = self2:GetActivityFrame(activityInfo.type, activityInfo.index)
            local itemFrame= frame and frame.ItemFrame
            if itemFrame then
                WoWTools_ItemMixin:SetItemStats(itemFrame, itemFrame.displayedItemDBID and C_WeeklyRewards.GetItemHyperlink(itemFrame.displayedItemDBID), {point=itemFrame.Icon})
            end
        end
    end)
end



--拍卖行
local function Blizzard_AuctionHouseUI()
    --出售页面，买卖，物品信息 Blizzard_AuctionHouseSellFrame.lua
    hooksecurefunc(AuctionHouseSellFrameMixin, 'SetItem', function(self, itemLocation)
        WoWTools_ItemMixin:Setup(self.ItemDisplay.ItemButton, {itemLocation= itemLocation, size=12})
    end)

    hooksecurefunc(AuctionHouseFrame, 'SelectBrowseResult', function(self, browseResult)
        local itemKey = browseResult.itemKey
        local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey) or {}
        if itemKeyInfo.isCommodity then
            WoWTools_ItemMixin:Setup(self.CommoditiesBuyFrame.BuyDisplay.ItemDisplay.ItemButton, {itemKey= itemKey, size=12})
        else
            WoWTools_ItemMixin:Setup(self.ItemBuyFrame.ItemDisplay.ItemButton, {itemKey= itemKey, size=12})
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
local function Blizzard_ItemInteractionUI()
    add_Button_OpenOption(ItemInteractionFrameCloseButton)--添加一个按钮, 打开选项
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















local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_ItemInfo']= WoWToolsSave['Plus_ItemInfo'] or P_Save
            addName= '|A:Barbershop-32x32:0:0|a'..(WoWTools_DataMixin.onlyChinese and '物品信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEMS, INFO))

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= addName,
                tooltip= WoWTools_DataMixin.onlyChinese and '系统背包|n商人' or (BAGSLOT..'|n'..MERCHANT),--'Inventorian, Baggins', 'Bagnon'
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(WoWTools_DataMixin.Icon.icon2..addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if Save().disabled then
                self:UnregisterAllEvents()
            else
                Init()

                if C_AddOns.IsAddOnLoaded('Blizzard_PerksProgram') then
                    Blizzard_PerksProgram()
                end
                if C_AddOns.IsAddOnLoaded('Blizzard_WeeklyRewards') then
                    Blizzard_WeeklyRewards()
                end
                if C_AddOns.IsAddOnLoaded('Blizzard_AuctionHouseUI') then
                    Blizzard_AuctionHouseUI()
                end
                if C_AddOns.IsAddOnLoaded('Blizzard_ItemInteractionUI') then
                    Blizzard_ItemInteractionUI()
                end
                if C_AddOns.IsAddOnLoaded('Blizzard_ItemUpgradeUI') then
                    add_Button_OpenOption(ItemUpgradeFrameCloseButton)
                end

                for classID= 1, GetNumClasses() do
                    local classInfo = C_CreatureInfo.GetClassInfo(classID)
                    if classInfo and classInfo.className and classInfo.classFile then
                        ClassNameIconTab[classInfo.className]= WoWTools_UnitMixin:GetClassIcon(classInfo.classFile)--职业图标
                    end
                end
            end


        elseif arg1=='Blizzard_PerksProgram' then
            Blizzard_PerksProgram()

        elseif arg1=='Blizzard_WeeklyRewards' then
            Blizzard_WeeklyRewards()

        elseif arg1=='Blizzard_AuctionHouseUI' then
            Blizzard_AuctionHouseUI()

        elseif arg1=='Blizzard_ItemInteractionUI' then--套装转换, 界面
            Blizzard_ItemInteractionUI()


        elseif arg1=='Blizzard_ItemUpgradeUI' then--装备升级, 界面
            add_Button_OpenOption(ItemUpgradeFrameCloseButton)--添加一个按钮, 打开选项                       
        end
    end
end)