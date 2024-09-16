WoWTools_TimeMixin={}





function WoWTools_TimeMixin:SecondsToClock(seconds, displayZeroHours, notDisplaySeconds)--TimeUtil.lua
    if seconds and seconds>=0 then
        local units = ConvertSecondsToUnits(seconds)
        if units.hours > 0 or displayZeroHours then
            if not notDisplaySeconds then
                return format('%.2d:%.2d:%.2d', units.hours, units.minutes, units.seconds)
            else
                return format('%.2d:%.2d', units.hours, units.minutes)
            end
        else
            return format('%.2d:%.2d', units.minutes, units.seconds)
        end
    end
end







function WoWTools_TimeMixin:Info(value, chat, time, expirationTime)
    if value and value>0 then
        time= time or GetTime()
        while time<value do
            time= time+86400
        end
        time= time - value
        time= time<0 and 0 or time
        if chat then
            return WoWTools_TimeMixin:SecondsToClock(time), time
        else
            return SecondsToTime(time), time
        end
    elseif expirationTime and expirationTime>0 then
        time= time or GetTime()
        while time< expirationTime do
            time= time+ 86400
        end
        time= expirationTime- time
        time= time<0 and 0 or time
        if chat then
            return WoWTools_TimeMixin:SecondsToClock(time), time
        else
            return SecondsToTime(time), time
        end
    else
        if chat then
            return WoWTools_TimeMixin:SecondsToClock(0), 0
        else
            return SecondsToTime(0), 0
        end
    end
end