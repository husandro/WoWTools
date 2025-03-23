
--实时玩家当前坐标


--地图POI提示 AreaPOIDataProvider.lua
local INSTANCE_DIFFICULTY_FORMAT='('..WoWTools_TextMixin:Magic(INSTANCE_DIFFICULTY_FORMAT)..')'-- "（%s）";
local IsSetup


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







local function Init(frame)
    if UnitAffectingCombat('player') then
        return
    end

    local isEnabled= WoWTools_WorldMapMixin.Save.ShowAreaPOI_Name


    frame.updateWidgetID=nil
    frame.updateAreaPoiID=nil
    frame:SetScript('OnUpdate', nil)



    if not frame.Text and isEnabled and (frame.name or frame.widgetSetID or frame.areaPoiID) then
        frame.Text= WoWTools_WorldMapMixin:Create_Wolor_Font(frame, 10)
        frame.Text:SetPoint('TOP', frame, 'BOTTOM', 0, 3)
    end

    if not isEnabled or (not frame.widgetSetID and not frame.areaPoiID) then
        if frame and frame.Text then
            local text--地图，地名，名称
            if isEnabled and frame.name then
                text= WoWTools_TextMixin:CN(frame.name)
                text= text:match(INSTANCE_DIFFICULTY_FORMAT) or text
            end
            frame.Text:SetText(text or '')
        end
        return
    end


    local text

    if frame.areaPoiID and C_AreaPoiInfo.IsAreaPOITimed(frame.areaPoiID) then
        frame.updateAreaPoiID= frame.areaPoiID
        frame:SetScript('OnUpdate', set_Widget_Text_OnUpDate)

    elseif frame.widgetSetID then
        for _,widget in ipairs(C_UIWidgetManager.GetAllWidgetsBySetID(frame.widgetSetID) or {}) do
            if widget and widget.widgetID and  widget.widgetType==8 then
                local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(widget.widgetID) or {}
                if widgetInfo.shownState== Enum.WidgetShownState.Shown and widgetInfo.text then
                    if widgetInfo.hasTimer then--剩余时间：
                        text= widgetInfo.text
                        frame.updateWidgetID= widget.widgetID
                        if not frame.setScripOK then
                            frame.setScripOK=true
                            frame:SetScript('OnUpdate', set_Widget_Text_OnUpDate)
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

    frame.Text:SetText(text or frame.name or '')
end











--BaseMapPoiPinMixin
function WoWTools_WorldMapMixin:Init_AreaPOI_Name()
    if IsSetup or not self.Save.ShowAreaPOI_Name then
        return
    end

    hooksecurefunc(AreaPOIPinMixin,'OnAcquired', Init)--地图POI提示 AreaPOIDataProvider.lua
    IsSetup= true
end