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
       --disabledClockPlus=true,--禁用plus
       --showStopwatchFrame=true,--加载游戏时，显示秒表
       --StopwatchFrameScale=1,--缩放

       hideExpansionLandingPageMinimapButton= true,--隐藏，图标
       --moveExpansionLandingPageMinimapButton=true,--移动动图标

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






local panel= CreateFrame("Frame")
local Button



































































































--[[挑战专送门标签
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
        e.tips:AddDoubleLine(e.addName, Initializer:GetName())
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
end]]
























































































--#########
--初始，菜单
--#########
local function Init_Menu(_, level, menuList)
    local info
    if menuList=='panelButtonRestPoint' then
   
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
            tooltipText= 'CVar minimapTrackingShowAll',
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
            tooltipTitle=(e.onlyChinese and '镜头视野范围' or )..': '..format(e.onlyChinese and '%s码' or IN_GAME_NAVIGATION_RANGE, format('%i', C_Minimap.GetViewRadius() or 100)),
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
                print(e.addName, Initializer:GetName(), e.GetEnabeleDisable(not Save.disabledInstanceDifficulty), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)



        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= '|A:dragonflight-landingbutton-up:0:0|a'..(e.onlyChinese and '隐藏要塞图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, GARRISON_LOCATION_TOOLTIP, EMBLEM_SYMBOL))),
            tooltipOnButton= true,
            checked= Save.hideExpansionLandingPageMinimapButton,
            colorCode= not ExpansionLandingPageMinimapButton and '|cff9e9e9e' or nil,
            --keepShownOnClick=true,
            func= function()
                Save.hideExpansionLandingPageMinimapButton= not Save.hideExpansionLandingPageMinimapButton and true or nil
                print(e.addName, Initializer:GetName(), '|cnGREEN_FONT_COLOR:' , e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text= '|A:dragonflight-landingbutton-up:0:0|a'..(e.onlyChinese and '移动要塞图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NPE_MOVE, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, GARRISON_LOCATION_TOOLTIP, EMBLEM_SYMBOL))),
            checked= Save.moveExpansionLandingPageMinimapButton,
            colorCode= not ExpansionLandingPageMinimapButton and '|cff9e9e9e' or nil,
            disabled= Save.hideExpansionLandingPageMinimapButton,
            keepShownOnClick=true,
            func= function()
                Save.moveExpansionLandingPageMinimapButton= not Save.moveExpansionLandingPageMinimapButton and true or nil
                print(e.addName, Initializer:GetName(), '|cnGREEN_FONT_COLOR:' , e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
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
        for _, factionID in pairs(Get_Major_Faction_List()) do
            info= Set_Faction_Menu(factionID)
            if info then
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end

        --盟约
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
end



























local function click_Func(self, d)
    local key= IsModifierKeyDown()
    if IsAltKeyDown() and self and type(self)=='table' then
        if not self.menu then
            self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
            e.LibDD:UIDropDownMenu_Initialize(self.Menu, Init_Menu, 'MENU')
        end
        e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)

    elseif IsShiftKeyDown() then
        WeeklyRewards_LoadUI()--宏伟宝库
        WeeklyRewards_ShowUI()--WeeklyReward.lua

    elseif d=='LeftButton' and not key then
            local expButton=ExpansionLandingPageMinimapButton
            if expButton and expButton.ToggleLandingPage and expButton.title then
                expButton:ToggleLandingPage()--Minimap.lua
            else
                if not Initializer then
                    e.OpenPanelOpting()
                end
                e.OpenPanelOpting(Initializer)
                --Settings.OpenToCategory(id)
                --e.call(InterfaceOptionsFrame_OpenToCategory, id)
            end

    elseif d=='RightButton' and not key then
        if SettingsPanel:IsShown() then
            if not Initializer then
                e.OpenPanelOpting()
            end
            e.OpenPanelOpting(Initializer)
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
    e.tips:AddDoubleLine(e.addName, Initializer:GetName())
    e.tips:Show()
end





























































--####
--初始
--####
local function Init()
   
    --Init_M_Portal_Room_Labels()--挑战专送门标签



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
    end


    --要塞，图标
    if ExpansionLandingPageMinimapButton then
        if Save.hideExpansionLandingPageMinimapButton then
            ExpansionLandingPageMinimapButton:SetShown(false)
            ExpansionLandingPageMinimapButton:HookScript('OnShow', function(self)
                self:SetShown(false)
            end)
        elseif Save.moveExpansionLandingPageMinimapButton then
            ExpansionLandingPageMinimapButton:SetFrameStrata('TOOLTIP')
            C_Timer.After(2, function()
                e.Set_Move_Frame(ExpansionLandingPageMinimapButton, {hideButton=true, needMove=true, click='RightButton', setResizeButtonPoint={
                    nil, nil, nil, -2, 2
                }})
                C_Timer.After(8, function()--盟约图标停止闪烁
                    ExpansionLandingPageMinimapButton.MinimapLoopPulseAnim:Stop()
                end)
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
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            Save.vigentteButtonTextScale= Save.vigentteButtonTextScale or 1
            Save.uiMapIDs= Save.uiMapIDs or {}
            Save.questIDs= Save.questIDs or {}
            Save.areaPoiIDs= Save.areaPoiIDs or {}


            --添加控制面板
            Initializer= e.AddPanel_Check({
                name= '|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..(e.onlyChinese and '小地图' or addName),
                tooltip= e.cn(addName),
                GetValue= function() return not Save.disabled end,
                SetValue= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(Initializer:GetName(), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if not Save.disabled then
                self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
                self:RegisterEvent('ZONE_CHANGED')
                self:RegisterEvent("PLAYER_ENTERING_WORLD")
                if Save.ZoomOutInfo then
                    set_Event_MINIMAP_UPDATE_ZOOM()--当前缩放，显示数值
                end
                Init()
            else
                self:UnregisterAllEvents()
            end
            self:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_TimeManager' then
            
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