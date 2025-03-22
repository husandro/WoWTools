
local e= select(2, ...)
local TrackButton
local WorldMapButton--世界地图，添加一个按钮
local addName, addName2
--[[
vigentteButton=WoWTools_DataMixin.Player.husandro,
vigentteButtonShowText=true,
vigentteSound= WoWTools_DataMixin.Player.husandro,--播放声音
vigentteButtonTextScale=1,
hideVigentteCurrentOnMinimap=true,--当前，小地图，标记
hideVigentteCurrentOnWorldMap=true,--当前，世界地图，标记
questIDs={},--世界任务, 监视, ID {[任务ID]=true}
areaPoiIDs={[7492]= 2025},--{[areaPoiID]= 地图ID}
uiMapIDs= {},--地图ID 监视, areaPoiIDs，
currentMapAreaPoiIDs=true,--当前地图，监视, areaPoiIDs，
textToDown= WoWTools_DataMixin.Player.husandro,--文本，向下
]]

local function Save()
    return WoWTools_MinimapMixin.Save
end






--取得 areaPoiID 名称
--[[local barColor = {
	--[Enum.StatusBarColorTintValue.Black] = BLACK_FONT_COLOR,
	[3] = WHITE_FONT_COLOR,
	[2] = RED_FONT_COLOR,
	[1] = YELLOW_FONT_COLOR,
	--[Enum.StatusBarColorTintValue.Orange] = ORANGE_FONT_COLOR,
	[5] = EPIC_PURPLE_COLOR,
	[4] = GREEN_FONT_COLOR,
	[6] = RARE_BLUE_COLOR,
}]]

local function get_AreaPOIInfo_Name(poiInfo)
    return (poiInfo.atlasName and '|A:'..poiInfo.atlasName..':0:0|a' or '')..(poiInfo.name or '')
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
                itemTexture= WoWTools_QuestMixin:GetRewardInfo(questID).texture
                if not itemTexture then
                    atlas= 'worldquest-tracker-questmarker'
                end
                local secondsLeft = C_TaskQuest.GetQuestTimeLeftSeconds(questID, true)
                local secText= secondsLeft and SecondsToTime(secondsLeft)--WoWTools_TimeMixin:SecondsToClock(secondsLeft, true)
                text= text and text..'|n' or ''
                text= WoWTools_TextMixin:CN(questName)
                    ..(secText and ' |cffffffff'..secText..'|r' or '')
            end
        end
    end
    return text, itemTexture, atlas
end


















local function Get_Bar_Value(info)
    local barValue= info.barValue or info.leftBarMin
    local barMax= info.barMax or info.leftBarMin
    local barText
    if barMax and barMax>0 and barValue then
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
    if barText then
        barText= '|cffff00ff'..barText..'|r'
    end
    return barText
end



local function Get_widgetSetID_Info(widgetSetID)
    if not widgetSetID then
        return
    end

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

            if info
                and (
                    (info.shownState and info.shownState~=Enum.WidgetShownState.Hidden)
                    or (info.state and info.state~=Enum.IconAndTextWidgetState.Hidden)
                )
            then
                return info
            end
        end
    end
end













--##############
--areaPoiID 文本
--##############
local function Get_areaPoiID_Text(uiMapID, areaPoiID, all)
    local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID) or {}
    if not poiInfo.name  then
        return
    end

    local widgetSetData = Get_widgetSetID_Info(poiInfo.tooltipWidgetSet or poiInfo.iconWidgetSet)

    local time
    if C_AreaPoiInfo.IsAreaPOITimed(areaPoiID) then
        time=  C_AreaPoiInfo.GetAreaPOISecondsLeft(areaPoiID)
        time= (time and time>0) and time or nil
    end

    if (not widgetSetData or not widgetSetData.hasTimer) and not time then
        return
    end

    local name= WoWTools_TextMixin:CN(poiInfo.name)
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
        if time<86400 then
            if time<300 then
                time= '|cnGREEN_FONT_COLOR:'..WoWTools_TimeMixin:SecondsToClock(time)..'|r'
            else
                time= '|cffffffff'..WoWTools_TimeMixin:SecondsToClock(time)..'|r'
            end
        else
            time= '|cffffffff'..SecondsToTime(time)..'|r'
        end

    end

    return name..(time or ''), atlas, widgetSetData
end















--#########
--Vignettes
--#########
local function Get_Current_Vignettes()
    local onMinimap={}
    local onWorldMap={}
    local save=Save()

    if not (save.hideVigentteCurrentOnMinimap and save.hideVigentteCurrentOnWorldMap) then
        local vignetteGUIDs= C_VignetteInfo.GetVignettes() or {}
        local bestUniqueVignetteIndex = C_VignetteInfo.FindBestUniqueVignette(vignetteGUIDs)
        local tab={}



        for index, guid in pairs(vignetteGUIDs) do
            local info= C_VignetteInfo.GetVignetteInfo(guid) or {}
            if info.vignetteID and not tab[info.vignetteID]
                and (info.name or info.atlasName)
                and not info.isDead
                and (
                    (info.onMinimap and not save.hideVigentteCurrentOnMinimap)--当前，小地图，标记
                    or (info.onWorldMap and not save.hideVigentteCurrentOnWorldMap)--当前，世界地图，标记
                )
            then

                if info.rewardQuestID==0 then
                    info.rewardQuestID=nil
                end
                local name= WoWTools_TextMixin:CN(info.name, {vignetteID= info.vignetteID})

                if info.vignetteID == 5715 or info.vignetteID==5466 then--翻动的泥土堆
                    name= name..'|T1059121:0|t'
                elseif info.vignetteID== 5485 then
                    name= name..'|A:MajorFactions_Icons_Tuskarr512:0:0|a'
                elseif info.vignetteID==5468 then
                    name= name..'|A:MajorFactions_Icons_Expedition512:0:0|a'
                end

                if info.rewardQuestID then--任务，奖励
                    local itemTexture= WoWTools_QuestMixin:GetRewardInfo(info.rewardQuestID).texture
                    if itemTexture then
                        name= name..'|T'..itemTexture..':0|t'
                    end
                end

                if index==bestUniqueVignetteIndex then--唯一
                    name= '|cnGREEN_FONT_COLOR:'..name..'|r'..'|A:auctionhouse-icon-favorite:0:0|a'
                end

                local data= {
                    name=name,
                    widgetSetData= Get_widgetSetID_Info(info.widgetSetID),
                    atlas=info.atlasName,
                    vignetteGUID=guid,
                    onMinimap=info.onMinimap,
                    rewardQuestID= info.rewardQuestID
                }
                if info.onMinimap then
                    table.insert(onMinimap, data)
                else
                    table.insert(onWorldMap, data)
                end
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
                GameTooltip_SetTitle(GameTooltip, WoWTools_TextMixin:CN(vignetteInfo.name))
                titleAdded = true

            elseif vignetteInfo.type == Enum.VignetteType.PvPBounty then
                local player = PlayerLocation:CreateFromGUID(vignetteInfo.objectGUID)
                local class = select(3, C_PlayerInfo.GetClass(player))
                local race = C_PlayerInfo.GetRace(player)
                local name = C_PlayerInfo.GetName(player)
                if race and class and name then
                    local classInfo = C_CreatureInfo.GetClassInfo(class) or {}
                    local factionInfo = C_CreatureInfo.GetFactionInfo(race) or {}
                    GameTooltip_SetTitle(GameTooltip, WoWTools_TextMixin:CN(name), GetClassColorObj(classInfo.classFile))
                    GameTooltip_AddColoredLine(GameTooltip, WoWTools_TextMixin:CN(factionInfo.name), GetFactionColor(factionInfo.groupTag))
                    if vignetteInfo.rewardQuestID then
                        GameTooltip_AddQuestRewardsToTooltip(GameTooltip, vignetteInfo.rewardQuestID, TOOLTIP_QUEST_REWARDS_STYLE_PVP_BOUNTY)
                    end
                    titleAdded=true
                end
                waitingForData = not titleAdded

            elseif vignetteInfo.type == Enum.VignetteType.Torghast then
                SharedTooltip_SetBackdropStyle(GameTooltip, GAME_TOOLTIP_BACKDROP_STYLE_RUNEFORGE_LEGENDARY)
                GameTooltip_SetTitle(GameTooltip, WoWTools_TextMixin:CN(vignetteInfo.name))
                titleAdded = true
            end

            if not waitingForData and vignetteInfo.widgetSetID then
                local overflow = GameTooltip_AddWidgetSet(GameTooltip, vignetteInfo.widgetSetID, titleAdded and vignetteInfo.addPaddingAboveWidgets and 10)
                if overflow then
                    verticalPadding = -overflow
                end
            elseif waitingForData then
                GameTooltip_SetTitle(GameTooltip, WoWTools_Mixin.onlyChinese and '获取数据' or RETRIEVING_DATA)
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
                GameTooltip_SetTitle(GameTooltip, WoWTools_TextMixin:CN(poiInfo.name), HIGHLIGHT_FONT_COLOR)
                addedTooltipLine = true
            end

            if hasDescription then
                GameTooltip_AddNormalLine(GameTooltip, WoWTools_TextMixin:CN(poiInfo.description))
                addedTooltipLine = true
            end

            if showTimer then
                local secondsLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(self.areaPoiID)
                if secondsLeft and secondsLeft > 0 then
                    local timeString = SecondsToTime(secondsLeft)
                    GameTooltip_AddNormalLine(GameTooltip, format(WoWTools_Mixin.onlyChinese and '剩余时间：%s' or BONUS_OBJECTIVE_TIME_LEFT, timeString))
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
        GameTooltip:AddDoubleLine('areaPoiID |cnGREEN_FONT_COLOR:'..self.areaPoiID, 'uiMapID |cnGREEN_FONT_COLOR:'..self.uiMapID..'|r')
    elseif vignetteID then
        GameTooltip:AddLine('vignetteID |cnGREEN_FONT_COLOR:'..vignetteID)
    elseif self.questID then
        GameTooltip:AddLine('questID |cnGREEN_FONT_COLOR:'..self.questID)
    end
    if widgetSetID then
        local info= self.uiMapID and C_Map.GetMapInfo(self.uiMapID) or {}
        GameTooltip:AddDoubleLine('widgetSetID |cnGREEN_FONT_COLOR:'..widgetSetID, WoWTools_TextMixin:CN(info.name))
    end
    if self.rewardQuestID then
        GameTooltip:AddLine('rewardQuestID |cnGREEN_FONT_COLOR:'..self.rewardQuestID)
    end
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
                local time= WoWTools_TimeMixin:SecondsToClock(secondsLeft)
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
    WoWTools_ChatMixin:Chat(text, nil, nil)
end



















--TrackButton 文本
local function set_Button_Text()
    local allTable={}

    local onMinimap, onWorldMap= Get_Current_Vignettes()--{vignetteID=info.vignetteID, text=text, atlas= info.atlasName}
    for _, vigenttes in pairs(onMinimap) do
        table.insert(allTable, vigenttes)
    end
    for _, vigenttes in pairs(onWorldMap) do
        table.insert(allTable, vigenttes)
    end


    for questID, _ in pairs(Save().questIDs) do--世界任务
        local name, itemTexture, atlas= get_Quest_Text(questID)
        if name then
            table.insert(allTable, {questID=questID, name=name, texture=itemTexture, atlas= atlas})
        end
    end


    for areaPoiID, uiMapID in pairs(Save().areaPoiIDs) do--自定义 areaPoiID
        local name, atlas, widgetSetData= Get_areaPoiID_Text(uiMapID, areaPoiID, true)
        if name then
            table.insert(allTable, {name=name, areaPoiID=areaPoiID, uiMapID=uiMapID, widgetSetData=widgetSetData, atlas=atlas})
        end
    end



    for uiMapID, _ in pairs(Save().uiMapIDs) do--地图ID
        local tab={}
        for _, areaPoiID in pairs(C_AreaPoiInfo.GetAreaPOIForMap(uiMapID) or {}) do
            if not Save().areaPoiIDs[areaPoiID] and not tab[areaPoiID] then
                local name, atlas, widgetSetData= Get_areaPoiID_Text(uiMapID, areaPoiID)
                if name then
                    table.insert(allTable, {name=name, areaPoiID=areaPoiID, uiMapID=uiMapID, widgetSetData=widgetSetData, atlas=atlas})
                    tab[areaPoiID]=true
                end
            end
        end
    end

    if Save().currentMapAreaPoiIDs then
        local uiMapID= C_Map.GetBestMapForUnit("player")
        if uiMapID and uiMapID>0 and not Save().uiMapIDs[uiMapID] then
            local nameTab={}
            for _, areaPoiID in pairs(C_AreaPoiInfo.GetAreaPOIForMap(uiMapID) or {}) do
                if not Save().areaPoiIDs[areaPoiID] then
                    local name, atlas, widgetSetData= Get_areaPoiID_Text(uiMapID, areaPoiID)
                    if name and not nameTab[name] then
                        table.insert(allTable, {name=name, areaPoiID=areaPoiID, uiMapID=uiMapID, widgetSetData=widgetSetData, atlas=atlas})
                        nameTab[name]=true
                    end
                end
            end
        end
    end

    for index, info in pairs(allTable) do
        local btn = TrackButton.buttons[index]
        if not btn then
            btn= WoWTools_ButtonMixin:Cbtn(TrackButton.Frame, {size=12})
            btn.nameText= WoWTools_LabelMixin:Create(btn)
            btn.nameText:SetPoint('LEFT', btn, 'RIGHT')
            btn.onMinimap= btn:CreateTexture(nil, 'ARTWORK')
            btn.onMinimap:SetAtlas('UI-HUD-MicroMenu-Highlightalert')
            btn.onMinimap:SetPoint('CENTER')
            btn.onMinimap:SetSize(16,16)
            btn.onMinimap:SetVertexColor(0,1,0)
            btn.text= WoWTools_LabelMixin:Create(btn)

            btn.index= index

            function btn:settings(tables)
                self.questID= tables.questID--任务

                self.vignetteGUID= tables.vignetteGUID--vigentte
                self.rewardQuestID= tables.rewardQuestID

                self.areaPoiID= tables.areaPoiID--areaPoi
                self.uiMapID= tables.uiMapID

                self.name= tables.name
                self.nameText:SetText(tables.name=='' and ' ' or tables.name or '')


                local text
                if tables.widgetSetData then
                    text= tables.widgetSetData.text or tables.widgetSetData.tooltip

                    local barValueText= Get_Bar_Value(tables.widgetSetData)
                    if barValueText then
                        text= (text or '')..barValueText
                    end
                end
                self.text:SetText(text or '')

                if tables.atlas then
                    self:SetNormalAtlas(tables.atlas)
                else
                    self:SetNormalTexture(tables.texture or 0)
                end
                self:SetShown(tables.name)
                self.onMinimap:SetShown(tables.vignetteGUID and tables.onMinimap)--提示， 在小地图
            end

            function btn:set_point()
                if Save().textToDown then
                    if self.index==1 then
                        self:SetPoint('TOP', TrackButton, 'BOTTOM')
                    else
                        self:SetPoint('TOPRIGHT', TrackButton.buttons[index-1].text, 'BOTTOMLEFT')
                    end
                    self.text:SetPoint('TOPLEFT', self.nameText, 'BOTTOMLEFT')
                else
                    if index==1 then
                        self:SetPoint('BOTTOM', TrackButton, 'TOP')
                    else
                        self:SetPoint('BOTTOMRIGHT', TrackButton.buttons[index-1].text, 'TOPLEFT')
                    end
                    self.text:SetPoint('BOTTOMLEFT', self.nameText, 'TOPLEFT')
                end
            end

            btn:SetScript('OnClick', function(self, d)
                if d=='LeftButton' then
                    if self.name and self.name~='' then
                        set_OnClick_btn(self)
                    end
                end
            end)
            btn:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
                TrackButton:SetButtonState('NORMAL')
                self.nameText:SetAlpha(1)
                self.text:SetAlpha(1)
            end)
            btn:SetScript('OnEnter', function(self)
                GameTooltip:SetOwner(self.nameText or self.text or self, "ANCHOR_RIGHT")
                GameTooltip:ClearLines()

                set_OnEnter_btn_tips(self)

                GameTooltip:AddLine(' ')
                GameTooltip:AddDoubleLine(self.name and self.name~='' and '|A:communities-icon-chat:0:0|a'..(WoWTools_Mixin.onlyChinese and '信息' or INFO) or ' ', WoWTools_DataMixin.Icon.left)
                GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU , WoWTools_DataMixin.Icon.right)

                GameTooltip:Show()
                TrackButton:SetButtonState('PUSHED')
                self.nameText:SetAlpha(0.5)
                self.text:SetAlpha(0.5)
            end)


            btn:set_point()

            TrackButton.buttons[index]=btn
        end

        btn:settings(info)
    end

    for i= #allTable+1, #TrackButton.buttons do
        TrackButton.buttons[i]:settings({})
    end
end
























local function Init_Menu(self, root)--菜单
    local sub, sub2
--显示
    sub=root:CreateCheckbox(
        WoWTools_Mixin.onlyChinese and '显示' or SHOW,
    function()
        return Save().vigentteButtonShowText
    end, function()
        Save().vigentteButtonShowText= not Save().vigentteButtonShowText and true or nil
        self:set_shown()
        self:set_texture()
        self:set_state()
    end)

    
    sub:CreateCheckbox(
        WoWTools_Mixin.onlyChinese and '向下滚动' or COMBAT_TEXT_SCROLL_DOWN,
    function()
        return Save().textToDown
    end, function()
        Save().textToDown= not Save().textToDown and true or nil
        for _, btn in pairs(self.buttons) do
            btn:ClearAllPoints()
            btn.text:ClearAllPoints()
            btn:set_point()
        end
    end)

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().vigentteButtonTextScale
    end, function(value)
        Save().vigentteButtonTextScale= value
        self:set_scale()
    end)


--FrameStrata    
    sub2= WoWTools_MenuMixin:FrameStrata(sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().trackButtonStrata= data
        self:set_strata()
    end)
    sub2:SetEnabled(not WoWTools_Mixin:IsLockFrame(self))
    --if UnitAffectingCombat('player') then
      --  sub2:SetEnabled(false)
    --end

--重置位置
    sub:CreateDivider()
    WoWTools_MenuMixin:RestPoint(self, sub, Save().pointVigentteButton, WoWTools_MinimapMixin.Rest_TrackButton_Point)

--当前
    root:CreateDivider()
    sub=root:CreateCheckbox(
        (WoWTools_Mixin.onlyChinese and '当前' or REFORGE_CURRENT)..(Save().vigentteSound and '|A:chatframe-button-icon-voicechat:0:0|a' or ' ')..'Vignette',
    function()
        return not Save().hideVigentteCurrent
    end, function()
        Save().hideVigentteCurrent= not Save().hideVigentteCurrent and true or nil
    end)

--小地图
    sub:CreateCheckbox(
        (WoWTools_Mixin.onlyChinese and '小地图' or HUD_EDIT_MODE_MINIMAP_LABEL),
    function()
        return not Save().hideVigentteCurrentOnMinimap
    end, function()
        Save().hideVigentteCurrentOnMinimap= not Save().hideVigentteCurrentOnMinimap and true or nil
    end)


--世界地图
    sub:CreateCheckbox(
        (WoWTools_Mixin.onlyChinese and '世界地图' or WORLDMAP_BUTTON),
    function()
        return not Save().hideVigentteCurrentOnWorldMap
    end, function()
        Save().hideVigentteCurrentOnWorldMap= not Save().hideVigentteCurrentOnWorldMap and true or nil
    end)

--播放声音
    sub:CreateCheckbox(
        '|A:chatframe-button-icon-voicechat:0:0|a'
        ..(Save().hideVigentteCurrentOnWorldMap and '|cff9e9e9e' or '')
        ..(WoWTools_Mixin.onlyChinese and '播放声音' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, EVENTTRACE_BUTTON_PLAY, SOUND)),
    function()
        return Save().vigentteSound
    end, function()
        Save().vigentteSound= not Save().vigentteSound and true or nil
        if not Save().hideVigentteCurrentOnWorldMap then
            self:set_VIGNETTES_UPDATED(true)
            self:set_event()
            if Save().vigentteSound then
                self:speak_Text(WoWTools_Mixin.onlyChinese and '播放声音' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, EVENTTRACE_BUTTON_PLAY, SOUND))
            end
        end
    end)

--世界任务
    local num=0
    for questID in pairs(Save().questIDs) do
        num= num+1
        WoWTools_Mixin:Load({id=questID, type=='quest'})
    end
    sub=root:CreateButton(
        (WoWTools_Mixin.onlyChinese and '世界任务' or TRACKER_HEADER_WORLD_QUESTS)
        ..' |cnGREEN_FONT_COLOR:#'..num,
    function()
        return MenuResponse.Open
    end)

    for questID in pairs(Save().questIDs) do
        sub2=sub:CreateCheckbox(
            '|T'..(WoWTools_QuestMixin:GetRewardInfo(questID).texture or 0)..':0|t'
            ..WoWTools_QuestMixin:GetName(questID),
        function(data)
            return Save().questIDs[data.questID]
        end, function(data)
            Save().questIDs[data.questID]= not Save().questIDs[data.questID] and true or nil
            print(WoWTools_DataMixin.Icon.icon2.. addName, addName2, WoWTools_QuestMixin:GetLink(data.questID))
        end, {questID=questID})
        sub2:SetTooltip(function(tooltip, description)
            tooltip:AddLine(WoWTools_Mixin.onlyChinese and '移除' or REMOVE)
            tooltip:AddLine('questID '..description.data.questID)
        end)
    end

    if num>1 then
        sub:CreateDivider()
        sub:CreateButton(
            WoWTools_Mixin.onlyChinese and '全部清除' or CLEAR_ALL,
        function()
            Save().questIDs={}
        end)
        WoWTools_MenuMixin:SetGridMode(sub, num)
    end

--areaPoiIDs
    num=0
    for _ in pairs(Save().areaPoiIDs) do
        num= num+1
    end
    sub=root:CreateButton(
        'AreaPoiID |cnGREEN_FONT_COLOR:#'..num,
    function()
        return MenuResponse.Open
    end)

    for areaPoiID, uiMapID in pairs(Save().areaPoiIDs) do
        local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID) or {}
        sub2=sub:CreateCheckbox(get_AreaPOIInfo_Name(poiInfo) or areaPoiID, function(data)
            return Save().areaPoiIDs[data.areaPoiID]
        end, function(data)
            Save().areaPoiIDs[data.areaPoiID]= not Save().areaPoiIDs[data.areaPoiID] and data.uiMapID or nil
        end, {areaPoiID=areaPoiID, uiMapID=uiMapID})
        sub2:SetTooltip(function(tooltip, description)
            tooltip:AddLine(WoWTools_Mixin.onlyChinese and '移除' or REMOVE)
            tooltip:AddLine('uiMapID '..description.data.uiMapID)
            tooltip:AddLine('areaPoiID '..description.data.areaPoiID)
        end)
    end

    if num>1 then
        sub:CreateDivider()
        sub:CreateButton(
            WoWTools_Mixin.onlyChinese and '全部清除' or CLEAR_ALL,
        function()
            Save().areaPoiIDs={}
        end)
        WoWTools_MenuMixin:SetGridMode(sub, num)
    end

--地图
    num=0
    for _ in pairs(Save().uiMapIDs) do
        num= num+1
    end
    sub=root:CreateButton(
        (WoWTools_Mixin.onlyChinese and '地图' or WORLD_MAP)..'|cnGREEN_FONT_COLOR:#'..num,
    function()
        return MenuResponse.Open
    end)

    for uiMapID in pairs(Save().uiMapIDs) do
        sub2=sub:CreateCheckbox(
            WoWTools_TextMixin:CN((C_Map.GetMapInfo(uiMapID) or {}).name) or uiMapID,
        function(data)
            return Save().uiMapIDs[data.uiMapID]
        end, function(data)
            Save().uiMapIDs[data.uiMapID]= not Save().uiMapIDs[data.uiMapID] and true or nil
        end, {uiMapID=uiMapID})
        sub2:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_Mixin.onlyChinese and '移除' or REMOVE)
            tooltip:AddLine('uiMapID '..uiMapID)
        end)
    end

    if num>1 then
        sub:CreateDivider()
        sub:CreateButton(
            WoWTools_Mixin.onlyChinese and '全部清除' or CLEAR_ALL,
        function()
            Save().uiMapIDs={}
        end)
        WoWTools_MenuMixin:SetGridMode(sub, num)
    end


--打开选项
    root:CreateDivider()
    WoWTools_MinimapMixin:OpenPanel(root)
end






















--小地图, 标记, 文本
local function Init_Button()
    TrackButton= WoWTools_ButtonMixin:Cbtn(nil, {
        size=23,
        name='WoWTools_Minimap_TrackButton',
        atlas='VignetteKillElite',
    })



    TrackButton.buttons={}

    TrackButton.Frame= CreateFrame('Frame', nil, TrackButton)
    TrackButton.Frame:SetAllPoints()


    --[[TrackButton.texture= TrackButton:CreateTexture(nil, 'BORDER')
    TrackButton.texture:SetAllPoints(TrackButton)
    TrackButton.texture:SetAlpha(0.5)]]



    function TrackButton:set_strata()
        self:SetFrameStrata(Save().trackButtonStrata or 'MEDIUM')
    end


    function TrackButton:set_texture()
        self:GetNormalTexture():SetAlpha(Save().vigentteButtonShowText and 0.3 or 0.7)
    end

    function TrackButton:set_point()--设置，位置
        if Save().pointVigentteButton then
            self:SetPoint(Save().pointVigentteButton[1], UIParent, Save().pointVigentteButton[3], Save().pointVigentteButton[4], Save().pointVigentteButton[5])
        else
            self:SetPoint('TOPLEFT', 600, WoWTools_DataMixin.Player.husandro and 0 or -100)
        end
    end

    TrackButton:RegisterForDrag("RightButton")
    TrackButton:SetMovable(true)
    TrackButton:SetClampedToScreen(true)
    TrackButton:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    TrackButton:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save().pointVigentteButton={self:GetPoint(1)}
        Save().pointVigentteButton[2]=nil
    end)

    TrackButton:SetScript('OnMouseUp', ResetCursor)
    TrackButton:SetScript('OnMouseDown', function(self, d)--显示，隐藏
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        else
            local key= IsModifierKeyDown()
            if d=='LeftButton' and not key then
                Save().vigentteButtonShowText= not Save().vigentteButtonShowText and true or nil
                self:set_shown()
                self:set_texture()

            elseif d=='RightButton' and not key then
                MenuUtil.CreateContextMenu(self, Init_Menu)
            end
        end
    end)





    function TrackButton:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(addName, addName2)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_TextMixin:GetShowHide(nil, true), WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '主菜单' or MAINMENU_BUTTON, WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine((WoWTools_Mixin.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save().vigentteButtonTextScale or 1), 'Alt+'..WoWTools_DataMixin.Icon.mid)
        GameTooltip:Show()
    end

    TrackButton:SetScript('OnMouseWheel', function(self, d)--缩放
        Save().vigentteButtonTextScale= WoWTools_FrameMixin:ScaleFrame(self, d, Save().vigentteButtonTextScale, nil)
    end)

    TrackButton:SetScript('OnEnter',function(self)
        self:set_tooltip()
    end)
    TrackButton:SetScript('OnLeave',function(self)
        GameTooltip:Hide()
        ResetCursor()
    end)












    function TrackButton:set_shown()
        local hide= not Save().vigentteButton
            or (IsInInstance() and not WoWTools_MapMixin:IsInDelve())
            or C_PetBattles.IsInBattle()
            or UnitInVehicle('player')
            or UnitAffectingCombat('player')
            or WorldMapFrame:IsShown()

        self:SetShown(not hide)
        self.Frame:SetShown(Save().vigentteButtonShowText and not hide)
        self.elapsed=nil
    end


    function TrackButton:set_event()
        self:UnregisterAllEvents()

        self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
        self:RegisterEvent('PLAYER_ENTERING_WORLD')

        if Save().vigentteButton and (not IsInInstance() or WoWTools_MapMixin:IsInDelve()) then
            self:RegisterEvent('PET_BATTLE_OPENING_DONE')
            self:RegisterEvent('PET_BATTLE_CLOSE')

            self:RegisterUnitEvent('UNIT_EXITED_VEHICLE', 'player')
            self:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', 'player')

            self:RegisterEvent('PLAYER_REGEN_DISABLED')
            self:RegisterEvent('PLAYER_REGEN_ENABLED')

            if Save().vigentteSound then
                self:RegisterEvent('VIGNETTES_UPDATED')
            end
        end
    end

    TrackButton:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_ENTERING_WORLD' or event=='ZONE_CHANGED_NEW_AREA' then
            self.SpeakTextTab=nil
            self:set_event()
            self:set_shown()
        elseif event=='VIGNETTES_UPDATED' then
            self:set_VIGNETTES_UPDATED()
        else--PLAYER_REGEN_DISABLED PLAYER_REGEN_ENABLED
            self:set_shown()
        end
    end)










    function TrackButton:set_scale()--设置，Button的 Frame Text 属性
        self.Frame:SetScale(Save().vigentteButtonTextScale or 1)
    end

    WorldMapFrame:HookScript('OnHide', function() TrackButton:set_shown() end)
    WorldMapFrame:HookScript('OnShow', function() TrackButton:set_shown() end)

    TrackButton.Frame:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 1) + elapsed
        if self.elapsed>=1 then
            self.elapsed=0
            set_Button_Text()
        end
    end)
















    --播放声音
    function TrackButton:speak_Text(text)
        local ttsVoices= C_VoiceChat.GetTtsVoices() or {}
        local voiceID= ttsVoices.voiceID or C_TTSSettings.GetVoiceOptionID(Enum.TtsVoiceType.Standard)
        local destination= ttsVoices.voiceID and Enum.VoiceTtsDestination.QueuedLocalPlayback or Enum.VoiceTtsDestination.LocalPlayback
        --C_VoiceChat.SpeakText(voiceID, text, destination, rate, volume)
        C_VoiceChat.SpeakText(voiceID, text, destination, 0, 100)
        print(WoWTools_DataMixin.Icon.icon2.. addName2,'|cffff00ff', text)
    end
    function TrackButton:set_VIGNETTES_UPDATED(init)
        if UnitOnTaxi('player') or not Save().vigentteSound then
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


    function TrackButton:set_state()
        if self:GetButtonState()~='PUSHED' then
            self:SetButtonState('PUSHED')
            C_Timer.After(5, function()
                if not GameTooltip:IsOwned(self) then
                    self:SetButtonState('NORMAL')
                end
            end)
        end
    end
    TrackButton:SetScript('OnShow', TrackButton.set_state)
    TrackButton:set_state()


    TrackButton:set_VIGNETTES_UPDATED(true)
    TrackButton:set_point()
    TrackButton:set_texture()
    TrackButton:set_scale()
    TrackButton:set_event()
    TrackButton:set_shown()
    TrackButton:set_strata()

end























--世界地图，添加一个按钮
local function Init_WorldFrame_Button()
    WorldMapButton= WoWTools_ButtonMixin:Cbtn(WorldMapFrame, {size=20, name='WoWTools_Minimap_WorldTrackButton'})
    function WorldMapButton:set_texture()
        local uiMapID= WorldMapFrame.mapID or WorldMapFrame:GetMapID("current")
        if not uiMapID then
            self:SetNormalTexture(0)
        else
            self:SetNormalAtlas(Save().uiMapIDs[uiMapID] and WoWTools_DataMixin.Icon.select or 'VignetteKillElite')
        end
    end
    WorldMapButton:SetPoint('TOPRIGHT', WorldMapFramePortrait, 'BOTTOMRIGHT', 2, 10)
    WorldMapButton:SetScript('OnClick', function(self)
        local uiMapID= WorldMapFrame.mapID or WorldMapFrame:GetMapID("current")
        if uiMapID then
            Save().uiMapIDs[uiMapID]= not Save().uiMapIDs[uiMapID] and true or nil
            local name= (C_Map.GetMapInfo(uiMapID) or {}).name or ('uiMapID '..uiMapID)
            print(WoWTools_DataMixin.Icon.icon2.. addName, addName2,
                name,
                Save().uiMapIDs[uiMapID] and '|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.select) or ('|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a')
            )
            self:set_texture()
        end
    end)
    WorldMapButton:SetScript('OnShow', WorldMapButton.set_texture)
    WorldMapButton:SetScript('OnLeave', GameTooltip_Hide)
    WorldMapButton:SetScript('OnEnter', function(self)
        local uiMapID= WorldMapFrame.mapID or WorldMapFrame:GetMapID("current")
        if uiMapID then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddDoubleLine(addName2..(Save().uiMapIDs[uiMapID] and format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.select) or ''), ((C_Map.GetMapInfo(uiMapID) or {}).name or '')..' '..uiMapID)
            GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, addName)
            GameTooltip:Show()
        end
    end)
    hooksecurefunc(WorldMapFrame, 'OnMapChanged', function() WorldMapButton:set_texture() end)--uiMapIDs, 添加，移除 --Blizzard_WorldMap.lua
end

















--世界地图，事件
local function Init_WorldFrame_Event()
    hooksecurefunc('TaskPOI_OnEnter', function(self)--世界任务，提示 WorldMapFrame.lua
        if self.questID and self.OnMouseClickAction then
            GameTooltip:AddDoubleLine(addName2..(Save().questIDs[self.questID] and format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.select) or ''), 'Alt+'..WoWTools_DataMixin.Icon.left)
            GameTooltip:Show()
        end
    end)
    hooksecurefunc(WorldQuestPinMixin, 'RefreshVisuals', function(self)--世界任务，添加/移除 WorldQuestDataProvider.lua self.tagInfo
        if not self.OnMouseClickAction or self.setTracking then
            return
        end
        hooksecurefunc(self, 'OnMouseClickAction', function(f, d)
            if f.questID and d=='LeftButton' and IsAltKeyDown() then
                Save().questIDs[f.questID]= not Save().questIDs[f.questID] and true or nil
                print(WoWTools_DataMixin.Icon.icon2.. addName, addName2,
                    WoWTools_QuestMixin:GetLink(f.questID),
                    Save().questIDs[f.questID] and '|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.select) or ('|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a')
                )
            end
        end)
        self.setTracking=true
    end)

    hooksecurefunc(AreaPOIPinMixin,'TryShowTooltip', function(self)--areaPoiID,提示 AreaPOIDataProvider.lua
        if self.areaPoiID and  self:GetMap() and self:GetMap():GetMapID() then
            GameTooltip:AddDoubleLine(addName2..(Save().areaPoiIDs[self.areaPoiID] and format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.select) or ''), 'Alt+'..WoWTools_DataMixin.Icon.left)
            GameTooltip:Show()
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
                    Save().areaPoiIDs[self.areaPoiID]= not Save().areaPoiIDs[self.areaPoiID] and uiMapID or nil
                    local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, self.areaPoiID) or {}
                    local name= get_AreaPOIInfo_Name(poiInfo)--取得 areaPoiID 名称
                    name= name=='' and 'areaPoiID '..self.areaPoiID or name
                    print(WoWTools_DataMixin.Icon.icon2.. addName, addName2,
                        (C_Map.GetMapInfo(uiMapID) or {}).name or ('uiMapID '..uiMapID),
                        name,
                        Save().areaPoiIDs[self.areaPoiID] and '|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.select) or ('|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a')
                    )
                end
            end
        end)
        self.setTracking=true
    end)

end















--小地图, 标记, 文本
function WoWTools_MinimapMixin:Init_TrackButton()
    if not Save().vigentteButton or TrackButton then
        if TrackButton then
            TrackButton:set_shown()
        end
        return
    end
    addName= self.addName
    addName2= self.addName2

    Init_Button()--小地图, 标记, 文本
    Init_WorldFrame_Button()--世界地图，添加一个按钮
    Init_WorldFrame_Event()--世界地图，事件
end


--重置位置
function WoWTools_MinimapMixin:Rest_TrackButton_Point()
    if TrackButton then
        Save().pointVigentteButton=nil
        TrackButton:ClearAllPoints()
        TrackButton:set_point()
    end
end

function WoWTools_MinimapMixin:Init_TrackButton_Menu(_, root)
    if TrackButton then
        Init_Menu(TrackButton, root)
    end
end













--[[
UIWidgetManagerSharedDocumentation.lua
{
Name = "UIWidgetVisualizationType",
Type = "Enumeration",
NumValues = 30,
MinValue = 0,
MaxValue = 29,
Fields =
{ Name = "IconAndText", Type = "UIWidgetVisualizationType", EnumValue = 0 },
{ Name = "CaptureBar", Type = "UIWidgetVisualizationType", EnumValue = 1 },
{ Name = "StatusBar", Type = "UIWidgetVisualizationType", EnumValue = 2 },
{ Name = "DoubleStatusBar", Type = "UIWidgetVisualizationType", EnumValue = 3 },
{ Name = "IconTextAndBackground", Type = "UIWidgetVisualizationType", EnumValue = 4 },
{ Name = "DoubleIconAndText", Type = "UIWidgetVisualizationType", EnumValue = 5 },
{ Name = "StackedResourceTracker", Type = "UIWidgetVisualizationType", EnumValue = 6 },
{ Name = "IconTextAndCurrencies", Type = "UIWidgetVisualizationType", EnumValue = 7 },
{ Name = "TextWithState", Type = "UIWidgetVisualizationType", EnumValue = 8 },
{ Name = "HorizontalCurrencies", Type = "UIWidgetVisualizationType", EnumValue = 9 },
{ Name = "BulletTextList", Type = "UIWidgetVisualizationType", EnumValue = 10 },
{ Name = "ScenarioHeaderCurrenciesAndBackground", Type = "UIWidgetVisualizationType", EnumValue = 11 },
{ Name = "TextureAndText", Type = "UIWidgetVisualizationType", EnumValue = 12 },
{ Name = "SpellDisplay", Type = "UIWidgetVisualizationType", EnumValue = 13 },
{ Name = "DoubleStateIconRow", Type = "UIWidgetVisualizationType", EnumValue = 14 },
{ Name = "TextureAndTextRow", Type = "UIWidgetVisualizationType", EnumValue = 15 },
{ Name = "ZoneControl", Type = "UIWidgetVisualizationType", EnumValue = 16 },
{ Name = "CaptureZone", Type = "UIWidgetVisualizationType", EnumValue = 17 },
{ Name = "TextureWithAnimation", Type = "UIWidgetVisualizationType", EnumValue = 18 },
{ Name = "DiscreteProgressSteps", Type = "UIWidgetVisualizationType", EnumValue = 19 },
{ Name = "ScenarioHeaderTimer", Type = "UIWidgetVisualizationType", EnumValue = 20 },
{ Name = "TextColumnRow", Type = "UIWidgetVisualizationType", EnumValue = 21 },
{ Name = "Spacer", Type = "UIWidgetVisualizationType", EnumValue = 22 },
{ Name = "UnitPowerBar", Type = "UIWidgetVisualizationType", EnumValue = 23 },
{ Name = "FillUpFrames", Type = "UIWidgetVisualizationType", EnumValue = 24 },
{ Name = "TextWithSubtext", Type = "UIWidgetVisualizationType", EnumValue = 25 },
{ Name = "MapPinAnimation", Type = "UIWidgetVisualizationType", EnumValue = 26 },
{ Name = "ItemDisplay", Type = "UIWidgetVisualizationType", EnumValue = 27 },
{ Name = "TugOfWar", Type = "UIWidgetVisualizationType", EnumValue = 28 },
{ Name = "ScenarioHeaderDelves", Type = "UIWidgetVisualizationType", EnumValue = 29 },





local function Get_widgetSetID_Info(widgetSetID)
    if not widgetSetID then
        return
    end

    for _, widget in ipairs(C_UIWidgetManager.GetAllWidgetsBySetID(widgetSetID) or {}) do
        local info
        if widget.widgetID then
            if widget.widgetType ==Enum.UIWidgetVisualizationType.IconAndText then
                info= C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo(widget.widgetID)

state	Enum.IconAndTextWidgetState	
text	string	
tooltip	string	
dynamicTooltip	string	
tooltipLoc	Enum.UIWidgetTooltipLocation	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number	



            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.CaptureBar then
                info= C_UIWidgetManager.GetCaptureBarWidgetVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
barValue	number	
barMinValue	number	
barMaxValue	number	
neutralZoneSize	number	
neutralZoneCenter	number	
tooltip	string	
glowAnimType	Enum.CaptureBarWidgetGlowAnimType	
fillDirectionType	Enum.CaptureBarWidgetFillDirectionType	
tooltipLoc	Enum.UIWidgetTooltipLocation	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number	


            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.StatusBar then
                info= C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
leftBarMin	number	
leftBarMax	number	
leftBarValue	number	
leftBarTooltip	string	
rightBarMin	number	
rightBarMax	number	
rightBarValue	number	
rightBarTooltip	string	
barValueTextType	Enum.StatusBarValueTextType	
text	string	
leftBarTooltipLoc	Enum.UIWidgetTooltipLocation	
rightBarTooltipLoc	Enum.UIWidgetTooltipLocation	
fillMotionType	Enum.UIWidgetMotionType	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number	


            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.DoubleStatusBar then
                info= C_UIWidgetManager.GetDoubleStatusBarWidgetVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
leftBarMin	number	
leftBarMax	number	
leftBarValue	number	
leftBarTooltip	string	
rightBarMin	number	
rightBarMax	number	
rightBarValue	number	
rightBarTooltip	string	
barValueTextType	Enum.StatusBarValueTextType	
text	string	
leftBarTooltipLoc	Enum.UIWidgetTooltipLocation	
rightBarTooltipLoc	Enum.UIWidgetTooltipLocation	
fillMotionType	Enum.UIWidgetMotionType	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number	


            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.IconTextAndBackground then

shownState	Enum.WidgetShownState	
text	string	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number	


            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.DoubleIconAndText then

shownState	Enum.WidgetShownState	
resources	UIWidgetCurrencyInfo[]	
tooltipLoc	Enum.UIWidgetTooltipLocation	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number	


            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.StackedResourceTracker then
                info= C_UIWidgetManager.GetIconTextAndBackgroundWidgetVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
resources	UIWidgetCurrencyInfo[]	
tooltipLoc	Enum.UIWidgetTooltipLocation	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number	



            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.IconTextAndCurrencies then
                info= C_UIWidgetManager.GetIconTextAndCurrenciesWidgetVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
barValue	number	
barMinValue	number	
barMaxValue	number	
neutralZoneSize	number	
neutralZoneCenter	number	
tooltip	string	
glowAnimType	Enum.CaptureBarWidgetGlowAnimType	
fillDirectionType	Enum.CaptureBarWidgetFillDirectionType	
tooltipLoc	Enum.UIWidgetTooltipLocation	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number	

            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.TextWithState then
                info= C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
enabledState	Enum.WidgetEnabledState	
text	string	
tooltip	string	
textSizeType	Enum.UIWidgetTextSizeType	
fontType	Enum.UIWidgetFontType	
bottomPadding	number	
tooltipLoc	Enum.UIWidgetTooltipLocation	
hAlign	Enum.WidgetTextHorizontalAlignmentType	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number

            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.HorizontalCurrencies then
                info= C_UIWidgetManager.GetHorizontalCurrenciesWidgetVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
enabledState	Enum.WidgetEnabledState	
text	string	
tooltip	string	
textSizeType	Enum.UIWidgetTextSizeType	
fontType	Enum.UIWidgetFontType	
bottomPadding	number	
tooltipLoc	Enum.UIWidgetTooltipLocation	
hAlign	Enum.WidgetTextHorizontalAlignmentType	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number



            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.BulletTextList then
                info= C_UIWidgetManager.GetBulletTextListWidgetVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
enabledState	Enum.WidgetEnabledState	
lines	string[]	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number	

            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.ScenarioHeaderCurrenciesAndBackground then
                info= C_UIWidgetManager.GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
currencies	UIWidgetCurrencyInfo[]	
headerText	string	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number	


            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.TextureAndText then
                info= C_UIWidgetManager.GetTextureAndTextVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
currencies	UIWidgetCurrencyInfo[]	
headerText	string	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number	


            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.SpellDisplay then
                info= C_UIWidgetManager.GetSpellDisplayVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
enabledState	Enum.WidgetEnabledState	
spellInfo	UIWidgetSpellInfo	
tooltipLoc	Enum.UIWidgetTooltipLocation	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number	



            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.DoubleStateIconRow then
                info= C_UIWidgetManager.GetDoubleStateIconRowVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
leftIcons	UIWidgetStateIconInfo[]	
rightIcons	UIWidgetStateIconInfo[]	
tooltipLoc	Enum.UIWidgetTooltipLocation	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number


            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.TextureAndTextRow then
                info= C_UIWidgetManager.GetTextureAndTextRowVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
entries	TextureAndTextEntryInfo[]	
textSizeType	Enum.UIWidgetTextureAndTextSizeType	
fixedWidth	number?	
tooltipLoc	Enum.UIWidgetTooltipLocation	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number	


            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.ZoneControl then
                info= C_UIWidgetManager.GetZoneControlVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
mode	Enum.ZoneControlMode	
leadingEdgeType	Enum.ZoneControlLeadingEdgeType	
dangerFlashType	Enum.ZoneControlDangerFlashType	
zoneEntries	ZoneEntry[]	
tooltipLoc	Enum.UIWidgetTooltipLocation	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number


            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.CaptureZone then
                info= C_UIWidgetManager.GetCaptureZoneVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
mode	Enum.ZoneControlMode	
leadingEdgeType	Enum.ZoneControlLeadingEdgeType	
dangerFlashType	Enum.ZoneControlDangerFlashType	
zoneInfo	ZoneEntry	
tooltipLoc	Enum.UIWidgetTooltipLocation	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number


            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.TextureWithAnimation then
                info= C_UIWidgetManager.GetTextureWithAnimationVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
tooltip	string	
tooltipLoc	Enum.UIWidgetTooltipLocation	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number


            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.DiscreteProgressSteps then
                info= C_UIWidgetManager.GetDiscreteProgressStepsVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
tooltip	string	
tooltipLoc	Enum.UIWidgetTooltipLocation	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number


            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.ScenarioHeaderTimer then
                info= C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
tooltip	string	
tooltipLoc	Enum.UIWidgetTooltipLocation	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number


            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.TextColumnRow then
                info= C_UIWidgetManager.GetTextColumnRowVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
entries	TextColumnRowEntryInfo[]	
textSizeType	Enum.UIWidgetTextSizeType	
fontType	Enum.UIWidgetFontType	
tooltip	string	
tooltipLoc	Enum.UIWidgetTooltipLocation	
bottomPadding	number	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number


            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.Spacer then
                info= C_UIWidgetManager.GetSpacerVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
widgetWidth	number	
widgetHeight	number	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number

            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.UnitPowerBar then
                info= C_UIWidgetManager.GetUnitPowerBarWidgetVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
barMin	number	
barMax	number	
barValue	number	
tooltip	string	
barValueTextType	Enum.StatusBarValueTextType	
overrideBarText	string	
overrideBarTextShownType	Enum.StatusBarOverrideBarTextShownType	
tooltipLoc	Enum.UIWidgetTooltipLocation	
fillMotionType	Enum.UIWidgetMotionType	
flashBlendModeType	Enum.UIWidgetBlendModeType	
sparkBlendModeType	Enum.UIWidgetBlendModeType	
flashMomentType	Enum.WidgetUnitPowerBarFlashMomentType	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number


            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.FillUpFrames then
                info= C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
barMin	number	
barMax	number	
barValue	number	
tooltip	string	
barValueTextType	Enum.StatusBarValueTextType	
overrideBarText	string	
overrideBarTextShownType	Enum.StatusBarOverrideBarTextShownType	
tooltipLoc	Enum.UIWidgetTooltipLocation	
fillMotionType	Enum.UIWidgetMotionType	
flashBlendModeType	Enum.UIWidgetBlendModeType	
sparkBlendModeType	Enum.UIWidgetBlendModeType	
flashMomentType	Enum.WidgetUnitPowerBarFlashMomentType	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number

            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.TextWithSubtext then
                info= C_UIWidgetManager.GetTextWithSubtextWidgetVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
barMin	number	
barMax	number	
barValue	number	
tooltip	string	
barValueTextType	Enum.StatusBarValueTextType	
overrideBarText	string	
overrideBarTextShownType	Enum.StatusBarOverrideBarTextShownType	
tooltipLoc	Enum.UIWidgetTooltipLocation	
fillMotionType	Enum.UIWidgetMotionType	
flashBlendModeType	Enum.UIWidgetBlendModeType	
sparkBlendModeType	Enum.UIWidgetBlendModeType	
flashMomentType	Enum.WidgetUnitPowerBarFlashMomentType	
widgetSizeSetting	number	
textureKit	string	
frameTextureKit	string	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number

            --elseif widget.widgetType ==Enum.UIWidgetVisualizationType.WorldLootObject		Added in 10.1.0
            elseif widget.widgetType ==Enum.UIWidgetVisualizationType.ItemDisplay then
                info= C_UIWidgetManager.GetItemDisplayVisualizationInfo(widget.widgetID)

shownState	Enum.WidgetShownState	
tooltipLoc	Enum.UIWidgetTooltipLocation	
itemInfo	UIWidgetItemInfo	
widgetSizeSetting	number	
textureKit	string : textureKit	
frameTextureKit	string : textureKit	
hasTimer	boolean	
orderIndex	number	
widgetTag	string	
inAnimType	Enum.WidgetAnimationType	
outAnimType	Enum.WidgetAnimationType	
widgetScale	Enum.UIWidgetScale	
layoutDirection	Enum.UIWidgetLayoutDirection	
modelSceneLayer	Enum.UIWidgetModelSceneLayer	
scriptedAnimationEffectID	number

            end
        end
        if info
            and (
                (info.shownState and info.shownState~=Enum.WidgetShownState.Hidden)
                or (info.state and info.state~=Enum.IconAndTextWidgetState.Hidden)
            )
        then
            return info
        end
    end
end
]]
