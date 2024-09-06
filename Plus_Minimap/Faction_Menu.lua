local e= select(2, ...)







 --[[盟约 9.0
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
end]]



--[[
name= name,
factionID= factionID,
description= data.description,
color= barColor,

isMajor=isMajor,
isParagon= isParagon,
friendshipID= friendshipID,

texture= texture,
atlas= atlas,

factionStandingtext= factionStandingtext,
valueText= value,

hasRewardPending=hasRewardPending,

isCapped= isCapped,
isHeader= isHeader,
isHeaderWithRep= isHeaderWithRep,

hasRep= data.hasBonusRepGain,--额外，声望
]]


    --[[sub:SetTooltip(function(tooltip, description)

    end)]]

    --[[local data = C_MajorFactions.GetMajorFactionData(factionID or 0)
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
    end]]




--菜单, 派系声望
local function Set_Faction_Menu(root, factionID)
    local info= WoWTools_FactionMinxin:GetInfo(factionID, nil, false)
    if not info.name then
        return
    end

    local sub=root:CreateCheckbox(
        (info.atlas and '|A:'..info.atlas..':0:0|a' or (info.texture and '|T'..info.texture..':0|t') or '')
        ..e.cn(info.name)
        ..(info.color and '|c'..info.color:GenerateHexColor() or '|cffffffff')
        ..(info.factionStandingtext and ' '..info.factionStandingtext..' ' or '')
        ..'|r'
        ..(info.valueText or '')
        ..(info.hasRewardPending and '|A:BonusLoot-Chest:0:0|a' or ''),

    function(data)
        return MajorFactionRenownFrame and MajorFactionRenownFrame.majorFactionID==data.factionID

    end, function(data)
        WoWTools_LoadUIMixin:MajorFaction(data.factionID)

    end, {factionID=factionID})

    return sub
end










--派系声望
function WoWTools_MinimapMixin:Faction_Menu(_, root)
    local sub

--打开选项
    sub=root:CreateCheckbox(
        '|A:VignetteEvent-SuperTracked:0:0|a'
        ..(e.onlyChinese and '名望' or LANDING_PAGE_RENOWN_LABEL),
    function()
        return MajorFactionRenownFrame and MajorFactionRenownFrame:IsShown()
    end, function()
        WoWTools_LoadUIMixin:MajorFaction(2593)
        return MenuResponse.Open
    end, {factionID=2593})

    local index=0
--当前版本
    local tab=C_MajorFactions.GetMajorFactionIDs(e.ExpansionLevel) or {}

--MajorFactionsConstantsDocumentation.lua
    for _, factionID in pairs(Constants.MajorFactionsConsts or {}) do
        table.insert(tab, factionID)
    end
    table.sort(tab, function(a, b) return a>b end)
    
    for _, factionID in pairs(tab) do
        if Set_Faction_Menu(sub, factionID) then
            index=index+1
        end
    end


--旧数据
    for expacID= e.ExpansionLevel-1, 9, -1 do
        tab=C_MajorFactions.GetMajorFactionIDs(expacID)
        if tab then
            table.sort(tab, function(a, b) return a>b end)
        --[[    sub2= sub:CreateButton(
                e.GetExpansionText(expacID, nil)..' '..#tab,
            function()
                return MenuResponse.Open
            end)]]
            sub:CreateDivider()
            for _, factionID in pairs(tab) do
                if Set_Faction_Menu(sub, factionID) then
                    index= index+1
                end
            end
        end
    end
    WoWTools_MenuMixin:SetNumButton(sub, index)
end