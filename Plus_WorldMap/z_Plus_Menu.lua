

local function Is_Check(info, tab)
    local complete= tab.complete

    local frequency= tab.frequency
    local class= tab.questClassification

    if tab.all
        or (complete and C_QuestLog.IsComplete(info.questID))
        or (frequency and tab.frequency==info.frequency)
        or (class and class== info.questClassification)
    then
        return true
    end
end


local function Abandon_Quest(tab)
    local n=0

    print(
        WoWTools_DataMixin.Icon.icon2
        ..'|A:bags-button-autosort-up:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '放弃任务' or ABANDON_QUEST)
    )

    for index=1 , C_QuestLog.GetNumQuestLogEntries() do
        local questInfo=C_QuestLog.GetInfo(index)
        if questInfo and questInfo.questID and C_QuestLog.CanAbandonQuest(questInfo.questID) and Is_Check(questInfo, tab) then

            local linkQuest= GetQuestLink(questInfo.questID)

            do
                C_QuestLog.SetSelectedQuest(questInfo.questID)
            end

            do
                C_QuestLog.SetAbandonQuest()
            end
            do
                C_QuestLog.AbandonQuest()
            end

            n=n+1
            print(n..') ', linkQuest or questInfo.questID)
        end

        if IsModifierKeyDown() then
            return
        end
    end
    PlaySound(SOUNDKIT.IG_QUEST_LOG_ABANDON_QUEST)
end






local function Color(text)
    local hex
    if text then
        local col= WoWTools_QuestMixin:GetColor(text)
        if col then
            hex= col.hex
        end
    end
    return hex or ''
end

local frequencyText={
[0]= WoWTools_DataMixin.onlyChinese and '默认' or DEFAULT,
[1]= WoWTools_DataMixin.onlyChinese and '日常' or DAILY,
[2]= WoWTools_DataMixin.onlyChinese and '每周' or WEEKLY,
[3]= WoWTools_DataMixin.onlyChinese and '游戏活动' or EVENT_SCHEDULER_FRAME_LABEL,
}


local classText={
[0]= WoWTools_DataMixin.onlyChinese and '重要' or QUEST_CLASSIFICATION_IMPORTANT,
[1]= WoWTools_DataMixin.onlyChinese and '传说' or QUEST_CLASSIFICATION_LEGENDARY,
[2]= WoWTools_DataMixin.onlyChinese and '战役' or QUEST_CLASSIFICATION_CAMPAIGN,
[3]= WoWTools_DataMixin.onlyChinese and '使命' or QUEST_CLASSIFICATION_CALLING,
[4]= WoWTools_DataMixin.onlyChinese and '综合' or QUEST_CLASSIFICATION_META,
[5]= WoWTools_DataMixin.onlyChinese and '可重复' or QUEST_CLASSIFICATION_RECURRING,
[6]= WoWTools_DataMixin.onlyChinese and '故事线' or QUEST_CLASSIFICATION_QUESTLINE,
[7]= WoWTools_DataMixin.onlyChinese and '普通' or PLAYER_DIFFICULTY1,
[8]= WoWTools_DataMixin.onlyChinese and '奖励目标' or MAP_LEGEND_BONUSOBJECTIVE,
[9]= WoWTools_DataMixin.onlyChinese and '威胁' or PING_TYPE_THREAT,
[10]=WoWTools_DataMixin.onlyChinese and '世界任务' or WORLD_QUEST_BANNER,
}


local function set_tooltip(root)
    root:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_WorldMapMixin.addName..WoWTools_DataMixin.Icon.icon2)
    end)
end


--设置菜单
local function Init_Menu(self, root)
    if not self:IsVisible() then
        return
    end

    

    local num, complete= 0, 0
    local frequency={}--frequency
    local class={}

    local sub, sub2, name

    for index=1 , C_QuestLog.GetNumQuestLogEntries() do
        local info=C_QuestLog.GetInfo(index)
        if info and info.questID and C_QuestLog.CanAbandonQuest(info.questID) then
            num= num+1--可放弃数量
--frequency 数量
            if info.frequency then
                frequency[info.frequency]= (frequency[info.frequency] or 0)+1
            end
--classification 数量
            if info.questClassification	then
                class[info.questClassification]= (class[info.questClassification] or 0)+1
            end
--完成数量
            if C_QuestLog.IsComplete(info.questID) then
                complete= complete+1
            end
--加载数据
            WoWTools_Mixin:Load({id=info and info.questID, type='quest'})
        end
    end


--全部放弃
root:CreateDivider()
name= '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '全部放弃' or LOOT_HISTORY_ALL_PASSED)
    ..' #|cnGREEN_FONT_COLOR:'
    ..num
    ..'|r/'
    ..(select(2, C_QuestLog.GetNumQuestLogEntries()) or 0)

sub=root:CreateButton(
    name,
function(data)
    StaticPopup_Show("WoWTools_WORLDMAP_ABANDONQUEST",
        data.name,
        nil,
        {all=true}
    )
end, {name=name})
set_tooltip(sub)



--QuestFrequency 频率
for enum, index in pairs(Enum.QuestFrequency) do
    name= Color(enum)
        ..(frequencyText[index] or enum)
        ..' #'
        ..(frequency[index] and '|cnGREEN_FONT_COLOR:' or '|cff626262')
        ..(frequency[index] or 0)

    sub2= sub:CreateButton(
        name,
    function(data)
        StaticPopup_Show("WoWTools_WORLDMAP_ABANDONQUEST",
            data.name..'\n\n'..'Enum.QuestFrequency.'..data.enum,
            nil,
            {frequency=data.index}
        )
    end, {name=name, index=index, enum=enum})

    sub2:SetTooltip(function(tooltip, desc)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '放弃任务' or ABANDON_QUEST)
        tooltip:AddLine(desc.data.name)
        tooltip:AddLine('Enum.QuestFrequency.'..desc.data.enum..' = '..desc.data.index)
    end)
end



--QuestClassification 类型
sub:CreateDivider()
for enum, index in pairs(Enum.QuestClassification) do
    name= Color(enum)
        ..(classText[index] or enum)
        ..' #'
        ..(class[index] and '|cnGREEN_FONT_COLOR:' or '|cff626262')
        ..(class[index] or 0)

    sub2= sub:CreateButton(
        name,
    function(data)
        StaticPopup_Show("WoWTools_WORLDMAP_ABANDONQUEST",
            data.name..'\n\n'..'Enum.QuestClassification.'..data.enum,
            nil,
            {questClassification=data.index}
        )
    end, {name=name, index=index, enum=enum})

    sub2:SetTooltip(function(tooltip, desc)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '放弃任务' or ABANDON_QUEST)
        tooltip:AddLine(desc.data.name)
        tooltip:AddLine('Enum.QuestClassification.'..desc.data.enum..' = '..desc.data.index)
    end)
end


--任务完成
sub:CreateDivider()
name= Color('Complete')
    ..(WoWTools_DataMixin.onlyChinese and '任务完成' or QUEST_COMPLETE)
    ..' #'
    ..(complete>0 and '|cnGREEN_FONT_COLOR' or '|cff626262')
    ..complete

sub:CreateButton(
    name,
function(data)
    StaticPopup_Show("WoWTools_WORLDMAP_ABANDONQUEST",
        data.name..'\n\n'..'Enum.QuestClassification.'..data.enum,
        nil,
        {complete=true}
    )
end, {name=name})

--滚动条
WoWTools_MenuMixin:SetScrollMode(sub)

--CVar
    root:CreateDivider()
    sub= root:CreateButton('CVar', function()
        return MenuResponse.Open
    end)
    set_tooltip(sub)

    if WoWTools_MenuMixin:CheckInCombat(sub) then
        return
    end
    local tab={
        --'displayQuestID',
        --'displayInternalOnlyStatus',
        --'showReadyToRecord',
        'questPOI',
        'autoQuestWatch',
        'scrollToLogQuest'
    }
    table.sort(tab)
    for _, var in pairs(tab) do
        sub2=sub:CreateCheckbox(
            (var=='scrollToLogQuest' and '|cnRED_FONT_COLOR:' or '')
            ..var,
        function(data)
            return C_CVar.GetCVarBool(data.var) and true or false
        end, function(data)
            if data then
                C_CVar.SetCVar(data.var, C_CVar.GetCVarBool(data.var) and '0' or '1')
            end
        end, {var=var})
        sub2:SetTooltip(function(tooltip, description)
            if description.data.var=='scrollToLogQuest' then
                tooltip:AddLine('|cnRED_FONT_COLOR:BUG')
            end
            tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '默认' or DEFAULT, WoWTools_TextMixin:GetYesNo(C_CVar.GetCVarDefault(description.data.var)))
            tooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_WorldMapMixin.addName)
        end)
    end
end









local function Init()
    StaticPopupDialogs["WoWTools_WORLDMAP_ABANDONQUEST"] =  {
        text= (WoWTools_DataMixin.onlyChinese and "放弃\"%s\"？" or ABANDON_QUEST_CONFIRM)
            ..'|n|n|cnYELLOW_FONT_COLOR:'
            ..(not WoWTools_DataMixin.onlyChinese and VOICEMACRO_1_Sc_0..' ' or "危险！")..(not WoWTools_DataMixin.onlyChinese and VOICEMACRO_1_Sc_0..' ' or "危险！")..(not WoWTools_DataMixin.onlyChinese and VOICEMACRO_1_Sc_0 or "危险！"),
        button1 = '|cnRED_FONT_COLOR:'..(not WoWTools_DataMixin.onlyChinese and ABANDON_QUEST_ABBREV or "放弃"),
        button2 = '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '取消' or CANCEL),
        OnAccept = function(_, data)
           Abandon_Quest(data)
        end,
        whileDead=true,
        hideOnEscape=true,
        exclusive=true,

        showAlert= true,
        fullScreenCover =true,
        --timeout=60,
        acceptDelay= 1--not WoWTools_DataMixin.Player.husandro and 2 or nil,
    }


    Menu.ModifyMenu("MENU_QUEST_MAP_FRAME_SETTINGS", function(...)
        Init_Menu(...)
    end)


    Init=function()end
end






function WoWTools_WorldMapMixin:Init_Plus_Menu()
    Init()
end