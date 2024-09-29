--Blizzard_Calendar.lua
local e= select(2, ...)










local function CreateEventFrame_OnShow(self)
    if self.menu then
        return
    end
    self.menu=CreateFrame("Frame", nil, CalendarCreateEventFrame, "UIDropDownMenuTemplate")
    self.menu:SetPoint('BOTTOMLEFT', CalendarCreateEventFrame, 'BOTTOMRIGHT', -22,74)
    e.LibDD:UIDropDownMenu_SetWidth(self.menu, 60)
    e.LibDD:UIDropDownMenu_SetText(self.menu, e.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET)
    e.LibDD:UIDropDownMenu_Initialize(self.menu, function(_, level)
        local map=WoWTools_MapMixin:GetUnit('player');--玩家区域名称
        local inviteTab={}
        for index = 1, C_Calendar.GetNumInvites() do
            local inviteInfo = C_Calendar.EventGetInvite(index);
            if inviteInfo and inviteInfo.name then
                inviteTab[inviteInfo.name]= true
            end
        end
        local find
        local maxLevel= GetMaxLevelForLatestExpansion()
        for i=1 ,BNGetNumFriends() do
            local wow=C_BattleNet.GetFriendAccountInfo(i);
            local wowInfo= wow and wow.gameAccountInfo
            if wowInfo and wowInfo.playerGuid and wowInfo.characterName and not inviteTab[wowInfo.characterName] and wowInfo.wowProjectID==1 then

                local text= WoWTools_UnitMixin:GetPlayerInfo({guid=wowInfo.playerGuid, faction=wowInfo.factionName, name=wowInfo.characterName, reName=true, reRealm=true})--角色信息
                if wowInfo.areaName then --位置
                    if wowInfo.areaName==map then
                        text=text..'|A:poi-islands-table:0:0|a'
                    else
                        text=text..' '..wowInfo.areaName
                    end
                end

                if wowInfo.characterLevel and wowInfo.characterLevel~=maxLevel and wowInfo.characterLevel>0 then--等级
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
        local map=WoWTools_MapMixin:GetUnit('player');--玩家区域名称
        local inviteTab={}
        for index = 1, C_Calendar.GetNumInvites() do
            local inviteInfo = C_Calendar.EventGetInvite(index);
            if inviteInfo and inviteInfo.name then
                inviteTab[inviteInfo.name]= true
            end
        end
        local find
        local maxLevel= GetMaxLevelForLatestExpansion()
        for i=1 , C_FriendList.GetNumFriends() do
            local game=C_FriendList.GetFriendInfoByIndex(i)
            if game and game.name and not inviteTab[game.name] then--and not game.afk and not game.dnd then
                local text=WoWTools_UnitMixin:GetPlayerInfo({guid=game.guid, name=game.name,  reName=true, reRealm=true})--角色信息
                text= (game.level and game.level~=maxLevel and game.level>0) and text .. ' |cff00ff00'..game.level..'|r' or text--等级
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
        local map=WoWTools_MapMixin:GetUnit('player')
        local inviteTab={}
        for index = 1, C_Calendar.GetNumInvites() do
            local inviteInfo = C_Calendar.EventGetInvite(index);
            if inviteInfo and inviteInfo.name then
                inviteTab[inviteInfo.name]= true
            end
        end
        local find
        local maxLevel= GetMaxLevelForLatestExpansion()
        for index=1,  GetNumGuildMembers() do
            local name, rankName, rankIndex, lv, _, zone, publicNote, officerNote, isOnline, status, _, _, _, _, _, _, guid = GetGuildRosterInfo(index)
            if name and guid and not inviteTab[name] and isOnline and name~=e.Player.name_realm then
                local text=WoWTools_UnitMixin:GetPlayerInfo({guid=guid, name=name,  reName=true, reRealm=true})--名称
                text=(lv and lv~=maxLevel and lv>0) and text..' |cnGREEN_FONT_COLOR:'..lv..'|r' or text--等级
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
end









local function InviteListScrollFrame_Update()
    local frame= CalendarCreateEventInviteList.ScrollBox
    if C_Calendar.AreNamesReady() and frame:GetView()  then
        for index, btn in pairs(frame:GetFrames() or {}) do--ScrollBox.lua
            local inviteInfo = C_Calendar.EventGetInvite(index)
            if inviteInfo and inviteInfo.guid then
                btn.Class:SetText(WoWTools_UnitMixin:GetPlayerInfo({guid=inviteInfo.guid, name=inviteInfo.name}))
            end
        end
    end
end













function WoWTools_HolidayMixin:Init_CreateEventFrame()
    CalendarCreateEventFrame:HookScript('OnShow', CreateEventFrame_OnShow)
    hooksecurefunc('CalendarCreateEventInviteListScrollFrame_Update', InviteListScrollFrame_Update)
end