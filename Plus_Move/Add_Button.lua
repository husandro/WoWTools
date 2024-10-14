--添加，移动/缩放，按钮
--创建, 一个移动按钮
local e= select(2, ...)
local function Save()
    return WoWTools_MoveMixin.Save
end









local function Set_Tooltip(self)
    self:SetAlpha(1)
    e.tips:SetOwner(self, "ANCHOR_LEFT")
    e.tips:ClearLines()
    e.tips:AddDoubleLine(e.addName, WoWTools_MoveMixin.addName)
    e.tips:AddLine(format('|cffff00ff%s|r', self.name))
    e.tips:AddLine(' ')
    if self.setZoom then
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save().scale[self.name] or 1), 'Alt+'..e.Icon.mid)
    end
    e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, self.click=='RightButton' and e.Icon.right or e.Icon.left)
    e.tips:Show()
end





local function Set_Scale(btn, name)
    if btn:CanChangeAttribute() then
        name= name or btn:GetParent():GetName()
        local scale= Save().scale[name]
        if scale then
            btn:SetScale(scale)
        end
    end
end





local function Create_Button(frame, name, click, setZoom)
    local btn= WoWTools_ButtonMixin:Cbtn(frame, {texture='Interface\\Cursor\\UI-Cursor-Move', size={22,22}})

    btn.name= name
    btn.setZoom= setZoom
    btn.click= click

    btn:SetPoint('BOTTOM', frame, 'TOP')
    btn:SetFrameLevel(frame:GetFrameLevel()+7)-- 9999)


    btn:SetScript("OnEnter",function(self)
        self:SetAlpha(1)
        Set_Tooltip(self)
    end)

    btn:SetScript("OnLeave", function(self)
        ResetCursor()
        e.tips:Hide()
        self:SetAlpha(0.2)
    end)

    if setZoom then
        Set_Scale(btn, name)

        btn:SetScript('OnMouseWheel', function(self, delta)
            Save().scale[self.name]=WoWTools_FrameMixin:ScaleFrame(self:GetParent(), delta, Save().scale[self.name])
            Set_Tooltip(self)
        end)

    end

    btn:SetAlpha(0.2)
    return btn
end




local function SetupButton(frame, tab)
    if not frame or Save().disabledMove or frame.WoWToolsMoveButton then
        return
    end
    tab= tab or {}

    local name= tab.name or frame:GetName()
    local setZoom= not tab.notZoom and not Save().disabledZoom
    local click= tab.click

    if not name then
        return name
    end

    frame.WoWToolsMoveButton= Create_Button(frame, name, click, setZoom)

    tab.frame= frame
    tab.name= name
    WoWTools_MoveMixin:Setup(frame.WoWToolsMoveButton, tab)
end


















--移动, 能量条
local function Init_UIWidgetPowerBarContainerFrame()--移动, 能量条
    local frame= UIWidgetPowerBarContainerFrame
    if not frame then
        return
    end

    SetupButton(frame)
    if frame.WoWToolsMoveButton or frame.ResizeButton then
        local find=false
        for _, f in pairs(frame.widgetFrames or {}) do
            if f then
                find=true
                break
            end
        end
        if not find then
            if frame.WoWToolsMoveButton then
                frame.WoWToolsMoveButton:Hide()
            end
        end
    end
    
    hooksecurefunc(frame, 'CreateWidget', function(self)
        if self.WoWToolsMoveButton then
            self.WoWToolsMoveButton:SetShown(true)
        end
    end)
    hooksecurefunc(frame, 'RemoveWidget', function(self)
        if self.WoWToolsMoveButton then
            self.WoWToolsMoveButton:SetShown(false)
        end
    end)
    hooksecurefunc(frame, 'RemoveAllWidgets', function(self)
        if self.WoWToolsMoveButton then
            self.WoWToolsMoveButton:SetShown(false)
        end
    end)

end








local function Init()
    SetupButton(ZoneAbilityFrame)--, {frame=ZoneAbilityFrame.SpellButtonContainer})

    Init_UIWidgetPowerBarContainerFrame()--移动, 能量条

    C_Timer.After(4, function()
    --小眼睛
        SetupButton(QueueStatusButton, {save=true, notZoom=true, show=true})

    --编辑模式
        hooksecurefunc(EditModeManagerFrame, 'ExitEditMode', function()
            WoWTools_MoveMixin:SetPoint(QueueStatusButton)--小眼睛, 
        end)
    end)
end




function WoWTools_MoveMixin:Init_AddButton()
    Init()
end