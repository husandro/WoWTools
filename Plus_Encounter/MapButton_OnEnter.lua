local e= select(2, ...)



local function Init()
    EncounterJournal.encounter.instance.mapButton:SetScript('OnLeave', GameTooltip_Hide)
    EncounterJournal.encounter.instance.mapButton:SetScript('OnEnter', function(self3)--综述,小地图提示
        local name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, _, mapID= EJ_GetInstanceInfo()
        if not name then
            return
        end
        e.tips:SetOwner(self3, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(link or name, (dungeonAreaMapID and 'UiMapID|cnGREEN_FONT_COLOR:'..dungeonAreaMapID..'|r' or '')..(mapID and ' mapID|cnGREEN_FONT_COLOR:'..mapID..'|r' or ''))
        e.tips:AddLine(' ')
        e.tips:AddLine(description, nil,nil,nil, true)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(bgImage and '|T'..bgImage..':26|t'..bgImage, loreImage and '|T'..loreImage..':26|t'..loreImage)
        e.tips:AddDoubleLine(buttonImage1 and '|T'..buttonImage1..':26|t'..buttonImage1, buttonImage2 and '|T'..buttonImage2..':26|t'..buttonImage2)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.addName, WoWTools_EncounterMixin.addName)
        e.tips:Show()
    end)
end






function WoWTools_EncounterMixin:Init_mapButton_OnEnter()
    Init()
end