--旅程

local function Init()
    WoWTools_DataMixin:Hook(EncounterJournalJourneysFrame.JourneysList, 'Update', function(frame)
        
    end)

    
    WoWTools_DataMixin:Hook(RenownCardButtonMixin, 'OnEnter', function()
        print('RenownCardButtonMixin')
    end)
    Init=function()end
end

function WoWTools_EncounterMixin:Init_JourneysList()
    Init()
end