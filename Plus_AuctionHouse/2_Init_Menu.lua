--拍卖行, 受限模式
if WoWTools_AuctionHouseMixin.disabled then
    return
end






local function Save()
    return WoWToolsSave['Plus_AuctionHouse'] or {}
end











local function Set_Tooltip(root)
    root:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)
end









local function Init_Menu(_, root)
    local sub
    root:CreateTitle('Plus')
    sub= root:CreateCheckbox(
        WoWTools_Mixin.onlyChinese and '购买' or AUCTION_HOUSE_BUY_TAB,
    function()
        return not Save().disabledBuyPlus
    end, function()
        Save().disabledBuyPlus= not Save().disabledBuyPlus and true or nil
    end)
    Set_Tooltip(sub)

    sub= root:CreateCheckbox(
        WoWTools_Mixin.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB,
    function()
        return not Save().disabledSellPlus
    end, function()
        Save().disabledSellPlus= not Save().disabledSellPlus and true or nil
    end)
    Set_Tooltip(sub)


    sub= root:CreateCheckbox(
        WoWTools_Mixin.onlyChinese and '拍卖' or AUCTION_HOUSE_AUCTIONS_SUB_TAB,
    function()
        return not Save().disabledAuctionsPlus
    end, function()
        Save().disabledAuctionsPlus= not Save().disabledAuctionsPlus and true or nil
    end)
    Set_Tooltip(sub)

--打开，选项
    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_AuctionHouseMixin.addName})

--重新加载UI
    WoWTools_MenuMixin:Reload(sub)
end









function WoWTools_AuctionHouseMixin:Init_MenuButton()
    local btn=WoWTools_ButtonMixin:Menu(AuctionHouseFrameCloseButton, {name='WoWToolsAuctionHouseMenuButton'})
    btn:SetPoint('RIGHT', AuctionHouseFrameCloseButton, 'LEFT')
    btn:SetupMenu(Init_Menu)
end