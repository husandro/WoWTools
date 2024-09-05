local e= select(2, ...)
local Save= function()
    return  WoWTools_MinimapMixin.Save
end







--要塞,任务，列表
local function Get_Garrison_List_Num(followerType)
    local num, all, text= 0, 0, ''
    if followerType then
        local missions = C_Garrison.GetInProgressMissions(followerType) or {}--GarrisonBaseUtils.lua
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
    end
    return text
end







--LuaEnum.lua
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

    --[[{name=e.onlyChinese and '巨龙群岛概要' or DRAGONFLIGHT_LANDING_PAGE_TITLE,
    garrisonType= Enum.GarrisonType.Type_9_0_Garrison,
    garrFollowerTypeID= Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower,
    disabled=false,--not C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower),
    atlas= 'dragonflight-landingbutton-up',
    tooltip= e.onlyChinese and '点击显示巨龙群岛概要' or DRAGONFLIGHT_LANDING_PAGE_TOOLTIP,
    func= function()
        ToggleExpansionLandingPage()
    end,
    },]]
    {name=e.onlyChinese and '卡兹阿加概要' or WAR_WITHIN_LANDING_PAGE_TITLE,--Blizzard_WarWithinLandingPage.lua
    garrisonType= Enum.ExpansionLandingPageType.WarWithin,
    --garrFollowerTypeID= Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower,
    disabled= not C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(LE_EXPANSION_WAR_WITHIN),
    atlas= 'warwithin-landingbutton-up',
    tooltip= e.onlyChinese and '点击这里显示卡兹阿加概要' or DRAGONFLIGHT_LANDING_PAGE_TOOLTIP,
    func= function()
        ToggleExpansionLandingPage()
    end,
    },
}






--要塞报告 GarrisonBaseUtils.lua
local function Init_Garrison_Menu(_, root)
    local sub
    local bat= UnitAffectingCombat('player')     

    for _, info in pairs(GarrisonList) do
        if info.name=='-' then
            root:CreateDivider()

        else
            local has= C_Garrison.HasGarrison(info.garrisonType)
            local num, num2= '', ''
            if has and info.garrFollowerTypeID then
                num= ' '..Get_Garrison_List_Num(info.garrFollowerTypeID)
                if info.garrFollowerTypeID2 then
                    num2= format(' |A:%s:0:0|a%s', info.atlas2 or '',  Get_Garrison_List_Num(info.garrFollowerTypeID2))
                end
            end
            local atlas= type(info.atlas)=='function' and info.atlas() or info.atlas or ''


            sub=root:CreateCheckbox(
                format('|A:%s:0:0|a%s%s%s', atlas, info.name, num, num2),
            function(data)
                return GarrisonLandingPage and GarrisonLandingPage:IsShown() and GarrisonLandingPage.garrTypeID==data.garrisonType
            end, function(data)
                if data.func then
                    data.func()
                else
                    if GarrisonLandingPage and GarrisonLandingPage:IsShown() and GarrisonLandingPage.garrTypeID==data.garrisonType then
                        GarrisonLandingPage:Hide()
                    else
                        ShowGarrisonLandingPage(data.garrisonType)
                    end
                end
            end, {
                garrisonType= info.garrisonType,
                tooltip= info.tooltip,
                func=info.func
            })
            sub:SetTooltip(function(tooltip, description)
                tooltip:AddLine(description.data.tooltip)
            end)

            
            local disabled
            if info.disabled then
                disabled= info.disabled
            else
                disabled= not has
            end
            disabled= disabled or bat
            sub:SetEnabled(not disabled and true or false)
        end
    end
end









function WoWTools_MinimapMixin:Garrison_Menu(frame, root)
    Init_Garrison_Menu(frame, root)
end
















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











































