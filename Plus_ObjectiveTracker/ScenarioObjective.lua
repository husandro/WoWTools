





local function Init()
    ScenarioObjectiveTracker.Header.numStagesLabel= WoWTools_LabelMixin:Create(ScenarioObjectiveTracker.Header, {copyFont=ScenarioObjectiveTracker.StageBlock.Name, justifyH='RIGHT'})
    ScenarioObjectiveTracker.Header.numStagesLabel:SetPoint('LEFT', ScenarioObjectiveTracker.Header.Text, 'RIGHT')

    hooksecurefunc(ScenarioObjectiveTracker, 'LayoutContents', function(self)
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
        end

        GameTooltip:AddDoubleLine(WoWTools_DataMixin.Icon.icon2..'scenarioID', scenarioID)
        GameTooltip:Show()
    end)

    Init=function()end
end









function WoWTools_ObjectiveMixin:Init_ScenarioObjective()
    Init()
end