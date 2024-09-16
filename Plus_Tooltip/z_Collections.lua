--Blizzard_Collections



---宠物手册， 召唤随机，偏好宠物，技能ID 
local function Blizzard_Collections()
    hooksecurefunc('PetJournalSummonRandomFavoritePetButton_OnEnter', function()--PetJournalSummonRandomFavoritePetButton
        WoWTools_TooltipMixin:Set_Spell(GameTooltip, 243819)
        GameTooltip:Show()
    end)
end




function WoWTools_TooltipMixin.AddOn.Blizzard_Collections()
    Blizzard_Collections()
end
