--挑战, 钥匙插件, 界面
local function Save()
    return WoWTools_MoveMixin.Save
end




local function Init()
    WoWTools_MoveMixin:Setup(ChallengesKeystoneFrame)

    if not Save().disabledZoom then
        ChallengesFrame.WeeklyInfo:SetPoint('BOTTOMRIGHT')
        ChallengesFrame.WeeklyInfo.Child:SetPoint('BOTTOMRIGHT')
        ChallengesFrame.WeeklyInfo.Child.RuneBG:SetPoint('BOTTOMRIGHT')
        for _, region in pairs({ChallengesFrame:GetRegions()}) do
            if region:GetObjectType()=='Texture' then
                region:SetPoint('BOTTOMRIGHT')
            end
        end
        ChallengesFrame:HookScript('OnShow', function()
            local self= PVEFrame
            if self.ResizeButton.disabledSize or UnitAffectingCombat('player') then
                return
            end
            local size= Save().size['PVEFrame_KEY']
            self.ResizeButton.setSize= true
            if size then
                self:SetSize(size[1], size[2])
            else
                self:SetSize(PVE_FRAME_BASE_WIDTH, 428)
            end
        end)
    end
end




WoWTools_MoveMixin.ADDON_LOADED['Blizzard_ChallengesUI']= Init