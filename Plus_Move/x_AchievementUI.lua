--成就
local function Init()
    AchievementFrameCategories:ClearAllPoints()
    AchievementFrameCategories:SetPoint('TOPLEFT', 21, -19)
    AchievementFrameCategories:SetPoint('BOTTOMLEFT', 175, 19)
    AchievementFrameMetalBorderRight:ClearAllPoints()
    AchievementFrame.SearchResults:SetPoint('TOP', 0, -15)

    WoWTools_MoveMixin:Setup(AchievementFrame, {
        minW=768,
        maxW=768,
        minH=500,
        setSize=true,
        sizeRestFunc= function(self)
            self.targetFrame:SetSize(768, 500)
        end,
    })

    WoWTools_MoveMixin:Setup(AchievementFrameComparisonHeader, {frame=AchievementFrame})
    WoWTools_MoveMixin:Setup(AchievementFrameComparison, {frame=AchievementFrame})
    WoWTools_MoveMixin:Setup(AchievementFrame.Header, {frame=AchievementFrame})
end


WoWTools_MoveMixin.ADDON_LOADED['Blizzard_AchievementUI']= Init