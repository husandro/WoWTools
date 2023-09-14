local id, e = ...
local addName= CALENDAR_FILTER_HOLIDAYS
local Save={
    onGoing=true,--仅限: 正在活动
    --disabled= not e.Player.husandro
    --left=true,--内容靠左
    --showDate= true,--时间
    --showID=true, --节日 ID
}
local panel= CreateFrame('Frame')
local button


















local function _CalendarFrame_SafeGetName(name)
	if ( not name or name == "" ) then
		return UNKNOWN;
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
		["START"]			= CALENDAR_EVENTNAME_FORMAT_START,
		["END"]				= CALENDAR_EVENTNAME_FORMAT_END,
		[""]				= "%s",
		["ONGOING"]			= "%s",
	},
	["RAID_LOCKOUT"] = {
		[""]				= CALENDAR_EVENTNAME_FORMAT_RAID_LOCKOUT,
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
            return e.Icon.select2
        end
    end
end

local CALENDAR_EVENTTYPE_TEXTURES = {
	[Enum.CalendarEventType.Raid]		= "Interface\\LFGFrame\\LFGIcon-Raid",
	[Enum.CalendarEventType.Dungeon]	= "Interface\\LFGFrame\\LFGIcon-Dungeon",
	[Enum.CalendarEventType.PvP]		= e.Player.faction=='Alliance' and "Interface\\Calendar\\UI-Calendar-Event-PVP02"
                                            or (e.Player.faction=='Horde' and "Interface\\Calendar\\UI-Calendar-Event-PVP01")
                                            or "Interface\\Calendar\\UI-Calendar-Event-PVP",
	[Enum.CalendarEventType.Meeting]	= "Interface\\Calendar\\MeetingIcon",
	--[Enum.CalendarEventType.Other]		= "Interface\\Calendar\\UI-Calendar-Event-Other",
}

local function set_Button_Text()--设置,显示内容 Blizzard_Calendar.lua CalendarDayButton_OnEnter(self)
    if Save.hide or not button:IsShown() then
        button.Text:SetText('')
        return
    end

    local monthOffset,day
    local info= C_Calendar.GetEventIndex()
    local info2= C_DateAndTime.GetCurrentCalendarTime()
    if info then
        monthOffset=info.offsetMonths
        day=info.monthDay
    elseif info2 then
        monthOffset=0
        day= info2.monthDay
    end
    if not day or not monthOffset then
        if button.Text then
            button.Text:SetText('')
        end
        return
    end

    local numEvents = C_Calendar.GetNumDayEvents(monthOffset, day);
    if ( numEvents <= 0 ) then
        if button.Text then
            button.Text:SetText('')
        end
		return;
	end

    local events = {};
	for i = 1, numEvents do
		local event = C_Calendar.GetDayEvent(monthOffset, day, i);
        if event then
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
                or info2.monthDay~=day
                or not Save.onGoing
                or (Save.onGoing and  isValid)
            then
                if Save.showDate and isValid and event.eventTime then
                    event.eventTime= '|cnGREEN_FONT_COLOR:'..event.eventTime..'|r'
                end
                event.index= i
                tinsert(events, event);
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

    local text=''
	local findQuest

    if day and info2.monthDay~=day then
        text='|A:UI-HUD-Calendar-'..day..'-Up:0:0|a'
    end

	for _, event in ipairs(events) do
		local title = event.title;
        local msg = ''
        if event.calendarType=='PLAYER' or _CalendarFrame_IsPlayerCreatedEvent(event.calendarType) then--自定义,事件
			local creaText;
			if UnitExists(event.invitedBy) and UnitIsUnit("player", event.invitedBy) then
				if ( event.calendarType == "GUILD_ANNOUNCEMENT" ) then
					creaText = e.Icon.player;
				elseif ( event.calendarType == "GUILD_EVENT" ) then
					creaText = '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '公会' or GUILD)..'|r'
				elseif ( event.calendarType == "COMMUNITY_EVENT") then--社区
					creaText = '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '社区' or COMMUNITIES)..'|r';
                else
					creaText = e.Icon.player
				end
			else
				if _CalendarFrame_IsSignUpEvent(event.calendarType, event.inviteType) then
					local inviteStatusInfo = CalendarUtil.GetCalendarInviteStatusInfo(event.inviteStatus);
					if ( event.inviteStatus == Enum.CalendarStatus.NotSignedup or
							event.inviteStatus == Enum.CalendarStatus.Signedup ) then
						creaText = inviteStatusInfo.name;
					else
						creaText = format(CALENDAR_SIGNEDUP_FOR_GUILDEVENT_WITH_STATUS, inviteStatusInfo.name);
					end
				else
					if ( event.calendarType == "GUILD_ANNOUNCEMENT" ) then
						creaText = format(CALENDAR_ANNOUNCEMENT_CREATEDBY_PLAYER, _CalendarFrame_SafeGetName(event.invitedBy));
					else
						creaText = format(CALENDAR_EVENT_INVITEDBY_PLAYER, _CalendarFrame_SafeGetName(event.invitedBy));
					end
				end
			end
			msg= (creaText or '')
		end

       -- msg= event.iconTexture and msg..'|T'..event.iconTexture..':0|t' or msg

        if ( event.calendarType == "RAID_LOCKOUT" ) then
			title = GetDungeonNameWithDifficulty(title, event.difficultyName);
            msg= msg..format(CALENDAR_CALENDARTYPE_TOOLTIP_NAMEFORMAT[event.calendarType][event.sequenceType], title)
        elseif event.calendarType=='HOLIDAY' and title:find(PLAYER_DIFFICULTY_TIMEWALKER) then--时空漫游
            msg= msg..(e.onlyChinese and '时空漫游' or PLAYER_DIFFICULTY_TIMEWALKER)
        else
            msg= msg..(title:match(': (.+)') or title:match('：(.+)') or title)
        end

        if Save.showDate then--时间
            msg= Save.left and (msg..' '..event.eventTime) or (event.eventTime..' '..msg)
        end

        if Save.showID and event.eventID then--显示 ID
            msg= Save.left and (msg..' |cffffffff'..event.eventID)..'|r' or ('|cffffffff'..event.eventID..'|r '..msg)
        end

        local icon
        if title:find(PVP) or event.eventID==561 then
            icon= '|A:pvptalents-warmode-swords:0:0|a'--pvp
        elseif event.calendarType=='HOLIDAY' and event.eventID then
            if event.eventID==1063
                or event.eventID==616
                or event.eventID==617
                or event.eventID==623
                or event.eventID==629
                or event.eventID==654
                or event.eventID==1068
                or event.eventID==1277
                or event.eventID==1269 then--时光

                local tab={40168, 40173, 40786, 45563, 55499, 40168, 40173, 40787, 45563, 55498, 64710,64709}
                local isCompleted= set_Quest_Completed(tab)--任务是否完成
                local texture= isCompleted or '|A:AutoQuest-Badge-Campaign:0:0|a'
                msg= Save.left and (texture..msg) or (msg..texture)
                findQuest= isCompleted
                icon='|T463446:0|t'--1166[时空扭曲徽章]

            elseif event.eventID==479 then--暗月
                local tab={36471, 32175}
                local isCompleted= set_Quest_Completed(tab)--任务是否完成
                local texture= isCompleted or '|A:AutoQuest-Badge-Campaign:0:0|a'
                msg= Save.left and msg..texture or (texture..msg)

                findQuest=isCompleted
                icon='|T134481:0|t'--515[暗月奖券]


            elseif event.eventID==324 or event.eventID==1405 then--万圣节
               icon= '|T236546:0|t'--33226[奶糖]
            elseif event.eventID==423 then--情人节
                icon='|T235468:0|t'
            elseif event.eventID==181 then
                icon= '|T235477:0|t'
            elseif event.eventID==691 then
                icon='|T1500867:0|t'
            elseif event.iconTexture then
                icon='|T'..event.iconTexture..':0|t'
            end
        end
        
        if CALENDAR_EVENTTYPE_TEXTURES[event.eventType] then
            local texture= '|T'..CALENDAR_EVENTTYPE_TEXTURES[event.eventType]..':0|t'
            icon= Save.left and (texture..(icon or '')) or ((icon or '')..texture)
        end
        
        local invitInfo= C_Calendar.EventGetInvite(event.index)
        if invitInfo and invitInfo.guid then
            local texture= e.GetPlayerInfo({guid=invitInfo.guid})
             icon= Save.left and (texture..(icon or '')) or ((icon or '')..texture)
        end

        if icon then
            msg= Save.left and (icon..msg) or (msg..icon)
        end

        if msg~='' then
            text= text~='' and text..'|n' or text
            text= text..msg..' '
        end
	end

    button:UnregisterEvent('QUEST_COMPLETE')
    if findQuest then
        button:RegisterEvent('QUEST_COMPLETE')
    end
    button.Text:SetText(text)
end


--#####
--主菜单
--#####
local function InitMenu(_, level)--主菜单
    local info={
        text= e.onlyChinese and '内容靠左' or BINDING_NAME_STRAFELEFT,--向左平移
        checked=not Save.left,
        func= function()
            Save.left= not Save.left and true or nil
            button:set_Text_Settings()--设置Tex
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '仅限: 正在活动' or LFG_LIST_CROSS_FACTION:format(CALENDAR_TOOLTIP_ONGOING),
        checked= Save.onGoing,
        func= function()
            Save.onGoing= not Save.onGoing and true or nil
            set_Button_Text()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '时间' or TIME_LABEL,
        checked= Save.showDate,
        func= function()
            Save.showDate= not Save.showDate and true or nil
            set_Button_Text()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '节日 ID' or CALENDAR_FILTER_HOLIDAYS..' ID',--时间
        checked= Save.showID,
        func= function()
            Save.showID= not Save.showID and true or nil
            set_Button_Text()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text=e.onlyChinese and '还原位置' or RESET_POSITION,
        colorCode=not Save.point and '|cff606060',
        func=function()
            Save.point=nil
            button:ClearAllPoints()
            button:set_Point()
        end,
        tooltipOnButton=true,
        tooltipTitle=e.Icon.right..' '..NPE_MOVE,
        notCheckable=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

        --[[info={
            text=e.onlyChinese and '设置' or SETTINGS,
            notCheckable=true,
            menuList='SETTINGS',
            hasArrow=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)]]

        e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text=e.Icon.left..(e.onlyChinese and '显示/隐藏' or (SHOW..'/'..HIDE)),
        isTitle=true,
        notCheckable=true
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
    info={--点击这里显示日历
        text=e.Icon.mid..(e.onlyChinese and '打开/关闭日历' or GAMETIME_TOOLTIP_TOGGLE_CALENDAR ),
        isTitle=true,
        notCheckable=true
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={--提示移动
        text= e.Icon.right..(e.onlyChinese and '移动' or NPE_MOVE),
        isTitle=true,
        notCheckable=true
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text='Alt+'..e.Icon.mid..(e.onlyChinese and '缩放' or UI_SCALE:gsub('UI',''):gusb(INTERFACE_LABEL,''))..(Save.scale or 1),
        isTitle=true,
        notCheckable=true
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text=id..' '..addName,
        isTitle=true,
        notCheckable=true
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end









--####
--初始
--####
local function Init()
    button= e.Cbtn(nil, {icon='hide', size={20,20}})
    button.Text=e.Cstr(button, {color=true})
    button.texture=button:CreateTexture()
    button.texture:SetAllPoints(button)
    button.texture:SetAlpha(0.3)

    button:RegisterForDrag("RightButton")
    button:SetMovable(true)
    button:SetClampedToScreen(true)
    button:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save.point={self:GetPoint(1)}
        Save.point[2]=nil
        e.LibDD:CloseDropDownMenus()
        ResetCursor()
        self:Raise()
    end)
    button:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            Save.hide= not Save.hide and true or nil
            self:set_Button_Text_Event()--设置事件
            set_Button_Text()
            self:set_Texture()
        elseif d=='RightButton' then
            if not self.Menu then
                self.Menu=CreateFrame("Frame", id..addName..'Menu', self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, InitMenu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    button:SetScript('OnMouseUp', function()
        ResetCursor()
    end)
    button:SetScript('OnMouseWheel', function(self, d)--缩放
        if IsAltKeyDown() then
            local sacle=Save.scale or 1
            if d==1 then
                sacle=sacle+0.1
            elseif d==-1 then
                sacle=sacle-0.1
            end
            if sacle>3 then
                sacle=3
            elseif sacle<0.6 then
                sacle=0.6
            end
            print(id, addName, e.onlyChinese and '缩放' or UI_SCALE:gsub('UI',''):gusb(INTERFACE_LABEL,''), sacle)
            Save.scale=sacle
            self:set_Text_Settings()--设置Text
        else
            Calendar_Toggle()
        end
    end)
    button:SetScript('OnLeave', function(self) self.texture:SetAlpha(0.3) end)
    button:SetScript('OnEnter', function(self) self.texture:SetAlpha(1) end)

    function button:set_Texture()--设置，图片
        self.texture:SetAtlas(Save.hide and e.Icon.disabled or e.Icon.icon)
    end
    button:set_Texture()

    function button:set_Point()--设置, 位置
        if Save.point then
            self:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
        else
            self:SetPoint('BOTTOMRIGHT', ObjectiveTrackerBlocksFrame, 'TOPLEFT', -35, -10)
        end
    end
    button:set_Point()

    button:RegisterEvent('PLAYER_ENTERING_WORLD')
    function button:set_Button_Text_Event(hide)--设置事件
        if Save.hide or hide then
            self:UnregisterEvent('CALENDAR_UPDATE_EVENT_LIST')
            self:UnregisterEvent('CALENDAR_UPDATE_EVENT')
            self:UnregisterEvent('CALENDAR_NEW_EVENT')
            self:UnregisterEvent('CALENDAR_OPEN_EVENT')
            self:UnregisterEvent('CALENDAR_CLOSE_EVENT')
        else
            self:RegisterEvent('CALENDAR_UPDATE_EVENT_LIST')
            self:RegisterEvent('CALENDAR_UPDATE_EVENT')
            self:RegisterEvent('CALENDAR_NEW_EVENT')
            self:RegisterEvent('CALENDAR_OPEN_EVENT')
            self:RegisterEvent('CALENDAR_CLOSE_EVENT')
        end
    end

    function button:set_IsInInstancer_Event(isInInstance)
        if isInInstance then
            self:UnregisterEvent('PLAYER_REGEN_DISABLED')
            self:UnregisterEvent('PLAYER_REGEN_ENABLED')
        else
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
        end
        self:SetShown(not isInInstance)
    end

    button:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_ENTERING_WORLD' then
            C_Timer.After(2, function()
                local isInInstance= IsInInstance()
                self:set_IsInInstancer_Event(isInInstance)
                self:set_Button_Text_Event(isInInstance)
                set_Button_Text()
            end)
        elseif event=='PLAYER_REGEN_DISABLED' then
            self:SetShown(false)
            set_Button_Text()

        elseif event=='PLAYER_REGEN_ENABLED' then
            self:SetShown(true)
            set_Button_Text()

        else
            set_Button_Text()
        end
    end)

    button:set_Button_Text_Event(IsInInstance())
    button:set_IsInInstancer_Event(IsInInstance())

    function button:set_Text_Settings()--设置，Text， 属性
        self.Text:SetJustifyH(Save.left and 'LEFT' or  'RIGHT' )
        self.Text:ClearAllPoints()
        if Save.left then
            self.Text:SetPoint('TOPLEFT', self, 'TOPRIGHT')
        else
            self.Text:SetPoint('TOPRIGHT', self, 'TOPLEFT')
        end
        self.Text:SetScale(Save.scale or 1)
        set_Button_Text()
    end
    button:set_Text_Settings()
end
















--#########
--初始，插件
--#########
local function Init_Blizzard_Calendar()
    local function calendar_Uptate()
        local indexInfo = C_Calendar.GetEventIndex()
        local info= indexInfo and C_Calendar.GetDayEvent(indexInfo.offsetMonths, indexInfo.monthDay, indexInfo.eventIndex)
        local text
        if info and info.eventID then
            text= (info.iconTexture and '|T'..info.iconTexture..':0|t'..info.iconTexture or '')
                ..'  eventID '..info.eventID
                ..(info.title and '|n'..info.title or '')
        end
        if text and not CalendarViewHolidayFrame.Text then
            CalendarViewHolidayFrame.Text= e.Cstr(CalendarViewHolidayFrame)
            CalendarViewHolidayFrame.Text:SetPoint('BOTTOMLEFT',12,12)
            CalendarViewHolidayFrame.Texture2=CalendarViewHolidayFrame:CreateTexture()
            local w,h= CalendarViewHolidayFrame:GetSize()
            CalendarViewHolidayFrame.Texture2:SetSize(w-70, h-70)
            CalendarViewHolidayFrame.Texture2:SetPoint('CENTER',40,-40)
            CalendarViewHolidayFrame.Texture2:SetAlpha(0.5)
        end
        if CalendarViewHolidayFrame.Text then
            CalendarViewHolidayFrame.Text:SetText(text or '')
            CalendarViewHolidayFrame.Texture2:SetTexture(info.iconTexture or 0)
        end
    end

    if CalendarViewHolidayFrame.update then
        hooksecurefunc(CalendarViewHolidayFrame, 'update', calendar_Uptate)--提示节目ID
    end
    hooksecurefunc('CalendarViewHolidayFrame_Update', calendar_Uptate)

    hooksecurefunc('CalendarCreateEventInviteListScrollFrame_Update', function()
        local namesReady = C_Calendar.AreNamesReady();
        if namesReady then
            for index, button in pairs(CalendarCreateEventInviteList.ScrollBox:GetFrames()) do--ScrollBox.lua
                local inviteInfo = C_Calendar.EventGetInvite(index)
                if inviteInfo and inviteInfo.guid then
                   button.Class:SetText(e.GetPlayerInfo({guid=inviteInfo.guid, name=inviteInfo.name}))
                end
            end
        end
    end)


    --Blizzard_Calendar.lua
    CalendarCreateEventFrame:SetScript('OnShow', function(self)
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
                            text=text..e.Icon.map2
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
        self.menu.Button:SetScript('OnClick', function(self2)
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
                            text= text..e.Icon.map2
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
        menu2.Button:SetScript('OnClick', function(self2)
            e.LibDD:ToggleDropDownMenu(1, nil, self2:GetParent(), self2, 15, 0)
        end)

        local last=CreateFrame("Frame", nil, CalendarCreateEventFrame, "UIDropDownMenuTemplate")
        last:SetPoint('TOPRIGHT', menu2, 'BOTTOMRIGHT')
        e.LibDD:UIDropDownMenu_SetWidth(last, 60)
        e.LibDD:UIDropDownMenu_SetText(last, e.onlyChinese and '公会' or GUILD)
        e.LibDD:UIDropDownMenu_Initialize(last, function(self2, level, type)
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
                        text= zone==map and text..e.Icon.map2 or text..' '..zone
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
        last.Button:SetScript('OnClick', function(self2)
            e.LibDD:CloseDropDownMenus()
            e.LibDD:ToggleDropDownMenu(1, nil, self2:GetParent(), self2, 15, 0)
        end)
    end)

    CalendarFrame:HookScript('OnHide', set_Button_Text)
end

















panel:RegisterEvent('ADDON_LOADED')
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save


            --添加控制面板
            e.AddPanel_Check({
                name= '|A:GarrisonTroops-Health:0:0|a'..(e.onlyChinese and '节日' or addName),
                tooltip= addName,
                value= not Save.disabled,
                func= function()
                    Save.disabled = not Save.disabled and true or nil
                    print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                end
            })

            --[[添加控制面板        
            local sel=e.AddPanel_Check('|A:GarrisonTroops-Health:0:0|a'..(e.onlyChinese and '节日' or addName), not Save.disabled, true)
            sel:SetScript('OnMouseDown', function()
                Save.disabled = not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
            end)]]

            if  Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()--初始
                if not IsAddOnLoaded("Blizzard_Calendar") then--加载
                    LoadAddOn("Blizzard_Calendar")
                    Calendar_Toggle()
                    C_Calendar.OpenCalendar()
                    C_Timer.After(2, function()
                        if CalendarFrame and CalendarFrame:IsShown() then
                            Calendar_Toggle()
                        end
                    end)
                end
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_Calendar' then
            Init_Blizzard_Calendar()--初始，插件
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)
