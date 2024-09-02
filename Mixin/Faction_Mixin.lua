local e= select(2, ...)

WoWTools_FactionMinxin={}


function WoWTools_FactionMinxin:GetInfo(factionID, index, toRight)
    local data
    if factionID then
        data= C_Reputation.GetFactionDataByID(factionID)
    elseif index then
        data= C_Reputation.GetFactionDataByIndex(index)
    end

    if not data or not data.name then
        return {}
    end

    factionID= factionID or data.factionID

    local name= data.name
    local isHeader= data.isHeader
    local isHeaderWithRep= data.isHeaderWithRep
    local standingID= data.reaction
    local barMin= data.currentReactionThreshold
    local barValue= data.currentStanding
    local barMax= data.nextReactionThreshold


    local factionStandingtext, value, texture, atlas, barColor


    local isCapped= standingID == MAX_REPUTATION_REACTION--8
    local isMajor = C_Reputation.IsMajorFaction(factionID)
    local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)
    local friendshipID--个人声望
    if repInfo and repInfo.friendshipFactionID> 0 then--个人声望
        local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID) or {}
        factionStandingtext = e.cn(repInfo.reaction)

        if rankInfo.currentLevel and rankInfo.maxLevel and rankInfo.maxLevel>0 then
            factionStandingtext= (factionStandingtext and factionStandingtext..' ' or '')..rankInfo.currentLevel..'/'..rankInfo.maxLevel
        end
        if repInfo.nextThreshold then
            if rankInfo.maxLevel>0  and rankInfo.currentLevel~=rankInfo.maxLevel then
                barColor= FACTION_BAR_COLORS[standingID]
            end
            value= format('%i%%', repInfo.standing/repInfo.nextThreshold*100)
            isCapped= false
            friendshipID= repInfo.friendshipFactionID
        else
            value= '|cff9e9e9e'..(e.onlyChinese and '已满' or VIDEO_OPTIONS_ULTRA_HIGH)..'|r'
            isCapped=true
        end
        texture=repInfo.texture--图标

    elseif isMajor then--名望
        isCapped=C_MajorFactions.HasMaximumRenown(factionID)
        local info = C_MajorFactions.GetMajorFactionData(factionID) or {}
        if info.renownLevel then
            factionStandingtext= (e.onlyChinese and '名望' or RENOWN_LEVEL_LABEL)..' '..info.renownLevel
            local levels = C_MajorFactions.GetRenownLevels(factionID)
            if levels then
                factionStandingtext= factionStandingtext..'/'..#levels
            end
        end
        if not isCapped then
            value= format('%i%%', info.renownReputationEarned/info.renownLevelThreshold*100)
            barColor= GREEN_FONT_COLOR
        else
            value= '|cff9e9e9e'..(e.onlyChinese and '最高' or VIDEO_OPTIONS_ULTRA_HIGH)..'|r'
        end
        atlas=info.textureKit and 'MajorFactions_Icons_'..info.textureKit..'512'
    else
        if isHeaderWithRep or not isHeader then
            factionStandingtext = e.cn(GetText("FACTION_STANDING_LABEL"..standingID, e.Player.sex))
            if barValue and barMax and barMin then
                if barMax==0 then
                    value= format('%i%%', (barMin-barValue)/barMin*100)
                else
                    value= format('%i%%', barValue/barMax*100)
                end
                if toRight then--向右平移 
                    factionStandingtext= factionStandingtext..' '..standingID..'/'..MAX_REPUTATION_REACTION
                else
                    factionStandingtext= standingID..'/'..MAX_REPUTATION_REACTION..' '..factionStandingtext
                end
            end
            if not isCapped then
                factionStandingtext = e.cn(GetText("FACTION_STANDING_LABEL"..standingID, e.Player.sex))
                if barValue and barMax and barMin then
                    if barMax==0 then
                        value= format('%i%%', (barMin-barValue)/barMin*100)
                    else
                        value= format('%i%%', barValue/barMax*100)
                    end
                    if toRight then--向右平移 
                        factionStandingtext= factionStandingtext..' '..standingID..'/'..MAX_REPUTATION_REACTION
                    else
                        factionStandingtext= standingID..'/'..MAX_REPUTATION_REACTION..' '..factionStandingtext
                    end
                    barColor= FACTION_BAR_COLORS[standingID]
                end
            else
                value= '|cff9e9e9e'..(e.onlyChinese and '最高' or VIDEO_OPTIONS_ULTRA_HIGH)..'|r'
            end
        end
    end

    local isParagon = C_Reputation.IsFactionParagon(factionID)--奖励
    local hasRewardPending
    if isParagon then--奖励
        local currentValue, threshold, _, hasRewardPending2, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID);
        hasRewardPending= hasRewardPending2 and format('|A:GarrMission-%sChest:0:0|a', e.Player.faction) or nil
        if not tooLowLevelForParagon and currentValue and threshold then
            local completed= math.modf(currentValue/threshold)--完成次数
            currentValue= completed>0 and currentValue - threshold * completed or currentValue
            if toRight then--向右平移 
                value= '('..completed..') '..format('%i%%', currentValue/threshold*100)
            else
                value= format('%i%%', currentValue/threshold*100)..' ('..completed..')'
            end
        end
    end

    return {
        name= name,
        factionID= factionID,
        description= data.description,
        color= barColor,

        isMajor=isMajor,
        isParagon= isParagon,
        friendshipID= friendshipID,

        texture= texture,
        atlas= atlas,

        factionStandingtext= factionStandingtext,
        valueText= value,

        hasRewardPending=hasRewardPending,

        isCapped= isCapped,
        isHeader= isHeader,
        isHeaderWithRep= isHeaderWithRep,

        hasRep= data.hasBonusRepGain,--额外，声望
    }
end