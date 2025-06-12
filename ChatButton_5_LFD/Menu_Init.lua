
local function Save()
    return WoWToolsSave['ChatButton_LFD'] or {}
end





--RaidFinder.lua
local function isRaidFinderDungeonDisplayable(dungeonID)
    local _, _, _, minLevel, maxLevel, _, _, _, expansionLevel = GetLFGDungeonInfo(dungeonID)
    local myLevel = WoWTools_DataMixin.Player.Level
    return myLevel >= minLevel and myLevel <= maxLevel and EXPANSION_LEVEL >= expansionLevel
end








local function Set_Tooltip(tooltip, desc)
    local dungeonName= desc.data.dungeonName
    local dungeonID= desc.data.dungeonID
    local num= WoWTools_LFDMixin:Get_Instance_Num(dungeonName)

    local bossKillText= desc.data.bossKillText
    local bossTab= desc.data.bossTab
    local modifiedDesc= desc.data.modifiedDesc


    local rewardID, rewardType, rewardArg= desc.data.rewardIndex, desc.data.rewardType, desc.data.rewardArg

    if ( rewardType == "reward" ) then
		tooltip:SetLFGDungeonReward(dungeonID, rewardID)

	elseif ( rewardType == "shortage" ) then
		tooltip:SetLFGDungeonShortageReward(dungeonID, rewardArg, rewardID)
	end

    if rewardType then
        tooltip:AddLine(' ')
    end

    local _, moneyAmount, _, experienceGained = GetLFGDungeonRewards(dungeonID)
    if experienceGained>0 and moneyAmount>0 then

        tooltip:AddDoubleLine(
            experienceGained> 0 and experienceGained..'|A:GarrMission_CurrencyIcon-Xp:0:0|a' or ' ',
            moneyAmount > 0 and SetTooltipMoney(tooltip, moneyAmount, nil)
        )
    end

    if bossKillText then
        tooltip:AddLine(' ')
        tooltip:AddLine(bossKillText)
    end
    if bossTab then
        for index, text in pairs(bossTab) do
            tooltip:AddLine(index..') '..text)
        end
    end
    if modifiedDesc then
        tooltip:AddLine(' ')
        tooltip:AddLine(modifiedDesc, nil,nil,nil, true)
    end

    if rewardType
        or experienceGained>0
        or moneyAmount>0
        or bossKillText
        or bossTab
        or modifiedDesc
    then
        tooltip:AddLine(' ')
    end
    tooltip:AddLine(WoWTools_TextMixin:CN(dungeonName))
    tooltip:AddDoubleLine(
        (num and (WoWTools_DataMixin.onlyChinese and '完成' or COMPLETE)..' '..num or ''),
        (dungeonID and 'dungeonID '..dungeonID or nil)
    )
end







local function Add_Initializer(btn, desc)
    if not btn.leftTexture then
        btn.leftTexture = btn:AttachTexture()
        btn.leftTexture:SetSize(20, 20)
        btn.leftTexture:SetAtlas(WoWTools_DataMixin.Icon.toRight)
        btn.leftTexture:SetPoint("LEFT")
        btn.leftTexture:SetAlpha(0)
        btn.fontString:SetPoint('LEFT', btn.leftTexture, 'RIGHT')
    end
    btn.dungeonID= desc.data.dungeonID

    btn:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed= (self.elapsed or 0.5) +elapsed
        if self.elapsed>0.5 then
            self.elapsed=0
            local r,g,b= 1, 1, 1
            local atlas

            if select(2, GetLFGProposal())==self.dungeonID then
                r,g,b= 1,0,1
                atlas= 'quest-legendary-turnin'

            elseif GetLFGQueueStats(desc.data.type, self.dungeonID) then
                r,g,b= 0,1,0
                atlas= WoWTools_DataMixin.Icon.toRight
            end
            if atlas then
                self.leftTexture:SetAtlas(atlas)
            end
            self.leftTexture:SetAlpha(atlas and 1 or 0)
            self.fontString:SetTextColor(r,g,b)

            if GameTooltip:IsOwned(self) then
                self:SetButtonState('PUSHED')
            end
        end
    end)

    btn:SetScript('OnHide', function(self)
        self:SetScript('OnUpdate', nil)
        self.dungeonID= nil
        self.elapsed=nil
    end)
end

















local function GetLFGLockList()
	local lockInfo = C_LFGInfo.GetLFDLockStates()
	local lockMap = {}
	for _, lock in ipairs(lockInfo) do
		lockMap[lock.lfgID] = lock
	end
	return lockMap
end








--追随者，副本
local function Set_LFGFollower_Dungeon_List(root)--追随者，副本
    if PlayerGetTimerunningSeasonID() then
        return
    end

    local followerList= {}
    local dungeoNum= 0
	for _, dungeonID in ipairs( GetLFDChoiceOrder() or {}) do--LFDFrame.lua
        local lockMap= LFGLockList or GetLFGLockList()
		if not lockMap[dungeonID] or not lockMap[dungeonID].hideEntry then
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
    local reward, rewardIndex, rewardType, rewardArg

    sub= root:CreateButton(WoWTools_DataMixin.onlyChinese and '追随者地下城' or LFG_TYPE_FOLLOWER_DUNGEON, function()
        return MenuResponse.Open
    end)

    for _, dungeonID in pairs(followerList) do
        local info = C_LFGInfo.GetDungeonInfo(dungeonID)
        if info and info.name then
            local isAvailableForAll, isAvailableForPlayer, hid2eIfNotJoinable = IsLFGDungeonJoinable(dungeonID)
            if (isAvailableForAll or not hid2eIfNotJoinable) then


                if isAvailableForPlayer then
                    reward, rewardIndex, rewardType, rewardArg= WoWTools_LFDMixin:GetRewardInfo(dungeonID)
                    sub2= sub:CreateButton(
                            (info.iconID and '|T'..info.iconID..':0|t' or '')
                            ..WoWTools_TextMixin:CN(info.name)
                            ..reward
                            ..(GetLFGDungeonRewards(dungeonID) and format('|A:%s:0:0|a', 'common-icon-checkmark') or ''),

                        function(data)
                            if GetLFGQueueStats(LE_LFG_CATEGORY_LFD, data.dungeonID) then
                                LeaveSingleLFG(LE_LFG_CATEGORY_LFD, data.dungeonID)
                            else
                                LFDQueueFrame_SetTypeInternal('follower')
                                LFDQueueFrame_SetType(data.dungeonID)
                                LFDQueueFrame_Join()
                                WoWTools_LFDMixin:Set_LFDButton_Data(data.dungeonID, LE_LFG_CATEGORY_LFD, WoWTools_TextMixin:CN(data.dungeonName), nil)--设置图标, 点击,提示
                            end
                            return MenuResponse.Open
                        end, {
                            dungeonID=dungeonID,
                            dungeonName=info.name,
                            type=LE_LFG_CATEGORY_LFD,
                            rewardIndex= rewardIndex,
                            rewardType= rewardType,
                            rewardArg= rewardArg,
                        })
                        sub2:SetTooltip(Set_Tooltip)
                    --[[sub2:SetTooltip(function(tooltip, desc)
                        tooltip:AddLine(WoWTools_TextMixin:CN(desc.data.dungeonName)..' ')
                        tooltip:AddLine(' ')
                        tooltip:AddDoubleLine(
                            'dungeonID '..desc.data.dungeonID,
                            WoWTools_LFDMixin:Get_Instance_Num(desc.data.dungeonName)
                        )

                    end)]]

                    sub2:AddInitializer(Add_Initializer)
                end
            end

        end
    end
    WoWTools_MenuMixin:SetGridMode(sub, dungeoNum)
end























--副本， 菜单列表
--5人，随机 LFDFrame.lua
local function set_Party_Menu_List(root)
    local sub, find, reward, rewardIndex, rewardType, rewardArg
    for i=1, GetNumRandomDungeons() do
        local dungeonID, name = GetLFGRandomDungeonInfo(i)
        if dungeonID and name then
            local isAvailableForAll, isAvailableForPlayer, hid2eIfNotJoinable = IsLFGDungeonJoinable(dungeonID)
            if (isAvailableForAll or not hid2eIfNotJoinable) then
                if isAvailableForPlayer then

                    reward, rewardIndex, rewardType, rewardArg= WoWTools_LFDMixin:GetRewardInfo(dungeonID)
                    sub=root:CreateButton(
                        WoWTools_TextMixin:CN(name)
                        ..reward
                        ..(GetLFGDungeonRewards(dungeonID) and format('|A:%s:0:0|a', 'common-icon-checkmark') or ''),

                    function(data)
                        if GetLFGQueueStats(LE_LFG_CATEGORY_LFD, data.dungeonID) then
                            LeaveSingleLFG(LE_LFG_CATEGORY_LFD, data.dungeonID)
                        else
                            LFDQueueFrame_SetTypeInternal('specific')
                            LFDQueueFrame_SetType(data.dungeonID)
                            LFDQueueFrame_Join()
                            WoWTools_LFDMixin:Set_LFDButton_Data(data.dungeonID, LE_LFG_CATEGORY_LFD, WoWTools_TextMixin:CN(data.dungeonName), nil)--设置图标, 点击,提示
                        end
                        return MenuResponse.Open

                    end, {
                        dungeonID=dungeonID,
                        dungeonName=name,
                        type=LE_LFG_CATEGORY_LFD,
                        rewardIndex= rewardIndex,
                        rewardType= rewardType,
                        rewardArg= rewardArg,
                    })

                    sub:SetTooltip(Set_Tooltip)
                    --[[sub:SetTooltip(function(tooltip, desc)
                        tooltip:AddLine(WoWTools_TextMixin:CN(desc.data.dungeonName)..' ')
                        tooltip:AddLine(' ')
                        tooltip:AddDoubleLine('dungeonID '..desc.data.dungeonID, WoWTools_LFDMixin:Get_Instance_Num(desc.data.dungeonName),nil)
                    end)]]

                    sub:AddInitializer(Add_Initializer)

                else
                    sub=root:CreateButton('   |cff9e9e9e'..WoWTools_TextMixin:CN(name)..' |r', function()
                        return MenuResponse.Open
                    end, {
                        dungeonID=dungeonID,
                        dungeonName=name
                    })

                    sub:SetTooltip(function(tooltip, desc)
                        tooltip:AddLine(WoWTools_TextMixin:CN(desc.data.dungeonName)..' ')
                        tooltip:AddLine(' ')
                        tooltip:AddLine('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '你不能进入此队列。' or YOU_MAY_NOT_QUEUE_FOR_THIS))
                        local declined= LFGConstructDeclinedMessage(desc.data.dungeonID)
                        if declined and declined~='' then
                            tooltip:AddLine('|cnRED_FONT_COLOR:'..WoWTools_TextMixin:CN(declined), nil,nil,nil, true)
                        end
                        tooltip:AddLine(' ')
                        tooltip:AddDoubleLine('dungeonID '..desc.data.dungeonID, WoWTools_LFDMixin:Get_Instance_Num(desc.data.dungeonName),nil)
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




















--场景战役 SCENARIOS
local function Init_Scenarios_Menu(root)--ScenarioFinder.lua
    local sub, sub2, reward, rewardIndex, rewardType, rewardArg
    --[[if not PlayerGetTimerunningSeasonID() then
       return
    end]]
    local numScenario= GetNumRandomScenarios() or 0
    if numScenario==0 then
        return
    end

    sub= root:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '场景战役' or SCENARIOS)..' #'..numScenario,
    function()
        return MenuResponse.Open
    end)


    for i=1, numScenario do
        --local id, name, typeID, subtype, minLevel, maxLevel= GetRandomScenarioInfo(i)
        local dungeonID, name = GetRandomScenarioInfo(i)
        if dungeonID and name then
            local isAvailableForAll, isAvailableForPlayer = IsLFGDungeonJoinable(dungeonID)

            if isAvailableForAll and isAvailableForPlayer then
                reward, rewardIndex, rewardType, rewardArg= WoWTools_LFDMixin:GetRewardInfo(dungeonID)
                sub2=sub:CreateButton(
                    --WoWTools_TextMixin:CN(name, {scenarioID=dungeonID, isName=true})..reward,
                    WoWTools_TextMixin:CN(name)..reward,
                function(data)
                    if GetLFGQueueStats(LE_LFG_CATEGORY_SCENARIO) then--not ( mode == "queued" or mode == "listed" or mode == "rolecheck" or mode == "suspended" ) then
                        LeaveLFG(LE_LFG_CATEGORY_SCENARIO)
                    else
                        LFG_JoinDungeon(LE_LFG_CATEGORY_SCENARIO, data.dungeonID, ScenariosList, ScenariosHiddenByCollapseList)--ScenarioQueueFrame_Join() 
                        WoWTools_LFDMixin:Set_LFDButton_Data(data.dungeonID, LE_LFG_CATEGORY_LFD, data.dungeonName, nil)--设置图标, 点击,提示
                    end
                    return MenuResponse.Open

                end, {
                    dungeonID= dungeonID,
                    dungeonName= name,
                    type= LE_LFG_CATEGORY_SCENARIO,
                    rewardIndex= rewardIndex,
                    rewardType= rewardType,
                    rewardArg= rewardArg,
                })
                sub2:SetTooltip(Set_Tooltip)
                --[[sub2:SetTooltip(function(tooltip, desc)
                    tooltip:AddLine(desc.data.dungeonName)
                    tooltip:AddLine(' ')
                    tooltip:AddDoubleLine('dungeonID '..desc.data.dungeonID, WoWTools_LFDMixin:Get_Instance_Num(desc.data.dungeonName), nil)
                end)]]

                sub2:AddInitializer(Add_Initializer)

            else
                sub2=sub:CreateButton('     |cff9e9e9e'..WoWTools_TextMixin:CN(name)..' |r', function()
                    return MenuResponse.Open
                end, {
                    dungeonID= dungeonID,
                    dungeonName=name,
                })

                sub2:SetTooltip(function(tooltip, desc)
                    tooltip:AddLine(WoWTools_TextMixin:CN(desc.data.dungeonName))
                    tooltip:AddLine(' ')
                    tooltip:AddLine('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '你不能进入此队列。' or YOU_MAY_NOT_QUEUE_FOR_THIS))
                    local text= LFGConstructDeclinedMessage(desc.data.dungeonID)
                    if text and text~='' then
                        tooltip:AddLine('|cnRED_FONT_COLOR:'..WoWTools_TextMixin:CN(text))
                    end
                    tooltip:AddLine(' ')
                    tooltip:AddDoubleLine('dungeonID '..desc.data.dungeonID, WoWTools_LFDMixin:Get_Instance_Num(desc.data.dungeonName), nil)
                end)
            end
        end
    end
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


    local currentMapName, find, sub, icon, reward, rewardIndex, rewardType, rewardArg
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
            root:CreateTitle(icon..WoWTools_TextMixin:CN(sortedDungeons[i].mapName))
        end

        local dungeonID= sortedDungeons[i].id
        local dungeonName= sortedDungeons[i].name
        local dungeonMapID= sortedDungeons[i].mapID

        local modifiedDesc, modifiedIcon
        if dungeonMapID then
            local modifiedInstanceInfo = C_ModifiedInstance.GetModifiedInstanceInfoFromMapID(dungeonMapID)
            if (modifiedInstanceInfo) then
                modifiedIcon = '|A:'..GetFinalNameFromTextureKit("%s-small", modifiedInstanceInfo.uiTextureKit)..':0:0|a'
                modifiedDesc = WoWTools_TextMixin:CN(modifiedInstanceInfo.description)--, {lfgDungeonID=dungeonID, isDesc=true})
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
                        ..WoWTools_TextMixin:CN(bossName)
                    )
                end
                bossKillText = format(WoWTools_DataMixin.onlyChinese and '已消灭 |cnGREEN_FONT_COLOR:%d|r/%d 个首领' or BOSSES_KILLED, killNum, bossNum)
                isKillAll= bossNum==killNum
            end

            reward, rewardIndex, rewardType, rewardArg= WoWTools_LFDMixin:GetRewardInfo(dungeonID)
            sub=root:CreateButton(
                ((LfgDungeonID==dungeonID or scenarioName== strlower(dungeonName)) and '|A:auctionhouse-icon-favorite:0:0|a' or '')--在当前副本
                ..(modifiedIcon or '')
                ..(isKillAll and '|cff9e9e9e' or '')
                ..WoWTools_TextMixin:CN(dungeonName)--名称
                ..reward
                ..killText,
            function(data)
                if GetLFGQueueStats(LE_LFG_CATEGORY_RF, data.dungeonID) then
                    LeaveSingleLFG(LE_LFG_CATEGORY_RF, data.dungeonID)
                else
                    WoWTools_Mixin:Call(RaidFinderQueueFrame_SetRaid, data.dungeonID)
                    WoWTools_Mixin:Call(RaidFinderQueueFrame_Join)
                    --printListInfo()--输出当前列表
                    WoWTools_LFDMixin:Set_LFDButton_Data(data.dungeonID, LE_LFG_CATEGORY_RF, WoWTools_TextMixin:CN(data.dungeonName), nil)--设置图标, 点击,提示
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

                rewardIndex= rewardIndex,
                rewardType= rewardType,
                rewardArg= rewardArg,
            })
            sub:SetTooltip(Set_Tooltip)
            --[[sub:SetTooltip(function(tooltip, desc)
                tooltip:AddLine(WoWTools_TextMixin:CN(desc.data.dungeonName)..' ')
                tooltip:AddLine(desc.data.bossKillText)
                tooltip:AddLine(' ')
                for index, text in pairs(desc.data.bossTab) do
                    tooltip:AddLine(index..') '..text)
                end
                if desc.data.modifiedDesc then
                    tooltip:AddLine(' ')
                    tooltip:AddLine(desc.data.modifiedDesc, nil,nil,nil, true)
                end
                tooltip:AddLine(' ')
                tooltip:AddDoubleLine('dungeonID '..desc.data.dungeonID, WoWTools_LFDMixin:Get_Instance_Num(desc.data.dungeonName), nil)
            end)]]

            sub:AddInitializer(Add_Initializer)

        else
            sub=root:CreateButton((modifiedIcon or '')..'|cff9e9e9e'..WoWTools_TextMixin:CN(dungeonName)..' |r', function()
                return MenuResponse.Open
             end, {modifiedDesc=modifiedDesc, dungeonID=dungeonID}
            )
            sub:SetTooltip(function(tooltip, desc)
                tooltip:AddLine('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '你不能进入此队列。' or YOU_MAY_NOT_QUEUE_FOR_THIS))
                local msg= LFGConstructDeclinedMessage(desc.data.dungeonID)
                if msg then
                    tooltip:AddLine('|cnRED_FONT_COLOR:'..WoWTools_TextMixin:CN(msg), 0.62, 0.62, 0.62, true)
                end
                if desc.data.modifiedDesc then
                    tooltip:AddLine(' ')
                    tooltip:AddLine(WoWTools_TextMixin:CN(desc.data.modifiedDesc), nil, nil, nil, true)
                end
                tooltip:AddLine(' ')
                tooltip:AddDoubleLine('dungeonID '..desc.data.dungeonID, WoWTools_LFDMixin:Get_Instance_Num(desc.data.dungeonName),nil)
            end)

        end
        find=true
    end

    if find then
        root:CreateDivider()
    end
end

































--职责，可选列表
local function Init_All_Role(_, root)
    local sub, isLeader, isTank, isHealer, isDPS, tank, healer, dps, num
    local canBeTank, canBeHealer, canBeDamager = UnitGetAvailableRoles("player")
    local cursorRole = select(5, GetSpecializationInfo(GetSpecialization() or 0))

    sub=root:CreateButton('PvE', function()
        PVEFrame_ToggleFrame("GroupFinderFrame", LFDParentFrame)
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(MicroButtonTooltipText('队伍查找器', "TOGGLEGROUPFINDER"))
    end)

    root:CreateDivider()
    for _, role in pairs({'TANK', 'HEALER', 'DAMAGER'}) do
        sub= root:CreateCheckbox(
            WoWTools_DataMixin.Icon[role]
            ..WoWTools_TextMixin:CN(_G[role])
            ..(role==cursorRole and '|A:auctionhouse-icon-favorite:0:0|a' or ''),
        function(data)
            isLeader, isTank, isHealer, isDPS = GetLFGRoles()
            if data.role=='TANK' then
                return isTank
            elseif data.role=='HEALER' then
                return isHealer
            elseif data.role=='DAMAGER' then
                return isDPS
            end
        end, function(data)
            isLeader, isTank, isHealer, isDPS = GetLFGRoles()
            if data.role=='TANK' then
                isTank= not isTank
            elseif data.role=='HEALER' then
                isHealer= not isHealer
            elseif data.role=='DAMAGER' then
                isDPS= not isDPS
            end
            SetLFGRoles(isLeader, isTank, isHealer, isDPS)
        end, {role=role})

        if role=='TANK' then
            sub:SetEnabled(canBeTank)
        elseif role=='HEALER' then
            sub:SetEnabled(canBeHealer)
        elseif role=='DAMAGER' then
            sub:SetEnabled(canBeDamager)
        end
    end

    sub=root:CreateButton('PvP', function()
        PVEFrame_ToggleFrame("GroupFinderFrame", RaidFinderFrame)
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(MicroButtonTooltipText('队伍查找器', "TOGGLEGROUPFINDER"))
    end)

    root:CreateDivider()

    tank, healer, dps = GetPVPRoles()--检测是否选定角色PVP

    for _, role in pairs({'TANK', 'HEALER', 'DAMAGER'}) do
        sub= root:CreateCheckbox(
            WoWTools_DataMixin.Icon[role]
            ..WoWTools_TextMixin:CN(_G[role])
            ..(role==cursorRole and '|A:auctionhouse-icon-favorite:0:0|a' or ''),
        function(data)
            tank, healer, dps = GetPVPRoles()
            if data.role=='TANK' then
                return tank
            elseif data.role=='HEALER' then
                return healer
            elseif data.role=='DAMAGER' then
                return dps
            end
        end, function(data)
            tank, healer, dps = GetPVPRoles()
            if data.role=='TANK' then
                tank= not tank
            elseif data.role=='HEALER' then
                healer= not healer
            elseif data.role=='DAMAGER' then
                dps= not dps
            end
            SetPVPRoles(tank, healer, dps)
        end, {role=role})

        if role=='TANK' then
            sub:SetEnabled(canBeTank)
        elseif role=='HEALER' then
            sub:SetEnabled(canBeHealer)
        elseif role=='DAMAGER' then
            sub:SetEnabled(canBeDamager)
        end
    end

    root:SetGridMode(MenuConstants.VerticalGridDirection, 2)

end




















--初始菜单
local function Init_Menu(_, root)
    local sub, sub2, sub3, tab, line, num
    local isLeader, isTank, isHealer, isDPS = GetLFGRoles()--角色职责
    local tank, healer, dps


--设置
    local text=''
    if (isTank or isHealer or isDPS) then
        text= (isTank and WoWTools_DataMixin.Icon.TANK or '')
                ..(isHealer and WoWTools_DataMixin.Icon.TANK or '')
                ..(isDPS and WoWTools_DataMixin.Icon.DAMAGER or '')
                ..(isLeader and '|A:UI-HUD-UnitFrame-Player-Group-GuideIcon:0:0|a' or '')
    else
        text='|A:QuestLegendaryTurnin:0|a|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '无职责' or NO_ROLE)..'|r'
    end

--离开副本
    if Save().leaveInstance then
        text= text..'|A:common-icon-rotateleft:0:0|a'
    end
--释放, 复活
    if Save().ReMe and (Save().ReMe_AllZone and (not IsInInstance() or not IsInGroup('LE_PARTY_CATEGORY_HOME'))) then
        text= text..'|A:poi-soulspiritghost:0:0|a'
    end

    sub=root:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS)..text,
    function()
        PVEFrame_ToggleFrame("GroupFinderFrame")
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(MicroButtonTooltipText('队伍查找器', "TOGGLEGROUPFINDER"))
    end)






--设置, 小眼睛, 信息
    sub2=sub:CreateCheckbox('|A:common-icon-rotateleft:0:0|a'..(WoWTools_DataMixin.onlyChinese and '离开副本' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC,LEAVE, INSTANCE)), function()
        return Save().leaveInstance
    end, function()
        Save().leaveInstance= not Save().leaveInstance and true or nil
        WoWTools_LFDMixin:Set_Queue_Status()--小眼睛, 信息
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '离开副本和战场' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LEAVE, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, INSTANCE, BATTLEFIELDS)))
        tooltip:AddLine(' ')
        if WoWTools_DataMixin.onlyChinese then
            tooltip:AddLine('离开随机: 自动掷骰')
        else
            tooltip:AddLine(format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LEAVE,LFG_TYPE_RANDOM_DUNGEON))
            tooltip:AddLine(format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, ROLL))
        end
    end)





--设置, 信息 QueueStatusFrame.lua
    sub2=sub:CreateCheckbox('|A:groupfinder-eye-frame:0:0|a'..(WoWTools_DataMixin.onlyChinese and '列表信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SOCIAL_QUEUE_TOOLTIP_HEADER,INFO)), function()
        return not Save().hideQueueStatus
    end, function()
        Save().hideQueueStatus = not Save().hideQueueStatus and true or nil
        WoWTools_LFDMixin:Set_Queue_Status()
    end)

    sub2:CreateButton(
        (Save().tipsFramePoint and '' or '|cff9e9e9e')..(WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION),
    function()
        Save().tipsFramePoint=nil
        if WoWTools_LFDMixin.TipsButton then
            WoWTools_LFDMixin.TipsButton:ClearAllPoints()
            WoWTools_LFDMixin.TipsButton:set_Point()
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_LFDMixin.addName, WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION)
        end
        return MenuResponse.Open
    end)





--设置, 预创建队伍增强
    sub2=sub:CreateCheckbox('|A:UI-HUD-MicroMenu-Groupfinder-Mouseover:0:0|a'..(WoWTools_DataMixin.onlyChinese and '预创建队伍增强' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LFGLIST_NAME, 'Plus')), function()
        return Save().LFGPlus
    end, function()
        Save().LFGPlus = not Save().LFGPlus and true or nil
        if WoWTools_LFDMixin.LFGPlusButton then
            WoWTools_LFDMixin.LFGPlusButton:set_texture()
        end
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
    end)





--职责确认
    sub2=sub:CreateCheckbox('|A:quest-legendary-turnin:0:0|a'..(WoWTools_DataMixin.onlyChinese and '职责确认' or ROLE_POLL), function()
        return Save().autoSetPvPRole
    end, function()
        Save().autoSetPvPRole= not Save().autoSetPvPRole and true or nil
    end)

--职责，可选列表
    Init_All_Role(_, sub2)


--设置,战场
    sub:CreateDivider()
    tank, healer, dps = GetPVPRoles()--检测是否选定角色PVP
    sub:CreateTitle(
        (WoWTools_DataMixin.onlyChinese and '战场' or BATTLEFIELDS)
        ..(tank and WoWTools_DataMixin.Icon.TANK or '')
        ..(healer and WoWTools_DataMixin.Icon.TANK or '')
        ..(dps and WoWTools_DataMixin.Icon.DAMAGER or '')
    )

--释放, 复活    
    sub2=sub:CreateCheckbox(
        '|A:poi-soulspiritghost:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '释放, 复活' or (BATTLE_PET_RELEASE..', '..RESURRECT)),
    function()
        return Save().ReMe
    end, function()
        Save().ReMe= not Save().ReMe and true or nil
        WoWTools_LFDMixin:Init_RepopMe()
    end)

--所有地区
    sub3=sub2:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '其它' or OTHER,
    function()
        return Save().ReMe_AllZone
    end, function()
        Save().ReMe_AllZone= not Save().ReMe_AllZone and true or false
        WoWTools_LFDMixin:Init_RepopMe()
    end)
    sub3:SetTooltip(function(tooltip)
       tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '有队伍副本除外' or  'Except for group instance')
    end)







--前往副本 Plus
    sub:CreateDivider()
    sub2= sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '前往副本' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PET_ACTION_MOVE_TO, INSTANCE),
    function()
        return not Save().disabledLFGDungeonReadyDialog
    end, function()
        Save().disabledLFGDungeonReadyDialog= not Save().disabledLFGDungeonReadyDialog and true or nil
        WoWTools_LFDMixin:Init_LFGDungeonReadyDialog()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('LFGDungeonReadyDialog')
        tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '信息' or INFO, WoWTools_DataMixin.onlyChinese and '队伍查找器' or DUNGEONS_BUTTON)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '已经建好了一个副本，准备前往：' or SPECIFIC_INSTANCE_IS_READY)
    end)

--队伍查找器, 接受邀请, 信息
    sub2=sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '邀请信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, INVITE, INFO),
    function()
        return not Save().disabedLFDInviteInfo
    end, function()
        Save().disabedLFDInviteInfo= not Save().disabedLFDInviteInfo and true or nil
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('LFGListInviteDialog_Show')
        tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '信息' or INFO, WoWTools_DataMixin.onlyChinese and '队伍查找器' or DUNGEONS_BUTTON)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '你收到了一支队伍的邀请：' or LFG_LIST_INVITED_TO_GROUP)
    end)





    sub:CreateDivider()
--副本， 次数
    num= 0
    for _, complete in pairs(Save().wow) do
        num= complete+ num
    end
    sub2= sub:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '副本次数' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, INSTANCE, COMPLETE))..' #'..num,
    function()
        return MenuResponse.Open
    end)

    if num>0 then
        sub2:CreateButton(
            WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
        function()
            StaticPopup_Show('WoWTools_OK',
            WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
            nil,
            {SetValue=function()
                Save().wow={}
            end})
            return MenuResponse.Open
        end)
        sub2:CreateDivider()
        for name, complete in pairs(Save().wow) do
            sub3=sub2:CreateCheckbox(
                name=='island' and (WoWTools_DataMixin.onlyChinese and '海岛探险' or ISLANDS_HEADER) or WoWTools_TextMixin:CN(name)..' #|cnGREEN_FONT_COLOR:'..complete,
            function(data)
                return Save().wow[data.name]
            end, function(data)
                Save().wow[name]= not Save().wow[name] and data.complete or nil
            end, {name=name, complete=complete})
            sub3:SetTooltip(function (tooltip)
                tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)
            end)
        end
        WoWTools_MenuMixin:SetScrollMode(sub2)
    end











--战利品掷骰
    sub=root:CreateButton(
        (Save().autoROLL and '|TInterface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47:0|t' or '|A:Levelup-Icon-Bag:0:0|a')
        ..(WoWTools_DataMixin.onlyChinese and '战利品掷骰' or LOOT_ROLL),
    function()
        WoWTools_Mixin:Call(ToggleLootHistoryFrame)
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('/loot ')
    end)

    sub:CreateCheckbox((WoWTools_DataMixin.onlyChinese and '自动掷骰' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, ROLL))..'|TInterface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47:0|t', function()
        return Save().autoROLL
    end, function()
        Save().autoROLL= not Save().autoROLL and true or nil
    end)

    sub:CreateCheckbox('|A:communities-icon-notification:0:0|a'..(WoWTools_DataMixin.onlyChinese and '战利品 Plus' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LOOT, 'Plus')), function()
        return not Save().disabledLootPlus
    end, function()
        Save().disabledLootPlus= not Save().disabledLootPlus and true or nil
    end)











--副本，逃亡者
    local deserterExpiration = GetLFGDeserterExpiration()
    local shouldtext
    local cooldowntext
    if ( deserterExpiration ) then
		shouldtext = format("|cnRED_FONT_COLOR:%s|r "..WoWTools_UnitMixin:GetPlayerInfo(nil, WoWTools_DataMixin.Player.GUID, nil), WoWTools_DataMixin.onlyChinese and '逃亡者' or DESERTER)
        local timeRemaining = deserterExpiration - GetTime()
        if timeRemaining>0 then
            shouldtext= shouldtext..' '..SecondsToTime(ceil(timeRemaining))
        end
	else
		local myExpireTime = GetLFGRandomCooldownExpiration()
        if myExpireTime then
            cooldowntext= format("|cnRED_FONT_COLOR:%s|r "..WoWTools_UnitMixin:GetPlayerInfo(nil, WoWTools_DataMixin.Player.GUID, nil), WoWTools_DataMixin.onlyChinese and '冷却中' or ON_COOLDOWN)
            local timeRemaining = myExpireTime - GetTime()
            if timeRemaining>0 then
                cooldowntext= cooldowntext..' '..SecondsToTime(ceil(timeRemaining))
            end
        end
	end
    for i = 1, GetNumSubgroupMembers() do
        local unit= 'party'..i
		if ( UnitHasLFGDeserter(unit) ) then
			shouldtext= (shouldtext and shouldtext..'|n' or '')..WoWTools_UnitMixin:GetPlayerInfo(unit, nil, nil)..' '..(WoWTools_DataMixin.onlyChinese and '逃亡者' or DESERTER)
		elseif ( UnitHasLFGRandomCooldown(unit) ) then
			cooldowntext= (cooldowntext and cooldowntext..'|n' or '')..WoWTools_UnitMixin:GetPlayerInfo(unit, nil, nil)..' '..(WoWTools_DataMixin.onlyChinese and '冷却中' or ON_COOLDOWN)
		end
    end
    if shouldtext then
        root:CreateDivider()
        root:CreateTitle('|cnGREEN_FONT_COLOR:'..shouldtext)
    end









--显示 LFGDungeonReadyDialog
    if not WoWTools_LFDMixin:ShowMenu_LFGDungeonReadyDialog(root) then

        root:CreateDivider()
    --副本，列表
        Set_LFGFollower_Dungeon_List(root)--追随者，副本
        Init_Scenarios_Menu(root)--场景
        set_Party_Menu_List(root)--随机

        if cooldowntext then
            root:CreateTitle('|cnGREEN_FONT_COLOR:'..cooldowntext)
            root:CreateDivider()
        end
        set_Raid_Menu_List(root)--团本
    else
        root:CreateDivider()
    end


--离开所有队列
    sub=root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '离开所有队列' or LEAVE_ALL_QUEUES,
    function()
        WoWTools_LFDMixin:Leave_All_LFG()
        return MenuResponse.Open
    end)
    sub:AddInitializer(function(btn)
        btn:SetScript("OnUpdate", function(self, elapsed)
            self.elapsed= (self.elapsed or 1.2) +elapsed
            if self.elapsed>1.2 then
                self.elapsed=0
                local queueNum= WoWTools_LFDMixin:Leave_All_LFG(true)
                self.fontString:SetText((queueNum==0 and '|cff9e9e9e' or '')..(WoWTools_DataMixin.onlyChinese and '离开所有队列' or LEAVE_ALL_QUEUES)..' '..queueNum)
            end
        end)
        btn:SetScript('OnHide', function(self)
            self:SetScript('OnUpdate', nil)
            self.elapsed= nil
        end)
    end)


--离开地下堡
    sub:CreateButton(
        (WoWTools_MapMixin:IsInDelve() and '' or '|cff9e9e9e')
        ..(WoWTools_DataMixin.onlyChinese and '离开地下堡' or INSTANCE_WALK_IN_LEAVE),
    function()
        if WoWTools_MapMixin:IsInDelve() then
            StaticPopup_Show('WoWTools_OK',
                (WoWTools_DataMixin.onlyChinese and '离开地下堡' or INSTANCE_WALK_IN_LEAVE)
                ..'|n|n|A:BonusLoot-Chest:32:32|a|cnGREEN_FONT_COLOR:'
                ..(WoWTools_DataMixin.onlyChinese and '注意：奖励' or (LABEL_NOTE..': '..REWARD)),
                nil,
                {SetValue=C_PartyInfo.DelveTeleportOut}
            )
        else
            C_PartyInfo.DelveTeleportOut()
        end
        return MenuResponse.Open
    end)

--离开副本
    sub2=sub:CreateButton(
        (select(10, GetInstanceInfo()) and '' or '|cff9e9e9e')
        ..(WoWTools_DataMixin.onlyChinese and '离开副本' or INSTANCE_LEAVE),
    function()
        if select(10, GetInstanceInfo()) then
            StaticPopup_Show('WoWTools_OK',
                (WoWTools_DataMixin.onlyChinese and '离开副本' or INSTANCE_LEAVE)
                ..'|n|n|A:BonusLoot-Chest:32:32|a|cnGREEN_FONT_COLOR:'
                ..(WoWTools_DataMixin.onlyChinese and '注意：奖励' or (LABEL_NOTE..': '..REWARD)),
                nil,
                {SetValue=function()
                    C_PartyInfo.LeaveParty(LE_PARTY_CATEGORY_INSTANCE)
                    LFGTeleport(true)
                end}
            )
        else
            C_PartyInfo.LeaveParty(LE_PARTY_CATEGORY_INSTANCE)
            LFGTeleport(true)
        end
        return MenuResponse.Open
    end)




--离开载具
    sub:CreateButton(
        (CanExitVehicle() and '' or '|cff9e9e9e')--UnitControllingVehicle("player"
        ..(WoWTools_DataMixin.onlyChinese and '离开载具' or BINDING_NAME_VEHICLEEXIT),
    function()
        WoWTools_Mixin:Call(VehicleExit)
        return MenuResponse.Open
    end)
end














function WoWTools_LFDMixin:Init_Menu(...)
    Init_Menu(...)
end