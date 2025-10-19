

local function Save()
    return WoWToolsSave['Plus_Texture'] or {}
end





--[[local function GetMinValueAlpha()--透明度，最小值
    local alpha= Save().alpha or 0.5
    WoWTools_TextureMixin.min= alpha<0.5 and 0.5 or (alpha<0.3 and 0.3) or 0.5
end]]








local function Init_Options()
    local sub
    local tooltip= '|cnGREEN_FONT_COLOR:'
            ..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)


    local Category, Layout= WoWTools_PanelMixin:AddSubCategory({
        name= WoWTools_TextureMixin.addName,
        disabled= Save().disabled,
    })
    WoWTools_TextureMixin.Category= Category

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '启用' or ENABLE,
        tooltip= tooltip,
        category= Category,
        GetValue= function() return not Save().disabled end,
        SetValue= function()
            Save().disabled= not Save().disabled and true or nil
        end
    })

    WoWTools_PanelMixin:Header(Layout, WoWTools_DataMixin.onlyChinese and '材质' or TEXTURES_SUBHEADER)

    sub=WoWTools_PanelMixin:Check_Button({
        checkName= WoWTools_DataMixin.onlyChinese and '材质' or TEXTURES_SUBHEADER,
        GetValue= function() return not Save().disabledTexture end,
        SetValue= function()
            Save().disabledTexture= not Save().disabledTexture and true or nil
            print('b',  Save().disabledTexture)
        end,
        buttonText= WoWTools_DataMixin.onlyChinese and '设置颜色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS ,COLOR),
        buttonFunc= function()
            WoWTools_PanelMixin:Open(nil, ('|A:Forge-ColorSwatch:0:0|a'..WoWTools_DataMixin.Player.UseColor.hex..(WoWTools_DataMixin.onlyChinese and '颜色' or COLOR)))
        end,
        tooltip= '|A:Forge-ColorSwatch:0:0|a'..WoWTools_DataMixin.Player.UseColor.hex..(WoWTools_DataMixin.onlyChinese and '颜色' or COLOR),
        layout= Layout,
        category= Category
    })






    WoWTools_PanelMixin:Header(Layout, WoWTools_DataMixin.onlyChinese and '其它' or OTHER)









    sub= WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '聊天泡泡' or CHAT_BUBBLES_TEXT,
        tooltip= (WoWTools_DataMixin.onlyChinese and '在副本无效' or (INSTANCE..' ('..DISABLE..')'))
                ..'|n|n'..((WoWTools_DataMixin.onlyChinese and '说' or SAY)..' CVar: chatBubbles '.. WoWTools_TextMixin:GetShowHide(C_CVar.GetCVarBool("chatBubbles")))
                ..'|n'..((WoWTools_DataMixin.onlyChinese and '小队' or SAY)..' CVar: chatBubblesParty '.. WoWTools_TextMixin:GetShowHide(C_CVar.GetCVarBool("chatBubblesParty")))
                ..'\n\n'..tooltip,
        category= Category,
        GetValue= function() return not Save().disabledChatBubble end,
        SetValue= function()
            Save().disabledChatBubble= not Save().disabledChatBubble and true or nil
            WoWTools_TextureMixin:Init_Chat_Bubbles()
        end
    })



    WoWTools_DataMixin:OnlySlider({
        name= WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE,
        GetValue= function() return Save().chatBubbleSacal or 0.85 end,
        minValue= 0.3,
        maxValue= 1,
        setp= 0.1,
        tooltip= WoWTools_TextureMixin.addName,
        category= Category,
        SetValue= function(_, _, value2)
            if not value2 then return end
            Save().chatBubbleSacal= WoWTools_DataMixin:GetFormatter1to10(value2, 0.3, 1)
            WoWTools_TextureMixin:Init_Chat_Bubbles()
        end
    }, sub)






    WoWTools_DataMixin:Check_Slider({
        checkName= (WoWTools_DataMixin.onlyChinese and '职业能量' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CLASS, ENERGY))..' 1 2 3',
        checkGetValue= function() return Save().classPowerNum end,
        tooltip= tooltip,
        checkSetValue= function()
            Save().classPowerNum= not Save().classPowerNum and true or false
            WoWTools_MoveMixin:Init_Class_Power()--职业
        end,
        sliderGetValue= function()
            local s= Save().classPowerNumSize or 12
            if type(s)~='number' then
                s= 12
                Save().classPowerNumSize=12
            end
            return s or 12
        end,
        minValue= 6,
        maxValue= 64,
        step= 1,
        sliderSetValue= function(_, _, value2)
            if value2 then
                local value3= WoWTools_DataMixin:GetFormatter1to10(value2, 6, 64)
                Save().classPowerNumSize= value3
                WoWTools_MoveMixin:Init_Class_Power()--职业
            end
        end,
        layout= Layout,
        category= Category,
    })



    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '隐藏教程' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, SHOW_TUTORIALS),
        tooltip='HelpTip'..'\n\n'..tooltip,
        category= Category,
        GetValue= function() return not Save().disabledHelpTip end,
        SetValue= function()
            Save().disabledHelpTip= not Save().disabledHelpTip and true or nil
            WoWTools_TextureMixin:Init_HelpTip()--隐藏教程
        end
    })

    Init_Options=function()end
end






















function WoWTools_TextureMixin:Init_Options()
    Init_Options()
end
