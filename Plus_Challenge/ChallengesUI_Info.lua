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
        return '|cff00ff00'..nu..'|r/'..to, nu, to
    --end
end





 --提示, 包里KEY地图
local function Set_CurrentKey(frame)
    if frame.currentKey then
        return
    end

    frame.currentKey= Frame:CreateTexture(nil, 'OVERLAY', nil, Frame:GetFrameLevel())

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
        GameTooltip:SetOwner(self:GetParent(), "ANCHOR_RIGHT")
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
            
--提示, 包里KEY地图
            Set_CurrentKey(frame)

            local findKey= currentChallengeMapID== frame.mapID
            frame.currentKey:SetShown(findKey)
            frame.currentKey.label:SetShown(findKey)
            frame.currentKey.label:SetText(keyStoneLevel or '')
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
    Frame:SetFrameLevel(PVEFrame.TitleContainer:GetFrameLevel()+1)
    Frame:SetSize(1,1)
    Frame:Hide()


    function Frame:Settings()
        local show= not Save().hideIns
        self:SetShown(show)
        self:SetScale(Save().insScale or 1)
        if show then
            Set_Update()
        end
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
        Frame:Settings()
    end
end









function WoWTools_ChallengeMixin:ChallengesUI_Info()
    Init()
end


