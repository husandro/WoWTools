--[[
WoWTools_ItemMixin:SetupInfo(itemButton, {
    itemLink= ,
    hyperlink=,
    lootIndex= , 
    bag= {bag=bagID, slot=slotID},
    merchant= {slot=slot, buyBack= selectedTab==2},
    guidBank= {tab=tab, slot=i},
    itemLocation=,
    itemKey=,
    

    point= region,
    size=
})
]]
local function Save()
    return WoWToolsSave['Plus_ItemInfo']
end


local chargesStr= ITEM_SPELL_CHARGES:gsub('%%d', '%(%%d%+%)')--(%d+)次
local keyStr= format(CHALLENGE_MODE_KEYSTONE_NAME,'(.+) ')--钥石
local equipStr= WoWTools_TextMixin:Magic(EQUIPMENT_SETS)--:gsub('|cFFFFFFFF', ''):gsub('|r', ''))
local pvpItemStr= PVP_ITEM_LEVEL_TOOLTIP:gsub('%%d', '%(%%d%+%)')--"装备：在竞技场和战场中将物品等级提高至%d。"
local upgradeStr= ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT:gsub('%%s/%%s','(.-%%d%+/%%d%+)')-- "升级：%s/%s"
local classStr= format(ITEM_CLASSES_ALLOWED, '(.+)') --"职业：%s"
local itemLevelStr= ITEM_LEVEL:gsub('%%d', '%(%%d%+%)')--"物品等级：%d"

local useStr=ITEM_SPELL_TRIGGER_ONUSE..'(.+)'--使用：
local ITEM_SPELL_KNOWN= ITEM_SPELL_KNOWN

--local size= 10--字体大小

local heirloomWeapontemEquipLocTab={--传家宝 ，武器，itemEquipLoc
    ['INVTYPE_WEAPON']= true,
    ['INVTYPE_2HWEAPON']= true,
    ['INVTYPE_RANGED']= true,
    ['INVTYPE_RANGEDRIGHT']= true,
}




local ClassNameIconTab={}--职业图标 ClassNameIconTab['法师']=图标
local FMTab={}--附魔

EventRegistry:RegisterFrameEventAndCallback('PLAYER_ENTERING_WORLD', function(owner)
    for classID= 1, GetNumClasses() do
        local classInfo = C_CreatureInfo.GetClassInfo(classID)
        if classInfo and classInfo.className and classInfo.classFile then
            ClassNameIconTab[classInfo.className]= WoWTools_UnitMixin:GetClassIcon(nil, nil, classInfo.classFile)--职业图标
        end
    end

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
    EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
end)



--[[local function Get_Class_Icon_da_Text(text)
    local t
    if text then
        for name, icon in pairs(ClassNameIconTab) do
            if text:find(name) then
                t= (t or '')..icon
            end
        end
    end
    return t
end]]




--已收集, 未收集
local function get_has_text(has)
    if has then
        return format('|cnWARNING_FONT_COLOR:%s|r',  WoWTools_DataMixin.onlyChinese and '已收集' or WoWTools_TextMixin:sub(COLLECTED, 3, 5, true))
    elseif has~=nil then
        return format('|cnGREEN_FONT_COLOR:%s|r',  WoWTools_DataMixin.onlyChinese and '未收集' or WoWTools_TextMixin:sub(NOT_COLLECTED, 3, 5, true))
    end
end






--装等，提示
local function get_itemLeve_color(itemLink, itemLevel, itemEquipLoc, itemQuality, upItemLevel)
    if not itemLevel or itemLevel==1 then
        return
    end

    local invSlot = WoWTools_ItemMixin:GetEquipSlotID(itemEquipLoc)
    if not invSlot then
        return itemLevel
    end

    local isTimerunning= PlayerIsTimerunning()

    local upLevel, downLevel
    local itemLinkPlayer =  GetInventoryItemLink('player', invSlot)
    if itemLinkPlayer then
        if isTimerunning then
            local numItem, numPlayer= 0, 0
            for _, num in pairs(C_Item.GetItemStats(itemLink) or {}) do
                numItem= numItem +num
            end
            for _, num in pairs(C_Item.GetItemStats(itemLinkPlayer) or {}) do
                numPlayer= numPlayer +num
            end
            upLevel= numItem>numPlayer
            downLevel= numItem<numPlayer
        else
            local equipedLevel= C_Item.GetDetailedItemLevelInfo(itemLinkPlayer)
            if equipedLevel then
                local equipedInfo= WoWTools_ItemMixin:GetTooltip({hyperLink=itemLinkPlayer, text={upgradeStr}, onlyText=true})--物品提示，信息
                if equipedInfo.text[upgradeStr] then--"升级：%s/%s"
                    local min, max= equipedInfo.text[upgradeStr]:match('(%d+)/(%d+)')
                    if min and max and min<max then
                        min, max= tonumber(min) or 0, tonumber(max) or 0
                        equipedLevel=equipedLevel+ (max-min)*5--已装备，物品，总装等
                    end
                end

                local level= (itemLevel + upItemLevel*5) - equipedLevel
                if level> 5 then
                    upLevel=true
                elseif level< -5 then
                    downLevel=true
                else
                    local qualityPlayer= C_Item.GetItemQualityByID(itemLinkPlayer)
                    if qualityPlayer and itemQuality then
                        if qualityPlayer<itemQuality then
                            upLevel=true
                        elseif qualityPlayer>itemQuality then
                            downLevel=true
                        end
                    end
                end
            end
        end
    else
        upLevel=true
    end

    if upLevel or downLevel or isTimerunning then
        return (upLevel and '|cnGREEN_FONT_COLOR:' or (downLevel and '|cnWARNING_FONT_COLOR:') or  '|cffffffff')
                ..itemLevel..'|r'
    end
end


































local function Set_Label(label, tab)
    local font
    if WoWTools_DataMixin.onlyChinese and not LOCALE_zhCN then
        font= 'Fonts\\ARHei.ttf'
    else
        font= label:GetFont()
    end
    label:SetFont(font, tab.size, 'OUTLINE')
    label:SetTextColor(1,1,1,1)
end






local function Create_Label(frame, tab)
    tab= tab or {}
    if tab.size then
        tab.size= tab.size + (Save().size or 10)
    else
        tab.size= Save().size or 10
    end

    local font= 'ChatFontNormal'--'SystemFont_Shadow_Small_Outline'
    local layer= 'OVERLAY'

--右边
    frame.topRightText= frame:CreateFontString(nil, layer, font)--WoWTools_LabelMixin:Create(frame, labelInfo)
    frame.topRightText:SetPoint('TOPRIGHT', tab.point or frame, 2, 1)
    Set_Label(frame.topRightText, tab)
    frame.topRightText:SetJustifyH('RIGHT')

    frame.rightText= frame:CreateFontString(nil, layer, font)--WoWTools_LabelMixin:Create(frame, labelInfo)
    frame.rightText:SetPoint('RIGHT', tab.point or frame, 2, 0)
    Set_Label(frame.rightText, tab)
    frame.rightText:SetJustifyH('RIGHT')

    frame.bottomRightText= frame:CreateFontString(nil, layer, font)--WoWTools_LabelMixin:Create(frame, labelInfo)
    frame.bottomRightText:SetPoint('BOTTOMRIGHT', tab.point or frame, 2, -1)
    Set_Label(frame.bottomRightText, tab)
    frame.bottomRightText:SetJustifyH('RIGHT')

--左边
    frame.topLeftText= frame:CreateFontString(nil, layer, font) --WoWTools_LabelMixin:Create(frame, labelInfo)
    frame.topLeftText:SetPoint('TOPLEFT', tab.point or frame, -2, 1)
    Set_Label(frame.topLeftText, tab)

    frame.leftText= frame:CreateFontString(nil, layer, font)--WoWTools_LabelMixin:Create(frame, labelInfo)
    frame.leftText:SetPoint('LEFT', tab.point or frame, -2, 0)
    Set_Label(frame.leftText, tab)

    frame.bottomLeftText=frame:CreateFontString(nil, layer, font)--WoWTools_LabelMixin:Create(frame, labelInfo)
    frame.bottomLeftText:SetPoint('BOTTOMLEFT', tab.point or frame, -2, -1)
    Set_Label(frame.bottomLeftText, tab)

    frame.setIDItem=frame:CreateTexture()
    frame.setIDItem:SetPoint('TOPLEFT', -4, 4)
    frame.setIDItem:SetPoint('BOTTOMRIGHT', 4, -4)
    frame.setIDItem:SetAtlas('UI-HUD-MicroMenu-Highlightalert')

    if frame.Count then
        frame.Count:ClearAllPoints()
        frame.Count:SetPoint('BOTTOMRIGHT')
    end
end

local function Clear_Label(frame)
    if frame.topLeftText then
        frame.topLeftText:SetText('')
        frame.leftText:SetText('')
        frame.bottomLeftText:SetText('')
        frame.topRightText:SetText('')
        frame.rightText:SetText('')
        frame.bottomRightText:SetText('')
        frame.setIDItem:Hide()
    end
end
































local function Get_Info(tab)

    local itemLevel, itemQuality, battlePetSpeciesID, itemLink, containerInfo, itemID, isBound
    local topLeftText, bottomRightText, leftText, rightText, bottomLeftText, topRightText, setIDItem--setIDItem套装
    local currencyID

    if tab.itemLink or tab.hyperlink then
        itemLink= tab.itemLink or tab.hyperlink
        itemID= tab.itemID

    elseif tab.lootIndex then
        currencyID= select(4, GetLootSlotInfo(tab.lootIndex))
        if currencyID then
            local info= C_CurrencyInfo.GetCurrencyInfo(currencyID) or {}
            if info.quantity and info.quantity>0 then
                topLeftText= WoWTools_DataMixin:MK(info.quantity, 3)
            end
            return topLeftText, leftText, bottomLeftText, topRightText, rightText, bottomRightText, setIDItem
        else
            itemLink= GetLootSlotLink(tab.lootIndex)
        end

    elseif tab.bag then
        containerInfo = C_Container.GetContainerItemInfo(tab.bag.bag or -1, tab.bag.slot or -1)
        if containerInfo then
            itemLink= containerInfo.hyperlink
            itemID= containerInfo.itemID
            isBound= containerInfo.isBound
        end

    elseif tab.merchant then
        if tab.merchant.buyBack then
            itemLink= GetBuybackItemLink(tab.merchant.slot)
        else
            itemLink= GetMerchantItemLink(tab.merchant.slot)
            itemID= GetMerchantItemID(tab.merchant.slot)
        end

    elseif tab.guidBank then
        itemLink= GetGuildBankItemLink(tab.guidBank.tab, tab.guidBank.slot)

    elseif tab.itemLocation and tab.itemLocation:IsValid() then
        itemLink= C_Item.GetItemLink(tab.itemLocation)
        itemID= C_Item.GetItemID(tab.itemLocation)

    elseif tab.itemKey then
        local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(tab.itemKey) or {}
        itemID= tab.itemKey.itemID or itemKeyInfo.itemID
        itemLevel= tab.itemKey.itemLevel
        itemLink= itemKeyInfo.battlePetLink or WoWTools_ItemMixin:GetLink(itemID)
        itemQuality= itemKeyInfo.quality
        battlePetSpeciesID= tab.itemKey.battlePetSpeciesID

    elseif tab.itemID then
        itemLink= select(2, C_Item.GetItemInfo(tab.itemID))
    end


    if not itemLink then
        return
    end


    itemID= itemID or WoWTools_ItemMixin:GetItemID(itemLink)

    local _, _, itemQuality2, itemLevel2, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, _, _, classID, subclassID, bindType, expacID, setID, isCraftingReagent = C_Item.GetItemInfo(itemLink)
    itemMinLevel= itemMinLevel or 1

--套装：炎阳珠衣装
    local transmogSetID= C_Item.GetItemLearnTransmogSet(itemLink)

    itemLevel= C_Item.GetDetailedItemLevelInfo(itemLink) or itemLevel or itemLevel2
    itemQuality= itemQuality or itemQuality2
    expacID= expacID or 0

--套装，传说5，神器6，传家宝，提示
    if itemQuality and itemQuality>=Enum.ItemQuality.Legendary or setID then
        setIDItem= itemQuality or true
    end
    --setIDItem= setID and true or ((itemQuality==Enum.ItemQuality.Legendary or itemQuality==Enum.ItemQuality.Artifact) and itemQuality) or nil

    local lowerVer= not PlayerIsTimerunning() and expacID< WoWTools_DataMixin.ExpansionLevel and itemID~='5512' and itemID~='113509'--低版本，5512糖 食物,113509[魔法汉堡]

    local sellItem
    if tab.bag and containerInfo and not containerInfo.isLocked then
        sellItem= WoWTools_MerchantMixin:CheckSellItem(itemID, itemLink, itemQuality, isBound)--检测是否是出售物品
    end

--检测是否是出售物品
    if sellItem then
        if itemQuality==0 then
            topRightText='|A:Coin-Silver:0:0|a'
        else
            topLeftText= itemLevel and itemLevel>20 and (classID==2 or classID==4) and itemLevel
            topRightText= '|T236994:0|t'
        end

--住宅装饰
    elseif C_Item.IsDecorItem(itemLink) then
        local entryInfo = C_HousingCatalog.GetCatalogEntryInfoByItem(itemLink, true)
        if entryInfo then

            --if entryInfo.canCustomize then
                topLeftText= '|A:housing-dyable-palette-icon:0:0|a'
            --end
            if entryInfo.isAllowedIndoors then
                leftText='|A:house-room-limit-icon:0:0|a'
            end
            if entryInfo.isAllowedOutdoors then
                bottomLeftText='|A:house-outdoor-budget-icon:0:0|a'
            end


            if entryInfo.placementCost then
                topRightText= entryInfo.placementCost..'|A:House-Decor-budget-icon:0:0|a'
            end
            if entryInfo.firstAcquisitionBonus>0 then
                rightText= '|A:GarrMission_CurrencyIcon-Xp:18:18:3|a'
            end
            if entryInfo.showQuantity and entryInfo.numPlaced and entryInfo.numStored then
                bottomRightText=entryInfo.numPlaced..'/'..entryInfo.numStored--..'|A:house-chest-icon:0:0|a'
            end
        end

--套装：炎阳珠衣装
    elseif transmogSetID then
        local collect, numAll = select(2, WoWTools_CollectionMixin:SetID(transmogSetID))
        if numAll then
            if collect==numAll then
                bottomLeftText= get_has_text(true)
            elseif collect>0 then
                bottomLeftText= '|cnWARNING_FONT_COLOR:'..collect..'/'..numAll
            else
                bottomLeftText= get_has_text(false)
            end
        end

--炉石
    elseif itemID==6948 then
        bottomLeftText=WoWTools_TextMixin:sub(WoWTools_TextMixin:CN(GetBindLocation()), 3, 6, true)
--住宅装饰--11.2.7

--    elseif C_Item.IsDecorItem and C_Item.IsDecorItem(itemID) then

-- C_Item.IsCurioItem(itemIDOrLink) or C_Item.IsRelicItem(itemIDOrLink)

--宝箱
    elseif containerInfo and containerInfo.hasLoot then
        local dateInfo= WoWTools_ItemMixin:GetTooltip({bag=tab.bag, merchant=tab.merchant, guidBank=tab.guidBank, hyperLink=itemLink, red=true, onlyRed=true})--物品提示，信息
        topRightText= dateInfo.red and '|A:Monuments-Lock:0:0|a' or '|A:talents-button-undo:0:0|a'
--挑战
    elseif itemID and C_Item.IsItemKeystoneByID(itemID) then
        local name=itemLink:match('%[(.-)]') or itemLink
        if name then
            topLeftText=name:match('%((%d+)%)') or C_MythicPlus.GetOwnedKeystoneLevel() --等级
            name=name:gsub('%((%d+)%)','')
            name=name:match('（(.-)）') or name:match('%((.-)%)') or name:match('%- (.+)') or name:match(keyStr)--名称
            if name then
                bottomLeftText= WoWTools_TextMixin:sub(name, 3,6, true)
            end
            local text= WoWTools_ChallengeMixin:GetRewardText(1)--得到，周奖励，信息
            if text then
                leftText='|cnGREEN_FONT_COLOR:'..text..'|r'
            end
        end

--宠物兑换, wow9.0
    elseif itemQuality==0 and WoWTools_CollectionMixin:GetPet9Item(itemID, true) then
        topRightText='|A:WildBattlePetCapturable:0:0|a'

--垃圾装备
    elseif itemQuality==0 and not (classID==2 or classID==4 ) then
        topRightText='|A:Coin-Silver:0:0|a'

--背包
    elseif classID==1 then
        bottomLeftText= WoWTools_TextMixin:sub(itemSubType, 2, 3, true)
        if containerInfo and not containerInfo.isBound then--没有锁定
            topRightText='|A:Professions_Specialization_Lock_Glow:0:0|a'
        end
        --多少格
        local dateInfo= WoWTools_ItemMixin:GetTooltip({bag=tab.bag, merchant=tab.merchant, guidBank=tab.guidBank, hyperLink=itemLink, index=3})
        local indexText= dateInfo.indexText
        if indexText and indexText:find('%d+') then
            leftText= indexText:match('%d+')
        end

--宝石
    elseif classID==3 then
        if itemLevel and itemLevel>10 then
            rightText= itemLevel
        end
        topRightText= WoWTools_TextMixin:sub(subclassID==9 and itemType or itemSubType, 2,3)
        if lowerVer then--低版本
            topRightText= '|cff626262'..topRightText..'|r'
        else
            bottomLeftText, topLeftText= WoWTools_ItemMixin:SetGemStats(nil, itemLink)
        end

--附魔, 19专业装备 ,7商业技能
    elseif isCraftingReagent or classID==8 or classID==9 or (classID==0 and (subclassID==1 or subclassID==3 or subclassID==5)) or classID==19 or classID==7 then
        local dateInfo= WoWTools_ItemMixin:GetTooltip({bag=tab.bag, merchant=tab.merchant, guidBank=tab.guidBank, hyperLink=itemLink, text={ITEM_SPELL_KNOWN, useStr,}, wow=true, red=true})--物品提示，信息 ITEM_SPELL_KNOWN = "已经学会"
        if not (classID==15 and (subclassID== 0 or subclassID==4)) then
            if classID==0 and subclassID==5 then
                topRightText= WoWTools_TextMixin:sub(POWER_TYPE_FOOD, 2,3, true)--食物
            else
                topRightText= WoWTools_TextMixin:sub(itemSubType==OTHER and itemType or itemSubType, 2,3, true)
            end
            if lowerVer then--低版本
                topRightText= '|cff626262'..topRightText..'|r'
            end
        end
        if dateInfo.text[ITEM_SPELL_KNOWN] then--"已经学会"
            bottomRightText= format('|A:%s:0:0|a', 'common-icon-checkmark')
        elseif dateInfo.red then--红色
            bottomRightText= format('|A:%s:0:0|a', 'talents-button-reset')
        elseif dateInfo.wow then
            bottomRightText= WoWTools_DataMixin.Icon.wow2
        end

        if expacID== WoWTools_DataMixin.ExpansionLevel and classID==8 and dateInfo.text[useStr] then--附魔
            local text= dateInfo.text[useStr]
            for k, v in pairs(FMTab) do
                if text:find(k) then
                    leftText= text:match('%d+%%') or text:match('%d+%,%d+') or text:match('%d+')
                    leftText= leftText and '|cnGREEN_FONT_COLOR:'..leftText..'|r'
                    bottomLeftText= '|cffffffff'..v..'|r'
                    break
                end
            end
        end

--鱼竿
    elseif classID==2 and subclassID==20 then
        topRightText='|A:worldquest-icon-fishing:0:0|a'

--装备
    elseif classID==2 or classID==4 then
        if C_Item.IsCosmeticItem(itemLink) then--装饰品
            bottomLeftText= get_has_text(select(2, WoWTools_CollectionMixin:Item(itemLink, nil, nil, true)))
        elseif PlayerIsTimerunning() then

            local stat= WoWTools_ItemMixin:GetItemStats(itemLink)
            for i=1 ,4 do
                if stat[i] then
                    if i==1 then
                        bottomLeftText= stat[i].text
                    elseif i==2 then
                        bottomRightText= stat[i].text
                    elseif i==3 then
                        topLeftText= stat[i].text
                    elseif i==4 then
                        topRightText= stat[i].text
                    end
                else
                    break
                end
            end
            leftText= get_itemLeve_color(itemLink, itemLevel, itemEquipLoc, itemQuality, nil)--装等，提示

        else
            local isRedItem
            if itemQuality and itemQuality>1  then
                local upItemLevel= 0
                local dateInfo= WoWTools_ItemMixin:GetTooltip({
                    bag=tab.bag, merchant=tab.merchant, guidBank=tab.guidBank, hyperLink=itemLink, itemID=itemID,
                    text={equipStr, pvpItemStr, upgradeStr, classStr, itemLevelStr, 'Set di equipaggiamenti(.-)'}, wow=true, red=true})--物品提示，信息
                isRedItem= dateInfo.red

                if dateInfo.text[itemLevelStr] then--物品等级：%d
                    itemLevel= tonumber(dateInfo.text[itemLevelStr]) or itemLevel
                end



                if dateInfo.text[equipStr] then--套装名称，                
                    local text= dateInfo.text[equipStr]:match('(.+),') or dateInfo.text[equipStr]:match('(.+)，') or dateInfo.text[equipStr]
                    bottomLeftText= '|cff00ccff'..(WoWTools_TextMixin:sub(text,3,4, true) or '')..'|r'

                elseif dateInfo.wow then--战网
                    bottomLeftText= dateInfo.wow--WoWTools_DataMixin.Icon.wow2
                    if subclassID==0 then
                        if itemLevel and itemLevel>1 then
                            bottomLeftText= bottomLeftText.. itemLevel
                            local level= GetAverageItemLevel()
                            if not dateInfo.red then
                                bottomLeftText= bottomLeftText.. (level<itemLevel and '|A:bags-greenarrow:0:0|a' or format('|A:%s:0:0|a', 'common-icon-checkmark'))
                            else
                                bottomLeftText= format('%s|A:%s:0:0|a', bottomLeftText, 'talents-button-reset')
                            end
                        end
                        if dateInfo.text[classStr] then
                            local text=''
                            local n=1
                            local findText=dateInfo.text[classStr]
                            if findText:find(',') then
                                findText= ' '..findText..','
                                findText:gsub(' (.-),', function(t)
                                    if ClassNameIconTab[t] then
                                        text= select(2, math.modf(n/4))==0 and text..'|n' or text
                                        text=text..ClassNameIconTab[t]
                                        n= n+1
                                    end
                                end)
                            else
                                for className, icon in pairs (ClassNameIconTab) do
                                    if dateInfo.text[classStr]:find(className) then
                                        text= select(2, math.modf(n/2))==0 and text..'|n' or text
                                        text=text..icon
                                        n= n+1
                                    end
                                end
                            end
                            topLeftText= text
                        end
                    else
                        if dateInfo.red then
                            if dateInfo.red~= USED then
                                local redText= dateInfo.red:match('%d+') or dateInfo.red
                                topRightText= '|cnWARNING_FONT_COLOR:'..strlower(WoWTools_TextMixin:sub(redText, 2,3, true)) ..'|r'
                            end
                        end
                        topRightText= topRightText or WoWTools_TextMixin:sub(itemSubType, 2, 3, true)
                    end
                end

                if itemMinLevel>WoWTools_DataMixin.Player.Level then--低装等
                    bottomLeftText= '|cnWARNING_FONT_COLOR:'..(bottomLeftText or itemMinLevel)..'|r'
                end
                if dateInfo.text[pvpItemStr] then--PvP装备
                    rightText= '|A:Warfronts-BaseMapIcons-Horde-Barracks-Minimap:0:0|a'
                end
                if WoWTools_DataMixin.Player.IsMaxLevel and dateInfo.text[upgradeStr] then--"升级：%s/%s"

                    local min, max= dateInfo.text[upgradeStr]:match('(%d+)/(%d+)')
                    local upText= dateInfo.text[upgradeStr]:match('(.-)%d+/%d+')

                    upText= upText and strlower(WoWTools_TextMixin:sub(upText, 1,3, true)) or ''
                    if min and max then
                        if min==max then
                            leftText= "|A:VignetteKill:0:0|a"..upText
                        else
                            min, max= tonumber(min) or 0, tonumber(max) or 0
                            upItemLevel= max-min
                            leftText= '|cnGREEN_FONT_COLOR:'..max-min..'|r'..upText
                        end
                    end
                end

                if not topLeftText then
                    if not dateInfo.red then--装等，提示
                        local text= get_itemLeve_color(itemLink, itemLevel, itemEquipLoc, itemQuality, upItemLevel)
                        if text then
                            topLeftText= topLeftText and topLeftText..'|r'..text or text
                        end

                    elseif itemMinLevel<=WoWTools_DataMixin.Player.Level and itemQuality~=7 then--不可使用
                        topLeftText='|A:talents-button-reset:0:0|a'
                        isRedItem=true
                    end
                end
            end


            local collectedIcon, isCollected= WoWTools_CollectionMixin:Item(itemLink, nil, true)--幻化
            bottomRightText= not isCollected and collectedIcon or bottomRightText
--幻化，没有收集
            if isCollected==false then
--当是 披风时，会提示布甲
                if WoWTools_ItemMixin:GetEquipSlotID(itemEquipLoc)~=15 then
                    topRightText= topRightText or WoWTools_TextMixin:sub(itemSubType, 2, 3, true)
                    if itemQuality and itemQuality<=1 then
                        if itemMinLevel<=WoWTools_DataMixin.Player.Level then
                            isRedItem=true
                        else
                            local dateInfo= WoWTools_ItemMixin:GetTooltip({
                                bag=tab.bag, merchant=tab.merchant, guidBank=tab.guidBank, hyperLink=itemLink, itemID=itemID,
                                onlyRed=true, red=true})--物品提示，信息
                            isRedItem= dateInfo.red
                        end
                    end
                    if topRightText and isRedItem then
                        topRightText= '|cnWARNING_FONT_COLOR:'..topRightText..'|r'
                    end
                end
            elseif containerInfo and itemQuality==0 then
                topRightText= '|A:Coin-Silver:0:0|a'
            end
        end

        if containerInfo and not containerInfo.isBound and (bindType==Enum.ItemBind.OnEquip or bindType==Enum.ItemBind.OnUse) and not topRightText then
            rightText='|A:Professions_Specialization_Lock_Glow:16:16|a'--可交易
        end

        leftText= leftText or ''--不显示，物品数量


--宠物
    elseif battlePetSpeciesID or itemID==82800 or classID==17 or (classID==15 and subclassID==2) or itemLink:find('Hbattlepet:(%d+)') then
        local speciesID = battlePetSpeciesID or itemLink:match('Hbattlepet:(%d+)') or (itemID and select(13, C_PetJournal.GetPetInfoByItemID(itemID)))--宠物
        if not speciesID and itemID==82800 and tab.guidBank then
            local data= C_TooltipInfo.GetGuildBankItem(tab.guidBank.tab, tab.guidBank.slot) or {}
            speciesID= data.battlePetSpeciesID
        end
        if speciesID then
            topLeftText= select(3, WoWTools_PetBattleMixin:Collected(speciesID)) or topLeftText--宠物, 收集数量
            local petType= select(3, C_PetJournal.GetPetInfoBySpeciesID(speciesID))
            if petType then
                topRightText='|TInterface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[petType]..':24|t'
            end
        end
--坐骑
    elseif classID==15 and subclassID==5 then
        local mountID = itemID and C_MountJournal.GetMountFromItem(itemID)
        if mountID then
            bottomRightText= get_has_text(select(11, C_MountJournal.GetMountInfoByID(mountID)))
        end

--任务
    elseif classID==12 and itemQuality and itemQuality>0 then
        topRightText= WoWTools_DataMixin.onlyChinese and '任务' or WoWTools_TextMixin:sub(itemSubType, 2,3, true)

--玩具，已收集, 未收集
    elseif itemID and C_ToyBox.GetToyInfo(itemID) then
        bottomRightText= get_has_text(PlayerHasToy(itemID))--已收集, 未收集

--7传家宝，8 WoWToken
    elseif itemQuality==7 or itemQuality==8 then
        topRightText=WoWTools_DataMixin.Icon.wow2

        if classID==0 and subclassID==8 and C_Item.GetItemSpell(itemLink) then--传家宝，升级，物品
            local dateInfo= WoWTools_ItemMixin:GetTooltip({bag=tab.bag, merchant=tab.merchant, guidBank=tab.guidBank, hyperLink=itemLink, text={useStr}, wow=true, red=true})--物品提示，信息
            if dateInfo.text[useStr] and dateInfo.text[useStr]:find(UPGRADE) then--UPGRADE = "升级"
                local tipText= string.lower(dateInfo.text[useStr])
                local weapon= tipText:find(string.lower(WEAPON))--WEAPON = "武器"
                local shield= tipText:find(string.lower(SHIELDSLOT))--SHIELDSLOT = "盾牌"
                local num
                num= dateInfo.text[useStr]:match('%d+')
                num= num and tonumber(num)
                if num and (weapon or shield) then
                    local tab2={
                            [35]=29,
                            [40]=34,
                            [45]=39,
                            [50]=44,
                            [60]=49,
                            [70]=59,
                    }
                    rightText= format('%s%d|r',  tab2[num] and '|cnGREEN_FONT_COLOR:' or '|cffff00ff', tab2[num] or num)--设置, 最高,等级
                    local heirloomNum=0
                    for _, heirloomID in pairs(C_Heirloom.GetHeirloomItemIDs() or {}) do
                        if heirloomID and C_Heirloom.PlayerHasHeirloom(heirloomID) then
                            local _, itemEquipLoc2, _, _, upgradeLevel, _, _, _, _, maxLevel= C_Heirloom.GetHeirloomInfo(heirloomID)
                            local maxUp=C_Heirloom.GetHeirloomMaxUpgradeLevel(heirloomID)
                            if upgradeLevel and maxLevel and maxUp and upgradeLevel< maxUp and maxLevel< num-1  and (weapon and heirloomWeapontemEquipLocTab[itemEquipLoc2] or (not weapon and shield)) then
                                heirloomNum= heirloomNum+1
                            end
                        end
                    end
                    topLeftText= heirloomNum==0 and '|cnWARNING_FONT_COLOR:'..heirloomNum..'|r' or heirloomNum
                    bottomRightText= format('|A:%s:18:18|a', shield and 'Warfronts-BaseMapIcons-Horde-Heroes-Minimap' or 'Warfronts-BaseMapIcons-Horde-Barracks-Minimap')
                end
            end
        end

--[[套装：炎阳珠衣装
    elseif classID==0 and subclassID==8 and itemName:find(WARDROBE_SETS) then
        local dateInfo= WoWTools_ItemMixin:GetTooltip({bag=tab.bag, merchant=tab.merchant, guidBank=tab.guidBank, hyperLink=itemLink, text={ITEM_SPELL_KNOWN, '外观仅供(.-)使用'}, wow=true, red=true})--物品提示，信息 ITEM_SPELL_KNOWN = "已经学会"
        local text= dateInfo.text['外观仅供(.-)使用']
        if dateInfo.text[ITEM_SPELL_KNOWN] then
            bottomLeftText= get_has_text(true)
        elseif text then
            bottomLeftText= Get_Class_Icon_da_Text(text)
        elseif dateInfo.wow then
            topRightText= WoWTools_DataMixin.Icon.wow2
        elseif dateInfo.red then
            topRightText= format('|A:%s:0:0|a', 'talents-button-reset')
        end]]

--仅一个
    elseif itemStackCount==1 then
        local dateInfo= WoWTools_ItemMixin:GetTooltip({bag=tab.bag, merchant=tab.merchant, guidBank=tab.guidBank, hyperLink=itemLink, text={chargesStr}, wow=true, red=true})--物品提示，信息
        bottomLeftText=dateInfo.text[chargesStr]
        if dateInfo.wow then
            topRightText= WoWTools_DataMixin.Icon.wow2
        elseif dateInfo.red then
            topRightText= format('|A:%s:0:0|a', 'talents-button-reset')
        end
    end


    topRightText= topRightText or ((itemID and select(2, C_Item.GetItemSpell(itemID))) and '|A:soulbinds_tree_conduit_icon_utility:0:0|a')

--物品数量
    if not leftText and ((tab.bag and tab.bag.bag <= NUM_BAG_SLOTS+1 and tab.bag.bag>=0) or not tab.bag) then
        local num=C_Item.GetItemCount(itemLink, true, false, true)-C_Item.GetItemCount(itemLink)--银行数量
        if num>0  then
            leftText= '+'..WoWTools_DataMixin:MK(num, 0)
        end
    end

    return topLeftText, leftText, bottomLeftText, topRightText, rightText, bottomRightText, setIDItem
end




















function WoWTools_ItemMixin:SetupInfo(frame, tab)
    if not frame then
        return

    elseif not tab then
        Clear_Label(frame)
        frame._isSetItemInfo= nil
        return
    elseif frame._isSetItemInfo then
        return
    end

    frame._isSetItemInfo=true

    if not frame.topRightText then
        Create_Label(frame, tab)
    end

    local topLeftText, leftText, bottomLeftText, topRightText, rightText, bottomRightText, setIDItem= Get_Info(tab or {})

    frame.topRightText:SetText(topRightText or '')
    frame.rightText:SetText(rightText or '')
    frame.bottomRightText:SetText(bottomRightText or '')

    frame.topLeftText:SetText(topLeftText or '')
    frame.leftText:SetText(leftText or '')
    frame.bottomLeftText:SetText(bottomLeftText or '')

    if setIDItem then
        if type(setIDItem)=='number' then
            local r, g, b = WoWTools_ItemMixin:GetColor(setIDItem)
            frame.setIDItem:SetVertexColor(r, g, b)
        else
            frame.setIDItem:SetVertexColor(0,1,0)
        end
    end
    frame.setIDItem:SetShown(setIDItem)

    if frame.Count and frame.Count:GetText()=='1000' then
        frame.Count:SetText('1k')
    end

    frame._isSetItemInfo= nil
end



