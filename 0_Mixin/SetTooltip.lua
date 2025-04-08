--[[
SetTooltip(tooltip, data, root, frame)
]]



WoWTools_SetTooltipMixin={}












local function set_vignetteGUID(tooltip, vignetteGUID)
    local vignetteInfo = C_VignetteInfo.GetVignetteInfo(vignetteGUID)
    if not vignetteInfo then
        return
    end
    local verticalPadding = nil
    local waitingForData, titleAdded = false, false

    if vignetteInfo.type == Enum.VignetteType.Normal or vignetteInfo.type == Enum.VignetteType.Treasure then
        GameTooltip_SetTitle(tooltip, WoWTools_TextMixin:CN(vignetteInfo.name))
        titleAdded = true

    elseif vignetteInfo.type == Enum.VignetteType.PvPBounty then
        local player = PlayerLocation:CreateFromGUID(vignetteInfo.objectGUID)
        local class = select(3, C_PlayerInfo.GetClass(player))
        local race = C_PlayerInfo.GetRace(player)
        local name = C_PlayerInfo.GetName(player)
        if race and class and name then
            local classInfo = C_CreatureInfo.GetClassInfo(class) or {}
            local factionInfo = C_CreatureInfo.GetFactionInfo(race) or {}
            GameTooltip_SetTitle(tooltip, WoWTools_TextMixin:CN(name), GetClassColorObj(classInfo.classFile))
            GameTooltip_AddColoredLine(tooltip, WoWTools_TextMixin:CN(factionInfo.name), GetFactionColor(factionInfo.groupTag))
            if vignetteInfo.rewardQuestID then
                GameTooltip_AddQuestRewardsToTooltip(tooltip, vignetteInfo.rewardQuestID, TOOLTIP_QUEST_REWARDS_STYLE_PVP_BOUNTY)
            end
            titleAdded=true
        end
        waitingForData = not titleAdded

    elseif vignetteInfo.type == Enum.VignetteType.Torghast then
        SharedTooltip_SetBackdropStyle(tooltip, GAME_TOOLTIP_BACKDROP_STYLE_RUNEFORGE_LEGENDARY)
        GameTooltip_SetTitle(tooltip, WoWTools_TextMixin:CN(vignetteInfo.name))
        titleAdded = true
    end

    if not waitingForData and vignetteInfo.widgetSetID then
        local overflow = GameTooltip_AddWidgetSet(tooltip, vignetteInfo.widgetSetID, titleAdded and vignetteInfo.addPaddingAboveWidgets and 10)
        if overflow then
            verticalPadding = -overflow
        end
    elseif waitingForData then
        GameTooltip_SetTitle(tooltip, WoWTools_DataMixin.onlyChinese and '获取数据' or RETRIEVING_DATA)
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
            GameTooltip_SetTitle(tooltip, WoWTools_TextMixin:CN(poiInfo.name), HIGHLIGHT_FONT_COLOR)
            addedTooltipLine = true
        end

        if hasDescription then
            GameTooltip_AddNormalLine(tooltip, WoWTools_TextMixin:CN(poiInfo.description))
            addedTooltipLine = true
        end

        if showTimer then
            local secondsLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(areaPoiID)
            if secondsLeft and secondsLeft > 0 then
                local timeString = SecondsToTime(secondsLeft)
                GameTooltip_AddNormalLine(tooltip, format(WoWTools_DataMixin.onlyChinese and '剩余时间：%s' or BONUS_OBJECTIVE_TIME_LEFT, timeString))
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









--专精，天赋
local function Set_Specialization(tooltip, specIndex, specID)
    local name, description, icon, role, primaryStat, roleIcon
    if specIndex then
        specID, name, description, icon, role, primaryStat= GetSpecializationInfo(specIndex, false, false, nil, UnitSex("player"))
        roleIcon= GetMicroIconForRoleEnum(GetSpecializationRoleEnum(specIndex, false, false))

    elseif specID then
        specID, name, description, icon, role, primaryStat = GetSpecializationInfoByID(specID)
        roleIcon= GetMicroIconForRoleEnum(GetSpecializationRoleEnumByID(specID))
    end

    if not specID or not name or not tooltip then
        return
    end

    local stat={
        WoWTools_DataMixin.onlyChinese and '力量' or SPEC_FRAME_PRIMARY_STAT_STRENGTH,
        WoWTools_DataMixin.onlyChinese and '敏捷' or SPEC_FRAME_PRIMARY_STAT_AGILITY,
        WoWTools_DataMixin.onlyChinese and '智力' or SPEC_FRAME_PRIMARY_STAT_INTELLECT,
        --WoWTools_DataMixin.onlyChinese and '智力' or SPEC_FRAME_PRIMARY_STAT_INTELLECT,
    }

    local specIDs= C_SpecializationInfo.GetSpellsDisplay(specID) or {}

    tooltip:AddDoubleLine(
        (specID or '')..'|T'..(icon or 0)..':0|t'
        ..(WoWTools_TextMixin:CN(name) or ''),

        (stat[primaryStat] or stat[3])
        ..'|A:'..(roleIcon or '')..':0:0|a'..(WoWTools_TextMixin:CN(_G[role] or role) or '')
    )

    tooltip:AddLine(' ')
    tooltip:AddDoubleLine(
        WoWTools_SpellMixin:GetName(specIDs[1]),
        WoWTools_SpellMixin:GetName(specIDs[6])
    )

    tooltip:AddLine(' ')
    tooltip:AddLine(WoWTools_TextMixin:CN(description), nil, nil, nil, true)
end












--地下城挑战，分数，超链接
local function Set_DungeonScore(self, link)
    local splits  = StringSplitIntoTable(":", link)

	--Bad Link, Return. 
	if(not splits) then
		return
	end

	local dungeonScore = tonumber(splits[2]) or 0
    local guid= splits[3]
	local playerName = splits[4]
	local playerClass = splits[5]
	local playerItemLevel = tonumber(splits[6]) or 0
	local playerLevel = tonumber(splits[7]) or 0
	local className, classFileName = GetClassInfo(playerClass)
	--local classColor = C_ClassColor.GetClassColor(classFileName)
	local runsThisSeason = tonumber(splits[8]) or 0
	local bestSeasonScore = tonumber(splits[9]) or 0
	local bestSeasonNumber = tonumber(splits[10]) or 0

	--Bad Link..
	if(not playerName or not playerClass or not playerItemLevel or not playerLevel) then
		return
	end

	--Bad Link..
	if not className or not guid then
		return
	end

    GameTooltip_SetTitle(self, WoWTools_UnitMixin:GetPlayerInfo(nil, guid, playerName, {reName=true}))

	--GameTooltip_SetTitle(self, classColor:WrapTextInColorCode(playerName))
	GameTooltip_AddColoredLine(self, format(
        WoWTools_DataMixin.onlyChinese and '等级%d %s' or DUNGEON_SCORE_LINK_LEVEL_CLASS_FORMAT_STRING,
        playerLevel, (WoWTools_UnitMixin:GetClassIcon(classFileName, nil, guid, false) or '').. WoWTools_TextMixin:CN(className)
    ), HIGHLIGHT_FONT_COLOR)
	GameTooltip_AddNormalLine(self, format(
        WoWTools_DataMixin.onlyChinese and '物品等级：|A:charactercreate-icon-customize-body-selected:0:0|a|cffffffff%d|r' or DUNGEON_SCORE_LINK_ITEM_LEVEL,
        playerItemLevel
    ))

	local color = C_ChallengeMode.GetDungeonScoreRarityColor(dungeonScore) or HIGHLIGHT_FONT_COLOR
	GameTooltip_AddNormalLine(self, format(
        WoWTools_DataMixin.onlyChinese and '史诗钥石评分：|A:recipetoast-icon-star:0:0|a%s' or DUNGEON_SCORE_LINK_RATING,
        color:WrapTextInColorCode(dungeonScore)
    ))

	GameTooltip_AddNormalLine(self, format(
        WoWTools_DataMixin.onlyChinese and '本赛季尝试次数：|A:TaskPOI-IconSelect:0:0|a|cffffffff%d|r' or DUNGEON_SCORE_LINK_RUNS_SEASON,
        runsThisSeason
    ))

	if(bestSeasonScore ~= 0) then
		local bestSeasonColor = C_ChallengeMode.GetDungeonScoreRarityColor(bestSeasonScore) or HIGHLIGHT_FONT_COLOR
		GameTooltip_AddNormalLine(self, format(
            WoWTools_DataMixin.onlyChinese and '之前的最高记录： %s|cff808080（第%d赛季）' or DUNGEON_SCORE_LINK_PREVIOUS_HIGH,
            bestSeasonColor:WrapTextInColorCode(bestSeasonScore), bestSeasonNumber)
        )
	end
	GameTooltip_AddBlankLineToTooltip(self)

	local sortTable = { }
    local DUNGEON_SCORE_LINK_INDEX_START = 11
    local DUNGEON_SCORE_LINK_ITERATE = 3
	for i = DUNGEON_SCORE_LINK_INDEX_START, (#splits), DUNGEON_SCORE_LINK_ITERATE do
		local mapChallengeModeID = tonumber(splits[i])
		local completedInTime = splits[i + 1] == "1"
		local level = tonumber(splits[i + 2])
		local mapName = C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)

		--If any of the maps don't exist.. this is a bad link
		if(not mapName) then
			return
		end

		table.insert(sortTable, {
            mapName =WoWTools_TextMixin:CN(mapName),
            completedInTime = completedInTime,
            level = level or 0,
        })
	end

	-- Sort Alphabetically. 
	table.sort(sortTable, function(a, b)
---@diagnostic disable-next-line: missing-return, discard-returns
        strcmputf8i(a.mapName, b.mapName)
    end)

	for i = 1, #sortTable do
		local textColor = sortTable[i].completedInTime and HIGHLIGHT_FONT_COLOR or GRAY_FONT_COLOR
		GameTooltip_AddColoredDoubleLine(self,
            format('%s', sortTable[i].mapName),
            (sortTable[i].level > 0 and  DUNGEON_SCORE_LINK_TEXT2:format(sortTable[i].level) or DUNGEON_SCORE_LINK_NO_SCORE),
            NORMAL_FONT_COLOR,
            textColor
        )
	end
end








local function Add_Tooltip(tooltip, tip, data)
    if type(tip)=='function' then
        tip(tooltip, data)
    elseif tip then
        if tooltip==BattlePetTooltip then
            BattlePetTooltipTemplate_AddTextLine(BattlePetTooltip, tip)
            BattlePetTooltipTemplate_AddTextLine(BattlePetTooltip, ' ')
            --BattlePetTooltip:Show()
        else
            GameTooltip_AddNormalLine(tooltip, tip, true)
        end
    end
end



function WoWTools_SetTooltipMixin:Setup(tooltip, data, frame)
    frame= frame or data.frame

    data= data or frame

    if not data then
        return
    end

    local hyperLink=
            data.link
            or data.itemLink
            or data.spellLink
            or data.hyperLink
            or data.battlePetLink

    local itemID= data.itemID
    local spellID= data.spellID
    local currencyID= data.currencyID
    local achievementID= data.achievementID

    local questID= data.questID

    local rewardQuestID= data.rewardQuestID

    local widgetSetID= data.widgetSetID
    local vignetteGUID= data.vignetteGUID

    local uiMapID= data.uiMapID
    local areaPoiID= data.uiMapID

    local speciesID= data.speciesID
    local petID= data.petID

    local specIndex= data.specIndex--天赋，专精
    local specID= data.specID

    local dungeonScore= data.dungeonScore

    local addTooltip= data.tooltip--添加，提示


    tooltip= tooltip or GameTooltip
    local cooldown--冷却时间剩余

    if hyperLink then
        if tooltip==BattlePetTooltip or hyperLink:find('Hbattlepet:%d+') then
            BattlePetToolTip_Show(BattlePetToolTip_UnpackBattlePetLink(hyperLink))
            --BattlePetToolTip_ShowLink(itemKeyInfo.battlePetLink)
            Add_Tooltip(BattlePetTooltip, addTooltip, data)
            return
        else
            tooltip:SetHyperlink(hyperLink)
        end

    elseif itemID then
        if C_ToyBox.GetToyInfo(itemID) then
            tooltip:SetToyByItemID(itemID)
        else
            tooltip:SetItemByID(itemID)
        end
        cooldown= WoWTools_CooldownMixin:GetText(nil, itemID)--冷却时间剩余

    elseif spellID then
        tooltip:SetSpellByID(spellID)
        cooldown= WoWTools_CooldownMixin:GetText(spellID, nil)--冷却时间剩余

    elseif currencyID then
        tooltip:SetCurrencyByID(currencyID)

    elseif widgetSetID then
        GameTooltip_AddWidgetSet(tooltip, widgetSetID)

    elseif achievementID then
        tooltip:SetAchievementByID(achievementID)

    elseif questID then
        GameTooltip_AddQuest(frame or {}, questID)

    elseif rewardQuestID then
        GameTooltip_AddQuestRewardsToTooltip(tooltip, rewardQuestID)
        GameTooltip_AddQuestTimeToTooltip(tooltip, questID)

    elseif vignetteGUID then
        set_vignetteGUID(tooltip, vignetteGUID)

    elseif uiMapID and areaPoiID then
        set_areaPoiID(tooltip, uiMapID, areaPoiID)

    elseif speciesID or petID then
        if not petID then
            local speciesName= C_PetJournal.GetPetInfoBySpeciesID(speciesID)
            if speciesName then
                petID= select(2, C_PetJournal.FindPetIDByName(speciesName))
            end
        end
        if petID then
            tooltip:SetCompanionPet(petID)
        --elseif speciesID then

        end


    elseif specIndex or specID then
        Set_Specialization(tooltip, specIndex, specID)

    elseif dungeonScore then
        Set_DungeonScore(tooltip, dungeonScore)--地下城挑战，分数，超链接
    end

    Add_Tooltip(tooltip, addTooltip, data)

--冷却时间剩余
    if cooldown then
        Add_Tooltip(tooltip, ' ', nil)
        Add_Tooltip(tooltip, format(WoWTools_DataMixin.onlyChinese and '冷却时间剩余：%s' or ITEM_COOLDOWN_TIME, cooldown), nil)
    end

    return true
end











function WoWTools_SetTooltipMixin:Frame(frame, tooltip, data)
    tooltip= tooltip or GameTooltip

    tooltip:SetOwner(
        data and data.owner or frame.owner or frame,
        data and data.anchor or frame.anchor or "ANCHOR_LEFT"
    )
    tooltip:ClearLines()

    if self:Setup(tooltip, data, frame) then
        tooltip:Show()
    end

end



function WoWTools_SetTooltipMixin:Set_Menu(root)
    root:SetTooltip(function(tooltip, description)
        self:Setup(tooltip, description.data)
    end)
end