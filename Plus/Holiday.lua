local id, e = ...
local addName= CALENDAR_FILTER_HOLIDAYS
local Save={
    onGoing=true,--仅限: 正在活动
    --disabled= not e.Player.husandro
    --left=e.Player.husandro,--内容靠左
    --toTopTrack=true,--向上
    --showDate= true,--时间
}
local panel= CreateFrame('Frame')
local TrackButton
local Initializer













local function _CalendarFrame_SafeGetName(name)
	if ( not name or name == "" ) then
		return e.onlyChinese and '未知' or UNKNOWN;
	end
	return name;
end

local function _CalendarFrame_IsPlayerCreatedEvent(calendarType)
	return
		calendarType == "PLAYER" or
		calendarType == "GUILD_ANNOUNCEMENT" or
		calendarType == "GUILD_EVENT" or
		calendarType == "COMMUNITY_EVENT";
end

local function _CalendarFrame_IsSignUpEvent(calendarType, inviteType)
	return (calendarType == "GUILD_EVENT" or calendarType == "COMMUNITY_EVENT") and inviteType == Enum.CalendarInviteType.Signup;
end

local CALENDAR_CALENDARTYPE_TOOLTIP_NAMEFORMAT = {
	["PLAYER"] = {
		[""]				= "%s",
	},
	["GUILD_ANNOUNCEMENT"] = {
		[""]				= "%s",
	},
	["GUILD_EVENT"] = {
		[""]				= "%s",
	},
	["COMMUNITY_EVENT"] = {
		[""]				= "%s",
	},
	["SYSTEM"] = {
		[""]				= "%s",
	},
	["HOLIDAY"] = {
		["START"]			= e.onlyChinese and '%s 开始' or CALENDAR_EVENTNAME_FORMAT_START,
		["END"]				= e.onlyChinese and '%s 结束' or CALENDAR_EVENTNAME_FORMAT_END,
		[""]				= "%s",
		["ONGOING"]			= "%s",
	},
	["RAID_LOCKOUT"] = {
		[""]				= e.onlyChinese and '%s解锁' or CALENDAR_EVENTNAME_FORMAT_RAID_LOCKOUT,
	},
};

local function set_Time_Color(eventTime, hour, minute, init)
    if hour and minute then
        local seconds= hour*3600 + minute*60
        local time= GetServerTime()
        if (init and time< seconds)
          or (not init and time> seconds)
        then
            return '|cff828282'..eventTime..'|r', false
        end
    end
    return eventTime, true
end

local function set_Quest_Completed(tab)--任务是否完成
    for _, questID in pairs(tab) do
        local completed= C_QuestLog.IsQuestFlaggedCompleted(questID)
        if completed then
            return format('|A:%s:0:0|a', e.Icon.select)
        end
    end
end

local CALENDAR_EVENTTYPE_TEXTURES = {
	[Enum.CalendarEventType.Raid]		= "Interface\\LFGFrame\\LFGIcon-Raid",
	[Enum.CalendarEventType.Dungeon]	= "Interface\\LFGFrame\\LFGIcon-Dungeon",
	--[Enum.CalendarEventType.PvP]		=  e.Player.faction=='Alliance' and "Interface\\Calendar\\UI-Calendar-Event-PVP02" or (e.Player.faction=='Horde' and "Interface\\Calendar\\UI-Calendar-Event-PVP01") or "Interface\\Calendar\\UI-Calendar-Event-PVP",
	[Enum.CalendarEventType.Meeting]	= "Interface\\Calendar\\MeetingIcon",
	[Enum.CalendarEventType.Other]		= "Interface\\Calendar\\UI-Calendar-Event-Other",
}






local function Get_Button_Text(event)
    local icon,atlas
    local findQuest
    local text
    local texture
    local title

    if e.HolidayEvent[event.eventID] then
        title=e.HolidayEvent[event.eventID][1]
    end
    title= title or e.cn(event.title)


    if _CalendarFrame_IsPlayerCreatedEvent(event.calendarType) then--自定义,事件
        local invitInfo= C_Calendar.EventGetInvite(event.index) or {}
        if invitInfo.guid then
            atlas= e.GetPlayerInfo({guid=invitInfo.guid, reAtlas=true})
        end
        if UnitIsUnit("player", event.invitedBy) then--我
            atlas= atlas or e.GetUnitRaceInfo({unit='player',reAtlas=true})
        else
            if _CalendarFrame_IsSignUpEvent(event.calendarType, event.inviteType) then
                local inviteStatusInfo = CalendarUtil.GetCalendarInviteStatusInfo(event.inviteStatus);
                if event.inviteStatus== Enum.CalendarStatus.NotSignedup or event.inviteStatus == Enum.CalendarStatus.Signedup then
                    text = inviteStatusInfo.name;
                else
                    text = format(e.onlyChinese and '已登记（%s）' or CALENDAR_SIGNEDUP_FOR_GUILDEVENT_WITH_STATUS, inviteStatusInfo.name);
                end
            else
                if ( event.calendarType == "GUILD_ANNOUNCEMENT" ) then
                    text = format(e.onlyChinese and '由%s创建' or CALENDAR_ANNOUNCEMENT_CREATEDBY_PLAYER, _CalendarFrame_SafeGetName(event.invitedBy));
                    atlas= 'communities-icon-chat'
                else
                    text = format( e.onlyChinese and '被%s邀请' or CALENDAR_EVENT_INVITEDBY_PLAYER, _CalendarFrame_SafeGetName(event.invitedBy));
                end
            end
            atlas= atlas or 'charactercreate-icon-dice'
        end


    elseif ( event.calendarType == "RAID_LOCKOUT" ) then
        title= format(
            CALENDAR_CALENDARTYPE_TOOLTIP_NAMEFORMAT[event.calendarType][event.sequenceType],
            GetDungeonNameWithDifficulty(title, event.difficultyName)
        )
        atlas='worldquest-icon-raid'

    elseif event.calendarType=='HOLIDAY' then
        if title:find(PLAYER_DIFFICULTY_TIMEWALKER) or--时空漫游
            event.eventID==1063 or
            event.eventID==616 or
            event.eventID==617 or
            event.eventID==623 or
            event.eventID==629 or
            event.eventID==643 or--熊猫人之迷
            event.eventID==654 or
            event.eventID==1068 or
            event.eventID==1277 or
            event.eventID==1269
        then

            local tab={40168, 40173, 40786, 45563, 55499, 40168, 40173, 40787, 45563, 55498, 64710,64709,
                72725,--迷离的时光之路 熊猫人之迷
            }
            local isCompleted= set_Quest_Completed(tab)--任务是否完成
            texture= isCompleted or '|A:AutoQuest-Badge-Campaign:0:0|a'
            title=(e.onlyChinese and '时空漫游' or PLAYER_DIFFICULTY_TIMEWALKER)
            findQuest= isCompleted and true or findQuest
            icon=463446--1166[时空扭曲徽章]

        elseif event.eventID==479 then--暗月--CALENDAR_FILTER_DARKMOON = "暗月马戏团"--515[暗月奖券]
            local tab={36471, 32175}
            local isCompleted= set_Quest_Completed(tab)--任务是否完成
            texture= isCompleted or '|A:AutoQuest-Badge-Campaign:0:0|a'
            findQuest=isCompleted and true or findQuest
            icon=134481

        elseif event.eventID==324 or event.eventID==1405 then--万圣节
            icon= 236546--33226[奶糖]
        elseif event.eventID==423 then--情人节
            icon=235468
        elseif event.eventID==181 then
            icon= 235477
        elseif event.eventID==691 then
            icon=1500867
        elseif event.iconTexture then
            icon=event.iconTexture
        end
    end


    if event.eventType== Enum.CalendarEventType.PvP or  title:find(PVP) or event.eventID==561 then
        atlas= 'pvptalents-warmode-swords'--pvp

    elseif event.calendarType=='HOLIDAY' and event.eventID then

        if event.title:find(PLAYER_DIFFICULTY_TIMEWALKER)--时空漫游
            or event.eventID==1063
            or event.eventID==616
            or event.eventID==617
            or event.eventID==623
            or event.eventID==629
            or event.eventID==643--熊猫人之迷
            or event.eventID==654
            or event.eventID==1068
            or event.eventID==1277
            or event.eventID==1269
         then

            local tab={40168, 40173, 40786, 45563, 55499, 40168, 40173, 40787, 45563, 55498, 64710,64709,
            72725,--迷离的时光之路 熊猫人之迷
            }
            local isCompleted= set_Quest_Completed(tab)--任务是否完成

            texture= isCompleted or '|A:AutoQuest-Badge-Campaign:0:0|a'
            findQuest= isCompleted
            icon=463446--1166[时空扭曲徽章]

        elseif event.eventID==479 then--暗月--CALENDAR_FILTER_DARKMOON = "暗月马戏团"
            local tab={36471, 32175}
            local isCompleted= set_Quest_Completed(tab)--任务是否完成
            texture= isCompleted or '|A:AutoQuest-Badge-Campaign:0:0|a'
            findQuest=isCompleted
            icon=134481--515[暗月奖券]

        elseif event.eventID==324 or event.eventID==1405 then--万圣节
            icon= 236546--33226[奶糖]
        elseif event.eventID==423 then--情人节
            icon=235468
        elseif event.eventID==181 then
            icon= 235477
        elseif event.eventID==691 then
            icon=1500867
        elseif event.iconTexture then
            icon=event.iconTexture
        end
    end
    title= e.cn(title:match(HEADER_COLON..'(.+)') or title)
    title= not event.isValid and '|cff606060'..title..'|r' or title
    local msg
    if Save.left then
        msg= ((Save.showDate and event.eventTime) and event.eventTime..' ' or '')
            ..(text and text..' ' or '')
            ..(texture or '')
            ..title
    else
        msg= title
            ..(texture or '')
            ..(text and ' '..text or '')
            ..((Save.showDate and event.eventTime) and ' '..event.eventTime or '')
    end

    icon= icon or CALENDAR_EVENTTYPE_TEXTURES[event.eventType]
    return msg, icon, atlas, findQuest
end





--TrackButton，提示
local function Set_TrackButton_Pushed(show, text)
	if TrackButton then
		TrackButton:SetButtonState(show and 'PUSHED' or "NORMAL")
	end
    if text then
		text:SetAlpha(show and 0.5 or 1)
	end
end

local function _CalendarFrame_IsTodayOrLater(month, day, year)--Blizzard_Calendar.lua
	local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime() or {};
	return currentCalendarTime.month==month and
	    currentCalendarTime.monthDay== day and
        currentCalendarTime.year== year
end

--设置,显示内容 Blizzard_Calendar.lua CalendarDayButton_OnEnter(self)
local function Set_TrackButton_Text(monthOffset, day)
    if Save.hide or not TrackButton then
        if TrackButton then
            TrackButton:set_Shown()
        end
        return
    end
    if not monthOffset or not day then
        local info= C_Calendar.GetEventIndex()
        if info then
            monthOffset=info.offsetMonths
            day=info.monthDay
        else
            local currentCalendarTime= C_DateAndTime.GetCurrentCalendarTime()
            if currentCalendarTime then
                monthOffset=0
                day= currentCalendarTime.monthDay
            end
        end
    end

    local events = {};
    local findQuest
    local isToDay

    if day and monthOffset then
        local monthInfo = C_Calendar.GetMonthInfo(monthOffset);
        if monthInfo then
            isToDay=_CalendarFrame_IsTodayOrLater(monthInfo.month, day, monthInfo.year)
        end
    end

    local numEvents = (day and monthOffset) and C_Calendar.GetNumDayEvents(monthOffset, day) or 0
    if numEvents>0 then
        for i = 1, numEvents do
            local event = C_Calendar.GetDayEvent(monthOffset, day, i);
            if event and event.title then
                local isValid
                if (event.sequenceType == "ONGOING") then
                    event.eventTime = format(CALENDAR_TOOLTIP_DATE_RANGE, FormatShortDate(event.startTime.monthDay, event.startTime.month), FormatShortDate(event.endTime.monthDay, event.endTime.month));
                    isValid=true
                elseif (event.sequenceType == "END") then
                    event.eventTime, isValid = set_Time_Color(GameTime_GetFormattedTime(event.endTime.hour, event.endTime.minute, true), event.startTime.hour, event.startTime.minute)
                else
                    event.eventTime, isValid = set_Time_Color(GameTime_GetFormattedTime(event.startTime.hour, event.startTime.minute, true), event.startTime.hour, event.startTime.minute, true)
                end

                if _CalendarFrame_IsPlayerCreatedEvent(event.calendarType)
                    or not isToDay--今天
                    or not Save.onGoing
                    or (Save.onGoing and isValid)
                then
                    event.index= i
                    event.isValid= isValid
                    local text, texture, atlas, findQuest2= Get_Button_Text(event)
                    if text then
                        event.tab={text= text, texture=texture, atlas= atlas}

                        findQuest= (not findQuest and findQuest2) and true or findQuest

                        tinsert(events, event);
                    end
                end
            end
        end
        table.sort(events, function(a, b)
            if ((a.sequenceType == "ONGOING") ~= (b.sequenceType == "ONGOING")) then
                return a.sequenceType ~= "ONGOING";
            elseif (a.sequenceType == "ONGOING" and a.sequenceIndex ~= b.sequenceIndex) then
                return a.sequenceIndex > b.sequenceIndex;
            end
            if (a.startTime.hour ~= b.startTime.hour) then
                return a.startTime.hour < b.startTime.hour;
            end
            return a.startTime.minute < b.startTime.minute;
        end)
    end



   local last
	for index, event in ipairs(events) do
        local btn= TrackButton.btn[index]
        if not btn then
            btn= e.Cbtn(TrackButton.Frame, {size={14,14}, icon='hide'})
            if Save.toTopTrack then
                btn:SetPoint('BOTTOM', last or TrackButton, 'TOP')
            else
			    btn:SetPoint('TOP', last or TrackButton, 'BOTTOM')
            end
            btn:SetScript('OnLeave', function(self)
				e.tips:Hide()
				Set_TrackButton_Pushed(false, self.text)--TrackButton，提示
			end)

            btn:SetScript('OnEnter', function(self)
                if Save.left then
                    GameTooltip:SetOwner(self.text, "ANCHOR_LEFT")
                else
                    GameTooltip:SetOwner(self.text, "ANCHOR_RIGHT")
                end
                e.tips:ClearLines()
                local title, description
                if (self.monthOffset and self.day and self.index) then
                    local holidayInfo= C_Calendar.GetHolidayInfo(self.monthOffset, self.day, self.index);
                    if (holidayInfo) then
                        if e.HolidayEvent[self.eventID] then
                            title= e.HolidayEvent[self.eventID][1]
                            description= e.HolidayEvent[self.eventID][2]
                        end
                        title= title or holidayInfo.name
                        description = description or holidayInfo.description;

                        if (holidayInfo.startTime and holidayInfo.endTime) then
                            description=format(e.onlyChinese and '%1$s|n|n开始：%2$s %3$s|n结束：%4$s %5$s' or CALENDAR_HOLIDAYFRAME_BEGINSENDS,
                                e.cn(description),
                                FormatShortDate(holidayInfo.startTime.monthDay, holidayInfo.startTime.month),
                                GameTime_GetFormattedTime(holidayInfo.startTime.hour, holidayInfo.startTime.minute, true),
                                FormatShortDate(holidayInfo.endTime.monthDay, holidayInfo.endTime.month),
                                GameTime_GetFormattedTime(holidayInfo.endTime.hour, holidayInfo.endTime.minute, true)
                            )
                        end
                    else
                        local raidInfo = C_Calendar.GetRaidInfo(self.monthOffset, self.day, self.index);
                        if raidInfo and raidInfo.calendarType == "RAID_LOCKOUT" then
                            title = GetDungeonNameWithDifficulty(raidInfo.name, raidInfo.difficultyName);
                            description= format(e.onlyChinese and '你的%1$s副本将在%2$s解锁。' or CALENDAR_RAID_LOCKOUT_DESCRIPTION, e.cn(title),  GameTime_GetFormattedTime(raidInfo.time.hour, raidInfo.time.minute, true))
                        end
                    end
                    if title or description then
                        if title then
                            e.tips:AddLine(e.cn(title))
                        end
                        if description then
                            e.tips:AddLine(' ')
                            e.tips:AddLine(description, nil,nil,nil,true)
                            e.tips:AddLine(' ')
                        end
                    end
                end
                e.tips:AddDoubleLine('eventID', self.eventID)
                e.tips:AddDoubleLine(id, Initializer:GetName())
                e.tips:Show()
				Set_TrackButton_Pushed(true, self.text)--TrackButton，提示
			end)


            btn.text= e.Cstr(btn, {color=true})
            function btn:set_text_point()
                if Save.left then
                    self.text:SetPoint('RIGHT', self, 'LEFT',1, 0)
                else
                    self.text:SetPoint('LEFT', self, 'RIGHT', -1, 0)
                end
                self.text:SetJustifyH(Save.left and 'RIGHT' or 'LEFT')
            end
            btn:set_text_point()

			TrackButton.btn[index]=btn
		else
			btn:SetShown(true)
		end
		last=btn


        btn.index= event.index
        btn.day=day
        btn.monthOffset= monthOffset
        btn.eventID= event.eventID

        btn.text:SetText(event.tab.text)

		if event.tab.atlas then
			btn:SetNormalAtlas(event.tab.atlas)
		else
			btn:SetNormalTexture(event.tab.texture or event.iconTexture or 0)
		end
	end

    TrackButton:UnregisterEvent('QUEST_COMPLETE')
    if findQuest then
        TrackButton:RegisterEvent('QUEST_COMPLETE')
    end

    if (day and not isToDay) then
        TrackButton:SetNormalAtlas( 'UI-HUD-Calendar-'..day..'-Mouseover')
    else
        TrackButton:SetNormalTexture(0)
    end

    for index= #events+1, #TrackButton.btn do
		local btn=TrackButton.btn[index]
		btn.text:SetText('')
		btn:SetShown(false)
		btn:SetNormalTexture(0)
	end

    TrackButton.monthOffset= monthOffset
    TrackButton.day= day
    TrackButton:SetID(day or 0)
end










local function Init_TrackButton()
    TrackButton= e.Cbtn(nil, {icon='hide', size={18,18}, pushe=true})

    TrackButton.texture=TrackButton:CreateTexture()
    TrackButton.texture:SetAllPoints(TrackButton)
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
        Save.point={self:GetPoint(1)}
        Save.point[2]=nil
    end)

    function TrackButton:set_Events()--设置事件
        if Save.hide then
            self:UnregisterAllEvents()
        else
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            self:RegisterEvent('PET_BATTLE_OPENING_DONE')
			self:RegisterEvent('PET_BATTLE_CLOSE')

            self:RegisterEvent('CALENDAR_UPDATE_EVENT_LIST')
            self:RegisterEvent('CALENDAR_UPDATE_EVENT')
            self:RegisterEvent('CALENDAR_NEW_EVENT')
            self:RegisterEvent('CALENDAR_OPEN_EVENT')
            self:RegisterEvent('CALENDAR_CLOSE_EVENT')
        end
    end


    function TrackButton:set_Shown()
        local hide= IsInInstance() or C_PetBattles.IsInBattle() or UnitAffectingCombat('player')
        self:SetShown(not hide)
        self.texture:SetShown(Save.hide and true or false)
        self.Frame:SetShown(not hide and not Save.hide)
    end


    function TrackButton:set_Scale()
        self.Frame:SetScale(Save.scale or 1)
    end


    function TrackButton:set_Tooltips()
        if self.monthOffset and self.day then
            CalendarDayButton_OnEnter(self)
            e.tips:AddLine(' ')
        else
            if Save.left then
                e.tips:SetOwner(self, "ANCHOR_LEFT")
            else
                e.tips:SetOwner(self, "ANCHOR_RIGHT")
            end
            e.tips:ClearLines()
        end
        e.tips:AddDoubleLine(e.onlyChinese and '打开/关闭日历' or GAMETIME_TOOLTIP_TOGGLE_CALENDAR, e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' '..(Save.scale or 1), 'Alt+'..e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:Show()
    end
    TrackButton:SetScript('OnMouseUp', ResetCursor)
    TrackButton:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        elseif d=='LeftButton' then
            Calendar_Toggle()

        elseif d=='RightButton' then
            if not self.Menu then
                self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, function(_, level)
                    local info
                    info={
                        text=e.onlyChinese and '显示' or SHOW,
                        checked=not Save.hide,
                        func= function()
                            Save.hide= not Save.hide and true or nil
                            Set_TrackButton_Text()
                            TrackButton:set_Events()--设置事件
                            TrackButton:set_Shown()
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)

                    e.LibDD:UIDropDownMenu_AddSeparator(level)
                    info={
                        text= e.onlyChinese and '向左平移' or BINDING_NAME_STRAFELEFT,--向左平移
                        checked=not Save.left,
                        func= function()
                            Save.left= not Save.left and true or nil
                            for _, btn in pairs(TrackButton.btn) do
                                btn.text:ClearAllPoints()
                                btn:set_text_point()
                            end
                            Set_TrackButton_Text()
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)

                    info={
						text=e.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP,
						icon='bags-greenarrow',
						checked= Save.toTopTrack,
						func= function()
							Save.toTopTrack = not Save.toTopTrack and true or nil
							local last
							for index= 1, #TrackButton.btn do
								local btn=TrackButton.btn[index]
								btn:ClearAllPoints()
								if Save.toTopTrack then
									btn:SetPoint('BOTTOM', last or TrackButton, 'TOP')
								else
									btn:SetPoint('TOP', last or TrackButton, 'BOTTOM')
								end
								last=btn
							end
							Set_TrackButton_Text()
						end
					}
					e.LibDD:UIDropDownMenu_AddButton(info, level)


                    info={
                        text= e.onlyChinese and '仅限: 正在活动' or LFG_LIST_CROSS_FACTION:format(CALENDAR_TOOLTIP_ONGOING),
                        checked= Save.onGoing,
                        func= function()
                            Save.onGoing= not Save.onGoing and true or nil
                            Set_TrackButton_Text()
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)

                    info={
                        text= e.onlyChinese and '时间' or TIME_LABEL,
                        checked= Save.showDate,
                        func= function()
                            Save.showDate= not Save.showDate and true or nil
                            Set_TrackButton_Text()
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                end, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
        end
    end)


    TrackButton:SetScript('OnMouseWheel', function(self, d)--缩放
        if IsAltKeyDown() then
            local sacle=Save.scale or 1
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
            Save.scale=sacle
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

    function TrackButton:set_Point()--设置, 位置
        if Save.point then
            self:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
        elseif e.Player.husandro then
            self:SetPoint('TOPLEFT', 150,0)
        else
            self:SetPoint('BOTTOMRIGHT', _G['!KalielsTrackerFrame'] or ObjectiveTrackerBlocksFrame, 'TOPLEFT', -35, -10)
        end
    end

    TrackButton:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_ENTERING_WORLD'
        or event=='PLAYER_REGEN_DISABLED'
        or event=='PLAYER_REGEN_ENABLED'
        or event=='PET_BATTLE_OPENING_DONE'
        or event=='PET_BATTLE_CLOSE'
        then
            self:set_Shown()
        else
            Set_TrackButton_Text()
        end
    end)



    TrackButton:set_Point()
    TrackButton:set_Scale()
    TrackButton:set_Shown()
    TrackButton:set_Events()
    Set_TrackButton_Text()

    hooksecurefunc('CalendarDayButton_Click', function(button)
        Set_TrackButton_Text(button.monthOffset, button.day)
    end)
    CalendarFrame:HookScript('OnHide', function()
        Set_TrackButton_Text()
        Set_TrackButton_Pushed(false)--TrackButton，提示

    end)
    CalendarFrame:HookScript('OnShow', function()
        Set_TrackButton_Pushed(true)--TrackButton，提示
        C_Timer.After(2, function()
            Set_TrackButton_Pushed(false)
        end)
    end)
end



























local function calendar_Uptate()
    local indexInfo = C_Calendar.GetEventIndex()
    local info= indexInfo and C_Calendar.GetDayEvent(indexInfo.offsetMonths, indexInfo.monthDay, indexInfo.eventIndex) or {}
    local text
    if info.eventID then
        local head, desc--汉化
        if e.HolidayEvent[info.eventID] then
            head, desc= e.HolidayEvent[info.eventID][1], e.HolidayEvent[info.eventID][2]
        end
        text= (info.iconTexture and '|T'..info.iconTexture..':0|t'..info.iconTexture..'|n' or '')
            ..'eventID '..info.eventID
            ..(info.title and '|n'..info.title or '')
            ..(head and '|n'..head or '')
        if head then
            CalendarViewHolidayFrame.Header:Setup(head)
        end
        if desc then
            if (info.startTime and info.endTime) then
                desc = format('%1$s|n|n开始：%2$s %3$s|n结束：%4$s %5$s', desc, FormatShortDate(info.startTime.monthDay, info.startTime.month), GameTime_GetFormattedTime(info.startTime.hour, info.startTime.minute, true), FormatShortDate(info.endTime.monthDay, info.endTime.month), GameTime_GetFormattedTime(info.endTime.hour, info.endTime.minute, true));
            end
            CalendarViewHolidayFrame.ScrollingFont:SetText(desc)
        end
    end
    if text and not CalendarViewHolidayFrame.Text then
        CalendarViewHolidayFrame.Text= e.Cstr(CalendarViewHolidayFrame, {mouse=true, color={r=0, g=0.68, b=0.94, a=1}})
        CalendarViewHolidayFrame.Text:SetPoint('BOTTOMLEFT',12,12)
        CalendarViewHolidayFrame.Text:SetScript('OnLeave', function(self) self:SetAlpha(1) e.tips:Hide() end)
        CalendarViewHolidayFrame.Text:SetScript('OnEnter', function(self)
            self:SetAlpha(0.3)
            if not self.eventID then return end
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, Initializer:GetName())
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine('https://www.wowhead.com/event='..self.eventID, e.Icon.left)
            e.tips:Show()
        end)
        CalendarViewHolidayFrame.Text:SetScript('OnMouseDown', function(frame)
            if not frame.eventID then return end
            e.Show_WoWHead_URL(true, 'event', frame.eventID, nil)
        end)

        CalendarViewHolidayFrame.Texture2=CalendarViewHolidayFrame:CreateTexture()
        local w,h= CalendarViewHolidayFrame:GetSize()
        CalendarViewHolidayFrame.Texture2:SetSize(w-70, h-70)
        CalendarViewHolidayFrame.Texture2:SetPoint('CENTER',40,-40)
        CalendarViewHolidayFrame.Texture2:SetAlpha(0.5)
    end
    if CalendarViewHolidayFrame.Text then
        CalendarViewHolidayFrame.Text.eventID= info.eventID or nil
        CalendarViewHolidayFrame.Text:SetText(text or '')
        CalendarViewHolidayFrame.Texture2:SetTexture(info.iconTexture or 0)
    end
end


--#########
--初始，插件
--#########

local function Init_Blizzard_Calendar()
    if CalendarViewHolidayFrame.update then
        hooksecurefunc(CalendarViewHolidayFrame, 'update', calendar_Uptate)--提示节目ID
    end
    hooksecurefunc('CalendarViewHolidayFrame_Update', calendar_Uptate)

    hooksecurefunc('CalendarCreateEventInviteListScrollFrame_Update', function()
        local namesReady = C_Calendar.AreNamesReady();
        local frame= CalendarCreateEventInviteList.ScrollBox
        if namesReady or not frame:GetView()  then
            for index, btn in pairs(frame:GetFrames()) do--ScrollBox.lua
                local inviteInfo = C_Calendar.EventGetInvite(index)
                if inviteInfo and inviteInfo.guid then
                    btn.Class:SetText(e.GetPlayerInfo({guid=inviteInfo.guid, name=inviteInfo.name}))
                end
            end
        end
    end)


    --Blizzard_Calendar.lua
    CalendarCreateEventFrame:HookScript('OnShow', function(self)
        if self.menu then
            return
        end
        self.menu=CreateFrame("Frame", nil, CalendarCreateEventFrame, "UIDropDownMenuTemplate")
        self.menu:SetPoint('BOTTOMLEFT', CalendarCreateEventFrame, 'BOTTOMRIGHT', -22,74)
        e.LibDD:UIDropDownMenu_SetWidth(self.menu, 60)
        e.LibDD:UIDropDownMenu_SetText(self.menu, e.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET)
        e.LibDD:UIDropDownMenu_Initialize(self.menu, function(_, level)
            local map=e.GetUnitMapName('player');--玩家区域名称
            local inviteTab={}
            for index = 1, C_Calendar.GetNumInvites() do
                local inviteInfo = C_Calendar.EventGetInvite(index);
                if inviteInfo and inviteInfo.name then
                    inviteTab[inviteInfo.name]= true
                end
            end
            local find
            for i=1 ,BNGetNumFriends() do
                local wow=C_BattleNet.GetFriendAccountInfo(i);
                local wowInfo= wow and wow.gameAccountInfo
                if wowInfo and wowInfo.playerGuid and wowInfo.characterName and not inviteTab[wowInfo.characterName] and wowInfo.wowProjectID==1 then

                    local text= e.GetPlayerInfo({guid=wowInfo.playerGuid, faction=wowInfo.factionName, name=wowInfo.characterName, reName=true, reRealm=true})--角色信息
                    if wowInfo.areaName then --位置
                        if wowInfo.areaName==map then
                            text=text..'|A:poi-islands-table:0:0|a'
                        else
                            text=text..' '..wowInfo.areaName
                        end
                    end

                    if wowInfo.characterLevel and wowInfo.characterLevel~=MAX_PLAYER_LEVEL and wowInfo.characterLevel>0 then--等级
                        text=text ..' |cff00ff00'..wowInfo.characterLevel..'|r'
                    end
                    if not wowInfo.isOnline then
                        text= text..' '..(e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)
                    end
                    local info={
                        text=text,
                        notCheckable=true,
                        tooltipOnButton=true,
                        tooltipTitle= wow and wow.note,
                        arg1= wowInfo.characterName..(wowInfo.realmName and '-'..wowInfo.realmName or ''),
                        func=function(self2, arg1)
                            CalendarCreateEventInviteEdit:SetText(arg1)
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                    find=true
                end
            end
            if not find then
                e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
            end
        end)
        self.menu.Button:SetScript('OnMouseDown', function(self2)
            e.LibDD:ToggleDropDownMenu(1, nil, self2:GetParent(), self2, 15, 0)
        end)

        local menu2=CreateFrame("Frame", nil, CalendarCreateEventFrame, "UIDropDownMenuTemplate")
        menu2:SetPoint('TOPRIGHT', self.menu, 'BOTTOMRIGHT')
        e.LibDD:UIDropDownMenu_SetWidth(menu2, 60)
        e.LibDD:UIDropDownMenu_SetText(menu2, e.onlyChinese and '好友' or FRIEND)
        e.LibDD:UIDropDownMenu_Initialize(menu2, function(_, level)
            local map=e.GetUnitMapName('player');--玩家区域名称
            local inviteTab={}
            for index = 1, C_Calendar.GetNumInvites() do
                local inviteInfo = C_Calendar.EventGetInvite(index);
                if inviteInfo and inviteInfo.name then
                    inviteTab[inviteInfo.name]= true
                end
            end
            local find
            for i=1 , C_FriendList.GetNumFriends() do
                local game=C_FriendList.GetFriendInfoByIndex(i)
                if game and game.name and not inviteTab[game.name] then--and not game.afk and not game.dnd then
                    local text=e.GetPlayerInfo({guid=game.guid, name=game.name,  reName=true, reRealm=true})--角色信息
                    text= (game.level and game.level~=MAX_PLAYER_LEVEL and game.level>0) and text .. ' |cff00ff00'..game.level..'|r' or text--等级
                    if game.area and game.connected then
                        if game.area == map then--地区
                            text= text..'|A:poi-islands-table:0:0|a'
                        else
                            text= text..' |cnGREEN_FONT_COLOR:'..game.area..'|r'
                        end
                    elseif not game.connected then
                        text= text..' '..(e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)
                    end

                    local info={
                        text=text,
                        notCheckable= true,
                        tooltipOnButton=true,
                        tooltipTitle=game.notes,
                        icon= game.afk and FRIENDS_TEXTURE_AFK or game.dnd and FRIENDS_TEXTURE_DND,
                        arg1= game.name,
                        func=function(_, arg1)
                            CalendarCreateEventInviteEdit:SetText(arg1)
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                    find=true
                end
            end
            if not find then
                e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
            end
        end)
        menu2.Button:SetScript('OnMouseDown', function(self2)
            e.LibDD:ToggleDropDownMenu(1, nil, self2:GetParent(), self2, 15, 0)
        end)

        local last=CreateFrame("Frame", nil, CalendarCreateEventFrame, "UIDropDownMenuTemplate")
        last:SetPoint('TOPRIGHT', menu2, 'BOTTOMRIGHT')
        e.LibDD:UIDropDownMenu_SetWidth(last, 60)
        e.LibDD:UIDropDownMenu_SetText(last, e.onlyChinese and '公会' or GUILD)
        e.LibDD:UIDropDownMenu_Initialize(last, function(_, level)
            local map=e.GetUnitMapName('player')
            local inviteTab={}
            for index = 1, C_Calendar.GetNumInvites() do
                local inviteInfo = C_Calendar.EventGetInvite(index);
                if inviteInfo and inviteInfo.name then
                    inviteTab[inviteInfo.name]= true
                end
            end
            local find
            for index=1,  GetNumGuildMembers() do
                local name, rankName, rankIndex, lv, _, zone, publicNote, officerNote, isOnline, status, _, _, _, _, _, _, guid = GetGuildRosterInfo(index)
                if name and guid and not inviteTab[name] and isOnline and name~=e.Player.name_realm then
                    local text=e.GetPlayerInfo({guid=guid, name=name,  reName=true, reRealm=true})--名称
                    text=(lv and lv~=MAX_PLAYER_LEVEL and lv>0) and text..' |cnGREEN_FONT_COLOR:'..lv..'|r' or text--等级
                    if zone then--地区
                        text= zone==map and text..'|A:poi-islands-table:0:0|a' or text..' '..zone
                    end
                    text= rankName and text..' '..rankName..(rankIndex or '') or text
                    local info={
                        text=text,
                        notCheckable=true,
                        tooltipOnButton=true,
                        tooltipTitle=publicNote or '',
                        tooltipText=officerNote or '',
                        icon= status==1 and FRIENDS_TEXTURE_AFK or status==2 and FRIENDS_TEXTURE_DND,
                        arg1=name,
                        func=function(_, arg1)
                            CalendarCreateEventInviteEdit:SetText(arg1)
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                    find=true
                end
            end
            if not find then
                e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
            end
        end)
        last.Button:SetScript('OnMouseDown', function(self2)
            e.LibDD:CloseDropDownMenus()
            e.LibDD:ToggleDropDownMenu(1, nil, self2:GetParent(), self2, 15, 0)
        end)
    end)
end

















panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            Initializer= e.AddPanel_Check_Button({
                checkName= '|A:GarrisonTroops-Health:0:0|a'..(e.onlyChinese and '节日' or addName),
                checkValue= not Save.disabled,
                checkFunc= function()
                    Save.disabled = not Save.disabled and true or nil
                    print(id, Initializer:GetName(), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                end,
                buttonText= e.onlyChinese and '重置位置' or RESET_POSITION,
                buttonFunc= function()
                    Save.point=nil
                    if TrackButton then
                        TrackButton:ClearAllPoints()
                        TrackButton:set_Point()
                    end
                    print(id, Initializer:GetName(), e.onlyChinese and '重置位置' or RESET_POSITION)
                end,
                tooltip= e.cn(addName),
                layout= nil,
                category= nil,
            })

            if  Save.disabled then
                self:UnregisterEvent('ADDON_LOADED')
            else
                Calendar_LoadUI()
            end

        elseif arg1=='Blizzard_Calendar' then
            Init_Blizzard_Calendar()--初始，插件
            C_Timer.After(2, Init_TrackButton)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)
