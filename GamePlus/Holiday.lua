local id, e = ...
local addName= CALENDAR_FILTER_HOLIDAYS
local Save={onGoing=true, disabled= not e.Player.husandro}
local panel= e.Cbtn(nil, {icon='hide', size={18,18}})

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
        local time=GetTime()
        if (init and time< seconds) or (not init and time> seconds) then
            return '|cnRED_FONT_COLOR:'..eventTime..'|r'
        end
    end
    return eventTime
end

local function set_Quest_Completed(tab)--任务是否完成
    for _, questID in pairs(tab) do
        local completed= C_QuestLog.IsQuestFlaggedCompleted(questID)
        if completed then
            return e.Icon.select2
        end
    end
    return ''
end

local function set_Text()--设置,显示内容 Blizzard_Calendar.lua CalendarDayButton_OnEnter(self)
    panel.texture:SetShown(Save.hide)

    if Save.hide then
        if panel.Text then
            panel.Text:SetText('')
        end
        return
    end

    panel:SetButtonState('PUSHED')

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
        if panel.Text then
            panel.Text:SetText('')
        end
        return
    end

    local numEvents = C_Calendar.GetNumDayEvents(monthOffset, day);
    if ( numEvents <= 0 ) then
        if panel.Text then
            panel.Text:SetText('')
        end
		return;
	end

    local events = {};
	for i = 1, numEvents do
		local event = C_Calendar.GetDayEvent(monthOffset, day, i);
        if event then
            if _CalendarFrame_IsPlayerCreatedEvent(event.calendarType)
                or info2.monthDay~=day
                or (Save.onGoing and event.sequenceType == "ONGOING" or not Save.onGoing)
            then
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

    local Text2=''
	local eventTime, find_Quest

    if day and info2.monthDay~=day then
        Text2='|A:UI-HUD-Calendar-'..day..'-Up:0:0|a'
    end

	for _, event in ipairs(events) do
		local title = event.title;
        local msg = ''

        if title:find(PVP) then
            msg= msg..'|A:pvptalents-warmode-swords:0:0|a'--pvp
        elseif event.calendarType=='HOLIDAY' and event.eventID then
            if event.eventID==1063 or event.eventID==617 or event.eventID==623 or event.eventID==629 or event.eventID==654 or event.eventID==1068 or event.eventID==1277 or event.eventID==1269 then--时光
                local tab={40168, 40173, 40786, 45563, 55499, 40168, 40173, 40787, 45563, 55498, 64710,64709}
                msg= msg..set_Quest_Completed(tab)--任务是否完成
                find_Quest=true
                msg= msg..'|T463446:0|t'--1166[时空扭曲徽章]

            elseif event.eventID==479 then--暗月
                local tab={36471, 32175}
                msg= msg..set_Quest_Completed(tab)--任务是否完成
                msg= msg..'|T134481:0|t'--515[暗月奖券]
                find_Quest=true

            elseif event.eventID==324 then--万圣节
               msg= msg..'|T236546:0|t'--33226[奶糖]
            elseif event.eventID==423 then--情人节
                msg= msg..'|T235468:0|t'
            elseif event.eventID==181 then
                msg= msg..'|T235477:0|t'
            elseif event.eventID==691 then
                msg= msg..'|T1500867:0|t'
            elseif event.iconTexture then
                msg= msg..'|T'..event.iconTexture..':0|t'
            end
        end


        if event.calendarType=='PLAYER' or _CalendarFrame_IsPlayerCreatedEvent(event.calendarType) then--自定义,事件
			local text;
			if event.invitedBy and UnitIsUnit("player", event.invitedBy) then
				if ( event.calendarType == "GUILD_ANNOUNCEMENT" ) then
					text = e.Icon.player;
				elseif ( event.calendarType == "GUILD_EVENT" ) then
					text = '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '公会' or GUILD)..'|r'
				elseif ( event.calendarType == "COMMUNITY_EVENT") then--社区
					text = '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '社区' or COMMUNITIES)..'|r';
                else
					text = e.Icon.player
				end
			else
				if _CalendarFrame_IsSignUpEvent(event.calendarType, event.inviteType) then
					local inviteStatusInfo = CalendarUtil.GetCalendarInviteStatusInfo(event.inviteStatus);
					if ( event.inviteStatus == Enum.CalendarStatus.NotSignedup or
							event.inviteStatus == Enum.CalendarStatus.Signedup ) then
						text = inviteStatusInfo.name;
					else
						text = format(CALENDAR_SIGNEDUP_FOR_GUILDEVENT_WITH_STATUS, inviteStatusInfo.name);
					end
				else
					if ( event.calendarType == "GUILD_ANNOUNCEMENT" ) then
						text = format(CALENDAR_ANNOUNCEMENT_CREATEDBY_PLAYER, _CalendarFrame_SafeGetName(event.invitedBy));
					else
						text = format(CALENDAR_EVENT_INVITEDBY_PLAYER, _CalendarFrame_SafeGetName(event.invitedBy));
					end
				end
			end
			msg= msg..(text or '')
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

        if Save.showDate then
            if (event.sequenceType == "ONGOING") then
                eventTime = format(CALENDAR_TOOLTIP_DATE_RANGE, FormatShortDate(event.startTime.monthDay, event.startTime.month), FormatShortDate(event.endTime.monthDay, event.endTime.month));
            elseif (event.sequenceType == "END") then
                eventTime = GameTime_GetFormattedTime(event.endTime.hour, event.endTime.minute, true);
                eventTime= set_Time_Color(eventTime, event.startTime.hour, event.startTime.minute)
            else
                eventTime = GameTime_GetFormattedTime(event.startTime.hour, event.startTime.minute, true);
                eventTime= set_Time_Color(eventTime, event.startTime.hour, event.startTime.minute, true)
            end
            msg= msg..' '..eventTime
        end

        if Save.showID and event.eventID then--显示 ID
            msg= msg..' '..event.eventID
        end

        if msg~='' then
            Text2= Text2~='' and Text2..'\n' or Text2
            Text2= Text2..msg..' '
        end
	end

    if find_Quest then
        panel:RegisterEvent('QUEST_COMPLETE')
    else
        panel:UnregisterEvent('QUEST_COMPLETE')
    end
    panel.Text:SetText(Text2)

    C_Timer.After(1, function()
        panel:SetButtonState('NORMAL')
    end)
end

local function set_event()--设置事件
    if Save.hide then
        panel:UnregisterEvent('CALENDAR_UPDATE_EVENT_LIST')
        panel:UnregisterEvent('CALENDAR_UPDATE_EVENT')
        panel:UnregisterEvent('CALENDAR_NEW_EVENT')
        panel:UnregisterEvent('CALENDAR_OPEN_EVENT')
        panel:UnregisterEvent('CALENDAR_CLOSE_EVENT')
    else
        panel:RegisterEvent('CALENDAR_UPDATE_EVENT_LIST')
        panel:RegisterEvent('CALENDAR_UPDATE_EVENT')
        panel:RegisterEvent('CALENDAR_NEW_EVENT')
        panel:RegisterEvent('CALENDAR_OPEN_EVENT')
        panel:RegisterEvent('CALENDAR_CLOSE_EVENT')
    end
end

local function Text_Settings()--设置Text
    if panel.Text then
        panel.Text:SetJustifyH(Save.left and 'LEFT' or  'RIGHT' )
        panel.Text:ClearAllPoints()
        panel.Text:SetPoint(Save.left and 'TOPLEFT' or 'TOPRIGHT')
        if Save.classColor then
            panel.Text:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
        else
            panel.Text:SetTextColor(0.8, 0.8, 0.8)
            e.Cstr(nil, {changeFont=panel.Text, color=true})--nil,nil,panel.Text,true)
        end
        if Save.scale then
            panel.Text:SetScale(Save.scale)
        end
    end
    C_Timer.After(2, set_Text)
end

--#####
--主菜单
--#####
local function InitMenu(self, level, type)--主菜单
    local info
    if type then
        info={
            text= e.onlyChinese and '内容靠左' or BINDING_NAME_STRAFELEFT,--向左平移
            checked= Save.left,
            func= function()
                Save.left= not Save.left and true or nil
                Text_Settings()--设置Tex
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinese and '职业颜色' or CLASS_COLORS,
            checked= Save.classColor,
            func= function()
                Save.classColor= not Save.classColor and true or nil
                Text_Settings()--设置Tex
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinese and '仅限: 正在活动' or LFG_LIST_CROSS_FACTION:format(CALENDAR_TOOLTIP_ONGOING),
            checked= Save.onGoing,
            func= function()
                Save.onGoing= not Save.onGoing and true or nil
                set_Text()
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinese and '时间' or TIME_LABEL,
            checked= Save.showDate,
            func= function()
                Save.showDate= not Save.showDate and true or nil
                set_Text()
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinese and '节日 ID' or CALENDAR_FILTER_HOLIDAYS..' ID',--时间
            checked= Save.showID,
            func= function()
                Save.showID= not Save.showID and true or nil
                set_Text()
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text=e.onlyChinese and '还原位置' or RESET_POSITION,
            colorCode=not Save.point and '|cff606060',
            func=function()
                Save.point=nil
                panel:ClearAllPoints()
                panel:SetPoint('TOP', Minimap, 'BOTTOM',-20,0)
            end,
            tooltipOnButton=true,
            tooltipTitle=e.Icon.right..' '..NPE_MOVE,
            notCheckable=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    else
        info={
            text=e.onlyChinese and '设置' or SETTINGS,
            notCheckable=true,
            menuList='SETTINGS',
            hasArrow=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

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
            text='Alt+'..e.Icon.mid..(e.onlyChinese and '缩放' or UI_SCALE)..(Save.scale or 1),
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
end

--####
--初始
--####
local function Init()
    panel.Text=e.Cstr(panel, {color=true})--nil,nil,nil,true)
    panel.texture=panel:CreateTexture()
    panel.texture:SetAllPoints(panel)
    panel.texture:SetAtlas(e.Icon.icon)
    panel.texture:SetAlpha(0.5)
    if Save.point then
        panel:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
    else
        panel:SetPoint('TOP', Minimap, 'BOTTOM',-20,0)
    end

    panel:RegisterForDrag("RightButton")
    panel:SetMovable(true)
    panel:SetClampedToScreen(true)
    panel:SetScript("OnDragStart", function(self,d)
        --if IsAltKeyDown() then
            self:StartMoving()
        --end
    end)
    panel:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save.point={self:GetPoint(1)}
        Save.point[2]=nil
        e.LibDD:CloseDropDownMenus()
        ResetCursor()
    end)
    panel:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            Save.hide= not Save.hide and true or nil
            set_event()--设置事件
            set_Text()
        elseif d=='RightButton' then
            if not self.Menu then
                self.Menu=CreateFrame("Frame", id..addName..'Menu', self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, InitMenu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    panel:SetScript('OnMouseUp', function()
        ResetCursor()
    end)
    panel:SetScript('OnMouseWheel', function(self, d)--缩放
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
            print(id, addName, e.onlyChinese and '缩放' or UI_SCALE, sacle)
            Save.scale=sacle
            Text_Settings()--设置Text
        else
            Calendar_Toggle()
        end
    end)

    

    set_event()
    Text_Settings()--设置Text

    local function calendar_Uptate()
        local indexInfo = C_Calendar.GetEventIndex()
        local info= indexInfo and C_Calendar.GetDayEvent(indexInfo.offsetMonths, indexInfo.monthDay, indexInfo.eventIndex)
        local text
        if info and info.eventID then
            text= (info.iconTexture and '|T'..info.iconTexture..':0|t'..info.iconTexture or '')
                ..'  eventID '..info.eventID
                ..(info.title and '\n'..info.title or '')
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
                   button.Class:SetText(e.GetPlayerInfo({unit=nil, guid=inviteInfo.guid, name=inviteInfo.name,  reName=false, reRealm=false, reLink=false}))
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
        e.LibDD:UIDropDownMenu_Initialize(self.menu, function(self, level, type)
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
                if wowInfo and wowInfo.playerGuid and wowInfo.characterName and not inviteTab[wowInfo.characterName] then

                    local text= e.GetPlayerInfo({unit=nil, guid=wowInfo.playerGuid, name=wowInfo.characterName,  reName=true, reRealm=true, reLink=false})--角色信息
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
        e.LibDD:UIDropDownMenu_Initialize(menu2, function(self, level, type)
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
                    local text=e.GetPlayerInfo({unit=nil, guid=game.guid, name=game.name,  reName=true, reRealm=true, reLink=false})--角色信息
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
        menu2.Button:SetScript('OnClick', function(self2)
            e.LibDD:ToggleDropDownMenu(1, nil, self2:GetParent(), self2, 15, 0)
        end)

        local last=CreateFrame("Frame", nil, CalendarCreateEventFrame, "UIDropDownMenuTemplate")
        last:SetPoint('TOPRIGHT', menu2, 'BOTTOMRIGHT')
        e.LibDD:UIDropDownMenu_SetWidth(last, 60)
        e.LibDD:UIDropDownMenu_SetText(last, e.onlyChinese and '公会' or GUILD)
        e.LibDD:UIDropDownMenu_Initialize(last, function(self2, level, type)
            local map=e.GetUnitMapName('player');--玩家区域名称
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
                    local text=e.GetPlayerInfo({unit=nil, guid=guid, name=name,  reName=true, reRealm=true, reLink=false})--名称
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
                        func=function(self3, arg1)
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
end


panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_ENTERING_WORLD')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel('|A:GarrisonTroops-Health:0:0|a'..(e.onlyChinese and '节日' or addName), not Save.disabled, true)
            sel:SetScript('OnMouseDown', function()
                Save.disabled = not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
            end)

            if  Save.disabled then
                panel:UnregisterAllEvents()
                panel:SetShown(false)
            else
                if not IsAddOnLoaded("Blizzard_Calendar") then--加载
                    LoadAddOn("Blizzard_Calendar")
                    Calendar_Toggle()
                    C_Calendar.OpenCalendar()
                    Calendar_Toggle()
                else
                    Init()--初始
                    panel:UnregisterEvent('ADDON_LOADED')
                end
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_Calendar' then
            Init()--初始
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    elseif event=='PLAYER_ENTERING_WORLD' then
        if IsInInstance() and not Save.hide then
            Save.hide= true
            Text_Settings()--设置Text
        end

    else
        set_Text()
    end
end)
