local AbandoList

local function Is_Check(info, tab)
    local All= tab.type=='All'
    local Complete= tab.type=='Complete'
    local Incomplete= tab.type=='Incomplete'
    local Trivial= tab.type=='Trivial'
    local QuestFrequency= tab.type=='QuestFrequency' and Enum.QuestFrequency[tab.enum]
    local QuestClassification= tab.type=='QuestClassification' and Enum.QuestClassification[tab.enum]

    local isComplete= C_QuestLog.IsComplete(info.questID)

    if All
        or (Complete and isComplete)
        or (Incomplete and not isComplete)
        or (Trivial and C_QuestLog.IsQuestTrivial(info.questID))
        or (QuestFrequency and QuestFrequency== info.frequency)
        or (QuestClassification and QuestClassification== info.questClassification)
    then
        return true
    end
end










local function Color(text)
    local hex
    if text then
        local col= WoWTools_QuestMixin:GetColor(text)
        if col then
            hex= col.hex
        end
    end
    return hex
end










local function Abandon_Quest(tab)
    local n=0
    local info
    print(
        WoWTools_DataMixin.Icon.icon2
        ..'|A:bags-button-autosort-up:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '放弃任务' or ABANDON_QUEST),

        tab.name
    )


    for index=1 , C_QuestLog.GetNumQuestLogEntries() do
        info=C_QuestLog.GetInfo(index)
        if info
            and info.questID
            and C_QuestLog.CanAbandonQuest(info.questID)
            and Is_Check(info, tab)
        then

            local linkQuest= GetQuestLink(info.questID)

            do
                C_QuestLog.SetSelectedQuest(info.questID)
            end

            do
                C_QuestLog.SetAbandonQuest()
            end

            do
                C_QuestLog.AbandonQuest()
            end

            n=n+1
            print('|cnGREEN_FONT_COLOR:'..n..')|r', linkQuest or info.title or info.questID)
        end

        if IsModifierKeyDown() then
            return
        end
    end

end










local function QuestList_Tooltip(tooltip, data)
    tooltip:AddLine(data.name)

    if data.enum then
        tooltip:AddLine(
            'Enum.'..data.type..'.'..data.enum
            --Enum[data.type][data.enum]
        )
    end
    if data.num>0 then
        tooltip:AddLine(' ')
    end

    local text
    local num=0
    for index=1, C_QuestLog.GetNumQuestLogEntries() do
        local info=C_QuestLog.GetInfo(index)
        if info
            and info.questID
            and C_QuestLog.CanAbandonQuest(info.questID)
            and Is_Check(info, data)
        then


--QuestMapFrame.QuestsFrame.ScrollFrame:ScrollToQuest(info.questID)
--QuestMapFrame:OnHighlightedQuestPOIChange(info.questID)

            num=num+1

            if num==1 then
               text= info.title
            end

            local color= select(2, WoWTools_QuestMixin:GetAtlasColor(info.questID, info))

            tooltip:AddDoubleLine(
                (color and color.hex or '')
                ..WoWTools_TextMixin:CN(
                    GetQuestLink(info.questID) or info.title or info.questID, {questID=info.questID, isName=true}
                )
                ..(C_QuestLog.IsComplete(info.questID) and ' |cnGREEN_FONT_COLOR:|A:common-dropdown-icon-checkmark-yellow:0:0|a'..(
                    WoWTools_DataMixin.onlyChinese and '完成' or COMPLETE
                ) or '')
                ,
                '|cffffffff'..num..')'
            )
        end
    end

    if QuestScrollFrame.SearchBox:IsEnabled() then
        if text then
           QuestScrollFrame.SearchBox:SetText(text)
        else
            QuestScrollFrame.SearchBox:Clear()
        end
    end
end












--设置菜单
local function Init_Menu(self, root)
    local sub, sub2, name, info

    root:CreateDivider()
    sub= root:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '放弃任务' or ABANDON_QUEST)
        ..' #'
        ..(select(2, C_QuestLog.GetNumQuestLogEntries()) or 0),
    function()
        return MenuResponse.Open
    end)






 local Num={
    Totale=0,
    All=0,
    Complete=0,
    Incomplete=0,
    Trivial=0,
    QuestFrequency={},
    QuestClassification={}
}

for index=1 , C_QuestLog.GetNumQuestLogEntries() do
    info=C_QuestLog.GetInfo(index)
    if info and info.questID  and C_QuestLog.CanAbandonQuest(info.questID) then

        Num.All= Num.All+1

--frequency 数量
        if info.frequency then
            Num.QuestFrequency[info.frequency]= (Num.QuestFrequency[info.frequency] or 0)+1
        end
--classification 数量
        if info.questClassification	then
            Num.QuestClassification[info.questClassification]= (Num.QuestClassification[info.questClassification] or 0)+1
        end
--完成数量
        if C_QuestLog.IsComplete(info.questID) then
            Num.Complete= Num.Complete+1
        else
            Num.Incomplete= Num.Incomplete+1
        end
--低等任务
        if C_QuestLog.IsQuestTrivial(info.questID) then
            Num.Trivial= Num.Trivial+1
        end
--加载数据
        WoWTools_DataMixin:Load({id=info and info.questID, type='quest'})
    end
end

for _, tab in pairs(AbandoList) do
    if tab.name=='-' then
        sub:CreateDivider()
    else
        local num
        if tab.enum then
            num= Num[tab.type][Enum[tab.type][tab.enum]]
        else
            num= Num[tab.type]
        end

        num= num or 0

        name= (tab.enum and Color(tab.enum) or Color(tab.type) or '|cffffffff')
            ..tab.name
            ..' |r#'
            ..(num==0 and '|cff626262' or '|cffffffff')
            ..num
            ..'|r'

        sub2=sub:CreateButton(
            name,
        function(data)
            StaticPopup_Show("WoWTools_WORLDMAP_ABANDONQUEST",
                data.name..(data.enum and '\n\nEnum.'..data.type..tab.enum or ''),
                nil,
                data
            )
        end,{
            name=name,
            type=tab.type,
            enum=tab.enum,
            num= num,
        })

       sub2:SetTooltip(function(tooltip, desc)
            QuestList_Tooltip(tooltip, desc.data)
       end)
    end
end
--滚动条
WoWTools_MenuMixin:SetScrollMode(sub)














--CVar
    root:CreateDivider()
    sub= root:CreateButton('CVar', function()
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_WorldMapMixin.addName..WoWTools_DataMixin.Icon.icon2)
    end)

    if WoWTools_MenuMixin:CheckInCombat(sub) then
        return
    end
    local tab={
        'questPOI',
        'autoQuestWatch',
        'scrollToLogQuest',

        'showQuestObjectivesInLog',
        'displayQuestID',
        'displayInternalOnlyStatus',
        'showReadyToRecord',

    }
    table.sort(tab)
    local col= InCombatLockdown() and '|cff626262' or ''
    for _, var in pairs(tab) do
        if var=='-' then
            sub:CreateDivider()
        else
            sub2=sub:CreateCheckbox(
                col..var,
            function(data)
                return C_CVar.GetCVarBool(data.var) and true or false
            end, function(data)
                if not InCombatLockdown() then
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
end









local function Init()

AbandoList= {
{name='|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '全部放弃' or LOOT_HISTORY_ALL_PASSED), type='All'},
{name='-'},

{name=WoWTools_DataMixin.onlyChinese and '默认' or DEFAULT, type='QuestFrequency', enum='Default'},--0
{name=WoWTools_DataMixin.onlyChinese and '日常' or DAILY, type='QuestFrequency', enum='Daily'},
{name=WoWTools_DataMixin.onlyChinese and '每周' or WEEKLY, type='QuestFrequency', enum='Weekly'},
{name=WoWTools_DataMixin.onlyChinese and '游戏活动' or EVENT_SCHEDULER_FRAME_LABEL, type='QuestFrequency', enum='ResetByScheduler'},--3
{name='-'},

{name=WoWTools_DataMixin.onlyChinese and '重要' or QUEST_CLASSIFICATION_IMPORTANT, type='QuestClassification', enum='Important'},--0
{name=WoWTools_DataMixin.onlyChinese and '传说' or QUEST_CLASSIFICATION_LEGENDARY, type='QuestClassification', enum='Legendary'},
{name=WoWTools_DataMixin.onlyChinese and '战役' or QUEST_CLASSIFICATION_CAMPAIGN, type='QuestClassification', enum='Campaign'},
{name=WoWTools_DataMixin.onlyChinese and '使命' or QUEST_CLASSIFICATION_CALLING, type='QuestClassification', enum='Calling'},
{name=WoWTools_DataMixin.onlyChinese and '综合' or QUEST_CLASSIFICATION_META, type='QuestClassification', enum='Meta'},
{name=WoWTools_DataMixin.onlyChinese and '可重复' or QUEST_CLASSIFICATION_RECURRING, type='QuestClassification', enum='Recurring'},
{name=WoWTools_DataMixin.onlyChinese and '故事线' or QUEST_CLASSIFICATION_QUESTLINE, type='QuestClassification', enum='Questline'},
{name=WoWTools_DataMixin.onlyChinese and '普通' or PLAYER_DIFFICULTY1, type='QuestClassification', enum='Normal'},
{name=WoWTools_DataMixin.onlyChinese and '奖励目标' or MAP_LEGEND_BONUSOBJECTIVE, type='QuestClassification', enum='BonusObjective'},
{name=WoWTools_DataMixin.onlyChinese and '威胁' or PING_TYPE_THREAT, type='QuestClassification', enum='Threat'},
{name=WoWTools_DataMixin.onlyChinese and '世界任务' or WORLD_QUEST_BANNER, type='QuestClassification', enum='WorldQuest'},--10
{name='-'},

{name=WoWTools_DataMixin.onlyChinese and '完成' or COMPLETE, type='Complete'},
{name=WoWTools_DataMixin.onlyChinese and '未完成' or INCOMPLETE, type='Incomplete'},
{name=WoWTools_DataMixin.onlyChinese and '低等级' or TRIVIAL_QUEST_LABEL, type='Trivial'}
}








    StaticPopupDialogs["WoWTools_WORLDMAP_ABANDONQUEST"] =  {
        text= '\n'..(WoWTools_DataMixin.onlyChinese and "放弃\"%s\"？" or ABANDON_QUEST_CONFIRM)
            ..'|n|n|cnYELLOW_FONT_COLOR:'
            ..(WoWTools_DataMixin.onlyChinese and '危险！' or VOICEMACRO_1_Sc_0)
            ..(WoWTools_DataMixin.onlyChinese and '危险！' or VOICEMACRO_1_Sc_0)
            ..(WoWTools_DataMixin.onlyChinese and '危险！' or VOICEMACRO_1_Sc_0)
            ..'\n',
        button1 = '|cnRED_FONT_COLOR:'..(not WoWTools_DataMixin.onlyChinese and ABANDON_QUEST_ABBREV or "放弃"),
        button2 = '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '取消' or CANCEL),
        OnShow=function()
            PlaySound(SOUNDKIT.IG_QUEST_LOG_ABANDON_QUEST)
        end,
        OnAccept = function(_, data)
            Abandon_Quest(data)
        end,
        whileDead=true,
        hideOnEscape=true,
        exclusive=true,

        showAlert= true,
        --fullScreenCover =true,
        timeout=60,
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