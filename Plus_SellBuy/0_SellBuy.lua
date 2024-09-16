local id, e = ...

WoWTools_SellBuyMixin={
Save={
    noSell={
        [144341]=true,--[可充电的里弗斯电池]
        [49040]=true,--[基维斯]
        [114943]=true,--[终极版侏儒军刀]
        [103678]=true,--迷时神器
        [142469]=true,--魔导大师的紫罗兰印戒
        [139590]=true,--[传送卷轴：拉文霍德]
        [144391]=true,--拳手的重击指环
        [144392]=true,--拳手的重击指环
        [37863]=true,--[烈酒的遥控器]
        
    },
    Sell={
        [34498]=true,--[纸飞艇工具包]
    },
    --notAutoLootPlus= e.Player.husandro,--打开拾取窗口时，下次禁用，自动拾取
    --notPlus=true,--商人 Plus,加宽

    --notSellBoss=true,--出售，BOSS，掉落
    bossItems={},
    saveBossLootList= e.Player.husandro,--保存，BOSS，列表

    --notAutoRepairAll=true,--自动修理

    MERCHANT_ITEMS_PER_PAGE= 24,--页，物品数量
    numLine=6,--行数
    buyItems={
        --[guid]={[itemID]=numbre,}
    },
    WoWBuyItems={
        [8529]=200,--诺格弗格药剂
    },
    repairItems={date=date('%x'), player=0, guild=0, num=0}
},


addName=nil,



Init_AutoLoot=function()end,
Init_Delete=function()end,

Init_Plus=function()end,
Set_Merchant_Info=function()end,
Init_WidthX2=function()end,
Init_StackSplitFrame=function()end,

Init_Auto_Sell_Junk=function()end,

Init_Buy_Items_Button=function()end,--购买物品
Init_Buyback_Button=function()end,--回购物品
Init_Menu=function()end,
}


local function Save()
    return WoWTools_SellBuyMixin.Save
end









--####################
--检测是否是出售物品
--为 ItemInfo.lua, 用
function WoWTools_SellBuyMixin:CheckSellItem(itemID, itemLink, quality, isBound)
    if not itemID or Save().noSell[itemID] then
        return
    end
    if Save().Sell[itemID] and not Save().notSellCustom then
        return e.onlyChinese and '自定义' or CUSTOM
    end
    if not e.Is_Timerunning and not Save().notSellBoss and itemLink then
        local level= Save().bossItems[itemID]
        if level then
            local itemLevel= C_Item.GetDetailedItemLevelInfo(itemLink) or select(4, C_Item.GetItemInfo(itemLink))
            if level== itemLevel  then
                return e.onlyChinese and '首领' or BOSS
            end
        end
    end
    if quality==0 then
        if WoWTools_CollectedMixin:GetPet9Item(itemID, true) then--宠物兑换, wow9.0
            return e.onlyChinese and '宠物' or PET

        elseif not Save().notSellJunk then--垃圾
            if isBound==true then
                return e.onlyChinese and '垃圾' or BAG_FILTER_JUNK
            else
                local classID, subclassID = select(6, C_Item.GetItemInfoInstant(itemID))
                if (classID==2 or classID==4) and subclassID~=0 then
                    local isCollected = select(2, WoWTools_CollectedMixin:Item(itemID, nil, nil))--物品是否收集
                    if isCollected==false then
                        return
                    end
                end
                return e.onlyChinese and '垃圾' or BAG_FILTER_JUNK
            end
        end
    end
end











--商人 Plus
function WoWTools_SellBuyMixin:Init_Plus()
    if self.Save.notPlus then
        return
    end

    self:Init_StackSplitFrame()-- 堆叠,数量,框架

    C_Timer.After(2, self.Init_WidthX2)--加宽，框架x2

    hooksecurefunc('MerchantFrame_UpdateCurrencies', function()
        MerchantExtraCurrencyInset:SetShown(false)
        MerchantExtraCurrencyBg:SetShown(false)
        MerchantMoneyInset:SetShown(false)
    end)
end


















--####
--初始
--####

local function Init()
    WoWTools_SellBuyMixin:Init_AutoLoot()
    WoWTools_SellBuyMixin:Init_Delete()
    WoWTools_SellBuyMixin:Init_Auto_Repair()--自动修理
    WoWTools_SellBuyMixin:Init_Plus()--商人 Plus

    WoWTools_SellBuyMixin:Init_Auto_Sell_Junk()--自动出售

    WoWTools_SellBuyMixin:Init_Buy_Items_Button()--购买物品
    WoWTools_SellBuyMixin:Init_Buyback_Button()--回购物品
    WoWTools_SellBuyMixin:Init_Menu()
end













--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if WoWToolsSave[MERCHANT] then
                --WoWTools_SellBuyMixin.Save= WoWToolsSave[MERCHANT]
                --Save().bossItems={}
                --Save().buyItems= WoWToolsSave.BuyItems and WoWToolsSave.BuyItems[e.Player.name_realm] or {}--购买物品
                --Save().repairItems=WoWToolsSave.Repair and WoWToolsSave.Repair[e.Player.name_realm] or {}--修理
                WoWToolsSave.BuyItems=nil
                WoWToolsSave.Repair=nil
                WoWToolsSave[MERCHANT]=nil
            end

            WoWTools_SellBuyMixin.Save= WoWToolsSave['Plus_SellBuy'] or WoWTools_SellBuyMixin.Save
            WoWTools_SellBuyMixin.Save.buyItems[e.Player.guid]= WoWTools_SellBuyMixin.Save.buyItems[e.Player.guid] or {}
            WoWTools_SellBuyMixin.Save.WoWBuyItems= WoWTools_SellBuyMixin.Save.WoWBuyItems or {}

            WoWTools_SellBuyMixin.addName= '|A:SpellIcon-256x256-SellJunk:0:0|a'..(e.onlyChinese and '商人' or MERCHANT)

            --添加控制面板
            e.AddPanel_Check({
                name= WoWTools_SellBuyMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(e.addName, WoWTools_SellBuyMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                end
            })

            if Save().disabled then
                WoWTools_SellBuyMixin.CheckSellItem=nil
            else

                Init()

            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not Save().saveBossLootList then
                Save().bossItems={}
            end
            WoWToolsSave['Plus_SellBuy']= WoWTools_SellBuyMixin.Save
        end
    end
end)
