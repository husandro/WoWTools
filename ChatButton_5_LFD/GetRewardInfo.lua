local e= select(2, ...)







function WoWTools_LFDMixin:GetRewardInfo(dungeonID)--FB奖励
    local t=''
    if not dungeonID then
        return t
    end
    --local numRewards = select(6, GetLFGDungeonRewards(dungeonID))
    local _, moneyAmount, _, _, experienceVar, numRewards = GetLFGDungeonRewards(dungeonID)
    if numRewards and numRewards>0 then--奖励物品
        for i=1 , numRewards do
            local texturePath=select(2, GetLFGDungeonRewardInfo(dungeonID, i))
            if texturePath then
                t=t..'|T'..texturePath..':0|t'
            end
        end
    end
    if moneyAmount and moneyAmount>0 then--钱
        t=t..'|A:Coin-Gold:0:0|a'
    end
    if experienceVar then
        t=t..'|A:GarrMission_CurrencyIcon-Xp:0:0|a'--'|cffff00ffXP|r'
    end
    local T,H,D--额外奖励
    local canTank, canHealer, canDamage = C_LFGList.GetAvailableRoles()
    for ii=1, LFG_ROLE_NUM_SHORTAGE_TYPES do
        local eligible, forTank, forHealer, forDamage, itemCount= GetLFGRoleShortageRewards(dungeonID, ii)
        if eligible and itemCount~=0 and ( forTank and canTank or forHealer and canHealer or forDamage and canDamage ) then
            local rewardIcon = select(2, GetLFGDungeonShortageRewardInfo(dungeonID, ii, 1))
            if rewardIcon then--local tankLocked, healerLocked, damageLocked = GetLFDRoleRestrictions(dungeonID)
                if forTank then
                    T=(T or '')..'|T'..rewardIcon..':0|t'
                end
                if forHealer then
                    H=(H or '')..'|T'..rewardIcon..':0|t'
                end
                if forDamage then
                    D=(D or '')..'|T'..rewardIcon..':0|t'
                end
            end
        end
    end
    if T or H  or D then
        t=t..' |cff00ff00('.. (T and e.Icon['TANK']..T or '').. (H and e.Icon['HEALER']..H or '').. (D and e.Icon['DAMAGER']..D or '') ..')|r'
    end
    return t
end


