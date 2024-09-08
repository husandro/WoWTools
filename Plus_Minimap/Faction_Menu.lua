local e= select(2, ...)





--菜单, 派系声望
local function Set_Faction_Menu(root, factionID)
    local info= WoWTools_FactionMinxin:GetInfo(factionID, nil, false)
    if not info.name then
        return
    end

    local sub=root:CreateCheckbox(
        (info.atlas and '|A:'..info.atlas..':0:0|a' or (info.texture and '|T'..info.texture..':0|t') or '')
        ..e.cn(info.name)
        ..(info.color and '|c'..info.color:GenerateHexColor() or '|cffffffff')
        ..(info.factionStandingtext and ' '..info.factionStandingtext..' ' or '')
        ..'|r'
        ..(info.valueText or '')
        ..(info.hasRewardPending and '|A:BonusLoot-Chest:0:0|a' or ''),

    function(data)
        return MajorFactionRenownFrame and MajorFactionRenownFrame.majorFactionID==data.factionID

    end, function(data)
        WoWTools_LoadUIMixin:MajorFaction(data.factionID)

    end, {factionID=factionID})

    return sub
end










--派系声望
function WoWTools_MinimapMixin:Faction_Menu(_, root)
    local sub

--打开选项
    sub=root:CreateCheckbox(
        '|A:VignetteEvent-SuperTracked:0:0|a'
        ..(e.onlyChinese and '名望' or LANDING_PAGE_RENOWN_LABEL),
    function()
        return MajorFactionRenownFrame and MajorFactionRenownFrame:IsShown()
    end, function()
        WoWTools_LoadUIMixin:MajorFaction(2593)
    end)

    local index=0
--当前版本
    local tab=C_MajorFactions.GetMajorFactionIDs(e.ExpansionLevel) or {}

--MajorFactionsConstantsDocumentation.lua
    for _, factionID in pairs(Constants.MajorFactionsConsts or {}) do
        table.insert(tab, factionID)
    end
    table.sort(tab, function(a, b) return a>b end)

    for _, factionID in pairs(tab) do
        if Set_Faction_Menu(sub, factionID) then
            index=index+1
        end
    end


--旧数据
    for expacID= e.ExpansionLevel-1, 9, -1 do
        tab=C_MajorFactions.GetMajorFactionIDs(expacID)
        if tab then
            table.sort(tab, function(a, b) return a>b end)
            sub:CreateDivider()
            for _, factionID in pairs(tab) do
                if Set_Faction_Menu(sub, factionID) then
                    index= index+1
                end
            end
        end
    end
    WoWTools_MenuMixin:SetNumButton(sub, index)
end


