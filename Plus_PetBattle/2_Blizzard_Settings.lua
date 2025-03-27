local function Save()
    return WoWToolsSave['Plus_PetBattle2']
end

local Category, Layout








local function Init()
    if Save().disabled then
        return
    end
    WoWTools_PanelMixin:Header(Layout, WoWTools_Mixin.onlyChinese and '选项' or OPTIONS)

    local category

--宠物对战 Plus
--[[WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_PetBattleMixin.addName5,
        GetValue= function() return not Save().Plus.disabled end,
        SetValue= function()
            Save().Plus.disabled = not Save().Plus.disabled and true or nil
            if not WoWTools_PetBattleMixin:Set_Plus() then
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_PetBattleMixin.addName5, WoWTools_Mixin.onlyChinese and '重置位置' or RESET_POSITION)
            end
        end,
        layout= Layout,
        category= Category,
    })]]

--技能按钮
    WoWTools_PanelMixin:Check_Button({
        checkName= WoWTools_PetBattleMixin.addName6,
        GetValue= function() return not Save().AbilityButton.disabled end,
        SetValue= function()
            Save().AbilityButton.disabled= not Save().AbilityButton.disabled and true or nil
            WoWTools_PetBattleMixin:Init_AbilityButton()
        end,
        buttonText= WoWTools_Mixin.onlyChinese and '重置' or RESET,
        buttonFunc= function()
            Save().AbilityButton= {disabled= Save().AbilityButton.disabled}
            WoWTools_PetBattleMixin:Init_AbilityButton()
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_PetBattleMixin.addName6, WoWTools_Mixin.onlyChinese and '重置' or RESET)
        end,
        tooltip= WoWTools_PetBattleMixin.addName,
        layout= Layout,
        category= Category,
    })

--宠物类型, TypeButton
    WoWTools_PanelMixin:Check_Button({
        checkName= WoWTools_PetBattleMixin.addName4,
        GetValue= function() return not Save().TypeButton.disabled end,
        SetValue= function()
            Save().TypeButton.disabled= not Save().TypeButton.disabled and true or nil
            WoWTools_PetBattleMixin:Set_TypeButton(true)
        end,
        buttonText= WoWTools_Mixin.onlyChinese and '重置' or RESET,
        buttonFunc= function()
            Save().TypeButton= {
                disabled=Save().TypeButton.disabled,
                showBackground=true,
            }
            WoWTools_PetBattleMixin:Set_TypeButton()
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_PetBattleMixin.addName, WoWTools_Mixin.onlyChinese and '重置位置' or RESET_POSITION)
        end,
        tooltip= WoWTools_PetBattleMixin.addName,
        layout= Layout,
        category= Category,
    })

    WoWTools_PanelMixin:Header(Layout, WoWTools_Mixin.onlyChinese and '其它' or OTHER)
--[[点击移动
    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.Icon.right..(WoWTools_Mixin.onlyChinese and '点击移动' or CLICK_TO_MOVE),
        tooltip=function()
            return
            '|n'..(not WoWTools_Mixin.onlyChinese and CLICK_TO_MOVE..', '..REFORGE_CURRENT or '点击移动, 当前: ')..WoWTools_TextMixin:GetEnabeleDisable(C_CVar.GetCVarBool("autoInteract"))
            ..'|n'..(WoWTools_Mixin.onlyChinese and '等级' or LEVEL)..' < '..GetMaxLevelForLatestExpansion()..'  '..WoWTools_TextMixin:GetEnabeleDisable(false)
            ..'|n'..(WoWTools_Mixin.onlyChinese and '等级' or LEVEL)..' = '..GetMaxLevelForLatestExpansion()..'  '..WoWTools_TextMixin:GetEnabeleDisable(true)
            ..(WoWTools_DataMixin.Player.IsMaxLevel and '|n|n|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '满级' or GUILD_RECRUITMENT_MAXLEVEL) or '')
        end,
        GetValue= function() return Save().clickToMove end,
        SetValue= function()
            Save().clickToMove = not Save().clickToMove and true or nil
            WoWTools_PetBattleMixin:ClickToMove_CVar()--点击移动
        end,
        layout= Layout,
        category= Category,
    })]]

--点击移动按钮
    category= WoWTools_PanelMixin:Check_Button({
        checkName= WoWTools_PetBattleMixin.addName3,
        GetValue= function() return not Save().ClickMoveButton.disabled end,
        SetValue= function()
            Save().ClickMoveButton.disabled= not Save().ClickMoveButton.disabled and true or nil
            WoWTools_PetBattleMixin:ClickToMove_Button()
        end,
        buttonText= WoWTools_Mixin.onlyChinese and '重置' or RESET,
        buttonFunc= function()
            Save().ClickMoveButton= {
                disabled= Save().ClickMoveButton.disabled,
                PlayerFrame=true,
                lock_autoInteract=WoWTools_DataMixin.Player.husandro and '1' or nil,
                lock_cameraSmoothStyle= WoWTools_DataMixin.Player.husandro and '0' or nil,
                lock_cameraSmoothTrackingStyle= WoWTools_DataMixin.Player.husandro and '0' or nil,
            }
            WoWTools_PetBattleMixin:ClickToMove_Button()
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_PetBattleMixin.addName3, WoWTools_Mixin.onlyChinese and '重置' or RESET)
        end,
        layout= Layout,
        category= Category,
    })

--点击移动按钮 SetParent
    WoWTools_PanelMixin:OnlyCheck({
        name= 'PlayerFrame',
        tooltip='|nSetParent(\'PlayerFrame\')|n|n'..WoWTools_PetBattleMixin.addName3,
        GetValue= function() return Save().ClickMoveButton.PlayerFrame end,
        SetValue= function()
            Save().ClickMoveButton.PlayerFrame = not Save().ClickMoveButton.PlayerFrame and true or nil
            WoWTools_PetBattleMixin:ClickToMove_Button()
        end,
        layout= Layout,
        category= Category,
    }, category)


    return true
end






local function Init_Panel()
    Category, Layout= WoWTools_PanelMixin:AddSubCategory({
        name=WoWTools_PetBattleMixin.addName,
        disabled= Save().disabled,
    })

    WoWTools_PetBattleMixin.Category= Category

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_Mixin.onlyChinese and '启用' or ENABLE,
        tooltip= WoWTools_PetBattleMixin.addName,
        GetValue= function() return not Save().disabled end,
        category= Category,
        func= function()
            Save().disabled= not Save().disabled and true or nil
            WoWTools_PetBattleMixin:Set_Options()
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_PetBattleMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    })

end














function WoWTools_PetBattleMixin:Init_Options()
    Init_Panel()
end
function WoWTools_PetBattleMixin:Set_Options()
    if Init() then
        Init=function()end
    end
end

