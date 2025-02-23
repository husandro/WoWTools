--添加控制面板
local e= select(2, ...)
local function Save()
    return WoWTools_MoveMixin.Save
end
local Category, Layout







local function Init_Options()
    e.AddPanel_Header(Layout, e.onlyChinese and '选项' or OPTIONS)

    --移动
    local initializer2= e.AddPanel_Check({
        name= '|TInterface\\Cursor\\UI-Cursor-Move:0|t'..(e.onlyChinese and '移动' or NPE_MOVE),
        tooltip= WoWTools_MoveMixin.addName,
        GetValue= function() return not Save().disabledMove end,
        category= Category,
        SetValue= function()
            Save().disabledMove= not Save().disabledMove and true or nil
            print(WoWTools_Mixin.addName, WoWTools_MoveMixin.addName, e.GetEnabeleDisable(not Save().disabledMove), e.onlyChinese and '重新加载UI' or RELOADUI)
        end
    })

    local initializer= e.AddPanel_Check_Button({
        checkName= '|cnRED_FONT_COLOR:'..(e.onlyChinese and '保存位置' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SAVE, CHOOSE_LOCATION:gsub(CHOOSE , ''))),
        tooltip= '|cnRED_FONT_COLOR:'..(e.onlyChinese and '危险！' or VOICEMACRO_1_Sc_0),
        GetValue= function() return Save().SavePoint end,
        SetValue=function()
            Save().SavePoint= not Save().SavePoint and true or nil
        end,
        buttonText= e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
        buttonFunc= function()
            StaticPopupDialogs[WoWTools_MoveMixin.addName..'MoveZoomClearPoint']= {
                text = WoWTools_MoveMixin.addName..'|n|n'
                ..(e.onlyChinese and '保存位置' or (Save()..CHOOSE_LOCATION:gsub(CHOOSE , ''))),
                button1 = '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2),
                button2 = e.onlyChinese and '取消' or CANCEL,
                whileDead=true, hideOnEscape=true, exclusive=true,
                OnAccept=function()
                    Save().point={}
                    print(WoWTools_Mixin.addName, WoWTools_MoveMixin.addName, e.onlyChinese and '重设到默认位置' or HUD_EDIT_MODE_RESET_POSITION, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD))
                end,
            }
            StaticPopup_Show(WoWTools_MoveMixin.addName..'MoveZoomClearPoint')
        end,
        layout= Layout,
        category=Category,
    }, initializer2)


    initializer= e.AddPanel_Check({
        name= e.onlyChinese and '可以移到屏幕外' or 'Can be moved off screen',
        tooltip= WoWTools_MoveMixin.addName,
        GetValue= function() return Save().moveToScreenFuori end,
        category= Category,
        SetValue= function()
            Save().moveToScreenFuori= not Save().moveToScreenFuori and true or nil
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save().disabledMove then return false else return true end end)

    --缩放
    initializer2= e.AddPanel_Check_Button({
        checkName= '|A:UI-HUD-Minimap-Zoom-In:0:0|a'..(e.onlyChinese and '缩放' or UI_SCALE),
        GetValue= function() return not Save().disabledZoom end,
        SetValue= function()
            Save().disabledZoom= not Save().disabledZoom and true or nil
            print(WoWTools_Mixin.addName, WoWTools_MoveMixin.addName, e.GetEnabeleDisable(not Save().disabledZoom), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,

        buttonText= (e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2),
        buttonFunc= function()
            StaticPopupDialogs[WoWTools_MoveMixin.addName..'MoveZoomClearZoom']= {
                text = WoWTools_MoveMixin.addName..'|n|n'
                ..('|A:UI-HUD-Minimap-Zoom-In:0:0|a'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)),
                button1 = '|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '缩放' or UI_SCALE),
                button2 = e.onlyChinese and '取消' or CANCEL,
                button3=  '|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '大小' or HUD_EDIT_MODE_SETTING_ARCHAEOLOGY_BAR_SIZE),
                whileDead=true, hideOnEscape=true, exclusive=true,
                OnAccept=function()
                    Save().scale={}
                    print(WoWTools_Mixin.addName, WoWTools_MoveMixin.addName, (e.onlyChinese and '缩放' or UI_SCALE)..': 1', '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD))
                end,
                OnAlt=function()
                    Save().size={}
                    Save().disabledSize={}
                    print(WoWTools_Mixin.addName, WoWTools_MoveMixin.addName, e.onlyChinese and '大小' or HUD_EDIT_MODE_SETTING_ARCHAEOLOGY_BAR_SIZE, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD))
                end,
            }
            StaticPopup_Show(WoWTools_MoveMixin.addName..'MoveZoomClearZoom')
        end,

        tooltip= WoWTools_MoveMixin.addName,
        layout= Layout,
        category= Category
    })

    initializer= e.AddPanel_Check_Sider({
        checkName= e.onlyChinese and '移动时Frame透明' or MAP_FADE_TEXT:gsub(WORLD_MAP, 'Frame'),
        checkGetValue= function() return not Save().notMoveAlpha end,
        checkTooltip= e.onlyChinese and '当你开始移动时，Frame变为透明状态。' or OPTION_TOOLTIP_MAP_FADE:gsub(string.lower(WORLD_MAP), 'Frame'),
        checkSetValue= function()
            Save().notMoveAlpha= not Save().notMoveAlpha and true or nil
            print(WoWTools_Mixin.addName, WoWTools_MoveMixin.addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,

        sliderGetValue= function() return Save().alpha or 0.5 end,
        minValue= 0,
        maxValue= 0.9,
        step= 0.1,
        sliderSetValue= function(_, _, value2)
            if value2 then
                Save().alpha= e.GetFormatter1to10(value2, 0, 1)
            end
        end,
        layout= Layout,
        category= Category,
    })
    initializer:SetParentInitializer(initializer2, function() if Save().disabledZoom then return false else return true end end)
end











local function Init_Add()
    Category, Layout= e.AddPanel_Sub_Category({
        name=WoWTools_MoveMixin.addName,
        disabled= Save().disabled,
    })
    WoWTools_MoveMixin.Category= Category

    e.AddPanel_Check({
        name= e.onlyChinese and '启用' or ENABLE,
        tooltip= WoWTools_MoveMixin.addName,
        GetValue= function() return not Save().disabled end,
        category= Category,
        SetValue= function()
            Save().disabled= not Save().disabled and true or nil
            print(WoWTools_Mixin.addName, WoWTools_MoveMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    })

    if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
        Init_Options()
    else
        EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
            if arg1=='Blizzard_Settings' then
                Init_Options()
                EventRegistry:UnregisterCallback(arg1, owner)
            end
        end)
    end
end



function WoWTools_MoveMixin:Init_Options()
    Init_Add()
end