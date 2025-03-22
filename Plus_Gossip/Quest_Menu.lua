local e= select(2, ...)
local function Save()
    return WoWTools_GossipMixin.Save
end









local function Init_Menu(self, root)
    local sub, sub2, num

--启用
    sub=root:CreateCheckbox(
        (WoWTools_Mixin.onlyChinese and '启用' or ENABLE)
        ..'|A:UI-HUD-UnitFrame-Target-PortraitOn-Boss-Quest:0:0|a',
    function()
        return Save().quest
    end, function()
        Save().quest= not Save().quest and true or nil
        self:set_Texture()--设置，图片
        self:tooltip_Show()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('Alt+'..(WoWTools_Mixin.onlyChinese and '暂时禁用' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, BOOSTED_CHAR_SPELL_TEMPLOCK, DISABLE)))
    end)

--低等级任务
    sub2=sub:CreateCheckbox(
        '|A:TrivialQuests:0:0|a'..(WoWTools_Mixin.onlyChinese and '低等级任务' or MINIMAP_TRACKING_TRIVIAL_QUESTS),--低等任务
    function()
        return WoWTools_MapMixin:Get_Minimap_Tracking(MINIMAP_TRACKING_TRIVIAL_QUESTS, false)
    end, function()
        WoWTools_MapMixin:Get_Minimap_Tracking(MINIMAP_TRACKING_TRIVIAL_QUESTS, true)
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..(WoWTools_Mixin.onlyChinese and '追踪' or TRACKING))
    end)

--自动:选择奖励
    root:CreateDivider()
    num=0
    for _ in pairs(Save().questRewardCheck) do
        num=num+1
    end
    sub=root:CreateCheckbox(
        (WoWTools_Mixin.onlyChinese and '自动选择奖励' or format(TITLE_REWARD, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, CHOOSE)))
        ..(num==0 and ' |cff9e9e9e' or ' ')
        ..num,
    function()
        return Save().autoSelectReward
    end, function()
        Save().autoSelectReward= not Save().autoSelectReward and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '最高品质' or format(PROFESSIONS_CRAFTING_QUALITY, VIDEO_OPTIONS_ULTRA_HIGH))
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '稀有' or GARRISON_MISSION_RARE)
        tooltip:AddLine('|cff0000ff'..(WoWTools_Mixin.onlyChinese and '稀有' or GARRISON_MISSION_RARE)..'|r')
    end)

--子目录，自动:选择奖励
    for questID, index in pairs(Save().questRewardCheck) do
        WoWTools_Mixin:Load({id=questID, type='quest'})
        sub2=sub:CreateCheckbox(
            WoWTools_QuestMixin:GetName(questID)..' |cnGREEN_FONT_COLOR:'..index,
        function(data)
            return Save().questRewardCheck[data.questID]
        end, function(data)
            Save().questRewardCheck[data.questID]= not Save().questRewardCheck[data.questID] and data.index or nil
        end, {questID=questID, index=index})
        WoWTools_SetTooltipMixin:Set_Menu(sub2)
    end
    if num>1 then
        sub:CreateDivider()
        sub:CreateButton(
            WoWTools_Mixin.onlyChinese and '清除全部' or CLEAR_ALL,
        function()
            Save().questRewardCheck={}
        end)
        WoWTools_MenuMixin:SetGridMode(sub, num)
    end

    
--自定义任务
    num=0
    for _ in pairs(Save().questOption) do
        num=num+1
    end
    sub=root:CreateButton(
        '     '..(WoWTools_Mixin.onlyChinese and '自定义任务' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CUSTOM, QUESTS_LABEL))
        ..(num==0 and ' |cff9e9e9e' or ' ')
        ..num,
    function()
        return MenuResponse.Open
    end)


--子目录，自定义任务
    for questID, text in pairs(Save().questOption) do
        WoWTools_Mixin:Load({type='quest', di=questID})
        sub2=sub:CreateCheckbox(
            WoWTools_QuestMixin:GetName(questID),
        function(data)
            return Save().questOption[data.questID]
        end, function(data)
            Save().questOption[data.questID]= not Save().questOption[data.questID] and data.text or nil
        end, {questID=questID, text=text})
        WoWTools_SetTooltipMixin:Set_Menu(sub2)
    end

    if num>1 then
        sub:CreateDivider()
        sub:CreateButton(
            WoWTools_Mixin.onlyChinese and '清除全部' or CLEAR_ALL,
        function()
            Save().questOption={}
        end)
        WoWTools_MenuMixin:SetGridMode(sub, num)
    end



--共享任务
    root:CreateDivider()
    sub=root:CreateCheckbox(
        (IsInGroup() and '' or '|cff9e9e9e')
        ..(WoWTools_Mixin.onlyChinese and '共享任务' or SHARE_QUEST)
        ..'|A:groupfinder-waitdot:0:0|a',
    function()
        return Save().pushable
    end, function()
        Save().pushable= not Save().pushable and true or nil
        self:set_Event()--设置事件
        self:set_PushableQuest()--共享,任务
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(
            WoWTools_Mixin.onlyChinese and '仅限在队伍中'
            or format(LFG_LIST_CROSS_FACTION, AGGRO_WARNING_IN_PARTY)
        )
    end)

--数量
    sub=root:CreateCheckbox(
        (WoWTools_Mixin.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL),
    function()
        return Save().showAllQuestNum
    end, function()
        Save().showAllQuestNum= not Save().showAllQuestNum and true or nil
        self:set_Quest_Num_Text()
        self:set_Event()--设置事件
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(
            WoWTools_Mixin.onlyChinese and '显示所有数量'
            or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, ALL)
        )
        tooltip:AddLine(
            WoWTools_Mixin.onlyChinese and '在副本中禁用|n任务>0'
            or (format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, AGGRO_WARNING_IN_INSTANCE, DISABLE)..'|n'..QUESTS_LABEL..' >0')
        )
    end)


--追踪
    root:CreateDivider()
    root:CreateTitle(WoWTools_Mixin.onlyChinese and '追踪' or TRACKING)

--自动任务追踪
    sub=root:CreateCheckbox(
        (WoWTools_Mixin.onlyChinese and '自动任务追踪' or AUTO_QUEST_WATCH_TEXT),
    function()
        return C_CVar.GetCVarBool("autoQuestWatch")
    end, function()
        if not UnitAffectingCombat('player') then
            C_CVar.SetCVar("autoQuestWatch", C_CVar.GetCVarBool("autoQuestWatch") and '0' or '1')
        end
    end)
    sub:SetTooltip(function (tooltip)
        tooltip:AddLine('CVar autoQuestWatch')
    end)
    sub:SetEnabled(not UnitAffectingCombat('player'))


--当前地图
    root:CreateCheckbox(
        WoWTools_Mixin.onlyChinese and '当前地图' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REFORGE_CURRENT, WORLD_MAP),
    function()
        return Save().autoSortQuest
    end, function()
        Save().autoSortQuest= not Save().autoSortQuest and true or nil
        self:set_Event()--仅显示本地图任务,事件
        self:set_Only_Show_Zone_Quest()--显示本区域任务
    end)


end
















function  WoWTools_GossipMixin:Init_Menu_Quest(frame, root)
    Init_Menu(frame, root)
end