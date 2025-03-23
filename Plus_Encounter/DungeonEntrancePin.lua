
local function Save()
    return WoWTools_EncounterMixin.Save
end






--世界地图，副本，提示
local function Init(frame)
    if frame.setEnter or Save().hideEncounterJournal then
        return
    end

    frame:HookScript('OnEnter', function(self)
        if Save().hideEncounterJournal or not self.journalInstanceID then
            return
        end
        local name, _, _, _, _, _, dungeonAreaMapID, _, _, mapID = EJ_GetInstanceInfo(self.journalInstanceID)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        local cnName=WoWTools_TextMixin:CN(name)
        GameTooltip:AddDoubleLine(name,  (cnName and name..' ' or '')..(mapID and ' mapID '..mapID or ''))
        GameTooltip:AddDoubleLine('journalInstanceID: |cnGREEN_FONT_COLOR:'..self.journalInstanceID, (dungeonAreaMapID and dungeonAreaMapID>0) and 'dungeonAreaMapID '..dungeonAreaMapID or '')
        GameTooltip:AddLine(' ')
        if WoWTools_EncounterMixin:GetInstanceData(self, true) then
            GameTooltip:AddLine(' ')
        end
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_EncounterMixin.addName)
        GameTooltip:Show()
    end)
    frame:SetScript('OnLeave', GameTooltip_Hide)
    frame.setEnter=true
end





function WoWTools_EncounterMixin:Init_DungeonEntrancePin()--世界地图，副本，提示
    hooksecurefunc(DungeonEntrancePinMixin, 'OnAcquired', Init)
end