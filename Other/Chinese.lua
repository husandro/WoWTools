local id, e= ...
if LOCALE_zhCN or LOCALE_zhTW then
    return
end


local addName= BUG_CATEGORY15
local Save={
    disabled= not e.Player.husandro
}
local panel= CreateFrame("Frame")


local function font(lable)
    if lable then
        local fontName2, size2, fontFlag2= lable:GetFont()
        if e.onlyChinese then
            fontName2= 'Fonts\\ARHei.ttf'--黑体字
        end
        lable:SetFont(fontName2, size2, fontFlag2 or 'OUTLINE')
    end
end


local function set(self, text, affer, setFont)
    if self and text and not self:IsForbidden() and self.SetText then--CanAccessObject(self) then
        if setFont then
            font(self)
        end
        if affer then
            C_Timer.After(affer, function() self:SetText(text) end)
        else
            self:SetText(text)
        end
    elseif self and e.Player.husandro and text then
        print(self.GetName and self:GetName() or '', text)
    end
end


local function dia(string, tab)
    if StaticPopupDialogs[string] then
        for name, text in pairs(tab) do
            if StaticPopupDialogs[string][name] then
                StaticPopupDialogs[string][name]= text
            end
        end
    end
end

local function hookDia(string, text, func)
    if StaticPopupDialogs[string] and StaticPopupDialogs[string][text] then
        hooksecurefunc(StaticPopupDialogs[string], text, func)
    end
end

local function reg(self, text)
    if self and text then
        for _, region in pairs({self:GetRegions()}) do
            if region:GetObjectType()=='FontString' then
                set(region, text)
                return
            end
        end
    end
end





local function Init_Set()

e.strText={
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
    [ARENA] = "竞技场",













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
            [LOOT_KEY_TEXT] = "拾取键",
            [USE_COMBINED_BAGS_TEXT] = "组合背包",
            [ENABLE_INTERACT_TEXT] = "开启交互按键",
            [BINDING_NAME_INTERACTTARGET] = "与目标互动",
            [ENABLE_INTERACT_SOUND_OPTION] = "交互按键音效提示",
                --[ENABLE_INTERACT_SOUND_OPTION_TOOLTIP] = "你变得可以或者不可以与一个目标互动时，播放音效提示。",
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
    [NOT_BOUND] = "未设置",
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

    [DAMAGE] = "伤害",
    [MELEE] = "近战",
    [RANGED] = "远程",
    [AURAS] = "光环",
    [PERIODIC] = "周期",
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

    [HEALTH] = "生命值",
    [MANA] = "法力值",
    --[powerType, powerToken, altR, altG, altB = UnitPowerType(unit [, index])
    --_G[powerToken]
    [RAGE] = "怒气",
    [FOCUS] = "集中值",
    [ENERGY] = "能量",
    [HAPPINESS] = "快乐",
    [RUNES] = "符文",
    [RUNIC_POWER] = "符文能量",
    [SOUL_SHARDS] = "灵魂碎片",
    [ECLIPSE] = "日蚀",
    [HOLY_POWER] = "神圣能量",
    [AMMOSLOT] = "弹药",
    [FUEL] = "燃料",
    [STAGGER] = "醉拳",
    [CHI] = "真气",
    [INSANITY] = "狂乱值",
    [STAT_AVERAGE_ITEM_LEVEL] = "物品等级",
    [STAT_MOVEMENT_SPEED] = "移动速度",
    [SPELL_STAT1_NAME] = "力量",
    [SPELL_STAT2_NAME] = "敏捷",
    [SPELL_STAT3_NAME] = "耐力",
    [SPELL_STAT4_NAME] = "智力",
    [SPELL_STAT5_NAME] = "精神",
    [STAT_CRITICAL_STRIKE] = "爆击",
    [STAT_HASTE] = "急速",
    [STAT_MASTERY] = "精通",
    [STAT_VERSATILITY] = "全能",
    [STAT_LIFESTEAL] = "吸血",
    [STAT_AVOIDANCE] = "闪避",
    [STAT_SPEED] = "加速",
    [STAT_PARRY] = "招架",
    [STAT_ATTACK_POWER] = "攻击强度",
    [WEAPON_SPEED] = "攻击速度",

    [STAT_ENERGY_REGEN] = "能量值回复",
    [STAT_RUNE_REGEN] = "符文速度",

    [STAT_FOCUS_REGEN] = "集中值回复",
    [STAT_SPELLPOWER] = "法术强度",
    [MANA_REGEN] = "法力回复",
    [STAT_ARMOR] = "护甲",
    [STAT_DODGE] = "躲闪",
    [STAT_BLOCK] = "格挡",
    [STAT_STAGGER] = "醉拳",


    --[ARENA] = "竞技场",
    --[SOCIAL_QUEUE_FORMAT_ARENA_SKIRMISH] = "竞技场练习赛",
    [AUCTION_HOUSE_FILTER_DROPDOWN_CUSTOM] = "自定义",





    [GUILD_CHALLENGE_TYPE1] = "地下城",--GuildChallengeAlertFrame_SetUp
    [GUILD_CHALLENGE_TYPE2] = "团队副本",
    [GUILD_CHALLENGE_TYPE3] = "评级战场",
    [GUILD_CHALLENGE_TYPE4] = "场景战役",
    [GUILD_CHALLENGE_TYPE5] = "史诗钥石地下城",


    [GetItemClassInfo(8)] = "物品强化",
    [GetItemClassInfo(14)] = "永久物品",
    [PROFESSIONS_TRACKER_HEADER_PROFESSION]= "专业技能",

    [RAID_INFO_WORLD_BOSS] = "世界首领",
    [PLAYER_DIFFICULTY1] = "普通",
    [PLAYER_DIFFICULTY2] = "英雄",
    [PLAYER_DIFFICULTY3] = "随机团队",
    [PLAYER_DIFFICULTY4] = "弹性团队",
    [PLAYER_DIFFICULTY5] = "挑战",
    [PLAYER_DIFFICULTY6] = "史诗",
    [PLAYER_DIFFICULTY_MYTHIC_PLUS] = "史诗钥石",
    [PLAYER_DIFFICULTY_TIMEWALKER] = "时空漫游",

    --[[[ITEM_QUALITY0_DESC] = "粗糙",
    [ITEM_QUALITY1_DESC] = "普通",
    [ITEM_QUALITY2_DESC] = "优秀",
    [ITEM_QUALITY3_DESC] = "精良",
    [ITEM_QUALITY4_DESC] = "史诗",
    [ITEM_QUALITY5_DESC] = "传说",
    [ITEM_QUALITY6_DESC] = "神器",
    [ITEM_QUALITY7_DESC] = "传家宝",]]

    [THE_ALLIANCE] = PLAYER_FACTION_COLOR_ALLIANCE:WrapTextInColorCode('联盟'),
    [THE_HORDE] = PLAYER_FACTION_COLOR_HORDE:WrapTextInColorCode('部落'),

    [TANK] = "坦克",
    [HEALER] = "治疗者",
    [DAMAGER] = "伤害输出",





    [HUD_EDIT_MODE_ARCHAEOLOGY_BAR_LABEL] = "考古条",
    [HUD_EDIT_MODE_ARENA_FRAMES_LABEL] = "竞技场框体",
    [HUD_EDIT_MODE_BAGS_LABEL] = "背包",
    [HUD_EDIT_MODE_BOSS_FRAMES_LABEL] = "首领框体",
    [HUD_EDIT_MODE_BUFFS_AND_DEBUFFS_LABEL] = "增益效果和负面效果",
    [HUD_EDIT_MODE_BUFF_FRAME_LABEL] = "增益效果框",
    [HUD_EDIT_MODE_CAST_BAR_LABEL] = "施法条",
    [HUD_EDIT_MODE_CHAT_FRAME_LABEL] = "聊天框体",
    [HUD_EDIT_MODE_DEBUFF_FRAME_LABEL] = "减益效果框",
    [HUD_EDIT_MODE_DURABILITY_FRAME_LABEL] = "装备耐久度",
    [HUD_EDIT_MODE_ENCOUNTER_BAR_LABEL] = "战斗条",
    [HUD_EDIT_MODE_EXPERIENCE_BAR_LABEL] = "经验条",
    [HUD_EDIT_MODE_EXTRA_ABILITIES_LABEL] = "额外技能",
    [HUD_EDIT_MODE_FOCUS_FRAME_LABEL] = "焦点框体",
    [HUD_EDIT_MODE_HUD_TOOLTIP_LABEL] = "HUD提示信息",
    [HUD_EDIT_MODE_LOOT_FRAME_LABEL] = "拾取窗口",
    [HUD_EDIT_MODE_MICRO_MENU_LABEL] = "菜单",
    [HUD_EDIT_MODE_MINIMAP_LABEL] = "小地图",
    [HUD_EDIT_MODE_OBJECTIVE_TRACKER_LABEL] = "目标追踪栏",
    [HUD_EDIT_MODE_PARTY_FRAMES_LABEL] = "小队框体",
    [HUD_EDIT_MODE_PET_ACTION_BAR_LABEL] = "宠物条",
    [HUD_EDIT_MODE_PET_FRAME_LABEL] = "宠物框体",
    [HUD_EDIT_MODE_PLAYER_FRAME_LABEL] = "玩家框体",
    [HUD_EDIT_MODE_POSSESS_ACTION_BAR_LABEL] = "附身条",
    [HUD_EDIT_MODE_RAID_FRAMES_LABEL] = "团队框体",
    [HUD_EDIT_MODE_STANCE_BAR_LABEL] = "姿态条",
    [HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL] = "对话特写头像",
    [HUD_EDIT_MODE_TARGET_AND_FOCUS] = "目标和焦点",
    [HUD_EDIT_MODE_TARGET_FRAME_LABEL] = "目标框体",
    [HUD_EDIT_MODE_TIMER_BARS_LABEL] = "时长条",
    [HUD_EDIT_MODE_UNSAVED_CHANGES] = "你有未保存的改动",
    [HUD_EDIT_MODE_VEHICLE_LEAVE_BUTTON_LABEL] = "退出载具按钮",
    [HUD_EDIT_MODE_VEHICLE_SEAT_INDICATOR_LABEL] = "载具座位",


    [HOME] = "首页",

    [ITEM_HEROIC] = "英雄",
    [ITEM_HEROIC_EPIC] = "英雄级别史诗品质",
    [ITEM_HEROIC_QUALITY0_DESC] = "英雄粗糙",
    [ITEM_HEROIC_QUALITY1_DESC] = "英雄普通",
    [ITEM_HEROIC_QUALITY2_DESC] = "英雄优秀",
    [ITEM_HEROIC_QUALITY3_DESC] = "英雄稀有",
    [ITEM_HEROIC_QUALITY4_DESC] = "英雄史诗",
    [ITEM_HEROIC_QUALITY5_DESC] = "英雄传说",
    [ITEM_HEROIC_QUALITY6_DESC] = "英雄神器",
    [ITEM_HEROIC_QUALITY7_DESC] = "英雄传家宝",

    [ITEM_QUALITY0_DESC] = "粗糙",
    [ITEM_QUALITY1_DESC] = "普通",
    [ITEM_QUALITY2_DESC] = "优秀",
    [ITEM_QUALITY3_DESC] = "精良",
    [ITEM_QUALITY4_DESC] = "史诗",
    [ITEM_QUALITY5_DESC] = "传说",
    [ITEM_QUALITY6_DESC] = "神器",
    [ITEM_QUALITY7_DESC] = "传家宝",
}


if _G['MOTION_SICKNESS_DROPDOWN'] then
    e.strText[_G['MOTION_SICKNESS_DROPDOWN']] = "动态眩晕"
end
if _G['MOTION_SICKNESS_DRAGONRIDING_SCREEN_EFFECTS'] then
    e.strText[_G['MOTION_SICKNESS_DRAGONRIDING_SCREEN_EFFECTS']] = "动态飞行屏幕效果"
end

end














































local function Init()
        --可能会出错
        set(GameMenuFrame.Header.Text, '游戏菜单')
        set(GameMenuButtonHelp, '帮助')
        set(GameMenuButtonStore, '商店')
        set(GameMenuButtonWhatsNew, '新内容')
        set(GameMenuButtonSettings, '选项')
        set(GameMenuButtonEditMode, '编辑模式')
        set(GameMenuButtonMacros, '宏')
        set(GameMenuButtonAddons, '插件')
        set(GameMenuButtonLogout, '登出')
        set(GameMenuButtonQuit, '退出游戏')
        set(GameMenuButtonContinue, '返回游戏')

    --角色
    set(CharacterFrameTab1, '角色')
        PAPERDOLL_SIDEBARS[1].name= '角色属性'
            set(CharacterStatsPane.ItemLevelCategory.Title, '物品等级')
            set(CharacterStatsPane.AttributesCategory.Title, '属性')
            set(CharacterStatsPane.EnhancementsCategory.Title, '强化属性')
            hooksecurefunc('PaperDollFrame_SetLabelAndText', function(statFrame, label)--PaperDollFrame.lua
                local text= e.strText[label]
                if text then
                    set(statFrame.Label, format('%s：', text))
                end
            end)


        PAPERDOLL_SIDEBARS[2].name= '头衔'
        PAPERDOLL_SIDEBARS[3].name= '装备管理'
            set(PaperDollFrameEquipSetText, '装备')
            set(PaperDollFrameSaveSetText , '保存')
                set(GearManagerPopupFrame.BorderBox.EditBoxHeaderText, '输入方案名称（最多16个字符）：')
                set(GearManagerPopupFrame.BorderBox.IconSelectionText, '选择一个图标：')
                set(GearManagerPopupFrame.BorderBox.OkayButton, '确认')
                set(GearManagerPopupFrame.BorderBox.CancelButton, '取消')
    set(CharacterFrameTab2, '声望')
        set(ReputationFrameFactionLabel, '阵营')--FACTION
        set(ReputationFrameStandingLabel,  "关系")--STANDING
        set(ReputationDetailViewRenownButton, '浏览名望')--ReputationFrame.xml
        set(ReputationDetailMainScreenCheckBoxText, '显示为经验条')
        set(ReputationDetailInactiveCheckBoxText, '隐藏')
        set(ReputationDetailAtWarCheckBoxText, '交战状态')
    set(CharacterFrameTab3, '货币')
        set(TokenFramePopup.Title, '货币设置')
        set(TokenFramePopup.InactiveCheckBox.Text, '未使用')
        set(TokenFramePopup.BackpackCheckBox.Text, '在行囊上显示')














    --法术 SpellBookFrame.lua
    hooksecurefunc('SpellBookFrame_Update', function()
        set(SpellBookFrameTabButton1, '法术')
        set(SpellBookFrameTabButton2, '专业')
        set(SpellBookFrameTabButton3, '宠物')

        if SpellBookFrame.bookType== BOOKTYPE_SPELL then
            SpellBookFrame:SetTitle('法术')
        elseif SpellBookFrame.bookType== BOOKTYPE_PROFESSION then
            SpellBookFrame:SetTitle('专业')
        elseif SpellBookFrame.bookType== BOOKTYPE_PET then
            SpellBookFrame:SetTitle('宠物')
        end
    end)
    hooksecurefunc('SpellBookFrame_UpdatePages', function()
        local currentPage, maxPages = SpellBook_GetCurrentPage()
        if ( maxPages == nil or maxPages == 0 ) then
            return
        end
        SpellBookPageText:SetFormattedText('第%d页', currentPage)
    end)
























    --LFD PVEFrame.lua
    --地下城和团队副本
    GroupFinderFrame:HookScript('OnShow', function()
        PVEFrame:SetTitle('地下城和团队副本')
    end)

    set(PVEFrameTab1, '地下城和团队副本')
    set(PVEFrameTab2, 'PvP')
    set(PVEFrameTab3, '史诗钥石地下城')

    set(GroupFinderFrame.groupButton1.name, '地下城查找器')
        set(LFDQueueFrameTypeDropDownName, '类型：')
        set(LFDQueueFrameRandomScrollFrameChildFrameTitle, '')
    set(GroupFinderFrame.groupButton2.name, '团队查找器')
        set(RaidFinderQueueFrameSelectionDropDownName, '团队')
            hooksecurefunc('RaidFinderFrameFindRaidButton_Update', function()--RaidFinder.lua
                local mode = GetLFGMode(LE_LFG_CATEGORY_RF, RaidFinderQueueFrame.raid)
	            --Update the text on the button
                if ( mode == "queued" or mode == "rolecheck" or mode == "proposal" or mode == "suspended" ) then
                    set(RaidFinderFrameFindRaidButton, '离开队列')--LEAVE_QUEUE
                else
                    if ( IsInGroup() and GetNumGroupMembers() > 1 ) then
                        set(RaidFinderFrameFindRaidButton, '小队加入')--:SetText(JOIN_AS_PARTY)
                    else
                        set(RaidFinderFrameFindRaidButton, '寻找组队')--:SetText(FIND_A_GROUP)
                    end
                end
            end)
    set(GroupFinderFrame.groupButton3.name, '预创建队伍')
        set(LFGListFrame.CategorySelection.Label, '预创建队伍')
        hooksecurefunc('LFGListCategorySelection_AddButton', function(self, btnIndex, categoryID, filters)--LFGList.lua
            local baseFilters = self:GetParent().baseFilters
            local allFilters = bit.bor(baseFilters, filters)
            if ( filters ~= 0 and #C_LFGList.GetAvailableActivities(categoryID, nil, allFilters) == 0) then
                return
            end
            local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID)
            local text=LFGListUtil_GetDecoratedCategoryName(categoryInfo.name, filters, true)
            local button= self.CategoryButtons[btnIndex]
            if button and button.Label and text then
                if e.strText[text] then

                    set(button.Label, e.strText[text], nil, true)
                end
            end
        end)
        set(LFGListFrame.CategorySelection.StartGroupButton, '创建队伍')
        set(LFGListFrame.CategorySelection.FindGroupButton, '寻找队伍')
        set(LFGListFrame.CategorySelection.Label, '预创建队伍')
            set(LFGListFrame.EntryCreation.NameLabel, '名称')
            set(LFGListFrame.EntryCreation.DescriptionLabel, '详细信息')
            hooksecurefunc('LFGListEntryCreation_SetPlaystyleLabelTextFromActivityInfo', function(self, activityInfo)--LFGList.lua
                if(not activityInfo) then
                    return
                end
                local labelText
                if(activityInfo.isRatedPvpActivity) then
                    labelText = '目标'--LFG_PLAYSTYLE_LABEL_PVP
                elseif (activityInfo.isMythicPlusActivity) then
                    labelText = '目标'--LFG_PLAYSTYLE_LABEL_PVE
                else
                    labelText = '游戏风格'--LFG_PLAYSTYLE_LABEL_PVE_MYTHICZERO
                end
                set(self.PlayStyleLabel, labelText)
            end)
            set(LFGListFrame.EntryCreation.PlayStyleLabel, '目标')
            set(LFGListFrame.EntryCreation.MythicPlusRating.Label, '最低史诗钥石评分')
            set(LFGListFrame.EntryCreation.ItemLevel.Label, '最低物品等级')
            set(LFGListFrame.EntryCreation.PvpItemLevel.Label, '最低PvP物品等级')
            set(LFGListFrame.EntryCreation.VoiceChat.Label, '语音聊天')
            hooksecurefunc('LFGListEntryCreation_Select', function(self)
                local faction = UnitFactionGroup("player")
                if faction=='Alliance' then
                    set(self.CrossFactionGroup.Label, '仅限联盟')
                elseif faction=='Horde' then
                    set(self.CrossFactionGroup.Label, '仅限部落')
                end
            end)
            set(LFGListFrame.EntryCreation.PrivateGroup.Label, '个人')
            hooksecurefunc('LFGListEntryCreation_SetEditMode', function(self)--LFGList.lua
                if self.editMode then
                    set(self.ListGroupButton, '编辑完毕')
                else
                    set(self.ListGroupButton, '列出队伍')
                end
            end)
            set(LFGListFrame.ApplicationViewer.NameColumnHeader.Label, '名称', nil, true)
            set(LFGListFrame.ApplicationViewer.RoleColumnHeader.Label, '职责', nil, true)
            set(LFGListFrame.ApplicationViewer.ItemLevelColumnHeader.Label, '装等', nil, true)
            set(LFGApplicationViewerRatingColumnHeader.Label, '分数', nil, true)

            --hooksecurefunc('LFGListEntryCreation_Show', function()
    set(LFGListFrame.ApplicationViewer.AutoAcceptButton.Label, '自动邀请')
    set(LFGListFrame.ApplicationViewer.BrowseGroupsButton, '浏览队伍')
    set(LFGListFrame.ApplicationViewer.RemoveEntryButton, '移除')
    set(LFGListFrame.ApplicationViewer.EditButton, '编辑')
    set(LFGListFrame.ApplicationViewer.UnempoweredCover.Label, '你的队伍正在组建中。')
    --set(LFGListFrame.SearchPanel.SearchBox.Instructions, '')
    set(LFGListFrame.SearchPanel.FilterButton, '过滤器')
    set(LFGListFrame.SearchPanel.BackToGroupButton, '回到队伍')
    set(LFGListFrame.SearchPanel.SignUpButton, '申请')
    set(LFGListFrame.SearchPanel.BackButton, '后退')
    set(LFGListFrame.SearchPanel.ScrollBox.NoResultsFound, '未找到队伍。如果你找不到想要的队伍，可以自己创建一支。')
    set(LFGListFrame.EntryCreation.CancelButton, '后退')
    hooksecurefunc('LFDQueueFrameFindGroupButton_Update', function()--LFDFrame.lua
        local mode = GetLFGMode(LE_LFG_CATEGORY_LFD)
        if ( mode == "queued" or mode == "rolecheck" or mode == "proposal" or mode == "suspended" ) then
            set(LFDQueueFrameFindGroupButton, '离开队列')
        else
            if ( IsInGroup() and GetNumGroupMembers() > 1 ) then
                set(LFDQueueFrameFindGroupButton, '小队加入')
            else
                set(LFDQueueFrameFindGroupButton, '寻找组队')
            end
        end
    end)

    hooksecurefunc('LFDRoleCheckPopup_Update', function()
        local slots, bgQueue = GetLFGRoleUpdate()
        local isLFGList, activityID = C_LFGList.GetRoleCheckInfo()
        local displayName
        if( isLFGList ) then
            displayName = C_LFGList.GetActivityFullName(activityID)
        elseif ( bgQueue ) then
            displayName = GetLFGRoleUpdateBattlegroundInfo()
        elseif ( slots == 1 ) then
            local dungeonID, _, dungeonSubType = GetLFGRoleUpdateSlot(1)
            if ( dungeonSubType == LFG_SUBTYPEID_HEROIC ) then
                displayName = format('英雄难度：%s', select(LFG_RETURN_VALUES.name, GetLFGDungeonInfo(dungeonID)))
            else
                displayName = select(LFG_RETURN_VALUES.name, GetLFGDungeonInfo(dungeonID))
            end
        else
            displayName = '多个地下城'
        end
        displayName = displayName and NORMAL_FONT_COLOR:WrapTextInColorCode(displayName) or ""

        if ( isLFGList ) then
            LFDRoleCheckPopupDescriptionText:SetFormattedText('申请加入%s', displayName)
        else
            LFDRoleCheckPopupDescriptionText:SetFormattedText('在等待%s的队列中', displayName)
        end

        local maxLevel, isLevelReduced = C_LFGInfo.GetRoleCheckDifficultyDetails()
        if isLevelReduced then
            local canDisplayLevel = maxLevel and maxLevel < UnitEffectiveLevel("player")
            if canDisplayLevel then
                LFDRoleCheckPopupDescription.SubText:SetFormattedText(bgQueue and '等级和技能限制为小队的最低等级范围（%s）。' or '等级和技能限制为地下城的最高等级（%s）。', maxLevel)
            else
                LFDRoleCheckPopupDescription.SubText:SetText('进入战场时，等级和技能可能会受到限制。')
            end
        end
    end)


    hooksecurefunc('LFDFrame_OnEvent', function(_, event, ...)
        if ( event == "LFG_ROLE_CHECK_SHOW" ) then
            local requeue = ...
            set(LFDRoleCheckPopup.Text, requeue and '你的队友已经将你加入另一场练习赛的队列。\n\n请确认你的角色：' or '确定你的职责：')
        elseif ( event == "LFG_READY_CHECK_SHOW" ) then
            local _, readyCheckBgQueue = GetLFGReadyCheckUpdate()
            local displayName
            if ( readyCheckBgQueue ) then
                displayName = GetLFGReadyCheckUpdateBattlegroundInfo()
            else
                displayName = '未知'
            end
            set(LFDReadyCheckPopup.Text, format('你的队长将你加入|cnGREEN_FONT_COLOR:%s|r的队列。准备好了吗？', displayName))

        --[[elseif ( event == "LFG_BOOT_PROPOSAL_UPDATE" ) then
            local voteInProgress, didVote, myVote, targetName, totalVotes, bootVotes, timeLeft, reason = GetLFGBootProposal()
            if ( voteInProgress and not didVote and targetName ) then
                if (reason and reason ~= "") then
                    StaticPopupDialogs["VOTE_BOOT_PLAYER"].text = VOTE_BOOT_PLAYER
                else
                    StaticPopupDialogs["VOTE_BOOT_PLAYER"].text = VOTE_BOOT_PLAYER_NO_REASON
                end
                -- Person who started the vote voted yes, the person being voted against voted no, so weve seen this before if we have more than 2 votes.
                StaticPopup_Show("VOTE_BOOT_PLAYER", targetName, reason, totalVotes > 2 )
            else
                StaticPopup_Hide("VOTE_BOOT_PLAYER")
            end]]
        end
    end)

    hooksecurefunc('LFDQueueFrameRandomCooldownFrame_Update', function()--LFDFrame.lua
        local cooldownFrame = LFDQueueFrameCooldownFrame
        local hasDeserter = false --If we have deserter, we want to show this over the specific frame as well as the random frame.

        local deserterExpiration = GetLFGDeserterExpiration()

        local myExpireTime
        if ( deserterExpiration ) then
            myExpireTime = deserterExpiration
            hasDeserter = true
        else
            myExpireTime = GetLFGRandomCooldownExpiration()
        end


        for i = 1, GetNumSubgroupMembers() do
            --local nameLabel = _G["LFDQueueFrameCooldownFrameName"..i]
            local statusLabel = _G["LFDQueueFrameCooldownFrameStatus"..i]

            --local _, classFilename = UnitClass("party"..i)
            --local classColor = classFilename and RAID_CLASS_COLORS[classFilename] or NORMAL_FONT_COLOR
            --nameLabel:SetFormattedText("|cff%.2x%.2x%.2x%s|r", classColor.r * 255, classColor.g * 255, classColor.b * 255, GetUnitName("party"..i, true))

            if ( UnitHasLFGDeserter("party"..i) ) then
                statusLabel:SetFormattedText(RED_FONT_COLOR_CODE.."%s|r", '逃亡者')
                hasDeserter = true
            elseif ( UnitHasLFGRandomCooldown("party"..i) ) then
                statusLabel:SetFormattedText(RED_FONT_COLOR_CODE.."%s|r", '冷却中')
            else
                statusLabel:SetFormattedText(GREEN_FONT_COLOR_CODE.."%s|r", '就绪')
            end
        end
        if ( myExpireTime and GetTime() < myExpireTime ) then
            if ( deserterExpiration ) then
                cooldownFrame.description:SetText('你刚刚逃离了随机队伍，在接下来的时间内无法再度排队：')
            else
                cooldownFrame.description:SetText('你近期加入过一个随机地下城队列。\n需要过一段时间才可加入另一个，等待时间为：')
            end
        else
            if ( hasDeserter ) then
                cooldownFrame.description:SetText('你的一名队伍成员刚刚逃离了随机副本队伍，在接下来的时间内无法再度排队。')
            else
                cooldownFrame.description:SetText('的一名队友近期加入过一个随机地下城队列，暂时无法加入另一个。')
            end
        end

    end)

    --LFGList.lua
    dia("LFG_LIST_INVITING_CONVERT_TO_RAID", {text = '邀请这名玩家或队伍会将你的小队转化为团队。', button1 = '邀请', button2 = '取消'})

    hooksecurefunc('LFGDungeonReadyPopup_Update', function()--LFGFrame.lua
        local proposalExists, _, typeID, subtypeID, _, _, role, hasResponded, _, _, numMembers, _, _, _, isSilent = GetLFGProposal()
        if ( not proposalExists ) then
            return
        elseif ( isSilent ) then
            return
        end

        if ( role == "NONE" ) then
            role = "DAMAGER"
        end

        local leaveText = '离开队列'
        if ( subtypeID == LFG_SUBTYPEID_RAID or subtypeID == LFG_SUBTYPEID_FLEXRAID ) then
            LFGDungeonReadyDialog.enterButton:SetText('进入')
        elseif ( subtypeID == LFG_SUBTYPEID_SCENARIO ) then
            if ( numMembers > 1 ) then
                LFGDungeonReadyDialog.enterButton:SetText('进入')
            else
                LFGDungeonReadyDialog.enterButton:SetText('接受')
                leaveText = '取消'
            end
        else
            LFGDungeonReadyDialog.enterButton:SetText('进入')
        end
        LFGDungeonReadyDialog.leaveButton:SetText(leaveText)

        if not hasResponded then
            local LFGDungeonReadyDialog = LFGDungeonReadyDialog
            if ( typeID == TYPEID_RANDOM_DUNGEON and subtypeID ~= LFG_SUBTYPEID_SCENARIO ) then
                LFGDungeonReadyDialog.label:SetText('你的随机地下城小队已经整装待发！')
            else
                 if ( numMembers > 1 ) then
                    LFGDungeonReadyDialog.label:SetText('已经建好了一个队伍，准备前往：')
                else
                    LFGDungeonReadyDialog.label:SetText('已经建好了一个副本，准备前往：')
                end
            end
            if ( subtypeID ~= LFG_SUBTYPEID_SCENARIO and subtypeID ~= LFG_SUBTYPEID_FLEXRAID  and e.strText[_G[role]]) then
                LFGDungeonReadyDialogRoleLabel:SetText(e.strText[_G[role]])
            end
        end
    end)
    set(LFGDungeonReadyDialogYourRoleDescription, '你的职责')
    set(LFGDungeonReadyDialogRoleLabel, '治疗者')
    set(LFGDungeonReadyDialogRewardsFrameLabel, '奖励')
    set(LFGDungeonReadyStatusLabel, '就位确认')

    set(LFGDungeonReadyDialogRandomInProgressFrameStatusText, '该地下城正在进行中。')
    set(RaidFinderQueueFrameScrollFrameChildFrameRewardsLabel, '奖励')
    set(LFDQueueFrameRandomScrollFrameChildFrameRewardsLabel, '奖励')

    RaidFinderQueueFrameScrollFrameChildFrameEncounterList:HookScript('OnEnter', function(self)
        if self.dungeonID then
            local numEncounters, numCompleted = GetLFGDungeonNumEncounters(self.dungeonID)
            if ( numCompleted > 0 ) then
                GameTooltip:AddLine(' ')
                GameTooltip:AddLine(format('|cnHIGHLIGHT_FONT_COLOR:物品已经被拾取（%d/%d）', numCompleted, numEncounters))
                GameTooltip:Show()
            end
        end
    end)


    hooksecurefunc('LFGListInviteDialog_Show', function(self, resultID, kstringGroupName)
        local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID) or {}
        local activityName = C_LFGList.GetActivityFullName(searchResultInfo.activityID, nil, searchResultInfo.isWarMode)
        local _, status, _, _, role = C_LFGList.GetApplicationInfo(resultID)
        local name= kstringGroupName or searchResultInfo.name
        if e.strText[name] then
            self.GroupName:SetText(e.strText[name])
        end
        if e.strText[activityName] then
            self.ActivityName:SetText(e.strText[activityName])
        end
        role= _G[role]
        if e.strText[role] then
            self.Role:SetText(e.strText[role])
        end
        self.Label:SetText(status ~= "invited" and '你已经加入了一支队伍：' or '你收到了一支队伍的邀请：')
    end)
    set(LFGListInviteDialog.Label, '你收到了一支队伍的邀请：')
    set(LFGListInviteDialog.RoleDescription, '你的职责')
    set(LFGListInviteDialog.OfflineNotice, '有一名队伍成员处于离线状态，将无法收到邀请。')
    set(LFGListInviteDialog.AcceptButton, '接受')
    set(LFGListInviteDialog.DeclineButton, '拒绝')
    set(LFGListInviteDialog.AcknowledgeButton, '确定')

    set(LFGListCreationDescription.EditBox.Instructions, '关于你的队伍的更多细节（可选）')
    hooksecurefunc('LFGListSearchPanel_SetCategory', function(self, categoryID, filters)--LFGList.lua
        local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID) or {}
        if categoryInfo.searchPromptOverride then
            set(self.SearchBox.Instructions, e.strText[categoryInfo.searchPromptOverride])
        else
            set(self.SearchBox.Instructions,'过滤器')
        end
        local name = LFGListUtil_GetDecoratedCategoryName(categoryInfo.name, filters, false)
        set(self.CategoryName, e.strText[name])
    end)



























    --选项
    hooksecurefunc(SettingsPanel.Container.SettingsList.ScrollBox, 'Update', function(frame)
        if not frame:GetView() or not frame:IsVisible() then
            return
        end
        --标提
        set(SettingsPanel.Container.SettingsList.Header.Title, e.strText[SettingsPanel.Container.SettingsList.Header.Title:GetText()])
        for _, btn in pairs(frame:GetFrames() or {}) do
            local lable
            if btn.Button then--按钮
                lable= btn.Button.Text or btn.Button
                if lable then
                    set(lable, e.strText[lable:GetText()])
                end
            end
            if btn.DropDown and btn.DropDown.Button and btn.DropDown.Button.SelectionDetails  then--下拉，菜单info= btn
                lable= btn.DropDown.Button.SelectionDetails.SelectionName
                if lable then
                    set(lable, e.strText[lable:GetText()])
                end
            end
            if btn.Button1 then
                set(btn.Button1, e.strText[btn.Button1:GetText()])
            end
            if btn.Button2 then
                local text= btn.Button2:GetText() or ''
                local col, name= text:match('(|cff......)(.-)|r')
                name= name or text
                if name~='' then
                    name= e.strText[name]
                    if name then
                        set(btn.Button2, (col or '')..name)
                    end
                end
            end
            lable= btn.Text or btn.Label or btn.Title
            if lable then
                set(lable, e.strText[lable:GetText()])
            elseif btn.Text and btn.data and btn.data.name and e.strText[btn.data.name] then
                set(btn.Text, e.strText[btn.data.name])
                if btn.data.tooltip and e.strText[btn.data.tooltip] then
                    btn.data.tooltip= e.strText[btn.data.tooltip] or btn.data.tooltip
                end
            end
        end
    end)





    --快速快捷键模式
    --QuickKeybind.xml
    set(QuickKeybindFrame.Header.Text, '快速快捷键模式')
    set(QuickKeybindFrame.InstructionText, '你处于快速快捷键模式。将鼠标移到一个按钮上并按下你想要的按键，即可设置那个按钮的快捷键。')
    set(QuickKeybindFrame.CancelDescriptionText, '取消会使你离开快速快捷键模式。')
    --set(QuickKeybindFrameText, '')
    set(QuickKeybindFrame.OkayButton, '确定')
    set(QuickKeybindFrame.DefaultsButton, '恢复默认设置')
    set(QuickKeybindFrame.CancelButton, '取消')
    set(QuickKeybindFrame.UseCharacterBindingsButton.text, '角色专用按键设置')



    --列表 Blizzard_CategoryList.lua
    hooksecurefunc(SettingsCategoryListButtonMixin, 'Init', function(self, initializer)--hooksecurefunc(SettingsPanel.CategoryList.ScrollBox, 'Update', function(frame)
        local category = initializer.data.category
        if category then
            set(self.Label, e.strText[category:GetName()])
        end
    end)
    hooksecurefunc(SettingsCategoryListHeaderMixin, 'Init', function(self, initializer)
        local text= e.strText[initializer.data.label]
        if text then
            self.Label:SetText(text)
        end
    end)



    e.Cstr(nil, {changeFont= QuickKeybindFrame.OutputText, size=16})
    local function set_SetOutputText(self, text)
        if not text then
            return
        end
        if text==KEYBINDINGFRAME_MOUSEWHEEL_ERROR then
            set(self.OutputText, '|cnRED_FONT_COLOR:无法将鼠标滚轮的上下滚动状态绑定在动作条上|r')
        elseif text==KEY_BOUND then
            set(self.OutputText, '|cnGREEN_FONT_COLOR:按键设置成功|r')
        else
            local a, b, c= e.Magic(PRIMARY_KEY_UNBOUND_ERROR), e.Magic(KEY_UNBOUND_ERROR), e.Magic(SETTINGS_BIND_KEY_TO_COMMAND_OR_CANCEL)
            local finda, findb= text:match(a), text:match(b)
            local findc1, findc2= text:match(c)
            if finda then
                set(self.OutputText, format('|cffff0000主要动作 |cffff00ff%s|r 现在没有绑定！|r', e.strText[finda] or finda))
            elseif findb then
                set(self.OutputText, format('|cffff0000动作 |cffff00ff%s|r 现在没有绑定！|r', e.strText[findb] or findb))
            elseif findc1 and findc2 then
                set(self.OutputText, format('设置 |cnGREEN_FONT_COLOR:%s|r 的快捷键，或者按 %s 取消', e.strText[findc1] or findc1, findc2))
            end
        end
    end
    hooksecurefunc(QuickKeybindFrame, 'SetOutputText', set_SetOutputText)
    hooksecurefunc(SettingsPanel, 'SetOutputText', set_SetOutputText)

    --快捷键
    hooksecurefunc(KeyBindingFrameBindingTemplateMixin,'Init', function(self)
        local label= self.Text or self.Label
        local text= label and e.strText[label:GetText()]
        set(label, text)
    end)




    --好友
    hooksecurefunc('FriendsFrame_Update', function()
        local selectedTab = PanelTemplates_GetSelectedTab(FriendsFrame) or FRIEND_TAB_FRIENDS
        if selectedTab == FRIEND_TAB_FRIENDS then
            local selectedHeaderTab = PanelTemplates_GetSelectedTab(FriendsTabHeader) or FRIEND_HEADER_TAB_FRIENDS
            if selectedHeaderTab == FRIEND_HEADER_TAB_FRIENDS then
                FriendsFrame:SetTitle('好友名单')
            elseif selectedHeaderTab == FRIEND_HEADER_TAB_IGNORE then
                FriendsFrame:SetTitle('屏蔽列表')
            elseif selectedHeaderTab == FRIEND_HEADER_TAB_RAF then
                FriendsFrame:SetTitle('招募战友')
            end
        elseif ( selectedTab == FRIEND_TAB_WHO ) then
            FriendsFrameTitleText:SetText('名单列表')
        elseif ( selectedTab == FRIEND_TAB_RAID ) then
            FriendsFrameTitleText:SetText('团队')
        elseif ( selectedTab == FRIEND_TAB_QUICK_JOIN ) then
            FriendsFrameTitleText:SetText('快速加入')
        end
    end)

    set(FriendsFrameTab1, '好友')
        set(FriendsFrameBattlenetFrame.BroadcastFrame.UpdateButton, '更新')
        set(FriendsFrameBattlenetFrame.BroadcastFrame.CancelButton, '取消')
        set(FriendsFrameAddFriendButton, '添加好友')
            set(AddFriendEntryFrameTopTitle, '添加好友')
            set(AddFriendEntryFrameOrLabel, '或')
            hooksecurefunc('AddFriendFrame_ShowEntry', function()
                if ( BNFeaturesEnabledAndConnected() ) then
                    local _, battleTag, _, _, _, _, isRIDEnabled = BNGetInfo()
                    if ( battleTag and isRIDEnabled ) then
                        AddFriendEntryFrameLeftTitle:SetText('实名')
                        AddFriendEntryFrameLeftDescription:SetText('输入电子邮件地址\n(或战网昵称)')
                        AddFriendNameEditBoxFill:SetText('输入：电子邮件地址、战网昵称、角色名')
                    elseif ( isRIDEnabled ) then
                        AddFriendEntryFrameLeftTitle:SetText('实名')
                        AddFriendEntryFrameLeftDescription:SetText('输入电子邮件地址')
                        AddFriendNameEditBoxFill:SetText('输入：电子邮件地址、角色名')
                    elseif ( battleTag ) then
                        AddFriendEntryFrameLeftTitle:SetText('战网昵称')
                        AddFriendEntryFrameLeftDescription:SetText('输入战网昵称')
                        AddFriendNameEditBoxFill:SetText('输入：战网昵称、角色名')
                    end
                else
                    AddFriendEntryFrameLeftDescription:SetText('暴雪游戏服务不可用')
                end
            end)
            set(AddFriendEntryFrameRightDescription, '输入角色名')
            hooksecurefunc('AddFriendEntryFrame_Init', function()
                set(AddFriendEntryFrameAcceptButtonText, '添加好友')
            end)
            set(AddFriendEntryFrameCancelButtonText, '取消')
            AddFriendNameEditBox:ClearAllPoints()--移动，输入框
            AddFriendNameEditBox:SetPoint('BOTTOMLEFT', AddFriendEntryFrameAcceptButton, 'TOPLEFT', 0, 4)
            set(AddFriendInfoFrameContinueButton, '继续')

        set(FriendsTabHeaderTab1, '好友')
        set(FriendsTabHeaderTab2, '屏蔽')
            set(FriendsFrameIgnorePlayerButton, '添加')
            set(FriendsFrameUnsquelchButton, '移除')
        set(FriendsTabHeaderTab3, '招募战友')
            if RecruitAFriendFrame then
                local function set_UpdateRAFInfo(self, rafInfo)
                    if self.rafEnabled and rafInfo and #rafInfo.versions > 0 then
                        local latestRAFVersionInfo = self:GetLatestRAFVersionInfo()
                        if (latestRAFVersionInfo.numRecruits == 0) and (latestRAFVersionInfo.monthCount.lifetimeMonths == 0) then
                            self.RewardClaiming.MonthCount:SetText('招募战友即可开始！')
                        else
                            self.RewardClaiming.MonthCount:SetFormattedText('招募战友已奖励%d个月', latestRAFVersionInfo.monthCount.lifetimeMonths)
                        end
                    end
                end
                hooksecurefunc(RecruitAFriendFrame, 'UpdateRAFInfo', set_UpdateRAFInfo)
                set_UpdateRAFInfo(RecruitAFriendFrame, RecruitAFriendFrame.rafInfo)

                local function set_UpdateNextReward(self, nextReward)--C_RecruitAFriend.GetRAFInfo()
                    if nextReward then
                        if nextReward.canClaim then
                            self.RewardClaiming.EarnInfo:SetText('你获得了：')
                        elseif nextReward.monthCost > 1 then
                            self.RewardClaiming.EarnInfo:SetFormattedText('下一个奖励 (|cnGREEN_FONT_COLOR:%d|r/%d个月)：', nextReward.monthCost - nextReward.availableInMonths, nextReward.monthCost)
                        elseif nextReward.monthsRequired == 0 then
                            self.RewardClaiming.EarnInfo:SetText('第一个奖励：')
                        else
                            self.RewardClaiming.EarnInfo:SetText('下一个奖励：')
                        end

                        if not nextReward.petInfo and not nextReward.appearanceInfo and not nextReward.appearanceSetInfo and not nextReward.illusionInfo then
                            if nextReward.titleInfo then
                                local titleName = TitleUtil.GetNameFromTitleMaskID(nextReward.titleInfo.titleMaskID)
                                if titleName then
                                    self:SetNextRewardName(format('新头衔：|cnGREEN_FONT_COLOR:%s|r', titleName), nextReward.repeatableClaimCount, nextReward.rewardType)
                                end
                            else
                                self:SetNextRewardName('30天免费游戏时间', nextReward.repeatableClaimCount, nextReward.rewardType)
                            end
                        end
                    end
                end
                hooksecurefunc(RecruitAFriendFrame, 'UpdateNextReward', set_UpdateNextReward)
                if RecruitAFriendFrame.rafEnabled and RecruitAFriendFrame.rafInfo and #RecruitAFriendFrame.rafInfo.versions > 0 then
                    local latestRAFVersionInfo = RecruitAFriendFrame:GetLatestRAFVersionInfo() or {}
                    set_UpdateNextReward(RecruitAFriendFrame, latestRAFVersionInfo.nextReward)
                end

                hooksecurefunc(RecruitAFriendFrame.RewardClaiming.ClaimOrViewRewardButton, 'Update', function(self)
                    if self.haveUnclaimedReward then
                        self:SetText('获取奖励')
                    else
                        self:SetText('查看所有奖励')
                    end
                end)
                if RecruitAFriendFrame.RewardClaiming.ClaimOrViewRewardButton.haveUnclaimedReward then
                    set(RecruitAFriendFrame.RewardClaiming.ClaimOrViewRewardButton, '获取奖励')
                else
                    set(RecruitAFriendFrame.RewardClaiming.ClaimOrViewRewardButton, '查看所有奖励')
                end

                set(RecruitAFriendFrame.RecruitList.Header.RecruitedFriends, '已招募的战友')
                set(RecruitAFriendFrame.RecruitList.NoRecruitsDesc,  "|cffffd200招募战友后，战友每充值一个月的游戏时间，你就能获得一次奖励。|n|n若战友一次充值的游戏时间超过一个月，奖励会逐月进行发放。|n|n一起游戏还能解锁额外奖励！|r|n|n更多信息：|n|HurlIndex:49|h|cff82c5ff访问我们的战友招募网站|r|h")
                set(RecruitAFriendFrame.RecruitmentButton, '招募')
                RecruitAFriendFrame.RewardClaiming.NextRewardInfoButton:HookScript('OnEnter', function()
                    GameTooltip_AddNormalLine(GameTooltip, '招募好友后，当好友开始订阅时，你就能开始获得奖励。')
                    GameTooltip:Show()
                end)

                set(RecruitAFriendRewardsFrame.Title, '战友招募奖励')
                hooksecurefunc(RecruitAFriendRewardsFrame, 'UpdateDescription', function(self, selectedRAFVersionInfo)
                    self.Description:SetText((selectedRAFVersionInfo.rafVersion == self:GetRecruitAFriendFrame():GetLatestRAFVersion()) and '每名拥有可用的游戏时间的被招募者|n每30天可以为你提供一份月度奖励。' or '不能再为旧版招募活动再招募新的战友，但是旧版现有的被招募的战友还会继续提供战友招募奖励。')
                end)


                RecruitAFriendRewardsFrame.VersionInfoButton:HookScript('OnEnter', function(self)
                    local recruitAFriendFrame = self:GetRecruitAFriendFrame()
                    local selectedVersionInfo = recruitAFriendFrame:GetSelectedRAFVersionInfo()
                    local helpText = recruitAFriendFrame:IsLegacyRAFVersion(selectedVersionInfo.rafVersion) and '当前激活的旧版招募战友：|cnHIGHLIGHT_FONT_COLOR:%d|r|n尚未领取的奖励：|cnHIGHLIGHT_FONT_COLOR:%d|r' or '当前激活的招募战友：|cnHIGHLIGHT_FONT_COLOR:%d|r|n尚未领取的奖励：|cnHIGHLIGHT_FONT_COLOR:%d|r'
                    GameTooltip_AddNormalLine(GameTooltip, ' ')
                    GameTooltip_AddNormalLine(GameTooltip, helpText:format(selectedVersionInfo.numRecruits, selectedVersionInfo.numAffordableRewards))
                    GameTooltip:Show()
                end)

                set(RecruitAFriendRecruitmentFrame.Title, '招募')

                hooksecurefunc(RecruitAFriendRecruitmentFrame, 'UpdateRecruitmentInfo', function(self, recruitmentInfo, recruitsAreMaxed)
                    local maxRecruits = 0
                    local maxRecruitLinkUses = 0
                    local daysInCycle = 0
                    local rafSystemInfo = C_RecruitAFriend.GetRAFSystemInfo()
                    if rafSystemInfo then
                        maxRecruits = rafSystemInfo.maxRecruits
                        maxRecruitLinkUses = rafSystemInfo.maxRecruitmentUses
                        daysInCycle = rafSystemInfo.daysInCycle
                    end

                    if recruitmentInfo then
                        local expireDate = date("*t", recruitmentInfo.expireTime)
                        recruitmentInfo.expireDateString = FormatShortDate(expireDate.day, expireDate.month, expireDate.year)

                        set(self.Description, format('招募战友，与你一起游玩《魔兽世界》！|n你每%2$d天可以邀请%1$d个战友。', recruitmentInfo.totalUses, daysInCycle))

                        if recruitmentInfo.sourceFaction ~= "" then
                            local region= e.Get_Region(recruitmentInfo.sourceRealm)
                            local reaml= (region and region.col or '')..(recruitmentInfo.sourceRealm or '')
                            set(self.FactionAndRealm, format('我们会鼓励你的战友在%2$s服务器创建一个%1$s角色，从而加入你的冒险。', e.strText[recruitmentInfo.sourceFaction] or recruitmentInfo.sourceFaction, reaml))
                        end
                    else
                        local PLAYER_FACTION_NAME= e.Player.faction=='Alliance' and PLAYER_FACTION_COLOR_ALLIANCE:WrapTextInColorCode('联盟') or (e.Player.faction=='Horde' and PLAYER_FACTION_COLOR_HORDE:WrapTextInColorCode('部落')) or '中立'
                        set(self.Description, format('招募战友，与你一起游玩《魔兽世界》！|n你每%2$d天可以邀请%1$d个战友。', maxRecruitLinkUses, daysInCycle))
                        set(self.FactionAndRealm, format('我们会鼓励你的战友在%2$s服务器创建一个%1$s角色，从而加入你的冒险。', PLAYER_FACTION_NAME, e.Player.realm))
                    end

                    if recruitsAreMaxed then
                        set(self.InfoText1, format('"%d/%d 已招募的战友。已达到最大招募数量。', maxRecruits, maxRecruits))
                    elseif recruitmentInfo then
                        if recruitmentInfo.remainingUses > 0 then
                            set(self.InfoText1, format('此链接会在|cnGREEN_FONT_COLOR:%s|r后过期', recruitmentInfo.expireDateString))
                        else
                            set(self.InfoText1, format('你在|cnGREEN_FONT_COLOR:%s|r后即可创建一个新链接', recruitmentInfo.expireDateString))
                        end


                        local timesUsed = recruitmentInfo.totalUses - recruitmentInfo.remainingUses
                        set(self.InfoText2, format('%d/%d 名朋友已经使用了这个链接。', timesUsed, recruitmentInfo.totalUses))
                    end
                end)
            end

            hooksecurefunc(RecruitAFriendRecruitmentFrame.GenerateOrCopyLinkButton, 'Update', function(self, recruitmentInfo)
                recruitmentInfo= recruitmentInfo or self.recruitmentInfo
                if recruitmentInfo then
                    set(RecruitAFriendRecruitmentFrameText, '复制链接')
                else
                    set(RecruitAFriendRecruitmentFrameText, '创建链接')
                end
            end)

    set(FriendsFrameTab2, '查询')
        set(WhoFrameWhoButton, '刷新')
        set(WhoFrameAddFriendButton, '添加好友')
        set(WhoFrameGroupInviteButton, '组队邀请')
        set(FriendsFrameSendMessageButton, '发送信息')
    set(FriendsFrameTab3, '团队')
        set(RaidFrameAllAssistCheckButtonText, '所有|TInterface\\GroupFrame\\UI-Group-AssistantIcon:12:12:0:1|t')
        RaidFrameAllAssistCheckButton:HookScript('OnEnter', function(self)
            GameTooltip:AddLine('钩选此项可使所有团队成员都获得团队助理权限', nil, nil, nil, true)
            if ( not self:IsEnabled() ) then
                GameTooltip:AddLine('|cnRED_FONT_COLOR:只有团队领袖才能更改此项设置。', nil, nil, nil, true)
            end
            GameTooltip:Show()
        end)
        set(WhoFrameColumnHeader1, '名称')
        set(WhoFrameColumnHeader4, '职业')
        hooksecurefunc('WhoList_Update', function()
            local numWhos, totalCount = C_FriendList.GetNumWhoResults()
            local displayedText = ""
            if ( totalCount > MAX_WHOS_FROM_SERVER ) then
                displayedText = format('（显示%d）', MAX_WHOS_FROM_SERVER)
            end
            WhoFrameTotals:SetText(format('找到%d个人', totalCount).."  "..displayedText)
        end)
        set(RaidFrameRaidInfoButton, '团队信息')
            set(RaidInfoFrame.Header.Text, '团队信息')
            set(RaidInfoInstanceLabel.text, '副本')
            set(RaidInfoIDLabel.text, '锁定过期')
            hooksecurefunc('RaidInfoFrame_UpdateButtons', function()
                if RaidInfoFrame.selectedIndex then
                    if RaidInfoFrame.selectedIsInstance then
                        local _, _, _, _, locked, extended= GetSavedInstanceInfo(RaidInfoFrame.selectedIndex)
                        if extended then
                            RaidInfoExtendButton:SetText('移除副本锁定延长')
                        else
                            RaidInfoExtendButton:SetText(locked and '延长副本锁定' or '重新激活副本锁定')
                        end
                    else
                        RaidInfoExtendButton:SetText('延长副本锁定')
                    end
                else
                    RaidInfoExtendButton:SetText('延长副本锁定')
                end
            end)
            hooksecurefunc('RaidInfoFrame_InitButton', function(button, elementData)--RaidFrame.lua
                local function InitButton(extended, locked, name, difficulty)
                    if extended or locked then
                        if e.strText[name] then
                            set(button.name, e.strText[name])
                        end
                    else
                        button.reset:SetFormattedText("|cff808080%s|r", '已过期')
                        if e.strText[name] then
                            button.name:SetFormattedText("|cff808080%s|r", e.strText[name])
                        end
                    end
                    if e.strText[difficulty] then
                        button.difficulty:SetText(e.strText[difficulty])
                    end
                    if button.extended:IsShown() then
                        set(button.extended, '|cff00ff00已延长|r')
                    end
                end

                local index = elementData.index
                if elementData.isInstance then
                    local name, _, _, _, locked, extended, _, _, _, difficultyName = GetSavedInstanceInfo(index)
                    InitButton(extended, locked, name, difficultyName)
                else
                    local name = GetSavedWorldBossInfo(index)
                    local locked = true
                    local extended = false
                    InitButton(extended, locked, name, RAID_INFO_WORLD_BOSS)
                end
            end)
            hooksecurefunc('RaidFrame_OnShow', function(self)
                self:GetParent():GetTitleText():SetText('团队')
            end)
            set(RaidInfoCancelButton, '关闭')

        set(RaidFrameConvertToRaidButton, '转化为团队')
        set(RaidFrameRaidDescription, '团队是超过5个人的队伍，这是为了击败高等级的特定挑战而准备的大型队伍模式。\n\n|cffffffff- 团队成员无法获得非团队任务所需的物品或者杀死怪物的纪录。\n\n- 在团队中，你通过杀死怪物获得的经验值相对普通小队要少。\n\n- 团队让你可以赢得用其它方法根本无法通过的挑战。|r')
    hooksecurefunc('FriendsFrame_UpdateQuickJoinTab', function(numGroups)--FriendsFrame.lua
        if numGroups then
            set(FriendsFrameTab4, '快速加入'.. (numGroups>0 and '|cnGREEN_FONT_COLOR:' or '')..numGroups)
        end
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
        set(_G[frame:GetName().."Tab"], e.strText[name])
    end)
    hooksecurefunc('ChatConfig_CreateCheckboxes', function(frame, checkBoxTable, checkBoxTemplate, title)--ChatConfigFrame.lua
        if title then
            if e.strText[title] then
                set(_G[frame:GetName().."Title"], e.strText[title])
            end
        end
        local box = frame:GetName().."CheckBox"
        for index in ipairs(checkBoxTable or {}) do
            local label = _G[box..index.."CheckText"]
            if label then
                local text= label:GetText()
                if e.strText[text] then
                    set(label, e.strText[text])
                else
                    local num, name= text:match('(%d+%.)(.+)')
                    if num and name and e.strText[name] then
                        set(label, num..e.strText[name])
                    end
                end
            end
        end
    end)

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
                set(checkBoxText, e.strText[checkBoxText:GetText()])
            end
        end
    end)
    set(TextToSpeechCharacterSpecificButtonText, '角色专用设置')

    hooksecurefunc('ChatConfigCategoryFrame_Refresh', function()--ChatConfigFrame.lua
        local currentChatFrame = FCF_GetCurrentChatFrame()
        if  CURRENT_CHAT_FRAME_ID == VOICE_WINDOW_ID then
            ChatConfigFrame.Header:Setup('文字转语音选项')
        else
            ChatConfigFrame.Header:Setup(currentChatFrame ~= nil and format('%s设置', e.strText[currentChatFrame.name] or currentChatFrame.name) or "")
        end
    end)



    set(ChannelFrameTitleText, '聊天频道')
    set(ChannelFrame.NewButton, '添加')
    set(ChannelFrame.SettingsButton, '设置')
    set(CreateChannelPopup.UseVoiceChat.Text, '启用语音聊天')
    set(CreateChannelPopup.Header.Text, '新建频道')
    set(CreateChannelPopup.Name.Label, '频道名称')
    set(CreateChannelPopup.Password.Label, '密码')
    set(CreateChannelPopup.OKButton, '确定')
    set(CreateChannelPopup.CancelButton, '取消')

    hooksecurefunc(ObjectiveTrackerBlocksFrame.QuestHeader, 'UpdateHeader', function(self)
        --if C_QuestSession.HasJoined() then self.Text:SetText('任务场景')
        self.Text:SetText('任务')
    end)

    C_Timer.After(2, function()
        set(ObjectiveTrackerFrame.HeaderMenu.Title, '追踪')
        set(ObjectiveTrackerBlocksFrame.CampaignQuestHeader.Text, '战役')
        set(ObjectiveTrackerBlocksFrame.ProfessionHeader.Text, '专业')
        set(ObjectiveTrackerBlocksFrame.MonthlyActivitiesHeader.Text, '旅行者日志')
        set(ObjectiveTrackerBlocksFrame.AchievementHeader.Text, '成就')
        --set(ObjectiveTrackerBlocksFrame.QuestHeader.Text, '任务')
    end)

    --银行
    --BankFrame.lua
    set(BankFrameTab1.Text, '银行')
    set(BankFrameTab2.Text, '材料')
    BANK_PANELS[2].SetTitle=function() BankFrame:SetTitle('材料银行') end
    if ReagentBankFrame.DespositButton:GetText()~='' then
        set(ReagentBankFrame.DespositButton, '存放各种材料')
    end

    --商人
    set(MerchantFrameTab1, '商人')
    set(MerchantFrameTab2, '购回')
    set(MerchantPageText, '')
    hooksecurefunc('MerchantFrame_UpdateBuybackInfo', function ()
        MerchantFrame:SetTitle('从商人处购回')
    end)
    hooksecurefunc('MerchantFrame_UpdateMerchantInfo', function()
        MerchantPageText:SetFormattedText('页数 %s/%s', MerchantFrame.page, math.ceil(GetMerchantNumItems() / MERCHANT_ITEMS_PER_PAGE))
    end)

    --就绪
    --ReadyCheck.lua
    set(ReadyCheckListenerFrame.TitleContainer.TitleText, '就位确认')
    set(ReadyCheckFrameYesButton, '就绪')--:SetText(GetText("READY", UnitSex("player")))
	set(ReadyCheckFrameNoButton, '未就绪')--:SetText(GetText("NOT_READY", UnitSex("player")))
    hooksecurefunc('ShowReadyCheck', function(initiator)
        if ReadyCheckListenerFrame:IsShown() then
            local _, _, difficultyID = GetInstanceInfo()
            if ( not difficultyID or difficultyID == 0 ) then
                if (UnitInRaid("player")) then-- not in an instance, go by current difficulty setting
                    difficultyID = GetRaidDifficultyID()
                else
                    difficultyID = GetDungeonDifficultyID()
                end
            end
            local difficultyName, _, _, _, _, _, toggleDifficultyID = GetDifficultyInfo(difficultyID)
            local name= e.GetPlayerInfo({name= initiator, reName=true})
            name= name~='' and name or initiator
            if ( toggleDifficultyID and toggleDifficultyID > 0 ) then
                -- the current difficulty might change while inside an instance so show the difficulty on the ready check
                difficultyName=  e.GetDifficultyColor(nil, difficultyID) or difficultyName
                ReadyCheckFrameText:SetFormattedText("%s正在进行就位确认。\n团队副本难度: |cnGREEN_FONT_COLOR:"..difficultyName..'|r', name)
            else
                ReadyCheckFrameText:SetFormattedText('%s正在进行就位确认。', name)
            end
           -- ReadyCheckListenerFrame:Show()
        end
    end)

    --插件
    set(AddonListTitleText, '插件列表')
    set(AddonListForceLoad, '加载过期插件')
    reg(AddonListForceLoad, '加载过期插件')

    set(AddonListEnableAllButton, '全部启用')
    set(AddonListDisableAllButton, '全部禁用')
    hooksecurefunc('AddonList_Update', function()--AddonList.lua
        if ( not InGlue() ) then
            if ( AddonList_HasAnyChanged() ) then
                set(AddonListOkayButton, '重新加载UI')
            else
                set(AddonListOkayButton, '确定')
            end
        end
    end)
    set(AddonListCancelButton, '取消')

    --拾取
    set(GroupLootHistoryFrameTitleText, '战利品掷骰')

    --邮箱 MailFrame.lua
    --MailFrame:HookScript('OnShow', function(self)
    set(InboxTooMuchMailText, '你的收件箱已满。')
    set(MailFrameTrialError, '你需要升级你的账号才能开启这项功能。')

    hooksecurefunc('MailFrameTab_OnClick', function(self, tabID)
        tabID = tabID or self:GetID()
        if tabID == 1  then
            MailFrame:SetTitle('收件箱')
        elseif tabID==2 then
            MailFrame:SetTitle('发件箱')
        end
    end)
    set(MailFrameTab1, '收件箱')
        set(OpenAllMail, '全部打开')
        hooksecurefunc(OpenAllMail,'StartOpening', function(self)
            set(self, '正在打开……')
        end)
        hooksecurefunc(OpenAllMail,'StopOpening', function(self)
            set(self, '全部打开')
        end)
        hooksecurefunc('InboxFrame_Update', function()
            local numItems = GetInboxNumItems()
            local index = ((InboxFrame.pageNum - 1) * INBOXITEMS_TO_DISPLAY) + 1
            for i=1, INBOXITEMS_TO_DISPLAY do
                if ( index <= numItems ) then
                    local daysLeft = select(7, GetInboxHeaderInfo(index))
                    if ( daysLeft >= 1 ) then
                        daysLeft = GREEN_FONT_COLOR_CODE..format('%d|4天:天', floor(daysLeft)).." "..FONT_COLOR_CODE_CLOSE
                    else
                        daysLeft = RED_FONT_COLOR_CODE..SecondsToTime(floor(daysLeft * 24 * 60 * 60))..FONT_COLOR_CODE_CLOSE
                    end
                    local expireTime= _G["MailItem"..i.."ExpireTime"]
                    if expireTime then
                        set(expireTime, daysLeft)
                        if ( InboxItemCanDelete(index) ) then
                            expireTime.tooltip = '信息保留时间'
                        else
                            expireTime.tooltip = '信息退回时间'
                        end
                    end
                end
                index = index + 1
            end
        end)


    set(MailFrameTab2, '发件箱')
        set(SendMailMailButton, '发送')
        set(SendMailCancelButton, '取消')
        hooksecurefunc('SendMailRadioButton_OnClick', function(index)--MailFrame.lua
            if ( index == 1 ) then
                SendMailMoneyText:SetText('|cnRED_FONT_COLOR:寄送金额：')
            else
                SendMailMoneyText:SetText('|cnGREEN_FONT_COLOR:付款取信邮件的金额')
            end
        end)
        set(SendMailSendMoneyButtonText, '|cnRED_FONT_COLOR:发送钱币')
        set(SendMailCODButtonText, '|cnGREEN_FONT_COLOR:付款取信')
        hooksecurefunc('SendMailAttachment_OnEnter', function(self)
            local index = self:GetID()
            if ( not HasSendMailItem(index) ) then
                GameTooltip:SetText('将物品放在这里随邮件发送', 1.0, 1.0, 1.0)
            end
        end)


        set(OpenMailSenderLabel, '来自：')
        set(OpenMailSubjectLabel, '主题：')
        hooksecurefunc('OpenMail_Update', function()
            if not InboxFrame.openMailID then
                return
            end
            local _, _, _, _, isInvoice, isConsortium = GetInboxText(InboxFrame.openMailID)
            if ( isInvoice ) then
                local invoiceType, itemName, playerName, _, _, _, _, _, etaHour, etaMin, count, commerceAuction = GetInboxInvoiceInfo(InboxFrame.openMailID)
                if ( invoiceType ) then
                    if ( playerName == nil ) then
                        playerName = (invoiceType == "buyer") and '多个卖家' or '多个买家'
                    end
                    local multipleSale = count and count > 1
                    if ( multipleSale ) then
                        itemName = format(AUCTION_MAIL_ITEM_STACK, itemName, count)
                    end
                    OpenMailInvoicePurchaser:SetShown(not commerceAuction)
                    if ( invoiceType == "buyer" ) then
                        OpenMailInvoicePurchaser:SetText("销售者： "..playerName)
                        OpenMailInvoiceAmountReceived:SetText('|cnRED_FONT_COLOR:付费金额：')
                    elseif (invoiceType == "seller") then
                        OpenMailInvoiceItemLabel:SetText("物品售出： "..itemName)
                        OpenMailInvoicePurchaser:SetText("购买者： "..playerName)
                        OpenMailInvoiceAmountReceived:SetText('|cnGREEN_FONT_COLOR:收款金额：')

                    elseif (invoiceType == "seller_temp_invoice") then
                        OpenMailInvoiceItemLabel:SetText("物品售出： "..itemName)
                        OpenMailInvoicePurchaser:SetText("购买者： "..playerName)
                        OpenMailInvoiceAmountReceived:SetText('等待发送的数量：')
                        OpenMailInvoiceMoneyDelay:SetFormattedText('预计投递时间%s', GameTime_GetFormattedTime(etaHour, etaMin, true))
                    end
                end
            end

            if ( isConsortium ) then
                local info = C_Mail.GetCraftingOrderMailInfo(InboxFrame.openMailID) or {}
                if ( info.reason == Enum.RcoCloseReason.RcoCloseCancel ) then
                    ConsortiumMailFrame.OpeningText:SetText('你的制造订单已被取消。')
                elseif ( info.reason == Enum.RcoCloseReason.RcoCloseExpire ) then
                    ConsortiumMailFrame.OpeningText:SetText('你的制造订单已过期。')
                elseif ( info.reason == Enum.RcoCloseReason.RcoCloseFulfill ) then
                    ConsortiumMailFrame.OpeningText:SetFormattedText('订单：%s',info.recipeName)
                    ConsortiumMailFrame.CrafterText:SetFormattedText('完成者：|cnHIGHLIGHT_FONT_COLOR:%s|r', info.crafterName or "")
                elseif ( info.reason == Enum.RcoCloseReason.RcoCloseReject ) then
                    ConsortiumMailFrame.OpeningText:SetFormattedText('订单：%s', info.recipeName)
                    ConsortiumMailFrame.CrafterText:SetFormattedText('|cnHIGHLIGHT_FONT_COLOR:%s|r决定不完成此订单。', info.crafterName or "")
                elseif ( info.reason == Enum.RcoCloseReason.RcoCloseCrafterFulfill ) then
                    ConsortiumMailFrame.OpeningText:SetFormattedText('订单：%s', info.recipeName)
                    ConsortiumMailFrame.CrafterText:SetFormattedText('收件人：%s', info.customerName or "")
                    ConsortiumMailFrame.ConsortiumNote:SetFormattedText('嗨，%1$s，你完成了%3$s的%2$s的订单，但还没寄给对方。因为你的订单即将过期，所以我们在没有收取额外费用的情况下帮你寄出去了！附上你的佣金。', UnitName("player"), info.recipeName, info.customerName or "")
                end
            end

            if (OpenMailFrame.itemButtonCount and OpenMailFrame.itemButtonCount > 0 ) then
                OpenMailAttachmentText:SetText('|cnGREEN_FONT_COLOR:拿取附件：')
            else
                OpenMailAttachmentText:SetText('无附件')
            end
            if InboxItemCanDelete(InboxFrame.openMailID) then
                OpenMailDeleteButton:SetText('删除')
            else
                OpenMailDeleteButton:SetText('退信')
            end
            set(OpenMailFrameTitleText, '打开邮件')
        end)
        set(OpenMailReplyButton, '回复')
        set(OpenMailCancelButton, '关闭')
    set(OpenMailInvoiceSalePrice, '售价：')
    set(OpenMailInvoiceDeposit, '保证金：')
    set(OpenMailInvoiceHouseCut, '拍卖费：')
    set(OpenMailInvoiceNotYetSent, '未发送的数量')

    set(OpenMailReportSpamButton, '举报玩家')
    set(ConsortiumMailFrame.CommissionReceived, '附上佣金：')
    set(ConsortiumMailFrame.CommissionPaidDisplay.CommissionPaidText, '已支付佣金：')

    hooksecurefunc('GuildChallengeAlertFrame_SetUp', function(frame, challengeType)--AlertFrameSystems.lua
        local text= e.strText[_G["GUILD_CHALLENGE_TYPE"..challengeType]]
        if text then
            frame.Type:SetText(text)
        end
    end)

    hooksecurefunc('AchievementAlertFrame_SetUp', function(frame, achievementID, alreadyEarned)
        --local _, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuildAch, wasEarnedByMe, earnedBy = select(12, GetAchievementInfo(achievementID)
        local unlocked = frame.Unlocked
        if select(12, GetAchievementInfo(achievementID)) then
            unlocked:SetText('获得公会成就')
        else
            unlocked:SetText('已获得成就')
        end
    end)

    hooksecurefunc('LootWonAlertFrame_SetUp', function(self, _, _, _, _, _, _, _, _, _, _, _, _, _, isSecondaryResult)
        if isSecondaryResult then
            self.Label:SetText('你获得了')--YOU_RECEIVED_LABEL
        end
    end)

    hooksecurefunc('HonorAwardedAlertFrame_SetUp', function(self, amount)
        self.Amount:SetFormattedText('%d点荣誉', amount)
    end)
    hooksecurefunc('GarrisonShipFollowerAlertFrame_SetUp', function(frame, _, _, _, _, _, _, isUpgraded)
        if ( isUpgraded ) then
            frame.Title:SetText('升级的舰船已加入你的舰队')
        else
            frame.Title:SetText('舰船已加入你的舰队')
        end
    end)
    hooksecurefunc('NewRecipeLearnedAlertFrame_SetUp', function(self, recipeID, recipeLevel)
        local tradeSkillID = C_TradeSkillUI.GetTradeSkillLineForRecipe(recipeID)
        if tradeSkillID then
            local recipeName = GetSpellInfo(recipeID)
            if recipeName then
                local rank = GetSpellRank(recipeID)
                self.Title:SetText(rank and rank > 1 and '配方升级！' or '学会了新配方！')

                if recipeLevel ~= nil then
                    recipeName = format('%s (等级 %i)', recipeName, recipeLevel)
                    local rankTexture = NewRecipeLearnedAlertFrame_GetStarTextureFromRank(rank)
                    if rankTexture then
                        self.Name:SetFormattedText("%s %s", recipeName, rankTexture)
                    else
                        self.Name:SetText(recipeName)
                    end
                end
            end
        end
    end)

    hooksecurefunc(SkillLineSpecsUnlockedAlertFrameMixin,'SetUp', function(self, skillLineID)
        self.Title:SetText('解锁新要素：')
        self.Name:SetFormattedText('%s专精', C_TradeSkillUI.GetTradeSkillDisplayName(skillLineID))
    end)
    hooksecurefunc('WorldQuestCompleteAlertFrame_SetUp', function(frame, questData)
        frame.ToastText:SetText(questData.displayAsObjective and '目标完成！' or '世界任务完成！')
    end)

    hooksecurefunc(ItemAlertFrameMixin, 'SetUpDisplay', function(self, _, _, _, label)
        if label== YOU_COLLECTED_LABEL then
            self.Label:SetText('你收集到了')
        end
    end)

    --死亡
    set(GhostFrameContentsFrameText, '返回墓地')

    --宠物对战
    if PetBattleFrame then
        set(PetBattleFrame.BottomFrame.TurnTimer.SkipButton, '待命')
    end

    --任务对话框
    set(GossipFrame.GreetingPanel.GoodbyeButton, '再见')
    set(QuestFrameAcceptButton, '接受')
    set(QuestFrameGreetingGoodbyeButton, '再见')
    set(QuestFrameCompleteQuestButton, '完成任务')
    set(QuestFrameCompleteButton, '继续')
    set(QuestFrameGoodbyeButton, '再见')
    set(QuestFrameDeclineButton, '拒绝')

    set(QuestMapFrame.DetailsFrame.BackButton, '返回')
    set(QuestMapFrame.DetailsFrame.AbandonButton, '放弃')

   hooksecurefunc('QuestMapFrame_UpdateQuestDetailsButtons', function()
        local questID = C_QuestLog.GetSelectedQuest()
        local isWatched = QuestUtils_IsQuestWatched(questID)
        if isWatched then
            QuestMapFrame.DetailsFrame.TrackButton:SetText('取消追踪')
            QuestLogPopupDetailFrame.TrackButton:SetText('取消追踪')
        else
            QuestMapFrame.DetailsFrame.TrackButton:SetText('追踪')
            QuestLogPopupDetailFrame.TrackButton:SetText('追踪')
        end
    end)

    set(QuestMapFrame.DetailsFrame.ShareButton, '共享')
    QuestMapFrame.DetailsFrame.DestinationMapButton.tooltipText= '显示最终目的地'
    QuestMapFrame.DetailsFrame.WaypointMapButton.tooltipText= '显示旅行路径'

    reg(QuestMapFrame.DetailsFrame.RewardsFrame, '奖励')
    set(MapQuestInfoRewardsFrame.ItemChooseText, '你可以从这些奖励品中选择一件：')
    set(MapQuestInfoRewardsFrame.PlayerTitleText, '新头衔： %s')
    set(MapQuestInfoRewardsFrame.QuestSessionBonusReward, '在小队同步状态下完成此任务有可能获得奖励：')
    set(QuestInfoRequiredMoneyText, '需要金钱：')
    set(QuestInfoRewardsFrame.ItemChooseText, '你可以从这些奖励品中选择一件：')
    set(QuestInfoRewardsFrame.PlayerTitleText, '新头衔： %s')
    set(QuestInfoRewardsFrame.QuestSessionBonusReward, '在小队同步状态下完成此任务有可能获得奖励：')


    hooksecurefunc(WorldMapFrame, 'SetupTitle', function(self)
        self.BorderFrame:SetTitle('地图和任务日志')
    end)
    hooksecurefunc(WorldMapFrame, 'SynchronizeDisplayState', function(self)
        if self:IsMaximized() then
            self.BorderFrame:SetTitle('地图')
        else
            self.BorderFrame:SetTitle('地图和任务日志')
        end
    end)
    set(WorldMapFrameHomeButtonText, '世界', nil, true)



    --小地图
    MinimapCluster.ZoneTextButton.tooltipText = MicroButtonTooltipText('世界地图', "TOGGLEWORLDMAP")
    MinimapCluster.ZoneTextButton:HookScript('OnEvent', function(self)
        self.tooltipText = MicroButtonTooltipText('世界地图', "TOGGLEWORLDMAP")
    end)
    Minimap.ZoomIn:HookScript('OnEnter', function()
        if GameTooltip:IsShown() then
            GameTooltip:SetText('放大')
        end
    end)
    Minimap.ZoomOut:HookScript('OnEnter', function()
        if GameTooltip:IsShown() then
            GameTooltip:SetText('缩小')
        end
    end)
    MinimapCluster.Tracking.Button:HookScript('OnEnter', function()
        GameTooltip:SetText('追踪', 1, 1, 1)
	    GameTooltip:AddLine('点击以开启或关闭追踪类型。', nil, nil, nil, true)
        GameTooltip:Show()
    end)





































    --编辑模式    
    set(EditModeManagerFrame.Title, 'HUD编辑模式')
    EditModeManagerFrame.Tutorial.MainHelpPlateButtonTooltipText= '点击这里打开/关闭编辑模式的帮助系统。'
    set(EditModeManagerFrame.ShowGridCheckButton.Label, '显示网格')
    set(EditModeManagerFrame.EnableSnapCheckButton.Label, '贴附到界面元素上')
    set(EditModeManagerFrame.EnableAdvancedOptionsCheckButton.Label, '高级选项')
    set(EditModeManagerFrame.AccountSettings.SettingsContainer.ScrollChild.AdvancedOptionsContainer.FramesTitle.Title, '框体')
    set(EditModeManagerFrame.AccountSettings.SettingsContainer.ScrollChild.AdvancedOptionsContainer.CombatTitle.Title, '战斗')
    set(EditModeManagerFrame.AccountSettings.SettingsContainer.ScrollChild.AdvancedOptionsContainer.MiscTitle.Title, '其它')
    set(EditModeManagerFrame.LayoutDropdown.Label, '布局：')
    hooksecurefunc(EditModeManagerFrame.AccountSettings, 'SetExpandedState', function(self, expanded, isUserInput)
        set(self.Expander.Label, expanded and '收起选项 |A:editmode-up-arrow:16:11:0:3|a' or '展开选项 |A:editmode-down-arrow:16:11:0:-7|a')
    end)
    set(EditModeManagerFrame.AccountSettings.Expander.Label, '展开选项 |A:editmode-down-arrow:16:11:0:-7|a')
    set(EditModeManagerFrame.RevertAllChangesButton, '撤销所有变更')
    set(EditModeManagerFrame.SaveChangesButton, '保存')

    --EditModeDialogs.lua
    set(EditModeUnsavedChangesDialog.CancelButton, '取消')
    hooksecurefunc(EditModeUnsavedChangesDialog, 'ShowDialog', function(self, selectedLayoutIndex)
        if selectedLayoutIndex then
            set(self.Title, '如果你切换布局，你会丢失所有未保存的改动。|n你想继续吗？')
            set(self.SaveAndProceedButton, '保存并切换')
            set(self.ProceedButton, '切换')
        else
            set(self.Title, '如果你现在退出，你会丢失所有未保存的改动。|n你想继续吗？')
            set(self.SaveAndProceedButton, '保存并退出')
            set(self.ProceedButton, '退出')
        end
    end)

    hooksecurefunc(EditModeSystemSettingsDialog, 'AttachToSystemFrame', function(self, systemFrame)
        local name= systemFrame:GetSystemName()
        if name and e.strText[name] then
            set(self.Title, e.strText[name])
        end
    end)

    set(EditModeNewLayoutDialog.Title, '给新布局起名')
    set(EditModeNewLayoutDialog.CharacterSpecificLayoutCheckButton.Label, '角色专用布局')
    set(EditModeNewLayoutDialog.AcceptButton, '保存')
    set(EditModeNewLayoutDialog.CancelButton, '取消')

    set(EditModeImportLayoutDialog.Title, '导入布局')
    set(EditModeImportLayoutDialog.EditBoxLabel, '导入文本：')
    set(EditModeImportLayoutDialog.ImportBox.EditBox.Instructions, '在此粘贴布局代码')
    set(EditModeImportLayoutDialog.NameEditBoxLabel, '新布局名称：')
    set(EditModeImportLayoutDialog.CharacterSpecificLayoutCheckButton.Label, '角色专用布局')
    set(EditModeImportLayoutDialog.AcceptButton, '导入')
    set(EditModeImportLayoutDialog.CancelButton, '取消')


    EditModeImportLayoutDialog.AcceptButton.disabledTooltip= '输入布局的名称'
    EditModeNewLayoutDialog.AcceptButton.disabledTooltip= '输入布局的名称'

    local function CheckForMaxLayouts(acceptButton, charSpecificButton)
        if EditModeManagerFrame:AreLayoutsFullyMaxed() then
            acceptButton.disabledTooltip = format('最多允许%d种角色布局和%d种账号布局', Constants.EditModeConsts.EditModeMaxLayoutsPerType, Constants.EditModeConsts.EditModeMaxLayoutsPerType)
            return true
        end
        local layoutType = charSpecificButton:IsControlChecked() and Enum.EditModeLayoutType.Character or Enum.EditModeLayoutType.Account
        local areLayoutsMaxed = EditModeManagerFrame:AreLayoutsOfTypeMaxed(layoutType)
        if areLayoutsMaxed then
            acceptButton.disabledTooltip = (layoutType == Enum.EditModeLayoutType.Character) and format('只允许有%d个角色专用的布局。勾选以保存一种账号通用的布局', Constants.EditModeConsts.EditModeMaxLayoutsPerType) or format('只允许有%d个账号通用的布局。勾选以保存一种角色专用的布局', Constants.EditModeConsts.EditModeMaxLayoutsPerType)
            return true
        end
    end
    local function CheckForDuplicateLayoutName(acceptButton, editBox)
        local editBoxText = editBox:GetText()
        local editModeLayouts = EditModeManagerFrame:GetLayouts()
        for _, layout in ipairs(editModeLayouts) do
            if layout.layoutName == editBoxText then
                acceptButton.disabledTooltip = '该名称已被使用。'
                return true
            end
        end
    end
    hooksecurefunc(EditModeImportLayoutDialog, 'UpdateAcceptButtonEnabledState', function(self)
        if not CheckForMaxLayouts(self.AcceptButton, self.CharacterSpecificLayoutCheckButton)
            and not CheckForDuplicateLayoutName(self.AcceptButton, self.LayoutNameEditBox)  then
            self.AcceptButton.disabledTooltip = '输入布局的名称'
        end
    end)
    hooksecurefunc(EditModeNewLayoutDialog, 'UpdateAcceptButtonEnabledState', function(self)
        if not CheckForMaxLayouts(self.AcceptButton, self.CharacterSpecificLayoutCheckButton)
            and not CheckForDuplicateLayoutName(self.AcceptButton, self.LayoutNameEditBox)  then
            self.AcceptButton.disabledTooltip = '输入布局的名称'
        end
    end)

    --EditModeManagerFrame.AccountSettings.SettingsContainer.ScrollChild.AdvancedOptionsContainer.CombatContainer

    for _, frame in pairs(EditModeManagerFrame.AccountSettings.SettingsContainer.ScrollChild.BasicOptionsContainer:GetLayoutChildren() or {}) do
        if frame.labelText then
            set(frame.Label, e.strText[frame.labelText])
        end
    end

    EditModeManagerFrame.AccountSettings.SettingsContainer.ScrollChild.AdvancedOptionsContainer.FramesContainer:HookScript('OnShow', function(self)
        for _,frame in pairs(self:GetLayoutChildren() or {}) do
            local text= e.strText[frame.labelText]
            if text then
                frame:SetLabelText(text)
                --set(frame.Label, e.strText[frame.labelText])
            end
        end
    end)
    EditModeManagerFrame.AccountSettings.SettingsContainer.ScrollChild.AdvancedOptionsContainer.CombatContainer:HookScript('OnShow', function(self)
        for _,frame in pairs(self:GetLayoutChildren() or {}) do
            local text= e.strText[frame.labelText]
            if text then
                frame:SetLabelText(text)
                --set(frame.Label, e.strText[frame.labelText])
            end
        end
    end)
    EditModeManagerFrame.AccountSettings.SettingsContainer.ScrollChild.AdvancedOptionsContainer.MiscContainer:HookScript('OnShow', function(self)
        for _,frame in pairs(self:GetLayoutChildren() or {}) do
            local text= e.strText[frame.labelText]
            if text then
                frame:SetLabelText(text)
            end
            if frame.disabledTooltipText== HUD_EDIT_MODE_LOOT_FRAME_DISABLED_TOOLTIP then
                frame.disabledTooltipText= '你必须关闭位于：界面 > 控制菜单中的“鼠标位置打开拾取窗口”选项，才能自定义拾取窗口布局。'
            end
        end
    end)
    hooksecurefunc(EditModeManagerFrame.AccountSettings, 'SetupStatusTrackingBar2', function(self)
        self.settingsCheckButtons.StatusTrackingBar2:SetLabelText('状态栏 2')
    end)

    set(EditModeSystemSettingsDialog.Buttons.RevertChangesButton, '撤销变更')
    hooksecurefunc(EditModeSystemMixin, 'AddExtraButtons', function(self)
        set(self.resetToDefaultPositionButton, '重设到默认位置')
    end)



    --GameTooltip.lua
    --替换，原生
    function GameTooltip_OnTooltipAddMoney(self, cost, maxcost)
        if( not maxcost or maxcost < 1 ) then --We just have 1 price to display
            SetTooltipMoney(self, cost, nil, string.format("%s:", '卖价'))
        else
            GameTooltip_AddColoredLine(self, ("%s:"):format('卖价'), HIGHLIGHT_FONT_COLOR)
            local indent = string.rep(" ",4)
            SetTooltipMoney(self, cost, nil, string.format("%s%s:", indent, '最小'))
            SetTooltipMoney(self, maxcost, nil, string.format("%s%s:", indent, '最大'))
        end
    end

    TOOLTIP_QUEST_REWARDS_STYLE_DEFAULT.headerText = '奖励'
    TOOLTIP_QUEST_REWARDS_STYLE_WORLD_QUEST.headerText = '奖励'
    TOOLTIP_QUEST_REWARDS_STYLE_CONTRIBUTION.headerText = '为该建筑捐献物资会奖励你：'
    TOOLTIP_QUEST_REWARDS_STYLE_PVP_BOUNTY.headerText = '悬赏奖励'
    TOOLTIP_QUEST_REWARDS_STYLE_ISLANDS_QUEUE.headerText = '获胜奖励：'
    TOOLTIP_QUEST_REWARDS_STYLE_EMISSARY_REWARD.headerText = '奖励'
    TOOLTIP_QUEST_REWARDS_PRIORITIZE_CURRENCY_OVER_ITEM.headerText = '奖励'


    --Ping系统
    set(PingSystemTutorialTitleText, '信号系统')
    set(PingSystemTutorial.Tutorial1.TutorialHeader, '|cnTUTORIAL_BLUE_FONT_COLOR:按下|r信号键，在世界上放置快速信号。')
    set(PingSystemTutorial.Tutorial2.TutorialHeader, '|cnTUTORIAL_BLUE_FONT_COLOR:按下并按住|r信号键，选择一个特定的信号。')
    set(PingSystemTutorial.Tutorial3.TutorialHeader, '|cnTUTORIAL_BLUE_FONT_COLOR:直接|r向一名生物或角色发送信号。')
    set(PingSystemTutorial.Tutorial4.TutorialHeader, '|cnTUTORIAL_BLUE_FONT_COLOR:设置使用|r信号的宏。')
    set(PingSystemTutorial.Tutorial4.ImageBounds.TutorialBody1, "在聊天中|cnNORMAL_FONT_COLOR:输入/macro|r")
    set(PingSystemTutorial.Tutorial4.ImageBounds.TutorialBody2, "宏命令：")
    set(PingSystemTutorial.Tutorial4.ImageBounds.TutorialBody3, "|cnNORMAL_FONT_COLOR:/ping [@target] 信号类型|r")




    --BNet.lua
    hooksecurefunc(BNToastFrame, 'ShowToast', function(self)
        local toastType, toastData = self.toastType or {}, self.toastData or {}
        if ( toastType == 5 ) then
            set(self.DoubleLine, '你收到了一个新的好友请求。')
        elseif ( toastType == 4 ) then
            set(self.DoubleLine, format('你共有|cff82c5ff%d|r条好友请求。', toastData))
        elseif ( toastType == 1 ) then
            if C_BattleNet.GetAccountInfoByID(toastData) then
                set(self.BottomLine, FRIENDS_GRAY_COLOR:WrapTextInColorCode('已经|cff00ff00上线|r'))
            end
        elseif ( toastType == 2 ) then
            if C_BattleNet.GetAccountInfoByID(toastData) then
                set(self.BottomLine, '已经|cffff0000下线|r。')
            end
        elseif ( toastType == 6 ) then
            local clubName

            if toastData.club.clubType == Enum.ClubType.BattleNet then
                clubName = BATTLENET_FONT_COLOR:WrapTextInColorCode(toastData.club.name)
            else
                clubName = NORMAL_FONT_COLOR:WrapTextInColorCode(toastData.club.name)
            end
            set(self.DoubleLine, format('你已受邀加入|n%s', clubName or ''))
        elseif (toastType == 7) then
            local clubName = NORMAL_FONT_COLOR:WrapTextInColorCode(toastData.name)
            set(self.DoubleLine, format('你已受邀加入|n%s', clubName or ''))
        end
    end)

































    --NavigationBar.lua
    hooksecurefunc('NavBar_Initialize', function(_, _, homeData, homeButton)
        local name= homeData and homeData.name or HOME
        name = name==HOME and '首页' or e.strText[name]
        set(homeButton.Text or homeButton.text, name, nil, true)
    end)


    --MovieFrame.xml
    set(MovieFrame.CloseDialog.ConfirmButton, '是')
    set(MovieFrame.CloseDialog.ResumeButton, '否')




    --StackSplitFrame.lua
    hooksecurefunc(StackSplitFrame, 'ChooseFrameType', function(self, splitAmount)
        if splitAmount ~= 1 then
            set(self.StackSplitText, format('%d 堆', self.split/self.minSplit))
            set(self.StackItemCountText, format('总计%d', self.split))
        end
    end)
    hooksecurefunc(StackSplitFrame, 'UpdateStackText', function(self)
        if self.isMultiStack then
            set(self.StackSplitText, format('%d 堆', self.split/self.minSplit))
            set(self.StackItemCountText, format('总计%d', self.split))
        end
    end)




    set(StackSplitFrame.OkayButton, '确定')
    set(StackSplitFrame.CancelButton, '取消')

    set(ColorPickerFrame.Footer.OkayButton, '确定')
    set(ColorPickerFrame.Footer.CancelButton, '取消')
    set(ColorPickerFrame.Header.Text, '颜色选择器')


    if PetStableFrame and e.Player.class=='HUNTER' then--PetStable.lua
        set(PetStableActivePetsLabel, '使用中')
        hooksecurefunc('PetStable_Update', function()
            PetStableFrame:SetTitleFormatted('%s 的小宠物', UnitName("player"))

            if ( PetStableFrame.selectedPet ) then
                if ( GetStablePetFoodTypes(PetStableFrame.selectedPet) ) then
                    PetStableDiet.tooltip = format('|cffffd200食物：|r%s', BuildListString(GetStablePetFoodTypes(PetStableFrame.selectedPet)))
                end
            end
            PetStableCurrentPage:SetFormattedText('页数 %s/%s', PetStableFrame.page, NUM_PET_STABLE_PAGES)
        end)

        hooksecurefunc('PetStable_UpdateSlot', function(button, petSlot)
            local icon, name, _, family, talent = GetStablePetInfo(petSlot)
            if ( icon and family and talent) then
                button.tooltip = e.strText[name] or name
                button.tooltipSubtext = format(STABLE_PET_INFO_TOOLTIP_TEXT, e.strText[family] or family, e.strText[talent] or talent)
            else
                button.tooltip = '空的兽栏位置'
            end
        end)

    end





    --Blizzard_Dialogs.lua
    dia('CONFIRM_RESET_TO_DEFAULT_KEYBINDINGS', {text = '确定将所有快捷键设置为默认值吗？', button1 = '确定', button2 = '取消'})
    dia('GAME_SETTINGS_TIMED_CONFIRMATION', {button1 = '确定', button2 = '取消'})
    dia('GAME_SETTINGS_CONFIRM_DISCARD', {text= '你尚有还未应用的设置。\n你确定要退出吗？', button1 = '退出', button2 = '应用并退出', button3 = '取消'})
    dia('GAME_SETTINGS_APPLY_DEFAULTS', {text= '你想要将所有用户界面和插件设置重置为默认状态，还是只重置这个界面或插件的设置？', button1 = '所有设置', button2 = '这些设置', button3 = '取消'})


    --StaticPopup.lua
    hookDia("GENERIC_CONFIRMATION", 'OnShow', function(self, data)--StaticPopup.lua
        if data.text==HUD_EDIT_MODE_DELETE_LAYOUT_DIALOG_TITLE then
            set(self.text, format('你确定要删除布局|n|cnGREEN_FONT_COLOR:%s|r吗？', data.text_arg1, data.text_arg2))

        elseif data.text==SELL_ALL_JUNK_ITEMS_POPUP then
            set(self.text, format('你即将出售所有垃圾物品，而且无法回购。\n你确定要继续吗？', data.text_arg1, data.text_arg2))

        elseif data.text==PROFESSIONS_CRAFTING_ORDER_MAIL_REPORT_WARNING then
            set(self.text, format('这名玩家有你还未认领的物品。如果你在认领前举报这名玩家，你会失去所有这些物品。', data.text_arg1, data.text_arg2))

        elseif data.text==SELL_ALL_JUNK_ITEMS_POPUP then
            set(self.text, format('你即将出售所有垃圾物品，而且无法回购。\n你确定要继续吗？', data.text_arg1, data.text_arg2))

        elseif data.text==TALENT_FRAME_CONFIRM_CLOSE then
            set(self.text, format('如果你继续，会失去所有待定的改动。', data.text_arg1, data.text_arg2))

        elseif data.text==CRAFTING_ORDER_RECRAFT_WARNING2 then
            set(self.text, format('再造可能导致你的物品的品质下降。|n|n\n\n你确定要发布此订单吗？', data.text_arg1, data.text_arg2))

        elseif data.text==PROFESSIONS_ORDER_UNUSABLE_WARNING then
            set(self.text, format('此物品目前不能使用，而且拾取后就会绑定。确定要下达此订单吗？', data.text_arg1, data.text_arg2))

        elseif data.text==CRAFTING_ORDERS_IGNORE_CONFIRMATION then
            set(self.text, format('你确定要屏蔽|cnGREEN_FONT_COLOR:%s|r吗？', data.text_arg1, data.text_arg2))

        elseif data.text==CRAFTING_ORDERS_OWN_REAGENTS_CONFIRMATION then
            set(self.text, format('你即将完成一个制造订单，里面包含一些你自己的材料。你确定吗？', data.text_arg1, data.text_arg2))

        elseif data.text==TALENT_FRAME_CONFIRM_LEAVE_DEFAULT_LOADOUT then
            set(self.text, format('你如果不先将你当前的天赋配置储存下来，就会永远失去此配置。|n|n你确定要继续吗？', data.text_arg1, data.text_arg2))

        elseif data.text==TALENT_FRAME_CONFIRM_STARTER_DEVIATION then
            set(self.text, format('选择此天赋会使你离开入门天赋配置指引。', data.text_arg1, data.text_arg2))

        end

        if not data.acceptText then
		    set(self.button1, '是')

        elseif data.acceptText==OKAY then
            set(self.button1, '确定')

        elseif data.acceptText==SAVE then
            set(self.button1, '保存')

        elseif data.acceptText==ACCEPT then
                set(self.button1, '接受')

        elseif data.acceptText==CONTINUE then
            set(self.button1, '继续')
        end

        if not data.cancelText then
            set(self.button2, '否')

        elseif data.cancelText==CANCEL then
            set(self.button2, '取消')
        end

	end)

    hookDia("GENERIC_INPUT_BOX", 'OnShow', function(self, data)
        if data.text==HUD_EDIT_MODE_RENAME_LAYOUT_DIALOG_TITLE then
            set(self.text, format('为布局|cnGREEN_FONT_COLOR:%s|r输入新名称', data.text_arg1, data.text_arg2))
        end

        if not data.acceptText then
            self.button1:SetText('完成')

        elseif data.acceptText==OKAY then
            set(self.button1, '确定')

        elseif data.acceptText==SAVE then
            set(self.button1, '保存')

        elseif data.acceptText==ACCEPT then
                set(self.button1, '接受')

        elseif data.acceptText==CONTINUE then
            set(self.button1, '继续')
        end

        if not data.cancelText then
		    self.button2:SetText('取消')
        end
	end)

    dia("CONFIRM_OVERWRITE_EQUIPMENT_SET", {text = '你已经有一个名为|cnGREEN_FONT_COLOR:%s|r的装备方案了。是否要覆盖已有方案', button1 = '是', button2 = '否'})
    dia("CONFIRM_SAVE_EQUIPMENT_SET", {text = '你想要保存装备方案\"|cnGREEN_FONT_COLOR:%s|r\"吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_DELETE_EQUIPMENT_SET", {text = '你确认要删除装备方案 |cnGREEN_FONT_COLOR:%s|r 吗？', button1 = '是', button2 = '否'})

    dia("CONFIRM_GLYPH_PLACEMENT",{button1 = '是', button2 = '否'})
    hookDia("CONFIRM_GLYPH_PLACEMENT", 'OnShow', function(self)
		self.text:SetFormattedText('你确定要使用|cnGREEN_FONT_COLOR:%s|r铭文吗？这将取代|cnGREEN_FONT_COLOR:%s|r。', self.data.name, self.data.currentName)
	end)

    dia("CONFIRM_GLYPH_REMOVAL",{button1 = '是', button2 = '否'})
    hookDia("CONFIRM_GLYPH_REMOVAL", 'OnShow', function(self)
		self.text:SetFormattedText('你确定要移除|cnGREEN_FONT_COLOR:%s|r吗？', self.data.name)
	end)

    dia("CONFIRM_RESET_TEXTTOSPEECH_SETTINGS", {text = '确定将所有文字转语音设定重置为默认值吗？', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_REDOCK_CHAT", {text = '这么做会将你的聊天窗口重新并入综合标签页。', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_PURCHASE_TOKEN_ITEM", {text = '你确定要将%s兑换为下列物品吗？ %s', button1 = '是', button2 = '否'})
    dia("CONFIRM_PURCHASE_NONREFUNDABLE_ITEM", {text = '你确定要将%s兑换为下列物品吗？本次购买将无法退还。%s', button1 = '是', button2 = '否'})

    dia("CONFIRM_UPGRADE_ITEM", {button1 = '是', button2 = '否'})
    hookDia("CONFIRM_UPGRADE_ITEM", 'OnShow', function(self, data)
		if data.isItemBound then
			self.text:SetFormattedText('你确定要花费|cnGREEN_FONT_COLOR:%s|r升级下列物品吗？', data.costString)
		else
			self.text:SetFormattedText('你确定要花费|cnGREEN_FONT_COLOR:%s|r升级下列物品吗？升级会将该物品变成灵魂绑定物品。', data.costString)
		end
    end)

    dia("CONFIRM_REFUND_TOKEN_ITEM", {text = '你确定要退还下面这件物品%s，获得%s的退款吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_REFUND_MAX_HONOR", {text = '你的荣誉已接近上限。卖掉这件物品会让你损失%d点荣誉。确认要继续吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_REFUND_MAX_ARENA_POINTS", {text = '你的竞技场点数已接近上限。出售这件物品会让你损失|cnGREEN_FONT_COLOR:%d|r点竞技场点数。确认要继续吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_REFUND_MAX_HONOR_AND_ARENA", {text = '你的荣誉已接近上限。卖掉此物品会使你损失%1$d点荣誉和%2$d的竞技场点数。要继续吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_HIGH_COST_ITEM", {text = '你确定要花费如下金额的货币购买%s吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_COMPLETE_EXPENSIVE_QUEST", {text = '完成这个任务需要缴纳如下数额的金币。你确定要完成这个任务吗？', button1 = '完成任务', button2 = '取消'})
    dia("CONFIRM_ACCEPT_PVP_QUEST", {text = '接受这个任务之后，你将被标记为PvP状态，直到你放弃或完成此任务。你确定要接受任务吗？', button1 = '接受', button2 = '取消'})
    dia("USE_GUILDBANK_REPAIR", {text = '你想要使用公会资金修理吗？', button1 = '使用个人资金', button2 = '确定'})
    dia("GUILDBANK_WITHDRAW", {text = '接提取数量：', button1 = '接受', button2 = '取消'})
    dia("GUILDBANK_DEPOSIT", {text = '存放数量：', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_BUY_GUILDBANK_TAB", {text = '你是否想要购买一个公会银行标签？', button1 = '是', button2 = '否'})
    dia("CONFIRM_BUY_REAGENTBANK_TAB", {text = '确定购买材料银行栏位吗？', button1 = '是', button2 = '否'})
    dia("TOO_MANY_LUA_ERRORS", {text = '你的插件有大量错误，可能会导致游戏速度降低。你可以在界面选项中打开Lua错误显示。', button1 = '禁用插件', button2 = '忽略'})
    dia("CONFIRM_ACCEPT_SOCKETS", {text = '镶嵌之后，一颗或多颗宝石将被摧毁。你确定要镶嵌新的宝石吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_RESET_INSTANCES", {text = '你确定想要重置你的所有副本吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_RESET_CHALLENGE_MODE", {text = '你确定要重置地下城吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_GUILD_DISBAND", {text = '你真的要解散公会吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_BUY_BANK_SLOT", {text = '你愿意付钱购买银行空位吗？', button1 = '是', button2 = '否'})
    dia("MACRO_ACTION_FORBIDDEN", {text = '一段宏代码已被禁止，因为其功能只对暴雪UI开放。', button1 = '确定'})
    dia("ADDON_ACTION_FORBIDDEN", {text = '|cnRED_FONT_COLOR:%s|r已被禁用，因为该功能只对暴雪的UI开放。\n你可以禁用这个插件并重新装载UI。', button1 = '禁用', button2 = '忽略'})
    dia("CONFIRM_LOOT_DISTRIBUTION", {text = '你想要将%s分配给%s，确定吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_BATTLEFIELD_ENTRY", {text = '你现在可以进入战斗：\n\n|cff20ff20%s|r\n', button1 = '进入', button2 = '离开队列'})
    dia("BFMGR_CONFIRM_WORLD_PVP_QUEUED", {text = '你已在%s队列中。请等候。', button1 = '确定'})
    dia("BFMGR_CONFIRM_WORLD_PVP_QUEUED_WARMUP", {text = '你正在下一场%s战斗的等待队列中。', button1 = '确定'})
    dia("BFMGR_DENY_WORLD_PVP_QUEUED", {text = '你现在无法进入%s战场的等待队列。', button1 = '确定'})
    dia("BFMGR_INVITED_TO_QUEUE", {text = '你想要加入%s的战斗吗？', button1 = '接受', button2 = '取消'})
    dia("BFMGR_INVITED_TO_QUEUE_WARMUP", {text = '%s的战斗即将打响！你要加入等待队列吗？', button1 = '接受', button2 = '取消'})
    dia("BFMGR_INVITED_TO_ENTER", {text = '%s的战斗又一次在召唤你！|n现在进入？|n剩余时间：%d %s', button1 = '接受', button2 = '取消'})
    dia("BFMGR_EJECT_PENDING", {text = '你已在%s队列中但还没有收到战斗的召唤。稍后你将被传出战场。', button1 = '确定'})
    dia("BFMGR_EJECT_PENDING_REMOTE", {text = '你已在%s队列中但还没有收到战斗的召唤。', button1 = '确定'})
    dia("BFMGR_PLAYER_EXITED_BATTLE", {text = '你已经从%s的战斗中退出。', button1 = '确定'})
    dia("BFMGR_PLAYER_LOW_LEVEL", {text = '你的级别太低，无法进入%s。', button1 = '确定'})
    dia("BFMGR_PLAYER_NOT_WHILE_IN_RAID", {text = '你不能在团队中进入%s。', button1 = '确定'})
    dia("BFMGR_PLAYER_DESERTER", {text = '在你的逃亡者负面效果消失之前，你无法进入%s。', button1 = '确定'})
    dia("CONFIRM_GUILD_LEAVE", {text = '确定要退出%s？', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_GUILD_PROMOTE", {text = '确定要将%s提升为会长？', button1 = '接受', button2 = '取消'})
    dia("RENAME_GUILD", {text = '输入新的公会名：', button1 = '接受', button2 = '取消'})
    dia("HELP_TICKET_QUEUE_DISABLED", {text = 'GM帮助请求暂时不可用。', button1 = '确定'})
    dia("CLIENT_RESTART_ALERT", {text = '你的有些设置需要你重新启动游戏才能够生效。', button1 = '确定'})
    dia("CLIENT_LOGOUT_ALERT", {text = '你的某些设置将在你登出游戏并重新登录之后生效。', button1 = '确定'})
    dia("COD_ALERT", {text = '你没有足够的钱来支付付款取信邮件。', button1 = '关闭'})
    dia("COD_CONFIRMATION", {text = '收下这件物品将花费：', button1 = '接受', button2 = '取消'})
    dia("COD_CONFIRMATION_AUTO_LOOT", {text = '收下这件物品将花费：', button1 = '接受', button2 = '取消'})
    dia("DELETE_MAIL", {text = '删除这封邮件会摧毁%s', button1 = '接受', button2 = '取消'})
    dia("DELETE_MONEY", {text = '删除这封邮件会摧毁：', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_REPORT_BATTLEPET_NAME", {text = '你确定要举报%s 使用不当战斗宠物名吗？', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_REPORT_PET_NAME", {text = '你确定要举报%s 使用不当战斗宠物名吗？', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_REPORT_SPAM_MAIL", {text = '你确定要举报%s为骚扰者吗？', button1 = '接受', button2 = '取消'})
    dia("JOIN_CHANNEL", {text = '输入频道名称', button1 = '接受', button2 = '取消'})
    dia("CHANNEL_INVITE", {text = '你想要将谁邀请至%s？', button1 = '接受', button2 = '取消'})
    dia("CHANNEL_PASSWORD", {text = '为%s输入一个密码。', button1 = '接受', button2 = '取消'})
    dia("NAME_CHAT", {text = '输入对话窗口名称', button1 = '接受', button2 = '取消'})
    dia("RESET_CHAT", {text = '"将你的聊天窗口重置为默认设置。\n你会失去所有自定义设置。', button1 = '接受', button2 = '取消'})
    dia("PETRENAMECONFIRM", {text = '你确定要将宠物命名为\'%s\'吗？', button1 = '是', button2 = '否'})

    dia("DEATH", {text = '%d%s后释放灵魂', button1 = '释放灵魂', button2 = '复活', button3 = '复活', button4 = '摘要'})
    hookDia("DEATH", 'OnShow', function(self)
		if ( IsActiveBattlefieldArena() and not C_PvP.IsInBrawl() ) then
			self.text:SetText('你死亡了。释放灵魂后将进入观察模式。')
		elseif ( self.timeleft == -1 ) then
			self.text:SetText('你死亡了。要释放灵魂到最近的墓地吗？')
		end
	end)
    hookDia("DEATH", 'OnUpdate', function(self)--, elapsed)
		if ( IsFalling() and not IsOutOfBounds()) then
			return
		end

		local b1_enabled = self.button1:IsEnabled()
		local encounterSupressRelease = IsEncounterSuppressingRelease()
		if ( encounterSupressRelease ) then
			self.button1:SetText('释放灵魂')
		else
			local hasNoReleaseAura, _, hasUntilCancelledDuration = HasNoReleaseAura()
			if ( hasNoReleaseAura ) then
				if hasUntilCancelledDuration then
					self.button1:SetText('释放灵魂')
				end
			else
				self.button1:SetText('释放灵魂')
			end
		end
		if ( b1_enabled ~= self.button1:IsEnabled() ) then
			if ( b1_enabled ) then
				if ( encounterSupressRelease ) then
					self.text:SetText('你队伍中有一名成员正在战斗中。')
				else
					self.text:SetText('现在无法释放。')
				end
			end
		end
	end)


    dia("RESURRECT", {text = '%s想要复活你。一旦这样复活，你将会进入复活虚弱状态', delayText = '%s要复活你，%d%s内生效。一旦这样复活，你将会进入复活虚弱状态。', button1 = '接受', button2 = '拒绝'})
    dia("RESURRECT_NO_SICKNESS", {text = '%s想要复活你', delayText = '%s要复活你，%d%s内生效', button1 = '接受', button2 = '拒绝'})
    dia("RESURRECT_NO_TIMER", {text = '%s想要复活你', button1 = '接受', button2 = '拒绝'})
    dia("SKINNED", {text = '徽记被取走 - 你只能在墓地复活', button1 = '接受'})
    dia("SKINNED_REPOP", {text = '徽记被取走 - 你只能在墓地复活', button1 = '释放灵魂', button2 = '拒绝'})
    dia("TRADE", {text = '和%s交易吗？', button1 = '是', button2 = '否'})
    dia("PARTY_INVITE", {button1 = '接受', button2 = '拒绝'})
    dia("GROUP_INVITE_CONFIRMATION", {button1 = '接受', button2 = '拒绝'})
    dia("CHAT_CHANNEL_INVITE", {text = '%2$s邀请你加入\'%1$s\'频道。', button1 = '接受', button2 = '拒绝'})
    dia("BN_BLOCK_FAILED_TOO_MANY_RID", {text = '你能够屏蔽的实名和战网昵称好友已达上限。', button1 = '确定'})
    dia("BN_BLOCK_FAILED_TOO_MANY_CID", {text = '你通过暴雪游戏服务屏蔽的角色数量已达上限。', button1 = '确定'})
    dia("CHAT_CHANNEL_PASSWORD", {text = '请输入\'%1$s\'的密码。', button1 = '接受', button2 = '取消'})
    dia("CAMP", {text = '请输入\'%1$s\'的密码。', button1 = '取消'})
    dia("QUIT", {text = '%d%s后退出游戏', button1 = '立刻退出', button2 = '取消'})
    dia("LOOT_BIND", {text = '拾取%s后，该物品将与你绑定', button1 = '确定', button2 = '取消'})
    dia("EQUIP_BIND", {text = '装备之后，该物品将与你绑定。', button1 = '确定', button2 = '取消'})
    dia("EQUIP_BIND_REFUNDABLE", {text = '进行此项操作会使该物品无法退还', button1 = '确定', button2 = '取消'})
    dia("EQUIP_BIND_TRADEABLE", {text = '执行此项操作会使该物品不可交易。', button1 = '确定', button2 = '取消'})
    dia("USE_BIND", {text = '使用该物品后会将它和你绑定', button1 = '确定', button2 = '取消'})
    dia("CONFIM_BEFORE_USE", {text = '你确定要使用这个物品吗？', button1 = '确定', button2 = '取消'})
    dia("USE_NO_REFUND_CONFIRM", {text = '进行此项操作会使该物品无法退还', button1 = '确定', button2 = '取消'})
    dia("CONFIRM_AZERITE_EMPOWERED_BIND", {text = '选择一种力量后，此物品会与你绑定。', button1 = '确定', button2 = '取消'})
    dia("CONFIRM_AZERITE_EMPOWERED_SELECT_POWER", {text = '你确定要选择这项艾泽里特之力吗？', button1 = '确定', button2 = '取消'})
    dia("CONFIRM_AZERITE_EMPOWERED_RESPEC", {text = '重铸的花费会随使用的次数而提升。\n\n你确定要花费如下金额来重铸%s吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_AZERITE_EMPOWERED_RESPEC_EXPENSIVE", {text = '重铸的花费会随使用的次数而提升。|n|n你确定要花费%s来重铸%s吗？|n|n请输入 %s 以确认。', button1 = '是', button2 = '否'})
    dia("DELETE_ITEM", {text = '你确定要摧毁%s？', button1 = '是', button2 = '否'})
    dia("DELETE_QUEST_ITEM", {text = '确定要销毁%s吗？\n\n|cffff2020销毁该物品的同时也将放弃所有相关任务。|r', button1 = '是', button2 = '否'})
    dia("DELETE_GOOD_ITEM", {text = '你真的要摧毁%s吗？\n\n请在输入框中输入\"'..DELETE_ITEM_CONFIRM_STRING..'\"以确认。', button1 = '是', button2 = '否'})
    dia("DELETE_GOOD_QUEST_ITEM", {text = '确定要摧毁%s吗？\n|cffff2020摧毁该物品也将同时放弃相关任务。|r\n\n请在输入框中输入\"'..DELETE_ITEM_CONFIRM_STRING..'\"以确认。', button1 = '是', button2 = '否'})
    dia("QUEST_ACCEPT", {text = '%s即将开始%s\n你也想这样吗？', button1 = '是', button2 = '否'})
    dia("QUEST_ACCEPT_LOG_FULL", {text = '%s正在开始%s任务\n你的任务纪录已满。如果能够在任务纪录中\n空出位置，你也可以参与此任务。', button1 = '是', button2 = '否'})
    dia("ABANDON_PET", {text = '你是否决定永远地遗弃你的宠物？你将再也不能召唤它了。', button1 = '确定', button2 = '取消'})
    dia("ABANDON_QUEST", {text = '放弃\"%s\"？', button1 = '是', button2 = '否'})
    dia("ABANDON_QUEST_WITH_ITEMS", {text = '确定要放弃\"%s\"并摧毁%s吗？', button1 = '是', button2 = '否'})
    dia("ADD_FRIEND", {text = '输入好友的角色名：', button1 = '接受', button2 = '取消'})
    dia("SET_FRIENDNOTE", {text = '为%s设置备注：', button1 = '接受', button2 = '取消'})
    dia("SET_BNFRIENDNOTE", {text = '为%s设置备注：', button1 = '接受', button2 = '取消'})
    dia("SET_COMMUNITY_MEMBER_NOTE", {text = '为%s设置备注：', button1 = '接受', button2 = '取消'})

    dia("CONFIRM_REMOVE_COMMUNITY_MEMBER", {text = '你确定要将%s从群组中移除吗？', button1 = '是', button2 = '否'})
    hookDia("CONFIRM_REMOVE_COMMUNITY_MEMBER", 'OnShow', function(self, data)
		if data.clubType == Enum.ClubType.Character then
			self.text:SetFormattedText('你确定要将%s从社区中移除吗？', data.name)
		else
			self.text:SetFormattedText('你确定要将%s从群组中移除吗？', data.name)
		end
	end)


    dia("CONFIRM_DESTROY_COMMUNITY_STREAM", {text = '你确定要删除频道%s吗？', button1 = '是', button2 = '否'})
    hookDia("CONFIRM_DESTROY_COMMUNITY_STREAM", 'OnShow', function(self, data)
		local streamInfo = C_Club.GetStreamInfo(data.clubId, data.streamId)
		if streamInfo then
			self.text:SetFormattedText('你确定要删除频道%s吗', streamInfo.name)
		end
	end)

    dia("CONFIRM_LEAVE_AND_DESTROY_COMMUNITY", {text = '确定要退出并删除群组吗？', subText = '退出后群组会被删除。你确定要删除群组吗？此操作无法撤销。', button1 = '接受', button2 = '取消'})
    hookDia("CONFIRM_LEAVE_AND_DESTROY_COMMUNITY", 'OnShow', function(self, clubInfo)
        if clubInfo.clubType == Enum.ClubType.Character then
            self.text:SetText('确定要退出并删除社区吗？')
            self.SubText:SetText('退出后社区会被删除。你确定要删除社区吗？此操作无法撤销。')
        else
            self.text:SetText('确定要退出并删除群组吗？')
            self.SubText:SetText('退出后群组会被删除。你确定要删除群组吗？此操作无法撤销。')
        end
    end)

    dia("CONFIRM_LEAVE_COMMUNITY", {text = '退出群组？', subText = '你确定要退出%s吗？', button1 = '接受', button2 = '取消'})
    hookDia("CONFIRM_LEAVE_COMMUNITY", 'OnShow', function(self, clubInfo)
        if clubInfo.clubType == Enum.ClubType.Character then
			self.text:SetText('退出社区？')
			self.SubText:SetFormattedText('你确定要退出%s吗？', clubInfo.name)
		else
			self.text:SetText('退出群组？')
			self.SubText:SetFormattedText('你确定要退出%s吗？', clubInfo.name)
		end
    end)

    dia("CONFIRM_DESTROY_COMMUNITY", {button1 = '接受', button2 = '取消'})
    hookDia("CONFIRM_DESTROY_COMMUNITY", 'OnShow', function(self, clubInfo)
        if clubInfo.clubType == Enum.ClubType.BattleNet then
			self.text:SetFormattedText('你确定要删除群组\"%s\"吗？此操作无法撤销。|n|n请在输入框中输入\"'..COMMUNITIES_DELETE_CONFIRM_STRING ..'\"以确认。', clubInfo.name)
		else
			self.text:SetFormattedText('你确定要删除社区\"%s\"吗？此操作无法撤销。|n|n请在输入框中输入\"'..COMMUNITIES_DELETE_CONFIRM_STRING ..'\"以确认。', clubInfo.name)
		end
    end)

    dia("ADD_IGNORE", {text = '输入想要屏蔽的玩家名字\n或者\n在聊天窗口中按住Shift并点击该玩家的名字：', button1 = '接受', button2 = '取消'})
    dia("ADD_GUILDMEMBER", {text = '添加公会成员：', button1 = '接受', button2 = '取消'})
    dia("CONVERT_TO_RAID", {text = '你的队伍已经满了。你想要将队伍转换成团队吗？\n\n注意：在团队中，你的大部分任务都无法完成！', button1 = '转换', button2 = '取消'})
    dia("LFG_LIST_AUTO_ACCEPT_CONVERT_TO_RAID", {text = '你的队伍已经满了。你想要将队伍转换成团队吗？\n\n注意：在团队中，你的大部分任务都无法完成！', button1 = '转换', button2 = '取消'})

    dia("REMOVE_GUILDMEMBER", {text = format('确定想要从公会中移除%s吗？', "XXX"), button1 = '是', button2 = '否'})
    hookDia("REMOVE_GUILDMEMBER", 'OnShow', function(self, data)
		if data then
			self.text:SetFormattedText('你确定想要从公会中移除%s吗？', data.name)
		end
	end)

    dia("SET_GUILDPLAYERNOTE", {text = '设置玩家信息', button1 = '接受', button2 = '取消'})
    dia("SET_GUILDOFFICERNOTE", {text = '设置公会官员信息', button1 = '接受', button2 = '取消'})

    dia("SET_GUILD_COMMUNITIY_NOTE", {text = '设置玩家信息', button1 = '接受', button2 = '取消'})
    hookDia("SET_GUILD_COMMUNITIY_NOTE", 'OnShow', function(self, data)
		if data then
			self.text:SetText(data.isPublic and '设置玩家信息' or '设置公会官员信息')
		end
	end)

    dia("RENAME_PET", {text = '输入你想要给宠物起的名字：', button1 = '接受', button2 = '取消'})
    dia("DUEL_REQUESTED", {text = '%s向你发出决斗要求。', button1 = '接受', button2 = '拒绝'})
    dia("DUEL_OUTOFBOUNDS", {text = '正在离开决斗区域,你将在%d%s内失败。'})
    dia("PET_BATTLE_PVP_DUEL_REQUESTED", {text = '%s向你发出宠物对战要求。', button1 = '接受', button2 = '拒绝'})
    dia("UNLEARN_SKILL", {text = '你确定要忘却%s并遗忘所有已经学会的配方？如果你选择回到此专业，你的专精知识将依然存在。|n|n在框内输入 \"'..UNLEARN_SKILL_CONFIRMATION ..'\" 以确认。', button1 = '忘却这个技能', button2 = '取消'})
    dia("XP_LOSS", {text = '如果你找到你的尸体，那么你可以在没有任何惩罚的情况下复活。现在由我来复活你，那么你的所有物品（包括已装备的和物品栏中的）将损失50%%的耐久度，你也要承受%s的|cff71d5ff|Hspell:15007|h[复活虚弱]|h|r时间。', button1 = '接受', button2 = '取消'})
    dia("XP_LOSS_NO_SICKNESS_NO_DURABILITY", {text = '你可以找到你的尸体并在尸体位置复活。10级以下的玩家可以在此复活并不受任何惩罚。"', button1 = '接受', button2 = '取消'})
    dia("RECOVER_CORPSE", {delayText = '%d%s后复活', text= '现在复活吗？', button1 = '接受'})
    dia("RECOVER_CORPSE_INSTANCE", {text= '你必须进入副本才能捡回你的尸体。'})
    dia("AREA_SPIRIT_HEAL", {text = '%d%s后复活', button1 = '选择位置', button2 = '取消'})
    dia("BIND_ENCHANT", {text = '对这件物品进行附魔将使其与你绑定。', button1 = '确定', button2 = '取消'})
    dia("BIND_SOCKET", {text = '该操作将使此物品与你绑定。', button1 = '确定', button2 = '取消'})
    dia("REFUNDABLE_SOCKET", {text = '进行此项操作会使该物品无法退还', button1 = '确定', button2 = '取消'})
    dia("ACTION_WILL_BIND_ITEM", {text = '该操作将使此物品与你绑定。', button1 = '确定', button2 = '取消'})
    dia("REPLACE_ENCHANT", {text = '你要将\"%s\"替换为\"%s\"吗？', button1 = '是', button2 = '否'})
    dia("REPLACE_TRADESKILL_ENCHANT", {text = '你要将\"%s\"替换为\"%s\"吗？', button1 = '是', button2 = '否'})
    dia("TRADE_REPLACE_ENCHANT", {text = '你要将\"%s\"替换为\"%s\"吗？', button1 = '是', button2 = '否'})
    dia("TRADE_POTENTIAL_BIND_ENCHANT", {text = '将此物品附魔会使其与你绑定。', button1 = '确定', button2 = '取消'})
    dia("TRADE_POTENTIAL_REMOVE_TRANSMOG", {text = '交易%s后，将把它从你的外观收藏中移除。', button1 = '确定'})
    dia("CONFIRM_MERCHANT_TRADE_TIMER_REMOVAL", {text = '出售后%s将变为不可交易物品，即使你将其回购也无法恢复。', button1 = '确定', button2 = '取消'})
    dia("END_BOUND_TRADEABLE", {text = '执行此项操作会使该物品不可交易。', button1 = '确定', button2 = '取消'})
    dia("INSTANCE_BOOT", {text = '你现在不在这个副本的队伍里。你将在%d%s内被传送到最近的墓地中。'})
    dia("GARRISON_BOOT", {text = '该要塞不属于你或者你的队长。你将在%d %s后被传送出要塞。'})
    dia("INSTANCE_LOCK", {text = '你进入了一个已经保存进度的副本！你将在%2$s内被保存到%1$s的副本进度中！', button1 = '接受', button2 = '离开副本'})
    --dia("CONFIRM_TALENT_WIPE", {text = '你确定要遗忘所有的天赋吗', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_BINDER", {text = '你想要将%s设为你的新家吗？', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_SUMMON", {text = '%s想将你召唤到%s去。这个法术将在%d%s后取消。', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_SUMMON_SCENARIO", {text = '%s已在%s开启一个场景战役。你是否愿意加入他们？\n\n此邀请将在%d%s后失效。', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_SUMMON_STARTING_AREA", {text = '%s想召唤你前往%s。\n\n你将无法返回此初始区域。\n\n该法术将在%d %s后取消。', button1 = '接受', button2 = '取消'})
    dia("BILLING_NAG", {text = '您的帐户中还有%d%s的剩余游戏时间', button1 = '确定'})
    dia("IGR_BILLING_NAG", {text = '你的IGR游戏时间即将用尽，你很快会被断开连接。', button1 = '确定'})
    dia("CONFIRM_LOOT_ROLL", {text = '拾取%s后，该物品将与你绑定。', button1 = '确定', button2 = '取消'})
    dia("GOSSIP_CONFIRM", {button1 = '接受', button2 = '取消'})
    dia("GOSSIP_ENTER_CODE", {text = '请输入电子兑换券号码：', button1 = '接受', button2 = '取消'})
    dia("CREATE_COMBAT_FILTER", {text = '输入过滤名称：', button1 = '接受', button2 = '取消'})
    dia("COPY_COMBAT_FILTER", {text = '输入过滤名称：', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_COMBAT_FILTER_DELETE", {text = '你确认要删除这个过滤条件？', button1 = '确定', button2 = '取消'})
    dia("CONFIRM_COMBAT_FILTER_DEFAULTS", {text = '你确定要将过滤条件设定为初始状态吗？', button1 = '确定', button2 = '取消'})
    dia("WOW_MOUSE_NOT_FOUND", {text = '无法找到魔兽世界专用鼠标。请连接鼠标后在用户界面中再次启动该选项。', button1 = '确定'})
    dia("CONFIRM_BUY_STABLE_SLOT", {text = '你确定要支付以下数量的金币来购买一个新的兽栏栏位吗？', button1 = '是', button2 = '否'})
    dia("TALENTS_INVOLUNTARILY_RESET", {text = '因为天赋树有了一些改动，你的某些天赋已被重置。', button1 = '确定'})
    dia("TALENTS_INVOLUNTARILY_RESET_PET", {text = '你的宠物天赋已被重置。', button1 = '确定'})
    dia("SPEC_INVOLUNTARILY_CHANGED", {text = '由于该专精暂时无法使用，你的角色专精已发生改变。', button1 = '确定'})

    dia("VOTE_BOOT_PLAYER", {button1 = '是', button2 = '否'})

    dia("VOTE_BOOT_REASON_REQUIRED", {text = '请写明将%s投票移出的理由：', button1 = '确定', button2 = '取消'})
    dia("LAG_SUCCESS", {text = '你的延迟报告已经成功提交。', button1 = '确定'})
    dia("LFG_OFFER_CONTINUE", {text = '一名玩家离开了你的队伍。是否寻找另一名玩家以完成%s？', button1 = '是', button2 = '否'})
    dia("CONFIRM_MAIL_ITEM_UNREFUNDABLE", {text = '进行此项操作会使该物品无法退还', button1 = '确定', button2 = '取消'})
    dia("AUCTION_HOUSE_DISABLED", {text = '拍卖行目前暂时关闭。|n请稍后再试。', button1 = '确定'})
    dia("CONFIRM_BLOCK_INVITES", {text = '你确定要屏蔽任何来自%s的邀请？', button1 = '接受', button2 = '取消'})
    dia("BATTLENET_UNAVAILABLE", {text = '暴雪游戏服务暂时不可用。\n\n你的实名和战网昵称好友无法显示，你也无法发送或收到实名或战网昵称好友邀请。也许需要重启游戏以重新启用暴雪游戏服务功能。', button1 = '确定'})
    dia("WEB_PROXY_FAILED", {text = '在配置浏览器时发生错误。请重启魔兽世界并再试一次。', button1 = '确定'})
    dia("WEB_ERROR", {text = '错误：%d|n浏览器无法完成你的请求。请重试。', button1 = '确定'})
    dia("CONFIRM_REMOVE_FRIEND", {button1 = '接受', button2 = '取消'})
    dia("PICKUP_MONEY", {text = '提取总额', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_GUILD_CHARTER_PURCHASE", {text = '你会失去在上一个公会中的一级公会声望\n你是否要继续？', button1 = '是', button2 = '否'})
    dia("GUILD_DEMOTE_CONFIRM", {button1 = '是', button2 = '否'})
    dia("GUILD_PROMOTE_CONFIRM", {button1 = '是', button2 = '否'})
    dia("CONFIRM_RANK_AUTHENTICATOR_REMOVE", {button1 = '是', button2 = '否'})
    dia("VOID_DEPOSIT_CONFIRM", {text = '储存这件物品将移除该物品上的一切改动并使其无法退还，且无法交易。\n你是否要继续？', button1 = '确定', button2 = '取消'})
    dia("GUILD_IMPEACH", {text = '你所在公会的领袖已被标记为非活动状态。你现在可以争取公会领导权。是否要移除公会领袖？', button1 = '弹劾', button2 = '取消'})
    dia("SPELL_CONFIRMATION_PROMPT", {button1 = '是', button2 = '否'})
    dia("SPELL_CONFIRMATION_WARNING", {button1 = '确定'})
    dia("CONFIRM_LAUNCH_URL", {text = '点击“确定”后将在你的网络浏览器中打开一个窗口。', button1 = '确定', button2 = '取消'})

    dia("CONFIRM_LEAVE_INSTANCE_PARTY", {button1 = '是', button2 = '取消'})
    StaticPopupDialogs["CONFIRM_LEAVE_INSTANCE_PARTY"].OnShow= function(self)
        local text= self.text:GetText()
        if text== CONFIRM_LEAVE_BATTLEFIELD then
            set(self.text, '确定要离开战场吗？')
        elseif text== CONFIRM_LEAVE_INSTANCE_PARTY then
            set(self.text, '确定要离开副本队伍吗？\n\n一旦离开队伍，你将无法返回该副本。')
        end
    end

    dia("CONFIRM_LEAVE_BATTLEFIELD", {text = '确定要离开战场吗？', button1 = '是', button2 = '取消'})
    hookDia("CONFIRM_LEAVE_BATTLEFIELD", 'OnShow', function(self)
		local ratedDeserterPenalty = C_PvP.GetPVPActiveRatedMatchDeserterPenalty()
		if ( ratedDeserterPenalty ) then
			local ratingChange = math.abs(ratedDeserterPenalty.personalRatingChange)
			local queuePenaltySpellLink, queuePenaltyDuration = C_SpellBook.GetSpellLinkFromSpellID(ratedDeserterPenalty.queuePenaltySpellID), SecondsToTime(ratedDeserterPenalty.queuePenaltyDuration)
			self.text:SetFormattedText('现在离开比赛会使你失去至少|cnORANGE_FONT_COLOR:%1$d|r点评级分数，而且你会受到%3$s的影响，持续%2$s。|n|n如果你现在离开，你将无法获得你完成的回合的荣誉或征服点数。|n|n你确定要离开比赛吗？', ratingChange, queuePenaltyDuration, queuePenaltySpellLink)
		elseif ( IsActiveBattlefieldArena() and not C_PvP.IsInBrawl() ) then
			self.text:SetText('确定要离开竞技场吗？')
		else
			self.text:SetText('确定要离开战场吗？')
		end
	end)

    dia("CONFIRM_SURRENDER_ARENA", {text= '放弃？', button1 = '是', button2 = '取消'})
    hookDia("CONFIRM_SURRENDER_ARENA", 'OnShow', function(self)
		self.text:SetText('放弃？')
	end)


    dia("SAVED_VARIABLES_TOO_LARGE", {text = '你的计算机内存不足，无法加载下列插件设置。请关闭部分插件。\n\n|cffffd200%s|r', button1 = '确定'})
    dia("PRODUCT_ASSIGN_TO_TARGET_FAILED", {text = '获取物品错误。请重试一次。', button1 = '确定'})
    hookDia("BATTLEFIELD_BORDER_WARNING", 'OnUpdate', function(self)
        self.text:SetFormattedText('你已经脱离了%s的战斗。\n\n为你保留的位置将在%s后失效。', self.data.name, SecondsToTime(self.timeleft, false, true))
    end)
    dia("LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS", {text = '针对此项活动，你的队伍人数已满，将被移出列表。', button1 = '确定'})
    dia("LFG_LIST_ENTRY_EXPIRED_TIMEOUT", {text = '你的队伍由于长期处于非活跃状态，已被移出列表。如果你还需要寻找申请者，请重新加入列表。', button1 = '确定'})
    dia("NAME_TRANSMOG_OUTFIT", {text = '输入外观方案名称：', button1 = '保存', button2 = '取消'})
    dia("CONFIRM_OVERWRITE_TRANSMOG_OUTFIT", {text = '你已经有一个名为%s的外观方案了。是否要覆盖已有方案？', button1 = '是', button2 = '否'})
    dia("CONFIRM_DELETE_TRANSMOG_OUTFIT", {text = '确定要删除外观方案%s吗？', button1 = '是', button2 = '否'})
    dia("TRANSMOG_OUTFIT_CHECKING_APPEARANCES", {text = '检查外观……', button1 = '取消'})
    dia("TRANSMOG_OUTFIT_ALL_INVALID_APPEARANCES", {text = '由于你的角色无法幻化此套装下的任何外观，因此你无法保存此外观方案。', button1 = '确定'})
    dia("TRANSMOG_OUTFIT_SOME_INVALID_APPEARANCES", {text = '此外观方案无法保存，因为你的角色有一件或多件物品无法幻化。', button1 = '确定', button2 = '取消'})
    dia("TRANSMOG_APPLY_WARNING", {button1 = '确定', button2 = '取消'})
    dia("TRANSMOG_FAVORITE_WARNING", {text = '将此外观设置为偏好外观将使你背包中的这个物品无法退款且无法交易。\n确定要继续吗？', button1 = '确定', button2 = '取消'})
    dia("CONFIRM_UNLOCK_TRIAL_CHARACTER", {text = '确定要升级这个角色吗？完成此步骤之后，你将无法更改自己的选择。', button1 = '确定', button2 = '取消'})
    dia("DANGEROUS_SCRIPTS_WARNING", {text = '你正试图运行自定义脚本。运行自定义脚本可能危害到你的角色，导致物品或金币损失。|n|n确定要运行吗？', button1 = '是', button2 = '否'})
    dia("EXPERIMENTAL_CVAR_WARNING", {text = '您已开启了一项或多项实验性镜头功能。这可能对部分玩家造成视觉上的不适。', button1 = '接受', button2 = '禁用"'})
    dia("PREMADE_GROUP_SEARCH_DELIST_WARNING", {text = '你的预创建队伍界面上已有一组队伍列表。是否要清除列表，开始新的搜索？', button1 = '是', button2 = '否'})

    dia("PREMADE_GROUP_LEADER_CHANGE_DELIST_WARNING", {text = '你已经被提升为队伍领袖|TInterface\\GroupFrame\\UI-Group-LeaderIcon:0:0:0:-1|t |n|n|cffffd200你想以此队名重新列出队伍吗？|r|n%s|n', subText = '|n%s后自动从列表移除', button1 = '列出我的队伍', button2 = '我想编辑队名', button3 = '不列出我的队伍'})
    hookDia("PREMADE_GROUP_LEADER_CHANGE_DELIST_WARNING", 'OnShow', function(self, data)
		self.text:SetFormattedText('你已经被提升为队伍领袖|TInterface\\GroupFrame\\UI-Group-LeaderIcon:0:0:0:-1|t |n|n|cffffd200你想以此队名重新列出队伍吗？|r|n%s|n', data.listingTitle)
	end)

    dia("PREMADE_GROUP_INSECURE_SEARCH", {text= '你的队伍已被移出列表，要搜索|n%s吗？', button1 = '是', button2 = '否'})
    dia("BACKPACK_INCREASE_SIZE", {text = '为您的《魔兽世界》账号添加安全令和短信安全保护功能，即可获得4格额外的背包空间。|n|n战网安全令完全免费，而且使用方便，可以有效地保护您的账号。短信安全保护功能可以在账号有重要改动时为您通知提醒。|n|n点击“启用”以打开账号安全设置页面。', button1 = '启用', button2 = '取消'})
    dia("GROUP_FINDER_AUTHENTICATOR_POPUP", {text = '为你的账号添加安全令和短信安全保护功能后就能使用队伍查找器的全部功能。|n|n战网安全令完全免费，而且使用方便，可以有效地保护您的账号，短信安全保护功能可以在账号有重要改动时为您通知提醒。|n|n点击“启用”即可打开安全令设置网站。', button1 = '启用', button2 = '取消'})
    dia("CLIENT_INVENTORY_FULL_OVERFLOW", {text= '你的背包满了。给背包腾出空间才能获得遗漏的物品。', button1 = '确定'})

    dia("LEAVING_TUTORIAL_AREA", {button2 = '结束教程"'})
    hookDia("LEAVING_TUTORIAL_AREA", 'OnShow', function(self)
		if UnitFactionGroup("player") == "Horde" then
			self.button1:SetText('返回')
			self.text:SetText('你距离奥格瑞玛太远了。|n |n如果你继续走的话，就会脱离教程。|n |n你想返回奥格瑞玛吗？|n |n |n')
		else
			self.button1:SetText('返回')
			self.text:SetText('你距离暴风城太远了。|n |n如果你继续走的话，就会脱离教程。|n |n你想返回暴风城吗？|n |n |n')
		end
	end)

    dia("CLUB_FINDER_ENABLED_DISABLED", {text = '公会和社区查找器已可用或不可用。', button1 = '确定'})

    dia("INVITE_COMMUNITY_MEMBER", {text = '邀请成员', subText = '输入战网昵称。',button1 = '发送', button2 = '取消'})
    hookDia("INVITE_COMMUNITY_MEMBER", 'OnShow', function(self, data)
		local clubInfo = C_Club.GetClubInfo(data.clubId) or {}
		if clubInfo.clubType == Enum.ClubType.BattleNet then
			self.SubText:SetText('输入一位战网好友名称')
			self.editBox.Instructions:SetText('实名好友或战网昵称')
		else
			self.SubText:SetText('输入角色名-服务器名。')
		end
		self.button1:SetScript("OnEnter", function(self2)
			if(not self2:IsEnabled()) then
                GameTooltip:SetOwner(self2, "ANCHOR_BOTTOMRIGHT")
                GameTooltip_AddColoredLine(GameTooltip, '已经达到最大人数。移除一名玩家后才能进行邀请。', RED_FONT_COLOR, true)
                GameTooltip:Show()
            end
		end)
		if (self.extraButton) then
			self.extraButton:SetScript("OnEnter", function(self2)
				if(not self2:IsEnabled()) then
                    GameTooltip:SetOwner(self2, "ANCHOR_BOTTOMRIGHT")
                    GameTooltip_AddColoredLine(GameTooltip, '已经达到最大人数。移除一名玩家后才能进行邀请。', RED_FONT_COLOR, true)
                    GameTooltip:Show()
                end
			end)
		end
	end)

    dia("CONFIRM_RAF_REMOVE_RECRUIT", {text = '你确定要从你的招募战友中移除|n|cffffd200%s|r|n吗？|n|n请在输入框中输入“'..REMOVE_RECRUIT_CONFIRM_STRING..'”以确定。', button1 = '是', button2 = '否'})

    dia("REGIONAL_CHAT_DISABLED", {
        text = '聊天已关闭',
        subText = '某些区域规定对此账号有影响。聊天功能已经默认关闭。你现在可以重新开启这些功能。或者你之后决定开启的话，可以在聊天设置面板里进行操作。\n\n如果你决定开启这些功能，请注意我们的社区互动规则，如果你遇到了任何的不当言论、行为，只要这些言论和行为对游戏体验造成了破坏或者干扰，您就可以使用我们在游戏内的举报选项进行举报。我们会评估聊天记录并采取对应的措施。',
        button1 = '打开聊天',
        button2 = '聊天保持关闭'
    })

    dia("CHAT_CONFIG_DISABLE_CHAT", {text = '你确定要完全关闭聊天吗？你将无法发送和接收任何信息。', button1 = '关闭聊天', button2 = '取消'})

    dia("RETURNING_PLAYER_PROMPT", {button1 = '是', button2 = '否'})
    hookDia("RETURNING_PLAYER_PROMPT", 'OnShow', function(self)
        local factionMajorCities = {
            ["Alliance"] = '暴风城',
            ["Horde"] = '奥格瑞玛',
        }
		local playerFactionGroup = UnitFactionGroup("player")
		local factionCity = playerFactionGroup and factionMajorCities[playerFactionGroup] or nil
		if factionCity then
			self.text:SetFormattedText('我们有好一阵子没见到你了！|n|n在%s可以开始全新的冒险之旅！|n|n你希望传送到那里吗？', factionCity)
		end
	end)

    dia("CRAFTING_HOUSE_DISABLED", {text = '工匠商盟目前不接受制造订单。|n请稍后再来看看！', button1 = '确定'})
    dia("PERKS_PROGRAM_DISABLED", {text = '商栈目前关闭。|n请稍后再试。', button1 = '确定'})


    --HelpFrame.lua
    dia("EXTERNAL_LINK", {text = '你正被重新定向到：\n|cffffd200%s|r\n点击“确定”，以在你的网页浏览器中打开此链接。', button1 = '确定', button2= '取消', button3 = '复制链接'})

    --LFGFrame.lua
    dia("LFG_QUEUE_EXPAND_DESCRIPTION", {text = '你正被重新定向到：\n|cffffd200%s|r\n点击“确定”，以在你的网页浏览器中打开此链接。', button1 = '是', button2= '否'})

    --Blizzard_PetBattleUI.lua
    dia("PET_BATTLE_FORFEIT", {text = '确定要放弃比赛吗？你的对手将被判定获胜，你的宠物也将损失百分之%d的生命值。', button1 = '确定', button2 = '取消',})
    dia("PET_BATTLE_FORFEIT_NO_PENALTY", {text = '确定要放弃比赛吗？你的对手将被判定获胜。', button1 = '确定', button2 = '取消',})

    --TextToSpeechFrame.lua
    dia("TTS_CONFIRM_SAVE_SETTINGS", {text= '你想让这个角色使用已经在这台电脑上保存的文字转语音设置吗？如果你从另一台电脑上登入，此设置会保存并覆盖之前你拥有的任何设定。', button1= '是', button2= '取消'})

    --Keybindings.lua
    dia("CONFIRM_DELETING_CHARACTER_SPECIFIC_BINDINGS", {text = '确定要切换到通用键位设定吗？所有本角色专用的键位设定都将被永久删除。', button1 = '确定', button2 = '取消'})




























end
































local function Init_Loaded(arg1)
    if arg1=='Blizzard_AuctionHouseUI' then
        hooksecurefunc(AuctionHouseFrame, 'UpdateTitle', function(self)
            local tab = PanelTemplates_GetSelectedTab(self)
            local title = '浏览拍卖'
            if tab == 2 then
                title = '发布拍卖'
            elseif tab == 3 then
                title = '拍卖'
            end
            self:SetTitle(title)
        end)
        hooksecurefunc('AuctionHouseFilterButton_SetUp', function(btn, info)
            set(btn, e.strText[info.name])
        end)

        set(AuctionHouseFrameBuyTab.Text, '购买')
            set(AuctionHouseFrame.SearchBar.FilterButton, '过滤器')
            hooksecurefunc(AuctionHouseFrame.BrowseResultsFrame.ItemList, 'SetState', function(self, state)
                if state == 1 then
                    local searchResultsText = self.searchStartedFunc and select(2, self.searchStartedFunc())
                    if searchResultsText== AUCTION_HOUSE_BROWSE_FAVORITES_TIP then
                        set(self.ResultsText, '小窍门：右键点击物品可以设置偏好。偏好的物品会在你打开拍卖行时立即出现。')
                    end
                elseif state == 2 then
                    set(self.ResultsText, '未发现物品')
                end
            end)

        set(AuctionHouseFrameSellTab.Text, '出售')
        set(AuctionHouseFrameAuctionsTab.Text, '拍卖')
        set(AuctionHouseFrameAuctionsFrame.CancelAuctionButton, '取消拍卖')
        set(AuctionHouseFrameAuctionsFrameAuctionsTab.Text, '拍卖')
        set(AuctionHouseFrameAuctionsFrameBidsTab.Text, '竞标')
        set(AuctionHouseFrameAuctionsFrameBidsTab.Text, '竞标')
        hooksecurefunc(AuctionHouseFrame.BrowseResultsFrame.ItemList, 'SetDataProvider', function(self)
            if self.ResultsText and self.ResultsText:IsShown() then
                set(self.ResultsText, '小窍门：右键点击物品可以设置偏好。偏好的物品会在你打开拍卖行时立即出现。')
            end
        end)

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
        AuctionHouseFrame.ItemSellFrame.BuyoutModeCheckButton:HookScript('OnEnter', function()
            GameTooltip_AddNormalLine(GameTooltip, '取消勾选此项以允许对你的拍卖品进行竞拍。', true)
            GameTooltip:Show()
        end)

        --刷新，列表
        set(AuctionHouseFrame.CommoditiesBuyFrame.BackButton, '返回')
        set(AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.BuyButton, '一口价')
        set(AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.QuantityInput.Label, '数量')
        set(AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.UnitPrice.Label, '单价')
        set(AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.TotalPrice.Label, '总价')

        set(AuctionHouseFrame.ItemBuyFrame.BackButton, '返回')
        set(AuctionHouseFrame.ItemBuyFrame.BidFrame.BidButton, '竞标')
        set(AuctionHouseFrame.ItemBuyFrame.BuyoutFrame.BuyoutButton, '一口价')

        AuctionHouseFrame.CommoditiesSellList.RefreshFrame.RefreshButton:HookScript('OnEnter', function()
            GameTooltip_SetTitle(GameTooltip, '刷新')
            GameTooltip:Show()
        end)
        AuctionHouseFrame.ItemSellList.RefreshFrame.RefreshButton:HookScript('OnEnter', function()
            GameTooltip_SetTitle(GameTooltip, '刷新')
            GameTooltip:Show()
        end)


        --Blizzard_AuctionHouseSharedTemplates.lua
        hooksecurefunc(AuctionHouseFrame.ItemSellList.RefreshFrame, 'SetQuantity', function(self, totalQuantity)
            if totalQuantity ~= 0 then
                set(self.TotalQuantity, format('可购买数量：|cnGREEN_FONT_COLOR:%s|r', e.MK(totalQuantity, 0)))
            end
        end)
        hooksecurefunc(AuctionHouseFrame.CommoditiesSellList.RefreshFrame, 'SetQuantity', function(self, totalQuantity)
            if totalQuantity ~= 0 then
                set(self.TotalQuantity, format('可购买数量：|cnGREEN_FONT_COLOR:%s|r', e.MK(totalQuantity, 0)))
            end
        end)
        hooksecurefunc(AuctionHouseFrame.ItemBuyFrame.BidFrame, 'SetPrice', function(self, minBid, isOwnerItem, isPlayerHighBid)
            if not (isPlayerHighBid or minBid == 0) then
                if minBid > GetMoney() then
                    self.BidButton:SetDisableTooltip('你的钱不够')
                elseif isOwnerItem then
                    self.BidButton:SetDisableTooltip('你不能购买自己的拍卖品')
                end
            end
        end)

        --Blizzard_AuctionHouseSellFrame.lua
        hooksecurefunc(AuctionHouseFrame.CommoditiesSellFrame, 'UpdatePostButtonState', function(self)
            local canPostItem, reasonTooltip = self:CanPostItem()
            if not canPostItem and reasonTooltip then
                if reasonTooltip== AUCTION_HOUSE_SELL_FRAME_ERROR_ITEM then
                    self.PostButton:SetTooltip('没有选择物品')
                elseif reasonTooltip== AUCTION_HOUSE_SELL_FRAME_ERROR_DEPOSIT then
                    self.PostButton:SetTooltip('你没有足够的钱来支付保证金')
                elseif reasonTooltip== AUCTION_HOUSE_SELL_FRAME_ERROR_QUANTITY then
                    self.PostButton:SetTooltip('数量必须大于0')
                elseif reasonTooltip== ERR_GENERIC_THROTTLE then
                    self.PostButton:SetTooltip('你太快了')
                end
            end
        end)
        hooksecurefunc(AuctionHouseFrame.ItemSellFrame, 'UpdatePostButtonState', function(self)
            local canPostItem, reasonTooltip = self:CanPostItem()
            if not canPostItem and reasonTooltip then
                if reasonTooltip== AUCTION_HOUSE_SELL_FRAME_ERROR_ITEM then
                    self.PostButton:SetTooltip('没有选择物品')
                elseif reasonTooltip== AUCTION_HOUSE_SELL_FRAME_ERROR_DEPOSIT then
                    self.PostButton:SetTooltip('你没有足够的钱来支付保证金')
                elseif reasonTooltip== AUCTION_HOUSE_SELL_FRAME_ERROR_QUANTITY then
                    self.PostButton:SetTooltip('数量必须大于0')
                elseif reasonTooltip== ERR_GENERIC_THROTTLE then
                    self.PostButton:SetTooltip('你太快了')
                end
            end
        end)


        set(AuctionHouseFrame.WoWTokenResults.Buyout, '一口价')
        set(AuctionHouseFrame.WoWTokenResults.BuyoutLabel, '一口价')
        AuctionHouseFrame.WoWTokenResults.HelpButton:HookScript('OnEnter', function()
            GameTooltip:AddLine('关于魔兽世界时光徽章')
            GameTooltip:Show()
        end)

        --Blizzard_AuctionHouseFrame.lua
        dia("BUYOUT_AUCTION", {text = '以一口价购买：', button1 = '接受', button2 = '取消',})
        dia("BID_AUCTION", {text = '出价为：', button1 = '接受', button2 = '取消',})

        dia("PURCHASE_AUCTION_UNIQUE", {text = '出价为：', button1 = '确定', button2 = '取消',})
        hookDia("PURCHASE_AUCTION_UNIQUE", 'OnShow', function(self, data)
            self.text:SetFormattedText('|cffffd200此物品属于“%s”。|n|n你同时只能装备一件拥有此标签的装备。|r', data.categoryName)
        end)

        dia("CANCEL_AUCTION", {text = '取消拍卖将使你失去保证金。', button1 = '接受', button2 = '取消'})
        hookDia("CANCEL_AUCTION", 'OnShow', function(self)
            local cancelCost = C_AuctionHouse.GetCancelCost(self.data.auctionID)
            if cancelCost > 0 then
                self.text:SetText('取消拍卖会没收你所有的保证金和：')
            else
                self.text:SetText('取消拍卖将使你失去保证金。')
            end
        end)

        dia("AUCTION_HOUSE_POST_WARNING", {text = NORMAL_FONT_COLOR:WrapTextInColorCode('拍卖行即将在已经预定的每周维护时间段中进行重大更新。|n|n如果你的拍卖品到时还未售出，你的物品会被提前退回，而且你会失去你的保证金。'), button1 = '接受', button2 = '取消',})
        dia("AUCTION_HOUSE_POST_ERROR", {text =  NORMAL_FONT_COLOR:WrapTextInColorCode('目前无法拍卖物品。|n|n拍卖行即将进行重大更新。'), button1 = '确定'})

        --Blizzard_AuctionHouseWoWTokenFrame.lua
        dia("TOKEN_NONE_FOR_SALE", {text = '目前没有可售的魔兽世界时光徽章。请稍后再来查看。', button1 = '确定'})
        dia("TOKEN_AUCTIONABLE_TOKEN_OWNED", {text = '你必须先将从商城购得的魔兽世界时光徽章售出后才能从拍卖行中购买新的徽章。', button1 = '确定'})

        set(AuctionHouseFrame.BuyDialog.BuyNowButton, '立即购买')
        set(AuctionHouseFrame.BuyDialog.CancelButton, '取消')


















    elseif arg1=='Blizzard_ClassTalentUI' then
         for _, tabID in pairs(ClassTalentFrame:GetTabSet() or {}) do
            local btn= ClassTalentFrame:GetTabButton(tabID)
            if tabID==1 then
                set(btn, '专精')
            elseif tabID==2 then
                set(btn, '天赋')
            end
        end

        --Blizzard_ClassTalentTalentsTab.lua
        set(ClassTalentFrame.TalentsTab.ApplyButton, '应用改动')
        set(ClassTalentFrame.TalentsTab.SearchBox.Instructions, '搜索')
        hooksecurefunc(ClassTalentFrame.TalentsTab.ApplyButton, 'SetDisabledTooltip', function(self, canChangeError)
            if canChangeError then
                if canChangeError ==  TALENT_FRAME_REFUND_INVALID_ERROR  then
                    self.disabledTooltip = '你必须修复所有错误。忘却天赋来释放点数，并在其他地方花费这些点数来构建可用的配置。'
                elseif canChangeError== ERR_TALENT_FAILED_UNSPENT_TALENT_POINTS then
                    self.disabledTooltip= '你必须花费所有可用的天赋点才能应用改动'
                end
            end
        end)
        ClassTalentFrame.TalentsTab.ApplyButton:HookScript('OnEnter', function()
        end)
        hooksecurefunc(ClassTalentFrame.TalentsTab.ClassCurrencyDisplay, 'SetPointTypeText', function(self, text)
            set(self.CurrencyLabel, format('%s 可用点数', text))
        end)
        hooksecurefunc(ClassTalentFrame.TalentsTab.SpecCurrencyDisplay, 'SetPointTypeText', function(self, text)
            set(self.CurrencyLabel, format('%s 可用点数', text))
        end)
        ClassTalentFrame.TalentsTab.InspectCopyButton:SetTextToFit('复制配置代码')

        if ClassTalentFrame.SpecTab.numSpecs and ClassTalentFrame.SpecTab.numSpecs>0 and ClassTalentFrame.SpecTab.SpecContentFramePool then
            local sex= UnitSex("player")
            local SPEC_STAT_STRINGS = {
                [LE_UNIT_STAT_STRENGTH] = '力量',
                [LE_UNIT_STAT_AGILITY] = '敏捷',
                [LE_UNIT_STAT_INTELLECT] = '智力',
            }
            for frame in pairs(ClassTalentFrame.SpecTab.SpecContentFramePool.activeObjects or {}) do
                set(frame.ActivatedText, '激活')
                set(frame.ActivateButton, '激活')
                if frame.RoleName then
                    set(frame.RoleName, e.strText[frame.RoleName:GetText()])
                end
                set(frame.SampleAbilityText, '典型技能')
                if frame.specIndex then
                    local specID, _, description, _, _, primaryStat = GetSpecializationInfo(frame.specIndex, false, false, nil, sex)
                    if specID and primaryStat and primaryStat ~= 0 then
                        set(frame.Description, description.."|n"..format('主要属性：%s', SPEC_STAT_STRINGS[primaryStat]))
                    end
                end
            end
        end

        --Blizzard_WarmodeButtonTemplate.lua
        ClassTalentFrame.TalentsTab.WarmodeButton:HookScript('OnEnter', function(self)
            --GameTooltip:SetOwner(self, "ANCHOR_LEFT", 14, 0)
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine('战争模式')
            --GameTooltip_SetTitle(GameTooltip, '战争模式')
            if C_PvP.IsWarModeActive() or self:GetWarModeDesired() then
                GameTooltip_AddInstructionLine(GameTooltip, '|cnGREEN_FONT_COLOR:开启')
            end
            local wrap = true
            local warModeRewardBonus = C_PvP.GetWarModeRewardBonus()
            GameTooltip_AddNormalLine(GameTooltip, format('加入战争模式即可激活世界PvP，使任务的奖励和经验值提高%1$d%%，并可以在野外使用PvP天赋。', warModeRewardBonus), wrap)
            local canToggleWarmode = C_PvP.CanToggleWarMode(true)
            local canToggleWarmodeOFF = C_PvP.CanToggleWarMode(false)

            if(not canToggleWarmode or not canToggleWarmodeOFF) then
                if (not C_PvP.ArePvpTalentsUnlocked()) then
                    GameTooltip_AddErrorLine(GameTooltip, format('|cnRED_FONT_COLOR:在%d级解锁', C_PvP.GetPvpTalentsUnlockedLevel()), wrap)
                else
                    local warmodeErrorText
                    if(not C_PvP.CanToggleWarModeInArea()) then
                        if(self:GetWarModeDesired()) then
                            if(not canToggleWarmodeOFF and not IsResting()) then
                                warmodeErrorText = UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0] and '战争模式可以在任何休息区域关闭，但只能在奥格瑞玛或瓦德拉肯开启。' or '战争模式可以在任何休息区域关闭，但只能在暴风城或瓦德拉肯开启。'
                            end
                        else
                            if(not canToggleWarmode) then
                                warmodeErrorText = UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0] and '只能在奥格瑞玛或瓦德拉肯进入战争模式。' or '只能在暴风城或瓦德拉肯进入战争模式。'
                            end
                        end
                    end
                    if(warmodeErrorText) then
                        GameTooltip_AddErrorLine(GameTooltip, '|cnRED_FONT_COLOR:'..warmodeErrorText, wrap)
                    elseif (UnitAffectingCombat("player")) then
                        GameTooltip_AddErrorLine(GameTooltip, '|cnRED_FONT_COLOR:你正处于交战状态', wrap)
                    end
                end
            end
            GameTooltip:Show()
        end)

        dia("CONFIRM_LEARN_SPEC", {button1 = '是', button2 = '否',})
        hookDia("CONFIRM_LEARN_SPEC", 'OnShow', function(self)
            if (self.data.previewSpecCost and self.data.previewSpecCost > 0) then
                self.text:SetFormattedText('激活此专精需要花费%s。确定要学习此专精吗？', GetMoneyString(self.data.previewSpecCost))
            else
                self.text:SetText('你确定要学习这种天赋专精吗？')
            end
        end)

        dia("CONFIRM_EXIT_WITH_UNSPENT_TALENT_POINTS", {text = '你还有未分配的天赋。你确定要关闭这个窗口？', button1 = '是', button2 = '否'})

        hooksecurefunc(ClassTalentFrame, 'UpdateFrameTitle', function(self)
            local tabID = self:GetTab()
            if self:IsInspecting() then
                local inspectUnit = self:GetInspectUnit()
                if inspectUnit then
                    self:SetTitle(format('天赋 - %s', UnitName(self:GetInspectUnit())))
                else
                    self:SetTitle(format('天赋链接 (%s %s)', self:GetSpecName(), self:GetClassName()))
                end
            elseif tabID == self.specTabID then
                self:SetTitle('专精')
            else -- tabID == self.talentTabID
                self:SetTitle('天赋')
            end
        end)

        --Blizzard_ClassTalentLoadoutEditDialog.lua
        dia("LOADOUT_CONFIRM_DELETE_DIALOG", {text = '你确定要删除配置%s吗？', button1 = '删除', button2 = '取消'})
        dia("LOADOUT_CONFIRM_SHARED_ACTION_BARS", {text = '此配置的动作条会被你共享的动作条替换。', button1 = '接受', button2 = '取消'})
        ClassTalentLoadoutEditDialog.UsesSharedActionBars:HookScript('OnEnter', function()
            GameTooltip:AddLine(' ')
            GameTooltip_AddNormalLine(GameTooltip, '默认条件下，每个配置都有自己保存的一套动作条。\n\n所有开启此选项的配置都会共享同样的动作条。')
            GameTooltip:Show()
        end)

        --Blizzard_ClassTalentLoadoutImportDialog.xml
        set(ClassTalentLoadoutImportDialog.Title, '导入配置')
        set(ClassTalentLoadoutImportDialog.ImportControl.Label, '导入文本')
        set(ClassTalentLoadoutImportDialog.ImportControl.InputContainer.EditBox.Instructions, '在此粘贴配置代码')
        set(ClassTalentLoadoutImportDialog.NameControl.Label, '新配置名称')
        set(ClassTalentLoadoutImportDialog.AcceptButton, '导入')
        set(ClassTalentLoadoutImportDialog.CancelButton, '取消')
        ClassTalentLoadoutImportDialog.AcceptButton.disabledTooltip = '输入可用的配置代码'

        --Blizzard_ClassTalentLoadoutEditDialog.xml
        set(ClassTalentLoadoutEditDialog.Title, '配置设定')
        set(ClassTalentLoadoutEditDialog.NameControl.Label, '名字')
        set(ClassTalentLoadoutEditDialog.UsesSharedActionBars.Label, '使用共享的动作条')
        set(ClassTalentLoadoutEditDialog.AcceptButton, '接受')
        set(ClassTalentLoadoutEditDialog.DeleteButton, '删除')
        set(ClassTalentLoadoutEditDialog.CancelButton, '取消')

        --Blizzard_ClassTalentLoadoutCreateDialog.xml
        set(ClassTalentLoadoutCreateDialog.Title, '新配置')
        set(ClassTalentLoadoutCreateDialog.NameControl.Label, '名字')
        set(ClassTalentLoadoutCreateDialog.AcceptButton, '保存')
        set(ClassTalentLoadoutCreateDialog.CancelButton, '取消')






















    elseif arg1=='Blizzard_ProfessionsCustomerOrders' then
        hooksecurefunc(ProfessionsCustomerOrdersCategoryButtonMixin, 'Init', function(self, categoryInfo, _, isRecraftCategory)
            if isRecraftCategory then
                set(self, '开始再造订单')
            elseif categoryInfo and categoryInfo.categoryName and e.strText[categoryInfo.categoryName] then
                set(self, e.strText[categoryInfo.categoryName])
            end
        end)
        set(ProfessionsCustomerOrdersFrameBrowseTab, '发布订单')
        set(ProfessionsCustomerOrdersFrameOrdersTab, '我的订单')


        ProfessionsCustomerOrdersFrame.BrowseOrders:HookScript('OnEvent', function (self, event)
            if event == "CRAFTINGORDERS_CUSTOMER_OPTIONS_PARSED" and not C_CraftingOrders.HasFavoriteCustomerOptions() then
                set(self.RecipeList.ResultsText, '小窍门：右键点击配方可以设置偏好。偏好的配方会在你打开商盟时立即出现。')
            end
        end)
        hooksecurefunc(ProfessionsCustomerOrdersFrame.BrowseOrders, 'StartSearch', function (self)
            if self.RecipeList.ResultsText:IsShown() then
                self.RecipeList.ResultsText:SetText('未找到配方')
            end
        end)
        set(ProfessionsCustomerOrdersFrame.BrowseOrders.SearchBar.SearchButton, '搜索')
        ProfessionsCustomerOrdersFrame.BrowseOrders.SearchBar.FavoritesSearchButton:HookScript("OnEnter", function(frame)
            GameTooltip:SetText('|cffffffff收藏')
            if not C_CraftingOrders.HasFavoriteCustomerOptions() then
                GameTooltip_AddNormalLine(GameTooltip, '你的偏好列表是空的。右键点击订单列表的一个物品可以将其添加到偏好中。')
            end
            GameTooltip:Show()
         end)






        set(ProfessionsCustomerOrdersFrame.Form.BackButton, '返回' )
        set(ProfessionsCustomerOrdersFrame.Form.MinimumQuality.Text, '最低品质：')
        set(ProfessionsCustomerOrdersFrame.Form.ReagentContainer.RecraftInfoText, '再造使你可以改变某些制造装备的附加材料和品质。')
        set(ProfessionsCustomerOrdersFrame.Form.AllocateBestQualityCheckBox.Text, '使用最高品质材料')

        set(ProfessionsCustomerOrdersFrame.Form.OrderRecipientDisplay.Crafter, '制作者：')
        hooksecurefunc(ProfessionsCustomerOrdersFrame.Form, 'SetupDurationDropDown', function(self)
            self.PaymentContainer.Duration:SetText('持续时间')
        end)

        set(ProfessionsCustomerOrdersFrame.Form.PaymentContainer.Tip, '佣金')
        set(ProfessionsCustomerOrdersFrame.Form.PaymentContainer.NoteEditBox.TitleBox.Title, '给制作者的信息：')
        ProfessionsCustomerOrdersFrame.Form.PaymentContainer.NoteEditBox.ScrollingEditBox.defaultText= '在此输入消息'
        set(ProfessionsCustomerOrdersFrame.Form.PaymentContainer.TimeRemaining, '过期时间')
        set(ProfessionsCustomerOrdersFrame.Form.PaymentContainer.PostingFee, '发布费')
        set(ProfessionsCustomerOrdersFrame.Form.PaymentContainer.TotalPrice, '总价')
        set(ProfessionsCustomerOrdersFrame.Form.PaymentContainer.ListOrderButton, '发布订单')
        set(ProfessionsCustomerOrdersFrame.Form.PaymentContainer.CancelOrderButton, '取消订单')

        ProfessionsCustomerOrdersFrame.Form.FavoriteButton:HookScript('OnEnter', function (self)
            local isFavorite = self:GetChecked()
            if not isFavorite and C_CraftingOrders.GetNumFavoriteCustomerOptions() >= Constants.CraftingOrderConsts.MAX_CRAFTING_ORDER_FAVORITE_RECIPES then
                GameTooltip_AddErrorLine(GameTooltip, '你的偏好列表已满。取消偏好一个配方后才能添加此配方。')
            else
                GameTooltip_AddHighlightLine(GameTooltip, isFavorite and '从偏好中移除' or '设置为偏好')
            end
            GameTooltip:Show()
        end)
        ProfessionsCustomerOrdersFrame.Form.RecraftSlot.InputSlot:HookScript('OnEnter', function()
            local self= ProfessionsCustomerOrdersFrame.Form
            local itemGUID = ProfessionsCustomerOrdersFrame.Form.transaction and self.transaction:GetRecraftAllocation()
            if itemGUID then
                if not self.committed then
                    GameTooltip_AddInstructionLine(GameTooltip, '|cnDISABLED_FONT_COLOR:左键点击替换此装备|r')
                    GameTooltip:Show()
                end
            elseif not self.order.recraftItemHyperlink then
                GameTooltip_AddInstructionLine(GameTooltip, '左键点击选择一件可用的装备来再造')
                GameTooltip:Show()
            end
        end)


        hooksecurefunc(ProfessionsCustomerOrdersFrame.Form, 'UpdateListOrderButton', function(self)
            if self.committed or self.pendingOrderPlacement then
                return
            end
            local errorText
            if self.order.isRecraft and not self.order.skillLineAbilityID then
                errorText = '你必须选择一个此订单要再造的物品'
            elseif self.order.isRecraft and self:GetPendingRecraftItemQuality() == #self.minQualityIDs and not self:AnyModifyingReagentsChanged() then
                errorText = '"你不能在不改变任何附加材料的情况下发布最高品质的物品的再造订单。'
            elseif not self:AreRequiredReagentsProvided() then
                errorText = '你没有发布此订单所需的材料。'
            elseif not self.transaction:HasMetPrerequisiteRequirements() then
                errorText = '一种或多种附加材料不满足必要条件。'
            elseif self.order.orderType == Enum.CraftingOrderType.Personal and self.OrderRecipientTarget:GetText() == "" then
                errorText = '你必须指定收件人才能发布个人订单。'
            elseif self.PaymentContainer.TipMoneyInputFrame:GetAmount() <= 0 then
                errorText = '你必须提供佣金。'
            elseif self.PaymentContainer.TotalPriceMoneyDisplayFrame:GetAmount() > GetMoney() then
                errorText = '金币不足，无法购买建筑。'
            end
            if errorText then
                local listOrderButton = self.PaymentContainer.ListOrderButton
                listOrderButton:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(listOrderButton, "ANCHOR_RIGHT")
                    GameTooltip_AddErrorLine(GameTooltip, errorText)
                    GameTooltip:Show()
                end)
            end
        end)

        ProfessionsCustomerOrdersFrame.Form:HookScript('OnEvent', function(self, event, ...)
            if event == "CRAFTINGORDERS_ORDER_PLACEMENT_RESPONSE" or event == "CRAFTINGORDERS_ORDER_CANCEL_RESPONSE" then
                local result = ...
                local success = (result == Enum.CraftingOrderResult.Ok)
                if not success then
                    local errorText
                    if event == "CRAFTINGORDERS_ORDER_PLACEMENT_RESPONSE" then
                        if result == Enum.CraftingOrderResult.InvalidTarget then
                            errorText = '该玩家不存在。'
                        elseif result == Enum.CraftingOrderResult.TargetCannotCraft then
                            errorText = '该玩家没有所需的专业来制作此订单。'
                        elseif result == Enum.CraftingOrderResult.MaxOrdersReached then
                            errorText = '订单数量已达上限。'
                        else
                            errorText = '制造订单生成失败。请稍后重试。'
                        end
                    elseif event == "CRAFTINGORDERS_ORDER_CANCEL_RESPONSE" then
                        errorText = (result == Enum.CraftingOrderResult.AlreadyClaimed) and '取消订单失败。订单被认领后就无法再取消。' or '取消订单失败。请稍后再试。'
                    end
                    UIErrorsFrame:AddExternalErrorMessage(errorText)
                end
            end
        end)

        ProfessionsCustomerOrdersFrame.Form.PaymentContainer.ViewListingsButton:SetScript("OnEnter", function(frame)
            GameTooltip_AddHighlightLine(GameTooltip, '查看类似的订单。')
            GameTooltip:Show()
         end)

        set(ProfessionsCustomerOrdersFrame.Form.TrackRecipeCheckBox.Text, LIGHTGRAY_FONT_COLOR:WrapTextInColorCode('追踪配方'))

        ProfessionsCustomerOrdersFrame.Form.AllocateBestQualityCheckBox:HookScript("OnEnter", function(button)
            local checked = button:GetChecked()
            if checked then
                GameTooltip_AddNormalLine(GameTooltip, '取消勾选后，总会使用可用的最低品质的材料。')
            else
                GameTooltip_AddNormalLine(GameTooltip, '勾选后，总会使用可用的最高品质的材料。')
            end
            GameTooltip:Show()
        end)


        hooksecurefunc(ProfessionsCustomerOrdersFrame.Form, 'InitSchematic', function(self)
            local professionName = C_TradeSkillUI.GetProfessionNameForSkillLineAbility(self.order.skillLineAbilityID)
            professionName= e.strText[professionName] or professionName
	        set(self.ProfessionText, format('%s 配方', professionName))
        end)

        hooksecurefunc(ProfessionsCustomerOrdersFrame.Form, 'Init', function(self, order)
            if not self.committed then
                set(self.ReagentContainer.Reagents.Label, '提供材料：')
                set(self.ReagentContainer.OptionalReagents.Label, '提供附加材料：')
            else
                if self.order.orderState ~= Enum.CraftingOrderState.Created then
                    local remainingTime = Professions.GetCraftingOrderRemainingTime(order.expirationTime)
                    local seconds = remainingTime >= 60 and remainingTime or 60 -- Never show < 1min
                    local timeRemainingText = Professions.OrderTimeLeftFormatter:Format(seconds)
                    timeRemainingText = format('%s （等待中）', timeRemainingText)
                    set(self.PaymentContainer.TimeRemainingDisplay.Text, timeRemainingText)
                end

                if not order.crafterName then
                    local crafterText
                    if self.order.orderState == Enum.CraftingOrderState.Created then
                        crafterText = '尚未被认领'
                    else
                        crafterText = '未领取'
                    end
                    set(self.OrderRecipientDisplay.CrafterValue, crafterText)
                end

                local orderTypeText
                if self.order.orderType == Enum.CraftingOrderType.Public then
                    orderTypeText = '公开订单'
                elseif self.order.orderType == Enum.CraftingOrderType.Guild then
                    orderTypeText = '公会订单'
                elseif self.order.orderType == Enum.CraftingOrderType.Personal then
                    orderTypeText = '个人订单'
                end
                set(self.OrderRecipientDisplay.PostedTo, orderTypeText)

                local orderStateText
                if self.order.orderState == Enum.CraftingOrderState.Created then
                    orderStateText = '未领取'
                elseif self.order.orderState == Enum.CraftingOrderState.Expired then
                    orderStateText = '订单过期'
                elseif self.order.orderState == Enum.CraftingOrderState.Canceled then
                    orderStateText = '订单取消'
                elseif self.order.orderState == Enum.CraftingOrderState.Rejected then
                    orderStateText = '订单被拒绝'
                elseif self.order.orderState == Enum.CraftingOrderState.Claimed then
                    orderStateText = '订单正在进行中'
                else
                    orderStateText = '|cnGREEN_FONT_COLOR:订单完成！|r'
                end
                set(self.OrderStateText, orderStateText)

                set(self.ReagentContainer.Reagents.Label, '提供的材料：')
                set(self.ReagentContainer.OptionalReagents.Label, '提供的附加材料：')
            end
        end)


        hooksecurefunc(ProfessionsCustomerOrdersFrame.Form, 'DisplayCurrentListings', function(self)
            local orders = C_CraftingOrders.GetCustomerOrders()
            if #orders == 0 then
                set(self.CurrentListings.OrderList.ResultsText, '没有发现订单')
            end
        end)
        ProfessionsCustomerOrdersFrame.Form.CurrentListings:SetTitle('当前列表')
        set(ProfessionsCustomerOrdersFrame.Form.CurrentListings.CloseButton, '关闭')


        hooksecurefunc(ProfessionsCustomerOrdersFrame, 'SelectMode', function(self, mode)
            if mode== ProfessionsCustomerOrdersMode.Browse then
	            self:SetTitle('发布制造订单')
            elseif mode== ProfessionsCustomerOrdersMode.Orders then
                self:SetTitle('我的订单')
            end
        end)
        set(ProfessionsCustomerOrdersFrame.MyOrdersPage.OrderList.ResultsText, '没有发现订单')



















    elseif arg1=='Blizzard_Professions' then--专业
        hooksecurefunc(ProfessionsFrame, 'SetTitle', function(self, skillLineName)
            if e.strText[skillLineName] then
                skillLineName= e.strText[skillLineName]
                if C_TradeSkillUI.IsTradeSkillGuild() then
                    self:SetTitleFormatted('公会%s"', skillLineName)
                else
                    local linked, linkedName = C_TradeSkillUI.IsTradeSkillLinked()
                    if linked and linkedName then
                        self:SetTitleFormatted("%s %s[%s]|r", TRADE_SKILL_TITLE:format(skillLineName), HIGHLIGHT_FONT_COLOR_CODE, linkedName)
                    else
                        self:SetTitleFormatted(TRADE_SKILL_TITLE, skillLineName)
                    end
                end
            elseif C_TradeSkillUI.IsTradeSkillGuild() then
                self:SetTitleFormatted('公会%s"', skillLineName)
            end
        end)

        hooksecurefunc(ProfessionsFrame, 'UpdateTabs', function(self)
            local recipesTab = self:GetTabButton(self.recipesTabID)
            set(recipesTab.Text, '配方', nil, true)

            recipesTab = self:GetTabButton(self.specializationsTabID)
            set(recipesTab.Text, '专精', nil, true)

            recipesTab = self:GetTabButton(self.craftingOrdersTabID )
            set(recipesTab.Text, '制造订单', nil, true)
        end)

        set(ProfessionsFrame.CraftingPage.RecipeList.SearchBox.Instructions, '搜索')
        set(ProfessionsFrame.CraftingPage.RecipeList.FilterButton, "过滤器")
        set(ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList.SearchBox.Instructions, '搜索')
        set(ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList.FilterButton, '过滤器')

        --Blizzard_ProfessionsCrafting.lua
        set(ProfessionsFrame.CraftingPage.ViewGuildCraftersButton, '查看工匠')

        local FailValidationReason = EnumUtil.MakeEnum("Cooldown", "InsufficientReagents", "PrerequisiteReagents", "Disabled", "Requirement", "LockedReagentSlot", "RecraftOptionalReagentLimit")
        local FailValidationTooltips = {
            [FailValidationReason.Cooldown] = '配方冷却中。',
            [FailValidationReason.InsufficientReagents] = '你的材料不足。',
            [FailValidationReason.PrerequisiteReagents] = '一种或多种附加材料不满足必要条件。',
            [FailValidationReason.Requirement] = '你不满足一个或更多的条件，不能制作此配方。',
            [FailValidationReason.LockedReagentSlot] = '你尚未解锁必需的附加材料栏位。',
            [FailValidationReason.RecraftOptionalReagentLimit] = '你尝试再造的物品有装备唯一限制。需要先脱下该装备后进行再造。',
        }
        hooksecurefunc(ProfessionsFrame.CraftingPage, 'ValidateControls', function(self)
            local currentRecipeInfo = self.SchematicForm:GetRecipeInfo()
            local isRuneforging = C_TradeSkillUI.IsRuneforging()
            if currentRecipeInfo ~= nil and currentRecipeInfo.learned and (Professions.InLocalCraftingMode() or C_TradeSkillUI.IsNPCCrafting() or isRuneforging)
                and not currentRecipeInfo.isRecraft
                and not currentRecipeInfo.isDummyRecipe and not currentRecipeInfo.isGatheringRecipe
            then
                local transaction = self.SchematicForm:GetTransaction()
                local isEnchant = transaction:IsRecipeType(Enum.TradeskillRecipeType.Enchant)
                local countMax = self:GetCraftableCount()
                if isEnchant then
                    self.CreateButton:SetTextToFit('附魔')
                    local quantity = math.max(1, countMax)
                    self.CreateAllButton:SetTextToFit(format('"%s [%d]', '附魔所有', quantity))
                elseif not currentRecipeInfo.abilityVerb and not currentRecipeInfo.alternateVerb then
                    if self.SchematicForm.recraftSlot and self.SchematicForm.recraftSlot.InputSlot:IsVisible() then
                        self.CreateButton:SetTextToFit('再造')
                    else
                        self.CreateButton:SetTextToFit('制造')
                    end
                    if not currentRecipeInfo.abilityAllVerb then
                        self.CreateAllButton:SetTextToFit(format('%s [%d]', '全部制造', countMax))
                    end
                end
                local enabled = true
                if PartialPlayTime() then
                    local reasonText = format('你的在线时间已经超过3小时。在目前阶段下，你不能这么做。在下线休息%d小时后，你的防沉迷时间将会清零。请退出游戏下线休息。', REQUIRED_REST_HOURS - math.floor(GetBillingTimeRested() / 60))
                    self:SetCreateButtonTooltipText(reasonText)
                    enabled = false
                elseif NoPlayTime() then
                    local reasonText = format('你的在线时间已经超过5小时。在目前阶段下，你不能这么做。在下线休息%d小时后，你的防沉迷时间将会清零。请退出游戏，下线休息和运动。', REQUIRED_REST_HOURS - math.floor(GetBillingTimeRested() / 60))
                    self:SetCreateButtonTooltipText(reasonText)
                    enabled = false
                end
                if enabled then
                    local failValidationReason = self:ValidateCraftRequirements(currentRecipeInfo, transaction, isRuneforging, countMax)
                    if failValidationReason and FailValidationTooltips[failValidationReason] then
                        self:SetCreateButtonTooltipText(FailValidationTooltips[failValidationReason])
                    end
                end
            end
        end)


        set(ProfessionsFrame.CraftingPage.SchematicForm.QualityDialog.AcceptButton, '接受')
        set(ProfessionsFrame.CraftingPage.SchematicForm.QualityDialog.CancelButton, '取消')
        ProfessionsFrame.CraftingPage.SchematicForm.QualityDialog:SetTitle('材料品质')

        set(ProfessionsFrame.CraftingPage.SchematicForm.AllocateBestQualityCheckBox.text, LIGHTGRAY_FONT_COLOR:WrapTextInColorCode('使用最高品质材料'))
        ProfessionsFrame.CraftingPage.SchematicForm.AllocateBestQualityCheckBox:HookScript("OnEnter", function(button)--Blizzard_ProfessionsRecipeSchematicForm.lua
            local checked = button:GetChecked()
            if checked then
                GameTooltip_AddNormalLine(GameTooltip, '取消勾选后，总会使用可用的最低品质的材料。')
            else
                GameTooltip_AddNormalLine(GameTooltip, '勾选后，总会使用可用的最高品质的材料。')
            end
            GameTooltip:Show()
        end)
        set(ProfessionsFrame.CraftingPage.SchematicForm.TrackRecipeCheckBox.text, LIGHTGRAY_FONT_COLOR:WrapTextInColorCode('追踪配方'))
        ProfessionsFrame.CraftingPage.SchematicForm.FavoriteButton:HookScript("OnEnter", function(button)
            GameTooltip_AddHighlightLine(GameTooltip, button:GetChecked() and '从偏好中移除' or '设置为偏好')
            GameTooltip:Show()
        end)
        ProfessionsFrame.CraftingPage.SchematicForm.FavoriteButton:HookScript("OnClick", function(button)
            GameTooltip_AddHighlightLine(GameTooltip, button:GetChecked() and '从偏好中移除' or '设置为偏好')
            GameTooltip:Show()
        end)
        ProfessionsFrame.CraftingPage.SchematicForm.FirstCraftBonus:SetScript("OnEnter", function()
            GameTooltip_AddNormalLine(GameTooltip, '首次制造此配方会教会你某种新东西。')
            GameTooltip:Show()
        end)

        hooksecurefunc(ProfessionsFrame.CraftingPage, 'Init', function(self)--Blizzard_ProfessionsCrafting.lua
            local minimized = ProfessionsUtil.IsCraftingMinimized()
            if minimized and self.MinimizedSearchBox:IsCurrentTextValidForSearch() then
                set(self.MinimizedSearchResults:GetTitleText(),  format('搜索结果\"%s\"(%d)', self.MinimizedSearchBox:GetText(), self.searchDataProvider:GetSize()))
            end
        end)

        hooksecurefunc(ProfessionsFrame.CraftingPage, 'ValidateControls', function(self)--Blizzard_ProfessionsCrafting.lua
            local currentRecipeInfo = self.SchematicForm:GetRecipeInfo()
            local isRuneforging = C_TradeSkillUI.IsRuneforging()
            if currentRecipeInfo ~= nil and currentRecipeInfo.learned and (Professions.InLocalCraftingMode() or C_TradeSkillUI.IsNPCCrafting() or isRuneforging)
                and not currentRecipeInfo.isRecraft
                and not currentRecipeInfo.isDummyRecipe and not currentRecipeInfo.isGatheringRecipe then

                local transaction = self.SchematicForm:GetTransaction()
                local isEnchant = transaction:IsRecipeType(Enum.TradeskillRecipeType.Enchant)

                local countMax = self:GetCraftableCount()

                if isEnchant then
                    self.CreateButton:SetTextToFit('附魔')
                    local quantity = math.max(1, countMax)
                    self.CreateAllButton:SetTextToFit(format('%s [%d]', '附魔所有', quantity))
                else
                    if currentRecipeInfo.abilityVerb then
                        -- abilityVerb is recipe-level override
                        --self.CreateButton:SetTextToFit(currentRecipeInfo.abilityVerb)
                    elseif currentRecipeInfo.alternateVerb then
                        -- alternateVerb is profession-level override
                        --self.CreateButton:SetTextToFit(currentRecipeInfo.alternateVerb)
                    elseif self.SchematicForm.recraftSlot and self.SchematicForm.recraftSlot.InputSlot:IsVisible() then
                        self.CreateButton:SetTextToFit('再造')
                    else
                        self.CreateButton:SetTextToFit('制造')
                    end

                    local createAllFormat
                    if currentRecipeInfo.abilityAllVerb then
                        -- abilityAllVerb is recipe-level override
                        createAllFormat = currentRecipeInfo.abilityAllVerb
                    else
                        createAllFormat = '全部制造'
                    end
                    self.CreateAllButton:SetTextToFit(format('%s [%d]', createAllFormat, countMax))
                end

                local enabled = true
                if PartialPlayTime() then
                    local reasonText = format('你的在线时间已经超过3小时。在目前阶段下，你不能这么做。在下线休息%d小时后，你的防沉迷时间将会清零。请退出游戏下线休息。', REQUIRED_REST_HOURS - math.floor(GetBillingTimeRested() / 60))
                    self:SetCreateButtonTooltipText(reasonText)
                    enabled = false
                elseif NoPlayTime() then
                    local reasonText = format('你的在线时间已经超过5小时。在目前阶段下，你不能这么做。在下线休息%d小时后，你的防沉迷时间将会清零。请退出游戏，下线休息和运动。', REQUIRED_REST_HOURS - math.floor(GetBillingTimeRested() / 60))
                    self:SetCreateButtonTooltipText(reasonText)
                    enabled = false
                end

                if enabled then
                    local failValidationReason = self:ValidateCraftRequirements(currentRecipeInfo, transaction, isRuneforging, countMax)
                    self:SetCreateButtonTooltipText(FailValidationTooltips[failValidationReason])
                end

            end
        end)

        set(ProfessionsFrame.SpecPage.ApplyButton, '应用改动')
        set(ProfessionsFrame.SpecPage.UnlockTabButton, '解锁专精')
        set(ProfessionsFrame.SpecPage.ViewTreeButton, '解锁专精')
        set(ProfessionsFrame.SpecPage.BackToPreviewButton, '后退')
        set(ProfessionsFrame.SpecPage.ViewPreviewButton, '综述')
        set(ProfessionsFrame.SpecPage.BackToFullTreeButton, '后退')
        ProfessionsFrame.SpecPage.UndoButton.tooltipText= '取消待定改动'
        set(ProfessionsFrame.SpecPage.DetailedView.SpendPointsButton, '运用知识')
        set(ProfessionsFrame.SpecPage.DetailedView.UnlockPathButton, '学习副专精')
        set(ProfessionsFrame.SpecPage.TreePreview.HighlightsHeader, '专精特色：')

        ProfessionsFrame.SpecPage.DetailedView.SpendPointsButton:HookScript("OnEnter", function()
            local self= ProfessionsFrame.SpecPage
            local spendCurrency = C_ProfSpecs.GetSpendCurrencyForPath(self:GetDetailedPanelNodeID())
            if spendCurrency ~= nil then
                local currencyTypesID = self:GetSpendCurrencyTypesID()
                if currencyTypesID then
                    local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyTypesID)
                    if self.treeCurrencyInfoMap[spendCurrency] ~= nil and self.treeCurrencyInfoMap[spendCurrency].quantity == 0 then
                        GameTooltip:SetText(format('|cnRED_FONT_COLOR:你没有可以消耗的|r|n|cffffffff%s|r|r', currencyInfo.name), nil, nil, nil, nil, true)
                        GameTooltip:Show()
                    end
                end
            end
        end)
        hooksecurefunc(ProfessionsFrame.SpecPage, 'ConfigureButtons', function(self)
            self.DetailedView.SpendPointsButton:SetScript("OnEnter", function()
                local spendCurrency = C_ProfSpecs.GetSpendCurrencyForPath(self:GetDetailedPanelNodeID())
                if spendCurrency ~= nil then
                    local currencyTypesID = self:GetSpendCurrencyTypesID()
                    if currencyTypesID then
                        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyTypesID)
                        if self.treeCurrencyInfoMap[spendCurrency] ~= nil and self.treeCurrencyInfoMap[spendCurrency].quantity == 0 then
                            GameTooltip:SetOwner(self.DetailedView.SpendPointsButton, "ANCHOR_RIGHT", 0, 0)
                            GameTooltip_AddErrorLine(GameTooltip, format('你没有可以消耗的%s。', currencyInfo.name))

                            GameTooltip:Show()
                        end
                    end
                end
            end)
        end)


        set(ProfessionsFrame.OrdersPage.BrowseFrame.SearchButton, '搜索')
        set(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.BackButton, '返回')

        set(ProfessionsFrame.OrdersPage.BrowseFrame.PublicOrdersButton.Text, '公开', nil, true)
        set(ProfessionsFrame.OrdersPage.BrowseFrame.PersonalOrdersButton.Text, '个人', nil, true)

        ProfessionsFrame.OrdersPage.BrowseFrame.OrdersRemainingDisplay:HookScript('OnEnter', function()
            local claimInfo = C_CraftingOrders.GetOrderClaimInfo(ProfessionsFrame.OrdersPage.professionInfo.profession)
            local tooltipText
            if claimInfo.secondsToRecharge then
                tooltipText = format('你目前还能完成|cnGREEN_FONT_COLOR:%d|r份公开订单。|cnGREEN_FONT_COLOR:%s|r后才有更多可用的订单。', claimInfo.claimsRemaining, SecondsToTime(claimInfo.secondsToRecharge))
            else
                tooltipText = format('你目前还能完成|cnGREEN_FONT_COLOR:%d|r份公开订单。', claimInfo.claimsRemaining)
            end
            GameTooltip_AddNormalLine(GameTooltip, tooltipText)
            GameTooltip:Show()
        end)

        local orderTypeTabTitles ={
            [Enum.CraftingOrderType.Public] = '公开',
            [Enum.CraftingOrderType.Guild] = '公会',
            [Enum.CraftingOrderType.Personal] = '个人',}
        local function SetTabTitleWithCount(tabButton, type, count)
            local title = orderTypeTabTitles[type]
            if tabButton and title then
                if type == Enum.CraftingOrderType.Public then
                    set(tabButton.Text, title)
                else
                    set(tabButton.Text, format("%s (%s)", title, count))
                end
            end
        end
        hooksecurefunc(ProfessionsFrame.OrdersPage, 'InitOrderTypeTabs', function(self)
            for _, typeTab in ipairs(self.BrowseFrame.orderTypeTabs) do
                SetTabTitleWithCount(typeTab, typeTab.orderType, 0)
            end
        end)
        ProfessionsFrame.OrdersPage:HookScript('OnEvent', function(self, event, ...)
            if event == "CRAFTINGORDERS_UPDATE_ORDER_COUNT" then
                local type, count = ...
                local tabButton
                if type == Enum.CraftingOrderType.Guild then
                    tabButton = self.BrowseFrame.GuildOrdersButton
                elseif type == Enum.CraftingOrderType.Personal then
                    tabButton = self.BrowseFrame.PersonalOrdersButton
                end
                SetTabTitleWithCount(tabButton, type, count)
            elseif event == "CRAFTINGORDERS_REJECT_ORDER_RESPONSE" then
                local result = ...
                local success = (result == Enum.CraftingOrderResult.Ok)
                if not success then
                    UIErrorsFrame:AddExternalErrorMessage('拒绝订单失败。请稍后再试。')
                end
            end
        end)

        hooksecurefunc(ProfessionsFrame.OrdersPage, 'StartDefaultSearch', function(self)
            if self.BrowseFrame.OrderList.ResultsText:IsShown() then
                set(self.BrowseFrame.OrderList.ResultsText, '小窍门：右键点击配方可以设置偏好。偏好的配方会在你打开你的公开订单时立即出现。')
            end
        end)
        hooksecurefunc(ProfessionsFrame.OrdersPage, 'UpdateOrdersRemaining', function(self)
            if self.professionInfo then
                local isPublic = self.orderType == Enum.CraftingOrderType.Public
                if isPublic and self.professionInfo and self.professionInfo.profession then
                    set(self.BrowseFrame.OrdersRemainingDisplay.OrdersRemaining, format('剩余订单：%s', C_CraftingOrders.GetOrderClaimInfo(self.professionInfo.profession).claimsRemaining))
                end
            end
        end)
        hooksecurefunc(ProfessionsFrame.OrdersPage, 'ShowGeneric', function(self)
            if self.BrowseFrame.OrderList.ResultsText:IsShown() then
                set(self.BrowseFrame.OrderList.ResultsText, '没有发现订单')
            end
        end)

        set(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.PostedByTitle, '订单发布人：')
        set(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.CommissionTitle, '佣金：')
        set(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.ConsortiumCutTitle, '财团分成：')
        set(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.FinalTipTitle, '你的分成：')
        set(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.TimeRemainingTitle, '剩余时间：')
        set(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.NoteBox.NoteTitle, '给制作者的信息：')
        set(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.StartOrderButton, '开始接单')
        set(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.DeclineOrderButton, '拒绝订单')
        set(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.ReleaseOrderButton, '取消订单')

        set(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.OptionalReagents.Label, '附加材料：')
        ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.OptionalReagents.labelText= '附加材料：'--Blizzard_ProfessionsRecipeSchematicForm.xml
        ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.AllocateBestQualityCheckBox:HookScript("OnEnter", function(button)
            local checked = button:GetChecked()
            if checked then
                GameTooltip:SetText('取消勾选后，总会使用可用的最低品质的材料。')
            else
                GameTooltip:SetText('勾选后，总会使用可用的最高品质的材料。')
            end
            GameTooltip:Show()
        end)


        hooksecurefunc(ProfessionsFrame.OrdersPage.OrderView, 'UpdateStartOrderButton', function(self)--Blizzard_ProfessionsCrafterOrderView.lua
            local errorReason
            local recipeInfo = C_TradeSkillUI.GetRecipeInfo(self.order.spellID)
            local profession = C_TradeSkillUI.GetChildProfessionInfo().profession
            local claimInfo = profession and C_CraftingOrders.GetOrderClaimInfo(profession)
            if self.order.customerGuid == UnitGUID("player") then
                errorReason = '你不能认领你自己的订单。'
            elseif claimInfo and self.order.orderType == Enum.CraftingOrderType.Public and claimInfo.claimsRemaining <= 0 and Professions.GetCraftingOrderRemainingTime(self.order.expirationTime) > Constants.ProfessionConsts.PUBLIC_CRAFTING_ORDER_STALE_THRESHOLD then
                errorReason = format('你目前无法认领更多的公开订单。%s后才有更多可用的订单。', SecondsToTime(claimInfo.secondsToRecharge))
            elseif not recipeInfo or not recipeInfo.learned or (self.order.isRecraft and not C_CraftingOrders.OrderCanBeRecrafted(self.order.orderID)) then
                errorReason = '你还没有学会此配方。'
            elseif not self.hasOptionalReagentSlots then
                errorReason = '你尚未解锁完成此订单所需的附加材料栏位。'
            end

            if errorReason then
                self.OrderInfo.StartOrderButton:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(self.OrderInfo.StartOrderButton, "ANCHOR_RIGHT")
                    GameTooltip_AddErrorLine(GameTooltip, errorReason)
                    GameTooltip:Show()
                end)
            else
                self.OrderInfo.StartOrderButton:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(self.OrderInfo.StartOrderButton, "ANCHOR_RIGHT")
                    GameTooltip_AddHighlightLine(GameTooltip, '此订单开始后，你有30分钟的时间来完成此订单。')
                    GameTooltip:Show()
                end)
            end
        end)


        ProfessionsFrame.OrdersPage.OrderView.OrderDetails.FulfillmentForm.NoteEditBox.ScrollingEditBox.defaultText= '在此输入消息'

        set(ProfessionsFrame.OrdersPage.OrderView.CompleteOrderButton, '完成订单')
        set(ProfessionsFrame.OrdersPage.OrderView.StartRecraftButton, '再造')
        set(ProfessionsFrame.OrdersPage.OrderView.StopRecraftButton, '取消再造')
        set(ProfessionsFrame.OrdersPage.OrderView.DeclineOrderDialog.ConfirmationText, '你确定想拒绝此订单吗？')
        set(ProfessionsFrame.OrdersPage.OrderView.DeclineOrderDialog.NoteEditBox.TitleBox.Title, '拒绝原因：')
        set(ProfessionsFrame.OrdersPage.OrderView.DeclineOrderDialog.CancelButton, '否')
        set(ProfessionsFrame.OrdersPage.OrderView.DeclineOrderDialog.ConfirmButton, '是')

        set(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.AllocateBestQualityCheckBox.text,  LIGHTGRAY_FONT_COLOR:WrapTextInColorCode('使用最高品质材料'))



        hooksecurefunc(ProfessionsFrame.OrdersPage.OrderView, 'InitRegions', function(self)
            self.OrderDetails.FulfillmentForm.OrderCompleteText:SetText('订单完成！')
            self.DeclineOrderDialog:SetTitle('拒绝订单')
        end)

        ProfessionsFrame.OrdersPage.OrderView:HookScript('OnEvent', function(self, event, ...)
            if event == "CRAFTINGORDERS_CLAIM_ORDER_RESPONSE" then
                local result, orderID = ...
                if orderID == self.order.orderID then
                    local success = result == Enum.CraftingOrderResult.Ok
                    if not success then
                        if result == Enum.CraftingOrderResult.CannotClaimOwnOrder then
                            UIErrorsFrame:AddExternalErrorMessage('你不能认领你自己的制造订单。')
                        elseif result == Enum.CraftingOrderResult.OutOfPublicOrderCapacity then
                            UIErrorsFrame:AddExternalErrorMessage('你没有剩余的每日公开订单，现在只能完成即将过期的订单。')
                        else
                            UIErrorsFrame:AddExternalErrorMessage('此订单已不可用。')
                        end
                    end
                end
            elseif event == "CRAFTINGORDERS_RELEASE_ORDER_RESPONSE" or event == "CRAFTINGORDERS_REJECT_ORDER_RESPONSE" then
                local result, orderID = ...
                if orderID == self.order.orderID then
                    local success = result == Enum.CraftingOrderResult.Ok
                    if not success then
                        UIErrorsFrame:AddExternalErrorMessage('制造订单运行失败。请稍后重试。')
                    end
                end
            elseif event == "CRAFTINGORDERS_FULFILL_ORDER_RESPONSE" then
                local result, orderID = ...
                if orderID == self.order.orderID then
                    local success = result == Enum.CraftingOrderResult.Ok
                    if not success then
                        UIErrorsFrame:AddExternalErrorMessage('制造订单运行失败。请稍后重试。')
                    end
                end
            elseif event == "CRAFTINGORDERS_UNEXPECTED_ERROR" then
                UIErrorsFrame:AddExternalErrorMessage('制造订单运行失败。请稍后重试。')
            end
        end)

        hooksecurefunc(ProfessionsFrame.OrdersPage.OrderView, 'UpdateCreateButton', function(self)
            local transaction = self.OrderDetails.SchematicForm.transaction
            local recipeInfo = C_TradeSkillUI.GetRecipeInfo(self.order.spellID)
            if transaction:IsRecipeType(Enum.TradeskillRecipeType.Enchant) then
                self.CreateButton:SetText('附魔')
            else
                if recipeInfo and recipeInfo.abilityVerb then
                    --self.CreateButton:SetText(recipeInfo.abilityVerb)
                elseif recipeInfo and recipeInfo.alternateVerb then
                    -- alternateVerb is profession-level override
                    --self.CreateButton:SetText(recipeInfo.alternateVerb)
                elseif self:IsRecrafting() then
                    self.CreateButton:SetText('再造')
                else
                    self.CreateButton:SetText('制造')
                end
            end


            local errorReason
            if Professions.IsRecipeOnCooldown(self.order.spellID) then
                errorReason = '配方冷却中。'
            elseif not transaction:HasMetAllRequirements() then
                errorReason = '你的材料不足。'
            elseif self.order.minQuality and self.OrderDetails.SchematicForm.Details:GetProjectedQuality() and self.order.minQuality > self.OrderDetails.SchematicForm.Details:GetProjectedQuality() then
                local smallIcon = true
                errorReason = format('此订单要求的最低品质是%s', Professions.GetChatIconMarkupForQuality(self.order.minQuality, smallIcon))
            end
            if not errorReason then
                self.CreateButton:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(self.CreateButton, "ANCHOR_RIGHT")
                    GameTooltip_AddErrorLine(GameTooltip, errorReason)
                    GameTooltip:Show()
                end)
            end
        end)


        hooksecurefunc(ProfessionsFrame.OrdersPage.OrderView, 'SetOrder', function(self)
            local warningText
            if self.order.reagentState == Enum.CraftingOrderReagentsType.All then
                warningText = '所有材料都由顾客提供。'
            elseif self.order.reagentState == Enum.CraftingOrderReagentsType.Some then
                warningText = '将由你来提供某些材料。'
            elseif self.order.reagentState == Enum.CraftingOrderReagentsType.None then
                warningText = '将由你来提供全部材料。'
            end
            set(self.OrderInfo.OrderReagentsWarning.Text, warningText)
        end)



        ProfessionsFrame.CraftingPage.CraftingOutputLog:SetTitle('制作成果')

        set(ProfessionsFrame.CraftingPage.SchematicForm.Details.FinishingReagentSlotContainer.Label, '成品材料：')
        set(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.Details.FinishingReagentSlotContainer.Label, '成品材料：')
        ProfessionsFrame.CraftingPage.SchematicForm.Details:HookScript('OnShow', function(self)
            set(self.Label, '制作详情')
            set(self.StatLines.DifficultyStatLine.LeftLabel, '配方难度：')
            set(self.StatLines.SkillStatLine.LeftLabel, '技能：')
        end)

        ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.Details:HookScript('OnShow', function(self)
            set(self.Label, '制作详情')
            set(self.StatLines.DifficultyStatLine.LeftLabel, '配方难度：')
            set(self.StatLines.SkillStatLine.LeftLabel, '技能：')
        end)




        --set(ProfessionsFrame.CraftingPage.SchematicForm.Details.StatLines.DifficultyStatLine.LeftLabel, '配方难度：')
        --set(ProfessionsFrame.CraftingPage.SchematicForm.Details.StatLines.SkillStatLine.LeftLabel, '技能：')

        hooksecurefunc(ProfessionsCrafterDetailsStatLineMixin, 'SetLabel', function(self, label)--Blizzard_ProfessionsRecipeCrafterDetails.lua
            if label== PROFESSIONS_CRAFTING_STAT_TT_CRIT_HEADER then
                set(self.LeftLabel, '灵感')
            elseif label== PROFESSIONS_CRAFTING_STAT_TT_RESOURCE_RETURN_HEADER then
                set(self.LeftLabel, '充裕')
            elseif label== ITEM_MOD_CRAFTING_SPEED_SHORT then
                set(self.LeftLabel, '制作速度')
            elseif label== PROFESSIONS_OUTPUT_MULTICRAFT_TITLE then
                set(self.LeftLabel, '产能')
            end

        end)

        --[[hooksecurefunc(Professions, 'SetupProfessionsCurrencyTooltip', function(currencyInfo, currencyCount)--lizzard_Professions.lua
            if currencyInfo and currencyInfo.name then
                GameTooltip:SetText('|cffffffff'..currencyInfo.name..'|r')
                GameTooltip_AddNormalLine(GameTooltip, currencyInfo.description)
                GameTooltip_AddBlankLineToTooltip(GameTooltip)

                local count = currencyCount or currencyInfo.quantity
                GameTooltip_AddHighlightLine(GameTooltip, format('|cnNORMAL_FONT_COLOR:总计：|r %d', count))
            end
        end)]]

        --Blizzard_ProfessionsSpecializations.lua
        dia("PROFESSIONS_SPECIALIZATION_CONFIRM_PURCHASE_TAB", {button1 = '是', button2 = '取消'})
        hookDia("PROFESSIONS_SPECIALIZATION_CONFIRM_PURCHASE_TAB", 'OnShow', function(self, info)
            local headerText = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(format('学习%s？', info.specName).."\n\n")
            local bodyKey = info.hasAnyConfigChanges and '所有待定的改动都会在解锁此专精后进行应用。您确定要学习%s副专精吗？' or '您确定想学习%s专精吗？您将来可以在%s专业里更加精进后选择额外的专精。'
            local bodyText = NORMAL_FONT_COLOR:WrapTextInColorCode(bodyKey:format(info.specName, info.profName))
            self.text:SetText(headerText..bodyText)
            self.text:Show()
        end)

        --Blizzard_ProfessionsFrame.lua
        dia("PROFESSIONS_SPECIALIZATION_CONFIRM_CLOSE", {text = '你想在离开前应用改动吗？', button1 = '是', button2 = '否',})






















    elseif arg1=='Blizzard_Collections' then--收藏
        hooksecurefunc('CollectionsJournal_UpdateSelectedTab', function(self)--设置，标题
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
            set(MountJournalSearchBox.Instructions, '搜索')
            set(MountJournalFilterButtonText, '过滤器')
            set(MountJournal.MountCount.Label, '坐骑')
            set(MountJournalSummonRandomFavoriteButton.spellname, "随机召唤\n偏好坐骑")--hooksecurefunc('MountJournalSummonRandomFavoriteButton_OnLoad', function(self)
            set(MountJournal.MountDisplay.ModelScene.TogglePlayer.TogglePlayerText, '显示角色')
            hooksecurefunc('MountJournal_OnLoad', function(self)
	            self.SlotRequirementLabel:SetFormattedText('坐骑装备在%s级解锁', C_MountJournal.GetMountEquipmentUnlockLevel())
            end)
            hooksecurefunc('MountJournal_InitializeEquipmentSlot', function(self, item)
                if not item then
                    set(self.SlotLabel, '使用坐骑装备来强化你的坐骑。')
                end
            end)
            hooksecurefunc('MountJournal_UpdateMountDisplay', function()
                if ( MountJournal.selectedMountID ) then
                    if (  C_MountJournal.NeedsFanfare(MountJournal.selectedMountID) ) then
                        set(MountJournal.MountButton, '打开')
                    elseif ( select(4, C_MountJournal.GetMountInfoByID(MountJournal.selectedMountID)) ) then
                        set(MountJournal.MountButton, '解散坐骑')
                    else
                        set(MountJournal.MountButton, '召唤坐骑')
                    end
                end
            end)
            MountJournalMountButton:HookScript('OnEnter', function()
                local needsFanFare = MountJournal.selectedMountID and C_MountJournal.NeedsFanfare(MountJournal.selectedMountID)
                if needsFanFare then
                    GameTooltip_AddNormalLine(GameTooltip, '打开即可获得你的崭新坐骑。', true)
                else
                    GameTooltip_AddNormalLine(GameTooltip, '召唤或解散你选定的坐骑。', true)
                end
                GameTooltip:Show()
            end)

        set(CollectionsJournalTab2, '宠物手册')
            set(PetJournalSearchBox.Instructions, '搜索')
            set(PetJournalFilterButtonText, '过滤器')
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
                local queueState = C_PetBattles.GetPVPMatchmakingInfo()
                if ( queueState == "queued" or queueState == "proposal" or queueState == "suspended" ) then
                    PetJournalFindBattle:SetText('离开队列')
                else
                    PetJournalFindBattle:SetText('搜寻战斗')
                end
            end
            hooksecurefunc('PetJournalFindBattle_Update', set_PetJournalFindBattle)
            set_PetJournalFindBattle()
            set(PetJournal.PetCount.Label, '宠物')
            set(PetJournalSummonRandomFavoritePetButtonSpellName, '召唤随机\n偏好战斗宠物')
            set(PetJournalHealPetButtonSpellName, '复活\n战斗宠物')
        set(CollectionsJournalTab3, '玩具箱')
            set(ToyBox.searchBox.Instructions, '搜索')
            set(ToyBoxFilterButtonText, '过滤器')
            hooksecurefunc(ToyBox.PagingFrame, 'Update', function(self)--Blizzard_CollectionTemplates.lua
                self.PageText:SetFormattedText('%d/%d页', self.currentPage, self.maxPages)
            end)
        set(CollectionsJournalTab4, '传家宝')
            set(HeirloomsJournalText, '过滤器')
            set(HeirloomsJournalSearchBox.Instructions, '搜索')
            hooksecurefunc(HeirloomsJournal.PagingFrame, 'Update', function(self)--Blizzard_CollectionTemplates.lua
                self.PageText:SetFormattedText('%d/%d页', self.currentPage, self.maxPages)
            end)
        set(CollectionsJournalTab5, '外观')
            set(WardrobeCollectionFrameSearchBox.Instructions, '搜索')
            hooksecurefunc(WardrobeCollectionFrame, 'SetContainer', function(self, parent)
                if parent == CollectionsJournal then
                    set(self.FilterButton, '过滤器')
                elseif parent == WardrobeFrame then
                    set(self.FilterButton, '来源')
                end
            end)
            set(WardrobeCollectionFrame.FilterButton.text, '过滤器')
            set(WardrobeCollectionFrameTab1, '物品')
                hooksecurefunc(WardrobeCollectionFrame.ItemsCollectionFrame.PagingFrame, 'Update', function(self)--Blizzard_CollectionTemplates.lua
                    self.PageText:SetFormattedText('%d/%d页', self.currentPage, self.maxPages)
                end)
            set(WardrobeCollectionFrameTab2, '套装')
                hooksecurefunc(WardrobeCollectionFrame.SetsTransmogFrame.PagingFrame, 'Update', function(self)--Blizzard_CollectionTemplates.lua
                    self.PageText:SetFormattedText('%d/%d页', self.currentPage, self.maxPages)
                end)

        dia("BATTLE_PET_RENAME", {text = '重命名', button1 = '接受', button2 = '取消', button3 = '默认'})
        dia("BATTLE_PET_PUT_IN_CAGE", {text = '把这只宠物放入笼中？', button1 = '确定', button2 = '取消'})
        dia("BATTLE_PET_RELEASE", {text = "\n\n你确定要释放|cffffd200%s|r吗？\n\n", button1 = '确定', button2 = '取消'})


        dia("DIALOG_REPLACE_MOUNT_EQUIPMENT", {text = '你确定要替换此坐骑装备吗？已有的坐骑装备将被摧毁。', button1 = '是', button2 = '否'})

        --试衣间
        set(WardrobeFrameTitleText, '幻化')
        set(WardrobeOutfitDropDown.SaveButton, '保存')
        set(WardrobeTransmogFrame.ApplyButton, '应用')
        set(WardrobeOutfitEditFrame.Title, '输入外观方案名称：')
        set(WardrobeOutfitEditFrame.AcceptButton, '接受')
        set(WardrobeOutfitEditFrame.CancelButton, '取消')
        set(WardrobeOutfitEditFrame.DeleteButton, '删除外观方案')
















    elseif arg1=='Blizzard_EncounterJournal' then--冒险指南
        set(EncounterJournalTitleText, '冒险指南')

        if EncounterJournalMonthlyActivitiesTab then
            set(EncounterJournalMonthlyActivitiesTab, '旅行者日志')
                EncounterJournalMonthlyActivitiesTab:SetScript('OnEnter', function()
                    if not C_PlayerInfo.IsTravelersLogAvailable() then
                        local tradingPostLocation = e.Player.faction == "Alliance" and '暴风城' or '奥格瑞玛'
                        GameTooltip_AddBlankLineToTooltip(GameTooltip)
                        GameTooltip_AddErrorLine(GameTooltip, format('拜访%s的商栈，查看旅行者日志。', tradingPostLocation))
                        if AreMonthlyActivitiesRestricted() then
                            GameTooltip_AddBlankLineToTooltip(GameTooltip)
                            GameTooltip_AddErrorLine(GameTooltip, '需要可用的游戏时间。')
                        end

                        GameTooltip:Show()
                    end
                end)
            end

        set(EncounterJournalSuggestTab, '推荐玩法')
        set(EncounterJournalDungeonTab, '地下城')
        set(EncounterJournalRaidTab, '团队副本')
        set(EncounterJournalLootJournalTab, '套装物品')
        set(EncounterJournalSearchBox.Instructions, '搜索')

        hooksecurefunc('EJInstanceSelect_UpdateTitle', function(tabId)
            local text
            if ( tabId == EncounterJournal.suggestTab:GetID()) then
                text= '推荐玩法'
            elseif ( tabId == EncounterJournal.raidsTab:GetID()) then
                text= '团队副本'
            elseif ( tabId == EncounterJournal.dungeonsTab:GetID()) then
                text= '地下城'
            --elseif ( tabId == EncounterJournal.MonthlyActivitiesTab:GetID()) then
            elseif (tabId == EncounterJournal.LootJournalTab:GetID()) then
                text= '套装物品'
            end
            if text then
                set(EncounterJournal.instanceSelect.Title, text)
            end
        end)
        if EncounterJournalMonthlyActivitiesFrame and EncounterJournalMonthlyActivitiesFrame.HeaderContainer then
            set(EncounterJournalMonthlyActivitiesFrame.HeaderContainer.Title, '旅行者日志')
        end

        set(EncounterJournalEncounterFrameInfoFilterToggle.Text, '过滤器')
        set(EncounterJournalEncounterFrameInstanceFrameMapButtonText, '显示\n地图')
        set(EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle, '综述')

        local function EncounterJournal_SetupIconFlags(sectionID, infoHeaderButton, index)--Blizzard_EncounterJournal.lua
            local iconFlags = C_EncounterJournal.GetSectionIconFlags(sectionID)
            for index2, icon in ipairs(infoHeaderButton.icons or {}) do
                local iconFlag = iconFlags and iconFlags[index2]
                if iconFlag then
                    local tab={
                        [0] = "坦克预警",
                        [1] = "伤害输出预警",
                        [10] = "疾病效果",
                        [11] = "激怒",
                        [12] = "史诗难度",
                        [13] = "流血",
                        [2] = "治疗预警",
                        [3] = "英雄难度",
                        [4] = "灭团技",
                        [5] = "重要",
                        [6] = "可打断技能",
                        [7] = "法术效果",
                        [8] = "诅咒效果",
                        [9] = "中毒效果",
                    }
                    if tab[iconFlag] then
                        icon.tooltipTitle = tab[iconFlag]--_G["ENCOUNTER_JOURNAL_SECTION_FLAG"..iconFlag]
                        if index then
                            if iconFlag==1 then
                                set(infoHeaderButton.title, '伤害')
                            elseif iconFlag==2 then
                                set(infoHeaderButton.title, '治疗者')
                            elseif iconFlag==0 then
                                set(infoHeaderButton.title, '坦克')
                            end
                        end
                    end
                end
            end
        end
        hooksecurefunc('EncounterJournal_SetUpOverview', function(self, overviewSectionID, index)
            local infoHeader= self.overviews[index]
            --local sectionInfo = C_EncounterJournal.GetSectionInfo(overviewSectionID)
            if infoHeader and infoHeader.button and overviewSectionID then
                EncounterJournal_SetupIconFlags(overviewSectionID, infoHeader.button, index)
            end
        end)
        hooksecurefunc('EncounterJournal_ToggleHeaders', function()
            for _, infoHeader in pairs(EncounterJournal.encounter.usedHeaders or {}) do
                if infoHeader.myID and  infoHeader.button then
                    --local sectionInfo = C_EncounterJournal.GetSectionInfo(infoHeader.myID)
                    EncounterJournal_SetupIconFlags(infoHeader.myID, infoHeader.button)
                end
            end
        end)













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
                    set(btn.Button.Label, e.strText[btn.Button.name])
                end
            end
        end)










    elseif arg1=='Blizzard_MacroUI' then
        set(MacroFrameTab1, '通用宏')
        set(MacroFrameTab2, '专用宏', 0.3)
        set(MacroSaveButton, '保存')
        set(MacroCancelButton, '取消')
        set(MacroDeleteButton, '删除')
        set(MacroNewButton, '新建')
        set(MacroExitButton, '退出')

        dia("CONFIRM_DELETE_SELECTED_MACRO", {text= '确定要删除这个宏吗？', button1= '是', button2= '取消'})










    elseif arg1=='Blizzard_Communities' then--公会和社区
        set(CommunitiesFrame.CommunitiesControlFrame.GuildRecruitmentButton, '公会招募')
        set(CommunitiesFrame.InviteButton, '邀请成员')
        set(CommunitiesFrame.CommunitiesControlFrame.GuildControlButton, '公会设置')
        hooksecurefunc(CommunitiesFrame.CommunitiesControlFrame, 'Update', function(self)
            if self.CommunitiesSettingsButton:IsShown() then
                local communitiesFrame = self:GetCommunitiesFrame()
                local clubId = communitiesFrame:GetSelectedClubId()
                if clubId then
                    local clubInfo = C_Club.GetClubInfo(clubId)
                    if clubInfo then
                        self.CommunitiesSettingsButton:SetText(clubInfo.clubType == Enum.ClubType.BattleNet and '群组设置' or '社区设置')
                    end
                end
            end
            set(CommunitiesFrame.CommunitiesControlFrame.CommunitiesSettingsButton, '社区设置')
        end)

        set(CommunitiesFrame.RecruitmentDialog.DialogLabel, '招募')
        set(CommunitiesFrame.RecruitmentDialog.ShouldListClub.Label, '在公会查找器里列出我的公会')
        set(ClubFinderClubFocusDropdown.Label, '活动倾向')
        --set(ClubFinderLookingForDropdown.Label, '寻找：')
        --set(ClubFinderLanguageDropdown.Label, '语言')
        set(CommunitiesFrame.RecruitmentDialog.RecruitmentMessageFrame.Label, '招募信息')
        set(CommunitiesFrame.RecruitmentDialog.MaxLevelOnly.Label, '只限满级')
        set(CommunitiesFrame.RecruitmentDialog.MinIlvlOnly.Label, '最低物品等级')
        set(CommunitiesFrame.RecruitmentDialog.Accept, '接受')
        set(CommunitiesFrame.RecruitmentDialog.Cancel, '取消')
        set(CommunitiesFrame.NotificationSettingsDialog.ScrollFrame.Child.QuickJoinButton.Text, '快速加入通知')
        --set(CommunitiesFrame.RecruitmentDialog.MaxLevelOnly, '')

















    elseif arg1=="Blizzard_GuildBankUI" then--公会银行
        set(GuildBankFrameTab1, '公会银行')
            set(GuildBankFrame.WithdrawButton, '提取')
            set(GuildBankFrame.DepositButton, '存放')
            set(GuildBankMoneyLimitLabel, '可用数量：')
            hooksecurefunc(GuildBankFrame, 'UpdateTabs', function(self)--Blizzard_GuildBankUI.lua
                local name, isViewable, canDeposit, numWithdrawals, remainingWithdrawals, disableAll, titleText, withdrawalText
                local numTabs = GetNumGuildBankTabs()
                local currentTab = GetCurrentGuildBankTab()
                -- Set buyable tab
                local tabToBuyIndex
                if ( numTabs < MAX_BUY_GUILDBANK_TABS ) then
                    tabToBuyIndex = numTabs + 1
                end
                -- Disable and gray out all tabs if in the moneyLog since the tab is irrelevant
                if ( self.mode == "moneylog" ) then
                    disableAll = 1
                end
                for i=1, MAX_GUILDBANK_TABS do
                    local tab = self.BankTabs[i]
                    local tabButton = tab.Button
                    name, _, isViewable = GetGuildBankTabInfo(i)
                    if ( not name or name == "" ) then
                        name = format('标签%d', i)
                    end
                    if ( i == tabToBuyIndex and IsGuildLeader() ) then
                        tabButton.tooltip = '购买新的公会银行标签'
                        if ( disableAll or self.mode == "log" or self.mode == "tabinfo" ) then
                        else
                            if ( i == currentTab ) then
                                titleText = '购买新的公会银行标签'
                            end
                        end
                    elseif ( i > numTabs ) then
                    else
                        if ( isViewable ) then
                            if ( i == currentTab ) then
                                withdrawalText = name
                                titleText =  name
                            end
                        end
                    end
                end

                -- Set Title
                if ( self.mode == "moneylog" ) then
                    titleText = '金币记录'
                    withdrawalText = nil
                elseif ( self.mode == "log" ) then
                    if ( titleText ) then
                        titleText = format('%s 记录', titleText)
                    end
                elseif ( self.mode == "tabinfo" ) then
                    withdrawalText = nil
                    if ( titleText ) then
                        titleText = format('%s 信息', titleText)
                    end
                end
                -- Get selected tab info
                name, _, _, canDeposit, numWithdrawals, remainingWithdrawals = GetGuildBankTabInfo(currentTab)
                if ( titleText and (self.mode ~= "moneylog" and titleText ~= BUY_GUILDBANK_TAB) ) then
                    local access
                    if ( not canDeposit and numWithdrawals == 0 ) then
                        access = '|cffff2020（锁定）|r'
                    elseif ( not canDeposit ) then
                        access = '|cffff2020（只能提取）|r'
                    elseif ( numWithdrawals == 0 ) then
                        access = '|cffff2020（只能存放）|r'
                    else
                        access = '|cff20ff20（全部权限）|r'
                    end
                    titleText = titleText.."  "..access
                end
                if ( titleText ) then
                    self.TabTitle:SetText(titleText)
                end
                if ( withdrawalText ) then
                    local stackString
                    if ( remainingWithdrawals > 0 ) then
                        stackString = format('%d 堆', remainingWithdrawals)
                    elseif ( remainingWithdrawals == 0 ) then
                        stackString = '无'
                    else
                        stackString = '无限'
                    end
                    self.LimitLabel:SetText(format('%s的每日提取额度剩余：|cffffffff%s|r', withdrawalText, stackString))
                end
            end)
        set(GuildBankFrameTab2, '记录')
        set(GuildBankFrameTab3, '金币记录')
        set(GuildBankFrameTab4, '信息')
            set(GuildBankInfoSaveButton, '保存改变')














    elseif arg1=='Blizzard_InspectUI' then--玩家, 观察角色, 界面
        set(InspectFrameTab1, '角色')
        --pvp
            hooksecurefunc('InspectPVPFrame_Update', function()
                local _, _, _, _, lifetimeHKs, _, honorLevel = GetInspectHonorData()
                InspectPVPFrame.HKs:SetFormattedText('|cffffd200荣誉消灭：|r %d', lifetimeHKs or 0)
                if C_SpecializationInfo.CanPlayerUsePVPTalentUI() then
                    InspectPVPFrame.HonorLevel:SetFormattedText('荣誉等级：%d', honorLevel)
                end
            end)
        set(InspectFrameTab3, '公会')




















    elseif arg1=='Blizzard_PVPUI' then--地下城和团队副本, PVP
        hooksecurefunc('PVPQueueFrame_UpdateTitle', function()--Blizzard_PVPUI.lua
            if ConquestFrame.seasonState == 2 then--SEASON_STATE_PRESEASON
                PVEFrame:SetTitle('PvP（季前赛）')
            elseif ConquestFrame.seasonState == 1 then--SEASON_STATE_OFFSEASON
                PVEFrame:SetTitle('玩家VS玩家（休赛期）')
            else
                local expName = _G["EXPANSION_NAME"..GetExpansionLevel()]
                PVEFrame:SetTitleFormatted('玩家VS玩家 '..(e.strText[expName] or expName)..' 第 %d 赛季', PVPUtil.GetCurrentSeasonNumber())
            end
        end)
        set(PVPQueueFrameCategoryButton1.Name, '快速比赛')
            hooksecurefunc('HonorFrameBonusFrame_Update', function()--Blizzard_PVPUI.lua
                set(HonorFrame.BonusFrame.RandomBGButton.Title, '随机战场')
                set(HonorFrame.BonusFrame.RandomEpicBGButton.Title, '随机史诗战场')
                set(HonorFrame.BonusFrame.Arena1Button.Title, '竞技场练习赛')
            end)
        set(PVPQueueFrameCategoryButton2.Name, '评级')
        set(PVPQueueFrameCategoryButton3.Name, '预创建队伍')
        set(PVPQueueFrame.NewSeasonPopup.Leave, '关闭')

        hooksecurefunc('HonorFrame_UpdateQueueButtons', function()
            local HonorFrame = HonorFrame
            local canQueue
            local arenaID
            local isBrawl
            local isSpecialBrawl
            if ( HonorFrame.type == "specific" ) then
                if ( HonorFrame.SpecificScrollBox.selectionID ) then
                    canQueue = true
                end
            elseif ( HonorFrame.type == "bonus" ) then
                if ( HonorFrame.BonusFrame.selectedButton ) then
                    canQueue = HonorFrame.BonusFrame.selectedButton.canQueue
                    arenaID = HonorFrame.BonusFrame.selectedButton.arenaID
                    isBrawl = HonorFrame.BonusFrame.selectedButton.isBrawl
                    isSpecialBrawl = HonorFrame.BonusFrame.selectedButton.isSpecialBrawl
                end
            end

            local disabledReason

            if arenaID then
                local battlemasterListInfo = C_PvP.GetSkirmishInfo(arenaID)
                if battlemasterListInfo then
                    local groupSize = GetNumGroupMembers()
                    local minPlayers = battlemasterListInfo.minPlayers
                    local maxPlayers = battlemasterListInfo.maxPlayers
                    if groupSize > maxPlayers then
                        canQueue = false
                        disabledReason = format('要进入该竞技场，你的团队需要减少%d名玩家。', groupSize - maxPlayers)
                    elseif groupSize < minPlayers then
                        canQueue = false
                        disabledReason = format('要进入该竞技场，你的团队需要增加%d名玩家。', minPlayers - groupSize)
                    end
                end
            end

            if (isBrawl or isSpecialBrawl) and not canQueue then
                if IsInGroup(LE_PARTY_CATEGORY_HOME) then
                    local brawlInfo = isSpecialBrawl and C_PvP.GetSpecialEventBrawlInfo() or C_PvP.GetAvailableBrawlInfo() or {}
                    if brawlInfo then
                        disabledReason = format('你的小队未满足最低等级要求（%s）。', isSpecialBrawl and brawlInfo.minLevel or GetMaxLevelForPlayerExpansion())
                    end
                else
                    disabledReason = '你的级别不够。'
                end
            end

            if isBrawl or isSpecialBrawl and canQueue then
                local brawlInfo = isSpecialBrawl and C_PvP.GetSpecialEventBrawlInfo() or C_PvP.GetAvailableBrawlInfo() or {}
                local brawlHasMinItemLevelRequirement = brawlInfo and brawlInfo.brawlType == Enum.BrawlType.SoloRbg
                if (IsInGroup(LE_PARTY_CATEGORY_HOME)) then
                    if(brawlInfo and not brawlInfo.groupsAllowed) then
                        canQueue = false
                        disabledReason = '你不能在队伍中那样做。'
                    end
                    if (brawlHasMinItemLevelRequirement and brawlInfo.groupsAllowed) then
                        local brawlMinItemLevel = brawlInfo.minItemLevel
                        local partyMinItemLevel, playerWithLowestItemLevel = C_PartyInfo.GetMinItemLevel(Enum.AvgItemLevelCategories.PvP)
                        if (UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) and partyMinItemLevel < brawlMinItemLevel) then
                            canQueue = false
                            disabledReason = format('"%1$s需要更高的平均装备物品等级。（需要：%2$d。当前%3$d。）', playerWithLowestItemLevel, brawlMinItemLevel, partyMinItemLevel)
                        end
                    end
                end
                local _, _, playerPvPItemLevel = GetAverageItemLevel()
                if (brawlHasMinItemLevelRequirement and playerPvPItemLevel < brawlInfo.minItemLevel) then
                    canQueue = false
                    disabledReason = format('你需要更高的PvP装备物品平均等级才能加入队列。|n（需要 %2$d，当前%3$d。）', brawlInfo.minItemLevel, playerPvPItemLevel)
                end
            end
            if not disabledReason then
                if ( select(2,C_LFGList.GetNumApplications()) > 0 ) then
                    disabledReason = '你不能在拥有有效的预创建队伍申请时那样做。'
                    canQueue = false
                elseif ( C_LFGList.HasActiveEntryInfo() ) then
                    disabledReason = '你不能在你的队伍出现在预创建队伍列表中时那样做。'
                    canQueue = false
                end
            end
            local isInCrossFactionGroup = C_PartyInfo.IsCrossFactionParty()
            if ( canQueue ) then
                if ( IsInGroup(LE_PARTY_CATEGORY_HOME) ) then
                    HonorFrame.QueueButton:SetText('小队加入')
                    if (not UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME)) then
                        disabledReason = '你现在不是队长'
                    elseif(isInCrossFactionGroup) then
                        if isBrawl or isSpecialBrawl then
                            local brawlInfo = isSpecialBrawl and C_PvP.GetSpecialEventBrawlInfo() or C_PvP.GetAvailableBrawlInfo()
                            local allowCrossFactionGroups = brawlInfo and brawlInfo.brawlType == Enum.BrawlType.SoloRbg
                            if (not allowCrossFactionGroups) then
                                disabledReason ='在跨阵营队伍中无法这么做。你可以参加竞技场或者评级战场。'
                            end
                        end
                    end
                else
                    HonorFrame.QueueButton:SetText('加入战斗')
                end
            else
                if (HonorFrame.type == "bonus" and HonorFrame.BonusFrame.selectedButton and HonorFrame.BonusFrame.selectedButton.queueID) then
                    if not disabledReason then
                        disabledReason = LFGConstructDeclinedMessage(HonorFrame.BonusFrame.selectedButton.queueID)
                    end
                end
            end
            HonorFrame.QueueButton.tooltip = disabledReason
        end)

        hooksecurefunc('PVPConquestLockTooltipShow', function()
            GameTooltip:SetText(string.format('该功能将在%d级开启。', GetMaxLevelForLatestExpansion()))
            GameTooltip:Show()
        end)

        PVPQueueFrame.HonorInset.CasualPanel:HookScript('OnShow', function(self)
            if self.HKLabel:IsShown() then
                set(self.HKLabel, '宏伟宝库')
            end
        end)
        set(PVPQueueFrame.HonorInset.CasualPanel.HKLabel, '宏伟宝库')
        PVPQueueFrame.HonorInset.CasualPanel.WeeklyChest:HookScript('OnEnter', function()
            if not ConquestFrame_HasActiveSeason() then
                GameTooltip_SetTitle(GameTooltip, '宏伟宝库奖励')
                GameTooltip_AddDisabledLine(GameTooltip, '无效会阶')
                GameTooltip_AddNormalLine(GameTooltip, '征服点数只能在PvP赛季开启期间获得。')
                GameTooltip:Show()
            else
                local weeklyProgress = C_WeeklyRewards.GetConquestWeeklyProgress()
                local unlocksCompleted = weeklyProgress.unlocksCompleted or 0
                local maxUnlocks = weeklyProgress.maxUnlocks or 3
                local description
                if unlocksCompleted > 0 then
                    description = format('通过评级PvP获得获得荣誉点数以解锁宏伟宝库的奖励。你的奖励的物品等级会以你本周胜场的最高段位为基准。\n\n%s/%s奖励已解锁。', unlocksCompleted, maxUnlocks)
                else
                    description = format('通过评级PvP获得获得荣誉点数以解锁宏伟宝库的奖励。你的奖励的物品等级会以你本周胜场的最高段位为基准。\n\n%s/%s奖励已解锁。', unlocksCompleted, maxUnlocks)
                end
                GameTooltip_SetTitle(GameTooltip, '宏伟宝库奖励')
                local hasRewards = C_WeeklyRewards.HasAvailableRewards()
                if hasRewards then
                    GameTooltip_AddColoredLine(GameTooltip, '宏伟宝库里有奖励在等待着你。', GREEN_FONT_COLOR)
                    GameTooltip_AddBlankLineToTooltip(GameTooltip)
                end
                GameTooltip_AddNormalLine(GameTooltip, description)
                GameTooltip_AddInstructionLine(GameTooltip, '点击预览宏伟宝库')
                GameTooltip:Show()
            end
        end)

        hooksecurefunc(PVPQueueFrame.HonorInset.CasualPanel.HonorLevelDisplay, 'Update', function(self)
            local honorLevel = UnitHonorLevel("player")
	        set(self.LevelLabel, format('荣誉等级 %d', honorLevel))
        end)
        PVPQueueFrame.HonorInset.CasualPanel.HonorLevelDisplay:HookScript('OnEnter', function()
            GameTooltip_SetTitle(GameTooltip, '生涯荣誉')
            GameTooltip_AddColoredLine(GameTooltip, '所有角色获得的荣誉。', NORMAL_FONT_COLOR)
            GameTooltip_AddBlankLineToTooltip(GameTooltip)
            local currentHonor = UnitHonor("player")
            local maxHonor = UnitHonorMax("player")
            GameTooltip_AddColoredLine(GameTooltip, string.format('%d / %d', currentHonor, maxHonor), HIGHLIGHT_FONT_COLOR)
            GameTooltip:Show()
        end)
        PVPQueueFrame.HonorInset.CasualPanel.HonorLevelDisplay.NextRewardLevel:HookScript('OnEnter', function(self)
            local honorLevel = UnitHonorLevel("player")
            local nextHonorLevelForReward = C_PvP.GetNextHonorLevelForReward(honorLevel)
            local rewardInfo = nextHonorLevelForReward and C_PvP.GetHonorRewardInfo(nextHonorLevelForReward)
            if rewardInfo then
                local rewardText = select(11, GetAchievementInfo(rewardInfo.achievementRewardedID))
                if rewardText and rewardText ~= "" then
                    GameTooltip:SetText(format('到达荣誉等级%d级后可获得下一个奖励', nextHonorLevelForReward))
                    local WRAP = true
                    GameTooltip_AddColoredLine(GameTooltip, rewardText, HIGHLIGHT_FONT_COLOR, WRAP)
                    GameTooltip:Show()
                end
            end
        end)

        BONUS_BUTTON_TOOLTIPS.RandomBG.func= function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText('随机战场', 1, 1, 1)
            GameTooltip:AddLine('在随机战场上与敌对阵营竞争。', nil, nil, nil, true)
            GameTooltip:Show()
        end
        BONUS_BUTTON_TOOLTIPS.EpicBattleground.func = function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText('随机史诗战场', 1, 1, 1)
            GameTooltip:AddLine('在40人的大型战场上与敌对阵营竞争。', nil, nil, nil, true)
            GameTooltip:Show()
        end
--hooksecurefunc('HonorFrame_UpdateQueueButtons', function()









































    elseif arg1=='Blizzard_ArtifactUI' then
        --Blizzard_ArtifactUI.lua
        dia("CONFIRM_ARTIFACT_RESPEC", {text = '确定要重置你的神器专长吗？|n|n这将消耗%s点|cffe6cc80神器能量|r。', button1 = '是', button2 = '否'})
        dia("NOT_ENOUGH_POWER_ARTIFACT_RESPEC", {text = '你没有足够的|cffe6cc80神器能量|r来重置你的专长。|n|n需要%s点|cffe6cc80神器能量|r。', button1 = '确定'})

        --Blizzard_ArtifactPerks.lua
        dia("CONFIRM_RELIC_REPLACE", {text = '你确定要替换此圣物吗？已有的圣物将被摧毁。', button1 = '接受', button2 = '取消'})

    elseif arg1=='Blizzard_Soulbinds' then
        dia("SOULBIND_DIALOG_MOVE_CONDUIT", {text = '一个导灵器只能同时被放置在一个插槽内，所以之前插槽里的该导灵器已被移除。', button1 = '接受'})
        dia("SOULBIND_DIALOG_INSTALL_CONDUIT_UNUSABLE", {text = '此插槽目前未激活。你确定想在此添加一个导灵器吗？', button1 = '接受', button2 = '取消'})

    elseif arg1=='Blizzard_AnimaDiversionUI' then--Blizzard_AnimaDiversionUI.lua
        dia("ANIMA_DIVERSION_CONFIRM_CHANNEL", {text = '你确定想引导心能到%s吗？|n|n|cffffd200%s|r', button1 = '是', button2 = '取消'})
        dia("ANIMA_DIVERSION_CONFIRM_REINFORCE", {text = '你确定想强化%s吗？|n|n|cffffd200这样会永久激活此地点，而且无法撤销。|r', button1 = '是', button2 = '取消'})

        dia("SOULBIND_CONDUIT_NO_CHANGES_CONFIRMATION", {text = '你对你的导灵器进行了改动，但并没有应用这些改动。你确定想要离开吗？', button1 = '离开', button2 = '取消'})

    elseif arg1=='Blizzard_CovenantSanctum' then--Blizzard_CovenantSanctumUpgrades.lua
        dia("CONFIRM_ARTIFACT_RESPEC", {button1 = '是', button2 = '否'})
        hookDia("CONFIRM_ARTIFACT_RESPEC", 'OnShow', function(self, data)
            if data then
                local costString = GetGarrisonTalentCostString(data.talent)
                self.text:SetFormattedText('把|cff20ff20%s|r升到%d级会花费|n%s', data.talent.name, data.talent.tier + 1, costString)
            end
        end)

    elseif arg1=='Blizzard_PerksProgram' then--Blizzard_PerksProgramElements.lua
        dia("PERKS_PROGRAM_CONFIRM_PURCHASE", {text= '用%s%s 交易下列物品？', button1 = '购买', button2 = '取消'})
        dia("PERKS_PROGRAM_CONFIRM_REFUND", {text= '退还下列物品，获得退款%s%s？', button1 = '退款', button2 = '取消'})
        dia("PERKS_PROGRAM_SERVER_ERROR", {text= '商栈与服务器交换数据时出现困难，请稍后再试。', button1 = '确定'})
        dia("PERKS_PROGRAM_ITEM_PROCESSING_ERROR", {text= '正在处理一件物品。请稍后再试。。', button1 = '确定'})
        dia("PERKS_PROGRAM_CONFIRM_OVERRIDE_FROZEN_ITEM", {text= '你确定想替换当前的冻结物品吗？现在的冻结物品有可能已经下架了。', button1 = '确认', button2 = '取消'})

    elseif arg1=='Blizzard_WeeklyRewards' then--Blizzard_WeeklyRewards.lua
        font(WeeklyRewardsFrame.HeaderFrame.Text)
        hooksecurefunc(WeeklyRewardsFrame, 'UpdateTitle', function(self)
            local canClaimRewards = C_WeeklyRewards.CanClaimRewards()
            if canClaimRewards then
                set(self.HeaderFrame.Text, '你只能从宏伟宝库选择一件奖励。')
            elseif not C_WeeklyRewards.HasInteraction() and C_WeeklyRewards.HasAvailableRewards() then
                set(self.HeaderFrame.Text, '返回宏伟宝库，获取你的奖励')
            else
                set(self.HeaderFrame.Text, '每周完成活动可以将物品添加到宏伟宝库中。|n你每周可以选择一件奖励。')
            end
        end)

        dia("CONFIRM_SELECT_WEEKLY_REWARD", {text = '你一旦选好奖励就不能变更了。|n|n你确定要选择这件物品吗？', button1 = '是', button2 = '取消'})

    elseif arg1=='Blizzard_ChallengesUI' then--挑战, 钥匙插入， 界面
        hooksecurefunc(ChallengesFrame, 'UpdateTitle', function()
            local currentDisplaySeason =  C_MythicPlus.GetCurrentUIDisplaySeason()
            if ( not currentDisplaySeason ) then
                PVEFrame:SetTitle('史诗钥石地下城')
            else
                local currExpID = GetExpansionLevel()
                local expName = _G["EXPANSION_NAME"..currExpID]
                local title = format('史诗钥石地下城 %s 赛季 %d', e.strText[expName] or expName, currentDisplaySeason)
                PVEFrame:SetTitle(title)
            end
        end)
        set(ChallengesFrame.WeeklyInfo.Child.SeasonBest, '赛季最佳')
        set(ChallengesFrame.WeeklyInfo.Child.ThisWeekLabel, '本周')
        set(ChallengesFrame.WeeklyInfo.Child.Description, '在史诗难度下，你每完成一个地下城，都会提升下一个地下城的难度和奖励。\n\n每周你都会根据完成的史诗地下城获得一系列奖励。\n\n要想开始挑战，把你的地下城难度设置为史诗，然后前往任意下列地下城吧。')

        hooksecurefunc(ChallengesFrame.WeeklyInfo.Child.WeeklyChest, 'Update', function(self, bestMapID, dungeonScore)
            if C_WeeklyRewards.HasAvailableRewards() then
                self.RunStatus:SetText('拜访宏伟宝库获取你的奖励！')
            elseif self:HasUnlockedRewards(Enum.WeeklyRewardChestThresholdType.Activities)  then
                self.RunStatus:SetText('完成史诗钥石地下城即可获得：')
            elseif C_MythicPlus.GetOwnedKeystoneLevel() or (dungeonScore and dungeonScore > 0) then
                self.RunStatus:SetText('完成史诗钥石地下城即可获得：')
            end
        end)


        ChallengesFrame.WeeklyInfo.Child.WeeklyChest:HookScript('OnEnter', function(self)
            GameTooltip_SetTitle(GameTooltip, '宏伟宝库奖励')
            if self.state == 4 then--CHEST_STATE_COLLECT
                GameTooltip_AddColoredLine(GameTooltip, '宏伟宝库里有奖励在等待着你。', GREEN_FONT_COLOR)
                GameTooltip_AddBlankLineToTooltip(GameTooltip)
            end
            local lastCompletedActivityInfo, nextActivityInfo = WeeklyRewardsUtil.GetActivitiesProgress()
            if not lastCompletedActivityInfo then
                GameTooltip_AddNormalLine(GameTooltip, '在本周内完成一个满级英雄或史诗地下城可以解锁一个宏伟宝库奖励。时空漫游地下城算作英雄地下城。|n|n你的奖励的物品等级会以你本周最高等级的成绩为依据。')
            else
                if nextActivityInfo then
                    local globalString = (lastCompletedActivityInfo.index == 1) and '再完成%1$d个满级英雄或史诗地下城可以解锁第二个宏伟宝库奖励。时空漫游地下城算作英雄地下城。' or '再完成%1$d个满级英雄或史诗地下城可以解锁第三个宏伟宝库奖励。时空漫游地下城算作英雄地下城。'
                    GameTooltip_AddNormalLine(GameTooltip, globalString:format(nextActivityInfo.threshold - nextActivityInfo.progress))
                else
                    GameTooltip_AddNormalLine(GameTooltip, '你已经解锁了本周可提供的所有奖励。在下周开始时拜访宏伟宝库，从你解锁的奖励里进行选择！')
                    GameTooltip_AddBlankLineToTooltip(GameTooltip)
                    GameTooltip_AddColoredLine(GameTooltip, '提升你的奖励', GREEN_FONT_COLOR)
                    local level, count = WeeklyRewardsUtil.GetLowestLevelInTopDungeonRuns(lastCompletedActivityInfo.threshold)
                    if level == WeeklyRewardsUtil.HeroicLevel then
                        GameTooltip_AddNormalLine(GameTooltip, format('完成%1$d次史诗难度的地下城，提升你的奖励。', count))
                    else
                        local nextLevel = WeeklyRewardsUtil.GetNextMythicLevel(level)
                        GameTooltip_AddNormalLine(GameTooltip, format('完成%1$d个%2$d级或更高的史诗地下城可以提升你的奖励。', count, nextLevel))
                    end
                end
            end
            GameTooltip_AddInstructionLine(GameTooltip, '点击预览宏伟宝库')
            GameTooltip:Show()
        end)

        set(ChallengesFrame.WeeklyInfo.Child.DungeonScoreInfo.Title, '史诗钥石评分')
        ChallengesFrame.WeeklyInfo.Child.DungeonScoreInfo:HookScript('OnEnter', function()
            GameTooltip_SetTitle(GameTooltip, '史诗钥石评分')
            GameTooltip_AddNormalLine(GameTooltip, '基于你在每个地下城的最佳成绩得出的总体评分。你可以通过更迅速地完成地下城或者完成更高难度的地下城来提高你的评分。|n|n提升你的史诗地下城评分后，你就能把你的地下城装备升级到最高等级。|n|cff1eff00<Shift+点击以链接到聊天栏>|r')
            GameTooltip:Show()
        end)

    elseif arg1=='Blizzard_PlayerChoice' then
        dia("CONFIRM_PLAYER_CHOICE", {button1 = '确定', button2 = '取消'})
        dia("CONFIRM_PLAYER_CHOICE_WITH_CONFIRMATION_STRING", {button1 = '接受', button2 = '拒绝'})

    elseif arg1=='Blizzard_GarrisonTemplates' then--Blizzard_GarrisonSharedTemplates.lua
        dia("CONFIRM_FOLLOWER_UPGRADE", {button1 = '是', button2 = '否'})
        dia("CONFIRM_FOLLOWER_ABILITY_UPGRADE", {button1 = '是', button2 = '否'})
        dia("CONFIRM_FOLLOWER_TEMPORARY_ABILITY", {text = '确定要赋予%s这个临时技能吗？', button1 = '是', button2 = '否'})
        dia("CONFIRM_FOLLOWER_EQUIPMENT", {button1 = '是', button2 = '否'})

    elseif arg1=='Blizzard_ClassTrial' then--Blizzard_WeeklyRewards.lua
        dia("CLASS_TRIAL_CHOOSE_BOOST_TYPE", {text = '你希望使用哪种角色直升？', button1 = '接受', button2 = '接受', button3 = '取消'})
        dia("CLASS_TRIAL_CHOOSE_BOOST_LOGOUT_PROMPT", {text = '要使用此角色直升服务，请登出游戏，返回角色选择界面。', button1 = '立刻返回角色选择画面', button2 = '取消'})

    elseif arg1=='Blizzard_GarrisonUI' then--要塞
        dia("DEACTIVATE_FOLLOWER", {button1 = '是', button2 = '否'})
        hookDia("DEACTIVATE_FOLLOWER", 'OnShow', function(self)
            local quality = C_Garrison.GetFollowerQuality(self.data)
            local name = FOLLOWER_QUALITY_COLORS[quality].hex..C_Garrison.GetFollowerName(self.data)..FONT_COLOR_CODE_CLOSE
            local cost = GetMoneyString(C_Garrison.GetFollowerActivationCost())
            local uses = C_Garrison.GetNumFollowerDailyActivations()
            self.text:SetFormattedText('确定要遣散|n%s吗？|n|n重新激活一名追随者需要花费%s。|n你每天可重新激活%d名追随者。', name, cost, uses)
        end)

        dia("ACTIVATE_FOLLOWER", {button1 = '是', button2 = '否'})
        hookDia("ACTIVATE_FOLLOWER", 'OnShow', function(self)
            local quality = C_Garrison.GetFollowerQuality(self.data)
            local name = FOLLOWER_QUALITY_COLORS[quality].hex..C_Garrison.GetFollowerName(self.data)..FONT_COLOR_CODE_CLOSE
            local cost = GetMoneyString(C_Garrison.GetFollowerActivationCost())
            local uses = C_Garrison.GetNumFollowerDailyActivations()
            self.text:SetFormattedText('确定要激活|n%s吗？|n|n你今天还能激活%d名追随者，这将花费：', name, cost, uses)
        end)

        dia("CONFIRM_RECRUIT_FOLLOWER", {text  = '确定要招募%s吗？', button1 = '是', button2 = '否'})

        dia("DANGEROUS_MISSIONS", {button1 = '确定', button2 = '取消'})
        hookDia("DANGEROUS_MISSIONS", 'OnShow', function(self)
            local warningIconText = "|T" .. STATICPOPUP_TEXTURE_ALERT .. ":15:15:0:-2|t"
            self.text:SetFormattedText('|n %s |cffff2020警告！|r %s |n|n你即将执行一项高危行动。如果行动失败，所有参与任务的舰船都有一定几率永久损毁。', warningIconText, warningIconText)
        end)

        dia("GARRISON_SHIP_RENAME", {text  = '输入你想要的名字：', button1 = '接受', button2 = '取消', button3= '默认'})

        dia("GARRISON_SHIP_DECOMMISSION", {button1 = '是', button2 = '否'})
        hookDia("GARRISON_SHIP_DECOMMISSION", 'OnShow', function(self)
            local quality = C_Garrison.GetFollowerQuality(self.data.followerID)
            local name = FOLLOWER_QUALITY_COLORS[quality].hex..C_Garrison.GetFollowerName(self.data.followerID)..FONT_COLOR_CODE_CLOSE
            self.text:SetFormattedText('你确定要永久报废|n%s吗？|n|n你将无法重新获得这艘舰船。', name)
        end)

        dia("GARRISON_CANCEL_UPGRADE_BUILDING", {text  = '确定要取消这次建筑升级吗？升级的费用将被退还。', button1 = '是', button2 = '否'})
        dia("GARRISON_CANCEL_BUILD_BUILDING", {text  = '确定要取消建造这座建筑吗？建造的费用将被退还。', button1 = '是', button2 = '否'})
        dia("COVENANT_MISSIONS_CONFIRM_ADVENTURE", {text  = '开始冒险？', button1 = '确认', button2 = '取消'})
        dia("COVENANT_MISSIONS_HEAL_CONFIRMATION", {text  = '你确定要彻底治愈这名追随者吗？', button1 = '确认', button2 = '取消'})
        dia("COVENANT_MISSIONS_HEAL_ALL_CONFIRMATION", {text  = '你确定要付出%s，治疗所有受伤的伙伴？', button1 = '治疗全部', button2 = '取消'})

    --elseif arg1=='Blizzard_RuneforgeUI' then--Blizzard_RuneforgeCreateFrame.lua
        --dia("CONFIRM_RUNEFORGE_LEGENDARY_CRAFT", {button1 = '是', button2 = '否'})

    elseif arg1=='Blizzard_ClickBindingUI' then
        dia("CONFIRM_LOSE_UNSAVED_CLICK_BINDINGS", {text  = '你有未保存的点击施法按键绑定。如果你现在关闭，会丢失所有改动。', button1 = '确定', button2 = '取消'})
        dia("CONFIRM_RESET_CLICK_BINDINGS", {text  = '确定将所有点击施法按键绑定重置为默认值吗？\n', button1 = '确定', button2 = '取消'})


        set(ClickBindingFrameTitleText, '关于点击施法按键绑定')
        ClickBindingFrame.TutorialFrame:SetTitle('关于点击施法按键绑定')

        set(ClickBindingFrame.SaveButton, '保存')
        set(ClickBindingFrame.AddBindingButton, '添加绑定')
        set(ClickBindingFrame.ResetButton, '恢复默认设置')
        set(ClickBindingFrame.EnableMouseoverCastCheckbox.Label, '鼠标悬停施法')
        ClickBindingFrame.EnableMouseoverCastCheckbox:HookScript('OnEnter', function()
            GameTooltip:SetText('启用后，鼠标悬停到一个单位框体并使用一个键盘快捷键施放法术时，会直接对该单位施法，无需将该单位设为目标。', nil, nil, nil, nil, true)

        end)
        set(ClickBindingFrame.MouseoverCastKeyDropDown.Label, '鼠标悬停施法按键')
        set(ClickBindingFrame.TutorialFrame.SummaryText, '将法术和宏绑定到鼠标点击')
        set(ClickBindingFrame.TutorialFrame.InfoText, '通过点击单位框体施放绑定的法术和宏')
        set(ClickBindingFrame.TutorialFrame.AlternateText, '可以使用Shift键、Ctrl键或者Alt键来设定其他的点击绑定')
        set(ClickBindingFrame.TutorialFrame.ThrallName, '萨尔')
        ClickBindingFrame.SpellbookPortrait:HookScript('OnEnter', function()
            GameTooltip_SetTitle(GameTooltip, MicroButtonTooltipText('法术书和专业', "TOGGLESPELLBOOK"))
            GameTooltip:Show()
        end)
        ClickBindingFrame.MacrosPortrait:HookScript('OnEnter', function()
            GameTooltip_SetTitle(GameTooltip, '宏')
            GameTooltip:Show()
        end)

        local function NameAndIconFromElementData(elementData)
            if elementData.bindingInfo then
                local bindingInfo = elementData.bindingInfo
                local type = bindingInfo.type
                local actionID = bindingInfo.actionID

                local actionName
                if type == Enum.ClickBindingType.Spell or type == Enum.ClickBindingType.PetAction then
                    local overrideID = FindSpellOverrideByID(actionID)
                    actionName = GetSpellInfo(overrideID)
                elseif type == Enum.ClickBindingType.Macro then
                    local macroName
                    macroName = GetMacroInfo(actionID)
                    actionName = format('%s (宏)', macroName)
                elseif type == Enum.ClickBindingType.Interaction then
                    if actionID == Enum.ClickBindingInteraction.Target then
                        actionName = '目标单位框架 (默认)'
                    elseif actionID == Enum.ClickBindingInteraction.OpenContextMenu then
                        actionName = '打开上下文菜单 (默认)'
                    end
                end
                return actionName
            elseif elementData.elementType == 1 then
                return '默认鼠标绑定'
            elseif elementData.elementType == 3 then
                return '自定义鼠标绑定'
            elseif elementData.elementType == 5 then
                return '空'
            end
        end
        hooksecurefunc(ClickBindingFrame, 'SetUnboundText', function(self, elementData)
            set(self.UnboundText, format('%s 解除绑定', NameAndIconFromElementData(elementData)))
        end)

        local ButtonStrings = {
            LeftButton = '左键',
            Button1 = '左键',
            RightButton = '右键',
            Button2 = '右键',
            MiddleButton = '中键',
            Button3 = '中键',
            Button4 = '按键4',
            Button5 = '按键5',
            Button6 = '按键6',
            Button7 = '按键7',
            Button8 = '按键8',
            Button9 = '按键9',
            Button10 = '按键10',
            Button11 = '按键11',
            Button12 = '按键12',
            Button13 = '按键13',
            Button14 = '按键14',
            Button15 = '按键15',
            Button16 = '按键16',
            Button17 = '按键17',
            Button18 = '按键18',
            Button19 = '按键19',
            Button20 = '按键20',
            Button21 = '按键21',
            Button22 = '按键22',
            Button23 = '按键23',
            Button24 = '按键24',
            Button25 = '按键25',
            Button26 = '按键26',
            Button27 = '按键27',
            Button28 = '按键28',
            Button29 = '按键29',
            Button30 = '按键30',
            Button31 = '按键31',
        }

        local function BindingTextFromElementData(elementData)
            if elementData.elementType == 5 then
                local bindingText = elementData.bindingInfo and '鼠标移到该位置并点击一个鼠标按键来进行绑定' or '点击一个法术或宏以开始'
                return GREEN_FONT_COLOR:WrapTextInColorCode(bindingText)
            end

            local bindingInfo = elementData.bindingInfo
            if not bindingInfo or not bindingInfo.button then
                return RED_FONT_COLOR:WrapTextInColorCode('解除绑定 - 把鼠标移到目标上并点击来设置')
            end

            local buttonString = ButtonStrings[bindingInfo.button]
            local modifierText = C_ClickBindings.GetStringFromModifiers(bindingInfo.modifiers)
            if modifierText ~= "" then
                return format('%s-%s', modifierText, buttonString)
            else
                return buttonString
            end
        end
        local function ColoredNameAndIconFromElementData(elementData)
            local name = NameAndIconFromElementData(elementData)
            local isDisabled
            if elementData.elementType == 5 then
                isDisabled = (elementData.bindingInfo == nil)
            else
                isDisabled = elementData.unbound
            end
            if isDisabled then
                name = DISABLED_FONT_COLOR:WrapTextInColorCode(name)
            end
            return name
        end
        hooksecurefunc(ClickBindingLineMixin, 'Init', function(self, elementData)
            set(self.BindingText, BindingTextFromElementData(elementData))

            set(self.Name, ColoredNameAndIconFromElementData(elementData))
        end)
        hooksecurefunc(ClickBindingHeaderMixin, 'Init', function(self, elementData)
	        set(self.Name, ColoredNameAndIconFromElementData(elementData))
        end)

    elseif arg1=='Blizzard_ProfessionsTemplates' then
        dia("PROFESSIONS_RECRAFT_REPLACE_OPTIONAL_REAGENT", {button1 = '接受', button2 = '取消'})
        hookDia("PROFESSIONS_RECRAFT_REPLACE_OPTIONAL_REAGENT", 'OnShow', function(self, data)
            self.text:SetFormattedText('你想替换%s吗？\n它会在再造时被摧毁。', data.itemName)
        end)

    elseif arg1=='Blizzard_BlackMarketUI' then
        dia("BID_BLACKMARKET", {text = '确定要出价%s竞拍以下物品吗？', button1 = '确定', button2 = '取消'})

    elseif arg1=='Blizzard_TrainerUI' then--专业，训练师
        dia("CONFIRM_PROFESSION", {text = format('你只能学习两个专业。你要学习|cffffd200%s|r作为你的第一个专业吗？', "XXX"), button1 = '接受', button2 = '取消'})
        hookDia("CONFIRM_PROFESSION", 'OnShow', function(self)
            local prof1, prof2 = GetProfessions()
            if ( prof1 and not prof2 ) then
                self.text:SetFormattedText('你只能学习两个专业。你要学习|cffffd200%s|r作为你的第二个专业吗？', GetTrainerServiceSkillLine(ClassTrainerFrame.selectedService))
            elseif ( not prof1 ) then
                self.text:SetFormattedText('你只能学习两个专业。你要学习|cffffd200%s|r作为你的第一个专业吗？', GetTrainerServiceSkillLine(ClassTrainerFrame.selectedService))
            end
        end)
        set(ClassTrainerTrainButton, '训练')

    elseif arg1=='Blizzard_DeathRecap' then
        set(DeathRecapFrame.CloseButton, '关闭')
        set(DeathRecapFrame.Title, '死亡摘要')

    elseif arg1=='Blizzard_ItemSocketingUI' then--镶嵌宝石，界面
        set(ItemSocketingSocketButton, '应用')

    --[[elseif arg1=='Blizzard_CombatLog' then--聊天框，战斗记录
        print(CombatLogQuickButtonFrameButton1, id, addName)
        set(CombatLogQuickButtonFrameButton1, '我的动作')]]

    elseif arg1=='Blizzard_ItemUpgradeUI' then--装备升级,界面
        set(ItemUpgradeFrameTitleText, '物品升级')
        set(ItemUpgradeFrame.UpgradeButton, '升级')
        set(ItemUpgradeFrame.ItemInfo.MissingItemText, '将物品拖曳至此处升级。')
        set(ItemUpgradeFrame.MissingDescription, '许多可装备的物品都可以进行升级，从而提高其物品等级。不同来源的物品升级所需的货币也各不相同。')
        set(ItemUpgradeFrame.ItemInfo.UpgradeTo, '升级至：')
        set(ItemUpgradeFrame.UpgradeCostFrame.Label, '总花费：')
        set(ItemUpgradeFrame.FrameErrorText, '该物品已经升到满级了')


    elseif arg1=='Blizzard_Settings' then--Blizzard_SettingsPanel.lua 
        local label2= e.Cstr(SettingsPanel.CategoryList)
        label2:SetPoint('RIGHT', SettingsPanel.ClosePanelButton, 'LEFT', -2, 0)
        label2:SetText(id..' 语言翻译 提示：请要不在战斗中修改选项')

        set(SettingsPanel.Container.SettingsList.Header.DefaultsButton, '默认设置')
        dia('GAME_SETTINGS_APPLY_DEFAULTS', {text= '你想要将所有用户界面和插件设置重置为默认状态，还是只重置这个界面或插件的设置？', button1= '所有设置', button2= '取消', button3= '这些设置'})--Blizzard_Dialogs.lua
        set(SettingsPanel.GameTab.Text, '游戏')
        set(SettingsPanel.AddOnsTab.Text, '插件')
        set(SettingsPanel.NineSlice.Text, '选项')
        set(SettingsPanel.CloseButton, '关闭')
        set(SettingsPanel.ApplyButton, '应用')

        set(SettingsPanel.NineSlice.Text, '选项')
        set(SettingsPanel.SearchBox.Instructions, '搜索')

    elseif arg1=='Blizzard_TimeManager' then--小时图，时间
        set(TimeManagerStopwatchFrameText, '显示秒表')
        set(TimeManagerAlarmTimeLabel, '提醒时间')
        set(TimeManagerAlarmMessageLabel, '提醒信息')
        set(TimeManagerAlarmEnabledButtonText, '开启提醒')
        set(TimeManagerMilitaryTimeCheckText, '24小时模式')
        set(TimeManagerLocalTimeCheckText, '使用本地时间')
        set(StopwatchTitle, '秒表')

        hooksecurefunc('GameTime_UpdateTooltip', function()--GameTime.lua
            GameTooltip:SetText('时间信息', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            GameTooltip:AddDoubleLine( '服务器时间：', GameTime_GetGameTime(true), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            GameTooltip:AddDoubleLine( '本地时间：', GameTime_GetLocalTime(true), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        end)
        hooksecurefunc('TimeManagerClockButton_UpdateTooltip', function()
            if ( TimeManagerClockButton.alarmFiring ) then
                GameTooltip:AddLine('点击这里关闭提醒。')
            else
                GameTooltip:AddLine('点击这里显示时钟设置选项。')
            end
            GameTooltip:Show()
        end)

    elseif arg1=='Blizzard_ArchaeologyUI' then
        set(ArchaeologyFrameTitleText, '考古学')
        set(ArchaeologyFrameSummaryPageTitle, '种族')
        set(ArchaeologyFrameCompletedPage.infoText, '你还没有完成任何神器。寻找碎片及钥石以完成神器。')
        set(ArchaeologyFrameCompletedPage.titleBig, '已完成神器')
        set(ArchaeologyFrameCompletedPage.titleMid, '已完成的普通神器')

        set(ArchaeologyFrameCompletedPage.titleTop, '已完成的普通神器')

        set(ArchaeologyFrameArtifactPage.historyTitle, '历史')
        set(ArchaeologyFrameArtifactPage.raceRarity, '种族')
        set(ArchaeologyFrame.backButton, '后退')
        set(ArchaeologyFrameArtifactPageSolveFrameSolveButton, '解密')

        --[[
            self.summaryPage.UpdateFrame = ArchaeologyFrame_UpdateSummary
            self.completedPage.UpdateFrame = ArchaeologyFrame_UpdateComplete
            self.artifactPage.UpdateFrame = ArchaeologyFrame_CurrentArtifactUpdate
        ]]
        hooksecurefunc(ArchaeologyFrame.summaryPage, 'UpdateFrame', function(self)
            set(self.pageText, format('第%d页', self.currentPage))
        end)
        hooksecurefunc(ArchaeologyFrame.completedPage, 'UpdateFrame', function(self)
            set(self.pageText, format('第%d页', self.currentPage))
            set(self.titleTop, self.currData.onRare and '已完成的精良神器' or '已完成的普通神器')
        end)
        hooksecurefunc('ArchaeologyFrame_CurrentArtifactUpdate', function(self)
            local RaceName, _, RaceitemID	= GetArchaeologyRaceInfo(self.raceID, true)

            local runeName
            if RaceitemID and RaceitemID > 0 then
                runeName = GetItemInfo(RaceitemID)
            end
            if runeName then
                for i=1, ARCHAEOLOGY_MAX_STONES do
                    local slot= self.solveFrame["keystone"..i]
                    if slot and slot:IsShown() then
                        if ItemAddedToArtifact(i) then
                            self.solveFrame["keystone"..i].tooltip = format('点此以移除 |cnGREEN_FONT_COLOR:%s|r 。', runeName)
                        else
                            self.solveFrame["keystone"..i].tooltip = format('点此以从你的背包中选择一块 |cnGREEN_FONT_COLOR:%s|r 来降低完成该神器所需要的碎片数量。', runeName)
                        end
                    end
                end
            end

            if select(3, GetSelectedArtifactInfo()) == 0 then --Common Item
                self.raceRarity:SetText(RaceName.." - |cffffffff普通|r")
            else
                self.raceRarity:SetText(RaceName.." - |cff0070dd精良|r")
            end
        end)

        ArchaeologyFrame.rankBar:HookScript('OnEnter', function()
            GameTooltip:SetText('考古学技能', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true)
			GameTooltip:Show()
        end)

        ArchaeologyFrameArtifactPageSolveFrameStatusBar:HookScript('OnEnter', function()
            local _, _, _, _, _, maxCount = GetArchaeologyRaceInfo(ArchaeologyFrame.artifactPage.raceID)
            GameTooltip:SetText(format('拼出该神器所需的碎片数量。\n\n每个种族的碎片最多只能保存%d块。', maxCount), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true)
			GameTooltip:Show()
        end)
        set(ArchaeologyFrameHelpPageTitle, '考古学')
        set(ArchaeologyFrameHelpPageHelpScrollHelpText, '你需要搜集散落在世界各处的神器碎片来将它们复原为完整的神器。你能够在挖掘场里找到这些碎片，挖掘场的位置会标记在你的地图上。在挖掘场使用调查技能，你的调查工具就会显示出神器碎片大致的埋藏方向和位置。在前往一个新的挖掘地址前你可以在一个挖掘场中收集六次碎片。当你拥有了足够的碎片之后，你就可以破译隐藏在神器中的秘密，了解更多关于艾泽拉斯昔日的历史和传说。寻宝愉快！')
        set(ArchaeologyFrameHelpPageDigTitle, '考古学地图位置标记')

        ArchaeologyFrameSummarytButton:HookScript('OnEnter', function()
            GameTooltip:SetText('当前神器')
        end)
        ArchaeologyFrameCompletedButton:HookScript('OnEnter', function()
            GameTooltip:SetText('已完成神器')
        end)

    elseif arg1=='Blizzard_ItemInteractionUI' then--套装, 转换
        set(ItemInteractionFrame.CurrencyCost.Costs, '花费：')
        --hooksecurefunc(ItemInteractionFrame, 'LoadInteractionFrameData', function(self, frameData)dia("ITEM_INTERACTION_CONFIRMATION", {button2 = '取消'})
        dia("ITEM_INTERACTION_CONFIRMATION_DELAYED", {button2 = '取消'})
        dia("ITEM_INTERACTION_CONFIRMATION_DELAYED_WITH_CHARGE_INFO", {button2 = '取消'})


    --elseif arg1=='Blizzard_Calendar' then
        --dia("CALENDAR_DELETE_EVENT", {button1 = '确定', button2 = '取消'})
        --dia("CALENDAR_ERROR", {button1 = '确定'})
    end
end





















local EnabledTab={}
local function cancel_all()
    panel:UnregisterEvent('ADDON_LOADED')
    EnabledTab=nil
    Init=function() end
    Init_Loaded= function() end
    Init_Set= function() end
end




--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_LOGOUT')
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            if not e.onlyChinese then
                cancel_all()
                return
            end

            --添加控制面板
            e.AddPanel_Check({
                name= e.onlyChinese and '语言翻译' or addName,
                tooltip= 'UI, 仅限中文，|cnRED_FONT_COLOR:可能会出错|r|nChinese only',
                value= not Save.disabled,
                func= function()
                    Save.disabled = not Save.disabled and true or nil
                    print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                end
            })

            if Save.disabled then
                cancel_all()
            else

                do
                    Init_Set()
                end

                Init()

                for _, name in pairs(EnabledTab) do
                    Init_Loaded(name)
                end
                EnabledTab=nil
            end

        elseif e.onlyChinese and arg1 then
            if EnabledTab then
                table.insert(EnabledTab, arg1)

            elseif not Save.disabled then
                Init_Loaded(arg1)
            end
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)
