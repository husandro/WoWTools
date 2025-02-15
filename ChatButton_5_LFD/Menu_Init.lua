local e= select(2, ...)
local function Save()
    return WoWTools_LFDMixin.Save
end





--RaidFinder.lua
local function isRaidFinderDungeonDisplayable(dungeonID)
    local _, _, _, minLevel, maxLevel, _, _, _, expansionLevel = GetLFGDungeonInfo(dungeonID)
    local myLevel = e.Player.level
    return myLevel >= minLevel and myLevel <= maxLevel and EXPANSION_LEVEL >= expansionLevel
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

















local function GetLFGLockList()
	local lockInfo = C_LFGInfo.GetLFDLockStates();
	local lockMap = {};
	for _, lock in ipairs(lockInfo) do
		lockMap[lock.lfgID] = lock;
	end
	return lockMap;
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
                            ..WoWTools_LFDMixin:GetRewardInfo(dungeonID)
                            ..(GetLFGDungeonRewards(dungeonID) and format('|A:%s:0:0|a', e.Icon.select) or ''),

                        function(description)
                            if GetLFGQueueStats(LE_LFG_CATEGORY_LFD, description.dungeonID) then
                                LeaveSingleLFG(LE_LFG_CATEGORY_LFD, description.dungeonID)
                            else
                                LFDQueueFrame_SetTypeInternal('follower')
                                LFDQueueFrame_SetType(description.dungeonID)
                                LFDQueueFrame_Join()
                                WoWTools_LFDMixin:Set_LFDButton_Data(description.dungeonID, LE_LFG_CATEGORY_LFD, e.cn(description.dungeonName), nil)--设置图标, 点击,提示
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
                            WoWTools_LFDMixin:Get_Instance_Num(description.data.dungeonName),''
                        )

                    end)

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
    local sub, find
    for i=1, GetNumRandomDungeons() do
        local dungeonID, name = GetLFGRandomDungeonInfo(i)
        if dungeonID and name then
            local isAvailableForAll, isAvailableForPlayer, hid2eIfNotJoinable = IsLFGDungeonJoinable(dungeonID)
            if (isAvailableForAll or not hid2eIfNotJoinable) then
                if isAvailableForPlayer then


                    sub=root:CreateButton(
                        e.cn(name)
                        ..WoWTools_LFDMixin:GetRewardInfo(dungeonID)
                        ..(GetLFGDungeonRewards(dungeonID) and format('|A:%s:0:0|a', e.Icon.select) or ''),

                    function(description)
                        if GetLFGQueueStats(LE_LFG_CATEGORY_LFD, description.dungeonID) then
                            LeaveSingleLFG(LE_LFG_CATEGORY_LFD, description.dungeonID)
                        else
                            LFDQueueFrame_SetTypeInternal('specific')
                            LFDQueueFrame_SetType(description.dungeonID)
                            LFDQueueFrame_Join()
                            WoWTools_LFDMixin:Set_LFDButton_Data(description.dungeonID, LE_LFG_CATEGORY_LFD, e.cn(description.dungeonName), nil)--设置图标, 点击,提示
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
                        tooltip:AddDoubleLine('dungeonID '..description.data.dungeonID, WoWTools_LFDMixin:Get_Instance_Num(description.data.dungeonName),nil)
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
                        tooltip:AddDoubleLine('dungeonID '..description.data.dungeonID, WoWTools_LFDMixin:Get_Instance_Num(description.data.dungeonName),nil)
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
                        WoWTools_LFDMixin:Set_LFDButton_Data(description.dungeonID, LE_LFG_CATEGORY_LFD, description.dungeonName, nil)--设置图标, 点击,提示
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
                    tooltip:AddDoubleLine('scenarioID '..description.data.dungeonID, WoWTools_LFDMixin:Get_Instance_Num(description.data.dungeonName), nil)
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
                    tooltip:AddDoubleLine('scenarioID '..description.data.dungeonID, WoWTools_LFDMixin:Get_Instance_Num(description.data.dungeonName), nil)
                end)
            end
            find=true
        end
    end
    if find then
        root:CreateDivider()
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
                ..WoWTools_LFDMixin:GetRewardInfo(dungeonID)--名称
                ..killText,
            function(data)
                if GetLFGQueueStats(LE_LFG_CATEGORY_RF, data.dungeonID) then
                    LeaveSingleLFG(LE_LFG_CATEGORY_RF, data.dungeonID)
                else
                    e.call(RaidFinderQueueFrame_SetRaid, data.dungeonID)
                    e.call(RaidFinderQueueFrame_Join)
                    --printListInfo()--输出当前列表
                    WoWTools_LFDMixin:Set_LFDButton_Data(data.dungeonID, LE_LFG_CATEGORY_RF, e.cn(data.dungeonName), nil)--设置图标, 点击,提示
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
                tooltip:AddDoubleLine('dungeonID '..description.data.dungeonID, WoWTools_LFDMixin:Get_Instance_Num(description.data.dungeonName), nil)
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
                tooltip:AddDoubleLine('dungeonID '..description.data.dungeonID, WoWTools_LFDMixin:Get_Instance_Num(description.data.dungeonName),nil)
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
    local sub, isLeader, isTank, isHealer, isDPS, tank, healer, dps
    local canBeTank, canBeHealer, canBeDamager = UnitGetAvailableRoles("player")
    local cursorRole = select(5, GetSpecializationInfo(GetSpecialization() or 0))

    sub=root:CreateButton('PvE', function()
        PVEFrame_ToggleFrame("GroupFinderFrame", LFDParentFrame);
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(MicroButtonTooltipText('队伍查找器', "TOGGLEGROUPFINDER"))
    end)

    root:CreateDivider()    
    for _, role in pairs({'TANK', 'HEALER', 'DAMAGER'}) do
        sub= root:CreateCheckbox(
            e.Icon[role]
            ..e.cn(_G[role])
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
            e.Icon[role]
            ..e.cn(_G[role])
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
    local roleText
    if (isTank or isHealer or isDPS) then
        roleText= (isTank and e.Icon.TANK or '')
                ..(isHealer and e.Icon.HEALER or '')
                ..(isDPS and e.Icon.DAMAGER or '')
                ..(isLeader and '|A:UI-HUD-UnitFrame-Player-Group-GuideIcon:0:0|a' or '')
    else
        roleText= format('|A:QuestLegendaryTurnin:0|a'..'|cnRED_FONT_COLOR:%s|r', e.onlyChinese and '无职责' or NO_ROLE)
    end

    sub=root:CreateButton(
        (e.onlyChinese and '设置' or SETTINGS)..roleText,
    function()
        PVEFrame_ToggleFrame("GroupFinderFrame")
        return MenuResponse.Open
    end, roleText)
    sub:SetTooltip(function(tooltip, data)
        tooltip:AddLine('PVE '..( e.onlyChinese and '职责' or ROLE))
        tooltip:AddLine(data.data)
        tooltip:AddLine(' ')
        tooltip:AddLine(MicroButtonTooltipText('队伍查找器', "TOGGLEGROUPFINDER"))
    end)






--设置, 小眼睛, 信息
    sub2=sub:CreateCheckbox(format('|A:%s:0:0|a', e.Icon.toLeft)..(e.onlyChinese and '离开副本' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC,LEAVE, INSTANCE)), function()
        return Save().leaveInstance
    end, function()
        Save().leaveInstance= not Save().leaveInstance and true or nil
        WoWTools_LFDMixin:Set_Queue_Status()--小眼睛, 信息
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
        return not Save().hideQueueStatus
    end, function()
        Save().hideQueueStatus = not Save().hideQueueStatus and true or nil
        WoWTools_LFDMixin:Set_Queue_Status()
    end)

    sub2:CreateButton(
        (Save().tipsFramePoint and '' or '|cff9e9e9e')..(e.onlyChinese and '重置位置' or RESET_POSITION),
    function()
        Save().tipsFramePoint=nil
        if WoWTools_LFDMixin.TipsButton then
            WoWTools_LFDMixin.TipsButton:ClearAllPoints()
            WoWTools_LFDMixin.TipsButton:set_Point()
            print(WoWTools_Mixin.addName, WoWTools_LFDMixin.addName, e.onlyChinese and '重置位置' or RESET_POSITION)
        end
        return MenuResponse.Open
    end)





--设置, 预创建队伍增强
    sub2=sub:CreateCheckbox('|A:UI-HUD-MicroMenu-Groupfinder-Mouseover:0:0|a'..(e.onlyChinese and '预创建队伍增强' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LFGLIST_NAME, 'Plus')), function()
        return Save().LFGPlus
    end, function()
        Save().LFGPlus = not Save().LFGPlus and true or nil
        if WoWTools_LFDMixin.LFGPlusButton then
            WoWTools_LFDMixin.LFGPlusButton:set_texture()
        end
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
    end)





--职责确认
    sub2=sub:CreateCheckbox('|A:quest-legendary-turnin:0:0|a'..(e.onlyChinese and '职责确认' or ROLE_POLL), function()
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
        (e.onlyChinese and '战场' or BATTLEFIELDS)
        ..(tank and e.Icon.TANK or '')
        ..(healer and e.Icon.HEALER or '')
        ..(dps and e.Icon.DAMAGER or '')
    )

--释放, 复活    
    sub2=sub:CreateCheckbox('|A:poi-soulspiritghost:0:0|a'..(e.onlyChinese and '释放, 复活' or (BATTLE_PET_RELEASE..', '..RESURRECT)), function()
        return Save().ReMe
    end, function()
        Save().ReMe= not Save().ReMe and true or nil
        WoWTools_LFDMixin:RepopMe_SetEvent()
    end)

--所有地区
    sub3=sub2:CreateCheckbox(
        e.onlyChinese and '所有地区' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, VIDEO_OPTIONS_EVERYTHING, ZONE),
    function()
        return WoWTools_LFDMixin.ReMe_AllZone
    end, function()
        WoWTools_LFDMixin.ReMe_AllZone= not WoWTools_LFDMixin.ReMe_AllZone and true or false
    end)
    sub3:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '不保存' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NO, SAVE))
    end)





--战利品掷骰
    sub=root:CreateButton(
        (Save().autoROLL and '|TInterface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47:0|t' or '|A:Levelup-Icon-Bag:0:0|a')
        ..(e.onlyChinese and '战利品掷骰' or LOOT_ROLL),
    function()
        e.call(ToggleLootHistoryFrame)
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('/loot ')
    end)

    sub:CreateCheckbox((e.onlyChinese and '自动掷骰' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, ROLL))..'|TInterface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47:0|t', function()
        return Save().autoROLL
    end, function()
        Save().autoROLL= not Save().autoROLL and true or nil
    end)

    sub:CreateCheckbox('|A:communities-icon-notification:0:0|a'..(e.onlyChinese and '战利品 Plus' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LOOT, 'Plus')), function()
        return not Save().disabledLootPlus
    end, function()
        Save().disabledLootPlus= not Save().disabledLootPlus and true or nil
    end)











--副本，逃亡者
    local deserterExpiration = GetLFGDeserterExpiration()
    local shouldtext
    local cooldowntext
    if ( deserterExpiration ) then
		shouldtext = format("|cnRED_FONT_COLOR:%s|r "..WoWTools_UnitMixin:GetPlayerInfo(nil, e.Player.guid, nil), e.onlyChinese and '逃亡者' or DESERTER)
        local timeRemaining = deserterExpiration - GetTime()
        if timeRemaining>0 then
            shouldtext= shouldtext..' '..SecondsToTime(ceil(timeRemaining))
        end
	else
		local myExpireTime = GetLFGRandomCooldownExpiration()
        if myExpireTime then
            cooldowntext= format("|cnRED_FONT_COLOR:%s|r "..WoWTools_UnitMixin:GetPlayerInfo(nil, e.Player.guid, nil), e.onlyChinese and '冷却中' or ON_COOLDOWN)
            local timeRemaining = myExpireTime - GetTime()
            if timeRemaining>0 then
                cooldowntext= cooldowntext..' '..SecondsToTime(ceil(timeRemaining))
            end
        end
	end
    for i = 1, GetNumSubgroupMembers() do
        local unit= 'party'..i
		if ( UnitHasLFGDeserter(unit) ) then
			shouldtext= (shouldtext and shouldtext..'|n' or '')..WoWTools_UnitMixin:GetPlayerInfo(unit, nil, nil)..' '..(e.onlyChinese and '逃亡者' or DESERTER)
		elseif ( UnitHasLFGRandomCooldown(unit) ) then
			cooldowntext= (cooldowntext and cooldowntext..'|n' or '')..WoWTools_UnitMixin:GetPlayerInfo(unit, nil, nil)..' '..(e.onlyChinese and '冷却中' or ON_COOLDOWN)
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

--[[离开列队
    WoWTools_MenuMixin:SetGridMode(root, num)

    sub=root:CreateButton(
        (e.onlyChinese and '离开列队' or LEAVE_QUEUE),
    function()
        for i=1, NUM_LE_LFG_CATEGORYS do--列表信息
            LeaveLFG(i)
        end
        return MenuResponse.Open
    end, tab)
    sub:SetTooltip(function(tooltip, data)
        tooltip:AddLine(e.onlyChinese and '在队列中' or BATTLEFIELD_QUEUE_STATUS)
        for _, text in pairs(data.data or {}) do
            tooltip:AddLine(text)
        end
    end)
    sub:AddInitializer(function(btn)
        btn:SetScript("OnUpdate", function(self, elapsed)
            self.elapsed= (self.elapsed or 1.2) +elapsed
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
                self.fontString:SetText((queueNum==0 and '|cff9e9e9e' or '')..(e.onlyChinese and '离开列队' or LEAVE_QUEUE)..' '..queueNum)
            end
        end)
        btn:SetScript('OnHide', function(self)
            self:SetScript('OnUpdate', nil)
            self.elapsed= nil
        end)
    end)
]]

--离开所有队列
    sub=root:CreateButton(
        e.onlyChinese and '离开所有队列' or LEAVE_ALL_QUEUES,
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
                self.fontString:SetText((queueNum==0 and '|cff9e9e9e' or '')..(e.onlyChinese and '离开所有队列' or LEAVE_ALL_QUEUES)..' '..queueNum)
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
        ..(e.onlyChinese and '离开地下堡' or INSTANCE_WALK_IN_LEAVE),
    function()
        if WoWTools_MapMixin:IsInDelve() then
            StaticPopup_Show('WoWTools_OK',
                (e.onlyChinese and '离开地下堡' or INSTANCE_WALK_IN_LEAVE)
                ..'|n|n|A:BonusLoot-Chest:32:32|a|cnGREEN_FONT_COLOR:'
                ..(e.onlyChinese and '注意：奖励' or (LABEL_NOTE..': '..REWARD)),
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
        ..(e.onlyChinese and '离开副本' or INSTANCE_LEAVE),
    function()
        if select(10, GetInstanceInfo()) then
            StaticPopup_Show('WoWTools_OK',
                (e.onlyChinese and '离开副本' or INSTANCE_LEAVE)
                ..'|n|n|A:BonusLoot-Chest:32:32|a|cnGREEN_FONT_COLOR:'
                ..(e.onlyChinese and '注意：奖励' or (LABEL_NOTE..': '..REWARD)),
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
        ((UnitControllingVehicle("player") and CanExitVehicle()) and '' or '|cff9e9e9e')
        ..(e.onlyChinese and '离开载具' or BINDING_NAME_VEHICLEEXIT),
    function()
        e.call(VehicleExit)
        return MenuResponse.Open
    end)
end














function WoWTools_LFDMixin:Init_Menu(...)
    Init_Menu(...)
end