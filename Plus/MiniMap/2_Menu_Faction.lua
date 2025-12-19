





--菜单, 派系声望
local function Set_Faction_Menu(root, factionID)
    local info= WoWTools_FactionMixin:GetInfo(factionID, nil, false)
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
        WoWTools_LoadUIMixin:MajorFaction(data.factionID)
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
        WoWTools_LoadUIMixin:MajorFaction(2593)
        return MenuResponse.Refresh
    end)

    local index=0

--当前版本
    local tab=C_MajorFactions.GetMajorFactionIDs(WoWTools_DataMixin.ExpansionLevel) or {}
    local find={}

--MajorFactionsConstantsDocumentation.lua
    for _, factionID in pairs(Constants.MajorFactionsConsts or {}) do
        if not find[factionID] then
            table.insert(tab, factionID)
            find[factionID]=true
        end
    end
    table.sort(tab, function(a, b) return a>b end)

    for _, factionID in pairs(tab) do
        if Set_Faction_Menu(sub, factionID) then
            index=index+1
        end
    end


--旧数据
    for expacID= WoWTools_DataMixin.ExpansionLevel-1, 9, -1 do
        tab=C_MajorFactions.GetMajorFactionIDs(expacID)
        if tab then
            table.sort(tab, function(a, b) return a>b end)
            sub:CreateDivider()
            for _, factionID in pairs(tab) do
                if not find[factionID] then
                    if Set_Faction_Menu(sub, factionID) then
                        index= index+1
                    end
                    find[factionID]=true
                end
            end
        end
    end

    find=nil
    WoWTools_MenuMixin:SetScrollMode(sub)
end


