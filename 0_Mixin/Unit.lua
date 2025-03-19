local e= select(2, ...)

WoWTools_UnitMixin={}

function WoWTools_UnitMixin:NameRemoveRealm(name, realm)--玩家名称, 去服务器为*
    if not name then
        return
    end
    local reName= name:match('(.+)%-') or name
    local reRealm= name:match('%-(.+)') or realm
    if not reName or reRealm=='' or reRealm==e.Player.realm then
        return reName
    elseif e.Player.Realms[reRealm] then
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
                select(5, self:Get_Unit_Color('npc', nil))
                ..e.cn(name, {unit='npc', isName=true})
                ..'|r'
        end
    end
    return ''
end


--职业颜色
function WoWTools_UnitMixin:Get_Unit_Color(unit, guid)
    local r, g, b, hex, classFilename
    if UnitExists(unit) then
        if UnitIsUnit('player', unit) then
            r,g,b,hex= e.Player.r, e.Player.g, e.Player.b, e.Player.col
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







--e.GetPlayerInfo(unit, guid, name{faction=nil, reName=true, reLink=false, reRealm=false, reNotRegion=false, level=10})
function WoWTools_UnitMixin:GetPlayerInfo(unit, guid, name, tab)
    if type(unit)=='table' then
        tab= unit
        unit= tab.unit
        name= tab.name
        guid= tab.guid
    else
        tab= tab or {}
    end


    unit= unit or tab.unit or (guid and UnitTokenFromGUID(guid))
    name= name or tab.name
    guid= guid or tab.guid or (UnitExists(unit) and UnitGUID(unit)) or self:GetGUID(unit, name)


    local faction= tab.faction
    local reLink= tab.reLink
    local reName= tab.reName
    local reNotRegion= tab.reNotRegion
    local reRealm= tab.reRealm



    if guid==e.Player.guid or name==e.Player.name or name==e.Player.name_realm then
        return e.Icon.player..((reName or reLink) and e.Player.col..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)..'|r' or '')..'|A:auctionhouse-icon-favorite:0:0|a'
    end

    if reLink then
        return self:GetLink(name, guid, true) --玩家超链接
    end



    local text
    if guid and C_PlayerInfo.GUIDIsPlayer(guid) then
        local _, englishClass, _, englishRace, sex, name2, realm = GetPlayerInfoByGUID(guid)
        name= name2

        if guid and (not faction or unit) then
            if e.GroupGuid[guid] then
                unit = unit or e.GroupGuid[guid].unit
                faction= faction or e.GroupGuid[guid].faction
            end
        end

        local friend= self:GetIsFriendIcon(nil, guid, nil)--检测, 是否好友
        local groupInfo= e.GroupGuid[guid] or {}--队伍成员
        local server= not reNotRegion and e.Get_Region(realm)--服务器，EU， US {col=, text=, realm=}

        text= (server and server.col or '')
                    ..(friend or '')
                    ..(self:GetFaction(unit, faction) or '')--检查, 是否同一阵营
                    ..(self:GetRaceIcon({unit=unit, guid=guid , race=englishRace, sex=sex, reAtlas=false}) or '')
                    ..(self:GetClassIcon(unit, englishClass) or '')

        if groupInfo.combatRole=='HEALER' or groupInfo.combatRole=='TANK' then--职业图标
            text= text..e.Icon[groupInfo.combatRole]..(groupInfo.subgroup or '')
        end
        if reName and name then
            if reRealm then
                if not realm or realm=='' or realm==e.Player.realm then
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
                or guid and e.WoWDate[guid] and e.WoWDate[guid].level
            if unitLevel and unitLevel~=0 and GetMaxLevelForLatestExpansion()~=unitLevel then
                text= text..'|cnGREEN_FONT_COLOR:'..unitLevel..'|r'
            end

            text= '|c'..select(4,GetClassColor(englishClass))..text..'|r'
        end
    end


    if (not text or text=='') and name then
        if reLink then
            return self:GetLink(name, nil, true) --玩家超链接

        elseif reName then
            if not reRealm then
                name= self:NameRemoveRealm(name)
            end
            text= name
        end
    end

    return text or ''
end










--NPC ID, 注意是：字符
function WoWTools_UnitMixin:GetNpcID(unit)
    if UnitExists(unit) then
        local guid=UnitGUID(unit)
        if guid then
            return select(6,  strsplit("-", guid))
        end
    end
end










function WoWTools_UnitMixin:GetOnlineInfo(unit)--单位，状态信息
    if unit and UnitExists(unit) then
        if not UnitIsConnected(unit) then
            return format("\124T%s.tga:0\124t", FRIENDS_TEXTURE_DND), e.onlyChinese and '离线' or PLAYER_OFFLINE
        elseif UnitIsAFK(unit) then
            return format("\124T%s.tga:0\124t", FRIENDS_TEXTURE_AFK), e.onlyChinese and '离开' or AFK
        elseif UnitIsGhost(unit) then
            return '|A:poi-soulspiritghost:0:0|a', e.onlyChinese and '幽灵' or DEAD
        elseif UnitIsDead(unit) then
            return '|A:deathrecap-icon-tombstone:0:0|a', e.onlyChinese and '死亡' or DEAD
        end
    end
end











function WoWTools_UnitMixin:GetLink(name, guid, onlyLink) --玩家超链接
    guid= guid or self:GetGUID(nil, name)
    if guid==e.Player.guid then--自已
        return (not onlyLink and e.Icon.player)..'|Hplayer:'..e.Player.name_realm..'|h['..e.Player.col..COMBATLOG_FILTER_STRING_ME..'|r'..']|h'
    end
    if guid then
        local _, class, _, race, sex, name2, realm = GetPlayerInfoByGUID(guid)
        if name2 then
            local showName= self:NameRemoveRealm(name2, realm)
            if class then
                showName= '|c'..select(4,GetClassColor(class))..showName..'|r'
            end
            return (not onlyLink and self:GetRaceIcon({unit=nil, guid=guid , race=race , sex=sex , reAtlas=false}) or '')..'|Hplayer:'..name2..((realm and realm~='') and '-'..realm or '')..'|h['..showName..']|h'
        end
    elseif name then
        return '|Hplayer:'..name..'|h['..self:NameRemoveRealm(name)..']|h'
    end
    return ''
end










function WoWTools_UnitMixin:GetFaction(unit, englishFaction, all)--检查, 是否同一阵营
    englishFaction= englishFaction or (unit and  UnitFactionGroup(unit))
    if englishFaction and (englishFaction~= e.Player.faction or all) then
        return format('|A:%s:0:0|a', e.Icon[englishFaction] or '')
    end
end






--[[
BNET_CLIENT_WOW = "WoW";
BNET_CLIENT_APP = "App";
BNET_CLIENT_HEROES = "Hero";
BNET_CLIENT_CLNT = "CLNT";
]]

--e.WoWDate[e.Player.guid].region= e.Player.region
--e.WoWDate[e.Player.guid].battleTag= e.Player.battleTag or e.WoWDate[e.Player.guid].battleTag
function WoWTools_UnitMixin:GetIsFriendIcon(name, guid, unit)--检测, 是否好友
    if guid or unit then
        guid= guid or self:GetGUID(unit, name)
        if guid and guid~=e.Player.guid then
            local data= e.WoWDate[guid]
            if data then
                if data.region~=e.Player.region then--不在一区
                    return '|A:tokens-characterTransfer-small:0:0|a'

                elseif data.battleTag~=e.Player.battleTag then--不同战网
                    return '|A:tokens-guildRealmTransfer-small:0:0|a'

                elseif data.faction~= e.Player.faction then
                    return '|A:tokens-guildChangeFaction-small:0:0|a'
                else
                    return '|A:wowlabs_spellbucketicon-sword:0:0|a'
                end

            else
                local gameAccountInfo = C_BattleNet.GetGameAccountInfoByGUID(guid)
                if gameAccountInfo then--C_BattleNet.GetAccountInfoByGUID(guid)
                    local text
                    if C_Texture.IsTitleIconTextureReady(gameAccountInfo.clientProgram, Enum.TitleIconVersion.Small) then
                        C_Texture.GetTitleIconTexture(gameAccountInfo.clientProgram, Enum.TitleIconVersion.Small, function(success, texture)
                            if success then
                                text = BNet_GetClientEmbeddedTexture(texture, 32, 32, 0).." ";
                            end
                        end);
                    end
                    return text or e.Icon.net2

                elseif C_FriendList.IsFriend(guid) then
                    return '|A:groupfinder-icon-friend:0:0|a'--好友

                elseif IsGuildMember(guid) then--IsPlayerInGuildFromGUID
                    return '|A:UI-HUD-MicroMenu-GuildCommunities-Mouseover:0:0|a'--公会
                end
            end
        end

    elseif name then
        if C_FriendList.GetFriendInfo(name:gsub('%-'..e.Player.realm, ''))  then
            return '|A:groupfinder-icon-friend:0:0|a'--好友
        end

        if e.WoWGUID[self:GetFullName(name)] then
            return e.Icon.net2
        end
    end
end





function WoWTools_UnitMixin:GetGUID(unit, name)--从名字,名unit, 获取GUID
    if unit then
        return UnitGUID(unit)

    elseif name then
        local info=C_FriendList.GetFriendInfo(name:gsub('%-'..e.Player.realm, ''))--好友
        if info then
            return info.guid
        end

        name= self:GetFullName(name)
        if e.GroupGuid[name] then--队友
            return e.GroupGuid[name].guid

        elseif e.WoWGUID[name] then--战网
            return e.WoWGUID[name].guid

        elseif name==e.Player.name then
            return e.Player.guid

        elseif UnitIsPlayer('target') and self:GetFullName(nil, 'target')==name then--目标
            return UnitGUID('target')
        end
    end
end




--职业图标 groupfinder-icon-emptyslot'
function WoWTools_UnitMixin:GetClassIcon(unit, classFilename, reAltlas)
    classFilename= classFilename or (unit and UnitClassBase(unit))
    if classFilename then
        if classFilename=='EVOKER' then
            classFilename='UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Evoker'--'classicon-evoker'--UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Evoker
        else
            classFilename= 'groupfinder-icon-class-'..classFilename
        end
        if reAltlas then
            return classFilename
        else
            return '|A:'..classFilename ..':0:0|a'
        end
    end
end



function WoWTools_UnitMixin:GetRaceIcon(tab)--玩家种族图标 {unit=nil, guid=nil, race=nil, sex=nil, reAtlas=false} 
    local race =tab.race or tab.unit and select(2,UnitRace(tab.unit))
    local sex= tab.sex
    if not (race or sex) and tab.guid then
        race, sex = select(4, GetPlayerInfoByGUID(tab.guid))
    end
    sex=sex or tab.unit and UnitSex(tab.unit)
    sex= sex==2 and 'male' or sex==3 and 'female'
    if sex and race then
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
        if tab.reAtlas then
            return 'raceicon128-'..race..'-'..sex
        else
            return '|A:raceicon128-'..race..'-'..sex..':0:0|a'
        end
    end
end
e.Icon.player= WoWTools_UnitMixin:GetRaceIcon({unit='player', guid=nil , race=nil , sex=nil , reAtlas=false})









function WoWTools_UnitMixin:GetFullName(name, unit, guid)--取得全名
    if name and name:gsub(' ','')~='' then
        if not name:find('%-') then
            name= name..'-'..e.Player.realm
        end
        return name
    elseif guid then
        local name2, realm = select(6, GetPlayerInfoByGUID(guid))
        if name2 then
            if not realm or realm=='' then
                realm= e.Player.realm
            end
            return name2..'-'..realm
        end
    elseif unit then
        local name2, realm= UnitName(unit)
        if name2 then
            if not realm or realm=='' then
                realm= e.Player.realm
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
    if not reName or reRealm=='' or reRealm==e.Player.realm then
        return reName
    elseif e.Player.Realms[reRealm] then
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

    if inclusoMe then--所有队员
        if IsInRaid() then
            for i= 1, MAX_RAID_MEMBERS, 1 do
                local unit='raid'..i
                if UnitExists(unit) then
                    table.insert(tab, unit)
                end
            end
        else
            for i=1, GetNumGroupMembers() do
                local unit='party'..i
                if UnitExists(unit) then
                    table.insert(tab, unit)
                end
            end
        end
    else--除我外，所有队员
        if IsInRaid() then
            for i= 1, MAX_RAID_MEMBERS, 1 do
                local unit='raid'..i
                if UnitExists(unit) and not UnitIsUnit(unit, 'player') then
                    table.insert(tab, unit)
                end
            end
        else
            for i=1, GetNumGroupMembers()-1, 1 do
                local unit='party'..i
                if UnitExists(unit)  then
                    table.insert(tab, unit)
                end
            end
        end
    end
    return tab
end