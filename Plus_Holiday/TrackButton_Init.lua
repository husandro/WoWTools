
local function Save()
    return WoWToolsSave['Plus_Holiday']
end
local TrackButton









local function Init_Menu(self, root)
    local sub

    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '显示' or SHOW,
    function()
        return not Save().hide
    end, function()
        Save().hide= not Save().hide and true or nil
        WoWTools_HolidayMixin:TrackButtonSetText()
        TrackButton:set_Events()--设置事件
        TrackButton:set_Shown()
    end)


    sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '左' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT,
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

    sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP,
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

    sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '仅限: 正在活动' or LFG_LIST_CROSS_FACTION:format(CALENDAR_TOOLTIP_ONGOING),
    function()
        return Save().onGoing
    end, function()
        Save().onGoing= not Save().onGoing and true or nil
        WoWTools_HolidayMixin:TrackButtonSetText()
    end)

    sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '时间' or TIME_LABEL,
    function()
        return Save().showDate
    end, function()
        Save().showDate= not Save().showDate and true or nil
        WoWTools_HolidayMixin:TrackButtonSetText()
    end)

    sub:CreateDivider()
--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().scale or 1
    end, function(value)
        Save().scale=value
        self:set_Scale()
        self:set_Tooltips()
    end)

--FrameStrata    
    WoWTools_MenuMixin:FrameStrata(sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().strata= data
        self:set_strata()
    end)

--重置位置
	sub:CreateDivider()
	WoWTools_MenuMixin:RestPoint(self, sub, Save().point, function()
		Save().point=nil
		self:set_point()
		print(WoWTools_DataMixin.Icon.icon2..WoWTools_HolidayMixin.addName, WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION)
	end)

    root:CreateDivider()
    --打开选项界面
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_HolidayMixin.addName})
end











local function Init()
    TrackButton= WoWTools_ButtonMixin:Cbtn(nil, {size=23,  name='WoWToolsHolidayTrackButton'})
    WoWTools_HolidayMixin.TrackButton= TrackButton

    TrackButton.texture= TrackButton:CreateTexture(nil, 'BORDER')
    TrackButton.texture:SetAtlas('Adventure-MissionEnd-Line')
    TrackButton.texture:SetPoint('CENTER')
    TrackButton.texture:SetSize(12,10)

--显示背景 Background
    --WoWTools_TextureMixin:CreateBackground(TrackButton.Frame)

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
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            self:StopMovingOrSizing()
            Save().point={self:GetPoint(1)}
            Save().point[2]=nil
        else
            print(
                WoWTools_DataMixin.addName,
                '|cnRED_FONT_COLOR:',
                WoWTools_DataMixin.onlyChinese and '保存失败' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SAVE, FAILED)
            )
        end
        self:Raise()
    end)

    function TrackButton:set_Events()--设置事件
        if Save().hide then
            self:UnregisterAllEvents()
        else
            self:RegisterEvent('LOADING_SCREEN_DISABLED')
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
        if event=='LOADING_SCREEN_DISABLED'
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
        self.texture:SetAlpha(Save().hide and 0.7 or 0.3)
        self.Frame:SetShown(not hide and not Save().hide)
    end


    function TrackButton:set_Scale()
        self.Frame:SetScale(Save().scale or 1)
    end


    function TrackButton:set_Tooltips()
        if self.monthOffset and self.day then
            CalendarDayButton_OnEnter(self)
            GameTooltip:AddLine(' ')
        else
            if Save().left then
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            else
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            end
            GameTooltip:ClearLines()
        end
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '打开/关闭日历' or GAMETIME_TOOLTIP_TOGGLE_CALENDAR, WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_HolidayMixin.addName)
        GameTooltip:Show()
    end
    TrackButton:SetScript('OnMouseUp', ResetCursor)
    TrackButton:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        elseif d=='LeftButton' then
            Calendar_Toggle()

        elseif d=='RightButton' then
            MenuUtil.CreateContextMenu(self, function(...)
                Init_Menu(...)
            end)
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
    TrackButton:SetScript('OnLeave', GameTooltip_Hide)
    TrackButton:SetScript('OnEnter', TrackButton.set_Tooltips)

    function TrackButton:set_point()--设置, 位置
        self:ClearAllPoints()
        if Save().point then
            self:SetPoint(Save().point[1], UIParent, Save().point[3], Save().point[4], Save().point[5])
        else
            self:SetPoint('TOPLEFT', 400, WoWTools_DataMixin.Player.husandro and 0 or -100)
        end
    end


	function TrackButton:set_strata()
        self:SetFrameStrata(Save().strata or 'MEDIUM')
    end

    TrackButton:set_strata()
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