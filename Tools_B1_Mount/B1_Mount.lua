local id, e = ...


local P_Mouts_Tab={
    [ITEMS]={
        [174464]=true,--幽魂缰绳
        [168035]=true,--噬渊鼠缰绳
        --[37011]=true,--/魔法扫帚
    },
    [SPELLS]={
        [2645]=true,--幽魂之狼
        [111400]=true,--爆燃冲刺
        [2983]=true,--疾跑
        [190784]=true,--神圣马驹
        [48265]=true,--死亡脚步
        [186257]=true,--猎豹守护
        [6544]=true,--英勇飞跃
        [358267]= true,--悬空
        [1953]=true,--闪现术
        [109132]=true,--滚地翻
        [121536]=true,--天堂之羽
        [189110]=true,--地狱火撞击
        [195072]=true,--邪能冲撞
    },
    [FLOOR]={},--{[spellID]=uiMapID}
    [MOUNT_JOURNAL_FILTER_GROUND]={
        --[339588]=true,--[罪奔者布兰契]
        --[163024]=true,--战火梦魇兽
        --[366962]=true,--[艾什阿达，晨曦使者]
        [256123]=true,--[斯克维里加全地形载具]
    },
    [MOUNT_JOURNAL_FILTER_FLYING]={
        --[339588]=true,--[罪奔者布兰契]
        [163024]=true,--战火梦魇兽
        --[366962]=true,--[艾什阿达，晨曦使者]
        --[107203]=true,--泰瑞尔的天使战马
        --[419345]=true,--伊芙的森怖骑行扫帚
    },
    [MOUNT_JOURNAL_FILTER_AQUATIC]={
        --[359379]=true,--闪光元水母
        --[376912]=true,--[热忱的载人奥獭]
        --[342680]=true,--[深星元水母]
        --[30174]=true,--[乌龟坐骑]
        [98718]=true,
        --[64731]=true,--[海龟]
    },
    [MOUNT_JOURNAL_FILTER_DRAGONRIDING]={
        [368896]=true,--[复苏始祖幼龙]
        --[368901]=true,--[崖际荒狂幼龙]
        --[368899]=true,--[载风迅疾幼龙]
        --[360954]=true,--[高地幼龙]
        --[339588]=true,--[罪奔者布兰契]
        --[134359]=true,--飞天魔像
    },
    ['Shift']={
        --[[[75973]=true,--X-53型观光火箭
        [93326]=true,--沙石幼龙
        [121820]=true,--黑耀夜之翼]]
        [359379]=true,--闪光元水母
        [376912]=true,--[热忱的载人奥獭]
        [342680]=true,--[深星元水母]
        [30174]=true,--[乌龟坐骑]
        [98718]=true,
        [64731]=true,--[海龟]
    },
    ['Alt']={[264058]=true,--雄壮商队雷龙
        [122708]=true,--雄壮远足牦牛
        [61425]=true,--旅行者的苔原猛犸象
    },
    ['Ctrl']={
        [256123]=true,--斯克维里加全地形载具
        --[118089]=true,--天蓝水黾
        --[127271]=true,--猩红水黾
        --[107203]=true,--泰瑞尔的天使战马
     },
}


WoWTools_MountMixin={
    Save={
        Mounts=P_Mouts_Tab,
        KEY= e.Player.husandro and 'BUTTON5', --为我自定义, 按键
        AFKRandom=e.Player.husandro,--离开时, 随机坐骑
        mountShowTime=3,--坐骑秀，时间
        showFlightModeButton=true, --切换飞行模式
        --toFrame=nil,
    },
    --MountButton=nil,
    --faction= nil,0 1
}

function WoWTools_MountMixin:Get_Table_Num(type)--检测,表里的数量
    local num= 0
    for _ in pairs(self.Save.Mounts[type]) do
        num=num+1
    end
    return num
end

function WoWTools_MountMixin:P_Mouts_Tab()
    return P_Mouts_Tab
end








local function Init()
    for type, tab in pairs(WoWTools_MountMixin.Save.Mounts) do
        for ID in pairs(tab) do
            WoWTools_Mixin:Load({id=ID, type= type==ITEMS and 'item' or 'spell'})
        end
    end

    WoWTools_MountMixin:Init_Button()
    WoWTools_MountMixin:Init_Mount_Show()--坐骑秀
    WoWTools_MountMixin:Init_SpellFlyoutButton()
end





local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWTools_MountMixin.addName= '|A:hud-microbutton-Mounts-Down:0:0|a'..(WoWTools_Mixin.onlyChinese and '坐骑' or MOUNT)

            if WoWToolsSave['Tools_Mounts'] then
                WoWTools_MountMixin.Save= WoWToolsSave['Tools_Mounts']
            end

            if not WoWTools_MountMixin.Save.Mounts[SPELLS] then--为不同语言，
                WoWTools_MountMixin.Save.Mounts= P_Mouts_Tab
            end

            WoWTools_MountMixin.MountButton= WoWTools_ToolsMixin:CreateButton({
                name='Mount',
                tooltip=WoWTools_MountMixin.addName,
            })

            if WoWTools_MountMixin.MountButton then
                Init()--初始

                if C_AddOns.IsAddOnLoaded('Blizzard_Collections') then
                    WoWTools_MountMixin:Init_MountJournal()
                end

                if C_AddOns.IsAddOnLoaded('Blizzard_PlayerSpells') then
                    WoWTools_MountMixin:Init_UI_SpellBook_Menu()--法术书，选项
                end

                WoWTools_MountMixin.faction= e.Player.faction=='Horde' and 0 or (e.Player.faction=='Alliance' and 1)
            else
                self:UnregisterEvent('ADDON_LOADED')
            end

        elseif arg1=='Blizzard_Collections' then--收藏
            WoWTools_MountMixin:Init_MountJournal()

        elseif arg1=='Blizzard_PlayerSpells' then--法术书
            WoWTools_MountMixin:Init_UI_SpellBook_Menu()--法术书，选项
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Tools_Mounts']= WoWTools_MountMixin.Save
        end
    end
end)
--436854 C_MountJournal.GetDynamicFlightModeSpellID() 切换飞行模式