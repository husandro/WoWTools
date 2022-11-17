local id, e = ...
local addName=ITEMS..INFO
local Save={}

local panel=CreateFrame("Frame")
panel.tips=CreateFrame("GameTooltip", id..addName, panel, "GameTooltipTemplate")

local itemUseString =ITEM_SPELL_CHARGES:gsub('%%d', '%(%%d%+%)')--(%d+)次
local tradeskill={
    [1]='|T136243:0|t',--工程零件
    [4]='|T4620677:0|t',--珠宝加工	
    [5]='|T4620681:0|t',--布
    [6]='|T4620680:0|t',--皮革
    [7]='|T4620670:0|t',--金属与石材
    [8]='|T4620671:0|t',--烹饪
    [9]='|T4620675:0|t',--草药
    [10]='|A:DemonInvasion1:0:0|a',--元素	
    [12]='|T4620672:0|t',--附魔
    [16]='|T4620676:0|t',--铭文
}

local function setItemInfo(self, itemLink, itemID, bag, merchantIndex)
    local isBound, equipmentName, bagID, slot
    local topLeftText, bottomRightText, leftText, bottomLeftText, topRightText, r, g ,b
    if bag then
        isBound, equipmentName, bagID, slot = bag.isBound, bag.equipmentName, bag.bagID, bag.slot
    end

    if itemLink then
        local _, _, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, _, _, classID, subclassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(itemLink)
        itemLevel=GetDetailedItemLevelInfo(itemLink) or itemLevel
        if itemQuality then
            r,g,b = GetItemQualityColor(itemQuality)
        end
        if e.itemPetID[itemID] then
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

        elseif itemEquipLoc and _G[itemEquipLoc] then--装备  
                  
            if classID==2 and subclassID==20 then-- 鱼竿
                topRightText='|A:worldquest-icon-fishing:0:0|a'
            elseif itemQuality and itemQuality>1 then
                local invSlot = e.itemSlotTable[itemEquipLoc]
                if invSlot and itemLevel and itemLevel>1 then--装等
                    if itemQuality>2 then
                        topLeftText=itemLevel
                    end
                    local itemLinkPlayer =  GetInventoryItemLink('player', invSlot)
                    local upLevel
                    if itemLinkPlayer then
                        local lv=GetDetailedItemLevelInfo(itemLinkPlayer)
                        if lv and itemLevel-lv>=5 then
                            upLevel=true
                        end
                    else
                        upLevel=true
                    end
                    if upLevel and (itemMinLevel and itemMinLevel<=UnitLevel('player') or not itemMinLevel) then
                        topLeftText= (topLeftText or '')..e.Icon.up2
                    end
                end

                local sourceID = (not isBound or merchantIndex) and select(2,C_TransmogCollection.GetItemInfo(itemLink))
                
                if sourceID and not C_TransmogCollection.PlayerKnowsSource(sourceID) then
                    bottomRightText = select(2, C_TransmogCollection.PlayerCanCollectSource(sourceID)) and  e.Icon.okTransmog2 or e.Icon.transmogHide2
                end
                if itemQuality and itemQuality>1 then
                    if bag and not bag.isBound then--没有锁定
                        topRightText='|A:'..e.Icon.unlocked..':0:0|a'
                    else
                        local specTable = GetItemSpecInfo(itemLink) or {}
                        if subclassID~=0 and not (classID==4 and subclassID==1) and #specTable==0 then
                            topRightText=e.Icon.X2
                        elseif GetItemSpell(itemLink) then
                            topRightText='|A:Soulbinds_Tree_Conduit_Icon_Utility:0:0|a'--使用图标
                        end
                    end
                end
            end
        elseif setID then--装饰品
           local sets=C_TransmogSets.GetVariantSets(setID)
           if sets then
                bottomRightText=not sets.collected and e.Icon.okTransmog2
           end

        elseif classID==8 or classID==3 or classID==9 then--附魔, 宝石
            bottomLeftText= e.WA_Utf8Sub(itemSubType, 2,5)

        elseif classID==17 or (classID==15 and subclassID==2) or itemLink:find('Hbattlepet:(%d+)') then--宠物
            local speciesID = itemLink:match('Hbattlepet:(%d+)') or select(13, C_PetJournal.GetPetInfoByItemID(itemID))--宠物
            if speciesID then
                local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)
                if numCollected and limit and limit>0 then
                    if numCollected==limit then
                        topLeftText= '|cnGREEN_FONT_COLOR:'..numCollected..'/'..limit..'|r'
                    else
                        topLeftText='|cnRED_FONT_COLOR:'..numCollected..'/'..limit..'|r'
                    end
                end
                local petType= select(3, C_PetJournal.GetPetInfoBySpeciesID(speciesID))
                if petType then
                    bottomLeftText='|TInterface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[petType]..':0|t'
                end
            end
        elseif classID==15 and subclassID==5 then--坐骑
            local mountID = C_MountJournal.GetMountFromItem(itemID)
            if mountID then
                bottomRightText= select(11, C_MountJournal.GetMountInfoByID(mountID)) and e.Icon.X2 or e.Icon.info2
            end

        elseif classID==7 then--贸易材料
            if subclassID and tradeskill[subclassID] then
                --bottomLeftText=tradeskill[subclassID]
                topLeftText=tradeskill[subclassID]
            end
        elseif classID==12 and itemQuality and itemQuality>0 then--任务
            if bag then
                local questId, isActive = select(2, C_Container.GetContainerItemQuestInfo(bag.bagID, bag.slot))
                if questId then
                    if IsQuestCompletable(questId) then
                        bottomLeftText=DONE
                    elseif isActive then--已激活
                        bottomLeftText= e.WA_Utf8Sub(itemSubType, 2,5)
                    elseif not IsUsableItem(itemLink) then
                        topRightText=e.Icon.O2
                    end
                end
                panel.tips:SetOwner(panel, "ANCHOR_NONE")
                panel.tips:ClearLines()
                if merchantIndex then
                    panel.tips:SetMerchantItem(merchantIndex)
                else
                    panel.tips:SetBagItem(bagID,slot)
                end
                for n=3, 4 do--panel.tips:NumLines() do
                    local lineText=_G[id..addName..'TextLeft'..n] and _G[id..addName..'TextLeft'..n]:GetText()
                    if lineText then
                        local useNum=lineText:match(itemUseString)
                        if useNum then
                            bottomLeftText=useNum
                            break
                        end
                    end
                end
            end
        elseif itemQuality==7 or itemQuality==8 then
            bottomLeftText=e.Icon.wow2

        elseif C_ToyBox.GetToyInfo(itemID) then--玩具
            bottomRightText= PlayerHasToy(itemID) and e.Icon.X2 or e.Icon.info2

        elseif bag and IsUsableItem(itemLink)==false then--不可使用
            topRightText=e.Icon.info2

        elseif itemStackCount==1 then
            local spellName=GetItemSpell(itemLink)
            if spellName==LOOT_JOURNAL_LEGENDARIES_SOURCE_CRAFTED_ITEM then
                local specTable = GetItemSpecInfo(itemLink)
                if #specTable==0 then
                    topRightText=e.Icon.X2
                end
            elseif spellName then--USE_COLON
                panel.tips:SetOwner(panel, "ANCHOR_NONE")
                panel.tips:ClearLines()
                if merchantIndex then
                    panel.tips:SetMerchantItem(merchantIndex)
                else
                    panel.tips:SetBagItem(bagID,slot)
                end
                for n=3, 4 do--panel.tips:NumLines() do
                    local lineText=_G[id..addName..'TextLeft'..n] and _G[id..addName..'TextLeft'..n]:GetText()
                    if lineText then
                        local useNum=lineText:match(itemUseString)
                        if useNum then
                            bottomLeftText=useNum
                            break
                        end
                    end
                end
            end
        end
        if bag then--仅显示背包
            local num=GetItemCount(itemLink)--银行数量
            leftText=GetItemCount(itemLink, true)-num
            leftText= (leftText and leftText>0 ) and '+'..e.MK(leftText, 2) or nil
            if equipmentName then--装备管理, 名称
                bottomLeftText=e.WA_Utf8Sub(equipmentName,3,5)
            end
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
        local itemLink, itemID, isBound, _, equipmentName
        local slot, bagID= itemButton:GetSlotAndBagID()--:GetID() GetBagID()
        if itemButton.hasItem then
            itemLink, _, _, itemID, isBound = select(7, C_Container.GetContainerItemInfo(bagID, slot))
            equipmentName= select(2, C_Container.GetContainerItemEquipmentSetInfo(bagID,slot))
        end
        setItemInfo(itemButton, itemLink, itemID, {isBound=isBound, equipmentName=equipmentName, bagID=bagID, slot=slot})
    end
end
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
            setItemInfo(itemButton, itemLink, itemID, nil, index)
        end
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
    hooksecurefunc('MerchantFrame_UpdateMerchantInfo',setMerchantInfo)--MerchantFrame.lua
    hooksecurefunc('MerchantFrame_UpdateBuybackInfo', setMerchantInfo)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

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
                print(addName, e.GetEnabeleDisable(not Save.disabled), 	REQUIRES_RELOAD)
            end)

            sel:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(BAGSLOT..' '..MERCHANT, EMBLEM_SYMBOL..INFO)
                e.tips:Show()
            end)
            sel:SetScript('OnLeave', function() e.tips:Hide() end)

            if not Save.disabled then
                Init()
            end
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)