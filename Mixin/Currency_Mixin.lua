local e= select(2, ...)


--info, num, total, percent, isMax, canWeek, canEarned, canQuantity= WoWTools_CurrencyMixin:GetInfo(currencyID, index)
WoWTools_CurrencyMixin={
--GetInfo
--GatName
}







local function get_info(currencyID, index, link)
    local info
    if not currencyID then
        link= link or (index and C_CurrencyInfo.GetCurrencyListLink(index))
        currencyID= link and C_CurrencyInfo.GetCurrencyIDFromLink(link)
    end
    if currencyID then
        info=C_CurrencyInfo.GetCurrencyInfo(currencyID)
        link= link or C_CurrencyInfo.GetCurrencyLink(currencyID)
    end
    return info, currencyID, link
end





function WoWTools_CurrencyMixin:GetInfo(currencyID, index, link)
    local info
    info, currencyID, link = get_info(currencyID, index, link)

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










function WoWTools_CurrencyMixin:GetName(currencyID, index, link)
    local info, num, _, _, isMax, canWeek, canEarned, canQuantity= self:GetInfo(currencyID, index, link)
    if info and info.name then
        num= num or 0
        return
            '|T'..(info.iconFileID or 0)..':0|t'
            ..(C_CurrencyInfo.IsAccountTransferableCurrency(info.currencyID) and '|cff00ccff' or '|cnENCHANT_COLOR:')
            ..e.cn(info.name)
            ..'|r'
            ..(
                isMax and '|cnRED_FONT_COLOR:'
                or ((canWeek or canEarned or canQuantity) and '|cnGREEN_FONT_COLOR:')
                or (num==0 and '|cff00ccff')
                or '|cffffffff'

            )
            ..' '..WoWTools_Mixin:MK(num, 3)
    end
end