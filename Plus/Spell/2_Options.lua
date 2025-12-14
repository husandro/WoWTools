local function Save()
    return WoWToolsSave['Plus_Spell']
end

local Category, Layout



local function Init_Category()
    Category, Layout= WoWTools_PanelMixin:AddSubCategory({
        name=WoWTools_SpellMixin.addName,
        disabled=Save().disabled
    })
    WoWTools_SpellMixin.Category= Category
    
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
    WoWTools_PanelMixin:Header(Layout, 'Plus')

--法术弹出框
    WoWTools_PanelMixin:OnlyCheck({
        name= '|A:common-icon-backarrow:0:0|a'..(WoWTools_DataMixin.onlyChinese and '法术弹出框' or 'SpellFlyout'),
        tooltip= WoWTools_PanelMixin.addName,
        GetValue= function() return Save().flyoutText end,
        category= Category,
        SetValue= function()
            Save().flyoutText= not Save().flyoutText and true or false
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


--动作条颜色
    WoWTools_PanelMixin:OnlyCheck({
        name= '|A:UI-HUD-ActionBar-Interrupt:0:0|a'..(WoWTools_DataMixin.onlyChinese and '动作条颜色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ACTIONBARS_LABEL, COLOR)),
        tooltip= WoWTools_PanelMixin.addName,
        GetValue= function() return Save().actionButtonRangeColor end,
        category= Category,
        SetValue= function()
            Save().actionButtonRangeColor= not Save().actionButtonRangeColor and true or false
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


--专精按钮
    WoWTools_PanelMixin:OnlyCheck({
        name= '|A:talents-node-choiceflyout-circle-greenglow:0:0|a'..(WoWTools_DataMixin.onlyChinese and '专精按钮' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SPECIALIZATION, 'Button')),
        tooltip= WoWTools_PanelMixin.addName,
        GetValue= function() return Save().specButton.enabled end,
        category= Category,
        SetValue= function()
            Save().specButton.enabled= not Save().specButton.enabled and true or false
            WoWTools_SpellMixin:Init_Spec_Button()
            if not Save().specButton.enabled then
                print(
                    WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(Save().specButton.enabled),
                    WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                )
            end
        end
    })


--天赋
    WoWTools_PanelMixin:OnlyCheck({
        name= '|A:talents-button-undo:0:0|a'..(WoWTools_DataMixin.onlyChinese and '天赋' or TALENT),
        tooltip= WoWTools_PanelMixin.addName,
        GetValue= function() return Save().talentsFramePlus end,
        category= Category,
        SetValue= function()
            Save().talentsFramePlus= not Save().talentsFramePlus and true or false
            WoWTools_SpellMixin:Init_TalentsFrame()
            if not Save().talentsFramePlus then
                print(
                    WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(Save().talentsFramePlus),
                    WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                )
            end
        end
    })


--法术书
    WoWTools_PanelMixin:OnlyCheck({
        name= '|A:spellbook-item-iconframe:0:0|a'..(WoWTools_DataMixin.onlyChinese and '法术书' or SPELLBOOK),
        tooltip= WoWTools_PanelMixin.addName,
        GetValue= function() return Save().spellBookPlus end,
        category= Category,
        SetValue= function()
            Save().spellBookPlus= not Save().spellBookPlus and true or false
            WoWTools_SpellMixin:Init_SpellBookFrame()
            if not Save().spellBookPlus then
                print(
                    WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(Save().spellBookPlus),
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
