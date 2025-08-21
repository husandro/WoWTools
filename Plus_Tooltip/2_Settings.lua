
local function Init()

    TooltipDataProcessor.AddTooltipPostCall(TooltipDataProcessor.AllTypes, function(tooltip)
        if not tooltip.textLeft then
            WoWTools_TooltipMixin:Set_Init_Item(tooltip)--创建，设置，内容
        end
        if tooltip==ItemRefTooltip then
            WoWTools_TooltipMixin:Set_Init_Item(tooltip, true)--创建，设置，内容
        end
    end)







--物品 0
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
        if tooltip==ShoppingTooltip1 or ShoppingTooltip2==tooltip then
            return
        end
        local itemLink, itemID= select(2, TooltipUtil.GetDisplayedItem(tooltip))
        itemID= itemID or data.id
        WoWTools_TooltipMixin:Set_Item(tooltip, itemLink, itemID)
    end)

--法术 1
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, function(tooltip, data)
        WoWTools_TooltipMixin:Set_Spell(tooltip, data.id)
    end)

--单位 Unit 2
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
        WoWTools_TooltipMixin:Set_Unit(tooltip)
    end)

--Corpse 3
--Object 4

--货币 5
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Currency, function(tooltip, data)
        WoWTools_TooltipMixin:Set_Currency(tooltip, data.id)
    end)

--BattlePet 6

--UnitAura 7
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.UnitAura, function(tooltip, data)
        WoWTools_TooltipMixin:Set_All_Aura(tooltip, data)
    end)
--艾泽拉斯之心 8
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.AzeriteEssence, function(tooltip, data)
        WoWTools_TooltipMixin:Set_Azerite(tooltip, data.id)
    end)

--CompanionPet 9

--坐骑 10
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Mount, function(tooltip, data)
        WoWTools_TooltipMixin:Set_Mount(tooltip, data.id)
    end)

--PetAction 11
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.PetAction, function(tooltip, data)
        local action= tooltip:GetOwner()
        local spellID = select(7, GetPetActionInfo(action and action:GetID() or 0))
        WoWTools_TooltipMixin:Set_Spell(tooltip, spellID)
    end)
--成就 12
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Achievement, function(tooltip, data)
        WoWTools_TooltipMixin:Set_Achievement(tooltip, data.id)
    end)



--EnhancedConduit 13
--EquipmentSet 14
--InstanceLock 15
--PvPBrawl 16
--RecipeRankInfo 17
--Totem 18

--玩具 19
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, function(tooltip, data)
        if tooltip==ShoppingTooltip1 or ShoppingTooltip2==tooltip then
            return
        end
        local itemLink, itemID= select(2, TooltipUtil.GetDisplayedItem(tooltip))
        itemLink= itemLink or itemID or data.id
        WoWTools_TooltipMixin:Set_Item(tooltip, itemLink, itemID)
    end)

--CorruptionCleanser 20
--MinimapMouseover 21

--法术弹出框 22
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Flyout, function(tooltip, data)
        WoWTools_TooltipMixin:Set_Flyout(tooltip, data.id)
    end)

--任务 25
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Quest, function(tooltip, data)
        WoWTools_TooltipMixin:Set_Quest(tooltip, data.id, data)
    end)

--QuestPartyProgress 24

--宏 Macro 25
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Macro, function(tooltip)
        local frame= tooltip:GetOwner()--宏 11版本
        if frame and frame.action then
            local type, macroID, subType= GetActionInfo(frame.action)
            if type=='macro' and macroID then
                if subType=='spell' then--and macroID or GetMacroSpell(macroID)
                    WoWTools_TooltipMixin:Set_Spell(tooltip, macroID)
                elseif not subType or subType=='' then
                    local text=GetMacroBody(macroID)
                    if text then
                        tooltip:AddLine(text,nil,nil,nil,true)
                    end
                end
            end
        end
    end)

--Debug 26








--Buff, 来源, 数据, 不可删除，如果删除，目标buff没有数据
    hooksecurefunc(GameTooltip, "SetUnitBuff", function(...)
        WoWTools_TooltipMixin:Set_Buff('Buff', ...)
    end)
    hooksecurefunc(GameTooltip, "SetUnitDebuff", function(...)
        WoWTools_TooltipMixin:Set_Buff('Debuff', ...)
    end)
    hooksecurefunc(GameTooltip, "SetUnitAura", function(...)
        WoWTools_TooltipMixin:Set_Buff('Aura', ...)
    end)


    Init=function()end
end













function WoWTools_TooltipMixin:Init_Settings()
    Init()
end


--[[

{
Name = "TooltipDataType",
Type = "Enumeration",
NumValues = 27,
MinValue = 0,
MaxValue = 26,
Fields =
{
    { Name = "Item", Type = "TooltipDataType", EnumValue = 0 },
    { Name = "Spell", Type = "TooltipDataType", EnumValue = 1 },
    { Name = "Unit", Type = "TooltipDataType", EnumValue = 2 },
    { Name = "Corpse", Type = "TooltipDataType", EnumValue = 3 },
    { Name = "Object", Type = "TooltipDataType", EnumValue = 4 },
    { Name = "Currency", Type = "TooltipDataType", EnumValue = 5 },
    { Name = "BattlePet", Type = "TooltipDataType", EnumValue = 6 },
    { Name = "UnitAura", Type = "TooltipDataType", EnumValue = 7 },
    { Name = "AzeriteEssence", Type = "TooltipDataType", EnumValue = 8 },
    { Name = "CompanionPet", Type = "TooltipDataType", EnumValue = 9 },
    { Name = "Mount", Type = "TooltipDataType", EnumValue = 10 },
    { Name = "PetAction", Type = "TooltipDataType", EnumValue = 11 },
    { Name = "Achievement", Type = "TooltipDataType", EnumValue = 12 },
    { Name = "EnhancedConduit", Type = "TooltipDataType", EnumValue = 13 },
    { Name = "EquipmentSet", Type = "TooltipDataType", EnumValue = 14 },
    { Name = "InstanceLock", Type = "TooltipDataType", EnumValue = 15 },
    { Name = "PvPBrawl", Type = "TooltipDataType", EnumValue = 16 },
    { Name = "RecipeRankInfo", Type = "TooltipDataType", EnumValue = 17 },
    { Name = "Totem", Type = "TooltipDataType", EnumValue = 18 },
    { Name = "Toy", Type = "TooltipDataType", EnumValue = 19 },
    { Name = "CorruptionCleanser", Type = "TooltipDataType", EnumValue = 20 },
    { Name = "MinimapMouseover", Type = "TooltipDataType", EnumValue = 21 },
    { Name = "Flyout", Type = "TooltipDataType", EnumValue = 22 },
    { Name = "Quest", Type = "TooltipDataType", EnumValue = 23 },
    { Name = "QuestPartyProgress", Type = "TooltipDataType", EnumValue = 24 },
    { Name = "Macro", Type = "TooltipDataType", EnumValue = 25 },
    { Name = "Debug", Type = "TooltipDataType", EnumValue = 26 },
},
},
]]