local e= select(2, ...)





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






end









function WoWTools_ObjectiveTrackerMixin:Init_ScenarioObjective()
    Init()
end