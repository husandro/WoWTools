local e= select(2, ...)


--BOSS模型 Blizzard_EncounterJournal.lua
local function Setings(self)
    local text=''
    if not WoWTools_EncounterMixin.Save.hideEncounterJournal and self.displayInfo and EncounterJournal.encounter and EncounterJournal.encounter.info and EncounterJournal.encounter.info.model and EncounterJournal.encounter.info.model.imageTitle then
        if not EncounterJournal.creatureDisplayIDText then
            EncounterJournal.creatureDisplayIDText=WoWTools_LabelMixin:Create(self, {size=10, fontType=EncounterJournal.encounter.info.model.imageTitle})--10, EncounterJournal.encounter.info.model.imageTitle)
            EncounterJournal.creatureDisplayIDText:SetPoint('BOTTOM', EncounterJournal.encounter.info.model.imageTitle, 'TOP', 0 , 10)
        end
        if EncounterJournal.iconImage  then
            text= text..'|T'..EncounterJournal.iconImage..':0|t'..EncounterJournal.iconImage..'|n'
        end
        if self.id then
            text= text..'JournalEncounterCreatureID '.. self.id..'|n'
        end
        if self.uiModelSceneID  then
            text= text..'uiModelSceneID '..self.uiModelSceneID..'|n'
        end
        text= text..'CreatureDisplayID ' .. self.displayInfo
        local name= WoWTools_TextMixin:CN(self.name, true)--汉化
        if name then
            text= text..'|n'..name
        end
    end
    if EncounterJournal.creatureDisplayIDText then
        EncounterJournal.creatureDisplayIDText:SetText(text)
    end
end


function WoWTools_EncounterMixin:Init_Model_Boss()--BOSS模型 
    hooksecurefunc('EncounterJournal_DisplayCreature', Setings)
end
    