








local function calendar_Uptate()
    local indexInfo = C_Calendar.GetEventIndex()
    local info= indexInfo and C_Calendar.GetDayEvent(indexInfo.offsetMonths, indexInfo.monthDay, indexInfo.eventIndex) or {}
    local text
    if info.eventID then
        local title= WoWTools_TextMixin:CN(nil, {holydayID= info.eventID, isName=true})
        text= (info.iconTexture and '|T'..info.iconTexture..':0|t'..info.iconTexture..'|n' or '')
            ..'eventID '..info.eventID
            ..(info.title and '|n'..info.title or '')
            ..(title and '|n'..title or '')
    end

    if text and not CalendarViewHolidayFrame.Text then
        CalendarViewHolidayFrame.Text= WoWTools_LabelMixin:Create(CalendarViewHolidayFrame, {mouse=true, color={r=0, g=0.68, b=0.94, a=1}})
        CalendarViewHolidayFrame.Text:SetPoint('BOTTOMLEFT',12,12)
        CalendarViewHolidayFrame.Text:SetScript('OnLeave', function(self) self:SetAlpha(1) GameTooltip:Hide() end)
        CalendarViewHolidayFrame.Text:SetScript('OnEnter', function(self)
            self:SetAlpha(0.3)
            if not self.eventID then return end
            GameTooltip:SetOwner(self:GetParent(), "ANCHOR_BOTTOMRIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_HolidayMixin.addName)
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine('https://www.wowhead.com/event='..self.eventID, WoWTools_DataMixin.Icon.left)
            GameTooltip:Show()
        end)
        CalendarViewHolidayFrame.Text:SetScript('OnMouseDown', function(frame)
            if not frame.eventID then return end
            WoWTools_TooltipMixin:Show_URL(true, 'event', frame.eventID, nil)
        end)

        CalendarViewHolidayFrame.Texture2=CalendarViewHolidayFrame:CreateTexture()
        local w,h= CalendarViewHolidayFrame:GetSize()
        CalendarViewHolidayFrame.Texture2:SetSize(w-70, h-70)
        CalendarViewHolidayFrame.Texture2:SetPoint('CENTER',40,-40)
        CalendarViewHolidayFrame.Texture2:SetAlpha(0.5)
    end
    if CalendarViewHolidayFrame.Text then
        CalendarViewHolidayFrame.Text.eventID= info.eventID or nil
        CalendarViewHolidayFrame.Text:SetText(text or '')
        CalendarViewHolidayFrame.Texture2:SetTexture(info.iconTexture or 0)
    end
end




local function Init()
    WoWTools_DataMixin:Hook(CalendarViewHolidayFrame, 'update', function(...) calendar_Uptate(...) end)--提示节目ID
    WoWTools_DataMixin:Hook('CalendarViewHolidayFrame_Update', function(...) calendar_Uptate(...) end)

    local btn= WoWTools_ButtonMixin:Cbtn(CalendarFrame.FilterButton, {
        size=23,
        name='WoWToolsHolidayReCurDayButton',
        atlas='UI-HUD-Calendar-'..tonumber(date('%d'))..'-Mouseover'
    })
    btn:SetPoint('RIGHT', CalendarFrame.FilterButton, 'LEFT', 0, -3)
    btn:SetScript('OnLeave', function() GameTooltip:Hide() end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText(WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '返回当月' or NPE_ABANDON_A_RETURN))
        GameTooltip:Show()
    end)
    btn:SetScript('OnMouseDown', function()
	    local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime()
		C_Calendar.SetAbsMonth(currentCalendarTime.month, currentCalendarTime.year)
    end)

    --WoWTools_DataMixin:Hook('CalendarDayButton_Click', function()
    -- local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime()
    CalendarYearBackground:ClearAllPoints()
    CalendarYearName:ClearAllPoints()
    CalendarYearName:SetPoint('RIGHT', btn, 'LEFT', -22, 1)
    CalendarYearName:SetScale(1.5)
    CalendarYearName:SetShadowOffset(1, -1)
    Init=function()end
end

function WoWTools_HolidayMixin:Init_Calendar_Uptate()
   Init()
end