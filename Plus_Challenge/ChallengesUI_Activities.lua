local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end

local Frame

local function Set_Text(self)
    WoWTools_ChallengeMixin:ActivitiesFrame(self)
end









local function Init()
    if Save().hideActivities then
        return
    end

    Frame= CreateFrame('Frame', nil, ChallengesFrame)
    Frame:SetFrameLevel(PVEFrame.TitleContainer:GetFrameLevel()+1)

    Frame:SetSize(1,1)
    Frame:Hide()


    function Frame:Settings()
        self:SetPoint('TOPLEFT', ChallengesFrame, 'TOPLEFT', Save().activitiesX or 10, Save().activitiesY or -53)
        self:SetShown(not Save().hideActivities)
        self:SetScale(Save().activitiesScale or 1)
     end

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

    Frame:Settings()

    Init= function()
        Frame:Settings()
    end
end

function WoWTools_ChallengeMixin:ChallengesUI_Activities()
    Init()
end
