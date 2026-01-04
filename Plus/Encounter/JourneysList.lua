local function Init()
    WoWTools_DataMixin:Hook(JourneysFrameMixin, 'SetupJourneysList', function()

    end)

    Init=function()end
end

function WoWTools_EncounterMixin:Init_JourneysList()
    Init()
end