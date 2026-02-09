--地图POI提示 AreaPOIDataProvider.lua
local function Save()
    return  WoWToolsSave['Plus_WorldMap']
end



local function Set_Update(self, elapsed)
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
            end


        elseif self.widgetID then
            local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(self.widgetID)
            if widgetInfo and widgetInfo.shownState== 1 and widgetInfo.text and widgetInfo.hasTimer then--剩余时间：
                local cn= WoWTools_TextMixin:CN(widgetInfo.text)
                self.Text:SetText(cn:gsub(HEADER_COLON, '|n'))
            end
        end
    end
end






--地图POI提示 AreaPOIDataProvider.lua
local function Init()
    if not Save().ShowAreaPOI_Name then
        return
    end

    WoWTools_DataMixin:Hook(AreaPOIPinMixin, 'OnAcquired', function(self, poiInfo)
        if not self.WoWToolsFrame then
            self.WoWToolsFrame= CreateFrame('Frame', nil, self)
            self.WoWToolsFrame:SetAllPoints()
            self.WoWToolsFrame.Text= self.WoWToolsFrame:CreateFontString(nil, 'ARTWORK', 'WorldMapTextFont')
            self.WoWToolsFrame.Text:SetPoint('TOP', self.Texture or self, 'BOTTOM')
        else
            self:SetScript('OnUpdate', nil)
            self.WoWToolsFrame.elapsed= nil
            self.WoWToolsFrame.areaPoiID= poiInfo.areaPoiID
            self.WoWToolsFrame.widgetID= nil
        end
        if not Save().ShowAreaPOI_Name then
            poiInfo= {}
        else
            poiInfo= poiInfo or self.poiInfo or {}
        end

        local text

        if poiInfo.areaPoiID and C_AreaPoiInfo.IsAreaPOITimed(poiInfo.areaPoiID) then
            self.WoWToolsFrame.areaPoiID= poiInfo.areaPoiID
            self.WoWToolsFrame:SetScript('OnUpdate', Set_Update)

        elseif poiInfo.widgetSetID then
            for _, widget in ipairs(C_UIWidgetManager.GetAllWidgetsBySetID(poiInfo.widgetSetID) or {}) do
                if widget and widget.widgetID and  widget.widgetType==Enum.UIWidgetVisualizationType.TextWithState then
                    local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(widget.widgetID)
                    if widgetInfo and widgetInfo.shownState==Enum.WidgetShownState.Shown then

                        if widgetInfo.hasTimer then--剩余时间：
                            self.WoWToolsFrame.widgetID= widget.widgetID
                            self.WoWToolsFrame:SetScript('OnUpdate', Set_Update)
                            break

                        elseif widgetInfo.text and widgetInfo.text~='' then
                            local icon, num= widgetInfo.text:match('(|T.-|t).-]|r.-(%d+)')
                            local text2= widgetInfo.text:match('(%d+/%d+)')--次数

                            if icon and num then
                                text= icon..'|cff00ff00'..num..'|r'
                            end
                            if text2 then
                                text= (text or '')..'|cffff00ff'..text2..'|r'
                            end
                            break
                        end
                    end
                end
            end
        end

        text= text or WoWTools_TextMixin:CN(poiInfo.name)
        if text then
            text= text:match('%((.+)%)') or text:match('（(.+)）')  or text
        end

        self.WoWToolsFrame.Text:SetText(text or '')
        self.WoWToolsFrame.Text:SetFontHeight(Save().areaPoinFontSize or 10)
    end)











    --POI提示 AreaPOIDataProvider.lua
    --AreaPOIPinMixin:TryShowTooltip
    WoWTools_DataMixin:Hook(AreaPoiUtil, 'TryShowTooltip', function(_, _, poiInfo)
        local tooltip = Save().ShowAreaPOI_Name
                and poiInfo
                and (poiInfo.areaPoiID or poiInfo.widgetSetID)
                and GetAppropriateTooltip()

        if not tooltip or not tooltip:IsShown() or WoWTools_FrameMixin:IsLocked(tooltip) or not poiInfo then
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

        WoWTools_TooltipMixin:CalculatePadding(tooltip)
    end)



    Init=function()end
end


--BaseMapPoiPinMixin
function WoWTools_WorldMapMixin:Init_AreaPOI_Name()
    Init()
end
