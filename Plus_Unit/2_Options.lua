local function Save()
    return WoWToolsSave['Plus_UnitFrame'] or {}
end






local function Init_Options()
    if not C_AddOns.IsAddOnLoaded('Blizzard_Settings') or Save().disabled then
        return
    end

--[[
    WoWTools_PanelMixin:OnlyCheck({
        name= '|A:common-icon-backarrow:0:0|a'..(WoWTools_DataMixin.onlyChinese and '法术弹出框' or 'SpellFlyout'),
        tooltip= WoWTools_PanelMixin.addName,
        GetValue= function() return Save().flyoutText end,
        category= Category,
        SetValue= function()
            Save().flyoutText= not Save().flyoutText and true or nil
            WoWTools_SpellMixin:Init_Spell_Flyout()
            if not Save().flyoutText then
                print(
                    WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(Save().flyoutText),
                    WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                )
            end
        end
    })
]]
--    WoWTools_PanelMixin:Header(Layout, 'Plus')

    Init_Options=function()end
end

function WoWTools_UnitMixin:Init_Options()
    Init_Options()
end