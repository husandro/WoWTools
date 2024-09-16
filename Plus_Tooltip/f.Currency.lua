local e= select(2, ...)


function WoWTools_TooltipMixin:Set_Currency(tooltip, currencyID)--货币
    local info2 = currencyID and C_CurrencyInfo.GetCurrencyInfo(currencyID)
    if not info2 then
        return
    end
    tooltip:AddDoubleLine((e.onlyChinese and '货币' or TOKENS)..' '..currencyID, info2.iconFileID and '|T'..info2.iconFileID..':0|t'..info2.iconFileID)
    local factionID = C_CurrencyInfo.GetFactionGrantedByCurrency(currencyID)--派系声望
    if factionID and factionID>0 then
        local name= (C_Reputation.GetFactionDataByID(factionID) or {}).name
        if name then
            tooltip:AddDoubleLine(e.onlyChinese and '声望' or REPUTATION, e.cn(name)..' '..factionID)
        end
    end

    local all,numPlayer=0,0
    for guid, info in pairs(e.WoWDate or {}) do--帐号数据
        if guid~=e.Player.guid then
            local quantity=info.Currency[currencyID]
            if quantity and quantity>0 then
                tooltip:AddDoubleLine(WoWTools_UnitMixin:GetPlayerInfo({guid=guid, faction=info.faction, reName=true, reRealm=true}), WoWTools_Mixin:MK(quantity, 3))
                all=all+quantity
                numPlayer=numPlayer+1
            end
        end
    end
    if numPlayer>1 then
        tooltip:AddDoubleLine(e.Icon.wow2..numPlayer..(e.onlyChinese and '角色' or CHARACTER), WoWTools_Mixin:MK(all,3))
    end

    WoWTools_TooltipMixin:Set_Web_Link(tooltip, {type='currency', id=currencyID, name=info2.name, col=nil, isPetUI=false})--取得网页，数据链接 npc item spell currency

    tooltip:Show()
end
