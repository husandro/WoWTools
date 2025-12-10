--世界地图任务

local function Create_Pin(self)
    self.worldQuestTypeTips=self:CreateTexture(nil, 'OVERLAY')
    self.worldQuestTypeTips:SetPoint('TOPRIGHT', self.Texture, 'TOPRIGHT', 5, 5)
    self.worldQuestTypeTips:SetSize(30, 30)

    self.rewardText= WoWTools_WorldMapMixin:Create_Wolor_Font(self, 12)
    self.rewardText:SetPoint('TOP', self, 'BOTTOM',0, 2)

    self.Display.Icon:SetSize(18, 18)
end





local function Clear_Pin(self)
    if self.worldQuestTypeTips then
        self.worldQuestTypeTips:SetTexture(0)
        self.rewardText:SetText('')
    end
end














local function Init()
    if not WoWToolsSave['Plus_WorldMap'].ShowWorldQues_Name then
        return
    end


    WoWTools_DataMixin:Hook(WorldQuestPinMixin, 'RefreshVisuals', function(self)
        if WoWTools_FrameMixin:IsLocked(self) then
            return
        end

        local data= WoWTools_QuestMixin:GetRewardInfo(self.questID)
        if not data then
            Clear_Pin(self)
            return

        elseif not self.worldQuestTypeTips then
            Create_Pin(self)
        end

        local text, texture

        if data.itemID then
            texture= data.texture

            local itemEquipLoc, _, classID = select(4, C_Item.GetItemInfoInstant(data.itemID))

            if classID==2 or classID==4 then
                if data.itemLevel and data.itemLevel>1 then
                    text= WoWTools_ItemMixin:GetColor(data.quality, {itemID=data.itemID, text=data.itemLevel})
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
                        local collectedText, isCollected= WoWTools_CollectionMixin:Item(nil, sourceID, true)--物品是否收集 
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
                    text= format('|cnWARNING_FONT_COLOR:%d|r', data.totalRewardAmount)
                elseif canWeek or canEarned or canQuantity then
                    text= format('|cnGREEN_FONT_COLOR:%d|r', data.totalRewardAmount)
                else
                    text= data.totalRewardAmount
                end
            end

        else
            texture= data.texture
        end

        local atlas
        if self.worldQuestType and self.worldQuestType ~= Enum.QuestTagType.Normal  then
            local tagInfo= self.tagInfo or C_QuestLog.GetQuestTagInfo(self.questID)
            if tagInfo then
                local inProgress = self.dataProvider:IsMarkingActiveQuests() and C_QuestLog.IsOnQuest(self.questID)
                atlas= QuestUtil.GetWorldQuestAtlasInfo(self.questID, tagInfo, inProgress)--QuestUtils.lua (questID, tagInfo, inProgress)
            end
        end

        if texture then
            self.Display.Icon:SetTexture(texture)
        end
        if atlas then
            self.worldQuestTypeTips:SetAtlas(atlas)
        else
            self.worldQuestTypeTips:SetTexture(0)
        end

       self.rewardText:SetText(text or '')
    end)



    Init=function()end
end











function WoWTools_WorldMapMixin:Init_WorldQuest_Name()
    Init()
end