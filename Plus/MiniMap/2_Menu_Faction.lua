





--菜单, 派系声望
local function Set_Faction_Menu(root, factionID)
    local info= WoWTools_FactionMixin:GetInfo(factionID)
    if not info.name then
        return
    end

    local icon=''
    if info.atlas then
        icon= '|A:'..info.atlas..':18:18|a'
    elseif info.texture then
        icon= '|T'..info.texture..':18|t'
    end

    local name= WoWTools_TextMixin:CN(info.name)
    if not info.isUnlocked then
        name= DISABLED_FONT_COLOR:WrapTextInColorCode(name)
    else
        name= NORMAL_FONT_COLOR:WrapTextInColorCode(name)
    end

    local sub=root:CreateRadio(
        icon..name
        ..(info.color and '|c'..info.color:GenerateHexColor() or '|cffffffff')
        ..(info.factionStandingtext and not info.isCapped and ' '..info.factionStandingtext..' ' or ' ')
        ..'|r'
        ..(info.valueText or '')
        ..(info.hasRewardPending and '|A:BonusLoot-Chest:0:0|a' or ''),

    function(data)
        if MajorFactionRenownFrame then--12.0没有了
            return MajorFactionRenownFrame and MajorFactionRenownFrame.majorFactionID==data.factionID
        else
            return EncounterJournalJourneysFrame and EncounterJournalJourneysFrame.JourneyProgress.majorFactionData.factionID==data.factionID
        end
    end, function(data)
        WoWTools_LoadUIMixin:OpenFaction(data.factionID)
        return MenuResponse.Refresh
    end, {factionID=factionID})

    WoWTools_SetTooltipMixin:FactionMenu(sub)

    return sub
end








--派系声望
function WoWTools_MinimapMixin:Faction_Menu(_, root)
    local sub

--打开选项
    sub=root:CreateButton(
        '|A:VignetteEvent-SuperTracked:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '名望' or LANDING_PAGE_RENOWN_LABEL),
    --function()
        --return MajorFactionRenownFrame and MajorFactionRenownFrame:IsShown()
    function()
        WoWTools_LoadUIMixin:OpenFaction(2593)
        return MenuResponse.Refresh
    end)



--当前版本

    local tab= C_MajorFactions.GetMajorFactionIDs()

    table.sort(tab, function(a, b)
        local a2= C_MajorFactions.GetMajorFactionData(a) or {expansionID=0}
        local b2= C_MajorFactions.GetMajorFactionData(b) or {expansionID=0}
        if a2.expansionID==b2.expansionID then
            return a>b
        else
            return a2.expansionID>b2.expansionID
        end
    end)

    local expansionID= WoWTools_DataMixin.ExpansionLevel

    for index, factionID in pairs(tab) do
        local major= C_MajorFactions.GetMajorFactionData(factionID)
        if major and major.expansionID<expansionID then
            expansionID= major.expansionID
            table.insert(tab, index, '-')
        end
    end
--[[MajorFactionsConstantsDocumentation.lua
    for _, factionID in pairs(Constants.MajorFactionsConsts or {}) do
        if not find[factionID] then
            table.insert(tab, factionID)
            find[factionID]=true
        end
    end
    table.sort(tab, function(a, b) return a>b end)]]

    
    for _, factionID in pairs(tab) do
        if factionID=='-' then
            sub:CreateDivider()
        elseif not C_MajorFactions.IsMajorFactionHiddenFromExpansionPage(factionID) then

            Set_Faction_Menu(sub, factionID)
        end
    end


--旧数据
    WoWTools_MenuMixin:SetScrollMode(sub)
end


