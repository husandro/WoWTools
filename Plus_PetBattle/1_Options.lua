local e= select(2, ...)

local function Save()
    return WoWTools_PetBattleMixin.Save
end

local Category, Layout








local function Init()
    if Save().disabled then
        return
    end
    e.AddPanel_Header(Layout, e.onlyChinese and '选项' or OPTIONS)

    local category

--宠物对战 Plus
--[[e.AddPanel_Check({
        name= WoWTools_PetBattleMixin.addName5,
        GetValue= function() return not Save().Plus.disabled end,
        SetValue= function()
            Save().Plus.disabled = not Save().Plus.disabled and true or nil
            if not WoWTools_PetBattleMixin:Set_Plus() then
                print(e.Icon.icon2..WoWTools_PetBattleMixin.addName5, e.onlyChinese and '重置位置' or RESET_POSITION)
            end
        end,
        layout= Layout,
        category= Category,
    })]]

--技能按钮
    e.AddPanel_Check_Button({
        checkName= WoWTools_PetBattleMixin.addName6,
        GetValue= function() return not Save().AbilityButton.disabled end,
        SetValue= function()
            Save().AbilityButton.disabled= not Save().AbilityButton.disabled and true or nil
            WoWTools_PetBattleMixin:Init_AbilityButton()
        end,
        buttonText= e.onlyChinese and '重置' or RESET,
        buttonFunc= function()
            Save().AbilityButton= {disabled= Save().AbilityButton.disabled}
            WoWTools_PetBattleMixin:Init_AbilityButton()
            print(e.Icon.icon2..WoWTools_PetBattleMixin.addName6, e.onlyChinese and '重置' or RESET)
        end,
        tooltip= WoWTools_PetBattleMixin.addName,
        layout= Layout,
        category= Category,
    })

--宠物类型, TypeButton
    e.AddPanel_Check_Button({
        checkName= WoWTools_PetBattleMixin.addName4,
        GetValue= function() return not Save().TypeButton.disabled end,
        SetValue= function()
            Save().TypeButton.disabled= not Save().TypeButton.disabled and true or nil
            WoWTools_PetBattleMixin:Set_TypeButton(true)
        end,
        buttonText= e.onlyChinese and '重置' or RESET,
        buttonFunc= function()
            Save().TypeButton= {
                disabled=Save().TypeButton.disabled,
                showBackground=true,
            }
            WoWTools_PetBattleMixin:Set_TypeButton()
            print(e.Icon.icon2..WoWTools_PetBattleMixin.addName, e.onlyChinese and '重置位置' or RESET_POSITION)
        end,
        tooltip= WoWTools_PetBattleMixin.addName,
        layout= Layout,
        category= Category,
    })

    e.AddPanel_Header(Layout, e.onlyChinese and '其它' or OTHER)
--[[点击移动
    e.AddPanel_Check({
        name= e.Icon.right..(e.onlyChinese and '点击移动' or CLICK_TO_MOVE),
        tooltip=function()
            return
            '|n'..(not e.onlyChinese and CLICK_TO_MOVE..', '..REFORGE_CURRENT or '点击移动, 当前: ')..e.GetEnabeleDisable(C_CVar.GetCVarBool("autoInteract"))
            ..'|n'..(e.onlyChinese and '等级' or LEVEL)..' < '..GetMaxLevelForLatestExpansion()..'  '..e.GetEnabeleDisable(false)
            ..'|n'..(e.onlyChinese and '等级' or LEVEL)..' = '..GetMaxLevelForLatestExpansion()..'  '..e.GetEnabeleDisable(true)
            ..(e.Player.IsMaxLevel and '|n|n|cnRED_FONT_COLOR:'..(e.onlyChinese and '满级' or GUILD_RECRUITMENT_MAXLEVEL) or '')
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
    category= e.AddPanel_Check_Button({
        checkName= WoWTools_PetBattleMixin.addName3,
        GetValue= function() return not Save().ClickMoveButton.disabled end,
        SetValue= function()
            Save().ClickMoveButton.disabled= not Save().ClickMoveButton.disabled and true or nil
            WoWTools_PetBattleMixin:ClickToMove_Button()
        end,
        buttonText= e.onlyChinese and '重置' or RESET,
        buttonFunc= function()
            Save().ClickMoveButton= {
                disabled= Save().ClickMoveButton.disabled,
                PlayerFrame=true,
                lock_autoInteract=e.Player.husandro and '1' or nil,
                lock_cameraSmoothStyle= e.Player.husandro and '0' or nil,
                lock_cameraSmoothTrackingStyle= e.Player.husandro and '0' or nil,
            }
            WoWTools_PetBattleMixin:ClickToMove_Button()
            print(e.Icon.icon2..WoWTools_PetBattleMixin.addName3, e.onlyChinese and '重置' or RESET)
        end,
        layout= Layout,
        category= Category,
    })

--点击移动按钮 SetParent
    e.AddPanel_Check({
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
    Category, Layout= e.AddPanel_Sub_Category({
        name=WoWTools_PetBattleMixin.addName,
        disabled= Save().disabled,
    })

    WoWTools_PetBattleMixin.Category= Category

    e.AddPanel_Check({
        name= e.onlyChinese and '启用' or ENABLE,
        tooltip= WoWTools_PetBattleMixin.addName,
        GetValue= function() return not Save().disabled end,
        category= Category,
        func= function()
            Save().disabled= not Save().disabled and true or nil
            WoWTools_PetBattleMixin:Set_Options()
            print(e.Icon.icon2..WoWTools_PetBattleMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
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

