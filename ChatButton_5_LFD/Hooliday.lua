--节日, 提示, LFDButton.texture












local function Set_Holiday()--节日, 提示, LFDButton.texture
    local dungeonID, name, texturePath, atlas
    local group= IsInGroup(LE_PARTY_CATEGORY_HOME)
    local canTank, canHealer, canDamage = C_LFGList.GetAvailableRoles()
    for dungeonIndex=1, GetNumRandomDungeons() do
        dungeonID, name = GetLFGRandomDungeonInfo(dungeonIndex)
        if dungeonID then
            local isAvailableForAll, isAvailableForPlayer, hid2eIfNotJoinable = IsLFGDungeonJoinable(dungeonID)
            if (isAvailableForPlayer or not hid2eIfNotJoinable) and isAvailableForAll then
                if select(15, GetLFGDungeonInfo(dungeonID)) then
                    local numRewards = select(6, GetLFGDungeonRewards(dungeonID))--isHoliday
                    if numRewards and numRewards>0 then--奖励物品
                        local find
                        for rewardIndex=1 , numRewards do
                            local _, texture, _, isBonusReward, rewardType= GetLFGDungeonRewardInfo(dungeonID, rewardIndex)
                            if texture then
                                if rewardType == "currency" then
                                    texturePath= texture
                                    find=true
                                    break
                                elseif rewardType=='item' then
                                    texturePath= texture
                                    --find=true
                                    --break
                                elseif isBonusReward and not texturePath then
                                    texturePath= texture
                                end
                            end
                        end
                        if find then
                            break
                        end
                    end
                elseif not group then
                    for shortageIndex=1, LFG_ROLE_NUM_SHORTAGE_TYPES do
                        local eligible, forTank, forHealer, forDamage, itemCount= GetLFGRoleShortageRewards(dungeonID, shortageIndex)
                        if eligible and itemCount~=0 and (forTank and canTank or forHealer and canHealer or forDamage and canDamage) then
                            atlas= format('groupfinder-icon-role-large-%s', forTank and 'tank' or forHealer and 'heal' or 'dps')
                            break
                        end
                    end
                end
            end
        end
    end
    if not texturePath and not atlas then
        dungeonID, name= nil,nil
    end
    WoWTools_LFDMixin:Set_LFDButton_Data(dungeonID, LE_LFG_CATEGORY_LFD, WoWTools_TextMixin:CN(name), texturePath,  atlas)--设置图标
end










--节日, 提示, LFDButton.texture

function WoWTools_LFDMixin:Init_Holiday()
    EventRegistry:RegisterFrameEventAndCallback("LFG_UPDATE_RANDOM_INFO", Set_Holiday)
    C_Timer.After(2, Set_Holiday)
end