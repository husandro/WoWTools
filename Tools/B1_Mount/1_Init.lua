


local P_Mouts_Tab={
    Item={
        [174464]=true,--幽魂缰绳
        [168035]=true,--噬渊鼠缰绳
        --[37011]=true,--/魔法扫帚
    },
    Spell={
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
    Floor={},--{[spellID]={uiMapID1=true, uiMapID2=true, ...}
    Ground={
        --[339588]=true,--[罪奔者布兰契]
        --[163024]=true,--战火梦魇兽
        --[366962]=true,--[艾什阿达，晨曦使者]
        [256123]=true,--[斯克维里加全地形载具]
    },
    Flying={
        --[339588]=true,--[罪奔者布兰契]
        [163024]=true,--战火梦魇兽
        --[366962]=true,--[艾什阿达，晨曦使者]
        --[107203]=true,--泰瑞尔的天使战马
        --[419345]=true,--伊芙的森怖骑行扫帚
    },
    Aquatic={
        --[359379]=true,--闪光元水母
        --[376912]=true,--[热忱的载人奥獭]
        --[342680]=true,--[深星元水母]
        --[30174]=true,--[乌龟坐骑]
        [98718]=true,
        --[64731]=true,--[海龟]
    },
    Dragonriding={
        [368896]=true,--[复苏始祖幼龙]
        --[368901]=true,--[崖际荒狂幼龙]
        --[368899]=true,--[载风迅疾幼龙]
        --[360954]=true,--[高地幼龙]
        --[339588]=true,--[罪奔者布兰契]
        --[134359]=true,--飞天魔像
    },
    Shift={
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
    Alt={
        [264058]=true,--雄壮商队雷龙
        [122708]=true,--雄壮远足牦牛
        [61425]=true,--旅行者的苔原猛犸象
    },
    Ctrl={
        [256123]=true,--斯克维里加全地形载具
        --[118089]=true,--天蓝水黾
        --[127271]=true,--猩红水黾
        --[107203]=true,--泰瑞尔的天使战马
     },
}


local P_Save={
    KEY= WoWTools_DataMixin.Player.husandro and 'BUTTON5', --为我自定义, 按键
    AFKRandom=WoWTools_DataMixin.Player.husandro,--离开时, 随机坐骑
    mountShowTime=3,--坐骑秀，时间
    showFlightModeButton=true, --切换飞行模式
    --toFrame=nil,
}



WoWTools_MountMixin={
    MountType={
        'Ground',
        'Aquatic',
        'Flying',
        'Dragonriding',

        'Alt',
        'Ctrl',
        'Shift',

        'Floor',
    },
    TypeName={
        Ground= MOUNT_JOURNAL_FILTER_GROUND,
        Aquatic= MOUNT_JOURNAL_FILTER_AQUATIC,
        Flying= MOUNT_JOURNAL_FILTER_FLYING,
        Dragonriding= MOUNT_JOURNAL_FILTER_DRAGONRIDING,

        Alt= 'Alt',
        Ctrl= 'Ctrl',
        Shift= 'Shift',
        Floor= FLOOR,

        Spell= SPELLS,
        Item= ITEMS,
    }
}

function WoWTools_MountMixin:Get_Table_Num(mountType)--检测,表里的数量
    local num= 0
    for _ in pairs(WoWToolsPlayerDate['Tools_Mounts'][mountType] or {}) do
        num=num+1
    end
    return num
end

function WoWTools_MountMixin:P_Mouts_Tab()
    return P_Mouts_Tab
end














local function Save()
    return WoWToolsSave['Tools_Mounts']
end




local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWTools_MountMixin.addName= '|TInterface\\Icons\\MountJournalPortrait:0|t'..(WoWTools_DataMixin.onlyChinese and '坐骑' or MOUNT)

            WoWToolsSave['Tools_Mounts']= WoWToolsSave['Tools_Mounts'] or P_Save
            P_Save= nil

            if Save().Mounts then--旧数据
                WoWToolsPlayerDate['Tools_Mounts']={
                    Item= Save().Mounts[ITEMS] or P_Mouts_Tab.Items or {},
                    Spell= Save().Mounts[SPELLS] or P_Mouts_Tab.Spell or {},
                    Floor= Save().Mounts[FLOOR] or P_Mouts_Tab.Floor or {},
                    Ground= Save().Mounts[MOUNT_JOURNAL_FILTER_GROUND] or P_Mouts_Tab.Ground or {},
                    Flying= Save().Mounts[MOUNT_JOURNAL_FILTER_FLYING] or P_Mouts_Tab.Flying or {},
                    Aquatic= Save().Mounts[MOUNT_JOURNAL_FILTER_AQUATIC] or P_Mouts_Tab.Aquatic or {},
                    Dragonriding= Save().Mounts[MOUNT_JOURNAL_FILTER_DRAGONRIDING] or P_Mouts_Tab.Dragonriding or {},
                    Shift= Save().Mounts.Shift or P_Mouts_Tab.Shift or {},
                    Alt= Save().Mounts.Alt or P_Mouts_Tab.Alt or {},
                    Ctrl= Save().Mounts.Ctrl or P_Mouts_Tab.Ctrl or {},
                }
                Save().Mounts= nil
            else
                WoWToolsPlayerDate['Tools_Mounts']= WoWToolsPlayerDate['Tools_Mounts'] or P_Mouts_Tab
            end

            WoWTools_ToolsMixin:CreateButton({
                name='Mount',
                tooltip=WoWTools_MountMixin.addName,
            })

            if WoWTools_ToolsMixin:Get_ButtonForName('Mount') then
                if WoWTools_DataMixin.onlyChinese and not LOCALE_zhCN then
                    WoWTools_MountMixin.TypeName={
                        Spell= '法术',
                        Item= '物品',
                        Ground= '地面',
                        Aquatic= '水栖',
                        Flying= '飞行',
                        Dragonriding= '驭空术',
                        Floor= '区域',
                    }
                end

                self:RegisterEvent('PLAYER_ENTERING_WORLD')

                WoWTools_MountMixin.faction= WoWTools_DataMixin.Player.Faction=='Horde' and 0 or (WoWTools_DataMixin.Player.Faction=='Alliance' and 1)

                for name, tab in pairs(WoWToolsPlayerDate['Tools_Mounts']) do
                    for ID in pairs(tab) do
                        WoWTools_DataMixin:Load(ID,  name=='Item' and 'item' or 'spell')
                    end
                end

                WoWTools_MountMixin:Init_MountJournal()
                WoWTools_MountMixin:Init_UI_SpellBook_Menu()--法术书，选项

            else
                self:SetScript('OnEvent', nil)
            end

            self:UnregisterEvent(event)
        end

    elseif event== 'PLAYER_ENTERING_WORLD'  then
        WoWTools_MountMixin:Init_Button()
        self:UnregisterEvent(event)
        self:SetScript('OnEvent', nil)
    end
end)
--436854 C_MountJournal.GetDynamicFlightModeSpellID() 切换飞行模式