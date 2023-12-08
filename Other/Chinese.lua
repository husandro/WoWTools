local id, e= ...
if LOCALE_zhCN or LOCALE_zhTW or not e.Player.husandro then
    return
end


local addName= BUG_CATEGORY15
local Save={
    disabled= e.Player.husandro
}




local function set(self, text)
    if not self then
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

    --法术
    set(SpellBookFrameTabButton1, '法术')
    set(SpellBookFrameTabButton2, '专业')
    set(SpellBookFrameTabButton3, '宠物')

    
STR_LCD = "力量";
INT_LCD = "智力";
PRIMARY_STAT1_TOOLTIP_NAME = "力量";
PRIMARY_STAT2_TOOLTIP_NAME = "敏捷";
PRIMARY_STAT3_TOOLTIP_NAME = "耐力";
PRIMARY_STAT4_TOOLTIP_NAME = "智力";
SPEC_FRAME_PRIMARY_STAT = "主要属性：%s";
SPEC_FRAME_PRIMARY_STAT_AGILITY = "敏捷";
SPEC_FRAME_PRIMARY_STAT_INTELLECT = "智力";
SPELL_STAT1_NAME = "力量";
SPELL_STAT2_NAME = "敏捷";
SPELL_STAT3_NAME = "耐力";
SPELL_STAT4_NAME = "智力";
SPELL_STAT5_NAME = "精神";



PARRY_LCD = "招架 %.2f";
PARRIED = "招架";
PARRY = "招架";
PARRY_CHANCE = "招架几率";
DEFENSE = "防御";
DEFLECT = "偏转";
ARMOR = "护甲";
ARMOR_TEMPLATE = "%s点护甲";
RESILIENCE_LCD = "韧性 %d";

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

DEFENSE_TOOLTIP = "防御";


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

ITEMS = "物品";
ITEMSLOTTEXT = "物品栏位";
ITEMS_EQUIPPED = "已装备%d件物品";
ITEMS_IN_INVENTORY = "背包中有%d件物品";
ITEMS_NOT_IN_INVENTORY = "缺少%d件物品";
ITEMS_VARIABLE_QUANTITY = "%d件物品";
ITEM_ACCOUNTBOUND = "账号绑定";
ITEM_ARTIFACT_VIEWABLE = "<Shift+右键点击查看神器>";
ITEM_AZERITE_EMPOWERED_VIEWABLE = "<Shift+右键点击查看艾泽里特之力>";
ITEM_AZERITE_ESSENCES_VIEWABLE = "<Shift+右键点击查看精华>";
ITEM_BIND_ON_EQUIP = "装备后绑定";
ITEM_BIND_ON_PICKUP = "拾取后绑定";
ITEM_BIND_ON_USE = "使用后绑定";
ITEM_BIND_QUEST = "任务物品";
ITEM_BIND_TO_ACCOUNT = "账号绑定";
ITEM_BIND_TO_BNETACCOUNT = "绑定至暴雪游戏通行证";
ITEM_BNETACCOUNTBOUND = "暴雪游戏通行证绑定";
ITEM_CANT_BE_DESTROYED = "这件物品无法被摧毁。";
ITEM_CAN_BE_READ = "<可以阅读该物品>";
ITEM_CHARGEUP_TOTAL = "（需要%s）";
ITEM_CHARGEUP_TOTAL_DAYS = "（需要%d天）";
ITEM_CHARGEUP_TOTAL_HOURS = "（需要%d小时）";
ITEM_CHARGEUP_TOTAL_MIN = "（需要%d分钟）";
ITEM_CHARGEUP_TOTAL_SEC = "（需要%d秒）";
ITEM_CLASSES_ALLOWED = "职业：%s";
ITEM_COMPARISON_CYCLING_DISABLED_MSG_MAINHAND = "访问按键设置菜单，开启主手物品的循环比较。（推荐快捷键：SHIFT-C）";
ITEM_COMPARISON_CYCLING_DISABLED_MSG_OFFHAND = "访问按键设置菜单，开启副手物品的循环比较。（推荐快捷键：SHIFT-C）";
ITEM_COMPARISON_RELIC_BONUS_RANKS = "%d级";
ITEM_COMPARISON_SWAP_ITEM_MAINHAND_DESCRIPTION = "按%s来切换用于搭配的主手物品。";
ITEM_COMPARISON_SWAP_ITEM_OFFHAND_DESCRIPTION = "按%s来切换用于搭配的副手物品。";
ITEM_CONJURED = "魔法制造的物品";
ITEM_CONTAINER = "容器";
ITEM_COOLDOWN_TIME = "冷却时间剩余：%s";
ITEM_COOLDOWN_TIME_DAYS = "剩余冷却时间：%d天";
ITEM_COOLDOWN_TIME_HOURS = "剩余冷却时间：%d小时";
ITEM_COOLDOWN_TIME_MIN = "冷却时间剩余：%d 分钟";
ITEM_COOLDOWN_TIME_SEC = "冷却时间剩余：%d秒";
ITEM_COOLDOWN_TOTAL = "（%s冷却）";
ITEM_COOLDOWN_TOTAL_DAYS = "(%d天冷却时间)";
ITEM_COOLDOWN_TOTAL_HOURS = "(%d小时冷却时间)";
ITEM_COOLDOWN_TOTAL_MIN = "(%d分钟冷却时间)";
ITEM_COOLDOWN_TOTAL_SEC = "(%d秒冷却时间)";
ITEM_CORRUPTION_BONUS_STAT = "+%d 腐蚀";
ITEM_COSMETIC = "装饰品";
ITEM_COSMETIC_LEARN = "使用：将此外观添加到你的收藏中。";
ITEM_CREATED_BY = "|cff00ff00<由%s制造>|r";
ITEM_CREATE_LOOT_SPEC_ITEM = "使用：制造一件适用于你当前拾取专精(%s)的灵魂绑定物品。";
ITEM_DELTA_DESCRIPTION = "如果你替换该物品，将会产生以下的属性变更：";
ITEM_DELTA_DUAL_WIELD_COMPARISON_MAINHAND_DESCRIPTION = "（与搭配了主手装备|c%s%s|r后相比）";
ITEM_DELTA_DUAL_WIELD_COMPARISON_OFFHAND_DESCRIPTION = "（与搭配了副手装备|c%s%s|r后相比）";
ITEM_DELTA_MULTIPLE_COMPARISON_DESCRIPTION = "如果你替换这些物品，将会产生以下的属性变更：";
ITEM_DISENCHANT_ANY_SKILL = "可分解";
ITEM_DISENCHANT_MIN_SKILL = "分解需要%s (%d)";
ITEM_DISENCHANT_NOT_DISENCHANTABLE = "无法分解";
ITEM_DURATION_DAYS = "持续时间：%d天";
ITEM_DURATION_HOURS = "持续时间：%d小时";
ITEM_DURATION_MIN = "持续时间：%d分钟";
ITEM_DURATION_SEC = "持续时间：%d秒";
ITEM_ENCHANT_DISCLAIMER = "物品将不会被交易！";
ITEM_ENCHANT_TIME_LEFT_DAYS = "%s（%d天）";
ITEM_ENCHANT_TIME_LEFT_HOURS = "%s（%d小时）";
ITEM_ENCHANT_TIME_LEFT_MIN = "%s（%d分钟）";
ITEM_ENCHANT_TIME_LEFT_SEC = "%s（%d秒）";
ITEM_GLYPH_ONUSE = "永久教会你使用这个雕文。";
ITEM_HEROIC = "英雄";
ITEM_HEROIC_EPIC = "英雄级别史诗品质";
ITEM_HEROIC_QUALITY0_DESC = "英雄粗糙";
ITEM_HEROIC_QUALITY1_DESC = "英雄普通";
ITEM_HEROIC_QUALITY2_DESC = "英雄优秀";
ITEM_HEROIC_QUALITY3_DESC = "英雄稀有";
ITEM_HEROIC_QUALITY4_DESC = "英雄史诗";
ITEM_HEROIC_QUALITY5_DESC = "英雄传说";
ITEM_HEROIC_QUALITY6_DESC = "英雄神器";
ITEM_HEROIC_QUALITY7_DESC = "英雄传家宝";
ITEM_IS_NOT_AZERITE_EMPOWERED = "这个物品没有被艾泽里特强化";
ITEM_LEGACY_INACTIVE_EFFECTS = "传承物品：效果未激活";
ITEM_LEVEL = "物品等级%d";
ITEM_LEVEL_ABBR = "iLvl";
ITEM_LEVEL_ALT = "物品等级%d (%d)";
ITEM_LEVEL_AND_MIN = "等级 %d （最小 %d）";
ITEM_LEVEL_PLUS = "物品等级%d+";
ITEM_LEVEL_RANGE = "需要等级%d到%d";
ITEM_LEVEL_RANGE_CURRENT = "需要等级 %d到%d （%d）";
ITEM_LEVEL_UPGRADE_MAX = "物品等级 %d";
ITEM_LIMIT_CATEGORY = "唯一：%s（%d）";
ITEM_LIMIT_CATEGORY_MULTIPLE = "装备唯一：%s （%d）";
ITEM_LOOT = "物品拾取";
ITEM_MILLABLE = "可研磨";
ITEM_MIN_LEVEL = "需要等级 %d";
ITEM_MIN_SKILL = "需要%s（%d）";
ITEM_MISSING = "%s缺失";
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
ITEM_MOD_CR_UNUSED_10_SHORT = "Unused 10";
ITEM_MOD_CR_UNUSED_11_SHORT = "Unused 11";
ITEM_MOD_CR_UNUSED_12_SHORT = "Unused 12";
ITEM_MOD_CR_UNUSED_1_SHORT = "Multi-Strike";
ITEM_MOD_CR_UNUSED_3_SHORT = "Speed";
ITEM_MOD_CR_UNUSED_4_SHORT = "Leech";
ITEM_MOD_CR_UNUSED_5_SHORT = "Avoidance";
ITEM_MOD_CR_UNUSED_6_SHORT = "永不磨损";
ITEM_MOD_CR_UNUSED_7_SHORT = "Unused 7";
ITEM_MOD_CR_UNUSED_9_SHORT = "Versatility";
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
ITEM_MOUSE_OVER = "将鼠标移动到图标上可以获得更多的信息";
ITEM_NAMES = "物品名";
ITEM_NAMES_SHOW_BRACES_COMBATLOG_TOOLTIP = "在物品名称外显示括号。";
ITEM_NAME_DESCRIPTION_DELIMITER = " ";
ITEM_NO_DROP = "无法丢弃";
ITEM_OBLITERATEABLE = "可拆解";
ITEM_OBLITERATEABLE_NOT = "无法拆解";
ITEM_ONLY_TOURNAMENT_GEAR_ALLOWED = "本次战争游戏只能使用竞技装备。";
ITEM_OPENABLE = "<右键点击打开>";
ITEM_PET_KNOWN = "已收集（%d/%d）";
ITEM_PROPOSED_ENCHANT = "将获得%s的效果。";
ITEM_PROSPECTABLE = "可选矿";
ITEM_PURCHASED_COLON = "物品购入：";
ITEM_QUALITY0_DESC = "粗糙";
ITEM_QUALITY1_DESC = "普通";
ITEM_QUALITY2_DESC = "优秀";
ITEM_QUALITY3_DESC = "精良";
ITEM_QUALITY4_DESC = "史诗";
ITEM_QUALITY5_DESC = "传说";
ITEM_QUALITY6_DESC = "神器";
ITEM_QUALITY7_DESC = "传家宝";
ITEM_QUALITY8_DESC = "时光徽章";
ITEM_QUANTITY_TEMPLATE = "%1$d %2$s";
ITEM_RACES_ALLOWED = "种族：%s";
ITEM_RANDOM_ENCHANT = "<随机额外属性>";
ITEM_READABLE = "<右键点击阅读>";
ITEM_REFUND_MSG = "物品已退还。获得退款：";
ITEM_RELIC_VIEWABLE = "<右键点击查看装备的神器>";
ITEM_REQ_ALLIANCE = "只限联盟";
ITEM_REQ_AMOUNT_EARNED = "需要在本赛季总共获得%1$d\n%2$s。";
ITEM_REQ_ARENA_RATING = "需要个人竞技场等级达到%d";
ITEM_REQ_ARENA_RATING_3V3 = "需要3v3的个人竞技场等级达到%d|n";
ITEM_REQ_ARENA_RATING_3V3_BG = "需要战场等级达到%d或者|n3v3的个人|n竞技场等级达到%d";
ITEM_REQ_ARENA_RATING_5V5 = "需要5v5的个人竞技场等级达到%d|n";
ITEM_REQ_ARENA_RATING_BG = "需要战场等级达到%d或者|n个人竞技场等级达到%d";
ITEM_REQ_HORDE = "只限部落";
ITEM_REQ_PURCHASE_ACHIEVEMENT = "需要成就：%s";
ITEM_REQ_PURCHASE_GUILD = "需要一个公会";
ITEM_REQ_PURCHASE_GUILD_LEVEL = "需要公会等级%d";
ITEM_REQ_REPUTATION = "需要 %s - %s";
ITEM_REQ_SKILL = "需要%s";
ITEM_REQ_SPECIALIZATION = "需要：%s";
ITEM_RESIST_ALL = "%c%d 所有抗性";
ITEM_RESIST_SINGLE = "%c%d %s抗性";
ITEM_SCRAPABLE = "可拆解";
ITEM_SCRAPABLE_NOT = "不可拆解";
ITEM_SET_BONUS = "套装：%s";
ITEM_SET_BONUS_GRAY = "(%d) 套装：%s";
ITEM_SET_BONUS_NO_VALID_SPEC = "套装奖励将根据玩家专精变化。";
ITEM_SET_LEGACY_INACTIVE_BONUS = "传承套装：套装奖励未激活";
ITEM_SET_NAME = "%s（%d/%d）";
ITEM_SIGNABLE = "<右键点击以了解详情>";
ITEM_SLOTS_IGNORED = "忽略%d个栏位";
ITEM_SOCKETABLE = "<Shift+右键点击打开镶嵌界面>";
ITEM_SOCKETING = "物品镶嵌";
ITEM_SOCKET_BONUS = "镶孔奖励：%s";
ITEM_SOLD_COLON = "物品售出：";
ITEM_SOULBOUND = "灵魂绑定";
ITEM_SPELL_CHARGES = "%d次";
ITEM_SPELL_CHARGES_NONE = "耗尽次数";
ITEM_SPELL_EFFECT = "效果：%s";
ITEM_SPELL_KNOWN = "已经学会";
ITEM_SPELL_MAX_USABLE_LEVEL = "（要求等级不高于%d）";
ITEM_SPELL_TRIGGER_ONEQUIP = "装备：";
ITEM_SPELL_TRIGGER_ONPROC = "击中时可能：";
ITEM_SPELL_TRIGGER_ONUSE = "使用：";
ITEM_STARTS_QUEST = "该物品将触发一个任务";
ITEM_SUFFIX_TEMPLATE = "%2$s%1$s";
ITEM_TEXT_FROM = "发信人，";
ITEM_TOURNAMENT_GEAR = "竞技装备";
ITEM_TOURNAMENT_GEAR_WARNING = "竞技装备只能在战争游戏中使用。";
ITEM_TOY_ONUSE = "使用：将该玩具添加到你的玩具箱。";
ITEM_UNIQUE = "唯一";
ITEM_UNIQUE_EQUIPPABLE = "装备唯一";
ITEM_UNIQUE_MULTIPLE = "唯一（%d）";
ITEM_UNSELLABLE = "无法出售";
ITEM_UPGRADE = "物品升级";
ITEM_UPGRADED_LABEL = "物品已升级！";
ITEM_UPGRADE_BONUS_DAMAGE_TEMPLATE = "|cff20ff20%1$s - %2$s|r点伤害";
ITEM_UPGRADE_BONUS_FORMAT = "(+%d) ";
ITEM_UPGRADE_BONUS_FORMAT_COLORIZED = "|cff20ff20%s (+%d)|r";
ITEM_UPGRADE_BONUS_STAT_FORMAT = "|cff20ff20%1$d (+%2$d)|r %3$s";
ITEM_UPGRADE_COST_LABEL = "总花费：";
ITEM_UPGRADE_CURRENT = "当前：";
ITEM_UPGRADE_DESCRIPTION = "许多可装备的物品都可以进行升级，从而提高其物品等级。不同来源的物品升级所需的货币也各不相同。";
ITEM_UPGRADE_DISCOUNT_ITEM_TYPE_FINGER = "戒指";
ITEM_UPGRADE_DISCOUNT_ITEM_TYPE_ONE_HANDED_WEAPON = "单手武器";
ITEM_UPGRADE_DISCOUNT_ITEM_TYPE_TRINKET = "饰品";
ITEM_UPGRADE_DISCOUNT_TOOLTIP_ACCOUNT_WIDE = "账号通用";
ITEM_UPGRADE_DISCOUNT_TOOLTIP_CURRENT_CHARACTER = "这次升级花费较少的%s，因为你已经在此栏位获得了更高物品等级（%d）的物品。";
ITEM_UPGRADE_DISCOUNT_TOOLTIP_OTHER_CHARACTER = "这次升级花费较少的%s，因为你账号上的一名角色已经在此栏位获得了更高物品等级（%d）的物品。";
ITEM_UPGRADE_DISCOUNT_TOOLTIP_PARTIAL_TWO_HAND_CURRENT_CHARACTER = "这次升级花费较少的%s，因为你已经拥有了一套更高物品等级（%d）的武器。";
ITEM_UPGRADE_DISCOUNT_TOOLTIP_PARTIAL_TWO_HAND_OTHER_CHARACTER = "这次升级花费较少的%s，因为你账号上的一名角色已经获得了一套更高物品等级（%d）的武器。";
ITEM_UPGRADE_DISCOUNT_TOOLTIP_TITLE = "%s折扣";
ITEM_UPGRADE_DISCOUNT_TOOLTIP_TWO_SLOT_CURRENT_CHARACTER = "这次升级花费较少的%1$s，因为你已经获得了两个更高物品等级（%3$d）的%2$s。";
ITEM_UPGRADE_DISCOUNT_TOOLTIP_TWO_SLOT_OTHER_CHARACTER = "这次升级花费较少的%1$s，因为你账号上的一名角色已经获得了两个更高物品等级（%3$d）的%2$s。";
ITEM_UPGRADE_DROPDOWN_LEVEL_FORMAT = "等级%d/%d";
ITEM_UPGRADE_DROPDOWN_LEVEL_FORMAT_STRING = "%s %d/%d";
ITEM_UPGRADE_ERROR_NOT_ENOUGH_CURRENCY = "%s不足。";
ITEM_UPGRADE_ERROR_NOT_ENOUGH_CURRENCY_DOWNGRADE = "较高等级的暗影烈焰纹章可以在峈姆的瓦斯卡尔恩处进行降级。";
ITEM_UPGRADE_ERROR_NOT_ENOUGH_CURRENCY_MULTIPLE = "升级货币不足。";
ITEM_UPGRADE_ERROR_NOT_ENOUGH_CURRENCY_TWO = "%s和%s不足。";
ITEM_UPGRADE_ERROR_UNDEFINED_MESSAGE = "该物品无法升级";
ITEM_UPGRADE_FRAGMENTS_TOTAL = "获得碎片：|c%s%s/%s|r";
ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT = "升级：%s/%s";
ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT_STRING = "升级：%s %s/%s";
ITEM_UPGRADE_FRAME_PREVIEW_RANK_TOOLTIP_ERROR = "需要之前的升级";
ITEM_UPGRADE_FRAME_UPGRADE_TO = "升级至：";
ITEM_UPGRADE_INACTIVE_BONUS_STAT_FORMAT = "|cff7f7f7f%1$d (+%2$d) %3$s|r";
ITEM_UPGRADE_INACTIVE_STAT_FORMAT = "|cff7f7f7f%1$d %2$s|r";
ITEM_UPGRADE_ITEM_LEVEL_BONUS_STAT_FORMAT = "物品等级 |cff20ff20%1$d(+%2$d)|r";
ITEM_UPGRADE_ITEM_LEVEL_STAT_FORMAT = "物品等级%d";
ITEM_UPGRADE_ITEM_UPGRADED_NOTIFICATION = "物品已升级";
ITEM_UPGRADE_MISSING_ITEM = "将物品拖曳至此处升级。";
ITEM_UPGRADE_NEXT_UPGRADE = "升级：";
ITEM_UPGRADE_NO_MORE_UPGRADES = "该物品不能再升级了。";
ITEM_UPGRADE_PROGRESS_ITEM_LEVEL_FORMAT = "%d |cnDISABLED_FONT_COLOR:(%d-%d)|r";
ITEM_UPGRADE_PROGRESS_LEVEL_FORMAT = "等级 %d/%d  %d |cnDISABLED_FONT_COLOR:(%d-%d)|r";
ITEM_UPGRADE_PROGRESS_LEVEL_FORMAT_STRING = "%s %d/%d  %d |cnDISABLED_FONT_COLOR:(%d-%d)|r";
ITEM_UPGRADE_PVP_ITEM_LEVEL_BONUS_STAT_FORMAT = "PvP物品等级 |cff20ff20%1$d(+%2$d)|r";
ITEM_UPGRADE_PVP_ITEM_LEVEL_STAT_FORMAT = "PvP物品等级 %d";
ITEM_UPGRADE_STAT_AVERAGE_ITEM_LEVEL = "物品等级";
ITEM_UPGRADE_STAT_FORMAT = "%1$d %2$s";
ITEM_UPGRADE_TOOLTIP_FORMAT = "升级：%d/%d";
ITEM_UPGRADE_TOOLTIP_FORMAT_STRING = "升级：%s %d/%d";
ITEM_UPGRADE_TUTORIAL_ITEM_IN_SLOT = "把这件装备带到主城的物品升级专员处提升其强度";
ITEM_VENDOR_STACK_BUY = "<按住Shift点击以购买不同数量>";
ITEM_WRAPPED_BY = "|cff00ff00<%s的礼物>|r";
ITEM_WRITTEN_BY = "由%s撰写";
ITEM_WRONG_CLASS = "你的职业无法使用这件物品！";
ITEM_WRONG_RACE = "你的种族无法使用这件物品！";
end






--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_LOGOUT')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if not e.onlyChinese then
                Init=function() end
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

            if not Save.disabled then
              Init()
            end

            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)