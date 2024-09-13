--[[
GetPosition()
IsInDelve()
Get_Minimap_Tracking
]]

WoWTools_MapMixin={}

function WoWTools_MapMixin:GetPosition()
   --local _x, _y, _z, mapID = UnitPosition("player");
    return UnitPosition("player")
end


--InstanceDifficulty.lua
function WoWTools_MapMixin:IsInDelve()
    local mapID= select(4, self:GetPosition())
    return C_DelvesUI.HasActiveDelve(mapID)
end





function WoWTools_MapMixin:Get_Minimap_Tracking(checkName, isSettings)
    for trackingID=1, C_Minimap.GetNumTrackingTypes() do
        local info= C_Minimap.GetTrackingInfo(trackingID)
        if info and info.name== checkName then            
            local active= info.active
            if isSettings then
                active= not info.active and true or false
                C_Minimap.SetTracking(trackingID, active)
            end
            return active
        end
    end
end

