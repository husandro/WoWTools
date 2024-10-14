local e= select(2, ...)
local function Save()
    return WoWTools_MoveMixin.Save
end


--清除，位置，数据
local function Clear_Point(self)
    if self.target.setMoveFrame and not self.target.notSave then--清除，位置，数据
        Save().point[self.name]=nil
        if self.restPointFunc then
            self.restPointFunc(self)
        elseif not self.notUpdatePositon then
            e.call(UpdateUIPanelPositions, self.target)
        end
    end
end



--[[菜单
local function Init_Menu(self, root)
    local sub
    sub=root:CreateCheckbox(
        (Save().point[self.name] and '' or '|cff9e9e9e')
        ..(e.onlyChinese and '清除位置' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_STOPWATCH_PARAM_STOP2, CHOOSE_LOCATION:gsub(CHOOSE , ''))),
    function()
        return Save().point[self.name]
    end, function()
        Clear_Point(self)
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(self.name)
    end)

--打开，选项
    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {category=WoWTools_MoveMixin.Category})
end]]





--Frame 移动时，设置透明度
local function Set_Move_Alpha(frame)
    local name= frame:GetName()
    if not frame or Save().disabledZoom or Save().notMoveAlpha or not name then
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
    e.tips:AddDoubleLine(e.addName, WoWTools_MoveMixin.addName)

    if not self:CanChangeAttribute() then
        e.tips:AddLine(format('|cnRED_FONT_COLOR:%s', e.onlyChinese and '当前不可更改' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REFORGE_CURRENT, DISABLE)))
        e.tips:Show()
        return
    end

    if self.notInCombat and UnitAffectingCombat('player') then
        e.tips:AddDoubleLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT), e.GetEnabeleDisable(false))
        e.tips:Show()
        return
    else
        e.tips:AddLine(' ')
    end

    local parent= self.target:GetParent()
    if parent then
        e.tips:AddDoubleLine(parent:GetName() or 'Parent', format('%.2f', parent:GetScale()))
    end
    e.tips:AddDoubleLine('|cffff00ff'..self.name, format('%s %.2f', e.onlyChinese and '实际' or 'Effective', self.target:GetEffectiveScale()))

    local scale
    scale= tonumber(format('%.2f', self.target:GetScale() or 1))
    scale= ((scale<=0.4 or scale>=2.5) and ' |cnRED_FONT_COLOR:' or ' |cnGREEN_FONT_COLOR:')..scale
    e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..scale, e.Icon.left)

    local col= Save().scale[self.name] and '' or '|cff9e9e9e'
    e.tips:AddDoubleLine(col..(e.onlyChinese and '默认' or DEFAULT), col..'Alt+'..e.Icon.left)

    if self.set_move_event then--Frame 移动时，设置透明度
        e.tips:AddLine(' ')
        if not Save().disabledAlpha[self.name] then
            e.tips:AddDoubleLine((e.onlyChinese and '移动时透明度 ' or MAP_FADE_TEXT:gsub(WORLD_MAP, 'Frame'))..'|cnGREEN_FONT_COLOR:'..Save().alpha, e.Icon.mid)
        else
            e.tips:AddDoubleLine('|cff9e9e9e'..((e.onlyChinese and '移动时透明度 禁用' or (MAP_FADE_TEXT:gsub(WORLD_MAP, 'Frame')..' '..DISABLE))), e.Icon.mid)
        end
    end

    if self.disabledSize then
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '大小' or 'Size')..': '..e.GetEnabeleDisable(false), 'Ctrl+'..e.Icon.right)
    elseif self.setSize then
        e.tips:AddLine(' ')
        local w, h
        w= math.modf(self.target:GetWidth())
        w= format('%s%d|r', ((self.minWidth and self.minWidth>=w) or (self.maxWidth and self.maxWidth<=w)) and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:', w)

        h= math.modf(self.target:GetHeight())
        h= format('%s%d|r', ((self.minHeight and self.minHeight>=h) or (self.maxHeight and self.maxHeight<=h)) and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:', h)

        e.tips:AddDoubleLine((e.onlyChinese and '大小' or 'Size')..format(' %s |cffffffffx|r %s', w, h), e.Icon.right)

        local col2
        if self.sizeRestTooltipColorFunc then
            col2=self.sizeRestTooltipColorFunc(self)
        end
        col2=col2 or (Save().size[self.name] and '' or '|cff9e9e9e')
        e.tips:AddDoubleLine(
            col2..(self.sizeRestFunc and (e.onlyChinese and '默认' or DEFAULT) or (e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)),
            col2..'Alt+'..e.Icon.right
        )
        e.tips:AddDoubleLine(e.GetEnabeleDisable(true), 'Ctrl+'..e.Icon.right)
        if self.sizeTooltip then
            if type(self.sizeTooltip)=='function' then
                self:sizeTooltip()
            else
                e.tips:AddLine(self.sizeTooltip)
            end
        end
    end
    if self.target.setMoveFrame and not self.target.notSave then
        local col2= Save().point[self.name] and '' or '|cff9e9e9e'
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(col2..(e.onlyChinese and '清除位置' or (SLASH_STOPWATCH_PARAM_STOP2..CHOOSE_LOCATION:gsub(CHOOSE , ''))), col2..'Shift+'..e.Icon.left)
    else
        e.tips:AddLine(' ')
    end
    e.tips:AddDoubleLine(e.onlyChinese and '选项' or OPTIONS, 'Shift+'..e.Icon.right)

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

        local target = self.target
        local continueResizeStop = true
        if target.onResizeStopCallback then
            continueResizeStop = target.onResizeStopCallback(self)
        end
        if continueResizeStop then
            target:StopMovingOrSizing()
        end
        if self.sizeStopFunc ~= nil then
            self.sizeStopFunc(self)
        else
            Save().size[self.name]= {self.target:GetSize()}
        end
    end
    --self:SetScript("OnUpdate", nil)
end






local function Set_OnMouseDown(self, d)
    if self.isActive or (self.notInCombat and UnitAffectingCombat('player')) or not self:CanChangeAttribute() then
        return
    end
    if IsShiftKeyDown() then
        if d=='RightButton' then
            --MenuUtil.CreateContextMenu(self, Init_Menu)
            e.OpenPanelOpting(WoWTools_MoveMixin.Category)--打开，选项

        elseif d=='LeftButton' then
            Clear_Point(self)--清除，位置，数据
        end

    elseif IsControlKeyDown() then
        if (self.setSize or self.disabledSize) and d=='RightButton' then--禁用，启用，大小，功能
            Save().disabledSize[self.name]= not Save().disabledSize[self.name] and true or nil
            print(e.addName, WoWTools_MoveMixin.addName, e.GetEnabeleDisable(not Save().disabledSize[self.name]), self.name, e.onlyChinese and '大小' or 'Size', '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD))
        end

    elseif d=='LeftButton' then
        if IsAltKeyDown() then--清除，缩放，数据
            self.target:SetScale(1)
            Save().scale[self.name]=nil
            if self.scaleRestFunc then
                self.scaleRestFunc(self)
            end
            if not self.notUpdatePositon then
                e.call(UpdateUIPanelPositions, self.target)
            end

        elseif not IsModifierKeyDown() then--开始，设置，缩放
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
        end

    elseif d=='RightButton' then
        if not self.setSize then
            return
        end
        if IsAltKeyDown() then--清除，大小，数据
            Save().size[self.name]=nil
            if self.sizeRestFunc then--还原
                self.sizeRestFunc(self)
            end
            if not self.notUpdatePositon then
                e.call(UpdateUIPanelPositions, self.target)
            end

        elseif not IsModifierKeyDown() then--开始，设置，大小
            self.isActive = true
            local target = self.target
            local continueResizeStart = true
            if target.onResizeStartCallback then
                continueResizeStart = target.onResizeStartCallback(self)
            end
            if continueResizeStart then
                self.target:SetResizable(true)
                self.target:StartSizing("BOTTOMRIGHT", true)
            end
            self:SetScript('OnUpdate', function(frame)
                Set_Tooltip(frame)
                if frame.sizeUpdateFunc then
                    frame.sizeUpdateFunc(frame)
                end
            end)
        end
    end

    Set_Tooltip(self)
end

















--是否设置，移动时，设置透明度
local function Set_OnMouseWheel(self, d)
    if self.notInCombat and UnitAffectingCombat('player') or not self:CanChangeAttribute() then
        return
    end
    local col
    if d==1 then
        Save().disabledAlpha[self.name]= true
        col= '|cff9e9e9e'
    else
        Save().disabledAlpha[self.name]= nil
        col= '|cnGREEN_FONT_COLOR:'
    end
    print(e.addName, WoWTools_MoveMixin.addName, e.GetEnabeleDisable(not Save().disabledAlpha[self.name]),
        '|cffff00ff'..self.name..'|r|n',
        col..(e.onlyChinese and '当你开始移动时，Frame变为透明状态。' or OPTION_TOOLTIP_MAP_FADE:gsub(string.lower(WORLD_MAP), 'Frame')),
        Save().alpha
    )
    self:set_move_event()
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
    local disabledSize= Save().disabledSize[name]
    local onShowFunc= tab.onShowFunc-- true, function

    local minW= tab.minW or 115--(e.Player.husandro and 115 or frame:GetWidth()/2)--最小窗口， 宽
    local minH= tab.minH or 115--(e.Player.husandro and 115 or frame:GetHeight()/2)--最小窗口，高
    local maxW= tab.maxW--最大，可无
    local maxH= tab.maxH--最大，可无

    local rotationDegrees= tab.rotationDegrees--旋转度数
    local initFunc= tab.initFunc--初始

    local btn=_G['WoWToolsResizeButton'..name]
    if not btn then
        btn= CreateFrame('Button', _G['WoWToolsResizeButton'..name], frame, 'PanelResizeButtonTemplate')--SharedUIPanelTemplates.lua
        btn:SetFrameLevel(9999)
        btn:SetSize(16, 16)
        if setResizeButtonPoint then
            btn:SetPoint(setResizeButtonPoint[1] or 'BOTTOMRIGHT', setResizeButtonPoint[2] or frame, setResizeButtonPoint[3] or 'BOTTOMRIGHT', setResizeButtonPoint[4] or 0, setResizeButtonPoint[5] or 0)
        else
            btn:SetPoint('BOTTOMRIGHT', frame, 6,-6)
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
    btn.alpha= tab.alpha--设置透明度为0，移到frame设置为1，
    btn.disabledSize= disabledSize--禁用，大小功能
    btn.setSize= setSize and not disabledSize--是否有，设置大小，功能    
    btn.notInCombat= tab.notInCombat--战斗中，禁止操作
    btn.notUpdatePositon= tab.notUpdatePositon
    btn.notMoveAlpha= tab.notMoveAlpha--是否设置，移动时，设置透明度

    btn.sizeRestFunc= tab.sizeRestFunc--清除，数据
    btn.sizeUpdateFunc= tab.sizeUpdateFunc--setSize时, OnUpdate
    btn.sizeRestTooltipColorFunc= tab.sizeRestTooltipColorFunc--重置，提示SIZE，颜色
    btn.sizeStopFunc= tab.sizeStopFunc--保存，大小，内容
    btn.sizeTooltip= tab.sizeTooltip

    if btn.setSize then
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
    if scale then
        frame:SetScale(scale)
    end

    btn:SetScript("OnMouseUp", function(s, d)
        Set_OnMouseUp(s, d)
    end)
    btn:SetScript("OnMouseDown",function(s, d)
        Set_OnMouseDown(s, d)
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
        do
            Set_Move_Alpha(frame)
        end
        if btn.set_move_event then
            btn:SetScript('OnMouseWheel', function(s, d)--是否设置，移动时，设置透明度
                Set_OnMouseWheel(s, d)
            end)
        end
    end
end








function WoWTools_MoveMixin:MoveAlpha(frame)
    Set_Move_Alpha(frame)
end