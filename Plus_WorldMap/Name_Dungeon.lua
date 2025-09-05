
--地下城，加名称
local IsSetup



local function Dungeon_Name(self)
    local text
    if  WoWToolsSave['Plus_WorldMap'].ShowDungeon_Name and self.name then
        if not self.Text then
            self.Text= WoWTools_WorldMapMixin:Create_Wolor_Font(self, 10)
            self.Text:SetPoint('TOP', self, 'BOTTOM', 0, 3)
        end
        text= WoWTools_TextMixin:CN(self.name)
    end
    if self.Text then
        self.Text:SetText(text or '')
    end
end




function WoWTools_WorldMapMixin:Init_Dungeon_Name()
    if IsSetup or not WoWToolsSave['Plus_WorldMap'].ShowDungeon_Name then
        return
    end

    WoWTools_DataMixin:Hook(DungeonEntrancePinMixin, 'OnAcquired', Dungeon_Name)
    IsSetup= true
end