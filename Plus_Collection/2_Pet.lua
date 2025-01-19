--宠物 2
--Blizzard_PetCollection.lua
local e= select(2, ...)






local function Init()
    --增加，总数
    PetJournal.PetCount.Label:ClearAllPoints()--太长了，
    PetJournal.PetCount.Label:SetPoint('RIGHT', PetJournal.PetCount.Count, 'LEFT', -2, 0)
    PetJournal.PetCount.Label:SetJustifyH('RIGHT')
    hooksecurefunc('PetJournal_UpdatePetList', function()
        if not PetJournal:IsVisible() then
            return
        end
        PetJournal.PetCount.Count:SetFormattedText('%d/%d', C_PetJournal.GetNumPets())
    end)
end





function WoWTools_PlusCollectionMixin:Init_Pet()--宠物 2
    Init()
end