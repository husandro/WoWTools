

WoWTools_DataMixin.WoWGUID={}--战网，好友GUID--WoWTools_DataMixin.WoWGUID[名称-服务器]=guid
WoWTools_DataMixin.PlayerInfo={}--玩家装等
WoWTools_DataMixin.GroupGuid={}--队伍数据收集 name={faction=, guid=}













local function Cached_ItemLevel(unit, guid)
    if not canaccessvalue(unit) or not canaccessvalue(guid) then
        return
    end

    unit= unit or (guid and UnitTokenFromGUID(guid))
    guid= guid or (unit and UnitGUID(unit))

    if not unit or not guid then
        return
    end


    --local color= WoWTools_UnitMixin:GetColor(unit, guid)
    --local r,g,b= color:GetRGB()
    --local hex= color:GenerateHexColorMarkup()
    local itemLevel, specID
    local data= WoWTools_DataMixin.PlayerInfo[guid] or {}

    local combatRole= UnitGroupRolesAssigned(unit)-- TANK, HEALER, DAMAGER, NONE
    local faction= UnitFactionGroup('player')

    combatRole= combatRole~='NONE' and combatRole or nil
    faction= faction~='' and faction or data.faction

    if guid==WoWTools_DataMixin.Player.GUID then
        itemLevel= GetAverageItemLevel()
        specID= PlayerUtil.GetCurrentSpecID()
        WoWTools_WoWDate[guid].itemLevel= itemLevel
        WoWTools_WoWDate[guid].specID= specID
        WoWTools_WoWDate[guid].faction= faction
    else
        itemLevel= C_PaperDollInfo.GetInspectItemLevel(unit)
        itemLevel= itemLevel>0 and itemLevel or data.itemLevel or nil

        specID= GetInspectSpecialization(unit) or 0
        specID= specID>0 and specID or data.specID or nil
    end

    if itemLevel then
        itemLevel= math.floor(itemLevel+ 0.5)
    end

    WoWTools_DataMixin.PlayerInfo[guid] = {--玩家装等
        faction= faction,
        level=UnitLevel(unit),

        itemLevel= itemLevel,
        specID= specID,

        color= WoWTools_UnitMixin:GetColor(unit, guid),
        combatRole= combatRole,
        --sex= UnitSex(unit),
        --col= hex,
        --r=r,
        --g=g,
        --b=b,

    }
end




EventRegistry:RegisterFrameEventAndCallback("INSPECT_READY", function(_, guid)--取得玩家信息
    local unit= canaccessvalue(guid) and guid and UnitTokenFromGUID(guid)

    if not unit then
        return
    end

    Cached_ItemLevel(unit, guid)

    --[[f UnitInParty(unit) and PartyFrame['MemberFrame'..1].classFrame then
        C_Timer.After(0.3, function()
            for i=1, 4 do
                local frame= PartyFrame['MemberFrame'..i]
                if frame:IsShown() and frame.classFrame then
                    if UnitGUID('party'..i)==guid then
                        frame.classFrame:set_settings()
                        break
                    end
                else
                    break
                end
            end
        end)
    end

    if TargetFrame.classFrame and WoWTools_UnitMixin:UnitIsUnit(unit, 'target') then
        TargetFrame.classFrame:set_settings()
    end]]

--设置 GameTooltip
    if  GameTooltip.textLeft and GameTooltip:IsShown() then
        local name2, unit2, guid2= TooltipUtil.GetDisplayedUnit(GameTooltip)
        if canaccessvalue(guid2) and guid2==guid then
            WoWTools_TooltipMixin:Set_Unit_Player(GameTooltip, name2, unit2, guid2)
        end
    end

--[[保存，自已，装等
    if guid==WoWTools_DataMixin.Player.GUID then
        WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].itemLevel= GetAverageItemLevel()
        WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].specID= PlayerUtil.GetCurrentSpecID()
    end]]
end)













--队伍数据收集
local function GetGroupGuidDate()--队伍数据收集
    local UnitTab={}

    if IsInRaid() then
        for index= 1, MAX_RAID_MEMBERS do --GetNumGroupMembers() do
            local unit= 'raid'..index
            if WoWTools_UnitMixin:UnitExists(unit) then
                local _, _, subgroup, _, _, _, _, _, _, role, _, combatRole = GetRaidRosterInfo(index)
                table.insert(UnitTab, {
                    name= UnitName(unit),
                    faction= UnitFactionGroup(unit),
                    unit=unit,
                    guid= UnitGUID(unit),
                    combatRole= combatRole or role,
                    subgroup= subgroup
                })
            end
        end

    elseif IsInGroup() then
        for index= 1, 4 do
            local unit= 'party'..index
            if WoWTools_UnitMixin:UnitExists(unit) then
                table.insert(UnitTab, {
                    name= UnitName(unit),
                    faction= UnitFactionGroup(unit),
                    unit= unit,
                    guid= UnitGUID(unit),
                    combatRole=UnitGroupRolesAssigned(unit),
                })
            end
        end
    end

    local unitList= {}
    for _, tab in pairs(UnitTab) do
        if tab.name then
            WoWTools_DataMixin.GroupGuid[tab.name]= tab
        end
        if tab.guid then
            WoWTools_DataMixin.GroupGuid[tab.guid]= tab
        end
        table.insert(unitList, tab.unit)
    end

    WoWTools_UnitMixin:GetNotifyInspect(unitList)--取得装等
end









EventRegistry:RegisterFrameEventAndCallback("GROUP_ROSTER_UPDATE", function()
    GetGroupGuidDate()
end)
EventRegistry:RegisterFrameEventAndCallback("GROUP_LEFT", function()
    GetGroupGuidDate()
end)