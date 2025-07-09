
WoWTools_MoveMixin={
    Events={},
    Frames={},
}

local function Save()
    return WoWToolsSave['Plus_Move']
end










--移动, 位置
local function Set_Frame_Point(self, name)--设置, 移动, 位置
    local data= self and self.moveFrameData

    local p
    if data and name and Save().SavePoint and not data.notSave then
        p= Save().point[name]
    end

    if not p or not p[1] then
        return
    end

    local frame= _G[data.target] or self

    if WoWTools_FrameMixin:IsLocked(frame) then
        EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner, tab)
            tab.target:ClearAllPoints()
            tab.target:SetPoint(tab.p[1], UIParent, tab.p[3], tab.p[4], tab.p[5])
            EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
        end, nil, {
            target=frame,
            p=p,
        })

    else
        frame:ClearAllPoints()
        frame:SetPoint(p[1], UIParent, p[3], p[4], p[5])
    end

    return true
end




local function Set_OnDragStart(self, d)
    local data= self.moveFrameData
    if
        (d=='RightButton' or d=='LeftButton')
        and (d== data.click or not data.click)
        and (data.isAltKeyDown and IsAltKeyDown() or not data.isAltKeyDown)
    then
        local frame= _G[data.target] or self
        if frame and frame:IsMovable() and not WoWTools_FrameMixin:IsLocked(frame) then
            frame:StartMoving()
        end
    end
end

local function Set_OnDragStop(self)
    local data= self.moveFrameData
    local frame= _G[data.target] or self
    local name= frame:GetName()

    ResetCursor()

    frame:StopMovingOrSizing()

    if not data.notSave and WoWTools_FrameMixin:IsInSchermo(frame) then
        Save().point[name]= {frame:GetPoint(1)}
        Save().point[name][2]= nil
    end
end

--设置光标
local function Set_OnMouseDown(self, d)
    local data= self.moveFrameData
    local frame= _G[data.target] or self

    if
        (d=='RightButton' or d=='LeftButton')
        and (d== data.click or not data.click)
        and (data.isAltKeyDown and IsAltKeyDown() or not data.isAltKeyDown)
        and frame:IsMovable()
        and not WoWTools_FrameMixin:IsLocked(frame)
    then
        SetCursor('UI_MOVE_CURSOR')
    end
end










local function Set_Move_Frame(frame, target, click, notSave, notFuori, isAltKeyDown)
--设置，数据
    frame.moveFrameData={
        target= target and target:GetName() or nil,
        click= click,
        notSave= notSave,
        isAltKeyDown= isAltKeyDown,
    }
--设置，可否到屏幕外
    if notFuori then
        frame:SetClampedToScreen(true)
        if target and not target.moveFrameData then
            target:SetClampedToScreen(true)
        end
    end

--设置，可移动
    frame:SetMovable(true)
    if target and not target.moveFrameData then
        target:SetMovable(true)
    end

--设置，响应事件
    if click=='RightButton' then
        frame:RegisterForDrag("RightButton")
    elseif click=='LeftButton' then
        frame:RegisterForDrag("LeftButton")
    else
        frame:RegisterForDrag("LeftButton", "RightButton")
    end

--开始移动
    frame:HookScript("OnDragStart", function(...)
        Set_OnDragStart(...)
    end)
--停止移动
    frame:HookScript("OnDragStop", function(...)
        Set_OnDragStop(...)
    end)
--设置光标
    frame:HookScript("OnMouseDown", function(...)
       Set_OnMouseDown(...)
    end)
--还原光标
    frame:HookScript("OnMouseUp", function()
        ResetCursor()
    end)
--还原光标
    frame:HookScript("OnLeave", function()
        ResetCursor()
    end)
end























function WoWTools_MoveMixin:Setup(frame, tab)
    tab= tab or {}

    local target= tab.frame
    local name= tab.name or (target and target:GetName()) or (frame and frame:GetName())



    if not frame or not name or frame.moveFrameData then

        if WoWTools_DataMixin.Player.husandro then
            print('移动', frame, name, frame and frame.moveFrameData, '出现错误')
        end
        return

    elseif WoWTools_FrameMixin:IsLocked(target or frame) then
         EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner)
            self:Setup(frame, tab)
            EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
        end)
        return
    end


    local SavePoint= Save().SavePoint or tab.savePoint
    --local moveToScreenFuori= Save().moveToScreenFuori

    local click= tab.click
    local notSave= ((tab.notSave or not SavePoint) and not tab.save) and true or nil
    local notFuori=  tab.notFuori or nil
    local isAltKeyDown= tab.isAltKeyDown or nil

    self:Scale_Size_Button(frame, tab)

    if tab.notMove  then
        return
    end

    do
        Set_Move_Frame(frame, target, click, notSave, notFuori, isAltKeyDown)
    end

    if frame.TitleContainer then
        Set_Move_Frame(frame.TitleContainer, frame, click, notSave, notFuori, isAltKeyDown)
    end

    if not target or not target.moveFrameData then
        return Set_Frame_Point(frame, name)--设置, 移动, 位置
    end
end






function WoWTools_MoveMixin:SetPoint(frame, name)--设置, 移动,
    if not frame then
        return
    end

    name= name or frame:GetName()
    if not name then
        return
    end

    if WoWTools_FrameMixin:IsLocked(frame) then
        EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner)
            self:SetPoint(frame, name)
            EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
        end)
        return true
    else
        return Set_Frame_Point(frame, name)
    end
end