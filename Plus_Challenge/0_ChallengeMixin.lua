WoWTools_ChallengeMixin={}











function WoWTools_ChallengeMixin:GetRewardText(type)--得到，周奖励，信息
    local text
    for _, info in pairs(C_WeeklyRewards.GetActivities(type) or {}) do
        if info.level and info.level>=0 and info.type==type then
            text= (text and text..'/' or '')
            ..(info.type==Enum.WeeklyRewardChestThresholdType.Raid
                and WoWTools_MapMixin:GetDifficultyColor(nil, info.level)
                or info.level
            )
        end
    end
    if text=='0/0/0' then
        --text= nil
    end
    return text
end




local function GetActivities()
    local R = {}
    for  _ , info in pairs( C_WeeklyRewards.GetActivities() or {}) do
        if info.type and info.type>0 and info.level then--and info.type>= 1 and info.type<= 3
            local head
            local difficultyText
--史诗地下城 1
            if info.type == Enum.WeeklyRewardChestThresholdType.Activities then
                head= WoWTools_DataMixin.onlyChinese and '史诗地下城' or MYTHIC_DUNGEONS
                difficultyText= string.format(WoWTools_DataMixin.onlyChinese and '史诗 %d' or WEEKLY_REWARDS_MYTHIC, info.level)
--PVP 2
            elseif info.type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
                head= WoWTools_DataMixin.onlyChinese and 'PvP' or PVP
                if WoWTools_DataMixin.onlyChinese then
                    local tab={
                        [0]= "休闲者",
                        [1]= "争斗者 I",
                        [2]= "挑战者 I",
                        [3]= "竞争者 I",
                        [4]= "决斗者",
                        [5]= "精锐",
                        [6]= "争斗者 II",
                        [7]= "挑战者 II",
                        [8]= "竞争者 II",
                    }
                    difficultyText=tab[info.level]
                end
                difficultyText=  difficultyText or PVPUtil.GetTierName(info.level)-- _G["PVP_RANK_"..tierEnum.."_NAME"] PVPUtil.lua
--团队副本 3
            elseif info.type == Enum.WeeklyRewardChestThresholdType.Raid then
                head= WoWTools_DataMixin.onlyChinese and '团队副本' or RAIDS
                difficultyText=  DifficultyUtil.GetDifficultyName(info.level)
--AlsoReceive 4
            elseif info.type== Enum.WeeklyRewardChestThresholdType.AlsoReceive then
                head= WoWTools_DataMixin.onlyChinese and '你还将得到' or WEEKLY_REWARDS_ALSO_RECEIVE
--5 Concession
            elseif info.type== Enum.WeeklyRewardChestThresholdType.Concession then
                head= WoWTools_DataMixin.onlyChinese and '收集' or WEEKLY_REWARDS_GET_CONCESSION

--世界 6
            elseif info.type== Enum.WeeklyRewardChestThresholdType.World then
                head= WoWTools_DataMixin.onlyChinese and '世界' or WORLD

            end
            if head then
                R[head]= R[head] or {}
                R[head][info.index] = {
                    level = info.level,
                    difficulty = difficultyText or (WoWTools_DataMixin.onlyChinese and '休闲者' or PVP_RANK_0_NAME),
                    progress = info.progress,
                    threshold = info.threshold,
                    unlocked = info.progress>=info.threshold,
                    id= info.id,
                    type= info.type,
                    itemDBID= info.rewards and info.rewards.itemDBID or nil,
                }
            end

        end
    end

    return R
end



function WoWTools_ChallengeMixin:ActivitiesTooltip(tooltip)
    if (not WoWTools_DataMixin.Player.IsMaxLevel and not WoWTools_DataMixin.Player.husandro) or PlayerGetTimerunningSeasonID() then--不是，最高等级时，退出
        return
    end

    tooltip= tooltip or GameTooltip
    local find
    for head, tab in pairs(GetActivities()) do
        tooltip:AddLine(format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toRight)..head)
        for index, info in pairs(tab) do
            if info.unlocked then
                local itemLink=  C_WeeklyRewards.GetExampleRewardItemHyperlinks(info.id)
                local texture= itemLink and C_Item.GetItemIconByID(itemLink)
                local itemLevel= itemLink and C_Item.GetDetailedItemLevelInfo(itemLink)
                tooltip:AddLine(
                    '   '..index..') '
                    ..(texture and itemLevel and '|T'..texture..':0|t'..itemLevel or info.difficulty)
                    ..format('|A:%s:0:0|a', 'common-icon-checkmark')..((info.level and info.level>0) and info.level or ''))
            else
                tooltip:AddLine('    |cff828282'..index..') '
                    ..info.difficulty
                    .. ' '..(info.progress>0 and '|cnGREEN_FONT_COLOR:'..info.progress..'|r' or info.progress)
                    .."/"..info.threshold..'|r')
            end
        end
        find=true
    end

    local CONQUEST_SIZE_STRINGS = {'', '2v2', '3v3', '10v10'}--PVP
    for i = 2, 4 do
        local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, lastWeeksBest, hasWon, pvpTier, ranking, roundsSeasonPlayed, roundsSeasonWon, roundsWeeklyPlayed, roundsWeeklyWon = GetPersonalRatedInfo(1)
        local tierInfo = pvpTier and C_PvP.GetPvpTierInfo(pvpTier)
        if tierInfo and rating then
            seasonBest= seasonBest or 0
            seasonPlayed= seasonPlayed or 0
            seasonWon= seasonWon or 0
            local text=''
            if seasonPlayed>0 then
                local best=''
                if seasonBest>0 and seasonBest~=rating then
                    best= '|cff9e9e9e'..seasonBest..'|r '
                end
                text= ' ('..best..'|cnGREEN_FONT_COLOR:'..seasonWon..'|r/'..seasonPlayed..')'
            end
            text= (tierInfo.tierIconID and '|T'..tierInfo.tierIconID..':0|t' or '')..CONQUEST_SIZE_STRINGS[i]..(rating==0 and ' |cff9e9e9e' or ' |cffffffff')..rating..'|r' ..text
            tooltip:AddLine(text)
            find=true
        end
    end

    return find
end














local function Create_Activities_SubLable(frame, head, index, last)
    local label= WoWTools_LabelMixin:Create(frame, {mouse= true})

    label:SetPoint('TOPLEFT', last, 'BOTTOMLEFT')
    label:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
    label:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self,  self.anchor or "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        local link= self:Get_ItemLink()
        if link then
            GameTooltip:SetHyperlink(link)
        else
            GameTooltip:AddDoubleLine(format(WoWTools_DataMixin.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION,WoWTools_DataMixin.onlyChinese and '物品等级' or STAT_AVERAGE_ITEM_LEVEL ),WoWTools_DataMixin.onlyChinese and '无' or NONE)
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine('Activities Type '..self.type, 'id '..self.id)
        end
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)
    function label:Get_ItemLink()
        local link
        if self.itemDBID then
            link= C_WeeklyRewards.GetItemHyperlink(self.itemDBID)
        elseif self.id then
            link= C_WeeklyRewards.GetExampleRewardItemHyperlinks(self.id)
        end
        if link and link~='' then
            WoWTools_Mixin:Load({id=link, type='item'})
            return link
        end
    end
    frame.WeekRewards['rewardChestSub'..head..index]= label

    return label
end


local function Create_Activities_HeaderLable(frame, head, point, last)
    local label= WoWTools_LabelMixin:Create(frame)
    if last then
        label:SetPoint('TOPLEFT', last, 'BOTTOMLEFT',0,-4)
    elseif point then
        label:SetPoint(point[1], point[2] or frame, point[3], point[4], point[5])
    else
        label:SetPoint('TOPLEFT')
    end

    frame.WeekRewards['rewardChestHead'..head]= label

    return label
end




function WoWTools_ChallengeMixin:ActivitiesFrame(frame, settings)--周奖励，提示
    if (not WoWTools_DataMixin.Player.IsMaxLevel and not WoWTools_DataMixin.Player.husandro) or PlayerGetTimerunningSeasonID() then--不是，最高等级时，退出
        return
    end

    settings= settings or {}
    if settings.isClear then

        for _, label in pairs(frame.WeekRewards or {}) do
            label:SetText('')
            label.id= nil
            label.type= nil
            label.itemDBID= nil
            label.anchor= nil
        end

        return
    end

    frame.WeekRewards= frame.WeekRewards or {}

    local R= GetActivities()
    local last
    local point= settings.point
    local anchor= settings.anchor

    for head, tab in pairs(R) do
        local label= frame.WeekRewards['rewardChestHead'..head] or Create_Activities_HeaderLable(frame, head, point, last)
        label:SetText('|A:common-icon-rotateright:0:0|a'..head)
        last= label

        for index, info in pairs(tab) do
            label= frame.WeekRewards['rewardChestSub'..head..index] or Create_Activities_SubLable(frame, head, index, last)

            label.id= info.id
            label.type= info.type
            label.itemDBID= info.itemDBID
            label.anchor= anchor
            last= label

            local text
            local itemLink= label:Get_ItemLink()
            if itemLink then
                local texture= C_Item.GetItemIconByID(itemLink)
                local itemLevel= C_Item.GetDetailedItemLevelInfo(itemLink)
                text= '    '..index..') '..(texture and '|T'..texture..':0|t' or itemLink)
                text= text..((itemLevel and itemLevel>0) and itemLevel or '')..format('|A:%s:0:0|a', 'common-icon-checkmark')..((info.level and info.level>0) and info.level or '')
            else
                if info.unlocked then
                    text='   '..index..') '..info.difficulty..format('|A:%s:0:0|a', 'common-icon-checkmark')..(info.level or '')--.. ' '..(WoWTools_DataMixin.onlyChinese and '完成' or COMPLETE)
                else
                    text='    |cff828282'..index..') '
                        ..info.difficulty
                        .. ' '..(info.progress>0 and '|cnGREEN_FONT_COLOR:'..info.progress..'|r' or info.progress)
                        .."/"..info.threshold..'|r'
                end
            end
            label:SetText(text or '')
        end
    end

    return last
end








function WoWTools_ChallengeMixin:KeystoneScorsoColor(score, texture, overall)--地下城史诗, 分数, 颜色 C_ChallengeMode.GetOverallDungeonScore()
    if not score or score==0 or score=='0' then
        return ''
    else
        score= type(score)~='number' and tonumber(score) or score
        local color= not overall and C_ChallengeMode.GetDungeonScoreRarityColor(score) or C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(score)
        if color  then
            score= color:WrapTextInColorCode(score)
        end
        if texture then
            score= '|T4352494:0|t'..score
        end
        return score, color
    end
end



