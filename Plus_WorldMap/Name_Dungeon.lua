
--地下城，加名称
local function Init()
    if not WoWToolsSave['Plus_WorldMap'].ShowDungeon_Name then
        return
    end

    WoWTools_DataMixin:Hook(DungeonEntrancePinMixin, 'OnAcquired', function(self)
        local text= WoWTools_TextMixin:CN(self.name)
        if text and not self.Text then
            self.Text= WoWTools_WorldMapMixin:Create_Wolor_Font(self, 10)
            self.Text:SetPoint('TOP', self, 'BOTTOM', 0, 3)
        end
        if self.Text then
            self.Text:SetText(text or '')
        end
    end)






    WoWTools_DataMixin:Hook(DungeonEntrancePinMixin, 'CheckShowTooltip', function(self)
        local tooltip = self.journalInstanceID and self.journalInstanceID>0 and GetAppropriateTooltip()
        if not tooltip or not tooltip:IsShown() or WoWTools_FrameMixin:IsLocked(tooltip) then
            return
        end

        local name, description, _, _, _, _, dungeonAreaMapID, _, _, mapID = EJ_GetInstanceInfo(self.journalInstanceID)

        if mapID and mapID>0 then
            tooltip:AddLine('instanceID|cffffffff'..WoWTools_DataMixin.Icon.icon2..mapID)
        end

        tooltip:AddLine('journalInstanceID|cffffffff'..WoWTools_DataMixin.Icon.icon2..self.journalInstanceID)

        if dungeonAreaMapID and dungeonAreaMapID>0 and mapID~=dungeonAreaMapID then
            tooltip:AddLine('dungeonAreaMapID|cffffffff'..WoWTools_DataMixin.Icon.icon2..dungeonAreaMapID)
        end

        local cn= WoWTools_TextMixin:CN(name)
        if tooltip.textLeft and name and cn~=name then
            tooltip.textLeft:SetText(name)
        end

        local isAlt= IsAltKeyDown()
        if not isAlt or not description then
            WoWTools_EncounterMixin:GetInstanceData(self, true)
        end

        if description then
            if isAlt then
                tooltip:AddLine(' ')
                tooltip:AddLine(
                    '|cffffffff'
                    ..WoWTools_TextMixin:CN(description),
                    nil,nil,nil,true
                )
            else
                tooltip:AddLine('|cnGREEN_FONT_COLOR:<Alt+'..(WoWTools_DataMixin.onlyChinese and '描述' or CALENDAR_EVENT_DESCRIPTION)..'>')
            end
        end

        tooltip:Show()
    end)


    Init= function()end
end

function WoWTools_WorldMapMixin:Init_Dungeon_Name()
    Init()
end