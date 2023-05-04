local id, e = ...
local addName= ITEMS..INFO
local Save={}
local panel=CreateFrame("Frame")

local chargesStr= ITEM_SPELL_CHARGES:gsub('%%d', '%(%%d%+%)')--(%d+)次
local keyStr= format(CHALLENGE_MODE_KEYSTONE_NAME,'(.+) ')--钥石
local equipStr= format(EQUIPMENT_SETS, '(.+)')
local pvpItemStr= PVP_ITEM_LEVEL_TOOLTIP:gsub('%%d', '%(%%d%+%)')--"装备：在竞技场和战场中将物品等级提高至%d。"
local upgradeStr= ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT:gsub('%%s/%%s','(%%d%+/%%d%+)')-- "升级：%s/%s"
local classStr= format(ITEM_CLASSES_ALLOWED, '(.+)') --"职业：%s";
local itemLevelStr= ITEM_LEVEL:gsub('%%d', '%(%%d%+%)')--"物品等级：%d"
local FMTab={}--附魔
local useStr=ITEM_SPELL_TRIGGER_ONUSE..'(.+)'--使用：
local andStr = COVENANT_RENOWN_TOAST_REWARD_COMBINER:format('(.-)','(.+)')--"%s 和 %s";
local size= 10--字体大小


local ClassNameIconTab={}--职业图标 ClassNameIconTab['法师']=图标
local heirloomWeapontemEquipLocTab={--传家宝，武器，itemEquipLoc
        ['INVTYPE_WEAPON']= true,
        ['INVTYPE_2HWEAPON']= true,
        ['INVTYPE_RANGED']= true,
        ['INVTYPE_RANGEDRIGHT']= true,
    }

--set_Item_Info(itemButton, {bag={bag=bagID, slot=slotID}, merchant={slot=slot, buyBack= selectedTab==2}, guidBank={tab=tab, slot=i}, hyperLink=nil})
local function set_Item_Info(self, tab)
    local itemLink, containerInfo, itemID= tab.hyperLink, nil, nil
    if tab.bag then
        containerInfo =C_Container.GetContainerItemInfo(tab.bag.bag, tab.bag.slot)
        if containerInfo then
            itemLink= containerInfo.hyperlink
            itemID= containerInfo.itemID
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
    end

    local topLeftText, bottomRightText, leftText, rightText, bottomLeftText, topRightText, r, g ,b, setIDItem--, isWoWItem--setIDItem套装

    if itemLink then
        itemID= itemID or GetItemInfoInstant(itemLink)

        local _, _, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, _, _, classID, subclassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(itemLink)

        setIDItem= setID and true or nil--套装
        itemLevel=  itemLevel or GetDetailedItemLevelInfo(itemLink) or 1

        if itemQuality then
            r,g,b = GetItemQualityColor(itemQuality)
        end

        local sellItem
        if tab.bag and not containerInfo.isLocked and e.CheckItemSell then
            sellItem= e.CheckItemSell(itemID, itemQuality)--检测是否是出售物品
        end

        if sellItem then--检测是否是出售物品
            if itemQuality==0 then
                topRightText='|A:Coin-Silver:0:0|a'
            else
                topLeftText= itemLevel and itemLevel>20 and (classID==2 or classID==4) and itemLevel
                topRightText= '|T236994:0|t'
            end

        elseif itemID==6948 then--炉石
            bottomLeftText= e.WA_Utf8Sub(GetBindLocation(), 2, 5)

        elseif containerInfo and containerInfo.hasLoot then--宝箱
            local dateInfo= e.GetTooltipData({bag=tab.bag, merchant=tab.merchant, guidBank=tab.guidBank, hyperLink=itemLink, red=true, onlyRed=true})--物品提示，信息
            topRightText= dateInfo.red and '|A:Monuments-Lock:0:0|a' or '|A:talents-button-undo:0:0|a'

        elseif C_Item.IsItemKeystoneByID(itemID) then--挑战
            local name=itemLink:match('%[(.-)]') or itemLink
            if name then
                topLeftText=name:match('%((%d+)%)') or C_MythicPlus.GetOwnedKeystoneLevel() --等级
                name=name:gsub('%((%d+)%)','')
                name=name:match('（(.-)）') or name:match('%((.-)%)') or name:match('%- (.+)') or name:match(keyStr)--名称
                if name then
                    bottomLeftText=e.WA_Utf8Sub(name, 3,6)
                end
                local activities=C_WeeklyRewards.GetActivities(1)--本周完成
                if activities then
                    local t=0
                    for _,v in pairs(activities) do
                        if v and v.level then
                            if v.level >t then t=v.level end
                        end
                    end
                    if t>0 then
                        leftText='|cnGREEN_FONT_COLOR:'..t..'|r'
                    end
                end
            end
        elseif e.itemPetID[itemID] then
            topRightText='|A:WildBattlePetCapturable:0:0|a'

        elseif itemQuality==0 and not (classID==2 or classID==4 ) then
            topRightText='|A:Coin-Silver:0:0|a'

        elseif classID==1 then--背包
            bottomLeftText= e.WA_Utf8Sub(itemSubType, 2,5)
            if containerInfo and not containerInfo.isBound then--没有锁定
                topRightText='|A:'..e.Icon.unlocked..':0:0|a'
            end
            --local dateInfo= e.GetTooltipData({bag=tab.bag, merchant=tab.merchant, guidBank=tab.guidBank, hyperLink=itemLink, text={bagNumStr}})
            --topLeftText= dateInfo.text[bagNumStr]--格数 CONTAINER_SLOTS  不知怎样处理--%2$s da %1$d |4scomparto:scomparti
         
        elseif classID==3 then--宝石
            if expacID== e.ExpansionLevel then
                local dateInfo= e.GetTooltipData({bag=tab.bag, merchant=tab.merchant, guidBank=tab.guidBank, hyperLink=itemLink, text={'(%+%d+ .+)', }})--物品提示，信息
                local text= dateInfo.text['(%+%d+ .+)']
                if text and text:find('%+') then
                    local str2, str3
                    if text:find(', ') then
                        str2, str3= text:match('(.-), (.+)')
                    elseif text:find('，') then
                        str2, str3= text:match('(.-)，(.+)')
                    else
                        str2, str3= text:match(andStr)
                    end
                    str2= str2 or text:match('%+%d+ .+')
                    if str2 then
                        str2= str2:match('%+%d+ (.+)')
                        leftText=e.WA_Utf8Sub(str2,1,3)
                        leftText= leftText and '|cffffffff'..leftText..'|r'
                        if str3 then
                            str3= str3:match('%+%d+ (.+)')
                            bottomLeftText= e.WA_Utf8Sub(str3,1,3)
                            bottomLeftText= bottomLeftText and '|cffffffff'..bottomLeftText..'|r'
                        end
                    end
                end
            end
            rightText= itemLevel

            topRightText= e.WA_Utf8Sub(subclassID==9 and itemType or itemSubType, 2,3)
            if expacID and expacID< e.ExpansionLevel then
                topRightText= '|cff606060'..topRightText..'|r'
            end

        elseif isCraftingReagent or classID==8 or classID==9 or (classID==0 and (subclassID==1 or subclassID==3 or subclassID==5)) or classID==19 or classID==7 then--附魔, 19专业装备 ,7商业技能
            local dateInfo= e.GetTooltipData({bag=tab.bag, merchant=tab.merchant, guidBank=tab.guidBank, hyperLink=itemLink, text={ITEM_SPELL_KNOWN, useStr,}, wow=true, red=true})--物品提示，信息 ITEM_SPELL_KNOWN = "已经学会";
            if not (classID==15 and (subclassID== 0 or subclassID==4)) then
                if classID==0 and subclassID==5 then
                    topRightText= e.WA_Utf8Sub(POWER_TYPE_FOOD, 2,5)--食物
                else
                    topRightText= e.WA_Utf8Sub(itemSubType==OTHER and itemType or itemSubType, 2,3)
                end
                if expacID and expacID< e.ExpansionLevel and itemID~='5512' and itemID~='113509' then--低版本，5512糖 食物,113509[魔法汉堡]
                    topRightText= '|cff606060'..topRightText..'|r'
                end
            end
            if dateInfo.text[ITEM_SPELL_KNOWN] then--"已经学会"
                bottomRightText= e.Icon.X2
            elseif dateInfo.red then--红色
                bottomRightText= e.Icon.O2
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
            if itemQuality and itemQuality>1 then
                local dateInfo= e.GetTooltipData({bag=tab.bag, merchant=tab.merchant, guidBank=tab.guidBank, hyperLink=itemLink, itemID=itemID,
                                                text={equipStr, pvpItemStr, upgradeStr, classStr, itemLevelStr}, wow=true, red=true})--物品提示，信息
                if dateInfo.text[itemLevelStr] then--传家宝
                    itemLevel= tonumber(dateInfo.text[itemLevelStr])
                end
                if dateInfo.text[equipStr] then--套装名称，
                    local text= dateInfo.text[equipStr]:match('(.+),') or dateInfo.text[equipStr]:match('(.+)，') or dateInfo.text[equipStr]
                    bottomLeftText=e.WA_Utf8Sub(text,3,5)
                elseif itemMinLevel>e.Player.level then--低装等
                    bottomLeftText='|cnRED_FONT_COLOR:'..itemMinLevel..'|r'
                elseif dateInfo.wow then--战网
                    bottomLeftText= e.Icon.wow2
                    if subclassID==0 then
                        if itemLevel and itemLevel>1 then
                            bottomLeftText= bottomLeftText.. itemLevel
                            local level= GetAverageItemLevel()
                            if not dateInfo.red then
                                bottomLeftText= bottomLeftText.. (level<itemLevel and e.Icon.up2 or e.Icon.select2)
                            else
                                bottomLeftText= bottomLeftText..e.Icon.X2
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
                                        text= select(2, math.modf(n/4))==0 and text..'\n' or text
                                        text=text..ClassNameIconTab[t]
                                        n= n+1
                                    end
                                end)
                            else
                                for className, icon in pairs (ClassNameIconTab) do
                                    if dateInfo.text[classStr]:find(className) then
                                        text= select(2, math.modf(n/4))==0 and text..'\n' or text
                                        text=text..icon
                                        n= n+1
                                    end
                                end
                            end
                            --rightText= dateInfo.red and e.Icon.X2 or e.Icon.select2
                            topLeftText= text
                        end
                    end
                end
                if dateInfo.text[pvpItemStr] then--PvP装备
                    rightText= '|A:Warfronts-BaseMapIcons-Horde-Barracks-Minimap:0:0|a'
                end
                if dateInfo.text[upgradeStr] then--"升级：%s/%s"
                    local min, max= dateInfo.text[upgradeStr]:match('(%d+)/(%d+)')
                    if min and max then
                        if min==max then
                            leftText= "|A:VignetteKill:0:0|a"
                        else
                            min, max= tonumber(min), tonumber(max)
                            leftText= '|cnGREEN_FONT_COLOR:'..max-min..'|r'
                        end
                    end
                end

                local invSlot = e.itemSlotTable[itemEquipLoc]
                if invSlot and itemLevel and itemLevel>1 then
                    if not dateInfo.red then--装等
                        local itemLinkPlayer =  GetInventoryItemLink('player', invSlot)
                        local upLevel, downLevel
                        if itemLinkPlayer then
                            local lv=GetDetailedItemLevelInfo(itemLinkPlayer)
                            if lv then
                                if itemLevel-lv>0 then
                                    upLevel=true
                                elseif itemLevel-lv< 0 and itemLevel>29 then
                                    downLevel=true
                                end
                            end
                        else
                            upLevel=true
                        end
                        if upLevel and (itemMinLevel and itemMinLevel<=e.Player.level or not itemMinLevel) then
                            topLeftText=e.Icon.up2
                        elseif downLevel then
                            topLeftText= e.Icon.down2
                        end
                        if itemQuality>2 or (not e.Player.levelMax and itemQuality==2) or upLevel then
                            topLeftText=itemLevel ..(topLeftText or '')
                        end
                    elseif itemMinLevel and itemMinLevel<=e.Player.level then--不可使用
                        topLeftText=e.Icon.X2
                    end
                end
                if (containerInfo and not containerInfo.isBound) or tab.guidBank or (tab.merchant and tab.merchant.buyBack) then--没有锁定
                    topRightText=itemSubType and e.WA_Utf8Sub(itemSubType,2,4) or '|A:'..e.Icon.unlocked..':0:0|a'
                end
            end
            if containerInfo and not containerInfo.isBound or not containerInfo then
                local isCollected
                bottomRightText, isCollected= e.GetItemCollected(itemLink, nil, true)--幻化
                if containerInfo and itemQuality and itemQuality<=1 then
                    if itemQuality==0 and isCollected then
                        topRightText='|A:Coin-Silver:0:0|a'
                    elseif not isCollected then
                        topRightText=itemSubType and e.WA_Utf8Sub(itemSubType,2,4)
                    end
                end
            end

        elseif classID==17 or (classID==15 and subclassID==2) or itemLink:find('Hbattlepet:(%d+)') then--宠物
            local speciesID = itemLink:match('Hbattlepet:(%d+)') or select(13, C_PetJournal.GetPetInfoByItemID(itemID))--宠物
            if speciesID then
                topLeftText= select(3, e.GetPetCollectedNum(speciesID)) or topLeftText--宠物, 收集数量
                local petType= select(3, C_PetJournal.GetPetInfoBySpeciesID(speciesID))
                if petType then
                    topRightText='|TInterface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[petType]..':0|t'
                end
            end

        elseif classID==15 and subclassID==5 then--坐骑
            local mountID = C_MountJournal.GetMountFromItem(itemID)
            if mountID then
                bottomRightText= select(11, C_MountJournal.GetMountInfoByID(mountID)) and e.Icon.X2 or e.Icon.star2
            end


        elseif classID==12 and itemQuality and itemQuality>0 then--任务
            topRightText= e.onlyChinese and '任务' or e.WA_Utf8Sub(itemSubType, 2,5)

        elseif itemQuality==7 or itemQuality==8 then--7传家宝，8 WoWToken
            topRightText=e.Icon.wow2
            if classID==0 and subclassID==8 and GetItemSpell(itemLink) then--传家宝，升级，物品
                local dateInfo= e.GetTooltipData({bag=tab.bag, merchant=tab.merchant, guidBank=tab.guidBank, hyperLink=itemLink, text={useStr}, wow=true, red=true})--物品提示，信息
                if dateInfo.text[useStr] and dateInfo.text[useStr]:find(UPGRADE) then--UPGRADE = "升级";
                    local weapon= dateInfo.text[useStr]:find(WEAPON)--WEAPON = "武器";
                    local shield= dateInfo.text[useStr]:find(SHIELDSLOT)--SHIELDSLOT = "盾牌";
                    local num
                    num= dateInfo.text[useStr]:match('%d+')
                    num= num and tonumber(num)
                    if num and (weapon or shield) then
                        rightText= '|cnGREEN_FONT_COLOR:'..num..'|r'--设置, 最高,等级
                        local heirloomNum=0
                        for _, heirloomID in pairs(C_Heirloom.GetHeirloomItemIDs() or {}) do
                            if heirloomID and C_Heirloom.PlayerHasHeirloom(heirloomID) then
                                local _, itemEquipLoc2, _, _, upgradeLevel, _, _, _, _, maxLevel= C_Heirloom.GetHeirloomInfo(heirloomID)
                                local maxUp=C_Heirloom.GetHeirloomMaxUpgradeLevel(heirloomID)
                                if upgradeLevel< maxUp and maxLevel< num-1  and (weapon and heirloomWeapontemEquipLocTab[itemEquipLoc2] or (not weapon and shield)) then
                                    heirloomNum= heirloomNum+1
                                end
                            end
                        end
                        topLeftText= heirloomNum==0 and '|cnRED_FONT_COLOR:'..heirloomNum..'|r' or heirloomNum
                    end
                end
            end

        elseif C_ToyBox.GetToyInfo(itemID) then--玩具
            bottomRightText= PlayerHasToy(itemID) and e.Icon.X2 or e.Icon.star2

        elseif itemStackCount==1 then
            local dateInfo= e.GetTooltipData({bag=tab.bag, merchant=tab.merchant, guidBank=tab.guidBank, hyperLink=itemLink, text={chargesStr}, wow=true, red=true})--物品提示，信息
            bottomLeftText=dateInfo.text[chargesStr]
            if dateInfo.wow then
                topRightText= e.Icon.wow2
            elseif dateInfo.red then
                topRightText= e.Icon.X2
            end
        end

        if (tab.bag and tab.bag.bag<=NUM_BAG_SLOTS+1 and tab.bag.bag>=0) or not tab.bag then
            local num=GetItemCount(itemLink, true)-GetItemCount(itemLink)--银行数量
            if num>0  then
                leftText= '+'..e.MK(num, 0)
            end
        end
    end

    if topRightText and not self.topRightText then
        self.topRightText=e.Cstr(self, {size=size})--size, nil, nil, nil, 'OVERLAY')
        self.topRightText:SetPoint('TOPRIGHT',2,0)
    end
    if self.topRightText then
        self.topRightText:SetText(topRightText or '')
        if r and g and b and topRightText then
            self.topRightText:SetTextColor(r,g,b)
        end
    end
    if topLeftText and not self.topLeftText then
        self.topLeftText=e.Cstr(self, {size=size})--size, nil, nil, nil, 'OVERLAY')
        self.topLeftText:SetPoint('TOPLEFT')
    end
    if self.topLeftText then
        self.topLeftText:SetText(topLeftText or '')
        if r and g and b and topLeftText then
            self.topLeftText:SetTextColor(r,g,b)
        end
    end
    if bottomRightText then
        if not self.bottomRightText then
            self.bottomRightText=e.Cstr(self, {size=size})--size, nil, nil, nil, 'OVERLAY')
            self.bottomRightText:SetPoint('BOTTOMRIGHT')
        end
    end
    if self.bottomRightText then
        self.bottomRightText:SetText(bottomRightText or '')
        if r and g and b and bottomRightText then
            self.bottomRightText:SetTextColor(r,g,b)
        end
    end

    if leftText and not self.leftText then
        self.leftText=e.Cstr(self, {size=size})--size, nil, nil, nil, 'OVERLAY')
        self.leftText:SetPoint('LEFT')
    end
    if self.leftText then
        self.leftText:SetText(leftText or '')
        if r and g and b and leftText then
            self.leftText:SetTextColor(r,g,b)
        end
    end

    if rightText and not self.rightText then
        self.rightText=e.Cstr(self, {size=size})--size, nil, nil, nil, 'OVERLAY')
        self.rightText:SetPoint('RIGHT')
    end
    if self.rightText then
        self.rightText:SetText(rightText or '')
        if r and g and b and rightText then
            self.rightText:SetTextColor(r,g,b)
        end
    end

    if bottomLeftText and not self.bottomLeftText then
        self.bottomLeftText=e.Cstr(self, {size=size})--size)
        self.bottomLeftText:SetPoint('BOTTOMLEFT')
    end
    if self.bottomLeftText then
        self.bottomLeftText:SetText(bottomLeftText or '')
        if r and g and b and bottomLeftText then
            self.bottomLeftText:SetTextColor(r,g,b)
        end
    end

    if setIDItem and not self.setIDItem then
        self.setIDItem=self:CreateTexture()
        self.setIDItem:SetAllPoints(self)
        self.setIDItem:SetAtlas(e.Icon.pushed)
    end
    if self.setIDItem then
        self.setIDItem:SetShown(setIDItem)
    end
end

local function setBags(self)--背包设置
    for _, itemButton in self:EnumerateValidItems() do
        if itemButton.hasItem then
            local slotID, bagID= itemButton:GetSlotAndBagID()--:GetID() GetBagID()
            set_Item_Info(itemButton, {bag={bag=bagID, slot=slotID}})
        else
            set_Item_Info(itemButton, {})
        end
    end
end


local function setMerchantInfo()--商人设置
    local selectedTab= MerchantFrame.selectedTab
    local page= selectedTab == 1 and MERCHANT_ITEMS_PER_PAGE or BUYBACK_ITEMS_PER_PAGE
    for i=1, page do
        local slot = selectedTab==1 and (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i) or i
        local itemButton= _G["MerchantItem"..i..'ItemButton']
        if itemButton then
            set_Item_Info(itemButton, {merchant={slot=slot, buyBack= selectedTab==2}})
        end
    end
end


--hooksecurefunc(GuildBankFrame,'Update', function(self)--Blizzard_GuildBankUI.lua
local MAX_GUILDBANK_SLOTS_PER_TAB = 98;
local NUM_SLOTS_PER_GUILDBANK_GROUP = 14;
local function setGuildBank()--公会银行,设置
    if GuildBankFrame and GuildBankFrame:IsVisible() then
        local tab = GetCurrentGuildBankTab() or 1;--Blizzard_GuildBankUI.lua
        for i=1, MAX_GUILDBANK_SLOTS_PER_TAB do
            local index = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP);
            if ( index == 0 ) then
                index = NUM_SLOTS_PER_GUILDBANK_GROUP;
            end
            local column = ceil((i-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP);
            local button = (GuildBankFrame.Columns[column] and GuildBankFrame.Columns[column].Buttons) and GuildBankFrame.Columns[column].Buttons[index];
            if button then
                set_Item_Info(button,{guidBank={tab=tab, slot=i}})
            end
        end
    end
end


local function set_BankFrameItemButton_Update(self)--银行, BankFrame.lua
    if not self.isBag then
        set_Item_Info(self, {bag={bag=self:GetParent():GetID(), slot=self:GetID()}})
    else
        local slot = self:GetBagID()
        local numFreeSlots
        numFreeSlots = C_Container.GetContainerNumFreeSlots(slot)
        if not numFreeSlots or numFreeSlots==0 then
            numFreeSlots= nil
        end
        if numFreeSlots and not self.numFreeSlots then
            self.numFreeSlots=e.Cstr(self, {color=true, justifyH='CENTER'})
            self.numFreeSlots:SetPoint('BOTTOM',0 ,6)
        end
        if self.numFreeSlots then
            self.numFreeSlots:SetText(numFreeSlots or '')
        end
    end
end


--####
--初始
--####
local function Init()

    --#################
    --拾取时, 弹出, 物品提示，信息
    --[[hooksecurefunc('LootUpgradeFrame_SetUp', function(self, itemLink)--AlertFrameSystems.lua
        print(id,addName, itemLink,'LootUpgradeFrame_SetUp')
        e.Set_Item_Stats(self, itemLink, self.lootItem and self.lootItem.Icon or self.Icon)
    end)
    hooksecurefunc('LootWonAlertFrame_SetUp', function(self, itemLink)
        print(id,addName, itemLink,'LootWonAlertFrame_SetUp')
        e.Set_Item_Stats(self, itemLink, self.lootItem and self.lootItem.Icon or self.Icon)
    end)
    hooksecurefunc('LegendaryItemAlertFrame_SetUp', function(self, itemLink)
        print(id,addName, itemLink,'LegendaryItemAlertFrame_SetUp')
        e.Set_Item_Stats(self, itemLink, self.lootItem and self.lootItem.Icon or self.Icon)
    end)]]

    --#####################################
    --职业图标 ClassNameIconTab['法师']=图标
    --#####################################
    for classID= 1, GetNumClasses() do
        local classInfo = C_CreatureInfo.GetClassInfo(classID)
        if classInfo and classInfo.className and classInfo.classFile then
            ClassNameIconTab[classInfo.className]= e.Class(nil, classInfo.classFile, false)--职业图标
        end
    end

    --###############
    --收起，背包小按钮
    --###############
    if C_CVar.GetCVarBool("expandBagBar") and C_CVar.GetCVarBool("combinedBags") then--MainMenuBarBagButtons.lua
        C_CVar.SetCVar("expandBagBar", '0')
    end

    --#########
    --背包, 数量
    --MainMenuBarBagButtons.lua
    if MainMenuBarBackpackButton then
        if MainMenuBarBackpackButtonCount then
            MainMenuBarBackpackButtonCount:SetShadowOffset(1, -1)
        end
        if e.Player.useColor and MainMenuBarBackpackButtonCount then
            MainMenuBarBackpackButtonCount:SetTextColor(e.Player.useColor.r, e.Player.useColor.g, e.Player.useColor.b, e.Player.useColor.a)
        end
        hooksecurefunc(MainMenuBarBackpackButton, 'UpdateFreeSlots', function(self)
            local totalFree
            totalFree= 0
            for i = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS-1 do
                local freeSlots, bagFamily= C_Container.GetContainerNumFreeSlots(i)
                if ( bagFamily == 0 ) then
                    totalFree = totalFree + freeSlots;
                end
            end
            self.freeSlots= totalFree
            if totalFree==0 then
                MainMenuBarBackpackButtonIconTexture:SetColorTexture(1,0,0,1)
                totalFree= '|cnRED_FONT_COLOR:'..totalFree..'|r'
            elseif totalFree<=5 then
                MainMenuBarBackpackButtonIconTexture:SetColorTexture(0,1,0,1)
                totalFree= '|cnGREEN_FONT_COLOR:'..totalFree..'|r'
            else
                MainMenuBarBackpackButtonIconTexture:SetColorTexture(0,0,0,0)
            end
            self.Count:SetText(totalFree)
        end)
    end
    --####
    --商人
    --####
    hooksecurefunc('MerchantFrame_UpdateMerchantInfo', setMerchantInfo)--MerchantFrame.lua
    hooksecurefunc('MerchantFrame_UpdateBuybackInfo', setMerchantInfo)

    --######################
    --##商人，物品，货币，数量
    --MerchantFrame.lua
    hooksecurefunc('MerchantFrame_UpdateAltCurrency', function(index, indexOnPage, canAfford)
        local itemCount = GetMerchantItemCostInfo(index);
        local frameName = "MerchantItem"..indexOnPage.."AltCurrencyFrame";
        local usedCurrencies = 0;
        if ( itemCount > 0 ) then
            for i=1, MAX_ITEM_COST do
                local _, itemValue, itemLink, currencyName = GetMerchantItemCostItem(index, i);
                if itemLink then
                    usedCurrencies = usedCurrencies + 1;
                    local button = _G[frameName.."Item"..usedCurrencies];
                    if button and button:IsShown() then
                        local num
                        if currencyName then
                            num= C_CurrencyInfo.GetCurrencyInfoFromLink(itemLink).quantity
                        else
                            num= GetItemCount(itemLink, true)
                        end
                        if itemValue and num then
                            if num>=itemValue then
                                num= '|cnGREEN_FONT_COLOR:'..e.MK(num,0)..'|r'
                            else
                                num= '|cnRED_FONT_COLOR:'..e.MK(num,0)..'|r'
                            end
                        end
                        if not button.quantityAll then
                            button.quantityAll= e.Cstr(button, {size=10, justifyH='RIGHT'})--10, nil, nil, nil, nil, 'RIGHT')
                            button.quantityAll:SetPoint('BOTTOMRIGHT', button, 'TOPRIGHT', 3,0)
                            button:EnableMouse(true)
                            button:SetScript('OnMouseDown', function(self)
                                if self.itemLink then
                                    local link= self.itemLink..(self.quantityAll.itemValue or '')
                                    if not ChatEdit_InsertLink(link) then
                                        ChatFrame_OpenChat(link)
                                    end
                                end
                            end)
                        end
                        button.quantityAll.itemValue= itemValue
                        button.quantityAll:SetText(num or '');
                    end
                end
            end
        end
    end)


    if IsAddOnLoaded("Bagnon") then
        local itemButton = Bagnon.ItemSlot or Bagnon.Item
        if (itemButton) and (itemButton.Update)  then
            hooksecurefunc(itemButton, 'Update', function(self)
                local slot, bag= self:GetSlotAndBagID()
                if slot and bag then
                    if self.hasItem then
                        local slotID, bagID= self:GetSlotAndBagID()--:GetID() GetBagID()
                        set_Item_Info(self, {bag={bag=bagID, slot=slotID}})
                    else
                        set_Item_Info(self, {})
                    end
                end
            end)
        end
        return
    elseif IsAddOnLoaded("Baggins") then
        hooksecurefunc(Baggins, 'UpdateItemButton', function(_, _, button, bagID, slotID)
            if button and bagID and slotID then
                set_Item_Info(button, {bag={bag=bagID, slot=slotID}})
            end
        end)
        return
    elseif IsAddOnLoaded('Inventorian') then
        local ADDON = LibStub("AceAddon-3.0"):GetAddon("Inventorian")
        local InvLevel = ADDON:NewModule('InventorianWoWToolsItemInfo')
        function InvLevel:Update()
            set_Item_Info(self, {bag={bag=self.bag, slot=self.slot}})
        end
        function InvLevel:WrapItemButton(item)
            hooksecurefunc(item, "Update", InvLevel.Update)
        end
        hooksecurefunc(ADDON.Item, "WrapItemButton", InvLevel.WrapItemButton)
        return
    end

    hooksecurefunc('ContainerFrame_GenerateFrame',function (self)
        for _, frame in ipairs(ContainerFrameSettingsManager:GetBagsShown()) do
            if not frame.SetBagInfo then
                setBags(frame)
                hooksecurefunc(frame, 'UpdateItems', setBags)
                frame.SetBagInfo=true
            end
        end
    end)
    hooksecurefunc('BankFrameItemButton_Update', set_BankFrameItemButton_Update)--银行

    --############
    --排序:从右到左
    --############
    local button= e.Cbtn(ContainerFrameCombinedBags.TitleContainer, {icon=true, size={20,20}})
    button:SetPoint('LEFT')
    button:SetAlpha(0.5)
    button:SetScript('OnClick', function(self, d)
        if not self.Menu then
            self.Menu= CreateFrame("Frame", id..addName..'Menu', self, "UIDropDownMenuTemplate")--菜单列表
            e.LibDD:UIDropDownMenu_Initialize(self.Menu, function(self2, level, type)
                local info={
                    text= e.onlyChinese and '反向整理背包' or REVERSE_CLEAN_UP_BAGS_TEXT,
                    checked= C_Container.GetSortBagsRightToLeft(),
                    tooltipOnButton=true,
                    tooltipTitle='C_Container.\nSetSortBagsRightToLeft',
                    tooltipText= e.onlyChinese and '整理背包会将物品移动到你最右边的背包里' or OPTION_TOOLTIP_REVERSE_CLEAN_UP_BAGS,
                    func= function()
                        C_Container.SetSortBagsRightToLeft(not C_Container.GetSortBagsRightToLeft() and true or false)
                    end,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)

                info={--排序:从右到左
                    --text= e.onlyChinese and '新物品: 最左边' or (BUG_CATEGORY11..'('..NEW_CAPS..'): '..HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT),
                    --text=(e.onlyChinese and '放入物品' or ITEMS)..': '.. (format(e.onlyChinese and '%s到%s' or INT_SPELL_POINTS_SPREAD_TEMPLATE, e.onlyChinese and '左' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_LEFT, e.onlyChinese and '右' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_RIGHT)),
                    text= e.onlyChinese and '将战利品放入最左边的背包' or REVERSE_NEW_LOOT_TEXT ,
                    icon= e.Icon.toLeft,
                    checked= C_Container.GetInsertItemsLeftToRight(),
                    tooltipOnButton=true,
                    tooltipTitle='C_Container.\nSetInsertItemsLeftToRight',
                    tooltipText= e.onlyChinese and '新物品会出现在你最左边的背包里' or OPTION_TOOLTIP_REVERSE_NEW_LOOT,
                    func= function()
                        C_Container.SetInsertItemsLeftToRight(not C_Container.GetInsertItemsLeftToRight() and true or false)
                    end,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)

                info={
                    text= e.onlyChinese and '整理背包: 自动' or (BAG_CLEANUP_BAGS..': '..AUTO_JOIN:gsub(JOIN,'')),
                    icon= 'bags-button-autosort-up',
                    checked=not C_Container.GetBackpackAutosortDisabled(),
                    tooltipOnButton=true,
                    tooltipTitle='C_Container.\nSetBackpackAutosortDisabled',
                    func= function()
                        C_Container.SetBackpackAutosortDisabled(not C_Container.GetBackpackAutosortDisabled() and true or false)
                    end,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)

                info={
                    text= e.onlyChinese and '整理银行: 自动' or (BAG_CLEANUP_BANK..': '..AUTO_JOIN:gsub(JOIN,'')),
                    icon= 'bags-button-autosort-up',
                    checked=not C_Container.GetBankAutosortDisabled(),
                    tooltipOnButton=true,
                    tooltipTitle='C_Container.\nSetBankAutosortDisabled',
                    func= function()
                        C_Container.SetBankAutosortDisabled(not C_Container.GetBankAutosortDisabled() and true or false)
                    end,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)

                info={
                    text= id..' '..addName,
                    isTitle=true,
                    notCheckable=true,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)

            end, "MENU")
        end
        e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
    end)

    if not MainMenuBarBackpackButton.OnClick then
        MainMenuBarBackpackButton:HookScript('OnClick', function(_, d)
            if d=='RightButton' then
                ToggleAllBags()
            end
        end)
    end

    panel:RegisterEvent('BANKFRAME_OPENED')
    panel:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED");
    panel:RegisterEvent("GUILDBANK_ITEM_LOCK_CHANGED");
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel(e.Icon.bag2..(e.onlyChinese and '物品信息' or addName), not Save.disabled, true)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)

            sel:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                if e.onlyChinese then
                    e.tips:AddDoubleLine('系统背包', '商人')
                else
                    e.tips:AddDoubleLine(BAGSLOT, MERCHANT)
                end
                e.tips:AddDoubleLine('Inventorian, Baggins', 'Bagnon')
                e.tips:Show()
            end)
            sel:SetScript('OnLeave', function() e.tips:Hide() end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
                panel:UnregisterEvent('ADDON_LOADED')

                FMTab={--附魔
                        ['主属性']= '主',
                        ['坐骑速度']= '骑',
                        [PRIMARY_STAT1_TOOLTIP_NAME]=  e.onlyChinese and "力" or strlower(e.WA_Utf8Sub(PRIMARY_STAT1_TOOLTIP_NAME, 1, 3)),
                        [PRIMARY_STAT2_TOOLTIP_NAME]=  e.onlyChinese and "敏" or strlower(e.WA_Utf8Sub(PRIMARY_STAT2_TOOLTIP_NAME, 1, 3)),
                        [PRIMARY_STAT3_TOOLTIP_NAME]=  e.onlyChinese and "耐" or strlower(e.WA_Utf8Sub(PRIMARY_STAT3_TOOLTIP_NAME, 1, 3)),
                        [PRIMARY_STAT4_TOOLTIP_NAME]=  e.onlyChinese and "智" or strlower(e.WA_Utf8Sub(PRIMARY_STAT4_TOOLTIP_NAME, 1, 3)),
                        [ITEM_MOD_CRIT_RATING_SHORT]= e.onlyChinese and '爆' or strlower(e.WA_Utf8Sub(STAT_CRITICAL_STRIKE, 1, 3)),
                        [ITEM_MOD_HASTE_RATING_SHORT]= e.onlyChinese and '急' or strlower(e.WA_Utf8Sub(STAT_HASTE, 1,3)),
                        [ITEM_MOD_MASTERY_RATING_SHORT]= e.onlyChinese and '精' or strlower(e.WA_Utf8Sub(STAT_MASTERY, 1,3)),
                        [ITEM_MOD_VERSATILITY]= e.onlyChinese and '全' or strlower(e.WA_Utf8Sub(STAT_VERSATILITY, 1,3)),
                        [ITEM_MOD_CR_AVOIDANCE_SHORT]= e.onlyChinese and '闪' or strlower(e.WA_Utf8Sub(ITEM_MOD_CR_AVOIDANCE_SHORT, 1,3)),
                        [ITEM_MOD_CR_LIFESTEAL_SHORT]= e.onlyChinese and '吸' or strlower(e.WA_Utf8Sub(ITEM_MOD_CR_LIFESTEAL_SHORT, 1,3)),
                        [ITEM_MOD_CR_SPEED_SHORT]= e.onlyChinese and '速' or strlower(e.WA_Utf8Sub(ITEM_MOD_CR_SPEED_SHORT, 1,3)),
                    }
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event == "GUILDBANKBAGSLOTS_CHANGED" or event =="GUILDBANK_ITEM_LOCK_CHANGED" then
        setGuildBank()--公会银行,设置
        if event=='GUILDBANKBAGSLOTS_CHANGED' then--打开公会银行时, 打开背包 GUILDBANKFRAME_OPENED
            local rankOrder= C_GuildInfo.GetGuildRankOrder(e.Player.guid)
            if rankOrder and rankOrder <=2 then
                OpenAllBags()
            end
        end

    elseif event=='BANKFRAME_OPENED' then--打开所有银行，背包
        for i=NUM_TOTAL_EQUIPPED_BAG_SLOTS+1, (NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS), 1 do
            ToggleBag(i);
        end
    end
end)