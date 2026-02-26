--AlertFrameSystems.lua
    WoWTools_DataMixin:Hook('DungeonCompletionAlertFrameReward_SetRewardItem', function(frame, itemLink)--,texture
        WoWTools_ItemMixin:SetItemStats(frame, frame.itemLink or itemLink , {point=frame.texture})
    end)
    --[[
    function AlertFrameSystems_Register()
	-- luacheck: ignore 111 (setting non-standard global variable)
	GuildChallengeAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("GuildChallengeAlertFrameTemplate", GuildChallengeAlertFrame_SetUp);
	DungeonCompletionAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("DungeonCompletionAlertFrameTemplate", DungeonCompletionAlertFrame_SetUp);
	ScenarioAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("ScenarioAlertFrameTemplate", ScenarioAlertFrame_SetUp);
	InvasionAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("ScenarioLegionInvasionAlertFrameTemplate", ScenarioLegionInvasionAlertFrame_SetUp, ScenarioLegionInvasionAlertFrame_Coalesce);
	DigsiteCompleteAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("DigsiteCompleteToastFrameTemplate", DigsiteCompleteToastFrame_SetUp);
	EntitlementDeliveredAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("EntitlementDeliveredAlertFrameTemplate", EntitlementDeliveredAlertFrame_SetUp);
	RafRewardDeliveredAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("RafRewardDeliveredAlertFrameTemplate", RafRewardDeliveredAlertFrame_SetUp);
	GarrisonBuildingAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("GarrisonBuildingAlertFrameTemplate", GarrisonBuildingAlertFrame_SetUp);
	GarrisonMissionAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("GarrisonStandardMissionAlertFrameTemplate", GarrisonMissionAlertFrame_SetUp);
	GarrisonShipMissionAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("GarrisonShipMissionAlertFrameTemplate", GarrisonMissionAlertFrame_SetUp);
	GarrisonRandomMissionAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("GarrisonRandomMissionAlertFrameTemplate", GarrisonRandomMissionAlertFrame_SetUp);
	GarrisonFollowerAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("GarrisonStandardFollowerAlertFrameTemplate", GarrisonFollowerAlertFrame_SetUp);
	GarrisonShipFollowerAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("GarrisonShipFollowerAlertFrameTemplate", GarrisonShipFollowerAlertFrame_SetUp);
	GarrisonTalentAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("GarrisonTalentAlertFrameTemplate", GarrisonTalentAlertFrame_SetUp);
	WorldQuestCompleteAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("WorldQuestCompleteAlertFrameTemplate", WorldQuestCompleteAlertFrame_SetUp, WorldQuestCompleteAlertFrame_Coalesce);
	LegendaryItemAlertSystem = AlertFrame:AddSimpleAlertFrameSubSystem("LegendaryItemAlertFrameTemplate", LegendaryItemAlertFrame_SetUp);
	NewPetAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("NewPetAlertFrameTemplate", NewPetAlertFrame_SetUp);
	NewMountAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("NewMountAlertFrameTemplate", NewMountAlertFrame_SetUp);
	NewToyAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("NewToyAlertFrameTemplate", NewToyAlertFrame_SetUp);
	NewWarbandSceneAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("NewWarbandSceneAlertFrameTemplate", NewWarbandSceneAlertFrame_SetUp);
	NewRuneforgePowerAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("NewRuneforgePowerAlertFrameTemplate", NewRuneforgePowerAlertSystem_SetUp);
	NewCosmeticAlertFrameSystem = AlertFrame:AddQueuedAlertFrameSubSystem("NewCosmeticAlertFrameTemplate", NewCosmeticAlertFrameSystem_SetUp);
	HousingItemEarnedAlertFrameSystem = AlertFrame:AddQueuedAlertFrameSubSystem("HousingItemEarnedAlertFrameTemplate", HousingItemEarnedAlertFrameSystem_SetUp);
	InitiativeTaskCompleteAlertFrameSystem = AlertFrame:AddQueuedAlertFrameSubSystem("InitiativeTaskCompleteAlertFrameTemplate", InitiativeTaskCompleteAlertFrameSystem_SetUp);
end

    ]]