
if WoWTools_AuctionHouseMixin.disabled then
    return
end






local function Set_BrowseResultsFrame(frame)
    if not frame:HasView() then
        return
    end
    for _, btn in pairs(frame:GetFrames() or {}) do
        local text
        local stats
        local itemKey= btn.rowData.itemKey

--itemID battlePetSpeciesID itemName battlePetLink appearanceLink quality iconFileID isPet isCommodity isEquipment
        local itemKeyInfo = itemKey and C_AuctionHouse.GetItemKeyInfo(itemKey)
        if itemKeyInfo then
            local classID= C_Item.GetItemInfoInstant(itemKeyInfo.itemID)
            local itemLink= WoWTools_AuctionHouseMixin:GetItemLink(btn.rowData)
--宠物
            local isCollectedAll
            text, isCollectedAll= select(3, WoWTools_PetBattleMixin:Collected(itemKeyInfo.battlePetSpeciesID, itemKeyInfo.itemID, true))
            if isCollectedAll then
                text= '|A:common-icon-checkmark-yellow:0:0|a'
            end
--物品是否收
            if not text then
                text= WoWTools_CollectedMixin:Item(itemKeyInfo.itemID, nil, true)
            end
--坐骑
            if not text then
                local isMountCollected= select(2, WoWTools_CollectedMixin:Mount(nil, itemKeyInfo.itemID))
                if isMountCollected==true then
                    text= '|A:common-icon-checkmark-yellow:0:0|a'
                elseif isMountCollected==false then
                    text= '|A:QuestNormal:0:0|a'
                end
            end
--玩具,是否收集
            if not text then
                local isToy= select(2, WoWTools_CollectedMixin:Toy(itemKeyInfo.itemID))
                if isToy==true then
                    text= '|A:common-icon-checkmark-yellow:0:0|a'
                elseif isToy==false then
                    text= '|A:QuestNormal:0:0|a'
                end
            end
--显示, 宝石, 属性
            if not text and classID==3 then
                local t1, t2= WoWTools_ItemMixin:SetGemStats(nil, itemLink)
                if t1 then
                    text= t1..(t2 and ' '..t2 or '')
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
--属性
            if itemKeyInfo.isEquipment and itemLink then
                for _, tab in pairs(WoWTools_ItemMixin:GetItemStats(itemLink) or {}) do
                    stats= (stats and stats..' ' or '')..tab.text
                end
--宝石插槽
                local numSockets= C_Item.GetItemNumSockets(itemLink or itemKeyInfo.itemID) or 0--MAX_NUM_SOCKETS
                for n= 1, numSockets do
                    text= (stats or '')..'|A:socket-cogwheel-closed:0:0|a'
                end
            end
        end

--各种提示
        if text and not btn.lable then
            btn.lable= btn:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
        end
        if btn.lable then
            btn.lable:SetPoint('RIGHT', btn.cells[2].Icon, 'LEFT')
            btn.lable:SetText(text or '')
        end
--自已出售，物品
        local isOwnerItem= btn.rowData.containsOwnerItem
        if btn.rowData and isOwnerItem and not btn.OwnerItemTexture then
            btn.OwnerItemTexture= btn:CreateTexture(nil, 'ARTWORK')
            btn.OwnerItemTexture:SetSize(14,14)
            btn.OwnerItemTexture:SetAtlas(WoWTools_DataMixin.Icon.Player:match('|A:(.-):'))
        end
        if btn.OwnerItemTexture then
            btn.OwnerItemTexture:SetPoint('RIGHT', btn.cells[4].FavoriteButton, 'LEFT')
            btn.OwnerItemTexture:SetShown(isOwnerItem)
        end
--属性
        if stats and not btn.statsLabel then
            btn.statsLabel= btn:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
            btn.statsLabel:SetJustifyH('RIGHT')
        end
        if btn.statsLabel then
            btn.statsLabel:SetPoint('RIGHT', btn.cells[2])
            btn.statsLabel:SetText(stats)
        end
    end
end





local function Set_ItemBuyFrame(frame)
     if not frame:HasView() then
        return
    end
    for _, btn in pairs(frame:GetFrames() or {}) do
        local stats
        local itemKey= btn.rowData.itemKey
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
        if btn.rowData.containsOwnerItem then
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


    WoWTools_DataMixin:Hook(AuctionHouseFrame.BrowseResultsFrame.ItemList.ScrollBox, 'Update', function(...)
        Set_BrowseResultsFrame(...)
    end)
    WoWTools_DataMixin:Hook(AuctionHouseFrame.BrowseResultsFrame.ItemList.ScrollBox, 'SetDataProvider', function(...)
        Set_BrowseResultsFrame(...)
    end)

    WoWTools_DataMixin:Hook(AuctionHouseFrame.ItemBuyFrame.ItemList.ScrollBox, 'Update', function(...)
        Set_ItemBuyFrame(...)
    end)
    WoWTools_DataMixin:Hook(AuctionHouseFrame.ItemBuyFrame.ItemList.ScrollBox, 'SetDataProvider', function(...)
        Set_ItemBuyFrame(...)
    end)

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
        WoWTools_ItemMixin:SetupInfo(frame.ItemDisplay.ItemButton, {itemLocation= itemLocation, size=12})
    end)

--购买，选定物品 AuctionHouseFrame.ItemBuyFrame.ItemDisplay.ItemButton
    WoWTools_DataMixin:Hook(AuctionHouseFrame, 'SelectBrowseResult', function(frame, browseResult)
        local itemKey = browseResult.itemKey
        local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey) or {}

        local f= itemKeyInfo.isCommodity and frame.CommoditiesBuyFrame.BuyDisplay.ItemDisplay or frame.ItemBuyFrame.ItemDisplay

        WoWTools_ItemMixin:SetupInfo(f.ItemButton, {itemKey= itemKey, size=12})

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