local id, e = ...
local addName=ITEMS..INFO
local Save={}
local panel=CreateFrame("Frame")

local itemUseString =ITEM_SPELL_CHARGES:gsub('%%d', '%(%%d%+%)')--(%d+)次
local KeyStone=CHALLENGE_MODE_KEYSTONE_NAME:gsub('%%s','(.+) ')--钥石
local text_EQUIPMENT_SETS= 	EQUIPMENT_SETS:gsub('%%s','(.+)')

local function set_Item_Info(self, itemLink, itemID, bag, merchantIndex, guildBank)
   -- local isBound, equipmentName, bagID, slotID
    local topLeftText, bottomRightText, leftText, bottomLeftText, topRightText, r, g ,b
    if itemLink then
        local _, _, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, _, _, classID, subclassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(itemLink)
        itemLevel=GetDetailedItemLevelInfo(itemLink) or itemLevel
        if itemQuality then
            r,g,b = GetItemQualityColor(itemQuality)
        end

        if bag and bag.hasLoot then--宝箱
            local tooltipData  = C_TooltipInfo.GetBagItem(bag.bagID, bag.slotID)
            if tooltipData and tooltipData.lines then
                local line= tooltipData.lines[2]
                TooltipUtil.SurfaceArgs(line)
                topRightText= line.leftText==LOCKED and '|A:Monuments-Lock:0:0|a' or '|A:talents-button-undo:0:0|a'
            end

        elseif C_Item.IsItemKeystoneByID(itemID) then--挑战
            local name=itemLink:match('%[(.-)]') or itemLink
            topLeftText=name:match('%((%d+)%)') or C_MythicPlus.GetOwnedKeystoneLevel() --等级
            name=name:gsub('%((%d+)%)','')
            name=name:match('（(.-)）') or name:match('%((.-)%)') or name:match('%- (.+)') name:match(KeyStone)--名称
            if name then
                bottomLeftText=e.WA_Utf8Sub(name, 2,5)
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
                    leftText='|cnRED_FONT_COLOR:'..t..'|r'
                end
            end
        elseif e.itemPetID[itemID] then
            topRightText='|A:WildBattlePetCapturable:0:0|a'

        elseif itemQuality and itemQuality==0 then
            topRightText='|A:Coin-Silver:0:0|a'

        elseif classID==1 then--背包
            if subclassID~=0 then
                bottomLeftText= e.WA_Utf8Sub(itemSubType, 2,5)
            end
            if bag and not bag.isBound then--没有锁定
                topRightText='|A:'..e.Icon.unlocked..':0:0|a'
            end

        elseif classID==8 or classID==3 or classID==9 or (classID==0 and (subclassID==1 or subclassID==3 or subclassID==5)) or classID==19 or classID==7 then--附魔, 宝石,19专业装备 ,7商业技能
            if classID==0 and subclassID==5 then
                topRightText= e.WA_Utf8Sub(POWER_TYPE_FOOD, 2,5)
            else
                topRightText= e.WA_Utf8Sub(itemSubType, 2,5)
            end
        elseif classID==2 and subclassID==20 then-- 鱼竿
                topRightText='|A:worldquest-icon-fishing:0:0|a'

        elseif classID==2 or classID==4 then--装备
            if itemQuality and itemQuality>1 then
                local invSlot = e.itemSlotTable[itemEquipLoc]
                local isEquippable= IsEquippableItem(itemLink)
                if invSlot and itemLevel and itemLevel>1 and isEquippable then--装等
                    local itemLinkPlayer =  GetInventoryItemLink('player', invSlot)
                    local upLevel
                    if itemLinkPlayer then
                        local lv=GetDetailedItemLevelInfo(itemLinkPlayer)
                        if lv and itemLevel-lv>1 then
                            upLevel=true
                        end
                    else
                        upLevel=true
                    end
                    if upLevel and (itemMinLevel and itemMinLevel<=UnitLevel('player') or not itemMinLevel) then
                        topLeftText=e.Icon.up2
                    end
                    if itemQuality>2 or (not e.Player.levelMax and itemQuality==2) or upLevel then
                        topLeftText=itemLevel ..(topLeftText or '')
                    end
                end

                local sourceID = ((not bag or not bag.isBound) or merchantIndex or guildBank) and select(2,C_TransmogCollection.GetItemInfo(itemLink))--幻化
                if sourceID then
                    bottomRightText = e.GetItemCollected(nil, sourceID, true) or bottomRightText
                end

                if itemQuality and itemQuality>1 and bag then
                    if not bag.isBound then--没有锁定
                        topRightText='|A:'..e.Icon.unlocked..':0:0|a'
                    elseif not isEquippable then--不可装备, 设置不成功,不知什么,情况
                        topRightText=e.Icon.X2
                    end
                end

                if bag and bag.isBound then
                    local tooltipData  = C_TooltipInfo.GetBagItem(bag.bagID, bag.slotID)--套装，名称
                    if tooltipData and tooltipData.lines then
                        local num=#tooltipData.lines
                        local line= tooltipData.lines[num-1]
                        TooltipUtil.SurfaceArgs(line)
                        local text= line.leftText
                        text= text and text:match(text_EQUIPMENT_SETS)
                        if text then
                            text= text:match('(.+),') or text:match('(.+)，') or text
                            bottomLeftText=e.WA_Utf8Sub(text,3,5)
                        end
                    end
                end
            end

        elseif setID then--装饰品
           local sets=C_TransmogSets.GetVariantSets(setID)
           if sets then
                bottomRightText=not sets.collected and e.Icon.okTransmog2
           end

        elseif classID==17 or (classID==15 and subclassID==2) or itemLink:find('Hbattlepet:(%d+)') then--宠物
            local speciesID = itemLink:match('Hbattlepet:(%d+)') or select(13, C_PetJournal.GetPetInfoByItemID(itemID))--宠物
            if speciesID then
                topLeftText= e.GetPetCollected(speciesID, nil, true) or topLeftText--宠物, 收集数量
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
            topRightText= e.onlyChinse and '任务' or e.WA_Utf8Sub(itemSubType, 2,5)

        elseif itemQuality==7 or itemQuality==8 then
            topRightText=e.Icon.wow2

        elseif C_ToyBox.GetToyInfo(itemID) then--玩具
            bottomRightText= PlayerHasToy(itemID) and e.Icon.X2 or e.Icon.star2

        elseif itemStackCount==1 then
            local spellName=GetItemSpell(itemLink)
            if spellName==LOOT_JOURNAL_LEGENDARIES_SOURCE_CRAFTED_ITEM then
                local specTable = GetItemSpecInfo(itemLink)
                if #specTable==0 then
                    topRightText=e.Icon.X2
                end
            elseif spellName and bag then--USE_COLON 仅限使用次数
                local tooltipData= C_TooltipInfo.GetBagItem(bag.bagID, bag.slotID)--套装，名称
                for _, line in ipairs(tooltipData.lines) do
                    TooltipUtil.SurfaceArgs(line)
                    local text= line.leftText and line.leftText:match(itemUseString)
                    if text then
                        bottomLeftText=text
                        break
                    end
                end
            end
        end
        if bag then--仅显示背包
            local num=GetItemCount(itemLink, true)-GetItemCount(itemLink)--银行数量
            if num>0 then
                leftText= '+'..e.MK(num, 2)
            end
        end

        if not topRightText and GetItemSpell(itemLink) then
            topRightText='|A:Soulbinds_Tree_Conduit_Icon_Utility:0:0|a'--使用图标
        end
    end
    if topRightText and not self.topRightText then
        self.topRightText=e.Cstr(self, nil, nil, nil, nil, 'OVERLAY')
        self.topRightText:SetPoint('TOPRIGHT',2,0)
    end
    if self.topRightText then
        self.topRightText:SetText(topRightText or '')
        if r and g and b and topRightText then
            self.topRightText:SetTextColor(r,g,b)
        end
    end
    if topLeftText and not self.topLeftText then
        self.topLeftText=e.Cstr(self, nil, nil, nil, nil, 'OVERLAY')
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
            self.bottomRightText=e.Cstr(self, nil, nil, nil, nil, 'OVERLAY')
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
        self.leftText=e.Cstr(self, nil, nil, nil, nil, 'OVERLAY')
        self.leftText:SetPoint('LEFT')
    end
    if self.leftText then
        self.leftText:SetText(leftText or '')
        if r and g and b and leftText then
            self.leftText:SetTextColor(r,g,b)
        end
    end
    if bottomLeftText and not self.bottomLeftText then
        self.bottomLeftText=e.Cstr(self)
        self.bottomLeftText:SetPoint('BOTTOMLEFT')
    end
    if self.bottomLeftText then
        self.bottomLeftText:SetText(bottomLeftText or '')
        if r and g and b and bottomLeftText then
            self.bottomLeftText:SetTextColor(r,g,b)
        end
    end
end

local function setBags(self)--背包设置
    for i, itemButton in self:EnumerateValidItems() do
        local itemLink, itemID, isBound--, equipmentName
        local slotID, bagID= itemButton:GetSlotAndBagID()--:GetID() GetBagID()
        local info
        if itemButton.hasItem then
            info=C_Container.GetContainerItemInfo(bagID, slotID)
            if info and info.hyperlink and info.itemID then
                itemLink= info.hyperlink
                itemID= info.itemID
                
                info.bagID=bagID
                info.slotID=slotID
            end
        end

        set_Item_Info(itemButton, itemLink, itemID, info, nil, nil)
    end
end


local function setMerchantInfo()--商人设置
    local selectedTab= MerchantFrame.selectedTab
    local page= selectedTab == 1 and MERCHANT_ITEMS_PER_PAGE or BUYBACK_ITEMS_PER_PAGE
    for i=1, page do
        local index = selectedTab==1 and (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i) or i
        local itemButton= _G["MerchantItem"..i..'ItemButton']
        if itemButton then
            local itemLink,itemID
            
            if itemButton:IsShown() then
                itemLink= GetMerchantItemLink(index)
                itemID= GetMerchantItemID(index)
            end
            set_Item_Info(itemButton, itemLink, itemID, nil, index, nil)
        end
    end
end

local MAX_GUILDBANK_SLOTS_PER_TAB = 98;
local NUM_SLOTS_PER_GUILDBANK_GROUP = 14;
local function setGuildBank()--公会银行,设置
    local tab = GetCurrentGuildBankTab();--Blizzard_GuildBankUI.lua
    for i=1, MAX_GUILDBANK_SLOTS_PER_TAB do
        local index = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP);
        if ( index == 0 ) then
            index = NUM_SLOTS_PER_GUILDBANK_GROUP;
        end
        local column = ceil((i-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP);
        local button = GuildBankFrame.Columns[column].Buttons[index];
        local itemLink= GetGuildBankItemLink(tab, i)
        local itemID= itemLink and GetItemInfoInstant(itemLink)
        set_Item_Info(button, itemLink, itemID, nil, nil, {tab, i})
	end
end

--####
--初始
--####
local function Init()
--[[    if Bagnon then
        local item = Bagnon.ItemSlot  or Bagnon.Item
        if (item) and (item.Update)  then
            hooksecurefunc(item, 'Update', Update)
        end
    elseif Baggins then
        hooksecurefunc(Baggins, 'UpdateItemButton',
            function (self, bag, button, bagID, slotID)
                Update(button,bagID, slotID)
        end)

    elseif Combuctor then
        local item = Combuctor.ItemSlot or Combuctor.Item
        if (item) and (item.Update)  then
            hooksecurefunc(item, 'Update', Update)
        end
    els]]
  --[[
  if IsAddOnLoaded('Inventorian') then
        C_Timer.After(3, function()
            local frame=InventorianBagFrame
            if frame then
                
            end
        end)
    else

]]

    hooksecurefunc(ContainerFrameCombinedBags,'Update', function(self)
        setBags(self)
    end)
    ContainerFrameCombinedBags.SetBagInfo=true
    hooksecurefunc('ContainerFrame_GenerateFrame',function (self, size, id2)
        for _, frame in ipairs(ContainerFrameSettingsManager:GetBagsShown()) do
            if not frame.SetBagInfo then
                setBags(frame)
                hooksecurefunc(frame, 'UpdateItems', setBags)
                frame.SetBagInfo=true
            end
        end
    end)
    
    hooksecurefunc('MerchantFrame_UpdateMerchantInfo',setMerchantInfo)--MerchantFrame.lua
    hooksecurefunc('MerchantFrame_UpdateBuybackInfo', setMerchantInfo)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED");
panel:RegisterEvent("GUILDBANK_ITEM_LOCK_CHANGED");

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel(addName, not Save.disabled, true)
            sel:SetScript('OnClick', function()
                if Save.disabled then
                    Save.disabled=nil
                else
                    Save.disabled=true
                end
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), 	REQUIRES_RELOAD)
            end)

            sel:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(BAGSLOT..' '..MERCHANT, EMBLEM_SYMBOL..INFO)
                e.tips:Show()
            end)
            sel:SetScript('OnLeave', function() e.tips:Hide() end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event == "GUILDBANKBAGSLOTS_CHANGED" or event =="GUILDBANK_ITEM_LOCK_CHANGED" then
        setGuildBank()--公会银行,设置

    end
end)