local e= select(2, ...)


local function AddRenownRewardsToTooltip(self, renownRewards)
	if not renownRewards then
		return
	end
	GameTooltip_AddHighlightLine(GameTooltip, WoWTools_Mixin.onlyChinese and '接下来的奖励：' or MAJOR_FACTION_BUTTON_TOOLTIP_NEXT_REWARDS)

	for _, rewardInfo in ipairs(renownRewards) do
		local renownRewardString
		local icon, name = RenownRewardUtil.GetRenownRewardInfo(rewardInfo, GenerateClosure(self.ShowMajorFactionRenownTooltip, self))
		if icon then
			local file, width, height = icon, 16, 16
			local rewardTexture = CreateSimpleTextureMarkup(file, width, height)
			renownRewardString = rewardTexture .. " " .. e.cn(name)
		end
		local wrapText = false
		GameTooltip_AddNormalLine(GameTooltip, renownRewardString, wrapText)
	end
end

local function TryAppendAccountReputationLineToTooltip(tooltip, factionID)
	if not tooltip or not factionID or not C_Reputation.IsAccountWideReputation(factionID) then
		return
	end
	GameTooltip_AddColoredLine(tooltip, WoWTools_Mixin.onlyChinese and '战团声望' or REPUTATION_TOOLTIP_ACCOUNT_WIDE_LABEL, ACCOUNT_WIDE_FONT_COLOR, false)
end









--Paragon
local function ShowParagonRewardsTooltip(self)

    EmbeddedItemTooltip:SetOwner(self, self.ANCHOR_RIGHT and 'ANCHOR_RIGHT' or "ANCHOR_LEFT")

	C_Reputation.RequestFactionParagonPreloadRewardData(self.factionID)
	ReputationParagonFrame_SetupParagonTooltip(self)
	GameTooltip_AddBlankLineToTooltip(EmbeddedItemTooltip)
	WoWTools_TooltipMixin:Set_Faction(EmbeddedItemTooltip, self.factionID)
	--EmbeddedItemTooltip:Show()
end

--Friendship
local function ShowFriendshipReputationTooltip(self)
	local friendshipData = C_GossipInfo.GetFriendshipReputation(self.factionID)



	if not friendshipData or friendshipData.friendshipFactionID < 0 then
		return false
	end

	GameTooltip:SetOwner(self, self.ANCHOR_RIGHT and "ANCHOR_RIGHT" or  "ANCHOR_LEFT")

	local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(friendshipData.friendshipFactionID)

	local name= e.cn(friendshipData.name or self.name)
	if not name then
		local data= C_Reputation.GetFactionDataByID(self.factionID)
		name= data and e.cn(data.name) or self.factionID
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
	--GameTooltip:Show()
	return true
end

--Major
local function ShowMajorFactionRenownTooltip(self)

	GameTooltip:SetOwner(self, self.ANCHOR_RIGHT and 'ANCHOR_RIGHT' or "ANCHOR_LEFT")

	local majorFactionData = C_MajorFactions.GetMajorFactionData(self.factionID) or {}
	GameTooltip_SetTitle(GameTooltip, e.cn(majorFactionData.name), HIGHLIGHT_FONT_COLOR)
	TryAppendAccountReputationLineToTooltip(GameTooltip, self.factionID)
	GameTooltip_AddHighlightLine(GameTooltip, (WoWTools_Mixin.onlyChinese and '名望' or RENOWN_LEVEL_LABEL).. majorFactionData.renownLevel)
	GameTooltip_AddBlankLineToTooltip(GameTooltip)
	GameTooltip_AddNormalLine(GameTooltip, format(WoWTools_Mixin.onlyChinese and '继续获取%s的声望以提升名望并解锁奖励。' or MAJOR_FACTION_RENOWN_TOOLTIP_PROGRESS, e.cn(majorFactionData.name)))
	GameTooltip_AddBlankLineToTooltip(GameTooltip)
	local nextRenownRewards = C_MajorFactions.GetRenownRewardsForLevel(self.factionID, C_MajorFactions.GetCurrentRenownLevel(self.factionID) + 1)
	if #nextRenownRewards > 0 then
		AddRenownRewardsToTooltip(self, nextRenownRewards)
	end
	GameTooltip_AddBlankLineToTooltip(GameTooltip)
	WoWTools_TooltipMixin:Set_Faction(GameTooltip, self.factionID)
end

--Standard
local function ShowStandardTooltip(self)
	GameTooltip:SetOwner(self, self.ANCHOR_RIGHT and 'ANCHOR_RIGHT' or "ANCHOR_LEFT")
	local name= self.name
	if not name then
		local data= C_Reputation.GetFactionDataByID(self.factionID)
		name= data and data.name
	end

	GameTooltip_SetTitle(GameTooltip, e.cn(name))
	TryAppendAccountReputationLineToTooltip(GameTooltip, self.factionID)
	GameTooltip_AddBlankLineToTooltip(GameTooltip)
	WoWTools_TooltipMixin:Set_Faction(GameTooltip, self.factionID)
end












function WoWTools_SetTooltipMixin:Faction(frame)--ANCHOR_RIGHT=true
    if not frame.factionID then
		return
	end

	if C_Reputation.IsFactionParagon(frame.factionID) then
		ShowParagonRewardsTooltip(frame)

	elseif C_Reputation.IsMajorFaction(frame.factionID) then
		ShowMajorFactionRenownTooltip(frame)

	else
		if not ShowFriendshipReputationTooltip(frame) then
			ShowStandardTooltip(frame)
		end
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