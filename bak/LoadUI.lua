---@diagnostic disable: undefined-global, redefined-local, assign-type-mismatch, undefined-field, inject-field, missing-parameter, redundant-parameter, unused-local, trailing-space, param-type-mismatch, duplicate-set-field



function ItemInteraction_LoadUI()
	UIParentLoadAddOn("Blizzard_ItemInteractionUI");
end

function IslandsQueue_LoadUI()
	UIParentLoadAddOn("Blizzard_IslandsQueueUI");
end

function PartyPose_LoadUI()
	UIParentLoadAddOn("Blizzard_PartyPoseUI");
end

function IslandsPartyPose_LoadUI()
	UIParentLoadAddOn("Blizzard_IslandsPartyPoseUI");
end

function WarfrontsPartyPose_LoadUI()
	UIParentLoadAddOn("Blizzard_WarfrontsPartyPoseUI");
end

function MatchCelebrationPartyPose_LoadUI()
	UIParentLoadAddOn("Blizzard_MatchCelebrationPartyPoseUI");
end

function AlliedRaces_LoadUI()
	UIParentLoadAddOn("Blizzard_AlliedRacesUI");
end

function AuctionHouseFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_AuctionHouseUI");
end

function ProfessionsCustomerOrders_LoadUI()
	UIParentLoadAddOn("Blizzard_ProfessionsCustomerOrders");
end

function BattlefieldMap_LoadUI()
	UIParentLoadAddOn("Blizzard_BattlefieldMap");
end

function ClassTrainerFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_TrainerUI");
end

function CombatLog_LoadUI()
	UIParentLoadAddOn("Blizzard_CombatLog");
end

function Commentator_LoadUI()
	UIParentLoadAddOn("Blizzard_Commentator");
end

function GuildBankFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_GuildBankUI");
end

function InspectFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_InspectUI");
end

function KeyBindingFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_BindingUI");
end

function ClickBindingFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_ClickBindingUI");
end

function MacroFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_MacroUI");
end
function MacroFrame_SaveMacro()
	-- this will be overwritten with the real thing when the addon is loaded
end

function RaidFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_RaidUI");
end

function SocialFrame_LoadUI()
	AchievementFrame_LoadUI();
	UIParentLoadAddOn("Blizzard_SocialUI");
end

function TalentFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_TalentUI");
end

function ClassTalentFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_ClassTalentUI");
end

function ProfessionsFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_Professions");
end

function ObliterumForgeFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_ObliterumUI");
end

function ScrappingMachineFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_ScrappingMachineUI");
end

function ItemSocketingFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_ItemSocketingUI");
end

function ArtifactFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_ArtifactUI");
end

function AdventureMapFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_AdventureMap");
end

function BarberShopFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_BarberShopUI");
end

function PerksProgramFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_PerksProgram");
end

function AchievementFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_AchievementUI");
end

function TimeManager_LoadUI()
	UIParentLoadAddOn("Blizzard_TimeManager");
end

function TokenFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_TokenUI");
end

function Calendar_LoadUI()
	UIParentLoadAddOn("Blizzard_Calendar");
end

function VoidStorage_LoadUI()
	UIParentLoadAddOn("Blizzard_VoidStorageUI");
end

function ArchaeologyFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_ArchaeologyUI");
end

function GMChatFrame_LoadUI(...)
	if ( C_AddOns.IsAddOnLoaded("Blizzard_GMChatUI") ) then
		return;
	else
		UIParentLoadAddOn("Blizzard_GMChatUI");
		if ( select(1, ...) ) then
			GMChatFrame_OnEvent(GMChatFrame, ...);
		end
	end
end

function EncounterJournal_LoadUI()
	UIParentLoadAddOn("Blizzard_EncounterJournal");
end

function CollectionsJournal_LoadUI()
	UIParentLoadAddOn("Blizzard_Collections");
end

function BlackMarket_LoadUI()
	UIParentLoadAddOn("Blizzard_BlackMarketUI");
end

function ItemUpgrade_LoadUI()
	-- ACHURCHILL TODO: remove once item upgrade testing is done
	if not OldItemUpgradeFrame then
		UIParentLoadAddOn("Blizzard_ItemUpgradeUI");
	end
end

function PlayerChoice_LoadUI()
	UIParentLoadAddOn("Blizzard_PlayerChoice");
end

function Store_LoadUI()
	UIParentLoadAddOn("Blizzard_StoreUI");
end

function Garrison_LoadUI()
	UIParentLoadAddOn("Blizzard_GarrisonUI");
end

function OrderHall_LoadUI()
	UIParentLoadAddOn("Blizzard_OrderHallUI");
end

function MajorFactions_LoadUI()
	UIParentLoadAddOn("Blizzard_MajorFactions");
end

function ChallengeMode_LoadUI()
	UIParentLoadAddOn("Blizzard_ChallengesUI");
end

function FlightMap_LoadUI()
	UIParentLoadAddOn("Blizzard_FlightMap");
end

function APIDocumentation_LoadUI()
	UIParentLoadAddOn("Blizzard_APIDocumentationGenerated");
end

function CovenantSanctum_LoadUI()
	UIParentLoadAddOn("Blizzard_CovenantSanctum");
end

function CovenantRenown_LoadUI()
	UIParentLoadAddOn("Blizzard_CovenantRenown");
end

function WeeklyRewards_LoadUI()
	UIParentLoadAddOn("Blizzard_WeeklyRewards");
end

function WeeklyRewards_ShowUI()
	if not WeeklyRewardsFrame then
		WeeklyRewards_LoadUI();
	end

	local force = true;	-- this could bWoWTools_DataMixin:Called from the world map which might be in fullscreen mode

	ShowUIPanel(WeeklyRewardsFrame, force);
end

--[[
function MovePad_LoadUI()
	UIParentLoadAddOn("Blizzard_MovePad");
end
]]

function NPE_CheckTutorials()
	if C_PlayerInfo.IsPlayerNPERestricted() and UnitLevel("player") == 1 then
		-- Hacky 9.0.1 fix for WOW9-58485...just force tutorials to on if they are entering Exile's Reach on a level 1 character
		SetCVar("showTutorials", 1);
	end

	NPE_LoadUI();
end

function NPE_LoadUI()
	if ( not GetTutorialsEnabled() or C_AddOns.IsAddOnLoaded("Blizzard_NewPlayerExperience") ) then
		return;
	end
	local isRestricted = C_PlayerInfo.IsPlayerNPERestricted();
	if  isRestricted then
		UIParentLoadAddOn("Blizzard_NewPlayerExperience");
	end
end

function BoostTutorial_AttemptLoad()
	if IsBoostTutorialScenario() and not C_AddOns.IsAddOnLoaded("Blizzard_BoostTutorial") then
		UIParentLoadAddOn("Blizzard_BoostTutorial");
	end
end

function ClassTrial_AttemptLoad()
	if C_ClassTrial.IsClassTrialCharacter() and not C_AddOns.IsAddOnLoaded("Blizzard_ClassTrial") then
		UIParentLoadAddOn("Blizzard_ClassTrial");
	end
end

function ClassTrial_IsExpansionTrialUpgradeDialogShowing()
	if ExpansionTrialThanksForPlayingDialog then
		return ExpansionTrialThanksForPlayingDialog:IsShowingExpansionTrialUpgrade();
	end

	if ExpansionTrialCheckPointDialog then
		return ExpansionTrialCheckPointDialog:IsShowingExpansionTrialUpgrade();
	end

	return false;
end

function ExpansionTrial_CheckLoadUI()
	local isExpansionTrial = GetExpansionTrialInfo();
	if isExpansionTrial then
		UIParentLoadAddOn("Blizzard_ExpansionTrial");
	end
end

function DeathRecap_LoadUI()
	UIParentLoadAddOn("Blizzard_DeathRecap");
end

function Communities_LoadUI()
	UIParentLoadAddOn("Blizzard_Communities");
end

function AzeriteRespecFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_AzeriteRespecUI");
end

function ChromieTimeFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_ChromieTimeUI");
end

function CovenantPreviewFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_CovenantPreviewUI");
end

function AnimaDiversionFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_AnimaDiversionUI");
end

function RuneforgeFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_RuneforgeUI");
end

function GenericTraitUI_LoadUI()
	UIParentLoadAddOn("Blizzard_GenericTraitUI");
end

function SubscriptionInterstitial_LoadUI()
	C_AddOns.LoadAddOn("Blizzard_SubscriptionInterstitialUI");
end
