local function Save()
    return WoWToolsSave['Plus_Spell']
end

local Category, Layout



local function Init_Category()
    Category, Layout= WoWTools_PanelMixin:AddSubCategory({
        name=WoWTools_SpellMixin.addName,
        disabled=Save().disabled
    })
    WoWTools_PanelMixin.Category= Category

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '启用' or ENABLE,
        tooltip= WoWTools_SpellMixin.addName,
        GetValue= function() return not Save().disabled end,
        category= Category,
        func= function()
            Save().disabled= not Save().disabled and true or nil
            print(
                WoWTools_DataMixin.Icon.icon2..WoWTools_SpellMixin.addName,
                WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
            )
        end
    })

    Init_Category= function()end
end
















local function Blizzard_Settings()
    if not C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
        return
    end

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

    WoWTools_PanelMixin:OnlyCheck({
        name= '|A:UI-HUD-ActionBar-Interrupt:0:0|a'..(WoWTools_DataMixin.onlyChinese and '动作条颜色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ACTIONBARS_LABEL, COLOR)),
        tooltip= WoWTools_PanelMixin.addName,
        GetValue= function() return Save().actionButtonRangeColor end,
        category= Category,
        SetValue= function()
            Save().actionButtonRangeColor= not Save().actionButtonRangeColor and true or nil
            WoWTools_SpellMixin:Init_ActionButton_UpdateRange()--法术按键, 颜色
            if not Save().actionButtonRangeColor then
                print(
                    WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(Save().actionButtonRangeColor),
                    WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                )
            end
        end
    })




    Blizzard_Settings=function()end
end














function WoWTools_SpellMixin:Init_Options()
    Init_Category()
    Blizzard_Settings()
end
     --[[添加控制面板
     WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_SpellMixin.addName,
        tooltip= WoWTools_DataMixin.onlyChinese and '法术距离, 颜色'
                or (
                    format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SPELLS, TRACKER_SORT_PROXIMITY)..': '.. COLOR

            ),
        Value= not Save().disabled,
        GetValue=function() return not Save().disabled end,
        SetValue= function()
            Save().disabled= not Save().disabled and true or nil
            print(
                WoWTools_DataMixin.Icon.icon2..WoWTools_SpellMixin.addName,
                WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
            )
        end,
        layout= WoWTools_OtherMixin.Layout,
        category= WoWTools_OtherMixin.Category,
    })
]]
