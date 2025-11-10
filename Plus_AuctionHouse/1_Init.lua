--拍卖行, 受限模式
if GameLimitedMode_IsActive() or PlayerIsTimerunning() then
    WoWTools_AuctionHouseMixin.disabled=true
    return
end

local P_Save={
    --出售
    --hideSellItemList=true,--隐藏，物品列表
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








local function Save()
    return WoWToolsSave['Plus_AuctionHouse'] or {}
end


local function Init()
    WoWTools_AuctionHouseMixin:Init_BrowseResultsFrame()
    WoWTools_AuctionHouseMixin:Init_AllAuctions()
    WoWTools_AuctionHouseMixin:Init_Sell()
    WoWTools_AuctionHouseMixin:Sell_Other()
    WoWTools_AuctionHouseMixin:Init_MenuButton()
end






local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGIN")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_AuctionHouse']= WoWToolsSave['Plus_AuctionHouse'] or P_Save
            P_Save=nil
--宠物笼
            Save().hideSellItem[82800]= nil
            Save().hideSellPet= Save().hideSellPet or {}
            Save().sellItemQualiy= Save().sellItemQualiy or 1--物品列表，检测有效物品

            if PlayerIsTimerunning() then
                WoWTools_AuctionHouseMixin.disabled= true
                self:UnregisterAllEvents()
                return
            end

            WoWTools_AuctionHouseMixin.addName= '|A:Auctioneer:0:0|a'..(WoWTools_DataMixin.onlyChinese and '拍卖行' or BUTTON_LAG_AUCTIONHOUSE)

--添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_AuctionHouseMixin.addName,
                Value= not Save().disabled,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(
                        WoWTools_AuctionHouseMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                        WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI
                    )
                end
            })

            if Save().disabled then
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