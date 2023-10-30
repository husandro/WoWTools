local id, e = ...
local addName= HUD_EDIT_MODE_MINIMAP_LABEL
local addName2
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
        useServerTimer=true,--小时图，使用服务器, 时间
       --disabledInstanceDifficulty=true,--副本，难图，指示


}

for questID, _ in pairs(Save.questIDs or {}) do
    e.LoadDate({id= questID, type=='quest'})
end

local panel= CreateFrame("Frame")
local Button




--[[if e.Player.husandro then
    hooksecurefunc(BaseMapPoiPinMixin, 'SetTexture', function(poiInfo)
        print(id,addName)
    end)
end]]








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

--[[local barColorFromTintValue = {
	[Enum.StatusBarColorTintValue.Black] = BLACK_FONT_COLOR,
	[Enum.StatusBarColorTintValue.White] = WHITE_FONT_COLOR,
	[Enum.StatusBarColorTintValue.Red] = RED_FONT_COLOR,
	[Enum.StatusBarColorTintValue.Yellow] = YELLOW_FONT_COLOR,
	[Enum.StatusBarColorTintValue.Orange] = ORANGE_FONT_COLOR,
	[Enum.StatusBarColorTintValue.Purple] = EPIC_PURPLE_COLOR,
	[Enum.StatusBarColorTintValue.Green] = GREEN_FONT_COLOR,
	[Enum.StatusBarColorTintValue.Blue] = RARE_BLUE_COLOR,
}]]
local function get_AreaPOIInfo_Name(poiInfo)
    return (poiInfo.atlasName and '|A:'..poiInfo.atlasName..':0:0|a' or '')..(poiInfo.name or '')
end















--任务奖励
--QuestUtils_AddQuestRewardsToTooltip(tooltip, questID, style)
local function Get_QuestReward_Texture(questID)
    local itemTexture, bestQuality

    local numQuestChoices = GetNumQuestLogChoices(questID)--可选任务，奖励
    if numQuestChoices>0 then
        bestQuality= -1
        for i = 1, numQuestChoices do
            local _, texture, _, quality= GetQuestLogChoiceInfo(i, questID);
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
            local _, texture, _, quality= GetQuestLogRewardInfo(i, questID);
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
                text= questName
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
                        barText= FormatFraction(info.barValue - info.barMin, info.barMax - info.barMin);

                    elseif info.barValueTextType == Enum.StatusBarValueTextType.Percentage then--1
                        local barPercent = PercentageBetween(info.barValue, info.barMin, info.barMax);
                        barText= FormatPercentage(barPercent, true);

                    elseif info.barValueTextType == Enum.StatusBarValueTextType.Time then
                        barText = SecondsToTime(info.barValue, false, true, nil, true);
                    end
                end
                barText= barText and '|cffffffff'..barText..'|r ' or ''

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
            local name= poiInfo.name
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
                local name= info.name
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
            local verticalPadding = nil;
            local waitingForData, titleAdded = false, false;

            if vignetteInfo.type == Enum.VignetteType.Normal or vignetteInfo.type == Enum.VignetteType.Treasure then
                GameTooltip_SetTitle(GameTooltip, vignetteInfo.name);
                titleAdded = true

            elseif vignetteInfo.type == Enum.VignetteType.PvPBounty then
                local player = PlayerLocation:CreateFromGUID(vignetteInfo.objectGUID)
                local class = select(3, C_PlayerInfo.GetClass(player));
                local race = C_PlayerInfo.GetRace(player);
                local name = C_PlayerInfo.GetName(player);
                if race and class and name then
                    local classInfo = C_CreatureInfo.GetClassInfo(class) or {};
                    local factionInfo = C_CreatureInfo.GetFactionInfo(race) or {};
                    GameTooltip_SetTitle(GameTooltip, name, GetClassColorObj(classInfo.classFile));
                    GameTooltip_AddColoredLine(GameTooltip, factionInfo.name, GetFactionColor(factionInfo.groupTag));
                    if vignetteInfo.rewardQuestID then
                        GameTooltip_AddQuestRewardsToTooltip(GameTooltip, vignetteInfo.rewardQuestID, TOOLTIP_QUEST_REWARDS_STYLE_PVP_BOUNTY);
                    end
                    titleAdded=true
                end
                waitingForData = not titleAdded;

            elseif vignetteInfo.type == Enum.VignetteType.Torghast then
                SharedTooltip_SetBackdropStyle(GameTooltip, GAME_TOOLTIP_BACKDROP_STYLE_RUNEFORGE_LEGENDARY);
                GameTooltip_SetTitle(GameTooltip, vignetteInfo.name);
                titleAdded = true
            end

            if not waitingForData and vignetteInfo.widgetSetID then
                local overflow = GameTooltip_AddWidgetSet(GameTooltip, vignetteInfo.widgetSetID, titleAdded and vignetteInfo.addPaddingAboveWidgets and 10);
                if overflow then
                    verticalPadding = -overflow;
                end
            elseif waitingForData then
                GameTooltip_SetTitle(GameTooltip, RETRIEVING_DATA);
            end
            if verticalPadding then
                GameTooltip:SetPadding(0, verticalPadding);
            end
            widgetSetID= vignetteInfo.widgetSetID
            vignetteID= vignetteInfo.vignetteID
        end

    elseif self.uiMapID and self.areaPoiID then--areaPoi AreaPOIPinMixin:TryShowTooltip()
        local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(self.uiMapID, self.areaPoiID) or {}
        local hasName = poiInfo.name ~= "";
        local hasDescription = poiInfo.description and poiInfo.description ~= "";
        local isTimed, hideTimer = C_AreaPoiInfo.IsAreaPOITimed(self.areaPoiID);
        local showTimer = isTimed and not hideTimer;
        local hasWidgetSet = poiInfo.widgetSetID ~= nil;

        local hasTooltip = hasDescription or showTimer or hasWidgetSet;
	    local addedTooltipLine = false

        if hasTooltip then
            local verticalPadding = nil;

            if hasName then
                GameTooltip_SetTitle(GameTooltip, poiInfo.name, HIGHLIGHT_FONT_COLOR);
                addedTooltipLine = true;
            end

            if hasDescription then
                GameTooltip_AddNormalLine(GameTooltip, poiInfo.description);
                addedTooltipLine = true;
            end

            if showTimer then
                local secondsLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(self.areaPoiID);
                if secondsLeft and secondsLeft > 0 then
                    local timeString = SecondsToTime(secondsLeft);
                    GameTooltip_AddNormalLine(GameTooltip, BONUS_OBJECTIVE_TIME_LEFT:format(timeString));
                    addedTooltipLine = true;
                end
            end

            --[[if poiInfo.textureKit == "OribosGreatVault" then
                GameTooltip_AddBlankLineToTooltip(GameTooltip);
                GameTooltip_AddInstructionLine(GameTooltip, ORIBOS_GREAT_VAULT_POI_TOOLTIP_INSTRUCTIONS);
                addedTooltipLine = true;
            end]]

            if hasWidgetSet then
                local overflow = GameTooltip_AddWidgetSet(GameTooltip, poiInfo.widgetSetID, addedTooltipLine and poiInfo.addPaddingAboveWidgets and 10);
                if overflow then
                    verticalPadding = -overflow;
                end
            end

            if poiInfo.uiTextureKit then
                local backdropStyle = GAME_TOOLTIP_TEXTUREKIT_BACKDROP_STYLES[poiInfo.uiTextureKit];
                if (backdropStyle) then
                    SharedTooltip_SetBackdropStyle(GameTooltip, backdropStyle);
                end
            end
            -- need to set padding after Show or else there will be a flicker
            if verticalPadding then
                GameTooltip:SetPadding(0, verticalPadding);
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
        e.tips:AddDoubleLine('widgetSetID |cnGREEN_FONT_COLOR:'..widgetSetID, info.name)
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
    e.Chat(text, nil)
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
            btn:SetScript("OnLeave", function() e.tips:Hide() Button:SetButtonState('NORMAL') end)
            btn:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                set_OnEnter_btn_tips(self)
                e.tips:Show()
                Button:SetButtonState('PUSHED')
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
                    print(id, addName, addName2, GetQuestLink(questID) or questID,
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
                    print(id,addName, addName2,
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
                    print(id,addName, addName2,
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
                    print(id,addName, addName2,
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
                print(id, addName, e.onlyChinese and '重置位置' or RESET_POSITION)
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
        print(id, addName2,'|cffff00ff', text)
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
        self:Raise()
    end)

    
    Button:SetScript('OnClick', function(self, d)--显示，隐藏
        local key= IsModifierKeyDown()
        if d=='LeftButton' and not key then
            Save.vigentteButtonShowText= not Save.vigentteButtonShowText and true or nil
            self:set_Shown()
            self:set_Texture()

        elseif d=='RightButton' and not key then
            self:show_menu()
        end
    end)

    Button:SetScript('OnMouseUp', ResetCursor)
    Button:SetScript('OnMouseDown', function(_, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
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
        e.tips:AddDoubleLine(addName, addName2)
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
            print(id, addName, e.onlyChinese and '缩放' or UI_SCALE, scale)
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






    hooksecurefunc('TaskPOI_OnEnter', function(self2)--世界任务，提示 WorldMapFrame.lua
        if self2.questID and self2.OnMouseClickAction then
            e.tips:AddDoubleLine(addName2..(Save.questIDs[self2.questID] and e.Icon.select2 or ''), 'Alt+'..e.Icon.left)
            e.tips:Show()
        end
    end)
    hooksecurefunc(WorldQuestPinMixin, 'RefreshVisuals', function(self)--世界任务，添加/移除 WorldQuestDataProvider.lua self.tagInfo
        if not self.OnMouseClickAction or self.setTracking then
            return
        end
        hooksecurefunc(self, 'OnMouseClickAction', function(self2, d)
            if self2.questID and d=='LeftButton' and IsAltKeyDown() then
                Save.questIDs[self2.questID]= not Save.questIDs[self2.questID] and true or nil
                print(id,addName, addName2,
                    GetQuestLink(self2.questID) or self2.questID,
                    Save.questIDs[self2.questID] and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..e.Icon.select2 or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..e.Icon.X2)
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
                    print(id,addName, addName2,
                        (C_Map.GetMapInfo(uiMapID) or {}).name or ('uiMapID '..uiMapID),
                        name,
                        Save.areaPoiIDs[self.areaPoiID] and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..e.Icon.select2 or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..e.Icon.X2)
                    )
                end
            end
        end)
        self.setTracking=true
    end)

    WorldMapFrame.setTrackingButton= e.Cbtn(WorldMapFrame, {size={20,20}, icon='hide'})
    WorldMapFrame.setTrackingButton:SetPoint('TOPRIGHT', WorldMapFramePortrait, 'BOTTOMRIGHT', 2, 10)
    WorldMapFrame.setTrackingButton:Raise()
    WorldMapFrame.setTrackingButton:SetScript('OnClick', function(self)
        local frame= self:GetParent()
        local uiMapID= frame.mapID or frame:GetMapID("current")
        if uiMapID then
            Save.uiMapIDs[uiMapID]= not Save.uiMapIDs[uiMapID] and true or nil
            local name= (C_Map.GetMapInfo(uiMapID) or {}).name or ('uiMapID '..uiMapID)
            print(id,addName, addName2,
                name,
                Save.uiMapIDs[uiMapID] and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..e.Icon.select2 or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..e.Icon.X2)
            )
            frame:Set_TrackingButton_Texture()
        end
    end)
    WorldMapFrame.setTrackingButton:SetScript('OnShow', function(self)
        self:GetParent():Set_TrackingButton_Texture()
    end)
    WorldMapFrame.setTrackingButton:SetScript('OnLeave', function() e.tips:Hide() end)
    WorldMapFrame.setTrackingButton:SetScript('OnEnter', function(self)
        local frame= self:GetParent()
        local uiMapID= frame.mapID or frame:GetMapID("current")
        if uiMapID then
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(addName2..(Save.uiMapIDs[uiMapID] and e.Icon.select2 or ''), ((C_Map.GetMapInfo(uiMapID) or {}).name or '')..' '..uiMapID)
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
        end
    end)
    function WorldMapFrame:Set_TrackingButton_Texture()
        local uiMapID= self.mapID or self:GetMapID("current")
        if not uiMapID then
            self.setTrackingButton:SetNormalTexture(0)
        else
            local atlas
            if Save.uiMapIDs[uiMapID] then
                atlas= e.Icon.select
            else
                atlas='VignetteKillElite'
            end
            self.setTrackingButton:SetNormalAtlas(atlas)
        end
    end
    hooksecurefunc(WorldMapFrame, 'OnMapChanged', WorldMapFrame.Set_TrackingButton_Texture)--uiMapIDs, 添加，移除 --Blizzard_WorldMap.lua
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
        Minimap.zoomText= e.Cstr(Minimap, {color=true})
        Minimap.zoomText:SetPoint('BOTTOM', Minimap.ZoomOut, 'TOP', 3, 0)
    end
    Minimap.zoomText:SetText(zoom and level and (level-zoom)..'/'..level or '')

    if not Minimap.viewRadius then
        Minimap.viewRadius=e.Cstr(Minimap, {color=true, justifyH='CENTER'})
        Minimap.viewRadius:SetPoint('BOTTOMLEFT', Minimap, 'BOTTOM', 8, -8)
        Minimap.viewRadius:EnableMouse(true)
        Minimap.viewRadius:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.onlyChinese and '镜头视野范围' or CAMERA_FOV, format(e.onlyChinese and '%s码' or IN_GAME_NAVIGATION_RANGE, format('%i', C_Minimap.GetViewRadius() or 100)))
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
        end)
        Minimap.viewRadius:SetScript('OnLeave', function() e.tips:Hide() end)
    end
    Minimap.viewRadius:SetFormattedText('%i', C_Minimap.GetViewRadius() or 100)
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
            colorCode= not Save.pointVigentteButton and '|cff606060' or '',
            func= function()
                Save.pointVigentteButton=nil
                Button:ClearAllPoints()
                Button:Set_Point()
                print(id, addName, e.onlyChinese and '重置位置' or RESET_POSITION)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    end

    if menuList then
        return
    end

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

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= '|A:UI-HUD-Minimap-Zoom-Out:0:0|a'..(e.onlyChinese and '缩小地图' or BINDING_NAME_MINIMAPZOOMOUT),
        checked= Save.ZoomOut,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '更新地区时' or UPDATE..ZONE,
        tooltipText= id..' '..addName,
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
            print(id, addName, e.GetEnabeleDisable(not Save.disabledInstanceDifficulty), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

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
        if not IsAddOnLoaded("Blizzard_WeeklyRewards") then--周奖励面板
            LoadAddOn("Blizzard_WeeklyRewards")
        end
        WeeklyRewards_ShowUI()--WeeklyReward.lua

    elseif d=='LeftButton' and not key then
            local expButton=ExpansionLandingPageMinimapButton
            if expButton and expButton.ToggleLandingPage and expButton.title then
                expButton.ToggleLandingPage(expButton)--Minimap.lua
            else
                e.OpenPanelOpting()
                --Settings.OpenToCategory(id)
                --e.call(InterfaceOptionsFrame_OpenToCategory, id)
            end

    elseif d=='RightButton' and not key then
        e.OpenPanelOpting()
    end
end
local function enter_Func(self)
    local expButton=ExpansionLandingPageMinimapButton
    if expButton and expButton.OnEnter and expButton.title then--Minimap.lua
        expButton.OnEnter(expButton)
        e.tips:AddLine(' ')
    else
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
    end

    e.tips:AddDoubleLine(e.onlyChinese and '选项' or SETTINGS_TITLE , e.Icon.right)

    if self and type(self)=='table' then
        if expButton and expButton:IsShown() then
            expButton:SetShown(false)
        end
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, 'Alt'..e.Icon.right)
    end
    e.tips:AddDoubleLine(e.onlyChinese and '宏伟宝库' or RATED_PVP_WEEKLY_VAULT , 'Shift'..e.Icon.left)

    e.tips:AddLine(' ')
    e.tips:AddDoubleLine(id, addName)
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
    local self= MinimapCluster.InstanceDifficulty
    if Save.disabledInstanceDifficulty then
        return
    end

    self.Instance.Border:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)
    self.Guild.Border:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)
    self.ChallengeMode.Border:SetVertexColor(e.Player.r, e.Player.g, e.Player.b, 1)
    e.Cstr(nil,{size=14, copyFont=self.Instance.Text, changeFont= self.Instance.Text})--字体，大小
    self.Instance.Text:SetShadowOffset(1,-1)
    e.Cstr(nil,{size=14, copyFont=self.Guild.Instance.Text, changeFont= self.Instance.Text})--字体，大小
    self.Guild.Instance.Text:SetShadowOffset(1,-1)

    --MinimapCluster:HookScript('OnEvent', function(self2)--Minimap.luab
    hooksecurefunc(self, 'Update', function(self2)--InstanceDifficulty.lua
        local isChallengeMode= self.ChallengeMode:IsShown()
        local tips, color
        local frame
        if self.Guild:IsShown() then
            frame = self.Guild
        elseif isChallengeMode then
            frame = self.ChallengeMode
        elseif self.Instance:IsShown() then
            frame = self.Instance
        end

        if isChallengeMode then--挑战
            tips, color= e.GetDifficultyColor(nil, DifficultyUtil.ID.DungeonChallenge)
        elseif IsInInstance() then
            local difficultyID = select(3, GetInstanceInfo())
            tips, color= e.GetDifficultyColor(nil, difficultyID)
        end
        if frame and color then
            frame.Background:SetVertexColor(color.r, color.g, color.b)
        end

        self2.tips= tips
    end)
    self:HookScript('OnEnter', function(self2)
        if not IsInInstance() then
            return
        end
        e.tips:SetOwner(MinimapCluster, "ANCHOR_LEFT")
        e.tips:ClearLines()
        local difficultyID, name, maxPlayers= select(3,GetInstanceInfo())
        name= name..(maxPlayers and ' ('..maxPlayers..')' or '')
        e.tips:AddDoubleLine(self2.tips, name)
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
        }
        for _, ID in pairs(tab) do
            local text= e.GetDifficultyColor(nil, ID)
            e.tips:AddLine((self2.tips==text and e.Icon.toRight2 or '')..text..(self2.tips==text and e.Icon.toLeft2 or ''))
        end
        e.tips:AddDoubleLine('difficultyID', difficultyID)
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
    end)
    self:HookScript('OnLeave', function()
        e.tips:Hide()
    end)
end








--####
--初始
--####
local function Init()
    Init_InstanceDifficulty()--副本，难图，指示

    Init_Set_Button()--小地图, 标记, 文本

    --########
    --盟约图标
    --########
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
            enter= enter_Func,
        })

        if ExpansionLandingPageMinimapButton then
            ExpansionLandingPageMinimapButton:SetShown(false)
            ExpansionLandingPageMinimapButton:HookScript('OnShow', function(self2)
                self2:SetShown(false)
            end)
        end
    end
end
--[[
    panel.Texture= UIParent:CreateTexture()
    panel.Texture:SetTexture("Interface\\Minimap\\POIIcons")
    panel.Texture:SetPoint('CENTER')
    panel.Texture:SetSize(16,16)


local ATLAS_WITH_TEXTURE_KIT_PREFIX = "%s-%s";
hooksecurefunc(MinimapMixin , 'SetTexture', function(poiInfo)
    print(poiInfo.atlasName, poiInfo.textureIndex)
    local atlasName = poiInfo.atlasName;
	if atlasName then
		if poiInfo.textureKit then
			atlasName = ATLAS_WITH_TEXTURE_KIT_PREFIX:format(poiInfo.textureKit, atlasName);
		end
        local sizeX, sizeY = panel.Texture:GetSize();
		panel.Texture:SetAtlas(atlasName, true);
		panel:SetSize(sizeX, sizeY);

		panel.Texture:SetTexCoord(0, 1, 0, 1);
	else
		
		panel.Texture:SetWidth(16);
		panel.Texture:SetHeight(16);
		panel.Texture:SetTexture("Interface/Minimap/POIIcons");
	

		local x1, x2, y1, y2 = C_Minimap.GetPOITextureCoords(poiInfo.textureIndex);
		panel.Texture:SetTexCoord(x1, x2, y1, y2);
		
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
            e.AddPanel_Check({
                name= '|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..(e.onlyChinese and '小地图' or addName),
                tooltip= addName,
                value= not Save.disabled,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
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
            local TimeManagerClockButton_Update_R= TimeManagerClockButton_Update--小时图，使用服务器, 时间
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
            local check= CreateFrame("CheckButton", nil, TimeManagerFrame, "InterfaceOptionsCheckButtonTemplate")
            check:SetPoint('TOPLEFT', TimeManagerFrame, 'BOTTOMLEFT')
            check.Text:SetText(e.onlyChinese and '服务器时间' or TIMEMANAGER_TOOLTIP_REALMTIME)
            check:SetChecked(Save.useServerTimer)
            check:SetScript('OnClick', function()
                Save.useServerTimer= not Save.useServerTimer and true or nil
                set_Server_Timer()
            end)
            check:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT");
                e.tips:ClearLines();
                e.tips:AddDoubleLine(e.onlyChinese and '时间信息' or TIMEMANAGER_TOOLTIP_TITLE, e.onlyChinese and '使用' or USE)
                e.tips:AddDoubleLine(id, addName)
                e.tips:Show()
            end)
            check:SetScript('OnLeave', function() e.tips:Hide() end)

            hooksecurefunc('TimeManagerClockButton_UpdateTooltip', function()
                e.tips:AddDoubleLine(e.Icon.left..(e.onlyChinese and '服务器时间' or TIMEMANAGER_TOOLTIP_REALMTIME), e.SecondsToClock(GetServerTime()))
                e.tips:AddDoubleLine(id, addName)
                e.tips:Show()
            end)
        --elseif arg1=='Blizzard_ExpansionLandingPage' then
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