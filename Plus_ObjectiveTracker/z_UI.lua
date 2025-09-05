

--任务，追踪柆
function WoWTools_TextureMixin.Events:Blizzard_ObjectiveTracker()
    self:SetAlphaColor(ScenarioObjectiveTracker.StageBlock.NormalBG, nil, nil, 0.3)

    self:SetButton(ObjectiveTrackerFrame.Header.MinimizeButton)

    self:Init_BGMenu_Frame(ObjectiveTrackerFrame,{
        alpha=0,
        enabled=true,
        bgPoint=function(icon)
            icon:SetAllPoints(ObjectiveTrackerFrame.NineSlice)
        end,
        isNewButton=true,
        newButtonPoint=function(btn, icon)
            btn:SetPoint('RIGHT', ObjectiveTrackerFrame.Header.MinimizeButton, 'LEFT', -23, 0)
            btn:SetFrameStrata(ObjectiveTrackerFrame.Header.MinimizeButton:GetFrameStrata())
            btn:SetFrameLevel(ObjectiveTrackerFrame.Header.MinimizeButton:GetFrameLevel()+1)

            local function Set_Collapsed(collapsed)
                local show= not collapsed
                btn:SetShown(show)
                icon:SetShown(show)
                local far= ObjectiveTrackerFrame.AirParticlesFar
                if far then
                    far:SetShown(show)
                end
            end

            Set_Collapsed(ObjectiveTrackerFrame:IsCollapsed())
          
            WoWTools_DataMixin:Hook(ObjectiveTrackerFrame, 'SetCollapsed', function(_, collapsed)
               Set_Collapsed(collapsed)
            end)
        end,
        settings=function(icon, texture, alpha)
            ObjectiveTrackerFrame.NineSlice:SetAlpha(texture and 0 or 1)
            icon:SetAlpha(texture and alpha or 0)
            local far= ObjectiveTrackerFrame.AirParticlesFar
            if far then
                far:SetAlpha(texture and 1 or 0)
            end
        end
    })
end




















--追踪栏
function WoWTools_MoveMixin.Events:Blizzard_ObjectiveTracker()
    EventRegistry:RegisterCallback("EditMode.Exit", function()
        ObjectiveTrackerFrame:SetMovable(true)
    end)

    self:Setup(ObjectiveTrackerFrame.Header, {
        notSave=true,
        notZoom=true,
        frame=ObjectiveTrackerFrame,
    })
end
