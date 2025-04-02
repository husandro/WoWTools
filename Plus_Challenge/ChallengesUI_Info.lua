local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end

local Frame
























--[[(资料来自)：
https://www.wowhead.com/guide/mythic-plus-dungeons/dragonflight-season-4/overview#mythic-affixes
AngryKeystones Schedule



148/萨拉塔斯的交易：扬升
159/萨拉塔斯的交易：湮灭
158/萨拉塔斯的交易：虚缚
160/萨拉塔斯的交易：吞噬

https://www.wowhead.com/cn/affix=9/残暴
https://www.wowhead.com/cn/affix=152/挑战者的危境
https://www.wowhead.com/cn/affix=10/强韧
https://www.wowhead.com/cn/affix=147/萨拉塔斯的狡诈

local affixSchedule = {--C_MythicPlus.GetCurrentSeason() C_MythicPlus.GetCurrentUIDisplaySeason()
    --season=12,--当前赛季
    --[1]={[1]=9, [2]=124, [3]=6},	--Tyrannical Storming Raging
    [2]={[1]=10, [2]=134, [3]=7},	--Fortified Entangling Bolstering
    [3]={[1]=9, [2]=136, [3]=123},	--Tyrannical Incorporeal Spiteful
    [4]={[1]=10, [2]=135, [3]=6},	--Fortified 	Afflicted	Raging
    [5]={[1]=9, [2]=3, [3]=8},	--Tyrannical Volcanic 	Sanguine
    [6]={[1]=10, [2]=124, [3]=11},	--Fortified 	Storming Bursting
    [7]={[1]=9, [2]=135, [3]=7},	--Tyrannical Afflicted 	Bolstering
    [8]={[1]=10, [2]=136, [3]=8},	--Fortified 	Incorporeal Sanguine
    [9]={[1]=9, [2]=134, [3]=11},	--Tyrannical Entangling Bursting
    [10]={[1]=10, [2]=3, [3]=123},	--Fortified 	Volcanic 	Spiteful
    -- TWW Season 2 (Sort:[1](Level 4+);[2](Level 7+);[3](Level 10+);[4](Level 12+))
	-- Information from(资料来自)：https://www.wowhead.com/guide/mythic-plus-dungeons/the-war-within-season-2/overview
	{ [1]=148, [2] =9 , [3]=10, [4]=147, }, -- (1) Xal’atath’s Bargain: Ascendant | Tyrannical | Fortified  | Xal’atath’s Guile
	{ [1]=162, [2] =10, [3]=9 , [4]=147, }, -- (2) Xal’atath’s Bargain: Pulsar    | Fortified  | Tyrannical | Xal’atath’s Guile
	{ [1]=158, [2] =9 , [3]=10, [4]=147, }, -- (3) Xal’atath’s Bargain: Voidbound | Tyrannical | Fortified  | Xal’atath’s Guile
	{ [1]=160, [2] =10, [3]=9 , [4]=147, }, -- (4) Xal’atath’s Bargain: Devour    | Fortified  | Tyrannical | Xal’atath’s Guile
	{ [1]=162, [2] =9 , [3]=10, [4]=147, }, -- (5) Xal’atath’s Bargain: Pulsar    | Tyrannical | Fortified  | Xal’atath’s Guile
	{ [1]=148, [2] =10, [3]=9 , [4]=147, }, -- (6) Xal’atath’s Bargain: Ascendant | Fortified  | Tyrannical | Xal’atath’s Guile
	{ [1]=160, [2] =9 , [3]=10, [4]=147, }, -- (7) Xal’atath’s Bargain: Devour    | Tyrannical | Fortified  | Xal’atath’s Guile
	{ [1]=158, [2] =10, [3]=9 , [4]=147, }, -- (8) Xal’atath’s Bargain: Voidbound | Fortified  | Tyrannical | Xal’atath’s Guile
}

]]








































--##################
--史诗钥石地下城, 界面
--[[词缀日程表AngryKeystones Schedule.lua
local function Init_Affix()
    if C_AddOns.IsAddOnLoaded("AngryKeystones")
        or not affixSchedule
        or Frame.affixesButton
        --or C_MythicPlus.GetCurrentSeason()~= affixSchedule.season
    then
        affixSchedule=nil
        return
    end
    local currentWeek
    local max= 0
    local currentAffixes = C_MythicPlus.GetCurrentAffixes()
    if currentAffixes then
        for index, affixes in ipairs(affixSchedule) do
            if not currentWeek then
                local matches = 0
                for _, affix in ipairs(currentAffixes) do
                    if affix.id == affixes[1] or affix.id == affixes[2] or affix.id == affixes[3] then
                        matches = matches + 1
                    end
                end
                if matches >= 3 then
                    currentWeek = index
                end
            end
            max=max+1
        end
    end

    if not currentWeek then
        affixSchedule=nil
        return
    end

    local one= currentWeek+1
    one= one>max and 1 or one

    for i=1, 3 do
        local btn= WoWTools_ButtonMixin:Cbtn(Frame, {size={22,22}, isType2=true})--建立 Affix 按钮
        local affixID= affixSchedule[one][i]
        btn.affixInfo= affixID
        btn:SetSize(24, 24)
        btn.Border= btn:CreateTexture(nil, "BORDER")
        btn.Border:SetAllPoints()
        btn.Border:SetAtlas("ChallengeMode-AffixRing-Sm")
        btn.Portrait = btn:CreateTexture(nil, "BACKGROUND")
        btn.Portrait:SetAllPoints(btn.Border)
        local _, _, filedataid = C_ChallengeMode.GetAffixInfo(affixID);
        SetPortraitToTexture(btn.Portrait, filedataid)--btn.SetUp = ScenarioChallengeModeAffixMixin.SetUp
        btn:SetScript("OnEnter", ChallengesKeystoneFrameAffixMixin.OnEnter)
        btn:SetScript("OnLeave", GameTooltip_Hide)
        btn.affixID = affixID
        btn:SetPoint('TOP', ChallengesFrame.WeeklyInfo.Child.AffixesContainer, 'BOTTOM', ((i-1)*24)-24, -3)---((index-1)*24))

        if i==1 then
            local label= WoWTools_LabelMixin:Create(btn)
            label:SetPoint('RIGHT', btn, 'LEFT')
            label:SetText(one)
            --if index==1 then
            --label:SetTextColor(0,1,0)
            label:EnableMouse(true)
            label.affixSchedule= affixSchedule
            label.currentWeek= currentWeek
            label.max= max
            label:SetScript('OnLeave', function(self) self:SetAlpha(1) end)
            label:SetScript('OnEnter', function(self)
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddLine(WoWTools_ChallengeMixin.addName)
                GameTooltip:AddLine(' ')
                for idx=1, self.max do
                    local tab= self.affixSchedule[idx]
                    local text=''
                    for i2=1, 3 do
                        local affixID= tab[i2]
                        local name, _, filedataid = C_ChallengeMode.GetAffixInfo(affixID)
                        text= text..'|T'..filedataid..':0|t'..WoWTools_TextMixin:CN(name)..'  '
                    end
                    local col= idx==self.currentWeek and '|cnGREEN_FONT_COLOR:' or (select(2, math.modf(idx/2))==0 and '|cffff8200') or '|cffffffff'
                    GameTooltip:AddLine(col..(idx<10 and '  ' or '')..idx..') '..text)
                end
                GameTooltip:Show()
                self:SetAlpha(0.3)
            end)
            --end
        end
    end
    --end
    --ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:ClearAllPoints()
    --ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:SetPoint('BOTTOM', 0, -12)
end

]]















local function GetNum(mapID, all)--取得完成次数,如 1/10
    local nu, to=0,0
    local info
    if all then
        info=C_MythicPlus.GetRunHistory(true, true) or {}--全部
    else
        info=C_MythicPlus.GetRunHistory(false, true) or {}--本周
    end
    for _,v in pairs(info) do
        if v.mapChallengeModeID==mapID then
            if v.completed then
                nu=nu+1
            end
            to=to+1
        end
    end
    if to>0 then
        return '|cff00ff00'..nu..'|r/'..to, nu, to
    end
end


























































local function Set_Update()--Blizzard_ChallengesUI.lua
    local self= ChallengesFrame
    if not self.maps or #self.maps==0 then
        return
    end

    local currentChallengeMapID= C_MythicPlus.GetOwnedKeystoneChallengeMapID()--当前, KEY地图,ID
    local keyStoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()--当前KEY，等级




    for i=1, #self.maps do
        local frame = self.DungeonIcons[i]
        if frame and frame.mapID then
            local insTab=WoWTools_DataMixin.ChallengesSpellTabs[frame.mapID] or {}
            frame.spellID= insTab.spell
            frame.journalInstanceID= insTab.ins
            if not frame.setTips then
                frame:HookScript('OnEnter', function(self2)--提示
                    if not self2.mapID or Save().hideIns then
                        return
                    end
                    local intimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(self2.mapID)
                    if intimeInfo then
                        GameTooltip:AddLine(' ')
                        for index, info in pairs(intimeInfo.members) do
                            if info.name then
                                if index==1 then
                                    if intimeInfo.completionDate and intimeInfo.level then--完成,日期
                                        local d=intimeInfo.completionDate
                                        local time= format('|cnGREEN_FONT_COLOR:%s:%s %d/%d/%d %s', d.hour<10 and '0'..d.hour or d.hour, d.minute<10 and '0'..d.minute or d.minute, d.day, d.month, d.year, '('..intimeInfo.level..')')
                                        local time2
                                        if overtimeInfo and overtimeInfo.completionDate and overtimeInfo.level then
                                            d=overtimeInfo.completionDate
                                            time2= format('|cffff0000%s %s:%s %d/%d/%d', '('..overtimeInfo.level..')', d.hour<10 and '0'..d.hour or d.hour, d.minute<10 and '0'..d.minute or d.minute, d.day, d.month, d.year)
                                        end
                                        GameTooltip:AddDoubleLine(time, time2)
                                    end
                                end

                                local text, text2= '', nil
                                if info.specID then
                                    local icon, role= select(4, GetSpecializationInfoByID(info.specID))
                                    text= WoWTools_DataMixin.Icon[role]..'|T'..icon..':0|t'
                                end
                                text= info.name== WoWTools_DataMixin.Player.Name and text..info.name..'|A:auctionhouse-icon-favorite:0:0|a' or text..info.name
                                if info.classID then
                                    local classFile= select(2, GetClassInfo(info.classID))
                                    local argbHex = classFile and select(4, GetClassColor(classFile))
                                    if argbHex then
                                        text= '|c'..argbHex..text..'|r'
                                    end
                                end
                                if overtimeInfo and overtimeInfo.members and overtimeInfo.members[index] and overtimeInfo.members[index].name then
                                    local info2= overtimeInfo.members[index]
                                    text2= info2.name== WoWTools_DataMixin.Player.Name and ('|A:auctionhouse-icon-favorite:0:0|a'..info2.name) or info2.name
                                    if info2.specID then
                                        local icon, role= select(4, GetSpecializationInfoByID(info.specID))
                                        text2= text2..'|T'..icon..':0|t'..WoWTools_DataMixin.Icon[role]
                                    end
                                    if info2.classID then
                                        local classFile= select(2, GetClassInfo(info2.classID))
                                        local argbHex = classFile and select(4, GetClassColor(classFile))
                                        if argbHex then
                                            text2= '|c'..argbHex..text2..'|r'
                                        end
                                    end
                                end
                                GameTooltip:AddDoubleLine(text, text2)

                                if index==#intimeInfo.members and intimeInfo.affixIDs then
                                    local affix, affix2='', ''
                                    for index2, v in pairs(intimeInfo.affixIDs) do
                                        local filedataid = select(3, C_ChallengeMode.GetAffixInfo(v))
                                        if filedataid then
                                            affix= affix.. '|T'..filedataid..':0|t'
                                        end
                                        if overtimeInfo and overtimeInfo.affixIDs and overtimeInfo.affixIDs[index2] then
                                            filedataid = select(3, C_ChallengeMode.GetAffixInfo(overtimeInfo.affixIDs[index2]))
                                            if filedataid then
                                                affix2= affix2.. '|T'..filedataid..':0|t'
                                            end
                                        end
                                    end
                                    if affix ~='' then
                                        GameTooltip:AddDoubleLine(affix, affix2)
                                    end
                                end
                            end
                        end
                    end

                    GameTooltip:AddLine(' ')
                    local timeLimit, texture, backgroundTexture = select(3, C_ChallengeMode.GetMapUIInfo(self2.mapID))
                    local a=GetNum(self2.mapID, true) or RED_FONT_COLOR_CODE..(WoWTools_DataMixin.onlyChinese and '无' or NONE)..'|r'--所有
                    local w=GetNum(self2.mapID) or RED_FONT_COLOR_CODE..(WoWTools_DataMixin.onlyChinese and '无' or NONE)..'|r'--本周
                    GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '历史' or HISTORY)..': '..a, (WoWTools_DataMixin.onlyChinese and '本周' or CHALLENGE_MODE_THIS_WEEK)..': '..w)
                    GameTooltip:AddLine(' ')
                    GameTooltip:AddDoubleLine('mapChallengeModeID |cnGREEN_FONT_COLOR:'.. self2.mapID..'|r', timeLimit and (WoWTools_DataMixin.onlyChinese and '限时' or GROUP_FINDER_PVE_PLAYSTYLE3)..' '.. SecondsToTime(timeLimit))
                    if texture and backgroundTexture then
                        GameTooltip:AddDoubleLine('|T'..texture..':0|t'..texture, '|T'..backgroundTexture..':0|t'..backgroundTexture)
                    end
                    GameTooltip:Show()
                end)

                frame:EnableMouse(true)
                frame:SetScript('OnMouseDown', function(self2)
                    if self.journalInstanceID then
                        WoWTools_LoadUIMixin:JournalInstance(self.journalInstanceID)
                    end
                end)

                frame.setTips=true
            end

             --#########
            --名称, 缩写
            --#########
            local nameText = not Save().hideIns and C_ChallengeMode.GetMapUIInfo(frame.mapID)--名称
            if nameText then
                if not frame.nameLable then
                    frame.nameLable=WoWTools_LabelMixin:Create(frame, {size=10, mouse= true, justifyH='CENTER'})
                    frame.nameLable:SetPoint('BOTTOM', frame, 'TOP', 0, 3)
                    frame.nameLable:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
                    frame.nameLable:SetScript('OnEnter', function(self2)
                        if self2.name then
                            GameTooltip:SetOwner(self2:GetParent(), "ANCHOR_LEFT")
                            GameTooltip:ClearLines()
                            GameTooltip:AddLine(self2.name..' ')
                            GameTooltip:Show()
                        end
                        self2:SetAlpha(0.5)
                    end)
                end
                frame.nameLable.name= nameText
                --  ( ) . % + - * ? [ ^ $
                if (WoWTools_DataMixin.onlyChinese or LOCALE_zhCN) and WoWTools_DataMixin.ChallengesSpellTabs[frame.mapID] then
                    nameText= WoWTools_DataMixin.ChallengesSpellTabs[frame.mapID].name
                else
                    nameText=nameText:match('%((.+)%)') or nameText
                    nameText=nameText:match('%（(.+)%）') or nameText
                    nameText=nameText:match('%- (.+)') or nameText
                    nameText=nameText:match(HEADER_COLON..'(.+)') or nameText
                    nameText=nameText:match('·(.+)') or nameText
                    nameText=WoWTools_TextMixin:sub(nameText, 5, 12)
                end
                frame.nameLable:SetScale(Save().insScale or 1)
            end
            if frame.nameLable then
                frame.nameLable:SetText(nameText or '')
            end



            --#########
            --分数，最佳
            --#########
            local intimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(frame.mapID)
            local affixScores, overAllScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(frame.mapID)
            if (overAllScore and intimeInfo or overtimeInfo) then
                if not frame.scoreLable then--分数
                    frame.scoreLable=WoWTools_LabelMixin:Create(frame, {size=10, mouse=true})
                    frame.scoreLable:SetPoint('BOTTOMLEFT', frame, 0, 24)
                    frame.scoreLable:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
                    frame.scoreLable:SetScript('OnEnter', function(self2)
                        if self2.score then
                            GameTooltip:SetOwner(self2:GetParent(), "ANCHOR_RIGHT")
                            GameTooltip:ClearLines()
                            GameTooltip:AddLine(format(WoWTools_DataMixin.onlyChinese and '史诗钥石评分：%s' or CHALLENGE_COMPLETE_DUNGEON_SCORE, self2.score))
                            GameTooltip:Show()
                            self2:SetAlpha(0.5)
                        end
                    end)

                    --###########
                    --移动层数位置
                    --###########
                    if frame.HighestLevel then
                        frame.HighestLevel:ClearAllPoints()
                        frame.HighestLevel:SetPoint('LEFT', 0, 12)
                        frame.HighestLevel:EnableMouse(true)
                        frame.HighestLevel:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
                        frame.HighestLevel:SetScript('OnEnter', function(self2)
                            GameTooltip:SetOwner(self2:GetParent(), "ANCHOR_RIGHT")
                            GameTooltip:ClearLines()
                            GameTooltip:AddLine(format(WoWTools_DataMixin.onlyChinese and '最佳%s' or DUNGEON_SCORE_BEST_AFFIX, (WoWTools_DataMixin.onlyChinese and '等级' or LEVEL)..': '..self2:GetText()))
                            GameTooltip:Show()
                            self2:SetAlpha(0.5)
                        end)
                    end
                end
                frame.scoreLable:SetText((overAllScore and not Save().hideIns) and '|A:AdventureMapIcon-MissionCombat:16:16|a'..WoWTools_ChallengeMixin:KeystoneScorsoColor(overAllScore,nil,true) or '')
                frame.scoreLable.score= overAllScore
                frame.scoreLable:SetScale(Save().insScale or 1)

                if affixScores and #affixScores > 0 then --最佳 
                    local nameA, _, filedataidA = C_ChallengeMode.GetAffixInfo(10)
                    local nameB, _, filedataidB = C_ChallengeMode.GetAffixInfo(9)
                    for _, info in ipairs(affixScores) do
                        local text
                        local label=frame['affixInfo'..info.name]
                        if info.level and info.level>0 and info.durationSec and (info.name == nameA or info.name==nameB) and not Save().hideIns then
                            if not label then
                                label= WoWTools_LabelMixin:Create(frame, {justifyH='RIGHT', mouse=true})
                                if info.name== nameA then
                                    label:SetPoint('BOTTOMLEFT',frame)
                                else
                                    label:SetPoint('BOTTOMLEFT', frame, 0, 12)
                                end
                                label:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
                                label:SetScript('OnEnter', function(self2)
                                    GameTooltip:SetOwner(self2:GetParent(), "ANCHOR_RIGHT")
                                    GameTooltip:ClearLines()
                                    GameTooltip:AddDoubleLine(format(WoWTools_DataMixin.onlyChinese and '最佳%s' or DUNGEON_SCORE_BEST_AFFIX, self2.name),
                                                            self2.overTime and '|cff828282'..format(WoWTools_DataMixin.onlyChinese and '%s (超时)' or DUNGEON_SCORE_OVERTIME_TIME, WoWTools_TimeMixin:SecondsToClock(self2.durationSec)) or WoWTools_TimeMixin:SecondsToClock(self2.durationSec)
                                                        )
                                    GameTooltip:Show()
                                    self2:SetAlpha(0.5)
                                end)
                                frame['affixInfo'..info.name]= label
                            end
                            local level= info.overTime and '|cff828282'..info.level..'|r' or info.level
                            local icon='|T'..(info.name == nameA and filedataidA or filedataidB)..':0|t'
                            text= icon..level

                            label.overTime= info.overTime
                            label.durationSec= info.durationSec
                            label.name= icon..info.name..': '..level
                        end
                        if label then
                            label:SetScale(Save().insScale or 1)
                            label:SetText(text or '')
                        end
                    end
                end

                --#####################
                --副本 完成/总次数 (全部)
                --#####################
                local numText
                if not Save().hideIns then
                    local all, completed, totale= GetNum(frame.mapID, true)
                    local week= GetNum(frame.mapID)--本周
                    if all or week then
                        if not frame.completedLable then
                            frame.completedLable=WoWTools_LabelMixin:Create(frame, {mouse=true})
                            frame.completedLable:SetPoint('TOPLEFT', frame)
                            frame.completedLable:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
                            frame.completedLable:SetScript('OnEnter', function(self2)
                                if self2.all or self2.week then
                                    GameTooltip:SetOwner(self2:GetParent(), "ANCHOR_RIGHT")
                                    GameTooltip:ClearLines()
                                    GameTooltip:AddDoubleLine(
                                        WoWTools_DataMixin.onlyChinese and '历史 |cnGREEN_FONT_COLOR:完成|r/总计' or (HISTORY..' |cnGREEN_FONT_COLOR:'..COMPLETE..'|r/'..TOTAL) ,
                                        self2.all or (WoWTools_DataMixin.onlyChinese and '无' or NONE)
                                    )
                                    GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '本周' or CHALLENGE_MODE_THIS_WEEK, self2.week and '('..self2.week..')' or (WoWTools_DataMixin.onlyChinese and '无' or NONE))
                                    if self2.completed and self2.totale and self2.completed < self2.totale then
                                        GameTooltip:AddLine(' ')
                                        GameTooltip:AddDoubleLine(self2.totale..' - |cnGREEN_FONT_COLOR:'..self2.completed..'|r =', '|cnRED_FONT_COLOR:'..format(WoWTools_DataMixin.onlyChinese and '%s (超时)' or DUNGEON_SCORE_OVERTIME_TIME, self2.totale-self2.completed))
                                    end
                                    GameTooltip:Show()
                                    self2:SetAlpha(0.5)
                                end
                            end)
                        end
                        numText= (all or '')..((week and week~=all) and ' |cffffffff(|r'..week..'|cffffffff)|r' or '')
                        frame.completedLable.all=all or week
                        frame.completedLable.week= week
                        frame.completedLable.completed= completed
                        frame.completedLable.totale= totale
                    end
                end
                if frame.completedLable then
                    frame.completedLable:SetScale(Save().insScale or 1)
                    frame.completedLable:SetText(numText or '')
                end
            end

            --################
            --提示, 包里KEY地图
            --################
            local findKey= currentChallengeMapID== frame.mapID and not Save().hideIns or false
            if findKey and not frame.currentKey then--提示, 包里KEY地图
                frame.currentKey= frame:CreateTexture(nil, 'OVERLAY', nil, self:GetFrameLevel()+1)
                frame.currentKey:SetPoint('RIGHT', frame, 0, 8)
                frame.currentKey:SetAtlas('common-icon-checkmark')
                frame.currentKey:SetSize(22,22)
                frame.currentKey:EnableMouse(true)
                frame.currentKey:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(1) self2.label:SetAlpha(1) end)
                frame.currentKey:SetScript('OnEnter', function(self2)
                    GameTooltip:SetOwner(self2:GetParent(), "ANCHOR_RIGHT")
                    GameTooltip:ClearLines()
                    local bagID, slotID= select(2, WoWTools_BagMixin:Ceca(nil, {isKeystone=true}))--查找，包的key
                    if bagID and slotID then
                        GameTooltip:SetBagItem(bagID, slotID)
                    end
                    GameTooltip:Show()
                    self2:SetAlpha(0.3)
                    self2.label:SetAlpha(0.3)
                end)
                --当前KEY，等级
                frame.currentKey.label=WoWTools_LabelMixin:Create(frame)
                frame.currentKey.label:SetPoint('TOP', frame.currentKey,-2,2)
            end
            if frame.currentKey then
                frame.currentKey:SetScale(Save().insScale or 1)
                frame.currentKey:SetShown(findKey)
                frame.currentKey.label:SetText(keyStoneLevel or '')
            end

            --[[-#####
            --传送门
            --#####
            if not Save().hidePort then
                if frame.spellID then
                    if not frame.spellPort then
                        local h=frame:GetWidth()/3 +8
                        local texture= C_Spell.GetSpellTexture(frame.spellID)
                        frame.spellPort= WoWTools_ButtonMixin:Cbtn(frame, {
                            isSecure=true,
                            size=h,
                            texture= texture,
                            atlas=not texture and 'WarlockPortal-Yellow-32x32',
                            --pushe=not texture
                        })
                        frame.spellPort:SetPoint('BOTTOMRIGHT', frame)--, 4,-4)
                        frame.spellPort:SetScript("OnEnter",function(self2)
                            local parent= self2:GetParent()
                            if parent.spellID then
                                GameTooltip:SetOwner(parent, "ANCHOR_RIGHT")
                                GameTooltip:ClearLines()
                                GameTooltip:SetSpellByID(parent.spellID)
                                if not IsSpellKnownOrOverridesKnown(parent.spellID) then--没学会
                                    GameTooltip:AddLine('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '法术尚未学会' or SPELL_FAILED_NOT_KNOWN))
                                end
                                GameTooltip:Show()
                                self2:SetAlpha(1)
                            end
                        end)
                        frame.spellPort:SetScript("OnLeave",function(self2)
                            GameTooltip:Hide()
                            local spellID=self2:GetParent().spellID
                            self2:SetAlpha(spellID and IsSpellKnownOrOverridesKnown(spellID) and 1 or 0.3)
                        end)
                        frame.spellPort:SetScript('OnHide', function(self2)
                            self2:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
                        end)
                        frame.spellPort:RegisterEvent('SPELL_UPDATE_COOLDOWN')
                        frame.spellPort:SetScript('OnShow', function(self2)
                            self2:RegisterEvent('SPELL_UPDATE_COOLDOWN')
                            WoWTools_CooldownMixin:SetFrame(self2, {spell=self2:GetParent().spellID})
                        end)
                        frame.spellPort:SetScript('OnEvent', function(self2)
                            WoWTools_CooldownMixin:SetFrame(self2, {spell=self2:GetParent().spellID})
                        end)
                    end
                end
            end
            if frame.spellPort and frame.spellPort:CanChangeAttribute() then
                if frame.spellID and IsSpellKnownOrOverridesKnown(frame.spellID) then
                    local name= C_Spell.GetSpellName(frame.spellID)
                    frame.spellPort:SetAttribute("type", "spell")
                    frame.spellPort:SetAttribute("spell", name or frame.spellID)
                    frame.spellPort:SetAlpha(1)
                else
                    frame.spellPort:SetAlpha(0.3)
                end
                frame.spellPort:SetShown(not Save().hidePort)
                frame.spellPort:SetScale(Save().portScale or 1)
            end]]
        end
    end

    --[[if ChallengesFrame.WeeklyInfo.Child.WeeklyChest and ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus and ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:GetText()==MYTHIC_PLUS_COMPLETE_MYTHIC_DUNGEONS then
        ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:SetText('')--隐藏，完成史诗钥石地下城即可获得
        ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:Hide()
    end
    if ChallengesFrame and ChallengesFrame.WeeklyInfo and ChallengesFrame.WeeklyInfo.Child and ChallengesFrame.WeeklyInfo.Child.Description then
        ChallengesFrame.WeeklyInfo.Child.Description:SetText('')
        ChallengesFrame.WeeklyInfo.Child.Description:Hide()
    end]]
end





































--####
--初始
--####
local function Init()
    Frame= CreateFrame("Frame", 'WoWToolsChallengesUITipsFrame', ChallengesFrame)
    Frame:SetFrameStrata('HIGH')
    Frame:SetFrameLevel(7)
    Frame:SetPoint('CENTER')
    Frame:SetSize(1, 1)


    function Frame:Settings()
        self:SetShown(not Save().hideTips)
        self:SetScale(Save().tipsScale or 1)
    end


    --Init_Affix()


    

    

    hooksecurefunc(ChallengesFrame, 'Update', Set_Update)




    if ChallengesFrame.WeeklyInfo and ChallengesFrame.WeeklyInfo.Child then--隐藏, 赛季最佳
        if ChallengesFrame.WeeklyInfo.Child.SeasonBest then
            ChallengesFrame.WeeklyInfo.Child.SeasonBest:SetText('')
        end
   end

    if ChallengesFrame.WeeklyInfo and ChallengesFrame.WeeklyInfo.Child then
        if ChallengesFrame.WeeklyInfo.Child.Description and ChallengesFrame.WeeklyInfo.Child.Description:IsVisible() then
            local text= ChallengesFrame.WeeklyInfo.Child.Description:GetText()
            if text==MYTHIC_PLUS_MISSING_KEYSTONE_MESSAGE then
                ChallengesFrame.WeeklyInfo.Child.Description:SetText()
                print(WoWTools_DataMixin.Icon.icon2.. WoWTools_ChallengeMixin.addName)
                print('|cffff00ff',text)
            end
        end
    end

    if C_AddOns.IsAddOnLoaded("AngryKeystones") then
        ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:ClearAllPoints()
        ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:SetPoint('BOTTOM', ChallengesFrame.WeeklyInfo.Child.WeeklyChest, 0, -55)
    end



    Init=function()
        Set_Update()
        Frame:Settings()
    end
end









function WoWTools_ChallengeMixin:ChallengesUI_Info()
    Init()
end


