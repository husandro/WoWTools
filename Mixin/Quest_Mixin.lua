--[[
GetRewardInfo(questID)
GetName(questID)
GetID()
GetLink(questID)
GetRewardInfo(questID)
]]
local e= select(2, ...)
WoWTools_QuestMixin={}

function WoWTools_QuestMixin:GetID()
   return QuestInfoFrame.questLog and C_QuestLog.GetSelectedQuest() or GetQuestID()
end

function WoWTools_QuestMixin:GetName(questID)
    if questID then
        return e.cn(nil, {questID=questID, isName=true})
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
        e.LoadDate({id=questID, type='quest'})
        local index= C_QuestLog.GetLogIndexForQuestID(questID)
        local info= index and C_QuestLog.GetInfo(index) or {}
        local name= e.cn(info.title or questID, {questID=questID, isName=true})
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
    if data then return data end

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
            e.LoadDate({id=spellID, type='spell'})
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