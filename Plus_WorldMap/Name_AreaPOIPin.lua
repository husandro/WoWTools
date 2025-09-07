
--实时玩家当前坐标


--地图POI提示 AreaPOIDataProvider.lua
local INSTANCE_DIFFICULTY_FORMAT='('..WoWTools_TextMixin:Magic(INSTANCE_DIFFICULTY_FORMAT)..')'-- "（%s）";



local function set_Widget_Text_OnUpDate(self, elapsed)
    self.elapsed= (self.elapsed or 1) + elapsed
    if self.elapsed>1 then
        self.elapsed= 0
        if self.updateAreaPoiID then
            local time= C_AreaPoiInfo.GetAreaPOISecondsLeft(self.updateAreaPoiID)
            if time and time>0 then
                if time<86400 then
                    self.Text:SetText(WoWTools_TimeMixin:SecondsToClock(time))
                else
                    self.Text:SetText(SecondsToTime(time, true))
                end
                return
            end
        end
        if self.updateWidgetID then
            local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(self.updateWidgetID) or {}
            if widgetInfo.shownState== 1 and widgetInfo.text and widgetInfo.hasTimer then--剩余时间：
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

    WoWTools_DataMixin:Hook(AreaPOIPinMixin,'OnAcquired', function(self)
        if WoWTools_FrameMixin:IsLocked(self) then
            return
        end

        local isEnabled=  WoWToolsSave['Plus_WorldMap'].ShowAreaPOI_Name


        self.updateWidgetID=nil
        self.updateAreaPoiID=nil
        self:SetScript('OnUpdate', nil)
        self:HookScript('OnHide', function(s)
            s.elapsed= nil
            if self.Text then
                self.Text:SetText('')
            end
        end)


        if not self.Text and isEnabled and (self.name or self.widgetSetID or self.areaPoiID) then
            self.Text= WoWTools_WorldMapMixin:Create_Wolor_Font(self, 10)
            self.Text:SetPoint('TOP', self, 'BOTTOM', 0, 3)
        end

        if not isEnabled or (not self.widgetSetID and not self.areaPoiID) then
            if self and self.Text then
                local text--地图，地名，名称
                if isEnabled and self.name then
                    text= WoWTools_TextMixin:CN(self.name)
                    text= text:match(INSTANCE_DIFFICULTY_FORMAT) or text
                end
                self.Text:SetText(text or '')
            end
            return
        end


        local text

        if self.areaPoiID and C_AreaPoiInfo.IsAreaPOITimed(self.areaPoiID) then
            self.updateAreaPoiID= self.areaPoiID
            self:SetScript('OnUpdate', function(...)
                set_Widget_Text_OnUpDate(...)
            end)

        elseif self.widgetSetID then
            for _,widget in ipairs(C_UIWidgetManager.GetAllWidgetsBySetID(self.widgetSetID) or {}) do
                if widget and widget.widgetID and  widget.widgetType==8 then
                    local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(widget.widgetID) or {}
                    if widgetInfo.shownState== Enum.WidgetShownState.Shown and widgetInfo.text then
                        if widgetInfo.hasTimer then--剩余时间：
                            text= widgetInfo.text
                            self.updateWidgetID= widget.widgetID
                            if not self.setScripOK then
                                self.setScripOK=true
                                self:SetScript('OnUpdate', function(...)
                                    set_Widget_Text_OnUpDate(...)
                                end)
                            end
                        else
                            local icon, num= widgetInfo.text:match('(|T.-|t).-]|r.-(%d+)')
                            local text2= widgetInfo.text:match('(%d+/%d+)')--次数
                            if icon and num then
                                text= icon..'|cff00ff00'..num..'|r'
                            end
                            if text2 then
                                text= (text or '')..'|cffff00ff'..text2..'|r'
                            end
                        end
                        if text then
                            break
                        end
                    end
                end
            end
        end

        self.Text:SetText(text or self.name or '')
    end)

    Init=function()end
end


--BaseMapPoiPinMixin
function WoWTools_WorldMapMixin:Init_AreaPOI_Name()
    Init()
end