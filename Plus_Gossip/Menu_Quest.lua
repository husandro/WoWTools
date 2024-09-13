local e= select(2, ...)
local addName2
local function Save()
    return WoWTools_GossipMixin.Save
end





local function Init_Menu(self, root)
    local sub, sub2, num

--启用
    sub=root:CreateCheckbox(
        '|A:UI-HUD-UnitFrame-Target-PortraitOn-Boss-Quest:0:0|a'..(e.onlyChinese and '启用' or ENABLE),
    function()
        return Save().quest
    end, function()
        Save().quest= not Save().quest and true or nil
        self:set_Texture()--设置，图片
        self:tooltip_Show()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('Alt+%s'..(e.onlyChinese and '暂时禁用' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, BOOSTED_CHAR_SPELL_TEMPLOCK, DISABLE)))
    end)

--其他任务
    sub=root:CreateCheckbox(
        '|A:TrivialQuests:0:0|a'..(e.onlyChinese and '其他任务' or MINIMAP_TRACKING_TRIVIAL_QUESTS),--低等任务
    function()
        return self:get_set_IsQuestTrivialTracking()
    end, function()
        self:get_set_IsQuestTrivialTracking(true)
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '追踪' or TRACKING)
        tooltip:AddLine(e.onlyChinese and '低等任务' or (format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LOW, LEVEL), QUESTS_LABEL)))
    end)

--自动:选择奖励
    sub=root:CreateCheckbox(
        e.onlyChinese and '自动选择奖励' or format(TITLE_REWARD, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, CHOOSE)),
    function()
        return Save().autoSelectReward
    end, function()
        Save().autoSelectReward= not Save().autoSelectReward and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '最高品质' or format(PROFESSIONS_CRAFTING_QUALITY, VIDEO_OPTIONS_ULTRA_HIGH))
        tooltip:AddLine('|cff0000ff'..(e.onlyChinese and '稀有' or GARRISON_MISSION_RARE)..'|r')
    end)

--子目录，自动:选择奖励
    num=0
    for questID, index in pairs(Save().questRewardCheck) do
        e.LoadData({id=questID, type='quest'})
        sub2=sub:CreateCheckbox(
            WoWTools_QuestMixin:GetName(questID)..' |cnGREEN_FONT_COLOR:'..index,
        function(data)
            return Save().questRewardCheck[data.questID]
        end, function(data)
            Save().questRewardCheck[data.questID]= not Save().questRewardCheck[data.questID] and data.index or nil
        end, {questID=questID, index=index})
        WoWTools_TooltipMixin:SetTooltip(nil, nil, sub2, nil)
        num=num+1
    end
    if num>1 then
        sub:CreateDivider()
        sub:CreateButton(
            e.onlyChinese and '清除全部' or CLEAR_ALL,
        function()
            Save().questRewardCheck={}
        end)
        WoWTools_MenuMixin:SetGridMode(sub, num)
    end

--共享任务
    sub=root:CreateCheckbox(
        '|A:plunderstorm-glues-queueselector-trio-selected:0:0|a'
        ..(IsInGroup() and '' or '|cff9e9e9e')
        ..(e.onlyChinese and '共享任务' or SHARE_QUEST),
    function()
        return Save().pushable
    end, function()
        Save().pushable= not Save().pushable and true or nil
        self:set_Event()--设置事件
        self:set_PushableQuest()--共享,任务
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(
            e.onlyChinese and '仅限在队伍中'
            or format(LFG_LIST_CROSS_FACTION, AGGRO_WARNING_IN_PARTY)
        )
    end)

--数量
    sub=root:CreateCheckbox(
        (e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL),
    function()
        return Save().showAllQuestNum
    end, function()
        Save().showAllQuestNum= not Save().showAllQuestNum and true or nil
        self:set_Quest_Num_Text()
        self:set_Event()--设置事件
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(
            e.onlyChinese and '显示所有数量'
            or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, ALL)
        )
        tooltip:AddLine(
            e.onlyChinese and '在副本中禁用|n任务>0'
            or (format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, AGGRO_WARNING_IN_INSTANCE, DISABLE)..'|n'..QUESTS_LABEL..' >0')
        )
    end)


--追踪
    root:CreateDivider()
    root:CreateTitle(e.onlyChinese and '追踪' or TRACKING)

    sub=root:CreateCheckbox(
        (e.onlyChinese and '自动任务追踪' or AUTO_QUEST_WATCH_TEXT),
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
    root:SetEnabled(not UnitAffectingCombat('player'))
end










--###########
--任务，主菜单
--[[###########
local function Init(_, level, type)
    local info
    --local uiMapID = (WorldMapFrame:IsShown() and (WorldMapFrame.mapID or WorldMapFrame:GetMapID("current"))) or C_Map.GetBestMapForUnit('player')


    elseif type=='CUSTOM' then
        for questID, text in pairs(Save().questOption) do
            info={
                text= text,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle='questID  '..questID,
                tooltipText='|n'..e.Icon.left..(e.onlyChinese and '移除' or REMOVE),
                func=function()
                    Save().questOption[questID]=nil
                    print(e.addName, addName2, e.onlyChinese and '移除' or REMOVE, text, 'ID', questID)
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '清除全部' or CLEAR_ALL,
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle= 'Shift+'..e.Icon.left,
            func= function()
                if IsShiftKeyDown() then
                    Save().questOption={}
                    print(e.addName, addName2, e.onlyChinese and '自定义' or CUSTOM, e.onlyChinese and '清除全部' or CLEAR_ALL)
                end
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    end


    if type then
        return
    end
















    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= e.onlyChinese and '追踪' or TRACKING,
        isTitle= true,
        notCheckable=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '自动任务追踪' or AUTO_QUEST_WATCH_TEXT,
        checked=C_CVar.GetCVarBool("autoQuestWatch"),
        tooltipOnButton=true,
        tooltipTitle= 'CVar autoQuestWatch',
        keepShownOnClick=true,
        func=function()
            C_CVar.SetCVar("autoQuestWatch", C_CVar.GetCVarBool("autoQuestWatch") and '0' or '1')
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '当前地图' or (REFORGE_CURRENT..WORLD_MAP),
        checked= Save().autoSortQuest,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '仅显示当前地图任务' or format(GROUP_FINDER_CROSS_FACTION_LISTING_WITH_PLAYSTLE, SHOW, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, FLOOR, QUESTS_LABEL)),--仅限-本区域任务
        tooltipText= e.onlyChinese and '触发事件: 更新区域' or (EVENTS_LABEL..':' ..UPDATE..FLOOR),
        keepShownOnClick=true,
        func=function()
            Save().autoSortQuest= not Save().autoSortQuest and true or nil
            self:set_Event()--仅显示本地图任务,事件
            self:set_Only_Show_Zone_Quest()--显示本区域任务
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={--自定义,任务,选项
        text= e.onlyChinese and '自定义任务' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CUSTOM, QUESTS_LABEL),
        menuList='CUSTOM',
        notCheckable=true,
        hasArrow=true,
        keepShownOnClick=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end
]]


function  WoWTools_GossipMixin:Init_Menu_Quest(frame, root)
    Init_Menu(frame, root)
end