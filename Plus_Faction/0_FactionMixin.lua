
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










function WoWTools_FactionMixin:GetInfo(factionID, index, toRight)
    local data= Get_Data(factionID, index)
    if not data.name then
        return data
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

    local isCapped= standingID == MAX_REPUTATION_REACTION--8
    local isMajor = C_Reputation.IsMajorFaction(factionID)
    local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)
    local friendshipID--个人声望
    if repInfo and repInfo.friendshipFactionID> 0 then--个人声望
        local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID) or {}
        if rankInfo.currentLevel and rankInfo.maxLevel and rankInfo.maxLevel>0 then
            factionStandingtext= (factionStandingtext and factionStandingtext..' ' or '')..rankInfo.currentLevel..'/'..rankInfo.maxLevel
        end
        if repInfo.nextThreshold then
            if rankInfo.maxLevel>0  and rankInfo.currentLevel~=rankInfo.maxLevel then
                barColor= FACTION_BAR_COLORS[standingID]
            end
            value= format('%i%%', repInfo.standing/repInfo.nextThreshold*100)
            isCapped= false
        else
            value= '|cff9e9e9e'..(WoWTools_Mixin.onlyChinese and '已满' or VIDEO_OPTIONS_ULTRA_HIGH)..'|r'
            isCapped=true
        end
        factionStandingtext = WoWTools_TextMixin:CN(repInfo.reaction)
        texture=repInfo.texture--图标
        friendshipID= repInfo.friendshipFactionID

    elseif isMajor then--名望
        isCapped=C_MajorFactions.HasMaximumRenown(factionID)
        local info = C_MajorFactions.GetMajorFactionData(factionID) or {}
        if info.renownLevel then
            factionStandingtext= (WoWTools_Mixin.onlyChinese and '名望' or RENOWN_LEVEL_LABEL)..' '..info.renownLevel
            local levels = C_MajorFactions.GetRenownLevels(factionID)
            if levels then
                factionStandingtext= factionStandingtext..'/'..#levels
            end
        end
        if not isCapped then
            value= format('%i%%', info.renownReputationEarned/info.renownLevelThreshold*100)
            barColor= GREEN_FONT_COLOR
        else
            value= '|cff9e9e9e'..(WoWTools_Mixin.onlyChinese and '最高' or VIDEO_OPTIONS_ULTRA_HIGH)..'|r'
        end
        atlas=info.textureKit and 'MajorFactions_Icons_'..info.textureKit..'512'
        isUnlocked= info.isUnlocked
    else
        if isHeaderWithRep or not isHeader then
            factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID)
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
                factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID)
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
                value= '|cff9e9e9e'..(WoWTools_Mixin.onlyChinese and '最高' or VIDEO_OPTIONS_ULTRA_HIGH)..'|r'
            end
        end
    end

    local isParagon = C_Reputation.IsFactionParagon(factionID)--奖励
    local hasRewardPending
    if isParagon then--奖励
        local currentValue, threshold, _, hasRewardPending2, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID);
        hasRewardPending= hasRewardPending2 and format('|A:GarrMission-%sChest:0:0|a', WoWTools_DataMixin.Player.Faction) or nil
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
        isUnlocked= isUnlocked,
    }
end




function WoWTools_FactionMixin:GetName(factionID, index)
    local data= WoWTools_FactionMixin:GetInfo(factionID, index, true)
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

            or '|A:greatVault-lock:0:0|a'--未解锁
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