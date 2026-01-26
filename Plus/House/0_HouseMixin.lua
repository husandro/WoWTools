WoWTools_HouseMixin={}

function WoWTools_HouseMixin:GetObjectiveText(entryInfo)
    if entryInfo
        and entryInfo.entryID
        and C_ContentTracking.IsTrackable(Enum.ContentTrackingType.Decor, entryInfo.entryID.recordID)
    then
        local targetType, targetID = C_ContentTracking.GetCurrentTrackingTarget(Enum.ContentTrackingType.Decor, entryInfo.entryID.recordID)
        if targetType then
            local obj= C_ContentTracking.GetObjectiveText(targetType, targetID)
            if obj and obj~='' then
                return CreateAtlasMarkup("waypoint-mappin-minimap-untracked", 16, 16, -3, 0)..WoWTools_TextMixin:CN(obj)
            end
        end
    end
end