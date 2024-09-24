local e= select(2, ...)
local function Save()
    return WoWTools_InviteMixin.Save
end

local RestingFrame


--休息区提示
local function set_event()--设置, 休息区提示事件
    if Save().restingTips then
        panel:RegisterEvent('PLAYER_UPDATE_RESTING')
    else
        panel:UnregisterEvent('PLAYER_UPDATE_RESTING')
    end
end

local function Init()
    local frame= CreateFrame("Frame")
    WoWTools_InviteMixin.RestingFrame= frame

    function frame:set_event()
        self:UnregisterAllEvents()
        if Save().restingTips then
            self:RegisterEvent('PLAYER_UPDATE_RESTING')
        end
    end

    function frame:settings()
        if IsResting() then
            print(
                '|A:communities-icon-addgroupplus:0:0|a|cff00ff00'
                ..(e.onlyChinese and '进入休息区域' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ENTER_LFG, CALENDAR_STATUS_OUT), ZONE))
            )
        else
            print(
                '|A:communities-icon-addgroupplus:0:0|a|cffff00ff'
                ..(e.onlyChinese and '离开休息区域' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LEAVE, CALENDAR_STATUS_OUT), ZONE))
            )
        end
    end

    frame:SetScript("OnEvent", frame.settings)
    frame:set_event()
    
end

local function set_PLAYER_UPDATE_RESTING()--设置, 休息区提示
    if IsResting() then
        print(
            '|A:communities-icon-addgroupplus:0:0|a|cff00ff00'
            ..(e.onlyChinese and '进入休息区域' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ENTER_LFG, CALENDAR_STATUS_OUT), ZONE))
        )
        
    else
        print(
            '|A:communities-icon-addgroupplus:0:0|a|cffff00ff'
            ..(e.onlyChinese and '离开休息区域' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LEAVE, CALENDAR_STATUS_OUT), ZONE))
        )
    end
end

function WoWTools_InviteMixin:Init_Resting()
    Init()
end