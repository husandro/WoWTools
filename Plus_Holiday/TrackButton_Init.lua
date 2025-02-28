local e= select(2, ...)
local function Save()
    return WoWTools_HolidayMixin.Save
end
local TrackButton









local function Init_Menu(self, root)
    local sub

    root:CreateCheckbox(
        e.onlyChinese and '显示' or SHOW,
    function()
        return not Save().hide
    end, function()
        Save().hide= not Save().hide and true or nil
        WoWTools_HolidayMixin:TrackButtonSetText()
        TrackButton:set_Events()--设置事件
        TrackButton:set_Shown()
    end)

    root:CreateDivider()
    root:CreateCheckbox(
        e.onlyChinese and '左' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT,
    function()
        return not Save().left
    end, function()
        Save().left= not Save().left and true or nil
        for _, btn in pairs(TrackButton.btn) do
            btn.text:ClearAllPoints()
            btn:set_text_point()
        end
        WoWTools_HolidayMixin:TrackButtonSetText()
    end)

    root:CreateCheckbox(
        e.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP,
    function()
        return Save().toTopTrack
    end, function()
        Save().toTopTrack = not Save().toTopTrack and true or nil
        local last
        for index= 1, #TrackButton.btn do
            local btn=TrackButton.btn[index]
            btn:ClearAllPoints()
            if Save().toTopTrack then
                btn:SetPoint('BOTTOM', last or TrackButton, 'TOP')
            else
                btn:SetPoint('TOP', last or TrackButton, 'BOTTOM')
            end
            last=btn
        end
        WoWTools_HolidayMixin:TrackButtonSetText()
    end)

    root:CreateCheckbox(
        e.onlyChinese and '仅限: 正在活动' or LFG_LIST_CROSS_FACTION:format(CALENDAR_TOOLTIP_ONGOING),
    function()
        return Save().onGoing
    end, function()
        Save().onGoing= not Save().onGoing and true or nil
        WoWTools_HolidayMixin:TrackButtonSetText()
    end)

    root:CreateCheckbox(
        e.onlyChinese and '时间' or TIME_LABEL,
    function()
        return Save().showDate
    end, function()
        Save().showDate= not Save().showDate and true or nil
        WoWTools_HolidayMixin:TrackButtonSetText()
    end)

--打开选项界面
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_HolidayMixin.addName})
    --缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().scale or 1
    end, function(value)
        Save().scale=value
        self:set_Scale()
        self:set_Tooltips()
    end)
end











local function Init()
    TrackButton= WoWTools_ButtonMixin:Cbtn(nil, {size=18, isType2=true, name='WoWToolsHolidayTrackButton'})
    WoWTools_HolidayMixin.TrackButton= TrackButton

    TrackButton.texture=TrackButton:CreateTexture()
    TrackButton.texture:SetAllPoints()
    TrackButton.texture:SetAlpha(0.5)
    TrackButton.texture:SetAtlas(e.Icon.icon)

    TrackButton.Frame= CreateFrame('Frame',nil, TrackButton)
    TrackButton.Frame:SetPoint('BOTTOM')
    TrackButton.Frame:SetSize(1,1)

    TrackButton.btn={}

    TrackButton:RegisterForDrag("RightButton")
    TrackButton:SetMovable(true)
    TrackButton:SetClampedToScreen(true)
    TrackButton:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    TrackButton:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save().point={self:GetPoint(1)}
        Save().point[2]=nil
    end)

    function TrackButton:set_Events()--设置事件
        if Save().hide then
            self:UnregisterAllEvents()
        else
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:RegisterEvent('ZONE_CHANGED_NEW_AREA')

            self:RegisterEvent('PLAYER_REGEN_DISABLED')
            self:RegisterEvent('PLAYER_REGEN_ENABLED')

            self:RegisterEvent('PET_BATTLE_OPENING_DONE')
			self:RegisterEvent('PET_BATTLE_CLOSE')

            self:RegisterUnitEvent('UNIT_EXITED_VEHICLE', 'player')
            self:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', 'player')

            self:RegisterEvent('CALENDAR_UPDATE_EVENT_LIST')
            self:RegisterEvent('CALENDAR_UPDATE_EVENT')
            self:RegisterEvent('CALENDAR_NEW_EVENT')
            self:RegisterEvent('CALENDAR_OPEN_EVENT')
            self:RegisterEvent('CALENDAR_CLOSE_EVENT')
        end
    end

    TrackButton:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_ENTERING_WORLD'
            or event=='ZONE_CHANGED_NEW_AREA'
            or event=='PLAYER_REGEN_DISABLED'
            or event=='PLAYER_REGEN_ENABLED'
            or event=='PET_BATTLE_OPENING_DONE'
            or event=='PET_BATTLE_CLOSE'
            or event=='UNIT_ENTERED_VEHICLE'
            or event=='UNIT_EXITED_VEHICLE'
        then
            self:set_Shown()
        else
            WoWTools_HolidayMixin:TrackButtonSetText()
        end
    end)



    function TrackButton:set_Shown()
        local hide= IsInInstance()
            or C_PetBattles.IsInBattle()
            or UnitInVehicle('player')
            or UnitAffectingCombat('player')

        self:SetShown(not hide)
        self.texture:SetShown(Save().hide and true or false)
        self.Frame:SetShown(not hide and not Save().hide)
    end


    function TrackButton:set_Scale()
        self.Frame:SetScale(Save().scale or 1)
    end


    function TrackButton:set_Tooltips()
        if self.monthOffset and self.day then
            CalendarDayButton_OnEnter(self)
            e.tips:AddLine(' ')
        else
            if Save().left then
                e.tips:SetOwner(self, "ANCHOR_LEFT")
            else
                e.tips:SetOwner(self, "ANCHOR_RIGHT")
            end
            e.tips:ClearLines()
        end
        e.tips:AddDoubleLine(e.onlyChinese and '打开/关闭日历' or GAMETIME_TOOLTIP_TOGGLE_CALENDAR, e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_HolidayMixin.addName)
        e.tips:Show()
    end
    TrackButton:SetScript('OnMouseUp', ResetCursor)
    TrackButton:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        elseif d=='LeftButton' then
            Calendar_Toggle()

        elseif d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)

    TrackButton:SetScript('OnMouseWheel', function(self, d)--缩放
        if IsAltKeyDown() then
            local sacle=Save().scale or 1
            if d==1 then
                sacle=sacle+0.05
            elseif d==-1 then
                sacle=sacle-0.05
            end
            if sacle>4 then
                sacle=4
            elseif sacle<0.4 then
                sacle=0.4
            end
            Save().scale=sacle
            self:set_Scale()
            self:set_Tooltips()
        end
    end)
    TrackButton:SetScript('OnLeave', function(self)
        e.tips:Hide()
        --self.texture:SetAlpha(0.5)
    end)
    TrackButton:SetScript('OnEnter', function(self)
        self:set_Tooltips()
        --self.texture:SetAlpha(1)
    end)

    function TrackButton:set_point()--设置, 位置
        self:ClearAllPoints()
        if Save().point then
            self:SetPoint(Save().point[1], UIParent, Save().point[3], Save().point[4], Save().point[5])
        elseif e.Player.husandro then
            self:SetPoint('TOPLEFT', 250, 0)
        else
            self:SetPoint('BOTTOMRIGHT', _G['!KalielsTrackerFrame'] or ObjectiveTrackerBlocksFrame, 'TOPLEFT', -35, -10)
        end
    end



    TrackButton:set_point()
    TrackButton:set_Scale()
    TrackButton:set_Shown()
    TrackButton:set_Events()
    WoWTools_HolidayMixin:TrackButtonSetText()

    hooksecurefunc('CalendarDayButton_Click', function(button)
        WoWTools_HolidayMixin:TrackButtonSetText(button.monthOffset, button.day)
    end)
    CalendarFrame:HookScript('OnHide', function()
        WoWTools_HolidayMixin:TrackButtonSetText()
        WoWTools_HolidayMixin:SetTrackButtonState(false)--TrackButton，提示
    end)
    CalendarFrame:HookScript('OnShow', function()
        WoWTools_HolidayMixin:SetTrackButtonState(true)--TrackButton，提示
        C_Timer.After(2, function()
            WoWTools_HolidayMixin:SetTrackButtonState(false)
        end)
    end)
end












--TrackButton，提示
function WoWTools_HolidayMixin:SetTrackButtonState(show, text)
    if TrackButton then
		TrackButton:SetButtonState(show and 'PUSHED' or "NORMAL")
	end
    if text then
		text:SetAlpha(show and 0.5 or 1)
	end
end


function WoWTools_HolidayMixin:Init_TrackButton()
    Init()
end
function WoWTools_HolidayMixin:Init_Menu(frame)
    MenuUtil.CreateContextMenu(frame, Init_Menu)
end