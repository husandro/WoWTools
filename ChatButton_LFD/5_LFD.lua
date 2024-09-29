local id, e = ...
local addName
WoWTools_LFDMixin={
    Save={
        leaveInstance=e.Player.husandro,--自动离开,指示图标
        autoROLL= e.Player.husandro,--自动,战利品掷骰
        --disabledLootPlus=true,--禁用，战利品Plus
        ReMe=true,--仅限战场，释放，复活
        autoSetPvPRole=e.Player.husandro,--自动职责确认， 排副本
        LFGPlus= e.Player.husandro,--预创建队伍增强
        tipsScale=1,--提示内容,缩放
        sec=3,--时间 timer
        wow={
            --['island']=0,
            --[副本名称]=0,
        }
    }
}

local LFDButton, tipsButton
local panel= CreateFrame("Frame")





















function e.Get_Instance_Num(name)
    name= name or GetInstanceInfo()
    local num = Save().wow[name] or 0
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
        ..'  '..(queuedTime and WoWTools_TimeMixin:Info(queuedTime, true) or '')
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
        if not Save().hideQueueStatus then
            LFDButton.texture:SetAtlas('groupfinder-eye-frame')
        else
            LFDButton.texture:SetAtlas('UI-HUD-MicroMenu-Groupfinder-Mouseover')
        end
    end
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
    sub2:CreateButton((Save().tipsFramePoint and '' or '|cff9e9e9e')..(e.onlyChinese and '重置位置' or RESET_POSITION), function()
        Save().tipsFramePoint=nil
        if tipsButton then
            tipsButton:ClearAllPoints()
            tipsButton:set_Point()
            print(e.addName, WoWTools_LFDMixin.addName, e.onlyChinese and '重置位置' or RESET_POSITION)
        end
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
    sub:CreateCheckbox('|A:quest-legendary-turnin:0:0|a'..(e.onlyChinese and '职责确认' or ROLE_POLL), function()
        return Save().autoSetPvPRole
    end, function()
        Save().autoSetPvPRole= not Save().autoSetPvPRole and true or nil
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
        return Save().ReMe
    end, function()
        Save().ReMe= not Save().ReMe and true or nil
    end)







--战利品掷骰
    sub=root:CreateButton(
        (Save().autoROLL and '|TInterface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47:0|t' or '|A:Levelup-Icon-Bag:0:0|a')
        ..(e.onlyChinese and '战利品掷骰' or LOOT_ROLL),
    ToggleLootHistoryFrame)
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

--离开列队

    num= 0
    for i=1, NUM_LE_LFG_CATEGORYS do--列表信息
        num= (get_Queued_List(i) or 0)+ num
    end
    WoWTools_MenuMixin:SetGridMode(root, num)

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
    sub:CreateButton(
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
        VehicleExit()
        return MenuResponse.Open
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
        WoWTools_WeekMixin:Activities({showTooltip=true})--周奖励，提示

        if self.name and (self.dungeonID or self.RaidID) then
            e.tips:AddLine(' ')
            e.tips:AddLine(self.name..e.Icon.left)
        end
        if tipsButton and tipsButton:IsShown() then
            tipsButton:SetButtonState('PUSHED')
        end
        e.tips:Show()
        self:state_enter()--Init_Menu)
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

    WoWTools_LFDMixin:Init_Queue_Status()--建立，小眼睛, 更新信息

    

   
    WoWTools_LFDMixin:Loot_Plus()--历史, 拾取框
    WoWTools_LFDMixin:Roll_Plus()--自动 ROLL
    WoWTools_LFDMixin:Init_RolePollPopup()    
    WoWTools_LFDMixin:Init_Exit_Instance()--离开副本
    WoWTools_LFDMixin:Init_LFG_Plus()--
    WoWTools_LFDMixin:Role_CheckInfo()--职责确认，信息
    
    C_Timer.After(2, setHoliday)--节日, 提示, button.texture





    PVPTimerFrame:HookScript('OnShow', function(self2)
        e.PlaySound()--播放, 声音
        e.Ccool(self2, nil, BATTLEFIELD_TIMER_THRESHOLDS[3] or 60, nil, true)--冷却条
    end)
end














































--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1, arg2, arg3, arg4)
    if event == "ADDON_LOADED" then
        if arg1==id then
            WoWTools_LFDMixin.Save= WoWToolsSave['ChatButton_LFD'] or WoWTools_LFDMixin.Save
            WoWTools_LFDMixin.Save.sec= WoWTools_LFDMixin.Save.sec or 3

            WoWTools_LFDMixin.addName= '|A:groupfinder-eye-frame:0:0|a'..(e.onlyChinese and '队伍查找器' or DUNGEONS_BUTTON)

            LFDButton= WoWTools_ChatButtonMixin:CreateButton('LFD', WoWTools_LFDMixin.addName)

            if LFDButton then--禁用Chat Button
                
                Init()
                
                
                
                self:RegisterEvent('LFG_UPDATE_RANDOM_INFO')

                self:RegisterEvent('CORPSE_IN_RANGE')--仅限战场，释放, 复活
                self:RegisterEvent('PLAYER_DEAD')
                self:RegisterEvent('AREA_SPIRIT_HEALER_IN_RANGE')
                self:RegisterEvent('UPDATE_BATTLEFIELD_STATUS')
                self:RegisterEvent('GROUP_LEFT')
                self:RegisterEvent('PLAYER_ROLES_ASSIGNED')--职责确认
            end

            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButton_LFD']= WoWTools_LFDMixin.Save
        end

    

    elseif event=='LFG_UPDATE_RANDOM_INFO' then
        setHoliday()--节日, 提示, LFDButton.texture

    elseif event=='CORPSE_IN_RANGE' or event=='PLAYER_DEAD' or event=='AREA_SPIRIT_HEALER_IN_RANGE' then--仅限战场，释放, 复活
        if Save().ReMe and WoWTools_MapMixin:IsInPvPArea() then
            if event=='PLAYER_DEAD' then
                print(e.addName, WoWTools_LFDMixin.addName,'|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '释放, 复活' or (BATTLE_PET_RELEASE..', '..RESURRECT)))
            end
            RepopMe()--死后将你的幽灵释放到墓地。
            RetrieveCorpse()--当玩家站在它的尸体附近时复活。
            AcceptAreaSpiritHeal()--在范围内时在战场上注册灵魂治疗师的复活计时器
        end



    end
end)

