
local function Save()
    return WoWToolsSave['Plus_Holiday']
end
local TrackButton
local NumButton=0
local Name='WoWToolsHolidayTrackButton'














local function Check_TimeWalker_Quest_Completed()--迷离的时光之路，任务是否完成
    for _, questID in pairs({
        40168, 40173, 40786, 45563, 55499, 40168, 40173, 40787, 45563, 55498, 64710,64709,
        72725, 83362,--迷离的时光之路 熊猫人之迷
    }) do
        if C_QuestLog.IsQuestFlaggedCompleted(questID) then
            return format('|A:%s:0:0|a', 'common-icon-checkmark')
        end
    end
end

local function Check_Darkmon_Quest_Completed()--暗月马戏团，宠物对战，任务是否完成
    for _, questID in pairs({36471, 32175}) do
        if C_QuestLog.IsQuestFlaggedCompleted(questID) then
            return format('|A:%s:0:0|a', 'common-icon-checkmark')
        end
    end
end
















local function _CalendarFrame_SafeGetName(name)
	if ( not name or name == "" ) then
		return WoWTools_DataMixin.onlyChinese and '未知' or UNKNOWN;
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
		["START"]			= WoWTools_DataMixin.onlyChinese and '%s 开始' or CALENDAR_EVENTNAME_FORMAT_START,
		["END"]				= WoWTools_DataMixin.onlyChinese and '%s 结束' or CALENDAR_EVENTNAME_FORMAT_END,
		[""]				= "%s",
		["ONGOING"]			= "%s",
	},
	["RAID_LOCKOUT"] = {
		[""]				= WoWTools_DataMixin.onlyChinese and '%s解锁' or CALENDAR_EVENTNAME_FORMAT_RAID_LOCKOUT,
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
	--[Enum.CalendarEventType.PvP]		=  WoWTools_DataMixin.Player.Faction=='Alliance' and "Interface\\Calendar\\UI-Calendar-Event-PVP02" or (WoWTools_DataMixin.Player.Faction=='Horde' and "Interface\\Calendar\\UI-Calendar-Event-PVP01") or "Interface\\Calendar\\UI-Calendar-Event-PVP",
	[Enum.CalendarEventType.Meeting]	= "Interface\\Calendar\\MeetingIcon",
	[Enum.CalendarEventType.Other]		= "Interface\\Calendar\\UI-Calendar-Event-Other",
}






local function Get_Button_Text(event)
    local icon,atlas
    local findQuest
    local text
    local texture

    local title=WoWTools_TextMixin:CN(nil, {holydayID=event.eventID, isName=true}) or event.title


    if _CalendarFrame_IsPlayerCreatedEvent(event.calendarType) then--自定义,事件
        local invitInfo= C_Calendar.EventGetInvite(event.index) or {}
        if invitInfo.guid then
            atlas= WoWTools_UnitMixin:GetPlayerInfo(nil, invitInfo.guid, nil, {reAtlas=true})
        end
        if not UnitIsUnit("player", event.invitedBy) then
            if _CalendarFrame_IsSignUpEvent(event.calendarType, event.inviteType) then
                local inviteStatusInfo = CalendarUtil.GetCalendarInviteStatusInfo(event.inviteStatus);
                if event.inviteStatus== Enum.CalendarStatus.NotSignedup or event.inviteStatus == Enum.CalendarStatus.Signedup then
                    text = inviteStatusInfo.name;
                else
                    text = format(WoWTools_DataMixin.onlyChinese and '已登记（%s）' or CALENDAR_SIGNEDUP_FOR_GUILDEVENT_WITH_STATUS, inviteStatusInfo.name);
                end
            else
                if ( event.calendarType == "GUILD_ANNOUNCEMENT" ) then
                    text = format(WoWTools_DataMixin.onlyChinese and '由%s创建' or CALENDAR_ANNOUNCEMENT_CREATEDBY_PLAYER, _CalendarFrame_SafeGetName(event.invitedBy));
                    atlas= 'communities-icon-chat'
                else
                    text = format( WoWTools_DataMixin.onlyChinese and '被%s邀请' or CALENDAR_EVENT_INVITEDBY_PLAYER, _CalendarFrame_SafeGetName(event.invitedBy));
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
            event.eventID==1269 or
            event.eventID==1669
        then

            local isCompleted= Check_TimeWalker_Quest_Completed()--迷离的时光之路，任务是否完成
            texture= isCompleted or '|A:AutoQuest-Badge-Campaign:0:0|a'
            title=(WoWTools_DataMixin.onlyChinese and '时空漫游' or PLAYER_DIFFICULTY_TIMEWALKER)
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

        if event.title:find(PLAYER_DIFFICULTY_TIMEWALKER)--时空漫游 559
            --[[or event.eventID==1063
            or event.eventID==616
            or event.eventID==617
            or event.eventID==623
            or event.eventID==629
            or event.eventID==643--熊猫人之迷
            or event.eventID==654
            or event.eventID==1068
            or event.eventID==1277
            or event.eventID==1269]]
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
        msg= ((Save().showDate and event.eventTime) and '|cffffffff'..event.eventTime..'|r ' or '')
            ..(text and text..' ' or '')
            ..(texture or '')
            ..title
    else
        msg= title
            ..(texture or '')
            ..(text and ' '..text or '')
            ..((Save().showDate and event.eventTime) and ' |cffffffff'..event.eventTime..'|r' or '')
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






local CALENDAR_CALENDARTYPE_TCOORDS = {
	["PLAYER"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["GUILD_ANNOUNCEMENT"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["GUILD_EVENT"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["COMMUNITY_EVENT"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["SYSTEM"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	["HOLIDAY"] = {
		left	= 0.0,
		right	= 0.7109375,
		top		= 0.0,
		bottom	= 0.7109375,
	},
	["RAID_LOCKOUT"] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
}
local CALENDAR_EVENTTYPE_TCOORDS = {
	[Enum.CalendarEventType.Raid] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	[Enum.CalendarEventType.Dungeon] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	[Enum.CalendarEventType.PvP] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	[Enum.CalendarEventType.Meeting] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
	[Enum.CalendarEventType.Other] = {
		left	= 0.0,
		right	= 1.0,
		top		= 0.0,
		bottom	= 1.0,
	},
};
local function _CalendarFrame_GetTextureCoords(calendarType, eventType)
	local tcoords;
	if ( calendarType == "HOLIDAY" ) then
		tcoords = CALENDAR_CALENDARTYPE_TCOORDS[calendarType];
	else
		tcoords = CALENDAR_EVENTTYPE_TCOORDS[eventType];
	end
	return tcoords;
end

















local function Create_Button(index)
    --[[local btn= WoWTools_ButtonMixin:Cbtn(TrackButton.Frame, {
        size=14,
        setID=index,
        addTexture=true,
        name=Name..index
    })]]
    local btn= CreateFrame('Button', Name..index, TrackButton.Frame, 'WoWToolsButtonTemplate', index)
    btn:SetSize(16,16)

    btn.texture=btn:CreateTexture(nil, 'BORDER')
--自定义，图标大小
    btn.texture:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
    btn.texture:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0, 0)

    btn:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            Calendar_Toggle()
        elseif d=='RightButton' then
            WoWTools_HolidayMixin:Init_Menu(self)
        end
    end)

    btn:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        WoWTools_HolidayMixin:SetTrackButtonState(false, self.text)--TrackButton，提示
    end)

    btn:SetScript('OnEnter', function(self)
        if Save().left then
            GameTooltip:SetOwner(self.text, "ANCHOR_LEFT")
        else
            GameTooltip:SetOwner(self.text, "ANCHOR_RIGHT")
        end
        GameTooltip:ClearLines()
        local title, description
        if (self.monthOffset and self.day and self.index) then
            local holidayInfo= C_Calendar.GetHolidayInfo(self.monthOffset, self.day, self.index);
            if (holidayInfo) then
                local data= WoWTools_TextMixin:CN(nil, {holydayID=self.eventID}) or {}
                title= data.T or holidayInfo.name
                description = data.D or holidayInfo.description;

                if (holidayInfo.startTime and holidayInfo.endTime) then
                    description=format(WoWTools_DataMixin.onlyChinese and '%1$s|n|n开始：%2$s %3$s|n结束：%4$s %5$s' or CALENDAR_HOLIDAYFRAME_BEGINSENDS,
                        description,
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
                    description= format(WoWTools_DataMixin.onlyChinese and '你的%1$s副本将在%2$s解锁。' or CALENDAR_RAID_LOCKOUT_DESCRIPTION, WoWTools_TextMixin:CN(title),  GameTime_GetFormattedTime(raidInfo.time.hour, raidInfo.time.minute, true))
                end
            end
            if title or description then
                if title then
                    GameTooltip:AddLine(title)
                end
                if description and description~='' then
                    GameTooltip:AddLine(' ')
                    GameTooltip:AddLine(description, nil,nil,nil,true)
                    GameTooltip:AddLine(' ')
                end
            end
        end
        GameTooltip:AddDoubleLine('eventID', self.eventID)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_HolidayMixin.addName)
        GameTooltip:Show()
        WoWTools_HolidayMixin:SetTrackButtonState(true, self.text)--TrackButton，提示
    end)


    btn.text= WoWTools_LabelMixin:Create(btn)



    function btn:settings()
        self.text:ClearAllPoints()
        if Save().left then
            self.text:SetPoint('RIGHT', self, 'LEFT',1, 0)
        else
            self.text:SetPoint('LEFT', self, 'RIGHT', -1, 0)
        end
        self.text:SetJustifyH(Save().left and 'RIGHT' or 'LEFT')

        self:ClearAllPoints()
        if Save().toTopTrack then
            self:SetPoint('BOTTOM', _G[Name..(self:GetID()-1)] or TrackButton, 'TOP')
        else
            self:SetPoint('TOP',  _G[Name..(self:GetID()-1)] or TrackButton, 'BOTTOM')
        end

    end

    NumButton= index

    btn:settings()
    return btn
end






















--设置,显示内容 Blizzard_Calendar.lua CalendarDayButton_OnEnter(self)
local function Set_Text(monthOffset, day)

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



    local btn, s, tcoords
    local width=0
    local num= #events
    local toLeft= Save().left


	for index, event in pairs(events) do
        btn= _G[Name..index] or Create_Button(index)
        btn:SetShown(true)

        btn.index= event.index
        btn.day=day
        btn.monthOffset= monthOffset
        btn.eventID= event.eventID

        btn.text:SetText(event.tab.text)

        s= btn.text:GetStringWidth()
        if s> width then
            TrackButton.Background:SetPoint(toLeft and 'LEFT' or 'RIGHT', btn.text)
            width= s
        end

        if event.iconTexture then
            btn.texture:SetTexture(event.iconTexture)
            tcoords = _CalendarFrame_GetTextureCoords(event.calendarType, event.eventType)
            btn.texture:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
        else
            if event.tab.atlas then
                btn.texture:SetAtlas(event.tab.atlas)
            else
                btn.texture:SetTexture(event.tab.texture or 0)
            end
             btn.texture:SetTexCoord(0,1,0,1)
        end
	end


    if num>0 then
        local toTop= Save().toTopTrack
        if toLeft then
            TrackButton.Background:SetPoint(toTop and 'BOTTOMRIGHT' or 'TOPRIGHT', _G[Name..1])
            TrackButton.Background:SetPoint(toTop and 'TOPRIGHT' or 'BOTTOMRIGHT', _G[Name..num])
        else
            TrackButton.Background:SetPoint(toTop and 'BOTTOMLEFT' or 'TOPLEFT', _G[Name..1])
            TrackButton.Background:SetPoint(toTop and 'TOPLEFT' or 'BOTTOMLEFT', _G[Name..num])
        end
    end

    if findQuest then
        TrackButton:RegisterEvent('QUEST_COMPLETE')
    else
        TrackButton:UnregisterEvent('QUEST_COMPLETE')
    end

    if (day and not isToDay) then
        TrackButton:SetNormalAtlas('UI-HUD-Calendar-'..day..'-Mouseover')
    else
        TrackButton:SetNormalTexture(0)
    end

    for index= num+1, NumButton do
		btn=_G[Name..index]
		btn.text:SetText('')
		btn:SetShown(false)
		btn:SetNormalTexture(0)
	end

    TrackButton.monthOffset= monthOffset
    TrackButton.day= day
    TrackButton:SetID(day or 0)
end



































local function Init_Menu(self, root)
    --local sub

    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '显示' or SHOW,
    function()
        return not Save().hide
    end, function()
        Save().hide= not Save().hide and true or nil
        self:set_Events()--设置事件
        self:set_Shown()
    end)

    root:CreateDivider()
    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '左' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT,
    function()
        return Save().left
    end, function()
        Save().left= not Save().left and true or nil
        WoWTools_HolidayMixin:Init_TrackButton()
    end)

    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP,
    function()
        return Save().toTopTrack
    end, function()
        Save().toTopTrack = not Save().toTopTrack and true or nil
       WoWTools_HolidayMixin:Init_TrackButton()
    end)

    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '仅限: 正在活动' or LFG_LIST_CROSS_FACTION:format(CALENDAR_TOOLTIP_ONGOING),
    function()
        return Save().onGoing
    end, function()
        Save().onGoing= not Save().onGoing and true or false
        Set_Text()
    end)

    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '时间' or TIME_LABEL,
    function()
        return Save().showDate
    end, function()
        Save().showDate= not Save().showDate and true or nil
        Set_Text()
    end)

    root:CreateDivider()
--缩放
    WoWTools_MenuMixin:Scale(self, root, function()
        return Save().scale or 1
    end, function(value)
        Save().scale=value
        self:settings()
    end)

--背景, 透明度
    WoWTools_MenuMixin:BgAplha(root,
    function()
        return Save().bgAlpha or 0.5
    end, function(value)
        Save().bgAlpha=value
        self:settings()
    end)

--FrameStrata    
    WoWTools_MenuMixin:FrameStrata(root, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().strata= data
        self:settings()
    end)

--重置位置
	root:CreateDivider()
	WoWTools_MenuMixin:RestPoint(self, root, Save().point, function()
		Save().point=nil
		self:set_point()
		print(WoWTools_DataMixin.Icon.icon2..WoWTools_HolidayMixin.addName, WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION)
	end)

--重新加载UI
   -- WoWTools_MenuMixin:Reload(root)

    root:CreateDivider()
    --打开选项界面
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_HolidayMixin.addName})
end






























local function Init()
    --[[TrackButton= WoWTools_ButtonMixin:Cbtn(nil, {
        size=23,
        name='WoWToolsHolidayTrackMainButton'
    })]]
    TrackButton= CreateFrame('Button', 'WoWToolsHolidayTrackMainButton', UIParent, 'WoWToolsButtonTemplate')

--显示背景 Background
    WoWTools_TextureMixin:CreateBG(TrackButton)

    TrackButton.texture= TrackButton:CreateTexture(nil, 'BORDER')
    TrackButton.texture:SetAtlas('Adventure-MissionEnd-Line')
    TrackButton.texture:SetPoint('CENTER')
    TrackButton.texture:SetSize(12,10)


    TrackButton.Frame= CreateFrame('Frame',nil, TrackButton)
    TrackButton.Frame:SetPoint('BOTTOM')
    TrackButton.Frame:SetSize(1,1)

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
                '|cnWARNING_FONT_COLOR:',
                WoWTools_DataMixin.onlyChinese and '保存失败' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SAVE, FAILED)
            )
        end
    end)

    function TrackButton:set_Events()--设置事件
        self:UnregisterAllEvents()
        if Save().hide then
            return
        end
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
            Set_Text()
        end
    end)

    function TrackButton:set_Shown()
        local hide= IsInInstance()
            or C_PetBattles.IsInBattle()
            or UnitInVehicle('player')
            or UnitAffectingCombat('player')

        local showFrame= not hide and not Save().hide

        self:SetShown(not hide)
        self.texture:SetAlpha(Save().hide and 0.7 or 0.3)
        self.Frame:SetShown(showFrame)
        self.Background:SetShown(showFrame)
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
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)


    TrackButton:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)
    TrackButton:SetScript('OnEnter', function(self)
        self:set_Tooltips()
    end)

    function TrackButton:set_point()--设置, 位置
        self:ClearAllPoints()
        if Save().point then
            self:SetPoint(Save().point[1], UIParent, Save().point[3], Save().point[4], Save().point[5])
        else
            self:SetPoint('TOPLEFT', 400, WoWTools_DataMixin.Player.husandro and 0 or -100)
        end
    end



    function TrackButton:settings()
        self:SetFrameStrata(Save().strata or 'MEDIUM')
        self.Frame:SetScale(Save().scale or 1)

        self.Background:SetAlpha(Save().bgAlpha or 0.5)
        self.Background:ClearAllPoints()

        self:set_Shown()
        self:set_Events()
        Set_Text()
    end
    WoWTools_DataMixin:Hook('CalendarDayButton_Click', function(button)
        Set_Text(button.monthOffset, button.day)
    end)
    CalendarFrame:HookScript('OnHide', function()
        Set_Text()
        WoWTools_HolidayMixin:SetTrackButtonState(false)--TrackButton，提示
    end)
    CalendarFrame:HookScript('OnShow', function()
        WoWTools_HolidayMixin:SetTrackButtonState(true)--TrackButton，提示
        C_Timer.After(2, function()
            WoWTools_HolidayMixin:SetTrackButtonState(false)
        end)
    end)

    TrackButton:set_point()
    TrackButton:settings()

    Init=function()
        TrackButton:set_point()
        TrackButton:settings()
        for index= 1, NumButton do
            local btn= _G[Name..index]
            if btn then
                btn:settings()
            end
        end
    end
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