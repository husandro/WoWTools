--成就 AchievementObjectiveTracker


local function Clear_Achievement()
    local tab={}
    local num=0
    for index, achievementID in pairs(C_ContentTracking.GetTrackedIDs(Enum.ContentTrackingType.Achievement)) do
--移除
        C_ContentTracking.StopTracking(Enum.ContentTrackingType.Achievement, achievementID,  Enum.ContentTrackingStopType.Manual)
        num= index
        table.insert(tab, achievementID)
    end
--更新，成就面板
    if num>0 and AchievementFrame and AchievementFrame:IsVisible() and AchievementFrameAchievements_ForceUpdate then
        WoWTools_DataMixin:Call(AchievementFrameAchievements_ForceUpdate)--Blizzard_ObjectiveTracker
    end
    return tab, num
end






local function Init()
    WoWTools_ObjectiveMixin:Add_ClearAll_Button(
        AchievementObjectiveTracker,
        WoWTools_DataMixin.onlyChinese and '成就' or TRACKER_HEADER_ACHIEVEMENTS,
    function(self)
        local tab, num= Clear_Achievement()
        for index, achievementID in pairs(tab) do
            print(
                index..')',
                GetAchievementLink(achievementID)
                or ('|cffffff00|Hachievement:'..achievementID..':'..WoWTools_DataMixin.Player.GUID..':0:0:0:-1:0:0:0:0|h['..achievementID..']|h|r')
            )
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
function WoWTools_ObjectiveMixin:Clear_Achievement()
    return Clear_Achievement()
end