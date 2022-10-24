local id, e = ...
local addName=ITEMS..INFO
local Save={}

local panel=CreateFrame("Frame")
panel.tips=CreateFrame("GameTooltip", id..addName, panel, "GameTooltipTemplate")
--local PlayerItemLevel=GetAverageItemLevel()
local itemUseString =ITEM_SPELL_CHARGES:gsub('%%d', '%(%%d%+%)')--(%d+)次

local function setItemInfo(self, itemLink, itemID, bag, merchantIndex)
    local isBound, equipmentName, bagID, slot
    if bag then
        isBound, equipmentName, bagID, slot = bag.isBound, bag.equipmentName, bag.bagID, bag.slot
    end
    local hex, topLeftText, bottomRightText, leftText, bottomLeftText
    if itemLink then
        local _, _, itemQuality, itemLevel, itemMinLevel, _, itemSubType, itemStackCount, itemEquipLoc, _, _, classID, subclassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(itemLink)
        itemLevel=GetDetailedItemLevelInfo(itemLink) or itemLevel
        hex= itemQuality and select(4, GetItemQualityColor(itemQuality))
        if itemEquipLoc and _G[itemEquipLoc] then--装备
            if itemQuality and itemQuality>1 and itemLevel and itemLevel>1 then--装等
                topLeftText=itemLevel
                if hex then
                    topLeftText='|c'..hex..topLeftText..'|r'
                end
                local invSlot = e.itemSlotTable[itemEquipLoc]
                if invSlot then
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
                        topLeftText= topLeftText..e.Icon.up2
                    end
                end
            end

            local sourceID = not isBound and select(2,C_TransmogCollection.GetItemInfo(itemLink))
            if sourceID and not C_TransmogCollection.PlayerKnowsSource(sourceID) then
                bottomRightText = select(2, C_TransmogCollection.PlayerCanCollectSource(sourceID)) and  e.Icon.okTransmog2 or e.Icon.transmogHide2
            end
        elseif setID then--套装
           local sets=C_TransmogSets.GetVariantSets(setID)
           if sets then
                bottomRightText=not sets.collected and e.Icon.okTransmog2
           end
        else
            if C_ToyBox.GetToyInfo(itemID) then--玩具
                bottomRightText= PlayerHasToy(itemID) and e.Icon.O2 or e.Icon.info2
            else
                local mountID = C_MountJournal.GetMountFromItem(itemID)--坐骑物品
                local speciesID = itemLink:match('Hbattlepet:(%d+)') or select(13, C_PetJournal.GetPetInfoByItemID(itemID))--宠物
                if mountID then
                    bottomRightText= select(11, C_MountJournal.GetMountInfoByID(mountID)) and e.Icon.O2 or e.Icon.info2
                elseif speciesID then
                    local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)
                    if numCollected and limit and limit>0 then
                        if numCollected==limit then
                            topLeftText= '|cnGREEN_FONT_COLOR:'..numCollected..'/'..limit..'|r'
                        else
                            topLeftText='|cnRED_FONT_COLOR:'..numCollected..'/'..limit..'|r'
                        end
                    end

                elseif itemStackCount==1 then--USE_COLON
                --[[if classID==8 and subclassID  and itemSubType then
                    bottomLeftText= e.WA_Utf8Sub(itemSubType, 2,5)
                else]]
                    if GetItemSpell(itemLink) then
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
            end
        end
        if bag then--仅显示背包
            local num=GetItemCount(itemLink)--银行数量
            leftText=GetItemCount(itemLink, true)-num
            leftText= leftText and leftText>0 and hex and '|c'..hex..'+'..e.MK(leftText, 2)..'|r' or nil
            if equipmentName then--装备管理, 名称
                bottomLeftText=e.WA_Utf8Sub(equipmentName,3,5)-- = function(input, size, letterSize):
                bottomLeftText = hex and '|c'..hex..bottomLeftText..'|r' or bottomLeftText
            end
        end
    end

    if topLeftText and not self.level then
        self.level=e.Cstr(self, nil, nil, nil, nil, 'OVERLAY')
        self.level:SetPoint('TOPLEFT')
    end
    if self.level then
        self.level:SetText(topLeftText or '')
    end
    if bottomRightText then
        if not self.bottomRightText then
            self.bottomRightText=e.Cstr(self, nil, nil, nil, nil, 'OVERLAY')
            self.bottomRightText:SetPoint('BOTTOMRIGHT')
        end
    end
    if self.bottomRightText then
        self.bottomRightText:SetText(bottomRightText or '')
    end

    if leftText and not self.leftText then
        self.leftText=e.Cstr(self, nil, nil, nil, nil, 'OVERLAY')
        self.leftText:SetPoint('LEFT')
    end
    if self.leftText then
        self.leftText:SetText(leftText or '')
    end
    if bottomLeftText and not self.bottomLeftText then
        self.bottomLeftText=e.Cstr(self)
        self.bottomLeftText:SetPoint('BOTTOMLEFT')
    end
    if self.bottomLeftText then
        self.bottomLeftText:SetText(bottomLeftText or '')
    end
end

local function setBags(self)
    for i, itemButton in self:EnumerateValidItems() do
        local itemLink, itemID, isBound, _, equipmentName
        local slot, bagID= itemButton:GetSlotAndBagID()--:GetID() GetBagID()
        if itemButton.hasItem then
            itemLink, _, _, itemID, isBound = select(7, GetContainerItemInfo(bagID, slot))
            equipmentName= select(2, GetContainerItemEquipmentSetInfo(bagID,slot))
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

local function setMerchantInfo()--商人
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
hooksecurefunc('MerchantFrame_UpdateMerchantInfo',setMerchantInfo)--MerchantFrame.lua
hooksecurefunc('MerchantFrame_UpdateBuybackInfo', setMerchantInfo)

--加载保存数据
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save
            
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)
--ContainerFrame.lua

--[[
function ContainerFrameSettingsManager:SetupBagsCombined()
	local container = ContainerFrameCombinedBags;
	self:SetupBagsGeneric(container);
	self:SetTokenTrackerOwner(container);
	self:SetMoneyFrameOwner(container);
end

function ContainerFrameMixin:UpdateItemContextMatching()
	EventRegistry:TriggerEvent("ItemButton.UpdateItemContextMatching", self:GetBagID());
end
]]