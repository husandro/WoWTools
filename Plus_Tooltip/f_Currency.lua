


function WoWTools_TooltipMixin:Set_Currency(tooltip, currencyID)--货币
    if self:IsInCombatDisabled(tooltip)
        or not canaccessvalue(currencyID)
        or not currencyID
    then
        return
    end

    local info2= C_CurrencyInfo.GetCurrencyInfo(currencyID)
    if not info2 then
        return
    end

    local icon, isWide, isTrans, col= WoWTools_CurrencyMixin:GetAccountIcon(currencyID)

    col= col or '|cffffffff'
    icon= icon or ''

    tooltip:AddDoubleLine(
       '|T'..(info2.iconFileID or 0)..':'..self.iconSize..'|t'..col..(info2.iconFileID or ''),

        'currencyID'..WoWTools_DataMixin.Icon.icon2..'|cffffffff'..currencyID..icon
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

    local numPlayer= #data
    if isTrans and numPlayer>0 and data then
        tooltip:AddLine(' ')
        for index, info in pairs(data) do
            tooltip:AddDoubleLine(
                index
                ..')'
                ..WoWTools_UnitMixin:GetPlayerInfo(nil, info.characterGUID, nil, {reName=true, reRealm=true, faction=info.faction}),
                WoWTools_DataMixin:MK(info.quantity, 3)
            )
            if index>2 and not IsShiftKeyDown() then
                if index<numPlayer then
                    tooltip:AddLine('|cnGREEN_FONT_COLOR:<|A:NPE_Icon:0:0|aShift+ '..(WoWTools_DataMixin.onlyChinese and '角色' or CHARACTER)..' '..numPlayer..'>')
                end
                break
            end
        end
    end

    local textLeft=  (col or '|cnGREEN_FONT_COLOR:')..numPlayer..(WoWTools_DataMixin.onlyChinese and '角色' or CHARACTER)
    local text2Left= (col or '|cnGREEN_FONT_COLOR:')..(icon~='' and icon or WoWTools_DataMixin.Icon.wow2)..WoWTools_DataMixin:MK(num, 3)
    local textRight= col..WoWTools_DataMixin:MK(info2.quantity or 0, 3)

    if tooltip.IsEmbedded then--嵌入式
        tooltip:AddLine(textLeft)
        tooltip:AddLine(text2Left)
        tooltip:AddLine(textRight)
    else
        tooltip.textLeft:SetText(textLeft or '')
        tooltip.text2Left:SetText(text2Left or '')
        tooltip.textRight:SetText(textRight or '')
    end

    tooltip.Portrait:settings(info2.iconFileID )

    WoWTools_TooltipMixin:Set_Web_Link(tooltip, {type='currency', id=currencyID, name=info2.name, col=nil, isPetUI=false})--取得网页，数据链接 npc item spell currency

    --tooltip:Show()
    WoWTools_TooltipMixin:CalculatePadding(tooltip)
end
