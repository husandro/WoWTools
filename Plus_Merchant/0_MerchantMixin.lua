WoWTools_MerchantMixin={}

local function Save()
    return WoWToolsSave['Plus_SellBuy']
end

function WoWTools_MerchantMixin:Update_MerchantFrame()
    if MerchantFrame.selectedTab == 2 then
        WoWTools_Mixin:Call(MerchantFrame_UpdateBuybackInfo)
    else
        WoWTools_Mixin:Call(MerchantFrame_UpdateMerchantInfo)
    end
end

function WoWTools_MerchantMixin:CheckSellItem(itemID, itemLink, quality, isBound)
    if not itemID or Save().disabled or Save().noSell[itemID] then
        return
    end

    if Save().Sell[itemID] and not Save().notSellCustom then
        return WoWTools_DataMixin.onlyChinese and '自定义' or CUSTOM
    end

    if not WoWTools_DataMixin.Is_Timerunning and not Save().notSellBoss and itemLink then
        local level= Save().bossItems[itemID]
        if level then
            local itemLevel= C_Item.GetDetailedItemLevelInfo(itemLink) or select(4, C_Item.GetItemInfo(itemLink))
            if level== itemLevel  then
                return WoWTools_DataMixin.onlyChinese and '首领' or BOSS
            end
        end
    end

    if quality==0 then
        if WoWTools_CollectedMixin:GetPet9Item(itemID, true) then--宠物兑换, wow9.0
            return WoWTools_DataMixin.onlyChinese and '宠物' or PET

        elseif not Save().notSellJunk then--垃圾
            if isBound==true then
                return WoWTools_DataMixin.onlyChinese and '垃圾' or BAG_FILTER_JUNK
            else
                local classID, subclassID = select(6, C_Item.GetItemInfoInstant(itemID))
                if (classID==2 or classID==4) and subclassID~=0 then
                    local isCollected = select(2, WoWTools_CollectedMixin:Item(itemID, nil, nil))--物品是否收集
                    if isCollected==false then
                        return
                    end
                end
                return WoWTools_DataMixin.onlyChinese and '垃圾' or BAG_FILTER_JUNK
            end
        end
    end
end
