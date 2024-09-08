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
    --sellJunkMago=true,--出售，可幻化，垃圾物品
    --notPlus=true,--商人 Plus,加宽

    --notSellBoss=true,--出售，BOSS，掉落
    --bossSave={},
    saveBossLootList= e.Player.husandro,--保存，BOSS，列表

    --notAutoRepairAll=true,--自动修理

    MERCHANT_ITEMS_PER_PAGE= 24,--页，物品数量
    numLine=6,--行数
},

addName=nil,
buySave={},
Repair={},
}


local id, e = ...

local function Save()
    return WoWTools_SellBuyMixin.Save
end



local function Init()
    WoWTools_SellBuyMixin:Init_LootPlus()--自动拾取 Plus

end


local panel=CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event)
    if event == "ADDON_LOADED" then
        if WoWToolsSave[MERCHANT] then
            Save= WoWToolsSave[MERCHANT]
            WoWToolsSave[MERCHANT]=nil
        else
            Save= WoWToolsSave['Plus_SellBuy'] or Save
        end
        WoWTools_SellBuyMixin.addName= '|A:SpellIcon-256x256-SellJunk:0:0|a'..(e.onlyChinese and '商人' or MERCHANT)

        e.AddPanel_Check({
            name= WoWTools_SellBuyMixin.addName,
            GetValue= function() return not Save().disabled end,
            SetValue= function()
                Save().disabled= not Save().disabled and true or nil
                print(e.addName, WoWTools_SellBuyMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
            end
        })

        if Save.disabled then
            e.CheckItemSell=nil
        else
            if WoWToolsSave then
                WoWTools_SellBuyMixin.buySave= WoWToolsSave.BuyItems and WoWToolsSave.BuyItems[e.Player.name_realm] or WoWTools_SellBuyMixin.buySave--购买物品
                WoWTools_SellBuyMixin.RepairSave= WoWToolsSave.Repair and WoWToolsSave.Repair[e.Player.name_realm] or WoWTools_SellBuyMixin.RepairSave--修理
            end

            Init()

            C_Timer.After(2.2, function()
                if not e.Is_Timerunning then
                    self:RegisterEvent('ENCOUNTER_LOOT_RECEIVED')
                end
            end)
        end
        self:UnregisterEvent('ADDON_LOADED')
    end
end)