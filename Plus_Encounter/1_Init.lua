local P_Save={
    wowBossKill={},
    loot= {},--[WoWTools_DataMixin.Player.Class]= {}
    favorites={},--副本收藏 WoWTools_DataMixin.Player.GUID= {}
}









local function Save()
    return WoWToolsSave['Adventure_Journal']
end





--################
--冒险指南界面初始化
--################
local function Init_EncounterJournal()--冒险指南界面
    WoWTools_EncounterMixin:Button_Init()
    WoWTools_EncounterMixin:Init_EncounterJournalItemMixin()--Boss, 战利品, 信息
    WoWTools_EncounterMixin:Init_mapButton_OnEnter()
    WoWTools_EncounterMixin:Init_UI_ListInstances()--界面, 副本击杀
    WoWTools_EncounterMixin:Set_RightAllInfo()--冒险指南,右边,显示所数据
    WoWTools_EncounterMixin:Init_MonthlyActivities()--贸易站
    WoWTools_EncounterMixin:Init_ItemSets() --战利品, 套装, 收集数
    WoWTools_EncounterMixin:Init_Model_Boss()--BOSS模型 
    WoWTools_EncounterMixin:Init_Spell_Boss()--技能提示
    WoWTools_EncounterMixin:Init_Specialization_Loot()--BOSS战时, 指定拾取, 专精


    --[[if not Save().hideEncounterJournal and Save().EncounterJournalTier and not InCombatLockdown() then--记录上次选择TAB
        local max= EJ_GetNumTiers()
        if max then
            local tier= math.min(Save().EncounterJournalTier, max)
            if tier~= max then
                EJ_SelectTier(tier)
            end
        end
    end

    --记录上次选择版本
    WoWTools_DataMixin:Hook('EJ_SelectTier', function(tier)
        Save().EncounterJournalTier=tier
    end)]]

    Init_EncounterJournal=function()end
end









local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('UPDATE_INSTANCE_INFO')
panel:RegisterEvent('WEEKLY_REWARDS_UPDATE')
panel:RegisterEvent('PLAYER_ENTERING_WORLD')

panel:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Adventure_Journal']= WoWToolsSave['Adventure_Journal'] or P_Save

            Save().loot[WoWTools_DataMixin.Player.Class]= Save().loot[WoWTools_DataMixin.Player.Class] or {}--这个不能删除，不然换职业会出错
            Save().favorites[WoWTools_DataMixin.Player.GUID]= Save().favorites[WoWTools_DataMixin.Player.GUID] or {}

            WoWTools_EncounterMixin.addName= '|A:UI-HUD-MicroMenu-AdventureGuide-Mouseover:0:0|a'..(WoWTools_DataMixin.onlyChinese and '冒险指南' or ADVENTURE_JOURNAL)

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_EncounterMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(WoWTools_EncounterMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if Save().disabled then
                self:UnregisterAllEvents()
            else

                if C_AddOns.IsAddOnLoaded('Blizzard_EncounterJournal') then
                    Init_EncounterJournal()--冒险指南界面
                    self:UnregisterEvent(event)
                end
            end

            self:RegisterEvent('BOSS_KILL')

        elseif arg1=='Blizzard_EncounterJournal' and WoWToolsSave then---冒险指南
            Init_EncounterJournal()--冒险指南界面
            self:UnregisterEvent(event)
        end

    elseif event=='BOSS_KILL' then--记录，没删除
        if arg1 then
            Save().wowBossKill[arg1]= Save().wowBossKill[arg1] and Save().wowBossKill[arg1] +1 or 1--Boss击杀数量
        end

    elseif event=='UPDATE_INSTANCE_INFO' then
        C_Timer.After(2, function()
            --WoWTools_EncounterMixin:InstanceBoss_Settings()--显示副本击杀数据
            --WoWTools_EncounterMixin:WorldBoss_Settings()--显示世界BOSS击杀数据Text
            WoWTools_EncounterMixin:Set_RightAllInfo()--冒险指南,右边,显示所数据
        end)

    elseif event=='WEEKLY_REWARDS_UPDATE' then
        C_Timer.After(2, function()
            WoWTools_EncounterMixin:Set_RightAllInfo()--冒险指南,右边,显示所数据
        end)

    elseif event=='PLAYER_ENTERING_WORLD' then
        WoWTools_EncounterMixin:Init_DungeonEntrancePin()--世界地图，副本，提示
        --WoWTools_EncounterMixin:WorldBoss_Settings()
        --WoWTools_EncounterMixin:InstanceBoss_Settings()
        self:UnregisterEvent(event)
    end
end)