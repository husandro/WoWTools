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










local IsOpened
local function Init_Open()
    EventRegistry:RegisterFrameEventAndCallback("CALENDAR_UPDATE_EVENT_LIST", function()
        if not IsOpened then
            ToggleCalendar()
            IsOpened=true
        end
    end)
    ToggleCalendar()
end





EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(_, arg1)
    if arg1==id then

        WoWTools_HolidayMixin.Save= WoWToolsSave['Plus_Holiday'] or Save()
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

        if not Save().disabled then
            C_Timer.After(0.3, Init_Open)
        end

    elseif arg1=='Blizzard_Calendar' then
        if not Save().disabled then
            WoWTools_HolidayMixin:Init_CreateEventFrame()
            WoWTools_HolidayMixin:Init_Calendar_Uptate()
            WoWTools_HolidayMixin:Init_TrackButton()
        end
    end
end)


EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGOUT", function()
    if not e.ClearAllSave then
        WoWToolsSave['Plus_Holiday']= Save()
    end
end)