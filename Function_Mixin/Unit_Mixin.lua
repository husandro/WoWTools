local e= select(2, ...)

WoWTools_UnitMixin={}

function WoWTools_UnitMixin:GetPlayerNameRemoveRealm(name, realm)--玩家名称, 去服务器为*
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







--e.GetPlayerInfo({unit=nil, guid=nil, name=nil, faction=nil, reName=true, reLink=false, reRealm=false, reNotRegion=false})
function WoWTools_UnitMixin:GetPlayerInfo(unit, guid, name, tab)
    tab= tab or {}
    
    unit= unit or tab.unit
    name= name or tab.name
    guid= guid or tab.guid or (UnitExists(unit) and UnitGUID(unit)) or e.GetGUID(unit, name)
    local faction= tab.faction

    local reLink= tab.reLink
    local reName= tab.reName
    local reNotRegion= tab.reNotRegion
    local reRealm= tab.reRealm


    if guid==e.Player.guid or name==e.Player.name or name==e.Player.name_realm then
        return e.Icon.player..((reName or reLink) and e.Player.col..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)..'|r' or '')..'|A:auctionhouse-icon-favorite:0:0|a'
    end

    if reLink then
        return e.PlayerLink(name, guid, true) --玩家超链接
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

        local friend= e.GetFriend(nil, guid, nil)--检测, 是否好友
        local groupInfo= e.GroupGuid[guid] or {}--队伍成员
        local server= not reNotRegion and e.Get_Region(realm)--服务器，EU， US {col=, text=, realm=}

        text= (server and server.col or '')
                    ..(friend or '')
                    ..(e.GetUnitFaction(unit, faction) or '')--检查, 是否同一阵营
                    ..(e.GetUnitRaceInfo({unit=unit, guid=guid , race=englishRace, sex=sex, reAtlas=false}) or '')
                    ..(e.Class(unit, englishClass) or '')

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
            text= '|c'..select(4,GetClassColor(englishClass))..text..'|r'
        end
    end


    if (not text or text=='') and name then
        if reLink then
            return e.PlayerLink(name, nil, true) --玩家超链接

        elseif reName then
            if not reRealm then
                name= self:NameRemoveRealm(name)
            end
            text= name
        end
    end

    return text or ''
end