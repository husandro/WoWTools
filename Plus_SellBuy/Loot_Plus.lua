local e= select(2, ...)





--自动拾取 Plus
local function Init()
    local check=CreateFrame("CheckButton", nil, LootFrame.TitleContainer, "InterfaceOptionsCheckButtonTemplate")
    check:SetPoint('TOPLEFT',-27,2)

    check:SetScript('OnClick', function()
        if UnitAffectingCombat('player') then
            return
        end
        C_CVar.SetCVar("autoLootDefault", not C_CVar.GetCVarBool("autoLootDefault") and '1' or '0')
        local value= C_CVar.GetCVarBool("autoLootDefault")
        print(e.Icon.icon2..WoWTools_SellBuyMixin.addName, '|cffff00ff|A:Cursor_lootall_128:0:0|a'..(e.onlyChinese and "自动拾取" or AUTO_LOOT_DEFAULT_TEXT)..' Plus|r|n', not e.onlyChinese and AUTO_LOOT_DEFAULT_TEXT or "自动拾取", e.GetEnabeleDisable(value))

        if value and not IsModifierKeyDown() then
            for i = GetNumLootItems(), 1, -1 do
                LootSlot(i)
            end
        end
    end)

    check:SetScript('OnLeave', GameTooltip_Hide)
    check:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_SellBuyMixin.addName)
        GameTooltip:AddLine('|cffff00ff|A:Cursor_lootall_128:0:0|a'..(e.onlyChinese and "自动拾取" or AUTO_LOOT_DEFAULT_TEXT)..' Plus|r')
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(e.onlyChinese and '自动拾取' or AUTO_LOOT_DEFAULT_TEXT, (e.onlyChinese and '当前' or REFORGE_CURRENT)..': '..e.GetEnabeleDisable(C_CVar.GetCVarBool("autoLootDefault")))
        local col= UnitAffectingCombat('player') and '|cff9e9e9e'
        GameTooltip:AddDoubleLine((col or '')..(e.onlyChinese and '拾取时' or PROC_EVENT512_DESC:format(ITEM_LOOT)),
            (col or '|cnGREEN_FONT_COLOR:')..'Shift|r '..(e.onlyChinese and '禁用' or DISABLE))
        GameTooltip:Show()
    end)

    check:SetScript('OnShow', function(self)
        self:SetEnabled(not UnitAffectingCombat('player'))
        self:SetChecked(C_CVar.GetCVarBool("autoLootDefault"))
    end)

    check:RegisterEvent('LOOT_READY')
    check:SetScript('OnEvent', function()
        if IsShiftKeyDown() and not UnitAffectingCombat('player') then
            C_CVar.SetCVar("autoLootDefault", '0')
            print(e.Icon.icon2..WoWTools_SellBuyMixin.addName,'|cffff00ff|A:Cursor_lootall_128:0:0|a'..(e.onlyChinese and "自动拾取" or AUTO_LOOT_DEFAULT_TEXT)..' Plus|r','|cnGREEN_FONT_COLOR:Shift|r', e.onlyChinese and "自动拾取" or AUTO_LOOT_DEFAULT_TEXT, e.GetEnabeleDisable(C_CVar.GetCVarBool("autoLootDefault")))

        else
            if C_CVar.GetCVarBool("autoLootDefault") then
                for i = GetNumLootItems(), 1, -1 do
                    LootSlot(i)
                end
            end
        end
    end)


    LootFrame:HookScript("OnShow", function ()
        if C_CVar.GetCVarBool("autoLootDefault") then
            for i= GetNumLootItems(), 1, -1 do
                LootSlot(i)
            end
        end
    end)
end






function WoWTools_SellBuyMixin:Init_AutoLoot()
    if not self.Save.notAutoLootPlus then
        Init()
    end
end
