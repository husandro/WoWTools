WoWTools_UnitMixin={}

function WoWTools_UnitMixin:NameRemoveRealm(name, realm)--玩家名称, 去服务器为*
    if not name then
        return
    end
    local reName= name:match('(.+)%-') or name
    local reRealm= name:match('%-(.+)') or realm
    if not reName or reRealm=='' or reRealm==WoWTools_DataMixin.Player.Realm then
        return reName
    elseif WoWTools_DataMixin.Player.Realms[reRealm] then
        return reName..'|cnGREEN_FONT_COLOR:*|r'
    elseif reRealm then
        return reName..'*'
    end
    return reName
end


function WoWTools_UnitMixin:Get_NPC_Name()
    if UnitExists('npc') then
        local name= GetUnitName('npc')
        if name then
            return
                select(5, self:GetColor('npc', nil))
                ..WoWTools_TextMixin:CN(name, {unit='npc', isName=true})
                ..'|r'
        end
    end
    return ''
end


--职业颜色
function WoWTools_UnitMixin:GetColor(unit, guid, classFilename)
    local r, g, b, hex
    if UnitExists(unit) then
        if UnitIsUnit('player', unit) then
            r,g,b,hex= WoWTools_DataMixin.Player.r, WoWTools_DataMixin.Player.g, WoWTools_DataMixin.Player.b, WoWTools_DataMixin.Player.col
        else
            classFilename= UnitClassBase(unit)
        end
    elseif guid then
        classFilename = select(2, GetPlayerInfoByGUID(guid))
    end
    if classFilename then
        r, g, b, hex= GetClassColor(classFilename)
        hex= hex and '|c'..hex
    end

    r, g, b, hex =r or 1, g or 1, b or 1, hex or '|cffffffff'

    return {r=r, g=g, b=b, hex=hex},--1
        r,--2
        g,
        b,
        hex--5
end







--[[
WoWTools_UnitMixin:GetPlayerInfo(unit, guid, name,{
    faction=nil,
    reName=true,
    reLink=false,
    reRealm=false,
    reNotRace=false,
    reNotRegion=false,
    level=10
})
]]
function WoWTools_UnitMixin:GetPlayerInfo(unit, guid, name, tab)
    if type(unit)=='table' then
        tab= unit
    else
        tab= tab or {}
    end


    unit= unit or tab.unit or (guid and UnitTokenFromGUID(guid))
    name= name or tab.name
    guid= guid or tab.guid or (UnitExists(unit) and UnitGUID(unit)) or self:GetGUID(unit, name)

    local reName= tab.reName
    local reRealm= tab.reRealm

    local reNotRegion= tab.reNotRegion
    local reNotRace= tab.reNotRace
    local faction= tab.faction
    local reLink= tab.reLink

    local size= tab.size or 0

    if guid==WoWTools_DataMixin.Player.GUID
        or name==WoWTools_DataMixin.Player.Name
        or name==WoWTools_DataMixin.Player.Name_Realm
    then
        return WoWTools_DataMixin.Icon.Player
            ..(
                (reName or reLink) and WoWTools_DataMixin.Player.col..(WoWTools_DataMixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)..'|r' or ''
            )..'|A:auctionhouse-icon-favorite:0:0|a'
    end

    if reLink then
        return self:GetLink(unit, guid, name, true)--玩家超链接
    end



    local text
    if guid and C_PlayerInfo.GUIDIsPlayer(guid) then
        local _, englishClass, _, englishRace, sex, name2, realm = GetPlayerInfoByGUID(guid)
        name= name2

        if guid and (not faction or unit) then
            if WoWTools_DataMixin.GroupGuid[guid] then
                unit = unit or WoWTools_DataMixin.GroupGuid[guid].unit
                faction= faction or WoWTools_DataMixin.GroupGuid[guid].faction
            end
        end

        local friend= self:GetIsFriendIcon(nil, guid, nil)--检测, 是否好友
        local groupInfo= WoWTools_DataMixin.GroupGuid[guid] or {}--队伍成员
        local server= not reNotRegion and WoWTools_RealmMixin:Get_Region(realm)--服务器，EU， US {col=, text=, realm=}

        text= (server and server.col or '')
                    ..(friend or '')
                    ..(self:GetFaction(unit, faction, nil, {size=size}) or '')--检查, 是否同一阵营
                    ..(not reNotRace and self:GetRaceIcon(unit, guid, englishRace, {sex=sex, size=size}) or '')
                    ..(self:GetClassIcon(unit, guid, englishClass, {size=size}) or '')

        if groupInfo.combatRole=='HEALER' or groupInfo.combatRole=='TANK' then--职业图标
            text= text..WoWTools_DataMixin.Icon[groupInfo.combatRole]..(groupInfo.subgroup or '')
        end
        if reName and name then
            if reRealm then
                if not realm or realm=='' or realm==WoWTools_DataMixin.Player.Realm then
                    text= text..name
                else
                    text= text..name..'-'..realm
                end
            else
                text= text..self:NameRemoveRealm(name, realm)
            end
--等级 
            local unitLevel= tab.level
                or (unit and UnitLevel(name))
                or guid and WoWTools_WoWDate[guid] and WoWTools_WoWDate[guid].level
            if unitLevel and unitLevel~=0 and GetMaxLevelForLatestExpansion()~=unitLevel then
                text= text..'|cnGREEN_FONT_COLOR:'..unitLevel..'|r'
            end

            text= '|c'..select(4,GetClassColor(englishClass))..text..'|r'
        end
    end


    if (not text or text=='') and name then
        if reLink then
            return self:GetLink(unit, guid, name, true) --玩家超链接

        elseif reName then
            if not reRealm then
                name= self:NameRemoveRealm(name)
            end
            text= name
        end
    end

    return text or ''
end








--[[
if unit_type == "Creature" or unit_type == "Vehicle" then
    local _, _, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-", guid)
elseif unit_type == "Player" then
    local _, server_id, player_id = strsplit("-", guid)
end
NPC ID, 注意是：字符 Creature-0-1465-0-2105-448-000043F59F
]]
function WoWTools_UnitMixin:GetNpcID(unit, guid)
    unit= unit or 'npc'
    guid= guid or (UnitExists(unit) and UnitGUID(unit))
    if guid then
        local zone, npc = select(5, strsplit("-", guid))
        return npc, zone
    end
end










function WoWTools_UnitMixin:GetOnlineInfo(unit)--单位，状态信息
    if unit and UnitExists(unit) then
        if not UnitIsConnected(unit) then
            return format("\124T%s.tga:0\124t", FRIENDS_TEXTURE_DND), WoWTools_DataMixin.onlyChinese and '离线' or PLAYER_OFFLINE
        elseif UnitIsAFK(unit) then
            return format("\124T%s.tga:0\124t", FRIENDS_TEXTURE_AFK), WoWTools_DataMixin.onlyChinese and '离开' or AFK
        elseif UnitIsGhost(unit) then
            return '|A:poi-soulspiritghost:0:0|a', WoWTools_DataMixin.onlyChinese and '幽灵' or DEAD
        elseif UnitIsDead(unit) then
            return '|A:deathrecap-icon-tombstone:0:0|a', WoWTools_DataMixin.onlyChinese and '死亡' or DEAD
        end
    end
end









--[[
local isCharacterClub = clubInfo.clubType == Enum.ClubType.Character;
local inviterName = inviterInfo.name or "";
local classInfo = inviterInfo.classID and C_CreatureInfo.GetClassInfo(inviterInfo.classID);
local inviterText;
if isCharacterClub and classInfo then
    local classColorInfo = RAID_CLASS_COLORS[classInfo.classFile];
    inviterText = GetPlayerLink(inviterName, ("[%s]"):format(WrapTextInColorCode(inviterName, classColorInfo.colorStr)));
elseif isCharacterClub then
    inviterText = GetPlayerLink(inviterName, ("[%s]"):format(inviterName));
else
    inviterText = inviterName;
end
]]

function WoWTools_UnitMixin:GetLink(unit, guid, name, onlyLink) --玩家超链接
    guid= guid or self:GetGUID(unit, name)
    if guid==WoWTools_DataMixin.Player.GUID then--自已
        return (onlyLink and '' or WoWTools_DataMixin.Icon.Player)..'|Hplayer:'..WoWTools_DataMixin.Player.Name_Realm..'|h['..WoWTools_DataMixin.Player.col..COMBATLOG_FILTER_STRING_ME..'|r'..']|h'
    end
    if guid then
        local _, class, _, race, sex, name2, realm = GetPlayerInfoByGUID(guid)
        if name2 then
            local showName= self:NameRemoveRealm(name2, realm)
            if class then
                showName= '|c'..select(4,GetClassColor(class))..showName..'|r'
            end
            return (onlyLink and '' or self:GetRaceIcon(unit, guid, race, {sex=sex , reAtlas=false}))..'|Hplayer:'..name2..((realm and realm~='') and '-'..realm or '')..'|h['..showName..']|h'
        end
    elseif name then
        return '|Hplayer:'..name..'|h['..self:NameRemoveRealm(name)..']|h'
    end
    return ''
end









function WoWTools_UnitMixin:GetFaction(unit, englishFaction, all, tab)--检查, 是否同一阵营
    englishFaction= englishFaction or (unit and  UnitFactionGroup(unit))
    if englishFaction and (englishFaction~= WoWTools_DataMixin.Player.Faction or all) then
        local size= tab and tab.size or 0
        return format('|A:%s:'..size..':'..size..'|a', WoWTools_DataMixin.Icon[englishFaction] or '')
    end
end






--[[
BNET_CLIENT_WOW = "WoW";
BNET_CLIENT_APP = "App";
BNET_CLIENT_HEROES = "Hero";
BNET_CLIENT_CLNT = "CLNT";
]]

--WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].region= WoWTools_DataMixin.Player.Region
--WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].battleTag= WoWTools_DataMixin.Player.BattleTag or WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].battleTag
function WoWTools_UnitMixin:GetIsFriendIcon(unit, guid, name)--检测, 是否好友
    if guid or unit then
        guid= guid or self:GetGUID(unit, name)
        if guid and guid~=WoWTools_DataMixin.Player.GUID then
            local data= WoWTools_WoWDate[guid]
            if data then
                if data.region~=WoWTools_DataMixin.Player.Region then--不在一区
                    return '|A:tokens-characterTransfer-small:0:0|a'

                elseif data.battleTag~=WoWTools_DataMixin.Player.BattleTag then--不同战网
                    return '|A:tokens-guildRealmTransfer-small:0:0|a'

                elseif data.faction~= WoWTools_DataMixin.Player.Faction then
                    return '|A:tokens-guildChangeFaction-small:0:0|a'
                else
                    return '|A:wowlabs_spellbucketicon-sword:0:0|a'
                end

            else
                local gameAccountInfo = C_BattleNet.GetGameAccountInfoByGUID(guid)
                if gameAccountInfo then--C_BattleNet.GetAccountInfoByGUID(guid)
                    local text
                    if C_Texture.IsTitleIconTextureReady(gameAccountInfo.clientProgram, Enum.TitleIconVersion.Large) then
                        C_Texture.GetTitleIconTexture(gameAccountInfo.clientProgram, Enum.TitleIconVersion.Large, function(success, texture)
                            if success then
                                text = BNet_GetClientEmbeddedTexture(texture, 0, 0)--.." ";
                            end
                        end);
                    end
                    return text or WoWTools_DataMixin.Icon.net2

                elseif C_FriendList.IsFriend(guid) then
                    return '|A:groupfinder-icon-friend:0:0|a'--好友

                elseif IsGuildMember(guid) then--IsPlayerInGuildFromGUID
                    return '|A:UI-HUD-MicroMenu-GuildCommunities-Mouseover:0:0|a'--公会
                end
            end
        end

    elseif name then
        if C_FriendList.GetFriendInfo(name:gsub('%-'..WoWTools_DataMixin.Player.Realm, ''))  then
            return '|A:groupfinder-icon-friend:0:0|a'--好友
        end

        if WoWTools_DataMixin.WoWGUID[self:GetFullName(name)] then
            return WoWTools_DataMixin.Icon.net2
        end
    end
end





function WoWTools_UnitMixin:GetGUID(unit, name)--从名字,名unit, 获取GUID
    if unit then
        return UnitGUID(unit)

    elseif name then
        local info=C_FriendList.GetFriendInfo(name:gsub('%-'..WoWTools_DataMixin.Player.Realm, ''))--好友
        if info then
            return info.guid
        end

        name= self:GetFullName(name)
        if WoWTools_DataMixin.GroupGuid[name] then--队友
            return WoWTools_DataMixin.GroupGuid[name].guid

        elseif WoWTools_DataMixin.WoWGUID[name] then--战网
            return WoWTools_DataMixin.WoWGUID[name].guid

        elseif name==WoWTools_DataMixin.Player.Name then
            return WoWTools_DataMixin.Player.GUID

        elseif UnitIsPlayer('target') and self:GetFullName(nil, 'target')==name then--目标
            return UnitGUID('target')
        end
    end
end




--职业图标 groupfinder-icon-emptyslot'
function WoWTools_UnitMixin:GetClassIcon(unit, guid, classFilename, tab)
    tab= tab or {}

    local reAtlas= tab.reAtlas
    local size= tab.size or 0

    if not classFilename then
        if unit then
            classFilename= UnitClassBase(unit)
        elseif guid then
            classFilename= select(2, GetPlayerInfoByGUID(guid))
        end
    end

    if classFilename then
        --if classFilename=='EVOKER' then
            --classFilename='UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Evoker'--'classicon-evoker'--UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Evoker
        classFilename= 'groupfinder-icon-class-'..classFilename
        if reAtlas then
            return classFilename
        else
            return '|A:'..classFilename ..':'..size..':'..size..'|a'
        end
    end
end


--玩家种族图标 
function WoWTools_UnitMixin:GetRaceIcon(unit, guid, race, tab)
    tab= tab or {}

    local size= tab.size or 0
    local sex= tab.sex
    local reAtlas= tab.reAtlas

    if not sex or not race then
        if unit then
            race= select(2,UnitRace(unit))
            sex= UnitSex(unit)

        elseif guid then
            race, sex = select(4, GetPlayerInfoByGUID(guid))
        end
    end

    if race then
        sex= sex==3 and 'female' or 'male'
        if race=='Scourge' then
            race='Undead'
        elseif race=='HighmountainTauren' then
            race='highmountain'
        elseif race=='ZandalariTroll' then
            race='zandalari'
        elseif race=='LightforgedDraenei' then
            race='lightforged'
        elseif race=='Dracthyr' then
            race='dracthyrvisage'
        end
        if reAtlas then
            return 'raceicon128-'..race..'-'..sex
        else
            return '|A:raceicon128-'..race..'-'..sex..':'..size..':'..size..'|a'
        end
    end
end







function WoWTools_UnitMixin:GetFullName(name, unit, guid)--取得全名
    if name and name:gsub(' ','')~='' then
        if not name:find('%-') then
            name= name..'-'..WoWTools_DataMixin.Player.Realm
        end
        return name
    elseif guid then
        local name2, realm = select(6, GetPlayerInfoByGUID(guid))
        if name2 then
            if not realm or realm=='' then
                realm= WoWTools_DataMixin.Player.Realm
            end
            return name2..'-'..realm
        end
    elseif unit then
        local name2, realm= UnitName(unit)
        if name2 then
            if not realm or realm=='' then
                realm= WoWTools_DataMixin.Player.Realm
            end
            return name2..'-'..realm
        end
    end
end
--[[local function GetPlayerNameRemoveRealm(name, realm)--玩家名称, 去服务器为*
    if not name then
        return
    end
    local reName= name:match('(.+)%-') or name
    local reRealm= name:match('%-(.+)') or realm
    if not reName or reRealm=='' or reRealm==WoWTools_DataMixin.Player.Realm then
        return reName
    elseif WoWTools_DataMixin.Player.Realms[reRealm] then
        return reName..'|cnGREEN_FONT_COLOR:*|r'
    elseif reRealm then
        return reName..'*'
    end
    return reName
end]]







--取得，队员, unit
function WoWTools_UnitMixin:GetGroupMembers(inclusoMe)
    local tab={}
    if not IsInGroup() then
        return tab
    end

    local unit
    if inclusoMe then--所有队员
        if IsInRaid() then
            for i= 1, MAX_RAID_MEMBERS, 1 do
                unit='raid'..i
                if UnitExists(unit) then
                    table.insert(tab, unit)
                end
            end
        else
            for i=1, GetNumGroupMembers() do
                unit='party'..i
                if UnitExists(unit) then
                    table.insert(tab, unit)
                end
            end
        end

    else--除我外，所有队员
        if IsInRaid() then
            for i= 1, MAX_RAID_MEMBERS, 1 do
                unit='raid'..i
                if UnitExists(unit) and not UnitIsUnit(unit, 'player') then
                    table.insert(tab, unit)
                end
            end
        else
            for i=1, GetNumGroupMembers()-1, 1 do
                unit='party'..i
                if UnitExists(unit)  then
                    table.insert(tab, unit)
                end
            end
        end
    end
    return tab
end








--#######
--取得装等
--#######
local NotifyInspectTicker
function WoWTools_UnitMixin:GetNotifyInspect(tab, unit)
    if unit then
        if UnitExists(unit) and CanInspect(unit) and (not InspectFrame or not InspectFrame:IsShown()) then--and CheckInteractDistance(unit, 1)
            NotifyInspect(unit)
        end
    else
        tab=tab or {}
        local num, index= #tab, 1
        if num>0 then
            if NotifyInspectTicker and not NotifyInspectTicker:IsCancelled() then
                NotifyInspectTicker:Cancel()
            end
            NotifyInspectTicker=C_Timer.NewTimer(4, function()--InspectFrame,如果显示，查看玩家，天赋，出错
                local unit2=tab[index]
                if UnitExists(unit2) and CanInspect(unit2) and (not InspectFrame or not InspectFrame:IsShown()) then--and CheckInteractDistance(unit2, 1)
                    NotifyInspect(tab[index])
                    index= index+ 1
                end
            end, num)
        end
    end
end




















--距离
local LibRangeCheck = LibStub("LibRangeCheck-3.0", true)
function WoWTools_UnitMixin:GetRange(unit, checkVisible)--WA Prototypes.lua
    return LibRangeCheck:GetRange(unit, checkVisible)
end

--距离
function WoWTools_UnitMixin:CheckRange(unit, range, operator)
    local min, max= LibRangeCheck:GetRange(unit, operator)
    if (operator) then-- == "<=") then
        return (max or 999) <= range
    else
        return (min or 0) >= range
    end
end




local function Set_Range_OnUpdata(self, elapsed)
    self.elapsed= (self.elapsed or 0.3) + elapsed
    if self.elapsed<0.3 then
        return
    end

    self.elapsed=0
    local speed, mi, ma
    if not UnitIsUnit(self.unit, 'player') then
        mi, ma= LibRangeCheck:GetRange(self.unit)
        if mi and ma then
            local r,g,b
            if ma<=5 then
                r,g,b= 0,1,0--绿色

            elseif ma<=8 then
                r,g,b= 0.78, 0.61, 0.43--战士

            elseif ma<=30 then
                r,g,b= 1, 0.49, 0.04--XD

            elseif ma<=35 then
                r,g,b= 0.25, 0.78, 0.92--法师

            elseif ma<=40 then
                r,g,b= 0.67, 0.83, 0.45--猎人
            else
                r,g,b= 1, 0, 0--红
            end

            self.Text:SetTextColor(r,g,b)
            self.Text2:SetTextColor(r,g,b)
        end

        local value= GetUnitSpeed(self.unit) or 0
        if value==0 then
            speed= '|cff8282820'
        else
            speed= format('%.0f', (value)*100/BASE_MOVEMENT_SPEED)
        end
    end
    self.Text:SetText(mi or '')
    self.Text2:SetText(ma or '')
    self.Text3:SetText(speed or '')
end



local function Set_Range_Text(frame)
    local label= WoWTools_LabelMixin:Create(frame, {justifyH='RIGHT', mouse=true})
    label:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)
    label:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(self.tooltip)
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)

    return label
end

function WoWTools_UnitMixin:SetRangeFrame(frame)
--位置，最大值
    frame.Text2= Set_Range_Text(frame)
    frame.Text2:SetPoint('RIGHT', frame, 'LEFT')
    frame.Text2.tooltip= WoWTools_DataMixin.onlyChinese and '最小距离' or FARCLIP

--位置，最小值
    frame.Text= Set_Range_Text(frame)
    frame.Text:SetPoint('BOTTOMRIGHT', frame.Text2, 'TOPRIGHT')
    frame.Text.tooltip= WoWTools_DataMixin.onlyChinese and '最大距离' or FARCLIP

--移动, 速度
    frame.Text3= Set_Range_Text(frame)
    frame.Text3:SetPoint('TOPRIGHT', frame.Text2, 'BOTTOMRIGHT')
    frame.Text3.tooltip= WoWTools_DataMixin.onlyChinese and '移动速度' or STAT_MOVEMENT_SPEED

    frame:SetScript('OnUpdate', Set_Range_OnUpdata)
end