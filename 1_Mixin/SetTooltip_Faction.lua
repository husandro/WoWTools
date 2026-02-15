
--ReputationEntryMixin
local function ShowParagonRewardsTooltip(frame)
	EmbeddedItemTooltip:SetOwner(frame, frame.anchor or "ANCHOR_LEFT")
	ReputationParagonFrame_SetupParagonTooltip(frame)
	if frame.canClickForOptions then
		GameTooltip_SetBottomText(EmbeddedItemTooltip, WoWTools_DataMixin.onlyChinese and '<点击查看旅程>' or JOURNEYS_TOOLTIP_VIEW_JOURNEY or REPUTATION_BUTTON_TOOLTIP_CLICK_INSTRUCTION, GREEN_FONT_COLOR)
	end
	WoWTools_TooltipMixin:Set_Faction(EmbeddedItemTooltip, frame.factionID)
	EmbeddedItemTooltip:Show()
end

local function ShowFriendshipReputationTooltip(frame)
	local factionID= frame.factionID
	local friendshipData = C_GossipInfo.GetFriendshipReputation(factionID)
	if not friendshipData
		or not friendshipData.friendshipFactionID
		or friendshipData.friendshipFactionID < 0
	then
		return
	end
	GameTooltip:SetOwner(frame, frame.anchor or  "ANCHOR_LEFT")

	local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(friendshipData.friendshipFactionID)
	if rankInfo.maxLevel > 0 then
		GameTooltip_SetTitle(GameTooltip, WoWTools_TextMixin:CN(friendshipData.name).." ("..rankInfo.currentLevel.."/"..rankInfo.maxLevel..")")
	else
		GameTooltip_SetTitle(GameTooltip, WoWTools_TextMixin:CN(friendshipData.name))
	end
	ReputationUtil.TryAppendAccountReputationLineToTooltip(GameTooltip, factionID)
	GameTooltip:AddLine(WoWTools_TextMixin:CN(friendshipData.text), nil, nil, nil, true)

	--GameTooltip_AddBlankLineToTooltip(GameTooltip)
	if friendshipData.nextThreshold then
		local current = friendshipData.standing - friendshipData.reactionThreshold
		local max = friendshipData.nextThreshold - friendshipData.reactionThreshold
		GameTooltip_AddHighlightLine(GameTooltip, WoWTools_TextMixin:CN(friendshipData.reaction).." ("..current.." / "..max..")")
	else
		GameTooltip_AddHighlightLine(GameTooltip, WoWTools_TextMixin:CN(friendshipData.reaction))
	end
	if frame.canClickForOptions then
		GameTooltip_AddBlankLineToTooltip(GameTooltip)
		GameTooltip_AddInstructionLine(GameTooltip, WoWTools_DataMixin.onlyChinese and '<点击查看选项>' or REPUTATION_BUTTON_TOOLTIP_CLICK_INSTRUCTION)
	end
	WoWTools_TooltipMixin:Set_Faction(GameTooltip, factionID)
	GameTooltip:Show()
end

local function ShowMajorFactionRenownTooltip(frame)
	local factionID= frame.factionID
	GameTooltip:SetOwner(frame, frame.anchor or  "ANCHOR_LEFT")
	RenownRewardUtil.AddMajorFactionToTooltip(GameTooltip, factionID, GenerateClosure(ShowMajorFactionRenownTooltip, frame))
	EventRegistry:TriggerEvent("ShowMajorFactionRenown.Tooltip.OnEnter", frame, GameTooltip, factionID)

--未解锁
	local major= C_MajorFactions.GetMajorFactionData(factionID)
	if major and not major.isUnlocked and major.unlockDescription and major.unlockDescription~='' then
		GameTooltip_AddBlankLineToTooltip(GameTooltip)
		GameTooltip_AddErrorLine(GameTooltip, WoWTools_TextMixin:CN(major.unlockDescription), true)
	end

	if C_MajorFactions.IsWeeklyRenownCapped(factionID) then
		GameTooltip_AddErrorLine(GameTooltip,WoWTools_DataMixin.onlyChinese and '本周达到上限' or format(CURRENCY_THIS_WEEK, CAPPED))
	end

	if frame.canClickForOptions then
		GameTooltip_AddBlankLineToTooltip(GameTooltip)
		GameTooltip_AddInstructionLine(GameTooltip, WoWTools_DataMixin.onlyChinese and '<点击查看选项>>' or REPUTATION_BUTTON_TOOLTIP_CLICK_INSTRUCTION)
	end

	WoWTools_TooltipMixin:Set_Faction(GameTooltip, factionID)
	GameTooltip:Show()
end

local function ShowStandardTooltip(frame)
	local factionID= frame.factionID
	local factionData = C_Reputation.GetFactionDataByID(factionID)
	if factionData then
		GameTooltip:SetOwner(frame, frame.anchor or  "ANCHOR_LEFT")
		GameTooltip_SetTitle(GameTooltip, WoWTools_TextMixin:CN(factionData.name))
		ReputationUtil.TryAppendAccountReputationLineToTooltip(GameTooltip, factionID)
		GameTooltip_AddNormalLine(GameTooltip, WoWTools_TextMixin:CN(factionData.description), true)

		if frame.canClickForOptions then
			GameTooltip_AddBlankLineToTooltip(GameTooltip)
			GameTooltip_AddInstructionLine(GameTooltip, WoWTools_DataMixin.onlyChinese and '<点击查看选项>' or REPUTATION_BUTTON_TOOLTIP_CLICK_INSTRUCTION)
		end
		WoWTools_TooltipMixin:Set_Faction(GameTooltip, factionID)
		GameTooltip:Show()
	end
end


--需要GameTooltip:Show() EmbeddedItemTooltip_Hide(EmbeddedItemTooltip)
function WoWTools_SetTooltipMixin:Faction(frame)--ANCHOR_RIGHT=true
	local factionID
	if frame then
		factionID= frame.factionID
			or (frame.data and frame.data.factionID)
			or (frame.elementData and frame.elementData.factionID)
	end

    if not factionID then
		return
	end

	local friendshipData = C_GossipInfo.GetFriendshipReputation(factionID)
	local isMajor= C_Reputation.IsMajorFaction(factionID)

	if C_Reputation.IsFactionParagonForCurrentPlayer(factionID) then
		ShowParagonRewardsTooltip(frame)

	elseif friendshipData and friendshipData.friendshipFactionID and friendshipData.friendshipFactionID>0 then
		ShowFriendshipReputationTooltip(frame)

	elseif isMajor then
		ShowMajorFactionRenownTooltip(frame)
	else
		ShowStandardTooltip(frame)
	end

end


function WoWTools_SetTooltipMixin:FactionMenu(root)
	root:SetOnEnter(function(btn, description)
		btn.factionID= description.data.factionID
		self:Faction(btn)
	end)
	root:SetOnLeave(function(btn)
		btn.factionID=nil
		self:Hide()
	end)
end


function WoWTools_SetTooltipMixin:Hide()
	EmbeddedItemTooltip:SetShown(false)
	GameTooltip_Hide()
end