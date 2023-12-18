local id, e= ...
if LOCALE_zhCN or LOCALE_zhTW then
    return
end


local addName= BUG_CATEGORY15
local Save={
    disabled= not e.Player.husandro
}
local panel= CreateFrame("Frame")



local strText={
    --Blizzard_AuctionData.lua
    [AUCTION_CATEGORY_WEAPONS] = "武器",
        [AUCTION_SUBCATEGORY_ONE_HANDED] = "单手",
            [GetItemSubClassInfo(2, 0)]= "单手斧",
            [GetItemSubClassInfo(2, 4)]= "单手锤",
            [GetItemSubClassInfo(2, 7)]= "单手剑",
            [GetItemSubClassInfo(2, 9)]= "战刃",
            [GetItemSubClassInfo(2, 15)]= "匕首",
            [GetItemSubClassInfo(2, 13)]= "拳套",
            [GetItemSubClassInfo(2, 19)]= "魔杖",
        [AUCTION_SUBCATEGORY_TWO_HANDED] = "双手",
            [GetItemSubClassInfo(2, 1)]= "双手斧",
            [GetItemSubClassInfo(2, 5)]= "双手锤",
            [GetItemSubClassInfo(2, 8)]= "双手剑",
            [GetItemSubClassInfo(2, 6)]= "长柄武器",
            [GetItemSubClassInfo(2, 10)]= "法杖",
        [AUCTION_SUBCATEGORY_RANGED] = "远程",
            [GetItemSubClassInfo(2, 2)]= "弓",
            [GetItemSubClassInfo(2, 18)]= "弩",
            [GetItemSubClassInfo(2, 3)]= "枪械",
            [GetItemSubClassInfo(2, 16)]= "投掷武器",
        [AUCTION_SUBCATEGORY_MISCELLANEOUS] = "杂项",
            [GetItemSubClassInfo(2, 20)]= "鱼竿",
            [AUCTION_SUBCATEGORY_OTHER] = "其他",
    [AUCTION_CATEGORY_ARMOR] = "护甲",
        ['|cff00ccff'..RUNEFORGE_LEGENDARY_CRAFTING_FRAME_TITLE..'|r'] = "|cff00ccff符文铭刻|r",
        [GetItemSubClassInfo(4, 4)]= "板甲",
        [GetItemSubClassInfo(4, 3)]= "锁甲",
        [GetItemSubClassInfo(4, 2)]= "皮甲",
        [GetItemSubClassInfo(4, 1)]= "布甲",
        --[AUCTION_SUBCATEGORY_MISCELLANEOUS] = "杂项",
            [AUCTION_SUBCATEGORY_CLOAK] = "披风",
            [INVTYPE_FINGER]= "手指",
            [INVTYPE_TRINKET] = "饰品",
            [INVTYPE_HOLDABLE] = "副手物品",
            [SHOW_COMBAT_HEALING_ABSORB_SELF] = "护盾",
            [INVTYPE_BODY] = "衬衣",
        [ITEM_COSMETIC] = "装饰品",
    [AUCTION_CATEGORY_CONTAINERS] = "容器",
        [GetItemSubClassInfo(1, 0)]= "容器",
        [GetItemSubClassInfo(1, 2)]= "草药",
        [GetItemSubClassInfo(1, 3)]= "附魔",
        [GetItemSubClassInfo(1, 4)]= "工程",
        [GetItemSubClassInfo(1, 5)]= "宝石",
        [GetItemSubClassInfo(1, 6)]= "矿石",
        [GetItemSubClassInfo(1, 7)]= "制皮",
        [GetItemSubClassInfo(1, 8)]= "铭文",
        [GetItemSubClassInfo(1, 9)]= "钓鱼",
        [GetItemSubClassInfo(1, 10)]= "烹饪",
        [GetItemSubClassInfo(1, 11)]= "材料",
    [AUCTION_CATEGORY_GEMS] = "宝石",
        [GetItemSubClassInfo(3, 11)]= "神器圣物",
        [GetItemSubClassInfo(3, 0)]= "智力",
        [GetItemSubClassInfo(3, 1)]= "敏捷",
        [GetItemSubClassInfo(3, 2)]= "力量",
        [GetItemSubClassInfo(3, 3)]= "耐力",
        [GetItemSubClassInfo(3, 5)]= "爆机",
        [GetItemSubClassInfo(3, 6)]= "精通",
        [GetItemSubClassInfo(3, 7)]= "急速",
        [GetItemSubClassInfo(3, 8)]= "全能",
        [GetItemSubClassInfo(3, 10)]= "复合属性",
    [AUCTION_CATEGORY_ITEM_ENHANCEMENT] = "物品强化",
        [GetItemSubClassInfo(8, 0)] = "头部",
        [GetItemSubClassInfo(8, 1)] = "颈部",
        [GetItemSubClassInfo(8, 2)] = "肩部",
        [GetItemSubClassInfo(8, 3)] = "披风",
        [GetItemSubClassInfo(8, 4)] = "胸部",
        [GetItemSubClassInfo(8, 5)] = "手腕",
        [GetItemSubClassInfo(8, 6)] = "手部",
        [GetItemSubClassInfo(8, 7)] = "腰部",
        [GetItemSubClassInfo(8, 8)] = "腿部",
        [GetItemSubClassInfo(8, 9)] = "脚部",
        [GetItemSubClassInfo(8, 10)] = "手指",
        [GetItemSubClassInfo(8, 11)] = "武器",
        [GetItemSubClassInfo(8, 12)] = "双手武器",
        [GetItemSubClassInfo(8, 13)] = "盾牌/副手",
    [AUCTION_CATEGORY_CONSUMABLES] = "消耗品",
        [GetItemSubClassInfo(0, 0)] = "爆炸物和装置",
        [GetItemSubClassInfo(0, 1)] = "药水",
        [GetItemSubClassInfo(0, 2)] = "药剂",
        [GetItemSubClassInfo(0, 3)] = "合剂和瓶剂",
        [GetItemSubClassInfo(0, 5)] = "食物和饮水",
        [GetItemSubClassInfo(0, 7)] = "绷带",
        [GetItemSubClassInfo(0, 9)] = "凡图斯符文",
    [AUCTION_CATEGORY_GLYPHS] = "雕文",
        [GetItemSubClassInfo(16, 1)] = "|cffc69b6d战士|r",
        [GetItemSubClassInfo(16, 2)] = "|cfff48cba圣骑士|r",
        [GetItemSubClassInfo(16, 3)] = "|cffaad372猎人|r",
        [GetItemSubClassInfo(16, 4)] = "|cfffff468盗贼|r",
        [GetItemSubClassInfo(16, 5)] = "|cffffffff牧师|r",
        [GetItemSubClassInfo(16, 6)] = "|cffc41e3a死亡骑士|r",
        [GetItemSubClassInfo(16, 7)] = "|cff0070dd萨满|r",
        [GetItemSubClassInfo(16, 8)] = "|cff3fc7eb法师|r",
        [GetItemSubClassInfo(16, 9)] = "|cff8788ee术士|r",
        [GetItemSubClassInfo(16, 10)] = "|cff00ff98武僧|r",
        [GetItemSubClassInfo(16, 11)] = "|cffff7c0a德鲁伊|r",
        [GetItemSubClassInfo(16, 12)] = "|cffa330c9恶魔猎手|r",

    [AUCTION_CATEGORY_TRADE_GOODS] = "杂货",
        [GetItemSubClassInfo(7, 5)] = "布料",
        [GetItemSubClassInfo(7, 6)] = "皮料",
        [GetItemSubClassInfo(7, 7)] = "金属和矿石",
        [GetItemSubClassInfo(7, 8)] = "烹饪",

        [GetItemSubClassInfo(7, 9)] = "草药",
        [GetItemSubClassInfo(7, 12)] = "附魔材料",
        [GetItemSubClassInfo(7, 16)] = "铭文",
        [GetItemSubClassInfo(7, 4)] = "珠宝加工",
        [GetItemSubClassInfo(7, 1)] = "零件",
        [GetItemSubClassInfo(7, 10)] = "元素",

        [GetItemSubClassInfo(7, 18)] = "附加材料",
        [GetItemSubClassInfo(7, 19)] = "成器材料",
    [AUCTION_CATEGORY_RECIPES] = "配方",
        [GetItemSubClassInfo(9, 1)] = "制皮",
        [GetItemSubClassInfo(9, 2)] = "裁缝",
        [GetItemSubClassInfo(9, 3)] = "工程",
        [GetItemSubClassInfo(9, 4)] = "锻造",
        [GetItemSubClassInfo(9, 6)] = "炼金术",
        [GetItemSubClassInfo(9, 8)] = "附魔",
        [GetItemSubClassInfo(9, 10)] = "珠宝加工",
        [GetItemSubClassInfo(9, 11)] = "铭文",
        [GetItemSubClassInfo(9, 5)] = "烹饪",
        [GetItemSubClassInfo(9, 7)] = "急救",
        --[GetItemSubClassInfo(9, 9)] = "钓鱼",
        [GetItemSubClassInfo(9, 0)] = "书籍",
    [AUCTION_CATEGORY_PROFESSION_EQUIPMENT] = "专业装备",
        [GetItemSubClassInfo(19, 5)] = "采矿",
        [GetItemSubClassInfo(19, 3)] = "草药学",
        [GetItemSubClassInfo(19, 10)] = "剥皮",
        [PROFESSIONS_FISHING] = "钓鱼",
    [AUCTION_CATEGORY_BATTLE_PETS] = "战斗宠物",
        [GetItemSubClassInfo(17, 0)] = "人形",
        [GetItemSubClassInfo(17, 1)] = "龙类",
        [GetItemSubClassInfo(17, 2)] = "飞行",
        [GetItemSubClassInfo(17, 3)] = "亡灵",
        [GetItemSubClassInfo(17, 4)] = "小动物",
        [GetItemSubClassInfo(17, 5)] = "魔法",
        [GetItemSubClassInfo(17, 6)] = "元素",
        [GetItemSubClassInfo(17, 7)] = "野兽",
        [GetItemSubClassInfo(17, 8)] = "水栖",
        [GetItemSubClassInfo(17, 9)] = "机械",
        [COMPANIONS] = "小伙伴",
    [AUCTION_CATEGORY_QUEST_ITEMS] = "任务物品",
    [AUCTION_CATEGORY_MISCELLANEOUS] = "杂项",
        [GetItemSubClassInfo(15, 0)] = "垃圾",
        [GetItemSubClassInfo(15, 1)] = "材料",
        [GetItemSubClassInfo(15, 3)] = "节日",
        [GetItemSubClassInfo(15, 5)] = "坐骑",
        [GetItemSubClassInfo(15, 6)] = "坐骑装备",
    [AUCTION_SUBCATEGORY_PROFESSION_ACCESSORIES] = "配饰",
    [AUCTION_SUBCATEGORY_PROFESSION_TOOLS] = "工具",
    [GetItemSubClassInfo(18, 0)] = "时光徽章",





    --成就
    [ACHIEVEMENT_SUMMARY_CATEGORY] = "总览",
    [CHARACTER] = "角色",
    [QUESTS_LABEL] = "任务",
    [GROUP_FINDER] = "地下城和团队副本",
    [TRADE_SKILLS] = "专业",
    [PROFESSIONS_ARCHAEOLOGY] = "考古学",
    [REPUTATION] = "声望",
    [HONOR] = "荣誉",
    [COLLECTIONS] = "藏品",
    [GENERAL] = "综合",
    [KILLS] = "杀敌",
    [DEATHS] = "死亡",
    [SKILLS] = "技能",
    [TUTORIAL_TITLE35] = "旅行",
    [SOCIALS] = "社交",
    [TRACKER_HEADER_PROVINGGROUNDS] = "试炼场",
    [COMBAT_TEXT_SHOW_HONOR_GAINED_TEXT] = "荣誉消灭",
    [KILLING_BLOW_TOOLTIP_TITLE] = "消灭",
    [EVENTS_LABEL] = "事件",

    [BATTLE_PET_SOURCE_5] = "宠物对战",
    [BATTLE_PET_SOURCE_7] = "世界事件",
    [BATTLE_PET_SOURCE_8] = "特殊",
    [GAMES] = "比赛",

    [EXPANSION_NAME0] = "经典旧世",
    [EXPANSION_NAME1] = "燃烧的远征",
    [EXPANSION_NAME2] = "巫妖王之怒",
    [EXPANSION_NAME3] = "大地的裂变",
    [EXPANSION_NAME4] = "熊猫人之谜",
    [POSTMASTER_PIPE_PANDARIA] = "潘达利亚",
    [POSTMASTER_PIPE_DRAENOR] = "德拉诺",
    [EXPANSION_NAME5] = "德拉诺之王",
    [EXPANSION_NAME6] = "军团再临",
    [EXPANSION_NAME7] = "争霸艾泽拉斯",
    [EXPANSION_NAME8] = "暗影国度",
    [EXPANSION_NAME9] = "巨龙时代",
    [BATTLEGROUNDS] = "战场",
    --[CHANNEL_CATEGORY_WORLD] = "世界",
    [GUILD_CHALLENGE_TYPE1] = "地下城",
    [GUILD_CHALLENGE_TYPE2] = "团队副本",
    [GUILD_CHALLENGE_TYPE3] = "评级战场",
    [GUILD_CHALLENGE_TYPE4] = "场景战役",
    [GUILD_CHALLENGE_TYPE5] = "史诗钥石地下城",


    [DUNGEON_FLOOR_TOLBARADWARLOCKSCENARIO0] = "托尔巴拉德",
    [POSTMASTER_PIPE_EASTERNKINGDOMS] = "东部王国",
    [POSTMASTER_PIPE_KALIMDOR] = "卡利姆多",
    [POSTMASTER_PIPE_NORTHREND] = "诺森德",
    [POSTMASTER_PIPE_OUTLAND] = "外域",
    [WORLD_PVP] = "阿什兰",
    [WORLD] = "世界",
    [TOY_BOX] = "玩具箱",
    [WARDROBE] = "外观",

    --选项
    [SETTINGS_TAB_GAME] = "游戏",
        [CONTROLS_LABEL] = "控制",
            [GAMEFIELD_DESELECT_TEXT] = "目标锁定",

            [AUTO_DISMOUNT_FLYING_TEXT] = "自动取消飞行",

            [CLEAR_AFK] = "自动解除离开状态",

            [INTERACT_ON_LEFT_CLICK_TEXT] = "左键点击操作",

            [LOOT_UNDER_MOUSE_TEXT] = "鼠标位置打开拾取窗口",

            [AUTO_LOOT_DEFAULT_TEXT] = "自动拾取",

            [AUTO_LOOT_KEY_TEXT] = "自动拾取按键",
            [USE_COMBINED_BAGS_TEXT] = "组合背包",

            [ENABLE_INTERACT_TEXT] = "开启交互按键",
            [BINDING_NAME_INTERACTTARGET] = "与目标互动",

            [ENABLE_INTERACT_SOUND_OPTION] = "交互按键音效提示",
                [ENABLE_INTERACT_SOUND_OPTION_TOOLTIP] = "你变得可以或者不可以与一个目标互动时，播放音效提示。",
        [MOUSE_LABEL] = "鼠标",
            [LOCK_CURSOR] = "将鼠标指针锁定在窗口内",

            [INVERT_MOUSE] = "反转鼠标",

            [MOUSE_LOOK_SPEED] = "鼠标观察速度",

            [ENABLE_MOUSE_SPEED] = "启用鼠标灵敏度",

            [MOUSE_SENSITIVITY] = "鼠标灵敏度",

            [CLICK_TO_MOVE] = "点击移动",

        [CAMERA_LABEL] = "镜头",
            [WATER_COLLISION] = "水体碰撞",

            [AUTO_FOLLOW_SPEED] = "自动跟随速度",

            [CAMERA_CTM_FOLLOWING_STYLE] = "镜头跟随模式",

    [INTERFACE_LABEL] = "界面",--Interface.lua
        [NAMES_LABEL] = "名字",
            [UNIT_NAME_OWN] = "我的名字",
            [SHOW_NPC_NAMES] = "NPC姓名",
            [UNIT_NAME_NONCOMBAT_CREATURE] = "小动物和小伙伴",
            [UNIT_NAME_FRIENDLY] = "友方玩家",
                [UNIT_NAME_FRIENDLY_MINIONS] = "仆从",
            [UNIT_NAME_ENEMY] = "敌方玩家",
        [NAMEPLATES_LABEL] = "姓名板",
            [UNIT_NAMEPLATES_AUTOMODE] = "显示所有姓名板",
                [UNIT_NAMEPLATES_MAKE_LARGER] = "大姓名板",
            [UNIT_NAMEPLATES_SHOW_ENEMIES] = "敌方单位姓名板",
                [UNIT_NAMEPLATES_SHOW_ENEMY_MINIONS] = "仆从",
                [UNIT_NAMEPLATES_SHOW_ENEMY_MINUS] = "杂兵",
            [UNIT_NAMEPLATES_SHOW_FRIENDS] = "友方玩家姓名板",
            [UNIT_NAMEPLATES_SHOW_FRIENDLY_MINIONS] = "仆从",
            [SHOW_NAMEPLATE_LOSE_AGGRO_FLASH] = "失去怪物威胁时闪烁",
            [UNIT_NAMEPLATES_TYPES] = "姓名板排列方式",
        [DISPLAY_LABEL] = "显示",
            [HIDE_ADVENTURE_JOURNAL_ALERTS] = "隐藏冒险指南提示",
            [SHOW_IN_GAME_NAVIGATION] = "游戏内导航",
            [SHOW_TUTORIALS]= "教程",
            [OBJECT_NPC_OUTLINE] = "轮廓线模式",
            [STATUSTEXT_LABEL] = "状态文字",
            [CHAT_BUBBLES_TEXT] = "聊天泡泡",
            [REPLACE_OTHER_PLAYER_PORTRAITS] = "替换玩家框体头像",
            [REPLACE_MY_PLAYER_PORTRAIT] = "替换我的框体头像",
        [RAID_FRAMES_LABEL] = "团队框体",--InterfaceOverrides.lua
            [COMPACT_UNIT_FRAME_PROFILE_DISPLAYHEALPREDICTION] = "显示预计治疗",
                [COMPACT_UNIT_FRAME_PROFILE_DISPLAYPOWERBAR] = "显示能量条",
            [COMPACT_UNIT_FRAME_PROFILE_DISPLAYAGGROHIGHLIGHT] = "高亮显示仇恨目标",
            [COMPACT_UNIT_FRAME_PROFILE_DISPLAYONLYHEALERPOWERBARS] = "只显示治疗者能量条",
            [PVP_COMPACT_UNIT_FRAME_PROFILE_USECLASSCOLORS] = "显示职业颜色",
            [PVP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYPETS] = "显示宠物",
            [COMPACT_UNIT_FRAME_PROFILE_DISPLAYMAINTANKANDASSIST] = "显示主坦克和主助理",
            [COMPACT_UNIT_FRAME_PROFILE_DISPLAYNONBOSSDEBUFFS] = "显示负面效果",
                [DISPLAY_ONLY_DISPELLABLE_DEBUFFS] = "只显示可供驱散的负面效果",
            [PVP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT] = "显示生命值数值",

        [PVP_FRAMES_LABEL] = "竞技场对手框体",


        [SETTING_GROUP_GAMEPLAY] = "游戏功能",

    [ACTIONBARS_LABEL] = "动作条",--ActionBars.lua
        [COUNTDOWN_FOR_COOLDOWNS_TEXT] = "显示冷却时间",
        [LOCK_ACTIONBAR_TEXT] = "锁定动作条",

    [COMBAT_LABEL] = "战斗",--Combat.lua
        [DISPLAY_PERSONAL_RESOURCE] = "显示个人资源",
            [NAMEPLATE_HIDE_HEALTH_AND_POWER] = "隐藏生命值和能量条",
            [DISPLAY_PERSONAL_RESOURCE_ON_ENEMY] = "在敌方目标上显示玩家的特殊资源",
            [DISPLAY_PERSONAL_COOLDOWNS] = "显示个人冷却时间",
            [DISPLAY_PERSONAL_FRIENDLY_BUFFS] = "显示友方增益效果",
        [SELF_HIGHLIGHT_OPTION] = "团队中自身高亮",
        [SHOW_TARGET_OF_TARGET_TEXT] = "目标的目标",
        [FLASH_LOW_HEALTH_WARNING] = "生命值过低时不闪烁屏幕",
        [LOSS_OF_CONTROL] = "失控警报",
        [SHOW_COMBAT_TEXT_TEXT] = "滚动战斗记录",
        [ENABLE_MOUSEOVER_CAST] = "鼠标悬停施法",
        [AUTO_SELF_CAST_TEXT] = "自动自我施法",
            [AUTO_SELF_CAST_KEY_TEXT] = "自我施法",
        [FOCUS_CAST_KEY_TEXT] = "焦点施法按键",
        [SETTING_EMPOWERED_SPELL_INPUT] = "蓄力法术输入",
        [SPELL_ALERT_OPACITY] = "法术警报不透明度",
        [PRESS_AND_HOLD_CASTING_OPTION] = "按住施法",
        [ACTION_TARGETING_OPTION] = "开启动作瞄准",

    --社交 Social.lua
        [RESTRICT_CHAT_CONFIG_DISABLE] = "关闭聊天",
        [CENSOR_SOURCE_EXCLUDE] = "屏蔽信息",
        [PROFANITY_FILTER] = "语言过滤器",
        [GUILDMEMBER_ALERT] = "公会成员提示",
        [BLOCK_TRADES] = "阻止交易",
        [BLOCK_GUILD_INVITES] = "阻止公会邀请",
        [RESTRICT_CALENDAR_INVITES] = "限制日历邀请",
        [SHOW_ACCOUNT_ACHIEVEMENTS] = "对他人只显示角色成就",
        [BLOCK_CHAT_CHANNEL_INVITE] = "阻止聊天频道邀请",
        [SHOW_TOAST_ONLINE_TEXT] = "好友上线",
        [SHOW_TOAST_OFFLINE_TEXT] = "好友下线",
        [SHOW_TOAST_BROADCAST_TEXT] = "通告更新",
        [SHOW_TOAST_FRIEND_REQUEST_TEXT] = "实名和战网昵称好友请求",
        [SHOW_TOAST_WINDOW_TEXT] = "显示浮窗",
        [AUTO_ACCEPT_QUICK_JOIN_TEXT] = "自动接受快速加入申请",
        [CHAT_STYLE] = "聊天风格",
        [WHISPER_MODE] = "新的悄悄话",
        [TIMESTAMPS_LABEL] = "聊天时间戳",
        [RESET_CHAT_POSITION] = "重置聊天窗口位置",

    [PING_SYSTEM_LABEL] = "信号系统",--PingSystem.lua AudioOverrides.lua
        [ENABLE_PINGS] = "开启信号",
        [PING_MODE] = "信号模式",
        [ENABLE_PING_SOUNDS] = "信号音效",
        [SHOW_PINGS_IN_CHAT] = "在聊天中显示信号",

    [SETTINGS_KEYBINDINGS_LABEL] = "快捷键",
    [SETTING_GROUP_ACCESSIBILITY] = "易用性",--Accessibility.lua
        [MOVE_PAD] = "显示移动框",
        [CINEMATIC_SUBTITLES] = "动画字幕",
        [ALTERNATE_SCREEN_EFFECTS] = "开启光敏模式",
        [ENABLE_QUEST_TEXT_CONTRAST] = "任务文本颜色反差",
        [MINIMUM_CHARACTER_NAME_SIZE_TEXT] = "最小角色名尺寸",
        [MOTION_SICKNESS_DROPDOWN] = "动态眩晕",
        [ADJUST_MOTION_SICKNESS_SHAKE] = "视角晃动",
        [CURSOR_SIZE] = "鼠标指针大小",
        [TARGET_TOOLTIP_OPTION] = "动作瞄准提示信息",
        [INTERACT_ICONS_OPTION] = "交互按键图标",
        
    --综合
    [COLORBLIND_LABEL] = "色盲模式",
    [TTS_LABEL] = "文本转语音",
        [ENABLE_SPEECH_TO_TEXT_TRANSCRIPTION] = "语音聊天文字转录",
        [ENABLE_TEXT_TO_SPEECH] = "大声朗读聊天文本",
        [ENABLE_REMOTE_TEXT_TO_SPEECH] = "在语音聊天中为我发言",
        [VOICE] = "语音",
    --[ACCESSIBILITY_MOUNT_LABEL] = "坐骑", Mounts.lua
        [ACCESSIBILITY_ADV_FLY_LABEL] = "动态飞行",
        [MOTION_SICKNESS_DRAGONRIDING] = "晕动症",
        "动态飞行屏幕效果",
        [MOTION_SICKNESS_DRAGONRIDING_SPEED_EFFECTS] = "动态飞行速度效果",
        [ADV_FLY_PITCH_CONTROL] = "倾角控制",
        [ADV_FLY_PITCH_CONTROL_GROUND_DEBOUNCE] = "防抖倾角输入",
        [ADV_FLY_CAMERA_PITCH_CHASE_TEXT] = "键盘倾斜镜头跟随",
        [ADV_FLY_MINIMUM_PITCH_TEXT] = "最低键盘倾斜速度",
        [ADV_FLY_MINIMUM_TURN_TEXT] = "最低键盘转向速度",
        [ADV_FLY_MAXIMUM_PITCH_TEXT] = "最高键盘倾斜速度",
        [ADV_FLY_MAXIMUM_TURN_TEXT] = "最高键盘转向速度",
        [ADV_FLY_MINIMUM_TURN_TEXT] = "最低键盘转向速度",
        

    [SETTING_GROUP_SYSTEM] = "系统",
        [GRAPHICS_LABEL] = "图形",--Graphics.lua
            [PRIMARY_MONITOR] = "显示器",
            [DISPLAY_MODE] = "显示模式",
            [WINDOW_SIZE] = "分辨率",
            [CUSTOM] = "自定义",
            [RENDER_SCALE] = "渲染倍数",
            [VERTICAL_SYNC] = "垂直同步",
            [NOTCH_MODE] = "刘海屏模式",
            [LOW_LATENCY_MODE] = "低延迟模式",
            [ANTIALIASING] = "抗锯齿",
            [FXAA_CMAA_LABEL] = "基于图像的技术",
            [MSAA_LABEL] = "多重采样技术",
            [MULTISAMPLE_ALPHA_TEST] = "多重采样测试",
            [RENDER_SCALE] = "渲染倍数",
            [CAMERA_FOV] = "镜头视野范围",
            [USE_UISCALE] = "使用UI缩放",
            [RAID_SETTINGS_ENABLED] = "启用团队副本和战场设置",
            [GRAPHICS_QUALITY] = "图像质量",
            [ADVANCED_LABEL] = "高级",
            [TRIPLE_BUFFER] = "三倍缓冲",
            [ANISOTROPIC] = "材质过滤",
            [RT_SHADOW_QUALITY] = "光线追踪阴影",
            [SSAO_TYPE_LABEL] = "环境光遮蔽类型",
            [RESAMPLE_QUALITY] = "重新采样品质",
            [VRS_MODE] = "VRS模式",
            [GXAPI] = "图形接口",
            [PHYSICS_INTERACTION] = "物理交互",
            [GRAPHICS_CARD] = "显卡",
            [MAXFPS_CHECK] = "最高前台帧数开关",
            [MAXFPS] = "最高前台帧数",
            [MAXFPSBK_CHECK] = "最高后台帧数开关",
            [MAXFPSBK] = "最高后台帧数",
            [TARGETFPS] = "目标帧数",
            [RESAMPLE_SHARPNESS] = "重新采样锐度",
            [OPTION_CONTRAST] = "对比度",
            [OPTIONS_BRIGHTNESS] = "亮度",
            [GAMMA] = "伽马值",

            --[LIQUID_DETAIL] = "液体细节",
        [AUDIO_LABEL] = "音频",
        [LANGUAGES_LABEL] = "语言",
        [NETWORK_LABEL] = "网络",






}


























local function set(self, text)
    if self and text and not self:IsForbidden() then--CanAccessObject(self) then
        self:SetText(text)
    end
end


























local function Init()
    --角色
    set(CharacterFrameTab1, '角色')
    set(CharacterFrameTab2, '声望')
    set(CharacterFrameTab3, '货币')
    set(CharacterStatsPane.ItemLevelCategory.Title, '物品等级')
    set(CharacterStatsPane.AttributesCategory.Title, '属性')
    set(CharacterStatsPane.EnhancementsCategory.Title, '强化属性')

    set(PaperDollFrameEquipSetText, '装备')
    set(PaperDollFrameSaveSetText , '保存')

    set(GearManagerPopupFrame.BorderBox.EditBoxHeaderText, '输入方案名称（最多16个字符）：')
    set(GearManagerPopupFrame.BorderBox.IconSelectionText, '选择一个图标：')
    set(GearManagerPopupFrame.BorderBox.OkayButton, '确认')
    set(GearManagerPopupFrame.BorderBox.CancelButton, '取消')
    GearManagerPopupFrame:HookScript('OnShow', function(self)
        set(self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconHeader, '当前已选择')
        set(self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription, '点击在列表中浏览')
    end)

    PAPERDOLL_SIDEBARS[1].name= '角色属性'
    PAPERDOLL_SIDEBARS[2].name= '头衔'
    PAPERDOLL_SIDEBARS[3].name= '装备管理'

    --ReputationFrame.xml
    set(ReputationDetailViewRenownButton, '浏览名望')
    set(ReputationDetailMainScreenCheckBoxText, '显示为经验条')
    set(ReputationDetailInactiveCheckBoxText, '隐藏')
    set(ReputationDetailAtWarCheckBoxText, '交战状态')

    set(TokenFramePopup.Title, '货币设置')
    set(TokenFramePopup.InactiveCheckBox.Text, '未使用')
    set(TokenFramePopup.BackpackCheckBox.Text, '在行囊上显示')

    --法术 SpellBookFrame.lua
    hooksecurefunc('SpellBookFrame_Update', function()
        set(SpellBookFrameTabButton1, '法术')
        set(SpellBookFrameTabButton2, '专业')
        set(SpellBookFrameTabButton3, '宠物')
    end)

    --LFD PVEFrame.lua
    set(PVEFrameTab1, '地下城和团队副本')
    set(PVEFrameTab2, 'PvP')
    set(PVEFrameTab3, '史诗钥石地下城')


    set(GroupFinderFrame.groupButton1.name, '地下城查找器')
    set(GroupFinderFrame.groupButton2.name, '团队查找器')
    set(GroupFinderFrame.groupButton3.name, '预创建队伍')
    set(LFGListFrame.CategorySelection.StartGroupButton, '创建队伍')
    set(LFGListFrame.CategorySelection.FindGroupButton, '寻找队伍')


    --选项
    hooksecurefunc(SettingsPanel.Container.SettingsList.ScrollBox, 'Update', function(frame)
        if not frame:GetView() then
            return
        end
        for _, btn in pairs(frame:GetFrames() or {}) do
            if btn.Title then
                set(btn.Title, strText[btn.Title:GetText()])

            elseif btn.Label then
                set(btn.Label, strText[btn.Label:GetText()])

            elseif btn.Text and btn.data and btn.data.name and strText[btn.data.name] then
                set(btn.Text, strText[btn.data.name])
                btn.data.tooltip= strText[btn.data.tooltip] or btn.data.tooltip
            end
        end
    end)
    --hooksecurefunc(SettingsListSearchCategoryMixin, 'Init', function(self, initializer)

    --Blizzard_CategoryList.lua
    hooksecurefunc(SettingsCategoryListButtonMixin, 'Init', function(self, initializer)--hooksecurefunc(SettingsPanel.CategoryList.ScrollBox, 'Update', function(frame)
        local category = initializer.data.category
        set(self.Label, strText[category:GetName()])
    end)
    hooksecurefunc(SettingsCategoryListHeaderMixin, 'Init', function(self, initializer)
        local text= strText[initializer.data.label]
        if text then
            self.Label:SetText(text)
        end
    end)
    
    set(SettingsPanel.Container.SettingsList.Header.DefaultsButton, '默认设置')
end
































local function Init_Loaded(arg1)
    if arg1=='Blizzard_AuctionHouseUI' then
        hooksecurefunc('AuctionHouseFilterButton_SetUp', function(btn, info)
            set(btn, strText[info.name])
        end)

        set(AuctionHouseFrameBuyTab.Text, '购买')
        set(AuctionHouseFrameSellTab.Text, '出售')
        set(AuctionHouseFrameAuctionsTab.Text, '拍卖')
        set(AuctionHouseFrameAuctionsFrame.CancelAuctionButton, '取消拍卖')
        set(AuctionHouseFrameAuctionsFrameAuctionsTab.Text, '拍卖')
        set(AuctionHouseFrameAuctionsFrameBidsTab.Text, '竞标')
        set(AuctionHouseFrameAuctionsFrameBidsTab.Text, '竞标')
        --set(AuctionHouseFrameAuctionsFrameText, '一口价')

        set(AuctionHouseFrame.SearchBar.SearchButton, '搜索')

        set(AuctionHouseFrame.ItemSellFrame.CreateAuctionLabel, '开始拍卖')
        set(AuctionHouseFrame.ItemSellFrame.PostButton,'创建拍卖')
        set(AuctionHouseFrame.ItemSellFrame.QuantityInput.Label, '数量')
        set(AuctionHouseFrame.ItemSellFrame.DurationDropDown.Label, '持续时间')
        set(AuctionHouseFrame.ItemSellFrame.Deposit.Label, '保证金')
        set(AuctionHouseFrame.ItemSellFrame.TotalPrice.Label, '总价')
        set(AuctionHouseFrame.ItemSellFrame.QuantityInput.MaxButton, '最大数量')
        set(AuctionHouseFrame.ItemSellFrame.PriceInput.PerItemPostfix, '每个物品')
        set(AuctionHouseFrame.ItemSellFrame.SecondaryPriceInput.Label, '竞标价格')
        --Blizzard_AuctionHouseUI
        hooksecurefunc(AuctionHouseFrame.ItemSellFrame, 'SetSecondaryPriceInputEnabled', function(self, enabled)
            self.PriceInput:SetLabel('一口价')--AUCTION_HOUSE_BUYOUT_LABEL)
            if enabled then
                self.PriceInput:SetSubtext('|cff777777(可选)|r')--AUCTION_HOUSE_BUYOUT_OPTIONAL_LABEL
            end
        end)

        set(AuctionHouseFrame.CommoditiesSellFrame.CreateAuctionLabel, '开始拍卖')
        set(AuctionHouseFrame.CommoditiesSellFrame.PostButton,'创建拍卖')
        set(AuctionHouseFrame.CommoditiesSellFrame.QuantityInput.Label, '数量')
        set(AuctionHouseFrame.CommoditiesSellFrame.PriceInput.Label, '一口价')
        set(AuctionHouseFrame.CommoditiesSellFrame.DurationDropDown.Label, '持续时间')
        set(AuctionHouseFrame.CommoditiesSellFrame.Deposit.Label, '保证金')
        set(AuctionHouseFrame.CommoditiesSellFrame.TotalPrice.Label, '总价')
        set(AuctionHouseFrame.CommoditiesSellFrame.QuantityInput.MaxButton, '最大数量')
        set(AuctionHouseFrame.CommoditiesSellFrame.PriceInput.PerItemPostfix, '每个物品')
        set(AuctionHouseFrame.ItemSellFrame.BuyoutModeCheckButton.Text, '一口价')



        set(AuctionHouseFrame.CommoditiesBuyFrame.BackButton, '返回')
        set(AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.BuyButton, '一口价')
        set(AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.QuantityInput.Label, '数量')
        set(AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.UnitPrice.Label, '单价')
        set(AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.TotalPrice.Label, '总价')

        set(AuctionHouseFrame.ItemBuyFrame.BackButton, '返回')
        set(AuctionHouseFrame.ItemBuyFrame.BidFrame.BidButton, '竞标')
        set(AuctionHouseFrame.ItemBuyFrame.BuyoutFrame.BuyoutButton, '一口价')

    elseif arg1=='Blizzard_ClassTalentUI' then--Blizzard_TalentUI.lua Blizzard_AuctionData.lua
         for _, tabID in pairs(ClassTalentFrame:GetTabSet() or {}) do
            local btn= ClassTalentFrame:GetTabButton(tabID)
            if tabID==1 then
                set(btn, '专精')
            elseif tabID==2 then
                set(btn, '天赋')
            end
        end
        set(ClassTalentFrame.TalentsTab.ApplyButton, '应用改动')

    elseif arg1=='Blizzard_ProfessionsCustomerOrders' then
        hooksecurefunc(ProfessionsCustomerOrdersCategoryButtonMixin, 'Init', function(self, categoryInfo, _, isRecraftCategory)
            if isRecraftCategory then
                set(self, '开始再造订单')
            elseif categoryInfo and categoryInfo.categoryName and strText[categoryInfo.categoryName] then
                set(self, strText[categoryInfo.categoryName])
            end
        end)
        set(ProfessionsCustomerOrdersFrameBrowseTab, '发布订单')
        set(ProfessionsCustomerOrdersFrameOrdersTab, '我的订单')
        set(ProfessionsCustomerOrdersFrame.BrowseOrders.SearchBar.SearchButton, '搜索')

        set(ProfessionsCustomerOrdersFrame.Form.BackButton, '返回' )
        set(ProfessionsCustomerOrdersFrame.Form.ReagentContainer.RecraftInfoText, "再造功能可以让你改变某些制作的装备的附加材料和品质。\n\n你可以在再造时提升技能，但几率较低。")
        set(ProfessionsCustomerOrdersFrame.Form.TrackRecipeCheckBox.Text, '追踪配方')
        set(ProfessionsCustomerOrdersFrame.Form.AllocateBestQualityCheckBox.Text, '使用最高品质材料')
        --set(ProfessionsCustomerOrdersFrame.Form.ReagentContainer.Reagents.Label.Text, '提供材料：')

        set(ProfessionsCustomerOrdersFrame.Form.MinimumQuality.Text, '')
        set(ProfessionsCustomerOrdersFrame.Form.PaymentContainer.NoteEditBox.TitleBox.Title, '给制作者的信息：')
        set(ProfessionsCustomerOrdersFrame.Form.PaymentContainer.Tip, '佣金')
        set(ProfessionsCustomerOrdersFrame.Form.PaymentContainer.Duration.TimeRemaining, '过期时间')

    elseif arg1=='Blizzard_Collections' then--收藏
        set(CollectionsJournalTab1, '坐骑')
        set(CollectionsJournalTab2, '宠物手册')
        set(CollectionsJournalTab3, '玩具箱')
        set(CollectionsJournalTab4, '传家宝')
        set(CollectionsJournalTab5, '外观')

        hooksecurefunc('MountJournal_UpdateMountDisplay', function()--Blizzard_MountCollection.lua
            if ( MountJournal.selectedMountID ) then
                local active = select(4, C_MountJournal.GetMountInfoByID(MountJournal.selectedMountID))
                local needsFanfare = C_MountJournal.NeedsFanfare(MountJournal.selectedMountID)
                if ( needsFanfare ) then
                    MountJournal.MountButton:SetText('打开')
                elseif ( active ) then
                    MountJournal.MountButton:SetText('解散坐骑')
                else
                    MountJournal.MountButton:SetText('召唤')
                end
            end
        end)

        set(WardrobeCollectionFrameTab1, '物品')
        set(WardrobeCollectionFrameTab2, '套装')

    elseif arg1=='Blizzard_EncounterJournal' then--冒险指南
        set(EncounterJournalMonthlyActivitiesTab, '旅行者日志')
        set(EncounterJournalSuggestTab, '推荐玩法')
        set(EncounterJournalDungeonTab, '地下城')
        set(EncounterJournalRaidTab, '团队副本')
        set(EncounterJournalLootJournalTab, '套装物品')

    elseif arg1=='Blizzard_AchievementUI' then--成就
        set(AchievementFrameTab1, '成就')
        set(AchievementFrameTab2, '公会')
        set(AchievementFrameTab3, '统计')

        set(AchievementFrameSummaryAchievementsHeaderTitle, '近期成就')
        set(AchievementFrameSummaryCategoriesHeaderTitle, '进展总览')

        hooksecurefunc('AchievementFrame_RefreshView', function()--Blizzard_AchievementUI.lua
            if AchievementFrame.Header.Title:GetText()==GUILD_ACHIEVEMENTS_TITLE then
                AchievementFrame.Header.Title:SetText('公会成就')
            else
                AchievementFrame.Header.Title:SetText('成就点数')
            end
        end)


        hooksecurefunc('AchievementFrameCategories_UpdateDataProvider', function()
            for _, btn in pairs(AchievementFrameCategories.ScrollBox:GetFrames() or {}) do
                if btn.Button then
                    set(btn.Button.Label, strText[btn.Button.name])
                end
            end
        end)

    --elseif arg1=='Blizzard_Professions' then--专业
    end
end






















local function cancel_all()
    Init=function() end
    Init_Loaded= function() end
    strText={}
    panel:UnregisterEvent('ADDON_LOADED')
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_LOGOUT')
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if not e.onlyChinese then
                cancel_all()
                return
            end

            Save= WoWToolsSave[addName] or Save

            --添加控制面板
            e.AddPanel_Check({
                name= e.onlyChinese and '语言翻译' or addName,
                tooltip= '仅限中文，|cnRED_FONT_COLOR:可能会出错|r|nChinese only',
                value= not Save.disabled,
                func= function()
                    Save.disabled = not Save.disabled and true or nil
                    print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                end
            })

            if Save.disabled then
                cancel_all()
            else
               Init()
            end
        else
            Init_Loaded(arg1)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)