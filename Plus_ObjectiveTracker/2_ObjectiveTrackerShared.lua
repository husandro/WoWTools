    --物品按钮左边,放大



local function Init()
    hooksecurefunc(QuestObjectiveItemButtonMixin, 'SetUp', function(self)
        self:SetSize(42,42)
        self.NormalTexture:SetTexture(nil)
    end)
end



function WoWTools_ObjectiveTrackerMixin:Init_ObjectiveTrackerShared()
    Init()
end