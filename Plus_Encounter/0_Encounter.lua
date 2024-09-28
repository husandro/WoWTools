local id, e = ...

WoWTools_EncounterMixin={
Save={
    wowBossKill={},
    loot= {[e.Player.class]= {}},
    favorites={},--副本收藏
},
addName=nil,
InstanceBossButton=nil,
WorldBossButton=nil,
}

function WoWTools_EncounterMixin:GetBossNameSort(name)--取得怪物名称, 短名称
    name= e.cn(name)
    name=name:gsub('(,.+)','')
    name=name:gsub('(，.+)','')
    name=name:gsub('·.+','')
    name=name:gsub('%-.+','')
    name=name:gsub('<.+>', '')
    return name
end






local function Save()
    return WoWTools_EncounterMixin.Save
end





--################
--冒险指南界面初始化
--################
local function Init_EncounterJournal()--冒险指南界面
    WoWTools_EncounterMixin:Button_Init()
    WoWTools_EncounterMixin:Init_EncounterJournalItemMixin()--Boss, 战利品, 信息
    WoWTools_EncounterMixin:Init_mapButton_OnEnter()
    WoWTools_EncounterMixin:Init_UI_ListInstances()
    WoWTools_EncounterMixin:Set_RightAllInfo()--冒险指南,右边,显示所数据
    WoWTools_EncounterMixin:Init_MonthlyActivities()--贸易站
    WoWTools_EncounterMixin:Init_ItemSets() --战利品, 套装, 收集数
    WoWTools_EncounterMixin:Init_Model_Boss()--BOSS模型 
    WoWTools_EncounterMixin:Init_Spell_Boss()--技能提示
    WoWTools_EncounterMixin:Init_Specialization_Loot()--BOSS战时, 指定拾取, 专精


    if not WoWTools_EncounterMixin.Save.hideEncounterJournal and WoWTools_EncounterMixin.Save.EncounterJournalTier then--记录上次选择TAB
        local max= EJ_GetNumTiers()
        if max then
            local tier= math.min(WoWTools_EncounterMixin.Save.EncounterJournalTier, max)
            if tier~= max then
                EJ_SelectTier(tier)
            end
        end
    end

    --记录上次选择版本
    hooksecurefunc('EJ_SelectTier', function(tier)
        Save().EncounterJournalTier=tier
    end)
end










--###########
--加载保存数据
--###########
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then

            WoWTools_EncounterMixin.Save= WoWToolsSave['Adventure_Journal'] or Save()

            Save().loot[e.Player.class]= Save().loot[e.Player.class] or {}

            WoWTools_EncounterMixin.addName= '|A:UI-HUD-MicroMenu-AdventureGuide-Mouseover:0:0|a'..(e.onlyChinese and '冒险指南' or ADVENTURE_JOURNAL)

            --添加控制面板
            e.AddPanel_Check({
                name= WoWTools_EncounterMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(WoWTools_EncounterMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if not Save().disabled then
                WoWTools_EncounterMixin:Init_DungeonEntrancePin()--世界地图，副本，提示
                WoWTools_EncounterMixin:WorldBoss_Settings()
                WoWTools_EncounterMixin:InstanceBoss_Settings()
                self:RegisterEvent('BOSS_KILL')
                self:RegisterEvent('UPDATE_INSTANCE_INFO')
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
                self:RegisterEvent('WEEKLY_REWARDS_UPDATE')

            else
                self:UnregisterEvent('ADDON_LOADED')
            end

        elseif arg1=='Blizzard_EncounterJournal' then---冒险指南
            Init_EncounterJournal()--冒险指南界面
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Adventure_Journal']=Save
        end

    elseif event=='UPDATE_INSTANCE_INFO' then
        C_Timer.After(2, function()
            WoWTools_EncounterMixin:InstanceBoss_Settings()--显示副本击杀数据
            WoWTools_EncounterMixin:WorldBoss_Settings()--显示世界BOSS击杀数据Text
            WoWTools_EncounterMixin:Set_RightAllInfo()--冒险指南,右边,显示所数据
        end)

    elseif event=='BOSS_KILL' and arg1 then
        Save().wowBossKill[arg1]= Save().wowBossKill[arg1] and Save().wowBossKill[arg1] +1 or 1--Boss击杀数量

    elseif event=='WEEKLY_REWARDS_UPDATE' then
        C_Timer.After(2, function()
            WoWTools_EncounterMixin:Set_RightAllInfo()--冒险指南,右边,显示所数据
        end)
    end
end)