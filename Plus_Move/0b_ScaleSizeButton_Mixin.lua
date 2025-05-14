
local function Save()
    return WoWToolsSave['Plus_Move']
end


local P_UIPanelWindows= {}






function WoWTools_MoveMixin:Set_SizeScale(frame)
    local name= frame and frame:GetName()
    if not name
        or WoWTools_FrameMixin:IsLocked(frame)
        or not frame.ResizeButton
    then
        return
    end

    local scale= Save().scale[name]
    if scale then
        frame:SetScale(scale)
    end

    if frame.ResizeButton.setSize then
        local size= Save().size[name]
        if size then
            frame:SetSize(size[1], size[2])
        end
    end
end



--保存，大小
local function Save_Frame_Size(self)
    if self.sizeStopFunc ~= nil then
        self.sizeStopFunc(self)
    else
        Save().size[self.name]= {self.targetFrame:GetSize()}
    end
end



--百分比，设置大小
local function Set_ScalePercent(self, isSu)
    local w,h= self.targetFrame:GetSize()
    if isSu then
        w= w+ w* 0.1
        h= h+ h* 0.1
    else
        w= w- w* 0.1
        h= h- h* 0.1
    end
    local maxW= self.maxWidth or math.modf(UIParent:GetWidth())
    local maxH= self.maxHeight or math.modf(UIParent:GetHeight())

    if
        w<self.minWidth
        or h<self.minHeight
        or w>maxW
        or h>maxH
    then
        return
    end

    self.targetFrame:SetSize(w,h)

    Save_Frame_Size(self)--保存，大小
end


















--锁定框体位置

local function FrameOnShow_SetPoint(self, isSet)
    local attributes= P_UIPanelWindows[self.name] or UIPanelWindows[self.name]
    if not self.targetFrame:CanChangeAttribute() or not attributes then
        return
    end

    if isSet then
        SetUIPanelAttribute(self.targetFrame, self.name, true)
        self.targetFrame:SetAttribute("UIPanelLayout-defined", true)
        for name, att in pairs(attributes) do
            self.targetFrame:SetAttribute("UIPanelLayout-"..name, att)
        end
        UpdateUIPanelPositions(self.targetFrame)
    else

        self.targetFrame:SetAttribute("UIPanelLayout-defined", nil)
        for name in pairs(attributes) do
            self.targetFrame:SetAttribute("UIPanelLayout-"..name, nil)
        end
    end
end




--锁定框体位置
local function Init_Point_Menu(self, root)
    if not UIPanelWindows then
        return
    end
    local sub


--当显示时，锁定框体位置

    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '锁定框体位置' or LOCK_FOCUS_FRAME,
    function()
        return Save().UIPanelWindows[self.name]
    end, function()
        Save().UIPanelWindows[self.name]= not Save().UIPanelWindows[self.name] and true or nil

    --禁用，自动设置
        if Save().UIPanelWindows[self.name] then
            if UIPanelWindows[self.name] then
                P_UIPanelWindows[self.name]= UIPanelWindows[self.name]
                UIPanelWindows[self.name]= nil
                FrameOnShow_SetPoint(self, false)
            end
    --还原
        elseif P_UIPanelWindows[self.name] then
            UIPanelWindows[self.name]= P_UIPanelWindows[self.name]
            P_UIPanelWindows[self.name]= nil
            FrameOnShow_SetPoint(self, true)
        end
    end)

    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(self.name)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '显示时，自定义位置' or  'When show, custom position')
        tooltip:AddLine('|A:NPE_Icon:0:0|aEsc '..(WoWTools_DataMixin.onlyChinese and '无效' or DISABLE))
        local tab= P_UIPanelWindows[self.name] or UIPanelWindows[self.name]
        if tab then
            tooltip:AddLine(' ')
            local t
            for name, value in pairs(tab) do
                t=type(value)
                tooltip:AddDoubleLine(name,
                    (t=='string' or t=='number') and value
                    or (value==true and 'true') or (value==false and 'false')
                    or t
                )
            end
        end
    end)
    sub:SetEnabled(
        (P_UIPanelWindows[self.name] or UIPanelWindows[self.name])
        and Save().point[self.name]
        and self.targetFrame:CanChangeAttribute()
    )

--重新加载UI
    WoWTools_MenuMixin:Reload(sub)
    sub:CreateDivider()
    sub:CreateTitle(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)

--列表
    root:CreateDivider()
    local index=0
    for name in pairs(Save().UIPanelWindows) do
        index= index+1
        sub=root:CreateCheckbox(
            (index<10 and ' ' or '')..index..') '..name,
        function(data)
            return Save().UIPanelWindows[data.name]
        end, function(data)
            Save().UIPanelWindows[data.name]= not Save().UIPanelWindows[data.name] and true or nil
            FrameOnShow_SetPoint(self, Save().UIPanelWindows[data.name])
        end, {name=name})
        sub:SetTooltip(function(tooltip, desc)
            tooltip:AddLine(desc.data.name)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2 )
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end)
    end

--全部清除
    if index>0 then
        root:CreateDivider()
        root:CreateButton(
            '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
        function()
            StaticPopup_Show('WoWTools_OK',
                WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
            nil,
            {SetValue=function()
                Save().UIPanelWindows={}
            end})
            return MenuResponse.Open
        end)
    end

--SetScrollMod
    WoWTools_MenuMixin:SetScrollMode(root)
end


























--菜单
local function Init_Menu(self, root)
    root:SetTag('WOWTOOLS_RESIZEBUTTON_MENU')

    local sub, sub2
    if WoWTools_FrameMixin:IsLocked(self.targetFrame) then
        root:CreateTitle(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        return
    end

--缩放
    WoWTools_MenuMixin:Scale(self, root, function()
        return self.targetFrame:GetScale()
    end, function(value)
        if not WoWTools_FrameMixin:IsLocked(self.targetFrame) then
            Save().scale[self.name]=value
            self.targetFrame:SetScale(value)
        end
    end, function()
        if not WoWTools_FrameMixin:IsLocked(self.targetFrame) then
            Save().scale[self.name]=nil
            if self.scaleRestFunc then
                self.scaleRestFunc(self)
            end
        end
    end)

--尺寸
    if self.setSize then
        sub=root:CreateCheckbox(
            WoWTools_DataMixin.onlyChinese and '尺寸' or HUD_EDIT_MODE_SETTING_ARCHAEOLOGY_BAR_SIZE,
        function()
            return not Save().disabledSize[self.name]
        end, function()
            Save().disabledSize[self.name]= not Save().disabledSize[self.name] and true or nil
        end)
--x
        sub:CreateSpacer()
        sub2=WoWTools_MenuMixin:CreateSlider(sub, {
            getValue=function()
                return math.modf(self.targetFrame:GetWidth())
            end, setValue=function(value)
                if not WoWTools_FrameMixin:IsLocked(self.targetFrame) then
                    self.targetFrame:SetWidth(value)
                    Save_Frame_Size(self)--保存，大小
                    if self.sizeUpdateFunc then
                        self:sizeUpdateFunc()
                    end
                    if self.sizeStopFunc then
                        self:sizeStopFunc()
                    end
                end
            end,
            name='x',
            minValue=self.minWidth,
            maxValue=self.maxWidth or math.modf(UIParent:GetWidth()),
            step=5,
        })
        sub2:SetEnabled(not Save().disabledSize[self.name])
        sub:CreateSpacer()
        sub:CreateSpacer()
        sub2=WoWTools_MenuMixin:CreateSlider(sub, {
            getValue=function()
                return math.modf(self.targetFrame:GetHeight())
            end, setValue=function()
                if not WoWTools_FrameMixin:IsLocked(self.targetFrame) then
                    Save_Frame_Size(self)--保存，大小
                    if self.sizeUpdateFunc then
                        self:sizeUpdateFunc()
                    end
                    if self.sizeStopFunc then
                        self:sizeStopFunc()
                    end
                end
            end,
            name='y',
            minValue= self.minHeight,
            maxValue= self.maxHeight or math.modf(UIParent:GetHeight()),
            step=5,
        })
        sub2:SetEnabled(not Save().disabledSize[self.name])
        sub:CreateSpacer()
        sub:CreateButton(
            '+0.1%',
        function()
            Set_ScalePercent(self, true)
            return MenuResponse.Refresh
        end)
        sub:CreateButton(
            '-0.1%',
        function()
            Set_ScalePercent(self, false)
            return MenuResponse.Refresh
        end)
--重置, 尺寸
        sub:CreateRadio(
            WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
        function()
            return Save().size[self.name]
        end, function()
            Save().size[self.name]=nil
            if not WoWTools_FrameMixin:IsLocked(self.targetFrame) then
                if self.sizeRestFunc then--还原
                    self:sizeRestFunc()
                end
                if not self.notUpdatePositon then
                    WoWTools_Mixin:Call(UpdateUIPanelPositions, self.targetFrame)
                end
            end
            return MenuResponse.Refresh
        end)
    end

--改变透明度
    if self.set_move_event then
        sub=root:CreateCheckbox(
            (WoWTools_DataMixin.onlyChinese and '改变透明度' or CHANGE_OPACITY)..' '..(Save().alpha or 1),
        function()
            return not Save().disabledAlpha[self.name]
        end, function()
            Save().disabledAlpha[self.name]= not Save().disabledAlpha[self.name] and true or nil
            self:set_move_event()
        end)
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '移动时' or CAMERA_SMARTER)
        end)

--设置
        WoWTools_MenuMixin:OpenOptions(sub, {category=WoWTools_MoveMixin.Category, name=WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS})
    end

--清除，位置，数据

    root:CreateDivider()
    sub=root:CreateCheckbox(
        (Save().point[self.name] and '' or '|cff9e9e9e')
        ..(WoWTools_DataMixin.onlyChinese and '清除位置' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_STOPWATCH_PARAM_STOP2, CHOOSE_LOCATION:gsub(CHOOSE , ''))),
    function()
        return Save().point[self.name]
    end, function()
        if self.targetFrame.setMoveFrame
            and not self.targetFrame.notSave
            and not WoWTools_FrameMixin:IsLocked(self.targetFrame)
        then

            if P_UIPanelWindows[self.name] then
                UIPanelWindows[self.name]= P_UIPanelWindows[self.name]
                P_UIPanelWindows[self.name]= nil
            end

            Save().point[self.name]=nil

            if self.restPointFunc then
                self.restPointFunc(self)
            elseif not self.notUpdatePositon then
                WoWTools_Mixin:Call(UpdateUIPanelPositions, self.targetFrame)
            end

        end
        return MenuResponse.Refresh
    end)




--锁定框体位置
    Init_Point_Menu(self, sub)




--打开，选项
    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {category=WoWTools_MoveMixin.Category, name=WoWTools_MoveMixin.addName})
end



















--Frame 移动时，设置透明度
local function Set_Move_Alpha(frame)
    local name= frame:GetName()
    if not frame or Save().notMoveAlpha or not name then
        return
    end
    local btn= frame.ResizeButton
    if not btn then
        btn= CreateFrame("Frame", nil, frame)
        btn.name= name
        frame.ResizeButton= btn
    end
    btn:SetScript('OnEvent', function(self, event)
        local target= self.targetFrame or self:GetParent()
        if event=='PLAYER_STARTED_MOVING' then
            target:SetAlpha(Save().alpha)

        elseif event=='PLAYER_STOPPED_MOVING' then
            target:SetAlpha(1)

        end
    end)
    frame:HookScript('OnEnter', function(self)
        self:SetAlpha(1)
    end)
    function btn:set_move_event()
        if Save().disabledAlpha[self.name] or Save().alpha==1 then
            self:UnregisterAllEvents()
            self:SetScript('OnShow', nil)
            self:SetScript('OnHide', nil)
            self:GetParent():SetAlpha(1)
        else
            if self:IsVisible() then
                self:RegisterEvent('PLAYER_STARTED_MOVING')
                self:RegisterEvent('PLAYER_STOPPED_MOVING')
            end
            self:SetScript('OnShow', function(f)
                f:RegisterEvent('PLAYER_STARTED_MOVING')
                f:RegisterEvent('PLAYER_STOPPED_MOVING')
            end)
            self:SetScript('OnHide', function(f)
                f:UnregisterAllEvents()
                f:GetParent():SetAlpha(1)
            end)
        end
    end
    btn:set_move_event()
end











local function GetScaleDistance(SOS) -- distance from cursor to TopLeft :)
	local left, top = SOS.left, SOS.top
	local scale = SOS.EFscale
	local x, y = GetCursorPosition()
	x = x/scale - left
	y = top - y/scale
	return sqrt(x*x+y*y)
end














local function Set_Tooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()

    if WoWTools_FrameMixin:IsLocked(self.targetFrame) then
        GameTooltip:AddDoubleLine('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT), WoWTools_TextMixin:GetEnabeleDisable(false))
        GameTooltip:Show()
        return
    elseif self.targetFrame:IsProtected() then
        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT,
            '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '禁止操作' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DISABLE, NPE_CONTROLS))
        )
        GameTooltip:AddLine(' ')
    end

    GameTooltip:AddDoubleLine('|cffff00ff'..self.name, format('%s %.2f', WoWTools_DataMixin.onlyChinese and '实际' or 'Effective', self.targetFrame:GetEffectiveScale()))
    local parent= self.targetFrame:GetParent()
    if parent then
        GameTooltip:AddDoubleLine(parent:GetName() or 'Parent', format('%.2f', parent:GetScale()))
    end

    local scale
    scale= tonumber(format('%.2f', self.targetFrame:GetScale() or 1))
    scale= ((scale<=0.4 or scale>=2.5) and ' |cnRED_FONT_COLOR:' or ' |cnGREEN_FONT_COLOR:')..scale..' '
    GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE), scale..WoWTools_DataMixin.Icon.left)

    if self.setSize then
        GameTooltip:AddLine(' ')
        local col
        if self.sizeRestTooltipColorFunc then
            col=self.sizeRestTooltipColorFunc(self)
        end
        col=col or (Save().size[self.name] and '' or '|cff9e9e9e')

        local w, h
        w= math.modf(self.targetFrame:GetWidth())
        w= format('%s%d|r', ((self.minWidth and self.minWidth>=w) or (self.maxWidth and self.maxWidth<=w)) and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:', w)

        h= math.modf(self.targetFrame:GetHeight())
        h= format('%s%d|r', ((self.minHeight and self.minHeight>=h) or (self.maxHeight and self.maxHeight<=h)) and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:', h)

        GameTooltip:AddDoubleLine(
            col..(WoWTools_DataMixin.onlyChinese and '尺寸' or HUD_EDIT_MODE_SETTING_ARCHAEOLOGY_BAR_SIZE)..format(' %s |cffffffffx|r %s', w, h),
                WoWTools_TextMixin:GetEnabeleDisable(not Save().disabledSize[self.name])..WoWTools_DataMixin.Icon.right
        )

        if self.sizeTooltip then
            if type(self.sizeTooltip)=='function' then
                self:sizeTooltip()
            else
                GameTooltip:AddLine(self.sizeTooltip)
            end
        end
    end

    GameTooltip:AddLine(' ')
    if self.set_move_event then--Frame 移动时，设置透明度
        GameTooltip:AddDoubleLine(
            (WoWTools_DataMixin.onlyChinese and '移动时透明度 ' or MAP_FADE_TEXT:gsub(WORLD_MAP, 'Frame')),
            Save().disabledAlpha[self.name] and WoWTools_TextMixin:GetEnabeleDisable(false) or ('|cnGREEN_FONT_COLOR:'..Save().alpha)
        )
    end

    GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.mid)
    GameTooltip:Show()
end










local function Set_Enter(btn)
    if btn.alpha then
        btn:SetAlpha(btn.alpha)
        if btn.alpha==0 then
            btn.targetFrame:HookScript('OnEnter', function(self)
                self.ResizeButton:SetAlpha(1)
            end)
            btn.targetFrame:HookScript('OnLeave', function(self)
                self.ResizeButton:SetAlpha(0)
            end)
        end
    end

    btn:SetScript('OnLeave', function(self)
        GameTooltip_Hide()
        ResetCursor()
        btn:SetAlpha(self.alpha or 0.5)
    end)
    btn:SetScript('OnEnter', function(self)
        Set_Tooltip(self)
        --SetCursor("UI_RESIZE_CURSOR")
        SetCursor('Interface\\CURSOR\\Crosshair\\UI-Cursor-SizeRight')
        --SetCursor('UI_RESIZE_CURSOR')
        self:SetAlpha(1)--and 1 or 0.5)
    end)
end








local function Set_OnMouseUp(self, d)
    self:SetScript("OnUpdate", nil)
    self.isActiveButton= nil

    --[[if WoWTools_FrameMixin:IsLocked(self.targetFrame) then
        return
    end]]

    if self.setSize then--保存，大小 d=='RightButton' and
        local continueResizeStop = true
        if self.targetFrame.onResizeStopCallback then
            continueResizeStop = self.targetFrame.onResizeStopCallback(self)
        end
        if continueResizeStop then
            self.targetFrame:StopMovingOrSizing()
        end
        Save_Frame_Size(self)--保存，大小

    elseif d=='LeftButton' then--保存，缩放
        if self.scaleStoppedFunc then
            self.scaleStoppedFunc(self)
        else
            Save().scale[self.name]= self.targetFrame:GetScale()
        end
    end
    --self:SetScript("OnUpdate", nil)
end






local function Set_OnMouseDown(self, d)
    if self.isActiveButton or WoWTools_FrameMixin:IsLocked(self.targetFrame) then
        return
    end

    if d=='LeftButton' then
        self.isActiveButton= d
        local target= self.targetFrame
        self.SOS.left, self.SOS.top = target:GetLeft(), target:GetTop()
        self.SOS.scale = target:GetScale()
        self.SOS.x, self.SOS.y = self.SOS.left, self.SOS.top-(UIParent:GetHeight()/self.SOS.scale)
        self.SOS.EFscale = target:GetEffectiveScale()
        self.SOS.dist = GetScaleDistance(self.SOS)
        self:SetScript("OnUpdate", function(frame2)
            if WoWTools_FrameMixin:IsLocked(frame2) then
                self:SetScript("OnUpdate", nil)
                return
            end
            local SOS= frame2.SOS
            local distance= GetScaleDistance(SOS)
            local scale2 = distance/SOS.dist*SOS.scale
            if scale2 < 0.4 then
                scale2 = 0.4
            elseif scale2 > 2.5 then
                scale2 = 2.5
            end
            scale2= tonumber(format('%.2f', scale2))
            local target2= frame2.targetFrame
            target2:SetScale(scale2)

            local s = SOS.scale/target2:GetScale()
            local x = SOS.x*s
            local y = SOS.y*s
            target2:ClearAllPoints()
            target2:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
            Set_Tooltip(frame2)
            if frame2.scaleUpdateFunc then
                frame2.scaleUpdateFunc(frame2)
            end
        end)

    elseif d=='RightButton' and self.setSize and not Save().disabledSize[self.name] and not IsModifierKeyDown() then
--开始，设置，大小
        self.isActiveButton = d
        local continueResizeStart = true
        if self.targetFrame.onResizeStartCallback then
            continueResizeStart = self.targetFrame.onResizeStartCallback(self)
        end
        if continueResizeStart then
            self.targetFrame:SetResizable(true)
            self.targetFrame:StartSizing("BOTTOMRIGHT", true)
        end
        self:SetScript('OnUpdate', function(f)
            if WoWTools_FrameMixin:IsLocked(f.targetFrame) then
                self:SetScript("OnUpdate", nil)
                self.targetFrame:StopMovingOrSizing()

            elseif f.sizeUpdateFunc then
                f.sizeUpdateFunc(f)

            end
            Set_Tooltip(f)
        end)
    end



    Set_Tooltip(self)
end









local function Set_OnShow(self)
    if WoWTools_FrameMixin:IsLocked(self) then
        EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner, frame)
            WoWTools_MoveMixin:Set_SizeScale(frame)
            EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
        end, nil, self)
    else
        WoWTools_MoveMixin:Set_SizeScale(self)
    end
end




local function Set_Init_Frame(btn, target, size, initFunc)
    if WoWTools_FrameMixin:IsLocked(target) then--not InCombatLockdown() or not sel:IsProtected() 
        EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner, tab)--btn2, target2, size2, initFunc2)
            if tab.size then
                tab.target:SetSize(tab.size[1], tab.size[2])
            end
            if initFunc then
                initFunc(btn)
            end
            EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
        end, nil, {
            btn=btn,
            target=target,
            size=size,
            initFunc=initFunc
        })
        if WoWTools_DataMixin.Player.husandro then
            print(WoWTools_MoveMixin.addName, issecure(), target:GetName(), '|cnRED_FONT_COLOR:不能执行')
        end
    else
        if size then
            target:SetSize(size[1], size[2])
        end
        if initFunc then
            initFunc(btn)
        end
        if WoWTools_DataMixin.Player.husandro then
            print(WoWTools_MoveMixin.addName, issecure(), target:GetName(), '|cnGREEN_FONT_COLOR:执行')
        end
    end
end












function WoWTools_MoveMixin:ScaleSize(frame, tab)
    local name= tab.name or frame:GetName()
    tab= tab or {}

    if not name
        --or (Save().disabledZoom and not tab.needSize)
        or tab.notZoom
        or frame.ResizeButton
        or tab.frame
        or _G['WoWToolsResizeButton'..name]

    then
        return
    end

    local setResizeButtonPoint= tab.setResizeButtonPoint--设置，按钮，位置
    local setSize= tab.setSize
    local onShowFunc= tab.onShowFunc-- true, function

    local minW= tab.minW or 115--最小窗口， 宽
    local minH= tab.minH or 115--最小窗口，高
    local maxW= tab.maxW--最大，可无
    local maxH= tab.maxH--最大，可无

    local rotationDegrees= tab.rotationDegrees--旋转度数
    local initFunc= tab.initFunc--初始


    local btn= CreateFrame('Button', 'WoWToolsResizeButton'..name, frame, 'PanelResizeButtonTemplate')--SharedUIPanelTemplates.lua
    btn:SetFrameStrata('DIALOG')
    btn:SetFrameLevel(frame:GetFrameLevel()+7)
    btn:SetSize(16, 16)


    if setResizeButtonPoint then
        btn:SetPoint(setResizeButtonPoint[1] or 'BOTTOMRIGHT', setResizeButtonPoint[2] or frame, setResizeButtonPoint[3] or 'BOTTOMRIGHT', setResizeButtonPoint[4] or 0, setResizeButtonPoint[5] or 0)
    else
        btn:SetPoint('BOTTOMRIGHT', frame)--m, 6,-6)
    end


    frame.ResizeButton= btn

    btn.targetFrame= btn.targetFrame or frame
    btn.name= name

--设置缩放
    btn.scaleStoppedFunc= tab.scaleStoppedFunc--保存，缩放内容
    btn.scaleUpdateFunc= tab.scaleUpdateFunc
    btn.scaleRestFunc= tab.scaleRestFunc--清除，数据
    btn.restPointFunc= tab.restPointFunc--还原，（清除，位置，数据）
    btn.alpha= tab.alpha--设置透明度为0，移到frame设置为1
    btn.setSize= setSize --and not disabledSize--是否有，设置大小，功能    
    --btn.notInCombat= tab.notInCombat--战斗中，禁止操作
    btn.notUpdatePositon= tab.notUpdatePositon
    btn.notMoveAlpha= tab.notMoveAlpha--是否设置，移动时，设置透明度

    btn.sizeRestFunc= tab.sizeRestFunc--清除，数据
    btn.sizeUpdateFunc= tab.sizeUpdateFunc--setSize时, OnUpdate
    btn.sizeRestTooltipColorFunc= tab.sizeRestTooltipColorFunc--重置，提示SIZE，颜色
    btn.sizeStopFunc= tab.sizeStopFunc--保存，大小，内容
    btn.sizeTooltip= tab.sizeTooltip
    btn.alpha= tab.alpha

    --btn.hideButton= tab.hideButton--隐藏按钮，移过时，才显示

    if btn.sizeRestFunc then
        frame:SetResizable(true)
        btn:Init(frame, minW, minH, maxW , maxH, rotationDegrees)
        --[[
            self.targetFrame = targetFrame
            self.minWidth = minWidth
            self.minHeight = minHeight
            self.maxWidth = maxWidth
            self.maxHeight = maxHeight
        ]]

        local size= Save().size[name]
        if size or initFunc then
            Set_Init_Frame(btn, frame, size, initFunc)
        end
    end

    WoWTools_ColorMixin:Setup(btn, {type='Button', alpha=1})--设置颜色

    btn:SetClampedToScreen(true)
    Set_Enter(btn)

    btn.SOS = { --Scaler Original State
        dist = 0,
        x = 0,
        y = 0,
        left = 0,
        top = 0,
        scale = 1,
    }

    local scale= Save().scale[name]
    if scale and scale~=1 then
        if WoWTools_FrameMixin:IsLocked(frame) then
            EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner, info)
                info.frame:SetScale(info.scale)
                EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
            end, nil, {frame=frame, scale= scale})
        else
            frame:SetScale(scale)
        end
    end

    btn:SetScript("OnMouseUp", function(s, d)
        Set_OnMouseUp(s, d)
    end)
    btn:SetScript("OnMouseDown",function(s, d)
        s.isOnMouseDown=true
        Set_OnMouseDown(s, d)
    end)
    btn:SetScript('OnMouseWheel', function(s)
        MenuUtil.CreateContextMenu(s, Init_Menu)
        Set_Tooltip(s)
    end)
    btn.targetFrame:HookScript('OnHide', function(s)
        if s.ResizeButton.isActiveButton then
            Set_OnMouseUp(s.ResizeButton, s.ResizeButton.isActiveButton)
        end
    end)

    if onShowFunc then
        if onShowFunc==true then
            frame:HookScript('OnShow', function(s)
                Set_OnShow(s)
            end)
        else
            frame:HookScript('OnShow', onShowFunc)
        end
    end

    if not btn.notMoveAlpha then--移动时，设置透明度
        Set_Move_Alpha(frame)
    end

--当显示时，锁定框体位置
    if Save().UIPanelWindows[name] and UIPanelWindows[name] then
        P_UIPanelWindows[name]= UIPanelWindows[name]
        UIPanelWindows[name]= nil
        FrameOnShow_SetPoint(btn, false)
    end
end








function WoWTools_MoveMixin:MoveAlpha(frame)
    Set_Move_Alpha(frame)
end