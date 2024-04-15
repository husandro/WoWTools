local id, e = ...
local addName= HUD_EDIT_MODE_MINIMAP_LABEL
local addName2
local Initializer
local Save={
        scale=e.Player.husandro and 1 or 0.85,
        ZoomOut=true,--更新地区时,缩小化地图
        ZoomOutInfo=true,--小地图, 缩放, 信息

        vigentteButton=e.Player.husandro,
        vigentteButtonShowText=true,
        vigentteSound= e.Player.husandro,--播放声音

        vigentteButtonTextScale=1,
        --hideVigentteCurrentOnMinimap=true,--当前，小地图，标记
        --hideVigentteCurrentOnWorldMap=true,--当前，世界地图，标记
        questIDs={},--世界任务, 监视, ID {[任务ID]=true}
        areaPoiIDs={[7492]= 2025},--{[areaPoiID]= 地图ID}
        uiMapIDs= {},--地图ID 监视, areaPoiIDs，
        currentMapAreaPoiIDs=true,--当前地图，监视, areaPoiIDs，
        textToDown= e.Player.husandro,--文本，向下

        miniMapPoint={},--保存小图地, 按钮位置

       --disabledInstanceDifficulty=true,--副本，难图，指示
       --hideMPortalRoomLabels=true,--'10.2 副本，挑战专送门'


       --disabledClockPlus=true,--时钟，秒表
       --时钟
       useServerTimer=true,--小时图，使用服务器, 时间
       --TimeManagerClockButtonScale=1--缩放
       --TimeManagerClockButtonPoint={}--位置

       --秒表
       --showStopwatchFrame=true,--加载游戏时，显示秒表
       --StopwatchFrameScale=1,--缩放

       hideExpansionLandingPageMinimapButton= e.Player.husandro,--隐藏，图标

       moving_over_Icon_show_menu=e.Player.husandro,--移过图标时，显示菜单
       --hide_MajorFactionRenownFrame_Button=true,--隐藏，派系声望，列表，图标
       --MajorFactionRenownFrame_Button_Scale=1,--缩放
}



--[[local LocalMajorFaction={--派系声望
    [2593]=true,--'桶腿船团'
    [2503]=true,-- '马鲁克半人马'
    [2574]=true,--'梦境守望者'
    [2564]=true,-- '峈姆鼹鼠人'
    [2511]=true,--'伊斯卡拉海象人
    [2510]=true,--'瓦德拉肯联军
    [2507]=true,--'龙鳞探险队'
}
hooksecurefunc('ReputationFrame_InitReputationRow', function(factionRow)
    if factionRow.factionID and C_Reputation.IsMajorFaction(factionRow.factionID) and not MajorFaction[factionRow.factionID] then
        Save.MajorFaction[factionRow.factionID]=true
    end
end)]]




for questID, _ in pairs(Save.questIDs or {}) do
    e.LoadDate({id= questID, type=='quest'})
end

local panel= CreateFrame("Frame")
local Button









--取得 areaPoiID 名称
local barColor = {
	--[Enum.StatusBarColorTintValue.Black] = BLACK_FONT_COLOR,
	[3] = WHITE_FONT_COLOR,
	[2] = RED_FONT_COLOR,
	[1] = YELLOW_FONT_COLOR,
	--[Enum.StatusBarColorTintValue.Orange] = ORANGE_FONT_COLOR,
	[5] = EPIC_PURPLE_COLOR,
	[4] = GREEN_FONT_COLOR,
	[6] = RARE_BLUE_COLOR,
}

local function get_AreaPOIInfo_Name(poiInfo)
    return (poiInfo.atlasName and '|A:'..poiInfo.atlasName..':0:0|a' or '')..(poiInfo.name or '')
end















--任务奖励 QuestUtils_AddQuestRewardsToTooltip(tooltip, questID, style)
local function Get_QuestReward_Texture(questID)
    local itemTexture, bestQuality

    local numQuestChoices = GetNumQuestLogChoices(questID)--可选任务，奖励
    if numQuestChoices>0 then
        bestQuality= -1
        for i = 1, numQuestChoices do
            local _, texture, _, quality= GetQuestLogChoiceInfo(i, questID)
            if quality > bestQuality then
                itemTexture= texture or itemTexture
            end
        end
        if itemTexture then return itemTexture end
    end

    local numQuestRewards = GetNumQuestLogRewards(questID)
    if numQuestRewards>0 then
        bestQuality = -1
        for i = 1, numQuestRewards do
            local _, texture, _, quality= GetQuestLogRewardInfo(i, questID)
            if quality > bestQuality then
                itemTexture= texture
            end
        end
        if itemTexture then return itemTexture end
    end


    if C_QuestInfoSystem.HasQuestRewardSpells(questID) then
        for _, spell in pairs(C_QuestInfoSystem.GetQuestRewardSpells(questID) or {}) do
            local info = C_QuestInfoSystem.GetQuestRewardSpellInfo(questID, spell)
            if info and info.texture and info.texture>0 then
                itemTexture= info.texture
                break
            elseif not C_Item.IsItemDataCachedByID(spell) then
                C_Item.RequestLoadItemDataByID(spell)
            end
        end
        if itemTexture then return itemTexture end
    end

    local numQuestCurrencies= GetNumQuestLogRewardCurrencies(questID)--货币
    if numQuestCurrencies>0 then
        bestQuality= -1
        for i=1, numQuestCurrencies do
            local _, texture, _, _, quality = GetQuestLogRewardCurrencyInfo(i, questID)
            if quality > bestQuality then
                itemTexture= texture
            end
        end
        return itemTexture

    elseif GetQuestLogRewardArtifactXP(questID) > 0 then--神器XP
        local artifactCategory= select(2, GetRewardArtifactXP()) or select(2, GetQuestLogRewardArtifactXP())
        if artifactCategory then
            local icon = select(2, C_ArtifactUI.GetArtifactXPRewardTargetInfo(artifactCategory))
            if icon and icon >0 then
                return icon
            end
        end

    elseif GetQuestLogRewardHonor(questID)>0 then--荣誉
        return 'Interface\\ICONS\\Achievement_LegionPVPTier4'

    elseif GetQuestLogRewardXP(questID) > 0 then--XP
        return 'Interface\\Icons\\XP_Icon'

    elseif GetQuestLogRewardMoney(questID)>0 then--钱
        return 'Interface\\Icons\\inv_misc_coin_01'--'interface\\moneyframe\\ui-goldicon'
    end

end

























--#######################
--小地图, 标记, 监视，文本
--#######################
--世界任务 文本
local function get_Quest_Text(questID)
    local text, itemTexture, atlas
    if C_TaskQuest.IsActive(questID) then
        if not HaveQuestRewardData(questID) then
            C_TaskQuest.RequestPreloadRewardData(questID)
        else
            local questName= C_TaskQuest.GetQuestInfoByQuestID(questID)
            if questName then
                itemTexture= Get_QuestReward_Texture(questID)
                if not itemTexture then
                    atlas= 'worldquest-tracker-questmarker'
                end
                local secondsLeft = C_TaskQuest.GetQuestTimeLeftSeconds(questID)
                local secText= e.SecondsToClock(secondsLeft, true)
                text= text and text..'|n' or ''
                text= e.cn(questName)
                    ..(secText and ' |cffffffff'..secText..'|r' or '')
            end
        end
    end
    return text, itemTexture, atlas
end


























local function Get_widgetSetID_Text(widgetSetID, all)
    local text

    for _, widget in ipairs(C_UIWidgetManager.GetAllWidgetsBySetID(widgetSetID) or {}) do
        local info
        if widget.widgetID then
            if widget.widgetType ==Enum.UIWidgetVisualizationType.IconAndText then info= C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.CaptureBar then info= C_UIWidgetManager.GetCaptureBarWidgetVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.StatusBar then info= C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.DoubleStatusBar then info= C_UIWidgetManager.GetDoubleStatusBarWidgetVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.IconTextAndBackground then info= C_UIWidgetManager.GetIconTextAndBackgroundWidgetVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.DoubleIconAndText then info= C_UIWidgetManager.GetDoubleIconAndTextWidgetVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.StackedResourceTracker then info= C_UIWidgetManager.GetStackedResourceTrackerWidgetVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.IconTextAndCurrencies then info= C_UIWidgetManager.GetIconTextAndCurrenciesWidgetVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.TextWithState then info= C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.HorizontalCurrencies then info= C_UIWidgetManager.GetHorizontalCurrenciesWidgetVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.BulletTextList then info= C_UIWidgetManager.GetBulletTextListWidgetVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.ScenarioHeaderCurrenciesAndBackground then info= C_UIWidgetManager.GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.TextureAndText then info= C_UIWidgetManager.GetTextureAndTextVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.SpellDisplay then info= C_UIWidgetManager.GetSpellDisplayVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.DoubleStateIconRow then info= C_UIWidgetManager.GetDoubleStateIconRowVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.TextureAndTextRow then info= C_UIWidgetManager.GetTextureAndTextRowVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.ZoneControl then info= C_UIWidgetManager.GetZoneControlVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.CaptureZone then info= C_UIWidgetManager.GetCaptureZoneVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.TextureWithAnimation then info= C_UIWidgetManager.GetTextureWithAnimationVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.DiscreteProgressSteps then info= C_UIWidgetManager.GetDiscreteProgressStepsVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.ScenarioHeaderTimer then info= C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.TextColumnRow then info= C_UIWidgetManager.GetTextColumnRowVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.Spacer then info= C_UIWidgetManager.GetSpacerVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.UnitPowerBar then info= C_UIWidgetManager.GetUnitPowerBarWidgetVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.FillUpFrames then info= C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo(widget.widgetID)
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.TextWithSubtext then info= C_UIWidgetManager.GetTextWithSubtextWidgetVisualizationInfo(widget.widgetID)
            --elseif widget.widgetType ==Enum.UIWidgetVisualizationType.WorldLootObject		Added in 10.1.0
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.ItemDisplay then info= C_UIWidgetManager.GetItemDisplayVisualizationInfo(widget.widgetID)
            end
        end

        if info and info.shownState == Enum.WidgetShownState.Shown and info.text and info.text~='' then
           if info.hasTimer or all then
                local barText
                if info.barMax and info.barMax>0 and info.barValue then
                    if info.barValueTextType == Enum.StatusBarValueTextType.Value then--Blizzard_UIWidgetTemplateBase.lua
                        barText= info.barValue--2

                    elseif info.barValueTextType == Enum.StatusBarValueTextType.ValueOverMax then
                        barText= FormatFraction(info.barValue, info.barMax)--5

                    elseif info.barValueTextType == Enum.StatusBarValueTextType.ValueOverMaxNormalized then
                        barText= FormatFraction(info.barValue - info.barMin, info.barMax - info.barMin)

                    elseif info.barValueTextType == Enum.StatusBarValueTextType.Percentage then--1
                        local barPercent = PercentageBetween(info.barValue, info.barMin, info.barMax)
                        barText= FormatPercentage(barPercent, true)

                    elseif info.barValueTextType == Enum.StatusBarValueTextType.Time then
                        barText = SecondsToTime(info.barValue, false, true, nil, true)
                    end
                end
                barText= barText and '|cffffffff'..barText..'|r ' or ''
                info.text= e.cn(info.text)
                local text3= info.text:gsub('^|n', '')
                text3= text3:gsub('|n', '|n       ')
                text3= text3:gsub(':%d+|t', ':0|t')
                local col = barColor[info.enabledState]
                if col then
                    text3= col:WrapTextInColorCode(text3)
                end

                text=(text and text..'|n' or '').. '   '..barText..text3
               --if widgetSetID==1001 then
            end
        end
    end


    return text
end














--##############
--areaPoiID 文本
--##############
local function Get_areaPoiID_Text(uiMapID, areaPoiID, all)
    local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID) or {}
    if not poiInfo.name  then
        return
    end
    local text= poiInfo.widgetSetID and Get_widgetSetID_Text(poiInfo.widgetSetID, all)
    if text then

        local time
        if C_AreaPoiInfo.IsAreaPOITimed(areaPoiID) then
            time=  C_AreaPoiInfo.GetAreaPOISecondsLeft(areaPoiID)
            time= (time and time>0) and time or nil
        end

        if text and (time or all) then
            local name= e.cn(poiInfo.name)
            local atlas=  poiInfo.atlasName
            if poiInfo.factionID and C_Reputation.IsMajorFaction(poiInfo.factionID) then
                local info = C_MajorFactions.GetMajorFactionData(poiInfo.factionID)
                if info and info.textureKit then
                    if not atlas then
                        atlas= 'MajorFactions_Icons_'..info.textureKit..'512'
                    else
                        name= name..'|A:MajorFactions_Icons_'..info.textureKit..'512:0:0|a'
                    end
                end
            end
            if time then
                if poiInfo.name~='' then
                    if time<86400 then
                        text= text..' |cffffffff'..e.SecondsToClock(time)..'|r'
                    else
                        text= text..' |cffffffff'..SecondsToTime(time)..'|r'
                    end
                else
                    if time<86400 then
                        text= text..' '..e.SecondsToClock(time)
                    else
                        text= text..' '..SecondsToTime(time)
                    end
                end
            end
            return name, atlas, text
        end
    end
end
















--#########
--Vignettes
--#########
local function get_vignette_Text()
    local onMinimap={}
    local onWorldMap={}
    if not (Save.hideVigentteCurrentOnMinimap and Save.hideVigentteCurrentOnWorldMap) then
        local vignetteGUIDs= C_VignetteInfo.GetVignettes() or {}
        local bestUniqueVignetteIndex = C_VignetteInfo.FindBestUniqueVignette(vignetteGUIDs)
        local tab={}



        for index, guid in pairs(vignetteGUIDs) do
            local info= C_VignetteInfo.GetVignetteInfo(guid) or {}
            if info.vignetteID and not tab[info.vignetteID]
                and (info.name or info.atlasName)
                and not info.isDead
                and (
                    (info.onMinimap and not Save.hideVigentteCurrentOnMinimap)--当前，小地图，标记
                    or (info.onWorldMap and not Save.hideVigentteCurrentOnWorldMap)--当前，世界地图，标记
                )
            then

                if info.rewardQuestID==0 then
                    info.rewardQuestID=nil
                end
                local text
                local name= e.cn(info.name)
                if info.widgetSetID then
                    text= Get_widgetSetID_Text(info.widgetSetID, true)
                end

                if info.vignetteID == 5715 or info.vignetteID==5466 then--翻动的泥土堆
                    name= name..'|T1059121:0|t'
                elseif info.vignetteID== 5485 then
                    name= name..'|A:MajorFactions_Icons_Tuskarr512:0:0|a'
                elseif info.vignetteID==5468 then
                    name= name..'|A:MajorFactions_Icons_Expedition512:0:0|a'
                end
                if info.rewardQuestID then--任务，奖励

                    local itemTexture= Get_QuestReward_Texture(info.rewardQuestID)

                    if itemTexture then
                        name= name..'|T'..itemTexture..':0|t'
                    end
                end
                if index==bestUniqueVignetteIndex then--唯一
                    name= '|cnGREEN_FONT_COLOR:'..name..'|r'..e.Icon.star2
                end

                --local point= C_VignetteInfo.GetVignettePosition(guid, uiMapID)
                table.insert(info.onMinimap and onMinimap or onWorldMap, {
                    name=name,
                    text=text,
                    atlas=info.atlasName,
                    vignetteGUID=guid,
                    onMinimap=info.onMinimap,
                    rewardQuestID= info.rewardQuestID
                })
                tab[info.vignetteID]=true
            end
        end
    end
    return onMinimap, onWorldMap
end














--##########
--小按钮，提示
--VignetteDataProvider.lua VignettePinMixin:OnMouseEnte
local function set_OnEnter_btn_tips(self)
    local widgetSetID, vignetteID
    if self.questID then--任务
        GameTooltip_AddQuest(self, self.questID)

    elseif self.vignetteGUID then--vigentte
        local vignetteInfo = C_VignetteInfo.GetVignetteInfo(self.vignetteGUID)
        if vignetteInfo then
            local verticalPadding = nil
            local waitingForData, titleAdded = false, false

            if vignetteInfo.type == Enum.VignetteType.Normal or vignetteInfo.type == Enum.VignetteType.Treasure then
                GameTooltip_SetTitle(GameTooltip, e.cn(vignetteInfo.name))
                titleAdded = true

            elseif vignetteInfo.type == Enum.VignetteType.PvPBounty then
                local player = PlayerLocation:CreateFromGUID(vignetteInfo.objectGUID)
                local class = select(3, C_PlayerInfo.GetClass(player))
                local race = C_PlayerInfo.GetRace(player)
                local name = C_PlayerInfo.GetName(player)
                if race and class and name then
                    local classInfo = C_CreatureInfo.GetClassInfo(class) or {}
                    local factionInfo = C_CreatureInfo.GetFactionInfo(race) or {}
                    GameTooltip_SetTitle(GameTooltip, e.cn(name), GetClassColorObj(classInfo.classFile))
                    GameTooltip_AddColoredLine(GameTooltip, e.cn(factionInfo.name), GetFactionColor(factionInfo.groupTag))
                    if vignetteInfo.rewardQuestID then
                        GameTooltip_AddQuestRewardsToTooltip(GameTooltip, vignetteInfo.rewardQuestID, TOOLTIP_QUEST_REWARDS_STYLE_PVP_BOUNTY)
                    end
                    titleAdded=true
                end
                waitingForData = not titleAdded

            elseif vignetteInfo.type == Enum.VignetteType.Torghast then
                SharedTooltip_SetBackdropStyle(GameTooltip, GAME_TOOLTIP_BACKDROP_STYLE_RUNEFORGE_LEGENDARY)
                GameTooltip_SetTitle(GameTooltip, e.cn(vignetteInfo.name))
                titleAdded = true
            end

            if not waitingForData and vignetteInfo.widgetSetID then
                local overflow = GameTooltip_AddWidgetSet(GameTooltip, vignetteInfo.widgetSetID, titleAdded and vignetteInfo.addPaddingAboveWidgets and 10)
                if overflow then
                    verticalPadding = -overflow
                end
            elseif waitingForData then
                GameTooltip_SetTitle(GameTooltip, e.onlyChinese and '获取数据' or RETRIEVING_DATA)
            end
            if verticalPadding then
                GameTooltip:SetPadding(0, verticalPadding)
            end
            widgetSetID= vignetteInfo.widgetSetID
            vignetteID= vignetteInfo.vignetteID
        end

    elseif self.uiMapID and self.areaPoiID then--areaPoi AreaPOIPinMixin:TryShowTooltip()
        local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(self.uiMapID, self.areaPoiID) or {}
        local hasName = poiInfo.name ~= ""
        local hasDescription = poiInfo.description and poiInfo.description ~= ""
        local isTimed, hideTimer = C_AreaPoiInfo.IsAreaPOITimed(self.areaPoiID)
        local showTimer = isTimed and not hideTimer
        local hasWidgetSet = poiInfo.widgetSetID ~= nil

        local hasTooltip = hasDescription or showTimer or hasWidgetSet
	    local addedTooltipLine = false

        if hasTooltip then
            local verticalPadding = nil

            if hasName then
                GameTooltip_SetTitle(GameTooltip, e.cn(poiInfo.name), HIGHLIGHT_FONT_COLOR)
                addedTooltipLine = true
            end

            if hasDescription then
                GameTooltip_AddNormalLine(GameTooltip, e.cn(poiInfo.description))
                addedTooltipLine = true
            end

            if showTimer then
                local secondsLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(self.areaPoiID)
                if secondsLeft and secondsLeft > 0 then
                    local timeString = SecondsToTime(secondsLeft)
                    GameTooltip_AddNormalLine(GameTooltip, format(e.onlyChinese and '剩余时间：%s' or BONUS_OBJECTIVE_TIME_LEFT, timeString))
                    addedTooltipLine = true
                end
            end

            --[[if poiInfo.textureKit == "OribosGreatVault" then
                GameTooltip_AddBlankLineToTooltip(GameTooltip)
                GameTooltip_AddInstructionLine(GameTooltip, ORIBOS_GREAT_VAULT_POI_TOOLTIP_INSTRUCTIONS)
                addedTooltipLine = true
            end]]

            if hasWidgetSet then
                local overflow = GameTooltip_AddWidgetSet(GameTooltip, poiInfo.widgetSetID, addedTooltipLine and poiInfo.addPaddingAboveWidgets and 10)
                if overflow then
                    verticalPadding = -overflow
                end
            end

            if poiInfo.uiTextureKit then
                local backdropStyle = GAME_TOOLTIP_TEXTUREKIT_BACKDROP_STYLES[poiInfo.uiTextureKit]
                if (backdropStyle) then
                    SharedTooltip_SetBackdropStyle(GameTooltip, backdropStyle)
                end
            end
            -- need to set padding after Show or else there will be a flicker
            if verticalPadding then
                GameTooltip:SetPadding(0, verticalPadding)
            end
            widgetSetID= poiInfo.widgetSetID
        end
    end
    if self.areaPoiID and self.uiMapID then
        e.tips:AddDoubleLine('areaPoiID |cnGREEN_FONT_COLOR:'..self.areaPoiID, 'uiMapID |cnGREEN_FONT_COLOR:'..self.uiMapID..'|r')
    elseif vignetteID then
        e.tips:AddLine('vignetteID |cnGREEN_FONT_COLOR:'..vignetteID)
    elseif self.questID then
        e.tips:AddLine('questID |cnGREEN_FONT_COLOR:'..self.questID)
    end
    if widgetSetID then
        local info= self.uiMapID and C_Map.GetMapInfo(self.uiMapID) or {}
        e.tips:AddDoubleLine('widgetSetID |cnGREEN_FONT_COLOR:'..widgetSetID, e.cn(info.name))
    end
    if self.rewardQuestID then
        e.tips:AddLine('rewardQuestID |cnGREEN_FONT_COLOR:'..self.rewardQuestID)
    end

    e.tips:AddLine(' ')

    e.tips:AddDoubleLine(self.name and self.name~='' and '|A:communities-icon-chat:0:0|a'..(e.onlyChinese and '信息' or INFO) or ' ', e.Icon.left)
    e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU , e.Icon.right)
    e.tips:Show()
end














--小按钮，点击
local function set_OnClick_btn(self)
    local text
    if self.areaPoiID and self.uiMapID then
        local info = C_AreaPoiInfo.GetAreaPOIInfo(self.uiMapID, self.areaPoiID)
        if info and info.name then
            local link
            if info.position then
                if C_Map.CanSetUserWaypointOnMap(self.uiMapID) then
                    local mapPoint = UiMapPoint.CreateFromVector2D(self.uiMapID, info.position)--UiMapPoint.CreateFromCoordinates(mapID, x, y, z)
                    C_Map.SetUserWaypoint(mapPoint)
                    link= C_Map.GetUserWaypointHyperlink()
                    C_Map.ClearUserWaypoint()
                else
                    local x, y= info.position:GetXY()
                    if x and y then
                        link= format('%.2f', x*100)..' '..format('%.2f', y*100)
                    end
                end
            end
            text= info.name..(link or '')
            local secondsLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(self.areaPoiID)
            if secondsLeft then
                local time= e.SecondsToClock(secondsLeft)
                if time then
                    text= text..' '..time
                end
            else

            end
        end

    elseif self.questID then
        C_SuperTrack.SetSuperTrackedQuestID(self.questID)
        text= GetQuestLink(self.questID) or C_TaskQuest.GetQuestInfoByQuestID(self.questID)

    elseif self.vignetteGUID then
        local info= C_VignetteInfo.GetVignetteInfo(self.vignetteGUID)
        if info then
            text= info.name
        end
    end

    if not text then
        text= self.name:match('(.-)|A') or self.name:match('(.-)|T')  or self.name
    end
    e.Chat(text, nil, nil)
end



















--Button 文本
local function set_Button_Text()
    local allTable={}

    local onMinimap, onWorldMap= get_vignette_Text()--{vignetteID=info.vignetteID, text=text, atlas= info.atlasName}
    for _, vigenttes in pairs(onMinimap) do
        table.insert(allTable, vigenttes)
    end
    for _, vigenttes in pairs(onWorldMap) do
        table.insert(allTable, vigenttes)
    end


    for questID, _ in pairs(Save.questIDs) do--世界任务
        local name, itemTexture, atlas= get_Quest_Text(questID)
        if name then
            table.insert(allTable, {questID=questID, name=name, texture=itemTexture, atlas= atlas})
        end
    end


    for areaPoiID, uiMapID in pairs(Save.areaPoiIDs) do--自定义 areaPoiID
        local name, atlas, text= Get_areaPoiID_Text(uiMapID, areaPoiID, true)
        if name then
            table.insert(allTable, {name=name, areaPoiID=areaPoiID, uiMapID=uiMapID, text=text, atlas=atlas})
        end
    end



    for uiMapID, _ in pairs(Save.uiMapIDs) do--地图ID
        local tab={}
        for _, areaPoiID in pairs(C_AreaPoiInfo.GetAreaPOIForMap(uiMapID) or {}) do
            if not Save.areaPoiIDs[areaPoiID] and not tab[areaPoiID] then
                local name, atlas, text= Get_areaPoiID_Text(uiMapID, areaPoiID)
                if name then
                    table.insert(allTable, {name=name, areaPoiID=areaPoiID, uiMapID=uiMapID, text=text, atlas=atlas})
                    tab[areaPoiID]=true
                end
            end
        end
    end

    if Save.currentMapAreaPoiIDs then
        local uiMapID= C_Map.GetBestMapForUnit("player")
        if uiMapID and uiMapID>0 and not Save.uiMapIDs[uiMapID] then
            local nameTab={}
            for _, areaPoiID in pairs(C_AreaPoiInfo.GetAreaPOIForMap(uiMapID) or {}) do
                if not Save.areaPoiIDs[areaPoiID] then
                    local name, atlas, text= Get_areaPoiID_Text(uiMapID, areaPoiID)
                    if name and not nameTab[name] then
                        table.insert(allTable, {name=name, areaPoiID=areaPoiID, uiMapID=uiMapID, text=text, atlas=atlas})
                        nameTab[name]=true
                    end
                end
            end
        end
    end

    for index, info in pairs(allTable) do
        local btn = Button.btn[index]
        if not btn then
            btn= e.Cbtn(Button.Frame, {size={12,12}, icon='hdie'})
            btn.nameText= e.Cstr(btn,{color=true})
            btn.nameText:SetPoint('LEFT', btn, 'RIGHT')
            btn.onMinimap= btn:CreateTexture(nil, 'ARTWORK')
            btn.onMinimap:SetAtlas('UI-HUD-MicroMenu-Highlightalert')
            btn.onMinimap:SetPoint('CENTER')
            btn.onMinimap:SetSize(16,16)
            btn.onMinimap:SetVertexColor(0,1,0)
            btn.text= e.Cstr(btn,{color=true})

            btn.index= index

            function btn:set_rest(tables)
                self.questID= tables.questID--任务

                self.vignetteGUID= tables.vignetteGUID--vigentte
                self.rewardQuestID= tables.rewardQuestID

                self.areaPoiID= tables.areaPoiID--areaPoi
                self.uiMapID= tables.uiMapID

                self.name= tables.name
                self.nameText:SetText(tables.name=='' and ' ' or tables.name or '')
                self.text:SetText(tables.text or '')
                if tables.atlas then
                    self:SetNormalAtlas(tables.atlas)
                else
                    self:SetNormalTexture(tables.texture or 0)
                end
                self:SetShown((tables.text or tables.texture or tables.atlas) and true or false)
                self.onMinimap:SetShown(tables.vignetteGUID and tables.onMinimap)--提示， 在小地图
            end
            function btn:set_btn_point()
                if Save.textToDown then
                    if self.index==1 then
                        self:SetPoint('TOP', Button, 'BOTTOM')
                    else
                        self:SetPoint('TOPRIGHT', Button.btn[index-1].text, 'BOTTOMLEFT')
                    end
                    self.text:SetPoint('TOPLEFT', self.nameText, 'BOTTOMLEFT')
                else
                    if index==1 then
                        self:SetPoint('BOTTOM', Button, 'TOP')
                    else
                        self:SetPoint('BOTTOMRIGHT', Button.btn[index-1].text, 'TOPLEFT')
                    end
                    self.text:SetPoint('BOTTOMLEFT', self.nameText, 'TOPLEFT')
                end
            end

            btn:SetScript('OnClick', function(self, d)
                if d=='LeftButton' then
                    if self.name and self.name~='' then
                        set_OnClick_btn(self)
                    end
                else
                    Button:show_menu(self)
                end
            end)
            btn:SetScript("OnLeave", function(self)
                e.tips:Hide()
                Button:SetButtonState('NORMAL')
                self.nameText:SetAlpha(1)
                self.text:SetAlpha(1)
            end)
            btn:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self.nameText or self.text or self, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                set_OnEnter_btn_tips(self)
                e.tips:Show()
                Button:SetButtonState('PUSHED')
                self.nameText:SetAlpha(0.5)
                self.text:SetAlpha(0.5)
            end)


            btn:set_btn_point()

            Button.btn[index]=btn
        end

        btn:set_rest(info)
    end

    for i= #allTable+1, #Button.btn do
        Button.btn[i]:set_rest({})
    end
end

























local function Init_Button_Menu(_, level, menuList)--菜单
    local info
    if menuList=='CurrentVignette' then--当前 Vingnette
        info={
            text=e.onlyChinese and '小地图' or HUD_EDIT_MODE_MINIMAP_LABEL,
            checked= not Save.hideVigentteCurrentOnMinimap,
            func= function()
                Save.hideVigentteCurrentOnMinimap= not Save.hideVigentteCurrentOnMinimap and true or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        info={
            text=e.onlyChinese and '世界地图' or WORLDMAP_BUTTON,
            checked= not Save.hideVigentteCurrentOnWorldMap,
            func= function()
                Save.hideVigentteCurrentOnWorldMap= not Save.hideVigentteCurrentOnWorldMap and true or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '播放声音' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, EVENTTRACE_BUTTON_PLAY, SOUND),
            icon= 'chatframe-button-icon-voicechat',
            checked= Save.vigentteSound,
            disabled= Save.hideVigentteCurrentOnWorldMap,
            func= function()
                Save.vigentteSound= not Save.vigentteSound and true or nil
                Button:set_VIGNETTES_UPDATED(true)
                Button:set_Event()
                if Save.vigentteSound then
                    Button:speak_Text(e.onlyChinese and '播放声音' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, EVENTTRACE_BUTTON_PLAY, SOUND))
                end
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)


    elseif menuList=='WorldQuest' then--世界任务
        for questID, _ in pairs(Save.questIDs) do
            e.LoadDate({id= questID, type=='quest'})
            info={
                text= GetQuestLink(questID) or questID,
                icon= select(2, GetQuestLogRewardInfo(1, questID))
                     or select(2, GetQuestLogRewardCurrencyInfo(1, questID))
                     or e.Icon.quest,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle= (e.onlyChinese and '移除' or REMOVE)..' '..questID,
                arg1= questID,
                func= function(_, arg1)
                    Save.questIDs[arg1]=nil
                    print(id, Initializer:GetName(), e.cn(addName2), GetQuestLink(questID) or questID,
                    '|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..e.Icon.X2
                )
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '全部清除' or CLEAR_ALL,
            notCheckable=true,
            func= function()
                Save.questIDs={}
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif menuList=='AreaPoiID' then--AreaPoiID
        for areaPoiID, uiMapID in pairs(Save.areaPoiIDs) do
            local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID) or {}
            local name
            name= get_AreaPOIInfo_Name(poiInfo)
            name= name=='' and areaPoiID or name
            info={
                text= name,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle= (e.onlyChinese and '移除' or REMOVE)..' '..areaPoiID,
                tooltipText= (C_Map.GetMapInfo(uiMapID) or {}).name,
                arg1= areaPoiID,
                arg2= uiMapID,
                func= function(_, arg1,arg2)
                    Save.areaPoiIDs[arg1]=nil
                    print(id,Initializer:GetName(), e.cn(addName2),
                        get_AreaPOIInfo_Name(C_AreaPoiInfo.GetAreaPOIInfo(arg2, arg1) or {}),
                        arg1 and 'areaPoiID '..arg1 or '',
                        ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..e.Icon.X2)
                )
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '全部清除' or CLEAR_ALL,
            notCheckable=true,
            func= function()
                Save.areaPoiIDs={}
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif menuList=='uiMapIDs' then--地图
        for uiMapID, _ in pairs(Save.uiMapIDs) do
            local name=  (C_Map.GetMapInfo(uiMapID) or {}).name
            name= name or uiMapID
            info={
                text= name,
                icon= e.Icon.map,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle= (e.onlyChinese and '移除' or REMOVE)..' '..uiMapID,
                arg1= uiMapID,
                func= function(_, arg1)
                    Save.uiMapIDs[arg1]=nil
                    print(id,Initializer:GetName(), e.cn(addName2),
                    (C_Map.GetMapInfo(uiMapID) or {}).name,
                    arg1 and 'uiMapID '..arg1 or '',
                    ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..e.Icon.X2)
                )
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '当前地图' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REFORGE_CURRENT, WORLD_MAP),
            checked= Save.currentMapAreaPoiIDs,
            tooltipOnButton= true,
            tooltipTitle= C_Map.GetBestMapForUnit("player"),
            func= function()
                Save.currentMapAreaPoiIDs= not Save.currentMapAreaPoiIDs and true or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        info={
            text= e.onlyChinese and '全部清除' or CLEAR_ALL,
            notCheckable=true,
            func= function()
                Save.uiMapIDs={}
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif menuList=='AreaPoiID' then--AreaPoiID
        for areaPoiID, uiMapID in pairs(Save.areaPoiIDs) do
            local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID) or {}
            local name
            name= get_AreaPOIInfo_Name(poiInfo)
            name= name=='' and areaPoiID or name
            info={
                text= name,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle= (e.onlyChinese and '移除' or REMOVE)..' '..areaPoiID,
                tooltipText= (C_Map.GetMapInfo(uiMapID) or {}).name,
                arg1= areaPoiID,
                arg2= uiMapID,
                func= function(_, arg1,arg2)
                    Save.areaPoiIDs[arg1]=nil
                    print(id,Initializer:GetName(), e.cn(addName2),
                        get_AreaPOIInfo_Name(C_AreaPoiInfo.GetAreaPOIInfo(arg2, arg1) or {})
                        'areaPoiID '..arg1,
                        ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..e.Icon.X2)
                )
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '全部清除' or CLEAR_ALL,
            notCheckable=true,
            func= function()
                Save.areaPoiIDs={}
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif menuList=='SETTINGS' then
        info={
            text= e.onlyChinese and '向下滚动' or COMBAT_TEXT_SCROLL_DOWN,
            checked= Save.textToDown,
            func= function()
                Save.textToDown= not Save.textToDown and true or nil
                for _, btn in pairs(Button.btn) do
                    btn:ClearAllPoints()
                    btn.text:ClearAllPoints()
                    btn:set_btn_point()
                end
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '重置位置' or RESET_POSITION,
            notCheckable=true,
            disabled= not Button,
            colorCode= not Save.pointVigentteButton and '|cff606060' or '',
            func= function()
                Save.pointVigentteButton=nil
                Button:ClearAllPoints()
                Button:Set_Point()
                print(id, Initializer:GetName(), e.onlyChinese and '重置位置' or RESET_POSITION)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    end

    if menuList then
        return
    end


    info={
        text= e.onlyChinese and '显示' or SHOW,
        checked= Save.vigentteButtonShowText,
        keepShownOnClick=true,
        func= function()
            Save.vigentteButtonShowText= not Save.vigentteButtonShowText and true or nil
            Button:set_Shown()
            Button:set_Texture()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)


    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= (e.onlyChinese and '当前' or REFORGE_CURRENT)..(Save.vigentteSound and '|A:chatframe-button-icon-voicechat:0:0|a' or ' ')..'Vignette',
        menuList='CurrentVignette',
        hasArrow=true,
        notCheckable=true,
        func= function()
            Save.hideVigentteCurrent= not Save.hideVigentteCurrent and true or nil
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    local num=0
    for _ in pairs(Save.questIDs) do
        num= num+1
    end
    info={
        text= (e.onlyChinese and '世界任务' or TRACKER_HEADER_WORLD_QUESTS)..' |cnGREEN_FONT_COLOR:#'..num,
        notCheckable=true,
        menuList= 'WorldQuest',
        hasArrow=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    num=0
    for _ in pairs(Save.areaPoiIDs) do
        num= num+1
    end
    info={
        text= 'AreaPoiID |cnGREEN_FONT_COLOR:#'..num,
        notCheckable=true,
        menuList= 'AreaPoiID',
        hasArrow=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    num=0
    for _, _ in pairs(Save.uiMapIDs) do--地图
        num= num+1
    end
    info={
        text= (e.onlyChinese and '地图' or WORLD_MAP)..'|cnGREEN_FONT_COLOR:#'..num,
        notCheckable=true,
        menuList= 'uiMapIDs',
        hasArrow=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)


    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= e.onlyChinese and '设置' or SETTINGS,
        notCheckable=true,
        keepShownOnClick=true,
        menuList='SETTINGS',
        hasArrow=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end























local function Init_Set_Button()--小地图, 标记, 文本
    if not Save.vigentteButton or Button then
        if Button then
            Button:set_Shown()
        end
        return
    end

    Button= e.Cbtn(nil, {icon='hide', size={18,18}, pushe=true})
    Button.btn={}

    Button.Frame= CreateFrame('Frame', nil, Button)
    Button.Frame:SetAllPoints(Button)

    Button.texture= Button:CreateTexture(nil, 'BORDER')
    Button.texture:SetAllPoints(Button)
    Button.texture:SetAlpha(0.5)

    --播放声音
    function Button:speak_Text(text)
        local ttsVoices= C_VoiceChat.GetTtsVoices() or {}
        local voiceID= ttsVoices.voiceID or C_TTSSettings.GetVoiceOptionID(Enum.TtsVoiceType.Standard)
        local destination= ttsVoices.voiceID and Enum.VoiceTtsDestination.QueuedLocalPlayback or Enum.VoiceTtsDestination.LocalPlayback
        --C_VoiceChat.SpeakText(voiceID, text, destination, rate, volume)
        C_VoiceChat.SpeakText(voiceID, text, destination, 0, 100)
        print(id, e.cn(addName2),'|cffff00ff', text)
    end
    function Button:set_VIGNETTES_UPDATED(init)
        if UnitOnTaxi('player') or not Save.vigentteSound then
            self.SpeakTextTab=nil
            return
        end
        self.SpeakTextTab= self.SpeakTextTab or {}
        local find
        for _, vignetteGUID in pairs(C_VignetteInfo.GetVignettes() or {}) do
            local info= vignetteGUID and C_VignetteInfo.GetVignetteInfo(vignetteGUID) or {}
            if info.name and info.name~='' and info.zoneInfiniteAOI then
                if init then
                    if not info.isDead then
                        self.SpeakTextTab[info.name]=true
                    end
                else
                    if info.isDead then
                        self.SpeakTextTab[info.name]=nil
                    elseif not self.SpeakTextTab[info.name] then
                        if not find then
                            self:speak_Text(info.name)
                            find=true
                        end
                        self.SpeakTextTab[info.name]=true
                    end
                end
            end
        end
    end

    function Button:set_Shown()
        local hide= not Save.vigentteButton
            or IsInInstance()
            or UnitAffectingCombat('player')
            or WorldMapFrame:IsShown()

        Button:SetShown(not hide)
        Button.Frame:SetShown(Save.vigentteButtonShowText and not hide)
    end

    function Button:set_Texture()
        if Save.vigentteButtonShowText then
            self.texture:SetTexture(0)
        else
            self.texture:SetAtlas('VignetteKillElite')
        end
    end

    function Button:Set_Point()--设置，位置
        if Save.pointVigentteButton then
            self:SetPoint(Save.pointVigentteButton[1], UIParent, Save.pointVigentteButton[3], Save.pointVigentteButton[4], Save.pointVigentteButton[5])
        elseif e.Player.husandro then
            self:SetPoint('TOPLEFT', 300, 0)
        else
            self:SetPoint('BOTTOMLEFT', QuickJoinToastButton, 'TOPLEFT', 4, 2)
        end
    end

    Button:RegisterForDrag("RightButton")
    Button:SetMovable(true)
    Button:SetClampedToScreen(true)
    Button:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    Button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save.pointVigentteButton={self:GetPoint(1)}
        Save.pointVigentteButton[2]=nil
    end)

    Button:SetScript('OnMouseUp', ResetCursor)
    Button:SetScript('OnMouseDown', function(self, d)--显示，隐藏
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        else
            local key= IsModifierKeyDown()
            if d=='LeftButton' and not key then
                Save.vigentteButtonShowText= not Save.vigentteButtonShowText and true or nil
                self:set_Shown()
                self:set_Texture()

            elseif d=='RightButton' and not key then
                self:show_menu()
            end
        end
    end)



    function Button:show_menu(frame)
        if not self.menu then
            self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
            e.LibDD:UIDropDownMenu_Initialize(self.Menu, Init_Button_Menu, 'MENU')
        end
        e.LibDD:ToggleDropDownMenu(1, nil,self.Menu, frame or self, 15,0)
    end

    function Button:set_Tootips()
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(Initializer:GetName(), e.cn(addName2))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.GetShowHide(nil, true), e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '主菜单' or MAINMENU_BUTTON, e.Icon.right)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' '..(Save.vigentteButtonTextScale), 'Alt+'..e.Icon.mid)
        e.tips:Show()
    end

    Button:SetScript('OnMouseWheel', function(self, d)--缩放
        if IsAltKeyDown() then
            local scale= Save.vigentteButtonTextScale or 1
            if d==1 then
                scale= scale- 0.05
            elseif d==-1 then
                scale= scale+ 0.05
            end
            scale= scale>2.5 and 2.5  or scale
            scale= scale<0.4 and 0.4 or scale
            print(id, Initializer:GetName(), e.onlyChinese and '缩放' or UI_SCALE, scale)
            Save.vigentteButtonTextScale= scale
            self:set_Frame_Scale()--设置，Button的 Frame Text 属性
            self:set_Tootips()
        end
    end)

    Button:SetScript('OnEnter',function(self)
        self:set_Tootips()
        self.texture:SetAlpha(1)
    end)
    Button:SetScript('OnLeave',function(self)
        e.tips:Hide()
        ResetCursor()
        self.texture:SetAlpha(0.5)
    end)

    function Button:set_Event()
        self:UnregisterAllEvents()

        self:RegisterEvent('PLAYER_ENTERING_WORLD')--设置，事件
        if Save.vigentteButton and not IsInInstance() then
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            if Save.vigentteSound then
                self:RegisterEvent('VIGNETTES_UPDATED')
            end
        end
    end

    Button:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_ENTERING_WORLD' then
            self.SpeakTextTab=nil
            self:set_Event()
            self:set_Shown()
        elseif event=='VIGNETTES_UPDATED' then
            self:set_VIGNETTES_UPDATED()
        else--PLAYER_REGEN_DISABLED PLAYER_REGEN_ENABLED
            self:set_Shown()
        end
    end)

    function Button:set_Frame_Scale()--设置，Button的 Frame Text 属性
        self.Frame:SetScale(Save.vigentteButtonTextScale or 1)
    end

    WorldMapFrame:HookScript('OnHide', function() Button:set_Shown() end)
    WorldMapFrame:HookScript('OnShow', function() Button:set_Shown() end)

    Button.Frame:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 1) + elapsed
        if self.elapsed>=1 then
            self.elapsed=0
            set_Button_Text()
        end
    end)

    Button:set_VIGNETTES_UPDATED(true)
    Button:Set_Point()
    Button:set_Texture()
    Button:set_Frame_Scale()
    Button:set_Event()
    Button:set_Shown()






    hooksecurefunc('TaskPOI_OnEnter', function(self)--世界任务，提示 WorldMapFrame.lua
        if self.questID and self.OnMouseClickAction then
            e.tips:AddDoubleLine(addName2..(Save.questIDs[self.questID] and e.Icon.select2 or ''), 'Alt+'..e.Icon.left)
            e.tips:Show()
        end
    end)
    hooksecurefunc(WorldQuestPinMixin, 'RefreshVisuals', function(self)--世界任务，添加/移除 WorldQuestDataProvider.lua self.tagInfo
        if not self.OnMouseClickAction or self.setTracking then
            return
        end
        hooksecurefunc(self, 'OnMouseClickAction', function(self, d)
            if self.questID and d=='LeftButton' and IsAltKeyDown() then
                Save.questIDs[self.questID]= not Save.questIDs[self.questID] and true or nil
                print(id,Initializer:GetName(), e.cn(addName2),
                    GetQuestLink(self.questID) or self.questID,
                    Save.questIDs[self.questID] and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..e.Icon.select2 or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..e.Icon.X2)
                )
            end
        end)
        self.setTracking=true
    end)

    hooksecurefunc(AreaPOIPinMixin,'TryShowTooltip', function(self)--areaPoiID,提示 AreaPOIDataProvider.lua
        if self.areaPoiID and  self:GetMap() and self:GetMap():GetMapID() then
            e.tips:AddDoubleLine(addName2..(Save.areaPoiIDs[self.areaPoiID] and e.Icon.select2 or ''), 'Alt+'..e.Icon.left)
            e.tips:Show()
        end
    end)
    hooksecurefunc(AreaPOIPinMixin,'OnAcquired', function(self)---areaPoiID, 添加/移除 AreaPOIDataProvider.lua
        if self.setTracking then
            return
        end
        self:HookScript('OnMouseDown', function(self2,d)
            if self2.areaPoiID and d=='LeftButton' and IsAltKeyDown() then
                local uiMapID = self:GetMap() and self:GetMap():GetMapID()
                if uiMapID then
                    Save.areaPoiIDs[self.areaPoiID]= not Save.areaPoiIDs[self.areaPoiID] and uiMapID or nil
                    local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, self.areaPoiID) or {}
                    local name= get_AreaPOIInfo_Name(poiInfo)--取得 areaPoiID 名称
                    name= name=='' and 'areaPoiID '..self.areaPoiID or name
                    print(id,Initializer:GetName(), e.cn(addName2),
                        (C_Map.GetMapInfo(uiMapID) or {}).name or ('uiMapID '..uiMapID),
                        name,
                        Save.areaPoiIDs[self.areaPoiID] and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..e.Icon.select2 or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..e.Icon.X2)
                    )
                end
            end
        end)
        self.setTracking=true
    end)

    local SetTrackingButton= e.Cbtn(WorldMapFrame, {size={20,20}, icon='hide'})
    function SetTrackingButton:set_texture()
        local uiMapID= WorldMapFrame.mapID or WorldMapFrame:GetMapID("current")
        if not uiMapID then
            self:SetNormalTexture(0)
        else
            self:SetNormalAtlas(Save.uiMapIDs[uiMapID] and e.Icon.select or 'VignetteKillElite')
        end
    end
    SetTrackingButton:SetPoint('TOPRIGHT', WorldMapFramePortrait, 'BOTTOMRIGHT', 2, 10)
    SetTrackingButton:SetScript('OnClick', function(self)
        local uiMapID= WorldMapFrame.mapID or WorldMapFrame:GetMapID("current")
        if uiMapID then
            Save.uiMapIDs[uiMapID]= not Save.uiMapIDs[uiMapID] and true or nil
            local name= (C_Map.GetMapInfo(uiMapID) or {}).name or ('uiMapID '..uiMapID)
            print(id,Initializer:GetName(), e.cn(addName2),
                name,
                Save.uiMapIDs[uiMapID] and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..e.Icon.select2 or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..e.Icon.X2)
            )
            self:set_texture()
        end
    end)
    SetTrackingButton:SetScript('OnShow', SetTrackingButton.set_texture)
    SetTrackingButton:SetScript('OnLeave', GameTooltip_Hide)
    SetTrackingButton:SetScript('OnEnter', function(self)
        local uiMapID= WorldMapFrame.mapID or WorldMapFrame:GetMapID("current")
        if uiMapID then
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(addName2..(Save.uiMapIDs[uiMapID] and e.Icon.select2 or ''), ((C_Map.GetMapInfo(uiMapID) or {}).name or '')..' '..uiMapID)
            e.tips:AddDoubleLine(id, Initializer:GetName())
            e.tips:Show()
        end
    end)
    hooksecurefunc(WorldMapFrame, 'OnMapChanged', function() SetTrackingButton:set_texture() end)--uiMapIDs, 添加，移除 --Blizzard_WorldMap.lua
end






































--###################
--更新地区时,缩小化地图
--###################
local function set_ZoomOut()
    if Save.ZoomOut then
        local value= Minimap:GetZoomLevels()
        if value~=0 then
            Minimap:SetZoom(0)
        end
    end
end























--################
--当前缩放，显示数值
--Minimap.lua
local function set_Event_MINIMAP_UPDATE_ZOOM()
    if Save.ZoomOutInfo then
        panel:RegisterEvent('MINIMAP_UPDATE_ZOOM')
    else
        panel:UnregisterEvent('MINIMAP_UPDATE_ZOOM')
        if Minimap.zoomText then
            Minimap.zoomText:SetText('')
        end
        if Minimap.viewRadius then
            Minimap.viewRadius:SetText('')
        end
    end
end
local function set_MINIMAP_UPDATE_ZOOM()
    local zoom = Minimap:GetZoom()
    local level= Minimap:GetZoomLevels()
    if not Minimap.zoomText then
        Minimap.zoomText= e.Cstr(Minimap, {color=true, mouse=true})
        Minimap.zoomText:SetPoint('BOTTOM', Minimap.ZoomOut, 'TOP', 3, 0)
        Minimap.zoomText:SetAlpha(0.5)
        Minimap.zoomText:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.5) end)
        Minimap.zoomText:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.onlyChinese and '缩放' or UI_SCALE, self:GetText())
            e.tips:AddDoubleLine(id, Initializer:GetName())
            e.tips:Show()
            self:SetAlpha(1)
        end)
    end
    Minimap.zoomText:SetText(zoom and level and (level-zoom)..'/'..level or '')

    if not Minimap.viewRadius then
        Minimap.viewRadius=e.Cstr(Minimap, {color=true, justifyH='CENTER', mouse=true})
        Minimap.viewRadius:SetPoint('BOTTOMLEFT', Minimap, 'BOTTOM', 8, -8)
        --Minimap.viewRadius:EnableMouse(true)
        Minimap.viewRadius:SetAlpha(0.5)
        Minimap.viewRadius:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.5) end)
        Minimap.viewRadius:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.onlyChinese and '镜头视野范围' or CAMERA_FOV, format(e.onlyChinese and '%s码' or IN_GAME_NAVIGATION_RANGE, format('%i', C_Minimap.GetViewRadius() or 100)))
            e.tips:AddDoubleLine(id, Initializer:GetName())
            e.tips:Show()
            self:SetAlpha(1)
        end)

    end
    Minimap.viewRadius:SetFormattedText('%i', C_Minimap.GetViewRadius() or 100)
end













--挑战专送门标签
--10.2 第三赛季
local MRoomFrame
local function Init_M_Portal_Room_Labels()
    if C_MythicPlus.GetCurrentSeason()~=11
        or Save.hideMPortalRoomLabels
        or MRoomFrame
    then
        if MRoomFrame then
            MRoomFrame:set_evnet()
            MRoomFrame:set_shown()
        end
        return
    end

    MRoomFrame= CreateFrame('Frame')

    function MRoomFrame:set_evnet()
        MRoomFrame:UnregisterAllEvents()
        if not Save.hideMPortalRoomLabels then
            MRoomFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
            if select(8, GetInstanceInfo())==2678 then
                MRoomFrame:RegisterEvent('PLAYER_STARTED_MOVING')
                MRoomFrame:RegisterEvent('PLAYER_STOPPED_MOVING')
            end
        end
    end
    function MRoomFrame:set_shown()
        local instanceID= select(8, GetInstanceInfo())
        self:SetShown(instanceID==2678 and not Save.hideMPortalRoomLabels and not IsPlayerMoving())
    end
    MRoomFrame:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_ENTERING_WORLD' then
            self:set_evnet()
        end
        self:set_shown()
    end)
    MRoomFrame:set_evnet()
    MRoomFrame:set_shown()

    local cn= e.onlyChinese and not LOCALE_zhCN and not LOCALE_zhTW

    local lable= e.Cstr(MRoomFrame, {color=true, justifyH='CENTER'})
    local mapInfo=C_Map.GetMapInfo(641) or {}
    lable:SetPoint('CENTER', UIParent, 0, 200)
    lable:SetText(
        (cn and '堡垒 | 林地|n' or '')
        ..( EJ_GetInstanceInfo(740) or '')..' | '..( EJ_GetInstanceInfo(762) or '')
        ..(mapInfo.name and '|n'..mapInfo.name or '')
    )


    lable= e.Cstr(MRoomFrame, {color=true, justifyH='CENTER'})
    lable:SetPoint('CENTER', UIParent, -150, 150)
    mapInfo=C_Map.GetMapInfo(543) or {}
    lable:SetText(
        (cn and '永茂林地|n' or '')
        ..(EJ_GetInstanceInfo(556) or '')
        ..(mapInfo.name and '|n'..mapInfo.name or '')
    )


    lable= e.Cstr(MRoomFrame, {color=true, justifyH='CENTER', mouse=true})
    mapInfo=C_Map.GetMapInfo(203) or {}
    lable:SetPoint('CENTER', UIParent, -200, 100)
    lable:SetText(
        (cn and '潮汐王座|n' or '')
        ..(EJ_GetInstanceInfo(65) or '')
        ..(mapInfo.name and '|n'..mapInfo.name or '')
    )
    lable:SetScript('OnLeave', function(self) self:SetAlpha(1) e.tips:Hide() end)
    lable:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(e.onlyChinese and '挑战传送门标签' or 'M+ Portal Room Labels')
        e.tips:Show()
        self:SetAlpha(0.3)
    end)


    lable= e.Cstr(MRoomFrame, {color=true, justifyH='CENTER'})
    lable:SetPoint('CENTER', UIParent, 150, 150)
    mapInfo=C_Map.GetMapInfo(862) or {}
    lable:SetText(
        (cn and '阿塔达萨|n' or '')
        ..(EJ_GetInstanceInfo(968) or '')
        ..(mapInfo.name and '|n'..mapInfo.name or '')
    )


    lable= e.Cstr(MRoomFrame, {color=true, justifyH='CENTER'})
    mapInfo=C_Map.GetMapInfo(896) or {}
    lable:SetPoint('CENTER', UIParent, 200, 100)
    lable:SetText(
        (cn and '维克雷斯庄园|n' or '')
        ..(EJ_GetInstanceInfo(1021) or '')
        ..(mapInfo.name and '|n'..mapInfo.name or '')
    )
end


























 --盟约 9.0
 local mainTextureKitRegions = {
	["Background"] = "CovenantSanctum-Renown-Background-%s",
	["TitleDivider"] = "CovenantSanctum-Renown-Title-Divider-%s",
	["Divider"] = "CovenantSanctum-Renown-Divider-%s",
	["Anima"] = "CovenantSanctum-Renown-Anima-%s",
	["FinalToastSlabTexture"] = "CovenantSanctum-Renown-FinalToast-%s",
	["SelectedLevelGlow"] = "CovenantSanctum-Renown-Next-Glow-%s",
}
local function SetupTextureKit(frame, regions, covenantData)
	SetupTextureKitOnRegions(covenantData.textureKit, frame, regions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
end

local function Set_Covenant_Button(self, covenantID, activityID)
    local btn= self['covenant'..covenantID]
    if not btn then
        local info = C_Covenants.GetCovenantData(covenantID) or {}
        btn=e.Cbtn(self.frame or self, {size={32,32}, atlas=format('SanctumUpgrades-%s-32x32', info.textureKit)})
        btn:SetHighlightAtlas('ChromieTime-Button-HighlightForge-ColorSwatchHighlight')
        if covenantID==1 then
            btn:SetPoint('BOTTOMLEFT', self.frame and self:GetParent() or self, 'TOPLEFT', 0, 5)
        else
            btn:SetPoint('LEFT', self['covenant'..(covenantID-1)], 'RIGHT')
        end
        btn:SetScript('OnClick', function(frame)
            if not CovenantRenownFrame or not CovenantRenownFrame:IsShown() then
                do
                    ToggleCovenantRenown()
                end
            end

            --CovenantRenownMixin:SetUpCovenantData()
            local covenantData = C_Covenants.GetCovenantData(frame.covenantID) or {}
            local textureKit = covenantData.textureKit;
            NineSliceUtil.ApplyUniqueCornersLayout(CovenantRenownFrame.NineSlice, textureKit);
            NineSliceUtil.DisableSharpening(CovenantRenownFrame.NineSlice);
            local atlas = "CovenantSanctum-RenownLevel-Border-%s";
            CovenantRenownFrame.HeaderFrame.Background:SetAtlas(atlas:format(textureKit), TextureKitConstants.UseAtlasSize);
            UIPanelCloseButton_SetBorderAtlas(CovenantRenownFrame.CloseButton, "UI-Frame-%s-ExitButtonBorder", -1, 1, textureKit);
            SetupTextureKit(CovenantRenownFrame, mainTextureKitRegions, covenantData);
            local renownLevelsInfo = C_CovenantSanctumUI.GetRenownLevels(frame.covenantID) or {}
            for i, levelInfo in ipairs(renownLevelsInfo) do
                levelInfo.textureKit = textureKit;
                levelInfo.rewardInfo = C_CovenantSanctumUI.GetRenownRewardsForLevel(frame.covenantID, i);
            end
            CovenantRenownFrame.TrackFrame:Init(renownLevelsInfo);
            CovenantRenownFrame.maxLevel = renownLevelsInfo[#renownLevelsInfo].level;

            --CovenantRenownMixin:GetLevels()
            local renownLevel = C_CovenantSanctumUI.GetRenownLevel();
            self.actualLevel = renownLevel;
            local cvarName = "lastRenownForCovenant"..frame.covenantID
            local lastRenownLevel = tonumber(GetCVar(cvarName)) or 1;
            if lastRenownLevel < renownLevel then
                renownLevel = lastRenownLevel;
            end
            self.displayLevel = renownLevel;

            CovenantRenownFrame:Refresh(true)

            C_CovenantSanctumUI.RequestCatchUpState();
        end)
        btn.covenantID= covenantID
        self['covenant'..covenantID]=btn
        btn.Text=e.Cstr(btn, {color={r=1,g=1,b=1}})
        btn.Text:SetPoint('CENTER')
    end

    local level=0
    local isMaxLevel
    if covenantID==activityID then
        btn:LockHighlight()
        level= C_CovenantSanctumUI.GetRenownLevel()
        isMaxLevel= C_CovenantSanctumUI.HasMaximumRenown()
    else
        btn:UnlockHighlight()
        local tab = C_CovenantSanctumUI.GetRenownLevels(covenantID) or {}
        local num= #tab
        for i=num, 1, -1 do
            if not tab[i].locked then
                level= tab[i].level
                isMaxLevel= i==num
                break
            end
        end
    end
    btn.Text:SetText(isMaxLevel and format('|cnGREEN_FONT_COLOR:%d|r', level) or level)
    btn.renownLevel= level
    return btn
 end




 --盟约 9.0
 local function Init_Blizzard_CovenantRenown()
    CovenantRenownFrame:HookScript('OnShow', function(self)
        local activityID = C_Covenants.GetActiveCovenantID() or 0
        if activityID>0 then
            for i=1, 4 do
                if Save.hide_MajorFactionRenownFrame_Button then
                    local btn= self['covenant'..i]
                    if btn then
                        btn:SetShown(false)
                    end
                else
                    local btn=Set_Covenant_Button(CovenantRenownFrame, i, activityID)
                    btn:SetShown(true)
                end
            end
        end
    end)
end
























--取得，等级，派系声望
local function Get_Major_Faction_Level(factionID, level)
    local text=''
    level= level or 0
    if C_MajorFactions.HasMaximumRenown(factionID) then
        if C_Reputation.IsFactionParagon(factionID) then--奖励
            local currentValue, threshold, _, hasRewardPending, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID)
            if not tooLowLevelForParagon and currentValue and threshold then
                local completed= math.modf(currentValue/threshold)--完成次数
                currentValue= completed>0 and currentValue - threshold * completed or currentValue
                text= format('%i%%|A:GarrMission-%sChest:0:0|a%s%d', currentValue/threshold*100, e.Player.faction, hasRewardPending and e.Icon.select2 or '', completed)

            end
        end
        text= text or format('|cnGREEN_FONT_COLOR:%d|r|A:common-icon-checkmark:0:0|a', level)
    else
        local levels = C_MajorFactions.GetRenownLevels(factionID)
        if levels then
            text= format('%d/%d', level, #levels)
        else
            text= format('%d', level)
        end
        local info = C_MajorFactions.GetMajorFactionData(factionID)
        if info then
            text= format('%s %i%%', text, info.renownReputationEarned/info.renownLevelThreshold*100)
        end
    end
    return text
end


--取得，所有，派系声望
local function Get_Major_Faction_List()
    local tab={}
    for i= LE_EXPANSION_DRAGONFLIGHT, e.ExpansionLevel, 1 do
        for _, factionID in pairs(C_MajorFactions.GetMajorFactionIDs(i) or {}) do--if C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(i) then
            table.insert(tab, factionID)
        end
    end
    for _, factionID in pairs(Constants.MajorFactionsConsts or {}) do--MajorFactionsConstantsDocumentation.lu
        table.insert(tab, factionID)
    end
    table.sort(tab, function(a,b) return a>b end)
    return tab
end


--菜单, 派系声望
local function Set_Faction_Menu(factionID)
    local data = C_MajorFactions.GetMajorFactionData(factionID or 0)
    if data and data.name then
        return {
            text=format('|A:majorfactions_icons_%s512:0:0|a%s %s',
                        data.textureKit or '',
                        e.cn(data.name) or (e.onlyChinese and '主要阵营' or MAJOR_FACTION_LIST_TITLE),
                        --C_MajorFactions.HasMaximumRenown(factionID) and '|cnGREEN_FONT_COLOR:' or '',
                        Get_Major_Faction_Level(factionID, data.renownLevel)),
            checked= MajorFactionRenownFrame and MajorFactionRenownFrame.majorFactionID==factionID,
            keepShownOnClick=true,
            colorCode= UnitAffectingCombat('player') and '|cnRED_FONT_COLOR:' or ((not data.isUnlocked and data.renownLevel==0) and '|cff606060') or nil,
            tooltipOnButton=true,
            tooltipTitle='FactionID '..factionID,
            arg1=factionID,
            func= function(_, arg1)
                if MajorFactionRenownFrame and MajorFactionRenownFrame.majorFactionID==arg1 then
                    MajorFactionRenownFrame:Hide()
                else
                    ToggleMajorFactionRenown(arg1)
                end
            end
        }
    end
end

--派系，列表 MajorFactionRenownFrame
local function Init_MajorFactionRenownFrame()
    MajorFactionRenownFrame.WoWToolsFaction= e.Cbtn(MajorFactionRenownFrame, {size={22,22}, icon='hide'})
    function MajorFactionRenownFrame.WoWToolsFaction:set_scale()
        self.frame:SetScale(Save.MajorFactionRenownFrame_Button_Scale or 1)
    end
    function MajorFactionRenownFrame.WoWToolsFaction:set_texture()
        self:SetNormalAtlas(Save.hide_MajorFactionRenownFrame_Button and 'talents-button-reset' or e.Icon.icon)
    end
    function MajorFactionRenownFrame.WoWToolsFaction:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.GetShowHide(not Save.hide_MajorFactionRenownFrame_Button), e.Icon.left)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.MajorFactionRenownFrame_Button_Scale or 1), e.Icon.mid)
        e.tips:Show()
    end
    MajorFactionRenownFrame.WoWToolsFaction:SetFrameStrata('HIGH')
    MajorFactionRenownFrame.WoWToolsFaction:SetPoint('LEFT', MajorFactionRenownFrame.CloseButton, 'RIGHT', 4, 0)
    MajorFactionRenownFrame.WoWToolsFaction:SetScript('OnLeave', GameTooltip_Hide)
    MajorFactionRenownFrame.WoWToolsFaction:SetScript('OnEnter', MajorFactionRenownFrame.WoWToolsFaction.set_tooltips)
    MajorFactionRenownFrame.WoWToolsFaction:SetScript('OnClick', function(self)
        Save.hide_MajorFactionRenownFrame_Button= not Save.hide_MajorFactionRenownFrame_Button and true or nil
        self:set_faction()
        self:set_texture()
        self:set_tooltips()
    end)
    MajorFactionRenownFrame.WoWToolsFaction:SetScript('OnMouseWheel', function(self, d)
        local n= Save.MajorFactionRenownFrame_Button_Scale or 1
        n= d==1 and n-0.1 or n
        n= d==-1 and n+0.1 or n
        n= n>4 and 4 or n
        n= n<0.4 and 0.4 or n
        Save.MajorFactionRenownFrame_Button_Scale=n
        self:set_scale()
        self:set_tooltips()
    end)


    MajorFactionRenownFrame.WoWToolsFaction.frame=CreateFrame('Frame', nil, MajorFactionRenownFrame.WoWToolsFaction)
    MajorFactionRenownFrame.WoWToolsFaction.btn={}
    function MajorFactionRenownFrame.WoWToolsFaction:set_faction()
        if Save.hide_MajorFactionRenownFrame_Button then
            self.frame:SetShown(false)
            return
        end
        self.frame:SetShown(true)

        --所有，派系声望
        local selectFactionID= MajorFactionRenownFrame:GetCurrentFactionID()
        local tab= Get_Major_Faction_List()--取得，所有，派系声望
        local n=1
        for _, factionID in pairs(tab) do
            local info=C_MajorFactions.GetMajorFactionData(factionID or 0)
            if info then
                local btn= self.btn[n]
                if not btn then
                    btn= e.Cbtn(self.frame, {size={235/2.5, 110/2.5}, icon='hide'})
                    btn:SetPoint('TOPLEFT', self.btn[n-1] or self, 'BOTTOMLEFT')
                    btn:SetHighlightAtlas('ChromieTime-Button-Highlight')
                    btn:SetScript('OnLeave', GameTooltip_Hide)
                    btn:SetScript('OnEnter', ReputationBarMixin.ShowMajorFactionRenownTooltip)
                    btn:SetScript('OnClick', function(frame)
                        if MajorFactionRenownFrame:GetCurrentFactionID()~=frame.factionID then
                            ToggleMajorFactionRenown(frame.factionID)
                        end
                    end)
                    btn.Text= e.Cstr(btn)
                    btn.Text:SetPoint('BOTTOMLEFT', btn, 'BOTTOM')
                    self.btn[n]= btn
                end
                n= n+1
                btn.factionID= factionID
                btn:SetNormalAtlas('majorfaction-celebration-'..(info.textureKit or 'toastbg'))
                btn:SetPushedAtlas('MajorFactions_Icons_'..(info.textureKit or '')..'512')
                if selectFactionID==factionID then--选中
                    btn:LockHighlight()
                else
                    btn:UnlockHighlight()
                end
                btn.Text:SetText(Get_Major_Faction_Level(factionID, info.renownLevel))--等级
            end
        end

        --盟约
        local activityID = C_Covenants.GetActiveCovenantID() or 0
        if activityID>0 then
            for i=1, 4 do
                Set_Covenant_Button(self, i, activityID)
            end
        end

    end


    MajorFactionRenownFrame.WoWToolsFaction:set_scale()
    MajorFactionRenownFrame.WoWToolsFaction:set_texture()
    MajorFactionRenownFrame.WoWToolsFaction.HeaderText= e.Cstr(MajorFactionRenownFrame.WoWToolsFaction.frame, {color={r=1, g=1, b=1}, copyFont=MajorFactionRenownFrame.HeaderFrame.Level, justifyH='LEFT', size=14})
    MajorFactionRenownFrame.WoWToolsFaction.HeaderText:SetPoint('BOTTOMLEFT', MajorFactionRenownFrame.HeaderFrame.Level, 'BOTTOMRIGHT', 16, -4)

    function MajorFactionRenownFrame.WoWToolsFaction.HeaderText:set_text()
        local text=''
        if not Save.hide_MajorFactionRenownFrame_Button then
            local factionID= MajorFactionRenownFrame:GetCurrentFactionID()
            local info=C_MajorFactions.GetMajorFactionData(factionID or 0)
            if info then
                text= Get_Major_Faction_Level(factionID, info.renownLevel)
            end
        end
        self:SetText(text)
    end
    hooksecurefunc(MajorFactionRenownFrame, 'Refresh', function(self)
        self.WoWToolsFaction:set_faction()
        self.WoWToolsFaction.HeaderText:set_text(majorFactionID)
    end)
end





















--要塞,任务，列表
local function Get_Garrison_List_Num(followerType)
    local num, all, text= 0, 0, ''
    local missions = followerType and C_Garrison.GetInProgressMissions(followerType) or {}--GarrisonBaseUtils.lua
    for _, mission in ipairs(missions) do
        if (mission.isComplete == nil) then
            mission.isComplete = mission.timeLeftSeconds == 0
        end
        if mission.isComplete then
            num = num + 1
        end
        all = all + 1
    end
    if all==0 then
        text= ''--format('|cff606060%d/%d|r', num, all)
    elseif num==0 then
        text= format('|cff606060%d|r/%d', num, all)
    elseif all==num then
        text= format('|cffff00ff%d/%d|r', num, all)..e.Icon.select2
    else
        text= format('|cnGREEN_FONT_COLOR:%d|r/%d', num, all)
    end
    return text
end

--要塞报告 GarrisonBaseUtils.lua
local function Init_Garrison_Menu(level)
    local GarrisonList={

        {name=  e.onlyChinese and '盟约圣所' or GARRISON_TYPE_9_0_LANDING_PAGE_TITLE,
        garrisonType= Enum.GarrisonType.Type_9_0_Garrison,
        garrFollowerTypeID= Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower,
        disabled= C_Covenants.GetActiveCovenantID()==0,
        atlas= function()
            local info= C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID() or 0) or {}
            local icon=''
            if info.textureKit then
                icon= format('CovenantChoice-Celebration-%sSigil', info.textureKit or '')
            end
            return icon
        end,
        tooltip= e.onlyChinese and '点击显示圣所报告' or GARRISON_TYPE_9_0_LANDING_PAGE_TOOLTIP,
        },

        --[[{name=  e.onlyChinese and '任务' or GARRISON_TYPE_8_0_LANDING_PAGE_TITLE,
        garrisonType= Enum.GarrisonType.Type_8_0_Garrison,
        garrFollowerTypeID= Enum.GarrisonFollowerType.FollowerType_8_0_GarrisonFollower,
        atlas= string.format("bfa-landingbutton-%s-up", e.Player.faction),
        tooltip= e.onlyChinese and '点击显示任务报告' or GARRISON_TYPE_8_0_LANDING_PAGE_TOOLTIP,
        },]]

        {name=  e.onlyChinese and '职业大厅' or ORDERHALL_MISSION_REPORT:match('(.-)%\n') or ORDER_HALL_LANDING_PAGE_TITLE,
        garrisonType= Enum.GarrisonType.Type_7_0_Garrison,
        garrFollowerTypeID= Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower,
        frame='OrderHallMissionFrame',
        atlas= e.Class('player', nil, true),--职业图标 -- e.Player.class == "EVOKER" and "UF-Essence-Icon-Active" or string.format("legionmission-landingbutton-%s-up", e.Player.class),
        tooltip= e.onlyChinese and '点击显示职业大厅报告' or MINIMAP_ORDER_HALL_LANDING_PAGE_TOOLTIP,
        },

        {name= e.onlyChinese and '要塞' or GARRISON_LOCATION_TOOLTIP,
        garrisonType= Enum.GarrisonType.Type_6_0_Garrison,
        garrFollowerTypeID= Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower,
        garrFollowerTypeID2=Enum.GarrisonFollowerType.FollowerType_6_0_Boat,
        atlas= format("GarrLanding-MinimapIcon-%s-Up", e.Player.faction),
        atlas2= format('Islands-%sBoat', e.Player.faction),
        tooltip= e.onlyChinese and '点击显示要塞报告' or MINIMAP_GARRISON_LANDING_PAGE_TOOLTIP,
        },

        {name='-'},

        {name=  e.onlyChinese and '巨龙群岛概要' or DRAGONFLIGHT_LANDING_PAGE_TITLE,
        garrisonType= Enum.GarrisonType.Type_9_0_Garrison,
        garrFollowerTypeID= Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower,
        disabled=not C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(LE_EXPANSION_DRAGONFLIGHT),
        atlas= 'dragonflight-landingbutton-up',
        tooltip= e.onlyChinese and '点击显示巨龙群岛概要' or DRAGONFLIGHT_LANDING_PAGE_TOOLTIP,
        func= function()
            ToggleExpansionLandingPage()
        end,
        },
    }


    local bat= UnitAffectingCombat('player')
    for _, info in pairs(GarrisonList) do
        if info.name=='-' then
            e.LibDD:UIDropDownMenu_AddSeparator(level)

        else
            local has= C_Garrison.HasGarrison(info.garrisonType)
            local num, num2= '', ''
            if has then
                num= ' '..Get_Garrison_List_Num(info.garrFollowerTypeID)
                if info.garrFollowerTypeID2 then
                    num2= format(' |A:%s:0:0|a%s', info.atlas2 or '',  Get_Garrison_List_Num(info.garrFollowerTypeID2))
                end
            end
            local atlas= type(info.atlas)=='function' and info.atlas() or info.atlas
            local disabled
            if info.disabled then
                disabled= info.disabled
            else
                disabled= not has
            end
            disabled= disabled or bat
            e.LibDD:UIDropDownMenu_AddButton({
                text= format('|A:%s:0:0|a%s%s%s', atlas, info.name, num, num2),
                checked= GarrisonLandingPage and GarrisonLandingPage:IsShown() and GarrisonLandingPage.garrTypeID==info.garrisonType,
                disabled= disabled,
                keepShownOnClick=true,
                tooltipOnButton=true,
                tooltipTitle= info.tooltip,
                arg1= info.garrisonType,
                func= info.func or function(_, garrisonType)
                    if GarrisonLandingPage and GarrisonLandingPage:IsShown() and GarrisonLandingPage.garrTypeID==garrisonType then
                        GarrisonLandingPage:Hide()
                    else
                        ShowGarrisonLandingPage(garrisonType)
                    end
                end
            }, level)
        end
    end
end





















--#########
--初始，菜单
--#########
local function Init_Menu(_, level, menuList)
    local info
    if menuList=='panelButtonRestPoint' then
        info={
            text= e.onlyChinese and '重置位置' or RESET_POSITION,
            notCheckable=true,
            disabled= not Button,
            keepShownOnClick=true,
            colorCode= not Save.pointVigentteButton and '|cff606060' or '',
            func= function()
                Save.pointVigentteButton=nil
                Button:ClearAllPoints()
                Button:Set_Point()
                print(id, Initializer:GetName(), e.onlyChinese and '重置位置' or RESET_POSITION)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif menuList=='ResetTimeManagerClockButton' then
        info={
            text= e.onlyChinese and '重置位置' or RESET_POSITION,
            notCheckable=true,
            keepShownOnClick=true,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '时钟' or TIMEMANAGER_TITLE,
            disabled= not Save.TimeManagerClockButtonScale and not Save.TimeManagerClockButtonPoint,
            colorCode= Save.disabledClockPlus and '|cff606060',
            func= function()
                Save.TimeManagerClockButtonScale=nil
                Save.TimeManagerClockButtonPoint=nil
                TimeManagerClockButton:SetScale(1)
                TimeManagerClockButton:ClearAllPoints()
                TimeManagerClockButton:SetParent(MinimapCluster)
                TimeManagerClockButton:SetPoint('TOPRIGHT', MinimapCluster.BorderTop,-4,0)--Blizzard_TimeManager.xml
                --<Anchor point="TOPRIGHT" relativeKey="$parent.BorderTop" x="-4" y="0"/>
                print(id, Initializer:GetName(), e.onlyChinese and '重置位置' or RESET_POSITION)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    --[[end

    if menuList then
        return
    end]]

    elseif menuList=='OPTIONS' then

        info={
            text= '|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..(e.onlyChinese and '镇民' or TOWNSFOLK_TRACKING_TEXT),
            checked= C_CVar.GetCVarBool("minimapTrackingShowAll"),
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '显示: 追踪' or SHOW..': '..TRACKING,
            tooltipText= id..' '..addName..'|n|nCVar minimapTrackingShowAll',
            keepShownOnClick=true,
            func= function()
                C_CVar.SetCVar('minimapTrackingShowAll', not C_CVar.GetCVarBool("minimapTrackingShowAll") and '1' or '0' )
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        --e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= '|A:UI-HUD-Minimap-Zoom-Out:0:0|a'..(e.onlyChinese and '缩小地图' or BINDING_NAME_MINIMAPZOOMOUT),
            checked= Save.ZoomOut,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '更新地区时' or UPDATE..ZONE,
            tooltipText= id..' '..Initializer:GetName(),
            keepShownOnClick=true,
            func= function()
                Save.ZoomOut= not Save.ZoomOut and true or nil
                set_ZoomOut()--更新地区时,缩小化地图
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text= '|A:common-icon-zoomin:0:0|a'..(e.onlyChinese and '信息' or INFO),--当前缩放，显示数值
            checked= Save.ZoomOutInfo,
            tooltipOnButton=true,
            tooltipTitle=(e.onlyChinese and '镜头视野范围' or CAMERA_FOV)..': '..format(e.onlyChinese and '%s码' or IN_GAME_NAVIGATION_RANGE, format('%i', C_Minimap.GetViewRadius() or 100)),
            keepShownOnClick=true,
            func= function()
                Save.ZoomOutInfo= not Save.ZoomOutInfo and true or nil
                set_Event_MINIMAP_UPDATE_ZOOM()
                if Save.ZoomOutInfo then
                    set_MINIMAP_UPDATE_ZOOM()
                end
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        local tab={
            DifficultyUtil.ID.Raid40,
            DifficultyUtil.ID.RaidLFR,
            DifficultyUtil.ID.DungeonNormal,
            DifficultyUtil.ID.DungeonHeroic,
            DifficultyUtil.ID.DungeonMythic,
            DifficultyUtil.ID.DungeonChallenge,
            DifficultyUtil.ID.RaidTimewalker,
            25,
            205,
        }
        local tips=''
        for _, ID in pairs(tab) do
            local text= e.GetDifficultyColor(nil, ID)
            tips= tips..'|n'..text
        end

        info={
            text= '|A:DungeonSkull:0:0|a'..(e.onlyChinese and '地下城难度' or DUNGEON_DIFFICULTY),
            tooltipOnButton= true,
            tooltipTitle= e.onlyChinese and '颜色' or COLOR,
            tooltipText= tips,
            checked= not Save.disabledInstanceDifficulty,
            keepShownOnClick=true,
            func= function()
                Save.disabledInstanceDifficulty= not Save.disabledInstanceDifficulty and true or nil
                print(id, Initializer:GetName(), e.GetEnabeleDisable(not Save.disabledInstanceDifficulty), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text= '|A:dragonflight-landingbutton-up:0:0|a'..(e.onlyChinese and '要塞图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, GARRISON_LOCATION_TOOLTIP, EMBLEM_SYMBOL)),
            tooltipOnButton= true,
            tooltipTitle= e.GetShowHide(nil, true),
            checked= not Save.hideExpansionLandingPageMinimapButton,
            colorCode= not ExpansionLandingPageMinimapButton and '|cff606060' or nil,
            keepShownOnClick=true,
            func= function()
                Save.hideExpansionLandingPageMinimapButton= not Save.hideExpansionLandingPageMinimapButton and true or nil
                if ExpansionLandingPageMinimapButton then
                    if Save.hideExpansionLandingPageMinimapButton then
                        ExpansionLandingPageMinimapButton:SetShown(false)
                    else
                        ExpansionLandingPageMinimapButton.mode=nil
                        ExpansionLandingPageMinimapButton:RefreshButton()
                    end
                end
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        if C_MythicPlus.GetCurrentSeason()==11 then
            info={
                text= '|A:WarlockPortalAlliance:0:0|a'..(e.onlyChinese and '挑战传送门标签' or 'M+ Portal Room Labels'),
                tooltipOnButton=true,
                checked= not Save.hideMPortalRoomLabels,
                keepShownOnClick=true,
                func= function()
                    Save.hideMPortalRoomLabels= not Save.hideMPortalRoomLabels and true or nil
                    Init_M_Portal_Room_Labels()
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        info={
            text= '|A:characterupdate_clock-icon:0:0|a'..(e.onlyChinese and '时钟' or TIMEMANAGER_TITLE)..' Plus',
            checked= not Save.disabledClockPlus,
            keepShownOnClick=true,
            hasArrow=true,
            menuList='ResetTimeManagerClockButton',
            func= function()
                Save.disabledClockPlus= not Save.disabledClockPlus and true or nil
                print(id, Initializer:GetName(), '|cnGREEN_FONT_COLOR:' , e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text='|A:newplayertutorial-drag-cursor:0:0|a'..(e.onlyChinese and '显示菜单' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, HUD_EDIT_MODE_MICRO_MENU_LABEL)),
            checked= Save.moving_over_Icon_show_menu,
            keepShownOnClick=true,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '移过图标时，显示菜单' or 'Show menu when moving over icon',
            tooltipText= e.onlyChinese and '不在战斗中' or 'Leaving Combat',
            func= function()
                Save.moving_over_Icon_show_menu= not Save.moving_over_Icon_show_menu and true or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif menuList=='FACTION' then--派系声望
        local major= Get_Major_Faction_List()
        for i=2, #major do
            info= Set_Faction_Menu(major[i])
            if info then
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end
        local covenantID= C_Covenants.GetActiveCovenantID() or 0
        local data = C_Covenants.GetCovenantData(covenantID) or {}
        if data then--and C_CovenantSanctumUI.HasMaximumRenown(covenantID) then
            local tabs= C_CovenantSanctumUI.GetRenownLevels(covenantID) or {}
            e.LibDD:UIDropDownMenu_AddSeparator(level)
            info={
                text= format('|A:SanctumUpgrades-%s-32x32:0:0|a%s %d/%d', data.textureKit or '', e.cn(data.name) or (e.onlyChinese and '盟约圣所' or GARRISON_TYPE_9_0_LANDING_PAGE_TITLE), C_CovenantSanctumUI.GetRenownLevel() or 1, #tabs),
                checked= CovenantRenownFrame and CovenantRenownFrame:IsShown(),
                keepShownOnClick=true,
                disabled= covenantID==0,
                func= function()
                    ToggleCovenantRenown()
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
    end

    if menuList then
        return
    end

    Init_Garrison_Menu(level)--要塞报告


    e.LibDD:UIDropDownMenu_AddButton({--Blizzard_DragonflightLandingPage.lua
        text= format('|A:dragonriding-barbershop-icon-protodrake:0:0|a%s', e.onlyChinese and '驭龙术' or GENERIC_TRAIT_FRAME_DRAGONRIDING_TITLE),
        checked= GenericTraitFrame and GenericTraitFrame:IsShown(),
        keepShownOnClick=true,
        colorCode= (select(4, GetAchievementInfo(68798)) or select(4, GetAchievementInfo(15794))) and '' or '|cff606060',
        func= function()
            GenericTraitUI_LoadUI();
            local DRAGONRIDING_TRAIT_SYSTEM_ID = 1;
            GenericTraitFrame:SetSystemID(DRAGONRIDING_TRAIT_SYSTEM_ID);
            ToggleFrame(GenericTraitFrame);
        end
    }, level)

    --派系声望
    local major= Get_Major_Faction_List()
    for _, factionID in pairs(major) do
        info= Set_Faction_Menu(factionID)
        if info then
            --e.LibDD:UIDropDownMenu_AddSeparator(level)
            if #major>1 then
                info.hasArrow= true
            end
            info.keepShownOnClick=true
            info.menuList='FACTION'
            e.LibDD:UIDropDownMenu_AddButton(info, level)
            break
        end
    end


    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= '|A:VignetteKillElite:0:0|a'..(e.onlyChinese and '追踪' or TRACKING),
        tooltipOnButton=true,
        tooltipTitle=e.onlyChinese and '地图' or WORLD_MAP,
        tooltipText='|nAreaPoiID|nWorldQuest|nVignette',
        checked= Save.vigentteButton,
        disabled= IsInInstance() or UnitAffectingCombat('player'),
        menuList= 'panelButtonRestPoint',
        hasArrow= true,
        keepShownOnClick=true,
        func= function ()
            Save.vigentteButton= not Save.vigentteButton and true or nil
            Init_Set_Button()--小地图, 标记, 文本
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info= {
        text= '    |A:mechagon-projects:0:0|a'..(e.onlyChinese and '选项' or OPTIONS),
        notCheckable=true,
        keepShownOnClick=true,
        menuList='OPTIONS',
        hasArrow=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end



























local function click_Func(self, d)
    local key= IsModifierKeyDown()
    if IsAltKeyDown() and self and type(self)=='table' then
        if not self.menu then
            self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
            e.LibDD:UIDropDownMenu_Initialize(self.Menu, Init_Menu, 'MENU')
        end
        e.LibDD:ToggleDropDownMenu(1, nil,self.Menu, self, 15,0)

    elseif IsShiftKeyDown() then
        WeeklyRewards_LoadUI()
        --[[if not C_AddOns.IsAddOnLoaded("Blizzard_WeeklyRewards") then--周奖励面板
            C_AddOns.LoadAddOn("Blizzard_WeeklyRewards")
        end]]
        WeeklyRewards_ShowUI()--WeeklyReward.lua

    elseif d=='LeftButton' and not key then
            local expButton=ExpansionLandingPageMinimapButton
            if expButton and expButton.ToggleLandingPage and expButton.title then
                expButton:ToggleLandingPage()--Minimap.lua
            else
                e.OpenPanelOpting(Initializer:GetName())
                --Settings.OpenToCategory(id)
                --e.call(InterfaceOptionsFrame_OpenToCategory, id)
            end

    elseif d=='RightButton' and not key then
        if SettingsPanel:IsShown() then
            e.OpenPanelOpting(Initializer:GetName())
        else
            e.OpenPanelOpting()
        end
    end
end



local function enter_Func(self)
    local expButton=ExpansionLandingPageMinimapButton
    if expButton and expButton.OnEnter and expButton.title then--Minimap.lua
        expButton:OnEnter()
        e.tips:AddLine(' ')
    else
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
    end

    e.tips:AddDoubleLine(e.onlyChinese and '选项' or SETTINGS_TITLE , e.Icon.right)

    if self and type(self)=='table' then
        if _G['LibDBIcon10_WoWTools'] and _G['LibDBIcon10_WoWTools']:IsMouseWheelEnabled() then
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.mid)
        else
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, 'Alt'..e.Icon.right)
        end
    end
    e.tips:AddDoubleLine(e.onlyChinese and '宏伟宝库' or RATED_PVP_WEEKLY_VAULT , 'Shift'..e.Icon.left)

    e.tips:AddLine(' ')
    e.tips:AddDoubleLine(id, Initializer:GetName())
    e.tips:Show()
end



















--####################
--添加，游戏，自带，菜单
--###################
WowTools_OnAddonCompartmentClick= click_Func
WowTools_OnAddonCompartmentFuncOnEnter= enter_Func
























--##############
--副本，难图，指示
--##############
local function Init_InstanceDifficulty()--副本，难图，指示
    local btn= MinimapCluster.InstanceDifficulty
    if Save.disabledInstanceDifficulty then
        return
    end

    --btn.Instance.Border:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)
    --btn.Guild.Border:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)
    --btn.ChallengeMode.Border:SetVertexColor(e.Player.r, e.Player.g, e.Player.b, 1)
    e.Set_Label_Texture_Color(btn.Instance.Border, {type='Texture'})
    e.Set_Label_Texture_Color(btn.Guild.Border, {type='Texture'})
    e.Set_Label_Texture_Color(btn.ChallengeMode.Border, {type='Texture'})

    e.Cstr(nil,{size=14, copyFont=btn.Instance.Text, changeFont= btn.Instance.Text})--字体，大小
    btn.Instance.Text:SetShadowOffset(1,-1)
    e.Cstr(nil,{size=14, copyFont=btn.Guild.Instance.Text, changeFont= btn.Instance.Text})--字体，大小
    btn.Guild.Instance.Text:SetShadowOffset(1,-1)


    --MinimapCluster:HookScript('OnEvent', function(self)--Minimap.luab
    hooksecurefunc(btn, 'Update', function(self)--InstanceDifficulty.lua
        local isChallengeMode= self.ChallengeMode:IsShown()
        local tips, color, name
        local frame
        if self.Guild:IsShown() then
            frame = self.Guild
        elseif isChallengeMode then
            frame = self.ChallengeMode
        elseif self.Instance:IsShown() then
            frame = self.Instance
        end
        local difficultyID
        if isChallengeMode then--挑战
            tips, color, name= e.GetDifficultyColor(nil, DifficultyUtil.ID.DungeonChallenge)
        elseif IsInInstance() then
            difficultyID = select(3, GetInstanceInfo())
            tips, color, name= e.GetDifficultyColor(nil, difficultyID)
        end
        if frame and color then
            frame.Background:SetVertexColor(color.r, color.g, color.b)
        end
        if not self.labelType then
            self.labelType= e.Cstr(self, {color=true, level=22, alpha=0.5})
            self.labelType:SetPoint('TOP', self, 'BOTTOM', 0, 4)
        end
        self.labelType:SetText(name and e.WA_Utf8Sub(name, 2, 6) or '')
        self.tips= tips
    end)

    btn:HookScript('OnEnter', function(self)
        if not IsInInstance() then
            return
        end
        e.tips:SetOwner(MinimapCluster, "ANCHOR_LEFT")
        e.tips:ClearLines()
        local difficultyID, name, maxPlayers= select(3,GetInstanceInfo())
        name= name..(maxPlayers and ' ('..maxPlayers..')' or '')
        e.tips:AddDoubleLine(self.tips, name)
        e.tips:AddLine(' ')
        local tab={
            DifficultyUtil.ID.Raid40,
            DifficultyUtil.ID.RaidLFR,
            DifficultyUtil.ID.DungeonNormal,
            DifficultyUtil.ID.DungeonHeroic,
            DifficultyUtil.ID.DungeonMythic,
            DifficultyUtil.ID.DungeonChallenge,
            DifficultyUtil.ID.RaidTimewalker,
            25,
            205,--Seguace (5)LFG_TYPE_FOLLOWER_DUNGEON = "追随者地下城"
        }
        for _, ID in pairs(tab) do
            local text= e.GetDifficultyColor(nil, ID)
            e.tips:AddLine((self.tips==text and e.Icon.toRight2 or '')..text..(self.tips==text and e.Icon.toLeft2 or ''))
        end
        e.tips:AddDoubleLine('difficultyID', difficultyID)
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:Show()
        if self.labelType then
            self.labelType:SetAlpha(1)
        end
    end)
    btn:HookScript('OnLeave', function(self)
        if self.labelType then
            self.labelType:SetAlpha(0.5)
        end
        e.tips:Hide()
    end)
end















--时间 Pluse
--Blizzard_TimeManager.lua
local function Blizzard_TimeManager()
    if Save.disabledClockPlus then
        return
    end

    --时钟，设置位置
    function TimeManagerClockButton:set_point()
        if Save.TimeManagerClockButtonPoint then
            TimeManagerClockTicker:SetPoint('LEFT')
            TimeManagerClockButton:SetWidth(TimeManagerClockButton:GetWidth()+5)
            TimeManagerClockButton:SetParent(UIParent)
            TimeManagerClockButton:ClearAllPoints()
            TimeManagerClockButton:SetPoint(Save.TimeManagerClockButtonPoint[1], UIParent, Save.TimeManagerClockButtonPoint[3], Save.TimeManagerClockButtonPoint[4], Save.TimeManagerClockButtonPoint[5])
        end
    end
    --时钟，缩放
    TimeManagerClockButton:EnableMouseWheel(true)
    function TimeManagerClockButton:set_scale()
        self:SetScale(Save.TimeManagerClockButtonScale or 1)
    end
    TimeManagerClockButton:HookScript('OnMouseWheel', function(self, d)
        local n= Save.TimeManagerClockButtonScale or 1
        if d==1 then
            n= n-0.05
        elseif d==-1 then
            n= n+0.05
        end
        n= n>4 and 4 or n
        n= n<0.4 and 0.4 or n
        Save.TimeManagerClockButtonScale= n
        self:set_scale()
        print(id, Initializer:GetName(), '|cnGREEN_FONT_COLOR:', n)
    end)
    --时钟，移动
    TimeManagerClockButton:SetMovable(true)
    TimeManagerClockButton:SetClampedToScreen(true)
    TimeManagerClockButton:RegisterForDrag('RightButton')
    TimeManagerClockButton:HookScript('OnMouseDown', function(_, d)
        if d=='RightButton' then
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    TimeManagerClockButton:SetScript('OnMouseUp', ResetCursor)
    TimeManagerClockButton:HookScript("OnDragStart", TimeManagerClockButton.StartMoving)
    TimeManagerClockButton:HookScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save.TimeManagerClockButtonPoint={self:GetPoint(1)}
        Save.TimeManagerClockButtonPoint[2]=nil
    end)
    --透明度
    TimeManagerClockButton:HookScript('OnLeave', function(self) self:SetAlpha(1) end)
    TimeManagerClockButton:HookScript('OnEnter', function(self)
        self:SetAlpha(0.5)
        e.call('TimeManagerClockButton_UpdateTooltip')
    end)

    --设置，时间，颜色
    TimeManagerClockTicker:SetShadowOffset(1, -1)
    e.Set_Label_Texture_Color(TimeManagerClockTicker, {type='FontString', alpha=1})--设置颜色

    TimeManagerClockButton:set_scale()
    TimeManagerClockButton:set_point()

    --小时图，使用服务器, 时间
    local TimeManagerClockButton_Update_R= TimeManagerClockButton_Update
    local function set_Server_Timer()--小时图，使用服务器, 时间
        if Save.useServerTimer then
            TimeManagerClockButton_Update=function()
                TimeManagerClockTicker:SetText(e.SecondsToClock(GetServerTime(), true) or '')
            end
        else
            TimeManagerClockButton_Update= TimeManagerClockButton_Update_R
        end
    end
    if Save.useServerTimer then
        set_Server_Timer()
    end
    local check= CreateFrame("CheckButton", nil, TimeManagerFrame, "UICheckButtonTemplate")
    check:SetSize(24,24)
    check:SetPoint('BOTTOMRIGHT', TimeManagerMilitaryTimeCheck, 'TOPRIGHT',0,-4)
    check.Text:ClearAllPoints()
    check.Text:SetPoint('RIGHT', check, 'LEFT', -2, 0)
    check.Text:SetFontObject(GameFontHighlightSmall)

    check.Text:SetText(e.onlyChinese and '服务器时间' or TIMEMANAGER_TOOLTIP_REALMTIME)
    check:SetChecked(Save.useServerTimer)
    check:SetScript('OnClick', function()
        Save.useServerTimer= not Save.useServerTimer and true or nil
        set_Server_Timer()
    end)
    check:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine((e.onlyChinese and '时钟' or TIMEMANAGER_TITLE)..' Plus')
        e.tips:Show()
    end)
    check:SetScript('OnLeave', GameTooltip_Hide)
    --提示
    hooksecurefunc('TimeManagerClockButton_UpdateTooltip', function()
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine('|cffffffff'..(e.onlyChinese and '服务器时间' or TIMEMANAGER_TOOLTIP_REALMTIME), '|cnGREEN_FONT_COLOR:'..e.SecondsToClock(GetServerTime())..e.Icon.left)
        e.tips:AddDoubleLine('|cffffffff'..(e.onlyChinese and '移动' or NPE_MOVE), e.Icon.right)
        e.tips:AddDoubleLine('|cffffffff'..((e.onlyChinese and '缩放' or UI_SCALE)), '|cnGREEN_FONT_COLOR:'..(Save.TimeManagerClockButtonScale or 1)..e.Icon.mid)
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:Show()
    end)




    --秒表
    --####
    StopwatchCloseButton:ClearAllPoints()
    StopwatchCloseButton:SetPoint('TOPLEFT')
    StopwatchTitle:SetText(e.onlyChinese and '秒表' or STOPWATCH_TITLE)
    StopwatchTitle:SetPoint('LEFT', StopwatchCloseButton, 'RIGHT')

    --隐藏，开始/暂停，按钮
    StopwatchPlayPauseButton:Hide()

    --移动
    StopwatchFrame:RegisterForDrag("LeftButton", 'RightButton')
    StopwatchFrame:HookScript('OnMouseDown', function()
        SetCursor('UI_MOVE_CURSOR')
    end)
    StopwatchFrame:HookScript('OnMouseUp', ResetCursor)
    StopwatchFrame:HookScript('OnLeave', GameTooltip_Hide)
    function StopwatchFrame:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.StopwatchFrameScale or 1), e.Icon.mid)
        e.tips:AddDoubleLine(e.onlyChinese and '开始/暂停' or NEWBIE_TOOLTIP_STOPWATCH_PLAYPAUSEBUTTON, '|A:newplayertutorial-drag-cursor:0:0|a'..(e.onlyChinese and '移过' or 'Move over'))
        e.tips:Show()
    end
    StopwatchFrame:HookScript('OnEnter', function(self)
        StopwatchPlayPauseButton_OnClick(StopwatchPlayPauseButton)--开始/暂停
        self:set_tooltips()
    end)

    --缩放
    StopwatchFrame:EnableMouseWheel(true)
    function StopwatchFrame:set_scale()
        self:SetScale(Save.StopwatchFrameScale or 1)
    end
    StopwatchFrame:SetScript('OnMouseWheel', function(self, d)
        local n= Save.StopwatchFrameScale or 1
        if d==1 then
            n= n-0.05
        elseif d==-1 then
            n= n+0.05
        end
        n= n>4 and 4 or n
        n= n<0.4 and 0.4 or n
        Save.StopwatchFrameScale= n
        self:set_scale()
        self:set_tooltips()
        print(id, Initializer:GetName(), '|cnGREEN_FONT_COLOR:', n)
    end)
    StopwatchFrame:set_scale()

    StopwatchTickerHour:SetTextColor(0,1,0,1)
    StopwatchTickerMinute:SetTextColor(0,1,0,1)
    StopwatchTickerSecond:SetTextColor(0,1,0,1)
    StopwatchTickerHour:SetShadowOffset(1, -1)
    StopwatchTickerMinute:SetShadowOffset(1, -1)
    StopwatchTickerSecond:SetShadowOffset(1, -1)

    hooksecurefunc('StopwatchPlayPauseButton_OnClick', function()
        if StopwatchPlayPauseButton.playing then
            e.Set_Label_Texture_Color(StopwatchTickerHour, {type='FontString'})
            e.Set_Label_Texture_Color(StopwatchTickerMinute, {type='FontString'})
            e.Set_Label_Texture_Color(StopwatchTickerSecond, {type='FontString'})
        else
            StopwatchTickerHour:SetTextColor(0,1,0,1)
            StopwatchTickerMinute:SetTextColor(0,1,0,1)
            StopwatchTickerSecond:SetTextColor(0,1,0,1)
        end
    end)
    --加载游戏时，显示秒表
    StopwatchFrame:HookScript('OnShow', function()
        Save.showStopwatchFrame=true
    end)
    StopwatchCloseButton:HookScript('OnClick', function()

        Save.showStopwatchFrame=nil
    end)
    if Save.showStopwatchFrame and not StopwatchFrame:IsShown() then
        Stopwatch_Toggle()
    end
    C_Timer.After(2.5, function()
        --设置，重置，按钮
        if not StopwatchFrameBackgroundLeft:IsShown() then
            StopwatchResetButton:ClearAllPoints()
            StopwatchResetButton:SetPoint('RIGHT', StopwatchTickerHour, 'LEFT', -2,0)
            StopwatchResetButton:SetAlpha(0.2)
            StopwatchResetButton:HookScript('OnLeave', function(self) self:SetAlpha(0.2) end)
            StopwatchResetButton:HookScript('OnEnter', function(self) self:SetAlpha(1) end)
        end
    end)
end













--####
--初始
--####
local function Init()
    Init_InstanceDifficulty()--副本，难图，指示
    C_Timer.After(2, Init_Set_Button)--小地图, 标记, 文本
    Init_M_Portal_Room_Labels()--挑战专送门标签



    --图标
    local libDataBroker = LibStub:GetLibrary("LibDataBroker-1.1", true)
    local libDBIcon = LibStub("LibDBIcon-1.0", true)
    if libDataBroker and libDBIcon then
        local Set_MinMap_Icon= function(tab)-- {name, texture, func, hide} 小地图，建立一个图标 Hide("MyLDB") icon:Show("")
            local bunnyLDB = libDataBroker:NewDataObject(tab.name, {
                OnClick=tab.func,--fun(displayFrame: Frame, buttonName: string)
                OnEnter=tab.enter,--fun(displayFrame: Frame)
                OnLeave=nil,--fun(displayFrame: Frame)
                OnTooltipShow=nil,--fun(tooltip: Frame)
                icon=tab.texture,--string
                iconB=nil,--number,
                iconCoords=nil,--table,
                iconG=nil,--number,
                iconR=nil,--number,
                label=nil,--string,
                suffix=nil,--string,
                text=tab.name,-- string,
                tocname=nil,--string,
                tooltip=nil,--Frame,
                type='data source',-- "data source"|"launcher",
                value=nil,--string,
            })

            libDBIcon:Register(tab.name, bunnyLDB, Save.miniMapPoint)
            return libDBIcon
        end
        Save.miniMapPoint= Save.miniMapPoint or {}

        Set_MinMap_Icon({name= id, texture= [[Interface\AddOns\WoWTools\Sesource\Texture\WoWtools.tga]],--texture= -18,--136235,
            func= click_Func,
            enter= function(self)
                if Save.moving_over_Icon_show_menu and not UnitAffectingCombat('player') then
                    if not self.menu then
                        self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                        e.LibDD:UIDropDownMenu_Initialize(self.Menu, Init_Menu, 'MENU')
                    end
                    e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)
                end
                enter_Func(self)
            end,
        })
        local btn= _G['LibDBIcon10_WoWTools']
        if btn then
            btn:EnableMouseWheel(true)
            btn:SetScript('OnMouseWheel', function(self, d)
                if not self.menu then
                    self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                    e.LibDD:UIDropDownMenu_Initialize(self.Menu, Init_Menu, 'MENU')
                end
                e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)
            end)
        end



        if ExpansionLandingPageMinimapButton then
            if Save.hideExpansionLandingPageMinimapButton then
                ExpansionLandingPageMinimapButton:SetShown(false)
            end
            ExpansionLandingPageMinimapButton:HookScript('OnShow', function(self)
                if Save.hideExpansionLandingPageMinimapButton then
                   self:SetShown(false)
                end
            end)
        end
    end


end
--[[
    panel.Texture= UIParent:CreateTexture()
    panel.Texture:SetTexture("Interface\\Minimap\\POIIcons")
    panel.Texture:SetPoint('CENTER')
    panel.Texture:SetSize(16,16)


local ATLAS_WITH_TEXTURE_KIT_PREFIX = "%s-%s"
hooksecurefunc(MinimapMixin , 'SetTexture', function(poiInfo)
    print(poiInfo.atlasName, poiInfo.textureIndex)
    local atlasName = poiInfo.atlasName
	if atlasName then
		if poiInfo.textureKit then
			atlasName = ATLAS_WITH_TEXTURE_KIT_PREFIX:format(poiInfo.textureKit, atlasName)
		end
        local sizeX, sizeY = panel.Texture:GetSize()
		panel.Texture:SetAtlas(atlasName, true)
		panel:SetSize(sizeX, sizeY)

		panel.Texture:SetTexCoord(0, 1, 0, 1)
	else
		
		panel.Texture:SetWidth(16)
		panel.Texture:SetHeight(16)
		panel.Texture:SetTexture("Interface/Minimap/POIIcons")
	

		local x1, x2, y1, y2 = C_Minimap.GetPOITextureCoords(poiInfo.textureIndex)
		panel.Texture:SetTexCoord(x1, x2, y1, y2)
		
	end
    print('SetTexture')
end)]]













--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            Save.vigentteButtonTextScale= Save.vigentteButtonTextScale or 1
            Save.uiMapIDs= Save.uiMapIDs or {}
            Save.questIDs= Save.questIDs or {}
            Save.areaPoiIDs= Save.areaPoiIDs or {}

            addName2= '|A:VignetteKillElite:0:0|a'..(e.onlyChinese and '追踪' or TRACKING)

            --添加控制面板
            Initializer= e.AddPanel_Check({
                name= '|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..(e.onlyChinese and '小地图' or addName),
                tooltip= e.cn(addName),
                value= not Save.disabled,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(Initializer:GetName(), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if not Save.disabled then
                panel:RegisterEvent("ZONE_CHANGED_NEW_AREA")
                panel:RegisterEvent('ZONE_CHANGED')
                panel:RegisterEvent("PLAYER_ENTERING_WORLD")
                if Save.ZoomOutInfo then
                    set_Event_MINIMAP_UPDATE_ZOOM()--当前缩放，显示数值
                end
                Init()
            else
                panel:UnregisterAllEvents()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_TimeManager' then
            Blizzard_TimeManager()--秒表
        --elseif arg1=='Blizzard_ExpansionLandingPage' then

        elseif arg1=='Blizzard_MajorFactions' then
            Init_MajorFactionRenownFrame()

        elseif arg1=='Blizzard_CovenantRenown' then
            Init_Blizzard_CovenantRenown()

        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='PLAYER_ENTERING_WORLD' or event=='ZONE_CHANGED_NEW_AREA' or event=='ZONE_CHANGED' then
        set_ZoomOut()--更新地区时,缩小化地图

    elseif event=='MINIMAP_UPDATE_ZOOM' then--当前缩放，显示数值 Minimap.lua
        set_MINIMAP_UPDATE_ZOOM()
    end
end)