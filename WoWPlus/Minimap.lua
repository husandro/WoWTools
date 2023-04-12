local id, e = ...
local addName= HUD_EDIT_MODE_MINIMAP_LABEL
local Save={
        scale=e.Player.husandro and 1 or 0.85,
        ZoomOut=true,
        vigentteButton=e.Player.husandro,
        vigentteButtonShowText=true,
        expansionScale= 0.85,
        addIcon= e.Player.husandro,
        miniMapPoint={},--保存小图地, 按钮位置
        --expansionAlpha=0.3,
}
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
        print(id, addName, e.onlyChinese and '缩放' or UI_SCALE, '|cnGREEN_FONT_COLOR:'..scale)
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

    frame.ScaleIn=e.Cbtn(Minimap, {icon='hide', size={20,20}})
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
        e.tips:AddDoubleLine(e.onlyChinese and '缩放' or UI_SCALE, (e.onlyChinese and '缩小' or ZOOM_OUT)..(Save.scale or 1)..e.Icon.left)

        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
        e.tips:Show()
    end)
    frame.ScaleIn:SetScript('OnLeave', function() e.tips:Hide() ResetCursor() end)
    frame.ScaleIn:SetScript('OnMouseUp', function() ResetCursor() end)

    frame.ScaleOut=e.Cbtn(Minimap, {icon='hide', size={20,20}})
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
        e.tips:AddDoubleLine(e.onlyChinese and '缩放' or UI_SCALE,(e.onlyChinese and '放大' or ZOOM_IN)..(Save.scale or 1)..e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
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
local Set_MinMap_Icon= function(tab)-- {name, texture, func, hide} 小地图，建立一个图标 Hide("MyLDB") icon:Show("")
    Save.miniMapPoint= Save.miniMapPoint or {}
    local bunnyLDB = LibStub("LibDataBroker-1.1"):NewDataObject(tab.name, {
        type = "data source",
        text = tab.name,
        icon = tab.texture,
        OnClick = tab.func,
        OnEnter= tab.enter,
    })
    local icon = LibStub("LibDBIcon-1.0")
    --icon:Register(tab.name, bunnyLDB, {hide= tab.hide})
    icon:Register(tab.name, bunnyLDB, Save.miniMapPoint)
    return icon
end

local function set_ExpansionLandingPageMinimapButton()
    if Save.addIcon then
        if ExpansionLandingPageMinimapButton then
            ExpansionLandingPageMinimapButton:SetShown(false)
        end
        Set_MinMap_Icon({name= id, texture= 136235,
            func= function(self, d)
                if d=='LeftButton' then
                    if IsAltKeyDown() then
                        if not IsAddOnLoaded("Blizzard_WeeklyRewards") then--周奖励面板
                            LoadAddOn("Blizzard_WeeklyRewards")
                        end
                        WeeklyRewards_ShowUI()--WeeklyReward.lua
                    else
                        if ExpansionLandingPageMinimapButton and ExpansionLandingPageMinimapButton.ToggleLandingPage and ExpansionLandingPageMinimapButton.title then
                            ExpansionLandingPageMinimapButton.ToggleLandingPage(ExpansionLandingPageMinimapButton)--Minimap.lua
                        else
                            InterfaceOptionsFrame_OpenToCategory(id)
                        end
                    end
                else
                    InterfaceOptionsFrame_OpenToCategory(id)
                end
            end,
            enter= function(self)
                if ExpansionLandingPageMinimapButton and ExpansionLandingPageMinimapButton.OnEnter and ExpansionLandingPageMinimapButton.title then--Minimap.lua
                    ExpansionLandingPageMinimapButton.OnEnter(ExpansionLandingPageMinimapButton)
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(e.onlyChinese and '宏伟宝库' or RATED_PVP_WEEKLY_VAULT , 'Alt'..e.Icon.left)
                    e.tips:AddDoubleLine(e.onlyChinese and '设置选项' or OPTIONS, e.Icon.right)
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(id, addName)
                    e.tips:Show()
                else
                    e.tips:SetOwner(self, "ANCHOR_Left")
                    e.tips:ClearLines()
                    e.tips:AddDoubleLine(e.onlyChinese and '设置选项' or OPTIONS, e.Icon.right)
                    e.tips:AddDoubleLine(e.onlyChinese and '宏伟宝库' or RATED_PVP_WEEKLY_VAULT , 'Alt'..e.Icon.left)
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(id, addName)
                    e.tips:Show()
                end
                if ExpansionLandingPageMinimapButton and ExpansionLandingPageMinimapButton:IsShown() then
                    ExpansionLandingPageMinimapButton:SetShown(false)
                end
            end
        })

    else
        local frame=ExpansionLandingPageMinimapButton
        frame:SetFrameStrata('TOOLTIP')
        frame:SetMovable(true)--移动
        frame:RegisterForDrag("RightButton")
        frame:SetClampedToScreen(true)
        frame:EnableMouseWheel(true)
        frame:SetScript("OnDragStart", function(self, d)
            if d=='RightButton' and IsAltKeyDown() then
                self:StartMoving()
            end
        end)

        frame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
        end)
        frame:SetScript('OnMouseDown', function(self, d)
            if d=='RightButton' and not IsModifierKeyDown() then
                InterfaceOptionsFrame_OpenToCategory(id)
            end
        end)
        --hooksecurefunc(DragonridingPanelSkillsButtonMixin, 'OnClick', function(self, d)--显示,飞龙技能

        frame:SetScript('OnEnter',function(self)--Minimap.lua
            self:SetAlpha(1)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:SetText(self.title, 1, 1, 1);
            e.tips:AddLine(self.description, nil, nil, nil, true);
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.onlyChinese and '设置选项' or OPTIONS, e.Icon.right)
            e.tips:AddDoubleLine(e.onlyChinese and '宏伟宝库' or RATED_PVP_WEEKLY_VAULT , e.Icon.mid)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.onlyChinese and '缩放' or UI_SCALE, (Save.expansionScale and Save.expansionScale or '')..' Alt+'..e.Icon.mid)
            e.tips:AddDoubleLine(e.onlyChinese and '透明度' or CHANGE_OPACITY, (Save.expansionScale and Save.expansionScale or '')..' Ctrl+'..e.Icon.mid)
            e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
        end)
        frame:SetScript('OnLeave', function(self)
            e.tips:Hide()
            if Save.expansionAlpha and Save.expansionAlpha~=1 then
                self:SetAlpha(Save.expansionAlpha)
            end
        end)
        frame:SetScript('OnMouseWheel', function(self, d)
            if not IsModifierKeyDown() then--打开, 插件, 选项
                if not IsAddOnLoaded("Blizzard_WeeklyRewards") then--周奖励面板
                    LoadAddOn("Blizzard_WeeklyRewards")
                end
                WeeklyRewards_ShowUI()--WeeklyReward.lua
            elseif IsAltKeyDown() then--缩放
                local n= Save.expansionScale or 1
                if d==1 then
                    n= n+0.1
                elseif d==-1 then
                    n= n-0.1
                end
                n= n>2 and 2 or n<0.3 and 0.3 or n
                self:SetScale(n)
                Save.expansionScale=n
                print(id, addName, e.onlyChinese and '缩放' or UI_SCALE, '|cnGREEN_FONT_COLOR:'..n)
            elseif IsControlKeyDown() then--透明度
                local n= Save.expansionAlpha or 1
                if d==1 then
                    n= n+0.1
                elseif d==-1 then
                    n= n-0.1
                end
                n= n>1 and 1 or n<0.3 and 0.3 or n
                self:SetAlpha(n)
                Save.expansionAlpha=n
                print(id, addName, e.onlyChinese and '透明度' or CHANGE_OPACITY, '|cnGREEN_FONT_COLOR:'..n)
            end
        end)
        if Save.expansionScale and Save.expansionScale~=1 then
            frame:SetScale(Save.expansionScale)
        end
        C_Timer.After(8, function()--盟约图标停止闪烁
            frame.MinimapLoopPulseAnim:Stop()
            if Save.expansionAlpha and Save.expansionAlpha~=1 then
                frame:SetAlpha(Save.expansionAlpha)
            end
        end)
    end
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

local uiMapIDsTab= {2026, 2025, 2024, 2023, 2022}--地图, areaPoiIDs
if e.Player.ver then
    table.insert(uiMapIDsTab, 2133)
end
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
    
 

    if e.Player.level==70 then
        
        for _, uiMapID in pairs(uiMapIDsTab) do
            local areaPoiIDs = C_AreaPoiInfo.GetAreaPOIForMap(uiMapID) or {}
            for _, areaPoiID in pairs(areaPoiIDs) do
                --if areaPoiID then--and (areaPoiID<7234 or areaPoiID>7260) then--not areaPoiIDTab[areaPoiID] then--不显示, areaPoiID
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
                --end
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
        panel.vigentteButton= e.Cbtn(nil, {icon='hide', size={15,15}})
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
            e.tips:AddDoubleLine(e.onlyChinese and '文本' or LOCALE_TEXT_LABEL, e.GetShowHide(Save.vigentteButtonShowText)..e.Icon.left)
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
            text=e.onlyChinese and '镇民' or TOWNSFOLK_TRACKING_TEXT,
            checked= C_CVar.GetCVarBool("minimapTrackingShowAll"),
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '显示: 追踪' or SHOW..': '..TRACKING,
            tooltipText= id..' '..addName..'\n\nCVar minimapTrackingShowAll',
            func= function()
                Save.minimapTrackingShowAll= not C_CVar.GetCVarBool("minimapTrackingShowAll") and true or false
                set_minimapTrackingShowAll()--追踪,镇民
            end
        }
        UIDropDownMenu_AddButton(info, 1)

        info={
            text= e.onlyChinese and '缩小地图' or BINDING_NAME_MINIMAPZOOMOUT,
            icon='UI-HUD-Minimap-Zoom-Out',
            checked= Save.ZoomOut,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '更新地区时' or UPDATE..ZONE,
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
            text= e.onlyChinese and '文本' or LOCALE_TEXT_LABEL,
            icon='MajorFactions_MapIcons_Tuskarr64',
            tooltipOnButton=true,
            tooltipTitle= id..'  '..addName,
            tooltipText= (e.onlyChinese and '小地图' or HUD_EDIT_MODE_MINIMAP_LABEL)..mapName,
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
        UIDropDownMenu_AddButton(info, 1)
    end)
end


--####
--初始
--####
local function Init()
    set_MinimapCluster()--缩放
    C_Timer.After(2, set_ExpansionLandingPageMinimapButton)--盟约图标
    set_MinimapMenu()--小地图, 添加菜单
    set_minimapTrackingShowAll()--追踪,镇民

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


end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if  arg1==id then
            Save= WoWToolsSave[addName] or Save

             --添加控制面板        
             local check=e.CPanel('|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..(e.onlyChinese and '小地图' or addName), not Save.disabled)
             check:SetScript('OnMouseDown', function()
                Save.disabled = not Save.disabled and true or nil
                print(id, addName, e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
             end)

             --添加一个图标，隐藏要塞图标
             local checkAddIcon=CreateFrame("CheckButton", nil, check, "InterfaceOptionsCheckButtonTemplate")
             checkAddIcon:SetChecked(Save.addIcon)
             checkAddIcon.text:SetText(e.Icon.wow2..(e.onlyChinese and '图标' or EMBLEM_SYMBOL))
             checkAddIcon:SetScript('OnMouseUp', function()
                 Save.addIcon = not Save.addIcon and true or false
                 print(id, addName, e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
             end)
             checkAddIcon:SetPoint("LEFT", check.text, 'RIGHT', 2, 0)
             checkAddIcon:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.onlyChinese and '添加' or ADD, e.Icon.wow2..(e.onlyChinese and '图标' or EMBLEM_SYMBOL))
                e.tips:AddDoubleLine(e.onlyChinese and "要塞报告" or GARRISON_LANDING_PAGE_TITLE, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '隐藏' or HIDE))
                e.tips:Show()
            end)
            checkAddIcon:SetScript('OnLeave', function() e.tips:Hide() end)

            if not Save.disabled then
                if not e.Player.levelMax then
                    uiMapIDsTab= {}
                    questIDTab= {}
                end
                panel:RegisterEvent("ZONE_CHANGED_NEW_AREA")
                panel:RegisterEvent('ZONE_CHANGED')
                panel:RegisterEvent("PLAYER_ENTERING_WORLD")
                panel:RegisterEvent('MINIMAP_UPDATE_ZOOM')
                Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
            panel:UnregisterEvent('ADDON_LOADED')
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
        local zoomIn, zoomOut= Minimap.ZoomIn:IsEnabled(), Minimap.ZoomOut:IsEnabled()
        local zoom = Minimap:GetZoom();
        local level= Minimap:GetZoomLevels()
        if zoomOut and zoomIn then
            if not Minimap.ZoomIn.text then
                Minimap.ZoomIn.text= e.Cstr(Minimap, {color=true})
                Minimap.ZoomIn.text:SetPoint('BOTTOMLEFT', Minimap.ZoomIn, 'TOPLEFT',-2,-6)
            end
            Minimap.ZoomIn.text:SetText(level-1-zoom)
            if not Minimap.ZoomOut.text then
                Minimap.ZoomOut.text= e.Cstr(Minimap, {color=true})
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
end)