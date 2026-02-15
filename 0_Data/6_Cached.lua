

WoWTools_DataMixin.WoWGUID={}--战网，好友GUID--WoWTools_DataMixin.WoWGUID[名称-服务器]=guid
WoWTools_DataMixin.UnitItemLevel={}--玩家装等
WoWTools_DataMixin.GroupGuid={}--队伍数据收集











local function Cached_Group(unit)
    local guid= UnitGUID(unit)
    if not canaccessvalue(guid) or not guid then
        return
    end

    WoWTools_DataMixin.GroupGuid[guid]= {
        unit= unit,
        combatRole= UnitGroupRolesAssigned(unit),
        faction= UnitFactionGroup(unit),
    }
    WoWTools_DataMixin.GroupGuid[GetUnitName(unit, true)]= {
        unit= unit,
        combatRole= UnitGroupRolesAssigned(unit),
        guid=guid,
        faction= UnitFactionGroup(unit),
    }
end




local function Cached_ItemLevel(unit, guid)
    unit= unit or (canaccessvalue(guid) and guid and UnitTokenFromGUID(guid))
    if not unit then
        return
    end


    local color= WoWTools_UnitMixin:GetColor(unit, guid)
    local r,g,b= color:GetRGB()
    local hex= color:GenerateHexColorMarkup()

    local data= WoWTools_DataMixin.UnitItemLevel[guid] or {}

    WoWTools_DataMixin.UnitItemLevel[guid] = {--玩家装等
        itemLevel= C_PaperDollInfo.GetInspectItemLevel(unit) or data.itemLevel,
        specID= GetInspectSpecialization(unit) or data.specID,
        faction= UnitFactionGroup(unit) or data.faction,
        col= hex,
        r=r,
        g=g,
        b=b,
        level=UnitLevel(unit),
    }
end




EventRegistry:RegisterFrameEventAndCallback("INSPECT_READY", function(_, guid)--取得玩家信息
    local unit= canaccessvalue(guid) and guid and UnitTokenFromGUID(guid)
    if not unit then
        return
    end

    Cached_ItemLevel(unit, guid)

    if UnitInParty(unit) and PartyFrame:IsVisible() then
        --先使用一次，用以Shift+点击，设置焦点功能, Invite.lua
        for i=1, 4 do
            local frame= PartyFrame['MemberFrame'..i]
            if frame:IsShown() and frame.classFrame then
                if UnitGUID('party'..i)==guid then
                    frame.classFrame:set_settings(guid)
                    break
                end
            end
        end
    end

    if WoWTools_UnitMixin:UnitIsUnit(unit, 'target') and TargetFrame.classFrame then
        TargetFrame.classFrame:set_settings(guid)
    end

--设置 GameTooltip
    if  GameTooltip.textLeft and GameTooltip:IsShown() then
        local name2, unit2, guid2= TooltipUtil.GetDisplayedUnit(GameTooltip)
        if canaccessvalue(guid2) and guid2==guid then
            WoWTools_TooltipMixin:Set_Unit_Player(GameTooltip, name2, unit2, guid2)
        end
    end

--保存，自已，装等
    if guid==WoWTools_DataMixin.Player.GUID then
        WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].itemLevel= GetAverageItemLevel()
        WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].specID= PlayerUtil.GetCurrentSpecID()
    end
end)

