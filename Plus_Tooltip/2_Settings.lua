
local function Init()


    --装备，对比，提示
    ShoppingTooltip1.Portrait= ShoppingTooltip1:CreateTexture(nil, 'BACKGROUND',nil, 2)--右上角图标
    ShoppingTooltip1.Portrait:SetPoint('TOPRIGHT',-2, -3)
    ShoppingTooltip1.Portrait:SetSize(40,40)
    ShoppingTooltip1.Portrait:SetAtlas('Adventures-Target-Indicator')
    ShoppingTooltip1.Portrait:SetAlpha(0.5)

    ShoppingTooltip2.Portrait= ShoppingTooltip2:CreateTexture(nil, 'BACKGROUND',nil, 2)--右上角图标
    ShoppingTooltip2.Portrait:SetPoint('TOPRIGHT',-2, -3)
    ShoppingTooltip2.Portrait:SetSize(40,40)
    ShoppingTooltip2.Portrait:SetAtlas('Adventures-Target-Indicator')
    ShoppingTooltip2.Portrait:SetAlpha(0.5)


    TooltipDataProcessor.AddTooltipPostCall(TooltipDataProcessor.AllTypes, function(tooltip)
        if not tooltip.textLeft then
            WoWTools_TooltipMixin:Set_Init_Item(tooltip)--创建，设置，内容
        end
        if tooltip==ItemRefTooltip then
            WoWTools_TooltipMixin:Set_Init_Item(tooltip, true)--创建，设置，内容
        end
    end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
        WoWTools_TooltipMixin:Set_Unit(tooltip)--单位
    end)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
        if tooltip==ShoppingTooltip1 or ShoppingTooltip2==tooltip then
            return
        end
        local itemLink, itemID= select(2, TooltipUtil.GetDisplayedItem(tooltip))--物品
        itemLink= itemLink or itemID or data.id
        WoWTools_TooltipMixin:Set_Item(tooltip, itemLink, itemID)
    end)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, function(tooltip, data)
        if tooltip==ShoppingTooltip1 or ShoppingTooltip2==tooltip then
            return
        end
        local itemLink, itemID= select(2, TooltipUtil.GetDisplayedItem(tooltip))--物品
        itemLink= itemLink or itemID or data.id
        WoWTools_TooltipMixin:Set_Item(tooltip, itemLink, itemID)
    end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, function(tooltip, data)
        WoWTools_TooltipMixin:Set_Spell(tooltip, data.id)--法术
    end)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Currency, function(tooltip, data)
        WoWTools_TooltipMixin:Set_Currency(tooltip, data.id)--货币
    end)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.UnitAura, function(tooltip, data)
        WoWTools_TooltipMixin:Set_All_Aura(tooltip, data)--Aura
    end)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.AzeriteEssence, function(tooltip, data)
        WoWTools_TooltipMixin:Set_Azerite(tooltip, data.id)--艾泽拉斯之心
    end)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Mount, function(tooltip, data)
        WoWTools_TooltipMixin:Set_Mount(tooltip, data.id)--坐骑
    end)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Flyout, function(tooltip, data)
        WoWTools_TooltipMixin:Set_Flyout(tooltip, data.id)--法术弹出框
    end)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Achievement, function(tooltip, data)
        WoWTools_TooltipMixin:Set_Achievement(tooltip, data.id)--成就
    end)


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



    --################
    --Buff, 来源, 数据, 不可删除，如果删除，目标buff没有数据
    --################
    hooksecurefunc(GameTooltip, "SetUnitBuff", function(...)
        WoWTools_TooltipMixin:Set_Buff('Buff', ...)
    end)
    hooksecurefunc(GameTooltip, "SetUnitDebuff", function(...)
        WoWTools_TooltipMixin:Set_Buff('Debuff', ...)
    end)
    hooksecurefunc(GameTooltip, "SetUnitAura", function(...)
        WoWTools_TooltipMixin:Set_Buff('Aura', ...)
    end)
end













function WoWTools_TooltipMixin:Init_Settings()
    Init()
end