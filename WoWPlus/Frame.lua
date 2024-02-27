local id, e = ...
local Save={
    --disabledMove=true,--禁用移动
    point={},--移动
    SavePoint= e.Player.husandro,--保存窗口,位置
    moveToScreenFuori=e.Player.husandro,--可以移到屏幕外

    --disabledZoom=true,--禁用缩放
    scale={--缩放
        ['UIWidgetPowerBarContainerFrame']= 0.85,
    },
    size={},
    disabledSize={},--['CharacterFrame']= true

    --notAlpha=true,--是否设置，移动时，设置透明度
    alpha=0.5,
    disabledAlpha={},
}
local addName= 'Frame'
local panel= CreateFrame("Frame")
















function GetScaleDistance(SOS) -- distance from cursor to TopLeft :)
	local left, top = SOS.left, SOS.top
	local scale = SOS.EFscale
	local x, y = GetCursorPosition()
	x = x/scale - left
	y = top - y/scale
	return sqrt(x*x+y*y)
end


local function Set_Scale_Size(frame, tab)
    local name= tab.name
    if not name or Save.disabledZoom or tab.notZoom or frame.ResizeButton or tab.frame then
        return
    end
    local btn= CreateFrame('Button', _G['WoWToolsResizeButton'..name], frame, 'PanelResizeButtonTemplate')--SharedUIPanelTemplates.lua
    frame.ResizeButton= btn

    --设置缩放
    btn.scaleStoppedFunc= tab.scaleStoppedFunc--保存，缩放内容
    btn.scaleRestFunc= tab.scaleRestFunc--清除，数据

    local setSize= tab.setSize
    local disabledSize= Save.disabledSize[name]
    btn.disabledSize= disabledSize--禁用，大小功能
    btn.setSize= setSize and not disabledSize--是否有，设置大小，功能

    local onShowFunc= tab.onShowFunc-- true, function
    btn.notAlpha= tab.notAlpha--是否设置，移动时，设置透明度

    if btn.setSize then
        local minW= tab.minW or (e.Player.husandro and 115 or frame:GetWidth()/2)--最小窗口， 宽
        local minH= tab.minH or (e.Player.husandro and 115 or frame:GetHeight()/2)--最小窗口，高
        local maxW= tab.maxW--最大，可无
        local maxH= tab.maxH--最大，可无
        local rotationDegrees= tab.rotationDegrees--旋转度数
        local initFunc= tab.initFunc--初始
        btn.sizeRestFunc= tab.sizeRestFunc--清除，数据
        btn.sizeUpdateFunc= tab.sizeUpdateFunc--setSize时, OnUpdate
        btn.sizeRestTooltipColorFunc= tab.sizeRestTooltipColorFunc--重置，提示SIZE，颜色
        btn.sizeStoppedFunc= tab.sizeStoppedFunc--保存，大小，内容

        frame:SetResizable(true)
        btn:Init(frame, minW, minH, maxW , maxH, rotationDegrees)
        --[[
            self.target = target
            self.minWidth = minWidth
            self.minHeight = minHeight
            self.maxWidth = maxWidth
            self.maxHeight = maxHeight
        ]]
        if initFunc then
            initFunc(btn)
        end
        local size= Save.size[name]
        if size then
            frame:SetSize(size[1], size[2])
        end
    end
    --[[btn= CreateFrame('Button', nil, frame)
    btn:SetNormalAtlas('Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up')
    btn:SetHighlightAtlas('Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight')
    btn:SetPushedAtlas('Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down')]]

    e.Set_Label_Texture_Color(btn, {type='Button', alpha=1})--设置颜色

    --btn:SetAlpha(0.5)
    btn:SetSize(16, 16)
    btn:SetPoint('BOTTOMRIGHT', frame, 6,-6)
    btn:SetClampedToScreen(true)
    btn:SetScript('OnLeave', function() GameTooltip_Hide() ResetCursor()  end)
    function btn:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:AddLine(' ')
        local parent= self.target:GetParent()
        if parent then
            e.tips:AddDoubleLine(parent:GetName() or 'Parent', format('%.2f', parent:GetScale()))
        end
        e.tips:AddDoubleLine('|cffff00ff'..self.name, format('%s %.2f', e.onlyChinese and '实际' or 'Effective', self.target:GetEffectiveScale()))

        local scale
        scale= tonumber(format('%.2f', self.target:GetScale() or 1))
        scale= ((scale<=0.4 or scale>=2.5) and ' |cnRED_FONT_COLOR:' or ' |cnGREEN_FONT_COLOR:')..scale
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..scale, e.Icon.left)

        local col= Save.scale[self.name] and '' or '|cff606060'
        e.tips:AddDoubleLine(col..(e.onlyChinese and '默认' or DEFAULT), col..'Alt+'..e.Icon.left)

        if not self.notAlpha then
            e.tips:AddLine(' ')
            if not Save.disabledAlpha[self.name] then
                e.tips:AddDoubleLine((e.onlyChinese and '透明度 ' or 'Alpha ')..'|cnGREEN_FONT_COLOR:'..Save.alpha, e.Icon.mid)
            else
                e.tips:AddDoubleLine('|cff606060'..(e.onlyChinese and '透明度 禁用' or ('Alpha '..DISABLE)), e.Icon.mid)
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

            local col
            if self.sizeRestTooltipColorFunc then
                col=self.sizeRestTooltipColorFunc(self)
            end
            col=col or (Save.size[self.name] and '' or '|cff606060')
            e.tips:AddDoubleLine(
                col..(self.sizeRestFunc and (e.onlyChinese and '默认' or DEFAULT) or (e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)),
                col..'Alt+'..e.Icon.right
            )
            e.tips:AddDoubleLine(e.GetEnabeleDisable(true), 'Ctrl+'..e.Icon.right)
        end

        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '选项' or OPTIONS, 'Shift+'..e.Icon.left)
        e.tips:Show()
    end
    btn:SetScript('OnEnter', function(self)
        self:set_tooltip()
        SetCursor("UI_RESIZE_CURSOR")
    end)


    btn.target= frame
    btn.name= name
    btn.SOS = { --Scaler Original State
        dist = 0,
        x = 0,
        y = 0,
        left = 0,
        top = 0,
        scale = 1,
    }

    local scale= Save.scale[name]
    if scale then
        frame:SetScale(scale)
    end
   
    btn:SetScript("OnMouseUp", function(self, d)
        if not self.isActive then
            return
        end
        self.isActive= nil
        if d=='LeftButton' then--保存，缩放
            if self.scaleStoppedFunc then
                self.scaleStoppedFunc(self)
            else
                Save.scale[self.name]= self.target:GetScale()
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
            if self.sizeStoppedFunc ~= nil then
                self.sizeStoppedFunc(self)
            else
                Save.size[self.name]= {self.target:GetSize()}
            end
        end
        self:SetScript("OnUpdate", nil)
    end)
    btn:SetScript("OnMouseDown",function(self, d)
        if self.isActive then
            return
        end
        if IsShiftKeyDown() then
            e.OpenPanelOpting()

        elseif IsControlKeyDown() then
            if (self.setSize or self.disabledSize) and d=='RightButton' then--禁用，启用，大小，功能
                Save.disabledSize[self.name]= not Save.disabledSize[self.name] and true or nil
                print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabledSize[self.name]), self.name, e.onlyChinese and '大小' or 'Size', '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD))
            end

        elseif d=='LeftButton' then
            if IsAltKeyDown() then--清除，缩放，数据
                self.target:SetScale(1)
                Save.scale[self.name]=nil
                if self.scaleRestFunc then
                    self.scaleRestFunc(self)
                end
                e.call('UpdateUIPanelPositions', self.target)

            elseif not IsModifierKeyDown() then--开始，设置，缩放
                self.isActive= true
                local target= self.target
                self.SOS.left, self.SOS.top = target:GetLeft(), target:GetTop()
                self.SOS.scale = target:GetScale()
                self.SOS.x, self.SOS.y = self.SOS.left, self.SOS.top-(UIParent:GetHeight()/self.SOS.scale)
                self.SOS.EFscale = target:GetEffectiveScale()
                self.SOS.dist = GetScaleDistance(self.SOS)
                self:SetScript("OnUpdate", function(frame)
                    local SOS= frame.SOS
                    local distance= GetScaleDistance(SOS)
                    local scale = distance/SOS.dist*SOS.scale
                    if scale < 0.4 then -- clamp min and max scale
                        scale = 0.4
                    elseif scale > 2.5 then
                        scale = 2.5
                    end
                    scale= tonumber(format('%.2f', scale))
                    local target= frame.target
                    target:SetScale(scale)

                    local s = SOS.scale/target:GetScale()
                    local x = SOS.x*s
                    local y = SOS.y*s
                    target:ClearAllPoints()
                    target:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
                    frame:set_tooltip()
                end)
            end

        elseif d=='RightButton' then
            if not self.setSize then
                return
            end
            if IsAltKeyDown() then--清除，大小，数据
                Save.size[self.name]=nil
                if self.sizeRestFunc then--还原
                    self.sizeRestFunc(self)
                end
                e.call('UpdateUIPanelPositions', self.target)

            elseif not IsModifierKeyDown() then--开始，设置，大小
                self.isActive = true
                local target = self.target
                local continueResizeStart = true
                if target.onResizeStartCallback then
                    continueResizeStart = target.onResizeStartCallback(self)
                end
                if continueResizeStart then
                    local alwaysStartFromMouse = true
                    self.target:StartSizing("BOTTOMRIGHT", alwaysStartFromMouse)
                end
                self:SetScript('OnUpdate', function(frame)
                    frame:set_tooltip()
                    if frame.sizeUpdateFunc then
                        frame.sizeUpdateFunc(frame)
                    end
                end)
            end
        end
    end)

    if onShowFunc then
        if onShowFunc==true then
            frame:HookScript('OnShow', function(self)
                local name= self:GetName()
                local scale= Save.scale[name]
                if scale then
                    self:SetScale(scale)
                end
                if self.ResizeButton.setSize then
                    local size= Save.size[name]
                    if size then
                        self:SetSize(size[1], size[2])
                    end
                end
            end)
        else
            frame:HookScript('OnShow', onShowFunc)
        end
    end

    if not Save.notAlpha and not btn.notAlpha then--移动时，设置透明度
        btn:SetScript('OnEvent', function(self, event)
            if event=='PLAYER_STARTED_MOVING' then
                self.target:SetAlpha(Save.alpha)
            else
                self.target:SetAlpha(1)
            end
        end)
        function btn:set_event()
            if not Save.disabledAlpha[self.name] then
                if self:IsShown() then
                    self:RegisterEvent('PLAYER_STARTED_MOVING')
                    self:RegisterEvent('PLAYER_STOPPED_MOVING')
                end
                self:SetScript('OnShow', function(frame)
                    frame:RegisterEvent('PLAYER_STARTED_MOVING')
                    frame:RegisterEvent('PLAYER_STOPPED_MOVING')
                end)
                self:SetScript('OnHide', function(frame)
                    frame:UnregisterAllEvents()
                    frame.target:SetAlpha(1)
                end)
            else
                self:UnregisterAllEvents()
                self:SetScript('OnShow', nil)
                self:SetScript('OnHide', nil)
                self.target:SetAlpha(1)
            end
        end
        btn:set_event()
        btn:SetScript('OnMouseWheel', function(self, d)--是否设置，移动时，设置透明度
            if d==1 then
                Save.disabledAlpha[self.name]= true
            else
                Save.disabledAlpha[self.name]= nil
            end
            print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabledAlpha[self.name]),
                '|cffff00ff'..self.name..'|r|n', 
                e.onlyChinese and '当你开始移动时，Frame变为透明状态。' or OPTION_TOOLTIP_MAP_FADE:gsub(string.lower(WORLD_MAP), 'Frame'),
                '|cffff7f00'..Save.alpha
            )
            self:set_event()
            self:set_tooltip()
        end)
    end
end





























--###############
--设置, 移动, 位置
--###############
local function set_Frame_Point(self, name)--设置, 移动, 位置
    if Save.SavePoint and self and not self.notSave then
        name= name or self.FrameName or self:GetName()
        if name then
            local p= Save.point[name]
            if p and p[1] and p[3] and p[4] and p[5] then
                local frame= self.targetMoveFrame or self
                frame:ClearAllPoints()
                frame:SetPoint(p[1], UIParent, p[3], p[4], p[5])
            end
        end
    end
end





--####
--移动
--####
local function set_Move_Frame(self, tab)
    tab= tab or {}

    local frame= tab.frame
    local name= tab.name or (frame and frame:GetName()) or (self and self:GetName())
    local click= tab.click
    local frame= tab.frame
    local notSave= tab.notSave or not Save.SavePoint

    if not self or not name or self.setMoveFrame then
        return
    end
    tab.name= name

    Set_Scale_Size(self, tab)

    if Save.disabledMove or tab.notMove or self.setMoveFrame then
        return
    end

    self.targetMoveFrame= tab.frame--要移动的Frame
    self.setMoveFrame=true
    self.typeClick= click
    self.notSave= notSave
    if not Save.moveToScreenFuori and Save.SavePoint then
        self:SetClampedToScreen(true)
        if frame then
            frame:SetClampedToScreen(true)
        end
    end
    self:SetMovable(true)
    if frame then
        frame:SetMovable(true)
    end
    if click=='RightButton' then
        self:RegisterForDrag("RightButton")
    elseif click=='LeftButton' then
        self:RegisterForDrag("LeftButton")
    else
        self:RegisterForDrag("LeftButton", "RightButton")
    end
    self:HookScript("OnDragStart", function(s)
        s= s.targetMoveFrame or s
        s:StartMoving()
    end)
    self:HookScript("OnDragStop", function(s)
        local s2= s.targetMoveFrame or s
        s2:StopMovingOrSizing()
        ResetCursor()
        local frameName= s2:GetName()
        if s.notSave or not frameName then
            return
        end
        Save.point[frameName]= {s2:GetPoint(1)}
        Save.point[frameName][2]= nil
    end)
    self:HookScript("OnMouseDown", function(s, d)--设置, 光标
        if d~='RightButton' and d~='LeftButton' then
            return
        end
        if d== s.typeClick or not s.typeClick then
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    self:HookScript("OnMouseUp", ResetCursor)--停止移动
    self:HookScript("OnLeave", ResetCursor)
    set_Frame_Point(self, tab.name)--设置, 移动, 位置
end



















--####
--缩放
--####
local function set_Zoom_Frame(frame, tab)--notZoom, zeroAlpha, name, point=left)--放大
    if frame.ResizeButton or tab.notZoom or Save.disabledZoom then --or not tab.name or _G['MoveZoomInButtonPer'..tab.name] or _G['WoWToolsResizeButton'..tab.name] then
        return
    end

    frame.ResizeButton= e.Cbtn(frame, {atlas='UI-HUD-Minimap-Zoom-In', size={18,18}, name='MoveZoomInButtonPer'..tab.name})
    e.Set_Label_Texture_Color(frame.ResizeButton, {type='Button'})

    frame.ResizeButton.name= tab.name
    frame.ResizeButton.target= frame
    frame.ResizeButton.alpha= tab.zeroAlpha and 0 or 0.2
    frame.ResizeButton:SetFrameLevel(frame.ResizeButton:GetFrameLevel() +5)

    if frame.moveButton then
        frame.ResizeButton:SetPoint('RIGHT', frame.moveButton, 'LEFT')

    elseif tab.point=='left' then
        frame.ResizeButton:SetPoint('RIGHT', frame, 'LEFT')

    elseif frame.Header then
        frame.ResizeButton:SetPoint('LEFT')

    elseif frame.TitleContainer then
        frame.ResizeButton:SetPoint('LEFT', 35,-2)

    elseif frame.SpellButtonContainer then
        frame.ResizeButton:SetPoint('BOTTOM', frame.SpellButtonContainer, 'TOP', -20,0)

    elseif frame.BorderFrame and frame.BorderFrame.TitleContainer then
        frame.ResizeButton:SetPoint('LEFT', 35,-2)

    else
        frame.ResizeButton:SetPoint('BOTTOMLEFT', frame, 'TOPLEFT')
    end

    frame.ResizeButton:SetScript('OnClick', function(self, d)
        if UnitAffectingCombat('player') then
            return
        end
        local n= Save.scale[self.name] or 1
        if d=='LeftButton' then
            n= n+ 0.05
        elseif d=='RightButton' then
            n= n- 0.05
        end
        n= n>3 and 3 or n
        n= n< 0.5 and 0.5 or n
        Save.scale[self.name]= n
        self.target:SetScale(n)
        self:set_Tooltips()
    end)

    frame.ResizeButton:SetScript('OnMouseWheel', function(self,d)
        if UnitAffectingCombat('player') then
            return
        end
        local n= Save.scale[self.name] or 1
        if d==-1 then
            n= n+ 0.05
        elseif d==1 then
            n= n- 0.05
        end
        n= n>4 and 4 or n
        n= n< 0.4 and 0.4 or n
        Save.scale[self.name]= n
        self.target:SetScale(n)
        self:set_Tooltips()
    end)

    frame.ResizeButton:SetAlpha(frame.ResizeButton.alpha)
    frame.ResizeButton:SetScript("OnLeave", function(self)
        e.tips:Hide()
        self:SetAlpha(self.alpha)
    end)
    function frame.ResizeButton:set_Tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:AddLine(self.name)
        e.tips:AddLine(' ')
        local col= UnitAffectingCombat('player') and '|cff606060:' or ''
        e.tips:AddDoubleLine(col..(e.onlyChinese and '缩放' or UI_SCALE).. ' |cnGREEN_FONT_COLOR:'..(format('%.2f', Save.scale[self.name] or 1)), e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(col..(e.onlyChinese and '放大' or ZOOM_IN), e.Icon.left)
        e.tips:AddDoubleLine(col..(e.onlyChinese and '缩小' or ZOOM_OUT), e.Icon.right)
        e.tips:Show()
    end
    frame.ResizeButton:SetScript("OnEnter",function(self)
        self:set_Tooltips()
        self:SetAlpha(1)
    end)

    if Save.scale[tab.name] and Save.scale[tab.name]~=1 then
        frame:SetScale(Save.scale[tab.name])
    end
    if tab.zeroAlpha then
        frame:HookScript('OnEnter', function(self)
            self.ResizeButton:SetAlpha(1)
            if self.moveButton then
                self.moveButton:SetAlpha(1)
            end
        end)
        frame:HookScript('OnLeave', function(self)
            self.ResizeButton:SetAlpha(0)
            if self.moveButton then
                self.moveButton:SetAlpha(0)
            end
        end)
    end
end

--#################
--创建, 一个移动按钮
--#################
local function created_Move_Button(frame, tab)--created_Move_Button(frame, {frame=nil, save=true, zeroAlpha=nil, notZoom=nil})
    tab= tab or {}
    tab.name= tab.name or (frame and frame:GetName())
    if not frame or not tab.name then
        return
    end
    if not Save.disabledMove and not frame.moveButton then
        frame.moveButton= e.Cbtn(frame, {texture='Interface\\Cursor\\UI-Cursor-Move', size={22,22}})
        frame.moveButton:SetPoint('BOTTOM', frame, 'TOP')
        frame.moveButton:SetFrameLevel(frame:GetFrameLevel()+5)
        frame.moveButton.alpha= tab.zeroAlpha and 0 or 0.2
        frame.moveButton:SetAlpha(frame.moveButton.alpha)
        frame.moveButton:SetScript("OnEnter",function(self)
            self:SetAlpha(1)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, tab.click=='RightButton' and e.Icon.right or e.Icon.left)
            e.tips:AddDoubleLine(id, e.cn(addName))
            e.tips:Show()
        end)
        tab.frame=frame
        set_Move_Frame(frame.moveButton, tab)
        frame.moveButton:SetScript("OnLeave", function(self)
            ResetCursor()
            e.tips:Hide()
            self:SetAlpha(self.alpha)
        end)
        set_Frame_Point(frame)--设置, 移动, 位置)
    end
    set_Zoom_Frame(frame, tab)
end























--[[local combatCollectionsJournal--藏品
local function set_Move_CollectionJournal()--藏品
    set_Move_Frame(CollectionsJournal)--藏品
    --set_Move_Frame(RematchJournal, {frame=CollectionsJournal})--藏品
    set_Move_Frame(WardrobeFrame)--幻化
end]]






























local function setAddLoad(arg1)
    if arg1=='Blizzard_TrainerUI' then--专业训练师
        set_Move_Frame(ClassTrainerFrame, {minW=328, minH=197, setSize=true, initFunc=function(btn)
            ClassTrainerFrameSkillStepButton:SetPoint('RIGHT', -12, 0)
            ClassTrainerFrameBottomInset:SetPoint('BOTTOMRIGHT', -4, 28)
            hooksecurefunc('ClassTrainerFrame_Update', function()--Blizzard_TrainerUI.lua
                ClassTrainerFrame.ScrollBox:SetPoint('BOTTOMRIGHT', -26, 34)
            end)
            btn.target.ScrollBox:ClearAllPoints()
        end, sizeRestFunc=function(self)
            self.target:SetSize(338, 424)
        end})





    elseif arg1=='Blizzard_Communities' then--公会和社区
        --communitiesFrame:SetSize(814, 426)
        --communitiesFrame:SetSize(322, 406)
        set_Move_Frame(CommunitiesFrame, {setSize=true, initFunc=function()
            local function set_size(frame)
                local self= frame:GetParent()
                local size, scale
                local displayMode = self:GetDisplayMode();
                if displayMode==COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
                    self.ResizeButton.minWidth= 290
                    self.ResizeButton.minHeight= 115
                    size= Save.size['CommunitiesFrameMINIMIZED']
                    scale= Save.scale['CommunitiesFrameMINIMIZED']
                else
                    size= Save.size['CommunitiesFrameNormal']
                    scale= Save.scale['CommunitiesFrameNormal']
                    self.ResizeButton.minWidth= 814
                    self.ResizeButton.minHeight= 426
                end
                if size then
                    self:SetSize(size[1], size[2])
                end
                if scale then
                    self:SetScale(scale)
                end
            end
            hooksecurefunc(CommunitiesFrame.MaxMinButtonFrame, 'Minimize', set_size)--maximizedCallback
            hooksecurefunc(CommunitiesFrame.MaxMinButtonFrame, 'Maximize', set_size)
            hooksecurefunc(ClubFinderCommunityAndGuildFinderFrame.CommunityCards.ScrollBox, 'Update', function(frame)
                for _, btn in pairs(frame:GetFrames() or {}) do
                    btn.Name:ClearAllPoints()
                    btn.Name:SetPoint('TOPLEFT', btn.LogoBorder, 'TOPRIGHT', 12,0)
                    btn.Description:ClearAllPoints()
                    btn.Description:SetPoint('LEFT', btn.LogoBorder, 'RIGHT', 12,0)
                    btn.Description:SetPoint('RIGHT', btn.RequestJoin, 'LEFT', -26,0)
                    btn.Background:SetPoint('RIGHT', -12,0)--移动背景
                    local cardInfo= btn.cardInfo-- or {}-- clubFinderGUID, isCrossFaction, clubId, 

                    if not btn.corssFactionTexture and cardInfo.isCrossFaction then--跨阵营
                        btn.corssFactionTexture= btn:CreateTexture(nil, 'OVERLAY')
                        btn.corssFactionTexture:SetSize(18,18)
                        btn.corssFactionTexture:SetAtlas('CrossedFlags')
                        btn.corssFactionTexture:SetPoint('LEFT', btn.MemberIcon, 'RIGHT', 4, 0)
                    end
                    if btn.corssFactionTexture then
                        btn.corssFactionTexture:SetShown(true)--not cardInfo.isCrossFaction)
                    end
                    local autoAccept--自动，批准, 无效
                    local clubStatus= cardInfo.clubFinderGUID and C_ClubFinder.GetPlayerClubApplicationStatus(cardInfo.clubFinderGUID)
                    btn:SetAlpha(btn.RequestJoin:IsShown() and 1 or 0.3)
                    if clubStatus then
                        autoAccept= clubStatus== Enum.PlayerClubRequestStatus.AutoApproved--2
                    end
                    if not btn.autoAcceptTexture and autoAccept then
                        btn.autoAcceptTexture= btn:CreateTexture(nil, 'OVERLAY')
                        btn.autoAcceptTexture:SetSize(18,18)
                        btn.autoAcceptTexture:SetAtlas(e.Icon.select)
                        btn.autoAcceptTexture:SetPoint('LEFT', btn.MemberIcon, 'RIGHT', 24, 0)
                    end
                    if btn.autoAcceptTexture then
                        btn.autoAcceptTexture:SetShown(autoAccept)
                    end
                end
            end)
        end, scaleStoppedFunc= function(btn)
            local self= btn.target
            local displayMode = self:GetDisplayMode()
            if displayMode==COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
                Save.scale['CommunitiesFrameMINIMIZED']= self:GetScale()
            else
                Save.scale['CommunitiesFrameNormal']= self:GetScale()
            end
        end, scaleRestFunc=function(btn)
            local displayMode = btn.target:GetDisplayMode()
            if displayMode==COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
                Save.scale['CommunitiesFrameMINIMIZED']= nil
            else
                Save.scale['CommunitiesFrameNormal']= nil
            end
        end, sizeStoppedFunc=function(btn)
            local self= btn.target
            local displayMode = self:GetDisplayMode()
            if displayMode==COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
                Save.size['CommunitiesFrameMINIMIZED']= {self:GetSize()}
            else
                Save.size['CommunitiesFrameNormal']= {self:GetSize()}
            end
        end, sizeRestFunc=function(btn)
            local self= btn.target
            local displayMode = self:GetDisplayMode()
            if displayMode==COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
                Save.size['CommunitiesFrameMINIMIZED']=nil
                self:SetSize(322, 406)
            elseif Save.size['CommunitiesFrameNormal'] then
                Save.size['CommunitiesFrameNormal']= nil
                self:SetSize(814, 426)
            end
        end, sizeRestTooltipColorFunc=function(btn)
            local displayMode = btn.target:GetDisplayMode()
            if displayMode==COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
                if Save.size['CommunitiesFrameMINIMIZED'] then
                    return ''
                end
            elseif Save.size['CommunitiesFrameNormal'] then
                return ''
            end
            return '|cff606060'
        end,
        })
        set_Move_Frame(CommunitiesFrame.RecruitmentDialog)
        set_Move_Frame(CommunitiesFrame.NotificationSettingsDialog)
        set_Move_Frame(CommunitiesFrame.NotificationSettingsDialog.Selector, {frame=CommunitiesFrame.NotificationSettingsDialog})
        set_Move_Frame(CommunitiesFrame.NotificationSettingsDialog.ScrollFrame, {frame=CommunitiesFrame.NotificationSettingsDialog})

    elseif arg1=='Blizzard_TimeManager' then--小时图，时间
        set_Move_Frame(TimeManagerFrame, {save=true})

    elseif arg1=='Blizzard_AchievementUI' then--成就
        set_Move_Frame(AchievementFrame, {minW=768, maxW=768, minH=500, setSize=true, initFunc=function()
            AchievementFrameCategories:ClearAllPoints()
            AchievementFrameCategories:SetPoint('TOPLEFT', 21, -19)
            AchievementFrameCategories:SetPoint('BOTTOMLEFT', 175, 19)
            AchievementFrameMetalBorderRight:ClearAllPoints()
        end, sizeRestFunc=function(self)
            self.target:SetSize(768, 500)
        end})
        set_Move_Frame(AchievementFrameComparisonHeader, {frame=AchievementFrame})
        set_Move_Frame(AchievementFrame.Header, {frame=AchievementFrame})


    elseif arg1=='Blizzard_EncounterJournal' then--冒险指南
        set_Move_Frame(EncounterJournal, {minW=800, minH=496, maxW=800, setSize=true, initFunc=function()
            EncounterJournalMonthlyActivitiesFrame.FilterList:SetPoint('BOTTOMLEFT', 225, 5)-- Blizzard_MonthlyActivities.xml
            EncounterJournalMonthlyActivitiesFrame.ScrollBox:SetPoint('BOTTOMLEFT', EncounterJournalMonthlyActivitiesFrame.FilterList, 'BOTTOMRIGHT')
            EncounterJournalInstanceSelectBG:SetPoint('BOTTOMRIGHT', 0,2)
            EncounterJournalInstanceSelect.ScrollBox:SetPoint('BOTTOMLEFT', -3, 15)
            EncounterJournal.LootJournalItems.ItemSetsFrame:SetPoint('TOPRIGHT', -22, -10)
            for _, region in pairs({EncounterJournal.LootJournalItems:GetRegions()}) do
                if region:GetObjectType()=='Texture' then
                    region:SetPoint('BOTTOM')
                    break
                end
            end
            EncounterJournal.LootJournal.ScrollBox:SetPoint('TOPLEFT', 20, -51)
            for _, region in pairs({EncounterJournal.LootJournal:GetRegions()}) do
                if region:GetObjectType()=='Texture' then
                    region:SetPoint('BOTTOM')
                    break
                end
            end
            EncounterJournalEncounterFrameInfo:SetPoint('TOP')
            EncounterJournalEncounterFrameInfo.BossesScrollBox:SetPoint('TOP', 0, -43)
            EncounterJournalEncounterFrameInstanceFrame:SetPoint('TOP')
            EncounterJournalEncounterFrameInfoBG:SetPoint('TOP')
            EncounterJournalEncounterFrameInstanceFrameMapButton:ClearAllPoints()
            EncounterJournalEncounterFrameInstanceFrameMapButton:SetPoint('TOPLEFT', 33, -275)
            EncounterJournalEncounterFrameInstanceFrame.LoreScrollingFont:SetPoint('TOPRIGHT', -35, -330)
            EncounterJournalEncounterFrameInfoOverviewScrollFrame:SetPoint('TOP',0,-43)
            EncounterJournalEncounterFrameInfo.LootContainer:SetPoint('TOP', 0, -43)
            EncounterJournalEncounterFrameInfoDetailsScrollFrame:SetPoint('TOP', 0, -43)
            EncounterJournalEncounterFrameInfoModelFrame:ClearAllPoints()
            EncounterJournalEncounterFrameInfoModelFrame:SetPoint('RIGHT', 0, 0)
        end, sizeRestFunc=function(self)
            self.target:SetSize(800, 496)
        end})

    elseif arg1=='Blizzard_ClassTalentUI' then--天赋
        local frame=ClassTalentFrame
        if frame then
            set_Move_Frame(frame, {save=true})
            if frame.TalentsTab and frame.TalentsTab.ButtonsParent then
                set_Move_Frame(frame.TalentsTab.ButtonsParent, {save=true, frame=frame})--里面, 背景
            end
            if frame.ResizeButton then
                --设置,大小
                --Blizzard_SharedTalentFrame.lua
                hooksecurefunc(TalentFrameBaseMixin, 'OnShow', function (self)
                    local name= ClassTalentFrame:GetName()
                    if name then
                        if Save.scale[name] and Save.scale[name]~= ClassTalentFrame:GetScale() then
                            ClassTalentFrame:SetScale(Save.scale[name])
                        end
                    end
                end)
            end

            --####################
            --专精 UpdateSpecFrame
            --Blizzard_ClassTalentSpecTab.lua
            if frame.SpecTab and frame.SpecTab.SpecContentFramePool then
                for specContentFrame in frame.SpecTab.SpecContentFramePool:EnumerateActive() do
                    set_Move_Frame(specContentFrame, {frame= frame, save=true})
                end
            end
            hooksecurefunc(frame.SpecTab, 'UpdateSpecContents', function()--Blizzard_ClassTalentSpecTab.lua
                local name= ClassTalentFrame:GetName()
                if name then
                    if Save.scale[name] and Save.scale[name]~= ClassTalentFrame:GetScale() then
                        ClassTalentFrame:SetScale(Save.scale[name])
                    end
                end
            end)
        end

    elseif arg1=='Blizzard_AuctionHouseUI' then--拍卖行
        set_Move_Frame(AuctionHouseFrame, {setSize=true, initFunc=function()
            AuctionHouseFrame.CategoriesList:SetPoint('BOTTOM', AuctionHouseFrame.MoneyFrameBorder.MoneyFrame, 'TOP',0,2)
            AuctionHouseFrame.BrowseResultsFrame.ItemList.Background:SetPoint('BOTTOMRIGHT')
            AuctionHouseFrameAuctionsFrame.SummaryList.Background:SetPoint('BOTTOM')
            AuctionHouseFrameAuctionsFrame.AllAuctionsList.Background:SetPoint('BOTTOMRIGHT')
            AuctionHouseFrameAuctionsFrame.BidsList.Background:SetPoint('BOTTOMRIGHT')
            AuctionHouseFrame.WoWTokenResults.BuyoutLabel:ClearAllPoints()
            AuctionHouseFrame.WoWTokenResults.BuyoutLabel:SetPoint('BOTTOM', AuctionHouseFrame.WoWTokenResults.Buyout, 'TOP', 0, 32)
            AuctionHouseFrame.WoWTokenResults.Background:SetPoint('BOTTOMRIGHT')
            AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.Background:SetPoint('BOTTOM')
            AuctionHouseFrame.CommoditiesBuyFrame.ItemList.Background:SetPoint('BOTTOMRIGHT')
            AuctionHouseFrame.ItemBuyFrame.ItemList.Background:SetPoint('BOTTOMRIGHT')
            AuctionHouseFrame.ItemBuyFrame.ItemDisplay:SetPoint('RIGHT',-3, 0)
            AuctionHouseFrame.ItemBuyFrame.ItemDisplay.Background:SetPoint('RIGHT')

            hooksecurefunc(AuctionHouseFrame, 'SetDisplayMode', function(self, mode)
                local size= Save.size[self:GetName()]
                if not size then
                    return
                end
                local btn= self.ResizeButton
                if mode==AuctionHouseFrameDisplayMode.ItemSell or mode==AuctionHouseFrameDisplayMode.CommoditiesSell then
                    self:SetSize(800, 538)
                    btn.minWidth = 800
                    btn.minHeight = 538
                    btn.maxWidth = 800
                    btn.maxHeight = 538
                else
                    self:SetSize(size[1], size[2])
                    btn.minWidth = 600
                    btn.minHeight = 320
                    btn.maxWidth = nil
                    btn.maxHeight = nil
                end
            end)
        end, sizeRestFunc=function(btn)
            btn.target:SetSize(800, 538)
        end})

        set_Move_Frame(AuctionHouseFrame.ItemSellFrame, {frame=AuctionHouseFrame})
        set_Move_Frame(AuctionHouseFrame.ItemSellFrame.Overlay, {frame=AuctionHouseFrame})
        set_Move_Frame(AuctionHouseFrame.ItemSellFrame.ItemDisplay, {frame=AuctionHouseFrame})

        set_Move_Frame(AuctionHouseFrame.CommoditiesSellFrame, {frame=AuctionHouseFrame})
        set_Move_Frame(AuctionHouseFrame.CommoditiesSellFrame.Overlay, {frame=AuctionHouseFrame})
        set_Move_Frame(AuctionHouseFrame.CommoditiesSellFrame.ItemDisplay, {frame=AuctionHouseFrame})

        set_Move_Frame(AuctionHouseFrame.ItemBuyFrame.ItemDisplay, {frame=AuctionHouseFrame, save=true})
        set_Move_Frame(AuctionHouseFrameAuctionsFrame.ItemDisplay, {frame=AuctionHouseFrame, save=true})

    elseif arg1=='Blizzard_BlackMarketUI' then--黑市
        set_Move_Frame(BlackMarketFrame)


























    elseif arg1=='Blizzard_Collections' then--收藏
        local checkbox = WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox
        checkbox.Label:ClearAllPoints()
        checkbox.Label:SetPoint("LEFT", checkbox, "RIGHT", 2, 1)
        checkbox.Label:SetPoint("RIGHT", checkbox, "RIGHT", 160, 1)
        set_Move_Frame(CollectionsJournal)--藏品
        --set_Move_Frame(RematchJournal, {frame=CollectionsJournal})--藏品
        set_Move_Frame(WardrobeFrame)--幻化

        --[[if not UnitAffectingCombat('player') then
            set_Move_CollectionJournal()--藏品
        else
            combatCollectionsJournal=true
            panel:RegisterEvent('PLAYER_REGEN_ENABLED')
        end]]

    elseif arg1=='Blizzard_Calendar' then--日历
        set_Move_Frame(CalendarFrame)
        set_Move_Frame(CalendarEventPickerFrame, {frame=CalendarFrame})
        set_Move_Frame(CalendarTexturePickerFrame, {frame=CalendarFrame})
        set_Move_Frame(CalendarMassInviteFrame, {frame=CalendarFrame})
        set_Move_Frame(CalendarCreateEventFrame, {frame=CalendarFrame})
        set_Move_Frame(CalendarViewEventFrame, {frame=CalendarFrame})
        set_Move_Frame(CalendarViewHolidayFrame, {frame=CalendarFrame})
        set_Move_Frame(CalendarViewRaidFrame, {frame=CalendarFrame})

    elseif arg1=='Blizzard_GarrisonUI' then--要塞
        set_Move_Frame(GarrisonShipyardFrame)--海军行动
        set_Move_Frame(GarrisonMissionFrame)--要塞任务
        set_Move_Frame(GarrisonCapacitiveDisplayFrame)--要塞订单
        set_Move_Frame(GarrisonLandingPage)--要塞报告
        set_Move_Frame(OrderHallMissionFrame)

    elseif arg1=='Blizzard_PlayerChoice' then
        set_Move_Frame(PlayerChoiceFrame)--任务选择

    elseif arg1=="Blizzard_GuildBankUI" then--公会银行
        set_Move_Frame(GuildBankFrame)

    elseif arg1=='Blizzard_FlightMap' then--飞行地图
        set_Move_Frame(FlightMapFrame)

    elseif arg1=='Blizzard_OrderHallUI' then
        set_Move_Frame(OrderHallTalentFrame)

    elseif arg1=='Blizzard_GenericTraitUI' then--欲龙术
        set_Move_Frame(GenericTraitFrame)
        set_Move_Frame(GenericTraitFrame.ButtonsParent, {frame=GenericTraitFrame})

    elseif arg1=='Blizzard_WeeklyRewards' then--'Blizzard_EventTrace' then--周奖励面板
        set_Move_Frame(WeeklyRewardsFrame)
        set_Move_Frame(WeeklyRewardsFrame.Blackout, {frame=WeeklyRewardsFrame})

    elseif arg1=='Blizzard_ItemSocketingUI' then--镶嵌宝石，界面
        set_Move_Frame(ItemSocketingFrame)
    elseif arg1=='Blizzard_ItemUpgradeUI' then--装备升级,界面
        set_Move_Frame(ItemUpgradeFrame)

    elseif arg1=='Blizzard_InspectUI' then--玩家, 观察角色, 界面
        if InspectFrame then
            set_Move_Frame(InspectFrame)
        end

    elseif arg1=='Blizzard_PVPUI' then--地下城和团队副本, PVP
        if not Save.disabledZoom then
            PVPUIFrame:SetPoint('BOTTOMRIGHT')
            LFGListPVPStub:SetPoint('BOTTOMRIGHT')
            LFGListFrame.ApplicationViewer.InfoBackground:SetPoint('RIGHT', -2,0)
            hooksecurefunc('PVPQueueFrame_ShowFrame', function()
                local btn= PVEFrame.ResizeButton
                if btn.disabledSize then
                    return
                end
                if PVPQueueFrame.selection==LFGListPVPStub then
                    btn.setSize= true
                    local size= Save.size['PVEFrame_PVP']
                    if size then
                        PVEFrame:SetSize(size[1], size[2])
                        return
                    end
                else
                    btn.setSize= false
                end
                PVEFrame:SetHeight(428)
            end)
        end

    elseif arg1=='Blizzard_ChallengesUI' then--挑战, 钥匙插件, 界面
        set_Move_Frame(ChallengesKeystoneFrame)

        if not Save.disabledZoom then
            ChallengesFrame.WeeklyInfo:SetPoint('BOTTOMRIGHT')
            ChallengesFrame.WeeklyInfo.Child:SetPoint('BOTTOMRIGHT')
            ChallengesFrame.WeeklyInfo.Child.RuneBG:SetPoint('BOTTOMRIGHT')
            for _, region in pairs({ChallengesFrame:GetRegions()}) do
                if region:GetObjectType()=='Texture' then
                    region:SetPoint('BOTTOMRIGHT')
                end
            end
            ChallengesFrame:HookScript('OnShow', function()
                local self= PVEFrame
                if self.ResizeButton.disabledSize then
                    return
                end
                local size= Save.size['PVEFrame_KEY']
                self.ResizeButton.setSize= true
                if size then
                    self:SetSize(size[1], size[2])
                else
                    self:SetSize(PVE_FRAME_BASE_WIDTH, 428)
                end
            end)
        end

    elseif arg1=='Blizzard_ItemInteractionUI' then--套装, 转换
        set_Move_Frame(ItemInteractionFrame)

    elseif arg1=='Blizzard_Professions' then--专业, 10.1.5
        --[[InspectRecipeFrame:HookScript('OnShow', function(self2)
            local name= self2:GetName()
            if name and Save.scale[name] then
                self2:SetScale(Save.scale[name])
            end
        end)]]
        --set_Move_Frame(InspectRecipeFrame)
            --ProfessionsFrame.CraftingPage        
            --ProfessionsFrame.SpecPage
            --ProfessionsFrame.OrdersPage
        set_Move_Frame(ProfessionsFrame, {setSize=true, initFunc=function()--ProfessionsUtil.SetCraftingMinimized(false)
            ProfessionsFrame.CraftingPage.P_GetDesiredPageWidth= ProfessionsFrame.CraftingPage.GetDesiredPageWidth
            function ProfessionsFrame.CraftingPage:GetDesiredPageWidth()--Blizzard_ProfessionsCrafting.lua
                local size, scale
                local frame= self:GetParent()
                local name= frame:GetName()
                if ProfessionsUtil.IsCraftingMinimized() then
                    scale= Save.scale[name..'Mini']
                    size= Save.size[name..'Mini']

                else
                    scale= Save.scale[name..'Normal']
                    size= Save.size[name..'Normal']
                end
                if scale then
                    frame:SetScale(scale)
                end
                if size then
                    frame:SetSize(size[1], size[2])
                    return size[1]
                else
                    return self:P_GetDesiredPageWidth()--404
                end
            end
            ProfessionsFrame.OrdersPage.P_GetDesiredPageWidth= ProfessionsFrame.OrdersPage.GetDesiredPageWidth
            function ProfessionsFrame.OrdersPage:GetDesiredPageWidth()--Blizzard_ProfessionsCrafterOrderPage.lua
                local frame= self:GetParent()
                local name= frame:GetName()
                local scale= Save.scale[name..'Order']
                local size= Save.size[name..'Order']
                if scale then
                    frame:SetScale(scale)
                end
                if size then
                    frame:SetSize(size[1], size[2])
                    return size[1]
                else
                    return self:P_GetDesiredPageWidth()-- 1105
                end
            end
            ProfessionsFrame.SpecPage.P_GetDesiredPageWidth= ProfessionsFrame.SpecPage.GetDesiredPageWidth
            function ProfessionsFrame.SpecPage:GetDesiredPageWidth()--Blizzard_ProfessionsSpecializations.lua
                local frame= self:GetParent()
                local name= frame:GetName()
                local scale= Save.scale[name..'Spec']
                local size= Save.size[name..'Spec']
                if scale then
                    frame:SetScale(scale)
                end
                if size then
                    frame:SetSize(size[1], size[2])
                    return size[1]
                else
                    return self:P_GetDesiredPageWidth()--1144
                end
            end
            local function set_on_show(self)
                C_Timer.After(0.3, function()
                    local size, scale
                    local name= self:GetName()
                    if ProfessionsUtil.IsCraftingMinimized() then
                        scale= Save.scale[name..'Mini']
                        size= Save.size[name..'Mini']
                        self.ResizeButton.minWidth= 404
                        self.ResizeButton.minHeight= 650
                    elseif self.TabSystem.selectedTabID==1 then
                        scale= Save.scale[name..'Normal']
                        size= Save.size[name..'Normal']
                        self.ResizeButton.minWidth= 830
                        self.ResizeButton.minHeight= 580
                        if size then
                            self:Refresh()
                        end
                    elseif self.TabSystem.selectedTabID==2 then
                        scale= Save.scale[name..'Spec']
                        size= Save.size[name..'Spec']
                        self.ResizeButton.minWidth= 1144
                        self.ResizeButton.minHeight= 658
                    elseif self.TabSystem.selectedTabID==3 then
                        scale= Save.scale[name..'Order']
                        size= Save.size[name..'Order']
                        self.ResizeButton.minWidth= 1050
                        self.ResizeButton.minHeight= 240
                        if size then
                            self:Refresh()
                        end
                    end
                    if scale then
                        self:SetScale(scale)
                    end
                    if size then
                        self:SetSize(size[1], size[2])
                    end
                end)
            end
            ProfessionsFrame:HookScript('OnShow', set_on_show)
            for _, tabID in pairs(ProfessionsFrame:GetTabSet() or {}) do
                local btn= ProfessionsFrame:GetTabButton(tabID)
                btn:HookScript('OnClick', function()
                    set_on_show(ProfessionsFrame)
               end)
            end
            hooksecurefunc(ProfessionsFrame, 'ApplyDesiredWidth', set_on_show)

            --655 553
            local function set_craftingpage_position(self)
                self.SchematicForm:ClearAllPoints()
                self.SchematicForm:SetPoint('TOPRIGHT', -5, -72)
                self.SchematicForm:SetPoint('BOTTOMRIGHT', 670, 5)
                self.RecipeList:ClearAllPoints()
                self.RecipeList:SetPoint('TOPLEFT', 5, -72)
                self.RecipeList:SetPoint('BOTTOMLEFT', 5, 5)
                self.RecipeList:SetPoint('TOPRIGHT', self.SchematicForm, 'TOPLEFT')
            end

            set_craftingpage_position(ProfessionsFrame.CraftingPage)
            function ProfessionsFrame.CraftingPage:SetMaximized()
                set_craftingpage_position(self)
                self:Refresh(self.professionInfo)
            end
            hooksecurefunc(ProfessionsFrame.CraftingPage, 'SetMinimized', function(self)
                self.SchematicForm.Details:ClearAllPoints()
                self.SchematicForm.Details:SetPoint('BOTTOM', 0, 33)
                self.SchematicForm:SetPoint('BOTTOMRIGHT')
            end)
            ProfessionsFrame.CraftingPage.RankBar:ClearAllPoints()
            ProfessionsFrame.CraftingPage.RankBar:SetPoint('RIGHT', ProfessionsFrame.CraftingPage.Prof1Gear1Slot, 'LEFT', -36, 0)

            ProfessionsFrame.CraftingPage.SchematicForm.MinimalBackground:ClearAllPoints()
            ProfessionsFrame.CraftingPage.SchematicForm.MinimalBackground:SetAllPoints(ProfessionsFrame.CraftingPage.SchematicForm)

            ProfessionsFrame.SpecPage.TreeView:ClearAllPoints()
            ProfessionsFrame.SpecPage.TreeView:SetPoint('TOPLEFT', 2, -85)
            ProfessionsFrame.SpecPage.TreeView:SetPoint('BOTTOM', 0, 50)
            ProfessionsFrame.SpecPage.DetailedView:ClearAllPoints()
            ProfessionsFrame.SpecPage.DetailedView:SetPoint('TOPLEFT', ProfessionsFrame.SpecPage.TreeView, 'TOPRIGHT', -40, 0)
            ProfessionsFrame.SpecPage.DetailedView:SetPoint('BOTTOMRIGHT', 0, 50)

            ProfessionsFrame.SpecPage.PanelFooter:ClearAllPoints()
            ProfessionsFrame.SpecPage.PanelFooter:SetPoint('BOTTOMLEFT', 0, 4)
            ProfessionsFrame.SpecPage.PanelFooter:SetPoint('BOTTOMRIGHT')

            ProfessionsFrame.OrdersPage.BrowseFrame.OrderList:ClearAllPoints()
            ProfessionsFrame.OrdersPage.BrowseFrame.OrderList:SetPoint('TOPRIGHT', 0, -92)
            ProfessionsFrame.OrdersPage.BrowseFrame.OrderList:SetWidth(800)
            ProfessionsFrame.OrdersPage.BrowseFrame.OrderList:SetPoint('BOTTOM', 0, 5)
            ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList:ClearAllPoints()
            ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList:SetPoint('TOPLEFT', 5, -92)
            ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList:SetPoint('BOTTOMRIGHT', ProfessionsFrame.OrdersPage.BrowseFrame.OrderList, 'BOTTOMLEFT')
            for _, region in pairs({ProfessionsFrame.SpecPage.PanelFooter:GetRegions()}) do
                if region:GetObjectType()=='Texture' then
                    region:ClearAllPoints()
                    region:SetAllPoints(ProfessionsFrame.SpecPage.PanelFooter)
                    break
                end
            end
        end, scaleStoppedFunc=function(btn)
            local self= btn.target
            local sacle= self:GetScale()
            local name= btn.name
            if ProfessionsUtil.IsCraftingMinimized() then
                Save.scale[name..'Mini']= sacle
            elseif self.TabSystem.selectedTabID==2 then
                Save.scale[name..'Spec']= sacle
            elseif self.TabSystem.selectedTabID==3 then
                Save.scale[name..'Order']= sacle
            else
                Save.scale[name..'Normal']= sacle
            end
        end, scaleRestFunc=function(btn)
            local self= btn.target
            local name= btn.name
            if ProfessionsUtil.IsCraftingMinimized() then
                Save.scale[name..'Mini']= nil
            elseif self.TabSystem.selectedTabID==2 then
                Save.scale[name..'Spec']= nil
            elseif self.TabSystem.selectedTabID==3 then
                Save.scale[name..'Order']= nil
            else
                Save.scale[name..'Normal']= nil
            end
        end, sizeRestTooltipColorFunc= function(btn)
            local name= btn.name
            if ProfessionsUtil.IsCraftingMinimized() then
                return Save.size[name..'Mini'] and '' or '|cff606060'
            elseif btn.target.TabSystem.selectedTabID==2 then
                return Save.size[name..'Spec'] and '' or '|cff606060'
            elseif btn.target.TabSystem.selectedTabID==3 then
                return Save.size[name..'Order'] and '' or '|cff606060'
            else
                return Save.size[name..'Normal'] and '' or '|cff606060'
            end
        end, sizeStoppedFunc=function(btn)
            local self= btn.target
            local name= btn.name
            local size= {self:GetSize()}
            if ProfessionsUtil.IsCraftingMinimized() then
                Save.size[name..'Mini']= size
            elseif self.TabSystem.selectedTabID==2 then
                Save.size[name..'Spec']= size
            elseif self.TabSystem.selectedTabID==3 then
                Save.size[name..'Order']= size
                self:Refresh()
            else
                Save.size[name..'Normal']= size
                self:Refresh()
            end
        end, sizeRestFunc=function(btn)
            local self= btn.target
            local name= btn.name
            if ProfessionsUtil.IsCraftingMinimized() then
                self:SetSize(404, 658)
                Save.size[name..'Mini']=nil
            elseif self.TabSystem.selectedTabID==2 then
                self:SetSize(1144, 658)
                Save.size[name..'Spec']=nil
            elseif self.TabSystem.selectedTabID==3 then
                self:SetSize(1105, 658)
                Save.size[name..'Order']=nil
            else
                self:SetSize(942, 658)
                Save.size[name..'Normal']=nil
                self:Refresh(self.professionInfo)
            end
        end})

    elseif arg1=='Blizzard_ProfessionsCustomerOrders' then--专业定制
        set_Move_Frame(ProfessionsCustomerOrdersFrame, {setSize=true, minW=825, minH=200, onShowFunc=true, initFunc=function()
            ProfessionsCustomerOrdersFrame.BrowseOrders:ClearAllPoints()
            ProfessionsCustomerOrdersFrame.BrowseOrders:SetPoint('TOPLEFT')
            ProfessionsCustomerOrdersFrame.BrowseOrders:SetPoint('BOTTOMRIGHT')
            ProfessionsCustomerOrdersFrame.BrowseOrders.RecipeList:ClearAllPoints()
            ProfessionsCustomerOrdersFrame.BrowseOrders.RecipeList:SetPoint('TOPRIGHT', 0, -72)
            ProfessionsCustomerOrdersFrame.BrowseOrders.RecipeList:SetWidth(660)
            ProfessionsCustomerOrdersFrame.BrowseOrders.RecipeList:SetPoint('BOTTOM', 0, 29)
            ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList:ClearAllPoints()
            ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList:SetPoint('TOPLEFT', 0, -72)
            ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList:SetPoint('BOTTOMRIGHT', ProfessionsCustomerOrdersFrame.BrowseOrders.RecipeList, 'BOTTOMLEFT', 4, 0)
            ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList.ScrollBox:SetPoint('RIGHT', -12,0)
            ProfessionsCustomerOrdersFrame.MyOrdersPage:ClearAllPoints()
            ProfessionsCustomerOrdersFrame.MyOrdersPage:SetPoint('TOPLEFT')
            ProfessionsCustomerOrdersFrame.MyOrdersPage:SetPoint('BOTTOMRIGHT')
            hooksecurefunc(ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList.ScrollBox, 'Update', function(self)
                for _, btn in pairs(self:GetFrames() or {}) do
                    btn.HighlightTexture:SetPoint('RIGHT')
                    btn.NormalTexture:SetPoint('RIGHT')
                    btn.SelectedTexture:SetPoint('RIGHT')
                end
            end)
            ProfessionsCustomerOrdersFrame.Form:HookScript('OnHide', function(self)
                local frame= self:GetParent()
                if frame.ResizeButton.disabledSize then
                    return
                end
                frame.ResizeButton.setSize=true
                local name= frame:GetName()
                local scale= Save.scale[name]
                if scale then
                    frame:SetScale(scale)
                end
                local size= Save.size[name]
                if size then
                    frame:SetSize(size[1], size[2])
                end
            end)
            ProfessionsCustomerOrdersFrame.Form:HookScript('OnShow', function(self)
                local frame= self:GetParent()
                if frame.ResizeButton.disabledSize then
                    return
                end
                frame.ResizeButton.setSize= false
                local name= frame:GetName()
                local scale= Save.scale[name..'From']
                if scale then
                    frame:SetScale(scale)
                end
                if Save.size[name] then
                    frame:SetSize(825, 568)
                end
            end)
        end, scaleStoppedFunc=function(btn)
            local self= btn.target
            local name= btn.name
            if self.Form:IsShown() then
                Save.scale[name..'From']= self:GetScale()
            else
                Save.scale[name]= self:GetScale()
            end
        end, scaleRestFunc=function(btn)
            local name= btn.name
            if btn.target.Form:IsShown() then
                Save.scale[name..'From']= nil
            else
                Save.scale[name]= nil
            end
        end, sizeRestFunc=function(btn)
            btn.target:SetSize(825, 568)
        end})
        set_Move_Frame(ProfessionsCustomerOrdersFrame.Form, {frame=ProfessionsCustomerOrdersFrame})

    elseif arg1=='Blizzard_VoidStorageUI' then--虚空，仓库
         set_Move_Frame(VoidStorageFrame)

    elseif arg1=='Blizzard_ChromieTimeUI' then--时光漫游
        set_Move_Frame(ChromieTimeFrame)


    elseif arg1=='Blizzard_BFAMissionUI' then--侦查地图
        set_Move_Frame(BFAMissionFrame)

    elseif arg1=='Blizzard_MacroUI' then--宏
        set_Move_Frame(MacroFrame)

    elseif arg1=='Blizzard_MajorFactions' then--派系声望
        set_Move_Frame(MajorFactionRenownFrame)

    elseif arg1=='Blizzard_DebugTools' then--FSTACK
        set_Move_Frame(TableAttributeDisplay, {minW=476, minH=150, setSize=true, initFunc=function()
            TableAttributeDisplay.LinesScrollFrame:ClearAllPoints()
            TableAttributeDisplay.LinesScrollFrame:SetPoint('TOPLEFT', 6, -62)
            TableAttributeDisplay.LinesScrollFrame:SetPoint('BOTTOMRIGHT', -36, 22)
            TableAttributeDisplay.FilterBox:SetPoint('RIGHT', -26,0)
            TableAttributeDisplay.TitleButton.Text:SetPoint('RIGHT')
            hooksecurefunc(TableAttributeLineReferenceMixin, 'Initialize', function(self, _, _, attributeData)
                local frame= self:GetParent():GetParent():GetParent()
                local btn= frame.ResizeButton
                if btn and btn.setSize then
                    local w= frame:GetWidth()-200
                    self.ValueButton:SetWidth(w)
                    self.ValueButton.Text:SetWidth(w)
                end
            end)
            hooksecurefunc(TableAttributeDisplay, 'UpdateLines', function(self)
                if self.dataProviders then
                    for _, line in ipairs(self.lines) do
                        if line.ValueButton then
                            local w= self:GetWidth()-200
                            line.ValueButton:SetWidth(w)
                            line.ValueButton.Text:SetWidth(w)
                        end
                    end
                end
            end)
        end, sizeUpdateFunc=function(btn)
            btn.target:UpdateLines()--RefreshAllData()
        end, sizeRestFunc=function(btn)
            btn.target:SetSize(500, 400)
        end})

    elseif arg1=='Blizzard_EventTrace' then--ETRACE
        set_Move_Frame(EventTrace, {notZoom=true, save=true})

    elseif arg1=='Blizzard_DeathRecap' then--死亡
        set_Move_Frame(DeathRecapFrame, {save=true})

    elseif arg1=='Blizzard_ClickBindingUI' then--点击，施法
        set_Move_Frame(ClickBindingFrame)
        set_Move_Frame(ClickBindingFrame.ScrollBox, {frame=ClickBindingFrame})

    elseif arg1=='Blizzard_ArchaeologyUI' then
        set_Move_Frame(ArchaeologyFrame)
    end
end























--###########
--职业，能量条
--###########
local function set_classPowerBar()
    local tab={
        PlayerFrame.classPowerBar,
        RuneFrame,
        MonkStaggerBar,
        _G['PlayerFrameAlternateManaBar'],
        EssencePlayerFrame,
        --MageArcaneChargesFrame,
        --TotemFrame,
    }

    for _, self in pairs(tab) do
        if self and self:IsShown() then
            if self.FrameName then
                set_Frame_Point(self)
            else
                set_Move_Frame(self, {
                    save=true,
                    zeroAlpha=true,
                    point= e.Player.class=='EVOKER' and 'left' or nil,
                })
            end
        end
    end


    if TotemFrame and TotemFrame:IsShown() and TotemFrame.totemPool and TotemFrame.totemPool.activeObjects then
        for btn, _ in pairs(TotemFrame.totemPool.activeObjects) do
            if btn:IsShown() then
                if btn.FrameName then
                    set_Frame_Point(btn)
                else
                    set_Move_Frame(btn, {frame=TotemFrame, save=true, zeroAlpha=true})
                end
            end
        end
    end
end


































--########
--初始,移动
--########
local function Init_Move()
    --世界地图
    local minimizedWidth= WorldMapFrame.minimizedWidth or 702
    local minimizedHeight= WorldMapFrame.minimizedHeight or 534
    local function set_min_max_value(size)
        local self= WorldMapFrame
        local isMax= self:IsMaximized()
        if isMax then
            self.minimizedWidth= minimizedWidth
            self.minimizedHeight= minimizedHeight
            self.BorderFrame.MaximizeMinimizeFrame:Maximize()
        elseif size then
            local w= size[1]-(self.questLogWidth or 290)
            self.minimizedWidth= w
            self.minimizedHeight= size[2]
            self.BorderFrame.MaximizeMinimizeFrame:Minimize()
            --[[QUEST_TEMPLATE_LOG.contentWidth= w--285
            QUEST_TEMPLATE_DETAIL.contentWidth= w-10
            QUEST_TEMPLATE_REWARD.contentWidth= w
            QUEST_TEMPLATE_MAP_DETAILS.contentWidth= w-41
            QUEST_TEMPLATE_MAP_REWARDS.contentWidth= w-41]]
        end
    end
    set_Move_Frame(WorldMapFrame, {minW=(WorldMapFrame.questLogWidth or 290)*2+37, minH=WorldMapFrame.questLogWidth, setSize=true, onShowFunc=true, notAlpha=true, initFunc=function()
        --[[WorldMapFrame:HookScript('OnShow', function(self)
            local scale= Save.scale[self:GetName()]
            if scale then
                self:SetScale(scale)
            end
        end)]]
        hooksecurefunc(WorldMapFrame, 'Minimize', function(self)
            local name= self:GetName()
            local size= Save.size[name]
            if size then
                self:SetSize(size[1], size[2])
                set_min_max_value(size)
            end
            local scale= Save.scale[name]
            if scale then
                self:SetScale(scale)
            end
            self.ResizeButton:SetShown(true)
        end)
        hooksecurefunc(WorldMapFrame, 'Maximize', function(self)
            set_min_max_value()
            if Save.scale[self:GetName()] then
                self:SetScale(1)
            end
            self.ResizeButton:SetShown(false)
        end)
        QuestMapFrame.Background:ClearAllPoints()
        QuestMapFrame.Background:SetAllPoints(QuestMapFrame)
        QuestMapFrame.DetailsFrame:ClearAllPoints()
        QuestMapFrame.DetailsFrame:SetPoint('TOPLEFT', 0, -42)
        QuestMapFrame.DetailsFrame:SetPoint('BOTTOMRIGHT')
        QuestMapFrame.DetailsFrame.Bg:SetPoint('BOTTOMRIGHT')
        QuestMapFrame.DetailsFrame.SealMaterialBG:SetPoint('BOTTOMRIGHT', QuestMapFrame.DetailsFrame.RewardsFrame, 'TOPRIGHT', 0, -6)
        set_Move_Frame(MapQuestInfoRewardsFrame, {frame= WorldMapFrame})
        set_Move_Frame(QuestMapFrame, {frame= WorldMapFrame})
        set_Move_Frame(QuestMapFrame.DetailsFrame, {frame= WorldMapFrame})
        set_Move_Frame(QuestMapFrame.DetailsFrame.RewardsFrame, {frame= WorldMapFrame})
        set_Move_Frame(QuestMapDetailsScrollFrame, {frame= WorldMapFrame})
    end, sizeUpdateFunc= function(btn)--WorldMapMixin:UpdateMaximizedSize()
        set_min_max_value({btn.target:GetSize()})
    end, sizeRestFunc= function(self)
        local target=self.target
        target.minimizedWidth= minimizedWidth
        target.minimizedHeight= minimizedHeight
        target:SetSize(minimizedWidth+ (WorldMapFrame.questLogWidth or 290), minimizedHeight)
        target.BorderFrame.MaximizeMinimizeFrame:Minimize()
    end})
--[[移动,宽度，设置
--ScrollFrame parentKey="QuestsFrame" name="QuestScrollFrame" inherits="ScrollFrameTemplate">
--QuestScrollFrame.Contents:SetPoint('BOTTOMRIGHT')
QuestScrollFrame.Contents:SetPoint('BOTTOMRIGHT')
QuestMapFrame.DetailsFrame.RewardsFrame.RewardsScrollFrame.Contents:SetPoint('BOTTOMRIGHT')
QuestMapFrame.DetailsFrame.ScrollFrame.Contents:SetPoint('BOTTOMRIGHT')

QuestScrollFrame.DetailFrame.TopDetail:ClearAllPoints()
QuestScrollFrame.DetailFrame.TopDetail:SetPoint('TOPLEFT', 0, 9)
QuestScrollFrame.DetailFrame.TopDetail:SetPoint('TOPRIGHT', 0,-15)

QuestScrollFrame.DetailFrame.BottomDetail:ClearAllPoints()
QuestScrollFrame.DetailFrame.BottomDetail:SetPoint('BOTTOMLEFT', 0, 18)
QuestScrollFrame.DetailFrame.BottomDetail:SetPoint('BOTTOMRIGHT')

QuestMapFrame.DetailsFrame.RewardsFrame:SetPoint('RIGHT')

QuestMapDetailsScrollFrame.Contents:SetPoint('RIGHT')

local btn= e.Cbtn(QuestMapFrame, {size={18,18}, icon=true})
btn:SetPoint('LEFT', QuestMapFrame, 'RIGHT')
btn.value= WorldMapFrame.questLogWidth or 290
function btn:initFunc()
    local w= Save.size['questLogWidth']
    if w then
        local p= self:GetParent()
        p:SetWidth(w)
        WorldMapFrame.questLogWidth=w
        minimizedWidth= w
        if not WorldMapFrame:IsMaximized() and WorldMapFrame:IsShown() then
            WorldMapFrame.BorderFrame.MaximizeMinimizeFrame:Minimize()
        end
    end
end
btn:initFunc()
btn:SetScript('OnClick', function(self)
    local w= self.value
    local w2= Save.size['questLogWidth']
    if not self.slider then
        self.slider= e.CSlider(self, {min=w/2, max=w*2, value=w2 or w, setp=1, color=true,
        text= 'QuestMapFrame',
        func=function(frame, value)
            value= math.modf(value)
            value= value==0 and 0 or value
            frame:SetValue(value)
            frame.Text:SetText(value)
            Save.size['questLogWidth']= value
            frame:GetParent():initFunc()
        end})
        self.slider:SetPoint('LEFT', self, 'RIGHT')
        --self.slider:SetPoint('BOTTOMRIGHT', WorldMapFrame.BorderFrame.TitleContainer, 'TOPRIGHT', -23, 2)
    else
        self.slider:SetShown(not self.slider:IsShown() and true or false)
    end
end)]]





















    --插件
    set_Move_Frame(AddonList, {minW=430, minH=120, setSize=true, initFunc=function()
        AddonList.ScrollBox:ClearAllPoints()
        AddonList.ScrollBox:SetPoint('TOPLEFT', 7, -64)
        AddonList.ScrollBox:SetPoint('BOTTOMRIGHT', -22,32)
        hooksecurefunc('AddonList_InitButton', function(entry)
            entry.Title:SetPoint('RIGHT', -220, 0 )
        end)
        --e.call(AddonList_Update)
    end, sizeRestFunc=function(self)
        self.target:SetSize("500", "478")
    end})



    --[[set_Move_Frame(EditModeManagerFrame, {setSize=true, initFunc=function()
        EditModeManagerFrame.AccountSettings.SettingsContainer:SetPoint('TOPLEFT')
        EditModeManagerFrame.AccountSettings.SettingsContainer:SetPoint('BOTTOMRIGHT')
    end})]]
    --AddonList:Show()

















    --角色
    set_Move_Frame(CharacterFrame, {minW=338, minH=424, setSize=true, initFunc=function()
        PaperDollFrame.TitleManagerPane:ClearAllPoints()
        PaperDollFrame.TitleManagerPane:SetPoint('TOPLEFT', CharacterFrameInsetRight, 4, -4)
        PaperDollFrame.TitleManagerPane:SetPoint('BOTTOMRIGHT', CharacterFrameInsetRight, -4, 4)
        PaperDollFrame.TitleManagerPane.ScrollBox:ClearAllPoints()
        PaperDollFrame.TitleManagerPane.ScrollBox:SetPoint('TOPLEFT',CharacterFrameInsetRight,4,-4)
        PaperDollFrame.TitleManagerPane.ScrollBox:SetPoint('BOTTOMRIGHT', CharacterFrameInsetRight, -22,0)

        PaperDollFrame.EquipmentManagerPane:ClearAllPoints()
        PaperDollFrame.EquipmentManagerPane:SetPoint('TOPLEFT', CharacterFrameInsetRight, 4, -4)
        PaperDollFrame.EquipmentManagerPane:SetPoint('BOTTOMRIGHT', CharacterFrameInsetRight, -4, 4)
        PaperDollFrame.EquipmentManagerPane.ScrollBox:ClearAllPoints()
        PaperDollFrame.EquipmentManagerPane.ScrollBox:SetPoint('TOPLEFT', CharacterFrameInsetRight, 4, -28)
        PaperDollFrame.EquipmentManagerPane.ScrollBox:SetPoint('BOTTOMRIGHT', CharacterFrameInsetRight, -22,0)

        CharacterModelScene:ClearAllPoints()
        CharacterModelScene:SetPoint('TOPLEFT', 52, -66)
        CharacterModelScene:SetPoint('BOTTOMRIGHT', CharacterFrameInset, -50, 34)

        CharacterModelFrameBackgroundOverlay:ClearAllPoints()
        CharacterModelFrameBackgroundOverlay:SetAllPoints(CharacterModelScene)

        CharacterModelFrameBackgroundTopLeft:ClearAllPoints()
        CharacterModelFrameBackgroundTopLeft:SetPoint('TOPLEFT')
        CharacterModelFrameBackgroundTopLeft:SetPoint('BOTTOMRIGHT',-19, 128)

        CharacterModelFrameBackgroundTopRight:ClearAllPoints()
        CharacterModelFrameBackgroundTopRight:SetPoint('TOPLEFT', CharacterModelFrameBackgroundTopLeft, 'TOPRIGHT')
        CharacterModelFrameBackgroundTopRight:SetPoint('BOTTOMRIGHT', 0, 128)

        CharacterModelFrameBackgroundBotLeft:ClearAllPoints()
        CharacterModelFrameBackgroundBotLeft:SetPoint('TOPLEFT', CharacterModelFrameBackgroundTopLeft, 'BOTTOMLEFT')
        CharacterModelFrameBackgroundBotLeft:SetPoint('BOTTOMRIGHT', -19, 0)

        CharacterModelFrameBackgroundBotRight:ClearAllPoints()
        CharacterModelFrameBackgroundBotRight:SetPoint('TOPLEFT', CharacterModelFrameBackgroundBotLeft, 'TOPRIGHT')
        CharacterModelFrameBackgroundBotRight:SetPoint('BOTTOMRIGHT')

        CharacterStatsPane.ClassBackground:ClearAllPoints()
        CharacterStatsPane.ClassBackground:SetAllPoints(CharacterStatsPane)

        CharacterMainHandSlot:ClearAllPoints()
        CharacterMainHandSlot:SetPoint('BOTTOMRIGHT', CharacterFrameInset, 'BOTTOM', -2.5, 16)
        CharacterFrameInset:ClearAllPoints()
        CharacterFrameInset:SetPoint('TOPLEFT', 4, -60)
        --PANEL_DEFAULT_WIDTH 338
        --CHARACTERFRAME_EXPANDED_WIDTH 540
        --CharacterStatsPane width 197
        hooksecurefunc('CharacterFrame_Collapse', function()
            CharacterFrameInset:SetPoint('BOTTOMRIGHT',-4, 4)
            local size= Save.size['CharacterFrameCollapse']
            if size then
                CharacterFrame:SetSize(size[1], size[2])
            end
            CharacterFrame.ResizeButton.minWidth= 270
            CharacterFrame.ResizeButton.minHeight= 115
        end)
        hooksecurefunc('CharacterFrame_Expand', function()--显示角色，界面
            CharacterFrameInset:SetPoint('BOTTOMRIGHT', -221, 4)
            local size= Save.size['CharacterFrameExpanded']
            if size then
                CharacterFrame:SetSize(size[1], size[2])
            elseif Save.size['CharacterFrameCollapse'] then
                CharacterFrame:SetHeight(424)
            end
            CharacterFrame.ResizeButton.minWidth= CHARACTERFRAME_EXPANDED_WIDTH
            CharacterFrame.ResizeButton.minHeight= 424
        end)
        set_Move_Frame(ReputationFrame, {frame=CharacterFrame})
        set_Move_Frame(TokenFrame, {frame=CharacterFrame})
    end, sizeUpdateFunc=function()
        if PaperDollFrame.EquipmentManagerPane:IsVisible() then
            e.call('PaperDollEquipmentManagerPane_Update')
        end
        if PaperDollFrame.TitleManagerPane:IsVisible() then
            e.call('PaperDollTitlesPane_Update')
        end
    end, sizeStoppedFunc=function(btn)
        local self= btn.target
        if CharacterFrame.Expanded then
            Save.size['CharacterFrameExpanded']={self:GetSize()}
        else
            Save.size['CharacterFrameCollapse']={self:GetSize()}
        end
    end, sizeRestFunc=function(btn)
        local self= btn.target
        if self.Expanded then
            Save.size['CharacterFrameExpanded']=nil
            self:SetSize(CHARACTERFRAME_EXPANDED_WIDTH, 424)
        else
            Save.size['CharacterFrameCollapse']=nil
            self:SetSize(PANEL_DEFAULT_WIDTH, 424)
        end
    end, sizeRestTooltipColorFunc=function(self)
        return ((self.target.Expanded and Save.size['CharacterFrameExpanded']) or (not self.target.Expanded and Save.size['CharacterFrameCollapse'])) and '' or '|cff606060'
    end})

    --好友列表
    set_Move_Frame(FriendsFrame, {setSize=true, minW=338, minH=424, initFunc=function(self)
            FriendsListFrame.ScrollBox:SetPoint('BOTTOMRIGHT', -24, 30)
            WhoFrameColumnHeader1:SetWidth(200)
            hooksecurefunc(WhoFrame.ScrollBox, 'Update', function(self)
                for _, btn in pairs(self:GetFrames() or {}) do
                    btn:SetPoint('RIGHT')
                end
            end)
        end, sizeRestFunc=function(self)
            self.target:SetSize(338, 424)
    end})
    
    --对话
    set_Move_Frame(GossipFrame, {minW=220, minH=220, setSize=true, initFunc=function(self)
        self.target.GreetingPanel:SetPoint('BOTTOMRIGHT')
        self.target.GreetingPanel.ScrollBox:SetPoint('BOTTOMRIGHT', -28,28)
        self.target.Background:SetPoint('BOTTOMRIGHT', -28,28)
        --GreetingText:SetWidth(GreetingText:GetParent():GetWidth()-56)
        hooksecurefunc(GossipGreetingTextMixin, 'Setup', function(self)
            self.GreetingText:SetWidth(self:GetWidth()-22)
        end)
        --hooksecurefunc(GossipOptionButtonMixin, 'Setup', function(self, optionInfo)
    end, sizeRestFunc=function(self)
        self.target:SetSize(384, 512)
    end})

    --任务
    set_Move_Frame(QuestFrame, {minW=164, minH=128, setSize=true, initFunc=function()
        local tab={
            'Detail',
            'Greeting',
            'Progress',
            'Reward',
        }
        for _, name in pairs(tab) do
            local frame= _G['QuestFrame'..name..'Panel']
            if frame then
                frame:SetPoint('BOTTOMRIGHT')
                if frame.Bg then
                    frame.Bg:SetPoint('BOTTOMRIGHT', -28,28)
                end
                if frame.SealMaterialBG then
                    frame.SealMaterialBG:SetPoint('BOTTOMRIGHT', -28,28)
                end
            end
            frame= _G['Quest'..name..'ScrollFrame']
            if frame then
                frame:SetPoint('BOTTOMRIGHT', -28,28)
            end
        end
    end, sizeRestFunc=function(self)
        self.target:SetSize(338, 496)
    end})

    --聊天设置
    set_Move_Frame(ChannelFrame, {minW=402, minH=200, maxW=402, setSize=true,  sizeRestFunc=function(self)
        self.target:SetSize(402, 423)
    end})




    set_Move_Frame(SettingsPanel, {notSave=true, setSize=true, minW=800, minH=200, initFunc=function(btn)
        for _, region in pairs({btn.target:GetRegions()}) do
            if region:GetObjectType()=='Texture' then
                region:SetPoint('BOTTOMRIGHT', -12, 38)
            end
        end
    end, sizeRestFunc=function(self)
        self.target:SetSize(920, 724)
    end})

    --邮箱，信件
    set_Move_Frame(MailFrame)--[[, {setSize=true, initFunc=function()
        InboxFrame:SetPoint('BOTTOMRIGHT')
        InboxPrevPageButton:ClearAllPoints()
        InboxPrevPageButton:SetPoint('BOTTOMLEFT', 4, 4)
        OpenAllMail:ClearAllPoints()
        OpenAllMail:SetPoint('BOTTOM', 0, 4)
        InboxNextPageButton:ClearAllPoints()
        InboxNextPageButton:SetPoint('BOTTOMRIGHT', -4, 4)
    end})]]
    set_Move_Frame(SendMailFrame, {frame=MailFrame})





    --[[if PVEFrame.activeTabIndex==1 then
    elseif PVEFrame.activeTabIndex==2 then
    elseif PVEFrame.activeTabIndex==3 then
        
    end]]



    --地下城和团队副本

    set_Move_Frame(PVEFrame, {setSize=true, minW=563, minH=428, initFunc=function()
        --btn.PVE_FRAME_BASE_WIDTH= PVE_FRAME_BASE_WIDTH
        LFGListPVEStub:SetPoint('BOTTOMRIGHT')
        LFGListFrame.CategorySelection.Inset.CustomBG:SetPoint('BOTTOMRIGHT')
        --hooksecurefunc('PVEFrame_ShowFrame', function()self.activeTabIndex~=3
        hooksecurefunc('GroupFinderFrame_SelectGroupButton', function(index)
            local btn= PVEFrame.ResizeButton
            if btn.disabledSize then
                return
            end
            if index==3 then
                btn.setSize= true
                local size= Save.size['PVEFrame_PVE']
                if size then
                    PVEFrame:SetSize(size[1], size[2])
                    return
                end
            else
                btn.setSize= false
            end
            PVEFrame:SetSize(PVE_FRAME_BASE_WIDTH, 428)
        end)
    end, sizeUpdateFunc=function(btn)
        if PVEFrame.activeTabIndex==3 then
            e.call(ChallengesFrame.Update, ChallengesFrame)
        end
    end, sizeStoppedFunc=function(btn)
        if PVEFrame.activeTabIndex==1 then
            Save.size['PVEFrame_PVE']= {btn.target:GetSize()}
        elseif PVEFrame.activeTabIndex==2 then
            if PVPQueueFrame.selection==LFGListPVPStub then
                Save.size['PVEFrame_PVP']= {btn.target:GetSize()}
            end
        elseif PVEFrame.activeTabIndex==3 then
            Save.size['PVEFrame_KEY']= {btn.target:GetSize()}
        end

    end, sizeRestFunc=function(btn)
        if PVEFrame.activeTabIndex==1 then
           -- PVE_FRAME_BASE_WIDTH= btn.PVE_FRAME_BASE_WIDTH
            Save.size['PVEFrame_PVE']=nil
            btn.target:SetSize(PVE_FRAME_BASE_WIDTH, 428)
        elseif PVEFrame.activeTabIndex==2 then--Blizzard_PVPUI.lua
            Save.size['PVEFrame_PVP']=nil
            local width = PVE_FRAME_BASE_WIDTH;
	        width = width + PVPQueueFrame.HonorInset:Update();
            btn.target:SetSize(width, 428)
        elseif PVEFrame.activeTabIndex==3 then
            Save.size['PVEFrame_KEY']=nil
            btn.target:SetSize(PVE_FRAME_BASE_WIDTH, 428)
            e.call(ChallengesFrame.Update, ChallengesFrame)
        end
    end})






    --好友列表
    --set_Move_Frame(AddFriendFrame)


    created_Move_Button(ZoneAbilityFrame, {frame=ZoneAbilityFrame.SpellButtonContainer})
    --跟点击，功能冲突 ZoneAbilityFrameSpellButtonMixin:OnDragStart()
    --[[hooksecurefunc(ZoneAbilityFrame, 'UpdateDisplayedZoneAbilities', function(self)
        --for spellButton in self.SpellButtonContainer:EnumerateActive() do
    end)]]



    --########
    --小，背包
    --########
    for i=1 ,NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS+1 do
        local frame= _G['ContainerFrame'..i]
        if frame then
            if i==1 then
                set_Move_Frame(frame, {save=true})
            else
                set_Move_Frame(frame)
            end
        end
    end
    if not Save.disabledZoom and not Save.disabledMove then
        hooksecurefunc('UpdateContainerFrameAnchors', function()--ContainerFrame.lua
            for _, frame in ipairs(ContainerFrameSettingsManager:GetBagsShown()) do
                local name= frame:GetName()
                if name then
                    if not Save.disabledZoom and Save.scale[name] and Save.scale[name]~=1 then--缩放
                        frame:SetScale(Save.scale[name])
                    end
                    if (frame==ContainerFrameCombinedBags or frame==ContainerFrame1) then--位置
                        set_Frame_Point(frame, name)--设置, 移动, 位置
                    end
                end
            end
        end)
    end

    if UIWidgetPowerBarContainerFrame then--移动, 能量条
        created_Move_Button(UIWidgetPowerBarContainerFrame, {})

        function UIWidgetPowerBarContainerFrame:Get_WidgetIsShown()
            for _, frame in pairs(self.widgetFrames or {}) do
                if frame then
                    return true
                end
            end
            return false
        end
        if UIWidgetPowerBarContainerFrame.ResizeButton or UIWidgetPowerBarContainerFrame.moveButton then--and frame.ZoomOut then
            local show= UIWidgetPowerBarContainerFrame:Get_WidgetIsShown()
            if UIWidgetPowerBarContainerFrame.moveButton then
                UIWidgetPowerBarContainerFrame.moveButton:SetShown(show)
            end
            if UIWidgetPowerBarContainerFrame.ResizeButton then
                UIWidgetPowerBarContainerFrame.ResizeButton:SetShown(show)
            end
            hooksecurefunc(UIWidgetPowerBarContainerFrame, 'CreateWidget', function(self)
                local isShow= self:Get_WidgetIsShown()
                if self.ResizeButton then
                    self.ResizeButton:SetShown(isShow)
                end
                if self.moveButton then
                    self.moveButton:SetShown(isShow)
                end
            end)
            hooksecurefunc(UIWidgetPowerBarContainerFrame, 'RemoveWidget', function(self)--Blizzard_UIWidgetManager.lua frame.ZoomOut:SetShown(find)
                local isShow= self:Get_WidgetIsShown()
                if self.ResizeButton then
                    self.ResizeButton:SetShown(isShow)
                end
                if self.moveButton then
                    self.moveButton:SetShown(isShow)
                end
            end)
            hooksecurefunc(UIWidgetPowerBarContainerFrame, 'RemoveAllWidgets', function(self)
                if self.ResizeButton then
                    self.ResizeButton:SetShown(false)
                end
                if self.moveButton then
                    self.moveButton:SetShown(false)
                end
            end)
        end
    end

    hooksecurefunc('PlayerFrame_ToPlayerArt', function()
        C_Timer.After(0.5, set_classPowerBar)
    end)

    set_Move_Frame(LootFrame, {save=false})--物品拾取

    --################################
    --场景 self==ObjectiveTrackerFrame
    --Blizzard_ObjectiveTracker.lua ObjectiveTracker_GetVisibleHeaders()
    hooksecurefunc('ObjectiveTracker_Initialize', function(self)
        for _, module in ipairs(self.MODULES) do
            set_Move_Frame(module.Header, {frame=self, notZoom=true})
        end
        self:SetClampedToScreen(false)
    end)

    --if Save.SavePoint then--在指定位置,显示
    hooksecurefunc('UpdateUIPanelPositions',function(currentFrame)
        if not UnitAffectingCombat('player') then
            set_Frame_Point(currentFrame)
        end
    end)
    --end

    --职业，能量条
    if TotemFrame then
        TotemFrame:HookScript('OnEvent', function()
            set_classPowerBar()
        end)
    end
    panel:RegisterUnitEvent('UNIT_DISPLAYPOWER', "player")
    panel:RegisterEvent('PLAYER_TALENT_UPDATE')

    C_Timer.After(2, function()
        created_Move_Button(QueueStatusButton, {save=true, notZoom=true, show=true})--小眼睛, 

        --编辑模式
        hooksecurefunc(EditModeManagerFrame, 'ExitEditMode', function()
            set_classPowerBar()--职业，能量条
            created_Move_Button(QueueStatusButton, {save=true, notZoom=true, show=true})--小眼睛, 
       end)
    end)


    set_Move_Frame(GameMenuFrame, {notSave=true})--菜单
    set_Move_Frame(ExtraActionButton1, {click='RightButton', notSave=true})--额外技能
    set_Move_Frame(ContainerFrameCombinedBags)
    set_Move_Frame(MirrorTimer1, {notSave=true})
    set_Move_Frame(ColorPickerFrame, {click='RightButton'})--颜色选择器
    set_Move_Frame(PartyFrame.Background, {frame=PartyFrame, notZoom=true, notSave=true})
    set_Move_Frame(OpacityFrame)
    set_Move_Frame(ArcheologyDigsiteProgressBar, {notZoom=true})
    set_Move_Frame(VehicleSeatIndicator)
    set_Move_Frame(ExpansionLandingPage)
    set_Move_Frame(PlayerPowerBarAlt)
    set_Move_Frame(CreateChannelPopup)
    set_Move_Frame(BattleTagInviteFrame)
    for text, _ in pairs(UIPanelWindows) do
        local frame=_G[text]
        if frame and (not frame.ResizeButton and not frame.targetMoveFrame) then
            set_Move_Frame(_G[text])
        end
    end
end
















--###########
--添加控制面板
--###########
local Category, Layout= e.AddPanel_Sub_Category({name= '|TInterface\\Cursor\\UI-Cursor-Move:0|t'..addName})
local function Init_Options()
    e.AddPanel_Header(Layout, e.onlyChinese and '选项' or OPTIONS)

    --移动
    local initializer2= e.AddPanel_Check({
        name= '|TInterface\\Cursor\\UI-Cursor-Move:0|t'..(e.onlyChinese and '移动' or NPE_MOVE),
        tooltip= e.cn(addName),
        value= not Save.disabledMove,
        category= Category,
        func= function()
            Save.disabledMove= not Save.disabledMove and true or nil
            print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabledMove), e.onlyChinese and '重新加载UI' or RELOADUI)
        end
    })

    local initializer= e.AddPanel_Check_Button({
        checkName= '|cnRED_FONT_COLOR:'..(e.onlyChinese and '保存位置' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SAVE, CHOOSE_LOCATION:gsub(CHOOSE , ''))),
        tooltip= '|cnRED_FONT_COLOR:'..(e.onlyChinese and '危险！' or VOICEMACRO_1_Sc_0),
        checkValue= Save.SavePoint,
        checkFunc=function()
            Save.SavePoint= not Save.SavePoint and true or nil
        end,
        buttonText= e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
        buttonFunc= function()
            StaticPopupDialogs[id..addName..'MoveZoomClearPoint']= {
                text =id..' '..addName..'|n|n'
                ..(e.onlyChinese and '保存位置' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SAVE, CHOOSE_LOCATION:gsub(CHOOSE , ''))),
                button1 = '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2),
                button2 = e.onlyChinese and '取消' or CANCEL,
                whileDead=true, hideOnEscape=true, exclusive=true,
                OnAccept=function()
                    Save.point={}
                    print(id, e.cn(addName), e.onlyChinese and '重设到默认位置' or HUD_EDIT_MODE_RESET_POSITION, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD))
                end,
            }
            StaticPopup_Show(id..addName..'MoveZoomClearPoint')
        end,
        layout= Layout,
        category=Category,
    })
    initializer:SetParentInitializer(initializer2, function() return not Save.disabledMove end)

        initializer= e.AddPanel_Check({
            name= e.onlyChinese and '可以移到屏幕外' or 'Can be moved off screen',
            tooltip= e.cn(addName),
            value= Save.moveToScreenFuori,
            category= Category,
            func= function()
                Save.moveToScreenFuori= not Save.moveToScreenFuori and true or nil
            end
        })
        initializer:SetParentInitializer(initializer2, function() if Save.disabledMove then return false else return true end end)

    --缩放
    initializer2= e.AddPanel_Check_Button({
        checkName= '|A:UI-HUD-Minimap-Zoom-In:0:0|a'..(e.onlyChinese and '缩放' or UI_SCALE),
        checkValue= not Save.disabledZoom,
        checkFunc= function()
            Save.disabledZoom= not Save.disabledZoom and true or nil
            print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabledZoom), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,

        buttonText= (e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2),
        buttonFunc= function()
            StaticPopupDialogs[id..addName..'MoveZoomClearZoom']= {
                text =id..' '..addName..'|n|n'
                ..('|A:UI-HUD-Minimap-Zoom-In:0:0|a'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)),
                button1 = '|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '缩放' or UI_SCALE),
                button2 = e.onlyChinese and '取消' or CANCEL,
                button3=  '|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '大小' or 'Size'),
                whileDead=true, hideOnEscape=true, exclusive=true,
                OnAccept=function()
                    Save.scale={}
                    print(id, e.cn(addName), (e.onlyChinese and '缩放' or UI_SCALE)..': 1', '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD))
                end,
                OnAlt=function()
                    Save.size={}
                    Save.disabledSize={}
                    print(id, e.cn(addName), e.onlyChinese and '大小' or 'Size', '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD))
                end,
            }
            StaticPopup_Show(id..addName..'MoveZoomClearZoom')
        end,

        tooltip= e.cn(addName),
        layout= Layout,
        category= Category
    })

    initializer= e.AddPanel_Check_Sider({
        checkName= e.onlyChinese and '移动时Frame透明' or MAP_FADE_TEXT:gsub(WORLD_MAP, 'Frame'),
        checkValue= not Save.notAlpha,
        checkTooltip= e.onlyChinese and '当你开始移动时，Frame变为透明状态。' or OPTION_TOOLTIP_MAP_FADE:gsub(string.lower(WORLD_MAP), 'Frame'),
        checkFunc= function()
            print(id, e.cn(addName), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,
        sliderValue= Save.alpha or 0.5,
        sliderMinValue= 0,
        sliderMaxValue= 1,
        sliderStep= 0.1,
        siderName= nil,
        siderTooltip= nil,
        siderFunc= function(_, _, value2)
            Save.alpha= e.GetFormatter1to10(value2, 0, 1)
        end,
        layout= Layout,
        category= Category,
    })
    initializer:SetParentInitializer(initializer2, function() if Save.disabledZoom then return false else return true end end)
    --窗口大小
    --[[e.AddPanel_Check({
        name= '|TInterface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up:0|t'..(e.onlyChinese and '窗口大小' or 'Window Size'),
        tooltip= e.cn(addName),
        value= not Save.disabledResizable,
        category= Category,
        func= function()
            Save.disabledResizable= not Save.disabledResizable and true or nil
            print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabledResizable), e.onlyChinese and '重新加载UI' or RELOADUI)
        end
    })]]

end



--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

local eventTab={}
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            Save.scale= Save.scale or {}
            Save.size= Save.size or {}
            Save.disabledSize= Save.disabledSize or {}
            Save.disabledAlpha= Save.disabledAlpha or {}
            Save.alpha= Save.alpha or 0.5

            e.AddPanel_Check({
                name= e.onlyChinese and '启用' or ENABLE,
                tooltip= e.cn(addName),
                value= not Save.disabled,
                category= Category,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init_Move()--初始, 移动
                for _, ent in pairs(eventTab or {}) do
                    setAddLoad(ent)
                end
            end
            eventTab=nil

        elseif arg1=='Blizzard_Settings' then
            Init_Options()--初始, 选项

        else
            if eventTab then
                table.insert(eventTab, arg1)
            else
                setAddLoad(arg1)
            end
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    --[[elseif event=='PLAYER_REGEN_ENABLED' then
        if combatCollectionsJournal then
            set_Move_CollectionJournal()--藏品
        end
        panel:UnregisterEvent('PLAYER_REGEN_ENABLED')]]

    elseif event=='UNIT_DISPLAYPOWER' or event=='PLAYER_TALENT_UPDATE' then
        C_Timer.After(0.5, set_classPowerBar)
    end

end)
--[[--缩放
    br:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    br:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    br:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
]]