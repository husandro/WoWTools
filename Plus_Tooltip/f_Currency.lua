


function WoWTools_TooltipMixin:Set_Currency(tooltip, currencyID)--货币
    local info2 = (tooltip and currencyID) and C_CurrencyInfo.GetCurrencyInfo(currencyID)
    if not info2 or WoWTools_FrameMixin:IsLocked(tooltip) then
        return
    end

    local icon, isWide, isTrans, col= WoWTools_CurrencyMixin:GetAccountIcon(currencyID)

    col= col or '|cffffffff'
    icon= icon or ''

    tooltip:AddDoubleLine(
        info2.iconFileID and '|T'..(info2.iconFileID or 0)..':'..self.iconSize..'|t'..col..info2.iconFileID,

        icon..'currencyID'..WoWTools_DataMixin.Icon.icon2..'|r'..col..currencyID
    )

    local factionID = C_CurrencyInfo.GetFactionGrantedByCurrency(currencyID)--派系声望
    if factionID and factionID>0 then
        local name= (C_Reputation.GetFactionDataByID(factionID) or {}).name
        if name then
            tooltip:AddDoubleLine(
                WoWTools_DataMixin.onlyChinese and '声望' or REPUTATION,

                WoWTools_TextMixin:CN(name)..WoWTools_DataMixin.Icon.icon2..'|cffffffff'..factionID
            )
        end
    end


    local num, data= 0, {}
--战团可转移货币
    if isTrans then
        num, data= WoWTools_CurrencyMixin:GetAccountInfo(currencyID)
--[[
        tooltip:AddLine(col..(WoWTools_DataMixin.onlyChinese and '战团可转移货币' or ACCOUNT_TRANSFERRABLE_CURRENCY))
--战团通用
    elseif isWide then
        tooltip:AddLine(col..(WoWTools_DataMixin.onlyChinese and '战团货币' or ACCOUNT_LEVEL_CURRENCY))
]]

    elseif not isWide then
        for guid, info in pairs(WoWTools_WoWDate or {}) do--帐号数据
            if guid~=WoWTools_DataMixin.Player.GUID then
                local quantity=info.Currency[currencyID]
                if quantity and quantity>0 then
                    table.insert(data, {
                        characterGUID=guid,
                        faction= info.faction,
                        quantity= quantity,
                    })
                    num= num + quantity
                end
            end
        end
        if num>0 then
            table.sort(data, function(a, b) return a.quantity>b.quantity end)
        end
    end


    if isTrans then
        tooltip:AddLine(' ')
        for index, info in pairs(data) do
            tooltip:AddDoubleLine(
                WoWTools_UnitMixin:GetPlayerInfo(nil, info.characterGUID, nil, {reName=true, reRealm=true, faction=info.faction}),
                WoWTools_Mixin:MK(info.quantity, 3)
            )
            if index>4 then
                break
            end
        end

        local numPlayer= #data
        tooltip.textLeft:SetText(
            (col or '|cnGREEN_FONT_COLOR:')
            ..numPlayer
            ..(icon or WoWTools_DataMixin.Icon.wow2)
            ..(WoWTools_DataMixin.onlyChinese and '角色' or CHARACTER)
            ..('|T'..(info2.iconFileID or 0)..':0|t')..WoWTools_Mixin:MK(num, 3)
        )
    end

    WoWTools_TooltipMixin:Set_Web_Link(tooltip, {type='currency', id=currencyID, name=info2.name, col=nil, isPetUI=false})--取得网页，数据链接 npc item spell currency

    --tooltip:Show()
    WoWTools_Mixin:Call(GameTooltip_CalculatePadding, tooltip)
end
