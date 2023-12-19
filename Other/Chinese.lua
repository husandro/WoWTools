local id, e= ...
if LOCALE_zhCN or LOCALE_zhTW then
    return
end


local addName= BUG_CATEGORY15
local Save={
    disabled= not e.Player.husandro
}
local panel= CreateFrame("Frame")

local function set(self, text)
    if self and text and not self:IsForbidden() then--CanAccessObject(self) then
        self:SetText(text)
    end
end


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
            --[AUTO_LOOT_KEY_TEXT] = "自动拾取按键",
            [LOOT_KEY_TEXT] = "拾取键",
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
                [CAMERA_SMART] = "移动时只调整水平角度",
                [CAMERA_SMARTER] = "仅在移动时",
                [CAMERA_ALWAYS] = "总是调整视角",
                [CAMERA_NEVER] = "从不调整镜头",
        [CAMERA_LABEL] = "镜头",
            [WATER_COLLISION] = "水体碰撞",
            [AUTO_FOLLOW_SPEED] = "自动跟随速度",
            [CAMERA_CTM_FOLLOWING_STYLE] = "镜头跟随模式",

    [INTERFACE_LABEL] = "界面",--Interface.lua
        [NAMES_LABEL] = "名字",
            [UNIT_NAME_OWN] = "我的名字",
            [SHOW_NPC_NAMES] = "NPC姓名",
                [NPC_NAMES_DROPDOWN_TRACKED] = "任务NPC",
                [NPC_NAMES_DROPDOWN_HOSTILE] = "敌对及任务NPC",
                [NPC_NAMES_DROPDOWN_INTERACTIVE] = "敌对、任务及可互动的NPC",
                [NPC_NAMES_DROPDOWN_ALL] = "所有NPC",
                [NPC_NAMES_DROPDOWN_NONE] = "无",
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
                [UNIT_NAMEPLATES_TYPE_1] = "重叠姓名板",
                [UNIT_NAMEPLATES_TYPE_2] = "堆叠姓名板",
        [DISPLAY_LABEL] = "显示",
            [HIDE_ADVENTURE_JOURNAL_ALERTS] = "隐藏冒险指南提示",
            [SHOW_IN_GAME_NAVIGATION] = "游戏内导航",
            [SHOW_TUTORIALS]= "教程", [RESET_TUTORIALS] = "重置教程",
            [OBJECT_NPC_OUTLINE] = "轮廓线模式",
                [OBJECT_NPC_OUTLINE_DISABLED] = "禁用",
                [OBJECT_NPC_OUTLINE_MODE_ONE] = "仅限任务目标",
                [OBJECT_NPC_OUTLINE_MODE_THREE] = "任务目标、鼠标悬停及目标",
                [OBJECT_NPC_OUTLINE_MODE_TWO] = "任务目标和鼠标悬停（默认）",
            [STATUSTEXT_LABEL] = "状态文字",
                [STATUS_TEXT_VALUE] = "数值",
                [STATUS_TEXT_PERCENT] = "百分比",
                [STATUS_TEXT_BOTH] = "同时显示",
            [CHAT_BUBBLES_TEXT] = "聊天泡泡",
                [ALL] = "全部",
                [CHAT_BUBBLES_EXCLUDE_PARTY_CHAT] = "屏蔽小队聊天",
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
                [PVP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT] = "显示生命值数值",
                [PVP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH] = "剩余生命值",
                [PVP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH] = "损失生命值",
                --[PVP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE] = "无",
                [PVP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC] = "生命值百分比",
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
        --[BINDING_NAME_TOGGLESELFHIGHLIGHT] = "开启/关闭自身高亮",
            [SELF_HIGHLIGHT_MODE_CIRCLE] = "圆环",--CombatOverrides.lua
            [SELF_HIGHLIGHT_MODE_CIRCLE_AND_OUTLINE] = "圆环&轮廓线",
            [SELF_HIGHLIGHT_MODE_OUTLINE] = "轮廓线",
            [OFF] = "禁用",

        [SELF_HIGHLIGHT_OPTION] = "团队中自身高亮",

        [SHOW_TARGET_OF_TARGET_TEXT] = "目标的目标",
        [FLASH_LOW_HEALTH_WARNING] = "生命值过低时不闪烁屏幕",
        [LOSS_OF_CONTROL] = "失控警报",
        [SHOW_COMBAT_TEXT_TEXT] = "滚动战斗记录",
        [ENABLE_MOUSEOVER_CAST] = "鼠标悬停施法",
        [AUTO_SELF_CAST_TEXT] = "自动自我施法",
            [SELF_CAST_AUTO] = "自动",
            [SELF_CAST_KEY_PRESS] = "按键",
            [SELF_CAST_AUTO_AND_KEY_PRESS] = "自动和按键",
            [AUTO_SELF_CAST_KEY_TEXT] = "自我施法",
        [FOCUS_CAST_KEY_TEXT] = "焦点施法按键",
        [SETTING_EMPOWERED_SPELL_INPUT] = "蓄力法术输入",
            [SETTING_EMPOWERED_SPELL_INPUT_HOLD_OPTION] = "按下后放开",
            [SETTING_EMPOWERED_SPELL_INPUT_TAP_OPTION] = "两次按键",
        [SPELL_ALERT_OPACITY] = "法术警报不透明度",
        [PRESS_AND_HOLD_CASTING_OPTION] = "按住施法",
        [ACTION_TARGETING_OPTION] = "开启动作瞄准",

    --社交 Social.lua
        [RESTRICT_CHAT_CONFIG_DISABLE] = "关闭聊天",
        [CENSOR_SOURCE_EXCLUDE] = "屏蔽信息",
            [CENSOR_SOURCE_EVERYONE] = "所有人",
            [CENSOR_SOURCE_EXCLUDE_FRIENDS] = "朋友外的所有人",
            [CENSOR_SOURCE_EXCLUDE_FRIENDS_AND_GUILD] = "朋友和公会成员外的所有人",
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
            [IM_STYLE] = "即时通讯风格",
            [CLASSIC_STYLE] = "经典风格",
        [WHISPER_MODE] = "新的悄悄话",
            [CONVERSATION_MODE_POPOUT] = "新标签页",
            [CONVERSATION_MODE_INLINE] = "一致模式",
            [CONVERSATION_MODE_POPOUT_AND_INLINE] = "同时",
        [TIMESTAMPS_LABEL] = "聊天时间戳",
        [RESET_CHAT_POSITION] = "重置聊天窗口位置", [RESET] = "重置",

    [PING_SYSTEM_LABEL] = "信号系统",--PingSystem.lua AudioOverrides.lua
        [ENABLE_PINGS] = "开启信号",
        [PING_MODE] = "信号模式",
            [PING_MODE_KEY_DOWN] = "快速信号",
            [PING_MODE_CLICK_DRAG] = "从容信号",
        [ENABLE_PING_SOUNDS] = "信号音效",
        [SHOW_PINGS_IN_CHAT] = "在聊天中显示信号", [PING_CHAT_SETTINGS] = "聊天设置",
        [PING_KEYBINDINGS] = "信号快捷键",

    [SETTINGS_KEYBINDINGS_LABEL] = "快捷键",

    [SETTING_GROUP_ACCESSIBILITY] = "易用性",--Accessibility.lua
    --综合
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
            [INTERACT_ICONS_SHOW_ALL] = "显示全部",
            [INTERACT_ICONS_SHOW_NONE] = "全不显示",

    [COLORBLIND_LABEL] = "色盲模式",
        [USE_COLORBLIND_MODE] = "开启色盲模式界面",
        [COLORBLIND_FILTER] = "色盲过滤器",
            [COLORBLIND_OPTION_PROTANOPIA] = "1. 红色盲模式",
            [COLORBLIND_OPTION_DEUTERANOPIA] = "2. 绿色盲模式",
            [COLORBLIND_OPTION_TRITANOPIA] = "3. 蓝色盲模式",
        [ADJUST_COLORBLIND_STRENGTH] = "调整强度",
    [TTS_LABEL] = "文本转语音",
        [ENABLE_SPEECH_TO_TEXT_TRANSCRIPTION] = "语音聊天文字转录",
        [ENABLE_TEXT_TO_SPEECH] = "大声朗读聊天文本",
        [ENABLE_REMOTE_TEXT_TO_SPEECH] = "在语音聊天中为我发言",
        [VOICE] = "语音",
    --[ACCESSIBILITY_MOUNT_LABEL] = "坐骑", Mounts.lua
        [ACCESSIBILITY_ADV_FLY_LABEL] = "动态飞行",
        [MOTION_SICKNESS_DRAGONRIDING] = "晕动症",
            [DEFAULT] = "默认",
            [MOTION_SICKNESS_CHARACTER_CENTERED] = "保持角色处于正中",
            [MOTION_SICKNESS_REDUCE_CAMERA_MOTION] = "减少镜头运动",
            [MOTION_SICKNESS_BOTH] = "保持角色居中，减少镜头运动",
            [MOTION_SICKNESS_NONE] = "允许动态镜头运动",

        [MOTION_SICKNESS_DRAGONRIDING_SPEED_EFFECTS] = "动态飞行速度效果",
            [SHAKE_INTENSITY_FULL] = "高",
            [SHAKE_INTENSITY_REDUCED] = "低",
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
    [AUDIO_LABEL] = "音频",--Audio.lua
        [ENABLE_SOUND] = "开启声效",
        [AUDIO_OUTPUT_DEVICE] = "输出设备",
        [MASTER_VOLUME] = "主音量",
        [MUSIC_VOLUME] = "音乐",
        [FX_VOLUME] = "效果",
        [AMBIENCE_VOLUME] = "环境音",
        [DIALOG_VOLUME] = "对话",
        [ENABLE_MUSIC] = "音乐",
        [ENABLE_MUSIC_LOOPING] = "音乐循环",
        [ENABLE_PET_BATTLE_MUSIC] = "宠物对战音乐",
        [ENABLE_SOUNDFX] = "声音效果",
        [ENABLE_PET_SOUNDS] = "启用宠物音效",
        [ENABLE_EMOTE_SOUNDS] = "表情音效",
        [ENABLE_DIALOG] = "对话",
        [ENABLE_ERROR_SPEECH] = "错误提示",
        [ENABLE_AMBIENCE] = "环境音效",
        [ENABLE_BGSOUND] = "背景声音",
        [ENABLE_REVERB] = "启用混响",
        [ENABLE_SOFTWARE_HRTF] = "距离过滤",
        [AUDIO_CHANNELS] = "伴音通道",
        [AUDIO_CACHE_SIZE] = "音频缓存大小",
        [VOICE_CHAT_VOLUME] = "语音聊天音量",
        [VOICE_CHAT_DUCKING_SCALE] = "语音聊天降噪",
        [VOICE_CHAT_MIC_DEVICE] = "麦克风设备",
        [VOICE_CHAT_MIC_VOLUME] = "麦克风音量",
        [VOICE_CHAT_MIC_SENSITIVITY] = "麦克风灵敏度",
        [VOICE_CHAT_TEST_MIC_DEVICE] = "测试麦克风",
        [VOICE_CHAT_MODE] = "语音聊天模式",
        [OPEN_MIC] = "自由发言",
        [PUSH_TO_TALK] = "按键发言",
        [VOICE_CHAT_MODE_KEY] = "按键发言键位",
        [PING_SYSTEM_SETTINGS] = "信号系统设置",
    [LANGUAGES_LABEL] = "语言",
        [LOCALE_TEXT_LABEL] = "文本",
        [SOUND] = "声音",
    [NETWORK_LABEL] = "网络",--Network.lua
        [OPTIMIZE_NETWORK_SPEED] = "优化网络速度",
        [USEIPV6] = "当IPv6可用时开启",
        [ADVANCED_COMBAT_LOGGING] = "高级战斗日志",








        [CHARACTER_SPECIFIC_KEYBINDINGS] = "角色专用按键设置",
            [CLICK_BIND_MODE] = "点击施法",
            [QUICK_KEYBIND_MODE] = "快速快捷键模式",

            [BINDING_HEADER_ACTIONBAR] = "动作条",
            [BINDING_HEADER_ACTIONBAR2] = "动作条2",
            [BINDING_HEADER_ACTIONBAR3] = "动作条3",
            [BINDING_HEADER_ACTIONBAR4] = "动作条4",
            [BINDING_HEADER_ACTIONBAR5] = "动作条5",
            [BINDING_HEADER_ACTIONBAR6] = "动作条6",
            [BINDING_HEADER_ACTIONBAR7] = "动作条7",
            [BINDING_HEADER_ACTIONBAR8] = "动作条8",
            [BINDING_HEADER_BLANK] = "  ",
            [BINDING_HEADER_CAMERA] = "视角",
            [BINDING_HEADER_CHAT] = "聊天",
            [BINDING_HEADER_COMMENTATOR] = "解说员",
            [BINDING_HEADER_COMMENTATORCAMERA] = "综合镜头设置",
            [BINDING_HEADER_COMMENTATORFOLLOW] = "跟随",
            [BINDING_HEADER_COMMENTATORFOLLOWSNAP] = "对焦",
            [BINDING_HEADER_COMMENTATORLOOKAT] = "追踪",
            [BINDING_HEADER_COMMENTATORMISC] = "其他",
            [BINDING_HEADER_COMMENTATORSCORING] = "打分",
            [BINDING_HEADER_DEBUG] = "调试",
            [BINDING_HEADER_INTERFACE] = "界面面板",
            [BINDING_HEADER_ITUNES_REMOTE] = "iTunes遥控",
            [BINDING_HEADER_MISC] = "其他",
            [BINDING_HEADER_MOVEMENT] = "移动按键",
            [BINDING_HEADER_MOVIE_RECORDING_SECTION] = "视频录制",
            [BINDING_HEADER_MULTIACTIONBAR] = "额外的动作条",
            [BINDING_HEADER_MULTICASTFUNCTIONS] = "萨满图腾栏功能",
            [BINDING_HEADER_OTHER] = "其他",
            [BINDING_HEADER_PING_SYSTEM] = "信号系统",
            [BINDING_HEADER_RAID_TARGET] = "队伍标记",
            [BINDING_HEADER_TARGETING] = "选中目标",
            [BINDING_HEADER_VEHICLE] = "载具控制",
            [BINDING_HEADER_VOICE_CHAT] = "语音聊天",

            [BINDING_NAME_ACTIONPAGE1] = "动作条1",
            [BINDING_NAME_ACTIONPAGE2] = "动作条2",
            [BINDING_NAME_ACTIONPAGE3] = "动作条3",
            [BINDING_NAME_ACTIONPAGE4] = "动作条4",
            [BINDING_NAME_ACTIONPAGE5] = "动作条5",
            [BINDING_NAME_ACTIONPAGE6] = "动作条6",
            [BINDING_NAME_ACTIONWINDOW1] = "移动动作条1",
            [BINDING_NAME_ACTIONWINDOW2] = "移动动作条2",
            [BINDING_NAME_ACTIONWINDOW3] = "移动动作条3",
            [BINDING_NAME_ACTIONWINDOW4] = "移动动作条4",
            [BINDING_NAME_ACTIONWINDOWDECREMENT] = "将移动动作条滑向左边",
            [BINDING_NAME_ACTIONWINDOWINCREMENT] = "将移动动作条滑向右边",
            [BINDING_NAME_ACTIONWINDOWMOVE] = "改变移动动作条位置",
            [BINDING_NAME_ALLNAMEPLATES] = "显示所有姓名板",
            [BINDING_NAME_ASSISTTARGET] = "协助目标",
            [BINDING_NAME_ATTACKTARGET] = "攻击目标",
            [BINDING_NAME_BONUSACTIONBUTTON1] = "宠物快捷键 1",
            [BINDING_NAME_BONUSACTIONBUTTON10] = "宠物快捷键 10",
            [BINDING_NAME_BONUSACTIONBUTTON2] = "宠物快捷键 2",
            [BINDING_NAME_BONUSACTIONBUTTON3] = "宠物快捷键 3",
            [BINDING_NAME_BONUSACTIONBUTTON4] = "宠物快捷键 4",
            [BINDING_NAME_BONUSACTIONBUTTON5] = "宠物快捷键 5",
            [BINDING_NAME_BONUSACTIONBUTTON6] = "宠物快捷键 6",
            [BINDING_NAME_BONUSACTIONBUTTON7] = "宠物快捷键 7",
            [BINDING_NAME_BONUSACTIONBUTTON8] = "宠物快捷键 8",
            [BINDING_NAME_BONUSACTIONBUTTON9] = "宠物快捷键 9",
            [BINDING_NAME_CAMERAZOOMIN] = "放大",
            [BINDING_NAME_CAMERAZOOMOUT] = "缩小",
            [BINDING_NAME_CENTERCAMERA] = "镜头居中",
            [BINDING_NAME_CHATBOTTOM] = "翻至对话最下端",
            [BINDING_NAME_CHATPAGEDOWN] = "对话向下翻页",
            [BINDING_NAME_CHATPAGEUP] = "对话向上翻页",
            [BINDING_NAME_CHECK_FOR_SCOREBOARD] = "生成终场计分板",
            [BINDING_NAME_COMBATLOGBOTTOM] = "战斗日志翻至最下端",
            [BINDING_NAME_COMBATLOGPAGEDOWN] = "战斗日志向下翻页",
            [BINDING_NAME_COMBATLOGPAGEUP] = "战斗日志向上翻页",
            [BINDING_NAME_COMMENTATORFOLLOW1] = "跟随队伍1的玩家1",
            [BINDING_NAME_COMMENTATORFOLLOW10] = "跟随队伍2的玩家4",
            [BINDING_NAME_COMMENTATORFOLLOW10SNAP] = "对焦队伍2的玩家4",
            [BINDING_NAME_COMMENTATORFOLLOW11] = "跟随队伍2的玩家5",
            [BINDING_NAME_COMMENTATORFOLLOW11SNAP] = "对焦队伍2的玩家5",
            [BINDING_NAME_COMMENTATORFOLLOW12] = "跟随队伍2的玩家6",
            [BINDING_NAME_COMMENTATORFOLLOW12SNAP] = "对焦队伍2的玩家6",
            [BINDING_NAME_COMMENTATORFOLLOW1SNAP] = "对焦队伍1的玩家1",
            [BINDING_NAME_COMMENTATORFOLLOW2] = "跟随队伍1的玩家2",
            [BINDING_NAME_COMMENTATORFOLLOW2SNAP] = "对焦队伍1的玩家2",
            [BINDING_NAME_COMMENTATORFOLLOW3] = "跟随队伍1的玩家3",
            [BINDING_NAME_COMMENTATORFOLLOW3SNAP] = "对焦队伍1的玩家3",
            [BINDING_NAME_COMMENTATORFOLLOW4] = "跟随队伍1的玩家4",
            [BINDING_NAME_COMMENTATORFOLLOW4SNAP] = "对焦队伍1的玩家4",
            [BINDING_NAME_COMMENTATORFOLLOW5] = "跟随队伍1的玩家5",
            [BINDING_NAME_COMMENTATORFOLLOW5SNAP] = "对焦队伍1的玩家5",
            [BINDING_NAME_COMMENTATORFOLLOW6] = "跟随队伍1的玩家6",
            [BINDING_NAME_COMMENTATORFOLLOW6SNAP] = "对焦队伍1的玩家6",
            [BINDING_NAME_COMMENTATORFOLLOW7] = "跟随队伍2的玩家1",
            [BINDING_NAME_COMMENTATORFOLLOW7SNAP] = "对焦队伍2的玩家1",
            [BINDING_NAME_COMMENTATORFOLLOW8] = "跟随队伍2的玩家2",
            [BINDING_NAME_COMMENTATORFOLLOW8SNAP] = "对焦队伍2的玩家2",
            [BINDING_NAME_COMMENTATORFOLLOW9] = "跟随队伍2的玩家3",
            [BINDING_NAME_COMMENTATORFOLLOW9SNAP] = "对焦队伍2的玩家3",
            [BINDING_NAME_COMMENTATORLOOKAT1] = "追踪队伍1的玩家1",
            [BINDING_NAME_COMMENTATORLOOKAT10] = "追踪队伍2的玩家4",
            [BINDING_NAME_COMMENTATORLOOKAT11] = "追踪队伍2的玩家5",
            [BINDING_NAME_COMMENTATORLOOKAT12] = "追踪队伍2的玩家6",
            [BINDING_NAME_COMMENTATORLOOKAT2] = "追踪队伍1的玩家2",
            [BINDING_NAME_COMMENTATORLOOKAT3] = "追踪队伍1的玩家3",
            [BINDING_NAME_COMMENTATORLOOKAT4] = "追踪队伍1的玩家4",
            [BINDING_NAME_COMMENTATORLOOKAT5] = "追踪队伍1的玩家5",
            [BINDING_NAME_COMMENTATORLOOKAT6] = "追踪队伍1的玩家6",
            [BINDING_NAME_COMMENTATORLOOKAT7] = "追踪队伍2的玩家1",
            [BINDING_NAME_COMMENTATORLOOKAT8] = "追踪队伍2的玩家2",
            [BINDING_NAME_COMMENTATORLOOKAT9] = "追踪队伍2的玩家3",
            [BINDING_NAME_COMMENTATORLOOKATNONE] = "停止跟随/追踪玩家",
            [BINDING_NAME_COMMENTATORMOVESPEEDDECREASE] = "降低镜头机速度",
            [BINDING_NAME_COMMENTATORMOVESPEEDINCREASE] = "提高镜头速度",
            [BINDING_NAME_COMMENTATORRESET] = "重置解说员",
            [BINDING_NAME_COMMENTATORRESETZOOM] = "Reset Zoom",
            [BINDING_NAME_COMMENTATORZOOMIN] = "镜头推进",
            [BINDING_NAME_COMMENTATORZOOMOUT] = "镜头拉远",
            [BINDING_NAME_CYCLEFOLLOWTRANSITONSPEED] = "循环切换速度",
            [BINDING_NAME_DISMOUNT] = "解散坐骑",
            [BINDING_NAME_EXTRAACTIONBUTTON1] = "额外快捷键1",
            [BINDING_NAME_FLIPCAMERAYAW] = "水平视角",
            [BINDING_NAME_FOCUSARENA1] = "将竞技场敌人1设为焦点",
            [BINDING_NAME_FOCUSARENA2] = "将竞技场敌人2设为焦点",
            [BINDING_NAME_FOCUSARENA3] = "将竞技场敌人3设为焦点",
            [BINDING_NAME_FOCUSARENA4] = "将竞技场敌人4设为焦点",
            [BINDING_NAME_FOCUSARENA5] = "将竞技场敌人5设为焦点",
            [BINDING_NAME_FOCUSTARGET] = "焦点目标",
            [BINDING_NAME_FOLLOWTARGET] = "跟随目标",
            [BINDING_NAME_FORCEFOLLOWTRANSITON] = "对焦以跟随目标",
            [BINDING_NAME_FRIENDNAMEPLATES] = "显示友方姓名板",
            [BINDING_NAME_INTERACTMOUSEOVER] = "与鼠标悬停处互动",
            [BINDING_NAME_INTERACTTARGET] = "与目标互动",
            [BINDING_NAME_INVERTBINDINGMODE1] = "动作条绑定模式变更",
            [BINDING_NAME_INVERTBINDINGMODE2] = "目标绑定模式变更",
            [BINDING_NAME_INVERTBINDINGMODE3] = "自定义绑定模式变更",
            [BINDING_NAME_ITEMCOMPARISONCYCLING] = "物品比较循环",
            [BINDING_NAME_ITUNES_BACKTRACK] = "iTunes上一首",
            [BINDING_NAME_ITUNES_NEXTTRACK] = "iTunes下一首",
            [BINDING_NAME_ITUNES_PLAYPAUSE] = "iTunes播放/暂停",
            [BINDING_NAME_ITUNES_VOLUMEDOWN] = "iTunes音量降低",
            [BINDING_NAME_ITUNES_VOLUMEUP] = "iTunes音量提高",
            [BINDING_NAME_JUMP] = "跳跃",
            [BINDING_NAME_MASTERVOLUMEDOWN] = "主音量缩小",
            [BINDING_NAME_MASTERVOLUMEUP] = "主音量放大",
            [BINDING_NAME_MINIMAPZOOMIN] = "放大地图",
            [BINDING_NAME_MINIMAPZOOMOUT] = "缩小地图",
            [BINDING_NAME_MOVEANDSTEER] = "移动控制",
            [BINDING_NAME_MOVEBACKWARD] = "后退",
            [BINDING_NAME_MOVEFORWARD] = "前进",
            [BINDING_NAME_MOVEVIEWIN] = "视角拉近",
            [BINDING_NAME_MOVEVIEWOUT] = "视角拉远",
            [BINDING_NAME_MOVIE_RECORDING_CANCEL] = "取消录制/压缩",
            [BINDING_NAME_MOVIE_RECORDING_COMPRESS] = "压缩视频",
            [BINDING_NAME_MOVIE_RECORDING_GUI] = "显示/隐藏用户界面",
            [BINDING_NAME_MOVIE_RECORDING_STARTSTOP] = "开始录制/停止录制",

            [BINDING_NAME_MULTICASTACTIONBUTTON1] = "大地图腾",
            [BINDING_NAME_MULTICASTACTIONBUTTON10] = "火焰图腾",
            [BINDING_NAME_MULTICASTACTIONBUTTON11] = "水图腾",
            [BINDING_NAME_MULTICASTACTIONBUTTON12] = "空气图腾",
            [BINDING_NAME_MULTICASTACTIONBUTTON2] = "火焰图腾",
            [BINDING_NAME_MULTICASTACTIONBUTTON3] = "水图腾",
            [BINDING_NAME_MULTICASTACTIONBUTTON4] = "空气图腾",
            [BINDING_NAME_MULTICASTACTIONBUTTON5] = "大地图腾",
            [BINDING_NAME_MULTICASTACTIONBUTTON6] = "火焰图腾",
            [BINDING_NAME_MULTICASTACTIONBUTTON7] = "水图腾",
            [BINDING_NAME_MULTICASTACTIONBUTTON8] = "空气图腾",
            [BINDING_NAME_MULTICASTACTIONBUTTON9] = "大地图腾",
            [BINDING_NAME_MULTICASTRECALLBUTTON1] = "收回图腾",
            [BINDING_NAME_MULTICASTSUMMONBUTTON1] = "元素的召唤",
            [BINDING_NAME_MULTICASTSUMMONBUTTON2] = "先祖的召唤",
            [BINDING_NAME_MULTICASTSUMMONBUTTON3] = "灵魂的召唤",
            [BINDING_NAME_NAMEPLATES] = "显示敌方姓名板",
            [BINDING_NAME_NEXTACTIONPAGE] = "下一动作条",
            [BINDING_NAME_NEXTVIEW] = "下一个视角",
            [BINDING_NAME_OPENALLBAGS] = "打开/关闭所有的背包",
            [BINDING_NAME_OPENCHAT] = "打开对话框",
            [BINDING_NAME_OPENCHATSLASH] = "打开带“/”的对话框",
            [BINDING_NAME_PETATTACK] = "宠物攻击",
            [BINDING_NAME_PINGASSIST] = "协助",
            [BINDING_NAME_PINGATTACK] = "攻击",
            [BINDING_NAME_PINGONMYWAY] = "正在赶来",
            [BINDING_NAME_PINGWARNING] = "警告",
            [BINDING_NAME_PITCHDECREMENT] = "减小倾角",
            [BINDING_NAME_PITCHDOWN] = "向下倾斜",
            [BINDING_NAME_PITCHINCREMENT] = "增大倾角",
            [BINDING_NAME_PITCHUP] = "向上倾斜",
            [BINDING_NAME_PREVIOUSACTIONPAGE] = "前一动作条",
            [BINDING_NAME_PREVVIEW] = "前一个视角",
            [BINDING_NAME_PUSHTOTALK] = "按键发言",
            [BINDING_NAME_RAIDTARGET1] = "为目标指定星形",
            [BINDING_NAME_RAIDTARGET2] = "为目标指定圆形",
            [BINDING_NAME_RAIDTARGET3] = "为目标指定菱形",
            [BINDING_NAME_RAIDTARGET4] = "为目标指定三角",
            [BINDING_NAME_RAIDTARGET5] = "为目标指定月亮",
            [BINDING_NAME_RAIDTARGET6] = "为目标指定方块",
            [BINDING_NAME_RAIDTARGET7] = "为目标指定十字",
            [BINDING_NAME_RAIDTARGET8] = "为目标指定骷髅",
            [BINDING_NAME_RAIDTARGETNONE] = "清除队伍标记图标",
            [BINDING_NAME_REPLY] = "回复对话",
            [BINDING_NAME_REPLY2] = "再次密语",
            [BINDING_NAME_RESETVIEW1] = "重置视角1",
            [BINDING_NAME_RESETVIEW2] = "重置视角2",
            [BINDING_NAME_RESETVIEW3] = "重置视角3",
            [BINDING_NAME_RESETVIEW4] = "重置视角4",
            [BINDING_NAME_RESETVIEW5] = "重置视角5",
            [BINDING_NAME_RESET_SCORE_COUNT] = "重置比赛分数",
            [BINDING_NAME_SAVEVIEW1] = "保存视角1",
            [BINDING_NAME_SAVEVIEW2] = "保存视角2",
            [BINDING_NAME_SAVEVIEW3] = "保存视角3",
            [BINDING_NAME_SAVEVIEW4] = "保存视角4",
            [BINDING_NAME_SAVEVIEW5] = "保存视角5",
            [BINDING_NAME_SCREENSHOT] = "截图",
            [BINDING_NAME_SETVIEW1] = "设置1号视角",
            [BINDING_NAME_SETVIEW2] = "设置2号视角",
            [BINDING_NAME_SETVIEW3] = "设置3号视角",
            [BINDING_NAME_SETVIEW4] = "设置4号视角",
            [BINDING_NAME_SETVIEW5] = "设置5号视角",
            [BINDING_NAME_SHAPESHIFTBUTTON1] = "特殊快捷键1",
            [BINDING_NAME_SHAPESHIFTBUTTON10] = "特殊快捷键10",
            [BINDING_NAME_SHAPESHIFTBUTTON2] = "特殊快捷键2",
            [BINDING_NAME_SHAPESHIFTBUTTON3] = "特殊快捷键3",
            [BINDING_NAME_SHAPESHIFTBUTTON4] = "特殊快捷键4",
            [BINDING_NAME_SHAPESHIFTBUTTON5] = "特殊快捷键5",
            [BINDING_NAME_SHAPESHIFTBUTTON6] = "特殊快捷键6",
            [BINDING_NAME_SHAPESHIFTBUTTON7] = "特殊快捷键7",
            [BINDING_NAME_SHAPESHIFTBUTTON8] = "特殊快捷键8",
            [BINDING_NAME_SHAPESHIFTBUTTON9] = "特殊快捷键9",
            [BINDING_NAME_SITORSTAND] = "坐下/下降",
            [BINDING_NAME_STARTATTACK] = "开始攻击",
            [BINDING_NAME_STARTAUTORUN] = "开始自动奔跑",
            [BINDING_NAME_STOPATTACK] = "停止攻击",
            [BINDING_NAME_STOPAUTORUN] = "停止自动奔跑",
            [BINDING_NAME_STOPCASTING] = "停止施法",
            [BINDING_NAME_STRAFELEFT] = "向左平移",
            [BINDING_NAME_STRAFERIGHT] = "向右平移",
            [BINDING_NAME_SWAPUNITFRAMES] = "交换场地",
            [BINDING_NAME_SWINGCAMERA] = "晃动镜头",
            [BINDING_NAME_SWINGCAMERAANDPLAYER] = "晃动镜头和玩家",
            [BINDING_NAME_TARGETARENA1] = "选中竞技场敌人1",
            [BINDING_NAME_TARGETARENA2] = "选中竞技场敌人2",
            [BINDING_NAME_TARGETARENA3] = "选中竞技场敌人3",
            [BINDING_NAME_TARGETARENA4] = "选中竞技场敌人4",
            [BINDING_NAME_TARGETARENA5] = "选中竞技场敌人5",
            [BINDING_NAME_TARGETENEMYDIRECTIONAL] = "锁定前方敌人",
            [BINDING_NAME_TARGETFOCUS] = "目标焦点",
            [BINDING_NAME_TARGETFRIENDDIRECTIONAL] = "锁定前方友军",
            [BINDING_NAME_TARGETLASTHOSTILE] = "选中上一个敌对目标",
            [BINDING_NAME_TARGETLASTTARGET] = "选中上一个目标",
            [BINDING_NAME_TARGETMOUSEOVER] = "选中鼠标悬停目标",
            [BINDING_NAME_TARGETNEARESTENEMY] = "选中最近的敌人",
            [BINDING_NAME_TARGETNEARESTENEMYPLAYER] = "选中最近的敌对玩家",
            [BINDING_NAME_TARGETNEARESTFRIEND] = "选中最近的盟友",
            [BINDING_NAME_TARGETNEARESTFRIENDPLAYER] = "选中最近的友方玩家",
            [BINDING_NAME_TARGETPARTYMEMBER1] = "选中队友1",
            [BINDING_NAME_TARGETPARTYMEMBER2] = "选中队友2",
            [BINDING_NAME_TARGETPARTYMEMBER3] = "选中队友3",
            [BINDING_NAME_TARGETPARTYMEMBER4] = "选中队友4",
            [BINDING_NAME_TARGETPARTYPET1] = "选中队友宠物1",
            [BINDING_NAME_TARGETPARTYPET2] = "选中队友宠物2",
            [BINDING_NAME_TARGETPARTYPET3] = "选中队友宠物3",
            [BINDING_NAME_TARGETPARTYPET4] = "选中队友宠物4",
            [BINDING_NAME_TARGETPET] = "选中宠物",
            [BINDING_NAME_TARGETPREVIOUSENEMY] = "选中前一个敌人",
            [BINDING_NAME_TARGETPREVIOUSENEMYPLAYER] = "选中上一个敌对玩家",
            [BINDING_NAME_TARGETPREVIOUSFRIEND] = "选中前一个盟友",
            [BINDING_NAME_TARGETPREVIOUSFRIENDPLAYER] = "选中上一个友方玩家",
            [BINDING_NAME_TARGETSCANENEMY] = "目标扫描敌人",
            [BINDING_NAME_TARGETSELF] = "选中自己",
            [BINDING_NAME_TARGETTALKER] = "选中当前发言者",
            [BINDING_NAME_TEAM_1_ADD_SCORE] = "为队伍1加分",
            [BINDING_NAME_TEAM_1_REMOVE_SCORE] = "为队伍1减分",
            [BINDING_NAME_TEAM_2_ADD_SCORE] = "为队伍2加分",
            [BINDING_NAME_TEAM_2_REMOVE_SCORE] = "为队伍2减分",
            [BINDING_NAME_TEXT_TO_SPEECH_STOP] = "停止文本转语音回放",
            [BINDING_NAME_TOGGLEABILITYBOOK] = "打开/关闭能力界面",
            [BINDING_NAME_TOGGLEACHIEVEMENT] = "打开/关闭成就面板",
            [BINDING_NAME_TOGGLEACTIONBARLOCK] = "打开/关闭动作条锁定",
            [BINDING_NAME_TOGGLEAUTORUN] = "打开/关闭自动奔跑",
            [BINDING_NAME_TOGGLEAUTOSELFCAST] = "打开/关闭自动自我施法",
            [BINDING_NAME_TOGGLEBACKPACK] = "打开/关闭行囊",
            [BINDING_NAME_TOGGLEBAG1] = "打开/关闭1号背包",
            [BINDING_NAME_TOGGLEBAG2] = "打开/关闭2号背包",
            [BINDING_NAME_TOGGLEBAG3] = "打开/关闭3号背包",
            [BINDING_NAME_TOGGLEBAG4] = "打开/关闭4号背包",
            [BINDING_NAME_TOGGLEBAG5] = "打开/关闭5号背包",
            [BINDING_NAME_TOGGLEBATTLEFIELDMINIMAP] = "打开/关闭区域地图开关",
            [BINDING_NAME_TOGGLEBINDINGMODE1] = "动作条绑定模式切换",
            [BINDING_NAME_TOGGLEBINDINGMODE2] = "目标绑定模式切换",
            [BINDING_NAME_TOGGLEBINDINGMODE3] = "自定义绑定模式切换",
            [BINDING_NAME_TOGGLECAMERACOLLISION] = "开启/关闭镜头碰撞",
            [BINDING_NAME_TOGGLECHANNELPULLOUT] = "打开/关闭频道拖出列表",
            [BINDING_NAME_TOGGLECHANNELS_UNUSED] = "切换频道",
            [BINDING_NAME_TOGGLECHANNELTAB] = "切换频道面板",
            [BINDING_NAME_TOGGLECHARACTER0] = "打开/关闭角色界面",
            [BINDING_NAME_TOGGLECHARACTER1] = "打开/关闭技能界面",
            [BINDING_NAME_TOGGLECHARACTER2] = "打开/关闭声望界面",
            [BINDING_NAME_TOGGLECHARACTER3] = "打开/关闭宠物面板",
            [BINDING_NAME_TOGGLECHARACTER4] = "打开/关闭PvP面板",
            [BINDING_NAME_TOGGLECHATTAB] = "打开/关闭聊天面板",
            [BINDING_NAME_TOGGLECOLLECTIONS] = "打开/关闭藏品窗口",
            [BINDING_NAME_TOGGLECOLLECTIONSHEIRLOOM] = "打开/关闭传家宝面板",
            [BINDING_NAME_TOGGLECOLLECTIONSMOUNTJOURNAL] = "打开/关闭坐骑手册",
            [BINDING_NAME_TOGGLECOLLECTIONSPETJOURNAL] = "打开/关闭宠物手册",
            [BINDING_NAME_TOGGLECOLLECTIONSTOYBOX] = "打开/关闭玩具箱",
            [BINDING_NAME_TOGGLECOLLECTIONSWARDROBE] = "显示/隐藏外观",
            [BINDING_NAME_TOGGLECOMBATLOG] = "打开/关闭战斗日志",
            [BINDING_NAME_TOGGLECOMPANIONJOURNAL] = "打开/关闭小伙伴手册",
            [BINDING_NAME_TOGGLECOREABILITIESBOOK] = "打开/关闭核心技能",
            [BINDING_NAME_TOGGLECURRENCY] = "打开/关闭货币页面",
            [BINDING_NAME_TOGGLEDUNGEONSANDRAIDS] = "打开/关闭地下城查找器",
            [BINDING_NAME_TOGGLEENCOUNTERJOURNAL] = "打开/关闭冒险指南",
            [BINDING_NAME_TOGGLEFPS] = "打开/关闭帧数显示",
            [BINDING_NAME_TOGGLEFRIENDSTAB] = "打开/关闭好友面板",
            [BINDING_NAME_TOGGLEGAMEMENU] = "打开/关闭游戏菜单",
            [BINDING_NAME_TOGGLEGARRISONLANDINGPAGE] = "打开/关闭要塞报告",
            [BINDING_NAME_TOGGLEGRAPHICSSETTINGS] = "打开/关闭画质设定",
            [BINDING_NAME_TOGGLEGROUPFINDER] = "打开/关闭队伍查找器",
            [BINDING_NAME_TOGGLEGUILDTAB] = "打开/关闭公会和社区",
            [BINDING_NAME_TOGGLEIGNORETAB] = "切换忽略面板",
            --[BINDING_NAME_TOGGLEINSCRIPTION] = "打开/关闭雕文面板",
            [BINDING_NAME_TOGGLEKEYRING] = "打开/关闭钥匙链",
            [BINDING_NAME_TOGGLELFGPARENT] = "打开/关闭地下城查找器",
            [BINDING_NAME_TOGGLELFRPARENT] = "打开/关闭其他团队",
            [BINDING_NAME_TOGGLEMINIMAP] = "打开/关闭地图",
            [BINDING_NAME_TOGGLEMINIMAPROTATION] = "打开/关闭微缩地图旋转",
            [BINDING_NAME_TOGGLEMOUNTJOURNAL] = "打开/关闭坐骑手册",
            [BINDING_NAME_TOGGLEMOUSE] = "摇杆鼠标模式",
            [BINDING_NAME_TOGGLEMUSIC] = "打开/关闭音乐",
            [BINDING_NAME_TOGGLEPETBOOK] = "打开/关闭宠物法术书",
            [BINDING_NAME_TOGGLEPETJOURNAL] = "打开/关闭宠物手册",
            [BINDING_NAME_TOGGLEPINGLISTENER] = "信号",
            [BINDING_NAME_TOGGLEPROFESSIONBOOK] = "打开/关闭专业技能书",
            [BINDING_NAME_TOGGLEPVP] = "打开/关闭PvP面板",
            [BINDING_NAME_TOGGLEQUESTLOG] = "打开/关闭任务日志",
            [BINDING_NAME_TOGGLEQUICKJOINTAB] = "开启/关闭快速加入",
            [BINDING_NAME_TOGGLERAIDFINDER] = "打开/关闭团队查找器",
            [BINDING_NAME_TOGGLERAIDTAB] = "打开/关闭团队面板",
            [BINDING_NAME_TOGGLEREAGENTBAG1] = "打开/关闭材料包",
            [BINDING_NAME_TOGGLERUN] = "跑/走",
            [BINDING_NAME_TOGGLESELFHIGHLIGHT] = "开启/关闭自身高亮",
            [BINDING_NAME_TOGGLESHEATH] = "取出/收起武器",
            [BINDING_NAME_TOGGLESMOOTHFOLLOWTRANSITIONS] = "开启/关闭平滑跟随切换",
            [BINDING_NAME_TOGGLESOCIAL] = "打开/关闭社交界面",
            [BINDING_NAME_TOGGLESOUND] = "打开/关闭声效",
            [BINDING_NAME_TOGGLESPELLBOOK] = "打开/关闭法术书",
            [BINDING_NAME_TOGGLESTATISTICS] = "打开/关闭统计数据面板",
            [BINDING_NAME_TOGGLETALENTS] = "打开/关闭天赋面板",
            [BINDING_NAME_TOGGLETEXTTOSPEECH] = "开启/关闭文字转语音选项",
            [BINDING_NAME_TOGGLETOYBOX] = "打开/关闭玩具箱",
            [BINDING_NAME_TOGGLEUI] = "打开/关闭用户界面",
            [BINDING_NAME_TOGGLEWHATHASCHANGEDBOOK] = "打开/关闭“最新改动”",
            [BINDING_NAME_TOGGLEWHOTAB] = "打开/关闭查询面板",
            [BINDING_NAME_TOGGLEWINDOWED] = "打开/关闭窗口模式",
            [BINDING_NAME_TOGGLEWORLDMAP] = "打开/关闭世界地图",
            [BINDING_NAME_TOGGLEWORLDMAPSIZE] = "切换世界地图大小",
            [BINDING_NAME_TOGGLEWORLDSTATESCORES] = "打开/关闭积分窗口",
            [BINDING_NAME_TOGGLE_CASTER_COOLDOWN_DISPLAY] = "开启/关闭施法者冷却显示",
            [BINDING_NAME_TOGGLE_FRAME_LOCK] = "开启/关闭默认用户界面",
            [BINDING_NAME_TOGGLE_NAMEPLATE_SIZE] = "切换姓名板尺寸",
            [BINDING_NAME_TOGGLE_SMART_CAMERA] = "开启/关闭智能镜头",
            [BINDING_NAME_TOGGLE_SMART_CAMERA_LOCK] = "锁定智能镜头",
            [BINDING_NAME_TOGGLE_VOICE_PUSH_TO_TALK] = "语音聊天：按键发言",
            [BINDING_NAME_TOGGLE_VOICE_SELF_DEAFEN] = "语音聊天：开启/解除自我隔音",
            [BINDING_NAME_TOGGLE_VOICE_SELF_MUTE] = "语音聊天：开启/解除自我禁音",
            [BINDING_NAME_TURNLEFT] = "左转",
            [BINDING_NAME_TURNRIGHT] = "右转",
            [BINDING_NAME_VEHICLEAIMDECREMENT] = "减小仰角",
            [BINDING_NAME_VEHICLEAIMDOWN] = "向下瞄准",
            [BINDING_NAME_VEHICLEAIMINCREMENT] = "增大仰角",
            [BINDING_NAME_VEHICLEAIMUP] = "向上瞄准",
            [BINDING_NAME_VEHICLECAMERAZOOMIN] = "镜头拉近",
            [BINDING_NAME_VEHICLECAMERAZOOMOUT] = "镜头拉远",
            [BINDING_NAME_VEHICLEEXIT] = "离开载具",
            [BINDING_NAME_VEHICLENEXTSEAT] = "后一座位",
            [BINDING_NAME_VEHICLEPREVSEAT] = "前一座位",




    [SYSTEM_DEFAULT] = "系统默认",

    [KEY1] = "按键设置1",
    [KEY2] = "按键设置2",
    [KEY_BACKSPACE] = "退格",
    [KEY_BUTTON1] = "鼠标左键",
    [KEY_BUTTON2] = "鼠标右键",
    [KEY_BUTTON3] = "鼠标中键",
    [KEY_MOUSEWHEELDOWN] = "鼠标滚轮向下滚动",
    [KEY_MOUSEWHEELUP] = "鼠标滚轮向上滚动",
    [KEY_UP] = "方向键上",
    [KEY_DOWN] = "方向键下",
    [KEY_ENTER] = "回车",
    [KEY_LEFT] = "方向键左",
    [KEY_RIGHT] = "方向键右",
    [KEY_NUMPADDECIMAL] = "数字键盘.",
    [KEY_NUMPADDIVIDE] = "数字键盘/",
    [KEY_NUMPADMINUS] = "数字键盘-",
    [KEY_NUMPADMULTIPLY] = "数字键盘*",
    [KEY_NUMPADPLUS] = "数字键盘+",
    [SHIFT_KEY] = "SHIFT键",


    [PLAYER_MESSAGES] = "玩家信息",
    [CREATURE_MESSAGES] = "怪物信息",
    [DONE_BY] = "来源为：",
    [DONE_TO] = "目标为：",
    [UNIT_COLORS] = "单位颜色：",
    [SAY] = "说",
    [EMOTE] = "表情",
    [YELL] = "大喊",
    [GUILD] = "公会",
    [GUILD_CHAT] = "公会聊天",
    [OFFICER] = "官员",
    [OFFICER_CHAT] = "官员聊天",
    [GUILD_ACHIEVEMENT] = "公会通告",
    [ACHIEVEMENT] = "成就通告",
    [WHISPER] = "悄悄话",
    [BN_WHISPER] = "战网昵称密语",
    [PARTY] = "小队",
    [PARTY_LEADER] = "小队队长",
    [RAID] = "团队",
    [RAID_LEADER] = "团队领袖",
    [RAID_WARNING] = "团队通知",
    [INSTANCE_CHAT] = "副本",
    [INSTANCE_CHAT_LEADER] = "副本向导",
    [VOICE_CHAT_TRANSCRIPTION] = "语音识别",
    [MONSTER_BOSS_EMOTE] = "首领台词",
    [RAID_BOSS_WHISPER] = "首领密语",

    [COMBAT_XP_GAIN] = "经验",
    [COMBAT_HONOR_GAIN] = "荣誉",
    [COMBAT_FACTION_CHANGE] = "声望",
    [SKILLUPS] = "技能提升",
    [ITEM_LOOT] = "物品拾取",
    [CURRENCY] = "货币",
    [MONEY_LOOT] = "金钱拾取",
    [TRADESKILLS] = "商业技能",
    [OPENING] = "正在打开",
    [PET_INFO] = "宠物信息",
    [COMBAT_MISC_INFO] = "其它信息",

    [BG_SYSTEM_ALLIANCE] = "战场联盟",
    [BG_SYSTEM_HORDE] = "战场部落",
    [BG_SYSTEM_NEUTRAL] = "战场中立",

    [SYSTEM_MESSAGES] = "系统信息",
    [ERRORS] = "错误",
    [IGNORED] = "已屏蔽",
    [CHANNEL] = "频道",
    [TARGETICONS] = "目标图标",
    [BN_INLINE_TOAST_ALERT] = "暴雪游戏服务提示",
    [PET_BATTLE_COMBAT_LOG] = "宠物对战",
    [PET_BATTLE_INFO] = "宠物对战信息",

    [COMBATLOG_FILTER_STRING_CUSTOM_UNIT] = "自定义单位",
    [COMBATLOG_FILTER_STRING_ME] = "我",
    [COMBATLOG_FILTER_STRING_MY_PET] = "宠物",
    [COMBATLOG_FILTER_STRING_FRIENDLY_UNITS] = "友方",
    [COMBATLOG_FILTER_STRING_HOSTILE_PLAYERS] = "敌方玩家",
    [COMBATLOG_FILTER_STRING_HOSTILE_UNITS] = "敌方单位",
    [COMBATLOG_FILTER_STRING_NEUTRAL_UNITS] = "中立",
    [COMBATLOG_FILTER_STRING_UNKNOWN_UNITS] = "未知",

    [MELEE] = "近战",
    [RANGED] = "远程",
    [AURAS] = "光环",
    [PERIODIC] = "周期",
    [DAMAGE] = "伤害",
    [MISSES] = "未命中",
    [BENEFICIAL] = "增益",
    [HOSTILE] = "敌对",
    [DISPELS] = "驱散",
    [ENCHANTS] = "附魔",
    [HEALS] = "治疗",
    [OTHER] = "其它",
    [SPELLS] = "法术",
    [POWER_GAINS] = "获得能量",
    [DRAINS] = "吸取",
    [INTERRUPTS] = "打断",
    [SPECIAL] = "特殊",
    [EXTRA_ATTACKS] = "额外攻击",
    [SUMMONS] = "召唤",
    [RESURRECT] = "复活",
    [BUILDING_DAMAGE] = "攻城",
    [BUILDING_HEAL] = "修理",
    [EMPOWERS] = "蓄力",
    [SPELL_CASTING] = "法术施放",
    [START] = "开始",
    [SUCCESS] = "成功",
    [FAILURES] = "失败",
    [DAMAGE_SHIELD] = "伤害护盾",
    [ENVIRONMENTAL_DAMAGE] = "环境伤害",
    [KILLS] = "杀敌",
    [DEATHS] = "死亡",
    [CHAT_MSG_MONSTER_EMOTE] = "怪物表情",
    [CHAT_MSG_MONSTER_PARTY] = "怪物小队",
    [CHAT_MSG_MONSTER_SAY] = "怪物说",
    [CHAT_MSG_MONSTER_WHISPER] = "怪物悄悄话",
    [CHAT_MSG_MONSTER_YELL] = "怪物大喊",
    [MONSTER_BOSS_WHISPER] = "首领密语",
    [CHAT_CONFIG_CHANNEL_SETTINGS_TITLE_WITH_DRAG_INSTRUCTIONS] = "频道|cff808080（拖拽可重排顺序）|r",

    [GENERAL_LABEL] = "综合",
    [COMBAT_LOG] = "战斗记录",
    [PET_BATTLE_COMBAT_LOG] = "宠物对战",
    [VOICE] = "语音",
    [TEXT_TO_SPEECH] = "文本转语音",
}




















































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

    set(PVPQueueFrameCategoryButton1, '快速比赛')
    set(PVPQueueFrameCategoryButton2, '评级')
    set(PVPQueueFrameCategoryButton3, '预创建队伍')


    set(GroupFinderFrame.groupButton1.name, '地下城查找器')
    set(GroupFinderFrame.groupButton2.name, '团队查找器')
    set(GroupFinderFrame.groupButton3.name, '预创建队伍')
    set(LFGListFrame.CategorySelection.StartGroupButton, '创建队伍')
    set(LFGListFrame.CategorySelection.FindGroupButton, '寻找队伍')


    --选项
    hooksecurefunc(SettingsPanel.Container.SettingsList.ScrollBox, 'Update', function(frame)
        if not frame:GetView() or not frame:IsVisible() then
            return
        end
        --标提
        set(SettingsPanel.Container.SettingsList.Header.Title, strText[SettingsPanel.Container.SettingsList.Header.Title:GetText()])
        for _, btn in pairs(frame:GetFrames() or {}) do
            local lable
            if btn.Button then--按钮
                lable= btn.Button.Text or btn.Button
                set(lable, strText[lable:GetText()])
            end
            if btn.DropDown then--下拉，菜单info= btn
                lable= btn.DropDown.Button.SelectionDetails.SelectionName
                set(lable, strText[lable:GetText()])
            end
            if btn.Button1 then
                set(btn.Button1, strText[btn.Button1:GetText()])
            end
            if btn.Button2 then
                set(btn.Button2, strText[btn.Button1:GetText()])
            end
            lable= btn.Text or btn.Label or btn.Title
            if lable then
                set(lable, strText[lable:GetText()])
            elseif btn.Text and btn.data and btn.data.name and strText[btn.data.name] then
                set(btn.Text, strText[btn.data.name])
                btn.data.tooltip= strText[btn.data.tooltip] or btn.data.tooltip
            end
        end
    end)

    --列表 Blizzard_CategoryList.lua
    hooksecurefunc(SettingsCategoryListButtonMixin, 'Init', function(self, initializer)--hooksecurefunc(SettingsPanel.CategoryList.ScrollBox, 'Update', function(frame)
        local category = initializer.data.category
        if category then
            set(self.Label, strText[category:GetName()])
        end
    end)
    hooksecurefunc(SettingsCategoryListHeaderMixin, 'Init', function(self, initializer)
        local text= strText[initializer.data.label]
        if text then
            self.Label:SetText(text)
        end
    end)


    --快捷键
    hooksecurefunc(KeyBindingFrameBindingTemplateMixin,'Init', function(self, initializer)
        local label= self.Text or self.Label
        local text= label and strText[label:GetText()]
        set(label, text)
    end)

    --Blizzard_SettingsPanel.lua 
    set(SettingsPanel.Container.SettingsList.Header.DefaultsButton, '默认设置')
    StaticPopupDialogs['GAME_SETTINGS_APPLY_DEFAULTS'].text= '你想要将所有用户界面和插件设置重置为默认状态，还是只重置这个界面或插件的设置？'--Blizzard_Dialogs.lua
    StaticPopupDialogs['GAME_SETTINGS_APPLY_DEFAULTS'].button1= '所有设置'
    StaticPopupDialogs['GAME_SETTINGS_APPLY_DEFAULTS'].button2= '取消'
    StaticPopupDialogs['GAME_SETTINGS_APPLY_DEFAULTS'].button3= '这些设置'
    set(SettingsPanel.GameTab.Text, '游戏')
    set(SettingsPanel.AddOnsTab.Text, '插件')
    set(SettingsPanel.NineSlice.Text, '选项')


    --[[可能会出错
    set(GameMenuFrame.Header.Text, '游戏菜单')
    set(GameMenuButtonHelpText, '帮助')
    set(GameMenuButtonStoreText, '商店')
    set(GameMenuButtonWhatsNewText, '新内容')
    set(GameMenuButtonSettingsText, '选项')
    set(GameMenuButtonEditModeText, '编辑模式')
    set(GameMenuButtonMacrosText, '宏')
    set(GameMenuButtonAddonsText, '插件')
    set(GameMenuButtonLogoutText, '登出')
    set(GameMenuButtonQuitText, '退出游戏')
        set(GameMenuButtonContinueText, '返回游戏')]]

    set(FriendsFrameTab1, '好友')
        set(FriendsFrameAddFriendButton, '添加好友')
        set(FriendsTabHeaderTab1, '好友')
        set(FriendsTabHeaderTab2, '屏蔽')
            set(FriendsFrameIgnorePlayerButton, '添加')
            set(FriendsFrameUnsquelchButton, '移除')
        set(FriendsTabHeaderTab3, '招募战友')
            set(RecruitAFriendFrame.RewardClaiming.ClaimOrViewRewardButton, '查看所有奖励')
            set(RecruitAFriendFrame.RecruitList.Header.RecruitedFriends, '已招募的战友')
            set(RecruitAFriendFrame.RecruitList.NoRecruitsDesc,  "|cffffd200招募战友后，战友每充值一个月的游戏时间，你就能获得一次奖励。|n|n若战友一次充值的游戏时间超过一个月，奖励会逐月进行发放。|n|n一起游戏还能解锁额外奖励！|r|n|n更多信息：|n|HurlIndex:49|h|cff82c5ff访问我们的战友招募网站|r|h")
            set(RecruitAFriendFrame.RecruitmentButton, '招募')
    set(FriendsFrameTab2, '查询')
        set(WhoFrameWhoButton, '刷新')
        set(WhoFrameAddFriendButton, '添加好友')
        set(WhoFrameGroupInviteButton, '组队邀请')
        set(FriendsFrameSendMessageButton, '发送信息')
    set(FriendsFrameTab3, '团队')
        set(RaidFrameRaidInfoButton, '团队信息')
        set(RaidFrameConvertToRaidButton, '转化为团队')
        set(RaidFrameRaidDescription, '团队是超过5个人的队伍，这是为了击败高等级的特定挑战而准备的大型队伍模式。\n\n|cffffffff- 团队成员无法获得非团队任务所需的物品或者杀死怪物的纪录。\n\n- 在团队中，你通过杀死怪物获得的经验值相对普通小队要少。\n\n- 团队让你可以赢得用其它方法根本无法通过的挑战。|r')
    hooksecurefunc('FriendsFrame_UpdateQuickJoinTab', function(numGroups)--FriendsFrame.lua
        set(FriendsFrameTab4, '快速加入'.. numGroups)
    end)
    hooksecurefunc(QuickJoinFrame, 'UpdateJoinButtonState', function(self)--QuickJoin.lua
        set(self.JoinQueueButton, '申请加入')
        if ( IsInGroup(LE_PARTY_CATEGORY_HOME) ) then
            self.JoinQueueButton.tooltip = '你已在一个队伍中。你必须离开队伍才能加入此队列。'
        elseif  self:GetSelectedGroup() ~= nil then
            local queues = C_SocialQueue.GetGroupQueues(self:GetSelectedGroup())
            if ( queues and queues[1] and queues[1].queueData.queueType == "lfglist" ) then
                set(self.JoinQueueButton, '申请')
            end
        end
    end)


    hooksecurefunc('FCF_SetWindowName', function(frame, name)--FloatingChatFrame.lua
        set(_G[frame:GetName().."Tab"], strText[name])
    end)
    hooksecurefunc('ChatConfig_CreateCheckboxes', function(frame, checkBoxTable, checkBoxTemplate, title)--ChatConfigFrame.lua
        if title then
            if strText[title] then
                set(_G[frame:GetName().."Title"], strText[title])
            end
        end
        local box = frame:GetName().."CheckBox"
        for index in ipairs(checkBoxTable or {}) do
            local label = _G[box..index.."CheckText"]
            if label then
                local text= label:GetText()
                if strText[text] then
                    set(label, strText[text])
                else
                    local num, name= text:match('(%d+%.)(.+)')
                    if num and name and strText[name] then
                        set(label, num..strText[name])
                    end
                end
            end
        end
    end)
    --[[CHAT_CONFIG_CHAT_LEFT[1].text='说'--ChatConfigFrame.lua
    CHAT_CONFIG_CHAT_LEFT[2].text='表情'
    CHAT_CONFIG_CHAT_LEFT[3].text='大喊'
    CHAT_CONFIG_CHAT_LEFT[4].text='公会聊天'
    CHAT_CONFIG_CHAT_LEFT[5].text='官员聊天'
    CHAT_CONFIG_CHAT_LEFT[6].text='公会通告'
    CHAT_CONFIG_CHAT_LEFT[7].text='成就通告'
    CHAT_CONFIG_CHAT_LEFT[8].text='悄悄话'
    CHAT_CONFIG_CHAT_LEFT[9].text='战网昵称密语'
    CHAT_CONFIG_CHAT_LEFT[10].text='小队'
    CHAT_CONFIG_CHAT_LEFT[11].text='小队队长'
    CHAT_CONFIG_CHAT_LEFT[12].text='团队'
    CHAT_CONFIG_CHAT_LEFT[13].text='团队领袖'
    CHAT_CONFIG_CHAT_LEFT[14].text='团队通知'
    CHAT_CONFIG_CHAT_LEFT[15].text='副本'
    CHAT_CONFIG_CHAT_LEFT[16].text='副本向导'
    if C_VoiceChat.IsTranscriptionAllowed() then
        CHAT_CONFIG_CHAT_LEFT[17].text='语音识别'
    end

    CHAT_CONFIG_CHAT_CREATURE_LEFT[1].text='说'
    CHAT_CONFIG_CHAT_CREATURE_LEFT[2].text='表情'
    CHAT_CONFIG_CHAT_CREATURE_LEFT[3].text='大喊'
    CHAT_CONFIG_CHAT_CREATURE_LEFT[4].text='怪物悄悄话'
    CHAT_CONFIG_CHAT_CREATURE_LEFT[5].text='首领台词'
    CHAT_CONFIG_CHAT_CREATURE_LEFT[6].text='首领密语'

    CHAT_CONFIG_OTHER_COMBAT[1].text='经验'
    CHAT_CONFIG_OTHER_COMBAT[2].text='荣誉'
    CHAT_CONFIG_OTHER_COMBAT[3].text='声望'
    CHAT_CONFIG_OTHER_COMBAT[4].text='技能提升'
    CHAT_CONFIG_OTHER_COMBAT[5].text='物品拾取'
    CHAT_CONFIG_OTHER_COMBAT[6].text='货币'
    CHAT_CONFIG_OTHER_COMBAT[7].text='金钱拾取'
    CHAT_CONFIG_OTHER_COMBAT[8].text='商业技能'
    CHAT_CONFIG_OTHER_COMBAT[9].text='正在打开'
    CHAT_CONFIG_OTHER_COMBAT[10].text='宠物信息'
    CHAT_CONFIG_OTHER_COMBAT[11].text='其它信息'

    CHAT_CONFIG_OTHER_PVP[1].text='战场部落'
    CHAT_CONFIG_OTHER_PVP[2].text='战场联盟'
    CHAT_CONFIG_OTHER_PVP[3].text='战场中立'

    CHAT_CONFIG_OTHER_SYSTEM[1].text='系统信息'
    CHAT_CONFIG_OTHER_SYSTEM[2].text='错误'
    CHAT_CONFIG_OTHER_SYSTEM[3].text='已屏蔽'
    CHAT_CONFIG_OTHER_SYSTEM[4].text='频道'
    CHAT_CONFIG_OTHER_SYSTEM[5].text='目标图标'
    CHAT_CONFIG_OTHER_SYSTEM[6].text='暴雪游戏服务提示'
    CHAT_CONFIG_OTHER_SYSTEM[7].text='宠物对战'
    CHAT_CONFIG_OTHER_SYSTEM[8].text='宠物对战信息'
    CHAT_CONFIG_OTHER_SYSTEM[9].text='信号'

    COMBAT_CONFIG_MESSAGESOURCES_BY[1].text= function () return ( UsesGUID("SOURCE") and '自定义单位' or '我') end
    COMBAT_CONFIG_MESSAGESOURCES_BY[2].text='宠物'
    COMBAT_CONFIG_MESSAGESOURCES_BY[3].text='友方'
    COMBAT_CONFIG_MESSAGESOURCES_BY[4].text='敌方玩家'
    COMBAT_CONFIG_MESSAGESOURCES_BY[5].text='敌方单位'
    COMBAT_CONFIG_MESSAGESOURCES_BY[6].text='中立'
    COMBAT_CONFIG_MESSAGESOURCES_BY[7].text='未知'
    
    COMBAT_CONFIG_MESSAGESOURCES_TO[1].text= function () return ( UsesGUID("DEST") and '自定义单位' or '我') end
    COMBAT_CONFIG_MESSAGESOURCES_TO[2].text='宠物'
    COMBAT_CONFIG_MESSAGESOURCES_TO[3].text='友方'
    COMBAT_CONFIG_MESSAGESOURCES_TO[4].text='敌方玩家'
    COMBAT_CONFIG_MESSAGESOURCES_TO[5].text='敌方单位'
    COMBAT_CONFIG_MESSAGESOURCES_TO[6].text='中立'
    COMBAT_CONFIG_MESSAGESOURCES_TO[7].text='未知'

    COMBAT_CONFIG_MESSAGETYPES_LEFT[1].text='近战'
        COMBAT_CONFIG_MESSAGETYPES_LEFT[1].subTypes[1].text='伤害'
        COMBAT_CONFIG_MESSAGETYPES_LEFT[1].subTypes[2].text='未命中'
    COMBAT_CONFIG_MESSAGETYPES_LEFT[2].text='远程'
        COMBAT_CONFIG_MESSAGETYPES_LEFT[2].subTypes[1].text='伤害'
        COMBAT_CONFIG_MESSAGETYPES_LEFT[2].subTypes[2].text='未命中'
    COMBAT_CONFIG_MESSAGETYPES_LEFT[3].text='光环'
        COMBAT_CONFIG_MESSAGETYPES_LEFT[3].subTypes[1].text='增益'
        COMBAT_CONFIG_MESSAGETYPES_LEFT[3].subTypes[2].text='敌对'
        COMBAT_CONFIG_MESSAGETYPES_LEFT[3].subTypes[3].text='驱散'
        COMBAT_CONFIG_MESSAGETYPES_LEFT[3].subTypes[4].text='附魔'
    COMBAT_CONFIG_MESSAGETYPES_LEFT[4].text='周期'
        COMBAT_CONFIG_MESSAGETYPES_LEFT[4].subTypes[1].text='伤害'
        COMBAT_CONFIG_MESSAGETYPES_LEFT[4].subTypes[2].text='未命中'
        COMBAT_CONFIG_MESSAGETYPES_LEFT[4].subTypes[3].text='治疗'
        COMBAT_CONFIG_MESSAGETYPES_LEFT[4].subTypes[4].text='其它'
    
    --原LUA 错误 两个5
    COMBAT_CONFIG_MESSAGETYPES_RIGHT[1].text='法术'
        for index, tab in pairs(COMBAT_CONFIG_MESSAGETYPES_RIGHT[1].subTypes) do
            if tab.text==DAMAGE then
                COMBAT_CONFIG_MESSAGETYPES_RIGHT[1].subTypes[index].text='伤害'
            elseif tab.text==MISSES then
                COMBAT_CONFIG_MESSAGETYPES_RIGHT[1].subTypes[index].text='未命中'
            elseif tab.text==HEALS then
                COMBAT_CONFIG_MESSAGETYPES_RIGHT[1].subTypes[index].text='治疗'
            elseif tab.text==POWER_GAINS then
                COMBAT_CONFIG_MESSAGETYPES_RIGHT[1].subTypes[index].text='获得能量'
            elseif tab.text==DRAINS then
                COMBAT_CONFIG_MESSAGETYPES_RIGHT[1].subTypes[index].text='吸取'
            elseif tab.text==INTERRUPTS then
                COMBAT_CONFIG_MESSAGETYPES_RIGHT[1].subTypes[index].text='打断'
            elseif tab.text==SPECIAL then
                COMBAT_CONFIG_MESSAGETYPES_RIGHT[1].subTypes[index].text='特殊'
            elseif tab.text==EXTRA_ATTACKS then
                COMBAT_CONFIG_MESSAGETYPES_RIGHT[1].subTypes[index].text='额外攻击'
            elseif tab.text==SUMMONS then
                COMBAT_CONFIG_MESSAGETYPES_RIGHT[1].subTypes[index].text='召唤'
            elseif tab.text==RESURRECT then
                COMBAT_CONFIG_MESSAGETYPES_RIGHT[1].subTypes[index].text='复活'
            elseif tab.text==BUILDING_DAMAGE then
                COMBAT_CONFIG_MESSAGETYPES_RIGHT[1].subTypes[index].text='攻城'
            elseif tab.text==BUILDING_HEAL then
                COMBAT_CONFIG_MESSAGETYPES_RIGHT[1].subTypes[index].text='修理'
            elseif tab.text==EMPOWERS then
                COMBAT_CONFIG_MESSAGETYPES_RIGHT[1].subTypes[index].text='蓄力'
            end
        end
        COMBAT_CONFIG_MESSAGETYPES_RIGHT[1].subTypes[1].text='伤害'
        COMBAT_CONFIG_MESSAGETYPES_RIGHT[1].subTypes[2].text='未命中'
        COMBAT_CONFIG_MESSAGETYPES_RIGHT[1].subTypes[3].text='治疗'
        COMBAT_CONFIG_MESSAGETYPES_RIGHT[1].subTypes[4].text='获得能量'
    COMBAT_CONFIG_MESSAGETYPES_RIGHT[2].text='法术施放'
        COMBAT_CONFIG_MESSAGETYPES_RIGHT[2].subTypes[1].text='开始'
        COMBAT_CONFIG_MESSAGETYPES_RIGHT[2].subTypes[2].text='成功'
        COMBAT_CONFIG_MESSAGETYPES_RIGHT[2].subTypes[3].text='失败'

    COMBAT_CONFIG_MESSAGETYPES_MISC[1].text='伤害护盾'
    COMBAT_CONFIG_MESSAGETYPES_MISC[2].text='环境伤害'
    COMBAT_CONFIG_MESSAGETYPES_MISC[3].text='杀敌'
    COMBAT_CONFIG_MESSAGETYPES_MISC[4].text='死亡'

    COMBAT_CONFIG_UNIT_COLORS[1].text='我'
    COMBAT_CONFIG_UNIT_COLORS[2].text='宠物'
    COMBAT_CONFIG_UNIT_COLORS[3].text='友方'
    COMBAT_CONFIG_UNIT_COLORS[4].text='敌方单位'
    COMBAT_CONFIG_UNIT_COLORS[5].text='敌方玩家'
    COMBAT_CONFIG_UNIT_COLORS[6].text='中立'
    COMBAT_CONFIG_UNIT_COLORS[7].text='未知']]
    for i=1, 7 do
        local btn=_G['ChatConfigCategoryFrameButton'..i]
        if btn then
            local text= btn:GetText()
            if text==CHAT then
                set(btn, '聊天')
            elseif text==CHANNELS then
                set(btn, '频道')
            elseif text==OTHER then
                set(btn, '其它')
            elseif text==COMBAT then
                set(btn, '战斗')
            elseif text==SETTINGS then
                set(btn, '设置')
            elseif text== UNIT_COLORS then
                set(btn, '"单位颜色：')
            elseif text== COLORIZE then
                set(btn, '彩色标记：')
            elseif text== HIGHLIGHTING then
                set(btn, '高亮显示：')
            end
        end
    end

    set(ChatConfigFrameDefaultButton, '聊天默认')
    set(ChatConfigFrameRedockButton, '重置聊天窗口位置')
    set(ChatConfigFrameOkayButton, '确定')
    set(CombatLogDefaultButton, '战斗记录默认')
    set(TextToSpeechDefaultButton, '文字转语音默认设置')

    set(ChatConfigCombatSettingsFiltersCopyFilterButton, '复制')
    set(ChatConfigCombatSettingsFiltersAddFilterButton, '添加')
    set(ChatConfigCombatSettingsFiltersDeleteButton, '删除')
    set(CombatConfigSettingsSaveButton, '保存')

    set(TextToSpeechFramePlaySampleAlternateButton, '播放样本')
    set(TextToSpeechFramePlaySampleButton, '播放样本')
    StaticPopupDialogs["TTS_CONFIRM_SAVE_SETTINGS"].text= '你想让这个角色使用已经在这台电脑上保存的文字转语音设置吗？如果你从另一台电脑上登入，此设置会保存并覆盖之前你拥有的任何设定。'
    StaticPopupDialogs["TTS_CONFIRM_SAVE_SETTINGS"].button1= '是'
    StaticPopupDialogs["TTS_CONFIRM_SAVE_SETTINGS"].button2= '取消'
    set(TextToSpeechFramePanelContainer.PlaySoundSeparatingChatLinesCheckButton.text, '每条新信息之间播放声音')
    set(TextToSpeechFramePanelContainer.PlayActivitySoundWhenNotFocusedCheckButton.text, '某个聊天窗口有活动，而且不是当前焦点窗口时，播放一个音效')
    set(TextToSpeechFramePanelContainer.AddCharacterNameToSpeechCheckButton.text, '在语音中添加<角色名说>')
    set(TextToSpeechFramePanelContainer.NarrateMyMessagesCheckButton.text, '大声朗读我自己的信息')
    set(TextToSpeechFrameTtsVoiceDropdownLabel, '语音设置"')
    set(TextToSpeechFrameTtsVoiceDropdownMoreVoicesLabel, '更多信息请查阅|cff00aaff|HurlIndex:56|h支持页面|h|r')
    set(TextToSpeechFramePanelContainerText, '使用另一个声音来朗读系统信息')
    set(TextToSpeechFrameAdjustRateSliderLabel, '调节讲话速度')
    set(TextToSpeechFrameAdjustVolumeSliderLabel, '音量')
    set(ChatConfigTextToSpeechMessageSettingsSubTitle, '对特定信息开启文字转语音')

    hooksecurefunc('TextToSpeechFrame_UpdateMessageCheckboxes', function(frame)--TextToSpeechFrame.lua
        local checkBoxNameString = frame:GetName().."CheckBox"
        for index in ipairs(frame.checkBoxTable or {}) do
            local checkBoxText = _G[checkBoxNameString..index].text
            if checkBoxText then
                set(checkBoxText, strText[checkBoxText:GetText()])
            end
        end
    end)
    set(TextToSpeechCharacterSpecificButtonText, '角色专用设置')

    hooksecurefunc('ChatConfigCategoryFrame_Refresh', function()--ChatConfigFrame.lua
        local currentChatFrame = FCF_GetCurrentChatFrame()
        if  CURRENT_CHAT_FRAME_ID == VOICE_WINDOW_ID then
            ChatConfigFrame.Header:Setup('文字转语音选项')
        else
            ChatConfigFrame.Header:Setup(currentChatFrame ~= nil and format('%s设置', strText[currentChatFrame.name] or currentChatFrame.name) or "")
        end
    end)



    set(ChannelFrameTitleText, '聊天频道')
    set(ChannelFrame.NewButton, '添加')
    set(ChannelFrame.SettingsButton, '设置')
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
        --设置，标题
        --Blizzard_Collections.lua
        hooksecurefunc('CollectionsJournal_UpdateSelectedTab', function(self)
            local selected = CollectionsJournal_GetTab(self)
            if selected==1 then
                self:SetTitle('坐骑')
            elseif selected==2 then
                self:SetTitle('宠物手册')
            elseif selected==3 then
                self:SetTitle('玩具箱')
            elseif selected==4 then
                self:SetTitle('传家宝')
            elseif selected==5 then
                self:SetTitle('外观')
            end
        end)

        set(CollectionsJournalTab1, '坐骑')
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
            set(MountJournalSummonRandomFavoriteButton.spellname, "随机召唤\n偏好坐骑")--hooksecurefunc('MountJournalSummonRandomFavoriteButton_OnLoad', function(self)
            set(MountJournal.MountDisplay.ModelScene.TogglePlayer.TogglePlayerText, '显示角色')

        set(CollectionsJournalTab2, '宠物手册')
            local function Set_Pet_Button_Name()
                local petID = PetJournalPetCard.petID
                local hasPetID = petID ~= nil
                local needsFanfare = hasPetID and C_PetJournal.PetNeedsFanfare(petID)
                if hasPetID and petID == C_PetJournal.GetSummonedPetGUID() then
                    PetJournal.SummonButton:SetText('解散')
                elseif needsFanfare then
                    PetJournal.SummonButton:SetText('打开')
                else
                    PetJournal.SummonButton:SetText('召唤')
                end
            end
            hooksecurefunc('PetJournal_UpdateSummonButtonState', Set_Pet_Button_Name)
            Set_Pet_Button_Name()

            local function set_PetJournalFindBattle()
                local queueState = C_PetBattles.GetPVPMatchmakingInfo();
                if ( queueState == "queued" or queueState == "proposal" or queueState == "suspended" ) then
                    PetJournalFindBattle:SetText('离开队列');
                else
                    PetJournalFindBattle:SetText('搜寻战斗');
                end
            end
            hooksecurefunc('PetJournalFindBattle_Update', set_PetJournalFindBattle)
            set_PetJournalFindBattle()

        set(CollectionsJournalTab3, '玩具箱')
        set(CollectionsJournalTab4, '传家宝')
        set(CollectionsJournalTab5, '外观')



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

    elseif arg1=='Blizzard_MacroUI' then
        set(MacroSaveButton, '保存')
        set(MacroCancelButton, '取消')
        set(MacroDeleteButton, '删除')
        set(MacroNewButton, '新建')
        set(MacroExitButton, '退出')
        StaticPopupDialogs["CONFIRM_DELETE_SELECTED_MACRO"].text= '确定要删除这个宏吗？'
        StaticPopupDialogs["CONFIRM_DELETE_SELECTED_MACRO"].button1= '是'
        StaticPopupDialogs["CONFIRM_DELETE_SELECTED_MACRO"].button2= '取消'

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