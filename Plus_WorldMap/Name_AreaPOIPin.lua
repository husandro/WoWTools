--地图POI提示 AreaPOIDataProvider.lua
local INSTANCE_DIFFICULTY_FORMAT='('..WoWTools_TextMixin:Magic(INSTANCE_DIFFICULTY_FORMAT)..')'-- "（%s）";



local function set_Widget_Text_OnUpDate(self, elapsed)
    self.elapsed= (self.elapsed or 1) + elapsed
    if self.elapsed>1 then
        self.elapsed= 0
        if self.areaPoiID then
            local time= C_AreaPoiInfo.GetAreaPOISecondsLeft(self.areaPoiID)
            if time and time>0 then
                if time<86400 then
                    self.Text:SetText(WoWTools_TimeMixin:SecondsToClock(time))
                else
                    self.Text:SetText(SecondsToTime(time, true))
                end
                return
            end
        end
        if self.widgetID then
            local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(self.widgetID)
            if widgetInfo and widgetInfo.shownState== 1 and widgetInfo.text and widgetInfo.hasTimer then--剩余时间：
                self.Text:SetText(widgetInfo.text:gsub(HEADER_COLON, '|n'))
            end
        end
    end
end












--地图POI提示 AreaPOIDataProvider.lua
local function Init()
    if not WoWToolsSave['Plus_WorldMap'].ShowAreaPOI_Name then
        return
    end

    WoWTools_DataMixin:Hook(AreaPOIPinMixin, 'OnAcquired', function(self, poiInfo)
        poiInfo= poiInfo or self.poiInfo

        if WoWTools_FrameMixin:IsLocked(self) or not poiInfo then
            return
        end

        self.widgetID= nil
        self.areaPoiID= nil
        self:SetScript('OnUpdate', nil)

        if not (poiInfo.name or poiInfo.widgetSetID or poiInfo.areaPoiID) then
            if self.Text then
                self.Text:SetText('')
            end
            return
        end

        if not self.Text  then
            self.Text= WoWTools_WorldMapMixin:Create_Wolor_Font(self, 10)
            self.Text:SetPoint('TOP', self, 'BOTTOM', 0, 3)
        end

        if poiInfo.areaPoiID and C_AreaPoiInfo.IsAreaPOITimed(poiInfo.areaPoiID) then
            self.areaPoiID= poiInfo.areaPoiID
            self:SetScript('OnUpdate', set_Widget_Text_OnUpDate)
            return

        elseif poiInfo.widgetSetID then
            for _, widget in ipairs(C_UIWidgetManager.GetAllWidgetsBySetID(poiInfo.widgetSetID) or {}) do
                if widget and widget.widgetID and  widget.widgetType==Enum.UIWidgetVisualizationType.TextWithState then
                    local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(widget.widgetID)
                    if widgetInfo and widgetInfo.shownState==Enum.WidgetShownState.Shown and widgetInfo.text then
                        if widgetInfo.hasTimer then--剩余时间：
                            self.widgetID= widget.widgetID
                            self:SetScript('OnUpdate', set_Widget_Text_OnUpDate)

                        else
                            local icon, num= widgetInfo.text:match('(|T.-|t).-]|r.-(%d+)')
                            local text2= widgetInfo.text:match('(%d+/%d+)')--次数
                            local text
                            if icon and num then
                                text= icon..'|cff00ff00'..num..'|r'
                            end
                            if text2 then
                                text= (text or '')..'|cffff00ff'..text2..'|r'
                            end
                            self.Text:SetText(text or '')
                        end
                        return
                    end
                end
            end
        end

        local text= WoWTools_TextMixin:CN(poiInfo.name or self.name, {areaPoiID=poiInfo.areaPoiID, isName=true})

        text= text and text:match(INSTANCE_DIFFICULTY_FORMAT) or text

        self.Text:SetText(text or '')
    end)











    --POI提示 AreaPOIDataProvider.lua
    --AreaPOIPinMixin:TryShowTooltip
    WoWTools_DataMixin:Hook(AreaPoiUtil, 'TryShowTooltip', function(_, _, poiInfo)
        local tooltip = poiInfo and GetAppropriateTooltip()
        if not tooltip or not tooltip:IsShown() or not (poiInfo.areaPoiID or not poiInfo.widgetSetID) or WoWTools_FrameMixin:IsLocked(tooltip) then
            return
        end
        if poiInfo.areaPoiID then
            tooltip:AddLine('areaPoiID|cffffffff'..WoWTools_DataMixin.Icon.icon2..poiInfo.areaPoiID)
        end
        if poiInfo.widgetSetID then
            tooltip:AddLine('widgetSetID|cffffffff'..WoWTools_DataMixin.Icon.icon2..poiInfo.widgetSetID)
            for _,widget in ipairs(C_UIWidgetManager.GetAllWidgetsBySetID(poiInfo.widgetSetID) or {}) do
                if widget and widget.widgetID and widget.shownState==1 then
                    tooltip:AddLine('widgetID|cffffffff'..WoWTools_DataMixin.Icon.icon2..widget.widgetID)
                end
            end
        end
        if poiInfo.factionID then
            WoWTools_TooltipMixin:Set_Faction(tooltip, poiInfo.factionID)
        end

        WoWTools_DataMixin:Call('GameTooltip_CalculatePadding', tooltip)
    end)


    Init=function()end
end


--BaseMapPoiPinMixin
function WoWTools_WorldMapMixin:Init_AreaPOI_Name()
    Init()
end
