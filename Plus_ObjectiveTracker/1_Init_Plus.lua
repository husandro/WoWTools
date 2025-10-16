--[[
local Frames={
    'QuestObjectiveTracker',
    'CampaignQuestObjectiveTracker',
    'WorldQuestObjectiveTracker',
    'AchievementObjectiveTracker',
    'ProfessionsRecipeTracker',
    'MonthlyActivitiesObjectiveTracker',
    'BonusObjectiveTracker', --.Header
}]]




local P_Save={
    disabled= not WoWTools_DataMixin.Player.husandro,
    scale= WoWTools_DataMixin.Player.husandro and 0.85 or 1,
    alpha=1,
    autoHide= WoWTools_DataMixin.Player.husandro and true or nil
}


local function Save()
    return WoWToolsSave['ObjectiveTracker']
end










local function Init()
--场景
    ScenarioObjectiveTracker.Header.numStagesLabel= WoWTools_LabelMixin:Create(ScenarioObjectiveTracker.Header, {copyFont=ScenarioObjectiveTracker.StageBlock.Name, justifyH='RIGHT'})
    ScenarioObjectiveTracker.Header.numStagesLabel:SetPoint('LEFT', ScenarioObjectiveTracker.Header.Text, 'RIGHT')

    WoWTools_DataMixin:Hook(ScenarioObjectiveTracker, 'LayoutContents', function(self)
        local text
        local currentStage, numStages = select(2, C_Scenario.GetInfo())
        if numStages and numStages>1 and currentStage then
            text= (numStages==currentStage and '|cnGREEN_FONT_COLOR:' or '')..currentStage..'/'..numStages
        end
        self.Header.numStagesLabel:SetText(text or '')
    end)
    --local scenarioName, currentStage, numStages, flags, hasBonusStep, isBonusStepComplete, _, xp, money, scenarioType, areaName, _, scenarioID = C_Scenario.GetInfo();
    ScenarioObjectiveTracker.StageBlock:HookScript('OnEnter', function(self)
        local scenarioID = select(13, C_Scenario.GetInfo())
        if not scenarioID then
            return
        end
        if not GameTooltip:IsShown() then
            GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
            GameTooltip:ClearLines()
        else
            GameTooltip:AddLine(' ')
        end

        GameTooltip:AddDoubleLine(WoWTools_DataMixin.Icon.icon2..'scenarioID', '|cnGREEN_FONT_COLOR:'..scenarioID)
        GameTooltip:Show()
    end)










--QuestObjectiveItemButtonTemplate
--物品按钮左边,放大
    WoWTools_DataMixin:Hook(QuestObjectiveItemButtonMixin, 'SetUp', function(self)
        if not WoWTools_FrameMixin:IsLocked(self) and not self.isSetTexture then
            self:SetSize(42,42)
            self.NormalTexture:SetPoint('TOPLEFT', -10, 10)
            self.NormalTexture:SetPoint('BOTTOMRIGHT', 10, -10)
            self:GetPushedTexture():SetPoint('TOPLEFT', -14, 14)
            self:GetPushedTexture():SetPoint('BOTTOMRIGHT', 14, -14)
            self.isSetTexture= true
        end
    end)





















--成就 AchievementObjectiveTracker
    WoWTools_ObjectiveMixin:Add_ClearAll_Button(
        AchievementObjectiveTracker,
        WoWTools_DataMixin.onlyChinese and '成就' or TRACKER_HEADER_ACHIEVEMENTS,
    function()
        WoWTools_ObjectiveMixin:Clear_Achievement(true)
    end)
    WoWTools_DataMixin:Hook(AchievementObjectiveTracker, 'AddAchievement', function(self, achievementID)
        local block = WoWTools_ObjectiveMixin:Get_Block(self, achievementID)
        if not block then
            return
        end

        local icon= select(10, GetAchievementInfo(achievementID))
        WoWTools_ObjectiveMixin:Set_Block_Icon(block, icon, 'isAchievement')


        for index, line in pairs(block.usedLines or {}) do
            local subIcon
            if type(index)=='number' then
                --local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(achievementID, index);
                local assetID= select(8, GetAchievementCriteriaInfoByID(achievementID, index))
                subIcon = assetID and select(10, GetAchievementInfo(assetID))
            end
            WoWTools_ObjectiveMixin:Set_Line_Icon(line, subIcon)
        end
    end)













--专业技能 ProfessionsRecipeTracker
    WoWTools_ObjectiveMixin:Add_ClearAll_Button(
        ProfessionsRecipeTracker,
        WoWTools_DataMixin.onlyChinese and '专业技能' or PROFESSIONS_TRACKER_HEADER_PROFESSION,
    function()
        WoWTools_ObjectiveMixin:Clear_ProfessionsRecipe(true)
    end)
    WoWTools_DataMixin:Hook(ProfessionsRecipeTracker, 'AddRecipe', function(self, recipeID, isRecraft)
        local blockID = NegateIf(recipeID, isRecraft);
	    local block = WoWTools_ObjectiveMixin:Get_Block(self, blockID)

        if not block then
            return
        end

        local data=  C_TradeSkillUI.GetRecipeInfo(recipeID)
        if data then
            WoWTools_ObjectiveMixin:Set_Block_Icon(block, data.icon, 'isRecipe')
        end

        local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, isRecraft)
        if not recipeSchematic or not recipeSchematic.reagentSlotSchematics then
            return
        end

        for index, line in pairs(block.usedLines or {}) do
            local subIcon
            if type(index)=='number' then
                local reagentSlotSchematic= recipeSchematic.reagentSlotSchematics[index]
                if reagentSlotSchematic then
                    local reagent = reagentSlotSchematic.reagents[1] or {}
                    if reagent.itemID then
                        local item = Item:CreateFromItemID(reagent.itemID);
                        subIcon = item:GetItemIcon()
                    elseif reagent.currencyID then
                        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(reagent.currencyID);
                        if currencyInfo then
                            subIcon = currencyInfo.iconFileID;
                        end
                    end
                end
            end

            WoWTools_ObjectiveMixin:Set_Line_Icon(line, subIcon)
        end
    end)










--任务 QuestObjectiveTracker QuestObjectiveTrackerMixin
    WoWTools_ObjectiveMixin:Add_ClearAll_Button(
    QuestObjectiveTracker,
        WoWTools_DataMixin.onlyChinese and '任务' or TRACKER_HEADER_QUESTS,
    function()
        WoWTools_ObjectiveMixin:Clear_Quest(true)
    end)

    WoWTools_DataMixin:Hook(QuestObjectiveTracker, 'AddBlock', function(_, block)
        local questID= block.id and tonumber(block.id)
        if questID then
            local color = select(2, WoWTools_QuestMixin:GetAtlasColor(questID))
            if color and block.HeaderText then
                block.HeaderText:SetTextColor(color.r, color.g, color.b)
            end
        end
    end)









--战役，任务 CampaignQuestObjectiveTracker
    WoWTools_ObjectiveMixin:Add_ClearAll_Button(
        CampaignQuestObjectiveTracker,
        WoWTools_DataMixin.onlyChinese and '战役' or TRACKER_HEADER_CAMPAIGN_QUESTS,
    function()
        WoWTools_ObjectiveMixin:Clear_CampaignQuest(true)
    end)







--世界，任务 WorldQuestObjectiveTracker
    WoWTools_ObjectiveMixin:Add_ClearAll_Button(
        WorldQuestObjectiveTracker,
        WoWTools_DataMixin.onlyChinese and '世界任务' or TRACKER_HEADER_WORLD_QUESTS,
    function()
       WoWTools_ObjectiveMixin:Clear_WorldQuest(true)
    end)






--旅行者日志 MonthlyActivitiesObjectiveTracker
    WoWTools_ObjectiveMixin:Add_ClearAll_Button(
        MonthlyActivitiesObjectiveTracker,
        WoWTools_DataMixin.onlyChinese and '旅行者日志' or TRACKER_HEADER_MONTHLY_ACTIVITIES,
    function()
        WoWTools_ObjectiveMixin:Clear_MonthlyActivities(true)
    end)








    WoWTools_ObjectiveMixin:Init_Menu()
    Init=function()end
end

















local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if arg1~= 'WoWTools' then
        return
    end

    WoWToolsSave['ObjectiveTracker']= WoWToolsSave['ObjectiveTracker'] or CopyTable(P_Save)
    P_Save= nil

    WoWTools_ObjectiveMixin.addName= '|A:Objective-Nub:0:0|a|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '目标追踪栏' or HUD_EDIT_MODE_OBJECTIVE_TRACKER_LABEL)..'|r'

    --添加控制面板
    WoWTools_PanelMixin:OnlyCheck({
        name=WoWTools_ObjectiveMixin.addName,
        tooltip='|cnWARNING_FONT_COLOR:Bug',
        GetValue= function() return not Save().disabled end,
        SetValue= function()
            Save().disabled= not Save().disabled and true or nil

            Init()

            if Save().disabled then
                print(
                    WoWTools_DataMixin.Icon.icon2..WoWTools_ObjectiveMixin.addName,
                    WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                    WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                )
            end
        end
    })

    if not Save().disabled then
        Init()
    end

    self:UnregisterEvent(event)
end)