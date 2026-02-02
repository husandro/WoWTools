--拍卖行, 受限模式
--if GameLimitedMode_IsActive() or PlayerIsTimerunning() then
--    WoWTools_AuctionHouseMixin.disabled=true



local function Save()
    return WoWToolsSave['Plus_AuctionHouse'] or {}
end








local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub
    root:CreateTitle('Plus')

    sub= root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '购买' or AUCTION_HOUSE_BUY_TAB,
    function()
        return not Save().disabledBuyPlus
    end, function()
        Save().disabledBuyPlus= not Save().disabledBuyPlus and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

    sub= root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB,
    function()
        return not Save().disabledSellPlus
    end, function()
        Save().disabledSellPlus= not Save().disabledSellPlus and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

    sub= root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '拍卖' or AUCTION_HOUSE_AUCTIONS_SUB_TAB,
    function()
        return not Save().disabledAuctionsPlus
    end, function()
        Save().disabledAuctionsPlus= not Save().disabledAuctionsPlus and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

--打开，选项
    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_AuctionHouseMixin.addName})

--重新加载UI
    WoWTools_MenuMixin:Reload(sub)
end










local function Init()
    WoWTools_AuctionHouseMixin:Init_BrowseResultsFrame()
    WoWTools_AuctionHouseMixin:Init_AllAuctions()
    WoWTools_AuctionHouseMixin:Init_Sell()
    WoWTools_AuctionHouseMixin:Sell_Other()

    local btn= CreateFrame('DropdownButton', 'WoWToolsAuctionHouseMenuButton', AuctionHouseFrameCloseButton, 'WoWToolsMenuTemplate') --WoWTools_ButtonMixin:Menu(AuctionHouseFrameCloseButton, {name='WoWToolsAuctionHouseMenuButton'})
    btn:SetPoint('RIGHT', AuctionHouseFrameCloseButton, 'LEFT')
    btn.tootip= WoWTools_AuctionHouseMixin.addName
    btn:SetupMenu(Init_Menu)

    Init=function()end
end






local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGIN")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_AuctionHouse']= WoWToolsSave['Plus_AuctionHouse'] or {
                numButton=14,--行数
                scaleSellButton=0.95,--综合
                intShowSellItem= WoWTools_DataMixin.Player.husandro,--显示，转到出售物品
                isMaxSellItem= true,--出售物品时，使用，最大数量
                hideSellItem={--跳过，拍卖行物品
                    [201469]=true,--翡翠青苹果
                    [202071]=true,--元素微粒
                    [192658]=true,--高纤维树叶
                    [192615]=true,--幽光液体
                },
                hideSellPet={
                    --[speciaID]=true, --speciaID 为字符
                },
                sellItemQualiy=1,--物品列表，检测有效物品
                SellItemDefaultPrice={},--默认价格
            }
--宠物笼
            Save().hideSellPet= Save().hideSellPet or {}
            Save().sellItemQualiy= Save().sellItemQualiy or 1--物品列表，检测有效物品

            WoWTools_AuctionHouseMixin.addName= '|A:Auctioneer:0:0|a'..(WoWTools_DataMixin.onlyChinese and '拍卖行' or BUTTON_LAG_AUCTIONHOUSE)

--添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_AuctionHouseMixin.addName,
                Value= not Save().disabled,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    Init()
                    WoWTools_AuctionHouseMixin:Init_AccountStore()
                end,
                tooltip=WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI,
            })

            if Save().disabled then
                self:SetScript('OnEvent', nil)
                self:UnregisterAllEvents()

            elseif C_AddOns.IsAddOnLoaded('Blizzard_AuctionHouseUI') then
                Init()
                self:UnregisterEvent(event)
            end

        elseif arg1=='Blizzard_AuctionHouseUI' and WoWToolsSave then
            Init()
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_LOGIN' then
        WoWTools_AuctionHouseMixin:Init_AccountStore()
        self:UnregisterEvent(event)
    end
end)