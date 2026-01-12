
local function Save()
	return WoWToolsSave['Currency2']
end

local MaxTabs={}





local function Currency_Max(curID)--已达到资源上限
    local tab, num= {}, 0
    if curID then
        if MaxTabs[curID] then
            return
        end
        local isMax, isMaxWeek= WoWTools_CurrencyMixin:IsMax(curID)
        if isMax or isMaxWeek then
            tab[curID]={isMax=isMax, isMaxWeek=isMaxWeek}
            num=1
        else
            return
        end

    else
        for i=1, C_CurrencyInfo.GetCurrencyListSize() do
            local isMax, isMaxWeek, currencyID= WoWTools_CurrencyMixin:IsMax(nil, i)
            if (isMax or isMaxWeek) and not MaxTabs[currencyID] then
                tab[currencyID]={isMax=isMax, isMaxWeek=isMaxWeek}
                num=num+1
            end
        end

        for currencyID, _ in pairs(Save().tokens) do
            if not MaxTabs[currencyID] and not tab[currencyID] then
                local isMax, isMaxWeek= WoWTools_CurrencyMixin:IsMax(currencyID)
                if isMax or isMaxWeek then
                    tab[curID]={isMax=isMax, isMaxWeek=isMaxWeek}
                    num=num+1
                end
            end
        end

    end

    if num>0 then
        print(WoWTools_CurrencyMixin.addName..WoWTools_DataMixin.Icon.icon2)

        local index=0
        for currencyID, info in pairs(tab) do
            index= index+1
            print(
                '   '..index..')',
                WoWTools_CurrencyMixin:GetLink(currencyID, nil, nil, true),
                info.isMaxWeek and (WoWTools_DataMixin.onlyChinese and '本周' or GUILD_CHALLENGES_THIS_WEEK) or ''
            )
            MaxTabs[currencyID]=true
        end

        print(
            '|cnGREEN_FONT_COLOR:'
            ..(WoWTools_DataMixin.onlyChinese and '已达到资源上限' or SPELL_FAILED_CUSTOM_ERROR_248)
            ..'|r'
            ..(num>1 and num or '')
            ..WoWTools_DataMixin.Icon.icon2
        )
    end
end












local OwerID


function WoWTools_CurrencyMixin:Init_MaxTooltip()
    if Save().hideCurrencyMax then
        if OwerID then
            EventRegistry:UnregisterCallback('CURRENCY_DISPLAY_UPDATE', OwerID)
        end

    elseif not OwerID then
        OwerID= EventRegistry:RegisterFrameEventAndCallback("CURRENCY_DISPLAY_UPDATE", function(_, currencyID)
            Currency_Max(currencyID)
        end)

        C_Timer.After(2, function() Currency_Max() end)
    end
end