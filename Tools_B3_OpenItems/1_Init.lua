local id, e = ...

WoWTools_OpenItemMixin={}

local Save={
    use={--定义,使用物品, [ID]=数量(或组合数量)
        [190198]=5,
        [201791]=1,--龙类驯服手册》
        [198969]=1,--守护者的印记,  研究以使你的巨龙群岛工程学知识提高1点。

        [198790]=1,--10.0 加，声望物品
        [201781]=1,
        [201783]=1,
        [201779]=1,

        [201922]=1,--伊斯卡拉海象人徽章
        [200287]=1,
        [202092]=1,
        [200453]=1,

        [201924]=1,--瓦德拉肯联军徽章
        [202093]=1,
        [200455]=1,
        [200289]=1,

        [201923]=1,--马鲁克半人马徽章
        [200288]=1,
        [202094]=1,
        [200454]=1,


        [200285]=1,--龙鳞探险队徽章
        [201921]=1,
        [200452]=1,
        [202091]=1,
        [201782]=1,--提尔的祝福


        [204573]=1,--10.07 源石宝石
        [204574]=1,
        [204575]=1,
        [204576]=1,
        [204577]=1,
        [204578]=1,
        [204579]=1,

        [204075]=15,--雏龙的暗影烈焰纹章碎片 10.1
        [204076]=15,
        [204077]=15,
        [204717]=2,
        [190328]=10,--活力之霜
        [190322]=10,--活力秩序

        --10.2
        [208396]=2,--分裂的梦境火花
        --10.2.7
        --[219273]=1,--历久经验帛线 从 219256 到 219282
        [87779]=1,--远古郭莱储物箱钥匙

        --11
        [229899]=100,--宝匣钥匙碎片
        [224025]=10,--爆裂碎片
        [219191]=15,--草草写下的纸条


    },
    no={--禁用使用
        [64402]=true,--协同战旗
        [6948]=true,--炉石
        --[140192]=true,--达拉然炉石
        --[110560]=true,--要塞炉石
        [23247]=true,--燃烧之花
        [168416]=true,
        [109076]=true,
        [132119]=true,
        [193902]=true,
        [37863]=true,

        [139590]=true,--[传送卷轴：拉文霍德]
        [141605]=true,--[飞行管理员的哨子]
        [163604]=true,--[撒网器5000型]
        [199900]=true,--[二手勘测工具]
        [198083]=true,--探险队补给包
        [191294]=true,--小型探险锹
        [202087]=true,--匠械移除设备
        [128353]=true,--海军上将的罗盘
        [86143]=true,--pet
        [5512]=true,--SS糖
        [92675]=true,--无瑕野兽战斗石
        [92741]=true,--无瑕战斗石

        --熊猫人之谜
        [102464]=true,--黑色灰烬
        [94233]=true,--镫恒的咒语

        --10.0
        [194510]=true,--伊斯卡拉鱼叉
        [199197]=true,--瓶装精
        [200613]=true,--艾拉格风石碎片
        [18149]=true,--召回符文
        [194701]=true,--不祥海螺
        [192749]=true,--时空水晶

        [204439]=true,--研究宝箱钥匙
        [194743]=true,--古尔查克的指示器
        [194730]=true,--鳞腹鲭鱼
        [194519]=true,--欧索利亚的协助
        [202620]=true,--毒素解药
        [191529]=true,--卓然洞悉
        [191526]=true,--次级卓然洞悉
        [193915]=true,
        [190320]=true,

        --10.1
        [203708]=true,--蜗壳哨
        [205982]=true,--失落的挖掘地图
        [207057]=true,--雪白战狼的赐福
        --10.2
        [208066]=true,--小小的梦境之种
        [208067]=true,--饱满的梦境之种
        [208047]=true,--硕大的梦境之种
        [210014]=true,--神秘的恒久之种
        [190324]=true,--觉醒秩序

        --10.2.7
        [217956]=true,
        [217608]=true,
        [217607]=true,
        [217606]=true,
        [217605]=true,
        [217930]=true,
        [217929]=true,
        [217928]=true,

        [217731]=true,
        [217730]=true,
        [217901]=true,

        [89770]=true,--一簇牦牛毛
        [219940]=true,--流星残片
        [95350]=true,---乌古的咒语
        
        --11
        [224185]=true--导蟹树枝

    },
    pet=true,
    open=true,
    toy=true,
    mount=true,
    mago=true,
    ski=true,
    alt=true,
    --noItemHide= true,--not e.Player.husandro,
    KEY=e.Player.husandro and 'F',
    --reagent= true,--禁用，检查，材料包
}




local addName
local OpenButton
--local useText, noText




if e.Player.class=='ROGUE' then
    WoWTools_Mixin:Load({id=1804, type='spell'})--开锁 Pick Lock
end
















local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_LOGIN')
--panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            WoWToolsSave['Tools_OpenItems']= WoWToolsSave['Tools_OpenItems'] or Save

            addName= '|A:BonusLoot-Chest:0:0|a'..(e.onlyChinese and '打开物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, ITEMS))
            
            OpenButton= WoWTools_ToolsMixin:CreateButton({
                name='OpenItems',
                tooltip=addName,
            })

            if OpenButton then
                WoWTools_OpenItemMixin.OpenButton= OpenButton
                WoWTools_OpenItemMixin.addName= addName
            else
                self:UnregisterEvent('PLAYER_LOGIN')
            end
            self:UnregisterEvent("ADDON_LOADED")
        end

    elseif event=='PLAYER_LOGIN' then
          WoWTools_OpenItemMixin:Init_Button()

    --[[elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            --WoWToolsSave['Tools_OpenItems'] = WoWTools_OpenItemMixin.Save
        end]]
    end
end)