WoWTools_EncounterMixin={}









function WoWTools_EncounterMixin:GetBossNameSort(name)--取得怪物名称, 短名称
    name= WoWTools_TextMixin:CN(name)
    name=name:gsub('(,.+)','')
    name=name:gsub('(，.+)','')
    name=name:gsub('·.+','')
    name=name:gsub('%-.+','')
    name=name:gsub('<.+>', '')
    return name
end











local function Set_WorldData_Tooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:ClearLines()
    GameTooltip:AddDoubleLine(format('%s %s',
        WoWTools_DataMixin.onlyChinese and '世界BOSS/稀有 ' or format('%s/%s', format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CHANNEL_CATEGORY_WORLD, BOSS), GARRISON_MISSION_RARE),
        WoWTools_TextMixin:GetShowHide(WoWToolsSave['Adventure_Journal'].showWorldBoss)
    ), WoWTools_DataMixin.Icon.left)

    GameTooltip:AddLine(' ')
    for guid, info in pairs(WoWTools_WoWDate or {}) do
        local find
        local text, num= nil, 0
        for bossName in pairs(info.Worldboss.boss) do--世界BOSS
            num=num+1
            text= text and text..' ' or '   '
            text= text..'|cnGREEN_FONT_COLOR:'..num..')|r'.. WoWTools_EncounterMixin:GetBossNameSort(WoWTools_TextMixin:CN(bossName))
        end
        if text then
            GameTooltip:AddLine(text, nil,nil,nil, true)
            find=true
        end

        text, num= nil, 0
        for bossName, _ in pairs(info.Rare.boss) do--稀有怪
            num= num+1
            text= text and text..' ' or ''
            text= text..'(|cnGREEN_FONT_COLOR:'..num..'|r)'.. WoWTools_EncounterMixin:GetBossNameSort(WoWTools_TextMixin:CN(bossName))
        end
        if text then
            GameTooltip:AddLine(text, nil,nil,nil, true)
            find=true
        end
        if find then
            GameTooltip:AddDoubleLine(
                WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {faction=info.faction, reName=true, reRealm=true}),
                guid==WoWTools_DataMixin.Player.GUID and '|A:auctionhouse-icon-favorite:0:0|a'
            )
        end
    end
    if self.instanceID then
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine('instanceID', self.instanceID)
    end
    GameTooltip:Show()
end


--所有角色已击杀世界BOSS提示
function WoWTools_EncounterMixin:GetWorldData(frame)
    Set_WorldData_Tooltip(frame)
end






















local function GetInstanceData(frame, showTips)
    local text,find
    local instanceID= frame.instanceID or frame.journalInstanceID
    if not instanceID then
        return
    end

    if instanceID==1205 or instanceID==1192 or instanceID==1028 or instanceID==822 or instanceID==557 or instanceID==322 then--世界BOSS
        if showTips then
            Set_WorldData_Tooltip(frame)--角色世界BOSS提示            
            find=true
        else
            for guid, info in pairs(WoWTools_WoWDate or {}) do--世界BOSS
                if guid==WoWTools_DataMixin.Player.GUID then
                    local num=0
                    for bossName, worldBossID in pairs(info.Worldboss.boss) do
                        num= num+1
                        text= text and text..' ' or ''
                        if num>2 and  select(2, math.modf(num / 3))==0 then
                            text=text..'|n'
                        end
                        text= text..'|cnGREEN_FONT_COLOR:'..num..')|r'.. WoWTools_EncounterMixin:GetBossNameSort(WoWTools_TextMixin:CN(bossName))
                    end
                    break
                end
            end
        end
    else
        local n=GetNumSavedInstances()
        local instancename= frame.tooltipTitle or EJ_GetInstanceInfo(instanceID)
        for i=1, n do
            local name, _, reset, difficultyID, _, _, _, _, _, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
            if instancename==name and (not reset or reset>0) and numEncounters and encounterProgress and numEncounters>0 and encounterProgress>0 then
                difficultyName= WoWTools_MapMixin:GetDifficultyColor(difficultyName, difficultyID) or difficultyName
                local num=encounterProgress..'/'..numEncounters..'|r'
                num= encounterProgress==numEncounters and '|cnGREEN_FONT_COLOR:'..num..'|r' or num
                if showTips then
                    if find then
                        GameTooltip:AddLine(' ')
                    end

                    GameTooltip:AddDoubleLine((difficultyName or WoWTools_TextMixin:CN(name) or '')..' '..(num or ''))
                    local t
                    for j=1,numEncounters do
                        local bossName,_,isKilled = GetSavedInstanceEncounterInfo(i,j)
                        local t2
                        t2= WoWTools_TextMixin:CN(bossName)
                        if t then
                            t2=t2..' ('..j else t2=j..') '..t2
                        end
                        if isKilled then t2='|cnWARNING_FONT_COLOR:'..t2..'|r' end
                        if j==numEncounters or t then
                            if not t then
                                t=t2
                                t2=nil
                            end
                            GameTooltip:AddDoubleLine(t,t2)
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




--界面,击杀,数据
function WoWTools_EncounterMixin:GetInstanceData(frame, showTips)
    return GetInstanceData(frame, showTips)
end



