local id, e = ...
local addName= HUD_EDIT_MODE_MINIMAP_LABEL
local Save={
        scale=e.Player.husandro and 1 or 0.85,
        ZoomOut=true,--更新地区时,缩小化地图
        ZoomOutInfo=true,--小地图, 缩放, 信息

        vigentteButton=e.Player.husandro,
        vigentteButtonShowText=true,
        vigentteButtonTextScale=1,

        miniMapPoint={},--保存小图地, 按钮位置
        useServerTimer=true,--小时图，使用服务器, 时间
        --disabledInstanceDifficulty=true,--副本，难图，指示
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

local panel= CreateFrame("Frame")

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

--#################
--小地图, 标记, 文本
--#################
local function set_vigentteButton_Text(self)
    local text
    --世界任务, 监视
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

                    text= text and text..'|n' or ''
                    text= '|T'..itemTexture..':0|t|cffff00ff'..questName..'|r'..(secText or '')
                end
            end
        end
    end

    for _, guid in pairs(C_VignetteInfo.GetVignettes() or {}) do--当前
        local info= C_VignetteInfo.GetVignetteInfo(guid)
        if info and info.atlasName and not info.isDead then
            if info.onMinimap then
                text= text and text..'|n' or ''
                text= text..'|A:'..info.atlasName..':0:0|a'..(info.name and '|cnGREEN_FONT_COLOR:'..info.name..'|r' or '')
            elseif info.onWorldMap then
                text= text and text..'|n' or ''
                text= text..'|A:'..info.atlasName..':0:0|a'..(info.name and '|cffff00ff'..info.name..'|r' or '')
            end
        end
    end

    for _, uiMapID in pairs(uiMapIDsTab) do--地图ID
        for _, areaPoiID in pairs(C_AreaPoiInfo.GetAreaPOIForMap(uiMapID) or {}) do

            local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID) or {}

            local name=''
            if  poiInfo.name or poiInfo.atlasName then
                name= (poiInfo.atlasName and '|A:'..poiInfo.atlasName..':0:0|a' or '')..(poiInfo.name or '')
            end

            for _, widget in ipairs(poiInfo.widgetSetID and C_UIWidgetManager.GetAllWidgetsBySetID(poiInfo.widgetSetID) or {}) do
                if widget and widget.widgetID then--and  widget.widgetType==8 then
                    local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(widget.widgetID) or {}
                    if widgetInfo.shownState== 1  and widgetInfo.text then
                        if widgetInfo.hasTimer then
                            text= text and text..'|n' or ''
                            text= text..'      '..widgetInfo.text:gsub('|n', '|n      ')..'|n'..name
                            break
                        else
                            local icon, num= widgetInfo.text:match('(|T.-|t).+(%d+)')
                            if icon and num then
                                local texture= icon:match('(|T.-):')
                                if texture then
                                    icon= texture..':0|t'
                                end
                                text= text and text..'|n' or ''

                                text= text..name..icon..'|cff00ff00'..num..'|r'
                                break
                            end
                        end
                    end
                end
            end

            local isTimed, hideTimer= C_AreaPoiInfo.IsAreaPOITimed(areaPoiID)
            if isTimed and not hideTimer then
                local secondsLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(areaPoiID)
                if secondsLeft and secondsLeft>0 then
                    text= text and text..'|n' or ''

                    text= text..name
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
                end
            end
        end
    end

    panel.Button.Frame.text:SetText(text or '')
end

local function check_Button_Enabled_Disabled()
    local self= panel.Button
    local isDisabled= not Save.vigentteButton or IsInInstance() or UnitAffectingCombat('player') or WorldMapFrame:IsShown()
    if self then
        self:SetShown(not isDisabled)
        self.Frame:SetShown(Save.vigentteButtonShowText and not isDisabled)
        if isDisabled or not Save.vigentteButtonShowText then
            self.Frame.text:SetText('')
        end
    end
    return isDisabled
end

local function Init_Button_Menu(_, level, type)
    local info={
        text=e.onlyChinese and '显示/隐藏' or (SHOW..'/'..HIDE),
        checked= Save.vigentteButtonShowText,
        tooltipOnButton=true,
        func= function()
            Save.vigentteButtonShowText= not Save.vigentteButtonShowText and true or false
            panel.Button:SetNormalAtlas(Save.vigentteButtonShowText and e.Icon.icon or e.Icon.disabled)
            check_Button_Enabled_Disabled()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end

local function Init_Set_Button()--小地图, 标记, 文本
    local btn= panel.Button
    if check_Button_Enabled_Disabled() then
        return
    end

    if not btn then
        btn= e.Cbtn(nil, {icon=Save.vigentteButtonShowText, size={20,20}})

        function btn:Set_Point()--设置，位置
            if Save.pointVigentteButton then
               self:SetPoint(Save.pointVigentteButton[1], UIParent, Save.pointVigentteButton[3], Save.pointVigentteButton[4], Save.pointVigentteButton[5])
            elseif e.Player.husandro then
                self:SetPoint('BOTTOMRIGHT', ActionButton1, 'BOTTOMLEFT', -20, -20)
            else
                self:SetPoint('CENTER', -330, -240)
            end
        end
        btn:Set_Point()

        btn:RegisterForDrag("RightButton")
        btn:SetMovable(true)
        btn:SetClampedToScreen(true)
        btn:SetScript("OnDragStart", function(self,d)
            if d=='RightButton' and not IsModifierKeyDown() then
                self:StartMoving()
            end
        end)
        btn:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            Save.pointVigentteButton={self:GetPoint(1)}
            Save.pointVigentteButton[2]=nil
            print(id, addName, 'Alt+'..e.Icon.right, e.onlyChinese and '还原位置' or RESET_POSITION)
        end)

        btn:SetScript('OnClick', function(self, d)--显示，隐藏
            local key= IsModifierKeyDown()
            if d=='LeftButton' and not key then
                if not self.menu then
                    self.Menu=CreateFrame("Frame", id..addName..'Menu', self, "UIDropDownMenuTemplate")
                    e.LibDD:UIDropDownMenu_Initialize(self.Menu, Init_Button_Menu, 'MENU')
                end
                e.LibDD:ToggleDropDownMenu(1, nil,self.Menu, self, 15,0)

            elseif d=='RightButton' and key then
                Save.pointVigentteButton=nil
                btn:ClearAllPoints()
                self:Set_Point()

            elseif d=='RightButton' and not key then
                SetCursor('UI_MOVE_CURSOR')
            end
        end)

        btn:SetScript('OnMouseWheel', function(self, d)--缩放
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
                self.Frame:SetScale(scale)
            end
        end)
        btn:SetScript('OnEnter',function(self)
            set_vigentteButton_Text()
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.onlyChinese and '主菜单' or MAINMENU_BUTTON, e.Icon.left)
            e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
            e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..': '..(Save.vigentteButtonTextScale), 'Alt+'..e.Icon.mid)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
        end)
        btn:SetScript('OnLeave',function(self)
            e.tips:Hide()
            ResetCursor()
        end)

        btn:RegisterEvent('PLAYER_REGEN_DISABLED')
        btn:RegisterEvent('PLAYER_REGEN_ENABLED')
        btn:RegisterEvent('PLAYER_ENTERING_WORLD')
        btn:SetScript('OnEvent', check_Button_Enabled_Disabled)

        btn.Frame= CreateFrame('Frame', nil, btn)
        btn.Frame:SetPoint('BOTTOMLEFT', btn, 'TOPLEFT')
        btn.Frame:SetSize(1,1)
        if Save.vigentteButtonTextScale~=1 then
            btn.Frame:SetScale(Save.vigentteButtonTextScale)
        end

        btn.Frame.text= e.Cstr(btn.Frame, {color=true})
        btn.Frame.text:SetPoint('BOTTOMLEFT')

        WorldMapFrame:HookScript('OnHide', check_Button_Enabled_Disabled)
        WorldMapFrame:HookScript('OnShow', check_Button_Enabled_Disabled)

        check_Button_Enabled_Disabled()

        btn.Frame.elapsed=1
        btn.Frame:SetScript('OnUpdate', function(self, elapsed)
            self.elapsed= self.elapsed+ elapsed
            if self.elapsed>=1 then
                set_vigentteButton_Text(self.text)
               self.elapsed=0
            end
        end)
        panel.Button=btn
    end
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
            Init_Set_Button()--小地图, 标记, 文本
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
        text= e.onlyChinese and '地下城难度' or DUNGEON_DIFFICULTY,
        icon= 'DungeonSkull',
        tooltipOnButton= true,
        tooltipTitle= e.onlyChinese and '颜色' or COLOR,
        tooltipText= tips,
        checked= not Save.disabledInstanceDifficulty,
        func= function()
            Save.disabledInstanceDifficulty= not Save.disabledInstanceDifficulty and true or nil
            print(id, addName, e.GetEnabeleDisable(not Save.disabledInstanceDifficulty), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end



local function click_Func(self, d)
    local key= IsModifierKeyDown()
    if d=='LeftButton' then
        if IsShiftKeyDown() then
            if not IsAddOnLoaded("Blizzard_WeeklyRewards") then--周奖励面板
                LoadAddOn("Blizzard_WeeklyRewards")
            end
            WeeklyRewards_ShowUI()--WeeklyReward.lua
        elseif IsAltKeyDown() and self and type(self)=='table' then
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
    if self and type(self)=='table' then
        if expButton and expButton:IsShown() then
            expButton:SetShown(false)
        end
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, 'Alt'..e.Icon.left, 0,1,0, 0,1,0)
    end
    e.tips:AddDoubleLine(e.onlyChinese and '宏伟宝库' or RATED_PVP_WEEKLY_VAULT , 'Shift'..e.Icon.left, 1,0,1, 1,0,1)
    e.tips:AddDoubleLine(e.onlyChinese and '选项' or SETTINGS_TITLE , e.Icon.right, 0,1,0, 0,1,0)
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
                type = "data source",
                text = tab.name,
                icon = tab.texture,
                OnClick = tab.func,
                OnEnter= tab.enter,
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


--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            Save.vigentteButtonTextScale= Save.vigentteButtonTextScale or 1

             --添加控制面板        
             local check=e.CPanel('|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..(e.onlyChinese and '小地图' or addName), not Save.disabled)
             check:SetScript('OnMouseDown', function()
                Save.disabled = not Save.disabled and true or nil
                print(id, addName, e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
             end)

            if not Save.disabled then
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
            else
                panel:UnregisterAllEvents()
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

    elseif event=='MINIMAP_UPDATE_ZOOM' then--当前缩放，显示数值 Minimap.lua
        set_MINIMAP_UPDATE_ZOOM()
    end
end)