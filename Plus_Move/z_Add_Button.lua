--添加，移动/缩放，按钮


--移动, 能量条
local function Init_UIWidgetPowerBarContainerFrame()--移动, 能量条
    local frame= UIWidgetPowerBarContainerFrame
    if not frame then
        return
    end

    WoWTools_MoveMixin:CreateButton(frame)
    if frame.moveButton or frame.ResizeButton then
        local find=false
        for _, f in pairs(frame.widgetFrames or {}) do
            if f then
                find=true
                break
            end
        end
        if not find then
            if frame.moveButton then
                frame.moveButton:Hide()
            end
            if frame.ResizeButton then
                frame.ResizeButton:Hide()
            end
        end
    end
    hooksecurefunc(frame, 'CreateWidget', function(self)
        if self.moveButton then
            self.moveButton:SetShown(true)
        end
        if self.ResizeButton then
            self.ResizeButton:SetShown(true)
        end
    end)
    hooksecurefunc(frame, 'RemoveWidget', function(self)
        if self.moveButton then
            self.moveButton:SetShown(false)
        end
        if self.ResizeButton then
            self.ResizeButton:SetShown(false)
        end
    end)
    hooksecurefunc(frame, 'RemoveAllWidgets', function(self)
        if self.moveButton then
            self.moveButton:SetShown(false)
        end
        if self.ResizeButton then
            self.ResizeButton:SetShown(false)
        end
    end)

end











local function Init()
    WoWTools_MoveMixin:CreateButton(ZoneAbilityFrame, {frame=ZoneAbilityFrame.SpellButtonContainer})

    Init_UIWidgetPowerBarContainerFrame()--移动, 能量条

    C_Timer.After(4, function()
    --小眼睛
        WoWTools_MoveMixin:CreateButton(QueueStatusButton, {save=true, notZoom=true, show=true})

    --编辑模式
        hooksecurefunc(EditModeManagerFrame, 'ExitEditMode', function()
            WoWTools_MoveMixin:SetPoint(QueueStatusButton)--小眼睛, 
        end)
    end)
end




function WoWTools_MoveMixin:Init_AddButton()
    Init()
end