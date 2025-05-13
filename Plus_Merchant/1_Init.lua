local P_Save={
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
    --notAutoLootPlus= WoWTools_DataMixin.Player.husandro,--打开拾取窗口时，下次禁用，自动拾取
    --notPlus=true,--商人 Plus,加宽

    --notSellBoss=true,--出售，BOSS，掉落
    bossItems={},
    saveBossLootList= WoWTools_DataMixin.Player.husandro,--保存，BOSS，列表

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
    --ShowBackground=false,--显示背景
}

local function Save()
    return WoWToolsSave['Plus_SellBuy']
end







local function Init()
    WoWTools_MerchantMixin:Init_AutoLoot()
    WoWTools_MerchantMixin:Init_Delete()
    WoWTools_MerchantMixin:Init_Auto_Repair()--自动修理


    WoWTools_MerchantMixin:Init_Auto_Sell_Junk()--自动出售

    WoWTools_MerchantMixin:Init_Buy_Items_Button()--购买物品
    WoWTools_MerchantMixin:Init_Buyback_Button()--回购物品
    WoWTools_MerchantMixin:Init_Menu()

--商人 Plus
    WoWTools_MerchantMixin:Init_WidthX2()
    WoWTools_MerchantMixin:Init_Plus_Other()

    Init=function()end
end







local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('LOADING_SCREEN_DISABLED')
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWToolsSave['Plus_SellBuy']= WoWToolsSave['Plus_SellBuy'] or P_Save

            WoWToolsSave['Plus_SellBuy'].buyItems[WoWTools_DataMixin.Player.GUID]= WoWToolsSave['Plus_SellBuy'].buyItems[WoWTools_DataMixin.Player.GUID] or {}
            WoWToolsSave['Plus_SellBuy'].WoWBuyItems= WoWToolsSave['Plus_SellBuy'].WoWBuyItems or {}

            WoWTools_MerchantMixin.addName= '|A:SpellIcon-256x256-SellJunk:0:0|a'..(WoWTools_DataMixin.onlyChinese and '商人' or MERCHANT)

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_MerchantMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    if Save().disabled then
                        print(
                            WoWTools_DataMixin.Icon.icon2..WoWTools_MerchantMixin.addName,
                            WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                            WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI
                        )
                        self:UnregisterEvent('PLAYER_LOGOUT')
                    else
                        self:RegisterEvent("PLAYER_LOGOUT")
                    end
                    Inti()
                end
            })

            if Save().disabled then
                self:UnregisterAllEvents()
            else
                Init()
                self:UnregisterEvent(event)
            end
        end

    elseif event=='LOADING_SCREEN_DISABLED' then
        Init()
        self:UnregisterEvent(event)

    elseif event == "PLAYER_LOGOUT" then
        if not WoWTools_DataMixin.ClearAllSave then
            if not Save().saveBossLootList then
                Save().bossItems={}
            end
        end
    end
end)