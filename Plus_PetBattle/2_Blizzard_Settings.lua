local function Save()
    return WoWToolsSave['Plus_PetBattle2']
end

local Category, Layout








local function Init()
    if Save().disabled then
        return
    end

    WoWTools_PanelMixin:Header(Layout, WoWTools_DataMixin.onlyChinese and '选项' or OPTIONS)

    local category

--技能按钮
    WoWTools_PanelMixin:Check_Button({
        checkName= WoWTools_PetBattleMixin.addName6,
        GetValue= function() return not Save().AbilityButton.disabled end,
        SetValue= function()
            Save().AbilityButton.disabled= not Save().AbilityButton.disabled and true or nil
            WoWTools_PetBattleMixin:Init_AbilityButton()
        end,
        buttonText= WoWTools_DataMixin.onlyChinese and '重置' or RESET,
        buttonFunc= function()
            Save().AbilityButton= {disabled= Save().AbilityButton.disabled}
            WoWTools_PetBattleMixin:Init_AbilityButton()
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_PetBattleMixin.addName6, WoWTools_DataMixin.onlyChinese and '重置' or RESET)
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
        buttonText= WoWTools_DataMixin.onlyChinese and '重置' or RESET,
        buttonFunc= function()
            Save().TypeButton= {
                disabled=Save().TypeButton.disabled,
                showBackground=true,
            }
            WoWTools_PetBattleMixin:Set_TypeButton()
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_PetBattleMixin.addName, WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION)
        end,
        tooltip= WoWTools_PetBattleMixin.addName,
        layout= Layout,
        category= Category,
    })

    WoWTools_PanelMixin:Header(Layout, WoWTools_DataMixin.onlyChinese and '其它' or OTHER)


--点击移动按钮
    category= WoWTools_PanelMixin:Check_Button({
        checkName= WoWTools_PetBattleMixin.addName3,
        GetValue= function() return not Save().ClickMoveButton.disabled end,
        SetValue= function()
            Save().ClickMoveButton.disabled= not Save().ClickMoveButton.disabled and true or nil
            WoWTools_PetBattleMixin:ClickToMove_Button()
        end,
        buttonText= WoWTools_DataMixin.onlyChinese and '重置' or RESET,
        buttonFunc= function()
            Save().ClickMoveButton= {
                disabled= Save().ClickMoveButton.disabled,
                PlayerFrame=true,
                lock_autoInteract=WoWTools_DataMixin.Player.husandro and '1' or nil,
                lock_cameraSmoothStyle= WoWTools_DataMixin.Player.husandro and '0' or nil,
                lock_cameraSmoothTrackingStyle= WoWTools_DataMixin.Player.husandro and '0' or nil,
            }
            WoWTools_PetBattleMixin:ClickToMove_Button()
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_PetBattleMixin.addName3, WoWTools_DataMixin.onlyChinese and '重置' or RESET)
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
            Save().ClickMoveButton.PlayerFrame = not Save().ClickMoveButton.PlayerFrame and true or false
            WoWTools_PetBattleMixin:ClickToMove_Button()
        end,
        layout= Layout,
        category= Category,
    }, category)


    Init=function()end
end






local function Init_Panel()
    Category, Layout= WoWTools_PanelMixin:AddSubCategory({
        name=WoWTools_PetBattleMixin.addName,
        disabled= Save().disabled,
    })

    WoWTools_PetBattleMixin.Category= Category

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '启用' or ENABLE,
        tooltip= WoWTools_PetBattleMixin.addName,
        GetValue= function() return not Save().disabled end,
        category= Category,
        func= function()
            Save().disabled= not Save().disabled and true or nil
            WoWTools_PetBattleMixin:Set_Options()
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_PetBattleMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    })

    Init_Panel=function()end
end














function WoWTools_PetBattleMixin:Init_Options()
    Init_Panel()
end
function WoWTools_PetBattleMixin:Set_Options()
    Init()
end

