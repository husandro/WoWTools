local id, e = ...
if (e.Player.region~=3 and not e.Is_PTR) or LOCALE_zhCN or LOCALE_zhTW then
    return
end



--[[
1	self:AddOverlayFrame("WorldMapFloorNavigationFrameTemplate", "FRAME", "TOPLEFT", self:GetCanvasContainer(), "TOPLEFT", -15, 2)

	if C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.WorldMapTrackingOptions) then
2		self:AddOverlayFrame("WorldMapTrackingOptionsButtonTemplate", "DROPDOWNTOGGLEBUTTON", "TOPRIGHT", self:GetCanvasContainer(), "TOPRIGHT", -4, -2)
	end

	if C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.WorldMapTrackingPin) then
3		self:AddOverlayFrame("WorldMapTrackingPinButtonTemplate", "BUTTON", "TOPRIGHT", self:GetCanvasContainer(), "TOPRIGHT", -36, -2)
	end

4	self:AddOverlayFrame("WorldMapBountyBoardTemplate", "FRAME", nil, self:GetCanvasContainer())
5	self:AddOverlayFrame("WorldMapActionButtonTemplate", "FRAME", nil, self:GetCanvasContainer())
6	self:AddOverlayFrame("WorldMapZoneTimerTemplate", "FRAME", "BOTTOM", self:GetCanvasContainer(), "BOTTOM", 0, 20)
7	self:AddOverlayFrame("WorldMapThreatFrameTemplate", "FRAME", "BOTTOMLEFT", self:GetCanvasContainer(), "BOTTOMLEFT", 0, 0)
8	self:AddOverlayFrame("WorldMapActivityTrackerTemplate", "BUTTON", "BOTTOMLEFT", self:GetCanvasContainer(), "BOTTOMLEFT", 0, 0)--WorldMapBountyBoard.lua

]]

local function Init_overlayFrames()--WorldMapMixin:AddOverlayFrames()    
    local index=1
    local btn
    local isTracking= C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.WorldMapTrackingOptions)
    if isTracking then
        index=index+1
        local optionButton=WorldMapFrame.overlayFrames[index]
        if optionButton then
            optionButton:HookScript('OnEnter', function()
                GameTooltip_SetTitle(GameTooltip, '地图筛选')
                GameTooltip:Show()
            end)
        end
    end

    local isPin= C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.WorldMapTrackingPin)
    if isPin then
        index=index+1
        btn= WorldMapFrame.overlayFrames[index]
        if btn then
            btn:HookScript('OnEnter', function(self)
                GameTooltip_SetTitle(GameTooltip, '地图标记')--WorldMapTrackingPinButtonMixin:OnEnter()
                local mapID = self:GetParent():GetMapID()
                if C_Map.CanSetUserWaypointOnMap(mapID) then
                    GameTooltip_AddNormalLine(GameTooltip, '在地图上放置一个位置标记，此标记可以追踪，也可以分享给其他玩家。')
                    GameTooltip_AddBlankLineToTooltip(GameTooltip)
                    GameTooltip_AddInstructionLine(GameTooltip, '点击这个按钮，然后在地图上点击来放置一个标记，或者直接<按住Ctrl点击地图>。')
                else
                    GameTooltip_AddErrorLine(GameTooltip, '你不能在这张地图上放置标记。')-- heheheha

                end
                GameTooltip:Show()
            end)
        end
    end
 
    index=index+4
    --[[btn=  WorldMapFrame.overlayFrames[index]
    if btn then
        btn:HookScript('OnEnter', function()
            GameTooltip_SetTitle(GameTooltip, '恩佐斯突袭')
            GameTooltip_AddColoredLine(GameTooltip, '点击浏览被恩佐斯的军队突袭的地区。', GREEN_FONT_COLOR)
            GameTooltip:Show()
        end)
    end]]

   index=index+1
    btn= WorldMapFrame.overlayFrames[index]
    if btn then
        hooksecurefunc(btn, 'ShowMapJumpTooltip', function(self)
            local factionName = (C_Reputation.GetFactionDataByID(self.selectedBounty.factionID) or {}).name
            if factionName then
                GameTooltip_SetTitle(GameTooltip, factionName)                
                GameTooltip_AddInstructionLine(GameTooltip, "<左键点击在可用活动间轮换>|n<右键点击取消追踪阵营>", false)
                GameTooltip:Show()
            end
        end)
    end
end











--[[local function set(label, text)
    text= e.strText[text]
    if label and text and text~='' then--CanAccessObject(self) then
        label:SetText(text)
    end
end]]
local function setLabel(label)
    local text= label and e.strText[label:GetText()]
    if text then
        label:SetText(text)
    end
end
local function setFont(label)
    if label then
        local _, size, fontFlag= label:GetFont()
        label:SetFont('Fonts\\ARHei.ttf', size, fontFlag or 'OUTLINE')
    end
end
local function setRegion(frame)
    for _, region in pairs({frame:GetRegions()}) do
        if region:GetObjectType()=='FontString' then--reg(QuestMapFrame.DetailsFrame.RewardsFrame, '奖励')
            setLabel(region)
        end
    end
end

local function Init()
    Init_overlayFrames()

    --飞行地图，地图名称
    hooksecurefunc(ZoneLabelDataProviderMixin, 'EvaluateBestAreaTrigger', function(self)
        local label= self.ZoneLabel and self.ZoneLabel.Text
        local name= label and e.strText[label:GetText()]
        if name then
            label:SetText(name)
        end        
    end)

    QuestMapFrame.DetailsFrame.BackButton:SetText('返回')
    QuestMapFrame.DetailsFrame.AbandonButton:SetText('放弃')

   hooksecurefunc('QuestMapFrame_UpdateQuestDetailsButtons', function()
        local questID = C_QuestLog.GetSelectedQuest()
        local isWatched = QuestUtils_IsQuestWatched(questID)
        if isWatched then
            QuestMapFrame.DetailsFrame.TrackButton:SetText('取消追踪')
            QuestLogPopupDetailFrame.TrackButton:SetText('取消追踪')
        else
            QuestMapFrame.DetailsFrame.TrackButton:SetText('追踪')
            QuestLogPopupDetailFrame.TrackButton:SetText('追踪')
        end
    end)

    QuestMapFrame.DetailsFrame.ShareButton:SetText('共享')
    QuestMapFrame.DetailsFrame.DestinationMapButton.tooltipText= '显示最终目的地'
    QuestMapFrame.DetailsFrame.WaypointMapButton.tooltipText= '显示旅行路径'

    setRegion(QuestMapFrame.DetailsFrame.RewardsFrame)
     
    
    MapQuestInfoRewardsFrame.ItemChooseText:SetText('你可以从这些奖励品中选择一件：')
    MapQuestInfoRewardsFrame.PlayerTitleText:SetText('新头衔： %s')
    MapQuestInfoRewardsFrame.QuestSessionBonusReward:SetText('在小队同步状态下完成此任务有可能获得奖励：')
    QuestInfoRequiredMoneyText:SetText('需要金钱：')
    QuestInfoRewardsFrame.ItemChooseText:SetText('你可以从这些奖励品中选择一件：')
    QuestInfoRewardsFrame.PlayerTitleText:SetText('新头衔： %s')
    QuestInfoRewardsFrame.QuestSessionBonusReward:SetText('在小队同步状态下完成此任务有可能获得奖励：')


    hooksecurefunc(WorldMapFrame, 'SetupTitle', function(self)
        self.BorderFrame:SetTitle('地图和任务日志')
    end)
    hooksecurefunc(WorldMapFrame, 'SynchronizeDisplayState', function(self)
        if self:IsMaximized() then
            self.BorderFrame:SetTitle('地图')
        else
            self.BorderFrame:SetTitle('地图和任务日志')
        end
    end)
    setFont(WorldMapFrameHomeButtonText)
    WorldMapFrameHomeButtonText:SetText('世界')
    
    
end





--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, _, arg1)
    if arg1==id then
        if not e.disbledCN then
            Init()
        else
        end
        self:UnregisterAllEvents()
    end
end)