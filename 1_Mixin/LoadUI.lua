WoWTools_LoadUIMixin= {}

--[[
Journal(index)加载，收藏，UI
GenericTraitUI(systemID, treeID)加载，Trait，UI
Dragonriding()驭空术
ToggleLandingPage()概要
Professions(recipeID)专业
WeeklyRewards()宏伟宝库
MajorFaction(factionID)派系声望
Achievement(achievementID)打开成就
JournalInstance(journalInstanceID)--冒险指南，副本
]]


function WoWTools_LoadUIMixin:IsDisabledOpenFrame()
    return Kiosk.IsEnabled() or DISALLOW_FRAME_TOGGLING
end



--[[
       if not CollectionsJournal then
            CollectionsJournal_LoadUI();
        end

        if not CollectionsJournal:IsShown() then
            ShowUIPanel(CollectionsJournal);
        end

        CollectionsJournal_SetTab(CollectionsJournal, 2);

        local speciesID = C_PetBattles.GetPetSpeciesID(self.petOwner, self.petIndex);
        PetJournal_SelectSpecies(PetJournal, speciesID);
]]

function WoWTools_LoadUIMixin:Journal(index, tab)--加载，收藏，UI
    if
        self:IsDisabledOpenFrame()
        or InCombatLockdown()
    then
        return
    end

    if not CollectionsJournal then
        CollectionsJournal_LoadUI()
    end

    if not CollectionsJournal:IsShown() then
        ShowUIPanel(CollectionsJournal)
        --CollectionsJournal:Show()
    end

    index= index or 1

    CollectionsJournal_SetTab(CollectionsJournal, index)

    if not tab then
        return
    end

--玩具
    if tab.toyItemID then
        if index==3 then
            local name2= select(2, C_ToyBox.GetToyInfo(tab.toyItemID))
            if name2 then
                C_ToyBoxInfo.SetDefaultFilters()
                if ToyBox.searchBox then
                    ToyBox.searchBox:SetText(name2)
                end
            end
        end
--宠物
    elseif (tab.petOwner and tab.petIndex) or tab.petSpeciesID then
        local speciesID = tab.petSpeciesID or C_PetBattles.GetPetSpeciesID(tab.petOwner, tab.petIndex)
        if speciesID then
            PetJournalSearchBox:SetText('')
            C_PetJournal.SetDefaultFilters()
            PetJournal_SelectSpecies(PetJournal, speciesID)
        end
    end
end
--[[

function BattlePetTooltipJournalClick_OnClick(self)
	SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_PETS);
	if CollectionsJournal then
		local battlePetID = self:GetParent().battlePetID;
		if ( battlePetID ) then
			local speciesID = C_PetJournal.GetPetInfoByPetID(battlePetID);
			if ( speciesID and speciesID == self:GetParent().speciesID ) then
				PetJournal_SelectPet(PetJournal, battlePetID);
				return;
			end
		end
		PetJournal_SelectSpecies(PetJournal, self:GetParent().speciesID);
	end
end
    if
        (index==1 and not MountJournal:IsVisible())
        or (index==2 and not PetJournal:IsVisible())
        or (index==3 and not ToyBox:IsVisible())
        or (index==4 and not HeirloomsJournal:IsVisible())
        or (index==5 and not WardrobeCollectionFrame:IsVisible())
        or (index==6 and not WarbandSceneJournal:IsVisible())
    then
        ToggleCollectionsJournal(index)
    end]]




--打开/关闭角色界面
--MicroButtonTooltipText('角色信息', "TOGGLECHARACTER0")
--C_CurrencyInfo.GetCurrencyListSize() <= 0
function WoWTools_LoadUIMixin:OpenPaperDoll(frameIndex, tabIndex)--打开/关闭角色界面
    if self:IsDisabledOpenFrame()
        or C_GameRules.IsGameRuleActive(Enum.GameRule.CharacterPanelDisabled)
    then
        return
    end

    if not CharacterFrame:IsShown() then
        ToggleCharacter("PaperDollFrame")
    end

    if frameIndex==1 then
        if tabIndex then
            PaperDollFrame_SetSidebar(PaperDollFrame, tabIndex)
        end

    elseif frameIndex==2 then
        if not ReputationFrame:IsShown() then
            ToggleCharacter("ReputationFrame")
        end

    elseif frameIndex==3 then
        CharacterFrame:ToggleTokenFrame()
    end
end





--[[加载，Trait，UI
function WoWTools_LoadUIMixin:GenericTraitUI(systemID, treeID)
    TraitUtil.OpenTraitFrame(treeID)

    --WoWTools_DataMixin:Call('GenericTraitUI_LoadUI')
    --securecallfunction(GenericTraitFrame.SetSystemID, GenericTraitFrame, systemID)
    --securecallfunction(GenericTraitFrame.SetTreeID, GenericTraitFrame, treeID)
    --ToggleFrame(GenericTraitFrame)
end

--Blizzard_DragonflightLandingPage.lua
--驭空术
function WoWTools_LoadUIMixin:Dragonriding()
    self:GenericTraitUI(Enum.ExpansionLandingPageType.Dragonflight, Constants.MountDynamicFlightConsts.TREE_ID)
end]]











--概要 ExpansionLandingPageMinimapButtonMixin:RefreshButton(forceUpdateIcon)
function WoWTools_LoadUIMixin:ToggleLandingPage()

    local mode= C_Garrison.GetLandingPageGarrisonType()
    if --ExpansionLandingPageMinimapButton:IsInGarrisonMode()
        GameRulesUtil.ShouldShowExpansionLandingPageButton()
        and mode
        and C_Garrison.IsLandingPageMinimapButtonVisible(mode)
        and not self:IsDisabledOpenFrame()
    then
        GarrisonLandingPage_Toggle()
    end
end





--专业
function WoWTools_LoadUIMixin:Professions(recipeID)
    if self:IsDisabledOpenFrame() then
        return
    end

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
    if
        InCombatLockdown()
        or self:IsDisabledOpenFrame()
    then
        return
    end

    if not WeeklyRewardsFrame then
        WeeklyRewards_LoadUI()
    end

    if WeeklyRewardsFrame and WeeklyRewardsFrame:IsVisible()then
        WeeklyRewardsFrame:Hide()
    else
        WeeklyRewards_ShowUI()--WeeklyReward.lua
    end
end






--[[
派系声望 ReputationDetailViewRenownButtonMixin:OnClick()
EncounterJournal_OpenToPowerID(powerID)
EncounterJournal_OpenJournal(difficultyID, instanceID, encounterID, sectionID, creatureID, itemID, tierIndex)
EJSuggestTab_GetPlayerTierIndex()
EJ_ContentTab_SelectAppropriateInstanceTab(instanceID)
function ReputationDetailViewRenownButtonMixin:OnClick()
	if not EncounterJournal then
		EncounterJournal_LoadUI();
	end

	if not EncounterJournal:IsShown() then
		ShowUIPanel(EncounterJournal);
	end

	EJ_ContentTab_Select(EncounterJournal.JourneysTab:GetID());
	EncounterJournalJourneysFrame:ResetView(nil, self.factionID);
end

]]
function WoWTools_LoadUIMixin:OpenFaction(factionID)
    if
        self:IsDisabledOpenFrame()
    then
        return
    end

    local isMajor= factionID and C_Reputation.IsMajorFaction(factionID)

    if isMajor or not factionID then
        if not EncounterJournal then
            EncounterJournal_LoadUI()
        end

        if WoWTools_FrameMixin:IsLocked(EncounterJournal) then
            return
        end

        if ReputationFrame:IsVisible() then
            HideUIPanel(CharacterFrame)
        end

        if not EncounterJournal:IsShown() then
            ShowUIPanel(EncounterJournal)
        end

        EJ_ContentTab_Select(EncounterJournal.JourneysTab:GetID())

        if factionID and EncounterJournalJourneysFrame then--12.0才有
            EncounterJournalJourneysFrame:ResetView(C_MajorFactions.GetMajorFactionData(factionID), factionID)
            EncounterJournal_OpenToJourney(factionID)
        end

    elseif factionID then
        self:OpenPaperDoll(2)
        if not ReputationFrame or not ReputationFrame:IsShown() then
            return
        end

        if EncounterJournal and EncounterJournal:IsShown() then
            HideUIPanel(EncounterJournal)
        end

        if C_Reputation.GetReputationSortType()~=Enum.ReputationSortType.None then
            C_Reputation.SetReputationSortType(Enum.ReputationSortType.None)
        end
        WoWTools_FactionMixin:Find(factionID)
    end

end
    --[[EJ_ContentTab_Select(EncounterJournal.JourneysTab:GetID())

    if factionID then
        EncounterJournalJourneysFrame:ResetView(nil, factionID)
    end]]











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
    if
        self:IsDisabledOpenFrame()
    then
        return
    end


    if not CovenantRenownFrame or not CovenantRenownFrame:IsShown() then
        ToggleCovenantRenown()
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










--[[
法术书 PlayerSpellsUtil.lua
PlayerSpellsUtil={
  OpenToClassSpecializationsTab=<function>,
  SpellBookCategories={
    Class=1,
    General=2,
    Pet=3
  },
  ToggleClassTalentOrSpecFrame=<function>,
  ToggleClassTalentFrame=<function>,
  SetPlayerSpellsFrameMinimizedOnNextShow=<function>,
  OpenToSpellBookTabAtSpell(spellID, knownSpellsOnly, toggleFlyout, flyoutReason),
  OpenToSpellBookTab(),
  FrameTabs={
    SpellBook=3,
    ClassTalents=2,
    ClassSpecializations=1
  },
  OpenToSpellBookTabAtCategory(spellBookCategory),
  ToggleSpellBookFrame(spellBookCategory),
  TogglePlayerSpellsFrame(suggestedTab, inspectUnit),
  OpenToClassTalentsTab(inspectUnit),
  InspectLoadout(linkData)
}
]]
function WoWTools_LoadUIMixin:SpellBook(index, spellID)
    if InCombatLockdown()
        or self:IsDisabledOpenFrame()
    then
        return
    end

    if index==1 then
        PlayerSpellsUtil.OpenToClassSpecializationsTab()
    elseif index==2 then
        PlayerSpellsUtil.OpenToClassTalentsTab()
        --[[if PlayerSpellsFrame and PlayerSpellsFrame.TalentsFrame:IsVisible() then
            PlayerSpellsUtil.TogglePlayerSpellsFrame(2)
        else
            PlayerSpellsUtil.ToggleClassTalentOrSpecFrame()
        end]]
    else--这个有BUG
        if spellID then
            local knownSpellsOnly, toggleFlyout, flyoutReason = true, true, nil;
            PlayerSpellsUtil.OpenToSpellBookTabAtSpell(spellID, knownSpellsOnly, toggleFlyout, flyoutReason)
        else
            PlayerSpellsUtil.OpenToSpellBookTab()
        end
    end
end





--打开成就
-- AchievementObjectiveTrackerMixin:OnBlockHeaderClick
--AchievementFrameAchievements.selection ~= achievementID
--CanShowAchievementUI()
function WoWTools_LoadUIMixin:Achievement(achievementID)
    if not achievementID
        or not C_AchievementInfo.IsValidAchievement(achievementID)
        or self:IsDisabledOpenFrame()
    then
        return
    end

    if not AchievementFrame then
        WoWTools_DataMixin:Call('AchievementFrame_LoadUI')
    end

    if not AchievementFrame:IsShown() then
        WoWTools_DataMixin:Call('AchievementFrame_ToggleAchievementFrame')
    end

    WoWTools_DataMixin:Call('AchievementFrame_SelectAchievement', achievementID, true)
end


--AchievementFrame_SelectAchievement(6779)
--[[
战斗中，打不开
journalType 0=Instance, 1=Encounter, 2=Section.
journalID InstanceID, EncounterID, or SectionID.
difficulty DifficultyID of the instance.

AdventureGuideUtil.lua
https://warcraft.wiki.gg/wiki/DifficultyID
Blizzard_SharedMapDataProviders/DungeonEntranceDataProvider.lua
|Hjournal:1:2568:23|h[虚空石畸体]|h
EncounterJournal_DisplayInstance

function EncounterJournalPinMixin:OnMouseClickAction()
	EncounterJournal_LoadUI();
	EncounterJournal_OpenJournal(nil, self.instanceID, self.encounterID);
end

WoWTools_DataMixin:Call(ToggleEncounterJournal)
]]
function WoWTools_LoadUIMixin:JournalInstance(journalType, journalInstanceID, difficultyID)
    if not AdventureGuideUtil.IsAvailable()
        or not journalInstanceID
        or (InCombatLockdown() and (not EncounterJournal or not EncounterJournal:IsShown()))
        or self:IsDisabledOpenFrame()
    then
        return
    end
    AdventureGuideUtil.OpenJournalLink(journalType or 0, journalInstanceID, difficultyID or 23)
end


--[[
DelvesCompanionConfigurationFrame.playerCompanionID = companionID
TraitUtil.OpenTraitFrame(traitTreeID)
ShowUIPanel(DelvesCompanionConfigurationFrame)
ShowUIPanel(DelvesCompanionAbilityListFrame)
]]
function WoWTools_LoadUIMixin:OpenCompanion(companionID)
    if InCombatLockdown() or self:IsDisabledOpenFrame() or not DelvesCompanionConfigurationFrame then
        return
    end

    if not companionID then
        local factionID= C_DelvesUI.GetDelvesFactionForSeason()-- or 2272
        if factionID then
            local major= C_MajorFactions.GetMajorFactionData(factionID)
            if major then
                companionID= major.playerCompanionID
            end
        end
    end

    local traitTreeID = C_DelvesUI.GetTraitTreeForCompanion(companionID)
    local configID= traitTreeID and C_Traits.GetConfigIDByTreeID(traitTreeID)

    if not configID then
        return
    end

    DelvesCompanionConfigurationFrame.playerCompanionID = companionID
    ShowUIPanel(DelvesCompanionConfigurationFrame)
end

function WoWTools_LoadUIMixin:Housing()
    if not HousingDashboardFrame then
        do
            HousingFramesUtil.ToggleHousingDashboard()
        end
        if HousingDashboardFrame and HousingDashboardFrame:IsShown() then
            HousingFramesUtil.ToggleHousingDashboard()
        end
    end
end