
WoWTools_AuctionHouseMixin= {}

function WoWTools_AuctionHouseMixin:GetItemLink(rowData)
    if not rowData then
        return
    end
    local itemLink= rowData.itemLink
    local itemID, isPet
    itemID= rowData.itemID or (rowData and rowData.itemKey and rowData.itemKey.itemID)
    if not itemLink and rowData.auctionID then
        local priceInfo = C_AuctionHouse.GetAuctionInfoByID(rowData.auctionID) or {}
        itemLink= priceInfo.itemLink or priceInfo.battlePetLink
    end
    if not itemLink and itemID then
        itemLink= WoWTools_ItemMixin:GetLink(itemID)
    end
    isPet= rowData and rowData.itemKey and rowData.itemKey.battlePetSpeciesID and rowData.itemKey.battlePetSpeciesID>0
    return itemLink, itemID, isPet
end


--拍卖行, 受限模式
if GameLimitedMode_IsActive() or PlayerGetTimerunningSeasonID() then
    WoWTools_AuctionHouseMixin.Save={disabled=true}
    return
end
local id, e = ...

WoWTools_AuctionHouseMixin.Save={
    --出售
    --hideSellItemList=true,--隐藏，物品列表
    numButton=15,--行数
    scaleSellButton=0.95,--综合

    intShowSellItem= e.Player.husandro,--显示，转到出售物品
    isMaxSellItem= true,--出售物品时，使用，最大数量
    hideSellItem={
        [201469]=true,--翡翠青苹果
        [202071]=true,--元素微粒
        [192658]=true,--高纤维树叶
        [192615]=true,--幽光液体
    },--跳过，拍卖行物品
    SellItemDefaultPrice={},--默认价格
}

local function Save()
    return WoWTools_AuctionHouseMixin.Save
end

local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if WoWToolsSave[BUTTON_LAG_AUCTIONHOUSE] then
                WoWTools_AuctionHouseMixin.Save= WoWToolsSave[BUTTON_LAG_AUCTIONHOUSE]
                WoWToolsSave[BUTTON_LAG_AUCTIONHOUSE]= nil
            else
                WoWTools_AuctionHouseMixin.Save= WoWToolsSave['Plus_AuctionHouse'] or Save()
            end

            if PlayerGetTimerunningSeasonID() then
                self:UnregisterEvent(event)
                return
            end

            local addName= '|A:Auctioneer:0:0|a'..(e.onlyChinese and '拍卖行' or BUTTON_LAG_AUCTIONHOUSE)
            WoWTools_AuctionHouseMixin.addName= addName

            --添加控制面板
            e.AddPanel_Check({
                name= addName,
                Value= not Save().disabled,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(WoWTools_Mixin.addName, addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                end
            })

            if Save().disabled then
                self:UnregisterEvent(event)
            else

                WoWTools_AuctionHouseMixin:Init_AccountStore()
            end

        elseif arg1=='Blizzard_AuctionHouseUI' then
            WoWTools_AuctionHouseMixin:Init_BrowseResultsFrame()
            WoWTools_AuctionHouseMixin:Init_AllAuctions()
            WoWTools_AuctionHouseMixin:Init_Sell()
            self:UnregisterEvent(event)
        end
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_AuctionHouse']=Save()
        end
    end
end)