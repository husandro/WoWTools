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



--numOut 可提取：数字，true无限，false禁用
--numIn 是否放入：true, false
function WoWTools_GuildBankMixin:GetNumWithdrawals(tabID)

    tabID= tabID or GetCurrentGuildBankTab()
    QueryGuildBankTab(tabID)

    local _, _, isViewable, canDeposit, numWithdrawals, remainingWithdrawals= GetGuildBankTabInfo(tabID)

    if not isViewable then
        return
    end

    local numOut
    local numIn= true

    if
        (canDeposit and numWithdrawals==0) --锁定
        or not canDeposit--只能提取
        or numWithdrawals==0 --只能存放
    then
        numIn= false
    end

    if remainingWithdrawals > 0  and remainingWithdrawals then
        numOut= remainingWithdrawals
    elseif (remainingWithdrawals==0 and numOut==false) then--'无'
        numOut=false
    else --'无限制'
        numOut=true
    end

    return numOut, numIn
end