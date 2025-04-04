local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end
local Frame



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
    --if to>0 then
        return (nu==0 and '|cff828282' or '|cff00ff00')..nu..(nu==0 and '/' or '|r/')..to, nu, to
    --end
end









local function Set_OnEnter(self)
    local intimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(self.mapID)
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

    local timeLimit, texture, backgroundTexture = select(3, C_ChallengeMode.GetMapUIInfo(self.mapID))

    local a=GetNum(self.mapID, true)--所有
        or ('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '无' or NONE)..'|r')

    local w=GetNum(self.mapID)--本周
        or ('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '无' or NONE)..'|r')

    GameTooltip:AddDoubleLine(
        (WoWTools_DataMixin.onlyChinese and '历史' or HISTORY)..': '..a,
        (WoWTools_DataMixin.onlyChinese and '本周' or CHALLENGE_MODE_THIS_WEEK)..': '..w
    )
    GameTooltip:AddLine(' ')

    GameTooltip:AddDoubleLine(
        'mapChallengeModeID |cnGREEN_FONT_COLOR:'.. self.mapID..'|r',
        timeLimit and (WoWTools_DataMixin.onlyChinese and '限时' or GROUP_FINDER_PVE_PLAYSTYLE3)
        ..' '
        .. SecondsToTime(timeLimit)
    )

    if texture and backgroundTexture then
        GameTooltip:AddDoubleLine(
            '|T'..texture..':0|t'..texture,
            '|T'..backgroundTexture..':0|t'..backgroundTexture
        )
    end

    if self.journalInstanceID then

        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(
            
            (InCombatLockdown() and '|cff828282' or '|cnGREEN_FONT_COLOR:')
            ..'<'
            ..WoWTools_DataMixin.Icon.left
            ..(WoWTools_DataMixin.onlyChinese and '冒险指南' or ADVENTURE_JOURNAL)
            ..'>'
        )
    end

    GameTooltip:Show()
end















local function Create_Label(frame)

--副本 完成/总次数 (全部)
    frame.completedLable=WoWTools_LabelMixin:Create(Frame, {mouse=true})
    frame.completedLable:SetPoint('TOPLEFT', frame)
    frame.completedLable:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
    frame.completedLable:SetScript('OnEnter', function(self)
        if self.all or self.week then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddDoubleLine(
                WoWTools_DataMixin.onlyChinese and '历史 |cnGREEN_FONT_COLOR:完成|r/总计' or (HISTORY..' |cnGREEN_FONT_COLOR:'..COMPLETE..'|r/'..TOTAL) ,
                self.all or (WoWTools_DataMixin.onlyChinese and '无' or NONE)
            )
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '本周' or CHALLENGE_MODE_THIS_WEEK, self.week and '('..self.week..')' or (WoWTools_DataMixin.onlyChinese and '无' or NONE))
            if self.completed and self.totale and self.completed < self.totale then
                GameTooltip:AddLine(' ')
                GameTooltip:AddDoubleLine(self.totale..' - |cnGREEN_FONT_COLOR:'..self.completed..'|r =', '|cnRED_FONT_COLOR:'..format(WoWTools_DataMixin.onlyChinese and '%s (超时)' or DUNGEON_SCORE_OVERTIME_TIME, self.totale-self.completed))
            end
            GameTooltip:Show()
            self:SetAlpha(0.3)
        end
    end)








--分数，最佳

    frame.scoreLable=WoWTools_LabelMixin:Create(Frame, {size=10, mouse=true})
    frame.scoreLable:SetPoint('BOTTOMLEFT', frame, 0, 24)
    frame.scoreLable:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
    frame.scoreLable:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(format(WoWTools_DataMixin.onlyChinese and '史诗钥石评分：%s' or CHALLENGE_COMPLETE_DUNGEON_SCORE, self.score))
            GameTooltip:Show()
            self:SetAlpha(0.3)
    end)






--移动层数位置
    if frame.HighestLevel then
        frame.HighestLevel:ClearAllPoints()
        frame.HighestLevel:SetPoint('LEFT', 0, 12)
        frame.HighestLevel:EnableMouse(true)
        frame.HighestLevel:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
        frame.HighestLevel:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(format(WoWTools_DataMixin.onlyChinese and '最佳%s' or DUNGEON_SCORE_BEST_AFFIX, (WoWTools_DataMixin.onlyChinese and '等级' or LEVEL)..': '..self:GetText()))
            GameTooltip:Show()
            self:SetAlpha(0.5)
        end)
    end








--提示, 包里KEY地图
    frame.currentKey= Frame:CreateTexture(nil, 'OVERLAY')

    frame.currentKey:SetPoint('RIGHT', frame, 0, 8)
    frame.currentKey:SetAtlas('common-icon-checkmark')
    frame.currentKey:SetSize(22,22)
    frame.currentKey:EnableMouse(true)
    frame.currentKey:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
        self.label:SetAlpha(1)
    end)

    frame.currentKey:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        local bagID, slotID= select(2, WoWTools_BagMixin:Ceca(nil, {isKeystone=true}))--查找，包的key
        if bagID and slotID then
            GameTooltip:SetBagItem(bagID, slotID)
        end
        GameTooltip:Show()
        self:SetAlpha(0.3)
        self.label:SetAlpha(0.3)
    end)

--当前KEY，等级
    frame.currentKey.label= WoWTools_LabelMixin:Create(Frame)
    frame.currentKey.label:SetPoint('TOP', frame.currentKey, -2, 2)



--名称, 缩写
    frame.nameLable=WoWTools_LabelMixin:Create(Frame, {size=10, mouse= true, justifyH='CENTER'})
    frame.nameLable:SetPoint('BOTTOM', frame, 'TOP', 0, 3)
    frame.nameLable:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)
    frame.nameLable:SetScript('OnEnter', function(self)
        if self.name then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(self.name)
            GameTooltip:Show()
        end
        self:SetAlpha(0.5)
    end)






--提示
    frame:EnableMouse(true)
    frame:HookScript('OnEnter', function(self)
        if Save().hideIns then
            return
        end
        Set_OnEnter(self)
    end)
    frame:SetScript('OnMouseDown', function(self)
        if self.journalInstanceID and not InCombatLockdown() then
            WoWTools_LoadUIMixin:JournalInstance(self.journalInstanceID)
        end
    end)
end



















local function Create_Affix_Label(frame, name, nameA)

    local label= WoWTools_LabelMixin:Create(Frame, {justifyH='RIGHT', mouse=true})

    if name== nameA then
        label:SetPoint('BOTTOMLEFT', frame)
    else
        label:SetPoint('BOTTOMLEFT', frame, 0, 12)
    end

    label:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)

    label:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(
            format(
                WoWTools_DataMixin.onlyChinese and '最佳%s' or DUNGEON_SCORE_BEST_AFFIX,
                self.name
            ),

            self.overTime and
            '|cff828282'
            ..format(
                WoWTools_DataMixin.onlyChinese and '%s (超时)' or DUNGEON_SCORE_OVERTIME_TIME,
                    WoWTools_TimeMixin:SecondsToClock(self.durationSec)
                )
            or
                WoWTools_TimeMixin:SecondsToClock(self.durationSec)
        )
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)

    frame['affixInfo'..name] = label

    return label
end





















local function Set_Update()--Blizzard_ChallengesUI.lua
    local self= ChallengesFrame
    if not self.maps or #self.maps==0 or not Frame:IsShown() then
        return
    end


    local currentChallengeMapID= C_MythicPlus.GetOwnedKeystoneChallengeMapID()--当前, KEY地图,ID
    local keyStoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()--当前KEY，等级



    for i=1, #self.maps do
        local frame = self.DungeonIcons[i]
        local insTab= frame and WoWTools_DataMixin.ChallengesSpellTabs[frame.mapID]

        if insTab then

            frame.spellID= insTab.spell
            frame.journalInstanceID= insTab.ins

            if not frame.currentKey then
                Create_Label(frame)

            end

--名称, 缩写
            local nameText = C_ChallengeMode.GetMapUIInfo(frame.mapID)--名称
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
            frame.nameLable.name= nameText
            frame.nameLable:SetText(nameText or '0')



--分数，最佳
           -- local intimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(frame.mapID)
            local affixScores, overAllScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(frame.mapID)
            affixScores= affixScores or {}
            overAllScore= overAllScore or 0
            frame.scoreLable.score= overAllScore
            frame.scoreLable:SetText(
                
                    '|A:AdventureMapIcon-MissionCombat:16:16|a'
                    ..(overAllScore==0 and '|cff8282820'
                        or WoWTools_ChallengeMixin:KeystoneScorsoColor(overAllScore,nil,true)
                    )
                
            )

            local nameA, _, filedataidA = C_ChallengeMode.GetAffixInfo(10)
            local nameB, _, filedataidB = C_ChallengeMode.GetAffixInfo(9)
            local text, label, level, icon
            for _, info in ipairs(affixScores) do
                if info.name == nameA or info.name==nameB then

                    label= frame['affixInfo'..info.name] or Create_Affix_Label(frame, info.name, nameA)

                    level= info.overTime and '|cff828282'..info.level..'|r' or info.level
                    icon='|T'..(info.name == nameA and filedataidA or filedataidB)..':0|t'
                    text= icon..level

                    label.overTime= info.overTime
                    label.durationSec= info.durationSec
                    label.name= icon..info.name..': '..level

                    label:SetText(text or '0')
                end
            end

--副本 完成/总次数 (全部)
            local numText
            local all, completed, totale= GetNum(frame.mapID, true)
            local week= GetNum(frame.mapID)--本周

            numText= (all or '')..((week and week~=all) and ' |cffffffff(|r'..week..'|cffffffff)|r' or '')

            frame.completedLable.all=all or week
            frame.completedLable.week= week
            frame.completedLable.completed= completed
            frame.completedLable.totale= totale
            frame.completedLable:SetText(numText or '0')

--提示, 包里KEY地图
            local findKey= currentChallengeMapID== frame.mapID

            frame.currentKey:SetShown(findKey)
            frame.currentKey.label:SetShown(findKey)
            frame.currentKey.label:SetText(keyStoneLevel or '0')
        end
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


































--####
--初始
--####
local function Init()
    if Save().hideIns then
        return
    end

    Frame= CreateFrame('Frame', nil, ChallengesFrame)
    Frame:SetFrameStrata('HIGH')
    Frame:SetFrameLevel(10)
    Frame:SetSize(1,1)
    Frame:SetPoint('TOPLEFT')

    function Frame:Settings()
        local show= not Save().hideIns

        self:SetScale(Save().insScale or 1)

        if show then
            Set_Update()
        end

        self:SetShown(show)
     end

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
                print(
                    WoWTools_DataMixin.Icon.icon2
                    ..WoWTools_ChallengeMixin.addName
                )
                print('|cffff00ff',text)
            end
        end
    end

    if C_AddOns.IsAddOnLoaded("AngryKeystones") then
        ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:ClearAllPoints()
        ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:SetPoint('BOTTOM', ChallengesFrame.WeeklyInfo.Child.WeeklyChest, 0, -55)
    end

    Frame:Settings()

    Init=function()
        Frame:Settings()
    end
end









function WoWTools_ChallengeMixin:ChallengesUI_Info()
    Init()
end


