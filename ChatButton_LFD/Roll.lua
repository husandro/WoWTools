





--#######
--自动ROLL
--GroupLootFrame.lua --frame.rollTime  frame.Timer
local function Init()
    local function set_RollOnLoot(rollID, rollType, link)
        RollOnLoot(rollID, rollType)
        link= link or GetLootRollItemLink(rollID)
        if link then
                print('|A:groupfinder-eye-frame:0:0|a|cnGREEN_FONT_COLOR:'
                    ..(rollType==1 and '|A:lootroll-toast-icon-need-up:0:0|a' or '|A:lootroll-toast-icon-transmog-up:0:0|a')
                    ..link
                )
            --end)
        end
    end
    local function set_Timer_Text(frame)--提示，剩余时间
        if frame and frame.Timer and not frame.Timer.Text and frame:IsShown() then
            frame.Timer.Text= WoWTools_LabelMixin:CreateLabel(frame.Timer)
            frame.Timer.Text:SetPoint('RIGHT')
            frame.Timer:HookScript("OnUpdate", function(self2)
                self2.Text:SetText(WoWTools_TimeMixin:SecondsToClock(self2:GetValue()))
            end)
        end
    end
    local function set_ROLL_Check(frame)
        local rollID= frame and frame.rollID
        if not WoWTools_LFDMixin.Save.autoROLL or not rollID then
            set_Timer_Text(frame)--提示，剩余时间
            return
        end

        local _, _, _, quality, _, canNeed, canGreed, canDisenchant, reasonNeed, reasonGreed, reasonDisenchant, deSkillRequired, canTransmog = GetLootRollItemInfo(rollID)

        local link = GetLootRollItemLink(rollID)

        if not canNeed or (IsInLFGDungeon() and quality and quality>=4) or not link then
            set_RollOnLoot(rollID, canNeed and 1 or 2, link)
            return
        end

        if canTransmog and not C_TransmogCollection.PlayerHasTransmogByItemInfo(link) then--幻化
            local sourceID=select(2,C_TransmogCollection.GetItemInfo(link))
            if sourceID then
                local hasItemData, canCollect =  C_TransmogCollection.PlayerCanCollectSource(sourceID)
                if hasItemData and canCollect then
                    local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
                    if sourceInfo and not sourceInfo.isCollected then
                        set_RollOnLoot(rollID, 1, link)
                        return
                    end
                end
            end
        end

        local itemID, _, _, itemEquipLoc, _, classID, subclassID = C_Item.GetItemInfoInstant(link)
        local slot=WoWTools_ItemMixin:GetEquipSlotID(itemEquipLoc)--比较装等
        if slot then
            local slotLink=GetInventoryItemLink('player', slot)
            if slotLink then
                local slotItemLevel= C_Item.GetDetailedItemLevelInfo(slotLink) or 0
                local itemLevel= C_Item.GetDetailedItemLevelInfo(link)
                if itemLevel then
                    local num=itemLevel-slotItemLevel
                    if num>0 then
                        set_RollOnLoot(rollID, 1, link)
                        return
                    end
                end
            --else--没有装备
                --set_RollOnLoot(rollID, 1, link)
                --return
            end

        elseif classID==15 and subclassID==2 then--宠物物品
            set_RollOnLoot(rollID, 1, link)
            return

        elseif classID==15 and  subclassID==5 then--坐骑
            local mountID = C_MountJournal.GetMountFromItem(itemID)
            if mountID then
                local isCollected =select(11, C_MountJournal.GetMountInfoByID(mountID))
                if not isCollected then
                    set_RollOnLoot(rollID, 1, link)
                    return
                end
            end

        elseif C_ToyBox.GetToyInfo(itemID) and not PlayerHasToy(itemID) then--玩具 
            set_RollOnLoot(rollID, 1, link)
            return

        elseif classID==0 or subclassID==0 then
            set_RollOnLoot(rollID, 1, link)
            return
        end

        set_Timer_Text(frame)--提示，剩余时间
    end

    hooksecurefunc('GroupLootContainer_AddFrame', function(_, frame)
        set_ROLL_Check(frame)
    end)

    hooksecurefunc('GroupLootContainer_Update', function(self)
        for i=1, self.maxIndex do
            local frame = self.rollFrames[i]
            if frame and frame:IsShown()  then
                set_ROLL_Check(frame)
            end
        end
    end)

end









function WoWTools_LFDMixin:Init_Roll_Plus()
    Init()
end