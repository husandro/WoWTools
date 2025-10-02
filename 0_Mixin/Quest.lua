--[[
GetRewardInfo(questID)
GetName(questID)
GetID()
GetLink(questID)
GetRewardInfo(questID)
GetQuestAll()--所有，任务，提示
]]

WoWTools_QuestMixin={}

function WoWTools_QuestMixin:GetID()
   return QuestInfoFrame.questLog and C_QuestLog.GetSelectedQuest() or GetQuestID()
end

function WoWTools_QuestMixin:GetName(questID)
    if questID then
        return WoWTools_TextMixin:CN(nil, {questID=questID, isName=true})
            or C_TaskQuest.GetQuestInfoByQuestID(questID)
            or C_QuestLog.GetTitleForQuestID(questID)
            or questID
    end
end

function WoWTools_QuestMixin:GetLink(questID)
    if not questID then
        return
    end
    local link= GetQuestLink(questID)
    if not link then
        WoWTools_DataMixin:Load({id=questID, type='quest'})
        local index= C_QuestLog.GetLogIndexForQuestID(questID)
        local info= index and C_QuestLog.GetInfo(index) or {}
        local name= WoWTools_TextMixin:CN(info.title or questID, {questID=questID, isName=true})
        link= '|cffffff00|Hquest:'..questID..':'..(info.level or -1)..':::|h['..(name or questID)..']|h|r'
    end
    return link
end
















--QuestUtils_AddQuestRewardsToTooltip(tooltip, questID, style)
function WoWTools_QuestMixin:GetRewardInfo(questID)
    if not questID then
        return
    end
    if not questID then
        return
    end
    local data, info, bestQuality

--可选任务，奖励
    bestQuality= -1
    for i = 1, GetNumQuestLogChoices(questID) or 0, 1 do
        local itemName, itemTexture, quantity, quality, isUsable, itemID= GetQuestLogChoiceInfo(i, questID)
        if itemID and quantity and quality > bestQuality then
            data= {
                name=itemName,
                itemID=itemID,
                texture=itemTexture,
                quantity=quantity,
                quality=quality,
                isUsable=isUsable,
            }
        end
    end
    if data then
        return data
    end

--物品
    local numRewards= GetNumQuestLogRewards(questID, true) or 0
    if numRewards>0 then
        bestQuality = -1
        for i = 1, numRewards, 1 do
            local itemName, itemTexture, numItems, quality, isUsable, itemID, itemLevel= GetQuestLogRewardInfo(i, questID)
            if itemName and itemID and quality and quality > bestQuality then
                data= {
                    name=itemName,
                    itemID=itemID,
                    texture=itemTexture,
                    quantity=numItems,
                    quality=quality,
                    isUsable=isUsable,
                    itemLevel=itemLevel,
                }
            end
        end
        if data then return data end
    end

--货币
--[[
texture	number : fileID	
name	string	
currencyID	number	
quality	number	
baseRewardAmount	number	
bonusRewardAmount	number	
totalRewardAmount	number	
questRewardContextFlags	Enum.QuestRewardContextFlags?	
]]
    info= C_QuestLog.GetQuestRewardCurrencyInfo(questID, 1, false) or {}
    if info.currencyID then
        return info
    end


--法术
    if C_QuestInfoSystem.HasQuestRewardSpells(questID) then
        local spells= C_QuestInfoSystem.GetQuestRewardSpells(questID)
        for _, spellID in pairs(spells or {}) do
            info = C_QuestInfoSystem.GetQuestRewardSpellInfo(questID, spellID)
            WoWTools_DataMixin:Load({id=spellID, type='spell'})
            if info and info.texture and info.texture>0 then
                data= {
                    texture= info.texture,--fileID
                    name= info.name,--string
                    garrFollowerID= info.garrFollowerID,--number
                    isTradeskill= info.isTradeskill,--boolean
                    isSpellLearned= info.isSpellLearned,--boolean
                    hideSpellLearnText=info.hideSpellLearnText,--boolean
                    isBoostSpell=info.isBoostSpell,--boolean	
                    genericUnlock=info.genericUnlock,--boolean	
                    type=info.type,--Enum.QuestCompleteSpellType	
                    spellID= spellID,
                    spells= spells,
                }
                break
            end
        end
    end
    if data then return data end


--神器XP
    if GetQuestLogRewardArtifactXP(questID) > 0 then
        local artifactCategory= select(2, GetRewardArtifactXP()) or select(2, GetQuestLogRewardArtifactXP())
        if artifactCategory then
            local itemName, itemTexture= C_ArtifactUI.GetArtifactXPRewardTargetInfo(artifactCategory)
            return {
                name=itemName,
                texture= itemTexture,
            }
        end
--荣誉
    elseif GetQuestLogRewardHonor(questID)>0 then
        return {
            texture= 'Interface\\ICONS\\Achievement_LegionPVPTier4',
            --name= HONOR
        }
--XP
    elseif GetQuestLogRewardXP(questID) > 0 then
        return {
            texture='Interface\\Icons\\XP_Icon',
            --name=COMBAT_XP_GAIN,--经验
        }
--钱
    elseif GetQuestLogRewardMoney(questID)>0 then

        return {
            texture='Interface\\Icons\\inv_misc_coin_01',--'interface\\moneyframe\\ui-goldicon'
        }
    end
    return {}
end

--[[
--QuestUtils.lua
QuestUtils_GetQuestName(questID
]]






--所有，任务，提示
function WoWTools_QuestMixin:GetQuestAll()
    local numQuest, dayNum, weekNum, campaignNum, legendaryNum, storyNum, bountyNum, inMapNum = 0, 0, 0, 0, 0, 0, 0,0
    for index=1, C_QuestLog.GetNumQuestLogEntries() do
        local info = C_QuestLog.GetInfo(index)
        if info and not info.isHeader and not info.isHidden then
            if info.frequency== 0 then
                numQuest= numQuest+ 1

            elseif info.frequency==  Enum.QuestFrequency.Daily then--日常
                dayNum= dayNum+ 1

            elseif info.frequency== Enum.QuestFrequency.Weekly then--周常
                weekNum= weekNum+ 1
            end

            if info.campaignID then
                campaignNum= campaignNum+1
            elseif info.isLegendarySort then
                legendaryNum= legendaryNum +1
            elseif info.isStory then
                storyNum= storyNum +1
            elseif info.isBounty then
                bountyNum= bountyNum+ 1
            end
            if info.isOnMap then
                inMapNum= inMapNum +1
            end
        end
    end
    local num= select(2, C_QuestLog.GetNumQuestLogEntries())
    local all=C_QuestLog.GetAllCompletedQuestIDs() or {}--完成次数
    GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '已完成' or  CRITERIA_COMPLETED)..' '..WoWTools_DataMixin:MK(#all, 3), self:GetColor('Daily').hex..(WoWTools_DataMixin.onlyChinese and '日常' or DAILY)..': '..GetDailyQuestsCompleted()..format('|A:%s:0:0|a', 'common-icon-checkmark'))
    GameTooltip:AddLine(WoWTools_DataMixin.Player.col..(WoWTools_DataMixin.onlyChinese and '上限' or CAPPED)..': '..(numQuest+ dayNum+ weekNum)..'/'..(C_QuestLog.GetMaxNumQuestsCanAccept() or 38))
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '当前地图' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REFORGE_CURRENT, WORLD_MAP))..': '..inMapNum)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine(self:GetColor('Daily').hex..(WoWTools_DataMixin.onlyChinese and '日常' or DAILY)..': '..dayNum)
    GameTooltip:AddLine(self:GetColor('Weekly').hex..(WoWTools_DataMixin.onlyChinese and '周长' or WEEKLY)..': '..weekNum)
    GameTooltip:AddLine((num>=MAX_QUESTS and '|cnWARNING_FONT_COLOR:' or '|cffffffff')..(WoWTools_DataMixin.onlyChinese and '一般' or RESISTANCE_FAIR)..': '..numQuest..'/'..MAX_QUESTS)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine(self:GetColor('Legendary').hex..(WoWTools_DataMixin.onlyChinese and '传说' or GARRISON_FOLLOWER_QUALITY6_DESC)..': '..legendaryNum)
    GameTooltip:AddLine(self:GetColor('Legendary').hex..(WoWTools_DataMixin.onlyChinese and '战役' or TRACKER_HEADER_CAMPAIGN_QUESTS)..': '..campaignNum)
    GameTooltip:AddLine(self:GetColor('Legendary').hex..(WoWTools_DataMixin.onlyChinese and '悬赏' or PVP_BOUNTY_REWARD_TITLE)..': '..bountyNum)
    GameTooltip:AddLine(self:GetColor('Legendary').hex..(WoWTools_DataMixin.onlyChinese and '故事' or 'Story')..': '..storyNum)
    GameTooltip:AddLine((WoWTools_DataMixin.onlyChinese and '追踪' or TRACK_QUEST_ABBREV)..': '..C_QuestLog.GetNumQuestWatches())
end















--[[
[Enum.StatusBarColorTintValue.Black] = BLACK_FONT_COLOR,
[Enum.StatusBarColorTintValue.White] = WHITE_FONT_COLOR,
[Enum.StatusBarColorTintValue.Red] = RED_FONT_COLOR,
[Enum.StatusBarColorTintValue.Yellow] = YELLOW_FONT_COLOR,
[Enum.StatusBarColorTintValue.Orange] = ORANGE_FONT_COLOR,
[Enum.StatusBarColorTintValue.Purple] = EPIC_PURPLE_COLOR,
[Enum.StatusBarColorTintValue.Green] = GREEN_FONT_COLOR,
[Enum.StatusBarColorTintValue.Blue] = RARE_BLUE_COLOR,
]]
local QustColorTab={
    Important={r=1, g=0, b=1, hex='|cffff00ff'},--重要 C_QuestLog.IsImportantQuest(questID)
    Legendary={r=1, g=0.49, b=0, hex='|cffff7d00'},--传说,
    Campaign={r=1, g=0.82, b=0, hex='|cffffd100'},--战役 C_CampaignInfo.IsCampaignQuest(questID)
	Calling={r=0.53, g=0.53, b=0.93, hex='|cff8788ee'},--使命 C_QuestLog.IsQuestCalling(questID)
	Meta={r=1,g=1,b=1, hex='|cffffffff'},--综合 C_QuestLog.IsMetaQuest(questID) 

	Recurring={r=0.06, g=0.38, b=0.81, hex='|cff1062cf'},--可重复 C_QuestLog.IsRepeatableQuest(questID)
	Questline={r=0.67, g=0.83, b=0.45, hex='|cffaad372'},--故事线 IsStoryQuest(questID)
	Normal={r=1,g=1,b=1, hex='|cffffffff'},--普通
	BonusObjective={r=0.09, g=0.78, b=0.39, a=1.00, hex='|cff17c864'},--C_QuestLog.IsQuestBounty(questID) 
	Threat={r=1.00, g=0.28, b=0.00, a=1.00, hex='|cffff4800'},--威胁 C_QuestLog.IsThreatQuest(questID)
	WorldQuest={r=0.9, g=0.8, b=0.5, hex='|cffe6cc80'},--世界任务 C_QuestLog.IsWorldQuest(questID)
    

    Trivial={r=0.53, g=0.53, b=0.53, hex='|cff878787'},--0 难度 Difficulty C_QuestLog.IsQuestTrivial(questID)
    Easy={r=0.63, g=1, b=0.61, hex='|cffa1ff9c'},--1
    Difficult={r=1, g=0.43, b=0.42, hex='|cffff6e6b'},--3
    Impossible={r=1, g=0, b=1, hex='|cffff00ff'},--4


    Story={r=0.09, g=0.78, b=0.39, a=1.00, hex='|cff17c864'},
    Complete={r=0.10, g=1.00, b=0.10, a=1.00, hex='|cff19ff19'},
    Failed={r=1.00, g=0.00, b=0.00, a=1.00, hex='|cffff0000'},
    Horde={r=1.00, g=0.38, b=0.38, a=1.00, hex='|cffff6161'},
    Alliance={r=0.00, g=0.68, b=0.94, a=1.00, hex='|cff00adf0'},
    WoW={r=0.00, g=0.80, b=1.00, a=1.00, hex='|cff00ccff'},
    PvP={r=0.80, g=0.30, b=0.22, a=1.00, hex='|cffcc4d38'},

    Default={r=1,g=1,b=1, hex='|cffffffff'},
    Daily={r=0.06, g=0.38, b=0.81, hex='|cff1062cf'},--日常
    Weekly={r=0.02, g=1, b=0.66, hex='|cff05ffa8'},--周长
    ResetByScheduler= {r=0.00, g=0.80, b=1.00, a=1.00, hex='|cff00ccff'},--游戏活动
}


    

function WoWTools_QuestMixin:GetColor(text, questID)

    if text then
        return QustColorTab[text]

    elseif questID then --and UnitEffectiveLevel('player')== WoWTools_DataMixin.Player.Level then
        
    
    
        local difficulty= C_PlayerInfo.GetContentDifficultyQuestForPlayer(questID)
        if difficulty then
            if difficulty== 0 then--Trivial    
                return QustColorTab.Trivial
            elseif difficulty== 1 then--Easy
                return QustColorTab.Easy
            elseif difficulty==3 then--Difficult    
                return QustColorTab.Difficult
            elseif difficulty==4 then--Impossible    
                return QustColorTab.Impossible
            end
        end
    end
end







--任务图标，颜色
function WoWTools_QuestMixin:GetAtlasColor(questID, info, tagInfo, isComplete)--QuestMapFrame.lua QuestUtils.lua
    questID= questID or (info and info.questID)
    questID= tonumber(questID)
    if not info and questID then
       local questLogIndex= C_QuestLog.GetLogIndexForQuestID(questID)
       info = questLogIndex and C_QuestLog.GetInfo(questLogIndex)
    end

    tagInfo =  tagInfo or C_QuestLog.GetQuestTagInfo(questID) or {}
    if not questID or not info then
        return
    end

    if isComplete==nil then
        isComplete= C_QuestLog.IsComplete(questID)
    end

    local tagID, color, atlas
    if isComplete then
        if tagInfo.tagID == Enum.QuestTag.Legendary then
            tagID, color, atlas= "COMPLETED_LEGENDARY", self:GetColor('Complete'), nil
        else
            tagID, color, atlas=  nil, self:GetColor('Complete'), format('|A:%s:0:0|a', 'common-icon-checkmark')--"COMPLETED", self:GetColor('Complete')
        end
    elseif C_QuestLog.IsFailed(questID) then
        tagID, color, atlas= "FAILED", self:GetColor('Failed'), nil

    elseif tagInfo.tagID==267 or tagInfo.tagName==TRADE_SKILLS then--专业
        tagID, color, atlas= nil, self:GetColor('Weekly'), '|A:Professions-Icon-Quality-Mixed-Small:0:0|a'

    elseif info.isCalling then
        local secondsRemaining = C_TaskQuest.GetQuestTimeLeftSeconds(questID)
        if secondsRemaining then
            if secondsRemaining < 3600 then -- 1 hour
                tagID, color, atlas= "EXPIRING_SOON", self:GetColor('Calling'), nil
            elseif secondsRemaining < 18000 then -- 5 hours
                tagID, color, atlas= "EXPIRING", self:GetColor('Calling'), nil
            end
        end

    elseif tagInfo.tagID == Enum.QuestTag.Account then
        local factionGroup = GetQuestFactionGroup(questID)
        if factionGroup==LE_QUEST_FACTION_HORDE then--部落
            tagID, color, atlas= 'HORDE', self:GetColor('Horde'), nil
        elseif factionGroup==LE_QUEST_FACTION_ALLIANCE then
            tagID, color, atlas= "ALLIANCE", self:GetColor('Alliance'), nil--联盟
        else
            tagID, color, atlas= Enum.QuestTag.Account,self:GetColor('WoW'), nil--帐户
        end

    elseif info.frequency == Enum.QuestFrequency.Daily then--日常
        tagID, color, atlas= "DAILY", self:GetColor('Daily'), nil

    elseif info.frequency == Enum.QuestFrequency.Weekly then--周常
        tagID, color, atlas= "WEEKLY", self:GetColor('Weekly'), nil

    else
        tagID, color, atlas= tagInfo.tagID, nil, nil
    end
    if not atlas and tagID then
        local tagAtlas = QuestUtils_GetQuestTagAtlas(tagID)
        if tagAtlas then
            atlas= '|A:'..tagAtlas..':0:0|a'
        end
    end
    if tagInfo.tagID==41 and not color then
        color=self:GetColor('PvP')
    end
    return atlas, color
end




