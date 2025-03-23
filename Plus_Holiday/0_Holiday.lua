local id, e = ...

WoWTools_HolidayMixin={
    Save={
        onGoing=true,--仅限: 正在活动
        --disabled= not WoWTools_DataMixin.Player.husandro
        --left=WoWTools_DataMixin.Player.husandro,--内容靠左
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
    EventRegistry:RegisterFrameEventAndCallback("CALENDAR_UPDATE_EVENT_LIST", function(owner)
        ToggleCalendar()
        EventRegistry:UnregisterCallback('CALENDAR_UPDATE_EVENT_LIST', owner)
    end)
    ToggleCalendar()
end







local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWTools_HolidayMixin.Save= WoWToolsSave['Plus_Holiday'] or Save()

            local addName= '|A:GarrisonTroops-Health:0:0|a'..(WoWTools_Mixin.onlyChinese and '节日' or CALENDAR_FILTER_HOLIDAYS)
            WoWTools_HolidayMixin.addName= addName

            WoWTools_PanelMixin:Check_Button({
                checkName= addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled = not Save().disabled and true or nil
                    print(WoWTools_DataMixin.Icon.icon2.. addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_Mixin.onlyChinese and '重新加载UI' or RELOADUI)
                end,
                buttonText= WoWTools_Mixin.onlyChinese and '重置位置' or RESET_POSITION,
                buttonFunc= function()
                    Save().point=nil
                    if WoWTools_HolidayMixin.TrackButton then
                        WoWTools_HolidayMixin.TrackButton:set_point()
                    end
                    print(WoWTools_DataMixin.Icon.icon2.. addName, WoWTools_Mixin.onlyChinese and '重置位置' or RESET_POSITION)
                end,
                layout= nil,
                category= nil,
            })

            if Save().disabled then
                self:UnregisterEvent(event)
            else
                C_Timer.After(2, function()
                    if UnitAffectingCombat('player') then
                        self:RegisterEvent('PLAYER_REGEN_ENABLED')
                    else
                        Init_Open()
                    end
                end)
            end

        elseif arg1=='Blizzard_Calendar' then
            WoWTools_HolidayMixin:Init_CreateEventFrame()
            WoWTools_HolidayMixin:Init_Calendar_Uptate()
            WoWTools_HolidayMixin:Init_TrackButton()

        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        Init_Open()
        self:UnregisterEvent(event)

    elseif event == "PLAYER_LOGOUT" then
        if not WoWTools_DataMixin.ClearAllSave then
            WoWToolsSave['Plus_Holiday']=Save()
        end
    end
end)