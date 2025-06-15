

WoWTools_HolidayMixin={}

local P_Save={
    onGoing=true,--仅限: 正在活动
    --disabled= not WoWTools_DataMixin.Player.husandro
    --left=WoWTools_DataMixin.Player.husandro,--内容靠左
    --toTopTrack=true,--向上
    --showDate= true,--时间
}

local function Save()
    return WoWToolsSave['Plus_Holiday']
end














local function Init()
    WoWTools_HolidayMixin:Init_CreateEventFrame()
    WoWTools_HolidayMixin:Init_Calendar_Uptate()
    WoWTools_HolidayMixin:Init_TrackButton()
    Init=function()end
end




local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_ENTERING_WORLD")






local function Init_Open()
    if UnitAffectingCombat('player') then
        panel:RegisterEvent('PLAYER_REGEN_ENABLED')
    else
        EventRegistry:RegisterFrameEventAndCallback("CALENDAR_UPDATE_EVENT_LIST", function(owner)
            if CalendarFrame:IsShown() then
                ToggleCalendar()
            end
            EventRegistry:UnregisterCallback('CALENDAR_UPDATE_EVENT_LIST', owner)
        end)
        ToggleCalendar()
    end
end





panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_Holiday']= WoWToolsSave['Plus_Holiday'] or P_Save

            WoWTools_HolidayMixin.addName= '|A:GarrisonTroops-Health:0:0|a'..(WoWTools_DataMixin.onlyChinese and '节日' or CALENDAR_FILTER_HOLIDAYS)

            WoWTools_PanelMixin:Check_Button({
                checkName= WoWTools_HolidayMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled = not Save().disabled and true or nil
                    print(WoWTools_DataMixin.Icon.icon2..WoWTools_HolidayMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)
                end,
                buttonText= WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION,
                buttonFunc= function()
                    Save().point=nil
                    if WoWTools_HolidayMixin.TrackButton then
                        WoWTools_HolidayMixin.TrackButton:set_point()
                    end
                    print(WoWTools_DataMixin.Icon.icon2..WoWTools_HolidayMixin.addName, WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION)
                end,
                layout= nil,
                category= nil,
            })

            if Save().disabled then
               self:UnregisterAllEvents()
            else
                if C_AddOns.IsAddOnLoaded('Blizzard_Calendar') then
                    Init()
                    self:UnregisterEvent(event)
                end
            end

        elseif arg1=='Blizzard_Calendar' and WoWToolsSave then
            Init()
            self:UnregisterEvent(event)

        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        Init_Open()
        self:UnregisterEvent(event)

    elseif event == "PLAYER_ENTERING_WORLD" and WoWToolsSave then
        Init_Open()
        self:UnregisterEvent(event)
    end
end)