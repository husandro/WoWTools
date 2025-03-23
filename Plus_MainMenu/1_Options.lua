--添加控制面板

local function Save()
    return WoWTools_MainMenuMixin.Save
end


local Category, Layout




local function Init_Options()--初始, 选项
    WoWTools_PanelMixin:Header(Layout, 
        (Save().disabled and '|cff828282' or '')
        ..'1) Plus'
    )

    local initializer2= WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_Mixin.onlyChinese and '启用' or ENABLE,
        tooltip= WoWTools_MainMenuMixin.addName,
        GetValue= function() return not Save().disabled end,
        category= Category,
        SetValue= function()
            Save().disabled= not Save().disabled and true or nil
            if not Save().disabled then
                WoWTools_MainMenuMixin:Settings()
            else
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_MainMenuMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_Mixin.onlyChinese and '重新加载UI' or RELOADUI)
            end
        end
    })

    local initializer= WoWTools_Mixin:OnlySlider({
        name= WoWTools_Mixin.onlyChinese and '字体大小' or FONT_SIZE,
        GetValue= function() return Save().size end,
        minValue= 8,
        maxValue= 18,
        setp= 1,
        tooltip= WoWTools_MainMenuMixin.addName,
        category= Category,
        SetValue= function(_, _, value2)
            if value2 then
                Save().size=value2
                WoWTools_MainMenuMixin:Settings()
            end
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save().plus then return true else return false end end)

    initializer= WoWTools_Mixin:Check_Slider({
        checkName= WoWTools_Mixin.onlyChinese and '透明度' or 'Alpha',
        checkGetValue= function() return Save().enabledMainMenuAlpha end,
        checkTooltip= WoWTools_MainMenuMixin.addName,
        checkSetValue= function()
            Save().enabledMainMenuAlpha= not Save().enabledMainMenuAlpha and true or nil
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_MainMenuMixin.addName, WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,
        sliderGetValue= function() return Save().mainMenuAlphaValue end,
        minValue= 0,
        maxValue= 1,
        step= 0.1,
        sliderSetValue= function(_, _, value2)
            if value2 then
                Save().mainMenuAlphaValue= WoWTools_Mixin:GetFormatter1to10(value2, 0, 1)
                WoWTools_MainMenuMixin:Settings()
            end
        end,
        layout= Layout,
        category= Category,
    })
    initializer:SetParentInitializer(initializer2, function() if Save().plus then return true else return false end end)

    WoWTools_PanelMixin:Header(Layout,
        (Save().frameratePlus and '' or '|cff828282')
        ..'2) '..(WoWTools_Mixin.onlyChinese and '系统' or SYSTEM)
    )

    initializer2= WoWTools_PanelMixin:OnlyCheck({
        name= (WoWTools_Mixin.onlyChinese and '每秒帧数:' or FRAMERATE_LABEL)..' Plus',
        tooltip= MicroButtonTooltipText(FRAMERATE_LABEL, "TOGGLEFPS"),
        GetValue= function() return Save().frameratePlus end,
        category= Category,
        SetValue= function()
            Save().frameratePlus= not Save().frameratePlus and true or nil
            if _G['WoWToolsPlusFramerateButton'] then
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_MainMenuMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(Save().frameratePlus), WoWTools_Mixin.onlyChinese and '重新加载UI' or RELOADUI)
            else
                WoWTools_MainMenuMixin:Init_Framerate_Plus()
            end
        end
    })
    initializer= WoWTools_PanelMixin:OnlyCheck({
        name= (WoWTools_Mixin.onlyChinese and '登入' or LOG_IN)..' WoW: '..(WoWTools_Mixin.onlyChinese and '显示' or SHOW),
        tooltip=  MicroButtonTooltipText(FRAMERATE_LABEL, "TOGGLEFPS"),
        GetValue= function() return Save().framerateLogIn end,
        category= Category,
        SetValue= function()
            Save().framerateLogIn= not Save().framerateLogIn and true or nil
            WoWTools_MainMenuMixin:Init_Framerate_Plus()
            if Save().framerateLogIn and not FramerateFrame:IsShown() then
                FramerateFrame:Toggle()
            end
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save().frameratePlus then return true else return false end end)
end







function WoWTools_MainMenuMixin:Init_Category()
    Category, Layout= WoWTools_PanelMixin:AddSubCategory({
            name= self.addName,
            disabled= Save().disabled and not Save().frameratePlus,
        })
end


function WoWTools_MainMenuMixin:Init_Options()
    Init_Options()
end