local e= select(2, ...)








local function calendar_Uptate()
    local indexInfo = C_Calendar.GetEventIndex()
    local info= indexInfo and C_Calendar.GetDayEvent(indexInfo.offsetMonths, indexInfo.monthDay, indexInfo.eventIndex) or {}
    local text
    if info.eventID then
        local title= e.cn(nil, {holydayID= info.eventID, isName=true})
        text= (info.iconTexture and '|T'..info.iconTexture..':0|t'..info.iconTexture..'|n' or '')
            ..'eventID '..info.eventID
            ..(info.title and '|n'..info.title or '')
            ..(title and '|n'..title or '')
    end

    if text and not CalendarViewHolidayFrame.Text then
        CalendarViewHolidayFrame.Text= WoWTools_LabelMixin:CreateLabel(CalendarViewHolidayFrame, {mouse=true, color={r=0, g=0.68, b=0.94, a=1}})
        CalendarViewHolidayFrame.Text:SetPoint('BOTTOMLEFT',12,12)
        CalendarViewHolidayFrame.Text:SetScript('OnLeave', function(self) self:SetAlpha(1) e.tips:Hide() end)
        CalendarViewHolidayFrame.Text:SetScript('OnEnter', function(self)
            self:SetAlpha(0.3)
            if not self.eventID then return end
            e.tips:SetOwner(self:GetParent(), "ANCHOR_BOTTOMRIGHT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.addName, WoWTools_HolidayMixin.addName)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine('https://www.wowhead.com/event='..self.eventID, e.Icon.left)
            e.tips:Show()
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






function WoWTools_HolidayMixin:Init_Calendar_Uptate()
    hooksecurefunc(CalendarViewHolidayFrame, 'update', calendar_Uptate)--提示节目ID    
    hooksecurefunc('CalendarViewHolidayFrame_Update', calendar_Uptate)
end