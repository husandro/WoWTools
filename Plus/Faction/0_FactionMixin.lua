
WoWTools_FactionMixin={}

local function GetText(string)
    return WoWTools_TextMixin:CN(_G[string..(WoWTools_DataMixin.Player.Sex==3 and '_FEMALE' or '')])
end

local function Get_Data(factionID, index)
    local data
    if factionID then
        data= C_Reputation.GetFactionDataByID(factionID)
    elseif index then
        data= C_Reputation.GetFactionDataByIndex(index)
    end
    return data or {}
end










function WoWTools_FactionMixin:GetInfo(factionID, index, toLeft)
    local toRight= not toLeft

    local data= Get_Data(factionID, index)
    if not data.name then
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


    local factionStandingtext, value, texture, atlas, barColor--, unlockDescription
    local isUnlocked=true
    local unlockDescription

    local isCapped= standingID == MAX_REPUTATION_REACTION--8
    local isMajor = C_Reputation.IsMajorFaction(factionID)
    local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)

    local friendshipID--个人声望

--名望
    if isMajor then
        isCapped=C_MajorFactions.HasMaximumRenown(factionID)
        local info = C_MajorFactions.GetMajorFactionData(factionID)
        if info then
            if info.isUnlocked then
                factionStandingtext= (WoWTools_DataMixin.onlyChinese and '名望' or RENOWN_LEVEL_LABEL)..' '..(info.renownLevel or 0)
                local levels = C_MajorFactions.GetRenownLevels(factionID)
                if levels then
                    factionStandingtext= factionStandingtext..'/'..#levels
                end

                if not isCapped then
                    value= format('|A:GarrMission_CurrencyIcon-Xp:0:0|a%i%%', info.renownReputationEarned/info.renownLevelThreshold*100)
                end
            else
                factionStandingtext= '|A:AdventureMapIcon-Lock:0:0|a'
            end
            if info.textureKit then
                atlas= 'MajorFactions_Icons_'..info.textureKit..'512'
            end

            isUnlocked= info.isUnlocked
            unlockDescription= info.unlockDescription
        end

--个人声望
    elseif repInfo and repInfo.friendshipFactionID and repInfo.friendshipFactionID> 0 then

        factionStandingtext = WoWTools_TextMixin:CN(repInfo.reaction) or ''
        texture=repInfo.texture--图标
        friendshipID= repInfo.friendshipFactionID

        if repInfo.nextThreshold then
            local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID)
            if rankInfo then
                if toRight then
                    factionStandingtext= factionStandingtext..' '..rankInfo.currentLevel..'/'..rankInfo.maxLevel
                else
                    factionStandingtext= (rankInfo.currentLevel..'/'..rankInfo.maxLevel)..' '..factionStandingtext
                end
            end

            local currentExperience = repInfo.standing - repInfo.reactionThreshold
            local nextLevelAt = repInfo.nextThreshold - repInfo.reactionThreshold
            value= format('|A:GarrMission_CurrencyIcon-Xp:0:0|a%i%%', currentExperience/nextLevelAt*100)
            isCapped= false

        else
            isCapped= true
        end

    elseif isHeaderWithRep or not isHeader then
        factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID)

        if not isCapped then
            if barValue and barMax and barMin then
                if barMax==0 then
                    value= format('|A:GarrMission_CurrencyIcon-Xp:0:0|a%i%%', (barMin-barValue)/barMin*100)
                else
                    value= format('|A:GarrMission_CurrencyIcon-Xp:0:0|a%i%%', barValue/barMax*100)
                end
                if toRight then--向右平移 
                    factionStandingtext= factionStandingtext..' '..standingID..'/'..MAX_REPUTATION_REACTION
                else
                    factionStandingtext= standingID..'/'..MAX_REPUTATION_REACTION..' '..factionStandingtext
                end
            end
        end
    end

    barColor= not isUnlocked and DISABLED_FONT_COLOR or (isCapped and WARNING_FONT_COLOR) or FACTION_BAR_COLORS[standingID] or FACTION_ORANGE_COLOR


    local isParagon = C_Reputation.IsFactionParagon(factionID)--奖励
    local hasRewardPending
    local itemID
    if isParagon and isUnlocked and isCapped then--奖励
        --local currentValue, threshold, _, hasRewardPending2, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID)

        local currentValue, threshold, rewardQuestID, hasRewardPending2, tooLowLevelForParagon, paragonStorageLevel = C_Reputation.GetFactionParagonInfo(factionID)
        if hasRewardPending2 then
            itemID = select(6, GetQuestLogRewardInfo(1, rewardQuestID))
            local icon= itemID and select(5, C_Item.GetItemInfoInstant(itemID))
            hasRewardPending= icon and '|T'..icon..':0|t' or format('|A:GarrMission-%sChest:0:0|a', WoWTools_DataMixin.Player.Faction)
        end

        if currentValue and threshold then

            local completed= paragonStorageLevel or math.modf(currentValue/threshold)--完成次数

            currentValue= completed>0 and currentValue - threshold * completed or currentValue

            if toRight then--向右平移 
                value= format('%i%%', currentValue/threshold*100)..' ('..completed..')'
            else
                value= '('..completed..') '..format('%i%%', currentValue/threshold*100)
            end
--等级太低
            if tooLowLevelForParagon then
                value= DISABLED_FONT_COLOR:WrapTextInColorCode(value)
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
        itemID= itemID,

        isCapped= isCapped,
        isHeader= isHeader,
        isHeaderWithRep= isHeaderWithRep,

        hasRep= data.hasBonusRepGain,--额外，声望
        isUnlocked= isUnlocked,
        unlockDescription= unlockDescription,
        
        data= data,
    }
end




function WoWTools_FactionMixin:GetName(factionID, index)
    local data= self:GetInfo(factionID, index)
    if not data.name or not data.factionID then
        if data.name then
            return WoWTools_TextMixin:CN(data.name)
        else
            return factionID or index
        end
    end

    local isAccount= C_Reputation.IsAccountWideReputation(factionID)

    return
        (data.atlas and ('|A:'..data.atlas..':0:0|a') or (data.texture and '|T'..data.texture..':0|t') or '')

        ..(isAccount and '|cff00ccff' or (data.isCapped and '|cffff7f00') or '|cff00ff00')--战团声望， 已满
        ..WoWTools_TextMixin:CN(data.name)--名称
        ..'|r '

        ..(data.isUnlocked and
            '|cffffffff'
            ..(--等级
                data.isCapped and ''
                or (data.factionStandingtext and data.factionStandingtext..' ')
                or ''
            )
            ..((data.isCapped or data.hasRep) and data.valueText or '')--值
            ..'|r'

            or '|A:Professions_Specialization_Lock_Glow:0:0|a'--未解锁
        )

        ..(isAccount and '|A:questlog-questtypeicon-account:0:0|a' or '')

        ..(data.hasRewardPending--有奖励，可取
            and (WoWTools_DataMixin.Player.Faction=='Alliance' and '|A:GarrMission-AllianceChest:0:0|a' or '|A:GarrMission-HordeChest:0:0|a')
            or ''
        )
end




--移过，提示
function WoWTools_FactionMixin:Find(factionID, name)--选中提示

    if not ReputationFrame:IsShown() then
        return
    end

    local all= C_Reputation.GetNumFactions()
    if all==0 then
        return
    end

    if factionID or name then
        for index=1, all do
            local data= C_Reputation.GetFactionDataByIndex(index)
            if data and data.name and data.factionID then

                if data.factionID==factionID or data.name==name then

                    ReputationFrame.ScrollBox:ScrollToElementDataIndex(index)

                    for _, frame in pairs(ReputationFrame.ScrollBox:GetFrames() or {}) do
                        if frame.Content and frame.elementData then
                            if frame.elementData.factionID==factionID or frame.elementData.name==name then
                                frame.Content.BackgroundHighlight:SetAlpha(0.2)
                            else
                                frame.Content.BackgroundHighlight:SetAlpha(0)
                            end
                        end
                    end
                    break
                end
            end
        end
    else
        for _, frame in pairs(ReputationFrame.ScrollBox:GetFrames() or {}) do
            if frame.Content then
               frame.Content.BackgroundHighlight:SetAlpha(0)
            end
        end
    end
end


function WoWTools_FactionMixin:UpdatList()
    if ReputationFrame and ReputationFrame:IsVisible() then
        WoWTools_DataMixin:Call(ReputationFrame.Update, ReputationFrame)
    end
end




--伙伴
--C_DelvesUI.GetDelvesFactionForSeason()
function WoWTools_FactionMixin:GetCompanionInfo(companionID, tooltip)

    local playerCompanionID

    local seasonFactionID= C_DelvesUI.GetDelvesFactionForSeason()
    if seasonFactionID then
        local major= C_MajorFactions.GetMajorFactionData(seasonFactionID)
        if major and major.playerCompanionID then--地下堡，第3赛季 factionID 2272
            companionID= companionID or major.playerCompanionID
            playerCompanionID= major.playerCompanionID
        end
    end


    local factionID = C_DelvesUI.GetFactionForCompanion(companionID)--factionID 2640 布莱恩.铜须
    local info= factionID and C_Reputation.GetFactionDataByID(factionID)

    if not info or not info.name then
        return
    end


    local companionRankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID)


    local compaionName= (playerCompanionID==companionID and '|A:CampCollection-icon-star:0:0|a' or '')
            ..WoWTools_TextMixin:CN(info.name)

    local level
    if companionRankInfo then
        level = companionRankInfo.currentLevel or 0
        local companionRepInfo = C_GossipInfo.GetFriendshipReputation(factionID)
        if companionRepInfo then
            if companionRepInfo.nextThreshold then
                local currentExperience = companionRepInfo.standing - companionRepInfo.reactionThreshold
                local nextLevelAt = companionRepInfo.nextThreshold - companionRepInfo.reactionThreshold
                level= format('%d|A:GarrMission_CurrencyIcon-Xp:0:0|a%i%%', level, currentExperience/nextLevelAt*100)
            else
                --已最高级
                level= ACCOUNT_WIDE_FONT_COLOR:GenerateHexColorMarkup()..level..'|r'
            end
        end
    end

    local traitTreeID = C_DelvesUI.GetTraitTreeForCompanion(companionID)
    local configID= traitTreeID and C_Traits.GetConfigIDByTreeID(traitTreeID)


    if tooltip then
        local hex= configID and '' or DISABLED_FONT_COLOR:GenerateHexColorMarkup()
        tooltip:AddDoubleLine(level and hex..level or ' ', hex..compaionName)
    end

    info.companionID= companionID
    info.playerCompanionID= playerCompanionID

    info.compaionName= compaionName
    info.compaionLevel= level
    info.traitTreeID= traitTreeID
    info.configID= configID

    return info
end