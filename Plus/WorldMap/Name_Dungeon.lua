--地下城，加名称
local function Save()
    return  WoWToolsSave['Plus_WorldMap']
end




local function Init_Label(self)
    self.Text= self:CreateFontString(nil, 'ARTWORK', 'WorldMapTextFont')
    self.Text:SetJustifyH('CENTER')
    self.Text:SetPoint('TOP', self, 'BOTTOM', 0, 3)
end

local function Init()
    if not Save().ShowDungeon_Name then
        return
    end

    WoWTools_DataMixin:Hook(DungeonEntrancePinMixin, 'OnLoad', Init_Label)

    WoWTools_DataMixin:Hook(DungeonEntrancePinMixin, 'OnAcquired', function(self)
        if not self.Text then
            Init_Label(self)
        end

        self.Text:SetText(
            Save().ShowDungeon_Name
            and WoWTools_TextMixin:CN(self.name)
            or ''
        )
        self.Text:SetFontHeight(Save().dungeonFontSize or 10)
    end)






    WoWTools_DataMixin:Hook(DungeonEntrancePinMixin, 'CheckShowTooltip', function(self)
        local tooltip = Save().ShowDungeon_Name
            and self.journalInstanceID
            and self.journalInstanceID>0
            and GetAppropriateTooltip()

        if not tooltip or not tooltip:IsShown() or WoWTools_FrameMixin:IsLocked(tooltip) then
            return
        end

        local name, description, _, _, _, _, dungeonAreaMapID, _, _, mapID = EJ_GetInstanceInfo(self.journalInstanceID)

        if mapID and mapID>0 then
            tooltip:AddLine('instanceID|cffffffff'..WoWTools_DataMixin.Icon.icon2..mapID)
        end

        tooltip:AddLine('journalInstanceID|cffffffff'..WoWTools_DataMixin.Icon.icon2..self.journalInstanceID)

        if dungeonAreaMapID and dungeonAreaMapID>0 then
            tooltip:AddLine('uiMapID|cffffffff'..WoWTools_DataMixin.Icon.icon2..dungeonAreaMapID)
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