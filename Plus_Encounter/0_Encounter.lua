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
    WoWTools_EncounterMixin:Init_UI_ListInstances()--界面, 副本击杀
    WoWTools_EncounterMixin:Set_RightAllInfo()--冒险指南,右边,显示所数据
    WoWTools_EncounterMixin:Init_MonthlyActivities()--贸易站
    WoWTools_EncounterMixin:Init_ItemSets() --战利品, 套装, 收集数
    WoWTools_EncounterMixin:Init_Model_Boss()--BOSS模型 
    WoWTools_EncounterMixin:Init_Spell_Boss()--技能提示
    WoWTools_EncounterMixin:Init_Specialization_Loot()--BOSS战时, 指定拾取, 专精


    if not Save().hideEncounterJournal and Save().EncounterJournalTier then--记录上次选择TAB
        local max= EJ_GetNumTiers()
        if max then
            local tier= math.min(Save().EncounterJournalTier, max)
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




local function Init()
    WoWTools_EncounterMixin:Init_DungeonEntrancePin()--世界地图，副本，提示
    WoWTools_EncounterMixin:WorldBoss_Settings()
    WoWTools_EncounterMixin:InstanceBoss_Settings()

    EventRegistry:RegisterFrameEventAndCallback("UPDATE_INSTANCE_INFO", function(owner, arg1)
        C_Timer.After(2, function()
            WoWTools_EncounterMixin:InstanceBoss_Settings()--显示副本击杀数据
            WoWTools_EncounterMixin:WorldBoss_Settings()--显示世界BOSS击杀数据Text
            WoWTools_EncounterMixin:Set_RightAllInfo()--冒险指南,右边,显示所数据
        end)
    end)

    EventRegistry:RegisterFrameEventAndCallback("BOSS_KILL", function(_, arg1)
        if arg1 then
            Save().wowBossKill[arg1]= Save().wowBossKill[arg1] and Save().wowBossKill[arg1] +1 or 1--Boss击杀数量
        end
    end)

    EventRegistry:RegisterFrameEventAndCallback("WEEKLY_REWARDS_UPDATE", function(owner, arg1)
        C_Timer.After(2, function()
            WoWTools_EncounterMixin:Set_RightAllInfo()--冒险指南,右边,显示所数据
        end)
    end)
end







local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWTools_EncounterMixin.Save= WoWToolsSave['Adventure_Journal'] or Save()

            Save().loot[e.Player.class]= Save().loot[e.Player.class] or {}--这个不能删除，不然换职业会出错

            WoWTools_EncounterMixin.addName= '|A:UI-HUD-MicroMenu-AdventureGuide-Mouseover:0:0|a'..(WoWTools_Mixin.onlyChinese and '冒险指南' or ADVENTURE_JOURNAL)

            --添加控制面板
            e.AddPanel_Check({
                name= WoWTools_EncounterMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(WoWTools_EncounterMixin.addName, e.GetEnabeleDisable(not Save().disabled), WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if Save().disabled then
                self:UnregisterEvent(event)
            else
                Init()
            end

        elseif arg1=='Blizzard_EncounterJournal' then---冒险指南
            Init_EncounterJournal()--冒险指南界面
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Adventure_Journal']=Save()
        end
    end
end)