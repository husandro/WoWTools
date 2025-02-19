local id, e = ...





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

WoWTools_UseItemsMixin={
    Save= P_Tabs,
    P_Tabs=P_Tabs,
    addName=nil
}




function WoWTools_UseItemsMixin:Find_Type(type, ID)
    for index, ID2 in pairs(self.Save[type]) do
        if ID2==ID then
            return index
        end
    end
end







local function Init()
    WoWTools_UseItemsMixin:Init_All_Buttons()
    WoWTools_UseItemsMixin:Init_Button()
    WoWTools_UseItemsMixin:Init_SpellFlyoutButton()--法术书，界面, Flyout, 菜单
end





--加载保存数据
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then

            if WoWToolsSave[USE_ITEM..'Tools'] then
                WoWTools_UseItemsMixin.Save= WoWToolsSave[USE_ITEM..'Tools']
                WoWTools_UseItemsMixin.Save.flyout= WoWTools_UseItemsMixin.Save.flyout or {}
                WoWToolsSave[USE_ITEM..'Tools']=nil
            else
                WoWTools_UseItemsMixin.Save = WoWToolsSave['Tools_UseItems'] or WoWTools_UseItemsMixin.Save
            end

--禁用，Tools模块，退出
            if not WoWTools_ToolsButtonMixin:GetButton() then
                self:UnregisterEvent('ADDON_LOADED')
                return
            end

            --if (not WoWToolsSave or not WoWToolsSave[addName..'Tools']) and PlayerHasToy(156833) and WoWTools_UseItemsMixin.Save.item[1]==194885 then
            --Save.item[1] = 156833
            --end

            WoWTools_UseItemsMixin.addName= '|A:soulbinds_tree_conduit_icon_utility:0:0|a'..(e.onlyChinese and '使用物品' or USE_ITEM)

            for _, ID in pairs(WoWTools_UseItemsMixin.Save.item) do
                e.LoadData({id=ID, type='item'})
            end
            for _, ID in pairs(WoWTools_UseItemsMixin.Save.spell) do
                e.LoadData({id=ID, type='spell'})
            end
            for _, ID in pairs(WoWTools_UseItemsMixin.Save.equip) do
                e.LoadData({id=ID, type='item'})
            end

            C_Timer.After(2.3, function()
                if UnitAffectingCombat('player') then
                    self:RegisterEvent("PLAYER_REGEN_ENABLED")
                else
                    Init()--初始
                end
            end)

            if C_AddOns.IsAddOnLoaded('Blizzard_Collections') then
                WoWTools_UseItemsMixin:Init_UI_Toy()
            end

        elseif arg1=='Blizzard_Collections' then
            WoWTools_UseItemsMixin:Init_UI_Toy()

        elseif arg1=='Blizzard_PlayerSpells' then--法术书
            WoWTools_UseItemsMixin:Init_PlayerSpells()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Tools_UseItems']=WoWTools_UseItemsMixin.Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        Init()--初始
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
end)