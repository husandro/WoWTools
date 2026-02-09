--世界地图任务
local function Save()
    return  WoWToolsSave['Plus_WorldMap']
end





local function Create_Pin(self)
    self.Display.Icon2= self.Display:CreateTexture(nil, 'ARTWORK', nil, 6)
    self.Display.Icon2:SetPoint('TOPLEFT', self)
    self.Display.Icon2:SetPoint('BOTTOMRIGHT', self)
    WoWTools_ButtonMixin:AddMask(self.Display, true, self.Display.Icon2)

    self.Display.typeTexure=self.Display:CreateTexture(nil, 'ARTWORK', nil, 7)
    self.Display.typeTexure:SetPoint('TOPRIGHT', self)
    self.Display.typeTexure:SetSize(10, 10)

    self.Display.rewardText=self.Display:CreateFontString(nil, 'ARTWORK', 'WorldMapTextFont')-- WoWTools_WorldMapMixin:Create_Wolor_Font(self, 12)
    self.Display.rewardText:SetJustifyH('CENTER')
    self.Display.rewardText:SetPoint('TOP', self, 'BOTTOM', 0, 2)

    function self:wowtools_Clear()
        self.Display.Icon2:SetTexture(0)
        self.Display.Icon:SetAlpha(1)
        self.Display.typeTexure:SetTexture(0)
        self.Display.rewardText:SetText('')
    end
end














local function Init()
    if not Save().ShowWorldQues_Name then
        return
    end

    WoWTools_DataMixin:Hook(WorldQuestPinMixin, 'OnLoad', Create_Pin)

    WoWTools_DataMixin:Hook(WorldQuestPinMixin, 'RefreshVisuals', function(self)
        if not self.wowtools_Clear then
            Create_Pin(self)
        end

        local data= Save().ShowWorldQues_Name and WoWTools_QuestMixin:GetRewardInfo(self.questID)
        if not data then
            self:wowtools_Clear()
            return
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
                        local lv= WoWTools_ItemMixin:GetItemLevel(itemLinkPlayer)
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
                        if collectedText and isCollected==false then
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
                    text= format('|cnHIGHLIGHT_FONT_COLOR:%d|r', data.totalRewardAmount)
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

        self.Display.Icon2:SetTexture(texture or 0)
        self.Display.Icon:SetAlpha(texture and 0 or 1)

        if atlas and texture then
            self.Display.typeTexure:SetAtlas(atlas)
        else
            self.Display.typeTexure:SetTexture(0)
        end

        self.Display.rewardText:SetText(text or '')
        self.Display.rewardText:SetFontHeight(12)
    end)



    Init=function()end
end











function WoWTools_WorldMapMixin:Init_WorldQuest_Name()
    Init()
end