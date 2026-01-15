local function Save()
    return WoWToolsSave['Plus_Move'] or {}
end

WoWTools_MoveMixin={
    Events={},
    Frames={},
    Save=Save
}












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
        EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner)
            Set_Frame_Point(self, name)
            EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
        end)

    else
        frame:ClearAllPoints()
        frame:SetPoint(p[1], UIParent, p[3], p[4], p[5])
    end

    return true
end




local function Set_OnDragStart(self, d)
    local data= self.moveFrameData

    local frame
    if data then
        frame= _G[data.target] or self
    end

    if not frame
        or not frame:IsMovable()
        or (data.click and d~=data.click)
        or (data.isAltKeyDown and not IsAltKeyDown())
        or WoWTools_FrameMixin:IsLocked(frame)
    then
        return
    end

--保护
    if frame:IsProtected() then
        frame._moveOwnerID= EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_DISABLED", function(owner)
            ResetCursor()
            frame:StopMovingOrSizing()
            frame._moveOwnerID= nil
            EventRegistry:UnregisterCallback('PLAYER_REGEN_DISABLED', owner)
        end)
    end

    frame:StartMoving()
end


local function Set_OnDragStop(self)
    local data= self.moveFrameData
    local frame= _G[data.target] or self
    local name= frame:GetName()

    ResetCursor()

--保护，清除
    if frame._moveOwnerID then
        EventRegistry:UnregisterCallback('PLAYER_REGEN_DISABLED', frame._moveOwnerID)
        frame._moveOwnerID= nil
    end

    if WoWTools_FrameMixin:IsLocked(frame) then
        return
    end

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










local function Set_Move_Frame(frame, target, click, notSave, isAltKeyDown)

    --if frame:IsMovable() and WoWTools_DataMixin.Player.husandro then
      --  print('移动', '|cnWARNING_FONT_COLOR:已有别的插件设置|r', frame:GetName(), frame.moveFrameData)

--设置，数据
    frame.moveFrameData={
        target= target and target:GetName() or nil,
        click= click,
        notSave= notSave,
        isAltKeyDown= isAltKeyDown,
    }

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
    frame:SetScript("OnDragStart", function(...)
        Set_OnDragStart(...)
    end)
--停止移动
    frame:SetScript("OnDragStop", function(...)
        Set_OnDragStop(...)
    end)
--设置光标
    frame:HookScript("OnMouseDown", function(...)
       Set_OnMouseDown(...)
    end)
--还原光标
   frame:HookScript("OnMouseUp", ResetCursor)
 --[[还原光标
    frame:HookScript("OnLeave", function()
        ResetCursor()
    end)]]
end























function WoWTools_MoveMixin:Setup(frame, tab)
    tab= tab or {}

    local target= tab.frame
    local name= tab.name or (target and target:GetName()) or (frame and frame:GetName())


    if not frame or not name or frame.moveFrameData then-- or frame:IsMovable() then
        if WoWTools_DataMixin.Player.husandro then
            print('移动', frame, name, frame and frame.moveFrameData, '出现错误')
        else
            return
        end

    elseif WoWTools_FrameMixin:IsLocked(target or frame) then
         EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner)
            self:Setup(frame, tab)
            EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
        end)
        return
    end


    local SavePoint= Save().SavePoint or tab.savePoint
    --local moveToScreenFuori= Save().moveToScreenFuori

    local click= tab.click--RightButton LeftButton nil
    local notSave= ((tab.notSave or not SavePoint) and not tab.save) and true or nil
    local isAltKeyDown= tab.isAltKeyDown or nil

    self:Scale_Size_Button(frame, tab)

    if tab.notMove  then
        return
    end

    do
        Set_Move_Frame(frame, target, click, notSave, isAltKeyDown)
    end

    if frame.TitleContainer then
        Set_Move_Frame(frame.TitleContainer, target or frame, click, notSave, isAltKeyDown)
--会点不中，关闭按钮
        if frame.CloseButton then
            frame.CloseButton:SetFrameLevel(frame.TitleContainer:GetFrameLevel()+1)
        end
    end
end



    --[[if not target or not target.moveFrameData then
        return Set_Frame_Point(frame, name)--设置, 移动, 位置
    end]]






function WoWTools_MoveMixin:SetPoint(frame, name)--设置, 移动,
    name= name or (frame and frame:GetName())
    if not name or not frame then
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