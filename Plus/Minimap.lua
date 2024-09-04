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
       --disabledStopwatchPlus=true,--禁用plus
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
            e.tips:AddDoubleLine(e.addName, Initializer:GetName())
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
            e.tips:AddDoubleLine(e.addName, Initializer:GetName())
            e.tips:Show()
            self:SetAlpha(1)
        end)

    end
    Minimap.viewRadius:SetFormattedText('%i', C_Minimap.GetViewRadius() or 100)
end













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
	SetupTextureKitOnRegions(covenantData.textureKit, frame, regions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize)
end

local function Set_Covenant_Button(self, covenantID, activityID)
    local btn= self['covenant'..covenantID]
    if not btn then
        local info = C_Covenants.GetCovenantData(covenantID) or {}
        btn=WoWTools_ButtonMixin:Cbtn(self.frame or self, {size={32,32}, atlas=format('SanctumUpgrades-%s-32x32', info.textureKit)})
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
            local textureKit = covenantData.textureKit
            NineSliceUtil.ApplyUniqueCornersLayout(CovenantRenownFrame.NineSlice, textureKit)
            NineSliceUtil.DisableSharpening(CovenantRenownFrame.NineSlice)
            local atlas = "CovenantSanctum-RenownLevel-Border-%s"
            CovenantRenownFrame.HeaderFrame.Background:SetAtlas(atlas:format(textureKit), TextureKitConstants.UseAtlasSize)
            UIPanelCloseButton_SetBorderAtlas(CovenantRenownFrame.CloseButton, "UI-Frame-%s-ExitButtonBorder", -1, 1, textureKit)
            SetupTextureKit(CovenantRenownFrame, mainTextureKitRegions, covenantData)
            local renownLevelsInfo = C_CovenantSanctumUI.GetRenownLevels(frame.covenantID) or {}
            for i, levelInfo in ipairs(renownLevelsInfo) do
                levelInfo.textureKit = textureKit
                levelInfo.rewardInfo = C_CovenantSanctumUI.GetRenownRewardsForLevel(frame.covenantID, i)
            end
            CovenantRenownFrame.TrackFrame:Init(renownLevelsInfo)
            CovenantRenownFrame.maxLevel = renownLevelsInfo[#renownLevelsInfo].level

            --CovenantRenownMixin:GetLevels()
            local renownLevel = C_CovenantSanctumUI.GetRenownLevel()
            self.actualLevel = renownLevel
            local cvarName = "lastRenownForCovenant"..frame.covenantID
            local lastRenownLevel = tonumber(GetCVar(cvarName)) or 1
            if lastRenownLevel < renownLevel then
                renownLevel = lastRenownLevel
            end
            self.displayLevel = renownLevel

            CovenantRenownFrame:Refresh(true)

            C_CovenantSanctumUI.RequestCatchUpState()
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
    local text,hasRewardPending ='', false
    level= level or 0
    if C_MajorFactions.HasMaximumRenown(factionID) then
        if C_Reputation.IsFactionParagon(factionID) then--奖励
            local currentValue, threshold, _, hasRewardPending2, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID)
            if not tooLowLevelForParagon and currentValue and threshold and threshold>0 then
                hasRewardPending= hasRewardPending2
                local completed= math.modf(currentValue/threshold)--完成次数
                currentValue= completed>0 and currentValue - threshold * completed or currentValue
                if hasRewardPending2 then
                    text= format('|cnGREEN_FONT_COLOR:%i%%|A:GarrMission-%sChest:0:0|a%s%d|r', currentValue/threshold*100, e.Player.faction, hasRewardPending and format('|A:%s:0:0|a', e.Icon.select) or '', completed)
                else
                    text= format('%i%%|A:Banker:0:0|a%s%d', currentValue/threshold*100, hasRewardPending and format('|A:%s:0:0|a', e.Icon.select) or '', completed)
                end
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
    return text, hasRewardPending
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
        local name, hasRewardPending= Get_Major_Faction_Level(factionID, data.renownLevel)
        return {
            text=format('|A:majorfactions_icons_%s512:0:0|a%s %s',
                        data.textureKit or '',
                        e.cn(data.name) or (e.onlyChinese and '主要阵营' or MAJOR_FACTION_LIST_TITLE),
                        --C_MajorFactions.HasMaximumRenown(factionID) and '|cnGREEN_FONT_COLOR:' or '',
                        name),
            checked= MajorFactionRenownFrame and MajorFactionRenownFrame.majorFactionID==factionID,
            keepShownOnClick=true,
            tooltipOnButton= hasRewardPending,
            tooltipTitle=e.onlyChinese and '你有未领取的奖励' or WEEKLY_REWARDS_UNCLAIMED_TITLE,
            disabled= UnitAffectingCombat('player'),
            colorCode= (not data.isUnlocked and data.renownLevel==0) and '|cff9e9e9e' or nil,
            --tooltipOnButton=true,
            --tooltipTitle='FactionID '..factionID,
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
    MajorFactionRenownFrame.WoWToolsFaction= WoWTools_ButtonMixin:Cbtn(MajorFactionRenownFrame, {size={22,22}, icon='hide'})
    function MajorFactionRenownFrame.WoWToolsFaction:set_scale()
        self.frame:SetScale(Save.MajorFactionRenownFrame_Button_Scale or 1)
    end
    function MajorFactionRenownFrame.WoWToolsFaction:set_texture()
        self:SetNormalAtlas(Save.hide_MajorFactionRenownFrame_Button and 'talents-button-reset' or e.Icon.icon)
    end
    function MajorFactionRenownFrame.WoWToolsFaction:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, Initializer:GetName())
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
                    btn= WoWTools_ButtonMixin:Cbtn(self.frame, {size={235/2.5, 110/2.5}, icon='hide'})
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
        self.WoWToolsFaction.HeaderText:set_text()
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
        text= ''--format('|cff9e9e9e%d/%d|r', num, all)
    elseif num==0 then
        text= format('|cff9e9e9e%d|r/%d', num, all)
    elseif all==num then
        text= format('|cffff00ff%d/%d|r', num, all)..format('|A:%s:0:0|a', e.Icon.select)
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
            colorCode= not Save.pointVigentteButton and '|cff9e9e9e' or '',
            func= function()
                Save.pointVigentteButton=nil
                Button:ClearAllPoints()
                Button:Set_Point()
                print(e.addName, Initializer:GetName(), e.onlyChinese and '重置位置' or RESET_POSITION)
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
            colorCode= Save.disabledClockPlus and '|cff9e9e9e',
            func= function()
                Save.TimeManagerClockButtonScale=nil
                Save.TimeManagerClockButtonPoint=nil
                TimeManagerClockButton:SetScale(1)
                TimeManagerClockButton:ClearAllPoints()
                TimeManagerClockButton:SetParent(MinimapCluster)
                TimeManagerClockButton:SetPoint('TOPRIGHT', MinimapCluster.BorderTop,-4,0)--Blizzard_TimeManager.xml
                --<Anchor point="TOPRIGHT" relativeKey="$parent.BorderTop" x="-4" y="0"/>
                print(e.addName, Initializer:GetName(), e.onlyChinese and '重置位置' or RESET_POSITION)
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
                print(e.addName, Initializer:GetName(), e.GetEnabeleDisable(not Save.disabledInstanceDifficulty), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        --[[if C_MythicPlus.GetCurrentSeason()==11 then
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
        end]]

        info={
            text= '|A:characterupdate_clock-icon:0:0|a'..(e.onlyChinese and '时钟' or TIMEMANAGER_TITLE)..' Plus',
            checked= not Save.disabledClockPlus,
            keepShownOnClick=true,
            hasArrow=true,
            menuList='ResetTimeManagerClockButton',
            func= function()
                Save.disabledClockPlus= not Save.disabledClockPlus and true or nil
                print(e.addName, Initializer:GetName(), '|cnGREEN_FONT_COLOR:' , e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
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

    Init_Garrison_Menu(level)--要塞报告

    --驭空术
    --[[local DRAGONRIDING_INTRO_QUEST_ID = 68798;
    local DRAGONRIDING_ACCOUNT_ACHIEVEMENT_ID = 15794;
    local DRAGONRIDING_TRAIT_SYSTEM_ID = 1;
    local DRAGONRIDING_TREE_ID = 672;]]

    local numDragonriding=''
    local dragonridingConfigID = C_Traits.GetConfigIDBySystemID(1);
    if dragonridingConfigID then
        local treeCurrencies = C_Traits.GetTreeCurrencyInfo(dragonridingConfigID, 672, false) or {}
        local num= treeCurrencies[1] and treeCurrencies[1].quantity
        if num and num>=0 then
            numDragonriding= format(' %s%d|r |T%d:0|t', num==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:', num, select(4, C_Traits.GetTraitCurrencyInfo(2563)) )
        end
    end

    e.LibDD:UIDropDownMenu_AddButton({--Blizzard_DragonflightLandingPage.lua
        text= format('|A:dragonriding-barbershop-icon-protodrake:0:0|a%s%s', e.onlyChinese and '驭空术' or GENERIC_TRAIT_FRAME_DRAGONRIDING_TITLE, numDragonriding),
        checked= GenericTraitFrame and GenericTraitFrame:IsShown() and GenericTraitFrame:GetConfigID() == C_Traits.GetConfigIDBySystemID(1),
        keepShownOnClick=true,
        disabled= UnitAffectingCombat('player'),
        colorCode= (select(4, GetAchievementInfo(15794)) or C_QuestLog.IsQuestFlaggedCompleted(68798)) and '' or '|cff9e9e9e',
        func= function()
            GenericTraitUI_LoadUI()
            local DRAGONRIDING_TRAIT_SYSTEM_ID = 1
            GenericTraitFrame:SetSystemID(DRAGONRIDING_TRAIT_SYSTEM_ID)
            ToggleFrame(GenericTraitFrame)
        end
    }, level)

    local has= C_WeeklyRewards.HasAvailableRewards()
    local icon= format('|A:GarrMission-%sChest:0:0|a', e.Player.faction=='Alliance' and 'Alliance' or 'Horde')
    e.LibDD:UIDropDownMenu_AddButton({
        text= format('%s|A:oribos-weeklyrewards-orb-dialog:0:0|a%s%s',
            has and '|cnGREEN_FONT_COLOR:' or '',
            e.onlyChinese and '宏伟宝库' or RATED_PVP_WEEKLY_VAULT,
            has and icon or ''),
        tooltipOnButton=has,
        tooltipTitle= has and format('%s|cffff00ff%s|r%s',icon, e.onlyChinese and '你有未领取的奖励' or WEEKLY_REWARDS_UNCLAIMED_TITLE, icon),
        checked= WeeklyRewardsFrame and WeeklyRewardsFrame:IsShown(),
        colorCode= (UnitAffectingCombat('player') or not e.Player.levelMax) and '|cff9e9e9e',
        keepShownOnClick=true,
        func=function()
            if WeeklyRewardsFrame and WeeklyRewardsFrame:IsShown() then
                WeeklyRewardsFrame:Hide()
            else
                WeeklyRewards_LoadUI()--宏伟宝库
                WeeklyRewards_ShowUI()--WeeklyReward.lua
            end
        end
    }, level)

    --派系声望
    local major= Get_Major_Faction_List()
    for _, factionID in pairs(major) do
        info= Set_Faction_Menu(factionID)
        if info then
            --e.LibDD:UIDropDownMenu_AddSeparator(level)
            info.hasArrow= true
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
            Init_TrackButton()--小地图, 标记, 文本
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info= {
        text= Initializer:GetName(),--'    |A:mechagon-projects:0:0|a'..(e.onlyChinese and '选项' or OPTIONS),
        --notCheckable=true,
        checked= SettingsPanel:IsShown(),
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '选项' or OPTIONS,
        keepShownOnClick=true,
        menuList='OPTIONS',
        hasArrow=true,
        func= function()
            if not Initializer then
                e.OpenPanelOpting()
            end
            e.OpenPanelOpting(Initializer)
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    --[[e.LibDD:UIDropDownMenu_AddSeparator(level)
    e.LibDD:UIDropDownMenu_AddButton({
        text= '    '..Initializer:GetName(),
        notCheckable=true,
        func= function()
            e.OpenPanelOpting(Initializer)
        end
    }, level)]]
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



















--####################
--添加，游戏，自带，菜单
--###################
WowTools_OnAddonCompartmentClick= click_Func
WowTools_OnAddonCompartmentFuncOnEnter= enter_Func











































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