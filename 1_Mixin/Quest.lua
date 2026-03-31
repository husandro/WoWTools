--[[
ToggleQuestLog()
OpenQuestLog(mapID)
QuestUtils_GetQuestName(questID) return C_TaskQuest.GetQuestInfoByQuestID(questID) or C_QuestLog.GetTitleForQuestID(questID) or "";
QuestUtil.OpenQuestDetails(questID)--显示任务细节
QuestUtil.GetQuestIconOffer


QuestEventListener:AddCancelableCallback(questID, 
QuestUtil.
GetRewardInfo(questID)
GetName(questID)
GetID()
GetLink(questID)
GetRewardInfo(questID)
GetQuestAll()--所有，任务，提示
]]

WoWTools_QuestMixin={}

function WoWTools_QuestMixin:IsValidQuestID(questID)
    if questID then
        questID = type(questID)~='number' and tonumber(questID) or questID or 0
        if questID>0 and questID<2e9 then
            return questID
        end
    end
end

function WoWTools_QuestMixin:GetID()
   local questID = QuestInfoFrame.questLog and C_QuestLog.GetSelectedQuest() or GetQuestID()
   return self:IsValidQuestID(questID)
end

--注意，返回都是字符
function WoWTools_QuestMixin:GetName(questID)
    questID= self:IsValidQuestID(questID)
    if not questID then
        return ''
    end

    WoWTools_DataMixin:Load(questID, 'quest')

    local name =WoWTools_TextMixin:CN(nil, {questID=questID, isName=true})
                or C_TaskQuest.GetQuestInfoByQuestID(questID)
                or C_QuestLog.GetTitleForQuestID(questID)
                or tostring(questID)

    local atlas, color= WoWTools_QuestMixin:GetAtlasColor(questID)
    if atlas then
        name= atlas..name
    end
    if color then
        name= color:WrapTextInColorCode(name)
    end

    return name
end

function WoWTools_QuestMixin:GetLink(questID)
    questID= self:IsValidQuestID(questID)
    if not questID then
        return
    end

    WoWTools_DataMixin:Load(questID, 'quest')

    local link= GetQuestLink(questID)
    if not link then
        local index= C_QuestLog.GetLogIndexForQuestID(questID)
        local info= index and C_QuestLog.GetInfo(index) or {}
        local name= info.title or self:GetName(questID)
        link= '|cffffff00|Hquest:'..questID..':'..(info.level or -1)..':::|h['..name..']|h|r'
    end

    return link
end
















--QuestUtils_AddQuestRewardsToTooltip(tooltip, questID, style)
function WoWTools_QuestMixin:GetRewardInfo(questID)
    questID= self:IsValidQuestID(questID)
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
           WoWTools_DataMixin:Load(spellID, 'spell')
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
    else
        local money= GetQuestLogRewardMoney(questID)
        if money>0 then
            return {
                texture='Interface\\Icons\\inv_misc_coin_01',--'interface\\moneyframe\\ui-goldicon'
                name= WoWTools_DataMixin:MK(money/1e4, 0),
            }
        end
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
    local dayColor= self:GetColor('Daily')
    local legendaryColor= self:GetColor('Legendary')
    local weekColor= self:GetColor('Weekly')

    GameTooltip:AddDoubleLine(
        (WoWTools_DataMixin.onlyChinese and '已完成' or  CRITERIA_COMPLETED)
        ..' '..WoWTools_DataMixin:MK(#all, 3),
        self:GetColor('Daily'):GenerateHexColorMarkup()..(WoWTools_DataMixin.onlyChinese and '日常' or DAILY)
        ..': '..GetDailyQuestsCompleted()
        ..format('|A:%s:0:0|a', 'common-icon-checkmark'),
        nil, nil, nil, dayColor:GetRGB()
    )
    GameTooltip:AddLine(
        (WoWTools_DataMixin.onlyChinese and '上限' or CAPPED)..': '..(numQuest+ dayNum+ weekNum)..'/'..(C_QuestLog.GetMaxNumQuestsCanAccept() or 38)
    )
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine(
        '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '当前地图' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REFORGE_CURRENT, WORLD_MAP))..': '..inMapNum)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine((WoWTools_DataMixin.onlyChinese and '日常' or DAILY)..': '..dayNum, dayColor:GetRGB())
    GameTooltip:AddLine((WoWTools_DataMixin.onlyChinese and '周长' or WEEKLY)..': '..weekNum, weekColor:GetRGB())
    GameTooltip:AddLine((num>=MAX_QUESTS and '|cnWARNING_FONT_COLOR:' or '|cffffffff')..(WoWTools_DataMixin.onlyChinese and '一般' or RESISTANCE_FAIR)..': '..numQuest..'/'..MAX_QUESTS)
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine((WoWTools_DataMixin.onlyChinese and '传说' or GARRISON_FOLLOWER_QUALITY6_DESC)..': '..legendaryNum, legendaryColor:GetRGB())
    GameTooltip:AddLine((WoWTools_DataMixin.onlyChinese and '战役' or TRACKER_HEADER_CAMPAIGN_QUESTS)..': '..campaignNum, legendaryColor:GetRGB())
    GameTooltip:AddLine((WoWTools_DataMixin.onlyChinese and '悬赏' or PVP_BOUNTY_REWARD_TITLE)..': '..bountyNum, legendaryColor:GetRGB())
    GameTooltip:AddLine((WoWTools_DataMixin.onlyChinese and '故事' or 'Story')..': '..storyNum, legendaryColor:GetRGB())
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
    Important=     CreateColor(1, 0, 1),-- {r=1, g=0, b=1, hex='|cffff00ff'},--重要 C_QuestLog.IsImportantQuest(questID)
    Legendary=     CreateColor(1, 0.49, 0),--{r=1, g=0.49, b=0, hex='|cffff7d00'},--传说,
    Campaign=      CreateColor(1, 0.82, 0),--{r=1, g=0.82, b=0, hex='|cffffd100'},--战役 C_CampaignInfo.IsCampaignQuest(questID)
	Calling=       CreateColor(0.53, 0.53, 0.93),--{r=0.53, g=0.53, b=0.93, hex='|cff8788ee'},--使命 C_QuestLog.IsQuestCalling(questID)
	--Meta=          CreateColor(1, 1, 1),--{r=1,g=1,b=1, hex='|cffffffff'},--综合 C_QuestLog.IsMetaQuest(questID) 

	Recurring=     CreateColor(0.06, 0.38, 0.81),--{r=0.06, g=0.38, b=0.81, hex='|cff1062cf'},--可重复 C_QuestLog.IsRepeatableQuest(questID)
	Questline=     CreateColor(0.67, 0.83, 0.45),--{r=0.67, g=0.83, b=0.45, hex='|cffaad372'},--故事线 IsStoryQuest(questID)
	--Normal=        CreateColor(1, 1, 1),--{r=1,g=1,b=1, hex='|cffffffff'},--普通
	BonusObjective=CreateColor(0.09, 0.78, 0.39),--{r=0.09, g=0.78, b=0.39, a=1.00, hex='|cff17c864'},--C_QuestLog.IsQuestBounty(questID) 
	Threat=        CreateColor(1, 0.28, 0),--{r=1.00, g=0.28, b=0.00, a=1.00, hex='|cffff4800'},--威胁 C_QuestLog.IsThreatQuest(questID)
	WorldQuest=    CreateColor(0.9, 0.8, 0.5),--{r=0.9, g=0.8, b=0.5, hex='|cffe6cc80'},--世界任务 C_QuestLog.IsWorldQuest(questID)

    Trivial=       CreateColor(0.53, 0.53, 0.53),--{r=0.53, g=0.53, b=0.53, hex='|cff878787'},--0 难度 Difficulty C_QuestLog.IsQuestTrivial(questID)
    Easy=          CreateColor(0.63, 1, 0.61),--{r=0.63, g=1, b=0.61, hex='|cffa1ff9c'},--1
    Difficult=     CreateColor(1, 0.43, 0.42),--{r=1, g=0.43, b=0.42, hex='|cffff6e6b'},--3
    Impossible=    CreateColor(1, 0, 1),--{r=1, g=0, b=1, hex='|cffff00ff'},--4

    Story=         CreateColor(0.09, 0.78, 0.39),--{r=0.09, g=0.78, b=0.39, a=1.00, hex='|cff17c864'},
    Complete=      CreateColor(0.1, 1, 0.1),--{r=0.10, g=1.00, b=0.10, a=1.00, hex='|cff19ff19'},
    Failed=        CreateColor(1, 0, 0),--{r=1.00, g=0.00, b=0.00, a=1.00, hex='|cffff0000'},
    Horde=         CreateColor(1, 0.38, 0.38),--{r=1.00, g=0.38, b=0.38, a=1.00, hex='|cffff6161'},
    Alliance=      CreateColor(0, 0.68, 0.94),--{r=0.00, g=0.68, b=0.94, a=1.00, hex='|cff00adf0'},
    WoW=           CreateColor(0, 0.8, 1),--{r=0.00, g=0.80, b=1.00, a=1.00, hex='|cff00ccff'},
    PvP=           CreateColor(0.8, 0.3, 0.22),--{r=0.80, g=0.30, b=0.22, a=1.00, hex='|cffcc4d38'},

    --Default=       CreateColor(1, 1, 1),--{r=1,g=1,b=1, hex='|cffffffff'},
    Daily=         CreateColor(0.06, 0.38, 0.81),--{r=0.06, g=0.38, b=0.81, hex='|cff1062cf'},--日常
    Weekly=        CreateColor(0.02, 1, 0.66),--{r=0.02, g=1, b=0.66, hex='|cff05ffa8'},--周长
    ResetByScheduler= CreateColor(0, 0.8, 1),--{r=0.00, g=0.80, b=1.00, a=1.00, hex='|cff00ccff'},--游戏活动
}




function WoWTools_QuestMixin:GetColor(text, questID)
    local color
    if text then
        color= QustColorTab[text]

    elseif questID then --and UnitEffectiveLevel('player')== WoWTools_DataMixin.Player.Level then
        local difficulty= C_PlayerInfo.GetContentDifficultyQuestForPlayer(questID)
        if difficulty then
            if difficulty== 0 then--Trivial    
                color= QustColorTab.Trivial
            elseif difficulty== 1 then--Easy
                color= QustColorTab.Easy
            elseif difficulty==3 then--Difficult    
                color= QustColorTab.Difficult
            elseif difficulty==4 then--Impossible    
                color= QustColorTab.Impossible
            end
        end
    end
    return  color or HIGHLIGHT_FONT_COLOR
end







--任务图标，颜色
function WoWTools_QuestMixin:GetAtlasColor(questID, info, tagInfo, isComplete)--QuestMapFrame.lua QuestUtils.lua
    questID= self:IsValidQuestID(questID) or (info and info.questID)

    if not questID then
        return
    end

    local questLogIndex= C_QuestLog.GetLogIndexForQuestID(questID)
    info = info or (questLogIndex and C_QuestLog.GetInfo(questLogIndex))

    if not info then
        return
    end

    tagInfo=  tagInfo or C_QuestLog.GetQuestTagInfo(questID) or {}

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

    if (tagInfo.tagID==41 or tagInfo.tagID==113 or tagInfo.tagID==140 or tagInfo.tagID==255 or tagInfo.tagID==256 or tagInfo.tagID==278) and not color then
        color=self:GetColor('PvP')
        atlas= atlas or '|A:pvptalents-warmode-swords:0:0|a'
    end

    if not atlas then
        local icon
        if tagID then
            icon=  QuestUtils_GetQuestTagAtlas(tagID, tagInfo.worldQuestType)
        elseif questLogIndex then
    	    local _, frequency, isRepeatable, isLegendary, _, isImportant, isMeta = GetAvailableQuestInfo(questLogIndex)
            icon= QuestUtil.GetQuestIconOffer(isLegendary, frequency, isRepeatable, C_CampaignInfo.IsCampaignQuest(questID), C_QuestLog.IsQuestCalling(questID), isImportant, isMeta)
        end
        if icon then
            atlas= select(3, WoWTools_TextureMixin:IsAtlas(icon))
        end
    end

    return atlas, color
end




