--世界地图任务
local isHooked


local function Init(self)--WorldQuestDataProvider.lua self.tagInfo
    if UnitAffectingCombat('player') then
        return
    elseif not WoWTools_WorldMapMixin.Save.ShowWorldQues_Name or not self.questID then-- or self.questID<=0 or self.questID>=2147483647 then
        if self.Text then self.Text:SetText('') end
        if self.worldQuestTypeTips then self.worldQuestTypeTips:SetShown(false) end
        return
    end


    local data= WoWTools_QuestMixin:GetRewardInfo(self.questID) or {}
    local text, texture

    if data.itemID then
        texture= data.texture

        if data.itemLevel and data.itemLevel>1 then
            text= data.itemLevel
        end

        local itemEquipLoc, _, classID = select(4, C_Item.GetItemInfoInstant(data.itemID))
        if classID==2 or classID==4 then
            local hex= select(4, WoWTools_ItemMixin:GetColor(data.itemID, data.quality))

            if hex and text then--物品，颜色
                text=hex..text..'|r'
            end

            local setLevelUp
            local invSlot = WoWTools_ItemMixin:GetEquipSlotID(itemEquipLoc)
            if invSlot and data.name and data.itemLevel and data.itemLevel>1 then--装等
                local itemLinkPlayer =  GetInventoryItemLink('player', invSlot)
                if itemLinkPlayer then
                    local lv= C_Item.GetDetailedItemLevelInfo(itemLinkPlayer)
                    if lv and data.itemLevel-lv>0 then
                        text= (text or '')..'|A:bags-greenarrow:0:0|a'
                        setLevelUp=true
                    end
                end
            end
            if not setLevelUp then
                local sourceID = select(2, C_TransmogCollection.GetItemInfo(data.itemID))--幻化
                if sourceID then
                    local collectedText, isCollected= WoWTools_CollectedMixin:Item(nil, sourceID, true)--物品是否收集 
                    if collectedText and not isCollected then
                        text= (text or '')..collectedText
                    end
                end
            end
        end

    elseif data.currencyID and data.totalRewardAmount and data.totalRewardAmount>0 then
        texture=data.texture

        local info, _, _, _, isMax, canWeek, canEarned, canQuantity= WoWTools_CurrencyMixin:GetInfo(data.currencyID, nil)
        if info and data.totalRewardAmount>1 then
            if isMax then
                text= format('|cnRED_FONT_COLOR:%d|r', data.totalRewardAmount)
            elseif canWeek or canEarned or canQuantity then
                text= format('|cnGREEN_FONT_COLOR:%d|r', data.totalRewardAmount)
            else
                text= data.totalRewardAmount
            end
        end

    else
        texture= data.texture
    end


    if self.Display and texture then
        SetPortraitToTexture(self.Display.Icon, texture)
        self.Display.Icon:SetSize(18, 18)
    end


    if not self.Text and text then
        self.Text= WoWTools_WorldMapMixin:Create_Wolor_Font(self, 12)
        self.Text:SetPoint('TOP', self, 'BOTTOM',0, 2)
    end
    if self.Text then
        self.Text:SetText(text or '')
    end

    local tagInfo
    if self.worldQuestType and self.worldQuestType ~= Enum.QuestTagType.Normal  then
        tagInfo= self.tagInfo or C_QuestLog.GetQuestTagInfo(self.questID)
    end
    if tagInfo then
        local inProgress = self.dataProvider:IsMarkingActiveQuests() and C_QuestLog.IsOnQuest(self.questID)

        local atlas= QuestUtil.GetWorldQuestAtlasInfo(self.questID, tagInfo, inProgress)--QuestUtils.lua (questID, tagInfo, inProgress)
        if not self.worldQuestTypeTips and atlas then
            self.worldQuestTypeTips=self:CreateTexture(nil, 'OVERLAY')
            self.worldQuestTypeTips:SetPoint('TOPRIGHT', self.Texture, 'TOPRIGHT', 5, 5)
            self.worldQuestTypeTips:SetSize(30, 30)
        end
        if atlas then
            self.worldQuestTypeTips:SetAtlas(atlas)
        end
    end
    if self.worldQuestTypeTips then
        self.worldQuestTypeTips:SetShown(tagInfo)
    end
end









function WoWTools_WorldMapMixin:Init_WorldQuest_Name()
    if isHooked or not self.Save.ShowWorldQues_Name then
        return
    end
    hooksecurefunc(WorldQuestPinMixin, 'RefreshVisuals', Init)--世界地图任务
    isHooked=true
end