
--飞行点，加名称
local function Blizzard_FlightMap()
    hooksecurefunc(FlightMap_FlightPointPinMixin, 'OnMouseEnter', function(self2)
        local info= self2.taxiNodeData
        if info then
            GameTooltip:AddDoubleLine('nodeID '..(info.nodeID or ''), 'slotIndex '..(info.slotIndex or ''))
            GameTooltip:Show()
        end
    end)

    WoWTools_TooltipMixin.AddOn.Blizzard_FlightMap=nil
end


function WoWTools_TooltipMixin.AddOn.Blizzard_FlightMap()
    Blizzard_FlightMap()
end