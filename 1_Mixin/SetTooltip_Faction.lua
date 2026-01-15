--[[

local function AddRenownRewardsToTooltip(self, renownRewards)
	if not renownRewards then
		return
	end
	GameTooltip_AddHighlightLine(GameTooltip, WoWTools_DataMixin.onlyChinese and '接下来的奖励：' or MAJOR_FACTION_BUTTON_TOOLTIP_NEXT_REWARDS)

	for _, rewardInfo in ipairs(renownRewards) do
		local renownRewardString
		local icon, name = RenownRewardUtil.GetRenownRewardInfo(rewardInfo, GenerateClosure(self.ShowMajorFactionRenownTooltip, self))
		if icon then
			local file, width, height = icon, 16, 16
			local rewardTexture = CreateSimpleTextureMarkup(file, width, height)
			renownRewardString = rewardTexture .. " " .. WoWTools_TextMixin:CN(name)
		end
		local wrapText = false
		GameTooltip_AddNormalLine(GameTooltip, renownRewardString, wrapText)
	end
end

local function TryAppendAccountReputationLineToTooltip(tooltip, factionID)
	if not tooltip or not factionID or not C_Reputation.IsAccountWideReputation(factionID) then
		return
	end
	GameTooltip_AddColoredLine(tooltip, WoWTools_DataMixin.onlyChinese and '战团声望' or REPUTATION_TOOLTIP_ACCOUNT_WIDE_LABEL, ACCOUNT_WIDE_FONT_COLOR, false)
end









--Paragon
local function ShowParagonRewardsTooltip(self)

    EmbeddedItemTooltip:SetOwner(self, self.ANCHOR_RIGHT and 'ANCHOR_RIGHT' or "ANCHOR_LEFT")

	C_Reputation.RequestFactionParagonPreloadRewardData(self.factionID)
	ReputationParagonFrame_SetupParagonTooltip(self)
	GameTooltip_AddBlankLineToTooltip(EmbeddedItemTooltip)
	WoWTools_TooltipMixin:Set_Faction(EmbeddedItemTooltip, self.factionID)
	EmbeddedItemTooltip:Show()
end

--Friendship
local function ShowFriendshipReputationTooltip(self)
	local friendshipData = C_GossipInfo.GetFriendshipReputation(self.factionID)



	if not friendshipData or friendshipData.friendshipFactionID < 0 then
		return false
	end

	GameTooltip:SetOwner(self, self.ANCHOR_RIGHT and "ANCHOR_RIGHT" or  "ANCHOR_LEFT")

	local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(friendshipData.friendshipFactionID)

	local name= WoWTools_TextMixin:CN(friendshipData.name or self.name)
	if not name then
		local data= C_Reputation.GetFactionDataByID(self.factionID)
		name= data and WoWTools_TextMixin:CN(data.name) or self.factionID
	end


	if rankInfo.maxLevel > 0 then
		GameTooltip_SetTitle(GameTooltip, name.." ("..rankInfo.currentLevel.." / "..rankInfo.maxLevel..")", HIGHLIGHT_FONT_COLOR)
	else
		GameTooltip_SetTitle(GameTooltip, name, HIGHLIGHT_FONT_COLOR)
	end
	TryAppendAccountReputationLineToTooltip(GameTooltip, self.factionID)

	if friendshipData.text and friendshipData.text~='' or (friendshipData.reaction and friendshipData.reaction~='') then
		GameTooltip_AddBlankLineToTooltip(GameTooltip)
	end

	GameTooltip:AddLine(friendshipData.text, nil, nil, nil, true)
	if friendshipData.nextThreshold then
		local current = friendshipData.standing - friendshipData.reactionThreshold
		local max = friendshipData.nextThreshold - friendshipData.reactionThreshold
		local wrapText = true
		GameTooltip_AddHighlightLine(GameTooltip, friendshipData.reaction.." ("..current.." / "..max..")", wrapText)
	else
		local wrapText = true
		GameTooltip_AddHighlightLine(GameTooltip, friendshipData.reaction, wrapText)
	end
	GameTooltip_AddBlankLineToTooltip(GameTooltip)
	WoWTools_TooltipMixin:Set_Faction(GameTooltip, self.factionID)

	GameTooltip:Show()

	return true
end

--Major
local function ShowMajorFactionRenownTooltip(self)
	local majorFactionData = C_MajorFactions.GetMajorFactionData(self.factionID)

	if not majorFactionData then
		return
	end

	
	GameTooltip:SetOwner(self, self.ANCHOR_RIGHT and 'ANCHOR_RIGHT' or "ANCHOR_LEFT")
	GameTooltip_SetTitle(GameTooltip, WoWTools_TextMixin:CN(majorFactionData.name), HIGHLIGHT_FONT_COLOR)

	TryAppendAccountReputationLineToTooltip(GameTooltip, self.factionID)

	GameTooltip_AddHighlightLine(GameTooltip, (WoWTools_DataMixin.onlyChinese and '名望' or RENOWN_LEVEL_LABEL).. majorFactionData.renownLevel)

	GameTooltip_AddBlankLineToTooltip(GameTooltip)
	GameTooltip_AddNormalLine(GameTooltip, format(WoWTools_DataMixin.onlyChinese and '继续获取%s的声望以提升名望并解锁奖励。' or MAJOR_FACTION_RENOWN_TOOLTIP_PROGRESS, WoWTools_TextMixin:CN(majorFactionData.name)))

	GameTooltip_AddBlankLineToTooltip(GameTooltip)
	local nextRenownRewards = C_MajorFactions.GetRenownRewardsForLevel(self.factionID, C_MajorFactions.GetCurrentRenownLevel(self.factionID) + 1)
	if #nextRenownRewards > 0 then
		AddRenownRewardsToTooltip(self, nextRenownRewards)
	end

	if not majorFactionData.isUnlocked then
		GameTooltip_AddBlankLineToTooltip(GameTooltip)
		GameTooltip_AddErrorLine(GameTooltip, format(
			WoWTools_DataMixin.onlyChinese and  '%s尚未解锁' or ERR_AZERITE_ESSENCE_SELECTION_FAILED_ESSENCE_NOT_UNLOCKED,
			majorFactionData.unlockOrder or ''
		))
		GameTooltip_AddInstructionLine(GameTooltip, WoWTools_TextMixin:CN(majorFactionData.unlockDescription), true)
	end
	GameTooltip_AddBlankLineToTooltip(GameTooltip)
	WoWTools_TooltipMixin:Set_Faction(GameTooltip, self.factionID)

	GameTooltip:Show()
end

--Standard
local function ShowStandardTooltip(self)
	GameTooltip:SetOwner(self, self.ANCHOR_RIGHT and 'ANCHOR_RIGHT' or "ANCHOR_LEFT")
	local name= self.name
	if not name then
		local data= C_Reputation.GetFactionDataByID(self.factionID)
		name= data and data.name
	end

	GameTooltip_SetTitle(GameTooltip, WoWTools_TextMixin:CN(name))
	TryAppendAccountReputationLineToTooltip(GameTooltip, self.factionID)
	GameTooltip_AddBlankLineToTooltip(GameTooltip)
	WoWTools_TooltipMixin:Set_Faction(GameTooltip, self.factionID)

	GameTooltip:Show()
end


]]


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
	if not friendshipData or friendshipData.friendshipFactionID < 0 then
		return
	end
	GameTooltip:SetOwner(frame, frame.anchor or  "ANCHOR_LEFT")
	local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(friendshipData.friendshipFactionID)
	if rankInfo.maxLevel > 0 then
		GameTooltip_SetTitle(GameTooltip, WoWTools_TextMixin:CN(friendshipData.name).." ("..rankInfo.currentLevel.." / "..rankInfo.maxLevel..")", HIGHLIGHT_FONT_COLOR)
	else
		GameTooltip_SetTitle(GameTooltip, WoWTools_TextMixin:CN(friendshipData.name), HIGHLIGHT_FONT_COLOR)
	end
	ReputationUtil.TryAppendAccountReputationLineToTooltip(GameTooltip, factionID)
	GameTooltip_AddBlankLineToTooltip(GameTooltip)
	GameTooltip:AddLine(WoWTools_TextMixin:CN(friendshipData.text), nil, nil, nil, true)
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
--未解锁
	local major= C_MajorFactions.GetMajorFactionData(factionID)
	if major and not major.isUnlocked and major.unlockDescription and major.unlockDescription~='' then
		GameTooltip_AddBlankLineToTooltip(GameTooltip)
		GameTooltip_AddErrorLine(GameTooltip, WoWTools_TextMixin:CN(major.unlockDescription), true)
	end
	if frame.canClickForOptions then
		GameTooltip_AddBlankLineToTooltip(GameTooltip)
		GameTooltip_AddInstructionLine(GameTooltip, WoWTools_DataMixin.onlyChinese and '<点击查看选项>>' or REPUTATION_BUTTON_TOOLTIP_CLICK_INSTRUCTION)
	end
	WoWTools_TooltipMixin:Set_Faction(GameTooltip, factionID)
	EventRegistry:TriggerEvent("ShowMajorFactionRenown.Tooltip.OnEnter", frame, GameTooltip, factionID)
	GameTooltip:Show()
end

local function ShowStandardTooltip(frame)
	local factionID= frame.factionID
	local factionData = C_Reputation.GetFactionDataByID(factionID)
	if factionData then
		GameTooltip:SetOwner(frame, frame.anchor or  "ANCHOR_LEFT")
		GameTooltip_SetTitle(GameTooltip, WoWTools_TextMixin:CN(factionData.name))
		ReputationUtil.TryAppendAccountReputationLineToTooltip(GameTooltip, factionID)
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
		factionID= frame.factionID or (frame.data and frame.data.factionID)
	end

    if not factionID then
		return
	end

	local friendshipData = C_GossipInfo.GetFriendshipReputation(factionID)
	local isMajor= C_Reputation.IsMajorFaction(factionID)

	if C_Reputation.IsFactionParagonForCurrentPlayer(factionID) then
		ShowParagonRewardsTooltip(frame)

	elseif friendshipData and friendshipData.friendshipFactionID>0 then
		ShowFriendshipReputationTooltip(frame)

	elseif isMajor then
		ShowMajorFactionRenownTooltip(frame)
	else
		ShowStandardTooltip(frame)
	end

end
	--[[
	local function GetReputationTypeFromElementData(elementData)
	if not elementData then
		return nil
	end

	local friendshipData = C_GossipInfo.GetFriendshipReputation(elementData.factionID)
	local isFriendshipReputation = friendshipData and friendshipData.friendshipFactionID > 0
	if isFriendshipReputation then
		return ReputationType.Friendship
	end

	if C_Reputation.IsMajorFaction(elementData.factionID) then
		return ReputationType.MajorFaction
	end

	return ReputationType.Standard
end
	]]
	
	--[[local major= C_Reputation.IsMajorFaction(factionID)
	if major then
		if major.isUnlocked and major.unlockDescription then
			GameTooltip:SetOwner(frame, "ANCHOR_CURSOR_RIGHT")
			GameTooltip_AddErrorLine(GameTooltip, major.unlockDescription)
			GameTooltip:Show()
		
		end

	elseif C_Reputation.IsFactionParagonForCurrentPlayer(factionID) then
			ShowParagonRewardsTooltip(frame, factionID)
		else
			ShowRenownRewardsTooltip(frame, factionID)
		end
	end]]
	--[[elseif C_Reputation.IsFactionParagon(frame.factionID) then
		ShowParagonRewardsTooltip(frame, factionID)

	elseif not ShowFriendshipReputationTooltip(frame) then
			ShowStandardTooltip(frame)
	end]]


	--[[if C_Reputation.IsFactionParagon(frame.factionID) then
		ShowParagonRewardsTooltip(frame)

	elseif C_Reputation.IsMajorFaction(frame.factionID) then
		ShowMajorFactionRenownTooltip(frame)

	else
		if not ShowFriendshipReputationTooltip(frame) then
			ShowStandardTooltip(frame)
		end
	end]]

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