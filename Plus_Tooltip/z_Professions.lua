--专业
--lizzard_Professions.lua
local function Blizzard_Professions()
    hooksecurefunc(Professions, 'SetupProfessionsCurrencyTooltip', function(currencyInfo)
        if currencyInfo then
            local nodeID = ProfessionsFrame.SpecPage:GetDetailedPanelNodeID()
            local currencyTypesID = nodeID and Professions.GetCurrencyTypesID(nodeID)
            if currencyTypesID then
                GameTooltip_AddBlankLineToTooltip(GameTooltip)
                WoWTools_TooltipMixin:Set_Currency(GameTooltip, currencyTypesID)--货币
                GameTooltip:AddDoubleLine('nodeID', '|cffffffff'..nodeID..'|r')
            end
        end
    end)


    --专精，技能，查询
    hooksecurefunc(ProfessionsSpecPathMixin, 'OnEnter', function(self)
        if self.nodeID then--self.nodeInfo.ID
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine('nodeID '..self.nodeID, self.entryID and 'entryID '..self.entryID)

            local name= WoWTools_TooltipMixin.WoWHead..'profession-trait/'..(self.nodeID or '')
            WoWTools_TooltipMixin:Set_Web_Link(GameTooltip, {name=name})
            GameTooltip:Show()
        end
    end)

    WoWTools_TooltipMixin.AddOn.Blizzard_Professions=nil
end




function WoWTools_TooltipMixin.AddOn.Blizzard_Professions()
    Blizzard_Professions()
end