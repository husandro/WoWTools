--[[添加 ResizeButton 按钮
    FriendsFrame.IgnoreListWindow:ClearAllPoints()
    FriendsFrame.IgnoreListWindow:SetPoint('TOPLEFT', FriendsFrame, 'TOPRIGHT')
    if Save().IgnoreListWindowHeight then
        FriendsFrame.IgnoreListWindow:SetHeight(Save().IgnoreListWindowHeight)
    end
    FriendsFrame.IgnoreListWindow:SetResizable(true)
    FriendsFrame.IgnoreListWindow:SetResizeBounds(273, 104)
    FriendsFrame.IgnoreListWindow.ResizeButton= CreateFrame('Button', nil, FriendsFrame.IgnoreListWindow, 'WoWToolsButtonTemplate')
    FriendsFrame.IgnoreListWindow.ResizeButton:SetSize(32, 12)
    FriendsFrame.IgnoreListWindow.ResizeButton:SetNormalAtlas('lootroll-resizehandle')

 
    FriendsFrame.IgnoreListWindow.ResizeButton:SetPoint('TOP', FriendsFrame.IgnoreListWindow, 'BOTTOM', 0, 3)
    FriendsFrame.IgnoreListWindow.ResizeButton:SetScript("OnMouseDown", function(btn)
		local alwaysStartFromMouse = true;
		btn:GetParent():StartSizing("BOTTOM", alwaysStartFromMouse);
	end)
	FriendsFrame.IgnoreListWindow.ResizeButton:SetScript("OnMouseUp", function(btn)
		local p= btn:GetParent()
        p:StopMovingOrSizing()
        p:ClearAllPoints()
        p:SetPoint('TOPLEFT', FriendsFrame, 'TOPRIGHT')
        Save().IgnoreListWindowHeight= p:GetHeight()
	end)
    FriendsFrame.IgnoreListWindow.ResizeButton:SetScript('OnClick', nil)

        
    https://warcraft.wiki.gg/wiki/Making_resizable_frames
    br:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    br:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    br:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
--]]

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














--保存，大小
local function Save_Frame_Size(self)
    if self.sizeStopFunc ~= nil then
        self.sizeStopFunc(self)
    else
        local w, h= self:GetParent():GetSize()
        w= math.modf(w)
        h= math.modf(h)
        Save().size[self.name]= {w, h}
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







--[[按 Esc 键，隐藏框体
local function Set_ESC(name, isSet)
    local isRemove, isAdd
    if isSet then--设置 1=移除(禁用), 2=添加(启用)
        isRemove= Save().Esc[name]==1
        isAdd= Save().Esc[name]==2
    end

    local index
    for i, value in pairs(UISpecialFrames) do
        print(i, value)
        if value==name then
            index= i
            --break
        end
    end

    if isRemove then
        if index then
            table.remove(UISpecialFrames, index)
        end
    elseif isAdd then
        if not index then
            table.insert(UISpecialFrames, name)
        end
    end
    return index
end
]]

















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
    for frameName in pairs(Save().UIPanelWindows) do
        index= index+1
        sub=root:CreateCheckbox(
            (index<10 and ' ' or '')..index..') '..frameName,
        function(data)
            return Save().UIPanelWindows[data.name]
        end, function(data)
            Save().UIPanelWindows[data.name]= not Save().UIPanelWindows[data.name] and true or nil
            FrameOnShow_SetPoint(self, Save().UIPanelWindows[data.name])
        end, {name=frameName})
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


















--[[local function Init_Esc_Menu(self, root)
    local sub
    local name= self.name
    local set= Save().Esc[name]

    local function get_text()
        local value= Save().Esc[name]
        local col
        if not value then
            col= '|cff606060'
        elseif value==1 then
            col= '|cnWARNING_FONT_COLOR:'
        elseif value==2 then
            col= '|cnGREEN_FONT_COLOR:'
        end
        return col..'|A:NPE_Icon:0:0|aEsc'
    end

    sub= root:CreateCheckbox(
        get_text(),
    function()
        return Save().Esc[name]
    end, function()
        Save().Esc[name]= not Save().Esc[name] and set
        MenuUtil.SetElementText(sub, get_text())
    end)

    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '按Esc键，隐藏框休' or 'Press the Esc key to hide the frame')
        tooltip:AddLine(' ')
        tooltip:AddLine('|cff606060'..(WoWTools_DataMixin.onlyChinese and '忽略' or IGNORE_DIALOG))
        tooltip:AddLine('|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE))
        tooltip:AddLine('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '启用' or ENABLE))
        tooltip:AddLine(' ')
        tooltip:AddLine(
            format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WoWTools_DataMixin.onlyChinese and '当前' or REFORGE_CURRENT, 'UISpecialFrames')
            ..': '
            ..WoWTools_TextMixin:GetEnabeleDisable(Set_ESC(name) and true or false)
        )
    end)
end


]]














--菜单
local function Init_Menu(self, root)
    local target= self:GetParent()
    local name= self.name
    root:SetTag('WOWTOOLS_RESIZEBUTTON_MENU')

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
            target:SetScale(1)
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
            local t=self:GetParent()
            if not WoWTools_FrameMixin:IsLocked(t) then
                if self.sizeRestFunc then--还原
                    self:sizeRestFunc()
                end
                if not self.notUpdatePositon then
                    WoWTools_DataMixin:Call('UpdateUIPanelPositions', t)
                end
            end
            return MenuResponse.Refresh
        end)
    end

--改变透明度
    if self.set_move_event then
        sub=root:CreateCheckbox(
            (WoWTools_DataMixin.onlyChinese and '改变透明度' or HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY)..' '..(Save().alpha or 1),
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
        WoWTools_MenuMixin:OpenOptions(sub, {
            category=WoWTools_MoveMixin.Category,
            name=WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS
        })
    end

--清除，位置，数据

    root:CreateDivider()
    sub=root:CreateCheckbox(
        (Save().point[name] and '' or '|cff626262')
        ..(WoWTools_DataMixin.onlyChinese and '清除位置' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_STOPWATCH_PARAM_STOP2, CHOOSE_LOCATION:gsub(CHOOSE , ''))),
    function()
        return Save().point[name]
    end, function()
        local data= target.moveFrameData
        if data
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
                WoWTools_DataMixin:Call('UpdateUIPanelPositions', target)
            end
        end
        return MenuResponse.Refresh
    end)




--锁定框体位置
    Init_Point_Menu(self, sub)

--按 Esc 键，隐藏框体
    --Init_Esc_Menu(self, root)


--打开，选项
    sub=root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {
        category=WoWTools_MoveMixin.Category,
        name=WoWTools_MoveMixin.addName,
        --name2=name,
    })


--/reload
    WoWTools_MenuMixin:Reload(sub)

    if self.addMenu then
        self.addMenu(target, root)
    end
end



















--Frame 移动时，设置透明度
local function Set_Move_Alpha(frame)
    local name= frame and frame:GetName()
    if not name or Save().notMoveAlpha then
        return
    end


    if not frame.ResizeButton then
        frame.ResizeButton= CreateFrame("Frame", nil, frame)
    end
    frame.ResizeButton.name= name

    frame.ResizeButton:SetScript('OnEvent', function(self, event)
        local target= self:GetParent()
        if event=='PLAYER_STARTED_MOVING' then
            target:SetAlpha(Save().alpha)

        elseif event=='PLAYER_STOPPED_MOVING' then
            target:SetAlpha(1)

        end
    end)



    function frame.ResizeButton:set_move_event()
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

    frame.ResizeButton:set_move_event()

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
    local name= self.name or target:GetName()

    if WoWTools_FrameMixin:IsLocked(target) then
        GameTooltip:AddDoubleLine('|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT), WoWTools_TextMixin:GetEnabeleDisable(false))
        GameTooltip:Show()
        return
    elseif target:IsProtected() then
        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT,
            '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '禁止操作' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DISABLE, NPE_CONTROLS))
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
    scale= ((scale<=0.4 or scale>=2.5) and ' |cnWARNING_FONT_COLOR:' or ' |cnGREEN_FONT_COLOR:')..scale..' '
    GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE), scale..WoWTools_DataMixin.Icon.left)

    if self.setSize then
        GameTooltip:AddLine(' ')
        local col
        if self.sizeRestTooltipColorFunc then
            col=self.sizeRestTooltipColorFunc(self)
        end
        col=col or (Save().size[name] and '' or '|cff626262')

        local w, h
        w= math.modf(target:GetWidth())
        w= format('%s%d|r', ((self.minWidth and self.minWidth>=w) or (self.maxWidth and self.maxWidth<=w)) and '|cnWARNING_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:', w)

        h= math.modf(target:GetHeight())
        h= format('%s%d|r', ((self.minHeight and self.minHeight>=h) or (self.maxHeight and self.maxHeight<=h)) and '|cnWARNING_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:', h)

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

        --if btn.alpha==0 then
        target:HookScript('OnEnter', function(self)
            self.ResizeButton:SetAlpha(1)
        end)
        target:HookScript('OnLeave', function(self)
            self.ResizeButton:SetAlpha(self.ResizeButton.alpha)
        end)
        --end
    end

    btn:SetScript('OnLeave', function(self)
        GameTooltip_Hide()
        ResetCursor()
        self:SetAlpha(self.alpha or 0.5)
    end)
    btn:SetScript('OnEnter', function(self)
        Set_Tooltip(self)
        SetCursor('Interface\\CURSOR\\Crosshair\\UI-Cursor-SizeRight')
        self:SetAlpha(1)
    end)

    btn:SetAlpha(btn.alpha or 0.5)
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
        if self.scaleStopFunc then
            self.scaleStopFunc(self)
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
            print(WoWTools_MoveMixin.addName, '|cff626262'..tostring(issecure())..'|r', target:GetName(), '|cnWARNING_FONT_COLOR:不能执行|r')
        end
    else
        if size then
            Set_Frame_Size(target, size[1], size[2])--设置大小
        end
        if initFunc then
            initFunc(btn)
        end
        if WoWTools_DataMixin.Player.husandro then
            print(WoWTools_MoveMixin.addName, '|cff626262'..tostring(issecure())..'|r', target:GetName(), '|cnGREEN_FONT_COLOR:执行|r')
        end
    end
end












function WoWTools_MoveMixin:Scale_Size_Button(frame, tab)
    local name= frame:GetName()
    tab= tab or {}

    if not name
        or tab.notZoom
        or frame.ResizeButton
        or (tab.frame and not tab.needSize)
        or _G['WoWToolsResizeButton'..name]

    then
        return
    end

    local setResizeButtonPoint= tab.setResizeButtonPoint--设置，按钮，位置
    local onShowFunc= tab.onShowFunc-- true, function

    local minW= tab.minW or 115--最小窗口， 宽
    local minH= tab.minH or 115--最小窗口，高
    local maxW= tab.maxW--最大，可无
    local maxH= tab.maxH--最大，可无

    local rotationDegrees= tab.rotationDegrees--旋转度数
    local initFunc= tab.initFunc--初始


    frame.ResizeButton= CreateFrame('Button', 'WoWToolsResizeButton'..name, frame, 'PanelResizeButtonTemplate')--UI-HUD-UnitFrame-Player-PortraitOn-CornerEmbellishment SharedUIPanelTemplates.lua


    local btn= frame.ResizeButton

    btn:SetFrameStrata('DIALOG')
    btn:SetFrameLevel(frame:GetFrameLevel()+7)
    btn:SetSize(18, 18)


    if setResizeButtonPoint then
        btn:SetPoint(setResizeButtonPoint[1] or 'BOTTOMRIGHT', setResizeButtonPoint[2] or frame, setResizeButtonPoint[3] or 'BOTTOMRIGHT', setResizeButtonPoint[4] or 0, setResizeButtonPoint[5] or 0)
    else
        btn:SetPoint('BOTTOMRIGHT', frame, 3, -3)
    end


    btn.name= name

--设置缩放
    btn.scaleStopFunc= tab.scaleStopFunc--保存，缩放内容
    btn.scaleUpdateFunc= tab.scaleUpdateFunc
    btn.scaleRestFunc= tab.scaleRestFunc--清除，数据
    btn.restPointFunc= tab.restPointFunc--还原，（清除，位置，数据）
    btn.alpha= tab.alpha--button 透明度
    btn.setSize= tab.sizeRestFunc and true or nil --and not disabledSize--是否有，设置大小，功能
    btn.notUpdatePositon= tab.notUpdatePositon
    btn.notMoveAlpha= tab.notMoveAlpha--是否设置，移动时，设置透明度

    btn.sizeRestFunc= tab.sizeRestFunc--清除，数据
    btn.sizeUpdateFunc= tab.sizeUpdateFunc--setSize时, OnUpdate
    btn.sizeRestTooltipColorFunc= tab.sizeRestTooltipColorFunc--重置，提示SIZE，颜色
    btn.sizeStopFunc= tab.sizeStopFunc--保存，大小，内容
    btn.sizeTooltip= tab.sizeTooltip

    btn.addMenu= tab.addMenu--添加菜单
    --btn.alpha= tab.alpha

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

    WoWTools_TextureMixin:SetButton(btn, {alpha=1})

    --btn:SetClampedToScreen(true)

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
        MenuUtil.CreateContextMenu(s, Init_Menu)
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
                WoWTools_MoveMixin:Set_SizeScale(s)
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

--[[按 Esc 键，隐藏框体
    if Save().Esc[name] then
        Set_ESC(name, true)
    end]]

    Set_Enter(btn, frame)
end








function WoWTools_MoveMixin:MoveAlpha(frame)
    Set_Move_Alpha(frame)
end

function WoWTools_MoveMixin:Set_SizeScale(frame)
    local name= frame and frame:GetName()
    if not name or not frame.ResizeButton then
        return
    end

    if WoWTools_FrameMixin:IsLocked(frame) then
        EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner)
            self:Set_SizeScale(frame)
            EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
        end)
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


function WoWTools_MoveMixin:Set_Frame_Scale(frame)
    local name= frame:GetName()
    local value= name and Save().scale[name]
    if value then
        Set_Frame_Scale(frame, value)
    end
end