

local P_Save={
    --disabled=true,
    --disabledTexture=true,
    UIButton=WoWTools_DataMixin.Player.husandro,
    CheckBox= WoWTools_DataMixin.Player.husandro,
    alpha= 0.5,

    --disabledChatBubble=true,--禁用，聊天泡泡
    chatBubbleAlpha= 0.5,--聊天泡泡
    chatBubbleSacal= 0.85,

    classPowerNum= WoWTools_DataMixin.Player.husandro,--职业，显示数字
    classPowerNumSize= 23,

    --disabledMainMenu= not WoWTools_DataMixin.Player.husandro, --主菜单，颜色，透明度
    --disabledHelpTip=true,--隐藏所有教程

    Bg={
        --[[UseTexture={
            --自定义，图片 Texture or Atlas

        },]]
        All={--统一设置
            texture='Interface\\AddOns\\WoWTools\\Source\\Background\\Black.tga',
            alpha=0.75,
            nineSlice=0,
        },
        Add={--分开设置
--[[   
            [name]={
                enabled=true,--分开设置
                alpha=0.5,
                texture=texture or atlas,
                notLayer=true-- self:SetDrawLayerEnabled('BACKGROUND', not Save().Add[name].notLayer)
            }
]]

        },
        Anims={
            --disabled=true,
            alpha=0.75,
            speed=10,
        }
    },
    no={},--禁用
}


local function Save()
    return WoWToolsSave['Plus_Texture']
end
local function SaveLog()
    return WoWToolsPlayerDate['TextureClassColor']
end
local Layout











local function Init_Panel()
    local sub
    local tooltip= '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)

    --[[WoWTools_PanelMixin:Header(Layout, WoWTools_DataMixin.onlyChinese and '颜色' or COLOR)

    WoWTools_PanelMixin:CheckMenu({
        category=WoWTools_TextureMixin.Category,
        layout=WoWTools_TextureMixin.Layout,
        name=WoWTools_DataMixin.onlyChinese and '职业颜色' or CLASS_COLORS,
        tooltip=WoWTools_TextureMixin.addName,
        GetValue= function() 
            return not Save().disabledClassColor
        end,
        SetValue= function()
            Save().disabledClassColor= not Save().disabledClassColor and true or nil
        end,

        DropDownGetValue=function()
            
        end,
        DropDownSetValue=function(value)
        end,
        GetOptions=function()
            local container = Settings.CreateControlTextContainer()
            container:Add(1, '|A:bags-greenarrow:0:0|a'..(WoWTools_DataMixin.onlyChinese and '位于上方' or QUESTLINE_LOCATED_ABOVE))
            container:Add(2, '|A:Bags-padlock-authenticator:0:0|a'..(WoWTools_DataMixin.onlyChinese and '位于下方' or QUESTLINE_LOCATED_BELOW))
            return container:GetData()
        end
    })]]

    WoWTools_PanelMixin:Header(Layout, WoWTools_DataMixin.onlyChinese and '材质' or TEXTURES_SUBHEADER)

    --[[sub=WoWTools_PanelMixin:Check_Button({
        checkName= WoWTools_DataMixin.onlyChinese and '材质' or TEXTURES_SUBHEADER,
        GetValue= function() return not Save().disabledTexture end,
        SetValue= function()
            Save().disabledTexture= not Save().disabledTexture and true or nil
        end,
        buttonText= WoWTools_DataMixin.onlyChinese and '设置颜色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS ,COLOR),
        buttonFunc= function()
            WoWTools_PanelMixin:Open(nil, ('|A:Forge-ColorSwatch:0:0|a'..WoWTools_DataMixin.Player.UseColor.hex..(WoWTools_DataMixin.onlyChinese and '颜色' or COLOR)))
        end,
        tooltip= '|A:Forge-ColorSwatch:0:0|a'..WoWTools_DataMixin.Player.UseColor.hex..(WoWTools_DataMixin.onlyChinese and '颜色' or COLOR),
        layout= Layout,
        category= WoWTools_TextureMixin.Category
    })]]
    
    --[[WoWTools_PanelMixin:OnlyMenu({
        SetValue= function(value)
            Save().useColor= value

            if value==2 then
                local valueR, valueG, valueB, valueA= Save().useCustomColorTab.r, Save().useCustomColorTab.g, Save().useCustomColorTab.b, Save().useCustomColorTab.a
                local setA, setR, setG, setB
                local function func()
                    local hex=WoWTools_ColorMixin:RGBtoHEX(setR, setG, setB, setA)--RGB转HEX
                    Save().useCustomColorTab={r=setR, g=setG, b=setB, a=setA, hex= '|c'..hex }
                    Set_Color()--自定义，颜色
                    print(
                        WoWTools_DataMixin.Player.UseColor.hex,
                        WoWTools_DataMixin.addName,
                        WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                    )
                end
                WoWTools_ColorMixin:ShowColorFrame(valueR, valueG, valueB, valueA, function()
                        setR, setG, setB, setA= WoWTools_ColorMixin:Get_ColorFrameRGBA()
                        func()
                    end, function()
                        setR, setG, setB, setA= valueR, valueG, valueB, valueA
                        func()
                    end
                )
            else
                if ColorPickerFrame:IsShown() then
                    ColorPickerFrame.Footer.OkayButton:Click()
                end
                Set_Color()--自定义，颜色
                print(
                    WoWTools_DataMixin.Player.UseColor.hex,
                    WoWTools_DataMixin.addName,
                    WoWTools_DataMixin.onlyChinese and '颜色' or COLOR,
                    '|r',
                    WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                )
            end
        end,
        GetOptions= function()
            local container = Settings.CreateControlTextContainer()
			container:Add(1, WoWTools_DataMixin.onlyChinese and '职业' or CLASS)
			container:Add(2, WoWTools_DataMixin.onlyChinese and '自定义' or CUSTOM)
			--container:Add(3, WoWTools_DataMixin.onlyChinese and '无' or NONE)
			return container:GetData()
        end,
        GetValue= function() return Save().useColor end,
        name= '|A:Forge-ColorSwatch:0:0|a'..WoWTools_DataMixin.Player.UseColor.hex..(WoWTools_DataMixin.onlyChinese and '颜色' or COLOR),
        tooltip= WoWTools_DataMixin.addName,
    })]]



    WoWTools_PanelMixin:OnlyCheck({
        name= 'UIButton',
        tooltip= tooltip,
        category= WoWTools_TextureMixin.Category,
        GetValue= function() return Save().UIButton end,
        SetValue= function()
            Save().UIButton= not Save().UIButton and true or nil
        end
    }, sub)

    WoWTools_PanelMixin:OnlyCheck({
        name= 'CheckBox',
        tooltip= tooltip,
        category= WoWTools_TextureMixin.Category,
        GetValue= function() return Save().CheckBox end,
        SetValue= function()
            Save().CheckBox= not Save().CheckBox and true or nil
        end
    }, sub)

    WoWTools_PanelMixin:Header(Layout, WoWTools_DataMixin.onlyChinese and '其它' or OTHER)


    sub= WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '聊天泡泡' or CHAT_BUBBLES_TEXT,
        tooltip= (WoWTools_DataMixin.onlyChinese and '在副本无效' or (INSTANCE..' ('..DISABLE..')'))
                ..'|n|n'..((WoWTools_DataMixin.onlyChinese and '说' or SAY)..' CVar: chatBubbles '.. WoWTools_TextMixin:GetShowHide(C_CVar.GetCVarBool("chatBubbles")))
                ..'|n'..((WoWTools_DataMixin.onlyChinese and '小队' or SAY)..' CVar: chatBubblesParty '.. WoWTools_TextMixin:GetShowHide(C_CVar.GetCVarBool("chatBubblesParty")))
                ..'\n\n'..tooltip,
        category= WoWTools_TextureMixin.Category,
        GetValue= function() return not Save().disabledChatBubble end,
        SetValue= function()
            Save().disabledChatBubble= not Save().disabledChatBubble and true or nil
            WoWTools_TextureMixin:Init_Chat_Bubbles()
        end
    })



    WoWTools_PanelMixin:OnlySlider({
        name= WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE,
        GetValue= function() return Save().chatBubbleSacal or 0.85 end,
        minValue= 0.3,
        maxValue= 1,
        setp= 0.1,
        tooltip= WoWTools_TextureMixin.addName,
        category= WoWTools_TextureMixin.Category,
        SetValue= function(_, _, value2)
            if not value2 then return end
            Save().chatBubbleSacal= WoWTools_DataMixin:GetFormatter1to10(value2, 0.3, 1)
            WoWTools_TextureMixin:Init_Chat_Bubbles()
        end
    }, sub)






    WoWTools_PanelMixin:Check_Slider({
        checkName= (WoWTools_DataMixin.onlyChinese and '职业能量' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CLASS, ENERGY))..' 1 2 3',
        checkGetValue= function() return Save().classPowerNum end,
        tooltip= tooltip,
        checkSetValue= function()
            Save().classPowerNum= not Save().classPowerNum and true or false
            WoWTools_TextureMixin:Init_Class_Power()--职业
        end,
        sliderGetValue= function()
            local s= Save().classPowerNumSize or 23
            if type(s)~='number' then
                s= 23
                Save().classPowerNumSize=23
            end
            return s
        end,
        minValue= 6,
        maxValue= 64,
        step= 1,
        sliderSetValue= function(_, _, value2)
            if value2 then
                local value3= WoWTools_DataMixin:GetFormatter1to10(value2, 6, 64)
                Save().classPowerNumSize= value3
                WoWTools_TextureMixin:Init_Class_Power()--职业
            end
        end,
        layout= Layout,
        category= WoWTools_TextureMixin.Category,
    })



    local function Add_Options(name)
        WoWTools_PanelMixin:OnlyCheck({
            name= name:gsub('Blizzard_', ''),
            tooltip= tooltip,
            category= WoWTools_TextureMixin.Category,
            Value= not Save().no[name],
            GetValue= function() return not Save().no[name] end,
            SetValue= function()
                Save().no[name]= not Save().no[name] and true or nil
            end
        })
    end

    WoWTools_PanelMixin:Header(Layout, 'Event')
    for name in pairs(WoWTools_TextureMixin.Events) do
        Add_Options(name)
    end

    WoWTools_PanelMixin:Header(Layout, 'Frame')
    for name in pairs(WoWTools_TextureMixin.Frames) do
        Add_Options(name)
    end


    Init_Panel=function()end
end












local function Init()
    for name, func in pairs(WoWTools_TextureMixin.Frames) do
        if _G[name] then
            if not Save().no[name] then
                func(WoWTools_TextureMixin)
            end
        elseif WoWTools_DataMixin.Player.husandro then
            print(WoWTools_TextureMixin.addName, 'Frames[|cnWARNING_FONT_COLOR:'..name..'|r]', '没有发现')
        end
        WoWTools_TextureMixin.Frames[name]= nil
    end

    for name, func in pairs(WoWTools_TextureMixin.Events) do
        if C_AddOns.IsAddOnLoaded(name) then
            if not Save().no[name] then
                func(WoWTools_TextureMixin)
            end
            WoWTools_TextureMixin.Events[name]= nil
        end
    end

    Init=function()end
end






local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

local function Clear_Frame()
    WoWTools_TextureMixin.Events={}
    WoWTools_TextureMixin.Frames={}
    panel:UnregisterEvent('ADDON_LOADED')
    panel:SetScript('OnEvent', nil)
    Clear_Frame=function()end
end

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_Texture']= WoWToolsSave['Plus_Texture'] or P_Save

            Save().Bg= Save().Bg or P_Save.Bg
            Save().Bg.Anims= Save().Bg.Anims or P_Save.Bg.Anims
            Save().no= Save().no or {}

            P_Save= nil

            WoWToolsPlayerDate['BGTexture']= WoWToolsPlayerDate['BGTexture'] or {}

            WoWTools_TextureMixin.addName= '|A:AnimCreate_Icon_Texture:0:0|a'..(WoWTools_DataMixin.onlyChinese and '材质' or TEXTURES_SUBHEADER)

            WoWTools_TextureMixin.Category, Layout= WoWTools_PanelMixin:AddSubCategory({
                name= WoWTools_TextureMixin.addName,
                disabled= Save().disabled,
            })

            WoWTools_PanelMixin:Check_Button({
                checkName= WoWTools_DataMixin.onlyChinese and '启用' or ENABLE,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    Init_Panel()
                end,
                buttonText= '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '重置' or RESET),
                buttonFunc= function()
                    StaticPopup_Show('WoWTools_RestData',
                        WoWTools_TextureMixin.addName
                        ..'|n|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)..'|r',
                        nil,
                    function()
                        WoWToolsSave['Plus_Texture']= nil
                        WoWTools_DataMixin:Reload()
                    end)
                end,
                tooltip= '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD),
                layout= Layout,
                category= WoWTools_TextureMixin.Category,
            })

            if Save().disabled then
                Clear_Frame()
            else
                Init_Panel()

                WoWTools_TextureMixin:Init_Class_Power()--职业
                WoWTools_TextureMixin:Init_Chat_Bubbles()--聊天泡泡

                if Save().disabledTexture then
                    self:UnregisterEvent(event)
                else
                    Init()
                end
            end

        elseif WoWToolsSave then
            if WoWTools_TextureMixin.Events[arg1] then
                if not Save().no[arg1] then
                    WoWTools_TextureMixin.Events[arg1](WoWTools_TextureMixin)
                end
                WoWTools_TextureMixin.Events[arg1]= nil
            end
        end
    end
end)