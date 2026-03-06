
--飞行点名称
local function Save()
   return WoWToolsSave['Plus_WorldMap']
end










local function Init_Hook()
    if not Save().ShowFlightMap_Name then
        return
    end

    WoWTools_DataMixin:Hook(FlightMap_FlightPointPinMixin, 'OnLoad', function(self)
        self.NameLabel= self:CreateFontString(nil, 'ARTWORK', 'WoWToolsWorldFont')
        self.NameLabel:SetPoint('TOP', self, 'BOTTOM', 0, 3)
        self.NameLabel:SetJustifyH('CENTER')
    end)

    WoWTools_DataMixin:Hook(FlightMap_FlightPointPinMixin, 'UpdatePinSize', function(self)--, taxiNodeType
        local text
        if self.taxiNodeData and Save().ShowFlightMap_Name then
            text= self.taxiNodeData.name
            if text then
                text= text:match('(.-)'..KEY_COMMA) or text:match('(.-)'..PLAYER_LIST_DELIMITER) or text
                text= WoWTools_TextMixin:CN(text)
                self.NameLabel:SetScale(Save().FlightMapScale or 1)
            end
        end
        self.NameLabel:SetText(text or '')
    end)
end




local function Init()
    if not C_AddOns.IsAddOnLoaded('Blizzard_FlightMap') then
        EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
            if arg1=='Blizzard_FlightMap' then
                Init()
                EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
            end
        end)
        return
    end







    local btn= CreateFrame('DropdownButton', 'WoWToolsFlightMapButton', FlightMapFrame.BorderFrame.TitleContainer, 'WoWToolsButtonTemplate')
    btn:SetPoint('LEFT')

    btn:SetAlpha(0.5)
    btn:SetScript('OnClick', function(self)
        Save().ShowFlightMap_Name= not  Save().ShowFlightMap_Name and true or nil
        --CloseTaxiMap()
        WoWTools_DataMixin:Call(FlightMapFrame.RefreshAll, FlightMapFrame)
        self:settings()
    end)

    function btn:tooltip(tooltip)
        tooltip:AddDoubleLine('taxiMapID '..(GetTaxiMapID() or ''), (WoWTools_DataMixin.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL)..' '..(NumTaxiNodes() or 0))
        tooltip:AddLine(' ')
        tooltip:AddDoubleLine(
            '|A:FlightMaster:0:0|a'..(WoWTools_DataMixin.onlyChinese and '飞行点' or MAP_LEGEND_FLIGHTPOINT),
            format(
                CLUB_FINDER_LOOKING_FOR_CLASS_SPEC,
                WoWTools_TextMixin:GetShowHide( Save().ShowFlightMap_Name),
                WoWTools_DataMixin.onlyChinese and '名称' or  LFG_LIST_TITLE
            )
            ..WoWTools_DataMixin.Icon.left
        )
        tooltip:AddLine(WoWTools_WorldMapMixin.addName..WoWTools_DataMixin.Icon.icon2)
    end

    function btn:settings()
        if Save().ShowFlightMap_Name then
            self:SetNormalTexture(WoWTools_DataMixin.Icon.icon)
        else
            self:SetNormalAtlas('talents-button-reset')
        end
        Init_Hook()
    end

    btn:SetupMenu(function(self, root)
        if not self:IsMouseOver() then
            return
        end

--缩放
        WoWTools_MenuMixin:Scale(self, root,
        function()--GetValue
            return Save().FlightMapScale or 1
        end, function(alpha)--SetValue
            Save().FlightMapScale= alpha
        end, function()--SetValue
            Save().FlightMapScale=nil
        end)

--打开选项
        root:CreateDivider()
        WoWTools_MenuMixin:OpenOptions(root, {name= WoWTools_WorldMapMixin.addName})
    end)

    btn:settings()



--飞行点，加名称
    WoWTools_DataMixin:Hook(FlightMap_FlightPointPinMixin, 'OnMouseEnter', function(self)
        local info= self.taxiNodeData
        if not info or not info.nodeID then
            return
        end

        GameTooltip:AddLine('nodeID|cffffffff'..WoWTools_DataMixin.Icon.icon2..info.nodeID)
        if info.slotIndex then
            GameTooltip:AddLine('slotIndex|cffffffff'..WoWTools_DataMixin.Icon.icon2..info.slotIndex)
        end
        --WoWTools_TooltipMixin:Show()
        GameTooltip:Show()
    end)






    Init=function()end
end






function WoWTools_WorldMapMixin:Init_FlightMap_Name()
    Init()
end