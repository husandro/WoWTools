WoWTools_UseItemsMixin={}

local P_Tabs={
    item={
        --156833,--[凯蒂的印哨]
        194885,--[欧胡纳栖枝]收信
        40768,--[移动邮箱]
        114943,--[终极版侏儒军刀]
        168667,--[布林顿7000]

        49040,--[基维斯]
        144341,--[可充电的里弗斯电池]

        128353,--[海军上将的罗盘]
        167075,--[超级安全传送器：麦卡贡]
        168222,--[加密的黑市电台]
        184504, 184501, 184503, 184502, 184500, 64457,--[侍神者的袖珍传送门：奥利波斯]
        221966,--虫洞发生器：卡兹阿加
        198156,--龙洞发生器-巨龙群岛
        172924,--[虫洞发生器：暗影界]
        168807,--[虫洞发生器：库尔提拉斯]
        168808,--[虫洞发生器：赞达拉]
        151652,--[虫洞发生器：阿古斯]
        112059,--[虫洞离心机]
        87215,--[虫洞发生器：潘达利亚]
        48933,--[虫洞发生器：诺森德]
        30542,--[空间撕裂器 - 52区]
        151016,--[开裂的死亡之颅]
        136849, 52251,--[自然道标]
        139590,--[传送卷轴：拉文霍德]
        87216,--[热流铁砧]
        85500,--[垂钓翁钓鱼筏]
        37863,--[烈酒的遥控器]
        --141605,--[飞行管理员的哨子]
        200613,--艾拉格风石碎片
        --226373,--恒久诺格弗格药剂
    },
    spell={
        436854,--/切换飞行模式
        83958,--移动银行
        69046,--[呼叫大胖],种族特性
        50977,--[黑锋之门]
        193753,--[传送：月光林地]
        556,--[星界传送]
        18960,--[梦境行者]
        126892,--[禅宗朝圣]
    },
    equip={
        65274,65360, 63206, 63207, 63352, 63353,--协同披风
        103678,--迷时神器
        142469,--魔导大师的紫罗兰印戒
        144391, 144392,--拳手的重击指环
    },
    flyout={
    },
}




function WoWTools_UseItemsMixin:Get_P_Tabs()
    return P_Tabs
end

function WoWTools_UseItemsMixin:Find_Type(type, ID)
    for index, ID2 in pairs(WoWToolsSave['Tools_UseItems'][type]) do
        if ID2==ID then
            return index
        end
    end
end










--加载保存数据
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_ENTERING_WORLD')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

           WoWToolsSave['Tools_UseItems']= WoWToolsSave['Tools_UseItems'] or P_Tabs

--禁用，Tools模块，退出

            if not WoWTools_ToolsMixin.Button then
                self:UnregisterAllEvents()
                return
            end

            WoWTools_UseItemsMixin.addName= '|A:soulbinds_tree_conduit_icon_utility:0:0|a'..(WoWTools_DataMixin.onlyChinese and '使用物品' or USE_ITEM)

            for _, ID in pairs(WoWToolsSave['Tools_UseItems'].item) do
                WoWTools_Mixin:Load({id=ID, type='item'})
            end

            for _, ID in pairs(WoWToolsSave['Tools_UseItems'].spell) do
                WoWTools_Mixin:Load({id=ID, type='spell'})
            end

            for _, ID in pairs(WoWToolsSave['Tools_UseItems'].equip) do
                WoWTools_Mixin:Load({id=ID, type='item'})
            end

        elseif arg1=='Blizzard_Collections' and WoWToolsSave then
            WoWTools_UseItemsMixin:Init_UI_Toy()
            if C_AddOns.IsAddOnLoaded('Blizzard_PlayerSpells') then
                self:UnregisterEvent(event)
            end

        elseif arg1=='Blizzard_PlayerSpells' and WoWToolsSave then--法术书
            WoWTools_UseItemsMixin:Init_PlayerSpells()
            if C_AddOns.IsAddOnLoaded('Blizzard_Collections') then
                self:UnregisterEvent(event)
            end

        end

    elseif event=='PLAYER_ENTERING_WORLD' and WoWTools_ToolsMixin.Button then
        WoWTools_UseItemsMixin:Init_All_Buttons()
        WoWTools_UseItemsMixin:Init_Button()
        WoWTools_UseItemsMixin:Init_SpellFlyoutButton()--法术书，界面, Flyout, 菜单
        self:UnregisterEvent(event)
    end
end)