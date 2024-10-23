local e= select(2, ...)
local function Save()
    return WoWTools_MoveMixin.Save
end




--保存，大小
local function Save_Frame_Size(self)
    if self.sizeStopFunc ~= nil then
        self.sizeStopFunc(self)
    else
        Save().size[self.name]= {self.target:GetSize()}
    end
end



--百分比，设置大小
local function Set_ScalePercent(self, isSu)
    local w,h= self.target:GetSize()
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

    self.target:SetSize(w,h)

    Save_Frame_Size(self)--保存，大小
end












--菜单
local function Init_Menu(self, root)
    local sub, sub2
    if not self.target:CanChangeAttribute() then
        root:CreateTitle(format('|cnRED_FONT_COLOR:%s', e.onlyChinese and '当前不可更改' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REFORGE_CURRENT, DISABLE)))
        return
    elseif self.notInCombat and UnitAffectingCombat('player') then
        root:CreateTitle(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        return
    end

--缩放
    WoWTools_MenuMixin:Scale(root, function()
        return self.target:GetScale()
    end, function(value)
        if self.target:CanChangeAttribute() then
            Save().scale[self.name]=value
            self.target:SetScale(value)
        end
    end, function()
        Save().scale[self.name]=nil
        if self.scaleRestFunc then
            self.scaleRestFunc(self)
        end
    end)

--尺寸
    if self.setSize then
        sub=root:CreateCheckbox(
            e.onlyChinese and '尺寸' or HUD_EDIT_MODE_SETTING_ARCHAEOLOGY_BAR_SIZE,
        function()
            return not Save().disabledSize[self.name]
        end, function()
            Save().disabledSize[self.name]= not Save().disabledSize[self.name] and true or nil
        end)
--x
        sub:CreateSpacer()
        sub2=WoWTools_MenuMixin:CreateSlider(sub, {
            getValue=function()
                return math.modf(self.target:GetWidth())
            end, setValue=function(value)
                if self.target:CanChangeAttribute() then
                    self.target:SetWidth(value)
                    Save_Frame_Size(self)--保存，大小
                end
            end,
            name='x',
            minValue=self.minWidth,
            maxValue=self.maxWidth or math.modf(UIParent:GetWidth()),
            step=5,
        })
        sub2:SetEnabled(not Save().disabledSize[self.name] and self.target:CanChangeAttribute())
        sub:CreateSpacer()
        sub:CreateSpacer()
        sub2=WoWTools_MenuMixin:CreateSlider(sub, {
            getValue=function()
                return math.modf(self.target:GetHeight())
            end, setValue=function(value)
                if self.target:CanChangeAttribute() then
                    self.target:SetHeight(value)
                    Save_Frame_Size(self)--保存，大小
                end
            end,
            name='y',
            minValue= self.minHeight,
            maxValue= self.maxHeight or math.modf(UIParent:GetHeight()),
            step=5,
        })
        sub2:SetEnabled(not Save().disabledSize[self.name] and self.target:CanChangeAttribute())
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
            e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
        function()
            return Save().size[self.name]
        end, function()
            Save().size[self.name]=nil
            if self.sizeRestFunc then--还原
                self.sizeRestFunc(self)
            end
            if not self.notUpdatePositon then
                e.call(UpdateUIPanelPositions, self.target)
            end
            return MenuResponse.Refresh
        end)
    end

--改变透明度
    if self.set_move_event then
        sub=root:CreateCheckbox(
            (e.onlyChinese and '改变透明度' or CHANGE_OPACITY)..' '..(Save().alpha or 1),
        function()
            return not Save().disabledAlpha[self.name]
        end, function()
            Save().disabledAlpha[self.name]= not Save().disabledAlpha[self.name] and true or nil
            self:set_move_event()
        end)
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(e.onlyChinese and '移动时' or CAMERA_SMARTER)
        end)

--设置
        WoWTools_MenuMixin:OpenOptions(sub, {category=WoWTools_MoveMixin.Category, name=e.onlyChinese and '设置' or SETTINGS})
    end

--清除，位置，数据
    if not Save().disabledMove then
        root:CreateDivider()
        root:CreateRadio(
            (Save().point[self.name] and '' or '|cff9e9e9e')
            ..(e.onlyChinese and '清除位置' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_STOPWATCH_PARAM_STOP2, CHOOSE_LOCATION:gsub(CHOOSE , ''))),
        function()
            return Save().point[self.name]
        end, function()
            if self.target.setMoveFrame and not self.target.notSave then
                Save().point[self.name]=nil
                if self.restPointFunc then
                    self.restPointFunc(self)
                elseif not self.notUpdatePositon then
                    e.call(UpdateUIPanelPositions, self.target)
                end
            end
            return MenuResponse.Refresh
        end)
    end

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
        else
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
    e.tips:SetOwner(self, "ANCHOR_RIGHT")
    e.tips:ClearLines()


    if not self:CanChangeAttribute() then
        e.tips:AddLine(format('|cnRED_FONT_COLOR:%s', e.onlyChinese and '当前不可更改' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REFORGE_CURRENT, DISABLE)))
        e.tips:Show()
        return
    end

    if self.notInCombat and UnitAffectingCombat('player') then
        e.tips:AddDoubleLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT), e.GetEnabeleDisable(false))
        e.tips:Show()
        return
    end

    e.tips:AddDoubleLine('|cffff00ff'..self.name, format('%s %.2f', e.onlyChinese and '实际' or 'Effective', self.target:GetEffectiveScale()))
    local parent= self.target:GetParent()
    if parent then
        e.tips:AddDoubleLine(parent:GetName() or 'Parent', format('%.2f', parent:GetScale()))
    end

    local scale
    scale= tonumber(format('%.2f', self.target:GetScale() or 1))
    scale= ((scale<=0.4 or scale>=2.5) and ' |cnRED_FONT_COLOR:' or ' |cnGREEN_FONT_COLOR:')..scale..' '
    e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE), scale..e.Icon.left)

    if self.setSize then
        e.tips:AddLine(' ')
        local col
        if self.sizeRestTooltipColorFunc then
            col=self.sizeRestTooltipColorFunc(self)
        end
        col=col or (Save().size[self.name] and '' or '|cff9e9e9e')

        local w, h
        w= math.modf(self.target:GetWidth())
        w= format('%s%d|r', ((self.minWidth and self.minWidth>=w) or (self.maxWidth and self.maxWidth<=w)) and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:', w)

        h= math.modf(self.target:GetHeight())
        h= format('%s%d|r', ((self.minHeight and self.minHeight>=h) or (self.maxHeight and self.maxHeight<=h)) and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:', h)

        e.tips:AddDoubleLine(
            col..(e.onlyChinese and '尺寸' or HUD_EDIT_MODE_SETTING_ARCHAEOLOGY_BAR_SIZE)..format(' %s |cffffffffx|r %s', w, h),
                e.GetEnabeleDisable(not Save().disabledSize[self.name])..e.Icon.right
        )

        if self.sizeTooltip then
            if type(self.sizeTooltip)=='function' then
                self:sizeTooltip()
            else
                e.tips:AddLine(self.sizeTooltip)
            end
        end
    end

    e.tips:AddLine(' ')
    if self.set_move_event then--Frame 移动时，设置透明度
        e.tips:AddDoubleLine(
            (e.onlyChinese and '移动时透明度 ' or MAP_FADE_TEXT:gsub(WORLD_MAP, 'Frame')),
            Save().disabledAlpha[self.name] and e.GetEnabeleDisable(false) or ('|cnGREEN_FONT_COLOR:'..Save().alpha)
        )
    end

    e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.mid)

    if self.notInCombat then
        e.tips:AddLine(' ')
        e.tips:AddLine(e.onlyChinese and '请不要在战斗中操作' or 'Please don\'t do it in combat')
    end
    e.tips:Show()
end










local function Set_Enter(btn, alpha)
    if alpha then
        btn:SetAlpha(alpha)
        btn.alpha= alpha
    end
    btn:SetScript('OnLeave', function(self)
        GameTooltip_Hide()
        ResetCursor()
        btn:SetAlpha(self.alpha or 1)
    end)
    btn:SetScript('OnEnter', function(self)
        Set_Tooltip(self)
        SetCursor("UI_RESIZE_CURSOR")
        self:SetAlpha(self.alpha and 1 or 0.5)
    end)
end








local function Set_OnMouseUp(self, d)
    self:SetScript("OnUpdate", nil)

    if not self.isActive or (self.notInCombat and UnitAffectingCombat('player')) or not self:CanChangeAttribute() then
        return
    end

    self.isActive= nil
    if d=='LeftButton' then--保存，缩放
        if self.scaleStoppedFunc then
            self.scaleStoppedFunc(self)
        else
            Save().scale[self.name]= self.target:GetScale()
        end

    elseif d=='RightButton' and self.setSize then--保存，大小
        local continueResizeStop = true
        if self.target.onResizeStopCallback then
            continueResizeStop = self.target.onResizeStopCallback(self)
        end
        if continueResizeStop then
            self.target:StopMovingOrSizing()
        end
        Save_Frame_Size(self)--保存，大小
    end
    --self:SetScript("OnUpdate", nil)
end






local function Set_OnMouseDown(self, d)
    if self.isActive or (self.notInCombat and UnitAffectingCombat('player')) or not self.target:CanChangeAttribute() then
        return
    end

    if d=='LeftButton' then
        self.isActive= true
        local target= self.target
        self.SOS.left, self.SOS.top = target:GetLeft(), target:GetTop()
        self.SOS.scale = target:GetScale()
        self.SOS.x, self.SOS.y = self.SOS.left, self.SOS.top-(UIParent:GetHeight()/self.SOS.scale)
        self.SOS.EFscale = target:GetEffectiveScale()
        self.SOS.dist = GetScaleDistance(self.SOS)
        self:SetScript("OnUpdate", function(frame2)
            local SOS= frame2.SOS
            local distance= GetScaleDistance(SOS)
            local scale2 = distance/SOS.dist*SOS.scale
            if scale2 < 0.4 then -- clamp min and max scale
                scale2 = 0.4
            elseif scale2 > 2.5 then
                scale2 = 2.5
            end
            scale2= tonumber(format('%.2f', scale2))
            local target2= frame2.target
            target2:SetScale(scale2)

            local s = SOS.scale/target:GetScale()
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
        self.isActive = true
        local continueResizeStart = true
        if self.target.onResizeStartCallback then
            continueResizeStart = self.target.onResizeStartCallback(self)
        end
        if continueResizeStart then
            self.target:SetResizable(true)
            self.target:StartSizing("BOTTOMRIGHT", true)
        end
        self:SetScript('OnUpdate', function(f)
            Set_Tooltip(f)
            if f.sizeUpdateFunc then
                f.sizeUpdateFunc(f)
            end
        end)
    end

    Set_Tooltip(self)
end



















local function Set_OnShow(self)
    if (self.notInCombat and UnitAffectingCombat('player')) or not self:CanChangeAttribute() then
        return
    end
    local name2= self:GetName()
    local scale2= Save().scale[name2]
    if scale2 then
        self:SetScale(scale2)
    end
    if self.ResizeButton.setSize then
        local size= Save().size[name2]
        if size then
            self:SetSize(size[1], size[2])
        end
    end
end




local function Set_Init_Frame(btn, target, size, initFunc)
    if btn.notInCombat and UnitAffectingCombat('player') then
        btn.notInCombatFrame= CreateFrame("Frame", nil, btn)
        btn.notInCombatFrame.size=size
        btn.notInCombatFrame.target=target
        btn.notInCombatFrame.initFunc=initFunc
        btn:SetScript("OnEvent", function(self)
            if self.size then
                do
                    self.target:SetSize(self.size[1], self.size[2])
                end
                self.size=nil
                self.frame=nil
            end
            if self.initFunc then
                do
                    self.initFunc(self:GetParent())
                end
                self.initFunc=nil
            end
            self:UnregisterEvent('PLAYER_REGEN_ENABLED')
        end)
        btn:RegisterEvent('PLAYER_REGEN_ENABLED')
    else
        if size then
            target:SetSize(size[1], size[2])
        end
        if initFunc then
            initFunc(btn)
        end
    end
end












function WoWTools_MoveMixin:ScaleSize(frame, tab)
    local name= tab.name or frame:GetName()

    if not name
        or (Save().disabledZoom and not tab.needSize)
        or tab.notZoom
        or frame.ResizeButton
        or tab.frame
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

    local btn=_G['WoWToolsResizeButton'..name]
    if not btn then
        btn= CreateFrame('Button', _G['WoWToolsResizeButton'..name], frame, 'PanelResizeButtonTemplate')--SharedUIPanelTemplates.lua
        btn:SetFrameStrata('HIGH')
        btn:SetFrameLevel(frame:GetFrameLevel()+7)---9999)
        btn:Raise()
        btn:SetSize(16, 16)
        if setResizeButtonPoint then
            btn:SetPoint(setResizeButtonPoint[1] or 'BOTTOMRIGHT', setResizeButtonPoint[2] or frame, setResizeButtonPoint[3] or 'BOTTOMRIGHT', setResizeButtonPoint[4] or 0, setResizeButtonPoint[5] or 0)
        else
            btn:SetPoint('BOTTOMRIGHT', frame)--m, 6,-6)
        end
    end

    frame.ResizeButton= btn

    btn.target= btn.target or frame
    btn.name= name

--设置缩放
    btn.scaleStoppedFunc= tab.scaleStoppedFunc--保存，缩放内容
    btn.scaleUpdateFunc= tab.scaleUpdateFunc
    btn.scaleRestFunc= tab.scaleRestFunc--清除，数据
    btn.restPointFunc= tab.restPointFunc--还原，（清除，位置，数据）
    btn.alpha= tab.alpha--设置透明度为0，移到frame设置为1
    btn.setSize= setSize --and not disabledSize--是否有，设置大小，功能    
    btn.notInCombat= tab.notInCombat--战斗中，禁止操作
    btn.notUpdatePositon= tab.notUpdatePositon
    btn.notMoveAlpha= tab.notMoveAlpha--是否设置，移动时，设置透明度

    btn.sizeRestFunc= tab.sizeRestFunc--清除，数据
    btn.sizeUpdateFunc= tab.sizeUpdateFunc--setSize时, OnUpdate
    btn.sizeRestTooltipColorFunc= tab.sizeRestTooltipColorFunc--重置，提示SIZE，颜色
    btn.sizeStopFunc= tab.sizeStopFunc--保存，大小，内容
    btn.sizeTooltip= tab.sizeTooltip

    if btn.sizeRestFunc then
        frame:SetResizable(true)
        btn:Init(frame, minW, minH, maxW , maxH, rotationDegrees)
        --[[
            self.target = target
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

    WoWTools_ColorMixin:SetLabelTexture(btn, {type='Button', alpha=1})--设置颜色

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
        frame:SetScale(scale)
    end

    btn:SetScript("OnMouseUp", function(s, d)
        Set_OnMouseUp(s, d)
    end)
    btn:SetScript("OnMouseDown",function(s, d)
        Set_OnMouseDown(s, d)
    end)
    btn:SetScript('OnMouseWheel', function(f)
        MenuUtil.CreateContextMenu(f, Init_Menu)
        Set_Tooltip(f)
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
end








function WoWTools_MoveMixin:MoveAlpha(frame)
    Set_Move_Alpha(frame)
end