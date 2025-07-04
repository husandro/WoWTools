--出售，菜单，按钮
local function Save()
    return WoWToolsSave['Plus_SellBuy']
end


local function Check_All()
     return WoWTools_BagMixin:GetItems(true, nil, nil, function(_, _, info)
        return not info.isLocked and not Save().noSell[info.itemID]
    end)
end

local function Sell_Items(tab)
    local num, gruop, preceTotale= 0, 0, 0
    local data
    for _, info in pairs(tab) do
        if IsModifierKeyDown() or not MerchantFrame:IsVisible() or InCombatLockdown() then
            break
        end

        data= info.info
        do
            C_Container.UseContainerItem(info.bag, info.slot)--买出
        end

        local prece =0
        if not info.hasNoValue then--卖出钱
            prece = (select(11, C_Item.GetItemInfo(data.hyperlink)) or 0) * (data.stackCount or 1)--价格
            preceTotale = preceTotale + prece
        end
        gruop= gruop+ 1
        num= num+ (data.stackCount or 1)--数量
        print('|cnRED_FONT_COLOR:'..gruop..')|r',  data.hyperlink, C_CurrencyInfo.GetCoinTextureString(prece))
    end

    if num > 0 then
        print(
            WoWTools_DataMixin.Icon.icon2..WoWTools_MerchantMixin.addName,
            (WoWTools_DataMixin.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB)..' |cnGREEN_FONT_COLOR:'..gruop..'|r'..(WoWTools_DataMixin.onlyChinese and '组' or AUCTION_PRICE_PER_STACK),
            '|cnGREEN_FONT_COLOR:'..num..'|r'..(WoWTools_DataMixin.onlyChinese and '件' or AUCTION_HOUSE_QUANTITY_LABEL),
            C_CurrencyInfo.GetCoinTextureString(preceTotale)
        )
    end
end

local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    elseif WoWTools_MenuMixin:CheckInCombat(root) then
        return
    elseif not C_MerchantFrame.IsSellAllJunkEnabled() then
        root:CreateTitle(WoWTools_DataMixin.onlyChinese and '商人不收' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, AUCTION_HOUSE_SELL_TAB, DISABLE))
        return
    end

    local att= '|n|n|cnYELLOW_FONT_COLOR:'
            ..(WoWTools_DataMixin.onlyChinese and '危险！' or VOICEMACRO_1_Sc_0)
            ..(WoWTools_DataMixin.onlyChinese and '危险！' or VOICEMACRO_1_Sc_0)
            ..(WoWTools_DataMixin.onlyChinese and '危险！' or VOICEMACRO_1_Sc_0)
            ..'|n'
    local sub, sub2, name


    name= (WoWTools_DataMixin.onlyChinese and '出售全部' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, AUCTION_HOUSE_SELL_TAB, ALL))
        ..' #|cnGREEN_FONT_COLOR:'..#Check_All()

    sub= root:CreateButton(
        name,
    function(data)
        StaticPopup_Show('WoWTools_OK',
            'Perks-ShoppingCart'..data.name..att,
            nil,
            {SetValue=function()
                Sell_Items(Check_All())
            end})
        return MenuResponse.Open
    end, {name=name})

    sub:SetTooltip(function(tooltip)
        for index, info in pairs(Check_All()) do
            tooltip:AddDoubleLine(WoWTools_ItemMixin:GetName(info.info.itemID, info.info.hyperlink), index)
        end
    end)


end









local function Init()
    local btn= WoWTools_ButtonMixin:Menu(MerchantFrameCloseButton, {
        atlas='Perks-ShoppingCart',
        name= 'WoWToolsMerchantSellButtonMenu',
    })
    btn:SetPoint('RIGHT', _G['WoWTools_SellBuyMenuButton'], 'LEFT')
    btn:SetupMenu(function(...)
        Init_Menu(...)
    end)

    Init=function()end
end

function WoWTools_MerchantMixin:Init_SellButtonMenu()
    Init()
end