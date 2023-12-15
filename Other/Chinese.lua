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
    if not self or not text or self:IsForbidden() then--CanAccessObject(self) then
        if e.Player.husandro and self:IsForbidden() then
            print(id, addName, self:IsForbidden() and '危险，出错', text)
        end
        return
    end
    self:SetText(text)
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
    REPUTATION_SHOW_AS_XP = "在你的技能栏上方显示声望栏。";
    set(ReputationDetailInactiveCheckBoxText, '隐藏')
    REPUTATION_MOVE_TO_INACTIVE = "将声望条移动到你的声望列表最底部的隐藏分类中。对于归类你不再关心的声望非常有用。";
    set(ReputationDetailAtWarCheckBoxText, '交战状态')
    REPUTATION_AT_WAR_DESCRIPTION = "决定该阵营的成员对你的反应。如果你钩选了交战状态框，那么你就可以攻击他们。如果你没有钩选交战状态框，则不会对他们进行攻击。";

    set(TokenFramePopup.Title, '货币设置')
    set(TokenFramePopup.InactiveCheckBox.Text, '未使用')
    TOKEN_MOVE_TO_UNUSED = "将这种货币移动到你的列表底部的“未使用”类别中。可以有效地归类那些你不再关心的货币类型。";
    set(TokenFramePopup.BackpackCheckBox.Text, '在行囊上显示')
    TOKEN_SHOW_ON_BACKPACK = "钩选此项可以在你的行囊上显示此类货币的数量。\n\n你也可以按住Shift点击某种货币，从行囊中添加或移除它。";
    TOO_MANY_WATCHED_TOKENS = "你在同一时间内只能追踪%d种货币";

    --PaperDollFrame.lua
    SPELL_STAT1_NAME = "力量";
    SPELL_STAT2_NAME = "敏捷";
    SPELL_STAT3_NAME = "耐力";
    SPELL_STAT4_NAME = "智力";
    SPELL_STAT5_NAME = "精神";

    MANA = "法力值";

    CR_AVOIDANCE_TOOLTIP = "范围效果法术的伤害降低。\n\n闪避：%s [+%.2f%%]";
    CR_BLOCK_TOOLTIP = "格挡可使一次攻击的伤害降低%0.2f%%.\n|cff888888（对抗与你实力相当的敌人时）|r";
    CR_CRIT_MELEE_TOOLTIP = "攻击造成额外伤害的几率。\n%s点爆击（+%.2f%%爆击率）";
    CR_CRIT_PARRY_RATING_TOOLTIP = "攻击和法术造成额外效果的几率。\n\n爆击：%s [+%.2f%%]\n\n招架几率提高%.2f%%。";
    CR_CRIT_RANGED_TOOLTIP = "攻击造成额外伤害的几率。\n%s点爆击（+%.2f%%爆击率）";
    CR_CRIT_SPELL_TOOLTIP = "法术造成额外伤害的几率。\n%s点爆击（+%.2f%%爆击率）";
    CR_CRIT_TOOLTIP = "攻击和法术造成额外效果的几率。\n\n爆击：%s [+%.2f%%]";
    CR_DODGE_BASE_STAT_TOOLTIP = "躲闪几率提高%.2f%%|n|cff888888（在效果递减之前）|r";
    CR_DODGE_TOOLTIP = "%d点躲闪可使躲闪几率提高%.2f%%\n|cff888888（在效果递减之前）|r";
    CR_EXPERTISE_TOOLTIP = "被躲闪或招架的几率降低%s\n%s点精准(+%.2F%% 精准)";
    CR_HASTE_RATING_TOOLTIP = "%d点急速  (%.2f%% 急速)";
    CR_HIT_MELEE_TOOLTIP = "使你的近战攻击命中%d级目标的几率提高%.2f%%。";
    CR_HIT_RANGED_TOOLTIP = "使你的远程攻击命中%d级目标的几率提高%.2f%%。";
    CR_HIT_SPELL_TOOLTIP = "使你的法术命中%d级目标的几率提高%.2f%%。";
    CR_LIFESTEAL_TOOLTIP = "你所造成伤害和治疗的一部分将转而治疗你。\n\n吸血：%s [+%.2f%%]";
    CR_MULTISTRIKE_TOOLTIP = "有%.2f%%几率对每个目标造成相当于普通伤害或治疗量%.0f%%的额外伤害或治疗。\n\n溅射：%s [%.2f%%]";
    CR_PARRY_BASE_STAT_TOOLTIP = "招架几率提高%.2f%%|n|cff888888（在效果递减之前）|r";
    CR_PARRY_TOOLTIP = "%d点招架可使招架几率提高%.2f%%\n|cff888888（在效果递减之前）|r";
    CR_RANGED_EXPERTISE_TOOLTIP = "被躲闪的几率降低%s\n%s点精准(+%.2F%% 精准)";
    CR_SPEED_TOOLTIP = "提升移动速度。|n|n速度：%s [+%.2f%%]";
    CR_STURDINESS_TOOLTIP = "防止物品的耐久度降低。";
    CR_VERSATILITY_TOOLTIP = "造成的伤害值和治疗量提高%.2f%%，受到的伤害降低%.2f%%。\n\n全能：%s [%.2f%%/%.2f%%]";

    EFAULT_AGILITY_TOOLTIP = "提高你的远程武器攻击强度。|n提高所有武器的爆击几率。|n提高你的护甲值和躲避攻击的几率。";
    DEFAULT_INTELLECT_TOOLTIP = "提高你的武器技能熟练度提升速度。";
    DEFAULT_SPIRIT_TOOLTIP = "提高你的生命值和法力值回复速度。";
    DEFAULT_STAMINA_TOOLTIP = "提高你的生命值上限。";
    DEFAULT_STAT1_TOOLTIP = "提高你的攻击和技能强度";
    DEFAULT_STAT2_TOOLTIP = "提高你的攻击和技能强度";
    DEFAULT_STAT3_TOOLTIP = "生命值提高%s点";
    DEFAULT_STAT4_TOOLTIP = "提高你的法术强度";
    DEFAULT_STATARMOR_TOOLTIP = "受到的物理伤害减免%0.2f%%";
    DEFAULT_STATDEFENSE_TOOLTIP = "%s点防御（+%s 防御）\n躲闪、格挡和招架几率提高%.2f%%\n被命中和被爆击的几率降低%.2f%%\n|cff888888（在效果递减之前）|r";
    DEFAULT_STATSPELLBONUS_TOOLTIP = "法术攻击的伤害加成。";

    DAMAGE_SCHOOL2 = "神圣";
    DAMAGE_SCHOOL3 = "火焰";
    DAMAGE_SCHOOL4 = "自然";
    DAMAGE_SCHOOL5 = "冰霜";
    DAMAGE_SCHOOL6 = "暗影";
    DAMAGE_SCHOOL7 = "奥术";

    STAT_ARMOR = "护甲";
    STAT_ARMOR_BASE_TOOLTIP = "基础护甲值物理减伤：%0.2f%%";
    STAT_ARMOR_BONUS_ARMOR_BLADED_ARMOR_TOOLTIP = "总护甲值物理减伤：%0.2f%%\n攻击强度提高%d";
    STAT_ARMOR_TARGET_TOOLTIP = "（对当前目标：%0.2f%%）";
    STAT_ARMOR_TOOLTIP = "物理伤害减免：%0.2f%%\n|cff888888（对抗与你实力相当的敌人时）|r";
    STAT_ARMOR_TOTAL_TOOLTIP = "总护甲值物理减伤：%0.2f%%";
    STAT_ATTACK_POWER = "攻击强度";
    STAT_ATTACK_SPEED = "攻击速度";
    STAT_ATTACK_SPEED_BASE_TOOLTIP = "攻击速度+%s%%";
    STAT_AVERAGE_ITEM_LEVEL = "物品等级";
    STAT_AVERAGE_ITEM_LEVEL_EQUIPPED = "（已装备%d）";
    STAT_AVERAGE_ITEM_LEVEL_TOOLTIP = "你的装备的平均物品等级。";
    STAT_AVERAGE_PVP_ITEM_LEVEL = "PvP物品等级：%d";
    STAT_AVOIDANCE = "闪避";
    STAT_BLOCK = "格挡";
    STAT_BLOCK_TARGET_TOOLTIP = "（对当前目标：%0.2f%%）";
    STAT_BLOCK_TOOLTIP = "格挡值提高%d";
    STAT_BONUS_ARMOR = "护甲加成";
    STAT_CATEGORY_ATTACK = "攻击";
    STAT_CATEGORY_ATTRIBUTES = "属性";
    STAT_CATEGORY_DEFENSE = "防御";
    STAT_CATEGORY_ENHANCEMENTS = "强化属性";
    STAT_CATEGORY_GENERAL = "概况";
    STAT_CATEGORY_MELEE = "近战";
    STAT_CATEGORY_PVP = "PvP";
    STAT_CATEGORY_RANGED = "远程";
    STAT_CATEGORY_RESISTANCE = "抗性";
    STAT_CATEGORY_SPELL = "法术";
    STAT_CHI_TOOLTIP = "能量值上限。使用技能会消耗能量值，能量值会随时间自动回复。";
    STAT_CRITICAL_STRIKE = "爆击";
    STAT_DODGE = "躲闪";
    STAT_DPS_SHORT = "每秒伤害";
    STAT_ENERGY_REGEN = "能量值回复";
    STAT_ENERGY_REGEN_TOOLTIP = "每秒回复的能量值";
    STAT_ENERGY_TOOLTIP = "能量值上限。使用技能会消耗能量值，能量值会随时间自动回复。";
    STAT_EXPERTISE = "精准";
    STAT_FOCUS_REGEN = "集中值回复";
    STAT_FOCUS_REGEN_TOOLTIP = "每秒回复的集中值。";
    STAT_FOCUS_TOOLTIP = "集中值上限。使用技能会消耗集中值，集中值会随时间自动回复。";
    STAT_FORMAT = "%s：";
    STAT_HASTE = "急速";
    STAT_HASTE_BASE_TOOLTIP = "\n\n急速：%s [+%.2f%%]";
    STAT_HASTE_DEATHKNIGHT_TOOLTIP = "提高攻击速度和符文回复速度。";
    STAT_HASTE_DRUID_TOOLTIP = "提高攻击、施法和能量值回复速度。";
    STAT_HASTE_HUNTER_TOOLTIP = "提高攻击速度和集中值回复速度。";
    STAT_HASTE_MELEE_DEATHKNIGHT_TOOLTIP = "提高攻击速度和符文回复速度。";
    STAT_HASTE_MELEE_DRUID_TOOLTIP = "提高攻击速度和能量值回复速度。";
    STAT_HASTE_MELEE_HUNTER_TOOLTIP = "提高攻击速度和集中值回复速度。";
    STAT_HASTE_MELEE_MONK_TOOLTIP = "提高攻击速度和能量值回复速度。";
    STAT_HASTE_MELEE_ROGUE_TOOLTIP = "提高攻击速度和能量值回复速度。";
    STAT_HASTE_MELEE_TOOLTIP = "提高攻击速度。";
    STAT_HASTE_MONK_TOOLTIP = "提高攻击、施法和能量值回复速度。";
    STAT_HASTE_RANGED_HUNTER_TOOLTIP = "提高攻击速度和集中值回复速度。";
    STAT_HASTE_RANGED_TOOLTIP = "提高攻击速度。";
    STAT_HASTE_ROGUE_TOOLTIP = "提高攻击速度和能量值回复速度。";
    STAT_HASTE_SPELL_TOOLTIP = "提高施法速度。";
    STAT_HASTE_TOOLTIP = "提高攻击速度和施法速度。";
    STAT_HEALTH_PET_TOOLTIP = "最大生命值。如果生命值为0，则该生物会死亡。";
    STAT_HEALTH_TOOLTIP = "你的生命值上限。如果你的生命值为0的话，那你就会死亡。";
    STAT_HIT_CHANCE = "命中几率";
    STAT_HIT_MELEE_TOOLTIP = "%s点命中（+%.2f%%命中率）";
    STAT_HIT_NORMAL_ATTACKS = "普通攻击";
    STAT_HIT_RANGED_TOOLTIP = "%s点命中（+%.2f%%命中率）";
    STAT_HIT_SPECIAL_ATTACKS = "特殊攻击";
    STAT_HIT_SPELL_TOOLTIP = "%s点命中（+%.2f%%命中率）";
    STAT_LIFESTEAL = "吸血";
    STAT_LUNAR_POWER_TOOLTIP = "最大星界能量值。";
    STAT_MANA_TOOLTIP = "法力值上限。施放法术需要消耗法力值。";
    STAT_MASTERY = "精通";
    STAT_MASTERY_TOOLTIP = "精通： %s [+%.2f%%]";
    STAT_MASTERY_TOOLTIP_NOT_KNOWN = "要使精通生效，你必须先在训练师处学习该技能。";
    STAT_MASTERY_TOOLTIP_NO_TALENT_SPEC = "你必须选择一项天赋专精以激活精通技能。";
    STAT_MOVEMENT_FLIGHT_TOOLTIP = "飞行速度：%d%%";
    STAT_MOVEMENT_GROUND_TOOLTIP = "奔跑速度：%d%%";
    STAT_MOVEMENT_SPEED = "移动速度";
    STAT_MOVEMENT_SWIM_TOOLTIP = "游泳速度：%d%%";
    STAT_MULTISTRIKE = "溅射";
    STAT_NO_BENEFIT_TOOLTIP = "|cff808080该属性不能使你获益|r";
    STAT_PARRY = "招架";
    STAT_PVP_POWER = "PvP强度";
    STAT_RAGE_TOOLTIP = "怒气值上限。使用技能会消耗怒气值，攻击敌人和受到攻击时会回复怒气值。";
    STAT_RESILIENCE = "PvP韧性";
    STAT_RESILIENCE_BASE_TOOLTIP = "\n%s点韧性 (+%.2f%%韧性)";
    STAT_RUNE_REGEN = "符文速度";
    STAT_RUNE_REGEN_FORMAT = "%.2f秒";
    STAT_RUNE_REGEN_TOOLTIP = "每个符文充能所需的时间。";
    STAT_RUNIC_POWER_TOOLTIP = "符文能量上限。";
    STAT_SPEED = "加速";
    STAT_SPELLDAMAGE = "法术伤害";
    STAT_SPELLDAMAGE_TOOLTIP = "提高伤害性法术的效果";
    STAT_SPELLHEALING = "法术治疗";
    STAT_SPELLHEALING_TOOLTIP = "提高治疗性法术的效果";
    STAT_SPELLPOWER = "法术强度";
    STAT_SPELLPOWER_MELEE_ATTACK_POWER_TOOLTIP = "提高法术造成的伤害和治疗效果。提高近战武器造成的伤害，每秒%s点伤害。";
    STAT_SPELLPOWER_TOOLTIP = "提高法术造成的伤害和治疗效果。";
    STAT_STAGGER = "醉拳";
    STAT_STAGGER_TARGET_TOOLTIP = "（对当前目标比例%0.2f%%）";
    STAT_STAGGER_TOOLTIP = "你的醉拳可化解%0.2f%%的伤害";
    STAT_STURDINESS = "永不磨损";
    STAT_TARGET_LEVEL = "目标等级";
    STAT_TEMPLATE = "%s状态";
    STAT_TOOLTIP_BONUS_AP = "提高你的攻击和技能强度";
    STAT_TOOLTIP_BONUS_AP_SP = "提高你的攻击和技能强度";
    STAT_TOOLTIP_SP_AP_DRUID = "提高你的法术、攻击和技能强度";
    STAT_USELESS_TOOLTIP = "|cff808080不能使你的职业获益|r";
    STAT_VERSATILITY = "全能";


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

    LEAVE_QUEUE = "离开队列";
    JOIN_AS_PARTY = "小队加入";
    INSTANCE_ROLE_WARNING_TITLE = "该角色在某些地下城不可用。";
    INSTANCE_ROLE_WARNING_TEXT = "该角色在你所选择的一个或更多地下城中不可用。在这些地下城中，你将作为可胜任的角色加入队列。";
    ERR_NOT_LEADER = "你现在不是队长";
    CANNOT_DO_THIS_WHILE_LFGLIST_LISTED = "你不能在你的队伍出现在预创建队伍列表中时那样做。";
    CROSS_FACTION_RAID_DUNGEON_FINDER_ERROR = "在跨阵营队伍中无法这么做。你可以参加非队列匹配模式的团队副本和地下城。";
    START_A_GROUP = "创建队伍";
    LFG_LIST_FIND_A_GROUP = "寻找队伍";
    LFG_RANDOM_COOLDOWN_YOU = "你近期加入过一个随机地下城队列。\n需要过一段时间才可加入另一个，等待时间为：";
    LFG_DESERTER_YOU = "你刚刚逃离了随机队伍，在接下来的时间内无法再度排队：";
    LFG_DESERTER_OTHER = "你的一名队伍成员刚刚逃离了随机副本队伍，在接下来的时间内无法再度排队。";
    LFG_RANDOM_COOLDOWN_OTHER = "你的一名队友近期加入过一个随机地下城队列，暂时无法加入另一个。";
    YOU_MAY_NOT_QUEUE_FOR_DUNGEON = "你不能进入这个地下城的队列。";
    ERR_ROLE_UNAVAILABLE = "该职责不可用。";
    ROLE_DESCRIPTION_DAMAGER = "表示你愿意担当对敌人输出伤害的职责。";
    ROLE_DESCRIPTION_HEALER = "表示你愿意在队友受到伤害时为他们提供治疗。";
    ROLE_DESCRIPTION_TANK = "表示你愿意通过使敌人攻击自己，保护队友不受攻击。";
    VOTE_BOOT_PLAYER = "有人发起了一个将%1$s从队伍中移出的投票。\n\n理由为：\n|cffffd200%2$s|r\n\n你同意将%1$s移出队伍吗？";
    VOTE_BOOT_PLAYER_NO_REASON = "有人发起了一个将%1$s从队伍中移出的投票。\n\n你同意将%1$s移出队伍吗？";
    REQUEUE_CONFIRM_YOUR_ROLE = "你的队友已经将你加入另一场练习赛的队列。\n\n请确认你的角色：";
    CONFIRM_YOUR_ROLE = "确定你的职责：";

    INSTANCE_UNAVAILABLE_SELF_ACHIEVEMENT_NOT_COMPLETED = "你还没完成所需的成就。";
    INSTANCE_UNAVAILABLE_SELF_AREA_NOT_EXPLORED = "你需要发现%2$s。";
    INSTANCE_UNAVAILABLE_SELF_CANNOT_RUN_ANY_CHILD_DUNGEON = "你不满足此分类下任何地下城的要求。";
    INSTANCE_UNAVAILABLE_SELF_ENGAGED_IN_PVP = "你已进入PvP状态。";
    INSTANCE_UNAVAILABLE_SELF_EXPANSION_TOO_LOW = "你没有安装正确的《魔兽世界》内容更新。";
    INSTANCE_UNAVAILABLE_SELF_GEAR_TOO_HIGH = "你的装备物品平均等级太高。（需要 %2$d，当前%3$d。）";
    INSTANCE_UNAVAILABLE_SELF_GEAR_TOO_LOW = "你的装备物品平均等级不够。（需要 %2$d，当前%3$d。）";
    INSTANCE_UNAVAILABLE_SELF_LEVEL_TOO_HIGH = "你的级别太高了。";
    INSTANCE_UNAVAILABLE_SELF_LEVEL_TOO_LOW = "你的级别不够。";
    INSTANCE_UNAVAILABLE_SELF_MISSING_ITEM = "你没有所需的物品。";
    INSTANCE_UNAVAILABLE_SELF_NO_SPEC = "在进入此地下城前，你必须选择一项职业专精";
    INSTANCE_UNAVAILABLE_SELF_NO_VALID_ROLES = "你没有有效的角色。";
    INSTANCE_UNAVAILABLE_SELF_OTHER = "你的级别没有达到该地下城的要求。";
    INSTANCE_UNAVAILABLE_SELF_PVP_GEAR_TOO_LOW = "你需要更高的PvP装备物品平均等级才能加入队列。|n（需要 %2$d，当前%3$d。）";
    INSTANCE_UNAVAILABLE_SELF_QUEST_NOT_COMPLETED = "你没有完成所需的任务。";
    INSTANCE_UNAVAILABLE_SELF_RAID_LOCKED = "你已与该副本锁定。";
    INSTANCE_UNAVAILABLE_SELF_TEMPORARILY_DISABLED = "你不能进入。这个副本暂时不可用。";

    --[[StaticPopupDialogs["LFG_LIST_INVITING_CONVERT_TO_RAID"].text= "邀请这名玩家或队伍会将你的小队转化为团队。"
    StaticPopupDialogs["LFG_LIST_INVITING_CONVERT_TO_RAID"].button1 = '邀请'
	StaticPopupDialogs["LFG_LIST_INVITING_CONVERT_TO_RAID"].button2 = '取消']]
    LFG_LIST_APP_DECLINED_MESSAGE = "你发送给“%s”的申请已被拒绝。";
    LFG_LIST_APP_DECLINED_FULL_MESSAGE = "“%s”已满，已被移出列表。";
    LFG_LIST_APP_DECLINED_DELISTED_MESSAGE = "“%s”已被移出列表。";
    LFG_LIST_APP_TIMED_OUT_MESSAGE = "你发送给“%s”的申请已过期。";
    --hooksecurefunc('LFGListCategorySelection_AddButton', function(self, btnIndex, categoryID, filters)

        ITEM_MOD_AGILITY = "%c%s 敏捷";
        ITEM_MOD_AGILITY_OR_INTELLECT_SHORT = "敏捷或智力";
        ITEM_MOD_AGILITY_OR_STRENGTH_OR_INTELLECT_SHORT = "敏捷、力量或智力";
        ITEM_MOD_AGILITY_OR_STRENGTH_SHORT = "敏捷或力量";
        ITEM_MOD_AGILITY_SHORT = "敏捷";
        ITEM_MOD_ARMOR_PENETRATION_RATING = "使你的护甲穿透提高%s点。";
        ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT = "护甲穿透";
        ITEM_MOD_ATTACK_POWER = "攻击强度提高%s点。";
        ITEM_MOD_ATTACK_POWER_SHORT = "攻击强度";
        ITEM_MOD_BLOCK_RATING = "使你的盾牌格挡提高%s点。";
        ITEM_MOD_BLOCK_RATING_SHORT = "格挡";
        ITEM_MOD_BLOCK_VALUE = "使你的盾牌格挡值提高%s点。";
        ITEM_MOD_BLOCK_VALUE_SHORT = "格挡值";
        ITEM_MOD_CORRUPTION = "腐蚀";
        ITEM_MOD_CORRUPTION_RESISTANCE = "腐蚀抗性";
        ITEM_MOD_CRAFTING_SPEED_SHORT = "制作速度";
        ITEM_MOD_CRIT_MELEE_RATING = "近战爆击提高%s点。";
        ITEM_MOD_CRIT_MELEE_RATING_SHORT = "爆击（近战）";
        ITEM_MOD_CRIT_RANGED_RATING = "远程爆击提高%s点。";
        ITEM_MOD_CRIT_RANGED_RATING_SHORT = "爆击（远程）";
        ITEM_MOD_CRIT_RATING = "使你的爆击提高%s点。";
        ITEM_MOD_CRIT_RATING_SHORT = "爆击";
        ITEM_MOD_CRIT_SPELL_RATING = "法术爆击提高%s点。";
        ITEM_MOD_CRIT_SPELL_RATING_SHORT = "爆击（法术）";
        ITEM_MOD_CRIT_TAKEN_MELEE_RATING = "近战爆击躲闪提高%s点。";
        ITEM_MOD_CRIT_TAKEN_MELEE_RATING_SHORT = "爆击躲闪（近战）";
        ITEM_MOD_CRIT_TAKEN_RANGED_RATING = "远程爆击躲闪提高%s点。";
        ITEM_MOD_CRIT_TAKEN_RANGED_RATING_SHORT = "爆击躲闪（远程）";
        ITEM_MOD_CRIT_TAKEN_RATING = "爆击躲闪提高%s点。";
        ITEM_MOD_CRIT_TAKEN_RATING_SHORT = "爆击躲闪";
        ITEM_MOD_CRIT_TAKEN_SPELL_RATING = "法术爆击躲闪提高%s点。";
        ITEM_MOD_CRIT_TAKEN_SPELL_RATING_SHORT = "爆击躲闪（法术）";
        ITEM_MOD_CR_AVOIDANCE_SHORT = "闪避";
        ITEM_MOD_CR_LIFESTEAL_SHORT = "吸血";
        ITEM_MOD_CR_MULTISTRIKE_SHORT = "溅射";
        ITEM_MOD_CR_SPEED_SHORT = "加速";
        ITEM_MOD_CR_STURDINESS_SHORT = "永不磨损";
        ITEM_MOD_CR_UNUSED_6_SHORT = "永不磨损";
        ITEM_MOD_DAMAGE_PER_SECOND_SHORT = "每秒伤害";
        ITEM_MOD_DEFENSE_SKILL_RATING = "防御提高%s点。";
        ITEM_MOD_DEFENSE_SKILL_RATING_SHORT = "防御";
        ITEM_MOD_DEFTNESS_SHORT = "熟练";
        ITEM_MOD_DODGE_RATING = "使你的躲闪提高%s点。";
        ITEM_MOD_DODGE_RATING_SHORT = "躲闪";
        ITEM_MOD_EXPERTISE_RATING = "使你的精准提高%s点。";
        ITEM_MOD_EXPERTISE_RATING_SHORT = "精准";
        ITEM_MOD_EXTRA_ARMOR = "使你的护甲值提高%s。";
        ITEM_MOD_EXTRA_ARMOR_SHORT = "护甲加成";
        ITEM_MOD_FERAL_ATTACK_POWER = "在猎豹、熊、巨熊和枭兽形态下的攻击强度提高%s点。";
        ITEM_MOD_FERAL_ATTACK_POWER_SHORT = "变形形态下的攻击强度";
        ITEM_MOD_FINESSE_SHORT = "精细";
        ITEM_MOD_HASTE_RATING = "使你的急速提高%s点。";
        ITEM_MOD_HASTE_RATING_SHORT = "急速";
        ITEM_MOD_HEALTH = "%c%s 生命值";
        ITEM_MOD_HEALTH_REGEN = "每5秒恢复%s点生命值。";
        ITEM_MOD_HEALTH_REGENERATION = "每5秒恢复%s点生命值。";
        ITEM_MOD_HEALTH_REGENERATION_SHORT = "生命值恢复";
        ITEM_MOD_HEALTH_REGEN_SHORT = "每5秒的生命值恢复";
        ITEM_MOD_HEALTH_SHORT = "生命值";
        ITEM_MOD_HIT_MELEE_RATING = "近战命中提高%s点。";
        ITEM_MOD_HIT_MELEE_RATING_SHORT = "命中（近战）";
        ITEM_MOD_HIT_RANGED_RATING = "远程命中提高%s点。";
        ITEM_MOD_HIT_RANGED_RATING_SHORT = "命中（远程）";
        ITEM_MOD_HIT_RATING = "使你的命中提高%s点。";
        ITEM_MOD_HIT_RATING_SHORT = "命中";
        ITEM_MOD_HIT_SPELL_RATING = "法术命中提高%s点。";
        ITEM_MOD_HIT_SPELL_RATING_SHORT = "命中（法术）";
        ITEM_MOD_HIT_TAKEN_MELEE_RATING = "近战命中躲闪提高%s点。";
        ITEM_MOD_HIT_TAKEN_MELEE_RATING_SHORT = "命中躲闪（近战）";
        ITEM_MOD_HIT_TAKEN_RANGED_RATING = "远程命中躲闪提高%s点。";
        ITEM_MOD_HIT_TAKEN_RANGED_RATING_SHORT = "命中躲闪（远程）";
        ITEM_MOD_HIT_TAKEN_RATING = "命中躲闪提高%s点。";
        ITEM_MOD_HIT_TAKEN_RATING_SHORT = "命中躲闪";
        ITEM_MOD_HIT_TAKEN_SPELL_RATING = "法术命中躲闪提高%s点。";
        ITEM_MOD_HIT_TAKEN_SPELL_RATING_SHORT = "命中躲闪（法术）";
        ITEM_MOD_INSPIRATION_SHORT = "灵感";
        ITEM_MOD_INTELLECT = "%c%s 智力";
        ITEM_MOD_INTELLECT_SHORT = "智力";
        ITEM_MOD_MANA = "%c%s 法力值";
        ITEM_MOD_MANA_REGENERATION = "每5秒回复%s点法力值。";
        ITEM_MOD_MANA_REGENERATION_SHORT = "法力回复";
        ITEM_MOD_MANA_SHORT = "法力值";
        ITEM_MOD_MASTERY_RATING = "使你的精通提高%s点。";
        ITEM_MOD_MASTERY_RATING_SHORT = "精通";
        ITEM_MOD_MASTERY_RATING_SPELL = "(%s)";
        ITEM_MOD_MASTERY_RATING_TWO_SPELLS = "(%s/%s)";
        ITEM_MOD_MELEE_ATTACK_POWER_SHORT = "近战攻击强度";
        ITEM_MOD_MODIFIED_CRAFTING_STAT_1 = "随机属性1";
        ITEM_MOD_MODIFIED_CRAFTING_STAT_2 = "随机属性2";
        ITEM_MOD_MULTICRAFT_SHORT = "产能";
        ITEM_MOD_PARRY_RATING = "使你的招架提高%s点。";
        ITEM_MOD_PARRY_RATING_SHORT = "招架";
        ITEM_MOD_PERCEPTION_SHORT = "感知";
        ITEM_MOD_POWER_REGEN0_SHORT = "每5秒的法力值恢复";
        ITEM_MOD_POWER_REGEN1_SHORT = "每5秒的怒气增长";
        ITEM_MOD_POWER_REGEN2_SHORT = "每5秒的专注获得";
        ITEM_MOD_POWER_REGEN3_SHORT = "每5秒的能量恢复";
        ITEM_MOD_POWER_REGEN4_SHORT = "每5秒的快乐值获得";
        ITEM_MOD_POWER_REGEN5_SHORT = "每5秒的符文恢复";
        ITEM_MOD_POWER_REGEN6_SHORT = "每5秒的符文能量恢复";
        ITEM_MOD_PVP_POWER = "使你的PvP强度提高%s点。";
        ITEM_MOD_PVP_POWER_SHORT = "PvP强度";
        ITEM_MOD_PVP_PRIMARY_STAT_SHORT = "PvP强度";
        ITEM_MOD_RANGED_ATTACK_POWER = "远程攻击强度提高%s点。";
        ITEM_MOD_RANGED_ATTACK_POWER_SHORT = "远程攻击强度";
        ITEM_MOD_RESILIENCE_RATING = "使你的PvP韧性提高%s点。";
        ITEM_MOD_RESILIENCE_RATING_SHORT = "PvP韧性";
        ITEM_MOD_RESOURCEFULNESS_SHORT = "充裕";
        ITEM_MOD_SPELL_DAMAGE_DONE = "魔法法术和效果的伤害量提高最多%s点。";
        ITEM_MOD_SPELL_DAMAGE_DONE_SHORT = "伤害加成";
        ITEM_MOD_SPELL_HEALING_DONE = "魔法法术和效果的治疗量提高最多%s点。";
        ITEM_MOD_SPELL_HEALING_DONE_SHORT = "治疗加成";
        ITEM_MOD_SPELL_PENETRATION = "法术穿透提高%s点。";
        ITEM_MOD_SPELL_PENETRATION_SHORT = "法术穿透";
        ITEM_MOD_SPELL_POWER = "法术强度提高%s点。";
        ITEM_MOD_SPELL_POWER_SHORT = "法术强度";
        ITEM_MOD_SPIRIT = "%c%s 精神";
        ITEM_MOD_SPIRIT_SHORT = "精神";
        ITEM_MOD_STAMINA = "%c%s 耐力";
        ITEM_MOD_STAMINA_SHORT = "耐力";
        ITEM_MOD_STRENGTH = "%c%s 力量";
        ITEM_MOD_STRENGTH_OR_INTELLECT_SHORT = "力量或智力";
        ITEM_MOD_STRENGTH_SHORT = "力量";
        ITEM_MOD_VERSATILITY = "全能";
end


local function Init_Loaded(arg1)
    if arg1=='Blizzard_AuctionHouseUI' then
        local strText={
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
                [GetItemSubClassInfo(9, 9)] = "钓鱼",
                [GetItemSubClassInfo(9, 0)] = "书籍",
            [AUCTION_CATEGORY_PROFESSION_EQUIPMENT] = "专业装备",
                [GetItemSubClassInfo(19, 5)] = "采矿",
                [GetItemSubClassInfo(19, 3)] = "草药学",
                [GetItemSubClassInfo(19, 10)] = "剥皮",
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
        }

        hooksecurefunc('AuctionHouseFilterButton_SetUp', function(btn, info)
            set(btn, strText[info.name])
        end)

        set(AuctionHouseFrameBuyTab.Text, '购买')
        set(AuctionHouseFrameSellTab.Text, '出售')
        set(AuctionHouseFrameAuctionsTab.Text, '拍卖')
        set(AuctionHouseFrameAuctionsFrameAuctionsTab.Text, '拍卖')
        set(AuctionHouseFrameAuctionsFrameBidsTab.Text, '竞标')
        set(AuctionHouseFrameAuctionsFrameBidsTab.Text, '竞标')
        set(AuctionHouseFrameAuctionsFrameText, '一口价')

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
            self.PriceInput:SetLabel('一口价')--AUCTION_HOUSE_BUYOUT_LABEL);
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

    elseif arg1=='Blizzard_ClassTalentUI' then--Blizzard_TalentUI.lua
         for _, tabID in pairs(ClassTalentFrame:GetTabSet() or {}) do
            local btn= ClassTalentFrame:GetTabButton(tabID)
           if btn then
            if tabID==1 then
                set(btn, '专精')
            elseif tabID==2 then
                set(btn, '天赋')
            end
           end
        end
        set(ClassTalentFrame.TalentsTab.ApplyButton, '应用改动')
        PVP_LABEL_WAR_MODE = "战争模式";
        PVP_WAR_MODE_ENABLED = "开启";
        PVP_WAR_MODE_DESCRIPTION = "加入战争模式即可激活世界PvP，使任务的奖励和经验值最多提高10%，并可以在野外使用PvP天赋。";
        PVP_WAR_MODE_DESCRIPTION_FORMAT = "加入战争模式即可激活世界PvP，使任务的奖励和经验值提高%1$d%%，并可以在野外使用PvP天赋。";
        SPELL_FAILED_AFFECTING_COMBAT = "你正处于交战状态";
        PVP_WAR_MODE_NOT_NOW_ALLIANCE = "只能在暴风城或瓦德拉肯进入战争模式。";
        PVP_WAR_MODE_NOT_NOW_ALLIANCE_RESTAREA = "战争模式可以在任何休息区域关闭，但只能在暴风城或瓦德拉肯开启。";
        PVP_WAR_MODE_NOT_NOW_HORDE = "只能在奥格瑞玛或瓦德拉肯进入战争模式。";
        PVP_WAR_MODE_NOT_NOW_HORDE_RESTAREA = "战争模式可以在任何休息区域关闭，但只能在奥格瑞玛或瓦德拉肯开启。";

        WAR_MODE_CALL_TO_ARMS = "战争模式：战斗的召唤";
        WAR_MODE_BONUS_INCENTIVE_TOOLTIP = "战争模式的加成提升至%2$d%%。";
    end
end






















local function cancel_all()
    Init=function() end
    Init_Loaded= function() end
    panel:UnregisterEvent('ADDON_LOADED')
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_LOGOUT')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if not e.onlyChinese then
                cancel_all()
                return
            end

            Save= WoWToolsSave[addName] or Save

            --添加控制面板
            e.AddPanel_Check({
                name= '|cnRED_FONT_COLOR:'..(e.onlyChinese and '语言翻译' or addName),
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