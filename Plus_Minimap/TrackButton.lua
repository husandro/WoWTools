
local e= select(2, ...)
local TrackButton
local WorldMapButton--世界地图，添加一个按钮
local addName, addName2


local function Save()
    return WoWTools_MinimapMixin.Save
end






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
    if not (Save().hideVigentteCurrentOnMinimap and Save().hideVigentteCurrentOnWorldMap) then
        local vignetteGUIDs= C_VignetteInfo.GetVignettes() or {}
        local bestUniqueVignetteIndex = C_VignetteInfo.FindBestUniqueVignette(vignetteGUIDs)
        local tab={}



        for index, guid in pairs(vignetteGUIDs) do
            local info= C_VignetteInfo.GetVignetteInfo(guid) or {}
            if info.vignetteID and not tab[info.vignetteID]
                and (info.name or info.atlasName)
                and not info.isDead
                and (
                    (info.onMinimap and not Save().hideVigentteCurrentOnMinimap)--当前，小地图，标记
                    or (info.onWorldMap and not Save().hideVigentteCurrentOnWorldMap)--当前，世界地图，标记
                )
            then

                if info.rewardQuestID==0 then
                    info.rewardQuestID=nil
                end
                local text
                local name= e.cn(info.name, {vignetteID= info.vignetteID})
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

                    local itemTexture= WoWTools_QuestMixin:GetRewardInfo(info.rewardQuestID).texture

                    if itemTexture then
                        name= name..'|T'..itemTexture..':0|t'
                    end
                end
                if index==bestUniqueVignetteIndex then--唯一
                    name= '|cnGREEN_FONT_COLOR:'..name..'|r'..'|A:auctionhouse-icon-favorite:0:0|a'
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



















--TrackButton 文本
local function set_Button_Text()
    local allTable={}

    local onMinimap, onWorldMap= get_vignette_Text()--{vignetteID=info.vignetteID, text=text, atlas= info.atlasName}
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
        local name, atlas, text= Get_areaPoiID_Text(uiMapID, areaPoiID, true)
        if name then
            table.insert(allTable, {name=name, areaPoiID=areaPoiID, uiMapID=uiMapID, text=text, atlas=atlas})
        end
    end



    for uiMapID, _ in pairs(Save().uiMapIDs) do--地图ID
        local tab={}
        for _, areaPoiID in pairs(C_AreaPoiInfo.GetAreaPOIForMap(uiMapID) or {}) do
            if not Save().areaPoiIDs[areaPoiID] and not tab[areaPoiID] then
                local name, atlas, text= Get_areaPoiID_Text(uiMapID, areaPoiID)
                if name then
                    table.insert(allTable, {name=name, areaPoiID=areaPoiID, uiMapID=uiMapID, text=text, atlas=atlas})
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
        local btn = TrackButton.btn[index]
        if not btn then
            btn= WoWTools_ButtonMixin:Cbtn(TrackButton.Frame, {size={12,12}, icon='hdie'})
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
                if Save().textToDown then
                    if self.index==1 then
                        self:SetPoint('TOP', TrackButton, 'BOTTOM')
                    else
                        self:SetPoint('TOPRIGHT', TrackButton.btn[index-1].text, 'BOTTOMLEFT')
                    end
                    self.text:SetPoint('TOPLEFT', self.nameText, 'BOTTOMLEFT')
                else
                    if index==1 then
                        self:SetPoint('BOTTOM', TrackButton, 'TOP')
                    else
                        self:SetPoint('BOTTOMRIGHT', TrackButton.btn[index-1].text, 'TOPLEFT')
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
                e.tips:Hide()
                TrackButton:SetButtonState('NORMAL')
                self.nameText:SetAlpha(1)
                self.text:SetAlpha(1)
            end)
            btn:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self.nameText or self.text or self, "ANCHOR_RIGHT")
                e.tips:ClearLines()

                WoWTools_TooltipMixin:set_tooltip(e.tips, {
                    questID= self.questID,
                    rewardQuestID=self.rewardQuestID,
                    vignetteGUID= self.vignetteGUID,
                    uiMapID= self.uiMapID,
                    areaPoiID= self.areaPoiID,

                    frame=self,
                })
                
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(self.name and self.name~='' and '|A:communities-icon-chat:0:0|a'..(e.onlyChinese and '信息' or INFO) or ' ', e.Icon.left)
                e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU , e.Icon.right)

                e.tips:Show()
                TrackButton:SetButtonState('PUSHED')
                self.nameText:SetAlpha(0.5)
                self.text:SetAlpha(0.5)
            end)


            btn:set_btn_point()

            TrackButton.btn[index]=btn
        end

        btn:set_rest(info)
    end

    for i= #allTable+1, #TrackButton.btn do
        TrackButton.btn[i]:set_rest({})
    end
end
























local function Init_Menu(self, root)--菜单
    local sub, sub2, sub3, col
--显示
    root:CreateCheckbox(
        e.onlyChinese and '显示' or SHOW,
    function()
        return Save().vigentteButtonShowText
    end, function()
        Save().vigentteButtonShowText= not Save().vigentteButtonShowText and true or nil
        self:set_Shown()
        self:set_Texture()
    end)

--当前
    root:CreateDivider()
    sub=root:CreateCheckbox(
        (e.onlyChinese and '当前' or REFORGE_CURRENT)..(Save().vigentteSound and '|A:chatframe-button-icon-voicechat:0:0|a' or ' ')..'Vignette',
    function()
        return not Save().hideVigentteCurrent
    end, function()
        Save().hideVigentteCurrent= not Save().hideVigentteCurrent and true or nil
    end)

--小地图
    sub:CreateCheckbox(
        (e.onlyChinese and '小地图' or HUD_EDIT_MODE_MINIMAP_LABEL),
    function()
        return not Save().hideVigentteCurrentOnMinimap
    end, function()
        Save().hideVigentteCurrentOnMinimap= not Save().hideVigentteCurrentOnMinimap and true or nil
    end)

   
--世界地图
    sub:CreateCheckbox(
        (e.onlyChinese and '世界地图' or WORLDMAP_BUTTON),
    function()
        return not Save().hideVigentteCurrentOnWorldMap
    end, function()
        Save().hideVigentteCurrentOnWorldMap= not Save().hideVigentteCurrentOnWorldMap and true or nil
    end)

--播放声音
    sub:CreateCheckbox(
        '|A:chatframe-button-icon-voicechat:0:0|a'
        ..(Save().hideVigentteCurrentOnWorldMap and '|cff9e9e9e' or '')
        ..(e.onlyChinese and '播放声音' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, EVENTTRACE_BUTTON_PLAY, SOUND)),
    function()
        return Save().vigentteSound
    end, function()
        Save().vigentteSound= not Save().vigentteSound and true or nil
        if not Save().hideVigentteCurrentOnWorldMap then
            self:set_VIGNETTES_UPDATED(true)
            self:set_Event()
            if Save().vigentteSound then
                self:speak_Text(e.onlyChinese and '播放声音' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, EVENTTRACE_BUTTON_PLAY, SOUND))
            end
        end
    end)

--世界任务
    local num=0
    for questID in pairs(Save().questIDs) do
        num= num+1
        e.LoadDate({id=questID, type=='quest'})
    end
    sub=root:CreateButton(
        (e.onlyChinese and '世界任务' or TRACKER_HEADER_WORLD_QUESTS)
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
            print(e.addName, addName, addName2, WoWTools_QuestMixin:GetLink(data.questID))
        end, {questID=questID})
        sub2:SetTooltip(function(tooltip)
            tooltip:AddLine(e.onlyChinese and '移除' or REMOVE)
        end)
    end

    WoWTools_MenuMixin:SetNumButton(sub, num)
    if num>1 then
        sub:CreateDivider()
        sub:CreateButton(
            e.onlyChinese and '全部清除' or CLEAR_ALL,
        function()
            Save().questIDs={}
        end)
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
        sub2:SetTooltip(function(tooltip)
            tooltip:AddLine(e.onlyChinese and '移除' or REMOVE)
        end)
    end
  
    WoWTools_MenuMixin:SetNumButton(sub, num)
    if num>1 then
        sub:CreateDivider()
        sub:CreateButton(
            e.onlyChinese and '全部清除' or CLEAR_ALL,
        function()
            Save().questIDs={}
        end)
    end

--地图
    num=0
    for _ in pairs(Save().uiMapIDs) do
        num= num+1
    end
    sub=root:CreateButton(
        (e.onlyChinese and '地图' or WORLD_MAP)..'|cnGREEN_FONT_COLOR:#'..num,
    function()
        return MenuResponse.Open
    end)

    for uiMapID in pairs(Save().uiMapIDs) do
        sub2=sub:CreateCheckbox(
            (C_Map.GetMapInfo(uiMapID) or {}).name or uiMapID,
        function(data)
            return Save().uiMapIDs[data.uiMapID]
        end, function(data)
            Save().uiMapIDs[data.uiMapID]= not Save().uiMapIDs[data.uiMapID] and true or nil
        end, {uiMapID=uiMapID})
        sub2:SetTooltip(function(tooltip)
            tooltip:AddLine(e.onlyChinese and '移除' or REMOVE)
        end)
    end
  
    WoWTools_MenuMixin:SetNumButton(sub, num)
    if num>1 then
        sub:CreateDivider()
        sub:CreateButton(
            e.onlyChinese and '全部清除' or CLEAR_ALL,
        function()
            Save().uiMapIDs={}
        end)
    end


--设置
    root:CreateDivider()
    sub=root:CreateButton(
        e.onlyChinese and '设置' or SETTINGS,
    function()
        return MenuResponse.Open
    end)

    sub:CreateCheckbox(
        e.onlyChinese and '向下滚动' or COMBAT_TEXT_SCROLL_DOWN,
    function()
        return Save().textToDown
    end, function()
        Save().textToDown= not Save().textToDown and true or nil
        for _, btn in pairs(TrackButton.btn) do
            btn:ClearAllPoints()
            btn.text:ClearAllPoints()
            btn:set_btn_point()
        end
    end)

end








--[[
local function Init_Button_Menu(_, level, menuList)--菜单
    local info
    if menuList=='CurrentVignette' then--当前 Vingnette
        info={
            text=e.onlyChinese and '小地图' or HUD_EDIT_MODE_MINIMAP_LABEL,
            checked= not Save().hideVigentteCurrentOnMinimap,
            func= function()
                Save().hideVigentteCurrentOnMinimap= not Save().hideVigentteCurrentOnMinimap and true or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        info={
            text=e.onlyChinese and '世界地图' or WORLDMAP_BUTTON,
            checked= not Save().hideVigentteCurrentOnWorldMap,
            func= function()
                Save().hideVigentteCurrentOnWorldMap= not Save().hideVigentteCurrentOnWorldMap and true or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '播放声音' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, EVENTTRACE_BUTTON_PLAY, SOUND),
            icon= 'chatframe-button-icon-voicechat',
            checked= Save().vigentteSound,
            disabled= Save().hideVigentteCurrentOnWorldMap,
            func= function()
                Save().vigentteSound= not Save().vigentteSound and true or nil
                TrackButton:set_VIGNETTES_UPDATED(true)
                TrackButton:set_Event()
                if Save().vigentteSound then
                    TrackButton:speak_Text(e.onlyChinese and '播放声音' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, EVENTTRACE_BUTTON_PLAY, SOUND))
                end
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)


    elseif menuList=='WorldQuest' then--世界任务
        for questID, _ in pairs(Save().questIDs) do
            e.LoadDate({id= questID, type=='quest'})
            info={
                text= GetQuestLink(questID) or questID,
                icon= select(2, GetQuestLogRewardInfo(1, questID))
                     or (C_QuestLog.GetQuestRewardCurrencyInfo(questID, 1, false) or {}).texture--select(2, GetQuestLogRewardCurrencyInfo(1, questID))
                     or 'AutoQuest-Badge-Campaign',
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle= (e.onlyChinese and '移除' or REMOVE)..' '..questID,
                arg1= questID,
                func= function(_, arg1)
                    Save().questIDs[arg1]=nil
                    print(e.addName, addName, addName2, GetQuestLink(questID) or questID,
                    '|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a'
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
                Save().questIDs={}
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif menuList=='AreaPoiID' then--AreaPoiID
        for areaPoiID, uiMapID in pairs(Save().areaPoiIDs) do
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
                    Save().areaPoiIDs[arg1]=nil
                    print(e.addName,addName, addName2,
                        get_AreaPOIInfo_Name(C_AreaPoiInfo.GetAreaPOIInfo(arg2, arg1) or {}),
                        arg1 and 'areaPoiID '..arg1 or '',
                        ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a')
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
                Save().areaPoiIDs={}
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif menuList=='uiMapIDs' then--地图
        for uiMapID, _ in pairs(Save().uiMapIDs) do
            local name=  (C_Map.GetMapInfo(uiMapID) or {}).name
            name= name or uiMapID
            info={
                text= name,
                icon= 'poi-islands-table',
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle= (e.onlyChinese and '移除' or REMOVE)..' '..uiMapID,
                arg1= uiMapID,
                func= function(_, arg1)
                    Save().uiMapIDs[arg1]=nil
                    print(e.addName,addName, addName2,
                    (C_Map.GetMapInfo(uiMapID) or {}).name,
                    arg1 and 'uiMapID '..arg1 or '',
                    ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a')
                )
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '当前地图' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REFORGE_CURRENT, WORLD_MAP),
            checked= Save().currentMapAreaPoiIDs,
            tooltipOnButton= true,
            tooltipTitle= C_Map.GetBestMapForUnit("player"),
            func= function()
                Save().currentMapAreaPoiIDs= not Save().currentMapAreaPoiIDs and true or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        info={
            text= e.onlyChinese and '全部清除' or CLEAR_ALL,
            notCheckable=true,
            func= function()
                Save().uiMapIDs={}
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif menuList=='AreaPoiID' then--AreaPoiID
        for areaPoiID, uiMapID in pairs(Save().areaPoiIDs) do
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
                    Save().areaPoiIDs[arg1]=nil
                    print(e.addName,addName, addName2,
                        get_AreaPOIInfo_Name(C_AreaPoiInfo.GetAreaPOIInfo(arg2, arg1) or {})
                        'areaPoiID '..arg1,
                        ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a')
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
                Save().areaPoiIDs={}
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif menuList=='SETTINGS' then
        info={
            text= e.onlyChinese and '向下滚动' or COMBAT_TEXT_SCROLL_DOWN,
            checked= Save().textToDown,
            func= function()
                Save().textToDown= not Save().textToDown and true or nil
                for _, btn in pairs(TrackButton.btn) do
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
            disabled= not TrackButton,
            colorCode= not Save().pointVigentteButton and '|cff9e9e9e' or '',
            func= function()
                Save().pointVigentteButton=nil
                TrackButton:ClearAllPoints()
                TrackButton:Set_Point()
                print(e.addName, addName, e.onlyChinese and '重置位置' or RESET_POSITION)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    end

    if menuList then
        return
    end


    info={
        text= e.onlyChinese and '显示' or SHOW,
        checked= Save().vigentteButtonShowText,
        keepShownOnClick=true,
        func= function()
            Save().vigentteButtonShowText= not Save().vigentteButtonShowText and true or nil
            TrackButton:set_Shown()
            TrackButton:set_Texture()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)


    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= (e.onlyChinese and '当前' or REFORGE_CURRENT)..(Save().vigentteSound and '|A:chatframe-button-icon-voicechat:0:0|a' or ' ')..'Vignette',
        menuList='CurrentVignette',
        hasArrow=true,
        notCheckable=true,
        func= function()
            Save().hideVigentteCurrent= not Save().hideVigentteCurrent and true or nil
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    local num=0
    for _ in pairs(Save().questIDs) do
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
    for _ in pairs(Save().areaPoiIDs) do
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
    for _, _ in pairs(Save().uiMapIDs) do--地图
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

]]


















--小地图, 标记, 文本
local function Init_Button()
    --TrackButton= WoWTools_ButtonMixin:Cbtn(nil, {icon=true, size={18,18}, isType2=true, name='WoWTools_Minimap_TrackButton'})
    TrackButton= WoWTools_ButtonMixin:Cbtn(nil, {icon='hide', isType2=true, name='WoWTools_Minimap_TrackButton'})
    TrackButton.btn={}

    TrackButton.Frame= CreateFrame('Frame', nil, TrackButton)
    TrackButton.Frame:SetAllPoints(TrackButton)

    TrackButton.texture= TrackButton:CreateTexture(nil, 'BORDER')
    TrackButton.texture:SetAllPoints(TrackButton)
    TrackButton.texture:SetAlpha(0.5)





    function TrackButton:set_Texture()
        if Save().vigentteButtonShowText then
            self.texture:SetTexture(0)
        else
            self.texture:SetAtlas('VignetteKillElite')
        end
    end

    function TrackButton:Set_Point()--设置，位置
        if Save().pointVigentteButton then
            self:SetPoint(Save().pointVigentteButton[1], UIParent, Save().pointVigentteButton[3], Save().pointVigentteButton[4], Save().pointVigentteButton[5])
        elseif e.Player.husandro then
            self:SetPoint('TOPLEFT', 300, 0)
        else
            self:SetPoint('BOTTOMLEFT', QuickJoinToastButton, 'TOPLEFT', 4, 2)
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
                self:set_Shown()
                self:set_Texture()

            elseif d=='RightButton' and not key then
                MenuUtil.CreateContextMenu(self, Init_Menu)
            end
        end
    end)



    

    function TrackButton:set_Tootips()
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(addName, addName2)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.GetShowHide(nil, true), e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '主菜单' or MAINMENU_BUTTON, e.Icon.right)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' '..(Save().vigentteButtonTextScale), 'Alt+'..e.Icon.mid)
        e.tips:Show()
    end

    TrackButton:SetScript('OnMouseWheel', function(self, d)--缩放
        if IsAltKeyDown() then
            local scale= Save().vigentteButtonTextScale or 1
            if d==1 then
                scale= scale- 0.05
            elseif d==-1 then
                scale= scale+ 0.05
            end
            scale= scale>2.5 and 2.5  or scale
            scale= scale<0.4 and 0.4 or scale
            print(e.addName, addName, e.onlyChinese and '缩放' or UI_SCALE, scale)
            Save().vigentteButtonTextScale= scale
            self:set_Frame_Scale()--设置，Button的 Frame Text 属性
            self:set_Tootips()
        end
    end)

    TrackButton:SetScript('OnEnter',function(self)
        self:set_Tootips()
        self.texture:SetAlpha(1)
    end)
    TrackButton:SetScript('OnLeave',function(self)
        e.tips:Hide()
        ResetCursor()
        self.texture:SetAlpha(0.5)
    end)









    --播放声音
    function TrackButton:speak_Text(text)
        local ttsVoices= C_VoiceChat.GetTtsVoices() or {}
        local voiceID= ttsVoices.voiceID or C_TTSSettings.GetVoiceOptionID(Enum.TtsVoiceType.Standard)
        local destination= ttsVoices.voiceID and Enum.VoiceTtsDestination.QueuedLocalPlayback or Enum.VoiceTtsDestination.LocalPlayback
        --C_VoiceChat.SpeakText(voiceID, text, destination, rate, volume)
        C_VoiceChat.SpeakText(voiceID, text, destination, 0, 100)
        print(e.addName, addName2,'|cffff00ff', text)
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


    function TrackButton:set_Shown()
        local hide= not Save().vigentteButton
            or IsInInstance()
            or C_PetBattles.IsInBattle()
            or UnitInVehicle('player')
            or UnitAffectingCombat('player')

            or WorldMapFrame:IsShown()

        TrackButton:SetShown(not hide)
        TrackButton.Frame:SetShown(Save().vigentteButtonShowText and not hide)
    end


    function TrackButton:set_Event()
        self:UnregisterAllEvents()

        self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
        self:RegisterEvent('PLAYER_ENTERING_WORLD')

        if Save().vigentteButton and not IsInInstance() then
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
            self:set_Event()
            self:set_Shown()
        elseif event=='VIGNETTES_UPDATED' then
            self:set_VIGNETTES_UPDATED()
        else--PLAYER_REGEN_DISABLED PLAYER_REGEN_ENABLED
            self:set_Shown()
        end
    end)



    






    function TrackButton:set_Frame_Scale()--设置，Button的 Frame Text 属性
        self.Frame:SetScale(Save().vigentteButtonTextScale or 1)
    end

    WorldMapFrame:HookScript('OnHide', function() TrackButton:set_Shown() end)
    WorldMapFrame:HookScript('OnShow', function() TrackButton:set_Shown() end)

    TrackButton.Frame:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 1) + elapsed
        if self.elapsed>=1 then
            self.elapsed=0
            set_Button_Text()
        end
    end)

    TrackButton:set_VIGNETTES_UPDATED(true)
    TrackButton:Set_Point()
    TrackButton:set_Texture()
    TrackButton:set_Frame_Scale()
    TrackButton:set_Event()
    TrackButton:set_Shown()

end























--世界地图，添加一个按钮
local function Init_WorldFrame_Button()
    WorldMapButton= WoWTools_ButtonMixin:Cbtn(WorldMapFrame, {size={20,20}, icon='hide', name='WoWTools_Minimap_WorldTrackButton'})
    function WorldMapButton:set_texture()
        local uiMapID= WorldMapFrame.mapID or WorldMapFrame:GetMapID("current")
        if not uiMapID then
            self:SetNormalTexture(0)
        else
            self:SetNormalAtlas(Save().uiMapIDs[uiMapID] and e.Icon.select or 'VignetteKillElite')
        end
    end
    WorldMapButton:SetPoint('TOPRIGHT', WorldMapFramePortrait, 'BOTTOMRIGHT', 2, 10)
    WorldMapButton:SetScript('OnClick', function(self)
        local uiMapID= WorldMapFrame.mapID or WorldMapFrame:GetMapID("current")
        if uiMapID then
            Save().uiMapIDs[uiMapID]= not Save().uiMapIDs[uiMapID] and true or nil
            local name= (C_Map.GetMapInfo(uiMapID) or {}).name or ('uiMapID '..uiMapID)
            print(e.addName, addName, addName2,
                name,
                Save().uiMapIDs[uiMapID] and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', e.Icon.select) or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a')
            )
            self:set_texture()
        end
    end)
    WorldMapButton:SetScript('OnShow', WorldMapButton.set_texture)
    WorldMapButton:SetScript('OnLeave', GameTooltip_Hide)
    WorldMapButton:SetScript('OnEnter', function(self)
        local uiMapID= WorldMapFrame.mapID or WorldMapFrame:GetMapID("current")
        if uiMapID then
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(addName2..(Save().uiMapIDs[uiMapID] and format('|A:%s:0:0|a', e.Icon.select) or ''), ((C_Map.GetMapInfo(uiMapID) or {}).name or '')..' '..uiMapID)
            e.tips:AddDoubleLine(e.addName, addName)
            e.tips:Show()
        end
    end)
    hooksecurefunc(WorldMapFrame, 'OnMapChanged', function() WorldMapButton:set_texture() end)--uiMapIDs, 添加，移除 --Blizzard_WorldMap.lua
end

















--世界地图，事件
local function Init_WorldFrame_Event()
    hooksecurefunc('TaskPOI_OnEnter', function(self)--世界任务，提示 WorldMapFrame.lua
        if self.questID and self.OnMouseClickAction then
            e.tips:AddDoubleLine(addName2..(Save().questIDs[self.questID] and format('|A:%s:0:0|a', e.Icon.select) or ''), 'Alt+'..e.Icon.left)
            e.tips:Show()
        end
    end)
    hooksecurefunc(WorldQuestPinMixin, 'RefreshVisuals', function(self)--世界任务，添加/移除 WorldQuestDataProvider.lua self.tagInfo
        if not self.OnMouseClickAction or self.setTracking then
            return
        end
        hooksecurefunc(self, 'OnMouseClickAction', function(self, d)
            if self.questID and d=='LeftButton' and IsAltKeyDown() then
                Save().questIDs[self.questID]= not Save().questIDs[self.questID] and true or nil
                print(e.addName,addName, addName2,
                    GetQuestLink(self.questID) or self.questID,
                    Save().questIDs[self.questID] and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', e.Icon.select) or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a')
                )
            end
        end)
        self.setTracking=true
    end)

    hooksecurefunc(AreaPOIPinMixin,'TryShowTooltip', function(self)--areaPoiID,提示 AreaPOIDataProvider.lua
        if self.areaPoiID and  self:GetMap() and self:GetMap():GetMapID() then
            e.tips:AddDoubleLine(addName2..(Save().areaPoiIDs[self.areaPoiID] and format('|A:%s:0:0|a', e.Icon.select) or ''), 'Alt+'..e.Icon.left)
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
                    Save().areaPoiIDs[self.areaPoiID]= not Save().areaPoiIDs[self.areaPoiID] and uiMapID or nil
                    local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, self.areaPoiID) or {}
                    local name= get_AreaPOIInfo_Name(poiInfo)--取得 areaPoiID 名称
                    name= name=='' and 'areaPoiID '..self.areaPoiID or name
                    print(e.addName,addName, addName2,
                        (C_Map.GetMapInfo(uiMapID) or {}).name or ('uiMapID '..uiMapID),
                        name,
                        Save().areaPoiIDs[self.areaPoiID] and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', e.Icon.select) or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a')
                    )
                end
            end
        end)
        self.setTracking=true
    end)

end
















function WoWTools_MinimapMixin:Init_TrackButton()--小地图, 标记, 文本

    if not Save().vigentteButton or TrackButton then
        if TrackButton then
            TrackButton:set_Shown()
        end
        return
    end
    addName= self.adddName
    addName2= self.addName2

    Init_Button()--小地图, 标记, 文本
    Init_WorldFrame_Button()--世界地图，添加一个按钮
    Init_WorldFrame_Event()--世界地图，事件
end

