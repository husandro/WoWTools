--挑战, 钥匙插件, 界面

function WoWTools_MoveMixin.Events:Blizzard_ChallengesUI()
    self:Setup(ChallengesKeystoneFrame)

    --if not Save().disabledZoom then
        ChallengesFrame.WeeklyInfo:SetPoint('BOTTOMRIGHT')
        ChallengesFrame.WeeklyInfo.Child:SetPoint('BOTTOMRIGHT')
        ChallengesFrame.WeeklyInfo.Child.RuneBG:SetPoint('BOTTOMRIGHT')
        for _, region in pairs({ChallengesFrame:GetRegions()}) do
            if region:GetObjectType()=='Texture' then
                region:SetPoint('BOTTOMRIGHT')
            end
        end
        ChallengesFrame:HookScript('OnShow', function()
            local frame= PVEFrame
            if not frame.ResizeButton or frame.ResizeButton.disabledSize or not frame:CanChangeAttribute() then
                return
            end
            local size= WoWToolsSave['Plus_Move'].size['PVEFrame_KEY']
            frame.ResizeButton.setSize= true
            if size then
                frame:SetSize(size[1], size[2])
            else
                frame:SetSize(PVE_FRAME_BASE_WIDTH, 428)
            end
        end)
    --end
end