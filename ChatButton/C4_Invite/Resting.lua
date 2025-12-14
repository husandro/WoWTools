
local function Save()
    return WoWToolsSave['ChatButton_Invite'] or {}
end





--休息区提示

local function Init()
    local frame= CreateFrame('Frame')
    WoWTools_InviteMixin.RestingFrame= frame

    frame.enterText= '|A:communities-icon-addgroupplus:0:0|a'..(
                    WoWTools_DataMixin.onlyChinese and '进入|cnGREEN_FONT_COLOR:休息|r区'
                    or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ENTER_LFG, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, '|cnGREEN_FONT_COLOR:Rest|r', ZONE))
                )

    frame.leaveText= '|A:communities-icon-addgroupplus:0:0|a'..(
                    WoWTools_DataMixin.onlyChinese and '离开|cnWARNING_FONT_COLOR:休息|r区'
                    or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LEAVE, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, '|cnWARNING_FONT_COLOR:Rest|r', ZONE))
                )

    function frame:set_event()
        self:UnregisterAllEvents()
        if Save().restingTips then
            self:RegisterEvent('PLAYER_UPDATE_RESTING')
        end
    end

    function frame:settings()
        print(
            IsResting() and self.enterText or self.leaveText
        )
    end

    frame:SetScript("OnEvent", frame.settings)
    frame:set_event()
end








function WoWTools_InviteMixin:Init_Resting()
    Init()
end

function WoWTools_InviteMixin:Resting_Settings()
    self.RestingFrame:set_event()
    self.RestingFrame:settings()
end