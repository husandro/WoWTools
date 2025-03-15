local e= select(2, ...)
local function Save()
    return WoWTools_GuildBankMixin.Save
end
local MAX_GUILDBANK_SLOTS_PER_TAB= 96



local function Init(self)
    if WoWTools_GuildBankMixin.isInRun then--禁用，按钮移动事件
        self.isInRun=true--停止，已运行
        return
    end

    local saveItemSeconds= Save().saveItemSeconds or 0.8
    local currentIndex = GetCurrentGuildBankTab() -- 当前 Tab

    local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expansionID, setID, isCraftingReagent
    --local itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subClassID, itemLink
    local items = {}
    for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
        itemLink = GetGuildBankItemLink(currentIndex, slot)
        if itemLink then
            itemName, _, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expansionID, setID, isCraftingReagent= C_Item.GetItemInfo(itemLink)
           -- itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subClassID = C_Item.GetItemInfoInstant(itemLink)
            table.insert(items, {
                slot = slot,
                link = itemLink,
                id = C_Item.GetItemInfoInstant(itemLink),
                rarity = itemQuality,
                type = classID,
                subType = subclassID,
            })
        end
    end

    table.sort(items, function(a, b)
        if a.type == b.type then
            if a.subType == b.subType then
                if a.rarity == b.rarity then
                    return a.id < b.id
                end
                return a.rarity > b.rarity
            end
            return a.subType < b.subType
        end
        return a.type < b.type
    end)

    local find

    local function sortItems()
        if
            not self:IsVisible()
            or self.isInRun
            or GetCurrentGuildBankTab()~= currentIndex
           
        then
            self.isInRun= nil
            WoWTools_GuildBankMixin.isInRun= nil
            print(WoWTools_GuildBankMixin.addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '排序' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_SORT_BY)..'|r', e.onlyChinese and '中断' or INTERRUPT  )
            return
        end

        find=false
        for i, item in pairs(items) do
            
            if item.id and item.slot ~= i then
                PickupGuildBankItem(currentIndex, item.slot)
                PickupGuildBankItem(currentIndex, i)
               -- items[i]={}
                find=true
                print(i..')', item.link)
                break
            end
        end

        if not find then
            print(WoWTools_GuildBankMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '提取' or WITHDRAW)..'|r', e.onlyChinese and '完成' or COMPLETE )
            return
        end

        C_Timer.After(saveItemSeconds, function()
            sortItems()
        end)
    end

    sortItems()
end


function WoWTools_GuildBankMixin:Init_Plus_Sort(frame, ...)
    if frame then
        --Init(frame)
    end
end