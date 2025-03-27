



local function Init()
    EncounterJournal.encounter.instance.mapButton:SetScript('OnLeave', GameTooltip_Hide)
    EncounterJournal.encounter.instance.mapButton:SetScript('OnEnter', function(self)--综述,小地图提示
        local name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, _, mapID= EJ_GetInstanceInfo()
        if not name then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(link or name, (dungeonAreaMapID and 'UiMapID|cnGREEN_FONT_COLOR:'..dungeonAreaMapID..'|r' or '')..(mapID and ' mapID|cnGREEN_FONT_COLOR:'..mapID..'|r' or ''))
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(description, nil,nil,nil, true)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(bgImage and '|T'..bgImage..':26|t'..bgImage, loreImage and '|T'..loreImage..':26|t'..loreImage)
        GameTooltip:AddDoubleLine(buttonImage1 and '|T'..buttonImage1..':26|t'..buttonImage1, buttonImage2 and '|T'..buttonImage2..':26|t'..buttonImage2)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_EncounterMixin.addName)
        GameTooltip:Show()
    end)
end






function WoWTools_EncounterMixin:Init_mapButton_OnEnter()
    Init()
end