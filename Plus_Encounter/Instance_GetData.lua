local e= select(2, ...)
local function Save()
    return WoWTools_EncounterMixin.Save
end










local function getBossNameSort(name)--取得怪物名称, 短名称
    name= e.cn(name)
    name=name:gsub('(,.+)','')
    name=name:gsub('(，.+)','')
    name=name:gsub('·.+','')
    name=name:gsub('%-.+','')
    name=name:gsub('<.+>', '')
    return name
end

--所有角色已击杀世界BOSS提示
local function set_EncounterJournal_World_Tips(self)
    e.tips:SetOwner(self, "ANCHOR_LEFT")
    e.tips:ClearLines()
    e.tips:AddDoubleLine(format('%s %s',
        e.onlyChinese and '世界BOSS/稀有 ' or format('%s/%s', format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CHANNEL_CATEGORY_WORLD, BOSS), GARRISON_MISSION_RARE),
        e.GetShowHide(Save().showWorldBoss)
    ), e.Icon.left)

    e.tips:AddLine(' ')
    for guid, info in pairs(e.WoWDate or {}) do
        local find
        local text, num= nil, 0
        for bossName, worldBossID in pairs(info.Worldboss.boss) do--世界BOSS
            num=num+1
            text= text and text..' ' or '   '
            text= text..'|cnGREEN_FONT_COLOR:'..num..')|r'..getBossNameSort(e.cn(bossName), worldBossID)
        end
        if text then
            e.tips:AddLine(text, nil,nil,nil, true)
            find=true
        end

        text, num= nil, 0
        for bossName, _ in pairs(info.Rare.boss) do--稀有怪
            num= num+1
            text= text and text..' ' or ''
            text= text..'(|cnGREEN_FONT_COLOR:'..num..'|r)'..getBossNameSort(e.cn(bossName))
        end
        if text then
            e.tips:AddLine(text, nil,nil,nil, true)
            find=true
        end
        if find then
            e.tips:AddDoubleLine(WoWTools_UnitMixin:GetPlayerInfo({guid=guid, faction=info.faction, reName=true, reRealm=true}), guid==e.Player.guid and '|A:auctionhouse-icon-favorite:0:0|a')
        end
    end
    e.tips:AddLine(' ')
    e.tips:AddDoubleLine('instanceID', self.instanceID)
    e.tips:Show()
end













--界面,击杀,数据
local function encounterJournal_ListInstances_set_Instance(self, showTips)
    local text,find
    local instanceID= self.instanceID or self.journalInstanceID
    if not instanceID then
        return
    end

    if instanceID==1205 or instanceID==1192 or instanceID==1028 or instanceID==822 or instanceID==557 or instanceID==322 then--世界BOSS
        if showTips then
            set_EncounterJournal_World_Tips(self)--角色世界BOSS提示            
            find=true
        else
            for guid, info in pairs(e.WoWDate or {}) do--世界BOSS
                if guid==e.Player.guid then
                    local num=0
                    for bossName, worldBossID in pairs(info.Worldboss.boss) do
                        num= num+1
                        text= text and text..' ' or ''
                        if num>2 and  select(2, math.modf(num / 3))==0 then
                            text=text..'|n'
                        end
                        text= text..'|cnGREEN_FONT_COLOR:'..num..')|r'..getBossNameSort(e.cn(bossName), worldBossID)
                    end
                    break
                end
            end
        end
    else
        local n=GetNumSavedInstances()
        local instancename= self.tooltipTitle or EJ_GetInstanceInfo(instanceID)
        for i=1, n do
            local name, _, reset, difficultyID, _, _, _, _, _, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
            if instancename==name and (not reset or reset>0) and numEncounters and encounterProgress and numEncounters>0 and encounterProgress>0 then
                difficultyName= WoWTools_MapMixin:GetDifficultyColor(difficultyName, difficultyID) or difficultyName
                local num=encounterProgress..'/'..numEncounters..'|r'
                num= encounterProgress==numEncounters and '|cnGREEN_FONT_COLOR:'..num..'|r' or num
                if showTips then
                    if find then
                        e.tips:AddLine(' ')
                    end

                    e.tips:AddDoubleLine((difficultyName or e.cn(name) or '')..' '..(num or ''))
                    local t
                    for j=1,numEncounters do
                        local bossName,_,isKilled = GetSavedInstanceEncounterInfo(i,j)
                        local t2
                        t2= e.cn(bossName)
                        if t then
                            t2=t2..' ('..j else t2=j..') '..t2
                        end
                        if isKilled then t2='|cFFFF0000'..t2..'|r' end
                        if j==numEncounters or t then
                            if not t then
                                t=t2
                                t2=nil
                            end
                            e.tips:AddDoubleLine(t,t2)
                            t=nil
                        else
                            t=t2
                        end
                    end
                    find=true
                else
                    text= text and text..'|n' or ''
                    text=text..difficultyName..' '..num
                end
            end
        end
    end
    if not showTips then
        return text
    else
        return find
    end
end
