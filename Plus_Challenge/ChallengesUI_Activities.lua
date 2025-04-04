local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end

local Frame

local function Set_Text(self)
    WoWTools_ChallengeMixin:ActivitiesFrame(self, {isPvP=not Save().activitiesHidePvP})
end









local function Init()
    if Save().hideActivities then
        return
    end

    Frame= CreateFrame('Frame', nil, ChallengesFrame)
    Frame:SetFrameStrata('HIGH')
    Frame:SetFrameLevel(3)
    Frame:SetSize(1,1)
    Frame:Hide()

    function Frame:Settings()
        local show= not Save().hideActivities
        self:SetPoint('TOPLEFT', ChallengesFrame, 'TOPLEFT', Save().activitiesX or 10, Save().activitiesY or -53)
        self:SetShown(show)
        self:SetScale(Save().activitiesScale or 1)
     end

    Frame:Settings()

    Frame:SetScript('OnShow', function(self)
        Set_Text(self)
        self:RegisterEvent('MYTHIC_PLUS_CURRENT_AFFIX_UPDATE')
    end)
    Frame:SetScript('OnHide', function(self)
        self:UnregisterEvent('MYTHIC_PLUS_CURRENT_AFFIX_UPDATE')
        WoWTools_ChallengeMixin:ActivitiesFrame(Frame, {isClear=true})
    end)
    Frame:SetScript('OnEvent', function(self)
        Set_Text(self)
    end)

    Init= function()
        Frame:SetShown(false)
        Frame:Settings()
    end
end

function WoWTools_ChallengeMixin:ChallengesUI_Activities()
    Init()
end
