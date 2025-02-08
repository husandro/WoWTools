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
category= e.AddPanel_Check({
        name= WoWTools_PetBattleMixin.addName5,
        GetValue= function() return not Save().Plus.disabled end,
        SetValue= function()
            Save().Plus.disabled = not Save().Plus.disabled and true or nil
            if not WoWTools_PetBattleMixin:Set_Plus() then
                print(e.addName, WoWTools_PetBattleMixin.addName5, e.onlyChinese and '重置位置' or RESET_POSITION)
            end
        end,
        layout= Layout,
        category= Category,
    })

--技能按钮
    e.AddPanel_Check_Button({
        checkName= WoWTools_PetBattleMixin.addName4,
        GetValue= function() return not Save().TrackButton.disabled end,
        SetValue= function()
            Save().TrackButton.disabled= not Save().TrackButton.disabled and true or nil
            WoWTools_PetBattleMixin:Set_TrackButton(true)
        end,
        buttonText= e.onlyChinese and '重置位置' or RESET_POSITION,
        buttonFunc= function()
            Save().TrackButton.point= nil
            if WoWTools_PetBattleMixin.TrackButton then
                WoWTools_PetBattleMixin.TrackButton:set_point()
            end
            print(e.addName, WoWTools_PetBattleMixin.addName, e.onlyChinese and '重置位置' or RESET_POSITION)
        end,
        tooltip= WoWTools_PetBattleMixin.addName,
        layout= Layout,
        category= Category,
    }, category)

--宠物类型, TrackButton
    e.AddPanel_Check_Button({
        checkName= WoWTools_PetBattleMixin.addName4,
        GetValue= function() return not Save().TrackButton.disabled end,
        SetValue= function()
            Save().TrackButton.disabled= not Save().TrackButton.disabled and true or nil
            WoWTools_PetBattleMixin:Set_TrackButton(true)
        end,
        buttonText= e.onlyChinese and '重置位置' or RESET_POSITION,
        buttonFunc= function()
            Save().TrackButton.point= nil
            if WoWTools_PetBattleMixin.TrackButton then
                WoWTools_PetBattleMixin.TrackButton:set_point()
            end
            print(e.addName, WoWTools_PetBattleMixin.addName, e.onlyChinese and '重置位置' or RESET_POSITION)
        end,
        tooltip= WoWTools_PetBattleMixin.addName,
        layout= Layout,
        category= Category,
    })

--点击移动
    e.AddPanel_Check({
        name= WoWTools_PetBattleMixin.addName2,
        tooltip=function()
            return
            '|n'..(not e.onlyChinese and CLICK_TO_MOVE..', '..REFORGE_CURRENT or '点击移动, 当前: ')..e.GetEnabeleDisable(C_CVar.GetCVarBool("autoInteract"))
            ..'|n'..(e.onlyChinese and '等级' or LEVEL)..' < '..GetMaxLevelForLatestExpansion()..'  '..e.GetEnabeleDisable(false)
            ..'|n'..(e.onlyChinese and '等级' or LEVEL)..' = '..GetMaxLevelForLatestExpansion()..'  '..e.GetEnabeleDisable(true)
            ..(e.Player.levelMax and '|n|n|cnRED_FONT_COLOR:'..(e.onlyChinese and '满级' or GUILD_RECRUITMENT_MAXLEVEL) or '')
        end,
        GetValue= function() return Save().clickToMove end,
        SetValue= function()
            Save().clickToMove = not Save().clickToMove and true or nil
            WoWTools_PetBattleMixin:ClickToMove_CVar()--点击移动
        end,
        layout= Layout,
        category= Category,
    })

--点击移动按钮
    category= e.AddPanel_Check_Button({
        checkName= WoWTools_PetBattleMixin.addName3,
        GetValue= function() return not Save().MoveButton.disabled end,
        SetValue= function()
            Save().MoveButton.disabled= not Save().MoveButton.disabled and true or nil
            WoWTools_PetBattleMixin:ClickToMove_Button()
        end,
        buttonText= e.onlyChinese and '重置位置' or RESET_POSITION,
        buttonFunc= function()
            Save().MoveButton.Point=nil
            WoWTools_PetBattleMixin:ClickToMove_Button()
            print(e.addName, WoWTools_PetBattleMixin.addName3, e.onlyChinese and '重置位置' or RESET_POSITION)
        end,
        layout= Layout,
        category= Category,
    })

--点击移动按钮 SetParent
    e.AddPanel_Check({
        name= 'PlayerFrame',
        tooltip='|nSetParent(\'PlayerFrame\')|n|n'..WoWTools_PetBattleMixin.addName3,
        GetValue= function() return Save().MoveButton.PlayerFrame end,
        SetValue= function()
            Save().MoveButton.PlayerFrame = not Save().MoveButton.PlayerFrame and true or nil
            WoWTools_PetBattleMixin:ClickToMove_Button()
        end,
        layout= Layout,
        category= Category,
    }, category)


    return true
end






local function Init_Panel()
    Category, Layout= e.AddPanel_Sub_Category({name=WoWTools_PetBattleMixin.addName})
    WoWTools_PetBattleMixin.Category= Category

    e.AddPanel_Check({
        name= e.onlyChinese and '启用' or ENABLE,
        tooltip= WoWTools_PetBattleMixin.addName,
        GetValue= function() return not Save().disabled end,
        category= Category,
        func= function()
            Save().disabled= not Save().disabled and true or nil
            WoWTools_PetBattleMixin:Set_Options()
            print(e.addName, WoWTools_PetBattleMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
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

