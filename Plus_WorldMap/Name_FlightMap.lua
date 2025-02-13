local e = select(2, ...)
--飞行点名称
local btn







local function Set_Text(self)
    local text
    if self.taxiNodeData and WoWTools_WorldMapMixin.Save.ShowFlightMap_Name then
        if not self.Text and self.taxiNodeData.name then
            self.Text= WoWTools_WorldMapMixin:Create_Wolor_Font(self, 10)
            self.Text:SetPoint('TOP', self, 'BOTTOM', 0, 3)
        end
        text= self.taxiNodeData.name
        if text then
            text= text:match('(.-)'..KEY_COMMA) or text:match('(.-)'..PLAYER_LIST_DELIMITER) or text
            text= e.cn(text)
        end
    end
    if self.Text then
        self.Text:SetText(text or '')
    end
end












local function Init()
    btn= WoWTools_ButtonMixin:Cbtn(FlightMapFrame.BorderFrame.TitleContainer, {size={20,20}, icon='hide'})
    btn:SetPoint('LEFT')

    btn:SetAlpha(0.5)
    btn:SetScript('OnClick', function(self)
        WoWTools_WorldMapMixin.Save.ShowFlightMap_Name= not WoWTools_WorldMapMixin.Save.ShowFlightMap_Name and true or nil
        CloseTaxiMap()
        self:Settings()
    end)
    btn:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.5) end)
    btn:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine('taxiMapID '..(GetTaxiMapID() or ''), (e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL)..' '..(NumTaxiNodes() or 0))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(
            '|A:FlightMaster:0:0|a'..(e.onlyChinese and '飞行点' or MAP_LEGEND_FLIGHTPOINT),
            format(
                CLUB_FINDER_LOOKING_FOR_CLASS_SPEC,
                e.GetShowHide(WoWTools_WorldMapMixin.Save.ShowFlightMap_Name),
                e.onlyChinese and '名称' or  COMMUNITIES_SETTINGS_NAME_LABEL
            )
            ..e.Icon.left
        )
        e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_WorldMapMixin.addName)
        e.tips:Show()
        self:SetAlpha(1)
    end)

    function btn:Settings()
        self:SetNormalAtlas(not WoWTools_WorldMapMixin.Save.ShowFlightMap_Name and e.Icon.disabled or e.Icon.icon)
    end
    btn:Settings()

    hooksecurefunc(FlightMap_FlightPointPinMixin, 'SetFlightPathStyle', Set_Text)
end






function WoWTools_WorldMapMixin:Init_FlightMap_Name()
    Init()
end