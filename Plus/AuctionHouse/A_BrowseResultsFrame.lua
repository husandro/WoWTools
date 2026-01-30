
local function Get_Item(btn)
    local text, stats
    local itemLink, itemID, itemKey, battlePetSpeciesID= WoWTools_AuctionHouseMixin:GetItemLink(btn.rowData)
  

    if not itemLink or not itemID then
        return
    end

        --local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey)
--itemID battlePetSpeciesID itemName battlePetLink appearanceLink quality iconFileID isPet isCommodity isEquipment
    --local itemKeyInfo = itemKey and C_AuctionHouse.GetItemKeyInfo(itemKey)
    --if itemKeyInfo then

        local classID= select(6, C_Item.GetItemInfoInstant(itemID))

        if C_Item.IsDecorItem(itemID) then

            local entryInfo= C_HousingCatalog.GetCatalogEntryInfoByItem(itemLink or itemID, true)
            if entryInfo then
--装饰放置成本
                if entryInfo.placementCost then
                    stats= format('|cffffffff%d|r|A:House-Decor-budget-icon:0:0|a', entryInfo.placementCost)
                end
--室内, 室外
                if entryInfo.isAllowedIndoors then
                    stats= (stats or '')..'|A:house-room-limit-icon:0:0|a'
                end
                if entryInfo.isAllowedOutdoors then
                    stats= (stats or '')..'|A:house-outdoor-budget-icon:0:0|a'
                end

--无法被摧毁
                if C_HousingCatalog.CanDestroyEntry(entryInfo.entryID)==false then
                    text= '|A:Objective-Fail:0:0|a'
                end

--XP
                if entryInfo.firstAcquisitionBonus and entryInfo.firstAcquisitionBonus>0 then
                     text= (text or '')..'|A:GarrMission_CurrencyIcon-Xp:0:0|a'
                else--if entryInfo.showQuantity then
--数量
                    local num= (entryInfo.numPlace or 0) + (entryInfo.quality or 0)+ (entryInfo.remainingRedeemable or 0)
                    text= num..'|A:house-chest-icon:0:0|a'
                    if num==0 then
                        text= DISABLED_FONT_COLOR:WrapTextInColorCode(num)
                    end
                end
            end

--宠物
        elseif battlePetSpeciesID and battlePetSpeciesID>0 then
            local isCollectedAll
            text, isCollectedAll= select(3, WoWTools_PetBattleMixin:Collected(battlePetSpeciesID, itemID, true))
            if isCollectedAll then
                text= '|A:common-icon-checkmark-yellow:0:0|a'
            end

--显示, 宝石, 属性
        elseif classID==3 then
            local t1, t2= WoWTools_ItemMixin:SetGemStats(nil, itemLink)
            if t1 then
                text= t1..(t2 and PLAYER_LIST_DELIMITER..t2 or '')
            end
--玩具,是否收集    
        elseif C_ToyBox.GetToyInfo(itemID) then
            local isToy= select(2, WoWTools_CollectionMixin:Toy(itemID))
            if isToy==true then
                text= '|A:common-icon-checkmark-yellow:0:0|a'
            elseif isToy==false then
                text= '|A:QuestNormal:0:0|a'
            end
        end

--物品，属性
        for _, tab in pairs(WoWTools_ItemMixin:GetItemStats(itemLink) or {}) do
            stats= (stats and stats..PLAYER_LIST_DELIMITER or '')..tab.text
        end
--物品, 宝石插槽
        local numSockets= C_Item.GetItemNumSockets(itemLink or itemID) or 0--MAX_NUM_SOCKETS
        for n= 1, numSockets do
            stats= '|A:socket-cogwheel-closed:0:0|a'..(stats or '')
        end


--物品是否收
        local isCollectedText= WoWTools_CollectionMixin:Item(itemID, nil, true)
        if isCollectedText then
            text= WoWTools_CollectionMixin:Item(itemID, nil, true)..(text or '')
        end

--坐骑
        local isMountCollected= select(2, WoWTools_CollectionMixin:Mount(nil, itemID))
        if isMountCollected~=nil then
            if isMountCollected==true then
                text= '|A:common-icon-checkmark-yellow:0:0|a'..(text or '')
            elseif isMountCollected==false then
                text= '|A:QuestNormal:0:0|a'..(text or '')
            end
        end


    --是否，学习
        if not text then
            local redInfo= WoWTools_ItemMixin:GetTooltip({
                itemKey=itemKey,
                red=true,
                text={ITEM_SPELL_KNOWN},
            })
            if redInfo.text[ITEM_SPELL_KNOWN] then
                text= '|A:common-icon-checkmark:0:0|a'
            elseif redInfo.red then
                text= '|A:worldquest-icon-firstaid:0:0|a'
            else
                text= '|A:Recurringavailablequesticon:0:0|a'
            end
        end

    return text, stats
end

local function Set_Button(btn)
    local text, stats= Get_Item(btn)

--各种提示
    btn.lable:SetPoint('RIGHT', btn.cells[2].Icon, 'LEFT')
    btn.lable:SetText(text or '')

--自已出售，物品
    local isOwnerItem= btn.rowData and btn.rowData.containsOwnerItem
    btn.OwnerItemTexture:SetPoint('RIGHT', btn.cells[4].FavoriteButton, 'LEFT')
    btn.OwnerItemTexture:SetShown(isOwnerItem)

--属性
    btn.statsLabel:SetPoint('RIGHT', btn.cells[2])
    btn.statsLabel:SetText(stats)
end

local function Create_Label(btn)
--各种提示
    btn.lable= btn:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
    btn.lable:SetPoint('RIGHT', btn.cells[2].Icon, 'LEFT')

--自已出售，物品
    btn.OwnerItemTexture= btn:CreateTexture(nil, 'ARTWORK')
    btn.OwnerItemTexture:SetSize(14,14)
    btn.OwnerItemTexture:SetAtlas(WoWTools_DataMixin.Icon.Player:match('|A:(.-):'))
    btn.OwnerItemTexture:SetPoint('RIGHT', btn.cells[4].FavoriteButton, 'LEFT')

--属性
    btn.statsLabel= btn:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
    btn.statsLabel:SetJustifyH('RIGHT')
    btn.statsLabel:SetPoint('RIGHT', btn.cells[2])
end


local function Load_Item(btn, itemKey)
    if itemKey.itemID and not C_Item.IsItemDataCachedByID(itemKey.itemID) then
        ItemEventListener:AddCancelableCallback(itemKey.itemID, function()
            if btn.rowData and btn.rowData.itemKey and btn.rowData.itemKey.itemID==itemKey.itemID then
                Set_Button(btn)
            end
        end)
    end
end


local function Set_BrowseResultsFrame(frame)
    if not frame:HasView() then
        return
    end

    for _, btn in pairs(frame:GetFrames() or {}) do
        if btn.rowData and btn.rowData.itemKey then
            if not btn.OwnerItemTexture then
                Create_Label(btn)
            end
            Set_Button(btn)

            Load_Item(btn, btn.rowData.itemKey)
        end
    end
end





local function Set_ItemBuyFrame(frame)
     if not frame:HasView() then
        return
    end
    for _, btn in pairs(frame:GetFrames() or {}) do
        local stats
        local itemKey= btn.rowData and btn.rowData.itemKey
--itemID battlePetSpeciesID itemName battlePetLink appearanceLink quality iconFileID isPet isCommodity isEquipment
        local itemKeyInfo = itemKey and C_AuctionHouse.GetItemKeyInfo(itemKey)
        if itemKeyInfo then
            if itemKeyInfo.isEquipment then-- (classID==2 or classID==4) then
                local itemLink= btn.rowData.itemLink
                if not itemLink then
                    local data= C_TooltipInfo.GetItemKey(itemKey.itemID, itemKey.itemLevel, itemKey.itemSuffix, C_AuctionHouse.GetItemKeyRequiredLevel(itemKey))
                    itemLink= data and data.hyperlink
                end
                if itemLink then
                    for _, tab in pairs(WoWTools_ItemMixin:GetItemStats(itemLink) or {}) do
                        stats= (stats and stats..' ' or '')..tab.text
                    end
                end
            end
        end
--自已出售，物品
        if btn.rowData and btn.rowData.containsOwnerItem then
            stats= WoWTools_DataMixin.Icon.Player..(stats or '')
        end
--属性
        if stats and not btn.statsLabel then
            btn.statsLabel= btn:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
        end
        if btn.statsLabel then
            btn.statsLabel:SetPoint('LEFT', btn.cells[2].Checkmark, 'RIGHT', 4, 0)
            btn.statsLabel:SetText(stats)
        end

    end
end





--[[浏览拍卖行
Blizzard_AuctionHouseUI.lua
local ITEM_SPELL_KNOWN = ITEM_SPELL_KNOWN--"已学习
AuctionHouseItemListMixin
AuctionHouseItemListLineMixin
]]
local function Init()
    if WoWToolsSave['Plus_AuctionHouse'].disabledBuyPlus then
        return
    end


    WoWTools_DataMixin:Hook(AuctionHouseFrame.BrowseResultsFrame.ItemList.ScrollBox, 'Update', Set_BrowseResultsFrame)
   --WoWTools_DataMixin:Hook(AuctionHouseFrame.BrowseResultsFrame.ItemList.ScrollBox, 'SetDataProvider', Set_BrowseResultsFrame)
    WoWTools_DataMixin:Hook(AuctionHouseFrame.BrowseResultsFrame.ItemList.ScrollBox, 'SetScrollTargetOffset', Set_BrowseResultsFrame)

    WoWTools_DataMixin:Hook(AuctionHouseFrame.ItemBuyFrame.ItemList.ScrollBox, 'Update', Set_ItemBuyFrame)
    --WoWTools_DataMixin:Hook(AuctionHouseFrame.ItemBuyFrame.ItemList.ScrollBox, 'SetDataProvider', Set_ItemBuyFrame)
    WoWTools_DataMixin:Hook(AuctionHouseFrame.ItemBuyFrame.ItemList.ScrollBox, 'SetScrollTargetOffset', Set_ItemBuyFrame)

    --双击，一口价
    WoWTools_DataMixin:Hook(AuctionHouseFrame.ItemBuyFrame.ItemList.ScrollBox, 'Update', function(frame)
        if not frame:HasView() then
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

    --购买，数量
    AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.QuantityInput.InputBox:HookScript('OnShow', function(self)
        if not self:HasText() then
            self:SetText(1)
        end
    end)


--出售页面，买卖，物品信息 Blizzard_AuctionHouseSellFrame.lua
    WoWTools_DataMixin:Hook(AuctionHouseSellFrameMixin, 'SetItem', function(frame, itemLocation)
        WoWTools_ItemMixin:SetupInfo(frame.ItemDisplay.ItemButton, itemLocation and {itemLocation= itemLocation, size=2} or nil)
    end)

--购买，选定物品 AuctionHouseFrame.ItemBuyFrame.ItemDisplay.ItemButton
    WoWTools_DataMixin:Hook(AuctionHouseFrame, 'SelectBrowseResult', function(frame, browseResult)
        local itemKey = browseResult.itemKey
        local itemKeyInfo = itemKey and C_AuctionHouse.GetItemKeyInfo(itemKey) or {}

        local f= itemKeyInfo.isCommodity and frame.CommoditiesBuyFrame.BuyDisplay.ItemDisplay or frame.ItemBuyFrame.ItemDisplay

        WoWTools_ItemMixin:SetupInfo(f.ItemButton, itemKey and {itemKey= itemKey, size=2} or nil)

        if not f.countLable then
            f.countLable= f:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
            f.countLable:SetPoint('BOTTOM', f, 'TOP')
        end

        f.countLable:SetText(WoWTools_ItemMixin:GetCount(itemKey.itemID) or '')
    end)

    Init=function()end
end










function WoWTools_AuctionHouseMixin:Init_BrowseResultsFrame()
    Init()
end