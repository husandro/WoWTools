WoWTools_HouseMixin={}
--CreateAtlasMarkup("waypoint-mappin-minimap-untracked", 16, 16, 0, 0)

--来源
function WoWTools_HouseMixin:GetObjectiveText(entryInfo)
    if entryInfo
        and entryInfo.entryID
        and C_ContentTracking.IsTrackable(Enum.ContentTrackingType.Decor, entryInfo.entryID.recordID)
    then
        local targetType, targetID = C_ContentTracking.GetCurrentTrackingTarget(Enum.ContentTrackingType.Decor, entryInfo.entryID.recordID)
        if targetType then
            local obj= C_ContentTracking.GetObjectiveText(targetType, targetID)
            if obj and obj~='' then
                return CreateAtlasMarkup("|A:waypoint-mappin-minimap-untracked:0:0|a"..WoWTools_TextMixin:CN(obj))
            end
        end
    end
end

--关键词
function WoWTools_HouseMixin:GetTagsText(entryInfo)
    if entryInfo and entryInfo.dataTagsByID then
        local tag
         for _, name in pairs(entryInfo.dataTagsByID) do
            tag= (tag and tag..PLAYER_LIST_DELIMITER or '')..WoWTools_TextMixin:CN(name)
        end
        if tag then
            return '|A:Map-Filter-Button:0:0|a'..tag
        end
    end
end
