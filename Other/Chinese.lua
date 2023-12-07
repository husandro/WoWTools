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

PRIMARY_STAT1_TOOLTIP_NAME = "力量";
PRIMARY_STAT2_TOOLTIP_NAME = "敏捷";
PRIMARY_STAT3_TOOLTIP_NAME = "耐力";
PRIMARY_STAT4_TOOLTIP_NAME = "智力";
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



end

--[[hooksecurefunc('PaperDollFrame_SetLabelAndText', function(frame, text)--不要删除
        if text== STAT_HASTE then
            set(frame.Label, '急速')
        end
    end)]]






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
                tooltip= '仅限中文|nChinese only',
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