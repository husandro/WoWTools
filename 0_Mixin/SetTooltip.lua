--[[
SetTooltip(tooltip, data, root, frame)
]]


local e= select(2, ...)
WoWTools_SetTooltipMixin={}












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
        e.onlyChinese and '力量' or SPEC_FRAME_PRIMARY_STAT_STRENGTH,
        e.onlyChinese and '敏捷' or SPEC_FRAME_PRIMARY_STAT_AGILITY,
        e.onlyChinese and '智力' or SPEC_FRAME_PRIMARY_STAT_INTELLECT,
        --e.onlyChinese and '智力' or SPEC_FRAME_PRIMARY_STAT_INTELLECT,
    }

    local specIDs= C_SpecializationInfo.GetSpellsDisplay(specID) or {}

    tooltip:AddDoubleLine(
        (specID or '')..'|T'..(icon or 0)..':0|t'
        ..(e.cn(name) or ''),

        (stat[primaryStat] or stat[3])
        ..'|A:'..(roleIcon or '')..':0:0|a'..(e.cn(_G[role] or role) or '')
    )

    tooltip:AddLine(' ')
    tooltip:AddDoubleLine(
        WoWTools_SpellMixin:GetName(specIDs[1]),
        WoWTools_SpellMixin:GetName(specIDs[6])
    )

    tooltip:AddLine(' ')
    tooltip:AddLine(e.cn(description), nil, nil, nil, true)
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



function WoWTools_SetTooltipMixin:Setup(tooltip, data)
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

    local speciesID= data.speciesID
    local petID= data.petID

    local specIndex= data.specIndex--天赋，专精
    local specID= data.specID

    local tip= data.tooltip--添加，提示

    tooltip= tooltip or GameTooltip

    local cooldown--冷却时间剩余

    if itemLink then
        if tooltip==BattlePetTooltip or itemLink:find('Hbattlepet:%d+') then
            BattlePetToolTip_Show(BattlePetToolTip_UnpackBattlePetLink(itemLink))
            Add_Tooltip(BattlePetTooltip, tip, data)
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
        cooldown= e.GetSpellItemCooldown(nil, itemID)--冷却时间剩余

    elseif spellID then
        tooltip:SetSpellByID(spellID)
        cooldown= e.GetSpellItemCooldown(spellID, nil)--冷却时间剩余

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
        elseif speciesID then

        end


    elseif specIndex or specID then
        Set_Specialization(tooltip, specIndex, specID)
    end

    Add_Tooltip(tooltip, tip, data)
    
--冷却时间剩余
    if cooldown then
        Add_Tooltip(tooltip, ' ', nil)
        Add_Tooltip(tooltip, format(e.onlyChinese and '冷却时间剩余：%s' or ITEM_COOLDOWN_TIME, cooldown), nil)
    end

    return true
end











function WoWTools_SetTooltipMixin:Frame(frame, tooltip, data)
    tooltip= tooltip or GameTooltip
    tooltip:SetOwner(frame, "ANCHOR_LEFT");
    tooltip:ClearLines()
    if frame.itemLink and (not data or not data.itemLink) then
        data= data or {}
        data.itemLink= frame.itemLink
    end
    if self:Setup(tooltip, data) then
        tooltip:Show()
    end
end

function WoWTools_SetTooltipMixin:Set_Menu(root)
    root:SetTooltip(function(tooltip, description)
        self:Setup(tooltip, description.data)
    end)
end