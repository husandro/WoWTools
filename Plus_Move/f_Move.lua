local function Save()
    return WoWTools_MoveMixin.Save
end














--移动, 位置
local function Set_Frame_Point(frame, name)--设置, 移动, 位置
    if not frame
        or not name
        or not Save().SavePoint
        or frame.notSave
        or not frame:CanChangeAttribute()
    then
        return
    end


    local p= Save().point[name]
    if p and p[1] and p[3] and p[4] and p[5] then
        local target= frame.targetFrame or frame
        target:ClearAllPoints()
        target:SetPoint(p[1], UIParent, p[3], p[4], p[5])
    end
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

    frame:HookScript("OnDragStart", function(self, d)
        IsModifierKeyDown()
        if
            (d=='RightButton' or d=='LeftButton')
            and (d== self.click or not self.click)
            and (self.isAltKeyDown and IsAltKeyDown() or not self.isAltKeyDown)
        then
            local f= self.targetFrame or self
            f:StartMoving()
        end
    end)

    frame:HookScript("OnDragStop", function(s)
        local s2= s.targetFrame or s
        s2:StopMovingOrSizing()
        ResetCursor()
        local frameName= s2:GetName()
        if s.notSave or not frameName then
            return
        end
        Save().point[frameName]= {s2:GetPoint(1)}
        Save().point[frameName][2]= nil
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








function WoWTools_MoveMixin:Setup(frame, tab)
    tab= tab or {}
    local save= Save()

    local target= tab.frame
    local name= tab.name or (target and target:GetName()) or (frame and frame:GetName())
    local click= tab.click
    local notSave= ((tab.notSave or not save.SavePoint) and not tab.save) and true or nil
    local notFuori=  not save.moveToScreenFuori and save.SavePoint or tab.notFuori
    local isAltKeyDown= tab.isAltKeyDown

    if not frame or not name or frame.setMoveFrame then
        return
    end

    tab.name= name

    self:ScaleSize(frame, tab)

    if (save.disabledMove and not tab.needMove) or tab.notMove  then
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