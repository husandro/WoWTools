--设置菜单


local function Init_Menu(_, root)
    local sub, sub2
--全部放弃
    root:CreateDivider()

    sub=root:CreateButton('|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '全部放弃' or LOOT_HISTORY_ALL_PASSED)..' #'..(select(2, C_QuestLog.GetNumQuestLogEntries()) or 0), function()
        StaticPopup_Show("WoWTools_WorldMpa_ABANDON_QUEST",
            '|n|cnRED_FONT_COLOR:|n|A:bags-button-autosort-up:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '所有任务' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ALL, QUESTS_LABEL))
            ..' |r#|cnGREEN_FONT_COLOR:'
            ..select(2, C_QuestLog.GetNumQuestLogEntries())..'|r'
        )
    end)

    sub:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_WorldMapMixin.addName)
    end)
    root:CreateDivider()

--CVar
    sub= root:CreateButton('CVar', function() return MenuResponse.Open end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_WorldMapMixin.addName)
    end)

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
    StaticPopupDialogs["WoWTools_WorldMpa_ABANDON_QUEST"] =  {
        text= (WoWTools_DataMixin.onlyChinese and "放弃\"%s\"？" or ABANDON_QUEST_CONFIRM)..'|n|n|cnYELLOW_FONT_COLOR:'..(not WoWTools_DataMixin.onlyChinese and VOICEMACRO_1_Sc_0..' ' or "危险！")..(not WoWTools_DataMixin.onlyChinese and VOICEMACRO_1_Sc_0..' ' or "危险！")..(not WoWTools_DataMixin.onlyChinese and VOICEMACRO_1_Sc_0 or "危险！"),
        button1 = '|cnRED_FONT_COLOR:'..(not WoWTools_DataMixin.onlyChinese and ABANDON_QUEST_ABBREV or "放弃"),
        button2 = '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '取消' or CANCEL),
        OnAccept = function()
            local n=0
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_WorldMapMixin.addName,  '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '放弃' or ABANDON_QUEST_ABBREV))
            for index=1 , C_QuestLog.GetNumQuestLogEntries() do
                do
                    local questInfo=C_QuestLog.GetInfo(index)
                    if questInfo and questInfo.questID and C_QuestLog.CanAbandonQuest(questInfo.questID) then
                        local linkQuest=GetQuestLink(questInfo.questID)
                        C_QuestLog.SetSelectedQuest(questInfo.questID)
                        C_QuestLog.SetAbandonQuest();
                        C_QuestLog.AbandonQuest()
                        n=n+1
                        print(n..') ', linkQuest or questInfo.questID)
                    end
                    if IsModifierKeyDown() then
                        return
                    end
                end
            end
            PlaySound(SOUNDKIT.IG_QUEST_LOG_ABANDON_QUEST);
        end,
        whileDead=true, hideOnEscape=true, exclusive=true,
        showAlert= true,
        fullScreenCover =true,
        timeout=60,
        acceptDelay=3,
    }


    Menu.ModifyMenu("MENU_QUEST_MAP_FRAME_SETTINGS", function(...)
        Init_Menu(...)
    end)


    Init=function()end
end






function WoWTools_WorldMapMixin:Init_Plus_Menu()
    Init()
end