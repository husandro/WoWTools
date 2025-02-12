--添加，移动/缩放，按钮
--创建, 一个移动按钮
local e= select(2, ...)
local function Save()
    return WoWTools_MoveMixin.Save
end









local function Set_Tooltip(self)
    e.tips:SetOwner(self, "ANCHOR_LEFT")
    e.tips:ClearLines()
    e.tips:AddDoubleLine(e.addName, WoWTools_MoveMixin.addName)
    e.tips:AddLine(format('|cffff00ff%s|r', self.name))
    e.tips:AddLine(' ')
    if self.setZoom then
        e.tips:AddDoubleLine(
            (e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save().scale[self.name] or 1),
            'Alt+'..e.Icon.mid
        )
    end
    e.tips:AddDoubleLine(
        e.onlyChinese and '移动' or NPE_MOVE,
        'Alt+'..(self.click=='RightButton' and e.Icon.right or e.Icon.left)
    )
    e.tips:Show()
end






local function Init_Menu(self, root)
--缩放
    WoWTools_MenuMixin:Scale(root, function()
        return Save.scale
    end, function(value)
        Save.scale= value
        self:set_scale()
    end)
end


local function SetupButton(frame, tab)
    tab= tab or {}
    local name
    if frame and not Save().disabledMove and not frame.WoWToolsMoveButton then
        name= tab.name or frame:GetName()
    end
    if not name then
        return
    end

    tab= tab or {}
    local setZoom= not tab.notZoom and not Save().disabledZoom
    local click= tab.click
    local setPoint= tab.setPoint
    local size= tab.size or 23
    local alpha= tab.alpha or 0.3

    local btn= WoWTools_ButtonMixin:Cbtn(frame, {
        texture='Interface\\Cursor\\UI-Cursor-Move',
        size=size,
        name='WoWToolsMoveButton_'..name
    })

    btn.name= name
    btn.setZoom= setZoom
    --btn.click= click
    btn.alpha= alpha

--透明度
    function btn:set_alpha()
        if self.alpha~=1 then
            self:SetAlpha(GameTooltip:IsOwned(self) and 1 or self.alpha)
        end
    end
    btn:set_alpha()

--位置
    if setPoint then
        setPoint(btn)
    else
        btn:SetPoint('BOTTOM', frame, 'TOP')
    end
    btn:SetFrameLevel(frame:GetFrameLevel()+7)-- 9999)

--提示
    btn:SetScript("OnLeave", function(self)
        ResetCursor()
        e.tips:Hide()
        self:set_alpha()
    end)
    btn:SetScript("OnEnter",function(self)
        Set_Tooltip(self)
        self:set_alpha()
    end)

--菜单
    btn:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and not IsModifierKeyDown() then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)

--缩放
    if setZoom then
        if frame:CanChangeAttribute() then
            local scale= Save().scale[name]
            if scale and scale~=1 then
                frame:SetScale(scale)
            end
        end

        btn:SetScript('OnMouseWheel', function(self, delta)
            Save().scale[self.name]= WoWTools_FrameMixin:ScaleFrame(
                self.targetFrame,
                delta,
                Save().scale[self.name]
            )
            Set_Tooltip(self)
        end)
    end

    tab.targetFrame= frame
    tab.name= name
    tab.click= 'RightButton'--点击，移动
    tab.isAltKeyDown= true

    WoWTools_MoveMixin:Setup(frame.WoWToolsMoveButton, tab)

    frame.WoWToolsMoveButton= btn
    return btn
end


















--移动, 能量条
local function Init_UIWidgetPowerBarContainerFrame()--移动, 能量条
    local frame= UIWidgetPowerBarContainerFrame
    if not frame then
        return
    end

    SetupButton(frame)

    if frame.WoWToolsMoveButton then
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

--宠物对战
    local btn=SetupButton(PetBattleFrame.BottomFrame, {
        name='PetBattleFrame_BottomFrame',
        size= {20, 26},
        setPoint=function(button)
            button:SetPoint('BOTTOMRIGHT', PetBattleFrame.BottomFrame.MicroButtonFrame, -4, 0)
        end,
    })

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

--[[function WoWTools_MoveMixin:SetupButton(frame, tab)
    SetupButton(frame, tab)
end]]