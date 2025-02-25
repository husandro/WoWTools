local function Save()
    return WoWTools_MoveMixin.Save
end










--移动, 位置
local function Set_Frame_Point(frame, name)--设置, 移动, 位置
    if not frame
        or not name
        or not Save().SavePoint
        or frame.notSave
    then
        return
    end


    local p= Save().point[name]
    if p and p[1] and p[3] and p[4] and p[5] then
        local target= frame.targetFrame or frame

        if target:IsProtected() and InCombatLockdown() then

            EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner, tab)
                target:ClearAllPoints()
                target:SetPoint(tab.p[1], UIParent, tab.p[3], tab.p[4], tab.p[5])
                EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
            end, nil, {
                target=target,
                p=p,
            })

        else
            target:ClearAllPoints()
            target:SetPoint(p[1], UIParent, p[3], p[4], p[5])
        end
    end
end








local function Set_Move_Frame_Script(frame)
    frame:HookScript("OnDragStart", function(self, d)
        if
            (d=='RightButton' or d=='LeftButton')
            and (d== self.click or not self.click)
            and (self.isAltKeyDown and IsAltKeyDown() or not self.isAltKeyDown)
        then
            (self.targetFrame or self):StartMoving()
        end
    end)

    frame:HookScript("OnDragStop", function(self)
        local targetFrame= self.targetFrame or self
        targetFrame:StopMovingOrSizing()
        ResetCursor()
        local name= self.name or targetFrame:GetName()
        if targetFrame.notSave or not name then
            return
        end
        Save().point[name]= {targetFrame:GetPoint(1)}
        Save().point[name][2]= nil
    end)

    frame:HookScript("OnMouseDown", function(self, d)--设置, 光标
        if
            (d=='RightButton' or d=='LeftButton')
            and (d== self.click or not self.click)
            and (self.isAltKeyDown and IsAltKeyDown() or not self.isAltKeyDown)
        then
            SetCursor('UI_MOVE_CURSOR')
        end
    end)

    frame:HookScript("OnMouseUp", ResetCursor)--停止移动
    frame:HookScript("OnLeave", ResetCursor)
end









--移动 Frame
local function Set_Move_Frame(frame, target, click, notSave, notFuori, isAltKeyDown)
    frame.targetFrame= target--要移动的Frame
    frame.setMoveFrame=true
    frame.click= click
    frame.notSave= notSave
    frame.isAltKeyDown= isAltKeyDown

    if notFuori then
        frame:SetClampedToScreen(true)
        if target then
            target:SetClampedToScreen(true)
        end
    end

    frame:SetMovable(true)
    if target then
        target:SetMovable(true)
    end

    if click=='RightButton' then
        frame:RegisterForDrag("RightButton")
    elseif click=='LeftButton' then
        frame:RegisterForDrag("LeftButton")
    else
        frame:RegisterForDrag("LeftButton", "RightButton")
    end

    Set_Move_Frame_Script(frame)
end


























function WoWTools_MoveMixin:Setup(frame, tab)
    tab= tab or {}

    local SavePoint= self.Save.SavePoint
    local moveToScreenFuori= self.Save.moveToScreenFuori
    local disabledMove= self.Save.disabledMove

    local target= tab.frame
    local name= tab.name or (target and target:GetName()) or (frame and frame:GetName())

    local click= tab.click
    local notSave= ((tab.notSave or not SavePoint) and not tab.save) and true or nil
    local notFuori=  not moveToScreenFuori and SavePoint or tab.notFuori
    local isAltKeyDown= tab.isAltKeyDown

    if not frame or not name then --or not frame.setMoveFrame then
        return
    end

    tab.name= name

    self:ScaleSize(frame, tab)

    if (disabledMove and not tab.needMove) or tab.notMove  then
        return
    end

    Set_Move_Frame(frame, target, click, notSave, notFuori, isAltKeyDown)


    Set_Frame_Point(frame, name)--设置, 移动, 位置
end






function WoWTools_MoveMixin:SetPoint(frame, name)--设置, 移动,
    if frame then
        name= name or frame:GetName()
        if name then
            Set_Frame_Point(frame, name)
        end
    end
end