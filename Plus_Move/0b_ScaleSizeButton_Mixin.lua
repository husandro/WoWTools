
local function Save()
    return WoWToolsSave['Plus_Move']
end


local P_UIPanelWindows= {}



--设置大小
local function Set_Frame_Size(self, w, h)
    if not self:IsResizable() then
        self:SetResizable(true)
    end
    self:SetSize(w, h)
end

local function Set_Frame_Scale(self, scale)
    if WoWTools_FrameMixin:IsLocked(self) then
        EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner, info)
            info.frame:SetScale(info.scale)
            EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
        end, nil, {frame=self, scale= scale})
    else
        self:SetScale(scale)
    end
end










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
        Set_Frame_Scale(frame, scale)
    end

    if frame.ResizeButton.setSize then
        local size= Save().size[name]
        if size then
            Set_Frame_Size(frame, size[1], size[2])--设置大小
        end
    end
end



--保存，大小
local function Save_Frame_Size(self)
    if self.sizeStopFunc ~= nil then
        self.sizeStopFunc(self)
    else
        Save().size[self.name]= {self:GetParent():GetSize()}
    end
end



--百分比，设置大小
local function Set_ScalePercent(self, isSu)
    local target= self:GetParent()
    local w,h= target:GetSize()
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

    Set_Frame_Size(target, w, h)--设置大小
    Save_Frame_Size(self)--保存，大小
end


















--锁定框体位置
local function FrameOnShow_SetPoint(self, isSet)
    local name= self.name
    local target= self:GetParent()

    local attributes= P_UIPanelWindows[name] or UIPanelWindows[name]
    if not target:CanChangeAttribute() or not attributes then
        return
    end

    if isSet then
        SetUIPanelAttribute(target, name, true)
        target:SetAttribute("UIPanelLayout-defined", true)

        for name2, att in pairs(attributes) do
            target:SetAttribute("UIPanelLayout-"..name2, att)
        end
        UpdateUIPanelPositions(target)

    else

        target:SetAttribute("UIPanelLayout-defined", nil)
        for name2 in pairs(attributes) do
            target:SetAttribute("UIPanelLayout-"..name2, nil)
        end
    end
end




--锁定框体位置
local function Init_Point_Menu(self, root)
    if not UIPanelWindows then
        return
    end
    local sub
    local name= self.name
    local target= self:GetParent()

--当显示时，锁定框体位置
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '锁定框体位置' or LOCK_FOCUS_FRAME,
    function()
        return Save().UIPanelWindows[name]
    end, function()
        Save().UIPanelWindows[name]= not Save().UIPanelWindows[name] and true or nil

    --禁用，自动设置
        if Save().UIPanelWindows[name] then
            if UIPanelWindows[name] then
                P_UIPanelWindows[name]= UIPanelWindows[name]
                UIPanelWindows[name]= nil
                FrameOnShow_SetPoint(self, false)
            end
    --还原
        elseif P_UIPanelWindows[name] then
            UIPanelWindows[name]= P_UIPanelWindows[name]
            P_UIPanelWindows[name]= nil
            FrameOnShow_SetPoint(self, true)
        end
    end)

    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(name)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '显示时，自定义位置' or  'When show, custom position')
        tooltip:AddLine('|A:NPE_Icon:0:0|aEsc '..(WoWTools_DataMixin.onlyChinese and '无效' or DISABLE))
        local tab= P_UIPanelWindows[name] or UIPanelWindows[name]
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
        (P_UIPanelWindows[name] or UIPanelWindows[name])
        and Save().point[name]
        and target:CanChangeAttribute()
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
    local target= self:GetParent()
    local name= self.name

    local sub, sub2
    if WoWTools_FrameMixin:IsLocked(target) then
        root:CreateTitle(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        return
    end

--缩放
    WoWTools_MenuMixin:Scale(self, root, function()
        return target:GetScale()
    end, function(value)
        if not WoWTools_FrameMixin:IsLocked(target) then
            Save().scale[name]=value
            Set_Frame_Scale(target, value)
        end
    end, function()
        if not WoWTools_FrameMixin:IsLocked(target) then
            Save().scale[name]=nil
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
            return not Save().disabledSize[name]
        end, function()
            Save().disabledSize[name]= not Save().disabledSize[name] and true or nil
        end)
--x
        sub:CreateSpacer()
        sub2=WoWTools_MenuMixin:CreateSlider(sub, {
            getValue=function()
                return math.modf(target:GetWidth())
            end, setValue=function(value)
                if not WoWTools_FrameMixin:IsLocked(target) then
                    target:SetWidth(value)
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
        sub2:SetEnabled(not Save().disabledSize[name])
        sub:CreateSpacer()
        sub:CreateSpacer()
        sub2=WoWTools_MenuMixin:CreateSlider(sub, {
            getValue=function()
                return math.modf(target:GetHeight())
            end, setValue=function()
                if not WoWTools_FrameMixin:IsLocked(target) then
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
        sub2:SetEnabled(not Save().disabledSize[name])
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
            return Save().size[name]
        end, function()
            Save().size[name]=nil
            local target=self:GetParent()
            if not WoWTools_FrameMixin:IsLocked(target) then
                if self.sizeRestFunc then--还原
                    self:sizeRestFunc()
                end
                if not self.notUpdatePositon then
                    WoWTools_Mixin:Call(UpdateUIPanelPositions, target)
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
            return not Save().disabledAlpha[name]
        end, function()
            Save().disabledAlpha[name]= not Save().disabledAlpha[name] and true or nil
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
        (Save().point[name] and '' or '|cff9e9e9e')
        ..(WoWTools_DataMixin.onlyChinese and '清除位置' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_STOPWATCH_PARAM_STOP2, CHOOSE_LOCATION:gsub(CHOOSE , ''))),
    function()
        return Save().point[name]
    end, function()
        local data= self.moveFrameData or {}
        if target.setMoveFrame
            and not data.notSave
            and not WoWTools_FrameMixin:IsLocked(target)
        then
            if P_UIPanelWindows[name] then
                UIPanelWindows[name]= P_UIPanelWindows[name]
                P_UIPanelWindows[name]= nil
            end

            Save().point[name]=nil

            if self.restPointFunc then
                self.restPointFunc(self)
            elseif not self.notUpdatePositon then
                WoWTools_Mixin:Call(UpdateUIPanelPositions, target)
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
        local target= self:GetParent()
        if event=='PLAYER_STARTED_MOVING' then
            target:SetAlpha(Save().alpha)

        elseif event=='PLAYER_STOPPED_MOVING' then
            target:SetAlpha(1)

        end
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

    frame:HookScript('OnEnter', function(self)
        self:SetAlpha(1)
    end)
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
    local target= self:GetParent()
    local name= self.name

    if WoWTools_FrameMixin:IsLocked(target) then
        GameTooltip:AddDoubleLine('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT), WoWTools_TextMixin:GetEnabeleDisable(false))
        GameTooltip:Show()
        return
    elseif target:IsProtected() then
        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT,
            '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '禁止操作' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DISABLE, NPE_CONTROLS))
        )
        GameTooltip:AddLine(' ')
    end

    GameTooltip:AddDoubleLine('|cffff00ff'..name, format('%s %.2f', WoWTools_DataMixin.onlyChinese and '实际' or 'Effective', target:GetEffectiveScale()))
    local parent= target:GetParent()
    if parent then
        GameTooltip:AddDoubleLine(parent:GetName() or 'Parent', format('%.2f', parent:GetScale()))
    end

    local scale
    scale= tonumber(format('%.2f', target:GetScale() or 1))
    scale= ((scale<=0.4 or scale>=2.5) and ' |cnRED_FONT_COLOR:' or ' |cnGREEN_FONT_COLOR:')..scale..' '
    GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE), scale..WoWTools_DataMixin.Icon.left)

    if self.setSize then
        GameTooltip:AddLine(' ')
        local col
        if self.sizeRestTooltipColorFunc then
            col=self.sizeRestTooltipColorFunc(self)
        end
        col=col or (Save().size[name] and '' or '|cff9e9e9e')

        local w, h
        w= math.modf(target:GetWidth())
        w= format('%s%d|r', ((self.minWidth and self.minWidth>=w) or (self.maxWidth and self.maxWidth<=w)) and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:', w)

        h= math.modf(target:GetHeight())
        h= format('%s%d|r', ((self.minHeight and self.minHeight>=h) or (self.maxHeight and self.maxHeight<=h)) and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:', h)

        GameTooltip:AddDoubleLine(
            col..(WoWTools_DataMixin.onlyChinese and '尺寸' or HUD_EDIT_MODE_SETTING_ARCHAEOLOGY_BAR_SIZE)..format(' %s |cffffffffx|r %s', w, h),
                WoWTools_TextMixin:GetEnabeleDisable(not Save().disabledSize[name])..WoWTools_DataMixin.Icon.right
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
            Save().disabledAlpha[name] and WoWTools_TextMixin:GetEnabeleDisable(false) or ('|cnGREEN_FONT_COLOR:'..Save().alpha)
        )
    end

    GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.mid)
    GameTooltip:Show()
end










local function Set_Enter(btn, target)
    if btn.alpha then
        btn:SetAlpha(btn.alpha)
        if btn.alpha==0 then
            target:HookScript('OnEnter', function(self)
                self.ResizeButton:SetAlpha(1)
            end)
            target:HookScript('OnLeave', function(self)
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
        SetCursor('Interface\\CURSOR\\Crosshair\\UI-Cursor-SizeRight')
        self:SetAlpha(1)
    end)
end








local function Set_OnMouseUp(self)
    local d= self.isActiveButton
    local target= self:GetParent()

    self:SetScript("OnUpdate", nil)

    if d=='RightButton' and self.setSize then--保存，大小 d=='RightButton' and
        local continueResizeStop = true
        if target.onResizeStopCallback then
            continueResizeStop = target.onResizeStopCallback(self)
        end
        if continueResizeStop then
            target:StopMovingOrSizing()
        end
        Save_Frame_Size(self)--保存，大小

    elseif d=='LeftButton' then--保存，缩放
        if self.scaleStoppedFunc then
            self.scaleStoppedFunc(self)
        end
        Save().scale[self.name]= target:GetScale()
    end

    self.isActiveButton= nil
end






local function Set_OnMouseDown(self, d)
    local target= self:GetParent()

    if self.isActiveButton
        or WoWTools_FrameMixin:IsLocked(target)
        or IsModifierKeyDown()
    then
        return
    end

    self.isActiveButton = d


    if d=='LeftButton' then
        self.SOS.left, self.SOS.top = target:GetLeft(), target:GetTop()
        self.SOS.scale = target:GetScale()
        self.SOS.x, self.SOS.y = self.SOS.left, self.SOS.top-(UIParent:GetHeight()/self.SOS.scale)
        self.SOS.EFscale = target:GetEffectiveScale()
        self.SOS.dist = GetScaleDistance(self.SOS)
        self:SetScript("OnUpdate", function()
            if WoWTools_FrameMixin:IsLocked(self) then
                self:SetScript("OnUpdate", nil)
                self.isActiveButton=nil
                return
            end

            local SOS= self.SOS
            local distance= GetScaleDistance(SOS)
            local scale2 = distance/SOS.dist*SOS.scale
            if scale2 < 0.4 then
                scale2 = 0.4
            elseif scale2 > 2.5 then
                scale2 = 2.5
            end

            scale2= tonumber(format('%.2f', scale2))
            target:SetScale(scale2)

            local s = SOS.scale/target:GetScale()
            local x = SOS.x*s
            local y = SOS.y*s

            target:ClearAllPoints()
            target:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)

            Set_Tooltip(self)

            if self.scaleUpdateFunc then
                self.scaleUpdateFunc(self)
            end
        end)

    elseif d=='RightButton' and self.setSize and not Save().disabledSize[self.name] then
--开始，设置，大小

        local continueResizeStart = true
        if target.onResizeStartCallback then
            continueResizeStart = target.onResizeStartCallback(self)
        end
        if continueResizeStart then
            target:SetResizable(true)
            target:StartSizing("BOTTOMRIGHT", true)
        end
        self:SetScript('OnUpdate', function()
            if WoWTools_FrameMixin:IsLocked(target) then
                self:SetScript("OnUpdate", nil)
                self.isActiveButton=nil
                target:StopMovingOrSizing()

            elseif self.sizeUpdateFunc then
                self.sizeUpdateFunc(self)
            end
            Set_Tooltip(self)
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
                Set_Frame_Size(tab.target, tab.size[1], tab.size[2])--设置大小
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
            Set_Frame_Size(target, size[1], size[2])--设置大小
        end
        if initFunc then
            initFunc(btn)
        end
        if WoWTools_DataMixin.Player.husandro then
            print(WoWTools_MoveMixin.addName, issecure(), target:GetName(), '|cnGREEN_FONT_COLOR:执行')
        end
    end
end












function WoWTools_MoveMixin:Scale_Size_Button(frame, tab)
    local name= frame:GetName()
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
    btn:SetSize(18, 18)


    if setResizeButtonPoint then
        btn:SetPoint(setResizeButtonPoint[1] or 'BOTTOMRIGHT', setResizeButtonPoint[2] or frame, setResizeButtonPoint[3] or 'BOTTOMRIGHT', setResizeButtonPoint[4] or 0, setResizeButtonPoint[5] or 0)
    else
        btn:SetPoint('BOTTOMRIGHT', frame)--m, 6,-6)
    end


    frame.ResizeButton= btn

    --btn.targetFrame= frame
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
    Set_Enter(btn, frame)

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
        Set_Frame_Scale(frame, scale)
    end

    btn:SetScript("OnMouseUp", function(s, d)
        Set_OnMouseUp(s, d)
    end)
    btn:SetScript("OnMouseDown",function(s, d)
        Set_OnMouseDown(s, d)
    end)
    btn:SetScript('OnMouseWheel', function(s)
        MenuUtil.CreateContextMenu(s, function(...)
            Init_Menu(...)
        end)
        Set_Tooltip(s)
    end)
    frame:HookScript('OnHide', function(s)
        local b= s.ResizeButton
        local d= b and b.isActiveButton
        if d then
            b:SetScript("OnUpdate", nil)
            b.isActiveButton= nil
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