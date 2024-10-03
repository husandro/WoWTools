local e= select(2, ...)
local function Save()
    return WoWTools_HolidayMixin.Save
end






local function Check_TimeWalker_Quest_Completed()--迷离的时光之路，任务是否完成
    for _, questID in pairs({
        40168, 40173, 40786, 45563, 55499, 40168, 40173, 40787, 45563, 55498, 64710,64709,
        72725,--迷离的时光之路 熊猫人之迷
    }) do
        if C_QuestLog.IsQuestFlaggedCompleted(questID) then
            return format('|A:%s:0:0|a', e.Icon.select)
        end
    end
end

local function Check_Darkmon_Quest_Completed()--暗月马戏团，宠物对战，任务是否完成
    for _, questID in pairs({36471, 32175}) do
        if C_QuestLog.IsQuestFlaggedCompleted(questID) then
            return format('|A:%s:0:0|a', e.Icon.select)
        end
    end
end
















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

    local tab= e.cn(nil, {holydayID=event.eventID}) or {}
    local title=tab[1] or event.title


    if _CalendarFrame_IsPlayerCreatedEvent(event.calendarType) then--自定义,事件
        local invitInfo= C_Calendar.EventGetInvite(event.index) or {}
        if invitInfo.guid then
            atlas= WoWTools_UnitMixin:GetPlayerInfo({guid=invitInfo.guid, reAtlas=true})
        end
        if UnitIsUnit("player", event.invitedBy) then--我
            atlas= atlas or WoWTools_UnitMixin:GetRaceIcon({unit='player',reAtlas=true})
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

            local isCompleted= Check_TimeWalker_Quest_Completed()--迷离的时光之路，任务是否完成
            texture= isCompleted or '|A:AutoQuest-Badge-Campaign:0:0|a'
            title=(e.onlyChinese and '时空漫游' or PLAYER_DIFFICULTY_TIMEWALKER)
            findQuest= isCompleted and true or findQuest
            icon=463446--1166[时空扭曲徽章]

        elseif event.eventID==479 then--暗月--CALENDAR_FILTER_DARKMOON = "暗月马戏团"--515[暗月奖券]
            local isCompleted= Check_Darkmon_Quest_Completed()--暗月马戏团，宠物对战，任务是否完成
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
            local isCompleted= Check_TimeWalker_Quest_Completed()--迷离的时光之路，任务是否完成

            texture= isCompleted or '|A:AutoQuest-Badge-Campaign:0:0|a'
            findQuest= isCompleted
            icon=463446--1166[时空扭曲徽章]

        elseif event.eventID==479 then--暗月--CALENDAR_FILTER_DARKMOON = "暗月马戏团"
            local isCompleted= Check_Darkmon_Quest_Completed()--暗月马戏团，宠物对战，任务是否完成
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

    title= title:match(HEADER_COLON..'(.+)') or title
    title= not event.isValid and '|cff9e9e9e'..title..'|r' or title
    local msg
    if Save().left then
        msg= ((Save().showDate and event.eventTime) and event.eventTime..' ' or '')
            ..(text and text..' ' or '')
            ..(texture or '')
            ..title
    else
        msg= title
            ..(texture or '')
            ..(text and ' '..text or '')
            ..((Save().showDate and event.eventTime) and ' '..event.eventTime or '')
    end

    icon= icon or CALENDAR_EVENTTYPE_TEXTURES[event.eventType]
    return msg, icon, atlas, findQuest
end







local function _CalendarFrame_IsTodayOrLater(month, day, year)--Blizzard_Calendar.lua
	local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime() or {};
	return currentCalendarTime.month==month and
	    currentCalendarTime.monthDay== day and
        currentCalendarTime.year== year
end




















--设置,显示内容 Blizzard_Calendar.lua CalendarDayButton_OnEnter(self)
local function Set_TrackButton_Text(monthOffset, day)
    local TrackButton= WoWTools_HolidayMixin.TrackButton
    if Save().hide or not TrackButton then
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
                    event.eventTime = format(CALENDAR_TOOLTIP_DATE_RANGE, FormatShortDate(event.startTime.monthDay, event.startTime.month, event.startTime.year), FormatShortDate(event.endTime.monthDay, event.endTime.month, event.endTime.year));
                    isValid=true
                elseif (event.sequenceType == "END") then
                    event.eventTime, isValid = set_Time_Color(GameTime_GetFormattedTime(event.endTime.hour, event.endTime.minute, true), event.startTime.hour, event.startTime.minute)
                else
                    event.eventTime, isValid = set_Time_Color(GameTime_GetFormattedTime(event.startTime.hour, event.startTime.minute, true), event.startTime.hour, event.startTime.minute, true)
                end

                if _CalendarFrame_IsPlayerCreatedEvent(event.calendarType)
                    or not isToDay--今天
                    or not Save().onGoing
                    or (Save().onGoing and isValid)
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
            btn= WoWTools_ButtonMixin:Cbtn(TrackButton.Frame, {size={14,14}, icon='hide'})
            if Save().toTopTrack then
                btn:SetPoint('BOTTOM', last or TrackButton, 'TOP')
            else
			    btn:SetPoint('TOP', last or TrackButton, 'BOTTOM')
            end
            btn:SetScript('OnLeave', function(self)
				e.tips:Hide()
				WoWTools_HolidayMixin:SetTrackButtonState(false, self.text)--TrackButton，提示
			end)

            btn:SetScript('OnEnter', function(self)
                if Save().left then
                    GameTooltip:SetOwner(self.text, "ANCHOR_LEFT")
                else
                    GameTooltip:SetOwner(self.text, "ANCHOR_RIGHT")
                end
                e.tips:ClearLines()
                local title, description
                if (self.monthOffset and self.day and self.index) then
                    local holidayInfo= C_Calendar.GetHolidayInfo(self.monthOffset, self.day, self.index);
                    if (holidayInfo) then
                        local data= e.cn(nil, {holydayID=self.eventID}) or {}
                        title= data[1] or holidayInfo.name
                        description = data[2] or holidayInfo.description;

                        if (holidayInfo.startTime and holidayInfo.endTime) then
                            description=format(e.onlyChinese and '%1$s|n|n开始：%2$s %3$s|n结束：%4$s %5$s' or CALENDAR_HOLIDAYFRAME_BEGINSENDS,
                                e.cn(description),
                                FormatShortDate(holidayInfo.startTime.monthDay, holidayInfo.startTime.month, holidayInfo.startTime.year),
                                GameTime_GetFormattedTime(holidayInfo.startTime.hour, holidayInfo.startTime.minute, true),
                                FormatShortDate(holidayInfo.endTime.monthDay, holidayInfo.endTime.month, holidayInfo.startTime.year),
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
                e.tips:AddDoubleLine(e.addName, WoWTools_HolidayMixin.addName)
                e.tips:Show()
				WoWTools_HolidayMixin:SetTrackButtonState(true, self.text)--TrackButton，提示
			end)


            btn.text= WoWTools_LabelMixin:Create(btn, {color=true})
            function btn:set_text_point()
                if Save().left then
                    self.text:SetPoint('RIGHT', self, 'LEFT',1, 0)
                else
                    self.text:SetPoint('LEFT', self, 'RIGHT', -1, 0)
                end
                self.text:SetJustifyH(Save().left and 'RIGHT' or 'LEFT')
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












function WoWTools_HolidayMixin:TrackButtonSetText(...)
    Set_TrackButton_Text(...)
end















