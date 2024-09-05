
--[[
时间 Pluse
Blizzard_TimeManager.lua

TimeManagerClockButtonScale=1缩放
TimeManagerClockButtonPoint={}位置

时钟
useServerTimer=true,小时图，使用服务器, 时间
TimeManagerClockButtonScale=1缩放
TimeManagerClockButtonPoint={}位置

秒表

disabledClockPlus=true,时钟，秒表
disabledClockPlus=true,禁用plus
showStopwatchFrame=true,加载游戏时，显示秒表
StopwatchFrameScale=1,缩放
StopwatchOnClickPause=true,--移过暂停
]]
local e= select(2, ...)
local addName

local Save= function()
    return  WoWTools_MinimapMixin.Save
end




















--秒表
local function Init_Stopwatch_Menu(_, root)
--plus
    local sub=root:CreateCheckbox('|TInterface\\Icons\\INV_Misc_PocketWatch_01:0:|t Plus', function()
        return not Save().disabledClockPlus
    end, function()
        Save().disabledClockPlus= not Save().disabledClockPlus and true or nil
        print(e.addName, addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)


--重新加载
    WoWTools_MenuMixin:Reload(sub, nil)
    sub:CreateDivider()
    WoWTools_MinimapMixin:OpenPanel(sub)

    if Save().disabledClockPlus then
        return
    end

    root:CreateDivider()
    root:CreateCheckbox(
        e.Icon.left..(e.onlyChinese and '开始/暂停' or NEWBIE_TOOLTIP_STOPWATCH_PLAYPAUSEBUTTON),
    function()
        return Save().StopwatchOnClickPause
    end, function()
        Save().StopwatchOnClickPause= not Save().StopwatchOnClickPause and true or nil
        if StopwatchFrame.set_onclick_pause then
            StopwatchFrame:set_onclick_pause()
        else
            StopwatchTitle:SetText(e.onlyChinese and '秒表' or STOPWATCH_TITLE)
        end
    end)

--显示背景
    WoWTools_MenuMixin:ShowBackground(root,
    function()
        return Save().isShowStopwatchBackground
    end, function()
        Save().isShowStopwatchBackground= not Save().isShowStopwatchBackground and true or nil
        if StopwatchFrame.set_background then
            StopwatchFrame:set_background()
        end
    end)


--缩放
    WoWTools_MenuMixin:Scale(root, function()
        return Save().StopwatchFrameScale
    end, function(value)
        Save().StopwatchFrameScale= value
        if StopwatchFrame.set_scale then
            StopwatchFrame:set_scale()
        end
    end)

--FrameStrata
    WoWTools_MenuMixin:FrameStrata(root, function(data)
        return StopwatchFrame:GetFrameStrata()==data
    end, function(data)
        Save().stopwatchFrameStrata= data
        if StopwatchFrame.set_strata then
            StopwatchFrame:set_strata()
        end
    end)


--重置位置
    root:CreateDivider()
    WoWTools_MenuMixin:RestPoint(root, Save().TimeManagerClockButtonPoint, function()
        if StopwatchFrame.rest_point then
            StopwatchFrame:rest_point()
        end
    end)
end






















--时间信息
local function Init_TimeManager_Menu(self, root)
--plus
    local sub=root:CreateCheckbox('|A:auctionhouse-icon-clock:0:0:|a Plus', function()
        return not Save().disabledClockPlus
    end, function()
        Save().disabledClockPlus= not Save().disabledClockPlus and true or nil
        print(e.addName, addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

--重新加载
    WoWTools_MenuMixin:Reload(sub, nil)
    sub:CreateDivider()
    WoWTools_MinimapMixin:OpenPanel(sub)

    if not Save().disabledClockPlus then
    --显示背景
        root:CreateDivider()
        WoWTools_MenuMixin:ShowBackground(
            root,
        function()
            return Save().isShowTimeManagerBackground
        end, function()
            Save().isShowTimeManagerBackground= not Save().isShowTimeManagerBackground and true or nil
            if TimeManagerClockButton.set_background then
                TimeManagerClockButton:set_background()
            end
        end)

    --缩放
        WoWTools_MenuMixin:Scale(root, function()
            return Save().TimeManagerClockButtonScale
        end, function(value)
            Save().TimeManagerClockButtonScale= value
            if TimeManagerClockButton.set_scale then
                TimeManagerClockButton:set_scale()
            end
        end)

    --FrameStrata
        WoWTools_MenuMixin:FrameStrata(root, function(data)
            return TimeManagerClockButton:GetFrameStrata()==data
        end, function(data)
            Save().TimeManagerClockButtonStrata= data
            if TimeManagerClockButton.set_strata then
                TimeManagerClockButton:set_strata()
            end
        end)


    --重置位置
        WoWTools_MenuMixin:RestPoint(root, Save().TimeManagerClockButtonPoint,  WoWTools_MinimapMixin.Rest_TimeManager_Point)
    end

--秒表
    root:CreateDivider()
    sub=root:CreateCheckbox(
        '|TInterface\\Icons\\INV_Misc_PocketWatch_01:0:|t'
        --..(self==StopwatchFrame and '|cnGREEN_FONT_COLOR:' )
        ..(e.onlyChinese and '秒表' or STOPWATCH_TITLE),
    function()
        return StopwatchFrame:IsShown()
    end, function()
        e.call(Stopwatch_Toggle)
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '显示/隐藏' or (SHOW..'/'..HIDE))
    end)
    Init_Stopwatch_Menu(self, sub)
end



























--[[
local function Init_Menu(self, root)
    local sub

--时间信息  
    sub=root:CreateButton(
        '|A:auctionhouse-icon-clock:0:0:|a'
        ..(self==TimeManagerClockButton and '|cnGREEN_FONT_COLOR:' or '')
        ..(e.onlyChinese and '时间信息' or TIMEMANAGER_TOOLTIP_TITLE),
    function()
        return MenuResponse.Open
    end)
    Init_TimeManager_Menu(self, sub)

--秒表
    root:CreateDivider()
    sub=root:CreateCheckbox(
        '|TInterface\\Icons\\INV_Misc_PocketWatch_01:0:|t'
        --..(self==StopwatchFrame and '|cnGREEN_FONT_COLOR:' )
        ..(e.onlyChinese and '秒表' or STOPWATCH_TITLE),
    function()
        return StopwatchFrame:IsShown()
    end, function()
        e.call(Stopwatch_Toggle)
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '显示/隐藏' or (SHOW..'/'..HIDE))
    end)
    Init_Stopwatch_Menu(self, sub)
end
]]






























local function Init_TimeManager()
    local btn= TimeManagerClockButton



--FrameStrata
    function btn:set_strata()
        local strata= Save().TimeManagerClockButtonStrata
        if strata and Save().TimeManagerClockButtonPoint then
            self:SetFrameStrata(strata)
        end
    end
    btn:set_strata()


--时钟，设置位置
    btn.rePoint={btn:GetPoint(1)}
    btn:SetMovable(true)
    btn:SetClampedToScreen(true)
    btn:RegisterForDrag('RightButton')
    btn:HookScript("OnDragStart", function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    btn:HookScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save().TimeManagerClockButtonPoint={self:GetPoint(1)}
        Save().TimeManagerClockButtonPoint[2]=nil
        self:set_strata()
    end)
    btn:SetScript('OnMouseUp', ResetCursor)
    btn:HookScript('OnMouseDown', function(_, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        end
    end)

    function btn:rest_point()
        TimeManagerClockButton:ClearAllPoints()
        TimeManagerClockButton:SetParent(MinimapCluster)
        TimeManagerClockButton:SetFrameStrata('MEDIUM')
        TimeManagerClockButton:SetPoint(self.rePoint[1], self.rePoint[2], self.rePoint[3], self.rePoint[4], self.rePoint[5])
        --TimeManagerClockButton:SetPoint('TOPRIGHT', MinimapCluster.BorderTop ,-4, 0)
    end
    btn.width= btn:GetWidth()
    function btn:set_point()
        local point= Save().TimeManagerClockButtonPoint
        if point then
            TimeManagerClockTicker:SetPoint('CENTER')
            self:SetWidth(self.width+5)
            self:SetParent(UIParent)
            self:ClearAllPoints()
            self:SetPoint(point[1], UIParent, point[3], point[4], point[5])
        end
    end
    btn:set_point()


--时钟，缩放
    btn:EnableMouseWheel(true)
    btn:HookScript('OnMouseWheel', function(self, d)
        Save().TimeManagerClockButtonScale=WoWTools_FrameMixin:ScaleFrame(self, d, Save().TimeManagerClockButtonScale, nil)
        e.call(TimeManagerClockButton_UpdateTooltip)
    end)
    function btn:set_scale()
        self:SetScale(Save().TimeManagerClockButtonScale or 1)
    end
    btn:set_scale()


--PushedTexture
    WoWTools_ButtonMixin:SetPushedTexture(btn, false)
    btn:HookScript('OnLeave', ResetCursor)
    btn:HookScript('OnEnter', TimeManagerClockButton_UpdateTooltip)


    --设置，时间，颜色
    TimeManagerClockTicker:SetShadowOffset(1, -1)
    e.Set_Label_Texture_Color(TimeManagerClockTicker, {type='FontString', alpha=1})--设置颜色


    --[[小时图，使用服务器, ServerTime
    btn.TimeManagerClockButton_Update_R= TimeManagerClockButton_Update
    function btn:set_Server_Timer()--小时图，使用服务器, 时间
        if Save().useServerTimer then
            TimeManagerClockButton_Update=function()
                TimeManagerClockTicker:SetText(e.SecondsToClock(C_DateAndTime.GetServerTimeLocal(), true, true))
            end
        else
            TimeManagerClockButton_Update= self.TimeManagerClockButton_Update_R
        end
        e.call(TimeManagerClockButton_Update)
    end
    if Save().useServerTimer then
        btn:set_Server_Timer()
    end]]


--[[显示秒
    if Save().isTimeManagerShowSeconds then
        btn.elapsed=1
        btn:HookScript('OnUpdate', function(self, elapsed)
            self.elapsed= self.elapsed+elapsed
            if self.elapsed>1 then
                self.elapsed=0
                TimeManagerClockButton_Update()
            end
        end)
    end]]



--显示背景
    WoWTools_FrameMixin:CreateBackground(btn, function(texture)
        texture:SetPoint('TOPLEFT', TimeManagerClockTicker, -1, -1)
        texture:SetPoint('BOTTOMRIGHT', TimeManagerClockTicker, 1, 0)
    end)
    function btn:set_background()
        self.Background:SetShown(Save().isShowTimeManagerBackground)
    end
    btn:set_background()
end




















--秒表
local function Init_StopwatchFrame()
--Tooltip
    function StopwatchFrame:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE or SLASH_TEXTTOSPEECH_MENU, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save().StopwatchFrameScale or 1), 'Alt+'..e.Icon.mid)
        e.tips:AddDoubleLine('|A:dressingroom-button-appearancelist-up:0:0|a'..(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL), e.Icon.right)
        if Save().StopwatchOnClickPause then
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(
                (e.onlyChinese and '开始/暂停' or NEWBIE_TOOLTIP_STOPWATCH_PLAYPAUSEBUTTON),
                e.Icon.left
            )
        end
        e.tips:Show()
    end
    StopwatchFrame:HookScript('OnLeave', function()
        e.tips:Hide()
        StopwatchResetButton:SetAlpha(StopwatchResetButton.alpha or 1)
        ResetCursor()

    end)
    StopwatchFrame:HookScript('OnEnter', function(self)
        StopwatchResetButton:SetAlpha(1)
        self:set_tooltip()
    end)


--缩放
    function StopwatchFrame:set_scale()
        self:SetScale(Save().StopwatchFrameScale or 1)
    end
    StopwatchFrame:EnableMouseWheel(true)
    StopwatchFrame:SetScript('OnMouseWheel', function(self, d)
        Save().StopwatchFrameScale=WoWTools_FrameMixin:ScaleFrame(self, d, Save().StopwatchFrameScale, nil)
    end)
    StopwatchFrame:set_scale()


--FrameStrata
    function StopwatchFrame:set_strata()
        local strata= Save().stopwatchFrameStrata
        if strata then
            self:SetFrameStrata(strata)
        end
    end
    StopwatchFrame:set_strata()


--加载游戏时，显示秒表
    StopwatchFrame:HookScript('OnShow', function()
        Save().showStopwatchFrame=true
    end)

    StopwatchFrame:HookScript('OnHide', function()
        Save().showStopwatchFrame=nil
    end)
    if Save().showStopwatchFrame and not StopwatchFrame:IsShown() then
        e.call(Stopwatch_Toggle)
    end


--移动
    function StopwatchFrame:rest_point()
        StopwatchFrame:ClearAllPoints()
        StopwatchFrame:SetPoint("TOPRIGHT", UIParent, -250, -300);
    end
    StopwatchFrame:RegisterForDrag('RightButton')
    StopwatchFrame:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    StopwatchFrame:SetScript('OnMouseUp', ResetCursor)
    StopwatchFrame:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        elseif d=='LeftButton' then
            if Save().StopwatchOnClickPause then
                do
                    e.call(StopwatchPlayPauseButton_OnClick, StopwatchPlayPauseButton)--开始/暂停
                end
            end
        elseif d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Stopwatch_Menu)
        end
    end)


--开始/暂停，颜色, 提示
    StopwatchCloseButton:ClearAllPoints()
    StopwatchCloseButton:SetPoint('TOPLEFT')

    StopwatchTitle:SetPoint('LEFT', StopwatchCloseButton, 'RIGHT')
    StopwatchTickerHour:SetTextColor(0,1,0,1)
    StopwatchTickerMinute:SetTextColor(0,1,0,1)
    StopwatchTickerSecond:SetTextColor(0,1,0,1)
    StopwatchTickerHour:SetShadowOffset(1, -1)
    StopwatchTickerMinute:SetShadowOffset(1, -1)
    StopwatchTickerSecond:SetShadowOffset(1, -1)

    hooksecurefunc('Stopwatch_Pause', function()
        StopwatchTitle:SetText('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '暂停' or EVENTTRACE_BUTTON_PAUSE))
        StopwatchTickerHour:SetTextColor(0,1,0,1)
        StopwatchTickerMinute:SetTextColor(0,1,0,1)
        StopwatchTickerSecond:SetTextColor(0,1,0,1)
    end)
    hooksecurefunc('Stopwatch_Play', function()
        StopwatchTitle:SetText(e.Player.col..(e.onlyChinese and '开始' or START))
        e.Set_Label_Texture_Color(StopwatchTickerHour, {type='FontString'})
        e.Set_Label_Texture_Color(StopwatchTickerMinute, {type='FontString'})
        e.Set_Label_Texture_Color(StopwatchTickerSecond, {type='FontString'})
    end)
    hooksecurefunc('Stopwatch_Clear', function()
        StopwatchTitle:SetText((e.onlyChinese and '重置' or RESET))
        StopwatchTickerHour:SetTextColor(1,1,1,1)
        StopwatchTickerMinute:SetTextColor(1,1,1,1)
        StopwatchTickerSecond:SetTextColor(1,1,1,1)
    end)


--设置，提示
    StopwatchPlayPauseButton:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(self.alpha or 1) end)
    StopwatchPlayPauseButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        if Stopwatch_IsPlaying() then
            e.tips:AddLine(e.onlyChinese and '暂停' or EVENTTRACE_BUTTON_PAUSE)
        else
            e.tips:AddLine(e.onlyChinese and '开始' or START)
        end
        e.tips:Show()
        self:SetAlpha(1)
    end)

    StopwatchResetButton:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(self.alpha or 1) end)
    StopwatchResetButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, Save().StopwatchOnClickPause and "ANCHOR_LEFT" or "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddLine(e.onlyChinese and '重置' or RESET)
        e.tips:Show()
        self:SetAlpha(1)
    end)

    function StopwatchFrame:set_onclick_pause()
        local show= not Save().StopwatchOnClickPause and true or false
        StopwatchResetButton:ClearAllPoints()
        if not show then
            StopwatchResetButton:SetPoint('RIGHT', StopwatchTickerHour, 'LEFT', -2, 3)
            StopwatchTicker:SetPoint('BOTTOMRIGHT')
            StopwatchCloseButton:SetPoint('TOPLEFT', 12,1)
        else
            StopwatchResetButton:SetPoint('BOTTOMRIGHT', -2, 3)
            StopwatchTicker:SetPoint('BOTTOMRIGHT', -49, 3)
            StopwatchCloseButton:SetPoint('TOPLEFT', -10, 1)
        end
        StopwatchResetButton.alpha= show and 1 or 0
        StopwatchResetButton:SetAlpha(StopwatchResetButton.alpha)
        StopwatchPlayPauseButton:SetShown(show)
    end
    if Save().StopwatchOnClickPause then
        StopwatchFrame:set_onclick_pause()
    end


--显示背景
    WoWTools_FrameMixin:CreateBackground(StopwatchFrame, function(texture)
        texture:SetPoint('TOPLEFT', StopwatchTickerHour, -1, -1.5)
        texture:SetPoint('BOTTOMRIGHT', StopwatchTickerSecond, 2, 0)
    end)
    function StopwatchFrame:set_background()
        self.Background:SetShown(Save().isShowStopwatchBackground)
    end
    StopwatchFrame:set_background()


    StopwatchFrame:SetWidth(100)
end




























function WoWTools_MinimapMixin:Init_TimeManager()
    addName= self.addName

    TimeManagerClockButton:SetScript('OnClick', function(frame, d)
        if d=='RightButton' and not IsAltKeyDown() then
            MenuUtil.CreateContextMenu(frame, Init_TimeManager_Menu)

        elseif d=='LeftButton' then
            e.call(TimeManager_Toggle)
        end
    end)

    hooksecurefunc('TimeManagerClockButton_UpdateTooltip', function()
        if Save().disabledClockPlus then
            e.tips:AddDoubleLine('|A:dressingroom-button-appearancelist-up:0:0|a'..(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL), e.Icon.right)
        else
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine('|cffffffff'..('ServerTime'), '|cnGREEN_FONT_COLOR:'..e.SecondsToClock(GetServerTime())..e.Icon.left)
            e.tips:AddDoubleLine('|A:dressingroom-button-appearancelist-up:0:0|a'..(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL), e.Icon.right)

            --e.tips:AddDoubleLine('|cffffffff'..(e.onlyChinese and '服务器时间' or TIMEMANAGER_TOOLTIP_REALMTIME), '|cnGREEN_FONT_COLOR:'..e.SecondsToClock(C_DateAndTime.GetServerTimeLocal(), true, true)..e.Icon.left)
            --e.tips:AddLine(' ')

            e.tips:AddDoubleLine('|cffffffff'..(e.onlyChinese and '移动' or NPE_MOVE), 'Alt+'..e.Icon.right)
            e.tips:AddDoubleLine('|cffffffff'..((e.onlyChinese and '缩放' or UI_SCALE))..' |cnGREEN_FONT_COLOR:'..(Save().TimeManagerClockButtonScale or 1), 'Alt+'..e.Icon.mid)
            --e.tips:AddDoubleLine(e.addName, addName)
        end
        e.tips:Show()
    end)


    if not self.Save.disabledClockPlus then
        Init_TimeManager()
    end

    if not self.Save.disabledClockPlus then
        Init_StopwatchFrame()
    end



end








--[[function WoWTools_MinimapMixin:Show_TimeManager_Menu(_, root)
    Init_Menu(_, root)
end]]

--重置，TimeManager位置
function WoWTools_MinimapMixin:Rest_TimeManager_Point()
    Save().TimeManagerClockButtonPoint=nil
    Save().TimeManagerClockButtonScale=nil
    Save().isShowTimeManagerBackground=nil
    if TimeManagerClockButton.rest_point then
        TimeManagerClockButton:rest_point()
        TimeManagerClockButton:set_scale()
        StopwatchFrame:set_background()
    end
end