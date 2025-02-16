local id, e = ...
local addName
local Save={}
local panel= CreateFrame('Frame')


local chargesStr= ITEM_SPELL_CHARGES:gsub('%%d', '%(%%d%+%)')--(%d+)次
local keyStr= format(CHALLENGE_MODE_KEYSTONE_NAME,'(.+) ')--钥石
local equipStr= WoWTools_TextMixin:Magic(EQUIPMENT_SETS)--:gsub('|cFFFFFFFF', ''):gsub('|r', ''))
local pvpItemStr= PVP_ITEM_LEVEL_TOOLTIP:gsub('%%d', '%(%%d%+%)')--"装备：在竞技场和战场中将物品等级提高至%d。"
local upgradeStr= ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT:gsub('%%s/%%s','(.-%%d%+/%%d%+)')-- "升级：%s/%s"
local classStr= format(ITEM_CLASSES_ALLOWED, '(.+)') --"职业：%s"
local itemLevelStr= ITEM_LEVEL:gsub('%%d', '%(%%d%+%)')--"物品等级：%d"
local FMTab={}--附魔
local useStr=ITEM_SPELL_TRIGGER_ONUSE..'(.+)'--使用：
local ITEM_SPELL_KNOWN= ITEM_SPELL_KNOWN

local size= 10--字体大小

local heirloomWeapontemEquipLocTab={--传家宝 ，武器，itemEquipLoc
        ['INVTYPE_WEAPON']= true,
        ['INVTYPE_2HWEAPON']= true,
        ['INVTYPE_RANGED']= true,
        ['INVTYPE_RANGEDRIGHT']= true,
    }

--e.Set_Item_Info(itemButton, {bag={bag=bagID, slot=slotID}, merchant={slot=slot, buyBack= selectedTab==2}, guidBank={tab=tab, slot=i}, itemLink=nil, point=nil})



local ClassNameIconTab={}--职业图标 ClassNameIconTab['法师']=图标
for classID= 1, GetNumClasses() do
    local classInfo = C_CreatureInfo.GetClassInfo(classID)
    if classInfo and classInfo.className and classInfo.classFile then
        ClassNameIconTab[classInfo.className]= WoWTools_UnitMixin:GetClassIcon(nil, classInfo.classFile, false)--职业图标
    end
end


local function Get_Class_Icon_da_Text(text)
    local t
    if text then
        for name, icon in pairs(ClassNameIconTab) do
            if text:find(name) then
                t= (t or '')..icon
            end
        end
    end
    return t
end










--已收集, 未收集
local function get_has_text(has)
    if has then
        return format('|cnRED_FONT_COLOR:%s|r',  e.onlyChinese and '已收集' or WoWTools_TextMixin:sub(COLLECTED, 3, 5, true))
    elseif has~=nil then
        return format('|cnGREEN_FONT_COLOR:%s|r',  e.onlyChinese and '未收集' or WoWTools_TextMixin:sub(NOT_COLLECTED, 3, 5, true))
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
    local upLevel, downLevel
    local itemLinkPlayer =  GetInventoryItemLink('player', invSlot)
    if itemLinkPlayer then
        if e.Is_Timerunning then
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
    if upLevel or downLevel or e.Is_Timerunning then
        return (upLevel and '|cnGREEN_FONT_COLOR:'  or (downLevel and '|cnRED_FONT_COLOR:') or  '|cffffffff')
                ..itemLevel..'|r'
    end
end








function e.Set_Item_Info(self, tab)
    if not self or (not self:IsShown() and not tab.isShow) then
        return
    end

    local itemLevel, itemQuality, battlePetSpeciesID
    local itemLink, containerInfo, itemID, isBound
    local topLeftText, bottomRightText, leftText, rightText, bottomLeftText, topRightText, setIDItem--, isWoWItem--setIDItem套装
    local currencyID

    if tab.itemLink or tab.hyperlink then
        itemLink= tab.itemLink or tab.hyperlink
        itemID= tab.itemID

    elseif tab.lootIndex then
        currencyID= select(4, GetLootSlotInfo(tab.lootIndex))
        if not currencyID then
            itemLink= GetLootSlotLink(tab.lootIndex)
        end

    elseif tab.bag then
        containerInfo = C_Container.GetContainerItemInfo(tab.bag.bag, tab.bag.slot)
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
    end



    if itemLink then

        itemID= itemID or C_Item.GetItemInfoInstant(itemLink)
        if not itemID then
            itemID= itemLink:match('|H.-:(%d+):')
            itemID= itemID and tonumber(itemID)
        end

        local itemName, _, itemQuality2, itemLevel2, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, _, _, classID, subclassID, bindType, expacID, setID, isCraftingReagent = C_Item.GetItemInfo(itemLink)
        itemMinLevel= itemMinLevel or 1

        --print(C_Item.GetDetailedItemLevelInfo(itemLink))

        itemLevel= C_Item.GetDetailedItemLevelInfo(itemLink) or itemLevel or itemLevel2
        itemQuality= itemQuality or itemQuality2
        expacID= expacID or 0

        setIDItem= setID and true or nil--套装


        local lowerVer= not e.Is_Timerunning and expacID< e.ExpansionLevel and itemID~='5512' and itemID~='113509'--低版本，5512糖 食物,113509[魔法汉堡]
        --[[if itemQuality then
            r,g,b = C_Item.GetItemQualityColor(itemQuality)
        end]]

        local sellItem
        if tab.bag and containerInfo and not containerInfo.isLocked and WoWTools_SellBuyMixin and WoWTools_SellBuyMixin.CheckSellItem then
            sellItem= WoWTools_SellBuyMixin:CheckSellItem(itemID, itemLink, itemQuality, isBound)--检测是否是出售物品
        end

        if sellItem then--检测是否是出售物品
            if itemQuality==0 then
                topRightText='|A:Coin-Silver:0:0|a'
            else
                topLeftText= itemLevel and itemLevel>20 and (classID==2 or classID==4) and itemLevel
                topRightText= '|T236994:0|t'
            end

        elseif itemID==6948 then--炉石
            bottomLeftText=WoWTools_TextMixin:sub(e.cn(GetBindLocation()), 3, 6, true)

        elseif containerInfo and containerInfo.hasLoot then--宝箱
            local dateInfo= WoWTools_ItemMixin:GetTooltip({bag=tab.bag, merchant=tab.merchant, guidBank=tab.guidBank, hyperLink=itemLink, red=true, onlyRed=true})--物品提示，信息
            topRightText= dateInfo.red and '|A:Monuments-Lock:0:0|a' or '|A:talents-button-undo:0:0|a'

        elseif itemID and C_Item.IsItemKeystoneByID(itemID) then--挑战
            local name=itemLink:match('%[(.-)]') or itemLink
            if name then
                topLeftText=name:match('%((%d+)%)') or C_MythicPlus.GetOwnedKeystoneLevel() --等级
                name=name:gsub('%((%d+)%)','')
                name=name:match('（(.-)）') or name:match('%((.-)%)') or name:match('%- (.+)') or name:match(keyStr)--名称
                if name then
                    bottomLeftText= WoWTools_TextMixin:sub(name, 3,6, true)
                end
                local text= WoWTools_WeekMixin:GetRewardText(1)--得到，周奖励，信息
                if text then
                    leftText='|cnGREEN_FONT_COLOR:'..text..'|r'
                end
            end

        elseif itemQuality==0 and WoWTools_CollectedMixin:GetPet9Item(itemID, true) then--宠物兑换, wow9.0
            topRightText='|A:WildBattlePetCapturable:0:0|a'

        elseif itemQuality==0 and not (classID==2 or classID==4 ) then
            topRightText='|A:Coin-Silver:0:0|a'

        elseif classID==1 then--背包
            bottomLeftText= WoWTools_TextMixin:sub(itemSubType, 2, 3, true)
            if containerInfo and not containerInfo.isBound then--没有锁定
                topRightText='|A:greatVault-lock:0:0|a'
            end
            --多少格
            local dateInfo= WoWTools_ItemMixin:GetTooltip({bag=tab.bag, merchant=tab.merchant, guidBank=tab.guidBank, hyperLink=itemLink, index=3})
            local indexText= dateInfo.indexText
            if indexText and indexText:find('%d+') then
                leftText= indexText:match('%d+')
            end

        elseif classID==3 then--宝石
            if itemLevel and itemLevel>10 then
                rightText= itemLevel
            end
            topRightText= WoWTools_TextMixin:sub(subclassID==9 and itemType or itemSubType, 2,3)
            if lowerVer then--低版本
                topRightText= '|cff9e9e9e'..topRightText..'|r'
            else
                bottomLeftText, topLeftText= WoWTools_ItemStatsMixin:Gem(nil, itemLink)
            end

        elseif isCraftingReagent or classID==8 or classID==9 or (classID==0 and (subclassID==1 or subclassID==3 or subclassID==5)) or classID==19 or classID==7 then--附魔, 19专业装备 ,7商业技能
            local dateInfo= WoWTools_ItemMixin:GetTooltip({bag=tab.bag, merchant=tab.merchant, guidBank=tab.guidBank, hyperLink=itemLink, text={ITEM_SPELL_KNOWN, useStr,}, wow=true, red=true})--物品提示，信息 ITEM_SPELL_KNOWN = "已经学会"
            if not (classID==15 and (subclassID== 0 or subclassID==4)) then
                if classID==0 and subclassID==5 then
                    topRightText= WoWTools_TextMixin:sub(POWER_TYPE_FOOD, 2,3, true)--食物
                else
                    topRightText= WoWTools_TextMixin:sub(itemSubType==OTHER and itemType or itemSubType, 2,3, true)
                end
                if lowerVer then--低版本
                    topRightText= '|cff9e9e9e'..topRightText..'|r'
                end
            end
            if dateInfo.text[ITEM_SPELL_KNOWN] then--"已经学会"
                bottomRightText= format('|A:%s:0:0|a', e.Icon.select)
            elseif dateInfo.red then--红色
                bottomRightText= format('|A:%s:0:0|a', e.Icon.disabled)
            elseif dateInfo.wow then
                bottomRightText= e.Icon.wow2
            end

            if expacID== e.ExpansionLevel and classID==8 and dateInfo.text[useStr] then--附魔
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

        elseif classID==2 and subclassID==20 then-- 鱼竿
                topRightText='|A:worldquest-icon-fishing:0:0|a'

        elseif classID==2 or classID==4 then--装备
            if C_Item.IsCosmeticItem(itemLink) then--装饰品
                bottomLeftText= get_has_text(select(2, WoWTools_CollectedMixin:Item(itemLink, nil, nil, true)))
            elseif e.Is_Timerunning then

                local stat= WoWTools_ItemStatsMixin:GetItem(itemLink)
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
                if itemQuality and (itemQuality>1 or e.Is_Timerunning) then
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
                        bottomLeftText= e.Icon.wow2
                        if subclassID==0 then
                            if itemLevel and itemLevel>1 then
                                bottomLeftText= bottomLeftText.. itemLevel
                                local level= GetAverageItemLevel()
                                if not dateInfo.red then
                                    bottomLeftText= bottomLeftText.. (level<itemLevel and '|A:bags-greenarrow:0:0|a' or format('|A:%s:0:0|a', e.Icon.select))
                                else
                                    bottomLeftText= format('%s|A:%s:0:0|a', bottomLeftText, e.Icon.disabled)
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
                                            text= select(2, math.modf(n/4))==0 and text..'|n' or text
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
                                    topRightText= '|cnRED_FONT_COLOR:'..strlower(WoWTools_TextMixin:sub(redText, 2,3, true)) ..'|r'
                                end
                            end
                            topRightText= topRightText or WoWTools_TextMixin:sub(itemSubType, 2, 3, true)
                        end
                    end

                    if itemMinLevel>e.Player.level then--低装等
                        bottomLeftText= '|cnRED_FONT_COLOR:'..(bottomLeftText or itemMinLevel)..'|r'
                    end
                    if dateInfo.text[pvpItemStr] then--PvP装备
                        rightText= '|A:Warfronts-BaseMapIcons-Horde-Barracks-Minimap:0:0|a'
                    end
                    if e.Player.levelMax and dateInfo.text[upgradeStr] then--"升级：%s/%s"
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

                    if not dateInfo.red then--装等，提示
                        local text= get_itemLeve_color(itemLink, itemLevel, itemEquipLoc, itemQuality, upItemLevel)
                        if text then
                            topLeftText= topLeftText and topLeftText..'|r'..text or text
                        end
                    elseif itemMinLevel<=e.Player.level and itemQuality~=7 then--不可使用
                        topLeftText=format('|A:%s:0:0|a', e.Icon.disabled)
                        isRedItem=true
                    end

                end


                local collectedIcon, isCollected= WoWTools_CollectedMixin:Item(itemLink, nil, true)--幻化
                bottomRightText= not isCollected and collectedIcon or bottomRightText
                if isCollected==false then
                    topRightText= topRightText or WoWTools_TextMixin:sub(itemSubType, 2, 3, true)
                    if itemQuality and itemQuality<=1 then
                        if itemMinLevel<=e.Player.level then
                            isRedItem=true
                        else
                            local dateInfo= WoWTools_ItemMixin:GetTooltip({
                                bag=tab.bag, merchant=tab.merchant, guidBank=tab.guidBank, hyperLink=itemLink, itemID=itemID,
                                onlyRed=true, red=true})--物品提示，信息
                            isRedItem= dateInfo.red
                        end
                    end
                    if topRightText and isRedItem then
                        topRightText= '|cnRED_FONT_COLOR:'..topRightText..'|r'
                    end
                elseif containerInfo and itemQuality==0 then
                    topRightText= '|A:Coin-Silver:0:0|a'
                end
            end
            if containerInfo and not containerInfo.isBound and (bindType==LE_ITEM_BIND_ON_EQUIP or bindType==LE_ITEM_BIND_ON_USE) and not topRightText then
                rightText='|A:greatVault-lock:16:16|a'--可交易
            end

        elseif battlePetSpeciesID or itemID==82800 or classID==17 or (classID==15 and subclassID==2) or itemLink:find('Hbattlepet:(%d+)') then--宠物
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

        elseif classID==15 and subclassID==5 then--坐骑
            local mountID = itemID and C_MountJournal.GetMountFromItem(itemID)
            if mountID then
                bottomRightText= get_has_text(select(11, C_MountJournal.GetMountInfoByID(mountID)))
            end


        elseif classID==12 and itemQuality and itemQuality>0 then--任务
            topRightText= e.onlyChinese and '任务' or WoWTools_TextMixin:sub(itemSubType, 2,3, true)

        elseif itemID and C_ToyBox.GetToyInfo(itemID) then--玩具
            bottomRightText= get_has_text(PlayerHasToy(itemID))--已收集, 未收集

        elseif itemQuality==7 or itemQuality==8 then--7传家宝，8 WoWToken
            topRightText=e.Icon.wow2

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
                        topLeftText= heirloomNum==0 and '|cnRED_FONT_COLOR:'..heirloomNum..'|r' or heirloomNum
                        bottomRightText= format('|A:%s:18:18|a', shield and 'Warfronts-BaseMapIcons-Horde-Heroes-Minimap' or 'Warfronts-BaseMapIcons-Horde-Barracks-Minimap')
                    end
                end
            end


        elseif classID==0 and subclassID==8 and itemName:find(WARDROBE_SETS) then--套装：炎阳珠衣装
            local dateInfo= WoWTools_ItemMixin:GetTooltip({bag=tab.bag, merchant=tab.merchant, guidBank=tab.guidBank, hyperLink=itemLink, text={ITEM_SPELL_KNOWN, '外观仅供(.-)使用'}, wow=true, red=true})--物品提示，信息 ITEM_SPELL_KNOWN = "已经学会"
            local text= dateInfo.text['外观仅供(.-)使用']
            if dateInfo.text[ITEM_SPELL_KNOWN] then
                bottomLeftText= get_has_text(true)
            elseif text then
                bottomLeftText= Get_Class_Icon_da_Text(text)
            elseif dateInfo.wow then
                topRightText= e.Icon.wow2
            elseif dateInfo.red then
                topRightText= format('|A:%s:0:0|a', e.Icon.disabled)
            end

        elseif itemStackCount==1 then
            local dateInfo= WoWTools_ItemMixin:GetTooltip({bag=tab.bag, merchant=tab.merchant, guidBank=tab.guidBank, hyperLink=itemLink, text={chargesStr}, wow=true, red=true})--物品提示，信息
            bottomLeftText=dateInfo.text[chargesStr]
            if dateInfo.wow then
                topRightText= e.Icon.wow2
            elseif dateInfo.red then
                topRightText= format('|A:%s:0:0|a', e.Icon.disabled)
            end
        end


        topRightText= topRightText or ((itemID and C_Item.GetItemSpell(itemID)) and '|A:soulbinds_tree_conduit_icon_utility:0:0|a')

        if not leftText and ((tab.bag and tab.bag.bag <= NUM_BAG_SLOTS+1 and tab.bag.bag>=0) or not tab.bag) then
            local num=C_Item.GetItemCount(itemLink, true, false, true)-C_Item.GetItemCount(itemLink)--银行数量
            if num>0  then
                leftText= '+'..WoWTools_Mixin:MK(num, 0)
            end
        end

    elseif currencyID then--货币
        local info= C_CurrencyInfo.GetCurrencyInfo(currencyID) or {}
        if info.quantity and info.quantity>0 then
            topLeftText= WoWTools_Mixin:MK(info.quantity, 3)
        end

    end

    if topRightText and not self.topRightText then
        self.topRightText=WoWTools_LabelMixin:Create(self, {size=tab.size or size, color={r=1,g=1,b=1}})--size, nil, nil, nil, 'OVERLAY')
        self.topRightText:SetPoint('TOPRIGHT', tab.point or self, 2,0)
    end
    if self.topRightText then
        self.topRightText:SetText(topRightText or '')
        --[[if r and g and b and topRightText then
            self.topRightText:SetTextColor(r,g,b)
        end]]
    end
    if topLeftText and not self.topLeftText then
        self.topLeftText=WoWTools_LabelMixin:Create(self, {size=tab.size or size, color={r=1,g=1,b=1}})--size, nil, nil, nil, 'OVERLAY')
        self.topLeftText:SetPoint('TOPLEFT', tab.point or self)
    end
    if self.topLeftText then
        self.topLeftText:SetText(topLeftText or '')
       --[[if r and g and b and topLeftText then
            self.topLeftText:SetTextColor(r,g,b)
        end]]
    end
    if bottomRightText then
        if not self.bottomRightText then
            self.bottomRightText=WoWTools_LabelMixin:Create(self, {size=tab.size or size, color={r=1,g=1,b=1}})--size, nil, nil, nil, 'OVERLAY')
            self.bottomRightText:SetPoint('BOTTOMRIGHT', tab.point or self)
        end
    end
    if self.bottomRightText then
        self.bottomRightText:SetText(bottomRightText or '')
        --[[if r and g and b and bottomRightText then
            self.bottomRightText:SetTextColor(r,g,b)
        end]]
    end

    if leftText and not self.leftText then
        self.leftText=WoWTools_LabelMixin:Create(self, {size=tab.size or size, color={r=1,g=1,b=1}})--size, nil, nil, nil, 'OVERLAY')
        self.leftText:SetPoint('LEFT', tab.point or self)
    end
    if self.leftText then
        self.leftText:SetText(leftText or '')
        --[[if r and g and b and leftText then
            self.leftText:SetTextColor(r,g,b)
        end]]
    end

    if rightText and not self.rightText then
        self.rightText=WoWTools_LabelMixin:Create(self, {size=tab.size or size, color={r=1,g=1,b=1}})--size, nil, nil, nil, 'OVERLAY')
        self.rightText:SetPoint('RIGHT', tab.point or self)
    end
    if self.rightText then
        self.rightText:SetText(rightText or '')
        --[[if r and g and b and rightText then
            self.rightText:SetTextColor(r,g,b)
        end]]
    end

    if bottomLeftText and not self.bottomLeftText then
        self.bottomLeftText=WoWTools_LabelMixin:Create(self, {size=tab.size or size, color={r=1,g=1,b=1}})--size)
        self.bottomLeftText:SetPoint('BOTTOMLEFT', tab.point or self)
    end
    if self.bottomLeftText then
        self.bottomLeftText:SetText(bottomLeftText or '')
        --[[if r and g and b and bottomLeftText then
            self.bottomLeftText:SetTextColor(r,g,b)
        end]]
    end

    if setIDItem and not self.setIDItem then
        self.setIDItem=self:CreateTexture()
        self.setIDItem:SetAllPoints(self)
        self.setIDItem:SetAtlas('UI-HUD-MicroMenu-Highlightalert')
    end
    if self.setIDItem then
        self.setIDItem:SetShown(setIDItem)
    end
    if not self.setCount and self.Count then
        self.Count:ClearAllPoints()
        self.Count:SetPoint('BottomRight')
        self.setCount=true
    end
end




































local function setBags(self)--背包设置
    if not self:IsVisible() then
        return
    end
    for _, itemButton in self:EnumerateValidItems() do
        if itemButton.hasItem then
            local slotID, bagID= itemButton:GetSlotAndBagID()--:GetID() GetBagID()
            e.Set_Item_Info(itemButton, {bag={bag=bagID, slot=slotID}})
        else
            e.Set_Item_Info(itemButton, {})
        end
    end
end


























--hooksecurefunc(GuildBankFrame,'Update', function(self)--Blizzard_GuildBankUI.lua
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
                e.Set_Item_Info(button,{guidBank={tab=tab, slot=i}})
            end
        end
    end
end
















local function set_BankFrameItemButton_Update(self)--银行, BankFrame.lua
    if not self.isBag then
        e.Set_Item_Info(self, {bag={bag=self:GetParent():GetID(), slot=self:GetID()}})
    else
        local slot = self:GetBagID()
        local numFreeSlots
        numFreeSlots = C_Container.GetContainerNumFreeSlots(slot)
        if not numFreeSlots or numFreeSlots==0 then
            numFreeSlots= nil
        end
        if numFreeSlots and not self.numFreeSlots then
            self.numFreeSlots=WoWTools_LabelMixin:Create(self, {color=true, justifyH='CENTER'})
            self.numFreeSlots:SetPoint('BOTTOM',0 ,6)
        end
        if self.numFreeSlots then
            self.numFreeSlots:SetText(numFreeSlots or '')
        end
    end
end



















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
                        e.Set_Item_Info(self, {bag={bag=bagID, slot=slotID}})
                    else
                        e.Set_Item_Info(self, {})
                    end
                end
            end)
        end
        return

    elseif C_AddOns.IsAddOnLoaded("Baggins") then
        hooksecurefunc(_G['Baggins'], 'UpdateItemButton', function(_, _, button, bagID, slotID)
            if button and bagID and slotID then
                e.Set_Item_Info(button, {bag={bag=bagID, slot=slotID}})
            end
        end)
        return

    elseif C_AddOns.IsAddOnLoaded('Inventorian') then
        local lib = LibStub("AceAddon-3.0", true)
        if lib then
            ADDON= lib:GetAddon("Inventorian")
            local InvLevel = ADDON:NewModule('InventorianWoWToolsItemInfo')
            function InvLevel:Update()
                e.Set_Item_Info(self, {bag={bag=self.bag, slot=self.slot}})
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


           -- panel:RegisterEvent('BANKFRAME_OPENED')--打开所有银行，背包
            panel:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")--打开公会银行时, 打开背包
            panel:RegisterEvent("GUILDBANK_ITEM_LOCK_CHANGED")

    end

    hooksecurefunc('BankFrameItemButton_Update', set_BankFrameItemButton_Update)--银行
    hooksecurefunc(BankPanelItemButtonMixin, 'Refresh', function(self)--战团银行
        local info= self.itemInfo or {}
        info.isShow=true
        e.Set_Item_Info(self, info)
    end)

    --############
    --排序:从右到左
    --############
    Menu.ModifyMenu("MENU_CONTAINER_FRAME_COMBINED", function(_, root)
        root:CreateDivider()
        local check= root:CreateCheckbox(e.onlyChinese and '反向整理背包' or REVERSE_CLEAN_UP_BAGS_TEXT, function()
                return not C_Container.GetSortBagsRightToLeft()
            end, function()
                C_Container.SetSortBagsRightToLeft(not C_Container.GetSortBagsRightToLeft() and true or false)
                return MenuResponse.Close
            end)
        check:SetTooltip(function(tooltip, elementDescription)
            GameTooltip_SetTitle(tooltip, id..' '..addName)
            tooltip:AddDoubleLine(MenuUtil.GetElementText(elementDescription), e.GetEnabeleDisable(not C_Container.GetSortBagsRightToLeft()))
            tooltip:AddDoubleLine('C_Container.SetSortBagsRightToLeft')
        end)

        check= root:CreateCheckbox(e.onlyChinese and '禁用排序' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DISABLE, STABLE_FILTER_BUTTON_LABEL),
            C_Container.GetBackpackAutosortDisabled,
            function()
                C_Container.SetBackpackAutosortDisabled(not C_Container.GetBackpackAutosortDisabled() and true or false)
                return MenuResponse.Close
            end)
        check:SetTooltip(function(tooltip, elementDescription)
            GameTooltip_SetTitle(tooltip, id..' '..addName)
            tooltip:AddDoubleLine(MenuUtil.GetElementText(elementDescription), e.GetEnabeleDisable(C_Container.GetBackpackAutosortDisabled()))
            tooltip:AddLine('C_Container.SetBackpackAutosortDisabled')
        end)

    end)
end


























--####
--初始
--####
local function Init()
    --boss掉落，物品, 可能，会留下 StaticPopup1 框架
    hooksecurefunc('BossBanner_ConfigureLootFrame', function(lootFrame, data)--LevelUpDisplay.lua
        WoWTools_ItemStatsMixin:SetItem(lootFrame, data.itemLink, {point=lootFrame.Icon})
    end)




    --拾取时, 弹出, 物品提示，信息, 战利品
    --AlertFrameSystems.lua
    hooksecurefunc('DungeonCompletionAlertFrameReward_SetRewardItem', function(frame, itemLink)
        WoWTools_ItemStatsMixin:SetItem(frame, frame.itemLink or itemLink , {point=frame.texture})
    end)
    hooksecurefunc('LootWonAlertFrame_SetUp', function(self)
        WoWTools_ItemStatsMixin:SetItem(self, self.hyperlink, {point= self.lootItem.Icon})
    end)
    hooksecurefunc('LootUpgradeFrame_SetUp', function(self)
        WoWTools_ItemStatsMixin:SetItem(self, self.hyperlink, {point=self.Icon})
    end)

    hooksecurefunc('LegendaryItemAlertFrame_SetUp', function(frame)
        WoWTools_ItemStatsMixin:SetItem(frame, frame.hyperlink, {point= frame.Icon})
    end)


    hooksecurefunc(LootItemExtendedMixin, 'Init', function(self, itemLink2, originalQuantity, _, isCurrency)--ItemDisplay.lua
        local _, _, _, _, itemLink = ItemUtil.GetItemDetails(itemLink2, originalQuantity, isCurrency)
        WoWTools_ItemStatsMixin:SetItem(self, itemLink, {point= self.Icon})
    end)



    --商人 
    local function setMerchantInfo()--商人设置
        local isBuy= MerchantFrame.selectedTab==1
        local page= isBuy and MERCHANT_ITEMS_PER_PAGE or BUYBACK_ITEMS_PER_PAGE
        for i=1, page do
            local slot = isBuy and (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i) or i
            local itemButton= _G["MerchantItem"..i..'ItemButton']
            if itemButton then
                e.Set_Item_Info(itemButton, {merchant={slot=slot, buyBack= not isBuy}})
            end
        end
        e.Set_Item_Info(MerchantBuyBackItemItemButton, {merchant={slot=GetNumBuybackItems(), buyBack=true}})
    end
    hooksecurefunc('MerchantFrame_UpdateMerchantInfo', setMerchantInfo)--MerchantFrame.lua
    hooksecurefunc('MerchantFrame_UpdateBuybackInfo', setMerchantInfo)



    --##商人，物品，货币，数量
    --MerchantFrame.lua
    hooksecurefunc('MerchantFrame_UpdateAltCurrency', function(index, indexOnPage, canAfford)
        local itemCount = GetMerchantItemCostInfo(index)
        local frameName = "MerchantItem"..indexOnPage.."AltCurrencyFrame"
        local usedCurrencies = 0
        if ( itemCount > 0 ) then
            for i=1, MAX_ITEM_COST do
                local _, itemValue, itemLink, currencyName = GetMerchantItemCostItem(index, i)
                if itemLink then
                    usedCurrencies = usedCurrencies + 1
                    local btn = _G[frameName.."Item"..usedCurrencies]
                    if btn and btn:IsShown() then
                        local num
                        if currencyName then
                            num= C_CurrencyInfo.GetCurrencyInfoFromLink(itemLink).quantity
                        else
                            num= C_Item.GetItemCount(itemLink, true, false, true)
                        end
                        if itemValue and num then
                            if num>=itemValue then
                                num= '|cnGREEN_FONT_COLOR:'..WoWTools_Mixin:MK(num,0)..'|r'
                            else
                                num= '|cnRED_FONT_COLOR:'..WoWTools_Mixin:MK(num,0)..'|r'
                            end
                        end
                        if not btn.quantityAll then
                            btn.quantityAll= WoWTools_LabelMixin:Create(btn, {size=10, justifyH='RIGHT'})--10, nil, nil, nil, nil, 'RIGHT')
                            btn.quantityAll:SetPoint('BOTTOMRIGHT', btn, 'TOPRIGHT', 3,0)
                            btn.quantityAll:SetAlpha(0.7)
                            btn:EnableMouse(true)
                            btn:HookScript('OnMouseDown', function(self)
                                if self.itemLink then
                                    local link= self.itemLink..(
                                        self.quantityAll.itemValue and ' x'..self.quantityAll.itemValue or ''
                                    )
                                    WoWTools_ChatMixin:Chat(link, nil, true)
                                end
                                self:SetAlpha(0.3)
                            end)
                            btn:HookScript('OnEnter', function(self)
                                self:SetAlpha(0.5)
                            end)
                            btn:HookScript('OnMouseUp', function(self)
                                self:SetAlpha(0.5)
                            end)
                            btn:HookScript('OnLeave', function(self) self:SetAlpha(1) end)
                            btn:HookScript('OnEnter', function(self)
                                if self.itemLink and e.tips:IsShown() then
                                    e.tips:AddLine(' ')
                                    e.tips:AddDoubleLine(e.onlyChinese and '链接至聊天栏' or COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT, e.Icon.left)
                                    e.tips:AddDoubleLine(WoWTools_Mixin.addName, addName)
                                    e.tips:Show()
                                end
                            end)
                        end
                        btn.quantityAll.itemValue= itemValue
                        btn.quantityAll:SetText(num or '')
                    end
                end
            end
        end
    end)




    --拾取
    hooksecurefunc(LootFrame, 'Open', function(self)--LootFrame.lua
        if not self.ScrollBox:GetView() then
            return
        end
        for index, btn in pairs(self.ScrollBox:GetFrames() or {}) do
            e.Set_Item_Info(btn.Item, {lootIndex=btn.GetOrderIndex() or btn:GetSlotIndex() or index})
        end
    end)
    hooksecurefunc(LootFrame.ScrollBox, 'SetScrollTargetOffset', function(self)
        if not self:GetView() then
            return
        end
        for index, btn in pairs(self:GetFrames() or {}) do
            e.Set_Item_Info(btn.Item, {lootIndex=btn.GetOrderIndex() or btn:GetSlotIndex() or index})
        end
    end)

    Init_Bag()



    hooksecurefunc( BankPanelItemButtonMixin, 'Refresh', function (self)
        e.Set_Item_Info(self, {itemLink=self.itemInfo and self.itemInfo.hyperlink})
    end)

end


































--添加一个按钮, 打开，角色界面
local function add_Button_OpenOption(frame)
    if not frame then
        return
    end
    local btn= WoWTools_ButtonMixin:Cbtn(frame, {atlas='charactercreate-icon-customize-body-selected', size={40,40}})
    btn:SetPoint('TOPRIGHT',-5,-25)
    btn:SetScript('OnClick', function()
        ToggleCharacter("PaperDollFrame")
    end)
    btn:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '打开/关闭角色界面' or BINDING_NAME_TOGGLECHARACTER0, e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(WoWTools_Mixin.addName, addName)
        e.tips:Show()
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























--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then

        if arg1==id then
            addName= '|A:bag-main:0:0|a'..(e.onlyChinese and '物品信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEMS, INFO))

            Save= WoWToolsSave['ItemInfo_Lua'] or Save

            --添加控制面板
            e.AddPanel_Check({
                name= addName,
                tooltip= e.onlyChinese and '系统背包|n商人' or (BAGSLOT..'|n'..MERCHANT),--'Inventorian, Baggins', 'Bagnon'
                GetValue= function() return not Save.disabled end,
                SetValue= function()
                    if Save.disabled then
                        Save.disabled=nil
                        panel:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
                    else
                        Save.disabled=true
                        panel:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
                    end
                    print(WoWTools_Mixin.addName, addName, e.GetEnabeleDisable(Save.disabled))
                end
            })

            if Save.disabled then
                self:UnregisterAllEvents()
            else
                Init()

                FMTab={--附魔
                        ['主属性']= '主',
                        ['坐骑速度']= '骑',
                        [PRIMARY_STAT1_TOOLTIP_NAME]=  e.onlyChinese and "力" or WoWTools_TextMixin:sub(PRIMARY_STAT1_TOOLTIP_NAME, 1, 3, true),
                        [PRIMARY_STAT2_TOOLTIP_NAME]=  e.onlyChinese and "敏" or WoWTools_TextMixin:sub(PRIMARY_STAT2_TOOLTIP_NAME, 1, 3, true),
                        [PRIMARY_STAT3_TOOLTIP_NAME]=  e.onlyChinese and "耐" or WoWTools_TextMixin:sub(PRIMARY_STAT3_TOOLTIP_NAME, 1, 3, true),
                        [PRIMARY_STAT4_TOOLTIP_NAME]=  e.onlyChinese and "智" or WoWTools_TextMixin:sub(PRIMARY_STAT4_TOOLTIP_NAME, 1, 3, true),
                        [ITEM_MOD_CRIT_RATING_SHORT]= e.onlyChinese and '爆' or WoWTools_TextMixin:sub(STAT_CRITICAL_STRIKE, 1, 3, true),
                        [ITEM_MOD_HASTE_RATING_SHORT]= e.onlyChinese and '急' or WoWTools_TextMixin:sub(STAT_HASTE, 1, 3, true),
                        [ITEM_MOD_MASTERY_RATING_SHORT]= e.onlyChinese and '精' or WoWTools_TextMixin:sub(STAT_MASTERY, 1, 3, true),
                        [ITEM_MOD_VERSATILITY]= e.onlyChinese and '全' or WoWTools_TextMixin:sub(STAT_VERSATILITY, 1, 3, true),
                        [ITEM_MOD_CR_AVOIDANCE_SHORT]= e.onlyChinese and '闪' or WoWTools_TextMixin:sub(ITEM_MOD_CR_AVOIDANCE_SHORT, 1, 3, true),
                        [ITEM_MOD_CR_LIFESTEAL_SHORT]= e.onlyChinese and '吸' or WoWTools_TextMixin:sub(ITEM_MOD_CR_LIFESTEAL_SHORT, 1, 3, true),
                        [ITEM_MOD_CR_SPEED_SHORT]= e.onlyChinese and '速' or WoWTools_TextMixin:sub(ITEM_MOD_CR_SPEED_SHORT, 1, 3, true),
                    }
            end
            self:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_PerksProgram' then
            --##########################
            --商站
            --Blizzard_PerksProgram.lua
            local function set_FrozenButton_Tips()
                if PerksProgramFrame.GetFrozenItemFrame then
                    local frame= PerksProgramFrame:GetFrozenItemFrame()
                    if frame then
                        local itemLink= frame.FrozenButton.itemID and WoWTools_ItemMixin:GetLink(frame.FrozenButton.itemID)
                        e.Set_Item_Info(frame.FrozenButton, {itemLink=itemLink, size=12})
                    end
                end
            end
            hooksecurefunc(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.ScrollBox, 'SetScrollTargetOffset', function(self2)
                if not self2:GetView() then
                    return
                end
                for _, btn in pairs(self2:GetFrames()) do
                    if btn.itemID then
                        local itemLink= WoWTools_ItemMixin:GetLink(btn.itemID)
                        e.Set_Item_Info(btn.ContentsContainer, {itemLink=itemLink, point=btn.ContentsContainer.Icon, size=12})
                    elseif btn.GetItemInfo then--10.2
                        local itemInfo=btn:GetItemInfo()
                        if itemInfo then
                            local itemLink= WoWTools_ItemMixin:GetLink(itemInfo.itemID)
                            e.Set_Item_Info(btn.ContentsContainer, {itemLink=itemLink, point=btn.ContentsContainer.Icon, size=12})
                        end
                    end
                end
                set_FrozenButton_Tips()
            end)

        elseif arg1=='Blizzard_WeeklyRewards' then--周奖励, 物品提示，信息
            hooksecurefunc(WeeklyRewardsFrame, 'Refresh', function(self2)--Blizzard_WeeklyRewards.lua WeeklyRewardsMixin:Refresh(playSheenAnims)
                for _, activityInfo in ipairs(C_WeeklyRewards.GetActivities() or {}) do
                    local frame = self2:GetActivityFrame(activityInfo.type, activityInfo.index)
                    local itemFrame= frame and frame.ItemFrame
                    if itemFrame then
                        WoWTools_ItemStatsMixin:SetItem(itemFrame, itemFrame.displayedItemDBID and C_WeeklyRewards.GetItemHyperlink(itemFrame.displayedItemDBID), {point=itemFrame.Icon})
                    end
                end
            end)
            hooksecurefunc(WeeklyRewardsFrame, 'UpdateSelection', function(self2)
                for _, activityInfo in ipairs(C_WeeklyRewards.GetActivities() or {}) do
                    local frame = self2:GetActivityFrame(activityInfo.type, activityInfo.index)
                    local itemFrame= frame and frame.ItemFrame
                    if itemFrame then
                        WoWTools_ItemStatsMixin:SetItem(itemFrame, itemFrame.displayedItemDBID and C_WeeklyRewards.GetItemHyperlink(itemFrame.displayedItemDBID), {point=itemFrame.Icon})
                    end
                end
            end)

        elseif arg1=='Blizzard_AuctionHouseUI' then--拍卖行
            --出售页面，买卖，物品信息 Blizzard_AuctionHouseSellFrame.lua
            hooksecurefunc(AuctionHouseSellFrameMixin, 'SetItem', function(self, itemLocation)
                e.Set_Item_Info(self.ItemDisplay.ItemButton, {itemLocation= itemLocation, size=12})
            end)

            hooksecurefunc(AuctionHouseFrame, 'SelectBrowseResult', function(self, browseResult)
                local itemKey = browseResult.itemKey
                local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey) or {}
                if itemKeyInfo.isCommodity then
                    e.Set_Item_Info(self.CommoditiesBuyFrame.BuyDisplay.ItemDisplay.ItemButton, {itemKey= itemKey, size=12})
                else
                    e.Set_Item_Info(self.ItemBuyFrame.ItemDisplay.ItemButton, {itemKey= itemKey, size=12})
                end
            end)

        elseif arg1=='Blizzard_ItemInteractionUI' then--套装转换, 界面
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
                WoWTools_ItemStatsMixin:SetItem(self, itemLink, {}) --设置，物品，次属性，表
            end)
            hooksecurefunc(ItemInteractionFrame.ItemConversionFrame.ItemConversionInputSlot, 'RefreshIcon', function(self)
                local itemInteractionFrame = self:GetParent():GetParent()
                local itemLocation = itemInteractionFrame:GetItemLocation()
                local itemLink
                local show= (itemLocation and itemInteractionFrame:GetInteractionType() == Enum.UIItemInteractionType.ItemConversion)
                if show then
                    itemLink= C_Item.GetItemLink(itemLocation)
                end
                WoWTools_ItemStatsMixin:SetItem(self, itemLink, {}) --设置，物品，次属性，表
            end)

        elseif arg1=='Blizzard_ItemUpgradeUI' then--装备升级, 界面
            add_Button_OpenOption(ItemUpgradeFrameCloseButton)--添加一个按钮, 打开选项                       
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['ItemInfo_Lua']=Save
        end

    elseif event == "GUILDBANKBAGSLOTS_CHANGED" or event =="GUILDBANK_ITEM_LOCK_CHANGED" then
        setGuildBank()--公会银行,设置

    end
end)
