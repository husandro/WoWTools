    --物品按钮左边,放大



local function Init()
    --QuestObjectiveItemButtonTemplate
    hooksecurefunc(QuestObjectiveItemButtonMixin, 'SetUp', function(self)
        if not WoWTools_FrameMixin:IsLocked(self) and not self.isSetTexture then
            self:SetSize(42,42)
            self.NormalTexture:SetPoint('TOPLEFT', -10, 10)
            self.NormalTexture:SetPoint('BOTTOMRIGHT', 10, -10)
            self:GetPushedTexture():SetPoint('TOPLEFT', -14, 14)
            self:GetPushedTexture():SetPoint('BOTTOMRIGHT', 14, -14)
            self.isSetTexture= true
            --WoWTools_ButtonMixin:AddMask(self)
        end
    end)
end



function WoWTools_ObjectiveMixin:Init_ObjectiveTrackerShared()
    Init()
end