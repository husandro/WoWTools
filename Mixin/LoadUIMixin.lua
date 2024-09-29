--[[
Journal(index)加载，收藏，UI
GenericTraitUI(systemID, treeID)加载，Trait，UI
Dragonriding()驭空术
ToggleLandingPage()概要
Professions(recipeID)专业
WeeklyRewards()宏伟宝库
MajorFaction(factionID)派系声望
UpdateGossipFrame()更新GossipFrame
]]
local e= select(2, ...)
WoWTools_LoadUIMixin= {}


function WoWTools_LoadUIMixin:Journal(index)--加载，收藏，UI
    if not CollectionsJournal then
        do
            CollectionsJournal_LoadUI();
        end
    end
    if not index then
        return
    end
    if
           (index==1 and not MountJournal:IsVisible())
        or (index==2 and not PetJournal:IsVisible())
        or (index==3 and not ToyBox:IsVisible())
        or (index==4 and not HeirloomsJournal:IsVisible())
        or (index==5 and not WardrobeCollectionFrame:IsVisible())
    then
        ToggleCollectionsJournal(index)
    end
end








--加载，Trait，UI
function WoWTools_LoadUIMixin:GenericTraitUI(systemID, treeID)
    GenericTraitUI_LoadUI()
    securecallfunction(GenericTraitFrame.SetSystemID, GenericTraitFrame, systemID)
    securecallfunction(GenericTraitFrame.SetTreeID, GenericTraitFrame, treeID)
    ToggleFrame(GenericTraitFrame)
end











--Blizzard_DragonflightLandingPage.lua
--驭空术
function WoWTools_LoadUIMixin:Dragonriding()
    self:GenericTraitUI(Enum.ExpansionLandingPageType.Dragonflight, Constants.MountDynamicFlightConsts.TREE_ID)
end











--概要 ExpansionLandingPage Minimap.lua
function WoWTools_LoadUIMixin:ToggleLandingPage()
    if UnitAffectingCombat('player') then
        return
    end
    local frame= ExpansionLandingPageMinimapButton
    if frame then
        if frame:IsInMajorFactionRenownMode() then
            ToggleMajorFactionRenown(Constants.MajorFactionsConsts.PLUNDERSTORM_MAJOR_FACTION_ID)
            return
        elseif frame:IsInGarrisonMode() then
            e.call(GarrisonLandingPage_Toggle)
            e.call(GarrisonMinimap_HideHelpTip, frame)
            return
        end
    end
    ToggleExpansionLandingPage()--frame:IsExpansionOverlayMode()
end





--专业
function WoWTools_LoadUIMixin:Professions(recipeID)
    do
        if not ProfessionsFrame then
            ProfessionsFrame_LoadUI()
        end
    end
    if recipeID then
        if C_TradeSkillUI.IsRecipeProfessionLearned(recipeID) then
            local parentTradeSkillID= select(3, C_TradeSkillUI.GetTradeSkillLineForRecipe(recipeID))            
            if parentTradeSkillID then
                OpenProfessionUIToSkillLine(parentTradeSkillID)
            end
            C_TradeSkillUI.OpenRecipe(recipeID)
        --else
            --Professions.InspectRecipe(recipeID)
        end
    end
end









--宏伟宝库
function WoWTools_LoadUIMixin:WeeklyRewards()
    if not UnitAffectingCombat('player') then
        if not WeeklyRewardsFrame then
            WeeklyRewards_LoadUI()
        elseif WeeklyRewardsFrame:IsShown() then
            WeeklyRewardsFrame:Hide()
        else
            WeeklyRewards_ShowUI()--WeeklyReward.lua
        end
    end
end







--派系声望
function WoWTools_LoadUIMixin:MajorFaction(factionID)
    if factionID and MajorFactionRenownFrame and MajorFactionRenownFrame.majorFactionID==factionID then
        MajorFactionRenownFrame:Hide()
    else
        ToggleMajorFactionRenown(factionID)
    end
end










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


--盟约 9.0
function WoWTools_LoadUIMixin:CovenantRenown(frame, covenantID)
    do
        if not CovenantRenownFrame or not CovenantRenownFrame:IsShown() then
            ToggleCovenantRenown()
        end
    end

    covenantID= covenantID or (frame and frame.covenantID)
    if not covenantID then
        return
    end

    --CovenantRenownMixin:SetUpCovenantData()
    local covenantData = C_Covenants.GetCovenantData(covenantID)
    if not covenantData then
        return
    end

    local textureKit = covenantData.textureKit

    NineSliceUtil.ApplyUniqueCornersLayout(CovenantRenownFrame.NineSlice, textureKit)
    NineSliceUtil.DisableSharpening(CovenantRenownFrame.NineSlice)

    local atlas = "CovenantSanctum-RenownLevel-Border-%s"
    CovenantRenownFrame.HeaderFrame.Background:SetAtlas(atlas:format(textureKit), TextureKitConstants.UseAtlasSize)
    UIPanelCloseButton_SetBorderAtlas(CovenantRenownFrame.CloseButton, "UI-Frame-%s-ExitButtonBorder", -1, 1, textureKit)
    SetupTextureKit(CovenantRenownFrame, mainTextureKitRegions, covenantData)

    local renownLevelsInfo = C_CovenantSanctumUI.GetRenownLevels(covenantID) or {}
    local unlocked=0
    for i, levelInfo in ipairs(renownLevelsInfo) do
        levelInfo.textureKit = textureKit
        if not levelInfo.locked then
            unlocked=i
        end
        levelInfo.rewardInfo = C_CovenantSanctumUI.GetRenownRewardsForLevel(covenantID, i)
    end
    CovenantRenownFrame.TrackFrame:Init(renownLevelsInfo)
    CovenantRenownFrame.maxLevel = renownLevelsInfo[#renownLevelsInfo].level


    CovenantRenownFrame.actualLevel = C_CovenantSanctumUI.GetRenownLevel()
    CovenantRenownFrame.displayLevel = unlocked

    CovenantRenownFrame:Refresh(true)

    C_CovenantSanctumUI.RequestCatchUpState()
end






--更新GossipFrame
function WoWTools_LoadUIMixin:UpdateGossipFrame()--更新GossipFrame
    if GossipFrame:IsShown() then
        GossipFrame:Update()
    end
end