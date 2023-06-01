local id, e = ...
local addName= HUD_EDIT_MODE_MINIMAP_LABEL
local Save={
        scale=e.Player.husandro and 1 or 0.85,
        ZoomOut=true,--更新地区时,缩小化地图
        ZoomOutInfo=true,--小地图, 缩放, 信息
        vigentteButton=e.Player.husandro,
        vigentteButtonShowText=true,
        miniMapPoint={},--保存小图地, 按钮位置
        useServerTimer=true,--小时图，使用服务器, 时间
}
local uiMapIDsTab= {--地图ID 监视, areaPoiIDs，
    2026,
    2025,
    2024,
    2023,
    2022,
    2133
}

local questIDTab= {--世界任务, 监视, ID
   -- [74378]=true,
}

local panel=CreateFrame("Frame")

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
            e.tips:AddDoubleLine(e.onlyChinese and '镜头视野范围' or CAMERA_FOV, (e.onlyChinese and '%s码' or IN_GAME_NAVIGATION_RANGE):format( format('%i', C_Minimap.GetViewRadius() or 100)))
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
        end)
        Minimap.viewRadius:SetScript('OnLeave', function() e.tips:Hide() end)
    end
    Minimap.viewRadius:SetFormattedText('%i', C_Minimap.GetViewRadius() or 100)
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

local setVigentteButtonText
local function set_vigentteButton_Text()
    if not Save.vigentteButtonShowText then
        panel.vigentteButton.text:SetText('')
        setVigentteButtonText=nil
        return
    end

    if setVigentteButtonText then
        return
    else
        setVigentteButtonText=true
    end

    local text
    if e.Player.levelMax then--世界任务, 监视
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
                text= text and text..'|n' or ''
                text= text..(info.name and '|cnGREEN_FONT_COLOR:'..info.name..'|r' or '')..'|A:'..info.atlasName..':0:0|a'
            elseif info.onWorldMap then
                text= text and text..'|n' or ''
                text= text..(info.name and '|cffff00ff'..info.name..'|r' or '')..'|A:'..info.atlasName..':0:0|a'
            end
        end
    end

    if e.Player.levelMax then
        for _, uiMapID in pairs(uiMapIDsTab) do
            local areaPoiIDs = C_AreaPoiInfo.GetAreaPOIForMap(uiMapID) or {}
            for _, areaPoiID in pairs(areaPoiIDs) do
                local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID)
                local secondsLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(areaPoiID)
                if poiInfo and poiInfo.name and poiInfo.atlasName and secondsLeft and secondsLeft>0 then-- C_AreaPoiInfo.IsAreaPOITimed(areaPoiID) then
                    text= text and text..'|n' or ''
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
                    if secondsLeft and secondsLeft>0 then
                        local secText=SecondsToClock(secondsLeft,true)
                        secText= secText:gsub('：',':')
                        if secondsLeft<= 600 then
                            secText= '|cnGREEN_FONT_COLOR:'..secText..'|r'
                        end
                        text= text..secText
                    end
                    text= text..'|A:'..poiInfo.atlasName..':0:0|a'
                end
            end
        end
    end


    panel.vigentteButton.text:SetText(text or '..')
    setVigentteButtonText=nil
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
        panel.vigentteButton= e.Cbtn(nil, {icon='hide', size={15,15}})
        if Save.pointVigentteButton then
            panel.vigentteButton:SetPoint(Save.pointVigentteButton[1], UIParent, Save.pointVigentteButton[3], Save.pointVigentteButton[4], Save.pointVigentteButton[5])
        else
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
            print(id, addName, 'Alt+'..e.Icon.right, e.onlyChinese and '还原位置' or RESET_POSITION)
        end)
        panel.vigentteButton:SetScript('OnMouseDown', function(self, d)
            local key= IsModifierKeyDown()
            if d=='LeftButton' and not key then
                Save.vigentteButtonShowText= not Save.vigentteButtonShowText and true or false
                if Save.vigentteButtonShowText then
                    self:SetNormalTexture(0)
                else
                    self:SetNormalAtlas(e.Icon.disabled)
                end
                set_vigentteButton_Event()
                set_vigentteButton_Text()
            elseif d=='RightButton' and key then
                self:ClearAllPoints()
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
                print(id, addName, e.onlyChinese and '字体大小' or FONT_SIZE, size)
                Save.vigentteButtonSize= size
                e.Cstr(nil, {size=size, changeFont=panel.vigentteButton.text, color=true, justifyH='RIGHT'})--size, nil, panel.vigentteButton.text, true ,nil,'RIGHT')
            end
        end)
        panel.vigentteButton:SetScript('OnEnter',function(self)
            set_vigentteButton_Text()
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, addName)
            e.tips:AddDoubleLine(e.onlyChinese and '追踪' or TRACKING, e.GetShowHide(Save.vigentteButtonShowText)..e.Icon.left)
            e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
            e.tips:AddDoubleLine((e.onlyChinese and '字体大小' or FONT_SIZE)..': '..(Save.vigentteButtonSize or 12), 'Alt+'..e.Icon.mid)
            e.tips:Show()
        end)
        panel.vigentteButton:SetScript('OnLeave',function(self)
            self:SetButtonState("NORMAL")
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

        panel.vigentteButton.text= e.Cstr(panel.vigentteButton, {size=Save.vigentteButtonSize, color=true, justifyH='RIGHT'})
        panel.vigentteButton.text:SetPoint('BOTTOMRIGHT')
    end
    panel.vigentteButton:SetShown(true)
    set_vigentteButton_Event()
    set_vigentteButton_Text()
end


local function Init_Menu(self, level, type)
    local info={
        text=e.onlyChinese and '镇民' or TOWNSFOLK_TRACKING_TEXT,
        icon='UI-HUD-Minimap-Tracking-Mouseover',
        checked= C_CVar.GetCVarBool("minimapTrackingShowAll"),
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '显示: 追踪' or SHOW..': '..TRACKING,
        tooltipText= id..' '..addName..'|n|nCVar minimapTrackingShowAll',
        func= function()
            C_CVar.SetCVar('minimapTrackingShowAll', not C_CVar.GetCVarBool("minimapTrackingShowAll") and '1' or '0' )
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '缩小地图' or BINDING_NAME_MINIMAPZOOMOUT,
        icon= 'UI-HUD-Minimap-Zoom-Out',
        checked= Save.ZoomOut,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '更新地区时' or UPDATE..ZONE,
        tooltipText= id..' '..addName,
        func= function()
            Save.ZoomOut= not Save.ZoomOut and true or nil
            set_ZoomOut()--更新地区时,缩小化地图
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '信息' or INFO,--当前缩放，显示数值
        icon= 'common-icon-zoomin',
        checked= Save.ZoomOutInfo,
        tooltipOnButton=true,
        tooltipTitle=(e.onlyChinese and '镜头视野范围' or CAMERA_FOV)..': '..format(e.onlyChinese and '%s码' or IN_GAME_NAVIGATION_RANGE, format('%i', C_Minimap.GetViewRadius() or 100)),
        func= function()
            Save.ZoomOutInfo= not Save.ZoomOutInfo and true or nil
            set_Event_MINIMAP_UPDATE_ZOOM()
            if Save.ZoomOutInfo then
                set_MINIMAP_UPDATE_ZOOM()
            end
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    local mapName=''
    for _, mapID in pairs(uiMapIDsTab) do
        local mapInfo=C_Map.GetMapInfo(mapID)
        if mapInfo and mapInfo.name then
            mapName= mapName..'|n'..mapInfo.name
        end
    end
    info={
        text= e.onlyChinese and '追踪' or TRACKING,
        icon='VignetteKillElite',
        tooltipOnButton=true,
        tooltipTitle='|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '小地图' or HUD_EDIT_MODE_MINIMAP_LABEL),
        tooltipText='|cffff00ff'..mapName,
        checked= Save.vigentteButton,
        disabled= IsInInstance(),
        func= function ()
            Save.vigentteButton= not Save.vigentteButton and true or nil
            set_VIGNETTE_MINIMAP_UPDATED()--小地图, 标记, 文本
            if panel.vigentteButton then
                panel.vigentteButton:SetButtonState('PUSHED')
            end
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end

local Set_MinMap_Icon= function(tab)-- {name, texture, func, hide} 小地图，建立一个图标 Hide("MyLDB") icon:Show("")
    local bunnyLDB = LibStub("LibDataBroker-1.1"):NewDataObject(tab.name, {
        type = "data source",
        text = tab.name,
        icon = tab.texture,
        OnClick = tab.func,
        OnEnter= tab.enter,
    })
    local icon = LibStub("LibDBIcon-1.0")
    icon:Register(tab.name, bunnyLDB, Save.miniMapPoint)
    return icon
end

--####
--初始
--####
local function Init()
    if MinimapCluster then
        if MinimapCluster.InstanceDifficulty and MinimapCluster.InstanceDifficulty.Instance.Border then
            MinimapCluster.InstanceDifficulty.Instance.Border:SetVertexColor(e.Player.r, e.Player.g, e.Player.b, 1)--外框， 颜色
            if MinimapCluster.InstanceDifficulty.ChallengeMode then
                MinimapCluster.InstanceDifficulty.ChallengeMode.Border:SetVertexColor(e.Player.r, e.Player.g, e.Player.b, 1)
            end

            if MinimapCluster.InstanceDifficulty.Instance.Text then
                e.Cstr(nil,{size=14, copyFont=MinimapCluster.InstanceDifficulty.Instance.Text, changeFont=MinimapCluster.InstanceDifficulty.Instance.Text})--字体，大小
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

    --########
    --盟约图标
    --########


    Save.miniMapPoint= Save.miniMapPoint or {}
    Set_MinMap_Icon({name= id, texture= 136235,
        func= function(self, d)
            local key= IsModifierKeyDown()
            if d=='LeftButton' then
                if IsShiftKeyDown() then
                    if not IsAddOnLoaded("Blizzard_WeeklyRewards") then--周奖励面板
                        LoadAddOn("Blizzard_WeeklyRewards")
                    end
                    WeeklyRewards_ShowUI()--WeeklyReward.lua
                elseif IsAltKeyDown() then
                    if not self.menu then
                        self.Menu=CreateFrame("Frame", id..addName..'Menu', self, "UIDropDownMenuTemplate")
                        e.LibDD:UIDropDownMenu_Initialize(self.Menu, Init_Menu, 'MENU')
                    end
                    e.LibDD:ToggleDropDownMenu(1, nil,self.Menu, self, 15,0)
                elseif not key then
                    local expButton=ExpansionLandingPageMinimapButton
                    if expButton and expButton.ToggleLandingPage and expButton.title then
                        expButton.ToggleLandingPage(expButton)--Minimap.lua
                    else
                        securecallfunction(InterfaceOptionsFrame_OpenToCategory, id)
                    end
                end
            elseif not key then
                securecallfunction(InterfaceOptionsFrame_OpenToCategory, id)
            end
        end,
        enter= function(self)
            local expButton=ExpansionLandingPageMinimapButton
            if expButton and expButton.OnEnter and expButton.title then--Minimap.lua
                expButton.OnEnter(expButton)
                e.tips:AddLine(' ')
            else
                e.tips:SetOwner(self, "ANCHOR_Left")
                e.tips:ClearLines()
            end
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, 'Alt'..e.Icon.left, 0,1,0, 0,1,0)
            e.tips:AddDoubleLine(e.onlyChinese and '宏伟宝库' or RATED_PVP_WEEKLY_VAULT , 'Shift'..e.Icon.left, 1,0,1, 1,0,1)
            e.tips:AddDoubleLine(e.onlyChinese and '选项' or SETTINGS_TITLE , e.Icon.right, 0,1,0, 0,1,0)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
            if expButton and expButton:IsShown() then
                expButton:SetShown(false)
            end
        end
    })

    if ExpansionLandingPageMinimapButton then
        ExpansionLandingPageMinimapButton:SetShown(false)
        ExpansionLandingPageMinimapButton:HookScript('OnShow', function(self2)
            self2:SetShown(false)
        end)
    end

end


--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

             --添加控制面板        
             local check=e.CPanel('|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..(e.onlyChinese and '小地图' or addName), not Save.disabled)
             check:SetScript('OnMouseDown', function()
                Save.disabled = not Save.disabled and true or nil
                print(id, addName, e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
             end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                if not e.Player.levelMax then
                    uiMapIDsTab= {}
                    questIDTab= {}
                end
                panel:RegisterEvent("ZONE_CHANGED_NEW_AREA")
                panel:RegisterEvent('ZONE_CHANGED')
                panel:RegisterEvent("PLAYER_ENTERING_WORLD")
                if Save.ZoomOutInfo then
                    set_Event_MINIMAP_UPDATE_ZOOM()--当前缩放，显示数值
                end
                Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_TimeManager' then
            local TimeManagerClockButton_Update_R= TimeManagerClockButton_Update--小时图，使用服务器, 时间
            local function set_Server_Timer()--小时图，使用服务器, 时间
                if Save.useServerTimer then
                    TimeManagerClockButton_Update=function()
                        TimeManagerClockTicker:SetText(SecondsToClock(GetServerTime()))
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
                e.tips:AddDoubleLine(e.Icon.left..(e.onlyChinese and '服务器时间' or TIMEMANAGER_TOOLTIP_REALMTIME), SecondsToClock(GetServerTime()))
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

        if event=='PLAYER_ENTERING_WORLD' then
            set_VIGNETTE_MINIMAP_UPDATED()--小地图, 标记, 文本

        end

    elseif event=='MINIMAP_UPDATE_ZOOM' then--当前缩放，显示数值 Minimap.lua
        set_MINIMAP_UPDATE_ZOOM()
    end
end)