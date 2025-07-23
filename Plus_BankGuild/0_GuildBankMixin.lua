--[[
QueryGuildBankLog(tab)
QueryGuildBankTab(tab)
QueryGuildBankText(tab)
]]
WoWTools_GuildBankMixin={}


--atlas==nil 没有<全部权限>
function WoWTools_GuildBankMixin:Get_Access(tabID)
    tabID = tabID or GetCurrentGuildBankTab()

    if not tabID
        or GuildBankFrame.noViewableTabs
        or GuildBankFrame.mode ~= "bank"
        or GetNumGuildBankTabs()<tabID
    then
        return '', 'Disabled'
    end

    local _, _, isViewable, canDeposit, numWithdrawals= GetGuildBankTabInfo(tabID)
    if not isViewable then
        return '', 'NotViewable'
    end

    local atlas, access
    if ( not canDeposit and numWithdrawals == 0 ) then
        access = WoWTools_DataMixin.onlyChinese and '|cffff2020（锁定）|r' or GUILDBANK_TAB_LOCKED;
        atlas= '|A:Monuments-Lock:0:0|a'

    elseif ( not canDeposit ) then
        access = WoWTools_DataMixin.onlyChinese and '|cffff2020（只能提取）|r' or GUILDBANK_TAB_WITHDRAW_ONLY;
        atlas= '|A:Cursor_OpenHand_32:0:0|a'

    elseif ( numWithdrawals == 0 ) then
        access = WoWTools_DataMixin.onlyChinese and '|cffff2020（只能存放）|r' or GUILDBANK_TAB_DEPOSIT_ONLY;
        atlas= '|A:Banker:0:0|a'

    else
        access = WoWTools_DataMixin.onlyChinese and '|cff20ff20（全部权限）|r' or GUILDBANK_TAB_FULL_ACCESS
    end

    return atlas, access
end



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

    if remainingWithdrawals and remainingWithdrawals > 0 then
        numOut= remainingWithdrawals

    elseif remainingWithdrawals==0 then--'无'
        numOut=false

    else --'无限制'
        numOut=true
    end

    return numOut, numIn
end
