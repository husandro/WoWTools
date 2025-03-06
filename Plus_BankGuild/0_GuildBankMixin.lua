WoWTools_GuildBankMixin={}

function WoWTools_GuildBankMixin:GetFree(tabID)
    tabID = tabID or GetCurrentGuildBankTab()
    local numFreeSlots = 0
    local items={}
    for slotID = 1, 98 do
        local itemLink= GetGuildBankItemLink(tabID, slotID)
        if not itemLink then
            numFreeSlots = numFreeSlots + 1
        else
            table.insert(items, {slotID=slotID, itemLink=itemLink})
        end
    end
    return numFreeSlots, items
end