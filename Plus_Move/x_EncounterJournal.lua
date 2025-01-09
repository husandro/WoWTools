--冒险指南





local function Init()
    EncounterJournalMonthlyActivitiesFrame.ScrollBox:SetPoint('BOTTOM')

    EncounterJournalInstanceSelectBG:SetPoint('BOTTOMRIGHT', 0,2)
    EncounterJournalInstanceSelect.ScrollBox:SetPoint('BOTTOMLEFT', -3, 15)
    EncounterJournal.LootJournalItems.ItemSetsFrame:SetPoint('TOPRIGHT', -22, -10)
    for _, region in pairs({EncounterJournal.LootJournalItems:GetRegions()}) do
        if region:GetObjectType()=='Texture' then
            region:SetPoint('BOTTOM')
            break
        end
    end
    EncounterJournal.LootJournal.ScrollBox:SetPoint('TOPLEFT', 20, -51)
    for _, region in pairs({EncounterJournal.LootJournal:GetRegions()}) do
        if region:GetObjectType()=='Texture' then
            region:SetPoint('BOTTOM')
            break
        end
    end
    EncounterJournalEncounterFrameInfo:SetPoint('TOP')
    EncounterJournalEncounterFrameInfo.BossesScrollBox:SetPoint('TOP', 0, -43)
    EncounterJournalEncounterFrameInstanceFrame:SetPoint('TOP')
    EncounterJournalEncounterFrameInfoBG:SetPoint('TOP')
    EncounterJournalEncounterFrameInstanceFrameMapButton:ClearAllPoints()
    EncounterJournalEncounterFrameInstanceFrameMapButton:SetPoint('TOPLEFT', 33, -275)
    EncounterJournalEncounterFrameInstanceFrame.LoreScrollingFont:SetPoint('TOPRIGHT', -35, -330)
    EncounterJournalEncounterFrameInfoOverviewScrollFrame:SetPoint('TOP',0,-43)
    EncounterJournalEncounterFrameInfo.LootContainer:SetPoint('TOP', 0, -43)
    EncounterJournalEncounterFrameInfoDetailsScrollFrame:SetPoint('TOP', 0, -43)
    EncounterJournalEncounterFrameInfoModelFrame:ClearAllPoints()
    EncounterJournalEncounterFrameInfoModelFrame:SetPoint('RIGHT', 0, 0)

    WoWTools_MoveMixin:Setup(EncounterJournal, {
        minW=800,
        minH=496,
        maxW=800,
        setSize=true,
        sizeRestFunc=function(self)
            self.target:SetSize(800, 496)
        end
    })
end


WoWTools_MoveMixin.ADDON_LOADED['Blizzard_EncounterJournal']= Init