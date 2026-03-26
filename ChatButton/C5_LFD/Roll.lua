
local function Save()
    return WoWToolsSave['ChatButton_LFD'] or {}
end




local function set_RollOnLoot(rollID, rollType, itemLink, notPrint)
    RollOnLoot(rollID, rollType)

    itemLink= itemLink or GetLootRollItemLink(rollID)

    if not itemLink or not notPrint then
        return
    end

    print(
        WoWTools_DataMixin.Icon.icon2
        ..'|A:groupfinder-eye-frame:0:0|a|cnGREEN_FONT_COLOR:'
        ..(rollType==1 and '|A:lootroll-toast-icon-need-up:0:0|a' or '|A:lootroll-toast-icon-transmog-up:0:0|a')
        ..itemLink
    )
end





--提示，剩余时间
local function set_Timer_Text(frame)--提示，剩余时间
    if frame and frame.Timer and not frame.Timer.Text and frame:IsShown() then
        frame.Timer.Text= WoWTools_LabelMixin:Create(frame.Timer)
        frame.Timer.Text:SetPoint('RIGHT')
        frame.Timer:HookScript("OnUpdate", function(self)
            self.Text:SetText(WoWTools_TimeMixin:SecondsToClock(self:GetValue()))
        end)
    end
end






local function set_ROLL_Check(frame, notPrint)
    local rollID= frame and frame.rollID
    if not Save().autoROLL or not rollID then
        set_Timer_Text(frame)--提示，剩余时间
        return
    end

    local _, _, _, quality, _, canNeed, canGreed, canDisenchant, reasonNeed, reasonGreed, reasonDisenchant, deSkillRequired, canTransmog = GetLootRollItemInfo(rollID)

    local itemLink = GetLootRollItemLink(rollID)

    if not canNeed or (IsInLFGDungeon() and quality and quality>=3) or not itemLink then
        set_RollOnLoot(rollID, 2, itemLink, notPrint)
        return
    end

    if canTransmog and not C_TransmogCollection.PlayerHasTransmogByItemInfo(itemLink) then--幻化
        local sourceID=select(2,C_TransmogCollection.GetItemInfo(itemLink))
        if sourceID then
            local hasItemData, canCollect =  C_TransmogCollection.PlayerCanCollectSource(sourceID)
            if hasItemData and canCollect then
                local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
                if sourceInfo and not sourceInfo.isCollected then
                    set_RollOnLoot(rollID, 1, itemLink, notPrint)
                    return
                end
            end
        end
    end

    local itemID, itemType, itemSubType, itemEquipLoc, _, classID, subclassID = C_Item.GetItemInfoInstant(itemLink)
    if C_Item.IsEquippableItem(itemLink) then
        for _, slot in ipairs({WoWTools_ItemMixin:GetEquipSlotID(itemEquipLoc)}) do--比较装等
            local slotLink= GetInventoryItemLink('player', slot)
            if slotLink then
                local slotItemLevel= WoWTools_ItemMixin:GetItemLevel(slotLink) or 0
                local itemLevel= WoWTools_ItemMixin:GetItemLevel(itemLink)
                if itemLevel then
                    local num=itemLevel-slotItemLevel
                    if num>0 then
                        set_RollOnLoot(rollID, 1, itemLink, notPrint)
                        return
                    end
                end
            end
        end
    end

    if classID==15 and subclassID==2 then--宠物物品
        set_RollOnLoot(rollID, 1, itemLink, notPrint)
        return

    elseif classID==15 and  subclassID==5 then--坐骑
        local mountID = C_MountJournal.GetMountFromItem(itemID)
        if mountID then
            local isCollected =select(11, C_MountJournal.GetMountInfoByID(mountID))
            if not isCollected then
                set_RollOnLoot(rollID, 1, itemLink, notPrint)
                return
            end
        end

    elseif C_ToyBox.GetToyInfo(itemID) and not PlayerHasToy(itemID) then--玩具 
        set_RollOnLoot(rollID, 1, itemLink, notPrint)
        return

--住宅装饰
    elseif C_Item.IsDecorItem(itemLink) then
        set_RollOnLoot(rollID, 1, itemLink, notPrint)
        return
    elseif classID==0 or subclassID==0 then
        set_RollOnLoot(rollID, 1, itemLink, notPrint)
        return
    end

    set_Timer_Text(frame)--提示，剩余时间
end









--#######
--自动ROLL
--GroupLootFrame.lua --frame.rollTime  frame.Timer
local function Init()
    WoWTools_DataMixin:Hook('GroupLootContainer_AddFrame', function(_, self)
        set_ROLL_Check(self)
    end)


    WoWTools_DataMixin:Hook('GroupLootContainer_Update', function(self)
        if self.rollFrames then
            for i=1, self.maxIndex or 0 do
                set_ROLL_Check(self.rollFrames[i], true)
            end
        end
    end)

    Init=function()end
end









function WoWTools_LFDMixin:Init_Roll_Plus()
    Init()
end