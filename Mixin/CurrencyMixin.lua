local e= select(2, ...)


--info, num, total, percent, isMax, canWeek, canEarned, canQuantity= WoWTools_CurrencyMixin:GetInfo(currencyID, index)
WoWTools_CurrencyMixin={}







local function get_info(currencyID, index, link)
    local info
    if not currencyID then
        link= link or (index and C_CurrencyInfo.GetCurrencyListLink(index))
        currencyID= link and C_CurrencyInfo.GetCurrencyIDFromLink(link)
    end
   if not currencyID or currencyID<=0 then
        return
   end
    info=C_CurrencyInfo.GetCurrencyInfo(currencyID)
    link= link or C_CurrencyInfo.GetCurrencyLink(currencyID)
    return info, currencyID, link
end


--移过，提示
function WoWTools_CurrencyMixin:Find(find, currencyID, name)--选中提示
    if not TokenFrame:IsVisible() then
        return
    end
    if find then
        for index=1, C_CurrencyInfo.GetCurrencyListSize() do
            local data= C_CurrencyInfo.GetCurrencyListInfo(index)
            if data and data.name and data.currencyID then
                if data.currencyID==currencyID or data.name==name then
                    TokenFrame.ScrollBox:ScrollToElementDataIndex(index)
                    for _, frame in pairs(TokenFrame.ScrollBox:GetFrames() or {}) do
                        if frame.Content and frame.elementData then
                            if frame.elementData.currencyID==currencyID or frame.elementData.name==name then
                                frame.Content.BackgroundHighlight:SetAlpha(0.2)
                            else
                                frame.Content.BackgroundHighlight:SetAlpha(0)
                            end
                        end
                    end
                    break
                end
            end
        end
    else
        for _, frame in pairs(TokenFrame.ScrollBox:GetFrames() or {}) do
            if frame.Content then
               frame.Content.BackgroundHighlight:SetAlpha(0)
            end
        end
    end
end



--IsMax
function WoWTools_CurrencyMixin:IsMax(currencyID, index, link)
    if not currencyID then
        local info= get_info(currencyID, index, link)
        currencyID= info and info.currencyID
    end
    if currencyID then
        return
            C_CurrencyInfo.PlayerHasMaxQuantity(currencyID),
            C_CurrencyInfo.PlayerHasMaxWeeklyQuantity(currencyID),
            currencyID
    end
end

--GetAccountIcon
function WoWTools_CurrencyMixin:GetAccountIcon(currencyID, index, link)
    if not currencyID then
        local info= get_info(currencyID, index, link)
        currencyID= info and info.currencyID
    end
    if currencyID then
        if C_CurrencyInfo.IsAccountTransferableCurrency(currencyID) then--可转移
            local isWide, isTrans, col= false, true, '|cff00ccff'
            return '|A:warbands-transferable-icon:18:0|a', false, isTrans, col, 'warbands-transferable-icon'

        elseif C_CurrencyInfo.IsAccountWideCurrency(currencyID) then--战网
            local isWide, isTrans, col= true, false, '|cff00ccff'
            return '|A:questlog-questtypeicon-account:0:0|a', isWide, false, col, 'questlog-questtypeicon-account'
        end
    end
end
-- local isWide, isTrans, col, atlas= WoWTools_CurrencyMixin:GetAccountIcon(currencyID, index, link)


--GetLink
function WoWTools_CurrencyMixin:GetLink(currencyID, index, link, isCN)
    local info
    info, _, link = get_info(currencyID, index, link)
    if link and isCN and WoWTools_Chinese_Mixin and info and info.name then
        local cnName= e.cn(info.name)
        if cnName and info.name~=info.name then
            link=link:gsub(info.name, cnName)
        end
    end
    return link, info
end





--GetInfo
function WoWTools_CurrencyMixin:GetInfo(currencyID, index, link)
    local info
    info, currencyID, link = get_info(currencyID, index, link)

    if not currencyID or not info or not info.quantity or not info.discovered then
        return
    end

    local canQuantity= info.maxQuantity and info.maxQuantity>0--最大数 quantity maxQuantity
    local canWeek= info.canEarnPerWeek and info.quantityEarnedThisWeek and info.maxWeeklyQuantity and info.maxWeeklyQuantity>0--本周 quantityEarnedThisWeek maxWeeklyQuantity
    local canEarned= info.useTotalEarnedForMaxQty and canQuantity--赛季 totalEarned已获取 maxQuantity
    local isMax= C_CurrencyInfo.PlayerHasMaxQuantity(currencyID) or C_CurrencyInfo.PlayerHasMaxWeeklyQuantity(currencyID)
            --(canWeek and info.maxWeeklyQuantity==info.quantityEarnedThisWeek)
            --or (canEarned and info.totalEarned==info.maxQuantity)
           --or (canQuantity and info.quantity==info.maxQuantity)
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









--GetName
function WoWTools_CurrencyMixin:GetName(currencyID, index, link)
    local info, num, _, _, isMax, canWeek, canEarned, canQuantity= self:GetInfo(currencyID, index, link)
    if info and info.name then
        num= num or 0
        return
            '|T'..(info.iconFileID or 0)..':0|t'--图标
            ..(
                ('|c'..select(4, C_Item.GetItemQualityColor(info.quality or 1)))--颜色
                or '|cnENCHANT_COLOR:'
            )
            ..e.cn(info.name)--名称
            ..'|r'
            ..(
                isMax and '|cnRED_FONT_COLOR:'
                or ((canWeek or canEarned or canQuantity) and '|cnGREEN_FONT_COLOR:')
                or (num==0 and '|cff00ccff')
                or '|cffffffff'

            )--数量，颜色
            ..' '..WoWTools_Mixin:MK(num, 3)--数量
            ..'|r'
            ..(self:GetAccountIcon(info.currencyID) or ''),
            --..(C_CurrencyInfo.IsAccountTransferableCurrency(info.currencyID) and '|A:questlog-questtypeicon-account:0:0|a' or ''),--战团

            info--返回，第二参数
    else
        if link then
            return link

        elseif currencyID then
            local icon= self:GetAccountIcon(currencyID)
            return icon
                and '|cff00ccff'..currencyID..'|r'..icon
                or currencyID
        else
            return index
        end
    end
end





function WoWTools_CurrencyMixin:GetAccountInfo(currencyID)
    if currencyID and currencyID>0 then
        if C_CurrencyInfo.IsAccountCharacterCurrencyDataReady() then
            local new={}
            local num=0
            for _, tab in pairs(C_CurrencyInfo.FetchCurrencyDataFromAccountCharacters(currencyID) or {}) do
                if e.WoWDate[tab.characterGUID] then
                    tab.faction= e.WoWDate[tab.characterGUID].faction
                end
                table.insert(new, tab)
                num= num+ tab.quantity
            end
            return num, new
        else
            C_CurrencyInfo.RequestCurrencyDataForAccountCharacters()
        end
    end
    return 0, {}
end
--[[
accountCurrencyData = C_CurrencyInfo.FetchCurrencyDataFromAccountCharacters(currencyID)
characterGUID	string : WOWGUID	
characterName	string	
currencyID	number	
quantity	number
faction 
]]