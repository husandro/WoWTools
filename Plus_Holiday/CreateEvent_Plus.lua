--Blizzard_Calendar.lua




local function Find_WoW(guid)
    for index = 1, C_Calendar.GetNumInvites() do
        local inviteInfo = C_Calendar.EventGetInvite(index)
        if inviteInfo and inviteInfo.guid==guid then
            return index
        end
    end
end


local function Add_Remove(data)--guid,name,realm
    local findIndex= Find_WoW(data.guid)
    if findIndex then
        C_Calendar.EventRemoveInvite(findIndex)
    else
        local fullName= data.name..(data.realm and '-'..data.realm or '')
        CalendarCreateEventInviteEdit:SetText(fullName)
        C_Calendar.EventInvite(fullName)
    end
end


local function Opentions_Menu(root, num)
    if num and num>0 then
        root:CreateDivider()
    end

--打开选项界面
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_HolidayMixin.addName})
--SetScrollMod
    WoWTools_MenuMixin:SetScrollMode(root)
end














local function Init_WoW_Menu(_, root)
    local sub
    local num=0
    local map=WoWTools_MapMixin:GetUnit('player')--玩家区域名称

    for i=1 ,BNGetNumFriends() do
        local wow=C_BattleNet.GetFriendAccountInfo(i) or {}
        local wowInfo= wow.gameAccountInfo
        if wowInfo and wowInfo.playerGuid and wowInfo.characterName and wowInfo.wowProjectID==1 then
            local text= WoWTools_UnitMixin:GetPlayerInfo(nil, wowInfo.playerGuid, wowInfo.characterName, {
                faction=wowInfo.factionName,
                level=wowInfo.characterLevel,
                reName=true,
                reRealm=true
            })
            if wowInfo.areaName then --位置
                if wowInfo.areaName==map then
                    text=text..'|A:poi-islands-table:0:0|a'
                else
                    text=text..' '..wowInfo.areaName
                end
            end

            if not wowInfo.isOnline then
                text= text..'|cff9e9e9e'..(WoWTools_DataMixin.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)..'|r'
            end

            sub=root:CreateCheckbox(
                text,
            function(data)
                return Find_WoW(data.guid) and true or false

            end, function(data)
                Add_Remove(data)--guid,name,realm
                return MenuResponse.Refresh

            end, {guid=wowInfo.playerGuid, name=wowInfo.characterName, realm=wowInfo.realmName, note=wow.note, tag=wow.battleTag})

            sub:SetTooltip(function(tooltip, description)
                tooltip:AddLine(description.data.tag)
                tooltip:AddLine(description.data.name)
                tooltip:AddLine(description.data.note, nil,nil,nil,true)
            end)
        end
        num= num+1
    end

    Opentions_Menu(root, num)
end













local function Init_Friend_Menu(_, root)
    local sub
    local num=0
    local map=WoWTools_MapMixin:GetUnit('player')--玩家区域名称

    for i=1 , C_FriendList.GetNumFriends() do
        local game=C_FriendList.GetFriendInfoByIndex(i)
        if game and game.name then
            local text=WoWTools_UnitMixin:GetPlayerInfo(nil, game.guid, game.name, {
                reName=true,
                reRealm=true,
                level=game.level,
            })

            if game.area and game.connected then
                if game.area == map then--地区
                    text= text..'|A:poi-islands-table:0:0|a'
                else
                    text= text..' |cnGREEN_FONT_COLOR:'..game.area..'|r'
                end
            elseif not game.connected then
                text= text..'|cff9e9e9e'..(WoWTools_DataMixin.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)..'|r'
            end

            if game.afk then
                text=text..'|T'..FRIENDS_TEXTURE_AFK..':0|t'
            elseif game.dnd then
                text=text..'|T'..FRIENDS_TEXTURE_DND..':0|t'
            end

            sub=root:CreateCheckbox(
                text,
            function(data)
                return Find_WoW(data.guid) and true or false

            end, function(data)
                Add_Remove(data)--guid,name,realm
                return MenuResponse.Refresh
            end, {guid=game.guid, name=game.name, note=game.notes})

            sub:SetTooltip(function(tooltip, description)
                tooltip:AddLine(description.data.name)
                tooltip:AddLine(description.data.note, nil,nil,nil,true)
            end)
            num= num+1
        end
    end

    Opentions_Menu(root, num)
end












local function Init_Guild_Menu(_, root)
    if not IsInGuild() then
        Opentions_Menu(root)
        return
    end

    local sub
    local num=0
    local map=WoWTools_MapMixin:GetUnit('player')
    for index=1, GetNumGuildMembers() do
        local name, rankName, rankIndex, lv, _, zone, publicNote, officerNote, isOnline, status, _, _, _, _, _, _, guid = GetGuildRosterInfo(index)
        if name and guid and guid~=WoWTools_DataMixin.Player.GUID then
            local text=WoWTools_UnitMixin:GetPlayerInfo(guid, name, nil, {
                reName=true,
                reRealm=true,
                levle=lv
            })
            if zone then--地区
                text= zone==map and text..'|A:poi-islands-table:0:0|a' or text..' '..zone
            end
            text= rankName and text..' '..rankName..(rankIndex or '') or text

            if not isOnline then
                text= text..'|cff9e9e9e'..(WoWTools_DataMixin.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)..'|r'
            end

            if status==1 then
                text=text..'|T'..FRIENDS_TEXTURE_AFK..':0|t'
            elseif status==2 then
                text=text..'|T'..FRIENDS_TEXTURE_DND..':0|t'
            end

            sub=root:CreateCheckbox(
                text,
            function(data)
                return Find_WoW(data.guid) and true or false

            end, function(data)
                Add_Remove(data)--guid,name,realm
                return MenuResponse.Refresh
            end, {guid=guid, name=name, note=publicNote, note2=officerNote})

            sub:SetTooltip(function(tooltip, description)
                tooltip:AddLine(description.data.name)
                tooltip:AddLine(description.data.note, nil,nil,nil,true)
                tooltip:AddLine(description.data.note2, nil,nil,nil,true)
            end)
            num= num+1
        end
    end

    Opentions_Menu(root, num)
end













local function Init_List()
    local wow = CreateFrame("Button", nil, CalendarClassTotalsButton, "CalendarClassButtonTemplate")
    wow:SetPoint('TOPLEFT', CalendarClassTotalsButton, 'BOTTOMLEFT', 0, -16)
    wow:SetNormalAtlas('glues-characterSelect-iconShop')
    wow:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, Init_WoW_Menu)
    end)

    local friend=CreateFrame("Button", nil, wow, "CalendarClassButtonTemplate")
    friend:SetPoint('TOPLEFT', wow, 'BOTTOMLEFT', 0, -12)
    friend:SetNormalAtlas('groupfinder-icon-friend')
    friend:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, Init_Friend_Menu)
    end)

    local guild=CreateFrame("Button", nil, wow, "CalendarClassButtonTemplate")
    guild:SetPoint('TOPLEFT', friend, 'BOTTOMLEFT', 0, -12)
    guild:SetNormalAtlas('communities-guildbanner-background')
    guild:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, Init_Guild_Menu)
    end)
end








local function InviteListScrollFrame_Update()
    local frame= CalendarCreateEventInviteList.ScrollBox
    if C_Calendar.AreNamesReady() and frame:GetView()  then
        for index, btn in pairs(frame:GetFrames() or {}) do--ScrollBox.lua
            local inviteInfo = C_Calendar.EventGetInvite(index)
            if inviteInfo and inviteInfo.guid then
                btn.Class:SetText(WoWTools_UnitMixin:GetPlayerInfo(nil, inviteInfo.guid, inviteInfo.name))
            end
        end
    end
end













function WoWTools_HolidayMixin:Init_CreateEventFrame()
    Init_List()
    --CalendarCreateEventFrame:HookScript('OnShow', CreateEventFrame_OnShow)
    hooksecurefunc('CalendarCreateEventInviteListScrollFrame_Update', InviteListScrollFrame_Update)
end