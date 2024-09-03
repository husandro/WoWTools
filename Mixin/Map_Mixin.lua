--[[
GetPosition()
IsInDelve()
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