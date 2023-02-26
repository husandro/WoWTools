local id, e = ...
local addName= HUD_EDIT_MODE_MINIMAP_LABEL
local Save={scale=0.85, ZoomOut=true, vigentteButton=e.Player.husandro, vigentteButtonShowText=true }
local panel=CreateFrame("Frame")

local function set_ZoomOut()--更新地区时,缩小化地图
    if Save.ZoomOut then
        local value= Minimap:GetZoomLevels()
        if value~=0 then
            Minimap:SetZoom(0)
        end
    end
end

local function set_minimapTrackingShowAll()--追踪,镇民
    if Save.minimapTrackingShowAll~=nil then
        C_CVar.SetCVar('minimapTrackingShowAll', not Save.minimapTrackingShowAll and '0' or '1' )
    end
end

--####
--缩放
--####
local function set_MinimapCluster()--缩放
    local frame=MinimapCluster
    local function set_Minimap_Zoom(d)
        local scale = Save.scale or 1
        if d==1 then
            scale= scale-0.05
        elseif d==-1 then
            scale= scale+0.05
        end
        scale= scale>2 and 2 or scale<0.4 and 0.4 or scale
        frame:SetScale(scale)
        Save.scale=scale
        print(id, addName, e.onlyChinse and '缩放' or UI_SCALE, '|cnGREEN_FONT_COLOR:'..scale)
    end
    --[[Minimap:SetScript('OnMouseWheel', function(self, d)--Minimap.lua
        if IsAltKeyDown() then
            set_Minimap_Zoom(d)
        else
            if d > 0 then
                Minimap_ZoomIn();
            elseif d < 0 then
                Minimap_ZoomOut();
            end
        end
    end)]]

    frame.ScaleIn=e.Cbtn(Minimap, nil, nil, nil, nil, true, {20,20})
    frame.ScaleIn:SetPoint('TOP',-2, 13)
    frame.ScaleIn:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' then
            SetCursor('UI_MOVE_CURSOR')
        else
            set_Minimap_Zoom(1)
        end
    end)
    frame.ScaleIn:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(e.onlyChinse and '缩放' or UI_SCALE, (e.onlyChinse and '缩小' or ZOOM_OUT)..(Save.scale or 1)..e.Icon.left)
        
        e.tips:AddDoubleLine(e.onlyChinse and '移动' or NPE_MOVE, e.Icon.right)
        e.tips:Show()
    end)
    frame.ScaleIn:SetScript('OnLeave', function() e.tips:Hide() ResetCursor() end)
    frame.ScaleIn:SetScript('OnMouseUp', function() ResetCursor() end)

    frame.ScaleOut=e.Cbtn(Minimap, nil, nil, nil, nil, true, {20,20})
    frame.ScaleOut:SetPoint('BOTTOM', -1, -13)
    frame.ScaleOut:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' then
            SetCursor('UI_MOVE_CURSOR')
        else
            set_Minimap_Zoom(-1)
        end
    end)
    frame.ScaleOut:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(e.onlyChinse and '缩放' or UI_SCALE,(e.onlyChinse and '放大' or ZOOM_IN)..(Save.scale or 1)..e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinse and '移动' or NPE_MOVE, e.Icon.right)
        e.tips:Show()
    end)
    frame.ScaleOut:SetScript('OnLeave', function() e.tips:Hide() ResetCursor() end)
    frame.ScaleOut:SetScript('OnMouseUp', function() ResetCursor() end)
    if Save.scale and Save.scale~=1 then
        frame:SetScale(Save.scale)
    end

    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame.ScaleIn:RegisterForDrag("RightButton")
    frame.ScaleIn:SetScript("OnDragStart", function()
        frame:StartMoving()
    end)
    frame.ScaleIn:SetScript("OnDragStop", function()
        ResetCursor()
        frame:StopMovingOrSizing()
    end)

    frame.ScaleOut:RegisterForDrag("RightButton")
    frame.ScaleOut:SetScript("OnDragStart", function()
        frame:StartMoving()
    end)
    frame.ScaleOut:SetScript("OnDragStop", function()
        ResetCursor()
        frame:StopMovingOrSizing()
    end)

end


--#######
--盟约图标
--#######
local function set_ExpansionLandingPageMinimapButton()
    if not ExpansionLandingPageMinimapButton then
        return
    end
    local OpenWR=function()
        if not WeeklyRewardsFrame then
            return
        end
        if WeeklyRewardsFrame:IsShown() then
            HideUIPanel(WeeklyRewardsFrame)
        else
            WeeklyRewardsFrame:Show()
            tinsert(UISpecialFrames, WeeklyRewardsFrame:GetName())
        end
    end
    ExpansionLandingPageMinimapButton:SetScale(0.6)--透明度
    ExpansionLandingPageMinimapButton:SetFrameStrata('TOOLTIP')
    ExpansionLandingPageMinimapButton:SetMovable(true)--移动
    ExpansionLandingPageMinimapButton:RegisterForDrag("RightButton")
    ExpansionLandingPageMinimapButton:SetClampedToScreen(true)
    ExpansionLandingPageMinimapButton:SetScript("OnDragStart", function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    ExpansionLandingPageMinimapButton:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
    ExpansionLandingPageMinimapButton:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and not IsModifierKeyDown() then--周奖励面板
            if not WeeklyRewardsFrame then
                LoadAddOn("Blizzard_WeeklyRewards")
            end
            OpenWR()
        end
    end)
    ExpansionLandingPageMinimapButton:SetScript('OnEnter',function(self)
        self:SetAlpha(1)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinse and '宏伟宝库' or RATED_PVP_WEEKLY_VAULT , e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinse and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
    end)
    ExpansionLandingPageMinimapButton:SetScript('OnLeave', function(self)
        e.tips:Hide()
        self:SetAlpha(0.3)
    end)

    C_Timer.After(8, function()--盟约图标停止闪烁
        ExpansionLandingPageMinimapButton.MinimapLoopPulseAnim:Stop()
        ExpansionLandingPageMinimapButton:SetAlpha(0.3)
    end)
end

--#################
--小地图, 标记, 文本
--#################
local function set_vigentteButton_Event()
    if Save.vigentteButton and Save.vigentteButtonShowText and not IsInInstance() then
        panel.vigentteButton:RegisterEvent('AREA_POIS_UPDATED')
        panel.vigentteButton:RegisterEvent('VIGNETTES_UPDATED')
        panel.vigentteButton:RegisterEvent('QUEST_DATA_LOAD_RESULT')
        panel.vigentteButton:RegisterEvent('QUEST_COMPLETE')
    else
        panel.vigentteButton:UnregisterAllEvents()
    end

    if Save.vigentteButton and Save.vigentteButtonShowText then
        panel.vigentteButton.text:SetText('')
    end
end

local uiMapIDsTab= {2026, 2025, 2024, 2023}--, 2022}--地图, areaPoiIDs
local questIDTab= {--世界任务, 监视, ID
    [74378]=true,
}
--[[local areaPoiIDTab={--不显示, areaPoiID
    [7239]=true,--元素入
    [7245]=true,
    [7248]=true,
    [7249]=true,
    [7255]=true,
    [7260]=true,
    
}]]
local function set_vigentteButton_Text()
    if not Save.vigentteButtonShowText then
        panel.vigentteButton.text:SetText('')
        return
    end

    local text
    if e.Player.level==70 then--世界任务, 监视
        for questID,_ in pairs(questIDTab) do
            if C_TaskQuest.IsActive(questID) then--世界任务
                if not HaveQuestRewardData(questID) then
                    C_TaskQuest.RequestPreloadRewardData(questID)
                else
                    local questName= C_TaskQuest.GetQuestInfoByQuestID(questID)
                    local itemTexture= select(2, GetQuestLogRewardInfo(1, questID))
                    if questName and itemTexture then
                        local secondsLeft = C_TaskQuest.GetQuestTimeLeftSeconds(questID)
                        local secText
                        if secondsLeft then
                            secText= SecondsToClock(secondsLeft, true)
                            secText= ' '..secText:gsub('：',':')
                            if secondsLeft<= 600 then
                                secText= '|cnGREEN_FONT_COLOR:'..secText..'|r'
                            end
                        end
                        text='|cffff8200'..questName..(secText or '')..'|T'..itemTexture..':0|t|r'
                    end
                end
            end
        end
    end

    local vignetteGUIDs=C_VignetteInfo.GetVignettes() or {}--当前
    for _, guid in pairs(vignetteGUIDs) do
        local info= C_VignetteInfo.GetVignetteInfo(guid)
        if info and info.atlasName and not info.isDead then
            if info.onMinimap then
                text= text and text..'\n' or ''
                text= text..(info.name and '|cnGREEN_FONT_COLOR:'..info.name..'|r' or '')..'|A:'..info.atlasName..':0:0|a'
            elseif info.onWorldMap then
                text= text and text..'\n' or ''
                text= text..(info.name and '|cffff00ff'..info.name..'|r' or '')..'|A:'..info.atlasName..':0:0|a'
            end
        end
    end

    for _, uiMapID in pairs(uiMapIDsTab) do
        local areaPoiIDs = C_AreaPoiInfo.GetAreaPOIForMap(uiMapID) or {}
        for _, areaPoiID in pairs(areaPoiIDs) do
            if areaPoiID and (areaPoiID<7234 or areaPoiID>7260) then--not areaPoiIDTab[areaPoiID] then--不显示, areaPoiID
                local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID)
                if poiInfo and poiInfo.name and poiInfo.atlasName and C_AreaPoiInfo.IsAreaPOITimed(areaPoiID) then

                    local secondsLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(areaPoiID)
                    if secondsLeft and secondsLeft>0 then
                        text= text and text..'\n' or ''
                        if poiInfo.widgetSetID then
                            local widgets = C_UIWidgetManager.GetAllWidgetsBySetID(poiInfo.widgetSetID) or {}
                            for _,widget in ipairs(widgets) do
                                if widget and widget.widgetID and  widget.widgetType==8 then
                                    local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(widget.widgetID)
                                    if widgetInfo and widgetInfo.shownState== 1  and widgetInfo.text then
                                        local icon, num= widgetInfo.text:match('(|T.-|t).+(%d+)')
                                        if icon and num then
                                            text= text..'|cff00ff00'..num..'|r'..icon
                                            break
                                        end
                                    end
                                end
                            end
                        end


                        text= text.. poiInfo.name
                        if poiInfo.factionID and C_Reputation.IsMajorFaction(poiInfo.factionID) then
                            local info = C_MajorFactions.GetMajorFactionData(poiInfo.factionID)
                            if info and info.textureKit then
                                text= text..'|A:MajorFactions_Icons_'..info.textureKit..'512:0:0|a'
                            else
                                text= text..' '
                            end
                        else
                            text= text..' '
                        end
                        local secText=SecondsToClock(secondsLeft,true)
                        secText= secText:gsub('：',':')
                        if secondsLeft<= 600 then
                            secText= '|cnGREEN_FONT_COLOR:'..secText..'|r'
                        end
                        text= text..secText
                        text= text..'|A:'..poiInfo.atlasName..':0:0|a'
                    end
                end
            end
        end
    end
    panel.vigentteButton.text:SetText(text or '..')
end

local function set_VIGNETTE_MINIMAP_UPDATED()--小地图, 标记, 文本
    if not Save.vigentteButton or IsInInstance() then
        if panel.vigentteButton then
            panel.vigentteButton.text:SetText('')
            panel.vigentteButton:SetShown(false)
            set_vigentteButton_Event()
        end
        return
    end
    if not panel.vigentteButton then
        panel.vigentteButton= e.Cbtn(nil, nil, nil, nil, nil, true,{15, 15})
        if Save.pointVigentteButton then
            panel.vigentteButton:SetPoint(Save.pointVigentteButton[1], UIParent, Save.pointVigentteButton[3], Save.pointVigentteButton[4], Save.pointVigentteButton[5])
        else
            --panel.vigentteButton:SetPoint('BOTTOMRIGHT', Minimap, 'BOTTOMLEFT', -10,5)
            panel.vigentteButton:SetPoint('CENTER', -330, -240)
        end
        if not Save.vigentteButtonShowText then
            panel.vigentteButton:SetNormalAtlas(e.Icon.disabled)
        end
        panel.vigentteButton:RegisterForDrag("RightButton")
        panel.vigentteButton:SetMovable(true)
        panel.vigentteButton:SetClampedToScreen(true)
        panel.vigentteButton:SetScript("OnDragStart", function(self,d)
            if d=='RightButton' and not IsModifierKeyDown() then
                self:StartMoving()
            end
        end)
        panel.vigentteButton:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            Save.pointVigentteButton={self:GetPoint(1)}
            Save.pointVigentteButton[2]=nil
            print(id, addName, 'Alt+'..e.Icon.right, e.onlyChinse and '还原位置' or RESET_POSITION)
        end)
        panel.vigentteButton:SetScript('OnMouseDown', function(self, d)
            local key= IsModifierKeyDown()
            if d=='LeftButton' and not key then
                Save.vigentteButtonShowText= not Save.vigentteButtonShowText and true or nil
                if Save.vigentteButtonShowText then
                    self:SetNormalTexture(0)
                else
                    self:SetNormalAtlas(e.Icon.disabled)
                end
                set_vigentteButton_Event()
                set_vigentteButton_Text()
            elseif d=='RightButton' and key then
                self:ClearAllPoints()
                --self:SetPoint('BOTTOMRIGHT', Minimap, 'BOTTOMLEFT', -10,5)
                panel.vigentteButton:SetPoint('CENTER', -330, -240)
                Save.pointVigentteButton=nil
            elseif d=='RightButton' and not key then
                SetCursor('UI_MOVE_CURSOR')
            end
        end)
        panel.vigentteButton:SetScript('OnMouseWheel', function(self, d)--缩放
            if IsAltKeyDown() then
                local size=Save.vigentteButtonSize or 12
                if d==1 then
                    size=size+1
                elseif d==-1 then
                    size=size-1
                end
                if size>36 then
                    size=36
                elseif size<8 then
                    size=8
                end
                print(id, addName, e.onlyChinse and '字体大小' or FONT_SIZE, size)
                Save.vigentteButtonSize= size
                e.Cstr(nil, size, nil, panel.vigentteButton.text, nil ,nil,'RIGHT')
            end
        end)
        panel.vigentteButton:SetScript('OnEnter',function(self)
            set_vigentteButton_Text()
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, addName)
            e.tips:AddDoubleLine(e.onlyChinse and '文本' or LOCALE_TEXT_LABEL, e.GetShowHide(Save.vigentteButtonShowText)..e.Icon.left)
            e.tips:AddDoubleLine(e.onlyChinse and '移动' or NPE_MOVE, e.Icon.right)
            e.tips:AddDoubleLine((e.onlyChinse and '字体大小' or FONT_SIZE)..': '..(Save.vigentteButtonSize or 12), 'Alt+'..e.Icon.mid)
            e.tips:Show()
        end)
        panel.vigentteButton:SetScript('OnLeave',function(self)
            e.tips:Hide()
            ResetCursor()
        end)
        panel.vigentteButton:SetScript("OnEvent", function(self, event, arg1, arg2)
            if event=='QUEST_DATA_LOAD_RESULT' and arg2 and questIDTab[arg1] then
                set_vigentteButton_Text()
            else
                set_vigentteButton_Text()
            end
        end)--更新事件

        panel.vigentteButton.text= e.Cstr(panel.vigentteButton, Save.vigentteButtonSize, nil, nil, nil,nil,'RIGHT')
        panel.vigentteButton.text:SetPoint('BOTTOMRIGHT')
    end
    panel.vigentteButton:SetShown(true)
    set_vigentteButton_Event()
    set_vigentteButton_Text()
end

--###############
--小地图, 添加菜单
--###############
local function set_MinimapMenu()--小地图, 添加菜单
    if not MinimapCluster or not MinimapCluster.Tracking or not MinimapCluster.Tracking.Button then
        return
    end
    MinimapCluster.Tracking.Button:HookScript( 'OnMouseDown', function()
        UIDropDownMenu_AddSeparator(1)
        local info={
            text=e.onlyChinse and '镇民' or TOWNSFOLK_TRACKING_TEXT,
            checked= C_CVar.GetCVarBool("minimapTrackingShowAll"),
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinse and '显示: 追踪' or SHOW..': '..TRACKING,
            tooltipText= id..' '..addName..'\n\nCVar minimapTrackingShowAll',
            func= function()
                Save.minimapTrackingShowAll= not C_CVar.GetCVarBool("minimapTrackingShowAll") and true or false
                set_minimapTrackingShowAll()--追踪,镇民
            end
        }
        UIDropDownMenu_AddButton(info, 1)

        info={
            text= e.onlyChinse and '缩小地图' or BINDING_NAME_MINIMAPZOOMOUT,
            icon='UI-HUD-Minimap-Zoom-Out',
            checked= Save.ZoomOut,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinse and '更新地区时' or UPDATE..ZONE,
            tooltipText= id..' '..addName,
            func= function()
                Save.ZoomOut= not Save.ZoomOut and true or nil
                set_ZoomOut()--更新地区时,缩小化地图
            end
        }
        UIDropDownMenu_AddButton(info, 1)

        local mapName=''
        for _, mapID in pairs(uiMapIDsTab) do
            local mapInfo=C_Map.GetMapInfo(mapID)
            if mapInfo and mapInfo.name then
                mapName= mapName..'\n'..mapInfo.name
            end
        end
        info={
            text= e.onlyChinse and '文本' or LOCALE_TEXT_LABEL,
            icon='MajorFactions_MapIcons_Tuskarr64',
            tooltipOnButton=true,
            tooltipTitle= id..'  '..addName,
            tooltipText= (e.onlyChinse and '小地图' or HUD_EDIT_MODE_MINIMAP_LABEL)..mapName,
            checked= Save.vigentteButton,
            disabled= IsInInstance(),
            func= function ()
                Save.vigentteButton= not Save.vigentteButton and true or nil
                set_VIGNETTE_MINIMAP_UPDATED()--小地图, 标记, 文本
            end
        }
        UIDropDownMenu_AddButton(info, 1)
    end)
end


--####
--初始
--####
local function Init()
    set_MinimapCluster()--缩放
    set_ExpansionLandingPageMinimapButton()--盟约图标
    set_MinimapMenu()--小地图, 添加菜单
    set_minimapTrackingShowAll()--追踪,镇民

    if MinimapCluster then
        if MinimapCluster.InstanceDifficulty and MinimapCluster.InstanceDifficulty.Instance.Border then
            MinimapCluster.InstanceDifficulty.Instance.Border:SetVertexColor(e.Player.r, e.Player.g, e.Player.b, 1)--外框， 颜色
            if MinimapCluster.InstanceDifficulty.ChallengeMode then
                MinimapCluster.InstanceDifficulty.ChallengeMode.Border:SetVertexColor(e.Player.r, e.Player.g, e.Player.b, 1)
            end

            if MinimapCluster.InstanceDifficulty.Instance.Text then
                e.Cstr(nil,14, MinimapCluster.InstanceDifficulty.Instance.Text, MinimapCluster.InstanceDifficulty.Instance.Text)--字体，大小
                MinimapCluster.InstanceDifficulty.Instance.Text:SetShadowOffset(1,-1)
            end
        end
        MinimapCluster:HookScript('OnEvent', function(self, event)--Minimap.lua
            if self.InstanceDifficulty.Instance and self.InstanceDifficulty.Instance:IsShown() then
                local frame= self.InstanceDifficulty.Instance.Background
                local _, _, difficultyID, _, _, _, _, _, _, LfgDungeonID = GetInstanceInfo()
                if difficultyID==24 or difficultyID==33 then--时光
                    frame:SetVertexColor(0, 0.7, 1 ,1)

                elseif LfgDungeonID then
                    frame:SetVertexColor(0, 0, 1, 1)

                elseif difficultyID then
                    local _, groupType, isHeroic, isChallengeMode, displayHeroic, displayMythic = GetDifficultyInfo(difficultyID)
                    if groupType=='raid' then
                        if displayMythic then
                            frame:SetVertexColor(1, 0, 1, 1)
                        elseif displayHeroic then
                            frame:SetVertexColor(0, 1, 0, 1)
                        else
                            frame:SetVertexColor(1, 1, 1, 1)
                        end
                    else
                        if isChallengeMode then--挑战
                            if self.InstanceDifficulty.ChallengeMode and self.InstanceDifficulty.ChallengeMode.Background then
                                self.InstanceDifficulty.ChallengeMode.Background:SetVertexColor(1,0.82,0,1)
                            end
                        elseif isHeroic and displayMythic then--史诗
                            frame:SetVertexColor(1, 0, 1, 1)
                        elseif isHeroic then--英雄
                            frame:SetVertexColor(0,1,0,1)
                        else--普通
                            frame:SetVertexColor(1, 1, 1, 1)
                        end
                    end
                else
                    frame:SetVertexColor(1, 1, 1, 1)
                end
            end
        end)
    end
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("ZONE_CHANGED_NEW_AREA")
panel:RegisterEvent('ZONE_CHANGED')
panel:RegisterEvent("PLAYER_ENTERING_WORLD")
panel:RegisterEvent('MINIMAP_UPDATE_ZOOM')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if  arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

             --添加控制面板        
             local sel=e.CPanel(e.onlyChinse and '小地图' or addName, not Save.disabled)
             sel:SetScript('OnMouseDown', function()
                Save.disabled = not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需求重新加载' or REQUIRES_RELOAD)
             end)
             sel:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(id, addName)
                e.tips:AddDoubleLine(UI_SCALE, Save.scale or 1)
                e.tips:Show()
            end)
            sel:SetScript('OnLeave', function() e.tips:Hide() end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
                panel:UnregisterEvent('ADDON_LOADED')
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='PLAYER_ENTERING_WORLD' or event=='ZONE_CHANGED_NEW_AREA' or event=='ZONE_CHANGED' then
        set_ZoomOut()--更新地区时,缩小化地图

        if event=='PLAYER_ENTERING_WORLD' then
            set_VIGNETTE_MINIMAP_UPDATED()--小地图, 标记, 文本
        end

    elseif event=='MINIMAP_UPDATE_ZOOM' then--当前缩放，显示数值 Minimap.lua
        local zoomIn, zoomOut= Minimap.ZoomIn:IsEnabled(), Minimap.ZoomOut:IsEnabled()
        local zoom = Minimap:GetZoom();
        local level= Minimap:GetZoomLevels()
        if zoomOut and zoomIn then
            if not Minimap.ZoomIn.text then
                Minimap.ZoomIn.text= e.Cstr(Minimap)
                Minimap.ZoomIn.text:SetPoint('BOTTOMLEFT', Minimap.ZoomIn, 'TOPLEFT',-2,-6)
            end
            Minimap.ZoomIn.text:SetText(level-1-zoom)
            if not Minimap.ZoomOut.text then
                Minimap.ZoomOut.text= e.Cstr(Minimap)
                Minimap.ZoomOut.text:SetPoint('BOTTOMLEFT', Minimap.ZoomOut, 'TOPLEFT',0,-2)
            end
            Minimap.ZoomOut.text:SetText(zoom)
        else
            if Minimap.ZoomIn.text then
                Minimap.ZoomIn.text:SetText('')
            end
            if Minimap.ZoomOut.text then
                Minimap.ZoomOut.text:SetText('')
            end
        end
    end
end)