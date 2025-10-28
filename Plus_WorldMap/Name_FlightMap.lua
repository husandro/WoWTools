
--飞行点名称
local btn







local function Set_Text(self)
    local text
    if self.taxiNodeData and  WoWToolsSave['Plus_WorldMap'].ShowFlightMap_Name then
        if not self.Text and self.taxiNodeData.name then
            self.Text= WoWTools_WorldMapMixin:Create_Wolor_Font(self, 10)
            self.Text:SetPoint('TOP', self, 'BOTTOM', 0, 3)
        end
        text= self.taxiNodeData.name
        if text then
            text= text:match('(.-)'..KEY_COMMA) or text:match('(.-)'..PLAYER_LIST_DELIMITER) or text
            text= WoWTools_TextMixin:CN(text)
        end
    end
    if self.Text then
        self.Text:SetText(text or '')
    end
end












local function Init()
    btn= WoWTools_ButtonMixin:Cbtn(FlightMapFrame.BorderFrame.TitleContainer, {size=20})
    btn:SetPoint('LEFT')

    btn:SetAlpha(0.5)
    btn:SetScript('OnClick', function(self)
         WoWToolsSave['Plus_WorldMap'].ShowFlightMap_Name= not  WoWToolsSave['Plus_WorldMap'].ShowFlightMap_Name and true or nil
        CloseTaxiMap()
        self:Settings()
    end)
    btn:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(0.5) end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine('taxiMapID '..(GetTaxiMapID() or ''), (WoWTools_DataMixin.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL)..' '..(NumTaxiNodes() or 0))
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            '|A:FlightMaster:0:0|a'..(WoWTools_DataMixin.onlyChinese and '飞行点' or MAP_LEGEND_FLIGHTPOINT),
            format(
                CLUB_FINDER_LOOKING_FOR_CLASS_SPEC,
                WoWTools_TextMixin:GetShowHide( WoWToolsSave['Plus_WorldMap'].ShowFlightMap_Name),
                WoWTools_DataMixin.onlyChinese and '名称' or  COMMUNITIES_SETTINGS_NAME_LABEL
            )
            ..WoWTools_DataMixin.Icon.left
        )
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_WorldMapMixin.addName)
        GameTooltip:Show()
        self:SetAlpha(1)
    end)

    function btn:Settings()
        if WoWToolsSave['Plus_WorldMap'].ShowFlightMap_Name then
            self:SetNormalTexture('Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools')
        else
            self:SetNormalAtlas('talents-button-reset')
        end
    end
    btn:Settings()

    WoWTools_DataMixin:Hook(FlightMap_FlightPointPinMixin, 'SetFlightPathStyle', function(...)
        Set_Text(...)
    end)









    --飞行点，加名称
    WoWTools_DataMixin:Hook(FlightMap_FlightPointPinMixin, 'OnMouseEnter', function(self)
        local info= self.taxiNodeData
        if not info or not info.nodeID then
            return
        end

        GameTooltip:AddDoubleLine(
            'nodeID|cffffffff'..WoWTools_DataMixin.Icon.icon2..info.nodeID,
            info.slotIndex and 'slotIndex|cffffffff'..WoWTools_DataMixin.Icon.icon2..info.slotIndex
        )

        WoWTools_DataMixin:Call('GameTooltip_CalculatePadding', GameTooltip)
    end)

    Init=function()end
end






function WoWTools_WorldMapMixin:Init_FlightMap_Name()
    Init()
end