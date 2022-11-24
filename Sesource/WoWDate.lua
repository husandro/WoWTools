local id, e = ...
local panel=CreateFrame("Frame")
e.WoWSave={
    ['Player-All-Time']={},
}
--wowSave[e.Player.name_server].keystones=tab

--###########
--队伍数据收集
--###########
e.GroupGuid={}
local function set_GroupGuid()
    e.GroupGuid={}
    if not IsInGroup() then
        return
    elseif IsInRaid() then
        for index= 1, GetNumGroupMembers() do
            local unit='raid'..index
            local guid=UnitGUID(unit)
            local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(index)

            if guid then
                local tab={unit=unit, subgroup=subgroup, combatRole=combatRole or role}
                e.GroupGuid[guid]=tab
                e.GroupGuid[GetUnitName(unit, true)]=tab
            end
        end
    else
        local tab
        for index= 1, GetNumGroupMembers()-1 do
            local unit='party'..index
            local guid=UnitGUID(unit)
            if guid then
                tab={unit=unit, combatRole=UnitGroupRolesAssigned(unit)}
                e.GroupGuid[guid]=tab
                e.GroupGuid[GetUnitName(unit, true)]=tab
            end
        end
        tab={unit='player', combatRole=UnitGroupRolesAssigned('player')}
        e.GroupGuid[UnitGUID('player')]=tab
        e.GroupGuid[UnitName('player')]=tab
    end
end

--#########
--总游戏时间
--#########
--e.WoWSave['Player-All-Time']
local function set_TIME_PLAYED_MSG(totalTimePlayed, timePlayedThisLevel)--总游戏时间：%s
    if totalTimePlayed and timePlayedThisLevel then
        e.WoWSave['Player-All-Time'][e.Player.name_server]={
            class= e.Player.class,
            race= select(2,UnitRace('player')),
            sex= UnitSex('player'),
            totalTime= totalTimePlayed,
            levelTime= timePlayedThisLevel,
        }
    end
end

panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_LOGOUT')

panel:RegisterEvent('GROUP_ROSTER_UPDATE')--队伍数据收集 e.GroupGuid
panel:RegisterEvent('GROUP_LEFT')
panel:RegisterEvent('ADDON_LOADED')

panel:RegisterEvent('TIME_PLAYED_MSG')--总游戏时间：%s

panel:SetScript('OnEvent', function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if WoWToolsSave then
                e.WoWSave['Player-All-Time']= WoWToolsSave['Player-All-Time'] or e.WoWSave['Player-All-Time']
            end
        end
    elseif event=='PLAYER_LOGOUT' then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave['Player-All-Time']= e.WoWSave['Player-All-Time']
            
        end
    elseif event=='GROUP_ROSTER_UPDATE' or (event=='ADDON_LOADED' and arg1==id) or GROUP_LEFT then
        set_GroupGuid()

    elseif event=='TIME_PLAYED_MSG' then--总游戏时间：%s
        set_TIME_PLAYED_MSG(arg1, arg2)

    end
end)