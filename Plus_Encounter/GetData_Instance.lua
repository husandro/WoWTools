local e= select(2, ...)







--界面,击杀,数据
function WoWTools_EncounterMixin:GetInstanceData(frame, showTips)
    local text,find
    local instanceID= frame.instanceID or frame.journalInstanceID
    if not instanceID then
        return
    end

    if instanceID==1205 or instanceID==1192 or instanceID==1028 or instanceID==822 or instanceID==557 or instanceID==322 then--世界BOSS
        if showTips then
            WoWTools_EncounterMixin:GetWorldData(frame)--角色世界BOSS提示            
            find=true
        else
            for guid, info in pairs(e.WoWDate or {}) do--世界BOSS
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
                        if isKilled then t2='|cFFFF0000'..t2..'|r' end
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



