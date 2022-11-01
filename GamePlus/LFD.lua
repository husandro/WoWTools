local id, e = ...
local addName =	DUNGEONS_BUTTON
local Save={leaveInstance=true, enterInstance=true}
local wowSave={[INSTANCE]={}}--{[ISLANDS_HEADER]=次数, [副本名称..难度=次数]}
local panel=CreateFrame("Frame")

local getRewardInfo=function(dungeonID)--FB奖励
    local t=''
    if not dungeonID then
        return t
    end
    --local numRewards = select(6, GetLFGDungeonRewards(dungeonID))
    local doneToday, moneyAmount, moneyVar, experienceGained, experienceVar, numRewards, spellID = GetLFGDungeonRewards(dungeonID)
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
        local eligible, forTank, forHealer, forDamage= GetLFGRoleShortageRewards(dungeonID, ii)
        if eligible and ( forTank or forHealer or forDamage) then
            local rewardIcon = select(2, GetLFGDungeonShortageRewardInfo(dungeonID, ii, 1))
            if rewardIcon then--local tankLocked, healerLocked, damageLocked = GetLFDRoleRestrictions(dungeonID)
                if forTank and canTank and rewardIcon then
                    T=(T or '')..'|T'..rewardIcon..':0|t'
                end
                if forHealer and canHealer and rewardIcon then
                    H=(H or '')..'|T'..rewardIcon..':0|t'
                end
                if forDamage and canDamage and rewardIcon then
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

local function getQueuedList(type, raiTips)--排队情况
    local list=GetLFGQueuedList(type)
    if not GetLFGQueueStats(type) or not list then
        return
    end
    local m, num= nil, 0
    for dungeonID, _ in pairs(list) do
        local name= dungeonID and GetLFGDungeonInfo(dungeonID)
        if name then
            num= num+1
            if raiTips then
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
                    boss=' '..kill..'/'..numEncounters
                    if kill==numEncounters then boss=RED_FONT_COLOR_CODE..boss..'|r' end
                    local mapName=select(19, GetLFGDungeonInfo(dungeonID))
                    if mapName then name=name.. '('..mapName..')' end
                end
                m=(m and m..'\n  ' or '  ').. num..') '..name..boss.. getRewardInfo(dungeonID)
            end
        end
    end
    return num, m
end

--#####
--小眼睛
--#####
local function setQueueStatus()--小眼睛, 信息
    local self=QueueStatusButton
    if Save.hideQueueStatus or not self then
        if self then
            if self.text then
                self.text:SetText('')
            end
            if self.enterInstance then
                self.enterInstance:SetShown(false)
            end
            if self.leaveInstance then
                self.leaveInstance:SetShown(false)
            end
        end
        return
    end
    if not self.text then--提示信息
        self.text=e.Cstr(self, nil, nil, nil, true)
        self.text:SetPoint('BOTTOMRIGHT', self, 'TOP')
    end
    local num, text=0, ''
    for i=1, NUM_LE_LFG_CATEGORYS do--列表信息
        local listNum, listText=getQueuedList(i,true)
        if listNum and listText then
            text= text~='' and text..'\n'..listText or listText
            num=num+listNum
        end
    end

    local pvp='';
    for i=1,  GetMaxBattlefieldID() do --PVP
        local status, mapName, teamSize, _, _, _, gameType = GetBattlefieldStatus(i);
        if (status=='queued' or status=='confirm') and mapName then
            if pvp~='' then pvp=pvp..'\n' end;
            if status=='confirm' then pvp=pvp..'(|cFF00FF00'..COVENANT_MISSIONS_CONFIRM_START_MISSION..'|r)' end
            pvp=pvp..mapName;
            if (teamSize and teamSize>0) or (gameType and gameType~='') then
                pvp=pvp..'(' if teamSize and teamSize >0 then pvp=pvp..teamSize end;
                if gameType then pvp=pvp..gameType end;
                pvp=pvp..')';
            end;
        end;
    end;
    if pvp~='' then
        text=text~='' and text..'\n' or text
        text=text..'|cFF00FF00*PvP|r'..pvp
        local tank, healer, dps = GetPVPRoles()
        if tank or healer or dps then
            text=text..(tank and e.Icon.TANK or '')..(healer and e.Icon.HEALER or '')..(dps and e.Icon.DAMAGER or '')
        end;
    end;

    local sta=C_PetBattles.GetPVPMatchmakingInfo()--PET
    if sta=='queued' then
        text=text~='' and  text..'\n' or text
        text=text..PET_BATTLE_PVP_QUEUE ..'|A:worldquest-icon-petbattle:0:0|a'
    end;

    if C_LFGList.HasActiveEntryInfo() then--已激活LFG
        local list
        local info =C_LFGList.GetActiveEntryInfo();
        if info and info.name then
            list=info.name;--名称
            local ap=C_LFGList.GetApplicants()--申请人数
             if ap and #ap>0 then
                list=list..' |cFF00FF00#'..#ap..'|r'
            end;
            if info.autoAccept then 
                list=list..'|A:runecarving-icon-reagent-empty:0:0|a' 
            end;--自动邀请
            if info.activityID then--名称
                local name2=C_LFGList.GetActivityFullName(info.activityID);                            
                if name2 then
                    list=list..' ('..name2..')'
                end;
            end;
            if info.duration then--时长
                local time=SecondsToClock(1800-info.duration);
                time=time:gsub('：',':');
                time=time:gsub(' ','');
                list=list..' '..time
            end;
            if info.privateGroup then--私人
                list=list..LFG_LIST_PRIVATE
            end;
        end;
        if list then
            text=text~='' and text..'\n'..list or list
        end
    end;

    local sea='';--LFG申请列表
    local apps = C_LFGList.GetApplications() or {};
    for i=1, #apps do
        local _, appStatus = C_LFGList.GetApplicationInfo(apps[i]);
        if ( appStatus == "applied" or appStatus == "invited" ) then
            local searchResultInfo = C_LFGList.GetSearchResultInfo(apps[i]);
            local activityName = C_LFGList.GetActivityFullName(searchResultInfo.activityID, nil, searchResultInfo.isWarMode);
            sea=sea..'\n'..searchResultInfo.name..'('.. activityName..')|cFF00FF00*|r';
        end;
    end;
    if sea~='' then
        text=text~='' and text..'\n'..QUEUED_STATUS_SIGNED_UP..'(|cFF00FF00LFG|r)'..sea or sea
    end

    self.text:SetText(text)

    if not self.enterInstance and Save.enterInstance then--自动进入,指示图标
        self.enterInstance=self:CreateTexture(nil, 'ARTWORK')
        self.enterInstance:SetPoint('BOTTOMLEFT',6,-6)
        self.enterInstance:SetSize(12,12)
        self.enterInstance:SetAtlas(e.Icon.toRight)
        self.enterInstance:SetDesaturated(true)
    end
    if self.enterInstance then
        self.enterInstance:SetShown(Save.enterInstance)
    end
    if not self.leaveInstance and Save.leaveInstance then--自动离开,指示图标
        self.leaveInstance=self:CreateTexture(nil, 'ARTWORK')
        self.leaveInstance:SetPoint('BOTTOMRIGHT',-6,-6)
        self.leaveInstance:SetSize(12,12)
        self.leaveInstance:SetAtlas(e.Icon.toLeft)
        self.leaveInstance:SetDesaturated(true)
    end
    if self.leaveInstance then
        self.leaveInstance:SetShown(Save.leaveInstance)
    end
end
local function setQueueStatusMenu(self, relativeTo)--小眼睛, 信息, 设置菜单 QueueStatusFrame.lua
    UIDropDownMenu_AddSeparator()
    local info=UIDropDownMenu_CreateInfo()--离开副本
    info.text=	SOCIAL_QUEUE_TOOLTIP_HEADER..INFO
    info.tooltipOnButton=true
    info.tooltipTitle=id..' '..addName
    info.checked=not Save.hideQueueStatus
    info.func=function()
        if Save.hideQueueStatus then
            Save.hideQueueStatus=nil
        else
            Save.hideQueueStatus=true
        end
        setQueueStatus()
    end
    UIDropDownMenu_AddButton(info)
end

--####
--菜单
--####
local function autoEnterLeavelInstance()--自动,离开, 进入, 副本
    local info
    local isLeader, isTank, isHealer, isDPS = GetLFGRoles()--角色职责
    info=UIDropDownMenu_CreateInfo()--准备进入
    info.text=e.Icon.toRight2..BATTLEFIELD_CONFIRM_STATUS..(isLeader and e.Icon.leader or '')
                ..(isTank and e.Icon.TANK or '')
                ..(isHealer and e.Icon.HEALER or '')
                ..(isDPS and e.Icon.DAMAGER or '')
                ..((not isTank and not isHealer and not isDPS) and ' |cnRED_FONT_COLOR:'..ROLE..'|r' or '')
    info.tooltipOnButton=true
    info.tooltipTitle=SPECIFIC_DUNGEON_IS_READY
    info.checked=Save.enterInstance
    info.tooltipText=AUTO_JOIN:gsub(JOIN, ENTER_LFG)..': '..e.GetEnabeleDisable(Save.enterInstance)..'\n\n'..id..' '..addName
    info.func=function()
        if Save.enterInstance then
            Save.enterInstance=nil
        else
            Save.enterInstance=true
        end
        setQueueStatus()--小眼睛, 信息
    end
    UIDropDownMenu_AddButton(info)

    info=UIDropDownMenu_CreateInfo()--离开副本
    info.text=e.Icon.toLeft2..LEAVE..'('..INSTANCE..')'
    info.tooltipOnButton=true
    info.tooltipTitle=LEAVE..' ('..SLASH_RANDOM3:gsub('/','')..') '..INSTANCE
    info.checked=Save.leaveInstance
    info.tooltipText=AUTO_JOIN:gsub(JOIN, LEAVE)..': '..e.GetEnabeleDisable(Save.leaveInstance)..'\n\n'..id..' '..addName
    info.func=function()
         if Save.leaveInstance then
             Save.leaveInstance=nil
         else
             Save.leaveInstance=true
         end
         setQueueStatus()--小眼睛, 信息
    end
    UIDropDownMenu_AddButton(info)

    local num, text=0, ''
    for i=1, NUM_LE_LFG_CATEGORYS do--列表信息
        local listNum, listText=getQueuedList(i,true)
        if listNum and listText then
            text= text~='' and text..'\n'..listText or listText
            num=num+listNum
        end
    end
     info=UIDropDownMenu_CreateInfo()--离开所有副本
     info.text=LEAVE_ALL_QUEUES..' #'..num..'|r'
     info.notCheckable=true
     info.disabled= num==0
     info.func=function ()
        for i=1, NUM_LE_LFG_CATEGORYS do--列表信息
            LeaveLFG(i)
        end
     end
     info.tooltipOnButton=true
     info.tooltipTitle=	BATTLEFIELD_QUEUE_STATUS
     info.tooltipText=text
     UIDropDownMenu_AddButton(info)
 end

local function printListInfo()--输出当前列表
    C_Timer.After(1.2, function()
        for i=1, NUM_LE_LFG_CATEGORYS  do--列表信息
            local n, text =getQueuedList(i, true)--排5人本
            if n and n>0 and text then
                print(id, addName, date('%X'))
                print(text)
            end
        end
    end)
end
local function partyList()--随机 LFDFrame.lua
    local info
    for i=1, GetNumRandomDungeons() do
        local dungeonID, name = GetLFGRandomDungeonInfo(i)
        local isAvailableForAll, isAvailableForPlayer, hid2eIfNotJoinable = IsLFGDungeonJoinable(dungeonID)
        if (isAvailableForPlayer or not hid2eIfNotJoinable) then
            info = UIDropDownMenu_CreateInfo()
            if isAvailableForAll then
                local lfd=GetLFGQueueStats(LE_LFG_CATEGORY_LFD, dungeonID)--是否有排本
                info.text = name..getRewardInfo(dungeonID)
                info.value = dungeonID
                info.func =function()
                    LFDQueueFrame_SetType(dungeonID)
                    if lfd then
                        LeaveSingleLFG(LE_LFG_CATEGORY_LFD, dungeonID)
                    else
                        LFDQueueFrame_Join()
                        printListInfo()--输出当前列表
                    end
                end
                info.checked=lfd
                local doneToday= GetLFGDungeonRewards(dungeonID)
                if doneToday then--local doneToday, moneyAmount, moneyVar, experienceGained, experienceVar, numRewards, spellID = GetLFGDungeonRewards(dungeonID)
                    info.icon='Interface\\AddOns\\WeakAuras\\Media\\Textures\\ok-icon.tga'
                end
                info.tooltipOnButton=true
                info.tooltipTitle='dungeonID: '..dungeonID
                local text=''
                if  lfd then
                    text='|cnGREEN_FONT_COLOR:'..LEAVE_QUEUE..'|r'
                end
                if doneToday then
                    text=text..'\n'..GUILD_EVENT_TODAY..'|TInterface\\AddOns\\WeakAuras\\Media\\Textures\\ok-icon.tga:0|t'..COMPLETE
                end
                if text~='' then
                    info.tooltipText=text
                end
            else
                info.text = name
				info.value = dungeonID
				info.disabled = 1
				info.tooltipWhileDisabled = 1
				info.tooltipOnButton = 1
				info.tooltipTitle = YOU_MAY_NOT_QUEUE_FOR_THIS
				info.tooltipText = LFGConstructDeclinedMessage(dungeonID)
            end
            UIDropDownMenu_AddButton(info)
        end
    end
end

local function isRaidFinderDungeonDisplayable(dungeonID)--RaidFinder.lua
    local _, _, _, minLevel, maxLevel, _, _, _, expansionLevel = GetLFGDungeonInfo(dungeonID)
    local myLevel = UnitLevel("player")
    return myLevel >= minLevel and myLevel <= maxLevel and EXPANSION_LEVEL >= expansionLevel
end
local raidList=function()--团队本
    local sortedDungeons, find = {}, nil
    local function InsertDungeonData(dungeonID, name, mapName, isAvailable, mapID)
        local t = { id = dungeonID, name = name, mapName = mapName, isAvailable = isAvailable, mapID = mapID }
        local foundMap = false
        for i = 1, #sortedDungeons do
            if ( sortedDungeons[i].mapName == mapName ) then
                foundMap = true
            else
                if ( foundMap ) then
                    tinsert(sortedDungeons, i, t)
                    return
                end
            end
        end
        tinsert(sortedDungeons, t)
    end
    for i=1, GetNumRFDungeons() do
        local dungeonInfo = { GetRFDungeonInfo(i) }
        local dungeonID = dungeonInfo[1]
        local name = dungeonInfo[2]
        local mapName = dungeonInfo[20]
        local mapID = dungeonInfo[23]
        local isAvailable, isAvailableToPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(dungeonID)
        if( not hideIfNotJoinable or isAvailable ) then
            if ( isAvailable or isAvailableToPlayer or isRaidFinderDungeonDisplayable(dungeonID) ) then
                InsertDungeonData(dungeonID, name, mapName, isAvailable, mapID)
                find=true
            end
        end
    end

    local ScInsName--场景名称
    local infos=C_ScenarioInfo.GetScenarioInfo()
    if infos and infos.name then
        ScInsName=infos.name
    end

    local currentMapName = nil
    for i = 1, #sortedDungeons do
        if ( currentMapName ~= sortedDungeons[i].mapName ) then
            local info = UIDropDownMenu_CreateInfo()
            currentMapName = sortedDungeons[i].mapName
            info.text = sortedDungeons[i].mapName
            info.isTitle = 1
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info)
        end

        local info = UIDropDownMenu_CreateInfo()
        if ( sortedDungeons[i].isAvailable ) then
            local sele=GetLFGQueueStats(LE_LFG_CATEGORY_RF, sortedDungeons[i].id)
            info.text = sortedDungeons[i].name..getRewardInfo(sortedDungeons[i].id)
            if ScInsName==sortedDungeons[i].name then--当前副本
                info.text='|A:auctionhouse-icon-favorite:0:0|a'..info.text
            end
            info.value = sortedDungeons[i].id
            info.func = function()
                if sele then
                    LeaveSingleLFG(LE_LFG_CATEGORY_RF, sortedDungeons[i].id)
                else
                    RaidFinderQueueFrame_SetRaid(sortedDungeons[i].id)
                    RaidFinderQueueFrame_Join()
                    printListInfo()--输出当前列表
                end
            end
            info.checked = sele
            info.tooltipOnButton = 1
            info.tooltipTitle = RAID_BOSSES
            local encounters=''
            local numEncounters = GetLFGDungeonNumEncounters(sortedDungeons[i].id)
            local kill=0
            local k2=''
            for j = 1, numEncounters do
                local bossName, _, isKilled = GetLFGDungeonEncounterInfo(sortedDungeons[i].id, j)
                local colorCode = ""
                if ( isKilled ) then
                    colorCode = RED_FONT_COLOR_CODE
                    kill=kill+1
                    k2=k2..'|cffff0000x|r'
                else
                    k2=k2..'|cff00ff00'..j..'|r'
                end
                if encounters then
                    encounters = encounters.."|n"..colorCode..bossName..FONT_COLOR_CODE_CLOSE
                else
                    encounters = colorCode..bossName..FONT_COLOR_CODE_CLOSE
                end
            end
            info.text=info.text..' '..kill..'/'..numEncounters--击杀数量
            if kill>0 and kill~=numEncounters then  info.text=info.text..' '..k2 end
            if kill==numEncounters then
                info.colorCode='|cffff0000'
            end

            local modifiedInstanceTooltipText = ""
            if(sortedDungeons[i].mapID) then
                local modifiedInstanceInfo = C_ModifiedInstance.GetModifiedInstanceInfoFromMapID(sortedDungeons[i].mapID)
                if (modifiedInstanceInfo) then
                    info.icon = GetFinalNameFromTextureKit("%s-small", modifiedInstanceInfo.uiTextureKit)
                    modifiedInstanceTooltipText = "|n|n" .. modifiedInstanceInfo.description
                end
                info.iconXOffset = -6
            end
            info.tooltipText = encounters .. modifiedInstanceTooltipText..'|n|n|cffffffffID '..sortedDungeons[i].id
        else
            info.text = sortedDungeons[i].name
			info.value = sortedDungeons[i].id
			local modifiedInstanceTooltipText = ""
			if(sortedDungeons[i].mapID) then
				local modifiedInstanceInfo = C_ModifiedInstance.GetModifiedInstanceInfoFromMapID(sortedDungeons[i].mapID)
				if (modifiedInstanceInfo) then
					info.icon = GetFinalNameFromTextureKit("%s-small", modifiedInstanceInfo.uiTextureKit)
					modifiedInstanceTooltipText = "|n|n" .. modifiedInstanceInfo.description
				end
				info.iconXOffset = -6
			end
			info.disabled = 1
			info.tooltipWhileDisabled = 1
			info.tooltipOnButton = 1
			info.tooltipTitle = YOU_MAY_NOT_QUEUE_FOR_THIS
			info.tooltipText = LFGConstructDeclinedMessage(sortedDungeons[i].id) .. modifiedInstanceTooltipText
        end
        UIDropDownMenu_AddButton(info)
    end
    return find
end


local function InitList(self, level, arg1)--LFDFrame.lua
    autoEnterLeavelInstance()--自动,离开, 进入, 副本
    UIDropDownMenu_AddSeparator()
    if  raidList() then --团本
        UIDropDownMenu_AddSeparator()
    end
    partyList()--随机
end


--###############
--离开, 进入, 副本
--###############
local sec=3--离开时间
local function setLFGDungeonReadyDialog(self)--自动进入FB LFGDungeonReadyDialog:HookScript("OnShow"
    local afk=UnitIsAFK('player')
    if not self.infoText then
        self.infoText=e.Cstr(self,nil, LFGDungeonReadyDialogInstanceInfoFrame.name, nil, true)
        self.infoText:SetPoint('LEFT', self, 'RIGHT')
        self.infoText:SetJustifyH('LEFT')
        self.infoText:SetShadowOffset(2, -2)
    end
    local proposalExists, dungeonID, typeID, subtypeID, name, backgroundTexture, role, hasResponded, totalEncounters, completedEncounters, numMembers, isLeader, isHoliday, proposalCategory , isSilent = GetLFGProposal();
    local text='' 
    if dungeonID then
        text='dungeonID: '..dungeonID
                ..( role and _G[role] and '\n'.._G[role]..e.Icon[role] ..(isLeader and e.Icon.leader or ''))
                ..(totalEncounters and completedEncounters and totalEncounters>0 and '\n|cnGREEN_FONT_COLOR:'..completedEncounters..'|r /'..totalEncounters..' '..BOSS or '')
                ..(numMembers and '\n'..numMembers..' '..PLAYER  or '')
                ..(isHoliday and '\n'..CALENDAR_FILTER_HOLIDAYS.. ' '..INSTANCE or '')
    end
    self.infoText:SetText(text)
    if not Save.enterInstance or afk then
        e.Ccool(self, GetTime(), 38, nil, true, true)
        if Save.enterInstance and afk then
            print(id, addName, '|cnRED_FONT_COLOR:'..NO..'|r', BATTLEFIELD_CONFIRM_STATUS, '|cnRED_FONT_COLOR:'..CHAT_FLAG_AFK..'|r')
        end
        return
    end
    if name then
        print(id, addName, QUEUED_STATUS_PROPOSAL,'|cnGREEN_FONT_COLOR:'..sec..'|r', SECONDS)
        if text~='' then
            text=text:gsub('\n', ' ')
            print(text)
        end
    end
    e.Ccool(self, GetTime(), sec, nil, true, true)
    C_Timer.After(sec, function()
        if self and self.enterButton and self:IsShown() and self.enterButton:IsEnabled() then
            self.enterButton:Click()
        end
    end)
end

local ExitIns
local function exitInstance()
    local ins=IsInInstance()
    local name, _, _, difficultyName, _, _, _, instanceID = GetInstanceInfo()
    ins = ins and name and difficultyName
    if ins then
        name= name..difficultyName
        wowSave[INSTANCE][name]=wowSave[INSTANCE][name]  and wowSave[INSTANCE][name] +1 or 1
    else
        name=nil
    end
    if not ExitIns or not ins then
        StaticPopup_Hide(addName..'ExitIns')
        return
    end
    if IsInLFDBattlefield() then
        local currentMapID, _, lfgID = select(8, GetInstanceInfo())
        local _, _, subtypeID, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, lfgMapID = GetLFGDungeonInfo(lfgID)
        if currentMapID == lfgMapID and subtypeID == LE_LFG_CATEGORY_BATTLEFIELD then
            LFGTeleport(true)
        end
    else
        C_PartyInfo.LeaveParty(LE_PARTY_CATEGORY_INSTANC)
    end
    print(id, addName, '|cnGREEN_FONT_COLOR:'..LEAVE..'|r'..(name or INSTANCE), name and '|cnGREEN_FONT_COLOR:'..wowSave[INSTANCE][name]..'|r'..VOICEMACRO_LABEL_CHARGE1 or '')
    ExitIns=nil
end

StaticPopupDialogs[addName..'ExitIns']={
    text =id..'('..addName..')\n\n|cff00ff00'..LEAVE..'|r: ' ..INSTANCE.. '|cff00ff00 '..sec..' |r'..SECONDS,
    button1 = LEAVE,
    button2 = CANCEL,
    OnAccept=function()
        exitInstance()
    end,
    OnCancel=function(_, _, d)
        if d=='clicked' then
            ExitIns=nil
            print(id,addName,'|cff00ff00'..CANCEL..'|r' .. LEAVE)
        end
    end,
    EditBoxOnEnterPressed = function()
        Exit()
    end,
    EditBoxOnEscapePressed = function(s)
        ExitIns=nil
        print(id, addName, '|cff00ff00'..CANCEL..'|r' .. LEAVE)
        s:GetParent():Hide()
    end,
whileDead=true,timeout=sec, hideOnEscape =true,}

local function leaveInstance()--自动离开
    if not Save.leaveInstance or not IsLFGComplete() then
        return
    end
    ExitIns=true
    StaticPopup_Show(addName..'ExitIns')
    e.Ccool(StaticPopup1, GetTime(), sec, nil, true)--冷却条
    C_Timer.After(sec, function()
        exitInstance()
    end)
end

local function levelIsland()--离开海岛
    wowSave[ISLANDS_HEADER]=wowSave[ISLANDS_HEADER] and wowSave[ISLANDS_HEADER]+1 or 1
    if not Save.leaveInstance then
        return
    end
    C_PartyInfo.LeaveParty(LE_PARTY_CATEGORY_INSTANC)
    LFGTeleport(true)
    print(id, addName, 	ISLAND_LEAVE, '|cnGREEN_FONT_COLOR:'..wowSave[ISLANDS_HEADER]..'|r'..	VOICEMACRO_LABEL_CHARGE1)
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
            self.island = e.Cbtn(UIParent, true)
            self.island:SetSize(50, 25)
            self.island:SetText(LEAVE)
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
            end)
            self.island:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(id, addName)
                e.tips:AddDoubleLine(ISLANDS_HEADER, (wowSave[ISLANDS_HEADER] and wowSave[ISLANDS_HEADER] or 0)..' '..VOICEMACRO_LABEL_CHARGE1)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(ISLAND_LEAVE, e.Icon.left)
                e.tips:AddDoubleLine(NPE_MOVE, e.Icon.right)
                e.tips:Show()
            end)
            self.island:SetScript('OnLeave', function ()
                e.tips:Hide()
            end)
        end
    else
    end
    if self.island then
        self.island:SetShown(find)
    end
end



--#######
--Init
--#######
local Settings=nil--不是已启动
local function Init()
    if Settings then
        return
    end

    local menuList= CreateFrame("Frame",nil, LFDMicroButton, "UIDropDownMenuTemplate")--菜单列表
    UIDropDownMenu_Initialize(menuList, InitList, "MENU")
    LFDMicroButton:HookScript('OnEnter', function(self2) ToggleDropDownMenu(1, nil, menuList, self2, -250,250) end)

    LFGDungeonReadyDialog:HookScript("OnShow", setLFGDungeonReadyDialog)--自动进入FB
    Settings=true

    hooksecurefunc('QueueStatusDropDown_Show', setQueueStatusMenu)--小眼睛, 信息, 设置菜单
    hooksecurefunc(QueueStatusFrame, 'Update', setQueueStatus)--小眼睛, 更新信息, QueueStatusFrame.lua

    local isLeader, isTank, isHealer, isDPS = GetLFGRoles()--检测是否选定角色pve
    if  not isTank and not isHealer and not isDPS then
        isTank, isHealer, isDPS=true, true, true
        local sid=GetSpecialization()
        local role = sid and  select(5, GetSpecializationInfo(sid))
        if role then
            if role=='TANK' then
                isTank, isHealer, isDPS=true, nil, nil
            elseif role=='HEALER' then
                isTank, isHealer, isDPS=nil, true, nil
            elseif role=='DAMAGER' then
                isTank, isHealer, isDPS=nil, nil ,true
            end
        end
        SetLFGRoles(isLeader, isTank, isHealer, isDPS)
    end
end
--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:RegisterEvent('LFG_COMPLETION_REWARD')
panel:RegisterEvent('PLAYER_ENTERING_WORLD')
panel:RegisterEvent('ISLAND_COMPLETED')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            wowSave=WoWToolsSave and WoWToolsSave[INSTANCE] or wowSave
            --添加控制面板        
            local sel=e.CPanel(addName, not Save.disabled, true)
            sel:SetScript('OnClick', function()
                if Save.disabled then
                    Save.disabled=nil
                else
                    Save.disabled=true
                end
                if Settings then
                    print(id, addName, e.GetEnabeleDisable(not Save.disabled), NEED..' /reload')
                end
                Init()
            end)
            if not Save.disabled then
                Init()
            end
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
            WoWToolsSave[INSTANCE]=wowSave
        end
    elseif not Save.disabled then

        if event=='LFG_COMPLETION_REWARD' or event=='LOOT_CLOSED' then
            leaveInstance()--自动离开

        elseif event=='PLAYER_ENTERING_WORLD' then
            if IsInInstance() then--自动离开
                panel:RegisterEvent('LOOT_CLOSED')
            else
                panel:UnregisterEvent('LOOT_CLOSED')
            end
            C_Timer.After(2, function()
                setIslandButton(self)--离开海岛按钮
            end)
        elseif event=='ISLAND_COMPLETED' then
            levelIsland()--离开海岛
        end
    end
end)

--test11
--ToggleDropDownMenu(level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay)
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
