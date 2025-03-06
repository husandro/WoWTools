
local e= select(2, ...)
local function Save()
    return WoWTools_TextureMixin.Save
end

local Category, Layout



local function GetMinValueAlpha()--透明度，最小值
    local alpha= Save().alpha or 0.5
    WoWTools_TextureMixin.min= alpha<0.5 and 0.5 or (alpha<0.3 and 0.3) or 0.5
end








local function Init_Options()
    GetMinValueAlpha()--min，透明度，最小值

    Category, Layout= e.AddPanel_Sub_Category({
        name= WoWTools_TextureMixin.addName,
        disabled= Save().disabled,
    })

    e.AddPanel_Check({
        name= e.onlyChinese and '启用' or ENABLE,
        tooltip= WoWTools_TextureMixin.addName,
        category= Category,
        GetValue= function() return not Save().disabled end,
        SetValue= function()
            Save().disabled= not Save().disabled and true or nil
            print(WoWTools_Mixin.addName, WoWTools_TextureMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    })

    e.AddPanel_Header(Layout, e.onlyChinese and '材质' or TEXTURES_SUBHEADER)
    local initializer2= e.AddPanel_Check_Button({
        checkName= e.onlyChinese and '材质' or TEXTURES_SUBHEADER,
        GetValue= function() return not Save().disabledTexture end,
        SetValue= function()
            Save().disabledTexture= not Save().disabledTexture and true or nil
            print(WoWTools_Mixin.addName, WoWTools_TextureMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,
        buttonText= e.onlyChinese and '设置颜色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS ,COLOR),
        buttonFunc= function()
            e.OpenPanelOpting(nil, (e.Player.useColor and e.Player.useColor.hex or '')..(e.onlyChinese and '颜色' or COLOR))
        end,
        tooltip= WoWTools_TextureMixin.addName,
        layout= Layout,
        category= Category
    })

    local initializer= e.AddPanelSider({
        name= e.onlyChinese and '透明度' or 'Alpha',
        GetValue= function() return Save().alpha or 0.5 end,
        minValue= 0,
        maxValue= 1,
        setp= 0.1,
        tooltip= WoWTools_TextureMixin.addName,
        category= Category,
        SetValue= function(_, _, value2)
            if value2 then
                Save().alpha= e.GetFormatter1to10(value2, 0, 1)
                print(WoWTools_Mixin.addName, WoWTools_TextureMixin.addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save().disabled then return false else return true end end)

    e.AddPanel_Header(Layout, e.onlyChinese and '其它' or OTHER)

    initializer2= e.AddPanel_Check({
        name= e.onlyChinese and '聊天泡泡' or CHAT_BUBBLES_TEXT,
        tooltip= (e.onlyChinese and '在副本无效' or (INSTANCE..' ('..DISABLE..')'))
                ..'|n|n'..((e.onlyChinese and '说' or SAY)..' CVar: chatBubbles '.. e.GetShowHide(C_CVar.GetCVarBool("chatBubbles")))
                ..'|n'..((e.onlyChinese and '小队' or SAY)..' CVar: chatBubblesParty '.. e.GetShowHide(C_CVar.GetCVarBool("chatBubblesParty"))),
        category= Category,
        GetValue= function() return not Save().disabledChatBubble end,
        SetValue= function()
            Save().disabledChatBubble= not Save().disabledChatBubble and true or nil
            WoWTools_TextureMixin:Init_Chat_Bubbles()
            if Save().disabledChatBubble and BubblesFrame then
                print(WoWTools_Mixin.addName, WoWTools_TextureMixin.addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        end
    })
    initializer= e.AddPanelSider({
        name= e.onlyChinese and '透明度' or 'Alpha',
        GetValue= function() return Save().chatBubbleAlpha or 0.5 end,
        minValue= 0,
        maxValue= 1,
        setp= 0.1,
        tooltip= WoWTools_TextureMixin.addName,
        category= Category,
        SetValue= function(_, _, value2)
            if value2 then
                Save().chatBubbleAlpha= e.GetFormatter1to10(value2, 0, 1)
                WoWTools_TextureMixin:Init_Chat_Bubbles()
            end
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save().disabledChatBubble then return false else return true end end)

    initializer= e.AddPanelSider({
        name= e.onlyChinese and '缩放' or UI_SCALE,
        GetValue= function() return Save().chatBubbleSacal or 0.85 end,
        minValue= 0.3,
        maxValue= 1,
        setp= 0.1,
        tooltip= WoWTools_TextureMixin.addName,
        category= Category,
        SetValue= function(_, _, value2)
            if not value2 then return end
            Save().chatBubbleSacal= e.GetFormatter1to10(value2, 0.3, 1)
            WoWTools_TextureMixin:Init_Chat_Bubbles()
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save().disabledChatBubble then return false else return true end end)

    e.AddPanel_Check_Sider({
        checkName= (e.onlyChinese and '职业能量' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CLASS, ENERGY))..' 1 2 3',
        checkGetValue= function() return Save().classPowerNum end,
        checkTooltip= WoWTools_TextureMixin.addName,
        checkSetValue= function()
            Save().classPowerNum= not Save().classPowerNum and true or false
            print(WoWTools_Mixin.addName, WoWTools_TextureMixin.addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,
        sliderGetValue= function() return Save().classPowerNumSize or 12 end,
        minValue= 6,
        maxValue= 64,
        step= 1,
        sliderSetValue= function(a, info, value2)
            if value2 then
                local value3= e.GetFormatter1to10(value2, 6, 64)
                Save().classPowerNumSize= value3
                WoWTools_MoveMixin:Init_Class_Power()--职业
                print(WoWTools_Mixin.addName, WoWTools_TextureMixin.addName,'|cnGREEN_FONT_COLOR:'.. value3..'|r', e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        end,
        layout= Layout,
        category= Category,
    })

    e.AddPanel_Check({
        name= e.onlyChinese and '隐藏教程' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, SHOW_TUTORIALS ),
        tooltip='HelpTip',
        category= Category,
        GetValue= function() return not Save().disabledHelpTip end,
        SetValue= function()
            Save().disabledHelpTip= not Save().disabledHelpTip and true or nil
            print(WoWTools_Mixin.addName, WoWTools_TextureMixin.addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    })
end






















function WoWTools_TextureMixin:Init_Options()
    Init_Options()
end
