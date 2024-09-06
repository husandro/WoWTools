WoWTools_TooltipMixin={}
--[[
SetTooltip(tooltip, data, root, frame)
]]


local e= select(2, ...)













local function ShowParagonRewardsTooltip(self)
	Set_SetOwner(self, EmbeddedItemTooltip);
	ReputationParagonFrame_SetupParagonTooltip(self);
	EmbeddedItemTooltip:Show()
end
local function TryAppendAccountReputationLineToTooltip(tooltip, factionID)
	if not tooltip or not factionID or not C_Reputation.IsAccountWideReputation(factionID) then
		return;
	end
	GameTooltip_AddColoredLine(tooltip, e.onlyChinese and '战团声望' or REPUTATION_TOOLTIP_ACCOUNT_WIDE_LABEL, ACCOUNT_WIDE_FONT_COLOR, false);
end



local function AddRenownRewardsToTooltip(self, renownRewards)
	GameTooltip_AddHighlightLine(tooltip, '接下来的奖励：');

	for i, rewardInfo in ipairs(renownRewards) do
		local renownRewardString;
		local icon, name = RenownRewardUtil.GetRenownRewardInfo(rewardInfo, GenerateClosure(self.ShowMajorFactionRenownTooltip, self));
		if icon then
			local file, width, height = icon, 16, 16;
			local rewardTexture = CreateSimpleTextureMarkup(file, width, height);
			renownRewardString = rewardTexture .. " " .. e.cn(name)
		end
		local wrapText = false;
		GameTooltip_AddNormalLine(tooltip, renownRewardString, wrapText);
	end
end




local function ShowMajorFactionRenownTooltip(tooltip, data)
	local majorFactionData = C_MajorFactions.GetMajorFactionData(data.factionID) or {}
	GameTooltip_SetTitle(tooltip, e.cn(majorFactionData.name), HIGHLIGHT_FONT_COLOR);
	TryAppendAccountReputationLineToTooltip(tooltip, data.factionID);
	GameTooltip_AddHighlightLine(tooltip, (e.onlyChinese and '名望' or RENOWN_LEVEL_LABEL).. majorFactionData.renownLevel);
	GameTooltip_AddBlankLineToTooltip(tooltip);
	GameTooltip_AddNormalLine(tooltip, format(e.onlyChinese and '继续获取%s的声望以提升名望并解锁奖励。' or MAJOR_FACTION_RENOWN_TOOLTIP_PROGRESS, e.cn(majorFactionData.name)))
	GameTooltip_AddBlankLineToTooltip(tooltip);
	local nextRenownRewards = C_MajorFactions.GetRenownRewardsForLevel(data.factionID, C_MajorFactions.GetCurrentRenownLevel(self.factionID) + 1);
	if #nextRenownRewards > 0 then
		AddRenownRewardsToTooltip(nextRenownRewards);
	end
	return tooltip
end


local function ShowFriendshipReputationTooltip(tooltip, data)
	local friendshipData = C_GossipInfo.GetFriendshipReputation(data.factionID);
	if not friendshipData or friendshipData.friendshipFactionID < 0 then
		return;
	end
	local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(friendshipData.friendshipFactionID);
	if rankInfo.maxLevel > 0 then
		GameTooltip_SetTitle(tooltip, friendshipData.name.." ("..rankInfo.currentLevel.." / "..rankInfo.maxLevel..")", HIGHLIGHT_FONT_COLOR);
	else
		GameTooltip_SetTitle(tooltip, friendshipData.name, HIGHLIGHT_FONT_COLOR);
	end
	TryAppendAccountReputationLineToTooltip(tooltip, data.factionID);
	GameTooltip_AddBlankLineToTooltip(tooltip);
	tooltip:AddLine(friendshipData.text, nil, nil, nil, true);
	if friendshipData.nextThreshold then
		local current = friendshipData.standing - friendshipData.reactionThreshold;
		local max = friendshipData.nextThreshold - friendshipData.reactionThreshold;
		local wrapText = true;
		GameTooltip_AddHighlightLine(tooltip, friendshipData.reaction.." ("..current.." / "..max..")", wrapText);
	else
		local wrapText = true;
		GameTooltip_AddHighlightLine(tooltip, friendshipData.reaction, wrapText);
	end
	return tooltip
end


local function ShowStandardTooltip(tooltip, data)
	GameTooltip_SetTitle(tooltip, e.cn(data.name))
	TryAppendAccountReputationLineToTooltip(tooltip, data.factionID);
	return tooltip
end




























local function set_vignetteGUID(tooltip, vignetteGUID)
    local vignetteInfo = C_VignetteInfo.GetVignetteInfo(vignetteGUID)
    if not vignetteInfo then
        return
    end
    local verticalPadding = nil
    local waitingForData, titleAdded = false, false

    if vignetteInfo.type == Enum.VignetteType.Normal or vignetteInfo.type == Enum.VignetteType.Treasure then
        GameTooltip_SetTitle(tooltip, e.cn(vignetteInfo.name))
        titleAdded = true

    elseif vignetteInfo.type == Enum.VignetteType.PvPBounty then
        local player = PlayerLocation:CreateFromGUID(vignetteInfo.objectGUID)
        local class = select(3, C_PlayerInfo.GetClass(player))
        local race = C_PlayerInfo.GetRace(player)
        local name = C_PlayerInfo.GetName(player)
        if race and class and name then
            local classInfo = C_CreatureInfo.GetClassInfo(class) or {}
            local factionInfo = C_CreatureInfo.GetFactionInfo(race) or {}
            GameTooltip_SetTitle(tooltip, e.cn(name), GetClassColorObj(classInfo.classFile))
            GameTooltip_AddColoredLine(tooltip, e.cn(factionInfo.name), GetFactionColor(factionInfo.groupTag))
            if vignetteInfo.rewardQuestID then
                GameTooltip_AddQuestRewardsToTooltip(tooltip, vignetteInfo.rewardQuestID, TOOLTIP_QUEST_REWARDS_STYLE_PVP_BOUNTY)
            end
            titleAdded=true
        end
        waitingForData = not titleAdded

    elseif vignetteInfo.type == Enum.VignetteType.Torghast then
        SharedTooltip_SetBackdropStyle(tooltip, GAME_TOOLTIP_BACKDROP_STYLE_RUNEFORGE_LEGENDARY)
        GameTooltip_SetTitle(tooltip, e.cn(vignetteInfo.name))
        titleAdded = true
    end

    if not waitingForData and vignetteInfo.widgetSetID then
        local overflow = GameTooltip_AddWidgetSet(tooltip, vignetteInfo.widgetSetID, titleAdded and vignetteInfo.addPaddingAboveWidgets and 10)
        if overflow then
            verticalPadding = -overflow
        end
    elseif waitingForData then
        GameTooltip_SetTitle(tooltip, e.onlyChinese and '获取数据' or RETRIEVING_DATA)
    end
    if verticalPadding then
        tooltip:SetPadding(0, verticalPadding)
    end
end







--areaPoi AreaPOIPinMixin:TryShowTooltip()
local function set_areaPoiID(tooltip, uiMapID, areaPoiID)
    local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID) or {}
    local hasName = poiInfo.name ~= ""
    local hasDescription = poiInfo.description and poiInfo.description ~= ""
    local isTimed, hideTimer = C_AreaPoiInfo.IsAreaPOITimed(areaPoiID)
    local showTimer = isTimed and not hideTimer
    local hasWidgetSet = poiInfo.widgetSetID ~= nil

    local hasTooltip = hasDescription or showTimer or hasWidgetSet
    local addedTooltipLine = false

    if hasTooltip then
        local verticalPadding = nil

        if hasName then
            GameTooltip_SetTitle(tooltip, e.cn(poiInfo.name), HIGHLIGHT_FONT_COLOR)
            addedTooltipLine = true
        end

        if hasDescription then
            GameTooltip_AddNormalLine(tooltip, e.cn(poiInfo.description))
            addedTooltipLine = true
        end

        if showTimer then
            local secondsLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(areaPoiID)
            if secondsLeft and secondsLeft > 0 then
                local timeString = SecondsToTime(secondsLeft)
                GameTooltip_AddNormalLine(tooltip, format(e.onlyChinese and '剩余时间：%s' or BONUS_OBJECTIVE_TIME_LEFT, timeString))
                addedTooltipLine = true
            end
        end

        --[[if poiInfo.textureKit == "OribosGreatVault" then
            GameTooltip_AddBlankLineToTooltip(tooltip)
            GameTooltip_AddInstructionLine(tooltip, ORIBOS_GREAT_VAULT_POI_TOOLTIP_INSTRUCTIONS)
            addedTooltipLine = true
        end]]

        if hasWidgetSet then
            local overflow = GameTooltip_AddWidgetSet(tooltip, poiInfo.widgetSetID, addedTooltipLine and poiInfo.addPaddingAboveWidgets and 10)
            if overflow then
                verticalPadding = -overflow
            end
        end

        if poiInfo.uiTextureKit then
            local backdropStyle = GAME_TOOLTIP_TEXTUREKIT_BACKDROP_STYLES[poiInfo.uiTextureKit]
            if (backdropStyle) then
                SharedTooltip_SetBackdropStyle(tooltip, backdropStyle)
            end
        end
        -- need to set padding after Show or else there will be a flicker
        if verticalPadding then
            tooltip:SetPadding(0, verticalPadding)
        end
    end
end

















function WoWTools_TooltipMixin:set_tooltip(tooltip, data)
    if type(data)~='table' then
        return
    end
    local itemLink= data.link or data.itemLink or data.spellLink
    local itemID= data.itemID
    local spellID= data.spellID
    local currencyID= data.currencyID
    local achievementID= data.achievementID
    
    local questID= data.questID
    local frame= data.frame
    local rewardQuestID= data.rewardQuestID

    local widgetSetID= data.widgetSetID
    local vignetteGUID= data.vignetteGUID

    local uiMapID= data.uiMapID
    local areaPoiID= data.uiMapID

    local tip= data.tooltip
    local factionID= data.factionID

    if itemLink then
        if itemLink:find('Hbattlepet:%d+') then
            BattlePetToolTip_Show(BattlePetToolTip_UnpackBattlePetLink(itemLink))
            return
        else
            tooltip:SetHyperlink(itemLink)
        end

    elseif itemID then
        if C_ToyBox.GetToyInfo(itemID) then
            tooltip:SetToyByItemID(itemID)
        else
            tooltip:SetItemByID(itemID)
        end

    elseif spellID then
        tooltip:SetSpellByID(spellID)

    elseif currencyID then
        tooltip:SetCurrencyByID(currencyID)

    elseif widgetSetID then
        GameTooltip_AddWidgetSet(tooltip, widgetSetID)

    elseif achievementID then
        tooltip:SetAchievementByID(achievementID)

    elseif questID then
        GameTooltip_AddQuest(frame, questID)
        GameTooltip_AddQuestTimeToTooltip(tooltip, questID)

    elseif rewardQuestID then
        GameTooltip_AddQuestRewardsToTooltip(tooltip, rewardQuestID)
        GameTooltip_AddQuestTimeToTooltip(tooltip, questID)

    elseif vignetteGUID then
        set_vignetteGUID(tooltip, vignetteGUID)

    elseif uiMapID and areaPoiID then
        set_areaPoiID(tooltip, uiMapID, areaPoiID)

    end

    if tip then
        GameTooltip_AddNormalLine(tooltip, type(tip)=='function' and tip() or tip, true)
    end
end


















function WoWTools_TooltipMixin:SetTooltip(tooltip, data, root, frame)
    if root then
        root:SetTooltip(function(tip, description)
            self:set_tooltip(tip, description.data)
        end)
    elseif frame then
        tooltip= tooltip or GameTooltip
        tooltip:SetOwner(frame, "ANCHOR_LEFT");
        tooltip:ClearLines()
        self:set_tooltip(tooltip, data)
        tooltip:Show();
    else
        self:set_tooltip(tooltip, data)
    end
end