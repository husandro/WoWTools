
--local bgAtlas = "|A:socket-%s-background:0:0|a"
--local closedBracketAtlas = "|A:socket-%s-closed:0:0|a"
--local openBracketAtlas = "socket-%s-open"

local GEM_TYPE_INFO={
['EMPTY_SOCKET_BLUE'] = "blue",-- "蓝色插槽";
['EMPTY_SOCKET_COGWHEEL'] = 'cogwheel',--"齿轮插槽";
['EMPTY_SOCKET_CYPHER'] = 'meta',--"晶态插槽"
['EMPTY_SOCKET_DOMINATION'] = 'domination',--"统御插槽";
['EMPTY_SOCKET_FIBER'] = 'hydraulic',-- "纤维镶孔";
['EMPTY_SOCKET_FRAGRANCE'] = 'hydraulic',--"芬芳镶孔";
['EMPTY_SOCKET_HYDRAULIC'] = 'hydraulic',--"染煞";
['EMPTY_SOCKET_META'] = 'meta', --"多彩插槽";
['EMPTY_SOCKET_PRIMORDIAL'] = 'meta',--"始源镶孔";
['EMPTY_SOCKET_PRISMATIC'] = 'prismatic', --"棱彩插槽";
['EMPTY_SOCKET_PUNCHCARDBLUE'] = 'punchcard-blue',-- "蓝色打孔卡插槽";
['EMPTY_SOCKET_PUNCHCARDRED'] = 'punchcard-red',-- "红色打孔卡插槽";
['EMPTY_SOCKET_PUNCHCARDYELLOW'] = 'punchcard-yellow', "黄色打孔卡插槽";
['EMPTY_SOCKET_RED'] = 'red',-- "红色插槽";
['EMPTY_SOCKET_SINGINGSEA'] =  'blue',--"吟海插槽";
['EMPTY_SOCKET_SINGINGTHUNDER'] = 'yellow',-- "吟雷插槽";
['EMPTY_SOCKET_SINGINGWIND'] = 'red', --"吟风插槽";
['EMPTY_SOCKET_TINKER'] = 'punchcard-red',--"匠械插槽";
['EMPTY_SOCKET_YELLOW'] = 'yellow',--"黄色插槽";
}
--[EMPTY_SOCKET_SINGING_SEA] = 'blue',--"吟海插槽";
--[EMPTY_SOCKET_SINGING_THUNDER] = 'yellow',--"吟雷插槽";
--[EMPTY_SOCKET_SINGING_WIND] =  'red', --"吟风插槽";

--[ITEM_MOD_HASTE_RATING_SHORT]= WoWTools_DataMixin.onlyChinese and '急' or WoWTools_TextMixin:sub(ITEM_MOD_HASTE_RATING_SHORT, 1, 2, true),





--物品, 宝石插槽, 属性
local function Get_StatsGem(itemID, itemLink)
    local numSockets= C_Item.GetItemNumSockets(itemLink or itemID) or 0--MAX_NUM_SOCKETS
    local gem
    local stats={}
    local rep= 0

    if itemLink then
        local find= 0
        for s, value in pairs(C_Item.GetItemStats(itemLink) or {}) do

            if GEM_TYPE_INFO[s] then
                gem= string.rep(format('|A:socket-%s-background:0:0|a', GEM_TYPE_INFO[s]), value)..(gem or '')
                find= find+ value

            else
                local g= _G[s]
                local text= WoWTools_DataMixin.StausText[g]
                if text then
                    if g==ITEM_MOD_MODIFIED_CRAFTING_STAT_1 or g==ITEM_MOD_MODIFIED_CRAFTING_STAT_2 then--随机
                        text= DISABLED_FONT_COLOR:WrapTextInColorCode(text)
                    end
                    table.insert(stats, text)
                end
            end
        end
        rep= numSockets-find
    else

        rep= numSockets
    end

    if rep>0 then
        gem= string.rep('|A:socket-cogwheel-closed:0:0|a', rep)..(gem or '')
    end

    return (select(2, C_Item.GetItemSpell(itemLink or itemID)) and '|A:soulbinds_tree_conduit_icon_utility:0:0|a' or '')
        ..(gem or '')
        ..table.concat(stats, PLAYER_LIST_DELIMITER)
end










local function Get_Stat(itemLink)
    local tab= {}
    for text in pairs(C_Item.GetItemStats(itemLink) or {}) do
        local g= _G[text] or text

        local t= WoWTools_DataMixin.StausText[g]
        if t then
            table.insert(tab, t)
        else
            t= WoWTools_TextMixin:CN(g)
            t= WoWTools_TextMixin:sub(t, 1, 3, true)
            table.insert(tab, t)
        end

    end
    return table.concat(tab, PLAYER_LIST_DELIMITER)
end







local function Get_Item(btn)
    local text, stats
    local rowData= btn:GetRowData()
    if not rowData then
        return
    end

    local itemLink, itemID= WoWTools_AuctionHouseMixin:GetItemLink(rowData)
    local itemKey= rowData.itemKey
    local itemKeyInfo = itemKey and C_AuctionHouse.GetItemKeyInfo(itemKey)


    if not itemLink or not itemID or not itemKeyInfo then
        return
    end

--itemID battlePetSpeciesID itemName battlePetLink appearanceLink quality iconFileID isPet isCommodity isEquipment
    --local itemKeyInfo = itemKey and C_AuctionHouse.GetItemKeyInfo(itemKey)
    --if itemKeyInfo then

    local classID= select(6, C_Item.GetItemInfoInstant(itemID))


--专业装备
    if classID==19 then
        text= WoWTools_CollectionMixin:Item(itemLink or itemID, nil, true)
        stats= Get_Stat(itemLink)

--配方 是否，学习
    elseif classID==9 then
        local redInfo= WoWTools_ItemMixin:GetTooltip({
            itemKey=itemKey,
            red=true,
            text={ITEM_SPELL_KNOWN},
        })
        if redInfo.text[ITEM_SPELL_KNOWN] then
            text= '|A:CovenantSanctum-Renown-Checkmark-Large:0:0|a'
        elseif redInfo.red then
            text= '|A:worldquest-icon-firstaid:0:0|a'
        end

--背包, 多少格
    elseif classID==1 then
        local dateInfo= WoWTools_ItemMixin:GetTooltip({itemID=itemID, hyperLink=itemLink, index=3})
        local indexText= dateInfo.indexText
        if indexText then
            text= indexText:match('%d+')
        end

--显示, 宝石, 属性
    elseif classID==3 then
        local t1, t2= WoWTools_ItemMixin:SetGemStats(nil, itemLink)
        if t1 then
            stats= t1..(t2 and PLAYER_LIST_DELIMITER..t2 or '')
        end

--住宅
    elseif C_Item.IsDecorItem(itemID) then
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
    elseif itemKeyInfo.isPet then
        local isCollectedAll, CollectedNum
        CollectedNum, text, isCollectedAll= select(2, WoWTools_PetBattleMixin:Collected(itemKeyInfo.battlePetSpeciesID, itemID))
        if isCollectedAll then
            stats= (CollectedNum or '')..' '..text
            text= '|A:CovenantSanctum-Renown-Checkmark-Large:0:0|a'
        end
        stats= CollectedNum
--幻化
    elseif C_Item.IsCosmeticItem(itemLink or itemID) then
        text= WoWTools_CollectionMixin:Item(itemID, nil, true)
        stats= (WoWTools_ItemMixin:GetCount(itemID, {notZero= true}) or '')..'|A:transmog-gearSlot-transmogrified-HL:0:0|a'

--物品，属性, 宝石, 幻化
    elseif itemKeyInfo.isEquipment then
        text= WoWTools_CollectionMixin:Item(itemID, nil, true)
        stats= Get_StatsGem(itemID, itemLink)


--玩具,是否收集    
    elseif C_ToyBox.GetToyInfo(itemID) then
        text= select(3, WoWTools_CollectionMixin:Toy(itemID))
        stats= WoWTools_ItemMixin:GetCount(itemID, {notZero= true})

--商品
    --elseif itemKeyInfo.isCommodity then


    else
--坐骑
        text= select(3, WoWTools_CollectionMixin:Mount(nil, itemID))

        stats= WoWTools_ItemMixin:GetCount(itemID, {notZero= true})
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


--[[local function Load_Item(btn, itemKey)
    if itemKey.itemID then--and not C_Item.IsItemDataCachedByID(itemKey.itemID) then
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
end]]





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
                    stats= table.concat(WoWTools_ItemMixin:GetItemStats(itemLink), PLAYER_LIST_DELIMITER)
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
  --[[
--AuctionHouseItemListMixin:Init()
print(AuctionHouseFrame.BrowseResultsFrame.ItemList.tableBuilder)
    if AuctionHouseFrame.BrowseResultsFrame.ItemList.tableBuilder then
        print('a', AuctionHouseFrame.BrowseResultsFrame.ItemList.tableBuilder:AddColumnInternal(AuctionHouseFrame.BrowseResultsFrame.ItemList, 0, 50, 0, 10, nil, "AuctionHouseTableCellTimeLeftTemplate"))
    end
  
AuctionHouseTableCellTextTemplate
tableBuilder:AddFixedWidthColumn(owner, 0, 50, 0, STANDARD_PADDING, Enum.AuctionHouseSortOrder.TimeRemaining, "AuctionHouseTableCellTimeLeftTemplate");
                                 owner, padding, width, leftCellPadding, rightCellPadding, sortOrder, cellTemplate, ...
]]
    ScrollUtil.RegisterAlternateRowBehavior(AuctionHouseFrame.BrowseResultsFrame.ItemList.ScrollBox, function(btn)
        local rowData= btn:GetRowData()
        if not rowData then
            return
        end

        if not btn.OwnerItemTexture then
            Create_Label(btn)
        end

        ItemEventListener:AddCancelableCallback(rowData.itemKey.itemID, function()
            Set_Button(btn)
        end)
    end)

    --WoWTools_DataMixin:Hook(AuctionHouseFrame.BrowseResultsFrame.ItemList.ScrollBox, 'Update', Set_BrowseResultsFrame)
   --WoWTools_DataMixin:Hook(AuctionHouseFrame.BrowseResultsFrame.ItemList.ScrollBox, 'SetDataProvider', Set_BrowseResultsFrame)
    --WoWTools_DataMixin:Hook(AuctionHouseFrame.BrowseResultsFrame.ItemList.ScrollBox, 'SetScrollTargetOffset', Set_BrowseResultsFrame)

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