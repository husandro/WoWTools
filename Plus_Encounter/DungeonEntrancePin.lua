
local function Save()
    return WoWToolsSave['Adventure_Journal']
end






--世界地图，副本，提示
local function Init(frame)
    if frame.setEnter or Save().hideEncounterJournal or WoWTools_Mixin:IsLockFrame(frame) then
        return
    end


    frame:HookScript('OnEnter', function(self)
        if Save().hideEncounterJournal or not self.journalInstanceID then
            return
        end

        local isAltKeyDown= IsAltKeyDown()

        local name, description, _, _, _, _, dungeonAreaMapID, _, _, mapID = EJ_GetInstanceInfo(self.journalInstanceID)

        if not GameTooltip:IsShown() then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(name)
        else
            GameTooltip:AddLine(' ')
        end
        local cnName= WoWTools_TextMixin:CN(name)

        GameTooltip:AddDoubleLine(mapID and 'mapID '..mapID or nil,  cnName~=name and cnName or nil)
        GameTooltip:AddDoubleLine('journalInstanceID '..self.journalInstanceID, (dungeonAreaMapID and dungeonAreaMapID>0) and 'dungeonAreaMapID '..dungeonAreaMapID or nil)
        GameTooltip:AddLine(' ')

        if WoWTools_EncounterMixin:GetInstanceData(self, true) then
            GameTooltip:AddLine(' ')
        end
        if isAltKeyDown then
            GameTooltip:AddLine(WoWTools_TextMixin:CN(description), nil,nil,nil,true)
            GameTooltip:AddLine(' ')
        end
        GameTooltip:AddDoubleLine(
            WoWTools_EncounterMixin.addName..WoWTools_DataMixin.Icon.icon2,
            isAltKeyDown and '' or '|cnGREEN_FONT_COLOR:Alt+'..(WoWTools_DataMixin.onlyChinese and '描述' or CALENDAR_EVENT_DESCRIPTION)
        )
        GameTooltip:Show()
    end)
    frame:HookScript('OnLeave', GameTooltip_Hide)

    frame.setEnter=true
end





function WoWTools_EncounterMixin:Init_DungeonEntrancePin()--世界地图，副本，提示
    hooksecurefunc(DungeonEntrancePinMixin, 'OnAcquired', Init)
end