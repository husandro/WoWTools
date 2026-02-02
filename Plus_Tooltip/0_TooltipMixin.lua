WoWTools_TooltipMixin={
    WoWHead= 'https://www.wowhead.com/',
    Events={},
    Frames={},
    addName= '|A:newplayertutorial-drag-cursor:0:0|aTooltips',
    iconSize=0,
    Save= function()
        return WoWToolsSave['Plus_Tootips']
    end,
}

--设置，宽度
function WoWTools_TooltipMixin:Set_Width(tooltip)
    if tooltip.HasAnySecretAspect and tooltip:HasAnySecretAspect() then--12.0才有
        return
    end

    local w= tooltip:GetWidth()
    local w2= tooltip.textLeft:GetWidth()
    if canaccessvalue(w2) then
        w2= w2+ tooltip.text2Left:GetWidth()+ tooltip.textRight:GetWidth()
        if w<w2 then
            tooltip:SetMinimumWidth(w2)
        end
    end
end


--设置单位
function WoWTools_TooltipMixin:Set_Unit(tooltip)--设置单位提示信息

    local name, unit, guid= TooltipUtil.GetDisplayedUnit(tooltip)
    if not canaccessvalue(unit) or not unit then
        return
    end

    if UnitIsPlayer(unit) then
        self:Set_Unit_Player(tooltip, name, unit, guid)

    elseif (UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then--宠物TargetFrame.lua
        self:Set_Pet(tooltip, UnitBattlePetSpeciesID(unit))

    else
        self:Set_Unit_NPC(tooltip, name, unit, guid)
    end
end

function WoWTools_TooltipMixin:IsInCombatDisabled(tooltip)
    return --(tooltip.HasAnySecretAspect and tooltip:HasAnySecretAspect())--12.0才有
        not tooltip
        or WoWTools_FrameMixin:IsLocked(tooltip)
        or (self:Save().isInCombatDisabled and InCombatLockdown())
end

function WoWTools_TooltipMixin:OpenOption(root, name2)
    return WoWTools_MenuMixin:OpenOptions(root, {category=self.Category, name=self.addName, nam2=name2})
end
