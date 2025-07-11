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
    elseif expirationTime and expirationTime>0 then--到期
        time= time or GetTime()

        while time> expirationTime do
            expirationTime= expirationTime+ 86400
        end
        time= expirationTime-time
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


-- upData 是上次更新时间，格式为 date('%Y-%m-%d %H:%M:%S')
-- (%d+)%-(%d+)%-(%d+) (%d+):(%d+):(%d+)
function WoWTools_TimeMixin:GetUpdate_Seconds(upData, curData)
    local seconds=0
    if upData then
        curData = curData or date('%Y-%m-%d %H:%M:%S')
        local y, m, d, h, min, s = upData:match('(%d+)%-(%d+)%-(%d+) (%d+):(%d+):(%d+)')
        local y2, m2, d2, h2, min2, s2= curData:match('(%d+)%-(%d+)%-(%d+) (%d+):(%d+):(%d+)')
        if y and m and d and h and min and s then
            local t = time({year = y, month = m, day = d, hour = h, min = min, sec = s})
            if t then
                seconds= time({year = y2, month = m2, day = d2, hour = h2, min = min2, sec = s2}) - t
            end
        end
    end
    return seconds
end


function WoWTools_TimeMixin:SecondsToFullTime(seconds)
    if not seconds then
        return ''
    end
    
    local years = math.floor(seconds / (365*24*60*60))--31536000
    seconds = seconds % (365*24*60*60)
    local months = math.floor(seconds / (30*24*60*60))
    seconds = seconds % (30*24*60*60)
    local days = math.floor(seconds / (24*60*60))
    seconds = seconds % (24*60*60)
    local hours = math.floor(seconds / (60*60))
    seconds = seconds % (60*60)
    local minutes = math.floor(seconds / 60)
    seconds = math.floor(seconds % 60)

    local str = ""
    if years > 0 then str = str .. years ..(WoWTools_DataMixin.onlyChinese and "年" or 'Y') end
    if months > 0 then str = str .. months ..(WoWTools_DataMixin.onlyChinese and "月" or 'M') end
    if days > 0 then str = str .. days ..(WoWTools_DataMixin.onlyChinese and "日" or 'D') end
    if hours > 0 then str = str .. hours ..(WoWTools_DataMixin.onlyChinese and "时" or 'h') end
    if minutes > 0 then str = str .. minutes ..(WoWTools_DataMixin.onlyChinese and "分" or 'm') end
    if seconds>0 then str = str .. minutes ..(WoWTools_DataMixin.onlyChinese and "秒" or 's') end


    return str
end