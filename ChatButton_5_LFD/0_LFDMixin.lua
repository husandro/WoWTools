WoWTools_LFDMixin={}




--离开所有队列
function WoWTools_LFDMixin:Leave_All_LFG(isCheck)
    local isInGroup= IsInGroup()
    local isLeavel= not isCheck and (isInGroup and UnitIsGroupLeader("player") or not isInGroup)
    local num=0
    if GetLFGQueueStats(LE_LFG_CATEGORY_SCENARIO) then
        if isLeavel then
            LeaveLFG(LE_LFG_CATEGORY_SCENARIO)
        end
        num= num+1
    end

    --pve
    for i=1, NUM_LE_LFG_CATEGORYS do
        if GetLFGQueueStats(i) then
            for _ in pairs(GetLFGQueuedList(i) or {}) do
                num= num+1
            end
        end
        if isLeavel then
            LeaveLFG(i)
        end
    end

    if C_PetBattles.GetPVPMatchmakingInfo() then--Pet Battles
        if isLeavel then
            C_PetBattles.StopPVPMatchmaking()--PetC_PetBattles.DeclineQueuedPVPMatch()
        end
        num= num+1
    end

    if isLeavel then
        RejectProposal()--拒绝 LFG 邀请并离开队列
    end

    for i=1, MAX_WORLD_PVP_QUEUES or 2 do --World PvP
        local queueID = select(3, GetWorldPVPQueueStatus(i))
        if queueID and queueID>0 then
            if isLeavel then
                BattlefieldMgrExitRequest(queueID)
            end
            num= num+1
        end
    end

--自己，创建
    if C_LFGList.HasActiveEntryInfo() then
        num= num+1
        if isLeavel then
            C_LFGList.RemoveListing()
            C_LFGList.ClearSearchResults()
        end
    end

    --申请，列表
    local apps= C_LFGList.GetApplications() or {}
    if isLeavel then
        for _, resultID in pairs(apps) do
            C_LFGList.CancelApplication(resultID)
        end
    end
    num= num+ #apps


    return num
end







--副本，完成次数
function WoWTools_LFDMixin:Get_Instance_Num(name)
    name= name or GetInstanceInfo()
    local num = self.Save.wow[name] or 0
    local text
    if num >0 then
        text= '|cnGREEN_FONT_COLOR:#'..num..'|r '..(WoWTools_Mixin.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
    else
        text= '0 '..(WoWTools_Mixin.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
    end
    return text , num
end





--设置图标, 点击,提示
function WoWTools_LFDMixin:Set_LFDButton_Data(dungeonID, type, name, texture, atlas)
    if not self.LFDButton then
        return
    end
    self.LFDButton.dungeonID=dungeonID
    self.LFDButton.name=name
    self.LFDButton.type=type--LE_LFG_CATEGORY_LFD LE_LFG_CATEGORY_RF LE_LFG_CATEGORY_SCENARIO
    if atlas then
        self.LFDButton.texture:SetAtlas(atlas)
    elseif texture then
        self.LFDButton.texture:SetTexture(texture)
    else
        if not self.Save.hideQueueStatus then
            self.LFDButton.texture:SetAtlas('groupfinder-eye-frame')
        else
            self.LFDButton.texture:SetAtlas('UI-HUD-MicroMenu-Groupfinder-Mouseover')
        end
    end
end






--显示 LFGDungeonReadyDialog
function WoWTools_LFDMixin:ShowMenu_LFGDungeonReadyDialog(root)
    if not GetLFGProposal() then
        return
    end

    root:CreateDivider()

    local sub= root:CreateButton(
        WoWTools_Mixin.onlyChinese and '显示进入' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, ENTER_LFG),
    function()
        if LFGDungeonReadyPopup:IsShown() then
            StaticPopupSpecial_Hide(LFGDungeonReadyPopup)
        else
            StaticPopupSpecial_Show(LFGDungeonReadyPopup)
        end
        return MenuResponse.Open
    end)

    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('LFGDungeonReadyPopup')
        tooltip:AddDoubleLine(WoWTools_LFDMixin.addName, WoWTools_ChatMixin.addName)
    end)

    return true
end







--排队情况
function WoWTools_LFDMixin:GetQueuedList(category, reTips, reRole)
    local list= GetLFGQueuedList(category)
    local  hasData, _, tank, healer, dps, _, _, _, _, _, _, _, _, _, _, _, queuedTime = GetLFGQueueStats(category)
    if not hasData or not list then
        return
    end
    local m, num= nil, 0
    for dungeonID, _ in pairs(list) do
        local name= dungeonID and GetLFGDungeonInfo(dungeonID)
        if name then
            num= num+1
            if reTips then
                name= WoWTools_TextMixin:CN(name)
                local boss=''
                if category==LE_LFG_CATEGORY_RF then
                    local numEncounters = GetLFGDungeonNumEncounters(dungeonID)
                    local kill=0
                    for index = 1, numEncounters do
                        local isKilled = select(3, GetLFGDungeonEncounterInfo(dungeonID, index))
                        if ( isKilled ) then
                            kill=kill+1
                        end
                    end
                    boss=' '..kill..' / '..numEncounters
                    if kill==numEncounters then boss=RED_FONT_COLOR_CODE..boss..'|r' end
                    local mapName=select(19, GetLFGDungeonInfo(dungeonID))
                    if mapName then
                        name= name.. ' ('..WoWTools_TextMixin:CN(mapName)..')'
                    end
                end
                m=(m and m..'|n  ' or '  ')
                    ..num..') |r '
                    ..name
                    ..boss
                    ..WoWTools_LFDMixin:GetRewardInfo(dungeonID)
            end
        end
    end
    if m and reRole then
        m=m..((tank and tank>0) and INLINE_TANK_ICON..'|cnRED_FONT_COLOR:'..tank..'|r'  or '')
        ..((healer and healer>0) and INLINE_HEALER_ICON..'|cnRED_FONT_COLOR:'..healer..'|r'  or '')
        ..((dps and dps>0) and INLINE_DAMAGER_ICON..'|cnRED_FONT_COLOR:'..dps..'|r'  or '')
        ..'  '..(queuedTime and WoWTools_TimeMixin:Info(queuedTime, true) or '')
        ..' '
    end
    return num, m
end









function WoWTools_LFDMixin:GetRewardInfo(dungeonID, scenarioID)--FB奖励
    local t=''
    if not dungeonID then
        return t
    end

    --local numRewards = select(6, GetLFGDungeonRewards(dungeonID))
    local _, moneyAmount, _, _, experienceVar, numRewards = GetLFGDungeonRewards(dungeonID)

    local rewardIndex, rewardType, rewardArg
    if numRewards and numRewards>0 then--奖励物品
        for i=1 , numRewards do
            local texturePath, _, isBonusReward= select(2, GetLFGDungeonRewardInfo(dungeonID, i))
            if texturePath and not isBonusReward then
                t=t..'|T'..texturePath..':0|t'
                rewardType= 'reward'
                rewardIndex= i
            end
        end
    end

    

    if not IsInGroup(LE_PARTY_CATEGORY_HOME) then
        local T,H,D--额外奖励
        local canTank, canHealer, canDamage = C_LFGList.GetAvailableRoles()
        local eligible, forTank, forHealer, forDamage, itemCount
        for shortageIndex= 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
            
            eligible, forTank, forHealer, forDamage, itemCount= GetLFGRoleShortageRewards(dungeonID, shortageIndex )
            forTank= forTank and canTank
            forHealer= forHealer and canHealer
            forDamage= forDamage and canDamage

            if eligible and (forTank or forHealer or forDamage) then
				for reward=1, itemCount or 0 do
                    local rewardIcon = select(2, GetLFGDungeonShortageRewardInfo(dungeonID, shortageIndex, reward))
                    if rewardIcon then
                        if forTank then
                            T=(T or '')..'|T'..rewardIcon..':0|t'
                        end
                        if forHealer then
                            H=(H or '')..'|T'..rewardIcon..':0|t'
                        end

                        if forDamage then
                            D=(D or '')..'|T'..rewardIcon..':0|t'
                        end
                        rewardIndex, rewardType, rewardArg= reward, "shortage", shortageIndex
                    end
                end
            end
        end
        if T or H  or D then
            t=t..' |cff00ff00('.. (T and WoWTools_DataMixin.Icon['TANK']..T or '').. (H and WoWTools_DataMixin.Icon['HEALER']..H or '').. (D and WoWTools_DataMixin.Icon['DAMAGER']..D or '') ..')|r'
        end
    end

    if moneyAmount and moneyAmount>0 then--钱
        t=t..'|A:Coin-Gold:0:0|a'
    end
    if experienceVar then
        t=t..'|A:GarrMission_CurrencyIcon-Xp:0:0|a'--'|cffff00ffXP|r'
    end

    return t, rewardIndex, rewardType, rewardArg
end


