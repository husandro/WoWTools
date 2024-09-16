
--info, num, total, percent, isMax, canWeek, canEarned, canQuantity= WoWTools_CurrencyMixin:Get(currencyID, index)
WoWTools_CurrencyMixin={}

function WoWTools_CurrencyMixin:Get(currencyID, index, link)
    local info
    if not currencyID then
        link= link or (index and C_CurrencyInfo.GetCurrencyListLink(index))
        currencyID= link and C_CurrencyInfo.GetCurrencyIDFromLink(link)
    end
    if currencyID then
        info=C_CurrencyInfo.GetCurrencyInfo(currencyID)
        link= link or C_CurrencyInfo.GetCurrencyLink(currencyID)
    end

    if not info or not info.quantity or not info.discovered then
        return
    end

    local canQuantity= info.maxQuantity and info.maxQuantity>0--最大数 quantity maxQuantity
    local canWeek= info.canEarnPerWeek and info.quantityEarnedThisWeek and info.maxWeeklyQuantity and info.maxWeeklyQuantity>0--本周 quantityEarnedThisWeek maxWeeklyQuantity
    local canEarned= info.useTotalEarnedForMaxQty and canQuantity--赛季 totalEarned已获取 maxQuantity
    local isMax= (canWeek and info.maxWeeklyQuantity==info.quantityEarnedThisWeek)
            or (canEarned and info.totalEarned==info.maxQuantity)
            or (canQuantity and info.quantity==info.maxQuantity)
    local num, totale, percent
    if canWeek then
        num, totale= info.quantityEarnedThisWeek, info.maxWeeklyQuantity
    else
        num, totale=  info.quantity, info.maxQuantity
    end
    if not isMax then
        if canWeek then
            percent= math.modf(info.quantityEarnedThisWeek/info.maxWeeklyQuantity*100)
        elseif canEarned then
            percent= math.modf(info.totalEarned/info.maxQuantity*100)
        elseif canQuantity then
            percent= math.modf(info.quantity/info.maxQuantity*100)
        end
    end

    info.link= link or C_CurrencyInfo.GetCurrencyLink(currencyID)
    info.currencyID= currencyID
    return info, num, totale, percent, isMax, canWeek, canEarned, canQuantity
end
