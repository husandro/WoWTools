--任务







local function Init()
    local frame= CreateFrame('Frame')

    frame.Text= WoWTools_LabelMixin:Create(QuestLogMicroButton,  {size=WoWTools_MainMenuMixin.Save.size, color=true})
    frame.Text:SetPoint('TOP', QuestLogMicroButton, 0,  -3)
    table.insert(WoWTools_MainMenuMixin.Labels, frame.Text)

    function frame:settings()
        local num
        num= select(2, C_QuestLog.GetNumQuestLogEntries()) or 0
        if num>=38 then
            num= '|cnRED_FONT_COLOR:'..num..'|r'
        elseif num >= MAX_QUESTS then
            num= '|cnYELLOW_FONT_COLOR:'..num..'|r'
        else
            num = num==0 and '' or num
        end
        self.Text:SetText(num)
    end
    frame:RegisterEvent('ACHIEVEMENT_EARNED')
    frame:SetScript('OnEvent', frame.settings)
    C_Timer.After(2, function() frame:settings() end)

    QuestLogMicroButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        GameTooltip:AddLine(' ')
        WoWTools_QuestMixin:GetQuestAll()--所有，任务，提示
        GameTooltip:Show()
    end)
end






function WoWTools_MainMenuMixin:Init_Quest()--任务
    Init()
end