--界面, 增强
local e= select(2, ...)
local function Save()
	return WoWTools_FactionMixin.Save
end












local function Setup(btn)--factionRow, elementData)--ReputationFrame.lua
	local data= btn.elementData or {}
	local factionID = data.factionID --or btn.factionIndex
	local frame = btn.Content
	if not frame or factionID==0 then
		return
    elseif Save().notPlus then
		frame.Name:SetTextColor(1,1,1)
		if frame.watchedIcon then--显示为经验条
			frame.watchedIcon:SetShown(false)
		end
		if frame.completed then--完成次数
			frame.completed:SetText('')
		end
		if frame.levelText then--等级
			frame.levelText:SetText('')
		end
		if frame.texture then--图标
			frame.texture:SetTexture(0)
		end
		if frame.check then
			frame.check:SetShown(false)
		end
		return
	end

	local bar = frame.ReputationBar;

	local barColor, levelText, texture, atlas,isCapped
	local isMajorFaction = C_Reputation.IsMajorFaction(factionID);
	local repInfo = C_GossipInfo.GetFriendshipReputation(factionID);

	if repInfo and repInfo.friendshipFactionID and repInfo.friendshipFactionID > 0 then--好友声望
		local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID)
		texture= repInfo and repInfo.texture
		if rankInfo and rankInfo.maxLevel>0 then
			if repInfo.nextThreshold then
				levelText= rankInfo.currentLevel..'/'..rankInfo.maxLevel
			else
				barColor= FACTION_ORANGE_COLOR
				isCapped= true
			end
		end

	elseif isMajorFaction then-- 名望
		local info = C_MajorFactions.GetMajorFactionData(factionID)
		if info then
			atlas= info.textureKit and 'MajorFactions_Icons_'..info.textureKit..'512'
			if C_MajorFactions.HasMaximumRenown(factionID) then
				barColor=FACTION_ORANGE_COLOR
				isCapped=true
			else
				barColor = GREEN_FONT_COLOR
				if info.renownLevel then
					local levels = C_MajorFactions.GetRenownLevels(factionID)
					if levels then
						levelText= #levels
						--levelText= info.renownLevel..'/'..#levels
					end
				end
			end
		end

	elseif data.reaction then
		if data.reaction == MAX_REPUTATION_REACTION then--已满
			barColor=FACTION_ORANGE_COLOR
			isCapped=true
		else
			barColor = FACTION_BAR_COLORS[data.reaction]
			levelText= data.reaction..'/'..MAX_REPUTATION_REACTION
		end
	end

	if barColor then--标题, 颜色
		if C_Reputation.IsAccountWideReputation(factionID) then
			frame.Name:SetTextColor(0, 0.8, 1)
        elseif isCapped then
            frame.Name:SetTextColor(1, 0.62, 0)
		else
			frame.Name:SetTextColor(barColor.r, barColor.g, barColor.b)
		end
	end

	local completedParagon--完成次数
	if isCapped and C_Reputation.IsFactionParagon(factionID) then--奖励
		local currentValue, threshold, _, _, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID)
		local completed=0
		if currentValue and threshold then
			if not tooLowLevelForParagon then
				completed= math.modf(currentValue/threshold)--完成次数
				completedParagon= completed>0 and completed
			end
		end
	end
	if completedParagon and not frame.completed then
		frame.completed= WoWTools_LabelMixin:Create(bar)
		frame.completed:SetPoint('RIGHT', frame.ParagonIcon, 'LEFT', 4,0)
	end
	if frame.completed then
		frame.completed:SetText(completedParagon or '')
	end

	if barColor and isCapped then
		bar:SetStatusBarColor(barColor.r, barColor.g, barColor.b)
	end

	if levelText and not frame.levelText then--等级
		frame.levelText= WoWTools_LabelMixin:Create(bar, {size=10})--10, nil, nil, nil, nil, 'RIGHT')
		frame.levelText:SetPoint('RIGHT')
	end
	if frame.levelText then
		frame.levelText:SetText(levelText or '')
	end

	if (texture or atlas) and not frame.texture then--图标
		local h=frame:GetHeight() or 20
		frame.texture= frame:CreateTexture(nil, 'OVERLAY')
		frame.texture:SetPoint('RIGHT', frame.Name, 'RIGHT',6,0)
		frame.texture:SetSize(h, h)
	end

	if frame.texture then
		if texture then
			frame.texture:SetTexture(texture)
		elseif atlas then
			frame.texture:SetAtlas(atlas)
		else
			frame.texture:SetTexture(0)
		end
	end

	if not frame.check then
		frame.check= CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
		frame.check:SetPoint('LEFT',-12,0)
		function frame.check:get_info()
			return self:GetParent():GetParent().elementData or {}
		end
		frame.check:SetScript('OnClick', function(self)
			local info= self:get_info()
			if info.factionID then
				Save().factions[info.factionID]= not Save().factions[info.factionID] and true or nil
				ReputationFrame:Update()
			end
		end)
		frame.check:SetScript('OnEnter', function(self)
			local info= self:get_info()
			if not info.factionID then
				return
			end
			GameTooltip:SetOwner(self, "ANCHOR_LEFT")
			GameTooltip:ClearLines()
			GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_FactionMixin.addName)
			GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '追踪' or TRACKING, WoWTools_Mixin.onlyChinese and '指定' or COMBAT_ALLY_START_MISSION)
			GameTooltip:AddLine(' ')
			GameTooltip:AddDoubleLine(e.cn(info.name), info.factionID, 0,1,0,0,1,0)
			GameTooltip:Show()
			self:SetAlpha(1)
		end)
		frame.check:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(0.3) end)
		frame.check:SetSize(18,22)
		frame.check:SetCheckedTexture(e.Icon.icon)
	end
	frame.check:SetShown(true)
	frame.check:SetChecked(Save().factions[factionID])
	frame.check:SetAlpha(0.3)

	--frame.AccountWideIcon:SetShown(data.isAccountWide)--战团
end

















function WoWTools_FactionMixin:Init_ScrollBox_Plus()
    hooksecurefunc(ReputationFrame.ScrollBox, 'Update', function(self)
        if not self:GetView() then
            return
        end
        for _, btn in pairs(self:GetFrames()or {}) do
            Setup(btn)
        end
    end)
end