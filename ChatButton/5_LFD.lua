local id, e = ...
local addName
local Save={
    leaveInstance=e.Player.husandro,--自动离开,指示图标
    autoROLL= e.Player.husandro,--自动,战利品掷骰
    --disabledLootPlus=true,--禁用，战利品Plus
    ReMe=true,--仅限战场，释放，复活
    autoSetPvPRole=true,--自动职责确认， 排副本
    LFGPlus= e.Player.husandro,--预创建队伍增强
    tipsScale=1,--提示内容,缩放

    wow={
        --['island']=0,
        --[副本名称]=0,
    }
}


local sec=3--时间 timer
local LFDButton, tipsButton
local panel= CreateFrame("Frame")




















local function Save_Instance_Num(name)
    name= name or GetInstanceInfo()
    if name then
        Save.wow[name]= (Save.wow[name] or 0)+1
    end
end



function e.Get_Instance_Num(name)
    name= name or GetInstanceInfo()
    local num = Save.wow[name] or 0
    local text
    if num >0 then
        text= '|cnGREEN_FONT_COLOR:#'..num..'|r '..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
    else
        text= '0 '..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
    end
    return text , num
end




















local function get_Reward_Info(dungeonID)--FB奖励
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


local function get_Queued_List(type, reTips, reRole)--排队情况
    local list= GetLFGQueuedList(type)
    local  hasData, _, tank, healer, dps, _, _, _, _, _, _, _, _, _, _, _, queuedTime =GetLFGQueueStats(type)
    if not hasData or not list then
        return
    end
    local m, num= nil, 0
    for dungeonID, _ in pairs(list) do
        local name= dungeonID and GetLFGDungeonInfo(dungeonID)
        if name then
            num= num+1
            if reTips then
                name= e.cn(name)
                local boss=''
                if type==LE_LFG_CATEGORY_RF then
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
                        name= name.. ' ('..e.cn(mapName)..')'
                    end
                end
                m=(m and m..'|n  ' or '  ')
                    ..num..') |r '
                    ..name
                    ..boss
                    ..get_Reward_Info(dungeonID)
            end
        end
    end
    if m and reRole then
        m=m..((tank and tank>0) and INLINE_TANK_ICON..'|cnRED_FONT_COLOR:'..tank..'|r'  or '')
        ..((healer and healer>0) and INLINE_HEALER_ICON..'|cnRED_FONT_COLOR:'..healer..'|r'  or '')
        ..((dps and dps>0) and INLINE_DAMAGER_ICON..'|cnRED_FONT_COLOR:'..dps..'|r'  or '')
        ..'  '..(queuedTime and e.GetTimeInfo(queuedTime, true) or '')
        ..' '
    end
    return num, m
end









--设置图标, 点击,提示
local function Set_LFDButton_Data(dungeonID, type, name, texture, atlas)
    LFDButton.dungeonID=dungeonID
    LFDButton.name=name
    LFDButton.type=type--LE_LFG_CATEGORY_LFD LE_LFG_CATEGORY_RF LE_LFG_CATEGORY_SCENARIO
    if atlas then
        LFDButton.texture:SetAtlas(atlas)
    elseif texture then
        LFDButton.texture:SetTexture(texture)
    else
        if not Save.hideQueueStatus then
            LFDButton.texture:SetAtlas('groupfinder-eye-frame')
        else
            LFDButton.texture:SetAtlas('UI-HUD-MicroMenu-Groupfinder-Mouseover')
        end
    end
end





--[[
local function printListInfo()--输出当前列表
    C_Timer.After(1.2, function()
        for i=1, NUM_LE_LFG_CATEGORYS  do--列表信息
            local n, text =get_Queued_List(i, true)--排5人本
            if n and n>0 and text then
                print(e.addName, addName, date('%X'))
                print(text)
            end
        end
    end)
end

]]





















--#####
--小眼睛
--#####
local function get_InviteButton_Frame(index)
    local frame= tipsButton.lfgTextTab[index]
    if not frame then
        local size=14
        frame= CreateFrame("Frame", nil, tipsButton)
        frame:SetSize(1,1)
        if index==1 then
            frame:SetPoint('TOPLEFT', tipsButton.text, 'BOTTOMLEFT')
        else
            frame:SetPoint('TOPLEFT', tipsButton.lfgTextTab[index-1], 'BOTTOMLEFT')
        end

        frame.ChatButton= e.Cbtn(frame, {size={size,size}, atlas= 'transmog-icon-chat'})
        frame.ChatButton:SetPoint('TOPLEFT')
        frame.ChatButton:SetScript('OnClick', function(self2)
            e.Say(nil, self2:GetParent().name)
        end)
        frame.ChatButton:SetScript('OnLeave', GameTooltip_Hide)
        frame.ChatButton:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine( self2:GetParent().name, e.onlyChinese and '/密语' or SLASH_SMART_WHISPER2)
            e.tips:AddLine(self2:GetParent().tooltip)
            e.tips:Show()
        end)

        frame.InviteButton= e.Cbtn(frame, {size={size,size}, atlas= e.Icon.select})
        frame.InviteButton:SetPoint('LEFT', frame.ChatButton, 'RIGHT')
        frame.InviteButton:SetScript('OnClick', function(self2)
            if ( not IsInRaid(LE_PARTY_CATEGORY_HOME)
                and (GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) + self2:GetParent().numMembers + C_LFGList.GetNumInvitedApplicantMembers()) > (MAX_PARTY_MEMBERS + 1) )
            then
                local dialog = StaticPopup_Show("LFG_LIST_INVITING_CONVERT_TO_RAID")
                if ( dialog ) then
                    dialog.data = self2:GetParent().applicantID
                end
            else
                C_LFGList.InviteApplicant(self2:GetParent().applicantID)
            end
        end)
        frame.InviteButton:SetScript('OnLeave', GameTooltip_Hide)
        frame.InviteButton:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(self2:GetParent().applicantID, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '邀请' or INVITE))
            e.tips:AddLine(self2:GetParent().tooltip)
            e.tips:Show()
        end)

        frame.DeclineButton= e.Cbtn(frame, {size={size,size}, atlas= 'communities-icon-redx'})
        frame.DeclineButton:SetPoint('LEFT', frame.InviteButton, 'RIGHT')
        frame.DeclineButton:SetScript('OnClick', function(self2)
            --C_LFGList.RemoveApplicant(self2:GetParent().applicantID)
            C_LFGList.DeclineApplicant(self2:GetParent().applicantID)
        end)
        frame.DeclineButton:SetScript('OnLeave', GameTooltip_Hide)
        frame.DeclineButton:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine( self2:GetParent().applicantID, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '拒绝' or DECLINE))
            e.tips:AddLine(self2:GetParent().tooltip)
            e.tips:Show()
        end)

        frame.text= e.Cstr(frame, {size=Save.tipsFrameTextSize, color=true})
        frame.text:SetPoint('TOPLEFT', frame.DeclineButton, 'TOPRIGHT')

        tipsButton.lfgTextTab[index]= frame
    end
    return frame
end


local function set_tipsFrame_Tips(text, LFGListTab)
    tipsButton.text:SetText(text or '')
    tipsButton:SetShown(text and true or false)

    table.sort(LFGListTab, function(a, b)
        if a.index== b.index then
            return a.itemLevel> b.itemLevel
        else
            return a.index< b.index
        end
    end)
    for index, tab in pairs(LFGListTab) do
        local frame= get_InviteButton_Frame(index)
        frame.text:SetText((index<10 and ' ' or '')..index..') '..tab.text)
        frame:SetHeight(frame.text:GetHeight())
        frame.applicantID= tab.applicantID
        frame.numMembers= tab.numMembers
        frame.tooltip= tab.text
        frame.name= tab.name
        frame:SetShown(true)
    end

    for index= #LFGListTab+1, #tipsButton.lfgTextTab do
        tipsButton.lfgTextTab[index].text:SetText('')
        tipsButton.lfgTextTab[index]:SetShown(false)
    end

    if not LFDButton.leaveInstance and Save.leaveInstance then--自动离开,指示图标
        LFDButton.leaveInstance=LFDButton:CreateTexture(nil, 'ARTWORK')
        LFDButton.leaveInstance:SetPoint('BOTTOMLEFT',4, 0)
        LFDButton.leaveInstance:SetSize(12,12)
        LFDButton.leaveInstance:SetAtlas(e.Icon.toLeft)
        --LFDButton.leaveInstance:SetDesaturated(true)
    end
    if LFDButton.leaveInstance then
        LFDButton.leaveInstance:SetShown(Save.leaveInstance)
    end
end
local function get_Status_Text(status)--列表，状态，信息
    return status=='queued' and ('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '在队列中' or BATTLEFIELD_QUEUE_STATUS)..'|r')
        or status=='confirm' and ('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '就绪' or READY)..'|r')
        or status=='active' and ('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '激活' or SPEC_ACTIVE)..'|r')
        or status=='proposal' and ('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '准备进入' or QUEUED_STATUS_PROPOSAL)..'|r')
        or status=='error' and ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '错误' or ERRORS)..'|r')
        or status=='none' and ('|cnYELLOW_FONT_COLOR:'..(e.onlyChinese and '无' or NONE)..'|r')
        or status=='suspended' and ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '暂停' or QUEUED_STATUS_SUSPENDED)..'|r')
        or status or ''
end




local function Set_Queue_Status()--小眼睛, 信息
    if Save.hideQueueStatus then--列表信息 
        set_tipsFrame_Tips(nil, {})
       return
    end

    local isLeader= LFGListUtil_IsEntryEmpowered()
    local text
    local num= 0
    local pve
    for i=1, NUM_LE_LFG_CATEGORYS do--PVE
        local listNum, listText= get_Queued_List(i, true, true)
        if listNum and listText then
            listText= listText:gsub('|n', '|n ')
            pve= pve and pve..'|n' or ''
            pve= pve..' '..listText
            pve= pve..' '
            num= num+ listNum
        end
    end
    if pve then
        local _, tank, healer, dps= GetLFGRoles()--检测是否选定角色pve
        text= text and text..'|n' or ''
        text= text..'|A:groupfinder-icon-friend:0:0|a|cnGREEN_FONT_COLOR:'..(e.onlyChinese and 'PVE' or TRANSMOG_SET_PVE)..'|r'
                ..(tank and INLINE_TANK_ICON or '')
                ..(healer and INLINE_HEALER_ICON or '')
                ..(dps and INLINE_DAMAGER_ICON or '')
                ..' '
        text= text..'|n'..pve..' '
    end

    local pvp
    for i=1, GetMaxBattlefieldID() do --PVP
        local status, mapName, teamSize, _, suspendedQueue, queueType, _, role = GetBattlefieldStatus(i)
        if status and mapName then
            pvp= pvp and pvp..'|n' or ''
            pvp= pvp..'   '..i..') '
                ..e.cn(mapName)..(queueType and ' ('..queueType..')')
                ..(status~='queued' and ' '..get_Status_Text(status) or '')
                ..(teamSize and teamSize>0 and ' '..teamSize or '')
                ..(suspendedQueue and ('|cnRED_FONT_COLOR: ['..(e.onlyChinese and '暂停' or QUEUED_STATUS_SUSPENDED)..']|r') or '')
                ..(e.Icon[role] or '')
                ..' '.. e.SecondsToClock(GetBattlefieldTimeWaited(i) / 1000)
                ..' '
        end
    end
    if pvp then
        local tank, healer, dps = GetPVPRoles()
        text= text and text..'|n' or ''
        text= text..'|A:honorsystem-icon-prestige-6:0:0|a|cnGREEN_FONT_COLOR:PvP|r'
            ..(tank and INLINE_TANK_ICON or '')
            ..(healer and INLINE_HEALER_ICON or '')
            ..(dps and INLINE_DAMAGER_ICON or '')
            ..' '
        text= text..'|n'..pvp
    end


    local queueState, _, queuedTime= C_PetBattles.GetPVPMatchmakingInfo() --PET
    if queueState then
        local pet= '|A:worldquest-icon-petbattle:0:0|a|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '宠物对战' or PET_BATTLE_PVP_QUEUE)..'|r'
        if queuedTime then
            pet= pet..' '..e.GetTimeInfo(queuedTime, true)
        end
        if queueState~='queued' then
            pet= pet..' '..get_Status_Text(queueState)
        end

        pet= pet..' '
        for slotIndex= 1, 3 do
            local tab= {C_PetJournal.GetPetLoadOutInfo(slotIndex)}--petID, ability1, ability2, ability3 = C_PetJournal.GetPetLoadOutInfo(slotIndex)
            if tab[1] then
                local _, _, level, _, _, _, _, _, icon = C_PetJournal.GetPetInfoByPetID(tab[1])
                if icon then
                    level= level or 1
                    pet= pet..'|n   '..slotIndex..') '
                        ..'|T'..icon..':0|t'
                        ..' '..(level<25 and '|cnRED_FONT_COLOR:'..level..'|r' or level)
                    for index= 2, 4 do
                        local abilityID= tab[index]
                        local abilityIcon= abilityID and select(2, C_PetJournal.GetPetAbilityInfo(abilityID))
                        if abilityIcon then
                            pet= pet..(index==2 and ' ' or '')..'|T'..abilityIcon..':0|t'
                        end
                    end
                    pet= pet..' '
                end
            end
        end
        text= text and text..'|n' or ''
        text= text..pet
    end

    local lfg--LFG，申请，列表
    local LFGTab= C_LFGList.GetApplications() or {}
    for index, applicantID in pairs(LFGTab) do
        local _, appStatus, _, appDuration, role = C_LFGList.GetApplicationInfo(applicantID)-- id, appStatus, pendingStatus, appDuration, role 
        if appStatus == "applied"  and appDuration and appDuration>0 then--invited,none
            local info = C_LFGList.GetSearchResultInfo(applicantID) or {}
            local activityName = C_LFGList.GetActivityFullName(info.activityID, nil, info.isWarMode)
            if info and info.name and not info.autoAccept and not info.isDelisted then
                local pvpRating--PVP分数
                local pvpIcon
                if info.leaderPvpRatingInfo then
                    if info.leaderPvpRatingInfo.tier and info.leaderPvpRatingInfo.tier>0 then
                        pvpIcon= ('|A:honorsystem-icon-prestige-'..info.leaderPvpRatingInfo.tier..':0:0|a')
                    elseif info.leaderPvpRatingInfo.rating and info.leaderPvpRatingInfo.rating> 0 then
                        pvpIcon= '|A:pvptalents-warmode-swords:0:0|a'
                    end
                    if info.leaderPvpRatingInfo.rating and info.leaderPvpRatingInfo.rating> 0 then
                        pvpRating= info.leaderPvpRatingInfo.rating
                    end
                end

                local numMembers--人数
                if info.numMembers and info.numMembers>0 then
                    numMembers= ' |A:socialqueuing-icon-group:0:0|a'..info.numMembers--..(e.onlyChinese and '队员' or PLAYERS_IN_GROUP)
                    local friendly
                    if info.numBNetFriends and info.numBNetFriends>0 then
                        friendly = (friendly and friendly..' ' or '')..info.numBNetFriends..format('|T%d:0|t', e.Icon.wow)
                    end
                    if info.numCharFriends and info.numCharFriends>0 then
                        friendly = (friendly and friendly..' ' or '')..info.numCharFriends..'|A:recruitafriend_V2_tab_icon:0:0|a'
                    end
                    if info.numGuildMates and info.numGuildMates>0 then
                        friendly = (friendly and friendly..' ' or '')..info.numGuildMates..'|A:communities-guildbanner-background:0:0|a'
                    end
                    if friendly then
                        numMembers= numMembers..' ('..friendly..')'
                    end
                end

                local factionText--指定，派系 info.crossFactionListing
                if info.leaderFactionGroup==0 and e.Player.faction=='Alliance' then
                    factionText= format('|A:%s:0:0|a', e.Icon.Horde)
                elseif info.leaderFactionGroup==1 and e.Player.faction=='Horde' then
                    factionText= format('|A:%s:0:0|a', e.Icon.Alliance)
                end

                local roleText--职责
                if role~='NONE' then
                    roleText= e.Icon[role]
                end

                lfg= lfg and lfg..'\n   ' or '   '
                lfg= lfg..index..') '..e.cn(info.name)
                    ..' '.. (e.cn(activityName) or '')
                    ..(numMembers or '')
                    ..(info.leaderOverallDungeonScore and info.leaderOverallDungeonScore>0 and ' '..e.GetKeystoneScorsoColor(info.leaderOverallDungeonScore, true) or '')
                    ..(pvpIcon or '')
                    ..(pvpRating or '')
                    ..(info.questID and '|A:AutoQuest-Badge-Campaign:0:0|a' or '')
                    ..(info.isWarMode and '|A:pvptalents-warmode-swords:0:0|a' or '')
                    ..(factionText or '')
                    ..(roleText or '')
                    ..' '..e.SecondsToClock(appDuration)--过期，时间
                    ..' '
            end

        end
    end
    if lfg then
        text= text and text..'|n' or ''
        text= text..'|A:charactercreate-icon-dice:0:0|a|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已登记' or QUEUED_STATUS_SIGNED_UP)..'|r #'..#LFGTab
        text= text..'|n'..lfg
    end

    --已激活LFG
    local LFGListTab= {}
    if C_LFGList.HasActiveEntryInfo() then
        local list
        local info= C_LFGList.GetActiveEntryInfo()

        if info and info.name then
            local applicants =C_LFGList.GetApplicants() or {}--申请人数
            local applicantsNum= #applicants

            local member
            if not info.autoAccept and applicantsNum>0 then
                local n=0
                for _, applicantID in pairs(applicants) do
                    local applicantInfo = C_LFGList.GetApplicantInfo(applicantID)
                    if applicantInfo and applicantInfo.numMembers and applicantInfo.applicationStatus=='applied' then
                        local memberText
                        local roleIndex= 3
                        local unitItemLevel= 0
                        local leaderName
                        for index=1 , applicantInfo.numMembers do
                            local name, class, _, level, itemLevel, honorLevel, tank, healer, dps, _, _, dungeonScore, pvpItemLevel= C_LFGList.GetApplicantMemberInfo(applicantID, index)
                            local icon= e.Class(nil, class)
                            if icon and name and class then
                                local col= '|c'..select(4, GetClassColor(class))--颜色

                                local levelText--等级
                                if level and level~=MAX_PLAYER_LEVEL then
                                    levelText=' |cnRED_FONT_COLOR:'..level..'|r'
                                end

                                local itemLevelText--装等/PVP装有情
                                if  itemLevel and itemLevel>20 then
                                    itemLevelText= format('%i',itemLevel)
                                    if pvpItemLevel and pvpItemLevel-itemLevel>9 then
                                        itemLevelText= itemLevelText..'/'..format('%i', pvpItemLevel)
                                    end
                                end

                                local realmText--服务器，名称
                                local realm= name:match('%-(.+)')
                                if realm then
                                    local realmTab = e.Get_Region(realm)
                                    if realmTab and realmTab.col then
                                        realmText= ' '..name ..' '..realmTab.col
                                    else
                                        realmText= name
                                    end
                                end

                                local scorsoText= e.GetKeystoneScorsoColor(dungeonScore, false) or ''--挑战分数，荣誉等级
                                if honorLevel and honorLevel>1 then
                                    scorsoText= scorsoText~='' and scorsoText..' ' or scorsoText
                                    scorsoText= scorsoText..'|A:pvptalents-warmode-swords:0:0|a'..honorLevel
                                end

                                memberText= memberText and memberText..(isLeader and '|n     ' or '|n          ') or ''
                                memberText= memberText..col
                                    ..(e.GetFriend(name) or '')
                                    ..icon
                                    ..(tank and INLINE_TANK_ICON or '')
                                    ..(healer and INLINE_HEALER_ICON or '')
                                    ..(dps and INLINE_DAMAGER_ICON or '')
                                    ..(itemLevelText or '')
                                    ..scorsoText
                                    ..(levelText or '')
                                    ..(realmText or '')
                                    ..'|r '

                                local roleIndex2= tank and 1 or healer and 2 or 3--索引
                                roleIndex= roleIndex< roleIndex2 and roleIndex2 or roleIndex
                                if index==1 then
                                    leaderName= name
                                end
                                if itemLevel then--物品等级
                                    unitItemLevel= itemLevel> unitItemLevel and itemLevel or unitItemLevel
                                end
                            end
                        end
                        if memberText and isLeader then--队长, 内容
                            table.insert(LFGListTab, {
                                text= memberText,
                                applicantID= applicantID,
                                index= roleIndex,
                                itemLevel= unitItemLevel,
                                numMembers= applicantInfo.numMembers,
                                name= leaderName,
                            })
                            n=n+1
                            member= member and member..'|n' or ''
                            member= member..'      '.. (n<10 and ' '..n or n)..')'..memberText
                        end
                    end
                end
            end

            local name2= info.activityID and C_LFGList.GetActivityFullName(info.activityID)--名称
            list= '   '..info.name--名称
                ..' |cFF00FF00#'..applicantsNum..'|r'--数量
                ..(info.autoAccept and '|A:runecarving-icon-reagent-empty:0:0|a' or '')--自动邀请
                ..(name2 and ' '..name2 or '')--名称
                ..(info.privateGroup and  (e.onlyChinese and '私人' or LFG_LIST_PRIVATE) or '')--私人
                ..(info.duration and  ' '..e.SecondsToClock(info.duration) or '')--时间

            if member and not isLeader then--不是队长, 显示, 内容
                list= list..'|n'..member
            end
        end
        if list then
            text= (text and text..'|n' or '')
            ..(LFGListUtil_IsEntryEmpowered() and e.Icon.player or '|A:auctionhouse-icon-favorite:0:0|a')
            ..(e.onlyChinese and '招募' or RAF_RECRUITMENT)..(info.autoAccept and ' ('..(e.onlyChinese and '自动加入' or AUTO_JOIN)..')' or '')
            ..'|n'..list
        end
    end

    set_tipsFrame_Tips(text, LFGListTab)
end






























local function Init_tipsButton()
    tipsButton= e.Cbtn(nil, {size={22,22}, atlas= 'UI-HUD-MicroMenu-Groupfinder-Mouseover'})

    function tipsButton:set_Point()
        if Save.tipsFramePoint then
            tipsButton:SetPoint(Save.tipsFramePoint[1], UIParent, Save.tipsFramePoint[3], Save.tipsFramePoint[4], Save.tipsFramePoint[5])
        else
            tipsButton:SetPoint('BOTTOMLEFT', LFDButton, 'TOPLEFT',0,2)
        end
    end

    tipsButton:SetScript("OnDragStart", function(self, d)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    tipsButton:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save.tipsFramePoint={self:GetPoint(1)}
        Save.tipsFramePoint[2]=nil
    end)

    function tipsButton:set_scale()
        self.text:SetScale(Save.tipsScale or 1)
    end

    tipsButton:SetScript('OnMouseWheel', function(self, delta)
        Save.tipsScale= WoWTools_MenuMixin:ScaleFrame(self, delta, Save.tipsScale, nil)
    end)

    tipsButton:SetScript("OnMouseDown", function(_, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    tipsButton:SetScript('OnMouseUp', ResetCursor)

    function tipsButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '列表信息' or (SOCIAL_QUEUE_TOOLTIP_HEADER..INFO), '|A:groupfinder-eye-frame:0:0|a')
        e.tips:AddLine(' ')

        e.tips:AddDoubleLine(
            (IsInGroup() and not UnitIsGroupLeader("player") and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:')..(e.onlyChinese and '离开所有队列' or LEAVE_ALL_QUEUES),
            '|cnGREEN_FONT_COLOR:Shift+'..e.Icon.left
        )
        e.tips:AddDoubleLine(e.onlyChinese and '队伍查找器' or DUNGEONS_BUTTON, e.Icon.right)
        e.tips:AddLine(' ')

        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' '..(Save.tipsScale or 1), 'Alt+'..e.Icon.mid)

        e.tips:Show()
    end
    tipsButton:SetScript("OnLeave", function(self)
        e.tips:Hide()
        ResetCursor()
        LFDButton:SetButtonState('NORMAL')
       -- self:state_leave()
    end)

    tipsButton:SetScript('OnEnter', function(self)
        self:set_tooltip()
        LFDButton:SetButtonState('PUSHED')
        Set_Queue_Status()--小眼睛, 更新信息
        --self:state_leave()
    end)


    
    --[[tipsButton:SetScript('OnClick', function(_, d)
        if d=='RightButton' and not IsModifierKeyDown() then
            PVEFrame_ToggleFrame()
        end
    end)]]

    tipsButton:SetScript('OnClick', function(self, d)--离开所有队列
        if d=='RightButton' and not IsModifierKeyDown() then
            PVEFrame_ToggleFrame()
            return
        end

        if (IsInGroup() and not UnitIsGroupLeader("player")) or not IsShiftKeyDown() or d~='LeftButton' then
            return
        end

        if GetLFGQueueStats(LE_LFG_CATEGORY_SCENARIO) then
            LeaveLFG(LE_LFG_CATEGORY_SCENARIO)
        end
        --pve
        for i=1, NUM_LE_LFG_CATEGORYS do
            LeaveLFG(i)
        end

        if C_PetBattles.GetPVPMatchmakingInfo() then--Pet Battles
            C_PetBattles.StopPVPMatchmaking()--PetC_PetBattles.DeclineQueuedPVPMatch()
        end

        RejectProposal()--拒绝 LFG 邀请并离开队列

        --[[PvP 不能用，保护 AcceptBattlefieldPort
        for i=1, GetMaxBattlefieldID() do
            local status, mapName, teamSize, registeredMatch, suspendedQueue, queueType = GetBattlefieldStatus(i)
        end]]

        if GetNumWorldPVPAreas then--10.2.7 移除
            for i=1,  GetNumWorldPVPAreas() do --World PvP
                local queueID = select(3, GetWorldPVPQueueStatus(i))
                if queueID and queueID>0 then
                    BattlefieldMgrExitRequest(queueID)
                end
            end
        end

        C_LFGList.RemoveListing()
        C_LFGList.ClearSearchResults()
    end)

    --[[tipsButton:SetScript('OnUpdate', function(self, elapsed)
        if UnitAffectingCombat('player') then
            return
        end
        self.elapsed= (self.elapsed or 1) + elapsed
        if self.elapsed>=1 and not UnitAffectingCombat('player') then
            self.elapsed=0
            Set_Queue_Status{}
            --e.call(QueueStatusFrame.Update, QueueStatusFrame)--小眼睛, 更新信息, QueueStatusFrame.lua
            --e.call(LFGListUtil_SetAutoAccept, C_LFGList.CanActiveEntryUseAutoAccept())--LFGList.lua 不可用
        end
    end)]]

    tipsButton.text= e.Cstr(tipsButton, {size=Save.tipsFrameTextSize, color=true})--Save.tipsFrameTextSize, nil, nil, true)
    tipsButton.text:SetPoint('BOTTOMLEFT', tipsButton, 'BOTTOMRIGHT')

    tipsButton.lfgTextTab= {}
    tipsButton.lfgTextTab[1]= get_InviteButton_Frame(1)


    tipsButton:set_Point()
    tipsButton:set_scale()--设置, 缩放
    tipsButton:RegisterForDrag("RightButton")
    tipsButton:SetMovable(true)
    tipsButton:SetClampedToScreen(true)
end













































local function Add_Initializer(button, description)
    if not button.leftTexture then
        button.leftTexture = button:AttachTexture()
        button.leftTexture:SetSize(20, 20)
        button.leftTexture:SetAtlas(e.Icon.toRight)
        button.leftTexture:SetPoint("LEFT")
        button.leftTexture:Hide()
        button.fontString:SetPoint('LEFT', button.leftTexture, 'RIGHT')
    end
    
    button:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed= (self.elapsed or 0.5) +elapsed
        if self.elapsed>0.5 then
            self.elapsed=0
            local isInQueue= GetLFGQueueStats(description.data.type, description.data.dungeonID)
            if isInQueue then
                self.fontString:SetTextColor(0,1,0)
            else
                self.fontString:SetTextColor(1,1,1)
            end
            if self.leftTexture then
                self.leftTexture:SetShown(isInQueue)
            end
        end
    end)

    button:SetScript('OnHide', function(self)
        self:SetScript('OnUpdate', nil)
        self.elapsed=nil
        if self.fontString then
            self.fontString:SetTextColor(1,1,1)
            self.fontString:SetPoint('LEFT')
        end
        if self.leftTexture then
            self.leftTexture:SetShown(false)
        end
    end)
end





















--追随者，副本
local function Set_LFGFollower_Dungeon_List(root)--追随者，副本
    if PlayerGetTimerunningSeasonID() then
        return
    end

    local followerList= {}
    local dungeoNum= 0
	for _, dungeonID in ipairs( GetLFDChoiceOrder() or {}) do--LFDFrame.lua
		if not LFGLockList[dungeonID] or not LFGLockList[dungeonID].hideEntry then
			if dungeonID >= 0 and C_LFGInfo.IsLFGFollowerDungeon(dungeonID) then
				table.insert(followerList, dungeonID)
                dungeoNum= dungeoNum+1
			end
		end
	end

    if dungeoNum==0 then
        return
    end
    local sub, sub2

    sub= root:CreateButton(e.onlyChinese and '追随者地下城' or LFG_TYPE_FOLLOWER_DUNGEON, function()
        return MenuResponse.Open
    end)

    for _, dungeonID in pairs(followerList) do
        local info = C_LFGInfo.GetDungeonInfo(dungeonID)
        if info and info.name then
            local isAvailableForAll, isAvailableForPlayer, hid2eIfNotJoinable = IsLFGDungeonJoinable(dungeonID)
            if (isAvailableForAll or not hid2eIfNotJoinable) then


                if isAvailableForPlayer then
                    sub2= sub:CreateButton(
                            (info.iconID and '|T'..info.iconID..':0|t' or '')
                            ..e.cn(info.name)
                            ..get_Reward_Info(dungeonID)
                            ..(GetLFGDungeonRewards(dungeonID) and format('|A:%s:0:0|a', e.Icon.select) or ''),

                        function(description)
                            if GetLFGQueueStats(LE_LFG_CATEGORY_LFD, description.dungeonID) then
                                LeaveSingleLFG(LE_LFG_CATEGORY_LFD, description.dungeonID)
                            else
                                LFDQueueFrame_SetTypeInternal('follower')
                                LFDQueueFrame_SetType(description.dungeonID)
                                LFDQueueFrame_Join()
                                Set_LFDButton_Data(description.dungeonID, LE_LFG_CATEGORY_LFD, e.cn(description.dungeonName), nil)--设置图标, 点击,提示
                            end
                            return MenuResponse.Open
                        end, {
                            dungeonID=dungeonID,
                            dungeonName=info.name,
                            type=LE_LFG_CATEGORY_LFD
                        })

                    sub2:SetTooltip(function(tooltip, description)
                        tooltip:AddLine(e.cn(description.data.dungeonName)..' ')
                        tooltip:AddLine(' ')
                        tooltip:AddDoubleLine(
                            'dungeonID '..description.data.dungeonID,
                            e.Get_Instance_Num(description.data.dungeonName),''
                        )

                    end)

                    sub2:AddInitializer(Add_Initializer)

                --[[else

                    sub2=sub:CreateButton('   |cff9e9e9e'..name..' |r', function()
                        return MenuResponse.Open
                    end, {
                        dungeonID=dungeonID,
                        dungeonName=name
                    })

                    sub2:SetTooltip(function(tooltip, description)
                        tooltip:AddLine(description.data.dungeonName..' ')
                        tooltip:AddLine(' ')
                        tooltip:AddLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '你不能进入此队列。' or YOU_MAY_NOT_QUEUE_FOR_THIS))
                        local declined= LFGConstructDeclinedMessage(description.data.dungeonID)
                        if declined and declined~='' then
                            tooltip:AddLine('|cnRED_FONT_COLOR:'..e.cn(declined), nil,nil,nil, true)
                        end
                        tooltip:AddLine(' ')
                        tooltip:AddLine('dungeonID: '..description.data.dungeonID)
                    end)]]
                end
            end

        end
    end
    if dungeoNum>35 then
        local line= math.ceil(dungeoNum/35)
        sub:SetGridMode(MenuConstants.VerticalGridDirection, line)
    end
end























--副本， 菜单列表
--5人，随机 LFDFrame.lua
local function set_Party_Menu_List(root)
    local sub, find
    for i=1, GetNumRandomDungeons() do
        local dungeonID, name = GetLFGRandomDungeonInfo(i)
        if dungeonID and name then
            local isAvailableForAll, isAvailableForPlayer, hid2eIfNotJoinable = IsLFGDungeonJoinable(dungeonID)
            if (isAvailableForAll or not hid2eIfNotJoinable) then
                if isAvailableForPlayer then


                    sub=root:CreateButton(
                        e.cn(name)
                        ..get_Reward_Info(dungeonID)
                        ..(GetLFGDungeonRewards(dungeonID) and format('|A:%s:0:0|a', e.Icon.select) or ''),

                    function(description)
                        if GetLFGQueueStats(LE_LFG_CATEGORY_LFD, description.dungeonID) then
                            LeaveSingleLFG(LE_LFG_CATEGORY_LFD, description.dungeonID)
                        else
                            LFDQueueFrame_SetTypeInternal('specific')
                            LFDQueueFrame_SetType(description.dungeonID)
                            LFDQueueFrame_Join()
                            Set_LFDButton_Data(description.dungeonID, LE_LFG_CATEGORY_LFD, e.cn(description.dungeonName), nil)--设置图标, 点击,提示
                        end
                        return MenuResponse.Open

                    end, {
                        dungeonID=dungeonID,
                        dungeonName=name,
                        type=LE_LFG_CATEGORY_LFD,

                    })

                    sub:SetTooltip(function(tooltip, description)
                        tooltip:AddLine(e.cn(description.data.dungeonName)..' ')
                        tooltip:AddLine(' ')
                        tooltip:AddDoubleLine('dungeonID '..description.data.dungeonID, e.Get_Instance_Num(description.data.dungeonName),nil)
                    end)

                    sub:AddInitializer(Add_Initializer)

                else
                    sub=root:CreateButton('   |cff9e9e9e'..e.cn(name)..' |r', function()
                        return MenuResponse.Open
                    end, {
                        dungeonID=dungeonID,
                        dungeonName=name
                    })

                    sub:SetTooltip(function(tooltip, description)
                        tooltip:AddLine(e.cn(description.data.dungeonName)..' ')
                        tooltip:AddLine(' ')
                        tooltip:AddLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '你不能进入此队列。' or YOU_MAY_NOT_QUEUE_FOR_THIS))
                        local declined= LFGConstructDeclinedMessage(description.data.dungeonID)
                        if declined and declined~='' then
                            tooltip:AddLine('|cnRED_FONT_COLOR:'..e.cn(declined), nil,nil,nil, true)
                        end
                        tooltip:AddLine(' ')
                        tooltip:AddDoubleLine('dungeonID '..description.data.dungeonID, e.Get_Instance_Num(description.data.dungeonName),nil)
                    end)
                end
                find=true
            end
        end
    end
    if find then
        root:CreateDivider()
    end
end




















--场景
local function Init_Scenarios_Menu(root)--ScenarioFinder.lua
    if not PlayerGetTimerunningSeasonID() then
       return
    end

    local sub, find
    for i=1, GetNumRandomScenarios() do
        --local id, name, typeID, subtype, minLevel, maxLevel= GetRandomScenarioInfo(i)
        local scenarioID, name = GetRandomScenarioInfo(i)
        if scenarioID and name then
            local isAvailableForAll, isAvailableForPlayer = IsLFGDungeonJoinable(scenarioID)
            if isAvailableForAll and isAvailableForPlayer then
                sub=root:CreateButton(e.cn(name, {scenarioID=scenarioID, isName=true}), function(description)
                    if GetLFGQueueStats(LE_LFG_CATEGORY_SCENARIO) then--not ( mode == "queued" or mode == "listed" or mode == "rolecheck" or mode == "suspended" ) then
                        LeaveLFG(LE_LFG_CATEGORY_SCENARIO)
                    else
                        LFG_JoinDungeon(LE_LFG_CATEGORY_SCENARIO, description.dungeonID, ScenariosList, ScenariosHiddenByCollapseList)--ScenarioQueueFrame_Join() 
                        Set_LFDButton_Data(description.dungeonID, LE_LFG_CATEGORY_LFD, description.dungeonName, nil)--设置图标, 点击,提示
                    end
                    return MenuResponse.Open

                end, {
                    dungeonID=scenarioID,
                    dungeonName=name,
                    type=LE_LFG_CATEGORY_SCENARIO,
                })

                sub:SetTooltip(function(tooltip, description)
                    tooltip:AddLine(description.data.dungeonName)
                    tooltip:AddLine(' ')
                    tooltip:AddDoubleLine('scenarioID '..description.data.dungeonID, e.Get_Instance_Num(description.data.dungeonName), nil)
                end)

                sub:AddInitializer(Add_Initializer)

            else
                sub=root:CreateButton('     |cff9e9e9e'..e.cn(name)..' |r', function()
                    return MenuResponse.Open
                end, {
                    dungeonID=scenarioID,
                    dungeonName=name,
                })

                sub:SetTooltip(function(tooltip, description)
                    tooltip:AddLine(e.cn(description.data.dungeonName))
                    tooltip:AddLine(' ')
                    tooltip:AddLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '你不能进入此队列。' or YOU_MAY_NOT_QUEUE_FOR_THIS))
                    local text= LFGConstructDeclinedMessage(description.data.dungeonID)
                    if text and text~='' then
                        tooltip:AddLine('|cnRED_FONT_COLOR:'..e.cn(text))
                    end
                    tooltip:AddLine(' ')
                    tooltip:AddDoubleLine('scenarioID '..description.data.dungeonID, e.Get_Instance_Num(description.data.dungeonName), nil)
                end)
            end
            find=true
        end
    end
    if find then
        root:CreateDivider()
    end
end
























--RaidFinder.lua
local function isRaidFinderDungeonDisplayable(dungeonID)
    local _, _, _, minLevel, maxLevel, _, _, _, expansionLevel = GetLFGDungeonInfo(dungeonID)
    local myLevel = e.Player.level
    return myLevel >= minLevel and myLevel <= maxLevel and EXPANSION_LEVEL >= expansionLevel
end








--团队本
local function set_Raid_Menu_List(root)
    local sortedDungeons= {}

    local function InsertDungeonData(dungeonID, name, mapName, isAvailable, mapID)
        local tab = { id = dungeonID, name = name, mapName = mapName, isAvailable = isAvailable, mapID = mapID }
        local foundMap = false
        for i = 1, #sortedDungeons do
            if ( sortedDungeons[i].mapName == mapName ) then
                foundMap = true
            else
                if ( foundMap ) then
                    tinsert(sortedDungeons, i, tab)
                    return
                end
            end
        end
        tinsert(sortedDungeons, tab)
    end

    for i=1, GetNumRFDungeons() do
        local dungeonInfo = { GetRFDungeonInfo(i) }
        local dungeonID = dungeonInfo[1]
        local name = dungeonInfo[2]
        local mapName = dungeonInfo[20]
        local mapID = dungeonInfo[23]
        if dungeonID and name then
            local isAvailable, isAvailableToPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(dungeonID)
            if name and (not hideIfNotJoinable or isAvailable)
                and (isAvailable or isAvailableToPlayer or isRaidFinderDungeonDisplayable(dungeonID))
            then
                InsertDungeonData(dungeonID, name, mapName, isAvailable, mapID)
            end
        end
    end


    local currentMapName, find, sub, icon
    local scenarioInfo = C_ScenarioInfo.GetScenarioInfo() or {}
    local scenarioName= scenarioInfo.name--场景名称
    if scenarioName then
        scenarioName= strlower(scenarioName)
    end
    local LfgDungeonID = select(10, GetInstanceInfo())


    for i = 1, #sortedDungeons do
        if ( currentMapName ~= sortedDungeons[i].mapName ) then
            currentMapName = sortedDungeons[i].mapName
            icon=select(11, GetLFGDungeonInfo(sortedDungeons[i].id))
            icon= icon and '|T'..icon..':0|t' or ''
            root:CreateTitle(icon..e.cn(sortedDungeons[i].mapName))
        end

        local dungeonID= sortedDungeons[i].id
        local dungeonName= sortedDungeons[i].name
        local dungeonMapID= sortedDungeons[i].mapID

        local modifiedDesc, modifiedIcon
        if dungeonMapID then
            local modifiedInstanceInfo = C_ModifiedInstance.GetModifiedInstanceInfoFromMapID(dungeonMapID)
            if (modifiedInstanceInfo) then
                modifiedIcon = '|A:'..GetFinalNameFromTextureKit("%s-small", modifiedInstanceInfo.uiTextureKit)..':0:0|a'
                modifiedDesc = e.cn(modifiedInstanceInfo.description)--, {lfgDungeonID=dungeonID, isDesc=true})
            end
        end

        if  sortedDungeons[i].isAvailable then

            local killText=''
            local bossTab={}
            local bossKillText=''
            local isKillAll=false

            local bossNum= GetLFGDungeonNumEncounters(dungeonID) or 0
            local killNum=0
            if bossNum>0 then
                for encounterIndex= 1, bossNum, 1 do
                    local bossName, texture, isKilled = GetLFGDungeonEncounterInfo(dungeonID, encounterIndex)
                    if isKilled then
                        killNum= killNum+1
                        killText= killText..' |cff9e9e9ex|r'
                    else
                        killText= killText..' '..encounterIndex
                    end
                    table.insert(bossTab,
                        (texture and '|T'..texture..':0|t' or '')
                        ..(isKilled and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:')
                        ..e.cn(bossName)
                    )
                end
                bossKillText = format(e.onlyChinese and '已消灭 |cnGREEN_FONT_COLOR:%d|r/%d 个首领' or BOSSES_KILLED, killNum, bossNum)
                isKillAll= bossNum==killNum
            end

            sub=root:CreateButton(
                ((LfgDungeonID==dungeonID or scenarioName== strlower(dungeonName)) and '|A:auctionhouse-icon-favorite:0:0|a' or '')--在当前副本
                ..(modifiedIcon or '')
                ..(isKillAll and '|cff9e9e9e' or '')
                ..e.cn(dungeonName)
                ..get_Reward_Info(dungeonID)--名称
                ..killText,
            function(data)
                if GetLFGQueueStats(LE_LFG_CATEGORY_RF, data.dungeonID) then
                    LeaveSingleLFG(LE_LFG_CATEGORY_RF, data.dungeonID)
                else
                    e.call(RaidFinderQueueFrame_SetRaid, data.dungeonID)
                    e.call(RaidFinderQueueFrame_Join)
                    --printListInfo()--输出当前列表
                    Set_LFDButton_Data(data.dungeonID, LE_LFG_CATEGORY_RF, e.cn(data.dungeonName), nil)--设置图标, 点击,提示
                end
                return MenuResponse.Open

            end, {
                dungeonID=dungeonID,
                dungeonName=dungeonName,
                dungeonMapID=dungeonMapID,

                modifiedDesc=modifiedDesc,
                type=LE_LFG_CATEGORY_RF,

                bossKillText=bossKillText,
                bossTab=bossTab,
            })

            sub:SetTooltip(function(tooltip, description)
                tooltip:AddLine(e.cn(description.data.dungeonName)..' ')
                tooltip:AddLine(description.data.bossKillText)
                tooltip:AddLine(' ')
                for index, text in pairs(description.data.bossTab) do
                    tooltip:AddLine(index..') '..text)
                end
                if description.data.modifiedDesc then
                    tooltip:AddLine(' ')
                    tooltip:AddLine(description.data.modifiedDesc, nil,nil,nil, true)
                end
                tooltip:AddLine(' ')
                tooltip:AddDoubleLine('dungeonID '..description.data.dungeonID, e.Get_Instance_Num(description.data.dungeonName), nil)
            end)

            sub:AddInitializer(Add_Initializer)

        else
            sub=root:CreateButton((modifiedIcon or '')..'|cff9e9e9e'..e.cn(dungeonName)..' |r', function()
                return MenuResponse.Open
             end, {modifiedDesc=modifiedDesc, dungeonID=dungeonID}
            )
            sub:SetTooltip(function(tooltip, description)
                tooltip:AddLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '你不能进入此队列。' or YOU_MAY_NOT_QUEUE_FOR_THIS))
                local msg= LFGConstructDeclinedMessage(description.data.dungeonID)
                if msg then
                    tooltip:AddLine('|cnRED_FONT_COLOR:'..e.cn(msg), 0.62, 0.62, 0.62, true)
                end
                if description.data.modifiedDesc then
                    tooltip:AddLine(' ')
                    tooltip:AddLine(e.cn(description.data.modifiedDesc), nil, nil, nil, true)
                end
                tooltip:AddLine(' ')
                tooltip:AddDoubleLine('dungeonID '..description.data.dungeonID, e.Get_Instance_Num(description.data.dungeonName),nil)
            end)

        end
        find=true
    end

    if find then
        root:CreateDivider()
    end
end


































--预创建队伍增强
local function getIndex(values, val)
    local index={}
    for k,v in pairs(values) do
        index[v]=k
    end
    return index[val]
end

local function Init_LFGListSearchEntry_Update(self)
    local resultID = self.resultID
    if not resultID or not C_LFGList.HasSearchResultInfo(resultID) then
        return
    end

    local info = C_LFGList.GetSearchResultInfo(resultID)
    local categoryID= LFGListFrame.SearchPanel.categoryID
    local _, appStatus, pendingStatus = C_LFGList.GetApplicationInfo(resultID)
    local isAppFinished = LFGListUtil_IsStatusInactive(appStatus) or LFGListUtil_IsStatusInactive(pendingStatus) or info.isDelisted

    local text, color, autoAccept = '', nil, nil
    if not isAppFinished then
        text, color= e.GetKeystoneScorsoColor(info.leaderOverallDungeonScore, true)--地下城, 分数
        if info.leaderPvpRatingInfo and info.leaderPvpRatingInfo.rating and info.leaderPvpRatingInfo.rating>0 then--PVP, 分数
            local text2, color2=e.GetKeystoneScorsoColor(info.leaderPvpRatingInfo.rating)
            local icon= info.leaderPvpRatingInfo.tier and info.leaderPvpRatingInfo.tier>0 and ('|A:honorsystem-icon-prestige-'..info.leaderPvpRatingInfo.tier..':0:0|a') or '|A:pvptalents-warmode-swords:0:0|a'
            if info.isWarMode then
                text= icon..text2..' '..text
            else
                text= text..' '..icon..text2
            end
            color= info.isWarMode and color2 or color

        end
        color= color or {r=1,g=1,b=1}
        if info.numBNetFriends and info.numBNetFriends>0 then--好友, 数量
            text= text..' '..format('|T%d:0|t', e.Icon.wow)..info.numBNetFriends
        end
        if info.numCharFriends and info.numCharFriends>0 then--好友, 数量
            text= text..' |A:socialqueuing-icon-group:0:0|a'..info.numCharFriends
        end
        if info.numGuildMates and info.numGuildMates>0 then--好友, 数量
            text= text..' |A:UI-HUD-MicroMenu-GuildCommunities-Mouseover:0:0|a'..info.numCharFriends
        end
        autoAccept= info.autoAccept--自动, 邀请
    end
    if text~='' and not self.scorsoText then
        self.scorsoText= e.Cstr(self, {justifyH='RIGHT'})
        self.scorsoText:SetPoint('TOPLEFT', self.DataDisplay.Enumerate, 0, 5)
        --self.scorsoText:SetPoint('RIGHT', self.DataDisplay.Enumerate.Icon5, 'LEFT', -2, 0)
    end
    if self.scorsoText then
        self.scorsoText:SetText(text)
        if color then
            self.Name:SetTextColor(color.r, color.g, color.b)
        end
    end
    if autoAccept and not self.autoAcceptTexture then--自动, 邀请
        self.autoAcceptTexture=self:CreateTexture(nil,'OVERLAY')
        self.autoAcceptTexture:SetPoint('LEFT')
        self.autoAcceptTexture:SetAtlas(e.Icon.select)
        self.autoAcceptTexture:SetSize(12,12)
        self.autoAcceptTexture:EnableMouse(true)
        self.autoAcceptTexture:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddLine(e.onlyChinese and '自动接受' or LFG_LIST_AUTO_ACCEPT)
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
        end)
        self.autoAcceptTexture:SetScript("OnLeave", GameTooltip_Hide)
    end
    if self.autoAcceptTexture then
        self.autoAcceptTexture:SetShown(autoAccept)
    end

    local realm, realmText
    if info.leaderName and not isAppFinished then
        local server= info.leaderName:match('%-(.+)') or e.Player.realm
        server=e.Get_Region(server)--服务器，EU， US {col, text}
        realm= server and server.col
        realmText=server and server.realm
    end
    if realm and not self.realmText then
        self.realmText= e.Cstr(self)
        self.realmText:SetPoint('BOTTOMRIGHT', self.DataDisplay.Enumerate,0,-3)
        self.realmText:EnableMouse(true)
        self.realmText:SetScript('OnEnter', function(self2)
            if self2.realm then
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.onlyChinese and '服务器' or 'Realm', '|cnGREEN_FONT_COLOR:'..self2.realm)
                e.tips:AddDoubleLine(id, addName)
                e.tips:Show()
            end
        end)
        self.realmText:SetScript("OnLeave", GameTooltip_Hide)
    end

    if self.realmText then
        self.realmText.realm= realmText
        self.realmText:SetText(realm or '')
    end

    if not self.OnDoubleClick then
        self:SetScript('OnDoubleClick', function()--LFGListApplicationDialogSignUpButton_OnClick(LFDButton) LFG队长分数, 双击加入 LFGListSearchPanel_UpdateResults
            if LFGListFrame.SearchPanel.SignUpButton:IsEnabled() then
                LFGListFrame.SearchPanel.SignUpButton:Click()
            end
            local frame=LFGListApplicationDialog
            if not frame.TankButton.CheckButton:GetChecked() and not frame.HealerButton.CheckButton:GetChecked() and not frame.DamagerButton.CheckButton:GetChecked() then
                local specID=GetSpecialization()--当前专精
                if specID then
                    local role = select(5, GetSpecializationInfo(specID))
                    if role=='DAMAGER' and frame.DamagerButton:IsShown() then
                        frame.DamagerButton.CheckButton:SetChecked(true)

                    elseif role=='TANK' and frame.TankButton:IsShown() then
                        frame.TankButton.CheckButton:SetChecked(true)

                    elseif role=='HEALER' and frame.HealerButton:IsShown() then
                        frame.HealerButton.CheckButton:SetChecked(true)
                    end
                    LFGListApplicationDialog_UpdateValidState(frame)
                end
            end
            if frame:IsShown() and frame.SignUpButton:IsEnabled() then
                frame.SignUpButton:Click()
            end
        end)
    end

    local orderIndexes = {}
    if categoryID == 2 and not isAppFinished then--_G["ShowRIORaitingWA1NotShowClasses"] ~= true--https://wago.io/klC4qqHaF
        for i=1, info.numMembers do
            --local role, class, classLocalized, specLocalized, isLeader = C_LFGList.GetSearchResultMemberInfo(resultID, i)
            local role, class, _, specLocalized, isLeader = C_LFGList.GetSearchResultMemberInfo(resultID, i)
            local orderIndex = getIndex(LFG_LIST_GROUP_DATA_ROLE_ORDER, role)
            table.insert(orderIndexes, {orderIndex, class, specLocalized, isLeader})
        end
        table.sort(orderIndexes, function(a,b) return a[1] < b[1] end)
    end
    --local xOffset = -88
    for i = 1, 5 do
        local class, specLocalized, isLeader
        if orderIndexes[i] then
            class= e.Class(nil, orderIndexes[i][2], true)
            specLocalized= orderIndexes[i][3]
            isLeader= orderIndexes[i][4]
        end
        local texture = self.DataDisplay.Enumerate["tex"..i]
        if not texture then
            texture = self.DataDisplay.Enumerate:CreateTexture(nil, "OVERLAY")
            self.DataDisplay.Enumerate["tex"..i]= texture
            texture:EnableMouse(true)
            texture:SetSize(12, 14)
            texture:SetPoint("RIGHT", self.DataDisplay.Enumerate, -106+i*18 ,-12)--xOffset, -10)
            texture:SetScript('OnLeave', function(f) f:SetAlpha(1) end)
            texture:SetScript('OnEnter', function(f)
                if f.specLocalized then
                    e.tips:SetOwner(f, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:AddLine(f.specLocalized)
                    e.tips:Show()
                end
                f:SetAlpha(0.5)
            end)
            texture.leader = self.DataDisplay.Enumerate:CreateTexture(nil, "OVERLAY")
            texture.leader:SetPoint('CENTER', texture, 0, 0)
            texture.leader:SetAlpha(0.5)
            texture.leader:SetAtlas('Forge-ColorSwatchSelection')
            texture.leader:SetSize(16,16)

            self.DataDisplay.Enumerate["tex"..i]= texture
        end
        if class then
            texture:SetAtlas(class)
        else
            texture:SetTexture(0)
        end
        texture.leader:SetShown(isLeader)
        texture.specLocalized= specLocalized
        --xOffset = xOffset + 18
    end
end
















--预创建队伍增强, 提示
local function Init_LFGListUtil_SetSearchEntryTooltip(tooltip, resultID, autoAcceptOption)
    if not Save.LFGPlus then
        return
    end
    local info = C_LFGList.GetSearchResultInfo(resultID)
    local _, appStatus, pendingStatus = C_LFGList.GetApplicationInfo(resultID)
    local isAppFinished = LFGListUtil_IsStatusInactive(appStatus) or LFGListUtil_IsStatusInactive(pendingStatus) or info.isDelisted
    if isAppFinished then
        return
    end
    local tab={}
    for i=1, info.numMembers do
        local role, classFile = C_LFGList.GetSearchResultMemberInfo(resultID, i)
        if classFile then
            tab[classFile]= tab[classFile] or {num=0, role={}}
            tab[classFile].num= tab[classFile].num +1
            table.insert(tab[classFile].role, {role=role, index= role=='TANK' and 1 or role=='HEALER' and 2 or 3})
        end
    end
    tooltip:AddLine(' ')
    for i=1,  GetNumClasses() do
        local classInfo = C_CreatureInfo.GetClassInfo(i)
        if classInfo and classInfo.classFile then
            local col='|c'..select(4, GetClassColor(classInfo.classFile))
            local text
            if tab[classInfo.classFile] then
                local num=tab[classInfo.classFile].num
                text= ' '..col..num..'|r'
                local roleText=' '
                table.sort(tab[classInfo.classFile].role, function(a,b) return a.index< b.index end)
                for _, role in pairs(tab[classInfo.classFile].role) do
                    if e.Icon[role.role] then
                        roleText= roleText..e.Icon[role.role]
                    end
                end
                text= text.. roleText
            end
            tooltip:AddDoubleLine(e.Class(nil, classInfo.classFile).. (text or ''), col..i)
        end
    end
    tooltip:AddLine(' ')
    tooltip:AddDoubleLine(e.onlyChinese and '申请' or SIGN_UP, (e.onlyChinese and '双击' or BUFFER_DOUBLE)..e.Icon.left, 0,1,0, 0,1,0)
    tooltip:AddDoubleLine(id, addName)
    tooltip:Show()
end

local function set_LFDButton_LFGPlus_Texture()--预创建队伍增强
    if not LFDButton.LFGPlus then
        LFDButton.LFGPlus= e.Cbtn(LFGListFrame, {size={20, 20}, atlas= Save.LFGPlus and e.Icon.icon or e.Icon.disabled})
        if _G['MoveZoomInButtonPerPVEFrame'] then
            LFDButton.LFGPlus:SetPoint('RIGHT', _G['MoveZoomInButtonPerPVEFrame'], 'LEFT')
        else
            LFDButton.LFGPlus:SetPoint('LEFT', PVEFrame.TitleContainer)
        end
        LFDButton.LFGPlus:SetFrameLevel(PVEFrame.TitleContainer:GetFrameLevel()+1)
        LFDButton.LFGPlus:SetAlpha(0.5)
        function LFDButton.LFGPlus:set_texture()
            self:SetNormalAtlas(Save.LFGPlus and e.Icon.icon or e.Icon.disabled)
        end
        LFDButton.LFGPlus:SetScript('OnClick', function(self)
            Save.LFGPlus= not Save.LFGPlus and true or nil
            self:set_texture()
            print(e.addName,addName, e.GetEnabeleDisable(Save.LFGPlus), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
        end)
        LFDButton.LFGPlus:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(0.5) end)
        LFDButton.LFGPlus:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(not e.onlyChinese and LFGLIST_NAME..' Plus'  or '预创建队伍增强', e.GetEnabeleDisable(Save.LFGPlus))
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
            self2:SetAlpha(1)
        end)
    end
end









































local ExitIns
local function exit_Instance()
    local ins = IsInInstance()
    if not ExitIns or not ins or IsModifierKeyDown() or LFGDungeonReadyStatus:IsVisible() or LFGDungeonReadyDialog:IsVisible() then
        ExitIns= nil
        StaticPopup_Hide(addName..'ExitIns')
        return
    end
    local name= GetInstanceInfo()

    Save_Instance_Num(name)

    local num= e.Get_Instance_Num(name)

    if IsInLFDBattlefield() then
        local currentMapID, _, lfgID = select(8, GetInstanceInfo())
        local _, _, subtypeID, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, lfgMapID = GetLFGDungeonInfo(lfgID)
        if currentMapID == lfgMapID and subtypeID == LE_LFG_CATEGORY_BATTLEFIELD then
            LFGTeleport(true)
        end
    else
        C_PartyInfo.LeaveParty(LE_PARTY_CATEGORY_INSTANCE)
    end


    print(e.addName, addName,
        e.onlyChinese and '离开' or LEAVE,
        e.cn(name) or e.onlyChinese and '副本' or INSTANCE,
        num
    )
    ExitIns=nil
end

local function setIslandButton(self)--离开海岛按钮
    local find
    if IsInInstance() then
        local uiMapID= C_Map.GetBestMapForUnit("player")--当前地图 
        if uiMapID and C_FogOfWar.GetFogOfWarForMap(uiMapID) then
            find=true
        end
    end
    if find then
        if not self.island then
            self.island = e.Cbtn(nil, {type=false, size={50,25}})
            self.island:SetText(e.onlyChinese and '离开' or LEAVE)
            if Save.islandPoint then
                self.island:SetPoint(Save.islandPoint[1], UIParent, Save.islandPoint[3], Save.islandPoint[4], Save.islandPoint[5])
            else
                self.island:SetPoint('BOTTOMRIGHT', -200, 200)
            end
            self.island:SetScript('OnMouseDown', function(self2, d)
                if d=='LeftButton' then
                    C_PartyInfo.LeaveParty(LE_PARTY_CATEGORY_INSTANCE)
                    LFGTeleport(true)
                elseif d=='RightButton' then
                    SetCursor('UI_MOVE_CURSOR')
                end
            end)
            self.island:SetClampedToScreen(true)
            self.island:SetMovable(true)
            self.island:RegisterForDrag("RightButton")
            self.island:SetScript("OnDragStart", function(self2) self2:StartMoving() end)
            self.island:SetScript("OnDragStop", function(self2)
                    ResetCursor()
                    self2:StopMovingOrSizing()
                    Save.islandPoint={self2:GetPoint(1)}
                    Save.islandPoint[2]= nil
            end)
            self.island:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(id, addName)
                local num= e.Get_Instance_Num('island')
                e.tips:AddDoubleLine(e.onlyChinese and '海岛探险' or ISLANDS_HEADER, num)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(e.onlyChinese and '离开海岛' or ISLAND_LEAVE, e.Icon.left)
                e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
                e.tips:Show()
            end)
            self.island:SetScript('OnLeave', function ()
                e.tips:Hide()
            end)
        end
    end
    if self.island then
        self.island:SetShown(find)
    end
end


























local function setHoliday()--节日, 提示, LFDButton.texture
    --LFDButton.dungeonID=nil
    --LFDButton.name=nil
    local dungeonID, name, texturePath, atlas
    local group= IsInGroup(LE_PARTY_CATEGORY_HOME)
    local canTank, canHealer, canDamage = C_LFGList.GetAvailableRoles()
    for dungeonIndex=1, GetNumRandomDungeons() do
        dungeonID, name = GetLFGRandomDungeonInfo(dungeonIndex)
        if dungeonID then
            local isAvailableForAll, isAvailableForPlayer, hid2eIfNotJoinable = IsLFGDungeonJoinable(dungeonID)
            if (isAvailableForPlayer or not hid2eIfNotJoinable) and isAvailableForAll then
                --name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, textureFilename, difficulty, maxPlayers, description, isHoliday, bonusRepAmount, minPlayers, isTimeWalker, name2, minGearLevel, isScalingDungeon, lfgMapID = GetLFGDungeonInfo(dungeonID)
                if select(15, GetLFGDungeonInfo(dungeonID)) then
                    --local doneToday, moneyAmount, moneyVar, experienceGained, experienceVar, numRewards, spellID = GetLFGDungeonRewards(dungeonID)
                    local numRewards = select(6, GetLFGDungeonRewards(dungeonID))--isHoliday
                    if numRewards and numRewards>0 then--奖励物品
                        local find
                        for rewardIndex=1 , numRewards do
                            --local name, texture, numItems, isBonusReward, rewardType, rewardID, quality = GetLFGDungeonRewardInfo(dungeonID, i)
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
    Set_LFDButton_Data(dungeonID, LE_LFG_CATEGORY_LFD, e.cn(name), texturePath,  atlas)--设置图标
end



























--#######
--自动ROLL
--GroupLootFrame.lua --frame.rollTime  frame.Timer
local function Roll_Plus()
    local function set_RollOnLoot(rollID, rollType, link)
        RollOnLoot(rollID, rollType)
        link= link or GetLootRollItemLink(rollID)
        C_Timer.After(2, function()
            print(e.addName, addName, '|cnGREEN_FONT_COLOR:',
                rollType==1 and (e.onlyChinese and '需求' or NEED)..'|A:lootroll-toast-icon-need-up:0:0|a'
                or ((e.onlyChinese and '贪婪' or GREED)..'|A:lootroll-toast-icon-transmog-up:0:0|a'),
                link)
        end)
    end
    local function set_Timer_Text(frame)--提示，剩余时间
        if frame and frame.Timer and not frame.Timer.Text and frame:IsShown() then
            frame.Timer.Text= e.Cstr(frame.Timer)
            frame.Timer.Text:SetPoint('RIGHT')
            frame.Timer:HookScript("OnUpdate", function(self2)
                self2.Text:SetText(e.SecondsToClock(self2:GetValue()))
            end)
        end
    end
    local function set_ROLL_Check(frame)
        local rollID= frame and frame.rollID
        if not Save.autoROLL or not rollID then
            set_Timer_Text(frame)--提示，剩余时间
            return
        end

        local _, _, _, quality, _, canNeed, canGreed, canDisenchant, reasonNeed, reasonGreed, reasonDisenchant, deSkillRequired, canTransmog = GetLootRollItemInfo(rollID)

        local link = GetLootRollItemLink(rollID)

        if not canNeed or (IsInLFGDungeon() and quality and quality>=4) or not link then
            set_RollOnLoot(rollID, canNeed and 1 or 2, link)
            return
        end

        if canTransmog and not C_TransmogCollection.PlayerHasTransmogByItemInfo(link) then--幻化
            local sourceID=select(2,C_TransmogCollection.GetItemInfo(link))
            if sourceID then
                local hasItemData, canCollect =  C_TransmogCollection.PlayerCanCollectSource(sourceID)
                if hasItemData and canCollect then
                    local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
                    if sourceInfo and not sourceInfo.isCollected then
                        set_RollOnLoot(rollID, 1, link)
                        return
                    end
                end
            end
        end

        local itemID, _, _, itemEquipLoc, _, classID, subclassID = C_Item.GetItemInfoInstant(link)
        local slot=e.GetItemSlotID(itemEquipLoc)--比较装等
        if slot then
            local slotLink=GetInventoryItemLink('player', slot)
            if slotLink then
                local slotItemLevel= C_Item.GetDetailedItemLevelInfo(slotLink) or 0
                local itemLevel= C_Item.GetDetailedItemLevelInfo(link)
                if itemLevel then
                    local num=itemLevel-slotItemLevel
                    if num>0 then
                        set_RollOnLoot(rollID, 1, link)
                        return
                    end
                end
            --else--没有装备
                --set_RollOnLoot(rollID, 1, link)
                --return
            end

        elseif classID==15 and subclassID==2 then--宠物物品
            set_RollOnLoot(rollID, 1, link)
            return

        elseif classID==15 and  subclassID==5 then--坐骑
            local mountID = C_MountJournal.GetMountFromItem(itemID)
            if mountID then
                local isCollected =select(11, C_MountJournal.GetMountInfoByID(mountID))
                if not isCollected then
                    set_RollOnLoot(rollID, 1, link)
                    return
                end
            end

        elseif C_ToyBox.GetToyInfo(itemID) and not PlayerHasToy(itemID) then--玩具 
            set_RollOnLoot(rollID, 1, link)
            return

        elseif classID==0 or subclassID==0 then
            set_RollOnLoot(rollID, 1, link)
            return
        end

        set_Timer_Text(frame)--提示，剩余时间
    end

    hooksecurefunc('GroupLootContainer_AddFrame', function(_, frame)
        set_ROLL_Check(frame)
    end)

    hooksecurefunc('GroupLootContainer_Update', function(self)
        for i=1, self.maxIndex do
            local frame = self.rollFrames[i]
            if frame and frame:IsShown()  then
                set_ROLL_Check(frame)
            end
        end
    end)

end






























--###########
--历史, 拾取框
--LootHistory.lua
local function Loot_Plus()
    local function set_LootFrame_btn(btn)
        if not btn then
            return
        elseif not btn.dropInfo or Save.disabledLootPlus then
            if btn.chatTexure then
                btn.chatTexure:SetShown(false)
            end
            if btn.itemSubTypeLabel then
                btn.itemSubTypeLabel:SetText("")
            end
            btn:SetAlpha(1)
            --btn.WinningRollInfo.Check:SetAlpha(1)
            e.Set_Item_Stats(btn.Item)
            return
        end



        if not btn.chatTexure then
            btn.chatTexure= e.Cbtn(btn, {size={18,18}, atlas='transmog-icon-chat'})
            btn.chatTexure:SetPoint('BOTTOMRIGHT', btn, 6, 4)
            btn.chatTexure:SetScript('OnLeave', GameTooltip_Hide)
            function btn.chatTexure:get_playerinfo()
                local p=self:GetParent().dropInfo or {}
                return p.winner or p.currentLeader or {}
            end

            function btn.chatTexure:get_text()
                local p= self:GetParent().dropInfo
                local nu=''
                if IsInRaid() then
                    for i=1, MAX_RAID_MEMBERS do
                        local name, _, subgroup= GetRaidRosterInfo(i)
                        if name==e.Player.name then
                            if subgroup then
                                nu= ' '..subgroup..GROUP
                            end
                            break
                        end
                    end
                end
                return (not p or p.playerRollState==Enum.EncounterLootDropRollState.Greed) and ''
                        or ((e.Player.region==1 or e.Player.region==3) and ' need, pls{rt1}'..nu)
                        or (e.Player.region==5 and ' 您好，我很需求这个，能让让吗？谢谢{rt1}'..nu)
                        or (' '..NEED..', '..VOICEMACRO_LABEL_THANKYOU3..'{rt1}'..nu)
            end
            function btn.chatTexure:get_playername()
                local info= self:get_playerinfo()
                local playerName= info.playerName
                if playerName and info.playerGUID and not playerName:find('%-') then
                    local realm= select(7,GetPlayerInfoByGUID(info.playerGUID))
                    if realm and realm~='' and realm~=e.Player.realm then
                        playerName= playerName..'-'..realm
                    end
                end
                return playerName
            end
            btn.chatTexure:SetScript('OnEnter', function(self)
                local p= self:GetParent()
                e.tips:SetOwner(self, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                if p.dropInfo.startTime then
                    local startTime= '|cnRED_FONT_COLOR:'..(e.GetTimeInfo(p.dropInfo.startTime/1000, false, nil) or '')
                    local duration= p.dropInfo.duration and '|cnGREEN_FONT_COLOR:'..format(e.onlyChinese and '持续时间：%s' or PROFESSIONS_CRAFTING_FORM_CRAFTER_DURATION_REMAINING, SecondsToTime(p.dropInfo.duration/100))
                    e.tips:AddDoubleLine(startTime, duration)
                    e.tips:AddLine(' ')
                end
                e.tips:AddDoubleLine(SLASH_SMART_WHISPER2..' '..(self:get_playername() or ''), (p.dropInfo.itemHyperlink or '')..(self:get_text() or ''))
                e.tips:AddLine(' ')
                if GroupLootHistoryFrame.selectedEncounterID then
                    e.tips:AddDoubleLine('EncounterID', GroupLootHistoryFrame.selectedEncounterID)
                end
                e.tips:AddDoubleLine(id, addName)
                e.tips:Show()
            end)
            btn.chatTexure:SetScript('OnClick', function(self)
                local p=self:GetParent().dropInfo or {}
                e.Say(nil, self:get_playername(), nil, (p.itemHyperlink or '').. (self:get_text() or ''))

            end)

            if btn.WinningRollInfo and btn.WinningRollInfo.Check and not btn.WinningRollInfo.Check.move then--移动, √图标
                btn.WinningRollInfo.Check:ClearAllPoints()
                btn.WinningRollInfo.Check:SetPoint('BOTTOMRIGHT', btn, 8, -2)
                btn.WinningRollInfo.Check.move=true
            end
        end

        local notGreed= btn.dropInfo.playerRollState ~= Enum.EncounterLootDropRollState.Greed
        local winInfo= btn.chatTexure:get_playerinfo()
        btn.chatTexure:SetShown(not winInfo.isSelf and winInfo.isSelf~=nil)
        --btn.chatTexure:SetAlpha(notGreed and 1 or 0.3)
        --btn.WinningRollInfo.Check:SetAlpha(notGreed and 1 or 0.3)
        btn:SetAlpha(winInfo.isSelf and 0.3 or (not notGreed and 0.5) or 1)


        if winInfo and notGreed then--修改，名字
            if winInfo.isSelf then
                btn.WinningRollInfo.WinningRoll:SetText(e.Player.col..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)..'|r')
            elseif winInfo.playerGUID then
                local name= e.GetPlayerInfo({guid=winInfo.playerGUID, reName=true})
                if name and name~='' then
                    btn.WinningRollInfo.WinningRoll:SetText(name)
                end
            end
        end

        e.Set_Item_Stats(btn.Item, notGreed and btn.dropInfo.itemHyperlink, {point= btn.Item and btn.Item.IconBorder})--设置，物品，4个次属性，套装，装等

        local text
        if not btn.itemSubTypeLabel then
            btn.itemSubTypeLabel= e.Cstr(btn, {color=true})
            btn.itemSubTypeLabel:SetPoint('BOTTOMLEFT', btn.Item.IconBorder, 'BOTTOMRIGHT',4,-8)
        end
        if btn.dropInfo.itemHyperlink and notGreed then
            local _, _, itemSubType2, itemEquipLoc, _, _, subclassID = C_Item.GetItemInfoInstant(btn.dropInfo.itemHyperlink)--提示,装备,子类型
            local collected, _, isSelfCollected= e.GetItemCollected(btn.dropInfo.itemHyperlink, nil, false)--物品是否收集
            text= subclassID==0 and itemEquipLoc and e.cn(_G[itemEquipLoc]) or e.cn(itemSubType2)
            if isSelfCollected and collected then
                text= text..' '..collected
            end

            if btn.dropInfo.startTime and notGreed then
                text= text..' |cnRED_FONT_COLOR:'..e.GetTimeInfo(btn.dropInfo.startTime/1000, true, nil)..'|r'
            end
        end
        if btn.itemSubTypeLabel then
            btn.itemSubTypeLabel:SetText(text or '')
        end
    end
    hooksecurefunc(LootHistoryElementMixin, 'Init', set_LootFrame_btn)
    hooksecurefunc(GroupLootHistoryFrame.ScrollBox, 'SetScrollTargetOffset', function(self)
        if not self:GetView() then
            return
        end
        for _, btn in pairs(self:GetFrames()) do
            set_LootFrame_btn(btn)
        end
    end)


    local btn= e.Cbtn(GroupLootHistoryFrame.TitleContainer, {size={18,18}, icon='hide'})
    if _G['MoveZoomInButtonPerGroupLootHistoryFrame'] then
        btn:SetPoint('RIGHT', _G['MoveZoomInButtonPerGroupLootHistoryFrame'], 'LEFT')
    else
        btn:SetPoint('LEFT')
    end
    function btn:Set_Atlas()
        if Save.disabledLootPlus then
            self:SetNormalAtlas(e.Icon.disabled)
        else
            self:SetNormalAtlas('communities-icon-notification')
        end
    end
    btn:Set_Atlas()
    btn:SetScript('OnClick', function(self2)
        Save.disabledLootPlus= not Save.disabledLootPlus and true or nil
        self2:Set_Atlas()
        if GroupLootHistoryFrame.selectedEncounterID then
            GroupLootHistoryFrame:DoFullRefresh()
        end
    end)
    btn:SetAlpha(0.5)
    btn:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(0.5) end)
    btn:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '战利品 Plus' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LOOT, 'Plus'), e.GetEnabeleDisable(not Save.disabledLootPlus))
        e.tips:AddLine(' ')
        local  encounterID= GroupLootHistoryFrame.selectedEncounterID
        local info= encounterID and C_LootHistory.GetInfoForEncounter(encounterID)
        if info then
            e.tips:AddDoubleLine('encounterName', info.encounterName)
            e.tips:AddDoubleLine('encounterID', info.encounterID)
            e.tips:AddDoubleLine('startTime', e.SecondsToClock(info.startTime))
            e.tips:AddDoubleLine('duration', info.duration and SecondsToTime(info.duration/100))
        else
            e.tips:AddDoubleLine('encounterID', e.onlyChinese and '无' or NONE)
        end
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, 'Tools '..addName)
        e.tips:Show()
        self2:SetAlpha(1)
    end)
end






















--#############
--职责确认，信息
--#############
local RoleC
local function get_Role_Info(env, Name, isT, isH, isD)
    if env=='LFG_ROLE_CHECK_DECLINED' then
        if LFDButton.RoleInfo then
            LFDButton.RoleInfo.text:SetText('')
            LFDButton.RoleInfo:Hide()
        end
        local co=GetNumGroupMembers()
        if co and co>0 then
            local find
            local u= IsInRaid() and 'raid' or 'party'
            for i=1, co do
                local unit=u..i
                if UnitExists(unit) and not UnitIsUnit('player', unit) then
                    local guid=UnitGUID(unit)
                    local line= e.PlayerOnlineInfo(unit)
                    if line and guid then
                        print(i..')',
                                line,
                                e.GetPlayerInfo({guid=guid, faction=UnitFactionGroup(unit), reLink=true}),
                                '|A:poi-islands-table:0:0|a',
                                e.GetUnitMapName(unit)
                            )
                        find=true
                    end
                end
            end
            if find then
                print(e.addName, addName)
            end
        end
        return

    elseif env=='UPDATE_BATTLEFIELD_STATUS' or env=='LFG_QUEUE_STATUS_UPDATE' or env=='GROUP_LEFT' or env=='PLAYER_ROLES_ASSIGNED' then
        if LFDButton.RoleInfo then
            LFDButton.RoleInfo.text:SetText('')
            LFDButton.RoleInfo:Hide()
            RoleC=nil
        end
        return
    end

    if not Name or not (isT or  isH or  isD) then
        return
    end

    if env=='LFG_ROLE_CHECK_ROLE_CHOSEN' then--队长重新排本
        if RoleC and RoleC[Name] then
            local u=RoleC[Name].unit
            if u and UnitIsGroupLeader(u) then
                RoleC=nil
            end
        end
    end

    local co=GetNumGroupMembers()
    if co and co>0 then
        if not RoleC then
            RoleC={}
            local raid=IsInRaid()
            local u= raid and 'raid' or 'party'
            for i=1, co do
                local u2=u..i
                if not raid and i==co then
                    u2='player'
                end
                local guid= UnitExists(u2) and UnitGUID(u2)
                if guid then
                    local info=(e.PlayerOnlineInfo(u2) or '')
                                ..e.GetPlayerInfo({guid=guid, unit=u2, reName=true, reRealm=true})
                    local name=GetUnitName(u2,true)
                    local player=UnitIsUnit('player', u2)
                    RoleC[name]={
                        info=info,
                        index=i,
                        unit=u2,
                        player=player,
                    }
                end
            end
        end

        local all=0
        local role=''
        if RoleC[Name] then
            if isT then role=role..INLINE_TANK_ICON end
            if isH then role=role..INLINE_HEALER_ICON end
            if isD then role=role..INLINE_DAMAGER_ICON end
            RoleC[Name].role=role
        else
            all=1
        end

        local m=''
        local playerMapID=select(2, e.GetUnitMapName('player'))
        for k, v in pairs(RoleC) do
            if v then
                if m~='' then m=m..'|n' end
                m=m..(v.role and v.role or v.index..')')..(v.info or k)
                if v.role then
                    all=all+1
                end
                local text, unitMapID=e.GetUnitMapName(v.unit)
                if text and unitMapID~= playerMapID then
                    m=m..'|cnRED_FONT_COLOR:|A:poi-islands-table:0:0|a'..text..'|r'
                end
            end
        end

        if m~='' and not LFDButton.RoleInfo then
            LFDButton.RoleInfo=e.Cbtn(nil, {icon='hide', size={20,20}})
            if Save.RoleInfoPoint then
                LFDButton.RoleInfo:SetPoint(Save.RoleInfoPoint[1], UIParent, Save.RoleInfoPoint[3], Save.RoleInfoPoint[4], Save.RoleInfoPoint[5])
            else
                LFDButton.RoleInfo:SetPoint('TOPLEFT', LFDButton, 'BOTTOMLEFT', 40, 40)
                LFDButton.RoleInfo:SetButtonState('PUSHED')
            end
            LFDButton.RoleInfo:RegisterForDrag("RightButton")
            LFDButton.RoleInfo:SetMovable(true)
            LFDButton.RoleInfo:SetClampedToScreen(true)
            LFDButton.RoleInfo:SetScript("OnDragStart", function(self)
                self:StartMoving()
            end)
            LFDButton.RoleInfo:SetScript("OnDragStop", function(self)
                ResetCursor()
                self:StopMovingOrSizing()
                Save.RoleInfoPoint={self:GetPoint(1)}
                Save.RoleInfoPoint[2]=nil
            end)
            LFDButton.RoleInfo:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(id, addName)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(e.onlyChinese and '全部清除' or CLEAR_ALL, e.Icon.left)
                e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
                e.tips:Show()
            end)
            LFDButton.RoleInfo:SetScript('OnLeave', GameTooltip_Hide)
            LFDButton.RoleInfo:SetScript('OnMouseDown', function(self, d)
                if d=='RightButton' then--移动光标
                    SetCursor('UI_MOVE_CURSOR')
                elseif d=='LeftButton' then
                    self.text:SetText('')
                    self:SetShown(false)
                end
            end)
            LFDButton.RoleInfo:SetScript("OnMouseUp", function(self)
                ResetCursor()
            end)
            LFDButton.RoleInfo.text=e.Cstr(LFDButton.RoleInfo)
            LFDButton.RoleInfo.text:SetPoint('BOTTOMLEFT')--, LFDButton.RoleInfo, 'BOTTOMRIGHT')
            LFDButton.RoleInfo:SetShown(false)
        end
        if LFDButton.RoleInfo then
            LFDButton.RoleInfo.text:SetText(m)
            LFDButton.RoleInfo:SetShown(m~='')
        end

    elseif LFDButton.RoleInfo then
        LFDButton.RoleInfo:SetShown(false)
    end
end






















local function Init_RolePollPopup_Plus()
    local _, isTank, isHealer, isDPS = GetLFGRoles()--检测是否选定角色pve
    if  not isTank and not isHealer and not isDPS then
        isTank, isHealer, isDPS=true, true, true
        local sid=GetSpecialization()
        local role = sid and  select(5, GetSpecializationInfo(sid))
        if role then
            if role=='TANK' then
                isTank, isHealer, isDPS=true, false, false
            elseif role=='HEALER' then
                isTank, isHealer, isDPS=false, true, false
            elseif role=='DAMAGER' then
                isTank, isHealer, isDPS=false, false ,true
            end
        end
        SetLFGRoles(true, isTank, isHealer, isDPS)
    end
    local function set_PvPRoles()--检测是否选定角色pvp
        local tank, healer, dps = GetPVPRoles()
        if  not tank and not  healer and not dps then
            tank, healer, dps=true,true,true
            local sid=GetSpecialization()
            if sid then
                local role = select(5, GetSpecializationInfo(sid))
                if role then
                    if role=='TANK' then
                        tank, healer, dps = true, false, false
                    elseif role=='HEALER' then
                        tank, healer, dps= false, true, false
                    elseif role=='DAMAGER' then
                        tank, healer, dps= false, false,true
                    end
                end
            end
            SetPVPRoles(tank, healer, dps)
        end
    end
    set_PvPRoles()

    function LFDRoleCheckPopup:CancellORSetTime(seconds)
        if self.acceptTime then
            self.acceptTime:Cancel()
        end
        e.Ccool(self, nil, seconds, nil, true, true)--设置冷却
    end
    LFDRoleCheckPopup:HookScript("OnUpdate",function(self)--副本职责
        if IsModifierKeyDown() then
            self:CancellORSetTime(nil)
        end
    end)
    LFDRoleCheckPopup:HookScript("OnShow",function(self)--副本职责
        e.PlaySound()--播放, 声音
        if not Save.autoSetPvPRole then
            return
        end

        set_PvPRoles()--检测是否选定角色pvp
        if not LFDRoleCheckPopupAcceptButton:IsEnabled() then
            LFDRoleCheckPopup_UpdateAcceptButton()
        end
        print(e.addName, addName,
                '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '职责确认' or ROLE_POLL)..': |cfff00fff'.. SecondsToTime(sec).. '|r '..(e.onlyChinese and '接受' or ACCEPT)..'|r',
                '|cnRED_FONT_COLOR:'..'Alt '..(e.onlyChinese and '取消' or CANCEL)
            )
        self:CancellORSetTime(sec)
        self.acceptTime= C_Timer.NewTimer(sec, function()
            if LFDRoleCheckPopupAcceptButton:IsEnabled() and not IsModifierKeyDown() then
                local t=LFDRoleCheckPopupDescriptionText:GetText()
                print(e.addName, addName, '|cffff00ff', t)
                LFDRoleCheckPopupAcceptButton:Click()--LFDRoleCheckPopupAccept_OnClick
            end
        end)
    end)


    LFGDungeonReadyDialog:HookScript('OnHide', function(self)
        if self.bossTips then
            self.bossTips:SetText('')
        end
    end)
    LFGDungeonReadyDialog:HookScript('OnShow', function(self)
        local numBosses = select(9, GetLFGProposal()) or 0
        local isHoliday = select(13, GetLFGProposal())
        if ( numBosses == 0 or isHoliday) then
            return
        end
        local text
        local dead=0
        for i=1, numBosses do
            local bossName, _, isKilled = GetLFGProposalEncounter(i)
            if bossName then
                text= (text and text..'|n' or '')..i..') '
                if ( isKilled ) then
                    text= text..'|A:common-icon-redx:0:0|a|cnRED_FONT_COLOR:'..e.cn(bossName)..' '..(e.onlyChinese and '已消灭' or BOSS_DEAD)
                    dead= dead+1
                else
                    text= text..format('|A:%s:0:0|a', e.Icon.select)..'|cnGREEN_FONT_COLOR:'..e.cn(bossName)..' '..(e.onlyChinese and '可消灭' or BOSS_ALIVE)
                end
                text= text..'|r'
            end
        end
        if not self.bossTips and text then
            self.bossTips= e.Cstr(self)
            self.bossTips:SetPoint('BOTTOMLEFT', self, 'BOTTOMRIGHT', 4, 4)
        end
        if self.bossTips then
            text= text and '|cff9e9e9e'..(e.onlyChinese and '首领：' or BOSSES)..'|r'
                ..format(e.onlyChinese and '已消灭%d/%d个首领' or BOSSES_KILLED, dead, numBosses)
                ..'|n|n'..text..'|n|n|cff9e9e9e'..id..' '..addName..' ' or ''
            self.bossTips:SetText(text)
        end
    end)

    C_Timer.After(2, setHoliday)--节日, 提示, button.texture





    PVPTimerFrame:HookScript('OnShow', function(self2)
        e.PlaySound()--播放, 声音
        e.Ccool(self2, nil, BATTLEFIELD_TIMER_THRESHOLDS[3] or 60, nil, true)--冷却条
    end)
    PVPReadyDialog:HookScript('OnShow', function(self2)
        e.PlaySound()--播放, 声音
        e.Ccool(self2, nil, BATTLEFIELD_TIMER_THRESHOLDS[3] or 60, nil, true)--冷却条
    end)



    --RolePoll.lua
    RolePollPopup:HookScript('OnShow', function(self)
        e.PlaySound()--播放, 声音

        local canBeTank, canBeHealer, canBeDamager = UnitGetAvailableRoles("player")
        local specID=GetSpecialization()--当前专精
        local icon
        local btn2
        if specID then
            local role = select(5, GetSpecializationInfo(specID))
            if role=='DAMAGER' and canBeDamager then
                btn2= RolePollPopupRoleButtonDPS
                icon= e.Icon['DAMAGER']
            elseif role=='TANK' and canBeTank then
                btn2= RolePollPopupRoleButtonTank
                icon= e.Icon['TANK']
            elseif role=='HEALER' and canBeHealer then
                btn2= RolePollPopupRoleButtonHealer
                icon= e.Icon['HEALER']
            end
        end
        if btn2 then
            btn2.checkButton:SetChecked(true)
            e.call(RolePollPopupRoleButtonCheckButton_OnClick, btn2.checkButton, btn2)
            if Save.autoSetPvPRole then
                e.Ccool(self, nil, sec, nil, true)--冷却条
                self.aceTime=C_Timer.NewTimer(sec, function()
                    if self.acceptButton:IsEnabled() then
                        self.acceptButton:Click()
                        print(e.addName, addName, e.onlyChinese and '职责确认' or ROLE_POLL, icon or '')
                    end
                end)
            end
        end
    end)

    RolePollPopup:HookScript('OnUpdate', function(self)
        if IsModifierKeyDown() then
            if self.aceTime then
                self.aceTime:Cancel()
            end
            e.Ccool(self)--冷却条
        end
    end)
    RolePollPopup:HookScript('OnHide', function(self)
        if self.aceTime then
            self.aceTime:Cancel()
        end
        e.Ccool(self)--冷却条
    end)

    LFGDungeonReadyStatus:HookScript('OnShow', function()
        if Save.leaveInstance then
            exit_Instance()
        end
    end)
    LFGDungeonReadyDialog:HookScript('OnShow', function()
        if Save.leaveInstance then
            exit_Instance()
        end
    end)
end





















local function Init_Dialogs()
    StaticPopupDialogs[addName..'ExitIns']={
        text =id..' '..addName..'|n|n|cff00ff00'..(e.onlyChinese and '离开' or LEAVE)..'|r: ' ..(e.onlyChinese and '副本' or INSTANCE).. '|cff00ff00 '..sec..' |r'..(e.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS),
        button1 = e.onlyChinese and '离开' or  LEAVE,
        button2 = e.onlyChinese and '取消' or CANCEL,
        OnAccept=function()
            ExitIns=true
            exit_Instance()
        end,
        OnCancel=function(_, _, d)
            if d=='clicked' then
                ExitIns=nil
                print(e.addName,addName,'|cff00ff00'..(e.onlyChinese and '取消' or CANCEL)..'|r', e.onlyChinese and '离开' or LEAVE)
            end
        end,
        OnUpdate= function(self)
            if IsModifierKeyDown() then
                self:Hide()
                ExitIns=nil
            end
        end,
        EditBoxOnEscapePressed = function(s)
            s:SetAutoFocus(false)
            s:ClearFocus()
            ExitIns=nil
            print(e.addName,addName,'|cff00ff00'..(e.onlyChinese and '取消' or CANCEL)..'|r', e.onlyChinese and '离开' or LEAVE)
            s:GetParent():Hide()
        end,
        whileDead=true, hideOnEscape=true, exclusive=true,
        timeout=sec}
end

























--初始菜单
local function Init_Menu(_, root)
    local sub, sub2, tab, line, num
    local isLeader, isTank, isHealer, isDPS = GetLFGRoles()--角色职责



--设置
    local roleText
    if (isTank or isHealer or isDPS) then
        roleText= (isTank and e.Icon.TANK or '')
                ..(isHealer and e.Icon.HEALER or '')
                ..(isDPS and e.Icon.DAMAGER or '')
                ..(isLeader and '|A:UI-HUD-UnitFrame-Player-Group-GuideIcon:0:0|a' or '')
    else
        roleText= format('|A:QuestLegendaryTurnin:0|a'..'|cnRED_FONT_COLOR:%s|r', e.onlyChinese and '无职责' or NO_ROLE)
    end

    sub=root:CreateButton((e.onlyChinese and '设置' or SETTINGS)..roleText, nil, roleText)
    sub:SetTooltip(function(tooltip, data)
        tooltip:AddLine('PVE '..( e.onlyChinese and '职责' or ROLE))
        tooltip:AddLine(data.data)
    end)






--设置, 小眼睛, 信息
    sub2=sub:CreateCheckbox(format('|A:%s:0:0|a', e.Icon.toLeft)..(e.onlyChinese and '离开副本' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC,LEAVE, INSTANCE)), function()
        return Save.leaveInstance
    end, function()
        Save.leaveInstance= not Save.leaveInstance and true or nil
        Set_Queue_Status()--小眼睛, 信息
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '离开副本和战场' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LEAVE, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, INSTANCE, BATTLEFIELDS)))
        tooltip:AddLine(' ')
        if e.onlyChinese then
            tooltip:AddLine('离开随机: 自动掷骰')
        else
            tooltip:AddLine(format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LEAVE,LFG_TYPE_RANDOM_DUNGEON))
            tooltip:AddLine(format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, ROLL))
        end
    end)





--设置, 信息 QueueStatusFrame.lua
    sub2=sub:CreateCheckbox('|A:groupfinder-eye-frame:0:0|a'..(e.onlyChinese and '列表信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SOCIAL_QUEUE_TOOLTIP_HEADER,INFO)), function()
        return not Save.hideQueueStatus
    end, function()
        Save.hideQueueStatus = not Save.hideQueueStatus and true or nil
        Set_Queue_Status()
    end)
    sub2:CreateButton((Save.tipsFramePoint and '' or '|cff9e9e9e')..(e.onlyChinese and '重置位置' or RESET_POSITION), function()
        Save.tipsFramePoint=nil
        if tipsButton then
            tipsButton:ClearAllPoints()
            tipsButton:set_Point()
            print(e.addName, addName, e.onlyChinese and '重置位置' or RESET_POSITION)
        end
    end)





--设置, 预创建队伍增强
    sub2=sub:CreateCheckbox('|A:UI-HUD-MicroMenu-Groupfinder-Mouseover:0:0|a'..(e.onlyChinese and '预创建队伍增强' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LFGLIST_NAME, 'Plus')), function()
        return Save.LFGPlus
    end, function()
        Save.LFGPlus = not Save.LFGPlus and true or nil
        if LFDButton.LFGPlus then
            LFDButton.LFGPlus:set_texture()
        end
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
    end)





--职责确认
    sub:CreateCheckbox('|A:quest-legendary-turnin:0:0|a'..(e.onlyChinese and '职责确认' or ROLE_POLL), function()
        return Save.autoSetPvPRole
    end, function()
        Save.autoSetPvPRole= not Save.autoSetPvPRole and true or nil
    end)




--设置,战场
    sub:CreateDivider()
    isTank, isHealer, isDPS = GetPVPRoles()--检测是否选定角色pve
    sub:CreateTitle(
        (e.onlyChinese and '战场' or BATTLEFIELDS)
        ..(isTank and e.Icon.TANK or '')
        ..(isHealer and e.Icon.HEALER or '')
        ..(isDPS and e.Icon.DAMAGER or '')
    )
    sub:CreateCheckbox('|A:poi-soulspiritghost:0:0|a'..(e.onlyChinese and '释放, 复活' or (BATTLE_PET_RELEASE..', '..RESURRECT)), function()
        return Save.ReMe
    end, function()
        Save.ReMe= not Save.ReMe and true or nil
    end)







--战利品掷骰
    sub=root:CreateButton(
        (Save.autoROLL and '|TInterface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47:0|t' or '|A:Levelup-Icon-Bag:0:0|a')
        ..(e.onlyChinese and '战利品掷骰' or LOOT_ROLL),
    ToggleLootHistoryFrame)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('/loot ')
    end)

    sub:CreateCheckbox((e.onlyChinese and '自动掷骰' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, ROLL))..'|TInterface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47:0|t', function()
        return Save.autoROLL
    end, function()
        Save.autoROLL= not Save.autoROLL and true or nil
    end)

    sub:CreateCheckbox('|A:communities-icon-notification:0:0|a'..(e.onlyChinese and '战利品 Plus' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LOOT, 'Plus')), function()
        return not Save.disabledLootPlus
    end, function()
        Save.disabledLootPlus= not Save.disabledLootPlus and true or nil
    end)











--副本，逃亡者

    local deserterExpiration = GetLFGDeserterExpiration()
    local shouldtext
    local cooldowntext
    if ( deserterExpiration ) then
		shouldtext = format("|cnRED_FONT_COLOR:%s|r "..e.GetPlayerInfo({guid=e.Player.guid}), e.onlyChinese and '逃亡者' or DESERTER)
        local timeRemaining = deserterExpiration - GetTime()
        if timeRemaining>0 then
            shouldtext= shouldtext..' '..SecondsToTime(ceil(timeRemaining))
        end
	else
		local myExpireTime = GetLFGRandomCooldownExpiration()
        if myExpireTime then
            cooldowntext= format("|cnRED_FONT_COLOR:%s|r "..e.GetPlayerInfo({guid=e.Player.guid}), e.onlyChinese and '冷却中' or ON_COOLDOWN)
            local timeRemaining = myExpireTime - GetTime()
            if timeRemaining>0 then
                cooldowntext= cooldowntext..' '..SecondsToTime(ceil(timeRemaining))
            end
        end
	end
    for i = 1, GetNumSubgroupMembers() do
        local unit= 'party'..i
		if ( UnitHasLFGDeserter(unit) ) then
			shouldtext= (shouldtext and shouldtext..'|n' or '')..e.GetPlayerInfo({unit=unit})..' '..(e.onlyChinese and '逃亡者' or DESERTER)
		elseif ( UnitHasLFGRandomCooldown(unit) ) then
			cooldowntext= (cooldowntext and cooldowntext..'|n' or '')..e.GetPlayerInfo({unit=unit})..' '..(e.onlyChinese and '冷却中' or ON_COOLDOWN)
		end
    end
    if shouldtext then
        root:CreateDivider()
        root:CreateTitle('|cnGREEN_FONT_COLOR:'..shouldtext)
    end








    root:CreateDivider()
--副本，列表
    Set_LFGFollower_Dungeon_List(root)--追随者，副本
    set_Party_Menu_List(root)--随机
    Init_Scenarios_Menu(root)--场景
    if cooldowntext then
        root:CreateTitle('|cnGREEN_FONT_COLOR:'..cooldowntext)
        root:CreateDivider()
    end
    set_Raid_Menu_List(root)--团本

--离开列队

    num= 0
    for i=1, NUM_LE_LFG_CATEGORYS do--列表信息
        num= (get_Queued_List(i) or 0)+ num
    end

    if num>35 then
        root:SetGridMode(MenuConstants.VerticalGridDirection, math.ceil(num/35))
    end

    sub=root:CreateButton((e.onlyChinese and '离开列队' or LEAVE_QUEUE)..' |cnGREEN_FONT_COLOR:#'..num..'|r', function()
        for i=1, NUM_LE_LFG_CATEGORYS do--列表信息
            LeaveLFG(i)
        end
    end, tab)

    sub:SetTooltip(function(tooltip, data)
        tooltip:AddLine(e.onlyChinese and '在队列中' or BATTLEFIELD_QUEUE_STATUS)
        for _, text in pairs(data.data or {}) do
            tooltip:AddLine(text)
        end
    end)

    sub:AddInitializer(function(btn)
        btn:SetScript("OnUpdate", function(self, elapsed)
            self.elapsed= (self.elapsed or 0) +elapsed
            if self.elapsed>1.2 then
                self.elapsed=0
                local queueNum= 0
                for i=1, NUM_LE_LFG_CATEGORYS do--列表信息
                    if GetLFGQueueStats(i) then
                        for _ in pairs(GetLFGQueuedList(i) or {}) do
                            queueNum= queueNum+1
                        end
                    end
                end
                self.fontString:SetText((e.onlyChinese and '离开列队' or LEAVE_QUEUE)..' |cnGREEN_FONT_COLOR:#'..queueNum..'|r')
            end
        end)
        btn:SetScript('OnHide', function(self)
            self:SetScript('OnUpdate', nil)
            self.elapsed= nil
        end)
    end)

end























--####
--初始
--####
local function Init()
    LFDButton:SetScript('OnClick', function(self, d)
        if d=='LeftButton' and self.dungeonID then
            if self.type==LE_LFG_CATEGORY_LFD then
                e.call(LFDQueueFrame_SetType, self.dungeonID)
                e.call(LFDQueueFrame_Join)
               -- printListInfo()--输出当前列表
            elseif self.type==LE_LFG_CATEGORY_RF then
                e.call(RaidFinderQueueFrame_SetRaid, self.dungeonID)
                e.call(RaidFinderQueueFrame_Join)
            elseif self.type==LE_LFG_CATEGORY_SCENARIO then
            end
        else
            MenuUtil.CreateContextMenu(self, Init_Menu)
            e.tips:Hide()
        end
    end)

    LFDButton:SetScript('OnEnter',function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.Get_Weekly_Rewards_Activities({showTooltip=true})--周奖励，提示

        if self.name and (self.dungeonID or self.RaidID) then
            e.tips:AddLine(' ')
            e.tips:AddLine(self.name..e.Icon.left)
        end
        if tipsButton and tipsButton:IsShown() then
            tipsButton:SetButtonState('PUSHED')
        end
        e.tips:Show()
        self:state_enter(Init_Menu)
    end)
    LFDButton:SetScript('OnLeave', function(self)
        e.tips:Hide()
        if tipsButton and tipsButton:IsShown() then
            tipsButton:SetButtonState('NORMAL')
        end
        self:state_leave()
    end)

    LFGDungeonReadyDialog:HookScript("OnShow", function(self)
        e.PlaySound()--播放, 声音
        e.Ccool(self, nil, 38, nil, true, true)
    end)--自动进入FB

    Init_tipsButton()--建立，小眼睛, 更新信息

    hooksecurefunc(QueueStatusFrame, 'Update', Set_Queue_Status)--小眼睛, 更新信息, QueueStatusFrame.lua

    set_LFDButton_LFGPlus_Texture()--预创建队伍增强
    if Save.LFGPlus then
        --预创建队伍增强
        hooksecurefunc('LFGListSearchEntry_Update', Init_LFGListSearchEntry_Update)
        hooksecurefunc('LFGListUtil_SetSearchEntryTooltip', Init_LFGListUtil_SetSearchEntryTooltip)
    end

    Loot_Plus()--历史, 拾取框

    Roll_Plus()--自动 ROLL

    Init_Dialogs()
    Init_RolePollPopup_Plus()
end

















































--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1, arg2, arg3, arg4)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave['ChatButton_LFD'] or Save
            addName= '|A:groupfinder-eye-frame:0:0|a'..(e.onlyChinese and '队伍查找器' or DUNGEONS_BUTTON)
            LFDButton= WoWTools_ChatButtonMixin:CreateButton('LFD', addName)

            if LFDButton then--禁用Chat Button
                

                Init()
                self:RegisterEvent('LFG_COMPLETION_REWARD')
                --self:RegisterEvent('SCENARIO_COMPLETED')
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
                self:RegisterEvent('ISLAND_COMPLETED')
                self:RegisterEvent('LFG_UPDATE_RANDOM_INFO')
                --self:RegisterEvent('START_LOOT_ROLL')
                self:RegisterEvent('PVP_MATCH_COMPLETE')
                self:RegisterEvent('CORPSE_IN_RANGE')--仅限战场，释放, 复活
                self:RegisterEvent('PLAYER_DEAD')
                self:RegisterEvent('AREA_SPIRIT_HEALER_IN_RANGE')
                self:RegisterEvent('LFG_ROLE_CHECK_ROLE_CHOSEN')
                self:RegisterEvent('LFG_ROLE_CHECK_DECLINED')
                self:RegisterEvent('LFG_QUEUE_STATUS_UPDATE')
                self:RegisterEvent('UPDATE_BATTLEFIELD_STATUS')
                self:RegisterEvent('GROUP_LEFT')
                self:RegisterEvent('PLAYER_ROLES_ASSIGNED')--职责确认
            end

            self:UnregisterEvent('ADDON_LOADED')

           
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButton_LFD']= Save
        end

    elseif event=='LFG_COMPLETION_REWARD' or event=='LOOT_CLOSED' then--or event=='SCENARIO_COMPLETED' then--自动离开
        if Save.leaveInstance
            and IsInLFGDungeon()
            and IsLFGComplete()
            and not LFGDungeonReadyStatus:IsVisible()
            and not LFGDungeonReadyDialog:IsVisible()
            --local scenarioInfo = C_ScenarioInfo.GetScenarioInfo()
            --local isCompleteScenario= scenarioInfo and scenarioInfo.isComplete
            --local lfgComplete=  IsLFGComplete()
            --if isCompleteScenario or lfgComplete then
            and not StaticPopup_Visible(addName..'ExitIns') then
                e.PlaySound()--播放, 声音
                local leaveSce= 30
                if Save.autoROLL and event=='LOOT_CLOSED' then
                    leaveSce= sec
                end
                ExitIns=true
                C_Timer.After(leaveSce, function()
                    exit_Instance()
                end)
                StaticPopup_Show(addName..'ExitIns')
                e.Ccool(StaticPopup1, nil, leaveSce, nil, true, true)--冷却条
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        if IsInInstance() then--自动离开
            self:RegisterEvent('LOOT_CLOSED')
        else
            self:UnregisterEvent('LOOT_CLOSED')
        end
        C_Timer.After(sec, function()
            setIslandButton(self)--离开海岛按钮
        end)
        ExitIns=nil

    elseif event=='ISLAND_COMPLETED' then--离开海岛
        Save_Instance_Num('island')

        if not Save.leaveInstance then
            return
        end

        e.PlaySound()--播放, 声音
        C_PartyInfo.LeaveParty(LE_PARTY_CATEGORY_INSTANCE)
        LFGTeleport(true)
        print(e.addName, addName,
            e.onlyChinese and '海岛探险' or ISLANDS_HEADER,
            e.Get_Instance_Num('island')
        )

    elseif event=='LFG_UPDATE_RANDOM_INFO' then
        setHoliday()--节日, 提示, LFDButton.texture

    --elseif event=='START_LOOT_ROLL' then
        --set_ROLL_Check(nil, arg1)

    elseif event=='CORPSE_IN_RANGE' or event=='PLAYER_DEAD' or event=='AREA_SPIRIT_HEALER_IN_RANGE' then--仅限战场，释放, 复活
        if Save.ReMe and e.Is_In_PvP_Area() then
            if event=='PLAYER_DEAD' then
                print(e.addName, addName,'|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '释放, 复活' or (BATTLE_PET_RELEASE..', '..RESURRECT)))
            end
            RepopMe()--死后将你的幽灵释放到墓地。
            RetrieveCorpse()--当玩家站在它的尸体附近时复活。
            AcceptAreaSpiritHeal()--在范围内时在战场上注册灵魂治疗师的复活计时器
        end

    elseif event=='PVP_MATCH_COMPLETE' then--离开战场
        if Save.leaveInstance then
            e.PlaySound()--播放, 声音
            if PVPMatchResults and PVPMatchResults.buttonContainer and PVPMatchResults.buttonContainer.leaveButton then
                e.Ccool(PVPMatchResults.buttonContainer.leaveButton, nil, sec, nil, true, true)
            end
            print(e.addName, addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '离开战场' or LEAVE_BATTLEGROUND), SecondsToTime(sec))
            C_Timer.After(sec, function()
                if not IsModifierKeyDown() then
                    if IsInLFDBattlefield() then
                        ConfirmOrLeaveLFGParty()
                    else
                        ConfirmOrLeaveBattlefield()
                    end
                end
            end)
        end

    elseif event=='LFG_ROLE_CHECK_ROLE_CHOSEN' or event=='LFG_ROLE_CHECK_DECLINED' or event=='LFG_QUEUE_STATUS_UPDATE' or event=='UPDATE_BATTLEFIELD_STATUS' or event=='GROUP_LEFT,PLAYER_ROLES_ASSIGNED' then
        get_Role_Info(event, arg1, arg2, arg3, arg4)--职责确认
    end
end)

--test11
--e.LibDD:ToggleDropDownMenu(level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay)
--MainMenuBarMicroButtons.lua
--[[
local Category={--NUM_LE_LFG_CATEGORYS 
    LE_LFG_CATEGORY_LFD,
    LE_LFG_CATEGORY_RF ,
    LE_LFG_CATEGORY_SCENARIO,
    LE_LFG_CATEGORY_LFR,
    LE_LFG_CATEGORY_WORLDPVP,
}
]]