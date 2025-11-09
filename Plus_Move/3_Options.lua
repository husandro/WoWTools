local function Save()
    return WoWToolsSave['Plus_Move']
end











local function Init()
    local Layout
    WoWTools_MoveMixin.Category, Layout= WoWTools_PanelMixin:AddSubCategory({
        name=WoWTools_MoveMixin.addName,
        disabled= Save().disabled,
    })

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '启用' or ENABLE,
        tooltip= WoWTools_MoveMixin.addName,
        GetValue= function() return not Save().disabled end,
        category= WoWTools_MoveMixin.Category,
        SetValue= function()
            Save().disabled= not Save().disabled and true or nil
            print(
                WoWTools_MoveMixin.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
            )
        end
    })

    WoWTools_PanelMixin:Header(Layout, WoWTools_DataMixin.onlyChinese and '选项' or OPTIONS)

    local sub=  WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '保存位置' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SAVE, CHOOSE_LOCATION:gsub(CHOOSE , '')),
        tooltip= WoWTools_MoveMixin.addName,
        GetValue= function() return Save().SavePoint end,
        category= WoWTools_MoveMixin.Category,
        SetValue= function()
            Save().SavePoint= not Save().SavePoint and true or nil
        end
    })


    WoWTools_PanelMixin:OnlyButton({
        buttonText= WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
        SetValue= function()
           StaticPopup_Show('WoWTools_OK',
            (WoWTools_DataMixin.onlyChinese and '保存位置' or (Save()..CHOOSE_LOCATION:gsub(CHOOSE , '')))
            ..'|n|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2),
            nil,
            {SetValue=function()
                Save().point={}
                print(
                    WoWTools_MoveMixin.addName..WoWTools_DataMixin.Icon.icon2, 
                    WoWTools_DataMixin.onlyChinese and '重设到默认位置' or HUD_EDIT_MODE_RESET_POSITION,
                    '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                )
            end})
        end,
        tooltip=WoWTools_DataMixin.onlyChinese and '重设到默认位置' or HUD_EDIT_MODE_RESET_POSITION,
        layout= Layout,
        category= WoWTools_MoveMixin.Category
    }, sub)


    WoWTools_PanelMixin:Check_Slider({
        checkName= WoWTools_DataMixin.onlyChinese and '移动时Frame透明' or MAP_FADE_TEXT:gsub(WORLD_MAP, 'Frame'),
        checkGetValue= function() return not Save().notMoveAlpha end,
        checkTooltip= WoWTools_DataMixin.onlyChinese and '当你开始移动时，Frame变为透明状态。' or OPTION_TOOLTIP_MAP_FADE:gsub(string.lower(WORLD_MAP), 'Frame'),
        checkSetValue= function()
            Save().notMoveAlpha= not Save().notMoveAlpha and true or nil
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_MoveMixin.addName, WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,

        sliderGetValue= function() return Save().alpha or 0.5 end,
        minValue= 0,
        maxValue= 0.9,
        step= 0.1,
        sliderSetValue= function(_, _, value2)
            if value2 then
                Save().alpha= WoWTools_DataMixin:GetFormatter1to10(value2, 0, 1)
            end
        end,
        layout= Layout,
        category= WoWTools_MoveMixin.Category,
    })


    Init=function()end
end



function WoWTools_MoveMixin:Init_Options()
    Init()
end