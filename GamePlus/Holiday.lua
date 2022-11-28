local id, e = ...
local addName=	CALENDAR_FILTER_HOLIDAYS
local Save={}
local panel= e.Cbtn(UIParent, nil, nil, nil, nil, true, {20,20})
--[[

local TimewarpedBadgeDayID={40168, 40173, 40786, 45563, 55499, 40168, 40173, 40787, 45563, 55498, 64710,64709}--任务是否完成
local Get=function(ID, name)
    local info = C_CurrencyInfo.GetCurrencyInfo(ID)
    local Q, icon
    if info then
        Q=info.quantity--数量
        icon=info.iconFileID--图标
    elseif GetItemInfoInstant(ID) then
        Q=GetItemCount(ID,true)
        icon=GetItemIcon(ID)
    end
    if not Q or  Q==0 then
        return name
    end
    local text= (icon and '|T'.. icon..':0|t' or '')..(name.. '')..e.MK(Q)
    if ID==1166 then --时空扭曲徽章                  
        local t
        for _,v in pairs(TimewarpedBadgeDayID) do
            if C_QuestLog.IsQuestFlaggedCompleted(v) then
                t=true
                break
            end
        end
        if t then
            text= text..'|cnGREEN_FONT_COLOR:'..COMPLETE..'|r'..e.Icon.select2
        else
            text= text..'|cnRED_FONT_COLOR:'..INCOMPLETE..'|r'..e.Icon.X2
        end
    elseif ID==515 then--暗月
        if C_QuestLog.IsQuestFlaggedCompleted(36471) and C_QuestLog.IsQuestFlaggedCompleted(32175) then
            text= text..e.Icon.select2
        else
            text= text..e.Icon.O2
        end
    elseif ID==33226 then--万圣节
        for i=1 ,GetNumRandomDungeons() do--随机地下城
            local Eid = GetLFGRandomDungeonInfo(i)
            if Eid and Eid==285 then --285 无头骑士
                local N=GetLFGDungeonInfo(Eid)
                if N then
                    text= text..' ('.. N ..')'
                end
                if GetLFGDungeonRewards(Eid)  then
                    text= text..e.Icon.select2
                else
                    text= text..O2
                end
                break
            end
        end
    end
    return text
end

]]


local function _CalendarFrame_SafeGetName(name)
	if ( not name or name == "" ) then
		return UNKNOWN;
	end
	return name;
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
local function _CalendarFrame_IsPlayerCreatedEvent(calendarType)
	return
		calendarType == "PLAYER" or
		calendarType == "GUILD_ANNOUNCEMENT" or
		calendarType == "GUILD_EVENT" or
		calendarType == "COMMUNITY_EVENT";
end

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

local function get_Currency_Info(currencyID)--货币,数量
    local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
    if info and info.quantity and info.quantity>0  then
        return (info.iconFileID and '|T'..info.iconFileID..':0|t' or '').. e.MK(info.quality, 0)
    end                       
end

local function set_Quest_Completed(tab)--任务是否完成
    for _, questID in pairs(tab) do 
        if C_QuestLog.IsQuestFlaggedCompleted(questID) then
            return e.Icon.select2
        end                    
    end
    return e.Icon.info2
end

local function set_Item_Numeri(itemID) 
    local texture = C_Item.GetItemIconByID(itemID)
    local num= GetItemCount(itemID, true)
    if num and num>0 then
        return (texture and '|T'..texture..':0|t' or '')..num
    end
end


local function set_Text()--设置,显示内容 Blizzard_Calendar.lua CalendarDayButton_OnEnter(self)
    panel.texture:SetShown(Save.hide)
    if Save.hide or Save.disabled then
        if panel.Text then
            panel.Text:SetText('')
        end
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
	local events = {};
	for i = 1, C_Calendar.GetNumDayEvents(monthOffset, day) do
		local event = C_Calendar.GetDayEvent(monthOffset, day, i);
		if event and (not Save.ongoing or (Save.ongoing and (event.sequenceType == "ONGOING" or _CalendarFrame_IsPlayerCreatedEvent(event.calendarType)))) then
			tinsert(events, event);
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

    local msg
	local eventTime
    if day and info2.monthDay~=day then
        msg='|A:UI-HUD-Calendar-'..day..'-Up:0:0|a'
    end
	for _, event in ipairs(events) do
		local title = event.title;
        msg =msg and msg..'\n' or ''

        if  (event.calendarType=='HOLIDAY' and not event.iconTexture) then
            if title:find(PVP) then
                msg=msg..'|A:pvptalents-warmode-swords:0:0|a'--pvp
            else
                msg= msg..e.Icon.star2--节日
            end
        end

        if ( _CalendarFrame_IsPlayerCreatedEvent(event.calendarType) ) then--自定义,事件
			local text;
			if ( UnitIsUnit("player", event.invitedBy) ) then
				if ( event.calendarType == "GUILD_ANNOUNCEMENT" ) then
					text = e.Icon.player;
				elseif ( event.calendarType == "GUILD_EVENT" ) then
					text = '|cnGREEN_FONT_COLOR:'..GUILD..'|r'
				elseif ( event.calendarType == "COMMUNITY_EVENT") then--社区
					text = '|cnGREEN_FONT_COLOR:'..COMMUNITIES..'|r';
				else
					text = e.Icon.player
				end
			else
				if ( _CalendarFrame_IsSignUpEvent(event.calendarType, event.inviteType) ) then
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
			msg=msg..text           
		end

        msg= event.iconTexture and msg..'|T'..event.iconTexture..':0|t' or msg

        if ( event.calendarType == "RAID_LOCKOUT" ) then
			title = GetDungeonNameWithDifficulty(title, event.difficultyName);
            msg=msg..format(CALENDAR_CALENDARTYPE_TOOLTIP_NAMEFORMAT[event.calendarType][event.sequenceType], title)
        elseif event.calendarType=='HOLIDAY' and title:find(PLAYER_DIFFICULTY_TIMEWALKER) then--时空漫游
            msg= msg..PLAYER_DIFFICULTY_TIMEWALKER
        else
            msg= msg.. title
        end

        if Save.showDate then
            if (event.sequenceType == "ONGOING") then
                --msg=msg..CALENDAR_TOOLTIP_ONGOING
                
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

        if event.calendarType=='HOLIDAY' and event.eventID then
            if event.eventID==617 or event.eventID==623 or event.eventID==629 or event.eventID==654 or event.eventID==1068 or event.eventID==1277 or event.eventID==1269 then--时光
                local text= get_Currency_Info(1166)--1166[时空扭曲徽章]
                msg= text and msg..text or msg
                local tab={40168, 40173, 40786, 45563, 55499, 40168, 40173, 40787, 45563, 55498, 64710,64709}
                msg= msg..set_Quest_Completed(tab)--任务是否完成

            elseif event.eventID==479 then--暗月
                msg=msg ..(set_Item_Numeri(515) or '')--515[暗月奖券]
                if C_QuestLog.IsQuestFlaggedCompleted(36471) and C_QuestLog.IsQuestFlaggedCompleted(32175) then
                    msg= msg..e.Icon.select2
                else
                    msg= msg..e.Icon.info2
                end
            
            elseif event.eventID==324 then--万圣节                
                msg=msg ..(set_Item_Numeri(33226) or '')--33226[奶糖]
            end

            msg= Save.showID and msg..' '..event.eventID or msg--显示 ID
        end
	end
    msg= msg and msg..'\n'
    panel.Text:SetText(msg or '')
end

   --[[
    local currentCalendarTime= C_Calendar.GetEventIndex() or C_DateAndTime.GetCurrentCalendarTime()
 local month=currentCalendarTime.month 0;

    local day=currentCalendarTime.monthDay
    --local hour=currentCalendarTime.hour
    --local minute= currentCalendarTime.minute
    --local HolidayInfo= C_Calendar.GetHolidayInfo(monthOffset, monthDay, index)

    local n=C_Calendar.GetNumDayEvents(month, day) or 0--当前节日数量
    for i=1, n do
        local event = C_Calendar.GetDayEvent(month, day, i)--节日信息
        if event and event.eventID  and event.title then
            
--            if event.sequenceType~='END' then -- and event.calendarType=='HOLIDAY' then
                text= text and text..'\n' or ''
                if (event.eventID==617 or event.eventID==623 or event.eventID==629 or event.eventID==654 or event.eventID==1068 or event.eventID==1277)  then--时光
                    text= text.. Get(1166, event.title)--1166[时空扭曲徽章]
                elseif event.eventID==479 then--暗月
                    text= text.. Get(515, event.title)--515[暗月奖券]
                elseif event.eventID==324 then--万圣节                
                    text= text.. Get(33226, event.title)-- 33226[奶糖]
                elseif event.eventID==1225 then--十七周年
                    text= text.. event.title
                    local t=C_QuestLog.IsQuestFlaggedCompleted(60215)--周任务是否完成
                    if t then
                        text=text..e.Icon.select2
                    elseif t==false then
                        text= text ..e.Icon.X2
                    end
                else
                    text= text..event.title
                end
        end
    end

]]


local function set_event()--设置事件
    if Save.disabled then
        panel:UnregisterAllEvents()
    else
        panel:RegisterEvent('CALENDAR_UPDATE_EVENT_LIST')
        --panel:RegisterEvent('QUEST_COMPLETE')
        panel:RegisterEvent('CALENDAR_UPDATE_EVENT')
        panel:RegisterEvent('CALENDAR_NEW_EVENT')
        --panel:RegisterEvent('BAG_UPDATE_DELAYED')
        panel:RegisterEvent('CALENDAR_OPEN_EVENT')
        --panel:RegisterEvent('LFG_UPDATE_RANDOM_INFO')
        panel:RegisterEvent('CALENDAR_CLOSE_EVENT')
        panel:RegisterEvent('BAG_UPDATE_DELAYED')
        panel:RegisterEvent('QUEST_COMPLETE')
        
    end
    panel:RegisterEvent('ADDON_LOADED')
    panel:RegisterEvent("PLAYER_LOGOUT")
    
end

local function Text_Settings()--设置Text
    if panel.Text then
        panel.Text:SetJustifyH(Save.left and 'LEFT' or  'RIGHT' )
        panel.Text:ClearAllPoints()
        panel.Text:SetPoint(Save.left and 'TOPLEFT' or 'TOPRIGHT')
        if Save.classColor then
            local r,g,b= GetClassColor(UnitClassBase('player'))
            panel.Text:SetTextColor(r,g,b)
        else
            panel.Text:SetTextColor(0.8, 0.8, 0.8)
        end
        if Save.scale then
            panel.Text:SetScale(Save.scale)
        end
    end
    panel:SetShown(not Save.disabled)

    C_Timer.After(2, set_Text)
end

--#####
--主菜单
--#####
local function InitMenu(self, level, type)--主菜单
    local info
    if type then
        info={
            text= BINDING_NAME_STRAFELEFT,--向左平移
            checked= Save.left,
            func= function() 
                Save.left= not Save.left and true or nil
                Text_Settings()--设置Tex
            end
        }
        UIDropDownMenu_AddButton(info, level)

        info={
            text= CLASS_COLORS,--	职业颜色
            checked= Save.classColor,
            func= function() 
                Save.classColor= not Save.classColor and true or nil
                Text_Settings()--设置Tex
            end
        }
        UIDropDownMenu_AddButton(info, level)
        
        info={
            text= LFG_LIST_CROSS_FACTION:format(CALENDAR_TOOLTIP_ONGOING),--仅限,正在活动
            checked= Save.ongoing,
            func= function() 
                Save.ongoing= not Save.ongoing and true or nil
                set_Text()
            end
        }
        UIDropDownMenu_AddButton(info, level)
        info={
            text= TIME_LABEL,--时间
            checked= Save.showDate,
            func= function() 
                Save.showDate= not Save.showDate and true or nil
                set_Text()
            end
        }
        UIDropDownMenu_AddButton(info, level)
        info={
            text= CALENDAR_FILTER_HOLIDAYS..' ID',--时间
            checked= Save.showID,
            func= function() 
                Save.showID= not Save.showID and true or nil
                set_Text()
            end
        }
        UIDropDownMenu_AddButton(info, level)

        UIDropDownMenu_AddSeparator(level)
        info={
            text=RESET_POSITION,--还原位置
            colorCode=not Save.point and '|cff606060',
            func=function()
                Save.point=nil
                panel:ClearAllPoints()
                panel:SetPoint('TOPRIGHT', Minimap, 'BOTTOMLEFT',45,20)
            end,
            tooltipOnButton=true,
            tooltipTitle='Alt +'..e.Icon.right..' '..NPE_MOVE,
            notCheckable=true,
        }
        UIDropDownMenu_AddButton(info, level)

        
    else
        info={
            text=SETTINGS,
            notCheckable=true,
            menuList='SETTINGS',
            hasArrow=true,
        }
        UIDropDownMenu_AddButton(info, level)
        UIDropDownMenu_AddSeparator(level)
        info={--提示移动
            text='Alt+'..e.Icon.right..NPE_MOVE,
            isTitle=true,
            notCheckable=true
        }
        UIDropDownMenu_AddButton(info, level)
        info={
            text='Alt+'..e.Icon.mid..UI_SCALE..(Save.scale or ''),
            isTitle=true,
            notCheckable=true
        }
        UIDropDownMenu_AddButton(info, level)
    end
end

--####
--初始
--####
local function Init()
    local btn=e.Cbtn(CalendarFrame, nil, not Save.disabled, nil, nil, nil, {25,25})
    btn:SetPoint('TOPRIGHT', CalendarFrame, 'TOPRIGHT', -20, -18)
    btn:SetScript('OnMouseDown', function()
        Save.disabled= not Save.disabled and true or nil
        set_event()--设置事件
        Text_Settings()--设置Text
    end)
    btn:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(e.GetShowHide(not Save.disabled), e.Icon.left)
        e.tips:Show()
    end)
    btn:SetScript('OnLeave', function() e.tips:Hide() end)

    panel.Text=e.Cstr(panel)
    --panel.Text:SetIndentedWordWrap(true)

    panel.texture=panel:CreateTexture()
    panel.texture:SetAllPoints(panel)
    panel.texture:SetAtlas(e.Icon.icon)
    panel.texture:SetAlpha(0.5)
    if Save.point then
        panel:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
    else
        panel:SetPoint('TOPRIGHT', Minimap, 'BOTTOMLEFT',45,20)
    end

    panel:RegisterForDrag("RightButton")
    panel:SetMovable(true)
    panel:SetClampedToScreen(true)
    panel:SetScript("OnDragStart", function(self,d )
        if IsAltKeyDown() and d=='RightButton' then
            self:StartMoving()
        end
    end)
    panel:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save.point={self:GetPoint(1)}
        Save.point[2]=nil
    end)
    panel:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' and not IsModifierKeyDown() then
            Save.hide= not Save.hide and true or nil
            set_Text()
        elseif d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        else
            ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
        end
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
            print(id, addName, UI_SCALE, sacle)
            Save.scale=sacle
            Text_Settings()--设置Text
        end
    end)
    panel:SetScript('OnMouseUp',function() ResetCursor() end)

    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    Text_Settings()--设置Text
end


panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            set_event()

            if not Save.disabled and not IsAddOnLoaded("Blizzard_Calendar") then--加载
                LoadAddOn("Blizzard_Calendar")
                
                Calendar_Toggle()
                C_Calendar.OpenCalendar()
                Calendar_Toggle()
                --CalendarFrame:Hide()
            end

        elseif arg1=='Blizzard_Calendar' then            
            Init()

            hooksecurefunc('CalendarViewHolidayFrame_Update', function()                
                local indexInfo = C_Calendar.GetEventIndex();
                if(indexInfo) then
                    local holidayInfo = C_Calendar.GetHolidayInfo(indexInfo.offsetMonths, indexInfo.monthDay, indexInfo.eventIndex);
                    local info= C_Calendar.GetDayEvent(indexInfo.offsetMonths, indexInfo.monthDay, indexInfo.eventIndex)
                    
                    if (holidayInfo and info and info.eventID) then
                        local description = holidayInfo.description;
                        if (holidayInfo.startTime and holidayInfo.endTime) then
                            description = format(CALENDAR_HOLIDAYFRAME_BEGINSENDS, description, FormatShortDate(holidayInfo.startTime.monthDay, holidayInfo.startTime.month), GameTime_GetFormattedTime(holidayInfo.startTime.hour, holidayInfo.startTime.minute, true), FormatShortDate(holidayInfo.endTime.monthDay, holidayInfo.endTime.month), GameTime_GetFormattedTime(holidayInfo.endTime.hour, holidayInfo.endTime.minute, true));
                        end
                        
                        description=description..'\n\n'..CALENDAR_FILTER_HOLIDAYS..'ID '..info.eventID..(info.iconTexture and '    |T'..info.iconTexture..':0|t'..info.iconTexture or '')
                        CalendarViewHolidayFrame.ScrollingFont:SetText(description);
                        
                        if info.iconTexture then
                            CalendarViewHolidayFrame.Texture:SetTexture(info.iconTexture) 
                        end
                    end
                end
            end)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    else
        set_Text()
    end
end)
