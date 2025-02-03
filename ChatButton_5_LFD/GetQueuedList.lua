local e= select(2, ...)





function WoWTools_LFDMixin:GetQueuedList(category, reTips, reRole)--排队情况
    local list= GetLFGQueuedList(category)
    local  hasData, _, tank, healer, dps, _, _, _, _, _, _, _, _, _, _, _, queuedTime = GetLFGQueueStats(category)
    if not hasData or not list then
        return
    end
    local m, num= nil, 0
    for dungeonID, _ in pairs(list) do
        local name= dungeonID and GetLFGDungeonInfo(dungeonID)
        if name then
            num= num+1
            if reTips then
                name= e.cn(name)
                local boss=''
                if category==LE_LFG_CATEGORY_RF then
                    local numEncounters = GetLFGDungeonNumEncounters(dungeonID)
                    local kill=0
                    for index = 1, numEncounters do
                        local isKilled = select(3, GetLFGDungeonEncounterInfo(dungeonID, index))
                        if ( isKilled ) then
                            kill=kill+1
                        end
                    end
                    boss=' '..kill..' / '..numEncounters
                    if kill==numEncounters then boss=RED_FONT_COLOR_CODE..boss..'|r' end
                    local mapName=select(19, GetLFGDungeonInfo(dungeonID))
                    if mapName then
                        name= name.. ' ('..e.cn(mapName)..')'
                    end
                end
                m=(m and m..'|n  ' or '  ')
                    ..num..') |r '
                    ..name
                    ..boss
                    ..WoWTools_LFDMixin:GetRewardInfo(dungeonID)
            end
        end
    end
    if m and reRole then
        m=m..((tank and tank>0) and INLINE_TANK_ICON..'|cnRED_FONT_COLOR:'..tank..'|r'  or '')
        ..((healer and healer>0) and INLINE_HEALER_ICON..'|cnRED_FONT_COLOR:'..healer..'|r'  or '')
        ..((dps and dps>0) and INLINE_DAMAGER_ICON..'|cnRED_FONT_COLOR:'..dps..'|r'  or '')
        ..'  '..(queuedTime and WoWTools_TimeMixin:Info(queuedTime, true) or '')
        ..' '
    end
    return num, m
end

