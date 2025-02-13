local id, e = ...

WoWTools_HolidayMixin={
    Save={
        onGoing=true,--仅限: 正在活动
        --disabled= not e.Player.husandro
        --left=e.Player.husandro,--内容靠左
        --toTopTrack=true,--向上
        --showDate= true,--时间
    },
    addName=nil,
    TrackButton=nil,
}


local function Save()
    return WoWTools_HolidayMixin.Save
end











local function Init_Open()
    do ToggleCalendar() end
    C_Timer.After(2, function()
        if CalendarFrame then
            if CalendarFrame:IsShown() then
                ToggleCalendar()
            else
                do ToggleCalendar() end
                if CalendarFrame:IsShown() then
                    ToggleCalendar()
                else
                    C_Timer.After(2, function()
                        if CalendarFrame:IsShown() then ToggleCalendar() end
                    end)
                end
            end
        end
    end)
end











local panel= CreateFrame('Frame')
panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then

            if WoWToolsSave[CALENDAR_FILTER_HOLIDAYS] then
                WoWTools_HolidayMixin.Save= WoWToolsSave[CALENDAR_FILTER_HOLIDAYS]
                WoWToolsSave[CALENDAR_FILTER_HOLIDAYS]=nil
            else
                WoWTools_HolidayMixin.Save= WoWToolsSave['Plus_Holiday'] or Save()
            end
            
            WoWTools_HolidayMixin.addName= '|A:GarrisonTroops-Health:0:0|a'..(e.onlyChinese and '节日' or CALENDAR_FILTER_HOLIDAYS)

            e.AddPanel_Check_Button({
                checkName= WoWTools_HolidayMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled = not Save().disabled and true or nil
                    print(WoWTools_Mixin.addName, WoWTools_HolidayMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                end,
                buttonText= e.onlyChinese and '重置位置' or RESET_POSITION,
                buttonFunc= function()
                    Save().point=nil
                    if WoWTools_HolidayMixin.TrackButton then
                        WoWTools_HolidayMixin.TrackButton:set_point()
                    end
                    print(WoWTools_Mixin.addName, WoWTools_HolidayMixin.addName, e.onlyChinese and '重置位置' or RESET_POSITION)
                end,
                tooltip= WoWTools_HolidayMixin.addName,
                layout= nil,
                category= nil,
            })

            if  Save().disabled then
                self:UnregisterEvent('ADDON_LOADED')
            else
                if C_AddOns.IsAddOnLoaded('Blizzard_Calendar') then
                    WoWTools_HolidayMixin:Init_CreateEventFrame()
                    WoWTools_HolidayMixin:Init_Calendar_Uptate()
                    WoWTools_HolidayMixin:Init_TrackButton()
                    self:UnregisterEvent('ADDON_LOADED')
                end
                Init_Open()
            end

        elseif arg1=='Blizzard_Calendar' then
            WoWTools_HolidayMixin:Init_CreateEventFrame()
            WoWTools_HolidayMixin:Init_Calendar_Uptate()
            WoWTools_HolidayMixin:Init_TrackButton()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_Holiday']= Save()
        end
    end
end)
