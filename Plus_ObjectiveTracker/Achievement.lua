







--成就 AchievementObjectiveTracker
local function Init()
    WoWTools_ObjectiveMixin:Add_ClearAll_Button(AchievementObjectiveTracker, WoWTools_DataMixin.onlyChinese and '成就' or TRACKER_HEADER_ACHIEVEMENTS, function(self)
        local num=0
        for index, achievementID in pairs(C_ContentTracking.GetTrackedIDs(Enum.ContentTrackingType.Achievement)) do
            C_ContentTracking.StopTracking(Enum.ContentTrackingType.Achievement, achievementID,  Enum.ContentTrackingStopType.Manual)
            print(index..')', GetAchievementLink(achievementID) or achievementID)
            num= num +1
        end
        if num>0 and AchievementFrame and AchievementFrame:IsVisible() and AchievementFrameAchievements_ForceUpdate then
            WoWTools_Mixin:Call(AchievementFrameAchievements_ForceUpdate)--Blizzard_ObjectiveTracker
        end
        self:print_text(num)
    end)



    hooksecurefunc(AchievementObjectiveTracker, 'AddAchievement', function(self, achievementID)
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


end





function WoWTools_ObjectiveMixin:Init_Achievement()
    Init()
end