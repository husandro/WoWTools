local e= select(2, ...)
local function Save()
    return WoWTools_EncounterMixin.Save
end


--所有角色已击杀世界BOSS提示
function WoWTools_EncounterMixin:GetWorldData(frame)
    GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
    GameTooltip:ClearLines()
    GameTooltip:AddDoubleLine(format('%s %s',
        e.onlyChinese and '世界BOSS/稀有 ' or format('%s/%s', format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CHANNEL_CATEGORY_WORLD, BOSS), GARRISON_MISSION_RARE),
        e.GetShowHide(Save().showWorldBoss)
    ), e.Icon.left)

    GameTooltip:AddLine(' ')
    for guid, info in pairs(e.WoWDate or {}) do
        local find
        local text, num= nil, 0
        for bossName, worldBossID in pairs(info.Worldboss.boss) do--世界BOSS
            num=num+1
            text= text and text..' ' or '   '
            text= text..'|cnGREEN_FONT_COLOR:'..num..')|r'.. WoWTools_EncounterMixin:GetBossNameSort(e.cn(bossName))
        end
        if text then
            GameTooltip:AddLine(text, nil,nil,nil, true)
            find=true
        end

        text, num= nil, 0
        for bossName, _ in pairs(info.Rare.boss) do--稀有怪
            num= num+1
            text= text and text..' ' or ''
            text= text..'(|cnGREEN_FONT_COLOR:'..num..'|r)'.. WoWTools_EncounterMixin:GetBossNameSort(e.cn(bossName))
        end
        if text then
            GameTooltip:AddLine(text, nil,nil,nil, true)
            find=true
        end
        if find then
            GameTooltip:AddDoubleLine(WoWTools_UnitMixin:GetPlayerInfo({guid=guid, faction=info.faction, reName=true, reRealm=true}), guid==e.Player.guid and '|A:auctionhouse-icon-favorite:0:0|a')
        end
    end
    GameTooltip:AddLine(' ')
    GameTooltip:AddDoubleLine('instanceID', frame.instanceID)
    GameTooltip:Show()
end