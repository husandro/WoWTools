local id, e = ...
local addName =	DUNGEONS_BUTTON
local Save={
    leaveInstance=true, enterInstance=true, autoROLL=true,
    ReMe=true,--仅限战场，释放，复活
    autoSetPvPRole=true,--自动职责确认， 排副本
}
local wowSave={[INSTANCE]={}}--{[ISLANDS_HEADER]=次数, [副本名称..难度=次数]}

local sec=3--时间 timer

local panel=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)

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
    local text=''
    if not Save.hideQueueStatus then
        if not panel.tipsFrame then
            panel.tipsFrame=e.Cbtn(nil, nil, nil, nil, nil, true, {20,20})
            if Save.tipsFramePoint then
                panel.tipsFrame:SetPoint(Save.tipsFramePoint[1], UIParent, Save.tipsFramePoint[3], Save.tipsFramePoint[4], Save.tipsFramePoint[5])
            else
                panel.tipsFrame:SetPoint('BOTTOMLEFT', panel, 'TOPLEFT',0,2)
            end
            panel.tipsFrame:RegisterForDrag("RightButton",'LeftButton')
            panel.tipsFrame:SetMovable(true)
            panel.tipsFrame:SetClampedToScreen(true)

            panel.tipsFrame:SetScript("OnDragStart", function(self,d )
                self:StartMoving()
            end)
            panel.tipsFrame:SetScript("OnDragStop", function(self)
                ResetCursor()
                self:StopMovingOrSizing()
                Save.tipsFramePoint={self:GetPoint(1)}
                Save.tipsFramePoint[2]=nil
            end)
            panel.tipsFrame:SetScript('OnMouseWheel', function(self, d)
                local n= Save.tipsFrameTextSize or 12
                if d==1 then
                    n=n+1
                elseif d==-1 then
                    n=n-1
                end
                Save.tipsFrameTextSize= n>30 and 30 or n<6 and 6 or n
                e.Cstr(nil, Save.tipsFrameTextSize, nil, self.text, true)
                print(id, addName, e.onlyChinse and '字体大小' or FONT_SIZE, '|cnGREEN_FONT_COLOR:'..Save.tipsFrameTextSize)
            end)
            panel.tipsFrame:SetScript("OnMouseDown", function(self,d)
                SetCursor('UI_MOVE_CURSOR')
            end)
            panel.tipsFrame:SetScript("OnLeave", function()
                e.tips:Hide()
                ResetCursor()
            end)
            panel.tipsFrame:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.onlyChinse and '移动' or NPE_MOVE, e.Icon.left)
                e.tips:AddDoubleLine(e.onlyChinse and '字体大小' or FONT_SIZE, (Save.tipsFrameTextSize or 12).. e.Icon.mid)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(e.onlyChinse and '列表信息' or (SOCIAL_QUEUE_TOOLTIP_HEADER..INFO), '|A:groupfinder-eye-frame:0:0|a')
                e.tips:AddDoubleLine(id, addName)
                e.tips:Show()
            end)
            panel.tipsFrame.text=e.Cstr(panel.tipsFrame, Save.tipsFrameTextSize, nil, nil, true)
            panel.tipsFrame.text:SetPoint('BOTTOMLEFT')
        end

        local num= 0
        for i=1, NUM_LE_LFG_CATEGORYS do--列表信息
            local listNum, listText=getQueuedList(i,true)
            if listNum and listText then
                text= text~='' and text..'\n'..listText or listText
                text=text..' '
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
            text=text..' '
        end;

        local sta=C_PetBattles.GetPVPMatchmakingInfo()--PET
        if sta=='queued' then
            text=text~='' and  text..'\n' or text
            text=text..PET_BATTLE_PVP_QUEUE ..'|A:worldquest-icon-petbattle:0:0|a'
            text=text..' '
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
                text=text..' '
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
                text=text..' '
            end;
        end;
        if sea~='' then
            text=text~='' and text..'\n'..QUEUED_STATUS_SIGNED_UP..'(|cFF00FF00LFG|r)'..sea or sea
            text=text..' '
        end
    end
    if panel.tipsFrame then
        panel.tipsFrame.text:SetText(text)
        panel.tipsFrame:SetShown(text~='' and true or nil)
    end

    if not panel.enterInstance and Save.enterInstance then--自动进入,指示图标
        panel.enterInstance=panel:CreateTexture(nil, 'ARTWORK')
        panel.enterInstance:SetPoint('BOTTOMLEFT',3,3)
        panel.enterInstance:SetSize(10,10)
        panel.enterInstance:SetAtlas(e.Icon.toRight)
        panel.enterInstance:SetDesaturated(true)
    end
    if panel.enterInstance then
        panel.enterInstance:SetShown(Save.enterInstance)
    end
    if not panel.leaveInstance and Save.leaveInstance then--自动离开,指示图标
        panel.leaveInstance=panel:CreateTexture(nil, 'ARTWORK')
        panel.leaveInstance:SetPoint('BOTTOMRIGHT',-7,3)
        panel.leaveInstance:SetSize(10,10)
        panel.leaveInstance:SetAtlas(e.Icon.toLeft)
        panel.leaveInstance:SetDesaturated(true)
    end
    if panel.leaveInstance then
        panel.leaveInstance:SetShown(Save.leaveInstance)
    end
end


--###############
--副本， 菜单列表
--###############
local function setTexture(dungeonID, RaidID, name, texture)--设置图标, 点击,提示
    if dungeonID or RaidID then
        panel.dungeonID=dungeonID
        panel.name=name
        panel.RaidID=RaidID
    end
    if texture then
        panel.texture:SetTexture(texture)
    else
        if not Save.hideQueueStatus then
            panel.texture:SetAtlas('groupfinder-eye-frame')
        else
            panel.texture:SetAtlas('UI-HUD-MicroMenu-Groupfinder-Mouseover')
        end
    end
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
local function partyList(self, level, type)--随机 LFDFrame.lua
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

                        setTexture(dungeonID, nil, name, nil)--设置图标, 点击,提示
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
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

local function isRaidFinderDungeonDisplayable(dungeonID)--RaidFinder.lua
    local _, _, _, minLevel, maxLevel, _, _, _, expansionLevel = GetLFGDungeonInfo(dungeonID)
    local myLevel = UnitLevel("player")
    return myLevel >= minLevel and myLevel <= maxLevel and EXPANSION_LEVEL >= expansionLevel
end
local raidList=function(self, level, type)--团队本
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
            UIDropDownMenu_AddButton(info, level)
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

                    setTexture(nil, sortedDungeons[i].id, sortedDungeons[i].name, nil)--设置图标, 点击,提示
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
                    encounters = encounters.."|n"..colorCode..bossName..'|r'
                else
                    encounters = colorCode..bossName..'|r'
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
        UIDropDownMenu_AddButton(info, level)
    end
    return find
end

--#######
--初始菜单
--#######
local function InitList(self, level, type)--LFDFrame.lua
    local info
    if type=='SETTINGS' then
        info={--自动, 准备进入,选项
            text=e.Icon.toRight2..(e.onlyChinse and '准备进入' or BATTLEFIELD_CONFIRM_STATUS),
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinse and '已经建好了一个队伍，准备前往' or SPECIFIC_DUNGEON_IS_READY,
            checked=Save.enterInstance,
            tooltipText= (e.onlyChinse and '自动进入' or AUTO_JOIN:gsub(JOIN, ENTER_LFG))..'\n'..(e.onlyChinse and '不能在 AFK 中' or format(ERR_ARENA_TEAM_PLAYER_NOT_IN_TEAM_SS, '',AFK)).. '\n\n|cnGREEN_FONT_COLOR:Alt '..(e.onlyChinse and '取消' or CANCEL)..'|r\n\n'..id..' '..addName,
            func=function()
                Save.enterInstance= not Save.enterInstance and true or nil
                setQueueStatus()--小眼睛, 信息
            end
        }
        UIDropDownMenu_AddButton(info, level)

        info={--自动, 离开副本,选项
            text=e.Icon.toLeft2..(e.onlyChinse and '离开副本' or (LEAVE..INSTANCE)),
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinse and '离开副本和战场' or (LEAVE..INSTANCE..' '..BATTLEFIELDS),
            checked=Save.leaveInstance,
            tooltipText= (e.onlyChinse and '离开随机(自动 Roll)' or  AUTO_JOIN:gsub(JOIN, LEAVE)..' ('..AUTO_JOIN:gsub(JOIN,'')..LOOT_ROLL) .. ')\n\n|cnGREEN_FONT_COLOR:Alt '..(e.onlyChinse and '取消' or CANCEL)..'|r\n\n'..id..' '..addName,
            func=function()
                Save.leaveInstance= not Save.leaveInstance and true or nil
                setQueueStatus()--小眼睛, 信息
            end
        }
        UIDropDownMenu_AddButton(info, level)

        local num, text=0, ''
        for i=1, NUM_LE_LFG_CATEGORYS do--列表信息
            local listNum, listText=getQueuedList(i,true)
            if listNum and listText then
                text= text~='' and text..'\n'..listText or listText
                num=num+listNum
            end
        end
        UIDropDownMenu_AddSeparator(level)

        info={
            text= (e.onlyChinse and '离开所有副本' or LEAVE_ALL_QUEUES)..' #'..num..'|r',
            notCheckable=true,
            disabled= num==0,
            func=function ()
                for i=1, NUM_LE_LFG_CATEGORYS do--列表信息
                    LeaveLFG(i)
                end
            end,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinse and '在队列中' or BATTLEFIELD_QUEUE_STATUS,
            tooltipText=text,
        }
        UIDropDownMenu_AddButton(info, level)

        UIDropDownMenu_AddSeparator(level)
        info={--信息 QueueStatusFrame.lua
            text='|A:groupfinder-eye-frame:0:0|a'.. (e.onlyChinse and '列表信息' or SOCIAL_QUEUE_TOOLTIP_HEADER..INFO),
            checked=not Save.hideQueueStatus,
            func=function()
                Save.hideQueueStatus = not Save.hideQueueStatus and true or nil
                setQueueStatus()
            end,
        }
        UIDropDownMenu_AddButton(info, level)

        info={--自动,战利品掷骰
            text='|TInterface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47:0|t'..(e.onlyChinse and '战利品掷骰' or LOOT_ROLL),
            checked=Save.autoROLL,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinse and '自动' or AUTO_JOIN:gsub(JOIN,''),
            func= function()
                Save.autoROLL= not Save.autoROLL and true or nil
            end
        }
        UIDropDownMenu_AddButton(info, level)

        info= {
            text= e.onlyChinse and '自动打开战利品掷骰窗口' or AUTO_OPEN_LOOT_HISTORY_TEXT,
            tooltipOnButton= true,
            tooltipTitle= '/loot',
            tooltipText= 'SetCVar("autoopenloothistory", "1")',
            checked= C_CVar.GetCVarBool("autoopenloothistory"),
            func= function ()
                local value= C_CVar.GetCVarBool("autoopenloothistory")
                Save.autoopenloothistory= not value and true or false
                e.set_CVar('autoopenloothistory', value)--自动打开战利品掷骰窗口
            end
        }
        UIDropDownMenu_AddButton(info, level)

    elseif type=='BATTLEFIELDS' then--战场
        info={
            text= e.onlyChinse and '释放, 复活' or (BATTLE_PET_RELEASE..', '..RESURRECT),
            checked= Save.ReMe,
            func= function()
                Save.ReMe= not Save.ReMe and true or nil
            end
        }
        UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinse and '职责确认' or ROLE_POLL,
            checked= Save.autoSetPvPRole,
            func= function()
                Save.autoSetPvPRole= not Save.autoSetPvPRole and true or nil 
            end
        }
        UIDropDownMenu_AddButton(info, level)

    else
        local isLeader, isTank, isHealer, isDPS = GetLFGRoles()--角色职责
        info={
            text= (e.onlyChinse and '设置' or SETTINGS)..(isLeader and e.Icon.leader or '')
            ..(isTank and e.Icon.TANK or '')
            ..(isHealer and e.Icon.HEALER or '')
            ..(isDPS and e.Icon.DAMAGER or '')
            ..((not isTank and not isHealer and not isDPS) and ' |cnRED_FONT_COLOR:'..ROLE..'|r' or '')
            ..(not Save.hideQueueStatus and '|A:groupfinder-eye-frame:0:0|a' or '')
            ..(Save.autoROLL and '|TInterface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47:0|t' or ''),--提示信息
            notCheckable=true,
            menuList='SETTINGS',
            hasArrow=true,
        }
        UIDropDownMenu_AddButton(info, level)

        isTank, isHealer, isDPS = GetPVPRoles()--检测是否选定角色pve
        info={
            text=e.onlyChinse and '战场' or BATTLEFIELDS
            ..(isTank and e.Icon.TANK or '')
            ..(isHealer and e.Icon.HEALER or '')
            ..(isDPS and e.Icon.DAMAGER or ''),
            notCheckable=true,
            menuList='BATTLEFIELDS',
            hasArrow=true,
        }
        UIDropDownMenu_AddButton(info, level)

        UIDropDownMenu_AddSeparator(level)
        if  raidList(self, level, type) then --团本
            UIDropDownMenu_AddSeparator(level)
        end
        partyList(self, level, type)--随机
    end
end


--###############
--离开, 进入, 副本
--###############
local function setLFGDungeonReadyDialog(self)--自动进入FB LFGDungeonReadyDialog:HookScript("OnShow"
    if Save.enterInstance then
        e.PlaySound()--播放, 声音
    end
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
                ..(totalEncounters and completedEncounters and totalEncounters>0 and '\n|cnGREEN_FONT_COLOR:'..completedEncounters..'|r /'..totalEncounters..' '..(e.onlyChinse and '首领' or BOSS) or '')
                ..(numMembers and '\n'..numMembers..' '..(e.onlyChinse and '玩家' or PLAYER)  or '')
                ..(isHoliday and '\n'..(e.onlyChinse and '节日' or CALENDAR_FILTER_HOLIDAYS).. ' '..(e.onlyChinse and '副本' or INSTANCE) or '')
    end
    self.infoText:SetText(text)
    if not Save.enterInstance or afk then
        e.Ccool(self, nil, 38, nil, true, true)
        if Save.enterInstance and afk then
            print(id, addName, '|cnRED_FONT_COLOR:'..(e.onlyChinse and '不能' or NO)..'|r', e.onlyChinse and '准备进入' or BATTLEFIELD_CONFIRM_STATUS, '|cnRED_FONT_COLOR:'..(e.onlyChinse and '离开中' or CHAT_FLAG_AFK))
        end
        return
    end
    if name then
        print(id, addName, e.onlyChinse and '准备进入' or QUEUED_STATUS_PROPOSAL,'|cnGREEN_FONT_COLOR:'..sec..'|r', e.onlyChinse and '秒' or SECONDS)
        if text~='' then
            text=text:gsub('\n', ' ')
            print(text)
        end
    end
    e.Ccool(self, nil, sec, nil, true, true)
    C_Timer.After(sec, function()
        if self and self.enterButton and self:IsShown() and self.enterButton:IsEnabled() and not IsModifierKeyDown() then
            self.enterButton:Click()
        end
    end)
end

local ExitIns
local function exitInstance()
    local ins
    ins= IsInInstance()
    local name, _, _, difficultyName, _, _, _, instanceID = GetInstanceInfo()
    ins = ins and name and difficultyName
    if ins then
        name= name..difficultyName
        wowSave[INSTANCE][name]=wowSave[INSTANCE][name]  and wowSave[INSTANCE][name] +1 or 1
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
    print(id, addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinse and '离开' or LEAVE)..'|r'..(name or (e.onlyChinse and '副本' or INSTANCE)), name and '|cnGREEN_FONT_COLOR:'..wowSave[INSTANCE][name]..'|r'..(e.onlyChinse and '次' or VOICEMACRO_LABEL_CHARGE1) or '')
    ExitIns=nil
end

StaticPopupDialogs[addName..'ExitIns']={
    text =id..'('..addName..')\n\n|cff00ff00'..(e.onlyChinse and '离开' or LEAVE)..'|r: ' ..(e.onlyChinse and '副本' or INSTANCE).. '|cff00ff00 '..sec..' |r'..(e.onlyChinse and '秒' or SECONDS),
    button1 = LEAVE,
    button2 = CANCEL,
    OnAccept=function()
        ExitIns=true
        exitInstance()
    end,
    OnCancel=function(_, _, d)
        if d=='clicked' then
            ExitIns=nil
            print(id,addName,'|cff00ff00'..(e.onlyChinse and '取消' or CANCEL)..'|r', e.onlyChinse and '离开' or LEAVE)
        end
    end,
    EditBoxOnEscapePressed = function(s)
        ExitIns=nil
        print(id,addName,'|cff00ff00'..(e.onlyChinse and '取消' or CANCEL)..'|r', e.onlyChinse and '离开' or LEAVE)
        s:GetParent():Hide()
    end,
whileDead=true,timeout=sec, hideOnEscape =true,}

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
            self.island:SetText(e.onlyChinse and '离开' or LEAVE)
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
                e.tips:AddDoubleLine(e.onlyChinse and '海岛探险' or ISLANDS_HEADER, (wowSave[ISLANDS_HEADER] and wowSave[ISLANDS_HEADER] or 0)..' '..(e.onlyChinse and '次' or VOICEMACRO_LABEL_CHARGE1))
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(e.onlyChinse and '离开海岛' or ISLAND_LEAVE, e.Icon.left)
                e.tips:AddDoubleLine(e.onlyChinse and '移动' or NPE_MOVE, e.Icon.right)
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


local function setHoliday()--节日, 提示, panel.texture
    panel.dungeonID=nil
    panel.name=nil
    for i=1, GetNumRandomDungeons() do
        local dungeonID, name = GetLFGRandomDungeonInfo(i)
        if dungeonID then
            local isAvailableForAll, isAvailableForPlayer, hid2eIfNotJoinable = IsLFGDungeonJoinable(dungeonID)
            if (isAvailableForPlayer or not hid2eIfNotJoinable) and isAvailableForAll then
                local isHoliday= select(15, GetLFGDungeonInfo(dungeonID))
                if isHoliday then
                    local numRewards = select(6, GetLFGDungeonRewards(dungeonID))
                    if numRewards and numRewards>0 then--奖励物品
                        for i2=1 , numRewards do
                            local texturePath=select(2, GetLFGDungeonRewardInfo(dungeonID, i2))
                            if texturePath then
                                setTexture(dungeonID, nil, name, texturePath)--设置图标, 点击,提示
                                return
                            end
                        end
                    end
                end
            end
        end
    end

    setTexture()--设置图标
end

--####
--初始
--####
local function Init()
    panel:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
    WoWToolsChatButtonFrame.last=panel

    panel.Menu= CreateFrame("Frame",nil, LFDMicroButton, "UIDropDownMenuTemplate")--菜单列表
    UIDropDownMenu_Initialize(panel.Menu, InitList, "MENU")
    
    panel:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' and (self.dungeonID or self.RaidID) then
            if self.dungeonID then
                LFDQueueFrame_SetType(self.dungeonID)
                LFDQueueFrame_Join()
                printListInfo()--输出当前列表
            else
                RaidFinderQueueFrame_SetRaid(self.RaidID)
                RaidFinderQueueFrame_Join()
                printListInfo()--输出当前列表
            end
        else
            ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
        end
    end)
    panel:SetScript('OnEnter',function(self)
        if self.name and (self.dungeonID or self.RaidID) then
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddLine(self.name..e.Icon.left)
            e.tips:Show()
        end
    end)
    panel:SetScript('OnLeave', function() e.tips:Hide() end)

    LFGDungeonReadyDialog:HookScript("OnShow", setLFGDungeonReadyDialog)--自动进入FB

    hooksecurefunc(QueueStatusFrame, 'Update', setQueueStatus)--小眼睛, 更新信息, QueueStatusFrame.lua

    local isLeader, isTank, isHealer, isDPS = GetLFGRoles()--检测是否选定角色pve
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
        SetLFGRoles(isLeader, isTank, isHealer, isDPS)
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

    LFDRoleCheckPopup:SetScript("OnShow",function(self)--副本职责
        if not Save.autoSetPvPRole then
            return
        end
        e.PlaySound()--播放, 声音
        set_PvPRoles()--检测是否选定角色pvp
        if not LFDRoleCheckPopupAcceptButton:IsEnabled() then
            LFDRoleCheckPopup_UpdateAcceptButton();
        end
        print(id, addName, e.onlyChinse and '职责确认' or ROLE_POLL,'|cff00ff00'..ACCEPT, SecondsToTime(sec))
        e.Ccool(self, nil, sec, nil, true, true)--设置冷却
        C_Timer.After(sec, function()
            if LFDRoleCheckPopupAcceptButton:IsEnabled() and not IsModifierKeyDown() then
                local t=LFDRoleCheckPopupDescriptionText:GetText()
                if t then
                    print(id, addName, '|cffff00ff'.. t)
                end
                LFDRoleCheckPopupAcceptButton:Click()
            end
        end)
    end)

    setHoliday()--节日, 提示, panel.texture

    e.set_CVar('autoopenloothistory', Save.autoopenloothistory)--自动打开战利品掷骰窗口
    --hooksecurefunc('QueueStatusDropDown_Show', setQueueStatusMenu)--小眼睛, 信息, 设置菜单
    --LFDMicroButton:HookScript('OnEnter', function(self2) ToggleDropDownMenu(1, nil, menuList, self2, -250,250) end)
end

local function setSTART_LOOT_ROLL(rollID, rollTime, lootHandle)--自动ROLL
    local isRandomInstance=select(10, GetInstanceInfo()) and true or nil
    if not (Save.autoROLL or (Save.leaveInstance and isRandomInstance)) or not rollID then
        return
    end

    local _, _, _, quality, bindO_nPickUp, canNeed, canGreed, _, reasonNeed, reasonGreed = GetLootRollItemInfo(rollID)
    local rollType= canNeed and 1 or 2
    local text= canNeed and (e.onlyChinse and '需求' or NEED) or canGreed and (e.onlyChinse and '贪婪' or GREED) or (e.onlyChinse and '无' or NONE)
    local link = GetLootRollItemLink(rollID)
    local find

    if (quality and quality>=4) or not canNeed or isRandomInstance or not link then
        RollOnLoot(rollID, rollType)
        find=true

    else
        if not C_TransmogCollection.PlayerHasTransmogByItemInfo(link) then--幻化
            local sourceID=select(2,C_TransmogCollection.GetItemInfo(link))
            if sourceID then
                local hasItemData, canCollect =  C_TransmogCollection.PlayerCanCollectSource(sourceID)
                if hasItemData and canCollect then
                    local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
                    if sourceInfo and not sourceInfo.isCollected then
                        RollOnLoot(rollID, rollType)
                        find=true
                    end
                end
            end
        end
        if not find then
            local itemID, _, itemSubType, itemEquipLoc, _, classID, subclassID = GetItemInfoInstant(link)
            local slot=itemEquipLoc and e.itemSlotTable[itemEquipLoc]--比较装等
            if slot then
                local slotLink=GetInventoryItemLink('player', slot)
                if slotLink then
                    local slotItemLevel= GetDetailedItemLevelInfo(slotLink) or 0
                    local itemLevel= GetDetailedItemLevelInfo(link)
                    if itemLevel then
                        local num=itemLevel-slotItemLevel
                        if num>0 then
                            RollOnLoot(rollID, rollType)
                            find=true
                        end
                    end
                else--没有装备
                    RollOnLoot(rollID, rollType)
                    find=true
                end

            elseif classID==15 and subclassID==2 then--宠物物品
                RollOnLoot(rollID, rollType)
                find=true
            elseif classID==15 and  subclassID==5 then--坐骑
                local mountID = C_MountJournal.GetMountFromItem(itemID)
                if mountID then
                    local isCollected =select(11, C_MountJournal.GetMountInfoByID(mountID))
                    if not isCollected then
                        RollOnLoot(rollID, rollType)
                        find=true
                    end
                end

            elseif C_ToyBox.GetToyInfo(itemID) and not PlayerHasToy(itemID) then--玩具 
                RollOnLoot(rollID, rollType)
                find=true
            end
        end
    end
    if find then
        C_Timer.After(1, function()
            print(id, addName, link, text)
        end)
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

panel:RegisterEvent('LFG_UPDATE_RANDOM_INFO')
panel:RegisterEvent('START_LOOT_ROLL')

panel:RegisterEvent('PVP_MATCH_COMPLETE')

panel:RegisterEvent('CORPSE_IN_RANGE')--仅限战场，释放, 复活
panel:RegisterEvent('PLAYER_DEAD')
panel:RegisterEvent('AREA_SPIRIT_HEALER_IN_RANGE')

panel:RegisterEvent('LFG_ROLE_CHECK_ROLE_CHOSEN')
panel:RegisterEvent('LFG_ROLE_CHECK_DECLINED')
panel:RegisterEvent('LFG_QUEUE_STATUS_UPDATE')
panel:RegisterEvent('UPDATE_BATTLEFIELD_STATUS')
panel:RegisterEvent('GROUP_LEFT')
panel:RegisterEvent('PLAYER_ROLES_ASSIGNED')--职责确认


local RoleC
local function get_Role_Info(env, Name, isT, isH, isD)--职责确认，信息
    if env=='LFG_ROLE_CHECK_DECLINED' then
        if panel.RoleInfo then
            panel.RoleInfo.text:SetText('')
            panel.RoleInfo:Hide()
        end
        local co=GetNumGroupMembers();
        if co and co>0 then
            local find
            local raid=IsInRaid()
            local u= raid and 'raid' or 'party'
            for i=1, co do
                local u2=u..i;
                if not raid and i==co then
                    u2='player'
                end
                local guid=UnitGUID(u2);
                local line=e.PlayerOnlineInfo(u2)
                if line and guid then
                    print(line, e.GetPlayerInfo(nil, guid, true), e.Icon.map2, e.GetUnitMapName(u2))
                    find=true
                end
            end
            if find then
                print(id, addName)
            end
        end
        return

    elseif env=='UPDATE_BATTLEFIELD_STATUS' or env=='LFG_QUEUE_STATUS_UPDATE' or env=='GROUP_LEFT' or env=='PLAYER_ROLES_ASSIGNED' then
        if panel.RoleInfo then
            panel.RoleInfo.text:SetText('')
            panel.RoleInfo:Hide()
            RoleC=nil;
        end
        return;
    end

    if not Name or not (isT or  isH or  isD) then
        return
    end

    if env=='LFG_ROLE_CHECK_ROLE_CHOSEN' then--队长重新排本
        if RoleC and RoleC[Name] then
            local u=RoleC[Name].unit;
            if u and UnitIsGroupLeader(u) then
                RoleC=nil;
            end
        end
    end

    local co=GetNumGroupMembers();
    if co and co>0 then
        if not RoleC then
            RoleC={};
            local raid=IsInRaid()
            local u= raid and 'raid' or 'party'
            for i=1, co do
                local u2=u..i
                if not raid and i==co then
                    u2='player'
                end
                local guid=UnitGUID(u2);
                if guid then
                    local info=(e.PlayerOnlineInfo(u2) or '')..e.GetPlayerInfo(nil, guid, true)
                    local name=GetUnitName(u2,true);
                    local player=UnitIsUnit('player', u2);
                    RoleC[name]={
                        info=info,
                        index=i,
                        unit=u2,
                        player=player,
                    }
                end
            end
        end

        local all=0;
        local role='';
        if RoleC[Name] then
            if isT then role=role..INLINE_TANK_ICON end
            if isH then role=role..INLINE_HEALER_ICON end
            if isD then role=role..INLINE_DAMAGER_ICON end
            RoleC[Name].role=role;
        else
            all=1;
        end

        local m='';
        local playerMapID=select(2, e.GetUnitMapName('player'))
        for k, v in pairs(RoleC) do
            if v then
                if m~='' then m=m..'\n' end
                m=m..(v.role and v.role or v.index..')')..(v.info or k)
                if v.role then
                    all=all+1
                end
                local text, unitMapID=e.GetUnitMapName(v.unit)
                if text and unitMapID~= playerMapID then
                    m=m..RED_FONT_COLOR_CODE..e.Icon.map2..text..'|r'
                end
            end
        end

        if m~='' and not panel.RoleInfo then
            panel.RoleInfo=e.Cbtn(nil, nil, nil, nil, nil, true, {20,20})
            if Save.RoleInfoPoint then
                panel.RoleInfo:SetPoint(Save.RoleInfoPoint[1], UIParent, Save.RoleInfoPoint[3], Save.RoleInfoPoint[4], Save.RoleInfoPoint[5])
            else
                panel.RoleInfo:SetPoint('TOPLEFT', panel, 'BOTTOMLEFT', 40, 40)
                panel.RoleInfo:SetButtonState('PUSHED')
            end
            panel.RoleInfo:RegisterForDrag("RightButton")
            panel.RoleInfo:SetMovable(true)
            panel.RoleInfo:SetClampedToScreen(true)
            panel.RoleInfo:SetScript("OnDragStart", function(self)
                self:StartMoving()
            end)
            panel.RoleInfo:SetScript("OnDragStop", function(self)
                ResetCursor()
                self:StopMovingOrSizing()
                Save.RoleInfoPoint={self:GetPoint(1)}
                Save.RoleInfoPoint[2]=nil
            end)
            panel.RoleInfo:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(id, addName)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(e.onlyChinse and '全部清除' or CLEAR_ALL, e.Icon.left)
                e.tips:AddDoubleLine(e.onlyChinse and '移动' or NPE_MOVE, e.Icon.right)
                e.tips:Show()
            end)
            panel.RoleInfo:SetScript('OnLeave', function() e.tips:Hide() end)
            panel.RoleInfo:SetScript('OnMouseDown', function(self, d)
                if d=='RightButton' then--移动光标
                    SetCursor('UI_MOVE_CURSOR')
                elseif d=='LeftButton' then
                    self.text:SetText('')
                    self:SetShown(false)
                end
            end)
            panel.RoleInfo:SetScript("OnMouseUp", function(self)
                ResetCursor()
            end)
            panel.RoleInfo.text=e.Cstr(panel.RoleInfo)
            panel.RoleInfo.text:SetPoint('BOTTOMLEFT')--, panel.RoleInfo, 'BOTTOMRIGHT')
            panel.RoleInfo:SetShown(false)
        end
        if panel.RoleInfo then
            panel.RoleInfo.text:SetText(m)
            panel.RoleInfo:SetShown(m~='')
        end

    elseif panel.RoleInfo then
        panel.RoleInfo:SetShown(false)
    end
end

panel:SetScript("OnEvent", function(self, event, arg1, arg2, arg3, arg4)
    if event == "ADDON_LOADED" and arg1==id then
            if WoWToolsChatButtonFrame.disabled then--禁用Chat Button
                panel:UnregisterAllEvents()
            else
                Save= WoWToolsSave and WoWToolsSave[addName] or Save
                wowSave=WoWToolsSave and WoWToolsSave[INSTANCE] or wowSave
                Init()
            end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
            WoWToolsSave[INSTANCE]=wowSave
        end

    elseif event=='LFG_COMPLETION_REWARD' or event=='LOOT_CLOSED' then--自动离开
        if Save.leaveInstance and IsLFGComplete() and IsInInstance() then
            e.PlaySound()--播放, 声音
            ExitIns=true
            C_Timer.After(sec, function()
                exitInstance()
            end)
            StaticPopup_Show(addName..'ExitIns')
            e.Ccool(StaticPopup1, nil, sec, nil, true)--冷却条
        end
    elseif event=='PLAYER_ENTERING_WORLD' then
        if IsInInstance() then--自动离开
            panel:RegisterEvent('LOOT_CLOSED')
        else
            panel:UnregisterEvent('LOOT_CLOSED')
        end
        C_Timer.After(sec, function()
            setIslandButton(self)--离开海岛按钮
        end)

    elseif event=='ISLAND_COMPLETED' then--离开海岛
        wowSave[ISLANDS_HEADER]=wowSave[ISLANDS_HEADER] and wowSave[ISLANDS_HEADER]+1 or 1
        if not Save.leaveInstance then
            return
        end
        e.PlaySound()--播放, 声音
        C_PartyInfo.LeaveParty(LE_PARTY_CATEGORY_INSTANC)
        LFGTeleport(true)
        print(id, addName, 	e.onlyChinse and '离开海岛' or ISLAND_LEAVE, '|cnGREEN_FONT_COLOR:'..wowSave[ISLANDS_HEADER]..'|r'..	VOICEMACRO_LABEL_CHARGE1)

    elseif event=='LFG_UPDATE_RANDOM_INFO' then
        setHoliday()--节日, 提示, panel.texture

    elseif event=='START_LOOT_ROLL' then
        setSTART_LOOT_ROLL(arg1, arg2, arg3)

    elseif event=='CORPSE_IN_RANGE' or event=='PLAYER_DEAD' or event=='AREA_SPIRIT_HEALER_IN_RANGE' then--仅限战场，释放, 复活
        if Save.ReMe and (C_PvP.IsBattleground() or C_PvP.IsArena()) then
            if event=='PLAYER_DEAD' then
                print(id, addName,'|cnGREEN_FONT_COLOR:'..(e.onlyChinse and '释放, 复活' or (BATTLE_PET_RELEASE..', '..RESURRECT)))
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
            print(id, addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinse and '离开战场' or LEAVE_BATTLEGROUND), SecondsToTime(sec))
            C_Timer.After(sec, function()
                if not IsModifierKeyDown() then
                    if IsInLFDBattlefield() then
                        ConfirmOrLeaveLFGParty();
                    else
                        ConfirmOrLeaveBattlefield();
                    end
                end
            end)
        end

    elseif event=='LFG_ROLE_CHECK_ROLE_CHOSEN' or event=='LFG_ROLE_CHECK_DECLINED' or event=='LFG_QUEUE_STATUS_UPDATE' or event=='UPDATE_BATTLEFIELD_STATUS' or event=='GROUP_LEFT,PLAYER_ROLES_ASSIGNED' then
        get_Role_Info(event, arg1, arg2, arg3, arg4)--职责确认
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
